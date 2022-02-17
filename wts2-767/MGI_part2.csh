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
        scp bhmgiapp01:/data/loads/mgi/mcvload/input/mcvload.txt  ${DATALOADSOUTPUT}/mgi/mcvload/input/
        scp bhmgiapp01:/data/loads/mgi/vocload/runTimeMP/MPheno_OBO.ontology  ${DATALOADSOUTPUT}/mgi/vocload/runTimeMP/
        scp ${DBUTILS}/mgidbmigration/wts2-767/nomenload.txt  /data/nomen/current
        scp ${DBUTILS}/mgidbmigration/wts2-767/fearload.txt ${DATALOADSOUTPUT}/mgi/fearload/input/
#        scp bhmgiapp01:/data/loads/mgi/fearload/input/fearload.txt ${DATALOADSOUTPUT}/mgi/fearload/input/
        scp bhmgiapp01:/data/downloads/www.mousephenotype.org/mgi_modification_allele_report.tsv /data/downloads/www.mousephenotype.org/
        scp bhmgiapp01:/data/downloads/www.ebi.ac.uk/impc.json /data/downloads/www.ebi.ac.uk/
        scp bhmgiapp01:/export/gondor/ftp/pub/mgigff3/MGI.gff3.gz ${FTPROOT}/pub/mgigff3/
        scp bhmgiapp01:/data/downloads/fms.alliancegenome.org/download/ORTHOLOGY-ALLIANCE_COMBINED.tsv.gz /data/downloads/fms.alliancegenome.org/download/
        breaksw
endsw

date | tee -a ${LOG}
echo 'Run Nomen/Mapping load' | tee -a ${LOG}
rm -f ${DATALOADSOUTPUT}/mgi/nomenload/input/lastrun
${NOMENLOAD}/bin/nomenload.sh ${NOMENLOAD}/nomenload.config

date | tee -a ${LOG}
echo 'Run MCV Annotation Load' | tee -a ${LOG}
${MCVLOAD}/bin/mcvload.sh

date | tee -a ${LOG}
echo 'Run Mammalian Phenotype Load' | tee -a ${LOG}
rm -f ${DATALOADSOUTPUT}/mgi/mcvload/input/lastrun
${VOCLOAD}/runOBOIncLoad.sh MP.config

date | tee -a ${LOG}
echo 'Run FeaR Load' | tee -a ${LOG}
rm -f ${DATALOADSOUTPUT}/mgi/fearload/input/lastrun
${FEARLOAD}/bin/fearload.sh

date | tee -a ${LOG}
echo 'Run Allele Load' | tee -a ${LOG}
${ALLELELOAD}/bin/makeIKMC.sh ikmc.config

#htmpload : genotypeload, strainload ; may need to make a test input file
date | tee -a ${LOG}
echo 'Run MP Annotation Loads' | tee -a ${LOG}
rm -f ${DATALOADSOUTPUT}/mgi/htmpload/impcmpload/input/lastrun
${MIRROR_WGET}/download_package www.ebi.ac.uk.impc.json
${HTMPLOAD}/bin/runMpLoads.sh

#straingenemodelload : strainmarkerload
# DATA: from mgigff3 file which is at ${FTPROOT}/pub/mgigff3/MGI.gff3.gz
#
date | tee -a ${LOG}
echo 'Run Strain Gene Model Load' | tee -a ${LOG}
rm -f ${DATALOADSOUTPUT}/mgi/strainmarkerload/output/lastrun
${STRAINGENEMODELLOAD}/bin/straingenemodelload.sh

#rnaseqload : delete all but 1 experiment in set
date | tee -a ${LOG}
echo 'Run RNA Sequence Load' | tee -a ${LOG}
${RNASEQLOAD}/bin/run_downloadFiles.sh
${RNASEQLOAD}/bin/rnaseqload.sh

date | tee -a ${LOG}
echo 'Run Homology Loads' | tee -a ${LOG}
${HOMOLOGYLOAD}/bin/homologyload.sh alliance_directload.config
${HOMOLOGYLOAD}/bin/homologyload.sh alliance_clusteredload.config

#targetedallelelload - this load not running in prod, will test this once it is updated to use new
# input file in the CREAM project

date | tee -a ${LOG}
echo '--- finished part 2' | tee -a ${LOG}
