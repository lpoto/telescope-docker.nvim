local telescope_utils = require "telescope-docker.core.telescope_util"

local actions = {}

function actions.select_picker(prompt_bufnr)
  telescope_utils.new_action(
    prompt_bufnr,

    ---@param docker_picker DockerPicker
    ---@param picker table
    function(docker_picker, picker)
      docker_picker:run(picker.init_options or {})
    end,
    false
  )
end

return actions
