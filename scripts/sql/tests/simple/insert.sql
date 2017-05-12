\timing on
INSERT INTO customer (c_id, c_d_id, c_w_id, c_first, c_middle, c_last, c_street_1) 
VALUES (5000,11,2,'FirstName', 'Md', 'LastName', 'S1');
\timing off
\timing on
SELECT * from customer WHERE c_id=5000;
\timing off
