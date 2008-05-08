#!/bin/csh -f

#
# This script loads the novel genes for Ensembl, NCBI and Vega.
#

cd `dirname $0` && source ./Configuration

${DATALOAD}/nomenload/nomenload.csh ${DATALOAD}/nomenload/ensembl.config
${DATALOAD}/nomenload/nomenload.csh ${DATALOAD}/nomenload/ncbi.config
${DATALOAD}/nomenload/nomenload.csh ${DATALOAD}/nomenload/vega.config
