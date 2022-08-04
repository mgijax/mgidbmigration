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

${GOLOAD}/go.sh | tee -a ${LOG} || exit 1

echo 'running reports' | tee -a ${LOG}
cd ${PUBRPTS}
source ./Configuration
cd daily
${PYTHON} GO_gene_association.py

date |tee -a $LOG

