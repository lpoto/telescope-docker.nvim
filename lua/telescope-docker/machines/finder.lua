local finders = require "telescope.finders"
local entry_display = require "telescope.pickers.entry_display"

local finder = {}

local get_machine_display

---Create a telescope finder for the currently available machines.
---
---@param machines_tbl Machine[]
---@return table?: a telescope finder
function finder.machines_finder(machines_tbl)
  return finders.new_table {
    results = machines_tbl,
    entry_maker = function(entry)
      return {
        value = entry,
        ordinal = entry.Name,
        display = function(entry2)
          return get_machine_display(entry2.value)
        end,
      }
    end,
  }
end

---@param machine Machine
get_machine_display = function(machine)
  local displayer = entry_display.create {
    separator = " ",
    items = {
      { width = 8 },
      { remaining = true },
    },
  }
  local hl = "Function"
  if machine.State == "Stopped" then
    hl = "Comment"
  elseif machine.State == "Error" then
    hl = "Error"
  end
  return displayer {
    { machine.State, hl },
    machine.Name,
  }
end

return finder
