local util = require "telescope._extensions.docker.util"
local setup = require "telescope._extensions.docker.setup"
local Image = require "telescope._extensions.docker.images.image"

local M = {}

---@param image Image
---@param callback function?
function M.delete(image, callback)
  util.info("Deleting image: " .. image.ID)
  local cmd =
    { setup.get_option "binary" or "docker", "image", "rm", image.ID }
  local error = {}
  vim.fn.jobstart(cmd, {
    detach = false,
    on_stderr = function(_, data)
      for _, d in ipairs(data) do
        if d:len() > 0 then
          table.insert(error, d)
        end
      end
    end,
    on_exit = function(_, code)
      if code ~= 0 then
        if #error > 0 then
          util.warn(table.concat(error, "\n"))
        else
          util.warn("Removing image exited with code: " .. vim.inspect(code))
        end
        return
      end
      util.info "Image removed"
      if type(callback) == "function" then
        callback(image)
      end
    end,
  })
end

---@param image Image
function M.history(image)
  util.info("Fetching image's hitory: " .. image.ID)
  local init_term = setup.get_option "init_term"

  local binary = setup.get_option "binary" or "docker"

  local ok, e = pcall(
    util.open_in_shell,
    binary .. " image history " .. image.ID,
    init_term
  )
  if not ok then
    util.warn(e)
    return
  end
end

---@param callback function?
---@return Image[]
function M.get_images(callback)
  local cmd = {
    setup.get_option "binary" or "docker",
    "image",
    "ls",
    "-a",
    "--format='{{json . }}'",
  }

  local images = {}

  local job_id = vim.fn.jobstart(cmd, {
    detach = false,
    on_stdout = function(_, data)
      local ok, err = pcall(function()
        for _, json in ipairs(data) do
          if json:len() > 0 then
            json = string.sub(json, 2, #json - 1)
            local image = Image:new(json)
            table.insert(images, image)
          end
        end
      end)
      if not ok then
        util.warn("Error when decoding image: ", err)
      end
    end,
    on_exit = function()
      if callback then
        callback(images)
      end
    end,
  })
  if not callback then
    vim.fn.jobwait({ job_id }, 2000)
  end
  return images
end

return M
