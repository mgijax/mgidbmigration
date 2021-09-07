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
        scp bhmgiapp01:/data/downloads/purl.obolibrary.org/obo/cl/cl-basic.obo /data/downloads/purl.obolibrary.org/obo/cl
        breaksw
endsw

# this load is now a DAG
date | tee -a ${LOG}
echo 'Run Cell Ontology Load' | tee -a ${LOG}
${VOCLOAD}/runOBOFullLoad.sh CL.config


date | tee -a ${LOG}
echo 'autosequence check' | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/test/autosequencecheck.csh | tee -a $LOG

date | tee -a ${LOG}
echo 'Running GEO HT Experiment Load' | tee -a $LOG
${GXDHTLOAD}/bin/geo_htload.sh | tee -a $LOG

# running this separately for now so can check geo load first
date | tee -a ${LOG}
echo 'Running expt_add_notes_accessions.csh' | tee -a $LOG
./expt_add_notes_accessions.csh | tee -a $LOG

date | tee -a ${LOG}
echo '--- finished part 2' | tee -a ${LOG}
