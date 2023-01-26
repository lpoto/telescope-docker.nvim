# Telescope docker

`telescope-docker.nvim` is a [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) extension,
that allows managing containers, images and docker-compose files from a telescope prompt.

## Demo

https://user-images.githubusercontent.com/67372390/214747403-4904a315-91f2-4205-a00d-cba793c49247.mp4
> _NOTE_  The demo uses [vim-floaterm](https://github.com/voldikss/vim-floaterm), as mentioned in the [Setup and usage](#setup-and-usage) below.

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
      init_term = function(command)
        -- Function used to initialize the terminal with the provided command
        -- by default a new tab with `'term ' .. command` is used.
        -- Example for using Floaterm instead:
        vim.cmd("FloatermNew")
        vim.cmd("FloatermSend " .. command)
      end
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
