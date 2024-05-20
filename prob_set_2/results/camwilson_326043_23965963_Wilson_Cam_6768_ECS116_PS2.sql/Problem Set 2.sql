set search_path to food_sec;

-- to the following to empty everything out of m49_codes_expanded
delete from m49_codes_expanded;

-- sanity check ... is the table empty?
select count(*) from m49_codes_expanded;

select *
from m49_codes_expanded
where country_or_area = 'Angola';

-- the two queries are: find distinct sub-region names associated with
--    countries in Africa, and same thing for intermediate-region names
select distinct sub_region_name 
from m49_codes_expanded
where region_name = 'Africa'
order by sub_region_name;

select distinct intermediate_region_name, country_or_area
from m49_codes_expanded
where region_name = 'Africa'
order by intermediate_region_name , country_or_area;

-- Here's a query that finds all countries in Africa for which the
--    sub_region name is NULL

select m49_code, country_or_area 
from m49_codes_expanded 
where region_name = 'Africa' and intermediate_region_code ISNULL
order by country_or_area;

select m49_code , country_or_area 
from m49_codes_expanded 
where region_name = 'Africa' and intermediate_region_code = ''
order by country_or_area;

-- Hmm, this includes not only countries, but also bigger regions
-- Exercise for you: how to list only the countries that have
--    empty string for intermediate_region_code or name

select m49_code, country_or_area
from m49_codes_expanded
where intermediate_region_code = '' or intermediate_region_name = ''

-- Here is a query that lists, for each country in Africa,
--    the country, the intermediate_region and the sub_region,
--    including both names and m49 codes for the countries/regions

-- first try:
select a.area_code_m49, a.area,
       ir.intermediate_region_code, ir.intermediate_region_name,
       sr.sub_region_code, sr.sub_region_name 
from africa_fs_after_cleaning_db a, m49_codes_expanded ir, m49_codes_expanded sr
where ir.m49_code = a.area_code_m49 and sr.m49_code = a.area_code_m49;
 
-- restrict Angola
select a.area_code_m49, a.area,
       ir.intermediate_region_code, ir.intermediate_region_name,
       sr.sub_region_code, sr.sub_region_name 
from africa_fs_after_cleaning_db a, m49_codes_expanded ir, m49_codes_expanded sr
where ir.m49_code = a.area_code_m49 and sr.m49_code = a.area_code_m49 and a.area_code_m49 = '024';

-- final
select distinct a.area_code_m49, a.area,
       ir.intermediate_region_code, ir.intermediate_region_name,
       sr.sub_region_code, sr.sub_region_name 
from africa_fs_after_cleaning_db a, m49_codes_expanded ir, m49_codes_expanded sr
where ir.m49_code = a.area_code_m49 and sr.m49_code = a.area_code_m49;

select *
from africa_fs_after_cleaning_db a
where item LIKE('%Gross%');

select area_code_m49, area, avg(value)
from africa_fs_after_cleaning_db a
where item_code = '22013'
group by area_code_m49, area
order by area;

select area_code_m49, area, round(avg(value)::numeric, 2) as avg_gdp
from africa_fs_after_cleaning_db a
where item_code = '22013'
group by area_code_m49, area
order by area;

select area_code_m49, area, to_char(avg(value), 'FM999999999.00') as avg_gdp
from africa_fs_after_cleaning_db a
where item_code = '22013'
group by area_code_m49, area
order by area;

select m.intermediate_region_code,
       m.intermediate_region_name,
       round(avg(value)::numeric, 0) as avg_gdp
from africa_fs_after_cleaning_db a, m49_codes_expanded m 
where m.m49_code = a.area_code_m49 
  and item_code = '22013'
  and m.intermediate_region_code != ''
group by m.intermediate_region_code,
         m.intermediate_region_name
order by m.intermediate_region_name;

-- create a query for Q3 mentioned above
select m.sub_region_code,
       m.sub_region_name,
       round(avg(a.value)::numeric, 0) as avg_gdp
from africa_fs_after_cleaning_db a
join m49_codes_expanded m on m.m49_code = a.area_code_m49 
where a.item_code = '22013' and m.sub_region_code != ''
group by m.sub_region_code,
         m.sub_region_name
order by m.sub_region_name;

-- create a query that gives the avg gdp, the max gdp, and the min gdp
--    over the years
--    for each intermeidate region in AFrica
--    and not including countries where intermediate region is empty
select m.intermediate_region_code,
       m.intermediate_region_name,
       round(avg(a.value)::numeric, 0) as avg_gdp,
       max(a.value) as max_gdp,
       min(a.value) as min_gdp
from africa_fs_after_cleaning_db a
join m49_codes_expanded m ON m.m49_code = a.area_code_m49 
where a.item_code = '22013'
  and m.intermediate_region_code != ''
group by m.intermediate_region_code,
         m.intermediate_region_name
order by m.intermediate_region_name;

-- create a query that gives the avg, max and min gdp
--    for each intermediate region in Africa,
--    but just for 2011 to 2020
--    (and not including countries where intermediate region is empty)
select m.intermediate_region_code,
       m.intermediate_region_name,
       round(avg(case when a."year" between '2011' and '2020' then a.value else null end)::numeric, 0) as avg_gdp,
       max(case when a."year" between '2011' and '2020' then a.value else null end) as max_gdp,
       min(case when a."year" between '2011' and '2020' then a.value else null end) as min_gdp
from africa_fs_after_cleaning_db a
join m49_codes_expanded m on m.m49_code = a.area_code_m49 
where a.item_code = '22013'
  and m.intermediate_region_code != ''
group by m.intermediate_region_code,
         m.intermediate_region_name
order by m.intermediate_region_name;


-- create a query that gives min and max gdp
--    for each intermediate region in Africa
--    (going across all years)
--    but show only countries where the avg gdp is <= $4000
--    (and not including countries where intermediate region is empty)
select m.intermediate_region_code,
       m.intermediate_region_name,
       max(a.value) as max_gdp,
       min(a.value) as min_gdp
from africa_fs_after_cleaning_db a
join m49_codes_expanded m on m.m49_code = a.area_code_m49 
where a.item_code = '22013'
  and m.intermediate_region_code != ''
group by m.intermediate_region_code,
         m.intermediate_region_name
having avg(a.value) <= 4000
order by m.intermediate_region_name;








