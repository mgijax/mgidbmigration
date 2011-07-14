#!/bin/sh

#
# create 'view' scripts
#

cd `dirname $0` && . ../Configuration

if [ $# -eq 1 ]
then
    findObject=$1_create.object
else
    findObject=*_create.object
fi

#
# edit "create" views from sybase to postgres
#

#
# copy mgddbschema/view/*_create.object to postgres directory
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
g/& source/s//./g
g/^go/s///g
g/active = 1/s//active = true/g
g/private = 0/s//private = false/g
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
/^checkpoint
;d
.
a
;

EOSQL
.
w
q
END

done

