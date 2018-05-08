" Interface with Language Server Protocols.
" Plug 'autozimu/LanguageClient-neovim', {
"     \     'for' : ['c', 'cpp'],
"     \  'branch' : 'next',
"     \      'do' : 'bash install.sh',
"     \ }
if exists('g:loaded_language_client_after_custom')
  finish
endif
let g:loaded_language_client_after_custom = 1

      " \ 'cpp': [$HOME.'/build/cquery/build/release/bin/cquery',
" let g:LanguageClient_serverCommands = {
"     \ 'cpp': [$HOME.'/build/cquery_testing/cquery/build/release/bin/cquery',
"     \ '--log-file=/tmp/cq.log', '--record=/tmp/cquery',
"     \ '--init={"completion": {"filterAndSort": false}}'] } 
let g:LanguageClient_serverCommands = { 'cpp': ['clangd-6.0'] } 
" Use an absolute configuration path if you want system-wide settings 
" let g:LanguageClient_loadSettings = 1
" let g:LanguageClient_settingsPath =
"       \ $HOME.'/.config/nvim/settings.json'
" let g:LanguageClient_loggingLevel = 'DEBUG'
function! LanguageClient_config_cpp()
  setlocal completefunc=LanguageClient#complete
  " setlocal formatexpr=LanguageClient_textDocument_rangeFormatting()
  " nn <buffer><silent> gs :call LanguageClient_textDocument_documentSymbol()<CR>
  nn <buffer><silent> g? :call LanguageClient_textDocument_hover()<CR>
  nn <buffer><silent> g. :call LanguageClient_textDocument_definition()<CR>
  nn <buffer><silent> <C-]> :call LanguageClient_textDocument_definition()<CR>
  nn <buffer><silent> gr :call LanguageClient_textDocument_references()<CR>
  nn <buffer><silent> <F2> :call LanguageClient_textDocument_rename()<CR>
endfunction

augroup LanguageClient_config
  autocmd!
  autocmd User LanguageClientStarted call LanguageClient_config_cpp()
augroup END
