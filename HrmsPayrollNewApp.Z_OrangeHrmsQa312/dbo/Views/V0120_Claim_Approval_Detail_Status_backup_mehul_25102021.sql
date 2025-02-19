


Create VIEW [dbo].[V0120_Claim_Approval_Detail_Status_backup_mehul_25102021]
As
select distinct CA.Emp_ID,CA.Claim_Apr_ID,CA.Cmp_ID,
				isnull(CA.Claim_App_ID,0)Claim_App_ID,em.Emp_First_Name,em.Emp_Full_Name,ca.Claim_Apr_Pending_Amount,Em.Emp_Left
				,em.Emp_code,ca.Claim_apr_Status as Claim_Apr_Status,ca.Claim_Apr_Date as Claim_Apr_Date,ca.Claim_App_Date,ISNULL(Ca.S_Emp_ID,0) AS S_Emp_ID,
				I.Branch_ID,I.Desig_Id,i.Grd_ID,Claim_App_Code,CLAIM_APP_DOC,Em.Alpha_Emp_Code,'' AS Claim_Limit_Type
				,Other_Email,Mobile_No ,Work_Email,BM.Branch_Name,DGM.Desig_Name,
				ISNULL(REVERSE(STUFF(REVERSE((SELECT DISTINCT   CM.Claim_Name + ','
				            FROM          T0130_CLAIM_APPROVAL_DETAIL CD WITH (NOLOCK)
							LEFT JOIN T0040_CLAIM_MASTER cm WITH (NOLOCK) on cm.Claim_ID=CD.Claim_ID
                            WHERE      CD.Claim_Apr_ID IN
                                                       (SELECT     cast(data AS numeric(18, 0))
                                                         FROM          dbo.Split(ISNULL(CA.Claim_Apr_ID, '0'), '#')
                                                         WHERE      data <> '') FOR XML path('') )), 1, 1, '')),'') AS Claim_Name
				
				--cad.Claim_App_Amount,cad.Claim_ID,cm.Claim_Name,cad.Claim_Apr_Dtl_ID,cad.Claim_Apr_Amount,
,desig_name as Designation, dept_name as Department, branch_name as [Branch Name],Grd_Name as [Grade_Name]
from T0120_CLAIM_APPROVAL CA WITH (NOLOCK)
		INNER JOIN (SELECT I.branch_id, I.grd_id, I.dept_id, I.desig_id, I.emp_id ,i.Cmp_ID
					   FROM   t0095_increment I 
							  INNER JOIN (SELECT Max(increment_effective_date) AS For_Date, emp_id 
										  FROM   t0095_increment 
										  WHERE  increment_effective_date <= Getdate() 
										  GROUP  BY emp_id) Qry 
										  ON I.emp_id = Qry.emp_id AND I.increment_effective_date = Qry.for_date
										  )Q_I 
					ON CA.emp_id = Q_I.emp_id  and CA.Cmp_ID = Q_I.Cmp_ID
	INNER JOIN t0040_grade_master GM 
			ON Q_I.grd_id = gm.grd_id 
	INNER JOIN t0030_branch_master BM 
			ON Q_I.branch_id = BM.branch_id 
	LEFT OUTER JOIN t0040_department_master DM 
			ON Q_I.dept_id = DM.dept_id 
	LEFT OUTER JOIN t0040_designation_master DGM 
			ON Q_I.desig_id = DGM.desig_id 
		inner join T0080_EMP_MASTER em WITH (NOLOCK) on em.Emp_ID=CA.Emp_ID --and em.Cmp_ID=CA.Cmp_ID		
		INNER join T0120_CLAIM_APPROVAL cad WITH (NOLOCK) on ca.Claim_Apr_ID=cad.Claim_Apr_ID and ca.Emp_ID=cad.Emp_ID
		--INNER join T0040_CLAIM_MASTER cm WITH (NOLOCK) on cm.Claim_ID=cad.Claim_ID and CM.Cmp_ID=cad.Cmp_ID
		LEFT join T0100_CLAIM_APPLICATION CAP WITH(NOLOCK) on CAP.Claim_App_ID =ca.Claim_App_ID and ca.Emp_ID = CAP.Emp_ID
		INNER JOIN dbo.T0095_INCREMENT I WITH (NOLOCK)  ON em.Increment_ID = I.Increment_ID
		and CA.Emp_ID=EM.Emp_ID
