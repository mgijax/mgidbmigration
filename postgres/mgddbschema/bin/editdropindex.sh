#!/bin/sh

cd `dirname $0` && . ../Configuration

if [ $# -eq 1 ]
then
    findObject=$1_drop.object
else
    findObject=*_drop.object
fi

#
# copy mgddbschema/index/*_drop.object to postgres directory
#
cd ${POSTGRESINDEX}
cp ${MGD_DBSCHEMADIR}/index/${findObject} .

for i in ${findObject}
do

t=`basename $i _drop.object`

ed $i <<END
g/csh -f -x/s//sh/g
g/& source/s//./g
g/${t}.idx/s//$t/g
g/offset/s//mgdoffset/g
g/^go/s//\\\g/g
/cat
d
.
a
psql -d \${MGD_DBNAME} <<EOSQL 2> \${LOGFILE_PG}/index/$i.log

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

