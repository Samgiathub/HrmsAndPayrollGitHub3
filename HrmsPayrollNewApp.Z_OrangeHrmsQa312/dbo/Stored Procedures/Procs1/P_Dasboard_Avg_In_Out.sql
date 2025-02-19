

CREATE PROCEDURE [dbo].[P_Dasboard_Avg_In_Out]
	@Cmp_ID INT,
	@Emp_ID INT,
	@FROM_DATE DATETIME = null ,
	@TO_DATE DATETIME = null
AS

        SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN
	
	IF ISNULL(@EMP_ID,0) = 0
		RETURN
	
	

	DECLARE @Current_Date AS DateTime
	DECLARE @COUNT AS INT
	SET @COUNT = 0

	Set @Current_Date= CONVERT(DATETIME, CONVERT(CHAR(10), GETDATE(), 103), 103)

	IF @FROM_DATE IS NULL
		BEGIN
			SET @FROM_DATE =  DATEADD(D, -30, @Current_Date)
			SET @TO_DATE =  @Current_Date
		END
		
	CREATE TABLE #Data         
	(         
	   Emp_Id   numeric ,         
	   For_date datetime,        
	   Duration_in_sec numeric,        
	   Shift_ID numeric ,        
	   Shift_Type numeric ,        
	   Emp_OT  numeric ,        
	   Emp_OT_min_Limit numeric,        
	   Emp_OT_max_Limit numeric,        
	   P_days  numeric(12,3) default 0,        
	   OT_Sec  numeric default 0  ,
	   In_Time datetime,
	   Shift_Start_Time datetime,
	   OT_Start_Time numeric default 0,
	   Shift_Change tinyint default 0,
	   Flag int default 0,
	   Weekoff_OT_Sec  numeric default 0,
	   Holiday_OT_Sec  numeric default 0,
	   Chk_By_Superior numeric default 0,
	   IO_Tran_Id	   numeric default 0, -- io_tran_id is used for is_cmp_purpose (t0150_emp_inout)
	   OUT_Time datetime,
	   Shift_End_Time datetime,			--Ankit 16112013
	   OT_End_Time numeric default 0,	--Ankit 16112013
	   Working_Hrs_St_Time tinyint default 0, --Hardik 14/02/2014
	   Working_Hrs_End_Time tinyint default 0, --Hardik 14/02/2014
	   GatePass_Deduct_Days numeric(18,2) default 0 -- Add by Gadriwala Muslim 05012014
	)    


	CREATE table #Emp_Cons 
	(      
		Emp_ID numeric ,     
		Branch_ID numeric,
		Increment_ID numeric    
	)  

	/*Self*/
	INSERT INTO #Emp_Cons (EMP_ID,BRANCH_ID,INCREMENT_ID)
	SELECT	Top 1 EMP_ID,BRANCH_ID,INCREMENT_ID
	FROM	T0095_INCREMENT WITH (NOLOCK)
	WHERE	EMP_ID=@EMP_ID
	ORDER BY Increment_Effective_Date Desc, Increment_ID DESC


	/*Employee's In & Out*/
	EXEC P_GET_EMP_INOUT @CMP_ID, @FROM_DATE, @TO_DATE --, '18166'

	
	IF NOT EXISTS(SELECT 1 from #Data)
		BEGIN
			/*Parameters Passed Month have not any In Out Punch*/
			DECLARE @Date DATE = (SELECT DATEADD(M, DATEDIFF(M, 0, GETDATE()), 0))
 
			WHILE(NOT EXISTS(SELECT 1 from #Data)) AND @COUNT <=12
				BEGIN
					
					 SELECT @FROM_DATE=DATEADD(M, -1, @Date) 
					 SELECT @TO_DATE= DATEADD(D, -1, @Date) 
					 SET @Date=@TO_DATE
					 EXEC P_GET_EMP_INOUT @CMP_ID, @FROM_DATE, @TO_DATE
					
					SET @COUNT = @COUNT + 1
					--PRINT @Date PRINT @FROM_DATE PRINT @TO_DATE
					
					
				END

		END	

															
				--SELECT	DateAdd(s,Avg(DateDiff(s, '1900-01-01', Cast(Convert(Varchar(5),D.In_Time,108) As DateTime))), '1900-01-01') AS AVG_IN,
				--		DateAdd(s,Avg(DateDiff(s, '1900-01-01', Cast(Convert(Varchar(5),D.OUT_Time,108) As DateTime))), '1900-01-01') AS AVG_OUT,
				--		D1.FOR_DATE AS Last_Punch, D1.In_Time as Last_In_Time, D1.Out_Time As Last_Out_Time
				--INTO	#AVG
				--FROM	#Data D
				--		LEFT OUTER JOIN (SELECT	D1.EMP_ID, D1.For_date, D1.IN_TIME, D1.OUT_TIME 
				--						 FROM	#DATA D1 
				--								INNER JOIN (SELECT  EMP_ID , MAX(FOR_DATE) FOR_DATE 
				--											FROM	#DATA  
				--											WHERE	FOR_DATE < @Current_Date
				--											GROUP BY EMP_ID) D2 ON D1.Emp_Id = D2.Emp_Id AND D1.For_date=D2.FOR_DATE
				--						) D1 ON D.EMP_ID=D1.Emp_Id
				--Where	D.In_Time Is not null and D.out_time is not null
				--		AND D.Emp_Id=@EMP_ID
				--GROUP by D1.For_date, D1.In_Time, D1.OUT_Time
				
				SELECT	DateAdd(s,Avg(DateDiff(s, '1900-01-01', Cast(Convert(Varchar(5),D.In_Time,108) As DateTime))), '1900-01-01') AS AVG_IN,
						DateAdd(s,Avg(DateDiff(s, '1900-01-01', Cast(Convert(Varchar(5),D.OUT_Time,108) As DateTime))), '1900-01-01') AS AVG_OUT,
						 D1.FOR_DATE  AS Last_Punch, D1.Last_In as Last_In_Time, D1.Last_Out As Last_Out_Time
				INTO	#AVG
				FROM	#Data D
					LEFT OUTER JOIN (SELECT	D1.EMP_ID, D1.For_date, MAX(ISNULL(D1.IN_TIME,'1900-01-01')) as Last_In, 
																	MAX(ISNULL(D1.OUT_TIME,'1900-01-01')) as Last_Out
									 FROM	#DATA D1 
												INNER JOIN (SELECT  EMP_ID , MAX(FOR_DATE) FOR_DATE 
															FROM	#DATA  
															WHERE	FOR_DATE <= @Current_Date
															GROUP BY EMP_ID
															) D2 ON D1.Emp_Id = D2.Emp_Id AND D1.For_date=D2.FOR_DATE
									  GROUP BY D1.EMP_ID, D1.For_date
									) D1 ON D.EMP_ID=D1.Emp_Id
				WHERE	D.IN_TIME IS NOT NULL AND D.OUT_TIME IS NOT NULL
						AND D.Emp_Id=@EMP_ID
				GROUP by D1.For_date, D1.Last_In, D1.Last_Out

				
    SELECT	AVG_IN, AVG_OUT, AVG_OUT - AVG_IN AS AVG_WORK ,Last_Punch,Last_In_Time,Last_Out_Time
	FROM	#AVG
				
		/* Sample Code Ramiz
		
		SELECT  d.emp_id , @FROM_DATE AS FROM_DATE, @TO_DATE AS TO_DATE, E.ALPHA_EMP_CODE,E.EMP_FULL_NAME,G.GRD_NAME,DM.DEPT_NAME,
			(DATEDIFF(DD ,@FROM_DATE,@TO_DATE) + 1) - (ISNULL(EH.WH_Count,0)) as Total_Working_Days,
			SUM(P_days) as Total_Worked_Days, --((DATEDIFF(DD ,@FROM_DATE,@TO_DATE) + 1) - (ISNULL(EH.WH_Count,0)) - SUM(P_days)) as Total_Absent_Days,
			Convert(varchar(15),Shift_Start_Time,108) as Shift_Start_Time , 
			CONVERT(VARCHAR(15) , CAST(AVG(CAST(CAST(Cast(In_Time as TIME) as DATETIME)as NUMERIC(18,17)))AS DATETIME) , 108) as Average_InTime,
			CONVERT(VARCHAR(15) , CAST(AVG(CAST(CAST(Cast(Out_Time as TIME) as DATETIME)as NUMERIC(18,17)))AS DATETIME) , 108) as Average_OutTime,
			dbo.F_Return_Hours(AVG(Duration_in_sec - @LUNCH_HRS_IN_SEC)) AS Average_Working_Hrs ,dbo.F_Return_Hours(AVG(@LUNCH_HRS_IN_SEC)) AS Lunch_hrs_Deducted
		FROM #DATA D 
		INNER JOIN  T0080_EMP_MASTER E ON D.EMP_ID=E.EMP_ID
		INNER JOIN  #Emp_Cons EC ON EC.EMP_ID = D.EMP_ID
		INNER JOIN  T0095_INCREMENT I ON I.EMP_ID=D.EMP_ID AND I.Increment_ID = EC.Increment_ID
		INNER JOIN  T0040_GRADE_MASTER G ON G.Grd_ID = I.Grd_ID
		LEFT OUTER JOIN  T0040_DEPARTMENT_MASTER DM ON DM.Dept_Id = I.Dept_ID
		LEFT OUTER JOIN  #Emp_Total_WeekOff_Holiday EH ON EH.Emp_ID = D.Emp_Id
		GROUP BY D.EMP_ID , E.ALPHA_EMP_CODE,E.EMP_FULL_NAME,G.GRD_NAME,DM.DEPT_NAME --, Convert(varchar(15),Shift_Start_Time,108)
		,EH.WH_Count
		ORDER BY Alpha_Emp_Code 
		*/
				
	TRUNCATE TABLE #Emp_Cons
	
	/*Downline Employees Team member details*/
	INSERT INTO #Emp_Cons(Emp_ID, Increment_ID, Branch_ID)
	Select	T.emp_id,I.Increment_ID,I.Branch_ID --,E.Reporting_Method,I.Sales_Code,T.Date_Of_Join,I.CTC--Added Date_Of_Join field by Mukti(19122017)	
	FROM	T0080_EMP_MASTER  T WITH (NOLOCK)
			INNER JOIN (
						SELECT	Cmp_ID,Emp_ID,R_Emp_ID,Reporting_Method,MAX(Effect_Date) As Effect_Date 
						FROM	T0090_EMP_REPORTING_DETAIL E WITH (NOLOCK)
						WHERE	Effect_Date<=GetDate() 
						GROUP	BY Cmp_ID,Emp_ID,R_Emp_ID,Reporting_Method
						) E ON E.Emp_ID=T.Emp_ID And E.Cmp_ID=T.Cmp_ID 
			INNER JOIN (
						SELECT	INCREMENT_ID,I.Emp_ID,I.Cmp_ID,I.Branch_ID , I.Sales_Code,I.CTC
						FROM	T0095_INCREMENT I WITH (NOLOCK)
						WHERE	I.Increment_ID = (
													SELECT	TOP 1 I1.Increment_ID
													FROM	T0095_INCREMENT I1 WITH (NOLOCK)
													WHERE	I1.Emp_ID=I.Emp_ID AND I1.Cmp_ID=I.Cmp_ID 
													ORDER	BY I1.Increment_Effective_Date DESC, I1.Increment_ID DESC
													)
						) I ON  T.Emp_ID=I.Emp_ID AND T.Cmp_ID=I.Cmp_ID
	Where	E.Effect_Date=(Select MAX(Effect_Date) FROM T0090_EMP_REPORTING_DETAIL ED WITH (NOLOCK)
							WHERE ED.Emp_ID=E.Emp_ID And Effect_Date<=GetDate())
			and (Emp_Left = 'N' or (Emp_Left = 'Y' and Emp_Left_Date >= @To_Date)) --Mukti(06042017)	
			AND E.R_Emp_ID=@Emp_ID
			AND E.Cmp_ID=@Cmp_ID --OR E.Reporting_Method='InDirect') --commented by Mukti(19122017)


	
	DECLARE @Member_Present INT
	
	SELECT	Emp_ID, 'P' As EStatus
	INTO	#Emp_Status
	FROM	#Emp_Cons EC
	WHERE	EXISTS(SELECT 1 FROM T0150_EMP_INOUT_RECORD T WITH (NOLOCK) WHERE @Current_Date = T.For_Date AND EC.EMP_ID=T.Emp_ID)	
	

	INSERT INTO #Emp_Status
	SELECT	Emp_ID, 'L' As EStatus	
	FROM	#Emp_Cons EC
	WHERE	(EXISTS(SELECT 1 FROM T0100_LEAVE_APPLICATION LA WITH (NOLOCK) INNER JOIN T0110_LEAVE_APPLICATION_DETAIL LAD WITH (NOLOCK) ON LA.Leave_Application_ID=lad.Leave_Application_ID WHERE @Current_Date BETWEEN LAD.From_Date AND LAD.To_Date AND EC.Emp_ID=LA.Emp_ID)
			OR 
			EXISTS(SELECT 1 FROM T0120_LEAVE_APPROVAL LA WITH (NOLOCK) INNER JOIN T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) ON LA.Leave_Approval_ID=lad.Leave_Approval_ID WHERE @Current_Date BETWEEN LAD.From_Date AND LAD.To_Date AND EC.Emp_ID=LA.Emp_ID)
			)
			AND NOT EXISTS(SELECT 1 FROM #EMP_STATUS  ES  WHERE EC.EMP_ID=ES.EMP_ID)
		
	INSERT INTO #Emp_Status
	SELECT	Emp_ID, 'S' As EStatus		
	FROM	#Emp_Cons EC			
	WHERE	EXISTS (SELECT 1 FROM T0040_SHIFT_MASTER ES WITH (NOLOCK) WHERE ES.SHIFT_ID=dbo.fn_get_Shift_From_Monthly_Rotation(@Cmp_ID,EC.Emp_ID, @Current_Date) AND Shift_St_Time > CONVERT(VARCHAR(5), DATEADD(HH,1,GETDATE()), 108))
			AND NOT EXISTS(SELECT 1 FROM #EMP_STATUS  ES  WHERE EC.EMP_ID=ES.EMP_ID)

	INSERT INTO #Emp_Status
	SELECT	Emp_ID, 'A' As EStatus		
	FROM	#Emp_Cons EC
	WHERE	NOT EXISTS (SELECT 1 FROM #Emp_Status TEC where EC.Emp_ID =TEC.Emp_ID)
	
	--CREATE table #Emp_Final_Data 
	--(      
	--	Present numeric ,     
	--	Leave numeric,
	--	Shift numeric,
	--	Absent   numeric,
	--	Total NUMERIC  
	--) 
	
	--INSERT INTO #Emp_Final_Data (Present,Leave,Shift,Absent,Total)
	--SELECT	SUM(CASE WHEN EStatus = 'P' Then 1 Else 0 END) ,
	--		SUM(CASE WHEN EStatus = 'L' Then 1 Else 0 END),
	--		SUM(CASE WHEN EStatus = 'S' Then 1 Else 0 END) ,
	--		SUM(CASE WHEN EStatus = 'A' Then 1 Else 0 END),
	--		 (SUM(Val1) + SUM(Val2) + SUM(Val3))
	--FROM	#Emp_Status

	
	SELECT	isnull(SUM(CASE WHEN EStatus = 'P' Then 1 Else 0 END),0) As Present,
			isnull(SUM(CASE WHEN EStatus = 'L' Then 1 Else 0 END),0) As Leave,
			isnull(SUM(CASE WHEN EStatus = 'S' Then 1 Else 0 END),0) As Shift,
			isnull(SUM(CASE WHEN EStatus = 'A' Then 1 Else 0 END),0) As Absent,
			isnull((SUM(CASE WHEN EStatus = 'P' Then 1 Else 0 END) + SUM(CASE WHEN EStatus = 'L' Then 1 Else 0 END) + SUM(CASE WHEN EStatus = 'S' Then 1 Else 0 END) + SUM(CASE WHEN EStatus = 'A' Then 1 Else 0 END)),0) as TotalMemmbers
	FROM	#Emp_Status
	
	
	
END


