local util = require "telescope._extensions.docker.util"
local enum = require "telescope._extensions.docker.enum"
local setup = require "telescope._extensions.docker.setup"
local Container = require "telescope._extensions.docker.containers.container"
local Image = require "telescope._extensions.docker.images.image"
local telescope_actions = require "telescope.actions"

local job_id

---@class State
---@field env table?: Environment variables
local State = {
  locked = false,
  env = nil,
  __cache = {},
}
State.__index = State

---@return any?: callback return values
---@return string?: Error
function State:binary(callback)
  if self.__cache.error then
    return nil, self.__cache.error
  end
  if self.__cache.binary and self.__cache.version then
    return callback(self.__cache.binary, self.__cache.version), nil
  end
  local b = setup.get_option "binary"
  if type(b) ~= "string" then
    b = "docker"
  end
  if vim.fn.executable(b) ~= 1 then
    self.__cache.error = "Docker binary not executable: " .. b
    return nil, self.__cache.error
  end
  local version = self:__get_version(b)
  if type(version) ~= "string" then
    self.__cache.error = "Failed to get docker version"
    return nil, self.__cache.error
  end

  self.__cache.binary = b
  self.__cache.version = version

  return callback(b, version), nil
end

---@return any? callback return values
---@return string? Error
---@return string? Warning
function State:compose_binary(callback)
  if self.__cache.compose_error then
    return nil, self.__cache.compose_error
  end
  if self.__cache.compose_binary and self.__cache.compose_version then
    return callback(self.__cache.compose_binary, self.__cache.compose_version),
      nil
  end
  local _, err = self:binary(function(binary, _)
    local b = setup.get_option "compose_binary"
    if type(b) ~= "string" then
      b = "docker-compose"
    end
    if vim.fn.executable(b) ~= 1 then
      self.__cache.compose_error = "Docker compose binary not executable: "
        .. b
      return
    end
    local version, used_binary = self:__get_compose_version(b, binary)
    if type(version) ~= "string" then
      self.__cache.compose_error = "Failed to get docker compose version"
      return
    end
    self.__cache.compose_binary = used_binary
    self.__cache.compose_version = version
    if used_binary ~= b then
      self.__cache.compose_warning = "Compose binary "
        .. vim.inspect(b)
        .. " is not valid, using "
        .. vim.inspect(used_binary)
    end
  end)
  if err ~= nil then
    return nil, err
  end
  if self.__cache.compose_error then
    return nil, self.__cache.compose_error, self.__cache.compose_warning
  end
  return callback(self.__cache.compose_binary, self.__cache.compose_version),
    nil,
    self.__cache.compose_warning
end

---@param env table?
---@return State
function State:new(env)
  local o = setmetatable({}, State)
  if type(env) == "table" and next(env) then
    o.env = env
  end
  return o
end

---@param env table?
function State:set_env(env)
  if type(env) ~= "table" or not next(env) then
    return
  end
  self.env = vim.tbl_extend("force", self.env or {}, env)
end

function State:get_env()
  local env = vim.g.docker_env
  if type(env) ~= "table" then
    env = {}
  end
  env = vim.tbl_extend("force", env, self.env or {})
  if next(env) then
    return env
  end
  return nil
end

---@class DockerCommandOpts
---@field args string[]: Docker command arguments
---@field ask_for_input boolean: Whether to ask for input
---@field cwd string?: Current working directory

---Execute a docker command with the provided arguments in
---a new terminal window.
---
---@param opts DockerCommandOpts
function State:docker_command(opts)
  self:binary(function(binary, _)
    opts = opts or {}
    if type(opts.args) ~= "table" or not next(opts.args) then
      util.warn("Invalid docker arguments: " .. vim.inspect(opts.args))
      return
    end
    if self.locked then
      util.warn "Docker state is locked, please wait a moment"
      return
    end
    if opts.ask_for_input then
      local input = vim.fn.input {
        prompt = binary .. " " .. table.concat(opts.args, " ") .. " ",
        default = "",
        cancelreturn = false,
      }
      if type(input) ~= "string" then
        return
      end
      for _, arg in ipairs(vim.split(input, " ")) do
        if arg:len() > 0 then
          table.insert(opts.args, arg)
        end
      end
    end

    self.locked = true
    local ok, e = pcall(function()
      if
        vim.api.nvim_buf_get_option(0, "filetype")
        == enum.TELESCOPE_PROMPT_FILETYPE
      then
        local bufnr = vim.api.nvim_get_current_buf()
        pcall(telescope_actions.close, bufnr)
      end

      local cmd = { binary, unpack(opts.args) }
      local o = { detach = false }
      local env = self:get_env()
      if env then
        o.env = env
      end
      if type(opts.cwd) == "string" then
        o.cwd = opts.cwd
      end
      local init_term = setup.get_option "init_term"
      util.open_in_shell(cmd, init_term, o)
    end)
    if not ok then
      util.warn("Failed to execute docker command:", e)
    end
    self.locked = false
  end)
end

---@class DockerJobOpts
---@field item Container|Image
---@field args table
---@field callback function
---@field start_msg string
---@field end_msg string
---@field ask_for_input boolean

---Execute an async docker command with the provided arguments.
---
---@param opts DockerJobOpts
function State:docker_job(opts)
  self:binary(function(binary, _)
    opts = opts or {}
    if type(opts.args) ~= "table" or not next(opts.args) then
      util.warn("Invalid docker arguments: " .. vim.inspect(opts.args))
      return
    end
    if self.locked then
      util.warn "Docker state is locked, please wait a moment"
      return
    end

    if opts.ask_for_input then
      local input = vim.fn.input {
        prompt = binary .. " " .. table.concat(opts.args, " ") .. " ",
        default = "",
        cancelreturn = false,
      }
      if type(input) ~= "string" then
        return
      end
      for _, arg in ipairs(vim.split(input, " ")) do
        if arg:len() > 0 then
          table.insert(opts.args, arg)
        end
      end
    end

    self.locked = true
    local ok, e = pcall(function()
      if type(opts.start_msg) == "string" then
        util.info(opts.start_msg)
      end
      local cmd = {
        binary,
        unpack(opts.args),
      }
      local error = {}
      local o = {
        detach = false,
        on_stderr = function(_, data)
          for _, d in ipairs(data) do
            if d:len() > 0 then
              table.insert(error, d)
            end
          end
        end,
        on_exit = function(_, code)
          self.locked = false
          if code ~= 0 then
            if #error > 0 then
              util.warn(table.concat(error, "\n"))
            else
              util.warn("Docker job - exited with code: " .. vim.inspect(code))
            end
            return
          end
          if type(opts.callback) == "function" then
            if type(opts.end_msg) == "string" then
              util.info(opts.end_msg)
            end
            opts.callback(opts.item)
          end
        end,
      }
      local env = self:get_env()
      if env then
        o.env = env
      end
      vim.fn.jobstart(cmd, o)
    end)
    if not ok then
      util.warn(e)
      self.locked = false
    end
  end)
end

---@param callback function?
---@return Container[]
function State:fetch_containers(callback)
  local containers, _ = self:binary(function(binary, _)
    if self.locked then
      util.warn "Docker state is locked, please wait a moment"
      return {}
    end
    self.locked = true
    local ok, containers = pcall(function()
      local cmd = {
        binary,
        "ps",
        "-a",
        "--format='{{json . }}'",
      }

      local err = nil
      local err_count = 0

      local containers = {}

      local opts = {
        detach = false,
        on_stdout = function(_, data)
          if type(data) ~= "table" then
            return
          end
          for _, json in ipairs(data) do
            local ok, e = pcall(function()
              json = util.preprocess_json(json)
              if json ~= nil then
                local container = Container:new(json)
                local env = self:get_env()
                container.env = env
                table.insert(containers, container)
              end
            end)
            if not ok then
              err = e
              err_count = err_count + 1
            end
          end
        end,
        on_exit = function()
          if err_count > 0 then
            util.warn(
              err_count,
              "error(s) occurred while fetching containers:",
              err
            )
          end

          self.locked = false

          if callback then
            callback(containers)
          end
        end,
      }
      local env = self:get_env()
      if env then
        opts.env = env
      end
      if job_id then
        pcall(vim.fn.jobstop, job_id)
      end
      job_id = vim.fn.jobstart(cmd, opts)
      if not callback then
        vim.fn.jobwait({ job_id }, 2000)
      end
      return containers
    end)
    if not ok then
      util.warn(containers)
      self.locked = false
      return {}
    end
    return containers
  end)
  return containers or {}
end

---@param callback function?
---@return Image[]
function State:fetch_images(callback)
  local images, _ = self:binary(function(binary, _)
    if self.locked then
      util.warn "Docker state is locked, please wait a moment"
      return {}
    end
    self.locked = true
    local ok, images = pcall(function()
      local cmd = {
        binary,
        "image",
        "ls",
        "-a",
        "--format='{{json . }}'",
      }
      local images = {}
      local unnamed_images = {}

      local err = nil
      local err_count = 0

      local opts = {
        detach = false,
        on_stdout = function(_, data)
          if type(data) ~= "table" then
            return
          end
          for _, json in ipairs(data) do
            local ok, e = pcall(function()
              json = util.preprocess_json(json)
              if json ~= nil then
                local image = Image:new(json)
                local env = self:get_env()
                image.env = env
                if image:name() == "<none>:<none>" then
                  table.insert(unnamed_images, image)
                else
                  table.insert(images, image)
                end
              end
            end)
            if not ok then
              err = e
              err_count = err_count + 1
            end
          end
        end,
        on_exit = function()
          if err_count > 0 then
            util.warn(
              err_count,
              "error(s) occurred while fetching images:",
              err
            )
          end

          self.locked = false
          local im = {}
          for _, image in ipairs(images) do
            table.insert(im, image)
          end
          for _, image in ipairs(unnamed_images) do
            table.insert(im, image)
          end
          if callback then
            callback(im)
          end
        end,
      }
      local env = self:get_env()
      if env then
        opts.env = env
      end
      if job_id then
        pcall(vim.fn.jobstop, job_id)
      end
      job_id = vim.fn.jobstart(cmd, opts)
      if not callback then
        vim.fn.jobwait({ job_id }, 2000)
      end
      local im = {}
      for _, image in ipairs(images) do
        table.insert(im, image)
      end
      for _, image in ipairs(unnamed_images) do
        table.insert(im, image)
      end
      return im
    end)
    if not ok then
      util.warn(images)
      self.locked = false
      return {}
    end
    return images
  end)
  return images or {}
end

function State:__get_compose_version(compose_binary, binary)
  local b = compose_binary
  local v = self:__version { b, "--version" }
  if type(v) ~= "string" or string.find(v:lower(), "compose") == nil then
    v = self:__version { binary, "compose", "version" }
    if v then
      b = binary .. " compose"
    end
  end
  if type(v) == "string" then
    if string.find(v:lower(), "compose") == nil then
      return nil
    end
  end
  return v, b
end

function State:__get_version(binary)
  local v = self:__version { binary, "--version" }
  if type(v) == "string" then
    if string.find(v:lower(), binary) == nil then
      return nil
    end
  end
  return v
end

function State:__version(cmd)
  local ok, v = pcall(function()
    local version = nil
    local j
    j = vim.fn.jobstart(cmd, {
      detach = false,
      on_stdout = function(_, data)
        for _, d in ipairs(data) do
          if type(d) == "string" and d:len() > 0 then
            if version == nil then
              version = d
            else
              version = version .. " " .. d
            end
          end
        end
      end,
    })
    vim.fn.jobwait({ j }, 10000)
    return version
  end)
  if not ok or type(v) ~= "string" or v:len() == 0 then
    return nil
  end
  return v
end

return State
