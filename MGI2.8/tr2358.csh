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
rm MLP_Notes.bcp
foreach i (MLP*)
set f=`basename $i .bcp`
bcpin.csh ${newmgddbschema} $f
end

cat - <<EOSQL | doisql.csh $0 >> $LOG
  
use ${DBNAME}
go

insert into MLP_Extra (_Strain_key, reference, dataset, note1, note2, creation_date, modification_date)
select _Strain_key, convert(varchar(25), reference), dataset, note1, note2, creation_date, modification_date
from $STRAINS..MLP_Notes
go

EOSQL

cd ..
${newmgddbschema}/index/MLP_create.logical
  
date >> $LOG
