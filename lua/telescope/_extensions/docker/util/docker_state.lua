local util = require "telescope._extensions.docker.util"
local enum = require "telescope._extensions.docker.enum"
local setup = require "telescope._extensions.docker.setup"
local Container = require "telescope._extensions.docker.containers.container"
local Image = require "telescope._extensions.docker.images.image"

local job_id

---@class State
---@field env table?: Environment variables
---@field binary string: Executable docker binary
local State = {
  binary = "docker",
  locked = false,
  env = nil,
}
State.__index = State

---@param env table?
---@return State
function State:new(env)
  local o = setmetatable({}, State)
  local binary = setup.get_option "binary" or "docker"
  if type(binary) == "string" then
    o.binary = binary
  end
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

function State:docker_command(cmd_args)
  if type(cmd_args) ~= "table" or not next(cmd_args) then
    util.warn("Invalid docker arguments: " .. vim.inspect(cmd_args))
    return
  end
  if self.locked then
    util.warn "Docker state is locked, please wait a moment"
    return
  end
  self.locked = true
  local ok, e = pcall(function()
    if
      vim.api.nvim_buf_get_option(0, "filetype")
      == enum.TELESCOPE_PROMPT_FILETYPE
    then
      -- NOTE: close telescope popup if open
      vim.api.nvim_buf_delete(0, { force = true })
    end

    local cmd = { self.binary, unpack(cmd_args) }

    local init_term = setup.get_option "init_term"
    if type(init_term) == "function" then
      init_term(cmd, self:get_env())
      return
    elseif
      type(init_term) ~= "string"
      or (not init_term:match "tab" and not init_term:match "split")
    then
      init_term = "tabnew"
    end
    vim.api.nvim_exec(init_term, false)
    local opts = { detach = false }
    local env = self:get_env()
    if env then
      opts.env = env
    end
    vim.fn.termopen(cmd, opts)
  end)
  if not ok then
    util.warn("Failed to execute docker command:", e)
  end
  self.locked = false
end

function State:docker_job(container, cmd_args, callback)
  if type(cmd_args) ~= "table" or not next(cmd_args) then
    util.warn("Invalid docker arguments: " .. vim.inspect(cmd_args))
    return
  end
  if self.locked then
    util.warn "Docker state is locked, please wait a moment"
    return
  end
  self.locked = true
  local ok, e = pcall(function()
    local cmd = {
      self.binary,
      unpack(cmd_args),
    }
    local error = {}
    local opts = {
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
        if type(callback) == "function" then
          callback(container)
        end
      end,
    }
    local env = self:get_env()
    if env then
      opts.env = env
    end
    vim.fn.jobstart(cmd, opts)
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

    local containers = {}

    local opts = {
      detach = false,
      on_stdout = function(_, data)
        local ok, err = pcall(function()
          for _, json in ipairs(data) do
            if json:len() > 0 then
              json = string.sub(json, 2, #json - 1)
              local container = Container:new(json)
              local env = self:get_env()
              container.env = env
              table.insert(containers, container)
            end
          end
        end)
        if not ok then
          util.warn("Error when decoding container: ", err)
        end
      end,
      on_exit = function()
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

    local opts = {
      detach = false,
      on_stdout = function(_, data)
        local ok, err = pcall(function()
          for _, json in ipairs(data) do
            if json:len() > 0 then
              json = string.sub(json, 2, #json - 1)
              local image = Image:new(json)
              table.insert(images, image)
            end
          end
        end)
        if not ok then
          util.warn("Error when decoding image: ", err)
        end
      end,
      on_exit = function()
        self.locked = false
        if callback then
          callback(images)
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
    return images
  end)
  if not ok then
    util.warn(images)
    self.locked = false
    return {}
  end
  return images
end

return State
