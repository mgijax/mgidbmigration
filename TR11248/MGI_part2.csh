#!/bin/csh -fx

#
# Migration for TR11248
# (part 2 running loads)
#
#

###----------------------###
###--- initialization ---###
###----------------------###

if ( ${?MGICONFIG} == 0 ) then
        setenv MGICONFIG /usr/local/mgi/test/mgiconfig
endif

source ${MGICONFIG}/master.config.csh


# start a new log file for this migration, and add a datestamp

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}

env | grep PG | tee -a ${LOG}

date | tee -a ${LOG}

# snp_population, snp_subsnp_strainallele
${DBSNPLOAD}/bin/snpPopulation.sh | tee -a ${LOG}

#
# take a backup
#
${PG_DBUTILS}/bin/dumpDB.csh ${PG_DBSERVER} ${PG_DBNAME} snp /export/dump/snp.part2.postgres.dump
date | tee -a ${LOG}

#
# counts
#
#cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a ${LOG}
#select count(*) from snp.SNP_Accession;
#select count(*) from snp.SNP_ConsensusSnp;
#select count(*) from snp.SNP_ConsensusSnp_Marker;
#select count(*) from mgd.MRK_Location_Cache;
#EOSQL

#
# run snp cache load:  INSYNC=no
#${SNPCACHELOAD}/snpmarker.sh | tee -a ${LOG}

#cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a ${LOG}
#select count(*) from snp.SNP_Accession;
#select count(*) from snp.SNP_ConsensusSnp;
#select count(*) from snp.SNP_ConsensusSnp_Marker;
#select count(*) from mgd.MRK_Location_Cache;
#EOSQL

#
# load backup/'export' to 'dev'
#
#${PG_DBUTILS}/bin/loadDB.csh ${PG_DBSERVER} pub_dev mgd /export/dump/mgd.postgres.dump | tee -a ${LOG}
${PG_DBUTILS}/bin/loadDB.csh ${PG_DBSERVER} pub_dev snp /export/dump/snp.part2.postgres.dump | tee -a ${LOG}
#${PG_DBUTILS}/bin/loadDB.csh ${PG_DBSERVER} pub_stable mgd /export/dump/mgd.postgres.dump | tee -a ${LOG}
${PG_DBUTILS}/bin/loadDB.csh ${PG_DBSERVER} pub_stable snp /export/dump/snp.part2.postgres.dump | tee -a ${LOG}

###-----------------------###
###--- final datestamp ---###
###-----------------------###
date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

