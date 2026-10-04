SET search_path TO movies;

--   Task 1: Calculate the Average Budget Growth Rate for Each Production Company
-- Calculate the average budget growth rate for each production company across all movies they have produced. 
-- Use window functions to determine the budget growth rate and then calculate the average growth rate.
WITH movie_budgets AS (
    SELECT m.title, pc.company_name, m.budget,
LAG(m.budget) OVER (
    PARTITION BY mc.company_id
    ORDER BY m.release_date ASC
) AS previous_budget
    FROM movie m 
JOIN movie_company mc ON mc.movie_id = m.movie_id
JOIN production_company pc ON pc.company_id = mc.company_id
), 
growth_budget AS (
SELECT
    company_name,
	title,
    budget,
    previous_budget,
   ((budget - previous_budget)*100.0)/NULLIF(previous_budget, 0) AS growth_rate
FROM movie_budgets)
SELECT
    company_name,
    ROUND(AVG(growth_rate), 2) AS avg_growth_rate
FROM growth_budget
GROUP BY company_name
ORDER BY avg_growth_rate DESC;


-- 🌟 Task 2: Determine the Most Consistently High-Rated Actor
-- Identify the actor who has appeared in the most movies that are rated above the average rating of all movies. 
-- Use window functions and CTEs to calculate the average rating and filter the actors based on this criterion.


WITH rating_comparison AS (
SELECT m.movie_id, m.title, m.vote_average, AVG(m.vote_average) OVER () AS global_average
FROM movie m
),
high_rated_movies AS (
SELECT movie_id, title, vote_average
FROM rating_comparison
WHERE vote_average > global_average
),
actor_count AS (
SELECT p.person_id, p.person_name, COUNT(DISTINCT(hrm.movie_id)) AS actor_movie_count
FROM high_rated_movies hrm
JOIN movie_cast mc ON mc.movie_id = hrm.movie_id
JOIN person p ON p.person_id = mc.person_id
GROUP BY p.person_id, p.person_name
),
actor_rank AS (
SELECT *,
RANK() OVER (
    ORDER BY actor_movie_count DESC
) AS ranking
FROM actor_count
)
SELECT person_id, person_name, actor_movie_count, ranking
FROM actor_rank
WHERE ranking = 1

-- 🌟 Task 3: Calculate the Rolling Average Revenue for Each Genre
-- Calculate the rolling average revenue for movies within each genre, considering only the last three movies released in the genre. 
-- Use window functions with the ROWS frame specification to achieve this.

SELECT m.title, m.release_date, m.revenue, g.genre_id, g.genre_name, ROUND(AVG(m.revenue) OVER (
    PARTITION BY g.genre_id
    ORDER BY m.release_date, m.movie_id
    ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
),2) AS rolling_avg_revenue
FROM movie m 
JOIN movie_genres mg ON mg.movie_id = m.movie_id
JOIN genre g ON g.genre_id = mg.genre_id
ORDER BY genre_id 


-- 🌟 Task 4: Identify the Highest-Grossing Movie Series
-- Identify the movie series (based on shared keywords) with the highest total revenue. 
-- Use window functions and CTEs to group movies by their series and calculate the total revenue.

WITH series_revenue AS (
SELECT k.keyword_id, k.keyword_name, m.title, m.revenue, SUM(m.revenue) OVER (
    PARTITION BY k.keyword_id
) AS total_revenue
FROM movie m
JOIN movie_keywords mk ON mk.movie_id = m.movie_id
JOIN keyword k ON k.keyword_id = mk.keyword_id
)
SELECT DISTINCT keyword_id, keyword_name, total_revenue
FROM series_revenue
ORDER BY total_revenue DESC
LIMIT 1


