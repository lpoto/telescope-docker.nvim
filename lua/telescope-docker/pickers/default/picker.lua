local util = require "telescope-docker.util"
local finder = require "telescope-docker.pickers.default.finder"
local mappings = require "telescope-docker.pickers.default.mappings"
local DockerPicker = require "telescope-docker.core.docker_picker"

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

---@param all_pickers DockerPicker[]
return function(all_pickers)
  pickers_tbl = {}
  for _, p in pairs(all_pickers) do
    table.insert(pickers_tbl, p)
  end
  table.sort(pickers_tbl, function(a, b)
    local a_1 = string.sub(a.name, 1, 1)
    local b_1 = string.sub(b.name, 1, 1)
    if a_1 == b_1 then
      return a.name > b.name
    end
    return a_1 < b_1
  end)
  return DockerPicker:new {
    picker_fn = default_picker,
    name = "default",
    description = "Available docker pickers",
  }
end
