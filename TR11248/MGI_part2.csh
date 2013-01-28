#!/bin/csh -fx

#
# Migration for TR11248
# (part 2 running loads)
#
#

###----------------------###
###--- initialization ---###
###----------------------###

source ../Configuration

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}

env | grep PG | tee -a ${LOG}

date | tee -a ${LOG}

#
# counts
#
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a ${LOG}
select count(*) from SNP_Accession;
select count(*) from SNP_ConsensusSnp;
select count(*) from MRK_Location_Cache;
EOSQL

#
# run snp cache load:  INSYNC=no
${SNPCACHELOAD}/snpmarker.sh | tee -a ${LOG}

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a ${LOG}
select count(*) from SNP_Accession;
select count(*) from SNP_ConsensusSnp;
select count(*) from MRK_Location_Cache;
EOSQL

###-----------------------###
###--- final datestamp ---###
###-----------------------###
date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

