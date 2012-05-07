#!/bin/sh

cd `dirname $0` && . ../Configuration

if [ $# -eq 1 ]
then
    findObject=$1_drop.object
else
    findObject=*_drop.object
fi

#
# edit "drop" views from sybase to postgres 
#

#
# copy mgddbschema/view/*_drop.object to postgres directory
#
cd ${POSTGRESVIEW}
cp ${MGD_DBSCHEMADIR}/view/${findObject} .

#
# convert each mgd-format view script to a postgres script
#

for i in ${findObject}
do

ed $i <<END
g/csh -f -x/s//sh/g
g/ source/s// ./g
g/drop view /s//drop view mgd./g
/cat
d
a
cat - <<EOSQL | \${PG_DBUTILS}/bin/doisql.csh \${MGD_DBSERVER} \${MGD_DBNAME} \$0

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

