select distinct bt.BibliographicRecordID as BibliographicRecordID, 
br.BrowseTitle as SeriesName, 
org.DisplayName as CollectionLocation,
shelf.Description as ShelfLocation,
ser.BrowseSeries as Series
from Polaris.BibliographicTags bt
with (NOLOCK)
inner join Polaris.BibliographicRecords br WITH (NOLOCK)
ON br.BibliographicRecordID = bt.BibliographicRecordID
inner join Polaris.CircItemRecords cir WITH (NOLOCK)
ON bt.BibliographicRecordID = cir.AssociatedBibRecordID
join
Polaris.BibliographicSubfields bs on (bt.BibliographicTagID = bs.BibliographicTagID)
join
Polaris.Organizations org ON (org.OrganizationID = cir.AssignedBranchID)
join 
Polaris.ShelfLocations shelf ON (cir.ShelfLocationID = shelf.ShelfLocationID)
join
Polaris.BibSeriesIndices bib ON (bib.BibliographicRecordID = bt.BibliographicRecordID)
join
Polaris.MainSeriesEntries ser ON (bib.MainSeriesEntryID = ser.MainSeriesEntryID)
TagNumber = 830 and Subfield = 'a' AND Data LIKE '%Step into Reading%';