/*
Cleaning Data in SQL Queries
*/

SELECT *
FROM PortifolioProject.dbo.NashvileHousing


--Standardize Date Format
SELECT SaleDate, CONVERT(Date, SaleDate)
FROM PortifolioProject.dbo.NashvileHousing

ALTER TABLE PortifolioProject.dbo.NashvileHousing
ADD SalesDateConverted date;

UPDATE NashvileHousing
SET SalesDateConverted = CONVERT(Date, SaleDate)

SELECT SalesDateConverted
FROM PortifolioProject.dbo.NashvileHousing


--Populate Property Address data
SELECT *
FROM PortifolioProject.dbo.NashvileHousing

--Check wether there is NULL address in duplicated ParcelID
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortifolioProject.dbo.NashvileHousing a
JOIN PortifolioProject.dbo.NashvileHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL


--Updates propertyAddress in order to fullfil it properly
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortifolioProject.dbo.NashvileHousing a
JOIN PortifolioProject.dbo.NashvileHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

--Breaking out Address into Individual Comlumns (Adress, City and State)
SELECT PropertyAddress
FROM PortifolioProject.dbo.NashvileHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM PortifolioProject.dbo.NashvileHousing

ALTER TABLE PortifolioProject.dbo.NashvileHousing
ADD PropertySplitAddress nvarchar(255);

UPDATE NashvileHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE PortifolioProject.dbo.NashvileHousing
ADD PropertySplitCity nvarchar(255);

UPDATE NashvileHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT PropertySplitAddress, PropertySplitCity
FROM PortifolioProject.dbo.NashvileHousing


SELECT
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
FROM PortifolioProject.dbo.NashvileHousing


ALTER TABLE PortifolioProject.dbo.NashvileHousing
ADD OwnerSplitAddress nvarchar(255);

UPDATE NashvileHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)

ALTER TABLE PortifolioProject.dbo.NashvileHousing
ADD OwnerSplitCity nvarchar(255);

UPDATE NashvileHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)

ALTER TABLE PortifolioProject.dbo.NashvileHousing
ADD OwnerSplitState nvarchar(255);

UPDATE NashvileHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)

SELECT OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
FROM PortifolioProject.dbo.NashvileHousing


--Checks distinct values in SoldAsVacant
SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant) AS Total
FROM PortifolioProject.dbo.NashvileHousing
GROUP BY SoldAsVacant
ORDER By Total

--Change Y and N to Yes and No in Sold as Vacant field
SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM PortifolioProject.dbo.NashvileHousing

UPDATE PortifolioProject.dbo.NashvileHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END


--Remove Diplicates
WITH RowNumCTE AS(
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
FROM PortifolioProject.dbo.NashvileHousing
)
DELETE --(use SELECT* to check)
FROM RowNumCTE
WHERE row_num > 1


--Delete Unused Columns
ALTER TABLE PortifolioProject.dbo.NashvileHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress