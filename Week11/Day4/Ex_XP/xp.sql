-- Exercise 1: Movie Rankings and Analysis

-- Task 1: Rank Movies by Popularity within Each Genre
-- Use the RANK() function to rank movies by their popularity within each genre. Display the genre name, movie title, 
-- and their rank based on popularity.
SET search_path TO movies;

SELECT genre_name, m.title, 
  RANK() OVER (PARTITION BY genre_name ORDER BY popularity DESC) AS popularity_rank
FROM genre g
JOIN movie_genres mg
ON mg.genre_id = g.genre_id
JOIN movie m
ON m.movie_id = mg.movie_id;

-- Task 2: Identify the Top 3 Movies by Revenue within Each Production Company
-- Use the NTILE() function to divide the movies produced by each production company into quartiles based on revenue. 
-- Display the company name, movie title, revenue, and quartile.

SELECT pc.company_name, m.title, m.revenue, 
NTILE(4) OVER (PARTITION BY pc.company_id ORDER BY m.revenue DESC) AS revenue_quartile
FROM movie m 
JOIN movie_company mc
ON mc.movie_id = m.movie_id
JOIN production_company pc
ON pc.company_id = mc.company_id;

-- Task 3: Calculate the Running Total of Movie Budgets for Each Genre
-- Use the SUM() function with the ROWS frame specification to calculate the running total of movie budgets within each genre. 
-- Display the genre name, movie title, budget, and running total budget.

SELECT genre_name, m.title, m.budget, 
SUM(budget) OVER (PARTITION BY mg.genre_id ORDER BY budget ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total_budget
FROM genre g 
JOIN movie_genres mg 
ON mg.genre_id = g.genre_id 
JOIN movie m 
ON m.movie_id = mg.movie_id

-- Task 4: Identify the Most Recent Movie for Each Genre
-- Use the FIRST_VALUE() function to find the most recent movie within each genre based on the release date. 
-- Display the genre name, movie title, and release date.

WITH recent_movies AS (
    SELECT 
        genre_name,

        FIRST_VALUE(m.title) OVER (
            PARTITION BY g.genre_id
            ORDER BY m.release_date DESC
        ) AS most_recent_movie,

        FIRST_VALUE(m.release_date) OVER (
            PARTITION BY g.genre_id
            ORDER BY m.release_date DESC
        ) AS most_recent_release_date

    FROM genre g
    JOIN movie_genres mg
        ON mg.genre_id = g.genre_id
    JOIN movie m
        ON m.movie_id = mg.movie_id
)

SELECT DISTINCT
    genre_name,
    most_recent_movie,
    most_recent_release_date
FROM recent_movies;


--  Exercise 2: Cast and Crew Performance Analysis

-- Task 1: Rank Actors by Their Appearance in Movies

-- Use the DENSE_RANK() function to rank actors based on the number of movies they have appeared in. 
-- Display the actor’s name and their rank.

WITH actor_movie_count AS (
    SELECT 
        mc.person_id,
        p.person_name,
        COUNT(mc.movie_id) AS movie_count
    FROM person p
    JOIN movie_cast mc
        ON mc.person_id = p.person_id
    GROUP BY mc.person_id, p.person_name
)

SELECT person_name,  
DENSE_RANK() OVER (ORDER BY movie_count DESC) AS dense_rank
FROM actor_movie_count;

-- Task 2: Identify the Top Director by Average Movie Rating
-- Use a CTE and the RANK() function to find the director with the highest average movie rating.
-- Display the director’s name and their average rating.

WITH director_rating AS (
	SELECT 
		p.person_name, AVG(vote_average) AS avg_rating,
		RANK() OVER (ORDER BY AVG(vote_average) DESC) AS rank
	FROM person p 
	JOIN movie_crew mcr
	ON mcr.person_id = p.person_id
	JOIN movie m
	ON m.movie_id = mcr.movie_id
	WHERE job = 'Director'
	GROUP BY p.person_name, mcr.person_id
)

SELECT person_name, avg_rating
FROM director_rating
WHERE rank = 1 

-- Task 3: Calculate the Cumulative Revenue of Movies Acted by Each Actor
-- Use the SUM() function to calculate the cumulative revenue of movies acted by each actor. 
-- Display the actor’s name and the cumulative revenue.

SELECT person_name, m.title,
m.revenue,
SUM(revenue) OVER (PARTITION BY p.person_id ORDER BY m.revenue ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total_revenue
FROM person p 
JOIN movie_cast mc
ON mc.person_id = p.person_id
JOIN movie m 
ON mc.movie_id = m.movie_id;

-- Task 4: Identify the Director Whose Movies Have the Highest Total Budget

-- Use a CTE and a window function to find the director whose movies have the highest total budget. 
-- Display the director’s name and the total budget.
WITH directors_total_budget AS (
SELECT p.person_name, m.budget, 
SUM(m.budget) OVER (PARTITION BY p.person_id) AS total_budget
FROM person p 
JOIN movie_crew mc
ON mc.person_id = p.person_id
JOIN movie m 
ON mc.movie_id = m.movie_id
WHERE mc.job = 'Director'
)

SELECT person_name, total_budget
FROM directors_total_budget
ORDER BY total_budget DESC
LIMIT 1;




