" Tip: Place the cursor in the optimal position, editing email messages.
" Author: Davide Alberani
" Version: 0.1.1
" Modified: Federico Camposeco, 2014
" Date: 24 May 2006
" Description: if you use Vim to edit your emails, having to manually

" Function used to identify where to place the cursor, editing an email.
function FirstInPost (...) range
  let cur = a:firstline
  while cur <= a:lastline
    let str = getline(cur)
    " Found an _empty_ subject in the headers.
    " NOTE: you can put similar checks to handle other empty headers
    " like To, From, Newgroups, ...
    if strlen(matchstr(str, '^Subject:\s*$')) > 0
      execute cur
      :start!
      break
    endif
    " We have reached the end of the headers.
    if str == ''
      let cur = cur + 1
      " If the first line of the body is an attribution, put
      " the cursor _before_ that line, otherwise the cursor is
      " leaved right after the headers (assuming we're writing
      " a new mail, and not editing a reply).
      " NOTE: modify the regexp to match your mail client's attribution!
      if strlen(matchstr(getline(cur), '^On.*wrote:.*')) > 0
        let cur = cur - 1
      endif
      execute cur
      :start
      break
    endif
    let cur = cur + 1
  endwhile
endfunction

" Command to be called with mutt's editor setting
com Fip :set tw=0<Bar>:%call FirstInPost()
