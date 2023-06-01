local setup = require "telescope-docker.setup"
local telescope_utils = require "telescope-docker.util.telescope"

local actions = {}

function actions.select_picker(prompt_bufnr)
  telescope_utils.new_action(
    prompt_bufnr,

    ---@param picker_f {name: string, picker: function}
    ---@param picker table
    function(picker_f, picker)
      setup.call_with_opts(picker_f.picker, picker.init_options or {})
    end,
    false
  )
end

return actions
