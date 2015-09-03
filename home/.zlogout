# Cleanup gpg key file and return crontab back
# cat /dev/null > $HOME/.gnupg/lock
# cat /dev/null > $HOME/.offlineimap/log
# crontab -l > /tmp/crontab.a
# sed -e 's=^\(.*/bin/imap-cron.sh$\)=#\1=g' /tmp/crontab.a | crontab
