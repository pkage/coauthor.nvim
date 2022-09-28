# coauthor.nvim

## what?

Coauthor is a Neovim 0.7+ plugin to automatically help you write. Select
some text in visual mode to use as a prompt, and coauthor will continue writing
that text for you.

## how?

Put your cursor on a line, then run `:CoauthorWrite`.

To check if the server is running, try `:CoauthorHealth`.

## install?

Install with [packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use {
    'pkage/coauthor.nvim',
    requires = { 'nvim-lua/plenary.nvim' },
    config = function()
        -- default configuration options shown
        require('coauthor').setup({
            server_uri = 'http://localhost:8021',
            max_length = 256
        })
    end
}
```

Install [poetry](https://python-poetry.org/), and ensure you've got the server running somewhere:

```sh
$ cd server
$ poetry run python server.py
```

## future work?

[ ] work with selections instead of lines

Neovim's API is a bit of a pain to work with, so this is future work.

## who?

This plugin was written by [patrick kage](http://ka.ge).

