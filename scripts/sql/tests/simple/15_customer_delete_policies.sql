\o /dev/null

SET ROLE tpcc;

DROP POLICY IF EXISTS select_customer ON customer;
DROP POLICY IF EXISTS update_customer ON customer;
DROP POLICY IF EXISTS insert_customer ON customer;
DROP POLICY IF EXISTS delete_customer ON customer;
ALTER TABLE customer DISABLE ROW LEVEL SECURITY;

SET ROLE tpcc;
