" Startup page.
" Plug 'mhinz/vim-startify'
if exists('g:loaded_startify_after_custom')
  finish
endif
let g:loaded_startify_after_custom = 1

let g:startify_session_persistence = 1
let g:startify_session_dir = '~/.config/nvim/sessions'
function! s:center_header(lines) abort
    let longest_line   = max(map(copy(a:lines), 'strwidth(v:val)'))
    let centered_lines = map(copy(a:lines),
        \ 'repeat(" ", (&columns / 2) - (longest_line / 2)) . v:val')
    return centered_lines
endfunction
let g:startify_custom_header = s:center_header(startify#fortune#boxed())
