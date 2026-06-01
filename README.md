# retail_sales_Analysis
Retail Sales Analysis using PostgreSQL and Excel Dashboard
# 🛒 Retail Sales Analysis — SQL + Excel Dashboard

**Author:** Dharshan | [GitHub](https://github.com/dharchandran-spec)

---

## 📌 Project Overview

This project analyzes retail sales data using **PostgreSQL** for advanced SQL analysis and **Microsoft Excel** for interactive dashboard visualization. The goal is to extract meaningful business insights from 9,487 retail transactions across 4 regions, 3 product categories, and 12 months.

---

## 🎯 Business Questions Answered

1. Which product category has the highest sales?
2. In which month are sales at peak?
3. Which ship mode is most used by month?
4. Which region sold the most and least?
5. Is discount affecting revenue?
6. Are customers satisfied with discounts?
7. Which category has the highest cost price per quantity?
8. What is the average discount by segment and category?
9. What is the average shipping pattern by month?
10. Which category is most at risk of late shipping?

---

## 🗂️ Dataset

- **Source:** [Kaggle — Retail Orders by Ankitbansal06](https://www.kaggle.com/datasets/ankitbansal06/retail-orders)
- **Raw rows:** 9,994
- **Cleaned rows:** 9,487 (507 zero-price rows removed)
- **Time period:** 2022–2023

---

## 🗃️ Database Design

The raw CSV was normalized into **4 relational tables** in PostgreSQL:

```
staging_orders (raw data)
        |
        ├── products      (product_id, category, sub_category)
        ├── regions       (region_id, region, country, state, city)
        ├── orders        (order_id, order_date, ship_mode, segment, region)
        └── order_items   (item_id, order_id, product_id, quantity, cost_price, list_price, discount)
```

---

## 🧹 Data Cleaning

| Issue | Action Taken |
|---|---|
| NULL values | Checked all 4 tables — none found |
| Duplicate rows | Checked all 4 tables — none found |
| Zero price rows | 507 rows removed from order_items |
| Invalid ship_mode values | 'Not Available', 'N/A', 'unknown' set to NULL |

---

## 🔍 SQL Techniques Used

| Technique | Purpose |
|---|---|
| INNER JOIN | Connect orders, products, order_items |
| LEFT JOIN | Find orders with no matching items |
| RIGHT JOIN | Find products never ordered |
| FULL OUTER JOIN | Find all unmatched records |
| CTEs | Organize complex multi-step queries |
| ROW_NUMBER() | Rank orders by sales within each region |
| RANK() | Rank sub-categories within each category |
| LAG() | Month over month sales growth comparison |
| LEAD() | Next month sales preview |
| Running Total | Cumulative sales across months |

---

## 📊 Key Business Insights

| Finding | Insight |
|---|---|
| 🥇 Technology leads sales | $4,080,330 — highest among all categories |
| 📅 October is peak month | $1,275,670 — pre-holiday shopping surge |
| 🌍 West region dominates | $3,594,450 — South underperforms at $2,037,220 |
| 💰 Higher discounts = more revenue | Discount 5 drives 14% higher avg sale than Discount 2 |
| 🚚 Standard Class dominates | Used in 70%+ of all shipments |
| 📦 Office Supplies at risk | 3,337 Standard Class shipments — highest late delivery risk |
| 📈 February best growth | +34.97% month over month growth |
| 💎 Technology most expensive | $105.66 cost per unit vs $28.75 for Office Supplies |

---

## 📁 Repository Structure

```
retail-sales-analysis/
├── README.md
├── sql/
│   └── project3_queries.sql
├── data/
│   ├── category_sales.csv
│   ├── monthly_sales.csv
│   ├── region_sales.csv
│   ├── discount_revenue.csv
│   └── subcategory_sales.csv
├── dashboard/
│   └── retail_sales_dashboard.xlsx
└── report/
    └── project_report.pdf
```

---

## 🛠️ Tools Used

| Tool | Purpose |
|---|---|
| PostgreSQL 18 | Database creation, data cleaning, SQL analysis |
| pgAdmin | PostgreSQL GUI |
| Microsoft Excel | Dashboard and visualization |
| GitHub | Version control and portfolio |

---

## 🚀 How to Run

1. Download `orders.csv` from [Kaggle](https://www.kaggle.com/datasets/ankitbansal06/retail-orders)
2. Install PostgreSQL and pgAdmin
3. Create database: `retail_project`
4. Run `sql/project3_queries.sql` step by step
5. Export results to CSV
6. Open `dashboard/retail_sales_dashboard.xlsx`

---

## 📬 Contact

**Dharshan** | B.Tech Information Technology | Tamil Nadu, India

GitHub: [dharchandran-spec](https://github.com/dharchandran-spec)
