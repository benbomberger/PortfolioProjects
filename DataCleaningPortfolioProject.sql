/*

Cleaning Data in SQL Queries

*/

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize SaleDate Format

-- 1st method
SELECT SaleDate, CONVERT(Date, SaleDate) as New
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)


-- 2nd method
SELECT SaleDate, CONVERT(Date, SaleDate) as New
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

SELECT SaleDateConverted
FROM NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress is NULL
ORDER BY ParcelID

/*
 Join the table on itself for comparisons, then look for rows where ParcelID and Property address are both populated, look for rows where
 ParcelID is populated and Property address is null, then use the provided Property address from one ParcelID to populate the null Property
 address of another entry where both ParcelIDs are identical
*/
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is Null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is Null


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

/*
Splitting PropertyAddress into two components (Address and City) by using the Substring method, CHARINDEX with a comma delimiter, and the
LEN method.  Then create two new columns in the table and populate them
*/
SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+2, LEN(PropertyAddress)) AS City
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+2, LEN(PropertyAddress))

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing


/*
 Splitting the OwnerAddress into three distinct components (Address, City, and State) using the PARSENAME method.  This method uses periods as
 the delimiter, so we also use a REPLACE function to swap all commas with periods.
*/

SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

/*
 Values in the SoldAsVacant column are currently Y,N,Yes, or No.  This runs a CASE statement to adjust them appropriately so only 'Yes'
 and 'No' remain.
*/

SELECT Distinct(SoldAsVacant), Count(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE 
	   WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

--------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

/*
 Looking for rows that contain exactly the same information (excluding the UniqueID column).  Any rows that are found to be duplicates are 
 stored in a CTE, then all the rows that are found in the CTE are deleted from the original table.
*/

WITH RowNumCTE AS (
SELECT *,
       ROW_NUMBER() OVER(
	   PARTITION BY ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					ORDER BY 
						UniqueID
						) row_num
FROM PortfolioProject.dbo.NashvilleHousing
--ORDER BY ParcelID
)
/*
 The following line (SELECT *) was replaced with a DELETE to get rid of the data, then swapped back to a SELECT * to verify.
*/
SELECT *
FROM RowNumCTE	
WHERE row_num > 1


--------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

/*
 IMPORTANT: This isn't usually done on the raw data that has been imported.  This is typically done on a view of the data that is 
 displaying additional information that can be truncated.
*/

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

