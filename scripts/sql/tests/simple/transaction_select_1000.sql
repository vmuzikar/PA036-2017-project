\o /dev/null

SET ROLE tpcc;
\timing on
SELECT perf_test(1000, 'SELECT * FROM customer LIMIT 1;');
\timing off


SET ROLE tpcc;


