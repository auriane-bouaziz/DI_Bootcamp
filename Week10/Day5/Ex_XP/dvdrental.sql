-- EX1
-- Instructions
-- Get a list of all the languages, from the language table.

-- Get a list of all films joined with their languages – select the following details : film title, description, and language name.

-- Get all languages, even if there are no films in those languages – select the following details : film title, description, and language name.

-- Create a new table called new_film with the following columns : id, name. Add some new films to the table.

-- Create a new table called customer_review, which will contain film reviews that customers will make.
-- Think about the DELETE constraint: if a film is deleted, its review should be automatically deleted.
-- It should have the following columns:
-- review_id – a primary key, non null, auto-increment.
-- film_id – references the new_film table. The film that is being reviewed.
-- language_id – references the language table. What language the review is in.
-- title – the title of the review.
-- score – the rating of the review (1-10).
-- review_text – the text of the review. No limit on the length.
-- last_update – when the review was last updated.

-- Add 2 movie reviews. Make sure you link them to valid objects in the other tables.

-- Delete a film that has a review from the new_film table, what happens to the customer_review table?


SELECT name
FROM language;

SELECT title, description, name
FROM film INNER JOIN "language" ON "language".language_id = film.language_id;

SELECT title, description, name
FROM film RIGHT OUTER JOIN language ON film.language_id = language.language_id;

CREATE TABLE new_film(
 new_film_id SERIAL PRIMARY KEY,
 name VARCHAR (100) NOT NULL
)

ALTER TABLE new_film
RENAME COLUMN new_film_id TO id;


INSERT INTO new_film (name)
VALUES
    ('Shallow Hall'),
    ('Harry Potter and the Order of Phoenix'),
	('Something Gotta Give');
	

CREATE TABLE customer_review(
 review_id SERIAL PRIMARY KEY,
 film_id INTEGER NOT NULL 
	REFERENCES new_film(id) 
	ON DELETE CASCADE,
 language_id SMALLINT
	REFERENCES language(language_id),
 title VARCHAR (100) NOT NULL,
 score SMALLINT
	CHECK (score BETWEEN 1 AND 10),
 review_text TEXT,
 last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

SELECT *
FROM new_film;

INSERT INTO customer_review (film_id,language_id,title,score,review_text,last_update)
VALUES
    (1,5,'Life lesson',8,'I wish this movie was longer, true comedy and cute romance!','2026-07-02'),
    (2,1,'A classic',10,'Perhaps the best of all the saga, the trio grew up.','2026-07-02');
	
DELETE FROM new_film WHERE id=2

SELECT *
FROM new_film;
SELECT *
FROM customer_review;
-- the film was deleted in parent and child table, new_film and custmer_review as well. 

-- EX2
SELECT *
FROM language;

UPDATE film SET language_id=2 WHERE film_id=5;
UPDATE film SET language_id=2 WHERE film_id=7;

SELECT *
FROM film
ORDER BY film_id;

-- The customer table has one foreign key: address_id, which references the address table. 
-- When inserting a customer, the address_id must already exist in the address table.

DROP TABLE customer_review;
-- no need extra checking to drop customer_review as it is a child table. 

SELECT COUNT(*)
FROM rental
WHERE return_date IS NULL;

SELECT film.film_id, title, rental_rate
FROM film 
INNER JOIN inventory ON film.film_id = inventory.film_id 
INNER JOIN rental ON rental.inventory_id = inventory.inventory_id
WHERE return_date IS NULL
ORDER BY rental_rate DESC
LIMIT 30
;

-- The 1st film : The film is about a sumo wrestler, and one of the actors is Penelope Monroe.
SELECT title, description
FROM film INNER JOIN film_actor ON film.film_id = film_actor.film_id
INNER JOIN actor ON film_actor.actor_id = actor.actor_id
WHERE description ILIKE '%sumo wrestler%'
  AND actor.first_name = 'Penelope'
  AND actor.last_name = 'Monroe';

-- The 2nd film : A short documentary (less than 1 hour long), rated “R”.
SELECT *
FROM film 
WHERE rating = 'R' 
	AND length < 60 
	AND description ILIKE '%documentary%';
	
-- The 3rd film : A film that his friend Matthew Mahan rented. He paid over $4.00 for the rental,
-- and he returned it between the 28th of July and the 1st of August, 2005.

SELECT title, description
FROM film 
INNER JOIN inventory ON film.film_id = inventory.film_id 
INNER JOIN rental ON rental.inventory_id = inventory.inventory_id
INNER JOIN customer ON customer.customer_id = rental.customer_id
WHERE rental_rate = 4
	AND first_name = 'Matthew'
	AND last_name = 'Mahan'
	AND return_date IN ('2005-07-28','2005-08-01') 