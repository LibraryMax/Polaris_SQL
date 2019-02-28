USE [Polaris]
GO
/****** Object:  StoredProcedure [Polaris].[AverageChkOut]    Script Date: 9/7/2018 3:55:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [Polaris].[AverageChkOut] --For after you've already created the procedure
									 --CREATE PROCEDURE to make a new one
		@branch INT
AS

BEGIN
	SET NOCOUNT ON
	
	DECLARE
	@ThisDate DATETIME = getdate(),
	@iter INT = -12,
	@StartDate DATETIME,
	@EndDate DATETIME,
	@cols NVARCHAR(MAX), 
	@query NVARCHAR(MAX);
	
	CREATE TABLE #FinalTable
	(CollName varchar (50), AVGDaysOut int, StartDate datetime, EndDate datetime, dateMonth datetime)
	--
	WHILE @iter < = -1
		BEGIN
			SET @StartDate = dateadd(mm, datediff(mm, 0, @ThisDate) + @iter, 0)
			SET @EndDate = EOMONTH(@ThisDate, + @iter)

		--	

			CREATE TABLE ChkoutLength
			(	ItemRecID int NOT NULL,
				OutHisID int NOT NULL,
				OutHisDate datetime,
				InHisID int NULL,
				CollName varchar (50) NOT NULL,
				StartDate datetime,
				EndDate datetime
			)

			INSERT INTO ChkoutLength(ItemRecID, OutHisID, OutHisDate, CollName, StartDate, EndDate)
				(Select irh.ItemRecordID, irh.ItemRecordHistoryID as OutHisID,
				irh.TransactionDate as OutHisDate, col.Name as CollName,
				@StartDate,
				@EndDate
				from polaris.polaris.ItemRecordHistory irh with (nolock)
				join polaris.polaris.ItemRecords ir (nolock)
				on (irh.ItemRecordID = ir.ItemRecordID)
				join polaris.polaris.collections col (nolock)
				on (ir.AssignedCollectionID = col.CollectionID)
				where irh.OrganizationID in (@branch)
				and irh.TransactionDate >= @StartDate
				and irh.TransactionDate < dateadd(dd,1,(@EndDate))
				and irh.ActionTakenID = 13) --CheckedOut

			UPDATE ChkoutLength
			SET InHisID = (
			Select min(inh.InHisID) from
				(Select irh2.ItemRecordID, irh2.ItemRecordHistoryID as InHisID
				from polaris.polaris.ItemRecordHistory irh2 with (nolock)
				where irh2.actiontakenid = 11 --checkedIn
				and irh2.TransactionDate >= @StartDate
				and irh2.TransactionDate <= dateadd(dd,(90 + 1),@StartDate)
				)inh
			WHERE inh.itemrecordid = Chkoutlength.ItemRecID
			and Inh.InHisID > ChkoutLength.OutHisID)
			
			INSERT INTO #FinalTable(CollName, AVGDaysOut, StartDate, EndDate, dateMonth)
			(SELECT cko.CollName,
			AVG((DATEDIFF(mi,cko.OutHisDate,irhi.TransactionDate)*1.0000)/1440) as AVGDaysOut,
			@StartDate, 
			@EndDate,
			CAST(@StartDate AS datetime)
			from ChkoutLength cko
			join polaris.polaris.ItemRecordHistory irhi (nolock)
			ON (cko.InHisID = irhi.ItemRecordHistoryID)
			WHERE (DATEDIFF(mi,cko.OutHisDate,irhi.TransactionDate)*1.0000) > 180
			Group by cko.CollName
			)
			--
			IF @iter > = -12
			BEGIN
				SET @iter = @iter + 1
			END
			--
			
			DROP TABLE ChkoutLength

		END

	SELECT * FROM #FinalTable
	DROP TABLE #FinalTable

END