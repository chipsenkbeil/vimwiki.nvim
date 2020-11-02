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

### Selection

This plugin provides several bindings to support selection and operation on
general elements within vimwiki files. Check out the [example in action](https://asciinema.org/a/369723?t=9).

- `ae` works on **an element** under cursor
    - `vae` will visually select the full element
    - `cae` will change an element
    - `dae` will delete an element
    - `yae` will yank an element
    - you can apply any other pending operator using `ae`
- `ie` works on **inner element** of element under cursor
    - `vie` will visually select the inner element
    - `cie` will change the inner element
    - `die` will delete the inner element
    - `yie` will yank the inner element
    - you can apply any other pending operator using `ie`
- `pe` works on **parent element** of element under cursor
    - `vpe` will visually select the parent element
    - `cpe` will change the parent element
    - `dpe` will delete the parent element
    - `ype` will yank the parent element
    - you can apply any other pending operator using `pe`
- `re` works on **root element** of element under cursor
    - `vre` will visually select the root element
    - `cre` will change the root element
    - `dre` will delete the root element
    - `yre` will yank the root element
    - you can apply any other pending operator using `re`

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
Plug 'chipsenkbeil/vimwiki-server.nvim', { 'tag': 'v0.1.0-alpha.4' }
```

<a name="contributing"></a>

## 3. Contributing

TODO

<a name="license"></a>

## 4. License

BSD 2-Clause
