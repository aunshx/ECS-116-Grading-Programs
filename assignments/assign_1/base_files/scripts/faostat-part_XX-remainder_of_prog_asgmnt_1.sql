--======================================
-- These are steps that the students will have to do for Programming Assignment 1

-- THIS FILE SHOULD NOT BE SHARED WITH THE STUDENTS !!
--======================================


--==================================================
-- uploading file africa_fs_ac_db.csv into postgresql
--==================================================


set search_path to food_sec__v02

show search_path

-- upload file africa_fs_ac_db.csv into PostgreSQL using DBeaver

-- using DBeaver, change the datatypes of selected columns
-- a.	area_code_m49: varchar(3)
-- b.	element_code: varchar(4)
-- c.	year_code: varchar(8)
-- d.	value: numeric

-- check whether values in the value column match csv file
select distinct value
from africa_fs_ac 
where value <= 2
-- spreadsheet has lots of decimal values

-- empty out and reload africa_fs_ac now that the data types are fixed
delete from africa_fs_ac 

-- use DBeaver to reload the data from the csv file
--    (right click on the table name africa_fs_ac and import data)


--==================================================
-- CREATING table gdp_stunting_overweight_anemia
--==================================================


-- Query that will be used to populate gdp_stunting_overweight_anemia

select gdp.area_code_m49, gdp.area, gdp.year_code,
       gdp.value as gdp_pc_ppp,
       stunting.value as childhood_stunting,
       overweight.value as childhood_overweight,
       anemia.value as anemia
from africa_fs_ac gdp,             -- providing the values for gdp
     africa_fs_ac stunting,        -- providing the values for stunting
     africa_fs_ac overweight,      -- providing the values for overweight
     africa_fs_ac anemia           -- providing the values for anemia
where stunting.area_code_m49 = gdp.area_code_m49
  and overweight.area_code_m49 = gdp.area_code_m49 
  and anemia.area_code_m49 = gdp.area_code_m49
--
  and stunting.year_code = gdp.year_code
  and overweight.year_code = gdp.year_code
  and anemia.year_code = gdp.year_code
--  
  and gdp.item_code = '22013'
  and stunting.item_code = '21025'
  and overweight.item_code = '21041'
  and anemia.item_code = '21043'
order by area, year_code

  
-- this yields 993 records, so good coverage
--   (a little less than the 1095 recods in gdp_stunting_overweight)

-- Let's make a table to hold this data

create table gdp_stunting_overweight_anemia
  (area_code_m49 varchar(3),
   area varchar(32),
   year_code varchar(8),
   gdp_pc_ppp numeric,
   childhood_stunting numeric,
   childhood_overweight numeric,
   anemia numeric,
   primary key (area_code_m49, year_code)
   )

-- now let's load the output from previous query into this table

insert into gdp_stunting_overweight_anemia
  (area_code_m49,
   area,
   year_code,
   gdp_pc_ppp,
   childhood_stunting,
   childhood_overweight,
   anemia
   )
select gdp.area_code_m49, gdp.area, gdp.year_code,
       gdp.value as gdp_pc_ppp,
       stunting.value as childhood_stunting,
       overweight.value as childhood_overweight,
       anemia.value as anemia
from africa_fs_ac gdp,             -- providing the values for gdp
     africa_fs_ac stunting,        -- providing the values for stunting
     africa_fs_ac overweight,      -- providing the values for overweight
     africa_fs_ac anemia           -- providing the values for anemia
where stunting.area_code_m49 = gdp.area_code_m49
  and overweight.area_code_m49 = gdp.area_code_m49 
  and anemia.area_code_m49 = gdp.area_code_m49
--
  and stunting.year_code = gdp.year_code
  and overweight.year_code = gdp.year_code
  and anemia.year_code = gdp.year_code
--  
  and gdp.item_code = '22013'
  and stunting.item_code = '21025'
  and overweight.item_code = '21041'
  and anemia.item_code = '21043'
-- order by area, year_code
  
-- inserted 993 records, which matches size of the query

-- sanity check
select count(*)
from gdp_stunting_overweight_anemia
-- 993; matches output of the query

-- sanity check
select *
from gdp_stunting_overweight



--=============================================
-- STUDENTS DO NOT NEED TO DO THE NEXT STEP,

-- Finding 3-year values with high availability  

-- The following query identifies items for which 
--     data is available for >= 20 years for
--     more than 45 countries
--    with a focus on data based on 3-year intervals
with high_avail_country_item as
( 
select area_code_m49, item_code, count(*), item, area 
from africa_fs_ac af
-- next line is focusing on the values based on a 3-year interval
where length(year_code) = 8
--  and item_code = '21049'         -- overweight
group by area_code_m49, area, item_code, item
having count(*) >= 20
order by area, item
)
select item_code, count(*), item
from high_avail_country_item
group by item_code, item
having count(*) >= 45
order by item

-- Here is the output
-- 21010	50	Average dietary energy supply adequacy (percent) (3-year average)
-- 210011	47	Number of people undernourished (million) (3-year average)
-- 210041	49	Prevalence of undernourishment (percent) (3-year average)

--=============================================


--==================================================
-- CREATING table energy_undernourished
--==================================================



-- STUDENTS NEED TO DO THE NEXT STEPS

-- query for building table energy_undernourished


select de.area_code_m49, de.area, de.year_code,
       de.value as dietary_energy,
       un.value as undernourishment
from africa_fs_ac de,    -- giving value for dietary energy
     africa_fs_ac un     -- giving value for prevalence of undernourishment
where un.area_code_m49 = de.area_code_m49
--
  and un.year_code = de.year_code
--  
  and de.item_code = '21010'
  and un.item_code = '210041'
order by area, year_code
  
-- this yields 1040 records, so good coverage

-- Let's make a table to hold this data

create table energy_undernourished
  (area_code_m49 varchar(3),
   area varchar(32),
   year_code varchar(8),
   dietary_energy numeric,
   undernourished numeric,
   primary key (area_code_m49, year_code)
   )

-- now let's load the output from previous query into this table

insert into energy_undernourished  
  (area_code_m49,
   area,
   year_code,
   dietary_energy,
   undernourished
   )
select de.area_code_m49, de.area, de.year_code,
       de.value as dietary_energy,
       un.value as undernourishment
from africa_fs_ac de,    -- giving value for dietary energy
     africa_fs_ac un     -- giving value for prevalence of undernourishment
where un.area_code_m49 = de.area_code_m49
--
  and un.year_code = de.year_code
--  
  and de.item_code = '21010'
  and un.item_code = '210041'
-- order by area, year_code
  
-- this added 1040 rows, which matches the size of the query

-- sanity check
select count(*)
from energy_undernourished
-- 1040; matches output of the query

-- sanity check
select *
from energy_undernourished

-- adding column "derived_year" to energy_undernourished

-- first, add the column, with type numeric but no values
-- for something similar, see
--     https://stackoverflow.com/questions/49368451/postgres-add-column-with-initially-calculated-values
ALTER TABLE energy_undernourished
ADD COLUMN derived_year numeric

-- sanity check: 
--    refresh your schema
--    look at columns info for energy_undernourished

-- inserting computed values for derived_year into energy_undernourished
-- see https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-update/
-- for the string manipulations, 
--    see https://www.postgresqltutorial.com/postgresql-string-functions/
--    and https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-cast/
update energy_undernourished 
set derived_year = cast(left(year_code, 4) as integer) + 1

-- sanity check: refresh and examine table

-- change datatype of derived_year to varchar(4), so that we can join with 
--    gdp_stunting_overweight_anemia
-- use SQL or DBeaver

ALTER TABLE energy_undernourished 
ALTER COLUMN derived_year 
TYPE varchar(4) USING derived_year::varchar(4);


--==================================================
-- JOINING tables gdp_stunting_overweight_anemia and energy_undernourished
--==================================================

-- here is the query for populating the new table
--     gdp_energy_with_fs_indicators

select g.area_code_m49, g.area, g.year_code,
       g.gdp_pc_ppp,
       e.dietary_energy,
       g.childhood_stunting,
       g.childhood_overweight,
       g.anemia,
       e.undernourished 
from gdp_stunting_overweight_anemia g, 
     energy_undernourished e
where e.area_code_m49 = g.area_code_m49 
  and e.derived_year = g.year_code 
-- 895 tuples

-- create table to hold this data set
create table gdp_energy_with_fs_indicators
(
    area_code_m49 varchar(3),
    area varchar(32),
    year_code varchar(4),
    gdp_pc_ppp numeric,
    dietary_energy numeric,
    childhood_stunting numeric,
    childhood_overweight numeric,
    anemia numeric,
    undernourished numeric,
    primary key (area_code_m49, year_code)
)
  
-- add the values into the table
insert into gdp_energy_with_fs_indicators 
(
    area_code_m49,
    area,
    year_code,
    gdp_pc_ppp,
    dietary_energy,
    childhood_stunting,
    childhood_overweight,
    anemia,
    undernourished
)
select g.area_code_m49, g.area, g.year_code,
       g.gdp_pc_ppp,
       e.dietary_energy,
       g.childhood_stunting,
       g.childhood_overweight,
       g.anemia,
       e.undernourished 
from gdp_stunting_overweight_anemia g, 
     energy_undernourished e
where e.area_code_m49 = g.area_code_m49 
  and e.derived_year = g.year_code 
-- inserted 895 tuples
  
-- export this to a csv file using DBeaver
  
-- if necessary, sort the csv file by area (country name) and year_code
  
--==============================================
-- creating table with aggegated values by country
--==============================================
  
-- the query used to populate the table
  
-- I am rounding to 2 digits, and casting into numeric
-- see https://stackoverflow.com/questions/13113096/how-to-round-an-average-to-2-decimal-places-in-postgresql
  
select area_code_m49, area, 
    round(avg(gdp_pc_ppp)::numeric, 2) as avg_gdp_pc_ppp,
    round(avg(dietary_energy)::numeric, 2) as avg_dietary_energy,
    round(avg(childhood_stunting)::numeric, 2) as avg_childhood_stunting,
    round(avg(childhood_overweight)::numeric, 2) as avg_childhood_overweight,
    round(avg(anemia)::numeric, 2) as avg_anemia,
    round(avg(undernourished)::numeric, 2) as avg_undernourished
from gdp_energy_with_fs_indicators
group by area_code_m49, area
order by area

-- create table to hold this data

create table gdp_energy_fs_aggs
(
    area_code_m49 varchar(3),
    area varchar(32),
    avg_gdp_pc_ppp numeric,
    avg_dietary_energy numeric,
    avg_childhood_stunting numeric,
    avg_childhood_overweight numeric,
    avg_anemia numeric,
    avg_undernourished numeric
)

insert into gdp_energy_fs_aggs
(
    area_code_m49,
    area,
    avg_gdp_pc_ppp,
    avg_dietary_energy,
    avg_childhood_stunting,
    avg_childhood_overweight,
    avg_anemia,
    avg_undernourished
)
select area_code_m49, area, 
    round(avg(gdp_pc_ppp)::numeric, 2) as avg_gdp_pc_ppp,
    round(avg(dietary_energy)::numeric, 2) as avg_dietary_energy,
    round(avg(childhood_stunting)::numeric, 2) as avg_childhood_stunting,
    round(avg(childhood_overweight)::numeric, 2) as avg_childhood_overweight,
    round(avg(anemia)::numeric, 2) as avg_anemia,
    round(avg(undernourished)::numeric, 2) as avg_undernourished
from gdp_energy_with_fs_indicators
group by area_code_m49, area
order by area

