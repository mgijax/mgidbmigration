#!/bin/csh -f

# Sharon, comment this line out
cd `dirname $0` && source ./Configuration

# Sharon, un-comment and set appropriately
#setenv CACHELOAD        /home/sc/jsam/seqcacheload
#setenv newmgddbschema	 /home/sc/jsam/mgddbschema
#source ${newmgddbschema}/Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date | tee -a  ${LOG}
 
# drop and re-create SP (Sharon)

#${newmgddbschema}/procedure/SEQ_createDummyTest_drop.object
#${newmgddbschema}/procedure/SEQ_createDummyTest_create.object

# drop indexes

#${newmgddbschema}/index/ACC_Accession_drop.object
#${newmgddbschema}/index/SEQ_Sequence_drop.object
#${newmgddbschema}/index/SEQ_Source_Assoc_drop.object

# un-partition tables

cat - <<EOSQL | doisql.csh $0 >> ${LOG}
  
use ${DBNAME}
go

update statistics SEQ_Sequence
go

update statistics SEQ_Source_Assoc
go

update statistics ACC_Accession
go

checkpoint
go

quit
 
EOSQL

# re-build indexes

#${newmgddbschema}/index/ACC_Accessione_create.object
#${newmgddbschema}/index/SEQ_Sequence_create.object
#${newmgddbschema}/index/SEQ_Source_Assoc_create.object

# re-partition tables

# load Sequence Cache tables

${CACHELOAD}/seqmarker.csh | tee -a ${LOG}
${CACHELOAD}/seqprobe.csh | tee -a ${LOG}

date | tee -a  ${LOG}

