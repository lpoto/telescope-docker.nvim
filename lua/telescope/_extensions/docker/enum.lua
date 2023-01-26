local enum = {}

enum.TITLE = "Telescope Containers"
enum.CONTAINERS_AUGROUP = "TelescopeContainers"

enum.TELESCOPE_PROMPT_FILETYPE = "TelescopePrompt"

enum.CONTAINERS = {
  ATTACH = "attach",
  EXEC = "exec",
  START = "start",
  STOP = "stop",
  KILL = "kill",
  DELETE = "delete",
  PAUSE = "pause",
  UNPAUSE = "unpause",
  LOGS = "logs",
  STATS = "stats",
  RENAME = "rename",
}

enum.IMAGES = {
  DELETE = "delete",
  HISTORY = "history",
}

return enum
