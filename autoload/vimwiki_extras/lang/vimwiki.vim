"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" VIMWIKI EXTRAS - LANG :: VIMWIKI
"
" About: Represents the vimwiki language defined using a grammar and objects.
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Ensure that all VimL uses standard option set to maintain consistency
let s:save_cpo = &cpoptions
set cpoptions&vim

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" GLOBAL CONFIG

" g:vimwiki_extras_lang_vimwiki_...

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" CONSTRUCTOR

function! vimwiki_extras#lang#vimwiki#new()
    return copy(s:self)
endfunction

let s:self = {}

" TODO: Use matchlist() to get ... regex may be too hard for the entire prog
" Could try the syntax groups...

" Types:
"   1. Starting a line (paragraph, header, although can have spaces in front)
"   2. Within a single line (typeface, links, transclusions,
"   3. Multi line:
"       a. Lists (only the first line has an indicator like - or 1.)
"          Continuations line up with the text from first line AND can have
"          other sub items inbetween
"       b. Comments
"       c. Mathjax

" k


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" PUBLIC METHODS

function! s:self.parse(text) dict abort
    let l:input = vimwiki_extras#lang#utils#input#new(a:text)
    let l:b = vimwiki_extras#lang#utils#builder#new()

    let l:Parser = l:b.or(
    \ vimwiki_extras#lang#vimwiki#header#parser(),
    \ )

    return l:Parser(l:input)
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" INTERNAL METHODS

" N/A

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Restore VI-compatible behavior configured by user
let &cpoptions = s:save_cpo
unlet s:save_cpo
