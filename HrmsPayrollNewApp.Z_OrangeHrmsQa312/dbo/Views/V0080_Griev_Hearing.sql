



CREATE View [dbo].[V0080_Griev_Hearing]
As
select GH.GH_ID,GAA.App_No,GH.Cmp_ID,GH.G_AllocationID,isnull(Format(GH.HearingDate,'dd/MM/yyyy HH:mm:ss'),'-') as HearingDate ,
isnull(GH.HearingLocation,'-') as HearingLocation,isnull(GH.GHContactNo,'-') as GHContactNo,GAA.App_Subline,GAA.Com_Name,GAA.GrievanceTypeTitle,GAA.CategoryTitle,
GAA.PriorityTitle,GSC.S_Name,isnull(GH.GHComments,'') as GHComments,GH.G_StatusID,GH.HearingDate as Hdate
from T0080_Griev_Hearing GH
left join V0080_Griev_App_Alloc_FullDetails GAA on GAA.G_Allocation_ID = GH.G_AllocationID
left join T0030_Griev_Status_Common GSC on GSC.S_ID = GH.G_StatusID
