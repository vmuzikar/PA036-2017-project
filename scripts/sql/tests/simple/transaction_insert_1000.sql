SET ROLE tpcc;

/*
CREATE OR REPLACE FUNCTION create_random_customers(num integer) RETURNS void  AS $$
DECLARE counter integer = 0;
DECLARE role_name TEXT;
BEGIN
    WHILE counter != num LOOP
        role_name := get_random_role();
    	EXECUTE 'SET ROLE ' || QUOTE_IDENT(role_name);

        INSERT INTO customer 
                (c_id, c_d_id, c_w_id, 
                 c_first, c_middle, c_last, c_street_1,) 
        VALUES (5000,11,2,
            'Delete', 'Md', 'LastName', 'S1');
        counter := counter + 1;
  	END LOOP;  
END;
$$
*/

SET ROLE tpcc;