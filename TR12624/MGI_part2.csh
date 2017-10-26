#!/bin/csh -fx

#
# TR12624 Uniprot N:1 TR12646 GOA mouse ignore N:1
#
# (part 2 - run loads)
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
echo '--- starting part 2' | tee -a $LOG

echo 'MGD_DBNAME='$MGD_DBNAME | tee -a $LOG || exit 1
echo 'MGD_DBPASSWORDFILE='$MGD_DBPASSWORDFILE | tee -a $LOG || exit 1
echo 'MGD_DBSERVER='$MGD_DBSERVER | tee -a $LOG || exit 1
echo 'MGD_DBUSER='$MGD_DBUSER | tee -a $LOG || exit 1

#
# copy /data/downloads files needed for loads
# this only needs to happen on development servers
#
switch (`uname -n`)
    case bhmgiapp14ld:
    case bhmgidevapp01:
	date | tee -a ${LOG}
	echo 'run mirror_wget downloads' | tee -a $LOG || exit 1
	scp bhmgiapp01:/data/downloads/uniprot/uniprotmus.dat /data/downloads/uniprot
	scp bhmgiapp01:/data/downloads/go_translation/ec2go /data/downloads/go_translation
	scp bhmgiapp01:/data/downloads/go_translation/interpro2go /data/downloads/go_translation
	scp bhmgiapp01:/data/downloads/go_translation/uniprotkb_kw2go /data/downloads/go_translation
	scp bhmgiapp01:/data/downloads/goa/MOUSE/goa_mouse.gaf.gz /data/downloads/goa/MOUSE
	scp bhmgiapp01:/data/downloads/goa/MOUSE/goa_mouse_isoform.gaf.gz /data/downloads/goa/MOUSE
	scp bhmgiapp01:/data/downloads/purl.obolibrary.org/obo/uberon.obo /data/downloads/purl.obolibrary.org
	scp bhmgiapp01:/data/downloads/go_noctua/mgi.gpad /data/downloads/go_noctua
	scp bhmgiapp01:/data/downloads/raw.githubusercontent.com/evidenceontology/evidenceontology/master/gaf-eco-mapping-derived.txt /data/downloads/raw.githubusercontent.com/evidenceontology/evidenceontology/master
	scp bhmgiapp01:/data/downloads/ftp.pir.georgetown.edu/databases/ontology/pro_obo/pro.obo /data/downloads/ftp.pir.georgetown.edu/databases/ontology/pro_obo
	scp bhmgiapp01:/data/downloads/pir.georgetown.edu/projects/pro/pro_wv.obo /data/downloads/pir.georgetown.edu/projects/pro
	scp bhmgiapp01:/data/downloads/goa/HUMAN/goa_human.gaf.gz /data/downloads/goa/HUMAN
	scp bhmgiapp01:/data/downloads/goa/HUMAN/goa_human_isoform.gaf.gz /data/downloads/goa/HUMAN
	scp bhmgiapp01:/data/downloads/build.berkeleybop.org/job/gaf-check-mgi/lastSuccessfulBuild/artifact/gene_association.mgi.inf.gaf /data/downloads/build.berkeleybop.org/job/gaf-check-mgi/lastSuccessfulBuild/artifact
	scp bhmgiapp01:/data/downloads/go_gene_assoc/gene_association.rgd.gz /data/downloads/go_gene_assoc
	scp bhmgiapp01:/data/downloads/go_gene_assoc/submission/paint/pre-submission/gene_association.paint_mgi.gz /data/downloads/go_gene_assoc/submission/paint/pre-submission
        breaksw
endsw

# copy the new MCV obo file from the TR directory to the input directory
scp /mgi/all/wts_projects/12600/12643/MCV_Vocab.obo ${DATALOADSOUTPUT}/mgi/mcvload/input/

date | tee -a ${LOG}
echo 'Run UniProt Load' | tee -a ${LOG}
${UNIPROTLOAD}/bin/uniprotload.sh | tee -a ${LOG}

date | tee -a ${LOG}
echo 'Run GO Loads' | tee -a ${LOG}
${GOLOAD}/go.sh | tee -a ${LOG}

date | tee -a ${LOG}
echo 'Update Reference Workflow Status' | tee -a ${LOG}
${PG_DBUTILS}/sp/run_BIB_updateWFStatus.csh | tee -a ${LOG}

date | tee -a ${LOG}
echo 'Run MCV Vocabulary Load' | tee -a ${LOG}
${MCVLOAD}/bin/run_mcv_vocload.sh

#echo 'generate GPA file...'
#REPORTOUTPUTDIR=${PUBREPORTDIR}/output;export REPORTOUTPUTDIR
#${PUBRPTS}/daily/GO_gene_association.py | tee -a ${GOLOG}

date | tee -a ${LOG}
echo '--- finished part 2' | tee -a ${LOG}
