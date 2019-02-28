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


/*
OrganizationID	Name
1...............Kitsap Regional Library System
2...............Kitsap Regional Library
3...............Bainbridge
4...............Bookmobile
5...............Downtown Bremerton
6...............Kingston
7...............Little Boston
8...............Manchester
9...............Mobile Services
10..............Port Orchard
11..............Poulsbo
12..............Silverdale 
13..............Sylvan Way - Bremerton
14..............oService Center
*/

/* and cir.AssignedCollectionID = 18 --Polaris.Collections Easy Fiction
and org.OrganizationID = 10 --Polaris.Organizations */