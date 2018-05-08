" Clang style.
" Plug 'sbdchd/neoformat', {'for' : ['cpp', 'fortran', 'python']}
if exists('g:loaded_neoformat_after_custom')
  finish
endif
let g:loaded_neoformat_after_custom = 1

let g:neoformat_python_yapf = {'exe' : 'yapf', 'args' : ['--style=chromium'],
                             \ 'valid_exit_codes' : [0, 2]}
let g:neoformat_enabled_python = ['yapf']
augroup NeoformatFiletypes
  autocmd!
  autocmd FileType cpp nnoremap <silent><buffer> <leader>f :Neoformat clangformat<CR>
  autocmd FileType cpp vnoremap <silent><buffer> <leader>f :Neoformat clangformat<CR>
  autocmd FileType fortran let &l:formatprg = 'fprettify --silent -i 2 -w 2'
  autocmd FileType fortran let g:neoformat_try_formatprg = 1
  autocmd FileType fortran nnoremap <silent><buffer> <leader>f :Neoformat<CR>
  autocmd FileType fortran vnoremap <silent><buffer> <leader>f :Neoformat<CR>
  autocmd FileType python nnoremap <silent><buffer> <leader>f :Neoformat<CR>
  autocmd FileType python vnoremap <silent><buffer> <leader>f :Neoformat<CR>
augroup END


