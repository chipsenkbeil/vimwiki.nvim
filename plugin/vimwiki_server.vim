"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" VIMWIKI SERVER - PLUGIN
"
" About: Represents the plugin to provide enhanced vimwiki functionality in
"        neovim using the vimwiki server.
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if exists('g:private_loaded_vimwiki_server')
    finish
endif
let g:private_loaded_vimwiki_server = 1

" Ensure that all VimL uses standard option set to maintain consistency
let s:save_cpo = &cpoptions
set cpoptions&vim

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Require neovim with lua support, floating windows, and more
if !has('nvim-0.4.0')
    " Only output a warning if editing some special files.
    if index(['', 'gitcommit'], &filetype) == -1
        execute 'echoerr ''vimwiki-server requires NeoVim >= 0.4.0'''
        execute 'echoerr ''Please update your editor appropriately.'''
    endif

    " Stop here, as it won't work.
    finish
endif

" Enable other plugins to play well with this one
let g:loaded_vimwiki_server = 1

augroup vimwiki_server
    autocmd!

    " When entering a vimwiki file, start the server if it is not running
    autocmd BufEnter *.wiki lua require 'vimwiki_server'.start()

    " Required to allow neovim to exit if a server is still running
    autocmd VimLeave * lua require 'vimwiki_server'.stop()
augroup END

" Restore VI-compatible behavior configured by user
let &cpoptions = s:save_cpo
unlet s:save_cpo
