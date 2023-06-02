local util = require "telescope-docker.util"
local finder = require "telescope-docker.pickers.images.finder"
local previewer = require "telescope-docker.pickers.images.previewer"
local mappings = require "telescope-docker.pickers.images.mappings"
local State = require "telescope-docker.pickers.images.docker_state"
local DockerPicker = require "telescope-docker.core.docker_picker"

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

  docker_state:fetch_items(function(images_tbl)
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

return DockerPicker:new {
  name = "images",
  description = "Existing docker images",
  picker_fn = available_images_telescope_picker,
  condition = function()
    local _, err = State:binary()
    return err
  end,
}
