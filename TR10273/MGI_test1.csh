#!/bin/csh -fx

#
# Migration for TR10273 -- Europhenome/Sanger MP annotations
# (test part 1 running loads)
#
# 1. run Sanger dataload with Sanger BioMart as input (real)
#
# 2. run 'runtest_part1' to load the Sanger test data (kick-out/mock)
#
# 3. run 'runtest_part1A' to load the Sanger test data (additional genotypes)
#
# STOP here if "additional genotypes" IDs are changing from last run
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

# run part 1 of migration
./MGI_part1.csh dev

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

-- should return (0)
select count(aa._Allele_key)
from GXD_AlleleGenotype g, VOC_Annot a, VOC_Evidence e, ALL_Allele aa, BIB_Citation_Cache c
where g._Genotype_key = a._Object_key
and a._AnnotType_key = 1002
and g._Allele_key = aa._Allele_key
and aa.isWildType = 0
and aa._Transmission_key in (3982952, 3982953)
and a._Annot_key = e._Annot_key
and e._Refs_key = c._Refs_key
and c.jnumID in ('J:175295')
go

EOSQL

exit 0

#
# due to the need for genotype ids set to specific values further down the pipeline
# the sanger tests need to run **before** the euro load
#
# run test - part 1 - sanger input file
${HTMPLOAD}/test/runtest_part1.sh ${HTMPLOAD}/test/sangermpload.config.test ${HTMPLOAD}/bin/sangermpload.sh ${HTMPLOAD}/test/sanger.annotload.config.test | tee -a ${LOG}

# for testing only; turn off before running on production
cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

-- change the transmission type for Allele: MGI:4435328, Zfp715<tm1a(EUCOMM)Hmgu> (610449)
-- to 'Chimeric'
update ALL_Allele set _Transmission_key = 3982952 where _Allele_key = 610449
go

-- should be (1)
select count(*) from ALL_Allele where _Allele_key = 610449 and _Transmission_key = 3982952
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

# STOP IF NEW GENOTYPE IDS ARE NEEDED

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

