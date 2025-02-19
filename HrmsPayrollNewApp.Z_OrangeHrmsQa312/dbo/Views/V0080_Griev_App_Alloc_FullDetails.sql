
CREATE View [dbo].[V0080_Griev_App_Alloc_FullDetails]
As
select GAA.G_Allocation_ID ,GA.App_No,GAA.Cmp_ID,GAA.CDTM as AllocDate,Format(GAA.CDTM,'dd/MM/yyyy') as Allocation_Date,isnull(Format(GH.HearingDate,'dd/MM/yyyy HH:mm:ss'),'-') as HearingDate,GCM.Com_Name,
GTM.GrievanceTypeTitle,GCTM.CategoryTitle,GPM.PriorityTitle,GSC.S_Name,GAA.Comments,GAA.[File_Name] as Alloc_Doc,
Format(GA.Receive_Date,'dd/MM/yyyy') as GApplicationDate,
CASE
    WHEN GA.[From] =0  THEN 'Employee'
    WHEN GA.[From] =1  THEN 'Other'
END as GAFrom,
CASE
    WHEN GA.[From] =0  THEN EMF.Emp_Full_Name
    WHEN GA.[From] =1  THEN GA.NameF
END as [Name_From],GRF.R_From,
CASE
    WHEN GA.Griev_Against =0  THEN 'Employee'
    WHEN GA.Griev_Against =1  THEN 'Other'
END as Griev_Against,
CASE
    WHEN GA.Griev_Against =0  THEN EMT.Emp_Full_Name
    WHEN GA.Griev_Against =1  THEN GA.NameT
END as [Name_Against],GA.SubjectLine as App_Subline,GA.Details as App_Details,
GA.Receive_Date as App_Date,GA.DocumentName as AppDoc,GH.HearingDate as GHDate,
GCM.NodelHR_id,GCM.Chairperson_id,
Case
   When GA.[From] = 0 Then GA.Emp_IDF
   When GA.[From] = 1 Then GA.Emp_IDT
END ForLocationHearing,GCM.GC_ID as CommitteeID,GTM.GrievanceTypeID as TypeID,
GCTM.G_CategoryID as CatID,GPM.G_PriorityID as PriorityID,GA.GA_ID as AppID,GSC.S_ID,
(select count(GHH_ID) from T0080_Griev_Hearing_History  where G_HearingID=GH.GH_ID) as AttemptHearing,isnull(GH.GH_ID,0) GH_ID,
isnull(GA.Emp_IDT,0) as Emp_IDT
from T0080_Griev_Application_Allocation GAA
left join T0040_Griev_Committee_Master GCM on GCM.GC_ID = GAA.CommitteeID
left join T0040_Grievance_Type_Master GTM on GTM.GrievanceTypeID = GAA.Griev_TypeID
left join T0040_Griev_Category_Master GCTM on GCTM.G_CategoryID = GAA.Griev_CatID
left join T0040_Griev_Priority_Master GPM on GPM.G_PriorityID = GAA.Griev_PriorityID
left join T0030_Griev_Status_Common GSC on GSC.S_ID = GAA.Griev_StatusID
left join T0080_Griev_Application GA on GA.GA_ID = GAA.GrievAppID
left join T0080_EMP_MASTER as EMF on EMF.Emp_ID = GA.Emp_IDF
left join T0080_EMP_MASTER as EMT on EMT.Emp_ID = GA.Emp_IDT
left join T0030_Griev_Recieve_From_List as GRF on GRF.Id = GA.Receive_From
left join T0080_Griev_Hearing as GH on GH.G_AllocationID = GAA.G_Allocation_ID
where GAA.G_Allocation_ID =(select max(G_Allocation_ID) from T0080_Griev_Application_Allocation where  GrievAppID= GA.GA_ID and Cmp_ID=GA.Cmp_ID)
