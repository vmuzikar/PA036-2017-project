\o /dev/null

\timing on
SELECT do_create_order(:'orders_table', 'member', 2001);
\timing off

-- Clean INSERT
SELECT do_delete_order('orders', 2001);