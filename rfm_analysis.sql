-- =================================================================
-- 1. DATABASE SETUP
-- Mempersiapkan tabel untuk menampung data transaksi UrbanMart
-- =================================================================

DROP TABLE IF EXISTS urbanmart_transactions;

CREATE TABLE urbanmart_transactions (
    "TransactionID" VARCHAR(20) PRIMARY KEY,
    "CustomerID" VARCHAR(20),
    "TransactionDate" DATE,
    "TransactionValue" FLOAT,
    "ProductCategory" VARCHAR(50),
    "PaymentMethod" VARCHAR(50),
    "CustomerGender" VARCHAR(10),
    "CustomerAgeGroup" VARCHAR(20),
    "Region" VARCHAR(50)
);

-- =================================================================
-- 2. RFM CALCULATION (BASIC METRICS)
-- Menghitung nilai Recency, Frequency, dan Monetary untuk tiap user
-- =================================================================

WITH RFM_Base AS (
    SELECT 
        "CustomerID",
        -- Recency: Jarak hari dari transaksi terakhir ke akhir tahun 2024
        ('2024-12-31'::DATE - MAX("TransactionDate")) AS recency,
        -- Frequency: Jumlah total transaksi per customer
        COUNT("TransactionID") AS frequency,
        -- Monetary: Total nilai belanja per customer
        SUM("TransactionValue") AS monetary
    FROM urbanmart_transactions
    GROUP BY "CustomerID"
),

-- =================================================================
-- 3. RFM SCORING
-- Memberikan skor 1-5 menggunakan NTILE berdasarkan kuartil data
-- =================================================================

RFM_Scores AS (
    SELECT 
        *,
        NTILE(5) OVER (ORDER BY recency DESC) AS r,
        NTILE(5) OVER (ORDER BY frequency ASC) AS f,
        NTILE(5) OVER (ORDER BY monetary ASC) AS m
    FROM RFM_Base
)

-- =================================================================
-- 4. CUSTOMER SEGMENTATION (FINAL OUTPUT)
-- Mengelompokkan pelanggan berdasarkan kombinasi skor RFM
-- =================================================================

SELECT 
    "CustomerID",
    CASE 
        WHEN r >= 4 AND f >= 4 THEN 'Champions'
        WHEN r >= 3 AND f >= 3 THEN 'Loyal Customers'
        WHEN r <= 2 AND f >= 3 THEN 'At Risk'
        WHEN r <= 1 THEN 'Lost Customers'
        ELSE 'Potential Loyalist'
    END AS customer_segment,
    r AS recency_score,
    f AS frequency_score,
    m AS monetary_score
FROM RFM_Scores
ORDER BY customer_segment, monetary DESC;
