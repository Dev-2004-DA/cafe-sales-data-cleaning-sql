# Café Sales Data Cleaning — MySQL

**Project completed:** October 2025 – November 2025  
**Tools:** MySQL · MySQL Workbench  
**Domain:** Data Cleaning · SQL · Data Engineering

---

## Overview

An end-to-end SQL data cleaning project on a dirty café sales transactions dataset.  
The raw table is processed through a **4-stage pipeline of staging tables**,  
each handling a specific layer of quality issues across all 8 columns.

**Output:** `FINAL_dfs` — a fully typed, imputed, and analysis-ready transactions table  
with no empty strings, no placeholder values, consistent data types, and mathematically  
verified totals.

---

## Problem Statement

The raw dataset contains multiple categories of dirty data:
- Placeholder strings — `'ERROR'`, `'UNKNOWN'`, and blank `''` across all columns
- Missing item names that can be intelligently inferred from price
- Mixed date formats (`YYYY-MM-DD` and `YYYY/MM/DD`) in the same column
- Untyped currency values and inconsistent Total Spent values
- Rows with simultaneous data loss across multiple columns

This project demonstrates a **production-style cleaning pipeline** —  
no in-place modification of the raw table, full rollback capability at every stage.

---

## Pipeline Architecture

| Stage Table | Purpose |
|---|---|
| `dirty_cafe_sales` | Raw source — original CSV import, never modified |
| `dirty_cafe_sales_stag_1` | Payment Method cleaned via LAG(); item imputed from price |
| `dirty_cafe_sales_stag_2` | Item NULL-filled via LAG(); Transaction Date parsed; Total Spent recomputed |
| `FINAL_dfs` | Location NULL-filled via LAG(); helper columns dropped — final output |

> Each stage uses `CREATE TABLE AS SELECT` — raw data is never modified.  
> Any intermediate state can be audited or rolled back without re-importing.

---

## Key SQL Techniques

### 1. Price-Based Item Imputation (applied before LAG)
Rather than blindly forward-filling NULL item values, a smarter first pass  
infers item names directly from `Price Per Unit` where the mapping is unique:

| Price Per Unit | Item | Safe to Impute? |
|---|---|---|
| $1.0 | Cookie | Yes — unique mapping |
| $1.5 | Tea | Yes — unique mapping |
| $2.0 | Coffee | Yes — unique mapping |
| $5.0 | Salad | Yes — unique mapping |
| $3.0 | — | No — Smoothie or Juice |
| $4.0 | — | No — Sandwich or Cake |

Prices with non-unique mappings ($3.0, $4.0) were left for LAG() fill in the next step.  
This ensures verified correct values are used wherever possible before propagating neighbours.

### 2. LAG() + COALESCE for NULL Forward-Fill
Three columns — `item`, `Payment Method`, `Location` — used LAG() window functions  
to carry the previous row's value forward when the current row is NULL.  
Seed default values handle the first row where no previous value exists.

### 3. Targeted Row Deletion Before Fill
Rows where `Location`, `Item`, and `Transaction Date` were all simultaneously dirty  
were deleted before imputation — insufficient remaining data made any fill indefensible.

### 4. Dual-Format Date Parsing
`Transaction Date` contained two mixed formats in the same column.  
Handled with a `COALESCE(STR_TO_DATE(...), STR_TO_DATE(...))` fallback pattern:
```sql
SET `Transaction Date` = COALESCE(
  STR_TO_DATE(`Transaction Date`, '%Y-%m-%d'),
  STR_TO_DATE(`Transaction Date`, '%Y/%m/%d')
);
```

### 5. Total Spent Recomputed from Source
Rather than parsing the dirty `Total Spent` strings, the column was fully  
recomputed at the end of the pipeline from the already-clean source columns:
```sql
UPDATE dfs1
SET `Total Spent` = Quantity * `Price Per Unit`;
```
This guarantees mathematical consistency across all rows regardless of the original values.

### 6. Payment Method Helper Column Pattern
MySQL cannot reference a LAG() alias in the same UPDATE without an intermediate table.  
A helper column `PM` was introduced to safely swap values, then renamed to the final column name.

---

## Final Output — FINAL_dfs

| Column | Final Data Type | Notes |
|---|---|---|
| `Transaction ID` | VARCHAR(20) PK | Primary key — confirmed unique |
| `item` | VARCHAR | NULL-free after price imputation + LAG() fill |
| `Quantity` | INT | No changes needed |
| `Price Per Unit` | DECIMAL(2,1) | Type-cast; values were already clean |
| `Total Spent` | DECIMAL(10,2) | Recomputed as Quantity × Price Per Unit |
| `Payment Method` | VARCHAR(20) | Cash / Credit Card / Digital Wallet |
| `Location` | VARCHAR(50) | In-store / Takeaway |
| `Transaction Date` | DATE | Parsed from two mixed string formats |

---

## Design Decisions

- **Price imputation before LAG()** — maximises rows filled with a verified correct value rather than a propagated neighbour value
- **Total Spent recomputed, not parsed** — recomputation from trusted source columns is always more accurate than cleaning a dirty formatted string
- **Three-column NULL rows deleted, not imputed** — when Location, Item, and Date are all dirty simultaneously, there is no defensible imputation
- **Staging table pipeline** — every intermediate state is preserved for full auditability

---

## Repository Structure

```
cafe-sales-data-cleaning-sql/
├── Cafe_sales.sql                      # Full SQL cleaning script
├── dirty_cafe_sales.csv                # Raw input dataset
├── Cleaned_cafe_sales.csv              # Final cleaned output
├── Cafe_Sales_MySQL_Documentation.pdf  # Detailed project documentation
└── README.md
```

> Dataset sourced from Kaggle — download the dirty version and import via MySQL Workbench.

---

## Skills Demonstrated

`MySQL` `Data Cleaning` `Window Functions` `LAG()` `COALESCE()` `STR_TO_DATE()`  
`Price-Based Imputation` `Staging Tables` `Data Type Casting` `NULL Handling`  
`MySQL Workbench` `Dual-Format Date Parsing`

---

*Part of my Data Analytics portfolio — [github.com/Dev-2004-DA](https://github.com/Dev-2004-DA)*
