



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[Get_Grp_Cmp_Emp_GeneologyChart]
		@cmp_id  numeric(18,0)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


BEGIN
	
	SELECT  E.Emp_ID,'<table width="150px" style="font-family:verdana;font-size:10px;color:#444444;font-weight:bold;background-color:;"><tr><td align=center><img src="App_File/EMPIMAGES/' +(case when e.image_name = '0.jpg' then case when e.gender ='F' then 'Emp_Default_Female.png' else 'Emp_default.png' end else  case when e.image_name='' then case when gender ='F' then 'Emp_Default_Female.png' else 'Emp_default.png' end else isnull(e.image_name,'Emp_default.png') end end) +'" width="60px" height="50px" style=background-color:#F5F5F5;border-radius:50px;/></td></tr><tr><td style="border-top:1px solid #000;"></td></tr><tr><td>'+ (E.Alpha_Emp_Code+'-'+E.Emp_Full_Name) +'</td></tr></table>' as Emp_Full_Name,
			ER.R_Emp_ID,'<table width="150px" style="font-family:verdana;font-size:10px;color:#444444;font-weight:bold;background-color:;"><tr><td align=center><img src="App_File/EMPIMAGES/' +(case when RER.Manager_Img = '0.jpg' then case when RER.Manager_gender ='F' then 'Emp_Default_Female.png' else 'Emp_default.png' end else  case when RER.Manager_Img='' then case when RER.Manager_gender ='F' then 'Emp_Default_Female.png' else 'Emp_default.png' end else isnull(RER.Manager_Img,'Emp_default.png') end end) +'" width="60px" height="50px" style=background-color:#F5F5F5;border-radius:50px;/></td></tr><tr><td style="border-top:1px solid #000;"></td></tr><tr><td>'+  RER.Manager_Name +'</td></tr></table>' as Manager_Name,D.Dept_Name,RER.Sup_dept,DG.Desig_Name,
			RER.sup_desig,B.Branch_Name,RER.sup_branch
	FROM  T0010_COMPANY_MASTER C WITH (NOLOCK) 
	INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) on E.Cmp_ID = C.Cmp_Id
	INNER JOIN T0090_EMP_REPORTING_DETAIL ER WITH (NOLOCK) ON ER.Emp_ID = E.Emp_ID
	INNER JOIN(	
				SELECT MAX(Row_ID)Row_ID,ER1.Emp_ID 
				FROM T0090_EMP_REPORTING_DETAIL ER1 WITH (NOLOCK) INNER JOIN
				(
					SELECT MAX(Effect_Date)Effect_Date,Emp_ID  
					FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
					WHERE Effect_Date <= GETDATE()
					GROUP BY Emp_ID
				)ER2 ON ER2.Effect_Date = ER1.Effect_Date and ER2.Emp_ID=ER1.Emp_ID
				GROUP BY ER1.Emp_ID
			)ER3 ON ER3.Row_ID = ER.Row_ID	
	INNER JOIN (
					SELECT I1.Emp_ID,I1.Increment_ID,I1.Desig_Id,I1.Dept_ID,I1.Branch_ID
					FROM T0095_INCREMENT I1 WITH (NOLOCK)
					INNER JOIN (
									SELECT MAX(Increment_ID)Increment_ID,T0095_INCREMENT.Emp_ID
									FROM  T0095_INCREMENT WITH (NOLOCK)
									INNER JOIN (
													SELECT max(Increment_Effective_Date)Increment_Effective_Date,Emp_ID
													FROM T0095_INCREMENT WITH (NOLOCK)
													WHERE Increment_Effective_Date <= GETDATE()
													GROUP BY Emp_ID
												)I3	 ON i3.Emp_ID = T0095_INCREMENT.Emp_ID
									GROUP BY T0095_INCREMENT.Emp_ID
								)I2 ON I1.Emp_ID = I2.Emp_ID and I1.Increment_ID = i2.Increment_ID
				)I ON E.Emp_ID = I.Emp_ID 
	INNER JOIN (
				 SELECT RE.Emp_ID,(RE.Alpha_Emp_Code +'-'+ RE.Emp_Full_Name)Manager_Name,RE.Emp_Left,
						DR.Dept_Name as Sup_dept,BR.Branch_Name as sup_branch,DGR.Desig_Name as sup_desig,cmp_name as Sup_Company,re.image_name as Manager_Img,RE.Gender as Manager_gender
				 FROM T0080_EMP_MASTER RE WITH (NOLOCK)
				 INNER JOIN (
								SELECT IR2.Emp_ID,IR2.Increment_ID,Desig_Id,Dept_ID,Branch_ID
								FROM T0095_INCREMENT IR1 WITH (NOLOCK)
								INNER JOIN (
												SELECT MAX(Increment_ID)Increment_ID,Emp_ID
												FROM T0095_INCREMENT WITH (NOLOCK)
												GROUP by Emp_ID
											)IR2 on IR1.Increment_ID = IR2.Increment_ID AND IR1.Emp_ID = IR2.Emp_ID
							)IR ON IR.Emp_ID = RE.Emp_ID
				LEFT JOIN T0040_DESIGNATION_MASTER DGR WITH (NOLOCK) ON DGR.Desig_ID = IR.Desig_Id
				LEFT JOIN T0040_DEPARTMENT_MASTER DR WITH (NOLOCK) ON DR.Dept_Id = IR.Dept_ID
				LEFT JOIN T0030_BRANCH_MASTER BR WITH (NOLOCK) ON BR.Branch_ID = IR.Branch_ID
				INNER JOIN T0010_COMPANY_MASTER CR WITH (NOLOCK) on CR.Cmp_Id = RE.Cmp_ID
				 WHERE  RE.Emp_Left <> 'Y'
			)RER ON RER.Emp_ID = ER.R_Emp_ID
	LEFT JOIN T0040_DESIGNATION_MASTER DG WITH (NOLOCK) ON DG.Desig_ID = I.Desig_Id
	LEFT JOIN T0040_DEPARTMENT_MASTER D WITH (NOLOCK) ON D.Dept_Id = I.Dept_ID
	LEFT JOIN T0030_BRANCH_MASTER B WITH (NOLOCK) ON B.Branch_ID = I.Branch_ID
	WHERE C.is_GroupOFCmp = 1 and E.Emp_Left<>'Y' AND RER.Emp_Left <> 'Y'
END

