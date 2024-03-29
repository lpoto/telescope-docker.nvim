# Telescope docker

`telescope-docker.nvim` is a [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) extension,
that allows managing:

- containers,
- images,
- networks,
- volumes,
- contexts,
- machines,
- swarm nodes,
- Dockerfiles and
- docker-compose files

from a telescope prompt.

https://github.com/lpoto/telescope-docker.nvim/assets/67372390/6e8832d9-c2db-41f7-a7b4-3665164a60fa

**_NOTE_** _Docker commands may be selected with either `<CR>` or `<C-a>`, selecting with
`<C-a>` allows adding additional arguments._

## Installation

The extension may be installed manually or with a plugin manager of choice.

An example using [Lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
require("lazy").setup({
  "lpoto/telescope-docker.nvim",
})
```

## Setup and usage

First setup and load the extension:

```lua
require("telescope").setup {
  extensions = {
    -- NOTE: this setup is optional
    docker = {
      -- These are the default values
      theme = "ivy",
      binary = "docker", -- in case you want to use podman or something
      compose_binary = "docker compose",
      buildx_binary = "docker buildx",
      machine_binary = "docker-machine",
      log_level = vim.log.levels.INFO,
      init_term = "tabnew", -- "vsplit new", "split new", ...
      -- NOTE: init_term may also be a function that receives
      -- a command, a table of env. variables and cwd as input.
      -- This is intended only for advanced use, in case you want
      -- to send the env. and command to a tmux terminal or floaterm
      -- or something other than a built in terminal.
    },
  },
}
-- Load the docker telescope extension
require("telescope").load_extension "docker"
```

Then use the extension:

```lua
:Telescope docker
-- :Telescope docker containers
-- :Telescope docker images
-- :Telescope docker networks
-- :Telescope docker volumes
-- :Telescope docker contexts
-- :Telescope docker swarm
-- :Telescope docker machines
-- :Telescope docker compose
-- :Telescope docker files
```

or with lua:

```lua
require("telescope").extensions.docker.docker(--[[opts...]])
--require("telescope").extensions.docker.containers(...)
-- ...
```

> NOTE: try `:checkhealth telescope-docker` if you encounter any issues.

## Changing docker environment

A table of environment variables may be passed to the pickers:

```lua
require("telescope").extensions.docker.containers({
  env = {
  -- ...
  }
})
-- NOTE: docker env variables may also be added as a global vim variable,
-- but will be overriden by the env passed to the function itself
vim.g.docker_env = {
  -- ...
}
```

## Connecting to a remote docker host

To connect to a remote docker host, an accessible host may be provided to the command:

```lua
Telescope docker containers host=ssh://....
```

or a `DOCKER_HOST` environment variable may be set:

```lua
require("telescope").extensions.docker.containers({
  env = {
    DOCKER_HOST = "ssh://...."
  }
})
-- OR
vim.g.docker_env = {
  DOCKER_HOST = "..."
}
```

> In the example above, the containers would be then fetched
> from the provided docker host.
> The same works for all other pickers, except for dockerfiles and docker compose files.
