local util = require "telescope-docker.util"
local finder = require "telescope-docker.machines.finder"
local previewer = require "telescope-docker.machines.previewer"
local mappings = require "telescope-docker.machines.mappings"
local State = require "telescope-docker.util.docker_state"

local pickers = require "telescope.pickers"
local conf = require("telescope.config").values

local available_machines_telescope_picker = function(options)
  util.info "Fetching machines ..."

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
  local _, err = docker_state:machine_binary()
  if err ~= nil then
    util.error(err)
    return
  end

  docker_state:fetch_machines(function(machines_tbl)
    machines_tbl = machines_tbl or {}
    if not next(machines_tbl) then
      util.warn "No machines were found"
      return
    end
    local ok, machines_finder = pcall(finder.machines_finder, machines_tbl)
    if not ok then
      util.error(machines_finder)
    end
    if not machines_finder then
      return
    end

    local picker = pickers.new(options, {
      prompt_title = "Machines",
      finder = machines_finder,
      sorter = conf.generic_sorter(options),
      previewer = previewer.machine_previewer(),
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
  available_machines_telescope_picker(opts)
end
