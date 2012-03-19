select substring_index(email_address, '@', -1) domain, count(substring_index(email_address, '@', -1)) count from mailing_lists_people group by domain order by count desc limit 10
