CREATE VIEW [dbo].[V0300_Exit_Clearance_Approval]
AS
SELECT  DISTINCT    EM.Alpha_Emp_Code, EM.Emp_Full_Name,cast( EM.Alpha_Emp_Code as varchar) + ' - ' + EM.Emp_Full_Name as F_Emp_Full_Name,
					EC.Request_Date, EC.Noc_Status, EC.Exit_ID, EC.Hod_ID,
					EM.Cmp_ID,EA.branch_id,EA.resignation_date,EM.Date_Of_Join,EC.Emp_id,EA.status,
					EA.desig_id,EM.Dept_ID,DS.Desig_Name,B.Branch_Name,DM.Dept_Name,EM.Emp_Superior,EA.last_date,EC.Approval_Id,EC.Remarks,EM.Emp_Left,
					DE.Dept_id As Exitdeptid,DE.Dept_Name AS Exit_Dept,EA.sup_ack,EC.Center_ID,ISNULL(CM.Center_Name,'')Center_Name
FROM         dbo.T0300_Exit_Clearance_Approval AS EC WITH (NOLOCK) INNER JOIN
                      dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK)  ON EC.Emp_ID = EM.Emp_ID LEFT OUTER JOIN
                      dbo.T0040_DEPARTMENT_MASTER AS DM WITH (NOLOCK)  ON DM.Dept_Id = EM.Dept_ID INNER JOIN
                      dbo.T0040_DESIGNATION_MASTER As DS WITH (NOLOCK)  ON DS.Desig_ID = EM.Desig_Id INNER JOIN
                      dbo.T0030_BRANCH_MASTER As B WITH (NOLOCK)  on B.Branch_ID = EM.Branch_ID INNER JOIN
					T0200_Emp_ExitApplication EA WITH (NOLOCK)  ON EA.exit_id = EC.Exit_id LEFT OUTER JOIN 
					T0095_Exit_Clearance E WITH (NOLOCK)  ON E.branch_id = EA.branch_id 
					LEFT OUTER JOIN--E.Emp_id = EC.Hod_ID LEFT OUTER JOIN
					T0040_DEPARTMENT_MASTER DE WITH (NOLOCK)  ON  EC.Dept_id = DE.Dept_Id LEFT OUTER JOIN
					T0040_COST_CENTER_MASTER CM  WITH (NOLOCK) ON CM.Center_ID=EC.Center_ID


