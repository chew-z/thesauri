Thesauri
--------

So I had been using [thesauri](http://github.com/tomku/thesauri) plugin for over two years and making some small adjustments. Finally I have decided to fork and commit my take.

## Installation

Using [vim-plug](https://github.com/junegunn/vim-plug):

`Plug 'chew-z/thesauri' `

## Requirements

- You should have [ripgrep](https://github.com/BurntSushi/ripgrep) installed and added to path, otherwise Thesauri will fail silently.
- Thesauri expects to find thesaurus files at $HOME/.vim/spell/[LANGUAGE].thes.txt

## Mapping keys

In Insert mode Control+L <C-l> toggles available languages

## Global variables

`g:thesauri_languages - default ['', 'pl', 'en'] - available languages`

`g:thesauri_filetypes - default ['text', 'markdown', 'mail', 'notes'] - file formats for which thesauri could be activated`

`g:thesauri_map_key - default 1 - use thesauri key mappings (<C-l>)`

`g:thesauri_mode - default 0 - toggle between tight matching and more loose one`

## How it works?

Thesauri sets omnifunc = thesauri#OmniThesauri locally per buffer. So it is possible to open multiple buffers with different languages. Imagine writing README file in English, having open mail in your native language and some documentation where you don't won't highlighte misspellings or any other language features.

Thesaurus suggestions are under <C-xC-o> in insert mode leaving default Vim thesaurus shortcut <C-xC-t> untouched. There are [reasons for that](https://github.com/vim/vim/issues/1611) - Vim expects format that isn't compatible with most thesaurus files and Vim's thesaurus function cannot be modified.

You can also have suggestions under <Tab> using some version of CleverTab function.

```viml
function! CleverTab()
    if pumvisible()
        return "\<C-n>"
    endif
    let l:col = col('.') - 1
    if !l:col || getline('.')[l:col - 1] !~# '\k'
        return "\<Tab>"
    elseif col('.')>1 && strpart( getline('.'), col('.')-2, 3 ) =~# '^\w'
        if exists('&omnifunc') && &omnifunc ==# 'thesauri#OmniThesauri'
            return "\<C-x>\<C-o>"
        else
            return "\<C-r>=completor#do('complete')\<CR>"
        endif
    endif
endfunction
```

