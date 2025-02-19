



CREATE View [dbo].[V0080_Grievance_Heairng_Calendar]
As
select GH_ID as id,App_No as title, 0 isMultipleDay ,
' ' as url,
            '<b>Location : </b>'+HearingLocation+
       '<br/><b>Contact : </b>'+GHContactNo+
	   '<br/><b>Committee : </b>'+Com_Name+
	   '<br/><b>Type : </b>'+GrievanceTypeTitle+
	   '<br/><b>Category : </b>'+CategoryTitle+
	   '<br/><b>Priority : </b>'+PriorityTitle+
	   '<br/><b>Status : </b>'+S_Name as description,
	   CONVERT(VARCHAR(10),Hdate,121) +' '+  CONVERT(VARCHAR, CONVERT(DATETIME, Hdate), 108) AS start,
CONVERT(VARCHAR(10),Hdate,121) +' '+  CONVERT(VARCHAR, CONVERT(DATETIME, Hdate), 108) AS [end],
	  -- cast(Hdate as datetime) AS start ,
 --cast(Hdate as datetime) AS [end],
 '#50BAFB' AS backgroundColor,
 '#50BAFB' AS borderColor ,
 Hdate ,
Cmp_ID,ISNULL(G_AllocationID,0) as G_AllocationID --Pooja13092022 Isnull 0 add only
from V0080_Griev_Hearing 
where  S_Name  not in ('Closed','Rejected')
