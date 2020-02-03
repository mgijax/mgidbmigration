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
        date | tee -a ${LOG}
        echo 'copying htmpload files' | tee -a $LOG || exit 1
        scp bhmgiapp01:/data/downloads/www.ebi.ac.uk/impc.json /data/downloads/www.ebi.ac.uk/
	scp bhmgiapp01:/data/downloads/www.mousephenotype.org/mp2_load_phenotyping_colonies_report.tsv /data/downloads/www.mousephenotype.org
	
        breaksw
endsw

# run IMPC htmpload - autsequence change to GXD_Genotype, GXD_AllelePair
#date | tee -a ${LOG}
#echo 'Run MP Annotation Load' | tee -a ${LOG}
#${HTMPLOAD}/bin/runMpLoads.sh

#date | tee -a ${LOG}
#echo 'Run Test Strain Load' | tee -a ${LOG}
#${STRAINLOAD}/strainload.csh ./test_strainload/test_strainload.config

date | tee -a ${LOG}
echo 'RNA Seq load' | tee -a $LOG
${RNASEQLOAD}/bin/rnaseqload.sh | tee -a $LOG

#
# run autosequence report
# 
${PG_MGD_DBSCHEMADIR}/test/autosequencecheck.csh >& autosequencecheck.csh.out

date | tee -a ${LOG}
echo '--- finished part 2' | tee -a ${LOG}
