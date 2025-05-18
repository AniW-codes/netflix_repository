# Netflix Movies and TV Shows Data Analysis using SQL

![](https://github.com/najirh/netflix_sql_project/blob/main/logo.png)

## Overview
This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

## Objectives

- Analyze the distribution of content types (movies vs TV shows).
- Identify the most common ratings for movies and TV shows.
- List and analyze content based on release years, countries, and durations.
- Explore and categorize content based on specific criteria and keywords.

## Dataset

The data for this project is sourced from the Kaggle dataset:

- **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema

```sql
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
);
```

## Business Problems and Solutions

### 1. Count the Number of Movies vs TV Shows

```sql
Select type, Count(*)
from netflix
group by type
```

**Objective:** Determine the distribution of content types on Netflix.

### 2. Find the Most Common Rating for Movies and TV Shows

```sql
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
```

**Objective:** Identify the most frequently occurring rating for each type of content.

### 3. List All Movies Released in a Specific Year (e.g., 2021)

```sql
Select *
from netflix
	where type = 'Movie' 
	and 
	release_year = 2021
```

**Objective:** Retrieve all movies released in a specific year.

### 4. Find the Top 5 Countries with the Most Content on Netflix

```sql
Select 
	TRIM(Unnest(String_to_array(country, ','))) as Countries, --String2array helps to convert items into a list and Unnest breaks them
	Count(show_id) as total_count
from netflix
		Group by Countries
		order by total_count desc
		LIMIT 5;
```

**Objective:** Identify the top 5 countries with the highest number of content items.

### 5. Identify the Longest Movie

```sql
Select title, duration, CAST(TRIM(REPLACE(duration, 'min','')) as int) as DURATION_MOVIE
from netflix
	where type = 'Movie' and duration is not null
	ORDER BY DURATION_MOVIE desc
	LIMIT 1
```

**Objective:** Find the movie with the longest duration.

### 6. Find Content Added in the Last 4 Years

```sql
Select date_added, TO_DATE(date_added, 'Month DD, YYYY')
from netflix

Select *
from netflix
	where TO_DATE(date_added, 'Month DD, YYYY') >= Current_date - Interval '4 years'
```

**Objective:** Retrieve content added to Netflix in the last 4 years.

### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

```sql

select * 
from netflix
	where director ilike  '%Rajiv Chilaka%'; 	--To counter case sensitivity, we can use ILIKE operator to filter out the results.
---------

SELECT *
FROM (
    SELECT 
        *,
        UNNEST(STRING_TO_ARRAY(director, ',')) AS director_name
    FROM netflix
) AS t
WHERE director_name = 'Rajiv Chilaka';
```

**Objective:** List all content directed by 'Rajiv Chilaka'.

### 8. List All TV Shows with More Than 5 Seasons

```sql

Select title, duration 
from 
		(select title, duration, CAST(TRIM(SUBSTRING(duration, 1,2)) as int) as season_numeric
		from netflix
		where type = 'TV Show')
	where season_numeric > 5

--------

SELECT *
FROM netflix
WHERE type = 'TV Show'
  AND SPLIT_PART(duration, ' ', 1)::INT > 5;
```

**Objective:** Identify TV shows with more than 5 seasons.

### 9. Count the Number of Content Items in Each Genre

```sql
Select TRIM(Unnest(String_to_array(listed_in,','))) as Genre,
		Count(show_id)
from netflix
	GROUP BY Genre
	ORDER BY Count(show_id) desc
```

**Objective:** Count the number of content items in each genre.

### 10.Find each year and the average numbers of content release in India on netflix and return top 5 year with highest avg content release!

```sql
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
```

**Objective:** Calculate and rank years by the average number of content releases by India.

### 11. List All Movies that are Documentaries

```sql
Select *
from netflix
	where type = 'Movie'
	and listed_in ilike '%documentaries%'
```

**Objective:** Retrieve all movies classified as documentaries.

### 12. Find All Content Without a Director

```sql
Select *
from netflix
	where director is null
```

**Objective:** List content that does not have a director.

### 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

```sql
Select *
from netflix
	where casts ilike '%salman Khan%'
	and release_year > EXTRACT(YEAR from Current_date) - 10
```

**Objective:** Count the number of movies featuring 'Salman Khan' in the last 10 years.

### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

```sql
Select TRIM(UNNEST(STRING_TO_ARRAY(casts, ','))) as Actors,
		Count(show_id)
from netflix
	where country ilike '%India%'
	GROUP BY Actors
	ORDER BY Count(show_id) desc
	Limit 10
```

**Objective:** Identify the top 10 actors with the most appearances in Indian-produced movies.

### 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords in description field. Label contents containing these keywords as 'Bad' and 'Good' as per condition necessary and provide a count.

```sql
Select Category, COUNT(Category) from (
select *,
		CASE 
			When description ilike '%kill%' or description ilike '%violence%' then 'Bad'
			Else 'Good'
		END as Category
from netflix)
GROUP BY Category

-----

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
```

**Objective:** Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.

## Findings and Conclusion

- **Content Distribution:** The dataset contains a diverse range of movies and TV shows with varying ratings and genres.
- **Common Ratings:** Insights into the most common ratings provide an understanding of the content's target audience.
- **Geographical Insights:** The top countries and the average content releases by India highlight regional content distribution.
- **Content Categorization:** Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.

This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making.



## Author - Aniruddha Warang

This project is part of my portfolio, showcasing the SQL skills essential for data analyst roles. If you have any questions, feedback, or would like to collaborate, feel free to get in touch!

- **LinkedIn**: [Connect with me professionally]([https://www.linkedin.com/aniruddhawarang])

Thank you for your support, and I look forward to connecting with you!
