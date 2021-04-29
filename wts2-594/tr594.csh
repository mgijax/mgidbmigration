#!/bin/csh -f

#
# gxd_genotype._genotype_key
# change 1 to 3
# change -1 to 1
# change -2 to 2
#
# prb_strain
# change -1 to 1
# change -2 to 2
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
 
${PUBRPTS}/mgimarkerfeed/mgimarkerfeed_reports.csh
wc -l ${PUBREPORTDIR}/output/mgimarkerfeed/genotype.bcp ${PUBREPORTDIR}/output/mgimarkerfeed/strain.bcp

${MGD_DBSCHEMADIR}/table/GXD_Expression_truncate.object 
${MGD_DBSCHEMADIR}/table/MRK_DO_Cache_truncate.object 

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

select * from gxd_genotype where _genotype_key < 5;

-- change 1 to 3
select count(*) from GXD_HTSample where _genotype_key = 1;
select count(*) from GXD_HTSample_RNASeqSet where _genotype_key = 1;
select count(*) from GXD_GelLane where _genotype_key = 1;
select count(*) from GXD_Specimen where _genotype_key = 1;
select count(*) from GXD_AlleleGenotype where _genotype_key = 1;
select count(*) from GXD_AllelePair where _genotype_key = 1;
select count(*) from PRB_Strain_Genotype where _genotype_key = 1;
select count(*) from VOC_Annot where _annottype_key in (1002,1020) and _object_key = 1;

select count(*) from IMG_ImagePane_Assoc where _MGIType_key = 12 and _object_key = 1;
select count(*) from MAP_Coord_Feature where _MGIType_key = 12 and _object_key = 1;
select count(*) from MAP_Coordinate where _MGIType_key = 12 and _object_key = 1;
select count(*) from MGI_Note where _MGIType_key = 12 and _object_key = 1;
select count(*) from MGI_Property where _MGIType_key = 12 and _object_key = 1;
select count(*) from MGI_Reference_Assoc where _MGIType_key = 12 and _object_key = 1;
select count(*) from MGI_Synonym where _MGIType_key = 12 and _object_key = 1;
select count(*) from VOC_AnnotHeader where _AnnotType_key = 1002 and _object_key = 1;
select count(*) from ACC_Accession where _MGIType_key = 12 and _object_key = 1;

insert into gxd_genotype values(3,38048,0,null,3982946,1001,1001,now(),now());

update GXD_HTSample set _genotype_key = 3 where _genotype_key = 1;
update GXD_HTSample_RNASeqSet set _genotype_key = 3 where _genotype_key = 1;
update GXD_GelLane set _genotype_key = 3 where _genotype_key = 1;
update GXD_Specimen set _genotype_key = 3 where _genotype_key = 1;
update GXD_AlleleGenotype set _genotype_key = 3 where _genotype_key = 1;
update GXD_AllelePair set _genotype_key = 3 where _genotype_key = 1;
update PRB_Strain_Genotype set _genotype_key = 3 where _genotype_key = 1;
update VOC_Annot set _object_key = 3 where _annottype_key in (1002,1020) and _object_key = 1;

update IMG_ImagePane_Assoc set _object_key = 3 where _MGIType_key = 12 and _object_key = 1;
update MAP_Coord_Feature set _object_key = 3 where _MGIType_key = 12 and _object_key = 1;
update MAP_Coordinate set _object_key = 3 where _MGIType_key = 12 and _object_key = 1;
update MGI_Note set _object_key = 3 where _MGIType_key = 12 and _object_key = 1;
update MGI_Property set _object_key = 3 where _MGIType_key = 12 and _object_key = 1;
update MGI_Reference_Assoc set _object_key = 3 where _MGIType_key = 12 and _object_key = 1;
update MGI_Synonym set _object_key = 3 where _MGIType_key = 12 and _object_key = 1;
update VOC_AnnotHeader set _object_key = 3 where _AnnotType_key = 1002 and _object_key = 1;
update ACC_Accession set _object_key = 3 where _MGIType_key = 12 and _object_key = 1;

delete from gxd_genotype where _genotype_key = 1;

select count(*) from GXD_HTSample where _genotype_key = 3;
select count(*) from GXD_HTSample_RNASeqSet where _genotype_key = 3;
select count(*) from GXD_GelLane where _genotype_key = 3;
select count(*) from GXD_Specimen where _genotype_key = 3;
select count(*) from GXD_AlleleGenotype where _genotype_key = 3;
select count(*) from GXD_AllelePair where _genotype_key = 3;
select count(*) from PRB_Strain_Genotype where _genotype_key = 3;
select count(*) from VOC_Annot where _annottype_key in (1002,1020) and _object_key = 3;

select count(*) from IMG_ImagePane_Assoc where _MGIType_key = 12 and _object_key = 3;
select count(*) from MAP_Coord_Feature where _MGIType_key = 12 and _object_key = 3;
select count(*) from MAP_Coordinate where _MGIType_key = 12 and _object_key = 3;
select count(*) from MGI_Note where _MGIType_key = 12 and _object_key = 3;
select count(*) from MGI_Property where _MGIType_key = 12 and _object_key = 3;
select count(*) from MGI_Reference_Assoc where _MGIType_key = 12 and _object_key = 3;
select count(*) from MGI_Synonym where _MGIType_key = 12 and _object_key = 3;
select count(*) from VOC_AnnotHeader where _AnnotType_key = 1002 and _object_key = 3;
select count(*) from ACC_Accession where _MGIType_key = 12 and _object_key = 3;

-- change -1 to 1
select count(*) from GXD_HTSample where _genotype_key = -1;
select count(*) from GXD_HTSample_RNASeqSet where _genotype_key = -1;
select count(*) from GXD_GelLane where _genotype_key = -1;
select count(*) from GXD_Specimen where _genotype_key = -1;
select count(*) from GXD_AlleleGenotype where _genotype_key = -1;
select count(*) from GXD_AllelePair where _genotype_key = -1;
select count(*) from PRB_Strain_Genotype where _genotype_key = -1;
select count(*) from VOC_Annot where _annottype_key in (1002,1020) and _object_key = -1;

select count(*) from IMG_ImagePane_Assoc where _MGIType_key = 12 and _object_key = -1;
select count(*) from MAP_Coord_Feature where _MGIType_key = 12 and _object_key = -1;
select count(*) from MAP_Coordinate where _MGIType_key = 12 and _object_key = -1;
select count(*) from MGI_Note where _MGIType_key = 12 and _object_key = -1;
select count(*) from MGI_Property where _MGIType_key = 12 and _object_key = -1;
select count(*) from MGI_Reference_Assoc where _MGIType_key = 12 and _object_key = -1;
select count(*) from MGI_Synonym where _MGIType_key = 12 and _object_key = -1;
select count(*) from VOC_AnnotHeader where _AnnotType_key = 1002 and _object_key = -1;
select count(*) from ACC_Accession where _MGIType_key = 12 and _object_key = -1;

insert into gxd_genotype values(1,-1,0,null,3982946,1001,1001,now(),now());

update GXD_HTSample set _genotype_key = 1 where _genotype_key = -1;
update GXD_HTSample_RNASeqSet set _genotype_key = 1 where _genotype_key = -1;
update GXD_GelLane set _genotype_key = 1 where _genotype_key = -1;
update GXD_Specimen set _genotype_key = 1 where _genotype_key = -1;
update GXD_AlleleGenotype set _genotype_key = 1 where _genotype_key = -1;
update GXD_AllelePair set _genotype_key = 1 where _genotype_key = -1;
update PRB_Strain_Genotype set _genotype_key = 1 where _genotype_key = -1;
update VOC_Annot set _object_key = 1 where _annottype_key in (1002,1020) and _object_key = -1;

update IMG_ImagePane_Assoc set _object_key = 1 where _MGIType_key = 12 and _object_key = -1;
update MAP_Coord_Feature set _object_key = 1 where _MGIType_key = 12 and _object_key = -1;
update MAP_Coordinate set _object_key = 1 where _MGIType_key = 12 and _object_key = -1;
update MGI_Note set _object_key = 1 where _MGIType_key = 12 and _object_key = -1;
update MGI_Property set _object_key = 1 where _MGIType_key = 12 and _object_key = -1;
update MGI_Reference_Assoc set _object_key = 1 where _MGIType_key = 12 and _object_key = -1;
update MGI_Synonym set _object_key = 1 where _MGIType_key = 12 and _object_key = -1;
update VOC_AnnotHeader set _object_key = 1 where _AnnotType_key = 1002 and _object_key = -1;
update ACC_Accession set _object_key = 1 where _MGIType_key = 12 and _object_key = -1;

delete from gxd_genotype where _genotype_key = -1;

select count(*) from GXD_HTSample where _genotype_key = 1;
select count(*) from GXD_HTSample_RNASeqSet where _genotype_key = 1;
select count(*) from GXD_GelLane where _genotype_key = 1;
select count(*) from GXD_Specimen where _genotype_key = 1;
select count(*) from GXD_AlleleGenotype where _genotype_key = 1;
select count(*) from GXD_AllelePair where _genotype_key = 1;
select count(*) from PRB_Strain_Genotype where _genotype_key = 1;
select count(*) from VOC_Annot where _annottype_key in (1002,1020) and _object_key = 1;

select count(*) from IMG_ImagePane_Assoc where _MGIType_key = 12 and _object_key = 1;
select count(*) from MAP_Coord_Feature where _MGIType_key = 12 and _object_key = 1;
select count(*) from MAP_Coordinate where _MGIType_key = 12 and _object_key = 1;
select count(*) from MGI_Note where _MGIType_key = 12 and _object_key = 1;
select count(*) from MGI_Property where _MGIType_key = 12 and _object_key = 1;
select count(*) from MGI_Reference_Assoc where _MGIType_key = 12 and _object_key = 1;
select count(*) from MGI_Synonym where _MGIType_key = 12 and _object_key = 1;
select count(*) from VOC_AnnotHeader where _AnnotType_key = 1002 and _object_key = 1;
select count(*) from ACC_Accession where _MGIType_key = 12 and _object_key = 1;

-- change -2 to 2
select count(*) from GXD_HTSample where _genotype_key = -2;
select count(*) from GXD_HTSample_RNASeqSet where _genotype_key = -2;
select count(*) from GXD_GelLane where _genotype_key = -2;
select count(*) from GXD_Specimen where _genotype_key = -2;
select count(*) from GXD_AlleleGenotype where _genotype_key = -2;
select count(*) from GXD_AllelePair where _genotype_key = -2;
select count(*) from PRB_Strain_Genotype where _genotype_key = -2;
select count(*) from VOC_Annot where _annottype_key in (1002,1020) and _object_key = -2;

select count(*) from IMG_ImagePane_Assoc where _MGIType_key = 12 and _object_key = -2;
select count(*) from MAP_Coord_Feature where _MGIType_key = 12 and _object_key = -2;
select count(*) from MAP_Coordinate where _MGIType_key = 12 and _object_key = -2;
select count(*) from MGI_Note where _MGIType_key = 12 and _object_key = -2;
select count(*) from MGI_Property where _MGIType_key = 12 and _object_key = -2;
select count(*) from MGI_Reference_Assoc where _MGIType_key = 12 and _object_key = -2;
select count(*) from MGI_Synonym where _MGIType_key = 12 and _object_key = -2;
select count(*) from VOC_AnnotHeader where _AnnotType_key = 1002 and _object_key = -2;
select count(*) from ACC_Accession where _MGIType_key = 12 and _object_key = -2;

insert into gxd_genotype values(2,-2,0,null,3982946,1001,1001,now(),now());

update GXD_HTSample set _genotype_key = 2 where _genotype_key = -2;
update GXD_HTSample_RNASeqSet set _genotype_key = 2 where _genotype_key = -2;
update GXD_GelLane set _genotype_key = 2 where _genotype_key = -2;
update GXD_Specimen set _genotype_key = 2 where _genotype_key = -2;
update GXD_AlleleGenotype set _genotype_key = 2 where _genotype_key = -2;
update GXD_AllelePair set _genotype_key = 2 where _genotype_key = -2;
update PRB_Strain_Genotype set _genotype_key = 2 where _genotype_key = -2;
update VOC_Annot set _object_key = 2 where _annottype_key in (1002,1020) and _object_key = -2;

update IMG_ImagePane_Assoc set _object_key = 2 where _MGIType_key = 12 and _object_key = -2;
update MAP_Coord_Feature set _object_key = 2 where _MGIType_key = 12 and _object_key = -2;
update MAP_Coordinate set _object_key = 2 where _MGIType_key = 12 and _object_key = -2;
update MGI_Note set _object_key = 2 where _MGIType_key = 12 and _object_key = -2;
update MGI_Property set _object_key = 2 where _MGIType_key = 12 and _object_key = -2;
update MGI_Reference_Assoc set _object_key = 2 where _MGIType_key = 12 and _object_key = -2;
update MGI_Synonym set _object_key = 2 where _MGIType_key = 12 and _object_key = -2;
update VOC_AnnotHeader set _object_key = 2 where _AnnotType_key = 1002 and _object_key = -2;
update ACC_Accession set _object_key = 2 where _MGIType_key = 12 and _object_key = -2;

delete from gxd_genotype where _genotype_key = -2;

select count(*) from GXD_HTSample where _genotype_key = 2;
select count(*) from GXD_HTSample_RNASeqSet where _genotype_key = 2;
select count(*) from GXD_GelLane where _genotype_key = 2;
select count(*) from GXD_Specimen where _genotype_key = 2;
select count(*) from GXD_AlleleGenotype where _genotype_key = 2;
select count(*) from GXD_AllelePair where _genotype_key = 2;
select count(*) from PRB_Strain_Genotype where _genotype_key = 2;
select count(*) from VOC_Annot where _annottype_key in (1002,1020) and _object_key = 2;

select count(*) from IMG_ImagePane_Assoc where _MGIType_key = 12 and _object_key = 2;
select count(*) from MAP_Coord_Feature where _MGIType_key = 12 and _object_key = 2;
select count(*) from MAP_Coordinate where _MGIType_key = 12 and _object_key = 2;
select count(*) from MGI_Note where _MGIType_key = 12 and _object_key = 2;
select count(*) from MGI_Property where _MGIType_key = 12 and _object_key = 2;
select count(*) from MGI_Reference_Assoc where _MGIType_key = 12 and _object_key = 2;
select count(*) from MGI_Synonym where _MGIType_key = 12 and _object_key = 2;
select count(*) from VOC_AnnotHeader where _AnnotType_key = 1002 and _object_key = 2;
select count(*) from ACC_Accession where _MGIType_key = 12 and _object_key = 2;

select * from gxd_genotype where _genotype_key < 5;

-- prb_strain

select * from prb_strain where _strain_key < 5;

-- change -1 to 1

select count(*) from ALL_Allele where _strain_key = -1;
select count(*) from ALL_CellLine where _strain_key = -1;
select count(*) from ALL_Variant where _strain_key = -1;
select count(*) from GXD_Genotype where _strain_key = -1;
select count(*) from MLD_FISH where _strain_key = -1;
select count(*) from MLD_InSitu where _strain_key = -1;
select count(*) from MRK_StrainMarker where _strain_key = -1;
select count(*) from PRB_Allele_Strain where _strain_key = -1;
select count(*) from PRB_Source where _strain_key = -1;
select count(*) from PRB_Strain_Genotype where _strain_key = -1;
select count(*) from PRB_Strain_Marker where _strain_key = -1;
select count(*) from RI_RISet where _strain_key_1 = -1;
select count(*) from RI_RISet where _strain_key_2 = -1;
select count(*) from CRS_Cross where _StrainHO_key = -1;
select count(*) from CRS_Cross where _StrainHT_key = -1;
select count(*) from CRS_Cross where _femalestrain_key = -1;
select count(*) from CRS_Cross where _malestrain_key = -1;

select count(*) from IMG_ImagePane_Assoc where _MGIType_key = 10 and _object_key = -1;
select count(*) from MAP_Coord_Feature where _MGIType_key = 10 and _object_key = -1;
select count(*) from MAP_Coordinate where _MGIType_key = 10 and _object_key = -1;
select count(*) from MGI_Note where _MGIType_key = 10 and _object_key = -1;
select count(*) from MGI_Property where _MGIType_key = 10 and _object_key = -1;
select count(*) from MGI_Reference_Assoc where _MGIType_key = 10 and _object_key = -1;
select count(*) from MGI_Synonym where _MGIType_key = 10 and _object_key = -1;
select count(*) from VOC_Annot where _AnnotType_key in (1008, 1009) and _object_key = -1;
select count(*) from ACC_Accession where _MGIType_key = 10 and _object_key = -1;

insert into prb_strain values(1,481338,3410535, 'Not Specified',0,0,0,1001,1001,now(),now());

update ALL_Allele set _strain_key = 1 where _strain_key = -1;
update ALL_CellLine set _strain_key = 1 where _strain_key = -1;
update ALL_Variant set _strain_key = 1 where _strain_key = -1;
update GXD_Genotype set _strain_key = 1 where _strain_key = -1;
update MLD_FISH set _strain_key = 1 where _strain_key = -1;
update MLD_InSitu set _strain_key = 1 where _strain_key = -1;
update MRK_StrainMarker set _strain_key = 1 where _strain_key = -1;
update PRB_Allele_Strain set _strain_key = 1 where _strain_key = -1;
update PRB_Source set _strain_key = 1 where _strain_key = -1;
update PRB_Strain_Genotype set _strain_key = 1 where _strain_key = -1;
update PRB_Strain_Marker set _strain_key = 1 where _strain_key = -1;
update RI_RISet set _strain_key_1 = 1 where _strain_key_1 = -1;
update RI_RISet set _strain_key_2 = 1 where _strain_key_2 = -1;
update CRS_Cross set _StrainHO_key = 1 where _strainho_key = -1;
update CRS_Cross set _StrainHT_key = 1 where _strainht_key = -1;
update CRS_Cross set _femalestrain_key = 1 where _femalestrain_key = -1;
update CRS_Cross set _malestrain_key = 1 where _malestrain_key = -1;

update IMG_ImagePane_Assoc set _Object_key = 1 where _MGIType_key = 10 and _object_key = -1;
update MAP_Coord_Feature set _Object_key = 1 where _MGIType_key = 10 and _object_key = -1;
update MAP_Coordinate set _Object_key = 1 where _MGIType_key = 10 and _object_key = -1;
update MGI_Note set _Object_key = 1 where _MGIType_key = 10 and _object_key = -1;
update MGI_Property set _Object_key = 1 where _MGIType_key = 10 and _object_key = -1;
update MGI_Reference_Assoc set _Object_key = 1 where _MGIType_key = 10 and _object_key = -1;
update MGI_Synonym set _Object_key = 1 where _MGIType_key = 10 and _object_key = -1;
update VOC_Annot set _Object_key = 1 where _AnnotType_key in (1008, 1009) and _object_key = -1;
update ACC_Accession set _Object_key = 1 where _MGIType_key = 10 and _object_key = -1;

delete from prb_strain where _strain_key = -1;

select count(*) from ALL_Allele where _strain_key = 1;
select count(*) from ALL_CellLine where _strain_key = 1;
select count(*) from ALL_Variant where _strain_key = 1;
select count(*) from GXD_Genotype where _strain_key = 1;
select count(*) from MLD_FISH where _strain_key = 1;
select count(*) from MLD_InSitu where _strain_key = 1;
select count(*) from MRK_StrainMarker where _strain_key = 1;
select count(*) from PRB_Allele_Strain where _strain_key = 1;
select count(*) from PRB_Source where _strain_key = 1;
select count(*) from PRB_Strain_Genotype where _strain_key = 1;
select count(*) from PRB_Strain_Marker where _strain_key = 1;
select count(*) from RI_RISet where _strain_key_1 = 1;
select count(*) from RI_RISet where _strain_key_2 = 1;
select count(*) from CRS_Cross where _StrainHO_key = 1;
select count(*) from CRS_Cross where _StrainHT_key = 1;
select count(*) from CRS_Cross where _femalestrain_key = 1;
select count(*) from CRS_Cross where _malestrain_key = 1;

select count(*) from IMG_ImagePane_Assoc where _MGIType_key = 10 and _object_key = 1;
select count(*) from MAP_Coord_Feature where _MGIType_key = 10 and _object_key = 1;
select count(*) from MAP_Coordinate where _MGIType_key = 10 and _object_key = 1;
select count(*) from MGI_Note where _MGIType_key = 10 and _object_key = 1;
select count(*) from MGI_Property where _MGIType_key = 10 and _object_key = 1;
select count(*) from MGI_Reference_Assoc where _MGIType_key = 10 and _object_key = 1;
select count(*) from MGI_Synonym where _MGIType_key = 10 and _object_key = 1;
select count(*) from VOC_Annot where _AnnotType_key in (1008, 1009) and _object_key = 1;
select count(*) from ACC_Accession where _MGIType_key = 10 and _object_key = 1;

-- change -2 to 2

select count(*) from ALL_Allele where _strain_key = -2;
select count(*) from ALL_CellLine where _strain_key = -2;
select count(*) from ALL_Variant where _strain_key = -2;
select count(*) from GXD_Genotype where _strain_key = -2;
select count(*) from MLD_FISH where _strain_key = -2;
select count(*) from MLD_InSitu where _strain_key = -2;
select count(*) from MRK_StrainMarker where _strain_key = -2;
select count(*) from PRB_Allele_Strain where _strain_key = -2;
select count(*) from PRB_Source where _strain_key = -2;
select count(*) from PRB_Strain_Genotype where _strain_key = -2;
select count(*) from PRB_Strain_Marker where _strain_key = -2;
select count(*) from RI_RISet where _strain_key_1 = -2;
select count(*) from RI_RISet where _strain_key_2 = -2;
select count(*) from CRS_Cross where _StrainHO_key = -2;
select count(*) from CRS_Cross where _StrainHT_key = -2;
select count(*) from CRS_Cross where _femalestrain_key = -2;
select count(*) from CRS_Cross where _malestrain_key = -2;

select count(*) from IMG_ImagePane_Assoc where _MGIType_key = 10 and _object_key = -2;
select count(*) from MAP_Coord_Feature where _MGIType_key = 10 and _object_key = -2;
select count(*) from MAP_Coordinate where _MGIType_key = 10 and _object_key = -2;
select count(*) from MGI_Note where _MGIType_key = 10 and _object_key = -2;
select count(*) from MGI_Property where _MGIType_key = 10 and _object_key = -2;
select count(*) from MGI_Reference_Assoc where _MGIType_key = 10 and _object_key = -2;
select count(*) from MGI_Synonym where _MGIType_key = 10 and _object_key = -2;
select count(*) from VOC_Annot where _AnnotType_key in (1008, 1009) and _object_key = -2;
select count(*) from ACC_Accession where _MGIType_key = 10 and _object_key = -2;

insert into prb_strain values(2,481338,3410535, 'Not Applicable',0,0,0,1001,1001,now(),now());

update ALL_Allele set _strain_key = 2 where _strain_key = -2;
update ALL_CellLine set _strain_key = 2 where _strain_key = -2;
update ALL_Variant set _strain_key = 2 where _strain_key = -2;
update GXD_Genotype set _strain_key = 2 where _strain_key = -2;
update MLD_FISH set _strain_key = 2 where _strain_key = -2;
update MLD_InSitu set _strain_key = 2 where _strain_key = -2;
update MRK_StrainMarker set _strain_key = 2 where _strain_key = -2;
update PRB_Allele_Strain set _strain_key = 2 where _strain_key = -2;
update PRB_Source set _strain_key = 2 where _strain_key = -2;
update PRB_Strain_Genotype set _strain_key = 2 where _strain_key = -2;
update PRB_Strain_Marker set _strain_key = 2 where _strain_key = -2;
update RI_RISet set _strain_key_1 = 2 where _strain_key_1 = -2;
update RI_RISet set _strain_key_2 = 2 where _strain_key_2 = -2;
update CRS_Cross set _StrainHO_key = 2 where _strainho_key = -2;
update CRS_Cross set _StrainHT_key = 2 where _strainht_key = -2;
update CRS_Cross set _femalestrain_key = 2 where _femalestrain_key = -2;
update CRS_Cross set _malestrain_key = 2 where _malestrain_key = -2;

update IMG_ImagePane_Assoc set _Object_key = 2 where _MGIType_key = 10 and _object_key = -2;
update MAP_Coord_Feature set _Object_key = 2 where _MGIType_key = 10 and _object_key = -2;
update MAP_Coordinate set _Object_key = 2 where _MGIType_key = 10 and _object_key = -2;
update MGI_Note set _Object_key = 2 where _MGIType_key = 10 and _object_key = -2;
update MGI_Property set _Object_key = 2 where _MGIType_key = 10 and _object_key = -2;
update MGI_Reference_Assoc set _Object_key = 2 where _MGIType_key = 10 and _object_key = -2;
update MGI_Synonym set _Object_key = 2 where _MGIType_key = 10 and _object_key = -2;
update VOC_Annot set _Object_key = 2 where _AnnotType_key in (1008, 1009) and _object_key = -2;
update ACC_Accession set _Object_key = 2 where _MGIType_key = 10 and _object_key = -2;

delete from prb_strain where _strain_key = -2;

select count(*) from ALL_Allele where _strain_key = 2;
select count(*) from ALL_CellLine where _strain_key = 2;
select count(*) from ALL_Variant where _strain_key = 2;
select count(*) from GXD_Genotype where _strain_key = 2;
select count(*) from MLD_FISH where _strain_key = 2;
select count(*) from MLD_InSitu where _strain_key = 2;
select count(*) from MRK_StrainMarker where _strain_key = 2;
select count(*) from PRB_Allele_Strain where _strain_key = 2;
select count(*) from PRB_Source where _strain_key = 2;
select count(*) from PRB_Strain_Genotype where _strain_key = 2;
select count(*) from PRB_Strain_Marker where _strain_key = 2;
select count(*) from RI_RISet where _strain_key_1 = 2;
select count(*) from RI_RISet where _strain_key_2 = 2;
select count(*) from CRS_Cross where _StrainHO_key = 2;
select count(*) from CRS_Cross where _StrainHT_key = 2;
select count(*) from CRS_Cross where _femalestrain_key = 2;
select count(*) from CRS_Cross where _malestrain_key = 2;

select count(*) from IMG_ImagePane_Assoc where _MGIType_key = 10 and _object_key = 2;
select count(*) from MAP_Coord_Feature where _MGIType_key = 10 and _object_key = 2;
select count(*) from MAP_Coordinate where _MGIType_key = 10 and _object_key = 2;
select count(*) from MGI_Note where _MGIType_key = 10 and _object_key = 2;
select count(*) from MGI_Property where _MGIType_key = 10 and _object_key = 2;
select count(*) from MGI_Reference_Assoc where _MGIType_key = 10 and _object_key = 2;
select count(*) from MGI_Synonym where _MGIType_key = 10 and _object_key = 2;
select count(*) from VOC_Annot where _AnnotType_key in (1008, 1009) and _object_key = 2;
select count(*) from ACC_Accession where _MGIType_key = 10 and _object_key = 2;

select * from prb_strain where _strain_key < 5;

EOSQL

${MGICACHELOAD}/gxdexpression.csh
${MRKCACHELOAD}/mrkdo.csh

${PUBRPTS}/mgimarkerfeed/mgimarkerfeed_reports.csh
wc -l ${PUBREPORTDIR}/output/mgimarkerfeed/genotype.bcp ${PUBREPORTDIR}/output/mgimarkerfeed/strain.bcp

date |tee -a $LOG

