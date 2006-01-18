#!/bin/csh -f

#
# Migration for 3.4 (SNP)
# Defaults: 6
# Procedures: 122   
# Rules: 5
# Triggers: 158
# User Tables: 190
# Views: 230

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date | tee -a  ${LOG}

#
# RADAR database stuff
#

./radar.csh

#
# MGD database stuff
#

echo "turnonbulkcopy" 
${DBUTILSBINDIR}/turnonbulkcopy.csh ${DBSERVER} ${DBNAME} | tee -a ${LOG}

echo "loading mgd backup"
load_db.csh ${DBSERVER} ${DBNAME} /shire/sybase/mgd.backup | tee -a ${LOG}

#update schema tag
echo "updatePublicVersion"
${DBUTILSBINDIR}/updatePublicVersion.csh ${DBSERVER} ${DBNAME} "${PUBLIC_VERSION}" | tee -a ${LOG}

echo "updateSchemaVersion"
${DBUTILSBINDIR}/updateSchemaVersion.csh ${DBSERVER} ${DBNAME} ${SCHEMA_TAG} | tee -a ${LOG}

date | tee -a  ${LOG}

echo "drop/create SNP_tables etc"
${newmgddbschema}/table/SNP_drop.logical | tee -a ${LOG}
${newmgddbschema}/table/SNP_create.logical | tee -a ${LOG}
${newmgddbschema}/key/SNP_create.logical | tee -a ${LOG}
${newmgddbschema}/index/SNP_create.logical | tee -a ${LOG}

${newmgddbperms}/public/table/SNP_grant.logical | tee -a ${LOG}

# delete snp accessions
cat - <<EOSQL | doisql.csh $0 | tee -a ${LOG}

use ${DBNAME}
go

select a._Accession_key 
	into tempdb..todelete 
	from ACC_Accession a 
	where a._MGIType_key = 30
	and a._LogicalDB_key = 73
	UNION 
	select a._Accession_key 
	from ACC_Accession a 
	where a._MGIType_key = 31 
	and a._LogicalDB_key = 74
	UNION 
	select a._Accession_key 
	from ACC_Accession a 
	where a._MGIType_key = 31 
	and a._LogicalDB_key = 75
go

create index idx1 on tempdb..todelete(_Accession_key)
go

delete ACC_Accession 
from tempdb..todelete d, ACC_Accession a 
where d._Accession_key = a._Accession_key
go

drop table tempdb..todelete
go

quit
EOSQL

echo "alter ACC_Accession.prefixPart"
./mgiacc.csh | tee -a ${LOG}

echo "drop PhenoSlim annotations"
./mgips.csh | tee -a ${LOG}

#echo "reconfig" | tee -a ${LOG}
#${newmgddbschema}/reconfig.csh | tee -a ${LOG}

#echo " revoke/grant all" | tee -a ${LOG}
#${newmgddbperms}/all_revoke.csh | tee -a ${LOG}
#${newmgddbperms}/all_grant.csh | tee -a ${LOG}

#${DBUTILSBINDIR}/updateStatisticsAll.csh ${newmgddbschema} | tee -a ${LOG}

date | tee -a  ${LOG}

