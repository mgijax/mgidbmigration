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

echo 'MGD_DBNAME='$MGD_DBNAME | tee -a $LOG || exit 1
echo 'MGD_DBPASSWORDFILE='$MGD_DBPASSWORDFILE | tee -a $LOG || exit 1
echo 'MGD_DBSERVER='$MGD_DBSERVER | tee -a $LOG || exit 1
echo 'MGD_DBUSER='$MGD_DBUSER | tee -a $LOG || exit 1

#
# copy /data/downloads files needed for loads
# this only needs to happen on development servers
#
switch (`uname -n`)
    case bhmgiapp14ld:
    case bhmgidevapp01:
    case bhmgiap09lt.jax.org:
        #date | tee -a ${LOG}
        #echo 'mirror files/copy from production' | tee -a $LOG || exit 1
        #scp bhmgiapp01:/data/loads/mgi/vocload/runTimeMP/MPheno_OBO.ontology /data/loads/sc/mgi/vocload/runTimeMP
	#scp bhmgiapp01:/data/loads/mgi/vocload/runTimeMP/MP.synonym /data/loads/sc/mgi/vocload/runTimeMP
	#scp bhmgiapp01:/data/loads/mgi/vocload/runTimeMP/MP.header /data/loads/sc/mgi/vocload/runTimeMP
	#scp bhmgiapp01:/data/loads/mgi/vocload/runTimeMP/MP.note /data/loads/sc/mgi/vocload/runTimeMP
        breaksw
endsw

# For testing the vocload voc_term autosequence
#date | tee -a ${LOG}
#echo 'Run Mammalian Phenotype Load' | tee -a ${LOG}
#${VOCLOAD}/runOBOIncLoad.sh MP.config

date | tee -a ${LOG}
echo '--- finished part 2' | tee -a ${LOG}
