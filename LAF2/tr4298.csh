#!/bin/csh -f

#
# Migration for PRB_Strain_Marker
#

cd `dirname $0` && source Configuration

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date >> $LOG
 
cat - <<EOSQL | doisql.csh $0 >> $LOG

use $DBNAME
go

sp_rename PRB_Strain_Marker, PRB_Strain_Marker_Old
go

end

EOSQL

#
# Use new schema product to create new table
#
${newmgddbschema}/table/PRB_Strain_Marker_create.object
${newmgddbschema}/default/PRB_Strain_Marker_bind.object

cat - <<EOSQL | doisql.csh $0 >> $LOG

use $DBNAME
go

select seq = identity(5), _Strain_key, _Marker_key, _Allele_key = null, 
creation_date, modification_date
into #strainTemp
from PRB_Strain_Marker_Old
go

insert into PRB_Strain_Marker
select seq + 1000, _Strain_key, _Marker_key, _Allele_key,
creation_date, modification_date
from #strainTemp
go

dump tran ${DBNAME} with truncate_only
go

checkpoint
go

quit

EOSQL

${newmgddbschema}/index/PRB_Strain_Marker_create.object
${newmgddbschema}/key/PRB_Strain_Marker_create.object
${newmgddbschema}/key/ALL_Allele_drop.object
${newmgddbschema}/key/ALL_Allele_create.object
${newmgddbschema}/key/MRK_Marker_drop.object
${newmgddbschema}/key/MRK_Marker_create.object
${newmgddbschema}/key/PRB_Strain_drop.object
${newmgddbschema}/key/PRB_Strain_create.object
${newmgddbschema}/view/PRB_Strain_Marker_View_drop.object
${newmgddbschema}/view/PRB_Strain_Marker_View_create.object

date >> $LOG

