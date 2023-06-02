local finders = require "telescope.finders"
local entry_display = require "telescope.pickers.entry_display"

local get_image_display
local max_name_width = 10

---Create a telescope finder for the currently available images.
---
---@param images_tbl Image[]
---@return table
local function images_finder(images_tbl)
  for _, image in ipairs(images_tbl or {}) do
    local name = image:name()
    if #name + 3 > max_name_width then
      max_name_width = #name + 3
    end
  end
  return finders.new_table {
    results = images_tbl,
    entry_maker = function(entry)
      return {
        value = entry,
        ordinal = entry:name() .. " " .. entry.ID,
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
    items = { { width = max_name_width }, {} },
  }
  return displayer {
    image:name(),
    { image.ID, "Comment" },
  }
end

return images_finder
