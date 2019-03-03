" Moby Project thesaurus integration for vim
" Author: Tom Kurth <tom@losthalo.org>
" Homepage: http://github.com/tomku/thesauri
" License: GPLv2
" Last Modified: 2012-07-12

" omnifunc for Thesaurus suggestions (better then built-in <C-xC-t>)
" I am setting thesaurus files per buffer not as global
" And I use moby thesaurus which has different format then Vim expects
" see https://github.com/vim/vim/issues/1611
" Oh, and I use this function as omnifunc not completefunc 
function! CompleteThesauri(findstart, base)
    if a:findstart
        let l:line = getline('.')
        let l:start = col('.') - 1
        while l:start > 0 && l:line[l:start - 1] !~# '\s'
            let l:start -= 1
        endwhile
        return l:start
    else
        if !exists('b:mobythesaurus_file')
            return []
        else
            " First version is loose and second is tight check fot yourself,
            " awk filters out unique results
            " Try for yourself in shell
            " rg -N "^([\\w\\s]+)?samolot([\\w\\s]+)?" .vim/spell/pl.thes.txt | tr ',' '\n'
            let l:query ="rg -N --color never \"^([\\w\\s]+)?" . a:base . "([\\w\\s]+)?,\" " . b:mobythesaurus_file . "| tr \",\" \"\\n\" | awk \'{ if (\!($0 in seen)) print $0; seen[$0] = 1; }\'"
            " let l:query ="rg -N --color never \"^([\\w\\s]+)?" . a:base . "([\\w\\s]+)?,\" " . b:mobythesaurus_file . "| tr \",\" \"\\n\" "
            "  rg -N "^samolot," .vim/spell/pl.thes.txt | tr ',' '\n'
            " let l:query ="rg -N --color never \"^" . a:base . ",\" " . b:mobythesaurus_file . "| tr \",\" \"\\n\" "
            let l:output = system(l:query)
            if v:shell_error > 1
                return []
            elseif v:shell_error == 1
                return []
            else
                let l:matches = []
                for l:m in split(l:output, "\n")
                    call add(l:matches, l:m)
                endfor
                return {'words': l:matches, 'refresh': 'always'}
            endif
       endif
    endif
endfun
"
