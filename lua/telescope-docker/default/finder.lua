local finders = require "telescope.finders"
local entry_display = require "telescope.pickers.entry_display"

local finder = {}

local get_picker_display
local max_w = 10
local max_desc_w = 10

---Create a telescope finder for the currently available pickers.
---
---@param pickers_tbl DockerPicker[]
---@return table
function finder.pickers_finder(pickers_tbl)
  for _, p in pairs(pickers_tbl) do
    if #p.name + 3 > max_w then
      max_w = #p.name + 3
    end
    if p.description ~= nil and #p.description + 5 > max_desc_w then
      max_desc_w = #p.description + 5
    end
  end
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

---@param picker DockerPicker
get_picker_display = function(picker)
  local items = {
    { width = max_w },
    { width = max_desc_w },
  }
  local displays = {
    picker.name,
    { picker.description, "Comment" },
  }
  if type(picker.condition) == "function" then
    local err, warn = picker.condition()
    if err ~= nil then
      table.insert(items, {})
      table.insert(displays, { err, "Error" })
    elseif warn ~= nil then
      table.insert(items, {})
      table.insert(displays, { warn, "Warning" })
    end
  end
  local displayer = entry_display.create {
    separator = " ",
    items = items,
  }
  return displayer(displays)
end

return finder
