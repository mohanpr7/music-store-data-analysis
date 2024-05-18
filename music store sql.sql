--Q1: who is the senior most employee based on job title?

select top 1 * from employee
order by levels desc

--Q2: which countries have the most invoices?

select count(*) as counts, billing_country  from invoice
group by billing_country
order by counts desc

--Q3: what are top 3 values of total invoice

select top 3 total from invoice 
order by total desc

--Q4: which city has best customers? we would like to throw a promotional music festival in the city we made the most money.
--Write a query that returns one city that has hihgest sum of invoice totals.
--Return both the city name and sum of all invoice totlas.

select sum(total) as invoice_total, billing_city from invoice 
group by billing_city 
order by invoice_total desc

--Q5: who is the best customer? The customer who has spent the most money will be declared the best customer.
--Write a query that returns the person who has spent the most money.

select top 1 customer.customer_id, customer.first_name, customer.last_name, sum(invoice.total) as total 
from customer
join invoice on customer.customer_id=invoice.customer_id
group by customer.customer_id , customer.first_name, customer.last_name
order by total desc

--Q6 Write a query to return the email, first name, last name, and genre of all Rock music listeners .
--Return your list ordered alphabetically by email starting with A

select distinct email, first_name,last_name 
from customer
join invoice on customer.customer_id=invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
where track_id IN( 
      select track_id from track 
	  join genre on track.genre_id = genre.genre_id
	  where genre.name like 'Rock'
	  )
order by email

--Q7  Let's invite the artists who have written the mock rock music in our dataset. 
-- Write a query that returns the artist name and total track count of the top 10 rock bands

select  top 10 artist.artist_id, artist.name, count(artist.artist_id) as no_of_songs
from track
join album on album.album_id = track.album_id
join artist on artist.artist_id = album.artist_id
join genre on genre.genre_id=track.genre_id
where genre.name like 'Rock'
group by artist.artist_id, artist.name
order by no_of_songs desc

--Q8 Return all the track names that have a song length than average song length. 
--Return the name and milliseconds for each track. Order by the song length with the longest songs listed first

select name, milliseconds from track
where milliseconds > (
      select AVG(milliseconds) as avg_length from track)
order by milliseconds desc;

--Q9  find how much amount sepnt by each customer on artists? write a query to return customer name, artist name and total spent  

with best_selling_artist as(
     select top 1 artist.artist_id as artist_id, artist.name as artist_name,
	 sum(invoice_line.unit_price*invoice_line.quantity) as total_sales
	 from invoice_line 
	 join track on track.track_id = invoice_line.track_id
	 join album on album.album_id = track.album_id
	 join artist on artist.artist_id = album.artist_id
	 group by artist.artist_id , artist.name
	 order by 3 desc
)
select c.customer_id, c.first_name, c.last_name, bsa.artist_name, sum(il.unit_price*il.quantity) as amount_spent 
from invoice i
join customer c on c.customer_id = i.customer_id
join invoice_line il on il.invoice_id = i.invoice_id
join track t on t.track_id = i.invoice_id 
join album alb on alb.album_id = t.album_id
join best_selling_artist bsa on bsa.artist_id = alb.artist_id
group by  c.customer_id, c.first_name, c.last_name, bsa.artist_name
order by 5 desc

--Q10 We want to find out the most popular music genre for each country. 
--We determine the most popular genre as the genre with the highest amount of purchases.
--write a query that returns each country along with the top genre. for countries where maximum number of purchases is shared return all genres.


with popular_genre as (
     select count(invoice_line.quantity) as purchases, customer.country, genre.name, genre.genre_id,
	 row_number() over(partition by customer.country order by count(invoice_line.quantity) desc) as rowno
	 from invoice_line
	 join invoice on invoice.invoice_id = invoice_line.invoice_id
	 join customer on customer.customer_id = invoice.customer_id
	 join track on track.track_id = invoice_line.track_id
	 join genre on genre.genre_id = track.genre_id
	 group by customer.country, genre.name, genre.genre_id
	 )
SELECT *
FROM popular_genre
WHERE rowno <= 1;


--Q11 write a query that determines the customer that has spent the most on music for each country. 
--write a query that returns the country along with the top customer and how much they spent.
-- for countries where the top amount shared, provide all customers who spent this amount.

WITH customer_with_country as (
     select customer.customer_id, first_name, last_name, billing_country, sum(total) as total_spending, 
	 row_number() over(partition by billing_country order by sum(total) desc)as rowno
	 from invoice
	 join customer on customer.customer_id = invoice.customer_id
	 group by customer.customer_id, first_name, last_name, billing_country
	
	 )
select * from customer_with_country where rowno<=1
	
