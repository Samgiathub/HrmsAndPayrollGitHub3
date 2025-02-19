CREATE PROCEDURE [dbo].[SP_RPT_EMP_INOUT_RECORD_GET_CONSOLIDATED_SHIFT_WISE] 
 @Cmp_ID   numeric,      
 @From_Date  datetime,      
 @To_Date  datetime ,      
 @Branch_ID  numeric   ,      
 @Cat_ID   numeric  ,      
 @Grd_ID   numeric ,      
 @Type_ID  numeric ,      
 @Dept_ID  numeric  ,      
 @Desig_ID  numeric ,      
 @Emp_ID   numeric  ,      
 @Constraint  varchar(MAX) = '',      
 @Report_call varchar(20) = 'IN-OUT',      
 @Weekoff_Entry varchar(1) = 'Y',  
 @PBranch_ID varchar(200) = '0',
 @Order_By	varchar(30) = 'Code', --Added by Nimesh 14-Jul-2015 (To sort by Code/Name/Enroll No)   
 @Format int = 2 --Added by Mukti(01032017)   
AS      
  	    SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON	
       
    IF DATEDIFF(d,@From_Date,@To_Date)>31  --Mukti(16032017)
		BEGIN
			set @to_date=DATEADD(d,-1,DATEADD(MM,1,@from_date))				
		END	
				
	--PRINT converT(varchar(20), getdate(), 114) + ' STEP 0'
	CREATE TABLE #ATT_CONS
	(	
		CMP_ID		NUMERIC,
		EMP_ID		NUMERIC , 		
		ROW_ID		NUMERIC ,
		EMP_CODE    VARCHAR(50) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,
		EMP_FULL_NAME  VARCHAR(300) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,
		BRANCH_NAME VARCHAR(200) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,
		DEPT_NAME  VARCHAR(200) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,
		GRD_NAME VARCHAR(200) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,
		DESIG_NAME VARCHAR(200) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,

		FOR_DATE	DATETIME,
		[STATUS]	VARCHAR(20) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,
		P_DAYS		NUMERIC(5,2) DEFAULT 0,
		A_DAYS		NUMERIC(5,2) DEFAULT 0 ,
		LEAVE_COUNT	NUMERIC(5,2),		
		WO_HO_DAY	NUMERIC(3,2) DEFAULT 0,		
		LATE_DEDUCT_DAYS NUMERIC(18,2) DEFAULT 0,
		EARLY_DEDUCT_DAYS NUMERIC(18,2) DEFAULT 0,		
		P_FROM_DATE  DATETIME,
		P_TO_DATE	DATETIME,
		BRANCH_ID	NUMERIC(18,0),
		DESIG_DIS_NO NUMERIC(18,2) DEFAULT 0,
		SHIFT_ID	NUMERIC(5,0),
	)
	 
	CREATE TABLE #Emp_Cons 
	(      
		Emp_ID numeric ,     
		Branch_ID numeric,
		Increment_ID numeric    
	);
	CREATE NONCLUSTERED INDEX IX_Emp_Cons_EmpID ON #Emp_Cons (Emp_ID);

	EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,0 ,0 ,0,0,0,0,0,0,0,0,0,0
	  
	IF (OBJECT_ID('tempdb..#Rotation') IS NULL)
		Create Table #Rotation (R_EmpID numeric(18,0), R_DayName varchar(25), R_ShiftID numeric(18,0), R_Effective_Date DateTime);

	EXEC SP_RPT_EMP_ATTENDANCE_MUSTER_GET @CMP_ID,@FROM_DATE,@TO_DATE,@BRANCH_ID,
										  @CAT_ID,@GRD_ID,@TYPE_ID,@DEPT_ID,@DESIG_ID,
										  @EMP_ID,@CONSTRAINT,'Consolidated',''
	
	
		
	CREATE TABLE #CONSOLIDATED
	(	
		SR_NO				NUMERIC,
		EMP_ID				NUMERIC , 		
		ROW_ID				NUMERIC ,
		Emp_Code			VARCHAR(50) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,
		Emp_Name			VARCHAR(300) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,
		Branch				VARCHAR(200) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,
		Grade				VARCHAR(200) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,
		Designation			VARCHAR(200) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,
		Department			VARCHAR(200) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,		
		[Type_Name]			VARCHAR(64) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,		
		Shift_Name			VARCHAR(64) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,		
		SHIFT_ID			NUMERIC(5,0),		
		Segment_Name		VARCHAR(64) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,		
		Vertical_Name		VARCHAR(64) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,		
		SubVertical_Name	VARCHAR(64) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,		
		SubBranch_Name		VARCHAR(64) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,		

		FOR_DATE	DATETIME,
		[STATUS]	VARCHAR(20) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,
		P_DAYS		NUMERIC(5,2) DEFAULT 0,
		A_DAYS		NUMERIC(5,2) DEFAULT 0,
		WEEKOFF		NUMERIC(5,2) DEFAULT 0,
		HOLIDAY		NUMERIC(5,2) DEFAULT 0,
		LEAVE_COUNT	NUMERIC(5,2),		
		WO_HO_DAY	NUMERIC(3,2) DEFAULT 0,		
		LATE_DEDUCT_DAYS NUMERIC(18,2) DEFAULT 0,
		EARLY_DEDUCT_DAYS NUMERIC(18,2) DEFAULT 0,		
		P_FROM_DATE  DATETIME,
		P_TO_DATE DATETIME,
		BRANCH_ID NUMERIC(18,0),
		DESIG_DIS_NO NUMERIC(18,2) DEFAULT 0,
		--Added By Mukti(02032017)start
		Gender varchar(10),
		Father_Name varchar(250),
		Date_Of_Join DATETIME,
		Date_Of_Birth DATETIME,
		Worker_Adult_No VARCHAR(50)							
		--Added By Mukti(02032017)end
	)
	
	CREATE TABLE #LATE_MARK
	(
		EMP_ID				NUMERIC,
		FOR_DATE			DATETIME,
		IN_TIME				DATETIME,
		OUT_TIME			DATETIME,
		REASON				VARCHAR(300),
		SHIFT_START_TIME	DATETIME,
		SHIFT_END_TIME		DATETIME,
		SHIFT_DUR			NUMERIC(9),
		F_BREAK_DUR			NUMERIC(9),
		S_BREAK_DUR			NUMERIC(9),
		T_BREAK_DUR			NUMERIC(9),
		EARLY_IN			NUMERIC(9),
		LATE_IN				NUMERIC(9),
		EARLY_OUT			NUMERIC(9),
		LATE_OUT			NUMERIC(9),
		WORK_DUR			NUMERIC(9),
		OT_Start			DATETIME,
		OT_END				DATETIME,
		IS_HALF_DAY			BIT,
		LATE_LIMIT			NUMERIC(9)
	)
		
	
	--Getting Shift from Shift Change Detail (Default Shift)
	UPDATE	#ATT_CONS SET SHIFT_ID = SH.Shift_ID
	FROM	#ATT_CONS D,
			(	
				SELECT	SD.Emp_ID,SD.Shift_ID, D.For_date,SD.Shift_Type
				FROM	T0100_EMP_SHIFT_DETAIL SD WITH (NOLOCK) INNER JOIN #ATT_CONS D ON SD.Emp_ID=D.Emp_Id
				WHERE	SD.Emp_ID=D.EMP_ID AND SD.Cmp_ID=@CMP_ID
						AND SD.For_Date =	(Select	Max(For_Date)
											FROM	T0100_EMP_SHIFT_DETAIL SD1 WITH (NOLOCK)
											WHERE	SD1.Emp_ID	=SD.Emp_ID AND SD1.Cmp_ID=SD.Cmp_ID	AND SD1.For_Date <= D.For_date	AND ISNULL(Shift_Type,0) <> 1												
											)
			) As SH
	WHERE	SH.For_date	= D.For_date AND SH.Emp_ID=D.Emp_ID AND D.SHIFT_ID IS NULL
		
	--Getting Shift from Monthly Shift Rotation Detail Detail 
	UPDATE	#ATT_CONS 
	SET		SHIFT_ID=SM.SHIFT_ID
	FROM	#ATT_CONS D INNER JOIN #Rotation R ON R.R_DayName = 'Day' + CAST(DATEPART(d, D.For_date) As Varchar)
					AND D.Emp_Id=R.R_EmpID
			INNER JOIN T0040_SHIFT_MASTER SM ON R.R_ShiftID	=SM.Shift_ID 
	WHERE	R.R_Effective_Date = (
									SELECT	MAX(R_Effective_Date)
									FROM	#Rotation R1 
									WHERE	R1.R_EmpID=Emp_Id AND R1.R_Effective_Date<=D.FOR_DATE
								) 
			AND NOT EXISTS(Select 1 from T0040_SHIFT_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Inc_Auto_Shift=1 AND D.Shift_ID=D.Shift_ID)
			AND SM.Cmp_ID=@Cmp_ID	 AND D.SHIFT_ID IS NULL
		
		
	--Getting Shift from Shift Change Detail (Temporary)
	UPDATE	#ATT_CONS SET SHIFT_ID = SH.Shift_ID
	FROM	#ATT_CONS D,
			(	
				SELECT	SD.Emp_ID,SD.Shift_ID, D.For_date,SD.Shift_Type
				FROM	T0100_EMP_SHIFT_DETAIL SD WITH (NOLOCK) INNER JOIN #ATT_CONS D ON SD.Emp_ID=D.Emp_Id
				WHERE	SD.Emp_ID=D.EMP_ID AND SD.Cmp_ID=@CMP_ID
						AND SD.For_Date =	(Select	Max(For_Date)
											FROM	T0100_EMP_SHIFT_DETAIL SD1 WITH (NOLOCK)
											WHERE	SD1.Emp_ID	=SD.Emp_ID AND SD1.Cmp_ID=SD.Cmp_ID	AND SD1.For_Date = D.For_date	
													AND SD1.Shift_Type=1														
											)
						AND NOT EXISTS (
											SELECT 1 FROM #Rotation R
											WHERE	SD.Emp_ID=R.R_EmpID AND R.R_DayName = 'Day' + CAST(DATEPART(d, D.For_date) As Varchar)
													AND R.R_Effective_Date = (
																			SELECT	MAX(R_Effective_Date)
																			FROM	#Rotation R1 
																			WHERE	R1.R_EmpID=D.Emp_Id AND R1.R_Effective_Date<=D.FOR_DATE
																		) 
										)													
			) As SH
	WHERE	SH.For_date	= D.For_date AND SH.Emp_ID=D.Emp_ID  AND D.SHIFT_ID IS NULL
		
	--Getting Shift from Shift Change Detail (Regular)
	UPDATE	#ATT_CONS SET SHIFT_ID = SH.Shift_ID
	FROM	#ATT_CONS D,
			(	
				SELECT	SD.Emp_ID,SD.Shift_ID, D.For_date,SD.Shift_Type
				FROM	T0100_EMP_SHIFT_DETAIL SD WITH (NOLOCK) INNER JOIN #ATT_CONS D ON SD.Emp_ID=D.Emp_Id
				WHERE	SD.Emp_ID=D.EMP_ID AND SD.Cmp_ID=@CMP_ID
						AND SD.For_Date =	(
												Select	Max(For_Date)
												FROM	T0100_EMP_SHIFT_DETAIL SD1 WITH (NOLOCK)
												WHERE	SD1.Emp_ID	=SD.Emp_ID AND SD1.Cmp_ID=SD.Cmp_ID	AND SD1.For_Date = D.For_date	
											)
						AND EXISTS (
										SELECT 1 FROM #Rotation R
										WHERE	SD.Emp_ID=R.R_EmpID AND R.R_DayName = 'Day' + CAST(DATEPART(d, D.For_date) As Varchar(5)) 
												AND R.R_Effective_Date = (
																			SELECT	MAX(R_Effective_Date)
																			FROM	#Rotation R1 
																			WHERE	R1.R_EmpID=D.Emp_Id AND R1.R_Effective_Date<=D.FOR_DATE
																		) 
									)													
			) As SH
	WHERE	SH.For_date	= D.For_date AND SH.Emp_ID=D.Emp_ID  AND D.SHIFT_ID IS NULL
	----PRINT 'CALC 5 :' + CONVERT(VARCHAR(20), GETDATE(), 114);

	
	UPDATE AC
	SET		SHIFT_ID = T.SHIFT_ID
	FROM	#ATT_CONS AC 
			INNER JOIN (SELECT	T.EMP_ID, T.SHIFT_ID
						FROM	#ATT_CONS T
								INNER JOIN (SELECT EMP_ID, MIN(FOR_DATE) AS FOR_DATE
											FROM	#ATT_CONS T1 
											WHERE	T1.SHIFT_ID IS NOT NULL
											GROUP BY T1.EMP_ID) T1 ON T.EMP_ID=T1.EMP_ID AND T.FOR_DATE=T1.FOR_DATE
						) T ON AC.EMP_ID=T.EMP_ID
	WHERE	AC.SHIFT_ID IS NULL

	
	
	INSERT INTO #LATE_MARK(EMP_ID,FOR_DATE, IN_TIME,OUT_TIME, SHIFT_START_TIME, SHIFT_END_TIME, SHIFT_DUR, F_BREAK_DUR, S_BREAK_DUR, T_BREAK_DUR, LATE_LIMIT)
	SELECT	e.Emp_ID,e.For_Date,MIN(In_time) AS IN_TIME, (CASE WHEN Max_In > MAX(Out_Time) THEN Max_In ELSE MAX(Out_time) END) AS OUT_TIME,
			SM.Shift_St_Time + e.For_Date, SM.Shift_End_Time + e.For_Date, SM.Shift_Dur, F_Duration, S_Duration, T_Duration, dbo.F_Return_Sec(Late_Limit) AS Late_Limit
	FROM	dbo.T0150_emp_inout_record e 
			INNER JOIN (
						SELECT	MAX(In_time) Max_In,Emp_Id,For_Date 
						FROM	dbo.T0150_emp_inout_record WITH (NOLOCK)
						--WHERE	Emp_ID =@Emp_ID  AND For_Date = @Temp_Month_Date 
						GROUP BY Emp_ID,For_Date
						) M ON e.Emp_ID = M.Emp_ID AND E.For_Date = M.For_Date		
			INNER JOIN  #ATT_CONS A ON E.EMP_ID=A.EMP_ID AND A.FOR_DATE=E.For_Date
			INNER JOIN	(SELECT	SHIFT_ID, Shift_St_Time, Shift_End_Time, Half_St_Time, Half_End_Time,  dbo.F_Return_Sec(Shift_Dur) AS Shift_Dur,
								dbo.F_Return_Sec(Half_Dur) AS Half_Dur, Is_Half_Day, dbo.F_Return_Sec(F_Duration) AS F_Duration, 
								(CASE WHEN SM.DeduHour_SecondBreak = 1 THEN dbo.F_Return_Sec(SM.S_Duration) ELSE 0 END) AS S_Duration,
								(CASE WHEN SM.DeduHour_ThirdBreak = 1 THEN dbo.F_Return_Sec(SM.T_Duration) ELSE 0 END) AS T_Duration
						FROM	T0040_SHIFT_MASTER SM WITH (NOLOCK)
						) SM ON A.SHIFT_ID=SM.Shift_ID
			INNER JOIN T0040_GENERAL_SETTING G WITH (NOLOCK) ON A.BRANCH_ID=G.Branch_ID
			INNER JOIN (SELECT	MAX(FOR_DATE) FOR_DATE, BRANCH_ID 
						FROM	T0040_GENERAL_SETTING G1 WITH (NOLOCK)
						WHERE	G1.For_Date <= @TO_DATE AND Cmp_ID = @Cmp_ID
						GROUP BY Branch_ID) G1 ON G.For_Date=G1.FOR_DATE AND G.Branch_ID=G1.Branch_ID									
	GROUP BY e.Emp_ID,e.For_Date,Reason,Max_In,SM.Shift_St_Time, SM.Shift_End_Time, SM.Shift_Dur, F_Duration, S_Duration, T_Duration, Late_Limit
	ORDER BY e.Emp_ID,e.For_Date

	--PRINT converT(varchar(20), getdate(), 114) + ' STEP 2'
	--UPDATE	LT
	--SET		EARLY_IN = DATEDIFF(s, IN_TIME,SHIFT_START_TIME)
	--FROM	#LATE_MARK LT
	--WHERE	IN_TIME < SHIFT_START_TIME

	UPDATE	LT
	SET		LATE_IN = DATEDIFF(s, SHIFT_START_TIME, IN_TIME)
	FROM	#LATE_MARK LT
	WHERE	IN_TIME > SHIFT_START_TIME AND DATEDIFF(s, SHIFT_START_TIME, IN_TIME) > LATE_LIMIT

	--- Uncomment Below code for Emerland Honda, It's specific changes for client, By Hardik 21/07/2020
	
		---- Added by Hardik for Emerland Honda
		--Create Table #Late_Early_Deduction
		--	(
		--		Emp_ID numeric(18,0),
		--		For_Date datetime,
		--		Late_Deduct_Days numeric(18,2),
		--		Early_Deduct_Days numeric(18,2),
		--		Late_Sec numeric,
		--		Early_Sec numeric
		--	 )

		--exec rpt_Late_Early_Mark_Combine_Deduction @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,1

		--UPDATE #LATE_MARK SET LATE_IN = NULL, EARLY_OUT=NULL  
	
		--UPDATE L SET LATE_IN = LED.Late_Sec, EARLY_OUT = LED.Early_Sec 
		--FROM #LATE_MARK L INNER JOIN #Late_Early_Deduction LED ON L.EMP_ID = LED.Emp_ID AND L.FOR_DATE=LED.For_Date

		--UPDATE Att SET STATUS = CASE WHEN Late_Sec > 0 THEN 'PL' WHEN Early_Sec >0 THEN 'PE' ELSE STATUS END -- Added by Hardik for Emerland Honda
		--FROM #ATT_CONS ATT INNER JOIN #Late_Early_Deduction LED ON ATT.EMP_ID = LED.Emp_ID AND ATT.FOR_DATE = LED.For_Date
		--WHERE  ATT.Status <> 'A' and LED.Late_Deduct_Days = 0 and LED.Early_Deduct_Days=0 

		--UPDATE Att SET STATUS = 'P2' -- Added by Hardik for Emerland Honda
		--FROM #ATT_CONS ATT INNER JOIN #Late_Early_Deduction LED ON ATT.EMP_ID = LED.Emp_ID AND ATT.FOR_DATE = LED.For_Date
		--WHERE  ATT.Status <> 'A' and (LED.Late_Deduct_Days>0 OR LED.Early_Deduct_Days>0) And P_days<>0.5 

		--UPDATE Att SET STATUS = 'P2' -- Added by Hardik for Emerland Honda
		--FROM #ATT_CONS ATT 
		--WHERE  ATT.Status = 'HF'

	----End Code for Emerland Honda


	INSERT INTO #ATT_CONS(CMP_ID, EMP_ID,FOR_DATE,[STATUS],SHIFT_ID)
	SELECT	@CMP_ID, EMP_ID, FOR_DATE, (CASE WHEN Late_in > 0 THEN dbo.F_Return_Hours(Late_in) ELSE NULL END) As Late_Hours, 9999 AS SHIFT_ID
	FROM	#LATE_MARK
	


	CREATE TABLE #EMP_DATES
	(
		ROW_ID		NUMERIC,
		EMP_ID		NUMERIC,
		SHIFT_ID	NUMERIC
	)
	
	CREATE TABLE #SHIFT_DETAIL
	(
		SHIFT_ID NUMERIC,
		SHIFT_NAME VARCHAR(128)
	)

	CREATE TABLE #LEAVE_DETAILS --Mukti(10032017)
	(
		EMP_ID		NUMERIC,
		LEAVE_CODE	VARCHAR(25),
		LEAVE_PERIOD NUMERIC(18,2),
		Leave_ID NUMERIC(18,0)
	)
	
	INSERT INTO #SHIFT_DETAIL 
	SELECT SHIFT_ID, SHIFT_NAME FROM T0040_SHIFT_MASTER WITH (NOLOCK)
	UNION ALL
	SELECT	9999, 'Late Hours'
	
	----Added by Mukti(10032017)start
	INSERT INTO #LEAVE_DETAILS
	SELECT	LT.Emp_ID,LM.Leave_Code,ISNULL(SUM(CASE WHEN LM.Default_Short_Name = 'COMP' THEN LT.COMPOFF_USED ELSE LT.LEAVE_USED * (case when LM.Apply_Hourly = 0 Then 1 Else 0.125 end) END),0) AS LEAVEDAYS,LM.Leave_ID
	FROM	T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)
		inner join T0040_LEAVE_MASTER LM WITH (NOLOCK) on lt.Leave_ID=lm.Leave_ID
		inner JOIN	#Emp_Cons E ON LT.EMP_ID=E.Emp_ID
	WHERE LT.Cmp_Id=@Cmp_ID AND (LT.FOR_DATE BETWEEN @FROM_DATE AND @TO_DATE)
		AND (LT.LEAVE_USED <> 0 OR LT.COMPOFF_USED <> 0) 
	GROUP BY  LT.EMP_ID,Leave_Code,LM.Leave_ID
	----Added by Mukti(10032017)end
	

	--select * from #ATT_CONS
	INSERT	INTO #CONSOLIDATED (SR_NO,EMP_ID,ROW_ID,Emp_Code,Emp_Name,Branch,Grade,Designation,Department,[Type_Name],Shift_Name,SHIFT_ID,Segment_Name,Vertical_Name,SubVertical_Name,SubBranch_Name,P_FROM_DATE,P_TO_DATE,BRANCH_ID,DESIG_DIS_NO,LEAVE_COUNT,LATE_DEDUCT_DAYS,Gender,Father_Name,Date_Of_Join,Date_Of_Birth,Worker_Adult_No)
	SELECT	0 SR_NO,A.EMP_ID,0,A1.Emp_Code,A1.EMP_FULL_NAME,A1.BRANCH_NAME,A1.GRD_NAME,A1.DESIG_NAME,A1.DEPT_NAME,T.TYPE_NAME,S.Shift_Name,A.SHIFT_ID,BS.Segment_Name,V.Vertical_Name,SV.SubVertical_Name,SB.SubBranch_Name,
			A1.P_FROM_DATE,A1.P_TO_DATE,A.BRANCH_ID,A1.DESIG_DIS_NO, (CASE WHEN A1.EMP_CODE IS NULL THEN 0 ELSE A3.LEAVE_COUNT END), (CASE WHEN A1.EMP_CODE IS NULL THEN 0 ELSE A3.LATE_DEDUCT_DAYS END),
			(case when em.Gender='M' then 'Male' else 'Female' END),em.Father_name,em.Date_Of_Join,em.Date_Of_Birth,em.Worker_Adult_No
	FROM	#ATT_CONS A 			
			LEFT OUTER JOIN #SHIFT_DETAIL S ON A.SHIFT_ID=S.Shift_ID
			LEFT OUTER JOIN (
								SELECT	A1.EMP_ID,A1.EMP_CODE,A1.EMP_FULL_NAME,A1.BRANCH_NAME,A1.GRD_NAME,A1.DESIG_NAME,A1.DEPT_NAME,A1.P_FROM_DATE,A1.P_TO_DATE,A1.DESIG_DIS_NO,SUM(A1.LEAVE_COUNT) AS LEAVE_COUNT, A1.SHIFT_ID
								FROM	#ATT_CONS A1 
										INNER JOIN (SELECT MIN(SHIFT_ID) AS SHIFT_ID, EMP_ID FROM #ATT_CONS A2 GROUP BY EMP_ID) A2 ON A1.EMP_ID=A2.EMP_ID AND A1.SHIFT_ID=A2.SHIFT_ID
								GROUP BY A1.EMP_ID,A1.EMP_CODE,A1.EMP_FULL_NAME,A1.BRANCH_NAME,A1.GRD_NAME,A1.DESIG_NAME,A1.DEPT_NAME,A1.P_FROM_DATE,A1.P_TO_DATE,A1.DESIG_DIS_NO, A1.SHIFT_ID
							) A1 ON A.EMP_ID=A1.EMP_ID AND A.SHIFT_ID=A1.SHIFT_ID			
			LEFT OUTER JOIN	#Emp_Cons E ON A1.EMP_ID=E.Emp_ID
			LEFT OUTER JOIN	T0095_INCREMENT I WITH (NOLOCK) ON E.Increment_ID=I.Increment_ID
			LEFT OUTER JOIN	T0040_TYPE_MASTER T WITH (NOLOCK) ON I.[Type_ID]=T.[Type_ID]
			LEFT OUTER JOIN T0040_Business_Segment BS WITH (NOLOCK) ON I.Segment_ID=BS.Segment_ID 
			LEFT OUTER JOIN T0040_Vertical_Segment V WITH (NOLOCK) ON I.Vertical_ID=V.Vertical_ID
			LEFT OUTER JOIN T0050_SubVertical SV WITH (NOLOCK) ON I.SubVertical_ID=SV.SubVertical_ID
			LEFT OUTER JOIN T0050_SubBranch SB WITH (NOLOCK) ON I.subBranch_ID=SB.SubBranch_ID
			LEFT OUTER JOIN (SELECT A3.EMP_ID, 
									SUM(LEAVE_COUNT) AS LEAVE_COUNT, SUM(A3.LATE_DEDUCT_DAYS) AS LATE_DEDUCT_DAYS 
							 FROM	#ATT_CONS A3 									
							 WHERE	SHIFT_ID <> 9999 and A3.[STATUS]not in('LWP') 									
							 GROUP BY A3.EMP_ID) A3 ON A1.EMP_ID=A3.EMP_ID

			inner join T0080_EMP_MASTER em WITH (NOLOCK) on em.Emp_ID=a.EMP_ID   --Mukti(01032017)	
	GROUP BY A.EMP_ID,A1.Emp_Code,A1.EMP_FULL_NAME,A1.BRANCH_NAME,A1.GRD_NAME,A1.DESIG_NAME,A1.DEPT_NAME,T.TYPE_NAME,S.Shift_Name,A.SHIFT_ID,BS.Segment_Name,V.Vertical_Name,SV.SubVertical_Name,SB.SubBranch_Name,
			A1.P_FROM_DATE,A1.P_TO_DATE,A.BRANCH_ID,A1.DESIG_DIS_NO,A3.LEAVE_COUNT,A3.LATE_DEDUCT_DAYS,Gender,Father_Name,Date_Of_Join,Date_Of_Birth,Worker_Adult_No
		
	
	
	UPDATE	C
	SET		SR_NO = T.SR_NO
	FROM	#CONSOLIDATED C 
			INNER JOIN (SELECT ROW_NUMBER() OVER (ORDER BY ORDER_COLUMN) AS SR_NO, EMP_ID
			 FROM	(SELECT EMP_ID, (CASE @Order_By WHEN 'NAME' THEN Emp_Name WHEN 'DESIGNATION' THEN RIGHT(REPLICATE('0',21)+ CAST(DESIG_DIS_NO AS VARCHAR(21)),21) ELSE EMP_CODE	END) AS ORDER_COLUMN
					 FROM #CONSOLIDATED C1 WHERE EMP_CODE IS NOT NULL
					)  T
			) T ON C.EMP_ID=T.EMP_ID
	--UPDATE	C
	--SET		SR_NO = T.SR_NO
	--FROM	#CONSOLIDATED C 
	--		INNER JOIN (SELECT ROW_NUMBER() OVER (ORDER BY ORDER_COLUMN) AS SR_NO, EMP_ID
	--		 FROM	(SELECT EMP_ID, (CASE @Order_By WHEN 'NAME' THEN Emp_Name WHEN 'DESIGNATION' THEN DESIG_DIS_NO ELSE EMP_CODE	END) AS ORDER_COLUMN
	--				 FROM #CONSOLIDATED C1 WHERE EMP_CODE IS NOT NULL
	--				)  T
	--		) T ON C.EMP_ID=T.EMP_ID
	--WHERE	C.EMP_CODE IS NOT NULL

	
	--PRINT converT(varchar(20), getdate(), 114) + ' STEP 3'
		

	INSERT INTO #EMP_DATES (ROW_ID, EMP_ID, SHIFT_ID)
	SELECT ROW_NUMBER() OVER(PARTITION BY EMP_ID ORDER BY EMP_ID, SHIFT_ID) AS ROW_ID, EMP_ID, SHIFT_ID FROM #CONSOLIDATED 
	--UNION ALL
	--SELECT DISTINCT EMP_ID, 9999 AS SHIFT_ID FROM #CONSOLIDATED 
	DECLARE @EXISTS_COLS VARCHAR(MAX);
	set @EXISTS_COLS = ','
	DECLARE @TEMP_DATE DATETIME
	DECLARE @QUERY VARCHAR(MAX)	
	DECLARE @UPDATE_TEMPLATE NVARCHAR(1000)
	DECLARE @COL_NAME VARCHAR(32)
	DECLARE @STR_DATE VARCHAR(20)
	SET	@TEMP_DATE  = @FROM_DATE
	SET @QUERY = '';
	
	WHILE (@TEMP_DATE  <= @TO_DATE)
		BEGIN
			if @Format=5 ---Mukti(02032017)
				BEGIN				
					SET @COL_NAME = CAST(DAY(@TEMP_DATE) AS VARCHAR(10)) --+  '_' + LEFT(DATENAME(WEEKDAY, @TEMP_DATE), 3)
				END
			ELSE
				BEGIN
					SET @COL_NAME = CAST(DAY(@TEMP_DATE) AS VARCHAR(10)) +  '_' + LEFT(DATENAME(WEEKDAY, @TEMP_DATE), 3)
				END
			SET @UPDATE_TEMPLATE =	'UPDATE E SET [' + @COL_NAME + ']=A.STATUS
			    						FROM	#EMP_DATES E
												INNER JOIN #ATT_CONS A ON E.EMP_ID=A.EMP_ID AND E.SHIFT_ID=A.SHIFT_ID
										WHERE	A.FOR_DATE =@TEMP_DATE'
			
			IF CHARINDEX(',' + @COL_NAME + ',', @EXISTS_COLS) = 0
				BEGIN 
					SET @QUERY = 'ALTER TABLE  #EMP_DATES ADD [' + @COL_NAME + '] VARCHAR(10) NULL; '
					EXEC (@QUERY)
				END
			
			SET @EXISTS_COLS = @EXISTS_COLS +@COL_NAME  + ','
			
			SET @STR_DATE =  CAST(@TEMP_DATE AS VARCHAR(20))	
			--SET @UPDATE_TEMPLATE =N'SELECT ''' +  @UPDATE_TEMPLATE + ''''			
			EXEC sp_executesql @UPDATE_TEMPLATE, N'@TEMP_DATE DATETIME', @TEMP_DATE
			--EXEC sp_executesql N'select E.*,A.STATUS,@COL_NAME FROM	#EMP_DATES E  INNER JOIN #ATT_CONS A ON E.EMP_ID=A.EMP_ID AND E.SHIFT_ID=A.SHIFT_ID WHERE	A.FOR_DATE =@TEMP_DATE', N'@COL_NAME VARCHAR(32), @TEMP_DATE DATETIME', @COL_NAME, @TEMP_DATE 
			--EXEC sp_executesql N'SELECT @COL_NAME; SELECT @TEMP_DATE', N'@COL_NAME AS VARCHAR(32),@TEMP_DATE AS DATETIME ', @COL_NAME=@COL_NAME, @TEMP_DATE=@TEMP_DATE

			SET @TEMP_DATE  = DATEADD(d, 1, @TEMP_DATE );
		END	
			
		
		if @Format=5 ---Mukti(02032017)
			BEGIN				
				SET @QUERY = 'ALTER TABLE  #EMP_DATES ADD [P_DAYS] NUMERIC(6,2) NULL,[PAID_LEAVE] NUMERIC(6,2) NULL,[UNPAID_LEAVE] NUMERIC(6,2) NULL, [A_DAYS] NUMERIC(6,2) NULL,[Holiday] NUMERIC(6,2) NULL,[WeekOff] NUMERIC(6,2) NULL; '
				EXEC (@QUERY)
			END
		ELSE
			BEGIN				
				SET @QUERY = 'ALTER TABLE  #EMP_DATES ADD [P_DAYS] NUMERIC(6,2) NULL, [A_DAYS] NUMERIC(6,2) NULL, [WeekOff] NUMERIC(6,2) NULL, [Holiday] NUMERIC(6,2) NULL; '
				EXEC (@QUERY)
			END

		
		---SELECT * FROM #ATT_CONS WHERE SHIFT_ID <> 9999
		UPDATE	E	
		SET		P_DAYS = TOTAL_P_DAYS,
				A_DAYS = TOTAL_A_DAYS,
				WEEKOFF = TOTAL_WEEKOFF,
				HOLIDAY = TOTAL_HOLIDAY
				--TOTAL_DAYS = ISNULL(TOTAL_P_DAYS,0) + ISNULL(TOTAL_WEEKOFF,0) + ISNULL(TOTAL_HOLIDAY,0),
				--PAYABLE_DAYS = (ISNULL(TOTAL_P_DAYS,0) + ISNULL(TOTAL_WEEKOFF,0) + ISNULL(TOTAL_HOLIDAY,0)) 
		FROM	#EMP_DATES E 
				INNER JOIN (
							SELECT	IsNull(SUM(P_DAYS),0) AS TOTAL_P_DAYS, IsNull(SUM(A_DAYS),0) AS TOTAL_A_DAYS, EMP_ID,
									SUM((CASE WHEN [STATUS] = 'W' THEN A.WO_HO_DAY ELSE 0 END)) AS TOTAL_WEEKOFF,
									SUM((CASE WHEN [STATUS] = 'HO' or [STATUS] = 'OHO' THEN A.WO_HO_DAY ELSE 0 END)) AS TOTAL_HOLIDAY 
							FROM	#ATT_CONS A
							GROUP BY  EMP_ID
							) A ON E.EMP_ID=A.EMP_ID
		WHERE	E.ROW_ID=1



		--Added by Mukti(10032017)start
			DECLARE @OD_COMOFF_SETTING INT
			SELECT @OD_COMOFF_SETTING =ISNULL(SETTING_VALUE,0)
			FROM DBO.T0040_SETTING WITH (NOLOCK) WHERE CMP_ID=@CMP_ID AND SETTING_NAME  = 'OD AND COMPOFF LEAVE CONSIDER AS PRESENT'
			
			
			IF ISNULL(@OD_COMOFF_SETTING,0) = 1
				BEGIN			
					
					UPDATE	ED 
					SET		P_DAYS = IsNull(P_DAYS,0) + ld.LEAVE_PERIOD
					FROM	#EMP_DATES ED
							INNER JOIN (SELECT	Emp_Id, IsNull(SUM(LEAVE_PERIOD),0) As Leave_Period
										FROM	#LEAVE_DETAILS LD 
												INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LM.Leave_ID=LD.Leave_ID AND (LM.Leave_Type='Company Purpose' OR lm.Leave_Code = 'COMP')  --Change by Jaina 17-11-2017
										GROUP BY Emp_Id) LD on ED.EMP_ID=LD.EMP_ID 				
					WHERE	ED.ROW_ID=1
					
					
					update #CONSOLIDATED set LEAVE_COUNT = 0
					

					update ED set LEAVE_COUNT = ld.LEAVE_PERIOD
					from #CONSOLIDATED ED
					inner join (Select	Emp_Id, IsNull(sum(LEAVE_PERIOD),0) As Leave_Period
								FROM	#LEAVE_DETAILS LD inner join 
									T0040_LEAVE_MASTER LM WITH (NOLOCK) on LM.Leave_ID=LD.Leave_ID and (LM.Leave_Type<>'Company Purpose' AND LM.Default_Short_Name <> 'COMP')
								 Group by Emp_Id) LD on ED.EMP_ID=LD.EMP_ID 
					where ISNULL(ED.Emp_Code,'') <> ''		

				end 
	--Added by Mukti(10032017)end
	
	if @Format=2  --for Attendance Register Format-2
		BEGIN	
			--commented by Mukti(10032017)start
			--DECLARE curLeave CURSOR FOR
			--SELECT DISTINCT [STATUS] FROM #ATT_CONS A WHERE SHIFT_ID <> 9999 AND LEAVE_COUNT > 0
			--OPEN curLeave
			--FETCH NEXT FROM curLeave INTO @COL_NAME		
			--WHILE @@FETCH_STATUS = 0
			--	BEGIN
			--				SET @QUERY = 'ALTER TABLE  #EMP_DATES ADD [' + @COL_NAME + '] VARCHAR(5) NULL; '
			--				EXEC (@QUERY)
							
			--				SET @UPDATE_TEMPLATE =	'UPDATE E SET [' + @COL_NAME + ']=A.D_COUNT
			--						FROM	#EMP_DATES E
			--								INNER JOIN (SELECT SUM(LEAVE_COUNT) AS D_COUNT, EMP_ID FROM  #ATT_CONS A WHERE [STATUS]=@COL_NAME GROUP BY EMP_ID) A ON E.EMP_ID=A.EMP_ID 
			--						WHERE	E.ROW_ID=1'
			--		EXEC sp_executesql @UPDATE_TEMPLATE, N'@TEMP_DATE DATETIME, @COL_NAME VARCHAR(32)', @TEMP_DATE, @COL_NAME
			--		FETCH NEXT FROM curLeave INTO @COL_NAME
			--	END
			--CLOSE curLeave
			--DEALLOCATE curLeave
			--commented by Mukti(10032017)end
			--Added by Mukti(10032017)start
			
			SET @EXISTS_COLS = ','

			--select * from #LEAVE_DETAILS
			DECLARE @Leave_period as NUMERIC(18,2)
			DECLARE @Leave_Type as VARCHAR(30)
			DECLARE curLeave CURSOR FOR
				SELECT DISTINCT A.LEAVE_CODE,A.LEAVE_PERIOD,A.EMP_ID,LM.Leave_Type FROM #LEAVE_DETAILS A
				inner join T0040_LEAVE_MASTER LM WITH (NOLOCK) on LM.Leave_ID=A.Leave_ID				
			OPEN curLeave
			FETCH NEXT FROM curLeave INTO @COL_NAME,@Leave_period,@emp_id,@Leave_Type		
			WHILE @@FETCH_STATUS = 0
				BEGIN
							if NOT(ISNULL(@OD_COMOFF_SETTING,0) = 1 and @Leave_Type='Company Purpose')
								BEGIN
								--if not EXISTS(select * from #EMP_DATES where )								
									IF CHARINDEX(',' + @COL_NAME + ',', @EXISTS_COLS) = 0
										BEGIN 
											SET @QUERY = 'ALTER TABLE  #EMP_DATES ADD [' + @COL_NAME + '] VARCHAR(5) NULL; '
											EXEC (@QUERY)
										END
									
									SET @EXISTS_COLS = @EXISTS_COLS +@COL_NAME  + ','
									SET @UPDATE_TEMPLATE =	'UPDATE #EMP_DATES SET [' + @COL_NAME + ']=' + cast(@Leave_period as varchar(15)) + '
									where emp_id=' + cast(@emp_id as varchar(50)) + ' and ROW_ID=1'
								
									EXEC sp_executesql @UPDATE_TEMPLATE, N'@TEMP_DATE DATETIME, @COL_NAME VARCHAR(32)', @TEMP_DATE, @COL_NAME
									
								END								
					FETCH NEXT FROM curLeave INTO @COL_NAME,@Leave_period,@emp_id,@Leave_Type
				END
			CLOSE curLeave
			DEALLOCATE curLeave

						
			ALTER TABLE #EMP_DATES DROP COLUMN ROW_ID
			SELECT	CASE WHEN EMP_CODE IS NULL THEN NULL ELSE  SR_NO END AS SRNO,Emp_Code,Emp_Name,Branch,Grade,Designation,Department,[Type_Name],Segment_Name,Vertical_Name,SubVertical_Name,SubBranch_Name,Shift_Name,
					ED.*,(CASE WHEN C.EMP_CODE IS NULL THEN NULL ELSE ISNULL(C.LEAVE_COUNT,0) END) AS LEAVE_DAYS, 
					(CASE WHEN C.EMP_CODE IS NULL THEN NULL ELSE (ISNULL(ED.P_DAYS,0) + ISNULL(ED.WEEKOFF,0) + ISNULL(ED.HOLIDAY,0) + ISNULL(C.LEAVE_COUNT,0)) END) AS TOTAL_DAYS, 
					(CASE WHEN C.Emp_Code IS NULL THEN NULL ELSE ISNULL(C.LATE_DEDUCT_DAYS,0) END) AS LATE_DAYS,
					(CASE WHEN C.EMP_CODE IS NULL THEN NULL ELSE ((ISNULL(ED.P_DAYS,0) + ISNULL(ED.WEEKOFF,0) + ISNULL(ED.HOLIDAY,0) + ISNULL(C.LEAVE_COUNT,0)) - ISNULL(C.LATE_DEDUCT_DAYS,0)) END) AS PAYABLE_DAYS --,LEAVE_COUNT,WO_HO_DAY,LATE_DEDUCT_DAYS,EARLY_DEDUCT_DAYS,P_FROM_DATE,P_TO_DATE,BRANCH_ID,P_DAYS,A_DAYS,WEEKOFF,HOLIDAY
			FROM	#CONSOLIDATED C INNER JOIN #EMP_DATES ED ON C.EMP_ID=ED.EMP_ID AND C.SHIFT_ID=ED.SHIFT_ID 
			ORDER BY SR_NO, SHIFT_ID
		END
	ELSE if @Format=5  --for Attendance Register Format-5
		BEGIN
			UPDATE	E	
			SET		UNPAID_LEAVE = ISNULL(A.UNPAID_LEAVE,0)			
			FROM	#EMP_DATES E 
					INNER JOIN (
								SELECT	isnull(sum(LT.Leave_Used),0)as UNPAID_LEAVE,LT.Emp_ID
								FROM	T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)
								inner join T0040_LEAVE_MASTER LM WITH (NOLOCK) on lt.Leave_ID=lm.Leave_ID
								WHERE LM.Leave_Paid_Unpaid='U' and Leave_Type <> 'Company Purpose'
								and LT.Cmp_Id=@Cmp_ID AND LT.For_Date>=@From_Date AND LT.For_Date<=@To_Date
								GROUP BY  LT.EMP_ID
								) A ON E.EMP_ID=A.EMP_ID
			 					
			IF @OD_COMOFF_SETTING = 0 -- Added By Nilesh Patel on 16082019 -OD Consider in Paid Leave -- Mantis ID = 0007726
				BEGIN
						UPDATE	E	
						SET		PAID_LEAVE = ISNULL(A.PAID_LEAVE,0)			
						FROM	#EMP_DATES E 
								INNER JOIN (
											SELECT	isnull(sum(LT.Leave_Used),0)as PAID_LEAVE,LT.Emp_ID
											FROM	T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)
											inner join T0040_LEAVE_MASTER LM WITH (NOLOCK) on lt.Leave_ID=lm.Leave_ID
											WHERE LM.Leave_Paid_Unpaid='P' and Leave_Type <> 'Company Purpose'
											and LT.Cmp_Id=@Cmp_ID AND LT.For_Date>=@From_Date AND LT.For_Date<=@To_Date
											GROUP BY  LT.EMP_ID
											) A ON E.EMP_ID=A.EMP_ID
				END
			
						
			ALTER TABLE #EMP_DATES DROP COLUMN [A_DAYS]
			ALTER TABLE #EMP_DATES DROP COLUMN ROW_ID
			
			SELECT	CASE WHEN EMP_CODE IS NULL THEN NULL ELSE  SR_NO END AS SR_NO,Worker_Adult_No as [Sr_No_in_the_Reg_of_Adult_Worker],
				Emp_Name as[Employee_Name],c.Father_Name[Father_Name/Spouse_Name],convert(VARCHAR(12),c.Date_Of_Birth,103)Date_Of_Birth,c.Gender as [Sex],C.Designation,
				convert(VARCHAR(12),c.Date_Of_Join,103) as[Date_of_Appointment],ED.*,
				--(CASE WHEN C.EMP_CODE IS NULL THEN NULL ELSE ((ISNULL(ED.P_DAYS,0) + ISNULL(ED.WEEKOFF,0) + ISNULL(ED.HOLIDAY,0) + ISNULL(C.LEAVE_COUNT,0)) - ISNULL(C.LATE_DEDUCT_DAYS,0)) END) AS [Total_Man_Days_Paid],
				(CASE WHEN C.EMP_CODE IS NULL THEN NULL ELSE ((ISNULL(ED.P_DAYS,0) + ISNULL(ED.WEEKOFF,0) + ISNULL(ED.HOLIDAY,0) + ISNULL(ED.PAID_LEAVE,0))) END) AS [Total_Man_Days_Paid],
				CM.Cmp_Address AS CMP_ADDRESS
			FROM	#CONSOLIDATED C 
			INNER JOIN #EMP_DATES ED ON C.EMP_ID=ED.EMP_ID AND C.SHIFT_ID=ED.SHIFT_ID 
			INNER JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) ON CM.CMP_ID =@Cmp_ID 
			where c.SHIFT_ID <> 9999 and ISNULL(C.Emp_Name,'') <> ''
			ORDER BY SR_NO, SHIFT_ID
		END
	 --PRINT converT(varchar(20), getdate(), 114) + ' STEP 4'
	--ALTER TABLE #FINAL DROP COLUMN EMP_ID, ROW_ID

	--SELECT * FROM #FINAL --ORDER BY SR_NO, SHIFT_ID
	
