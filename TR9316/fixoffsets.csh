#!/bin/csh -f

#
# Fix some offsets
#

source ../Configuration

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date | tee -a $LOG
 
cat - <<EOSQL | doisql.csh $MGD_DBSERVER $MGD_DBNAME $0 | tee -a $LOG

use $MGD_DBNAME
go

/* offset for UN was set to -1; should be -999 */

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

/* offset for non-UN was set to -999; should be -1 */

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

