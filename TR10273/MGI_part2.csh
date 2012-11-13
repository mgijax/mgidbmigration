#!/bin/csh -fx

#
# Migration for TR10273 -- Europhenome/Sanger MP annotations
# (part 2 running loads)
#
# 1. use current Sanger BioMart data
# 2. run Sanger dataload with Sanger BioMart as input
# 3. run 'runtest_part1' to load the Sanger test data
# 4. run Europhenome dataload with Europhenome BioMart as input
# 5. run 'runtest_part1' to load the Europhenome test data
# 6. run 'runtest_part2' to load additional genotypes & annotations for testing
# 7. run 'runtest_part3' to review the tests (pass/fail)
#
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
${HTMPLOAD}/bin/sangermpload.sh ${HTMPLOAD}/sangermpload.config ${HTMPLOAD}/annotload.config | tee -a ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

select count(*) from GXD_Genotype g where g._createdby_key = 1524 
go

select a.* 
from GXD_Genotype g, VOC_Annot a 
where g._createdby_key = 1524 
and g._Genotype_key = a._Object_key 
and a._AnnotType_key = 1002
go

EOSQL

#
# due to the need for genotype ids set to specific values further down the pipeline
# the sanger tests need to run **before** the euro load
#
# run test - part 1 - sanger input file + additonal genotypes
${HTMPLOAD}/test/runtest_part1.sh ${HTMPLOAD}/test/sangermpload.config.test ${HTMPLOAD}/bin/sangermpload.sh ${HTMPLOAD}/test/annotload.new.config.test | tee -a ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

select count(*) from GXD_Genotype g where g._createdby_key = 1526 
go

select a.* 
from GXD_Genotype g, VOC_Annot a 
where g._createdby_key = 1526 
and g._Genotype_key = a._Object_key 
and a._AnnotType_key = 1002
go

EOSQL

# run htmpload/europhenom
${HTMPLOAD}/bin/europhenompload.sh ${HTMPLOAD}/europhenompload.config ${HTMPLOAD}/annotload.config | tee -a ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

select count(*) from GXD_Genotype g where g._createdby_key = 1524 
go

select a.* 
from GXD_Genotype g, VOC_Annot a 
where g._createdby_key = 1524 
and g._Genotype_key = a._Object_key 
and a._AnnotType_key = 1002
go

EOSQL

# run test - part 1 - europhenome input file + additonal genotypes
${HTMPLOAD}/test/runtest_part1.sh ${HTMPLOAD}/test/europhenompload.config.test ${HTMPLOAD}/bin/europhenompload.sh ${HTMPLOAD}/test/annotload.append.config.test | tee -a ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

select count(*) from GXD_Genotype g where g._createdby_key = 1526 
go

select a.* 
from GXD_Genotype g, VOC_Annot a 
where g._createdby_key = 1526 
and g._Genotype_key = a._Object_key 
and a._AnnotType_key = 1002
go

EOSQL

# run test - part 2 - MP & OMIM annotations (sanger)
${HTMPLOAD}/test/runtest_part2.sh ${HTMPLOAD}/test/sangermpload.config.test | tee -a ${LOG}

# run test - part 3 - review (sanger)
${HTMPLOAD}/test/runtest_part3.sh ${HTMPLOAD}/test/sangermpload.config.test | tee -a ${LOG}

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

