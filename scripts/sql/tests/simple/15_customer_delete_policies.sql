\o /dev/null

SET ROLE tpcc;

DROP POLICY select_customer ON customer;
DROP POLICY update_customer ON customer;
DROP POLICY insert_customer ON customer;
DROP POLICY delete_customer ON customer;
ALTER TABLE customer DISABLE ROW LEVEL SECURITY;

SET ROLE tpcc;
