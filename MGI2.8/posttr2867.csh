#!/bin/csh -f

#
# Post-Migration for TR 2867
#

cd `dirname $0`

setenv DBSERVER $1
setenv DBNAME $2

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date >> $LOG
 
cat - <<EOSQL | doisql.csh $0 >> $LOG

use $DBNAME
go

/* For any object where all 3 annotations are to unknown terms */
/* and the references are the same... */
/* make the reference a NO-GO reference */
/* note that the original J: for unknowns is stored in VOC_Evidence.notes */

declare @u1Key integer
declare @u2Key integer
declare @u3Key integer
select @u1Key = _Object_key from ACC_Accession where accid = "GO:0000004"
select @u2Key = _Object_key from ACC_Accession where accid = "GO:0008372"
select @u3Key = _Object_key from ACC_Accession where accid = "GO:0005554"

select a._Annot_key, a._Object_key, a._Term_key, jnum = substring(e.notes, 1, 30)
into #annot1
from VOC_Annot a, VOC_Evidence e
where a._AnnotType_key = 1000
and a._Term_key in (@u1Key, @u2Key, @u3Key)
and a._Annot_key = e._Annot_key
go

select *
into #annot2
from #annot1
group by _Object_key, jnum having count(*) = 3
go

select distinct jnum from #annot2
go

select distinct a._Object_key
into #annot3
from #annot2 n, ACC_Accession a
where n.jnum = a.accID
go

update BIB_Refs
set dbs = dbs + "/GO*"
from #annot3 n, BIB_Refs r
where n._Object_key = r._Refs_key
go

EOSQL

date >> $LOG

