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
 
#
# DP_SNP_Marker - adding 'rs' prefix to accID
#
${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} snp DP_SNP_Marker ${MGI_LIVE}/dbutils/mgidbmigration/tr12963/snp/DP_SNP_Marker.bcp "|"
${PG_SNP_DBSCHEMADIR}/index/DP_SNP_Marker_drop.object | tee -a $LOG || exit 1
${PG_SNP_DBSCHEMADIR}/key/DP_SNP_Marker_drop.object | tee -a $LOG || exit 1

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
ALTER TABLE DP_SNP_Marker RENAME TO DP_SNP_Marker_old;
ALTER TABLE mgd.DP_SNP_Marker_old DROP CONSTRAINT DP_SNP_Marker_pkey CASCADE;
EOSQL

# new table
${PG_SNP_DBSCHEMADIR}/table/DP_SNP_Marker_create.object | tee -a $LOG || exit 1

#
# insert data int new table
#
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

insert into DP_SNP_Marker
select m._snpmarker_key, concat('rs'::text, m.accID::text), entrezgeneid, _fxn_key, chromosome, startcoord, refseqnucleotide, refseqprotein, contig_allele, residue, aa_position, reading_frame 
from DP_SNP_Marker_old m
;

EOSQL

${PG_SNP_DBSCHEMADIR}/index/DP_SNP_Marker_create.object | tee -a $LOG || exit 1
${PG_SNP_DBSCHEMADIR}/key/DP_SNP_Marker_create.object | tee -a $LOG || exit 1

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

select count(*) from DP_SNP_Marker_old;

select count(*) from DP_SNP_Marker;

drop table DP_SNP_Marker_old;

EOSQL

date |tee -a $LOG

