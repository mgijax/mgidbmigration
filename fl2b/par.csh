#!/bin/csh -fx

#
#  par loads
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
echo '--- starting par.csh' | tee -a $LOG

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
        #${MIRROR_WGET}/download_package ???

        breaksw
endsw

date | tee -a ${LOG}
echo 'Running PAR Mapping Load' | tee -a $LOG
${MAPPINGLOAD}/mappingonlyload.sh /mgi/all/wts2_projects/1000/WTS2-1080/parmappingload.config | tee -a $LOG

date | tee -a ${LOG}
echo '--- finished par.csh' | tee -a ${LOG}
