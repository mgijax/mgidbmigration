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
load_db.csh ${DBSERVER} ${DBNAME} /shire/sybase/mgd.backup
load_db.csh ${DBSERVER} ${RADARDB} /shire/sybase/radar.backup

########################################

#
# Coordinate loads
#
#coordload

#
# Marker Association loads
#
${ENTREZGENELOAD}/mouse/load.csh | tee -a ${LOG}

# mapping load...

#
# Marker Cache loads
#

${MRKCACHELOAD}/mrklocation.csh | tee -a ${LOG}
${MRKCACHELOAD}/mrkref.csh | tee -a ${LOG}

#
# Sequence Cache loads
#

${SEQCACHELOAD}/seqmarker.csh | tee -a ${LOG}
${SEQCACHELOAD}/seqprobe.csh | tee -a ${LOG}
${SEQCACHELOAD}/seqdescription.csh | tee -a ${LOG}
${SEQCACHELOAD}/seqcoord.csh | tee -a ${LOG}

date | tee -a  ${LOG}

