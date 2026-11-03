# NovaGear DB

A beginner-friendly MySQL database project for **NovaGear Technologies**, a fictional India-based consumer electronics and accessories business.

> **Project status: In progress**  
> This repository is being developed as a hands-on SQL learning and portfolio project. The database and practice queries are not yet complete.

## Project Overview

The project models the core operations of an online electronics retailer, including its product catalogue, suppliers, employees, customers, orders, order line items, and product reviews.

The SQL script is written for **MySQL 8.0+**.

## Database Structure

The database is named `novagear_db` and currently contains eight tables:

| Table | Purpose |
| --- | --- |
| `categories` | Product categories |
| `suppliers` | Supplier details and lead times |
| `employees` | Employee, department, salary, and reporting information |
| `products` | Product catalogue, pricing, stock, and availability |
| `customers` | Customer contact and registration details |
| `orders` | Order-level information, sales representative, status, and payment method |
| `order_items` | Products, quantities, selling prices, and discounts within each order |
| `reviews` | Product ratings and customer feedback |

The schema uses primary keys, foreign keys, unique constraints, and check constraints to model relationships and enforce basic data rules.

## Dataset

The SQL script includes sample data for all eight tables. Each table contains 50 rows or fewer. All people, email addresses, phone numbers, and suppliers are fictional.

## Current SQL Practice

The script currently contains business-style practice questions involving:

- Filtering and sorting products
- Identifying inventory shortfalls
- Finding customers with missing phone numbers
- Summarising catalogue and inventory data
- Grouping orders by payment method
- Department-level salary analysis
- Joining products with categories and suppliers
- Calculating product profit margins
- Analysing category-level sales and discounted revenue
- Finding customers who have never placed an order

The final sales-team order-count and revenue question is present but its SQL solution is still pending.

## How to Run

1. Install MySQL 8.0 or later and open MySQL Workbench (or another MySQL client).
2. Open `Novagear db.sql` from this repository.
3. Execute the script to create and populate `novagear_db`.
4. Run the included quick-check query to inspect table row counts.
5. Continue solving the business questions and add more analysis as the project develops.

> **Important:** The script starts with `DROP DATABASE IF EXISTS novagear_db;`. Running it again drops and recreates that database. Back up any database changes you want to keep before rerunning the script.

## Planned Improvements

- Complete the pending sales executive order-count and revenue query.
- Review and refine existing query logic and calculations.
- Add more business-focused SQL questions.
- Practise advanced SQL concepts such as CTEs and window functions.
- Document query solutions and insights as the project progresses.

## Repository Structure

```text
NovaGear_DB/
├── Novagear db.sql
└── README.md
```

## Disclaimer

NovaGear Technologies and all records in this project are fictional. This is a learning project and does not represent a real company's operational data.

---

**Status:** Work in progress. More queries, analysis, and documentation will be added as the project is completed.
