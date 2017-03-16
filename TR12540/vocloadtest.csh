#!/bin/csh

if ( ${?MGICONFIG} == 0 ) then
	setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}

scp bhmgiapp01:${DATALOADSOUTPUT}/mgi/vocload/runTimeMA/adult_mouse_anatomy.obo ${DATALOADSOUTPUT}/mgi/vocload/runTimeMA
scp bhmgiapp01:${DATALOADSOUTPUT}/mgi/vocload/emap/input/EMAPA.obo ${DATALOADSOUTPUT}/mgi/vocload/emap/input
scp bhmgiapp01:${DATALOADSOUTPUT}/mgi/vocload/runTimeMP/MPheno_OBO.ontology ${DATALOADSOUTPUT}/mgi/vocload/runTimeMP

${MIRROR_WGET}/download_package purl.obolibrary.org.go-basic.obo
${MIRROR_WGET}/download_package purl.obolibrary.org.cl-basic.obo
${MIRROR_WGET}/download_package data.omim.org
${MIRROR_WGET}/download_package compbio.charite.de.phenotype_annotation
${MIRROR_WGET}/download_package raw.githubusercontent.com.diseaseontology
exit

${VOCLOAD}/runOBOIncLoad.sh MP.config | tee -a ${LOG}
cut -f3,7 ${DATALOADSOUTPUT}/mgi/vocload/runTimeMP/Termfile | grep obsolete | uniq | tee -a ${LOG}

${VOCLOAD}/emap/emapload.sh | tee -a ${LOG}
cut -f3,7 ${DATALOADSOUTPUT}/mgi/vocload/emap/output/Termfile.emapa | grep obsolete | uniq | tee -a ${LOG}
cut -f3,7 ${DATALOADSOUTPUT}/mgi/vocload/emap/output/Termfile.emaps | grep obsolete | uniq | tee -a ${LOG}

${VOCLOAD}/runOBOIncLoad.sh GO.config | tee -a ${LOG}
cut -f3,7 ${DATALOADSOUTPUT}/mgi/vocload/runTimeGO/Termfile | grep obsolete | uniq | tee -a ${LOG}

${VOCLOAD}/runOBOIncLoad.sh MA.config | tee -a ${LOG}
cut -f3,7 ${DATALOADSOUTPUT}/mgi/vocload/runTimeMA/Termfile | grep obsolete | uniq | tee -a ${LOG}

${VOCLOAD}/runOBOFullLoad.sh CL.config | tee -a ${LOG}
cut -f3,7 ${DATALOADSOUTPUT}/mgi/vocload/runTimeCL/Termfile | grep obsolete | uniq | tee -a ${LOG}

${VOCLOAD}/runSimpleIncLoadNoArchive.sh OMIM.config | tee -a ${LOG}
cut -f3,7 ${DATALOADSOUTPUT}/mgi/vocload/OMIM/OMIM.tab | grep obsolete | uniq | tee -a ${LOG}

${VOCLOAD}/runOBOIncLoad.sh HPO.config | tee -a ${LOG}
cut -f3,7 ${DATALOADSOUTPUT}/mgi/vocload/runTimeHPO/Termfile | grep obsolete | uniq | tee -a ${LOG}

${VOCLOAD}/runOBOIncLoadNoArchive.sh DO.config | tee -a ${LOG}
cut -f3,7 ${DATALOADSOUTPUT}/mgi/vocload/runTimeDO/Termfile | grep obsolete | uniq | tee -a ${LOG}

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
select s.* 
from mgi_synonym s 
where s._MGIType_key = 13 and not exists (select * from voc_term t where s._object_key = t._term_key)
;
EOSQL

