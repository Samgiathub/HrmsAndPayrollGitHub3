

-- =============================================
-- Author:		Nimesh Parmar
-- Create date: 22-Oct-2018
-- Description:	This method is used to retrieve the locked detail for Salary Process
---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P_GET_EMP_LOCKED_ATTENDANCE] 
	@Cmp_ID		Numeric, 
	@Step		TinyInt,
	@From_Date	DateTime,
	@To_Date	DateTime,
	@Mode		Char(1) = 'P',
	@Constraint Varchar(Max) = ''
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	CREATE TABLE #Emp_Cons 
	(      
		Emp_ID numeric ,     
		Branch_ID numeric,
		Increment_ID numeric
	)    
	EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,0,0,0,0,0,0 ,0 ,@Constraint ,0 ,0 ,0,0,0,0,0,0,0,0,0,0	
	
	CREATE TABLE #LOCKED_CONS 
	(      
		Emp_ID numeric ,     
		Branch_ID numeric,
		Increment_ID numeric
	)    
		
	CREATE UNIQUE CLUSTERED INDEX IX_LOCKED_CONS ON #LOCKED_CONS (EMP_ID);
	
	
	INSERT INTO #LOCKED_CONS
	SELECT * FROM #Emp_Cons
	
	
	DROP TABLE #Emp_Cons
	
	CREATE TABLE #Emp_Sal_Period
	(
		Emp_ID				Numeric,
		Month_Start_Date	DateTime,
		Month_End_Date		DateTime
	)
	
	INSERT INTO #Emp_Sal_Period 
	SELECT EMP_ID, @FROM_DATE, @TO_DATE FROM #LOCKED_CONS
	
	IF @Step = 1	/*Pending Leave*/
		BEGIN
			SELECT	EM.Alpha_Emp_Code, EM.Emp_Full_Name, LM.Leave_Name, LAD.Leave_Period, LAD.From_Date, LAD.To_Date
			FROM	T0100_Leave_Application LAP WITH (NOLOCK)
					INNER JOIN T0110_Leave_Application_Detail LAD WITH (NOLOCK) ON LAP.Leave_Application_ID=LAD.Leave_Application_ID
					INNER JOIN #Emp_Sal_Period ES ON LAP.Emp_ID=ES.Emp_ID 
								AND (LAD.From_Date Between ES.Month_Start_Date And ES.Month_End_Date OR LAD.To_Date Between ES.Month_Start_Date And ES.Month_End_Date)
					INNER JOIN T0080_Emp_Master EM WITH (NOLOCK) ON ES.Emp_ID=EM.Emp_ID
					INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LAD.Leave_ID=LM.Leave_ID
					LEFT OUTER JOIN T0120_Leave_Approval LAR WITH (NOLOCK) ON LAP.Leave_Application_ID=LAR.Leave_Application_ID					
			WHERE	LAR.Leave_Approval_ID IS NULL 
		END
    ELSE IF @Step = 2	/*Holiday WeekOff*/
		BEGIN 						
							 
			CREATE TABLE #Emp_WeekOff
			(
				Row_ID			NUMERIC,
				Emp_ID			NUMERIC,
				For_Date		DATETIME,
				Weekoff_day		VARCHAR(10),
				W_Day			numeric(4,1),
				Is_Cancel		BIT
			)
			CREATE CLUSTERED INDEX IX_Emp_WeekOff_EMPID_FORDATE ON #Emp_WeekOff(Emp_ID,For_Date);
			
			CREATE TABLE #EMP_HOLIDAY(EMP_ID NUMERIC, FOR_DATE DATETIME, IS_CANCEL BIT, Is_Half tinyint, Is_P_Comp tinyint, H_DAY numeric(4,1));
			CREATE UNIQUE CLUSTERED INDEX IX_EMP_HOLIDAY_EMPID_FORDATE ON #EMP_HOLIDAY(EMP_ID, FOR_DATE);

			SET @CONSTRAINT = NULL
			
			DELETE	HW 
			FROM	T0180_EMP_LOCKED_HW HW
					INNER JOIN #Emp_Sal_Period ES ON HW.Emp_ID=ES.Emp_ID AND HW.FOR_DATE BETWEEN ES.Month_Start_Date AND ES.Month_End_Date
			WHERE	IsLocked = 0
			
			SELECT	@CONSTRAINT = ISNULL(@CONSTRAINT + '#', '') + CAST(EC.EMP_ID AS VARCHAR(10)) 
			FROM	#LOCKED_CONS EC
			WHERE	NOT EXISTS(Select 1 FROM T0180_EMP_LOCKED_HW HW WITH (NOLOCK)
												INNER JOIN #Emp_Sal_Period ES ON HW.Emp_ID=ES.Emp_ID AND HW.FOR_DATE BETWEEN ES.Month_Start_Date AND ES.Month_End_Date
										 WHERE	HW.Emp_ID=EC.Emp_ID )
			
			IF ISNULL(@CONSTRAINT, '') <> ''
				BEGIN
					EXEC SP_GET_HW_ALL @CONSTRAINT=@CONSTRAINT,@CMP_ID=@Cmp_ID, @FROM_DATE=@FROM_DATE, @TO_DATE=@TO_DATE, @All_Weekoff = 0, @Exec_Mode=0, @Delete_Cancel_HW=0					
					
					INSERT	INTO T0180_EMP_LOCKED_HW(Cmp_ID,Emp_ID,For_Date,HW_Type,HW_Day,Is_Cancel,CancelReason,IsLocked)
					SELECT	@Cmp_ID,W.Emp_ID,For_Date, 'W', W_Day, Is_Cancel,'',0
					FROM	#Emp_WeekOff W 
							INNER JOIN #Emp_Sal_Period ES ON W.EMP_ID=ES.EMP_ID AND W.FOR_DATE BETWEEN ES.Month_Start_Date AND ES.Month_End_Date
					
					INSERT	INTO T0180_EMP_LOCKED_HW(Cmp_ID,Emp_ID,For_Date,HW_Type,HW_Day,Is_Cancel,CancelReason,IsLocked)
					SELECT	@Cmp_ID,H.Emp_ID,For_Date, 'H', H_Day, Is_Cancel,'',0
					FROM	#EMP_HOLIDAY H 
							INNER JOIN #Emp_Sal_Period ES ON H.EMP_ID=ES.EMP_ID AND H.FOR_DATE BETWEEN ES.Month_Start_Date AND ES.Month_End_Date
							
					INSERT	INTO T0180_EMP_LOCKED_HW(Cmp_ID,Emp_ID,For_Date,HW_Type,HW_Day,Is_Cancel,CancelReason,IsLocked)
					SELECT	@Cmp_ID,EC.Emp_ID,Month_Start_Date, 'N', 0, 0,'',0
					FROM	#LOCKED_CONS EC
							INNER JOIN #Emp_Sal_Period ES ON EC.EMP_ID=ES.EMP_ID 
					WHERE	NOT EXISTS(SELECT 1 FROM #Emp_WeekOff W WHERE W.EMP_ID=EC.EMP_ID)
							AND NOT EXISTS(SELECT 1 FROM #EMP_HOLIDAY H WHERE H.EMP_ID=EC.EMP_ID)							
							AND NOT EXISTS(SELECT 1 FROM T0180_EMP_LOCKED_HW HW WITH (NOLOCK) WHERE HW.EMP_ID=EC.EMP_ID AND HW.FOR_DATE BETWEEN ES.Month_Start_Date AND ES.Month_End_Date)
				END
					
			SELECT	EM.Alpha_Emp_Code, EM.Emp_Full_Name, BM.Branch_Name, Sum(W.HW_Day) As W_Days, Sum(H.HW_Day) As H_Days,
					(STUFF((SELECT	',' + CAST(W1.FOR_DATE AS VARCHAR(11)) + ';' + CAST(W1.HW_Day AS VARCHAR(5))
							FROM	T0180_EMP_LOCKED_HW W1 WITH (NOLOCK)
							WHERE	LC.EMP_ID=W1.EMP_ID AND W1.FOR_DATE BETWEEN ES.Month_Start_Date AND ES.Month_End_Date AND CASE WHEN @Mode = 'A' AND W1.IsLocked=1 Then 1 When @Mode = 'P' AND W1.IsLocked=0 Then 1 When @Mode = '' Then 1 Else 0 END = 1 AND W1.HW_Type='W'
									FOR XML PATH('')), 1,1, '')) AS WeekOff_Dates
					
			FROM	#LOCKED_CONS LC 					
					INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON LC.EMP_ID=EM.EMP_ID 
					INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON LC.BRANCH_ID=BM.BRANCH_ID										
					INNER JOIN #Emp_Sal_Period ES ON LC.EMP_ID=ES.EMP_ID 
					LEFT OUTER JOIN T0180_EMP_LOCKED_HW W WITH (NOLOCK) ON LC.EMP_ID=W.EMP_ID AND W.FOR_DATE BETWEEN ES.Month_Start_Date AND ES.Month_End_Date AND CASE WHEN @Mode = 'A' AND W.IsLocked=1 Then 1 When @Mode = 'P' AND W.IsLocked=0 Then 1 When @Mode = '' Then 1 Else 0 END = 1 AND W.HW_Type='W'
					LEFT OUTER JOIN T0180_EMP_LOCKED_HW H WITH (NOLOCK) ON LC.EMP_ID=H.EMP_ID AND H.FOR_DATE BETWEEN ES.Month_Start_Date AND ES.Month_End_Date AND CASE WHEN @Mode = 'A' AND H.IsLocked=1 Then 1 When @Mode = 'P' AND H.IsLocked=0 Then 1 When @Mode = '' Then 1 Else 0 END = 1 AND W.HW_Type='H'
			GROUP BY EM.Alpha_Emp_Code, EM.Emp_Full_Name, BM.Branch_Name,LC.EMP_ID, ES.Month_Start_Date, ES.Month_End_Date
		END
	ELSE IF @Step = 3	/*Attendance & Leave*/
		BEGIN
			PRINT 'CODE IS PENDING'
		END	
	ELSE IF @Step = 4	/*Late Early Deduction*/
		BEGIN
			PRINT 'CODE IS PENDING'
		END
	
END

