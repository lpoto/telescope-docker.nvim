local util = require "telescope-docker.util"
local setup = require "telescope-docker.setup"
local pickers = {
  containers = require "telescope-docker.containers.picker",
  images = require "telescope-docker.images.picker",
  swarm = require "telescope-docker.swarm.picker",
  machines = require "telescope-docker.machines.picker",
  compose = require "telescope-docker.compose.picker",
  files = require "telescope-docker.files.picker",
}
pickers.docker = require "telescope-docker.default.picker"(pickers)

-- NOTE: ensure the telescope is loaded
-- before registering the extension
local has_telescope, telescope = pcall(require, "telescope")
if not has_telescope then
  util.warn(
    "This extension requires telescope.nvim "
      .. "(https://github.com/nvim-telescope/telescope.nvim)"
  )
end

return telescope.register_extension {
  setup = setup.setup,
  exports = vim.tbl_map(function(fn)
    return function(opts)
      return setup.call_with_opts(fn, opts or {})
    end
  end, pickers),
}
