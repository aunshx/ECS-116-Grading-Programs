-- Claire Cichocki 921463771 ECS116 Problem Set 2
set search_path to food_sec;

delete from m49_codes_expanded;

select count(*) from m49_codes_expanded;

-- giving row of m49_codea_expanded for Angola

select *
from m49_codes_expanded
where country_or_area = 'Angola';

-- finding distinct sub_region names for Africa

select distinct sub_region_name
from m49_codes_expanded
where region_name = 'Africa'
order by sub_region_name;

-- finding distinct intermediate_region names for Africa

select distinct intermediate_region_name, country_or_area
from m49_codes_expanded 
where region_name = 'Africa'
order by intermediate_region_name, country_or_area;

-- finding countries in Africa with NULL intermediate_region names

select m49_code, country_or_area
from m49_codes_expanded
where region_name = 'Africa'
and intermediate_region_code isnull
order by country_or_area;
-- comes up empty

-- finding countries in Africa with '' intermediate_region names

select m49_code, country_or_area
from m49_codes_expanded
where region_name = 'Africa'
and intermediate_region_code = ''
order by country_or_area;
-- comes up with countries and bigger regions

-- exercise: finding only countreis in Africa with '' intermediate_region names

select m49_code, country_or_area
from m49_codes_expanded
where region_name = 'Africa'
and intermediate_region_code = ''
and entity_category = 'current country'
order by country_or_area;

-- following along with first try of getting the country, 
-- intermdediate_region, sub_region, and names and m49 codes
-- for each country in Africa

select a.area_code_m49, a.area, ir.intermediate_region_code,
	ir.intermediate_region_name, sr.sub_region_code, sr.sub_region_name
from africa_fs_ac a, m49_codes_expanded ir, m49_codes_expanded sr
where ir.m49_code = a.area_code_m49
and sr.m49_code = a.area_code_m49;

-- restricting to Angola

select a.area_code_m49, a.area, ir.intermediate_region_code,
	ir.intermediate_region_name, sr.sub_region_code, sr.sub_region_name
from africa_fs_ac a, m49_codes_expanded ir, m49_codes_expanded sr
where ir.m49_code = a.area_code_m49
and sr.m49_code = a.area_code_m49
and a.area_code_m49 = '024';
-- but getting so many

-- so checking how many?

select count(*)
from africa_fs_ac 
where area_code_m49 = '024';
-- 415

-- only want one for each, so trying distinct

select distinct a.area_code_m49, a.area, ir.intermediate_region_code,
	ir.intermediate_region_name, sr.sub_region_code, sr.sub_region_name
from africa_fs_ac a, m49_codes_expanded ir, m49_codes_expanded sr
where ir.m49_code = a.area_code_m49
and sr.m49_code = a.area_code_m49;
-- seeing that not all have an intermediate region


-- q1: now going for average GDP per capita for each african country

-- using the hint of finding GDP values

select *
from africa_fs_ac afa 
where item LIKE('%Gross%');
-- can see the item code of 22013

-- average GDP per capita rounded to 2 digits

select area_code_m49, area,  round(avg(value)::numeric, 2) as avg_gdp
from africa_fs_ac a
where item_code = '22013'
group by area_code_m49, area
order by area;

-- q2: now going for average GDP per capita for each african intermediate region

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

-- q3: now going for average GDP per capita for each african sub region

select m.sub_region_code,
       m.sub_region_name,
       round(avg(value)::numeric, 0) as avg_gdp
from africa_fs_ac a, m49_codes_expanded m 
where m.m49_code = a.area_code_m49 
  and item_code = '22013'
  and m.sub_region_code != ''
group by m.sub_region_code,
         m.sub_region_name
order by m.sub_region_name;
-- seeing only two subregions: 015, 202

-- trying for avg gdp, max gdp, and min gdp for each intermediate
-- region in Africa

select m.intermediate_region_code,
       m.intermediate_region_name,
       round(avg(value)::numeric, 0) as avg_gdp,
       round(max(value)::numeric, 0) as max_gdp,
       round(min(value)::numeric, 0) as min_gdp
from africa_fs_ac a, m49_codes_expanded m 
where m.m49_code = a.area_code_m49 
  and item_code = '22013'
  and m.intermediate_region_code != ''
group by m.intermediate_region_code,
         m.intermediate_region_name
order by m.intermediate_region_name;

-- trying for same thing but just 2011-2020

select m.intermediate_region_code,
       m.intermediate_region_name,
       round(avg(value)::numeric, 0) as avg_gdp,
       round(max(value)::numeric, 0) as max_gdp,
       round(min(value)::numeric, 0) as min_gdp
from africa_fs_ac a, m49_codes_expanded m 
where m.m49_code = a.area_code_m49 
  and item_code = '22013'
  and m.intermediate_region_code != ''
  and a.year_code >= '2011' 
  and a.year_code <= '2020'
group by m.intermediate_region_code,
         m.intermediate_region_name
order by m.intermediate_region_name;

-- now trying for min and max gdp but only showing coutries
-- where avg gdp is <= 4000

select m.intermediate_region_code,
       m.intermediate_region_name,
       round(max(value)::numeric, 0) as max_gdp,
       round(min(value)::numeric, 0) as min_gdp
from africa_fs_ac a, m49_codes_expanded m 
where m.m49_code = a.area_code_m49 
  and item_code = '22013'
  and m.intermediate_region_code != ''
group by m.intermediate_region_code,
         m.intermediate_region_name
having round(avg(value)::numeric, 0) >= '4000'
order by m.intermediate_region_name;
