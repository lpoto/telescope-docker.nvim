local util = require "telescope-docker.util"
local setup = require "telescope-docker.setup"
local containers_picker = require "telescope-docker.containers.picker"
local images_picker = require "telescope-docker.images.picker"
local compose_picker = require "telescope-docker.compose.picker"
local dockerfiles_picker = require "telescope-docker.files.picker"

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

---Opens the dockerfiles picker and merges the provided opts
---with the default options provided during the setup.
---@param opts table|nil
local function files(opts)
  setup.call_with_opts(dockerfiles_picker, opts or {})
end

return telescope.register_extension {
  setup = setup.setup,
  exports = {
    containers = containers,
    images = images,
    compose = compose,
    files = files,
  },
}
