#!/bin/csh -f

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

select v._relationshipproperty_key, v.value, o._organism_key, o.commonname
into toupdate
from mgi_relationship_property v, mgi_organism o
where v._propertyname_key = 12948290
and lower(v.value) = o.commonname
and v.value != o.commonname
order by v.value
;
update mgi_relationship_property v
set value = t.commonname
from toupdate t
where t._relationshipproperty_key = v._relationshipproperty_key
;
select v._relationshipproperty_key, v.value, o._organism_key, o.commonname
from mgi_relationship_property v, mgi_organism o
where v._propertyname_key = 12948290
and lower(v.value) = o.commonname
and v.value != o.commonname
order by v.value
;

update mgi_relationship_property set value = 'Not Specified' where _propertyname_key = 12948290 and value in ('Not specified', 'Not Speficied');
update mgi_relationship_property set value = 'rabbit' where _propertyname_key = 12948290 and value in ('Rabit');
update mgi_relationship_property set value = 'rabbit' where _propertyname_key = 12948290 and value in ('Rabbit');

select distinct v.value from mgi_relationship_property v where v._propertyname_key = 12948290 order by value;

insert into VOC_Term values(nextval('voc_term_seq'), 97, 'Non-mouse_HGNC_Gene_ID', 'Non-mouse_HGNC_Gene_ID', null, 11, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 97, 'Non-mouse_RGD_Gene_ID', 'Non-mouse_RGD_Gene_ID', null, 12, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 97, 'Non-mouse_ZFIN_Gene_ID', 'Non-mouse_ZFIN_Gene_ID', null, 13, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 97, 'Non-mouse_WB_Gene_ID', 'Non-mouse_WB_Gene_ID', null, 14, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 97, 'Non-mouse_FB_Gene_ID', 'Non-mouse_FB_Gene_ID', null, 15, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 97, 'Non-mouse_SGD_Gene_ID', 'Non-mouse_SGD_Gene_ID', null, 16, 0, 1001, 1001, now(), now());

EOSQL

date |tee -a $LOG


