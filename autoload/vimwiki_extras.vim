"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" VIMWIKI EXTRAS - AUTOLOAD ENTRYPOINT
"
" About: Represents the entrypoint for the autoloaded portion of the vimwiki
"        extras plugin for vim. Will import plugin APIs to interact with
"        vimwiki files.
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if exists('g:autoloaded_vimwiki_extras')
    finish
endif
let g:autoloaded_vimwiki_extras = 1

" Ensure that all VimL uses standard option set to maintain consistency
let s:save_cpo = &cpoptions
set cpoptions&vim

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" GLOBAL CONFIG

" Contains all active clients by job id
let g:vimwiki_extras_clients = {}

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" TOP-LEVEL API

" Inspects vimwiki syntax under the cursor to determine what object is
" immediately under scope.
"
" :: Arguments
"
"   N/A
"
" :: Returns
"
"   vimwiki language object if successful
"
function! vimwiki_extras#inspect_under_cursor() abort
    echom 'Hello!'
endfunction

" Manipulates vimwiki syntax under the cursor using the given instructions,
" applying them if possible.
"
" :: Arguments
"
"   instructions: TODO
"
" :: Returns
"
"   vimwiki action description if successful
"
function! vimwiki_extras#manipulate_under_cursor() abort

endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" INTERNAL API

" N/A

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Restore VI-compatible behavior configured by user
let &cpoptions = s:save_cpo
unlet s:save_cpo
