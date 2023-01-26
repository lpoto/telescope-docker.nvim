local util = require "telescope._extensions.docker.util"
local setup = require "telescope._extensions.docker.setup"
local containers_picker =
  require "telescope._extensions.docker.containers.picker"
local images_picker = require "telescope._extensions.docker.images.picker"
local compose_picker = require "telescope._extensions.docker.compose.picker"

-- NOTE: ensure the telescope is loaded
-- before registering the extension
local has_telescope, telescope = pcall(require, "telescope")
if not has_telescope then
  util.warn(
    "This extension requires telescope.nvim "
      .. "(https://github.com/nvim-telescope/telescope.nvim)"
  )
end

---Opens the containers picker and merges the provided opts
---with the default options provided during the setup.
---@param opts table|nil
local function containers(opts)
  setup.call_with_opts(containers_picker, opts or {})
end

---Opens the images picker and merges the provided opts
---with the default options provided during the setup.
---@param opts table|nil
local function images(opts)
  setup.call_with_opts(images_picker, opts or {})
end

---Opens the docker-compose picker and merges the provided opts
---with the default options provided during the setup.
---@param opts table|nil
local function compose(opts)
  setup.call_with_opts(compose_picker, opts or {})
end

return telescope.register_extension {
  setup = setup.setup,
  exports = {
    docker = containers,
    containers = containers,
    images = images,
    compose = compose,
  },
}
