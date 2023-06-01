local enum = {}

enum.TITLE = "Telescope Docker"
enum.CONTAINERS_AUGROUP = "TelescopeDocker"

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
  RETAG = "retag",
  PUSH = "push",
}

enum.MACHINES = {
  INSPECT = "inspect",
  KILL = "kill",
  REGENERATE_CERTS = "regenerate certs",
  SSH = "ssh",
  START = "start",
  RESTART = "restart",
  REMOVE = "remove",
  STOP = "stop",
  UPGRADE = "upgrade",
}

enum.DOCKERFILES = {
  BUILD = "build",
  CD_AND_BUILD = "cd & build",
}

return enum