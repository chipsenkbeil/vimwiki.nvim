"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" VIMWIKI EXTRAS - LANG :: VIMWIKI :: HEADER
"
" About: Represents a header in vimwiki.
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Ensure that all VimL uses standard option set to maintain consistency
let s:save_cpo = &cpoptions
set cpoptions&vim

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" GLOBAL CONFIG

" g:vimwiki_extras_lang_vimwiki_header_...

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" CONSTRUCTOR

function! vimwiki_extras#lang#vimwiki#header#new(level, text) abort
    let l:self = copy(s:self)
    let l:self._level = a:level
    let l:self._text = a:text

    return l:self
endfunction

let s:self = vimwiki_extras#lang#utils#node#new('header')
let s:self._level = 0
let s:self._text = ''

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" STATIC FUNCTIONS

function! vimwiki_extras#lang#vimwiki#header#parser() abort
    let l:b = vimwiki_extras#lang#utils#builder#new()

    return b.apply(
    \ b.predicate(
    \   b.and(
    \     b.zeroOrMore(b.lit(' ')),
    \     b.oneOrMore(b.lit('=')),
    \     b.lit(' '),
    \     b.oneOrMore(b.not(b.lit(' ='))),
    \     b.lit(' '),
    \     b.oneOrMore(b.lit('=')),
    \   ),
    \   {r -> len(r[1]) == len(r[5])},
    \ ),
    \ {r -> vimwiki_extras#lang#vimwiki#header#new(len(r[1]), join(r[3], ''))},
    \ )
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" DATA API

function! s:self.get_text() dict abort
    return self._text
endfunction

function! s:self.get_level() dict abort
    return self._level
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" ACTION API - Performs updates in the buffer containing this element

function! s:self.set_text(text) dict abort
    let self._text = a:text
    " TODO: Perform update directly in the buffer
endfunction

function! s:self.set_level(level) dict abort
    " Ignore setting a bad level
    if a:level <= 0
        return
    endif

    let self._level = a:level
    " TODO: Perform update directly in the buffer
endfunction

function! s:self.increase_level() dict abort
    call self.set_level(self.get_level() + 1)
endfunction

function! s:self.decrease_level() dict abort
    call self.set_level(self.get_level() - 1)
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" INTERNAL METHODS

" N/A

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Restore VI-compatible behavior configured by user
let &cpoptions = s:save_cpo
unlet s:save_cpo
