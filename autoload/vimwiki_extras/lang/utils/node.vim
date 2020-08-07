"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" VIMWIKI EXTRAS - LANG :: UTILS :: NODE
"
" About: Represents a node in a language graph.
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Ensure that all VimL uses standard option set to maintain consistency
let s:save_cpo = &cpoptions
set cpoptions&vim

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" GLOBAL CONFIG

" g:vimwiki_extras_lang_utils_node_...

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" CONSTRUCTOR

function! vimwiki_extras#lang#utils#node#new(type) abort
    let l:self = copy(s:self)
    let l:self._type = a:type

    return l:self
endfunction

let s:self = {}
let s:self._type = ''
let s:self._children = []
let s:self._prev_sibling = v:null
let s:self._next_sibling = v:null
let s:self._parent = v:null
let s:self._location = vimwiki_extras#lang#utils#location#new()

" TODO: Support setting sig for all nodes in an entire parse tree by
"       generating a single random number using ..#utils#gen_unique_id()
"
"       Keep a global vimwiki_extras_change or something that has the last
"       set unique id, allowing us to determine if the node is stale or not
"
"       ALSO -- vimscript is super slow. If there is any chance this would
"       work, we'd need to know where the cursor is and what is being
"       edited/changed in a buffer so we can quickly look up the associated
"       node and only edit it and its children... maybe? Location info would
"       change across all nodes below the one being edited in a buffer,
"       possibly
let s:self._sig = 0

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" DATA API

function! s:self.get_type() dict abort
    return self._type
endfunction

function! s:self.get_children() dict abort
    return self._children
endfunction

function! s:self.add_child(child) dict abort
    let self._children += [a:child]
endfunction

function! s:self.get_prev_sibling() dict abort
    return self._prev_sibling
endfunction

function! s:self.set_prev_sibling(sibling) dict abort
    let self._prev_sibling = a:sibling
endfunction

function! s:self.get_next_sibling() dict abort
    return self._next_sibling
endfunction

function! s:self.set_next_sibling(sibling) dict abort
    let self._next_sibling = a:sibling
endfunction

function! s:self.get_parent() dict abort
    return self._parent
endfunction

function! s:self.set_parent(parent) dict abort
    let self._parent = a:parent
endfunction

function! s:self.get_location() dict abort
    return self._location
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" ACTION API - Performs updates in the buffer containing this node

function! s:self.move_below_next_sibling() dict abort
    " TODO: Implement
endfunction

function! s:self.move_above_prev_sibling() dict abort
    " TODO: Implement
endfunction

function! s:self.move_up_level() dict abort
    " TODO: Implement
endfunction

function! s:self.move_down_level() dict abort
    " TODO: Implement
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" INTERNAL METHODS

" N/A

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Restore VI-compatible behavior configured by user
let &cpoptions = s:save_cpo
unlet s:save_cpo
