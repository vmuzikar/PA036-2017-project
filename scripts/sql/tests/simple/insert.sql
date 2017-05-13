\o /dev/null

\timing on
INSERT INTO customer (c_id, c_d_id, c_w_id, c_first, c_middle, c_last, c_street_1) 
VALUES (5000,11,2,'FirstName', 'Md', 'LastName', 'S1');
\timing off

-- Clean INSERT
SELECT * from customer WHERE  c_id=5000 AND c_d_id=11 AND c_w_id=2;
DELETE FROM customer WHERE c_id=5000 AND c_d_id=11 AND c_w_id=2;
