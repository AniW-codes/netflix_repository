DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
)

Select *
from netflix

--Number if movies v tv shows
Select type, Count(*)
from netflix
group by type

--find most common rating for tv shows and movies
Select type, rating from (
		Select 
			type, 
			rating,
			Count(*) as tot,
			Rank()Over(Partition By type order by Count(*) DESC) as RNK
		from netflix
		Group By type, rating
)
where RNK = 1

--List all movies released in particular years (eg in 2021)
Select *
from netflix
	where type = 'Movie' 
	and 
	release_year = 2021

--Find top 5 countries with most content on netflix

Select 
	TRIM(Unnest(String_to_array(country, ','))) as Countries, --String2array helps to convert items into a list and Unnest breaks them
	Count(show_id) as total_count
from netflix
		Group by Countries
		order by total_count desc
		LIMIT 5;


--Identify the longest movie on netflix
Select title, duration, CAST(TRIM(REPLACE(duration, 'min','')) as int) as DURATION_MOVIE
from netflix
	where type = 'Movie' and duration is not null
	ORDER BY DURATION_MOVIE desc
	LIMIT 1

--Find content added in the last 4 years on netflix

Select date_added, TO_DATE(date_added, 'Month DD, YYYY')
from netflix

Select *
from netflix
	where TO_DATE(date_added, 'Month DD, YYYY') >= Current_date - Interval '4 years'

--Find all the movies/TV shows directed by 'Rajiv Chilaka'

select * 
from netflix
	where director ilike  '%Rajiv Chilaka%'; 	--To counter case sensitivity, we can use ILIKE operator to filter out the results.

--List all TV shows with more than 5 seasons

Select title, duration 
from 
		(select title, duration, CAST(TRIM(SUBSTRING(duration, 1,2)) as int) as season_numeric
		from netflix
		where type = 'TV Show')
	where season_numeric > 5


Select *
from netflix
	where type = 'TV Show' and 
					SPLIT_PART(duration, ' ',1)::int > 5 --Conversion of duration varchar into int to enable using > operator

--Count the number of content items in each genre (listed_in)
Select TRIM(Unnest(String_to_array(listed_in,','))) as Genre,
		Count(show_id)
from netflix
	GROUP BY Genre
	ORDER BY Count(show_id) desc

--Find each year and the average numbers of content release in INDIA on netflix and return top 5 year with highest avg content release

Select date_added, EXTRACT(YEAR from TO_DATE(date_added, 'Month DD, YYYY')) as year_add
from netflix 
	where Country = 'India'



Select EXTRACT(YEAR from TO_DATE(date_added, 'Month DD, YYYY')) as year_add, 
		Count(show_id),
		ROUND(Count(show_id) * 100.00/(Select Count(*) from netflix where country = 'India'), 2) as Avg_Percentage
from netflix 
	where Country = 'India'
	GROUP BY year_add
	ORDER BY count(show_id) desc

--List all movies that are Documentaries

Select *
from netflix
	where type = 'Movie'
	and listed_in ilike '%documentaries%'

--Find all content w/o director
Select *
from netflix
	where director is null

--Find how many movies has Salman Khan acted in the last 10 years
Select *
from netflix
	where casts ilike '%salman Khan%'
	and release_year > EXTRACT(YEAR from Current_date) - 10

--Find top 10 actors who have acted in movies released in India

Select TRIM(UNNEST(STRING_TO_ARRAY(casts, ','))) as Actors,
		Count(show_id)
from netflix
	where country ilike '%India%'
	GROUP BY Actors
	ORDER BY Count(show_id) desc
	Limit 10

--Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords in description field. Label contents containing these
--keywords as 'Bad' and 'Good' as per condition necessary and provide a count.

Select Category, COUNT(Category) from (
select *,
		CASE 
			When description ilike '%kill%' or description ilike '%violence%' then 'Bad'
			Else 'Good'
		END as Category
from netflix)
GROUP BY Category

----

With CTE_Category as
(
select *,
		CASE 
			When description ilike '%kill%' or description ilike '%violence%' then 'Bad'
			Else 'Good'
		END as Category
from netflix)

Select category, Count(*)
from CTE_Category
	GROUP BY category