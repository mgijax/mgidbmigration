#!/bin/csh -f

#
# Migration for TR 3710 (GXD_Assay)
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date >> $LOG
 
cat - <<EOSQL | doisql.csh $0 >> $LOG

use $DBNAME
go

sp_rename GXD_Assay, GXD_Assay_Old
go

end

EOSQL

#
# Use new schema product to create new table
#
${newmgddbschema}/table/GXD_Assay_create.object >> $LOG
${newmgddbschema}/default/GXD_Assay_bind.object >> $LOG

cat - <<EOSQL | doisql.csh $0 >> $LOG

use $DBNAME
go

insert into GXD_AssayType values (9, 'In situ reporter (knock in)', 1, 0, getdate(), getdate())
go

declare sKey integer
select @sKey = max(_ProbeSpecies_key) + 1 from PRB_Species

insert into PRB_Species(sKey, 'E. coli', getdate(), getdate())
insert into PRB_Species(sKey + 1, 'jellyfish', getdate(), getdate())
go

select _Assay_key, _AssayType_key, _Refs_key, _Marker_key, _ProbePrep_key, _AntibodyPrep_key,
_ImagePane_key, null, creation_date, modification_date
into GXD_Assay
from GXD_Assay_Old
go

checkpoint
go

quit

EOSQL

${newmgddbschema}/index/GXD_Assay_create.object >> $LOG

#cat - <<EOSQL | doisql.csh $0 >> $LOG
#
#use $DBNAME
#go
#
#drop table GXD_Assay_Old
#go
#
#end
#
#EOSQL

date >> $LOG

