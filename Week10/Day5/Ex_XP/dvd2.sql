-- EX2

-- Instructions
-- Use UPDATE to change the language of some films. Make sure that you use valid languages.

-- Which foreign keys (references) are defined for the customer table? How does this affect the way in which we INSERT into the customer table?

-- We created a new table called customer_review. Drop this table. Is this an easy step, or does it need extra checking?

-- Find out how many rentals are still outstanding (ie. have not been returned to the store yet).

-- Find the 30 most expensive movies which are outstanding (ie. have not been returned to the store yet)

-- Your friend is at the store, and decides to rent a movie. He knows he wants to see 4 movies, but he can’t remember their names. Can you help him find which movies he wants to rent?
-- The 1st film : The film is about a sumo wrestler, and one of the actors is Penelope Monroe.

-- The 2nd film : A short documentary (less than 1 hour long), rated “R”.

-- The 3rd film : A film that his friend Matthew Mahan rented. He paid over $4.00 for the rental, and he returned it between the 28th of July and the 1st of August, 2005.

-- The 4th film : His friend Matthew Mahan watched this film, as well. It had the word “boat” in the title or description, and it looked like it was a very expensive DVD to replace.




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
INNER JOIN payment ON payment.rental_id = rental.rental_id
WHERE payment.amount > 4
	AND first_name = 'Matthew'
	AND last_name = 'Mahan'
	AND return_date >= DATE '2005-07-28'
	AND return_date < DATE '2005-08-02';
-- two movies could be it. 

-- The 4th film : His friend Matthew Mahan watched this film, as well.
-- It had the word “boat” in the title or description, and it looked like it was a very expensive DVD to replace.

SELECT title, description, replacement_cost
FROM film 
INNER JOIN inventory ON film.film_id = inventory.film_id 
INNER JOIN rental ON rental.inventory_id = inventory.inventory_id
INNER JOIN customer ON customer.customer_id = rental.customer_id
WHERE (title ILIKE '%boat%' OR description ILIKE '%boat%')
	AND first_name = 'Matthew'
	AND last_name = 'Mahan'
ORDER BY replacement_cost DESC

-- best option is Stone fire cause highest replacement cost