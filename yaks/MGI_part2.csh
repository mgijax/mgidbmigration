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
${VOCLOAD}/runOBOIncLoad.sh CL.config

#
#  load test data for GXD_ISResultCellType
#
${MGI_LIVE}/dbutils/mgidbmigration/yaks/create_gxd_celltype.csh

date | tee -a ${LOG}
echo 'autosequence check' | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/test/autosequencecheck.csh | tee -a $LOG

date | tee -a ${LOG}
echo 'Downloading GEO HT Experiments and Samples' | tee -a $LOG
${GXDHTLOAD}/bin/mirror_geo_exp.sh | tee -a $LOG

date | tee -a ${LOG}
echo 'Running GEO HT Experiment Load' | tee -a $LOG
${GXDHTLOAD}/bin/geo_htload.sh | tee -a $LOG

date | tee -a ${LOG}
echo 'Running expt_add_notes_accessions.csh' | tee -a $LOG
${DBUTILS}/mgidbmigration/yaks/expt_add_notes_accessions.csh | tee -a $LOG

# run caches /adding cell type
date | tee -a ${LOG}
echo 'running expression and cre cache/adding cell type' | tee -a $LOG
${MGICACHELOAD}/gxdexpression.csh
${ALLCACHELOAD}/allelecrecache.csh

date | tee -a ${LOG}
echo '--- finished part 2' | tee -a ${LOG}
