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
 
 select count(*) from payment;