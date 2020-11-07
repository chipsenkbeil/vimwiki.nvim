# vimwiki-server.nvim

*Neovim plugin* that offers enhanced and alternative functionality for the
vimwiki language. This project uses `vimwiki-server` (part of the part of the
[vimwiki-rs](https://github.com/chipsenkbeil/vimwiki-rs) family) to power its
functionality in combination with the neovim Lua engine to provide all of its
vimwiki goodness.

**Not compatible with vim!**

## Table of Contents

1. [Installation](#installation)
2. [Usage](#usage)
3. [Contributing](#contributing)
4. [License](#license)

<a name="installation"></a>

## 1. Installation

Prior to installing this plugin, you must have the
[vimwiki-server](https://github.com/chipsenkbeil/vimwiki-rs/vimwiki-server)
binary available on your path. As `vimwiki-server` is experimental, this
plugin uses git tags to associate it with releases of `vimwiki-server` to
ensure compatibility with a given version. Be sure to pair your plugin with
the version of the server you are using!

Additionally, it is recommended to include this plugin alongside [vimwiki](https://github.com/vimwiki/vimwiki), although it is not required for the functionality covered by this plugin.


### Examples

With [vim-plug](https://github.com/junegunn/vim-plug):

```vim
Plug 'vimwiki/vimwiki'
Plug 'chipsenkbeil/vimwiki-server.nvim', { 'tag': 'v0.1.0-alpha.5' }
```

<a name="usage"></a>

## 2. Usage

### Code Execution

Within vimwiki, you can define preformatted text blocks, also known as code
blocks, using the following syntax:

```vimwiki
{{{
some code
is here
}}}
```

This plugin provides the ability to execute a code block under your cursor
through the mapping `gx`, as seen in [this example](https://asciinema.org/a/370438?t=62).

To perform code execution, this plugin spawns a new process and pipes the code
within the code block into the process via stdin. In order to know which
process to spawn, you need to set a global variable in neovim. For example, to
execute python code, you would include this definition:

```vim
" For python, send code to repl using stdin
let g:vimwiki_server#code#python = 'python3'
```

The above pattern is to use `g:vimwiki_server#code#<LANG>` where `<LANG>` is
replaced with the language used for your code block. For the above definition,
your code block needs to have a python label:

```vimwiki
{{{python
x = 0
while x < 5:
    print(5)
    x += 1
}}}
```

If you want to have a default language process that is used when a code block
does not have a language associated, you can specify it with
`g:vimwiki_server#code#default`.

Lastly, because code execution is trigger by neovim, there is one special
exception to code execution, which is defining the code with the vim language.
In this case, the vimscript is evaluated within neovim, which can be used to
set mappings, override variables, and more.

```vimwiki
{{{vim
" Change our setting by evaluating this vimscript code block
let g:vimwiki_server#code#python = 'python2'

" Print out some information to show in our result
echom 'Finished updating variables'
}}}
```

### Text Objects

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

<a name="contributing"></a>

## 3. Contributing

TODO

<a name="license"></a>

## 4. License

BSD 2-Clause
