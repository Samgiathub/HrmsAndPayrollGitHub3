

-- =============================================
-- Author:		Nilesh Patel 
-- Create date: 20-10-2018
-- Description:	Get Records of HR Checklist
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_Get_HR_Checklist_Details] 
	-- Add the parameters for the stored procedure here
	@Cmp_ID Numeric,
	@Emp_ID Numeric,
	@Type_ID Numeric,
	@Constrains Varchar(200) = '',
	@Training_ID Numeric = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	
	IF @Constrains is null  
		Begin
			Set @Constrains = ''
		End
		
	
	IF Object_ID('tempdb..#EmpData') Is not null
		Begin
			Drop Table #EmpData
		End

	Create Table #EmpData
	(
		Cmp_ID Numeric,
		Emp_ID Numeric,
		Branch_ID Numeric,
		Increment_ID Numeric,
		Alpha_Emp_Code Varchar(100),
		Emp_Full_Name Varchar(200),
		Training_Name Varchar(100),
		Training_Date DateTime,
		Training_Status Varchar(10),
		Training_Tran_ID Numeric,
		Assign_Checklist Varchar(500),
		Training_ID NUMERIC,
		Emp_Checklist_ID NUMERIC 
		
	)

	INSERT INTO #EmpData
	SELECT EM.CMP_ID,EM.EMP_ID,0,0,EM.ALPHA_EMP_CODE,EM.EMP_FULL_NAME,HT.TRAINING_NAME,EM.DATE_OF_JOIN,'Pending',QRY_1.TRAN_ID,QRY_1.ASSIGN_CHECKLIST,QRY_1.Training_ID,0
		FROM T0080_EMP_MASTER EM WITH (NOLOCK)
	OUTER APPLY DBO.SPLIT(EM.INDUCTION_TRAINING,',') QRY
	INNER JOIN T0040_HRMS_TRAINING_MASTER HT WITH (NOLOCK) ON CAST(HT.TRAINING_ID AS VARCHAR) = ISNULL(QRY.DATA,'0')
	INNER JOIN T0030_HRMS_TRAINING_TYPE HTT WITH (NOLOCK) ON HTT.TRAINING_TYPE_ID = HT.TRAINING_TYPE
	--INNER JOIN T0050_TRAINING_WISE_CHECKLIST TWC ON TWC.TRAINING_ID = HT.TRAINING_ID
	INNER JOIN(
				SELECT T.* 
					FROM T0050_TRAINING_WISE_CHECKLIST T WITH (NOLOCK)
				INNER JOIN (
								SELECT MAX(EFFECTIVE_DATE) AS EFF_DATE,TRAINING_ID AS TRAINING_ID
									FROM T0050_TRAINING_WISE_CHECKLIST WITH (NOLOCK)
								WHERE EFFECTIVE_DATE <= GETDATE()
								GROUP BY TRAINING_ID	
							) AS QRY
				ON T.TRAINING_ID = QRY.TRAINING_ID AND T.EFFECTIVE_DATE = QRY.EFF_DATE	
			   ) AS QRY_1 ON QRY_1.TRAINING_ID = HT.TRAINING_ID
		WHERE (EM.INDUCTION_TRAINING IS NOT NULL OR EM.INDUCTION_TRAINING <> '') AND HTT.INDUCTION_TRANING_DEPT = 1 
	--AND NOT EXISTS(SELECT 1 FROM T0050_EMP_WISE_CHECKLIST EC WHERE EC.EMP_ID = EM.EMP_ID) 
	AND EM.CMP_ID = @CMP_ID

	UPDATE  E 
	SET		Branch_ID = I.Branch_ID, Increment_ID=I.Increment_ID
	FROM	#EmpData E						
			INNER JOIN (SELECT	I1.EMP_ID, I1.INCREMENT_ID, I1.BRANCH_ID
						FROM	T0095_INCREMENT I1 WITH (NOLOCK) INNER JOIN #EmpData E1 ON I1.Emp_ID=E1.EMP_ID
								INNER JOIN (
											SELECT	MAX(I2.Increment_ID) AS Increment_ID, I2.Emp_ID
												FROM	T0095_INCREMENT I2 WITH (NOLOCK) INNER JOIN #EmpData E2 ON I2.Emp_ID=E2.EMP_ID
													INNER JOIN (
																SELECT	MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
																	FROM	T0095_INCREMENT I3 WITH (NOLOCK) INNER JOIN #EmpData E3 ON I3.Emp_ID=E3.EMP_ID
																WHERE	I3.Increment_Effective_Date <= GETDATE()
																GROUP BY I3.Emp_ID
																) I3 ON I2.Increment_Effective_Date=I3.INCREMENT_EFFECTIVE_DATE AND I2.Emp_ID=I3.Emp_ID																		
											WHERE	I2.Cmp_ID = @Cmp_Id 
											GROUP BY I2.Emp_ID
											) I2 ON I1.Emp_ID=I2.Emp_ID AND I1.Increment_ID=I2.INCREMENT_ID	
						WHERE	I1.Cmp_ID=@Cmp_Id											
					) I ON E.EMP_ID=I.Emp_ID
	
					
	UPDATE ED	
		SET Training_Status = 'Approve',
		    Emp_Checklist_ID = EWC.Checklist_ID
	From #EmpData ED 
	Inner Join T0050_Emp_Wise_Checklist EWC 
	ON ED.Emp_ID = EWC.Emp_ID and ED.Training_Tran_ID = EWC.Tran_ID AND ED.Training_ID = EWC.Training_ID 
				

	If Object_ID('tempdb..#Email_Branch') is not null
		Begin
			Drop Table #Email_Branch
		End

	CREATE TABLE #Email_Branch
	(
		Login_ID numeric(18,0),
		Branch_Id numeric(18,0)
	)
	Declare @Branch_ID_Multi Varchar(100) 
	Declare @Login_Id Numeric

	Declare CurHR cursor for 
		Select isnull(Branch_ID_multi,0) as Branch_ID_multi,Login_Id From T0011_LOGIN WITH (NOLOCK)
	Where Cmp_ID = @Cmp_ID And Is_HR = 1 and Is_Active =1

	Open CurHR
	fetch next from CurHR into @Branch_ID_Multi,@Login_Id
		while @@fetch_status = 0
			begin	
					Insert into #Email_Branch
					 select @Login_ID,data
					 from dbo.Split(@Branch_ID_Multi,',')
				fetch next from CurHR into @Branch_ID_Multi,@Login_Id
			end
	close CurHR
	deallocate CurHR

	Declare @W_Str Varchar(Max)
	Set @W_Str = ''
	
	IF @Type_ID = 1 
		Begin
			DECLARE @Count Numeric(18,2)
			
			Select	@Count = COUNT(*) 
			FROM	#Email_Branch EB
					INNER JOIN T0011_LOGIN TL WITH (NOLOCK) ON TL.Login_ID = EB.Login_ID
					INNER JOIN #EmpData ED ON (ED.Branch_ID = EB.Branch_ID OR EB.Branch_Id = 0)
			WHERE	TL.Emp_ID = @Emp_ID And Training_Status = 'Pending'

			IF OBJECT_ID('tempdb..#Notification_Value') IS NOT NULL
					BEGIN
						TRUNCATE TABLE #Notification_Value
						INSERT INTO #Notification_Value
						SELECT @Count as Chklist_Cnt
					END
				ELSE
					SELECT @Count AS Chklist_Cnt 

		End
	Else if @Type_ID = 2 
		Begin
			Set @W_Str ='Select ED.*
							FROM #Email_Branch EB
						INNER JOIN T0011_LOGIN TL WITH (NOLOCK) ON TL.Login_ID = EB.Login_ID
						INNER JOIN #EmpData ED ON (ED.Branch_ID = EB.Branch_ID OR EB.Branch_Id = 0)
						WHERE TL.Emp_ID = ' + Cast(@Emp_ID AS varchar(10)) + ' ' + @Constrains
			
			Exec(@W_Str)
		End
	Else if @Type_ID = 3
		Begin
			Select ED.*
				FROM #Email_Branch EB
			INNER JOIN T0011_LOGIN TL WITH (NOLOCK) ON TL.Login_ID = EB.Login_ID
			INNER JOIN #EmpData ED ON (ED.Branch_ID = EB.Branch_ID OR EB.Branch_Id = 0)
			WHERE TL.Emp_ID = @Emp_ID
		End
	Else if @Type_ID = 4 
		Begin
			Select * From #EmpData ED
			Inner Join T0040_Induction_Checklist IC WITH (NOLOCK)
			ON CHARINDEX('#' + Cast(IC.Checklist_ID as Varchar(10)) + '#','#' + ED.Assign_Checklist + '#') > 0
			Where ED.Emp_ID = @Emp_ID AND ED.Training_ID = @Training_ID
		End
END

