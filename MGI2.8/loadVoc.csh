#!/bin/csh -f

#
# Load VOC structures
#

cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date >> $LOG
 
# Load VOC tables

cd /home/lec/loads/simplevocload
./simplevocload.csh ${DBSERVER} ${DBNAME} phenoslim.out PhenoSlim 72460 P
./simplevocload.csh ${DBSERVER} ${DBNAME} go.ecodes "GO Evidence Codes" 73041 N
./simplevocload.csh ${DBSERVER} ${DBNAME} ps.ecodes "PhenoSlim Evidence Codes" 72460 N

cat - <<EOSQL | doisql.csh $0 >> $LOG

use $DBNAME
go

insert into VOC_AnnotType
values(1000,2,1003,1001,"GO/Marker", getdate(), getdate())
go

insert into VOC_AnnotType
values(1001,12,1000,1002,"PhenoSlim/Genotype", getdate(), getdate())
go

EOSQL

cd /home/lec/loads/annotload
./phenoslimgenotype.csh pslim.csmith.tab csmith new
./phenoslimgenotype.csh pslim.cwg.tab cwg append
./phenoslimgenotype.csh pslim.il.tab il append

date >> $LOG

