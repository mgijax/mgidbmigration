#!/bin/csh -fx

#
# Migration for TR11750
# (part 1)
#

###----------------------###
###--- initialization ---###
###----------------------###

if ( ${?MGICONFIG} == 0 ) then
	setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}

#
# PLEASE READ!
# FOR TESTING ONLY 
# MAKE SURE BOTH ARE TURNED OFF FOR REAL MIGRATION
#
#${MGI_DBUTILS}/bin/load_db.csh ${RADAR_DBSERVER} ${RADAR_DBNAME} /backups/rohan/scrum-dog/radar.backup
#${MGI_DBUTILS}/bin/load_db.csh ${MGD_DBSERVER} ${MGD_DBNAME} /backups/rohan/scrum-dog/mgd.backup

date | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/ACC_delete_byAccKey_drop.object | tee -a $LOG
${MGD_DBSCHEMADIR}/procedure/ACC_delete_byAccKey_create.object | tee -a $LOG

cat - <<EOSQL | doisql.csh $MGD_DBSERVER $MGD_DBNAME $0 | tee -a $LOG

use $MGD_DBNAME
go

sp_rename NOM_Marker, NOM_Marker_old
go

checkpoint
go

end

EOSQL

${MGD_DBSCHEMADIR}/table/NOM_Marker_create.object | tee -a $LOG

cat - <<EOSQL | doisql.csh $MGD_DBSERVER $MGD_DBNAME $0 | tee -a $LOG

use $MGD_DBNAME
go

insert into NOM_Marker values(_Nomen_key, _Marker_Type_key, _NomenStatus_key, symbol, name, chromosome,
statusNote, broadcast_date, _BroadcastBy_key, _CreatedBy_key, _ModifiedBy_key, 
creation_date, modification_date)
select _Nomen_key, _Marker_Type_key, _NomenStatus_key, symbol, name, chromosome,
statusNote, broadcast_date, _BroadcastBy_key, _CreatedBy_key, _ModifiedBy_key, 
creation_date, modification_date
from NOM_Marker_old
go

drop procedure PRB_getTissueDataSets
go

drop view MGI_Organism_Sequence_View
go

checkpoint
go

end

EOSQL
date | tee -a ${LOG}

${MGD_DBSCHEMADIR}/default/NOM_Marker_bind.object | tee -a $LOG
${MGD_DBSCHEMADIR}/index/NOM_Marker_create.object | tee -a $LOG
${MGD_DBSCHEMADIR}/key/NOM_Marker_create.object | tee -a $LOG
${MGD_DBSCHEMADIR}/procedure/NOM_transferToMGD_create.object | tee -a $LOG
${MGD_DBSCHEMADIR}/procedure/NOM_updateReserved_create.object | tee -a $LOG
${MGD_DBSCHEMADIR}/trigger/NOM_Marker_create.object | tee -a $LOG
${MGD_DBSCHEMADIR}/view/NOM_create.object | tee -a $LOG
${MGD_DBSCHEMADIR}/all_perms.csh | tee -a $LOG

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

delete from ACC_Accession where accid like 'MGD-PMEX-%'
go

delete from MLD_Expts where exptType = 'MAP'
go

drop view MLD_Distance_View
go
drop table MGI_AttributeHistory
go
drop table MLD_PhysMap
go
drop table MLD_Distance
go

drop table ALL_Allele_Old
go

exec MGI_Table_Column_Cleanup
go

update ACC_ActualDB 
set url = 'http://gensat.org/bgem_probe_dump.jsp?probe_id=@@@@' 
where _ActualDB_key = 132
go

EOSQL
date | tee -a ${LOG}

#
# re-fresh
#
${MGD_DBSCHEMADIR}/key/key_drop.csh | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/key_create.csh | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/trigger_drop.csh | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/trigger_create.csh | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/procedure_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/procedure_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/view/view_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/view/view_create.object | tee -a ${LOG}

#
# set permissions & counts
#
${MGD_DBSCHEMADIR}/all_perms.csh | tee -a ${LOG}
${MGD_DBSCHEMADIR}/objectCounter.sh | tee -a ${LOG}

#
# final tests (need full permissions
#
date | tee -a ${LOG}
${DBUTILS}/mgidbmigration/TR11515/allelecollection/allelecollectionTests.csh
date | tee -a ${LOG}

#
# final tests (need full permissions
#
date | tee -a ${LOG}
${DBUTILS}/mgidbmigration/TR11515/alleletype/alleletypeTests.csh
date | tee -a ${LOG}

#
# run sto85/update IMSR/germline
#
${MGI_DBUTILS}/bin/updateIMSRgermline.csh | tee -a ${LOG}
cat ${DATALOADSOUTPUT}/mgi/mgidbutilities/logs/updateIMSRgermline.csh | tee -a ${LOG}

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

