local util = require "telescope-docker.util"
local finder = require "telescope-docker.pickers.networks.finder"
local previewer = require "telescope-docker.pickers.networks.previewer"
local mappings = require "telescope-docker.pickers.networks.mappings"
local State = require "telescope-docker.pickers.networks.docker_state"
local DockerPicker = require "telescope-docker.core.docker_picker"

local pickers = require "telescope.pickers"
local conf = require("telescope.config").values

local available_networks_telescope_picker = function(options)
  util.info "Fetching networks ..."

  if options.env ~= nil and type(options.env) ~= "table" then
    util.warn "env must be a table"
    return
  end

  options = options or {}
  local env = options.env or {}
  if options.host then
    env.DOCKER_HOST = options.host
  end
  local docker_state = State:new(options.env)

  docker_state:fetch_items(function(networks_tbl)
    networks_tbl = networks_tbl or {}
    if not next(networks_tbl) then
      util.warn "No networks were found"
      return
    end
    local ok, networks_finder = pcall(finder.networks_finder, networks_tbl)
    if not ok then
      util.error(networks_finder)
    end
    if not networks_finder then
      return
    end

    local picker = pickers.new(options, {
      prompt_title = "Networks",
      finder = networks_finder,
      sorter = conf.generic_sorter(options),
      previewer = previewer.network_previewer(),
      dynamic_preview_title = true,
      selection_strategy = "row",
      scroll_strategy = "cycle",
      attach_mappings = mappings.attach_mappings,
    })

    picker.docker_state = docker_state

    picker:find()
  end)
end

return DockerPicker:new {
  name = "networks",
  description = "Existing docker networks",
  picker_fn = available_networks_telescope_picker,
  condition = function()
    local _, err = State:binary()
    return err
  end,
}
