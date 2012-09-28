#!/bin/csh -f


if ( ${?MGICONFIG} == 0 ) then
        setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date | tee -a $LOG

date | tee -a ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use $MGD_DBNAME
go

/* update old TIGM sequences with per spec in TR10911 */

/* old TIGM, VE=3983010, strand='+' */
select sgt._Sequence_key
into #toupdate1
from SEQ_GeneTrap sgt, ACC_Accession a, MAP_Coord_Feature mcf
where a._LogicalDB_key = 97
and a._MGIType_key = 19
and sgt._VectorEnd_key = 3983010
and sgt.creation_date <= '8/12/2009'
and a._Object_key = sgt._Sequence_key
and sgt._Sequence_key = mcf._Object_key
and mcf._MGIType_key = 19
and strand = '+'
go

/* old TIGM, VE=3983010, strand='-' */
select sgt._Sequence_key
into #toupdate2
from SEQ_GeneTrap sgt, ACC_Accession a, MAP_Coord_Feature mcf
where a._LogicalDB_key = 97
and a._MGIType_key = 19
and sgt._VectorEnd_key = 3983010
and sgt.creation_date <= '8/12/2009'
and a._Object_key = sgt._Sequence_key
and sgt._Sequence_key = mcf._Object_key
and mcf._MGIType_key = 19
and strand = '-'
go

update MAP_Coord_Feature
set strand = '-'
from #toupdate1 t, MAP_Coord_Feature mcf
where t._Sequence_key = mcf._Object_key
and mcf._MGIType_key = 19
go

update MAP_Coord_Feature
set strand = '+'
from #toupdate2 t, MAP_Coord_Feature mcf
where t._Sequence_key = mcf._Object_key
and mcf._MGIType_key = 19
go

checkpoint
go

end

EOSQL

date |tee -a $LOG

