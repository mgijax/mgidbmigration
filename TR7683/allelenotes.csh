#!/bin/csh -f

#
# TR Migration "Normal" MP Annotation Notes to new Note Type
#
# Usage:  alleletype.csh
#

source ../Configuration

setenv LOG `basename $0`.log

rm -rf ${LOG}
touch ${LOG}
 
date >> ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

/* select all MP terms that are headers */

select d._Object_key, t.term
into #headers
from DAG_Node d, VOC_Term t
where d._DAG_key = 4
and d._Label_key = 3
and d._Object_key = t._Term_key
go

create index idx1 on #headers(_Object_key)
go

/* select all notes for annotations to header terms */

select h.term, a._Annot_key, n._Note_key
into #toupdate
from #headers h, VOC_Annot a, VOC_Evidence e, MGI_Note n
where h._Object_key = a._Term_key
and a._AnnotType_key = 1002
and a._Annot_key = e._Annot_key
and e._AnnotEvidence_key = n._Object_key
and n._NoteType_key = 1008
go

create index idx1 on #toupdate(_Annot_key)
create index idx2 on #toupdate(_Note_key)
go

/* update Note Type to new Normal note */

update MGI_Note
set _NoteType_key = 1031
from #toupdate u, MGI_Note n
where u._Note_key = n._Note_key
go

/* update Qualifier */

update VOC_Annot
set _Qualifier_key = 2181424
from #toupdate u, VOC_Annot a
where u._Annot_key = a._Annot_key
go

EOSQL

date >> ${LOG}

