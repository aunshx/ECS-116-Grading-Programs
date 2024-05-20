set search_path to food_sec;
show search_path;

delete from m49_codes_expanded;
select count(*) from m49_codes_expanded;

select *
from m49_codes_expanded mce
where country_or_area = 'Angola';

select distinct sub_region_name
from m49_codes_expanded mce
where region_name = 'Africa'
order by sub_region_name;

select distinct intermediate_region_name, country_or_area
from m49_codes_expanded mce
where region_name = 'Africa'
order by intermediate_region_name , country_or_area;
select m49_code , country_or_area
from m49_codes_expanded
where region_name = 'Africa'
and intermediate_region_code ISNULL
order by country_or_area;

-- HERE
select ir.m49_code as africa_m49_code, ir.country_or_area as africa_country_or_area,
a.area_code_m49, a.area,
ir.m49_code as intermediate_region_m49_code, ir.intermediate_region_name,
sr.m49_code as sub_region_m49_code, sr.sub_region_name
from africa_fs_ac a, m49_codes_expanded ir, m49_codes_expanded sr
where ir.m49_code = a.area_code_m49
and sr.m49_code = a.area_code_m49;

select a.area_code_m49, a.area,
ir.intermediate_region_code, ir.intermediate_region_name,
sr.sub_region_code, sr.sub_region_name
from africa_fs_ac a, m49_codes_expanded ir, m49_codes_expanded sr
where ir.m49_code = a.area_code_m49
and sr.m49_code = a.area_code_m49
and a.area_code_m49 = '024';

select count(*)
from africa_fs_ac
where area_code_m49 = '024';

select distinct a.area_code_m49, a.area,
ir.intermediate_region_code, ir.intermediate_region_name,
sr.sub_region_code, sr.sub_region_name
from africa_fs_ac a, m49_codes_expanded ir, m49_codes_expanded sr
where ir.m49_code = a.area_code_m49
and sr.m49_code = a.area_code_m49;

select *
from africa_fs_ac afa
where item LIKE('%Gross%');

select area_code_m49, area, avg(value)
from africa_fs_ac a
where item_code = '22013'
group by area_code_m49, area
order by area;

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
from africa_fs_ac a, m49_codes_expanded m
where m.m49_code = a.area_code_m49
and item_code = '22013'
and m.intermediate_region_code != ''
group by m.intermediate_region_code,
m.intermediate_region_name
order by m.intermediate_region_name;

-- Q3. create a query that finds the average GDP per capita for each african sub region (ignore countries that do not fall into one of the sub regions)
select m.sub_region_name, round(avg(a.value)::numeric, 2) as avg_gdp_per_capita
from africa_fs_ac a
join m49_codes_expanded m on m.m49_code = a.area_code_m49
where a.item_code = '22013' and m.sub_region_name is not null
group by m.sub_region_name
order by m.sub_region_name;

-- Q4. create a query that gives the avg gdp, the max gdp, and the min gdp over the years, for each intermediate region in Africa, and not including countries where intermediate region is empty
select m.intermediate_region_name, round(avg(a.value)::numeric, 2) as avg_gdp, max(a.value) as max_gdp, min(a.value) as min_gdp
from africa_fs_ac a
join m49_codes_expanded m on m.m49_code = a.area_code_m49
where a.item_code = '22013' and m.intermediate_region_name != ''
group by m.intermediate_region_name
order by m.intermediate_region_name;

-- Q5. create a query that gives the avg, max and min gdp, for each intermediate region in Africa, but just for 2011 to 2020 (and not including countries where intermediate region is empty)
select m.intermediate_region_name, round(avg(a.value)::numeric, 2) as avg_gdp, max(a.value) as max_gdp, min(a.value) as min_gdp
from africa_fs_ac a
join m49_codes_expanded m on m.m49_code = a.area_code_m49
where a.item_code = '22013' and m.intermediate_region_name != '' and cast(a.year as integer) between 2011 and 2020
group by m.intermediate_region_name
order by m.intermediate_region_name;

-- Q6. create a query that gives min and max gdp, for each intermediate region in Africa (going across all years), but show only countries where the avg gdp is <= $4000 (and not including countries where intermediate region is empty)
select m.intermediate_region_name, max(a.value) as max_gdp, min(a.value) as min_gdp
from africa_fs_ac a
join m49_codes_expanded m on m.m49_code = a.area_code_m49
where a.item_code = '22013' and m.intermediate_region_name != ''
group by m.intermediate_region_name
having avg(a.value) <= 4000
order by m.intermediate_region_name;