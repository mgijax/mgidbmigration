#!/bin/csh -f

#
# vocload
#

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
-- MouseCyc
delete from dag_dag where _dag_key = 48;
EOSQL

# this looks obsolete: research.bioinformatics.udel.edu

# OMIM.config
${MIRROR_WGET}/download_package data.omim.org.omim

# CL.config
${MIRROR_WGET}/download_package purl.obolibrary.org.cl-basic.obo

# GO.config
${MIRROR_WGET}/download_package purl.obolibrary.org.go-basic.obo

# HPO.config
${MIRROR_WGET}/download_package purl.obolibrary.org.hp-basic.obo

# SO.config
${MIRROR_WGET}/download_package raw.githubusercontent.com.sequenceontology

# DO.config
${MIRROR_WGET}/download_package raw.githubusercontent.com.diseaseontology

# IP.config
${MIRROR_WGET}/download_package ftp.ebi.ac.uk.interpro

# proload
${MIRROR_WGET}/download_package proconsortium.org

# proisoformload
${MIRROR_WGET}/download_package purl.obolibrary.org.pr

# pirsfload
${MIRROR_WGET}/download_package www.uniprot.org.pirsfload

scp bhmgiapp01:/data/loads/mgi/vocload/runTimeMA/adult_mouse_anatomy.obo ${DATALOADSOUTPUT}/mgi/vocload/runTimeMA
scp bhmgiapp01:/data/loads/mgi/vocload/runTimeMP/MPheno_OBO.ontology ${DATALOADSOUTPUT}/mgi/vocload/runTimeMP
scp bhmgiapp01:/data/loads/mgi/vocload/runTimeMP/MP.header ${DATALOADSOUTPUT}/mgi/vocload/runTimeMP
scp bhmgiapp01:/data/loads/mgi/vocload/runTimeMP/MP.note ${DATALOADSOUTPUT}/mgi/vocload/runTimeMP
scp bhmgiapp01:/data/loads/mgi/vocload/runTimeMP/MP.synonym ${DATALOADSOUTPUT}/mgi/vocload/runTimeMP
scp bhmgiapp01:/data/loads/mgi/vocload/emap/input/EMAPA.obo ${DATALOADSOUTPUT}/mgi/vocload/emap/input
scp bhmgiapp01:/data/loads/mgi/mcvload/input/MCV_Vocab.obo ${DATALOADSOUTPUT}/mgi/mcvload/input
scp bhmgiapp01:/data/loads/mgi/rvload/input/RelationshipVocab.obo ${DATALOADSOUTPUT}/mgi/rvload/input
scp bhmgiapp01:/data/downloads/uniprot/uniprotmus.dat ${DATADOWNLOADS}/uniprot

rm -rf ${DATALOADSOUTPUT}/mgi/mcvload/input/lastrun
rm -rf ${DATALOADSOUTPUT}/mgi/rvload/input/lastrun
rm -rf ${DATALOADSOUTPUT}/mgi/pro/proload/input/lastrun

# input files using mirror_wget
${VOCLOAD}/runSimpleIncLoadNoArchive.sh OMIM.config
${VOCLOAD}/runOBOIncLoad.sh CL.config
${VOCLOAD}/runOBOIncLoad.sh GO.config
${VOCLOAD}/runOBOIncLoad.sh HPO.config
${VOCLOAD}/runOBOIncLoad.sh SO.config
${VOCLOAD}/runOBOIncLoadNoArchive.sh DO.config
${UNIPROTLOAD}/bin/makeInterProAnnot.sh
${PROLOAD}/bin/proload.sh
${PROISOFORMLOAD}/bin/proisoform.sh
${PIRSFLOAD}/bin/pirsfload.sh

# input files copied from production
${VOCLOAD}/runOBOIncLoad.sh MP.config
${VOCLOAD}/runOBOIncLoad.sh MA.config
${VOCLOAD}/emap/emapload.sh
${MCVLOAD}/bin/mcvload.sh
${RVLOAD}/bin/rvload.sh

# input file /mgi/all/wts_projects/10300/10308/RawBioTypeEquivalence/biotypemap.txt
${GENEMODELLOAD}/bin/biotypemapping.sh

date |tee -a $LOG

