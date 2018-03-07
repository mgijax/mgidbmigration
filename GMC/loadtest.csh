#!/bin/csh -fx

#
# This is to test python/java load changes for GMC/schema changes
#

###----------------------###
###--- initialization ---###
###----------------------###


if ( ${?MGICONFIG} == 0 ) then
	setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}

date | tee -a ${LOG}

echo 'MGD_DBNAME='$MGD_DBNAME | tee -a $LOG || exit 1
echo 'MGD_DBPASSWORDFILE='$MGD_DBPASSWORDFILE | tee -a $LOG || exit 1
echo 'MGD_DBSERVER='$MGD_DBSERVER | tee -a $LOG || exit 1
echo 'MGD_DBUSER='$MGD_DBUSER | tee -a $LOG || exit 1

#
# copy files
# 

# assemblyseqload
scp bhmgiapp01:/data/loads/mgi/genemodelload/output/vega_genemodels_load.txt /data/loads/mgi/genemodelload/output/ | tee -a $LOG || exit 1
scp bhmgiapp01:/data/loads/mgi/genemodelload/output/vega_assoc_load.txt /data/loads/mgi/genemodelload/output/ | tee -a $LOG || exit 1
# refseqload files from radar.APP_FilesMirrored
scp bhmgiapp01:/data/downloads/ftp.ncbi.nih.gov/refseq_gbpreprocessor/output/RefSeq.473.001.gz /data/downloads/ftp.ncbi.nih.gov/refseq_gbpreprocessor/output/
# gbseqload files from radar.APP_FilesMirrored
scp bhmgiapp01:/data/downloads/ftp.ncbi.nih.gov/genbank_gbpreprocessor/output/GenBank.479.001.gz /data/downloads/ftp.ncbi.nih.gov/genbank_gbpreprocessor/output/
# spseqload
scp bhmgiapp01:/data/downloads/uniprot/uniprotmus.dat /data/downloads/uniprot/ | tee -a $LOG || exit 1
# vega_ensemblseqloade
scp bhmgiapp01:/data/loads/mgi/genemodelload/input/ensembl_assoc.txt /data/loads/mgi/genemodelload/input/ | tee -a $LOG || exit 1
scp bhmgiapp01:/data/loads/mgi/genemodelload/input/ensembl_biotypes.gz /data/loads/mgi/genemodelload/input/ | tee -a $LOG || exit 1
scp bhmgiapp01:/data/loads/mgi/genemodelload/input/ensembl_genemodels.txt /data/loads/mgi/genemodelload/input/ | tee -a $LOG || exit 1
scp bhmgiapp01:/data/loads/mgi/genemodelload/input/ensembl_ncrna.gz /data/loads/mgi/genemodelload/input/ | tee -a $LOG || exit 1
scp bhmgiapp01:/data/loads/mgi/genemodelload/input/ensembl_proteins.gz /data/loads/mgi/genemodelload/input/ | tee -a $LOG || exit 1
scp bhmgiapp01:/data/loads/mgi/genemodelload/input/ensembl_transcripts.gz /data/loads/mgi/genemodelload/input/ | tee -a $LOG || exit 1
scp bhmgiapp01:/data/loads/mgi/genemodelload/input/ensembl.txt /data/loads/mgi/genemodelload/input/ | tee -a $LOG || exit 1
# targeted alleleload
scp /mgi/all/wts_projects/12600/12662/sto198/mgi_es_cell_allele_report_test.tsv /data/downloads/www.mousephenotype.org/mgi_es_cell_allele_report.tsv | tee -a $LOG || exit 1
# pubmed to gene load, gets its own input via eutils
# littriageload - lori put files in place
# go loads to test vocload/annotload
scp bhmgiapp01:${DATADOWNLOADS}/goa/HUMAN/goa_human.gaf.gz ${DATADOWNLOADS}/goa/HUMAN
scp bhmgiapp01:${DATADOWNLOADS}/goa/HUMAN/goa_human_isoform.gaf.gz ${DATADOWNLOADS}/goa/HUMAN
scp bhmgiapp01:${DATADOWNLOADS}/goa/MOUSE/goa_mouse.gaf.gz ${DATADOWNLOADS}/goa/MOUSE
scp bhmgiapp01:${DATADOWNLOADS}/goa/MOUSE/goa_mouse_isoform.gaf.gz ${DATADOWNLOADS}/goa/MOUSE
scp bhmgiapp01:${DATADOWNLOADS}/goa/MOUSE/goa_mouse_complex.gaf.gz ${DATADOWNLOADS}/goa/MOUSE
scp bhmgiapp01:${DATADOWNLOADS}/goa/MOUSE/goa_mouse_rna.gaf.gz ${DATADOWNLOADS}/goa/MOUSE
scp bhmgiapp01:${DATADOWNLOADS}/purl.obolibrary.org/obo/uberon.obo ${DATADOWNLOADS}/purl.obolibrary.org/obo
scp bhmgiapp01:${DATADOWNLOADS}/build.berkeleybop.org/job/gaf-check-mgi/lastSuccessfulBuild/artifact/gene_association.mgi.inf.gaf ${DATADOWNLOADS}/build.berkeleybop.org/job/gaf-check-mgi/lastSuccessfulBuild/artifact
scp bhmgiapp01:${DATADOWNLOADS}/go_noctua/mgi.gpad ${DATADOWNLOADS}/go_noctua
scp bhmgiapp01:${DATADOWNLOADS}/raw.githubusercontent.com/evidenceontology/evidenceontology/master/gaf-eco-mapping-derived.txt ${DATADOWNLOADS}/raw.githubusercontent.com/evidenceontology/evidenceontology/master
scp bhmgiapp01:${DATADOWNLOADS}/go_gene_assoc/gene_association.rgd.gz ${DATADOWNLOADS}/go_gene_assoc
scp bhmgiapp01:${DATADOWNLOADS}/go_gene_assoc/submission/paint/pre-submission/gene_association.paint_mgi.gz ${DATADOWNLOADS}/go_gene_assoc/submission/paint/pre-submission

#
# alleleload/htmpload
#
scp bhmgiapp01:${DATADOWNLOADS}/dmdd.org.uk/DMDD_MP_annotations.tsv ${DATADOWNLOADS}/dmdd.org.uk
scp bhmgiapp01:${DATADOWNLOADS}/www.ebi.ac.uk/impc_lacz.json ${DATADOWNLOADS}/www.ebi.ac.uk
scp bhmgiapp01:${DATADOWNLOADS}/www.mousephenotype.org/mp2_load_phenotyping_colonies_report.tsv ${DATADOWNLOADS}/www.mousephenotype.org
scp bhmgiapp01:${DATADOWNLOADS}/www.ebi.ac.uk/impc.json ${DATADOWNLOADS}/www.ebi.ac.uk

#
# run loads
#

date | tee -a ${LOG}
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

select max(_Assoc_key) from mgi_reference_assoc;
select max(_Assoc_key) from seq_source_assoc;
select max(_Assoc_key) from all_allele_cellline;
select max(_AnnotEvidence_key) from voc_evidence;
select max(_StrainMarker_key) from prb_strain_marker;

-- for alleleload : deletes alleles
select * from ALL_Allele 
where (creation_date between '02/04/2017' and ('02/04/2017'::date + '1 day'::interval))
;
delete from ALL_Allele
where (creation_date between '02/04/2017' and ('02/04/2017'::date + '1 day'::interval))
;

-- for htmpload : genotypes/strains
select * from voc_annot where _annottype_key = 1002 and _object_key in (82750,82747,82742,82740,82743,82749,82744);
select * from gxd_genotype where _strain_key between 76936 and 76942;
select * from prb_strain where _strain_key between 76936 and 76942;

delete from voc_annot where _annottype_key = 1002 and _object_key in (82750,82747,82742,82740,82743,82749,82744);
delete from gxd_genotype where _strain_key between 76936 and 76942;
delete from prb_strain where _strain_key between 76936 and 76942;

EOSQL
rm -rf ${DATALOADSOUTPUT}/mgi/htmpload/*/input/last*

${GBSEQLOAD}/bin/gbseqload.sh | tee -a $LOG || exit 1
${REFSEQLOAD}/bin/refseqload.sh | tee -a $LOG || exit 1
${SPSEQLOAD}/bin/spseqload.sh spseqload.config | tee -a $LOG || exit 1
${PUBMED2GENELOAD}/bin/pubmed2geneload.sh
${LITTRIAGELOAD}/bin/littriageload.sh
${ALLELELOAD}/bin/makeIKMC.sh ikmc.config
${HTMPLOAD}/bin/runMpLoads.sh

#
# get current max keys, compare to sequence vals in stdout
#
date | tee -a ${LOG}
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
    select max(_Assoc_key) from mgi_reference_assoc;
    select max(_Assoc_key) from seq_source_assoc;
    select max(_Assoc_key) from all_allele_cellline;
    select max(_AnnotEvidence_key) from voc_evidence;
    select max(_StrainMarker_key) from prb_strain_marker;

EOSQL
date | tee -a ${LOG}

