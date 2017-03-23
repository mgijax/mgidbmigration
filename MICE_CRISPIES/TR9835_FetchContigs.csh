#!/bin/csh -fx

#
# Mirror refseq and genbank genomic release files
# Run record splitter to get mouse CON division
#
# Products:
#
# mirror_wget : branch
# refseqload : branch

###----------------------###
###--- initialization ---###
###----------------------###

cd `dirname $0` && source ../Configuration
setenv CWD `pwd`	# current working directory
echo "Server: ${PG_DBSERVER}"
echo "Database: ${PG_DBNAME}"

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}
date | tee -a ${LOG}
echo "--- Starting in ${CWD}..." | tee -a ${LOG}

#
# run migration
#

date | tee -a ${LOG}
echo "--- Mirror GenBank Genomic Release ---"  | tee -a ${LOG}
${MIRROR_WGET}/genbankGenomicRel.sh

date | tee -a ${LOG}
echo "--- Mirror RefSeq Genomic Release ---"  | tee -a ${LOG}
${MIRROR_WGET}/refseqGenomicRel.sh

date | tee -a ${LOG}
echo "--- Run GBRecordSplitter on GenBank Genomic Sequences---"  | tee -a ${LOG}
setenv INPUTFILES	"/data/downloads/genbank/gbcon*.seq.gz"
setenv OUTPUTFILE	"/mgi/all/wts_projects/9800/9835/contig_data/gbcon.mouse"
#/usr/bin/zcat ${INPUTFILES} | ${DLA_UTILS}/GBRecordSplitter.py -r 500000 -d CON -m -v ${OUTPUTFILE} 1

date | tee -a ${LOG}
echo "--- Run GBRecordSplitter on RefSeq Genomic Sequences ---"  | tee -a ${LOG}
setenv OUTPUTFILE	/mgi/all/wts_projects/9800/9835/contig_data/refseqcon.mouse

setenv INPUTFILES       /data/downloads/refseq/release/complete/complete.1.genomic.gbff.gz
/usr/bin/gunzip -c ${INPUTFILES} | ${DLA_UTILS}/GBRecordSplitter.py -r 500000 -d CON -m -v ${OUTPUTFILE} 1

setenv INPUTFILES       /data/downloads/refseq/release/complete/complete.10*.genomic.gbff.gz
/usr/bin/gunzip -c ${INPUTFILES} | ${DLA_UTILS}/GBRecordSplitter.py -r 500000 -d CON -m -v ${OUTPUTFILE} 2

setenv INPUTFILES       /data/downloads/refseq/release/complete/complete.11*.genomic.gbff.gz
/usr/bin/gunzip -c ${INPUTFILES} | ${DLA_UTILS}/GBRecordSplitter.py -r 500000 -d CON -m -v ${OUTPUTFILE} 3

setenv INPUTFILES       /data/downloads/refseq/release/complete/complete.12*.genomic.gbff.gz
/usr/bin/gunzip -c ${INPUTFILES} | ${DLA_UTILS}/GBRecordSplitter.py -r 500000 -d CON -m -v ${OUTPUTFILE} 4

setenv INPUTFILES       /data/downloads/refseq/release/complete/complete.13*.genomic.gbff.gz
/usr/bin/gunzip -c ${INPUTFILES} | ${DLA_UTILS}/GBRecordSplitter.py -r 500000 -d CON -m -v ${OUTPUTFILE} 5

setenv INPUTFILES       /data/downloads/refseq/release/complete/complete.14*.genomic.gbff.gz
/usr/bin/gunzip -c ${INPUTFILES} | ${DLA_UTILS}/GBRecordSplitter.py -r 500000 -d CON -m -v ${OUTPUTFILE} 6

setenv INPUTFILES       /data/downloads/refseq/release/complete/complete.15*.genomic.gbff.gz
/usr/bin/gunzip -c ${INPUTFILES} | ${DLA_UTILS}/GBRecordSplitter.py -r 500000 -d CON -m -v ${OUTPUTFILE} 7

setenv INPUTFILES       /data/downloads/refseq/release/complete/complete.16*.genomic.gbff.gz
/usr/bin/gunzip -c ${INPUTFILES} | ${DLA_UTILS}/GBRecordSplitter.py -r 500000 -d CON -m -v ${OUTPUTFILE} 8

setenv INPUTFILES       /data/downloads/refseq/release/complete/complete.17*.genomic.gbff.gz
/usr/bin/gunzip -c ${INPUTFILES} | ${DLA_UTILS}/GBRecordSplitter.py -r 500000 -d CON -m -v ${OUTPUTFILE} 9

setenv INPUTFILES       /data/downloads/refseq/release/complete/complete.18*.genomic.gbff.gz
/usr/bin/gunzip -c ${INPUTFILES} | ${DLA_UTILS}/GBRecordSplitter.py -r 500000 -d CON -m -v ${OUTPUTFILE} 10

setenv INPUTFILES       /data/downloads/refseq/release/complete/complete.19*.genomic.gbff.gz
/usr/bin/gunzip -c ${INPUTFILES} | ${DLA_UTILS}/GBRecordSplitter.py -r 500000 -d CON -m -v ${OUTPUTFILE} 11

setenv INPUTFILES       /data/downloads/refseq/release/complete/complete.2*.genomic.gbff.gz
/usr/bin/gunzip -c ${INPUTFILES} | ${DLA_UTILS}/GBRecordSplitter.py -r 500000 -d CON -m -v ${OUTPUTFILE} 12

setenv INPUTFILES       /data/downloads/refseq/release/complete/complete.3*.genomic.gbff.gz
/usr/bin/gunzip -c ${INPUTFILES} | ${DLA_UTILS}/GBRecordSplitter.py -r 500000 -d CON -m -v ${OUTPUTFILE} 13 

setenv INPUTFILES       /data/downloads/refseq/release/complete/complete.4*.genomic.gbff.gz
/usr/bin/gunzip -c ${INPUTFILES} | ${DLA_UTILS}/GBRecordSplitter.py -r 500000 -d CON -m -v ${OUTPUTFILE} 14

setenv INPUTFILES       /data/downloads/refseq/release/complete/complete.5*.genomic.gbff.gz
/usr/bin/gunzip -c ${INPUTFILES} | ${DLA_UTILS}/GBRecordSplitter.py -r 500000 -d CON -m -v ${OUTPUTFILE} 15

setenv INPUTFILES       /data/downloads/refseq/release/complete/complete.6*.genomic.gbff.gz
/usr/bin/gunzip -c ${INPUTFILES} | ${DLA_UTILS}/GBRecordSplitter.py -r 500000 -d CON -m -v ${OUTPUTFILE} 16

setenv INPUTFILES       /data/downloads/refseq/release/complete/complete.7*.genomic.gbff.gz
/usr/bin/gunzip -c ${INPUTFILES} | ${DLA_UTILS}/GBRecordSplitter.py -r 500000 -d CON -m -v ${OUTPUTFILE} 17

setenv INPUTFILES       /data/downloads/refseq/release/complete/complete.8*.genomic.gbff.gz
/usr/bin/gunzip -c ${INPUTFILES} | ${DLA_UTILS}/GBRecordSplitter.py -r 500000 -d CON -m -v ${OUTPUTFILE} 18

setenv INPUTFILES       /data/downloads/refseq/release/complete/complete.9*.genomic.gbff.gz
/usr/bin/gunzip -c ${INPUTFILES} | ${DLA_UTILS}/GBRecordSplitter.py -r 500000 -d CON -m -v ${OUTPUTFILE} 19

date | tee -a ${LOG}

