#!/bin/csh -f

#
# Template
#


if ( ${?MGICONFIG} == 0 ) then
        setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

date

#rcp bhmgiapp01:/data/loads/entrezgene/entrezgeneload/input/gene2accession ${DATALOADSOUTPUT}/entrezgene/entrezgeneload/input
#rcp bhmgiapp01:/data/loads/entrezgene/entrezgeneload/input/gene2accession.mgi ${DATALOADSOUTPUT}/entrezgene/entrezgeneload/input
#rcp bhmgiapp01:/data/loads/entrezgene/entrezgeneload/input/gene2accession.new ${DATALOADSOUTPUT}/entrezgene/entrezgeneload/input
#rcp bhmgiapp01:/data/loads/entrezgene/entrezgeneload/input/gene2pubmed ${DATALOADSOUTPUT}/entrezgene/entrezgeneload/input
#rcp bhmgiapp01:/data/loads/entrezgene/entrezgeneload/input/gene2pubmed.mgi ${DATALOADSOUTPUT}/entrezgene/entrezgeneload/input
#rcp bhmgiapp01:/data/loads/entrezgene/entrezgeneload/input/gene2refseq ${DATALOADSOUTPUT}/entrezgene/entrezgeneload/input
#rcp bhmgiapp01:/data/loads/entrezgene/entrezgeneload/input/gene2refseq.mgi ${DATALOADSOUTPUT}/entrezgene/entrezgeneload/input
#rcp bhmgiapp01:/data/loads/entrezgene/entrezgeneload/input/gene2refseq.new ${DATALOADSOUTPUT}/entrezgene/entrezgeneload/input
#rcp bhmgiapp01:/data/loads/entrezgene/entrezgeneload/input/gene_dbxref.bcp ${DATALOADSOUTPUT}/entrezgene/entrezgeneload/input
#rcp bhmgiapp01:/data/loads/entrezgene/entrezgeneload/input/gene_history ${DATALOADSOUTPUT}/entrezgene/entrezgeneload/input
#rcp bhmgiapp01:/data/loads/entrezgene/entrezgeneload/input/gene_history.mgi ${DATALOADSOUTPUT}/entrezgene/entrezgeneload/input
#rcp bhmgiapp01:/data/loads/entrezgene/entrezgeneload/input/gene_info ${DATALOADSOUTPUT}/entrezgene/entrezgeneload/input
#rcp bhmgiapp01:/data/loads/entrezgene/entrezgeneload/input/gene_info.bcp ${DATALOADSOUTPUT}/entrezgene/entrezgeneload/input
#rcp bhmgiapp01:/data/loads/entrezgene/entrezgeneload/input/gene_info.mgi ${DATALOADSOUTPUT}/entrezgene/entrezgeneload/input
#rcp bhmgiapp01:/data/loads/entrezgene/entrezgeneload/input/gene_synonym.bcp ${DATALOADSOUTPUT}/entrezgene/entrezgeneload/input
#rcp bhmgiapp01:/data/loads/entrezgene/entrezgeneload/input/mim2gene_medgen ${DATALOADSOUTPUT}/entrezgene/entrezgeneload/input
#rcp bhmgiapp01:/data/loads/entrezgene/entrezgeneload/input/mim2gene_medgen.mgi ${DATALOADSOUTPUT}/entrezgene/entrezgeneload/input

# truncate all of the dp_entrezgene tables/drop indexes
source ${ENTREZGENELOAD}/Configuration
${RADAR_DBSCHEMADIR}/table/DP_EntrezGene_truncate.logical
${RADAR_DBSCHEMADIR}/index/DP_EntrezGene_drop.logical

# foreach dp_entrezgene table
#       sanity check the table; should fail; should skip the egload/entrezgeneload
#       reload the dp_entrezgene table

${EGLOAD}/bin/egload.sh
${ENTREZGENELOAD}/loadAll.csh
${PG_DBUTILS}/bin/bcpin.csh ${MGD_DBSERVER} ${MGD_DBNAME} DP_EntrezGene_Info ${EGINPUTDIR} gene_info.bcp "\t" "\n" radar

${EGLOAD}/bin/egload.sh
${ENTREZGENELOAD}/loadAll.csh
${PG_DBUTILS}/bin/bcpin.csh ${MGD_DBSERVER} ${MGD_DBNAME} DP_EntrezGene_Accession ${EGINPUTDIR} gene2accession.new "\t" "\n" radar

${EGLOAD}/bin/egload.sh
${ENTREZGENELOAD}/loadAll.csh
${PG_DBUTILS}/bin/bcpin.csh ${MGD_DBSERVER} ${MGD_DBNAME} DP_EntrezGene_DBXRef ${EGINPUTDIR} gene_dbxref.bcp "\t" "\n" radar

${EGLOAD}/bin/egload.sh
${ENTREZGENELOAD}/loadAll.csh
${PG_DBUTILS}/bin/bcpin.csh ${MGD_DBSERVER} ${MGD_DBNAME} DP_EntrezGene_PubMed ${EGINPUTDIR} gene2pubmed.mgi "\t" "\n" radar

${EGLOAD}/bin/egload.sh
${ENTREZGENELOAD}/loadAll.csh
${PG_DBUTILS}/bin/bcpin.csh ${MGD_DBSERVER} ${MGD_DBNAME} DP_EntrezGene_RefSeq ${EGINPUTDIR} gene2refseq.new "\t" "\n" radar

${EGLOAD}/bin/egload.sh
${ENTREZGENELOAD}/loadAll.csh
${PG_DBUTILS}/bin/bcpin.csh ${MGD_DBSERVER} ${MGD_DBNAME} DP_EntrezGene_Synonym ${EGINPUTDIR} gene_synonym.bcp "\t" "\n" radar

${EGLOAD}/bin/egload.sh
${ENTREZGENELOAD}/loadAll.csh
${PG_DBUTILS}/bin/bcpin.csh ${MGD_DBSERVER} ${MGD_DBNAME} DP_EntrezGene_History ${EGINPUTDIR} gene_history.mgi "\t" "\n" radar

${EGLOAD}/bin/egload.sh
${ENTREZGENELOAD}/loadAll.csh
${PG_DBUTILS}/bin/bcpin.csh ${MGD_DBSERVER} ${MGD_DBNAME} DP_EntrezGene_MIM ${EGINPUTDIR} mim2gene_medgen.mgi "\t" "\n" radar

# create indexes
${RADAR_DBSCHEMADIR}/index/DP_EntrezGene_create.logical

# all dp_entrezgene tables have been tested for false sanity check
# reload all of the radar tables again
./loadFiles.csh

# run egload, entrezgeneload again; verify runs are successful
${EGLOAD}/bin/egload.sh
${ENTREZGENELOAD}/loadAll.csh

date

