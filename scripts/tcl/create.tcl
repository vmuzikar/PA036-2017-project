#!/usr/local/bin/tclsh8.6

puts "[pwd]"

if [catch {package require Pgtcl} ] { error "Failed to load Pgtcl - Postgres Library Error" }
proc CreateStoredProcs { lda ora_compatible } {
	puts "CREATING TPCC STORED PROCEDURES"
	if { $ora_compatible eq "true" } {
set sql(1) { CREATE OR REPLACE FUNCTION DBMS_RANDOM (INTEGER, INTEGER) RETURNS INTEGER AS $$
DECLARE
    start_int ALIAS FOR $1;
    end_int ALIAS FOR $2;
BEGIN
    RETURN trunc(random() * (end_int-start_int) + start_int);
END;
$$ LANGUAGE 'plpgsql' STRICT;
}
set sql(2) { CREATE OR REPLACE PROCEDURE NEWORD (
no_w_id		INTEGER,
no_max_w_id		INTEGER,
no_d_id		INTEGER,
no_c_id		INTEGER,
no_o_ol_cnt		INTEGER,
no_c_discount		OUT NUMBER,
no_c_last		OUT VARCHAR2,
no_c_credit		OUT VARCHAR2,
no_d_tax		OUT NUMBER,
no_w_tax		OUT NUMBER,
no_d_next_o_id		IN OUT INTEGER,
tstamp		IN DATE )
IS
no_ol_supply_w_id	INTEGER;
no_ol_i_id		NUMBER;
no_ol_quantity		NUMBER;
no_o_all_local		INTEGER;
o_id			INTEGER;
no_i_name		VARCHAR2(24);
no_i_price		NUMBER(5,2);
no_i_data		VARCHAR2(50);
no_s_quantity		NUMBER(6);
no_ol_amount		NUMBER(6,2);
no_s_dist_01		CHAR(24);
no_s_dist_02		CHAR(24);
no_s_dist_03		CHAR(24);
no_s_dist_04		CHAR(24);
no_s_dist_05		CHAR(24);
no_s_dist_06		CHAR(24);
no_s_dist_07		CHAR(24);
no_s_dist_08		CHAR(24);
no_s_dist_09		CHAR(24);
no_s_dist_10		CHAR(24);
no_ol_dist_info		CHAR(24);
no_s_data		VARCHAR2(50);
x			NUMBER;
rbk			NUMBER;
BEGIN
--assignment below added due to error in appendix code
no_o_all_local := 0;
SELECT c_discount, c_last, c_credit, w_tax
INTO no_c_discount, no_c_last, no_c_credit, no_w_tax
FROM customer, warehouse
WHERE warehouse.w_id = no_w_id AND customer.c_w_id = no_w_id AND
customer.c_d_id = no_d_id AND customer.c_id = no_c_id;
UPDATE district SET d_next_o_id = d_next_o_id + 1 WHERE d_id = no_d_id AND d_w_id = no_w_id RETURNING d_next_o_id, d_tax INTO no_d_next_o_id, no_d_tax;
o_id := no_d_next_o_id;
INSERT INTO ORDERS (o_id, o_d_id, o_w_id, o_c_id, o_entry_d, o_ol_cnt, o_all_local) VALUES (o_id, no_d_id, no_w_id, no_c_id, tstamp, no_o_ol_cnt, no_o_all_local);
INSERT INTO NEW_ORDER (no_o_id, no_d_id, no_w_id) VALUES (o_id, no_d_id, no_w_id);
--#2.4.1.4
rbk := round(DBMS_RANDOM(1,100));
--#2.4.1.5
FOR loop_counter IN 1 .. no_o_ol_cnt
LOOP
IF ((loop_counter = no_o_ol_cnt) AND (rbk = 1))
THEN
no_ol_i_id := 100001;
ELSE
no_ol_i_id := round(DBMS_RANDOM(1,100000));
END IF;
--#2.4.1.5.2
x := round(DBMS_RANDOM(1,100));
IF ( x > 1 )
THEN
no_ol_supply_w_id := no_w_id;
ELSE
no_ol_supply_w_id := no_w_id;
--no_all_local is actually used before this point so following not beneficial
no_o_all_local := 0;
WHILE ((no_ol_supply_w_id = no_w_id) AND (no_max_w_id != 1))
LOOP
no_ol_supply_w_id := round(DBMS_RANDOM(1,no_max_w_id));
END LOOP;
END IF;
--#2.4.1.5.3
no_ol_quantity := round(DBMS_RANDOM(1,10));
SELECT i_price, i_name, i_data INTO no_i_price, no_i_name, no_i_data
FROM item WHERE i_id = no_ol_i_id;
SELECT s_quantity, s_data, s_dist_01, s_dist_02, s_dist_03, s_dist_04, s_dist_05, s_dist_06, s_dist_07, s_dist_08, s_dist_09, s_dist_10
INTO no_s_quantity, no_s_data, no_s_dist_01, no_s_dist_02, no_s_dist_03, no_s_dist_04, no_s_dist_05, no_s_dist_06, no_s_dist_07, no_s_dist_08, no_s_dist_09, no_s_dist_10 FROM stock WHERE s_i_id = no_ol_i_id AND s_w_id = no_ol_supply_w_id;
IF ( no_s_quantity > no_ol_quantity )
THEN
no_s_quantity := ( no_s_quantity - no_ol_quantity );
ELSE
no_s_quantity := ( no_s_quantity - no_ol_quantity + 91 );
END IF;
UPDATE stock SET s_quantity = no_s_quantity
WHERE s_i_id = no_ol_i_id
AND s_w_id = no_ol_supply_w_id;

no_ol_amount := (  no_ol_quantity * no_i_price * ( 1 + no_w_tax + no_d_tax ) * ( 1 - no_c_discount ) );

IF no_d_id = 1
THEN 
no_ol_dist_info := no_s_dist_01; 

ELSIF no_d_id = 2
THEN
no_ol_dist_info := no_s_dist_02;

ELSIF no_d_id = 3
THEN
no_ol_dist_info := no_s_dist_03;

ELSIF no_d_id = 4
THEN
no_ol_dist_info := no_s_dist_04;

ELSIF no_d_id = 5
THEN
no_ol_dist_info := no_s_dist_05;

ELSIF no_d_id = 6
THEN
no_ol_dist_info := no_s_dist_06;

ELSIF no_d_id = 7
THEN
no_ol_dist_info := no_s_dist_07;

ELSIF no_d_id = 8
THEN
no_ol_dist_info := no_s_dist_08;

ELSIF no_d_id = 9
THEN
no_ol_dist_info := no_s_dist_09;

ELSIF no_d_id = 10
THEN
no_ol_dist_info := no_s_dist_10;
END IF;

INSERT INTO order_line (ol_o_id, ol_d_id, ol_w_id, ol_number, ol_i_id, ol_supply_w_id, ol_quantity, ol_amount, ol_dist_info)
VALUES (o_id, no_d_id, no_w_id, loop_counter, no_ol_i_id, no_ol_supply_w_id, no_ol_quantity, no_ol_amount, no_ol_dist_info);

END LOOP;

COMMIT;
EXCEPTION
WHEN serialization_failure OR deadlock_detected OR no_data_found
THEN ROLLBACK;
END; }
set sql(3) { CREATE OR REPLACE PROCEDURE DELIVERY (
d_w_id			INTEGER,
d_o_carrier_id		INTEGER,
tstamp		IN DATE )
IS
d_no_o_id		INTEGER;
d_d_id	           	INTEGER;
d_c_id	           	NUMBER;
d_ol_total		NUMBER;
loop_counter            INTEGER;
BEGIN
FOR loop_counter IN 1 .. 10
LOOP
d_d_id := loop_counter;
SELECT no_o_id INTO d_no_o_id FROM new_order WHERE no_w_id = d_w_id AND no_d_id = d_d_id ORDER BY no_o_id ASC LIMIT 1;
DELETE FROM new_order WHERE no_w_id = d_w_id AND no_d_id = d_d_id AND no_o_id = d_no_o_id;
SELECT o_c_id INTO d_c_id FROM orders
WHERE o_id = d_no_o_id AND o_d_id = d_d_id AND
o_w_id = d_w_id;
 UPDATE orders SET o_carrier_id = d_o_carrier_id
WHERE o_id = d_no_o_id AND o_d_id = d_d_id AND
o_w_id = d_w_id;
UPDATE order_line SET ol_delivery_d = tstamp
WHERE ol_o_id = d_no_o_id AND ol_d_id = d_d_id AND
ol_w_id = d_w_id;
SELECT SUM(ol_amount) INTO d_ol_total
FROM order_line
WHERE ol_o_id = d_no_o_id AND ol_d_id = d_d_id
AND ol_w_id = d_w_id;
UPDATE customer SET c_balance = c_balance + d_ol_total
WHERE c_id = d_c_id AND c_d_id = d_d_id AND
c_w_id = d_w_id;
COMMIT;
DBMS_OUTPUT.PUT_LINE('D: ' || d_d_id || 'O: ' || d_no_o_id || 'time ' || tstamp);
END LOOP;
EXCEPTION
WHEN serialization_failure OR deadlock_detected OR no_data_found
THEN ROLLBACK;
END; }
set sql(4) { CREATE OR REPLACE PROCEDURE PAYMENT (
p_w_id			INTEGER,
p_d_id			INTEGER,
p_c_w_id		INTEGER,
p_c_d_id		INTEGER,
p_c_id			IN OUT NUMBER(5,0),
byname			INTEGER,
p_h_amount		NUMBER,
p_c_last		IN OUT VARCHAR2(16),
p_w_street_1		OUT VARCHAR2(20),
p_w_street_2		OUT VARCHAR2(20),
p_w_city		OUT VARCHAR2(20),
p_w_state		OUT CHAR(2),
p_w_zip			OUT CHAR(9),
p_d_street_1		OUT VARCHAR2(20),
p_d_street_2		OUT VARCHAR2(20),
p_d_city		OUT VARCHAR2(20),
p_d_state		OUT CHAR(2),
p_d_zip			OUT CHAR(9),
p_c_first		OUT VARCHAR2(16),
p_c_middle		OUT CHAR(2),
p_c_street_1		OUT VARCHAR2(20),
p_c_street_2		OUT VARCHAR2(20),
p_c_city		OUT VARCHAR2(20),
p_c_state		OUT CHAR(2),
p_c_zip			OUT CHAR(9),
p_c_phone		OUT CHAR(16),
p_c_since		OUT DATE,
p_c_credit		IN OUT CHAR(2),
p_c_credit_lim		OUT NUMBER(12, 2),
p_c_discount		OUT NUMBER(4, 4),
p_c_balance		IN OUT NUMBER(12, 2),
p_c_data		OUT VARCHAR2(500),
tstamp		IN DATE )
IS
namecnt			INTEGER;
p_d_name		VARCHAR2(11);
p_w_name		VARCHAR2(11);
p_c_new_data		VARCHAR2(500);
h_data			VARCHAR2(30);
CURSOR c_byname IS
SELECT c_first, c_middle, c_id,
c_street_1, c_street_2, c_city, c_state, c_zip,
c_phone, c_credit, c_credit_lim,
c_discount, c_balance, c_since
FROM customer
WHERE c_w_id = p_c_w_id AND c_d_id = p_c_d_id AND c_last = p_c_last
ORDER BY c_first;
BEGIN
UPDATE warehouse SET w_ytd = w_ytd + p_h_amount
WHERE w_id = p_w_id;
SELECT w_street_1, w_street_2, w_city, w_state, w_zip, w_name
INTO p_w_street_1, p_w_street_2, p_w_city, p_w_state, p_w_zip, p_w_name
FROM warehouse
WHERE w_id = p_w_id;
UPDATE district SET d_ytd = d_ytd + p_h_amount
WHERE d_w_id = p_w_id AND d_id = p_d_id;
SELECT d_street_1, d_street_2, d_city, d_state, d_zip, d_name
INTO p_d_street_1, p_d_street_2, p_d_city, p_d_state, p_d_zip, p_d_name
FROM district
WHERE d_w_id = p_w_id AND d_id = p_d_id;
IF ( byname = 1 )
THEN
SELECT count(c_id) INTO namecnt
FROM customer
WHERE c_last = p_c_last AND c_d_id = p_c_d_id AND c_w_id = p_c_w_id;
OPEN c_byname;
IF ( MOD (namecnt, 2) = 1 )
THEN
namecnt := (namecnt + 1);
END IF;
FOR loop_counter IN 0 .. cast((namecnt/2) AS INTEGER)
LOOP
FETCH c_byname
INTO p_c_first, p_c_middle, p_c_id, p_c_street_1, p_c_street_2, p_c_city,
p_c_state, p_c_zip, p_c_phone, p_c_credit, p_c_credit_lim, p_c_discount, p_c_balance, p_c_since;
END LOOP;
CLOSE c_byname;
ELSE
SELECT c_first, c_middle, c_last,
c_street_1, c_street_2, c_city, c_state, c_zip,
c_phone, c_credit, c_credit_lim,
c_discount, c_balance, c_since
INTO p_c_first, p_c_middle, p_c_last,
p_c_street_1, p_c_street_2, p_c_city, p_c_state, p_c_zip,
p_c_phone, p_c_credit, p_c_credit_lim,
p_c_discount, p_c_balance, p_c_since
FROM customer
WHERE c_w_id = p_c_w_id AND c_d_id = p_c_d_id AND c_id = p_c_id;
END IF;
p_c_balance := ( p_c_balance + p_h_amount );
IF p_c_credit = 'BC' 
THEN
 SELECT c_data INTO p_c_data
FROM customer
WHERE c_w_id = p_c_w_id AND c_d_id = p_c_d_id AND c_id = p_c_id;
-- The following statement in the TPC-C specification appendix is incorrect
-- copied setting of h_data from later on in the procedure to here as well
h_data := ( p_w_name || ' ' || p_d_name );
p_c_new_data := (TO_CHAR(p_c_id) || ' ' || TO_CHAR(p_c_d_id) || ' ' ||
TO_CHAR(p_c_w_id) || ' ' || TO_CHAR(p_d_id) || ' ' || TO_CHAR(p_w_id) || ' ' || TO_CHAR(p_h_amount,'9999.99') || TO_CHAR(tstamp) || h_data);
p_c_new_data := substr(CONCAT(p_c_new_data,p_c_data),1,500-(LENGTH(p_c_new_data)));
UPDATE customer
SET c_balance = p_c_balance, c_data = p_c_new_data
WHERE c_w_id = p_c_w_id AND c_d_id = p_c_d_id AND
c_id = p_c_id;
ELSE
UPDATE customer SET c_balance = p_c_balance
WHERE c_w_id = p_c_w_id AND c_d_id = p_c_d_id AND
c_id = p_c_id;
END IF;
--setting of h_data is here in the TPC-C appendix
h_data := ( p_w_name|| ' ' || p_d_name );
INSERT INTO history (h_c_d_id, h_c_w_id, h_c_id, h_d_id,
h_w_id, h_date, h_amount, h_data)
VALUES (p_c_d_id, p_c_w_id, p_c_id, p_d_id,
p_w_id, tstamp, p_h_amount, h_data);
COMMIT;
EXCEPTION
WHEN serialization_failure OR deadlock_detected OR no_data_found
THEN ROLLBACK;
END; }
set sql(5) { CREATE OR REPLACE PROCEDURE OSTAT (
os_w_id			INTEGER,
os_d_id			INTEGER,
os_c_id			IN OUT INTEGER,
byname			INTEGER,
os_c_last		IN OUT VARCHAR2,
os_c_first		OUT VARCHAR2,
os_c_middle		OUT VARCHAR2,
os_c_balance		OUT NUMBER,
os_o_id			OUT INTEGER,
os_entdate		OUT DATE,
os_o_carrier_id		OUT INTEGER )
IS
TYPE numbertable IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
os_ol_i_id numbertable;	
os_ol_supply_w_id numbertable;	
os_ol_quantity numbertable;	
TYPE amounttable IS TABLE OF NUMBER(6,2) INDEX BY BINARY_INTEGER;
os_ol_amount amounttable;
TYPE datetable IS TABLE OF DATE INDEX BY BINARY_INTEGER;
os_ol_delivery_d datetable;
namecnt			INTEGER;
i			BINARY_INTEGER;
CURSOR c_name IS
SELECT c_balance, c_first, c_middle, c_id
FROM customer
WHERE c_last = os_c_last AND c_d_id = os_d_id AND c_w_id = os_w_id
ORDER BY c_first;
CURSOR c_line IS
SELECT ol_i_id, ol_supply_w_id, ol_quantity,
ol_amount, ol_delivery_d
FROM order_line
WHERE ol_o_id = os_o_id AND ol_d_id = os_d_id AND ol_w_id = os_w_id;
os_c_line c_line%ROWTYPE;
BEGIN
IF ( byname = 1 )
THEN
SELECT count(c_id) INTO namecnt
FROM customer
WHERE c_last = os_c_last AND c_d_id = os_d_id AND c_w_id = os_w_id;
IF ( MOD (namecnt, 2) = 1 )
THEN
namecnt := (namecnt + 1);
END IF;
OPEN c_name;
FOR loop_counter IN 0 .. cast((namecnt/2) AS INTEGER)
LOOP
FETCH c_name  
INTO os_c_balance, os_c_first, os_c_middle, os_c_id;
END LOOP;
close c_name;
ELSE
SELECT c_balance, c_first, c_middle, c_last
INTO os_c_balance, os_c_first, os_c_middle, os_c_last
FROM customer
WHERE c_id = os_c_id AND c_d_id = os_d_id AND c_w_id = os_w_id;
END IF;
BEGIN
SELECT o_id, o_carrier_id, o_entry_d 
INTO os_o_id, os_o_carrier_id, os_entdate
FROM
(SELECT o_id, o_carrier_id, o_entry_d
FROM orders where o_d_id = os_d_id AND o_w_id = os_w_id and o_c_id=os_c_id
ORDER BY o_id DESC)
WHERE ROWNUM = 1;
EXCEPTION
WHEN NO_DATA_FOUND THEN
dbms_output.put_line('No orders for customer');
END;
i := 0;
FOR os_c_line IN c_line
LOOP
os_ol_i_id(i) := os_c_line.ol_i_id;
os_ol_supply_w_id(i) := os_c_line.ol_supply_w_id;
os_ol_quantity(i) := os_c_line.ol_quantity;
os_ol_amount(i) := os_c_line.ol_amount;
os_ol_delivery_d(i) := os_c_line.ol_delivery_d;
i := i+1;
END LOOP;
EXCEPTION
WHEN serialization_failure OR deadlock_detected OR no_data_found
THEN ROLLBACK;
END; }
set sql(6) { CREATE OR REPLACE PROCEDURE SLEV (
st_w_id			INTEGER,
st_d_id			INTEGER,
threshold		INTEGER )
IS 
st_o_id			NUMBER;	
stock_count		INTEGER;
BEGIN
SELECT d_next_o_id INTO st_o_id
FROM district
WHERE d_w_id=st_w_id AND d_id=st_d_id;
SELECT COUNT(DISTINCT (s_i_id)) INTO stock_count
FROM order_line, stock
WHERE ol_w_id = st_w_id AND
ol_d_id = st_d_id AND (ol_o_id < st_o_id) AND
ol_o_id >= (st_o_id - 20) AND s_w_id = st_w_id AND
s_i_id = ol_i_id AND s_quantity < threshold;
COMMIT;
EXCEPTION
WHEN serialization_failure OR deadlock_detected OR no_data_found
THEN ROLLBACK;
END; }
for { set i 1 } { $i <= 6 } { incr i } {
set result [ pg_exec $lda $sql($i) ]
if {[pg_result $result -status] != "PGRES_COMMAND_OK"} {
error "[pg_result $result -error]"
	} else {
pg_result $result -clear
	}
    }
} else {
set sql(1) { CREATE OR REPLACE FUNCTION DBMS_RANDOM (INTEGER, INTEGER) RETURNS INTEGER AS $$
DECLARE
    start_int ALIAS FOR $1;
    end_int ALIAS FOR $2;
BEGIN
    RETURN trunc(random() * (end_int-start_int) + start_int);
END;
$$ LANGUAGE 'plpgsql' STRICT;
}
set sql(2) { CREATE OR REPLACE FUNCTION NEWORD (INTEGER, INTEGER, INTEGER, INTEGER, INTEGER, INTEGER) RETURNS NUMERIC AS '
DECLARE
no_w_id		ALIAS FOR $1;	
no_max_w_id	ALIAS FOR $2;
no_d_id		ALIAS FOR $3;
no_c_id		ALIAS FOR $4;
no_o_ol_cnt	ALIAS FOR $5;
no_d_next_o_id	ALIAS FOR $6;
no_c_discount	NUMERIC;
no_c_last	VARCHAR;
no_c_credit	VARCHAR;
no_d_tax	NUMERIC;
no_w_tax	NUMERIC;
tstamp		TIMESTAMP;
no_ol_supply_w_id	INTEGER;
no_ol_i_id		NUMERIC;
no_ol_quantity		NUMERIC;
no_o_all_local		INTEGER;
o_id			INTEGER;
no_i_name		VARCHAR(24);
no_i_price		NUMERIC(5,2);
no_i_data		VARCHAR(50);
no_s_quantity		NUMERIC(6);
no_ol_amount		NUMERIC(6,2);
no_s_dist_01		CHAR(24);
no_s_dist_02		CHAR(24);
no_s_dist_03		CHAR(24);
no_s_dist_04		CHAR(24);
no_s_dist_05		CHAR(24);
no_s_dist_06		CHAR(24);
no_s_dist_07		CHAR(24);
no_s_dist_08		CHAR(24);
no_s_dist_09		CHAR(24);
no_s_dist_10		CHAR(24);
no_ol_dist_info		CHAR(24);
no_s_data		VARCHAR(50);
x			NUMERIC;
rbk			NUMERIC;
BEGIN
--assignment below added due to error in appendix code
no_o_all_local := 0;
SELECT c_discount, c_last, c_credit, w_tax
INTO no_c_discount, no_c_last, no_c_credit, no_w_tax
FROM customer, warehouse
WHERE warehouse.w_id = no_w_id AND customer.c_w_id = no_w_id AND
customer.c_d_id = no_d_id AND customer.c_id = no_c_id;
UPDATE district SET d_next_o_id = d_next_o_id + 1 WHERE d_id = no_d_id AND d_w_id = no_w_id RETURNING d_next_o_id, d_tax INTO no_d_next_o_id, no_d_tax;
o_id := no_d_next_o_id;
INSERT INTO ORDERS (o_id, o_d_id, o_w_id, o_c_id, o_entry_d, o_ol_cnt, o_all_local) VALUES (o_id, no_d_id, no_w_id, no_c_id, current_timestamp, no_o_ol_cnt, no_o_all_local);
INSERT INTO NEW_ORDER (no_o_id, no_d_id, no_w_id) VALUES (o_id, no_d_id, no_w_id);
--#2.4.1.4
rbk := round(DBMS_RANDOM(1,100));
--#2.4.1.5
FOR loop_counter IN 1 .. no_o_ol_cnt
LOOP
IF ((loop_counter = no_o_ol_cnt) AND (rbk = 1))
THEN
no_ol_i_id := 100001;
ELSE
no_ol_i_id := round(DBMS_RANDOM(1,100000));
END IF;
--#2.4.1.5.2
x := round(DBMS_RANDOM(1,100));
IF ( x > 1 )
THEN
no_ol_supply_w_id := no_w_id;
ELSE
no_ol_supply_w_id := no_w_id;
--no_all_local is actually used before this point so following not beneficial
no_o_all_local := 0;
WHILE ((no_ol_supply_w_id = no_w_id) AND (no_max_w_id != 1))
LOOP
no_ol_supply_w_id := round(DBMS_RANDOM(1,no_max_w_id));
END LOOP;
END IF;
--#2.4.1.5.3
no_ol_quantity := round(DBMS_RANDOM(1,10));
SELECT i_price, i_name, i_data INTO no_i_price, no_i_name, no_i_data
FROM item WHERE i_id = no_ol_i_id;
SELECT s_quantity, s_data, s_dist_01, s_dist_02, s_dist_03, s_dist_04, s_dist_05, s_dist_06, s_dist_07, s_dist_08, s_dist_09, s_dist_10
INTO no_s_quantity, no_s_data, no_s_dist_01, no_s_dist_02, no_s_dist_03, no_s_dist_04, no_s_dist_05, no_s_dist_06, no_s_dist_07, no_s_dist_08, no_s_dist_09, no_s_dist_10 FROM stock WHERE s_i_id = no_ol_i_id AND s_w_id = no_ol_supply_w_id;
IF ( no_s_quantity > no_ol_quantity )
THEN
no_s_quantity := ( no_s_quantity - no_ol_quantity );
ELSE
no_s_quantity := ( no_s_quantity - no_ol_quantity + 91 );
END IF;
UPDATE stock SET s_quantity = no_s_quantity
WHERE s_i_id = no_ol_i_id
AND s_w_id = no_ol_supply_w_id;

no_ol_amount := (  no_ol_quantity * no_i_price * ( 1 + no_w_tax + no_d_tax ) * ( 1 - no_c_discount ) );

IF no_d_id = 1
THEN 
no_ol_dist_info := no_s_dist_01; 

ELSIF no_d_id = 2
THEN
no_ol_dist_info := no_s_dist_02;

ELSIF no_d_id = 3
THEN
no_ol_dist_info := no_s_dist_03;

ELSIF no_d_id = 4
THEN
no_ol_dist_info := no_s_dist_04;

ELSIF no_d_id = 5
THEN
no_ol_dist_info := no_s_dist_05;

ELSIF no_d_id = 6
THEN
no_ol_dist_info := no_s_dist_06;

ELSIF no_d_id = 7
THEN
no_ol_dist_info := no_s_dist_07;

ELSIF no_d_id = 8
THEN
no_ol_dist_info := no_s_dist_08;

ELSIF no_d_id = 9
THEN
no_ol_dist_info := no_s_dist_09;

ELSIF no_d_id = 10
THEN
no_ol_dist_info := no_s_dist_10;
END IF;

INSERT INTO order_line (ol_o_id, ol_d_id, ol_w_id, ol_number, ol_i_id, ol_supply_w_id, ol_quantity, ol_amount, ol_dist_info)
VALUES (o_id, no_d_id, no_w_id, loop_counter, no_ol_i_id, no_ol_supply_w_id, no_ol_quantity, no_ol_amount, no_ol_dist_info);

END LOOP;
RETURN no_s_quantity;
EXCEPTION
WHEN serialization_failure OR deadlock_detected OR no_data_found
THEN ROLLBACK;
END; 
' LANGUAGE 'plpgsql';
	}
set sql(3) { CREATE OR REPLACE FUNCTION DELIVERY (INTEGER, INTEGER) RETURNS INTEGER AS '
DECLARE
d_w_id		ALIAS FOR $1;	
d_o_carrier_id  ALIAS FOR $2;	
d_d_id	       	INTEGER;
d_c_id	       	NUMERIC;
d_no_o_id		INTEGER;
d_ol_total		NUMERIC;
loop_counter		INTEGER;
BEGIN
FOR loop_counter IN 1 .. 10
LOOP
d_d_id := loop_counter;
SELECT no_o_id INTO d_no_o_id FROM new_order WHERE no_w_id = d_w_id AND no_d_id = d_d_id ORDER BY no_o_id ASC LIMIT 1;
DELETE FROM new_order WHERE no_w_id = d_w_id AND no_d_id = d_d_id AND no_o_id = d_no_o_id;
SELECT o_c_id INTO d_c_id FROM orders
WHERE o_id = d_no_o_id AND o_d_id = d_d_id AND
o_w_id = d_w_id;
 UPDATE orders SET o_carrier_id = d_o_carrier_id
WHERE o_id = d_no_o_id AND o_d_id = d_d_id AND
o_w_id = d_w_id;
UPDATE order_line SET ol_delivery_d = current_timestamp
WHERE ol_o_id = d_no_o_id AND ol_d_id = d_d_id AND
ol_w_id = d_w_id;
SELECT SUM(ol_amount) INTO d_ol_total
FROM order_line
WHERE ol_o_id = d_no_o_id AND ol_d_id = d_d_id
AND ol_w_id = d_w_id;
UPDATE customer SET c_balance = c_balance + d_ol_total
WHERE c_id = d_c_id AND c_d_id = d_d_id AND
c_w_id = d_w_id;
END LOOP;
RETURN 1;
EXCEPTION
WHEN serialization_failure OR deadlock_detected OR no_data_found
THEN ROLLBACK;
END; 
' LANGUAGE 'plpgsql';
}
set sql(4) { CREATE OR REPLACE FUNCTION PAYMENT (INTEGER, INTEGER, INTEGER, INTEGER, NUMERIC, INTEGER, NUMERIC, VARCHAR, VARCHAR, NUMERIC ) RETURNS INTEGER AS '
DECLARE
p_w_id			ALIAS FOR $1;
p_d_id			ALIAS FOR $2;
p_c_w_id		ALIAS FOR $3;
p_c_d_id		ALIAS FOR $4;
p_c_id_in		ALIAS FOR $5;
byname			ALIAS FOR $6;
p_h_amount		ALIAS FOR $7;
p_c_last_in		ALIAS FOR $8;
p_c_credit_in		ALIAS FOR $9;
p_c_balance_in		ALIAS FOR $10;
p_c_balance             NUMERIC(12, 2);
p_c_credit              CHAR(2);
p_c_last		VARCHAR(16);
p_c_id			NUMERIC(5,0);
p_w_street_1            VARCHAR(20);
p_w_street_2            VARCHAR(20);
p_w_city                VARCHAR(20);
p_w_state               CHAR(2);
p_w_zip                 CHAR(9);
p_d_street_1            VARCHAR(20);
p_d_street_2            VARCHAR(20);
p_d_city                VARCHAR(20);
p_d_state               CHAR(2);
p_d_zip                 CHAR(9);
p_c_first               VARCHAR(16);
p_c_middle              CHAR(2);
p_c_street_1            VARCHAR(20);
p_c_street_2            VARCHAR(20);
p_c_city                VARCHAR(20);
p_c_state               CHAR(2);
p_c_zip                 CHAR(9);
p_c_phone               CHAR(16);
p_c_since		TIMESTAMP;
p_c_credit_lim          NUMERIC(12, 2);
p_c_discount            NUMERIC(4, 4);
p_c_data                VARCHAR(500);
tstamp			TIMESTAMP;
namecnt			INTEGER;
p_d_name		VARCHAR(11);
p_w_name		VARCHAR(11);
p_c_new_data		VARCHAR(500);
h_data			VARCHAR(30);
c_byname CURSOR FOR
SELECT c_first, c_middle, c_id,
c_street_1, c_street_2, c_city, c_state, c_zip,
c_phone, c_credit, c_credit_lim,
c_discount, c_balance, c_since
FROM customer
WHERE c_w_id = p_c_w_id AND c_d_id = p_c_d_id AND c_last = p_c_last
ORDER BY c_first;
BEGIN
p_c_balance := p_c_balance_in;
p_c_id := p_c_id_in;
p_c_last := p_c_last_in;
p_c_credit := p_c_credit_in;
tstamp := current_timestamp;
UPDATE warehouse SET w_ytd = w_ytd + p_h_amount
WHERE w_id = p_w_id;
SELECT w_street_1, w_street_2, w_city, w_state, w_zip, w_name
INTO p_w_street_1, p_w_street_2, p_w_city, p_w_state, p_w_zip, p_w_name
FROM warehouse
WHERE w_id = p_w_id;
UPDATE district SET d_ytd = d_ytd + p_h_amount
WHERE d_w_id = p_w_id AND d_id = p_d_id;
SELECT d_street_1, d_street_2, d_city, d_state, d_zip, d_name
INTO p_d_street_1, p_d_street_2, p_d_city, p_d_state, p_d_zip, p_d_name
FROM district
WHERE d_w_id = p_w_id AND d_id = p_d_id;
IF ( byname = 1 )
THEN
SELECT count(c_id) INTO namecnt
FROM customer
WHERE c_last = p_c_last AND c_d_id = p_c_d_id AND c_w_id = p_c_w_id;
OPEN c_byname;
IF ( MOD (namecnt, 2) = 1 )
THEN
namecnt := (namecnt + 1);
END IF;
FOR loop_counter IN 0 .. cast((namecnt/2) AS INTEGER)
LOOP
FETCH c_byname
INTO p_c_first, p_c_middle, p_c_id, p_c_street_1, p_c_street_2, p_c_city,
p_c_state, p_c_zip, p_c_phone, p_c_credit, p_c_credit_lim, p_c_discount, p_c_balance, p_c_since;
END LOOP;
CLOSE c_byname;
ELSE
SELECT c_first, c_middle, c_last,
c_street_1, c_street_2, c_city, c_state, c_zip,
c_phone, c_credit, c_credit_lim,
c_discount, c_balance, c_since
INTO p_c_first, p_c_middle, p_c_last,
p_c_street_1, p_c_street_2, p_c_city, p_c_state, p_c_zip,
p_c_phone, p_c_credit, p_c_credit_lim,
p_c_discount, p_c_balance, p_c_since
FROM customer
WHERE c_w_id = p_c_w_id AND c_d_id = p_c_d_id AND c_id = p_c_id;
END IF;
p_c_balance := ( p_c_balance + p_h_amount );
IF p_c_credit = ''BC'' 
THEN
 SELECT c_data INTO p_c_data
FROM customer
WHERE c_w_id = p_c_w_id AND c_d_id = p_c_d_id AND c_id = p_c_id;
h_data := p_w_name || '' '' || p_d_name;
p_c_new_data := (p_c_id || '' '' || p_c_d_id || '' '' || p_c_w_id || '' '' || p_d_id || '' '' || p_w_id || '' '' || TO_CHAR(p_h_amount,''9999.99'') || TO_CHAR(tstamp,''YYYYMMDDHH24MISS'') || h_data);
p_c_new_data := substr(CONCAT(p_c_new_data,p_c_data),1,500-(LENGTH(p_c_new_data)));
UPDATE customer
SET c_balance = p_c_balance, c_data = p_c_new_data
WHERE c_w_id = p_c_w_id AND c_d_id = p_c_d_id AND
c_id = p_c_id;
ELSE
UPDATE customer SET c_balance = p_c_balance
WHERE c_w_id = p_c_w_id AND c_d_id = p_c_d_id AND
c_id = p_c_id;
END IF;
h_data := p_w_name || '' '' || p_d_name;
INSERT INTO history (h_c_d_id, h_c_w_id, h_c_id, h_d_id,
h_w_id, h_date, h_amount, h_data)
VALUES (p_c_d_id, p_c_w_id, p_c_id, p_d_id,
p_w_id, tstamp, p_h_amount, h_data);
RETURN p_c_id;
EXCEPTION
WHEN serialization_failure OR deadlock_detected OR no_data_found
THEN ROLLBACK;
END; 
' LANGUAGE 'plpgsql';
	}
set sql(5) { CREATE OR REPLACE FUNCTION OSTAT (INTEGER, INTEGER, INTEGER, INTEGER, VARCHAR) RETURNS SETOF record AS '
DECLARE
os_w_id		ALIAS FOR $1;
os_d_id		ALIAS FOR $2;		
os_c_id	 	ALIAS FOR $3;
byname		ALIAS FOR $4;	
os_c_last	ALIAS FOR $5;
out_os_c_id	INTEGER;
out_os_c_last	VARCHAR;
os_c_first	VARCHAR;
os_c_middle	VARCHAR;
os_c_balance	NUMERIC;
os_o_id		INTEGER;
os_entdate	TIMESTAMP;
os_o_carrier_id	INTEGER;
os_ol 		RECORD;
namecnt		INTEGER;
c_name CURSOR FOR
SELECT c_balance, c_first, c_middle, c_id
FROM customer
WHERE c_last = os_c_last AND c_d_id = os_d_id AND c_w_id = os_w_id
ORDER BY c_first;
BEGIN
IF ( byname = 1 )
THEN
SELECT count(c_id) INTO namecnt
FROM customer
WHERE c_last = os_c_last AND c_d_id = os_d_id AND c_w_id = os_w_id;
IF ( MOD (namecnt, 2) = 1 )
THEN
namecnt := (namecnt + 1);
END IF;
OPEN c_name;
FOR loop_counter IN 0 .. cast((namecnt/2) AS INTEGER)
LOOP
FETCH c_name  
INTO os_c_balance, os_c_first, os_c_middle, os_c_id;
END LOOP;
close c_name;
ELSE
SELECT c_balance, c_first, c_middle, c_last
INTO os_c_balance, os_c_first, os_c_middle, os_c_last
FROM customer
WHERE c_id = os_c_id AND c_d_id = os_d_id AND c_w_id = os_w_id;
END IF;
SELECT o_id, o_carrier_id, o_entry_d 
INTO os_o_id, os_o_carrier_id, os_entdate
FROM
(SELECT o_id, o_carrier_id, o_entry_d
FROM orders where o_d_id = os_d_id AND o_w_id = os_w_id and o_c_id=os_c_id
ORDER BY o_id DESC) AS SUBQUERY
LIMIT 1;
FOR os_ol IN
SELECT ol_i_id, ol_supply_w_id, ol_quantity, ol_amount, ol_delivery_d, out_os_c_id, out_os_c_last, os_c_first, os_c_middle, os_c_balance, os_o_id, os_entdate, os_o_carrier_id	
FROM order_line
WHERE ol_o_id = os_o_id AND ol_d_id = os_d_id AND ol_w_id = os_w_id
LOOP
RETURN NEXT os_ol;
END LOOP;
EXCEPTION
WHEN serialization_failure OR deadlock_detected OR no_data_found
THEN ROLLBACK;
END; 
' LANGUAGE 'plpgsql';
}
set sql(6) { CREATE OR REPLACE FUNCTION SLEV (INTEGER, INTEGER, INTEGER) RETURNS INTEGER AS '
DECLARE
st_w_id			ALIAS FOR $1;
st_d_id			ALIAS FOR $2;
threshold		ALIAS FOR $3; 

st_o_id			NUMERIC;	
stock_count		INTEGER;
BEGIN
SELECT d_next_o_id INTO st_o_id
FROM district
WHERE d_w_id=st_w_id AND d_id=st_d_id;

SELECT COUNT(DISTINCT (s_i_id)) INTO stock_count
FROM order_line, stock
WHERE ol_w_id = st_w_id AND
ol_d_id = st_d_id AND (ol_o_id < st_o_id) AND
ol_o_id >= (st_o_id - 20) AND s_w_id = st_w_id AND
s_i_id = ol_i_id AND s_quantity < threshold;
RETURN stock_count;
EXCEPTION
WHEN serialization_failure OR deadlock_detected OR no_data_found
THEN ROLLBACK;
END; 
' LANGUAGE 'plpgsql';
	}
for { set i 1 } { $i <= 6 } { incr i } {
set result [ pg_exec $lda $sql($i) ]
if {[pg_result $result -status] != "PGRES_COMMAND_OK"} {
error "[pg_result $result -error]"
	} else {
pg_result $result -clear
	}
    }
}
return
}

proc GatherStatistics { lda } {
	puts "GATHERING SCHEMA STATISTICS"
	set sql(1) "ANALYZE"
	for { set i 1 } { $i <= 1 } { incr i } {
		set result [ pg_exec $lda $sql($i) ]
		if {[pg_result $result -status] != "PGRES_COMMAND_OK"} {
			error "[pg_result $result -error]"
		} else {
			pg_result $result -clear
		}
	}
	return
}

proc ConnectToPostgres { host port user password dbname } {
global tcl_platform
if {[catch {set lda [pg_connect -conninfo [list host = $host port = $port user = $user password = $password dbname = $dbname ]]}]} {
puts stderr "Error, the database connection to $host could not be established"
set lda "Failed"
 } else {
if {$tcl_platform(platform) == "windows"} {
#Workaround for Bug #95 where first connection fails on Windows
catch {pg_disconnect $lda}
set lda [pg_connect -conninfo [list host = $host port = $port user = $user password = $password dbname = $dbname ]]
        }
pg_notice_handler $lda puts
set result [ pg_exec $lda "set CLIENT_MIN_MESSAGES TO 'ERROR'" ]
pg_result $result -clear
        }
return $lda
}

proc CreateUserDatabase { lda db user password } {
puts "CREATING DATABASE $db under OWNER $user"  
set sql(1) "CREATE USER $user PASSWORD '$password'"
set sql(2) "CREATE DATABASE $db OWNER $user"
for { set i 1 } { $i <= 2 } { incr i } {
set result [ pg_exec $lda $sql($i) ]
if {[pg_result $result -status] != "PGRES_COMMAND_OK"} {
error "[pg_result $result -error]"
	} else {
pg_result $result -clear
	}
    }
return
}

proc CreateTables { lda ora_compatible } {
puts "CREATING TPCC TABLES"
if { $ora_compatible eq "true" } {
set sql(1) "CREATE TABLE CUSTOMER (C_ID NUMBER(5, 0), C_D_ID NUMBER(2, 0), C_W_ID NUMBER(4, 0), C_FIRST VARCHAR2(16), C_MIDDLE CHAR(2), C_LAST VARCHAR2(16), C_STREET_1 VARCHAR2(20), C_STREET_2 VARCHAR2(20), C_CITY VARCHAR2(20), C_STATE CHAR(2), C_ZIP CHAR(9), C_PHONE CHAR(16), C_SINCE DATE, C_CREDIT CHAR(2), C_CREDIT_LIM NUMBER(12, 2), C_DISCOUNT NUMBER(4, 4), C_BALANCE NUMBER(12, 2), C_YTD_PAYMENT NUMBER(12, 2), C_PAYMENT_CNT NUMBER(8, 0), C_DELIVERY_CNT NUMBER(8, 0), C_DATA VARCHAR2(500), RECORD_UPDATE VARCHAR2(15), RECORD_DELETE VARCHAR2(15), RECORD_SELECT VARCHAR2(15))"
set sql(2) "CREATE TABLE DISTRICT (D_ID NUMBER(2, 0), D_W_ID NUMBER(4, 0), D_YTD NUMBER(12, 2), D_TAX NUMBER(4, 4), D_NEXT_O_ID NUMBER, D_NAME VARCHAR2(10), D_STREET_1 VARCHAR2(20), D_STREET_2 VARCHAR2(20), D_CITY VARCHAR2(20), D_STATE CHAR(2), D_ZIP CHAR(9))"
set sql(3) "CREATE TABLE HISTORY (H_C_ID NUMBER, H_C_D_ID NUMBER, H_C_W_ID NUMBER, H_D_ID NUMBER, H_W_ID NUMBER, H_DATE DATE, H_AMOUNT NUMBER(6, 2), H_DATA VARCHAR2(24))"
set sql(4) "CREATE TABLE ITEM (I_ID NUMBER(6, 0), I_IM_ID NUMBER, I_NAME VARCHAR2(24), I_PRICE NUMBER(5, 2), I_DATA VARCHAR2(50))"
set sql(5) "CREATE TABLE WAREHOUSE (W_ID NUMBER(4, 0), W_YTD NUMBER(12, 2), W_TAX NUMBER(4, 4), W_NAME VARCHAR2(10), W_STREET_1 VARCHAR2(20), W_STREET_2 VARCHAR2(20), W_CITY VARCHAR2(20), W_STATE CHAR(2), W_ZIP CHAR(9))"
set sql(6) "CREATE TABLE STOCK (S_I_ID NUMBER(6, 0), S_W_ID NUMBER(4, 0), S_QUANTITY NUMBER(6, 0), S_DIST_01 CHAR(24), S_DIST_02 CHAR(24), S_DIST_03 CHAR(24), S_DIST_04 CHAR(24), S_DIST_05 CHAR(24), S_DIST_06 CHAR(24), S_DIST_07 CHAR(24), S_DIST_08 CHAR(24), S_DIST_09 CHAR(24), S_DIST_10 CHAR(24), S_YTD NUMBER(10, 0), S_ORDER_CNT NUMBER(6, 0), S_REMOTE_CNT NUMBER(6, 0), S_DATA VARCHAR2(50))"
set sql(7) "CREATE TABLE NEW_ORDER (NO_W_ID NUMBER, NO_D_ID NUMBER, NO_O_ID NUMBER)"
set sql(8) "CREATE TABLE ORDERS (O_ID NUMBER, O_W_ID NUMBER, O_D_ID NUMBER, O_C_ID NUMBER, O_CARRIER_ID NUMBER, O_OL_CNT NUMBER, O_ALL_LOCAL NUMBER, O_ENTRY_D DATE)"
set sql(9) "CREATE TABLE ORDER_LINE (OL_W_ID NUMBER, OL_D_ID NUMBER, OL_O_ID NUMBER, OL_NUMBER NUMBER, OL_I_ID NUMBER, OL_DELIVERY_D DATE, OL_AMOUNT NUMBER, OL_SUPPLY_W_ID NUMBER, OL_QUANTITY NUMBER, OL_DIST_INFO CHAR(24))"
	} else {
set sql(1) "CREATE TABLE CUSTOMER (C_ID NUMERIC(5,0), C_D_ID NUMERIC(2,0), C_W_ID NUMERIC(4,0), C_FIRST VARCHAR(16), C_MIDDLE CHAR(2), C_LAST VARCHAR(16), C_STREET_1 VARCHAR(20), C_STREET_2 VARCHAR(20), C_CITY VARCHAR(20), C_STATE CHAR(2), C_ZIP CHAR(9), C_PHONE CHAR(16), C_SINCE TIMESTAMP, C_CREDIT CHAR(2), C_CREDIT_LIM NUMERIC(12, 2), C_DISCOUNT NUMERIC(4,4), C_BALANCE NUMERIC(12, 2), C_YTD_PAYMENT NUMERIC(12, 2), C_PAYMENT_CNT NUMERIC(8,0), C_DELIVERY_CNT NUMERIC(8,0), C_DATA VARCHAR(500), RECORD_UPDATE VARCHAR(15), RECORD_DELETE VARCHAR(15), RECORD_SELECT VARCHAR(15)) WITH (FILLFACTOR=50)"
set sql(2) "CREATE TABLE DISTRICT (D_ID NUMERIC(2,0), D_W_ID NUMERIC(4,0), D_YTD NUMERIC(12, 2), D_TAX NUMERIC(4,4), D_NEXT_O_ID NUMERIC, D_NAME VARCHAR(10), D_STREET_1 VARCHAR(20), D_STREET_2 VARCHAR(20), D_CITY VARCHAR(20), D_STATE CHAR(2), D_ZIP CHAR(9)) WITH (FILLFACTOR=10)"
set sql(3) "CREATE TABLE HISTORY (H_C_ID NUMERIC, H_C_D_ID NUMERIC, H_C_W_ID NUMERIC, H_D_ID NUMERIC, H_W_ID NUMERIC, H_DATE TIMESTAMP, H_AMOUNT NUMERIC(6,2), H_DATA VARCHAR(24)) WITH (FILLFACTOR=50)"
set sql(4) "CREATE TABLE ITEM (I_ID NUMERIC(6,0), I_IM_ID NUMERIC, I_NAME VARCHAR(24), I_PRICE NUMERIC(5,2), I_DATA VARCHAR(50)) WITH (FILLFACTOR=50)"
set sql(5) "CREATE TABLE WAREHOUSE (W_ID NUMERIC(4,0), W_YTD NUMERIC(12, 2), W_TAX NUMERIC(4,4), W_NAME VARCHAR(10), W_STREET_1 VARCHAR(20), W_STREET_2 VARCHAR(20), W_CITY VARCHAR(20), W_STATE CHAR(2), W_ZIP CHAR(9)) WITH (FILLFACTOR=10)"
set sql(6) "CREATE TABLE STOCK (S_I_ID NUMERIC(6,0), S_W_ID NUMERIC(4,0), S_QUANTITY NUMERIC(6,0), S_DIST_01 CHAR(24), S_DIST_02 CHAR(24), S_DIST_03 CHAR(24), S_DIST_04 CHAR(24), S_DIST_05 CHAR(24), S_DIST_06 CHAR(24), S_DIST_07 CHAR(24), S_DIST_08 CHAR(24), S_DIST_09 CHAR(24), S_DIST_10 CHAR(24), S_YTD NUMERIC(10, 0), S_ORDER_CNT NUMERIC(6,0), S_REMOTE_CNT NUMERIC(6,0), S_DATA VARCHAR(50)) WITH (FILLFACTOR=50)"
set sql(7) "CREATE TABLE NEW_ORDER (NO_W_ID NUMERIC, NO_D_ID NUMERIC, NO_O_ID NUMERIC) WITH (FILLFACTOR=50)"
set sql(8) "CREATE TABLE ORDERS (O_ID NUMERIC, O_W_ID NUMERIC, O_D_ID NUMERIC, O_C_ID NUMERIC, O_CARRIER_ID NUMERIC, O_OL_CNT NUMERIC, O_ALL_LOCAL NUMERIC, O_ENTRY_D TIMESTAMP) WITH (FILLFACTOR=50)"
set sql(9) "CREATE TABLE ORDER_LINE (OL_W_ID NUMERIC, OL_D_ID NUMERIC, OL_O_ID NUMERIC, OL_NUMBER NUMERIC, OL_I_ID NUMERIC, OL_DELIVERY_D TIMESTAMP, OL_AMOUNT NUMERIC, OL_SUPPLY_W_ID NUMERIC, OL_QUANTITY NUMERIC, OL_DIST_INFO CHAR(24)) WITH (FILLFACTOR=50)"
	}
for { set i 1 } { $i <= 9 } { incr i } {
set result [ pg_exec $lda $sql($i) ]
if {[pg_result $result -status] != "PGRES_COMMAND_OK"} {
error "[pg_result $result -error]"
	} else {
pg_result $result -clear
	}
    }
}

proc CreateIndexes { lda } {
puts "CREATING TPCC INDEXES"
set sql(1) "ALTER TABLE CUSTOMER ADD CONSTRAINT CUSTOMER_I1 PRIMARY KEY (C_W_ID, C_D_ID, C_ID)"
set sql(2) "CREATE UNIQUE INDEX CUSTOMER_I2 ON CUSTOMER (C_W_ID, C_D_ID, C_LAST, C_FIRST, C_ID)"
set sql(3) "ALTER TABLE DISTRICT ADD CONSTRAINT DISTRICT_I1 PRIMARY KEY (D_W_ID, D_ID) WITH (FILLFACTOR = 100)"
set sql(4) "ALTER TABLE NEW_ORDER ADD CONSTRAINT NEW_ORDER_I1 PRIMARY KEY (NO_W_ID, NO_D_ID, NO_O_ID)"
set sql(5) "ALTER TABLE ITEM ADD CONSTRAINT ITEM_I1 PRIMARY KEY (I_ID)"
set sql(6) "ALTER TABLE ORDERS ADD CONSTRAINT ORDERS_I1 PRIMARY KEY (O_W_ID, O_D_ID, O_ID)"
set sql(7) "CREATE UNIQUE INDEX ORDERS_I2 ON ORDERS (O_W_ID, O_D_ID, O_C_ID, O_ID)"
set sql(8) "ALTER TABLE ORDER_LINE ADD CONSTRAINT ORDER_LINE_I1 PRIMARY KEY (OL_W_ID, OL_D_ID, OL_O_ID, OL_NUMBER)"
set sql(9) "ALTER TABLE STOCK ADD CONSTRAINT STOCK_I1 PRIMARY KEY (S_W_ID, S_I_ID)"
set sql(10) "ALTER TABLE WAREHOUSE ADD CONSTRAINT WAREHOUSE_I1 PRIMARY KEY (W_ID) WITH (FILLFACTOR = 100)"
for { set i 1 } { $i <= 10 } { incr i } {
set result [ pg_exec $lda $sql($i) ]
if {[pg_result $result -status] != "PGRES_COMMAND_OK"} {
error "[pg_result $result -error]"
	}  else {
	pg_result $result -clear
	}
    }
return
}

proc chk_thread {} {
	set chk [package provide Thread]
	if {[string length $chk]} {
	    return "TRUE"
	    } else {
	    return "FALSE"
	}
    }

proc RandomNumber {m M} {return [expr {int($m+rand()*($M+1-$m))}]}

proc gettimestamp { } {
set tstamp [ clock format [ clock seconds ] -format %Y%m%d%H%M%S ]
return $tstamp
}

proc NURand { iConst x y C } {return [ expr {((([RandomNumber 0 $iConst] | [RandomNumber $x $y]) + $C) % ($y - $x + 1)) + $x }]}

proc Lastname { num namearr } {
	set name [ concat [ lindex $namearr [ expr {( $num / 100 ) % 10 }] ][ lindex $namearr [ expr {( $num / 10 ) % 10 }] ][ lindex $namearr [ expr {( $num / 1 ) % 10 }]]]
	return $name
}

proc MakeAlphaString { x y chArray chalen } {
	set len [ RandomNumber $x $y ]
	for {set i 0} {$i < $len } {incr i } {
		append alphastring [lindex $chArray [ expr {int(rand()*$chalen)}]]
	}
	return $alphastring
}

proc Makezip { } {
	set zip "000011111"
	set ranz [ RandomNumber 0 9999 ]
	set len [ expr {[ string length $ranz ] - 1} ]
	set zip [ string replace $zip 0 $len $ranz ]
	return $zip
}

proc MakeAddress { chArray chalen } {
return [ list [ MakeAlphaString 10 20 $chArray $chalen ] [ MakeAlphaString 10 20 $chArray $chalen ] [ MakeAlphaString 10 20 $chArray $chalen ] [ MakeAlphaString 2 2 $chArray $chalen ] [ Makezip ] ]
}

proc MakeNumberString { } {
	set zeroed "00000000"
	set a [ RandomNumber 0 99999999 ] 
	set b [ RandomNumber 0 99999999 ] 
	set lena [ expr {[ string length $a ] - 1} ]
	set lenb [ expr {[ string length $b ] - 1} ]
	set c_pa [ string replace $zeroed 0 $lena $a ]
	set c_pb [ string replace $zeroed 0 $lenb $b ]
	set numberstring [ concat $c_pa$c_pb ]
	return $numberstring
}

proc my_lpick list {
    lindex $list [expr {int(rand()*[llength $list])}]
}

proc listFromFile {filename} {
    set f [open $filename r]
    set data [split [string trim [read $f]]]
    close $f
    return $data
}

proc Customer { lda d_id w_id CUST_PER_DIST ora_compatible } {
	set globArray [ list 0 1 2 3 4 5 6 7 8 9 A B C D E F G H I J K L M N O P Q R S T U V W X Y Z a b c d e f g h i j k l m n o p q r s t u v w x y z ]
	set namearr [list BAR OUGHT ABLE PRI PRES ESE ANTI CALLY ATION EING]
	set chalen [ llength $globArray ]
	set bld_cnt 1
	set c_d_id $d_id
	set c_w_id $w_id
	set c_middle "OE"
	set c_balance -10.0
	set c_credit_lim 50000
	set h_amount 10.0
	set my_values [listFromFile "config/values.txt"]
	if { $ora_compatible eq "true" } {
		proc date_function {} {
			set df "to_date('[ gettimestamp ]','YYYYMMDDHH24MISS')"
			return $df
		}
		} else {
			proc date_function {} {
				set df "to_timestamp('[ gettimestamp ]','YYYYMMDDHH24MISS')"
			return $df
		}
	}
	puts "Loading Customer for DID=$d_id WID=$w_id"
	for {set c_id 1} {$c_id <= $CUST_PER_DIST } {incr c_id } {
		set c_first [ MakeAlphaString 8 16 $globArray $chalen ]
		if { $c_id <= 1000 } {
		set c_last [ Lastname [ expr {$c_id - 1} ] $namearr ]
			} else {
		set nrnd [ NURand 255 0 999 123 ]
		set c_last [ Lastname $nrnd $namearr ]
			}
		set c_add [ MakeAddress $globArray $chalen ]
		set c_phone [ MakeNumberString ]
		if { [RandomNumber 0 1] eq 1 } {
		set c_credit "GC"
			} else {
		set c_credit "BC"
			}
		set disc_ran [ RandomNumber 0 50 ]
		set c_discount [ expr {$disc_ran / 100.0} ]
		set c_data [ MakeAlphaString 300 500 $globArray $chalen ]
		set res_up  [my_lpick $my_values]
		set res_del [my_lpick $my_values]
		set res_sel  [my_lpick $my_values]
		append c_val_list ('$c_id', '$c_d_id', '$c_w_id', '$c_first', '$c_middle', '$c_last', '[ lindex $c_add 0 ]', '[ lindex $c_add 1 ]', '[ lindex $c_add 2 ]', '[ lindex $c_add 3 ]', '[ lindex $c_add 4 ]', '$c_phone', [ date_function ], '$c_credit', '$c_credit_lim', '$c_discount', '$c_balance', '$c_data', '10.0', '1', '0', '$res_up', '$res_del', '$res_sel')
		set h_data [ MakeAlphaString 12 24 $globArray $chalen ]
		append h_val_list ('$c_id', '$c_d_id', '$c_w_id', '$c_w_id', '$c_d_id', [ date_function ], '$h_amount', '$h_data')
		if { $bld_cnt<= 999 } { 
		append c_val_list ,
		append h_val_list ,
			}
		incr bld_cnt
		if { ![ expr {$c_id % 1000} ] } {
		set result [ pg_exec $lda "insert into customer (c_id, c_d_id, c_w_id, c_first, c_middle, c_last, c_street_1, c_street_2, c_city, c_state, c_zip, c_phone, c_since, c_credit, c_credit_lim, c_discount, c_balance, c_data, c_ytd_payment, c_payment_cnt, c_delivery_cnt, RECORD_UPDATE, RECORD_DELETE, RECORD_SELECT) values $c_val_list" ]
		if {[pg_result $result -status] != "PGRES_COMMAND_OK"} {
					error "[pg_result $result -error]"
				} else {
			pg_result $result -clear
			}
		set result [ pg_exec $lda "insert into history (h_c_id, h_c_d_id, h_c_w_id, h_w_id, h_d_id, h_date, h_amount, h_data) values $h_val_list" ]
		if {[pg_result $result -status] != "PGRES_COMMAND_OK"} {
					error "[pg_result $result -error]"
				} else {
			pg_result $result -clear
			}
			set result [ pg_exec $lda "commit" ]
			pg_result $result -clear
			set bld_cnt 1
			unset c_val_list
			unset h_val_list
				}
		}
	puts "Customer Done"
	return
}

proc Orders { lda d_id w_id MAXITEMS ORD_PER_DIST ora_compatible } {
set globArray [ list 0 1 2 3 4 5 6 7 8 9 A B C D E F G H I J K L M N O P Q R S T U V W X Y Z a b c d e f g h i j k l m n o p q r s t u v w x y z ]
set chalen [ llength $globArray ]
set bld_cnt 1
if { $ora_compatible eq "true" } {
proc date_function {} {
set df "to_date('[ gettimestamp ]','YYYYMMDDHH24MISS')"
return $df
}
	} else {
proc date_function {} {
set df "to_timestamp('[ gettimestamp ]','YYYYMMDDHH24MISS')"
return $df
}
	}
puts "Loading Orders for D=$d_id W=$w_id"
set o_d_id $d_id
set o_w_id $w_id
for {set i 1} {$i <= $ORD_PER_DIST } {incr i } {
set cust($i) $i
}
for {set i 1} {$i <= $ORD_PER_DIST } {incr i } {
set r [ RandomNumber $i $ORD_PER_DIST ]
set t $cust($i)
set cust($i) $cust($r)
set $cust($r) $t
}
set e ""
for {set o_id 1} {$o_id <= $ORD_PER_DIST } {incr o_id } {
set o_c_id $cust($o_id)
set o_carrier_id [ RandomNumber 1 10 ]
set o_ol_cnt [ RandomNumber 5 15 ]
if { $o_id > 2100 } {
set e "o1"
append o_val_list ('$o_id', '$o_c_id', '$o_d_id', '$o_w_id', [ date_function ], null, '$o_ol_cnt', '1')
set e "no1"
append no_val_list ('$o_id', '$o_d_id', '$o_w_id')
  } else {
  set e "o3"
append o_val_list ('$o_id', '$o_c_id', '$o_d_id', '$o_w_id', [ date_function ], '$o_carrier_id', '$o_ol_cnt', '1')
	}
for {set ol 1} {$ol <= $o_ol_cnt } {incr ol } {
set ol_i_id [ RandomNumber 1 $MAXITEMS ]
set ol_supply_w_id $o_w_id
set ol_quantity 5
set ol_amount 0.0
set ol_dist_info [ MakeAlphaString 24 24 $globArray $chalen ]
if { $o_id > 2100 } {
set e "ol1"
append ol_val_list ('$o_id', '$o_d_id', '$o_w_id', '$ol', '$ol_i_id', '$ol_supply_w_id', '$ol_quantity', '$ol_amount', '$ol_dist_info', null)
if { $bld_cnt<= 99 } { append ol_val_list , } else {
if { $ol != $o_ol_cnt } { append ol_val_list , }
		}
	} else {
set amt_ran [ RandomNumber 10 10000 ]
set ol_amount [ expr {$amt_ran / 100.0} ]
set e "ol2"
append ol_val_list ('$o_id', '$o_d_id', '$o_w_id', '$ol', '$ol_i_id', '$ol_supply_w_id', '$ol_quantity', '$ol_amount', '$ol_dist_info', [ date_function ])
if { $bld_cnt<= 99 } { append ol_val_list , } else {
if { $ol != $o_ol_cnt } { append ol_val_list , }
		}
	}
}
if { $bld_cnt<= 99 } {
append o_val_list ,
if { $o_id > 2100 } {
append no_val_list ,
		}
        }
incr bld_cnt
 if { ![ expr {$o_id % 100} ] } {
 if { ![ expr {$o_id % 1000} ] } {
	puts "...$o_id"
	}
set result [ pg_exec $lda  "insert into orders (o_id, o_c_id, o_d_id, o_w_id, o_entry_d, o_carrier_id, o_ol_cnt, o_all_local) values $o_val_list" ]
if {[pg_result $result -status] != "PGRES_COMMAND_OK"} {
            error "[pg_result $result -error]"
        } else {
	pg_result $result -clear
	}
if { $o_id > 2100 } {
set result [ pg_exec $lda "insert into new_order (no_o_id, no_d_id, no_w_id) values $no_val_list" ]
if {[pg_result $result -status] != "PGRES_COMMAND_OK"} {
            error "[pg_result $result -error]"
        } else {
	pg_result $result -clear
	}
	}
set result [ pg_exec $lda "insert into order_line (ol_o_id, ol_d_id, ol_w_id, ol_number, ol_i_id, ol_supply_w_id, ol_quantity, ol_amount, ol_dist_info, ol_delivery_d) values $ol_val_list" ]
if {[pg_result $result -status] != "PGRES_COMMAND_OK"} {
            error "[pg_result $result -error]"
        } else {
	pg_result $result -clear
	}
	set result [ pg_exec $lda "commit" ]
	pg_result $result -clear
	set bld_cnt 1
	unset o_val_list
	unset -nocomplain no_val_list
	unset ol_val_list
			}
		}
	set result [ pg_exec $lda "commit" ]
	pg_result $result -clear
	puts "Orders Done"
	return
}

proc LoadItems { lda MAXITEMS } {
set globArray [ list 0 1 2 3 4 5 6 7 8 9 A B C D E F G H I J K L M N O P Q R S T U V W X Y Z a b c d e f g h i j k l m n o p q r s t u v w x y z ]
set chalen [ llength $globArray ]
puts "Loading Item"
set result [ pg_exec $lda "begin" ]
pg_result $result -clear
for {set i 0} {$i < [ expr {$MAXITEMS/10} ] } {incr i } {
set orig($i) 0
}
for {set i 0} {$i < [ expr {$MAXITEMS/10} ] } {incr i } {
set pos [ RandomNumber 0 $MAXITEMS ] 
set orig($pos) 1
	}
for {set i_id 1} {$i_id <= $MAXITEMS } {incr i_id } {
set i_im_id [ RandomNumber 1 10000 ] 
set i_name [ MakeAlphaString 14 24 $globArray $chalen ]
set i_price_ran [ RandomNumber 100 10000 ]
set i_price [ format "%4.2f" [ expr {$i_price_ran / 100.0} ] ]
set i_data [ MakeAlphaString 26 50 $globArray $chalen ]
if { [ info exists orig($i_id) ] } {
if { $orig($i_id) eq 1 } {
set first [ RandomNumber 0 [ expr {[ string length $i_data] - 8}] ]
set last [ expr {$first + 8} ]
set i_data [ string replace $i_data $first $last "original" ]
	}
}
set result [ pg_exec $lda "insert into item (i_id, i_im_id, i_name, i_price, i_data) VALUES ('$i_id', '$i_im_id', '$i_name', '$i_price', '$i_data')" ]
 if {[pg_result $result -status] != "PGRES_COMMAND_OK"} {
            error "[pg_result $result -error]"
	    return
        } else {
	pg_result $result -clear
	}
      if { ![ expr {$i_id % 10000} ] } {
	puts "Loading Items - $i_id"
			}
		}
set result [ pg_exec $lda "commit" ]
pg_result $result -clear
puts "Item done"
return
	}

proc Stock { lda w_id MAXITEMS } {
set globArray [ list 0 1 2 3 4 5 6 7 8 9 A B C D E F G H I J K L M N O P Q R S T U V W X Y Z a b c d e f g h i j k l m n o p q r s t u v w x y z ]
set chalen [ llength $globArray ]
set bld_cnt 1
puts "Loading Stock Wid=$w_id"
set s_w_id $w_id
for {set i 0} {$i < [ expr {$MAXITEMS/10} ] } {incr i } {
set orig($i) 0
}
for {set i 0} {$i < [ expr {$MAXITEMS/10} ] } {incr i } {
set pos [ RandomNumber 0 $MAXITEMS ] 
set orig($pos) 1
	}
for {set s_i_id 1} {$s_i_id <= $MAXITEMS } {incr s_i_id } {
set s_quantity [ RandomNumber 10 100 ]
set s_dist_01 [ MakeAlphaString 24 24 $globArray $chalen ]
set s_dist_02 [ MakeAlphaString 24 24 $globArray $chalen ]
set s_dist_03 [ MakeAlphaString 24 24 $globArray $chalen ]
set s_dist_04 [ MakeAlphaString 24 24 $globArray $chalen ]
set s_dist_05 [ MakeAlphaString 24 24 $globArray $chalen ]
set s_dist_06 [ MakeAlphaString 24 24 $globArray $chalen ]
set s_dist_07 [ MakeAlphaString 24 24 $globArray $chalen ]
set s_dist_08 [ MakeAlphaString 24 24 $globArray $chalen ]
set s_dist_09 [ MakeAlphaString 24 24 $globArray $chalen ]
set s_dist_10 [ MakeAlphaString 24 24 $globArray $chalen ]
set s_data [ MakeAlphaString 26 50 $globArray $chalen ]
if { [ info exists orig($s_i_id) ] } {
if { $orig($s_i_id) eq 1 } {
set first [ RandomNumber 0 [ expr {[ string length $s_data]} - 8 ] ]
set last [ expr {$first + 8} ]
set s_data [ string replace $s_data $first $last "original" ]
		}
	}
append val_list ('$s_i_id', '$s_w_id', '$s_quantity', '$s_dist_01', '$s_dist_02', '$s_dist_03', '$s_dist_04', '$s_dist_05', '$s_dist_06', '$s_dist_07', '$s_dist_08', '$s_dist_09', '$s_dist_10', '$s_data', '0', '0', '0')
if { $bld_cnt<= 999 } { 
append val_list ,
}
incr bld_cnt
      if { ![ expr {$s_i_id % 1000} ] } {
set result [ pg_exec $lda "insert into stock (s_i_id, s_w_id, s_quantity, s_dist_01, s_dist_02, s_dist_03, s_dist_04, s_dist_05, s_dist_06, s_dist_07, s_dist_08, s_dist_09, s_dist_10, s_data, s_ytd, s_order_cnt, s_remote_cnt) values $val_list" ]
	if {[pg_result $result -status] != "PGRES_COMMAND_OK"} {
            error "[pg_result $result -error]"
        } else {
	pg_result $result -clear
	}
	set result [ pg_exec $lda "commit" ]
	pg_result $result -clear
	set bld_cnt 1
	unset val_list
	}
      if { ![ expr {$s_i_id % 20000} ] } {
	puts "Loading Stock - $s_i_id"
			}
	}
	set result [ pg_exec $lda "commit" ]
	pg_result $result -clear
	puts "Stock done"
	return
}

proc District { lda w_id DIST_PER_WARE } {
set globArray [ list 0 1 2 3 4 5 6 7 8 9 A B C D E F G H I J K L M N O P Q R S T U V W X Y Z a b c d e f g h i j k l m n o p q r s t u v w x y z ]
set chalen [ llength $globArray ]
puts "Loading District"
set d_w_id $w_id
set d_ytd 30000.0
set d_next_o_id 3001
for {set d_id 1} {$d_id <= $DIST_PER_WARE } {incr d_id } {
set d_name [ MakeAlphaString 6 10 $globArray $chalen ]
set d_add [ MakeAddress $globArray $chalen ]
set d_tax_ran [ RandomNumber 10 20 ]
set d_tax [ string replace [ format "%.2f" [ expr {$d_tax_ran / 100.0} ] ] 0 0 "" ]
set result [ pg_exec $lda "insert into district (d_id, d_w_id, d_name, d_street_1, d_street_2, d_city, d_state, d_zip, d_tax, d_ytd, d_next_o_id) values ('$d_id', '$d_w_id', '$d_name', '[ lindex $d_add 0 ]', '[ lindex $d_add 1 ]', '[ lindex $d_add 2 ]', '[ lindex $d_add 3 ]', '[ lindex $d_add 4 ]', '$d_tax', '$d_ytd', '$d_next_o_id')" ]
if {[pg_result $result -status] != "PGRES_COMMAND_OK"} {
            error "[pg_result $result -error]"
	    return
        } else {
	pg_result $result -clear
	}
	}
	set result [ pg_exec $lda "commit" ]
	pg_result $result -clear
	puts "District done"
	return
}

proc LoadWare { lda ware_start count_ware MAXITEMS DIST_PER_WARE } {
set globArray [ list 0 1 2 3 4 5 6 7 8 9 A B C D E F G H I J K L M N O P Q R S T U V W X Y Z a b c d e f g h i j k l m n o p q r s t u v w x y z ]
set chalen [ llength $globArray ]
puts "Loading Warehouse"
set w_ytd 3000000.00
for {set w_id $ware_start } {$w_id <= $count_ware } {incr w_id } {
set w_name [ MakeAlphaString 6 10 $globArray $chalen ]
set add [ MakeAddress $globArray $chalen ]
set w_tax_ran [ RandomNumber 10 20 ]
set w_tax [ string replace [ format "%.2f" [ expr {$w_tax_ran / 100.0} ] ] 0 0 "" ]
set result [ pg_exec $lda "insert into warehouse (w_id, w_name, w_street_1, w_street_2, w_city, w_state, w_zip, w_tax, w_ytd) values ('$w_id', '$w_name', '[ lindex $add 0 ]', '[ lindex $add 1 ]', '[ lindex $add 2 ]' , '[ lindex $add 3 ]', '[ lindex $add 4 ]', '$w_tax', '$w_ytd')" ]
 if {[pg_result $result -status] != "PGRES_COMMAND_OK"} {
            error "[pg_result $result -error]"
        } else {
	pg_result $result -clear
	}
	Stock $lda $w_id $MAXITEMS
	District $lda $w_id $DIST_PER_WARE
	set result [ pg_exec $lda "commit" ]
	pg_result $result -clear
	}
}

proc LoadCust { lda ware_start count_ware CUST_PER_DIST DIST_PER_WARE ora_compatible } {
for {set w_id $ware_start} {$w_id <= $count_ware } {incr w_id } {
for {set d_id 1} {$d_id <= $DIST_PER_WARE } {incr d_id } {
	Customer $lda $d_id $w_id $CUST_PER_DIST $ora_compatible
		}
	}
	set result [ pg_exec $lda "commit" ]
	pg_result $result -clear
	return
}

proc LoadOrd { lda ware_start count_ware MAXITEMS ORD_PER_DIST DIST_PER_WARE ora_compatible } {
for {set w_id $ware_start} {$w_id <= $count_ware } {incr w_id } {
for {set d_id 1} {$d_id <= $DIST_PER_WARE } {incr d_id } {
	Orders $lda $d_id $w_id $MAXITEMS $ORD_PER_DIST $ora_compatible
		}
	}
	set result [ pg_exec $lda "commit" ]
	pg_result $result -clear
	return
}
proc do_tpcc { host port count_ware superuser superuser_password defaultdb db user password ora_compatible num_threads } {
set MAXITEMS 100000
set CUST_PER_DIST 3000
set DIST_PER_WARE 10
set ORD_PER_DIST 3000
if { $num_threads > $count_ware } { set num_threads $count_ware }
if { $num_threads > 1 && [ chk_thread ] eq "TRUE" } {
set threaded "MULTI-THREADED"
set mythread [thread::id]
set allthreads [split [thread::names]]
set totalvirtualusers [expr [llength $allthreads] - 1]
set myposition [expr $totalvirtualusers - [lsearch -exact $allthreads $mythread]]
if {![catch {set timeout [tsv::get application timeout]}]} {
if { $timeout eq 0 } { 
set totalvirtualusers [ expr $totalvirtualusers - 1 ] 
set myposition [ expr $myposition - 1 ]
	}
}
switch $myposition {
	1 { 
puts "Monitor Thread"
if { $threaded eq "MULTI-THREADED" } {
tsv::lappend common thrdlst monitor
for { set th 1 } { $th <= $totalvirtualusers } { incr th } {
tsv::lappend common thrdlst idle
			}
tsv::set application load "WAIT"
		}
	}
	default { 
puts "Worker Thread"
if { [ expr $myposition - 1 ] > $count_ware } { puts "No Warehouses to Create"; return }
     }
   }
} else {
set threaded "SINGLE-THREADED"
set num_threads 1
  }
if { $threaded eq "SINGLE-THREADED" ||  $threaded eq "MULTI-THREADED" && $myposition eq 1 } {
puts "CREATING [ string toupper $superuser ] SCHEMA"
set lda [ ConnectToPostgres $host $port $superuser $superuser_password $defaultdb ]
if { $lda eq "Failed" } {
error "error, the database connection to $host could not be established"
 } else {
CreateUserDatabase $lda $db $user $password
set result [ pg_exec $lda "commit" ]
pg_result $result -clear
pg_disconnect $lda
set lda [ ConnectToPostgres $host $port $user $password $db ]
if { $lda eq "Failed" } {
error "error, the database connection to $host could not be established"
 } else {
CreateTables $lda $ora_compatible
set result [ pg_exec $lda "commit" ]
pg_result $result -clear
        }
}
if { $threaded eq "MULTI-THREADED" } {
tsv::set application load "READY"
LoadItems $lda $MAXITEMS
puts "Monitoring Workers..."
set prevactive 0
while 1 {  
set idlcnt 0; set lvcnt 0; set dncnt 0;
for {set th 2} {$th <= $totalvirtualusers } {incr th} {
switch [tsv::lindex common thrdlst $th] {
idle { incr idlcnt }
active { incr lvcnt }
done { incr dncnt }
	}
}
if { $lvcnt != $prevactive } {
puts "Workers: $lvcnt Active $dncnt Done"
	}
set prevactive $lvcnt
if { $dncnt eq [expr  $totalvirtualusers - 1] } { break }
after 10000 
}} else {
LoadItems $lda $MAXITEMS
}}
if { $threaded eq "SINGLE-THREADED" ||  $threaded eq "MULTI-THREADED" && $myposition != 1 } {
if { $threaded eq "MULTI-THREADED" } {
puts "Waiting for Monitor Thread..."
set mtcnt 0
while 1 {  
incr mtcnt
if {  [ tsv::get application load ] eq "READY" } { break }
if {  [ tsv::get application abort ]  } { return }
if { $mtcnt eq 48 } { 
puts "Monitor failed to notify ready state" 
return
	}
after 5000 
}
set lda [ ConnectToPostgres $host $port $user $password $db ]
if { $lda eq "Failed" } {
error "error, the database connection to $host could not be established"
 }
if { [ expr $num_threads + 1 ] > $count_ware } { set num_threads $count_ware }
set chunk [ expr $count_ware / $num_threads ]
set rem [ expr $count_ware % $num_threads ]
if { $rem > $chunk } {
if { [ expr $myposition - 1 ] <= $rem } {
set chunk [ expr $chunk + 1 ]
set mystart [ expr ($chunk * ($myposition - 2)+1) + ($rem - ($rem - $myposition+$myposition)) ]
        } else {
set mystart [ expr ($chunk * ($myposition - 2)+1) + $rem ]
  } } else {
set mystart [ expr ($chunk * ($myposition - 2)+1) ]
        }
set myend [ expr $mystart + $chunk - 1 ]
if  { $myposition eq $num_threads + 1 } { set myend $count_ware }
puts "Loading $chunk Warehouses start:$mystart end:$myend"
tsv::lreplace common thrdlst $myposition $myposition active
} else {
set mystart 1
set myend $count_ware
}
puts "Start:[ clock format [ clock seconds ] ]"
LoadWare $lda $mystart $myend $MAXITEMS $DIST_PER_WARE
LoadCust $lda $mystart $myend $CUST_PER_DIST $DIST_PER_WARE $ora_compatible
LoadOrd $lda $mystart $myend $MAXITEMS $ORD_PER_DIST $DIST_PER_WARE $ora_compatible
puts "End:[ clock format [ clock seconds ] ]"
set result [ pg_exec $lda "commit" ]
pg_result $result -clear
if { $threaded eq "MULTI-THREADED" } {
tsv::lreplace common thrdlst $myposition $myposition done
	}
}
if { $threaded eq "SINGLE-THREADED" || $threaded eq "MULTI-THREADED" && $myposition eq 1 } {
CreateIndexes $lda
CreateStoredProcs $lda $ora_compatible
GatherStatistics $lda 
puts "[ string toupper $user ] SCHEMA COMPLETE"
	pg_disconnect $lda
	return
	}
}



set hostname [lindex $argv 0]
set port [lindex $argv 1]
set super_user_name [lindex $argv 2]
set super_user_pass [lindex $argv 3]
set super_user_db [lindex $argv 4]
set warehouses [lindex $argv 5]
set virtual_users [lindex $argv 6]

set user_db [lindex $argv 7]
set user_name [lindex $argv 8]
set user_pass [lindex $argv 9]
set enterprise_compat false

puts "============================================="
puts "= HOSTNAME: $hostname"
puts "= PORT: $port"
puts "= USER: $super_user_name:$super_user_pass"
puts "= DB: $super_user_db"
puts "= WAREHOUSES: $warehouses"
puts "= VIRTUAL_USERS: $virtual_users"
puts "============================================="
puts ""

do_tpcc $hostname $port $warehouses $super_user_name $super_user_pass $super_user_db $user_name $user_pass $user_db $enterprise_compat $virtual_users
