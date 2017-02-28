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

${PG_MGD_DBSCHEMADIR}/trigger/trigger_drop.sh | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/view/view_drop.sh | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/procedure/ALL_insertAllele_create.object | tee -a $LOG

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

drop index if exists mgd.ALL_Allele_idx_nomenSymbol;

ALTER TABLE ALL_Allele DROP COLUMN nomenSymbol;

ALTER TABLE ALL_Cre_Cache ALTER COLUMN symbol TYPE text;
ALTER TABLE ALL_Cre_Cache ALTER COLUMN age TYPE text;
ALTER TABLE ALL_Knockout_Cache ALTER COLUMN holder TYPE text;
ALTER TABLE ALL_Knockout_Cache ALTER COLUMN repository TYPE text;
ALTER TABLE ALL_Knockout_Cache ALTER COLUMN companyID TYPE text;
ALTER TABLE ALL_Knockout_Cache ALTER COLUMN nihID TYPE text;
ALTER TABLE ALL_Knockout_Cache ALTER COLUMN jrsID TYPE text;
ALTER TABLE ALL_Label ALTER COLUMN labelType TYPE text;
ALTER TABLE MRK_Location_Cache ALTER COLUMN chromosome TYPE text;
ALTER TABLE MRK_Location_Cache ALTER COLUMN cytogeneticOffset TYPE text;
ALTER TABLE MRK_Location_Cache ALTER COLUMN genomicChromosome TYPE text;
ALTER TABLE MRK_Location_Cache ALTER COLUMN mapUnits TYPE text;
ALTER TABLE MRK_MCV_Cache ALTER COLUMN term TYPE text;
ALTER TABLE SEQ_Coord_Cache ALTER COLUMN chromosome TYPE text;
ALTER TABLE SEQ_Coord_Cache ALTER COLUMN mapUnits TYPE text;

ALTER TABLE MGI_Organism ALTER COLUMN commonName TYPE text;
ALTER TABLE MGI_Organism ALTER COLUMN latinName TYPE text;
ALTER TABLE MGI_Statistic ALTER COLUMN abbreviation TYPE text;
ALTER TABLE MGI_TranslationType ALTER COLUMN compressionChars TYPE text;
ALTER TABLE MGI_User ALTER COLUMN login TYPE text;
ALTER TABLE MGI_dbinfo ALTER COLUMN public_version TYPE text;
ALTER TABLE MGI_dbinfo ALTER COLUMN product_name TYPE text;
ALTER TABLE MGI_dbinfo ALTER COLUMN schema_version TYPE text;
ALTER TABLE MGI_dbinfo ALTER COLUMN snp_schema_version TYPE text;
ALTER TABLE MGI_dbinfo ALTER COLUMN snp_data_version TYPE text;

ALTER TABLE MLD_Assay_Types ALTER COLUMN description TYPE text;
ALTER TABLE MLD_Concordance ALTER COLUMN chromosome TYPE text;
ALTER TABLE MLD_Contig ALTER COLUMN name TYPE text;
ALTER TABLE MLD_Expt_Marker ALTER COLUMN gene TYPE text;
ALTER TABLE MLD_Expts ALTER COLUMN chromosome TYPE text;
ALTER TABLE MLD_FISH_Region ALTER COLUMN region TYPE text;
ALTER TABLE MLD_FISH ALTER COLUMN band TYPE text;
ALTER TABLE MLD_FISH ALTER COLUMN cellOrigin TYPE text;
ALTER TABLE MLD_FISH ALTER COLUMN karyotype TYPE text;
ALTER TABLE MLD_FISH ALTER COLUMN label TYPE text;
ALTER TABLE MLD_Hybrid ALTER COLUMN band TYPE text;
ALTER TABLE MLD_ISRegion ALTER COLUMN region TYPE text;
ALTER TABLE MLD_InSitu ALTER COLUMN band TYPE text;
ALTER TABLE MLD_InSitu ALTER COLUMN cellOrigin TYPE text;
ALTER TABLE MLD_InSitu ALTER COLUMN karyotype TYPE text;

EOSQL

${PG_MGD_DBSCHEMADIR}/trigger/trigger_create.sh | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/view/view_create.sh | tee -a $LOG

${ALLCACHELOAD}/allelecrecache.csh | tee -a $LOG
${ALLCACHELOAD}/alllabel.csh | tee -a $LOG
${MRKCACHELOAD}/mrklocation.csh | tee -a $LOG
${MRKCACHELOAD}/mrkmcv.csh | tee -a $LOG
${SEQCACHELOAD}/seqcoord.csh | tee -a $LOG

date |tee -a $LOG

