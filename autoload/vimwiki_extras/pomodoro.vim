" VIMWIKI EXTRAS - POMODORO
"
" About: Represents the top-level API for pomodoro-related operations on top
"        of vimwiki.
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Ensure that all VimL uses standard option set to maintain consistency
let s:save_cpo = &cpoptions
set cpoptions&vim

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" GLOBAL CONFIG

" g:vimwiki_extras_pomodoro_...

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" TOP-LEVEL API

" N/A

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" INTERNAL API

" N/A

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Restore VI-compatible behavior configured by user
let &cpoptions = s:save_cpo
unlet s:save_cpo
