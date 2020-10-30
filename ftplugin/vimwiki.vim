"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" VIMWIKI SERVER - FTPLUGIN :: VIMWIKI
"
" About: Represents the filetype plugin for the vimwiki language in
"        collaboration with the vimwiki server.
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Only load this plugin once per buffer
if exists('b:__vimwiki_server_ftplugin_vimwiki')
  finish
endif
let b:__vimwiki_server_ftplugin_vimwiki = 1

" Define our internal mappings for visual and operator-pending modes
onoremap <silent><buffer> <Plug>VimwikiServerElement
    \ :<C-U>lua require 'vimwiki_server'.select_an_element()<CR>
vnoremap <silent><buffer> <Plug>VimwikiServerElementV
    \ :<C-U>lua require 'vimwiki_server'.select_an_element()<CR>
onoremap <silent><buffer> <Plug>VimwikiServerInnerElement
    \ :<C-U>lua require 'vimwiki_server'.select_inner_element()<CR>
vnoremap <silent><buffer> <Plug>VimwikiServerInnerElementV
    \ :<C-U>lua require 'vimwiki_server'.select_inner_element()<CR>

" Apply our default external mappings for visual and operator-pending modes
omap <buffer> ae <Plug>VimwikiServerElement
omap <buffer> ie <Plug>VimwikiServerInnerElement
vmap <buffer> ae <Plug>VimwikiServerElementV
vmap <buffer> ie <Plug>VimwikiServerInnerElementV
