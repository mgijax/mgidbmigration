use nomen_dev
go

CREATE RULE check_Hybridization AS @col IN ('whole mount', 'sections', 'section from whole mount', 'Not Specified', 'Not Applicable')
go

CREATE RULE check_Sex AS @col IN ('Female', 'Male', 'Pooled', 'Not Specified', 'Not Applicable')
go

CREATE RULE check_NucleicAcidType AS @col IN ('DNA', 'RNA', 'Not Specified')
go

CREATE RULE check_DNAtype AS @col IN ('DNA (construct)', 'EST', 'RNA', 'cDNA', 'genomic', 'mitochondrial', 'oligo', 'primer', 'Not Specified')
go

CREATE RULE check_Relationship AS @col IN ('A', 'E', 'H', 'M', 'P')
go

CREATE RULE check_NLM_status AS @col IN ('Y', 'N', 'X')
go

CREATE RULE check_noteType AS @col IN ('C','E')
go

CREATE DEFAULT bit_default AS 0
go

CREATE DEFAULT current_date_default AS getdate()
go

CREATE DEFAULT preferred AS 1
go

CREATE TABLE ACC_MGIType (
       _MGIType_key         int NOT NULL,
       name                 varchar(80) NOT NULL,
       tableName            varchar(80) NOT NULL,
       primaryKeyName       varchar(80) NOT NULL,
       creation_date        datetime NOT NULL,
       modification_date    datetime NOT NULL,
       release_date         datetime NULL
)
go

CREATE UNIQUE CLUSTERED INDEX index_MGIType_key ON ACC_MGIType
(
       _MGIType_key
)
go

CREATE UNIQUE INDEX index_name ON ACC_MGIType
(
       name
)
go

CREATE INDEX index_modification_date ON ACC_MGIType
(
       modification_date
)
go

exec sp_primarykey ACC_MGIType, _MGIType_key
go

exec sp_bindefault current_date_default, 'ACC_MGIType.creation_date'
go

exec sp_bindefault current_date_default, 'ACC_MGIType.modification_date'
go

exec sp_bindefault current_date_default, 'ACC_MGIType.release_date'
go

CREATE TABLE ACC_Accession (
       _Accession_key       int NOT NULL,
       accID                varchar(30) NOT NULL,
       prefixPart           varchar(20) NULL,
       numericPart          int NULL,
       _LogicalDB_key       int NOT NULL,
       _Object_key          int NOT NULL,
       _MGIType_key         int NOT NULL,
       private              bit,
       preferred            bit,
       creation_date        datetime NOT NULL,
       modification_date    datetime NOT NULL,
       release_date         datetime NULL
)
go

CREATE UNIQUE CLUSTERED INDEX index_Accession_key ON ACC_Accession
(
       _Accession_key
)
go

CREATE INDEX index_Object_key ON ACC_Accession
(
       _Object_key
)
go

CREATE INDEX index_numericPart ON ACC_Accession
(
       numericPart
)
go

CREATE INDEX index_LogicalDB_key ON ACC_Accession
(
       _LogicalDB_key
)
go

CREATE INDEX index_MGIType_key ON ACC_Accession
(
       _MGIType_key
)
go

CREATE INDEX index_prefixPart ON ACC_Accession
(
       prefixPart
)
go

CREATE INDEX index_modification_date ON ACC_Accession
(
       modification_date
)
go

CREATE INDEX index_accID ON ACC_Accession
(
       accID
)
go

CREATE INDEX index_LogicalDB_MGI_Type_key ON ACC_Accession
(
       _LogicalDB_key,
       _MGIType_key
)
go

exec sp_primarykey ACC_Accession, _Accession_key
go

exec sp_bindefault bit_default, 'ACC_Accession.private'
go

exec sp_bindefault preferred, 'ACC_Accession.preferred'
go

exec sp_bindefault current_date_default, 'ACC_Accession.creation_date'
go

exec sp_bindefault current_date_default, 'ACC_Accession.modification_date'
go

exec sp_bindefault current_date_default, 'ACC_Accession.release_date'
go

CREATE TABLE ACC_AccessionReference (
       _Accession_key       int NOT NULL,
       _Refs_key            int NOT NULL,
       creation_date        datetime NOT NULL,
       modification_date    datetime NOT NULL,
       release_date         datetime NULL
)
go

CREATE UNIQUE CLUSTERED INDEX index_Acc_Refs_key ON ACC_AccessionReference
(
       _Accession_key,
       _Refs_key
)
go

CREATE INDEX index_Accession_key ON ACC_AccessionReference
(
       _Accession_key
)
go

CREATE INDEX index_modification_date ON ACC_AccessionReference
(
       modification_date
)
go

CREATE INDEX index_Refs_key ON ACC_AccessionReference
(
       _Refs_key
)
go

exec sp_primarykey ACC_AccessionReference,
       _Accession_key,
       _Refs_key
go

exec sp_bindefault current_date_default, 'ACC_AccessionReference.creation_date'
go

exec sp_bindefault current_date_default, 'ACC_AccessionReference.modification_date'
go

exec sp_bindefault current_date_default, 'ACC_AccessionReference.release_date'
go

exec sp_foreignkey ACC_Accession, ACC_LogicalDB,
       _LogicalDB_key
go

exec sp_foreignkey ACC_Accession, ACC_MGIType,
       _MGIType_key
go

exec sp_foreignkey ACC_AccessionReference, ACC_Accession,
       _Accession_key
go

exec sp_foreignkey ACC_AccessionReference, BIB_Refs,
       _Refs_key
go

insert ACC_MGIType values (1, "Nomenclature", "MRK_Nomen", "_Nomen_key", getDate(), getDate(), getDate())
go

