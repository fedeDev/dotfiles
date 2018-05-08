if exists('g:loaded_ale_after_custom')
  finish
endif
let g:loaded_ale_after_custom = 1

" Some other nice signs: ⌦ ⌧ • ‣ → ╳ ☓ ☒ ☑ ✓ ✔ ✕ ✖ ✗ ✘ ✕ ︕ •●
let g:ale_sign_error = '✕'
let g:ale_sign_warning = '•'
highlight ALEWarningSign ctermfg=Yellow
highlight ALEErrorSign ctermfg=Red
" My gcc -x f95 command does not work, but it does for gfortran.
let g:ale_fortran_gcc_executable = 'gfortran'
let g:airline#extensions#ale#enabled = 1
let g:ale_linters = {'cpp' : ['cpplint'], 'python' : ['pylint']}
let g:ale_cpp_cpplint_options = '--filter=-build/c++11,-build/include_order'
let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'
let g:ale_python_pylint_options = '--rcfile=~/.google-pylint.rc'
