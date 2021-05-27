#!/bin/csh -f

#
# Template
#

if ( ${?MGICONFIG} == 0 ) then
        setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date | tee -a $LOG
 
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

-- delete RIKEN Clusters (25) accession ids
delete from acc_accession where _logicaldb_key = 25;
delete from acc_logicaldb where _logicaldb_key = 25;

-- _mgitype_key that have private = true accession ids
select distinct a._mgitype_key, t.name, a._logicaldb_key, l.name, a.private
from acc_accession a, acc_logicaldb l, acc_mgitype t
where a._logicaldb_key = l._logicaldb_key
and a._mgitype_key = t._mgitype_key
and a.private = 1
and a._mgitype_key not in (1, 3, 9, 12, 13, 20, 25, 28)
and a._logicaldb_key not in (1, 107, 130, 118, 117)
order by a._mgitype_key, a._logicaldb_key
;

-- Rat ids
-- 4  | RatMap
-- 47 | Rat Genome Database
update acc_accession set private = 0 where _logicaldb_key in (4,47) and private = 1;

-- non-mouse/private or not?
-- 27 | RefSeq
-- 9 | Sequence DB
-- 13 | SWISS-PROT
select count(*), a._logicaldb_key, l.name, a.private
from acc_accession a, acc_logicaldb l, mrk_marker m 
where a._mgitype_key = 2 
and a._logicaldb_key in (9,13,27)
and a._logicaldb_key = l._logicaldb_key
and a._object_key = m._marker_key
and m._organism_key != 1
group by a._logicaldb_key, l.name, a.private
order by a._logicaldb_key
;
select a.*
into temp table toUpdate1
from acc_accession a, acc_logicaldb l, mrk_marker m 
where a._mgitype_key = 2 
and a._logicaldb_key in (9,13,27)
and a.private = 1
and a._logicaldb_key = l._logicaldb_key
and a._object_key = m._marker_key
and m._organism_key != 1
;
update acc_accession a
set private = 0 
from toUpdate1 t
where t._accession_key = a._accession_key
;

-- mouse markers/should be private = 1/leave as is
-- 107 | ABA
-- 130 | ArrayExpress
-- 118 | GENSAT
-- 117 | GEO
--select m.symbol, m._marker_status_key, m._organism_key, a.accid, a._logicaldb_key, l.name, a.creation_date
--from acc_accession a, acc_logicaldb l, mrk_marker m 
--where a.private = 1 
--and a._mgitype_key = 2 
--and a._logicaldb_key = l._logicaldb_key
--and a._object_key = m._marker_key
--and m._organism_key = 1
--order by l.name, m.symbol
--;

-- non-mouse markers/should be private = 1
-- 9 | Sequence DB
-- 118 | GENSAT
select a.*
into temp table toUpdate5
from acc_accession a, acc_logicaldb l, mrk_marker m
where a.private = 0 
and a._mgitype_key = 2 
and a._logicaldb_key in (9,118)
and a._logicaldb_key = l._logicaldb_key
and a._object_key = m._marker_key
and m._organism_key != 1
;
update acc_accession a
set private = 1 
from toUpdate5 t
where t._accession_key = a._accession_key
;

-- non-mouse/should be private = 0/leave as is
-- 55 | Entrez Gene
-- 64 | HGNC
-- 178 | MyGene
-- 168 | neXtProt
-- 15 | OMIM
-- 47 | Rat Genome Database
-- 172 | Zebrafish Model Organism Database
--select m.symbol, m._organism_key, a.accid, a._logicaldb_key, l.name
--from acc_accession a, acc_logicaldb l, mrk_marker m 
--where a.private = 0 
--and a._mgitype_key = 2 
--and a._logicaldb_key not in (9,118)
--and a._logicaldb_key = l._logicaldb_key
--and a._object_key = m._marker_key
--and m._organism_key != 1
--order by m._organism_key, l.name, m.symbol
--;

-- allele
-- 138 | EUCOMM-projects
-- 126 | KOMP-CSD-Project
-- 125 | KOMP-Regeneron-Project
-- 166 | mirKO-project
-- 143 | NorCOMM-projects
select a.*
into temp table toUpdate3
from acc_accession a, acc_logicaldb l, all_allele m
where a.private = 1 
and a._mgitype_key = 11
and a._logicaldb_key = l._logicaldb_key
and a._object_key = m._allele_key
;
update acc_accession a
set private = 0 
from toUpdate3 t
where t._accession_key = a._accession_key
;

--strain/must check with Michelle
--             22 | JAX Registry
--              1 | MGI
--select substring(s.strain,1,50), a.accid, a._logicaldb_key, l.name
--from acc_accession a, acc_logicaldb l, prb_strain s
--where a.private = 1 
--and a._mgitype_key = 10
--and a._logicaldb_key = l._logicaldb_key
--and a._object_key = s._strain_key
--order by l.name, s.strain
--;
-- strain
select a.*
into temp table toUpdate4
from acc_accession a, acc_logicaldb l, prb_strain m
where a.private = 1 
and a._mgitype_key = 10
and a._logicaldb_key not in (1,22)
and a._logicaldb_key = l._logicaldb_key
and a._object_key = m._strain_key
;
update acc_accession a
set private = 0 
from toUpdate4 t
where t._accession_key = a._accession_key
;

-- genotype/leave as is/no changes
-- 1 | MGI
--select a.accid, a._logicaldb_key, l.name
--from acc_accession a, acc_logicaldb l
--where a.private = 1 
--and a._mgitype_key = 12
--and a._logicaldb_key = l._logicaldb_key
--order by l.name
--;

-- vocabluary/leave as is/no changes
--select a.accid, a._logicaldb_key, l.name, t.term, t._vocab_key
--from acc_accession a, acc_logicaldb l, voc_term t
--where a.private = 1 
--and a._mgitype_key = 13
--and a._logicaldb_key = l._logicaldb_key
--and a._object_key = t._term_key
--order by l.name
--;

-- organism/leave as is/no changes
--select a.accid, a._logicaldb_key, l.name, m.commonname
--from acc_accession a, acc_logicaldb l, mgi_organism m
--where a.private = 1 
--and a._mgitype_key = 20
--and a._logicaldb_key = l._logicaldb_key
--and a._object_key = m._organism_key
--order by l.name
--;

-- ES cell line/leave as is/no changes
--select a.accid, a._logicaldb_key, l.name
--from acc_accession a, acc_logicaldb l
--where a.private = 1 
--and a._mgitype_key = 28
--and a._logicaldb_key = l._logicaldb_key
--order by l.name
--;

-- _mgitype_key that have private = true accession ids
select distinct a._mgitype_key, t.name, a._logicaldb_key, l.name, a.private
from acc_accession a, acc_logicaldb l, acc_mgitype t
where a._logicaldb_key = l._logicaldb_key
and a._mgitype_key = t._mgitype_key
and a.private = 1
and a._mgitype_key not in (1, 3, 9, 12, 13, 20, 25, 28)
and a._logicaldb_key not in (1, 107, 130, 118, 117)
order by a._mgitype_key, a._logicaldb_key
;

EOSQL

date |tee -a $LOG

