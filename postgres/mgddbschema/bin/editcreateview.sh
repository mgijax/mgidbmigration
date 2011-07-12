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
cd ${POSTGRESTABLE}
cp ${MGD_DBSCHEMADIR}/view/${findObject} .

#
# convert each mgd-format view script to a postgres script
#

for i in ${findObject}
do

ed $i <<END
/cat
d
a
psql -d \${MGD_DBNAME} -c "

.
/^use
d
d
d
.
/^on
;d
a
"
.
w
q
END

done

