local finders = require "telescope.finders"
local entry_display = require "telescope.pickers.entry_display"

local get_container_display
local max_name_width = 10

---Create a telescope finder for the currently available containers.
---
---@param containers_tbl Container[]
---@return table?: a telescope finder
local function containers_finder(containers_tbl)
  for _, container in ipairs(containers_tbl or {}) do
    local name = container.Names
    if #name + 3 > max_name_width then
      max_name_width = #name + 3
    end
  end

  return finders.new_table {
    results = containers_tbl,
    entry_maker = function(entry)
      return {
        value = entry,
        ordinal = entry.State .. " " .. entry.Names .. " " .. entry.ID,
        display = function(entry2)
          return get_container_display(entry2.value)
        end,
      }
    end,
  }
end

---@param container Container
get_container_display = function(container)
  local displayer = entry_display.create {
    separator = " ",
    items = {
      { width = 8 },
      { width = max_name_width },
      { remaining = true },
    },
  }
  local hl = "Comment"
  if container.State == "running" then
    hl = "Function"
  elseif container.State == "paused" then
    hl = "String"
  end
  return displayer {
    { container.State, hl },
    container.Names,
    { container.ID, "Comment" },
  }
end

return containers_finder
