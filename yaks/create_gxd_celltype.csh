#!/bin/csh -fx


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
echo '--- starting part 1' | tee -a $LOG

echo 'MGD_DBNAME='$MGD_DBNAME | tee -a $LOG 
echo 'MGD_DBPASSWORDFILE='$MGD_DBPASSWORDFILE | tee -a $LOG 
echo 'MGD_DBSERVER='$MGD_DBSERVER | tee -a $LOG 
echo 'MGD_DBUSER='$MGD_DBUSER | tee -a $LOG 

#
# create test cases for gxd_isresultcelltype
#
#one-to-one
#EMAPA:35223 cerebellum Purkinje cell layer (resultKey in (1926250, 1925572, 1925577)) - CL:0000121 Purkinje cell (termKey=90887561)
#EMAPA:35739 retina ganglion cell layer (resultKey in (1924417, 1923898, 1923896)) – CL:0000740 retinal ganglion cell #EMAPA:35217 cerebellum granule cell layer - CL:0001031 cerebellar granule cell (termKey=90888451)
#EMAPA:35406 hippocampus granule cell layer (resultKey in (1784262, 1784279, 1784263)) - CL:0001033 hippocampal granule cell (termKey=90888453)
#
#many-to-one
#EMAPA:35609 main olfactory bulb granule cell layer (resultKey in (1926020, 1924181, 1922738)) - CL:0000626 olfactory granule cell (termKey=90888053)
#EMAPA:35109 accessory olfactory bulb granule cell layer (resultKey in (1788176, 1788173, 1765609)) - CL:0000626 olfactory granule cell (termKey=90888053)
#
#one-to-many
#EMAPA:29106 Sertoli cell (resultKey in (1763464, 1920381, 1920126)) - CL:0000216 Sertoli cell (termKey=90887652)
#EMAPA:29106 Sertoli cell (resultKey in (1763464, 1920381, 1920126)) - CL:0002481 peritubular myoid cell (termKey=90888981)
#
date | tee -a ${LOG}
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

--one-to-one
insert into gxd_isresultcelltype values (1, 1926250, 90887561, now(), now());
insert into gxd_isresultcelltype values (2, 1925572, 90887561, now(), now());
insert into gxd_isresultcelltype values (3, 1925577, 90887561, now(), now());

insert into gxd_isresultcelltype values (4, 1924417, 90888451, now(), now());
insert into gxd_isresultcelltype values (5, 1923898, 90888451, now(), now());
insert into gxd_isresultcelltype values (6, 1923896, 90888451, now(), now());

insert into gxd_isresultcelltype values (7, 1784262, 90888453, now(), now());
insert into gxd_isresultcelltype values (8, 1784279, 90888453, now(), now());
insert into gxd_isresultcelltype values (9, 1784263, 90888453, now(), now());

--many-to-one
insert into gxd_isresultcelltype values (10, 1926020, 90888053, now(), now());
insert into gxd_isresultcelltype values (11, 1924181, 90888053, now(), now());
insert into gxd_isresultcelltype values (12, 1922738, 90888053, now(), now());

insert into gxd_isresultcelltype values (13, 1788176, 90888053, now(), now());
insert into gxd_isresultcelltype values (14, 1788173, 90888053, now(), now());
insert into gxd_isresultcelltype values (15, 1765609, 90888053, now(), now());

--one-to-many
insert into gxd_isresultcelltype values (16, 1763464, 90887652, now(), now());
insert into gxd_isresultcelltype values (17, 1920381, 90887652, now(), now());
insert into gxd_isresultcelltype values (18, 1920126, 90887652, now(), now());

insert into gxd_isresultcelltype values (19, 1763464, 90888981, now(), now());
insert into gxd_isresultcelltype values (20, 1920381, 90888981, now(), now());
insert into gxd_isresultcelltype values (21, 1920126, 90888981, now(), now());

select setval('gxd_isresultcelltype_seq', (select max(_resultcelltype_key) from GXD_ISResultCellType));

EOSQL

date | tee -a ${LOG}

