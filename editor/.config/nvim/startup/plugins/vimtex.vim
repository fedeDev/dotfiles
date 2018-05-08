" Everything we need and want for \latex.
" Plug 'lervag/vimtex', { 'for' : 'tex' }
if exists('g:loaded_vimtex_after_custom')
  finish
endif
let g:loaded_vimtex_after_custom = 1

augroup LatexVimtex
  autocmd!
  autocmd User VimtexEventInitPost call VimTexSetup()
augroup END

function! VimTexSetup()
  " Main settings.
  let g:tex_flavor = 'latex'
  let g:vimtex_compiler_progname = 'nvr'
  let g:vimtex_quickfix_open_on_warning = 0
  " let g:vimtex_view_automatic = 0
  let g:vimtex_view_general_viewer = 'qpdfview'
  let g:vimtex_view_general_options = '--unique @pdf\#src:@tex:@line:@col'
  let g:vimtex_view_general_options_latexmk = '--unique'
  let g:vimtex_imaps_enabled = 0
  let g:vimtex_format_enabled = 1
  let g:vimtex_index_split_width = 50

  " Define some more convenient mappings.
  nmap <silent><buffer> <leader>C <plug>(vimtex-compile)
  nmap <silent><buffer> <leader>c <plug>(vimtex-compile-ss)
  nmap <silent><buffer> <leader>t <plug>(vimtex-toggle-main)
  nmap <silent><buffer> <leader>v <plug>(vimtex-view)
  nmap <silent><buffer> <F11> <plug>(vimtex-labels-toggle)
  nmap <silent><buffer> <F12> <plug>(vimtex-toc-toggle)

  " Interoperation with deoplete and airline.
  if !exists('g:deoplete#omni#input_patterns')
      let g:deoplete#omni#input_patterns = {}
  endif
  let g:deoplete#omni#input_patterns.tex = g:vimtex#re#deoplete
  " To add airline integration I had to do this hack, since for some reason
  " exists('*vimtex#init') is v:false when airline gets loaded.
  let s:ext = {}
  function! s:ext.add_statusline_func(name) dict
    call airline#add_statusline_func(a:name)
  endfunction
  let g:airline#extensions#vimtex#enabled = 1
  call airline#extensions#vimtex#init(s:ext)
  let g:airline#extensions#vimtex#left = "vimtex → "
  let g:airline#extensions#vimtex#right = ""
  let g:airline#extensions#vimtex#main = "@root"
  let g:airline#extensions#vimtex#sub_main = "@sub: main"
  let g:airline#extensions#vimtex#sub_local = "@sub: local"
  let g:airline#extensions#vimtex#compiled = ""
  let g:airline#extensions#vimtex#continuous = " ↺ "
  let g:airline#extensions#vimtex#viewer = " viewing"
endfunction

" let g:vimtex_compiler_method = 'latexrun'
" let g:vimtex_compiler_latexrun = {
"       \ 'backend' : 'nvim',
"       \ 'background' : 1,
"       \ 'build_dir' : 'latex.out',
"       \ 'options' : [
"       \   '--verbose-cmds',
"       \   '--latex-args="-synctex=1"',
"       \ ],
"       \}
" let g:vimtex_compiler_callback_hooks = ['MyLatexHook']
" function! MyLatexHook(status) 
"   echom "Compilation finished. Status: ".a:status 
" endfunction
