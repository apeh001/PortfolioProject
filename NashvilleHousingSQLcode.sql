--Selecting the data to check if correct
Select *
From PortfolioProject..NashvilleHousing

--Selecting/Updating the SaleDate
--Since the SaleDate had a time on it, I decided to remove it to make it easier to read
Select NewSaleDate, Convert(date, SaleDate)
From PortfolioProject..NashvilleHousing

Update PortfolioProject..NashvilleHousing
Set SaleDate = Convert(date, SaleDate)

Alter Table NashvilleHousing
Add NewSaleDate date;

Update PortfolioProject..NashvilleHousing
Set NewSaleDate = Convert(Date, SaleDate)

--Populating the adress data
--We did this because there were null values in the PropertyAddress column, and we wanted to populate those cells accurately
Select *
From PortfolioProject..NashvilleHousing
order by ParcelID 

Select a.ParcelId, a.PropertyAddress, b.ParcelId, b.PropertyAddress, Isnull(a.propertyaddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	on a.ParcelId = b.ParcelId
	AND a.UniqueID <> b.UniqueID
Where a.propertyaddress is null

Update a
Set PropertyAddress = Isnull(a.propertyaddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	on a.ParcelId = b.ParcelId
	AND a.UniqueID <> b.UniqueID
Where a.propertyaddress is null

--Breaking Address into individual columns (Address, City, State)
--This made it easier to access certain data within the addresses
Select PropertyAddress
From PortfolioProject..NashvilleHousing

Select
Substring(PropertyAddress, 1, CharIndex(',', PropertyAddress) - 1) as Address
, Substring(PropertyAddress, CharIndex(',', PropertyAddress) + 1, Len(PropertyAddress)) as City

From PortfolioProject..NashvilleHousing

Alter Table PortfolioProject..NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update PortfolioProject..NashvilleHousing
Set PropertySplitAddress = Substring(PropertyAddress, 1, CharIndex(',', PropertyAddress) - 1)

Alter Table PortfolioProject..NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update PortfolioProject..NashvilleHousing
Set PropertySplitCity = Substring(PropertyAddress, CharIndex(',', PropertyAddress) + 1, Len(PropertyAddress))

Select *
From PortfolioProject..NashvilleHousing

Select OwnerAddress
From PortfolioProject..NashvilleHousing

Select
Parsename(Replace(OwnerAddress, ',', '.'), 3),
Parsename(Replace(OwnerAddress, ',', '.'), 2),
Parsename(Replace(OwnerAddress, ',', '.'), 1)
From PortfolioProject..NashvilleHousing

Alter Table PortfolioProject..NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Alter Table PortfolioProject..NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Alter Table PortfolioProject..NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update PortfolioProject..NashvilleHousing
Set OwnerSplitAddress = Parsename(Replace(OwnerAddress, ',', '.'), 3)

Update PortfolioProject..NashvilleHousing
Set OwnerSplitCity = Parsename(Replace(OwnerAddress, ',', '.'), 2)

Update PortfolioProject..NashvilleHousing
Set OwnerSplitState = Parsename(Replace(OwnerAddress, ',', '.'), 1)

Select *
From PortfolioProject..NashvilleHousing

--Changing Y and N to Yes and No in the SoldAsVacant Column
--This allowed us to standardize the Yes and No so it was easier and more accurate when retrieving the data
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group By SoldAsVacant
Order By 2

Select SoldAsVacant,
Case When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
End
From PortfolioProject..NashvilleHousing

Update PortfolioProject..NashvilleHousing
Set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
End

--Removing Duplicates
--It is important in the data to seek out duplicates so we do not get a false output
With RowNumCTE AS (
Select *,
	Row_Number() Over (
	Partition By ParcelId,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order By
					UniqueId
					) row_num


From PortfolioProject..NashvilleHousing
)
Select *
From RowNumCTE
Where row_num > 1
Order By PropertyAddress

--Delete Unused Columns
--Since these columns have either been parsed into new columns or were just not useful, I decided to delete them
Select *
From PortfolioProject..NashvilleHousing

Alter Table PortfolioProject..NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

