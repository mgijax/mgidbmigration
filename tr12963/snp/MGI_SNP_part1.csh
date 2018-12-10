#!/bin/csh -fx

#
# (part 1 running SNP schema changes)
#
#

###----------------------###
###--- initialization ---###
###----------------------###

if ( ${?MGICONFIG} == 0 ) then
	setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}

date | tee -a ${LOG}
echo '--- starting SNP part 1' | tee -a $LOG

echo 'MGD_DBNAME='$MGD_DBNAME | tee -a $LOG || exit 1
echo 'MGD_DBPASSWORDFILE='$MGD_DBPASSWORDFILE | tee -a $LOG || exit 1
echo 'MGD_DBSERVER='$MGD_DBSERVER | tee -a $LOG || exit 1
echo 'MGD_DBUSER='$MGD_DBUSER | tee -a $LOG || exit 1

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

drop index if exists snp.SNP_Accession_idx_accID;
drop index if exists snp.SNP_Accession_idx_prefixPart;

drop index if exists snp.DP_SNP_Marker_idx_entrezGeneId;
drop index if exists snp.DP_SNP_Marker_idx_accID;

drop index if exists snp.SNP_Coord_Cache_idx_clustered;

drop index if exists snp.SNP_Population_idx_name;

drop index if exists snp.SNP_Strain_idx_strain;

drop index if exists snp.SNP_Transcript_Protein_idx_clustered;

ALTER TABLE SNP_Accession ALTER COLUMN accID TYPE text;
ALTER TABLE SNP_Accession ALTER COLUMN prefixPart TYPE text;

ALTER TABLE DP_SNP_Marker ALTER COLUMN accID TYPE text;
ALTER TABLE DP_SNP_Marker ALTER COLUMN entrezGeneId TYPE text;
ALTER TABLE DP_SNP_Marker ALTER COLUMN chromosome TYPE text;
ALTER TABLE DP_SNP_Marker ALTER COLUMN refseqNucleotide TYPE text;
ALTER TABLE DP_SNP_Marker ALTER COLUMN refseqProtein TYPE text;
ALTER TABLE DP_SNP_Marker ALTER COLUMN residue TYPE text;

ALTER TABLE SNP_ConsensusSnp  ALTER COLUMN alleleSummary TYPE text;
ALTER TABLE SNP_ConsensusSnp  ALTER COLUMN buildCreated TYPE text;
ALTER TABLE SNP_ConsensusSnp  ALTER COLUMN buildUpdated TYPE text;

ALTER TABLE SNP_ConsensusSnp_Marker ALTER COLUMN residue TYPE text;
ALTER TABLE SNP_ConsensusSnp_Marker ALTER COLUMN distance_direction TYPE text;

ALTER TABLE SNP_Coord_Cache ALTER COLUMN chromosome TYPE text;
ALTER TABLE SNP_Coord_Cache ALTER COLUMN alleleSummary TYPE text;

ALTER TABLE SNP_Flank ALTER COLUMN flank TYPE text;

ALTER TABLE SNP_Population ALTER COLUMN subHandle TYPE text;
ALTER TABLE SNP_Population ALTER COLUMN name TYPE text;

ALTER TABLE SNP_Strain ALTER COLUMN strain TYPE text;

ALTER TABLE SNP_SubSnp ALTER COLUMN alleleSummary TYPE text;

ALTER TABLE SNP_SubSnp_StrainAllele ALTER COLUMN allele TYPE text;

ALTER TABLE SNP_Transcript_Protein ALTER COLUMN transcriptID TYPE text;
ALTER TABLE SNP_Transcript_Protein ALTER COLUMN proteinID TYPE text;

create index SNP_Accession_idx_accID on snp.SNP_Accession (accID);
create index SNP_Accession_idx_prefixPart on snp.SNP_Accession (prefixPart);

create index DP_SNP_Marker_idx_entrezGeneId on snp.DP_SNP_Marker (entrezGeneId);create index DP_SNP_Marker_idx_accID on snp.DP_SNP_Marker (accID);

create index SNP_Coord_Cache_idx_clustered on snp.SNP_Coord_Cache(chromosome, startCoordinate);
CLUSTER snp.SNP_Coord_Cache USING SNP_Coord_Cache_idx_clustered;

create index SNP_Population_idx_name on snp.SNP_Population (name);

create index SNP_Strain_idx_strain on snp.SNP_Strain (strain);

create index SNP_Transcript_Protein_idx_clustered on snp.SNP_Transcript_Protein (transcriptID, proteinID);

CLUSTER snp.SNP_Transcript_Protein USING SNP_Transcript_Protein_idx_clustered;

EOSQL

${PG_MGD_DBSCHEMADIR}/objectCounter.sh | tee -a $LOG || exit 1

#${PG_DBUTILS}/bin/vacuumDB.csh ${PG_DBSERVER} ${PG_DBNAME} | tee -a $LOG || exit 1
#${PG_DBUTILS}/bin/analyzeDB.csh ${PG_DBSERVER} ${PG_DBNAME} | tee -a $LOG || exit 1

echo 'rebuilding Java Frameworks libraries' | tee -a $LOG
${MGI_JAVALIB}/lib_java_dbsmgd/Install | tee -a $LOG
${MGI_JAVALIB}/lib_java_dla/Install | tee -a $LOG

echo 'gxdexpression migration' | tee -a $LOG
./snpStrainsPop.csh | tee -a $LOG || exit 1

date | tee -a ${LOG}
echo '--- finished SNP part 1' | tee -a ${LOG}

