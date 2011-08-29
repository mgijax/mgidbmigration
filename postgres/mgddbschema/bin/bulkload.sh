#!/bin/sh

#
#

cd `dirname $0` && . ../Configuration

setenv LOG      ${MGDDATA}/`basename $0`.log
rm -rf ${LOG}
touch ${LOG}

date >> ${LOG}

#
#${MGI_DBUTILS}/bin/bcpout.csh ${MGD_DBSERVER} ${MGD_DBNAME} $i ${POSTGRESDATA} $i.bcp "\t" "#=#"
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
# sybase:  bcp out the mgd data files
#

cd ${POSTGRESDIR}/table

#
# if all tables, then run... 
#
if [ $runAll -eq '1' ]
then
echo 'run drop/truncate for all tables...' | tee -a ${MGDDATA}
${POSTGRESDIR}/index/index_drop.sh
${POSTGRESDIR}/key/key_drop.sh
${POSTGRESDIR}/table/table_truncate.sh
fi

#
# else run script by object (see below)
#

#comment out if you are not going to create bcp files
echo 'bcp out the files from sybase...' | tee -a ${MGDDATA}
for i in ${findObject}
do
i=`basename $i _create.object`
echo $i | tee -a ${MGDDATA}
${MGI_DBUTILS}/bin/bcpout.csh ${MGD_DBSERVER} ${OLDMGD_DBNAME} $i ${MGDDATA} $i.bcp
done

#
# migrate bcp data format and load into postgres
#

for i in ${findObject}
do

i=`basename $i _create.object`

echo "table name...", $i | tee -a ${MGDDATA}

if [ $runAll -eq '0' ]
then
echo "dropping indexes..." | tee -a ${MGDDATA}
${POSTGRESDIR}/index/${i}_drop.object

echo "dropping key..." | tee -a ${MGDDATA}
${POSTGRESDIR}/key/${i}_drop.object

echo "truncating table..." | tee -a ${MGDDATA}
${POSTGRESDIR}/table/${i}_truncate.object
fi

cd ${MGDDATA}

echo "converting bcp using python regular expressions..." | tee -a ${MGDDATA}
# exporter scrip
cat $i.bcp | ${MGDPOSTGRES}/bin/postgresTextCleaner.py > $i.new
rm $i.bcp
mv $i.new $i.bcp

echo "converting bcp using perl #1..." | tee -a ${MGDDATA}
/usr/local/bin/perl -p -i -e 's/&=&/\t/g' $i.bcp

echo "converting bcp using perl #2..." | tee -a ${MGDDATA}
/usr/local/bin/perl -p -i -e 's/\t(... {1,2}\d{1,2} \d{4} {1,2}\d{1,2}:\d\d:\d\d):(.{5})/\t\1.\2/g' $i.bcp

echo "converting bcp using perl #3..." | tee -a ${MGDDATA}
/usr/local/bin/perl -p -i -e 's/#=#//g' $i.bcp

echo "calling postgres copy..." | tee -a ${MGDDATA}
psql -d ${MGD_DBNAME} <<END 
\copy $i from '$i.bcp' with null as ''
\g
vacuum analyze $i;
END

if [ $runAll -eq '0' ]
then
echo "adding indexes..." | tee -a ${MGDDATA}
${POSTGRESDIR}/index/${i}_create.object

echo "adding keys..." | tee -a ${MGDDATA}
${POSTGRESDIR}/key/${i}_create.object
fi

echo "#########" | tee -a ${MGDDATA}
done

#
# if all tables, then run... 
#
if [ $runAll -eq '1' ]
then
echo 'run create key/index for all tables...' | tee -a ${MGDDATA}
${POSTGRESDIR}/index/index_create.sh
${POSTGRESDIR}/key/key_create.sh
fi

date | tee -a ${LOG}

