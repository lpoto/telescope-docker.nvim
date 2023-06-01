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

  local state = State:new()
  local ok, err = state:binary(function(binary, version)
    vim.health.ok("Executable docker binary: " .. vim.inspect(binary))
    vim.health.ok("Docker version: " .. vim.inspect(version))
    return true
  end)
  if not ok and type(err) == "string" then
    vim.health.error(err, {
      "Change the docker binary",
    })
  end

  ok, err, warn = state:compose_binary(function(binary, version)
    vim.health.ok("Executable compose binary: " .. vim.inspect(binary))
    vim.health.ok("Compose version: " .. vim.inspect(version))
    return true
  end)
  if not ok and type(err) == "string" then
    vim.health.error(err, {
      "Change the compose binary",
    })
  end
  if type(warn) == "string" then
    vim.health.warn(warn)
  end
end

return health
