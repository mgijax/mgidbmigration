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

cd ${DBUTILS}/mgidbmigration/genfevah

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
        date | tee -a ${LOG}
        echo 'run mirror_wget downloads' | tee -a $LOG || exit 1
        #scp bhmgiapp01:/data/downloads/uniprot/uniprotmus.dat /data/downloads/uniprot
        breaksw
endsw

date | tee -a ${LOG}
echo '--- remove VEGA data/code' | tee -a $LOG
./vega.csh | tee -a $LOG

date | tee -a ${LOG}
echo '--- TSS-to-Gene load' | tee -a $LOG
./tsstogene.csh | tee -a $LOG

# only run if *not* running straingenemodelload
#date | tee -a ${LOG}
#echo '--- new mrk_biotypemapping ' | tee -a $LOG
#${GENEMODELLOAD}/bin/biotypemapping.sh | tee -a $LOG

date | tee -a ${LOG}
echo '--- Strain Gene Model load' | tee -a $LOG
${STRAINGENEMODELLOAD}/bin/straingenemodelload.sh | tee -a $LOG

date | tee -a ${LOG}
echo '--- finished part 2' | tee -a ${LOG}
