#!/bin/csh -fx

#
# TR12250/Literature Triage
#
# (part 2c - run loads)
#

###----------------------###
###--- initialization ---###
###----------------------###

if ( ${?MGICONFIG} == 0 ) then
        setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}

date | tee -a ${LOG}
echo '--- starting part 2' | tee -a $LOG

echo 'MGD_DBNAME='$MGD_DBNAME | tee -a $LOG || exit 1
echo 'MGD_DBPASSWORDFILE='$MGD_DBPASSWORDFILE | tee -a $LOG || exit 1
echo 'MGD_DBSERVER='$MGD_DBSERVER | tee -a $LOG || exit 1
echo 'MGD_DBUSER='$MGD_DBUSER | tee -a $LOG || exit 1

date | tee -a ${LOG}
echo 'Run UniProt Load' | tee -a ${LOG}
${UNIPROTLOAD}/bin/uniprotload.sh | tee -a ${LOG}

date | tee -a ${LOG}
echo 'Run GO/GOA Loads' | tee -a ${LOG}
${GOLOAD}/goamouse/goamouse.sh | tee -a ${LOG}
${MGICACHELOAD}/go_annot_extensions_display_load.csh | tee -a ${LOG}
${MGICACHELOAD}/go_isoforms_display_load.csh | tee -a ${LOG}

date | tee -a ${LOG}
echo '--- finished part 2' | tee -a ${LOG}
