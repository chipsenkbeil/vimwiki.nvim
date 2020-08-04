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

function! vim_extras#parser#lit(c) abort
    function! l:parser(input) closure abort
        let l:r = a:input.read_next()
        if l:r ==# a:c
            call a:input.advance_next()
            return a:c
        else
            return s:failure
        endif
    endfunction

    return funcref('l:parser')
endfunction

function! vim_extras#parser#zeroOrOne(parser) abort
    return vim_extras#parser#repeatNM(a:parser, 0, 1)
endfunction

function! vim_extras#parser#repeatNM(parser, n, m) abort
    function! l:parser(input) closure abort
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

    return funcref('l:parser')
endfunction

function! vim_extras#parser#not(parser) abort
    function! l:parser(input) closure abort
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

    return funcref('l:parser')
endfunction

function! vim_extras#parser#or(...) abort
    function! l:parser(input) closure abort
        for l:p in a:000
            let l:result = l:p(a:input)
            if !s:is_failure(l:result)
                return l:result
            endif
        endfor

        return s:failure
    endfunction

    return funcref('l:parser')
endfunction

function! vim_extras#parser#and(...) abort
    function! l:parser(input) closure abort
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

    return funcref('l:parser')
endfunction

function! vim_extras#parser#apply(f, parser) abort
    function! l:parser(input) closure abort
        let l:result = a:parser(a:input)
        if s:is_failure(l:result)
            return s:failure
        else
            return a:f(l:result)
        endif
    endfunction

    return funcref('l:parser')
endfunction

function! vimwiki_extras#parser#is_failure(result) abort
    return s:is_failure(a:result)
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" INTERNAL API

let s:failure = '<__FAILURE__>'

function! s:is_failure(result) abort
    return a:result ==# s:failure
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Restore VI-compatible behavior configured by user
let &cpoptions = s:save_cpo
unlet s:save_cpo
