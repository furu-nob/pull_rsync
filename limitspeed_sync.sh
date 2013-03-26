#!/bin/sh

#
# usage
# crontab -l
# 0 8  * * 1,2,3,4,5 /root/scripts/pullbackup/limitspeed_sync.sh 400
# 0 19 * * 1,2,3,4,5 /root/scripts/pullbackup/limitspeed_sync.sh 0
#

PULL_RSYNC_PATH='/root/scripts/pullbackup/pull_rsync_bw.sh'
REMOTE_SERVER='example.co.jp'
REMOTE_DIR='/media/backup/backup'
LOCAL_DIR='/mnt/disk/6/backup/example/rsync'

BANDWIDTH=$1

function show_help {
        echo "****************"
        echo "$0 usage"
        echo "****************"
        echo ""
        echo "\$ $0 BANDWIDTH"
        echo "** If BANDWIDTH=0 Unlimit!! **"
        echo ""
}

if [ $# -eq 0 ]
then
  show_help
  exit 1
fi

/usr/bin/pkill -u root rsync
sleep 30
$PULL_RSYNC_PATH $REMOTE_SERVER $REMOTE_DIR $LOCAL_DIR $BANDWIDTH &

