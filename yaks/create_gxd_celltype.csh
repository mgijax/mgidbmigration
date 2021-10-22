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
# J:122606      MGI:6162057     4i      Zic1    28      cerebellum internal granule cell layer  Expression in mature granule cells.     CL:0001031      cerebellar granule cell 

#one-to-many
# J:17847 MGI:5304804     2B      Gfap    28      cerebellum Purkinje cell layer  Expression in Bergmann glia and astrocytes    CL:0000644      Bergmann glial cell 
#             CL:0000127      astrocyte 

#many-to-one
# J:210150        MGI:5754355     2D +/+  Cux1    28      cortical layer II       Expression is in pyramidal cells.       CL:0000598      pyramidal neuron
# J:210150        MGI:5754355     2D +/+  Cux1    28      cortical layer III      Expression is in pyramidal cells.       CL:0000598      pyramidal neuron

#many-to-many
# J:100919      MGI:4940881     1C top brain section    Tg(Pcdh21-cre)BYoko
# P     accessory olfactory bulb external plexiform layer       Expression is observed only in mitral and       CL:1001502
# J:100919      MGI:4940881     1C top brain section    Tg(Pcdh21-cre)BYoko P     accessory olfactory bulb mitral cell layer      tufted cells of the accessory olfactory bulb    CL:1001503
# J:100919      MGI:4940881     1C top brain section    Tg(Pcdh21-cre)BYoko P     main olfactory bulb external plexiform layer    Expression is observed only in mitral and       
# J:100919      MGI:4940881     1C top brain section    Tg(Pcdh21-cre)BYoko P     main olfactory bulb mitral cell layer   tufted cells of the main olfactory bulb 
#

date | tee -a ${LOG}
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

--one-to-one
insert into gxd_isresultcelltype values (1, 1723155, (select _object_key from acc_accession where _mgitype_key = 13 and accid = 'CL:0001031'), now(), now());
--_results_key = 1723155, CL:0001031

--many-to-one
insert into gxd_isresultcelltype values (2, 1473081, (select _object_key from acc_accession where _mgitype_key = 13 and accid = 'CL:0000598'), now(), now());
insert into gxd_isresultcelltype values (3, 1473082, (select _object_key from acc_accession where _mgitype_key = 13 and accid = 'CL:0000598'), now(), now());
-- _results_key =1473081 ,  CL:0000598
-- _results_key =1473082 ,   CL:0000598

--one-to-many
insert into gxd_isresultcelltype values (4, 945152, (select _object_key from acc_accession where _mgitype_key = 13 and accid = 'CL:0000644'), now(), now());
insert into gxd_isresultcelltype values (5, 945152, (select _object_key from acc_accession where _mgitype_key = 13 and accid = 'CL:0000127'), now(), now());
-- _results_key = 945152, CL:0000644
-- _results_key = 945152, CL:0000127

--many-to-many
insert into gxd_isresultcelltype values (6, 779469, (select _object_key from acc_accession where _mgitype_key = 13 and accid = 'CL:0001502'), now(), now());
insert into gxd_isresultcelltype values (7, 779469, (select _object_key from acc_accession where _mgitype_key = 13 and accid = 'CL:0001503'), now(), now());
insert into gxd_isresultcelltype values (8, 779470, (select _object_key from acc_accession where _mgitype_key = 13 and accid = 'CL:0001502') , now(), now());
insert into gxd_isresultcelltype values (9, 779470, (select _object_key from acc_accession where _mgitype_key = 13 and accid = 'CL:0001503') , now(), now());

--  _results_key =779469 ,   CL:1001502
--  _results_key =779469 ,  CL:1001503
--  _results_key = 779470,  CL:1001502
--  _results_key = 779470, , CL:1001503

select setval('gxd_isresultcelltype_seq', (select max(_resultcelltype_key) from GXD_ISResultCellType));

EOSQL

date | tee -a ${LOG}

