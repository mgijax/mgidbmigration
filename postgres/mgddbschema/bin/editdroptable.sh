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
# copy mgddbschema/table/*_drop.object to postgres directory
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
g/source/s//./g
/cat
d
a
 psql -d \${MGD_DBNAME} -a <<EOSQL > \${LOGFILE_PG}/table/$i.log

.
/^use
d
d
/go
d
a
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

