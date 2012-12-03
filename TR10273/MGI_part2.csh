#!/bin/csh -fx

#
# Migration for TR10273 -- Europhenome/Sanger MP annotations
# (part 2 running loads)
#
# 1. run Sanger dataload with Sanger BioMart as input (real)
#
# 2. run 'runtest_part1' to load the Sanger test data (kick-out/mock)
#
# STOP here if "additional genotypes" IDs are changing from last run
#
# 3. run 'runtest_part1A' to load the Sanger test data (additional genotypes)
#
# 4. run Europhenome dataload with Europhenome BioMart as input (real)
#
# 5. run 'runtest_part1' to load the Europhenome test data (kick-out/mock)
#
# 6. run 'runtest_part2' to load additional MP & OMIM annotations for testing (sanger only)
# MP/OMIM data files use the created-by = 'scrum-dog'
#
# 7. run 'runtest_part3' to review the tests (pass/fail) (sanger)
#
# ALL TEST DATA RUNS THE MP ANNOTATIONS IN "APPEND" MODE.
# this means that the MP annotations will be "appended-to" the current 'htmpload' data
# that was loaded as part of the "real" data load
#
# Both the "real" and "kick-out/mock" data will use created-by = 'htmpload'
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

date | tee -a ${LOG}

# run htmpload/sanger
${HTMPLOAD}/bin/sangermpload.sh ${HTMPLOAD}/sangermpload.config ${HTMPLOAD}/annotload.config | tee -a ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

select count(*) from GXD_Genotype g where g._createdby_key = 1524 
go

select count(a._Annot_key)
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
# run test - part 1 - sanger input file
${HTMPLOAD}/test/runtest_part1.sh ${HTMPLOAD}/test/sangermpload.config.test ${HTMPLOAD}/bin/sangermpload.sh ${HTMPLOAD}/test/annotload.config.test | tee -a ${LOG}

# STOP IF NEW GENOTYPE IDS ARE NEEDED
exit 0

# for testing only; turn off before running on production
cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

-- change the transmission type for Allele: MGI:4435328, Zfp715<tm1a(EUCOMM)Hmgu> (610449)
-- to 'Chimeric'
update ALL_Allele set _Transmission_key = 3982952 where _Allele_key = 610449
go

EOSQL

# run test - part 1A - additional genotypes
${HTMPLOAD}/test/runtest_part1A.sh ${HTMPLOAD}/test/sangermpload.config.test | tee -a ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

select count(*) from GXD_Genotype g where g._createdby_key = 1524
go

select count(a._Annot_key)
from GXD_Genotype g, VOC_Annot a
where g._createdby_key = 1524
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

select count(a._Annot_key)
from GXD_Genotype g, VOC_Annot a
where g._createdby_key = 1524
and g._Genotype_key = a._Object_key
and a._AnnotType_key = 1002
go

EOSQL

# run test - part 1 - europhenome input file
${HTMPLOAD}/test/runtest_part1.sh ${HTMPLOAD}/test/europhenompload.config.test ${HTMPLOAD}/bin/europhenompload.sh ${HTMPLOAD}/test/annotload.config.test | tee -a ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

select count(*) from GXD_Genotype g where g._createdby_key = 1524
go

select count(a._Annot_key)
from GXD_Genotype g, VOC_Annot a
where g._createdby_key = 1524
and g._Genotype_key = a._Object_key
and a._AnnotType_key = 1002
go

EOSQL


# run test - part 2 - MP & OMIM annotations (sanger)
${HTMPLOAD}/test/runtest_part2.sh ${HTMPLOAD}/test/sangermpload.config.test | tee -a ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

select count(*) from GXD_Genotype g where g._createdby_key = 1526
go

select count(a._Annot_key)
from VOC_Annot a, VOC_Evidence e
where a._AnnotType_key = 1002
and a._Annot_key = e._Annot_key
and e._createdby_key = 1526
go

-- should be zero (empty)
select distinct _Allele_key_1 from GXD_AllelePair a
where not exists
(select 1 from GXD_AlleleGenotype g
where a._Genotype_key = g._Genotype_key
and a._Allele_key_1 = g._Allele_key)
union
select distinct _Allele_key_2 from GXD_AllelePair a
where a._Allele_key_2 is not null
and not exists
(select 1 from GXD_AlleleGenotype g
where a._Genotype_key = g._Genotype_key
and a._Allele_key_2 = g._Allele_key)
go

EOSQL

# run test - part 3 - review (sanger + euro)
${HTMPLOAD}/test/runtest_part3.sh ${HTMPLOAD}/test/sangermpload.config.test | tee -a ${LOG}
${HTMPLOAD}/test/runtest_part3.sh ${HTMPLOAD}/test/europhenompload.config.test | tee -a ${LOG}

# run test of real input data - part 3 - review (sanger + euro)
${HTMPLOAD}/test/runtest_part3.sh ${HTMPLOAD}/sangermpload.config | tee -a ${LOG}
${HTMPLOAD}/test/runtest_part3.sh ${HTMPLOAD}/europhenompload.config | tee -a ${LOG}

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

