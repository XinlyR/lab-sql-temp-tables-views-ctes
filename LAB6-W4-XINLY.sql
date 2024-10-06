#Step 1: Create a View
#First, create a view that summarizes rental information for each customer. 
#The view should include the customer's ID, name, email address, and total number of rentals (rental_count).
DROP VIEW IF EXISTS sakila.count_rental;
CREATE VIEW sakila.count_rental AS (
SELECT  c.customer_id, CONCAT(c.first_name,' ',c.last_name) AS customer_name ,c.email, COUNT(r.rental_id) AS rental_count
FROM sakila.customer AS c
JOIN sakila.rental AS r
ON c.customer_id=r.customer_id
GROUP BY c.customer_id);
SELECT * FROM sakila.count_rental;

#Step 2: Create a Temporary Table
#Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid). 
#The Temporary Table should use the rental summary view created in Step 1 to join with the payment table 
#and calculate the total amount paid by each customer.
DROP TABLE IF EXISTS sakila.sum_rental;
CREATE TEMPORARY TABLE sakila.sum_rental 
SELECT  c.customer_id, SUM(p.amount) AS total_paid
FROM sakila.count_rental AS c
JOIN sakila.rental AS r
ON c.customer_id=r.customer_id
JOIN sakila.payment AS p
ON r.rental_id=p.rental_id
GROUP BY c.customer_id ;
SELECT * FROM sakila.sum_rental;


#Step 3: Create a CTE and the Customer Summary Report
#Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created 
#in Step 2. The CTE should include the customer's name, email address, rental count, and total amount paid.
#Next, using the CTE, create the query to generate the final customer summary report, 
#which should include: customer name, email, rental_count, total_paid and average_payment_per_rental, 
#this last column is a derived column from total_paid and rental_count.
WITH cte_report AS (
  SELECT cr.customer_name, cr.email, cr.rental_count, sr.total_paid
	FROM sakila.count_rental AS cr
	JOIN sakila.sum_rental AS sr
	ON cr.customer_id = sr.customer_id)
    SELECT *, total_paid/rental_count AS average_payment_per_rental
    FROM cte_report
    ORDER BY rental_count DESC;



