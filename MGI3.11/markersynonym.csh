#!/bin/csh -f

#
# Migrate Marker Synonyms from MRK_Other into MGI_Synonym structures
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date >> $LOG
 
cat - <<EOSQL | doisql.csh $0 >> $LOG

use $DBNAME
go

/* delete synonyms we don't want anymore */

/* synonyms associated with J:66660 or J:66661 that exactly match an EntrezGene human synonym */

delete MRK_Other 
from MRK_Other m, $RADARDB..DP_EntrezGene_Info e, $RADARDB..DP_EntrezGene_Synonym s
where m._Refs_key in (67607, 67608)
and e.taxID = 9606
and e.geneID = s.geneID
and m.name = s.synonym
go

/* synonyms with no J: that exactly match an EntrezGene human synonym */

delete MRK_Other 
from MRK_Other m, $RADARDB..DP_EntrezGene_Info e, $RADARDB..DP_EntrezGene_Synonym s
where m._Refs_key is null
and e.taxID = 9606
and e.geneID = s.geneID
and m.name = s.synonym
go

/* set _Refs_key to J:94790 for all Synonyms that don't have a reference */

declare @refsKey integer
select @refsKey = _Object_key from ACC_Accession where accID = "J:94790"

update MRK_Other set _Refs_key = @refsKey where _Refs_key is null
go

/* pass new synonyms on to MGI_Synonym */

declare @synTypeKey integer
select @synTypeKey = max(_SynonymType_key) + 1 from MGI_SynonymType

/* marker mouse */

insert into MGI_SynonymType values(@synTypeKey, 2, 1, 'exact', 'a synonym whose conceptualization has the same meaning as the object being named.', 0, 1000, 1000, getdate(), getdate())

insert into MGI_SynonymType values(@synTypeKey + 1, 2, 1, 'similar', 'a synonym whose conceptualization has a meaning similar to but not exactly the same as the object being named.', 0, 1000, 1000, getdate(), getdate())

insert into MGI_SynonymType values(@synTypeKey + 2, 2, 1, 'broad', 'a synonym whose conceptualization is broader than the concept for the object being named.', 0, 1000, 1000, getdate(), getdate())

insert into MGI_SynonymType values(@synTypeKey + 3, 2, 1, 'narrow', 'a synonym whose conceptualization is narrower than the concept for the object being named.', 0, 1000, 1000, getdate(), getdate())

/* nomen mouse */

insert into MGI_SynonymType values(@synTypeKey + 4, 21, 1, 'exact', 'a synonym whose conceptualization has the same meaning as the object being named.', 0, 1000, 1000, getdate(), getdate())

insert into MGI_SynonymType values(@synTypeKey + 5, 21, 1, 'similar', 'a synonym whose conceptualization has a meaning similar to but not exactly the same as the object being named.', 0, 1000, 1000, getdate(), getdate())

insert into MGI_SynonymType values(@synTypeKey + 6, 21, 1, 'broad', 'a synonym whose conceptualization is broader than the concept for the object being named.', 0, 1000, 1000, getdate(), getdate())

insert into MGI_SynonymType values(@synTypeKey + 7, 21, 1, 'narrow', 'a synonym whose conceptualization is narrower than the concept for the object being named.', 0, 1000, 1000, getdate(), getdate())

/* marker human */

insert into MGI_SynonymType values(@synTypeKey + 8, 2, 2, 'entrezgene', 'a synonym that is loaded from EntrezGene.', 0, 1000, 1000, getdate(), getdate())

insert into MGI_SynonymType values(@synTypeKey + 9, 2, 2, 'mgi-curated', 'a synonym that is found in a publication and is not found in EntrezGene.', 0, 1000, 1000, getdate(), getdate())

go

select seq = identity(10), name, _Marker_key, _Refs_key, creation_date, modification_date
into #synonyms
from MRK_Other
go

declare @synKey integer
select @synKey = max(_Synonym_key) from MGI_Synonym

declare @synTypeKey integer
select @synTypeKey = _SynonymType_key from MGI_SynonymType where _MGIType_key = 2 and synonymType = 'exact'

insert into MGI_Synonym
select @synKey + seq, _Marker_key, 2, @synTypeKey, _Refs_key, name, 1000, 1000, creation_date, modification_date
from #synonyms
go

/* xxxxRik, mKIAAxxxx, MGC:xxxx synonyms need to be migrated to similar */

declare @synTypeKey integer
select @synTypeKey = _SynonymType_key from MGI_SynonymType where _MGIType_key = 2 and synonymType = 'similar'

update MGI_Synonym
set _SynonymType_key = @synTypeKey
where _MGIType_key = 2
and synonym like '%Rik'

update MGI_Synonym
set _SynonymType_key = @synTypeKey
where _MGIType_key = 2
and synonym like 'mKIAA%'

update MGI_Synonym
set _SynonymType_key = @synTypeKey
where _MGIType_key = 2
and synonym like 'MGC:%'

go

/* all Nomenclature synonyms of type "Author" are migrated to "exact" */

declare @oldsynTypeKey integer
declare @synTypeKey integer
select @oldsynTypeKey = _SynonymType_key from MGI_SynonymType where _MGIType_key = 21 and synonymType = 'Author'
select @synTypeKey = _SynonymType_key from MGI_SynonymType where _MGIType_key = 21 and synonymType = 'exact'

update MGI_Synonym
set _SynonymType_key = @synTypeKey
where _MGIType_key = 21
and _SynonymType_key = @oldsynTypeKey
go

/* all Nomenclature synonyms of type "Other" are migrated to "similar" */

declare @oldsynTypeKey integer
declare @synTypeKey integer
select @oldsynTypeKey = _SynonymType_key from MGI_SynonymType where _MGIType_key = 21 and synonymType = 'Other'
select @synTypeKey = _SynonymType_key from MGI_SynonymType where _MGIType_key = 21 and synonymType = 'similar'

update MGI_Synonym
set _SynonymType_key = @synTypeKey
where _MGIType_key = 21
and _SynonymType_key = @oldsynTypeKey
go

delete from MGI_SynonymType where _MGIType_key = 21 and synonymType in ("Author", "Other")
go

quit

EOSQL

date >> $LOG

