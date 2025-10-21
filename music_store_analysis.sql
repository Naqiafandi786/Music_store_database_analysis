/* QUESTIONS SET 1 - EASY */

/* Q1: Which countries have the most Invoices? */

SELECT COUNT(*) AS c, billing_country 
FROM invoice
GROUP BY billing_country
ORDER BY c DESC 


/* Q3: What are top 3 values of total invoice? */

SELECT total 
FROM invoice
ORDER BY total DESC


/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals*/

SELECT billing_city,SUM(total) AS InvoiceTotal
FROM invoice
GROUP BY billing_city
ORDER BY InvoiceTotal DESC
LIMIT 1;

/* Question Set 2 - Moderate */

/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

SELECT DISTINCT email AS Email,first_name AS FirstName, last_name AS LastName, genre.name AS Name
FROM customer
JOIN invoice ON invoice.customer_id = customer.customer_id
JOIN invoiceline ON invoiceline.invoice_id = invoice.invoice_id
JOIN track ON track.track_id = invoiceline.track_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
ORDER BY email;

/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

SELECT name,miliseconds
FROM track
WHERE miliseconds > (
	SELECT AVG(miliseconds) AS avg_track_length
	FROM track )
ORDER BY miliseconds DESC;

/* Question Set 3 - Advance */

/* Q1: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

sales_per_country AS(
		SELECT COUNT(*) AS purchases_per_genre, customer.country, genre.name, genre.genre_id
		FROM invoice_line
		JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
		JOIN customer ON customer.customer_id = invoice.customer_id
		JOIN track ON track.track_id = invoice_line.track_id
		JOIN genre ON genre.genre_id = track.genre_id
		GROUP BY 2,3,4
		ORDER BY 2
	),
	max_genre_per_country AS (SELECT MAX(purchases_per_genre) AS max_genre_number, country
		FROM sales_per_country
		GROUP BY 2
		ORDER BY 2)

SELECT sales_per_country.* 
FROM sales_per_country
JOIN max_genre_per_country ON sales_per_country.country = max_genre_per_country.country
WHERE sales_per_country.purchases_per_genre = max_genre_per_country.max_genre_number;

/* Q2: Which artist generated the highest total revenue, and what were their top 3 best-selling tracks? */

-- Step 1: Find total revenue per artist
WITH artist_revenue AS (
    SELECT 
        ar.artist_id,
        ar.name AS artist_name,
        SUM(il.unit_price * il.quantity) AS total_revenue
    FROM artist ar
    JOIN album a ON ar.artist_id = a.artist_id
    JOIN track t ON a.album_id = t.album_id
    JOIN invoice_line il ON t.track_id = il.track_id
    GROUP BY ar.artist_id
),
-- Step 2: Find top 3 tracks for the highest-grossing artist
top_tracks AS (
    SELECT 
        t.name AS track_name,
        SUM(il.unit_price * il.quantity) AS track_revenue,
        a.artist_id
    FROM track t
    JOIN album al ON t.album_id = al.album_id
    JOIN artist a ON al.artist_id = a.artist_id
    JOIN invoice_line il ON t.track_id = il.track_id
    WHERE a.artist_id = (
        SELECT artist_id FROM artist_revenue
        ORDER BY total_revenue DESC
        LIMIT 1
    )
    GROUP BY t.track_id, a.artist_id
    ORDER BY track_revenue DESC
    LIMIT 3
)
-- Step 3: Show results
SELECT ar.artist_name, ar.total_revenue, tt.track_name, tt.track_revenue
FROM artist_revenue ar
JOIN top_tracks tt ON ar.artist_id = tt.artist_id
WHERE ar.artist_id = (
    SELECT artist_id FROM artist_revenue
    ORDER BY total_revenue DESC
    LIMIT 1
);
