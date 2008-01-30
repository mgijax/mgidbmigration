#!/bin/csh
 
#
# Template for SQL report
#
# Notes:
#	- all public reports require a header and trailer
#	- all private reports require a header
#
# Usage:
#	template.sql PROD_MGI mgd
#


setenv DSQUERY $1
setenv MGD $2

/mgi/software/customSQL/bin/header.sh $0

isql -S$DSQUERY -Umgd_public -Pmgdpub -w200 <<END >> $0.rpt

use $MGD
go
/* # of VEGA gene models owned by assemblyseqload */
select count(*)
from SEQ_Sequence s, ACC_Accession a
where a._LogicalDB_key = 85
and a._MGIType_key = 19
and a._createdBy_key = 1439
and a._Object_key = s._Sequence_key
go

/* make sure all the sequence objects have same created by */
select count(*)
from SEQ_Sequence s, ACC_Accession a
where a._LogicalDB_key = 85
and a._MGIType_key = 19
and a._createdBy_key = 1439
and a._Object_key = s._Sequence_key
and a._createdBy_key = s._CreatedBy_key
go

/* # of VEGA gene models NOT owned by assemblyseqload i.e. the obsoletes*/
select a._CreatedBy_key, count(a._CreatedBy_key)
from SEQ_Sequence s, ACC_Accession a
where a._LogicalDB_key = 85
and a._MGIType_key = 19
and a._createdBy_key != 1439
and a._Object_key = s._Sequence_key
group by a._CreatedBy_key
go

/* make sure all the sequence objects have same created by */
select s._CreatedBy_key, count(s._CreatedBy_key)
from SEQ_Sequence s, ACC_Accession a
where a._LogicalDB_key = 85
and a._MGIType_key = 19
and a._createdBy_key != 1439
and a._Object_key = s._Sequence_key
and a._createdBy_key = s._CreatedBy_key
group by s._CreatedBy_key
go

/* # of VEGA assocload associations */
select count(*)
from ACC_Accession a
where a._LogicalDB_key = 85
and a._MGIType_key = 2
and a._createdBy_key = 1445
go

/* check VEGA assocload accession references */
select count(*)
from ACC_Accession a, ACC_AccessionReference r
where a._LogicalDB_key = 85
and a._MGIType_key = 2
and a._createdBy_key = 1445
and a._Accession_key = r._Accession_key
go

/* # of VEGA associations NOT owned by vega assocload  i.e. obsoletes */
select a._CreatedBy_key, count(a._CreatedBy_key)
from ACC_Accession a
where a._LogicalDB_key = 85
and a._MGIType_key = 2
and a._createdBy_key != 1445
group by a._CreatedBy_key
go

/* check non-assocload VEGA accession references */
select r._CreatedBy_key, count(r._CreatedBy_key)
from ACC_Accession a, ACC_AccessionReference r
where a._LogicalDB_key = 85
and a._MGIType_key = 2
and a._createdBy_key != 1445
and a._Accession_key = r._Accession_key
group by r._CreatedBy_key
go

/*  # of ENSEMBL gene models owned by assemblyseqload */
select count(*)
from SEQ_Sequence s, ACC_Accession a
where a._LogicalDB_key = 60
and a._MGIType_key = 19
and a._createdBy_key = 1410
and a._Object_key = s._Sequence_key
go

/* make sure all the sequence objects have same created by */
select count(*)
from SEQ_Sequence s, ACC_Accession a
where a._LogicalDB_key = 60
and a._MGIType_key = 19
and a._createdBy_key = 1410
and a._Object_key = s._Sequence_key
and a._createdBy_key = s._CreatedBy_key
go

/* # of ENSEMBL gene models NOT owned by assemblyseqload i.e. obsoletes */
select a._CreatedBy_key, count(a._CreatedBy_key)
from SEQ_Sequence s, ACC_Accession a
where a._LogicalDB_key = 60
and a._MGIType_key = 19
and a._createdBy_key != 1410
and a._Object_key = s._Sequence_key
group by a._CreatedBy_key
go

/* make sure all the sequence objects have same created by */
select s._CreatedBy_key, count(s._CreatedBy_key)
from SEQ_Sequence s, ACC_Accession a
where a._LogicalDB_key = 60
and a._MGIType_key = 19
and a._createdBy_key != 1410
and a._Object_key = s._Sequence_key
and a._createdBy_key = s._CreatedBy_key
group by s._CreatedBy_key
go

/* #of ENSEMBL assocload associations */
select count(*)
from ACC_Accession a
where a._LogicalDB_key = 60
and a._MGIType_key = 2
and a._createdBy_key = 1443
go

/* check ENSEMBL assocload accession references */
select count(*)
from ACC_Accession a, ACC_AccessionReference r
where a._LogicalDB_key = 60
and a._MGIType_key = 2
and a._createdBy_key = 1443
and a._Accession_key = r._Accession_key
go

/* # of ENSEMBL associations NOT owned by ensembl assocload i.e. obsoletes */
select a._CreatedBy_key, count(a._CreatedBy_key)
from ACC_Accession a
where a._LogicalDB_key = 60
and a._MGIType_key = 2
and a._createdBy_key != 1443
group by a._CreatedBy_key
go

/* check non-assocload ENSEMBL accession references */
select r._CreatedBy_key, count(r._CreatedBy_key)
from ACC_Accession a, ACC_AccessionReference r
where a._LogicalDB_key = 60
and a._MGIType_key = 2
and a._createdBy_key != 1443
and a._Accession_key = r._Accession_key
group by r._CreatedBy_key
go

quit

END

cat /mgi/software/customSQL/bin/trailer >> $0.rpt

