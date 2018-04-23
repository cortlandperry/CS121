-- [Problem 6a]
WITH cust_stuff AS 
(SELECT ticket.ticket_id
FROM (purchaser NATURAL JOIN purchaser_purchase NATURAL JOIN purchase NATURAL JOIN ticket)
 WHERE purchaser.cust_id = 54321)

	SELECT time_occur, f_date, f_source, destination, last_name,
    first_name, flight_num, seat_no, seat_type, class, ticket_id
    FROM (purchase NATURAL JOIN purchaser_purchase NATURAL JOIN purchaser NATURAL JOIN
    a_customer NATURAL JOIN traveler NATURAL JOIN ticket NATURAL JOIN tickets_flights NATURAL JOIN
    seat NATURAL JOIN flight NATURAL JOIN airplane)
    WHERE ticket.ticket_id IN (SELECT * FROM cust_stuff)
    ORDER BY time_occur DESC, f_date ASC, last_name ASC, first_name ASC, 
    f_source ASC, destination ASC, flight_num ASC, seat_no ASC, seat_type ASC, 
    class ASC, ticket_id ASC; 


-- [Problem 6b]
SELECT airplane.IATA, SUM(sale_price) as total_revenue FROM (ticket NATURAL JOIN tickets_flights 
	NATURAL JOIN flight NATURAL JOIN airplane )
    WHERE TIMESTAMP(flight.f_date, flight.f_time) BETWEEN CURRENT_TIMESTAMP - INTERVAL 2 WEEK AND CURRENT_TIMESTAMP
    GROUP BY airplane.IATA;

-- [Problem 6c]
SELECT first_name, last_name 
	FROM a_customer NATURAL JOIN traveler 
    WHERE passport_num IS NULL
    OR emer_contact IS NULL
    OR emer_phone IS NULL
    OR citizenship IS NULL;


