#!/bin/csh -f

#
# New values for ACC_MGIType
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date >> $LOG
echo "ACC MGI Type Migration..." | tee -a $LOG
 
cat - <<EOSQL | doisql.csh $0 >> $LOG

use $DBNAME
go

insert into ACC_MGIType 
values (18, 'Orthology', 'HMD_Class', '_Class_key', null, null, getdate(), getdate(), getdate())
go

insert into ACC_MGIType 
values (19, 'Sequence', 'SEQ_Sequence', '_Sequence_key', null, null, getdate(), getdate(), getdate())
go

insert into ACC_MGIType 
values (20, 'Organism', 'MGI_Organism', '_Organism_key', 'commonName', 'MGI_Organism_Summary_View', getdate(), getdate(), getdate())
go

insert into ACC_MGIType 
values (21, 'Nomenclature', 'NOM_Marker', '_Nomen_key', 'symbol', null, getdate(), getdate(), getdate())
go

checkpoint
go

quit

EOSQL

date >> $LOG

