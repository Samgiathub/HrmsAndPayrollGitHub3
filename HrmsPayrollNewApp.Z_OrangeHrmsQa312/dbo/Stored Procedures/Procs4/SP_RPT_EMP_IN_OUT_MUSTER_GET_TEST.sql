


CREATE PROCEDURE [dbo].[SP_RPT_EMP_IN_OUT_MUSTER_GET_TEST]
	 @Cmp_ID 		numeric
	,@From_Date		datetime
	,@To_Date 		datetime
	,@Branch_ID		numeric
	,@Cat_ID 		numeric 
	,@Grd_ID 		numeric
	,@Type_ID 		numeric
	,@Dept_ID 		numeric
	,@Desig_ID 		numeric
	,@Emp_ID 		numeric
	,@constraint 	varchar(MAX)
	,@Report_For	varchar(10)
AS
	SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON

	
	IF @Branch_ID = 0  
		set @Branch_ID = null
		
	IF @Cat_ID = 0  
		set @Cat_ID = null

	IF @Grd_ID = 0  
		set @Grd_ID = null

	IF @Type_ID = 0  
		set @Type_ID = null

	IF @Dept_ID = 0  
		set @Dept_ID = null

	IF @Desig_ID = 0  
		set @Desig_ID = null

	IF @Emp_ID = 0  
		set @Emp_ID = null


	CREATE table #Emp_Cons 
	 (      
	   Emp_ID numeric ,     
	   Branch_ID numeric,
	   Increment_ID numeric    
	 )      	 
	EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,0 ,0 ,0 ,0 ,0 ,0
	
	
	declare @For_Date datetime 
	Declare @Date_Diff numeric 
	Declare @New_To_Date datetime 
	
	
	set @Date_Diff = datediff(d,@From_Date,@to_DAte) + 1 
	set @Date_Diff = 35 - ( @Date_Diff)
	set @New_To_Date = @To_Date --dateadd(d,@date_diff,@To_Date)
	
	if	exists (select 1 from [tempdb].dbo.sysobjects where name like '#Att_Muster' )		
			begin
				drop table #Att_Muster
			end
	
	CREATE table #Status(Status_Idx int);
	
	INSERT INTO #Status Values(1);
	INSERT INTO #Status Values(2);
	INSERT INTO #Status Values(3);
	
		
	 CREATE table #Att_Muster 
	  (
			Emp_Id		numeric, 
			Branch_ID	numeric,
			Increment_ID numeric,
			Cmp_ID		numeric,
			For_Date	datetime,
			Leave_Count	numeric(5,1),
			WO_COHO		varchar(4) DEFAULT ('AB'),
			Status_1_1	varchar(22),
			Status_2_1	varchar(22),
			Status_3_1	varchar(22) DEFAULT ('AB'),
			Status_1_2	varchar(22),
			Status_2_2	varchar(22),
			Status_3_2	varchar(22) DEFAULT ('AB'),
			Status_1_3	varchar(22),
			Status_2_3	varchar(22),
			Status_3_3	varchar(22) DEFAULT ('AB'),
			Status_1_4	varchar(22),
			Status_2_4	varchar(22),
			Status_3_4	varchar(22) DEFAULT ('AB'),
			Status_1_5	varchar(22),
			Status_2_5	varchar(22),
			Status_3_5	varchar(22) DEFAULT ('AB'),
			Status_1_6	varchar(22),
			Status_2_6	varchar(22),
			Status_3_6	varchar(22) DEFAULT ('AB'),
			Status_1_7	varchar(22),
			Status_2_7	varchar(22),
			Status_3_7	varchar(22) DEFAULT ('AB'),
			Status_1_8	varchar(22),
			Status_2_8	varchar(22),
			Status_3_8	varchar(22) DEFAULT ('AB'),
			Status_1_9	varchar(22),
			Status_2_9	varchar(22),
			Status_3_9	varchar(22) DEFAULT ('AB'),
			Status_1_10	varchar(22),
			Status_2_10	varchar(22),
			Status_3_10	varchar(22) DEFAULT ('AB'),
			Status_1_11	varchar(22),
			Status_2_11	varchar(22),
			Status_3_11	varchar(22) DEFAULT ('AB'),
			Status_1_12	varchar(22),
			Status_2_12	varchar(22),
			Status_3_12	varchar(22) DEFAULT ('AB'),
			Status_1_13	varchar(22),
			Status_2_13	varchar(22),
			Status_3_13	varchar(22) DEFAULT ('AB'),
			Status_1_14	varchar(22),
			Status_2_14	varchar(22),
			Status_3_14	varchar(22) DEFAULT ('AB'),
			Status_1_15	varchar(22),
			Status_2_15	varchar(22),
			Status_3_15	varchar(22) DEFAULT ('AB'),
			Status_1_16	varchar(22),
			Status_2_16	varchar(22),
			Status_3_16	varchar(22) DEFAULT ('AB'),
			Status_1_17	varchar(22),
			Status_2_17	varchar(22),
			Status_3_17	varchar(22) DEFAULT ('AB'),
			Status_1_18	varchar(22),
			Status_2_18	varchar(22),
			Status_3_18	varchar(22) DEFAULT ('AB'),
			Status_1_19	varchar(22),
			Status_2_19	varchar(22),
			Status_3_19	varchar(22) DEFAULT ('AB'),
			Status_1_20	varchar(22),
			Status_2_20	varchar(22),
			Status_3_20	varchar(22) DEFAULT ('AB'),
			Status_1_21	varchar(22),
			Status_2_21	varchar(22),
			Status_3_21	varchar(22) DEFAULT ('AB'),
			Status_1_22	varchar(22),
			Status_2_22	varchar(22),
			Status_3_22	varchar(22) DEFAULT ('AB'),
			Status_1_23	varchar(22),
			Status_2_23	varchar(22),
			Status_3_23	varchar(22) DEFAULT ('AB'),
			Status_1_24	varchar(22),
			Status_2_24	varchar(22),
			Status_3_24	varchar(22) DEFAULT ('AB'),
			Status_1_25	varchar(22),
			Status_2_25	varchar(22),
			Status_3_25	varchar(22) DEFAULT ('AB'),
			Status_1_26	varchar(22),
			Status_2_26	varchar(22),
			Status_3_26	varchar(22) DEFAULT ('AB'),
			Status_1_27	varchar(22),
			Status_2_27	varchar(22),
			Status_3_27	varchar(22) DEFAULT ('AB'),
			Status_1_28	varchar(22),
			Status_2_28	varchar(22),
			Status_3_28	varchar(22) DEFAULT ('AB'),
			Status_1_29	varchar(22),
			Status_2_29	varchar(22),
			Status_3_29	varchar(22) DEFAULT ('AB'),
			Status_1_30	varchar(22),
			Status_2_30	varchar(22),
			Status_3_30	varchar(22) DEFAULT ('AB'),
			Status_1_31	varchar(22),
			Status_2_31	varchar(22),
			Status_3_31	varchar(22) DEFAULT ('AB')
	  )
	  
	  
	  CREATE CLUSTERED INDEX IX_Att_Muster_Emp_ID on dbo.#Att_Muster(Emp_Id);

/*
	CREATE table #Emp_Holiday
	  (
			Emp_Id		numeric , 
			Cmp_ID		numeric,
			For_Date	datetime,
			H_Day		numeric(3,1),
			is_Half_day tinyint
	  )	   
	 CREATE CLUSTERED INDEX IX_Emp_Holiday_Emp_ID_ForDate on dbo.#Emp_Holiday(Emp_Id,For_Date);

	CREATE table #Emp_Weekoff
	  (
			Emp_Id		numeric , 
			Cmp_ID		numeric,
			For_Date	datetime,
			W_Day		numeric(3,1)
	  )	  
	 CREATE CLUSTERED INDEX IX_Emp_Weekoff_Emp_ID_ForDate on dbo.#Emp_Weekoff(Emp_Id,For_Date);
	  */
	  
	DECLARE @REQUIRED_EXEC BIT
	SET @REQUIRED_EXEC = 0;
	
	IF OBJECT_ID('tempdb..#Emp_WeekOff') IS NULL
		BEGIN
			CREATE table #Emp_WeekOff
			(
				Row_ID			NUMERIC,
				Emp_ID			NUMERIC,
				For_Date		DATETIME,
				Weekoff_day		VARCHAR(10),
				W_Day			numeric(3,1),
				Is_Cancel		BIT
			)
			CREATE CLUSTERED INDEX IX_Emp_WeekOff_EmpID_ForDate ON #Emp_WeekOff(Emp_ID, For_Date)		
			SET @REQUIRED_EXEC = 1;
		END
	
	IF OBJECT_ID('tempdb..#EMP_HOLIDAY') IS NULL
		BEGIN
			CREATE table #EMP_HOLIDAY(EMP_ID NUMERIC, FOR_DATE DATETIME, IS_CANCEL BIT, Is_Half tinyint, Is_P_Comp tinyint, H_DAY numeric(3,1));
			CREATE UNIQUE CLUSTERED INDEX IX_EMP_HOLIDAY_EMPID_FORDATE ON #EMP_HOLIDAY(EMP_ID, FOR_DATE);
			
			SET @REQUIRED_EXEC = 1;
		END
		
	IF @REQUIRED_EXEC = 1
	BEGIN
		EXEC SP_GET_HW_ALL @CONSTRAINT=@CONSTRAINT,@CMP_ID=@Cmp_ID, @FROM_DATE=@FROM_DATE, @TO_DATE=@TO_DATE, @All_Weekoff = 0, @Exec_Mode=0
	END
	  
	-- Added By Sajid 07-12-2023 Start
	IF GETDATE() < @TO_DATE
	UPDATE #Emp_WeekOff SET Is_Cancel=1, W_Day=0
	FROM #Emp_WeekOff EW where EW.For_Date between GETDATE() and @TO_DATE

	IF GETDATE() <@TO_DATE
	UPDATE #EMP_HOLIDAY SET Is_Cancel=1 
	FROM #EMP_HOLIDAY EH where EH.For_Date between GETDATE() and @TO_DATE
	-- Added By Sajid 07-12-2023  END

	Declare @Is_Cancel_Holiday  numeric(1,0)
	Declare @Is_Cancel_Weekoff	numeric(1,0)	
	Declare @strHoliday_Date As Varchar(max)
	Declare @StrWeekoff_Date  varchar(max)

	Set @StrHoliday_Date = ''      
	set @StrWeekoff_Date = ''


	insert into #Att_Muster (Emp_ID,Branch_ID,Increment_ID,Cmp_ID,For_Date)
	select 	Emp_ID, Branch_ID,Increment_ID,@Cmp_ID ,@From_date from #Emp_Cons
	
	
	
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

	EXEC dbo.P_GET_EMP_INOUT @CMP_ID, @FROM_DATE, @TO_DATE,1

	DECLARE @COLS  VARCHAR(MAX);		
	DECLARE @QUERY VARCHAR(MAX);
	
	Declare @Temp_Date datetime
	Declare @count numeric 
	Declare @OutRuchi AS DateTime
	Declare @tmp_InTime DateTime
	Declare @tmp_OutTime DateTime


	declare @status_1 varchar(100)
	declare @status_2 varchar(100)
	declare @status_3 varchar(100)
	declare @strQry nvarchar(max)	
	
	
	DECLARE @Previous_Branch_ID Numeric;
	SET @Previous_Branch_ID = 0;


		---Taken this condition from Cursor to above Cursor by Hardik 29/03/2016, As this condition giving error.
		CREATE table #DATES(ROW_ID INT, FOR_DATE DATETIME);
		
		INSERT INTO #DATES
		SELECT T.ROW_ID +1,DATEADD(d, ROW_ID, @From_date)
		FROM	(SELECT (ROW_NUMBER() OVER (ORDER BY OBJECT_ID) -1) AS ROW_ID
				 FROM sys.objects) T
		WHERE	DATEADD(d, ROW_ID, @From_Date) <= @To_Date
		
	
	Declare @Emp_Id_Cur As Numeric(18,0)
	Set @Emp_Id_Cur=0
	
	Declare @EMP_JOINING_DATE as DATETIMe

		--Added by Deepali-06132023-start
			
	Declare @curRetDate as datetime
	set @curRetDate = @From_Date
	Declare @RET_DAYS as Int
	 declare @strQry1 nvarchar(max)   
	set @RET_DAYS =0

    --Added by Deepali-06132023-End 

	Declare Att_Cursor  Cursor Fast_forward For 
		Select Emp_Id,Branch_ID From #Att_Muster 
		order by Branch_ID
	Open Att_Cursor
	Fetch Next From Att_Cursor INTO @Emp_Id_Cur,@Branch_ID
	while @@fetch_status = 0
	Begin 
		
		if (@Previous_Branch_ID <> @Branch_ID)
		BEGIN			
			select	Top 1 @Is_Cancel_Holiday = isnull(Is_Cancel_Holiday,0)  ,@Is_Cancel_Weekoff = isnull(Is_Cancel_Weekoff,0)
			from	dbo.T0040_GENERAL_SETTING WITH (NOLOCK)
			where	cmp_ID = @cmp_ID	and Branch_ID = @Branch_ID
					and For_Date = ( select max(For_Date) from dbo.T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@To_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)			
		END

--SELECT COALESCE(@COLS  + ',', '')  + 
--	'Status_1_' +  Cast(D.ROW_ID As Varchar(5)) + ' = ''' + Cast(IsNull(T.In_Date, '') As Varchar(10)) + ''',  ' +
--	'Status_2_' +  Cast(D.ROW_ID As Varchar(5)) + ' = ''' + Cast(IsNull(T.Out_Date, '') As Varchar(10)) + ''', ' +
--	'Status_3_' +  Cast(D.ROW_ID As Varchar(5)) + CASE WHEN (T.In_Date IS NULL and T.OUT_DATE IS NULL AND T.EMP_LEFT_DATE IS NULL)
--	                                                       THEN ' = ''AB'' ' 
--	                                                    ELSE ' = NULL ' END , t.For_Date, t.Emp_Left_Date
--FROM 
--#DATES D LEFT OUTER JOIN
--				(				
--					SELECT DISTINCT eir.Emp_ID,EIR.Cmp_ID, EIR.for_Date,IsNull(dbo.F_Return_HHMM( In_Date),'') As In_Date
--							,IsNull(dbo.F_Return_HHMM( Case when Max_In_Date > Out_Date Then Max_In_Date Else Out_Date End), '') As Out_Date
--							,EM.EMP_LEFT_DATE
--					FROM	dbo.T0150_emp_inout_Record  EIR 
--					INNER JOIN #Emp_Cons Ec on EIR.Emp_Id = ec.Emp_ID 
--					INNER JOIN  T0080_EMP_MASTER EM on EIR.Emp_ID=EM.Emp_ID and EIR.Cmp_ID=EM.Cmp_ID 
--					INNER JOIN      
--								(
--									select I.Emp_ID,Emp_OT,isnull(Emp_OT_min_Limit,'00:00')Emp_OT_min_Limit,isnull(Emp_OT_max_Limit,'00:00')Emp_OT_max_Limit from dbo.T0095_Increment  I 
--									INNER JOIN         
--										(
--											select max(Increment_ID)Increment_ID ,Emp_ID from dbo.T0095_Increment         -- Ankit 12092014 for Same Date Increment
--											where increment_effective_Date <=@To_Date and Cmp_ID =@Cmp_ID  and Emp_ID = @Emp_Id_Cur 
--											group by Emp_ID
--										)q on I.emp_ID =q.Emp_ID and I.Increment_ID = q.Increment_ID 
--								 ) IQ on eir.Emp_ID =iq.emp_ID 
--					LEFT OUTER JOIN
--						(select Emp_Id, Min(In_Time) In_Date,For_Date From dbo.T0150_Emp_Inout_Record Where Emp_ID = @Emp_Id_Cur Group By Emp_Id,For_Date) Q1 on EIR.Emp_Id = Q1.Emp_Id 
--							And EIR.For_Date = Q1.For_Date
--					LEFT OUTER JOIN
--						(select Emp_Id, Max(Out_Time) Out_Date,For_Date From dbo.T0150_Emp_Inout_Record where  Emp_ID = @Emp_Id_Cur Group By Emp_Id,For_Date) Q2 on EIR.Emp_Id = Q2.Emp_Id 
--							And EIR.For_Date = Q2.For_Date
--					LEFT OUTER JOIN
--						--Added by Hardik 23/07/2012 for First IN And Last OUT (it will take Max In Punch as OUT and calculate Hours)
--						(select Emp_Id, Max(In_Time) Max_In_Date,For_Date From dbo.T0150_Emp_Inout_Record where  Emp_ID = @Emp_Id_Cur Group By Emp_Id,For_Date) Q4 on EIR.Emp_Id = Q4.Emp_Id  
--							And EIR.For_Date = Q4.For_Date
--					LEFT OUTER JOIN 
--						(Select Emp_ID,Chk_By_Superior Chk_By_Sup,For_Date from dbo.T0150_EMP_INOUT_RECORD where Chk_By_Superior=1 and Emp_ID = @Emp_Id_Cur) Q3 on EIR.Emp_Id = Q3.Emp_Id 
--							And EIR.For_Date = Q3.For_Date
--					Where	EIR.cmp_Id= @Cmp_ID and EIR.for_Date >=@From_Date and EIR.For_Date <=@To_Date  
--					and ec.Emp_ID = @Emp_Id_Cur and
--					EIR.For_Date<=isnull(EM.Emp_Left_Date,@To_Date)  --Added by Sumit on 22102016
--					group by eir.Emp_ID,eir.For_Date,OUT_Time,Max_In_Date,EIR.Cmp_ID,Q1.In_Date ,Q2.Out_Date , EMP_LEFT_DATE
				
--				) T ON D.For_Date=T.FOR_DATE
--		Order by D.ROW_ID
				
/*
		Exec dbo.SP_EMP_WEEKOFF_DATE_GET @Emp_Id_Cur,@Cmp_ID,@From_Date,@To_Date,null,null,@Is_Cancel_weekoff,@StrHoliday_Date,@StrWeekoff_Date output,0,0,1       
		--Exec dbo.SP_EMP_WEEKOFF_DATE_GET_ALL @Emp_Id_Cur,@Cmp_ID,@From_Date,@To_Date,null,null,@Is_Cancel_weekoff,@StrHoliday_Date,@StrWeekoff_Date output,0,0,1       
		Exec dbo.SP_EMP_HOLIDAY_DATE_GET @Emp_Id_Cur,@Cmp_ID,@From_Date,@To_Date,null,null,@Is_Cancel_Holiday,@StrHoliday_Date output,0,0,1,@Branch_ID,@StrWeekoff_Date  	 
		*/	
		--Set @Night_Shift = 0
		
		
	
/*
		--IN OUT
		SET		@COLS = NULL;
		SELECT @COLS  = COALESCE(@COLS  + ',', '')  + 
							'Status_1_' +  Cast(D.ROW_ID As Varchar(5)) + ' = ''' + Cast(IsNull(T.In_Date, '') As Varchar(10)) + ''',  ' +
							'Status_2_' +  Cast(D.ROW_ID As Varchar(5)) + ' = ''' + Cast(IsNull(T.Out_Date, '') As Varchar(10)) + ''', ' +
							'Status_3_' +  Cast(D.ROW_ID As Varchar(5)) + ' = ''-'' ' 
							--'Status_3_' +  Cast(D.ROW_ID As Varchar(5)) + CASE WHEN (T.In_Date IS NULL and T.OUT_DATE IS NULL AND T.EMP_LEFT_DATE IS NULL)
							--                                                       THEN ' = ''AB'' ' 
							--                                                    ELSE ' = NULL ' END
		FROM	#DATES D LEFT OUTER JOIN
				(				
					SELECT DISTINCT eir.Emp_ID,EIR.Cmp_ID, EIR.for_Date,IsNull(dbo.F_Return_HHMM( In_Date),'') As In_Date
							,IsNull(dbo.F_Return_HHMM( Case when Max_In_Date > Out_Date Then Max_In_Date Else Out_Date End), '') As Out_Date
							,EM.EMP_LEFT_DATE
					FROM	dbo.T0150_emp_inout_Record  EIR 
					INNER JOIN #Emp_Cons Ec on EIR.Emp_Id = ec.Emp_ID 
					INNER JOIN  T0080_EMP_MASTER EM on EIR.Emp_ID=EM.Emp_ID and EIR.Cmp_ID=EM.Cmp_ID 
					INNER JOIN      
								(
									select I.Emp_ID,Emp_OT,isnull(Emp_OT_min_Limit,'00:00')Emp_OT_min_Limit,isnull(Emp_OT_max_Limit,'00:00')Emp_OT_max_Limit from dbo.T0095_Increment  I 
									INNER JOIN         
										(
											select max(Increment_ID)Increment_ID ,Emp_ID from dbo.T0095_Increment         -- Ankit 12092014 for Same Date Increment
											where increment_effective_Date <=@To_Date and Cmp_ID =@Cmp_ID  and Emp_ID = @Emp_Id_Cur 
											group by Emp_ID
										)q on I.emp_ID =q.Emp_ID and I.Increment_ID = q.Increment_ID 
								 ) IQ on eir.Emp_ID =iq.emp_ID 
					LEFT OUTER JOIN
						(select Emp_Id, Min(In_Time) In_Date,For_Date From dbo.T0150_Emp_Inout_Record Where Emp_ID = @Emp_Id_Cur Group By Emp_Id,For_Date) Q1 on EIR.Emp_Id = Q1.Emp_Id 
							And EIR.For_Date = Q1.For_Date
					LEFT OUTER JOIN
						(select Emp_Id, Max(Out_Time) Out_Date,For_Date From dbo.T0150_Emp_Inout_Record where  Emp_ID = @Emp_Id_Cur Group By Emp_Id,For_Date) Q2 on EIR.Emp_Id = Q2.Emp_Id 
							And EIR.For_Date = Q2.For_Date
					LEFT OUTER JOIN
						--Added by Hardik 23/07/2012 for First IN And Last OUT (it will take Max In Punch as OUT and calculate Hours)
						(select Emp_Id, Max(In_Time) Max_In_Date,For_Date From dbo.T0150_Emp_Inout_Record where  Emp_ID = @Emp_Id_Cur Group By Emp_Id,For_Date) Q4 on EIR.Emp_Id = Q4.Emp_Id  
							And EIR.For_Date = Q4.For_Date
					LEFT OUTER JOIN 
						(Select Emp_ID,Chk_By_Superior Chk_By_Sup,For_Date from dbo.T0150_EMP_INOUT_RECORD where Chk_By_Superior=1 and Emp_ID = @Emp_Id_Cur) Q3 on EIR.Emp_Id = Q3.Emp_Id 
							And EIR.For_Date = Q3.For_Date
					Where	EIR.cmp_Id= @Cmp_ID and EIR.for_Date >=@From_Date and EIR.For_Date <=@To_Date  
					and ec.Emp_ID = @Emp_Id_Cur and
					EIR.For_Date<=isnull(EM.Emp_Left_Date,@To_Date)  --Added by Sumit on 22102016
					group by eir.Emp_ID,eir.For_Date,OUT_Time,Max_In_Date,EIR.Cmp_ID,Q1.In_Date ,Q2.Out_Date , EMP_LEFT_DATE
				
				) T ON D.For_Date=T.FOR_DATE
		Order by D.ROW_ID
			*/	
		
		--------------- Modify By Jignesh 11-Dec-2019----- For Date Wise Top 1 Record   ---
		/*
		SET		@COLS = NULL;
		SELECT @COLS  =  COALESCE(@COLS  + ',', '')  + 
							'Status_1_' +  Cast(D.ROW_ID As Varchar(5)) + ' = ''' + IsNull(Convert(Varchar(5),T.In_Time,108),'') + ''',  ' +
							'Status_2_' +  Cast(D.ROW_ID As Varchar(5)) + ' = ''' + IsNull(Convert(Varchar(5),T.Out_Time,108),'') + '' + (Case When EIR.ManualEntryFlag IN('I','O','IO','New') Then '#' Else '' END) +''', ' +
							'Status_3_' +  Cast(D.ROW_ID As Varchar(5)) + ' = Null ' 
		FROM    #Data T 
		INNER JOIN #DATES D ON T.FOR_DATE=D.FOR_DATE
		LEFT OUTER JOIN T0150_EMP_INOUT_RECORD EIR ON EIR.Emp_ID = T.EMP_ID and EIR.For_Date = T.FOR_DATE and (EIR.In_Time = T.In_Time OR EIR.Out_Time = T.Out_Time) 
			-- Added By Nilesh patel on 17062019 For High light Manual Punch
		WHERE	T.EMP_ID=@Emp_Id_Cur
		*/
		
		------------------- Add Jignesh 11-Dec-2019------------
		SET		@COLS = NULL;
		--SELECT @COLS  =  COALESCE(@COLS  + ',', '')  + 
		--					'Status_1_' +  Cast(T.ROW_ID As Varchar(5)) + ' = ''' + IsNull(Convert(Varchar(5),T.In_Time,108),'') + ''',  ' +
		--					'Status_2_' +  Cast(T.ROW_ID As Varchar(5)) + ' = ''' + IsNull(Convert(Varchar(5),T.Out_Time,108),'') + '' + (Case When T.ManualEntryFlag IN('I','O','IO','New') Then '#' Else '' END) +''', ' +
		--					'Status_3_' +  Cast(T.ROW_ID As Varchar(5)) + ' = Null ' 
		--From (
		
		--SELECT DISTINCT D.ROW_ID, A.EMP_ID ,A.For_Date,A.In_Time,A.Out_Time,EIR.ManualEntryFlag FROM #Data AS A 
		--INNER JOIN #DATES D ON A.FOR_DATE=D.FOR_DATE
		--LEFT OUTER JOIN  T0150_EMP_INOUT_RECORD  EIR WITH (NOLOCK) ON EIR.Emp_ID = A.EMP_ID and EIR.For_Date = A.FOR_DATE and (EIR.In_Time = A.In_Time OR EIR.Out_Time = A.Out_Time) 
		--WHERE	A.EMP_ID=@Emp_Id_Cur
		
		--) as T

		

		SELECT @COLS  =  COALESCE(@COLS  + ',', '')  + 
							'Status_1_' +  Cast(T.ROW_ID As Varchar(5)) + ' = ''' + IsNull(Convert(Varchar(5),T.In_Time,108),'') + ''',  ' +
							'Status_2_' +  Cast(T.ROW_ID As Varchar(5)) + ' = ''' + IsNull(Convert(Varchar(5),T.Out_Time,108),'') + '' + (Case When T.ManualEntryFlag IN('I','O','IO','New') Then '#' Else '' END) +''', ' +
							'Status_3_' +  Cast(T.ROW_ID As Varchar(5)) + ' = Null ' 
		From (		
			SELECT DISTINCT D.ROW_ID, A.EMP_ID ,A.For_Date,A.In_Time,A.Out_Time,EIR1.ManualEntryFlag,rn FROM #Data AS A 
			INNER JOIN #DATES D ON A.FOR_DATE=D.FOR_DATE
			--LEFT OUTER JOIN T0150_EMP_INOUT_RECORD EIR ON EIR.Emp_ID = A.EMP_ID and EIR.For_Date = A.FOR_DATE and (EIR.In_Time = A.In_Time OR EIR.Out_Time = A.Out_Time)
			LEFT OUTER JOIN
			(
				SELECT IO_Tran_Id,ROW_NUMBER() OVER (PARTITION BY EIR.For_Date ORDER BY ManualEntryFlag ASC) AS rn,In_Time,Out_Time,ManualEntryFlag,For_Date
				from T0150_EMP_INOUT_RECORD EIR
				WHERE Emp_ID = @Emp_Id_Cur and For_Date between @From_Date and @To_Date
			) EIR1 ON EIR1.For_Date = A.FOR_DATE and (EIR1.In_Time = A.In_Time OR EIR1.Out_Time = A.Out_Time) AND (rn = 1 )
		) T WHERE T.EMP_ID=@Emp_Id_Cur AND (rn = 1 )

		/*
		FROM    #Data T 
		INNER JOIN #DATES D ON T.FOR_DATE=D.FOR_DATE
		LEFT OUTER JOIN (Select Top 1  EMP_ID ,For_Date,In_Time,Out_Time,ManualEntryFlag From  T0150_EMP_INOUT_RECORD ) EIR ON EIR.Emp_ID = T.EMP_ID and EIR.For_Date = T.FOR_DATE and (EIR.In_Time = T.In_Time OR EIR.Out_Time = T.Out_Time) 
			-- Added By Nilesh patel on 17062019 For High light Manual Punch
		WHERE	T.EMP_ID=@Emp_Id_Cur
		*/
		------------------- End Jignesh 11-Dec-2019------------
		
		
		SET @QUERY = 'UPDATE #Att_Muster Set ' + @COLS + ' WHERE Emp_ID=' + Cast(@Emp_Id_Cur As Varchar(10))
		EXECUTE(@QUERY);
		
		
		
		DECLARE @EMP_LEFT_DATE datetime
		SELECT	@EMP_LEFT_DATE = Emp_Left_Date FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE EMP_ID=@Emp_Id_Cur
	
		IF (@EMP_LEFT_DATE >= @FROM_DATE AND @EMP_LEFT_DATE <= @TO_DATE)
			BEGIN
				SET		@COLS = NULL;
				SELECT	@COLS  = COALESCE(@COLS  + ',', '')  + 
								'Status_3_' +  Cast(D.ROW_ID As Varchar(5)) + ' = ''-'' ' 
				FROM	#DATES D 
				WHERE	D.FOR_DATE > @EMP_LEFT_DATE
				
				SET @QUERY = 'UPDATE #Att_Muster Set ' + @COLS + ' WHERE Emp_ID=' + Cast(@Emp_Id_Cur As Varchar(10))	
				EXECUTE(@QUERY);
			END
		
		--				Update #Att_Muster  ronakb
		--		set WO_HO = 'OHO',
		--			WO_HO_Day =eh.H_Day
		--		From #Att_Muster   AM inner join #Emp_Holiday eh on am.emp_ID = eh.emp_ID 
		--		and am.For_date =Eh.For_Date				
		--		inner join #EMP_WEEKOFF_HOLIDAY EWH on EWH.Emp_ID=EH.EMP_ID				
		--		where charindex(convert(varchar(11),AM.FOR_DATE,109),EWH.OptHolidayDate,0) > 0 
		--		and am.Emp_Id=ewh.Emp_ID --Added by Sumit on 9/11/2016 for 

		----Optional Holiday
		--SET		@COLS = NULL;
		--SELECT	@COLS  = COALESCE(@COLS  + ',', '')  + 'Status_3_' +  Cast(D.ROW_ID As Varchar(5)) + ' = ''OHO'' '							
		--FROM	(SELECT distinct For_Date,EMP_ID from #Emp_Holiday WHERE charindex(convert(varchar(11),D.FOR_DATE,109),EWH.OptHolidayDate,0) > 0 )  T  
		--		LEFT OUTER JOIN #Dates D ON T.FOR_DATE=D.For_Date
		--	    inner join T0080_EMP_MASTER E WITH (NOLOCK) on E.Emp_ID=T.EMP_ID 
		--		inner join #EMP_WEEKOFF_HOLIDAY EWH on EWH.Emp_ID=E.EMP_ID		
		--WHERE D.FOR_DATE <=ISNULL(E.Emp_Left_Date,D.FOR_DATE)

	
		
		SET		@QUERY = 'UPDATE #Att_Muster Set WO_COHO = ''OHO'', ' + @COLS + ' WHERE Emp_ID=' + Cast(@Emp_Id_Cur As Varchar(10))
		EXECUTE(@QUERY);

		--WEEK +\+7		
		SET		@COLS = NULL;
		SELECT	@COLS  = COALESCE(@COLS  + ',', '')  + 'Status_3_' +  Cast(D.ROW_ID As Varchar(5)) + ' = ''WO'' ' 							
		FROM	(SELECT distinct For_Date,Emp_ID from #Emp_Weekoff Where Emp_Id=@Emp_Id_Cur and Is_Cancel=0)  T  -- Added By Sajid 07-12-2023 -- Added Code and Is_Cancel=0
		LEFT OUTER JOIN #Dates D ON T.FOR_DATE=D.For_Date
				INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) on E.Emp_ID=T.Emp_ID
		WHERE D.FOR_DATE <= ISNULL(E.Emp_Left_Date,D.FOR_DATE)  --Added by Sumit on 22102016
		
				
		SET		@QUERY = 'UPDATE #Att_Muster Set WO_COHO = ''WO'', ' + @COLS + ' WHERE Emp_ID=' + Cast(@Emp_Id_Cur As Varchar(10))
		EXECUTE(@QUERY);

		--FULL DAY HOLIDAY
		SET		@COLS = NULL;
		SELECT	@COLS  = COALESCE(@COLS  + ',', '')  + 
							'Status_3_' +  Cast(D.ROW_ID As Varchar(5)) + ' = ''HO'' '
		FROM	(SELECT distinct For_Date,EMP_ID from #Emp_Holiday WHERE IsNull(is_Half,0) = 0  AND Emp_Id=@Emp_Id_Cur and Is_Cancel=0)  T  -- Added By Sajid 07-12-2023 -- Added Code and Is_Cancel=0
				LEFT OUTER JOIN #Dates D ON T.FOR_DATE=D.For_Date
				 inner join T0080_EMP_MASTER E WITH (NOLOCK) on E.Emp_ID=T.EMP_ID 
		WHERE D.FOR_DATE <=ISNULL(E.Emp_Left_Date,D.FOR_DATE) --Added by Sumit on 22102016
		
		
		SET		@QUERY = 'UPDATE #Att_Muster Set WO_COHO = ''HO'', ' + @COLS + ' WHERE Emp_ID=' + Cast(@Emp_Id_Cur As Varchar(10))
		EXECUTE(@QUERY);
		
		
		--HALF DAY HOLIDAY
		SET		@COLS= NULL
		SELECT	@COLS  = COALESCE(@COLS  + ',', '')  + 'Status_3_' +  Cast(D.ROW_ID As Varchar(5)) + ' = ''HHO'' '
		FROM	(SELECT distinct For_Date from #Emp_Holiday WHERE IsNull(is_Half,0) = 1 AND Emp_Id=@Emp_Id_Cur) T 
				LEFT OUTER JOIN #Dates D ON T.FOR_DATE=D.For_Date
		
		--select * from #Dates where FOR_DATE>GETDATE()
		
		SET @QUERY = 'UPDATE #Att_Muster Set WO_COHO = ''HHO'', ' + @COLS + ' WHERE Emp_ID=' + Cast(@Emp_Id_Cur As Varchar(10))
		EXECUTE(@QUERY);
		
	
	
		--LEAVE
		
		DECLARE @LEAVE_COUNT VARCHAR(10);
		SET		@COLS= NULL
		SELECT	@COLS  = COALESCE(@COLS  + ',', '')  + 'Status_3_' +  Cast(D.ROW_ID As Varchar(5)) + ' = ''' + T.Leave_Code + ''' '
				,@LEAVE_COUNT = Cast(T.Leave_Count As varchar(10))
		FROM	(						
					SELECT	Max(Leave_Code) As Leave_Code, Sum((isnull(Leave_Used,0) + isnull(CompOff_Used,0))) As Leave_Count, LT.For_Date
					FROM	T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) INNER JOIN T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) ON LT.Cmp_ID=lad.Cmp_ID 
							and (lt.For_Date BETWEEN LAD.From_Date AND LAD.To_Date) AND lT.Leave_ID=LAD.Leave_ID AND LT.FOR_DATE BETWEEN @From_Date AND @To_Date
							INNER JOIN T0120_LEAVE_APPROVAL LA WITH (NOLOCK) ON LAD.Cmp_ID=LA.Cmp_ID AND LAD.Leave_Approval_ID=LA.Leave_Approval_ID AND LT.Emp_ID=LA.Emp_ID
							INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LT.Cmp_ID=LM.Cmp_ID AND LT.Leave_ID=LM.Leave_ID
					WHERE	(LT.Leave_Used  > 0 or LT.compOff_Used > 0) And lT.Emp_ID = @Emp_Id_Cur 
					GROUP BY LT.For_Date
									
				) T LEFT OUTER JOIN #Dates D ON T.FOR_DATE=D.For_Date
		IF (@LEAVE_COUNT IS NOT NULL)
		BEGIN
			SET @QUERY = 'UPDATE #Att_Muster Set Leave_Count = ' + @LEAVE_COUNT + ', ' + @COLS + ' WHERE Emp_ID=' + Cast(@Emp_Id_Cur As Varchar(10))
			
			EXECUTE(@QUERY);
		END

	
		
		--Added By Jimit 30092019	
		SELECT	@EMP_JOINING_DATE = DATE_OF_JOIN 
		FROM	T0080_EMP_MASTER WITH (NOLOCK)
		WHERE	EMP_ID = @Emp_Id_Cur
				
		IF (@EMP_JOINING_DATE >= @FROM_DATE AND @EMP_JOINING_DATE <= @TO_DATE)
			BEGIN
				SET		@COLS = NULL;
				SELECT	@COLS  = COALESCE(@COLS  + ',', '')  + 
								'Status_3_' +  Cast(D.ROW_ID As Varchar(5)) + ' = ''-'' ' 
				FROM	#DATES D 
				WHERE	D.FOR_DATE < @EMP_JOINING_DATE
				
				SET @QUERY = 'UPDATE #Att_Muster Set WO_COHO = ''-'', ' + @COLS + ' WHERE Emp_ID=' + Cast(@Emp_Id_Cur As Varchar(10))	
				EXECUTE(@QUERY);
			END		
		--Ended
			
-- added by Deepali -13062023

	declare @curCM_ID as Numeric
	Declare @curemp_id as Numeric
	Declare @curTempDate as datetime			

	

	Declare Curs_Retain cursor for	                  
	select A.emp_id,A.CMP_Id, D.For_Date from #Att_Muster A, #DATES D where A.For_Date between @From_Date and @To_Date	


	Open Curs_Retain
	Fetch next from Curs_Retain into @curemp_id,@curCM_ID, @curTempDate
	While @@fetch_status = 0                    
			Begin 	
			
			print @curTempDate
			--select * from #DATES
						if  (( select 1 from T0100_EMP_RETAINTION_STATUS OA where   OA.Emp_Id = @curemp_id and OA.Cmp_Id= @curCM_ID and @curTempDate between OA.Start_Date and OA.End_Date 
						and OA.is_retain_On =0 )= 1)
											
						Begin 				
							SET		@COLS = NULL;
							SELECT	@COLS  = COALESCE(@COLS  + ',', '')  + 
									'Status_3_' +  Cast(D.ROW_ID As Varchar(5)) + ' = ''RT'' ' 
							FROM	#DATES D  where D.FOR_DATE = @curTempDate
			
							SET @strQry1 = 'UPDATE #Att_Muster Set WO_COHO = ''-'', ' + @COLS + ' WHERE Emp_ID=' + Cast(@curemp_id as varchar(10))
							--print @strQry1
							EXECUTE(@strQry1);
						   set @RET_DAYS= @RET_DAYS+1					   
						End
					
			fetch next from Curs_Retain into @curemp_id,@curCM_ID, @curTempDate
		
						print @RET_DAYS
		
			end
	close Curs_Retain                    
	deallocate Curs_Retain

	 -- added by Deepali -13062023 -End 

		SET @Previous_Branch_ID  = @Branch_ID
		
		Fetch Next From Att_Cursor INTO @Emp_Id_Cur, @Branch_ID
	End
	Close Att_Cursor
	Deallocate Att_Cursor
	
	
	DECLARE @Month int --=MONTH(@From_Date);
	SET @Month = MONTH(@From_Date)  --changed jimit 19042016
	
	----- Modify Jignesh 26-Feb-2020-----
	/*
	if @Month = 2 AND MONTH(@From_Date) % 4 >0
	begin
		SET @QUERY = 'UPDATE #Att_Muster Set Status_3_29 = NULL,Status_3_30 = NULL,Status_3_31 = NULL ' 
	end	
	ELSE IF @Month = 2 AND MONTH(@From_Date) % 4 = 0
		SET @QUERY = 'UPDATE #Att_Muster Set Status_3_30 = NULL,Status_3_31 = NULL ' 
	else if @Month IN (4,6,9,11) and datediff(d,@From_Date,@to_DAte) + 1  <= 30 -- datediff(d,@From_Date,@to_DAte) + 1  <= 30 Condition add by nilesh for kataria Manual salary cycle on 25102017
		SET @QUERY = 'UPDATE #Att_Muster Set Status_3_31 = NULL ' 
	*/	
	
	if @Month = 2 AND Year(@From_Date) % 4 >0
	begin
		SET @QUERY = 'UPDATE #Att_Muster Set Status_3_29 = NULL,Status_3_30 = NULL,Status_3_31 = NULL ' 
	end	
	ELSE IF @Month = 2 AND Year(@From_Date) % 4 = 0
		SET @QUERY = 'UPDATE #Att_Muster Set Status_3_30 = NULL,Status_3_31 = NULL ' 
	else if @Month IN (4,6,9,11) and datediff(d,@From_Date,@to_DAte) + 1  <= 30 -- datediff(d,@From_Date,@to_DAte) + 1  <= 30 Condition add by nilesh for kataria Manual salary cycle on 25102017
		SET @QUERY = 'UPDATE #Att_Muster Set Status_3_31 = NULL ' 
	EXECUTE(@QUERY);
	-------------------- End -------------

	
	

	Select AM.* , E.Emp_code,E.Emp_full_Name ,Branch_Address,Comp_Name
		, Branch_Name , Dept_Name ,Grd_Name , Desig_Name
		,Cmp_Name,Cmp_Address
		,@From_Date as P_From_date ,@To_Date as P_To_Date , 
		--E.Alpha_Emp_Code + '-' + E.Emp_Full_Name as 'Emp_Code_Name' --Emp_Code_name added by Mihir 07112011
		E.Emp_Full_Name as 'Emp_Code_Name' 
		, E.Alpha_Emp_Code , E.Emp_First_Name,BM.BRANCH_ID,E.date_of_join,TM.type_name,E.Enroll_No
	,DGM.Desig_Dis_No  ---added jimit 24082015
	From #Att_Muster  AM Inner join dbo.T0080_EMP_MASTER E WITH (NOLOCK) ON AM.EMP_ID = E.EMP_ID
			INNER JOIN dbo.T0095_Increment Q_I WITH (NOLOCK) ON AM.Increment_ID=Q_I.Increment_ID
		
	--INNER JOIN ( SELECT I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Emp_ID,I.type_id FROM dbo.T0095_Increment I inner join 
	--				( select max(Increment_ID) as Increment_ID , Emp_ID From dbo.T0095_Increment	-- Ankit 08092014 for Same Date Increment
	--				where Increment_Effective_date <= @To_Date
	--				and Cmp_ID = @Cmp_ID
	--				group by emp_ID  ) Qry on
	--				I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID	)Q_I ON
		--E.EMP_ID = Q_I.EMP_ID 
		INNER JOIN dbo.T0040_GRADE_MASTER GM WITH (NOLOCK) ON Q_I.Grd_Id = gm.Grd_ID INNER JOIN 
		dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Q_I.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN
		dbo.T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON Q_I.DEPT_ID = DM.DEPT_ID LEFT OUTER JOIN 
		dbo.T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON Q_I.DESIG_ID = DGM.DESIG_ID Inner join 
		dbo.T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.CMP_ID = CM.CMP_id left outer join
		T0040_TYPE_MASTER TM WITH (NOLOCK) on Q_I.type_id = TM.type_id
	--Order by Emp_Code,Am.For_Date
	--ORDER BY RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500) --, Am.For_Date
	ORDER BY Case When IsNumeric(Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + Alpha_Emp_Code, 20)
				When IsNumeric(Alpha_Emp_Code) = 0 then Left(Alpha_Emp_Code + Replicate('',21), 20)
				Else Alpha_Emp_Code
			 End
			 
	RETURN


