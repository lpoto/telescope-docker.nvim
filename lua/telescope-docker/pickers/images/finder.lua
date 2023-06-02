local finders = require "telescope.finders"
local entry_display = require "telescope.pickers.entry_display"

local get_image_display

---Create a telescope finder for the currently available images.
---
---@param images_tbl Image[]
---@return table
local function images_finder(images_tbl)
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

return images_finder
