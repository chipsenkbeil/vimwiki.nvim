"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" VIMWIKI EXTRAS - LANG :: UTILS :: LOCATION
"
" About: Represents a location in a buffer.
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Ensure that all VimL uses standard option set to maintain consistency
let s:save_cpo = &cpoptions
set cpoptions&vim

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" GLOBAL CONFIG

" g:vimwiki_extras_lang_utils_location_...

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" CONSTRUCTOR

function! vimwiki_extras#lang#utils#location#new() abort
    return copy(s:self)
endfunction

let s:self = {}

" Start and end position (line, col) of the text representing this node
let s:self._start = [1, 0]
let s:self._end = [1, 0]
let s:self._bufnr = -1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" DATA API

function! s:self.get_start_line() dict abort
    return self._start_pos[0]
endfunction

function! s:self.get_start_col() dict abort
    return self._start_pos[1]
endfunction

function! s:self.get_end_line() dict abort
    return self._end_pos[0]
endfunction

function! s:self.get_end_col() dict abort
    return self._end_pos[1]
endfunction

function! s:self.get_bufnr() dict abort
    return self._buf_nr
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" ACTION API - Performs updates in the buffer containing this location

function! s:self.move_to_start_of_other_buf(bufnr) dict abort
    " TODO: Implement
endfunction

function! s:self.move_to_end_of_other_buf(bufnr) dict abort
    " TODO: Implement
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" INTERNAL METHODS

" N/A

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Restore VI-compatible behavior configured by user
let &cpoptions = s:save_cpo
unlet s:save_cpo
