execute sp_unbindefault "HMD_Assay.creation_date"
go

execute sp_unbindefault "HMD_Assay.modification_date"
go

DROP TRIGGER HMD_Assay_Delete
go
 
DROP INDEX HMD_Assay.index_assay_key
go

DROP INDEX HMD_Assay.index_assay
go

DROP INDEX HMD_Assay.index_modification_date
go

execute sp_rename HMD_Assay,HMD_AssayJA8C5152000
go

CREATE TABLE HMD_Assay (
       _Assay_key           int NOT NULL,
       assay                varchar(80) NOT NULL,
       abbrev               char(2) NOT NULL,
       creation_date        datetime NOT NULL,
       modification_date    datetime NOT NULL
)
go

INSERT INTO
HMD_Assay (_Assay_key, assay, abbrev, creation_date, modification_date)
SELECT
_Assay_key, assay, "UN", creation_date, modification_date
FROM 
HMD_AssayJA8C5152000
go

/*
Formation of functional heteropolymers   FH
Immunological cross-reaction             IX
Similar response to specific inhibitors  SI
Similar subcellular location             SL
Similar substrate specificity            SS
Similar subunit structure                SU
Coincident expression                    CE
Nucleotide sequence comparison           NT
Amino acid sequence comparison           AA
Cross-hybridization to same molecular probe XH
Conserved map location                   CL
Functional complementation               FC
Not specificed                           NS
Unreviewed                               UN
*/


update HMD_Assay set abbrev = "FH" where assay = "Formation of functional heteropolymers"
go

update HMD_Assay set abbrev = "IX" where assay = "Immunological cross-reaction"
go

update HMD_Assay set abbrev = "SI" where assay = "Similar response to specific inhibitors"
go

update HMD_Assay set abbrev = "SL" where assay = "Similar subcellular location"
go

update HMD_Assay set abbrev = "SS" where assay = "Similar substrate specificity"
go

update HMD_Assay set abbrev = "SU" where assay = "Similar subunit structure"
go

update HMD_Assay set abbrev = "CE" where assay = "Coincident expression"
go

update HMD_Assay set abbrev = "NT" where assay = "Nucleotide sequence comparison"
go

update HMD_Assay set abbrev = "AA" where assay = "Amino acid sequence comparison"
go

update HMD_Assay set abbrev = "XH" where assay = "Cross-hybridization to same molecular probe"
go

update HMD_Assay set abbrev = "CL" where assay = "Conserved location"
go

update HMD_Assay set assay = "Conserved map location" where abbrev = "CL"
go

update HMD_Assay set abbrev = "NS" where assay = "Not Specified"
go

update HMD_Assay set abbrev = "UN" where assay = "Unreviewed"
go

update HMD_Assay set abbrev = "FC" where assay = "Functional complementation"
go

update HMD_Assay set abbrev = "FH" where assay = "Formation of functional heteropolymers"
go

DROP TABLE HMD_AssayJA8C5152000
go

/* KEYS */

exec sp_primarykey HMD_Assay, _Assay_key
go

/* TRIGGERS */

create trigger HMD_Assay_Delete
on HMD_Assay
for delete
as
/* Disallow removal of the homology assay if it is being referenced in homology */
if exists (select * from HMD_Homology_Assay, deleted
    where HMD_Homology_Assay._Assay_key = deleted._Assay_key)
begin
        rollback transaction
        raiserror 99999 "Assay is referenced in Homology Record(s)"
        return
end
go

/* INDEXES */

create unique clustered  index index_Assay_key on HMD_Assay ( _Assay_key )
with sorted_data on mgd_seg_0 
go

create unique nonclustered index index_assay on HMD_Assay ( assay )
on mgd_seg_1 
go

create nonclustered index index_modification_date on HMD_Assay ( modification_date )
on mgd_seg_1 
go

/* New Values added after Unique Index Added */

insert HMD_Assay (_Assay_key, assay, abbrev, creation_date, modification_date)
values (16, "Formation of functional heteropolymers", "FH", getDate(), getDate())
go 

insert HMD_Assay (_Assay_key, assay, abbrev, creation_date, modification_date)
values (17, "Functional complementation", "FC", getDate(), getDate())
go


/* DEFAULTS */

exec sp_bindefault current_date_default, 'HMD_Assay.creation_date'
go

exec sp_bindefault current_date_default, 'HMD_Assay.modification_date'
go

/* PERMISSIONS */

revoke all on HMD_Assay from editors
go

grant all on HMD_Assay to progs
go

grant all on HMD_Assay to plg, djr, sr, dbradt
go

grant select on HMD_Assay to public
go

