



CREATE VIEW [dbo].[V0120_VEHICLE_APPROVAL]
AS
SELECT DISTINCT 
                         Vehicle_App_Date,VA.Vehicle_Apr_ID,VA.Vehicle_App_ID,em.Cmp_ID,VM.Vehicle_ID, VM.Vehicle_Type, VA.emp_id,EM.Alpha_Emp_Code,EM.Emp_Full_Name,EM.Emp_First_Name,
						 VA.Max_Limit,VA.Initial_Emp_Contribution,VA.Vehicle_Cost,VA.Employee_Share,VM.No_Of_Year_Limit, VM.Attach_Mandatory, VM.Vehicle_Allow_Beyond_Limit,
						 case when VA.Approval_Status='A' THEN 'Approved' when Approval_Status='R' THEN 'Rejected' end as App_Status,
						 EMR.Emp_Full_Name AS Supervisor,EM.Emp_Superior,Dept_Name,Desig_Name,Branch_Name,va.Manufacture_Year,va.Attachment,VA.Vehicle_Model,
						 VA.Vehicle_manufacture,va.Comments,VA.Approval_Date,isnull(VA.Vehicle_Option,'')Vehicle_Option
FROM          dbo.T0120_VEHICLE_APPROVAL VA  INNER JOIN
						 dbo.V0080_EMP_MASTER_INCREMENT_GET AS EM ON VA.Emp_ID=EM.Emp_ID INNER JOIN
						 dbo.T0080_EMP_MASTER EMR ON EMR.EMP_ID=EM.Emp_Superior INNER JOIN
                         dbo.T0040_VEHICLE_TYPE_MASTER AS VM WITH (NOLOCK) ON EM.Cmp_ID = VM.Cmp_ID AND VM.Vehicle_ID=VA.Vehicle_ID  INNER JOIN
						 T0100_VEHICLE_APPLICATION V ON VA.Vehicle_App_ID=V.Vehicle_App_ID



