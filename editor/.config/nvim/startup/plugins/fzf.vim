" Fzf fuzzy finder for files, tags, and output of rg, ag, etc.
" Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
" Funcionality to integrate fzf to various vim concepts.
" Plug 'junegunn/fzf.vim'
if exists('g:loaded_fzf_after_custom')
  finish
endif
let g:loaded_fzf_after_custom = 1

let g:rg_flags = ' --column --line-number --no-heading --color=always
  \ --colors="match:fg:blue" --colors="path:fg:yellow" '
command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg'.g:rg_flags.shellescape(<q-args>), 1,
  \   <bang>0 ? fzf#vim#with_preview('up:60%')
  \           : fzf#vim#with_preview('right:50%:hidden', '?'),
  \   <bang>0)
command! -bang -nargs=* GRg
  \ call fzf#vim#grep(
  \   'rg'.g:rg_flags.shellescape(<q-args>).' '.FindRootDirectory(), 1,
  \   <bang>0 ? fzf#vim#with_preview('up:60%')
  \           : fzf#vim#with_preview('right:50%:hidden', '?'),
  \   <bang>0)
nnoremap <silent> tt :Files<cr>
nnoremap <silent> tT :GFiles --cached --others --exclude-standard<cr>
nnoremap <silent> tb :Buffers<cr>
nnoremap <leader>g :Rg <C-R><C-W>
nnoremap <leader>G :GRg <C-R><C-W>
nnoremap <leader>h :FZF -1 -e --query=%:t:r\ !.%:e$<cr>
nnoremap <silent> tf :BTags<cr>
nnoremap <silent> tm :echom "Please do the MRU stuff"

function! s:Gutentags_sink(lines)
  normal! m'
  let qfl = []
  try
    for line in a:lines[0:]
      try
        let parts = split(line)
        execute 'e '.parts[1]
        execute matchstr(parts[2], '^[0-9]\+\ze;\?"')
        call add(qfl, {'filename': expand('%'),
                     \ 'lnum': line('.'), 'text': getline('.')})
      catch /^Vim:Interrupt$/
        break
      catch
        echom v:exception
      endtry
    endfor
  endtry
  if len(qfl) > 1
    call setqflist(qfl)
    copen
    wincmd p
    clast
  endif
  normal! zz
endfunction

function! s:gutentagfiles() abort
  if empty(tagfiles()) || !g:gutentags_enabled
    throw "Please enable and run vim-gutentags for the current project."
  endif
  return tagfiles()[0]
endfunction

" Souce -> all tags | remove first 8 lines | remove space after cpp operator | arrange into columns
" Sink -> multi select, only display tag, file and type of tag
command! -bang -nargs=* Gutentags call fzf#run(fzf#wrap('gutags',
      \ {'source' : 'cat '.<sid>gutentagfiles().' | tail -n +8 | sed "s|^operator |operator|g" | column -t',
      \  'sink*' : function('s:Gutentags_sink'),
      \  'options' : '-m --tiebreak=begin --with-nth ..2,4.. --prompt "'.&ft.'-Tags> " --query '.fzf#shellescape(<q-args>)},
      \ <bang>0))
nnoremap <silent> tF :Gutentags<cr>

" Respect colorscheme.
function! s:update_fzf_colors()
  let rules =
  \ { 'fg':      [['Normal',       'fg']],
    \ 'bg':      [['Normal',       'bg']],
    \ 'hl':      [['Comment',      'fg']],
    \ 'fg+':     [['CursorColumn', 'fg'], ['Normal', 'fg']],
    \ 'bg+':     [['CursorColumn', 'bg']],
    \ 'hl+':     [['Statement',    'fg']],
    \ 'info':    [['PreProc',      'fg']],
    \ 'prompt':  [['Conditional',  'fg']],
    \ 'pointer': [['Exception',    'fg']],
    \ 'marker':  [['Keyword',      'fg']],
    \ 'spinner': [['Label',        'fg']],
    \ 'header':  [['Comment',      'fg']] }
  let cols = []
  for [name, pairs] in items(rules)
    for pair in pairs
      let code = synIDattr(synIDtrans(hlID(pair[0])), pair[1])
      if !empty(name) && code > 0
        call add(cols, name.':'.code)
        break
      endif
    endfor
  endfor
  let s:orig_fzf_default_opts = get(s:, 'orig_fzf_default_opts', $FZF_DEFAULT_OPTS)
  let $FZF_DEFAULT_OPTS = s:orig_fzf_default_opts .
        \ empty(cols) ? '' : (' --color='.join(cols, ','))
endfunction

augroup fzf_setup
  autocmd!
  autocmd VimEnter,ColorScheme * call <sid>update_fzf_colors()
  " Hide status bar while using fzf commands                                                                          
  autocmd  FileType fzf 
        \ set laststatus=0 | autocmd WinLeave <buffer> set laststatus=2                               
augroup END
