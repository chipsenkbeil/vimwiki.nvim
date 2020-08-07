" VIMWIKI EXTRAS - LANG :: UTILS :: RESULT
"
" About: Represents the result from running a parser.
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Ensure that all VimL uses standard option set to maintain consistency
let s:save_cpo = &cpoptions
set cpoptions&vim

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" GLOBAL CONFIG

" g:vimwiki_extras_lang_utils_result_...

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" TOP-LEVEL API

function! vimwiki_extras#lang#utils#result#success(info) abort
    let l:self = copy(s:self)
    let l:self._type = s:t_success
    let l:self._data = {'info': a:info}

    return l:self
endfunction

function! vimwiki_extras#lang#utils#result#failure(msg, cause) abort
    let l:self = copy(s:self)
    let l:self._type = s:t_failure
    let l:self._data = {'msg': printf('%s', a:msg), 'cause': a:cause}

    return l:self
endfunction

function! vimwiki_extras#lang#utils#result#is_failure(result) abort
    return type(a:result) == v:t_dict && get(a:result, 'type') ==# s:t_failure
endfunction

let s:self = {}
let s:self._type = ''
let s:self._data = {}

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" PUBLIC API

" True if result is a failure
function! s:self.is_failure() dict abort
    return self._type ==# s:t_failure
endfunction

" True if result is a success
function! s:self.is_success() dict abort
    return !self.is_failure()
endfunction

" If success, will return associated info, otherwise returns false
function! s:self.get_info() dict abort
    return get(self._data, 'info')
endfunction

" If failure, returns the associated msg, otherwise returns false
function! s:self.get_failure_msg() dict abort
    return get(self._data, 'msg')
endfunction

" If failure, returns the associated cause, otherwise returns false
function! s:self.get_failure_cause() dict abort
    return get(self._data, 'cause')
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" INTERNAL API

function s:SID()
    return matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze_SID$')
endfun

let s:t_failure = 'FAILURE'.s:SID()
let s:t_success = 'SUCCESS'.s:SID()

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Restore VI-compatible behavior configured by user
let &cpoptions = s:save_cpo
unlet s:save_cpo
