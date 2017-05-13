\o /dev/null


-- varibale for customers: :customers_table
-- varibale for orders: :orders_table

SET ROLE tpcc;

-- Function will create order 
-- @param role_name - Role NAME
CREATE OR REPLACE FUNCTION do_create_order(table_name TEXT, role_name TEXT, counter INTEGER) RETURNS void AS $$
DECLARE
    statement TEXT;
BEGIN
    statement := 'INSERT INTO  '|| QUOTE_IDENT(table_name) ||'  (o_id, o_w_id, o_d_id, o_c_id, o_ol_cnt) 
                                VALUES ($1, 11, 2, 100, 100)';
    EXECUTE statement USING (6000 + counter);
END;
$$ LANGUAGE plpgsql;


-- Function will delete order which id equal to counter
-- @param max_iter - Iter name
CREATE OR REPLACE FUNCTION do_delete_order(table_name TEXT,counter integer) RETURNS void AS $$
DECLARE
    statement TEXT;
BEGIN
    statement := 'DELETE FROM '|| QUOTE_IDENT(table_name) ||'  WHERE o_id=$1';
   EXECUTE statement USING (6000+counter);
END;
$$ LANGUAGE plpgsql;

-- Function will delete order which id equal to counter
-- @param max_iter - Iter name
CREATE OR REPLACE FUNCTION do_update_order(table_name TEXT, counter integer) RETURNS void AS $$
DECLARE
    statement TEXT;
BEGIN
    statement:= 'UPDATE  '|| QUOTE_IDENT(table_name) ||' SET o_ol_cnt=$1 WHERE o_id=(6000 + $2)';
   EXECUTE statement USING counter+200, counter;
END;
$$ LANGUAGE plpgsql;

-- Function will do clean up of the orders
CREATE OR REPLACE FUNCTION perf_orders_clean_up(table_name TEXT, max_iter integer) RETURNS void AS $$ 
DECLARE statement TEXT;
BEGIN
       statement:= 'DELETE FROM '|| QUOTE_IDENT(table_name) ||' WHERE o_id >= $1';
       EXECUTE statement USING (max_iter);
END;
$$ LANGUAGE 'plpgsql';



-- Function will perform tests of select
CREATE OR REPLACE FUNCTION perf_select_orders(table_name TEXT, max_iter integer) 
RETURNS void AS
$$ 
DECLARE role_name TEXT;
DECLARE counter integer = 0;
BEGIN
	WHILE counter != max_iter LOOP
        role_name := get_random_role();
    	PERFORM do_select_query(table_name, role_name);
        counter := counter + 1;
  	END LOOP;
END;
$$ LANGUAGE 'plpgsql';

-- Function will create orders
-- @param max_iter integer
CREATE OR REPLACE FUNCTION perf_insert_orders(table_name TEXT, max_iter integer) 
RETURNS void AS
$$ 
DECLARE role_name TEXT;
DECLARE counter integer = 0;
BEGIN
	WHILE counter != max_iter LOOP
        role_name := get_random_role();
    	PERFORM do_create_order(table_name ,role_name, counter);
        counter := counter + 1;
  	END LOOP;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION perf_delete_orders(table_name TEXT, max_iter integer) 
RETURNS void AS
$$ 
DECLARE counter integer = 0;
BEGIN
	WHILE counter != max_iter LOOP
    	PERFORM do_delete_order(table_name, counter);
        counter := counter + 1;
  	END LOOP;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION perf_update_orders(table_name TEXT, max_iter integer) 
RETURNS void AS
$$ 
DECLARE counter integer = 0;
BEGIN
	WHILE counter != max_iter LOOP
    	PERFORM do_update_order(table_name, counter);
        counter := counter + 1;
  	END LOOP;
END;
$$ LANGUAGE 'plpgsql';
