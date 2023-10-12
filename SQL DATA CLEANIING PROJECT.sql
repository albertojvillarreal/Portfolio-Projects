------Cleaning Data in SQL Queries------

Select *
From [Portfolio Project].dbo.NasvilleHousing





-----Standardize Date Format------


Select SaleDateConverted, CONVERT(Date,SaleDate)
From [Portfolio Project].dbo.NasvilleHousing

Update NasvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE [Portfolio Project].dbo.NasvilleHousing	
Add SaleDateConverted Date;

Update NasvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)





----- Populate Property Address Data-----

Select *
From [Portfolio Project]..NasvilleHousing
--Where PropertyAddress is null
Order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From [Portfolio Project]..NasvilleHousing a
JOIN [Portfolio Project]..NasvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From [Portfolio Project]..NasvilleHousing a
JOIN [Portfolio Project]..NasvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null





-----Breaking out Address into Individual Columns (Address, City, State) ------


Select PropertyAddress
From [Portfolio Project]..NasvilleHousing
--Where PropertyAddress is null
--Order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address

From [Portfolio Project]..NasvilleHousing


ALTER TABLE [Portfolio Project]..NasvilleHousing
Add PropertySplitAddress Nvarchar (255);

Update NasvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


ALTER TABLE [Portfolio Project]..NasvilleHousing
Add PropertySplitCity Nvarchar (255);

Update NasvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


Select *
From [Portfolio Project]..NasvilleHousing






Select OwnerAddress
From [Portfolio Project]..NasvilleHousing

 
Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From [Portfolio Project]..NasvilleHousing



ALTER TABLE [Portfolio Project]..NasvilleHousing
Add OwnerSplitAddress Nvarchar (255);

Update NasvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)



ALTER TABLE [Portfolio Project]..NasvilleHousing
Add OwnerSplitCity Nvarchar (255);

Update NasvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE [Portfolio Project]..NasvilleHousing
Add OwnerSplitState Nvarchar (255);

Update NasvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)





----- Change Y and N to YES and NO in "Sold as Vacant" field-----

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From [Portfolio Project]..NasvilleHousing
Group by SoldAsVacant
Order by 2



Select SoldAsVacant
,  CASE WHEN SoldAsVacant = 'Y' THEN 'Yes' 
		WHEN SoldAsVacant = 'N' THEN 'No'	
		ELSE SoldAsVacant
		END
From [Portfolio Project]..NasvilleHousing


Update NasvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes' 
		WHEN SoldAsVacant = 'N' THEN 'No'	
		ELSE SoldAsVacant
		END





---- Remove Duplicates-----

WITH RowNumCTE AS (
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
				
From [Portfolio Project]..NasvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
WHERE row_num > 1
--Order by PropertyAddress











---- Delete Unused Columns-----

Select *
From [Portfolio Project]..NasvilleHousing


ALTER TABLE [Portfolio Project]..NasvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE [Portfolio Project]..NasvilleHousing
DROP COLUMN SaleDate