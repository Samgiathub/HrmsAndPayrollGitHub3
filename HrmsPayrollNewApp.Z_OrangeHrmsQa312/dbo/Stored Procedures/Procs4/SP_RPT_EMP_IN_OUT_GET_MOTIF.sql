

CREATE PROCEDURE [dbo].[SP_RPT_EMP_IN_OUT_GET_MOTIF]
	 @Cmp_ID 		NUMERIC
	,@From_Date		DATETIME
	,@To_Date 		DATETIME
	,@Branch_ID		NUMERIC
	,@Cat_ID 		NUMERIC 
	,@Grd_ID 		NUMERIC
	,@Type_ID 		NUMERIC
	,@Dept_ID 		NUMERIC
	,@Desig_ID 		NUMERIC
	,@Emp_ID 		NUMERIC
	,@constraint 	VARCHAR(max)
	,@Sal_Type		NUMERIC =0
	,@Type			NUMERIC = 0 -- Added by Ali 03032014
AS

        SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON
	
	IF @Branch_ID = 0  
		SET @Branch_ID = null
		
	IF @Cat_ID = 0  
		SET @Cat_ID = null

	IF @Grd_ID = 0  
		SET @Grd_ID = null

	IF @Type_ID = 0  
		SET @Type_ID = null

	IF @Dept_ID = 0  
		SET @Dept_ID = null

	IF @Desig_ID = 0  
		SET @Desig_ID = null

	IF @Emp_ID = 0  
		SET @Emp_ID = null
		
	
	--Added by Jaina 18-11-2016 Start
	
	if OBJECT_ID('tempdb..#Emp_Cons') IS NULL
		BEGIN
			CREATE TABLE #Emp_Cons 
			 (      
				Emp_ID NUMERIC ,     
				Branch_ID NUMERIC,
				Increment_ID NUMERIC    
			 )       
		
			EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID=@Cmp_ID,@From_Date=@From_Date,@To_Date=@To_Date,@Branch_ID=@Branch_ID,@Cat_ID=@Cat_ID,@Grd_ID=@Grd_ID,@Type_ID=@Type_ID,@Dept_ID=@Dept_ID,@Desig_ID=@Desig_ID,@Emp_ID=@Emp_ID ,@constraint=@constraint,@SalScyle_Flag=3,@Type=@Type
		
			CREATE UNIQUE CLUSTERED INDEX IX_EMP_CONS_EMPID ON #Emp_Cons (EMP_ID);
		
		END
	--Added by Jaina 18-11-2016 END

	DECLARE @Comp_OD_As_Present AS Bit
	
	--Added by Jaina 17-11-2017
	SELECT @Comp_OD_As_Present = ISNULL(SETTING_VALUE,0) FROM T0040_SETTING WITH (NOLOCK)  
	WHERE SETTING_NAME = 'OD and CompOff Leave Consider As Present' AND CMP_ID = @CMP_ID
	
	DECLARE @Is_Cancel_Holiday  NUMERIC(1,0)
	DECLARE @Is_Cancel_Weekoff	NUMERIC(1,0)	

	SELECT	@Is_Cancel_Holiday = IsNull(Is_Cancel_Holiday,0)  ,@Is_Cancel_Weekoff = IsNull(Is_Cancel_Weekoff,0)
	FROM	T0040_GENERAL_SETTING WITH (NOLOCK) 
	WHERE	Cmp_ID = @cmp_ID AND Branch_ID = @Branch_ID
			AND For_Date = (SELECT MAX(For_Date) FROM T0040_GENERAL_SETTING WITH (NOLOCK) WHERE For_Date <=@To_Date AND Branch_ID = @Branch_ID AND Cmp_ID = @Cmp_ID)

	DECLARE @For_Date DATETIME 
	DECLARE @Date_Diff NUMERIC 
	DECLARE @New_To_Date DATETIME 
	SET @Date_Diff = datediff(d,@From_Date,@to_DAte) + 1 
	SET @Date_Diff = 35 - ( @Date_Diff)
	SET @New_To_Date = @To_Date --dateadd(d,@date_diff,@To_Date)	
	IF EXISTS(SELECT * FROM [tempdb].dbo.sysobjects WHERE NAME LIKE '#Att_Muster' )		
		BEGIN
			DROP TABLE #Att_Muster
		END

	CREATE TABLE #Att_Muster 
	(
		Emp_Id		NUMERIC , 
		Cmp_ID		NUMERIC,
		For_Date	DATETIME,
		Leave_Count	NUMERIC(5,1),
		WO_COHO		VARCHAR(4),
		Status_1_1	VARCHAR(22),
		Status_2_1	VARCHAR(22),
		Status_3_1	VARCHAR(22),
		Status_4_1	VARCHAR(22),
		Status_5_1	VARCHAR(22),
		Status_6_1	VARCHAR(22),
		Status_1_2	VARCHAR(22),
		Status_2_2	VARCHAR(22),
		Status_3_2	VARCHAR(22),
		Status_4_2	VARCHAR(22),
		Status_5_2	VARCHAR(22),
		Status_6_2	VARCHAR(22),
		Status_1_3	VARCHAR(22),
		Status_2_3	VARCHAR(22),
		Status_3_3	VARCHAR(22),
		Status_4_3	VARCHAR(22),
		Status_5_3	VARCHAR(22),
		Status_6_3	VARCHAR(22),
		Status_1_4	VARCHAR(22),
		Status_2_4	VARCHAR(22),
		Status_3_4	VARCHAR(22),
		Status_4_4	VARCHAR(22),
		Status_5_4	VARCHAR(22),
		Status_6_4	VARCHAR(22),
		Status_1_5	VARCHAR(22),
		Status_2_5	VARCHAR(22),
		Status_3_5	VARCHAR(22),
		Status_4_5	VARCHAR(22),
		Status_5_5	VARCHAR(22),
		Status_6_5	VARCHAR(22),
		Status_1_6	VARCHAR(22),
		Status_2_6	VARCHAR(22),
		Status_3_6	VARCHAR(22),
		Status_4_6	VARCHAR(22),
		Status_5_6	VARCHAR(22),
		Status_6_6	VARCHAR(22),
		Status_1_7	VARCHAR(22),
		Status_2_7	VARCHAR(22),
		Status_3_7	VARCHAR(22),
		Status_4_7	VARCHAR(22),
		Status_5_7	VARCHAR(22),
		Status_6_7	VARCHAR(22),
		Status_1_8	VARCHAR(22),
		Status_2_8	VARCHAR(22),
		Status_3_8	VARCHAR(22),
		Status_4_8	VARCHAR(22),
		Status_5_8	VARCHAR(22),
		Status_6_8	VARCHAR(22),
		Status_1_9	VARCHAR(22),
		Status_2_9	VARCHAR(22),
		Status_3_9	VARCHAR(22),
		Status_4_9	VARCHAR(22),
		Status_5_9	VARCHAR(22),
		Status_6_9	VARCHAR(22),
		Status_1_10	VARCHAR(22),
		Status_2_10	VARCHAR(22),
		Status_3_10	VARCHAR(22),
		Status_4_10	VARCHAR(22),
		Status_5_10	VARCHAR(22),
		Status_6_10	VARCHAR(22),
		Status_1_11	VARCHAR(22),
		Status_2_11	VARCHAR(22),
		Status_3_11	VARCHAR(22),
		Status_4_11	VARCHAR(22),
		Status_5_11	VARCHAR(22),
		Status_6_11	VARCHAR(22),
		Status_1_12	VARCHAR(22),
		Status_2_12	VARCHAR(22),
		Status_3_12	VARCHAR(22),
		Status_4_12	VARCHAR(22),
		Status_5_12	VARCHAR(22),
		Status_6_12	VARCHAR(22),
		Status_1_13	VARCHAR(22),
		Status_2_13	VARCHAR(22),
		Status_3_13	VARCHAR(22),
		Status_4_13	VARCHAR(22),
		Status_5_13	VARCHAR(22),
		Status_6_13	VARCHAR(22),
		Status_1_14	VARCHAR(22),
		Status_2_14	VARCHAR(22),
		Status_3_14	VARCHAR(22),
		Status_4_14	VARCHAR(22),
		Status_5_14	VARCHAR(22),
		Status_6_14	VARCHAR(22),
		Status_1_15	VARCHAR(22),
		Status_2_15	VARCHAR(22),
		Status_3_15	VARCHAR(22),
		Status_4_15	VARCHAR(22),
		Status_5_15	VARCHAR(22),
		Status_6_15	VARCHAR(22),
		Status_1_16	VARCHAR(22),
		Status_2_16	VARCHAR(22),
		Status_3_16	VARCHAR(22),
		Status_4_16	VARCHAR(22),
		Status_5_16	VARCHAR(22),
		Status_6_16	VARCHAR(22),
		Status_1_17	VARCHAR(22),
		Status_2_17	VARCHAR(22),
		Status_3_17	VARCHAR(22),
		Status_4_17	VARCHAR(22),
		Status_5_17	VARCHAR(22),
		Status_6_17	VARCHAR(22),
		Status_1_18	VARCHAR(22),
		Status_2_18	VARCHAR(22),
		Status_3_18	VARCHAR(22),
		Status_4_18	VARCHAR(22),
		Status_5_18	VARCHAR(22),
		Status_6_18	VARCHAR(22),
		Status_1_19	VARCHAR(22),
		Status_2_19	VARCHAR(22),
		Status_3_19	VARCHAR(22),
		Status_4_19	VARCHAR(22),
		Status_5_19	VARCHAR(22),
		Status_6_19	VARCHAR(22),
		Status_1_20	VARCHAR(22),
		Status_2_20	VARCHAR(22),
		Status_3_20	VARCHAR(22),
		Status_4_20	VARCHAR(22),
		Status_5_20	VARCHAR(22),
		Status_6_20	VARCHAR(22),
		Status_1_21	VARCHAR(22),
		Status_2_21	VARCHAR(22),
		Status_3_21	VARCHAR(22),
		Status_4_21	VARCHAR(22),
		Status_5_21	VARCHAR(22),
		Status_6_21	VARCHAR(22),
		Status_1_22	VARCHAR(22),
		Status_2_22	VARCHAR(22),
		Status_3_22	VARCHAR(22),
		Status_4_22	VARCHAR(22),
		Status_5_22	VARCHAR(22),
		Status_6_22	VARCHAR(22),
		Status_1_23	VARCHAR(22),
		Status_2_23	VARCHAR(22),
		Status_3_23	VARCHAR(22),
		Status_4_23	VARCHAR(22),
		Status_5_23	VARCHAR(22),
		Status_6_23	VARCHAR(22),
		Status_1_24	VARCHAR(22),
		Status_2_24	VARCHAR(22),
		Status_3_24	VARCHAR(22),
		Status_4_24	VARCHAR(22),
		Status_5_24	VARCHAR(22),
		Status_6_24	VARCHAR(22),
		Status_1_25	VARCHAR(22),
		Status_2_25	VARCHAR(22),
		Status_3_25	VARCHAR(22),
		Status_4_25	VARCHAR(22),
		Status_5_25	VARCHAR(22),
		Status_6_25	VARCHAR(22),
		Status_1_26	VARCHAR(22),
		Status_2_26	VARCHAR(22),
		Status_3_26	VARCHAR(22),
		Status_4_26	VARCHAR(22),
		Status_5_26	VARCHAR(22),
		Status_6_26	VARCHAR(22),
		Status_1_27	VARCHAR(22),
		Status_2_27	VARCHAR(22),
		Status_3_27	VARCHAR(22),
		Status_4_27	VARCHAR(22),
		Status_5_27	VARCHAR(22),
		Status_6_27	VARCHAR(22),
		Status_1_28	VARCHAR(22),
		Status_2_28	VARCHAR(22),
		Status_3_28	VARCHAR(22),
		Status_4_28	VARCHAR(22),
		Status_5_28	VARCHAR(22),
		Status_6_28	VARCHAR(22),
		Status_1_29	VARCHAR(22),
		Status_2_29	VARCHAR(22),
		Status_3_29	VARCHAR(22),
		Status_4_29	VARCHAR(22),
		Status_5_29	VARCHAR(22),
		Status_6_29	VARCHAR(22),
		Status_1_30	VARCHAR(22),
		Status_2_30	VARCHAR(22),
		Status_3_30	VARCHAR(22),
		Status_4_30	VARCHAR(22),
		Status_5_30	VARCHAR(22),
		Status_6_30	VARCHAR(22),
		Status_1_31	VARCHAR(22),
		Status_2_31	VARCHAR(22),
		Status_3_31	VARCHAR(22),
		Status_4_31	VARCHAR(22),
		Status_5_31	VARCHAR(22),
		Status_6_31	VARCHAR(22)
	)
	 	
	CREATE TABLE #Att_Detail
	(
		Emp_ID NUMERIC(18,0),
		Total_P_Days NUMERIC(18,2),
		OT_Hour VARCHAR(20),
		PL NUMERIC(18,2) default 0,
		CL NUMERIC(18,2) default 0,
		SL NUMERIC(18,2) default 0,
		LWP NUMERIC(18,2) default 0,
		Lunch NUMERIC(18,0),
		Advance NUMERIC(22,0),
		H_Days NUMERIC(18,2),
		Weekoff_OT_Hour VARCHAR(10),
		Holiday_OT_Hour VARCHAR(10)	 
	)
	 
	INSERT INTO #Att_Muster (Emp_ID,Cmp_ID,For_Date)
	SELECT 	Emp_ID ,@Cmp_ID ,@From_date FROM #Emp_Cons

	CREATE TABLE #Data_Weekoff           
	(           
		Emp_Id  NUMERIC ,     
		W_Days  NUMERIC(18,1)  
	)    
	
	
	CREATE TABLE #Data_MOTIF           
	(           
		Emp_Id   NUMERIC ,     
		For_date DATETIME,          
		P_days  NUMERIC(12,2) default 0,          --change by jimit ON 23092016 the length of p_days FROM (18,1) to (18,2)
		OT_Hour  VARCHAR(22),
		Weekoff_OT_Hour NUMERIC(18,2),
		Holiday_OT_Hour NUMERIC(18,2)		    
	)          	
	
 	EXEC SP_CALCULATE_PRESENT_DAYS @Cmp_ID=@Cmp_ID,@From_Date=@From_Date,@To_Date=@To_Date,@Branch_ID=@Branch_ID,@Cat_ID=@Cat_ID,@Grd_ID=@Grd_ID,@Type_ID=@Type_ID,@Dept_ID=@Dept_ID,@Desig_ID=@Desig_ID,@Emp_ID=@Emp_ID,@Constraint=@constraint,@Return_Record_set=5
 	
	
	
 	DECLARE @COLS  VARCHAR(MAX);	
 	
 	CREATE TABLE #DATES(ROW_ID INT, FOR_DATE DATETIME);		
		
	INSERT	INTO #DATES
	SELECT	T.ROW_ID +1,DATEADD(d, ROW_ID, @From_date)
	FROM	(SELECT (ROW_NUMBER() OVER (ORDER BY OBJECT_ID) -1) AS ROW_ID
				FROM sys.objects) T
	WHERE	DATEADD(d, ROW_ID, @From_Date) <= @To_Date
 	
	--Added by Jaina 18-11-2016 Start
	CREATE TABLE #Data      
	(     
		Emp_Id     NUMERIC ,     
		For_date   DATETIME,    
		Duration_in_sec  NUMERIC,    
		Shift_ID   NUMERIC ,    
		Shift_Type   NUMERIC ,    
		Emp_OT    NUMERIC ,    
		Emp_OT_min_Limit NUMERIC,    
		Emp_OT_max_Limit NUMERIC,    
		P_days    NUMERIC(12,2) default 0,    
		OT_Sec    NUMERIC default 0,
		In_Time DATETIME default null,
		Shift_Start_Time DATETIME default null,
		OT_Start_Time NUMERIC default 0,
		Shift_Change tinyint default 0 ,
		Flag Int Default 0  ,
		Weekoff_OT_Sec  NUMERIC default 0,
		Holiday_OT_Sec  NUMERIC default 0,
		Chk_By_Superior NUMERIC default 0,
		IO_Tran_Id	   NUMERIC default 0,
		Out_time DATETIME default null,
		Shift_END_Time DATETIME,			--Ankit 16112013
		OT_END_Time NUMERIC default 0,	--Ankit 16112013
		Working_Hrs_St_Time tinyint default 0, --Hardik 14/02/2014
		Working_Hrs_END_Time tinyint default 0, --Hardik 14/02/2014
		GatePass_Deduct_Days NUMERIC(18,2) default 0 -- Add by Gadriwala Muslim 05012014
	)  
	CREATE NONCLUSTERED INDEX IX_Data ON dbo.#data(Emp_Id,Shift_ID,For_Date) 
	
	EXEC dbo.P_GET_EMP_INOUT @cmp_id, @From_Date, @To_Date	 	
	--Added by Jaina 18-11-2016 END
	
	
 	UPDATE	#Att_Detail
	SET		Advance = Q.Adv_closing
	FROM	#Att_Detail AD 
			INNER JOIN (SELECT	ROUND(IsNull(Adv_closing,0),0) AS Adv_closing,Emp_ID 
						FROM	T0140_Advance_Transaction WITH (NOLOCK)
						WHERE	Cmp_ID = @Cmp_ID AND For_Date = (SELECT	MAX(for_date) 
																 FROM	T0140_Advance_Transaction WITH (NOLOCK)
																 WHERE  Cmp_ID = @Cmp_ID AND for_date <=  @To_Date
																 ) 
						GROUP BY Adv_closing ,Emp_ID 
			)Q ON AD.Emp_ID = Q.Emp_ID 
			 
	
	Update	#Att_Detail
	SET		LWP = Q.LeavE_Used
	FROM	#Att_Detail AD 
			INNER JOIN (SELECT	Emp_ID,SUM(LeavE_Used) AS LeavE_Used,Leave_Paid_Unpaid,Leave_Code  
						FROM	T0140_leave_Transaction LT WITH (NOLOCK)
								INNER JOIN T0040_Leave_Master LM WITH (NOLOCK) ON LT.Leave_ID = LM.Leave_ID
						WHERE	For_Date >=@From_Date AND For_Date <=@To_date
						GROUP BY Emp_ID,LT.Leave_ID,Leave_Type,Leave_Paid_Unpaid,Leave_Code
						)Q ON AD.Emp_ID =Q.emp_ID AND Q.Leave_Code='LWP'
	 	
	UPDATE	#Att_Detail
	SET		PL = Q.LeavE_Used
	FROM	#Att_Detail AD 
			INNER JOIN (SELECT	Emp_ID,SUM(LeavE_Used) AS LeavE_Used,Leave_Paid_Unpaid,Leave_Code  
						FROM	T0140_leave_Transaction LT WITH (NOLOCK)
								INNER JOIN T0040_Leave_Master LM WITH (NOLOCK) ON LT.Leave_ID = LM.Leave_ID
						WHERE	For_Date >=@From_Date AND For_Date <=@To_date
						GROUP BY Emp_ID,LT.Leave_ID,Leave_Type,Leave_Paid_Unpaid,Leave_Code
						)Q ON AD.Emp_ID = Q.emp_ID AND Q.Leave_Code='PL'
		
	UPDATE	#Att_Detail
	SET		CL = Q.LeavE_Used
	FROM	#Att_Detail AD 
			INNER JOIN (SELECT	Emp_ID,SUM(LeavE_Used) AS LeavE_Used,Leave_Paid_Unpaid,Leave_Code  
						FROM	T0140_leave_Transaction LT WITH (NOLOCK)
								INNER JOIN T0040_Leave_Master LM WITH (NOLOCK) ON LT.Leave_ID = LM.Leave_ID
						WHERE	For_Date >=@From_Date AND For_Date <=@To_date
						GROUP BY Emp_ID,LT.Leave_ID,Leave_Type,Leave_Paid_Unpaid,Leave_Code
						)Q ON AD.Emp_ID = Q.emp_ID AND Q.Leave_Code='CL'
		
	UPDATE	#Att_Detail
	SET		SL = Q.LeavE_Used
	FROM	#Att_Detail AD 
			INNER JOIN (SELECT	Emp_ID,SUM(LeavE_Used) AS LeavE_Used,Leave_Paid_Unpaid,Leave_Code  
						FROM	T0140_leave_Transaction LT WITH (NOLOCK)
								INNER JOIN T0040_Leave_Master LM WITH (NOLOCK) ON LT.Leave_ID = LM.Leave_ID
						WHERE	For_Date >=@From_Date AND For_Date <=@To_date
						GROUP BY Emp_ID,LT.Leave_ID,Leave_Type,Leave_Paid_Unpaid,Leave_Code
						)Q ON AD.Emp_ID = Q.emp_ID AND Q.Leave_Code='SL'
		 
     
	DECLARE @Temp_Date DATETIME
	DECLARE @count NUMERIC 
	
				
	DECLARE @QUERY AS VARCHAR(MAX); --ADDED AND CHANGED BY SUMIT ON 27102016
	SET @QUERY='';
		
	SET @Temp_Date = @From_Date 
	SET @count = 1 
	WHILE @Temp_Date <= @To_Date 
		BEGIN
			SET @QUERY='';
				
			--Added by Jaina 18-11-2016
				
			SET @QUERY +='UPDATE #ATT_MUSTER
							SET STATUS_1_'+ CAST(@COUNT AS VARCHAR(20)) +' =  DBO.F_RETURN_HHMM(IN_TIME) 
								,STATUS_2_'+ CAST(@COUNT AS VARCHAR(20)) +' =  DBO.F_RETURN_HHMM(OUT_TIME) 
								FROM #ATT_MUSTER AM INNER JOIN 
							( SELECT IN_TIME,OUT_TIME ,EMP_ID,FOR_DATE FROM #Data D
									WHERE FOR_DATE ='''+ CAST(@TEMP_DATE AS VARCHAR(50))+''' 
							)Q ON AM.EMP_ID =Q.EMP_ID
							INNER JOIN #Emp_Cons E ON E.Emp_ID=Q.Emp_ID;'
								
								
			SET @QUERY +='UPDATE #ATT_MUSTER
							SET STATUS_4_'+ CAST(@COUNT AS VARCHAR(20)) +' =  Q.DURATION
							FROM #ATT_MUSTER AM INNER JOIN 
							( SELECT EMP_ID,FOR_DATE,DURATION FROM T0150_EMP_INOUT_RECORD WITH (NOLOCK)
								WHERE CMP_ID = '+ CAST(@CMP_ID AS VARCHAR(100))+' AND FOR_DATE>='''+ CAST(@TEMP_DATE AS VARCHAR(50))+''' AND FOR_DATE <='''+ CAST(@TEMP_DATE AS VARCHAR(50))+'''
								GROUP BY EMP_ID ,FOR_DATE ,DURATION
							)Q ON AM.EMP_ID =Q.EMP_ID
							INNER JOIN #Emp_Cons E ON E.Emp_ID=Q.Emp_ID ;'
							
			SET @QUERY +='UPDATE  #ATT_MUSTER
							SET STATUS_5_'+ CAST(@COUNT AS VARCHAR(20)) +' =M.OT_HOUR
							,STATUS_6_'+ CAST(@COUNT AS VARCHAR(20)) +' = M.P_DAYS
							FROM #ATT_MUSTER AM INNER JOIN 
							( SELECT P_DAYS,(OT_HOUR + WEEKOFF_OT_HOUR + HOLIDAY_OT_HOUR) AS OT_HOUR,For_Date,EMP_ID FROM #DATA_MOTIF
								WHERE  FOR_DATE='''+ CAST(@TEMP_DATE AS VARCHAR(50))+'''
							)M ON AM.EMP_ID =M.EMP_ID 
							INNER JOIN #Emp_Cons E ON E.Emp_ID=M.Emp_ID ;'
								
								
			EXEC(@QUERY);

			SET @QUERY =	'UPDATE	AM
							SET		STATUS_1_'+ CAST(@COUNT AS VARCHAR(20)) +' = ''-'' 
							FROM	#ATT_MUSTER AM 
									INNER JOIN T0080_EMP_MASTER EM ON AM.EMP_ID = EM.EMP_ID									
									INNER JOIN #Emp_Cons E ON E.Emp_ID=EM.Emp_ID 
							WHERE	EM.EMP_LEFT_DATE IS NOT NULL AND EM.EMP_LEFT_DATE > ''' + CAST(@TEMP_DATE AS VARCHAR(50))+''';'
			EXEC(@QUERY);				
			
			SET @Temp_Date = dateadd(d,1,@Temp_date)				
			SET @count = @count + 1  
		END
		
	--Added by Jaina 17-11-2017
	if @Comp_OD_As_Present = 1
		BEGIN
			UPDATE	A
			SET		Total_P_Days =cast(Round(A.Total_P_Days + Isnull(Q1.OD_Compoff,0),2) as numeric(18,2)) --Q.P_DAYS + ISNULL(Q1.OD_COMPOFF,0)
			FROM	#Att_Detail A 	
					LEFT OUTER JOIN (select	sum((IsNull(LT.CompOff_Used,0) + IsNull(LT.Leave_Used,0)) * CASE WHEN LM.Apply_Hourly = 1 THEN 0.125 ELSE 1 END)  AS OD_Compoff,lt.Emp_ID
									 from	T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)
											INNER JOIN  T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LT.Leave_ID=LM.Leave_ID						
									 where	(Leave_Type='Company Purpose' OR Leave_Code = 'COMP') and LT.Cmp_ID=@Cmp_ID
											AND LT.FOR_DATE BETWEEN @FROM_DATE AND @TO_dATE
									 group by Emp_ID
									)Q1 on A.Emp_ID = Q1.Emp_ID 
		END
	
	--DECLARE @Emp_ID_H NUMERIC(18,0)	
	--DECLARE @Holiday_days NUMERIC(18,1)
	--DECLARE @Weekoff_days NUMERIC(18,1)
	--DECLARE @Branch_ID_T NUMERIC(18,0)
	--DECLARE @Test NUMERIC(18,0)
	--DECLARE @StrHoliday_Date AS VARCHAR(500)
	----DECLARE @StrWeekoff_Date  VARCHAR(1000)
	--DECLARE @varWeekOff_Date VARCHAR(1000)
	--SET @varWeekOff_Date = ''
	--SET @StrHoliday_Date = ''

	--DECLARE curH_Days cursor for                  
	--SELECT Emp_ID FROM #Att_Detail ORDER BY Emp_ID
	--open curH_Days                      
	-- fetch next FROM curH_Days into @Emp_ID_H
	--  WHILE @@fetch_status = 0                    
	--   BEGIN   
	--		--SELECT @Branch_ID_T = Branch_ID FROM t0095_increment WHERE Increment_ID in (SELECT MAX(Increment_ID) FROM t0095_increment WHERE Emp_ID=@Emp_ID)
	--		--EXEC SP_EMP_WEEKOFF_DATE_GET @Emp_ID_H,@Cmp_ID,@From_Date,@To_Date,null,null,@Is_Cancel_weekoff,@StrHoliday_Date,@varWeekOff_Date output,0,0,0 
	--		--EXEC SP_EMP_HOLIDAY_DATE_GET @Emp_ID_H,@Cmp_ID,@From_Date,@To_Date,null,null,@Is_Cancel_Holiday,@StrHoliday_Date output,@Holiday_days output,0,0,@Branch_ID,@varWeekOff_Date		
	--		--Update #Att_Detail SET H_Days = @Holiday_days WHERE Emp_ID=@Emp_ID_H		
		
	--		DECLARE @EMP_LEFT_DATE DATETIME
	--		SELECT	@EMP_LEFT_DATE = Emp_Left_Date FROM T0080_EMP_MASTER WHERE EMP_ID=@Emp_ID_H
	
	--		IF (@EMP_LEFT_DATE >= @FROM_DATE AND @EMP_LEFT_DATE <= @TO_DATE)
	--			BEGIN
	--				SET		@COLS = NULL;
	--				SELECT	@COLS  = COALESCE(@COLS  + ',', '')  + 
	--								'Status_1_' +  CAST(D.ROW_ID AS VARCHAR(5)) + ' = ''-'' ' 
	--				FROM	#DATES D 
	--				WHERE	D.FOR_DATE > @EMP_LEFT_DATE
				
	--				SET @QUERY = 'UPDATE #Att_Muster SET ' + @COLS + ' WHERE Emp_ID=' + CAST(@Emp_ID_H AS VARCHAR(10))	
	--				EXECUTE(@QUERY);
	--			END --Added by Sumit ON 27102016
		
		
	--   fetch next FROM curH_Days into @Emp_ID_H
	--   END                    
	-- close curH_Days                    
	-- deallocate curH_Days 
 
	/*************************************************************************
	Added by Nimesh: 17/Nov/2015 
	(To get holiday/weekoff data for all employees in seperate table)
	*************************************************************************/
	IF OBJECT_ID('tempdb..#EMP_HOLIDAY') IS NULL
		BEGIN
			CREATE TABLE #EMP_HOLIDAY(EMP_ID NUMERIC, FOR_DATE DATETIME, IS_CANCEL BIT, Is_Half tinyint, Is_P_Comp tinyint, H_DAY numeric(4,1));
			CREATE UNIQUE CLUSTERED INDEX IX_EMP_HOLIDAY_EMPID_FORDATE ON #EMP_HOLIDAY(EMP_ID, FOR_DATE);
			
			EXEC SP_GET_HW_ALL @CONSTRAINT=@CONSTRAINT,@CMP_ID=@Cmp_ID, @FROM_DATE=@FROM_DATE, @TO_DATE=@TO_DATE, @All_Weekoff = 0, @Exec_Mode=2	
		END
	
	UPDATE	A
	SET		H_Days = H.H_DAYS			
	FROM	#Att_Detail A
			INNER JOIN  (SELECT EMP_ID, COUNT(1) H_DAYS 
						 FROM	#EMP_HOLIDAY H WHERE H.IS_CANCEL=0 
						 GROUP BY Emp_ID) H ON H.EMP_ID=A.Emp_ID


	UPDATE	#Att_Detail
	SET		Lunch = Amount
	FROM	#Att_Detail AM 
			INNER JOIN (SELECT	Emp_ID,IsNull(Amount,0) AS Amount,Ad_Sort_NAME 
						FROM	T0190_Monthly_AD_Detail_Import MAD WITH (NOLOCK)
								INNER JOIN T0050_AD_MASTER Ma WITH (NOLOCK) ON MAD.Ad_ID=Ma.Ad_ID
						WHERE	MAD.Cmp_ID = @cmp_ID AND Ad_Sort_name='LD' AND Month(@From_Date)=MAD.Month AND Year(@From_Date)=MAD.Year
						GROUP BY Emp_ID,Amount,Ad_Sort_NAME )Q ON Am.Emp_ID =q.emp_ID  


	SELECT	AM.* ,AD.*, E.Emp_code,E.Alpha_Emp_Code,E.Emp_First_Name,CAST(E.Alpha_Emp_Code AS varchar) +' - '+ E.Emp_full_NAME AS Emp_full_Name,Branch_Address,Comp_Name,
			Branch_NAME , Dept_NAME ,Grd_Name,Desig_Name,TM.[Type_Name],Cmp_Name,Cmp_Address,@From_Date AS P_From_date ,@To_Date AS P_To_Date,
			CAST(REPLACE(AD.Ot_Hour,':','.') AS NUMERIC(18,2))/6 AS Test,DW.W_Days,E.Enroll_No,TM.Type_Name,IsNull(DM.Dept_Dis_no,0) AS Dept_Dis_no,
			DGM.Desig_Dis_No,VS.Vertical_Name,SV.SubVertical_NAME 
	FROM	#Att_Muster  AM 
			LEFT OUTER JOIN #Att_Detail AD ON AM.Emp_ID=AD.Emp_ID
			INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON AM.EMP_ID = E.EMP_ID
			INNER JOIN #Emp_Cons EC ON E.Emp_ID=EC.Emp_ID
			INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON I.Increment_ID = EC.Increment_ID 
			INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON I.Grd_Id = gm.Grd_ID 
			INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I.BRANCH_ID = BM.BRANCH_ID 
			LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I.DEPT_ID = DM.DEPT_ID 
			LEFT OUTER JOIN T0040_TYPE_MASTER TM WITH (NOLOCK) ON I.type_id = TM.Type_id 
			LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I.DESIG_ID = DGM.DESIG_ID 
			INNER JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.CMP_ID = CM.CMP_id 
			LEFT OUTER JOIN #Data_Weekoff DW ON AM.Emp_ID=DW.Emp_ID		
			LEFT outer JOIN T0040_Vertical_Segment VS	WITH (NOLOCK) On Vs.Vertical_ID = I.vertical_Id 
			LEFT OUTER JOIN T0050_SubVertical SV WITH (NOLOCK) ON sv.SubVertical_ID = I.SubVertical_ID
	ORDER BY CASE WHEN IsNumeric(E.Alpha_Emp_Code) = 1 then RIGHT(REPLICATE('0',21) + E.Alpha_Emp_Code, 20)
			WHEN IsNumeric(E.Alpha_Emp_Code) = 0 then LEFT(E.Alpha_Emp_Code + REPLICATE('',21), 20)
				Else E.Alpha_Emp_Code
			END
RETURN




