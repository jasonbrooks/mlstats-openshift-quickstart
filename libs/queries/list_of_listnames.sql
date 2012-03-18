select distinct(substring_index(TRIM(TRAILING '/' FROM mailing_list_url), '/', -1))  from messages
