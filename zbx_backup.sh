#!/bin/bash
DAY=`date +%m%d`
LOGFILE=/var/log/zabbix_backup.log
EMAIL=111@mail.ru
MAILFILE=/tmp/mailfile.tmp
BK_GLOBAL=/home/pi/backups
BK_DIR=$BK_GLOBAL/$DAY
#MYSQLCNF=/etc/mysql/my.cnf
set_date ()
{
DT=`date "+%y%m%d %H:%M:%S"`
}
#
mkdir $BK_DIR
set_date
echo -e "$DT Start ZABBIX DB backuping" > $MAILFILE
service zabbix-server stop >> $MAILFILE
#innobackupex --defaults-file=$MYSQLCNF --user=root --password=raspberry --no-timestamp $BK_DIR/xtra 2>&1 | tee /var/log/innobackupex.log | egrep "ERROR|innobackupex: completed OK" >>$MAILFILE
innobackupex  --user=root --password=raspberry --no-timestamp $BK_DIR/xtra 2>&1 | tee /var/log/innobackupex.log | egrep "ERROR|innobackupex: completed OK" >>$MAILFILE
innobackupex --apply-log --use-memory=1000M $BK_DIR/xtra 2>&1 | tee /var/log/innobackupex.log | egrep "ERROR|innobackupex: completed OK" >>$MAILFILE
service zabbix-server start >> $MAILFILE
set_date
echo -e "$DT DB backuping done" >> $MAILFILE
set_date
echo -e "$DT Start archiving" >> $MAILFILE
cd $BK_DIR
tar -cf $BK_DIR/zabbix_db_$DAY.tar ./xtra 2>>$MAILFILE
rm -rf $BK_DIR/xtra
cd /usr/local/share
tar -cf $BK_DIR/zabbix_files_$DAY.tar ./zabbix 2>>$MAILFILE
cd /usr/local/
tar -cf $BK_DIR/zabbix_etc_$DAY.tar ./etc 2>>$MAILFILE
cd /
gzip $BK_DIR/zabbix_db_$DAY.tar 2>>$MAILFILE
gzip $BK_DIR/zabbix_files_$DAY.tar 2>>$MAILFILE
gzip $BK_DIR/zabbix_etc_$DAY.tar 2>>$MAILFILE
set_date
echo -e "$DT Archiving done" >> $MAILFILE
rm -f zabbix_db_$DAY.tar
rm -f zabbix_files_$DAY.tar
rm -f zabbix_etc_$DAY.tar
set_date
#echo -e "$DT Start copyning to zb2 (10.77.12.3) server" >> $MAILFILE
#ssh smart-bit@zb2 'mkdir /home/zabbix/backups/'$DAY
#scp $BK_DIR/zabbix_db_$DAY.tar.gz smart-bit@zb2:/home/zabbix/backups/$DAY 2>>$MAILFILE
#scp $BK_DIR/zabbix_files_$DAY.tar.gz smart-bit@zb2:/home/zabbix/backups/$DAY 2>>$MAILFILE
#scp $BK_DIR/zabbix_etc_$DAY.tar.gz smart-bit@zb2:/home/zabbix/backups/$DAY 2>>$MAILFILE
#set_date
#echo -e "$DT Copyning to zb2 (10.77.12.3) server done" >> $MAILFILE
#set_date
echo -e "$DT Deleting old archive" >> $MAILFILE
find $BK_GLOBAL/* -type f -ctime +1 -exec rm -rf {} \; 2>>$MAILFILE
#ssh smart-bit@zb2 'find /home/zabbix/backups/* -type f -ctime +7 -exec rm -rf {} \;' 2>>$MAILFILE
find $BK_GLOBAL/* -type d -name "*" -empty -delete 2>>$MAILFILE
#ssh smart-bit@zb2 'find /home/zabbix/backups/* -type d -name "*" -empty -delete' 2>>$MAILFILE
set_date
echo -e "$DT Deleting old archive done" >> $MAILFILE
set_date
cat $MAILFILE >> $LOGFILE
echo -e "\nWe have on $BK_DIR:\n" >> $MAILFILE
ls -lh $BK_DIR >> $MAILFILE
echo -e "\nHDD usage:\n" >> $MAILFILE
df -h >> $MAILFILE
#mail -aFrom:zabbix1@com.com -s "Zabbix backup log $DAY" $EMAIL < $MAILFILE
