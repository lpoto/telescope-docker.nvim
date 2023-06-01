local util = require "telescope-docker.util"
local finder = require "telescope-docker.default.finder"
local mappings = require "telescope-docker.default.mappings"

local pickers = require "telescope.pickers"
local conf = require("telescope.config").values

local pickers_tbl = {}

local function default_picker(options)
  if type(pickers_tbl) ~= "table" or not next(pickers_tbl) then
    util.warn "No pickers are available"
    return
  end
  local ok, picker_finder = pcall(finder.pickers_finder, pickers_tbl)
  if not ok then
    util.error(picker_finder)
  end
  if not picker_finder then
    return
  end

  local picker = pickers.new(options, {
    prompt_title = "Docker",
    finder = picker_finder,
    sorter = conf.generic_sorter(options),
    previewer = nil,
    selection_strategy = "row",
    scroll_strategy = "cycle",
    attach_mappings = mappings.attach_mappings,
  })
  picker.init_options = options

  picker:find()
end

return function(all_pickers)
  pickers_tbl = {}
  for k, v in pairs(all_pickers) do
    table.insert(pickers_tbl, {
      name = k,
      picker = v,
    })
  end
  table.sort(pickers_tbl, function(a, b)
    return string.sub(a.name, 1, 1) < string.sub(b.name, 1, 1)
  end)
  return default_picker
end
