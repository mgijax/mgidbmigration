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

insert into VOC_Vocab values ((select max(_Vocab_key) + 1) from VOC_Vocab), 231052, 1, 1, 0, 'Allele to Driver Gene', now(), now())
;

insert into MGI_Relationship_Category values ((select max(_category_key) + 1 from MGI_Relationship_Category),
          'Allele_to_Driver_Gene', (select max(_vocab_key) from VOC_Vocab),11,2,94,95,1001,1001,now(),now())
	  ;

EOSQL

-- need python script to load 
--MRK_Marker (non-mouse)
--MGI_Relationship
--MGI_Relationship_Property

date |tee -a $LOG

