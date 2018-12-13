" Tag managment.
" Plug 'ludovicchabant/vim-gutentags'
if exists('g:loaded_gutentags_after_custom')
  finish
endif
let g:loaded_gutentags_after_custom = 1

let g:gutentags_enabled = 0
let g:gutentags_exclude_project_root =
      \ ['/usr/lib', '/usr/local/lib']
let g:gutentags_project_root = ['compile_commands.json']
function! s:SetupTags()
  let g:gutentags_enabled = 1
  let g:gutentags_ctags_exclude = ['docs', 'doc', 'build']
  let g:gutentags_cache_dir = '/Users/fcamposeco/.cache/gutentags'
  let g:gutentags_ctags_tagfile = &ft.'-tags'
  " Output line number instead of pattern and do full name tag type (K vs k).
  let g:gutentags_ctags_extra_args = ['--fields=-k+K-f-t-l-s', '-n']
endfunction

function! s:SetupCPPTags()
  call s:SetupTags()
  call add(g:gutentags_ctags_extra_args, '--languages=c++')
  call add(g:gutentags_ctags_extra_args,  '--c++-kinds=defghmstuvcx')
  call add(g:gutentags_ctags_extra_args,  '--langmap=c++:.cc.cpp.h.hpp')
endfunction
function! s:SetupPythonTags()
  call s:SetupTags()
  call add(g:gutentags_ctags_extra_args, '--languages=python')
endfunction
function! s:SetupFortranTags()
  call s:SetupTags()
  call add(g:gutentags_ctags_extra_args, '--languages=fortran')
  nnoremap <silent> g. <C-]>
endfunction

augroup TagsFiletype
  autocmd!
  autocmd FileType cpp call <sid>SetupCPPTags()
  autocmd FileType python call <sid>SetupPythonTags()
  autocmd FileType fortran call <sid>SetupFortranTags()
augroup END
