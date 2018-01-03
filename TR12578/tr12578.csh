#!/bin/csh -fx

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
echo '--- starting part 1' | tee -a $LOG

echo 'MGD_DBNAME='$MGD_DBNAME | tee -a $LOG || exit 1
echo 'MGD_DBPASSWORDFILE='$MGD_DBPASSWORDFILE | tee -a $LOG || exit 1
echo 'MGD_DBSERVER='$MGD_DBSERVER | tee -a $LOG || exit 1
echo 'MGD_DBUSER='$MGD_DBUSER | tee -a $LOG || exit 1

date | tee -a ${LOG}
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
    select s.*
    into temporary table seqNoId
    from SEQ_Sequence s
    where  not exists ( select 1
    from ACC_Accession a
    where s._Sequence_key = a._Object_key
    and a._MGIType_key = 19)
    ;

    create index idx1 on seqNoId(_Sequence_key)
    ;

    delete from SEQ_Sequence s
    using seqNoId ni
    where s._SequenceProvider_key = 316383 -- NIA (164664)
    and s._Sequence_key = ni._Sequence_key
    ;

    delete from SEQ_Sequence s
    using seqNoId ni
    where s._SequenceProvider_key = 316381 -- DFCI (158168)
    and s._Sequence_key = ni._Sequence_key
    ;

    delete from SEQ_Sequence s
    using seqNoId ni
    where s._SequenceProvider_key = 316382 -- DoTS (670369)
    and s._Sequence_key = ni._Sequence_key
    ;

    delete from SEQ_Sequence s
    using seqNoId ni
    where s._SequenceProvider_key = 5112896 -- Ensembl Protein (234)
    and s._Sequence_key = ni._Sequence_key
    ;
EOSQL
