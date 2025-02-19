



CREATE VIEW [dbo].[V0040_Collection_Master]    
AS    
	--SELECT Collection_ID,CollectionMonth,CollectionYear,TCM.Project_ID,TPM.Project_Name ,Service_Type,TCM.Contract_Type,Practice_Collection,Charges_Per,    
	--TCM.Fedora_Charges,Exchange_Rate,Total_Fedora_Charges,TCM.Cmp_ID,TCM.Other_Remarks,TSM.Speciality_Name   
	--FROM T0040_Collection_Master TCM    
	--INNER JOIN T0040_TS_Project_Master TPM ON TCM.Project_ID = TPM.Project_ID     
	--INNER JOIN T0040_Speciality_Master TSM ON TPM.Speciality_ID = TSM.Speciality_ID
	
	SELECT TCM.Collection_ID,TCM.CollectionMonth,TCM.CollectionYear,TCM.Manager_ID,TCM.Cmp_ID,
	TEM.Alpha_Emp_Code, (TEM.Emp_First_Name + ' ' + TEM.Emp_Last_Name) AS 'Emp_Name'
	FROM T0040_Collection_Master TCM WITH (NOLOCK)
	INNER JOIN T0080_EMP_MASTER TEM WITH (NOLOCK) ON TCM.Manager_ID = TEM.Emp_ID
