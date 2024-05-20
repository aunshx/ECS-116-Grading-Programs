set search_path to food_sec;

 -- to the following to empty everything out of m49_codes_expanded
delete from m49_codes_expanded;

-- sanity check ... is the table empty?
select count(*) from m49_codes_expanded;

-- now import the file m49_codes_expanded.csv directly into the table m49_codes_expanded
-- check that the data looks like the data in the csv file
-- also, as a sanity check, does the count of tuples in your table match the count in the csv file?
-- now let's look at one record in m49_codes_expanded, kind of closely
-- specifically: create a query that gives the row of m49_codes_expanded for the country "Angola"

select *  from m49_codes_expanded 
where country_or_area = 'Angola';

-- so: Angola is in intermediate_region "Middle Africa" sub_region  "Sub-Saharan Africa" region  "Africa"
-- before we go on, let's see the values for itermediate_region and sub_region that are associated with countries in Africa (recall that "Africa" shows up in the region_name column)
-- the two queries are: find distinct sub-region names associated with countries in Africa, and same thing for intermediate-region names

select distinct sub_region_name from m49_codes_expanded mce 
where region_name = 'Africa'
order by sub_region_name ;

select distinct intermediate_region_name, country_or_area from m49_codes_expanded mce 
where region_name = 'Africa'
order by intermediate_region_name , country_or_area;

-- Why are there null values in the answers to both of these queries?
-- Here's a query that finds all countries in Africa for which the sub_region name is NULL

select m49_code , country_or_area from m49_codes_expanded 
where region_name = 'Africa' and intermediate_region_code ISNULL
order by country_or_area;

-- hmm - why is this coming up empty? the empty values are not NULL, they are ''(empty string) so the query I wanted is

select m49_code , country_or_area 
from m49_codes_expanded 
where region_name = 'Africa'
  and intermediate_region_code = ''
order by country_or_area;

-- Hmm, this includes not only countries, but also bigger regions
-- Exercise for you: how to list only the countries that have empty string for intermediate_region_code or name
select country_or_area from m49_codes_expanded
where intermediate_region_code ='' or intermediate_region_name ='';

-- Here is a query that lists, for each country in Africa, the country, the intermediate_region and the sub_region, including both names and m49 codes for the countries/regions

select a.area_code_m49, a.area,
       ir.intermediate_region_code, ir.intermediate_region_name,
       sr.sub_region_code, sr.sub_region_name 
from africa_fs_ac a, m49_codes_expanded ir, m49_codes_expanded sr
where ir.m49_code = a.area_code_m49
  and sr.m49_code = a.area_code_m49;
  
 -- hmm, I am getting 21,688 answers, when I was expecting only 54 answers what is going wrong?
-- Let's restrict the query to just Angola to see if that tells us anything
select a.area_code_m49, a.area,
       ir.intermediate_region_code, ir.intermediate_region_name,
       sr.sub_region_code, sr.sub_region_name 
from africa_fs_ac a, m49_codes_expanded ir, m49_codes_expanded sr
where ir.m49_code = a.area_code_m49
  and sr.m49_code = a.area_code_m49 
  and a.area_code_m49 = '024';
   
-- WAIT -- when I think of the cross product of africa_fs_ac X m49_codes_expanded X m49_codes_expanded how many records in africa_fs_ac have area_code_m49 = '024' (Angola)?
  
select count(*)
from africa_fs_ac 
where area_code_m49 = '024';

-- 415 of them
-- But I only want one record for each country, not 400+ for each country
-- We can use the DISTINCT on the whole query, as follows

select distinct a.area_code_m49, a.area,
       ir.intermediate_region_code, ir.intermediate_region_name,
       sr.sub_region_code, sr.sub_region_name 
from africa_fs_ac a, m49_codes_expanded ir, m49_codes_expanded sr
where ir.m49_code = a.area_code_m49
  and sr.m49_code = a.area_code_m49;

-- Now, I want to practice doing some aggregation (group-by) queries that use groupings by sub- and intermediate-regions
-- For example, consider these 3 queries;
-- Q1: find the average GDP per capita for each african country (going over all years)
-- Q2: find the average GDP per capita for each african intermediate region
-- Q3: find the average GDP per capita for each african sub region (ignore countries that do not fall into one of the sub regions)
  
-- Q1:
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

-- now, how about Q2, getting avg gdp grouped by intermediate region
  
select m.intermediate_region_code,
       m.intermediate_region_name,
       round(avg(value)::numeric, 0) as avg_gdp
from africa_fs_ac a, m49_codes_expanded m 
where m.m49_code = a.area_code_m49 
  and item_code = '22013'
group by m.intermediate_region_code,
         m.intermediate_region_name
order by m.intermediate_region_name;

-- Exercises for you:
-- create a query for Q3 mentioned above:
SELECT 
  sr.sub_region_code,
  sr.sub_region_name,
  ROUND(AVG(a.value)::NUMERIC, 2) AS avg_gdp_per_capita
FROM 
  africa_fs_ac a
JOIN 
  m49_codes_expanded m ON a.area_code_m49 = m.m49_code
JOIN 
  m49_codes_expanded sr ON m.sub_region_code = sr.sub_region_code
WHERE 
  a.item_code = '22013' -- Assuming '22013' is the code for GDP per capita
  AND m.region_name = 'Africa'
  AND m.sub_region_name IS NOT NULL AND m.sub_region_name != ''
GROUP BY 
  sr.sub_region_code, sr.sub_region_name
ORDER BY 
  sr.sub_region_name;
 
-- create a query that gives the avg gdp, the max gdp, and the min gdp over the years for each intermeidate region in AFrica
SELECT 
  ir.intermediate_region_code,
  ir.intermediate_region_name,
  ROUND(AVG(a.value)::NUMERIC, 2) AS avg_gdp_per_capita,
  MAX(a.value) AS max_gdp_per_capita,
  MIN(a.value) AS min_gdp_per_capita
FROM 
  africa_fs_ac a
JOIN 
  m49_codes_expanded m ON a.area_code_m49 = m.m49_code
JOIN 
  m49_codes_expanded ir ON m.intermediate_region_code = ir.intermediate_region_code
WHERE 
  a.item_code = '22013' -- Assuming '22013' is the code for GDP per capita
  AND m.region_name = 'Africa'
  AND m.intermediate_region_name IS NOT NULL AND m.intermediate_region_name != ''
GROUP BY 
  ir.intermediate_region_code, ir.intermediate_region_name
ORDER BY 
  ir.intermediate_region_name;
 
-- create a query that gives the avg, max and min gdp for each intermediate region in Africa, but just for 2011 to 2020
SELECT 
  ir.intermediate_region_code,
  ir.intermediate_region_name,
  ROUND(AVG(a.value)::NUMERIC, 2) AS avg_gdp_per_capita,
  MAX(a.value) AS max_gdp_per_capita,
  MIN(a.value) AS min_gdp_per_capita
FROM 
  africa_fs_ac a
JOIN 
  m49_codes_expanded m ON a.area_code_m49 = m.m49_code
JOIN 
  m49_codes_expanded ir ON m.intermediate_region_code = ir.intermediate_region_code
WHERE 
  a.item_code = '22013' -- Assuming '22013' is the code for GDP per capita
  AND m.region_name = 'Africa'
  AND m.intermediate_region_name IS NOT NULL AND m.intermediate_region_name != ''
  AND CAST(a.year AS INTEGER) BETWEEN 2011 AND 2020
GROUP BY 
  ir.intermediate_region_code, ir.intermediate_region_name
ORDER BY 
  ir.intermediate_region_name;

 
-- create a query that gives min and max gdp for each intermediate region in Africa (going across all years) but show only countries where the avg gdp is <= $4000
-- Query to find the min and max GDP per capita for each intermediate region in Africa,
-- showing only countries where the average GDP is <= $4000
SELECT 
  ir.intermediate_region_code,
  ir.intermediate_region_name,
  MIN(a.value) AS min_gdp_per_capita,
  MAX(a.value) AS max_gdp_per_capita
FROM 
  africa_fs_ac a
JOIN 
  m49_codes_expanded m ON a.area_code_m49 = m.m49_code
JOIN 
  m49_codes_expanded ir ON m.intermediate_region_code = ir.intermediate_region_code
WHERE 
  a.item_code = '22013' -- Assuming '22013' is the code for GDP per capita
  AND m.region_name = 'Africa'
  AND m.intermediate_region_name IS NOT NULL AND m.intermediate_region_name != ''
  AND a.area_code_m49 IN (
    SELECT area_code_m49
    FROM africa_fs_ac
    WHERE item_code = '22013'
    GROUP BY area_code_m49
    HAVING AVG(value) <= 4000
  )
GROUP BY 
  ir.intermediate_region_code, ir.intermediate_region_name
ORDER BY 
  ir.intermediate_region_name;

  

