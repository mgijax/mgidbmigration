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
 
#cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
#delete from MGI_Property where _property_key >= 12834354;
#select setval('mgi_property_seq', (select max(_Property_key) from MGI_Property));
#EOSQL

$PYTHON wts1609.py | tee -a $LOG
${PG_DBUTILS}/bin/bcpin.csh ${MGD_DBSERVER} ${MGD_DBNAME} MGI_Property /mgi/all/wts2_projects/1600/WTS2-1609 MGI_Property.bcp "|" "\n" mgd | tee -a $LOG

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

select setval('mgi_property_seq', (select max(_Property_key) from MGI_Property));

select a.accid, p.value, p._property_key
from ACC_Accession a, MGI_Property p
where p._property_key >= 12875770
and p._object_key = a._Object_key
and a._logicaldb_key = 190
and a._mgitype_key = 42
and p._mgitype_key = 42
and p._PropertyTerm_key = 20475430
and p._PropertyType_key = 1002
;

EOSQL

date |tee -a $LOG

