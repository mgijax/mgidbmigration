#!/bin/csh -fx

#
# Migration for TR10273 -- Europhenome/Sanger MP annotations
# Sex-Auto

###----------------------###
###--- initialization ---###
###----------------------###

source ../Configuration

echo "Server: ${MGD_DBSERVER}"
echo "Database: ${MGD_DBNAME}"

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}

date | tee -a ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use $MGD_DBNAME
go

/* chr = 'X', state is homozygous or heterzygous ==> F */

select aa.accID, substring(t.term,1,25) as term, m.chromosome, p._EvidenceProperty_key
into #toupdate1
from VOC_Annot a, VOC_Evidence e, VOC_Evidence_Property p,
     VOC_Term t, GXD_AllelePair ap, ACC_Accession aa, MRK_Marker m
where a._AnnotType_key = 1002
and a._Annot_key = e._Annot_key
and e._AnnotEvidence_key = p._AnnotEvidence_key
and a._Term_key = t._Term_key
and a._Object_key = ap._Genotype_key
and ap._Genotype_key = aa._Object_key
and aa._MGIType_key = 12
and ap._Marker_key = m._Marker_key
and m.chromosome = 'X'
and ap._PairState_key in (847138, 847137)
go

update VOC_Evidence_Property
set value = 'F'
from #toupdate1 t, VOC_Evidence_Property p
where t._EvidenceProperty_key = p._EvidenceProperty_key
go

select * from #toupdate1 order by accID
go

/* chr = 'X', state is Hemizygous X-linked ==> M */

select aa.accID, substring(t.term,1,25) as term, m.chromosome, p._EvidenceProperty_key
into #toupdate2
from VOC_Annot a, VOC_Evidence e, VOC_Evidence_Property p,
     VOC_Term t, GXD_AllelePair ap, ACC_Accession aa, MRK_Marker m
where a._AnnotType_key = 1002
and a._Annot_key = e._Annot_key
and e._AnnotEvidence_key = p._AnnotEvidence_key
and a._Term_key = t._Term_key
and a._Object_key = ap._Genotype_key
and ap._Genotype_key = aa._Object_key
and aa._MGIType_key = 12
and ap._Marker_key = m._Marker_key
and m.chromosome = 'X'
and ap._PairState_key in (847133)
go
     
update VOC_Evidence_Property
set value = 'M'
from #toupdate2 t, VOC_Evidence_Property p
where t._EvidenceProperty_key = p._EvidenceProperty_key
go

select * from #toupdate2 order by accID
go

/* chr = 'Y' ==> M */

select aa.accID, substring(t.term,1,25) as term, m.chromosome, p._EvidenceProperty_key
into #toupdate3
from VOC_Annot a, VOC_Evidence e, VOC_Evidence_Property p,
     VOC_Term t, GXD_AllelePair ap, ACC_Accession aa, MRK_Marker m
where a._AnnotType_key = 1002
and a._Annot_key = e._Annot_key
and e._AnnotEvidence_key = p._AnnotEvidence_key
and a._Term_key = t._Term_key
and a._Object_key = ap._Genotype_key
and ap._Genotype_key = aa._Object_key
and aa._MGIType_key = 12
and ap._Marker_key = m._Marker_key
and m.chromosome = 'Y'
go
     
update VOC_Evidence_Property
set value = 'M'
from #toupdate3 t, VOC_Evidence_Property p
where t._EvidenceProperty_key = p._EvidenceProperty_key
go

select * from #toupdate3 order by accID
go

/* MP:0001145, MP:0003698, MP:0002789, MP:0006262 ==> M */
/* MP:0006362, MP:0001156, MP:0002673, MP:0003597, MP:0010357, MP:0001380 => M */

select aa.accID, substring(t.term,1,25) as term, p._EvidenceProperty_key
into #toupdate4
from VOC_Annot a, VOC_Evidence e, VOC_Evidence_Property p,
     VOC_Term t, ACC_Accession aa, ACC_Accession aaa
where a._AnnotType_key = 1002
and a._Annot_key = e._Annot_key
and e._AnnotEvidence_key = p._AnnotEvidence_key
and a._Term_key = t._Term_key
and a._Object_key = aa._Object_key
and aa._MGIType_key = 12
and a._Term_key = aaa._Object_key
and aaa._MGIType_key = 13
and aaa.accID in ('MP:0001145', 'MP:0003698', 'MP:0002789', 'MP:0006262', 'MP:0006362', 'MP:0001156', 'MP:0002673', 'MP:0003597', 'MP:0010357', 'MP:0001380')
go
     
update VOC_Evidence_Property
set value = 'M'
from #toupdate4 t, VOC_Evidence_Property p
where t._EvidenceProperty_key = p._EvidenceProperty_key
go

select * from #toupdate4 order by accID
go

/* children of ==> M */

select aa.accID, aaa.accID as childAccID, substring(t.term,1,25) as term, p._EvidenceProperty_key
into #toupdate5
from VOC_Annot a, VOC_Evidence e, VOC_Evidence_Property p,
     VOC_Term t, ACC_Accession aa, ACC_Accession aaa,
     DAG_Closure dc
where a._AnnotType_key = 1002
and a._Annot_key = e._Annot_key
and e._AnnotEvidence_key = p._AnnotEvidence_key
and a._Term_key = t._Term_key
and a._Object_key = aa._Object_key
and aa._MGIType_key = 12
and a._Term_key = aaa._Object_key
and aaa._MGIType_key = 13
and dc._DAG_key = 4
and dc._AncestorObject_key in (50301,50449,50531,54793,55401,718760,865129,1072176,2506309,6150751)
and a._Term_key = dc._DescendentObject_key
go
     
update VOC_Evidence_Property
set value = 'M'
from #toupdate5 t, VOC_Evidence_Property p
where t._EvidenceProperty_key = p._EvidenceProperty_key
go

select * from #toupdate5 order by accID
go

/* MP:0003699, MP:0008779, MP:0002788, MP:0008000 or child ==> F */
/* MP:0006361, MP:0001931, MP:0001119, MP:0009222, MP:0001376, MP:0000627 => F */

select aa.accID, substring(t.term,1,25) as term, p._EvidenceProperty_key
into #toupdate6
from VOC_Annot a, VOC_Evidence e, VOC_Evidence_Property p,
     VOC_Term t, ACC_Accession aa, ACC_Accession aaa
where a._AnnotType_key = 1002
and a._Annot_key = e._Annot_key
and e._AnnotEvidence_key = p._AnnotEvidence_key
and a._Term_key = t._Term_key
and a._Object_key = aa._Object_key
and aa._MGIType_key = 12
and a._Term_key = aaa._Object_key
and aaa._MGIType_key = 13
and aaa.accID in ('MP:0003699', 'MP:0008779', 'MP:0002788', 'MP:0008000', 'MP:0006361', 'MP:0001931', 'MP:0001119', 'MP:0009222', 'MP:0001376', 'MP:0000627')
go
     
update VOC_Evidence_Property
set value = 'F'
from #toupdate6 t, VOC_Evidence_Property p
where t._EvidenceProperty_key = p._EvidenceProperty_key
go

select * from #toupdate6 order by accID
go

/* children of or child ==> F */

select aa.accID, aaa.accID as childAccID, substring(t.term,1,25) as term, p._EvidenceProperty_key
into #toupdate7
from VOC_Annot a, VOC_Evidence e, VOC_Evidence_Property p,
     VOC_Term t, ACC_Accession aa, ACC_Accession aaa,
     DAG_Closure dc
where a._AnnotType_key = 1002
and a._Annot_key = e._Annot_key
and e._AnnotEvidence_key = p._AnnotEvidence_key
and a._Term_key = t._Term_key
and a._Object_key = aa._Object_key
and aa._MGIType_key = 12
and a._Term_key = aaa._Object_key
and aaa._MGIType_key = 13
and dc._DAG_key = 4
and dc._AncestorObject_key in (49936,50300,50529,50448,55400,865128,2506308,2310645,3311115,4043320)
and a._Term_key = dc._DescendentObject_key
go

update VOC_Evidence_Property
set value = 'F'
from #toupdate7 t, VOC_Evidence_Property p
where t._EvidenceProperty_key = p._EvidenceProperty_key
go

select * from #toupdate7 order by accID
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

