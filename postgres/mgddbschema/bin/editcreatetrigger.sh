#!/bin/sh

#
# create 'trigger' scripts
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
cp ${MGD_DBSCHEMADIR}/trigger/${findObject} .
exit 0

#
# convert each mgd-format trigger script to a postgres script
#

#g/create trigger /s//create trigger mgd./g

for i in ${findObject}
do

ed $i <<END
g/csh -f -x/s//sh/g
g/& source/s//./g
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

