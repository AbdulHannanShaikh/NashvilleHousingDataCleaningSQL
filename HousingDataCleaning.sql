SELECT *
FROM NashvilleHousingData..NashvilleHousingDataTable;

--UPDATE NashvilleHousingDataTable
--SET SaleDate = CONVERT(Date,SaleDate)

-- Standardize Date Format

ALTER TABLE NashvilleHousingDataTable
ADD SaleDateConverted Date;

UPDATE NashvilleHousingDataTable
SET SaleDateConverted = CONVERT(Date,SaleDate);

SELECT SaleDateConverted
FROM NashvilleHousingData..NashvilleHousingDataTable;

-- Populate Property Address data

SELECT A.ParcelID,A.PropertyAddress, A.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM NashvilleHousingDataTable A
JOIN NashvilleHousingDataTable B ON A.ParcelID = B.ParcelID
								AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL;

UPDATE A
SET A.PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM NashvilleHousingDataTable A
JOIN NashvilleHousingDataTable B ON A.ParcelID = B.ParcelID
								AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL;

-- Spliting PropertyAdress using SUBSTRING

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM NashvilleHousingDataTable;

ALTER TABLE NashvilleHousingDataTable
ADD PropertySplitAddress NVARCHAR(255), PropertySplitCity NVARCHAR(255)

UPDATE NashvilleHousingDataTable
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ), PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress));

-- Spliting OwnerAdress using PARSENAME

SELECT PARSENAME(REPLACE(OwnerAddress, ',','.'),3), PARSENAME(REPLACE(OwnerAddress, ',','.'),2), PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
FROM NashvilleHousingDataTable;

ALTER TABLE NashvilleHousingDataTable
ADD OwnerSplitAddress NVARCHAR(255), OwnerSplitCity NVARCHAR(255), OwnerSplitState NVARCHAR(255)

UPDATE NashvilleHousingDataTable
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3), OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2), OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)

-- Change Y and N to Yes and No respectively in SoldAsVacant Column

SELECT SoldAsVacant, 
		CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
			 WHEN SoldAsVacant = 'N' THEN 'No'
			 ELSE SoldAsVacant
		END
FROM NashvilleHousingDataTable;

UPDATE NashvilleHousingDataTable
SET SoldAsVacant = CASE 
			 WHEN SoldAsVacant = 'Y' THEN 'Yes'
			 WHEN SoldAsVacant = 'N' THEN 'No'
			 ELSE SoldAsVacant
				   END

-- Remove duplicates

WITH RowNumCTE AS(
SELECT *, ROW_NUMBER() 
		  OVER ( PARTITION BY ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference
				 ORDER BY UniqueID) RowNum
FROM NashvilleHousingDataTable)

SELECT * 
FROM RowNumCTE
WHERE RowNum > 1
ORDER BY PropertyAddress;

-- Remove Unused Columns

ALTER TABLE NashvilleHousingDataTable
DROP COLUMN PropertyAddress, SalePrice, OwnerAddress,TaxDistrict, Acreage