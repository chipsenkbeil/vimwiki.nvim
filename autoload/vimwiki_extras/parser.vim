" VIMWIKI EXTRAS - PARSER
"
" About: Represents the top-level API our parser combinator library for use
"        in describing and parsing languages using native vimL.
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Ensure that all VimL uses standard option set to maintain consistency
let s:save_cpo = &cpoptions
set cpoptions&vim

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" GLOBAL CONFIG

" g:vimwiki_extras_parser_...

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" TOP-LEVEL API

function! vimwiki_extras#parser#lit(c) abort
    function! s:LitParser(input) closure abort
        let l:r = a:input.read_next()
        if l:r ==# a:c
            call a:input.advance_next()
            return a:c
        else
            return s:failure
        endif
    endfunction

    return funcref('s:LitParser')
endfunction

function! vimwiki_extras#parser#zeroOrOne(parser) abort
    return vimwiki_extras#parser#repeatNM(a:parser, 0, 1)
endfunction

function! vimwiki_extras#parser#repeatNM(parser, n, m) abort
    function! s:RepeatNMParser(input) closure abort
        if a:n > a:m
            return s:failure
        endif

        let l:i = 0
        let l:pos = a:input.get_pos()
        let l:results = []
        while l:i <= a:m
            let l:result = a:parser(a:input)
            if s:is_failure(l:result)
                break
            else
                let l:results += [l:result]
            endif

            let l:i += 1
        endwhile

        if l:i >= a:n && l:i <= a:m
            return l:results
        else
            call a:input.set_pos(l:pos)
            return s:failure
        endif
    endfunction

    return funcref('s:RepeatNMParser')
endfunction

function! vimwiki_extras#parser#not(parser) abort
    function! s:NotParser(input) closure abort
        let l:pos = a:input.get_pos()
        let l:result = a:parser(a:input)
        if !s:is_failure(l:result)
            call a:input.set_pos(l:pos)
            return s:failure
        endif

        let l:r = a:input.read_next()
        call a:input.advance_next()
        return l:r
    endfunction

    return funcref('s:NotParser')
endfunction

function! vimwiki_extras#parser#or(...) abort
    function! s:OrParser(input) closure abort
        for l:p in a:000
            let l:result = l:p(a:input)
            if !s:is_failure(l:result)
                return l:result
            endif
        endfor

        return s:failure
    endfunction

    return funcref('s:OrParser')
endfunction

function! vimwiki_extras#parser#and(...) abort
    function! s:AndParser(input) closure abort
        let l:pos = a:input.get_pos()
        let l:results = []
        for l:p in a:000
            let l:result = l:p(a:input)
            if s:is_failure(l:result)
                call a:input.set_pos(l:pos)
                return s:failure
            else
                let l:results += [l:result]
            endif
        endfor

        return l:results
    endfunction

    return funcref('s:AndParser')
endfunction

function! vimwiki_extras#parser#apply(f, parser) abort
    function! s:ApplyParser(input) closure abort
        let l:result = a:parser(a:input)
        if s:is_failure(l:result)
            return s:failure
        else
            return a:f(l:result)
        endif
    endfunction

    return funcref('s:ApplyParser')
endfunction

function! vimwiki_extras#parser#is_failure(result) abort
    return s:is_failure(a:result)
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" INTERNAL API

function s:SID()
    return matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze_SID$')
endfun

let s:failure = s:SID().'<FAILURE>'

function! s:is_failure(result) abort
    return a:result ==# s:failure
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Restore VI-compatible behavior configured by user
let &cpoptions = s:save_cpo
unlet s:save_cpo
