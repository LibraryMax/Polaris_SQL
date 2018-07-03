DECLARE @StartDate DATETIME, @EndDate DATETIME
SET @StartDate = '2018-06-09 00:00:00'
SET @EndDate = '2018-06-09 23:59:59'

SELECT ORG.OrganizationID, ORG.DisplayName, Count(*) as TotalSelfCheckCircs
Into #TempSelfChecks2
FROM PolarisTransactions.Polaris.TransactionHeaders AS Headers WITH(NOLOCK)
INNER JOIN PolarisTransactions.Polaris.TransactionDetails AS Details WITH(NOLOCK)
ON Headers.TransactionID = Details.TransactionID 
INNER JOIN Polaris.Polaris.Organizations AS ORG WITH(NOLOCK)
ON Headers.OrganizationID = ORG.OrganizationID
WHERE Headers.TransactionTypeID = 6001 
AND Headers.TransactionDate BETWEEN @StartDate AND @EndDate
AND Details.TransactionSubTypeID = 145
AND Details.numValue in (12)
GROUP BY ORG.OrganizationID, ORG.DisplayName
ORDER BY ORG.DisplayName

SELECT ORG.OrganizationID, ORG.DisplayName, Count(*) as TotalCircs
Into #TempTotal2
FROM PolarisTransactions.Polaris.TransactionHeaders AS [HEADERS]
INNER JOIN PolarisTransactions.Polaris.TransactionDetails AS [DETAILS]
ON HEADERS.TransactionID = DETAILS.TransactionID
AND DETAILS.TransactionSubTypeID = 145
AND details.numValue <> 13
AND DETAILS.numValue <> 41
AND DETAILS.numValue <> 42
AND DETAILS.numValue <> 43
AND DETAILS.numValue <> 44
INNER JOIN Polaris.Polaris.Organizations AS [ORG]
ON Headers.OrganizationID = ORG.OrganizationID
WHERE TransactionTypeID = 6001
and headers.TransactionDate BETWEEN @StartDate AND @EndDate 
and headers.OrganizationID <> 4
and headers.OrganizationID <> 9
and headers.OrganizationID <> 14
GROUP BY ORG.OrganizationID, ORG.DisplayName
ORDER BY ORG.DisplayName

SELECT ORG.OrganizationID, org.DisplayName as [Branch], COUNT(*) AS [Circ NO Renew]  
into #TempDeskCheck
FROM PolarisTransactions.Polaris.TransactionHeaders AS [HEADERS]
	INNER JOIN PolarisTransactions.Polaris.TransactionDetails AS [DETAILS]
		ON HEADERS.TransactionID = DETAILS.TransactionID
		AND DETAILS.TransactionSubTypeID = 145
		and details.numValue = 15  --circ checkout and renewal
	LEFT OUTER JOIN PolarisTransactions.Polaris.TransactionDetails AS [RENEW]
		ON RENEW.TransactionID = HEADERS.TransactionID
		AND RENEW.TransactionSubTypeID = 124  --renewal
	INNER JOIN Polaris.Polaris.Organizations AS [ORG]
		ON Headers.OrganizationID = ORG.OrganizationID
WHERE TransactionTypeID = 6001
--and headers.TransactionDate BETWEEN @StartDate AND @EndDate 
and headers.TransactionDate BETWEEN @StartDate AND @EndDate
AND RENEW.numValue IS NULL
GROUP BY ORG.OrganizationID, ORG.DisplayName
ORDER BY ORG.DisplayName

SELECT ORG.OrganizationID, ORG.DisplayName as [Branch], Count(*) AS [Count]
INTO #tempDeskRenewal
	FROM PolarisTransactions.Polaris.TransactionHeaders AS Headers WITH(NOLOCK)
	INNER JOIN PolarisTransactions.Polaris.TransactionDetails AS Details WITH(NOLOCK)
		ON Headers.TransactionID = Details.TransactionID	
	LEFT OUTER JOIN PolarisTransactions.Polaris.TransactionDetails AS D2 WITH(NOLOCK)
		ON D2.TransactionID = Headers.TransactionID
		AND D2.TransactionSubTypeID = 124
	INNER JOIN Polaris.Polaris.Organizations AS ORG WITH(NOLOCK)
		ON Headers.OrganizationID = ORG.OrganizationID
WHERE Headers.TransactionTypeID = 6001 
	--AND Headers.TransactionDate BETWEEN @StartDate AND @EndDate
	and headers.TransactionDate BETWEEN @StartDate AND @EndDate
	AND Details.TransactionSubTypeID = 145
	AND Details.numValue in (15)
		AND D2.numValue IS NOT NULL
GROUP BY ORG.OrganizationID, ORG.DisplayName
ORDER BY ORG.DisplayName

SELECT tt.OrganizationID, tt.DisplayName, tdc.[Circ NO Renew] as CircCheck, tdr.Count as CircRenew, ts.TotalSelfCheckCircs, tt.TotalCircs,
SUM(tdr.Count + ts.TotalSelfCheckCircs + tdc.[Circ NO Renew]) AS TotalCalculate
FROM #TempTotal2 tt
INNER JOIN #TempSelfChecks2 ts 
ON ts.OrganizationID = tt.OrganizationID
INNER JOIN #TempDeskCheck tdc
ON ts.OrganizationID = tdc.OrganizationID
INNER JOIN #tempDeskRenewal tdr
ON ts.OrganizationID = tdr.OrganizationID
GROUP BY tt.OrganizationID, tt.DisplayName, tdc.[Circ NO Renew], tdr.Count, ts.TotalSelfCheckCircs, tt.TotalCircs

DROP TABLE #TempSelfChecks2
DROP TABLE #TempTotal2
DROP TABLE #TempDeskCheck
DROP TABLE #tempDeskRenewal