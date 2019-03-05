" Moby Project thesaurus integration for vim
" Author: chew-z base on work of Tom Kurth <tom@losthalo.org>
" Homepage: http://github.com/chew-z/thesauri forked from http://github.com/tomku/thesauri
" License: GPLv2
" Last Modified: 2019-03-05

" TODO

" omnifunc for Thesaurus suggestions (better then built-in <C-xC-t>)
" I am setting thesaurus files per buffer not as global
" And I use moby thesaurus which has different format then Vim expects
" see https://github.com/vim/vim/issues/1611
" Oh, and I use this function as omnifunc not completefunc

if !exists('g:mobythesaurus_mode') | let g:mobythesaurus_mode = 0 | endif
let s:myLangList = exists('g:thesauriLangList') ? g:thesauriLangList : [ '', 'pl', 'en']
let s:fts = exists('g:thesauri_filetypes') ? g:thesauri_filetypes : ['text', 'mail', 'markdown', 'notes']

if !exists('g:thesauri_map_keys')
    let g:thesauri_map_keys = 1
endif

if g:thesauri_map_keys
    inoremap <C-l> <C-o>:call thesauri#ToggleSpellLang()<CR>
endif

function! thesauri#ToggleSpellLang()
    if  index(s:fts, &filetype) == -1 " only text or markdown (or add to g:thesauri_filetypes)
        echom 'wrong filetype for prose writing'
    else
        if !exists( 'b:myLang')
            if &spell | let b:myLang = index(s:myLangList, &spelllang) | endif
        endif
        let b:myLang += 1
        if b:myLang >= len(s:myLangList) | let b:myLang = 0 | endif
        if b:myLang == 0
            set omnifunc=syntaxcomplete#Complete
            setlocal nospell
        else
            execute 'setlocal spell spelllang =' . get(s:myLangList, b:myLang, 'pl')
            let s:spelllang = get(s:myLangList, b:myLang, 'pl')
            let b:mobythesaurus_file=$HOME . '/.vim/spell/' . s:spelllang . '.thes.txt'
            setlocal omnifunc=thesauri#OmniThesauri
        endif
        highlight clear SpellBad
        highlight SpellBad cterm=underline
        echom 'language:' get(s:myLangList, b:myLang)
    endif
endfunction
"
function! thesauri#OmniThesauri(findstart, base)
    if a:findstart
        let l:line = getline('.')
        let l:start = col('.') - 1
        while l:start > 0 && l:line[l:start - 1] !~# '\s'
            let l:start -= 1
        endwhile
        return l:start
    else
        if !executable('rg')
            echom 'Ripgrep not found in path'
            return []
        endif
        if !exists('b:mobythesaurus_file')
            return []
        else
            " First version is loose matching and second [default] is tight check fot yourself
            " rg -N "^([\\w\\s]+)?samolot([\\w\\s]+)?" .vim/spell/pl.thes.txt | tr ',' '\n'
            if g:mobythesaurus_mode
                " match word anywhere in the line
                let l:query ="rg -wN --color never " . tolower(a:base) . " " . b:mobythesaurus_file . "| tr \",\" \"\\n\" | awk \'{ if (\!($0 in seen)) print $0; seen[$0] = 1; }\'"
            else
                " match first word in the line
                let l:query ="rg -wN --color never \"^" . tolower(a:base) . "\" " . b:mobythesaurus_file . "| tr \",\" \"\\n\" "
            endif
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
