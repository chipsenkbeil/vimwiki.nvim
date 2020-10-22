# vimwiki-server.nvim

*Neovim plugin* that offers enhanced and alternative functionality for the
vimwiki language. This project uses `vimwiki-server` (part of the part of the
[vimwiki-rs](https://github.com/chipsenkbeil/vimwiki-rs) family) to power its
functionality in combination with the neovim Lua engine to provide all of its
vimwiki goodness.

**Not compatible with vim!**

## Table of Contents

1. [Usage](#usage)
2. [Installation](#installation)
3. [Contributing](#contributing)
4. [License](#license)

<a name="usage"></a>

## 1. Usage

TODO

<a name="installation"></a>

## 2. Installation

It is recommended to include this plugin alongside
[vimwiki](https://github.com/vimwiki/vimwiki).

Additionally, as `vimwiki-server` is experimental, this plugin uses git tags
to associate it with releases of `vimwiki-server` to ensure compatibility with
a given version. Be sure to pair your plugin with the version of the server
you are using!

```vim
Plug 'vimwiki/vimwiki'
Plug 'chipsenkbeil/vimwiki-server.nvim', { 'tag': 'v0.1.0' }
```

<a name="contributing"></a>

## 3. Contributing

TODO

<a name="license"></a>

## 4. License

BSD 2-Clause
