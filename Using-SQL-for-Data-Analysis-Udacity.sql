/* Query 1 - Revenue Growth by Rep */

WITH t09 AS
  (SELECT e.firstname||" "||e.lastname sales_rep,
          strftime('%Y', i.invoicedate) YEAR,
                                        SUM(i.total) total
   FROM invoice i
   JOIN customer c ON i.customerid = c.customerid
   JOIN employee e ON c.supportrepid = e.employeeid
   GROUP BY 1,
            2
   HAVING strftime('%Y', i.invoicedate) = "2009"),
     t10 AS
  (SELECT e.firstname||" "||e.lastname sales_rep,
          strftime('%Y', i.invoicedate) YEAR,
                                        SUM(i.total) total
   FROM invoice i
   JOIN customer c ON i.customerid = c.customerid
   JOIN employee e ON c.supportrepid = e.employeeid
   GROUP BY 1,
            2
   HAVING strftime('%Y', i.invoicedate) = "2010"),
     t11 AS
  (SELECT e.firstname||" "||e.lastname sales_rep,
          strftime('%Y', i.invoicedate) YEAR,
                                        SUM(i.total) total
   FROM invoice i
   JOIN customer c ON i.customerid = c.customerid
   JOIN employee e ON c.supportrepid = e.employeeid
   GROUP BY 1,
            2
   HAVING strftime('%Y', i.invoicedate) = "2011"),
     t12 AS
  (SELECT e.firstname||" "||e.lastname sales_rep,
          strftime('%Y', i.invoicedate) YEAR,
                                        SUM(i.total) total
   FROM invoice i
   JOIN customer c ON i.customerid = c.customerid
   JOIN employee e ON c.supportrepid = e.employeeid
   GROUP BY 1,
            2
   HAVING strftime('%Y', i.invoicedate) = "2012"),
     t13 AS
  (SELECT e.firstname||" "||e.lastname sales_rep,
          strftime('%Y', i.invoicedate) YEAR,
                                        SUM(i.total) total
   FROM invoice i
   JOIN customer c ON i.customerid = c.customerid
   JOIN employee e ON c.supportrepid = e.employeeid
   GROUP BY 1,
            2
   HAVING strftime('%Y', i.invoicedate) = "2013")
SELECT t09.sales_rep,
       t09.total "2009",
       t10.total AS "2010",
       t11.total AS "2011",
       t12.total AS "2012",
       t13.total AS "2013"
FROM t09
JOIN t10 ON t09.sales_rep = t10.sales_rep
JOIN t11 ON t09.sales_rep = t11.sales_rep
JOIN t12 ON t09.sales_rep = t12.sales_rep
JOIN t13 ON t09.sales_rep = t13.sales_rep
ORDER BY 1;


/* Query 2 - sales by genre */
SELECT g.name genre_name,
       SUM(il.unitprice * il.quantity) total
FROM invoiceline il
JOIN track t ON il.trackid = t.trackid
JOIN genre g ON t.genreid = g.genreid
JOIN invoice i ON il.invoiceid = i.invoiceid
GROUP BY 1
ORDER BY 2 DESC;

/*Query 3 - Revenue Growth by Genre */
WITH t1 AS
  (SELECT strftime('%Y', i.invoicedate) AS YEAR,
          SUM(il.unitprice*il.quantity) rock
   FROM track t
   JOIN invoiceline il ON il.trackid = t.trackid
   JOIN invoice i ON i.invoiceid = il.invoiceid
   JOIN genre g ON t.genreid = g.genreid
   WHERE g.name = 'Rock'
   GROUP BY 1),
     t2 AS
  (SELECT strftime('%Y', i.invoicedate) AS YEAR,
          SUM(il.unitprice*il.quantity) latin
   FROM track t
   JOIN invoiceline il ON il.trackid = t.trackid
   JOIN invoice i ON i.invoiceid = il.invoiceid
   JOIN genre g ON t.genreid = g.genreid
   WHERE g.name = 'Latin'
   GROUP BY 1),
     t3 AS
  (SELECT strftime('%Y', i.invoicedate) AS YEAR,
          SUM(il.unitprice*il.quantity) metal
   FROM track t
   JOIN invoiceline il ON il.trackid = t.trackid
   JOIN invoice i ON i.invoiceid = il.invoiceid
   JOIN genre g ON t.genreid = g.genreid
   WHERE g.name = 'Metal'
   GROUP BY 1),
     t4 AS
  (SELECT strftime('%Y', i.invoicedate) AS YEAR,
          SUM(il.unitprice*il.quantity) alt_punk
   FROM track t
   JOIN invoiceline il ON il.trackid = t.trackid
   JOIN invoice i ON i.invoiceid = il.invoiceid
   JOIN genre g ON t.genreid = g.genreid
   WHERE g.name = 'Alternative & Punk'
   GROUP BY 1),
     t5 AS
  (SELECT strftime('%Y', i.invoicedate) AS YEAR,
          SUM(il.unitprice*il.quantity) tv_shows
   FROM track t
   JOIN invoiceline il ON il.trackid = t.trackid
   JOIN invoice i ON i.invoiceid = il.invoiceid
   JOIN genre g ON t.genreid = g.genreid
   WHERE g.name = 'TV Shows'
   GROUP BY 1),
t6 AS
  (SELECT strftime('%Y', i.invoicedate) AS YEAR,
          SUM(il.unitprice*il.quantity) jazz
   FROM track t
   JOIN invoiceline il ON il.trackid = t.trackid
   JOIN invoice i ON i.invoiceid = il.invoiceid
   JOIN genre g ON t.genreid = g.genreid
   WHERE g.name = 'Jazz'
   GROUP BY 1)
SELECT t1.year,
       t1.rock "Rock",
               t2.latin "Latin",
                        t3.metal "Metal",
                                 t4.alt_punk "Alternative & Punk",
                                             t5.tv_shows "TV Shows", t6.jazz "Jazz"
FROM t1
JOIN t2 ON t1.year = t2.year
JOIN t3 ON t1.year = t3.year
JOIN t4 ON t1.year = t4.year
JOIN t5 ON t1.year = t5.year
LEFT JOIN t6 ON t1.year = t6.year



/* Query 4- 2013 revenue by sales rep and genre */ WITH t1 AS
  (SELECT DISTINCT g.name AS genre,
                   SUM(il.unitprice*il.quantity) AS annual_total
   FROM genre g
   JOIN track t ON g.genreid = t.genreid
   JOIN invoiceline il ON t.trackid = il.trackid
   GROUP BY 1),
                                                        t2 AS
  (SELECT e.firstname||" "||e.lastname AS sales_rep,
          g.name AS genre,
          strftime('%Y', i.invoicedate) AS YEAR,
          SUM(il.unitprice*il.quantity) AS total
   FROM invoice i
   JOIN invoiceline il ON i.invoiceid = il.invoiceid
   JOIN track t ON t.trackid = il.trackid
   JOIN genre g ON t.genreid = g.genreid
   JOIN customer c ON i.customerid = c.customerid
   JOIN employee e ON c.supportrepid = e.employeeid
   WHERE strftime('%Y', i.invoicedate) = '2013'
     AND e.firstname||" "||e.lastname = 'Steve Johnson'
   GROUP BY 1,
            2,
            3
   ORDER BY 4 DESC
   LIMIT 5),
                                                        t3 AS
  (SELECT e.firstname||" "||e.lastname AS sales_rep,
          g.name AS genre,
          strftime('%Y', i.invoicedate) AS YEAR,
          SUM(il.unitprice*il.quantity) AS total
   FROM invoice i
   JOIN invoiceline il ON i.invoiceid = il.invoiceid
   JOIN track t ON t.trackid = il.trackid
   JOIN genre g ON t.genreid = g.genreid
   JOIN customer c ON i.customerid = c.customerid
   JOIN employee e ON c.supportrepid = e.employeeid
   WHERE strftime('%Y', i.invoicedate) = '2013'
     AND e.firstname||" "||e.lastname = 'Jane Peacock'
   GROUP BY 1,
            2,
            3
   ORDER BY 4 DESC
   LIMIT 5),
                                                        t4 AS
  (SELECT e.firstname||" "||e.lastname AS sales_rep,
          g.name AS genre,
          strftime('%Y', i.invoicedate) AS YEAR,
          SUM(il.unitprice*il.quantity) AS total
   FROM invoice i
   JOIN invoiceline il ON i.invoiceid = il.invoiceid
   JOIN track t ON t.trackid = il.trackid
   JOIN genre g ON t.genreid = g.genreid
   JOIN customer c ON i.customerid = c.customerid
   JOIN employee e ON c.supportrepid = e.employeeid
   WHERE strftime('%Y', i.invoicedate) = '2013'
     AND e.firstname||" "||e.lastname = 'Margaret Park'
   GROUP BY 1,
            2,
            3
   ORDER BY 4 DESC
   LIMIT 5)
SELECT t1.genre AS "Genre",
       t2.total AS "Steve Johnson",
       t3.total AS "Jane Peacock",
       t4.total AS "Margaret Park"
FROM t1
LEFT JOIN t2 ON t1.genre = t2.genre
LEFT JOIN t3 ON t1.genre = t3.genre
LEFT JOIN t4 ON t1.genre = t4.genre
WHERE t2.total IS NOT NULL
  OR t3.total IS NOT NULL
  OR t4.total IS NOT NULL
ORDER BY t1.annual_total DESC