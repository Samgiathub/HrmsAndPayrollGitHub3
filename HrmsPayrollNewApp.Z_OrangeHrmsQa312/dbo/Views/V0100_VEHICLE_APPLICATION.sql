



CREATE VIEW [dbo].[V0100_VEHICLE_APPLICATION]
AS
SELECT DISTINCT 
                         VA.Vehicle_App_ID,em.Cmp_ID,VM.Vehicle_ID, VM.Vehicle_Type, VA.emp_id,EM.Alpha_Emp_Code,EM.Emp_Full_Name,EM.Emp_First_Name,
						 VA.Max_Limit,VA.Initial_Emp_Contribution,VA.Vehicle_Cost,VA.Employee_Share,VM.No_Of_Year_Limit, VM.Attach_Mandatory, VM.Vehicle_Allow_Beyond_Limit,
						 case when App_Status='P' THEN 'Pending' when App_Status='D' THEN 'Draft' when App_Status='A' THEN 'Approved' when App_Status='R' THEN 'Rejected' end as App_Status,Vehicle_App_Date,
						 EMR.Emp_Full_Name AS Supervisor,EM.Emp_Superior,Dept_Name,Desig_Name,Branch_Name,Vehicle_Apr_ID,VA.Attachment,VA.Manufacture_Year,
						 CASE WHEN VM.Desig_Wise_Limit=1 THEN isnull(VMD.Employee_Contribution,0)
						 WHEN VM.Grade_Wise_Limit=1 THEN isnull(VMG.Employee_Contribution ,0)
						 WHEN VM.Branch_Wise_Limit=1 THEN isnull(VMB.Employee_Contribution,0) END AS Employee_Contribution,VA.Vehicle_Model,VA.Vehicle_Manufacture,
						 isnull(VA.Vehicle_Option,'')Vehicle_Option
FROM          dbo.T0100_VEHICLE_APPLICATION VA  INNER JOIN
						 dbo.V0080_EMP_MASTER_INCREMENT_GET AS EM ON VA.Emp_ID=EM.Emp_ID LEFT JOIN
						 dbo.T0080_EMP_MASTER EMR ON EMR.EMP_ID=EM.Emp_Superior LEFT JOIN
                         dbo.T0040_VEHICLE_TYPE_MASTER AS VM WITH (NOLOCK) ON EM.Cmp_ID = VM.Cmp_ID and VM.Vehicle_ID=VA.Vehicle_ID LEFT OUTER JOIN
                         dbo.T0041_Vehicle_Maxlimit_Design AS VMD WITH (NOLOCK) ON VM.Vehicle_ID = VMD.Vehicle_ID AND VM.Desig_Wise_Limit = 1 AND VMD.Desig_ID = EM.Desig_Id LEFT OUTER JOIN
                         dbo.T0041_Vehicle_Maxlimit_Design AS VMG WITH (NOLOCK) ON VM.Vehicle_ID = VMG.Vehicle_ID AND VM.Grade_Wise_Limit = 1 AND VMG.Grade_ID = EM.Grd_ID LEFT OUTER JOIN
                         dbo.T0041_Vehicle_Maxlimit_Design AS VMB WITH (NOLOCK) ON VM.Vehicle_ID = VMB.Vehicle_ID AND VM.Branch_Wise_Limit = 1 AND VMB.Branch_ID = EM.Branch_ID LEFT OUTER JOIN
						 dbo.T0120_VEHICLE_APPROVAL as VAPR WITH (NOLOCK)  ON VA.Vehicle_App_ID = VAPR.Vehicle_App_ID



