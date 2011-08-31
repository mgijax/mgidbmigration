#!/bin/sh

cd `dirname $0` && . ../Configuration

if [ $# -eq 1 ]
then
    findObject=$1_drop.object
else
    findObject=*_drop.object
fi

#
# copy radardbschema/index/*_drop.object to postgres directory
#
cd ${POSTGRESINDEX}
cp ${RADAR_DBSCHEMADIR}/index/${findObject} .

for i in ${findObject}
do

#g/drop index /s//drop index radar./g

t=`basename $i _drop.object`

ed $i <<END
g/csh -f -x/s//sh/g
g/& source/s//./g
g/${t}.idx/s//$t/g
g/^go/s//\\;/g
/cat
d
.
a
cat - <<EOSQL | \${PG_DBUTILS}/bin/doisql.csh \${RADAR_DBSERVER} \${RADAR_DBNAME} \$0

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
EOSQL
.
w
q
END

done

