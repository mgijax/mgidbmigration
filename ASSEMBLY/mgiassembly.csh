#!/bin/csh -f

#
# Migration for MGI Assembly
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date | tee -a ${LOG}
echo "MGI Assembly Migration..." | tee -a ${LOG}
 
# MAP_

${newmgddbschema}/table/MAP_drop.logical | tee -a ${LOG}
${newmgddbschema}/table/MAP_create.logical | tee -a ${LOG}
${newmgddbschema}/default/MAP_bind.logical | tee -a ${LOG}
${newmgddbschema}/index/MAP_create.logical | tee -a ${LOG}
${newmgddbschema}/key/MAP_create.logical | tee -a ${LOG}

# SEQ_

${newmgddbschema}/table/SEQ_Coord_Cache_drop.object | tee -a ${LOG}
${newmgddbschema}/table/SEQ_Coord_Cache_create.object | tee -a ${LOG}
${newmgddbschema}/default/SEQ_Coord_Cache_bind.object | tee -a ${LOG}
${newmgddbschema}/index/SEQ_Coord_Cache_create.object | tee -a ${LOG}

${newmgddbschema}/table/SEQ_Marker_Cache_drop.object | tee -a ${LOG}
${newmgddbschema}/table/SEQ_Marker_Cache_create.object | tee -a ${LOG}
${newmgddbschema}/default/SEQ_Marker_Cache_bind.object | tee -a ${LOG}
${newmgddbschema}/index/SEQ_Marker_Cache_create.object | tee -a ${LOG}

${newmgddbschema}/table/MRK_CuratedRepSequence_create.object | tee -a ${LOG}
${newmgddbschema}/default/MRK_CuratedRepSequence_bind.object | tee -a ${LOG}
${newmgddbschema}/index/MRK_CuratedRepSequence_create.object | tee -a ${LOG}

${newmgddbschema}/view/SEQ_Marker_Cache_View_drop.object | tee -a ${LOG}
${newmgddbschema}/view/SEQ_Marker_Cache_View_create.object | tee -a ${LOG}
${newmgddbschema}/view/VOC_Term_RepQualifier_View_create.object | tee -a ${LOG}
${newmgddbschema}/procedure/SEQ_deriveRepByMarker_create.object | tee -a ${LOG}
${newmgddbschema}/procedure/SEQ_deriveRepAll_create.object | tee -a ${LOG}
${newmgddbschema}/procedure/MRK_reloadSequence_drop.object | tee -a ${LOG}
${newmgddbschema}/procedure/MRK_reloadSequence_create.object | tee -a ${LOG}

${newmgddbschema}/index/ACC_ActualDB_drop.object | tee -a ${LOG}
${newmgddbschema}/index/ACC_ActualDB_create.object | tee -a ${LOG}
${newmgddbschema}/index/ACC_LogicalDB_drop.object | tee -a ${LOG}
${newmgddbschema}/index/ACC_LogicalDB_create.object | tee -a ${LOG}

cat - <<EOSQL | doisql.csh $0 >> ${LOG}

use ${DBNAME}
go

insert into ACC_MGIType values (27, 'Chromosome', 'MRK_Chromosome', '_Chromosome_key', null, null, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
go

insert into MGI_RefAssocType values(1008, 19, 'Load', 0, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
go

update VOC_Term set sequenceNum = 12 where _Term_key = 316381
update VOC_Term set sequenceNum = 13 where _Term_key = 316382
update VOC_Term set sequenceNum = 14 where _Term_key = 316383
update VOC_Term set sequenceNum = 15 where _Term_key = 316384
update VOC_Term set sequenceNum = 16 where _Term_key = 316385
go

declare @termKey integer
select @termKey = max(_Term_key) + 1 from VOC_Term
insert into VOC_Term values (@termKey, 25, 'Ensembl Gene Model', 'Ensembl Gene Model', 10, 0, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
insert into VOC_Term values (@termKey + 1, 25, 'NCBI Gene Model', 'NCBI Gene Model', 11, 0, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
go

declare @userKey integer
select @userKey = max(_User_key) + 1 from MGI_User
insert into MGI_User values (@userKey, 316353, 316350, 'ncbi_assemblyseqload', 'NCBI Genomic Sequence Load', ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
insert into MGI_User values (@userKey + 1, 316353, 316350, 'ensembl_assemblyseqload', 'Ensembl Genomic Sequence Load', ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
go

declare @logKey integer
select @logKey = max(_LogicalDB_key) + 1 from ACC_LogicalDB
insert into ACC_LogicalDB values (@logKey, 'NCBI Gene Model', 'NCBI Gene for assembly coordinates', null, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
insert into ACC_LogicalDB values (@logKey + 1, 'Ensembl Gene Model', 'Ensembl for assembly coordinates', null, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())

declare @actKey integer
select @actKey = max(_ActualDB_key) + 1 from ACC_ActualDB
insert into ACC_ActualDB values (@actKey, @logKey, 'NCBI Gene Model', 1, 'http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?db=gene&cmd=Retrieve&dopt=Graphics&list_uids=@@@@', 0, null, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
insert into ACC_ActualDB values (@actKey + 1, @logKey + 1, 'Ensembl Gene Model', 1, 'http://www.ensembl.org/Mus_musculus/geneview?gene=@@@@', 0, null, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
go

end

EOSQL

date | tee -a ${LOG}

