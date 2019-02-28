select
	br.BrowseCallNo AS 'Call Number',
	br.BrowseTitle AS Title, 
	br.BrowseAuthor as Author,
	br.BibliographicRecordID AS 'Bib Record ID',
	br.FirstAvailableDate AS 'First Available Date',
	vi.BibLifetimeCircCount AS 'Lifetime Circ',
	vi.NumberActiveHolds AS '# of Active Holds',
	vi.NumberofItems AS '# of Items',
	col.Abbreviation AS 'Collection Abbreviation',
	col.Name AS 'Material Type'
from Polaris.BibliographicRecords br (nolock)
join Polaris.RWRITER_BibDerivedDataView vi (nolock)
on br.BibliographicRecordID = vi.BibliographicRecordID
join polaris.Organizations org (nolock)
on br.RecordOwnerID = org.OrganizationID
join Polaris.OrganizationsCollections orgcoll (nolock)
on org.OrganizationID = orgcoll.CollectionID
join Polaris.Collections col (nolock)
on orgcoll.CollectionID = col.CollectionID
WHERE vi.NumberofItems = 0
GROUP BY br.BrowseCallNo, br.BrowseTitle, br.BrowseTitle, br.BrowseAuthor, br.BibliographicRecordID, br.FirstAvailableDate, 
vi.BibLifetimeCircCount, vi.NumberActiveHolds, vi.NumberofItems, col.Abbreviation, col.Name
order by vi.NumberofItems