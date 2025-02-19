
CREATE View [dbo].[V0080_Griev_Hearing_History_Lettest]
As
	select GHH.GHH_ID,GHH.Cmp_ID,isnull(Format(GHH.Next_HearingDate,'dd/MM/yyyy HH:mm:ss'),'-') as HearingDate,GHH.GHHComments as GHComments,
	GCM.S_Name,GH.HearingLocation,GH.GHContactNo,GH.GH_ID,GH.G_AllocationID,GHH.Next_HearingDate,
	(select count(GHH_ID) from T0080_Griev_Hearing_History where  G_HearingID=GH.GH_ID and Cmp_ID=GH.Cmp_ID) as HearingCount
	from T0080_Griev_Hearing_History  GHH
	left join V0080_Griev_Hearing GH on GH.GH_ID = GHH.G_HearingID
	left join T0030_Griev_Status_Common GCM on GCM.S_ID = GHH.G_StatusID
	where GHH.GHH_ID = (select max(GHH_ID) from T0080_Griev_Hearing_History where  G_HearingID=GH.GH_ID and Cmp_ID=GH.Cmp_ID)



