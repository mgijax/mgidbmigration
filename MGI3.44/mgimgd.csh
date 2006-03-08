#!/bin/csh -fx

#
# Default:	6
# Procedure:	122
# Rule:		5
# Trigger:	158
# User Table:	182
# View:		229
#

cd `dirname $0` && source ./Configuration

source ${newmgddbschema}/Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date | tee -a  ${LOG}
 
# load a backup
#load_db.csh ${MGD_DBSERVER} ${MGD_DBNAME} /shire/sybase/mgd.backup

echo "updateSchemaVersion"
${MGIDBUTILSBINDIR}/updateSchemaVersion.csh ${MGD_DBSERVER} ${MGD_DBNAME} ${MGD_SCHEMA_TAG} | tee -a ${LOG}

# create new mgd..MGI_dbinfo table...

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

./mgitable.csh | tee -a ${LOG}

date | tee -a  ${LOG}

########################################

cat - <<EOSQL | doisql.csh $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

drop table SNP_ConsensusSnp
go

drop table SNP_ConsensusSnp_Marker
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

drop view SNP_Summary_View
go

exec MGI_Table_Column_Cleanup
go

quit

EOSQL

${newmgddbschema}/reconfig.csh | tee -a ${LOG}
${newmgddbperms}/all_revoke.csh | tee -a ${LOG}
${newmgddbperms}/all_grant.csh | tee -a ${LOG}

date | tee -a  ${LOG}

