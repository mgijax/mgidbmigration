#!/bin/csh -fx

cd `dirname $0` && source ./Configuration

source ${newrdrdbschema}/Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date | tee -a  ${LOG}
 
echo "updateSchemaVersion"
${MGIDBUTILSBINDIR}/updateSchemaVersion.csh ${RDR_DBSERVER} ${RDR_DBNAME} ${RDR_SCHEMA_TAG} | tee -a ${LOG}

cat - <<EOSQL | doisql.csh $0 | tee -a ${LOG}

use ${RADAR_DBNAME}
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

