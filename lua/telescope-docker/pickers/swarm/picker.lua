local util = require "telescope-docker.util"
local finder = require "telescope-docker.pickers.swarm.finder"
local previewer = require "telescope-docker.pickers.swarm.previewer"
local mappings = require "telescope-docker.pickers.swarm.mappings"
local State = require "telescope-docker.pickers.swarm.docker_state"
local DockerPicker = require "telescope-docker.core.docker_picker"

local pickers = require "telescope.pickers"
local conf = require("telescope.config").values

local available_nodes_telescope_picker = function(options)
  util.info "Fetching nodes ..."

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

  docker_state:fetch_items(function(swarm_tbl)
    swarm_tbl = swarm_tbl or {}
    if not next(swarm_tbl) then
      util.warn "No nodes were found"
      return
    end
    local ok, swarm_finder = pcall(finder.nodes_finder, swarm_tbl)
    if not ok then
      util.error(swarm_finder)
    end
    if not swarm_finder then
      return
    end

    local picker = pickers.new(options, {
      prompt_title = "Nodes",
      finder = swarm_finder,
      sorter = conf.generic_sorter(options),
      previewer = previewer.node_previewer(),
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
  picker_fn = available_nodes_telescope_picker,
  name = "nodes",
  description = "Docker nodes in the current swarm",
  condition = function()
    local _, err = State:binary()
    return err
  end,
}
