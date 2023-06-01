local util = require "telescope-docker.util"
local finder = require "telescope-docker.containers.finder"
local previewer = require "telescope-docker.containers.previewer"
local mappings = require "telescope-docker.containers.mappings"
local State = require "telescope-docker.util.docker_state"
local DockerPicker = require "telescope-docker.util.docker_picker"

local pickers = require "telescope.pickers"
local conf = require("telescope.config").values

local available_containers_telescope_picker = function(options)
  util.info "Fetching containers ..."

  options = options or {}

  if options.env ~= nil and type(options.env) ~= "table" then
    util.warn "env must be a table"
    return
  end
  options.env = options.env or {}
  if options.host ~= nil and type(options.host) ~= "string" then
    util.warn "host must be a string"
    return
  end

  if options.host then
    options.env.DOCKER_HOST = options.host
  end
  local docker_state = State:new(options.env)

  docker_state:fetch_containers(function(containers_tbl)
    containers_tbl = containers_tbl or {}
    if not next(containers_tbl) then
      util.warn "No containers were found"
      return
    end
    local ok, containers_finder =
      pcall(finder.containers_finder, containers_tbl)
    if not ok then
      util.error(containers_finder)
    end
    if not containers_finder then
      return
    end

    local picker = pickers.new(options, {
      prompt_title = "Containers",
      finder = containers_finder,
      sorter = conf.generic_sorter(options),
      previewer = previewer.container_previewer(),
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
  picker_fn = available_containers_telescope_picker,
  name = "containers",
  description = "Existing docker containers",
  condition = function()
    local _, err = State:binary()
    return err
  end,
}
