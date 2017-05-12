SET ROLE manager \o /dev/null;
\timing on \o /dev/null;
SELECT * FROM customer LIMIT 10;
\timing off \o /dev/null;