SELECT * FROM banking_transactions;
SELECT COUNT(*) FROM banking_transactions;



--Q1: Total transaction value and transaction count.
SELECT SUM(transaction_amount),
COUNT(transaction_id)
FROM banking_transactions;
--Q2: Confirmed fraud count and fraud rate.
SELECT 
COUNT(*)FILTER(WHERE is_fraud =1) AS fraud_count,
	ROUND(
        COUNT(*) FILTER (WHERE is_fraud = 1) * 100.0
        / NULLIF(COUNT(*), 0),
        2
   	 ) AS fraud_rate_percentage
	
FROM banking_transactions;

--Q3.: Fraud amount by payment method.
SELECT 
channel AS payment_method,
SUM(transaction_amount)AS fraud_amount 
FROM banking_transactions
WHERE(is_fraud=1) 
GROUP BY channel
ORDER BY fraud_amount  DESC;

--Q4: Hourly and monthly fraud trends.

SELECT
    EXTRACT(HOUR FROM transaction_time::TIME) AS transaction_hour,
    COUNT(*) AS fraud_count,
    SUM(transaction_amount) AS fraud_amount
FROM banking_transactions
WHERE is_fraud = 1
GROUP BY EXTRACT(HOUR FROM transaction_time::TIME)
ORDER BY transaction_hour;
---BY MONTH

SELECT
    DATE_TRUNC('month', transaction_date::DATE)::DATE AS fraud_month,
    COUNT(*) AS fraud_count,
    SUM(transaction_amount) AS fraud_amount
FROM banking_transactions
WHERE is_fraud = 1
GROUP BY DATE_TRUNC('month', transaction_date::DATE)
ORDER BY fraud_month;


--Q5: Which transaction types have the highest fraud rate?

SELECT
    transaction_type,
    COUNT(*) AS total_transactions,
    SUM(CASE WHEN is_fraud = 1 THEN 1 ELSE 0 END) AS fraud_count,
    ROUND(
        100.0 * SUM(CASE WHEN is_fraud = 1 THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*), 0),
        2
    ) AS fraud_rate_pct,
    SUM(
        CASE WHEN is_fraud = 1
        THEN transaction_amount ELSE 0 END
    ) AS fraud_amount
FROM banking_transactions
GROUP BY transaction_type
ORDER BY fraud_rate_pct DESC;




--Q6: Customer transaction frequency and unusual activity.

SELECT
    customer_id,
    COUNT(transaction_id) AS total_transactions,
    SUM(transaction_amount) AS total_transaction_amount,
    ROUND(AVG(transaction_amount)::NUMERIC, 2)
        AS avg_transaction_amount,
    SUM(CASE WHEN is_fraud = 1 THEN 1 ELSE 0 END)
        AS fraud_count
FROM banking_transactions
GROUP BY customer_id
ORDER BY total_transactions DESC
LIMIT 20;



