# ☕ Dirty Cafe Sales – SQL Data Cleaning  

This project demonstrates **SQL-based data cleaning** on the **Dirty Cafe Sales dataset** (10,000 synthetic rows of cafe transactions).  
The dataset contains missing values, invalid entries, and inconsistent formats — useful for practicing **data wrangling and cleaning**.  
This dataset is taken from `Kaggle`.

---

## 🔹 Steps Performed
- Converted and standardized column data types  
- Handled missing & invalid values (`ERROR`, `UNKNOWN`, empty cells)  
- Forward-filled missing categorical values with `LAG()`  
- Recalculated `Total Spent` as `Quantity × Price Per Unit`  
- Standardized `Transaction Date` into proper `DATE` format  

---

## 📂 Tables
- **dirty_cafe_sales_stag_1** → First staging table  
- **dirty_cafe_sales_stag_2** → Cleaned version  
- **FINAL_dfs** → Final cleaned dataset  

---

## ✅ Final Output
The cleaned dataset (`FINAL_dfs`) is ready for:  
- Exploratory Data Analysis (EDA)  
- Feature Engineering  
- Machine Learning pipelines  

---

## 🛠 Example Usage
```sql
-- View the cleaned dataset
SELECT * 
FROM FINAL_dfs
LIMIT 10;

-- Example: total revenue by location
SELECT Location, SUM(`Total Spent`) AS revenue
FROM FINAL_dfs
GROUP BY Location;
