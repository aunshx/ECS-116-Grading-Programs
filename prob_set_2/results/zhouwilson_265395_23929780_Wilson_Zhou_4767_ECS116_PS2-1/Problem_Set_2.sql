-- Basics
set
search_path to food_sec;

show search_path;

-- to the following to empty everything out of m49_codes_expanded
delete
from
	m49_codes_expanded;

-- sanity check ... is the table empty?
select
	count(*)
from
	m49_codes_expanded;

-- specifically: create a query that gives the row of m49_codes_expanded
-- for the country "Angola"
select
	*
from
	m49_codes_expanded mce
where
	country_or_area = 'Angola';

-- the two queries are: find distinct sub-region names associated with
-- countries in Africa, and same thing for intermediate-region names
select
	distinct sub_region_name
from
	m49_codes_expanded mce
where
	region_name = 'Africa'
order by
	sub_region_name;

select
	distinct intermediate_region_name,
	country_or_area
from
	m49_codes_expanded mce
where
	region_name = 'Africa'
order by
	intermediate_region_name ,
	country_or_area;

-- Here's a query that finds all countries in Africa for which the
-- intermediate_region_name is NULL
select
	m49_code ,
	country_or_area
from
	m49_codes_expanded mce
where
	region_name = 'Africa'
	and intermediate_region_code is null
order by
	country_or_area ;

-- Here's a query that finds all countries in Africa for which the
-- intermediate_region_name is an empty string
select
	m49_code ,
	country_or_area
from
	m49_codes_expanded mce
where
	region_name = 'Africa'
	and intermediate_region_code = ''
order by
	country_or_area ;

-- restrict the query to just Angola
select
	afa.area_code_m49 ,
	afa.area ,
	mce.intermediate_region_code,
	mce.intermediate_region_name,
	mce2.sub_region_code ,
	mce2.sub_region_name
from
	africa_fs_ac afa ,
	m49_codes_expanded mce ,
	m49_codes_expanded mce2
where
	afa.area_code_m49 = mce.m49_code
	and afa.area_code_m49 = mce2.m49_code
	and afa.area_code_m49 = '024';

-- how many records in africa_fs_ac have area_code_m49 = '024' (Angola)?
select
	count(*)
from
	africa_fs_ac
where
	area_code_m49 = '024';

-- using the DISTINCT statement on the whole query
select
	distinct afa.area_code_m49 ,
	afa.area ,
	mce.intermediate_region_code,
	mce.intermediate_region_name,
	mce2.sub_region_code ,
	mce2.sub_region_name
from
	africa_fs_ac afa ,
	m49_codes_expanded mce ,
	m49_codes_expanded mce2
where
	afa.area_code_m49 = mce.m49_code
	and afa.area_code_m49 = mce2.m49_code;

-- find the values for GDP per capita
select
	*
from
	africa_fs_ac afa
where
	item like('%Gross%');

-- find the average GDP per capita for each african country (going over all years)
select
	area_code_m49,
	area,
	avg(value) as avg_value
from
	africa_fs_ac afa
where
	afa.item_code = '22013'
group by
	area_code_m49 ,
	area
order by
	area ;

-- the avg rounded to 2 digits
select
	area_code_m49,
	area,
	round(avg(value)::numeric,
	2) as avg_value
from
	africa_fs_ac afa
where
	afa.item_code = '22013'
group by
	area_code_m49 ,
	area
order by
	area ;



-- find the average GDP per capita for each african intermediate region

select
	mce.intermediate_region_code ,
	mce.intermediate_region_name ,
	round(avg(value)::numeric,
	0) as avg_value
from
	africa_fs_ac afa ,
	m49_codes_expanded mce
where
	afa.item_code = '22013'
	and afa.area_code_m49 = mce.m49_code
group by
	mce.intermediate_region_code ,
	mce.intermediate_region_name
order by
	mce.intermediate_region_name;


-- find the average GDP per capita for each african sub region
select
	mce.sub_region_code ,
	mce.sub_region_name ,
	round(avg(value)::numeric,
	0) as avg_value
from
	africa_fs_ac afa ,
	m49_codes_expanded mce
where
	afa.item_code = '22013'
	and afa.area_code_m49 = mce.m49_code
group by
	mce.sub_region_code ,
	mce.sub_region_name
order by
	mce.sub_region_name;

-- create a query that gives the avg gdp, the max gdp, and the min gdp
-- over the years
-- for each intermeidate region in AFrica

select
	mce.intermediate_region_code ,
	mce.intermediate_region_name ,
	round(avg(value)::numeric,
	0) as avg_value,
	round(max(value)::numeric,
	0) as max_value,
	round(min(value)::numeric ,
	0) as min_value
from
	africa_fs_ac afa ,
	m49_codes_expanded mce
where
	afa.item_code = '22013'
	and afa.area_code_m49 = mce.m49_code
group by
	mce.intermediate_region_code ,
	mce.intermediate_region_name
order by
	mce.intermediate_region_name;




-- create a query that gives the avg, max and min gdp
-- for each intermediate region in Africa,
-- but just for 2011 to 2020

select
	afa."year" ,
	mce.intermediate_region_code ,
	mce.intermediate_region_name ,
	round(avg(value)::numeric,
	0) as avg_value,
	round(max(value)::numeric,
	0) as max_value,
	round(min(value)::numeric ,
	0) as min_value
from
	africa_fs_ac afa,
	m49_codes_expanded mce
where
	afa.item_code = '22013'
	and afa.area_code_m49 = mce.m49_code
	and substring(afa."year",
	1,
	4)::int between 2011 and 2020
group by
	mce.intermediate_region_code ,
	mce.intermediate_region_name,
	afa."year"
order by
	afa."year",
	mce.intermediate_region_name;


-- create a query that gives min and max gdp
-- for each intermediate region in Africa
-- (going across all years)
-- but show only countries where the avg gdp is <= $4000

select
	mce.intermediate_region_code ,
	mce.intermediate_region_name ,
	round(max(value)::numeric,
	0) as max_value,
	round(min(value)::numeric ,
	0) as min_value
from
	africa_fs_ac afa ,
	m49_codes_expanded mce
where
	afa.item_code = '22013'
	and afa.area_code_m49 = mce.m49_code
group by
	mce.intermediate_region_code ,
	mce.intermediate_region_name
having
	round(avg(value)::numeric,
	0) <= 4000
order by
	mce.intermediate_region_name;