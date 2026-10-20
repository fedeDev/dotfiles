
# Default GitHub CLI to work; a checkout can select another host with
# git config --local gh.host github.com. Explicit GH_HOST takes precedence.
gh() {
  local host=${GH_HOST:-}
  if [[ -z $host ]]; then
    host=$(command git config --get gh.host 2>/dev/null) || host=''
    host=${host:-github.geo.apple.com}
  fi
  GH_HOST=$host command gh "$@"
}

# pwin launchers: p/p.gl (relassert), psan/psan.gl (asan), pdeb/pdeb.gl (debug).
# Headless variants add -nowin -nopwgl; .gl variants leave the window/GL on.
# All add -httpgpfs unless -nohttpgpfs is given.
# Uses the pwin dir of the checkout/worktree you are in, else ~/pwin (with a warning).
# Falls back to the next build dir when the preferred one is missing (with a warning).

_pwin_warn() { print -u2 -r -- $'\e[38;5;208m'"pwin: $*"$'\e[0m'; }

_pwin_root() {
  local d=$PWD
  while [[ $d != / && ! -f $d/pwin/pwin.c ]]; do d=${d:h}; done
  if [[ -f $d/pwin/pwin.c ]]; then
    print -r -- "$d/pwin"
  else
    _pwin_warn "not in a pwin worktree, using ~/pwin"
    print -r -- "$HOME/pwin"
  fi
}

_pwin_run() {  # _pwin_run <gl|nogl> <build dirs...> -- <args...>
  local mode=$1; shift
  local -a dirs; while [[ $1 != -- ]]; do dirs+=$1; shift; done; shift
  local root; root=$(_pwin_root) || return 1
  local d bin
  for d in $dirs; do
    [[ -x $root/build/$d/pwin ]] || continue
    bin=$root/build/$d/pwin
    [[ $d != $dirs[1] ]] && _pwin_warn "build/$dirs[1] missing in $root, using build/$d"
    break
  done
  [[ -n $bin ]] || { print -u2 "pwin: no binary in $root/build/{${(j:,:)dirs}}"; return 1; }
  local -a flags
  [[ $mode == nogl ]] && flags+=(-nowin -nopwgl)
  (( ${@[(Ie)-nohttpgpfs]} )) || (( ${@[(Ie)-httpgpfs]} )) || flags+=(-httpgpfs)
  "$bin" $flags "$@"
}

p()        { _pwin_run nogl relassert release -- "$@"; }
p.gl()     { _pwin_run gl   relassert release -- "$@"; }
psan()     { _pwin_run nogl asan relassert release -- "$@"; }
psan.gl()  { _pwin_run gl   asan relassert release -- "$@"; }
pdeb()     { _pwin_run nogl debug relassert release -- "$@"; }
pdeb.gl()  { _pwin_run gl   debug relassert release -- "$@"; }
