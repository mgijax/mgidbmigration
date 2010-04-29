#!/bin/csh -fx

# Migration for TR6839 - Part 1

cd `dirname $0` && source ../Configuration

echo "Server: ${MGD_DBSERVER}"
echo "Database: ${MGD_DBNAME}"

setenv CWD `pwd`        # current working directory

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}
date | tee -a ${LOG}

# load a backup

if ("${1}" == "dev") then
    echo "--- Loading new database into ${MGD_DBSERVER}..${MGD_DBNAME}" | tee -a
 ${LOG}
    load_db.csh ${MGD_DBSERVER} ${MGD_DBNAME} /shire/sybase/mgd.backup | tee -a
${LOG}
    date | tee -a ${LOG}
else
    echo "--- Working on existing database: ${MGD_DBSERVER}..${MGD_DBNAME}" | te
e -a ${LOG}
endif

setenv SCHEMA ${MGD_DBSCHEMADIR}
setenv PERMS ${MGD_DBPERMSDIR}
setenv UTILS ${MGI_DBUTILS}

date | tee -a ${LOG}
echo "--- Updating version numbers in db..." | tee -a ${LOG}

#${UTILS}/bin/updatePublicVersion.csh ${MGD_DBSERVER} ${MGD_DBNAME} "MGI 4.33" | tee -a ${LOG}
#${UTILS}/bin/updateSchemaVersion.csh ${MGD_DBSERVER} ${MGD_DBNAME} "4-3-3-0" | tee -a ${LOG}

date | tee -a ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

print 'Adding Sequence Ontology Logical DB'

declare @nextKey integer
select @nextKey = max(_LogicalDB_key) + 1 from ACC_LogicalDB

insert into ACC_LogicalDB
values(@nextKey, 'Sequence Ontology', 'Sequence Ontology', 1, 1001, 1001, getdate(), getdate())
go

print 'Adding Sequence Ontology Vocab type'

declare @nextKey integer
select @nextKey = max(_Vocab_key) + 1 from VOC_Vocab

declare @ldbKey integer
select @ldbKey = _LogicalDB_key
from ACC_LogicalDB
where name = 'Sequence Ontology'

insert into VOC_Vocab
values(@nextKey, 159965, @ldbKey, 0, 0, 'Sequence Ontology', getdate(), getdate())
go

print 'Adding Sequence Ontology DAG'

declare @nextKey integer
select @nextKey = max(_DAG_key) + 1 from DAG_DAG

insert into DAG_DAG
values(@nextKey, 159965, 13, 'Sequence Ontology', 'SO', getdate(), getdate())
go

print 'Adding SO Obsolete DAG'

declare @nextKey integer
select @nextKey = max(_DAG_key) + 1 from DAG_DAG

insert into DAG_DAG
values(@nextKey, 159965, 13, 'SO Obsolete', 'SOO', getdate(), getdate())
go

print 'Adding new VOC_VocabDAG for both DAGs'

declare @vocabKey integer
select @vocabKey = _Vocab_key
from VOC_Vocab
where name = 'Sequence Ontology'

declare @dagKey integer
select @dagKey = _DAG_key
from DAG_DAG
where name = 'Sequence Ontology'

insert into VOC_VocabDAG
values(@vocabKey, @dagKey, getdate(), getdate())
go

declare @vocabKey integer
select @vocabKey = _Vocab_key
from VOC_Vocab
where name = 'Sequence Ontology'

declare @dagKey integer
select @dagKey = _DAG_key
from DAG_DAG
where name = 'SO Obsolete'

insert into VOC_VocabDAG
values(@vocabKey, @dagKey, getdate(), getdate())
go

print 'Adding Sequence ontology edge labels'

declare @nextKey integer
select @nextKey = max(_Label_key) + 1 from DAG_Label

insert into DAG_Label
values(@nextKey, 'adjacent_to', getdate(), getdate())
go

declare @nextKey integer
select @nextKey = max(_Label_key) + 1 from DAG_Label

insert into DAG_Label
values(@nextKey, 'derives_from', getdate(), getdate())
go

declare @nextKey integer
select @nextKey = max(_Label_key) + 1 from DAG_Label

insert into DAG_Label
values(@nextKey, 'guided_by', getdate(), getdate())
go

declare @nextKey integer
select @nextKey = max(_Label_key) + 1 from DAG_Label

insert into DAG_Label
values(@nextKey, 'has_origin', getdate(), getdate())
go

declare @nextKey integer
select @nextKey = max(_Label_key) + 1 from DAG_Label

insert into DAG_Label
values(@nextKey, 'has_part', getdate(), getdate())
go

declare @nextKey integer
select @nextKey = max(_Label_key) + 1 from DAG_Label

insert into DAG_Label
values(@nextKey, 'has_quality', getdate(), getdate())
go

declare @nextKey integer
select @nextKey = max(_Label_key) + 1 from DAG_Label

insert into DAG_Label
values(@nextKey, 'member_of', getdate(), getdate())
go

declare @nextKey integer
select @nextKey = max(_Label_key) + 1 from DAG_Label

insert into DAG_Label
values(@nextKey, 'non_functional_homolog_of', getdate(), getdate())
go

declare @nextKey integer
select @nextKey = max(_Label_key) + 1 from DAG_Label

insert into DAG_Label
values(@nextKey, 'transcribed_to', getdate(), getdate())
go

declare @nextKey integer
select @nextKey = max(_Label_key) + 1 from DAG_Label

insert into DAG_Label
values(@nextKey, 'variant_of', getdate(), getdate())
go

print 'Adding SO Evidence Code Vocab Type'

declare @nextKey integer
select @nextKey = max(_Vocab_key) + 1 from VOC_Vocab

insert into VOC_Vocab
values(@nextKey, 159965, 1, 1, 0, 'SO Evidence Codes', getdate(), getdate())
go

print 'Adding SO Evidence Code Vocab Terms'

declare @nextKey integer
select @nextKey = max(_Term_key) + 1 from VOC_Term

declare @vocabKey integer
select @vocabKey = _Vocab_key
from VOC_Vocab
where name = 'SO Evidence Codes'

insert into VOC_Term
values(@nextKey, @vocabKey, 'IC', 'IC', 1, 0, 1001, 1001, getdate(), getdate())
go

print 'Creating soload MGI_User'

declare @nextKey integer
select @nextKey = max(_User_key) + 1 from MGI_User

insert into MGI_User
values(@nextKey, 316353, 316350, 'soload', 'Sequence Ontology Load', 1001, 1001, getdate(), getdate())
go

print 'Creating SO annotation type'

declare @nextKey integer
select @nextKey = max(_AnnotType_key) + 1 from VOC_AnnotType

declare @vocabKey integer
select @vocabKey = _Vocab_key
from VOC_Vocab
where name = 'Sequence Ontology'

declare @EvidenceVocabKey integer
select @EvidenceVocabKey = _Vocab_key
from VOC_Vocab
where name = 'SO Evidence Codes'

insert into VOC_AnnotType
values(@nextKey, 2, @vocabKey, @EvidenceVocabKey, 53, 'SO/Marker', getdate(), getdate())
go

quit

EOSQL
