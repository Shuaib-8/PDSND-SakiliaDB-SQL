/* Query 1 - which countries did customers purchase the the most DVD rental (Top 10) */

SELECT country AS country_name, SUM(payment.amount) AS payment_amount
FROM customer
JOIN payment
ON payment.customer_id = customer.customer_id
JOIN address
ON address.address_id = customer.address_id
JOIN city
ON city.city_id = address.city_id
JOIN country
ON country.country_id = city.country_id
WHERE country != 'Runion'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

/* Query 2 - The average film length per actor */
-- CTE to manipulate table in specified way

WITH t1 AS (SELECT actor.first_name, actor.last_name, first_name || ' ' || last_name AS actor_name, 
			film.length AS film_length
            FROM film
            JOIN film_actor
            ON film_actor.film_id = film.film_id
            JOIN actor
            ON film_actor.actor_id = actor.actor_id)

SELECT actor_name, AVG(film_length) AS avg_runtime
FROM t1
GROUP BY 1
ORDER BY 2 DESC;

/* Query 3 - DVD rentals by the number of rentals for payment levels for each store: inexpensive, affordable, expensive */
-- Window function, subquery within from and CASE WHEN statement to group payments into finite groups (categories)

SELECT DISTINCT(payment_levels), store_id,
                COUNT(amount) OVER(PARTITION BY payment_levels ORDER BY store_id DESC) AS Paymentcount_bypaymentgroups
FROM
	(SELECT payment.amount, store.store_id,
                  CASE WHEN amount <= 6.00 THEN 'Inexpensive'
                  WHEN amount > 6.00 AND amount <= 9.00 THEN 'Affordable'
                  ELSE 'Expensive'
                  END AS payment_levels
                  FROM payment
                  JOIN customer
                  ON payment.customer_id = customer.customer_id
                  JOIN staff
                  ON staff.staff_id = payment.staff_id
                  JOIN store
                  ON staff.store_id = store.store_id) AS t1
ORDER BY 1, 2;


/* Query 4 - Which film category/topic gathered the most rentals? */

WITH t1 AS (SELECT category.name, film.rental_duration, film.rental_rate
                              FROM category
                              JOIN film_category
                              ON category.category_id = film_category.category_id
                              JOIN film
                              ON film_category.film_id = film.film_id
 )

SELECT name, SUM(rental_rate)
FROM t1
GROUP BY 1
ORDER BY 2 DESC;
