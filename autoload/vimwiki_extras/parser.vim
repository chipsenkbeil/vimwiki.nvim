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

function! vimwiki_extras#parser#any_char() abort
    function! s:Parser(input) closure abort
        if a:input.has_more()
            let l:c = a:input.read_next()
            call a:input.advance_next()
            return l:c
        else
            return s:failure
        endif
    endfunction

    return funcref('s:Parser')
endfunction

function! vimwiki_extras#parser#lit(text) abort
    let l:text_len = len(a:text)
    function! s:Parser(input) closure abort
        let l:r = a:input.read_n(l:text_len)
        if l:r ==# a:text
            call a:input.advance_n(l:text_len)
            return a:text
        else
            return s:failure
        endif
    endfunction

    return funcref('s:Parser')
endfunction

function! vimwiki_extras#parser#oneOrMore(parser) abort
    let l:RepeatParser = vimwiki_extras#parser#repeat(a:parser)
    function! s:Parser(input) closure abort
        let l:results = l:RepeatParser(a:input)

        if empty(l:results)
            return s:failure
        else
            return l:results
        endif
    endfunction

    return funcref('s:Parser')
endfunction

function! vimwiki_extras#parser#repeat(parser) abort
    function! s:Parser(input) closure abort
        let l:results = []

        while a:input.has_more()
            let l:result = a:parser(a:input)

            if s:is_failure(l:result)
                break
            endif

            let l:results += [l:result]
        endwhile

        return l:results
    endfunction

    return funcref('s:Parser')
endfunction

function! vimwiki_extras#parser#zeroOrOne(parser) abort
    return vimwiki_extras#parser#repeatNM(a:parser, 0, 1)
endfunction

function! vimwiki_extras#parser#repeatNM(parser, n, m) abort
    function! s:Parser(input) closure abort
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

    return funcref('s:Parser')
endfunction

function! vimwiki_extras#parser#not(parser) abort
    function! s:Parser(input) closure abort
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

    return funcref('s:Parser')
endfunction

function! vimwiki_extras#parser#or(...) abort
    let l:parsers = a:000
    function! s:Parser(input) closure abort
        for l:Parser in l:parsers
            let l:result = l:Parser(a:input)
            if !s:is_failure(l:result)
                return l:result
            endif
        endfor

        return s:failure
    endfunction

    return funcref('s:Parser')
endfunction

function! vimwiki_extras#parser#and(...) abort
    let l:parsers = a:000
    function! s:Parser(input) closure abort
        let l:pos = a:input.get_pos()
        let l:results = []
        for l:Parser in l:parsers
            let l:result = l:Parser(a:input)
            if s:is_failure(l:result)
                call a:input.set_pos(l:pos)
                return s:failure
            else
                let l:results += [l:result]
            endif
        endfor

        return l:results
    endfunction

    return funcref('s:Parser')
endfunction

function! vimwiki_extras#parser#apply(parser, f) abort
    function! s:Parser(input) closure abort
        let l:pos = a:input.get_pos()
        let l:result = a:parser(a:input)
        if s:is_failure(l:result)
            return s:failure
        else
            try
                let l:f_result = a:f(l:result)
                return l:f_result
            catch
                call a:input.set_pos(l:pos)
                return s:failure
            endtry
        endif
    endfunction

    return funcref('s:Parser')
endfunction

function! vimwiki_extras#parser#predicate(parser, pred) abort
    function! s:Parser(input) closure abort
        let l:pos = a:input.get_pos()
        let l:result = a:parser(a:input)

        try
            let l:pred_result = a:pred(l:result)
            if l:pred_result
                return l:result
            else
                call a:input.set_pos(l:pos)
                return s:failure
            endif
        catch
            call a:input.set_pos(l:pos)
            return s:failure
        endtry
    endfunction

    return funcref('s:Parser')
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
