local util = require "telescope._extensions.docker.util"
local finder = require "telescope._extensions.docker.images.finder"
local previewer = require "telescope._extensions.docker.images.previewer"
local mappings = require "telescope._extensions.docker.images.mappings"
local State = require "telescope._extensions.docker.util.docker_state"

local pickers = require "telescope.pickers"
local conf = require("telescope.config").values

local available_images_telescope_picker = function(options)
  util.info "Fetching images ..."

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

  docker_state:fetch_images(function(images_tbl)
    images_tbl = images_tbl or {}
    if not next(images_tbl) then
      util.warn "No images were found"
      return
    end
    local ok, images_finder = pcall(finder.images_finder, images_tbl)
    if not ok then
      util.error(images_finder)
    end
    if not images_finder then
      return
    end

    local picker = pickers.new(options, {
      prompt_title = "Images",
      finder = images_finder,
      sorter = conf.generic_sorter(options),
      previewer = previewer.image_previewer(),
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
  available_images_telescope_picker(opts)
end
