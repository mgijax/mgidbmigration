#!/bin/csh -f

#
# Migration for: Data Sets
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date >> ${LOG}
echo 'DataSet Migration...' | tee -a ${LOG}

#cat - <<EOSQL | doisql.csh $0 >> ${LOG}

#use ${DBNAME}
#go

#sp_rename BIB_Refs, BIB_Refs_Old
#go

#end

#EOSQL

${newmgddbschema}/table/BIB_DataSets_Assoc_create.object | tee -a ${LOG}
${newmgddbschema}/table/BIB_DataSets_create.object | tee -a ${LOG}
${newmgddbschema}/key/BIB_DataSets_Assoc_create.object | tee -a ${LOG}
${newmgddbschema}/key/BIB_DataSets_create.object | tee -a ${LOG}
${newmgddbschema}/index/BIB_DataSets_Assoc_create.object | tee -a ${LOG}
${newmgddbschema}/index/BIB_DataSets_create.object | tee -a ${LOG}
${newmgddbschema}/trigger/BIB_DataSets_create.object | tee -a ${LOG}
${newmgddbschema}/trigger/BIB_Refs_drop.object | tee -a ${LOG}
${newmgddbschema}/trigger/BIB_Refs_create.object | tee -a ${LOG}
${newmgddbperms}/curatorial/table/BIB_DataSets_Assoc_grant.object | tee -a ${LOG}
${newmgddbperms}/curatorial/table/BIB_DataSets_grant.object | tee -a ${LOG}
${newmgddbperms}/curatorial/table/BIB_Refs_grant.object | tee -a ${LOG}
${newmgddbperms}/public/table/BIB_DataSets_Assoc_grant.object | tee -a ${LOG}
${newmgddbperms}/public/table/BIB_DataSets_grant.object | tee -a ${LOG}
${newmgddbperms}/public/table/BIB_Refs_grant.object | tee -a ${LOG}

cat - <<EOSQL | doisql.csh $0 >> ${LOG}

use ${DBNAME}
go

insert into BIB_DataSets values(1000,'Chromosome Committee', 'CC', null, 1000, 1000, getdate(), getdate())
insert into BIB_DataSets values(1001,'Expression','Expression', 'BIB_GXD_Exists', 1000, 1000, getdate(), getdate())
insert into BIB_DataSets values(1002,'Gene Ontology','GO', 'BIB_GO_Exists', 1000, 1000, getdate(), getdate())
insert into BIB_DataSets values(1003,'Homology','Homology', 'BIB_HMD_Exists', 1000, 1000, getdate(), getdate())
insert into BIB_DataSets values(1004,'Mapping','Mapping', 'BIB_MLD_Exists', 1000, 1000, getdate(), getdate())
insert into BIB_DataSets values(1005,'Mouse Locus Catalog','MLC', 'BIB_MLC_Exists', 1000, 1000, getdate(), getdate())
insert into BIB_DataSets values(1006,'Nomenclature','Nomen', 'BIB_NOM_Exists', 1000, 1000, getdate(), getdate())
insert into BIB_DataSets values(1007,'Molecular Segments', 'Probes', 'BIB_PRB_Exists', 1000, 1000, getdate(), getdate())
insert into BIB_DataSets values(1008,'Strain Characteristics Catalogue', 'SCC', null, 1000, 1000, getdate(), getdate())
insert into BIB_DataSets values(1009,'Tumor', 'Tumor', null, 1000, 1000, getdate(), getdate())
go

end

EOSQL

# load new BIB_DataSets table

./mgidataset.py >>& ${LOG}
cat ${DBPASSWORDFILE} | bcp ${DBNAME}..BIB_DataSets_Assoc in BIB_DataSets_Assoc.bcp -S${DBSERVER} -U${DBUSER} -c -t"\t" | tee -a ${LOG}

date >> ${LOG}

