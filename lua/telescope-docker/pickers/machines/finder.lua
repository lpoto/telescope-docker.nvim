local finders = require "telescope.finders"
local entry_display = require "telescope.pickers.entry_display"

local get_machine_display
local max_name_w = 10

---Create a telescope finder for the currently available machines.
---
---@param machines_tbl Machine[]
---@return table?: a telescope finder
local function machines_finder(machines_tbl)
  for _, machine in ipairs(machines_tbl or {}) do
    local name_w = #machine.Name
    if name_w + 3 > max_name_w then
      max_name_w = name_w + 3
    end
  end

  return finders.new_table {
    results = machines_tbl,
    entry_maker = function(entry)
      return {
        value = entry,
        ordinal = entry.State .. " " .. entry.Name,
        display = function(entry2)
          return get_machine_display(entry2.value)
        end,
      }
    end,
  }
end

---@param machine Machine
get_machine_display = function(machine)
  local items = {
    { width = 8 },
    { width = max_name_w },
  }
  local hl = "Function"
  if machine.State == "Stopped" then
    hl = "Comment"
  elseif machine.State == "Error" then
    hl = "Error"
  end
  local displays = {
    { machine.State, hl },
    machine.Name,
  }
  if machine.Error ~= "" then
    table.insert(items, {})
    table.insert(displays, {
      machine.Error,
      "Error",
    })
  end
  local displayer = entry_display.create {
    separator = " ",
    items = items,
  }
  return displayer(displays)
end

return machines_finder
