Nashville Housing Data Cleaning Project (SQL) 
 Project Overview
This project involves a comprehensive data cleaning process for a dataset containing over 56,000 records of Nashville housing market transactions. The primary goal was to transform messy, raw data into a structured, reliable, and analysis-ready format using Advanced SQL techniques.

 Technical Workflow & Key Achievements
1. Data Standardization
Date Alignment: Unified SaleDate formats for consistent time-series analysis.

Boolean Normalization: Standardized SoldAsVacant field entries from "Y/N" to "Yes/No" using CASE statements.

2. Advanced Data Imputation
Address Repair: Used Self-Joins on ParcelID to populate missing PropertyAddress records, ensuring 100% address coverage.

String Cleaning: Cleaned "Blank Strings" and hidden white spaces in City and District columns to ensure accurate grouping.

3. Dynamic Data Decomposition
Address Splitting: Deconstructed complex address strings into individual Address, City, and State columns using SUBSTRING and SUBSTRING_INDEX for better filtering.

4. Data Quality & Deduplication
Duplicate Removal: Identified and removed duplicate records using CTEs and Window Functions (ROW_NUMBER).

5. Financial Integrity Audit
Discrepancy Discovery: Identified 7,147 records where LandValue + BuildingValue did not equal TotalValue.

District Analysis: Identified that 30,368 records in the "General Services District" had a zero TotalValue, providing critical context for future statistical modeling.

 Final Results
Reliability: Increased dataset reliability by resolving inconsistencies in 12.5% of the financial data.

Optimization: The final dataset is fully optimized for visualization tools like Power BI or Tableau.

 مشروع تنظيف بيانات عقارات ناشفيل (باللغة العربية)
نظرة عامة
يتضمن هذا المشروع عملية تنظيف شاملة لبيانات سوق العقارات في مدينة ناشفيل. الهدف الأساسي كان تحويل البيانات الخام إلى تنسيق هيكلي دقيق باستخدام تقنيات SQL المتقدمة.

أبرز الإنجازات التقنية:
معالجة البيانات المفقودة: استخدام الـ Self-Join لملء العناوين المفقودة بناءً على رقم القطعة.

إزالة التكرارات: ضبط جودة البيانات بحذف السجلات المكررة باستخدام Window Functions.

التدقيق المالي: اكتشاف عدم تطابق حسابي في 7,147 سجلاً وتوضيح الفجوات في بيانات المناطق الخدمية.

هيكلة النصوص: تقسيم العناوين المعقدة إلى أعمدة منفصلة لسهولة الفلترة والبحث.
