#!/bin/bash
# Set all the neccesary environment variables
source '/home/fede/.gnupg/gpg-agent.env'
export GPG_AGENT_INFO
export HOME='/home/fede'

LOGFILE=${HOME}'/.offlineimap/log'
SERVICE='offlineimap'

ps -ef | grep -v grep | grep -v sh | grep -v SCREEN | grep /usr/bin/$SERVICE > /dev/null 2>&1
if [ $? -eq 1 ]
then
  echo "`date` $SERVICE will be started." >> ${LOGFILE}
  /usr/bin/offlineimap -c ${HOME}/.offlineimaprc >> ${LOGFILE} 2>&1
  echo "`date` $SERVICE started" >> ${LOGFILE}
else
  echo "`date` $SERVICE is up and running." >> ${LOGFILE}
fi
