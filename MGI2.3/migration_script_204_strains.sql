CREATE DEFAULT bit_default AS 0
go

CREATE DEFAULT current_date_default AS getdate()
go

drop table MLP_Species
go

CREATE TABLE MLP_Species (
       _Species_key         int NOT NULL,
       species              varchar(255) NOT NULL,
       creation_date        datetime NOT NULL,
       modification_date    datetime NOT NULL
)
go

CREATE UNIQUE CLUSTERED INDEX index_Species_key ON MLP_Species
(
       _Species_key
)
go

CREATE UNIQUE INDEX index_species ON MLP_Species
(
       species
)
go

CREATE INDEX index_modification_date ON MLP_Species
(
       modification_date
)
go

sp_primarykey MLP_Species, _Species_key
go

sp_bindefault current_date_default, 'MLP_Species.creation_date'
go

sp_bindefault current_date_default, 'MLP_Species.modification_date'
go

grant all on MLP_Species to mlp
go

grant all on MLP_Species to progs
go

drop table MLP_Strain
go

CREATE TABLE MLP_Strain (
       _Strain_key          int NOT NULL,
       _Species_key         int NOT NULL,
       userDefined1         varchar(255) NULL,
       userDefined2         varchar(255) NULL,
       creation_date        datetime NOT NULL,
       modification_date    datetime NOT NULL
)
go

CREATE UNIQUE CLUSTERED INDEX index_strain_key ON MLP_Strain
(
       _Strain_key
)
go

CREATE INDEX index_Species_key ON MLP_Strain
(
       _Species_key
)
go

CREATE INDEX index_modification_date ON MLP_Strain
(
       modification_date
)
go

sp_primarykey MLP_Strain, _Strain_key
go

sp_bindefault current_date_default, 'MLP_Strain.creation_date'
go

sp_bindefault current_date_default, 'MLP_Strain.modification_date'
go

grant all on MLP_Strain to mlp, progs
go

grant all on MLP_Strain to progs
go

drop table MLP_StrainType
go

CREATE TABLE MLP_StrainType (
       _StrainType_key      int NOT NULL,
       strainType           varchar(255) NOT NULL,
       creation_date        datetime NOT NULL,
       modification_date    datetime NOT NULL
)
go

CREATE UNIQUE CLUSTERED INDEX index_StrainType_key ON MLP_StrainType
(
       _StrainType_key
)
go

CREATE UNIQUE INDEX index_StrainType ON MLP_StrainType
(
       strainType
)
go

CREATE INDEX index_modification_date ON MLP_StrainType
(
       modification_date
)
go

sp_primarykey MLP_StrainType, _StrainType_key
go

sp_bindefault current_date_default, 'MLP_StrainType.creation_date'
go

sp_bindefault current_date_default, 'MLP_StrainType.modification_date'
go

grant all on MLP_StrainType to mlp, progs
go

drop table MLP_StrainTypes
go

CREATE TABLE MLP_StrainTypes (
       _Strain_key          int NOT NULL,
       _StrainType_key      int NOT NULL,
       creation_date        datetime NOT NULL,
       modification_date    datetime NOT NULL
)
go

CREATE UNIQUE CLUSTERED INDEX index_Strain_Strain_Type_keys ON MLP_StrainTypes
(
       _Strain_key, _StrainType_key
)
go

CREATE INDEX index_StrainTypes ON MLP_StrainTypes
(
       _StrainType_key
)
go

CREATE INDEX index_Strain_key ON MLP_StrainTypes
(
       _Strain_key
)
go

CREATE INDEX index_modification_date ON MLP_StrainTypes
(
       modification_date
)
go

sp_primarykey MLP_StrainTypes, _Strain_key, _StrainType_key
go

sp_bindefault current_date_default, 'MLP_StrainTypes.creation_date'
go

sp_bindefault current_date_default, 'MLP_StrainTypes.modification_date'
go

grant all on MLP_StrainTypes to mlp
go

grant all on MLP_StrainTypes to progs
go

/* Moyha's 'notes' spreadsheet contains more than just "notes", so we need to revise the MLP_Notes table: */

drop table MLP_Notes
go

CREATE TABLE MLP_Notes (
       _Strain_key          int NOT NULL,
       andor	            varchar(10) null,
       reference 	int null,
       dataset		varchar(25) null,
       note1		varchar(255) null,
       note2		varchar(25) null,
       note3		varchar(25) null,
       creation_date        datetime NOT NULL,
       modification_date    datetime NOT NULL
)
go

/*MLP_Notes Indexes */

CREATE UNIQUE CLUSTERED INDEX index_Strain_key ON MLP_Notes
(
       _Strain_key
)
go

CREATE INDEX index_modification_date ON MLP_Notes
(
       modification_date
)
go

/* Keys for MLP_Notes*/

sp_primarykey MLP_Notes, _Strain_key
go

/* Defaults for MLP_Notes */

sp_bindefault current_date_default, 'MLP_Notes.creation_date'
go

sp_bindefault current_date_default, 'MLP_Notes.modification_date'
go

grant all on MLP_Notes to mlp
go
 
grant all on MLP_Notes to progs
go

sp_foreignkey MLP_Strain, MLP_Species, _Species_key
go

sp_foreignkey MLP_Strain, PRB_Strain, _Strain_key
go

sp_foreignkey MLP_StrainTypes, MLP_Strain, _Strain_key
go

sp_foreignkey MLP_StrainTypes, MLP_StrainType, _StrainType_key
go

sp_foreignkey MLP_Notes, MLP_Strain, _Strain_key
go
