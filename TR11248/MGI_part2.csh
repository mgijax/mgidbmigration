#!/bin/csh -fx

#
# Migration for TR11248
# (part 2 running loads)
#
#

###----------------------###
###--- initialization ---###
###----------------------###

source ${DBUTILS}/mgidbmigration/Configuration

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}

env | grep PG | tee -a ${LOG}

date | tee -a ${LOG}

# snp_population, snp_subsnp_strainallele
${DBSNPLOAD}/bin/snpPopulation.sh | tee -a ${LOG}
exit 0

#
# counts
#
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a ${LOG}
select count(*) from snp.SNP_Accession;
select count(*) from snp.SNP_ConsensusSnp;
select count(*) from snp.SNP_ConsensusSnp_Marker;
select count(*) from mgd.MRK_Location_Cache;
EOSQL

#
# run snp cache load:  INSYNC=no
${SNPCACHELOAD}/snpmarker.sh | tee -a ${LOG}

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a ${LOG}
select count(*) from snp.SNP_Accession;
select count(*) from snp.SNP_ConsensusSnp;
select count(*) from snp.SNP_ConsensusSnp_Marker;
select count(*) from mgd.MRK_Location_Cache;
EOSQL

###-----------------------###
###--- final datestamp ---###
###-----------------------###
date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

