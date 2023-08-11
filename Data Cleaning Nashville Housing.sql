--Cleaning Data in SQL Queries

Select *
From PortfolioProject..NashvilleHousing

-- Standardize Date Format

Select SaleDate, Convert(Date,Saledate)
From PortfolioProject..NashvilleHousing

AlTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDate = CONVERT(Date,Saledate)

-- Populate Property Adress

Select *
From PortfolioProject..NashvilleHousing
-- Where property adress is null
Order by ParcelID

Select a.ParcelID, a.propertyAdress, b.ParcelID, b. propertyAdress, ISNULL(a.propertyAdress, b.propertyAdress)
From PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.parcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAdress is null

UPDATE a
SET propertyAddress = ISNULL(a.propertyAddress, b.propertyAddress)
From PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.parcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.propertyAddress is Null


-- Breaking out (Property)Address into individual colums (Adress, City, State)

SELECT
SUBSTRING(propertyAddress, 1, CHARINDEX(',', propertyaddress) -1) as Address
	Substring(propertyAddress, CHARINDEX(',', propertyaddress) +1, LEN(propertyAddress)) as Address

From portfolioProject..NashvilleHousing


AlTER TABLE NashvilleHousing
Add PropertyAdressSplit Nvarchar(255);

Update NashvilleHousing
SET PropertyAddressSplit = SUBSTRING(propertyAddress, 1, CHARINDEX(',', propertyaddress) -1)

AlTER TABLE NashvilleHousing
Add PropertyCitySplit Nvarchar(255);

Update NashvilleHousing
SET PropertyCitySplit = Substring(propertyAddress, CHARINDEX(',', propertyaddress) +1, LEN(propertyAddress))



-- Breaking out (owner)Address into individual colums (Adress, City, State)

Select OwnerAddress
From PortfolioProject..NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From PortfolioProject..NashvilleHousing

AlTER TABLE NashvilleHousing
Add OwneryAdressSplit Nvarchar(255);

Update NashvilleHousing
SET OwnerAdressSplit = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

AlTER TABLE NashvilleHousing
Add OwnerCitySplit Nvarchar(255);

Update NashvilleHousing
SET OwnerCitySplit = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

AlTER TABLE NashvilleHousing
Add OwnerStateSplit Nvarchar(255);

Update NashvilleHousing
SET OwnerStateSplit = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


-- Change Y & N to Yes & No in "Sold as vacant" field

Select distinct(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant
Order by 2


Select SoldAsVacant
, CASE when SoldAsVacant = 'Y' THEN 'Yes'
	   when SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'Yes'
	   when SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


--REMOVE duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject..NashvilleHousing
-- Order by ParcelID
)
DELETE
From RowNumCTE
where row_num > 1
-- REMOVED 104 duplicates


-- DELETE unused colums

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate, 