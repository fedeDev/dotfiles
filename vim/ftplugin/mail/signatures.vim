"
" Plugin to insert signature (long or short) only when instructed to
"
"
if exists("b:loaded_MuttMail_plugin")
   finish
endif
let b:loaded_MuttMail_plugin = 1

" Options
let g:MuttNoSignatureRemoval = 1
let g:MuttSigFile = '~/.mutt/signature'
let g:MuttSigLines = 1

if ! exists('g:MuttSigLines')
  let g:MuttSigLines=2
else 
  let g:MuttSigLines=g:MuttSigLines+1
endif

" Insert long or short signature
nnoremap <buffer> <localleader>ss :call InsertSignature(1)<cr>
nnoremap <buffer> <localleader>sl :call InsertSignature(0)<cr>
nnoremap <buffer> <localleader>S :call RemoveMySig()<cr>

function! MuttStripSig()
    normal mx
    execute "silent g/^-- $/+" . g:MuttSigLines . ",$d"
    echom "Removed Signature tail after " . g:MuttSigLines . " lines"
    normal `x
endfu

" Function to remove the signature
function! RemoveMySig()
    silent g/^--\s\=$/-1,$d
endfu

function! InsertSignature(...)
    normal! mx
    call RemoveMySig()
    normal! Go-- 
    execute "read " . g:MuttSigFile
    normal! 'x
    if a:1 == 1
        call MuttStripSig()
    endif
endfunction

" function GetRecipient()
"     let toline = search("^To:")
"     let line = getline(toline)
"     let stuff = split(line)
"
"     return stuff[1]
" endfu

