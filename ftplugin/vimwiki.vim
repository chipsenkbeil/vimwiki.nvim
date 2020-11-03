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

nnoremap <silent><buffer> <Plug>VimwikiServerExecute
    \ :lua require 'vimwiki_server/api'.code.execute_under_cursor()<CR>
nmap <buffer> gx <Plug>VimwikiServerExecute

" Define our internal mappings for visual and operator-pending modes
onoremap <silent><buffer> <Plug>VimwikiServerElement
    \ :<C-U>lua require 'vimwiki_server/api'.select.an_element()<CR>
vnoremap <silent><buffer> <Plug>VimwikiServerElementV
    \ :<C-U>lua require 'vimwiki_server/api'.select.an_element()<CR>
onoremap <silent><buffer> <Plug>VimwikiServerInnerElement
    \ :<C-U>lua require 'vimwiki_server/api'.select.inner_element()<CR>
vnoremap <silent><buffer> <Plug>VimwikiServerInnerElementV
    \ :<C-U>lua require 'vimwiki_server/api'.select.inner_element()<CR>
onoremap <silent><buffer> <Plug>VimwikiServerParentElement
    \ :<C-U>lua require 'vimwiki_server/api'.select.parent_element()<CR>
vnoremap <silent><buffer> <Plug>VimwikiServerParentElementV
    \ :<C-U>lua require 'vimwiki_server/api'.select.parent_element()<CR>
onoremap <silent><buffer> <Plug>VimwikiServerRootElement
    \ :<C-U>lua require 'vimwiki_server/api'.select.root_element()<CR>
vnoremap <silent><buffer> <Plug>VimwikiServerRootElementV
    \ :<C-U>lua require 'vimwiki_server/api'.select.root_element()<CR>

" Apply our default external mappings for visual and operator-pending modes
omap <buffer> ae <Plug>VimwikiServerElement
omap <buffer> ie <Plug>VimwikiServerInnerElement
omap <buffer> pe <Plug>VimwikiServerParentElement
omap <buffer> re <Plug>VimwikiServerRootElement
vmap <buffer> ae <Plug>VimwikiServerElementV
vmap <buffer> ie <Plug>VimwikiServerInnerElementV
vmap <buffer> pe <Plug>VimwikiServerParentElementV
vmap <buffer> re <Plug>VimwikiServerRootElementV
