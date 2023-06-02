local util = require "telescope-docker.util"
local telescope_utils = require "telescope-docker.core.telescope_util"
local DockerPicker = require "telescope-docker.core.docker_picker"

local pickers = require "telescope.pickers"
local conf = require("telescope.config").values

---@class ItemsPickerOptions
---@field name string
---@field description string
---@field item_name string
---@field finder_fn function
---@field docker_state State
---@field mappings_tbl table
---@field priority number?
---@field condition function?

---@param o ItemsPickerOptions
local available_items_telescope_picker = function(o)
  o = o or {}
  local name = o.name
  local description = o.description
  local item_name = o.item_name
  local finder_fn = o.finder_fn
  local State = o.docker_state
  local mappings_tbl = o.mappings_tbl
  local priority = o.priority
  local condition = o.condition

  local picker_fn = function(options)
    util.info("Fetching " .. item_name .. "s ...")

    if type(options) ~= "table" then
      options = {}
    end
    if options.env ~= nil and type(options.env) ~= "table" then
      util.warn "env must be a table"
      return
    end
    if options.host ~= nil and type(options.host) ~= "string" then
      util.warn "host must be a string"
      return
    end
    if options.host then
      options.env.DOCKER_HOST = options.host
    end

    local docker_state = State:new(options.env)

    docker_state:fetch_items(function(items_tbl)
      items_tbl = items_tbl or {}
      if not next(items_tbl) then
        util.warn("No " .. item_name .. "s were found")
        return
      end
      local ok, items_finder = pcall(finder_fn, items_tbl)
      if not ok then
        util.error(items_finder)
      end
      if not items_finder then
        return
      end

      local picker = pickers.new(options, {
        prompt_title = item_name .. "s",
        finder = items_finder,
        sorter = conf.generic_sorter(options),
        previewer = telescope_utils.item_previewer(item_name .. " info"),
        dynamic_preview_title = true,
        selection_strategy = "row",
        scroll_strategy = "cycle",
        attach_mappings = telescope_utils.get_attach_mappings_fn(mappings_tbl),
      })

      picker.docker_state = docker_state

      picker:find()
    end)
  end

  return DockerPicker:new {
    picker_fn = picker_fn,
    name = name,
    description = description,
    priority = priority,
    condition = condition or function()
      local _, err, warn = State:binary()
      return err, warn
    end,
  }
end

return available_items_telescope_picker
