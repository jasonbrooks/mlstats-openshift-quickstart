SELECT list_all.fdl Date FROM (select LEFT(first_date, 10) fdl from messages group by fdl order by first_date) list_all
