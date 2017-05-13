SET ROLE manager \o /dev/null;
\timing on \o /dev/null;

SELECT * FROM customer LIMIT 1;

\timing off \o /dev/null;
