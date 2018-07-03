SELECT td.TransactionSubTypeID, tst.TransactionSubTypeCodeDesc, tst.TransactionSubTypeCode, td.numValue, th.OrganizationID, COUNT(*) as TotalCount
FROM PolarisTransactions.Polaris.TransactionDetails as td
JOIN PolarisTransactions.Polaris.TransactionHeaders as th
ON td.TransactionID = th.TransactionID
JOIN PolarisTransactions.Polaris.TransactionSubTypeCodes as tst
ON td.TransactionSubTypeID = tst.TransactionSubTypeID

WHERE td.numValue = 51
AND tst.TransactionSubTypeCode = 51
and th.TransactionDate BETWEEN '2018-06-03 00:00:00' AND '2018-06-09 23:59:59'

GROUP BY td.TransactionSubTypeID, tst.TransactionSubTypeCodeDesc, tst.TransactionSubTypeCode, td.numValue, th.OrganizationID
ORDER BY th.OrganizationID