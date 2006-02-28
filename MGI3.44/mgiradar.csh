#!/bin/csh -fx

cd `dirname $0` && source ./Configuration

source ${newrdrdbschema}/Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date | tee -a  ${LOG}
 
echo "updateSchemaVersion"
${MGIDBUTILSBINDIR}/updateSchemaVersion.csh ${RDR_DBSERVER} ${RDR_DBNAME} ${RDR_SCHEMA_TAG} | tee -a ${LOG}

# create new MGI_dbinfo table...

${newrdrdbschema}/table/MGI_dbinfo_drop.object | tee -a ${LOG}
${newrdrdbschema}/table/MGI_dbinfo_create.object | tee -a ${LOG}
${newrdrdbperms}/public/table/MGI_dbinfo_grant.object | tee -a ${LOG}

cat - <<EOSQL | doisql.csh $0 | tee -a ${LOG}

use ${RDR_DBNAME}
go

insert MGI_dbinfo values ("$PUBLIC_VERSION", "$MGD_PRODUCTNAME", "$RDR_SCHEMA_TAG",
"$SNP_SCHEMA_TAG", "$SNP_DATAVERSION", getdate(), getdate(), getdate())
go

quit

EOSQL

cat - <<EOSQL | doisql.csh $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

drop table MGI_SNP_Accession
go

drop table MGI_SNP_ConsensusSNP
go

drop table MGI_SNP_Coordinate
go

drop table MGI_SNP_Flank
go

drop table MGI_SNP_Marker
go

drop table MGI_SNP_StrainAllele
go

drop table MGI_SNP_SubSNP
go

quit

EOSQL

date | tee -a  ${LOG}

