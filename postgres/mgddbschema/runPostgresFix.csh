#!/bin/csh -f

#
# Template
#
# mgddbschema-4-3-2-5
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

drop index PRB_Strain_Marker.idx_Qualifer_key
go

create nonclustered index idx_Qualifier_key on PRB_Strain_Marker (_Qualifier_key) on seg1
go

checkpoint
go

end

EOSQL

date |tee -a $LOG

