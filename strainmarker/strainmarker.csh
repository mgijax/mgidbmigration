#!/bin/csh -f

#
# mirror_wget : ftp.ensembl.org.mouse_gff3
#
# strainmarkerload : 
#
# Code changes:
# 1. DONE: merge some redudant qc reports
# 2. DONE: use ldb = 60 for ENS, else 209
# 3. DONE: if projection_parent_gene > 1, then just use the first projection_parent_gene
# 4. DONE : if projection_parent_gene contains MGP id, then old MGP add to ACC_Accession as secondary id
# 5. DONE : add call to patched script
# 6. genemodelload : remove patched lastrun script (see snpcacheload)
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
 
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
delete from app_jobstream where returncode is null;
EOSQL

#
# run one more timae
# github : save and tag the strainmarkerload product
#
#date | tee -a $LOG
#cd ${STRAINMARKERLOAD}/bin
#./archive_mgps.csh
#gzip archive_mgps.csh.log

# pick up new biotypes
# lncRNA  lncRNA gene
date | tee -a $LOG
${GENEMODELLOAD}/bin/biotypemapping.sh | tee -a $LOG

# make sure we have the latest MGI.gff3 file before running
# /export/rohan/ftp/pub/mgigff3/MGI.gff3.gz
# /export/gondor/ftp/pub/mgigff3/MGI.gff3.gz

date | tee -a $LOG
${STRAINMARKERLOAD}/bin/strainmarkerload.sh | tee -a $LOG

date |tee -a $LOG

