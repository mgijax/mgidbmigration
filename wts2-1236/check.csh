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
 
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
select count(*) from VOC_Term_EMAPS;
select count(*) from MGI_Note where _notetype_key = 1045;
select count(*) from MGI_Note where _notetype_key = 1046;
select count(*) from GXD_Expression;
select count(*) from MGI_Note where _notetype_key = 1021 and _mgitype_key = 11;
EOSQL

wc -l ${DATALOADSOUTPUT}/mgi/mgicacheload/output/MGI_Note.go_annot_extensions.bcp
wc -l ${DATALOADSOUTPUT}/mgi/mgicacheload/output/MGI_Note.go_isoforms.bcp
wc -l ${DATALOADSOUTPUT}/mgi/mgicacheload/output/GXD_Expression.bcp
wc -l ${DATALOADSOUTPUT}/mgi/mgicacheload/output/ACC_Accession.bcp
wc -l ${DATALOADSOUTPUT}/mgi/alomrkload/output/MGI_Note.bcp

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

