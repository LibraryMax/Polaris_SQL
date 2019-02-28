-- ItemRecordDetails -> CircItemRecords -> BibliographicRecords
-- 71 and 72


CREATE TABLE #Temp(BibliographicRecordID int, ACID int, IRID int, Title varchar(255), Author varchar(255), Call_Number int)
INSERT INTO #Temp(BibliographicRecordID, ACID, IRID, Title, Author, Call_Number)(
	SELECT DISTINCT br.BibliographicRecordID, cir.AssignedCollectionID, ird.ItemRecordID, br.BrowseTitle, br.BrowseAuthor, br.BrowseCallNo
	FROM Polaris.BibliographicRecords br (NOLOCK)
	JOIN Polaris.CircItemRecords cir (NOLOCK)
	ON br.BibliographicRecordID = cir.AssociatedBibRecordID
	JOIN Polaris.ItemRecordDetails ird (NOLOCK)
	ON cir.ItemRecordID = ird.ItemRecordID
	WHERE cir.AssignedCollectionID = 71 OR cir.AssignedCollectionID = 72
)
SELECT DISTINCT x.BibliographicRecordID, x.Title, x.Author, x.Call_Number
FROM #Temp as x
JOIN (
	SELECT BibliographicRecordID
	FROM #Temp
	GROUP by BibliographicRecordID
	HAVING count(DISTINCT ACID) > 1
) AS y
ON x.BibliographicRecordID = y.BibliographicRecordID
ORDER BY x.BibliographicRecordID
DROP TABLE #Temp