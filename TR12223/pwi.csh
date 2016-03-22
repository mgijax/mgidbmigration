#!/bin/csh -fx

#
# add 'label' to MGI_SetMember
#

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
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG || exit 1

select id, sql_text from PWI_Report where name in ('GXD Result Note Search');

select id, sql_text from PWI_Report where id = 2;

update PWI_Report set sql_text =
E'select distinct ac.accid as assay_mgiid,    
       ac_ref.accid as jnum_id,    
       gs.specimenlabel,    
       m.symbol as gene,    
       gisrs._stage_key as stage,    
       s.term as structure,    
       gisr.resultnote    
from GXD_Specimen gs    
             join GXD_Assay ga on ga._assay_key = gs._assay_key    
             join ACC_Accession ac on    
                     ac._object_key = ga._assay_key    
                     and ac.preferred = 1    
                     and ac._mgitype_key = 8    
                     and ac._logicaldb_key = 1    
             join ACC_Accession ac_ref on    
                     ac_ref._object_key = ga._refs_key    
                     and ac_ref.preferred = 1    
                     and ac_ref._mgitype_key = 1    
                     and ac_ref.prefixpart = \'J:\'    
                     and ac_ref._logicaldb_key = 1    
             join MRK_Marker m on m._marker_key = ga._marker_key    
             join GXD_InSituResult gisr on gisr._specimen_key = gs._specimen_key    
             join GXD_ISResultStructure gisrs on gisrs._result_key = gisr._result_key    
             join VOC_Term s on gisrs._emapa_term_key = s._term_key
            where ga._AssayType_key in (1, 6, 9) and lower(gisr.resultNote) like lower(\'%###Result Note Text###%\')
            order by gisrs._stage_key, s.term'
where id = 2;

select id, sql_text from PWI_Report where id = 2;

EOSQL
date | tee -a ${LOG}

