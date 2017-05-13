\o /dev/null

SET ROLE tpcc;

SELECT perf_insert_customers(1000);

\timing ON
SELECT perf_update_customers(1000);
\timing OFF

SELECT perf_clean_up(6000);

SET ROLE tpcc;