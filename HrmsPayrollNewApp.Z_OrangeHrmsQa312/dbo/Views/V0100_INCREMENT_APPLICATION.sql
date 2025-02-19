



CREATE VIEW [dbo].[V0100_INCREMENT_APPLICATION]
AS
SELECT	distinct e.Emp_Full_Name, I.App_ID, I.Emp_ID, I.Cmp_ID, I.Branch_ID, I.Cat_ID, I.Grd_ID, I.Dept_ID, I.Desig_Id, I.Type_ID, I.Bank_ID, I.Curr_ID, I.Wages_Type, I.Salary_Basis_On, 
		dbo.F_Show_Decimal(ISNULL(I.Basic_Salary,0), I.Cmp_ID) AS Basic_Salary, dbo.F_Show_Decimal(ISNULL(I.Gross_Salary,0), I.Cmp_ID) AS Gross_Salary, I.Increment_Type, I.Increment_Date, I.Increment_Effective_Date, 
		I.Payment_Mode, I.Inc_Bank_AC_No, I.Emp_OT, I.Emp_OT_Min_Limit, I.Emp_OT_Max_Limit, I.Increment_Per, dbo.F_Show_Decimal(I.Increment_Amount, I.Cmp_ID) AS Increment_Amount, 
		dbo.F_Show_Decimal(ISNULL(I.Pre_Basic_Salary,0), I.Cmp_ID) AS Pre_Basic_Salary, dbo.F_Show_Decimal(ISNULL(I.Pre_Gross_Salary,0), I.Cmp_ID) AS Pre_Gross_Salary, I.Increment_Comments, I.Emp_Late_mark, 
		I.Emp_Full_PF, I.Emp_PT, I.Emp_Fix_Salary, e.Emp_First_Name, e.Emp_code, e.Emp_Left, b.Branch_Name, dbo.T0040_GRADE_MASTER.Grd_Name, I.Yearly_Bonus_Amount, 
		I.Deputation_End_Date, dbo.T0040_DESIGNATION_MASTER.Desig_Name, dbo.F_Show_Decimal(ISNULL(I.CTC, 0), I.Cmp_ID) AS CTC, ISNULL(I.Center_ID, 0) AS Center_ID, e.Alpha_Emp_Code, 
		dbo.F_Show_Decimal(ISNULL(I.Pre_CTC_Salary,0), I.Cmp_ID) AS Pre_CTC_Salary, dbo.F_Show_Decimal(ISNULL(I.Incerment_Amount_gross,0), I.Cmp_ID) AS Incerment_Amount_gross, 
		dbo.F_Show_Decimal(ISNULL(I.Incerment_Amount_CTC,0), I.Cmp_ID) AS Incerment_Amount_CTC, I.Increment_Mode, I.is_physical, I.Segment_ID, I.Vertical_ID, I.SubVertical_ID, I.subBranch_ID, 
        I.Emp_Auto_Vpf, e.GroupJoiningDate, I.SalDate_id, I.Reason_ID, I.Reason_Name
		,ISNULL(Q.APPROVAL_STATUS,I.App_Status) App_Status
		--,I.App_Status
		,I.System_Date,I.Customer_Audit , I.Sales_Code,I.Is_Piece_Trans_Salary,I.Band_Id,I.Is_Pradhan_Mantri,I.Is_1time_PF_Member,I.Remarks
FROM    dbo.T0040_GRADE_MASTER WITH (NOLOCK) RIGHT OUTER JOIN
		dbo.T0100_INCREMENT_APPLICATION AS I WITH (NOLOCK)  ON dbo.T0040_GRADE_MASTER.Grd_ID = I.Grd_ID LEFT OUTER JOIN
		dbo.T0040_DEPARTMENT_MASTER WITH (NOLOCK)  ON I.Dept_ID = dbo.T0040_DEPARTMENT_MASTER.Dept_Id LEFT OUTER JOIN
		dbo.T0040_DESIGNATION_MASTER WITH (NOLOCK)  ON I.Desig_Id = dbo.T0040_DESIGNATION_MASTER.Desig_ID LEFT OUTER JOIN
		dbo.T0030_BRANCH_MASTER AS b WITH (NOLOCK)  ON I.Branch_ID = b.Branch_ID LEFT OUTER JOIN
		dbo.T0080_EMP_MASTER AS e WITH (NOLOCK)  ON I.Emp_ID = e.Emp_ID Left OUTER JOIN
		(
			SELECT	IAL.APP_ID,IAL.EMP_ID,isnull(Approval_Status,'I') AS APPROVAL_STATUS
			FROM	T0115_INCREMENT_APPROVAL_LEVEL IAL WITH (NOLOCK)
			WHERE	EXISTS(
								SELECT 1 FROM T0095_INCREMENT I  WITH (NOLOCK) 
								WHERE I.INCREMENT_APP_ID = IAL.APP_ID AND I.EMP_ID = IAL.EMP_ID
								)					
		)Q ON Q.APP_ID = I.APP_ID AND Q.EMP_ID = I.EMP_ID		
WHERE   (I.Increment_Type <> 'Joining') AND (ISNULL(I.Is_Master_Rec, 0) = 0)
		--and NOT EXISTS (select 1 FROM T0115_INCREMENT_APPROVAL_LEVEL TAL
		--				WHERE TAL.EMP_Id = I.EMP_Id and TAL.APP_ID = I.APP_ID
		--					  ANd I.App_Status = 'p')




