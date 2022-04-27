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
date | tee -a ${LOG}
echo 'copy curatoralleleload test file to input directory' | tee -a $LOG

switch (`uname -n`)

    case bhmgiapp14ld:
        rm /data/loads/mgi/curatoralleleload/input/lastrun
        scp /mgi/all/wts2_projects/800/WTS2-814/alleloaderinputfile_final.txt /data/loads/mgi/curatoralleleload/input/curatoralleleload.txt
    case bhmgiap09lt.jax.org:
        rm /data/loads/sc/mgi/curatoralleleload/input/lastrun
        scp /mgi/all/wts2_projects/800/WTS2-814/alleloaderinputfile_final.txt /data/loads/sc/mgi/curatoralleleload/input/curatoralleleload.txt
    #case bhmgidevapp01:
        
        breaksw
endsw

date | tee -a ${LOG}
echo 'Running Derivation Load' | tee -a $LOG
${DERIVATIONLOAD}/bin/derivationload.sh /mgi/all/wts2_projects/800/WTS2-814/MCAL_derivations_needed.txt | tee -a $LOG

date | tee -a ${LOG}
echo 'Running Curator Allele Load' | tee -a $LOG
${CURATORALLELELOAD}/bin/curatoralleleload.sh | tee -a $LOG

date | tee -a ${LOG}
echo '--- finished part 2' | tee -a ${LOG}
