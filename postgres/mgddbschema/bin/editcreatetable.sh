#!/bin/sh

#
# create 'table' scripts
#

cd `dirname $0` && . ../Configuration

if [ $# -eq 1 ]
then
    findObject=$1_create.object
else
    findObject=*_create.object
fi

#
# edit "create" tables from sybase to postgres
#

#
# copy mgddbschema/table/*_create.object to postgres directory
#
cd ${POSTGRESTABLE}
cp ${MGD_DBSCHEMADIR}/table/${findObject} .

#
# convert each mgd-format table script to a postgres script
#

for i in ${findObject}
do

ed $i <<END
g/csh -f -x/s//sh/g
g/& source/s//./g
g/tinyint/s//smallint/g
g/datetime/s//timestamp without time zone/g
g/bit/s//boolean/g
g/offset/s//mgdoffset/g
g/^)/s//);/
/cat
d
a
psql -d \${MGD_DBNAME} -a <<EOSQL > \${LOGFILE_PG}/table/$i.log

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

