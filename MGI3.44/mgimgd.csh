#!/bin/csh -fx

#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date | tee -a  ${LOG}
 
# create mgd..MGI_dbinfo table...

${newmgddbschema}/table/MGI_dbinfo_drop.object | tee -a ${LOG}
${newmgddbschema}/table/MGI_dbinfo_create.object | tee -a ${LOG}
${newmgddbperms}/public/table/MGI_dbinfo_grant.object | tee -a ${LOG}

cat - <<EOSQL | doisql.csh $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

insert MGI_dbinfo values ("$PUBLIC_VERSION", "$MGD_PRODUCTNAME", "$MGD_SCHEMA_TAG",
"$SNP_SCHEMA_TAG", "$SNP_DATAVERSION", getdate(), getdate(), getdate())
go

quit

EOSQL

# revised tables in mgd
${newmgddbschema}/table/SNP_ConsensusSnp_Marker_drop.csh | tee -a ${LOG}
${newmgddbschema}/table/SNP_ConsensusSnp_Marker_create.csh | tee -a ${LOG}

date | tee -a  ${LOG}

########################################

cat - <<EOSQL | doisql.csh $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

drop table SNP_Consensus_Snp
go

drop table SNP_SubSnp
go

drop table SNP_ConsensusSnp_StrainAllele
go

drop table SNP_SubSnp_StrainAllele
go

drop table SNP_Flank
go

drop table SNP_Population
go

drop table SNP_Coord_Cache
go

exec MGI_Table_Column_Cleanup
go

quit

EOSQL

${newmgddbschema}/reconfig.csh | tee -a ${LOG}
${newmgddbperms}/all_revoke.csh | tee -a ${LOG}
${newmgddbperms}/all_grant.csh | tee -a ${LOG}

date | tee -a  ${LOG}

