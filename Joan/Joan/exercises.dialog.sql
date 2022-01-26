alter table dialog_show add column new_date date;
update dialog_show set new_date = str_to_date(daystamp,'%Y%m%d');

alter table dialog_event add column new_date date;
update dialog_event set new_date = str_to_date(daystamp,'%Y%m%d');

alter table dialog_close add column new_date date;
update dialog_close set new_date = str_to_date(daystamp,'%Y%m%d');

-- 1. Show all events in dialog_show with regulation_id '1'
select * from dialog_event
where regulation_id = 1;

-- 2. Show all events in dialog_show with regulation_id '1', from March 2020.
select * from dialog_show
where regulation_id = 1
	and year(new_date) = 2020
    and month(new_date) = 03;

-- 3. Count the number of events from March 2020 in dialog_show per regulation. -- "15651" 
select count(*) from dialog_show
where year(new_date) = 2020
    and month(new_date) = 03; 

-- 4. Show all unique events from dialog_event in March 2020 ordered alphabetically
select distinct(event) from dialog_event
where year(new_date) = 2020
    and month(new_date) = 03
order by event;

-- 5. Show top 10 locales from dialog_close with the most close counts in March 2020.

-- locale	most_close_counts
-- en_GB	4146
-- it_IT	936
-- fr_FR	578
-- nl_NL	569
-- en_US	471
-- de_DE	465
-- en_IE	194
-- de_CH	179
-- en_DE	137
-- de_AT	121

select locale, max(count) as most_close_counts from dialog_close
where year(new_date) = 2020
    and month(new_date) = 03
group by locale
order by most_close_counts desc
limit 10;

-- 6. Show bottom 10 locales from dialog_close where the summed close counts in March 2020 were at least 100 or more.
-- locale	most_close_counts
-- en_PL	101
-- sv_SE	108
-- nl_BE	111
-- es_ES	119
-- de_AT	121
-- en_DE	137
-- de_CH	179
-- en_IE	194
-- de_DE	465
-- en_US	471

select locale, max(count) as most_close_counts from dialog_close
where year(new_date) = 2020
    and month(new_date) = 03
group by locale
having most_close_counts >= 100
order by most_close_counts asc
limit 10;

-- 7. Show all events from dialog_event, but instead of app_id, regulation_id, origin_id,
-- flow_id and run_counter_id show the human readable names found in the corresponding tables.
select de.id, de.daystamp, de.event, de.count, a.name AS app, app_version, os_version, locale, r.name AS regulation, o.name AS origin, f.name AS flow, rc.name AS run_counter from dialog_event de
join app a on de.app_id = a.id
join regulation r on de.regulation_id = r.id
join origin o on de.origin_id = o.id
join flow f on de.flow_id = f.id
join run_counter rc on de.run_counter_id = rc.id;

-- 8. (Bonus) Show the summed counts per run_counter ordered from high to low, for all run_counters but 'old'. Combine 'firstRun', 'secondRun' and 'thirdRun' under one new
-- group called 'firstToThirdRunCount'. (Hint: Use case statement)