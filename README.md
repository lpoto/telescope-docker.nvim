# Telescope docker

`telescope-docker.nvim` is a [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) extension,
that allows managing containers, images and docker-compose files from a telescope prompt.

## Demo

https://user-images.githubusercontent.com/67372390/236677032-32ebe222-c0f1-480c-a6b6-758ac84d0475.mp4

**_NOTE_** _Docker commands may be selected with either `<CR>` or `<C-a>`, selecting with
`<C-a>` allows adding additional arguments._

## Installation

### [Lazy](https://github.com/folke/lazy.nvim)

```lua
require("lazy").setup({
  "lpoto/telescope-docker.nvim",
})
```

### [Packer](https://github.com/wbthomason/packer.nvim)

```lua
use {"lpoto/telescope-docker.nvim"}
```

### [Vim-Plug](https://github.com/junegunn/vim-plug)

```lua
Plug  "lpoto/telescope-docker.nvim"
```

## Setup and usage

First setup and load the extension:

```lua
require("telescope").setup {
  extensions = {
    -- NOTE: this setup is optional
    docker = {
      theme = "ivy",
      binary = "docker", -- in case you want  to use podman or something
      log_level = vim.log.levels.INFO,
      init_term = "tabnew", -- "vsplit new", "split new", ...
      -- NOTE: init_term may also be a function that receives
      -- a command and a table of env. variables as input.
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
-- :Telescope docker compose
```

or in lua:

```lua
require("telescope").extensions.docker.containers(--[[opts...]])
--require("telescope").extensions.docker.images(...)
--require("telescope").extensions.docker.compose(...)
```

## Connecting to a remote docker host

A table of environment variables may be passed to the pickers:

```lua
require("telescope").extensions.docker.containers({
  env = {
    DOCKER_HOST = "ssh://remote-host..." -- NOTE: make sure to provide an accessible docker host
    -- ...
  }
  -- ...
})

-- NOTE: the host variable could also be provided in the telescope command
:Telescope docker host=ssh...

-- NOTE: docker env variables may also be added as a global vim variable,
-- but will be overriden by the env passed to the function itself
vim.g.docker_env = {
  DOCKER_HOST = "ssh://ec2-user@ec2-......amazonaws.com",
}
```

> In the above example the containers would be then fetched
> from the provided docker host.
> The same works for fetching images.
