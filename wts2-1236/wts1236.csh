#!/bin/csh -f

#
# lib_py_postgres
# alomrkload
# vocload
# mgicacheload
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
 
#cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
#-- MouseCyc
#delete from dag_dag where _dag_key = 48;
#EOSQL

# this looks obsolete: research.bioinformatics.udel.edu

# OMIM.config
${MIRROR_WGET}/download_package data.omim.org.omim

# GO.config
${MIRROR_WGET}/download_package purl.obolibrary.org.go-basic.obo

# HPO.config
${MIRROR_WGET}/download_package purl.obolibrary.org.hp-basic.obo

# SO.config
${MIRROR_WGET}/download_package raw.githubusercontent.com.sequenceontology

# DO.config
${MIRROR_WGET}/download_package raw.githubusercontent.com.diseaseontology

scp bhmgiapp01:/data/loads/mgi/vocload/runTimeMA/adult_mouse_anatomy.obo ${DATALOADSOUTPUT}/mgi/vocload/runTimeMA
scp bhmgiapp01:/data/loads/mgi/vocload/emap/input/EMAPA.obo ${DATALOADSOUTPUT}/mgi/vocload/emap/input

# remove old lib/python scripts that are moved to vocload/lib
#rm -rf ${LIBDIRS}/dbTable.py  ${LIBDIRS}/loadDAG.py  ${LIBDIRS}/Log.py  ${LIBDIRS}/Ontology.py  ${LIBDIRS}/voc_html.py  ${LIBDIRS}/vocloadDAG.py  ${LIBDIRS}/vocloadlib.py

${LOADADMIN}/prod/removeLastrunFiles.sh

# input files using mirror_wget
${VOCLOAD}/runSimpleIncLoadNoArchive.sh OMIM.config
${VOCLOAD}/runOBOIncLoad.sh GO.config
${VOCLOAD}/runOBOIncLoad.sh HPO.config
${VOCLOAD}/runOBOIncLoad.sh SO.config
${VOCLOAD}/runOBOIncLoadNoArchive.sh DO.config
${VOCLOAD}/runOBOIncLoad.sh MA.config
${VOCLOAD}/emap/emapload.sh

${MGICACHELOAD}/go_annot_extensions_display_load.csh
${MGICACHELOAD}/go_isoforms_display_load.csh
${MGICACHELOAD}/gxdexpression.csh
${MGICACHELOAD}/inferredfrom.csh

${ALOMRKLOAD}/bin/alomrkload.sh

#${VOCLOAD}/runOBOIncLoad.sh CL.config
#${UNIPROTLOAD}/bin/makeInterProAnnot.sh
#${PROLOAD}/bin/proload.sh
#${PROISOFORMLOAD}/bin/proisoform.sh
#${PIRSFLOAD}/bin/pirsfload.sh
#${MCVLOAD}/bin/mcvload.sh
#${RVLOAD}/bin/rvload.sh
#${GENEMODELLOAD}/bin/biotypemapping.sh

date |tee -a $LOG

