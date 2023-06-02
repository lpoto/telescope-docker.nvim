local finders = require "telescope.finders"
local entry_display = require "telescope.pickers.entry_display"

local get_context_display
local max_name_w = 10

---Create a telescope finder for the currently available contexts.
---
---@param contexts_tbl Context[]
---@return table?: a telescope finder
local function contexts_finder(contexts_tbl)
  for _, context in ipairs(contexts_tbl or {}) do
    local name_w = #context.Name
    if name_w + 3 > max_name_w then
      max_name_w = name_w + 3
    end
  end

  return finders.new_table {
    results = contexts_tbl,
    entry_maker = function(entry)
      return {
        value = entry,
        ordinal = entry.Name,
        display = function(entry2)
          return get_context_display(entry2.value)
        end,
      }
    end,
  }
end

---@param context Context
get_context_display = function(context)
  local items = {
    { width = max_name_w },
  }
  local displays = {
    context.Name,
  }
  if context.Error ~= "" then
    table.insert(items, {})
    table.insert(displays, {
      context.Error,
      "Error",
    })
  end
  local displayer = entry_display.create {
    separator = " ",
    items = items,
  }
  return displayer(displays)
end

return contexts_finder
