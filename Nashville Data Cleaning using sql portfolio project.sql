-- Cleaning Data in SQL Queries


Select *
from PortfolioProject.dbo.NashvilleHousing

--Standardize Date Format
-- Convert the SaleDate column from DateTime to only Date format

Select SaleDate2,CONVERT(Date,SaleDate)
from PortfolioProject.dbo.NashvilleHousing

ALTER Table NashvilleHousing
Add SaleDate2 Date;

Update NashvilleHousing
SET SaleDate2 = CONVERT(Date,SaleDate)


--Populate Property Address Data

Select *
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID

--doing self join
Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null

--Breaking out Address into Individual Columns(Address,City,State)

Select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

select
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address
,SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS Address

from PortfolioProject.dbo.NashvilleHousing

ALTER Table PortfolioProject.dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) 

ALTER Table PortfolioProject.dbo.NashvilleHousing
Add PropertySplitCity Varchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) 

select OwnerAddress
from PortfolioProject.dbo.NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from PortfolioProject.dbo.NashvilleHousing

--Now we have add those columns and then we need to add those values

ALTER Table PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)


ALTER Table PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitCity Varchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER Table PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitState Varchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

select * from PortfolioProject.dbo.NashvilleHousing


--Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant) ,COUNT(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2


SELECT SoldAsVacant
,CASE when SoldAsVacant = 'Y' THEN 'Yes'
	  when SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  end
from PortfolioProject.dbo.NashvilleHousing

Update PortfolioProject.dbo.NashvilleHousing
Set SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'Yes'
	  when SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  end

--Remove Duplicates
--Using CTE and it is basically like a temp table


WITH RowNumCTE AS(
select *,
	Row_Number() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by
					UniqueID
					) row_num
from PortfolioProject.dbo.NashvilleHousing
)
Select *
From RowNumCTE
where row_num >1

--Delete Unused Columns
order by PropertyAddress

--To delete duplicate row

WITH RowNumCTE AS(
select *,
	Row_Number() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by
					UniqueID
					) row_num
from PortfolioProject.dbo.NashvilleHousing
)
Delete 
From RowNumCTE
where row_num >1
--order by PropertyAddress

--Delete Unused Columns

Select *
from PortfolioProject.dbo.NashvilleHousing

ALTER TABLE  PortfolioProject.dbo.NashvilleHousing
Drop Column SaleDate
