local util = require "telescope-docker.util"
local enum = require "telescope-docker.enum"
local setup = require "telescope-docker.setup"
local Node = require "telescope-docker.pickers.swarm.node"
local telescope_actions = require "telescope.actions"

---@class State
---@field env table
local State = {
  __cache = {},
}
State.__index = State

---@param env table?
---@return State
function State:new(env)
  local o = setmetatable({}, State)
  if type(env) == "table" and next(env) then
    o.env = vim.tbl_extend("force", o.env or {}, env)
  end
  return o
end

local __binary
local __plugin_binary
local __get_version
local __get_plugin_version

---@return any?: callback return values
---@return string?: Error
function State:binary(callback)
  return __binary(callback)
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
---@field binary string?

---Execute a docker command with the provided arguments in
---a new terminal window.
---
---@param opts DockerCommandOpts
function State:docker_command(opts)
  if type(opts.binary) == "string" then
    return self:__docker_command(opts.binary, opts)
  end
  return __binary(function(binary, _)
    return self:__docker_command(binary, opts)
  end)
end

---@class DockerJobOpts
---@field item table
---@field args table
---@field callback function?
---@field err_callback function?
---@field start_msg string?
---@field end_msg string?
---@field ask_for_input boolean?
---@field cwd string?
---@field env table?
---@field await boolean?
---@field silent boolean?

---Execute an async docker command with the provided arguments.
---
---@param opts DockerJobOpts
function State:docker_job(opts)
  return __binary(function(binary, _)
    return self:__docker_job(binary, opts)
  end)
end

function State:plugin_binary(
  name,
  default_binary,
  fall_back,
  builtin_fallback,
  version_string,
  default_warn
)
  return __plugin_binary(
    name,
    default_binary,
    fall_back,
    builtin_fallback,
    version_string,
    default_warn
  )
end

---@param callback function?
---@return Item[]
function State:fetch_items(callback)
  if type(callback) == "function" then
    return callback {}
  end
  return {}
end

function State:__docker_command(binary, opts)
  opts = opts or {}
  if type(opts.args) ~= "table" or not next(opts.args) then
    util.warn("Invalid arguments: " .. vim.inspect(opts.args))
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
    env = vim.tbl_extend("force", env or {}, opts.env or {})
    if type(env) == "table" and next(env) then
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
end

function State:__docker_job(binary, opts)
  opts = opts or {}
  if type(opts.args) ~= "table" or not next(opts.args) then
    util.warn("Invalid docker arguments: " .. vim.inspect(opts.args))
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

  local ok, jid = pcall(function()
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
        if code ~= 0 then
          if not opts.silent then
            if #error > 0 then
              util.warn(table.concat(error, "\n"))
            else
              util.warn("Docker job - exited with code: " .. vim.inspect(code))
            end
          end
          if type(opts.err_callback) == "function" then
            opts.err_callback(code, error)
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
    env = vim.tbl_extend("force", env or {}, opts.env or {})
    if type(env) == "table" and next(env) then
      o.env = env
    end
    if type(opts.cwd) == "string" then
      o.cwd = opts.cwd
    end
    return vim.fn.jobstart(cmd, o)
  end)
  if not ok then
    util.warn(jid)
    return
  end
  if opts.await and type(jid) == "number" then
    vim.fn.jobwait({ jid }, 10000)
  end
  return jid
end

function __plugin_binary(
  name,
  default_binary,
  fall_back,
  builtin_fallback,
  version_string,
  default_warn
)
  local err = State.__cache[name .. "_error"]
  local warn = State.__cache[name .. "_warning"]
  if err then
    return nil, nil, err, warn
  end
  local bin = State.__cache[name .. "_binary"]
  local version = State.__cache[name .. "_version"]
  if type(bin) == "string" then
    return bin, version, nil, warn
  end
  local default_bin_used = true
  local binary = setup.get_option(name .. "_binary")
  if type(binary) ~= "string" then
    binary = default_binary
    default_bin_used = false
  end
  version = __get_plugin_version(name, binary, version_string)
  if type(version) == "string" then
    State.__cache[name .. "_binary"] = binary
    State.__cache[name .. "_version"] = version
    return binary, version, nil, warn
  end
  _, err = __binary(function(b)
    if type(fall_back) == "string" then
      bin = b .. " " .. fall_back
      version = __get_plugin_version(name, bin, version_string)
      if type(version) == "string" then
        State.__cache[name .. "_binary"] = bin
        State.__cache[name .. "_version"] = version
        if default_bin_used then
          warn = "Failed to get '"
            .. name
            .. "' version with '"
            .. binary
            .. "', falling back to '"
            .. bin
            .. "'"
          State.__cache[name .. "_warning"] = warn
        end
        return
      elseif type(default_warn) == "string" then
        warn = default_warn
        State.__cache[name .. "_warning"] = warn
      end
    end
    if builtin_fallback then
      bin = b
      State.__cache[name .. "_binary"] = bin
      return
    else
      State.__cache[name .. "_error"] = "Failed to get '"
        .. name
        .. "' version with '"
        .. binary
        .. "' and '"
        .. bin
        .. "'"
    end
  end)
  if err == nil then
    err = State.__cache[name .. "_error"]
  end
  if err ~= nil then
    State.__cache[name .. "_error"] = err
    return nil, nil, err, warn
  end
  binary = State.__cache[name .. "_binary"]
  version = State.__cache[name .. "_version"]
  return binary, version, err, warn
end

local __version
function __get_version(binary)
  local v = __version { binary, "--version" }
  if type(v) == "string" then
    if string.find(v:lower(), binary) == nil then
      return nil
    end
  end
  return v
end

function __get_plugin_version(name, binary, version_string)
  local v = __version(binary .. " " .. version_string)
  if type(v) == "string" then
    if string.find(v:lower(), name) == nil then
      return nil
    end
  end
  return v
end

function __version(cmd)
  local ok, v = pcall(function()
    local version = nil
    if type(cmd) == "table" then
      cmd = table.concat(cmd, " ")
    end
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

function __binary(callback)
  if State.__cache.error then
    return nil, State.__cache.error
  end
  if State.__cache.binary and State.__cache.version then
    if type(callback) ~= "function" then
      return nil, nil
    end
    return callback(State.__cache.binary, State.__cache.version), nil
  end
  local b = setup.get_option "binary"
  if type(b) ~= "string" then
    b = "docker"
  end
  local version = __get_version(b)
  if type(version) ~= "string" then
    State.__cache.error = "Failed to get version for docker binary: "
      .. vim.inspect(b)
    return nil, State.__cache.error
  end

  State.__cache.binary = b
  State.__cache.version = version

  if type(callback) ~= "function" then
    return nil, nil
  end

  return callback(b, version), nil
end

function State:__fetch_docker_items(cmd, process_json, callback, do_preprocess)
  if do_preprocess == nil then
    do_preprocess = true
  end
  local ok, all_items = pcall(function()
    local items = {}
    local secondary_items = {}

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
            if do_preprocess then
              json = util.preprocess_json(json)
            end
            if type(json) == "string" and json:len() > 0 then
              local item, secondary_item = process_json(json)
              if item ~= nil then
                table.insert(items, item)
              elseif secondary_item ~= nil then
                table.insert(secondary_items, secondary_item)
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
            "error(s) occurred while fetching docker data:",
            err
          )
        end

        local i = {}
        for _, item in ipairs(items) do
          table.insert(i, item)
        end
        for _, item in ipairs(secondary_items) do
          table.insert(i, item)
        end
        if callback then
          callback(i)
        end
      end,
    }
    local env = self:get_env()
    if env then
      opts.env = env
    end
    local job_id = vim.fn.jobstart(cmd, opts)
    if not callback then
      vim.fn.jobwait({ job_id }, 2000)
    end
    local i = {}
    for _, item in ipairs(items) do
      table.insert(i, item)
    end
    for _, item in ipairs(secondary_items) do
      table.insert(i, item)
    end
    return i
  end)
  if not ok then
    util.warn(all_items)
    return {}
  end
  return all_items
end

return State
