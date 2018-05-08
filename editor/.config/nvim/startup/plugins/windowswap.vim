" Swap windows with <leader>W
" Plug 'wesQ3/vim-windowswap'
let g:windowswap_map_keys = 0 "prevent default bindings
nnoremap <silent> <leader>W :call WindowSwap#EasyWindowSwap()<CR>
