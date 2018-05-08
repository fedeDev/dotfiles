" Serach enhancements
" Hihgligh search pattern while typing and nexting it.
" Plug 'haya14busa/is.vim'
" Enable visual mode '*' search.
" Plug 'haya14busa/vim-asterisk'
" Count number of matches.
" Plug 'osyo-manga/vim-anzu'
" Highligh current searched item.
" Plug 'inside/vim-search-pulse'
if exists('g:loaded_supersearch_after_custom')
  finish
endif
let g:loaded_supersearch_after_custom = 1

" Improved /-searching (anzu, asterisk and is.vim)
map *  <Plug>(asterisk-*)<Plug>(is-nohl-1)<Plug>Pulse
map g* <Plug>(asterisk-g*)<Plug>(is-nohl-1)<Plug>Pulse
map #  <Plug>(asterisk-#)<Plug>(is-nohl-1)<Plug>Pulse
map g# <Plug>(asterisk-g#)<Plug>(is-nohl-1)<Plug>Pulse
map n <Plug>(is-nohl)<Plug>(anzu-n-with-echo)<Plug>Pulse
map N <Plug>(is-nohl)<Plug>(anzu-N-with-echo)<Plug>Pulse
let g:vim_search_pulse_mode = 'pattern'
let g:vim_search_pulse_disable_auto_mappings = 1
