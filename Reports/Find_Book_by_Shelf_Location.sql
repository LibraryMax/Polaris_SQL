select distinct 
br.BibliographicRecordID as BibliographicRecordID,
shelf.Description as ShelfLocation,
org.DisplayName as CollectionLocation,
ser.BrowseSeries as Series,
br.BrowseCallNo as CallNo
from Polaris.BibliographicRecords br 
WITH (NOLOCK)
inner join Polaris.BibSeriesIndices bib WITH (NOLOCK)
ON bib.BibliographicRecordID = br.BibliographicRecordID
inner join Polaris.CircItemRecords cir WITH (NOLOCK)
ON br.BibliographicRecordID = cir.AssociatedBibRecordID
inner join Polaris.Organizations org WITH (NOLOCK)
ON (org.OrganizationID = cir.AssignedBranchID)
inner join Polaris.ShelfLocations shelf WITH (NOLOCK)
ON (cir.ShelfLocationID = shelf.ShelfLocationID)
inner join Polaris.MainSeriesEntries ser WITH (NOLOCK)
ON (bib.MainSeriesEntryID = ser.MainSeriesEntryID)
where cir.ShelfLocationID = '30'