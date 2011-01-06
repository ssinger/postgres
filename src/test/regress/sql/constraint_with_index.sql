
-- Tests for 'constraints with existing index' feature
CREATE TABLE cwi_test( a int , b varchar(10), c char);

-- add some data so that all tests have something to work with.

INSERT INTO cwi_test VALUES(1, 2), (3, 4), (5, 6);

CREATE UNIQUE INDEX cwi_uniq_idx ON cwi_test(a , b);
ALTER TABLE cwi_test ADD primary key USING INDEX cwi_uniq_idx;

CREATE UNIQUE INDEX cwi_uniq2_idx ON cwi_test(b , a);
ALTER TABLE cwi_test DROP CONSTRAINT cwi_uniq_idx,
	ADD CONSTRAINT cwi_replaced_pkey PRIMARY KEY
		USING INDEX cwi_uniq2_idx;

DROP INDEX cwi_replaced_pkey;	-- Should fail; a constraint depends on it
DROP INDEX cwi_uniq2_idx;	-- Should fail; index doesn't exist

CREATE UNIQUE INDEX cwi_uniq2_idx ON cwi_test(a , b);
ALTER TABLE cwi_test ADD UNIQUE USING INDEX cwi_uniq2_idx;

-- Should fail; index doesn't exist
ALTER TABLE cwi_test ADD PRIMARY KEY
	USING INDEX cwi_idx_doesnt_exist;

ALTER TABLE cwi_test ADD UNIQUE (a);
-- Should fail; already attached to a constraint
ALTER TABLE cwi_test ADD PRIMARY KEY USING INDEX cwi_test_a_key;

CREATE INDEX cwi_idx1 ON cwi_test(a , b);

-- Should fail; non-unique
ALTER TABLE cwi_test ADD PRIMARY KEY USING INDEX cwi_idx1;

CREATE UNIQUE INDEX cwi_idx2 ON cwi_test(a , b);
-- Should fail; PKey already exists
ALTER TABLE cwi_test ADD PRIMARY KEY USING INDEX cwi_idx2;

ALTER TABLE cwi_test DROP CONSTRAINT cwi_replaced_pkey;

ALTER TABLE cwi_test ADD primary key(a, b);

CREATE UNIQUE INDEX cwi_idx3 ON cwi_test(a);

ALTER TABLE cwi_test DROP CONSTRAINT cwi_test_pkey, ADD PRIMARY KEY
	USING INDEX cwi_idx3;

-- Should fail; primary key now depends on it
DROP INDEX cwi_idx3;

CREATE UNIQUE INDEX cwi_part_idx ON cwi_test( a ) WHERE c = 'c';

CREATE UNIQUE INDEX cwi_expr_idx ON cwi_test( (b || 'c') );

-- Should fail; partial index not allowed
ALTER TABLE cwi_test ADD PRIMARY KEY USING INDEX cwi_part_idx;

-- Should fail; expressional index not allowed
ALTER TABLE cwi_test ADD PRIMARY KEY USING INDEX cwi_expr_idx;

SELECT relname, relkind FROM pg_class WHERE relname like E'cwi\\_%'
	ORDER BY relkind DESC, relname ASC;

DROP TABLE cwi_test;

SELECT relname, relkind FROM pg_class WHERE relname like E'cwi\\_%';

