" Autocompletion manager
" Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
if exists('g:loaded_deoplete_after_custom')
  finish
endif
let g:loaded_deoplete_after_custom = 1

let g:deoplete#enable_at_startup = 1
" Assuming one uses <C-U> for expanding a snippet.
inoremap <expr> <CR> (pumvisible() ? "\<c-y>" : "\<CR>")
" Cycle completions with tabs and C-j/k.
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <C-j> pumvisible() ? "\<C-n>" : "\<C-j>"
inoremap <expr> <C-k> pumvisible() ? "\<C-p>" : "\<C-k>"
inoremap <C-Space> <C-x><C-o>
