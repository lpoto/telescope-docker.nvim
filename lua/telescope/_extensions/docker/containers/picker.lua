local util = require "telescope._extensions.docker.util"
local containers = require "telescope._extensions.docker.containers"
local finder = require "telescope._extensions.docker.containers.finder"
local previewer = require "telescope._extensions.docker.containers.previewer"
local mappings = require "telescope._extensions.docker.containers.mappings"

local pickers = require "telescope.pickers"
local conf = require("telescope.config").values

local available_containers_telescope_picker = function(options)
  util.info "Fetching containers ..."
  containers.get_containers(function(containers_tbl)
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

    local function containers_picker(opts)
      opts = opts or {}
      local picker = pickers.new(opts, {
        prompt_title = "Containers",
        --results_title = " Tasks",
        finder = containers_finder,
        sorter = conf.generic_sorter(opts),
        previewer = previewer.container_previewer(),
        dynamic_preview_title = true,
        selection_strategy = "row",
        scroll_strategy = "cycle",
        attach_mappings = mappings.attach_mappings,
      })
      picker:find()
    end

    containers_picker(options)
  end)
end

return function(opts)
  available_containers_telescope_picker(opts)
end
