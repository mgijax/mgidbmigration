#!/bin/csh -f

#
# migrates gxd_antiben to gxd_antibody table
#
# mgidbmigration
# pgmgddbschema
# mgd_java_api
# pwi
# qcreports_db
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
# GXD_Antibody changes
#
${PG_MGD_DBSCHEMADIR}/key/GXD_Antibody_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/MGI_Organism_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/VOC_Term_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/PRB_Source_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/index/GXD_Antibody_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/procedure/PRB_getStrainDataSets_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/procedure/PRB_processProbeSource_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/trigger/GXD_Antibody_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/view/GXD_drop.logical | tee -a $LOG || exit 1

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

ALTER TABLE mgd.GXD_Antibody DROP CONSTRAINT GXD_Antibody__ModifiedBy_key_fkey CASCADE;
ALTER TABLE mgd.GXD_Antibody DROP CONSTRAINT GXD_Antibody__CreatedBy_key_fkey CASCADE;
ALTER TABLE mgd.GXD_Antigen DROP CONSTRAINT GXD_Antigen__ModifiedBy_key_fkey CASCADE;
ALTER TABLE mgd.GXD_Antigen DROP CONSTRAINT GXD_Antigen__CreatedBy_key_fkey CASCADE;
ALTER TABLE mgd.GXD_Antigen DROP CONSTRAINT GXD_Antigen__Source_key_fkey CASCADE;

drop view if exists mgd.GXD_AntibodyAntigen_View CASCADE;
drop view if exists mgd.GXD_Antigen_View CASCADE;
drop view if exists mgd.GXD_Antigen_Acc_View CASCADE;
drop view if exists mgd.GXD_Antigen_Summary_View CASCADE;

ALTER TABLE GXD_Antibody RENAME TO GXD_Antibody_old;

EOSQL

# new table
# antigenName : not needed
# _Source_key                    int             not null,
# regionCovered                  text            null,
# antigenNote                    text            null,
${PG_MGD_DBSCHEMADIR}/table/GXD_Antibody_create.object | tee -a $LOG || exit 1

#
# insert data into new table
#
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

insert into GXD_Antibody
select a._Antibody_key, 
	a._AntibodyClass_key, 
	a._AntibodyType_key, 
	a._Organism_key,
        b._Source_key,
        a.antibodyName,
        b.regionCovered,
        a.antibodyNote,
        b.antigenNote ,
        a._CreatedBy_key,
        a._ModifiedBy_key,
        a.creation_date,
        a.modification_date
from GXD_Antibody_old a, GXD_Antigen b
where a._Antigen_key = b._Antigen_key
;

EOSQL

# re-set views, keys, etc.
${PG_MGD_DBSCHEMADIR}/key/GXD_Antibody_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/MGI_Organism_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/VOC_Term_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/PRB_Source_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/index/GXD_Antibody_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/procedure/PRB_getStrainDataSets_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/procedure/PRB_processProbeSource_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/procedure/PRB_processSequenceSource_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/trigger/GXD_Antibody_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/view/GXD_create.logical | tee -a $LOG || exit 1

#
# turn on when ready to remove BIB_DataSet* tables
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
ALTER TABLE mgd.GXD_Antibody ADD FOREIGN KEY (_CreatedBy_key) REFERENCES mgd.MGI_User DEFERRABLE;
ALTER TABLE mgd.GXD_Antibody ADD FOREIGN KEY (_ModifiedBy_key) REFERENCES mgd.MGI_User DEFERRABLE;
select count(*) from GXD_Antibody;
select count(*) from GXD_Antibody_old;
drop table mgd.GXD_Antibody_old;
drop table mgd.GXD_Antigen;

EOSQL

cd $QCRPTS
source ./Configuration
cd ${QCMONTHLY}
${QCRPTS}/reports.csh PRB_Reference.sql $QCOUTPUTDIR/PRB_Reference.rpt ${PG_DBSERVER} ${PG_DBNAME}

