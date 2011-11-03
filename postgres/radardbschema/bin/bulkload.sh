#!/bin/sh

#
#

cd `dirname $0` && . ../Configuration

LOG=${RADARDATA}/`basename $0`.log
rm -rf ${LOG}
touch ${LOG}

date >> ${LOG}

#
#${MGI_DBUTILS}/bin/bcpout.csh ${RADAR_DBSERVER} ${RADAR_DBNAME} $i ${POSTGRESDATA} $i.bcp "\t" "#=#"
#

if [ $# -eq 1 ]
then
    findObject=$1
    runAll=0
else
    findObject=*_create.object
    runAll=1
fi

#
# sybase:  bcp out the radar data files
#

cd ${POSTGRESDIR}/table

#
# if all tables, then run... 
#
if [ $runAll -eq '1' ]
then
echo 'run drop for all tables...' | tee -a ${LOG}
${POSTGRESDIR}/index/index_drop.sh
${POSTGRESDIR}/key/key_drop.sh
${POSTGRESDIR}/table/table_drop.sh
${POSTGRESDIR}/table/table_create.sh
fi

#
# else run script by object (see below)
#

#
# bcp out the sybase data
#
if [ ${runBCP} -eq '1' ]
then
echo 'bcp out the files from sybase...' | tee -a ${LOG}
for i in ${findObject}
do
i=`basename $i _create.object`
echo $i | tee -a ${LOG}
${MGI_DBUTILS}/bin/bcpout.csh ${RADAR_DBSERVER} ${OLDRADAR_DBNAME} $i ${RADARDATA} $i.bcp
done
fi
#
# end: bcp out the sybase data
#

#
# migrate bcp data format and load into postgres
#

for i in ${findObject}
do

i=`basename $i _create.object`

echo "table name...", $i | tee -a ${LOG}

if [ $runAll -eq '0' ]
then
echo "dropping indexes..." | tee -a ${LOG}
${POSTGRESDIR}/index/${i}_drop.object

echo "dropping key..." | tee -a ${LOG}
${POSTGRESDIR}/key/${i}_drop.object

echo "dropping/creating table..." | tee -a ${LOG}
${POSTGRESDIR}/table/${i}_drop.object
${POSTGRESDIR}/table/${i}_create.object

fi

echo ${RADARDATA}
cd ${RADARDATA}

#
# convert sybase data to postgres
#
if [ ${runBCP} -eq '1' ]
then

echo "converting bcp using python regular expressions..." | tee -a ${LOG}
# exporter scrip
cat $i.bcp | ${POSTGRES}/bin/postgresTextCleaner.py > $i.new
rm $i.bcp
mv $i.new $i.bcp

echo "converting bcp using perl #1..." | tee -a ${LOG}
/usr/local/bin/perl -p -i -e 's/&=&/\t/g' $i.bcp

echo "converting bcp using perl #2..." | tee -a ${LOG}
/usr/local/bin/perl -p -i -e 's/\t(... {1,2}\d{1,2} \d{4} {1,2}\d{1,2}:\d\d:\d\d):(.{5})/\t\1.\2/g' $i.bcp

echo "converting bcp using perl #3..." | tee -a ${LOG}
/usr/local/bin/perl -p -i -e 's/#=#//g' $i.bcp
fi
#
# end: convert sybase data to postgres
#

echo "calling postgres copy..." | tee -a ${LOG}
psql -U ${MGD_DBUSER} -d ${RADAR_DBNAME} <<END 
\copy radar.$i from '$i.bcp' with null as ''
\g
vacuum analyze radar.$i;
END

if [ $runAll -eq '0' ]
then
echo "adding indexes..." | tee -a ${LOG}
${POSTGRESDIR}/index/${i}_create.object

echo "adding keys..." | tee -a ${LOG}
${POSTGRESDIR}/key/${i}_create.object
fi

echo "#########" | tee -a ${LOG}
done

#
# if all tables, then run... 
#
if [ $runAll -eq '1' ]
then
echo 'run create key/index for all tables...' | tee -a ${LOG}
${POSTGRESDIR}/index/index_create.sh
${POSTGRESDIR}/key/key_create.sh
fi

date | tee -a ${LOG}

