\o /dev/null

SET ROLE tpcc;

DROP POLICY IF EXISTS select_orders ON orders;
DROP POLICY IF EXISTS update_orders ON orders;
DROP POLICY IF EXISTS insert_orders ON orders;
DROP POLICY IF EXISTS delete_orders ON orders;
ALTER TABLE customer DISABLE ROW LEVEL SECURITY;
ALTER TABLE orders DISABLE ROW LEVEL SECURITY;


SET ROLE tpcc;
