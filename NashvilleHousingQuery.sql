
			/**Data Cleaning Project in SQL**/

select * from Housing

			/**Standardizing Date format **/

select SaleDate,convert(date,SaleDate) from Housing

UPDATE  Housing
SET SaleDate = convert(date,SaleDate)

/**Adding the new Date column**/

ALTER table Housing 
ADD SaleDateConv date;

UPDATE  Housing
SET SaleDateConv = convert(date,SaleDate)

select SaleDateConv from Housing
select * from Housing


			/**Populating Property Address in the place of NULL**/

/**- If the parcel Ids of 2 rows are same then their address must be same too**/
/**Using Self Joint **/

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress) PopulatedAdd
from Housing a
JOIN Housing b
ON a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID 
where a.PropertyAddress is NULL

/**Updating the populated address in the place of NULL**/

UPDATE a
set a.PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from Housing a
JOIN Housing b
ON a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID 
where a.PropertyAddress is NULL

select * from Housing where PropertyAddress is NULL


			/**Breaking PropertyAddress into individual columns(street,city,state) **/

select SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Street from Housing
select SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) as City from Housing

--Adding the new Street,City columns

ALTER table Housing 
ADD PropertyStreet nvarchar(255);

UPDATE  Housing
SET PropertyStreet = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER table Housing 
ADD PropertyCity nvarchar(255);

UPDATE  Housing
SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress))

select PropertyAddress,PropertyStreet,PropertyCity from Housing


			/**Breaking OwnerAddress using PARSENAME() **/

select OwnerAddress,
parsename(replace(OwnerAddress,',','.'),1) as State,
parsename(replace(OwnerAddress,',','.'),2) as City,
parsename(replace(OwnerAddress,',','.'),3) as Street
from Housing

alter table Housing 
add State nvarchar(255);
UPDATE  Housing
SET State = parsename(replace(OwnerAddress,',','.'),1) 

alter table Housing 
add City nvarchar(255);
UPDATE  Housing
SET City = parsename(replace(OwnerAddress,',','.'),2) 

alter table Housing 
add Street nvarchar(255);
UPDATE  Housing
SET Street = parsename(replace(OwnerAddress,',','.'),3) 

select OwnerAddress,Street,City,State from Housing

			/** Changing datavalues Y,N to Yes,No in a column**/

select distinct SoldAsVacant,count(SoldAsVacant) from Housing 
group by SoldAsVacant
order by 2

UPDATE Housing
SET SoldAsVacant = CASE
						when SoldAsVacant = 'Y' then 'Yes'
						when SoldAsVacant = 'N' then 'No'
					END

Select distinct SoldAsVacant from Housing


			/** Identifying Duplicates **/

select * from Housing ;

/**Row numbering after partioning by many required columns, hence row_num > 1 are duplicates**/

WITH RowNumCTE as
(
select *, 
	ROW_NUMBER() over(
	partition by ParcelID,
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
	order by UniqueID ) row_num
from Housing
)
select * from RowNumCTE 
where row_num >1 

		/**Deleting Unused Columns**/

select * from Housing

alter table Housing
drop column OwnerAddress,TaxDistrict 


			/** END **/