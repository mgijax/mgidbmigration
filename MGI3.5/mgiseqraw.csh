#!/bin/csh -fx

#
# TR 7094/SEQ_Sequence split into SEQ_Sequence and SEQ_Sequence_Raw
#

source ./Configuration

setenv LOG	`basename $0`.log
rm -rf $LOG
touch $LOG

date | tee -a ${LOG}

# create new Raw table

${newmgddbschema}/table/SEQ_Sequence_Raw_create.object | tee -a ${LOG}
${newmgddbschema}/default/SEQ_Sequence_Raw_bind.object | tee -a ${LOG}
${newmgddbschema}/key/SEQ_Sequence_Raw_create.object | tee -a ${LOG}
${newmgddbperms}/public/table/SEQ_Sequence_Raw_grant.object | tee -a ${LOG}

# load new Raw table

cat - <<EOSQL | doisql.csh $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

insert into SEQ_Sequence_Raw 
select _Sequence_key, rawType,rawLibrary,rawOrganism,rawStrain,rawTissue,rawAge,rawSex,rawCellLine,
_CreatedBy_key,_ModifiedBy_key,creation_date,modification_date 
from SEQ_Sequence
go

sp_rename SEQ_Sequence, SEQ_Sequence_Old
go

quit

EOSQL

# create new Sequence table

${newmgddbschema}/table/SEQ_Sequence_create.object | tee -a ${LOG}
${newmgddbschema}/partition/SEQ_Sequence_create.object | tee -a ${LOG}
${newmgddbschema}/default/SEQ_Sequence_bind.object | tee -a ${LOG}
${newmgddbschema}/key/SEQ_Sequence_create.object | tee -a ${LOG}
${newmgddbperms}/public/table/SEQ_Sequence_grant.object | tee -a ${LOG}

# load new Sequence table

cat - <<EOSQL | doisql.csh $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

/* mouse */

insert into SEQ_Sequence
select _Sequence_key,_SequenceType_key,_SequenceQuality_key,_SequenceStatus_key,_SequenceProvider_key,1,
length,description,version,division,virtual,numberOfOrganisms,seqrecord_date,sequence_date,
_CreatedBy_key,_ModifiedBy_key,creation_date,modification_date
from SEQ_Sequence_Old
where _SequenceStatus_key != 316345
go

/* non-mouse (not loaded) */

insert into SEQ_Sequence
select _Sequence_key,_SequenceType_key,_SequenceQuality_key,_SequenceStatus_key,_SequenceProvider_key,75,
length,description,version,division,virtual,numberOfOrganisms,seqrecord_date,sequence_date,
_CreatedBy_key,_ModifiedBy_key,creation_date,modification_date
from SEQ_Sequence_Old
where _SequenceStatus_key = 316345
go

quit

EOSQL

${newmgddbschema}/index/SEQ_Sequence_create.object | tee -a ${LOG}
${newmgddbschema}/index/SEQ_Sequence_Raw_create.object | tee -a ${LOG}

date | tee -a ${LOG}

