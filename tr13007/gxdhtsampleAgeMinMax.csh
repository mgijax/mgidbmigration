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
	--FETCH age_cursor INTO v_pkey, v_age;
	--EXIT WHEN NOT FOUND;

	SELECT * FROM PRB_ageMinMax(v_age) into v_ageMin, v_ageMax;

	UPDATE GXD_HTSample
	SET ageMin = v_ageMin, ageMax = v_ageMax 
	WHERE _Sample_key = v_pkey;

END LOOP;

--CLOSE age_cursor;

RETURN;

END;
\$\$
LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION gxdhtsampleAgeMinMax() TO public;

EOSQL
