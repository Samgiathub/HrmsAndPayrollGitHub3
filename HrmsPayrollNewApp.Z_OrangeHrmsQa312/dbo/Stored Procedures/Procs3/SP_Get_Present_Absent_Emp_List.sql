

---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Get_Present_Absent_Emp_List]
(
	@Cmp_Id NUMERIC,
	@TO_DATE datetime
)  
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	BEGIN 
		CREATE table #TMP_ABSENT(
			Cmp_Id NUMERIC,
			Emp_Id NUMERIC,
			Emp_Code VARCHAR(100),
			Emp_Full_Name VARCHAR(200),
			Desig_Name VARCHAR(100),
			Dept_Name VARCHAR(100),
			For_Date Datetime,
			Status VARCHAR(10),
			Branch_Name VARCHAR(100)
		) 
		

		IF @Cmp_Id = 0
			SET @Cmp_Id = Null
	
		CREATE TABLE #PRESENT
		( 
			Cmp_Id		NUMERIC, 
			EMP_ID		NUMERIC,  
			EMP_CODE	VARCHAR(100),  
			EMP_FULL_NAME VARCHAR(100),  
			IN_TIME		DATETIME,  
			STATUS		CHAR(2),
			type		VARCHAR(50),
			Type_Name	VARCHAR(100),
			Desig_Name	VARCHAR(100),
			Dept_Name	VARCHAR(100),
			BRANCH_NAME VARCHAR(100)	--Added By Ramiz on 07/08/2018
		)  
		
		CREATE NONCLUSTERED INDEX IX_PRESENT ON #PRESENT(EMP_ID) INCLUDE(CMP_ID)

		/*************************************************************************
		Added by Nimesh: 25/Sep/2017 
		(To get holiday/weekoff data for all employees in seperate table)
		*************************************************************************/

		CREATE TABLE #EMP_HOLIDAY(EMP_ID NUMERIC, FOR_DATE DATETIME, IS_CANCEL BIT, Is_Half tinyint, Is_P_Comp tinyint, H_DAY numeric(4,1));
		CREATE UNIQUE CLUSTERED INDEX IX_EMP_HOLIDAY_EMPID_FORDATE ON #EMP_HOLIDAY(EMP_ID, FOR_DATE);

		CREATE TABLE #EMP_WEEKOFF
		(
			Row_ID			NUMERIC,
			Emp_ID			NUMERIC,
			For_Date		DATETIME,
			Weekoff_day		VARCHAR(10),
			W_Day			numeric(4,1),
			Is_Cancel		BIT
		)
		CREATE CLUSTERED INDEX IX_Emp_WeekOff_EmpID_ForDate ON #EMP_WEEKOFF(Emp_ID, For_Date)	
		
		DECLARE @CONSTRAINT AS VARCHAR(MAX);	
		DECLARE @Cmp_Id_C AS NUMERIC

		DECLARE curCompany CURSOR FAST_FORWARD FOR
		SELECT Cmp_Id FROM T0010_COMPANY_MASTER WITH (NOLOCK) WHERE Cmp_Id = IsNull(@Cmp_Id,Cmp_Id)
		OPEN curCompany                      
		FETCH NEXT FROM curCompany INTO @Cmp_Id_C
		WHILE @@FETCH_STATUS = 0                    
			BEGIN     
				DELETE FROM #PRESENT

				INSERT INTO #PRESENT (Cmp_Id,EMP_ID,EMP_CODE,EMP_FULL_NAME,IN_TIME,STATUS,type,Type_Name)   
				SELECT	@Cmp_Id_C, EIR.Emp_ID,CAST(EM.Alpha_Emp_Code  AS VARCHAR(25)) AS EMP_CODE, EM.EMP_FULL_NAME  AS Emp_Full_Name,Min(EIR.In_Time),'P',
							'<font color="Darkblue">P</font>',('<font color="green">' + Type_name + '</font>') AS  Type_name 
				FROM	T0150_EMP_INOUT_RECORD EIR WITH (NOLOCK)
						INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EIR.Emp_ID=EM.Emp_ID 
						INNER JOIN T0095_INCREMENT AS I WITH (NOLOCK) ON EM.INCREMENT_ID=I.INCREMENT_ID
						LEFT OUTER JOIN T0040_TYPE_MASTER TM WITH (NOLOCK) ON EM.type_id=tm.type_id
				WHERE	MONTH(EIR.in_time) = MONTH(@TO_DATE) AND YEAR(EIR.in_time) = YEAR(@TO_DATE) 
						AND DAY(EIR.in_time)= DAY(@TO_DATE) AND I.CMP_ID = @Cmp_Id_C 
				GROUP BY EIR.Emp_ID,CAST(EM.Alpha_Emp_Code  AS VARCHAR(25)), EM.EMP_FULL_NAME,Type_name   
			
				INSERT	INTO #PRESENT (Cmp_Id,EMP_ID,EMP_CODE,EMP_FULL_NAME,STATUS,type,Type_Name)	
				SELECT	@Cmp_Id_C, LA.Emp_ID, CAST(EM.Alpha_Emp_Code  AS VARCHAR(25))  AS EMP_CODE,( EM.EMP_FULL_NAME ) AS Emp_Full_Name,'L','<font color="blue">' + 'L' + '</font>' ,(Type_name) AS  Type_name  
				FROM	T0120_LEAVE_APPROVAL AS LA WITH (NOLOCK)  
						INNER JOIN T0080_EMP_MASTER AS EM WITH (NOLOCK) ON LA.Emp_ID=EM.emp_ID 
						INNER JOIN T0095_INCREMENT AS I WITH (NOLOCK) ON EM.INCREMENT_ID = I.INCREMENT_ID 
						LEFT OUTER JOIN T0130_LEAVE_APPROVAL_DETAIL AS LAD WITH (NOLOCK) ON LA.Leave_Approval_ID=LAD.Leave_Approval_ID 
						INNER JOIN T0040_LEAVE_MASTER TLM WITH (NOLOCK) ON LAD.Leave_ID=TLM.Leave_ID 
						LEFT OUTER JOIN T0040_TYPE_MASTER TM WITH (NOLOCK) ON EM.type_id=tm.type_id 
						LEFT OUTER JOIN T0135_LEAVE_CANCELATION AS LC WITH (NOLOCK) ON LAD.Leave_Approval_ID =Lc.Leave_Approval_ID 
				WHERE	LAD.from_Date < = @TO_DATE AND LAD.To_Date >= @TO_DATE AND LA.approval_status='A' AND I.CMP_ID=@Cmp_Id_C 
						AND Leave_TYpe <> 'Company Purpose' AND IsNull(Lv_can_Status,0) =0 -- this line added by mihir 10012012
						-- AND  Lv_can_Status=0 
				
				INSERT	INTO #PRESENT (Cmp_Id,EMP_ID,EMP_CODE,EMP_FULL_NAME,STATUS,type,Type_Name)  
				SELECT	@Cmp_Id_C,LA.Emp_ID, CAST(EM.Alpha_Emp_Code  AS VARCHAR(25))   AS EMP_CODE,( EM.EMP_FULL_NAME ) AS Emp_Full_Name,'OD','<font color="orange">' + 'OD' + '</font>',(Type_name ) AS  Type_name 
				FROM	T0120_LEAVE_APPROVAL AS LA WITH (NOLOCK) 			
						INNER JOIN T0080_EMP_MASTER AS EM WITH (NOLOCK) ON LA.emp_id=EM.Emp_ID 
						INNER JOIN T0095_INCREMENT AS I WITH (NOLOCK) ON EM.INCREMENT_ID = I.INCREMENT_ID 
						LEFT OUTER JOIN T0130_LEAVE_APPROVAL_DETAIL AS lad WITH (NOLOCK) ON LA.leave_approval_ID=LAD.leave_approval_ID 
						INNER JOIN T0040_LEAVE_MASTER TLM WITH (NOLOCK) ON LAD.Leave_ID=TLM.Leave_ID 
						LEFT OUTER JOIN T0040_TYPE_MASTER TM WITH (NOLOCK) ON EM.type_id=tm.type_id
				WHERE   LAD.from_Date < = @TO_DATE AND LAD.To_Date >= @TO_DATE AND LA.approval_status='A' AND I.CMP_ID=@Cmp_Id_C AND Leave_TYpe = 'Company Purpose'  
			  
			  
				INSERT	INTO #PRESENT (Cmp_Id,EMP_ID,EMP_CODE,EMP_FULL_NAME,STATUS,type,Type_Name)  
				SELECT	@Cmp_Id_C, EM.Emp_ID , CAST(EM.Alpha_Emp_Code  AS VARCHAR(25))   AS EMP_CODE,( EM.EMP_FULL_NAME ) AS Emp_Full_Name,'A','<font color="Red">' + 'A' + '</font>',(Type_name) AS  Type_name  
				FROM	T0080_EMP_MASTER EM WITH (NOLOCK) 
						INNER JOIN T0095_INCREMENT AS I WITH (NOLOCK) ON EM.Increment_ID=i.Increment_ID
						LEFT OUTER JOIN t0040_type_master TM WITH (NOLOCK) ON EM.type_id=tm.type_id
				WHERE	EM.emp_id NOT IN (SELECT Emp_ID FROM #PRESENT) AND I.CMP_ID=@Cmp_Id_C


				TRUNCATE TABLE #EMP_WEEKOFF
				TRUNCATE TABLE #EMP_HOLIDAY
				SET @CONSTRAINT = NULL;

				SELECT	@CONSTRAINT = COALESCE(@CONSTRAINT + '#','')
				FROM	#PRESENT
				WHERE	Cmp_Id=@Cmp_Id_C

				EXEC SP_GET_HW_ALL @CONSTRAINT=@CONSTRAINT,@CMP_ID=@Cmp_ID, @FROM_DATE=@TO_DATE, @TO_DATE=@TO_DATE, @All_Weekoff = 0, @Exec_Mode=0		

			  
				---- Alpesh 26-May-2012 ---- to show IF week off is ON that perticular date instead of absent
				--DECLARE @Emp_ID	NUMERIC
				--DECLARE @Is_Cancel_Holiday  NUMERIC(1,0)    
				--DECLARE @Is_Cancel_Weekoff  NUMERIC(1,0)
				--DECLARE @Left_Date		datetime  
				--DECLARE @join_dt   		datetime  
				--DECLARE @StrHoliday_Date  VARCHAR(max)    
				--DECLARE @StrWeekoff_Date  VARCHAR(max)
				--DECLARE @Cancel_Weekoff	NUMERIC(18, 0)
				--DECLARE @WO_Days	NUMERIC
				--DECLARE @Branch_ID AS NUMERIC
				--DECLARE @Desig_Id AS NUMERIC
				--DECLARE @Dept_Id AS NUMERIC
				--DECLARE @Desig_Name AS VARCHAR(100)
				--DECLARE @Dept_Name AS VARCHAR(100)
				--DECLARE @Holiday_days NUMERIC (2,0)
				--DECLARE @Cancel_Holiday NUMERIC (2,0)
		
				--DECLARE @Cancel_Holiday   NUMERIC(18, 0)
				--DECLARE @Emp_Left_Date	datetime
			  
				--SET @Is_Cancel_Weekoff = 0 
				--SET @StrHoliday_Date = ''    
				--SET @StrWeekoff_Date = ''  
				--SET @Holiday_days = 0
				--SET @Cancel_Holiday=0

				UPDATE	P
				SET		Desig_Name = DG.Desig_Name,
						Dept_Name = D.Dept_Name,
						BRANCH_NAME = BM.Branch_Name
				FROM	#PRESENT P 
						INNER JOIN T0095_INCREMENT I ON P.EMP_ID=I.EMP_ID
						INNER JOIN (SELECT	I1.EMP_ID, MAX(I1.Increment_ID) AS Increment_ID
									FROM	T0095_INCREMENT I1 WITH (NOLOCK)
											INNER JOIN (SELECT	MAX(Increment_effective_Date) AS For_Date, Emp_ID
														FROM	T0095_INCREMENT I2 WITH (NOLOCK)
														WHERE	Increment_Effective_Date <= @TO_DATE 
														GROUP BY emp_ID ) I2 ON I1.Emp_ID = I2.Emp_ID AND I1.Increment_effective_Date = I2.For_Date  
									GROUP BY I1.Emp_ID) I1 ON I.EMP_ID=I1.EMP_ID AND I.Increment_ID=I1.Increment_ID
						LEFT OUTER JOIN T0040_DEPARTMENT_MASTER D WITH (NOLOCK) ON I.Dept_ID=D.Dept_Id
						LEFT OUTER JOIN T0040_DESIGNATION_MASTER DG WITH (NOLOCK) ON I.Desig_Id=DG.Desig_ID
						INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I.Branch_ID = BM.Branch_ID
				WHERE	P.CMP_ID=@CMP_ID_C		

				UPDATE	P
				SET		STATUS='WO',
						type='<font color="Green">WO</font>'
				FROM	#PRESENT P
						INNER JOIN #EMP_WEEKOFF W ON P.EMP_ID=W.Emp_ID AND W.For_Date=@TO_DATE
				WHERE	P.Cmp_Id=@Cmp_Id_C
				
				UPDATE	P
				SET		STATUS='HO',
						type='<font color="Green">HO</font>'
				FROM	#PRESENT P
						INNER JOIN #EMP_HOLIDAY H ON P.EMP_ID=H.Emp_ID AND H.For_Date=@TO_DATE
				WHERE	P.Cmp_Id=@Cmp_Id_C

			  
				--DECLARE cur CURSOR FAST_FORWARD FOR 
				--SELECT EMP_ID FROM #PRESENT
				
				--OPEN cur
				--FETCH NEXT FROM cur INTO @Emp_ID
			  
				--WHILE @@FETCH_STATUS = 0
				--	BEGIN

				--		--SELECT	@Branch_ID = Branch_Id, @Desig_Id = Desig_Id, @Dept_Id=Dept_ID 
				--		--FROM	T0095_INCREMENT I 
				--		--		INNER JOIN  (SELECT MAX(Increment_effective_Date) AS For_Date, Emp_ID 
				--		--					 FROM	T0095_INCREMENT
				--		--					 WHERE	Increment_Effective_Date <= @TO_DATE AND Cmp_ID = @Cmp_Id_C AND Emp_ID = @Emp_ID
				--		--					 GROUP BY emp_ID ) Qry ON I.Emp_ID = Qry.Emp_ID AND I.Increment_effective_Date = Qry.For_Date  
			
				--		--SELECT @Dept_Name = Dept_Name FROM T0040_DEPARTMENT_MASTER WHERE Dept_Id = @Dept_Id	
				--		--SELECT @Desig_Name = Desig_Name FROM T0040_DESIGNATION_MASTER WHERE Desig_ID = @Desig_Id	

				--		--Update #PRESENT SET Dept_Name = @Dept_Name, Desig_Name = @Desig_Name WHERE EMP_ID = @Emp_ID
					
				--		--IF @Branch_ID is null
				--		--	BEGIN 
				--		--		SELECT	TOP 1 @Is_Cancel_Weekoff = Is_Cancel_Weekoff 
				--		--		FROM	T0040_GENERAL_SETTING 
				--		--		WHERE cmp_ID = @Cmp_Id_C AND For_Date = ( SELECT max(For_Date) FROM T0040_GENERAL_SETTING WHERE For_Date <= @TO_DATE AND Cmp_ID = @Cmp_Id_C)    
				--		--	End
				--		--Else
				--		--	BEGIN
				--		--		SELECT	@Is_Cancel_Weekoff = Is_Cancel_Weekoff 
				--		--		FROM	T0040_GENERAL_SETTING 
				--		--		WHERE	cmp_ID = @Cmp_Id_C AND Branch_ID = @Branch_ID  AND For_Date = ( SELECT max(For_Date) FROM T0040_GENERAL_SETTING WHERE For_Date <= @TO_DATE AND Branch_ID = @Branch_ID AND Cmp_ID = @Cmp_Id_C)    
				--		--	End

				--		--SELECT	@join_dt=Date_Of_Join,@Left_Date=Emp_Left_Date 
				--		--FROM	T0080_EMP_MASTER 
				--		--WHERE	Cmp_ID=@Cmp_Id_C AND Emp_ID=@Emp_ID
							
				--		--Exec SP_EMP_HOLIDAY_DATE_GET @Emp_ID,@Cmp_Id_C,@TO_DATE,@TO_DATE,null,null,0,@StrHoliday_Date OUTPUT,@Holiday_days OUTPUT,@Cancel_Holiday OUTPUT,0,@Branch_ID,@StrWeekoff_Date
				--		--Exec SP_EMP_WEEKOFF_DATE_GET @Emp_ID,@Cmp_Id_C,@TO_DATE,@TO_DATE,@join_dt,@left_Date,@Is_Cancel_weekoff,@StrHoliday_Date,@StrWeekoff_Date OUTPUT,@WO_Days OUTPUT ,@Cancel_Weekoff OUTPUT    	
					
				--		--IF charindex(CONVERT(VARCHAR(11),@TO_DATE,109),@StrWeekoff_Date,0) > 0
				--		--	BEGIN
				--		--		UPDATE	#PRESENT 
				--		--		SET		STATUS='WO',
				--		--				type='<font color="Green">WO</font>'
				--		--		WHERE EMP_ID = @Emp_ID AND STATUS = 'A'
				--		--	End
					
				--		--IF charindex(CONVERT(VARCHAR(11),@TO_DATE,109),@StrHoliday_Date,0) > 0
				--		--	BEGIN
				--		--		UPDATE	#PRESENT 
				--		--		SET		STATUS='HO',
				--		--				type='<font color="Green">HO</font>'
				--		--		WHERE	EMP_ID = @Emp_ID AND STATUS = 'A'
				--		--	End
					
				--		SET @StrHoliday_Date = ''    
				--		--SET @StrWeekoff_Date = ''  
				--		SET @Dept_Name = ''
				--		SET @Desig_Name = ''
				--		SET @Holiday_days = 0
				--		SET @Cancel_Holiday=0
			  
				--		FETCH NEXT FROM cur INTO @Emp_ID
				--	END
			  
				--CLOSE cur
				--DEALLOCATE cur
				------ End ----

				INSERT	INTO #TMP_ABSENT
				SELECT	DISTINCT P.Cmp_Id,(P.EMP_ID),P.EMP_CODE,P.EMP_FULL_NAME,Desig_Name,Dept_Name,In_time,P.STATUS,P.Branch_name
				FROM	#PRESENT AS p 
				INNER JOIN T0080_EMP_MASTER AS EM WITH (NOLOCK) ON P.EMP_ID = EM.EMP_ID   
				WHERE	EM.EMP_LEFT = 'N'   
				ORDER BY STATUS DESC  
			
				FETCH NEXT FROM curCompany INTO @Cmp_Id_C
			End
	  
	CLOSE curCompany
	DEALLOCATE curCompany

	SELECT * FROM #TMP_ABSENT   
	RETURN  
END




