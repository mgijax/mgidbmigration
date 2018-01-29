#!/bin/csh -fx

#
# add MGI_Set/MGI_SetMember for Journals
#

###----------------------###
###--- initialization ---###
###----------------------###

if ( ${?MGICONFIG} == 0 ) then
	setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}

date | tee -a ${LOG}
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG || exit 1

--insert into MGI_Set values(1052, 1, 'Journal/AP', 1, 1001, 1001, now(), now());
--insert into MGI_Set values(1053, 1, 'Journal/GO', 1, 1001, 1001, now(), now());
--insert into MGI_Set values(1054, 1, 'Journal/GXD', 1, 1001, 1001, now(), now());
--insert into MGI_Set values(1055, 1, 'Journal/Tumor', 1, 1001, 1001, now(), now());

delete from MGI_SetMember where _Set_key in (1052,1053,1054,1055);

insert into MGI_SetMember values((select max(_setmember_key) + 1 from mgi_setmember), 1052, (select _Term_key from voc_term where _vocab_key = 90 and term = 'unfertilized egg'), 1, 1001, 1001, now(), now());
insert into MGI_SetMember values(8587443, 1046, (select _Term_key from voc_term where _vocab_key = 90 and term = '8-cell stage conceptus'), 2, 1001, 1001, now(), now());
insert into MGI_SetMember values(8587444, 1046, (select _Term_key from voc_term where _vocab_key = 90 and term = 'blastocyst-stage conceptus'), 3, 1001, 1001, now(), now());
insert into MGI_SetMember values(8587445, 1046, (select _Term_key from voc_term where _vocab_key = 90 and term = '1-cell stage conceptus'), 4, 1001, 1001, now(), now());
insert into MGI_SetMember values(8587446, 1046, (select _Term_key from voc_term where _vocab_key = 90 and term = '2-cell stage conceptus'), 5, 1001, 1001, now(), now());

EOSQL
