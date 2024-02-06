#!/bin/csh -fx
#
# autolittriage
# lib_py_littriage
# htmpload
# gxdhtload
# pdfdownload
#

if ( ${?MGICONFIG} == 0 ) then
        setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}

date | tee -a ${LOG}

#cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

#select r._refs_key, c.mgiid, c.jnumid
#from bib_refs r, bib_citation_cache c, bib_workflow_relevance wr
#where r._refs_key = c._refs_key
#and r._refs_key = wr._refs_key
#and wr._relevance_key = 70594666
#and wr.isCurrent = 1
#and (wr.modification_date between '01/06/2024' and ('01/10/2024'::date + '1 day'::interval))
#;

#update bib_workflow_relevance wr
#set _relevance_key = 70594668
#where wr._relevance_key = 70594666
#and wr.isCurrent = 1
#and (wr.modification_date between '01/06/2024' and ('01/10/2024'::date + '1 day'::interval))
#;

#select c.mgiid
#from bib_refs r, bib_citation_cache c, bib_workflow_relevance wr
#where r._refs_key = c._refs_key
#and r._refs_key = wr._refs_key
#and wr._relevance_key = 70594668
#and wr.isCurrent = 1;
#;

EOSQL

#${LITTRIAGELOAD}/bin/processRelevance.sh | tee -a ${LOG}
#${LITTRIAGELOAD}/bin/processSecondary.sh | tee -a ${LOG}
${PDFDOWNLOAD}/download_papers.sh | tee -a ${LOG}

date | tee -a ${LOG}
