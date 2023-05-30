local util = require "telescope._extensions.docker.util"
local enum = require "telescope._extensions.docker.enum"
local setup = require "telescope._extensions.docker.setup"
local Container = require "telescope._extensions.docker.containers.container"
local Image = require "telescope._extensions.docker.images.image"
local telescope_actions = require "telescope.actions"

local job_id

---@class State
---@field env table?: Environment variables
---@field binary string: Executable docker binary
local State = {
  binary = "docker",
  locked = false,
  env = nil,
  docker_version = nil,
}
State.__index = State

---@return string
function State.get_binary()
  return setup.get_option "binary" or "docker"
end

---@param env table?
---@return State
---@return string?: Error message
function State:new(env)
  local o = setmetatable({}, State)
  local binary = State.get_binary()
  if type(binary) == "string" then
    o.binary = binary
  end
  if type(env) == "table" and next(env) then
    o.env = env
  end
  local err = nil
  if not o.docker_version then
    local version = o:version()
    if type(version) ~= "string" then
      err = "Failed to get docker version"
    else
      o.docker_version = version
      State.docker_version = version
    end
  end
  return o, err
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
      prompt = self.binary .. " " .. table.concat(opts.args, " ") .. " ",
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

    local cmd = { self.binary, unpack(opts.args) }
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
      prompt = self.binary .. " " .. table.concat(opts.args, " ") .. " ",
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
      self.binary,
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
end

---@param callback function?
---@return Container[]
function State:fetch_containers(callback)
  if self.locked then
    util.warn "Docker state is locked, please wait a moment"
    return {}
  end
  self.locked = true
  local ok, containers = pcall(function()
    local cmd = {
      self.binary,
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
end

---@param callback function?
---@return Image[]
function State:fetch_images(callback)
  if self.locked then
    util.warn "Docker state is locked, please wait a moment"
    return {}
  end
  self.locked = true
  local ok, images = pcall(function()
    local cmd = {
      self.binary,
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
          util.warn(err_count, "error(s) occurred while fetching images:", err)
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
end

function State:version()
  local ok, v = pcall(function()
    local version = nil
    local j
    j = vim.fn.jobstart({
      self.binary,
      "--version",
    }, {
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
    vim.fn.jobwait({ j }, 2000)
    return version
  end)
  if not ok or type(v) ~= "string" then
    return nil
  end
  return v
end

return State
