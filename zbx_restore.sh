#!/bin/bash
MAILFILE=/tmp/mailfile.tmp
if [ "x$1" = "x" ] ; then
DAY=`date +%m%d`
echo -e "Start ZABBIX2 restoring to TODAY backup" > $MAILFILE
else
DAY=$1
echo -e "Start ZABBIX2 restoring to $DAY backup" > $MAILFILE
fi
LOGFILE=/var/log/zabbix_restore.log
EMAIL=smart-bit@com.com
BK_GLOBAL=/home/pi/backups
BK_DIR=$BK_GLOBAL/$DAY
set_date ()
{
DT=`date "+%y%m%d %H:%M:%S"`
}
#
cd $BK_DIR
file_db="zabbix_db_$DAY.tar.gz"
if [ -e $file_db ]; then
set_date
echo -e "$DT Start ZABBIX DB restoring" >> $MAILFILE
service zabbix-server stop >> $MAILFILE
service mysql stop >> $MAILFILE
rm -R /var/lib/mysqlcrashed
tar xvfz $file_db
mv /var/lib/mysql /var/lib/mysqlcrashed
mv xtra /var/lib/mysql
chown -R mysql:mysql /var/lib/mysql
service mysql start >> $MAILFILE
set_date
echo -e "$DT DB restoring done" >> $MAILFILE
else
echo "File with backup DB does not exists. DB IS NOT RESTORED!" >> $MAILFILE
fi
file_files="zabbix_files_$DAY.tar.gz"
if [ -e $file_files ]; then
set_date
echo -e "$DT Start files restoring" >> $MAILFILE
tar xvfz $file_files
cp -aR zabbix/* /usr/local/share/zabbix && rm -r zabbix/* && rmdir zabbix
set_date
echo -e "$DT files restoring done" >> $MAILFILE
else
echo "Files does not exists. ZABBIX FILES IS NOT RESTORED!" >> $MAILFILE
fi
file_etc="zabbix_etc_$DAY.tar.gz"
if [ -e $file_etc ]; then
set_date
echo -e "$DT Start /usr/local/etc restoring" >> $MAILFILE
tar xvfz $file_etc
cp -aR * /usr/local/etc && rm -r *
echo -e "$DT etc restoring done" >> $MAILFILE
service zabbix-server start >> $MAILFILE
else
echo "Files etc does not exists. FILES IS NOT RESTORED!" >> $MAILFILE
fi

set_date
cat $MAILFILE >> $LOGFILE
#mail -aFrom:zabbix2@com.com -s "Zabbix2 restoring log $DAY" $EMAIL < $MAILFILE
