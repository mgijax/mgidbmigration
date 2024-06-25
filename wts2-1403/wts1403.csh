#!/bin/csh -f

#
# change OMIM -> MIM
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

delete from acc_accession where _logicaldb_key = 191 and prefixpart = 'MIM:';

EOSQL

# vocload/bin/DOpostprocess.py
# vocload/bin/loadTerms.py
# vocload/bin/OBOParser.py
${VOCLOAD}/runOBOIncLoadNoArchive.sh DO.config | tee -a $LOG

# entrezgeneload/human/createBuckets.csh
#${ENTREZGENELOAD}/loadHuman.csh | tee -a $LOG

# qcrpeorts_db/weekly/VOC_OMIMDOObsolete.py
cd ${QCRPTS}
source ./Configuration
cd weekly
${PYTHON} VOC_OMIMDOMult.py | tee -a $LOG
${PYTHON} VOC_OMIMDOObsolete.py | tee -a $LOG
cd ${PUBRPTS}
source ./Configuration
cd weekly
${PYTHON} MGI_DO.py | tee -a $LOG

date |tee -a $LOG

