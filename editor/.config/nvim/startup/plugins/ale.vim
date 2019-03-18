if exists('g:loaded_ale_after_custom')
  " finish
endif
let g:loaded_ale_after_custom = 1

" Some other nice signs: ⌦ ⌧ • ‣ → ╳ ☓ ☒ ☑ ✓ ✔ ✕ ✖ ✗ ✘ ✕ ︕ •●
let g:ale_sign_error = '✕'
let g:ale_sign_warning = '•'
highlight ALEWarningSign ctermfg=Yellow
highlight ALEErrorSign ctermfg=Red

let g:airline#extensions#ale#enabled = 1
"
let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'
let g:ale_linters = {'python': ['flake8']}
let g:ale_python_flake8_executable = '/usr/local/Cellar/flake8/3.7.7/bin/flake8'
let g:ale_fixers = {'python': ['autopep8']}
" let g:ale_python_flake8_options = ' --config /Users/fcamposeco/ovrsource/Software/CoreTech/.flake8'
" let g:ale_python_autopep8_options = ' --global-config /Users/fcamposeco/ovrsource/Software/CoreTech/.flake8'


" My gcc -x f95 command does not work, but it does for gfortran.
" let g:ale_fortran_gcc_executable = 'gfortran'
