#!/bin/csh -fx

#
# Dev only Migration for dbSNP 142
# We plan to go to test and to production with a snp schema dump, so only mgd stuff
# is in MGI_part1.csh, this version includes all the snp schema changes as well.
# (part 1 - schema updates, etc
#
# Products:
# pgsnpdbschema
# 
#

###----------------------###
###--- initialization ---###
###----------------------###

cd `dirname $0` && source ../Configuration
setenv CWD `pwd`	# current working directory
echo "Server: ${PG_DBSERVER}"
echo "Database: ${PG_DBNAME}"

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}
date | tee -a ${LOG}
echo "--- Starting in ${CWD}..." | tee -a ${LOG}

echo "--- Update SNP_ConsensusSnp_Marker Schema ---" | tee -a ${LOG}

#${SNP_DBSCHEMADIR}/table/SNP_ConsensusSnp_Marker_drop.object
#${SNP_DBSCHEMADIR}/table/SNP_ConsensusSnp_Marker_create.object
#${SNP_DBSCHEMADIR}/key/SNP_ConsensusSnp_Marker_create.object
#${SNP_DBSCHEMADIR}/index/SNP_ConsensusSnp_Marker_create.object
#
echo "--- Create new SNP_Transcript_Protein Table ---" | tee -a ${LOG}
#${SNP_DBSCHEMADIR}/table/SNP_Transcript_Protein_create.object
#${SNP_DBSCHEMADIR}/key/SNP_Transcript_Protein_create.object
#${SNP_DBSCHEMADIR}/index/SNP_Transcript_Protein_create.object

echo "--- Drop SNP_Summary_View ---"  | tee -a ${LOG}
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0

/* drop view snp.SNP_Summary_View

CASCADE
; */

delete from DAG_DAG
        where _DAG_key = 11
;

update VOC_Term
        set term = 'within distance of'
        where _Term_key = 10125472
;

delete from VOC_Term
        where _Term_key in (10125470, 10125471, 10125480, 10125481, 10125485, 10125486, 10125487, 10125488, 10125489, 10125490, 10125491, 10125492, 10125493, 10125494, 10125495, 10125496, 10125497, 10125498)
;

update snp.MGI_dbinfo set
        snp_data_version = 'dbSNP Build 142'
;

update mgd.MGI_dbinfo set
        snp_data_version = 'dbSNP Build 142'
;


EOSQL

# drop/create all indexes for tables wih clustered indexes so that indexes i
# are clustered immediately after creation
${SNP_DBSCHEMADIR}/index/SNP_Accession_drop.object
${SNP_DBSCHEMADIR}/index/SNP_Accession_create.object
${SNP_DBSCHEMADIR}/indexSNP_ConsensusSnp_Marker_drop.object
${SNP_DBSCHEMADIR}/indexSNP_ConsensusSnp_Marker_create.object
${SNP_DBSCHEMADIR}/indexSNP_ConsensusSnp_StrainAllele_drop.object
${SNP_DBSCHEMADIR}/indexSNP_ConsensusSnp_StrainAllele_create.object
${SNP_DBSCHEMADIR}/indexSNP_Coord_Cache_drop.object
${SNP_DBSCHEMADIR}/indexSNP_Coord_Cache_create.object
${SNP_DBSCHEMADIR}/indexSNP_Flank_drop.object
${SNP_DBSCHEMADIR}/indexSNP_Flank_create.object
${SNP_DBSCHEMADIR}/indexSNP_RefSeq_Accession_drop.object
${SNP_DBSCHEMADIR}/indexSNP_RefSeq_Accession_create.object
${SNP_DBSCHEMADIR}/indexSNP_Strain_drop.object
${SNP_DBSCHEMADIR}/indexSNP_Strain_create.object
${SNP_DBSCHEMADIR}/indexSNP_SubSnp_drop.object
${SNP_DBSCHEMADIR}/indexSNP_SubSnp_create.object
${SNP_DBSCHEMADIR}/indexSNP_SubSnp_StrainAllele_drop.object
${SNP_DBSCHEMADIR}/indexSNP_SubSnp_StrainAllele_create.object

# Create public perms (when dropping/creating tables)
${PG_DBUTILS}/bin/grantPublicPerms.csh ${PG_DBSERVER} ${PG_DBNAME} snp
date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}
