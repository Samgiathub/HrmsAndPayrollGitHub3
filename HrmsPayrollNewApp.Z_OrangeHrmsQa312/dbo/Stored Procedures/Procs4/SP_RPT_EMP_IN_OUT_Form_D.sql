--exec Emp_Details_Form_B_format1 @Company_Id=121,@From_Date='2021-10-01 00:00:00',@To_Date='2021-10-31 00:00:00',@Branch_ID='',@Cat_ID='',@Grade_ID='',@Type_ID='',@Dept_ID='',@Desig_ID='',@Emp_ID=0,@Constraint='21566',@Report_Type='ESIC'
--exec SP_RPT_EMP_IN_OUT_MUSTER_GET_TEST @Cmp_ID=119,@From_Date='2021-07-01 00:00:00',@To_Date='2021-07-31 00:00:00',@Branch_ID=0,@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Emp_ID=0,@Constraint='26782# 26939# 24430# 14039# 25801#25799',@Report_For='EMP RECORD'
--exec SP_RPT_EMP_IN_OUT_Form_D @Cmp_ID=119,@From_Date='2021-07-01 00:00:00',@To_Date='2021-07-31 00:00:00',@Branch_ID='',@Cat_ID='',@Grd_ID='',@Type_ID='',@Dept_ID='',@Desig_ID='',@Emp_ID=0,@Constraint='26782# 26939# 24430# 14039# 25801# 25799',@Report_For='EMP RECORD'
--exec SP_RPT_EMP_IN_OUT_Form_D @Cmp_ID=119,@From_Date='2021-07-01 00:00:00',@To_Date='2021-07-31 00:00:00',@Branch_ID='',@Cat_ID='',@Grd_ID='',@Type_ID='',@Dept_ID='',@Desig_ID='',@Emp_ID=0,@Constraint='26782# 26939',@Report_For='EMP RECORD'
--exec SP_RPT_EMP_IN_OUT_Form_D @Cmp_ID=119,@From_Date='2021-09-01 00:00:00',@To_Date='2021-09-30 00:00:00',@Branch_ID='',@Cat_ID='',@Grd_ID='',@Type_ID='',@Dept_ID='',@Desig_ID='',@Emp_ID=0,@Constraint='13963# 13964',@Report_For='EMP RECORD'


CREATE PROCEDURE [dbo].[SP_RPT_EMP_IN_OUT_Form_D]
	 @Cmp_ID 		numeric
	,@From_Date		datetime
	,@To_Date 		datetime
	,@Branch_ID		varchar(max)
	,@Cat_ID 		varchar(max) 
	,@Grd_ID 		varchar(max)
	,@Type_ID 		varchar(max)
	,@Dept_ID 		varchar(max)
	,@Desig_ID 		Varchar
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
			Status_In_1	varchar(22),
			Status_Out_1	varchar(22),
			Status_3_1	varchar(22) DEFAULT ('AB'),
			Status_In_2	varchar(22),
			Status_Out_2	varchar(22),
			Status_3_2	varchar(22) DEFAULT ('AB'),
			Status_In_3	varchar(22),
			Status_Out_3	varchar(22),
			Status_3_3	varchar(22) DEFAULT ('AB'),
			Status_In_4	varchar(22),
			Status_Out_4	varchar(22),
			Status_3_4	varchar(22) DEFAULT ('AB'),
			Status_In_5	varchar(22),
			Status_Out_5	varchar(22),
			Status_3_5	varchar(22) DEFAULT ('AB'),
			Status_In_6	varchar(22),
			Status_Out_6	varchar(22),
			Status_3_6	varchar(22) DEFAULT ('AB'),
			Status_In_7	varchar(22),
			Status_Out_7	varchar(22),
			Status_3_7	varchar(22) DEFAULT ('AB'),
			Status_In_8	varchar(22),
			Status_Out_8	varchar(22),
			Status_3_8	varchar(22) DEFAULT ('AB'),
			Status_In_9	varchar(22),
			Status_Out_9	varchar(22),
			Status_3_9	varchar(22) DEFAULT ('AB'),
			Status_In_10	varchar(22),
			Status_Out_10	varchar(22),
			Status_3_10	varchar(22) DEFAULT ('AB'),
			Status_In_11	varchar(22),
			Status_Out_11	varchar(22),
			Status_3_11	varchar(22) DEFAULT ('AB'),
			Status_In_12	varchar(22),
			Status_Out_12	varchar(22),
			Status_3_12	varchar(22) DEFAULT ('AB'),
			Status_In_13	varchar(22),
			Status_Out_13	varchar(22),
			Status_3_13	varchar(22) DEFAULT ('AB'),
			Status_In_14	varchar(22),
			Status_Out_14	varchar(22),
			Status_3_14	varchar(22) DEFAULT ('AB'),
			Status_In_15	varchar(22),
			Status_Out_15	varchar(22),
			Status_3_15	varchar(22) DEFAULT ('AB'),
			Status_In_16	varchar(22),
			Status_Out_16	varchar(22),
			Status_3_16	varchar(22) DEFAULT ('AB'),
			Status_In_17	varchar(22),
			Status_Out_17	varchar(22),
			Status_3_17	varchar(22) DEFAULT ('AB'),
			Status_In_18	varchar(22),
			Status_Out_18	varchar(22),
			Status_3_18	varchar(22) DEFAULT ('AB'),
			Status_In_19	varchar(22),
			Status_Out_19	varchar(22),
			Status_3_19	varchar(22) DEFAULT ('AB'),
			Status_In_20	varchar(22),
			Status_Out_20	varchar(22),
			Status_3_20	varchar(22) DEFAULT ('AB'),
			Status_In_21	varchar(22),
			Status_Out_21	varchar(22),
			Status_3_21	varchar(22) DEFAULT ('AB'),
			Status_In_22	varchar(22),
			Status_Out_22	varchar(22),
			Status_3_22	varchar(22) DEFAULT ('AB'),
			Status_In_23	varchar(22),
			Status_Out_23	varchar(22),
			Status_3_23	varchar(22) DEFAULT ('AB'),
			Status_In_24	varchar(22),
			Status_Out_24	varchar(22),
			Status_3_24	varchar(22) DEFAULT ('AB'),
			Status_In_25	varchar(22),
			Status_Out_25	varchar(22),
			Status_3_25	varchar(22) DEFAULT ('AB'),
			Status_In_26	varchar(22),
			Status_Out_26	varchar(22),
			Status_3_26	varchar(22) DEFAULT ('AB'),
			Status_In_27	varchar(22),
			Status_Out_27	varchar(22),
			Status_3_27	varchar(22) DEFAULT ('AB'),
			Status_In_28	varchar(22),
			Status_Out_28	varchar(22),
			Status_3_28	varchar(22) DEFAULT ('AB'),
			Status_In_29	varchar(22),
			Status_Out_29	varchar(22),
			Status_3_29	varchar(22) DEFAULT ('AB'),
			Status_In_30	varchar(22),
			Status_Out_30	varchar(22),
			Status_3_30	varchar(22) DEFAULT ('AB'),
			Status_In_31	varchar(22),
			Status_Out_31	varchar(22),
			Status_3_31	varchar(22) DEFAULT ('AB')
	  )
	  
	  
	  CREATE CLUSTERED INDEX IX_Att_Muster_Emp_ID on dbo.#Att_Muster(Emp_Id);


	  
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
	  
	Declare @Is_Cancel_Holiday  numeric(1,0)
	Declare @Is_Cancel_Weekoff	numeric(1,0)	
	Declare @strHoliday_Date As Varchar(max)
	Declare @StrWeekoff_Date  varchar(max)

	Set @StrHoliday_Date = ''      
	set @StrWeekoff_Date = ''

	
	insert into #Att_Muster (Emp_ID,Branch_ID,Increment_ID,Cmp_ID,For_Date)
	select 	Emp_ID, Branch_ID,Increment_ID,@Cmp_ID ,@From_date from #Emp_Cons
	
	--select * from  #Att_Muster--mansi
	
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
	
		Select  Emp_Id,ROW_ID,In_Time as Time,
			'IN' as status Into #InTime
		  from ((SELECT DISTINCT D.ROW_ID, A.EMP_ID ,A.For_Date,A.In_Time,A.Out_Time,EIR1.ManualEntryFlag,rn FROM #Data AS A 
			INNER JOIN #DATES D ON A.FOR_DATE=D.FOR_DATE
			--LEFT OUTER JOIN T0150_EMP_INOUT_RECORD EIR ON EIR.Emp_ID = A.EMP_ID and EIR.For_Date = A.FOR_DATE and (EIR.In_Time = A.In_Time OR EIR.Out_Time = A.Out_Time)
			LEFT OUTER JOIN
			(
				SELECT IO_Tran_Id,ROW_NUMBER() OVER (PARTITION BY EIR.For_Date ORDER BY ManualEntryFlag ASC) AS rn,In_Time,Out_Time,ManualEntryFlag,For_Date
				from T0150_EMP_INOUT_RECORD EIR
				WHERE Emp_ID = @Emp_Id_Cur and For_Date between @From_Date and @To_Date
			) EIR1 ON EIR1.For_Date = A.FOR_DATE and (EIR1.In_Time = A.In_Time OR EIR1.Out_Time = A.Out_Time) AND (rn = 1 ))) T
		
		 Select  Emp_Id,ROW_ID, 
		Out_Time as Time,
		 'OUT' as status Into #OutTime
			from ((SELECT DISTINCT D.ROW_ID, A.EMP_ID ,A.For_Date,A.In_Time,A.Out_Time,EIR1.ManualEntryFlag,rn FROM #Data AS A 
			INNER JOIN #DATES D ON A.FOR_DATE=D.FOR_DATE
			--LEFT OUTER JOIN T0150_EMP_INOUT_RECORD EIR ON EIR.Emp_ID = A.EMP_ID and EIR.For_Date = A.FOR_DATE and (EIR.In_Time = A.In_Time OR EIR.Out_Time = A.Out_Time)
			LEFT OUTER JOIN
			(
				SELECT IO_Tran_Id,ROW_NUMBER() OVER (PARTITION BY EIR.For_Date ORDER BY ManualEntryFlag ASC) AS rn,In_Time,Out_Time,ManualEntryFlag,For_Date
				from T0150_EMP_INOUT_RECORD EIR
				WHERE Emp_ID = @Emp_Id_Cur and For_Date between @From_Date and @To_Date
			) EIR1 ON EIR1.For_Date = A.FOR_DATE and (EIR1.In_Time = A.In_Time OR EIR1.Out_Time = A.Out_Time) AND (rn = 1 ))) T
		
		select Emp_Id,ROW_ID,FORMAT(Time, 'hh:mm tt')as Time
		,status into  #InOut from (select * from #InTime
		union 
		select * from #OutTime)as t		

			select Emp_Id,
			FORMAT([1], 'hh:mm tt')as[1],FORMAT([2], 'hh:mm tt')as [2],FORMAT([3], 'hh:mm tt')as [3],FORMAT([4], 'hh:mm tt')as [4],
			  FORMAT([5], 'hh:mm tt')as[5],FORMAT([6], 'hh:mm tt')as [6],FORMAT([7], 'hh:mm tt')as[7],FORMAT([8], 'hh:mm tt')as[8],
			  FORMAT([9], 'hh:mm tt')as[9],FORMAT([10], 'hh:mm tt')as [10],FORMAT([11], 'hh:mm tt')as[11],FORMAT([12], 'hh:mm tt')as [12],
			  FORMAT([13], 'hh:mm tt')as[13],FORMAT([14], 'hh:mm tt')as[14],FORMAT([15], 'hh:mm tt')as[15],FORMAT([16], 'hh:mm tt')as[16],FORMAT([17], 'hh:mm tt')as[17],
			  FORMAT([18], 'hh:mm tt')as [18],FORMAT([19], 'hh:mm tt')as[19],FORMAT([20], 'hh:mm tt')as[20],FORMAT([21], 'hh:mm tt')as[21],FORMAT([22], 'hh:mm tt')as[22],
			  FORMAT([23], 'hh:mm tt')as[23],FORMAT([24], 'hh:mm tt')as[24],FORMAT([25], 'hh:mm tt')as[25],FORMAT([26], 'hh:mm tt')as[26],FORMAT([27], 'hh:mm tt')as[27],
			  FORMAT([28], 'hh:mm tt')as[28],FORMAT([29], 'hh:mm tt')as[29],FORMAT([30], 'hh:mm tt')as[30],FORMAT([31], 'hh:mm tt')as[31],status into #finaltbl from (			 
			SELECT Emp_Id,[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],[26],[27],[28],[29],[30],[31],status From
			#InTime
			PIVOT (max(Time) 
				   FOR Row_ID in ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],[26],[27],[28],[29],[30],[31])
				   ) AS pvt	
            Union 
			SELECT Emp_Id,[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],[26],[27],[28],[29],[30],[31],status From
			#OutTime
			PIVOT (max(Time) 
				   FOR Row_ID in ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],[26],[27],[28],[29],[30],[31])
				   ) AS pvt	)as T
				
		
		--select * from #finaltbl--mansi

		DECLARE @EMP_LEFT_DATE1 datetime
		DECLARE @E_Id numeric
		SELECT	@EMP_LEFT_DATE1 = Emp_Left_Date,@E_Id=e.Emp_ID 
		FROM T0080_EMP_MASTER e
		 inner join #Emp_Cons ec on ec.Emp_ID=e.Emp_ID --WHERE EMP_ID=@Emp_Id_Cur
	  
		SELECT	Emp_Left_Date,e.Emp_ID,d.ROW_ID 
		into #empleft
		FROM T0080_EMP_MASTER e
		 inner join #Emp_Cons ec on ec.Emp_ID=e.Emp_ID 
		inner join #DATES d on d.FOR_DATE=e.Emp_Left_Date

	
		--IF (@EMP_LEFT_DATE1 >= @FROM_DATE AND @EMP_LEFT_DATE1 <= @TO_DATE)
		--	BEGIN
		--	   declare @left_E_Id  numeric,@R_Id numeric
		--	   DECLARE @E_col  VARCHAR(MAX);		
		--		SET		@COLS = NULL;
		--		set @E_col=NUll;
		--    set	 @left_E_Id=(select Emp_ID FROM	#empleft) 
		--	set @R_Id=(select ROW_ID from #empleft)
				 
				--select @left_E_Id,@R_Id
				--	SELECT	@E_Col=cast(@left_E_Id as varchar),@COLS  =  COALESCE(@COLS  + ',', '')  + 
				--				'[' +  Cast(D.ROW_ID As Varchar(5)) + ']' + ' = ''-''' 
				--FROM	#DATES D 
				--WHERE	D.FOR_DATE > (select Emp_Left_Date from #empleft)--el.Emp_Left_Date
				-- print @COLS
				-- print @E_Col
				 --insert into #InOut (Emp_Id,ROW_ID,time,status)select Emp_ID,ROW_ID,'WO','IN' from #tmpweekoff
				-- SET @QUERY = 'UPDATE #InOut Set ' + @E_Col + ' WHERE Emp_ID=' + Cast(@left_E_Id As Varchar(10))	
				--EXECUTE(@QUERY);
				--SET @QUERY = 'UPDATE #InOut Set ' + @COLS + ' WHERE Emp_ID=' + Cast(@left_E_Id As Varchar(10))	
				--EXECUTE(@QUERY);
		--	END
		----print @EMP_LEFT_DATE1
		
			select t.Emp_ID ,t.ROW_ID ,t.For_Date,t.W_Day into #tmpweekoff from (
			select ew.Emp_ID,ew.For_Date,ew.W_Day,ew.Is_Cancel,ew.Weekoff_day,
			d.ROW_ID 
			from #Emp_WeekOff ew 
			inner join #DATES d on d.FOR_DATE=ew.For_Date)as t
				
				--select * from #tmpweekoff --mansi
			select  * into #tmphalfholiday from (
			select eh.Emp_ID,eh.For_Date,eh.H_DAY,eh.IS_CANCEL,eh.Is_Half,
			d.ROW_ID 
			from #EMP_HOLIDAY eh 
			inner join #DATES d on d.FOR_DATE=eh.For_Date)as t WHERE IsNull(is_Half,0) = 1

		    select  * into #tmpfullholiday from (
			select eh.Emp_ID,eh.For_Date,eh.H_DAY,eh.IS_CANCEL,eh.Is_Half,
			d.ROW_ID 
			from #EMP_HOLIDAY eh 
			inner join #DATES d on d.FOR_DATE=eh.For_Date)as t WHERE IsNull(t.is_Half,0) = 0 

			select t.Emp_ID,t.For_Date,t.Leave_Code,t.Leave_Count,d.ROW_ID  into #Empleave FROM	(						
					SELECT	em.Emp_ID,Max(Leave_Code) As Leave_Code, Sum((isnull(Leave_Used,0) + isnull(CompOff_Used,0))) As Leave_Count, LT.For_Date
					FROM	T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) INNER JOIN T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) ON LT.Cmp_ID=lad.Cmp_ID 
							and (lt.For_Date BETWEEN LAD.From_Date AND LAD.To_Date) AND lT.Leave_ID=LAD.Leave_ID AND LT.FOR_DATE BETWEEN @From_Date AND @To_Date
							INNER JOIN T0120_LEAVE_APPROVAL LA WITH (NOLOCK) ON LAD.Cmp_ID=LA.Cmp_ID AND LAD.Leave_Approval_ID=LA.Leave_Approval_ID AND LT.Emp_ID=LA.Emp_ID
							INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LT.Cmp_ID=LM.Cmp_ID AND LT.Leave_ID=LM.Leave_ID
							INNER JOIN #Emp_Cons em WITH (NOLOCK) ON em.Emp_ID=lt.Emp_ID
					WHERE	(LT.Leave_Used  > 0 or LT.compOff_Used > 0) --And lT.Emp_ID = @Emp_Id_Cur 
					GROUP BY LT.For_Date,em.Emp_ID
									
				) T LEFT OUTER JOIN #Dates D ON T.FOR_DATE=D.For_Date

    
		
		  insert into #InOut (Emp_Id,ROW_ID,time,status)select Emp_ID,ROW_ID,'WO','IN' from #tmpweekoff
			insert into #InOut (Emp_Id,ROW_ID,time,status)select Emp_ID,ROW_ID,'WO','OUT' from #tmpweekoff 
			--select * from #InOut where Emp_Id=27287  --mansi
		
			--select * from #Empleave --mansi
			insert into #InOut (Emp_Id,ROW_ID,time,status)select Emp_ID,ROW_ID,Leave_Code,'IN' from #Empleave
			insert into #InOut (Emp_Id,ROW_ID,time,status)select Emp_ID,ROW_ID,Leave_Code,'OUT' from #Empleave 
			--select * from #tmphalfholiday --mansi(HHO)
			insert into #InOut (Emp_Id,ROW_ID,time,status)select Emp_ID,ROW_ID,'HHO','IN' from #tmphalfholiday
			insert into #InOut (Emp_Id,ROW_ID,time,status)select Emp_ID,ROW_ID,'-','OUT' from #tmphalfholiday 
			--select * from #tmpfullholiday --mansi(HO)
			insert into #InOut (Emp_Id,ROW_ID,time,status)select Emp_ID,ROW_ID,'HO','IN' from #tmpfullholiday
			insert into #InOut (Emp_Id,ROW_ID,time,status)select Emp_ID,ROW_ID,'HO','OUT' from #tmpfullholiday 
			


	Declare Att_Cursor  Cursor Fast_forward For 
		Select Emp_Id From #Att_Muster 
		order by Branch_ID
	Open Att_Cursor
	
	Fetch Next From Att_Cursor INTO @Emp_Id_Cur
	while @@fetch_status = 0
	Begin 
		
	--	if (@Previous_Branch_ID <> cast(@Branch_ID as numeric ))
		--BEGIN			
		--	select	Top 1 @Is_Cancel_Holiday = isnull(Is_Cancel_Holiday,0)  ,@Is_Cancel_Weekoff = isnull(Is_Cancel_Weekoff,0)
		--	from	dbo.T0040_GENERAL_SETTING WITH (NOLOCK)
		--	where	cmp_ID = @cmp_ID	and Branch_ID = cast(@Branch_ID as numeric)
		--			and For_Date = ( select max(For_Date) from dbo.T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@To_Date and Branch_ID = cast(@Branch_ID as numeric ) and Cmp_ID = @Cmp_ID)			
		--END

		SET		@COLS = NULL;
		
		SELECT @COLS  =  COALESCE(@COLS  + ',', '')  + 
							'Status_In_' +  Cast(T.ROW_ID As Varchar(5)) + ' = ''' + IsNull(Convert(Varchar(5),T.In_Time,108),'') + ''',  ' +
							'Status_Out_' +  Cast(T.ROW_ID As Varchar(5)) + ' = ''' + IsNull(Convert(Varchar(5),T.Out_Time,108),'') + '' + (Case When T.ManualEntryFlag IN('I','O','IO','New') Then '#' Else '' END) +''', ' +
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
	
		
		SET @QUERY = 'UPDATE #Att_Muster Set ' + @COLS + ' WHERE Emp_ID=' + Cast(@Emp_Id_Cur As Varchar(10))
		EXECUTE(@QUERY);
		 
		DECLARE @EMP_LEFT_DATE datetime
		SELECT	@EMP_LEFT_DATE = Emp_Left_Date FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE EMP_ID=@Emp_Id_Cur
		 ---added by mansi start
	  IF OBJECT_ID('tempdb..#tmpleft') IS NOT NULL
             DROP TABLE #tmpleft
			   IF OBJECT_ID('tempdb..#rw') IS NOT NULL
             DROP TABLE #rw
			  ---added by mansi end
		IF (@EMP_LEFT_DATE >= @FROM_DATE AND @EMP_LEFT_DATE <= @TO_DATE)
			BEGIN
			
				SET		@COLS = NULL;
				SELECT	@COLS  = COALESCE(@COLS  + ',', '')  + 
								'Status_3_' +  Cast(D.ROW_ID As Varchar(5)) + ' = ''-'' ' 
				FROM	#DATES D 
				WHERE	D.FOR_DATE > @EMP_LEFT_DATE

				SET @QUERY = 'UPDATE #Att_Muster Set ' + @COLS + ' WHERE Emp_ID=' + Cast(@Emp_Id_Cur As Varchar(10))	
				EXECUTE(@QUERY);
			
				    ---added by mansi start
					SELECT	 Cast(D.ROW_ID As Varchar(5)) as ROW_ID,@Emp_Id_Cur as Emp_Id
				  into #tmpleft FROM	#DATES D 
				  WHERE	D.FOR_DATE > @EMP_LEFT_DATE

					select i.Emp_Id,i.Row_id,time
					into #rw
					from #InOut I
					inner join #tmpleft tl on tl.Emp_Id=i.Emp_Id and i.ROW_ID=tl.ROW_ID
					--select * from #rw
					IF (SELECT COUNT(*) FROM #rw) > 0
					begin
					  DELETE t1
                 FROM #InOut AS t1 INNER join #rw AS t2
              ON t1.Emp_Id = t2.Emp_Id and t1.ROW_ID=t2.ROW_ID
					end 
             
			   insert into #InOut (Emp_Id,ROW_ID,time,status)select Emp_ID,ROW_ID,'-','IN' from #tmpleft
			   insert into #InOut (Emp_Id,ROW_ID,time,status)select Emp_ID,ROW_ID,'-','OUT' from #tmpleft 
			    ---added by mansi end
			END
		--print @EMP_LEFT_DATE
		
		
		--WEEK OFF		
		SET		@COLS = NULL;
		SELECT	@COLS  = COALESCE(@COLS  + ',', '')  + 'Status_3_' +  Cast(D.ROW_ID As Varchar(5)) + ' = ''WO'' ' 							
		FROM	(SELECT distinct For_Date,Emp_ID from #Emp_Weekoff Where Emp_Id=@Emp_Id_Cur)  T LEFT OUTER JOIN #Dates D ON T.FOR_DATE=D.For_Date
				INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) on E.Emp_ID=T.Emp_ID
		WHERE D.FOR_DATE <= ISNULL(E.Emp_Left_Date,D.FOR_DATE)  --Added by Sumit on 22102016
		
				
		SET		@QUERY = 'UPDATE #Att_Muster Set WO_COHO = ''WO'', ' + @COLS + ' WHERE Emp_ID=' + Cast(@Emp_Id_Cur As Varchar(10))
		EXECUTE(@QUERY);

		--FULL DAY HOLIDAY
		SET		@COLS = NULL;
		SELECT	@COLS  = COALESCE(@COLS  + ',', '')  + 
							'Status_3_' +  Cast(D.ROW_ID As Varchar(5)) + ' = ''HO'' '
		FROM	(SELECT distinct For_Date,EMP_ID from #Emp_Holiday WHERE IsNull(is_Half,0) = 0  AND Emp_Id=@Emp_Id_Cur) T 
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
		IF OBJECT_ID('tempdb..#tmpjoin') IS NOT NULL
             DROP TABLE #tmpjoin
			   IF OBJECT_ID('tempdb..#rwd') IS NOT NULL
             DROP TABLE #rwd
			  ---added by mansi end
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

				 ---added by mansi start
					SELECT	 Cast(D.ROW_ID As Varchar(5)) as ROW_ID,@Emp_Id_Cur as Emp_Id
				into #tmpjoin FROM	#DATES D 
				WHERE D.FOR_DATE < @EMP_JOINING_DATE

					select i.Emp_Id,i.Row_id,time
					into #rwd
					from #InOut I
					inner join #tmpjoin tl on tl.Emp_Id=i.Emp_Id and i.ROW_ID=tl.ROW_ID
					--select * from #rwd
					IF (SELECT COUNT(*) FROM #rwd) > 0
					begin
					  DELETE t1
                 FROM #InOut AS t1 INNER join #rwd AS t2
              ON t1.Emp_Id = t2.Emp_Id and t1.ROW_ID=t2.ROW_ID
					end 
             
			   insert into #InOut (Emp_Id,ROW_ID,time,status)select Emp_ID,ROW_ID,'-','IN' from #tmpjoin
			   insert into #InOut (Emp_Id,ROW_ID,time,status)select Emp_ID,ROW_ID,'-','OUT' from #tmpjoin 
			    ---added by mansi end
			END		
		--Ended


		--SET @Previous_Branch_ID  = @Branch_ID
		
		Fetch Next From Att_Cursor INTO @Emp_Id_Cur--, @Branch_ID
	End
	Close Att_Cursor
	Deallocate Att_Cursor
	
	
	DECLARE @Month int --=MONTH(@From_Date);
	SET @Month = MONTH(@From_Date)  --changed jimit 19042016
	
	
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
	 
	  --select * from #EMP_HOLIDAY 
	
	  --select * from #InOut i 
	  --inner join  #Empleave el on el.Emp_ID=i.Emp_Id and i.Time=el.Leave_Code 
	  --inner join #EMP_HOLIDAY eh on eh.EMP_ID=i.Emp_Id 
	  --inner join #tmpfullholiday ef on ef.EMP_ID=i.Emp_Id 
	  --where eh.H_DAY =1 --and time not in()


		select Emp_Id,[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],[26],[27],[28],[29],[30],[31],status
			 into #finaltbl1
			  from (			 
			SELECT Emp_Id,[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],[26],[27],[28],[29],[30],[31],status From
			#InOut
			PIVOT (max(Time) 
				   FOR Row_ID in ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],[26],[27],[28],[29],[30],[31])
				   ) AS pvt	
           	)as T
	
	
		select ms.Emp_id,ms.Present_Days into #empsal from
									T0080_EMP_MASTER E
									inner join  #Emp_Cons EC on EC.Emp_ID  = E.Emp_ID
									inner join T0200_MONTHLY_SALARY as MS on E.Emp_ID=MS.Emp_ID
									where  Month_St_Date=@From_Date and Month_End_Date=@To_Date			
 

  -- select * from #finaltbl1 order by Emp_Id,status 

	select e.Emp_ID,e.Emp_Full_Name as [Name_2],'Set Work' as [Relay_Or_Set_Work_3],'' as [Place_of_Work_4],
	isnull([1],'A')as [1],isnull([2],'A')as[2],isnull([3],'A')as[3],isnull([4],'A')as[4],isnull([5],'A')as[5],
	isnull([6],'A')as[6],isnull([7],'A')as[7],isnull([8],'A')as[8],isnull([9],'A')as[9],isnull([10],'A')as[10],
	isnull([11],'A')as[11],isnull([12],'A')as[12],isnull([13],'A')as[13],isnull([14],'A')as[14],
	isnull([15],'A')as[15],isnull([16],'A')as[16],isnull([17],'A')as[17],isnull([18],'A')as[18],
	isnull([19],'A')as[19],isnull([20],'A')as[20],isnull([21],'A')as[21],isnull([22],'A')as[22],
	isnull([23],'A')as[23],isnull([24],'A')as[24],isnull([25],'A')as[25],isnull([26],'A')as[26],
	isnull([27],'A')as[27],isnull([28],'A')as[28],isnull([29],'A')as[29],isnull([30],'A')as[30],
	isnull([31],'A')as[31],
	status as [INOUT_6],es.Present_Days as[Summary_No_of_Days_7],'' as[Remarks_No._of_hours_8],'' as [Signature_of_Register_Keeper_9]
	into #finalatt  From #finaltbl1  AM 
	Inner join dbo.T0080_EMP_MASTER E WITH (NOLOCK) ON AM.EMP_ID = E.EMP_ID
	left join #empsal es on es.Emp_ID=am.Emp_Id
		--select ms.Emp_id,ms.Present_Days,ms.Working_Days from
		--							T0080_EMP_MASTER E
		--							inner join  #Emp_Cons EC on EC.Emp_ID  = E.Emp_ID
		--							inner join T0200_MONTHLY_SALARY as MS on E.Emp_ID=MS.Emp_ID
		--							where  Month_St_Date=@From_Date and Month_End_Date=@To_Date			
 --select * into #finalattendance from #finalatt order by Emp_ID,INOUT_6 

	

	select (ROW_NUMBER() OVER(ORDER BY Emp_ID)) AS SrNo ,emp_id into #Emp_Row from #Emp_Cons 
	
 	select *  INTO #finalattendance from #finalatt order by Emp_ID,INOUT_6 
   
	DECLARE @Month1 int 
	SET @Month1 = MONTH(@From_Date)  --changed jimit 19042016

		if @Month1 = 2 AND Year(@From_Date) % 4 >0
	begin
		SET @QUERY = 'ALTER TABLE #finalattendance DROP COLUMN [29],[30],[31] '--set [29] = NULL,[30] = NULL,[31] = NULL ' 
	end	
	ELSE IF @Month1 = 2 AND Year(@From_Date) % 4 = 0
		SET @QUERY = 'ALTER TABLE #finalattendance DROP COLUMN [30],[31] '--'UPDATE #finaltbl1 Set [30] = NULL,[31] = NULL ' 
	else if @Month1 IN (4,6,9,11) and datediff(d,@From_Date,@to_DAte) + 1  <= 30 -- datediff(d,@From_Date,@to_DAte) + 1  <= 30 Condition add by nilesh for kataria Manual salary cycle on 25102017
		SET @QUERY = 'ALTER TABLE #finalattendance DROP COLUMN [31] '--'UPDATE #finaltbl1 Set [31] = NULL ' 
	EXECUTE(@QUERY);

		select er.SrNo,er.SrNo as [Sr_Number_in_Employee_Register_1],f.* 
	from #finalattendance f
	left join #Emp_Row er on er.Emp_ID=f.Emp_ID
	ORDER by Emp_Id
		
	
	--exec SP_RPT_EMP_IN_OUT_MUSTER_GET_WITH_DURATION_AND_OVERTIME @Cmp_ID=119,@From_Date=@From_Date,@To_Date=@To_Date,@Branch_ID=0,@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Emp_ID=0,@Constraint=@constraint,@Report_For='Format 3'
  --Emp_ID,Name_2,Relay_Or_Set_Work_3,Place_of_Work_4,INOUT_6,[Remarks_No._of_hours_8],Signature_of_Register_Keeper_9
			--Select AM.* , E.Emp_code,E.Emp_full_Name ,Branch_Address,Comp_Name
			--	, Branch_Name , Dept_Name ,Grd_Name , Desig_Name
			--	,Cmp_Name,Cmp_Address
			--	,@From_Date as P_From_date ,@To_Date as P_To_Date , 
			--	--E.Alpha_Emp_Code + '-' + E.Emp_Full_Name as 'Emp_Code_Name' --Emp_Code_name added by Mihir 07112011
			--	E.Emp_Full_Name as 'Emp_Code_Name' 
			--	, E.Alpha_Emp_Code , E.Emp_First_Name,BM.BRANCH_ID,E.date_of_join,TM.type_name,E.Enroll_No
			--,DGM.Desig_Dis_No  ---added jimit 24082015
			--From #Att_Muster  AM Inner join dbo.T0080_EMP_MASTER E WITH (NOLOCK) ON AM.EMP_ID = E.EMP_ID
			--		INNER JOIN dbo.T0095_Increment Q_I WITH (NOLOCK) ON AM.Increment_ID=Q_I.Increment_ID
			--	INNER JOIN dbo.T0040_GRADE_MASTER GM WITH (NOLOCK) ON Q_I.Grd_Id = gm.Grd_ID INNER JOIN 
			--	dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Q_I.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN
			--	dbo.T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON Q_I.DEPT_ID = DM.DEPT_ID LEFT OUTER JOIN 
			--	dbo.T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON Q_I.DESIG_ID = DGM.DESIG_ID Inner join 
			--	dbo.T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.CMP_ID = CM.CMP_id left outer join
			--	T0040_TYPE_MASTER TM WITH (NOLOCK) on Q_I.type_id = TM.type_id
			----Order by Emp_Code,Am.For_Date
			----ORDER BY RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500) --, Am.For_Date
			--ORDER BY Case When IsNumeric(Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + Alpha_Emp_Code, 20)
			--			When IsNumeric(Alpha_Emp_Code) = 0 then Left(Alpha_Emp_Code + Replicate('',21), 20)
			--			Else Alpha_Emp_Code
			--		 End
			 
	RETURN


