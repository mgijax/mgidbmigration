#!/bin/csh -f

#
# Template
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
 
cp /mgi/all/wts2_projects/1500/WTS2-1549/MCV_Vocab.obo /data/loads/mgi/mcvload/input/MCV_Vocab.obo
#cp /mgi/all/wts2_projects/1500/WTS2-1549/MCV_Vocab.obo /data/loads/lec/mgi/mcvload/input/MCV_Vocab.obo

${MCVLOAD}/bin/run_mcv_vocload.sh | tee -a ${LOG}
${MCVLOAD}/bin/mcvload.sh | tee -a ${LOG}

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
select * from voc_term where _vocab_key = 79;
select * from voc_annot where _annottype_key = 1011;
EOSQL
date |tee -a $LOG

