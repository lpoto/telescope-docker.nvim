local enum = require "telescope._extensions.docker.enum"

local util = {}

local log_level = nil
local notify

function util.warn(...)
  notify(vim.log.levels.WARN, ...)
end

function util.error(...)
  notify(vim.log.levels.ERROR, ...)
end

function util.info(...)
  notify(vim.log.levels.INFO, ...)
end

---@param lvl number
function util.set_log_level(lvl)
  if type(lvl) == "number" then
    log_level = lvl
  end
end

---@param command string
---@param init_term function?
function util.open_in_shell(command, init_term)
  util.info("Opening in shell: " .. command)
  if
      vim.api.nvim_buf_get_option(0, "filetype")
      == enum.TELESCOPE_PROMPT_FILETYPE
  then
    -- NOTE: close telescope popup if open
    local bufnr = vim.api.nvim_get_current_buf()
    pcall(telescope_actions.close, bufnr)
  end
  if type(init_term) ~= "function" then
    vim.api.nvim_exec("noautocmd keepjumps tabnew", false)
    vim.api.nvim_exec("noautocmd term " .. command, false)
  else
    init_term(command)
  end
end

function notify(lvl, ...)
  if log_level ~= nil and log_level > lvl then
    return
  end
  local args = { select(1, ...) }
  vim.schedule(function()
    local s = ""
    for _, v in ipairs(args) do
      if type(v) ~= "string" then
        v = vim.inspect(v)
      end
      if s:len() > 0 then
        s = s .. " " .. v
      else
        s = v
      end
    end
    if s:len() > 0 then
      vim.notify(s, lvl, {
        title = enum.TITLE,
      })
    end
  end)
end

function util.create_preview_buffer(lines)
  local ok, b = pcall(function()
    local buf = vim.api.nvim_create_buf(false, true)
    pcall(vim.api.nvim_buf_set_lines, buf, 0, -1, false, lines)
    pcall(vim.api.nvim_buf_set_option, buf, "buftype", "nofile")
    pcall(vim.api.nvim_buf_set_option, buf, "bufhidden", "wipe")
    pcall(vim.api.nvim_buf_set_option, buf, "syntax", "yaml")
    pcall(vim.api.nvim_buf_set_option, buf, "filetype", "yaml")
    return buf
  end)
  if not ok then
    util.warn(b)
    return -1
  end
  return b
end

--- Preprocess json string and remove double
--- quotations and special quotations that may
--- be outputted by docker on macOS
function util.preprocess_json(json)
  json = json:gsub("\r", "")
  json = json:gsub("\n", "")

  json = json:gsub("“", '"')
  json = json:gsub("”", '"')

  json = json:gsub('\\""', '"')
  json = json:gsub('"\\"', '"')
  json = json:gsub('""', '"')
  json = json:gsub("''", "'")
  json = json:gsub(':%s*"%s*,', ':"",')
  json = json:gsub(":%s*'%s*,", ":'',")
  return json
end

return util
