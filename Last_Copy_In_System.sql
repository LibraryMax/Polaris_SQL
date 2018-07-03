select
	br.BrowseCallNo AS 'Call Number',
	br.BrowseTitle AS Title, 
	br.BrowseAuthor as Author,
	its.Name as 'Status'
from Polaris.CircItemRecords cir (nolock)
join Polaris.RWRITER_BibDerivedDataView vi (nolock)
on cir.AssociatedBibRecordID = vi.BibliographicRecordID
join Polaris.Organizations org (nolock)
on cir.AssignedBranchID = org.OrganizationID
join Polaris.BibliographicRecords br (nolock)
on cir.AssociatedBibRecordID = br.BibliographicRecordID
join Polaris.ItemStatuses its
on cir.ItemStatusID = its.ItemStatusID
where (cir.ItemStatusID = 1 or cir.ItemStatusID = 2)
and cir.AssignedCollectionID = 18
and org.OrganizationID = 10
and vi.NumberofItems = 1
and br.PublicationYear < 2016
order by br.PublicationYear