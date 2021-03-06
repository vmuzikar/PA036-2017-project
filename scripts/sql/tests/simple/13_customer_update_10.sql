\o /dev/null

SET ROLE tpcc;

SELECT perf_insert_customers(:'customers_table', 10);

\timing ON
SELECT perf_update_customers(:'customers_table', 10);
\timing OFF

SELECT perf_clean_up(:'customers_table', 6000);

SET ROLE tpcc;