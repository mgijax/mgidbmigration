#!/bin/csh -fx

#
# Migration for TR10273 -- Europhenome/Sanger MP annotations
# (part 2 running loads)
#
# 1. use current Sanger BioMart data
# 2. run Sanger dataload with Sanger BioMart as input
# 3. run Europhenome dataload with Europhenome BioMart as input
# 4. run 'runtest_part1' to load the Sanger test data
#
# GXD_Genotype: 723
# VOC_Annot: 3058
#
# select count(*) from GXD_Genotype g
# where g._createdby_key = 1524 
#
# select a.* from GXD_Genotype g, VOC_Annot a 
# where g._createdby_key = 1524 
# and g._Genotype_key = a._Object_key 
# and a._AnnotType_key = 1002
#

###----------------------###
###--- initialization ---###
###----------------------###

source ../Configuration

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}

# run htmpload/sanger
echo ${HTMPLOAD}/bin/sangermpload.sh | tee -a ${LOG}
${HTMPLOAD}/bin/sangermpload.sh ${HTMPLOAD}/sangermpload.config ${HTMPLOAD}/annotload.config | tee -a ${LOG}

# run htmpload/europhenom
echo ${HTMPLOAD}/bin/europhenompload.sh | tee -a ${LOG}
${HTMPLOAD}/bin/europhenompload.sh ${HTMPLOAD}/europhenompload.config ${HTMPLOAD}/annotload.config | tee -a ${LOG}

# run test - part 1 - sanger input file + additonal genotypes
echo ${HTMPLOAD}/test/runtest_part1.sh ${HTMPLOAD}/test/sangermpload.config.test ${HTMPLOAD}/test/annotload.append.config.test ${HTMPLOAD}/bin/sangermpload.sh | tee -a ${LOG}
${HTMPLOAD}/test/runtest_part1.sh ${HTMPLOAD}/test/sangermpload.config.test ${HTMPLOAD}/test/annotload.append.config.test ${HTMPLOAD}/bin/sangermpload.sh | tee -a ${LOG}

# run test - part 1 - europhenome input file + additonal genotypes
echo ${HTMPLOAD}/test/runtest_part1.sh ${HTMPLOAD}/test/europhenompload.config.test ${HTMPLOAD}/test/annotload.append.config.test ${HTMPLOAD}/bin/europhenompload.sh | tee -a ${LOG}
${HTMPLOAD}/test/runtest_part1.sh ${HTMPLOAD}/test/europhenompload.config.test ${HTMPLOAD}/test/annotload.append.config.test ${HTMPLOAD}/bin/europhenompload.sh | tee -a ${LOG}

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}
