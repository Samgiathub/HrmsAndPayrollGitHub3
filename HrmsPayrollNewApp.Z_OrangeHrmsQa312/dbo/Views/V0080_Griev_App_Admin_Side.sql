









CREATE View [dbo].[V0080_Griev_App_Admin_Side]
As
select GA.GA_ID,isnull(GA.App_No,'GA'+cast(GA.GA_ID as nvarchar)) as App_No,format(GA.Receive_Date,'dd/MM/yyyy') as ReceiveDate,
CASE
    WHEN GA.[From] =0  THEN 'Employee'
    WHEN GA.[From] =1  THEN 'Other'
END as [From],
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
END as [Name_Against],GA.SubjectLine,GA.Cmp_ID,GA.Receive_Date as R_Date,GA.DocumentName,
CASE 
	WHEN GA.IsForwarded=0 THEN 'Pending'
	ELSE GSC.S_Name
END as ApplicationStatus,GA.Emp_IDF,
CASE
    WHEN GA.Griev_Against =0  THEN EMT.Branch_Name
    WHEN GA.Griev_Against =1  THEN EMF.Branch_Name
END as BranchApp,
CASE
    WHEN GA.Griev_Against =0  THEN EMT.Branch_ID
    WHEN GA.Griev_Against =1  THEN EMF.Branch_ID
END as B_ID,isnull(GA.Emp_IDT,0) as Emp_IDT,GA.Details,isnull(GA.EmailT,'') EmailT,isnull(GA.AddressT,'') AddressT,isnull(GA.ContactT,'') ContactT
from T0080_Griev_Application GA
left join V0080_Employee_Master as EMF on EMF.Emp_ID = GA.Emp_IDF
left join V0080_Employee_Master as EMT on EMT.Emp_ID = GA.Emp_IDT
left join T0030_Griev_Recieve_From_List as GRF on GRF.Id = GA.Receive_From
left join T0030_Griev_Status_Common as GSC on GSC.S_ID = GA.IsForwarded
