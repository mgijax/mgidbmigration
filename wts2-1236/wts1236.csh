#!/bin/csh -f

if ( ${?MGICONFIG} == 0 ) then
        setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date | tee -a $LOG
 
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
EOSQL

${MIRROR_WGET}/download_package data.omim.org.omim
${MIRROR_WGET}/download_package purl.obolibrary.org.cl-basic.obo
${MIRROR_WGET}/download_package purl.obolibrary.org.go-basic.obo
${MIRROR_WGET}/download_package purl.obolibrary.org.hp-basic.obo
${MIRROR_WGET}/download_package raw.githubusercontent.com.sequenceontology
${MIRROR_WGET}/download_package raw.githubusercontent.com.diseaseontology
${MIRROR_WGET}/download_package ftp.ebi.ac.uk.interpro

scp bhmgiapp01:/data/loads/mgi/vocload/runTimeMA/adult_mouse_anatomy.obo ${DATALOADSOUTPUT}/mgi/vocload/runTimeMA
scp bhmgiapp01:/data/loads/mgi/vocload/runTimeMP/MPheno_OBO.ontology ${DATALOADSOUTPUT}/mgi/vocload/runTimeMP
scp bhmgiapp01:/data/loads/mgi/vocload/emap/input/EMAPA.obo ${DATALOADSOUTPUT}/mgi/vocload/emap/input

# input files using mirror_wget
${VOCLOAD}/runSimpleIncLoadNoArchive.sh OMIM.config
${VOCLOAD}/runOBOIncLoad.sh CL.config
${VOCLOAD}/runOBOIncLoad.sh GO.config
${VOCLOAD}/runOBOIncLoad.sh HPO.config
${VOCLOAD}/runOBOIncLoad.sh SO.config
${VOCLOAD}/runOBOIncLoadNoArchive.sh DO.config
#${UNIPROTLOAD}/bin/uniprotload.sh

# input files copied from production
${VOCLOAD}/runOBOIncLoad.sh MP.config
${VOCLOAD}/runOBOIncLoad.sh MA.config
${VOCLOAD}/emap/emapload.sh

${MCVLOAD}/bin/mcvload.sh
${PROLOAD}/bin/proload.sh
${RVLOAD}/bin/rvload.sh
${PIRSFLOAD}/bin/pirsfload.sh
${GENEMODELLOAD}/bin/biotypemapping.sh

#${GOLOAD}/godaily.sh

date |tee -a $LOG

