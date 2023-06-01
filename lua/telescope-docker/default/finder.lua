local finders = require "telescope.finders"
local entry_display = require "telescope.pickers.entry_display"

local finder = {}

local get_picker_display

---Create a telescope finder for the currently available pickers.
---
---@param pickers_tbl {name: string, picker: function}[]
---@return table
function finder.pickers_finder(pickers_tbl)
  return finders.new_table {
    results = pickers_tbl,
    entry_maker = function(entry)
      return {
        value = entry,
        ordinal = entry.name,
        display = function(entry2)
          return get_picker_display(entry2.value)
        end,
      }
    end,
  }
end

---@param picker Image
get_picker_display = function(picker)
  local displayer = entry_display.create {
    separator = " ",
    items = { {} },
  }
  return displayer {
    picker.name,
  }
end

return finder
