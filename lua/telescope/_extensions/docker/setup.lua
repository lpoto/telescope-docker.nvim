local util = require "telescope._extensions.docker.util"

local setup = {}

local opts = {}

---Creates the default picker options from the provided
---options. If the `theme` field with a string value is added,
---the telescope theme identified by that value is added to the options.
---@param o table
function setup.setup(o)
  if type(o) ~= "table" then
    util.warn "Containers config should be a table!"
    return
  end

  if o.init_term ~= nil and type(o.init_term) ~= "function" then
    util.warn "'init_term' should be a function"
    o.init_term = nil
  end
  if o.log_level ~= nil and type(o.log_level) ~= "number" then
    util.warn "'log_level' should be number"
  else
    util.set_log_level(o.log_level)
  end
  if o.binary ~= nil and type(o.binary) ~= "string" then
    o.binary = nil
  end
  o.log_level = nil

  if type(o.theme) == "string" then
    local theme = require("telescope.themes")["get_" .. o.theme]
    if theme == nil then
      util.warn("No such telescope theme: ", o.name)
    else
      o = theme(o)
    end
  end
  opts = vim.tbl_extend("force", opts, o)
end

function setup.get_option(...)
  local v = opts
  for _, k in ipairs { select(1, ...) } do
    if type(k) ~= "string" then
      return nil
    end
    v = opts[k]
    if not v then
      return v
    end
  end
  return v
end

---@param callback function
---@param o table?
function setup.call_with_opts(callback, o)
  return callback(vim.tbl_extend("force", opts, o or {}))
end

return setup
