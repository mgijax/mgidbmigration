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
 
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

delete from mgi_user where login in (
'NOCTUA_Alzheimers_University_of_Toronto',
'NOCTUA_ARUK-UCL',
'NOCTUA_BHF-UCL',
'NOCTUA_CACAO',
'NOCTUA_CAFA',
'NOCTUA_DFLAT',
'NOCTUA_dictyBase',
'NOCTUA_FlyBase',
'NOCTUA_GO_Central',
'NOCTUA_GOC-OWL',
'NOCTUA_HGNC',
'NOCTUA_IntAct',
'NOCTUA_NTNU_SB',
'NOCTUA_ParkinsonsUK-UCL',
'NOCTUA_PINC',
'NOCTUA_Reactome',
'NOCTUA_Roslin_Institute',
'NOCTUA_SynGO-UCL',
'NOCTUA_WormBase',
'NOCTUA_YuBioLab',
'NOCTUA_HGNC-UCL',
'GOA_RHEA',
'NOCTUA_ComplexPortal',
'NOCTUA_DisProt'
)
;

EOSQL

# mirror_wget
# remove: ftp.geneontology.org.goload
# remove: snapshot.geneontology.org.goload.noctua
# add:  snapshot.geneontology.org.goload.annotations
# add to packagelist.daily:  snapshot.geneontology.org.goload.annotations

${MIRROR_WGET} download_package snapshot.geneontology.org.goload.annotations

cd /data/downloads
rm -rf current.geneontology.org
rm -rf snapshot.geneontology.org/products
rm -rf go_noctua
ln -s go_noctua snapshot.geneontology.org/annotations

${GOLOAD}/go.sh | tee -a $LOG

date |tee -a $LOG

