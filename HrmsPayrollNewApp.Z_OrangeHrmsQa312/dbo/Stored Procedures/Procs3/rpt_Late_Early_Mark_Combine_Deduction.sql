			   
CREATE PROCEDURE [dbo].[rpt_Late_Early_Mark_Combine_Deduction]
  @Cmp_ID		numeric  
 ,@From_Date	datetime  
 ,@To_Date		datetime   
 ,@Branch_ID	numeric  
 ,@Cat_ID		numeric   
 ,@Grd_ID		numeric  
 ,@Type_ID		numeric  
 ,@Dept_ID		numeric  
 ,@Desig_ID		numeric  
 ,@Emp_ID		numeric  
 ,@constraint	varchar(MAX)  
 ,@Flag         tinyint = 0
AS
BEGIN
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
	  
	-- Added by Hardik 27/11/2020 for Emerland Honda, As Holiday and Weekoff tables got clear when this SP call from Attendance Consolidated Report
	DECLARE @Required_Execution BIT;
	SET @Required_Execution = 0;

	IF @Flag = 0
		Begin
			IF OBJECT_ID('tempdb..#Emp_Cons') IS Not NULL
				BEGIN 		
					Drop Table #Emp_Cons
				END

			CREATE TABLE #Emp_Cons 
			(      
				Emp_ID numeric,     
				Branch_ID numeric,
				Increment_ID numeric    
			)
		END

		
	IF Object_ID('tempdb..#Emp_Late_Early') Is not null
		Begin
			Drop Table #Emp_Late_Early
		End

	Create Table #Emp_Late_Early
	(
		Cmp_ID Numeric,
		Emp_ID Numeric,
		For_Date Datetime,  
		In_Time  Datetime,
		Out_Time Datetime,
		Shift_St_Time Datetime,
		Shift_End_Time Datetime,
		Late_Sec Numeric,
		Early_Sec Numeric,
		Late_Limit Varchar(10),
		Early_Limit Varchar(10),
		Late_Deduction Numeric(3,2),
		Early_Deduction Numeric(3,2),
		ExemptFlag Varchar(4)
	)

	IF OBJECT_ID('tempdb..#EMP_HOLIDAY') IS NULL
		BEGIN
			CREATE TABLE #EMP_HOLIDAY(EMP_ID NUMERIC, FOR_DATE DATETIME, IS_CANCEL BIT, Is_Half tinyint, Is_P_Comp tinyint, H_DAY numeric(4,1));
			CREATE UNIQUE CLUSTERED INDEX IX_EMP_HOLIDAY_EMPID_FORDATE ON #EMP_HOLIDAY(EMP_ID, FOR_DATE);
			SET @Required_Execution =1
		END

	IF OBJECT_ID('tempdb..#Emp_WeekOff') IS NULL
		BEGIN
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
			SET @Required_Execution =1
		END
	
	CREATE table #Data
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
		--,Working_sec_Between_Shift numeric(18) default 0 -- Commented by Niraj(20062022)
	)     
	IF @Required_Execution =1
		EXEC SP_GET_HW_ALL @CONSTRAINT=@constraint,@CMP_ID=@Cmp_ID, @FROM_DATE=@FROM_DATE, @TO_DATE=@TO_DATE, @All_Weekoff = 0, @Exec_Mode=0, @Delete_Cancel_HW =0
		
	
	Exec SP_CALCULATE_PRESENT_DAYS @Cmp_ID=@Cmp_ID,@FROM_DATE=@From_Date,@TO_DATE=@To_Date,@Branch_ID=0,@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Emp_ID=0,@CONSTRAINT=@constraint,@Return_Record_set=4
	

	DECLARE @ABSENT_DATE_STRING VARCHAR(MAX)
	SET @ABSENT_DATE_STRING = ''
	DECLARE @WEEKOFF_DATE_STRING VARCHAR(MAX)
	SET @WEEKOFF_DATE_STRING = ''
	DECLARE @HOLIDAY_DATE_STRING VARCHAR(MAX)
	SET @HOLIDAY_DATE_STRING = ''

	DECLARE @LATE_ABSENT_DAY NUMERIC(18,2)
	SET @LATE_ABSENT_DAY = 0

	Declare @Total_LMark NUMERIC(18,2)
	SET @Total_LMark = 0

	DECLARE @INCREMENT_ID NUMERIC
	SET @INCREMENT_ID = 0

	Declare @Total_Late_Sec Numeric
	Set @Total_Late_Sec = 0

	Declare Cur_Emp Cursor For
	Select Emp_ID,Increment_ID From #Emp_Cons
	Open Cur_Emp
	Fetch Next From Cur_Emp into @Emp_ID,@INCREMENT_ID
		While @@FETCH_STATUS = 0
			Begin
				SET @ABSENT_DATE_STRING = ''
				SET @WEEKOFF_DATE_STRING = ''
				SET @HOLIDAY_DATE_STRING = ''
				SELECT @ABSENT_DATE_STRING = COALESCE(@ABSENT_DATE_STRING + '#', '') + CAST(FOR_DATE AS VARCHAR(11)) 
					FROM #DATA 
				WHERE EMP_ID = @EMP_ID AND FOR_DATE >= @FROM_DATE AND FOR_DATE <= @TO_DATE AND P_DAYS = 0

				SELECT @WEEKOFF_DATE_STRING = COALESCE(@WEEKOFF_DATE_STRING + '', ';') + CAST(FOR_DATE AS VARCHAR(11)) 
					FROM #EMP_WEEKOFF
				WHERE EMP_ID = @EMP_ID

				SELECT @HOLIDAY_DATE_STRING = COALESCE(@HOLIDAY_DATE_STRING + '', ';') + CAST(FOR_DATE AS VARCHAR(11)) 
					FROM #EMP_HOLIDAY
				WHERE EMP_ID = @EMP_ID
				
				--exec SP_CALCULATE_LATE_EARLY_DEDUCTION_COMBINE @Emp_ID,@Cmp_ID,@From_Date,@To_Date,@Late_Absent_Day output,@Total_LMark output,@Total_Late_Sec output,@Increment_ID,@WEEKOFF_DATE_STRING,@HOLIDAY_DATE_STRING,0,'',0,@Absent_date_String,0,1
				exec SP_CALCULATE_LATE_EARLY_DEDUCTION_COMBINE_MULTIPLE_EXEMPT @Emp_ID,@Cmp_ID,@From_Date,@To_Date,@Late_Absent_Day output,@Total_LMark output,@Total_Late_Sec output,@Increment_ID,@WEEKOFF_DATE_STRING,@HOLIDAY_DATE_STRING,0,'',0,@Absent_date_String,0,1
				
				Fetch Next From Cur_Emp into @Emp_ID,@INCREMENT_ID
			End
	Close Cur_Emp
	Deallocate Cur_Emp

	--UPDATE  #Emp_Late_Early SET Out_Time = '2024-10-02 16:30:00.000' where Emp_ID = 4413  and For_Date = '2024-10-02 00:00:00.000' 
	--UPDATE  #Emp_Late_Early SET Out_Time = '2024-10-03 16:00:00.000'  where Emp_ID = 4413  and For_Date = '2024-10-03 00:00:00.000' 

	select ROW_NUMBER() over(order by Emp_Id) as rn,* into #tmpEmp_cons from #Emp_Cons
	
	Declare @MonthExemptLimitInSec NUMERIC(18,0) = 7200
	Select *
		,CASE WHEN LATEMINUTESEC > 0 AND LATEMINUTESEC > EmpLateLimitSec THEN (LATEMINUTESEC - EmpLateLimitSec) ELSE 0 END AS ActualLateLimit
		,CASE WHEN EARLYMINUTESEC > 0 AND EARLYMINUTESEC > EmpEarlyLimitSec THEN (EARLYMINUTESEC - EmpEarlyLimitSec) ELSE 0 END AS ActualEarlyLimit
		,0 as DeductMonthLimit
		into #TempData1
		from (
			select AM.*
					, @MonthExemptLimitInSec as MonthLimitSec
					,case when dbo.F_Return_sec(Emp_Late_Limit) > 0 then dbo.F_Return_sec(AM.Late_Limit) else dbo.F_Return_sec(GS.Late_Limit) END as EmpLateLimitSec
					,Case when Cast(Shift_St_Time as Time) <> '00:00' then 
						case when  DateDiff(s,Shift_St_Time,In_Time) < 0 
							 then 0 
								when  DATEDIFF(S,Shift_St_Time,IN_TIME) > LTRIM(DATEDIFF(S, 0, AM.Late_Limit)) 
									then DATEDIFF(S,Shift_St_Time,IN_TIME)
							 else 0 
						end
					Else
						Case when DateDiff(s,Shift_St_Time,In_Time) < 0 then 0
						     when DateDiff(s,Shift_St_Time,In_Time) >  LTRIM(DATEDIFF(s, 0, AM.Late_Limit)) then  
							      DateDiff(s,Shift_St_Time,In_Time)
						else 0 end
					End  as LateMinuteSec
						,case when dbo.F_Return_sec(Emp_Early_Limit) > 0 then dbo.F_Return_sec(AM.Early_Limit) else dbo.F_Return_sec(GS.Early_Limit) END as EmpEarlyLimitSec
						,Case when Cast(Shift_End_Time as Time) <> '00:00' then 
						case when  DateDiff(s,OUT_time,Shift_End_Time) < 0 
							 then 0 
								when  DateDiff(s,OUT_time,Shift_End_Time) > LTRIM(DATEDIFF(S, 0, AM.Early_Limit)) 
									then DateDiff(s,OUT_time,Shift_End_Time)
							 else 0 
						end
					Else
						Case when DateDiff(s,OUT_time,Shift_End_Time) < 0 then 0
						     when DateDiff(s,OUT_time,Shift_End_Time) >  LTRIM(DATEDIFF(s, 0, AM.Early_Limit)) then  
							      DateDiff(s,OUT_time,Shift_End_Time)
						else 0 end
					End  as EarlyMinuteSec
					,GS.IsDeficit
					,DATEDIFF(s,In_Time,Out_Time) as DurationInTimeOutTime
					,DATEDIFF(s,Shift_St_Time,Shift_End_Time) as DurationShiftTime  
			FROM  #Emp_Late_Early AM 
			INNER JOIN #Emp_Cons E ON AM.Emp_ID=E.Emp_ID --and Am.P_days > 0 
			INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON E.INCREMENT_ID=I.INCREMENT_ID
			INNER JOIN T0040_GENERAL_SETTING GS WITH (NOLOCK) ON I.Branch_ID = GS.Branch_ID
			INNER JOIN(
						Select MAX(For_Date) as ForDate,Branch_ID FROM T0040_GENERAL_SETTING 
						Where Cmp_ID = @CMP_ID
						GROUP By Branch_ID
					  ) as QRY ON GS.For_Date = QRY.ForDate AND GS.Branch_ID = QRY.Branch_ID
		    WHERE (CASE WHEN GS.IS_LATE_MARK = 0 THEN 0 ELSE I.Emp_Late_Mark END) = 1  or	(I.Emp_Early_mark = 1 )
		) a

	-- Temporory
	--UPDATE  #TempData1 SET Out_Time = '2024-10-02 16:30:00.000' where Emp_ID = 4413  and For_Date = '2024-10-02 00:00:00.000' 
	--UPDATE  #TempData1 SET Out_Time = '2024-10-02 16:00:00.000'  where Emp_ID = 4413  and For_Date = '2024-10-03 00:00:00.000' 
	-- Temporory
	--UPDATE #Emp_Late_Early set Early_Deduction = 0 , Late_Deduction = 0 

	--Delete D from #Emp_Late_Early D inner  
	
	select ROW_NUMBER() OVER(partition by (emp_Id) ORDER BY (SELECT NULL)) AS RowNo,* 
	into #TempData 
	from #TempData1
	WHERE DURATIONINTIMEOUTTIME < DURATIONSHIFTTIME


	DELETE E from #TEMPDATA1 T inner join  #Emp_Late_Early E on T.Emp_ID = E.Emp_ID and t.For_Date = E.For_Date
	WHERE DURATIONINTIMEOUTTIME >= DURATIONSHIFTTIME

	--Delete E from #Emp_Late_Early E inner join #TEMPDATA T on E.Emp_ID = t.Emp_ID and E.For_Date = T.For_Date

	UPDATE #TEMPDATA set Early_Deduction = 0 , Late_Deduction = 0 
	--UPDATE E
	--SET E.Late_Deduction = 0 ,E.Early_Deduction = 0
	--From #TEMPDATA  E 
	--INNER JOIN  #Emp_Late_Early T on E.For_Date = T.For_Date  and E.Emp_ID = T.Emp_ID
	--WHERE DURATIONINTIMEOUTTIME >= DURATIONSHIFTTIME
	
	--select * from #TempData
	Alter Table #Emp_Late_Early  ADD Deduct_Days Numeric(18,2)

	--if exists(select 1 from #TempData) 
	--BEGIN
	--		Declare @empCount as int = 0
	--		DECLARE @empCounter INT = 1
	--		DECLARE @empID numeric(9,0) = 0
	--		SELECT @empCount = count(1) from #tmpEmp_cons

	--		Declare @EmpWiseMonthExemptLimitInSec as numeric = 0
	--		set @EmpWiseMonthExemptLimitInSec = @MonthExemptLimitInSec
	--		WHILE (@empCounter <= @empCount)
	--		BEGIN
	--							select @empID  = emp_id from #tmpEmp_cons where rn = @empCounter
	--							Declare @rowCount As Int = 0
	--							SELECT @rowCount = count(1) from #TEMPDATA where emp_id = @empID
	--							Declare @TotalLateAndEarlyMinuteSec as numeric(18,0) = 0
	--							Declare @TotalActualLimit as numeric(18,0) = 0
	--							Declare @For_date as DATE
	--							Declare @EMPId1 as int
	--							DECLARE @Counter INT = 1
	--							set @MonthExemptLimitInSec = @EmpWiseMonthExemptLimitInSec

	--							WHILE (@Counter <= @rowCount)
	--							BEGIN
										
	--									select @TotalLateAndEarlyMinuteSec = (LateMinuteSec + EarlyMinuteSec)
	--									,@TotalActualLimit = (ActualLateLimit + ActualEarlyLimit)
	--									,@For_date =T.For_date
	--									,@EMPId1 = t.Emp_ID
	--									from #TEMPDATA t 
	--									left join T0140_LEAVE_TRANSACTION L WITH (NOLOCK)  on T.emp_id =L.Emp_ID and T.For_date = L.For_Date and Leave_Used <> 1
	--									where RowNo = @Counter and T.emp_id = @empID 
										
	--									if @TotalLateAndEarlyMinuteSec > 0
	--									BEGIN
	--											if ((@MonthExemptLimitInSec- @TotalActualLimit) >= 0) 
	--											BEGIN	
	--												update #TEMPDATA set 
	--												DeductMonthLimit = (@MonthExemptLimitInSec- @TotalActualLimit)
	--												,Late_Deduction = 0 , Early_Deduction = 0  
	--												where RowNo = @Counter and emp_id = @empID
	--											END
	--									END
	--									IF ((@MonthExemptLimitInSec- @TotalActualLimit) >= 0) 
	--									BEGIN	
	--										 SET @MonthExemptLimitInSec = @MonthExemptLimitInSec - @TotalActualLimit
	--									END
	--									else 
	--									BEGIN
										
	--										UPDATE T SET LATE_DEDUCTION = LATEDEDUCT , EARLY_DEDUCTION = EARLYDEDUCT 
	--										FROM #TEMPDATA T  INNER JOIN  
	--										(
	--											SELECT EMP_ID,FOR_DATE
	--											, CASE WHEN LATE_SEC > 0 THEN 0.5 ELSE 0 END AS LATEDEDUCT 
	--											, CASE WHEN EARLY_SEC > 0 THEN 0.5 ELSE 0 END AS EARLYDEDUCT
	--											FROM #TEMPDATA
	--											WHERE ROWNO = @COUNTER AND EMP_ID = @EMPID
	--										) A ON A.EMP_ID = T.EMP_ID AND A.FOR_DATE = T.FOR_DATE
	--									END
	--									SET @Counter  = @Counter  + 1
	--							END
					
	--							Update d SET d.Early_Deduction = t.Early_Deduction , D.Late_Deduction = T.Late_Deduction
	--							FROM #Emp_Late_Early d 
	--							INNER JOIN #TEMPDATA T 
	--							ON d.For_date = t.For_date and D.Emp_Id = T.Emp_Id 
	--							where t. emp_id = @empID
	--				set @empCounter = @empCounter + 1
	--		END -- Outer while	
	--END

	Select ROW_Number() Over(Order by Emp_Id) as Rn, * into #TempEmpLateEarly from (
		select E.Emp_ID , cast((Sum(Late_Sec) + Sum(Early_Sec))/60 as int) as TotalMin , 0 as ToMin, E1.Branch_ID
		from #Emp_Late_Early E inner join #Emp_Cons E1 on E.Emp_ID = E1.Emp_ID
		where Late_Sec > 0 OR  Early_Sec > 0
		Group by E.Emp_ID, E1.Branch_ID
	) a 
	
	Select * into #TempGatepass from(
		SELECT distinct E.Branch_ID,G.Gen_ID ,FROM_MIN , TO_MIN ,DEDUCTION
		FROM #EMP_CONS E 
		INNER JOIN T0040_GENERAL_SETTING G ON E.BRANCH_ID = G.BRANCH_ID 
		INNER JOIN T0050_GENERAL_LATEMARK_SLAB G1 ON G.GEN_ID = G1.GEN_ID
	) b 

	--select * from #TempEmpLateEarly
	--select * from #TempGatepass
	
	-- Comment for Gallops Cases Deepal 14-11-2024
	--Declare @empCount as int = 0
	--DECLARE @empCounter INT = 1
	--DECLARE @empID numeric(9,0) = 0
	--select @empCount = count(1) from #tmpEmp_cons

	--Declare @EmpWiseMonthExemptLimitInSec as numeric = 0
	--set @EmpWiseMonthExemptLimitInSec = @MonthExemptLimitInSec
	--WHILE (@empCounter <= @empCount)
	--BEGIN
	--					select @empID  = emp_id from #tmpEmp_cons where rn = @empCounter
	--					Declare @rowCount As Int = 0
	--					SELECT @rowCount = count(1) from #TEMPDATA where emp_id = @empID
	--					Declare @TotalLateAndEarlyMinuteSec as numeric(18,0) = 0
	--					Declare @TotalActualLimit as numeric(18,0) = 0
	--					Declare @For_date as DATE
	--					Declare @EMPId1 as int
	--					DECLARE @Counter INT = 1
	--					set @MonthExemptLimitInSec = @EmpWiseMonthExemptLimitInSec
	--					WHILE (@Counter <= @rowCount)
	--					BEGIN
	--							select @TotalLateAndEarlyMinuteSec = (LateMinuteSec + EarlyMinuteSec)
	--							,@TotalActualLimit = (ActualLateLimit + ActualEarlyLimit)
	--							,@For_date =T.For_date
	--							,@EMPId1 = t.Emp_ID
	--							from #TEMPDATA t 
	--							left join T0140_LEAVE_TRANSACTION L WITH (NOLOCK)  on T.emp_id =L.Emp_ID and T.For_date = L.For_Date and Leave_Used <> 1
	--							where RowNo = @Counter and T.emp_id = @empID
								
	--							if @TotalLateAndEarlyMinuteSec > 0
	--							BEGIN
	--									if ((@MonthExemptLimitInSec- @TotalActualLimit) >= 0) 
	--									BEGIN	
	--										update #TEMPDATA set 
	--										DeductMonthLimit = (@MonthExemptLimitInSec- @TotalActualLimit)
	--										,Late_Deduction = 0 , Early_Deduction = 0  
	--										where RowNo = @Counter and emp_id = @empID
	--									END
	--							END
	--							IF ((@MonthExemptLimitInSec- @TotalActualLimit) >= 0) 
	--							BEGIN	
	--								 SET @MonthExemptLimitInSec = @MonthExemptLimitInSec - @TotalActualLimit
	--							END
	--							else 
	--							BEGIN
	--								--SELECT emp_Id,For_Date,case when Late_Sec > 0 then Late_Deduction else 0 END as LateDeduct 
	--									--, case when Early_Sec > 0 then Early_Deduction else 0 ENd as EarlyDeduct,Early_Sec,Late_Sec
	--									----,*
	--									--FROM #TempData
	--									--WHERE RowNo = @Counter and emp_id = @empID
	--								update T set Late_Deduction = LateDeduct , Early_Deduction = EarlyDeduct 
	--								from #TEMPDATA T  inner join  
	--								(
	--									SELECT emp_Id,For_Date
	--									, case when Late_Sec > 0 then 0.5 else 0 END as LateDeduct 
	--									, case when Early_Sec > 0 then 0.5 else 0 END as EarlyDeduct
	--									FROM #TempData
	--									WHERE RowNo = @Counter and emp_id = @empID
	--								) a on a.Emp_ID = T.Emp_ID and a.For_Date = t.For_Date

	--							END
	--							SET @Counter  = @Counter  + 1
	--					END
			
	--					Update d SET d.Early_Deduction = t.Early_Deduction 
	--					, D.Late_Deduction = T.Late_Deduction
	--					FROM #Emp_Late_Early d 
	--					INNER JOIN #TEMPDATA T 
	--					ON d.For_date = t.For_date and D.Emp_Id = T.Emp_Id 
	--					where t. emp_id = @empID
	--		set @empCounter = @empCounter + 1
	--END -- Outer while	
	-- Comment for Gallops Cases Deepal 14-11-2024
	
	--select Emp_ID,cast((Sum(Late_Sec) + Sum(Early_Sec))/60 as int) as TotalMin 
	--from #Emp_Late_Early 
	--where late_deduction > 0 OR  Early_Deduction > 0
	--Group by Emp_ID

	--select G.DEDUCTION from (
	--	select Emp_ID,cast((Sum(Late_Sec) + Sum(Early_Sec))/60 as int) as TotalMin 
	--	from #Emp_Late_Early 
	--	where late_deduction > 0 OR  Early_Deduction > 0
	--	Group by Emp_ID
	--) a inner join T0050_GENERAL_LATEMARK_SLAB G on (A.TotalMin >= From_min and  TO_MIN <= A.TotalMin)

	--select G.DEDUCTION from (
	--	select Emp_ID,cast((Sum(Late_Sec) + Sum(Early_Sec))/60 as int) as TotalMin 
	--	from #Emp_Late_Early 
	--	where late_deduction > 0 OR  Early_Deduction > 0
	--	Group by Emp_ID
	--) a inner join T0050_GENERAL_LATEMARK_SLAB G on (A.TotalMin >= From_min and  TO_MIN <= A.TotalMin)

	--WITH RECURSIVE TreeCTE AS (
 --   -- Start with nodes in the range
	--			select Emp_ID,cast((Sum(Late_Sec) + Sum(Early_Sec))/60 as int) as TotalMin 
	--			from #Emp_Late_Early 
	--			where late_deduction > 0 OR  Early_Deduction > 0
	--			Group by Emp_ID

	--			UNION ALL
	--			Select * from T0050_GENERAL_LATEMARK_SLAB
	--			-- Recursively find all child nodes
	--			SELECT t.id, t.parent_id, t.value
	--			FROM tree_table t
	--			INNER JOIN TreeCTE ON t.parent_id = TreeCTE.id
	--)
	--	SELECT * FROM TreeCTE;


	UPDATE #Emp_Late_Early  set Late_Deduction = 0 ,Early_Deduction = 0
	
	--select * from #TempEmpLateEarly
	--select * from #TempGatepass

	Declare @rowEmpNo as Int = 1
	Declare @tblRowNo as int = 0
	Declare @RowMin as int = 0
	Declare @rowCounter as int = 1
	Declare @rowEmpId as int = 0
	Declare @rowDeduct as numeric(18,2) = 0
	select @rowEmpNo = count(1) from #TempEmpLateEarly
	WHILE (@rowCounter <= @rowEmpNo)
	BEGIN
		SET @rowDeduct = 0
		SELECT @RowMin = TotalMin, @rowEmpId = Emp_ID from #TempEmpLateEarly where Rn = @rowCounter 
		SELECT @rowDeduct = DEDUCTION FROM #TempGatepass where @RowMin Between FROM_MIN and TO_MIN 
		UPDATE #Emp_Late_Early set Deduct_Days = @rowDeduct  where Emp_ID = @rowEmpId
	
		SET @rowCounter = @rowCounter + 1
	END
	
	--return
	--UPDATE E
	--set Deduct_Days = A.Deduction
	--From #Emp_Late_Early  E 
	--inner join (
	--	select Emp_ID , sum(DEDUCTION) as Deduction  
	--	from #TempEmpLateEarly T inner join #TempGatepass G on T.Branch_ID =G.Branch_ID
	--	where T.TotalMin between G.FROM_MIN and G.TO_MIN
	--	Group By Emp_ID
	--) A  
	--on E.Emp_ID = A.Emp_ID
	
	--Declare @TotalSumOfLateAndEarlyDeduction as Numeric(18,2) = 0
	--if exists(select 1 From #Emp_Late_Early where Late_Sec > 0 or Early_Sec > 0)
	--BEGIN
	--	Select @TotalSumOfLateAndEarlyDeduction = 
	--	sum(Late_Deduction) + sum(Early_Deduction) -- add the new commet
	--	From #Emp_Late_Early where Late_Sec > 0 or Early_Sec > 0
	--END
	
	if object_id('tempdb..#Late_Early_Deduction') is not null and @Flag = 1
	begin
	
			Insert into #Late_Early_Deduction
			select	
			 LE.Emp_ID,
			 LE.for_date,
			 Isnull(LE.Late_Deduction,0),
			 Isnull(LE.Early_Deduction,0),
			 Deduct_Days
			from #Emp_Late_Early LE
		
		return
	end 
		
	Select 
		Alpha_Emp_Code,Emp_Full_Name,Branch_Name,Grd_Name,Desig_Name,Dept_Name,EM.Emp_ID,
		CM.Cmp_Name,CM.Cmp_Address,In_Time,Out_Time,Shift_St_Time,Shift_End_Time,
		dbo.F_Return_Hours(Late_Sec) as Late_Hours,dbo.F_Return_Hours(Early_Sec) as Early_Hours,
		Late_Limit,Early_Limit,le.Late_Deduction,Early_Deduction,LE.For_Date,
		TM.Type_Name,VS.Vertical_Name,SV.SubVertical_Name,BM.Branch_Address,BM.Comp_Name,DM.Dept_Dis_no,
		@From_Date As From_Date,@To_Date as To_Date,LE.ExemptFlag
		--,@TotalSumOfLateAndEarlyDeduction as Deduct_Days
		,Deduct_Days
	From #Emp_Late_Early LE
	Inner join T0080_EMP_MASTER EM WITH (NOLOCK) ON LE.EMP_ID = EM.EMP_ID
	Inner Join #Emp_Cons EC ON EC.Emp_ID = LE.Emp_ID
	INNER Join T0095_INCREMENT I WITH (NOLOCK)  ON I.Increment_ID = EC.Increment_ID
	INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK)  ON BM.Branch_ID = I.Branch_ID
	INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK)  ON GM.Grd_ID = I.Grd_ID
	Left Outer Join T0040_DESIGNATION_MASTER Desig WITH (NOLOCK)  ON Desig.Desig_ID = I.Desig_Id
	Left Outer Join T0040_DEPARTMENT_MASTER DM WITH (NOLOCK)  ON DM.Dept_Id = I.Dept_ID
	Inner join T0010_COMPANY_MASTER CM WITH (NOLOCK)  ON CM.Cmp_Id = LE.Cmp_ID
	Left Outer join T0040_TYPE_MASTER TM WITH (NOLOCK)  ON TM.Type_ID = I.Type_ID
	Left Outer Join T0040_Vertical_Segment VS WITH (NOLOCK)  ON Vs.Vertical_ID = I.Vertical_ID
	Left Outer Join T0050_SubVertical SV WITH (NOLOCK)  ON SV.SubVertical_ID = I.SubVertical_ID
	
END
