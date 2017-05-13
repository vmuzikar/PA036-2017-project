--\o /dev/null


-- varibale for customers: :customers_table
-- varibale for orders: :orders_table

SET ROLE tpcc;

-- function will get random role
CREATE OR REPLACE FUNCTION get_random_role() RETURNS TEXT AS $$
DECLARE
    rol_name TEXT;
BEGIN
	SELECT rolname INTO rol_name FROM pg_roles WHERE rolname not in ('pg_signal_backend') AND rolsuper=false ORDER BY RANDOM() LIMIT 1;
    RETURN rol_name;
END;
$$ LANGUAGE plpgsql;

-- Function will execute query 
-- @param role_name - Role NAME
CREATE OR REPLACE FUNCTION do_select_query(table_name TEXT, role_name TEXT) RETURNS void AS $$
BEGIN
    EXECUTE 'SET ROLE ' || QUOTE_IDENT(role_name);
    EXECUTE 'SELECT * FROM '|| QUOTE_IDENT(table_name) ||' ORDER BY RANDOM() LIMIT 1;'; -- TODO
END;
$$ LANGUAGE plpgsql;

-- Function will perform performance tests
CREATE OR REPLACE FUNCTION perf_select(table_name TEXT, max_iter integer) 
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

-- Function will create customer 
-- @param role_name - Role NAME
CREATE OR REPLACE FUNCTION do_create_customer(table_name TEXT, role_name TEXT, counter INTEGER) RETURNS void AS $$
DECLARE
    statement TEXT;
BEGIN
    
    statement := 'INSERT INTO  '|| QUOTE_IDENT(table_name) ||'  (c_id, c_d_id, c_w_id, c_first, c_middle, c_last, c_street_1,
                                         record_update, record_delete, record_select) 
                                VALUES ($1, 11, 2, $2 , ''Md'', $2 , ''S1'', $3, $3, $3)';
    EXECUTE statement USING (6000 + counter), ('PERF_' || CAST(counter as TEXT)), role_name;
END;
$$ LANGUAGE plpgsql;

-- Function will delete customer which id equal to counter
-- @param max_iter - Iter name
CREATE OR REPLACE FUNCTION do_delete_customer(table_name TEXT,counter integer) RETURNS void AS $$
DECLARE
    statement TEXT;
BEGIN
    statement := 'DELETE FROM '|| QUOTE_IDENT(table_name) ||'  WHERE c_id=$1';
   EXECUTE statement USING (6000+counter);
END;
$$ LANGUAGE plpgsql;

-- Function will delete customer which id equal to counter
-- @param max_iter - Iter name
CREATE OR REPLACE FUNCTION do_update_customer(table_name TEXT, counter integer) RETURNS void AS $$
DECLARE
    statement TEXT;
BEGIN
    statement:= 'UPDATE  '|| QUOTE_IDENT(table_name) ||' SET c_first=$1 WHERE c_id=(6000 + $2)';
   EXECUTE statement USING 'CUP_' || CAST( counter as TEXT), counter;
END;
$$ LANGUAGE plpgsql;

-- Function will create customers
-- @param max_iter integer
CREATE OR REPLACE FUNCTION perf_insert_customers(table_name TEXT, max_iter integer) 
RETURNS void AS
$$ 
DECLARE role_name TEXT;
DECLARE counter integer = 0;
BEGIN
	WHILE counter != max_iter LOOP
        role_name := get_random_role();
    	PERFORM do_create_customer(table_name ,role_name, counter);
        counter := counter + 1;
  	END LOOP;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION perf_delete_customers(table_name TEXT, max_iter integer) 
RETURNS void AS
$$ 
DECLARE counter integer = 0;
BEGIN
	WHILE counter != max_iter LOOP
    	PERFORM do_delete_customer(table_name, counter);
        counter := counter + 1;
  	END LOOP;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION perf_update_customers(table_name TEXT, max_iter integer) 
RETURNS void AS
$$ 
DECLARE counter integer = 0;
BEGIN
	WHILE counter != max_iter LOOP
    	PERFORM do_update_customer(table_name, counter);
        counter := counter + 1;
  	END LOOP;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION perf_clean_up(table_name TEXT, max_iter integer) RETURNS void AS $$ 
DECLARE statement TEXT;
BEGIN
       statement:= 'DELETE FROM '|| QUOTE_IDENT(table_name) ||' WHERE c_id >= $1';
       EXECUTE statement USING (max_iter);
END;
$$ LANGUAGE 'plpgsql';

GRANT EXECUTE ON FUNCTION get_random_role() TO PUBLIC;
GRANT EXECUTE ON FUNCTION do_select_query(table_name TEXT, role_name TEXT) TO PUBLIC;
GRANT EXECUTE ON FUNCTION perf_select(table_name TEXT, max_iter integer) TO PUBLIC;
GRANT EXECUTE ON FUNCTION perf_insert_customers(table_name TEXT, max_iter integer) TO PUBLIC;
GRANT EXECUTE ON FUNCTION do_delete_customer(table_name TEXT, max_iter integer) TO PUBLIC;
GRANT EXECUTE ON FUNCTION perf_delete_customers(table_name TEXT, max_iter integer) TO PUBLIC;
GRANT EXECUTE ON FUNCTION perf_clean_up(table_name TEXT, max_iter integer) TO PUBLIC;
GRANT EXECUTE ON FUNCTION perf_update_customers(table_name TEXT, max_iter integer) TO PUBLIC;
GRANT EXECUTE ON FUNCTION do_create_customer(table_name TEXT, role_name TEXT, counter INTEGER) TO PUBLIC;
GRANT EXECUTE ON FUNCTION do_update_customer(table_name TEXT, counter INTEGER) TO PUBLIC;



SET ROLE tpcc;
