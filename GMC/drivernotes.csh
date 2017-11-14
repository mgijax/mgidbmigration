#!/bin/csh -f

#
# driver notes
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
--insert into VOC_Vocab values ((select max(_Vocab_key) + 1 from VOC_Vocab), 231052, 1, 1, 0, 'Allele to Driver Gene', now(), now()) ;
--insert into MGI_Relationship_Category values ((select max(_category_key) + 1 from MGI_Relationship_Category), 'allele_to_driver_gene', (select max(_vocab_key) from VOC_Vocab),null,11,2,94,95,1001,1001,now(),now()) ;
--insert into VOC_Term values((select max(_Term_key) + 1 from VOC_Term), 132, 'has_driver', null, 1, 0, 1001, 1001, now(), now());
delete from MGI_Relationship where _Category_key = 1006;
EOSQL

setenv COLDELIM "|" 
setenv LINEDELIM  "\n"

./drivernotes.py

# need python script to load 
# MRK_Marker (non-mouse)
# MGI_Relationship

${PG_DBUTILS}/bin/bcpin.csh ${PG_DBSERVER} ${PG_DBNAME} MGI_Relationship ${DBUTILS}/mgidbmigration/GMC MGI_Relationship.bcp ${COLDELIM} ${LINEDELIM} mgd | tee -a ${LOG}

# query using driver note data
./drivermouse.csh

# query using mgi_relationship data
./drivercheck.csh

date |tee -a $LOG

