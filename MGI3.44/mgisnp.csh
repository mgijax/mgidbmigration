#!/bin/csh -fx

# for SNP

cd `dirname $0` && source ./Configuration

source ${newsnpdbschema}/Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date | tee -a  ${LOG}
 
${MGIDBUTILSBINDIR}/turnonbulkcopy.csh ${SNP_DBSERVER} ${SNP_DBNAME} | tee -a ${LOG}

# create snp..MGI_dbinfo table...

#${newsnpdbschema}/table/MGI_dbinfo_create.object | tee -a ${LOG}
#${newsnpdbperms}/public/table/MGI_dbinfo_grant.object | tee -a ${LOG}

#cat - <<EOSQL | doisql.csh $0 | tee -a ${LOG}

#use ${SNP_DBNAME}
#go

#insert MGI_dbinfo values ("$PUBLIC_VERSION", "$SNP_PRODUCTNAME", "$SNP_SCHEMA_TAG", "$SNP_DATAVERSION",
#getdate(), getdate(), getdate())
#go

#quit

#EOSQL

# create new tables in snp
${newsnpdbschema}/all_create.csh | tee -a ${LOG}
${newsnpdbperms}/all_grant.csh | tee -a ${LOG}

# dump out MGD SNP data
foreach i (SNP_ConsensusSnp SNP_SubSnp SNP_Flank SNP_Population SNP_Coord_Cache SNP_ConsensusSnp_StrainAllele SNP_SubSnp_StrainAllele)
${MGIDBUTILSBINDIR}/bcpout.csh ${newmgddbschema} ${i} | tee -a ${LOG}
${newsnpdbschema}/index/${i}_drop.object | tee -a ${LOG}
${MGIDBUTILSBINDIR}/bcpin.csh ${newsnpdbschema} ${i} | tee -a ${LOG}
${newsnpdbschema}/index/${i}_create.object | tee -a ${LOG}
end

exit 0

cat - <<EOSQL | doisql.csh $0 | tee -a ${LOG}

/* copy MGI_Columns and MGI_Tables information from mgd to snp */

use ${SNP_DBNAME}
go

exec MGI_Table_Column_Cleanup
go

quit

EOSQL

date | tee -a  ${LOG}

