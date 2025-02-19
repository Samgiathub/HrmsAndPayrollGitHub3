


---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0380_EMP_IN_OUT_SHIFT_TIME_GET]
	 @Cmp_ID 		numeric
	,@From_Date		datetime
	,@To_Date 		datetime
	,@Branch_ID		numeric
 	,@Emp_ID 		numeric
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	--Added By Hiral 15 April,2013 (Start)
	Declare @Sal_St_Date	Datetime
	Declare @Sal_end_Date   Datetime 
	Declare @OutOf_Days		NUMERIC  
	--Added By Hiral 15 April,2013 (End)
	--Added By Hiral 15 April,2013 (Start)
	declare @manual_salary_period as numeric(18,0)

	 CREATE TABLE #tmpEMPINOUT
	 (
		intid			int identity,
		IO_Tran_Id		numeric,
		For_Date		Datetime,
		In_Time			varchar(10),
		Out_Time1		varchar(10),
		Duration		varchar(10),
		Reason			varchar(1000),
		Out_Time		Datetime,
		Late_Calc_Not_App tinyint,
		Shift_Name		varchar(50),
		Sh_In_time		varchar(10),
		Sh_Out_time		varchar(10),
		Manual_Flag		char(3) default 'N',
		In_DateTime		Datetime,	--Added By Ramiz 21/05/2018
		Out_DateTime    Datetime,
		Duration_in_sec	numeric,	--Added By Ramiz 17/10/2018,
		DayIndex		int ,
		Reason_disable	tinyint default 0   --Added By Jimit 29122018
		,IsNightShift	tinyint default 0   --Added By Jimit 29122018
		,ChkBySuperior	tinyint default 0
	)	

   
	 /*The Following Condition Added By Nimesh On 14-Sep-2018 (If this SP is being executed from Leave Application Page for particalar Date then record should be return only for this day)*/	
	IF DateDiff(d, @From_Date, @To_Date) > 1
	BEGIN  
				
			IF @Branch_ID = 0  
				SET @Branch_ID = null
				
			IF @Emp_ID = 0  
				SET @Emp_ID = null
				
				
			IF @Branch_ID is null
				begin
					select @Branch_ID  = Branch_ID 
					from dbo.T0095_Increment EI WITH (NOLOCK)
					where Increment_ID in (select max(Increment_ID) as Increment_ID from dbo.T0095_Increment WITH (NOLOCK)  where Increment_Effective_date <= @To_Date  
					and Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID) 
					and Emp_ID = @Emp_ID	-- Ankit 12092014 for Same Date Increment
				End

			If @Branch_ID is null
				Begin 
					select Top 1 @Sal_St_Date  = Sal_st_Date ,@manual_salary_period=isnull(Manual_Salary_Period ,0) 
					  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID    
					  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <= @To_Date and Cmp_ID = @Cmp_ID)    
				End
			Else
				Begin
					select @Sal_St_Date  =Sal_st_Date ,@manual_salary_period=isnull(Manual_Salary_Period ,0) 
					  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID and Branch_ID = @Branch_ID    
					  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <= @To_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)    
				End 
				
				
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
				  
			END
	ELSE --- Added Below Code by Hardik 29/12/2018 for Cliantha as In Leave Application, Auto Shift not working
		BEGIN
			
				CREATE TABLE #Emp_Cons 
				 (      
					Emp_ID numeric ,     
					Branch_ID numeric,
					Increment_ID numeric
				 )      
				
				EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,0,0,0,0,0,0,@Emp_ID,'',0 ,0 ,0,0,0,0,0,0,0,0,0,0
				
				
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

				EXEC P_GET_EMP_INOUT @Cmp_ID, @FROM_DATE, @TO_DATE,1

				
				
				If NOT EXISTS(select 1 from #Data)
					GOTO COMMON_CODE
				
				Declare @Emp_ID_AutoShift numeric
				Declare @In_Time_Autoshift datetime
				Declare @Out_Time_Autoshift datetime	--Added By Ramiz on 25/10/2016
				Declare @New_Shift_ID numeric
				DECLARE @AUTO_SHIFT_GRPID AS TINYINT   --Added By Jimit 03022018

				Declare @Shift_ID_Autoshift numeric
				Declare @Shift_start_time_Autoshift varchar(12)
				Declare @Shift_End_time_Autoshift varchar(12)
				Declare @IsNightShift tinyint = 0
				

				If exists(select 1 from T0040_SHIFT_MASTER s WITH (NOLOCK) where Isnull(s.Inc_Auto_Shift,0) = 1 and s.Cmp_ID=@Cmp_id)
					BEGIN
							
							
							SELECT @In_Time_Autoshift = d.In_Time, @Out_Time_Autoshift = d.Out_Time, @New_Shift_ID = d.Shift_ID, @AUTO_SHIFT_GRPID = ISNULL(Auto_Shift_Group,0) 
							,@IsNightShift = isnull(s.IsNightShift,0)
							FROM #Data d inner join T0040_SHIFT_MASTER s WITH (NOLOCK) on d.Shift_ID = s.Shift_ID 
							WHERE Isnull(s.Inc_Auto_Shift,0) = 1 
							ORDER BY In_time,Emp_ID
							
							SELECT	TOP 1 @Shift_ID_Autoshift =  Shift_ID ,@Shift_start_time_Autoshift = Shift_St_Time , @Shift_End_time_Autoshift = Shift_End_Time ,@IsNightShift = isnull(IsNightShift,0)
							FROM	T0040_SHIFT_MASTER WITH (NOLOCK)
							WHERE	Cmp_ID = @Cmp_ID AND Auto_Shift_Group = @AUTO_SHIFT_GRPID And Isnull(Inc_Auto_Shift,0)=1
							ORDER BY ABS(datediff(s,@In_Time_Autoshift,cast(CONVERT(VARCHAR(11),Case When DATEPART(hh,Shift_St_Time)=0 And DATEPART(hh,@In_Time_Autoshift) <> 0 THEN DATEADD(dd,1,@In_Time_Autoshift) ELSE @In_Time_Autoshift END, 121)  + CONVERT(VARCHAR(12), Shift_St_Time, 114) as datetime)))

							--SELECT @IsNightShift = isnull(s.IsNightShift,0)
							--FROM #Data d inner join T0040_SHIFT_MASTER s WITH (NOLOCK) on d.Shift_ID = s.Shift_ID 
							--ORDER BY In_time,Emp_ID
							
							/*
							If Employee has Worked on 2 different Dates (ie. Night shift) then we should not Update Shift end time , Condition Added By Ramiz on 25/10/2016
							
							 1) First I have Compared Dates , if In Date is Less then Out Date then only it will go in this Condition
							 2) Then I have Compared the Time , that If Date are Different But if Shift Start Time is Less than Shift End Time then Both Start time and End Time will be Updated
							*/
							IF ISNULL(@SHIFT_ID_AUTOSHIFT,0) > 0 AND (CAST(CONVERT(VARCHAR(11),@IN_TIME_AUTOSHIFT , 121) AS DATE) < CAST (CONVERT(VARCHAR(11) , @OUT_TIME_AUTOSHIFT , 121) AS DATE)) 
								Begin
									IF (@SHIFT_START_TIME_AUTOSHIFT < @SHIFT_END_TIME_AUTOSHIFT) 
										BEGIN
											Update D set Shift_ID=@Shift_ID_Autoshift,
											Shift_Start_Time= CAST(CONVERT(VARCHAR(11), In_time, 121)  + CONVERT(VARCHAR(12), @Shift_start_time_Autoshift, 114) as datetime)
											,Shift_End_Time = CAST(CONVERT(VARCHAR(11), In_time, 121)  + CONVERT(VARCHAR(12), @Shift_End_time_Autoshift, 114) as datetime)	
											from #Data D
											where Emp_ID=@Emp_ID and In_time=@In_Time_Autoshift 
											And Shift_ID <> @Shift_ID_Autoshift
										END
									ELSE
										BEGIN
											Update #Data set Shift_ID = @Shift_ID_Autoshift,
											Shift_Start_Time= CAST(CONVERT(VARCHAR(11), In_time, 121)  + CONVERT(VARCHAR(12), @Shift_start_time_Autoshift, 114) as datetime)
											from #Data 
											where Emp_ID=@Emp_ID and In_time=@In_Time_Autoshift 
											And Shift_ID <> @Shift_ID_Autoshift
										END
									End
							else if isnull(@Shift_ID_Autoshift,0) > 0  --Original Condition which was kept on 13/04/2015 by Ramiz
								Begin
								
									Update #Data set Shift_ID=@Shift_ID_Autoshift,
									Shift_Start_Time= CAST(CONVERT(VARCHAR(11), In_time, 121)  + CONVERT(VARCHAR(12), @Shift_start_time_Autoshift, 114) as datetime) ,
									Shift_End_Time = CAST(CONVERT(VARCHAR(11), Coalesce(OUT_Time, In_Time,For_Date), 121)  + CONVERT(VARCHAR(12), @Shift_End_time_Autoshift, 114) as datetime)					
									from #Data 
									where Emp_ID=@Emp_ID and In_time=@In_Time_Autoshift 
									And Shift_ID <> @Shift_ID_Autoshift
								End
						END
				
				INSERT INTO #tmpEMPINOUT
					(IO_Tran_Id, For_Date, In_Time, Out_Time1, Duration, Reason, Out_Time, Shift_Name, Sh_In_time,Sh_Out_time, Late_Calc_Not_App,Manual_Flag , In_DateTime,Out_DateTime 
					, Duration_in_sec, DayIndex , IsNightShift)
				SELECT 0, For_date, dbo.F_GET_AMPM (In_Time),dbo.F_GET_AMPM (OUT_Time), dbo.F_Return_Hours(Duration_in_sec),'',OUT_Time, SM.Shift_Name, SM.Shift_St_Time 
				,SM.Shift_End_Time, 0,0,In_Time,OUT_Time, Duration_in_sec,1,SM.IsNightShift 
				From #Data D INNER JOIN T0040_SHIFT_MASTER SM WITH (NOLOCK) On D.Shift_ID = SM.Shift_ID
				
				SELECT TE.* ,  dbo.F_Return_Hours(Duration_in_sec) as Actual_Duration
				FROM #tmpEMPINOUT TE
					
			RETURN
		END
		
	-- DECLARE @tmpEMPINOUT TABLE
	
COMMON_CODE:
	
		INSERT INTO #tmpEMPINOUT(IO_Tran_Id,For_Date,In_Time,Out_Time1,Duration,Reason,Out_Time,Late_Calc_Not_App,Manual_Flag , In_DateTime,Out_DateTime , Duration_in_sec, DayIndex,ChkBySuperior)
	    SELECT IO_Tran_Id,For_Date,dbo.F_GET_AMPM (In_Time) as In_Time,dbo.F_GET_AMPM (Out_Time) as Out_Time1
		,Duration
		,case when Chk_By_Superior =0 then '' else
		(Reason + CASE WHEN ISNULL(Other_reason,'') <> '' THEN ' (' + Other_reason + ')' ELSE '' END) end -- Change by ronakk 21112022
		,Out_Time,Late_Calc_Not_App,isnull(ManualEntryFlag,'N' ) 
		, In_Date_Time ,Out_Date_Time, dbo.F_Return_Sec(Duration),
				ROW_NUMBER() OVER(PARTITION BY For_Date ORDER BY For_Date, In_Time) 
				,Chk_By_Superior
		FROM	T0150_EMP_INOUT_RECORD	WITH (NOLOCK)			
		WHERE  Cmp_ID =@Cmp_ID and Emp_ID  =@Emp_ID and For_Date >=@From_Date and For_Date <= @To_Date 
				and Chk_By_Superior = (case when ISNULL(ManualEntryFlag,'') ='Abs' 
				then 1 else ISNULL(Chk_By_Superior,0) end)--Added by Mukti(07092016)	 
		ORDER BY For_date, IO_Tran_Id
	  
	  
	--Added By Ramiz on 17/10/2018 --(start)
		CREATE TABLE #TMP_DURATION
		(	
			FOR_DATE		DATETIME,
			Actual_Duration	VARCHAR(10)
		)
		
		INSERT INTO #TMP_DURATION
		SELECT	For_Date , dbo.F_Return_Hours(SUM(Duration_in_sec))
		FROM	#tmpEMPINOUT
		GROUP BY For_Date
	--Added By Ramiz on 17/10/2018 --(end)
	
	--Added by Nimesh 21 May, 2015
	IF (OBJECT_ID('tempdb..#Rotation') IS NULL)
		Create Table #Rotation (R_EmpID numeric(18,0), R_DayName varchar(25), R_ShiftID numeric(18,0), R_Effective_Date DateTime);
	--The #Rotation table gets re-created in dbo.P0050_UNPIVOT_EMP_ROTATION stored procedure
	Exec dbo.P0050_UNPIVOT_EMP_ROTATION @Cmp_ID, @Emp_ID, @To_Date, ''

	  
	declare @intLoop int
	declare @intcnt int
	set @intLoop=1
	set @intcnt=0
	
	declare @dtFor_Date datetime
	declare @shift_name varchar(50)
	declare @shift_in_time varchar(10) 
	declare @shift_out_time varchar(10)
	
    select @intcnt=count(intid) from #tmpEMPINOUT	
	
   IF(@intcnt>0)
	   BEGIN

		WHILE @intLoop<=@intcnt
			BEGIN
				   SELECT @dtFor_Date=For_Date,@shift_name=shift_name 
				   FROM #tmpEMPINOUT 
				   WHERE intid=@intLoop
		           
				   set @shift_name=''  
				   set @shift_in_time=''  
				   set @shift_out_time=''
	           
				--Retrieving latest shift info from shift detail using max(for_date)

				select	@shift_in_time=SM.shift_st_time,
							@shift_out_time=SM.shift_end_time,
							@shift_name=SM.shift_name
					from	(
								SELECT	(CASE WHEN Is_Half_Day=1 AND DATENAME(dw, @dtFor_Date) = Week_Day THEN Half_St_Time ELSE	Shift_St_Time END) As Shift_St_Time,
										(CASE WHEN Is_Half_Day=1 AND DATENAME(dw, @dtFor_Date) = Week_Day THEN Half_End_Time ELSE Shift_End_Time END) As Shift_End_Time,
										Shift_ID, Cmp_ID, Shift_Name
								FROM T0040_SHIFT_MASTER WITH (NOLOCK) 
								WHERE	Cmp_ID=@CMP_ID
							) SM right outer join
							(	
								SELECT	Q.emp_id,Q1.for_date, Q1.shift_id 
								FROM	t0100_emp_shift_detail Q1 WITH (NOLOCK)
										INNER JOIN (  														
														SELECT	MAX(For_Date)AS For_Date,Emp_ID 
														FROM	t0100_emp_shift_detail WITH (NOLOCK)
														WHERE	For_Date <= @dtFor_Date and Cmp_Id = @Cmp_ID and Emp_ID=@Emp_ID and isnull(shift_Type,0)= 0
														GROUP BY emp_ID													
													)Q ON Q1.emp_ID =Q.Emp_ID and Q1.For_DAte = Q.For_Date
							)Q_W on SM.shift_id=Q_w.shift_id and SM.cmp_id=@Cmp_ID

					
						
				--Modified by Nimesh 16 April,2015
				--Start Modification
					DECLARE @HasShift tinyint;
					SET @HasShift=0;
				
					--Checking shift rotaion is assigned or not.
					--If shift rotation has been assigned to employee(@Emp_ID) then shift_type should not be considered 
					--while checking shift in shift detail table. 			
					IF EXISTS(SELECT Top 1 1 FROM #Rotation T WHERE R_Effective_Date<=@dtFor_Date AND R_EmpID=@Emp_ID) BEGIN
						SET @HasShift=2;
						
						IF EXISTS(SELECT TOP 1 1 FROM T0100_EMP_SHIFT_DETAIL WITH (NOLOCK) WHERE For_Date=@dtFor_Date AND 
									Cmp_ID=@Cmp_ID And Emp_ID=@Emp_ID) BEGIN
							
							SELECT	@shift_in_time=SM.Shift_St_Time,@shift_out_time=SM.Shift_End_Time,@shift_name=SM.Shift_Name  
							FROM	T0100_EMP_SHIFT_DETAIL ES WITH (NOLOCK) INNER JOIN  
									(
										SELECT	(CASE WHEN Is_Half_Day=1 AND DATENAME(dw, @dtFor_Date) = Week_Day THEN Half_St_Time ELSE	Shift_St_Time END) As Shift_St_Time,
												(CASE WHEN Is_Half_Day=1 AND DATENAME(dw, @dtFor_Date) = Week_Day THEN Half_End_Time ELSE Shift_End_Time END) As Shift_End_Time,
												Shift_ID, Cmp_ID, Shift_Name
										FROM T0040_SHIFT_MASTER WITH (NOLOCK)
										WHERE	Cmp_ID=@CMP_ID
									) SM ON ES.SHIFT_ID = SM.SHIFT_ID
							WHERE	ES.Cmp_ID=@Cmp_ID  AND ES.Emp_ID=@Emp_Id AND For_Date = @dtFor_Date 
							
							SET @HasShift=1;
						END
					END ELSE BEGIN
					
						IF EXISTS(SELECT TOP 1 1 FROM T0100_EMP_SHIFT_DETAIL WITH (NOLOCK) WHERE For_Date=@dtFor_Date AND 
									Cmp_ID=@Cmp_ID And Emp_ID=@Emp_ID AND IsNull(Shift_Type,0)=1) BEGIN
							
							SELECT	@shift_in_time=SM.Shift_St_Time,@shift_out_time=SM.Shift_End_Time,@shift_name=SM.Shift_Name  
							FROM	T0100_EMP_SHIFT_DETAIL ES WITH (NOLOCK) INNER JOIN 
									(
										SELECT	(CASE WHEN Is_Half_Day=1 AND DATENAME(dw, @dtFor_Date) = Week_Day THEN Half_St_Time ELSE	Shift_St_Time END) As Shift_St_Time,
												(CASE WHEN Is_Half_Day=1 AND DATENAME(dw, @dtFor_Date) = Week_Day THEN Half_End_Time ELSE Shift_End_Time END) As Shift_End_Time,
												Shift_ID, Cmp_ID, Shift_Name
										FROM T0040_SHIFT_MASTER WITH (NOLOCK)
										WHERE	Cmp_ID=@CMP_ID
									) SM ON ES.SHIFT_ID = SM.SHIFT_ID
							WHERE	ES.Cmp_ID=@Cmp_ID  AND ES.Emp_ID=@Emp_Id AND For_Date = @dtFor_Date AND IsNull(Shift_Type,0)=1
						
							SET @HasShift=1; 
						END
					END
				
				
				--select * from @tmpEMPINOUT
										
				--If @HasShift Is 0 then retrieve shift from rotation detail
					IF (@HasShift=2) 
						SELECT Top 1 @shift_in_time=SM.Shift_St_Time,@shift_out_time=SM.Shift_End_Time,@shift_name=SM.Shift_Name  	
						FROM	#Rotation T INNER JOIN 
								(
									SELECT	(CASE WHEN Is_Half_Day=1 AND DATENAME(dw, @dtFor_Date) = Week_Day THEN Half_St_Time ELSE	Shift_St_Time END) As Shift_St_Time,
											(CASE WHEN Is_Half_Day=1 AND DATENAME(dw, @dtFor_Date) = Week_Day THEN Half_End_Time ELSE Shift_End_Time END) As Shift_End_Time,
											Shift_ID, Cmp_ID, Shift_Name
									FROM T0040_SHIFT_MASTER WITH (NOLOCK)
									WHERE	Cmp_ID=@CMP_ID
								)  SM ON T.R_SHIFTID = SM.SHIFT_ID
						WHERE	SM.Cmp_ID=@Cmp_ID  AND T.R_EmpID=@Emp_Id 
								AND T.R_DayName = 'Day' + Cast(DatePart(d, @dtFor_Date) As Varchar) 
								AND T.R_Effective_Date= (Select Max(R1.R_Effective_Date) FROM #Rotation R1
														 Where R1.R_Effective_Date<=@dtFor_Date AND R1.R_EmpID=T.R_EmpID) 														
						Order By T.R_Effective_Date Desc
				--End of Modification	 
				
				UPDATE	#tmpEMPINOUT
				SET		sh_in_time=@shift_in_time,sh_out_time=@shift_out_time,shift_name=@shift_name
				WHERE	intid=@intLoop
				
				SET @intLoop=@intLoop+1
			END	
	   END
   ELSE
    BEGIN
	
		if exists(select 1 from T0100_Emp_Shift_Detail where Emp_ID = @Emp_ID and For_Date = @From_Date)
		begin
			INSERT INTO #tmpEMPINOUT
				(IO_Tran_ID,Shift_Name,sh_in_time,sh_out_time,IsNightShift,For_Date)
			SELECT 1,t3.shift_name,t3.shift_St_time,shift_end_time,t3.IsNightShift,@From_Date 
			FROM T0100_EMP_SHIFT_DETAIL T1 WITH (NOLOCK)
			INNER JOIN (
						SELECT emp_id,max(for_date) as For_Date 
						FROM T0100_Emp_Shift_Detail WITH (NOLOCK)
						WHERE for_Date = @from_date --and Shift_Type=0 --Added this code for getting permanent shift for Emp In Out form and not temp shift on 05082016--Sumit
						GROUP BY Emp_ID
						) t2 on t1.emp_id = t2.emp_id and t1.for_date = t2.for_date
			INNER JOIN T0040_SHIFT_MASTER t3 WITH (NOLOCK) ON t1.shift_id = t3.shift_id AND t1.emp_id = @emp_id 
			--AND t1.Shift_Type =0 --Added this code for getting permanent shift for Emp In Out form and not temp shift on 05082016--Sumit		
		end
		else
		begin
			INSERT INTO #tmpEMPINOUT
				(IO_Tran_ID,Shift_Name,sh_in_time,sh_out_time,IsNightShift,For_Date)
			SELECT 1,t3.shift_name,t3.shift_St_time,shift_end_time ,t3.IsNightShift,@From_Date
			FROM T0100_EMP_SHIFT_DETAIL T1 WITH (NOLOCK)
			INNER JOIN (
						SELECT emp_id,max(for_date) as For_Date 
						FROM T0100_Emp_Shift_Detail WITH (NOLOCK)
						WHERE for_Date <= @from_date and Shift_Type=0 --Added this code for getting permanent shift for Emp In Out form and not temp shift on 05082016--Sumit
						GROUP BY Emp_ID
						) t2 on t1.emp_id = t2.emp_id and t1.for_date = t2.for_date
			INNER JOIN T0040_SHIFT_MASTER t3 WITH (NOLOCK) ON t1.shift_id = t3.shift_id AND t1.emp_id = @emp_id 
			AND t1.Shift_Type =0 --Added this code for getting permanent shift for Emp In Out form and not temp shift on 05082016--Sumit		
		end
    END

	--Added By Jimit 29122018
	Update	T
	SEt		Reason_disable = 1
	FROM	#TMPEMPINOUT T Inner join
			T0150_EMP_INOUT_RECORD EIR On  Eir.For_date = T.for_date and Emp_ID  =@Emp_ID 
			and Eir.chk_By_superior = 1 and Eir.App_date is not null
	where   Cmp_ID =@Cmp_ID and Emp_ID  =@Emp_ID and Eir.For_Date >=@From_Date and eir.For_Date <= @To_Date		
	--Ended			
	
	DECLARE @intCnt1 INT
	SET @intCnt1=0
    SELECT @intCnt1=count(intId) from #tmpEMPINOUT
	
		IF(@intCnt1<=0)
			BEGIN
				INSERT INTO #TMPEMPINOUT(IO_TRAN_ID)
				SELECT 1 		 
			END  
		
		
		
		SELECT intid,IO_Tran_Id
		,te.For_Date
		,Case when ChkBySuperior = 0 then In_Time else  Case when isnull(In_Time,'') = '' then FORMAT(CAST(In_DateTime AS datetime), 'hh\:mm tt') else   FORMAT(CAST(in_time AS datetime), 'hh\:mm tt')  end END as In_Time
		,Case when ChkBySuperior = 0 then --Out_Time 
							Out_Time1 --FORMAT(CAST(Out_Time1 AS Time), 'hh\:mm tt')  
					else  
					Case when isnull(Out_Time1,'') = '' 
					then  
						FORMAT(CAST(TE.Out_DateTime AS datetime), 'hh\:mm tt') 
					else
						Out_Time1 --FORMAT(CAST(Out_Time1 AS Time), 'hh\:mm tt')  
					end 
		END as Out_Time1
		,Duration,Reason
		,Case when ChkBySuperior = 0 
			then Out_Time 
				else  
				Case when isnull(Out_Time,'') = '' 
				then CAST(Out_DateTime as datetime) 
					else Out_Time --FORMAT(CAST(Out_Time AS datetime), 'hh\:mm tt') 
				END 
			END as Out_Time
		,Late_Calc_Not_App,Shift_Name,Sh_In_time,Sh_Out_time,Manual_Flag
		,Case when ChkBySuperior = 0 then Out_Time else In_DateTime END as In_DateTime
		,Case when ChkBySuperior = 0 then Out_Time else Out_DateTime END as Out_DateTime
		,Duration_in_sec,DayIndex,Reason_disable,IsNightShift
		,CASE WHEN DayIndex = 1 THEN TD.Actual_Duration  ELSE NULL END as Actual_Duration
		FROM #tmpEMPINOUT TE 
		LEFT OUTER JOIN #TMP_DURATION TD ON TE.For_Date = TD.FOR_DATE

		--SELECT intid,IO_Tran_Id
		--,te.For_Date,
		----Case when isnull(In_Time,'') = '' then '0' + CONVERT(varchar(25),CAST(In_DateTime as time),100)  else in_time end as In_Time,
		----Case when isnull(Out_Time1,'') = '' then '0' + CONVERT(varchar(25),CAST(Out_DateTime as Time),100) else Out_Time1 end as Out_Time1
		-- Case when isnull(In_Time,'') = '' then FORMAT(CAST(In_DateTime AS datetime), 'hh\:mm tt') else in_time end as In_Time,
		-- Case when isnull(Out_Time1,'') = '' then  FORMAT(CAST(Out_DateTime AS datetime), 'hh\:mm tt') else Out_Time1 end as Out_Time1
		--,Duration,Reason
		--,Case when isnull(Out_Time,'') = '' then CAST(Out_DateTime as date) else Out_Time end as Out_Time
		--,Late_Calc_Not_App,Shift_Name,Sh_In_time,Sh_Out_time,
		--Manual_Flag,In_DateTime,Out_DateTime,Duration_in_sec,DayIndex,Reason_disable,IsNightShift,
		--CASE WHEN DayIndex = 1 THEN TD.Actual_Duration  ELSE NULL END as Actual_Duration
		--FROM #tmpEMPINOUT TE
		--	LEFT OUTER JOIN #TMP_DURATION TD ON TE.For_Date = TD.FOR_DATE

RETURN




