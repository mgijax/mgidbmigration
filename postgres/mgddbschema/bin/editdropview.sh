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
cd ${POSTGRESTABLE}
cp ${MGD_DBSCHEMADIR}/view/${findObject} .

#
# convert each mgd-format view script to a postgres script
#

for i in ${findObject}
do

ed $i <<END
g/csh -f -x/s//sh/g
g/source/s//./g
/cat
d
a
psql -d \${MGD_DBNAME} -c "

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
"
.
w
q
END

done

