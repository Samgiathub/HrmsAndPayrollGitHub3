
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P_EMP_LATE_EARLY_EMAIL_NOTIFY]	 
	@Cmp_ID			Numeric,
	@CC_Email		Varchar(128) = ''
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	DECLARE @Branch_ID NUMERIC
	DECLARE @From_Date datetime
	DECLARE @To_Date  datetime
	DECLARE @VERY_LATE_LIMIT NUMERIC = (10 * 60) --(Minutes X Seconds);
	
	SET @From_Date = CONVERT(DATETIME, CONVERT(VARCHAR(10), DATEADD(M, -1, GETDATE()), 103), 103);
	
	SET @From_Date = DATEADD(d, (DAY(@From_Date) * -1)+1, @From_Date);
	SET @TO_DATE = CONVERT(DATETIME, CONVERT(VARCHAR(10), DATEADD(D, -1, DATEADD(MONTH, 1, @From_Date)), 103) + ' 23:59:59', 103);
	
		
	Declare @Sal_St_Date	Datetime
	Declare @Sal_end_Date   Datetime 
	Declare @OutOf_Days		NUMERIC  
	Declare @Is_Cancel_Holiday_WO_HO_same_day tinyint --Added By nilesh on 01122015(For Cancel Holiday When WO/HO on Same Day
    Set @Is_Cancel_Holiday_WO_HO_same_day = 0

	declare @manual_salary_period as numeric(18,0)
	
	
	CREATE TABLE #Emp_Cons 
	(      
		Emp_ID numeric ,     
		Branch_ID numeric,
		Increment_ID numeric    
	)  

	INSERT	INTO #Emp_Cons 	
	SELECT	DISTINCT I1.Emp_ID,I1.branch_id,I1.Increment_ID 
	FROM	T0095_INCREMENT I1 WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON I1.Emp_ID=E.Emp_ID
			INNER JOIN (SELECT	MAX(I2.Increment_ID) AS Increment_ID, I2.Emp_ID
						FROM	T0095_INCREMENT I2 WITH (NOLOCK)
								INNER JOIN (SELECT	MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
											FROM	T0095_INCREMENT I3 WITH (NOLOCK)
											WHERE	I3.Increment_Effective_Date <= @To_Date
											GROUP BY I3.Emp_ID
											) I3 ON I2.Increment_Effective_Date=I3.INCREMENT_EFFECTIVE_DATE AND I2.Emp_ID=I3.Emp_ID																								
						WHERE	Cmp_ID=@Cmp_ID
						GROUP BY I2.Emp_ID
						) I2 ON I1.Emp_ID=I2.Emp_ID AND I1.Increment_ID=I2.INCREMENT_ID	
	WHERE	Increment_Effective_Date <= @To_Date AND I1.Cmp_ID=@Cmp_ID
		   AND ( (@From_Date  >= E.Date_Of_Join AND  @From_Date <= e.Emp_Left_Date )      
					or ( @To_Date  >= Date_Of_Join  AND @To_Date <= Emp_Left_Date )      
					or (Emp_Left_Date is null AND @To_Date >= Date_Of_Join)      
					or (@To_Date >= Emp_Left_Date  AND  @From_Date <= Emp_Left_Date ))  --and I1.eMP_ID=48
	ORDER BY I1.Emp_ID
	
	DECLARE @CONSTRAINT VARCHAR(MAX)
	
	SELECT @CONSTRAINT = COALESCE(@CONSTRAINT + '#','') + CAST(EMP_ID AS VARCHAR(20)) FROM #Emp_Cons
	
	Select	TOP 1 @Branch_ID = Branch_ID FROM #Emp_Cons T 
		
	select	@Sal_St_Date  =Sal_st_Date ,@manual_salary_period=isnull(Manual_Salary_Period ,0),
			@Is_Cancel_Holiday_WO_HO_same_day = Is_Cancel_Holiday_WO_HO_same_day
	from	T0040_GENERAL_SETTING WITH (NOLOCK)
	where	cmp_ID = @cmp_ID and Branch_ID = @Branch_ID    
			and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <= @To_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)    
	
		
		
	if isnull(@Sal_St_Date,'') = ''    
		  begin    
			   set @From_Date  = @From_Date     
			   set @To_Date = @To_Date    
			   set @OutOf_Days = @OutOf_Days
		  end  
		     
	 else if day(@Sal_St_Date) =1
		  begin    
			   set @From_Date  = @From_Date     
			   set @To_Date = @To_Date    
			   set @OutOf_Days = @OutOf_Days    	         
		  end
		  		  
	else if @Sal_St_Date <> ''  and day(@Sal_St_Date) > 1   
		  begin   
			if @manual_salary_period = 0 
		       begin
			        set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@From_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@From_Date) )as varchar(10)) as smalldatetime)    
			        set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date)) 
			        set @OutOf_Days = datediff(d,@Sal_St_Date,@Sal_End_Date) + 1
			   
			        Set @From_Date = @Sal_St_Date
			        Set @To_Date = @Sal_End_Date 
			   end 
			else
				begin
					select @Sal_St_Date=from_date,@Sal_End_Date=end_date from salary_period where month= month(@From_Date) and YEAR=year(@From_Date)
					set @OutOf_Days = datediff(d,@Sal_St_Date,@Sal_End_Date) + 1
				    Set @From_Date = @Sal_St_Date
				    Set @To_Date = @Sal_End_Date 
			    end   
		  end
	

	
	declare @For_Date datetime 
	Declare @Date_Diff numeric 
	Declare @New_To_Date datetime 
	Declare @Row_ID	numeric 
	
	set @Date_Diff = datediff(d,@From_Date,@to_DAte) + 1 
	set @Date_Diff = 35 - ( @Date_Diff)
	set @New_To_Date = @To_Date --dateadd(d,@date_diff,@To_Date)
	
	Create TABLE #Att_Period
	  (
		For_Date	datetime,
		Row_ID		numeric
	  )
	
	set @For_Date = @From_Date
	set @Row_ID = 1
	

	While @For_Date <= @New_To_Date
		begin
			
			insert into #Att_Period 
			select @For_Date,@Row_ID
			
			set @Row_ID =@Row_ID + 1
			set @for_Date = dateadd(d,1,@for_date)
		end
		
	
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
	   P_days  numeric(12,1) default 0,        
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

	CREATE NONCLUSTERED INDEX ix_Data_Emp_Id_For_date on #Data(Emp_Id,For_Date);
	
	Create TABLE #Att_Muster
	(
		Emp_Id		numeric , 
		Cmp_ID		numeric,
		branch_ID	numeric,
		For_Date	datetime,
		Status		varchar(10),
		Leave_code	varchar(10) default '-',
		Leave_Count	numeric(5,2),
		OD			varchar(10) default '-',
		OD_Count	numeric(5,2),
		WO_HO		varchar(2),
		Status_2	varchar(10),
		Row_ID		numeric ,
		In_Date		datetime,
		Out_Date	Datetime,
		shift_id	numeric,
		shift_name  varchar(50),
		sh_in_time varchar(10),
		sh_out_time varchar(10),
		holiday varchar(50),
		late_limit varchar(10),
		Reason varchar(1000),
		Half_Full_Day Varchar(20),
		Chk_By_Superior varchar(15),
		Sup_Comment varchar(1000),
		Is_Cancel_Late_In tinyint,  -- Alpesh 02-Aug-2011 For Attendance Regularization
		Is_Cancel_Early_Out tinyint, -- Alpesh 02-Aug-2011 For Attendance Regularization
		Early_Limit varchar(10),
		Main_Status varchar(10),
		Detail_Status varchar(50),
		Is_Late_Calc_On_HO_WO	tinyint,
		Is_Early_Calc_On_HO_WO	tinyint,
		late_minute numeric default 0, -- Added by rohit on 18102013
		Early_minute Numeric default 0, -- Added by rohit on 18102013
		Is_Leave_App tinyint default 0,
		Other_Reason	varchar(1000)	null	--Added by Nimesh 31-Aug-2015
	)

	CREATE UNIQUE NONCLUSTERED INDEX ix_Att_Muster_Emp_Id on #Att_Muster(Emp_Id,For_Date) INCLUDE(Cmp_ID,Branch_ID);	  
	
	declare @get_date as datetime
	set @get_date=cast(getdate() as varchar(11))
	
	insert into #Att_Muster (Emp_ID,Cmp_ID,branch_ID,For_Date,row_ID)
	select 	Emp_ID ,@Cmp_ID,branch_ID,For_Date,row_ID from #Att_Period cross join #Emp_Cons
		
	--Add by Nimesh 21 April, 2015
	--This sp retrieves the Shift Rotation as per given employee id and effective date.
	--it will fetch all employee's shift rotation detail if employee id is not specified.

	IF (OBJECT_ID('tempdb..#Rotation') IS NULL)
		Create Table #Rotation (R_EmpID numeric(18,0), R_DayName varchar(25), R_ShiftID numeric(18,0), R_Effective_Date DateTime);
	--The #Rotation table gets re-created in dbo.P0050_UNPIVOT_EMP_ROTATION stored procedure
	Exec dbo.P0050_UNPIVOT_EMP_ROTATION @Cmp_ID, NULL, @To_Date, @constraint


	--Added for adding weekk off n holiday detail of whole month Alpesh 09-Sep-2011
	DECLARE @Main_To_Date DATETIME
	SET @Main_To_Date = @To_Date
	
	IF @get_date<@To_Date
		SET @To_Date=@get_date    
							
	SET @For_Date = @From_Date
	DECLARE @Att_date AS DATETIME
	SELECT @Att_date= max(for_date) FROM #Att_Muster
	WHILE @for_Date <= @Att_date
		BEGIN
			--Modified by Nimesh  20 May 2015
			--Updating default shift info From Shift Detail
			UPDATE	#Att_Muster SET SHIFT_ID = Shf.Shift_ID
			FROM	#Att_Muster AM INNER JOIN (SELECT esd.Shift_ID, esd.Emp_ID 
			FROM	T0100_EMP_SHIFT_DETAIL esd WITH (NOLOCK) INNER JOIN  
					(SELECT MAX(For_Date) AS For_Date,ESD.Emp_ID FROM T0100_EMP_SHIFT_DETAIL ESD WITH (NOLOCK) INNER JOIN #Emp_Cons EC on ESD.Emp_ID = EC.Emp_ID
						WHERE Cmp_ID = ISNULL(@Cmp_ID,Cmp_ID) AND For_Date <= @For_Date GROUP BY ESD.Emp_ID) S ON 
						esd.Emp_ID = S.Emp_ID AND esd.For_Date=s.For_Date) Shf ON 
					Shf.Emp_ID = AM.EMP_ID 
			WHERE	AM.For_Date=@For_Date

			
			--Updating Shift ID From Rotation
			UPDATE	#Att_Muster 
			SET		SHIFT_ID=SM.SHIFT_ID
			FROM	#Rotation R INNER JOIN T0040_SHIFT_MASTER SM WITH (NOLOCK) ON R.R_ShiftID=SM.Shift_ID					
			WHERE	SM.Cmp_ID=@Cmp_ID AND R.R_DayName = 'Day' + CAST(DATEPART(d, @for_Date) As Varchar) AND
					Emp_Id=R.R_EmpID AND R.R_Effective_Date=(SELECT MAX(R_Effective_Date)
						FROM #Rotation R1 WHERE R1.R_EmpID=Emp_Id AND 
							 R_Effective_Date<=@for_Date) 
					AND For_Date=@For_Date
					

			
			--Updating Shift ID from Employee Shift Detail where ForDate=@TempDate ANd Shift_Type=1 
			--And Rotation should be assigned to that particular employee
			UPDATE	#Att_Muster 
			SET		shift_id=ESD.SHIFT_ID
			FROM	#Att_Muster D INNER JOIN (SELECT esd.Shift_ID, esd.Emp_ID, esd.Shift_Type,esd.For_Date
					FROM T0100_EMP_SHIFT_DETAIL esd WITH (NOLOCK) INNER JOIN #Emp_Cons EC on ESD.Emp_ID = EC.Emp_ID
					WHERE Cmp_ID = ISNULL(@Cmp_ID,Cmp_ID) AND For_Date = @For_Date) ESD ON
					D.Emp_Id=ESD.Emp_ID AND D.For_date=ESD.For_Date				
			WHERE	ESD.Emp_ID IN (
									Select	DISTINCT R.R_EmpID 
									FROM	#Rotation R
									WHERE	R_DayName = 'Day' + CAST(DATEPART(d, @For_Date) As Varchar) 
											AND R_Effective_Date<=@For_Date
								) 
					AND D.For_date=@For_Date

			
			--Updating Shift ID from Employee Shift Detail where ForDate=@TempDate ANd Shift_Type=1 
			--And Rotation should not be assigned to that particular employee
			UPDATE	#Att_Muster 
			SET		SHIFT_ID=ESD.SHIFT_ID
			FROM	#Att_Muster D INNER JOIN (SELECT esd.Shift_ID, esd.Emp_ID, esd.Shift_Type,esd.For_Date
					FROM T0100_EMP_SHIFT_DETAIL esd WITH (NOLOCK) INNER JOIN #Emp_Cons EC on ESD.Emp_ID = EC.Emp_ID
					WHERE Cmp_ID = ISNULL(@Cmp_ID,Cmp_ID) AND For_Date = @For_Date) ESD ON
					D.Emp_Id=ESD.Emp_ID AND D.For_date=ESD.For_Date				
			WHERE	ESD.Emp_ID NOT IN (
											Select	DISTINCT R.R_EmpID 
											FROM	#Rotation R
											WHERE	R_DayName = 'Day' + CAST(DATEPART(d, @For_Date) As Varchar) 
													AND R_Effective_Date<=@For_Date
										) 
					AND IsNull(ESD.Shift_Type,0)=1 AND D.For_date=@For_Date
			--End Nimesh

			
			update #Att_Muster set  
				 --Late_limit = QW.late_limit
				--,Early_Limit = qw.Early_Limit
				 Is_Late_Calc_On_HO_WO = QW.Is_Late_Calc_On_HO_WO
				,Is_Early_Calc_On_HO_WO = QW.Is_Early_Calc_On_HO_WO
			From #Att_Muster   AM inner join 
			(select Q_w.for_date,Em.Emp_ID, Q_W.late_limit,Q_W.Early_Limit,Q_W.Is_Late_Calc_On_HO_WO,Q_W.Is_Early_Calc_On_HO_WO from v0080_employee_master EM 
				INNER JOIN #Emp_Cons EC on EM.Emp_ID= EC.Emp_ID
				left outer join 
			 (select Q.branch_id,Q1.for_date,Q1.late_limit,Q1.Early_Limit,Q1.Is_Late_Calc_On_HO_WO,Q1.Is_Early_Calc_On_HO_WO from T0040_GENERAL_SETTING Q1 WITH (NOLOCK) inner join
					 (select max(For_Date)as For_Date,branch_id from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <= @For_Date and Cmp_Id = @Cmp_ID group by branch_id )Q 
			   on Q1.branch_id =Q.branch_id and Q1.For_DAte = Q.For_Date)Q_W
			 on EM.branch_id=Q_W.Branch_id)QW
			ON AM.EMP_ID = QW.EMP_ID 
			where AM.FOR_DATE = @for_Date
			
			update #Att_Muster set  
				 Late_limit = Q_I.Emp_Late_Limit
				,Early_Limit = Q_I.Emp_Early_Limit				
			From #Att_Muster AM inner join 
				(Select isnull(I.Emp_Late_Limit,'00:00') Emp_Late_Limit,isnull(I.Emp_Early_Limit,'00:00') Emp_Early_Limit,I.Emp_ID 
				 FROM T0095_Increment I WITH (NOLOCK) INNER JOIN #Emp_Cons EC on I.Emp_ID = EC.Emp_ID inner join 
					(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
						(Select Max(Increment_Effective_Date) as Increment_Effective_Date,I.Emp_ID from T0095_Increment I WITH (NOLOCK) INNER JOIN #Emp_Cons EC on I.Emp_ID = EC.Emp_ID
						Where Increment_effective_Date <= @to_date and Cmp_ID = @Cmp_id Group by I.Emp_ID) new_inc
						on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
						Where TI.Increment_effective_Date <= @to_date and TI.Cmp_ID = @Cmp_id group by ti.emp_id
					) Qry on I.Increment_Id = Qry.Increment_Id
					--(Select max(Increment_effective_Date) as For_Date , Emp_ID From T0095_Increment where Increment_Effective_date <= @To_Date and Cmp_ID = @Cmp_ID
					--	group by emp_ID) Qry on I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date	
				)Q_I ON AM.EMP_ID = Q_I.EMP_ID			
			where AM.FOR_DATE = @for_Date
					
			
			set @for_Date = dateadd(d,1,@for_date)
		end
				
	--Added by Nimesh 21 April,2015
	--Finally Updating other shift infor from update Shift ID
	UPDATE	#Att_Muster 
	SET		SHIFT_NAME=SM.SHIFT_NAME,
			SH_IN_TIME =SM.SHIFT_ST_TIME,
			SH_OUT_TIME=SM.SHIFT_END_TIME
	FROM	T0040_SHIFT_MASTER SM INNER JOIN #Att_Muster AM ON 
			SM.Shift_ID=AM.shift_id 
	WHERE	SM.Cmp_ID=@Cmp_ID
				
	--End Nimesh
	
	update #Att_Muster set 
		Late_limit=0			
	where Late_limit = ''
	
	update #Att_Muster set 
		Early_Limit=0			
	where Early_Limit = ''
	
		
	--Ankit 25112014--
	
	Declare @Is_Cancel_Weekoff Numeric(1,0)
	Declare @Weekoff_Days Numeric(12,1)
	Declare @Cancel_Weekoff Numeric(12,1)
	Declare @Emp_Week_Detail numeric(18,0)
	Declare @StrWeekoff_Date varchar(Max)
	
	Declare @Is_Cancel_Holiday Numeric(1,0)
	Declare @Holiday_days Numeric(12,1)
	Declare @Cancel_Holiday Numeric(12,1)
	Declare @StrHoliday_Date varchar(Max)
	
	
	---Alpesh 3-Oct-2011
	declare	@Half_Day numeric(18,1)
	declare @HalfDay_Date varchar(500)
	declare @Temp_dt datetime
	declare @Shift_St_Time_Half_Day varchar(20)
	declare @Shift_End_Time_Half_Day varchar(20)
	
	
	DECLARE @EMP_ID NUMERIC
	
	DECLARE CUR_EMP CURSOR FOR
	SELECT EMP_ID,Branch_ID FROM #Emp_CONS Order by Branch_ID, EMP_ID
	
	OPEN CUR_EMP 
	FETCH NEXT FROM CUR_EMP INTO @EMP_ID,@Branch_ID
	
	WHILE (@@FETCH_STATUS = 0)
		BEGIN			
			select	@manual_salary_period=isnull(Manual_Salary_Period ,0),
					@Is_Cancel_Holiday_WO_HO_same_day = Is_Cancel_Holiday_WO_HO_same_day
			from	T0040_GENERAL_SETTING WITH (NOLOCK)
			where	cmp_ID = @cmp_ID and Branch_ID = @Branch_ID    
					and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <= @To_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)    
			
		
			exec GET_HalfDay_Date @Cmp_ID,@Emp_ID,@From_Date,@Main_To_Date,@Half_Day, @HalfDay_Date output	
			
			Update	A
			SET		sh_in_time =  SM.Half_St_Time,
					sh_out_time = SM.Half_End_Time
			from	#Att_Muster A INNER JOIN T0040_SHIFT_MASTER SM ON A.shift_id=A.shift_id					
					INNER JOIN (SELECT CAST(DATA AS DATETIME) AS HALF_DATE FROM dbo.Split(@HalfDay_Date, ';') T WHERE DATA <> '') T ON A.For_Date=T.HALF_DATE
			where	sm.Is_Half_Day = 1 
			 	
			
			SET @StrWeekoff_Date = NULL;
			SET @StrHoliday_Date = NULL;
			SET @Weekoff_Days = NULL;
			SET @Holiday_days = NULL;
			SET @Cancel_Weekoff = NULL;
			SET @Cancel_Holiday = NULL;
			
			-- Added by Nilesh Patel on 01122015 -Start 
			if @Is_Cancel_Holiday_WO_HO_same_day = 1 
				Begin
					Exec dbo.SP_EMP_WEEKOFF_DATE_GET @Emp_ID,@Cmp_ID,@From_Date,@To_Date,null,null,@Is_Cancel_weekoff,'',@StrWeekoff_Date output,@Weekoff_Days output ,@Cancel_Weekoff output
					Exec dbo.SP_EMP_HOLIDAY_DATE_GET @Emp_ID,@Cmp_ID,@From_Date,@To_Date,null,null,@Is_Cancel_Holiday,@StrHoliday_Date output,@Holiday_days output,@Cancel_Holiday output,0,0,@StrWeekoff_Date
					--Added by nilesh Patel on 01122015
				End
			Else
				Begin
					Exec dbo.SP_EMP_HOLIDAY_DATE_GET @Emp_ID,@Cmp_ID,@From_Date,@To_Date,null,null,@Is_Cancel_Holiday,@StrHoliday_Date output,@Holiday_days output,@Cancel_Holiday output,0,0,null
					Exec dbo.SP_EMP_WEEKOFF_DATE_GET @Emp_ID,@Cmp_ID,@From_Date,@To_Date,null,null,@Is_Cancel_weekoff,'',@StrWeekoff_Date output,@Weekoff_Days output ,@Cancel_Weekoff output
				End
			-- Added by Nilesh Patel on 01122015 -End 
			
					
			UPDATE	#Att_Muster
			SET		WO_HO = 'W' ,Main_Status='W'
			FROM	#Att_Muster Att INNER JOIN dbo.Split(@StrWeekoff_Date,';') ON Att.For_date = Data
			WHERE	EMP_ID=@EMP_ID
			
			-- Added by nilesh Patel on 01122015
			UPDATE	#Att_Muster
			SET		WO_HO = 'HO' ,Main_Status='HO'
			FROM	#Att_Muster Att INNER JOIN dbo.Split(@StrHoliday_Date,';') ON Att.For_date = Data
			WHERE	EMP_ID=@EMP_ID
			-- Added by nilesh Patel on 01122015
			
			
			
			FETCH NEXT FROM CUR_EMP INTO @EMP_ID,@Branch_ID
		END
	
	CLOSE CUR_EMP
	DEALLOCATE CUR_EMP
	

	
	--- Add by Hardik 16/08/2011 for Alternate Weekoff setting

	Declare @Row_No as int
	Declare @Alt_W_Full_Day_Cont varchar(100)
	Declare @Count as int
	Set @Count = 0

	update #Att_Muster
	set Status = 'P'
	from #Att_Muster AM inner join T0150_EMP_INOUT_RECORD EIR ON AM.EMP_ID = EIR.EMP_ID
	AND AM.FOR_DATE = EIR.FOR_DATE 
	where (NOT EIR.IN_TIME IS NULL or NOT EIR.Out_Time IS NULL)	--Alpesh 30-May-2012
	--where NOT EIR.IN_TIME IS NULL
	and Am.For_Date >=@From_Date and Am.For_Date <=@To_Date
	
	
	
	-- done by mitesh on 24/11/2011 - to display two different 0.5 leave on same day START
		
	update #Att_Muster
	set Leave_Count = LT.Leave_Used
		,status='L'
		,Leave_code= substring(LT.Leave_code,2,LEN(LT.Leave_code))
		,Main_Status='L'
		,Detail_Status= substring(LT.Leave_code,2,LEN(LT.Leave_code)) +'-'+ cast(dbo.F_Lower_Round(LT.Leave_Used,LT.Cmp_ID) as varchar)
	from #Att_Muster AM inner join				--Changed By Gadriwala Muslim 01102014

	(SELECT     LT1.Cmp_ID,  LT1.Emp_ID, LT1.For_Date, (sum(IsNull(case when LT1.Back_Dated_Leave > 0 THEN LT1.Back_Dated_Leave when Apply_Hourly=0 then LT1.Leave_Used else lt1.Leave_Used *0.125 End, 0)) 
	) as Leave_Used,
	 (select '/' + lmin.Leave_Code from T0040_LEAVE_MASTER as lmin WITH (NOLOCK) where lmin.Leave_ID in 
	 (
	 select leave_id from T0140_LEAVE_TRANSACTION as LT2 WITH (NOLOCK) where lt2.For_Date = LT1.For_Date and lt2.Emp_ID = LT1.Emp_ID and 
	 (lt2.Leave_Used > 0 )
	 ) and Leave_Type <> 'Company Purpose' and isnull(Default_Short_Name,'') <>'COMP'  FOR XML PATH ('')
	 ) AS Leave_Code FROM  T0140_LEAVE_TRANSACTION AS LT1 WITH (NOLOCK) Inner Join #Emp_Cons EC on LT1.Emp_ID = Ec.Emp_ID
	 LEFT OUTER JOIN T0040_LEAVE_MASTER AS EA WITH (NOLOCK) ON LT1.Leave_ID = EA.Leave_ID WHERE EA.Cmp_ID  = @Cmp_Id And LT1.Leave_Used > 0 and   
	 (EA.Leave_Type <> 'Company Purpose') and Leave_Paid_Unpaid='P' and isnull(Default_Short_Name,'')<>'COMP' group by LT1.Cmp_ID,  LT1.Emp_ID, LT1.For_Date)LT   --EA.Leave_code<>'OD' and
	ON AM.EMP_ID = LT.EMP_ID
	AND AM.FOR_DATE = LT.FOR_DATE 
	where LT.Leave_Used  >0
	and Am.For_Date >=@From_Date and Am.For_Date <=@Main_To_Date 
	
	
	update #Att_Muster
	set Leave_Count = LT.Leave_Used 
		,status='L'
		,Leave_code= substring(LT.Leave_code,2,LEN(LT.Leave_code))
		,Main_Status='L'
		,Detail_Status= substring(LT.Leave_code,2,LEN(LT.Leave_code)) +'-'+ cast(dbo.F_Lower_Round(LT.Leave_Used,Lt.Cmp_ID) as varchar)
	from #Att_Muster AM inner join				--Changed By Gadriwala Muslim 01102014

	(SELECT     LT1.Cmp_ID,  LT1.Emp_ID, LT1.For_Date, (sum(IsNull(case when Apply_Hourly=0 then (LT1.CompOff_Used - LT1.Leave_Encash_Days) else (LT1.CompOff_Used - LT1.Leave_Encash_Days) *0.125 End,0)) 
	) as Leave_Used,
	 (select '/' + lmin.Leave_Code from T0040_LEAVE_MASTER as lmin WITH (NOLOCK) where lmin.Leave_ID in 
	 (
	 select leave_id from T0140_LEAVE_TRANSACTION as LT2 WITH (NOLOCK) where lt2.For_Date = LT1.For_Date and lt2.Emp_ID = LT1.Emp_ID and 
	 ((lt2.CompOff_Used - lt2.Leave_Encash_Days) > 0 )
	 ) and Leave_Type <> 'Company Purpose' and isnull(Default_Short_Name,'') ='COMP'  FOR XML PATH ('')
	 ) AS Leave_Code FROM  T0140_LEAVE_TRANSACTION AS LT1 WITH (NOLOCK)  Inner Join #Emp_Cons EC on LT1.Emp_ID = Ec.Emp_ID
	 LEFT OUTER JOIN T0040_LEAVE_MASTER AS EA WITH (NOLOCK) ON LT1.Leave_ID = EA.Leave_ID WHERE EA.Cmp_ID  = @Cmp_Id And LT1.CompOff_Used > 0 and      
	 (EA.Leave_Type <> 'Company Purpose') and Leave_Paid_Unpaid='P' and isnull(Default_Short_Name,'')='COMP' group by LT1.Cmp_ID,  LT1.Emp_ID, LT1.For_Date)LT   --EA.Leave_code<>'OD' and
	ON AM.EMP_ID = LT.EMP_ID
	AND AM.FOR_DATE = LT.FOR_DATE 
	where LT.Leave_Used  >0
	and Am.For_Date >=@From_Date and Am.For_Date <=@Main_To_Date 

	-- done by mitesh on 24/11/2011 - to display two different 0.5 leave on same day END
	
	

	update #Att_Muster
	set OD_count = (LT.Leave_Used) --Changed By Gadriwala Muslim 01102014
		,status='OD'
		,OD= LT.Leave_code
		,Main_Status='OD'
		,Detail_Status= substring(LT.Leave_code,2,LEN(LT.Leave_code)) +'-'+ cast(dbo.F_Lower_Round(LT.Leave_Used,Lt.Cmp_ID)as varchar)
	from #Att_Muster AM inner join (select LT1.Cmp_ID, LT1.Leave_Used,LT1.Emp_ID,LT1.For_date,EA.Leave_code,EA.Leave_type from T0140_LEAVE_TRANSACTION LT1 WITH (NOLOCK) Inner Join #Emp_Cons EC on LT1.Emp_ID = EC.Emp_ID left outer join 
	t0040_leave_master EA WITH (NOLOCK) on LT1.leave_id=EA.Leave_id where EA.Leave_type='Company Purpose' and isnull(EA.Default_Short_Name,'') <> 'COMP' And EA.Cmp_ID = @Cmp_Id And LT1.Leave_Used>0)LT    --EA.Leave_code='OD' and 
	ON AM.EMP_ID = LT.EMP_ID
	AND AM.FOR_DATE = LT.FOR_DATE 
	where (LT.Leave_Used > 0 )
	and Am.For_Date >=@From_Date and Am.For_Date <=@Main_To_Date

	update #Att_Muster
	set OD_count = (LT.CompOff_Used -isnull(lt.Leave_Encash_Days,0)) --Changed By Gadriwala Muslim 01102014
		,status='OD'
		,OD= LT.Leave_code
		,Main_Status='OD'
		,Detail_Status= substring(LT.Leave_code,2,LEN(LT.Leave_code)) +'-'+ cast(dbo.F_Lower_Round(LT.CompOff_Used,LT.cmp_ID)as varchar)
	from #Att_Muster AM inner join (select LT1.Cmp_ID, LT1.CompOff_Used,LT1.Leave_Encash_Days,LT1.Emp_ID,LT1.For_date,EA.Leave_code,EA.Leave_type from T0140_LEAVE_TRANSACTION LT1 WITH (NOLOCK) Inner Join #Emp_Cons EC on LT1.Emp_ID = EC.Emp_ID left outer join 
	t0040_leave_master EA WITH (NOLOCK) on LT1.leave_id=EA.Leave_id where EA.Leave_type='Company Purpose' and isnull(EA.Default_Short_Name,'') = 'COMP' And EA.Cmp_ID = @Cmp_Id and LT1.CompOff_Used>0)LT    --EA.Leave_code='OD' and 
	ON AM.EMP_ID = LT.EMP_ID
	AND AM.FOR_DATE = LT.FOR_DATE 
	where ((LT.CompOff_Used - ISNULL(lt.Leave_Encash_Days,0))  > 0 )
	and Am.For_Date >=@From_Date and Am.For_Date <=@Main_To_Date

	
	
	---- Alpesh 06-Dec-2011 for Unpaid Leaves for which we dont maintain balance in T0140_LEAVE_TRANSACTION
	declare @lwp_EmpId numeric
	declare @lwp_LeaveId numeric
	declare @lwp_Leave_Code varchar(20)
	declare @lwp_FromDate datetime
	declare @lwp_ToDate datetime
	declare @lwp_Period numeric(18,1)
	declare @lwp_Leave_Assign varchar(20)
	declare @flag int
	declare @lwp_Leave_Remain numeric(18,1)
	declare @lwp_For_date datetime
	
	
	set @flag = 0
	set @lwp_Leave_Remain = 0
	
	UPDATE	A
	SET		Leave_Count = 1,
			STATUS = 'LWP',
			Leave_code =	CASE WHEN (LT.LEAVE_USED > 0.5) THEN	
								LM.Leave_Code 
							ELSE
								CASE WHEN A.Leave_Code IS NULL OR A.Leave_Code= '' or A.Leave_Code = '-' THEN 
									LM.Leave_Code 
								else 
									A.Leave_Code 
								end														
							END,
			Main_Status='LWP',
			Detail_Status= @lwp_Leave_Code + CASE WHEN (LT.LEAVE_USED > 0.5) THEN '-1.0' ELSE '-0.5' END
	FROM	#Att_Muster A  INNER JOIN T0140_LEAVE_TRANSACTION LT ON A.Emp_Id=LT.Emp_ID AND A.For_Date=LT.For_Date
			INNER JOIN T0040_LEAVE_MASTER LM on LT.Leave_ID = lm.Leave_ID
	where	LT.For_Date <= @Main_To_Date and lt.For_Date>=@From_Date and lt.Leave_Used>0 
			and LT.Cmp_ID=@cmp_id AND LM.Leave_Paid_Unpaid='U' and lT.LEAVE_USED > 0

	--declare cur1 cursor for 
	--	select lt.Emp_ID,lt.Leave_ID,lm.Leave_Code,For_Date,lt.Leave_Used as leave_period from T0140_LEAVE_TRANSACTION LT
	--			inner join T0040_LEAVE_MASTER LM on LT.Leave_ID = lm.Leave_ID
	--		where LT.For_Date <= @Main_To_Date and lt.For_Date>=@From_Date and lt.Leave_Used>0 and LT.Cmp_ID=@cmp_id and Emp_ID=@emp_id and  LM.Leave_Paid_Unpaid='U'
			
	--open cur1
	--fetch next from cur1 into @lwp_EmpId,@lwp_LeaveId,@lwp_Leave_Code,@lwp_For_date,@lwp_Period
	--while @@fetch_status = 0
	--begin			
	--				if @lwp_Period > 0.5
	--				  begin
	--					update #Att_Muster set
	--						 Leave_Count = 1
	--						,status = 'LWP'
	--						,Leave_code = @lwp_Leave_Code 
	--						,Main_Status='LWP'
	--						,Detail_Status= @lwp_Leave_Code +'-1.0'
	--					Where EMP_ID = @lwp_EmpId and CONVERT(varchar(10),For_Date,120) = CONVERT(varchar(10),@lwp_For_date,120)												
						
	--				  end
	--				else  										
	--				  begin
	--					update #Att_Muster set
	--						 Leave_Count = 0.5
	--						,status = 'LWP'
	--						,Leave_code = case when Leave_code Is null or Leave_code='' or Leave_code = '-' then @lwp_Leave_Code else Leave_code end
	--						,Main_Status='LWP'
	--						,Detail_Status= @lwp_Leave_Code +'-0.5'
	--					Where EMP_ID = @lwp_EmpId and CONVERT(varchar(10),For_Date,120) = CONVERT(varchar(10),@lwp_For_date,120)												
					
	--				  end	
					
	--	fetch next from cur1 into @lwp_EmpId,@lwp_LeaveId,@lwp_Leave_Code,@lwp_For_date,@lwp_Period
	--end
	--close cur1
	--deallocate cur1


	Update #Att_Muster
	set Status = WO_HO
	Where isnull(Status,'') <> '' and ( WO_HO = 'HO' or WO_HO = 'W')
	and For_Date >=@From_Date and For_Date <=@Main_To_Date  --Alpesh 09-Sep-2011
	--and For_Date >=@From_Date and For_Date <=@To_Date
	
			
	Update #Att_Muster set 
		 Status ='A'
		,Main_Status='A'
	Where Status is null
	and For_Date >=@From_Date and For_Date <=@To_Date

	
	
	Update #Att_Muster
	Set In_Date =In_time
	From #Att_Muster AM inner join 
	( select min(In_Time) In_Time ,Emp_Id,For_Date from T0150_EMP_INOUT_RECORD WITH (NOLOCK)
		Where Cmp_ID = @cmp_ID and For_Date>=@From_Date and For_Date <=@To_Date
		group by Emp_ID ,for_date 
	)q on Am.Emp_ID =q.emp_ID  and am.for_Date = Q.for_Date

	

	Update #Att_Muster
	Set Out_Date = Case When Max_In_Time > OUT_Time Then Max_In_Time Else OUT_Time End
	From #Att_Muster AM inner join 
	( select Max(Out_Time) OUT_Time ,Emp_Id,For_Date from T0150_EMP_INOUT_RECORD WITH (NOLOCK)
		Where Cmp_ID = @cmp_ID and For_Date>=@From_Date and For_Date <=@To_Date
		group by Emp_ID ,for_date 
	)q on Am.Emp_ID =q.emp_ID  and am.for_Date = Q.for_Date Left Outer Join
	( select Max(In_Time) Max_In_Time ,Emp_Id,For_Date from T0150_EMP_INOUT_RECORD WITH (NOLOCK)
		Where Cmp_ID = @cmp_ID and For_Date>=@From_Date and For_Date <=@To_Date
		group by Emp_ID ,for_date 
	)q1 on Am.Emp_ID =q1.emp_ID  and am.for_Date = Q1.for_Date
	
	Update #Att_Muster
	Set Reason = isnull(Q.Reason,''), Other_Reason=q.Other_Reason
	From #Att_Muster AM inner join 
	(select reason,Other_Reason,for_date,emp_ID from T0150_EMP_INOUT_RECORD WITH (NOLOCK) inner join T0040_Reason_Master rm WITH (NOLOCK) on reason=rm.Reason_Name
		Where Cmp_ID = @cmp_ID and For_Date>=@From_Date and For_Date <=@To_Date and Reason is not null And Reason <> ''
	 )q on Am.Emp_ID =q.emp_ID  and am.for_date = Q.for_date
	
	----Nikunj 08-June-2011---------
	Update #Att_Muster
	Set Half_Full_Day = isnull(Q.Half_Full_Day,'')
	From #Att_Muster AM inner join 
	(Select Half_Full_Day,for_date,emp_ID From T0150_EMP_INOUT_RECORD WITH (NOLOCK)
		Where Cmp_ID = @cmp_ID and For_Date>=@From_Date and For_Date <=@To_Date and Half_Full_Day is not null And Half_Full_Day <> ''
	 )q on Am.Emp_ID =q.emp_ID  and am.for_date = Q.for_date
	
	----Nikunj 08-June-2011---------
	
	--Update #Att_Muster
	--set Status =  dbo.F_Return_HHMM(cast(datepart(hh,In_Date) as varchar(2))+ ':'+ cast(datepart(mi,In_Date) as varchar(2)))
	--where Status = 'P'
	Update #Att_Muster
	set Status =  dbo.F_Return_HHMM(cast(datepart(hh,In_Date) as varchar(2))+ ':'+ cast(datepart(mi,In_Date) as varchar(2)))
	where In_Date is not null --Status = 'P' and	--Alpesh 30-May-2012
	
	Update #Att_Muster
	set Status_2 =  dbo.F_Return_HHMM(cast(datepart(hh,OUT_Date) as varchar(2))+ ':'+ cast(datepart(mi,OUT_Date) as varchar(2)))
	where not OUT_Date is null

	
	Update #Att_Muster set 
		 Status = WO_HO
	    ,Main_Status = WO_HO 
	where In_Date is null and ( WO_HO = 'W' or WO_HO = 'HO' )


	Update #Att_Muster
	set Status = '-'
	where isnull(Status,'')=''
	
		
	--Alpesh 5-Jun-2012
		
	Update #Att_Muster
	set Status = '-'
	where In_Date is null and OUT_Date is not null
	
	Update #Att_Muster
	set Main_Status='P'
	where In_Date is not null and OUT_Date is not null
	
	
	Update #Att_Muster set 		 
	    Main_Status = WO_HO 
	where ( WO_HO = 'W' or WO_HO = 'HO' )
	-- End--
	
	Update #Att_Muster set 		 
	    Main_Status = WO_HO 
	where ( WO_HO = 'W' or WO_HO = 'HO' )
	-- End--
	
	----------Alpesh 28-Jun-2011----------
	
	Update #Att_Muster
	Set Chk_By_Superior = isnull(Q.Chk_By_Superior,'')
	From #Att_Muster AM inner join 
	(Select Chk_By_Superior = case Chk_By_Superior when 2 then 'Rejected' when 1 then 'Approved' when 0  then 'Pending' else '' end ,for_date,emp_ID From T0150_EMP_INOUT_RECORD WITH (NOLOCK)
		inner join T0040_Reason_Master rm WITH (NOLOCK) on reason=rm.Reason_Name
		Where Cmp_ID = @cmp_ID and For_Date>=@From_Date and For_Date <=@To_Date and Chk_By_Superior is not null
		and (Reason is not null and Reason<>'')
	 )q on Am.Emp_ID =q.emp_ID  and am.for_date = Q.for_date
	
	
	Update #Att_Muster
	Set Sup_Comment = isnull(Q.Sup_Comment,'')
	From #Att_Muster AM inner join 
	(Select Sup_Comment,for_date,emp_ID From T0150_EMP_INOUT_RECORD WITH (NOLOCK)
		Where Cmp_ID = @cmp_ID and For_Date>=@From_Date and For_Date <=@To_Date and Sup_Comment is not null
	 )q on Am.Emp_ID =q.emp_ID  and am.for_date = Q.for_date
	---------------end-----------------
	----------Alpesh 02-Aug-2011----------
	 Update #Att_Muster
	Set Is_Cancel_Late_In = isnull(Q.Is_Cancel_Late_In,0)
	From #Att_Muster AM inner join 
	(Select Is_Cancel_Late_In,for_date,emp_ID From T0150_EMP_INOUT_RECORD WITH (NOLOCK)
		Where Cmp_ID = @cmp_ID and For_Date>=@From_Date and For_Date <=@To_Date
	 )q on Am.Emp_ID =q.emp_ID  and am.for_date = Q.for_date
	 
	 Update #Att_Muster
	Set Is_Cancel_Early_Out = isnull(Q.Is_Cancel_Early_Out,0)
	From #Att_Muster AM left outer join 
	(Select Is_Cancel_Early_Out,for_date,emp_ID From T0150_EMP_INOUT_RECORD WITH (NOLOCK)
		Where Cmp_ID = @cmp_ID and For_Date>=@From_Date and For_Date <=@To_Date and Is_Cancel_Early_Out = 1
	 )q on Am.Emp_ID =q.emp_ID  and am.for_date = Q.for_date
	---------------end-----------------
	--Alpesh 8-Jun-2012
	Update #Att_Muster Set
		Status=null
	Where len(Status)<=3
	
	Update #Att_Muster Set
		Status='-'
	where status is null AND for_date>GETDATE() 
	
	--if @Emp_ID is not null
	exec dbo.SP_CALCULATE_PRESENT_DAYS @Cmp_ID,@From_Date,@To_Date,0,0,0,0,0,0,0,@constraint,4
	----- End ----	
	--Nimesh 20 April,2015
	--This query will update the shift information according to updated shift in #Data table in 
	--SP_CALCULATE_PRESENT_DAYS stored procedure. The shifts are retrieveing from Employee Monthly 
	--Shift Rotation Details.
	UPDATE	#Att_Muster
	SET		shift_name=SM.shift_name, 
			sh_in_time =CONVERT(varchar(5),D.Shift_Start_Time, 108),
			sh_out_time=CONVERT(varchar(5),D.Shift_End_Time, 108),
			shift_id=D.Shift_ID
	FROM	(#Data D INNER JOIN #Att_Muster A ON D.Emp_ID=A.Emp_ID AND D.For_Date=A.For_Date)
			INNER JOIN T0040_SHIFT_MASTER SM ON D.Shift_ID=SM.Shift_ID 
	WHERE	SM.Cmp_ID=@Cmp_ID


-- Added by rohit on 28012013
	Update #Att_Muster
	set Main_Status='A'
	from #Att_Muster AM inner join #Data D on
	AM.Emp_Id = D.Emp_Id and AM.For_Date=d.For_Date
	where P_Days='0.0' and main_status not in ('W','HO','L','OD','P') and od <> 'OD' and isnull(leave_count,0) <= 0
	-- ended by rohit on 28012013	
	
	
	-- Added by rohit on 28012013
	Update #Att_Muster
	set Main_Status='L'
	from #Att_Muster AM 
	where  isnull(leave_count,0) > 0 and isnull(leave_code,'-') <> '-'
	
	Update #Att_Muster
	set Main_Status='OD'
	from #Att_Muster AM 
	where  isnull(od_count,0) > 0 and isnull(OD,'-') <> '-'
		
	-- ended by rohit on 28012013	
	
	---- Added by rohit on 18102013		
	-- Late Minute condition added by Hardik 21/12/2015 for 12 AM Shift
    update #Att_Muster
    set late_minute = Case when sh_in_time <> '00:00' then 
						case when datediff(mi,cast(cast(AM.for_date as varchar(11)) + ' ' + AM.sh_in_time as datetime),In_Date)<0 then 0 
						else datediff(mi,cast(cast(AM.for_date as varchar(11)) + ' ' + AM.sh_in_time as datetime),In_Date) end
					Else
						Case when datediff(mi,cast(cast(dateadd(d,1,AM.for_date) as varchar(11)) + ' ' + AM.sh_in_time as datetime),In_Date) < 0 then 0
						else datediff(mi,cast(cast(dateadd(d,1,AM.for_date) as varchar(11)) + ' ' + AM.sh_in_time as datetime),In_Date) end
					
					End
    ,Early_minute = case when datediff(mi,Out_Date,cast(cast((case when AM.sh_in_time > AM.sh_out_time then dateadd(d,1,AM.for_date) else AM.for_date end) as varchar(11)) + ' ' + AM.sh_out_time as datetime))<0 then 0 else datediff(mi,Out_Date,cast(cast((case when AM.sh_in_time > AM.sh_out_time then dateadd(d,1,AM.for_date) else AM.for_date end) as varchar(11)) + ' ' + AM.sh_out_time as datetime)) end
    from #Att_Muster AM

	
    
   Update #Att_Muster  
	set late_minute = 0 
	from #Att_Muster EL
		inner join (select la.Leave_Approval_ID,la.Emp_ID,lad.half_leave_date from T0120_LEAVE_APPROVAL la WITH (NOLOCK)
				inner join T0130_LEAVE_APPROVAL_DETAIL lad WITH (NOLOCK) on la.Leave_Approval_ID = lad.Leave_Approval_ID
				where Leave_Assign_As = 'First Half' and Approval_Status = 'A') Qry 
		on Qry.Emp_ID = el.Emp_ID and Qry.half_leave_date = el.For_Date
  
       
   Update #Att_Muster  
	set Early_minute = 0
   from #Att_Muster EL
		inner join (select la.Leave_Approval_ID,la.Emp_ID,lad.half_leave_date from T0120_LEAVE_APPROVAL la WITH (NOLOCK)
				inner join T0130_LEAVE_APPROVAL_DETAIL lad WITH (NOLOCK) on la.Leave_Approval_ID = lad.Leave_Approval_ID
				where Leave_Assign_As = 'Second Half' and Approval_Status = 'A') Qry 
		on Qry.Emp_ID = el.Emp_ID and Qry.half_leave_date = el.For_Date
  
	declare @T table
	(
		ID int identity primary key,
		FromDate datetime,
		ToDate datetime,
		H_Leave_Date datetime
	)
	insert into @T (FromDate,ToDate,H_Leave_Date)  
	( select  From_Date,To_Date,Half_Leave_Date from  V0110_LEAVE_APPLICATION_DETAIL LAD where Cmp_ID = @cmp_ID  and Emp_ID = @Emp_ID and (MONTH(From_Date) = MONTH(@from_Date) and YEAR(To_date) = YEAR(@To_Date)) and Leave_Assign_As <> 'Part Day')
	
	
	Update #Att_Muster  set Is_Leave_App = 1 where For_Date in  
		(select D.Dates from @T as T inner join master..spt_values as N
		on N.number between 0 and datediff(day, T.FromDate, T.ToDate)
		cross apply (select dateadd(day, N.number, T.FromDate)) as D(Dates)
		where N.type ='P' and  D.Dates <> T.H_Leave_Date 
		)		
	---- ended by rohit on 18102013

	----Added by Sid to remove those codes where leave and present days becomes full day 25062014


	update at 
	set Is_Leave_App = 1 
	from #Att_Muster at
	inner join #Data d on
	at.Emp_Id = d.Emp_Id and at.For_Date = d.For_date
	where Leave_Count + p_days >=1 


	--delete from #Att_Muster Where late_minute <= (dbo.F_Return_Sec(late_limit) /60)  or Early_minute <= (dbo.F_Return_Sec(Early_Limit) / 60)
	delete from #Att_Muster Where (IsNull(late_minute,0) = 0 AND IsNull(Early_minute,0) = 0) 
	
	
	--Select	AM.*,datediff(mi,AM.for_date,cast(cast(AM.for_date as varchar(11)) + ' ' + AM.late_limit as datetime))late_time,
	--		datediff(mi,AM.for_date,cast(cast(AM.for_date as varchar(11)) + ' ' + AM.Early_Limit as datetime))early_time,
	--		AM.late_minute as late_minutes,AM.Early_minute as early_out,
	--		E.Alpha_Emp_Code,E.Emp_full_Name,Branch_Name,Dept_Name,Grd_Name,Desig_Name,Branch_Address,Comp_Name,DBRD_Code,isnull(d.P_days,0.0) P_days,Emp_Late_mark,Emp_Early_mark,
	--		E.Work_Email			
	SELECT	ROW_NUMBER() OVER(PARTITION BY AM.EMP_ID ORDER BY AM.EMP_ID, AM.FOR_DATE) AS ROW_ID, AM.Emp_ID,AM.Cmp_ID, E.Alpha_Emp_Code,E.Emp_Full_Name,E.Work_Email,AM.For_Date,AM.sh_in_time,AM.sh_out_time,SM.Shift_Dur,Cast(d.P_days As Varchar(5)) As P_Days,
			dbo.F_GET_AMPM(AM.[STATUS]) AS In_Time, dbo.F_GET_AMPM(AM.STATUS_2) As Out_Time,
			Cast(dbo.F_Return_Hours(d.Duration_in_sec) As VarChar(10)) As Total_Work, 
			Cast(dbo.F_Return_Hours(AM.late_minute * 60) AS VARCHAR(10)) As Late_Minute, Cast(dbo.F_Return_Hours(AM.Early_minute * 60) AS VARCHAR(10)) As Early_Minute,
			Late_Limit,Early_limit--, 0 As VeryLateEarly
	INTO	#Reminder
	From	#Att_Muster  AM Inner join T0080_EMP_MASTER E ON AM.EMP_ID = E.EMP_ID
			INNER JOIN ( SELECT I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Emp_ID,isnull(I.Emp_Late_mark,0) Emp_Late_mark,isnull(I.Emp_Early_mark,0) Emp_Early_mark 
						FROM T0095_Increment I inner join 
							(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
								(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
								Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
								on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
								Where TI.Increment_effective_Date <= @to_date group by ti.emp_id
							) Qry on I.Increment_Id = Qry.Increment_Id
					)Q_I ON E.EMP_ID = Q_I.EMP_ID 										
			INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON Q_I.Grd_Id = gm.Grd_ID
			INNER JOIN T0040_SHIFT_MASTER SM WITH (NOLOCK) ON AM.shift_id=SM.Shift_ID AND AM.Cmp_ID=SM.Cmp_ID
			INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Q_I.BRANCH_ID = BM.BRANCH_ID
			LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON Q_I.DEPT_ID = DM.DEPT_ID 
			LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON Q_I.DESIG_ID = DGM.DESIG_ID 
			LEFT OUTER JOIN #Data d ON AM.Emp_ID=d.Emp_Id and AM.For_Date=d.For_Date
	Order by Emp_Code,Am.For_Date
	
	DELETE FROM #Reminder
	WHERE	NOT (dbo.F_Return_Sec(Late_Minute) - dbo.F_Return_Sec(Late_limit) > 0 OR dbo.F_Return_Sec(Early_Minute) - dbo.F_Return_Sec(Early_Limit) > 0)
	
	
	INSERT	INTO #Reminder(ROW_ID,EMP_ID,CMP_ID,SH_OUT_TIME,SHIFT_DUR,TOTAL_WORK,LATE_MINUTE,EARLY_MINUTE)	
	SELECT	ROW_ID,EMP_ID,CMP_ID,SH_OUT_TIME,SHIFT_DUR,TOTAL_WORK,LATE_MINUTE,EARLY_MINUTE
	FROM	(
				SELECT	(MAX(ROW_ID) + 1) AS ROW_ID,EMP_ID,CMP_ID,'TOTAL' AS SH_OUT_TIME,
						dbo.F_Return_Hours(Sum(dbo.F_Return_Sec(Shift_Dur))) As Shift_Dur,						
						dbo.F_Return_Hours(Sum(dbo.F_Return_Sec(LATE_MINUTE))) As LATE_MINUTE,
						dbo.F_Return_Hours(Sum(dbo.F_Return_Sec(TOTAL_WORK))) As TOTAL_WORK,
						dbo.F_Return_Hours(Sum(dbo.F_Return_Sec(EARLY_MINUTE))) As EARLY_MINUTE
				FROM	#Reminder
				GROUP BY EMP_ID,CMP_ID
			) T
	
	UPDATE #Reminder
	SET		SHIFT_DUR = CASE WHEN LEN(SHIFT_DUR) > 5 THEN  REPLACE(CAST(CAST(REPLACE(SHIFT_DUR, ':', '.') AS NUMERIC(9,2)) AS VARCHAR(10)), '.', ':') ELSE SHIFT_DUR END,	
			TOTAL_WORK = CASE WHEN LEN(TOTAL_WORK) > 5 THEN  REPLACE(CAST(CAST(REPLACE(TOTAL_WORK, ':', '.') AS NUMERIC(9,2)) AS VARCHAR(10)), '.', ':') ELSE TOTAL_WORK END,	
			LATE_MINUTE = CASE WHEN LEN(LATE_MINUTE) > 5 THEN  REPLACE(CAST(CAST(REPLACE(LATE_MINUTE, ':', '.') AS NUMERIC(9,2)) AS VARCHAR(10)), '.', ':') ELSE LATE_MINUTE END,	
			EARLY_MINUTE = CASE WHEN LEN(EARLY_MINUTE) > 5 THEN  REPLACE(CAST(CAST(REPLACE(EARLY_MINUTE, ':', '.') AS NUMERIC(9,2)) AS VARCHAR(10)), '.', ':') ELSE EARLY_MINUTE END
	WHERE	SH_OUT_TIME = 'TOTAL'
	
	Declare  @TableHead NVARCHAR(max)
	Set @TableHead =	'<html>
							<head>
								<style>
									td {border: solid black 1px;padding-left:5px;padding-right:5px;padding-top:1px;padding-bottom:1px;font-size:8pt;} 
									#detail tr td{ text-align:center; }
								</style>
							</head>
							<body>
								<div style=" font-family:Arial, Helvetica, sans-serif; color:Black;  text-decoration:none; font-weight:bold; text-align:center; font-size:13px;">
									Dear @@Emp_Name 
								</div><br/>					
								  
								<table width="800" border="0" align="center" cellpadding="0" cellspacing="0" style="border:1px solid #cacaca; border-radius: 10px 10px 10px 10px;" >
									<tr >
										<td align="center" valign="middle">
											<table width="800" border="0" cellspacing="0" cellpadding="0">
												<tr>
													<td height="9" align="center" valign="middle" style="border:0px"></td>
												</tr>
												<tr>
													<td width="800" height="24" align="center" valign="middle" style="background:#0b0505; border-radius: 10px 10px 10px 10px; font-family:Arial, Helvetica, sans-serif; color:#FFFFFF;  text-decoration:none; font-weight:bold; text-align:center; font-size:13px;"> 
														Late/Early Report For ( Date From ' + convert(varchar(15),@From_Date,103) + ' To ' + convert(varchar(15),@to_date,103) +  ') 
													</td>
												</tr>
												<tr>
													<td height="4" align="center" valign="middle"  style="border:0px"></td>
												</tr>
												<tr>
													<td height="8" align="center" valign="middle"  style="border:0px"></td>
												</tr>
											</table>										                                    
											<table id="detail" border="1" width="1000" height="24" align="center" valign="middle" style="background: #FFFFF;border-color:solid black;
												font-family: Arial, Helvetica, sans-serif;
												color: #000000; text-decoration: none; font-weight: normal; text-align: left;
												font-size: 12px;">
												<tr border="1">
													<td align=center><span style="font-size:small"><b>Code</b></span></td>
													<td align=center><b><span style="font-size:small">For Date</span></b></td>
													<td align=center><b><span style="font-size:small">Shift In Time</span></b></td>
													<td align=center><b><span style="font-size:small">Shift Out Time</span></b></td>
													<td align=center><b><span style="font-size:small">Shift Duration</span></b></td>
													<td align=center><b><span style="font-size:small">In Time</span></b></td>
													<td align=center><b><span style="font-size:small">Out Time</span></b></td>
													<td align=center><b><span style="font-size:small">Duration</span></b></td>
													<td align=center><b><span style="font-size:small">P Days</span></b></td>
													<td align=center><b><span style="font-size:small">Late In</span></b></td>
													<td align=center><b><span style="font-size:small">Early Out</span></b></td>										
												</tr>'

	DECLARE @TableTail NVARCHAR(max)  
	--SET @TableTail =	'<tr border="1">
	--						<td align=center><span style="font-size:small"><b>@Code</b></span></td>
	--						<td align=center><b><span style="font-size:small">@For_Date</span></b></td>
	--						<td align=center><b><span style="font-size:small">@Shift_In_Time</span></b></td>
	--						<td align=center><b><span style="font-size:small">@Shift_Out_Time</span></b></td>
	--						<td align=center><b><span style="font-size:small">@Shift_Duration</span></b></td>
	--						<td align=center><b><span style="font-size:small">@In_Time</span></b></td>
	--						<td align=center><b><span style="font-size:small">@Out_Time</span></b></td>
	--						<td align=center><b><span style="font-size:small">@Duration</span></b></td>
	--						<td align=center><b><span style="font-size:small">@Late_In</span></b></td>
	--						<td align=center><b><span style="font-size:small">@Early_Out</span></b></td>										
	--					</tr>'
	
	Declare @EmpEmail_ID VARCHAR(256)	
	Declare @Emp_Name as varchar(255)
	DECLARE @EMAIL_BODY NVARCHAR(MAX);
	DECLARE @EMAIL_PROFILE as VARCHAR(50)
	
	Declare @EMAIL_SUBJECT as varchar(max)           
	
	DECLARE @MONTH VARCHAR(32);
	
	SET @MONTH =  DATENAME(MONTH, @To_Date) + ' - ' + CAST(YEAR(@TO_DATE) AS VARCHAR(4)) 
	
	DECLARE Cur_Employee CURSOR FOR
	SELECT Emp_Id,Work_Email,Emp_Full_Name 
	FROM #Reminder T 
	WHERE (WORK_EMAIL <> '' OR @CC_Email <> '') AND Emp_Full_Name IS NOT NULL
	GROUP BY Emp_Id,Work_Email,Emp_Full_Name ORDER BY T.Emp_Id
	
	OPEN Cur_Employee                      
	FETCH NEXT FROM Cur_Employee INTO @Emp_Id,@EmpEmail_ID,@Emp_Name
	WHILE @@FETCH_STATUS = 0                    
		BEGIN   
			  			
			IF IsNull(@EmpEmail_ID,'')	= '' 
				SET @EmpEmail_ID = @CC_Email			
								  				
			SET @EMAIL_BODY = (SELECT  
										IsNull(Alpha_Emp_Code, '-')  As [td],
										IsNull(Convert(Varchar(10), For_Date , 103),'-') as [td],
										Isnull(sh_in_time,'-') as [td],
										Isnull(sh_out_time,'-') as [td],
										Isnull(Shift_Dur,'-') as [td],
										IsNull(In_Time,'-') as [td],
										IsNull(Out_Time,'-')  as [td],
										Isnull(Total_Work,'-') as [td],
										IsNull(P_Days,'-') as [td],
										(CASE WHEN dbo.F_Return_Sec(Late_Minute) >= @VERY_LATE_LIMIT AND sh_out_time <> 'TOTAL' THEN 
											'<span style="color:red;font-weight:bold;">' + Late_minute + '</span>'
										Else 
											Late_minute
										END) as [td],
										(CASE WHEN dbo.F_Return_Sec(Early_minute) >= @VERY_LATE_LIMIT AND sh_out_time <> 'TOTAL' THEN 
											'<span style="color:red;font-weight:bold;">' + Early_minute + '</span>'
										Else 
											Early_minute
										END) as [td]									
                               FROM    #Reminder T
                               WHERE   Emp_ID = @Emp_Id 
                               ORDER BY  T.ROW_ID For XML raw('tr'), ELEMENTS
                              ) 
					
			SET @EMAIL_BODY = REPLACE(REPLACE(REPLACE(@EMAIL_BODY, '&lt;', '<'), '&gt;', '>'), '<td>', '<td align="center">')
			SET @EMAIL_BODY = REPLACE(@TableHead, '@@Emp_Name', @Emp_Name) + @EMAIL_BODY + '</table> </td> </tr> </table> </body> </html>'
           			           		  
			
			SET @EMAIL_SUBJECT = 'Late/Early Report (' + @MONTH + ') - ' +  @EMP_NAME
           		  
			
       		SET @EMAIL_PROFILE = NULL
       					  
       		SELECT @EMAIL_PROFILE = ISNULL(DB_Mail_Profile_Name,'') from t9999_Reminder_Mail_Profile where cmp_id = @Cmp_Id       					  
       		
       		IF ISNULL(@EMAIL_PROFILE,'') = ''
       			SELECT @EMAIL_PROFILE = ISNULL(DB_Mail_Profile_Name,'') from t9999_Reminder_Mail_Profile where cmp_id = 0
			
			
			
			IF ISNULL(@EMAIL_PROFILE,'') <> ''
				EXEC msdb.dbo.sp_send_dbmail @profile_name = @EMAIL_PROFILE, @recipients = @EmpEmail_ID, @subject = @EMAIL_SUBJECT, @body = @EMAIL_BODY, @body_format = 'HTML',@copy_recipients = @CC_Email
			
			--For Testing	
			--IF ISNULL(@EMAIL_PROFILE,'') <> ''
			--	EXEC msdb.dbo.sp_send_dbmail @profile_name = @EMAIL_PROFILE, @recipients = 'nimesh.p@orangewebtech.com', @subject = @EMAIL_SUBJECT, @body = @EMAIL_BODY, @body_format = 'HTML',@copy_recipients = @CC_Email
				
				
			--return; Commented by Sumit on 04072016 after discussion with rohit bhai
NEXT_EMP:
			
			Set @EmpEmail_ID = NULL
			Set @Emp_Name = NULL
			FETCH NEXT FROM Cur_Employee INTO @Emp_Id,@EmpEmail_ID,@Emp_Name
		END                    
	CLOSE Cur_Employee                    
	DEALLOCATE Cur_Employee    	
	
	RETURN


