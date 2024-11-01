Create Database credit_analysis;
use credit_analysis;
select * from Accounts;
select * from Customers;
select * from credit_history;
select * from transactions;
select * from fraud_records;

-- Monthly transaction totals and outlier detection based on spending
SELECT 
    c.customer_id,
    YEAR(t.transaction_date) AS year,
    MONTH(t.transaction_date) AS month,
    SUM(t.transaction_amount) AS total_spent,
    AVG(t.transaction_amount) AS avg_transaction_amount,
    MAX(t.transaction_amount) AS max_transaction_amount
FROM 
    Transactions t
JOIN 
    Customers c ON t.customer_id = c.customer_id
GROUP BY 
    c.customer_id, YEAR(t.transaction_date), MONTH(t.transaction_date)
HAVING 
    MAX(t.transaction_amount) > AVG(t.transaction_amount) * 3;  -- Outlier threshold as 3x average

-- Daily and weekly average transaction amounts
SELECT 
    c.customer_id,
    DATE(t.transaction_date) AS transaction_day,
    WEEK(t.transaction_date) AS transaction_week,
    AVG(t.transaction_amount) AS avg_daily_transaction_amount,
    AVG(t.transaction_amount) OVER (PARTITION BY c.customer_id, WEEK(t.transaction_date)) AS avg_weekly_transaction_amount
FROM 
    Transactions t
JOIN 
    Customers c ON t.customer_id = c.customer_id
GROUP BY 
    c.customer_id, DATE(t.transaction_date), WEEK(t.transaction_date);
   
   
   -- Checking if transactions happen in the customer’s registered state/city
SELECT 
    c.customer_id,
    t.transaction_id,
    t.transaction_city,
    t.transaction_state,
    CASE 
        WHEN c.city = t.transaction_city AND c.state = t.transaction_state THEN 'Consistent'
        ELSE 'Inconsistent'
    END AS location_consistency
FROM 
    Transactions t
JOIN 
    Customers c ON t.customer_id = c.customer_id;
    
-- Comprehensive customer profile including customer, transaction, account, and credit history data
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    c.annual_income,
    c.employment_status,
    c.credit_score,
    t.transaction_id,
    t.transaction_date,
    t.transaction_amount,
    a.account_type,
    a.credit_limit,
    a.balance,
    ch.due_amount,
    ch.payment_amount,
    ch.missed_payment
FROM 
    Customers c
LEFT JOIN 
    Transactions t ON c.customer_id = t.customer_id
LEFT JOIN 
    Accounts a ON c.customer_id = a.customer_id
LEFT JOIN 
    Credit_History ch ON c.customer_id = ch.customer_id;
    
    
-- Delinquency rate: percentage of missed payments per customer
SELECT 
    c.customer_id,
    COUNT(ch.history_id) AS total_payments,
    SUM(CASE WHEN ch.missed_payment = TRUE THEN 1 ELSE 0 END) AS missed_payments,
    ROUND(SUM(CASE WHEN ch.missed_payment = TRUE THEN 1 ELSE 0 END) * 100.0 / COUNT(ch.history_id), 2) AS delinquency_rate
FROM 
    Customers c
JOIN 
    Credit_History ch ON c.customer_id = ch.customer_id
GROUP BY 
    c.customer_id;
    
-- Fraud statistics: total frauds, types, and open investigations
SELECT 
    c.customer_id,
    COUNT(f.fraud_id) AS total_frauds,
    COUNT(DISTINCT f.fraud_type) AS unique_fraud_types,
    SUM(CASE WHEN f.investigation_status = 'Open' THEN 1 ELSE 0 END) AS open_investigations
FROM 
    Fraud_Records f
JOIN 
    Transactions t ON f.transaction_id = t.transaction_id
JOIN 
    Customers c ON t.customer_id = c.customer_id
GROUP BY 
    c.customer_id;


