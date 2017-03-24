#!/bin/csh -fx

#
# Mirror refseq and genbank genomic release files
# Run record splitter to get mouse CON division
#
# Products:
#
# mirror_wget : branch
# refseqload : branch

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

#
# run migration
#

date | tee -a ${LOG}
echo 'Run RefSeq Contig Sequence Load' | tee -a ${LOG}
${REFSEQLOAD}/bin/refseqload.sh

date | tee -a ${LOG}
echo 'Run GenBank Contig Sequence Load' | tee -a ${LOG}
${GBSEQLOAD}/bin/gbseqload.sh

date | tee -a ${LOG}
echo 'Run Contig Assoc Load' | tee -a ${LOG}
${ASSOCLOAD}/bin/AssocLoad2.sh ${ASSOCLOAD}/DP.config.contig

date | tee -a ${LOG}
echo 'Run Location Note Load' | tee -a ${LOG}
${NOTELOAD}/mginoteload.csh /mgi/all/wts_projects/9800/9835/noteload/tr9835.config
date | tee -a ${LOG}

