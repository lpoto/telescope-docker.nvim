local finders = require "telescope.finders"
local entry_display = require "telescope.pickers.entry_display"

local get_node_display

---Create a telescope finder for the currently available nodes.
---
---@param nodes_tbl Node[]
---@return table
local function nodes_finder(nodes_tbl)
  return finders.new_table {
    results = nodes_tbl,
    entry_maker = function(entry)
      return {
        value = entry,
        ordinal = entry.Hostname .. " " .. entry.ID,
        display = function(entry2)
          return get_node_display(entry2.value)
        end,
      }
    end,
  }
end

---@param node Node
get_node_display = function(node)
  local displayer = entry_display.create {
    separator = " ",
    items = { {}, {}, { remaining = true } },
  }

  local hl = "Comment"
  if node.Status == "Ready" then
    hl = "Function"
  end

  return displayer {
    { node.Status, hl },
    { node.Hostname },
    { node.ID, "Comment" },
  }
end

return nodes_finder
