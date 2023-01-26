local mappings = require "telescope._extensions.docker.compose.mappings"
local builtin = require "telescope.builtin"

local docker_compose_picker = function(options)
  -- TODO: update this command
  local find_command = {
    "rg",
    "--files-with-matches",
    "services:",
    "-g",
    "*.yaml",
    "-g",
    "*.yml",
  }
  options.find_command = find_command
  options.attach_mappings = mappings.attach_mappings

  builtin.find_files(options)
end

return function(opts)
  docker_compose_picker(opts)
end
