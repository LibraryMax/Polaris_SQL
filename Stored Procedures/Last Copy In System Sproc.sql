USE [Polaris] --Use database [xxxx]
GO
/****** Object:  StoredProcedure [Polaris].[LastCopy]    Script Date: 8/31/2018 12:53:54 PM ******/
SET ANSI_NULLS ON --When ANSI_NULLS is on any comparison operation where (at least) 
				  --one of the operands is NULL produces the third logic value - UNKNOWN
GO
SET QUOTED_IDENTIFIER ON --When SET QUOTED_IDENTIFIER is ON, identifiers can be delimited by 
						 --double quotation marks, and literals must be delimited by single quotation marks
GO

ALTER PROCEDURE [Polaris].[LastCopy] --For after you've already created the procedure
									 --CREATE PROCEDURE to make a new one

	@ORGANIZATION INT,   -- Organization for which requests to fill report is returned.
	@Collection INT, --Collection code
	@PubYear INT--Publication Year
	
AS
BEGIN --starts procedure

	SET NOCOUNT ON --suppresses the "xx rows affected" message
	
	CREATE TABLE #Branches (OrganizationID INT)  
	IF LEN(@ORGANIZATION) = 1 AND @ORGANIZATION= '0' -- ALL SELECTED
	BEGIN
		INSERT INTO #Branches (OrganizationID)
		SELECT OrganizationID FROM Polaris.Organizations WITH (NOLOCK) WHERE OrganizationCodeID in (3)
	END
	ELSE
	BEGIN
		EXEC ('INSERT INTO #Branches SELECT OrganizationID FROM Polaris.Organizations WITH (NOLOCK) WHERE OrganizationID in(' + @ORGANIZATION + ')')  
	END

	/*Creation of a temporary table to hold our data*/
	create table #LastCopy
	(
		CallNumber varchar(MAX),
		Author varchar(255),
		Title varchar(MAX),
		Status varchar(80),
		PublicationYear INT
	)

	insert #LastCopy
	(
		CallNumber ,
		Author,
		Title,
		Status,
		PublicationYear	
	)

/* Our actual query*/
select
	br.BrowseCallNo AS 'Call Number',
	br.BrowseTitle AS Title, 
	br.BrowseAuthor as Author,
	its.Name as 'Status',
	br.PublicationYear as 'Publication Year'
from Polaris.CircItemRecords cir (nolock)
join Polaris.RWRITER_BibDerivedDataView vi (nolock)
on cir.AssociatedBibRecordID = vi.BibliographicRecordID
join Polaris.Organizations org (nolock)
on cir.AssignedBranchID = org.OrganizationID
join Polaris.BibliographicRecords br (nolock)
on cir.AssociatedBibRecordID = br.BibliographicRecordID
join Polaris.ItemStatuses its
on cir.ItemStatusID = its.ItemStatusID
join Polaris.Collections col (nolock)
on cir.AssignedCollectionID = col.CollectionID
where (cir.ItemStatusID = 1 or cir.ItemStatusID = 2)
and cir.AssignedCollectionID = @Collection
and org.OrganizationID = @ORGANIZATION
and vi.NumberofItems = 1
and br.PublicationYear < @PubYear

declare @execString varchar(1000) = 'SELECT * FROM #LastCopy' --What provides the data when the procedure is called

	exec (@execString) 
	
DROP TABLE #LastCopy --Deletes temporary table

END --Ends procedure