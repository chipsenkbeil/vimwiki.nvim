"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" VIMWIKI SERVER - PLUGIN
"
" About: Represents the plugin to provide enhanced vimwiki functionality in
"        neovim using the vimwiki server.
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if exists('g:vimwiki_server#internal#loaded')
    finish
endif
let g:vimwiki_server#internal#loaded = 1

" Ensure that all VimL uses standard option set to maintain consistency
let s:save_cpo = &cpoptions
set cpoptions&vim

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" CHECK VERSION

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

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" DEFINE EVENT HANDLING

augroup vimwiki_server
    autocmd!

    " When entering a vimwiki file, start the server if it is not running
    autocmd BufEnter *.wiki lua require 'vimwiki_server'.start()

    " Required to allow neovim to exit if a server is still running
    autocmd VimLeave * lua require 'vimwiki_server'.stop()

    " Events related to buffer content so vimwiki-server can report on
    " unsaved buffers
    autocmd BufWinEnter *.wiki lua require 'vimwiki_server/api'.events.on_enter_buffer_window()
    autocmd BufUnload *.wiki lua require 'vimwiki_server/api'.events.on_buffer_unload()
    autocmd InsertLeave *.wiki lua require 'vimwiki_server/api'.events.on_insert_leave()
    autocmd TextChanged,TextChangedI *.wiki lua require 'vimwiki_server/api'.events.on_text_changed()
augroup END

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" DEFINE COMMANDS

command! -nargs=0 VimwikiServerEvalCode
    \ :lua require 'vimwiki_server/api'.code.execute_under_cursor()<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Enable other plugins to play well with this one
let g:vimwiki_server#loaded = 1

" Restore VI-compatible behavior configured by user
let &cpoptions = s:save_cpo
unlet s:save_cpo
