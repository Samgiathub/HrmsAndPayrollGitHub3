




CREATE View [dbo].[V0080_Griev_Hearing_History_All]
As
select GHH.GHH_ID,GH.App_No,GHH.Cmp_ID,GH.GH_ID,Format(GHH.Last_HearingDate,'dd/MM/yyyy HH:mm:ss') as Last_HearingDate,
isnull(Format(GHH.Next_HearingDate,'dd/MM/yyyy HH:mm:ss'),'-') as NextHearingDate,GHH.GHHLocation as HearingLocation,
GHH.GHHContact as GHContactNo ,GAA.Com_Name,GAA.GrievanceTypeTitle,GAA.CategoryTitle,GAA.PriorityTitle,
GSC.S_Name,GH.App_Subline,GHH.GHHDocName,GHH.GHHComments,GH.HearingLocation as NewLoc,GH.GHContactNo as NewContact
from T0080_Griev_Hearing_History GHH
left join V0080_Griev_Hearing GH on GH.GH_ID = GHH.G_HearingID
left join V0080_Griev_Application_Allocation GAA on GAA.G_Allocation_ID =GHH.G_AllocationID
left join T0030_Griev_Status_Common GSC on GSC.S_ID = GHH.G_StatusID
