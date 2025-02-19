




CREATE VIEW [dbo].[V0100_IT_DECLARATION_RECORDS]
AS
SELECT     dbo.T0070_IT_MASTER.IT_Name,IT.FINANCIAL_YEAR,
		   IT.AMOUNT_ESS AS PROVISIONAL_AMOUNT, 
		   IT.AMOUNT AS Approval_AMOUNT, 
           dbo.T0080_EMP_MASTER.Alpha_Emp_Code,dbo.T0080_EMP_MASTER.Emp_ID, 
		   dbo.T0080_EMP_MASTER.Cmp_ID,dbo.T0080_EMP_MASTER.Emp_Full_Name,
		   CASE WHEN Is_Lock = 1 then 'Approved' Else 'Pending'  ENd as [Status],
		   dbo.T0070_IT_MASTER.IT_ID,(LEFT(DATENAME(MM,FOR_DATE),3) + '/' + DATENAME(YEAR,FOR_DATE)) As MONTHYEAR,
		   FOR_DATE,DOC_NAME,dbo.T0070_IT_MASTER.LOGIN_ID,Is_Lock,Is_Metro_City,
		   IT_Def_ID,IT_TRAN_ID,AMOUNT_ESS,IT.IT_Flag,
		   I.branch_Id,I.Dept_Id,I.Desig_Id,I.Grd_ID,I.Cat_ID,I.Vertical_ID,I.SubVertical_ID
		   ,I.Segment_ID,I.[Type_ID]
		   ,I.subBranch_ID, CASE WHEN COALESCE(DT.FileName, IT.DOC_NAME,'') <> '' THEN 1 ELSE 0 END As  HasDoc
		   
FROM       dbo.T0070_IT_MASTER WITH (NOLOCK) INNER JOIN
		   dbo.T0100_IT_DECLARATION IT WITH (NOLOCK)  ON dbo.T0070_IT_MASTER.IT_ID = IT.IT_ID INNER JOIN
           dbo.T0080_EMP_MASTER WITH (NOLOCK)  ON IT.EMP_ID = dbo.T0080_EMP_MASTER.Emp_ID INNER JOIN
			dbo.T0095_INCREMENT I WITH (NOLOCK)  ON dbo.T0080_EMP_MASTER.Increment_ID = I.Increment_ID 
			LEFT OUTER JOIN (SELECT Emp_ID,IT_ID,MAX(FileName) As FileName FROM T0110_IT_Emp_Details ED WITH (NOLOCK)  Where IsNull(FileName, '') <> '' Group By Emp_ID,IT_ID) DT ON DT.Emp_ID=IT.Emp_ID AND DT.IT_ID=IT.IT_ID
			-- Inner join
			--dbo.T0110_IT_Emp_Details IED On IED.Emp_ID = dbo.T0100_IT_DECLARATION.EMP_ID 
			--AND IED.Financial_Year = dbo.T0100_IT_DECLARATION.Financial_Year
			--Inner join
		   --T0030_BRANCH_MASTER BM ON BM.BRanch_Id = I.Branch_ID		LEFT OUTER Join
		   --T0040_DEPARTMENT_MASTER DM ON Dm.Dept_Id = I.Dept_Id 	LEFT OUTER Join
		   --T0040_DESIGNATION_MASTER DN On Dn.Desig_ID = I.Desig_Id  LEFT OUTER Join
		   --T0040_GRADE_MASTER Gm On Gm.Grd_ID = I.Grd_ID			LEFT OUTER Join
		   --T0030_CATEGORY_MASTER Cm On Cm.Cat_ID = I.Cat_ID			LEFT OUTER Join
		   --T0040_Vertical_Segment vs On vs.Vertical_ID = I.Vertical_ID	LEFT OUTER Join
		   --T0050_SubVertical Sv On sv.SubVertical_ID = I.SubVertical_ID
Where IT_Def_ID NOT IN(172,173)


