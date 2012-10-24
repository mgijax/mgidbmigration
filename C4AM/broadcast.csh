#!/bin/csh -f

#
# Template
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

echo 'running ensembl 1 broadcast' | tee -a $LOG 
${NOMENLOAD}/bin/broadcast.csh /mgi/all/wts_projects/11100/11133/ENSEMBL/NovelGene/ensembl_nomen.config | tee -a $LOG

echo 'running ncbi 1 broadcast' | tee -a $LOG
${NOMENLOAD}/bin/broadcast.csh /mgi/all/wts_projects/11100/11133/NCBI/NovelGene/ncbi_nomen.config | tee -a $LOG

# these added 10/24/2012:
echo 'running ensembl 2 broadcast' | tee -a $LOG
${NOMENLOAD}/bin/broadcast.csh /mgi/all/wts_projects/11100/11133/ENSEMBL/NovelGene2/ensembl_nomen.config | tee -a $LOG

echo 'running ncbi 2 broadcast' | tee -a $LOG
${NOMENLOAD}/bin/broadcast.csh /mgi/all/wts_projects/11100/11133/NCBI/NovelGene2/ncbi_nomen.config | tee -a $LOG

echo 'running vega broadcast' | tee -a $LOG
${NOMENLOAD}/bin/broadcast.csh /mgi/all/wts_projects/11100/11133/VEGA/NovelGene/vega_nomen.config | tee -a $LOG

date |tee -a $LOG

