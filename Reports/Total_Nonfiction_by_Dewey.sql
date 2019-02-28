if OBJECT_ID('Polaris.dbo.MaxT') is not null
drop table Polaris.dbo.MaxT
GO

DECLARE @DEWEYNUMBER VARCHAR(50) = 0
DECLARE @ONES VARCHAR(50) = 0
DECLARE @id VARCHAR(50) = 0
DECLARE @FRONT VARCHAR(50) = 'J  00'
DECLARE @FRONTYA VARCHAR(50) = 'YA  00'

CREATE TABLE MaxT ("ID" VARCHAR(50),
					"CallNumber" VARCHAR(50),
					"TotalNumberJ_12" int,
					"TotalNumberJ_6" int,
					"TotalNumberYA_12" int,
					"TotalNumberYA_6" int)

WHILE @DEWEYNUMBER < = 1000
	BEGIN
		INSERT INTO MaxT (CallNumber, TotalNumberJ_12, TotalNumberJ_6, TotalNumberYA_12, TotalNumberYA_6, ID)
		SELECT 
			CONCAT(@FRONT, @DEWEYNUMBER), 
			SUM(CASE WHEN col.CollectionID = 36
			AND (DATEPART(yy, br.FirstAvailableDate) > = 2006 AND DATEPART(yy, br.FirstAvailableDate) < = 2011)
			AND vi.CallNumber LIKE @FRONT + @DEWEYNUMBER +'%' THEN 1 ELSE 0 END),
			SUM(CASE WHEN (col.CollectionID = 36 OR col.CollectionID = 37)
			AND (DATEPART(yy, br.FirstAvailableDate) > = 2012 AND DATEPART(yy, br.FirstAvailableDate) < = 2018)
			AND vi.CallNumber LIKE @FRONT + @DEWEYNUMBER +'%' THEN 1 ELSE 0 END),
			SUM(CASE WHEN col.CollectionID = 59 
			AND (DATEPART(yy, br.FirstAvailableDate) > = 2006 AND DATEPART(yy, br.FirstAvailableDate) < = 2011)
			AND vi.CallNumber LIKE @FRONTYA + @DEWEYNUMBER +'%' THEN 1 ELSE 0 END),
			SUM(CASE WHEN (col.CollectionID = 59 OR col.CollectionID = 60)
			AND (DATEPART(yy, br.FirstAvailableDate) > = 2012 AND DATEPART(yy, br.FirstAvailableDate) < = 2018)
			AND vi.CallNumber LIKE @FRONTYA + @DEWEYNUMBER +'%' THEN 1 ELSE 0 END),
			@id
		From polaris.BibliographicRecords br (nolock)
		JOIN Polaris.CircItemRecords circ (nolock)
		ON circ.AssociatedBibRecordID = br.BibliographicRecordID 
		JOIN Polaris.Collections col (nolock)
		ON circ.AssignedCollectionID = col.CollectionID
		JOIN Polaris.ViewItemRecords vi (nolock)
		ON circ.ItemRecordID = vi.ItemRecordID

		IF @DEWEYNUMBER < 9
		BEGIN
			SET @ONES = @ONES + 1
			SET @DEWEYNUMBER = @ONES
			SET @id = @id + 1
		END
		ELSE IF @DEWEYNUMBER > = 9 AND @DEWEYNUMBER < = 98
		BEGIN
			SET @ONES = @ONES + 1
			SET @DEWEYNUMBER = @ONES
			SET @FRONT = 'J  0'
			SET @FRONTYA = 'YA  0'
			SET @id = @id + 1
		END
		ELSE IF @DEWEYNUMBER > = 99
		BEGIN
			SET @ONES = @ONES + 1
			SET @DEWEYNUMBER = @ONES
			SET @FRONT = 'J  '
			SET @FRONTYA = 'YA  '
			SET @id = @id + 1
		END
	END;
--SELECT * FROM MaxT


SELECT t.CallNumber, t.Total_J_6, t.Total_J_12, Total_YA_6, Total_YA_12
FROM (
	SELECT ID, CallNumber,
	SUM(TotalNumberJ_6) OVER (Partition by (ID)/10) as Total_J_6,
	SUM(TotalNumberJ_12) OVER (Partition by (ID)/10) as Total_J_12,
	SUM(TotalNumberYA_6) OVER (Partition by (ID)/10) as Total_YA_6,
	SUM(TotalNumberYA_12) OVER (Partition by (ID)/10) as Total_YA_12,
	ROW_NUMBER() OVER (ORDER BY CallNumber) AS rownum
	FROM MaxT
	) AS t
WHERE (t.rownum) % 10 = 0
ORDER BY CallNumber
