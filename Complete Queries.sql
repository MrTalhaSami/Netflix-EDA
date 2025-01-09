-- Creating and Importing data through query.

CREATE TABLE netflix_data (
    show_id TEXT PRIMARY KEY,
    type TEXT,
    title TEXT,
    director TEXT,
    casts TEXT,
    country TEXT,
    date_added DATE,
    release_year INT,
    rating TEXT,
    duration TEXT,
    listed_in TEXT,
    description TEXT
);

COPY netflix_data (
	show_id,
	type,
	title,
	director,
	casts,
	country,
	date_added,
	release_year,
	rating,
	duration,
	listed_in,
	description
)
from 'D:\Talha\Business Analytics\SQL\[PROJECT] - Netflix Dataset\netflix_titles.csv'
delimiter ','
csv header;

select*from netflix_data;

-- Creating and importing data through Import option

CREATE TABLE netlfix (
    show_id TEXT PRIMARY KEY,
    type TEXT,
    title TEXT,
    director TEXT,
    casts TEXT,
    country TEXT,
    date_added DATE,
    release_year INT,
    rating TEXT,
    duration TEXT,
    listed_in TEXT,
    description TEXT
);

select * from netlfix;

--Lets use "netflix_data" table for further process...

select count(*) from netlfix_data; -- returns total no. of rows in table

select distinct type from netflix_data; -- returns all unique type




-- 15 Business Problems & Solutions

--1. Count the number of Movies vs TV Shows

select type, count(*) 
from netflix_data
group by type;

--2. Find the most common rating for movies and TV shows

with cte as(
select type, rating, count(*) as trp, rank () over(partition by type order by count(*) desc )  
from netflix_data
group by rating, type
order by type asc, trp desc
)
select type, rating, trp
from cte
where rank = 1;
;


--3. List all movies released in a specific year (e.g., 2020)

select title 
from netflix_data
where type = 'Movie' and release_year = 2020;

--4. Find the top 5 countries with the most content on Netflix

select country,count(*) 
from netflix_data
where country is not null
group by country
order by 2 desc
limit 5;

--5. Identify the longest movie

select title,duration, 
	SPLIT_PART(duration, ' ', 1)::INT AS duration_in_minutes
from netflix_data
where type= 'Movie' AND duration is not null
order by 3 desc
limit 1;

--6. Find content added in the last 5 years

with cte as(
	select max(date_added) as recent_date
	from netflix_data
)
select type, extract (year from date_added) as content_year, count(*)
from netflix_data
where date_added is not null
and date_added >= (select recent_date - INTERVAL '5 years' from cte)
group by 1,2
order by 2 desc 
;


-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

select title,type from netflix_data
where director Ilike '%Rajiv Chilaka%';

-- 8. List all TV shows with more than 5 seasons

select title,duration, 
	SPLIT_PART(duration, ' ', 1)::INT AS Number_of_seasons
from netflix_data
where type= 'TV Show' AND duration is not null
order by 3 desc
limit 1;

-- 9. Count the number of content items in each genre

select 
	unnest(string_to_array(listed_in, ',')),count(*)
from 
	netflix_data
group by 1
order by 2 desc


-- 10.Find each year and the average numbers of content release in India on netflix. 
--return top 5 year with highest avg content release!

with cte as(
	select extract (year from date_added) as content_year,count(title) as no_of_content
	from netflix_data
	where country = 'India'
	group by 1
	order by 2 desc
)
select avg(no_of_content)
from cte;

--11. List all movies that are documentaries
with cte as(
	select 
		unnest(string_to_array(listed_in, ',')),count(*)
		,title
	from 
		netflix_data
	group by 1,3
	order by 2 desc
)
select title,unnest
from cte
where unnest = 'Documentaries'

--12. Find all content without a director

select * from netflix_data
where director is null

--13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

select count(*) from netflix_data
where casts ilike '%Salman Khan%' and release_year < extract(year from current_date)-10


--14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
select 
	unnest(string_to_array(casts,',')) as actors,
	count(*)
from netflix_data
where type = 'Movie' and country = 'India'
group by 1
order by 2 desc 
limit 10

--15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
--the description field. Label content containing these keywords as 'Bad' and all other 
--content as 'Good'. Count how many items fall into each category.


select 
	case
		when description ilike '%kill%' or description ilike '%violence%' then 'bad'
	else 'good'
end as content_status,count(*)
from netflix_data
group by 1;


