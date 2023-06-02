local finders = require "telescope.finders"
local entry_display = require "telescope.pickers.entry_display"

local get_volume_display

---Create a telescope finder for the currently available volumes.
---
---@param volumes_tbl Volume[]
---@return table?: a telescope finder
local function volumes_finder(volumes_tbl)
  return finders.new_table {
    results = volumes_tbl,
    entry_maker = function(entry)
      return {
        value = entry,
        ordinal = entry.Name,
        display = function(entry2)
          return get_volume_display(entry2.value)
        end,
      }
    end,
  }
end

---@param volume Volume
get_volume_display = function(volume)
  local displayer = entry_display.create {
    separator = " ",
    items = { {} },
  }
  return displayer {
    volume.Name,
  }
end

return volumes_finder
