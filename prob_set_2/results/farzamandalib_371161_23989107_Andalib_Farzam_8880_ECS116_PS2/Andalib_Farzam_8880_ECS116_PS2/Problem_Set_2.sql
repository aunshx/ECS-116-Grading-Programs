set search_path to food_sec
show search_path

select count(*) from m49_codes_expanded mce -- before delete, sanity check, there is 299 records.  
delete  from m49_codes_expanded mce ;

--sanity check 
select count(*) from m49_codes_expanded mce ;

--I checked, it's zero. so it is empty.  

-- Now import the data again. 
-- sanity check again. 
select count(*) from m49_codes_expanded mce ;  

--When I did the sainty check, before delete and after deltet mathched the tuples. 



select from m49_codes_expanded mce 
where country_or_area = 'Angola'

select  distinct sub_region_name from m49_codes_expanded mce 
where region_name = 'Africa'
order by sub_region_name 

select distinct intermediate_region_name, country_or_area
from m49_codes_expanded mce 
where region_name = 'Africa'
order by intermediate_region_name , country_or_area 

-- it shows null in the query that I run it. it shows null value in the output, I gusee there is some NA vuale in the our table. 
 

-- Here is the query that finds finds all countries in Africa wich the sub_region name is null.

select m49_code, country_or_area
from m49_codes_expanded mce 
where region_name = 'Africa' and intermediate_region_name isnull 
order by country_or_area ;
-- the out put is empty because there are empty string. we will fix in the next query. 




-- the actual query is the followig: 
select m49_code, country_or_area
from m49_codes_expanded mce 
where region_name = 'Africa'
and intermediate_region_code = ''
order by country_or_area  -- Now we don't have any empty or null in the query.


-- how to list only the countries that have empty string for intermediate_region_code or name 
-- first try:
select a.area_code_m49, a.area, 
ir.intermediate_region_code, ir.intermediate_region_name, sr.sub_region_code, sr.sub_region_name
from africa_fs_ac a, m49_codes_expanded ir, m49_codes_expanded sr
where ir.m49_code= a.area_code_m49 
and sr.m49_code = a.area_code_m49 ;



select count(*) from  africa_fs_ac afa  -- the output shows 21688 tuples. 



-- we are looking to have 54 answers. 
-- We restrict the query to just Angola to see if tells us anything. 
select a.area_code_m49, a.area, 
ir.intermediate_region_code, ir.intermediate_region_name, 
sr.sub_region_code, sr.sub_region_name
from africa_fs_ac a, m49_codes_expanded ir, m49_codes_expanded sr
where ir.m49_code= a.area_code_m49 
and sr.m49_code = a.area_code_m49 
and a.area_code_m49 = '024'


 -- why are there many Angola records? 
-- Becuae of the cross product  africa_fs_ac x m49_codes_expended x m49_codes_expended. 
-- Now we are going to check the area_code_m49 ='024'
-- check how many rows are there? 

select count(*)
from africa_fs_ac afa 
where area_code_m49 = '024'
-- the output shows 415 records but we want one record for eacy country. 


-- Now we have to use the distinct. 
select distinct a.area_code_m49, a.area, 
ir.intermediate_region_code, ir.intermediate_region_name, 
sr.sub_region_code, sr.sub_region_name
from africa_fs_ac a, m49_codes_expanded ir, m49_codes_expanded sr
where ir.m49_code= a.area_code_m49 and sr.m49_code = a.area_code_m49 





-- Now, I want to practice doing some aggregation (group-by) queries
-- that use groupings by sub- and intermediate-region

-- need to find the the value for GDP per capita. 
select * from africa_fs_ac afa 
where item like ('%Gross%')


-- Now we have found the item code wich is 22013
select area_code_m49, area, avg(value)
from africa_fs_ac afa 
where item_code = '22013'
group by area_code_m49 , area 
order by area; 



-- round the avarage 2 decimals; 
select area_code_m49, area, round(avg(value)::numeric, 2) as avg_gdp
from africa_fs_ac afa 
where item_code = '22013'
group by area_code_m49 , area
order by area; 


-- some beautiful out put in two decimals: 
select area_code_m49, area, to_char(avg(value), 'FM999999999.00' ) as avg_gdp
from africa_fs_ac afa 
where item_code = '22013'
group by area_code_m49 , area
order by area; 



-- find the gdp grouped by intermediate region; 
select m.intermediate_region_code, m.intermediate_region_name, round(avg(value)::numeric, 2) as avg_gdp
from africa_fs_ac a, m49_codes_expanded m
where m.m49_code = a.area_code_m49
and item_code = '22013'
group by m.intermediate_region_code , m.intermediate_region_name 
order by m.intermediate_region_name 




--find the avarage gdp per capita for each sub region: 
select m.sub_region_code, m.sub_region_name, round(avg(value)::numeric, 2) as avg_gdp
from africa_fs_ac a, m49_codes_expanded m
where m.m49_code = a.area_code_m49 
and item_code = '22013'
group by m.sub_region_code, m.sub_region_name 
order by m.sub_region_name ;



-- create query gives the avg, min, max of gdp for each intermediate region; 
select m.intermediate_region_code , m.intermediate_region_name , round(avg(value)::numeric, 2) as avg_gdp, max(value)as Maximum, min(value) as Minimum
from africa_fs_ac a, m49_codes_expanded m
where m.m49_code = a.area_code_m49 
and item_code ='22013'
group by m.intermediate_region_code , m.intermediate_region_name  
order by m.intermediate_region_name 



--creat query that gives the avg, min, max of gdp for each intermediate region in africa  for 2011 to 2020;
select * from africa_fs_ac afa 
where year = '2011'


--This is the  quey that we want. it shows the year between 2011-2020;
select m.intermediate_region_code, m.intermediate_region_name, year,round(avg(value)::numeric, 2) as avg_gdp, min(value) as minimum, max(value) as maximum
from africa_fs_ac a 
join m49_codes_expanded m on m.m49_code = a.area_code_m49 
where item_code = '22013'
and  year between '2011' and '2020'
group by m.intermediate_region_code , m.intermediate_region_name, year 
order by m.intermediate_region_name, year;





--create a query that gives min and max gdp
-- for each intermediate region in Africa
-- (going across all years)
-- but show only countries where the avg gdp is <= $4000

select m.intermediate_region_code, m.intermediate_region_name,year,  round(avg(value)::numeric, 2) as gdp_avg, max(value) as maximum, min(value) as minimum
from africa_fs_ac a
join m49_codes_expanded m on m.m49_code =a.area_code_m49 
where item_code= '22013'
group by m.intermediate_region_code , m.intermediate_region_name , year
having avg(a.value) >=4000
order by m.intermediate_region_name , year; 

