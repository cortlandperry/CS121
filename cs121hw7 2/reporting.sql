-- [Problem 6a]
SELECT protocol, COUNT(*) as total_requests
	FROM resource_dim NATURAL JOIN resource_fact
    GROUP BY protocol
    HAVING protocol IS NOT NULL
    ORDER BY total_requests DESC
    LIMIT 10;


-- [Problem 6b]
SELECT resource, response, COUNT(*) as error_count
	FROM resource_dim NATURAL JOIN resource_fact
    GROUP BY resource, response
    HAVING response >= 400
    ORDER BY error_count DESC
    LIMIT 20;


-- [Problem 6c]
SELECT ip_addr, COUNT(DISTINCT(visit_val)) as number_visits, SUM(num_requests) as total_requests, SUM(total_bytes) as total_bytes_sent
	FROM visitor_dim NATURAL JOIN visitor_fact
    GROUP BY ip_addr
    ORDER BY total_bytes_sent DESC
    LIMIT 20;

-- [Problem 6d]
SELECT date_val, IFNULL(SUM(num_requests),0) as total_requests, IFNULL(SUM(total_bytes),0) as total_bytes_sent
	FROM datetime_dim LEFT OUTER JOIN visitor_fact USING (date_id)
    GROUP BY date_val
    HAVING date_val BETWEEN '1995-07-23' AND '1995-08-12';

-- On August 2nd, it makes sense that the web is shut down because there was a hurricane and they shut down the Web server
-- We don't have an explanation for the other gap in service.
 
-- [Problem 6e]
SELECT * FROM datetime_dim NATURAL JOIN visitor_fact NATURAL JOIN visitor_dim;

SELECT date_val, resource, SUM(num_requests), MAX

WITH a AS (SELECT date_val, resource, SUM(num_requests) as daily_num_requests, SUM(total_bytes) as daily_total_bytes
	FROM datetime_dim NATURAL JOIN resource_fact NATURAL JOIN resource_dim 
    GROUP BY date_val, resource) 
    SELECT * FROM a NATURAL JOIN (SELECT date_val, MAX(daily_total_bytes) as daily_total_bytes FROM
    a GROUP BY date_val) as b ORDER BY date_val ASC;



-- [Problem 6f]
/** 
Most People didn't have internet at home, which means that they would need to be at work or
at a public area in order to use the internet. This is why on the weekdays there are far more uses,
because it is more likely that people will be using the internet at their work during the week than on the weekend.
This is the same as during the day as well.
**/

WITH weeknd AS (
SELECT hour_val, COUNT(DISTINCT(visit_val))/COUNT(DISTINCT(date_val)) as avg_weekend_visits
	FROM (datetime_dim NATURAL JOIN visitor_fact) NATURAL JOIN visitor_dim
    WHERE is_weekend(date_val)
	GROUP BY hour_val)
SELECT * FROM weeknd JOIN (SELECT hour_val, COUNT(DISTINCT(visit_val))/COUNT(DISTINCT(date_val)) as avg_weekday_visits
	FROM (datetime_dim NATURAL JOIN visitor_fact) NATURAL JOIN visitor_dim
    WHERE is_weekend(date_val) = FALSE
	GROUP BY hour_val) AS b USING (hour_val);




