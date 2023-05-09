local mappings = require "telescope._extensions.docker.compose.mappings"
local builtin = require "telescope.builtin"
local action_state = require "telescope.actions.state"
local State = require "telescope._extensions.docker.util.docker_state"

local get_result_processor
local name = "Docker compose files"

local docker_compose_picker = function(options)
  options = options or {}
  if options.hidden == nil then
    options.hidden = true
  end
  if options.no_ignore == nil then
    options.no_ignore = true
  end
  if options.search_file == nil then
    options.search_file = "{*.yml,*.yaml}"
  end
  if options.file_ignore_patterns == nil then
    options.file_ignore_patterns = {
      ".git/",
      "node_modules/",
      "vendor/",
      "venv/",
      "target/",
      "dist/",
      ".github/workflows/",
    }
  end
  if options.attach_mappings == nil then
    options.attach_mappings = mappings.attach_mappings
  end
  if options.prompt_tile == nil then
    options.prompt_title = "Docker Compose Files"
  end
  options.prompt_title = name
  builtin.find_files(options)

  local picker = action_state.get_current_picker(vim.fn.bufnr())
  if type(picker) == "table" and picker.prompt_title == name then
    picker.docker_state = State:new(options.env)
    picker.get_result_processor = get_result_processor
  end
end

--- This overrides the telescope's default  result processor, so
--- we can filter out the results that are yaml files but not docker-compose files.
--- We ignore entries that do not match patterns that  the docker-compose
--- files should match.
function get_result_processor(picker, find_id, prompt, status_updater)
  local count = 0
  local cb_add = function(score, entry)
    picker.manager:add_entry(picker, score, entry, prompt)
    status_updater { completed = false }
  end
  local cb_filter = function(_)
    picker:_increment "filtered"
  end
  return function(entry)
    if find_id ~= picker._find_id then
      return true
    end
    if not entry or entry.valid == false then
      return
    end
    picker:_increment "processed"
    count = count + 1

    local file = vim.F.if_nil(
      entry.filename,
      type(entry.value) == "string"
        and vim.fn.strchars(entry.value) > 0
        and vim.fn.filereadable(entry.value) == 1
        and entry.value
    ) -- false if none is true
    if not file then
      picker:_decrement "processed"
      return
    end

    for _, v in ipairs(picker.file_ignore_patterns or {}) do
      if string.find(file, v) then
        picker:_decrement "processed"
        return
      end
    end

    local lines = vim.fn.readfile(file)
    local patterns_found = 0
    -- NOTE: docker-compose files should always have a services section
    -- and an image or build section
    -- so we check for those patterns and ignore
    -- entries that do not match
    for _, line in ipairs(lines) do
      if patterns_found >= 2 then
        break
      end
      if patterns_found == 0 and line:match "^%s*services:%s*" then
        patterns_found = 1
      elseif patterns_found > 0 then
        if line:match "^%s*image:" or line:match "^%s*build:" then
          patterns_found = patterns_found + 1
        end
      end
    end
    if patterns_found < 2 then
      picker:_decrement "processed"
      return
    end

    picker.sorter:score(prompt, entry, cb_add, cb_filter)
  end
end

return function(opts)
  docker_compose_picker(opts)
end
