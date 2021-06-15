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
 

#
# TAGS
#
# mirror_wget : remove mim2gene_medgen from mirror_wget/ftp.ncbi.nih.gov
# entrezgeneload
# radardbschema : remove DP_EntrezGene_MIM
#

rm -rf ${DATADOWNLOADS}/ftp.ncbi.nih.gov/gene/DATA/mim2gene_medgen

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

select va._Term_key, mm._Marker_key, mo.commonName
        from voc_annot va, mrk_marker mm, mgi_organism mo
        where va._AnnotType_key = 1022
                and va._Object_key = mm._Marker_key
                and mm._Marker_Status_key = 1
                and va._Qualifier_key != 1614157
                and mm._Organism_key = mo._Organism_key
;

select mm._Marker_key, count(q._Term_key) as diseaseCount
        from voc_annot va,
                mrk_marker mm,
                voc_term q
        where va._AnnotType_key = 1022
                and va._Object_key = mm._Marker_key
                and va._Qualifier_key = q._Term_key
                and q.term is null
group by mm._Marker_key
;

delete from voc_annot where _annottype_key = 1022;
--drop table DP_EntrezGene_MIM;

EOSQL

${ENTREZGENELOAD}/human/load.csh | tee -a $LOG

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

select va._Term_key, mm._Marker_key, mo.commonName
        from voc_annot va, mrk_marker mm, mgi_organism mo
        where va._AnnotType_key = 1022
                and va._Object_key = mm._Marker_key
                and mm._Marker_Status_key = 1
                and va._Qualifier_key != 1614157
                and mm._Organism_key = mo._Organism_key
;

select mm._Marker_key, count(q._Term_key) as diseaseCount
        from voc_annot va,
                mrk_marker mm,
                voc_term q
        where va._AnnotType_key = 1022
                and va._Object_key = mm._Marker_key
                and va._Qualifier_key = q._Term_key
                and q.term is null
group by mm._Marker_key
;

EOSQL

date |tee -a $LOG

