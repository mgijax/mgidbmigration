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

delete from GXD_InSituResultStructure where _Result_key = 1237968 and _Structure_key = 7096
delete from GXD_InSituResultStructure where _Result_key = 1237971 and _Structure_key = 7054
delete from GXD_InSituResultStructure where _Result_key = 1238181 and _Structure_key = 7054
delete from GXD_InSituResultStructure where _Result_key = 1238273 and _Structure_key = 7096
delete from GXD_InSituResultStructure where _Result_key = 1238274 and _Structure_key = 7054
delete from GXD_InSituResultStructure where _Result_key = 1241515 and _Structure_key = 7054
delete from GXD_InSituResultStructure where _Result_key = 1242350 and _Structure_key = 7054
delete from GXD_InSituResultStructure where _Result_key = 1242381 and _Structure_key = 7054
delete from GXD_InSituResultStructure where _Result_key = 1243037 and _Structure_key = 7147
delete from GXD_InSituResultStructure where _Result_key = 1243040 and _Structure_key = 7147
delete from GXD_InSituResultStructure where _Result_key = 1245712 and _Structure_key = 7147
delete from GXD_InSituResultStructure where _Result_key = 1245713 and _Structure_key = 6942
delete from GXD_InSituResultStructure where _Result_key = 1250824 and _Structure_key = 7054
delete from GXD_InSituResultStructure where _Result_key = 1250911 and _Structure_key = 7054
delete from GXD_InSituResultStructure where _Result_key = 1251114 and _Structure_key = 7054
delete from GXD_InSituResultStructure where _Result_key = 1251171 and _Structure_key = 7054
delete from GXD_InSituResultStructure where _Result_key = 1251280 and _Structure_key = 7054
delete from GXD_InSituResultStructure where _Result_key = 1255973 and _Structure_key = 7096
delete from GXD_InSituResultStructure where _Result_key = 1255975 and _Structure_key = 7096
delete from GXD_InSituResultStructure where _Result_key = 1255981 and _Structure_key = 7094
delete from GXD_InSituResultStructure where _Result_key = 1255983 and _Structure_key = 7095
delete from GXD_InSituResultStructure where _Result_key = 1256041 and _Structure_key = 7095
delete from GXD_InSituResultStructure where _Result_key = 1256042 and _Structure_key = 7095
delete from GXD_InSituResultStructure where _Result_key = 1256055 and _Structure_key = 7094
delete from GXD_InSituResultStructure where _Result_key = 1256056 and _Structure_key = 7094
delete from GXD_InSituResultStructure where _Result_key = 1256060 and _Structure_key = 7094
delete from GXD_InSituResultStructure where _Result_key = 1256061 and _Structure_key = 7094
delete from GXD_InSituResultStructure where _Result_key = 1259723 and _Structure_key = 7094
delete from GXD_InSituResultStructure where _Result_key = 1259735 and _Structure_key = 7094
delete from GXD_InSituResultStructure where _Result_key = 1262302 and _Structure_key = 6940
delete from GXD_InSituResultStructure where _Result_key = 1262303 and _Structure_key = 6941
delete from GXD_InSituResultStructure where _Result_key = 1265976 and _Structure_key = 7054
delete from GXD_InSituResultStructure where _Result_key = 1266003 and _Structure_key = 7054
delete from GXD_InSituResultStructure where _Result_key = 1266240 and _Structure_key = 7094
delete from GXD_InSituResultStructure where _Result_key = 1266318 and _Structure_key = 7094
delete from GXD_InSituResultStructure where _Result_key = 1266433 and _Structure_key = 7054
delete from GXD_InSituResultStructure where _Result_key = 1266452 and _Structure_key = 7054
delete from GXD_InSituResultStructure where _Result_key = 1266984 and _Structure_key = 7054
delete from GXD_InSituResultStructure where _Result_key = 1267022 and _Structure_key = 7054
delete from GXD_InSituResultStructure where _Result_key = 1270467 and _Structure_key = 7147
delete from GXD_InSituResultStructure where _Result_key = 1270468 and _Structure_key = 7147
delete from GXD_InSituResultStructure where _Result_key = 1270529 and _Structure_key = 7147
delete from GXD_InSituResultStructure where _Result_key = 1270591 and _Structure_key = 7147
delete from GXD_InSituResultStructure where _Result_key = 1270593 and _Structure_key = 7147
delete from GXD_InSituResultStructure where _Result_key = 1270680 and _Structure_key = 7147
delete from GXD_InSituResultStructure where _Result_key = 1272421 and _Structure_key = 7094
delete from GXD_InSituResultStructure where _Result_key = 1273516 and _Structure_key = 7094
delete from GXD_InSituResultStructure where _Result_key = 1273517 and _Structure_key = 7094
delete from GXD_InSituResultStructure where _Result_key = 1273518 and _Structure_key = 7094
delete from GXD_InSituResultStructure where _Result_key = 1273520 and _Structure_key = 7094
delete from GXD_InSituResultStructure where _Result_key = 1273550 and _Structure_key = 7112
delete from GXD_InSituResultStructure where _Result_key = 1273840 and _Structure_key = 7118
delete from GXD_InSituResultStructure where _Result_key = 1273844 and _Structure_key = 7121
delete from GXD_InSituResultStructure where _Result_key = 1273845 and _Structure_key = 7121
delete from GXD_InSituResultStructure where _Result_key = 1273849 and _Structure_key = 7121
delete from GXD_InSituResultStructure where _Result_key = 1273854 and _Structure_key = 7118
delete from GXD_InSituResultStructure where _Result_key = 1273856 and _Structure_key = 7121
delete from GXD_InSituResultStructure where _Result_key = 1273858 and _Structure_key = 7121
delete from GXD_InSituResultStructure where _Result_key = 1273869 and _Structure_key = 7121
delete from GXD_InSituResultStructure where _Result_key = 1274735 and _Structure_key = 7054
delete from GXD_InSituResultStructure where _Result_key = 1274750 and _Structure_key = 7054
delete from GXD_InSituResultStructure where _Result_key = 1274822 and _Structure_key = 7054
delete from GXD_InSituResultStructure where _Result_key = 1275127 and _Structure_key = 7054
delete from GXD_InSituResultStructure where _Result_key = 1275403 and _Structure_key = 7054
delete from GXD_InSituResultStructure where _Result_key = 1275502 and _Structure_key = 7054
delete from GXD_InSituResultStructure where _Result_key = 1275579 and _Structure_key = 7054
delete from GXD_InSituResultStructure where _Result_key = 1277156 and _Structure_key = 7044
delete from GXD_InSituResultStructure where _Result_key = 1277157 and _Structure_key = 7051
delete from GXD_InSituResultStructure where _Result_key = 1277157 and _Structure_key = 7058
delete from GXD_InSituResultStructure where _Result_key = 1277158 and _Structure_key = 7059
delete from GXD_InSituResultStructure where _Result_key = 1277197 and _Structure_key = 7044
delete from GXD_InSituResultStructure where _Result_key = 1277199 and _Structure_key = 7044
delete from GXD_InSituResultStructure where _Result_key = 1277203 and _Structure_key = 7051
delete from GXD_InSituResultStructure where _Result_key = 1277203 and _Structure_key = 7058
delete from GXD_InSituResultStructure where _Result_key = 1277209 and _Structure_key = 7051
delete from GXD_InSituResultStructure where _Result_key = 1277209 and _Structure_key = 7058
delete from GXD_InSituResultStructure where _Result_key = 1277215 and _Structure_key = 7051
delete from GXD_InSituResultStructure where _Result_key = 1277215 and _Structure_key = 7058
delete from GXD_InSituResultStructure where _Result_key = 1277363 and _Structure_key = 7054
delete from GXD_InSituResultStructure where _Result_key = 1277419 and _Structure_key = 7054
delete from GXD_InSituResultStructure where _Result_key = 1277439 and _Structure_key = 7054
delete from GXD_InSituResultStructure where _Result_key = 1281136 and _Structure_key = 7147
delete from GXD_InSituResultStructure where _Result_key = 1281147 and _Structure_key = 7147
delete from GXD_InSituResultStructure where _Result_key = 1281150 and _Structure_key = 6942
delete from GXD_InSituResultStructure where _Result_key = 1281151 and _Structure_key = 6942
delete from GXD_InSituResultStructure where _Result_key = 1281152 and _Structure_key = 6940
delete from GXD_InSituResultStructure where _Result_key = 1281153 and _Structure_key = 6940
delete from GXD_InSituResultStructure where _Result_key = 1281182 and _Structure_key = 6942
delete from GXD_InSituResultStructure where _Result_key = 1281684 and _Structure_key = 7054
delete from GXD_InSituResultStructure where _Result_key = 133893 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 139284 and _Structure_key = 7096
delete from GXD_InSituResultStructure where _Result_key = 139295 and _Structure_key = 7096
delete from GXD_InSituResultStructure where _Result_key = 139320 and _Structure_key = 7096
delete from GXD_InSituResultStructure where _Result_key = 22438 and _Structure_key = 7048
delete from GXD_InSituResultStructure where _Result_key = 22439 and _Structure_key = 7049
delete from GXD_InSituResultStructure where _Result_key = 22439 and _Structure_key = 7051
delete from GXD_InSituResultStructure where _Result_key = 22439 and _Structure_key = 7059
delete from GXD_InSituResultStructure where _Result_key = 226623 and _Structure_key = 6941
delete from GXD_InSituResultStructure where _Result_key = 230863 and _Structure_key = 7096
delete from GXD_InSituResultStructure where _Result_key = 231019 and _Structure_key = 7096
delete from GXD_InSituResultStructure where _Result_key = 231021 and _Structure_key = 7058
delete from GXD_InSituResultStructure where _Result_key = 231022 and _Structure_key = 7059
delete from GXD_InSituResultStructure where _Result_key = 231062 and _Structure_key = 7054
delete from GXD_InSituResultStructure where _Result_key = 236879 and _Structure_key = 6942
delete from GXD_InSituResultStructure where _Result_key = 236880 and _Structure_key = 6941
delete from GXD_InSituResultStructure where _Result_key = 236884 and _Structure_key = 6942
delete from GXD_InSituResultStructure where _Result_key = 236894 and _Structure_key = 7147
delete from GXD_InSituResultStructure where _Result_key = 236895 and _Structure_key = 6942
delete from GXD_InSituResultStructure where _Result_key = 236895 and _Structure_key = 7147
delete from GXD_InSituResultStructure where _Result_key = 238353 and _Structure_key = 6942
delete from GXD_InSituResultStructure where _Result_key = 238354 and _Structure_key = 7147
delete from GXD_InSituResultStructure where _Result_key = 238356 and _Structure_key = 6942
delete from GXD_InSituResultStructure where _Result_key = 238410 and _Structure_key = 7147
delete from GXD_InSituResultStructure where _Result_key = 238411 and _Structure_key = 6942
delete from GXD_InSituResultStructure where _Result_key = 239923 and _Structure_key = 7095
delete from GXD_InSituResultStructure where _Result_key = 240028 and _Structure_key = 7147
delete from GXD_InSituResultStructure where _Result_key = 240031 and _Structure_key = 7147
delete from GXD_InSituResultStructure where _Result_key = 240788 and _Structure_key = 7147
delete from GXD_InSituResultStructure where _Result_key = 240789 and _Structure_key = 7147
delete from GXD_InSituResultStructure where _Result_key = 240790 and _Structure_key = 6941
delete from GXD_InSituResultStructure where _Result_key = 240790 and _Structure_key = 6942
delete from GXD_InSituResultStructure where _Result_key = 240792 and _Structure_key = 6940
delete from GXD_InSituResultStructure where _Result_key = 240850 and _Structure_key = 7121
delete from GXD_InSituResultStructure where _Result_key = 241959 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 247214 and _Structure_key = 7147
delete from GXD_InSituResultStructure where _Result_key = 247216 and _Structure_key = 7147
delete from GXD_InSituResultStructure where _Result_key = 248098 and _Structure_key = 7094
delete from GXD_InSituResultStructure where _Result_key = 248100 and _Structure_key = 7096
delete from GXD_InSituResultStructure where _Result_key = 248101 and _Structure_key = 7094
delete from GXD_InSituResultStructure where _Result_key = 248104 and _Structure_key = 7096
delete from GXD_InSituResultStructure where _Result_key = 248106 and _Structure_key = 7096
delete from GXD_InSituResultStructure where _Result_key = 248775 and _Structure_key = 7094
delete from GXD_InSituResultStructure where _Result_key = 248778 and _Structure_key = 7094
delete from GXD_InSituResultStructure where _Result_key = 248779 and _Structure_key = 7094
delete from GXD_InSituResultStructure where _Result_key = 248780 and _Structure_key = 7095
delete from GXD_InSituResultStructure where _Result_key = 248783 and _Structure_key = 7095
delete from GXD_InSituResultStructure where _Result_key = 249109 and _Structure_key = 7054
delete from GXD_InSituResultStructure where _Result_key = 249130 and _Structure_key = 7054
delete from GXD_InSituResultStructure where _Result_key = 249133 and _Structure_key = 6942
delete from GXD_InSituResultStructure where _Result_key = 249134 and _Structure_key = 7147
delete from GXD_InSituResultStructure where _Result_key = 249136 and _Structure_key = 6942
delete from GXD_InSituResultStructure where _Result_key = 249149 and _Structure_key = 6942
delete from GXD_InSituResultStructure where _Result_key = 249149 and _Structure_key = 7054
delete from GXD_InSituResultStructure where _Result_key = 249149 and _Structure_key = 7147
delete from GXD_InSituResultStructure where _Result_key = 249154 and _Structure_key = 6942
delete from GXD_InSituResultStructure where _Result_key = 249154 and _Structure_key = 7054
delete from GXD_InSituResultStructure where _Result_key = 249154 and _Structure_key = 7147
delete from GXD_InSituResultStructure where _Result_key = 249159 and _Structure_key = 6942
delete from GXD_InSituResultStructure where _Result_key = 249159 and _Structure_key = 7054
delete from GXD_InSituResultStructure where _Result_key = 249159 and _Structure_key = 7147
delete from GXD_InSituResultStructure where _Result_key = 249164 and _Structure_key = 6942
delete from GXD_InSituResultStructure where _Result_key = 249164 and _Structure_key = 7054
delete from GXD_InSituResultStructure where _Result_key = 249164 and _Structure_key = 7147
delete from GXD_InSituResultStructure where _Result_key = 249437 and _Structure_key = 7058
delete from GXD_InSituResultStructure where _Result_key = 249439 and _Structure_key = 7058
delete from GXD_InSituResultStructure where _Result_key = 249445 and _Structure_key = 7058
delete from GXD_InSituResultStructure where _Result_key = 251105 and _Structure_key = 7096
delete from GXD_InSituResultStructure where _Result_key = 251109 and _Structure_key = 7095
delete from GXD_InSituResultStructure where _Result_key = 251110 and _Structure_key = 7094
delete from GXD_InSituResultStructure where _Result_key = 251203 and _Structure_key = 7095
delete from GXD_InSituResultStructure where _Result_key = 251204 and _Structure_key = 7094
delete from GXD_InSituResultStructure where _Result_key = 261686 and _Structure_key = 7094
delete from GXD_InSituResultStructure where _Result_key = 261688 and _Structure_key = 7094
delete from GXD_InSituResultStructure where _Result_key = 261689 and _Structure_key = 7096
delete from GXD_InSituResultStructure where _Result_key = 261952 and _Structure_key = 7096
delete from GXD_InSituResultStructure where _Result_key = 262909 and _Structure_key = 7096
delete from GXD_InSituResultStructure where _Result_key = 262910 and _Structure_key = 7094
delete from GXD_InSituResultStructure where _Result_key = 262914 and _Structure_key = 7096
delete from GXD_InSituResultStructure where _Result_key = 262915 and _Structure_key = 7096
delete from GXD_InSituResultStructure where _Result_key = 264384 and _Structure_key = 7147
delete from GXD_InSituResultStructure where _Result_key = 264386 and _Structure_key = 7147
delete from GXD_InSituResultStructure where _Result_key = 264568 and _Structure_key = 6940
delete from GXD_InSituResultStructure where _Result_key = 264569 and _Structure_key = 6942
delete from GXD_InSituResultStructure where _Result_key = 264571 and _Structure_key = 6940
delete from GXD_InSituResultStructure where _Result_key = 264572 and _Structure_key = 6942
delete from GXD_InSituResultStructure where _Result_key = 264579 and _Structure_key = 7147
delete from GXD_InSituResultStructure where _Result_key = 264587 and _Structure_key = 6940
delete from GXD_InSituResultStructure where _Result_key = 264588 and _Structure_key = 6942
delete from GXD_InSituResultStructure where _Result_key = 264594 and _Structure_key = 7147
delete from GXD_InSituResultStructure where _Result_key = 264596 and _Structure_key = 7147
delete from GXD_InSituResultStructure where _Result_key = 264598 and _Structure_key = 6942
delete from GXD_InSituResultStructure where _Result_key = 264600 and _Structure_key = 7147
delete from GXD_InSituResultStructure where _Result_key = 264602 and _Structure_key = 6942
delete from GXD_InSituResultStructure where _Result_key = 264604 and _Structure_key = 7147
delete from GXD_InSituResultStructure where _Result_key = 264661 and _Structure_key = 6940
delete from GXD_InSituResultStructure where _Result_key = 264661 and _Structure_key = 6942
delete from GXD_InSituResultStructure where _Result_key = 264663 and _Structure_key = 6940
delete from GXD_InSituResultStructure where _Result_key = 264663 and _Structure_key = 6942
delete from GXD_InSituResultStructure where _Result_key = 264665 and _Structure_key = 6940
delete from GXD_InSituResultStructure where _Result_key = 264665 and _Structure_key = 6942
delete from GXD_InSituResultStructure where _Result_key = 264666 and _Structure_key = 6940
delete from GXD_InSituResultStructure where _Result_key = 264666 and _Structure_key = 6942
delete from GXD_InSituResultStructure where _Result_key = 265424 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 266738 and _Structure_key = 9169
delete from GXD_InSituResultStructure where _Result_key = 266743 and _Structure_key = 9169
delete from GXD_InSituResultStructure where _Result_key = 268028 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 268032 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 268042 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 269344 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 269349 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 269355 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 269362 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 269370 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 269377 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 269407 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 269418 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 269424 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 269427 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 269813 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 269814 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 270348 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 270354 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 270362 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 270368 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 270400 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 270405 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 270407 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 270414 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 270417 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 270424 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 270445 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 270454 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 270459 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 270469 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 270475 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 270483 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 270489 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 270497 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 270514 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 270525 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 270531 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 270534 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 270645 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 270657 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 270674 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 270699 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 270760 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 270770 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 270787 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 270804 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 270821 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 270829 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 270930 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 270932 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 270933 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 270937 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 270954 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 270955 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 270959 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 270960 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 270963 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 270965 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 273480 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 273488 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 273592 and _Structure_key = 9169
delete from GXD_InSituResultStructure where _Result_key = 273593 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 273804 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 274822 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 274825 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 277710 and _Structure_key = 9169
delete from GXD_InSituResultStructure where _Result_key = 277713 and _Structure_key = 9169
delete from GXD_InSituResultStructure where _Result_key = 277718 and _Structure_key = 9169
delete from GXD_InSituResultStructure where _Result_key = 278076 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 278082 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 278088 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 278662 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 278666 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 278716 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 278720 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 281094 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 281098 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 282917 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 282965 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 284347 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 284399 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 284415 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 284727 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 284733 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 285042 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 285061 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 285082 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 288561 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 288567 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 288751 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 288761 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 288772 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 294879 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 294892 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 305033 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 305040 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 305048 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 308493 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 308581 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 308991 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 308999 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 309021 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 309292 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 309307 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 309861 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 309869 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 309880 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 309935 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 309943 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 309958 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 310547 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 311530 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 314156 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 314167 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 314490 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 314496 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 315462 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 315912 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 315924 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 316541 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 316551 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 317180 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 317193 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 317206 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 318256 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 318790 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 319651 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 319661 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 320979 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 320986 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 323553 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 323574 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 324682 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 324692 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 326364 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 326370 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 328484 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 328494 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 329089 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 329099 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 329109 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 329438 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 329449 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 329643 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 330220 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 330226 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 333134 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 333329 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 333341 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 333562 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 333565 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 333637 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 333647 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 336628 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 336634 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 336642 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 338134 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 338139 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 341004 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 341018 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 341033 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 344188 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 344656 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 344662 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 344667 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 346083 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 346091 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 346099 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 346263 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 346398 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 346406 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 347270 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 347295 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 347625 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 347628 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 347631 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 348265 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 348274 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 348282 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 348482 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 348494 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 348506 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 349185 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 349192 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 349198 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 350301 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 350304 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 350309 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 350570 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 350578 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 350746 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 350762 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 350776 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 350920 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 350928 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 351331 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 351334 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 351337 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 354556 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 354562 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 355175 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 355192 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 355212 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 355229 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 355350 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 355354 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 357160 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 357171 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 357184 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 359750 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 359755 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 360924 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 360930 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 361483 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 361502 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 364041 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 364047 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 364344 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 364353 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 364742 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 364760 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 365547 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 365563 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 365706 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 365713 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 365723 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 365989 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 366002 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 366014 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 366841 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 369517 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 369527 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 369652 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 369654 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 369656 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 370025 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 370033 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 370612 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 370620 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 370627 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 372301 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 372310 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 374436 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 374457 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 374479 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 374500 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 374736 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 374744 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 375061 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 375076 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 375090 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 375238 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 375249 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 375548 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 375566 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 376657 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 376662 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 377336 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 377343 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 378642 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 378647 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 378652 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 379770 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 379782 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 381669 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 381677 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 381684 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 381749 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 381757 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 381763 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 382352 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 382360 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 382685 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 382697 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 382709 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 382914 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 382924 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 383541 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 383545 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 384220 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 384233 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 384245 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 384710 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 385432 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 385438 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 385649 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 385667 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 386012 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 386021 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 386528 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 388668 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 388686 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 389569 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 389579 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 390031 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 391477 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 391483 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 392316 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 392334 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 392350 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 393610 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 393617 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 393628 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 395688 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 400087 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 400102 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 400114 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 400870 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 400879 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 408868 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 408880 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 409830 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 409833 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 414751 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 414764 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 414899 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 414907 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 414915 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 415362 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 415382 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 415632 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 415642 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 416152 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 416158 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 416165 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 416170 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 416175 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 419616 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 419625 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 419633 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 419900 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 419924 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 419945 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 420453 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 421510 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 421520 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 421530 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 421542 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 421752 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 421764 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 421776 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 422475 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 422488 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 422499 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 422817 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 422824 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 424669 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 424675 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 424820 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 424825 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 425189 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 425204 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 425607 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 425623 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 425643 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 428921 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 428937 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 434351 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 439029 and _Structure_key = 9169
delete from GXD_InSituResultStructure where _Result_key = 439039 and _Structure_key = 9169
delete from GXD_InSituResultStructure where _Result_key = 439054 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 439061 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 439144 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 439146 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 439147 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 440046 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 440055 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 440420 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 440432 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 443366 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 443368 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 443370 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 443373 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 443993 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 447084 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 447357 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 447368 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 447381 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 447762 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 447771 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 447994 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 447997 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 448704 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 448711 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 450896 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 450913 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 451235 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 451256 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 451278 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 451299 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 451688 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 451689 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 453188 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 453203 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 454483 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 455118 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 455122 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 457323 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 457329 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 457334 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 457756 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 457770 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 461254 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 461268 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 462443 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 462464 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 464245 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 464255 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 465080 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 465086 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 465282 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 465290 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 465563 and _Structure_key = 9169
delete from GXD_InSituResultStructure where _Result_key = 465571 and _Structure_key = 9169
delete from GXD_InSituResultStructure where _Result_key = 465618 and _Structure_key = 9169
delete from GXD_InSituResultStructure where _Result_key = 465628 and _Structure_key = 9169
delete from GXD_InSituResultStructure where _Result_key = 466469 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 466489 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 469782 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 469792 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 470329 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 470337 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 470344 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 470811 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 470821 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 470829 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 470841 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 472423 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 473926 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 473931 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 473938 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 474084 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 474093 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 474489 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 474504 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 477473 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 477481 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 477486 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 478207 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 478217 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 478228 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 478527 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 478542 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 478561 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 478671 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 478675 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 478679 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 478683 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 478708 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 478712 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 478716 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 478720 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 478723 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 480359 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 480371 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 480383 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 482077 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 482094 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 482376 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 482398 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 482419 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 483299 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 485362 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 485588 and _Structure_key = 9169
delete from GXD_InSituResultStructure where _Result_key = 485594 and _Structure_key = 9169
delete from GXD_InSituResultStructure where _Result_key = 485601 and _Structure_key = 9169
delete from GXD_InSituResultStructure where _Result_key = 485608 and _Structure_key = 9169
delete from GXD_InSituResultStructure where _Result_key = 485613 and _Structure_key = 9169
delete from GXD_InSituResultStructure where _Result_key = 485638 and _Structure_key = 9169
delete from GXD_InSituResultStructure where _Result_key = 485643 and _Structure_key = 9169
delete from GXD_InSituResultStructure where _Result_key = 485648 and _Structure_key = 9169
delete from GXD_InSituResultStructure where _Result_key = 485653 and _Structure_key = 9169
delete from GXD_InSituResultStructure where _Result_key = 485657 and _Structure_key = 9169
delete from GXD_InSituResultStructure where _Result_key = 486433 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 486442 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 486450 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 486715 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 486728 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 486742 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 487479 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 487486 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 487493 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 487584 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 487592 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 491095 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 491099 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 491108 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 492006 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 492022 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 492412 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 492420 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 492533 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 492537 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 492641 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 492645 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 495778 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 495995 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 496010 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 497569 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 497573 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 502032 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 506985 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 510004 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 511360 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 511367 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 512082 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 512094 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 513146 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 513152 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 514233 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 514242 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 516665 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 516675 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 516687 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 518153 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 518158 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 518226 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 518229 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 518233 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 518592 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 518600 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 518606 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 519016 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 519021 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 519025 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 519081 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 519087 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 519093 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 519347 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 519356 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 519362 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 520234 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 520239 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 520240 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 520252 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 520254 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 520257 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 523076 and _Structure_key = 9169
delete from GXD_InSituResultStructure where _Result_key = 523077 and _Structure_key = 9169
delete from GXD_InSituResultStructure where _Result_key = 523078 and _Structure_key = 9169
delete from GXD_InSituResultStructure where _Result_key = 523079 and _Structure_key = 9169
delete from GXD_InSituResultStructure where _Result_key = 523080 and _Structure_key = 9169
delete from GXD_InSituResultStructure where _Result_key = 523581 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 523587 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 524671 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 534254 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 534259 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 534266 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 534312 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 534319 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 534326 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 534331 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 534463 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 534476 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 534817 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 536272 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 536290 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 537093 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 537109 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 537126 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 543311 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 544718 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 544724 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 546103 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 546137 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 547203 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 547210 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 552397 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 552404 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 554133 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 554141 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 555954 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 568529 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 568538 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 571095 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 571106 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 571117 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 571330 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 571335 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 571338 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 575388 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 581474 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 582206 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 582218 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 583399 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 583401 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 588634 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 588714 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 588904 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 588907 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 589347 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 589357 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 589364 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 590132 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 590140 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 591537 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 591543 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 591548 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 592459 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 592470 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 592482 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 592739 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 593194 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 593204 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 593774 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 593776 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 595255 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 595271 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 595284 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 597280 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 599500 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 599511 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 599520 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 600046 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 600061 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 600072 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 600275 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 600295 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 600309 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 600508 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 600528 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 600873 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 601413 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 601421 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 601650 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 601657 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 603231 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 603236 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 606225 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 607143 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 607155 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 607167 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 607179 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 607194 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 607207 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 607220 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 607233 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 607245 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 607258 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 607271 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 607284 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 607758 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 607772 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 608920 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 608930 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 610109 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 610115 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 610120 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 610125 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 610128 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 610130 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 610138 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 610142 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 610147 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 610151 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 610155 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 610158 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 610411 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 610413 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 610414 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 610415 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 614783 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 614787 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 615388 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 615407 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 615424 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 615598 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 615607 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 616372 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 616378 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 616383 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 616670 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 616674 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 617192 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 617202 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 617747 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 617762 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 617779 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 620323 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 620324 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 620325 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 620326 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 620327 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 625207 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 625210 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 626815 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 626827 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 626834 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 626940 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 626949 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 627240 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 627241 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 627242 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 627243 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 627354 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 627364 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 629133 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 629135 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 629136 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 629138 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 629172 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 629179 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 629346 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 629352 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 633886 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 633899 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 634084 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 637991 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 641891 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 641899 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 642146 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 642981 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 642993 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 643005 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 643019 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 644855 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 644864 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 651061 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 651065 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 654598 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 654620 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 654642 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 655974 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 655979 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 655986 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 656226 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 656240 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 656251 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 656310 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 656321 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 656332 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 656341 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 656573 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 656581 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 657554 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 657563 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 658864 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 658865 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 660853 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 661519 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 661526 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 661534 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 661539 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 661566 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 661575 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 661583 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 661590 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 661635 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 661642 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 662244 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 662253 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 662262 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 662271 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 662321 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 662330 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 662339 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 662348 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 662358 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 662653 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 662666 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 662683 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 662700 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 662715 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 662765 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 662781 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 662789 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 662796 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 662800 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 663225 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 663228 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 663230 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 663456 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 663459 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 663463 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 663468 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 663506 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 663512 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 663520 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 663525 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 663529 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 664314 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 664318 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 664337 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 666957 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 666958 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 669006 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 669022 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 669036 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 669912 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 669919 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 670684 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 670686 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 670693 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 670697 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 670701 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 670703 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 671856 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 675524 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 675574 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 675581 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 678090 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 679970 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 681985 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 681986 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 681987 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 683995 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 684011 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 685247 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 685251 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 685786 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 685795 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 685798 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 686238 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 686240 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 686242 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 686507 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 686511 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 686517 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 686613 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 686629 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 687001 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 687003 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 689339 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 689352 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 689478 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 689494 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 690149 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 690166 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 690515 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 693428 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 693430 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 693432 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 693435 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 693438 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 693457 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 693464 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 693467 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 693469 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 694558 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 694582 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 696053 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 696946 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 696949 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 696954 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 696958 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 696986 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 696990 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 696994 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 696996 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 696998 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 697000 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 699140 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 699937 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 700293 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 700302 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 700308 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 701423 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 701432 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 701443 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 701492 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 701502 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 701512 and _Structure_key = 9173
delete from GXD_InSituResultStructure where _Result_key = 710732 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 710745 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 714120 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 714137 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 714152 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 716357 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 716359 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 717592 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 717598 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 718213 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 718217 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 718220 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 718416 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 718417 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 722070 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 722081 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 722090 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 722559 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 722570 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 723401 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 723409 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 723416 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 723876 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 723889 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 725741 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 725745 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 727001 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 727011 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 727021 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 727470 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 727478 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 728788 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 728800 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 732458 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 732474 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 734648 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 734649 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 734650 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 734651 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 736944 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 736953 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 741841 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 741845 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 741901 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 741908 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 742840 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 742854 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 742868 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 743280 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 743291 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 743302 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 743312 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 744046 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 744053 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 744060 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 744068 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 744078 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 744550 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 744560 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 744569 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 744980 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 744987 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 744993 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 745347 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 746216 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 747034 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 747036 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 747564 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 747572 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 747578 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 747586 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 747938 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 747946 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 747955 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 748237 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 748258 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 748389 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 748391 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 748947 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 748951 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 749204 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 749214 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 750037 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 750051 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 750719 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 750723 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 751661 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 751669 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 751719 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 751721 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 752846 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 752856 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 753166 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 753178 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 755057 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 755062 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 755139 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 755144 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 755476 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 755484 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 755543 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 755548 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 755552 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 755986 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 755991 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 755995 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 756931 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 756935 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 757896 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 757911 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 757923 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 757938 and _Structure_key = 9638
delete from GXD_InSituResultStructure where _Result_key = 759166 and _Structure_key = 7147
delete from GXD_InSituResultStructure where _Result_key = 759239 and _Structure_key = 6942
delete from GXD_InSituResultStructure where _Result_key = 759240 and _Structure_key = 6941
delete from GXD_InSituResultStructure where _Result_key = 759241 and _Structure_key = 6942
delete from GXD_InSituResultStructure where _Result_key = 759243 and _Structure_key = 7147
delete from GXD_InSituResultStructure where _Result_key = 759244 and _Structure_key = 6942
delete from GXD_InSituResultStructure where _Result_key = 759244 and _Structure_key = 7147
delete from GXD_InSituResultStructure where _Result_key = 759256 and _Structure_key = 7054
delete from GXD_InSituResultStructure where _Result_key = 759257 and _Structure_key = 7054
delete from GXD_InSituResultStructure where _Result_key = 763696 and _Structure_key = 6942
delete from GXD_InSituResultStructure where _Result_key = 763837 and _Structure_key = 7147
delete from GXD_InSituResultStructure where _Result_key = 763838 and _Structure_key = 7147
delete from GXD_InSituResultStructure where _Result_key = 763841 and _Structure_key = 7147
delete from GXD_InSituResultStructure where _Result_key = 763843 and _Structure_key = 7147
delete from GXD_InSituResultStructure where _Result_key = 763847 and _Structure_key = 7147
delete from GXD_InSituResultStructure where _Result_key = 763848 and _Structure_key = 7147
delete from GXD_InSituResultStructure where _Result_key = 763998 and _Structure_key = 6941
delete from GXD_InSituResultStructure where _Result_key = 763999 and _Structure_key = 6941
delete from GXD_InSituResultStructure where _Result_key = 764000 and _Structure_key = 7147
delete from GXD_InSituResultStructure where _Result_key = 764001 and _Structure_key = 6941
delete from GXD_InSituResultStructure where _Result_key = 764002 and _Structure_key = 6941
delete from GXD_InSituResultStructure where _Result_key = 764003 and _Structure_key = 7147
delete from GXD_InSituResultStructure where _Result_key = 764004 and _Structure_key = 6941
delete from GXD_InSituResultStructure where _Result_key = 764005 and _Structure_key = 7147
delete from GXD_InSituResultStructure where _Result_key = 764006 and _Structure_key = 6941
delete from GXD_InSituResultStructure where _Result_key = 764007 and _Structure_key = 6941
delete from GXD_InSituResultStructure where _Result_key = 764009 and _Structure_key = 6941
delete from GXD_InSituResultStructure where _Result_key = 764045 and _Structure_key = 7147
delete from GXD_InSituResultStructure where _Result_key = 764047 and _Structure_key = 7147
delete from GXD_InSituResultStructure where _Result_key = 764049 and _Structure_key = 7147
delete from GXD_InSituResultStructure where _Result_key = 764051 and _Structure_key = 7147
delete from GXD_InSituResultStructure where _Result_key = 764053 and _Structure_key = 7147
delete from GXD_InSituResultStructure where _Result_key = 764055 and _Structure_key = 7147
delete from GXD_InSituResultStructure where _Result_key = 764057 and _Structure_key = 7147
delete from GXD_InSituResultStructure where _Result_key = 764062 and _Structure_key = 7147
delete from GXD_InSituResultStructure where _Result_key = 764064 and _Structure_key = 7147
delete from GXD_InSituResultStructure where _Result_key = 764068 and _Structure_key = 7147
delete from GXD_InSituResultStructure where _Result_key = 764070 and _Structure_key = 7147
delete from GXD_InSituResultStructure where _Result_key = 764099 and _Structure_key = 7094
delete from GXD_InSituResultStructure where _Result_key = 764100 and _Structure_key = 7095
delete from GXD_InSituResultStructure where _Result_key = 764168 and _Structure_key = 7094
delete from GXD_InSituResultStructure where _Result_key = 764171 and _Structure_key = 7094
delete from GXD_InSituResultStructure where _Result_key = 764174 and _Structure_key = 7095
delete from GXD_InSituResultStructure where _Result_key = 764180 and _Structure_key = 7096
delete from GXD_InSituResultStructure where _Result_key = 764190 and _Structure_key = 7096
delete from GXD_InSituResultStructure where _Result_key = 764197 and _Structure_key = 7094
delete from GXD_InSituResultStructure where _Result_key = 764201 and _Structure_key = 7094
delete from GXD_InSituResultStructure where _Result_key = 764202 and _Structure_key = 7094
delete from GXD_InSituResultStructure where _Result_key = 772902 and _Structure_key = 7078
delete from GXD_InSituResultStructure where _Result_key = 772908 and _Structure_key = 7078
delete from GXD_InSituResultStructure where _Result_key = 772943 and _Structure_key = 6941
delete from GXD_InSituResultStructure where _Result_key = 772944 and _Structure_key = 6941
delete from GXD_InSituResultStructure where _Result_key = 773591 and _Structure_key = 7096
delete from GXD_InSituResultStructure where _Result_key = 773592 and _Structure_key = 7094
delete from GXD_InSituResultStructure where _Result_key = 777778 and _Structure_key = 7054
delete from GXD_InSituResultStructure where _Result_key = 777781 and _Structure_key = 7059
delete from GXD_InSituResultStructure where _Result_key = 777783 and _Structure_key = 7059
delete from GXD_InSituResultStructure where _Result_key = 778634 and _Structure_key = 7057
delete from GXD_InSituResultStructure where _Result_key = 778636 and _Structure_key = 7057
delete from GXD_InSituResultStructure where _Result_key = 778638 and _Structure_key = 7057
delete from GXD_InSituResultStructure where _Result_key = 779944 and _Structure_key = 7147
delete from GXD_InSituResultStructure where _Result_key = 780093 and _Structure_key = 6940
delete from GXD_InSituResultStructure where _Result_key = 780096 and _Structure_key = 6940
delete from GXD_InSituResultStructure where _Result_key = 780097 and _Structure_key = 6940
delete from GXD_InSituResultStructure where _Result_key = 834711 and _Structure_key = 7058
delete from GXD_InSituResultStructure where _Result_key = 836070 and _Structure_key = 6942
delete from GXD_InSituResultStructure where _Result_key = 836072 and _Structure_key = 6942
delete from GXD_InSituResultStructure where _Result_key = 836524 and _Structure_key = 7068
delete from GXD_InSituResultStructure where _Result_key = 836952 and _Structure_key = 7078
delete from GXD_InSituResultStructure where _Result_key = 837524 and _Structure_key = 7096
delete from GXD_InSituResultStructure where _Result_key = 837527 and _Structure_key = 7096
delete from GXD_InSituResultStructure where _Result_key = 837789 and _Structure_key = 7147
delete from GXD_InSituResultStructure where _Result_key = 838324 and _Structure_key = 6941
delete from GXD_InSituResultStructure where _Result_key = 838325 and _Structure_key = 6941
delete from GXD_InSituResultStructure where _Result_key = 838326 and _Structure_key = 6940
delete from GXD_InSituResultStructure where _Result_key = 838326 and _Structure_key = 6942
delete from GXD_InSituResultStructure where _Result_key = 838601 and _Structure_key = 7094
delete from GXD_InSituResultStructure where _Result_key = 838602 and _Structure_key = 7094
delete from GXD_InSituResultStructure where _Result_key = 838603 and _Structure_key = 7094
delete from GXD_InSituResultStructure where _Result_key = 838604 and _Structure_key = 7094
delete from GXD_InSituResultStructure where _Result_key = 838605 and _Structure_key = 7094
delete from GXD_InSituResultStructure where _Result_key = 838606 and _Structure_key = 7094
delete from GXD_InSituResultStructure where _Result_key = 838607 and _Structure_key = 7094
delete from GXD_InSituResultStructure where _Result_key = 838611 and _Structure_key = 7094
delete from GXD_InSituResultStructure where _Result_key = 838614 and _Structure_key = 7096
delete from GXD_InSituResultStructure where _Result_key = 838720 and _Structure_key = 7147
delete from GXD_InSituResultStructure where _Result_key = 838734 and _Structure_key = 7147
delete from GXD_InSituResultStructure where _Result_key = 838771 and _Structure_key = 7147
delete from GXD_InSituResultStructure where _Result_key = 932406 and _Structure_key = 7096
delete from GXD_InSituResultStructure where _Result_key = 932409 and _Structure_key = 7096
delete from GXD_InSituResultStructure where _Result_key = 932900 and _Structure_key = 7095
delete from GXD_InSituResultStructure where _Result_key = 932902 and _Structure_key = 7094
delete from GXD_InSituResultStructure where _Result_key = 933260 and _Structure_key = 7095
delete from GXD_InSituResultStructure where _Result_key = 933262 and _Structure_key = 7094
delete from GXD_InSituResultStructure where _Result_key = 934005 and _Structure_key = 7054
delete from GXD_InSituResultStructure where _Result_key = 934006 and _Structure_key = 7054
delete from GXD_InSituResultStructure where _Result_key = 934014 and _Structure_key = 7058
delete from GXD_InSituResultStructure where _Result_key = 935580 and _Structure_key = 7047
delete from GXD_InSituResultStructure where _Result_key = 938107 and _Structure_key = 7058
delete from GXD_InSituResultStructure where _Result_key = 938108 and _Structure_key = 7058
delete from GXD_InSituResultStructure where _Result_key = 938115 and _Structure_key = 7058
delete from GXD_InSituResultStructure where _Result_key = 938116 and _Structure_key = 7058
delete from GXD_InSituResultStructure where _Result_key = 938117 and _Structure_key = 7058
delete from GXD_InSituResultStructure where _Result_key = 938124 and _Structure_key = 7058
delete from GXD_InSituResultStructure where _Result_key = 938130 and _Structure_key = 7058
delete from GXD_InSituResultStructure where _Result_key = 938131 and _Structure_key = 7058
delete from GXD_InSituResultStructure where _Result_key = 938154 and _Structure_key = 7058
delete from GXD_InSituResultStructure where _Result_key = 938155 and _Structure_key = 7058
delete from GXD_InSituResultStructure where _Result_key = 938156 and _Structure_key = 7058
delete from GXD_InSituResultStructure where _Result_key = 938163 and _Structure_key = 7058
delete from GXD_InSituResultStructure where _Result_key = 938169 and _Structure_key = 7058
delete from GXD_InSituResultStructure where _Result_key = 938170 and _Structure_key = 7058
delete from GXD_InSituResultStructure where _Result_key = 938246 and _Structure_key = 7058
delete from GXD_InSituResultStructure where _Result_key = 938247 and _Structure_key = 7058
delete from GXD_InSituResultStructure where _Result_key = 938657 and _Structure_key = 7054
delete from GXD_InSituResultStructure where _Result_key = 938703 and _Structure_key = 7054
delete from GXD_InSituResultStructure where _Result_key = 938907 and _Structure_key = 7054
delete from GXD_InSituResultStructure where _Result_key = 939304 and _Structure_key = 7054
delete from GXD_InSituResultStructure where _Result_key = 939537 and _Structure_key = 7054
delete from GXD_InSituResultStructure where _Result_key = 939769 and _Structure_key = 7054
delete from GXD_InSituResultStructure where _Result_key = 940157 and _Structure_key = 7054
delete from GXD_InSituResultStructure where _Result_key = 940554 and _Structure_key = 7054
delete from GXD_InSituResultStructure where _Result_key = 940619 and _Structure_key = 7054
delete from GXD_InSituResultStructure where _Result_key = 940765 and _Structure_key = 7054
delete from GXD_InSituResultStructure where _Result_key = 940767 and _Structure_key = 7054
delete from GXD_InSituResultStructure where _Result_key = 941012 and _Structure_key = 7054
delete from GXD_InSituResultStructure where _Result_key = 941210 and _Structure_key = 7054
delete from GXD_InSituResultStructure where _Result_key = 945116 and _Structure_key = 6940
delete from GXD_InSituResultStructure where _Result_key = 945124 and _Structure_key = 6940
delete from GXD_InSituResultStructure where _Result_key = 946687 and _Structure_key = 7054
delete from GXD_InSituResultStructure where _Result_key = 946688 and _Structure_key = 7054
delete from GXD_InSituResultStructure where _Result_key = 946689 and _Structure_key = 7055
delete from GXD_InSituResultStructure where _Result_key = 947503 and _Structure_key = 7096
delete from GXD_InSituResultStructure where _Result_key = 949620 and _Structure_key = 7054
delete from GXD_InSituResultStructure where _Result_key = 949657 and _Structure_key = 7054
delete from GXD_InSituResultStructure where _Result_key = 949883 and _Structure_key = 7054
delete from GXD_InSituResultStructure where _Result_key = 949977 and _Structure_key = 7054
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1237968, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1237971, 6943)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1238181, 6943)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1238273, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1238274, 6943)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1241515, 6943)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1242350, 6943)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1242381, 6943)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1243037, 7149)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1243040, 7149)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1245712, 7149)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1245713, 6939)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1250824, 6943)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1250911, 6943)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1251114, 6943)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1251171, 6943)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1251280, 6943)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1255973, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1255975, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1255981, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1255983, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1256041, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1256042, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1256055, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1256056, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1256060, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1256061, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1259723, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1259735, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1262302, 6939)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1262303, 6939)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1265976, 6943)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1266003, 6943)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1266240, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1266318, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1266433, 6943)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1266452, 6943)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1266984, 6943)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1267022, 6943)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1270467, 7149)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1270468, 7149)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1270529, 14745)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1270591, 7149)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1270593, 7149)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1270680, 7149)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1272421, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1273516, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1273517, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1273518, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1273520, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1273550, 7109)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1273840, 7115)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1273844, 7108)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1273845, 7108)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1273849, 7108)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1273854, 7115)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1273856, 7108)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1273858, 7108)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1273869, 7108)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1274735, 6943)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1274750, 6943)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1274822, 6943)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1275127, 6943)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1275403, 6943)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1275502, 6943)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1275579, 6943)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1277156, 7036)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1277157, 7036)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1277158, 7036)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1277197, 7036)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1277199, 7036)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1277203, 7036)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1277209, 7036)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1277215, 7036)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1277363, 6943)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1277419, 6943)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1277439, 6943)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1281136, 7149)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1281147, 7149)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1281150, 6939)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1281151, 6939)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1281152, 6939)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1281153, 6939)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1281182, 6939)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(1281684, 6943)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(133893, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(139284, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(139295, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(139320, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(22438, 7036)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(22439, 7036)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(22439, 7040)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(226623, 6939)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(230863, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(231019, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(231021, 7036)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(231022, 7036)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(231062, 6943)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(236879, 6939)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(236880, 6939)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(236884, 6939)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(236894, 7149)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(236895, 7135)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(238353, 6939)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(238354, 7149)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(238356, 6939)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(238410, 16496)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(238411, 6939)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(239923, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(240028, 7149)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(240031, 7149)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(240788, 7149)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(240789, 7149)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(240790, 6939)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(240792, 7135)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(240850, 7108)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(241959, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(247214, 7149)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(247216, 7149)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(248098, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(248100, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(248101, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(248104, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(248106, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(248775, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(248778, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(248779, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(248780, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(248783, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(249109, 6943)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(249130, 6943)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(249133, 6939)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(249134, 7149)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(249136, 6939)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(249149, 16496)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(249149, 6943)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(249149, 7149)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(249154, 16496)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(249154, 6943)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(249154, 7149)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(249159, 16496)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(249159, 6943)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(249159, 7149)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(249164, 16496)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(249164, 6943)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(249164, 7149)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(249437, 7036)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(249439, 7036)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(249445, 7036)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(251105, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(251109, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(251110, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(251203, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(251204, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(261686, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(261688, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(261689, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(261952, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(262909, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(262910, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(262914, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(262915, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(264384, 7149)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(264386, 7149)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(264568, 16597)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(264569, 16597)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(264571, 16597)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(264572, 16597)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(264579, 16607)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(264587, 16597)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(264588, 16597)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(264594, 7149)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(264596, 7149)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(264598, 7132)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(264600, 7149)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(264602, 16496)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(264604, 7149)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(264661, 6939)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(264663, 7132)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(264665, 6939)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(264666, 6939)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(265424, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(266738, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(266743, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(268028, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(268032, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(268042, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(269344, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(269349, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(269355, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(269362, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(269370, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(269377, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(269407, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(269418, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(269424, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(269427, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(269813, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(269814, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(270348, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(270354, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(270362, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(270368, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(270400, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(270405, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(270407, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(270414, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(270417, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(270424, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(270445, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(270454, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(270459, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(270469, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(270475, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(270483, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(270489, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(270497, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(270514, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(270525, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(270531, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(270534, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(270645, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(270657, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(270674, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(270699, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(270760, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(270770, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(270787, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(270804, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(270821, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(270829, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(270930, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(270932, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(270933, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(270937, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(270954, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(270955, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(270959, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(270960, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(270963, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(270965, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(273480, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(273488, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(273592, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(273593, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(273804, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(274822, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(274825, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(277710, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(277713, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(277718, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(278076, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(278082, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(278088, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(278662, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(278666, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(278716, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(278720, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(281094, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(281098, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(282917, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(282965, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(284347, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(284399, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(284415, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(284727, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(284733, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(285042, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(285061, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(285082, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(288561, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(288567, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(288751, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(288761, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(288772, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(294879, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(294892, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(305033, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(305040, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(305048, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(308493, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(308581, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(308991, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(308999, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(309021, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(309292, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(309307, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(309861, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(309869, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(309880, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(309935, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(309943, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(309958, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(310547, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(311530, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(314156, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(314167, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(314490, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(314496, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(315462, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(315912, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(315924, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(316541, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(316551, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(317180, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(317193, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(317206, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(318256, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(318790, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(319651, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(319661, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(320979, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(320986, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(323553, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(323574, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(324682, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(324692, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(326364, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(326370, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(328484, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(328494, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(329089, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(329099, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(329109, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(329438, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(329449, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(329643, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(330220, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(330226, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(333134, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(333329, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(333341, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(333562, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(333565, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(333637, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(333647, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(336628, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(336634, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(336642, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(338134, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(338139, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(341004, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(341018, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(341033, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(344188, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(344656, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(344662, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(344667, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(346083, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(346091, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(346099, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(346263, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(346398, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(346406, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(347270, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(347295, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(347625, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(347628, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(347631, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(348265, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(348274, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(348282, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(348482, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(348494, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(348506, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(349185, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(349192, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(349198, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(350301, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(350304, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(350309, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(350570, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(350578, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(350746, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(350762, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(350776, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(350920, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(350928, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(351331, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(351334, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(351337, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(354556, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(354562, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(355175, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(355192, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(355212, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(355229, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(355350, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(355354, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(357160, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(357171, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(357184, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(359750, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(359755, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(360924, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(360930, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(361483, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(361502, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(364041, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(364047, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(364344, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(364353, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(364742, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(364760, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(365547, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(365563, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(365706, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(365713, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(365723, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(365989, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(366002, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(366014, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(366841, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(369517, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(369527, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(369652, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(369654, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(369656, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(370025, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(370033, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(370612, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(370620, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(370627, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(372301, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(372310, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(374436, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(374457, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(374479, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(374500, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(374736, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(374744, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(375061, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(375076, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(375090, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(375238, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(375249, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(375548, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(375566, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(376657, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(376662, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(377336, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(377343, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(378642, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(378647, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(378652, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(379770, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(379782, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(381669, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(381677, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(381684, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(381749, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(381757, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(381763, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(382352, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(382360, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(382685, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(382697, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(382709, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(382914, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(382924, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(383541, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(383545, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(384220, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(384233, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(384245, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(384710, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(385432, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(385438, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(385649, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(385667, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(386012, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(386021, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(386528, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(388668, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(388686, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(389569, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(389579, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(390031, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(391477, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(391483, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(392316, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(392334, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(392350, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(393610, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(393617, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(393628, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(395688, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(400087, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(400102, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(400114, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(400870, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(400879, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(408868, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(408880, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(409830, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(409833, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(414751, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(414764, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(414899, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(414907, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(414915, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(415362, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(415382, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(415632, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(415642, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(416152, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(416158, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(416165, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(416170, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(416175, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(419616, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(419625, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(419633, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(419900, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(419924, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(419945, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(420453, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(421510, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(421520, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(421530, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(421542, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(421752, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(421764, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(421776, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(422475, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(422488, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(422499, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(422817, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(422824, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(424669, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(424675, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(424820, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(424825, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(425189, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(425204, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(425607, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(425623, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(425643, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(428921, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(428937, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(434351, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(439029, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(439039, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(439054, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(439061, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(439144, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(439146, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(439147, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(440046, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(440055, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(440420, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(440432, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(443366, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(443368, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(443370, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(443373, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(443993, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(447084, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(447357, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(447368, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(447381, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(447762, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(447771, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(447994, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(447997, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(448704, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(448711, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(450896, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(450913, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(451235, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(451256, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(451278, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(451299, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(451688, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(451689, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(453188, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(453203, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(454483, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(455118, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(455122, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(457323, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(457329, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(457334, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(457756, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(457770, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(461254, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(461268, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(462443, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(462464, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(464245, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(464255, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(465080, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(465086, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(465282, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(465290, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(465563, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(465571, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(465618, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(465628, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(466469, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(466489, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(469782, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(469792, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(470329, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(470337, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(470344, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(470811, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(470821, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(470829, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(470841, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(472423, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(473926, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(473931, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(473938, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(474084, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(474093, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(474489, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(474504, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(477473, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(477481, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(477486, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(478207, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(478217, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(478228, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(478527, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(478542, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(478561, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(478671, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(478675, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(478679, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(478683, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(478708, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(478712, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(478716, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(478720, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(478723, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(480359, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(480371, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(480383, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(482077, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(482094, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(482376, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(482398, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(482419, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(483299, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(485362, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(485588, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(485594, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(485601, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(485608, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(485613, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(485638, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(485643, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(485648, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(485653, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(485657, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(486433, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(486442, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(486450, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(486715, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(486728, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(486742, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(487479, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(487486, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(487493, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(487584, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(487592, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(491095, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(491099, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(491108, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(492006, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(492022, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(492412, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(492420, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(492533, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(492537, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(492641, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(492645, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(495778, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(495995, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(496010, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(497569, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(497573, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(502032, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(506985, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(510004, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(511360, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(511367, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(512082, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(512094, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(513146, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(513152, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(514233, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(514242, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(516665, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(516675, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(516687, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(518153, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(518158, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(518226, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(518229, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(518233, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(518592, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(518600, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(518606, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(519016, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(519021, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(519025, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(519081, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(519087, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(519093, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(519347, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(519356, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(519362, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(520234, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(520239, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(520240, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(520252, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(520254, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(520257, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(523076, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(523077, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(523078, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(523079, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(523080, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(523581, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(523587, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(524671, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(534254, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(534259, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(534266, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(534312, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(534319, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(534326, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(534331, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(534463, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(534476, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(534817, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(536272, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(536290, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(537093, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(537109, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(537126, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(543311, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(544718, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(544724, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(546103, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(546137, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(547203, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(547210, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(552397, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(552404, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(554133, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(554141, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(555954, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(568529, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(568538, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(571095, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(571106, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(571117, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(571330, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(571335, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(571338, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(575388, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(581474, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(582206, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(582218, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(583399, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(583401, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(588634, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(588714, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(588904, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(588907, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(589347, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(589357, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(589364, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(590132, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(590140, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(591537, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(591543, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(591548, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(592459, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(592470, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(592482, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(592739, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(593194, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(593204, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(593774, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(593776, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(595255, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(595271, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(595284, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(597280, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(599500, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(599511, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(599520, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(600046, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(600061, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(600072, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(600275, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(600295, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(600309, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(600508, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(600528, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(600873, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(601413, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(601421, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(601650, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(601657, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(603231, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(603236, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(606225, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(607143, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(607155, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(607167, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(607179, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(607194, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(607207, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(607220, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(607233, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(607245, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(607258, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(607271, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(607284, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(607758, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(607772, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(608920, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(608930, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(610109, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(610115, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(610120, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(610125, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(610128, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(610130, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(610138, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(610142, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(610147, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(610151, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(610155, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(610158, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(610411, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(610413, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(610414, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(610415, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(614783, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(614787, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(615388, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(615407, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(615424, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(615598, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(615607, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(616372, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(616378, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(616383, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(616670, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(616674, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(617192, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(617202, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(617747, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(617762, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(617779, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(620323, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(620324, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(620325, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(620326, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(620327, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(625207, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(625210, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(626815, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(626827, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(626834, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(626940, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(626949, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(627240, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(627241, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(627242, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(627243, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(627354, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(627364, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(629133, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(629135, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(629136, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(629138, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(629172, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(629179, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(629346, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(629352, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(633886, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(633899, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(634084, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(637991, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(641891, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(641899, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(642146, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(642981, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(642993, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(643005, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(643019, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(644855, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(644864, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(651061, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(651065, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(654598, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(654620, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(654642, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(655974, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(655979, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(655986, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(656226, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(656240, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(656251, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(656310, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(656321, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(656332, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(656341, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(656573, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(656581, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(657554, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(657563, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(658864, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(658865, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(660853, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(661519, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(661526, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(661534, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(661539, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(661566, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(661575, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(661583, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(661590, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(661635, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(661642, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(662244, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(662253, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(662262, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(662271, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(662321, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(662330, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(662339, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(662348, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(662358, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(662653, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(662666, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(662683, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(662700, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(662715, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(662765, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(662781, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(662789, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(662796, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(662800, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(663225, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(663228, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(663230, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(663456, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(663459, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(663463, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(663468, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(663506, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(663512, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(663520, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(663525, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(663529, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(664314, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(664318, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(664337, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(666957, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(666958, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(669006, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(669022, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(669036, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(669912, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(669919, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(670684, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(670686, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(670693, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(670697, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(670701, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(670703, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(671856, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(675524, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(675574, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(675581, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(678090, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(679970, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(681985, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(681986, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(681987, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(683995, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(684011, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(685247, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(685251, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(685786, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(685795, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(685798, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(686238, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(686240, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(686242, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(686507, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(686511, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(686517, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(686613, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(686629, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(687001, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(687003, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(689339, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(689352, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(689478, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(689494, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(690149, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(690166, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(690515, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(693428, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(693430, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(693432, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(693435, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(693438, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(693457, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(693464, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(693467, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(693469, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(694558, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(694582, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(696053, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(696946, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(696949, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(696954, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(696958, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(696986, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(696990, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(696994, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(696996, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(696998, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(697000, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(699140, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(699937, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(700293, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(700302, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(700308, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(701423, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(701432, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(701443, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(701492, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(701502, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(701512, 8013)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(710732, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(710745, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(714120, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(714137, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(714152, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(716357, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(716359, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(717592, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(717598, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(718213, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(718217, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(718220, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(718416, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(718417, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(722070, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(722081, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(722090, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(722559, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(722570, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(723401, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(723409, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(723416, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(723876, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(723889, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(725741, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(725745, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(727001, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(727011, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(727021, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(727470, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(727478, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(728788, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(728800, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(732458, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(732474, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(734648, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(734649, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(734650, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(734651, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(736944, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(736953, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(741841, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(741845, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(741901, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(741908, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(742840, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(742854, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(742868, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(743280, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(743291, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(743302, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(743312, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(744046, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(744053, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(744060, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(744068, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(744078, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(744550, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(744560, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(744569, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(744980, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(744987, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(744993, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(745347, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(746216, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(747034, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(747036, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(747564, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(747572, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(747578, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(747586, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(747938, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(747946, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(747955, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(748237, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(748258, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(748389, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(748391, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(748947, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(748951, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(749204, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(749214, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(750037, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(750051, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(750719, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(750723, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(751661, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(751669, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(751719, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(751721, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(752846, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(752856, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(753166, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(753178, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(755057, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(755062, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(755139, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(755144, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(755476, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(755484, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(755543, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(755548, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(755552, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(755986, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(755991, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(755995, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(756931, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(756935, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(757896, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(757911, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(757923, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(757938, 17231)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(759166, 7149)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(759239, 6939)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(759240, 6939)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(759241, 6939)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(759243, 7149)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(759244, 7135)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(759256, 6943)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(759257, 7038)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(763696, 6939)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(763837, 7149)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(763838, 7149)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(763841, 14746)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(763843, 14745)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(763847, 7149)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(763848, 7149)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(763998, 16496)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(763999, 16496)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(764000, 16496)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(764001, 16496)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(764002, 16496)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(764003, 7149)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(764004, 16496)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(764005, 7149)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(764006, 6943)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(764007, 16496)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(764009, 16496)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(764045, 7149)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(764047, 7149)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(764049, 7149)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(764051, 7149)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(764053, 7149)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(764055, 7149)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(764057, 7149)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(764062, 14822)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(764064, 14822)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(764068, 7149)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(764070, 7149)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(764099, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(764100, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(764168, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(764171, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(764174, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(764180, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(764190, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(764197, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(764201, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(764202, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(772902, 7040)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(772908, 7040)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(772943, 6939)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(772944, 6939)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(773591, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(773592, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(777778, 6943)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(777781, 7040)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(777783, 7040)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(778634, 7036)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(778636, 7036)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(778638, 7036)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(779944, 7149)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(780093, 14364)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(780096, 7135)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(780097, 6939)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(834711, 7036)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(836070, 7132)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(836072, 7132)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(836524, 7036)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(836952, 7040)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(837524, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(837527, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(837789, 7149)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(838324, 6939)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(838325, 17908)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(838326, 17908)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(838601, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(838602, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(838603, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(838604, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(838605, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(838606, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(838607, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(838611, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(838614, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(838720, 7149)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(838734, 7149)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(838771, 7149)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(932406, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(932409, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(932900, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(932902, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(933260, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(933262, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(934005, 6943)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(934006, 6943)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(934014, 7036)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(935580, 6963)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(938107, 7036)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(938108, 7036)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(938115, 7036)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(938116, 7036)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(938117, 7036)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(938124, 7036)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(938130, 7036)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(938131, 7036)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(938154, 7036)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(938155, 7036)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(938156, 7036)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(938163, 7036)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(938169, 7036)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(938170, 7036)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(938246, 6943)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(938247, 7036)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(938657, 6943)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(938703, 6943)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(938907, 6943)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(939304, 6943)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(939537, 6943)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(939769, 6943)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(940157, 6943)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(940554, 6943)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(940619, 6943)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(940765, 6943)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(940767, 6943)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(941012, 6943)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(941210, 6943)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(945116, 6999)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(945124, 6999)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(946687, 6943)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(946688, 6943)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(946689, 7040)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(947503, 7093)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(949620, 6943)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(949657, 6943)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(949883, 6943)
insert into GXD_InSituResultStructure (_Result_key, _Structure_key) values(949977, 6943)
update GXD_InSituResult set resultNote = "About 35% of alpha cells label for alkaline phosphatase." where _Result_key = 933260
update GXD_InSituResult set resultNote = "About 35% of beta cells label for alkaline phosphatase." where _Result_key = 933262
update GXD_InSituResult set resultNote = "Absent in lymphocytes and reticulocytes in the thymus." where _Result_key = 231022
update GXD_InSituResult set resultNote = "After removal of osteoblasts, fluorescence was observed in mature multinucleated osteoclasts. These cells were also positive for TRAP (Acp5)." where _Result_key = 772943
update GXD_InSituResult set resultNote = "After removal of osteoblasts, fluorescence was observed in mature multinucleated osteoclasts. These cells were also positive for TRAP (Acp5)." where _Result_key = 772944
update GXD_InSituResult set resultNote = "All labeled beta cells also contain insulin." where _Result_key = 838611
update GXD_InSituResult set resultNote = "Beta cells containing granules within the islets are most intensely stained." where _Result_key = 262910
update GXD_InSituResult set resultNote = "Cre activity is observed in most chondrocytes in the patella, patella cartilage and synovium." where _Result_key = 1270467
update GXD_InSituResult set resultNote = "Cre activity is observed in the Achilles and superficial digital flexor tendon of the heel, with RFP-positive chondrocytes distributed predominantly epiphyseal cartilage around the chondro-tendinous/ligmaentous junction (CT/LJ) of the calcaneous." where _Result_key = 1270468
update GXD_InSituResult set resultNote = "Cre expression is detected in columnar proliferating and hypertrophic chondrocytes." where _Result_key = 764005
update GXD_InSituResult set resultNote = "Cre expression is detected in osteoclast precursors in bone marrow of long bones." where _Result_key = 764006
update GXD_InSituResult set resultNote = "Cre expression is detected in osteoclasts in long bones." where _Result_key = 764004
update GXD_InSituResult set resultNote = "Cre expression is detected in osteoclasts in long bones." where _Result_key = 764007
update GXD_InSituResult set resultNote = "Cre expression is observed in most beta cells." where _Result_key = 261686
update GXD_InSituResult set resultNote = "EGFP protein is detected in megakaryocytes from tamoxifen treated adult mice." where _Result_key = 934006
update GXD_InSituResult set resultNote = "Expression in osteoblasts." where _Result_key = 763696
update GXD_InSituResult set resultNote = "Expression is detected in chondrocytes in the resting zone, proliferating zone and higher hypertrophic zone. No expression was detected in chondrocytes of the lower hypertrophic zone." where _Result_key = 764068
update GXD_InSituResult set resultNote = "Expression is detected only in hypertrophic chondrocytes." where _Result_key = 247216
update GXD_InSituResult set resultNote = "Expression is in a subset of macrophages in the bone marrow." where _Result_key = 938246
update GXD_InSituResult set resultNote = "Expression is in alveolar macrophages, absent on endothelial cells." where _Result_key = 938130
update GXD_InSituResult set resultNote = "Expression is in alveolar macrophages, absent on endothelial cells." where _Result_key = 938131
update GXD_InSituResult set resultNote = "Expression is in alveolar macrophages, absent on endothelial cells." where _Result_key = 938169
update GXD_InSituResult set resultNote = "Expression is in alveolar macrophages, absent on endothelial cells." where _Result_key = 938170
update GXD_InSituResult set resultNote = "Expression is in chondroprogenitor cells and early stage differentiating chondrocytes; absent in chondrocytes in the proliferating zone." where _Result_key = 1281136
update GXD_InSituResult set resultNote = "Expression is in developing chondrocytes of the limb." where _Result_key = 1243037
update GXD_InSituResult set resultNote = "Expression is in early stage osteoblasts." where _Result_key = 1281182
update GXD_InSituResult set resultNote = "Expression is in hypertrophic chondrocytes." where _Result_key = 1243040
update GXD_InSituResult set resultNote = "Expression is in leukocytes in the pericardial cavity, strong expression in infiltrative leukocytes." where _Result_key = 1277199
update GXD_InSituResult set resultNote = "Expression is in leukocytes in the pericardial cavity." where _Result_key = 1277156
update GXD_InSituResult set resultNote = "Expression is in leukocytes in the submucosa of the intestine." where _Result_key = 1277197
update GXD_InSituResult set resultNote = "Expression is in lymphocytes in the submucosa of the intestine." where _Result_key = 1277158
update GXD_InSituResult set resultNote = "Expression is in macrophages in the uterus." where _Result_key = 231021
update GXD_InSituResult set resultNote = "Expression is in megakaryocytes." where _Result_key = 231062
update GXD_InSituResult set resultNote = "Expression is in microgranulomatous clusters in the liver." where _Result_key = 935580
update GXD_InSituResult set resultNote = "Expression is in monocytes/macrophages in lung." where _Result_key = 1277157
update GXD_InSituResult set resultNote = "Expression is in osteoblasts on the endosteal side of the diaphysis and in some areas within the cortical bone." where _Result_key = 1281151
update GXD_InSituResult set resultNote = "Expression is in proliferating and hypertrophic chondrocytes." where _Result_key = 249134
update GXD_InSituResult set resultNote = "Expression is low to absent at the tips." where _Result_key = 133893
update GXD_InSituResult set resultNote = "Expression is present in chondrocytes in the growth plate of the knee joint, in the uncalcified articular cartilage above the tidemark, and in the superficial layer of the meniscus. It is not in chondrocytes in the calcified cartilage below the tidemark." where _Result_key = 764070
update GXD_InSituResult set resultNote = "Expression is strong in osteoblasts, chondrocytes, moderate in perichondrium/periosteum and is weak in marrow/megakaryocytes of the long bone." where _Result_key = 249159
update GXD_InSituResult set resultNote = "Expression is strong in osteoblasts, chondrocytes, moderate in perichondrium/periosteum and is weak in marrow/megakaryocytes of the long bone." where _Result_key = 249164
update GXD_InSituResult set resultNote = "Expression is strong in osteoblasts, perichondrium/periosteum and is moderate in chondrocytes, marrow/megakaryocytes of the long bone." where _Result_key = 249149
update GXD_InSituResult set resultNote = "Expression is strong in osteoblasts, perichondrium/periosteum and is moderate in chondrocytes, marrow/megakaryocytes of the long bone." where _Result_key = 249154
update GXD_InSituResult set resultNote = "Expression is strong in proliferating chondrocytes and is absent in resting and hypertrophic chondrocytes." where _Result_key = 240788
update GXD_InSituResult set resultNote = "Expression is strong in proliferating chondrocytes and is absent in resting and hypertrophic chondrocytes." where _Result_key = 240789
update GXD_InSituResult set resultNote = "Expression is weak in osteocytes in the metaphysis of the tibia." where _Result_key = 240792
update GXD_InSituResult set resultNote = "Expression was confined to the endoplasmic reticulum and the cytoplasm of the acinar cells." where _Result_key = 262914
update GXD_InSituResult set resultNote = "Expression was detected in the Golgi complex of the acinar cells. There was high density labeling of vesicles, and some gold particles were observed in the parallel membranes of Golgi transface." where _Result_key = 262915
update GXD_InSituResult set resultNote = "Expression was strong but focal in the acinar cells." where _Result_key = 139320
update GXD_InSituResult set resultNote = "Expression was strong in neutrophils." where _Result_key = 22438
update GXD_InSituResult set resultNote = "Expression was strong in the acinar glands and the islet epithelial cells." where _Result_key = 139284
update GXD_InSituResult set resultNote = "Fluorescence is observed with some degree of mosaicism in acinar cells." where _Result_key = 248100
update GXD_InSituResult set resultNote = "Fluorescence is observed with some degree of mosaicism in beta cells." where _Result_key = 248101
update GXD_InSituResult set resultNote = "In lumbar vertebrae, staining is not observed in osteoblasts or osteocytes." where _Result_key = 838326
update GXD_InSituResult set resultNote = "In lumbar vertebrae, staining is observed in osteoclasts." where _Result_key = 838325
update GXD_InSituResult set resultNote = "In the metaphysis expression is strong in osteoblasts and osteoclasts on the bone surface and is weak in osteocytes." where _Result_key = 240790
update GXD_InSituResult set resultNote = "Labeling is observed in a subset of cells, likely osteocytes, in the bone surrounding the inner ear starting at P6." where _Result_key = 945116
update GXD_InSituResult set resultNote = "Labeling is observed in all insulin-expressing beta cells." where _Result_key = 1272421
update GXD_InSituResult set resultNote = "Macrophages in the lamina propria." where _Result_key = 938247
update GXD_InSituResult set resultNote = "Macrophages in the lymph node and in sinusoidal endothelial cells." where _Result_key = 938154
update GXD_InSituResult set resultNote = "Macrophages in the lymph node and on endothelial sinusoidal cells." where _Result_key = 938155
update GXD_InSituResult set resultNote = "Macrophages in the lymph node and on sinusoidal endothelial cells." where _Result_key = 938156
update GXD_InSituResult set resultNote = "Macrophages in the lymph node in the medullary sinusoidal space adjacent to the paracortical areas." where _Result_key = 938115
update GXD_InSituResult set resultNote = "Macrophages in the lymph node in the medullary sinusoidal space adjacent to the paracortical areas." where _Result_key = 938116
update GXD_InSituResult set resultNote = "Macrophages in the lymph node in the medullary sinusoidal space adjacent to the paracortical areas." where _Result_key = 938117
update GXD_InSituResult set resultNote = "Natural killer cells in the pregnant (day 10) uterus." where _Result_key = 836524
update GXD_InSituResult set resultNote = "No EGFP fluorescence is observed in erythrocytes." where _Result_key = 836952
update GXD_InSituResult set resultNote = "No expression is observed in acinar or other endocrine cell types." where _Result_key = 261689
update GXD_InSituResult set resultNote = "No labeling is observed in macrophages labeled with antibody to F4/80." where _Result_key = 934014
update GXD_InSituResult set resultNote = "No staining is observed in osteoblasts in bone sections." where _Result_key = 238356
update GXD_InSituResult set resultNote = "No staining is observed in osteoclast (TRAP-positive) cells." where _Result_key = 1262303
update GXD_InSituResult set resultNote = "No staining is observed in the cuboidal osteoblastic cell lining of the cancellous bone." where _Result_key = 1245713
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 241959
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 269813
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 269814
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 270699
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 273480
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 273488
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 273804
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 274822
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 274825
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 278076
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 278082
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 278088
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 278662
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 278666
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 278716
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 278720
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 281094
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 281098
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 282917
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 282965
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 284347
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 284399
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 284415
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 284727
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 284733
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 285042
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 285061
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 285082
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 288561
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 288567
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 288751
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 288761
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 288772
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 294879
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 294892
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 305033
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 305040
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 305048
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 308493
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 308581
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 308991
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 308999
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 309021
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 309292
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 309307
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 309861
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 309869
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 309880
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 309935
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 309943
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 309958
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 310547
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 311530
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 314156
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 314167
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 314490
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 314496
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 315462
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 315912
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 315924
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 316541
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 316551
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 317180
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 317193
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 317206
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 318256
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 318790
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 319651
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 319661
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 320979
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 320986
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 323553
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 323574
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 324682
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 324692
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 326364
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 326370
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 328484
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 328494
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 329089
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 329099
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 329109
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 329438
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 329449
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 329643
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 330220
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 330226
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 333134
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 333329
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 333341
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 333562
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 333565
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 333637
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 333647
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 336628
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 336634
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 336642
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 338134
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 338139
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 341004
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 341018
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 341033
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 344188
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 344656
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 344662
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 344667
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 346083
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 346091
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 346099
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 346263
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 346398
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 346406
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 347270
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 347295
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 347625
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 347628
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 347631
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 348265
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 348274
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 348282
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 348482
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 348494
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 348506
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 349185
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 349192
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 349198
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 350301
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 350304
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 350309
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 350570
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 350578
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 350746
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 350762
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 350776
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 350920
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 350928
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 351331
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 351334
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 351337
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 354556
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 354562
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 355175
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 355192
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 355212
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 355229
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 355350
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 355354
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 357160
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 357171
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 357184
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 359750
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 359755
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 360924
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 360930
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 361483
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 361502
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 364041
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 364047
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 364344
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 364353
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 364742
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 364760
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 365547
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 365563
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 365706
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 365713
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 365723
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 365989
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 366002
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 366014
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 366841
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 369517
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 369527
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 369652
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 369654
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 369656
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 370025
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 370033
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 370612
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 370620
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 370627
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 372301
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 372310
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 374436
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 374457
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 374479
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 374500
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 374736
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 374744
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 375061
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 375076
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 375090
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 375238
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 375249
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 375548
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 375566
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 376657
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 376662
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 377336
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 377343
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 378642
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 378647
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 378652
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 379770
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 379782
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 381669
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 381677
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 381684
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 381749
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 381757
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 381763
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 382352
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 382360
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 382685
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 382697
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 382709
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 382914
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 382924
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 383541
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 383545
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 384220
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 384233
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 384245
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 384710
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 385432
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 385438
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 385649
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 385667
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 386012
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 386021
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 386528
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 388668
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 388686
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 389569
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 389579
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 390031
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 391477
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 391483
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 392316
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 392334
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 392350
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 393610
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 393617
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 393628
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 395688
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 400087
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 400102
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 400114
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 400870
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 400879
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 408868
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 408880
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 409830
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 409833
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 414751
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 414764
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 414899
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 414907
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 414915
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 415362
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 415382
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 415632
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 415642
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 416152
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 416158
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 416165
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 416170
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 416175
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 419616
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 419625
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 419633
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 419900
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 419924
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 419945
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 420453
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 421510
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 421520
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 421530
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 421542
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 421752
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 421764
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 421776
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 422475
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 422488
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 422499
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 422817
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 422824
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 424669
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 424675
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 424820
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 424825
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 425189
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 425204
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 425607
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 425623
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 425643
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 428921
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 428937
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 434351
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 439054
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 439061
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 439144
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 439146
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 439147
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 440046
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 440055
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 440420
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 440432
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 443366
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 443368
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 443370
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 443373
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 443993
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 447084
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 447357
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 447368
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 447381
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 447762
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 447771
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 447994
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 447997
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 450896
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 450913
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 451235
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 451256
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 451278
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 451299
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 451688
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 451689
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 453188
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 453203
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 454483
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 455118
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 455122
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 457323
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 457329
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 457334
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 457756
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 457770
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 461254
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 461268
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 462443
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 462464
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 464245
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 464255
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 465080
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 465086
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 465282
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 465290
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 466469
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 466489
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 469782
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 469792
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 470329
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 470337
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 470344
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 470811
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 470821
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 470829
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 470841
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 472423
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 473926
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 473931
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 473938
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 474084
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 474093
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 474489
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 474504
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 477473
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 477481
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 477486
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 478207
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 478217
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 478228
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 478527
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 478542
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 478561
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 480359
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 480371
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 480383
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 482077
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 482094
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 482376
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 482398
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 482419
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 483299
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 486433
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 486442
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 486450
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 486715
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 486728
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 486742
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 487479
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 487486
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 487493
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 487584
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 487592
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 491095
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 491099
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 491108
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 492006
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 492022
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 492412
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 492420
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 492533
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 492537
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 492641
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 492645
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 495778
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 495995
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 496010
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 497569
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 497573
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 502032
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 506985
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 510004
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 511360
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 511367
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 512082
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 512094
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 513146
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 513152
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 514233
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 514242
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 516665
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 516675
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 516687
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 518153
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 518158
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 518226
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 518229
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 518233
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 518592
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 518600
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 518606
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 519016
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 519021
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 519025
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 519081
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 519087
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 519093
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 519347
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 519356
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 519362
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 520234
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 520239
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 520240
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 520252
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 520254
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 520257
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 523581
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 523587
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 524671
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 534463
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 534476
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 534817
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 536272
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 536290
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 537093
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 537109
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 537126
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 543311
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 544718
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 544724
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 546103
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 546137
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 547203
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 547210
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 552397
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 552404
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 554133
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 554141
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 555954
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 568529
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 568538
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 571095
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 571106
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 571117
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 571330
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 571335
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 571338
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 575388
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 581474
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 582206
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 582218
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 583399
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 583401
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 588634
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 588714
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 588904
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 588907
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 589347
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 589357
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 589364
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 590132
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 590140
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 591537
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 591543
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 591548
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 592459
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 592470
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 592482
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 592739
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 593194
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 593204
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 593774
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 593776
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 595255
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 595271
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 595284
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 597280
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 599500
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 599511
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 599520
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 600046
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 600061
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 600072
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 600275
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 600295
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 600309
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 600508
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 600528
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 600873
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 601413
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 601421
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 601650
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 601657
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 603231
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 603236
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 606225
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 607143
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 607155
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 607167
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 607179
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 607194
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 607207
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 607220
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 607233
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 607245
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 607258
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 607271
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 607284
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 607758
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 607772
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 608920
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 608930
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 610411
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 610413
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 610414
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 610415
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 614783
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 614787
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 615388
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 615407
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 615424
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 615598
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 615607
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 616372
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 616378
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 616383
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 616670
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 616674
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 617192
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 617202
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 617747
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 617762
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 617779
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 625207
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 625210
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 626815
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 626827
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 626834
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 626940
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 626949
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 627354
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 627364
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 629346
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 629352
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 633886
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 633899
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 634084
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 637991
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 641891
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 641899
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 642146
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 642981
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 642993
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 643005
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 643019
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 644855
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 644864
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 651061
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 651065
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 654598
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 654620
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 654642
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 655974
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 655979
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 655986
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 656573
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 656581
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 657554
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 657563
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 658864
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 658865
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 660853
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 661635
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 661642
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 662700
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 662715
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 663225
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 663228
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 663230
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 664314
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 664318
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 664337
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 666957
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 666958
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 669006
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 669022
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 669036
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 669912
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 669919
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 670693
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 670697
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 671856
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 675524
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 675574
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 675581
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 678090
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 679970
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 681985
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 681986
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 681987
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 683995
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 684011
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 685247
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 685251
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 685786
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 685795
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 685798
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 686238
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 686240
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 686242
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 686507
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 686511
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 686517
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 686613
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 686629
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 687001
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 687003
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 689339
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 689352
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 689478
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 689494
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 690149
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 690166
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 690515
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 694558
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 694582
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 696053
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 699140
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 699937
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 700293
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 700302
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 700308
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 710732
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 710745
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 714120
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 714137
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 714152
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 716357
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 716359
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 717592
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 717598
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 718213
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 718217
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 718220
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 718416
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 718417
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 722070
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 722081
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 722090
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 722559
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 722570
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 723401
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 723409
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 723416
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 723876
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 723889
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 725741
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 725745
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 727001
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 727011
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 727021
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 727470
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 727478
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 728788
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 728800
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 732458
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 732474
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 734648
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 734649
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 734650
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 734651
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 736944
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 736953
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 741841
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 741845
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 741901
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 741908
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 742840
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 742854
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 742868
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 743280
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 743291
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 743302
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 743312
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 744046
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 744053
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 744060
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 744068
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 744078
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 744550
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 744560
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 744569
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 744980
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 744987
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 744993
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 745347
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 746216
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 747034
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 747036
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 747564
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 747572
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 747578
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 747586
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 747938
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 747946
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 747955
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 748237
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 748258
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 748389
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 748391
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 748947
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 748951
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 749204
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 749214
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 750037
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 750051
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 750719
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 750723
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 751661
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 751669
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 751719
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 751721
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 752846
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 752856
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 753166
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 753178
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 755057
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 755062
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 755139
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 755144
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 755476
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 755484
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 755543
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 755548
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 755552
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 755986
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 755991
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 755995
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 756931
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 756935
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 757896
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 757911
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 757923
update GXD_InSituResult set resultNote = "Originally this result was annotated to a male-specific term, but as the specimen was not sexed, it is likely the data annotator intended to use a non-gender specific term." where _Result_key = 757938
update GXD_InSituResult set resultNote = "Robust staining is observed in adipocytes of all fat depots." where _Result_key = 1273844
update GXD_InSituResult set resultNote = "Robust staining is observed in adipocytes of all fat depots." where _Result_key = 1273845
update GXD_InSituResult set resultNote = "Robust staining is observed in adipocytes." where _Result_key = 1273840
update GXD_InSituResult set resultNote = "Scattered expression in macrophages/monocytes in the alveolar wall and cavity." where _Result_key = 1277203
update GXD_InSituResult set resultNote = "Scattered expression in macrophages/monocytes in the alveolar wall and cavity." where _Result_key = 1277209
update GXD_InSituResult set resultNote = "Scattered expression in macrophages/monocytes in the alveolar wall and cavity." where _Result_key = 1277215
update GXD_InSituResult set resultNote = "Some clusters of beta cells do not stain after the 12 month chase period, supporting that new clusters are not generated from non-beta cells during the 12 month chase period." where _Result_key = 838607
update GXD_InSituResult set resultNote = "Some clusters of chondrocytes do not show staining." where _Result_key = 240028
update GXD_InSituResult set resultNote = "Some islets do not contain labeled beta cells." where _Result_key = 838605
update GXD_InSituResult set resultNote = "Some megakaryocytes are stained intensely." where _Result_key = 1250824
update GXD_InSituResult set resultNote = "Some megakaryocytes are stained." where _Result_key = 1250911
update GXD_InSituResult set resultNote = "Some scattered megakaryocytes may show staining." where _Result_key = 941210
update GXD_InSituResult set resultNote = "Staining in megakaryocytes is homogeneous." where _Result_key = 1266984
update GXD_InSituResult set resultNote = "Staining is absent from chondrocytes in the long bones." where _Result_key = 238354
update GXD_InSituResult set resultNote = "Staining is limited in perigonadal fat pad sections." where _Result_key = 1273869
update GXD_InSituResult set resultNote = "Staining is mostly absent from chondrocytes." where _Result_key = 759166
update GXD_InSituResult set resultNote = "Staining is not observed in acinar cells (labeled with amylase)." where _Result_key = 838614
update GXD_InSituResult set resultNote = "Staining is not observed in osteoclasts of long bones in sections." where _Result_key = 764009
update GXD_InSituResult set resultNote = "Staining is observed in >80% of beta cells in some clusters. This indicates that new clusters are not generated from non-beta cells during the 12 month chase period." where _Result_key = 838606
update GXD_InSituResult set resultNote = "Staining is observed in a small number of acinar cells and cells in islets." where _Result_key = 932409
update GXD_InSituResult set resultNote = "Staining is observed in a small number of acinar cells." where _Result_key = 932406
update GXD_InSituResult set resultNote = "Staining is observed in a subset of cells, likely osteocytes, in the bone surrounding the inner ear starting at P6." where _Result_key = 945124
update GXD_InSituResult set resultNote = "Staining is observed in about 24% of beta cells in ligated portion of pancreas." where _Result_key = 764197
update GXD_InSituResult set resultNote = "Staining is observed in about 77% of beta cells in some clusters in islets." where _Result_key = 838604
update GXD_InSituResult set resultNote = "Staining is observed in about 85% of glucagon-positive alpha cells." where _Result_key = 251203
update GXD_InSituResult set resultNote = "Staining is observed in adipocytes of perigonadal fat." where _Result_key = 1273858
update GXD_InSituResult set resultNote = "Staining is observed in all acinar cells." where _Result_key = 251105
update GXD_InSituResult set resultNote = "Staining is observed in all hypertrophic chondrocytes in growth plates." where _Result_key = 837789
update GXD_InSituResult set resultNote = "Staining is observed in all hypertrophic chondrocytes of the growth plate." where _Result_key = 764051
update GXD_InSituResult set resultNote = "Staining is observed in all osteocytes and osteoblasts in the cortical and trabecular compartments, but not in presosteoblasts." where _Result_key = 264661
update GXD_InSituResult set resultNote = "Staining is observed in almost all (>95%) of insulin-producing beta cells." where _Result_key = 251110
update GXD_InSituResult set resultNote = "Staining is observed in alpha-cells at the outer ring of islets." where _Result_key = 239923
update GXD_InSituResult set resultNote = "Staining is observed in beta cells in islets which can be identified by dithizone staining which is specific for insulin-producing cells." where _Result_key = 1259723
update GXD_InSituResult set resultNote = "Staining is observed in chondrocytes around the chondro-tendinous/ligamentous junction." where _Result_key = 1270591
update GXD_InSituResult set resultNote = "Staining is observed in chondrocytes around the chondrotendinous/ligamentous junction. More chondrocytes show cre activity than in Tg(Scx-cre)LShuk mice." where _Result_key = 1270593
update GXD_InSituResult set resultNote = "Staining is observed in chondrocytes in growth plate cartilage. Occasionally a clone of chondrocytes that fails to stain for B-gal activity is observed." where _Result_key = 236894
update GXD_InSituResult set resultNote = "Staining is observed in chondrocytes in growth plate cartilage. Occasionally a clone of chondrocytes that fails to stain for B-gal activity is observed." where _Result_key = 759243
update GXD_InSituResult set resultNote = "Staining is observed in chondrocytes in the heel joints in greater numbers than in Tg(Col1a1-cre)2Bek/R26R mice." where _Result_key = 264600
update GXD_InSituResult set resultNote = "Staining is observed in chondrocytes of the articular cartilage and meniscus restricted to the superficial layers of the fibrocartilage.." where _Result_key = 764057
update GXD_InSituResult set resultNote = "Staining is observed in chondrocytes of the growth plate and articular cartilages." where _Result_key = 764049
update GXD_InSituResult set resultNote = "Staining is observed in chondrocytes of the growth plate of the tibia." where _Result_key = 236895
update GXD_InSituResult set resultNote = "Staining is observed in chondrocytes of the growth plate of the tibia." where _Result_key = 759244
update GXD_InSituResult set resultNote = "Staining is observed in chondrocytes of the ribs and sternum." where _Result_key = 1270529
update GXD_InSituResult set resultNote = "Staining is observed in chondrocytes." where _Result_key = 838734
update GXD_InSituResult set resultNote = "Staining is observed in clusters of acinar cells (mean number of cells/islet = 0.8%)." where _Result_key = 261952
update GXD_InSituResult set resultNote = "Staining is observed in clusters of proliferative chondrocytes as well as occasional hypertrophic chondrocytes and sporadically in growth plate chondrocytes." where _Result_key = 264594
update GXD_InSituResult set resultNote = "Staining is observed in clusters of proliferative chondrocytes as well as occasional hypertrophic chondrocytes and sporadically in growth plate chondrocytes." where _Result_key = 264596
update GXD_InSituResult set resultNote = "Staining is observed in clusters of proliferative chondrocytes as well as occasional hypertrophic chondrocytes in the area of the future secondary ossification centers." where _Result_key = 264604
update GXD_InSituResult set resultNote = "Staining is observed in columnar proliferating and hypertrophic chondrocytes in long bones." where _Result_key = 764000
update GXD_InSituResult set resultNote = "Staining is observed in dermal adipocytes." where _Result_key = 1273849
update GXD_InSituResult set resultNote = "Staining is observed in glucagon-containing alpha cells (15% of total number of stained cells)." where _Result_key = 764100
update GXD_InSituResult set resultNote = "Staining is observed in growth plate and articular chondrocytes." where _Result_key = 763837
update GXD_InSituResult set resultNote = "Staining is observed in growth plate and articular chondrocytes." where _Result_key = 763838
update GXD_InSituResult set resultNote = "Staining is observed in growth plate chondrocytes of the vertebral body and the nucleus pulposus and annulus fibrosis of the intervertebral disc." where _Result_key = 764062
update GXD_InSituResult set resultNote = "Staining is observed in growth plate chondrocytes of the vertebral body." where _Result_key = 764064
update GXD_InSituResult set resultNote = "Staining is observed in hypertrophic chondrocytes." where _Result_key = 247214
update GXD_InSituResult set resultNote = "Staining is observed in insulin-containing beta islet cells (75-80% of total number of stained cells)." where _Result_key = 764099
update GXD_InSituResult set resultNote = "Staining is observed in isolated splenocyte patches while megakaryocytes and small splenic vessels are consistently stained." where _Result_key = 1267022
update GXD_InSituResult set resultNote = "Staining is observed in joint chondrocytes." where _Result_key = 779944
update GXD_InSituResult set resultNote = "Staining is observed in lining cells and osteocytes in bone sections stainined for X-gal and TRAP (tartrate-resistant alkaline phosphatase-positive)." where _Result_key = 1262302
update GXD_InSituResult set resultNote = "Staining is observed in many (75%) glucagon-producing alpha cells." where _Result_key = 251109
update GXD_InSituResult set resultNote = "Staining is observed in mast cells in lung cells. Activity is similar in line 13 cre mice." where _Result_key = 778634
update GXD_InSituResult set resultNote = "Staining is observed in mast cells in the lung. Activity is similar in line 13 cre mice." where _Result_key = 778636
update GXD_InSituResult set resultNote = "Staining is observed in mast cells in the lung. Activity is similar in line 13 cre mice." where _Result_key = 778638
update GXD_InSituResult set resultNote = "Staining is observed in megakaryocytes in the bone marrow." where _Result_key = 759256
update GXD_InSituResult set resultNote = "Staining is observed in megakaryocytes in the spleen." where _Result_key = 759257
update GXD_InSituResult set resultNote = "Staining is observed in megakaryocytes when tamoxifen is given to adult mice." where _Result_key = 934005
update GXD_InSituResult set resultNote = "Staining is observed in megakaryocytes." where _Result_key = 946687
update GXD_InSituResult set resultNote = "Staining is observed in most chondrocytes in the growth plate, including the lower hypertrophic zone and the deep layers of the articular cartilage." where _Result_key = 764045
update GXD_InSituResult set resultNote = "Staining is observed in most chondrocytes in the growth plate, including the lower hypertrophic zone and the deep layers of the articular cartilage." where _Result_key = 764047
update GXD_InSituResult set resultNote = "Staining is observed in most megakaryocytes." where _Result_key = 1251114
update GXD_InSituResult set resultNote = "Staining is observed in most megakaryocytes." where _Result_key = 1251171
update GXD_InSituResult set resultNote = "Staining is observed in only about 0.01% of insulin-positive beta cells." where _Result_key = 251204
update GXD_InSituResult set resultNote = "Staining is observed in osteoblasts and osteocytes of the trabecular and cortical compartments of the femur." where _Result_key = 264663
update GXD_InSituResult set resultNote = "Staining is observed in osteoblasts in the femur." where _Result_key = 836070
update GXD_InSituResult set resultNote = "Staining is observed in osteoblasts in the femur." where _Result_key = 836072
update GXD_InSituResult set resultNote = "Staining is observed in osteoblasts in the growth plate of the tibia." where _Result_key = 236895
update GXD_InSituResult set resultNote = "Staining is observed in osteoblasts in the growth plate of the tibia." where _Result_key = 759244
update GXD_InSituResult set resultNote = "Staining is observed in osteoblasts in the perichondrium, periosteum and endosteum." where _Result_key = 236879
update GXD_InSituResult set resultNote = "Staining is observed in osteoblasts in the perichondrium, periosteum and endosteum." where _Result_key = 759239
update GXD_InSituResult set resultNote = "Staining is observed in osteoblasts lining the bone trabeculae." where _Result_key = 236884
update GXD_InSituResult set resultNote = "Staining is observed in osteoblasts lining the bone trabeculae." where _Result_key = 759241
update GXD_InSituResult set resultNote = "Staining is observed in osteoblasts of the parietal bones." where _Result_key = 264569
update GXD_InSituResult set resultNote = "Staining is observed in osteoblasts of the parietal bones." where _Result_key = 264572
update GXD_InSituResult set resultNote = "Staining is observed in osteoblasts of the parietal bones." where _Result_key = 264588
update GXD_InSituResult set resultNote = "Staining is observed in osteoclasts in long bones." where _Result_key = 764001
update GXD_InSituResult set resultNote = "Staining is observed in osteoclasts in long bones." where _Result_key = 764002
update GXD_InSituResult set resultNote = "Staining is observed in osteoclasts in the long bones." where _Result_key = 763998
update GXD_InSituResult set resultNote = "Staining is observed in osteoclasts in the long bones." where _Result_key = 763999
update GXD_InSituResult set resultNote = "Staining is observed in osteocytes in bone." where _Result_key = 780097
update GXD_InSituResult set resultNote = "Staining is observed in osteocytes of the calvarium." where _Result_key = 780093
update GXD_InSituResult set resultNote = "Staining is observed in osteocytes of the parietal bones." where _Result_key = 264568
update GXD_InSituResult set resultNote = "Staining is observed in osteocytes of the parietal bones." where _Result_key = 264571
update GXD_InSituResult set resultNote = "Staining is observed in osteocytes of the parietal bones." where _Result_key = 264587
update GXD_InSituResult set resultNote = "Staining is observed in osteocytes of the tibia." where _Result_key = 780096
update GXD_InSituResult set resultNote = "Staining is observed in peritoneal macrophages." where _Result_key = 834711
update GXD_InSituResult set resultNote = "Staining is observed in round proliferating chondrocytes." where _Result_key = 764003
update GXD_InSituResult set resultNote = "Staining is observed in single cells or clusters of acinar cells." where _Result_key = 764180
update GXD_InSituResult set resultNote = "Staining is observed in some beta cells also stained for insulin." where _Result_key = 764201
update GXD_InSituResult set resultNote = "Staining is observed in some beta cells also stained for insulin." where _Result_key = 764202
update GXD_InSituResult set resultNote = "Staining is observed in the articular cartilage of the long bones." where _Result_key = 238410
update GXD_InSituResult set resultNote = "Staining is observed in the islets, presumably in beta cells." where _Result_key = 1266240
update GXD_InSituResult set resultNote = "Staining is observed in trabecular osteoblasts in the femur. Some stained cells at the junction between the hypertrophic zone and the primary spongiosa are observed also." where _Result_key = 264598
update GXD_InSituResult set resultNote = "Staining is observed only in chondrocytes in rib sections." where _Result_key = 763841
update GXD_InSituResult set resultNote = "Staining is observed only in chondrocytes in spine sections." where _Result_key = 763843
update GXD_InSituResult set resultNote = "Staining is observed only in peripheral islet alpha cells." where _Result_key = 932900
update GXD_InSituResult set resultNote = "Staining is observed restricted in the articular cartilage to chondrocytes above the tidemark, a virtual line demarcating the superficial nonmineralized cartilage and deeper mineralized cartilage." where _Result_key = 764053
update GXD_InSituResult set resultNote = "Staining is occasionally observed in chondrocytes in the joints." where _Result_key = 264579
update GXD_InSituResult set resultNote = "Staining is occasionally observed in the articular cartilage of long bone." where _Result_key = 264602
update GXD_InSituResult set resultNote = "Staining is restricted to chondrocytes of the growth plate." where _Result_key = 764055
update GXD_InSituResult set resultNote = "Staining is uniform, presumably in beta cells." where _Result_key = 1266318
update GXD_InSituResult set resultNote = "Staining was not detected in monocytes, lymphocytes or eosinophils." where _Result_key = 22439
update GXD_InSituResult set resultNote = "Strong staining in chondrocytes is observed with 48 hours of 4-OH tamoxifen treatment." where _Result_key = 763848
update GXD_InSituResult set resultNote = "There was expression present in the acinar cells." where _Result_key = 1237968
update GXD_InSituResult set resultNote = "There was expression present in the acinar cells." where _Result_key = 1255973
update GXD_InSituResult set resultNote = "There was expression present in the acinar cells." where _Result_key = 1255975
update GXD_InSituResult set resultNote = "There was expression present in the acinar cells." where _Result_key = 248104
update GXD_InSituResult set resultNote = "There was expression present in the acinar cells." where _Result_key = 248106
update GXD_InSituResult set resultNote = "There was expression present in the acinar cells." where _Result_key = 262909
update GXD_InSituResult set resultNote = "There was expression present in the acinar cells." where _Result_key = 764190
update GXD_InSituResult set resultNote = "There was expression present in the acinar cells." where _Result_key = 773591
update GXD_InSituResult set resultNote = "There was expression present in the acinar cells." where _Result_key = 837524
update GXD_InSituResult set resultNote = "There was expression present in the acinar cells." where _Result_key = 837527
update GXD_InSituResult set resultNote = "There was expression present in the adipocytes." where _Result_key = 240850
update GXD_InSituResult set resultNote = "There was expression present in the alpha cells." where _Result_key = 1255983
update GXD_InSituResult set resultNote = "There was expression present in the alpha cells." where _Result_key = 1256041
update GXD_InSituResult set resultNote = "There was expression present in the alpha cells." where _Result_key = 1256042
update GXD_InSituResult set resultNote = "There was expression present in the alpha cells." where _Result_key = 248780
update GXD_InSituResult set resultNote = "There was expression present in the alpha cells." where _Result_key = 248783
update GXD_InSituResult set resultNote = "There was expression present in the beta cells." where _Result_key = 1255981
update GXD_InSituResult set resultNote = "There was expression present in the beta cells." where _Result_key = 1256055
update GXD_InSituResult set resultNote = "There was expression present in the beta cells." where _Result_key = 1256056
update GXD_InSituResult set resultNote = "There was expression present in the beta cells." where _Result_key = 1256060
update GXD_InSituResult set resultNote = "There was expression present in the beta cells." where _Result_key = 1256061
update GXD_InSituResult set resultNote = "There was expression present in the beta cells." where _Result_key = 1259735
update GXD_InSituResult set resultNote = "There was expression present in the beta cells." where _Result_key = 1273516
update GXD_InSituResult set resultNote = "There was expression present in the beta cells." where _Result_key = 1273517
update GXD_InSituResult set resultNote = "There was expression present in the beta cells." where _Result_key = 1273518
update GXD_InSituResult set resultNote = "There was expression present in the beta cells." where _Result_key = 1273520
update GXD_InSituResult set resultNote = "There was expression present in the beta cells." where _Result_key = 248098
update GXD_InSituResult set resultNote = "There was expression present in the beta cells." where _Result_key = 248775
update GXD_InSituResult set resultNote = "There was expression present in the beta cells." where _Result_key = 248778
update GXD_InSituResult set resultNote = "There was expression present in the beta cells." where _Result_key = 248779
update GXD_InSituResult set resultNote = "There was expression present in the beta cells." where _Result_key = 261688
update GXD_InSituResult set resultNote = "There was expression present in the beta cells." where _Result_key = 773592
update GXD_InSituResult set resultNote = "There was expression present in the beta cells." where _Result_key = 838601
update GXD_InSituResult set resultNote = "There was expression present in the beta cells." where _Result_key = 838602
update GXD_InSituResult set resultNote = "There was expression present in the beta cells." where _Result_key = 838603
update GXD_InSituResult set resultNote = "There was expression present in the beta cells." where _Result_key = 932902
update GXD_InSituResult set resultNote = "There was expression present in the chondrocytes." where _Result_key = 1245712
update GXD_InSituResult set resultNote = "There was expression present in the chondrocytes." where _Result_key = 1270680
update GXD_InSituResult set resultNote = "There was expression present in the chondrocytes." where _Result_key = 1281147
update GXD_InSituResult set resultNote = "There was expression present in the chondrocytes." where _Result_key = 240031
update GXD_InSituResult set resultNote = "There was expression present in the chondrocytes." where _Result_key = 264384
update GXD_InSituResult set resultNote = "There was expression present in the chondrocytes." where _Result_key = 264386
update GXD_InSituResult set resultNote = "There was expression present in the chondrocytes." where _Result_key = 838720
update GXD_InSituResult set resultNote = "There was expression present in the chondrocytes." where _Result_key = 838771
update GXD_InSituResult set resultNote = "There was expression present in the erythrocytes." where _Result_key = 772902
update GXD_InSituResult set resultNote = "There was expression present in the erythrocytes." where _Result_key = 772908
update GXD_InSituResult set resultNote = "There was expression present in the lymphocytes." where _Result_key = 777781
update GXD_InSituResult set resultNote = "There was expression present in the lymphocytes." where _Result_key = 777783
update GXD_InSituResult set resultNote = "There was expression present in the macrophages." where _Result_key = 249437
update GXD_InSituResult set resultNote = "There was expression present in the macrophages." where _Result_key = 249439
update GXD_InSituResult set resultNote = "There was expression present in the macrophages." where _Result_key = 249445
update GXD_InSituResult set resultNote = "There was expression present in the macrophages." where _Result_key = 938107
update GXD_InSituResult set resultNote = "There was expression present in the macrophages." where _Result_key = 938108
update GXD_InSituResult set resultNote = "There was expression present in the macrophages." where _Result_key = 938124
update GXD_InSituResult set resultNote = "There was expression present in the macrophages." where _Result_key = 938163
update GXD_InSituResult set resultNote = "There was expression present in the megakaryocytes." where _Result_key = 1237971
update GXD_InSituResult set resultNote = "There was expression present in the megakaryocytes." where _Result_key = 1238181
update GXD_InSituResult set resultNote = "There was expression present in the megakaryocytes." where _Result_key = 1251280
update GXD_InSituResult set resultNote = "There was expression present in the megakaryocytes." where _Result_key = 1265976
update GXD_InSituResult set resultNote = "There was expression present in the megakaryocytes." where _Result_key = 1266003
update GXD_InSituResult set resultNote = "There was expression present in the megakaryocytes." where _Result_key = 1266433
update GXD_InSituResult set resultNote = "There was expression present in the megakaryocytes." where _Result_key = 1266452
update GXD_InSituResult set resultNote = "There was expression present in the megakaryocytes." where _Result_key = 1274822
update GXD_InSituResult set resultNote = "There was expression present in the megakaryocytes." where _Result_key = 1275127
update GXD_InSituResult set resultNote = "There was expression present in the megakaryocytes." where _Result_key = 1275403
update GXD_InSituResult set resultNote = "There was expression present in the megakaryocytes." where _Result_key = 1275502
update GXD_InSituResult set resultNote = "There was expression present in the megakaryocytes." where _Result_key = 1275579
update GXD_InSituResult set resultNote = "There was expression present in the megakaryocytes." where _Result_key = 1277363
update GXD_InSituResult set resultNote = "There was expression present in the megakaryocytes." where _Result_key = 1281684
update GXD_InSituResult set resultNote = "There was expression present in the megakaryocytes." where _Result_key = 249109
update GXD_InSituResult set resultNote = "There was expression present in the megakaryocytes." where _Result_key = 249130
update GXD_InSituResult set resultNote = "There was expression present in the megakaryocytes." where _Result_key = 777778
update GXD_InSituResult set resultNote = "There was expression present in the megakaryocytes." where _Result_key = 938657
update GXD_InSituResult set resultNote = "There was expression present in the megakaryocytes." where _Result_key = 938703
update GXD_InSituResult set resultNote = "There was expression present in the megakaryocytes." where _Result_key = 939537
update GXD_InSituResult set resultNote = "There was expression present in the megakaryocytes." where _Result_key = 939769
update GXD_InSituResult set resultNote = "There was expression present in the megakaryocytes." where _Result_key = 940157
update GXD_InSituResult set resultNote = "There was expression present in the megakaryocytes." where _Result_key = 941012
update GXD_InSituResult set resultNote = "There was expression present in the megakaryocytes." where _Result_key = 946688
update GXD_InSituResult set resultNote = "There was expression present in the megakaryocytes." where _Result_key = 949620
update GXD_InSituResult set resultNote = "There was expression present in the megakaryocytes." where _Result_key = 949657
update GXD_InSituResult set resultNote = "There was expression present in the osteoblasts." where _Result_key = 1281150
update GXD_InSituResult set resultNote = "There was expression present in the osteoblasts." where _Result_key = 238353
update GXD_InSituResult set resultNote = "There was expression present in the osteoblasts." where _Result_key = 264665
update GXD_InSituResult set resultNote = "There was expression present in the osteoblasts." where _Result_key = 264666
update GXD_InSituResult set resultNote = "There was expression present in the osteoclasts." where _Result_key = 226623
update GXD_InSituResult set resultNote = "There was expression present in the osteoclasts." where _Result_key = 838324
update GXD_InSituResult set resultNote = "There was expression present in the osteocytes." where _Result_key = 264665
update GXD_InSituResult set resultNote = "There was expression present in the osteocytes." where _Result_key = 264666
update GXD_InSituResult set resultNote = "There was expression present in the platelets." where _Result_key = 946689
update GXD_InSituResult set resultNote = "There was expression present in the white fat adipocytes." where _Result_key = 1273550
update GXD_InSituResult set resultNote = "There was moderate expression in the drainage component." where _Result_key = 273592
update GXD_InSituResult set resultNote = "There was moderate expression in the drainage component." where _Result_key = 277710
update GXD_InSituResult set resultNote = "There was moderate expression in the drainage component." where _Result_key = 277713
update GXD_InSituResult set resultNote = "There was moderate expression in the drainage component." where _Result_key = 277718
update GXD_InSituResult set resultNote = "There was moderate expression in the drainage component." where _Result_key = 439029
update GXD_InSituResult set resultNote = "There was moderate expression in the drainage component." where _Result_key = 439039
update GXD_InSituResult set resultNote = "There was moderate expression in the drainage component." where _Result_key = 523077
update GXD_InSituResult set resultNote = "There was moderate expression in the drainage component." where _Result_key = 523080
update GXD_InSituResult set resultNote = "There was moderate expression in the excretory component." where _Result_key = 269355
update GXD_InSituResult set resultNote = "There was moderate expression in the excretory component." where _Result_key = 270354
update GXD_InSituResult set resultNote = "There was moderate expression in the excretory component." where _Result_key = 270362
update GXD_InSituResult set resultNote = "There was moderate expression in the excretory component." where _Result_key = 270445
update GXD_InSituResult set resultNote = "There was moderate expression in the excretory component." where _Result_key = 270454
update GXD_InSituResult set resultNote = "There was moderate expression in the excretory component." where _Result_key = 270459
update GXD_InSituResult set resultNote = "There was moderate expression in the excretory component." where _Result_key = 270469
update GXD_InSituResult set resultNote = "There was moderate expression in the excretory component." where _Result_key = 270475
update GXD_InSituResult set resultNote = "There was moderate expression in the excretory component." where _Result_key = 270483
update GXD_InSituResult set resultNote = "There was moderate expression in the excretory component." where _Result_key = 270497
update GXD_InSituResult set resultNote = "There was moderate expression in the excretory component." where _Result_key = 270514
update GXD_InSituResult set resultNote = "There was moderate expression in the excretory component." where _Result_key = 270525
update GXD_InSituResult set resultNote = "There was moderate expression in the excretory component." where _Result_key = 270531
update GXD_InSituResult set resultNote = "There was moderate expression in the excretory component." where _Result_key = 270534
update GXD_InSituResult set resultNote = "There was moderate expression in the excretory component." where _Result_key = 273593
update GXD_InSituResult set resultNote = "There was moderate expression in the excretory component." where _Result_key = 448704
update GXD_InSituResult set resultNote = "There was moderate expression in the excretory component." where _Result_key = 448711
update GXD_InSituResult set resultNote = "There was moderate expression in the excretory component." where _Result_key = 478671
update GXD_InSituResult set resultNote = "There was moderate expression in the excretory component." where _Result_key = 478675
update GXD_InSituResult set resultNote = "There was moderate expression in the excretory component." where _Result_key = 478679
update GXD_InSituResult set resultNote = "There was moderate expression in the excretory component." where _Result_key = 478683
update GXD_InSituResult set resultNote = "There was moderate expression in the excretory component." where _Result_key = 478708
update GXD_InSituResult set resultNote = "There was moderate expression in the excretory component." where _Result_key = 478712
update GXD_InSituResult set resultNote = "There was moderate expression in the excretory component." where _Result_key = 478716
update GXD_InSituResult set resultNote = "There was moderate expression in the excretory component." where _Result_key = 478720
update GXD_InSituResult set resultNote = "There was moderate expression in the excretory component." where _Result_key = 478723
update GXD_InSituResult set resultNote = "There was moderate expression in the excretory component." where _Result_key = 629133
update GXD_InSituResult set resultNote = "There was moderate expression in the excretory component." where _Result_key = 661534
update GXD_InSituResult set resultNote = "There was moderate expression in the excretory component." where _Result_key = 661539
update GXD_InSituResult set resultNote = "There was moderate expression in the excretory component." where _Result_key = 661566
update GXD_InSituResult set resultNote = "There was moderate expression in the excretory component." where _Result_key = 661575
update GXD_InSituResult set resultNote = "There was moderate expression in the excretory component." where _Result_key = 661583
update GXD_InSituResult set resultNote = "There was moderate expression in the excretory component." where _Result_key = 661590
update GXD_InSituResult set resultNote = "There was no expression in the acinar cells." where _Result_key = 1238273
update GXD_InSituResult set resultNote = "There was no expression in the acinar cells." where _Result_key = 947503
update GXD_InSituResult set resultNote = "There was no expression in the alpha cells." where _Result_key = 764174
update GXD_InSituResult set resultNote = "There was no expression in the beta cells." where _Result_key = 764168
update GXD_InSituResult set resultNote = "There was no expression in the beta cells." where _Result_key = 764171
update GXD_InSituResult set resultNote = "There was no expression in the megakaryocytes." where _Result_key = 1238274
update GXD_InSituResult set resultNote = "There was no expression in the megakaryocytes." where _Result_key = 1241515
update GXD_InSituResult set resultNote = "There was no expression in the megakaryocytes." where _Result_key = 1242350
update GXD_InSituResult set resultNote = "There was no expression in the megakaryocytes." where _Result_key = 1242381
update GXD_InSituResult set resultNote = "There was no expression in the megakaryocytes." where _Result_key = 1274735
update GXD_InSituResult set resultNote = "There was no expression in the megakaryocytes." where _Result_key = 1274750
update GXD_InSituResult set resultNote = "There was no expression in the megakaryocytes." where _Result_key = 1277419
update GXD_InSituResult set resultNote = "There was no expression in the megakaryocytes." where _Result_key = 1277439
update GXD_InSituResult set resultNote = "There was no expression in the megakaryocytes." where _Result_key = 938907
update GXD_InSituResult set resultNote = "There was no expression in the megakaryocytes." where _Result_key = 939304
update GXD_InSituResult set resultNote = "There was no expression in the megakaryocytes." where _Result_key = 940554
update GXD_InSituResult set resultNote = "There was no expression in the megakaryocytes." where _Result_key = 940619
update GXD_InSituResult set resultNote = "There was no expression in the megakaryocytes." where _Result_key = 940765
update GXD_InSituResult set resultNote = "There was no expression in the megakaryocytes." where _Result_key = 940767
update GXD_InSituResult set resultNote = "There was no expression in the megakaryocytes." where _Result_key = 949883
update GXD_InSituResult set resultNote = "There was no expression in the megakaryocytes." where _Result_key = 949977
update GXD_InSituResult set resultNote = "There was no expression in the osteoblasts." where _Result_key = 238411
update GXD_InSituResult set resultNote = "There was no expression in the osteoclasts." where _Result_key = 236880
update GXD_InSituResult set resultNote = "There was no expression in the osteoclasts." where _Result_key = 759240
update GXD_InSituResult set resultNote = "There was no expression in the osteocytes." where _Result_key = 1281152
update GXD_InSituResult set resultNote = "There was no expression in the osteocytes." where _Result_key = 1281153
update GXD_InSituResult set resultNote = "There was strong expression in the acinar cells." where _Result_key = 139295
update GXD_InSituResult set resultNote = "There was strong expression in the acinar cells." where _Result_key = 230863
update GXD_InSituResult set resultNote = "There was strong expression in the adipocytes." where _Result_key = 1273856
update GXD_InSituResult set resultNote = "There was strong expression in the brown fat adipocytes." where _Result_key = 1273854
update GXD_InSituResult set resultNote = "There was strong expression in the drainage component." where _Result_key = 266738
update GXD_InSituResult set resultNote = "There was strong expression in the drainage component." where _Result_key = 266743
update GXD_InSituResult set resultNote = "There was strong expression in the drainage component." where _Result_key = 485588
update GXD_InSituResult set resultNote = "There was strong expression in the drainage component." where _Result_key = 485594
update GXD_InSituResult set resultNote = "There was strong expression in the drainage component." where _Result_key = 485601
update GXD_InSituResult set resultNote = "There was strong expression in the drainage component." where _Result_key = 485608
update GXD_InSituResult set resultNote = "There was strong expression in the drainage component." where _Result_key = 485613
update GXD_InSituResult set resultNote = "There was strong expression in the drainage component." where _Result_key = 485638
update GXD_InSituResult set resultNote = "There was strong expression in the drainage component." where _Result_key = 485643
update GXD_InSituResult set resultNote = "There was strong expression in the drainage component." where _Result_key = 485648
update GXD_InSituResult set resultNote = "There was strong expression in the drainage component." where _Result_key = 485653
update GXD_InSituResult set resultNote = "There was strong expression in the drainage component." where _Result_key = 485657
update GXD_InSituResult set resultNote = "There was strong expression in the excretory component." where _Result_key = 265424
update GXD_InSituResult set resultNote = "There was strong expression in the excretory component." where _Result_key = 268028
update GXD_InSituResult set resultNote = "There was strong expression in the excretory component." where _Result_key = 268032
update GXD_InSituResult set resultNote = "There was strong expression in the excretory component." where _Result_key = 268042
update GXD_InSituResult set resultNote = "There was strong expression in the excretory component." where _Result_key = 485362
update GXD_InSituResult set resultNote = "There was strong expression in the excretory component." where _Result_key = 534254
update GXD_InSituResult set resultNote = "There was strong expression in the excretory component." where _Result_key = 534259
update GXD_InSituResult set resultNote = "There was strong expression in the excretory component." where _Result_key = 534266
update GXD_InSituResult set resultNote = "There was strong expression in the excretory component." where _Result_key = 534312
update GXD_InSituResult set resultNote = "There was strong expression in the excretory component." where _Result_key = 534319
update GXD_InSituResult set resultNote = "There was strong expression in the excretory component." where _Result_key = 534326
update GXD_InSituResult set resultNote = "There was strong expression in the excretory component." where _Result_key = 534331
update GXD_InSituResult set resultNote = "There was strong expression in the excretory component." where _Result_key = 701423
update GXD_InSituResult set resultNote = "There was strong expression in the excretory component." where _Result_key = 701432
update GXD_InSituResult set resultNote = "There was strong expression in the excretory component." where _Result_key = 701443
update GXD_InSituResult set resultNote = "There was strong expression in the excretory component." where _Result_key = 701492
update GXD_InSituResult set resultNote = "There was strong expression in the excretory component." where _Result_key = 701502
update GXD_InSituResult set resultNote = "There was strong expression in the excretory component." where _Result_key = 701512
update GXD_InSituResult set resultNote = "There was strong expression in the osteoblasts." where _Result_key = 249133
update GXD_InSituResult set resultNote = "There was strong expression in the osteoblasts." where _Result_key = 249136
update GXD_InSituResult set resultNote = "There was very strong expression in the acinar cells." where _Result_key = 231019
update GXD_InSituResult set resultNote = "There was weak expression in the drainage component." where _Result_key = 465563
update GXD_InSituResult set resultNote = "There was weak expression in the drainage component." where _Result_key = 465571
update GXD_InSituResult set resultNote = "There was weak expression in the drainage component." where _Result_key = 465618
update GXD_InSituResult set resultNote = "There was weak expression in the drainage component." where _Result_key = 465628
update GXD_InSituResult set resultNote = "There was weak expression in the drainage component." where _Result_key = 523076
update GXD_InSituResult set resultNote = "There was weak expression in the drainage component." where _Result_key = 523078
update GXD_InSituResult set resultNote = "There was weak expression in the drainage component." where _Result_key = 523079
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 269344
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 269349
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 269362
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 269370
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 269377
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 269407
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 269418
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 269424
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 269427
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 270348
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 270368
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 270400
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 270405
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 270407
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 270414
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 270417
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 270424
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 270489
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 270645
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 270657
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 270674
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 270760
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 270770
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 270787
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 270804
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 270821
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 270829
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 270930
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 270932
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 270933
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 270937
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 270954
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 270955
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 270959
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 270960
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 270963
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 270965
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 610109
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 610115
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 610120
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 610125
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 610128
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 610130
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 610138
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 610142
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 610147
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 610151
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 610155
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 610158
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 620323
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 620324
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 620325
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 620326
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 620327
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 627240
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 627241
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 627242
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 627243
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 629135
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 629136
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 629138
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 629172
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 629179
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 656226
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 656240
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 656251
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 656310
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 656321
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 656332
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 656341
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 661519
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 661526
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 662244
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 662253
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 662262
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 662271
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 662321
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 662330
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 662339
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 662348
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 662358
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 662653
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 662666
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 662683
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 662765
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 662781
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 662789
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 662796
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 662800
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 663456
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 663459
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 663463
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 663468
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 663506
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 663512
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 663520
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 663525
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 663529
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 670684
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 670686
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 670701
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 670703
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 693428
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 693430
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 693432
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 693435
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 693438
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 693457
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 693464
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 693467
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 693469
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 696946
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 696949
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 696954
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 696958
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 696986
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 696990
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 696994
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 696996
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 696998
update GXD_InSituResult set resultNote = "There was weak expression in the excretory component." where _Result_key = 697000
update GXD_InSituResult set resultNote = "Weak staining in chondrocytes is observed with 24 hours of 4-OH tamoxifen treatment." where _Result_key = 763847
go

EOSQL
date | tee -a ${LOG}

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}
