
CREATE View [dbo].[V0080_Griev_Application_Allocation]
As
select GAA.G_Allocation_ID ,GA.App_No,GAA.Cmp_ID,GCM.Com_Name,GTM.GrievanceTypeTitle,GCTM.CategoryTitle,GPM.PriorityTitle,GSC.S_Name,
 Format(GAA.CDTM,'dd-MM-yyyy') as Allocation_Date,GA.SubjectLine,Format(GA.Receive_Date,'dd-MM-yyyy') as GAppDate  from T0080_Griev_Application_Allocation GAA
left join T0040_Griev_Committee_Master GCM on GCM.GC_ID = GAA.CommitteeID
left join T0040_Grievance_Type_Master GTM on GTM.GrievanceTypeID = GAA.Griev_TypeID
left join T0040_Griev_Category_Master GCTM on GCTM.G_CategoryID = GAA.Griev_CatID
left join T0040_Griev_Priority_Master GPM on GPM.G_PriorityID = GAA.Griev_PriorityID
left join T0030_Griev_Status_Common GSC on GSC.S_ID = GAA.Griev_StatusID
left join T0080_Griev_Application GA on GA.GA_ID = GAA.GrievAppID
