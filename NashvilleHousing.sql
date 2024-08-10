-- Cleaning Data in SQL

Select *
From HousingPortfolio..NashvilleHousing;

-- Populate Property Address

Select *
From HousingPortfolio..NashvilleHousing
Where PropertyAddress is null
order by ParcelID
;

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From HousingPortfolio..NashvilleHousing a
JOIN HousingPortfolio..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null
;

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From HousingPortfolio..NashvilleHousing a
JOIN HousingPortfolio..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null
;

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address2
From HousingPortfolio..NashvilleHousing
;

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1);

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress));


Select OwnerAddress
From HousingPortfolio..NashvilleHousing;

Select 
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From HousingPortfolio..NashvilleHousing;


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3);

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2);

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1);

-- Standardize SoldAsVacant fields

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From HousingPortfolio..NashvilleHousing
Group by SoldAsVacant
Order by 2
;

Select SoldAsVacant
, CASE 
		When SoldAsVacant = 'Y' then 'Yes'
		When SoldAsVacant = 'N' then 'No'
		Else SoldAsVacant
  End
From HousingPortfolio..NashvilleHousing
;

Update NashvilleHousing
SET SoldAsVacant =
CASE 
		When SoldAsVacant = 'Y' then 'Yes'
		When SoldAsVacant = 'N' then 'No'
		Else SoldAsVacant
End
;

-- Remove Duplicates, would not do to raw data

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY 
		ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
		ORDER BY
			UniqueID
	) row_num
From HousingPortfolio..NashvilleHousing
)
-- DELETE
Select *
From RowNumCTE
Where row_num>1
-- order by ParcelID
;

Select *
From HousingPortfolio..NashvilleHousing;

ALTER TABLE HousingPortfolio..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress;
