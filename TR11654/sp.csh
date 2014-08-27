#!/bin/csh -fx

###----------------------###
###--- initialization ---###
###----------------------###

if ( ${?MGICONFIG} == 0 ) then
	setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}

date | tee -a ${LOG}
cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

--select a.accID from ACC_Accession a, BIB_DataSet_Assoc ba
        --where a._MGIType_key = 1
        --and a._LogicalDB_key = 1
        --and a.prefixPart = "J:"
        --and a._Object_key = ba._Refs_key
        --and ba._DataSet_key = 1005
        --and ba.isNeverUsed = 1
--go

--- GXD_removeBadGelBand

select b.*
from GXD_GelBand b, GXD_GelRow r, GXD_GelLane l
where b._GelLane_key = l._GelLane_key 
and r._GelRow_key = b._GelRow_key 
and r._Assay_key != l._Assay_key
and r._Assay_key = 37764
go

select count(*) from GXD_GelBand
go

exec GXD_removeBadGelBand 37764
go

select b.*
from GXD_GelBand b, GXD_GelRow r, GXD_GelLane l
where b._GelLane_key = l._GelLane_key 
and r._GelRow_key = b._GelRow_key 
and r._Assay_key != l._Assay_key
and r._Assay_key = 37764
go

select count(*) from GXD_GelBand
go

--- BIB_getCopyright
--select r.jnumID, r._Refs_key
--from BIB_View r, BIB_Citation_Cache cc, VOC_Term t, MGI_Note n, MGI_NoteChunk c
--where r._Refs_key = cc._Refs_key
--and r.journal = t.term
--and t._Term_key = n._Object_key
--and n._MGIType_key = 13
--and n._NoteType_key = 1026
--and n._Note_key = c._Note_key
--and r.journal != 'Proc Natl Acad Sci U S A'
--and c.note not like "%Elsevier((%"
--and c.note not like "%JBiolChem(%"
--and c.note not like "%JLipidRes(%"
--and c.note like "%*%"
--go

declare @copyright varchar(255)
exec BIB_getCopyright 9, @copyright output
go

declare @copyright varchar(255)
exec BIB_getCopyright 209521, @copyright output
go

declare @copyright varchar(255)
exec BIB_getCopyright 199452, @copyright output
go

declare @copyright varchar(255)
exec BIB_getCopyright 209029, @copyright output
go

declare @prefixPart varchar(30)
declare @numericPart int
exec ACC_split 'A4ZVL1', @prefixPart out, @numericPart out

declare @prefixPart varchar(30)
declare @numericPart int
exec ACC_split '10522530', @prefixPart out, @numericPart out

declare @prefixPart varchar(30)
declare @numericPart int
exec ACC_split '1415900_a_at', @prefixPart out, @numericPart out

EOSQL
date | tee -a ${LOG}

