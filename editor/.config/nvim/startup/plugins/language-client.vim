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

" let g:LanguageClient_serverCommands = {
"     \ 'cpp': [$HOME.'/build/cquery_testing/cquery/buildcmake/release/bin/cquery',
"     \ '--log-file=/tmp/cq.log', '--record=/tmp/cquery',
"     \ '--init={"completion": {"filterAndSort": false}}'] } 
" let g:LanguageClient_serverCommands = { 'cpp': ['clangd-6.0'] } 
" Use an absolute configuration path if you want system-wide settings 
" let g:LanguageClient_loadSettings = 1
" let g:LanguageClient_settingsPath =
"       \ $HOME.'/.config/nvim/settings.json'
" let g:LanguageClient_loggingLevel = 'DEBUG'
" let g:LanguageClient_loggingFile = '/tmp/caca'
let g:LanguageClient_rootMarkers = ['TRIGGER_TESTS']

let g:LanguageClient_serverCommands = {
    \ 'c': ['ccls', '--log-file=/tmp/cc.log'],
    \ 'cpp': ['ccls'],
    \ 'cuda': ['ccls', '--log-file=/tmp/cc.log'],
    \ 'objc': ['ccls', '--log-file=/tmp/cc.log'],
    \ }

let g:LanguageClient_loadSettings = 1 " Use an absolute configuration path if you want system-wide settings
let g:LanguageClient_settingsPath = $HOME.'/.config/nvim/settings.json'
" https://github.com/autozimu/LanguageClient-neovim/issues/379 LSP snippet is not supported
let g:LanguageClient_hasSnippetSupport = 0

function! LanguageClient_config_cpp()
  setlocal completefunc=LanguageClient#complete
  " setlocal formatexpr=LanguageClient_textDocument_rangeFormatting()
  " nn <buffer><silent> gs :call LanguageClient_textDocument_documentSymbol()<CR>
  nn <buffer><silent> gm :call LanguageClient_contextMenu()<CR>
  nn <buffer><silent> g? :call LanguageClient_textDocument_hover()<CR>
  nn <buffer><silent> g. :call LanguageClient_textDocument_definition()<CR>
  nn <buffer><silent> gr :call LanguageClient_textDocument_references()<CR>
  nn <silent> gR :call LanguageClient#textDocument_references({'includeDeclaration': v:false})<cr>
endfunction

augroup LanguageClient_config
  au!
  autocmd User LanguageClientStarted call LanguageClient_config_cpp()
  au BufEnter * let b:Plugin_LanguageClient_started = 0
  au User LanguageClientStarted setl signcolumn=yes
  au User LanguageClientStarted let b:Plugin_LanguageClient_started = 1
  " au User LanguageClientStopped setl signcolumn=auto
  au User LanguageClientStopped let b:Plugin_LanguageClient_stopped = 0
  " au CursorMoved * if b:Plugin_LanguageClient_started | sil call LanguageClient#textDocument_documentHighlight() | endif
augroup END

