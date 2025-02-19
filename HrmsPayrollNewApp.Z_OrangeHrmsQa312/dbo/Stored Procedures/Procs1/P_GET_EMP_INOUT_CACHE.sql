CREATE PROCEDURE [dbo].[P_GET_EMP_INOUT_CACHE] 	
	@Cmp_ID		NUMERIC(9,0), 	
	@From_Date	DateTime,
	@To_Date	DateTime,
	@First_In_Last_OUT_Flag tinyint=0 ---Hardik 28/04/2017 for Today's Attendance on Home Page
AS
BEGIN
	
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET ANSI_WARNINGS OFF
	
	DECLARE @BEFORE_AFTER_DAYS INT
	SET @BEFORE_AFTER_DAYS = 8
	
	
	IF OBJECT_ID('tempdb..#TMP_EMP_0150_INOUT') IS NULL
		BEGIN
		

			SElECT TOP 0 * INTO #TMP_EMP_0150_INOUT FROM T0150_EMP_INOUT_RECORD WITH (NOLOCK) WHERE 1<>1
			CREATE CLUSTERED INDEX IX_TMP_INOUT ON #TMP_EMP_0150_INOUT (For_Date Desc,Emp_ID, In_Time,Out_Time)
			
			INSERT INTO #TMP_EMP_0150_INOUT
			SELECT EIR.* FROM dbo.T0150_EMP_INOUT_RECORD EIR  WITH (NOLOCK) 
			INNER JOIN #EMP_CONS EC ON EIR.EMP_ID=EC.EMP_ID
			WHERE	FOR_DATE BETWEEN (@FROM_DATE - @BEFORE_AFTER_DAYS) AND (@To_Date + @BEFORE_AFTER_DAYS)



		END
	
	
	IF OBJECT_ID('tempdb..#EMP_GEN_SETTINGS') IS NULL
		BEGIN
			CREATE TABLE #EMP_GEN_SETTINGS
			(
				EMP_ID		NUMERIC PRIMARY KEY ,
				BRANCH_ID	NUMERIC,
				First_In_Last_Out_For_InOut_Calculation TINYINT,
				Chk_otLimit_before_after_Shift_time	TINYINT
			) 
		END
	IF NOT EXISTS(SELECT 1 FROM tempdb.sys.columns Where object_id = OBJECT_ID('tempdb..#EMP_GEN_SETTINGS') AND name='Is_OT')
		ALTER TABLE #EMP_GEN_SETTINGS ADD Is_OT TinyInt NULL;
	
	

	--INSERT INTO #EMP_GEN_SETTINGS(Emp_ID,Branch_ID,First_In_Last_Out_For_InOut_Calculation ,Chk_otLimit_before_after_Shift_time)	
	SELECT	GS.GEN_ID,EC.EMP_ID, EC.BRANCH_ID,First_In_Last_Out_For_InOut_Calculation,Chk_otLimit_before_after_Shift_time, Is_OT
	INTO	#TMP_GEN
	FROM	#EMP_CONS EC 
			INNER JOIN T0040_GENERAL_SETTING GS  WITH (NOLOCK) ON EC.BRANCH_ID=GS.BRANCH_ID
			INNER JOIN (SELECT	GS1.BRANCH_ID, MAX(FOR_DATE) AS FOR_DATE
						FROM	T0040_GENERAL_SETTING GS1  WITH (NOLOCK) 
						WHERE	GS1.FOR_DATE < @TO_DATE
						GROUP BY GS1.BRANCH_ID) GS1 ON GS.BRANCH_ID=GS1.BRANCH_ID AND GS.FOR_DATE=GS1.FOR_DATE;




	INSERT INTO #EMP_GEN_SETTINGS(Emp_ID,Branch_ID,First_In_Last_Out_For_InOut_Calculation ,Chk_otLimit_before_after_Shift_time)	
	SELECT	DISTINCT EMP_ID, BRANCH_ID,First_In_Last_Out_For_InOut_Calculation,Chk_otLimit_before_after_Shift_time
	FROM	#TMP_GEN
	WHERE NOT EXISTS (SELECT 1 FROM #EMP_GEN_SETTINGS EGS WHERE #TMP_GEN.EMP_ID = EGS.EMP_ID)
	

	UPDATE	G
	SET		IS_OT = G1.IS_OT
	FROM	#EMP_GEN_SETTINGS G 
			INNER JOIN #TMP_GEN G1 ON G.EMP_ID=G1.EMP_ID
		
/*
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
	CREATE UNIQUE CLUSTERED INDEX IX_DATA_FILO ON #DATA (EMP_ID, FOR_DATE)
*/
	CREATE table #Data_EIO_Diff
	(         
	   Emp_Id   NUMERIC ,         
	   For_date DATETIME,        
	   Diff_Sec NUMERIC
	)         
	CREATE NONCLUSTERED INDEX ix_Data_temp1_Diff_Emp_Id_For_date ON #Data_EIO_Diff(Emp_Id,For_Date);
	
	--Added by Jaina 16-03-2017 Start
	DECLARE @DIFF_HOUR AS NUMERIC(18,4)
	Declare @Total_second as numeric(18)
	SET @DIFF_HOUR = 0
	SET @Total_second = 0
	
	select @DIFF_HOUR = CAST(Setting_Value  AS numeric(18,2)) from T0040_SETTING  WITH (NOLOCK) where Cmp_ID=@Cmp_Id and Setting_Name='Remove the Gap Between Two In-Out Punch from Working Hours' and ISNUMERIC(Setting_Value)=1
	
	IF @DIFF_HOUR % 1.00 > 0
		SET @DIFF_HOUR = (@DIFF_HOUR * 100) / 60;
						
	IF @DIFF_HOUR > 0
		BEGIN
			set @Total_second = (@DIFF_HOUR * 3600)
	
			--Added by Jaina 16-03-2017 End
		
			SELECT	ROW_NUMBER() OVER(PARTITION BY EIO1.Emp_ID ORDER BY FOR_DATE,ISNULL(IN_TIME, OUT_TIME)) AS ROW_ID, EIO1.Emp_ID,For_Date,In_Time,Out_Time 
			INTO	#EIO
			FROM	#TMP_EMP_0150_INOUT EIO1 INNER JOIN
					#Emp_Cons Ec ON EIO1.Emp_Id = ec.Emp_ID
			WHERE	--EIO1.Emp_ID = @curEmp_ID
					EIO1.cmp_Id= @Cmp_ID  and EIO1.for_Date >=@From_Date and EIO1.For_Date <=@To_Date 

	
			;WITH Q(ROW_ID,Emp_ID,For_Date,In_Time,Out_Time,LVL, DIFF,DiffSe) AS
			(
				SELECT	ROW_ID, EIO1.Emp_ID,For_Date,In_Time,Out_Time, 'U' AS LVL, CAST(NULL AS DATETIME) AS DIFF ,CAST(0 AS INT) AS DiffSe
				FROM	#EIO EIO1
				WHERE	ROW_ID=1
				UNION ALL
				SELECT	EIO2.ROW_ID,EIO2.Emp_ID,EIO2.For_Date,EIO2.In_Time,EIO2.Out_Time,'D' AS LVL,Q.Out_Time ,CAST(DATEDIFF(S,Q.out_Time,EIO2.In_Time) AS INT) AS DiffSe --CAST(EIO2.In_Time - Q.Out_Time AS DATETIME) AS DIFF
				FROM	#EIO EIO2 INNER JOIN Q ON EIO2.ROW_ID = (Q.ROW_ID + 1) AND Q.Emp_ID=EIO2.Emp_ID
			) 
 
			
			INSERT INTO #Data_EIO_Diff
			SELECT	Q.Emp_id,Q.For_Date,Q.DiffSe
			FROM Q	INNER JOIN (SELECT FOR_DATE, EMP_ID FROM Q Where Isnull(Out_Time,'')<>'' GROUP BY EMP_ID,FOR_DATE HAVING COUNT(1) >1 ) Q1 ON Q.FOR_DATE=Q1.FOR_DATE AND Q.EMP_ID=Q1.EMP_ID  ---Isnull(Out_Time,'')<>'' condition added by Hardik 21/07/2017 for Dishman Pharma
					INNER JOIN (SELECT MAX(ROW_ID) AS ROW_ID,EMP_ID,FOR_DATE FROM Q GROUP BY FOR_DATE,EMP_ID ) Q2 ON Q.ROW_ID=Q2.ROW_ID and Q2.Emp_ID=Q1.Emp_ID
			--WHERE	LVL='D' AND Q.DiffSe >= 18000 OPTION(MAXRECURSION 0) --(More thatn 5 Hours)
			WHERE	LVL='D' AND Q.DiffSe >= @Total_second OPTION(MAXRECURSION 0) --(More thatn 5 Hours)  --Change by Jaina 16-03-2017
			--SELECT Emp_id,DIFF,In_Time,Out_Time,Q.DiffSe FROM Q WHERE LVL='D' ORDER BY ROW_ID
			
			DROP TABLE #EIO
		END
	
	
	DECLARE @cBrh AS NUMERIC	
	DECLARE @Chk_otLimit_before_after_Shift_time TINYINT 
    DECLARE @First_In_Last_Out_For_InOut_Calculation TINYINT 
	DECLARE @curEmp_ID NUMERIC(9,0)
	

	DECLARE @IsNight BIT
	
	DECLARE @In_Time DateTime
	DECLARE @Out_Time DateTime
	
	
	--SET @IsNight = 0	--SET @IsNight = 1 for AIA Client otherwise SET it 0.
	--SELECT @IsNight = ISNULL(SETTING_VALUE,0) FROM T0040_SETTING WHERE SETTING_NAME='Enable Night Shift Scenario for In Out' AND CMP_ID=@Cmp_ID
	
	--DECLARE @COUNT INT 
	--SET @COUNT = 0
	
	--IF Isnull(@IsNight,0) = 1
		BEGIN			
			DECLARE @Shift_Id_N AS NUMERIC
			DECLARE @Shift_St_Sec AS NUMERIC
			DECLARE @Shift_En_sec AS NUMERIC
			DECLARE @Shift_St_Time AS VARCHAR(10)
			DECLARE @Shift_End_Time AS VARCHAR(10)
			DECLARE @Shift_Dur_N AS VARCHAR(10)
			DECLARE @Shift_ST_DateTime AS DATETIME
			DECLARE @Temp_Date AS DATETIME
			
			DECLARE @Shift_End_DateTime AS DATETIME
			DECLARE @Insert_In_Date AS DATETIME
			DECLARE @Insert_Out_Date AS DATETIME
			
			DECLARE @Shift_St_Sec_Next_day AS NUMERIC
			DECLARE @Shift_En_sec_Next_day AS NUMERIC
			DECLARE @Shift_St_Time_Next_day AS VARCHAR(10)
			DECLARE @Shift_End_Time_Next_day AS VARCHAR(10)
			DECLARE @Shift_End_DateTime_Next_day AS DATETIME
			DECLARE @Shift_ST_DateTime_Next_day AS DATETIME
			DECLARE @Shift_Id_N_Next_day AS NUMERIC
			DECLARE @Shift_Dur_N_Next_Day AS VARCHAR(10)
			DECLARE @Add_Hrs_Shift_End_Time AS NUMERIC(18,3)
			DECLARE @Minus_Hrs_Shift_St_Time AS NUMERIC
			DECLARE @Temp_Date_Next_Day AS DATETIME
			
			/*Half Day Shift*/
			DECLARE @Is_Half_Day As numeric;
			DECLARE @Half_WeekDay Varchar(10);
			DECLARE @Half_Shift_St_Time As DATETIME;
			DECLARE @Half_Shift_End_Time As DATETIME;			
			DECLARE @Half_Shift_Day AS BIT;
			/*Half Day Shift*/
			
			DECLARE @Temp_End_Date AS DATETIME
			DECLARE @Temp_Month_Date AS DATETIME
			
			DECLARE @PREVIOUS_END_TIME DATETIME
			
			DECLARE @EMP_COUNT INT 
			SELECT @EMP_COUNT = COUNT(1) FROM #EMP_CONS
			
			CREATE TABLE #EMP_SHIFT
			(
				EMP_ID		NUMERIC,
				FOR_DATE	DATETIME,
				SHIFT_ID	NUMERIC,
				Shift_St_Time	DateTime,
				Shift_End_Time	DateTime,
				Duration		Varchar(5),
				Shift_Type		TinyInt,
				Shift_Before	DateTime,
				Shift_After		DateTime,
				Add_Hrs_Shift_End_Time	Numeric
			)

		
			DECLARE @TEMP_FROM_DATE DATETIME
			DECLARE @TEMP_TO_DATE DATETIME
			SET @TEMP_FROM_DATE = @FROM_DATE - @BEFORE_AFTER_DAYS
			SET @TEMP_TO_DATE = @To_DATE + @BEFORE_AFTER_DAYS
			
			
			INSERT	INTO #EMP_SHIFT(EMP_ID, FOR_DATE,Shift_ID, Shift_Type,Shift_St_Time,Shift_End_Time,Duration,Add_Hrs_Shift_End_Time)
			Select	Distinct EC.Emp_ID, T.For_Date, ESD.Shift_ID, Shift_Type,FOR_DATE + Shift_St_Time,FOR_DATE + Shift_End_Time,F_Duration,7
			FROM	#Emp_Cons EC 					
					INNER JOIN T0080_EMP_MASTER EM  WITH (NOLOCK) ON EC.EMP_ID = EM.EMP_ID
					Cross Join (Select	Top 400 DateAdd(D, ROW_NUMBER() Over(Order by Object_ID) -1, @TEMP_FROM_DATE) As For_Date
								FROM	sys.tables ) T 
					Cross Apply (Select Shift_ID, Shift_Type
								 FROM	T0100_EMP_SHIFT_DETAIL ESD  WITH (NOLOCK) 
										INNER JOIN (SELECT	Emp_ID, Max(For_Date) As For_Date
													FROM	T0100_EMP_SHIFT_DETAIL ESD1 WITH (NOLOCK) 
													Where	ESD1.For_Date <= T.For_Date And ESD1.Shift_Type <> 1
													Group by ESD1.Emp_ID) ESD1 ON ESD1.Emp_ID=ESD.Emp_ID AND ESD1.For_Date=ESD.For_Date
								 Where	ESD.Emp_ID=EC.Emp_ID AND ESD.For_Date <= T.For_Date
								) ESD
					INNER JOIN T0040_SHIFT_MASTER SM  WITH (NOLOCK) ON ESD.Shift_ID=SM.Shift_ID
					--Left Outer Join T0100_EMP_SHIFT_DETAIL ESD ON EC.Emp_ID=ESD.Emp_ID AND T.For_Date=ESD.For_date										
			WHERE	T.For_Date Between EM.Date_Of_Join AND ISNULL(EM.Emp_Left_Date , @To_Date + @BEFORE_AFTER_DAYS) AND T.FOR_DATE <= (@To_Date + @BEFORE_AFTER_DAYS)
					AND EXISTS(SELECT 1 FROM #TMP_EMP_0150_INOUT EIO WHERE EIO.EMP_ID=EC.EMP_ID)	
			
			-- Added Below update query by Hardik 23/09/2019 for Elsamax as they have Tempoary shift assign which is not calculated proper.. also in above query added one codition "And ESD1.Shift_Type <> 1"


			Update ES
			Set Shift_Id = ESD.Shift_ID,
				Shift_St_Time = ES.FOR_DATE + SM.Shift_St_Time,
				Shift_End_Time = ES.FOR_DATE + SM.Shift_End_Time
				,Duration = F_Duration
			From #EMP_SHIFT ES 
				Inner Join T0100_EMP_SHIFT_DETAIL ESD  WITH (NOLOCK) On ES.EMP_ID=ESD.Emp_ID And ES.FOR_DATE=ESD.For_Date
				INNER JOIN T0040_SHIFT_MASTER SM  WITH (NOLOCK) ON ESD.Shift_ID=SM.Shift_ID
			Where ESD.Shift_Type = 1


			
			UPDATE	ES
			SET		Shift_St_Time = FOR_DATE + Half_St_Time,
					Shift_End_Time = FOR_DATE + Half_End_Time
					,Duration = Half_Dur
			FROM	#EMP_SHIFT ES
					INNER JOIN T0040_SHIFT_MASTER SM  WITH (NOLOCK) ON ES.Shift_ID=SM.Shift_ID AND DATENAME(WEEKDAY, ES.FOR_DATE)=SM.WEEK_DAY
			WHERE	SM.IS_HALF_DAY=1 AND ISNULL(Half_St_Time,'') <> ''
			
			/*
			UPDATE	ES
			SET		Shift_St_Time = ES.Shift_St_Time ,
					Shift_End_Time = ES.Shift_End_Time + 1
			FROM	#EMP_SHIFT ES
					INNER JOIN T0040_SHIFT_MASTER SM ON ES.Shift_ID=SM.Shift_ID AND SM.Shift_St_Time > SM.Shift_End_Time
			WHERE	SM.IS_HALF_DAY=1 AND ISNULL(Half_St_Time,'') <> ''
			*/

			UPDATE	#EMP_SHIFT
			SET		Shift_End_Time = Shift_End_Time + 1
			WHERE	Shift_End_Time < Shift_St_Time		
			
			UPDATE	ES
			SET		Add_Hrs_Shift_End_Time = IsNull(CASE WHEN DATEDIFF(HH,ES.Shift_End_Time, NES.Shift_St_Time) = 0 THEN 1
												  WHEN DATEDIFF(HH,ES.Shift_End_Time, NES.Shift_St_Time) > 16 THEN 11
												  WHEN DATEDIFF(HH,ES.Shift_End_Time, NES.Shift_St_Time) > 9 THEN DATEDIFF(HH,ES.Shift_End_Time, NES.Shift_St_Time) - 5
												  ELSE
														DATEDIFF(HH,ES.Shift_End_Time, NES.Shift_St_Time) / 2
											 END,Es.Add_Hrs_Shift_End_Time)
			FROM	#EMP_SHIFT ES
					LEFT OUTER JOIN #EMP_SHIFT NES ON ES.EMP_ID=NES.EMP_ID AND ES.FOR_DATE=(NES.FOR_DATE-1)
			
			
			UPDATE	ES
			SET		Shift_Before = DateAdd(HH, -7, ES.Shift_St_Time),
					Shift_After = DateAdd(HH, Add_Hrs_Shift_End_Time, ES.Shift_End_Time)
			FROM	#EMP_SHIFT ES
			
			
			UPDATE	ES
			SET		Shift_Before = Case When BES.Shift_After < ES.Shift_St_Time  THEN IsNull(DateAdd(n, 1, BES.Shift_After), DateAdd(hh,-5,ES.Shift_St_Time)) ELSE DateAdd(n,-30,ES.Shift_St_Time) END
			FROM	#EMP_SHIFT ES
					LEFT OUTER JOIN #EMP_SHIFT BES ON ES.EMP_ID=BES.EMP_ID AND ES.FOR_DATE=(BES.FOR_DATE+1);
			
			
			INSERT	INTO #DATA(Emp_ID,For_Date,Duration_In_sec,Emp_OT,Shift_ID,Shift_Type,Shift_Start_Time,Shift_End_Time)        
			SELECT	ES.EMP_ID, ES.FOR_DATE, DateDiff(s,'1900-01-01', ES.Duration), GS.IS_OT,ES.Shift_ID,ES.Shift_Type,ES.Shift_St_Time,ES.Shift_End_Time
			FROM	#EMP_SHIFT ES
					INNER JOIN #EMP_GEN_SETTINGS GS ON ES.EMP_ID=GS.EMP_ID
			
			
			UPDATE	D 
			SET		Chk_By_Superior = EIO.Chk_By_Superior --1
			FROM 	#DATA D
					INNER JOIN #TMP_EMP_0150_INOUT EIO ON D.EMP_ID=EIO.EMP_ID AND D.FOR_DATE=EIO.FOR_DATE
			--WHERE	EIO.Chk_By_Superior = 1  --- Commented by Hardik 08/09/2020 for Honda as if they Reject Regularise then In and Out time not showing

			
			DECLARE @FOR_DATE DATETIME
			SET @FOR_DATE = @TEMP_FROM_DATE
			WHILE @FOR_DATE <= DATEADD(D, @BEFORE_AFTER_DAYS * 1, @TO_DATE)
				BEGIN								
					--print DATEADD(D, @BEFORE_AFTER_DAYS * 1, @TO_DATE)

					UPDATE	D
					SET		IN_TIME = EIO.IN_TIME,
							OUT_TIME = CASE WHEN EIO.IN_TIME <> EIO.OUT_TIME THEN EIO.OUT_TIME ELSE NULL END,
							IO_Tran_ID = is_cmp_purpose --,
							--Chk_By_Superior = EIO.Chk_By_Superior
					FROM	#DATA D																					
							INNER JOIN	(SELECT ES.EMP_ID,ES.FOR_DATE, MIN(EIO.IN_TIME) AS IN_TIME, MAX(ISNULL(EIO.OUT_TIME,EIO.IN_TIME)) AS OUT_TIME, 
												Max(is_cmp_purpose) As is_cmp_purpose, Max(EIO.Chk_By_Superior) Chk_By_Superior
										 FROM	#TMP_EMP_0150_INOUT EIO 
												INNER JOIN #EMP_SHIFT ES ON EIO.EMP_ID=ES.EMP_ID AND ES.FOR_DATE=@FOR_DATE
												LEFT OUTER JOIN #EMP_SHIFT ENS ON EIO.EMP_ID=ENS.EMP_ID AND ENS.FOR_DATE = (@FOR_DATE + 1)
												LEFT OUTER JOIN #DATA DP ON DP.EMP_ID=EIO.EMP_ID AND DP.FOR_DATE = (@FOR_DATE - 1)
										 WHERE	EIO.IN_TIME > COALESCE(DP.OUT_TIME, DP.IN_Time, ES.Shift_Before) 
												AND EIO.IN_TIME < DateAdd(hh, -3, Isnull(ENS.Shift_Before,Dateadd(dd,1,ES.Shift_Before)))
												AND (
															(EIO.IN_TIME BETWEEN ES.Shift_Before AND (DateDiff(hh, -4, ES.shift_after))
																OR 
																(EIO.For_Date = @For_Date AND IsNull(EIO.Chk_By_Superior,0) = 1)
															)
															AND (
																	(EIO.OUT_TIME < ISNULL(DateAdd(n,30,ENS.Shift_St_Time), DATEADD(HH,4,ES.shift_after)) 
																			AND
																		EIO.IN_TIME < ISNULL(DateAdd(n,-15,ENS.Shift_St_Time), DATEADD(HH,4,ES.shift_after))) 
																	OR EIO.OUT_TIME IS NULL)													
													)												
										GROUP BY ES.FOR_DATE, ES.EMP_ID
										) EIO ON D.EMP_ID=EIO.EMP_ID AND D.Chk_By_Superior = EIO.Chk_By_Superior
					WHERE	D.FOR_DATE=@FOR_DATE
					
					--if OBJECT_ID('tempdb..#debug') is not null and @FOR_DATE='2018-10-24' --nms						
					--	SELECT 2222,@FOR_DATE, ES.EMP_ID,ES.FOR_DATE, EIO.IN_TIME AS IN_TIME, ISNULL(EIO.OUT_TIME,EIO.IN_TIME) AS OUT_TIME, 
					--			is_cmp_purpose As is_cmp_purpose, EIO.Chk_By_Superior Chk_By_Superior,DateAdd(hh, -3, ENS.Shift_Before) ENSShift_Before, 
					--			COALESCE(DP.OUT_TIME, DP.IN_Time, ES.Shift_Before) cmb, es.*
					--	FROM	#TMP_EMP_0150_INOUT EIO 
					--			INNER JOIN #EMP_SHIFT ES ON EIO.EMP_ID=ES.EMP_ID AND ES.FOR_DATE=@FOR_DATE
					--			LEFT OUTER JOIN #EMP_SHIFT ENS ON EIO.EMP_ID=ENS.EMP_ID AND ENS.FOR_DATE = (@FOR_DATE + 1)
					--			LEFT OUTER JOIN #DATA DP ON DP.EMP_ID=EIO.EMP_ID AND DP.FOR_DATE = (@FOR_DATE - 1)
					--	WHERE	EIO.IN_TIME > COALESCE(DP.OUT_TIME, DP.IN_Time, ES.Shift_Before) AND EIO.IN_TIME < DateAdd(hh, -3, ENS.Shift_Before)
					--			--and EIO.IN_TIME > '2018-10-23 07:22' AND EIO.IN_TIME < '2018-10-24 03:30'
					--		--AND (
					--		--			(EIO.IN_TIME BETWEEN ES.Shift_Before AND (DateDiff(hh, -4, ES.shift_after))
					--		--				--OR 
					--		--				--(EIO.For_Date = @For_Date AND IsNull(EIO.Chk_By_Superior,0) = 1 AND EIO.For_Date=ES.FOR_DATE)
					--		--			)
					--		--			--AND (
					--		--			--		(EIO.OUT_TIME < ISNULL(DateAdd(n,30,ENS.Shift_St_Time), DATEADD(HH,4,ES.shift_after)) 
					--		--			--				AND
					--		--			--			EIO.IN_TIME < ISNULL(DateAdd(n,-15,ENS.Shift_St_Time), DATEADD(HH,4,ES.shift_after))) 
					--		--			--		OR EIO.OUT_TIME IS NULL)													
					--		--	)
												


					SET @FOR_DATE = DATEADD(D, 1, @FOR_DATE);					
				END

					  
	  --declare @Ot_max as numeric,@ot_min AS Numeric
	  --		set @Ot_max = DateDiff(s,'1900-01-01',I.Emp_OT_Min_Limit),
			--		@ot_min = DateDiff(s,'1900-01-01',I.Emp_OT_Max_Limit)
			--FROM	#DATA D
			--		INNER JOIN #EMP_CONS EC ON D.EMP_ID=EC.EMP_ID
			--		INNER JOIN T0095_INCREMENT I  WITH (NOLOCK) ON EC.INCREMENT_ID=I.INCREMENT_ID 
			--Where I.Emp_OT_Min_Limit <> '24:00'
			
			UPDATE	D				
			SET		Emp_OT = CASE WHEN D.Emp_OT = 1 THEN I.Emp_OT ELSE 0 END
					,Emp_OT_Min_Limit = DateDiff(s,'1900-01-01',I.Emp_OT_Min_Limit),
					Emp_OT_Max_Limit = DateDiff(s,'1900-01-01',I.Emp_OT_Max_Limit)
			FROM	#DATA D
					INNER JOIN #EMP_CONS EC ON D.EMP_ID=EC.EMP_ID
					INNER JOIN T0095_INCREMENT I  WITH (NOLOCK) ON EC.INCREMENT_ID=I.INCREMENT_ID 
			Where I.Emp_OT_Min_Limit <> '24:00' -- Added by Hardik 22/10/2019 as Error coming in Amman Apollo client
				  And I.Emp_OT_Max_Limit <> '24:00'   ---------- Added by Jignesh Patel 31-12-2021 - Error Coming Toto Client 

				
			UPDATE	D				
			SET		Duration_In_Sec = DateDiff(s, In_Time, IsNull(Out_Time, In_Time))
			FROM	#DATA D
					INNER JOIN #EMP_CONS EC ON D.EMP_ID=EC.EMP_ID
					INNER JOIN T0095_INCREMENT I  WITH (NOLOCK) ON EC.INCREMENT_ID=I.INCREMENT_ID 
					
			--UPDATE	D
			--SET		IN_TIME = EIO.IN_TIME,
			--		OUT_TIME = CASE WHEN EIO.IN_TIME <> EIO.OUT_TIME THEN EIO.OUT_TIME ELSE NULL END,
			--		Emp_OT = I.Emp_OT,
			--		Emp_OT_Min_Limit = DateDiff(s,'1900-01-01',I.Emp_OT_Min_Limit),
			--		Emp_OT_Max_Limit = DateDiff(s,'1900-01-01',I.Emp_OT_Max_Limit),
			--		IO_Tran_ID= is_cmp_purpose
			--FROM	#DATA D
			--		INNER JOIN #EMP_SHIFT ES ON D.EMP_ID=ES.EMP_ID AND D.FOR_DATE=ES.FOR_DATE
			--		INNER JOIN #EMP_SHIFT ENS ON D.EMP_ID=ENS.EMP_ID AND (D.FOR_DATE+1)=ENS.FOR_DATE
			--		INNER JOIN #EMP_CONS EC ON D.EMP_ID=EC.EMP_ID
			--		INNER JOIN T0095_INCREMENT I ON EC.INCREMENT_ID=I.INCREMENT_ID 
			--		CROSS APPLY (SELECT MIN(IN_TIME) AS IN_TIME, MAX(ISNULL(OUT_TIME,IN_TIME)) AS OUT_TIME, Max(is_cmp_purpose) As is_cmp_purpose
			--					 FROM	#TMP_EMP_0150_INOUT EIO 
			--					 WHERE	ES.EMP_ID=EIO.EMP_ID AND (EIO.IN_TIME BETWEEN ES.Shift_Before AND ES.Shift_After 
			--														OR (EIO.OUT_TIME IS NOT NULL AND EIO.OUT_TIME BETWEEN ES.Shift_Before AND ES.Shift_After))
			--							and IsNull(EIO.OUT_TIME, ES.Shift_End_Time) <= DATEADD(HH,-4,ENS.Shift_End_Time)
			--					) EIO
						


	--------------- Add By Jignesh 03-Dec-2019(For Multi Recored )------
	if @First_In_Last_OUT_Flag = 0
	BEGIN			
		
------ Add By Jignesh 03-Dec-2019-----
				IF  OBJECT_ID('tempdb..#DATA_IO') IS NULL 
							BEGIN
								
								IF  object_id('tempdb..#DATA_IO') IS NOT NULL 
								begin
								--SELECT 1;
									DROP TABLE #DATA_IO  
								end
								SELECT * INTO #DATA_IO FROM #DATA  WHERE 1=2
							END
-----------------End-------------

				

			IF  object_id('tempdb..#DATA_IO') IS NOT NULL 
				BEGIN      
					INSERT INTO #DATA_IO
					SELECT DISTINCT
					A.Emp_Id,A.For_date,Duration_in_sec,A.Shift_ID,A.Shift_Type,A.Emp_OT,Emp_OT_min_Limit,A.Emp_OT_max_Limit,
					A.P_days	
					,A.OT_Sec	,B.In_Time	,A.Shift_Start_Time	,A.OT_Start_Time	,A.Shift_Change	,A.Flag	,A.Weekoff_OT_Sec	,A.Holiday_OT_Sec	,A.Chk_By_Superior	
					,A.IO_Tran_Id	,B.OUT_Time	,A.Shift_End_Time	,A.OT_End_Time	,A.Working_Hrs_St_Time	,A.Working_Hrs_End_Time	
					,A.GatePass_Deduct_Days
				
					FROM #DATA AS A Inner JOIN #TMP_EMP_0150_INOUT AS B
					ON A.emp_id = B.Emp_id
					And A.for_date = B.For_Date
					--And B.out_Time between A.In_Time AND isnull(A.out_time,A.Shift_End_Time)
					ORDER BY B.in_time

					UPDATE	D				
					SET		Emp_OT = CASE WHEN D.Emp_OT = 1 THEN I.Emp_OT ELSE 0 END,
							Emp_OT_Min_Limit = DateDiff(s,'1900-01-01',I.Emp_OT_Min_Limit),
							Emp_OT_Max_Limit = DateDiff(s,'1900-01-01',I.Emp_OT_Max_Limit),
							Duration_In_Sec = DateDiff(s, In_Time, IsNull(Out_Time, In_Time))
					FROM	#DATA_IO D
							INNER JOIN #EMP_CONS EC ON D.EMP_ID=EC.EMP_ID
							INNER JOIN T0095_INCREMENT I  WITH (NOLOCK) ON EC.INCREMENT_ID=I.INCREMENT_ID 
					Where I.Emp_OT_Min_Limit <> '24:00' 
					And I.Emp_OT_Max_Limit <> '24:00'   ---------- Added by Jignesh Patel 31-12-2021 - Error Coming Toto Client 
					--select * from #TMP_EMP_0150_INOUT	
					--select * from #DATA
					DELETE FROM #DATA
					INSERT INTO #DATA SELECT * FROM #DATA_IO 
				END  
			
	END
	----------------- End -----------------------		
			
			
			DELETE FROM #DATA WHERE IN_TIME IS NULL AND OUT_TIME IS NULL And Chk_By_Superior <> 1
		
			DELETE FROM #DATA WHERE FOR_DATE NOT BETWEEN @FROM_DATE AND @TO_DATE
			
			
		
			--INSERT INTO T0160_EMP_INOUT_CACH
			--SELECT * FROM #DATA WHERE FOR_DATE BETWEEN (@FROM_DATE - (@BEFORE_AFTER_DAYS - 1)) AND (@TO_DATE + (@BEFORE_AFTER_DAYS - 1)) ORDER BY EMP_ID, FOR_DATE DESC
		
			--RETURN

END

END

