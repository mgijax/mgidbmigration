#!/bin/sh

#
# create 'trigger' scripts
#

cd `dirname $0` && . ../Configuration

#
# read thru triggers_deletion.txt
#

while IFS=: read object mgikey mgitype text
do
echo $object
echo $mgikey
echo $mgitype
echo $text

cp ${MGD_DBSCHEMADIR}/trigger/${object}_create.object ${POSTGRESTRIGGER}
cp ${POSTGRESTRIGGER}/template_delete_create.object.new ${POSTGRESTRIGGER}/${object}_delete_create.object
cp ${POSTGRESTRIGGER}/template_delete_drop.object.new ${POSTGRESTRIGGER}/${object}_delete_drop.object

ed ${POSTGRESTRIGGER}/${object}_delete_create.object <<END
g/PG-TABLE/s//${object}/g
g/PG-KEY/s//${mgikey}/g
g/PG-TYPE/s//${mgitype}/g
.
w
q
END

ed ${POSTGRESTRIGGER}/${object}_delete_drop.object <<END
g/PG-TABLE/s//${object}/g
g/PG-KEY/s//${mgikey}/g
g/PG-TYPE/s//${mgitype}/g
.
w
q
END

#
# execute the script to create the delete function/trigger
#
${POSTGRESTRIGGER}/${object}_delete_create.object

done < triggers_delete.txt

