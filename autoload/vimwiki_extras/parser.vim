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

function! vimwiki_extras#parser#new_builder() abort
    return copy(s:self)
endfunction

let s:self = {}

function! s:self.any_char() dict abort
    function! s:Parser(input) closure abort
        if a:input.has_more()
            let l:c = a:input.read_next()
            call a:input.advance_next()
            return l:c
        else
            return s:make_failure('any_char: No more input available', v:null)
        endif
    endfunction

    return funcref('s:Parser')
endfunction

function! s:self.lit(text) dict abort
    let l:text_len = len(a:text)
    function! s:Parser(input) closure abort
        let l:r = a:input.read_n(l:text_len)
        if l:r ==# a:text
            call a:input.advance_n(l:text_len)
            return a:text
        else
            return s:make_failure(
            \ 'lit: Looking for "'.a:text.'", but found "'.l:r.'"',
            \ v:null,
            \ )
        endif
    endfunction

    return funcref('s:Parser')
endfunction

function! s:self.oneOrMore(parser) dict abort
    let l:RepeatParser = self.repeat(a:parser)
    function! s:Parser(input) closure abort
        let l:results = l:RepeatParser(a:input)

        if empty(l:results)
            return s:make_failure(
            \ 'oneOrMore: Found zero results, but expected one or more',
            \ v:null,
            \ )
        else
            return l:results
        endif
    endfunction

    return funcref('s:Parser')
endfunction

function! s:self.repeat(parser) dict abort
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

function! s:self.zeroOrOne(parser) dict abort
    return self.repeatNM(a:parser, 0, 1)
endfunction

function! s:self.exactly(parser, n) dict abort
    return self.repeatNM(a:parser, a:n, a:n)
endfunction

function! s:self.repeatNM(parser, n, m) dict abort
    function! s:Parser(input) closure abort
        if a:n > a:m
            return s:make_failure('repeatNM: n > m', v:null)
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
            return s:make_failure(
            \ 'repeatNM: Wanted in range ['.a:n.','.a:m.'], but found '.l:i.' matches',
            \ v:null,
            \ )
        endif
    endfunction

    return funcref('s:Parser')
endfunction

function! s:self.not(parser) dict abort
    function! s:Parser(input) closure abort
        let l:pos = a:input.get_pos()
        let l:result = a:parser(a:input)
        if !s:is_failure(l:result)
            call a:input.set_pos(l:pos)
            return s:make_failure(
            \ 'not: Unexpectedly succeeded with '.printf('%s', l:result),
            \ v:null,
            \ )
        endif

        let l:r = a:input.read_next()
        call a:input.advance_next()
        return l:r
    endfunction

    return funcref('s:Parser')
endfunction

function! s:self.or(...) dict abort
    let l:parsers = a:000
    function! s:Parser(input) closure abort
        for l:Parser in l:parsers
            let l:result = l:Parser(a:input)
            if !s:is_failure(l:result)
                return l:result
            endif
        endfor

        return s:make_failure('or: No match found', v:null)
    endfunction

    return funcref('s:Parser')
endfunction

function! s:self.and(...) dict abort
    let l:parsers = a:000
    function! s:Parser(input) closure abort
        let l:pos = a:input.get_pos()
        let l:results = []
        for l:Parser in l:parsers
            let l:result = l:Parser(a:input)
            if s:is_failure(l:result)
                call a:input.set_pos(l:pos)
                return s:make_failure('and: Failed some match', l:result)
            else
                let l:results += [l:result]
            endif
        endfor

        return l:results
    endfunction

    return funcref('s:Parser')
endfunction

function! s:self.apply(parser, f) dict abort
    function! s:Parser(input) closure abort
        let l:pos = a:input.get_pos()
        let l:result = a:parser(a:input)
        if s:is_failure(l:result)
            return s:make_failure('apply: Failed to match', l:result)
        else
            try
                let l:f_result = a:f(l:result)
                return l:f_result
            catch
                call a:input.set_pos(l:pos)
                return s:make_failure(
                \ 'apply: '.printf('%s', v:exception),
                \ v:null,
                \ )
            endtry
        endif
    endfunction

    return funcref('s:Parser')
endfunction

function! s:self.predicate(parser, pred) dict abort
    function! s:Parser(input) closure abort
        let l:pos = a:input.get_pos()
        let l:result = a:parser(a:input)
        if s:is_failure(l:result)
            return s:make_failure('predicate: Subparser failed', l:result)
        endif

        try
            let l:pred_result = a:pred(l:result)
            if l:pred_result
                return l:result
            else
                call a:input.set_pos(l:pos)
                return s:make_failure('predicate: Predicate failed', v:null)
            endif
        catch
            call a:input.set_pos(l:pos)
            return s:make_failure(
            \ 'predicate: '.printf('%s', v:exception),
            \ v:null,
            \ )
        endtry
    endfunction

    return funcref('s:Parser')
endfunction

function! s:self.side_effect(parser, f) dict abort
    function! s:Parser(input) closure abort
        let l:pos = a:input.get_pos()
        let l:result = a:parser(a:input)
        if s:is_failure(l:result)
            return s:make_failure('side_effect: Failed to match', l:result)
        else
            try
                call a:f(l:result)
                return l:result
            catch
                call a:input.set_pos(l:pos)
                return s:make_failure(
                \ 'apply: '.printf('%s', v:exception),
                \ v:null,
                \ )
            endtry
        endif
    endfunction

    return funcref('s:Parser')
endfunction

function! vimwiki_extras#parser#is_failure(result) abort
    return s:is_failure(a:result)
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" INTERNAL API

function! s:make_failure(msg, cause) abort
    return {
    \ 'type': 'failure',
    \ 'msg': printf('%s', a:msg),
    \ 'cause': a:cause,
    \ }
endfunction

function! s:is_failure(result) abort
    return type(a:result) == v:t_dict && get(a:result, 'type') ==# 'failure'
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Restore VI-compatible behavior configured by user
let &cpoptions = s:save_cpo
unlet s:save_cpo
