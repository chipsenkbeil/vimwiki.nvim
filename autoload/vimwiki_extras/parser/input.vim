" VIMWIKI EXTRAS - PARSER :: INPUT
"
" About: Represents the input used with a parser.
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Ensure that all VimL uses standard option set to maintain consistency
let s:save_cpo = &cpoptions
set cpoptions&vim

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" GLOBAL CONFIG

" g:vimwiki_extras_parser_input_...

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" CONSTRUCTOR

function! vimwiki_extras#parser#input#new(text) abort
    let l:self = copy(s:self)
    let l:self._text = a:text
    let l:self._len = len(a:text)

    return l:self
endfunction

let s:self = {}
let s:self._text = ''
let s:self._pos = 0
let s:self._len = 0
let s:self._prev_pos = 0

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" PUBLIC API

function! s:self.read_next() dict abort
    return self.read_n(1)
endfunction

function! s:self.read_n(n) dict abort
    return self._text[self._pos : self._pos+a:n-1]
endfunction

function! s:self.advance_next() dict abort
    call self.advance_n(1)
endfunction

function! s:self.advance_n(n) dict abort
    call self.set_pos(self.get_pos() + a:n)
endfunction

function! s:self.rollback() dict abort
    call self.set_pos(self._prev_pos)
endfunction

function! s:self.get_pos() dict abort
    return self._pos
endfunction

function! s:self.set_pos(pos) dict abort
    let self._prev_pos = self._pos
    let self._pos = a:pos
endfunction

function! s:self.get_len() dict abort
    return self._len - self._pos
endfunction

function! s:self.has_more() dict abort
    return self.get_len() > 0
endfunction

function! s:self.to_str() dict abort
    return self._pos.'/'.self._len.': '.self._text
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" INTERNAL API

" N/A

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Restore VI-compatible behavior configured by user
let &cpoptions = s:save_cpo
unlet s:save_cpo
