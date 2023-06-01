local enum = require "telescope-docker.enum"
local util = require "telescope-docker.util"
local popup = require "telescope-docker.util.popup"
local action_state = require "telescope.actions.state"
local finder = require "telescope-docker.images.finder"
local telescope_actions = require "telescope.actions"
local actions = {}

local select_node
---Open a popup through which a docker node action
---may be selected.
---
---@param prompt_bufnr number: The telescope prompt's buffer number
function actions.select_node(prompt_bufnr)
  return select_node(prompt_bufnr, {})
end

---@param prompt_bufnr number
---@param options string[]
function select_node(prompt_bufnr, options)
  popup.open(options, function(choice, ask_for_input) end)
end

return actions
