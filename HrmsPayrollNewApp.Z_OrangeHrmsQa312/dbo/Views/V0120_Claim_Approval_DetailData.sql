



CREATE VIEW [dbo].[V0120_Claim_Approval_DetailData]
As
select distinct cad.Emp_ID,cad.Claim_Apr_ID,cad.Cmp_ID,
				cad.Claim_App_ID,em.Emp_First_Name,em.Emp_Full_Name,ca.Claim_Apr_Pending_Amount,Em.Emp_Left
				,em.Emp_code,cad.Claim_Status as Claim_Apr_Status,ca.Claim_Apr_Date as Claim_Apr_Date,ca.Claim_App_Date,CAP.S_Emp_ID,
				I.Branch_ID,I.Desig_Id,i.Grd_ID,Claim_App_Code,CLAIM_APP_DOC,Em.Alpha_Emp_Code,Claim_Limit_Type,Other_Email,Mobile_No,cad.Claim_ID,--,cm.Claim_Name
				ISNULL(REVERSE(STUFF(REVERSE((SELECT DISTINCT   CM.Claim_Name + ','
                            FROM          T0130_CLAIM_APPROVAL_DETAIL CD WITH (NOLOCK)
							LEFT JOIN T0040_CLAIM_MASTER cm WITH (NOLOCK) on cm.Claim_ID=CD.Claim_ID
                            WHERE      CD.Claim_Apr_ID IN
                                                       (SELECT     cast(data AS numeric(18, 0))
                                                         FROM          dbo.Split(ISNULL(CAD.Claim_Apr_ID, '0'), '#')
                                                         WHERE      data <> '') FOR XML path('') )), 1, 1, '')),'') AS Claim_Name
				--cad.Claim_App_Amount,cad.Claim_ID,cm.Claim_Name,cad.Claim_Apr_Dtl_ID,cad.Claim_Apr_Amount,
 from T0130_CLAIM_APPROVAL_DETAIL CAD WITH (NOLOCK)
		inner join T0080_EMP_MASTER em WITH (NOLOCK) on em.Emp_ID=cad.Emp_ID and em.Cmp_ID=cad.Cmp_ID		
		left join T0120_CLAIM_APPROVAL ca WITH (NOLOCK) on ca.Claim_Apr_ID=cad.Claim_Apr_ID and ca.Emp_ID=cad.Emp_ID
		left join T0040_CLAIM_MASTER cm WITH (NOLOCK) on cm.Claim_ID=cad.Claim_ID
		left join T0100_CLAIM_APPLICATION CAP WITH(NOLOCK) on CAP.Claim_App_ID =ca.Claim_App_ID and ca.Emp_ID = CAP.Emp_ID
		INNER JOIN dbo.T0095_INCREMENT I WITH (NOLOCK)  ON em.Increment_ID = I.Increment_ID
		and cm.Cmp_ID=cad.Cmp_ID
