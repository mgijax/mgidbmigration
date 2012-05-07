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
# copy snpdbschema/view/*_create.object to postgres directory
#
cd ${POSTGRESVIEW}
cp ${SNPBE_DBSCHEMADIR}/view/${findObject} .

#
# convert each snp-format view script to a postgres script
#

for i in ${findObject}
do

ed $i <<END
g/csh -f -x/s//sh/g
g/ source/s// ./g
g/create view /s//create view snp./g
g/^go/s///g
g/private = 0/s//private = false/g
g/convert(varchar(25),s._VarClass_key)/s//cast(s._VarClass_key as varchar(25))/g
g/"/s//'/g
/cat
d
a
cat - <<EOSQL | \${PG_DBUTILS}/bin/doisql.csh \${SNPBE_DBSERVER} \${SNPBE_DBNAME} \$0

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

