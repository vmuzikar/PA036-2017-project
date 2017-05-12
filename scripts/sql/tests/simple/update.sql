\timing on
UPDATE customer SET c_first='FirstUpdtID10' WHERE c_id=10;
\timing off
\timing on
SELECT * from customer WHERE c_id=10;
\timing off
