#!/bin/csh -fx

#
# Migration for TR10273 -- Europhenome/Sanger MP annotations
# (test part 2 running loads)
#
# VERIFY THAT THE NEW GENOTYPE IDS ARE CORRECT
#
# 1. run Europhenome dataload with Europhenome BioMart as input (real)
#
# 2. run 'runtest_part1' to load the Europhenome test data (kick-out/mock)
#
# 3. run 'runtest_part2' to load additional MP & OMIM annotations for testing (sanger only)
# MP/OMIM data files use the created-by = 'scrum-dog'
#
# 4. run 'runtest_part3' to review the tests (pass/fail) (sanger)
#
# 5. run marker/coordinate test
#
# 6. run cache loads
#
# 7. make backup of DEV1_MGI..mgd_lec1
#
# 8. load backup into DEV_MGI..mgd_dev
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

# run test - part 1 - europhenome input file
${HTMPLOAD}/test/runtest_part1.sh ${HTMPLOAD}/test/europhenompload.config.test ${HTMPLOAD}/bin/europhenompload.sh ${HTMPLOAD}/test/europheno.annotload.config.test | tee -a ${LOG}

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
${HTMPLOAD}/test/runtest_part2.sh ${HTMPLOAD}/test/sangermpload.config.test ${HTMPLOAD}/test/sanger.annotload.config.test | tee -a ${LOG}

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
#${HTMPLOAD}/test/runtest_part3.sh ${HTMPLOAD}/sangermpload.config | tee -a ${LOG}
#${HTMPLOAD}/test/runtest_part3.sh ${HTMPLOAD}/europhenompload.config | tee -a ${LOG}

date | tee -a ${LOG}
echo 'Marker-Coordinate load' | tee -a ${LOG}
cp ${DBUTILS}/mgidbmigration/TR10273/C4AM_AlphaBuild_input.txt ${DATALOADSOUTPUT}/mgi/mrkcoordload/input/mrkcoordload.txt
${MRKCOORDLOAD}/bin/mrkcoordload.sh

date | tee -a ${LOG}
echo 'Load Sequence/Coordinate Cache Table' | tee -a ${LOG}
${SEQCACHELOAD}/seqcoord.csh
date | tee -a ${LOG}
echo 'Load Sequence/Marker Cache Table' | tee -a ${LOG}
${SEQCACHELOAD}/seqmarker.csh
date | tee -a ${LOG}
echo 'Load Sequence/Probe Cache Table' | tee -a ${LOG}
${SEQCACHELOAD}/seqprobe.csh
date | tee -a ${LOG}
echo 'Load Sequence/Description Cache Table' | tee -a ${LOG}
${SEQCACHELOAD}/seqdescription.csh

date | tee -a ${LOG}
echo 'Load Marker/Label Cache Table' | tee -a ${LOG}
${MRKCACHELOAD}/mrklabel.csh
date | tee -a ${LOG}
echo 'Load Marker/Reference Cache Table' | tee -a ${LOG}
${MRKCACHELOAD}/mrkref.csh
date | tee -a ${LOG}
echo 'Load Marker/Homology Cache Table' | tee -a ${LOG}
${MRKCACHELOAD}/mrkhomology.csh
date | tee -a ${LOG}
echo 'Load Marker/Location Cache Table' | tee -a ${LOG}
${MRKCACHELOAD}/mrklocation.csh
date | tee -a ${LOG}
echo 'Load Marker/Probe Cache Table' | tee -a ${LOG}
${MRKCACHELOAD}/mrkprobe.csh
date | tee -a ${LOG}
echo 'Load Marker/MCV Cache Table' | tee -a ${LOG}
${MRKCACHELOAD}/mrkmcv.csh

date | tee -a ${LOG}
echo 'Load Allele/Label Cache Table' | tee -a ${LOG}
${ALLCACHELOAD}/alllabel.csh
ate | tee -a ${LOG}
cho 'Load Allele/Combination Cache Table' | tee -a ${LOG}
{ALLCACHELOAD}/allelecombination.csh
date | tee -a ${LOG}
echo 'Load Marker/OMIM Cache Table' | tee -a ${LOG}
# the OMIM cache depends on the allele combination note 3
${MRKCACHELOAD}/mrkomim.csh
date | tee -a ${LOG}
echo 'Load Allele/Strain Cache Table' | tee -a ${LOG}
${ALLCACHELOAD}/allstrain.csh
date | tee -a ${LOG}
echo 'Load Allele/CRE Cache Table' | tee -a ${LOG}
${ALLCACHELOAD}/allelecrecache.csh

date | tee -a ${LOG}
echo 'Load Bib Citation Cache Table' | tee -a ${LOG}
${MGICACHELOAD}/bibcitation.csh
date | tee -a ${LOG}
echo 'Load Image Cache Table' | tee -a ${LOG}
${MGICACHELOAD}/imgcache.csh

date | tee -a ${LOG}
echo 'Load Voc/Count Cache Table' | tee -a ${LOG}
${MGICACHELOAD}/voccounts.csh
date | tee -a ${LOG}
echo 'Load Voc/Marker Cache Table' | tee -a ${LOG}
${MGICACHELOAD}/vocmarker.csh
date | tee -a ${LOG}
echo 'Load Voc/Allele Cache Table' | tee -a ${LOG}
${MGICACHELOAD}/vocallele.csh

date | tee -a ${LOG}
echo 'Make backup of DEV1_MGI..mgd_lec1' | tee -a ${LOG}
${MGI_DBUTILS}/bin/dump_db.csh DEV1_MGI mgd_lec1 /backups/rohan/scrum-dog/mgd_htmp.sybase
date | tee -a ${LOG}
echo 'Load backup into DEV_MGI..mgd_dev' | tee -a ${LOG}
${MGI_DBUTILS}/bin/load_db.csh DEV_MGI mgd_dev /backups/rohan/scrum-dog/mgd_htmp.sybase

date | tee -a ${LOG}
echo 'QC Reports' | tee -a ${LOG}
${QCRPTS}/qcnightly_reports.csh

date | tee -a ${LOG}
echo 'QC Reports' | tee -a ${LOG}
${QCRPTS}/qcmonthly_reports.csh

# this must run before the generateGIAAssoc.csh script
# which depends on GIA_???.py reports
date | tee -a ${LOG}
echo 'QC Reports' | tee -a ${LOG}
${QCRPTS}/qcweekly_reports.csh

date | tee -a ${LOG}
echo 'Daily Public Reports' | tee -a ${LOG}
${PUBRPTS}/nightly_reports.csh

date | tee -a ${LOG}
echo 'Weekly Public Reports' | tee -a ${LOG}
${PUBRPTS}/weekly_reports.csh

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

