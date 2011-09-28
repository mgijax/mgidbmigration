#!/bin/sh

#
# create 'trigger' scripts
#
# a) remove referential integrity checks from 'delete' triggers
#

cd `dirname $0` && . ../Configuration

if [ $# -eq 1 ]
then
    findObject=$1_create.object
else
    findObject=*_create.object
fi

#
# edit "create" triggers from sybase to postgres
#

#
# copy mgddbschema/trigger/*_create.object to postgres directory
#
cd ${POSTGRESTRIGGER}
#
# copy all
#
cp ${MGD_DBSCHEMADIR}/trigger/${findObject} .

exit 0

#
# only copy the ones we need to migrate
#
#for i in ACC_Accession_create.object \
#ACC_LogicalDB_create.object \
#do
#cp ${MGD_DBSCHEMADIR}/trigger/${i} .
#done

#
# when ready, cvs remove the non-migrated triggers
#

#
# convert each mgd-format trigger script to a postgres script
#

#g/create trigger /s//create trigger mgd./g

for i in ${findObject}
do

ed $i <<END
g/csh -f -x/s//sh/g
g/source/s//./g
g/^)/s//);/
/cat
d
a
cat - <<EOSQL | \${PG_DBUTILS}/bin/doisql.csh \${MGD_DBSERVER} \${MGD_DBNAME} \$0

.
/^use
d
d
d
.
/^on
;d
a
EOSQL
.
w
q
END

done

