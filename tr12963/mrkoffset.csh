#!/bin/csh -f

#
# Template
#


if ( ${?MGICONFIG} == 0 ) then
        setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date | tee -a $LOG
 
#
# MRK_Marker : adding cmOffset
# MRK_Offset : removing
#
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
ALTER TABLE MRK_Marker RENAME TO MRK_Marker_old;
ALTER TABLE mgd.MRK_Marker_old DROP CONSTRAINT MRK_Marker_pkey CASCADE;
EOSQL

# new table
${PG_MGD_DBSCHEMADIR}/table/MRK_Marker_create.object | tee -a $LOG || exit 1

#
# insert data int new table
#
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

insert into MRK_Marker
select m._Marker_key, m._Organism_key, m._Marker_status_key, m._Marker_Type_key,
m.symbol, m.name, m.chromosome, m.cytogeneticOffset, null,
m._CreatedBy_key, m._ModifiedBy_key, m.creation_date, m.modification_date
from MRK_Marker_old m
where m._Organism_key != 1
;

insert into MRK_Marker
select m._Marker_key, m._Organism_key, m._Marker_status_key, m._Marker_Type_key,
m.symbol, m.name, m.chromosome, m.cytogeneticOffset, s.cmOffset,
m._CreatedBy_key, m._ModifiedBy_key, m.creation_date, m.modification_date
from MRK_Marker_old m, MRK_Offset s
where m._Organism_key = 1
and m._Marker_key = s._Marker_key
and s.source = 0
;

ALTER TABLE mgd.MRK_Marker ADD FOREIGN KEY (_Organism_key) REFERENCES mgd.MGI_Organism DEFERRABLE;
ALTER TABLE mgd.MRK_Marker ADD FOREIGN KEY (_CreatedBy_key) REFERENCES mgd.MGI_User DEFERRABLE;
ALTER TABLE mgd.MRK_Marker ADD FOREIGN KEY (_ModifiedBy_key) REFERENCES mgd.MGI_User DEFERRABLE;
ALTER TABLE mgd.MRK_Marker ADD FOREIGN KEY (_Marker_Status_key) REFERENCES mgd.MRK_Status DEFERRABLE;
ALTER TABLE mgd.MRK_Marker ADD FOREIGN KEY (_Marker_Type_key) REFERENCES mgd.MRK_Types DEFERRABLE;

EOSQL

${PG_MGD_DBSCHEMADIR}/index/MRK_Marker_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/MRK_Marker_create.object | tee -a $LOG || exit 1

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
--drop table mgd.MRK_Marker_old;
--drop table mgd.MRK_Offset;
EOSQL

date |tee -a $LOG

