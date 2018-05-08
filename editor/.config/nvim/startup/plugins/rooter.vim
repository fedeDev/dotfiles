if exists('g:loaded_rooter_after_custom')
  finish
endif
let g:loaded_rooter_after_custom = 1

function! ChangeToRootDir()
  echohl Title | Rooter | echohl None
endfunction
nnoremap <silent> <leader>rp :call ChangeToRootDir()<cr>
let g:rooter_manual_only = 1
