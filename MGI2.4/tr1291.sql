#!/bin/csh -f

#
# Migration for TR 1291
#

setenv SYBASE   /opt/sybase
set path = ($path $SYBASE/bin)

setenv DSQUERY	$1
setenv MGD	$2
setenv NOMEN	$3

setenv LOG $0.log

rm -rf $LOG
touch $LOG
 
date >> $LOG
 
set scripts = $SYBASE/admin

set sql = /tmp/$$.sql
 
cat > $sql << EOSQL
 
/* Nomen */

use $NOMEN
go

drop trigger MRK_Nomen_Update
go

/* set broadcastToMGD */

update MRK_Nomen_Reference
set broadcastToMGD = 1
where isPrimary = 1
go

/* set broadcast user to ljm */

update MRK_Nomen
set _Suid_broadcast_key = 39
where _Marker_Status_key = 5
go

/* set all non-tier 3, tier 4 users to retired_editors */

update MRK_Nomen
set _Suid_key = 86
where _Suid_key not in (8,17,39,47,48,81,88,91)
go

checkpoint
go

/* MGD */

use $MGD
go

drop trigger MRK_Marker_Update
go

/* set non-mouse status to n/a */

update MRK_Marker
set _Marker_Status_key = -2
where _Species_key != 1
go

/* set all mouse ! W = 1 */

update MRK_Marker
set _Marker_Status_key = 1
where _Species_key = 1
and _Marker_Status_key = -1
and chromosome != "W"
go

/* set all status/chromosomes */

update MRK_Marker
set chromosome = m2.chromosome, _Marker_Status_key = 2
from MRK_Marker m, MRK_Current c, MRK_Marker m2
where m._Species_key = 1
and m.chromosome = "W"
and m._Marker_key = c._Marker_key
and c._Current_key = m2._Marker_key
go

update MRK_Marker
set _Marker_Status_key = 2, chromosome = "9"
where _Marker_key = 9992
go

update MRK_Marker
set _Marker_Status_key = 2, chromosome = "8"
where _Marker_key = 8611
go

update MRK_Marker
set _Marker_Status_key = 2, chromosome = "6"
where _Marker_key = 9117
go

update MRK_Marker
set _Marker_Status_key = 2, chromosome = "17"
where _Marker_key = 9340
go

update MRK_Marker
set _Marker_Status_key = 2, chromosome = "17"
where _Marker_key = 9341
go

update MRK_Marker
set _Marker_Status_key = 2, chromosome = "17"
where _Marker_key = 9400
go

update MRK_Marker
set _Marker_Status_key = 2, chromosome = "9"
where _Marker_key = 9996
go

update MRK_Marker
set _Marker_Status_key = 2, chromosome = "X"
where _Marker_key = 14063
go

update MRK_Marker
set _Marker_Status_key = 2, chromosome = "Y"
where _Marker_key = 14071
go

update MRK_Marker
set _Marker_Status_key = 2, chromosome = "UN"
where _Marker_key = 14868
go

/* should be no more chromosome "W" in database */

select symbol, _Marker_key, chromosome from MRK_Marker where chromosome = "W"
go

/* Events and Event Reasons */

update MRK_History
set _Marker_Event_key = 1
from MRK_History_Temp h, MRK_History h1
where h._Marker_key = h1._Marker_key
and h.sequenceNum = h1.sequenceNum
and h.note in ("Assigned", "Re-Assigned")
go

/* allele ofs */

update MRK_History
set _Marker_Event_key = 4
from MRK_History_Temp h, MRK_History h1
where h._Marker_key = h1._Marker_key
and h.sequenceNum = h1.sequenceNum
and h.note like "withdrawn, allele of%"
go

/* splits */

update MRK_History
set _Marker_Event_key = 5
from MRK_History_Temp h, MRK_History h1
where h._Marker_key = h1._Marker_key
and h.sequenceNum = h1.sequenceNum
and h.note like "withdrawn, =%,%"
go

/* deleted */

update MRK_History
set _Marker_Event_key = 6
from MRK_History_Temp h, MRK_History h1
where h._Marker_key = h1._Marker_key
and h.sequenceNum = h1.sequenceNum
and h.note = "withdrawn"
go

/* all unspecified -> withdrawn */

update MRK_History
set _Marker_Event_key = 2
from MRK_History_Temp h, MRK_History h1
where h._Marker_key = h1._Marker_key
and h.sequenceNum = h1.sequenceNum
and h.note like "withdrawn%"
and h1._Marker_Event_key = -1
go

/* should be no unspecified events */

select * from MRK_History where _Marker_Event_key = -1
go

checkpoint
go

quit
 
EOSQL
 
$scripts/dbo_sql $sql
rm $sql
 
date >> $LOG
