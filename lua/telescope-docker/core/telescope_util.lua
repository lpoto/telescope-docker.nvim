local action_state = require "telescope.actions.state"
local telescope_actions = require "telescope.actions"
local util = require "telescope-docker.util"
local previewers = require "telescope.previewers"

local telescope_utils = {}

---@param prompt_bufnr number
---@return table?
function telescope_utils.get_picker(prompt_bufnr)
  if prompt_bufnr == nil or not vim.api.nvim_buf_is_valid(prompt_bufnr) then
    prompt_bufnr = vim.api.nvim_get_current_buf()
  end
  return action_state.get_current_picker(prompt_bufnr)
end

---@param prompt_bufnr number: The telescope prompt's buffer number
---@param callback fun(item: Container|Node|Image|{name: string, picker: function}, picker: table)
---@param check_docker_state boolean?: Whether to check the picker's docker state
function telescope_utils.new_action(prompt_bufnr, callback, check_docker_state)
  local selection = action_state.get_selected_entry()
  local picker = telescope_utils.get_picker(prompt_bufnr)
  if
    not picker
    or (check_docker_state ~= false and not picker.docker_state)
    or not selection
    or not selection.value
  then
    return
  end
  ---@type Container
  local container = selection.value
  return callback(container, picker)
end

function telescope_utils.get_attach_mappings_fn(keys)
  return function(prompt_bufnr, map)
    for key, f in pairs(keys or {}) do
      if key == "<CR>" then
        telescope_actions.select_default:replace(function()
          f(prompt_bufnr)
        end)
      else
        local modes = { "n" }
        if key:sub(1, 1) == "<" then
          table.insert(modes, "i")
        end
        for _, mode in ipairs(modes) do
          map(mode, key, function()
            f(prompt_bufnr)
          end)
        end
      end
    end
    return true
  end
end

---@param prompt_bufnr number: The telescope prompt's buffer number
function telescope_utils.close_picker(prompt_bufnr)
  vim.schedule(function()
    if prompt_bufnr == nil or not vim.api.nvim_buf_is_valid(prompt_bufnr) then
      prompt_bufnr = vim.api.nvim_get_current_buf()
    end
    pcall(telescope_actions.close, prompt_bufnr)
  end)
end

---Asynchronously refresh the picker.
---
---@param prompt_bufnr number: The telescope prompt's buffer number
function telescope_utils.refresh_picker(prompt_bufnr, finder_fn)
  local picker = telescope_utils.get_picker(prompt_bufnr)
  if not picker or not picker.docker_state then
    return
  end
  picker.docker_state:fetch_items(function(results_tl)
    if prompt_bufnr == nil or not vim.api.nvim_buf_is_valid(prompt_bufnr) then
      prompt_bufnr = vim.api.nvim_get_current_buf()
    end
    local p = action_state.get_current_picker(prompt_bufnr)
    if p == nil then
      return
    end
    if not results_tl or not next(results_tl) then
      util.warn "No results were found"
      pcall(telescope_actions.close, prompt_bufnr)
      return
    end
    local ok, finder = pcall(finder_fn, results_tl)
    if not ok then
      util.error(finder)
    end
    if not finder then
      return
    end
    local e
    ok, e = pcall(p.refresh, p, finder)
    if not ok and type(e) == "string" then
      util.error(e)
    end
  end)
end

--- A previewer for Item.
function telescope_utils.item_previewer(title)
  return previewers.new {
    title = title,
    preview_fn = function(self, entry, status)
      entry.value:display(status)
      self.status = status
      self.state = self.state or {}
      self.state.winid = status.preview_win
      self.state.bufnr = vim.api.nvim_win_get_buf(status.preview_win)
    end,
  }
end

return telescope_utils
