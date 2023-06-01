local enum = require "telescope-docker.enum"
local util = require "telescope-docker.util"
local popup = require "telescope-docker.util.popup"
local action_state = require "telescope.actions.state"
local finder = require "telescope-docker.machines.finder"
local telescope_actions = require "telescope.actions"

local actions = {}
---Open a popup through which a docker machine action
---may be selected.
---
---@param prompt_bufnr number: The telescope prompt's buffer number
function actions.select_machine(prompt_bufnr)
end

return actions
