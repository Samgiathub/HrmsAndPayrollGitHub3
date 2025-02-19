

-- =============================================
-- Author:		Nilesh Patel
-- Create date: 08-Jan-2019
-- Description:	Stage Wise Induction Pending/Completed Details
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_RPT_GET_EMP_WISE_INDUCTION_TRAINING]
	@Cmp_ID Numeric,
	@From_Date Datetime,
	@To_Date Datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	If Object_ID('tempdb..#TrainingData') is not null
		Begin
			Drop Table #TrainingData
		End

	Create Table #TrainingData
	(
	    Cmp_ID Numeric,
		Emp_ID Numeric,
		Alpha_Emp_Code Varchar(25),
		Emp_Name Varchar(300),
		Date_Of_Join Datetime,
		HR_CheckList Numeric,
		HR_Evalution Numeric,
		Mark_Obtain Numeric(18,2),
		Fun_Checklist Numeric,
		Dept_ID Numeric,
		Induction_Training Varchar(30)
	)

	Insert Into #TrainingData
	Select @Cmp_ID,Emp_ID,Alpha_Emp_Code,Emp_Full_Name,Date_Of_Join,0,0,0,0,0,Induction_Training 
		From T0080_EMP_MASTER WITH (NOLOCK)
	Where Cmp_ID = @Cmp_ID and Induction_Training <> ''

	UPDATE TD
		SET TD.HR_CheckList = 1
	From #TrainingData TD Inner Join T0050_Emp_Wise_Checklist TC 
	ON TD.Emp_ID = TC.Emp_ID 

	UPDATE TD
		SET TD.Fun_Checklist = 1
	From #TrainingData TD Inner Join T0050_Emp_Wise_Fun_Checklist TC 
	ON TD.Emp_ID = TC.Emp_ID

	UPDATE TD
		SET TD.HR_Evalution = 1
	From #TrainingData TD Inner Join T0050_Emp_Wise_Checklist TC 
	ON TD.Emp_ID = TC.Emp_ID AND TC.Passing_Flag = 1


	UPDATE  E 
	SET		E.Dept_ID = Isnull(I.Dept_ID,0)
	FROM	#TrainingData E						
			INNER JOIN (SELECT	I1.EMP_ID, I1.INCREMENT_ID, I1.BRANCH_ID,I1.Dept_ID
						FROM	T0095_INCREMENT I1 WITH (NOLOCK) INNER JOIN #TrainingData E1 ON I1.Emp_ID=E1.EMP_ID
								INNER JOIN (
											SELECT	MAX(I2.Increment_ID) AS Increment_ID, I2.Emp_ID
												FROM	T0095_INCREMENT I2 WITH (NOLOCK)
												INNER JOIN #TrainingData E2 ON I2.Emp_ID=E2.EMP_ID
												INNER JOIN (
																SELECT	MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
																	FROM	T0095_INCREMENT I3 WITH (NOLOCK)
																	INNER JOIN #TrainingData E3 ON I3.Emp_ID=E3.EMP_ID
																WHERE	I3.Increment_Effective_Date <= GETDATE()
																GROUP BY I3.Emp_ID
															) I3 ON I2.Increment_Effective_Date=I3.INCREMENT_EFFECTIVE_DATE AND I2.Emp_ID=I3.Emp_ID																		
											WHERE	I2.Cmp_ID = @Cmp_Id 
											GROUP BY I2.Emp_ID
											) I2 ON I1.Emp_ID=I2.Emp_ID AND I1.Increment_ID=I2.INCREMENT_ID	
						WHERE	I1.Cmp_ID=@Cmp_Id											
					) I ON E.EMP_ID=I.Emp_ID

	Update TD
		Set Mark_Obtain = HT.Emp_Score
	From #TrainingData TD 
		OUTER APPLY DBO.Split(TD.Induction_Training,',') as Qry
	Inner Join T0140_HRMS_TRAINING_Feedback_Induction HT ON HT.Training_ID = Qry.Data and HT.Tran_Emp_Detail_Id = TD.Emp_ID
	Where HT.Induction_Training_Type = 1
	
	Select ROW_NUMBER() Over(order by TD.Emp_ID) as 'Sr.No','="' + TD.Alpha_Emp_Code + '"' as 'Employee Code',Emp_Name as 'Employee Name',
		   Case When TD.Dept_ID = 0 Then '-' Else DM.Dept_Name END As Dept_Name,
		   Case When HR_CheckList = 1 Then 'Completed' else 'Pending' End as 'Fill Up HR Checklist',
		   Case When HR_Evalution = 1 Then 'Completed' else 'Pending' End as 'HR Evalution',
		   TD.Mark_Obtain as 'HR Induction Obtain Marks',
		   Case When Fun_CheckList = 1 Then 'Completed' else 'Pending' End as 'Fill Up Functional Checklist'
	From #TrainingData TD Left OUTER Join T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON TD.Dept_ID = Dm.Dept_Id
	Where TD.Cmp_Id = @Cmp_ID and TD.Date_Of_Join >= @From_Date AND TD.Date_Of_Join <= @To_Date
END

