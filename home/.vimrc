set ruler
set list
set expandtab
set tabstop=2
set shiftwidth=2
set softtabstop=2
set autoindent
set hlsearch
set list
set listchars=tab:>-,trail:-
:vnoremap < <gv
:vnoremap > >gv
:highlight RedundantSpaces ctermbg=red guibg=red
:match RedundantSpaces /\s\+$\| \+\ze\t/
sy on
cmap w!! %!sudo tee > /dev/null %


"set fileencodings=koi8-r,utf8

"TIPS
"ctrl-n/ctrl-p -autocomplete :)
"
":e! Reopen the current file, getting rid of any unsaved changes.
"
"[I  list all lines found in current and included files that contain the word
"under the cursor.
"
"gg=G fix identation
autocmd BufRead *.hx set filetype=actionscript
