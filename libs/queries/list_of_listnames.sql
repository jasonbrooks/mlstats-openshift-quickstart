select distinct(substring_index(TRIM(TRAILING '/' FROM mailing_list_url), '/', -1)) list_name, substring_index(substring_index(TRIM(TRAILING '/' FROM mailing_list_url), '.', -2), '/', 1) domain from messages
