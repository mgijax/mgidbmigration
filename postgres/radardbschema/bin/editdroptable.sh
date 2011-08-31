#!/bin/sh

cd `dirname $0` && . ../Configuration

if [ $# -eq 1 ]
then
    findObject=$1_drop.object
else
    findObject=*_drop.object
fi

#
# edit "drop" tables from sybase to postgres 
#

#
# copy radardbschema/table/*_drop.object to postgres directory
#
cd ${POSTGRESTABLE}
cp ${RADAR_DBSCHEMADIR}/table/${findObject} .

#
# convert each radar-format table script to a postgres script
#

for i in ${findObject}
do

#g/drop table /s//drop table radar./g

ed $i <<END
g/csh -f -x/s//sh/g
g/source/s//./g
/cat
d
a
cat - <<EOSQL | \${PG_DBUTILS}/bin/doisql.csh \${RADAR_DBSERVER} \${RADAR_DBNAME} \$0

.
/^use
d
d
/go
d
a
CASCADE
;
.
/checkpoint
;d
a
EOSQL
.
w
q
END

done

