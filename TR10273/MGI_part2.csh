#!/bin/csh -fx

#
# Migration for TR10273 -- Europhenome/Sanger MP annotations
# (part 2 running loads)
#
# 1. run Sanger dataload with Sanger BioMart as input (real)
#
# 2. run Europhenome dataload with Europhenome BioMart as input (real)
#
# 3. run marker/omim cache
#
# 4. run test of real input data
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
${HTMPLOAD}/bin/htmpload.sh ${HTMPLOAD}/sangermpload.config ${HTMPLOAD}/annotload.config | tee -a ${LOG}

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

# run htmpload/europhenom
${HTMPLOAD}/bin/htmpload.sh ${HTMPLOAD}/europhenompload.config ${HTMPLOAD}/annotload.config | tee -a ${LOG}

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
and c.jnumID in ('J:165965')
go

EOSQL

date | tee -a ${LOG}
echo 'Load Allele/Combination Cache Table' | tee -a ${LOG}
${ALLCACHELOAD}/allelecombination.csh

date | tee -a ${LOG}
echo 'Load Marker/OMIM Cache Table' | tee -a ${LOG}
${MRKCACHELOAD}/mrkomim.csh

date | tee -a ${LOG}
echo 'Load Marker/Reference Cache Table' | tee -a ${LOG}
${MRKCACHELOAD}/mrkref.csh

# run test of real input data
${HTMPLOAD}/test/runtest_part3.sh ${HTMPLOAD}/sangermpload.config | tee -a ${LOG}
${HTMPLOAD}/test/runtest_part3.sh ${HTMPLOAD}/europhenompload.config | tee -a ${LOG}

###-----------------------###
###--- final datestamp ---###
###-----------------------###
date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

