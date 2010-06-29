#!/bin/csh -f

#
# Template
#

#setenv MGICONFIG /usr/local/mgi/live/mgiconfig
#setenv MGICONFIG /usr/local/mgi/test/mgiconfig
#source ${MGICONFIG}/master.config.csh

cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date | tee -a $LOG
 
cat - <<EOSQL | doisql.csh $MGD_DBSERVER $MGD_DBNAME $0 | tee -a $LOG

use $MGD_DBNAME
go

select m.symbol
from MRK_Marker m, MRK_Offset o
where m._Marker_key = o._Marker_key
and o.source = 0
and o.offset >= -1
and m._Marker_Status_key in (1,3)
and m.chromosome = 'UN'
go

update MRK_Offset 
set offset = -999
from MRK_Marker m, MRK_Offset o
where m._Marker_key = o._Marker_key
and o.source = 0
and o.offset >= -1
and m._Marker_Status_key in (1,3)
and m.chromosome = 'UN'
go

select m.symbol
from MRK_Marker m, MRK_Offset o
where m._Marker_key = o._Marker_key
and o.source = 0
and o.offset = -999
and m._Marker_Status_key in (1,3)
and m.chromosome != 'UN'
go

update MRK_Offset
set offset = -1
from MRK_Marker m, MRK_Offset o
where m._Marker_key = o._Marker_key
and o.source = 0
and o.offset = -999
and m._Marker_Status_key in (1,3)
and m.chromosome != 'UN'
go

checkpoint
go

end

EOSQL

date |tee -a $LOG

