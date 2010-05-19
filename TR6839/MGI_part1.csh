#!/bin/csh -fx

# Migration for TR6839 - Part 1

cd `dirname $0` && source ../Configuration

echo "Server: ${MGD_DBSERVER}"
echo "Database: ${MGD_DBNAME}"

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

###----------------------###
###--- add new tables ---###
###----------------------###

date | tee -a ${LOG}
echo "--- Creating new tables" | tee -a ${LOG}

${SCHEMA}/table/MRK_MTO_Cache_create.object | tee -a ${LOG}
${SCHEMA}/table/MRK_MTO_Count_Cache_create.object | tee -a ${LOG}

# add defaults for new tables
# not created yet


# add keys and indexes for new tables

date | tee -a ${LOG}
echo "--- Adding keys" | tee -a ${LOG}

${SCHEMA}/key/MRK_MTO_Cache_create.object | tee -a ${LOG}
${SCHEMA}/key/MRK_MTO_Count_Cache_create.object | tee -a ${LOG}

date | tee -a ${LOG}
echo "--- Adding indexes" | tee -a ${LOG}

${SCHEMA}/index/MRK_MTO_Cache_create.object | tee -a ${LOG}
${SCHEMA}/index/MRK_MTO_Count_Cache_create.object | tee -a ${LOG}

# add permissions for new tables

date | tee -a ${LOG}
echo "--- Adding new perms" | tee -a ${LOG}

${PERMS}/public/table/MRK_MTO_Cache_grant.object | tee -a ${LOG}
${PERMS}/public/table/MRK_MTO_Count_Cache_grant.object | tee -a ${LOG}

date | tee -a ${LOG}
echo "--- Updating version numbers in db..." | tee -a ${LOG}

#${UTILS}/bin/updatePublicVersion.csh ${MGD_DBSERVER} ${MGD_DBNAME} "MGI 4.33" | tee -a ${LOG}
#${UTILS}/bin/updateSchemaVersion.csh ${MGD_DBSERVER} ${MGD_DBNAME} "4-3-3-0" | tee -a ${LOG}

date | tee -a ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

print '####################################'
print '###  MTO VOCAB AND ANNOT LOAD ######'
print '####################################'
print 'Need to update reference to  MTO reference'

/* Done in production 5/5/10 'Adding Marker Type Ontology Logical DB' */

print 'Adding Marker Type Ontology Ontology Vocab type'

declare @nextKey integer
select @nextKey = max(_Vocab_key) + 1 from VOC_Vocab

declare @ldbKey integer
select @ldbKey = _LogicalDB_key
from ACC_LogicalDB
where name = 'Marker Type Ontology'

insert into VOC_Vocab
values(@nextKey, 160374, @ldbKey, 0, 0, 'Marker Type Ontology', getdate(), getdate())
go

print 'Adding Marker Type Ontology DAG'

declare @nextKey integer
select @nextKey = max(_DAG_key) + 1 from DAG_DAG

insert into DAG_DAG
values(@nextKey, 160374, 13, 'Marker Type Ontology', 'MTO', getdate(), getdate())
go

print 'Adding new VOC_VocabDAG for Marker Type DAG'

declare @vocabKey integer
select @vocabKey = _Vocab_key
from VOC_Vocab
where name = 'Marker Type Ontology'

declare @dagKey integer
select @dagKey = _DAG_key
from DAG_DAG
where name = 'Marker Type Ontology'

insert into VOC_VocabDAG
values(@vocabKey, @dagKey, getdate(), getdate())
go

print 'Creating mtoload MGI_User'

declare @nextKey integer
select @nextKey = max(_User_key) + 1 from MGI_User

insert into MGI_User
values(@nextKey, 316353, 316350, 'mtoload', 'Marker Type Ontology Load', 1001, 1001, getdate(), getdate())
go

print 'Adding MTO node labels'

declare @nextKey integer
select @nextKey = max(_Label_key) + 1 from DAG_Label

insert into DAG_Label
values(@nextKey, 'show', getdate(), getdate())
go

declare @nextKey integer
select @nextKey = max(_Label_key) + 1 from DAG_Label

insert into DAG_Label
values(@nextKey, 'hide', getdate(), getdate())
go

print 'Adding MTO Evidence Code Vocab Type'

declare @nextKey integer
select @nextKey = max(_Vocab_key) + 1 from VOC_Vocab

insert into VOC_Vocab
values(@nextKey, 159965, 1, 1, 0, 'MTO Evidence Codes', getdate(), getdate())
go

print 'Adding MTO Evidence Code Vocab Terms'

declare @nextKey integer
select @nextKey = max(_Term_key) + 1 from VOC_Term

declare @vocabKey integer
select @vocabKey = _Vocab_key
from VOC_Vocab
where name = 'MTO Evidence Codes'

insert into VOC_Term
values(@nextKey, @vocabKey, 'IC', 'IC', 1, 0, 1001, 1001, getdate(), getdate())
go

print 'Creating mtoload MGI_User'

declare @nextKey integer
select @nextKey = max(_User_key) + 1 from MGI_User

insert into MGI_User
values(@nextKey, 316353, 316350, 'soload', 'Marker Type Ontology Load', 1001, 1001,
 getdate(), getdate())
go

print 'Creating SO annotation type'

declare @nextKey integer
select @nextKey = max(_AnnotType_key) + 1 from VOC_AnnotType

declare @vocabKey integer
select @vocabKey = _Vocab_key
from VOC_Vocab
where name = 'Marker Type Ontology'

declare @EvidenceVocabKey integer
select @EvidenceVocabKey = _Vocab_key
from VOC_Vocab
where name = 'MTO Evidence Codes'

insert into VOC_AnnotType
values(@nextKey, 2, @vocabKey, @EvidenceVocabKey, 53, 'MTO/Marker', getdate(), getdate())
go

quit

EOSQL

echo 'Update Marker Types'
./updateMarkerType.csh
