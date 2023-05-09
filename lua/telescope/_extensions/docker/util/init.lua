local enum = require "telescope._extensions.docker.enum"
local telescope_actions = require "telescope.actions"

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

---@param command string|table
---@param init_term string|function|nil
---@param opts table|nil
function util.open_in_shell(command, init_term, opts)
  if
    vim.api.nvim_buf_get_option(0, "filetype")
    == enum.TELESCOPE_PROMPT_FILETYPE
  then
    -- NOTE: close telescope popup if open
    local bufnr = vim.api.nvim_get_current_buf()
    pcall(telescope_actions.close, bufnr)
  end

  opts = opts or {}
  if opts.detatch == nil then
    opts.detach = false
  end

  local init_term_f
  if type(init_term) ~= "function" then
    if
      type(init_term) ~= "string"
      or (not init_term:match "tab" and not init_term:match "split")
    then
      init_term = "tabnew"
    end
    init_term_f = function(cmd)
      vim.api.nvim_exec("noautocmd keepjumps " .. init_term, false)
      local buf = vim.api.nvim_get_current_buf()
      pcall(vim.api.nvim_buf_set_option, buf, "buftype", "nofile")
      pcall(vim.api.nvim_buf_set_option, buf, "bufhidden", "wipe")
      local job_id = vim.fn.termopen(cmd, opts)
      vim.api.nvim_create_autocmd({ "BufUnload", "BufHidden" }, {
        buffer = buf,
        once = true,
        callback = function()
          vim.schedule(function()
            pcall(vim.fn.jobstop, job_id)
            vim.defer_fn(function()
              pcall(vim.api.nvim_buf_delete, buf, { force = true })
            end, 10)
          end)
        end,
      })
    end
  else
    init_term_f = init_term
  end
  init_term_f(command)
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
