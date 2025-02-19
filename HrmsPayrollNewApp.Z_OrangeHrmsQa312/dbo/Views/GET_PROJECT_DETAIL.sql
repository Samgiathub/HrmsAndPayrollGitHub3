


 
 
CREATE VIEW [dbo].[GET_PROJECT_DETAIL]    
AS    
	SELECT TPM.Project_ID,TPM.Project_Name,TPM.Project_Code,TPM.Start_Date,TPM.Duration,TPM.Due_Date,
	TPM.Project_Description,ISNULL(TPM.Project_Status_ID,0) AS 'Project_Status_ID',ISNULL(TPM.Client_ID ,0) AS 'Client_ID',
	TPM.TimeSheet_Approval_Type,TPM.Project_Cost,TPM.Attachment,TPM.Completed,TPM.Disabled,TPM.Address1,TPM.Address2,
	ISNULL(TPM.Loc_ID,0) AS 'Loc_ID',TPM.State_ID,TPM.Zipcode,ISNULL(Overhead_Calculation,0) AS 'Overhead_Calculation',
	TPM.PhoneNo,TPM.FaxNo,TPM.Contact_Person,TPM.Contact_Email,TPM.Speciality_id,TSM.Speciality_Name,TPM.Contract_Type,
	TPM.Fedora_Charges,TPD.Assign_To,TPD.Project_Detail_ID,TPM.Cmp_ID,TPM.City,ISNULL(TPM.Branch_ID,0) AS 'Branch_ID',
	TPD.Branch_ID AS 'MBranch_ID'
	FROM T0040_TS_Project_Master TPM WITH (NOLOCK)    
	INNER JOIN T0050_TS_Project_Detail TPD WITH (NOLOCK) ON TPM.Project_ID = TPD.Project_ID  
	LEFT JOIN T0040_Speciality_Master TSM WITH (NOLOCK) ON TPM.speciality_id=TSM.Speciality_ID




