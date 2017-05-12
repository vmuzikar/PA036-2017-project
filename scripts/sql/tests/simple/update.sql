\timing on \o /dev/null;
UPDATE customer SET c_first='FirstUpdtID10' WHERE c_id=10;
SELECT * from customer WHERE c_id=10;
\timing off \o /dev/null;
