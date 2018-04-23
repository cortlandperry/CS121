-- [Problem 1.4a]
WITH max AS (SELECT artist_name, COUNT(*) as requests FROM
	(playlist JOIN song USING (audio_id) JOIN song_artists USING (audio_id) JOIN artist USING (artist_id)) 
    WHERE is_request GROUP BY artist_name)
    SELECT artist_name, requests FROM max WHERE requests = (SELECT MAX(requests) FROM max);
    
-- [Problem 1.4b]
SELECT company_name, SUM(price) as total_amount FROM 
	playlist JOIN ads USING(audio_id) JOIN company USING (company_id)
    GROUP BY company_name ORDER BY total_amount DESC;

