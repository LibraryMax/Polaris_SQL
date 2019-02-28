--Adult Fiction 9
Select distinct bibliographicrecordid as recordid
From bibliographicrecords br with (nolock)
Inner join circitemrecords cir with (nolock)
On (cir.associatedbibrecordid = br.bibliographicrecordid)
where creationdate between'7/16/2018' and '8/14/2018'
and assignedcollectionid = 9

--Adult DVD 6
Select distinct bibliographicrecordid as recordid
From bibliographicrecords br with (nolock)
Inner join circitemrecords cir with (nolock)
On (cir.associatedbibrecordid = br.bibliographicrecordid)
where creationdate between '7/16/2018' and '8/14/2018'
and assignedcollectionid = 6