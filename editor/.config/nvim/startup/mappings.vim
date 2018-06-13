" To be loaded from our vimrc/init.nvim.
let mapleader=","
let maplocalleader=" "
" Create whitespace.
nnoremap <silent> zj o<Esc>k
nnoremap <silent> zk O<Esc>j
nnoremap <silent> zl >>
nnoremap <silent> zh <<
nnoremap <silent> <space> i<space><esc>
" Scroll through command history from home row.
cnoremap <c-j> <down>
cnoremap <c-k> <up>
" In normal mode, we use : much more often than ; so lets swap them.
nnoremap ; :
nnoremap : ;
vnoremap ; :
vnoremap : ;
" This makes j and k work on 'screen lines' instead of on 'file lines'.
nnoremap <silent> j gj
nnoremap <silent> k gk
" Use arrows to resize windows.
noremap <up>    <C-W>+
noremap <down>  <C-W>-
noremap <left>  3<C-W><
noremap <right> 3<C-W>>

" Get spelling suggestions.
noremap <leader>s<leader> z=
" Toggle and untoggle spell checking.
noremap <leader>ss :setlocal spell! spelllang=en_us<cr>
" Remain in visual mode after indenting selection.
vnoremap < <gv
vnoremap > >gv
" Go to next buffer easily.
nnoremap <silent> <tab> :bn <CR>
nnoremap <silent> <S-tab> :bp <CR>
" Fast saving.
nnoremap <silent> <leader>w :w<cr>
" Map 0 to the first character and viceversa.
nnoremap 0 ^
nnoremap ^ 0
" Fast exit
noremap <silent> <leader>q :q<cr>
noremap <silent> <leader>x :x<cr>
" Show full path on the command line when pressing <C-G>
function! ShowFilePath()
  echohl Title | echom 'File path: '.expand('%:p') | echohl None
endfunction
nnoremap <silent> <C-G> :call ShowFilePath()<CR>
" Visually select text that was last edited/pasted.
noremap gV `[v`]
" Easily close the preview window. Opened sometimes for symbol documentation.
nnoremap <silent> tp :pc<cr>
" As with D and C, yank only from cursor til EOL.
nnoremap Y y$
" Exit visual mode with q.
vnoremap q <Esc>

