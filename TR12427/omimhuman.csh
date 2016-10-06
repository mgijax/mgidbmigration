#!/bin/csh -f

#
# Template
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

select v._Object_key,
       a1.accID as omimid, 
       a2.accID as doomimid, 
       a3.accID as doid, 
       a4.accID as markerid,
       a5.accID as refid,
       t1.term as qualifer,
       t2.abbreviation as evidence,
       e.inferredFrom,
       u1.login as modifiedBy,
       e.modification_date
from VOC_Annot v, VOC_Evidence e,
	ACC_Accession a1, VOC_Term oo, 
	ACC_Accession a2, ACC_Accession a3, ACC_Accession a4, ACC_Accession a5,
        VOC_Term t1, VOC_Term t2, MGI_User u1
where v._AnnotType_key = 1006
and v._Term_key = oo._Term_key
and oo._Term_key = a1._Object_key
and a1._MGIType_key = 13
and oo._Vocab_key = 44
and a1.accID = a2.accID
and a2._LogicalDB_key = 15
and a2._MGIType_key = 13
and a2._Object_key = a3._Object_key
and a3._LogicalDB_key = 191
and v._Object_key = a4._Object_key
and a4._MGIType_key = 2
and a4._LogicalDB_key = 55
and v._Annot_key = e._Annot_key
and e._Refs_key = a5._Object_key
and a5._LogicalDB_key = 1
and a5._MGIType_key = 1
and a5.prefixPart = 'J:'
and v._Qualifier_key = t1._Term_key
and e._EvidenceTerm_key = t2._Term_key
and e._ModifiedBy_key = u1._User_key
;

select count(e.*) from VOC_Annot v, VOC_Evidence e where v._AnnotType_key = 1006 and v._Annot_key = e._Annot_key;
select count(e.*) from VOC_Annot v, VOC_Evidence e where v._AnnotType_key = 1022 and v._Annot_key = e._Annot_key;

EOSQL

date |tee -a $LOG

