-- [Problem 2a]
DROP PROCEDURE IF EXISTS sp_compute_shortest_paths;

DELIMITER !
/*
This procedure will take all pairings of nodes in our graph, and determine the weight of the shortest path
between the two verticies, and then it will insert these pairings into our table called shortest_paths
*/
CREATE PROCEDURE sp_compute_shortest_paths()
BEGIN
	DECLARE node_size INTEGER;
    DECLARE counter1 INTEGER DEFAULT 1;
    DECLARE counter2 INTEGER DEFAULT 1;
    DECLARE counter3 INTEGER DEFAULT 1;
    DECLARE distance1 INTEGER;
    DECLARE distance2 INTEGER;
    DECLARE distance3 INTEGER;
    DECLARE edge_size INTEGER;
	DELETE FROM shortest_paths;
    
    SELECT COUNT(*) FROM nodes INTO node_size;
    SELECT COUNT(*) FROM node_adjacency INTO edge_size;
    
    -- First, we insert all the trivial conditions. First, if it goes to itself.
    REPEAT
		INSERT INTO shortest_paths VALUES (counter1, counter1, 0);
        SET counter1 = counter1 + 1;
    UNTIL counter1 = node_size + 1 END REPEAT;
    
    -- reset our counter
    SET counter1 = 1;
    
    -- Now any edge pairing in node_adjacency, we will set that as the minimal path length
    -- so we just insert all values from our adjacency mapping into shortest_paths
    -- if there are faster ways to get there, we will account for that later
	INSERT INTO shortest_paths SELECT * FROM node_adjacency;
	
    
    -- Now we fill in the rest of the distances, and we do this by checking if we have two nodes that together give us a shorter route than
    -- we found originally, for every single set of nodes in the entire data set. We compute the paths in order of how long in terms of nodes passed 
    -- they are, which is represented by counter3
    REPEAT
		REPEAT
			REPEAT
				-- we select the distances from the 3 nodes that we are looking at 
				SELECT total_distance FROM shortest_paths WHERE from_node_id = counter1 AND to_node_id = counter2 INTO distance1;
				SELECT total_distance FROM shortest_paths WHERE from_node_id = counter1 AND to_node_id = counter3 INTO distance2;
                SELECT total_distance FROM shortest_paths WHERE from_node_id = counter3 AND to_node_id = counter2 INTO distance3;
                
                
                -- if the two path distance is less than the value we already had, or if we had no value, we will
                -- update and change our array so that the distance between the two nodes of
                -- interest is equal to the distance between the routes of two nodes
                IF distance1 > distance2 + distance3 THEN
					INSERT INTO shortest_paths VALUES(counter1, counter2, (distance2 + distance3)) 
						ON DUPLICATE KEY UPDATE total_distance = distance2 + distance3;
                ELSEIF distance1 IS NULL AND (distance2 + distance3) IS NOT NULL THEN
					INSERT INTO shortest_paths VALUES(counter1, counter2, (distance2 + distance3));
                END IF;
                
                SET counter1 = counter1 + 1;
                
                -- need to set distances to null, so that there are no accidental double-checks
                SET distance1 = NULL;
				SET distance2 = NULL;
                SET distance3 = NULL;
            UNTIL counter1 = node_size + 1 END REPEAT;
				SET counter1 = 1;
                SET counter2 = counter2 + 1;
		UNTIL counter2 = node_size + 1 END REPEAT;
			SET counter2 = 1;
            SET counter3 = counter3 + 1;
	UNTIL counter3 = node_size + 1 END REPEAT;
    
END !

DELIMITER ;

CALL sp_compute_shortest_paths();

SELECT * FROM shortest_paths;

-- [Problem 2b]
SELECT from_node_id, node_name, SUM(1/(total_distance))/(COUNT(*)-1) as centrality
	FROM nodes JOIN shortest_paths ON nodes.node_id = shortest_paths.from_node_id
    GROUP BY from_node_id, node_name ORDER BY centrality DESC LIMIT 5;


