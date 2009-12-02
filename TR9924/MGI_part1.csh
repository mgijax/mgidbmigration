#!/bin/csh -fx

# Migration for TR9924 -- fall 2009 maintenance release

###----------------------###
###--- initialization ---###
###----------------------###

source ../Configuration
setenv CWD `pwd`	# current working directory
echo "Server: ${MGD_DBSERVER}"
echo "Database: ${MGD_DBNAME}"

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}
date | tee -a ${LOG}
echo "--- Starting in ${CWD}..." | tee -a ${LOG}

# load a backup

if ("${1}" == "dev") then
    echo "--- Loading new database into ${MGD_DBSERVER}..${MGD_DBNAME}" | tee -a ${LOG}
    load_db.csh ${MGD_DBSERVER} ${MGD_DBNAME} /shire/sybase/mgd.backup | tee -a ${LOG}
    date | tee -a ${LOG}
else
    echo "--- Working on existing database: ${MGD_DBSERVER}..${MGD_DBNAME}" | tee -a ${LOG}
endif

setenv SCHEMA ${MGD_DBSCHEMADIR}
setenv PERMS ${MGD_DBPERMSDIR}
setenv UTILS ${MGI_DBUTILS}

date | tee -a ${LOG}
echo "--- Updating version numbers in db..." | tee -a ${LOG}

${UTILS}/bin/updatePublicVersion.csh ${MGD_DBSERVER} ${MGD_DBNAME} "MGI 4.32" | tee -a ${LOG}
${UTILS}/bin/updateSchemaVersion.csh ${MGD_DBSERVER} ${MGD_DBNAME} "4-3-2-0" | tee -a ${LOG}

setenv DB_PARMS "${MGD_DBUSER} ${MGI_DBPASSWORDFILE} ${MGD_DBSERVER} ${MGD_DBNAME}"

cd ${CWD}

###--------------------###
###--- data changes ---###
###--------------------###

date | tee -a ${LOG}
echo "--- Update MouseFunc to be FuncBase" | tee -a ${LOG}
echo "--- Add Transgene marker type" | tee -a ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

/* changes to MouseFunc names */

update ACC_LogicalDB set name = "FuncBase", description = "FuncBase"
where _LogicalDB_key = 124
update ACC_ActualDB set name = "FuncBase" where _ActualDB_key = 110
go

/* add Transgene marker type */

if not exists (select 1 from MRK_Types where name = "Transgene")
begin
  declare @typeKey integer
  select @typeKey = max(_Marker_Type_key) from MRK_Types

  insert MRK_Types (_Marker_Type_key, name)
  values (@typeKey + 1, "Transgene")
end
go

/* update marker type for existing markers */

declare @tgKey integer
select @tgKey = _Marker_Type_key from MRK_Types where name = "Transgene"

update MRK_Marker
set _Marker_Type_key = @tgKey
from MRK_Marker m, MRK_Types t
where m._Marker_Type_key = t._Marker_Type_key
  and m._Organism_key = 1		-- only mouse markers
  and t.name = "Other Genome Feature"	-- only type "Other Genome Feature"
  and m.symbol like "Tg(%"		-- with transgene-style nomenclature
  and m._Marker_Status_key in (1,3)	-- current and pending status
go
EOSQL

date | tee -a ${LOG}
echo "--- Reporting on new transgene markers" | tee -a ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

declare @tgKey integer
select @tgKey = _Marker_Type_key from MRK_Types where name = "Transgene"

select count(1) as "All Transgene Markers"
from MRK_Marker where _Marker_Type_key = @tgKey

select count(1) as "Tg Mrk w/ >=1 tg allele"
from MRK_Marker m
where m._Marker_Type_key = @tgKey
  and exists (select 1 from ALL_Allele a, VOC_Term t
	where a._Marker_key = m._Marker_key
		and a._Allele_Type_key = t._Term_key
		and t.term like "transgenic%")

select count(1) as "Tg Mrk w/ >=1 non-tg allele"
from MRK_Marker m
where m._Marker_Type_key = @tgKey
  and exists (select 1 from ALL_Allele a, VOC_Term t
	where a._Marker_key = m._Marker_key
		and a._Allele_Type_key = t._Term_key
		and t.term not like "transgenic%")

select count(1) as "Tg Mrk w/ no tg alleles"
from MRK_Marker m
where m._Marker_Type_key = @tgKey
  and not exists (select 1 from ALL_Allele a, VOC_Term t
	where a._Marker_key = m._Marker_key
		and a._Allele_Type_key = t._Term_key
		and t.term like "transgenic%")

select count(1) as "Non-Tg Mrk w/ >=1 tg allele"
from MRK_Marker m
where m._Marker_Type_key != @tgKey
  and m._Marker_Status_key in (1,3)
  and m._Organism_key = 1
  and exists (select 1 from ALL_Allele a, VOC_Term t
	where a._Marker_key = m._Marker_key
		and a._Allele_Type_key = t._Term_key
		and t.term like "transgenic%")
go
EOSQL

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}
