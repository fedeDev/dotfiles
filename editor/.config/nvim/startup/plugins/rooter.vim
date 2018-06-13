if exists('g:loaded_rooter_after_custom')
  finish
endif
let g:loaded_rooter_after_custom = 1

function! ChangeToRootDir()
  echohl WarningMsg
  Rooter
  echohl None
endfunction
nnoremap <silent> <leader>rp :call ChangeToRootDir()<cr>

" Switch to the directory of the open buffer.
function! ChangeToBufferDir()
  execute ':cd %:p:h'
  echohl WarningMsg | echom 'cwd: '.expand('%:p:h') | echohl None
endfunction
noremap <leader>cd :call ChangeToBufferDir()<cr>
let g:rooter_manual_only = 1
