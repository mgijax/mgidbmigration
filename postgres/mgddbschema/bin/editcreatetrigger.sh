#!/bin/sh

#
# create 'trigger' scripts
#

cd `dirname $0` && . ../Configuration

#
# read thru triggers_deletion.txt
#

while IFS=: read object mgikey mgitype
do
echo $object
echo $mgikey
echo $mgitype

cp ${POSTGRESTRIGGER}/template_create.object.new ${POSTGRESTRIGGER}/${object}_create.object
cp ${POSTGRESTRIGGER}/template_drop.object.new ${POSTGRESTRIGGER}/${object}_drop.object

ed ${POSTGRESTRIGGER}/${object}_create.object <<END
g/PG-TABLE/s//${object}/g
g/PG-KEY/s//${mgikey}/g
g/PG-TYPE/s//${mgitype}/g
.
w
q
END

ed ${POSTGRESTRIGGER}/${object}_drop.object <<END
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
${POSTGRESTRIGGER}/${object}_create.object

done < triggers_delete.txt

