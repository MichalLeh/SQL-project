create table t_michal_lehuta_projekt_SQL_final as
select ctr.country, ctr.population_density, ctr.median_age_2018, ec.GDP_per_head, ec2.mortaliy_under5, ec3.gini, 
# life_exp_diff - rozdíl mezi oèekávanou dobou dožití v roce 1965 a v roce 2015
(le.life_exp2015-le2.life_exp1965) as life_exp_diff, 
# religion_ratio - podíl jednotlivých náboženství na celkovém obyvatelstvu
rel.religion, round(rel.population/rel2.total_population*100, 2) as religion_ratio, 
w1.city, w1.date, w2.binary_day, w2.season_code, w2.daily_avg_temp, w3.count_zero_rain, w4.max_day_wind
from 
(select  country, population_density, median_age_2018, capital_city from countries) ctr 
left join
# GDP_per_head - HDP na obyvatele
(select country, max(year) as max_year, round(GDP/population, 2) as GDP_per_head from economies where GDP != 'Null' group by country) ec 
on ctr.country = ec.country
left join 
# dìtská úmrtnost
(select country, mortaliy_under5, max(year) from economies e2 where mortaliy_under5 != 'Null' group by country) ec2
on ctr.country = ec2.country
left join 
# Gini koeficient
(select country, gini, max(year) as max_year_2 from economies where gini != 'Null' group by country) ec3
on ctr.country = ec3.country
left join 
(select country, life_expectancy as life_exp2015 from life_expectancy where year = 2015) le
on ctr.country = le.country 
 left join 
(select country, life_expectancy as life_exp1965 from life_expectancy where year = 1965) le2 
on le.country = le2.country
left join 
(select country, religion, population from religions where year = 2020) rel 
on ctr.country = rel.country
left join 
(select country, sum(population) as total_population from religions where year = 2020 group by country) rel2 
on rel.country = rel2.country
left join
(select city, date from weather group by city, date) w1
on w1.city = ctr.capital_city
left join 
(select city, date,
# binární promìnná pro víkend = 1, pracovní den = 0
case when dayname(date) in ('Sunday', 'Saturday') then 1 else 0 end as binary_day, 
# roèní období daného dne jaro = 0, léto = 1, podzim = 2, zima = 3
case when month(date) in (12, 1, 2) then 3
     when month(date) in (3, 4, 5) then 0
     when month(date) in (6, 7, 8) then 1 else 2 end as season_code,
# daily_avg_temp - prùmìrná denní teplota byla poèítána jako prùmìr teplot mezi 6 - 18 hodinou 
avg(temp) as daily_avg_temp from weather where hour in (6, 9, 12, 15, 18) group by date, city) w2
on w1.date = w2.date and w1.city = w2.city
left join
# count_zero_rain - poèet hodin v daném dni, kdy byly srážky nenulové
(select city, date, count(rain) as count_zero_rain from weather where rain != 0 group by city, date) w3 
on w1.date = w3.date and w1.city = w3.city
left join
# max_day_wind - maximální síla vìtru v nárazech bìhem dne
(select city, date, max(wind) as max_day_wind from weather group by city, date) w4 
on w2.date = w4.date and w1.city = w4.city
