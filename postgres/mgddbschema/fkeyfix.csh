#!/bin/csh -f

#
# Template
#

#setenv MGICONFIG /usr/local/mgi/live/mgiconfig
#setenv MGICONFIG /usr/local/mgi/test/mgiconfig
#source ${MGICONFIG}/master.config.csh

cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date | tee -a $LOG
 
cat - <<EOSQL | doisql.csh $MGD_DBSERVER $MGD_DBNAME $0 | tee -a $LOG

use $MGD_DBNAME
go

select a.* 
from MGI_Reference_Assoc a where not exists (select 1 from BIB_Refs r where a._Refs_key = r._Refs_key)
go

delete MGI_Reference_Assoc 
from MGI_Reference_Assoc a where not exists (select 1 from BIB_Refs r where a._Refs_key = r._Refs_key)
go

select a.* 
from MGI_Synonym a where not exists (select 1 from BIB_Refs r where a._Refs_key = r._Refs_key)
and a._Refs_key is not null
go

delete MGI_Synonym
from MGI_Synonym a where not exists (select 1 from BIB_Refs r where a._Refs_key = r._Refs_key)
and a._Refs_key is not null
go

select a.* 
from MLD_Notes a where not exists (select 1 from BIB_Refs r where a._Refs_key = r._Refs_key)
go

delete MLD_Notes
from MLD_Notes a where not exists (select 1 from BIB_Refs r where a._Refs_key = r._Refs_key)
go

select a.* 
from DAG_Edge a where not exists (select 1 from DAG_Node r where a._Parent_key = r._Node_key)
go

delete DAG_Edge
from DAG_Edge a where not exists (select 1 from DAG_Node r where a._Parent_key = r._Node_key)
go

select a.* 
from GXD_GelBand a where not exists (select 1 from GXD_GelLane r where a._GelLane_key = r._GelLane_key)
go

delete GXD_GelBand
from GXD_GelBand a where not exists (select 1 from GXD_GelLane r where a._GelLane_key = r._GelLane_key)
go

select a.* 
from GXD_Index_Stages a where not exists (select 1 from GXD_Index r where a._Index_key = r._Index_key)
go

delete GXD_Index_Stages
from GXD_Index_Stages a where not exists (select 1 from GXD_Index r where a._Index_key = r._Index_key)
go

select a.* 
from HMD_Homology_Marker a where not exists (select 1 from HMD_Homology r where a._Homology_key = r._Homology_key)
go

delete HMD_Homology_Marker
from HMD_Homology_Marker a where not exists (select 1 from HMD_Homology r where a._Homology_key = r._Homology_key)
go

select a.* 
from IMG_ImagePane a where not exists (select 1 from IMG_Image r where a._Image_key = r._Image_key)
go

delete IMG_ImagePane
from IMG_ImagePane a where not exists (select 1 from IMG_Image r where a._Image_key = r._Image_key)
go

select a.* 
from GXD_InSituResultImage a where not exists (select 1 from IMG_ImagePane r where a._ImagePane_key = r._ImagePane_key)
go

delete GXD_InSituResultImage
from GXD_InSituResultImage a where not exists (select 1 from IMG_ImagePane r where a._ImagePane_key = r._ImagePane_key)
go

select a.* 
from MGI_Synonym a where not exists (select 1 from MGI_SynonymType r where a._SynonymType_key = r._SynonymType_key)
go

delete MGI_Synonym
from MGI_Synonym a where not exists (select 1 from MGI_SynonymType r where a._SynonymType_key = r._SynonymType_key)
go

select a.* 
from PRB_Alias a where not exists (select 1 from PRB_Reference r where a._Reference_key = r._Reference_key)
go

delete PRB_Alias
from PRB_Alias a where not exists (select 1 from PRB_Reference r where a._Reference_key = r._Reference_key)
go

select a.* 
from PRB_Probe a where not exists (select 1 from PRB_Source r where a._Source_key = r._Source_key)
go

delete PRB_Probe
from PRB_Probe a where not exists (select 1 from PRB_Source r where a._Source_key = r._Source_key)
go

select a.* 
from CRS_Cross a where not exists (select 1 from PRB_Strain r where a._StrainHO_key = r._Strain_key)
go

delete CRS_Cross
from CRS_Cross a where not exists (select 1 from PRB_Strain r where a._StrainHO_key = r._Strain_key)
go

select a.* 
from PRB_Strain_Genotype a where not exists (select 1 from PRB_Strain r where a._Strain_key = r._Strain_key)
go

delete PRB_Strain_Genotype
from PRB_Strain_Genotype a where not exists (select 1 from PRB_Strain r where a._Strain_key = r._Strain_key)
go

select a.* 
from PRB_Strain_Marker a where not exists (select 1 from PRB_Strain r where a._Strain_key = r._Strain_key)
go

delete PRB_Strain_Marker
from PRB_Strain_Marker a where not exists (select 1 from PRB_Strain r where a._Strain_key = r._Strain_key)
go

select a.* 
from SEQ_Source_Assoc a where not exists (select 1 from SEQ_Sequence r where a._Sequence_key = r._Sequence_key)
go

delete SEQ_Source_Assoc
from SEQ_Source_Assoc a where not exists (select 1 from SEQ_Sequence r where a._Sequence_key = r._Sequence_key)
go

select a.* 
from VOC_Evidence a where not exists (select 1 from VOC_Annot r where a._Annot_key = r._Annot_key)
go

delete VOC_Evidence
from VOC_Evidence a where not exists (select 1 from VOC_Annot r where a._Annot_key = r._Annot_key)
go

select a.* 
from GXD_Index_Stages a where not exists (select 1 from VOC_Term r where a._StageID_key = r._Term_key)
go

delete GXD_Index_Stages
from GXD_Index_Stages a where not exists (select 1 from VOC_Term r where a._StageID_key = r._Term_key)
go

select a.* 
from mgi_translationtype a where not exists (select 1 from VOC_Vocab r where a._Vocab_key = r._Vocab_key)
go

select _MGIType_key, name from ACC_MGIType
go

select a.*
into #todelete
from ACC_Accession a where a._MGIType_key = 2
and not exists (select 1 from MRK_Marker r where a._Object_key = r._Marker_key)
go

delete ACC_Accession
from #todelete d, ACC_Accession a
where d._Accession_key = a._Accession_key
go

drop table #todelete
go

select a.* into #todelete
from ACC_Accession a where a._MGIType_key = 21
and not exists (select 1 from NOM_Marker r where a._Object_key = r._Nomen_key)
go

delete ACC_Accession
from #todelete d, ACC_Accession a
where d._Accession_key = a._Accession_key
go

drop table #todelete
go

select a.* from ACC_Accession a where a._MGIType_key = 1 and not exists (select 1 from BIB_Refs r where a._Object_key = r._Refs_key)
go

select a.* from ACC_Accession a where a._MGIType_key = 3
and not exists (select 1 from PRB_Probe r where a._Object_key = r._Probe_key)
go

select a.* from ACC_Accession a where a._MGIType_key = 4
and not exists (select 1 from MLD_Expts r where a._Object_key = r._Expt_key)
go

select a.* from ACC_Accession a where a._MGIType_key = 5
and not exists (select 1 from PRB_Source r where a._Object_key = r._Source_key)
go

select a.* from ACC_Accession a where a._MGIType_key = 6
and not exists (select 1 from GXD_Antibody r where a._Object_key = r._Antibody_key)
go

select a.* from ACC_Accession a where a._MGIType_key = 7
and not exists (select 1 from GXD_Antigen r where a._Object_key = r._Antigen_key)
go

select a.* from ACC_Accession a where a._MGIType_key = 8
and not exists (select 1 from GXD_Assay r where a._Object_key = r._Assay_key)
go

select a.* from ACC_Accession a where a._MGIType_key = 9
and not exists (select 1 from IMG_Image r where a._Object_key = r._Image_key)
go

select a.* from ACC_Accession a where a._MGIType_key = 10
and not exists (select 1 from PRB_Strain r where a._Object_key = r._Strain_key)
go

select a.* from ACC_Accession a where a._MGIType_key = 11
and not exists (select 1 from ALL_Allele r where a._Object_key = r._Allele_key)
go

select a.* from ACC_Accession a where a._MGIType_key = 12
and not exists (select 1 from GXD_Genotype r where a._Object_key = r._Genotype_key)
go

select a.* from ACC_Accession a where a._MGIType_key = 13
and not exists (select 1 from VOC_Term r where a._Object_key = r._Term_key)
go

select a.* from ACC_Accession a where a._MGIType_key = 14
and not exists (select 1 from VOC_Vocab r where a._Object_key = r._Vocab_key)
go

select a.* from ACC_Accession a where a._MGIType_key = 15 and not exists (select 1 from ACC_LogicalDB r where a._Object_key = r._LogicalDB_key)
go

select a.* from ACC_Accession a where a._MGIType_key = 16
and not exists (select 1 from ACC_ActualDB r where a._Object_key = r._ActualDB_key)
go

select a.* from ACC_Accession a where a._MGIType_key = 17
and not exists (select 1 from GXD_Index r where a._Object_key = r._Index_key)
go

select a.* from ACC_Accession a where a._MGIType_key = 19
and not exists (select 1 from SEQ_Sequence r where a._Object_key = r._Sequence_key)
go

select a.* from ACC_Accession a where a._MGIType_key = 19
and not exists (select 1 from SEQ_Sequence r where a._Object_key = r._Sequence_key)
go

select a.* from ACC_Accession a where a._MGIType_key = 20
and not exists (select 1 from MGI_Organism r where a._Object_key = r._Organism_key)
go

select a.* from ACC_Accession a where a._MGIType_key = 25
and not exists (select 1 from VOC_Evidence r where a._Object_key = r._AnnotEvidence_key)
go

select a.* from ACC_Accession a where a._MGIType_key = 28
and not exists (select 1 from ALL_CellLine r where a._Object_key = r._CellLine_key)
go

select a.* from ACC_Accession a where a._MGIType_key = 35
and not exists (select 1 from IMG_ImagePane r where a._Object_key = r._ImagePane_key)
go

select a.* from ACC_Accession a where a._MGIType_key = 38
and not exists (select 1 from GXD_Structure r where a._Object_key = r._Structure_key)
go

checkpoint
go

end

EOSQL

date |tee -a $LOG

