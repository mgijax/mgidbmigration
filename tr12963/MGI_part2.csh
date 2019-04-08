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
#switch (`uname -n`)
#    case bhmgiapp14ld:
#    case bhmgidevapp01:
#        date | tee -a ${LOG}
#        echo 'run mirror_wget downloads' | tee -a $LOG || exit 1
#        #scp bhmgiapp01:/data/downloads/uniprot/uniprotmus.dat /data/downloads/uniprot
#        breaksw
#endsw


date | tee -a ${LOG}
echo 'run variant migration' | tee -a $LOG
cd variant
./variant.csh | tee -a $LOG
cd ..

${PG_MGD_DBSCHEMADIR}/test/autosequencecheck.csh | tee -a $LOG || exit 1
${PG_DBUTILS}/bin/grantPublicPerms.csh ${PG_DBSERVER} ${PG_DBNAME} mgd | tee -a $LOG || exit 1

date | tee -a ${LOG}
echo 'Run Lit Triage Load' | tee -a ${LOG}
${LITTRIAGELOAD}/bin/littriageload.sh

exit 0

# after migration

date | tee -a ${LOG}
echo 'Run Mammalian Phenotype Load' | tee -a ${LOG}
${VOCLOAD}/runOBOIncLoad.sh MP.config

date | tee -a ${LOG}
echo 'Run EMAP Load' | tee -a ${LOG}
${VOCLOAD}/emap/emapload.sh

date | tee -a ${LOG}
echo 'Run GO Loads' | tee -a ${LOG}
${GOLOAD}/go.sh

date | tee -a ${LOG}
echo 'Run Allele Load' | tee -a ${LOG}
${ALLELELOAD}/bin/makeIKMC.sh ikmc.config

date | tee -a ${LOG}
echo 'Run MP Annotation Loads' | tee -a ${LOG}
${HTMPLOAD}/bin/runMpLoads.sh

date | tee -a ${LOG}
echo 'Run EMAL Load' | tee -a ${LOG}
${EMALLOAD}/bin/emalload.sh  ${EMALLOAD}/impc.config

date | tee -a ${LOG}
echo 'Run EntrezGene Data Provider Load' | tee -a ${LOG}
${ENTREZGENELOAD}/loadFiles.csh

date | tee -a ${LOG}
echo 'Run Non-Mouse EntrezGene Load' | tee -a ${LOG}
${ENTREZGENELOAD}/loadAll.csh

date | tee -a ${LOG}

echo '--- finished part 2' | tee -a ${LOG}
