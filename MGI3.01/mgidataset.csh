#!/bin/csh -f

#
# Migration for: Data Set
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date >> ${LOG}
echo 'DataSet Migration...' | tee -a ${LOG}

cat - <<EOSQL | doisql.csh $0 | tee -a ${LOG}

use ${DBNAME}
go

sp_rename BIB_Refs, BIB_Refs_Old
go

end

EOSQL

${newmgddbschema}/table/BIB_DataSet_Assoc_create.object | tee -a ${LOG}
${newmgddbschema}/table/BIB_DataSet_create.object | tee -a ${LOG}
${newmgddbschema}/table/BIB_Refs_create.object | tee -a ${LOG}
${newmgddbschema}/default/BIB_DataSet_Assoc_bind.object | tee -a ${LOG}
${newmgddbschema}/default/BIB_DataSet_bind.object | tee -a ${LOG}
${newmgddbschema}/default/BIB_Refs_bind.object | tee -a ${LOG}
${newmgddbschema}/key/BIB_DataSet_Assoc_create.object | tee -a ${LOG}
${newmgddbschema}/key/BIB_DataSet_create.object | tee -a ${LOG}
${newmgddbschema}/key/BIB_Refs_create.object | tee -a ${LOG}
${newmgddbschema}/key/MGI_User_drop.object | tee -a ${LOG}
${newmgddbschema}/key/MGI_User_create.object | tee -a ${LOG}
${newmgddbschema}/key/BIB_ReviewStatus_drop.object | tee -a ${LOG}
${newmgddbschema}/key/BIB_ReviewStatus_create.object | tee -a ${LOG}
${newmgddbschema}/key/VOC_Term_drop.object | tee -a ${LOG}
${newmgddbschema}/key/VOC_Term_create.object | tee -a ${LOG}
${newmgddbschema}/procedure/BIB_isNOGO_drop.object | tee -a ${LOG}
${newmgddbschema}/procedure/BIB_isNOGO_create.object | tee -a ${LOG}
${newmgddbschema}/procedure/BIB_removeNOGO_drop.object | tee -a ${LOG}
${newmgddbschema}/procedure/BIB_removeNOGO_create.object | tee -a ${LOG}
${newmgddbschema}/view/BIB_drop.logical | tee -a ${LOG}
${newmgddbschema}/view/BIB_create.logical | tee -a ${LOG}
${newmgddbschema}/view/IMG_Image_Summary_View_drop.object | tee -a ${LOG}
${newmgddbschema}/view/IMG_Image_Summary_View_create.object | tee -a ${LOG}
${newmgddbschema}/view/MLD_Summary_View_drop.object | tee -a ${LOG}
${newmgddbschema}/view/MLD_Summary_View_create.object | tee -a ${LOG}

cat - <<EOSQL | doisql.csh $0 | tee -a ${LOG}

use ${DBNAME}
go

insert into BIB_Refs
select o._Refs_key, o._ReviewStatus_key, o.refType, o.authors, o.authors2,
o._primary, o.title, o.title2, o.journal, o.vol, o.issue, o.date, o.year, 
o.pgs, o.NLMstatus, o.abstract, o.isReviewArticle, 1000, 1000,
o.creation_date, o.modification_date
from BIB_Refs_Old o
go

insert into BIB_DataSet values(1000,'Molecular Segments', 'Probes/Seq', 'BIB_PRB_Exists', 1, 0, 1000, 1000, getdate(), getdate())
insert into BIB_DataSet values(1001,'Mapping','Mapping', 'BIB_MLD_Exists', 2, 0, 1000, 1000, getdate(), getdate())
insert into BIB_DataSet values(1002,'Mouse Locus Catalog','MLC/Allele', 'BIB_MLC_Exists', 3, 0, 1000, 1000, getdate(), getdate())
insert into BIB_DataSet values(1003,'Homology','Homology', 'BIB_HMD_Exists', 4, 0, 1000, 1000, getdate(), getdate())
insert into BIB_DataSet values(1004,'Expression','Expression', 'BIB_GXD_Exists', 5, 0, 1000, 1000, getdate(), getdate())
insert into BIB_DataSet values(1005,'Gene Ontology','GO', 'BIB_GO_Exists', 6, 0, 1000, 1000, getdate(), getdate())
insert into BIB_DataSet values(1006,'Nomenclature','Nomen', 'BIB_NOM_Exists', 7, 0, 1000, 1000, getdate(), getdate())
insert into BIB_DataSet values(1007,'Tumor', 'Tumor', null, 8, 0, 1000, 1000, getdate(), getdate())
insert into BIB_DataSet values(1008,'Strain Characteristics Catalogue', 'SCC', null, 9, 0, 1000, 1000, getdate(), getdate())
insert into BIB_DataSet values(1009,'Chromosome Committee', 'CC', null, 10, 1, 1000, 1000, getdate(), getdate())
go

end

EOSQL

# load new BIB_DataSet table

./mgidataset.py | tee -a ${LOG}
cat ${DBPASSWORDFILE} | bcp ${DBNAME}..BIB_DataSet_Assoc in BIB_DataSet_Assoc.bcp -S${DBSERVER} -U${DBUSER} -c -t"\t" | tee -a ${LOG}

${newmgddbschema}/index/BIB_DataSet_Assoc_create.object | tee -a ${LOG}
${newmgddbschema}/index/BIB_DataSet_create.object | tee -a ${LOG}
${newmgddbschema}/index/BIB_Refs_create.object | tee -a ${LOG}
${newmgddbschema}/trigger/BIB_DataSet_create.object | tee -a ${LOG}
${newmgddbschema}/trigger/BIB_Refs_drop.object | tee -a ${LOG}
${newmgddbschema}/trigger/BIB_Refs_create.object | tee -a ${LOG}
${newmgddbschema}/trigger/BIB_ReviewStatus_drop.object | tee -a ${LOG}
${newmgddbschema}/trigger/BIB_ReviewStatus_create.object | tee -a ${LOG}

date >> ${LOG}

