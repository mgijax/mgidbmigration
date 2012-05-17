#!/bin/sh

#
#

cd `dirname $0` && . ../Configuration

LOG=$0.log
rm -rf ${LOG}
touch ${LOG}

date >> ${LOG}

if [ $# -eq 1 ]
then
    findObject=$1
    runAll=0
else
    findObject=*_create.object
    runAll=1
fi

#
# if all tables, then run... 
#
if [ $runAll -eq '1' ]
then

echo 'load mgd.postgres.dump into ${MGD_SCHEMA}...' | tee -a ${LOG}
echo ${PG_DBUTILS}/bin/loadDB.csh ${PG_DBSERVER} ${MGD_DBNAME} ${MGD_SCHEMA} /backups/rohan/postgres/mgd.postgres.dump
${PG_DBUTILS}/bin/loadDB.csh ${PG_DBSERVER} ${MGD_DBNAME} ${MGD_SCHEMA} /backups/rohan/postgres/mgd.postgres.dump

#echo 'run drop for all tables...' | tee -a ${LOG}
#${POSTGRESDIR}/index/index_drop.sh
#${POSTGRESDIR}/key/key_drop.sh
#${POSTGRESDIR}/trigger/trigger_drop.sh
#${POSTGRESDIR}/view/view.sh

#echo 'run create key/index/trigger/view for all tables...' | tee -a ${LOG}
#${POSTGRESDIR}/index/index_create.sh
#${POSTGRESDIR}/key/key_create.sh
#${POSTGRESDIR}/trigger/trigger_create.sh
#${POSTGRESDIR}/view/view_create.sh

else

echo "dropping indexes..." | tee -a ${LOG}
${POSTGRESDIR}/index/${i}_drop.object

echo "dropping key..." | tee -a ${LOG}
${POSTGRESDIR}/key/${i}_drop.object

#echo "dropping trigger..." | tee -a ${LOG}
#${POSTGRESDIR}/trigger/${i}_drop.object

echo "adding indexes..." | tee -a ${LOG}
${POSTGRESDIR}/index/${i}_create.object

echo "adding keys..." | tee -a ${LOG}
${POSTGRESDIR}/key/${i}_create.object

#echo "adding trigger..." | tee -a ${LOG}
#${POSTGRESDIR}/trigger/${i}_create.object

fi

echo "#########" | tee -a ${LOG}

#
# comments
#
#echo "updating comments..." | tee -a ${LOG}
#cd ${MGDPOSTGRES}/bin
#./comments.py
#psql -U ${MGD_DBUSER} -d ${MGD_DBNAME} < comments.txt

date | tee -a ${LOG}

