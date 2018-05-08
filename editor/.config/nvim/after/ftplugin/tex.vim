" Replace '. ' with '.\n', i.e., split lines at punto y seguido.
function! SplitAtPeriodF()
  s/\.\ /\.\r/g
endfunction
command! SplitAtPeriod call SplitAtPeriodF()
