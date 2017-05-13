ALTER TABLE customer ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;

CREATE POLICY select_customer ON customer FOR SELECT USING (pg_has_role(current_user,record_select,'member'));
CREATE POLICY update_customer ON customer FOR UPDATE USING (pg_has_role(current_user,record_update,'member'));
CREATE POLICY delete_customer ON customer FOR DELETE USING (pg_has_role(current_user,record_delete,'member'));
CREATE POLICY insert_customer ON customer FOR INSERT WITH CHECK (true);

CREATE POLICY select_orders ON orders FOR SELECT USING ( 
	((o_c_id,o_w_id,o_d_id) IN (SELECT c_id,c_w_id,c_d_id FROM customer)) );
CREATE POLICY delete_orders ON orders FOR DELETE USING ( 
	((o_c_id,o_w_id,o_d_id) IN (SELECT c_id,c_w_id,c_d_id FROM customer)) );
CREATE POLICY update_orders ON orders FOR UPDATE USING ( 
	((o_c_id,o_w_id,o_d_id) IN (SELECT c_id,c_w_id,c_d_id FROM customer)) );
CREATE POLICY insert_customer ON orders FOR INSERT WITH CHECK (true);

