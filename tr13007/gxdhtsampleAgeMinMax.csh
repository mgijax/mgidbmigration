#!/bin/sh

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0
DROP FUNCTION IF EXISTS gxdhtsampleAgeMinMax();
EOSQL

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0

CREATE OR REPLACE FUNCTION gxdhtsampleAgeMinMax (
)
RETURNS VOID AS
\$\$

DECLARE
v_pkey int; 	/* primary key of records to UPDATE */
v_age prb_source.age%TYPE;
v_ageMin numeric;
v_ageMax numeric;
--age_cursor refcursor;

BEGIN

FOR v_pkey, v_age IN
SELECT _Sample_key, age
FROM GXD_HTSample
WHERE age not in ('postnatal year')
LOOP
	SELECT * FROM PRB_ageMinMax(v_age) into v_ageMin, v_ageMax;
	UPDATE GXD_HTSample
	SET ageMin = v_ageMin, ageMax = v_ageMax 
	WHERE _Sample_key = v_pkey;
END LOOP;

FOR v_pkey, v_age IN
SELECT _GelLane_key, age
FROM GXD_GelLane
WHERE ageMin = 5000 or ageMin is null
LOOP
	SELECT * FROM PRB_ageMinMax(v_age) into v_ageMin, v_ageMax;
	UPDATE GXD_GelLane
	SET ageMin = v_ageMin, ageMax = v_ageMax 
	WHERE _GelLane_key = v_pkey;
END LOOP;

FOR v_pkey, v_age IN
SELECT _Specimen_key, age
FROM GXD_Specimen
WHERE ageMin = 5000 or ageMin is null
LOOP
	SELECT * FROM PRB_ageMinMax(v_age) into v_ageMin, v_ageMax;
	UPDATE GXD_Specimen
	SET ageMin = v_ageMin, ageMax = v_ageMax 
	WHERE _Specimen_key = v_pkey;
END LOOP;

RETURN;

END;
\$\$
LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION gxdhtsampleAgeMinMax() TO public;

EOSQL
