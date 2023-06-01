local action_state = require "telescope.actions.state"
local telescope_actions = require "telescope.actions"
local Path = require "plenary.path"

local actions = {}

---Edit the selected dockerfile
---
---@param prompt_bufnr number: The telescope prompt's buffer number
function actions.edit_dockerfile(prompt_bufnr)
  telescope_actions.file_edit(prompt_bufnr)
end

---Build the selected dockerfile, ask for input so a tag may
---be provided.
---
---Set the working directory of the
---docker command, to the directory inputed by the user.
---(default is the directory of the dockerfile)
---
---Set tag from the user input.
---
---@param prompt_bufnr number: The telescope prompt's buffer number
function actions.build_from_input(prompt_bufnr, ask_for_input)
  actions.__build(prompt_bufnr, ask_for_input, true, true)
end

function actions.__build(prompt_bufnr, ask_for_input, cd, tag)
  local selection = action_state.get_selected_entry()
  local picker = action_state.get_current_picker(prompt_bufnr)
  if
    not picker
    or not picker.docker_state
    or not selection
    or not selection.value
  then
    return
  end
  local dockerfile = Path.new(selection.cwd, selection.value):__tostring()
  local cwd = nil
  if cd then
    cwd = vim.fn.input {
      prompt = "Working directory: ",
      default = vim.fs.dirname(dockerfile),
      cancelreturn = nil,
    }
  end
  local args = { "build", "-f", dockerfile }
  if tag then
    local tag_input = vim.fn.input {
      prompt = "Name&tag: ",
      default = "",
      cancelreturn = nil,
    }
    if not tag_input or tag_input:len() == 0 then
      return
    end
    table.insert(args, "-t")
    table.insert(args, tag_input)
  end
  table.insert(args, ".")
  picker.docker_state:docker_command {
    args = args,
    cwd = cwd,
    ask_for_input = ask_for_input,
  }
end

return actions
