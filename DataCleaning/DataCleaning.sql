select SaleDate from [Portfolio Project]..[Nashville Housing Data for Data Cleaning]
--updating saledate column
update [Nashville Housing Data for Data Cleaning]
set SaleDate = CONVERT(date,saleDate)

select * from [Nashville Housing Data for Data Cleaning]

select PropertyAddress from [Nashville Housing Data for Data Cleaning]

--populating property address as it contains many null values which it should not

select * from [Nashville Housing Data for Data Cleaning] where PropertyAddress is null
order by ParcelID


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress) from [Nashville Housing Data for Data Cleaning] 
a join [Nashville Housing Data for Data Cleaning] b on a.ParcelID=b.ParcelID and a.UniqueID<>b.UniqueID
where a.PropertyAddress is null

update a
set PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
from [Nashville Housing Data for Data Cleaning] 
a join [Nashville Housing Data for Data Cleaning] b on a.ParcelID=b.ParcelID and a.UniqueID<>b.UniqueID
where a.PropertyAddress is null


--breaking out addresses individual parts
select PropertyAddress from [Nashville Housing Data for Data Cleaning]

select SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
 SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) as Place
from [Nashville Housing Data for Data Cleaning]

alter table [Nashville Housing Data for Data Cleaning]
add PropertySplitAddress nvarchar(255),
PropertyCity varchar(255)

update [Nashville Housing Data for Data Cleaning]
set PropertySplitAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1),
PropertyCity= SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress))

select * from [Nashville Housing Data for Data Cleaning]

-- owner address

select OwnerAddress from [Nashville Housing Data for Data Cleaning]

--now by using parsename

select 
PARSENAME(replace(OwnerAddress,',','.'),3),
PARSENAME(replace(OwnerAddress,',','.'),2),
PARSENAME(replace(OwnerAddress,',','.'),1)
from [Nashville Housing Data for Data Cleaning]

alter table[Nashville Housing Data for Data Cleaning]
add OwnerSplitAddress nvarchar(255),
OwnerCity varchar(255),
OwnerState varchar(255)

update [Nashville Housing Data for Data Cleaning]
set OwnerSplitAddress=PARSENAME(replace(OwnerAddress,',','.'),3),
OwnerCity=PARSENAME(replace(OwnerAddress,',','.'),2),
OwnerState=PARSENAME(replace(OwnerAddress,',','.'),1)

select * from [Nashville Housing Data for Data Cleaning]

--SoldAsVacant

select SoldAsVacant,count(SoldAsVacant)
from [Nashville Housing Data for Data Cleaning]
group by SoldAsVacant order by SoldAsVacant


--remove duplicates

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

From [Nashville Housing Data for Data Cleaning]

)
select *
From RowNumCTE
Where row_num > 1



--delete unused columns
--usually done in views
--if ok with changes in original dataset use alter
--if not create a copy be sure about the changes and then alter the original dataset

SELECT *
INTO NashvilleHousing_Copy
FROM [Nashville Housing Data for Data Cleaning]


ALTER TABLE NashvilleHousing_Copy
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;

select * from NashvilleHousing_Copy

