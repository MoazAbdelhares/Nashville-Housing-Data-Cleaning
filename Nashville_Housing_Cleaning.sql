/*
-------------------------------------------------------------------------------------------
1. DATABASE INITIALIZATION & PRELIMINARY CLEANUP
-------------------------------------------------------------------------------------------
*/

-- Standardizing UniqueID: Trimming and fixing data type
UPDATE housing SET UniqueID = TRIM(UniqueID);

ALTER TABLE housing MODIFY COLUMN UniqueID INT;

-- Quick check for any records with missing UniqueIDs
SELECT * FROM housing WHERE UniqueID IS NULL;

/*
-------------------------------------------------------------------------------------------
2. REMOVING DUPLICATE RECORDS
-------------------------------------------------------------------------------------------
-- Using ParcelID, Address, SaleDate, and Price to identify identical entries.
*/

DELETE FROM housing
WHERE UniqueID IN (
    SELECT UniqueID FROM (
        SELECT UniqueID,
               ROW_NUMBER() OVER (
                   PARTITION BY ParcelID, LandUse, PropertyAddress, SaleDate, 
                                SalePrice, OwnerName, OwnerAddress, Acreage, 
                                TaxDistrict, LandValue, BuildingValue, TotalValue 
                   ORDER BY UniqueID
               ) AS row_num
        FROM housing
    ) AS duplicates
    WHERE row_num > 1
);

/*
-------------------------------------------------------------------------------------------
3. PROPERTY ADDRESS REPAIR & STANDARDIZATION
-------------------------------------------------------------------------------------------
*/

-- Populate missing PropertyAddress by joining the table to itself on ParcelID
UPDATE housing a
JOIN housing b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = b.PropertyAddress
WHERE (a.PropertyAddress IS NULL OR a.PropertyAddress = '') 
  AND b.PropertyAddress IS NOT NULL;

-- Standardizing LandUse labels (Fixing typos)
UPDATE housing
SET LandUse = CASE 
    WHEN LandUse = 'VACANT RES LAND' THEN 'VACANT RESIDENTIAL LAND'
    WHEN LandUse = 'VACANT RESIENTIAL LAND' THEN 'VACANT RESIDENTIAL LAND'
    WHEN LandUse = 'GRRENBELT/RES' THEN 'GREENBELT/RES'
    ELSE LandUse
END;

/*
-------------------------------------------------------------------------------------------
4. DATA TYPE CONVERSIONS & NUMERIC CLEANING (SaleDate & SalePrice)
-------------------------------------------------------------------------------------------
*/

-- Converting SaleDate from String to Date Format
UPDATE housing SET SaleDate = STR_TO_DATE(SaleDate, '%M %d, %Y');

ALTER TABLE housing MODIFY COLUMN SaleDate DATE;

-- Cleaning SalePrice: Removing symbols ($, ,) and converting to Integer
UPDATE housing SET SalePrice = TRIM(REPLACE(REPLACE(SalePrice, ',', ''), '$', ''));

ALTER TABLE housing MODIFY COLUMN SalePrice INT;

/*
-------------------------------------------------------------------------------------------
5. STRING SPLITTING (Address & Owner Info)
-------------------------------------------------------------------------------------------
*/

-- Breaking out PropertyAddress into Individual Columns (Address, City)
ALTER TABLE housing
ADD PropertySplitAddress NVARCHAR(255),
ADD PropertySplitCity NVARCHAR(255);

UPDATE housing
SET PropertySplitAddress = SUBSTRING_INDEX(PropertyAddress, ',', 1),
    PropertySplitCity = SUBSTRING_INDEX(PropertyAddress, ',', -1);

-- Breaking out OwnerAddress into (Address, City, State)
ALTER TABLE housing
ADD OwnerSplitAddress NVARCHAR(255),
ADD OwnerSplitCity NVARCHAR(255),
ADD OwnerSplitState NVARCHAR(255);

UPDATE housing
SET OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress, ',', 1),
    OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1),
    OwnerSplitState = SUBSTRING_INDEX(OwnerAddress, ',', -1);

-- Standardizing "SoldAsVacant" (Y/N to Yes/No)
UPDATE housing
SET SoldAsVacant = CASE 
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
END;

/*
-------------------------------------------------------------------------------------------
6. HANDLING FINANCIALS & LAND DATA (Acreage, Values)
-------------------------------------------------------------------------------------------
*/

-- Cleaning Acreage: Rounding and fixing data type
UPDATE housing SET Acreage = ROUND(Acreage, 2);

ALTER TABLE housing MODIFY COLUMN Acreage FLOAT;

-- Fixing TotalValue: Converting zeros to NULL to avoid skewed averages
UPDATE housing SET TotalValue = NULL WHERE TotalValue = 0;

-- Trimming TaxDistrict labels
UPDATE housing SET TaxDistrict = TRIM(TaxDistrict);

/*
-------------------------------------------------------------------------------------------
7. FINAL CLEANUP & DATA AUDIT
-------------------------------------------------------------------------------------------
*/

-- Dropping redundant columns after splitting
ALTER TABLE housing
DROP COLUMN OwnerAddress, 
DROP COLUMN PropertyAddress;

-- Final Quality Check: Counting NULLs in key columns
SELECT 
    SUM(CASE WHEN PropertySplitAddress IS NULL THEN 1 ELSE 0 END) AS Missing_Address,
    SUM(CASE WHEN PropertySplitCity IS NULL THEN 1 ELSE 0 END) AS Missing_City,
    SUM(CASE WHEN SaleDate IS NULL THEN 1 ELSE 0 END) AS Missing_Date,
    SUM(CASE WHEN SalePrice = 0 OR SalePrice IS NULL THEN 1 ELSE 0 END) AS Missing_Price
FROM housing;

-- Verification of Land Value Calculation (The 7147 Discrepancy Insight)
SELECT UniqueID, LandValue, BuildingValue, TotalValue, 
      (TotalValue - (LandValue + BuildingValue)) AS Discrepancy
FROM housing
WHERE (LandValue + BuildingValue) <> TotalValue
ORDER BY ABS(Discrepancy) DESC;