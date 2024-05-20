set search_path to food_sec;

--first chunk of exercises
delete from m49_codes_expanded;

select count(*) from m49_codes_expanded;

--specific query
select * from m49_codes_expanded 
where country_or_area = 'Angola';

select distinct sub_region_name from m49_codes_expanded
where region_name = 'Africa'
order by sub_region_name;

select distinct intermediate_region_name, country_or_area from m49_codes_expanded 
where region_name = 'Africa'
order by intermediate_region_name , country_or_area;

select m49_code , country_or_area from m49_codes_expanded 
where region_name = 'Africa'
  and intermediate_region_code = ''
order by country_or_area;

-- Exercise for you: how to list only the countries that have
--    empty string for intermediate_region_code or name

select distinct intermediate_region_name, country_or_area from m49_codes_expanded 
where region_name = 'Africa' and intermediate_region_name = '' or intermediate_region_code = '';

select distinct a.area_code_m49, a.area,
       inter.intermediate_region_code, inter.intermediate_region_name,
       sub.sub_region_code, sub.sub_region_name 
from africa_fs_ac a, m49_codes_expanded inter, m49_codes_expanded sub
where inter.m49_code = a.area_code_m49
  and sub.m49_code = a.area_code_m49;
 
select distinct a.area_code_m49, a.area,
                inter.intermediate_region_code, inter.intermediate_region_name,
                sub.sub_region_code, sub.sub_region_name 
from africa_fs_ac a, m49_codes_expanded inter, m49_codes_expanded sub
where cast(inter.m49_code as integer) = cast(a.area_code_m49 as integer)
  and cast(sub.m49_code as integer) = cast(a.area_code_m49 as integer);
  
select * from africa_fs_ac
where item LIKE('%Gross%');

select area_code_m49, area, round(avg(value)::numeric, 2) as avg_gdp
from africa_fs_ac a
where item_code = '22013'
group by area_code_m49, area
order by area;

select area_code_m49, area, to_char(avg(value), 'FM999999999.00') as avg_gdp
from africa_fs_ac a
where item_code = '22013'
group by area_code_m49, area
order by area;

select m.intermediate_region_code,
       m.intermediate_region_name,
       round(avg(value)::numeric, 0) as avg_gdp
from africa_fs_ac a
join m49_codes_expanded m on m.m49_code::integer = a.area_code_m49
where item_code = '22013'
group by m.intermediate_region_code, m.intermediate_region_name
order by m.intermediate_region_name;

-- Q3: find the average GDP per capita for each african sub region
--       (ignore countries that do not fall into one of the sub regions)

select m.sub_region_code,
       m.sub_region_name,
       round(avg(value)::numeric, 0) as avg_gdp
from africa_fs_ac a
join m49_codes_expanded m on m.m49_code::integer = a.area_code_m49
group by m.sub_region_code, m.sub_region_name
order by m.sub_region_name;

-- create a query that gives the avg gdp, the max gdp, and the min gdp
--    over the years
--    for each intermeidate region in AFrica
select 
    m.intermediate_region_code,
    m.intermediate_region_name,
    a.year,
    round(avg(a.value)::numeric, 0) as avg_gdp,
    round(max(a.value)::numeric, 0) as max_gdp,
    round(min(a.value)::numeric, 0) as min_gdp
from africa_fs_ac a
join m49_codes_expanded m on m.m49_code::integer = a.area_code_m49
where a.item_code = '22013' and intermediate_region_name != ''
group by 
    m.intermediate_region_code,
    m.intermediate_region_name,
    a.year
order by m.intermediate_region_name, a.year;

-- create a query that gives the avg, max and min gdp
--    for each intermediate region in Africa,
--    but just for 2011 to 2020

select 
    m.intermediate_region_code,
    m.intermediate_region_name,
    round(avg(a.value)::numeric, 0) as avg_gdp,
    round(max(a.value)::numeric, 0) as max_gdp,
    round(min(a.value)::numeric, 0) as min_gdp
from africa_fs_ac a
join m49_codes_expanded m on m.m49_code::integer = a.area_code_m49
where a.item_code = '22013' and cast(a.year as integer) between 2011 and 2020
group by m.intermediate_region_code, m.intermediate_region_name
order by m.intermediate_region_name;

-- create a query that gives min and max gdp
--    for each intermediate region in Africa
--    (going across all years)
--    but show only countries where the avg gdp is <= $4000

select 
    m.intermediate_region_code,
    m.intermediate_region_name,
    min(a.value) as min_gdp,
    max(a.value) as max_gdp
from africa_fs_ac a
join m49_codes_expanded m on m.m49_code::integer = a.area_code_m49
where a.item_code = '22013'
group by m.intermediate_region_code,
    m.intermediate_region_name
having avg(a.value) <= 4000
order by m.intermediate_region_name;

