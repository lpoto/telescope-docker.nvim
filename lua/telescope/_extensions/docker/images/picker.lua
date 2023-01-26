local util = require "telescope._extensions.docker.util"
local images = require "telescope._extensions.docker.images"
local finder = require "telescope._extensions.docker.images.finder"
local previewer = require "telescope._extensions.docker.images.previewer"
local mappings = require "telescope._extensions.docker.images.mappings"

local pickers = require "telescope.pickers"
local conf = require("telescope.config").values

local available_images_telescope_picker = function(options)
  util.info "Fetching images ..."
  images.get_images(function(images_tbl)
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

    local function images_picker(opts)
      opts = opts or {}
      local picker = pickers.new(opts, {
        prompt_title = "Images",
        --results_title = " Tasks",
        finder = images_finder,
        sorter = conf.generic_sorter(opts),
        previewer = previewer.image_previewer(),
        dynamic_preview_title = true,
        selection_strategy = "row",
        scroll_strategy = "cycle",
        attach_mappings = mappings.attach_mappings,
      })
      picker:find()
    end

    images_picker(options)
  end)
end

return function(opts)
  available_images_telescope_picker(opts)
end
