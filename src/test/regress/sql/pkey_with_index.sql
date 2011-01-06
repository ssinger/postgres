
-- Tests for 'constraints with existing index' feature
CREATE TABLE cwi_test( a int , b varchar(10), c char);

-- add some data so that all tests have something to work with.

INSERT INTO cwi_test VALUES( 1, 2 );
INSERT INTO cwi_test VALUES( 3, 4 );
INSERT INTO cwi_test VALUES( 5, 6 );

CREATE UNIQUE INDEX cwi_uniq_idx ON cwi_test(a , b);
ALTER TABLE cwi_test ADD primary key USING INDEX cwi_uniq_idx;

CREATE UNIQUE INDEX cwi_uniq2_idx ON cwi_test(b , a);
ALTER TABLE cwi_test DROP CONSTRAINT cwi_uniq_idx,
	ADD CONSTRAINT cwi_replaced_pkey PRIMARY KEY(b, a)
		WITH (INDEX = 'cwi_uniq2_idx');

DROP INDEX cwi_uniq_idx;
DROP INDEX cwi_uniq2_idx;

CREATE UNIQUE INDEX cwi_uniq_idx ON cwi_test(a , b);
ALTER TABLE cwi_test ADD UNIQUE(a, b) WITH (INDEX = 'cwi_uniq_idx');

ALTER TABLE cwi_test ADD PRIMARY KEY (a, b) WITH ( INDEX = 3 );
ALTER TABLE cwi_test ADD PRIMARY KEY (a, b) WITH ( INDEX = del );
ALTER TABLE cwi_test ADD PRIMARY KEY(b, a)
	WITH (INDEX = 'cwi_idx_doesnt_exist');

ALTER TABLE cwi_test ADD UNIQUE (a);
ALTER TABLE cwi_test ADD PRIMARY KEY(a) WITH (INDEX = 'cwi_test_a_key');

CREATE INDEX cwi_idx1 ON cwi_test(a , b);

-- should fail; non-unique
ALTER TABLE cwi_test ADD primary key(a, b) WITH (INDEX = 'cwi_idx1');

CREATE UNIQUE INDEX cwi_idx2 ON cwi_test(a , b);

-- should fail; WITH INDEX option specified more than once.
ALTER TABLE cwi_test ADD PRIMARY KEY (a, b)
	WITH ( INDEX = 'cwi_idx2', INDEX = 'cwi_idx2' );

ALTER TABLE cwi_test ADD primary key(a, b) WITH (INDEX = 'cwi_idx2');

ALTER TABLE cwi_test DROP CONSTRAINT cwi_test_pkey;

ALTER TABLE cwi_test ADD primary key(a, b);

CREATE UNIQUE INDEX cwi_idx3 ON cwi_test(a);

-- should fail
ALTER TABLE cwi_test DROP CONSTRAINT cwi_test_pkey, ADD PRIMARY KEY(a, b)
	WITH (INDEX = 'cwi_idx3');

DROP INDEX cwi_idx3;

SELECT relname, relkind FROM pg_class WHERE relname like E'rpi\\_%'
	ORDER BY relkind DESC, relname ASC;

DROP TABLE cwi_test;

SELECT relname, relkind FROM pg_class WHERE relname like E'rpi\\_%';

