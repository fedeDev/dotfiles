envfile="${HOME}/.gnupg/gpg-agent.env"
if test -f "$envfile" && kill -0 $(grep GPG_AGENT_INFO "$envfile" | cut -d: -f 2) 2>/dev/null; then
    eval "$(cat "$envfile")"
else
    eval "$(gpg-agent --daemon --write-env-file "$envfile")"
fi
export GPG_AGENT_INFO  # the env file does not contain the export statement
[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec xinit -- :1 -nolisten tcp vt$XDG_VTNR
