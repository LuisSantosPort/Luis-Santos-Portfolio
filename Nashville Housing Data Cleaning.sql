/*

Cleaning Data in SQL Queries

*/


Select *
From `nashville housing data cleaning`.`nashville housing data for data cleaning`;

CREATE TABLE nashvillehousing
LIKE `nashville housing data cleaning`.`nashville housing data for data cleaning`;

INSERT nashvillehousing
SELECT *
FROM `nashville housing data cleaning`.`nashville housing data for data cleaning`;

SELECT *
FROM nashvillehousing;


--------------------------------------------------------------------------------------------------------------------------

SELECT SaleDate
FROM nashvillehousing;

ALTER TABLE nashvillehousing
MODIFY COLUMN `SaleDate`DATE;


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT PropertyAddress
FROM nashvillehousing;

SELECT *
FROM nashvillehousing
WHERE PropertyAddress = "";

Select *
FROM nashvillehousing
-- Where PropertyAddress = ""
ORDER BY ParcelID;

ALTER TABLE nashvillehousing RENAME COLUMN ï»¿UniqueID TO UniqueID;


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, COALESCE(a.PropertyAddress,b.PropertyAddress)
FROM nashvillehousing AS a
JOIN nashvillehousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL OR a.PropertyAddress = '';


CREATE TEMPORARY TABLE TempAddresses 
SELECT a.ParcelID, b.PropertyAddress
FROM nashvillehousing AS a
JOIN nashvillehousing AS b
    ON a.ParcelID = b.ParcelID
   AND a.UniqueID <> b.UniqueID
WHERE b.PropertyAddress IS NOT NULL AND b.PropertyAddress <> '';

SELECT *
FROM TempAddresses;

UPDATE nashvillehousing AS a
JOIN TempAddresses AS t
    ON a.ParcelID = t.ParcelID
SET a.PropertyAddress = t.PropertyAddress
WHERE a.PropertyAddress IS NULL OR a.PropertyAddress = '';


DROP TEMPORARY TABLE TempAddresses;


--------------------------------------------------------------------------------------------------------------------------


-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM nashvillehousing;


-- Breaking Out PropertyAddress into Individual Columns (Address, City)

-- Extracting Address and City
SELECT 
    TRIM(SUBSTRING_INDEX(PropertyAddress, ',', 1)) AS Address, 
    TRIM(SUBSTRING_INDEX(PropertyAddress, ',', -1)) AS City    
FROM nashvillehousing;

-- Adding new columns for Address and City
ALTER TABLE nashvilleHousing
ADD COLUMN PropertySplitAddress NVARCHAR(255),
ADD COLUMN PropertySplitCity NVARCHAR(255);

-- Populating the new columns with Address and City data
UPDATE NashvilleHousing
SET 
	PropertySplitAddress = TRIM(SUBSTRING_INDEX(PropertyAddress, ',', 1)),
    PropertySplitCity = TRIM(SUBSTRING_INDEX(PropertyAddress, ',', -1));

SELECT *
FROM nashvillehousing;


-- Splitting OwnerAddress into Individual Columns (Address, City, State)

-- Inspect OwnerAddress data
SELECT OwnerAddress
FROM nashvillehousing;

-- Extract components using SUBSTRING_INDEX 
SELECT 
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 1), ',', -1)) AS OwnerState,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1)) AS OwnerCity,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 3), ',', -1)) AS OwnerAddress
FROM nashvillehousing;


-- Add new columns for OwnerAddress components
ALTER TABLE NashvilleHousing
ADD COLUMN OwnerSplitAddress NVARCHAR(255),
ADD COLUMN OwnerSplitCity NVARCHAR(255),
ADD COLUMN OwnerSplitState NVARCHAR(255);

-- Populate the new columns with OwnerAddress components
UPDATE nashvillehousing
SET 
    OwnerSplitAddress = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 3), ',', -1)),
    OwnerSplitCity = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1)),
    OwnerSplitState = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 1), ',', -1));

SELECT *
FROM nashvillehousing;


--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


SELECT DISTINCT(SoldAsVacant), Count(SoldAsVacant)
FROM nashvillehousing
GROUP BY SoldAsVacant
ORDER BY 2;


SELECT SoldAsVacant
, CASE 
       WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM nashvillehousing;


UPDATE nashvillehousing
SET SoldAsVacant = CASE 
       WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END;



-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates


SELECT *
FROM nashvillehousing
WHERE UniqueID IN 
(
SELECT UniqueID
FROM (SELECT UniqueID,
			ROW_NUMBER() OVER (
                   PARTITION BY ParcelID, 
                                PropertyAddress, 
                                SalePrice, 
                                SaleDate, 
                                LegalReference
                   ORDER BY UniqueID) AS row_num
        FROM nashvillehousing) AS duplicates
    WHERE row_num > 1
);


DELETE FROM nashvillehousing
WHERE UniqueID IN 
(
SELECT UniqueID
FROM (SELECT UniqueID,
			ROW_NUMBER() OVER (
                   PARTITION BY ParcelID, 
                                PropertyAddress, 
                                SalePrice, 
                                SaleDate, 
                                LegalReference
                   ORDER BY UniqueID) AS row_num
        FROM nashvillehousing) AS duplicates
    WHERE row_num > 1
);


SELECT *
FROM nashvillehousing;


---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


Select *
From nashvillehousing;


ALTER TABLE nashvillehousing
   DROP COLUMN OwnerAddress,
   DROP COLUMN TaxDistrict,
   DROP COLUMN PropertyAddress,
   DROP COLUMN SaleDate;




