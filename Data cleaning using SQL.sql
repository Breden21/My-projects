/*
Cleaning Data in SQL using PostgreSQL in DBeaver

Process inolved changing data types, splitting columns,identifying duplicates,
categorizing information and dealing with nulls by populating the appropriate columns.

*/


SELECT *
FROM nashville_housing_data_for_data_cleaning 

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

ALTER TABLE nashville_housing_data_for_data_cleaning  
  ALTER "SaleDate" type date using("SaleDate"::date)

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT *
FROM nashville_housing_data_for_data_cleaning 
WHERE PropertyAddress IS NULL
ORDER BY ParcelID


SELECT a."ParcelID" , a."PropertyAddress" , b."ParcelID" , b."PropertyAddress" , COALESCE(a."PropertyAddress" ,b."PropertyAddress")
FROM nashville_housing_data_for_data_cleaning  a
JOIN nashville_housing_data_for_data_cleaning  b
	ON a."ParcelID"  = b."ParcelID" 
	AND a."UniqueID"  <> b."UniqueID"
WHERE a."PropertyAddress" isnull


UPDATE a
SET PropertyAddress = COALESCE(a."PropertyAddress" ,b."PropertyAddress")
rom nashville_housing_data_for_data_cleaning  a
JOIN nashville_housing_data_for_data_cleaning  b
	ON a."ParcelID"  = b."ParcelID" 
	AND a."UniqueID"  <> b."UniqueID"
WHERE a."PropertyAddress" isnull

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


SELECT PropertyAddress
FROM nashville_housing_data_for_data_cleaning 
--Where PropertyAddress is null
--order by ParcelID

SELECT split_part("PropertyAddress",',',1) AS Address,
SELECT split_part("PropertyAddress",',',2) AS City
FROM nashville_housing_data_for_data_cleaning nhdfdc 

ALTER TABLE nashville_housing_data_for_data_cleaning 
ADD PropertySplitAddress varchar(255);

UPDATE nashville_housing_data_for_data_cleaning 
SET PropertySplitAddress = split_part("PropertyAddress",',',1)

SELECT split_part("PropertyAddress",',',2) AS City
ALTER TABLE nashville_housing_data_for_data_cleaning 
ADD PropertySplitCity varchar(255);

UPDATE nashville_housing_data_for_data_cleaning 
SET PropertySplitCity = split_part("PropertyAddress",',',2)
 

SELECT "OwnerAddress" ,
SPLIT_PART("OwnerAddress",',',1),
SPLIT_PART("OwnerAddress",',',2),
SPLIT_PART("OwnerAddress",',',3) 
FROM nashville_housing_data_for_data_cleaning nhdfdc 

ALTER TABLE nashville_housing_data_for_data_cleaning 
ADD OwnerSplitAddress varchar(255);

ALTER TABLE nashville_housing_data_for_data_cleaning 
ADD OwnerSplitCity varchar(255);

ALTER TABLE nashville_housing_data_for_data_cleaning 
ADD OwnerSplitState varchar(255);

UPDATE nashville_housing_data_for_data_cleaning 
SET OwnerSplitAddress = split_part("OwnerAddress",',',1)

UPDATE nashville_housing_data_for_data_cleaning 
SET OwnerSplitCity = split_part("OwnerAddress",',',2)

UPDATE nashville_housing_data_for_data_cleaning 
SET OwnerSplitState = split_part("OwnerAddress",',',3)
--------------------------------------------------------------------------------------------------------------------------


-- Count the number of "Yes", "No","Y" and "N" in the data set


SELECT Distinct("SoldAsVacant"), Count("SoldAsVacant")
FROM nashville_housing_data_for_data_cleaning nhdfdc 
GROUP BY "SoldAsVacant" 
ORDER BY 2


--Change Y and N to Yes and No in "Sold as Vacant" field

SELECT "SoldAsVacant" 
, CASE WHEN "SoldAsVacant"  = 'Y' THEN 'Yes'
	   WHEN "SoldAsVacant"  = 'N' THEN 'No'
	   ELSE "SoldAsVacant" 
	   END
FROM nashville_housing_data_for_data_cleaning nhdfdc 

UPDATE nashville_housing_data_for_data_cleaning 
SET "SoldAsVacant" =CASE WHEN "SoldAsVacant"  = 'Y' THEN 'Yes'
	   WHEN "SoldAsVacant"  = 'N' THEN 'No'
	   ELSE "SoldAsVacant" 
	   END
	
----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Identifying Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY "ParcelID" ,
				 "PropertyAddress" ,
				 "SalePrice" ,
				 "SaleDate" ,
				 "LegalReference" 
				 ORDER BY
					"UniqueID " 
					) row_num

FROM nashville_housing_data_for_data_cleaning nhdfdc 
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY "PropertyAddress" 


SELECT *
FROM nashville_housing_data_for_data_cleaning




---------------------------------------------------------------------------------------------------------
