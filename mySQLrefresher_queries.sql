/* MYSQL assignment to provide basic understanding and practice on
 - Querying a database tables
 - Creating / Updating /Dropping tables
 - Creating JOINs to extract information
 - Sorting / Ordering data
 - Creating Views for data reporting
 */
 
 -- Set the database or schema that will be used throughout the exercise
 USE sakila;
 
 -- 1a. Display the first and last names of all actors from the table actor
 SELECT first_name, last_name FROM actor;
 
 -- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name
 SELECT CONCAT_WS(" ", UCASE(first_name), UCASE(last_name)) as `Actor Name` FROM actor;
 
 -- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
 SELECT actor_ID as `ID number`, first_name as `First Name`, last_name as `Last Name` FROM actor
 WHERE UCASE(first_name) = UCASE("Joe"); 
 
 -- Find all actors whose last name contain the letters GEN:
 SELECT actor_ID as `ID number`, first_name as `First Name`, last_name as `Last Name` FROM actor
 WHERE UCASE(last_name) LIKE '%GEN%';
 
 -- Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
 SELECT actor_ID as `ID number`, first_name as `First Name`, last_name as `Last Name` FROM actor
 WHERE INSTR(UCASE(last_name), UCASE("LI")) > 0
 ORDER BY last_name, first_name;
 
 -- Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China
 SELECT country_id, country FROM country
 WHERE UCASE(country) IN (UCASE("Afghanistan"), UCASE("Bangladesh"), UCASE("China"));
 
 -- You want to keep a description of each actor. You don't think you will be performing queries on a description, 
 -- 3a. so create a column in the table actor named description and use the data type BLOB 
 ALTER TABLE actor 
 ADD COLUMN description BLOB;
 
 -- check to see if new column has been added
 DESC actor;
 
 -- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
 ALTER TABLE actor
 DROP COLUMN description;
 
 -- check to see if the new column description has been dropped
 DESC actor;
 
 -- 4a. List the last names of actors, as well as how many actors have that last name.
 SELECT last_name, count(last_name) as `Num_Actors_with_same_LastName`  FROM actor
 GROUP BY last_name
 ORDER BY last_name;
 
 -- 4b. List last names of actors and the number of actors who have that last name, 
 -- but only for names that are shared by at least two actors
 SELECT last_name, count(last_name) as `Num_Actors_with_same_LastName`  FROM actor
 GROUP BY last_name
 HAVING count(last_name) >= 2
 ORDER BY last_name;
 
 -- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS
 UPDATE actor
 SET first_name = UCASE("HARPO")
 WHERE UCASE(first_name) = UCASE("GROUCHO") and UCASE(last_name) = UCASE("WILLIAMS");
 
 -- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all!
 -- In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
 UPDATE actor
 SET first_name = UCASE("GROUCHO")
 WHERE UCASE(first_name) = UCASE("HARPO") and UCASE(last_name) = UCASE("WILLIAMS");
 
 -- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
 -- DESC address;
 CREATE TABLE IF NOT EXISTS address
 (
	address_id SMALLINT(5) UNSIGNED AUTO_INCREMENT NOT NULL,
    address VARCHAR(50) NOT NULL,
    address2 VARCHAR(50),
    district VARCHAR(20) NOT NULL,
    city_id SMALLINT(5) UNSIGNED NOT NULL, 
    postal_code VARCHAR(10),
    phone VARCHAR(20) NOT NULL,
    location GEOMETRY NOT NULL,
    last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY(city_id),
    SPATIAL KEY(location),
    PRIMARY KEY(address_id)
 );
 
 -- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
 
 SELECT s.first_name as `First Name`, s.last_name as `Last Name`, 
 CONCAT_WS(",", a.address, a.address2, district, c.city) as `Address`
 FROM staff as s
 INNER JOIN address as a ON s.address_id = a.address_id
 INNER JOIN city as c ON a.city_id = c.city_id;
 
 -- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
 -- SELECT * FROM payment;
 
 SELECT CONCAT_WS(" ",s.first_name, s.last_name) as `Staff`, SUM(p.amount) as `Total Amount`
 FROM payment as p
 INNER JOIN staff as s ON s.staff_id = p.staff_id
 WHERE p.payment_date BETWEEN DATE('2005-08-01 00:00:00') AND DATE('2005-08-31 11:59:59')
 GROUP BY p.staff_id;
 
 -- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film
 SELECT f.title as `Film`, COUNT(fa.actor_id) as `Num. of Actors`
 FROM film as f
 INNER JOIN film_actor as fa ON f.film_id = fa.film_id
 GROUP BY f.film_id;
 
 -- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
 SELECT f.title as Title, COUNT(i.film_id) as `# of Copies`
 FROM inventory as i
 INNER JOIN film as f ON i.film_id = f.film_id
 WHERE UCASE(title) = UCASE("Hunchback Impossible");
 -- GROUP BY f.title ORDER BY COUNT(i.film_id) DESC ;
 
 -- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
 -- List the customers alphabetically by last name:
 
 SELECT c.first_name as `First Name`, c.last_name as `Last Name`, SUM(p.amount) as `Total Amount Paid`
 FROM customer as c
 INNER JOIN payment as p ON c.customer_id = p.customer_id
 GROUP BY c.customer_id ORDER BY c.last_name;
 
 -- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence.
-- As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
 -- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
 

SELECT f.title as `Title` FROM film as f
WHERE language_id = (SELECT language_id FROM language WHERE UCASE(name) = UCASE("English")) AND 
(UCASE(f.title) LIKE UCASE("Q%") OR UCASE(f.title) LIKE UCASE("K%"));

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip

SELECT CONCAT_WS(" ",a.first_name, a.last_name) as `Actor Name`
FROM film_actor as fa
INNER JOIN actor as a ON fa.actor_id = a.actor_id
WHERE film_id = (SELECT film_id FROM film WHERE UCASE(title) = UCASE("Alone Trip"));

-- 7c. You want to run an email marketing campaign in Canada, 
-- for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.

SELECT 
	CONCAT_WS(" ", cust.first_name, cust.last_name) as `Customer Name`,
    cust.email as `Email Address`,
	ctry.country as `Country`
FROM 
	customer as cust
INNER JOIN address as a 
	ON cust.address_id = a.address_id
INNER JOIN city
	ON city.city_id = a.city_id
INNER JOIN country as ctry
	ON ctry.country_id = city.country_id
WHERE UCASE(ctry.country) = UCASE("Canada");

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films.

SELECT
	f.title as `Movie Name`,
    c.name as `Category`
FROM film as f
INNER JOIN film_category as fc
	ON f.film_id = fc.film_id
INNER JOIN category as c
	ON fc.category_id = c.category_id
WHERE UCASE(c.name) = UCASE("Family");

-- 7e. Display the most frequently rented movies in descending order.

SELECT
	f.title as `Movie`,
    COUNT(r.rental_id) as `Times Rented`
FROM rental as r
INNER JOIN inventory as i
	ON i.inventory_id = r.inventory_id
INNER JOIN film as f
	ON i.film_id = f.film_id
GROUP BY f.film_id
ORDER BY COUNT(r.rental_id) DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT
	str.store_id as `Store`,
    SUM(p.amount) as `Store Revenue ($)`
FROM store as str
INNER JOIN staff as stf 
	ON str.store_id = stf.store_id
INNER JOIN payment as p
	ON stf.staff_id = p.staff_id
GROUP BY str.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT
	s.store_id as `Store`,
    city.city as `City Name`,
    cntry.country as `Country`
FROM store as s
INNER JOIN address as a 
	ON a.address_id = s.address_id
INNER JOIN city
	ON city.city_id = a.city_id
INNER JOIN country as cntry
	ON cntry.country_id = city.country_id;
    
-- 7h. List the top five genres in gross revenue in descending order.
SELECT
	c.name as `Category`,
    SUM(p.amount) as `Total Revenue By Category`
FROM payment as p
INNER JOIN rental as r ON r.rental_id = p.rental_id
INNER JOIN inventory as i ON i.inventory_id = r.inventory_id
INNER JOIN film_category as fc ON fc.film_id = i.film_id
INNER JOIN category as c ON c.category_id = fc.category_id
GROUP BY c.name 
ORDER BY SUM(p.amount) DESC
LIMIT 5;

-- 8a Create view for top revenue category
CREATE OR REPLACE VIEW top_revenue_category
AS
SELECT
	c.name as `Category`,
    SUM(p.amount) as `Total Revenue By Category`
FROM payment as p
INNER JOIN rental as r ON r.rental_id = p.rental_id
INNER JOIN inventory as i ON i.inventory_id = r.inventory_id
INNER JOIN film_category as fc ON fc.film_id = i.film_id
INNER JOIN category as c ON c.category_id = fc.category_id
GROUP BY c.name 
ORDER BY SUM(p.amount) DESC LIMIT 5;

-- 8b. CHeck if VIEW works by using Select statement from VIEW
SELECT * FROM top_revenue_category;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW top_revenue_category; 

