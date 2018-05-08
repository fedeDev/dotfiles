" Adds a window pane that shows the classes and methods on buffer.
" Plug 'majutsushi/tagbar'
let g:tagbar_sort = 0
let g:tagbar_width = 46
let g:tagbar_autofocus = 1
" This is just the default definition for c++ files.
nnoremap <F4> :TagbarToggle<cr><c-w>=
