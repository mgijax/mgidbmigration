#!/bin/csh -fx

#
# Test US144 - update to MRK_Marker insert trigger
# 

###----------------------###
###--- initialization ---###
###----------------------###

cd `dirname $0` && source ../Configuration
setenv CWD `pwd`	# current working directory
echo "Server: ${MGD_DBSERVER}"
echo "Database: ${MGD_DBNAME}"

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}
date | tee -a ${LOG}
echo "--- Starting in ${CWD}..." | tee -a ${LOG}

#
# drop/create MRK_Marker triggers
#
#${MGD_DBSCHEMADIR}/trigger/MRK_Marker_drop.object
#${MGD_DBSCHEMADIR}/trigger/MRK_Marker_create.object

#
# create markers to test new criteria for creating wild type alleles
#
date | tee -a ${LOG}

echo "--- create markers to test new criteria for creating wild type alleles' " | tee -a ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

/* MRK_Marker fields: nextAccKey, mouse, official, mkrType, internal curation status, symbol, name, chromosome, cytoOffset, sc, sc, today'sDate, today'sDate */

/* create genes that should not create WT alleles */

declare @maxKey integer
select @maxKey = max(_Marker_key) from MRK_Marker

/* not a gene (DNA Segment=2) (existing criteria)*/
insert into MRK_Marker
values (@maxKey + 1, 1, 1, 2, 166894, "AnewGeneDNASeg", "A new DNA Seg", "1", null, 1014, 1014, getdate(), getdate() )
go

declare @maxKey integer
select @maxKey = max(_Marker_key) from MRK_Marker

/* '%gene model%' in name nomen (existing criteria)*/
insert into MRK_Marker
values (@maxKey + 1, 1, 1, 1, 166894, "AnewGeneModelGene", "A new gene model", "1", null, 1014, 1014, getdate(), getdate() )
go

declare @maxKey integer
select @maxKey = max(_Marker_key) from MRK_Marker

/* '%expressed sequence%' in name nomen (new criteria) */
insert into MRK_Marker
values (@maxKey + 1, 1, 1, 1, 166894, "AnewGeneExprSeq", "A new expressed sequence gene", "1", null, 1014, 1014, getdate(), getdate() )
go

/* create genes that SHOULD create a wild type allele */

declare @maxKey integer
select @maxKey = max(_Marker_key) from MRK_Marker

/* symbol like '%Rik' (new criteria)*/
insert into MRK_Marker
values (@maxKey + 1, 1, 1, 1, 166894, "AnewGeneRik", "A new Gene Rik", "1", null, 1014, 1014, getdate(), getdate() )
go

declare @maxKey integer
select @maxKey = max(_Marker_key) from MRK_Marker

/* none of the excluded criteria (existing criteria) */
insert into MRK_Marker
values (@maxKey + 1, 1, 1, 1, 166894, "AnewGene", "A new Name", "1", null, 1014, 1014, getdate(), getdate() )
go

declare @maxKey integer
select @maxKey = max(_Marker_key) from MRK_Marker

/* name like 'RIKEN%' (new criteria)*/
insert into MRK_Marker
values (@maxKey + 1, 1, 1, 1, 166894, "AnewGeneRiken", "RIKEN new gene", "1", null, 1014, 1014, getdate(), getdate() )
go

declare @maxKey integer
select @maxKey = max(_Marker_key) from MRK_Marker

/* name like '%expressed%' (new criteria)*/
insert into MRK_Marker
values (@maxKey + 1, 1, 1, 1, 166894, "AnewGeneExpressed", "new expressed gene", "1", null, 1014, 1014, getdate(), getdate() )
go

declare @maxKey integer
select @maxKey = max(_Marker_key) from MRK_Marker

/* name like '%mitochondrial ribosomal protein%' (new criteria)*/
insert into MRK_Marker
values (@maxKey + 1, 1, 1, 1, 166894, "AnewGeneMTribProt", "new mitochondrial ribosomal protein gene", "1", null, 1014, 1014, getdate(), getdate() )
go

declare @maxKey integer
select @maxKey = max(_Marker_key) from MRK_Marker

/* name like 'ribosomal protein%' (new criteria)*/
insert into MRK_Marker
values (@maxKey + 1, 1, 1, 1, 166894, "AnewGeneRibProt", "ribosomal protein gene new", "1", null, 1014, 1014, getdate(), getdate() )
go

select * from MRK_Marker
where symbol like 'AnewGene%'
go

select * from ALL_Allele
where symbol like 'AnewGene%'
go

EOSQL
