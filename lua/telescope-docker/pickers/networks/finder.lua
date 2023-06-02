local finders = require "telescope.finders"
local entry_display = require "telescope.pickers.entry_display"

local get_network_display
local max_name = 10

---Create a telescope finder for the currently available networks.
---
---@param networks_tbl Network[]
---@return table?: a telescope finder
local function networks_finder(networks_tbl)
  for _, network in ipairs(networks_tbl or {}) do
    if #network.Name + 3 > max_name then
      max_name = #network.Name + 3
    end
  end
  return finders.new_table {
    results = networks_tbl,
    entry_maker = function(entry)
      return {
        value = entry,
        ordinal = entry.Name .. " " .. entry.ID,
        display = function(entry2)
          return get_network_display(entry2.value)
        end,
      }
    end,
  }
end

---@param network Network
get_network_display = function(network)
  local displayer = entry_display.create {
    separator = " ",
    items = {
      { width = max_name },
      { remaining = true },
    },
  }
  return displayer {
    { network.Name },
    { network.ID, "Comment" },
  }
end

return networks_finder
