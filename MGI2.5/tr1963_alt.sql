#!/bin/csh -f

#
# Migration for TR 1963
#

setenv SYBASE   /opt/sybase

setenv DSQUERY	 $1
setenv DATABASE	$2
setenv DBUSER mgd_dbo
setenv DBPASSWORD $SYBASE/admin/.mgd_dbo_password

setenv TABLES "CRS_Matrix MLC_Marker MLC_Marker_edit MLC_Lock_edit MLC_Reference MLC_Reference_edit PRB_Strain_Marker RI_RISet RI_Summary_Expt_Ref RI_Summary ACC_AccessionReference"

setenv BCPDIR /extra2/sybase/data

setenv LOG $0.log

set scripts = $SYBASE/admin

rm -rf $LOG
touch $LOG
 
date >> $LOG
 
set sql = /tmp/$$.sql

cat > $sql <<EOSQL

sp_dboption $DATABASE, "select into", true
go

use $DATABASE
go

checkpoint
go

EOSQL

cat $DBPASSWORD | isql -S$DSQUERY -U$DBUSER -i $sql

foreach i ($TABLES)
cat $DBPASSWORD | bcp $DATABASE..$i out $BCPDIR/$i.bcp -S$DSQUERY -U$DBUSER -c -t"&=&" -r"#=#\n"
end

cat > $sql <<EOSQL

use $DATABASE
go

drop table CRS_Matrix
go

drop table MLC_Lock_edit
go

drop table MLC_Marker
go

drop table MLC_Marker_edit
go

drop table MLC_Reference
go

drop table MLC_Reference_edit
go

drop table PRB_Strain_Marker
go

drop table RI_RISet
go

drop table RI_Summary
go

drop table RI_Summary_Expt_Ref
go

drop table ACC_AccessionReference
go

checkpoint
go

create table CRS_Matrix (
        _Cross_key int not null,
        _Marker_key int null,
        otherSymbol varchar ( 20 ) null,
        chromosome varchar ( 8 ) not null,
        rowNumber int not null,
        notes varchar ( 255 ) null,
        creation_date datetime not null,
        modification_date datetime not null 
)
on mgd_seg_0 
go

create table MLC_Lock_edit (
        time datetime not null,
        _Marker_key int not null,
        checkedOut bit not null,
        creation_date datetime not null,
        modification_date datetime not null
)
 on mgd_seg_0
go

create table MLC_Marker (
        _Marker_key int not null,
        tag int not null,
        _Marker_key_2 int not null,
        creation_date datetime not null,
        modification_date datetime not null 
)
 on mgd_seg_0 
go

create table MLC_Marker_edit (
        _Marker_key int not null,
        tag int not null,
        _Marker_key_2 int not null,
        creation_date datetime not null,
        modification_date datetime not null 
)
 on mgd_seg_0 
go

create table MLC_Reference (
        _Marker_key int not null,
        _Refs_key int not null,
        tag int not null,
        creation_date datetime not null,
        modification_date datetime not null 
)
 on mgd_seg_0 
go

create table MLC_Reference_edit (
        _Marker_key int not null,
        _Refs_key int not null,
        tag int not null,
        creation_date datetime not null,
        modification_date datetime not null
)
 on mgd_seg_0
go

create table PRB_Strain_Marker (
        _Strain_key int not null,
        _Marker_key int not null,
        creation_date datetime not null,
        modification_date datetime not null
)
 on mgd_seg_0
go

create table RI_RISet (
        _RISet_key int not null,
        origin varchar ( 35 ) not null,
        designation varchar ( 15 ) not null,
        abbrev1 varchar ( 4 ) not null,
        abbrev2 varchar ( 4 ) not null,
        RI_IdList varchar ( 255 ) not null,
        creation_date datetime not null,
        modification_date datetime not null
)
 on mgd_seg_0
go

create table RI_Summary (
        _RISummary_key int not null,
        _RISet_key int not null,
        _Marker_key int not null,
        summary varchar ( 255 ) not null,
        creation_date datetime not null,
        modification_date datetime not null
)
 on mgd_seg_0
go

create table RI_Summary_Expt_Ref (
        _RISummary_key int not null,
        _Expt_key int not null,
        _Refs_key int not null,
        creation_date datetime not null,
        modification_date datetime not null
)
 on mgd_seg_0
go

create table ACC_AccessionReference (
        _Accession_key int not null,
        _Refs_key int not null,
        creation_date datetime not null,
        modification_date datetime not null,
        release_date datetime null
)
 on mgd_seg_0
go

checkpoint
go

EOSQL

cat $DBPASSWORD | isql -S$DSQUERY -U$DBUSER -i $sql

foreach i ($TABLES)
cat $DBPASSWORD | bcp $DATABASE..$i in $BCPDIR/$i.bcp -S$DSQUERY -U$DBUSER -c -e $i.err -t"&=&" -r"#=#\n"
end

cat > $sql <<EOSQL

use $DATABASE
go

/* defaults */

exec sp_bindefault current_date_default, "CRS_Matrix.creation_date"
go

exec sp_bindefault current_date_default, "CRS_Matrix.modification_date"
go

exec sp_bindefault current_date_default, "MLC_Lock_edit.creation_date"
go

exec sp_bindefault current_date_default, "MLC_Lock_edit.modification_date"
go

exec sp_bindefault current_date_default, "MLC_Marker.creation_date"
go

exec sp_bindefault current_date_default, "MLC_Marker.modification_date"
go

exec sp_bindefault current_date_default, "MLC_Marker_edit.creation_date"
go

exec sp_bindefault current_date_default, "MLC_Marker_edit.modification_date"
go

exec sp_bindefault current_date_default, "MLC_Reference.creation_date"
go

exec sp_bindefault current_date_default, "MLC_Reference.modification_date"
go

exec sp_bindefault current_date_default, "MLC_Reference_edit.creation_date"
go

exec sp_bindefault current_date_default, "MLC_Reference_edit.modification_date"
go

exec sp_bindefault current_date_default, "PRB_Strain_Marker.creation_date"
go

exec sp_bindefault current_date_default, "PRB_Strain_Marker.modification_date"
go

exec sp_bindefault current_date_default, "RI_Summary.creation_date"
go

exec sp_bindefault current_date_default, "RI_Summary.modification_date"
go

exec sp_bindefault current_date_default, "RI_Summary_Expt_Ref.creation_date"
go

exec sp_bindefault current_date_default, "RI_Summary_Expt_Ref.modification_date"
go

exec sp_bindefault current_date_default, "ACC_AccessionReference.creation_date"
go

exec sp_bindefault current_date_default, "ACC_AccessionReference.modification_date"
go

exec sp_bindefault current_date_default, "ACC_AccessionReference.release_date"
go

/* keys */

sp_primarykey CRS_Matrix,_Cross_key, rowNumber
go

sp_primarykey MLC_Lock_edit,time, _Marker_key
go

sp_primarykey MLC_Marker,_Marker_key, _Marker_key_2
go

sp_primarykey MLC_Marker_edit,_Marker_key, _Marker_key_2
go

sp_primarykey MLC_Reference,_Marker_key, _Refs_key
go

sp_primarykey MLC_Reference_edit,_Marker_key, _Refs_key, tag
go

sp_primarykey PRB_Strain_Marker,_Strain_key, _Marker_key
go

sp_primarykey RI_RISet,_RISet_key
go

sp_primarykey RI_Summary,_RISummary_key
go

sp_primarykey RI_Summary_Expt_Ref,_RISummary_key, _Expt_key
go

sp_primarykey ACC_AccessionReference,_Accession_key, _Refs_key
go

sp_foreignkey CRS_Matrix, CRS_Cross, _Cross_key
go

sp_foreignkey CRS_Typings, CRS_Matrix, _Cross_key, rowNumber
go

sp_foreignkey MLC_Lock_edit, MLC_Text_edit, _Marker_key
go

sp_foreignkey MLC_Reference_edit, MLC_Text_edit, _Marker_key
go

sp_foreignkey MLC_Marker_edit, MLC_Text_edit, _Marker_key
go

sp_foreignkey MLC_Reference, MLC_Text, _Marker_key
go

sp_foreignkey MLC_Marker, MLC_Text, _Marker_key
go

sp_foreignkey PRB_Strain_Marker, PRB_Strain, _Strain_key
go

sp_foreignkey RI_Summary_Expt_Ref, BIB_Refs, _Refs_key
go

sp_foreignkey RI_Summary_Expt_Ref, MLD_RI, _Expt_key
go

sp_foreignkey ACC_AccessionReference, ACC_Accession, _Accession_key
go

sp_foreignkey ACC_AccessionReference, BIB_Refs, _Refs_key
go

/* indexes */

create unique clustered  index index_Cross_Marker_key on CRS_Matrix ( _Cross_key, _Marker_key, otherSymbol, chromosome, rowNumber ) with sorted_data on mgd_seg_0
go

create nonclustered  index index_modification_date on CRS_Matrix ( modification_date ) on mgd_seg_1
go

create nonclustered  index index_Marker_key on CRS_Matrix ( _Marker_key ) on mgd_seg_1
go

create nonclustered  index index_Cross_key on CRS_Matrix ( _Cross_key ) on mgd_seg_1
go

create unique clustered  index index_Marker_time on MLC_Lock_edit ( _Marker_key, time ) with sorted_data on mgd_seg_0
go

create unique nonclustered  index index_time on MLC_Lock_edit ( time ) on mgd_seg_1
go

create nonclustered  index index_modification_date on MLC_Lock_edit ( modification_date ) on mgd_seg_1
go

create nonclustered  index index_Marker_key on MLC_Lock_edit ( _Marker_key ) on mgd_seg_1
go

create unique clustered  index index_Marker_tag_key on MLC_Marker ( _Marker_key, _Marker_key_2, tag ) with sorted_data on mgd_seg_0
go

create nonclustered  index index_modification_date on MLC_Marker ( modification_date ) on mgd_seg_1
go

create nonclustered  index index_Marker_key_2 on MLC_Marker ( _Marker_key_2 ) on mgd_seg_1
go

create nonclustered  index index_Marker_key on MLC_Marker ( _Marker_key ) on mgd_seg_1
go

create unique clustered  index index_Marker_tag_key on MLC_Marker_edit ( _Marker_key, _Marker_key_2, tag ) on mgd_seg_0
go

create nonclustered  index index_Marker_key on MLC_Marker_edit ( _Marker_key ) on mgd_seg_1
go

create nonclustered  index index_modification_date on MLC_Marker_edit ( modification_date ) on mgd_seg_1
go

create nonclustered  index index_Marker_key_2 on MLC_Marker_edit ( _Marker_key_2 ) on mgd_seg_1
go

create unique clustered  index index_Marker_Refs_tag_key on MLC_Reference ( _Marker_key, _Refs_key, tag ) with sorted_data on mgd_seg_0
go

create nonclustered  index index_modification_date on MLC_Reference ( modification_date ) on mgd_seg_1
go

create nonclustered  index index_Refs_key on MLC_Reference ( _Refs_key ) on mgd_seg_1
go

create nonclustered  index index_Marker_key on MLC_Reference ( _Marker_key ) on mgd_seg_1
go

create unique clustered  index index_Marker_Refs_key on MLC_Reference_edit ( _Marker_key, _Refs_key, tag ) with sorted_data on mgd_seg_0
go

create nonclustered  index index_modification_date on MLC_Reference_edit ( modification_date ) on mgd_seg_1
go

create nonclustered  index index_Refs_key on MLC_Reference_edit ( _Refs_key ) on mgd_seg_1
go

create nonclustered  index index_Marker_key on MLC_Reference_edit ( _Marker_key ) on mgd_seg_1
go

create unique clustered  index index_Strain_Marker_keys on PRB_Strain_Marker ( _Strain_key, _Marker_key ) with sorted_data on mgd_seg_0
go

create nonclustered  index index_Strain_key on PRB_Strain_Marker ( _Strain_key ) on mgd_seg_1
go

create nonclustered  index index_Marker_key on PRB_Strain_Marker ( _Marker_key ) on mgd_seg_1
go

create nonclustered  index index_modification_date on PRB_Strain_Marker ( modification_date ) on mgd_seg_1
go

create unique clustered  index index_RISet_key on RI_RISet ( _RISet_key ) with sorted_data on mgd_seg_0
go

create unique nonclustered  index index_designation on RI_RISet ( designation ) on mgd_seg_1
go

create nonclustered  index index_modification_date on RI_RISet ( modification_date ) on mgd_seg_1
go

create unique clustered  index index_RISummary_key on RI_Summary ( _RISummary_key ) with sorted_data on mgd_seg_0
go

create nonclustered  index index_modification_date on RI_Summary ( modification_date ) on mgd_seg_1
go

create nonclustered  index index_RIset_fkey on RI_Summary ( _RISet_key ) on mgd_seg_1
go

create nonclustered  index index_Marker_key on RI_Summary ( _Marker_key ) on mgd_seg_1
go

create unique clustered  index index_Expt_RI_key on RI_Summary_Expt_Ref ( _RISummary_key, _Expt_key ) with sorted_data on mgd_seg_0
go

create nonclustered  index index_RISummary_fkey on RI_Summary_Expt_Ref ( _RISummary_key ) on mgd_seg_1
go

create nonclustered  index index_Expt_key on RI_Summary_Expt_Ref ( _Expt_key ) on mgd_seg_1
go

create nonclustered  index index_modification_date on RI_Summary_Expt_Ref ( modification_date ) on mgd_seg_1
go

create nonclustered  index index_Refs_key on RI_Summary_Expt_Ref ( _Refs_key ) on mgd_seg_1
go

create unique clustered  index index_Acc_Refs_key on ACC_AccessionReference ( _Accession_key, _Refs_key ) with sorted_data on mgd_seg_0
go

create nonclustered  index index_Accession_key on ACC_AccessionReference ( _Accession_key ) on mgd_seg_1
go

create nonclustered  index index_modification_date on ACC_AccessionReference ( modification_date ) on mgd_seg_1
go

create nonclustered  index index_Refs_key on ACC_AccessionReference ( _Refs_key ) on mgd_seg_1
go

EOSQL

cat $DBPASSWORD | isql -S$DSQUERY -U$DBUSER -i $sql

rm $sql

date >> $LOG
