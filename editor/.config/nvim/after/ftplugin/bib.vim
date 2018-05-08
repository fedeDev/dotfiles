" Capizalize titles in bibtex after ':', or any start of word not in the list.
function! s:capitalizeBibF()
  .v/^@/s/\v\:\s\a|<%(year>\=\{|pages>\=\{|number>\=\{|volume>\=\{|journal>\=\{|booktitle>\=\{|author>\=\{|journal>\=\{|publisher>\=\{|title>\=\{|in>|the>|at>|with>|a>|and>|for>|of>|on>|from>|by>)@!\a/\U&/g
endfunction

function! s:capitalizeBibTitlesF()
  g/^\s*.itle/s/\v\:\s\a|<%(year>\=\{|pages>\=\{|number>\=\{|volume>\=\{|journal>\=\{|booktitle>\=\{|author>\=\{|journal>\=\{|publisher>\=\{|title>\=\{|in>|the>|at>|with>|a>|and>|for>|of>|on>|from>|by>)@!\a/\U&/g
endfunction

command! CapitalizeBibLine call s:capitalizeBibF()
command! CapitalizeAllTitlesBib call s:capitalizeBibTitlesF()
