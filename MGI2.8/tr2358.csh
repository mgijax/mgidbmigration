#!/bin/csh -f

#
# Migration for TR 2358
#

cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date >> $LOG
 
#
# BCP-out all Strain data
#

bcpout.csh ${oldstrainsdbschema} all `pwd`/straindata

#
# re-create all Strain tables in MGD
#

${newmgddbschema}/table/MLP_create.logical
${newmgddbschema}/default/MLP_bind.logical
${newmgddbschema}/key/MLP_create.logical

#
# BCP-in all Strain data
#

cd straindata
foreach i (MLP*)
set f=`basename $i .bcp`
bcpin.csh ${newmgddbschema} $f
end

cd ..
${newmgddbschema}/index/MLP_create.logical
  
date >> $LOG
