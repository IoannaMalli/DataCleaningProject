
-- EXPLORE THE DATA SET ---

SELECT TOP (10) * FROM [SQLproject].[dbo].[Nashville]

-- STANDARDIZE DATE FORMAT -- 

SELECT SaleDate, CONVERT(Date, SaleDate) 
FROM  [SQLproject].[dbo].[Nashville]

ALTER TABLE [SQLproject].[dbo].[Nashville] 
ADD SaleDateConverted DATE

UPDATE [SQLproject].[dbo].[Nashville] 
SET SaleDateConverted = CONVERT(Date, SaleDate)

-- POPULATE PROPERTY ADDRESS DATA ( using the PropertyAddress of records with the same ParcelID)  -- 


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, B.PropertyAddress
FROM [SQLproject].[dbo].[Nashville] a
JOIN [SQLproject].[dbo].[Nashville] b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]

-- Above we observe that for the same ParcelId, there are records that the PropertyAddress in null --
-- and records that it is known. we can use that to populate the null values -- 

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress) 
FROM [SQLproject].[dbo].[Nashville] a
JOIN [SQLproject].[dbo].[Nashville] b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]

-- BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)--


ALTER TABLE Nashville
ADD PropertySplitAddress Nvarchar(250)

UPDATE Nashville 
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) 

ALTER TABLE Nashville
ADD PropertySplitCity Nvarchar(250)

UPDATE Nashville 
SET PropertySplitCity = SUBSTRING(PropertyAddress,  CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) 

SELECT PropertySplitAddress, PropertySplitCity 
FROM [SQLproject].[dbo].[Nashville]

-- do the same for owner address -- 
-- Parsename returns the specified part of an object name. It works with periods '.' --

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM [SQLproject].[dbo].[Nashville]

ALTER TABLE Nashville 
ADD OwnerSplitAddress Nvarchar(255) 

UPDATE Nashville 
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3) 

ALTER TABLE Nashville 
ADD OwnerSplitCity Nvarchar(255) 

UPDATE Nashville 
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2) 

ALTER TABLE Nashville 
ADD OwnerSplitState Nvarchar(255) 

UPDATE Nashville 
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1) 

-- Change Y and N to Yes and No is "Sold as Vacant" field --

SELECT DISTINCT(SoldAsVacant), Count(SoldAsVacant)
From [SQLproject].[dbo].[Nashville]
GROUP BY SoldAsVacant

-- Yes and No have been recorded as both "Yes"/"No" and "Y"/"N" -- 

UPDATE Nashville
SET SoldAsVacant = (CASE WHEN SoldAsVacant = 'Y' THEN 'Yes' 
						 WHEN SoldAsVacant = 'N' THEN 'No' 
						 ELSE SoldAsVacant
						 END)

-- REMOVE DUPLICATES -- 

WITH RowNumCTE AS(
SELECT *, 
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID, 
				 PropertyAddress,
				 SalePrice,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From [SQLproject].[dbo].[Nashville]
)
DELETE 
FROM RowNumCTE
WHERE row_num >1 

-- Delete Unused Columns -- 

ALTER TABLE [SQLproject].[dbo].[Nashville]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate 

-- Inspect Everything -- 
Select * 
FROM [SQLproject].[dbo].[Nashville]
