
--Cleaning data in SQL
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

--Standardize date format

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted  Date

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

--Populate Property Address data

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
WHERE PropertyAddress is null


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL( a.propertyaddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
ON a.ParcelID= b.ParcelID
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL( a.propertyaddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
ON a.ParcelID= b.ParcelID
WHERE a.PropertyAddress is null

--Breaking out address into individual columns (Address, City, State)


SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address 
,SUBSTRING (PropertyAddress,CHARINDEX(',',PropertyAddress) +1, LEN (PropertyAddress)) as City  
FROM PortfolioProject.dbo.NashvilleHousing


ALTER TABLE  PortfolioProject.dbo.NashvilleHousing
ADD PropertyAddressSplit NVARCHAR (255)

UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertyAddressSplit = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

ALTER TABLE  PortfolioProject.dbo.NashvilleHousing
ADD PropertyCity NVARCHAR (255)

UPDATE  PortfolioProject.dbo.NashvilleHousing
SET PropertyCity = SUBSTRING (PropertyAddress,CHARINDEX(',',PropertyAddress) +1, LEN (PropertyAddress))

--SEPERATING OWNER ADDRESS

SELECT 
PARSENAME(REPLACE(owneraddress,',','.'),3),
PARSENAME(REPLACE(owneraddress,',','.'),2),
PARSENAME(REPLACE(owneraddress,',','.'),1)
FROM PortfolioProject.dbo.NashvilleHousing


ALTER TABLE  PortfolioProject.dbo.NashvilleHousing
ADD NewOwnerAddress NVARCHAR (255)


ALTER TABLE  PortfolioProject.dbo.NashvilleHousing
ADD OwnerCity NVARCHAR (255)


ALTER TABLE  PortfolioProject.dbo.NashvilleHousing
ADD OwnerState NVARCHAR (255)


UPDATE  PortfolioProject.dbo.NashvilleHousing
SET NewOwnerAddress =PARSENAME(REPLACE(owneraddress,',','.'),3)

UPDATE  PortfolioProject.dbo.NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(owneraddress,',','.'),2)

UPDATE  PortfolioProject.dbo.NashvilleHousing
SET OwnerState= PARSENAME(REPLACE(owneraddress,',','.'),1)

--CHANGE Y and N to Yes and No in "Sold as Vacant" field

SELECT SoldAsVacant,
CASE
WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant= 'N' THEN 'No'
ELSE SoldAsVacant
END
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE
WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant= 'N' THEN 'No'
ELSE SoldAsVacant
END

--Remove Duplicates


WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID, 
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY UniqueID
			 ) row_num
FROM PortfolioProject.dbo.NashvilleHousing )

DELETE
FROM RowNumCTE
WHERE row_num >1
--ORDER BY PropertyAddress

----DELETE UNUSED COLUMNS

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress



