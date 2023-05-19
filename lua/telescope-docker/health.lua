local setup = require "telescope._extensions.docker.setup"
local State = require "telescope._extensions.docker.util.docker_state"

local health = {}

function health.check()
  vim.health.start "Telescope docker"

  if setup.called() then
    -- NOTE: ensure there were no errors during setup
    local errors = setup.errors()
    if #errors > 0 then
      vim.health.warn("Setup has failed", errors)
    else
      vim.health.ok "Setup has been successfully called"
    end
  end

  -- NOTE: ensure telescope is loaded
  if not package.loaded["telescope"] then
    vim.health.error("Telescope not loaded", {
      "Check if the plugin is installed correctly",
    })
  else
    vim.health.ok "Telescope loaded"
  end

  -- NOTE: ensure docker binary is executable
  local binary = State.get_binary()
  if type(binary) ~= "string" or vim.fn.executable(binary) ~= 1 then
    vim.health.error(
      "Docker binary not executable: " .. vim.inspect(binary),
      { "Set a different binary in the plugin's setup" }
    )
  else
    vim.health.ok("Executable docker binary: " .. vim.inspect(binary))
  end

  -- NOTE: ensure docker binary is valid
  local state, err = State:new()
  if err ~= nil then
    vim.health.error(err, {
      "Check if the binary is a valid docker binary",
    })
  else
    vim.health.ok("Docker version: " .. vim.inspect(state.docker_version))
  end
end

return health
