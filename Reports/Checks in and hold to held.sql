DECLARE @StartDate DATETIME, @EndDate DATETIME    
SET @StartDate = DATEADD(mm, DATEDIFF(mm, 0, getdate()) - 1, 0)    
SET @EndDate = dateadd(mm, 1, @StartDate)

CREATE TABLE #CheckIn (Name varchar(50), Number_Check_Ins INT)
CREATE TABLE #Holds (Name varchar(50), Number_Holds_Held INT)

INSERT INTO
	#CheckIn(Name, Number_Check_Ins)
		SELECT 
			ORG.DisplayName,
			COUNT(*) AS 'Count'
		FROM Polaris.TransactionHeaders TH (nolock)
		INNER JOIN Polaris.TransactionDetails TD (nolock) ON TH.TransactionID = TD.TransactionID
			AND TD.TransactionSubTypeID = 128
			AND TD.numvalue <> 45 --Power Pack Checkin
			AND TD.numValue <> 46 -- Mobile PAC Checkin
			AND TD.numValue <> 47 -- Third party check-in
			AND TD.numValue <> 3 -- Inventory
		INNER JOIN Polaris.TransactionTypes TT (nolock) ON TH.TransactionTypeID = TT.TransactionTypeID
		INNER JOIN Polaris.Polaris.Organizations ORG (nolock) ON TH.OrganizationID = ORG.OrganizationID
		WHERE TT.TransactionTypeID = 6002
			AND th.TransactionDate BETWEEN @StartDate AND @EndDate
		GROUP BY org.DisplayName 
	


INSERT INTO
	#Holds(Name, Number_Holds_Held)
		SELECT
			ORG.DisplayName,
			COUNT(*) AS 'Count'
		FROM Polaris.TransactionHeaders TH (nolock)
		INNER JOIN Polaris.TransactionDetails TD (nolock) ON TH.TransactionID = TD.TransactionID
			AND TD.TransactionSubTypeID = 33
			AND (TD.numvalue = 0 OR TD.numValue IS NULL)
		INNER JOIN Polaris.TransactionTypes TT (nolock) ON TH.TransactionTypeID = TT.TransactionTypeID
		INNER JOIN Polaris.Polaris.Organizations ORG (nolock) ON TH.OrganizationID = ORG.OrganizationID
		WHERE TT.TransactionTypeID = 6006
			AND th.TransactionDate BETWEEN @StartDate AND @EndDate
		GROUP BY org.DisplayName 
	
SELECT #CheckIn.Name, 
SUM(#CheckIn.Number_Check_Ins) AS 'Number of Check In',
SUM(#Holds.Number_Holds_Held) AS 'Number of Holds to Held' , 
SUM(#CheckIn.Number_Check_Ins + #Holds.Number_Holds_Held) AS 'Total'
FROM #CheckIn
LEFT JOIN #Holds ON #Checkin.Name = #Holds.Name
GROUP BY #CheckIn.Name WITH ROLLUP
DROP TABLE #CheckIn, #Holds