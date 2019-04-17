DECLARE @CountTotal INT = '0'
DECLARE @DeweyNumberTotal nvarchar(10) = '0'
DECLARE @DeweyCollectionTotal nvarchar(25) = '001 - 099'
CREATE TABLE #Total (Dewey_Number varchar(max), Count INT)

DECLARE @CountTime INT = '0'
DECLARE @DeweyNumberTime nvarchar(10) = '0'
DECLARE @DeweyCollectionTime nvarchar(25) = '001 - 099'
CREATE TABLE #TimeT (Dewey_Number varchar(max), Count INT)

WHILE @CountTotal <= '9'
BEGIN

	INSERT INTO #Total (Dewey_Number, Count)
		SELECT
		@DeweyCollectionTotal AS 'Dewey Number',
		COUNT(*) AS 'Count'
		FROM Polaris.BibliographicRecords br (NOLOCK)
		JOIN Polaris.BibliographicTags bt (NOLOCK) ON br.BibliographicRecordID = bt.BibliographicRecordID
		JOIN Polaris.BibliographicSubfields bs (NOLOCK) ON bt.BibliographicTagID = bs.BibliographicTagID
		JOIN Polaris.CircItemRecords ci (NOLOCK) ON ci.AssociatedBibRecordID = br.BibliographicRecordID
		JOIN Polaris.Organizations org (NOLOCK) ON org.OrganizationID = ci.AssignedBranchID
		JOIN Polaris.Collections coll (NOLOCK) ON coll.CollectionID = ci.AssignedCollectionID
		JOIN Polaris.ItemRecordDetails ird (NOLOCK) on ci.ItemRecordID = ird.ItemRecordID
		WHERE bt.TagNumber = '82'
		AND bs.Subfield = 'a'
		AND bs.Data LIKE @DeweyNumberTotal + '%'
		AND ird.OwningBranchID = '12'
		AND (ci.AssignedCollectionID = '13' OR ci.AssignedCollectionID = '14')
		AND (ci.ItemStatusID = '1' OR ci.ItemStatusID = '2')
	SET @CountTotal = @CountTotal + 1
	SET @DeweyNumberTotal = @DeweyNumberTotal + 1

	IF @CountTotal = 1
		SET @DeweyCollectionTotal = '100 - 199'
	ELSE IF @CountTotal = 2
		SET @DeweyCollectionTotal = '200 - 299'
	ELSE IF @CountTotal = 3
		SET @DeweyCollectionTotal = '300 - 399'
	ELSE IF @CountTotal = 4
		SET @DeweyCollectionTotal = '400 - 499'
	ELSE IF @CountTotal = 5
		SET @DeweyCollectionTotal = '500 - 599'
	ELSE IF @CountTotal = 6
		SET @DeweyCollectionTotal = '600 - 699'
	ELSE IF @CountTotal = 7
		SET @DeweyCollectionTotal = '700 - 799'
	ELSE IF @CountTotal = 8
		SET @DeweyCollectionTotal = '800 - 899'
	ELSE IF @CountTotal = 9
		SET @DeweyCollectionTotal = '900 - 999'
	ELSE
		CONTINUE	
END
WHILE @CountTime <= '9'
BEGIN

	INSERT INTO #TimeT (Dewey_Number, Count)
		SELECT
		@DeweyCollectionTime AS 'Dewey Number',
		COUNT(*) AS 'Count'
		FROM Polaris.BibliographicRecords br (NOLOCK)
		JOIN Polaris.BibliographicTags bt (NOLOCK) ON br.BibliographicRecordID = bt.BibliographicRecordID
		JOIN Polaris.BibliographicSubfields bs (NOLOCK) ON bt.BibliographicTagID = bs.BibliographicTagID
		JOIN Polaris.CircItemRecords ci (NOLOCK) ON ci.AssociatedBibRecordID = br.BibliographicRecordID
		JOIN Polaris.Organizations org (NOLOCK) ON org.OrganizationID = ci.AssignedBranchID
		JOIN Polaris.Collections coll (NOLOCK) ON coll.CollectionID = ci.AssignedCollectionID
		JOIN Polaris.ItemRecordDetails ird (NOLOCK) on ci.ItemRecordID = ird.ItemRecordID
		WHERE bt.TagNumber = '82'
		AND bs.Subfield = 'a'
		AND bs.Data LIKE @DeweyNumberTime + '%'
		AND ird.OwningBranchID = '12'
		AND (ci.AssignedCollectionID = '13' OR ci.AssignedCollectionID = '14')
		AND (ci.ItemStatusID = '1' OR ci.ItemStatusID = '2')
		AND ci.LastCheckOutRenewDate > DATEADD(MONTH,-18,GETDATE())
	SET @CountTime = @CountTime + 1
	SET @DeweyNumberTime = @DeweyNumberTime + 1

	IF @CountTime = 1
		SET @DeweyCollectionTime = '100 - 199'
	ELSE IF @CountTime = 2
		SET @DeweyCollectionTime = '200 - 299'
	ELSE IF @CountTime = 3
		SET @DeweyCollectionTime = '300 - 399'
	ELSE IF @CountTime = 4
		SET @DeweyCollectionTime = '400 - 499'
	ELSE IF @CountTime = 5
		SET @DeweyCollectionTime = '500 - 599'
	ELSE IF @CountTime = 6
		SET @DeweyCollectionTime = '600 - 699'
	ELSE IF @CountTime = 7
		SET @DeweyCollectionTime = '700 - 799'
	ELSE IF @CountTime = 8
		SET @DeweyCollectionTime = '800 - 899'
	ELSE IF @CountTime = 9
		SET @DeweyCollectionTime = '900 - 999'
	ELSE
		CONTINUE	
END

SELECT
	#Total.Dewey_Number AS 'Collection',
	#Total.Count AS 'Total Owned',
	#TimeT.Count AS 'Circulated in the last 18 Months'
FROM #Total
JOIN #TimeT ON #TimeT.Dewey_Number = #Total.Dewey_Number

DROP TABLE #Total, #TimeT