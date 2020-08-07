" VIMWIKI EXTRAS - UTILS
"
" About: Represents the top-level API for utility functions and other useful
"        features related to vimwiki.
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Ensure that all VimL uses standard option set to maintain consistency
let s:save_cpo = &cpoptions
set cpoptions&vim

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" GLOBAL CONFIG

" g:vimwiki_extras_utils_...

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" TOP-LEVEL API

" Produces a 32-bit unique id
function! vimwiki_extras#utils#gen_unique_id() abort
    " Use maximum value of an unsigned 32-bit integer
    return over_there#utils#random(4294967295)
endfunction

" From https://github.com/mhinz/vim-randomtag
"
" Generates a random number up to max integer specified using current time
" in microseconds to provide some form of randomness. This isn't necessarily
" a quality random function nor is it secure, but it's useful to get a number
" that is unique enough for callback IDs
function! vimwiki_extras#utils#random(max) abort
  return str2nr(matchstr(reltimestr(reltime()), '\v\.@<=\d+')[1:]) % a:max
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" INTERNAL API

" N/A

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Restore VI-compatible behavior configured by user
let &cpoptions = s:save_cpo
unlet s:save_cpo
