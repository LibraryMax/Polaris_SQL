USE [Polaris]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author, Max, Name>
-- Create date: <Create Date,8/31/2018>
-- Description:	<Description,Stored Procedure to grab Publishing Years,>
-- =============================================
CREATE PROCEDURE Polaris.BibRecordPublishingYear   
AS   
	select PublicationYear
	from Polaris.BiblioGraphicRecords WITH (NOLOCK)
	WHERE PublicationYear IS NOT NULL
	AND (PublicationYear > 2000 OR PublicationYear = 2000)
	AND (PublicationYear = YEAR(getdate()) OR PublicationYear < YEAR(getdate()))
	GROUP BY PublicationYear
	ORDER BY PublicationYear
GO 