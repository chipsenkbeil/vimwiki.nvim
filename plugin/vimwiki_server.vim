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

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" TODO: Provide shortcuts to API through commands like
"
"   command! -bar VimwikiExtrasDoTask :call vimwiki_server#DoTask()
"   command! -bar -nargs=* VimwikiExtrasDoTaskWithArgs :call vimwiki_server#DoTaskWithArgs(<f-args>)

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" TODO: Provide plug mappings to API like
"
"   nnoremap <silent> <Plug>(vimwiki_server_do_task) :VimwikiExtrasDoTask<Return>
"   nnoremap <silent> <Plug>(vimwiki_server_do_task_with_args) :VimwikiExtrasDoTaskWithArgs args<Return>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" TODO: Provide text objects
"
" https://vim.fandom.com/wiki/Creating_new_text_objects
" :h omap-info

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

onoremap <silent> <Plug>VimwikiServerElement
    \ :<C-U>lua require('vimwiki_server').select_an_element()<CR>
vnoremap <silent> <Plug>VimwikiServerElement
    \ :<C-U>lua require('vimwiki_server').select_an_element()<CR>
onoremap <silent> <Plug>VimwikiServerInnerElement
    \ :<C-U>lua require('vimwiki_server').select_inner_element()<CR>
vnoremap <silent> <Plug>VimwikiServerInnerElement
    \ :<C-U>lua require('vimwiki_server').select_inner_element()<CR>

omap ae <Plug>VimwikiServerElement
omap ie <Plug>VimwikiServerInnerElement
vmap ae <Plug>VimwikiServerElement
vmap ie <Plug>VimwikiServerInnerElement

augroup vimwiki_server
    autocmd!

    " When entering a vimwiki file, start the server if it is not running
    autocmd BufEnter *.wiki lua require('vimwiki_server').start()

    " Required to allow neovim to exit if a server is still running
    autocmd VimLeave * lua require('vimwiki_server').stop()
augroup END

" Restore VI-compatible behavior configured by user
let &cpoptions = s:save_cpo
unlet s:save_cpo
