/**
		About: 			  This script is a SQL Case study on RSVP movies 
        Probelm statement:RSVP Movies is an Indian film production company which has produced many super-hit movies. 
						  They have usually released movies for the Indian audience but for their next project, they are planning to release a movie for the global audience in 2022.
						  The production company wants to plan their every move analytically based on data and have approached us for help with this new project. We have been provided with the data of the movies that have been released in the past three years. 
						  We have to analyse the data set and draw meaningful insights that can help them start their new project. 
        Code writers: 	  Vaishnavi Sampath, Vaibhav & Renuka 
        Date: 			  25 Oct 2023
        Info: 			  -- The keywords and identifiers are formatted in uppercase and capitals respectively for readability
					      -- The how to approach for each question has been included in comments right after the question
						  -- Observations & inferences have been documented at the end of each code 
						  -- Code owners comments are marked in " -- ** " for differentiation from the prewritten script/code which is commneted in "--"
 
**/
USE imdb;

/* Now that you have imported the data sets, let’s explore some of the tables. 
 To begin with, it is beneficial to know the shape of the tables and whether any column has null values.
 Further in this segment, you will take a look at 'movies' and 'genre' tables.*/



-- Segment 1:


-- Q1. Find the total number of rows in each table of the schema?
-- Type your code below:
-- ** we will use primary keys to count the distinct rows for efficiency

SELECT
  (SELECT Count(Movie_id)
   FROM Director_mapping) AS Director_mapping_rows,
  (SELECT Count(Movie_id)
   FROM Genre) AS Genre_rows,
  (SELECT Count(Id)
   FROM Movie) AS Movie_rows,
  (SELECT Count(Id)
   FROM NAMES) AS Names_rows,
  (SELECT Count(Movie_id)
   FROM Ratings) AS Ratings_rows,
  (SELECT Count(*)
   FROM Role_mapping) AS Role_mapping_rows;
   
   
/**	Observation: 
	--movie and ratings table have equal rows which makes sense as there is a 1:1 mapping based on movie_id. 
	--all other columns have more rows than movie_id as there is 1: many relationship between movie and genre actors,actress (for example 1 more has more than 1 actor/actress/genre)
	--Director mapping count does not match the movie count, in fact its <60% meaning most movies do not have director info. Caution when we are working with this table as this may omit some records where director values are missing    **/

-- Q2. Which columns in the movie table have null values?
-- Type your code below:
-- ** we will get the numm counts by using the built in function isnull() which will return 1 or 0 based on the value and then we apply as sum to get the totalcount of nulls


SELECT Sum(Isnull(Id)) AS Id_null_count,
       Sum(Isnull(Title)) AS Title_null_count,
       Sum(Isnull(YEAR)) AS Year_null_count,
       Sum(Isnull(Duration)) AS Duration_null_count,
       Sum(Isnull(Country)) AS Country_null_count,
       Sum(Isnull(Worlwide_gross_income)) AS Worlwide_gross_income_null_count,
       Sum(Isnull(Languages)) AS Languages_null_count,
       Sum(Isnull(Production_company)) AS Production_company_null_count
FROM Movie;

-- **  Calculating the percent of nulls for better understanding

select sum(isnull(id))*100/count(id) as id_null_count,
sum(isnull(title))*100/count(title) as title_null_count,
sum(isnull(year))*100/count(year) as year_null_count,
sum(isnull(duration))*100/count(duration) as duration_null_count,
sum(isnull(country))*100/count(country) as country_null_count,
sum(isnull(worlwide_gross_income))*100/count(worlwide_gross_income) as worlwide_gross_income_null_count,
sum(isnull(languages))*100/count(languages) as languages_null_count,
sum(isnull(production_company))*100/count(production_company) as production_company_null_count
from movie;

/** Observation: 
	--country,grossincome,languages and production company details have null values and this might impact our inferences for cases where we refer to these values
	--gross income is not available for ~88% of data so this will lead to heavy biasing in our analysis, we need to be careful not to rely fully on metrics dependant of the gross income to avoid misinterpretation
	--We can also notice that id,title,year and duration do not have null values which is expected. **/


-- Now as you can see four columns of the movie table has null values. Let's look at the at the movies released each year. 
-- Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected)

/* Output format for the first part:

+---------------+-------------------+
| Year			|	number_of_movies|
+-------------------+----------------
|	2017		|	2134			|
|	2018		|		.			|
|	2019		|		.			|
+---------------+-------------------+


Output format for the second part of the question:
+---------------+-------------------+
|	month_num	|	number_of_movies|
+---------------+----------------
|	1			|	 134			|
|	2			|	 231			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

/**	computing the count of movies per year by grouping the year data
	we can either go with Year or Year(date_published) as we notice both have same results. 
	But for consistency & surity we are using the date_published as this field gives a better understanding with respect to naming convention than just 'year' column where we are unsure what this actually refers to. **/

-- ** computing the count of movies per year by grouping the year data
select year(date_published),count(title) as number_of_movies from movie
group by year(date_published);

select month(date_published),count(title) as number_of_movies from movie
group by month(date_published)
order by count(title) desc;

/** Observation:
	-- Less movies released in December and July while most of the movies released in March, ,September ,October and  January
    -- We can also notice that over the last 3 years the number movies per year has decreased by ~ 30%

/*The highest number of movies is produced in the month of March.
So, now that you have understood the month-wise trend of movies, let’s take a look at the other details in the movies table. 
We know USA and India produces huge number of movies each year. Lets find the number of movies produced by USA or India for the last year.*/
  
-- Q4. How many movies were produced in the USA or India in the year 2019??
-- Type your code below:

-- ** Based on the data understanding, a movie sometimes is jointly produced by multiple countries. we will be taking into account those entries as well

with USAIndiaMovies as (select 
 ( select count(*) from movie where year(date_published)=2019 and country regexp 'USA?') as USAMovies, -- ** all movies produced by USA (including other countries as well)
 ( select count(*) from movie where year(date_published)=2019 and country regexp 'India?') as IndiaMovies,  -- ** all movies produced by India (including other countries as well)
 ( select count(*) from movie where year(date_published)=2019 and country regexp 'USA?' and country regexp 'India?') as USAIndiaCommonMovies) -- ** all movies produced by USA & India (this is same as Intersection of the 2 sets)
 select USAMovies, IndiaMovies,USAIndiaCommonMovies, (USAMovies + IndiaMovies - USAIndiaCommonMovies ) as USAIndiaTogetherCombinedMoviesCount from USAIndiaMovies; -- ** We are getting the union results with formula Intersection(A,B)= A + B - Intersection(A,B) 
 
  
/* USA and India produced more than a thousand movies(you know the exact number!) in the year 2019.
Exploring table Genre would be fun!! 
Let’s find out the different genres in the dataset.*/

-- Q5. Find the unique list of the genres present in the data set?
-- Type your code below:


select genre from genre
group by genre ;-- rather than distinct we are going with group by to get unique genres as this will optimize the query performance


/** Observation:
	--There are 13 unique genres
    


/* So, RSVP Movies plans to make a movie of one of these genres.
Now, wouldn’t you want to know which genre had the highest number of movies produced in the last year?
Combining both the movie and genres table can give more interesting insights. */

-- Q6.Which genre had the highest number of movies produced overall?
-- Type your code below:

with MoviesPerGenre as (select genre, count(genre) as movie_count , rank() over (order by count(genre) desc) as GenreRanking from genre  -- assigning rank based on movie count
group by genre )
select genre,movie_count
from MoviesPerGenre
where GenreRanking=1;

/** Observation:
	--Drama tops the genre with most movies with 4285 movie count.



/* So, based on the insight that you just drew, RSVP Movies should focus on the ‘Drama’ genre. 
But wait, it is too early to decide. A movie can belong to two or more genres. 
So, let’s find out the count of movies that belong to only one genre.*/

-- Q7. How many movies belong to only one genre?
-- Type your code below:



with MovieWithOneGenre as( select m.id ,count(g.genre) as GenreCount
from movie m
join genre g
on m.id=g.movie_id
group by m.id
having count(g.genre)=1) -- filtering movies with only 1 genre count
select count(id) as CountOfMovieWithOneGenre from MovieWithOneGenre;

/** Observation:
	-- About 3289 movies that belong to only 1 genre. It is interesting to note that of of 7997 movies less than 50% movies belong to single category.
    -- We cannot fully decide that Drama is the top genre as this number is aggregated across multiple movies so the data may be biased **/

/* There are more than three thousand movies which has only one genre associated with them.
So, this figure appears significant. 
Now, let's find out the possible duration of RSVP Movies’ next project.*/

-- Q8.What is the average duration of movies in each genre? 
-- (Note: The same movie can belong to multiple genres.)


/* Output format:

+---------------+-------------------+
| genre			|	avg_duration	|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:


select genre,round(avg(duration),2) as avg_duration -- rounding avg duration to 2 decimals
from movie m
join genre g
on m.id=g.movie_id
group by genre
order by avg(duration) desc; -- find avg duration and sorting by avg duration

/** Observation:
	-- Action movies are most lengthy movies, followed by romance and crime

/* Now you know, movies of genre 'Drama' (produced highest in number in 2019) has the average duration of 106.77 mins.
Lets find where the movies of genre 'thriller' on the basis of number of movies.*/

-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 
-- (Hint: Use the Rank function)


/* Output format:
+---------------+-------------------+---------------------+
| genre			|		movie_count	|		genre_rank    |	
+---------------+-------------------+---------------------+
|drama			|	2312			|			2		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:

with MoviesPerGenre as (select genre, count(genre) as movie_count , rank() over (order by count(genre) desc) as genre_rank from genre  -- assigning rank based on movie count
group by genre )
select genre,movie_count,genre_rank
from MoviesPerGenre
where genre='Thriller';
/** Observation:
	-- Thriller movies ranked 3 based on total movie count.

/*Thriller movies is in top 3 among all genres in terms of number of movies
 In the previous segment, you analysed the movies and genres tables. 
 In this segment, you will analyse the ratings table as well.
To start with lets get the min and max values of different columns in the table*/


-- Segment 2:


-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
| min_avg_rating|	max_avg_rating	|	min_total_votes   |	max_total_votes 	 |min_median_rating|min_median_rating|
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
|		0		|			5		|	       177		  |	   2000	    		 |		0	       |	8			 |
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+*/
-- Type your code below:

select min(avg_rating) as min_avg_rating ,max(avg_rating) as max_avg_rating,min(total_votes) as min_total_votes,max(total_votes) as max_total_votes,min(median_rating) as min_median_rating,max(median_rating) as max_median_rating
from ratings;
/** Observation:
 -- avg rating and median rating is within bounds (between 1 & 10) and no outliers
 -- Minimum 100 votes have been cast and maximum votes is 72.5K


/* So, the minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table. 
Now, let’s find out the top 10 movies based on average rating.*/

-- Q11. Which are the top 10 movies based on average rating?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		movie_rank    |
+---------------+-------------------+---------------------+
| Fan			|		9.6			|			5	  	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
-- It's ok if RANK() or DENSE_RANK() is used too


with Top10Movies as(select title,avg_rating,
rank() over (order by avg_rating desc) as movie_rank
from movie m
join ratings r
on m.id=r.movie_id)
select * from Top10Movies
where movie_rank<=10;

/** Observation:
-- Kirket & Love in Kilnerry are top rated movies with avg_rating of 10
-- Fan is 5th highly rated movie



/* Do you find you favourite movie FAN in the top 10 movies with an average rating of 9.6? If not, please check your code again!!
So, now that you know the top 10 movies, do you think character actors and filler actors can be from these movies?
Summarising the ratings table based on the movie counts by median rating can give an excellent insight.*/

-- Q12. Summarise the ratings table based on the movie counts by median ratings.
/* Output format:

+---------------+-------------------+
| median_rating	|	movie_count		|
+-------------------+----------------
|	1			|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
-- Order by is good to have


select  median_rating,count(median_rating) as movie_count
from movie m
join ratings r
on m.id=r.movie_id
group by median_rating
order by median_rating;

/* Movies with a median rating of 7 is highest in number. 
Now, let's find out the production house with which RSVP Movies can partner for its next project.*/

-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??
/* Output format:
+------------------+-------------------+---------------------+
|production_company|movie_count	       |	prod_company_rank|
+------------------+-------------------+---------------------+
| The Archers	   |		1		   |			1	  	 |
+------------------+-------------------+---------------------+*/
-- Type your code below:



with ProductionCompanyRanking as(select production_company,count(production_company) as movie_count,rank() over (order by count(production_company) desc) as prod_company_rank
from movie m
join ratings r
on m.id=r.movie_id
and m.production_company is not null
where avg_rating>8
group by production_company)  -- using CTE to rank all the production company based on moviecount
select * from ProductionCompanyRanking
where prod_company_rank=1; -- filtering the companies with rank 1

-- It's ok if RANK() or DENSE_RANK() is used too
-- Answer can be Dream Warrior Pictures or National Theatre Live or both

-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?
/* Output format:

+---------------+-------------------+
| genre			|	movie_count		|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:


select genre,count(genre)  as movie_count
from movie m
join genre g
on m.id=g.movie_id
join ratings r
on m.id=r.movie_id
where year(date_published)='2017' -- filtering movies released in 2017
and month(date_published)=3 -- filtering movies released in March
and total_votes>1000 -- filtering movies  with more than 1000 votes
and country='USA' -- filtering movies released in USA
group by genre;


-- Lets try to analyse with a unique problem statement.
-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		genre	      |
+---------------+-------------------+---------------------+
| Theeran		|		8.3			|		Thriller	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:

select title,avg_rating,genre
from movie m
join ratings r
on m.id=r.movie_id
join genre g
on m.id=g.movie_id
where title regexp '^The' -- using regexp to find all the movie titles containing 'the'
and avg_rating>8 -- filtering movies with avg rating more than 8
order by avg_rating desc;

-- The Brighton Miracle is top rated movie among movies that contain 'The' based on average rating
select title,median_rating,genre
from movie m
join ratings r
on m.id=r.movie_id
join genre g
on m.id=g.movie_id
where title regexp '^The'
and median_rating>8
order by median_rating desc;

-- More than 5 movies topped the list based on median rating and The Brighton Miracle made it to this list too
-- The median rating 

-- You should also try your hand at median rating and check whether the ‘median rating’ column gives any significant insights.
-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?
-- Type your code below:


select count(title) as TotalMovies
from movie m
join ratings r
on m.id=r.movie_id
where date_published between '2018-04-01' and '2019-04-01'
and median_rating=8;


-- Once again, try to solve the problem given below.
-- Q17. Do German movies get more votes than Italian movies? 
-- Hint: Here you have to find the total number of votes for both German and Italian movies.
-- Type your code below:

with GermanMovies as( select count(total_votes) as VotesforGerman
from movie m
join ratings r
on m.id=r.movie_id
where languages regexp 'german'),
ItalianMovies as( select count(total_votes) as VotesforItalian
from movie m
join ratings r
on m.id=r.movie_id
where languages regexp 'italian')
select VotesforGerman,VotesforItalian,case 
when VotesforGerman>VotesforItalian then 'Yes'
else 'No'
end as IsGermanVotesMoreThanItalian
from ItalianMovies,GermanMovies;

-- Answer is Yes

/* Now that you have analysed the movies, genres and ratings tables, let us now analyse another table, the names table. 
Let’s begin by searching for null values in the tables.*/




-- Segment 3:



-- Q18. Which columns in the names table have null values??
/*Hint: You can find null values for individual columns or follow below output format
+---------------+-------------------+---------------------+----------------------+
| name_nulls	|	height_nulls	|date_of_birth_nulls  |known_for_movies_nulls|
+---------------+-------------------+---------------------+----------------------+
|		0		|			123		|	       1234		  |	   12345	    	 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:


select sum(isnull(name)) as name_nulls ,sum(isnull(height)) as height_nulls,
sum(isnull(date_of_birth)) as date_of_birth_nulls,
sum(isnull(known_for_movies)) as known_for_movies_nulls
from names;


-- select count(*) from names where date_of_birth is null


/* There are no Null value in the column 'name'.
The director is the most important person in a movie crew. 
Let’s find out the top three directors in the top three genres who can be hired by RSVP Movies.*/

-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?
-- (Hint: The top three genres would have the most number of movies with an average rating > 8.)
/* Output format:

+---------------+-------------------+
| director_name	|	movie_count		|
+---------------+-------------------|
|James Mangold	|		4			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:


with GenreRanking as(select genre,rank() over (order by count(genre) desc) as Ranking
from movie m
join ratings r
on m.id=r.movie_id
join genre g
on m.id=g.movie_id
where avg_rating>8
group by genre)
select name,count(name_id) as movie_count 
from director_mapping dm
join names n
on dm.name_id=n.id
join ratings r
on dm.movie_id=r.movie_id
join genre g
on dm.movie_id=g.movie_id
join GenreRanking gr
on g.genre=gr.genre
where avg_rating>8
and ranking<4
group by name_id
order by 2 desc
limit 3;



/* James Mangold can be hired as the director for RSVP's next project. Do you remeber his movies, 'Logan' and 'The Wolverine'. 
Now, let’s find out the top two actors.*/

-- Q20. Who are the top two actors whose movies have a median rating >= 8?
/* Output format:

+---------------+-------------------+
| actor_name	|	movie_count		|
+-------------------+----------------
|Christain Bale	|		10			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:



select name as actor_name, count(name),
rank() over (order by count(name) desc) as ranking
from movie m
join role_mapping rm
on rm.movie_id=m.id
join names n
on rm.name_id=n.id
join ratings r
on m.id=r.movie_id
where median_rating>=8
group by name;

select name as actor_name,count(name_id) as movie_count,
rank() over (order by count(name) desc) as ranking
from role_mapping rm
join ratings r
on rm.movie_id=r.movie_id
join names n
on rm.name_id=n.id
where median_rating>=8
group by name_id
order by 2 desc;



/* Have you find your favourite actor 'Mohanlal' in the list. If no, please check your code again. 
RSVP Movies plans to partner with other global production houses. 
Let’s find out the top three production houses in the world.*/

-- Q21. Which are the top three production houses based on the number of votes received by their movies?
/* Output format:
+------------------+--------------------+---------------------+
|production_company|vote_count			|		prod_comp_rank|
+------------------+--------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:



with Top3ProdHouse as (select production_company ,sum(total_votes) as vote_count , rank () over (order by sum(total_votes) desc) as prod_comp_rank
from movie m
join ratings r
on m.id=r.movie_id
group by production_company)
select * from Top3ProdHouse
where prod_comp_rank<=3;





/*Yes Marvel Studios rules the movie world.
So, these are the top three production houses based on the number of votes received by the movies they have produced.

Since RSVP Movies is based out of Mumbai, India also wants to woo its local audience. 
RSVP Movies also wants to hire a few Indian actors for its upcoming project to give a regional feel. 
Let’s find who these actors could be.*/

-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
-- Note: The actor should have acted in at least five Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actor_name	|	total_votes		|	movie_count		  |	actor_avg_rating 	 |actor_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Yogi Babu	|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

select n.name as actor_name, sum(total_votes) as total_votes,count(n.name) as movie_count, round(sum(total_votes * avg_rating)/sum(total_votes),2) as actor_avg_rating,rank() over(order by round(sum(total_votes * avg_rating)/sum(total_votes),2) desc, sum(total_votes) desc) as actor_rank
from role_mapping rm
join ratings r
on rm.movie_id=r.movie_id
join names n
on rm.name_id=n.id
join movie m
on rm.movie_id=m.id
where country ='India'
and category='actor'
group by n.name
having count(n.name)>=5;


-- Top actor is Vijay Sethupathi

-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 
-- Note: The actresses should have acted in at least three Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	actress_avg_rating 	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Tabu		|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:


select n.name as actor_name, sum(total_votes) as total_votes,count(n.name) as movie_count, round(sum(total_votes * avg_rating)/sum(total_votes),2) as actor_avg_rating,rank() over(order by round(sum(total_votes * avg_rating)/sum(total_votes),2) desc, sum(total_votes) desc) as actor_rank
from role_mapping rm
join ratings r
on rm.movie_id=r.movie_id
join names n
on rm.name_id=n.id
join movie m
on rm.movie_id=m.id
where country ='India'
and category='actress'
and languages regexp 'hindi?'
group by n.name
having count(n.name)>=3;






/* Taapsee Pannu tops with average rating 7.74. 
Now let us divide all the thriller movies in the following categories and find out their numbers.*/


/* Q24. Select thriller movies as per avg rating and classify them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/
-- Type your code below:



select title, case 
when avg_rating >8 then 'Superhit movies'
when avg_rating between 7 and 8 then 'Hit movies'
when avg_rating between 5 and 7 then 'One-time-watch movies'
else 'Flop movies' end as RatingCategory
from movie m
join ratings r
on m.id=r.movie_id
join genre g
on m.id=g.movie_id
where genre='thriller';





/* Until now, you have analysed various tables of the data set. 
Now, you will perform some tasks that will give you a broader understanding of the data in this segment.*/

-- Segment 4:

-- Q25. What is the genre-wise running total and moving average of the average movie duration? 
-- (Note: You need to show the output table in the question.) 
/* Output format:
+---------------+-------------------+---------------------+----------------------+
| genre			|	avg_duration	|running_total_duration|moving_avg_duration  |
+---------------+-------------------+---------------------+----------------------+
|	comdy		|			145		|	       106.2	  |	   128.42	    	 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:


SELECT genre,
    ROUND(AVG(duration),2) AS avg_duration,
    SUM(ROUND(AVG(duration),2)) OVER(ORDER BY genre ROWS UNBOUNDED 
    PRECEDING) AS running_total_duration,
    AVG(ROUND(AVG(duration),2)) OVER(ORDER BY genre ROWS 10 PRECEDING) 
    AS moving_avg_duration
FROM movie AS m 
INNER JOIN genre AS g 
ON m.id= g.movie_id
GROUP BY genre;

-- Round is good to have and not a must have; Same thing applies to sorting


-- Let us find top 5 movies of each year with top 3 genres.

-- Q26. Which are the five highest-grossing movies of each year that belong to the top three genres? 
-- (Note: The top 3 genres would have the most number of movies.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| genre			|	year			|	movie_name		  |worldwide_gross_income|movie_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	comedy		|			2017	|	       indian	  |	   $103244842	     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

-- Top 3 Genres based on most number of movies
select worlwide_gross_income,convert(SUBSTRING_INDEX (worlwide_gross_income,' ',-1) ,signed)  from movie where worlwide_gross_income not like '$%';
-- 1 INR = 0.0122 $


with MoviesUnderTopGenres as(
select g.genre, year,title as movie_name,worlwide_gross_income,case 
when SUBSTRING_INDEX (worlwide_gross_income,' ',1)='INR' then SUBSTRING_INDEX (worlwide_gross_income,' ',-1) *0.012
else  SUBSTRING_INDEX (worlwide_gross_income,' ',-1) end as worldwide_gross_income -- ,rank() over (order by convert(SUBSTRING_INDEX (worlwide_gross_income,' ',-1) ,signed) desc) as movie_rank
from movie m
join  genre g
on m.id=g.movie_id
join (select genre, rank() over (order by count(genre) desc) as ranking
from genre 
group by genre) gr
on g.genre=gr.genre
where ranking<=3)
select genre,year,movie_name,worlwide_gross_income,worldwide_gross_income,rank() over (order by convert(worldwide_gross_income,signed) desc) as movie_rank from MoviesUnderTopGenres;



-- Finally, let’s find out the names of the top two production houses that have produced the highest number of hits among multilingual movies.
-- Q27.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?
/* Output format:
+-------------------+-------------------+---------------------+
|production_company |movie_count		|		prod_comp_rank|
+-------------------+-------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:


with MultiLingualMovies as (select production_company,count(production_company) as movie_count , rank() over (order by count(production_company) desc) as prod_comp_rank
from movie m
join ratings r
on m.id=r.movie_id
where POSITION(',' IN languages)>0
and median_rating>=8 
 group by production_company)
 select * from MultiLingualMovies
 where prod_comp_rank<=2;





-- Multilingual is the important piece in the above question. It was created using POSITION(',' IN languages)>0 logic
-- If there is a comma, that means the movie is of more than one language


-- Q28. Who are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |actress_avg_rating	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Laura Dern	|			1016	|	       1		  |	   9.60			     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

with topactress as(select name as actress_name ,sum(total_votes) as total_votes,count(name) as movie_count,avg(avg_rating) as actress_avg_rating
,rank () over (order by count(name) desc ,avg(avg_rating) desc) as actress_rank
from movie m
join role_mapping rm
on m.id=rm.movie_id
join names n
on rm.name_id=n.id
join ratings r
on m.id=r.movie_id
join genre g
on m.id=g.movie_id
where avg_rating>8
and genre='drama'
and category='actress'
group by name)
select * from topactress
where actress_rank<=3






/* Q29. Get the following details for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations

Format:
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
| director_id	|	director_name	|	number_of_movies  |	avg_inter_movie_days |	avg_rating	| total_votes  | min_rating	| max_rating | total_duration |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
|nm1777967		|	A.L. Vijay		|			5		  |	       177			 |	   5.65	    |	1754	   |	3.7		|	6.9		 |		613		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+

--------------------------------------------------------------------------------------------*/
-- Type you code below:


with DirectorRank as (select name_id as director_id,count(name_id) as number_of_movies ,rank() over(order by count(name_id) desc) as director_ranking
from director_mapping
group by name_id),
Directordata as(
select name,name_id,
datediff(date_published , lag(date_published,1) over (partition by name_id order by date_published)) as inter_movie_days,
avg_rating,
total_votes,
duration 
from movie m
join director_mapping dm
on m.id=dm.movie_id
join names n
on dm.name_id=n.id
join ratings r
on m.id=r.movie_id)
select director_id,name,count(number_of_movies) as number_of_movies,
round(avg(inter_movie_days) )as avg_inter_movie_days,
round(avg(avg_rating)) as avg_rating,
sum(total_votes) as total_votes,
min(avg_rating) as min_rating,
max(avg_rating) as max_rating,
sum(duration) as total_duration
from Directordata dd
join DirectorRank dr
on dd.name_id=dr.director_id
where director_ranking<=9
group by director_id,name
order by director_ranking asc ,avg_rating desc






