#!/bin/csh -fx

#
# TR12662/GMC/MGI 6.12
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
echo 'Copy MP/Uberon/EMAPA files from production' | tee -a $LOG || exit 1
scp bhmgiapp01:/data/loads/mgi/vocload/runTimeMP/mp.owl /data/loads/mgi/vocload/runTimeMP
scp bhmgiapp01:/data/loads/mgi/vocload/emap/input/EMAPA.obo /data/loads/mgi/vocload/emap/input
scp bhmgiapp01:/data/downloads/purl.obolibrary.org/obo/uberon.obo /data/downloads/purl.obolibrary.org

#date | tee -a ${LOG}
#echo 'Run MP/EMAPA Relationship Load' | tee -a ${LOG}
#${MP_EMAPALOAD}/bin/mp_emapaload.sh | tee -a ${LOG}

date | tee -a ${LOG}
echo 'driver notes' | tee -a $LOG
./drivernotes.csh | tee -a $LOG

date | tee -a ${LOG}
echo '--- finished part 2' | tee -a ${LOG}
