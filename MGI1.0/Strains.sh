#!/bin/csh -f

#
# Migrate MGD3.3 Strains & Tissue data into MGI1.0 structures
#

setenv DSQUERY $1
setenv MGD $2
setenv CREATEIDX $3

set scripts = $SYBASE/admin

$scripts/indexes/MGD_DEV/STRAIN.drop $DSQUERY $MGD
$scripts/indexes/MGD_DEV/TISSUE.drop $DSQUERY $MGD

set sql = /tmp/$$.sql
 
cat > $sql << EOSQL
 
use master
go
 
sp_dboption $MGD, "select into", true
go
  
use $MGD
go
   
checkpoint
go
 
truncate table PRB_Strain
go

truncate table PRB_Tissue
go

truncate table PRB_Source
go

truncate table MLD_FISH
go

truncate table MLD_InSitu
go

truncate table CRS_Cross
go

truncate table PRB_Allele_Strain
go

checkpoint
go

quit
 
EOSQL
 
$scripts/dbo_sql $sql
rm $sql

# Create bcps and load

./Strains.py Strains
cat $scripts/.mgd_dbo_password | bcp $MGD..PRB_Strain in data/PRB_Strain.bcp -c -t\| -Umgd_dbo
cat $scripts/.mgd_dbo_password | bcp $MGD..PRB_Tissue in data/PRB_Tissue.bcp -c -t\| -Umgd_dbo

./Strains.py Other
cat $scripts/.mgd_dbo_password | bcp $MGD..PRB_Source in data/PRB_Source.bcp -c -t\| -Umgd_dbo
cat $scripts/.mgd_dbo_password | bcp $MGD..MLD_FISH in data/MLD_FISH.bcp -c -t\| -Umgd_dbo
cat $scripts/.mgd_dbo_password | bcp $MGD..MLD_InSitu in data/MLD_InSitu.bcp -c -t\| -Umgd_dbo
cat $scripts/.mgd_dbo_password | bcp $MGD..CRS_Cross in data/CRS_Cross.bcp -c -t\| -Umgd_dbo
uniq data/PRB_Allele_Strain.bcp > data/PRB_Allele_Strain.uniq.bcp
cat $scripts/.mgd_dbo_password | bcp $MGD..PRB_Allele_Strain in data/PRB_Allele_Strain.uniq.bcp -c -t\| -Umgd_dbo

set sql = /tmp/$$.sql
 
cat > $sql << EOSQL
 
use $MGD
go

/* Counts */
 
select count(*) "mgd..PRB_Strain" from mgd..PRB_Strain
go
 
select count(*) "PRB_Strain" from PRB_Strain
go
 
select count(*) "mgd..PRB_Source" from mgd..PRB_Source
go
 
select count(*) "Source Strain (NULL)" from mgd..PRB_Source where strain is null
go
 
select count(*) "Source Strain (not NULL)" from mgd..PRB_Source where strain is not null
go
 
select count(*) "Source Tissue (NULL)" from mgd..PRB_Source where tissue is null
go
 
select count(*) "Source Tissue (not NULL)" from mgd..PRB_Source where tissue is not null
go
 
select count(*) "PRB_Source" from PRB_Source
go
 
select count(*) "Source Strain (NULL)" from PRB_Source where _Strain_key < 0
go
 
select count(*) "Source Strain (not NULL)" from PRB_Source where _Strain_key > 0
go
 
select count(*) "Source Tissue (NULL)" from PRB_Source where _Tissue_key < 0
go
 
select count(*) "Source Tissue (not NULL)" from PRB_Source where _Tissue_key > 0
go
 
select count(*) "mgd..MLD_FISH" from mgd..MLD_FISH
go
 
select count(*) "MLD_FISH" from MLD_FISH
go
 
select count(*) "mgd..MLD_InSitu" from mgd..MLD_InSitu
go
 
select count(*) "MLD_InSitu" from MLD_InSitu
go
 
select count(*) "mgd..CRS_Cross" from mgd..CRS_Cross
go
 
select count(*) "CRS_Cross" from CRS_Cross
go

select m.strain from mgd..PRB_Source m, PRB_Source s
where s._Strain_key < 0 and s._Source_key = m._Source_key and m.strain is not null
go

select m.tissue from mgd..PRB_Source m, PRB_Source s
where s._Tissue_key < 0 and s._Source_key = m._Source_key and m.tissue is not null
go

checkpoint
go

quit
 
EOSQL
 
$scripts/dbo_sql $sql
rm $sql

if ( $CREATEIDX == "index" ) then
	$scripts/indexes/MGD_DEV/STRAIN.idx $DSQUERY $MGD
	$scripts/indexes/MGD_DEV/TISSUE.idx $DSQUERY $MGD
endif
