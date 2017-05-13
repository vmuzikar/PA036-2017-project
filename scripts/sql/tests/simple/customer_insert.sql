\o /dev/null

\timing on
SELECT do_create_customer(:'customers_table', 'member', 2001);
\timing off

-- Clean INSERT
SELECT do_delete_customer(:'customers_table', 2001);
