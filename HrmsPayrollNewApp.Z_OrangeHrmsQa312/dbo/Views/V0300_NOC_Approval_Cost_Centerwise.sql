





CREATE VIEW [dbo].[V0300_NOC_Approval_Cost_Centerwise]
AS
SELECT     E.Alpha_Emp_Code +' - '+ E.Emp_Full_Name As Emp_Full_Name, C.Center_Name,C.Cmp_Id , EC.Effective_Date,Ec.Emp_id,ECA.Noc_Status,C.Center_ID,ECA.Emp_ID As A_Emp_id,
		   ECA.Remarks,ECA.Approval_Id,E.Emp_Full_Name As EmpName,ECA.Updated_By,0 as dept_id,'' as dept_name  
FROM         dbo.T0080_EMP_MASTER AS E WITH (NOLOCK) INNER JOIN
             dbo.T0095_Exit_Clearance AS EC WITH (NOLOCK)  ON E.Emp_ID = EC.Emp_id
             left JOIN ( SELECT MAX(Effective_Date)as Effective_Date,Emp_id 
								   FROM T0095_Exit_Clearance WITH (NOLOCK) 
								   GROUP BY Emp_id
						)Qry on Qry.Emp_id = EC.Emp_id AND Qry.Effective_Date = EC.Effective_Date
			INNER JOIN dbo.T0040_COST_CENTER_MASTER AS C WITH (NOLOCK)  ON C.Center_ID = EC.Center_ID 
            LEFT OUTER JOIN dbo.T0300_Exit_Clearance_Approval AS ECA WITH (NOLOCK)  ON  EC.Center_ID = ECA.Center_ID AND ECA.Cmp_ID=EC.Cmp_id AND ECA.Hod_ID=Ec.Emp_id




