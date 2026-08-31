
-- Exercise 1: Detailed Medal Analysis
-- Task 1: Identify competitors who have won at least one medal in events spanning both Summer and Winter Olympics. 
-- Create a temporary table to store these competitors and their medal counts for each season, 
-- and then display the contents of this table.
CREATE TEMP TABLE summer_winter_medalists AS

SELECT
    p.full_name,
    SUM(CASE WHEN g.season = 'Summer' THEN 1 ELSE 0 END) AS summer_medals,
    SUM(CASE WHEN g.season = 'Winter' THEN 1 ELSE 0 END) AS winter_medals

FROM games_competitor gc

JOIN person p
    ON gc.person_id = p.id

JOIN games g
    ON gc.games_id = g.id

JOIN competitor_event ce
    ON gc.id = ce.competitor_id

JOIN medal m
    ON ce.medal_id = m.id

WHERE m.id <> 4

GROUP BY p.full_name

HAVING
    SUM(CASE WHEN g.season = 'Summer' THEN 1 ELSE 0 END) >= 1
    AND
    SUM(CASE WHEN g.season = 'Winter' THEN 1 ELSE 0 END) >= 1;	
	
SELECT *
FROM summer_winter_medalists;


-- Task 2: Create a temporary table to store competitors who have won medals in exactly two different sports, 
-- and then use a subquery to identify the top 3 competitors with the highest total number of medals across all sports. 
-- Display the contents of this table.


CREATE TEMP TABLE two_sports_medalists AS

SELECT
    gc.person_id, p.full_name,
    COUNT(DISTINCT s.sport_name) AS number_of_sports,
    COUNT(ce.medal_id) AS total_medals
	
FROM person p
INNER JOIN games_competitor gc
ON p.id = gc.person_id
INNER JOIN competitor_event ce
ON gc.id = ce.competitor_id
INNER JOIN event e 
ON e.id = ce.event_id
INNER JOIN sport s 
ON s.id = e.sport_id
INNER JOIN medal m
ON m.id = ce.medal_id


WHERE m.id <> 4

GROUP BY gc.person_id, p.full_name

HAVING COUNT(DISTINCT sport_name) = 2;


SELECT *
FROM (
    SELECT *
    FROM two_sports_medalists
    ORDER BY total_medals DESC
    LIMIT 3
) AS top3;


-- Exercise 2: Region and Competitor Performance

-- Task 1: Retrieve the regions that have competitors who have won the highest number of medals in a single Olympic event.
-- Use a subquery to determine the event with the highest number of medals for each competitor, 
-- and then display the top 5 regions with the highest total medals.

SELECT
    region_name,
    SUM(max_per_competitor.max_medals_in_one_event) AS total_medals
FROM (
    SELECT
        person_id,
        MAX(medal_count) AS max_medals_in_one_event

    FROM (
        SELECT
            person_id,
            event_id,
            COUNT(ce.medal_id) AS medal_count

        FROM games_competitor gc
        JOIN competitor_event ce
            ON ce.competitor_id = gc.id

        WHERE ce.medal_id <> 4

        GROUP BY person_id, event_id
    ) AS medal_per_event_and_competitor

    GROUP BY person_id

) AS max_per_competitor

JOIN person_region pr
    ON pr.person_id = max_per_competitor.person_id

JOIN noc_region nr
    ON nr.id = pr.region_id

GROUP BY region_name
ORDER BY total_medals DESC
LIMIT 5;

-- Task 2: Create a temporary table to store competitors who have participated in more than three Olympic Games 
-- but have not won any medals. 
-- Retrieve and display the contents of this table, including their full names and the number of games they participated in.
CREATE TEMP TABLE no_medal_competitors AS

SELECT p.id, p.full_name, COUNT(DISTINCT gc.games_id) AS games_count
FROM person p 
JOIN games_competitor gc 
ON gc.person_id = p.id
JOIN competitor_event ce
ON ce.competitor_id = gc.id
GROUP BY p.id, p.full_name
HAVING COUNT(DISTINCT gc.games_id) > 3
AND SUM(CASE WHEN ce.medal_id <> 4 THEN 1 ELSE 0 END) = 0
ORDER BY p.full_name DESC;

SELECT *
FROM no_medal_competitors
ORDER BY full_name;
