#!/bin/csh -f

#
# Template
#

setenv MGICONFIG /usr/local/mgi/live/mgiconfig
#setenv MGICONFIG /usr/local/mgi/test/mgiconfig
source ${MGICONFIG}/master.config.csh

cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date | tee -a $LOG
 
cat - <<EOSQL | doisql.csh $MGD_DBSERVER $MGD_DBNAME $0 | tee -a $LOG

use $RADAR_DBNAME
go

select m.*
into #toDelete
from APP_FilesProcessed m
where not exists (select 1 from APP_FilesMirrored p where m._File_key > = p._File_key)
go

select * from #toDelete
go

delete APP_FilesProcessed 
from #toDelete d, APP_FilesProcessed a
where d._File_key = a._File_key
go

drop table #toDelete
go


select * from APP_FilesProcessed where _File_key = 12011
go

delete from APP_FilesProcessed where _File_key = 12011
go


select * 
into #toDelete
from QC_SEQ_Merged r where not exists (select 1 from APP_JobStream j where r._jobstream_key = j._jobstream_key)
go

select * from #toDelete
go

delete QC_SEQ_Merged
from #toDelete d, QC_SEQ_Merged a
where d._jobstream_key = a._jobstream_key
go

drop table #toDelete
go

checkpoint
go

end

EOSQL

date |tee -a $LOG

