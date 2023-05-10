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
    case bhmgidevapp01:
    case bhmgiap09lt.jax.org:
        date | tee -a ${LOG}
        echo 'run mirror_wget downloads' | tee -a $LOG 
        ${MIRROR_WGET}/download_package alliancegenome.org.human_coordload
        #scp bhmgiapp01:/data/downloads/uniprot/uniprotmus.dat /data/downloads/uniprot
        breaksw
endsw

echo "running mapview human coordinate deletes" | tee -a $LOG
./mapview_delete.csh >>& ${LOG}

echo "running the run new human coordinate load" | tee -a $LOG
${HUMANCOORDLOAD}/bin/humancoordload.sh >>& $LOG

date | tee -a ${LOG}
echo '--- finished part 2' | tee -a ${LOG}
