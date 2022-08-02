--Here, we are checking to see if the data was imported correctly
Select * 
From PortfolioProject..drugsComTest_raw

--We see that there are come conditions that were null, so I decided to remove them
Delete 
From PortfolioProject..drugsComTest_raw 
Where condition is null

Select *
From PortfolioProject..drugsComTest_raw
Where condition is null

--I decided to change the date data type from datetime to just date
Alter table PortfolioProject..drugsComTest_raw
alter column date date

--rating per year
Select Year(date) as Years, Count(rating) as total_rating
From PortfolioProject..drugsComTest_raw
Group by year(date)
order by Years

--We now want to see how many people are suffering from a certain condition and which drug they are using
Select drugName, condition, Count(condition) as Total_per_Condition
From PortfolioProject..drugsComTest_raw
Group By condition, drugName
order by Count(condition) desc

--We want to see the most used drug
Select drugName, Count(drugName) as Total_Drugs, condition
From PortfolioProject..drugsComTest_raw
Group By condition, drugName
having Count(drugName) > 400
order By Count(drugName) desc

--We want to see the overall average rating of each drug that has a usefulCount over 300
Select drugName, condition, AVG(rating) as avg_rating
From PortfolioProject..drugsComTest_raw
Where usefulCount > 300
Group by drugName, condition
order by avg_rating desc

--Now, we want to see the least rated drug with the least usefulCounts
Select drugName, AVG(rating) as avg_rating
From PortfolioProject..drugsComTest_raw
Where usefulCount > 100 
Group by drugName, rating
Having avg(rating) < 5
Order by avg_rating 

--drugs with the most useful count per year
Select drugName, Year(date) as Years, Count(usefulCount) as totalCount
From PortfolioProject..drugsComTest_raw
Group by year(date), drugName
Having Count(usefulCount) > Avg(usefulCount)
order by drugName, Years
