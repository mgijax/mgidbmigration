#!/bin/csh -f

#
# Migration for MGI Fantom2
#

cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date >> $LOG
 
cat - <<EOSQL | doisql.csh $0 >> $LOG

use $DBNAME
go

sp_rename MGI_Fantom2, MGI_Fantom2_Old
go

end

EOSQL

#
# drop indexes, create new table
#
${newmgddbschema}/index/MGI_Fantom2Notes_drop.object >>& ${LOG}
${newmgddbschema}/table/MGI_Fantom2_create.object >>& ${LOG}
${newmgddbschema}/default/MGI_Fantom2_bind.object >>& ${LOG}

cat - <<EOSQL | doisql.csh $0 >> $LOG

use $DBNAME
go

insert into MGI_Fantom2
select _Fantom2_key,
        riken_seqid,
        riken_cloneid,
        riken_locusid,
        riken_cluster,
        convert(varchar(30), final_cluster),
        genbank_id,
        fantom1_clone,
        fantom2_clone,
        tiger_tc,
        unigene_id,
        seq_length,
        seq_note,
        seq_quality,
        riken_locusStatus,
        mgi_statusCode,
        mgi_numberCode,
        riken_numberCode,
        cds_category,
        cluster_analysis,
        gene_name_curation,
        cds_go_curation,
        blast_groupID,
        blast_mgiIDs,
        final_mgiID,
        final_symbol1,
        final_name1,
        final_symbol2,
        final_name2,
        nomen_event,
        "zilch",
        "zilch",
        "zilch",
        "zilch",
        "zilch",
        "zilch",
        createdBy,
        modifiedBy,
        creation_date,
        modification_date
from MGI_Fantom2_Old
go

update MGI_Fantom2 set final_cluster = "zilch" where final_cluster = "-1"
go

insert into MGI_Fantom2Notes select _Fantom2_key, 'H', 1, 'Species: |Symbol: |Name: |GenBank Seqid: |LocusLink ID: |GDB ID: |Evidence: |', getdate(), getdate() from MGI_Fantom2
go

dump tran ${DBNAME} with truncate_only
go

checkpoint
go

quit

EOSQL

${newmgddbschema}/index/MGI_Fantom2Notes_create.object >>& ${LOG}

date >> $LOG

