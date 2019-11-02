" Status line.
" Plug 'vim-airline/vim-airline' | Plug 'vim-airline/vim-airline-themes'
if exists('g:loaded_airline_after_custom')
  finish
endif
let g:loaded_airline_after_custom = 1

let g:airline_mode_map = {
      \ 'n'  : 'N', 'i'  : 'I', 'v'  : 'V char',
      \ 'V'  : 'V line', '' : 'V blck' }
function! AirlineInit()
  let g:airline_section_c = ''
  " let g:airline_section_x = airline#section#create(['LC_status'])
  let g:airline_section_y = ''
  " airline#section#create(['filetype'])
  " let g:airline_section_error =
        " \ airline#section#create(['ale_error_count', 'LC_error_count'])
  let g:airline_symbols.spell = 'Ꞩ'
endfunction

" call airline#parts#define_function('LC_error_count', 'LC_error_count')
" call airline#parts#define_function('LC_status', 'LC_status')

" function! LC_error_count()
"   let count = len(getqflist())
"   if exists('g:LanguageClient_loaded') && count
"     if g:LanguageClient_loaded 
"       return 'E: ' . count
"     endif
"   endif
"   return ''
" endfunction
" function! LC_status()
"   if exists('g:LanguageClient_loaded') && g:LanguageClient_loaded
"     return LanguageClient#statusLine()
"   endif
"   return ''
" endfunction

let g:airline#extensions#coc#enabled = 1

augroup AirlineVimrc
  autocmd!
  autocmd User AirlineAfterInit call AirlineInit()
augroup END
let g:airline_powerline_fonts = 1
" No separators, they fugly and unnecessary.
let g:airline_left_sep=''
let g:airline_right_sep=''
" Unicode U+2502.
let g:airline_left_alt_sep = '│'
let g:airline_right_alt_sep = '│'
" Extensions
  let g:airline#extensions#anzu#enabled = 0
  let g:airline#extensions#wordcount#enabled = 0
  let g:airline#extensions#ale#show_line_numbers = 0
  let g:airline#extensions#whitespace#enabled = 0
  let g:airline#extensions#branch#format = 2
  let g:airline#extensions#hunks#non_zero_only = 1
  " Tabline.
  let g:airline#extensions#tabline#enabled = 1
  let g:airline#extensions#tabline#buffers_label = ''
  let g:airline#extensions#tabline#formatter = 'unique_tail_improved'
  let g:airline#extensions#tabline#fnamemod = ':t'
  " No separators for buffers.
  let g:airline#extensions#tabline#left_sep = ''
  let g:airline#extensions#tabline#left_alt_sep = ''
  let g:airline#extensions#tabline#right_sep = ''
  let g:airline#extensions#tabline#right_alt_sep = ''
  " Display numbers for buffers and quick jump using <leader>1, <leader>2, etc.
  let g:airline#extensions#tabline#buffer_idx_mode = 1
  nmap <leader>1 <Plug>AirlineSelectTab1
  nmap <leader>2 <Plug>AirlineSelectTab2
  nmap <leader>3 <Plug>AirlineSelectTab3
  nmap <leader>4 <Plug>AirlineSelectTab4
  nmap <leader>5 <Plug>AirlineSelectTab5
  nmap <leader>6 <Plug>AirlineSelectTab6
  nmap <leader>7 <Plug>AirlineSelectTab7
  nmap <leader>8 <Plug>AirlineSelectTab8
  nmap <leader>9 <Plug>AirlineSelectTab9
