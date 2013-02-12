#!/bin/csh -f

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

setenv PART2LOG $0.log.$$
rm -rf ${PART2LOG}
touch ${PART2LOG}

setenv OUTPUTDIR ${DATALOADSOUTPUT}/dbsnp/dbsnpload/output
setenv LOGSDIR ${DATALOADSOUTPUT}/dbsnp/dbsnpload/logs
rm -rf ${LOGSDIR}/*

#
# snp_population, snp_subsnp_strainallele
#
echo 'START: running snp_population' | tee -a ${PART2LOG}
date | tee -a ${PART2LOG}
${DBSNPLOAD}/bin/snpPopulation.sh | tee -a ${PART2LOG}
date | tee -a ${PART2LOG}
echo 'DONE: snp_population' | tee -a ${PART2LOG}

#
# dbsnpload
#
echo 'START: running dbsnpload' | tee -a ${PART2LOG}
date | tee -a ${PART2LOG}
${DATALOAD}/dbsnpload/bin/dbsnpload.sh | tee -a ${PART2LOG}
date | tee -a ${PART2LOG}
echo 'DONE: dbsnpload' | tee -a ${PART2LOG}

#
# update strains
#
echo 'START: running updateSnpStrainOrder' | tee -a ${PART2LOG}
date | tee -a ${PART2LOG}
${DBSNPLOAD}/bin/updateSnpStrainOrder.sh | tee -a ${PART2LOG}
date | tee -a ${PART2LOG}
echo 'DONE: updateSnpStrainOrder' | tee -a ${PART2LOG}

# remove keys and indexes
echo 'START: remove database keys and indexes' | tee -a ${PART2LOG}
#psql -h ${PG_DBSERVER} -d ${PG_DBNAME} -U ${PG_DBUSER} --command "delete from SNP_Accession where _mgitype_key != 33"
${PG_SNP_DBSCHEMADIR}/key/key_drop.sh | tee -a ${PART2LOG}
${PG_SNP_DBSCHEMADIR}/index/index_drop.sh | tee -a ${PART2LOG}
echo 'DONE: database keys and indexes' | tee -a ${PART2LOG}

echo 'START: bcping in each table' | tee -a ${PART2LOG}
date | tee -a ${PART2LOG}
foreach i (DP_SNP_Marker \
       SNP_Strain \
       SNP_ConsensusSnp \
       SNP_ConsensusSnp_StrainAllele \
       SNP_Coord_Cache \
       SNP_Flank \
       SNP_SubSnp \
       SNP_SubSnp_StrainAllele)
${PG_SNP_DBSCHEMADIR}/table/${i}_truncate.object | tee -a ${PART2LOG}
psql -h ${PG_DBSERVER} -d ${PG_DBNAME} -U ${PG_DBUSER} --command "\copy snp.${i} from '${OUTPUTDIR}/${i}.bcp' with null as ''" | tee -a ${PART2LOG}
end
foreach i (SNP_Accession)
psql -h ${PG_DBSERVER} -d ${PG_DBNAME} -U ${PG_DBUSER} --command "\copy snp.${i} from '${OUTPUTDIR}/${i}.bcp' with null as ''" | tee -a ${PART2LOG}
end
date | tee -a ${PART2LOG}
echo 'DONE: bcping in each table' | tee -a ${PART2LOG}

# install keys and indexes
echo 'START: installing keys and indexes' | tee -a ${PART2LOG}
${PG_SNP_DBSCHEMADIR}/key/key_create.sh | tee -a ${PART2LOG}
${PG_SNP_DBSCHEMADIR}/index/index_create.sh | tee -a ${PART2LOG}
echo 'DONE: installing keys and indexes' | tee -a ${PART2LOG}

#
# counts
#
#cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a ${PART2LOG}
#select count(*) from snp.SNP_Accession;
#select count(*) from snp.SNP_ConsensusSnp;
#select count(*) from snp.SNP_ConsensusSnp_Marker;
#select count(*) from mgd.MRK_Location_Cache;
#EOSQL

#
# run snp cache load:  INSYNC=no
echo 'START: running snp cache load' | tee -a ${PART2LOG}
${SNPCACHELOAD}/snpmarker.sh | tee -a ${PART2LOG}
echo 'DONE: running snp cache load' | tee -a ${PART2LOG}

#cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a ${PART2LOG}
#select count(*) from snp.SNP_Accession;
#select count(*) from snp.SNP_ConsensusSnp;
#select count(*) from snp.SNP_ConsensusSnp_Marker;
#select count(*) from mgd.MRK_Location_Cache;
#EOSQL

#
# word-count of dbsnpload/logs/dbsnpload.cur.log
#
echo 'word-count of dbsnpload/logs/dbsnpload.cur.log' | tee -a ${PART2LOG}
grep " RS" ${LOGSDIR}/dbsnpload.cur.log | cut -f5 -d " " | sort | uniq | wc -l
echo 'count of number of RS loaded into database' | tee -a ${PART2LOG}
psql -h ${PG_DBSERVER} -d ${PG_DBNAME} -U ${PG_DBUSER} --command "select count(*) from snp_accession where _logicaldb_key = 73"

#
# load backup/'export' to 'dev'
#
echo 'START: creating backups' | tee -a ${PART2LOG}
#${PG_DBUTILS}/bin/dumpDB.csh mgi-testdb4 pub_dev mgd /export/dump/mgd.postgres.dump
${PG_DBUTILS}/bin/dumpDB.csh mgi-testdb4 pub_dev snp /export/dump/snp.part2.postgres.dump
#${PG_DBUTILS}/bin/loadDB.csh mgi-testdb4 pub_stable snp /export/dump/snp.part2.postgres.dump
#${PG_DBUTILS}/bin/loadDB.csh mgi-testdb4 pub_stable mgd /export/dump/mgd.postgres.dump
echo 'DONE: creating backups' | tee -a ${PART2LOG}

###-----------------------###
###--- final datestamp ---###
###-----------------------###
date | tee -a ${PART2LOG}
echo "--- Finished" | tee -a ${PART2LOG}

