use sakila;
#1 create a view
#create a view that summarizes rental information for each customer
#The view should include the customer's ID, name, email address, and total number of rentals (rental_count)

DROP VIEW IF EXISTS customer_rental_sum; #delete the view

CREATE VIEW customer_rental_sum AS #create view
SELECT #select info to display in the view
    c.customer_id,
    c.last_name,
    c.email,
    COUNT(r.rental_id) AS rental_count
FROM 
    customer c #select table containing customer info
LEFT JOIN 
    rental r ON c.customer_id = r.customer_id #joining tables to retrieve rental count
GROUP BY 
    c.customer_id, c.last_name, c.email;
    
SELECT * FROM customer_rental_sum; #display the (temporary) view

#2 Create a Temporary Table
# create a Temporary Table that calculates the total amount paid by each customer (total_paid)
# The Temporary Table should use the rental summary view created in Step 1 to join with the payment table and calculate the total amount paid by each customer.

CREATE TEMPORARY TABLE cust_total_paid AS #declare temporary table
SELECT #select columns
	c.customer_id,
    c.last_name,
    SUM(d.amount) AS total_paid
FROM #origin table
	customer_rental_sum c
JOIN #join with add table to retrieve payments
	payment d ON c.customer_id = d.customer_id
GROUP BY 
	c.customer_id, c.last_name;
    
SELECT * FROM cust_total_paid; #display the temporary table

#3 Create a CTE and the Customer Summary Report
# Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2
#The CTE should include the customer's name, email address, rental count, and total amount paid.
#Next, using the CTE, create the query to generate the final customer summary report, which should include
#customer name, email, rental_count, total_paid and average_payment_per_rental, this last column is a derived column from total_paid and rental_count.

WITH customer_summary_cte AS (
    SELECT r.last_name, r.rental_count, t.total_paid
    FROM customer_rental_sum r
    JOIN cust_total_paid t ON r.customer_id = t.customer_id )

SELECT c.last_name, c.rental_count, c.total_paid,
    CASE 
        WHEN c.rental_count > 0 THEN round(c.total_paid / c.rental_count,2)
        ELSE 0
    END AS average_payment_per_rental
FROM 
    customer_summary_cte c
ORDER BY average_payment_per_rental DESC
    

