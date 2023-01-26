local containers = require "telescope._extensions.docker.containers"
local finders = require "telescope.finders"
local entry_display = require "telescope.pickers.entry_display"

local finder = {}

local get_container_display

---Create a telescope finder for the currently available containers.
---
---@return table?: a telescope finder
function finder.containers_finder(containers_tbl)
  if not containers_tbl then
    containers_tbl = containers.get_containers() or {}
  end

  return finders.new_table {
    results = containers_tbl,
    entry_maker = function(entry)
      return {
        value = entry,
        ordinal = entry.Names,
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
  }
end

return finder
