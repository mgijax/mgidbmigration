#!/bin/csh -f

if ( ${?MGICONFIG} == 0 ) then
        setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date | tee -a $LOG
 
${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd MGI_Organism_MGIType ${MGI_LIVE}/dbutils/mgidbmigration/tr13349/MGI_Organism_MGIType.bcp "|"
${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd PWI_Report ${MGI_LIVE}/dbutils/mgidbmigration/tr13349/PWI_Report.bcp "|"

${PG_MGD_DBSCHEMADIR}/index/MGI_Organism_drop.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/index/MGI_Organism_MGIType_drop.object | tee -a $LOG 

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
ALTER TABLE MGI_Organism_MGIType RENAME TO MGI_Organism_MGIType_old;
EOSQL

# new table
${PG_MGD_DBSCHEMADIR}/table/MGI_Organism_MGIType_create.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/autosequence/MGI_Organism_MGIType_create.object | tee -a $LOG 

#
#insert data int new table
#
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

insert into MGI_Organism_MGIType
select nextval('mgi_organism_mgitype_seq'), m._organism_key, m._mgitype_key, m.sequenceNum,
m._CreatedBy_key, m._ModifiedBy_key, m.creation_date, m.modification_date
from MGI_Organism_MGIType_old m
;

delete from mgi_organism_mgitype where _mgitype_key in (18, 19)
;

EOSQL

${PG_MGD_DBSCHEMADIR}/index/MGI_Organism_create.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/index/MGI_Organism_MGIType_create.object | tee -a $LOG

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

select count(*) from MGI_Organism_MGIType_old;
select count(*) from MGI_Organism_MGIType;

update acc_logicaldb set _organism_key = 76 where _organism_key is null;
drop table mgi_organism_mgitype_old;
delete from gxd_assaytype where _assaytype_key in (-1,-2);
-- remove obsolete pwi_report
delete from pwi_report where id in (9,10,11,12,13,36,17);

EOSQL

date | tee -a ${LOG}
# delete coordinate collections RIKEN, MGI, miRBase, GtRNAdb, ePCR BLAST, 
# UniSTS, Tom Sproule, UCSC, MGI_Curation, djr
# 
# delete B38 *loaded* location notes, these were all created on 2017-04-25 
#  and are noteKey 633229215 through 633229231"
#
# delete Homologene, HGNC and Hybrid clusters and their terms in the 
# Marker Cluster Source vocabulary

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

delete from MAP_Coord_Collection where _collection_key in (96, 64, 57, 58, 68, 59, 62, 85, 56, 94)
;

delete from MGI_Note where _note_key between 633229215 and 633229231
;

delete from MRK_Cluster where _clustersource_key in (9272151, 13437099, 13764519)
;

delete from VOC_Term where _vocab_key = 89 and _term_key in (9272151, 13437099, 13764519)
;

delete from mgi_notechunk c where not exists (select 1 from mgi_note s where c._note_key = s._note_key);
delete from mgi_clustermember c where not exists (select 1 from mgi_cluster s where c._cluster_key = s._cluster_key);

EOSQL

# obsolete reports
rm -rf ${QCREPORTDIR}/output/WF_AP_Routed.rpt

date |tee -a $LOG

