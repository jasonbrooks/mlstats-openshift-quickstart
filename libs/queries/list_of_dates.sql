select current_timestamp() into @endperiod;
select first_date into @startperiod from messages where left(first_date, 4) > 1979 order by first_date limit 1;
call make_intervals(@startperiod,@endperiod,1,'DAY');
select left(interval_start, 10) Date from time_intervals;
