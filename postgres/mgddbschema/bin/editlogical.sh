#!/bin/sh

#
# create 'trigger' scripts
#

cd `dirname $0` && . ../Configuration

findLogical=*.logical

#
# edit "create" triggers from sybase to postgres
#

#
# copy mgddbschema/trigger/*_create.object to postgres directory
#
#cd ${POSTGRESTABLE}
#cp ${MGD_DBSCHEMADIR}/table/${findLogical} .
cd ${POSTGRESTRIGGER}
cp ${MGD_DBSCHEMADIR}/trigger/${findLogical} .

#
# convert
#

for i in ${findLogical}
do

ed $i <<END
g/csh -f -x/s//sh/g
g/foreach i (/s//for i in /g
g/)/s//
g/end/s//done/g
/for
a
do
.
w
q
END

done

