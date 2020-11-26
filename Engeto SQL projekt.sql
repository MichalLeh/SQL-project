# FINAL TABLE
Create or replace table t_michal_lehuta_projekt_SQL_final as
select ctr.*, cov.date, cov.confirmed, cov.tests_performed, 
rel.Christianity, rel.Islam, rel.Unaffiliated_religions, rel.Hinduism, rel.Buddhism, rel.Folk_religions, rel.Other_religions, rel.Judaism,
wet.city, wet.binary_day, wet.season_code, wet.daily_avg_temp, wet.count_zero_rain, wet.max_day_wind
FROM 
(select * from t_michal_lehuta_SQLprojekt_Countries) ctr
join
(select * from t_michal_lehuta_SQLprojekt_Religions) rel
on ctr.country = rel.country
join 
(select * from t_michal_lehuta_SQLprojekt_Covid19) cov 
on ctr.country = cov.country
join 
(select * from t_michal_lehuta_SQLprojekt_Weather) wet 
on cov.date = wet.date and ctr.capital_city = wet.city

# COUNTRIES TABLE
Create or replace table t_michal_lehuta_SQLprojekt_Countries as
select ctr.country, ec.population, ec.GDP_per_head, ctr.population_density, ctr.median_age_2018, ec2.mortaliy_under5, ec3.gini, ctr.capital_city,
# life_exp_diff - rozdíl mezi očekávanou dobou dožití v roce 1965 a v roce 2015
(le.life_exp2015-le2.life_exp1965) as life_exp_diff
from 
(select country, population_density, median_age_2018, capital_city from countries) ctr 
join
# GDP_per_head - HDP na obyvatele; inner join nezahrnuje pouze stát Sýrii
(select country, population, round(GDP/population, 2) as GDP_per_head from economies where GDP is not Null group by country) ec 
on ctr.country = ec.country
join 
# dětská úmrtnost
(select country, mortaliy_under5, max(year) from economies e2 where mortaliy_under5 is not Null group by country) ec2
on ctr.country = ec2.country
left join 
# Gini koeficient; inner join vynechá státy jako: Afghanistan, New Zealand, Saudi Arabia, Cuba, Singapore, Libya atd... a zároveň nemají Null hodnotu v ostatních zkoumaných proměnných
(select country, gini, max(year) from economies where gini is not Null group by country) ec3
on ctr.country = ec3.country
# left join zahrnuje rovněž Russian Federation (144 mil. obyvatel)
left join 
(select country, life_expectancy as life_exp2015 from life_expectancy where year = 2015) le
on ctr.country = le.country 
join 
(select country, life_expectancy as life_exp1965 from life_expectancy where year = 1965) le2 
on le.country = le2.country order by ec3.gini desc

# RELIGION TABLE - podíl jednotlivých náboženství na celkovém obyvatelstvu
Create OR replace table t_michal_lehuta_SQLprojekt_Religions as
select rbase.country, rbase.population, 
round(rbase.Christianity/r1.total_population*100, 2) as Christianity, round(rbase.Islam/r1.total_population*100, 2) as Islam, round(rbase.Unaffiliated_religions/r1.total_population*100, 2) as Unaffiliated_religions,
round(rbase.Hinduism/r1.total_population*100, 2) as Hinduism, round(rbase.Buddhism/r1.total_population*100, 2) as Buddhism, round(rbase.Folk_religions/r1.total_population*100, 2) as Folk_religions,
round(rbase.Other_religions/r1.total_population*100, 2) as Other_religions, round(rbase.Judaism/r1.total_population*100, 2) as Judaism
from 
(select country, sum(population) as population, 
sum(case when religion = 'Christianity' then population else 0 end) as Christianity,
sum(case when religion = 'Islam' then population else 0 end) as Islam,
sum(case when religion = 'Unaffiliated Religions' then population else 0 end) as Unaffiliated_religions, 
sum(case when religion = 'Hinduism' then population else 0 end) as Hinduism, 
sum(case when religion = 'Buddhism' then population else 0 end) as Buddhism, 
sum(case when religion = 'Folk Religions' then population else 0 end) as Folk_religions,
sum(case when religion = 'Other Religions' then population else 0 end) as Other_religions,
sum(case when religion = 'Judaism' then population else 0 end) as Judaism
from religions r where year = 2020 and population != 0 group by country) rbase 
JOIN 
(select country, sum(population) as total_population from religions r2 where year = 2020 group by country) r1 
on rbase.country = r1.country 

# COVID TABLE
Create OR replace table t_michal_lehuta_SQLprojekt_Covid19 as
select cbd.date, cbd.country, cbd.confirmed, ct.tests_performed from 
(select date, country, confirmed from covid19_basic_differences group by date, country) cbd 
join
(select country, date, tests_performed from covid19_tests group by date, country) ct
on cbd.country = ct.country and cbd.date = ct.date 

# WEATHER TABLE
CREATE OR replace table t_michal_lehuta_SQLprojekt_Weather as
select w1.city, w1.date, w2.binary_day, w2.season_code, w2.daily_avg_temp, w3.count_zero_rain, w4.max_day_wind from 
(select city, date from weather group by city, date) w1
left join
(select city, date,
# binární proměnná pro víkend = 1, pracovní den = 0
case when dayname(date) in ('Sunday', 'Saturday') then 1 else 0 end as binary_day, 
# roční období daného dne jaro = 0, léto = 1, podzim = 2, zima = 3
case when month(date) in (12, 1, 2) then 3
     when month(date) in (3, 4, 5) then 0
     when month(date) in (6, 7, 8) then 1 else 2 end as season_code,
# daily_avg_temp - průměrná denní teplota byla počítána jako průměr teplot mezi 6 - 18 hodinou 
avg(temp) as daily_avg_temp from weather where hour in (6, 9, 12, 15, 18) group by date, city) w2
on w1.date = w2.date and w1.city = w2.city
left join
# count_zero_rain - počet hodin v daném dni, kdy byly srážky nenulové
(select city, date, count(rain) as count_zero_rain from weather where rain != 0 group by city, date) w3 
on w1.date = w3.date and w1.city = w3.city
left join
# max_day_wind - maximální síla větru v nárazech během dne
(select city, date, max(wind) as max_day_wind from weather group by city, date) w4 
on w2.date = w4.date and w1.city = w4.city
