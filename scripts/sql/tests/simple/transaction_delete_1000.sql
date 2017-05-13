\o /dev/null

SET ROLE tpcc;

SELECT perf_insert_customers(1000);

\timing ON
SELECT perf_delete_customers(1000);
\timing OFF

SET ROLE tpcc;