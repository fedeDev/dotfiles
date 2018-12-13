" Autocompletion manager
" Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
if exists('g:loaded_ncm2_after_custom')
  finish
endif
let g:loaded_ncm2_after_custom = 1

autocmd BufEnter  *  call ncm2#enable_for_buffer()
" Affects the visual representation of what happens after you hit <C-x><C-o>
" https://neovim.io/doc/user/insert.html#i_CTRL-X_CTRL-O
" https://neovim.io/doc/user/options.html#'completeopt'
"
" This will show the popup menu even if there's only one match (menuone),
" prevent automatic selection (noselect) and prevent automatic text injection
" into the current line (noinsert).
set completeopt=noinsert,menuone,noselect


" let g:deoplete#enable_at_startup = 1
" " Assuming one uses <C-U> for expanding a snippet.
inoremap <expr> <CR> (pumvisible() ? "\<c-y>" : "\<CR>")
" Cycle completions with tabs and C-j/k.
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <C-j> pumvisible() ? "\<C-n>" : "\<C-j>"
inoremap <expr> <C-k> pumvisible() ? "\<C-p>" : "\<C-k>"
inoremap <C-Space> <C-x><C-o>
