#!/bin/csh -f

#
# mirror_wget : ftp.ensembl.org.mouse_gff3
#
# strainmarkerload : 
#
# Code changes:
# 1. DONE: merge some redudant qc reports
# 2. DONE: use ldb = 60 for ENS, else 209
# 3. DONE: if projection_parent_gene > 1, then just use the first projection_parent_gene
# 4. DONE : if projection_parent_gene contains MGP id, then old MGP add to ACC_Accession as secondary id
# 5. DONE : add call to patched script
# 6. genemodelload : remove patched lastrun script (see snpcacheload)
# 
# straingenemodelload (sprte) :
# assemblyseqload (sprte) :
# genemodelload (sprte) :
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
delete from app_jobstream where returncode is null;

-- delete old 282407 | J:259852 | Database Release 2018;()
select _StrainMarker_key
into temporary table toDelete
from MRK_StrainMarker
where _Refs_key in (282407)
;
create index idx1 on toDelete(_StrainMarker_key);
delete from MRK_StrainMarker sm using toDelete d where d._StrainMarker_key = sm._StrainMarker_key;

EOSQL

# delete annotations old 282407 | J:259852
${ANNOTLOAD}/annotload.csh mgp_annotloaddelete.config | tee -a $LOG

#
# run one more time
# github : save and tag the strainmarkerload product
#
#date | tee -a $LOG
#cd ${STRAINMARKERLOAD}/bin
#./archive_mgps.csh
#gzip archive_mgps.csh.log

# pick up new biotypes
# lncRNA  lncRNA gene
date | tee -a $LOG
${GENEMODELLOAD}/bin/biotypemapping.sh | tee -a $LOG

# make sure we have the latest MGI.gff3 file before running
# /export/rohan/ftp/pub/mgigff3/MGI.gff3.gz
# /export/gondor/ftp/pub/mgigff3/MGI.gff3.gz

date | tee -a $LOG
${STRAINMARKERLOAD}/bin/strainmarkerload.sh | tee -a $LOG

date |tee -a $LOG

