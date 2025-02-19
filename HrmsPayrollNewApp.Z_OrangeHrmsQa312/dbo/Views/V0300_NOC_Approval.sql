
CREATE VIEW [dbo].[V0300_NOC_Approval]
AS
SELECT     E.Alpha_Emp_Code +' - '+ E.Emp_Full_Name As Emp_Full_Name, D.Dept_Name,E.Cmp_Id ,
			 EC.Effective_Date,Ec.Emp_id,ECA.Noc_Status,D.Dept_Id,ECA.Emp_ID As A_Emp_id,
		   ECA.Remarks,ECA.Approval_Id,E.Emp_Full_Name As EmpName,ECA.Updated_By --Added By Jaina 06-06-2016
		   ,CCM.Center_ID as center_id,CCM.Center_Name as center_name,
		   ECA.Exit_ID,EC.branch_id 
FROM         dbo.T0080_EMP_MASTER AS E WITH (NOLOCK) INNER JOIN
             dbo.T0095_Exit_Clearance AS EC WITH (NOLOCK)  ON E.Emp_ID = EC.Emp_id
             INNER JOIN ( SELECT MAX(Effective_Date)as Effective_Date,Emp_id 
								   FROM T0095_Exit_Clearance WITH (NOLOCK) 
								   GROUP BY Emp_id
						)Qry on Qry.Emp_id = EC.Emp_id AND Qry.Effective_Date = EC.Effective_Date
			LEFT OUTER JOIN dbo.T0030_BRANCH_MASTER AS BM WITH (NOLOCK) ON BM.Branch_ID = EC.branch_id
			LEFT OUTER JOIN dbo.T0040_DEPARTMENT_MASTER AS D WITH (NOLOCK)  ON D.Dept_Id = EC.Dept_Id             
            LEFT OUTER JOIN dbo.T0040_Cost_Center_Master CCM WITH (NOLOCK)  ON EC.Center_ID=CCM.Center_ID
            LEFT OUTER JOIN dbo.T0300_Exit_Clearance_Approval AS ECA WITH (NOLOCK)  ON  (EC.Dept_id = ECA.Dept_id OR ECA.Center_ID=EC.Center_ID) AND ECA.Cmp_ID=EC.Cmp_id AND ECA.Hod_ID=Ec.Emp_id
    --      

