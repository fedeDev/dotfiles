augroup FiletypeTweaks
  autocmd!
  " Deactivate cindent for more simple text files.
  autocmd FileType mail,tex,plaintex,text,markdown,gitcommit set textwidth=0
  " Return to last edit position when opening files.
  autocmd BufReadPost *
        \ if line("'\"") > 0 && line("'\"") <= line("$") |
        \   exe "normal! g`\"" |
  " Set spellcheck for git commits always.
  autocmd FileType gitcommit,tex setlocal spell! spelllang=en_us
augroup END
