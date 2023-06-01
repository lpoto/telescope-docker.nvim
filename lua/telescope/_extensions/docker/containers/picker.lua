local util = require "telescope._extensions.docker.util"
local finder = require "telescope._extensions.docker.containers.finder"
local previewer = require "telescope._extensions.docker.containers.previewer"
local mappings = require "telescope._extensions.docker.containers.mappings"
local State = require "telescope._extensions.docker.util.docker_state"

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
  local _, err = docker_state:binary()
  if err ~= nil then
    util.error(err)
    return
  end

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

return function(opts)
  available_containers_telescope_picker(opts)
end
