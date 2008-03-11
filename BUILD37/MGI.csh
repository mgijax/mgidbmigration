#!/bin/csh -f

#
# Migration for Build 37
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date | tee -a  ${LOG}
 
# load a backup
#load_db.csh ${MGD_DBSERVER} ${MGD_DBNAME} /shire/sybase/mgd.backup
#load_db.csh ${RADAR_DBSERVER} ${RADAR_DBNAME} /shire/sybase/radar.backup

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
/*ENSEMBL delete all that were NOT created by the "Ensembl Association Load"*/
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

/* VEGA delete all that were NOT created by the "Ensembl Association Load"*/
select _Accession_key
into #toDeleteVega
from SEQ_Sequence s, ACC_Accession a
where a._LogicalDB_key = 85
and a._MGIType_key = 2
and a._createdBy_key != 1439
and a._Object_key = s._Sequence_key
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

EOSQL

date | tee -a  ${LOG}

