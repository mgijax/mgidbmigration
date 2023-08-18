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
 
#cd ${DATALOADSOUTPUT}/go/goamouse/output
#rm -rf a b
#cut -f11 goamouse.annot | sort | uniq > a
#cut -f1 -d"&" a | sort | uniq > b
#cat b

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

select _term_key, term
from voc_term 
where _vocab_key = 82
and note is null
and term in (
'acts_on_population_of',
'adjacent_to',
'causally_upstream_of',
'coincident_with',
'directly_positively_regulates',
'existence_overlaps',
'exists_during',
'gene product',
'go_qualifier_term',
'happens_during',
'has_end_location',
'has_input',
'has_output',
'has_participant',
'has_start_location',
'has_target_end_location',
'has_target_start_location',
'negatively_regulates',
'occurs_at',
'occurs_in',
'part_of',
'positively_regulates',
'produced_by',
'regulates',
'regulates_translation_of',
'regulates_transport_of',
'results_in_acquisition_of_features_of',
'results_in_determination_of',
'results_in_development_of',
'results_in_division_of',
'results_in_maturation_of',
'results_in_morphogenesis_of',
'results_in_movement_of',
'transports_or_maintains_localization_of'
)
order by term
;

EOSQL

date |tee -a $LOG

