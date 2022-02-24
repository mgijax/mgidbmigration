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

select orcid, _user_key, login, name from mgi_user where orcid is not null ;

update mgi_user set orcid = 'https://orcid.org/0000-0001-5501-853X' where _user_key = 1525;
update mgi_user set orcid = 'https://orcid.org/0000-0001-7476-6306' where _user_key = 1072;
update mgi_user set orcid = 'https://orcid.org/0000-0001-8691-8856' where _user_key = 1200;
update mgi_user set orcid = 'https://orcid.org/0000-0001-9990-8331' where _user_key = 1094;
update mgi_user set orcid = 'https://orcid.org/0000-0002-0871-5567' where _user_key = 1095;
update mgi_user set orcid = 'https://orcid.org/0000-0002-2246-3722' where _user_key = 1213;
update mgi_user set orcid = 'https://orcid.org/0000-0002-5741-7128' where _user_key = 1209;
update mgi_user set orcid = 'https://orcid.org/0000-0002-5819-0228' where _user_key = 1031;
update mgi_user set orcid = 'https://orcid.org/0000-0002-9796-7693' where _user_key = 1085;
update mgi_user set orcid = 'https://orcid.org/0000-0003-2689-5511' where _user_key = 1076;
update mgi_user set orcid = 'https://orcid.org/0000-0003-3394-9805' where _user_key = 1452;

select orcid, _user_key, login, name from mgi_user where orcid is not null ;

update voc_evidence_property set value=replace(value, 'http:', 'https:')
where _createdby_key in ( 1525, 1072, 1200, 1094, 1095, 1213, 1209, 1031, 1085, 1076, 1452)
;

select _evidenceproperty_key, value
from voc_evidence_property
where value like 'https://orc%'
and _createdby_key in ( 1525, 1072, 1200, 1094, 1095, 1213, 1209, 1031, 1085, 1076, 1452)
;

EOSQL

date |tee -a $LOG
