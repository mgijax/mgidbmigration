#!/bin/csh -f

#
# Migration for Build 34
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date | tee -a  ${LOG}
 
${DBUTILSBINDIR}/turnonbulkcopy.csh ${DBSERVER} ${DBNAME} | tee -a ${LOG}

# load a backup
#load_db.csh ${DBSERVER} ${DBNAME} /shire/sybase/mgd.backup
#load_db.csh ${DBSERVER} ${RADARDB} /shire/sybase/radar.backup

########################################

# delete old Ensembl coordinates

${BUILD34}/deleteEnsembl33.csh ${DBSERVER} ${DBNAME} | tee -a ${LOG}

# mapping load...

${BUILD34}/mappingload.csh | tee -a ${LOG}

#
# Coordinate loads
#
${ASSEMBLYSEQLOAD}/bin/assemblyseqload.sh ncbi_assemblyseqload.config
${ASSEMBLYSEQLOAD}/bin/assemblyseqload.sh ensembl_assemblyseqload.config

#
# Marker Association loads
#
${EGLOAD}/bin/egload.sh | tee -a ${LOG}
#${ENTREZGENELOAD}/mouse/load.csh | tee -a ${LOG}

#
# Sequence Cache loads
#

${SEQCACHELOAD}/seqmarker.csh | tee -a ${LOG}
${SEQCACHELOAD}/seqdescription.csh | tee -a ${LOG}
${SEQCACHELOAD}/seqcoord.csh | tee -a ${LOG}

#
# Marker Cache loads
#

${MRKCACHELOAD}/mrklocation.csh | tee -a ${LOG}
${MRKCACHELOAD}/mrkref.csh | tee -a ${LOG}

date | tee -a  ${LOG}

