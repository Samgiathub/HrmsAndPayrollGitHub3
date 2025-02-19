






CREATE VIEW [dbo].[V0300_NOC_Approval_GET]
AS
SELECT     E.Cmp_Id ,EC.Effective_Date,Ec.Emp_id,EC.Dept_Id,EC.branch_id 
FROM         dbo.T0080_EMP_MASTER AS E WITH (NOLOCK) RIGHT OUTER JOIN
			dbo.T0095_Exit_Clearance AS EC WITH (NOLOCK)  ON E.Branch_ID = EC.branch_id--E.Branch_ID=EC.branch_id AND E.Dept_ID= EC.Dept_id --E.Emp_ID = EC.Emp_id --AND 
             INNER JOIN ( SELECT MAX(Effective_Date)as Effective_Date,branch_id,Dept_id
								   FROM T0095_Exit_Clearance WITH (NOLOCK) 								   
								   GROUP BY branch_id,Dept_id								    
						)Qry on Qry.Effective_Date = EC.Effective_Date AND
						Qry.branch_id = EC.branch_id And Qry.Dept_id = EC.Dept_id      
			--LEFT OUTER JOIN dbo.T0030_BRANCH_MASTER AS BM WITH (NOLOCK) ON BM.Branch_ID = EC.branch_id
			--LEFT OUTER JOIN dbo.T0040_DEPARTMENT_MASTER AS D WITH (NOLOCK)  ON D.Dept_Id = EC.Dept_Id             
           --LEFT OUTER JOIN dbo.T0040_Cost_Center_Master CCM WITH (NOLOCK)  ON EC.Center_ID=CCM.Center_ID
           --LEFT OUTER JOIN dbo.T0300_Exit_Clearance_Approval AS ECA WITH (NOLOCK)  ON  (EC.Dept_id = ECA.Dept_id OR ECA.Center_ID=EC.Center_ID) AND ECA.Cmp_ID=EC.Cmp_id AND ECA.Hod_ID=Ec.Emp_id
    --      

