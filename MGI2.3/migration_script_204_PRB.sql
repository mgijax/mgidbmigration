CREATE DEFAULT bit_default AS 0
go

sp_unbindefault "PRB_Strain.standard"
go

sp_unbindefault "PRB_Strain.creation_date"
go

sp_unbindefault "PRB_Strain.modification_date"
go
            
DROP TRIGGER PRB_Strain_Delete
go

DROP TRIGGER PRB_Strain_Insert
go

DROP TRIGGER PRB_Strain_Update
go

DROP INDEX PRB_Strain.index_modification_date
go

DROP INDEX PRB_Strain.index_strain
go

sp_rename PRB_Strain,PRB_StrainJAKD0110000
go

CREATE TABLE PRB_Strain (
       _Strain_key          int NOT NULL,
       strain               varchar(255) NOT NULL,
       standard             bit NOT NULL,
       needsReview          bit NOT NULL,
       creation_date        datetime NOT NULL,
       modification_date    datetime NOT NULL       
       )
go

INSERT INTO PRB_Strain (_Strain_key, strain, standard, needsReview, creation_date, modification_date) 
SELECT _Strain_key, strain, standard, 0, creation_date, modification_date 
FROM PRB_StrainJAKD0110000
go

DROP TABLE PRB_StrainJAKD0110000
go

/* Keys for PRB_Strains*/

sp_primarykey PRB_Strain,_Strain_key
go

sp_foreignkey CRS_Cross, PRB_Strain, _StrainHT_key
go

sp_foreignkey CRS_Cross, PRB_Strain, _StrainHO_key
go

sp_foreignkey CRS_Cross, PRB_Strain, _femaleStrain_key
go

sp_foreignkey CRS_Cross, PRB_Strain, _maleStrain_key
go

sp_foreignkey MLD_FISH, PRB_Strain, _Strain_key
go

sp_foreignkey MLD_InSitu, PRB_Strain, _Strain_key
go

sp_foreignkey PRB_Allele_Strain, PRB_Strain, _Strain_key
go

sp_foreignkey PRB_Source, PRB_Strain, _Strain_key
go

sp_foreignkey GXD_Genotype, PRB_Strain, _Strain_key
go

/* Indexes for PRB_Strain */

CREATE UNIQUE CLUSTERED INDEX index_Strain_key ON PRB_Strain
(
       _Strain_key
)
ON mgd_seg_0
go

CREATE INDEX index_strain ON PRB_Strain
(
       strain
)
ON mgd_seg_1
go

CREATE INDEX index_modification_date ON PRB_Strain
(
       modification_date
)
ON mgd_seg_1
go

/* Defaults for PRB_Strain */

sp_bindefault bit_default, 'PRB_Strain.standard'
go

sp_bindefault bit_default, 'PRB_Strain.needsReview'
go

sp_bindefault current_date_default, 'PRB_Strain.creation_date'
go

sp_bindefault current_date_default, 'PRB_Strain.modification_date'
go

/* Permissions for PRB_Strain*/

revoke all on PRB_Strain from editors
go

grant all on PRB_Strain to progs
go

grant all on PRB_Strain to mlp
go

grant insert on PRB_Strain to editors
go

grant select on PRB_Strain to public
go

drop table PRB_Strain_Marker
go

CREATE TABLE PRB_Strain_Marker (
       _Strain_key          int NOT NULL,
       _Marker_key          int NOT NULL,
       creation_date        datetime NOT NULL,
       modification_date    datetime NOT NULL
)
go

CREATE UNIQUE CLUSTERED INDEX index_Strain_Marker_keys ON PRB_Strain_Marker
(
       _Strain_key, _Marker_key
)
go

CREATE INDEX index_Strain_key ON PRB_Strain_Marker
(
       _Strain_key
)
go

CREATE INDEX index_Marker_key ON PRB_Strain_Marker
(
       _Marker_key
) on mgd_seg_1
go

CREATE INDEX index_modification_date ON PRB_Strain_Marker
(
       modification_date
) on mgd_seg_1
go

sp_primarykey PRB_Strain_Marker, _Strain_key, _Marker_key
go

sp_bindefault current_date_default, 'PRB_Strain_Marker.creation_date'
go

sp_bindefault current_date_default, 'PRB_Strain_Marker.modification_date'
go

sp_foreignkey PRB_Strain_Marker, MRK_Marker, _Marker_key
go

exec sp_foreignkey PRB_Strain_Marker, PRB_Strain, _Strain_key
go

grant all on PRB_Strain_Marker to mlp, progs
go
