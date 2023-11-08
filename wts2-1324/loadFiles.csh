#!/bin/csh -f

cd `dirname $0` && source ${ENTREZGENELOAD}/Configuration

cd ${EGINPUTDIR}

# truncate existing tables
${RADAR_DBSCHEMADIR}/table/DP_EntrezGene_truncate.logical 

# drop indexes
${RADAR_DBSCHEMADIR}/index/DP_EntrezGene_drop.logical 

# bcp new data into tables
${PG_DBUTILS}/bin/bcpin.csh ${MGD_DBSERVER} ${MGD_DBNAME} DP_EntrezGene_Info ${EGINPUTDIR} gene_info.bcp "\t" "\n" radar
${PG_DBUTILS}/bin/bcpin.csh ${MGD_DBSERVER} ${MGD_DBNAME} DP_EntrezGene_Accession ${EGINPUTDIR} gene2accession.new "\t" "\n" radar
${PG_DBUTILS}/bin/bcpin.csh ${MGD_DBSERVER} ${MGD_DBNAME} DP_EntrezGene_DBXRef ${EGINPUTDIR} gene_dbxref.bcp "\t" "\n" radar
${PG_DBUTILS}/bin/bcpin.csh ${MGD_DBSERVER} ${MGD_DBNAME} DP_EntrezGene_PubMed ${EGINPUTDIR} gene2pubmed.mgi "\t" "\n" radar
${PG_DBUTILS}/bin/bcpin.csh ${MGD_DBSERVER} ${MGD_DBNAME} DP_EntrezGene_RefSeq ${EGINPUTDIR} gene2refseq.new "\t" "\n" radar
${PG_DBUTILS}/bin/bcpin.csh ${MGD_DBSERVER} ${MGD_DBNAME} DP_EntrezGene_Synonym ${EGINPUTDIR} gene_synonym.bcp "\t" "\n" radar
${PG_DBUTILS}/bin/bcpin.csh ${MGD_DBSERVER} ${MGD_DBNAME} DP_EntrezGene_History ${EGINPUTDIR} gene_history.mgi "\t" "\n" radar
${PG_DBUTILS}/bin/bcpin.csh ${MGD_DBSERVER} ${MGD_DBNAME} DP_EntrezGene_MIM ${EGINPUTDIR} mim2gene_medgen.mgi "\t" "\n" radar

# create indexes
${RADAR_DBSCHEMADIR}/index/DP_EntrezGene_create.logical 

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 
 
/* convert the EG mapPosition values to MGI format (remove the leading chromosome value) */

update DP_EntrezGene_Info
set mapPosition = substring(mapPosition, 3, 100)
where taxID in (${HUMANTAXID}, ${RATTAXID}, ${DOGTAXID}, ${CHIMPTAXID}, ${CATTLETAXID}, ${CHICKENTAXID}, ${ZEBRAFISHTAXID}, ${MONKEYTAXID}, ${XENOPUSTAXID})
and mapPosition SIMILAR To '(1|2|3)(0|1|2|3|4|5|6|7|8|9)%'
;

update DP_EntrezGene_Info
set mapPosition = substring(mapPosition, 2, 100)
where taxID in (${HUMANTAXID}, ${RATTAXID}, ${DOGTAXID}, ${CHIMPTAXID}, ${CATTLETAXID}, ${CHICKENTAXID}, ${ZEBRAFISHTAXID}, ${MONKEYTAXID}, ${XENOPUSTAXID})
and mapPosition SIMILAR TO '(0|1|2|3|4|5|6|7|8|9)%'
;

update DP_EntrezGene_Info
set mapPosition = substring(mapPosition, 2, 100)
where taxID in (${HUMANTAXID}, ${RATTAXID})
and mapPosition SIMILAR TO '(X|Y)%'
;

update DP_EntrezGene_Info
set chromosome = 'UN'
where chromosome in ('Un', 'unknown', '-')
;

update DP_EntrezGene_Info
set chromosome = 'UN'
where chromosome like '%|Un'
;

update DP_EntrezGene_Info
set chromosome = 'XY'
where chromosome = 'X|Y'
;

delete from DP_EntrezGene_Accession
where not exists (select DP_EntrezGene_Info.* from DP_EntrezGene_Info
	where DP_EntrezGene_Accession.geneID = DP_EntrezGene_Info.geneID)
;

delete from DP_EntrezGene_Accession where status = 'SUPPRESSED';

delete from  DP_EntrezGene_DBXRef
where not exists (select DP_EntrezGene_Info.* from DP_EntrezGene_Info
	where DP_EntrezGene_DBXRef.geneID = DP_EntrezGene_Info.geneID)
;

delete from  DP_EntrezGene_PubMed
where not exists (select DP_EntrezGene_Info.* from DP_EntrezGene_Info
	where DP_EntrezGene_PubMed.geneID = DP_EntrezGene_Info.geneID)
;

delete from  DP_EntrezGene_RefSeq
where not exists (select DP_EntrezGene_Info.* from DP_EntrezGene_Info
	where DP_EntrezGene_RefSeq.geneID = DP_EntrezGene_Info.geneID)
;

delete from  DP_EntrezGene_Synonym
where not exists (select DP_EntrezGene_Info.* from DP_EntrezGene_Info
	where DP_EntrezGene_Synonym.geneID = DP_EntrezGene_Info.geneID)
;

delete from  DP_EntrezGene_History 
where not exists (select DP_EntrezGene_Info.* from DP_EntrezGene_Info
	where DP_EntrezGene_History.geneID = DP_EntrezGene_Info.geneID)
;

delete from  DP_EntrezGene_MIM
where not exists (select DP_EntrezGene_Info.* from DP_EntrezGene_Info
	where DP_EntrezGene_MIM.geneID = DP_EntrezGene_Info.geneID)
;

EOSQL


