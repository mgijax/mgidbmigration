#!/bin/csh -fx

###----------------------###
###--- initialization ---###
###----------------------###

source ../Configuration

echo "Server: ${MGD_DBSERVER}"
echo "Database: ${MGD_DBNAME}"

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}

date | tee -a ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use $MGD_DBNAME
go

-- Alleles already in our database which are in a genotype 
-- and have only 1 known cell line (already in the database) 
-- can have that cell line associated with the genotype. 
--
-- the association *cannot* be manually made until this project is installed in production
--
-- Note: if the genotype already has MP or OMIM annotations, 
-- it may not be appropriate to associate a known cell line after-the-fact.
--

select c.*
into #sql
from ALL_Allele_CellLine c, ALL_CellLine cc
where c._MutantCellLine_key = cc._CellLine_key
and cc.cellline != "Not Specified"
and exists (select 1 from GXD_AllelePair g where c._Allele_key = g._Allele_key_1)
group by _Allele_key having count(*) = 1
go

insert into #sql
select c.*
from ALL_Allele_CellLine c, ALL_CellLine cc
where c._MutantCellLine_key = cc._CellLine_key
and cc.cellline != "Not Specified"
and exists (select 1 from GXD_AllelePair g where c._Allele_key = g._Allele_key_2)
group by _Allele_key having count(*) = 1
go

select distinct s._Allele_key, 'no ' as hasMP
into #hasMP
from #sql s 
where not exists (select 1 from GXD_AllelePair g, VOC_Annot v 
	where s._Allele_key = g._Allele_key_1
	and g._Genotype_key = v._Object_key
	and v._AnnotType_key = 1002)
go

insert into #hasMP
select distinct s._Allele_key, 'yes' as hasMP
from #sql s 
where exists (select 1 from GXD_AllelePair g, VOC_Annot v 
	where s._Allele_key = g._Allele_key_1
	and g._Genotype_key = v._Object_key
	and v._AnnotType_key = 1002)
go

select distinct s._Allele_key, 'no ' as hasOMIM
into #hasOMIM
from #sql s 
where not exists (select 1 from GXD_AllelePair g, VOC_Annot v 
	where s._Allele_key = g._Allele_key_1
	and g._Genotype_key = v._Object_key
	and v._AnnotType_key = 1005)
go

insert into #hasOMIM
select distinct s._Allele_key, 'yes' as hasOMIM
from #sql s 
where exists (select 1 from GXD_AllelePair g, VOC_Annot v 
	where s._Allele_key = g._Allele_key_1
	and g._Genotype_key = v._Object_key
	and v._AnnotType_key = 1005)
go

select distinct ldb.name, a.symbol, substring(cc.cellLine,1,25) as cellLine, 
	h1.hasMP, h2.hasOMIM
from #sql s, ACC_Accession aa, ACC_LogicalDB ldb, ALL_Allele a, ALL_CellLine cc, #hasMP h1, #hasOMIM h2
where s._MutantCellLine_key = aa._Object_key
and aa._MGIType_key = 28
and aa._LogicalDB_key = ldb._LogicalDB_key
and s._Allele_key = a._Allele_key
and s._MutantCellLine_key = cc._CellLine_key
and s._Allele_key = h1._Allele_key
and s._Allele_key = h2._Allele_key
order by ldb.name, a.symbol, cc.cellLine
go

checkpoint
go

end

EOSQL

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

