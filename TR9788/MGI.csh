#!/bin/csh -fx

#
# Migration for TR7493 -- gene trap LF
# (part 1 - migration of existing data into new structures)

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
echo "Migrating TIGEM, TIGM and EUCOMM strands" | tee -a ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

/* get all TIGM mutant cell lines */
select c._CellLine_key
        into #tigmCL
        from  ALL_CellLine c, ALL_CellLine_Derivation d
        where d._Creator_key = 3982964
        and d._Derivation_key = c._Derivation_key
go

create index idx_1 on #tigmCL(_CellLine_key)
go

/* get all TIGM sequences */
select saa._Sequence_key
    into #tigmSeq
    from #tigmCL t, ALL_Allele_CellLine aac, SEQ_Allele_Assoc saa
    where t._CellLine_key = aac._MutantCellLine_key
    and aac._Allele_key = saa._Allele_key
go

create index idx_1 on #tigmSeq(_Sequence_key)
go

/* get all TIGM sequences with upstream vector end */
select t._Sequence_key
    into #tigmUpstSeq
    from #tigmSeq t, SEQ_GeneTrap sgt
    where t._Sequence_key = sgt._Sequence_key
    and sgt._VectorEnd_key = 3983010
go

/* get all EUCOMM and TIGEM mutant cell lines */
select c._CellLine_key
    into #tigemeucommCL
    from  ALL_CellLine c, ALL_CellLine_Derivation d
    where d._Creator_key in (3982963, 4856374)
    and d._Derivation_key = c._Derivation_key
go

create index idx_1 on #tigemeucommCL(_CellLine_key)
go

/* get all EUCOMM and TIGEM sequuences */
select saa._Sequence_key
    into #tigemeucommSeq
    from #tigemeucommCL t, ALL_Allele_CellLine aac, SEQ_Allele_Assoc saa
    where t._CellLine_key = aac._MutantCellLine_key
    and aac._Allele_key = saa._Allele_key
go

/* union TIGM and EUCOMM/TIGEM From this set we toggle the strand */ 
select distinct t._Sequence_key
    into #all
    from #tigmUpstSeq t
    union
    select distinct te._Sequence_key
    from #tigemeucommSeq te
go

create index idx_1 on #all(_Sequence_key)
go

/* not all gene trap sequences have coordinates so (#plus + #minus) < #all */

/* get all sequences with '+' strand */
select distinct a._Sequence_key, f._Feature_key
    into #plus
    from #all a, MAP_Coord_Feature f, MAP_Coordinate c, 
	MAP_Coord_Collection cc
    where a._Sequence_key = f._Object_key
    and f._MGIType_key = 19
    and f.strand = '+'
    and f._Map_key = c._Map_key
    and c._Collection_key = cc._Collection_key
    and cc._Collection_key = 31
go

create index idx_1 on #plus(_Feature_key)
go

/* get all sequences with '-' strand */
select distinct a._Sequence_key, f._Feature_key
    into #minus
    from #all a, MAP_Coord_Feature f, MAP_Coordinate c, 
	MAP_Coord_Collection cc
    where a._Sequence_key = f._Object_key
    and f._MGIType_key = 19
    and f.strand = '-'
    and f._Map_key = c._Map_key
    and c._Collection_key = cc._Collection_key
    and cc._Collection_key = 31
go

create index idx_1 on #minus(_Feature_key)
go

/* update plus to minus */
update MAP_Coord_Feature
    set strand = '-'
    where _Feature_key in (
    select _Feature_key
    from #plus)
go

/* update minus to plus */
update MAP_Coord_Feature
    set strand = '+'
    where _Feature_key in (
    select _Feature_key
    from #minus)
go

/* log EUCOMM file in radar for TR9752 */
use ${RADAR_DBNAME}
go

declare @maxKey integer
select @maxKey = max(_File_key) from APP_FilesMirrored

insert APP_FilesMirrored
values (@maxKey + 1, "GenBank_preprocess", "/mgi/all/wts_projects/9700/9752/eucomm_genetraps.seq.gz", 12439, "mgiadmin", getdate(), getdate())
go

EOSQL

# run seq coord cacheload and alomrkload to pick up new point coord
# algorithm 
echo "Running seqcoord cacheload" | tee -a ${LOG}
${SEQCACHELOAD}/seqcoord.csh

echo "Running alomrkload" | tee -a ${LOG}
${ALOMRKLOAD}/bin/alomrkload.sh

date | tee -a ${LOG}
