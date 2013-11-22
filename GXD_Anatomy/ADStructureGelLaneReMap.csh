#!/bin/csh -fx

#
# Migration for TR11423
# sto88 : add new annotation type
#

###----------------------###
###--- initialization ---###
###----------------------###

if ( ${?MGICONFIG} == 0 ) then
	setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

env | grep MGD

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}


date | tee -a ${LOG}
cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

delete from GXD_GelLaneStructure where _GelLane_key = 156922 and _Structure_key = 6942
insert into GXD_GelLaneStructure (_GelLane_key, _Structure_key) values(156922, 6939)
update GXD_GelLane set laneNote = "Expression analyzed in osteoblasts." where _GelLane_key = 156922
delete from GXD_GelLaneStructure where _GelLane_key = 156923 and _Structure_key = 6942
insert into GXD_GelLaneStructure (_GelLane_key, _Structure_key) values(156923, 6939)
update GXD_GelLane set laneNote = "Expression analyzed in osteoblasts." where _GelLane_key = 156923
delete from GXD_GelLaneStructure where _GelLane_key = 237423 and _Structure_key = 6942
insert into GXD_GelLaneStructure (_GelLane_key, _Structure_key) values(237423, 6939)
update GXD_GelLane set laneNote = "Expression analyzed in osteoblasts." where _GelLane_key = 237423
delete from GXD_GelLaneStructure where _GelLane_key = 237427 and _Structure_key = 6942
insert into GXD_GelLaneStructure (_GelLane_key, _Structure_key) values(237427, 6939)
update GXD_GelLane set laneNote = "Expression analyzed in osteoblasts." where _GelLane_key = 237427
delete from GXD_GelLaneStructure where _GelLane_key = 81445 and _Structure_key = 7044
insert into GXD_GelLaneStructure (_GelLane_key, _Structure_key) values(81445, 7040)
update GXD_GelLane set laneNote = "Expression analyzed in white blood cells." where _GelLane_key = 81445
delete from GXD_GelLaneStructure where _GelLane_key = 230012 and _Structure_key = 7044
insert into GXD_GelLaneStructure (_GelLane_key, _Structure_key) values(230012, 7040)
update GXD_GelLane set laneNote = "Expression analyzed in leukocytes." where _GelLane_key = 230012
delete from GXD_GelLaneStructure where _GelLane_key = 230028 and _Structure_key = 7044
insert into GXD_GelLaneStructure (_GelLane_key, _Structure_key) values(230028, 7040)
update GXD_GelLane set laneNote = "Expression analyzed in leukocytes." where _GelLane_key = 230028
delete from GXD_GelLaneStructure where _GelLane_key = 230044 and _Structure_key = 7044
insert into GXD_GelLaneStructure (_GelLane_key, _Structure_key) values(230044, 7040)
update GXD_GelLane set laneNote = "Expression analyzed in leukocytes." where _GelLane_key = 230044
delete from GXD_GelLaneStructure where _GelLane_key = 234342 and _Structure_key = 7044
insert into GXD_GelLaneStructure (_GelLane_key, _Structure_key) values(234342, 7040)
update GXD_GelLane set laneNote = "Expression analyzed in leukocytes." where _GelLane_key = 234342
delete from GXD_GelLaneStructure where _GelLane_key = 88997 and _Structure_key = 7054
insert into GXD_GelLaneStructure (_GelLane_key, _Structure_key) values(88997, 6943)
update GXD_GelLane set laneNote = "Expression analyzed in megakaryocytes." where _GelLane_key = 88997
delete from GXD_GelLaneStructure where _GelLane_key = 88998 and _Structure_key = 7054
insert into GXD_GelLaneStructure (_GelLane_key, _Structure_key) values(88998, 6943)
update GXD_GelLane set laneNote = "Expression analyzed in megakaryocytes." where _GelLane_key = 88998
delete from GXD_GelLaneStructure where _GelLane_key = 88711 and _Structure_key = 7055
insert into GXD_GelLaneStructure (_GelLane_key, _Structure_key) values(88711, 7040)
update GXD_GelLane set laneNote = "Expression analyzed in platelets." where _GelLane_key = 88711
delete from GXD_GelLaneStructure where _GelLane_key = 88714 and _Structure_key = 7055
insert into GXD_GelLaneStructure (_GelLane_key, _Structure_key) values(88714, 7040)
update GXD_GelLane set laneNote = "Expression analyzed in platelets." where _GelLane_key = 88714
delete from GXD_GelLaneStructure where _GelLane_key = 158863 and _Structure_key = 7055
insert into GXD_GelLaneStructure (_GelLane_key, _Structure_key) values(158863, 7040)
update GXD_GelLane set laneNote = "Expression analyzed in platelets." where _GelLane_key = 158863
delete from GXD_GelLaneStructure where _GelLane_key = 158864 and _Structure_key = 7055
insert into GXD_GelLaneStructure (_GelLane_key, _Structure_key) values(158864, 7040)
update GXD_GelLane set laneNote = "Expression analyzed in platelets." where _GelLane_key = 158864
delete from GXD_GelLaneStructure where _GelLane_key = 197194 and _Structure_key = 7055
insert into GXD_GelLaneStructure (_GelLane_key, _Structure_key) values(197194, 7040)
update GXD_GelLane set laneNote = "Expression analyzed in platelets." where _GelLane_key = 197194
delete from GXD_GelLaneStructure where _GelLane_key = 197238 and _Structure_key = 7055
insert into GXD_GelLaneStructure (_GelLane_key, _Structure_key) values(197238, 7040)
update GXD_GelLane set laneNote = "Expression analyzed in platelets." where _GelLane_key = 197238
delete from GXD_GelLaneStructure where _GelLane_key = 197285 and _Structure_key = 7055
insert into GXD_GelLaneStructure (_GelLane_key, _Structure_key) values(197285, 7040)
update GXD_GelLane set laneNote = "Expression analyzed in platelets." where _GelLane_key = 197285
delete from GXD_GelLaneStructure where _GelLane_key = 197330 and _Structure_key = 7055
insert into GXD_GelLaneStructure (_GelLane_key, _Structure_key) values(197330, 7040)
update GXD_GelLane set laneNote = "Expression analyzed in platelets." where _GelLane_key = 197330
delete from GXD_GelLaneStructure where _GelLane_key = 197375 and _Structure_key = 7055
insert into GXD_GelLaneStructure (_GelLane_key, _Structure_key) values(197375, 7040)
update GXD_GelLane set laneNote = "Expression analyzed in platelets." where _GelLane_key = 197375
delete from GXD_GelLaneStructure where _GelLane_key = 197420 and _Structure_key = 7055
insert into GXD_GelLaneStructure (_GelLane_key, _Structure_key) values(197420, 7040)
update GXD_GelLane set laneNote = "Expression analyzed in platelets." where _GelLane_key = 197420
delete from GXD_GelLaneStructure where _GelLane_key = 82742 and _Structure_key = 7057
insert into GXD_GelLaneStructure (_GelLane_key, _Structure_key) values(82742, 7036)
update GXD_GelLane set laneNote = "Expression analyzed in mast cells." where _GelLane_key = 82742
delete from GXD_GelLaneStructure where _GelLane_key = 82798 and _Structure_key = 7057
insert into GXD_GelLaneStructure (_GelLane_key, _Structure_key) values(82798, 7036)
update GXD_GelLane set laneNote = "Expression analyzed in mast cells." where _GelLane_key = 82798
delete from GXD_GelLaneStructure where _GelLane_key = 82842 and _Structure_key = 7057
insert into GXD_GelLaneStructure (_GelLane_key, _Structure_key) values(82842, 7036)
update GXD_GelLane set laneNote = "Expression analyzed in mast cells." where _GelLane_key = 82842
delete from GXD_GelLaneStructure where _GelLane_key = 82886 and _Structure_key = 7057
insert into GXD_GelLaneStructure (_GelLane_key, _Structure_key) values(82886, 7036)
update GXD_GelLane set laneNote = "Expression analyzed in mast cells." where _GelLane_key = 82886
delete from GXD_GelLaneStructure where _GelLane_key = 82930 and _Structure_key = 7057
insert into GXD_GelLaneStructure (_GelLane_key, _Structure_key) values(82930, 7036)
update GXD_GelLane set laneNote = "Expression analyzed in mast cells." where _GelLane_key = 82930
delete from GXD_GelLaneStructure where _GelLane_key = 82974 and _Structure_key = 7057
insert into GXD_GelLaneStructure (_GelLane_key, _Structure_key) values(82974, 7036)
update GXD_GelLane set laneNote = "Expression analyzed in mast cells." where _GelLane_key = 82974
delete from GXD_GelLaneStructure where _GelLane_key = 234188 and _Structure_key = 7058
insert into GXD_GelLaneStructure (_GelLane_key, _Structure_key) values(234188, 7036)
update GXD_GelLane set laneNote = "Expression analyzed in macrophages." where _GelLane_key = 234188
delete from GXD_GelLaneStructure where _GelLane_key = 234189 and _Structure_key = 7058
insert into GXD_GelLaneStructure (_GelLane_key, _Structure_key) values(234189, 7036)
update GXD_GelLane set laneNote = "Expression analyzed in macrophages." where _GelLane_key = 234189
delete from GXD_GelLaneStructure where _GelLane_key = 139036 and _Structure_key = 7059
insert into GXD_GelLaneStructure (_GelLane_key, _Structure_key) values(139036, 7040)
update GXD_GelLane set laneNote = "Expression analyzed in lymphocytes." where _GelLane_key = 139036
delete from GXD_GelLaneStructure where _GelLane_key = 139037 and _Structure_key = 7059
insert into GXD_GelLaneStructure (_GelLane_key, _Structure_key) values(139037, 7040)
update GXD_GelLane set laneNote = "Expression analyzed in lymphocytes." where _GelLane_key = 139037
delete from GXD_GelLaneStructure where _GelLane_key = 139120 and _Structure_key = 7059
insert into GXD_GelLaneStructure (_GelLane_key, _Structure_key) values(139120, 7040)
update GXD_GelLane set laneNote = "Expression analyzed in lymphocytes." where _GelLane_key = 139120
delete from GXD_GelLaneStructure where _GelLane_key = 139121 and _Structure_key = 7059
insert into GXD_GelLaneStructure (_GelLane_key, _Structure_key) values(139121, 7040)
update GXD_GelLane set laneNote = "Expression analyzed in lymphocytes." where _GelLane_key = 139121
delete from GXD_GelLaneStructure where _GelLane_key = 139163 and _Structure_key = 7059
insert into GXD_GelLaneStructure (_GelLane_key, _Structure_key) values(139163, 7040)
update GXD_GelLane set laneNote = "Expression analyzed in lymphocytes." where _GelLane_key = 139163
delete from GXD_GelLaneStructure where _GelLane_key = 139164 and _Structure_key = 7059
insert into GXD_GelLaneStructure (_GelLane_key, _Structure_key) values(139164, 7040)
update GXD_GelLane set laneNote = "Expression analyzed in lymphocytes." where _GelLane_key = 139164
delete from GXD_GelLaneStructure where _GelLane_key = 139206 and _Structure_key = 7059
insert into GXD_GelLaneStructure (_GelLane_key, _Structure_key) values(139206, 7040)
update GXD_GelLane set laneNote = "Expression analyzed in lymphocytes." where _GelLane_key = 139206
delete from GXD_GelLaneStructure where _GelLane_key = 139207 and _Structure_key = 7059
insert into GXD_GelLaneStructure (_GelLane_key, _Structure_key) values(139207, 7040)
update GXD_GelLane set laneNote = "Expression analyzed in lymphocytes." where _GelLane_key = 139207
delete from GXD_GelLaneStructure where _GelLane_key = 150309 and _Structure_key = 7059
insert into GXD_GelLaneStructure (_GelLane_key, _Structure_key) values(150309, 7040)
update GXD_GelLane set laneNote = "Expression analyzed in lymphocytes." where _GelLane_key = 150309
delete from GXD_GelLaneStructure where _GelLane_key = 150262 and _Structure_key = 7060
insert into GXD_GelLaneStructure (_GelLane_key, _Structure_key) values(150262, 7040)
update GXD_GelLane set laneNote = "Expression analyzed in peripheral blood T-cells." where _GelLane_key = 150262
delete from GXD_GelLaneStructure where _GelLane_key = 151726 and _Structure_key = 7060
insert into GXD_GelLaneStructure (_GelLane_key, _Structure_key) values(151726, 7040)
update GXD_GelLane set laneNote = "Expression analyzed in T-lymphocytes." where _GelLane_key = 151726
delete from GXD_GelLaneStructure where _GelLane_key = 151728 and _Structure_key = 7060
insert into GXD_GelLaneStructure (_GelLane_key, _Structure_key) values(151728, 7040)
update GXD_GelLane set laneNote = "Expression analyzed in T-lymphocytes." where _GelLane_key = 151728
delete from GXD_GelLaneStructure where _GelLane_key = 47777 and _Structure_key = 7069
insert into GXD_GelLaneStructure (_GelLane_key, _Structure_key) values(47777, 7040)
update GXD_GelLane set laneNote = "Expression analyzed in B-lymphocytes." where _GelLane_key = 47777
delete from GXD_GelLaneStructure where _GelLane_key = 142610 and _Structure_key = 7069
insert into GXD_GelLaneStructure (_GelLane_key, _Structure_key) values(142610, 7040)
update GXD_GelLane set laneNote = "Expression analyzed in B-lymphocytes." where _GelLane_key = 142610
delete from GXD_GelLaneStructure where _GelLane_key = 151727 and _Structure_key = 7069
insert into GXD_GelLaneStructure (_GelLane_key, _Structure_key) values(151727, 7040)
update GXD_GelLane set laneNote = "Expression analyzed in B-lymphocytes." where _GelLane_key = 151727
update GXD_GelLane set laneNote = "Expression analyzed in B-lymphocytes." where _GelLane_key = 151728
delete from GXD_GelLaneStructure where _GelLane_key = 242515 and _Structure_key = 7078
insert into GXD_GelLaneStructure (_GelLane_key, _Structure_key) values(242515, 7040)
update GXD_GelLane set laneNote = "Protein isolated from 100 ug red blood cell membranes." where _GelLane_key = 242515
delete from GXD_GelLaneStructure where _GelLane_key = 242514 and _Structure_key = 7078
insert into GXD_GelLaneStructure (_GelLane_key, _Structure_key) values(242514, 7040)
update GXD_GelLane set laneNote = "Protein isolated from 50 ug red blood cell membranes." where _GelLane_key = 242514
delete from GXD_GelLaneStructure where _GelLane_key = 106736 and _Structure_key = 7078
insert into GXD_GelLaneStructure (_GelLane_key, _Structure_key) values(106736, 7040)
update GXD_GelLane set laneNote = "Protein isolated from platelet-free red blood cells." where _GelLane_key = 106736
delete from GXD_GelLaneStructure where _GelLane_key = 197195 and _Structure_key = 7078
insert into GXD_GelLaneStructure (_GelLane_key, _Structure_key) values(197195, 7040)
update GXD_GelLane set laneNote = "Expression analyzed in erythrocytes." where _GelLane_key = 197195
delete from GXD_GelLaneStructure where _GelLane_key = 197239 and _Structure_key = 7078
insert into GXD_GelLaneStructure (_GelLane_key, _Structure_key) values(197239, 7040)
update GXD_GelLane set laneNote = "Expression analyzed in erythrocytes." where _GelLane_key = 197239
delete from GXD_GelLaneStructure where _GelLane_key = 197286 and _Structure_key = 7078
insert into GXD_GelLaneStructure (_GelLane_key, _Structure_key) values(197286, 7040)
update GXD_GelLane set laneNote = "Expression analyzed in erythrocytes." where _GelLane_key = 197286
delete from GXD_GelLaneStructure where _GelLane_key = 197331 and _Structure_key = 7078
insert into GXD_GelLaneStructure (_GelLane_key, _Structure_key) values(197331, 7040)
update GXD_GelLane set laneNote = "Expression analyzed in erythrocytes." where _GelLane_key = 197331
delete from GXD_GelLaneStructure where _GelLane_key = 197376 and _Structure_key = 7078
insert into GXD_GelLaneStructure (_GelLane_key, _Structure_key) values(197376, 7040)
update GXD_GelLane set laneNote = "Expression analyzed in erythrocytes." where _GelLane_key = 197376
delete from GXD_GelLaneStructure where _GelLane_key = 197421 and _Structure_key = 7078
insert into GXD_GelLaneStructure (_GelLane_key, _Structure_key) values(197421, 7040)
update GXD_GelLane set laneNote = "Expression analyzed in erythrocytes." where _GelLane_key = 197421
delete from GXD_GelLaneStructure where _GelLane_key = 173013 and _Structure_key = 7080
insert into GXD_GelLaneStructure (_GelLane_key, _Structure_key) values(173013, 7040)
update GXD_GelLane set laneNote = "Expression analyzed in reticulocytes." where _GelLane_key = 173013
delete from GXD_GelLaneStructure where _GelLane_key = 173015 and _Structure_key = 7080
insert into GXD_GelLaneStructure (_GelLane_key, _Structure_key) values(173015, 7040)
update GXD_GelLane set laneNote = "Expression analyzed in reticulocytes." where _GelLane_key = 173015
delete from GXD_GelLaneStructure where _GelLane_key = 173026 and _Structure_key = 7080
insert into GXD_GelLaneStructure (_GelLane_key, _Structure_key) values(173026, 7040)
update GXD_GelLane set laneNote = "Expression analyzed in reticulocytes." where _GelLane_key = 173026
delete from GXD_GelLaneStructure where _GelLane_key = 235063 and _Structure_key = 7112
insert into GXD_GelLaneStructure (_GelLane_key, _Structure_key) values(235063, 7109)
update GXD_GelLane set laneNote = "Expression analyzed in white fat adipocytes." where _GelLane_key = 235063
delete from GXD_GelLaneStructure where _GelLane_key = 235076 and _Structure_key = 7112
insert into GXD_GelLaneStructure (_GelLane_key, _Structure_key) values(235076, 7109)
update GXD_GelLane set laneNote = "Expression analyzed in white fat adipocytes." where _GelLane_key = 235076
delete from GXD_GelLaneStructure where _GelLane_key = 235062 and _Structure_key = 7118
insert into GXD_GelLaneStructure (_GelLane_key, _Structure_key) values(235062, 7115)
update GXD_GelLane set laneNote = "Expression analyzed in brown fat adipocytes." where _GelLane_key = 235062
delete from GXD_GelLaneStructure where _GelLane_key = 235075 and _Structure_key = 7118
insert into GXD_GelLaneStructure (_GelLane_key, _Structure_key) values(235075, 7115)
update GXD_GelLane set laneNote = "Expression analyzed in brown fat adipocytes." where _GelLane_key = 235075
go

EOSQL
date | tee -a ${LOG}

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}
