#!/bin/sh

#
# truncate all GO Annotations (_annottype_key = 1000)
#

cd `dirname $0`

if [ "${MGICONFIG}" = "" ]
then
    MGICONFIG=/usr/local/mgi/live/mgiconfig
    export MGICONFIG
fi

. ${MGICONFIG}/master.config.sh

date
 
${PG_MGD_DBSCHEMADIR}/trigger/VOC_Evidence_Property_drop.object

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 

select _annot_key into temp toDelete from voc_annot where _annottype_key = 1000;
create index idxtodelete on toDelete(_annot_key);

delete from mgi_note using toDelete, voc_evidence, voc_evidence_property
where toDelete._annot_key = voc_evidence._annot_key 
and voc_evidence._annotevidence_key = voc_evidence_property._annotevidence_key
and voc_evidence_property._evidenceproperty_key = mgi_note._object_key 
and mgi_note._mgitype_key = 41;

delete from voc_evidence_property using toDelete, voc_evidence 
where toDelete._annot_key = voc_evidence._annot_key and voc_evidence._annotevidence_key = voc_evidence_property._annotevidence_key;

delete from voc_evidence using toDelete where toDelete._annot_key = voc_evidence._annot_key;

delete from voc_annot where _annottype_key = 1000;

EOSQL

${PG_MGD_DBSCHEMADIR}/trigger/VOC_Evidence_Property_create.object 

date 
