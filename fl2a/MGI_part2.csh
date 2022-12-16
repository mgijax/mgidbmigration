#!/bin/csh -fx

#
# (part 2 - run loads)
#
# BEFORE adding a call to a load:
# . Delete any "lastrun" files that may exist in the "input" directory
# . Copy any new /data/downloads files OR run mirror_wget package, if necessary
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

echo 'MGD_DBNAME='$MGD_DBNAME | tee -a $LOG 
echo 'MGD_DBPASSWORDFILE='$MGD_DBPASSWORDFILE | tee -a $LOG 
echo 'MGD_DBSERVER='$MGD_DBSERVER | tee -a $LOG 
echo 'MGD_DBUSER='$MGD_DBUSER | tee -a $LOG 

#
# copy /data/downloads files needed for loads
# this only needs to happen on development servers
#
switch (`uname -n`)
    case bhmgiapp14ld:
    case bhmgiap09lt.jax.org:
    case bhmgidevapp01:
        date | tee -a ${LOG}
        echo 'run mirror_wget downloads' | tee -a $LOG 
        # mp_hpmappingload
        ${MIRROR_WGET}/download_package raw.githubusercontent.com.mp_hp
        # emalload
        ${MIRROR_WGET}/download_package www.gentar.org.crispr
        # IMPC htmpload
        ${MIRROR_WGET}/download_package www.gentar.org.phenotyping
        ${MIRROR_WGET}/download_package www.ebi.ac.uk.impc.json

        breaksw
endsw

date | tee -a ${LOG}
echo 'Running MP/HP Mapping Load' | tee -a $LOG
${MPHPMAPPINGLOAD}/bin/mp_hpmappingload.sh | tee -a $LOG

echo 'Running Endonuclease-Mediated Load' | tee -a $LOG
${EMALLOAD}/bin/emalload.sh ${EMALLOAD}/impc.config | tee -a $LOG

echo 'Running IMPC HT MP Load' | tee -a $LOG
${HTMPLOAD}/bin/runMpLoads.sh  | tee -a $LOG

date | tee -a ${LOG}
echo '--- finished part 2' | tee -a ${LOG}
