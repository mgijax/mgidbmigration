#!/bin/sh

#
# for each table:
#	bcp out the table from sybase
#	bcp the table into postgres
#
# must convert sybase/datetime to postgres/timestamp
#

cd `dirname $0` && . ../Configuration

#
#${MGI_DBUTILS}/bin/bcpout.csh ${MGD_DBSERVER} ${MGD_DBNAME} $i ${POSTGRESDATA} $i.bcp "\t" "#=#"
#

if [ $# -eq 1 ]
then
    findObject=$1
else
    findObject=*_create.object
fi

#
# sybase:  bcp out the mgd data files
#

cd ${POSTGRESDIR}/table

#for i in ${findObject}
#do
#i=`basename $i _create.object`
#echo $i
#${MGI_DBUTILS}/bin/bcpout.csh ${MGD_DBSERVER} ${OLDMGD_DBNAME} $i ${POSTGRESDATA} $i.bcp
#done

#
# migrate bcp data format and load into postgres
#

for i in ${findObject}
do

i=`basename $i _create.object`

echo "table name...", $i

echo "truncating table..."
${POSTGRESDIR}/table/${i}_truncate.object

echo "dropping indexes..."
${POSTGRESDIR}/index/${i}_drop.object

echo "dropping key..."
${POSTGRESDIR}/key/${i}_drop.object

cd ${POSTGRESDIR}/data

#if [ "${i}" != "ACC_AccessionMax" -a "${i}" != "MGI_Columns" -a "${i}" != "MGI_Tables" ]
#then
#echo "converting bcp using python regular expressions..."
#${MGDPOSTGRES}/bin/bulkload.py < $i.bcp > $i.new
#rm $i.bcp
#mv $i.new $i.bcp
#fi

#echo "converting bcp using dos2unix..."
#dos2unix $i.bcp $i.bcp

#echo "converting bcp using perl #1..."
#/usr/local/bin/perl -p -i -e 's/&=&/\t/g' $i.bcp

#echo "converting bcp using perl #2..."
#/usr/local/bin/perl -p -i -e 's/\t(... {1,2}\d{1,2} \d{4} {1,2}\d{1,2}:\d\d:\d\d):(.{5})/\t\1.\2/g' $i.bcp

#echo "converting bcp using perl #3..."
#/usr/local/bin/perl -p -i -e 's/#=#//g' $i.bcp

echo "calling postgres copy..."
psql -d ${MGD_DBNAME} <<END 
\copy $i from '$i.bcp' with null as ''
\g
vacuum analyze $i;
END

echo "adding indexes..."
${POSTGRESDIR}/index/${i}_create.object

echo "adding keys..."
${POSTGRESDIR}/key/${i}_create.object

echo "#########"
done

