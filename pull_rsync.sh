#!/bin/sh

#RSYNC='/usr/bin/rsync -auvz -e ssh --delete --dry-run'
#RSYNC='/usr/bin/rsync -auvz --progress -e "ssh" --rsync-path="/usr/bin/sudo /usr/bin/rsync" --delete --dry-run'
#RSYNC='/usr/bin/rsync -auvz -e ssh --rsync-path="/usr/bin/sudo /usr/bin/rsync $*" --delete --dry-run'
RSYNC='/usr/bin/rsync -auvz -e ssh --rsync-path="/home/hogehoge/scripts/rsync.sh" --delete --dry-run'

REMOTE_USER='hogehoge'

# リモートのサーバとそのpath
REMOTE_SERVER=$1
REMOTE_PATH=$2

ME=`echo $REMOTE_SERVER |sed -e "s/\./_/g"`

# ローカルのバックアップ先
LOCAL_DESTINATION=$3

# メールの送り先
mailadd=furuyama@example.net
# メールの題名
subject="${ME}_pull_backup_rdiff"

# ログファイル
log="/var/log/${ME}_rdiff_pull_backup.log"

# Del older file
older=1M

# Lock File
_lockfile="/tmp/${ME}_`basename $0`.lock"
ln -s /dummy $_lockfile 2> /dev/null || { echo "$0 Cannot run multiple instance." | mail -s "Error_$subject" $mailadd && echo "$0 Cannot run multiple instance." >&2; exit 9; }
trap "rm $_lockfile; exit" 1 2 3 15
# /Lock File

function backupdir {
  REMOTEDIR=$1
  LOCALDIR=$2

  # mktemp
  temp_file=`mktemp /tmp/temp.XXXXXX`

  echo '---------------8<------------------' >> $temp_logfile
  echo "start(From $REMOTEDIR To $LOCALDIR) : "`date +%Y-%m-%d-%k:%M.%S` >> $temp_logfile

  ${RSYNC} ${REMOTE_USER}@${REMOTEDIR}/ ${LOCALDIR}/ >> $temp_logfile
  if [ $? != 0 ]; then
    echo "It failed in the backup.($REMOTEDIR)" >> $temp_logfile
    echo "It failed in the backup.($REMOTEDIR)" | mail -s "error_$subject" $mailadd
  else
    echo `date +%Y-%m-%d-%k:%M.%S` >> $temp_file
    echo "From ${ME}:$REMOTEDIR" >> $temp_file
    echo "To $LOCALDIR" >> $temp_file
    scp $temp_file $LOCALDIR/../pull_rsync_date.txt
  fi
  rm $temp_file
  echo "finish($REMOTEDIR) : `date +%Y-%m-%d-%k:%M.%S`" >> $temp_logfile
}

function show_help {
  echo "****************"
  echo "$0 usage"
  echo "****************"
  echo ""
  echo "\$ $0 remote_server remote_dir local_dir"
  echo ""
}

if [ $# -ne 3 ]
then
  show_help
  exit 1
fi


temp_logfile=`mktemp /tmp/temp.XXXXXX`

# バックアップ実行
    #backupdir $REMOTE_USER@$REMOTE_SERVER:$REMOTE_PATH $LOCAL_DESTINATION
    backupdir $REMOTE_SERVER:$REMOTE_PATH $LOCAL_DESTINATION

cat $temp_logfile >> $log

# メールでログを飛ばす
cat $temp_logfile | mail -s "$subject" $mailadd
rm $temp_logfile

# UnLock
rm $_lockfile
# /UnLock
