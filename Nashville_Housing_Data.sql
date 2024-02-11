select * 
from Nashville_Housing_Data
Fetch First 10 rows only;

/*cleaning data in SQL queries*/

select *
from Nashville_Housing_Data

/*populate Property Address data (null values present in this column)*/
/*first check for the PropertyAddress column: select PropertyAddress*/
select *
from Nashville_Housing_Data
/*where PropertyAddress is null*/
order by ParcelID /*ParcelID is same for Property with same address, if two data has same parcel id then populate the corresponding null property address with the one that shares same parcel id*/

alter table Nashville_Housing_Data rename column uniqueID_ to uniqueID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, COALESCE(a.PropertyAddress,b.PropertyAddress)
from Nashville_Housing_Data a
join Nashville_Housing_Data b
    on a.ParcelID = b.ParcelID
    and a.uniqueId != b.uniqueID
where a.PropertyAddress is null

update Nashville_Housing_Data a
set a.PropertyAddress = (
    select COALESCE(max(b.PropertyAddress), a.PropertyAddress)
    from Nashville_Housing_Data b
    where a.ParcelID = b.ParcelID
    and a.uniqueId != b.uniqueID
)
where a.PropertyAddress is null;

/*breaking out address into individual columns(address, city, state)*/
/*first: PropertyAddress*/
select replace(PropertyAddress, ',', '') as address, substr(Propertyaddress, instr(Propertyaddress, ' ', -1) + 1) as city
from Nashville_Housing_Data;

alter table Nashville_Housing_Data
add address varchar(255);

update Nashville_Housing_Data
set address = (select replace(PropertyAddress, ',', '') 
from dual);

alter table Nashville_Housing_Data
add city varchar(255);

update Nashville_Housing_Data
set city = (select substr(Propertyaddress, instr(Propertyaddress, ' ', -1) + 1)
from dual);

select *
from Nashville_Housing_Data

/*second: OwnerAddress*/
select OwnerAddress
from Nashville_Housing_Data

select replace(OwnerAddress, ',', '') as owneraddress, substr(OwnerAddress, instr(OwnerAddress, ' ', -1) + 1) as OwnerState
from Nashville_Housing_Data;


alter table Nashville_Housing_Data
add OwnerState varchar(255);

update Nashville_Housing_Data
set OwnerState = (select substr(OwnerAddress, instr(OwnerAddress, ' ', -1) + 1)
from dual);

select *
from Nashville_Housing_Data

/*change Y and N to Yes and No in 'Sold as Vacant' field*/
select SoldAsVacant, Count(*)
from Nashville_Housing_Data
group by SoldAsVacant
order by SoldAsVacant;

select SoldAsVacant, 
case when SoldAsVacant = 'Y' then 'Yes'  
     when SoldAsVacant = 'N' then 'No'  
     else SoldAsVacant
     end
from Nashville_Housing_Data

update Nashville_Housing_Data
set SoldAsVacant = case 
                        when SoldAsVacant = 'Y' then 'Yes'  
                        when SoldAsVacant = 'N' then 'No'  
                        else SoldAsVacant
                    end;

select *
from Nashville_Housing_Data

/*remove duplicates*/
delete from Nashville_Housing_Data
where rowid in (
    select rowid
    from (
        select rowid, row_number() over (partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference oreder by uniqueID) as row_num
        from Nashville_Housing_Data
    ) Subquery
    where row_num > 1
);

select *
from Nashville_Housing_Data

/*delete unused columns*/
alter table Nashville_Housing_Data
drop column OwnerAddress;

alter table Nashville_Housing_Data
drop column TaxDistrict;

alter table Nashville_Housing_Data
drop column PropertyAddress;

select *
from Nashville_Housing_Data
