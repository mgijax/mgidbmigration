#!/bin/csh -f

#
# Template
#

#setenv MGICONFIG /usr/local/mgi/live/mgiconfig
#setenv MGICONFIG /usr/local/mgi/test/mgiconfig
#source ${MGICONFIG}/master.config.csh

cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date | tee -a $LOG
 
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh | tee -a $LOG

-- MGI:5310731
update image set external_link = '\\Link(https://www.google.com/|Test Link|)'
where image_key = 388284;

-- MGI:5429049
update image set external_link = '\\Link(http://connectivity.brain-map.org/transgenic/search?page_num=0&page_size=38&no_paging=false&exact_match=false&search_term=Calb2-IRES-cre&search_type=line|AIBS Data|)'
where image_key = 442098;

-- MGI:5429059
update image set external_link = '\\Link(http://connectivity.brain-map.org/transgenic/search?page_num=0&page_size=38&no_paging=false&exact_match=false&search_term=Calb2-IRES-cre&search_type=line|AIBS Data|)'
where image_key = 442108;

-- MGI:5429015
update image set external_link = '\\Link(http://connectivity.brain-map.org/transgenic/search?page_num=0&page_size=38&no_paging=false&exact_match=false&search_term=Calb2-IRES-cre&search_type=line|AIBS Data|)'
where image_key = 442066;

-- MGI:5429057
update image set external_link = '\\Link(http://connectivity.brain-map.org/transgenic/search?exact_match=false&search_term=Calb2-IRES-cre&search_type=line|AIBS Data|)'
where image_key = 442106;

-- MGI:5429064
update image set external_link = '\\Link(http://connectivity.brain-map.org/transgenic/search?page_num=0&page_size=38&no_paging=false&exact_match=false&search_term=Calb2-IRES-cre&search_type=line|AIBS Data|)'
where image_key = 442110;

-- MGI:5429003
update image set external_link = '\\Link(https://ndp.jax.org/NDPServe.dll?ViewItem?ItemID=29307&XPos=-11951804&YPos=-4048671&ZPos=0&Lens=0.6912477047653858&SignIn=Sign%20in%20as%20Guest|GRS Image|)'
where image_key = 442054;

-- MGI:5429005
update image set external_link = '\\Link(https://ndp.jax.org/NDPServe.dll?ViewItem?ItemID=29307&XPos=-12533302&YPos=3324627&ZPos=0&Lens=0.7870385852010384&SignIn=Sign%20in%20as%20Guest|GRS Image|)'
where image_key = 442056;

-- MGI:5429036
update image set external_link = '\\Link(http://connectivity.brain-map.org/transgenic/search?exact_match=false&search_term=Calb2-IRES-cre&search_type=line|GRS Image|)'
where image_key = 442086;

-- MGI:5428971
update image set external_link = '\\Link(https://ndp.jax.org/NDPServe.dll?ViewItem?ItemID=19847&XPos=20954428&YPos=-1405049&ZPos=0&Lens=40&SignIn=Sign%20in%20as%20Guest|GRS Image|)'
where image_key = 442038;

-- MGI:5429007
update image set external_link = '\\Link(https://ndp.jax.org/NDPServe.dll?ViewItem?ItemID=19855&XPos=19464953&YPos=7550599&ZPos=0&Lens=8.322464221082296&SignIn=Sign%20in%20as%20Guest|GRS Image|)'
where image_key = 442058;

EOSQL

date |tee -a $LOG

