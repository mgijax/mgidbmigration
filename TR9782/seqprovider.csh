#!/bin/csh -f

#
# TR9774 reorder sequences provider vocabulary terms
#
# Usage: seqprovider.csh
#

source ../Configuration

setenv LOG `basename $0`.log

rm -rf ${LOG}
touch ${LOG}
 
date >> ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

update VOC_Term set sequenceNum = 5 where _Term_key = 316372
go
update VOC_Term set sequenceNum = 6 where _Term_key = 316373
go
update VOC_Term set sequenceNum = 7 where _Term_key = 316374
go
update VOC_Term set sequenceNum = 8 where _Term_key = 316375
go
update VOC_Term set sequenceNum = 9 where _Term_key = 316376
go
update VOC_Term set sequenceNum = 10 where _Term_key = 316377
go
update VOC_Term set sequenceNum = 11 where _Term_key = 316378
go
update VOC_Term set sequenceNum = 12 where _Term_key = 316379
go
update VOC_Term set sequenceNum = 13  where _Term_key = 492451
go
update VOC_Term set sequenceNum = 14 where _Term_key = 3311121
go
update VOC_Term set sequenceNum = 15 where _Term_key = 316380
go
update VOC_Term set sequenceNum = 16 where _Term_key = 1865333
go
update VOC_Term set sequenceNum = 17 where _Term_key = 615429
go
update VOC_Term set sequenceNum = 18 where _Term_key = 706915
go
update VOC_Term set sequenceNum = 19 where _Term_key = 316381
go
update VOC_Term set sequenceNum = 20 where _Term_key = 316382
go
update VOC_Term set sequenceNum = 21 where _Term_key = 316383
go
update VOC_Term set sequenceNum = 22 where _Term_key = 316384
go
update VOC_Term set sequenceNum = 23 where _Term_key = 316385
go
update VOC_Term set sequenceNum = 3 where _Term_key = 5112894
go
update VOC_Term set sequenceNum = 1 where _Term_key = 5112895
go
update VOC_Term set sequenceNum = 4 where _Term_key = 5112896
go
update VOC_Term set sequenceNum = 2 where _Term_key = 5112897
go

EOSQL

date >> ${LOG}

