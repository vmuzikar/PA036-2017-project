\o /dev/null

SET ROLE tpcc;

\timing ON
SELECT perf_insert_customers(1000);
\timing OFF

SELECT perf_clean_up(6000);
SET ROLE tpcc;