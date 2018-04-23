-- [Problem 2a]
SELECT COUNT(*) FROM raw_web_log;

-- [Problem 2b]
SELECT ip_addr, COUNT(*) as request_counts FROM raw_web_log 
	GROUP BY ip_addr ORDER BY  request_counts DESC LIMIT 20;

-- [Problem 2c]
SELECT resource, COUNT(*) as total_requests, SUM(bytes_sent) as total_bytes FROM raw_web_log
	GROUP BY resource ORDER BY total_bytes DESC LIMIT 20;

-- [Problem 2d]
SELECT visit_val, ip_addr, COUNT(*) as total_requests, MIN(logtime) as start_time, MAX(logtime) as end_time
	FROM raw_web_log GROUP BY visit_val, ip_addr ORDER BY total_requests DESC LIMIT 20;

