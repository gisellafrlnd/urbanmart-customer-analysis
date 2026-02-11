# UrbanMart: Strategic Customer Segmentation using PostgreSQL

## Project Overview
Proyek ini melakukan analisis mendalam terhadap **50.000 catatan transaksi** dari UrbanMart (e-commerce fiktif) untuk periode 2023-2024. Tujuan utamanya adalah mengimplementasikan metodologi **RFM (Recency, Frequency, Monetary)** untuk memahami perilaku pelanggan dan memberikan rekomendasi strategi bisnis yang berbasis data.

## Tools
* **Database:** PostgreSQL (Cloud-managed via Supabase).
* **Analysis Method:** RFM Analysis.
* **SQL Techniques:** CTEs (Common Table Expressions), Window Functions, Data Aggregation.

## Dataset Details
Dataset mencakup informasi **2.000 pelanggan unik** dengan detail transaksi antara Rp50.000 hingga Rp5.000.000 selama dua tahun (Januari 2023 - Desember 2024).

## Methodology: RFM Analysis
Saya menggunakan SQL untuk menghitung tiga metrik utama bagi setiap pelanggan:
* **Recency (R):** Jarak hari sejak transaksi terakhir pelanggan.
* **Frequency (F):** Seberapa sering pelanggan melakukan pembelian.
* **Monetary (M):** Total nilai ekonomi dari pelanggan tersebut.

Metrik ini dibagi ke dalam kuartil (skor 1-5) menggunakan fungsi `NTILE` untuk menentukan segmen pelanggan.

## SQL Implementation Snippet
Logika inti yang digunakan dalam file `rfm_analysis.sql`:

```sql
WITH RFM_Base AS (
    SELECT 
        "CustomerID",
        ('2024-12-31'::DATE - MAX("TransactionDate")) AS recency,
        COUNT("TransactionID") AS frequency,
        SUM("TransactionValue") AS monetary
    FROM urbanmart_transactions
    GROUP BY "CustomerID"
),
RFM_Scores AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY recency DESC) AS r,
        NTILE(5) OVER (ORDER BY frequency ASC) AS f,
        NTILE(5) OVER (ORDER BY monetary ASC) AS m
    FROM RFM_Base
)
SELECT 
    "CustomerID",
    CASE 
        WHEN r >= 4 AND f >= 4 THEN 'Champions'
        WHEN r >= 3 AND f >= 3 THEN 'Loyal Customers'
        WHEN r <= 2 AND f >= 3 THEN 'At Risk'
        WHEN r <= 1 THEN 'Lost Customers'
        ELSE 'Potential Loyalist'
    END AS customer_segment
FROM RFM_Scores;
```

## **Strategic Insights**
Melalui segmentasi ini, UrbanMart dapat menerapkan strategi yang berbeda:
* **Champions**: Berikan program VIP dan akses awal ke produk baru.
* **Loyal Customers**: Fokus pada kampanye upselling dan paket bundling.
* **At Risk**: Kirimkan voucher diskon khusus untuk mencegah mereka berhenti berbelanja (churn).
* **Lost Customers**: Lakukan survei untuk memahami penyebab mereka tidak kembali berbelanja.
