#!/bin/csh -f

#
# mirror_wget : ftp.ensembl.org.mouse_gff3_116
# strainmarkerload : 
# 	strainmarkerload.config.default
#	bin/strainmarkerload.sh : -W ignore:SyntaxWarning
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
date | tee -a $LOG
${GENEMODELLOAD}/bin/biotypemapping.sh | tee -a $LOG

# make sure we have the latest MGI.gff3 file before running
# /export/rohan/ftp/pub/mgigff3/MGI.gff3.gz
# /export/gondor/ftp/pub/mgigff3/MGI.gff3.gz

date | tee -a $LOG
${STRAINMARKERLOAD}/bin/strainmarkerload.sh | tee -a $LOG

date |tee -a $LOG

