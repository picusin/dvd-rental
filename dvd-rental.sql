/* UDACITY COURSE - PROJECT 01 - SQL */

/* QUESTION 1:
  I'd like to know the cost of a campaign aiming to increase the number of rentals. The campaign consists in a fidelity card that keeps
  track of every customer rentals and offers a free rental after X rentals.

  First, I need to know the total number of rentals per customer in the period stored in the database, to find a reasonable number of rentals (X).*/

SELECT c.customer_id,
      COUNT (*)
FROM rental r
JOIN customer c
ON r.customer_id = c.customer_id
GROUP BY 1
ORDER BY 2 DESC;

/* The number of rentals per customer goes from 12 to 46 for the total period in the database.
However, I need to look carefully at the rental period stored in the database: */

SELECT DATE_TRUNC ('day', rental_date) AS rental_day,
	   COUNT (*)
FROM rental
GROUP BY 1
ORDER BY 1;

/* I can see the earliest date stored is 2005.05.24 and the latest is 2006.02.14.
But there are lots of gaps between dates, in fact it seems the data has been collected
on specific weeks, leaving other weeks without any data.
In order to make the cost estimation reasonable, it has to refer to a specific period
of time. I will then use 4 full weeks from the database, and assume that'd be the
monthly cost of a campaign. I'm aware this is a bit of a simplification, but I'll
use this scenario for the purpose of the exercise. */

SELECT c.customer_id,
      COUNT (*)
FROM rental r
JOIN customer c
ON r.customer_id = c.customer_id
WHERE r.rental_date BETWEEN '2005-05-24' AND '2005-08-03'
GROUP BY 1
ORDER BY 2 DESC;

/* In these four weeks the number of rentals per customer goes from 8 to 33.
I'll estimate a campaign giving a free rental for every 10 rentals. */

/* The second thing I want to know is the average cost of a rental. Rental prices vary depending
on the object that's rented and the duration of the rental. To simplify the cost, I'll use the
average rental cost */

SELECT c.customer_id,
AVG(p.amount) AS average_rental_cost
FROM payment p
JOIN customer c
ON p.customer_id = c.customer_id
GROUP BY 1
ORDER BY 1;

/* The base table that I'll use as a subquery to calculate the total number of free rentals to
offer is this */

SELECT c.customer_id,
	  CONCAT (c.first_name, ' ', c.last_name) AS full_name,
      COUNT (*) AS number_of_rentals,
	  CAST (CAST (COUNT (*) AS DECIMAL(5,1))/10 AS DECIMAL (5,1)) AS free_rentals
FROM rental r
JOIN customer c
ON r.customer_id = c.customer_id
WHERE r.rental_date BETWEEN '2005-05-24' AND '2005-08-03'
GROUP BY 1, 2
ORDER BY 3 DESC;

/* I needed to use CAST twice here to get the right decimal format, not sure why
it didn't work with just one. Please provide feedback if possible. */


/* This final query provides the estimated monthly cost for the campaign, calculated as the value of
all the free rentals offered over four weeks using an average value equal to the average value of all the
rentals in the databae */

WITH t1 AS (SELECT c.customer_id,
        	  CONCAT (c.first_name, ' ', c.last_name) AS full_name,
              COUNT (*) AS number_of_rentals,
        	  CAST (CAST (COUNT (*) AS DECIMAL(5,1))/10 AS DECIMAL (5,1)) AS monthly_free_rentals
            FROM rental r
            JOIN customer c
            ON r.customer_id = c.customer_id
            WHERE r.rental_date BETWEEN '2005-05-24' AND '2005-08-03'
            GROUP BY 1, 2),

t2 AS (SELECT c.customer_id,
      AVG(p.amount) AS average_rental_cost
      FROM payment p
      JOIN customer c
      ON p.customer_id = c.customer_id
      GROUP BY 1)

SELECT CAST(SUM(t1.monthly_free_rentals)*AVG(t2.average_rental_cost) AS INTEGER) AS monthly_campaign_cost_USD
FROM t1
JOIN t2
ON t1.customer_id = t2.customer_id;

/* The result is US$ 4822, which would be the value of all the free rentals offered in
a four week period (month). */




/* QUESTION 2:
The next thing I want to know is when would be the best time of the year to
launch this campaign. I'd like to know at what time of the year the rentals tend to go
down, and that'd be the time when I'd launch the campaign to motivate the customers.
However, given the limited database not providing data for a full year, I'm aware
it won't be possible to get a clear picture. I will anyways write a query that
would allow me to get that information when more data gets collected over time.
Since using JOIN is mandatoty for the exercise, I will use the payment amount instead
of the rental number as the variable to assess the trend over time */

/*I will first group the rental_date data by week*/

SELECT r.rental_id, r.rental_date, p.amount,
      CASE WHEN r.rental_date < '2005-06-01' THEN 'Week 1'
           WHEN r.rental_date < '2005-06-22' THEN 'Week 2'
           WHEN r.rental_date < '2005-07-13' THEN 'Week 3'
           WHEN r.rental_date < '2005-08-03' THEN 'Week 4'
           WHEN r.rental_date < '2005-08-24' THEN 'Week 5' END AS week
FROM rental r
LEFT JOIN payment p
ON p.rental_id = r.rental_id
ORDER BY 2;

/* There are null values given for the rentals taking place in 2006, but
that's ok, I want to leave those out as there isn't data for a full week.
I also see that all the rentals in week 1 have a null value for the amount.
Other rentals in the other weeks also have a null value, maybe because they never
got paid for? I will ignore this fact and proceed only with weeks 2 to 5 */


/*Now I want to calculare the difference between one week and the previous one
to see if the rental payment amounts increase or decrease.*/


WITH t1 AS (SELECT r.rental_id, r.rental_date, p.amount,
      CASE WHEN r.rental_date > '2005-06-13' AND r.rental_date < '2005-06-22' THEN 'Week 2'
           WHEN r.rental_date < '2005-07-13' THEN 'Week 3'
           WHEN r.rental_date < '2005-08-03' THEN 'Week 4'
           WHEN r.rental_date < '2005-08-24' THEN 'Week 5' END AS week
FROM rental r
JOIN payment p
ON p.rental_id = r.rental_id
WHERE r.rental_date < '2005-08-24'
ORDER BY 2)

SELECT week, SUM(t1.amount) AS weekly_income_USD,
       SUM(t1.amount) - (LAG(SUM(t1.amount)) OVER (ORDER BY week)) AS variation_USD
FROM t1
GROUP BY 1
ORDER BY 1;

/*I see in the results that by Week 5 the amount starts decreasing, breaking the
previous positive trend, so it'd be a good time to launch the cmapaign.*/


/* QUESTION 3: I noticed in the previous question that many rentals had a null
value for payment. I'll assume those rentals never got paid and will
calculate the total debt that all customers have with the company,
using again an average amount based on the registered payments.
I also want to know which of the two staff members got more unpaid rentals */

WITH t1 AS (SELECT s.staff_id AS staff_id, CONCAT (s.first_name, ' ', s.last_name) AS Full_name, COUNT(*) AS number_of_unpaid_rentals
            FROM rental r
            LEFT JOIN payment p
            ON p.rental_id = r.rental_id
            JOIN staff s
            ON r.staff_id = s.staff_id
            WHERE p.amount IS NULL
			      GROUP BY 1,2),

t2 AS (SELECT r.staff_id,
      p.amount AS rental_amount
      FROM payment p
      JOIN rental r
      ON p.rental_id = r.rental_id)

SELECT t1.staff_id, t1.full_name,
       t1.number_of_unpaid_rentals,
	   CAST (t1.number_of_unpaid_rentals * AVG(t2.rental_amount) AS INTEGER) AS unpaid_amount_USD
FROM t1
JOIN t2
ON t1.staff_id = t2.staff_id
GROUP BY 1,2,3;



/* QUESTION 4: I want to rank the actors by the income they generate and assign
them a number of stars from 1 to 5 based on this generated income.*/

SELECT actor_id, actor_name, revenue_generated,
       NTILE(5) OVER (ORDER BY revenue_generated) AS Stars
FROM (SELECT a.actor_id AS actor_id,
       CONCAT (a.last_name, ', ',a.first_name) AS actor_name,
       SUM(p.amount) AS revenue_generated
      FROM actor a
      JOIN film_actor fa
      ON fa.actor_id = a.actor_id
      JOIN film f
      ON fa.film_id = f.film_id
      JOIN inventory i
      ON i.film_id = f.film_id
      JOIN rental r
      ON r.inventory_id = i.inventory_id
      JOIN payment p
      ON p.rental_id = r.rental_id
      GROUP BY 1, 2) AS sub
ORDER BY 2;
