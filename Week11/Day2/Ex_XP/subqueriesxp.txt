-- 🌟 Exercise 1: Complex Subquery Analysis
-- Task 1: Find the average age of competitors who have won at least one medal, grouped by the type of medal they won. Use a correlated subquery to achieve this.

-- Task 2: Identify the top 5 regions with the highest number of unique competitors who have participated in more than 3 different events. Use nested subqueries to filter and aggregate the data.

-- Task 3: Create a temporary table to store the total number of medals won by each competitor and filter to show only those who have won more than 2 medals. Use subqueries to aggregate the data.

-- Task 4: Use a subquery within a DELETE statement to remove records of competitors who have not won any medals from a temporary table created for analysis.


SELECT m.medal_name, (SELECT AVG(gc.age) 
                      FROM games_competitor gc 
                      WHERE EXISTS (
                        SELECT 1
                        FROM competitor_event ce
                      WHERE ce.competitor_id = gc.id
                      AND ce.medal_id = m.id) 
                      )
                      AS average_age
FROM medal m
WHERE m.medal_name != 'NA';




SELECT nr.region_name, COUNT(DISTINCT gc.id) AS comp_nb
FROM games_competitor gc 
JOIN  person_region pr 
ON gc.person_id = pr.person_id
JOIN noc_region nr
ON pr.region_id = nr.id
WHERE gc.id IN (SELECT ce.competitor_id
       FROM competitor_event ce 
       GROUP BY ce.competitor_id
       HAVING COUNT(DISTINCT event_id) > 3
               )
GROUP BY nr.region_name
ORDER BY comp_nb DESC
LIMIT 5 ;



CREATE TEMP TABLE comp_medal AS
SELECT medal_totals.competitor_id, medal_totals.medal_nb
FROM (
  	SELECt  ce.competitor_id, COUNT(ce.medal_id) AS medal_nb
	FROM competitor_event ce
	WHERE ce.medal_id != 4
	GROUP BY ce.competitor_id)
    AS medal_totals
WHERE medal_totals.medal_nb > 2 ;


DELETE FROM comp_medal as cm
WHERE NOT EXISTS (
    SELECT 1
    FROM competitor_event ce
    WHERE ce.competitor_id = cm.competitor_id
      AND ce.medal_id != 4
);


-- 🌟 Exercise 2: Advanced Data Manipulation and Optimization
-- Task 1: Update the heights of competitors based on the average height of competitors from the same region. Use a correlated subquery within the UPDATE statement.

-- Task 2: Insert new records into a temporary table for competitors who participated in more than one event in the same games and list their total number of events participated. Use nested subqueries for filtering.

-- Task 3: Identify regions where the average number of medals won per competitor is greater than the overall average. Use subqueries to calculate and compare averages.

-- Task 4: Create a temporary table to track competitors’ participation across different seasons and identify those who have participated in both Summer and Winter games.
-- task1

CREATE TEMP TABLE region_avg AS
SELECT pr.region_id,
       AVG(p.height) AS avg_height
FROM person AS p
JOIN person_region AS pr
  ON pr.person_id = p.id
GROUP BY pr.region_id;

UPDATE person AS p
SET height = (
    SELECT ra.avg_height
    FROM person_region AS pr
    JOIN region_avg AS ra
      ON ra.region_id = pr.region_id
    WHERE pr.person_id = p.id
);

-- task 2

CREATE TEMP TABLE multi_event_competitors (
    competitor_id INTEGER,
    games_id INTEGER,
    event_count INTEGER
);
INSERT INTO multi_event_competitors (
    competitor_id,
    games_id,
    event_count
)
SELECT event_totals.competitor_id,
       event_totals.games_id,
       event_totals.event_count
FROM (
    SELECT ce.competitor_id,
           gc.games_id,
           COUNT(DISTINCT ce.event_id) AS event_count
    FROM competitor_event ce
    JOIN games_competitor gc
      ON ce.competitor_id = gc.id
    GROUP BY ce.competitor_id, gc.games_id
) AS event_totals
WHERE event_totals.event_count > 1;

-- task 3 
SELECT nr.region_name,
       AVG(region_data.medal_count) AS region_average
FROM (
    SELECT gc.id AS competitor_id,
           pr.region_id,
           SUM(
               CASE
                   WHEN ce.medal_id <> 4 THEN 1
                   ELSE 0
               END
           ) AS medal_count
    FROM games_competitor gc
    JOIN person_region pr
      ON pr.person_id = gc.person_id
    LEFT JOIN competitor_event ce
      ON ce.competitor_id = gc.id
    GROUP BY gc.id, pr.region_id
) region_data
JOIN noc_region nr
  ON nr.id = region_data.region_id
GROUP BY nr.region_name
HAVING AVG(region_data.medal_count) > (
    SELECT AVG(overall_data.medal_count)
    FROM (
        SELECT gc.id,
               SUM(
                   CASE
                       WHEN ce.medal_id <> 4 THEN 1
                       ELSE 0
                   END
               ) AS medal_count
        FROM games_competitor gc
        LEFT JOIN competitor_event ce
          ON ce.competitor_id = gc.id
        GROUP BY gc.id
    ) overall_data
);city

-- task 4 
CREATE TEMP TABLE competitor_seasons AS
SELECT DISTINCT gc.person_id,
                g.season
FROM games_competitor gc
JOIN games g
  ON g.id = gc.games_id;city

SELECT person_id
FROM competitor_seasons
WHERE season IN ('Summer', 'Winter')
GROUP BY person_id
HAVING COUNT(DISTINCT season) = 2;








