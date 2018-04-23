-- [Problem a]
/*
This query selects all the customer names in the customer_name query,
and then the amount of loans that each customer in customer_names 
has borrowed from the bank, and then organizes the names in decreasing
order of all their nodes.
*/
 
 /* 
 Original Query:
 SELECT customer_name,
             (SELECT COUNT(*) FROM borrower b
              WHERE b.customer_name = c.customer_name) AS num_loans
      FROM customer c ORDER BY num_loans DESC;
*/

SELECT customer_name, COUNT(loan_number) AS num_loans
	FROM (customer NATURAL LEFT JOIN borrower)
    GROUP BY customer_name
    ORDER BY num_loans DESC;
    


-- [Problem b]
/*
This query selects the branch_names of the branches that have less assests
currently in their branch than one loan to their branch owes them.
*/
/*

SELECT branch_name FROM branch b
      WHERE assets < (SELECT SUM(amount) FROM loan l
                      WHERE l.branch_name = b.branch_name);
*/

SELECT branch_name
	FROM (branch NATURAL LEFT JOIN loan)
	GROUP BY branch.branch_name, assets
    HAVING assets < SUM(amount);


-- [Problem c]
SELECT branch_name, 
	(SELECT COUNT(account_number) FROM account a WHERE a.branch_name = b.branch_name) as num_accounts,
	(SELECT COUNT(loan_number) FROM loan l WHERE l.branch_name = b.branch_name) as num_loans
	FROM branch as b;
    
-- [Problem d]
/* This query is not correlated because the subquery in our statement
does not rely on any information from the outer query
*/

SELECT branch_name, COUNT(account_number) AS num_accounts, num_loans
	FROM 
    (SELECT branch_name, COUNT(loan_number) AS num_loans 
    FROM (branch NATURAL LEFT JOIN loan) 
    GROUP BY branch_name) as loan_part NATURAL JOIN account
    GROUP BY branch_name, num_loans;
    


