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

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}

env | grep PG | tee -a ${LOG}

#
# snp_population, snp_subsnp_strainallele
#
#date | tee -a ${LOG}
#${DBSNPLOAD}/bin/snpPopulation.sh | tee -a ${LOG}
#date | tee -a ${LOG}

#
# take a backup
#
#date | tee -a ${LOG}
#${PG_DBUTILS}/bin/dumpDB.csh ${PG_DBSERVER} ${PG_DBNAME} snp /export/dump/snp.part2.postgres.dump | tee -a ${LOG}
#date | tee -a ${LOG}

#
# dbsnpload
#
#date | tee -a ${LOG}
#${DATALOAD}/dbsnpload/bin/dbsnpload.sh | tee -a ${LOG}
#date | tee -a ${LOG}

#
# update strains
#
#date | tee -a ${LOG}
#${PG_DBUTILS}/bin/updateSnpStrainOrder.sh | tee -a ${LOG}
#date | tee -a ${LOG}

# remove keys and indexes
psql -h ${PG_DBSERVER} -d ${PG_DBNAME} -U ${PG_DBUSER} --command "delete from SNP_Accession where _mgitype_key != 33"
${PG_SNP_DBSCHEMADIR}/key/key_drop.sh
${PG_SNP_DBSCHEMADIR}/index/index_drop.sh

setenv OUTPUTDIR ${DATALOADSOUTPUT}/dbsnp/dbsnpload/output

foreach i (DP_SNP_Marker \
       SNP_Strain \
       SNP_ConsensusSnp \
       SNP_ConsensusSnp_StrainAllele \
       SNP_Coord_Cache \
       SNP_Flank \
       SNP_SubSnp \
       SNP_SubSnp_StrainAllele)
date
echo $i
${PG_SNP_DBSCHEMADIR}/table/${i}_truncate.object
psql -h ${PG_DBSERVER} -d ${PG_DBNAME} -U ${PG_DBUSER} --command "\copy snp.${i} from '${OUTPUTDIR}/${i}.bcp' with null as ''"
date
end

foreach i (SNP_Accession)
date
psql -h ${PG_DBSERVER} -d ${PG_DBNAME} -U ${PG_DBUSER} --command "\copy snp.${i} from '${OUTPUTDIR}/${i}.bcp' with null as ''"
date
end

# install keys and indexes
${PG_SNP_DBSCHEMADIR}/key/key_create.sh
${PG_SNP_DBSCHEMADIR}/index/index_create.sh

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
${SNPCACHELOAD}/snpmarker.sh | tee -a ${LOG}

#cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a ${LOG}
#select count(*) from snp.SNP_Accession;
#select count(*) from snp.SNP_ConsensusSnp;
#select count(*) from snp.SNP_ConsensusSnp_Marker;
#select count(*) from mgd.MRK_Location_Cache;
#EOSQL

#
# load backup/'export' to 'dev'
#
#${PG_DBUTILS}/bin/dumpDB.csh mgi-testdb4 pub_dev mgd /export/dump/mgd.postgres.dump
#${PG_DBUTILS}/bin/dumpDB.csh mgi-testdb4 pub_dev snp /export/dump/snp.part3.postgres.dump
#${PG_DBUTILS}/bin/loadDB.csh mgi-testdb4 pub_stable snp /export/dump/snp.part3.postgres.dump
#${PG_DBUTILS}/bin/loadDB.csh mgi-testdb4 pub_stable mgd /export/dump/mgd.postgres.dump

###-----------------------###
###--- final datestamp ---###
###-----------------------###
date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

