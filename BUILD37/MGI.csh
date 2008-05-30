#!/bin/csh -f

#
# Migration for Build 37
#

cd `dirname $0` && source ../Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date | tee -a  ${LOG}
 
date
echo 'Updating version numbers in the database'
${MGI_DBUTILS}/bin/updatePublicVersion.csh ${MGD_DBSERVER} ${MGD_DBNAME} "MGI 4.1"
${MGI_DBUTILS}/bin/updateSnpDataVersion.csh ${MGD_DBSERVER} ${MGD_DBNAME} "dbSNP Build 128"

########################################

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

/* delete obsolete gene model sequences */

/* ENSEMBL obsoletes are owned by Sophia, yz, 1093 */
exec SEQ_deleteByCreatedBy 'yz'
go

/* VEGA obsoletes are owned by Reddy, tbreddy, 1095 */
exec SEQ_deleteByCreatedBy 'tbreddy'
go

/* delete obsolete gene model associations */

/* ENSEMBL delete all that were NOT created by the "Ensembl Association Load"*/
select _Accession_key
into #toDeleteEnsembl
from ACC_Accession a
where a._LogicalDB_key = 60
and a._MGIType_key = 2
and a._createdBy_key != 1443
go

delete ACC_AccessionReference
from ACC_AccessionReference a, #toDeleteEnsembl d
where a._Accession_key = d._Accession_key
go

delete ACC_Accession
from ACC_Accession a, #toDeleteEnsembl d
where a._Accession_key = d._Accession_key
go

/* VEGA delete all that were NOT created by the "VEGA Association Load"*/
select _Accession_key
into #toDeleteVega
from ACC_Accession a
where a._LogicalDB_key = 85
and a._MGIType_key = 2
and a._createdBy_key != 1445
go

delete ACC_AccessionReference
from ACC_AccessionReference a, #toDeleteVega d
where a._Accession_key = d._Accession_key
go

delete ACC_Accession
from ACC_Accession a, #toDeleteVega d
where a._Accession_key = d._Accession_key
go

/* delete obsolete gene model maps/collections */
exec MAP_deleteByCollection "ENSEMBL 39 Gene Model"
go

exec MAP_deleteByCollection "VEGA 22 Gene Model"
go

/* delete mirBase/marker associations */
/* mirbaseload will NOT delete the curated associations */
delete from ACC_Accession
where _LogicalDB_key = 83 and
      _MGIType_key = 2
go

EOSQL

# TR8962
#
${MGD_DBSCHEMADIR}/procedure/BIB_getCopyright_drop.object
${MGD_DBSCHEMADIR}/procedure/BIB_getCopyright_create.object
${MGD_DBPERMSDIR}/public/procedure/BIB_getCopyright_grant.object

date | tee -a  ${LOG}

