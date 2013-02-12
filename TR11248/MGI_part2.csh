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
echo 'running snp_population' | tee -a ${PART2LOG}
date | tee -a ${PART2LOG}
${DBSNPLOAD}/bin/snpPopulation.sh | tee -a ${PART2LOG}
date | tee -a ${PART2LOG}
echo 'DONE: snp_population' | tee -a ${PART2LOG}

#
# dbsnpload
#
echo 'running dbsnpload' | tee -a ${PART2LOG}
date | tee -a ${PART2LOG}
${DATALOAD}/dbsnpload/bin/dbsnpload.sh | tee -a ${PART2LOG}
date | tee -a ${PART2LOG}
echo 'DONE: dbsnpload' | tee -a ${PART2LOG}

#
# word-count of dbsnpload/logs/dbsnpload.cur.log
#
echo 'word-count of dbsnpload/logs/dbsnpload.cur.log' | tee -a ${PART2LOG}
grep " RS" ${LOGSDIR}/dbsnpload.cur.log | cut -f5 -d " " | sort | uniq | wc -l

#
# update strains
#
echo 'running updateSnpStrainOrder' | tee -a ${PART2LOG}
date | tee -a ${PART2LOG}
${PG_DBUTILS}/bin/updateSnpStrainOrder.sh | tee -a ${PART2LOG}
date | tee -a ${PART2LOG}
echo 'DONE: updateSnpStrainOrder' | tee -a ${PART2LOG}

# remove keys and indexes
echo 'remove database keys and indexes' | tee -a ${PART2LOG}
#psql -h ${PG_DBSERVER} -d ${PG_DBNAME} -U ${PG_DBUSER} --command "delete from SNP_Accession where _mgitype_key != 33"
${PG_SNP_DBSCHEMADIR}/key/key_drop.sh | tee -a ${PART2LOG}
${PG_SNP_DBSCHEMADIR}/index/index_drop.sh | tee -a ${PART2LOG}
echo 'DONE: database keys and indexes' | tee -a ${PART2LOG}

echo 'bcping in each table' | tee -a ${PART2LOG}

foreach i (DP_SNP_Marker \
       SNP_Strain \
       SNP_ConsensusSnp \
       SNP_ConsensusSnp_StrainAllele \
       SNP_Coord_Cache \
       SNP_Flank \
       SNP_SubSnp \
       SNP_SubSnp_StrainAllele)
date
${PG_SNP_DBSCHEMADIR}/table/${i}_truncate.object | tee -a ${PART2LOG}
psql -h ${PG_DBSERVER} -d ${PG_DBNAME} -U ${PG_DBUSER} --command "\copy snp.${i} from '${OUTPUTDIR}/${i}.bcp' with null as ''" | tee -a ${PART2LOG}
date
end

foreach i (SNP_Accession)
date
psql -h ${PG_DBSERVER} -d ${PG_DBNAME} -U ${PG_DBUSER} --command "\copy snp.${i} from '${OUTPUTDIR}/${i}.bcp' with null as ''" | tee -a ${PART2LOG}
date
end
echo 'DONE: bcping in each table' | tee -a ${PART2LOG}

# install keys and indexes
echo 'installing keys and indexes' | tee -a ${PART2LOG}
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
echo 'running snp cache load' | tee -a ${PART2LOG}
${SNPCACHELOAD}/snpmarker.sh | tee -a ${PART2LOG}
echo 'DONE: running snp cache load' | tee -a ${PART2LOG}

#cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a ${PART2LOG}
#select count(*) from snp.SNP_Accession;
#select count(*) from snp.SNP_ConsensusSnp;
#select count(*) from snp.SNP_ConsensusSnp_Marker;
#select count(*) from mgd.MRK_Location_Cache;
#EOSQL

#
# load backup/'export' to 'dev'
#
echo 'creating backups' | tee -a ${PART2LOG}
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

