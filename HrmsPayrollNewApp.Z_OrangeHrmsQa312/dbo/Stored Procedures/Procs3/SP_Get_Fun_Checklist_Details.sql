

-- =============================================
-- Author:		Nilesh Patel 
-- Create date: 20-10-2018
-- Description:	Get Records of Function Checklist
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_Get_Fun_Checklist_Details] 
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
		Emp_Checklist_ID NUMERIC,
		R_Emp_ID Numeric 
	)


	INSERT INTO #EmpData
	SELECT EM.CMP_ID,EM.EMP_ID,0,0,EM.ALPHA_EMP_CODE,EM.EMP_FULL_NAME,HT.TRAINING_NAME,EM.DATE_OF_JOIN,'Pending',QRY_1.TRAN_ID,QRY_1.ASSIGN_CHECKLIST,QRY_1.Training_ID,0,0
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
		WHERE (EM.INDUCTION_TRAINING IS NOT NULL OR EM.INDUCTION_TRAINING <> '') AND HTT.INDUCTION_TRANING_DEPT = 2 
	AND EXISTS(SELECT 1 FROM T0050_EMP_WISE_CHECKLIST EC WITH (NOLOCK) WHERE EC.EMP_ID = EM.EMP_ID) -- Check Validation of If HR Induction is done than it will be eligiable for functional training here --Added by Nilesh For 27-12-2018
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
					
	UPDATE  E 
		SET	R_Emp_ID = Qry.R_Emp_ID				
	FROM	#EmpData E	
		Inner Join (
					Select RD.R_Emp_ID,RD.Emp_ID
					From  T0090_EMP_REPORTING_DETAIL RD  WITH (NOLOCK)
					INNER JOIN (
									SELECT MAX(EFFECT_DATE) AS EFFECT_DATE,EMP_ID FROM T0090_EMP_REPORTING_DETAIL  WITH (NOLOCK)
									WHERE EFFECT_DATE <= GETDATE()
									GROUP BY EMP_ID
								) AS EMP_SUP ON RD.EMP_ID = EMP_SUP.EMP_ID AND RD.EFFECT_DATE = EMP_SUP.EFFECT_DATE	
				  ) as Qry ON E.Emp_ID = Qry.Emp_ID
					  
	UPDATE ED	
		SET Training_Status = 'Approve',
		    Emp_Checklist_ID = EWC.Checklist_Fun_ID
	From #EmpData ED 
	Inner Join T0050_Emp_Wise_Fun_Checklist EWC ON ED.Emp_ID = EWC.Emp_ID and ED.Training_Tran_ID = EWC.Tran_ID AND ED.Training_ID = EWC.Training_ID 
	
	Declare @W_Str varchar(max)
	Set @W_Str = ''
				
	IF @Type_ID = 1
		BEGIN
			IF OBJECT_ID('tempdb..#Notification_Value') IS NOT NULL
					BEGIN
						TRUNCATE TABLE #Notification_Value
						INSERT INTO #Notification_Value
						Select	COUNT(*) as Chklist_Cnt 
						FROM	#EmpData
						WHERE	R_Emp_ID = @Emp_ID And Training_Status = 'Pending'
					END
				ELSE
					Select	COUNT(*) as Chklist_Cnt 
					FROM	#EmpData
					WHERE	R_Emp_ID = @Emp_ID And Training_Status = 'Pending'
			
		END
	Else if @Type_ID = 2 
		Begin
			Set @W_Str ='Select ED.*
							FROM #EmpData ED
						WHERE ED.R_Emp_ID = ' + Cast(@Emp_ID AS varchar(10)) + ' ' + @Constrains
			Exec(@W_Str)
			print @W_Str
		End
	Else if @Type_ID = 4 
		Begin
			Select * From #EmpData ED
			Inner Join T0040_Induction_Checklist IC WITH (NOLOCK)
			ON CHARINDEX('#' + Cast(IC.Checklist_ID as Varchar(10)) + '#','#' + ED.Assign_Checklist + '#') > 0
			Where ED.Emp_ID = @Emp_ID AND ED.Training_ID = @Training_ID and ED.Cmp_ID = @Cmp_ID
		End
END

