use nomen_dev
go

execute sp_unbindefault "MRK_Nomen.creation_date"
go


execute sp_unbindefault "MRK_Nomen.modification_date"
go

      
      /*
      CHANGE REPORT for Table MRK_Nomen
          - Dropping column ECNumber
          WARNING : Recreating Table MRK_Nomen based on the ERwin source model. Any properties not selected for sync will be recreated based on the ERwin source model.
      ACTION is DROP and CREATE Table MRK_Nomen
          - Data will be copied to table MRK_NomenJ9284559000 ,or table will be renamed MRK_NomenJ9284559000..
          - Temp table will be dropped if load data statement is successful.
      IMPACT ANALYSIS REPORT for DROP and CREATE Table MRK_Nomen
          - default current_date_default needs to be rebound to column. MRK_Nomen.creation_date 
          - default current_date_default needs to be rebound to column. MRK_Nomen.modification_date 
          - Following views were found referencing table MRK_Nomen:
                dbo.MRK_Nomen_View
                dbo.MRK_Nomen_Marker_View
                dbo.MRK_Nomen_Homology_View
                dbo.MRK_Nomen_AccNoRef_View
          - Following procedures were found referencing table MRK_Nomen:
                dbo.NOMEN_verifyMarker
                dbo.NOMEN_updateBroadcastStatus
          - Following triggers were found referencing table MRK_Nomen:
                dbo.MRK_Nomen_Update
                dbo.MRK_Nomen_Delete
      */

execute sp_rename MRK_Nomen,MRK_NomenJ9284559000
go


CREATE TABLE MRK_Nomen (
       _Nomen_key           int NOT NULL,
       _Marker_Type_key     int NOT NULL,
       _Marker_Status_key   int NOT NULL,
       _Marker_Event_key    int NOT NULL,
       _Suid_key            int NOT NULL,
       proposedSymbol       varchar(25) NOT NULL,
       proposedName         varchar(255) NULL,
       approvedSymbol       varchar(25) NOT NULL,
       approvedName         varchar(255) NOT NULL,
       chromosome           varchar(8) NOT NULL,
       humanSymbol          varchar(25) NULL,
       statusNote           varchar(255) NULL,
       broadcast_date       datetime NULL,
       creation_date        datetime NOT NULL,
       modification_date    datetime NOT NULL
)
go

CREATE INDEX index_modification_date ON MRK_Nomen
(
       modification_date
)
go

CREATE INDEX _Marker_Status_key_Index ON MRK_Nomen
(
       _Marker_Status_key
)
go

CREATE INDEX _Marker_event_Index ON MRK_Nomen
(
       _Marker_Event_key
)
go

CREATE INDEX index_Suid_key ON MRK_Nomen
(
       _Suid_key
)
go

CREATE INDEX _Marker_type_Index ON MRK_Nomen
(
       _Marker_Type_key
)
go

CREATE INDEX index_proposedSymbol ON MRK_Nomen
(
       proposedSymbol
)
go

CREATE INDEX index_approvedSymbol ON MRK_Nomen
(
       approvedSymbol
)
go

CREATE INDEX index_chromosome ON MRK_Nomen
(
       chromosome
)
go

CREATE INDEX index_broadcast_date ON MRK_Nomen
(
       broadcast_date
)
go


ALTER TABLE MRK_Nomen
       ADD PRIMARY KEY (_Nomen_key)
go

exec sp_primarykey MRK_Nomen,
       _Nomen_key
go

exec sp_bindefault current_date_default, 'MRK_Nomen.creation_date'
exec sp_bindefault current_date_default, 'MRK_Nomen.modification_date'
go

INSERT INTO MRK_Nomen (_Nomen_key, _Marker_Type_key, _Marker_Status_key, 
    _Marker_Event_key, _Suid_key, proposedSymbol, proposedName, approvedSymbol, 
    approvedName, chromosome, humanSymbol, statusNote, broadcast_date, 
    creation_date, modification_date) SELECT _Nomen_key, _Marker_Type_key, 
    _Marker_Status_key, _Marker_Event_key, _Suid_key, proposedSymbol, 
    proposedName, approvedSymbol, approvedName, chromosome, humanSymbol, 
    statusNote, broadcast_date, creation_date, modification_date FROM 
    MRK_NomenJ9284559000

go


DROP TABLE MRK_NomenJ9284559000
go


ALTER TABLE MRK_Nomen
       ADD FOREIGN KEY (_Marker_Event_key)
                             REFERENCES MRK_Event
go


ALTER TABLE MRK_Nomen
       ADD FOREIGN KEY (_Marker_Status_key)
                             REFERENCES MRK_Status
go


exec sp_foreignkey MRK_Nomen, MRK_Event,
       _Marker_Event_key
go

exec sp_foreignkey MRK_Nomen, MRK_Status,
       _Marker_Status_key
go



create trigger MRK_Nomen_Delete on MRK_Nomen
  for DELETE
  as
delete MRK_Nomen_GeneFamily from MRK_Nomen_GeneFamily, deleted
where MRK_Nomen_GeneFamily._Nomen_key = deleted._Nomen_key
 
delete MRK_Nomen_Notes from MRK_Nomen_Notes, deleted
where MRK_Nomen_Notes._Nomen_key = deleted._Nomen_key
 
delete MRK_Nomen_Other from MRK_Nomen_Other, deleted
where MRK_Nomen_Other._Nomen_key = deleted._Nomen_key
 
delete MRK_Nomen_Reference from MRK_Nomen_Reference, deleted
where MRK_Nomen_Reference._Nomen_key = deleted._Nomen_key
go


create trigger MRK_Nomen_Update on MRK_Nomen
  for UPDATE
  as
if @@rowcount > 1
begin
	return
end

declare @bKey integer
declare @dKey integer
select @bKey = _Marker_Status_key from MRK_Status where status = 'Broadcast'
select @dKey = _Marker_Status_key from MRK_Status where status = 'Deleted'

/* Set Broadcast Date to NULL automatically, if user changes Status from Broadcast */

if (select _Marker_Status_key from deleted) = @bKey and
   (select _Marker_Status_key from inserted) != @bKey and
   (select broadcast_date from inserted) != null
begin
	update MRK_Nomen
	set broadcast_date = NULL
	from MRK_Nomen n, inserted i
	where n._Nomen_key = i._Nomen_key
end

/* If Broadcast date is entered and Status is not Broadcast or Deleted, */
/* then update Status to Broadcast */

else if (select broadcast_date from inserted) != null and
        (select _Marker_Status_key from inserted) != @bKey and
        (select _Marker_Status_key from inserted) != @dKey
begin
	update MRK_Nomen
	set _Marker_Status_key = @bKey
	from MRK_Nomen n, inserted i
	where n._Nomen_key = i._Nomen_key
end

/* If Broadcast date is removed and Status is still Broadcast, deny update */

else if (select broadcast_date from inserted) = null and
        (select _Marker_Status_key from inserted) = @bKey
begin
	rollback transaction
	raiserror 99999 "Cannot remove Broadcast Date if status is Broadcast."
	return
end
go




