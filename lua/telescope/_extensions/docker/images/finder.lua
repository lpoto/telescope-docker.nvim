local images = require "telescope._extensions.docker.images"
local finders = require "telescope.finders"
local entry_display = require "telescope.pickers.entry_display"

local finder = {}

local get_image_display

---Create a telescope finder for the currently available images.
---
---@return table?: a telescope finder
function finder.images_finder(images_tbl)
  if not images_tbl then
    images_tbl = images.get_images() or {}
  end

  return finders.new_table {
    results = images_tbl,
    entry_maker = function(entry)
      return {
        value = entry,
        ordinal = entry:name(),
        display = function(entry2)
          return get_image_display(entry2.value)
        end,
      }
    end,
  }
end

---@param image Image
get_image_display = function(image)
  local displayer = entry_display.create {
    separator = " ",
    items = { {} },
  }
  return displayer {
    image:name(),
  }
end

return finder
