" Make T,t,F,t behave a bit smarter.
" Plug 'rhysd/clever-f.vim'
if exists('g:loaded_clever_f_after_custom')
  finish
endif
let g:loaded_clever_f_after_custom = 1

let g:clever_f_across_no_line = 1
let g:clever_f_smart_case = 1
let g:clever_f_not_overwrites_standard_mappings = 1
nmap f <Plug>(clever-f-f)
xmap f <Plug>(clever-f-f)
omap f <Plug>(clever-f-f)
nmap F <Plug>(clever-f-F)
xmap F <Plug>(clever-f-F)
omap F <Plug>(clever-f-F)
xmap t <Plug>(clever-f-t)
omap t <Plug>(clever-f-t)
xmap T <Plug>(clever-f-T)
omap T <Plug>(clever-f-T)
