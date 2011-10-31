#!/bin/sh

#
# create 'trigger' scripts
#

cd `dirname $0` && . ../Configuration

#
# read thru triggers_deletion.txt
#

while IFS=: read object mgikey mginame mgiprivate
do
echo $object
echo $mgikey
echo $mginame
echo $mgiprivate

cp ${MGD_DBSCHEMADIR}/trigger/${object}_create.object ${POSTGRESTRIGGER}
cp ${POSTGRESTRIGGER}/template_insert2_create.object.new ${POSTGRESTRIGGER}/${object}_insert_create.object
cp ${POSTGRESTRIGGER}/template_insert_drop.object.new ${POSTGRESTRIGGER}/${object}_insert_drop.object

ed ${POSTGRESTRIGGER}/${object}_insert_create.object <<END
g/PG-TABLE/s//${object}/g
g/PG-KEY/s//${mgikey}/g
g/PG-NAME/s//${mginame}/g
g/PG-PRIVATE/s//${mgiprivate}
.
w
q
END

ed ${POSTGRESTRIGGER}/${object}_insert_drop.object <<END
g/PG-TABLE/s//${object}/g
.
w
q
END

#
# execute the script to create the delete function/trigger
#
${POSTGRESTRIGGER}/${object}_insert_create.object

done < triggers_insert2.txt

