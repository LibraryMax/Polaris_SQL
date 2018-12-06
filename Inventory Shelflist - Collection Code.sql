--Stored procedure for inventory shelf lift by collection code
USE [Polaris]
GO
/****** Object:  StoredProcedure [Polaris].[Rpt_InventoryShelf_Collection]    Script Date: 12/5/2018 3:48:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [Polaris].[Rpt_InventoryShelf_Collection]             
	@StartLastInventoryDate as datetime, -- starting last inventory date  
	@EndLastInventoryDate as datetime, -- ending last inventory date  
	@OrganizationList as NVARCHAR(MAX), --list of branch codes
	@Collection as INT --numerical collection id
AS    
BEGIN  
	SET NOCOUNT ON

	CREATE TABLE #Branches (OrganizationID INT) --creating a table to limit by branch
	IF LEN(@OrganizationList) = 1 AND @OrganizationList= N'0' -- ALL SELECTED
	BEGIN
		INSERT INTO #Branches 
		SELECT OrganizationID FROM Polaris.Organizations WITH (NOLOCK) WHERE OrganizationCodeID IN (1,3)
	END
	ELSE
	BEGIN
		EXEC (N'INSERT INTO #Branches SELECT OrganizationID FROM Polaris.Organizations WITH (NOLOCK) WHERE OrganizationID in(' + @OrganizationList + N')')  
	END

	SELECT    
		coll.Name as Collection,    
		IRD.CopyNumber,     
		IRD.VolumeNumber,    
		IRD.LastInventoryDate,     
		BR.BrowseTitle,    
		MT.[Description] AS MaterialType,    
		ITS.[Description] AS ItemStatDescription,    
		CIR.Barcode AS ItemBarcode,    
		O.[Name] AS Orgname,     
		O.OrganizationID,    
		RS.RecordStatusName    
	FROM    	
		Polaris.Collections coll WITH (NOLOCK)
		INNER JOIN Polaris.OrganizationsCollections OrgColl WITH (NOLOCK)
			ON coll.CollectionID = OrgColl.CollectionID
		INNER JOIN Polaris.CircItemRecords CIR WITH (NOLOCK)     
			ON CIR.AssignedBranchID = OrgColl.OrganizationID
		INNER JOIN Polaris.ItemRecordDetails IRD WITH (NOLOCK)     
			ON IRD.ItemRecordID = CIR.ItemRecordID
		INNER JOIN Polaris.RecordStatuses RS WITH (NOLOCK)    
			ON CIR.RecordStatusID = RS.RecordStatusID		   	
		INNER JOIN Polaris.Organizations O WITH (NOLOCK)    
			ON CIR.AssignedBranchID = O.OrganizationID
		INNER JOIN Polaris.BibliographicRecords BR WITH (NOLOCK)    
			ON CIR.AssociatedBibRecordID = BR.BibliographicRecordID 	
		INNER JOIN Polaris.ItemStatuses ITS WITH (NOLOCK)    
			ON CIR.ItemStatusID = ITS.ItemStatusID    		
		INNER JOIN Polaris.MaterialTypes MT WITH (NOLOCK)    
			ON CIR.MaterialTypeID = MT.MaterialTypeID	
		 INNER JOIN #Branches B --Limits by branch by matching organizationIDs
			ON (O.OrganizationID = B.OrganizationID and OrgColl.OrganizationID = B.OrganizationID)  	
	WHERE    
		coll.CollectionID LIKE @Collection
		AND IRD.LastInventoryDate between @StartLastInventoryDate and @EndLastInventoryDate 
	ORDER BY    
		coll.CollectionID
	OPTION (FORCE ORDER);
	RETURN    
END
