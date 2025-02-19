-- =============================================
-- Author:		Nilesh Patel	
-- Create date: 30-05-2016
-- Description:	For Calculate Late Mark Scenario wise 
-- =============================================
CREATE PROCEDURE [dbo].[RPT_LATE_EARLY_MARK_SCENARIO]
	 @CMP_ID NUMERIC
	,@FROM_DATE DATETIME
	,@TO_DATE DATETIME
	,@CONSTRAINT  VARCHAR(MAX) = '' 
AS
BEGIN
	
	SET NOCOUNT ON;	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON 
	
	--if @CONSTRAINT <> ''
	--	Begin 
	--		Insert into #Emp_Cons_Scenario 
	--		Select Cast(Data as Numeric(18,0)),Cast(Data as Numeric(18,0)),Cast(Data as Numeric(18,0)) From dbo.Split(@CONSTRAINT,'#') 
	--	End 
	
	TRUNCATE TABLE #EMP_LATE_SCENARIO;
	TRUNCATE TABLE #Data_Scenario;
	--TRUNCATE TABLE #EMP_HW_CONS;
	
	--Alter Table #EMP_LATE_SCENARIO Add Late_Slab_Flag Numeric(5,0) not null default(0)
	--Alter Table #EMP_LATE_SCENARIO Add Trans_ID Numeric(5,0) not null default(0)
	IF OBJECT_ID('TEMPDB..#EMP_CONS') IS NOT NULL  --Added by Jaina 01-02-2017 start
	begin
		TRUNCATE table #Emp_Cons
	end
	ELSE
	BEGIN
		 CREATE table #Emp_Cons 
		 (      
			Emp_ID numeric ,     
			Branch_ID numeric,
			Increment_ID numeric    
		 )       
	END
	
	IF @Constraint <> ''  
		BEGIN		
				
			INSERT INTO #Emp_Cons 
			SELECT  EMP_ID, 0,0
			FROM	(Select Cast(Data As Numeric) As Emp_ID FROM dbo.Split(@Constraint,'#') T Where T.Data <> '') E
			
			UPDATE  E 
			SET		Branch_ID = I.Branch_ID, Increment_ID=I.Increment_ID
			FROM	#Emp_Cons E						
					INNER JOIN (SELECT	I1.EMP_ID, I1.INCREMENT_ID, I1.BRANCH_ID
								FROM	T0095_INCREMENT I1 WITH (NOLOCK) INNER JOIN #Emp_Cons E1 ON I1.Emp_ID=E1.EMP_ID
										INNER JOIN (SELECT	MAX(I2.Increment_ID) AS Increment_ID, I2.Emp_ID
													FROM	T0095_INCREMENT I2  WITH (NOLOCK) INNER JOIN #Emp_Cons E2 ON I2.Emp_ID=E2.EMP_ID
															INNER JOIN (SELECT	MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
																		FROM	T0095_INCREMENT I3  WITH (NOLOCK) INNER JOIN #Emp_Cons E3 ON I3.Emp_ID=E3.EMP_ID
																		WHERE	I3.Increment_Effective_Date <= @To_Date
																		GROUP BY I3.Emp_ID
																		) I3 ON I2.Increment_Effective_Date=I3.INCREMENT_EFFECTIVE_DATE AND I2.Emp_ID=I3.Emp_ID																		
													WHERE	I2.Cmp_ID = @Cmp_Id 
													GROUP BY I2.Emp_ID
													) I2 ON I1.Emp_ID=I2.Emp_ID AND I1.Increment_ID=I2.INCREMENT_ID	
								WHERE	I1.Cmp_ID=@Cmp_Id											
							) I ON E.EMP_ID=I.Emp_ID			
					
									
		END
		
			
	
	CREATE table #Data      
	(     
		Emp_Id     numeric ,     
		For_date   datetime,    
		Duration_in_sec  numeric,    
		Shift_ID   numeric ,    
		Shift_Type   numeric ,    
		Emp_OT    numeric ,    
		Emp_OT_min_Limit numeric,    
		Emp_OT_max_Limit numeric,    
		P_days    numeric(12,2) default 0,    
		OT_Sec    numeric default 0,
		In_Time datetime default null,
		Shift_Start_Time datetime default null,
		OT_Start_Time numeric default 0,
		Shift_Change tinyint default 0 ,
		Flag Int Default 0  ,
		Weekoff_OT_Sec  numeric default 0,
		Holiday_OT_Sec  numeric default 0,
		Chk_By_Superior numeric default 0,
		IO_Tran_Id	   numeric default 0,
		Out_time datetime default null,
		Shift_End_Time datetime,			--Ankit 16112013
		OT_End_Time numeric default 0,	--Ankit 16112013
		Working_Hrs_St_Time tinyint default 0, --Hardik 14/02/2014
		Working_Hrs_End_Time tinyint default 0, --Hardik 14/02/2014
		GatePass_Deduct_Days numeric(18,2) default 0, -- Add by Gadriwala Muslim 05012014
	)  
	CREATE NONCLUSTERED INDEX IX_Data ON dbo.#data(Emp_Id,Shift_ID,For_Date) 
	
	
	EXEC dbo.P_GET_EMP_INOUT @cmp_id, @FROM_DATE, @TO_DATE	   --Added by Jaina 01-02-2017 end
	
	
	INSERT INTO #EMP_LATE_SCENARIO(EMP_ID,CMP_ID,FOR_DATE,LATE_LIMIT_SEC,INCREMENT_ID,BRANCH_ID,LATE_LIMIT,EARLY_LIMIT_SEC,EARLY_LIMIT)  
	SELECT E.EMP_ID,CMP_ID,FOR_DATE,DBO.F_RETURN_SEC(EMP_LATE_LIMIT),IQ.INCREMENT_ID,IQ.BRANCH_ID,EMP_LATE_LIMIT,
	DBO.F_RETURN_SEC(EMP_EARLY_LIMIT),EMP_EARLY_LIMIT 
	FROM T0150_EMP_INOUT_RECORD E  WITH (NOLOCK) 
				INNER JOIN #Emp_Cons EC ON E.EMP_ID =EC.EMP_ID 
				INNER JOIN  
				(
					SELECT I.EMP_ID,EMP_LATE_LIMIT,EMP_LATE_MARK,I.INCREMENT_ID,BRANCH_ID,EMP_EARLY_MARK,
					EMP_EARLY_LIMIT FROM T0095_INCREMENT I  WITH (NOLOCK) INNER JOIN   
					(
						SELECT MAX(I2.INCREMENT_ID) AS INCREMENT_ID , I2.EMP_ID 
						FROM T0095_INCREMENT I2  WITH (NOLOCK) INNER JOIN #Emp_Cons E ON I2.EMP_ID=E.EMP_ID
						WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE AND CMP_ID = @CMP_ID GROUP BY I2.EMP_ID 
				    ) QRY ON I.EMP_ID = QRY.EMP_ID AND I.INCREMENT_ID = QRY.INCREMENT_ID
				    
			)IQ ON E.EMP_ID =IQ.EMP_ID AND EMP_LATE_MARK =1    
	WHERE FOR_DATE >=@FROM_DATE AND FOR_DATE <=@TO_DATE AND E.CMP_ID =@CMP_ID 
			 AND ((E.CHK_BY_SUPERIOR = 0 OR (E.CHK_BY_SUPERIOR = 2 OR E.Half_Full_day <> ''))
			 --and (IsNull(E.Chk_By_Superior,0)= 0 or  (ISNULL(E.Half_Full_day,'') <> '' AND IsNull(E.Chk_By_Superior,0)= 2))
				OR (E.CHK_BY_SUPERIOR = 1 AND (E.IS_CANCEL_EARLY_OUT = 0  OR E.IS_CANCEL_LATE_IN = 0))
				OR (E.CHK_BY_SUPERIOR = 2 AND (E.IS_CANCEL_EARLY_OUT = 0 OR E.IS_CANCEL_LATE_IN = 0))
				OR (E.CHK_BY_SUPERIOR = 2 AND E.Half_Full_day<>''))	--For Reject Case by chetan 020817
	GROUP BY E.EMP_ID ,E.CMP_ID,E.FOR_DATE,EMP_LATE_LIMIT,IQ.INCREMENT_ID,IQ.BRANCH_ID,EMP_EARLY_LIMIT 
	
	
	--Added by Jaina 17-11-2016 
	UPDATE	EL
	SET		IN_TIME = D.IN_TIME,
			OUT_TIME = D.OUT_TIME
	FROM	#EMP_LATE_SCENARIO EL INNER JOIN #Data D ON EL.Emp_ID=D.Emp_Id AND EL.For_Date=D.For_date
		
	
	
	--Comment By Jaina 17-11-2016
	/*
	UPDATE #EMP_LATE_SCENARIO SET IN_TIME  = Q.IN_TIME,
						  OUT_TIME = CASE WHEN Q4.MAX_IN_DATE > Q2.OUT_TIME THEN 
										Q4.MAX_IN_DATE 
									 ELSE 
										Q2.OUT_TIME 
									 END
	FROM #EMP_LATE_SCENARIO  EL INNER JOIN   
		 (
			SELECT EIR.EMP_ID,FOR_DATE,MIN(IN_TIME )IN_TIME FROM T0150_EMP_INOUT_RECORD EIR INNER JOIN 
			#Emp_Cons_Scenario EC ON EIR.EMP_ID =EC.EMP_ID 
			WHERE FOR_DATE BETWEEN @FROM_DATE AND @TO_DATE 
			GROUP BY EIR.EMP_ID,EIR.FOR_DATE 
		  )Q ON EL.EMP_ID =Q.EMP_ID AND EL.FOR_DATE =Q.FOR_DATE  
		 INNER JOIN 
		 (
				SELECT EIR.EMP_ID,FOR_DATE,MAX(OUT_TIME)OUT_TIME FROM T0150_EMP_INOUT_RECORD EIR INNER JOIN	
				#Emp_Cons_Scenario EC ON EIR.EMP_ID =EC.EMP_ID 
				WHERE FOR_DATE BETWEEN @FROM_DATE AND @TO_DATE 
				GROUP BY EIR.EMP_ID,EIR.FOR_DATE 
		 )Q2 ON EL.EMP_ID =Q2.EMP_ID AND EL.FOR_DATE =Q2.FOR_DATE  
		 INNER JOIN 
		 (
			SELECT EIR.EMP_ID, MAX(IN_TIME) MAX_IN_DATE,FOR_DATE FROM DBO.T0150_EMP_INOUT_RECORD EIR 
			INNER JOIN	#Emp_Cons_Scenario EC ON EIR.EMP_ID =EC.EMP_ID 
			WHERE FOR_DATE BETWEEN @FROM_DATE AND @TO_DATE 
			GROUP BY EIR.EMP_ID,EIR.FOR_DATE  
		 ) Q4 ON EL.EMP_ID = Q4.EMP_ID AND EL.FOR_DATE = Q4.FOR_DATE
		 LEFT OUTER JOIN 
		 (
			SELECT EIR.EMP_ID,CHK_BY_SUPERIOR CHK_BY_SUP,FOR_DATE FROM DBO.T0150_EMP_INOUT_RECORD EIR
			INNER JOIN	#Emp_Cons_Scenario EC ON EIR.EMP_ID =EC.EMP_ID WHERE CHK_BY_SUPERIOR <> 0
		 ) Q3 ON EL.EMP_ID = Q3.EMP_ID AND EL.FOR_DATE = Q3.FOR_DATE 
	
	*/
	IF OBJECT_ID('tempdb..#EMP_HW_CONS') IS NULL
	BEGIN
		
		--Holiday & Weekoff - In colon(;) seperated string (With Cancel) : Used in SP_CALCULATE_PRESENT_DAYS
		CREATE TABLE #EMP_HW_CONS
		(
			Emp_ID				NUMERIC,
			WeekOffDate			Varchar(Max),
			WeekOffCount		NUMERIC(3,1),
			CancelWeekOff		Varchar(Max),
			CancelWeekOffCount	NUMERIC(3,1),
			HolidayDate			Varchar(MAX),
			HolidayCount		NUMERIC(3,1),
			HalfHolidayDate		Varchar(MAX),
			HalfHolidayCount	NUMERIC(3,1),
			CancelHoliday		Varchar(Max),
			CancelHolidayCount	NUMERIC(3,1)
		)
		CREATE UNIQUE CLUSTERED INDEX IX_EMP_HW_CONS_EmpID ON EMP_HW_CONS(Emp_ID)
	
		EXEC SP_GET_HW_ALL @CONSTRAINT=@constraint,@CMP_ID=@Cmp_ID, @FROM_DATE=@From_Date, @TO_DATE=@To_Date, @All_Weekoff = 0, @Exec_Mode=0
	END
	
	Declare @For_Date datetime   
	Declare @Shift_St_Time  varchar(10)  
	Declare @Shift_St_DateTime datetime  
	Declare @In_Date   Datetime  
	Declare @var_Shift_St_Date varchar(20)  
	Declare @Emp_Late_Limit  varchar(10)  
	Declare @Late_Limit_Sec  numeric  
	Declare @StrWeekoff_Date VARCHAR(MAX)
	Declare @StrHoliday_Date VARCHAR(MAX)
	Declare @Is_Late_calc_On_HO_WO TINYINT
	Declare @Temp_Branch_ID NUMERIC
	Declare @Is_LateMark as tinyint
	Declare @Shift_End_Time  varchar(10)
	Declare @Shift_End_DateTime datetime  
	Declare @Out_Date   Datetime  
	Declare @var_Shift_End_Date varchar(20) 
	Declare @Max_Late_Limit  varchar(10)  
	Declare @Shift_Max_DateTime datetime
	Declare @Is_EarlyMark as TINYINT
	Declare @Emp_Early_Limit  varchar(10)  
	Declare @Early_Limit_Sec  numeric  
	Declare @Is_Early_calc_On_HO_WO TINYINT
	Declare @Max_Early_Limit  varchar(10)  
	Declare @Shift_End_Max_DateTime DATETIME
	Declare @Emp_LateMark AS TINYINT
	Declare @Emp_EarlyMark AS TINYINT
	Declare @is_halfDay varchar(15) 
	Declare @Shift_Day varchar(15)  
	declare @RoundingValue 	numeric(18,2)
	declare @RoundingValue_Early 	numeric(18,2)
	declare @Previous_Emp_ID as numeric(18,0)
	declare @previous_Branch_ID as numeric(18,0)
	Declare @Late_Is_Slabwise tinyint
	Declare @Early_Is_Slabwise tinyint
	Declare @Late_Mark_Scenario Numeric(2,0)
	Declare @Is_Late_Mark_Percentage Numeric(2,0)
	
	DECLARE @Extra_Count_Exemption NUMERIC(18,2)
	DECLARE @Extra_exemption_limit VARCHAR(10)
	DECLARE @Temp_Extra_Count AS NUMERIC(18,2)
	DECLARE @Extra_Exemption AS NUMERIC(18,2)
	Declare @Emp_ID Numeric(10,0)
	
	SET @Extra_Count_Exemption = 0
	SET @Extra_exemption_limit = 0
	SET @Temp_Extra_Count = 0
	SET @Extra_Exemption = 0

	Set @Is_LateMark = 1
	Set @Is_Late_calc_On_HO_WO = 0
	Set @Is_EarlyMark = 1
	Set @Is_Early_calc_On_HO_WO = 0
	SET @Emp_LateMark = 1
	SET @Emp_Early_Limit = 1     
	set @RoundingValue 	= 0
	set @RoundingValue_Early = 0
	set @Previous_Emp_ID = 0
	set @previous_Branch_ID = 0
	set @Late_Is_Slabwise = 0
	set @Early_Is_Slabwise = 0
	Set @Late_Mark_Scenario = 1
	Set @Is_Late_Mark_Percentage = 0
	
	Truncate table #Rotation
	IF (OBJECT_ID('tempdb..#Rotation') IS NULL)
		CREATE TABLE #Rotation 
		(
			R_EmpID numeric(18,0), 
			R_DayName varchar(25), 
			R_ShiftID numeric(18,0), 
			R_Effective_Date DateTime
		);
	
	IF EXISTS(SELECT 1 FROM T0050_SHIFT_ROTATION_MASTER  WITH (NOLOCK) WHERE Cmp_ID=@Cmp_ID)
		Exec dbo.P0050_UNPIVOT_EMP_ROTATION @Cmp_ID, null, @To_Date, @CONSTRAINT
		
	
	DECLARE @Shift_ID numeric(18,0);
		Declare curLate Cursor for 
		Select Emp_ID,For_Date,In_Time,Late_Limit_Sec,Branch_Id,Out_Time,Early_Limit_Sec 
		From #EMP_LATE_SCENARIO order by Emp_ID,For_Date
		Open curLate  
		Fetch Next From curLate into @Emp_ID,@For_Date,@In_Date,@Late_Limit_Sec,@Temp_Branch_ID,@Out_Date,@Early_limit_Sec
			While @@Fetch_Status = 0 
			 Begin
						If @previous_Branch_ID <> @Temp_Branch_ID
							begin					
								SELECT  @Is_Late_calc_On_HO_WO = Is_Late_Calc_On_HO_WO,
										@Is_LateMark = Is_Late_Mark,
										@RoundingValue = ISNULL(Early_Hour_Upper_Rounding,0),
										@Max_Late_Limit=isnull(Max_Late_Limit,'00:00') ,
										@Is_Early_calc_On_HO_WO = Is_Early_Calc_On_HO_WO,
										--@Max_Early_Limit=isnull(Max_Early_Limit,'00:00'),
										@Max_Early_Limit='00:00',
										@RoundingValue_early = ISNULL(Late_Hour_Upper_Rounding,0), 
										@Late_Is_Slabwise = Isnull(is_late_calc_slabwise,0),
										@Early_Is_Slabwise = isnull(is_Early_Calc_Slabwise,0),
										@Late_Mark_Scenario = ISNULL(Late_Mark_Scenario,1),
										@Is_Late_Mark_Percentage  = Isnull(Is_Latemark_Percentage,0)
								FROM dbo.T0040_GENERAL_SETTING  WITH (NOLOCK) WHERE Branch_ID = @Temp_Branch_ID AND Cmp_ID = @Cmp_ID and
								For_Date = (
												select MAX(For_Date) from T0040_GENERAL_SETTING  WITH (NOLOCK) 
												where Cmp_ID = @Cmp_ID and For_Date <= @To_Date and Branch_ID = @Temp_Branch_ID
										    )
							end
							
						if @Previous_Emp_ID <> @Emp_ID
							begin	
								SET @StrWeekoff_Date = ''
								SET @StrHoliday_Date = ''	
							
								SELECT	@StrWeekoff_Date=HW.WeekOffDate, @StrHoliday_Date = HW.HolidayDate + ISNULL(HW.HalfHolidayDate,'')
								FROM	#EMP_HW_CONS HW
								WHERE	Emp_ID=@Emp_ID
							end
							
							SET @Shift_ID = NULL;
						
							SELECT	@Shift_ID=Shift_ID
							FROM	T0100_EMP_SHIFT_DETAIL ESD WITH (NOLOCK) 
							WHERE	ESD.Cmp_ID=@Cmp_ID And ESD.Emp_ID=@Emp_ID AND ESD.Shift_Type=1 AND 
									ESD.Emp_ID NOT IN (	
													SELECT R_EmpID From #Rotation Where R_Effective_Date<=@For_Date 
												) 
							AND ESD.For_Date=@For_Date
							
							IF (@Shift_ID IS NULL) 
								BEGIN 
									SELECT	@Shift_ID=Shift_ID
									FROM	T0100_EMP_SHIFT_DETAIL ESD WITH (NOLOCK) 
									WHERE	ESD.Cmp_ID=@Cmp_ID And ESD.Emp_ID=@Emp_ID AND 
											ESD.Emp_ID IN (	
																SELECT R_EmpID From #Rotation Where R_Effective_Date<=@For_Date
															) 
											AND ESD.For_Date=@For_Date
									
									IF (@Shift_ID IS NULL) 
										BEGIN	
											SELECT	@Shift_ID = R_ShiftID
											FROM	#Rotation R 
											WHERE	R.R_EmpID=@Emp_ID AND R.R_DayName='Day' + CAST(DATEPART(d, @For_Date) As Varchar) AND
													R.R_Effective_Date=(
																		Select MAX(R_Effective_Date) From #Rotation R1 
																		Where R1.R_EmpID=R.R_EmpID AND R1.R_Effective_Date <=@For_Date
																		)									
											IF (@Shift_ID IS NULL) 
												BEGIN									
													SELECT	@Shift_ID=Shift_ID
													FROM	T0100_EMP_SHIFT_DETAIL ESD WITH (NOLOCK) 
													WHERE	ESD.Cmp_ID=@Cmp_ID And ESD.Emp_ID=@Emp_ID AND 
															ESD.For_Date=(
																			SELECT MAX(For_Date) FROM T0100_EMP_SHIFT_DETAIL ESD1 WITH (NOLOCK) 
																			WHERE ESD1.Cmp_ID=ESD.Cmp_ID AND ESD1.Emp_ID=ESD.Emp_ID AND
																			ESD1.For_Date<=@For_Date
																		 )
												END
										END					
								END 
								
								Select @shift_Id = Shift_Id From #Data Where For_Date = @For_Date And Emp_Id = @Emp_Id

								SELECT	@is_halfDay=SM.Week_Day 
								FROM	T0040_SHIFT_MASTER SM WITH (NOLOCK) 
								WHERE	SM.Shift_ID=@Shift_ID AND SM.Cmp_ID=@Cmp_ID
								
								update #EMP_LATE_SCENARIO set Shift_ID = @Shift_ID , 
								Is_Late_Calc_Ho_WO = @Is_Late_calc_On_HO_WO , Is_Early_Calc_Ho_WO = @Is_Early_Calc_On_HO_WO,
								Late_Mark_Scenario = @Late_Mark_Scenario,
								Is_Late_Mark_Percentage = @Is_Late_Mark_Percentage
								Where Emp_ID=@Emp_ID and For_Date =@For_Date  and cmp_ID = @Cmp_ID  
							
								set @Shift_Day = datename(WEEKDAY,@In_Date) 
								
								if @Shift_Day=@is_halfDay
									begin
										
										SELECT	@Shift_St_Time=SM.Half_St_Time,@Shift_End_Time=SM.Half_End_Time	
										FROM	T0040_SHIFT_MASTER SM  WITH (NOLOCK) 
										WHERE	SM.Cmp_ID=@Cmp_ID AND SM.Shift_ID=@Shift_ID
									end
								else
									begin
										
										SELECT	@Shift_St_Time=SM.Shift_St_Time,@Shift_End_Time=SM.Shift_End_Time
										FROM	T0040_SHIFT_MASTER SM  WITH (NOLOCK) 
										WHERE	SM.Cmp_ID=@Cmp_ID AND SM.Shift_ID=@Shift_ID
									end
									
								set @var_Shift_St_Date = cast(@In_Date as varchar(11)) + ' '  + @Shift_St_Time
								
								  if @Shift_St_Time > @Shift_End_Time
									  begin							
										  set @var_Shift_End_Date = ISNULL(cast(@Out_Date as varchar(11)),cast(@In_Date as varchar(11))) + ' '  + @Shift_End_Time	
									  end
								  else
									  begin											
										 set @var_Shift_End_Date = ISNULL(cast(@In_Date as varchar(11)),cast(@Out_Date as varchar(11))) + ' '  + @Shift_End_Time	
									  end  
								 
								  set @Shift_Max_DateTime = dateadd(s,dbo.F_Return_Sec(@Max_Late_Limit),@var_Shift_St_Date)  
								  set @Shift_End_Max_DateTime = dateadd(s,dbo.F_Return_Sec(@Max_Early_Limit)*(-1) ,@var_Shift_End_Date)  
								  set @Shift_St_DateTime = cast(@var_Shift_St_Date as datetime)  
								  set @Shift_St_DateTime = dateadd(s,@Late_Limit_Sec,@Shift_St_DateTime)  
								  set @Shift_End_DateTime = cast(@var_Shift_End_Date as datetime) 
								  set @Shift_End_DateTime = dateadd(s,@Early_Limit_Sec*(-1),@Shift_End_DateTime)  
							
							
								  Update #EMP_LATE_SCENARIO  
								  Set Shift_Max_St_Time=@Shift_Max_DateTime
								  ,shift_max_ed_time = @Shift_End_Max_DateTime
								  Where Emp_ID=@Emp_ID and For_Date =@For_Date 
					      
					      
      
								select @Emp_LateMark=I.Emp_Late_mark, @Emp_EarlyMark = I.Emp_Early_mark from T0095_Increment I  WITH (NOLOCK) 
								inner join   
									( 
										select max(Increment_ID) as Increment_ID , Emp_ID From T0095_Increment   WITH (NOLOCK) 
										where Increment_Effective_date <= @To_Date and Cmp_ID = @Cmp_ID  
										group by emp_ID  
									) Qry on  
								I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID   
								WHERE I.emp_id=@Emp_ID 
								
								
								
								If @Is_LateMark = 1
								Begin
									IF @Emp_LateMark = 1
										BEGIN
											IF @Is_Late_calc_On_HO_WO = 1
												BEGIN      											
													update #EMP_LATE_SCENARIO  
													set Shift_Time =@Shift_St_DateTime
													,Shift_End_Time=@Shift_End_DateTime 
													Where Emp_ID=@Emp_ID and For_Date =@For_Date  
												END
											ELSE
												BEGIN	   
													
													if charindex(cast(@For_Date as varchar(11)),@StrWeekoff_Date,0) <> 0 or charindex(cast(@For_Date as varchar(11)),@StrHoliday_Date,0) <> 0 
														Begin	
															
														  update #EMP_LATE_SCENARIO  
														  set 
														  In_Time =@Shift_St_DateTime,
														  Shift_Time =@Shift_St_DateTime
														  ,Shift_End_Time=@Shift_End_DateTime 
														  Where Emp_ID=@Emp_ID and For_Date =@For_Date  
														End
													Else
														Begin
															update #EMP_LATE_SCENARIO  
															set Shift_Time =@Shift_St_DateTime
															,Shift_End_Time=@Shift_End_DateTime   
															Where Emp_ID=@Emp_ID and For_Date =@For_Date  
														End
												END
										 END
									ELSE
										BEGIN
												update #EMP_LATE_SCENARIO set In_Time =@Shift_St_DateTime,
													Shift_Time =@Shift_St_DateTime Where Emp_ID=@Emp_ID and For_Date =@For_Date  
										END
								End
							Else
								BEGIN
									--update #EMP_LATE_SCENARIO  set Shift_End_Time=@Shift_End_DateTime ,
									--out_time=@Shift_end_DateTime      
									--Where Emp_ID=@Emp_ID and For_Date =@For_Date 
									
									update #Emp_Late 
									set In_Time = @Shift_St_DateTime,
									Shift_Time =@Shift_St_DateTime,
									Shift_End_Time=@Shift_End_DateTime ,
									out_time=@Shift_end_DateTime      
									Where Emp_ID=@Emp_ID and For_Date =@For_Date  
								End
							set @previous_Branch_ID = @Temp_Branch_ID
						set @Previous_Emp_ID = @Emp_ID
				fetch next from curLate into @Emp_ID,@For_Date,@In_Date,@Late_Limit_Sec,@Temp_Branch_ID,@Out_Date,@Early_Limit_Sec 
			 End
	   close curLate
	   deallocate curLate
	  
	   UPDATE #EMP_LATE_SCENARIO  
		SET 
			Late_sec =	CASE WHEN (DATEPART(hh,DATEADD(SECOND,-Late_Limit_Sec,Shift_Time)) = 0 AND In_Time < DATEADD(D,1,For_Date) ) THEN  DATEDIFF(s,DATEADD(D,1,For_Date),In_Time)
						ELSE DATEDIFF(s,Shift_Time,In_Time) END,
			Late_Hour = dbo.F_Return_Hours (DATEDIFF(s,Shift_Time,In_Time)),
			Is_Late = 1
		WHERE DATEDIFF(s,Shift_Time,In_Time) > 0
		
		Update #EMP_LATE_SCENARIO set 
			Late_sec = 0,Late_Hour = 0
			where datediff(s,Shift_Time,In_Time) > 0 and 
					(
						In_Time >= Shift_Time and In_Time <= Shift_Max_St_Time 
						and datediff(s,dateadd(s,-1*Late_Limit_Sec,Shift_Time),Shift_End_Time)<=datediff(s,In_Time,Out_Time)
					)	
					
		 Update #EMP_LATE_SCENARIO  
			set Late_sec = 0,Late_Hour = 0
			where Late_Sec < 60
			
		
		Update #EMP_LATE_SCENARIO  set 
			Late_sec = 0,Late_Hour = 0
		from #EMP_LATE_SCENARIO EL
		inner join (
					select la.Leave_Approval_ID,la.Emp_ID,lad.To_Date from T0120_LEAVE_APPROVAL la  WITH (NOLOCK) 
					inner join T0130_LEAVE_APPROVAL_DETAIL lad  WITH (NOLOCK) on la.Leave_Approval_ID = lad.Leave_Approval_ID
					where Leave_Assign_As = 'First Half' and Approval_Status = 'A'
					) Qry 
					on Qry.Emp_ID = el.Emp_ID and Qry.To_Date = el.For_Date
					
		Update #EMP_LATE_SCENARIO  set 
			Late_sec = 0,Late_Hour = 0
		from #EMP_LATE_SCENARIO EL 
		inner join (
						select la.Leave_Approval_ID,la.Emp_ID,lad.To_Date,Leave_out_time ,Leave_In_Time,From_Date 
						from T0120_LEAVE_APPROVAL la  WITH (NOLOCK) inner join T0130_LEAVE_APPROVAL_DETAIL lad  WITH (NOLOCK) on la.Leave_Approval_ID = lad.Leave_Approval_ID
						where upper(Leave_Assign_As) = 'PART DAY' and Approval_Status = 'A'
				    ) Qry 
					--on Qry.Emp_ID = el.Emp_ID and Qry.To_Date = el.For_Date and Qry.Leave_out_time =EL.Shift_Max_St_Time  --and Qry.Leave_out_time =EL.Shift_Time -- changed by rohit on 20042016
					--Above commented by Sumit on 09012017 for Night Shift Short Leave Case because to date is changing in that case
					on Qry.Emp_ID = el.Emp_ID and Qry.From_Date = el.For_Date and Qry.Leave_out_time =EL.Shift_Max_St_Time
					
 
	    update #EMP_LATE_SCENARIO
		set Late_Sec = 0 ,Late_Hour = 0
	    from #EMP_LATE_SCENARIO EL
	    inner join ( select Chk_By_Superior,Is_Cancel_Early_Out,Is_Cancel_Late_In,Emp_ID,For_Date 
					from T0150_EMP_INOUT_RECORD E  WITH (NOLOCK) where 
					For_Date >=@From_Date and For_Date <=@to_Date and e.Cmp_Id =@Cmp_ID 
					--and Chk_By_Superior <> 0 --comment by CHETAN 020817
					and ((IsNull(E.Chk_By_Superior,0)= 1 and ISNULL(E.Half_Full_day,'') <> '') OR (ISNULL(E.Half_Full_day,'') = '' AND IsNull(E.Chk_By_Superior,0)= 2))--added by chetan 020817
					and Is_Cancel_Late_In =  1)Qry		--Changed by Ramiz on 29/03/2016 , Previously it was Chk_By_Superior = 1 , but as now Chk_By_Superior = 2 is also included , so Condition is changed
			on Qry.Emp_ID =el.Emp_ID and Qry.For_Date = el.For_Date 
			
		
		Declare @Absent_emp_Id as numeric(18,0)
		Declare @Absent_For_date as datetime
		Declare @Absent_Branch_ID as numeric(18,0)
		
		CREATE TABLE #Shift_Details
		(
				Row_id numeric(18,0),
				Shift_ID numeric(18,0),
				Calculate_Days numeric(18,2),
				From_Hour numeric(18,2),
				To_Hour numeric(18,2)
		)
		
		Insert into #Shift_Details
		select ROW_NUMBER() over ( Partition by SD.Shift_ID order by Sd.Shift_ID,Calculate_days) as Row_ID,
		Sd.Shift_ID,Calculate_Days,From_Hour,To_hour  
		from T0050_Shift_Detail SD  WITH (NOLOCK) inner join #EMP_LATE_SCENARIO EL on EL.shift_ID = Sd.Shift_ID  order by SD.shift_ID,Calculate_Days 
		
		-- Deepal TO check the case Absent base on time and Late Deducation DATE 04062024
		UPDAte #EMP_LATE_SCENARIO set ActualTime = DATEDIFF(S,case when Shift_Time > IN_TIME then Shift_Time else IN_TIME END , CASE WHEN SHIFT_END_TIME > OUT_TIME THEN OUT_TIME ELSE SHIFT_END_TIME  END)
		-- Deepal TO check the case Absent base on time and Late Deducation DATE 04062024

		
		DECLARE @ABS_CONSTRAINT VARCHAR(MAX);
		
		SELECT @ABS_CONSTRAINT= COALESCE(@ABS_CONSTRAINT + '#', '') + CAST(EMP_ID as varchar(18)) 
		FROM
		(SELECT Distinct EMP_ID from #EMP_LATE_SCENARIO where Is_Late = 1 and For_Date >= @From_date and For_Date <= @To_Date and out_Time is null 
		union -- Records which Calculate Days greater than 0 Check for Absent
		select EL.emp_ID from #EMP_LATE_SCENARIO EL inner join
		#Shift_Details Qry on Qry.Shift_ID = El.Shift_ID and Qry.Row_ID = 1
		where  EL.Is_Late = 1 and Datediff(s,In_Time,Out_Time)/3600  < From_hour  and out_time is not null 
		and Calculate_days > 0   and EL.For_Date >= @From_date and EL.For_Date <= @To_Date	
		union   -- Records which Calculate Days is 0 Check for Absent
		select EL.emp_ID from #EMP_LATE_SCENARIO EL inner join
		#Shift_Details Qry on Qry.Shift_ID = El.Shift_ID and Qry.Row_ID = 1
		where  EL.Is_Late = 1 and Datediff(s,In_Time,Out_Time)/3600  >= From_hour and  Datediff(s,In_Time,Out_Time)/3600  <= To_Hour  and out_time is not null 
		and Calculate_days = 0   and EL.For_Date >= @From_date and EL.For_Date <= @To_Date) t
		
		DECLARE @ABS_FROM_DATE DATETIME,
				@ABS_TO_DATE DATETIME;
				
				
		select @ABS_FROM_DATE= MIN(For_Date),@ABS_TO_DATE= MAX(For_Date) 
		FROM 
		(SELECT Distinct For_Date from #EMP_LATE_SCENARIO where Is_Late = 1 and For_Date >= @From_date and For_Date <= @To_Date and out_Time is null 
		union -- Records which Calculate Days greater than 0 Check for Absent
		select EL.For_Date from #EMP_LATE_SCENARIO EL inner join
		#Shift_Details Qry on Qry.Shift_ID = El.Shift_ID and Qry.Row_ID = 1
		where  EL.Is_Late = 1 and Datediff(s,In_Time,Out_Time)/3600  < From_hour  and out_time is not null 
		and Calculate_days > 0   and EL.For_Date >= @From_date and EL.For_Date <= @To_Date	
		union   -- Records which Calculate Days is 0 Check for Absent
		select EL.For_Date from #EMP_LATE_SCENARIO EL inner join
		#Shift_Details Qry on Qry.Shift_ID = El.Shift_ID and Qry.Row_ID = 1
		where  EL.Is_Late = 1 and Datediff(s,In_Time,Out_Time)/3600  >= From_hour and  Datediff(s,In_Time,Out_Time)/3600  <= To_Hour  and out_time is not null 
		and Calculate_days = 0   and EL.For_Date >= @From_date and EL.For_Date <= @To_Date) t
		
		
		truncate table #Data  --Added by Jaina 17-11-2016
		Exec dbo.SP_CALCULATE_PRESENT_DAYS @Cmp_ID =@Cmp_ID,@From_Date=@ABS_FROM_DATE,@To_Date=@ABS_TO_DATE,@Branch_ID=0,@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Emp_ID=0,@constraint=@ABS_CONSTRAINT,@Return_Record_set=4,@StrWeekoff_Date='',@Is_Split_Shift_Req=1 ,@Late_SP=1  
		
		Select * Into #Data_Scenario from #data	
		
		update	#EMP_LATE_SCENARIO set Is_Late = 0 from #EMP_LATE_SCENARIO EL
				inner join  #Data_Scenario D on EL.For_Date = D.For_date and EL.Emp_ID = D.Emp_ID  and D.P_days = 0
		where Cmp_ID = @Cmp_ID 
		
		update	#EMP_LATE_SCENARIO set Is_Late = 1 
		from #EMP_LATE_SCENARIO EL
				inner join  #Data_Scenario D on EL.For_Date = D.For_date and EL.Emp_ID = D.Emp_ID  and D.P_days = 0
		where Cmp_ID = @Cmp_ID and ( EL.Is_Late_Calc_Ho_WO = 1 and ( D.Weekoff_OT_Sec > 0 or D.Holiday_OT_Sec > 0))		
		
		Declare @Gen_ID as numeric(18,0)
		Declare @Late_Limit varchar(10)
		Declare @Late_Adj_Day numeric(18,2)
		declare @Late_Deduction_Days numeric(18,2)
		declare @Late_CF_Reset_On varchar(10)
		declare @Is_late_CF tinyint
		declare @Late_with_Leave numeric(18,2)
		declare @Late_Count_Exemption numeric(18,2)
		declare @Late_Hour_Upper_Rounding numeric(18,2)
		declare @late_exemption_limit varchar(10)
		-------------------------------------
		Declare @Early_Limit varchar(10)
		Declare @Early_Adj_Day numeric(18,2)
		Declare @Early_Deduction_Days numeric(18,2)
		Declare @Early_Extra_Deduction numeric(18,2)
		Declare @Early_CF_Reset_On varchar(10)
		declare @Is_Early_CF tinyint
		declare @Early_With_Leave numeric(18,2)
		Declare @Early_Count_Exemption numeric(18,2)
		declare @Early_Calculate_type varchar(10)
		declare @Early_exemption_limit varchar(10)
		-----------------------------------------
		
		declare @Late_Calculate_Type varchar(10)
		declare @Late_Extra_Deduction numeric(18,2)
		Declare @Late_Exempted_Count numeric(18,0)
		Declare @Early_Exempted_Count numeric(18,0)
		Declare @Total_Late_Adjust_days numeric(18,2)
		declare @Total_Early_Adjust_days numeric(18,2)
		Declare @Shift_Time_Sec numeric(18,0)
		Declare @Working_Time_Sec numeric(18,0)
		-------------------------------------------
		Declare @cur_Emp_ID numeric(18,0)
		Declare @cur_Branch_ID numeric(18,0)
		declare @cur_cmp_Id numeric(18,0)
		declare @cur_For_date datetime
		Declare @cur_Late_Hour varchar(10)
		Declare @cur_Early_Hour varchar(10)
		Declare @cur_Late_Seconds numeric(18,0)
		Declare @cur_Early_Seconds numeric(18,0)
		Declare @cur_In_Time as datetime
		Declare @cur_Out_Time as datetime
		Declare @Cur_Shift_St_Time as datetime
		Declare @Cur_Shift_End_Time as datetime
		Declare @Cur_Late_Limit_Sec as numeric(18,0) -- Added by Gadriwala Muslim 22062015 
		Declare @Cur_Early_Limit_Sec as numeric(18,0) -- Added by Gadriwala Muslim 22062015 
	
		------------------------------------
		set @Late_Exempted_Count = 0
		set @Previous_Emp_ID = 0
		set @previous_Branch_ID = 0
		set @Total_Late_Adjust_days = 0
		set @Total_Early_Adjust_days = 0
		set @Shift_Time_Sec = 0
		set @Working_Time_Sec = 0
		
		IF OBJECT_ID('TEMPDB.DBO.#LATE_MARK_SLAB') IS NOT NULL
		DROP TABLE #LATE_MARK_SLAB
    
		CREATE TABLE #LATE_MARK_SLAB
		(
			Row_No Numeric(18,0),
			CMP_ID NUMERIC(18,0),
			EMP_ID NUMERIC(18,0),
			TRANS_ID NUMERIC(18,0),
			BRANCH_ID NUMERIC(18,0),
			FROM_MIN NUMERIC(18,0),
			TO_MIN NUMERIC(18,0),
			EXMPT_COUNT NUMERIC(18,0),
			DEDUCTION NUMERIC(18,2),
			DEDUCTION_TYPE VARCHAR(100),
			GEN_ID NUMERIC(18,0),
			ONE_TIME_EXEMPTION NUMERIC(2,0),
			TOTAL_LATE_COUNT NUMERIC(18,0),
			GROUP_FLAG BIT
		)
		
		Declare @Late_Diff_Minutes as numeric(18,2)
		Set @Late_Diff_Minutes = 0
		
		declare curdeduction cursor for 
				select el.Emp_ID,el.Branch_Id,el.For_Date,
													CASE WHEN dbo.F_Return_Hours(dbo.Pro_Rounding_Sec_HH_MM(el.Late_Sec,@RoundingValue))='00:00' THEN 
														'' 
													ELSE 
														dbo.F_Return_Hours(dbo.Pro_Rounding_Sec_HH_MM(el.Late_Sec,@RoundingValue)) 
													end as Late_Hour_Rounding,
													CASE WHEN dbo.F_Return_Hours(dbo.Pro_Rounding_Sec_HH_MM(el.Early_Sec ,@RoundingValue_Early))='00:00' THEN 
														'' 
													ELSE 
														dbo.F_Return_Hours(dbo.Pro_Rounding_Sec_HH_MM(el.Early_Sec ,@RoundingValue_Early)) 
													END as Early_Hour_Rounding,
													isnull(Late_Sec,0) as Late_Sec,
													ISNULL(Early_Sec,0) as Early_Sec,
													Datediff(s,In_Time,Out_Time) as Working_Time_Sec,
													Datediff(S,Shift_Time,Shift_end_Time) as Shift_Time_Sec,  
													In_Time,
													Out_Time,
													Shift_Time as Shift_St_date_Time,
													Shift_End_Time as Shift_End_date_Time,
													Late_Limit_Sec,
													Early_Limit_Sec
													from #Emp_Late_Scenario el 
													where ( is_Late = 1)
													order by Emp_ID,For_Date
			
		Open curdeduction  
			Fetch Next From curdeduction into @cur_Emp_ID,@cur_Branch_ID,@cur_For_date,@cur_Late_Hour,@cur_Early_Hour,@cur_Late_Seconds,@cur_Early_Seconds,@Working_Time_sec,@Shift_Time_Sec,@Cur_In_Time,@Cur_Out_Time,@Cur_Shift_st_Time,@cur_Shift_End_Time,@Cur_Late_Limit_Sec,@Cur_Early_Limit_Sec
			While @@fetch_status = 0   
				BEGIN
					
					IF @previous_Branch_ID <> @cur_Branch_ID 
						Begin
							SELECT  
								@GEN_ID = ISNULL(GEN_ID,0),
								@LATE_WITH_LEAVE = LATE_WITH_LEAVE,
								@IS_LATE_CALC_ON_HO_WO = IS_LATE_CALC_ON_HO_WO,
								@IS_LATEMARK = IS_LATE_MARK, 
								@ROUNDINGVALUE = ISNULL(EARLY_HOUR_UPPER_ROUNDING,0) 
							FROM dbo.T0040_GENERAL_SETTING  WITH (NOLOCK) WHERE Branch_ID = @cur_Branch_ID AND Cmp_ID = @Cmp_ID and
							For_Date = (
											select MAX(For_Date) from T0040_GENERAL_SETTING  WITH (NOLOCK) 
											where Cmp_ID = @Cmp_ID and For_Date <= @To_Date and Branch_ID = @cur_Branch_ID
								       )   
							
							Insert INTO #LATE_MARK_SLAB	
							SELECT ROW_NUMBER() Over(Order By TRANS_ID) As Row, CMP_ID,@cur_Emp_ID,TRANS_ID,@cur_Branch_ID,FROM_MIN,TO_MIN,EXEMPTION_COUNT,DEDUCTION,DEDUCTION_TYPE,GEN_ID,ONE_TIME_EXEMPTION,0, 0
							From T0050_GENERAL_LATEMARK_SLAB  WITH (NOLOCK) where GEN_ID = @Gen_ID
							
							UPDATE T1
							SET		GROUP_FLAG = 1
							FROM	#LATE_MARK_SLAB T1 
									INNER JOIN (SELECT T2.FROM_MIN, T2.TO_MIN FROM #LATE_MARK_SLAB T2 GROUP BY T2.FROM_MIN, T2.TO_MIN,T2.EMP_ID HAVING COUNT(1) > 1)  T2 ON T1.FROM_MIN=T2.FROM_MIN AND T1.TO_MIN = T2.TO_MIN
						End
					Else
						Begin
							IF @Previous_Emp_ID <> @cur_Emp_ID  
								Begin
									Insert INTO #LATE_MARK_SLAB	
									SELECT ROW_NUMBER() Over(Order By TRANS_ID) As Row, CMP_ID,@cur_Emp_ID,TRANS_ID,@cur_Branch_ID,FROM_MIN,TO_MIN,EXEMPTION_COUNT,DEDUCTION,DEDUCTION_TYPE,GEN_ID,ONE_TIME_EXEMPTION,0, 0
									From T0050_GENERAL_LATEMARK_SLAB  WITH (NOLOCK) where GEN_ID = @Gen_ID
							
									UPDATE T1
									SET		GROUP_FLAG = 1
									FROM	#LATE_MARK_SLAB T1 
									INNER JOIN (SELECT T2.FROM_MIN, T2.TO_MIN FROM #LATE_MARK_SLAB T2 GROUP BY T2.FROM_MIN, T2.TO_MIN,T2.EMP_ID HAVING COUNT(1) > 1)  T2 ON T1.FROM_MIN=T2.FROM_MIN AND T1.TO_MIN = T2.TO_MIN
								End
						End				
					IF @IS_LATEMARK > 0
						Begin
							--IF @LATE_WITH_LEAVE > 0 
							--	Begin
									Set @Late_Diff_Minutes = ((Isnull(@cur_Late_Seconds,0) + Isnull(@Cur_Late_Limit_Sec,0))/60)
					
									Update LMS Set TOTAL_LATE_COUNT = TOTAL_LATE_COUNT + 1
									From #LATE_MARK_SLAB LMS 
									Where @Late_Diff_Minutes Between LMS.FROM_MIN AND LMS.TO_MIN 
									AND LMS.EMP_ID = @cur_Emp_ID AND LMS.BRANCH_ID = @cur_Branch_ID
									
									Update #Emp_Late_Scenario  SET Late_Deduct_Days = 0 ,is_Maximum_late = 0,Early_Deduct_Days = 0 , Early_Sec = 0 ,Early_Hour = 0 
									WHERE FOR_DATE = @CUR_FOR_DATE AND EMP_ID = @CUR_EMP_ID
									
									UPDATE #Emp_Late_Scenario SET Late_Deduct_Days = ISNULL(DEDUCTION,0),is_Maximum_late = 1 FROM #Emp_Late_Scenario LS INNER JOIN
									( 
										SELECT EMP_ID,DEDUCTION FROM  #LATE_MARK_SLAB where TOTAL_LATE_COUNT > EXMPT_COUNT
										AND EMP_ID = @CUR_EMP_ID AND BRANCH_ID = @CUR_BRANCH_ID AND @LATE_DIFF_MINUTES BETWEEN FROM_MIN AND TO_MIN AND DEDUCTION_TYPE='Days'											
									)QRY ON QRY.EMP_ID = LS.Emp_ID 
									WHERE LS.FOR_DATE = @CUR_FOR_DATE AND LS.EMP_ID = @CUR_EMP_ID 
									
									
									UPDATE #LATE_MARK_SLAB SET TOTAL_LATE_COUNT = 0
									WHERE TOTAL_LATE_COUNT > EXMPT_COUNT AND EMP_ID = @CUR_EMP_ID AND BRANCH_ID = @CUR_BRANCH_ID 
										AND (@LATE_DIFF_MINUTES BETWEEN FROM_MIN AND TO_MIN)  AND ONE_TIME_EXEMPTION = 0 AND DEDUCTION_TYPE='Days'
										AND GROUP_FLAG = 0
								--End										
									
						End
						
						--if @cur_Late_Seconds <> 0 
						--	Begin
						--		 Update ELS
						--		 Set ELS.Late_Slab_Flag = LMS.Row_No
						--		 From #Emp_Late_Scenario ELS Inner Join #LATE_MARK_SLAB LMS
						--		 ON LMS.EMp_ID = ELS.Emp_ID and LMS.Branch_ID = ELS.Branch_ID
						--		 Where  ((Isnull(@cur_Late_Seconds,0) + Isnull(@Cur_Late_Limit_Sec,0))/60) BETWEEN LMS.FROM_MIN AND LMS.TO_MIN 
						--		 And ELS.For_Date = @cur_For_date And ELS.Emp_ID = @cur_Emp_ID
						--	End
						
					set @previous_Branch_ID = @cur_Branch_ID
					set @Previous_Emp_ID = @cur_Emp_ID
					Fetch Next From curdeduction into @cur_Emp_ID,@cur_Branch_ID,@cur_For_date,@cur_Late_Hour,@cur_Early_Hour,@cur_Late_Seconds,@cur_Early_Seconds,@Working_Time_sec,@Shift_Time_Sec,@Cur_In_Time,@Cur_Out_Time,@Cur_Shift_st_Time,@cur_Shift_End_Time,@Cur_Late_Limit_Sec,@Cur_Early_Limit_Sec
				End
		close curdeduction
		deallocate curdeduction
		
		
		--Added Condition by Nimesh/Nilesh on 23/08/2016 For AIA Late Mark Slab(Added Group Flag For Same Slab Details) --Start
		UPDATE T1
		SET		T1.TOTAL_LATE_COUNT = T2.TOTAL_LATE_COUNT
		From	#LATE_MARK_SLAB T1 
				INNER JOIN
					(Select MAX(TOTAL_LATE_COUNT) AS TOTAL_LATE_COUNT, T.FROM_MIN, T.TO_MIN , T.EMP_ID
					FROM #LATE_MARK_SLAB T
					WHERE T.GROUP_FLAG=1
					GROUP BY T.FROM_MIN, T.TO_MIN,T.EMP_ID) T2 ON  T1.FROM_MIN=T2.FROM_MIN AND T1.TO_MIN=T2.TO_MIN AND T1.EMP_ID=T2.EMP_ID
		WHERE	T1.GROUP_FLAG =1
					
		DELETE FROM #LATE_MARK_SLAB WHERE EXMPT_COUNT >= TOTAL_LATE_COUNT AND GROUP_FLAG=1
		DELETE LS FROM #LATE_MARK_SLAB LS 
				INNER JOIN (SELECT MAX(T.EXMPT_COUNT) EXMPT_COUNT, EMP_ID FROM #LATE_MARK_SLAB T GROUP BY  EMP_ID) T ON LS.EMP_ID=T.EMP_ID AND LS.EXMPT_COUNT <> T.EXMPT_COUNT
		WHERE	GROUP_FLAG=1
				
		--UPDATE LS
		--SET LATE_DEDUCT_DAYS = CASE WHEN LS.FOR_DATE = T3.FOR_DATE THEN LB.DEDUCTION ELSE  0 END
		--FROM #Emp_Late_Scenario LS 
		--		INNER JOIN #LATE_MARK_SLAB LB ON (((LS.LATE_SEC + LS.LATE_LIMIT_SEC) / 60) BETWEEN LB.FROM_MIN AND LB.TO_MIN) AND LS.EMP_ID=LB.EMP_ID
		--		INNER JOIN  (SELECT LS1.EMP_ID, MAX(LS1.FOR_DATE) AS FOR_DATE, LB1.FROM_MIN, LB1.TO_MIN FROM #Emp_Late_Scenario LS1
		--							INNER JOIN #LATE_MARK_SLAB LB1 ON ((LS1.LATE_SEC + LS1.LATE_LIMIT_SEC) / 60) BETWEEN LB1.FROM_MIN AND LB1.TO_MIN 									
		--							WHERE LB1.GROUP_FLAG=1
		--							GROUP BY LS1.EMP_ID, LB1.FROM_MIN, LB1.TO_MIN) T3 ON LS.EMP_ID=T3.EMP_ID AND LB.FROM_MIN=T3.FROM_MIN AND LB.TO_MIN=T3.TO_MIN
		--WHERE LB.GROUP_FLAG=1
		
		--		UPDATE LS
		--SET LATE_DEDUCT_DAYS = CASE WHEN LS.FOR_DATE = T3.FOR_DATE THEN LB.DEDUCTION ELSE  0 END
		--FROM #Emp_Late_Scenario LS 
		--		INNER JOIN #LATE_MARK_SLAB LB ON (((LS.LATE_SEC + LS.LATE_LIMIT_SEC) / 60) BETWEEN LB.FROM_MIN AND LB.TO_MIN) AND LS.EMP_ID=LB.EMP_ID
		--		INNER JOIN  (SELECT LS1.EMP_ID, LS1.FOR_DATE AS FOR_DATE, LB1.FROM_MIN, LB1.TO_MIN FROM #Emp_Late_Scenario LS1
		--							INNER JOIN #LATE_MARK_SLAB LB1 ON ((LS1.LATE_SEC + LS1.LATE_LIMIT_SEC) / 60) BETWEEN LB1.FROM_MIN AND LB1.TO_MIN 									
		--							WHERE LB1.GROUP_FLAG=0
		--							--GROUP BY LS1.EMP_ID, LB1.FROM_MIN, LB1.TO_MIN
		--							) T3 ON LS.EMP_ID=T3.EMP_ID AND LB.FROM_MIN=T3.FROM_MIN AND LB.TO_MIN=T3.TO_MIN
		--WHERE LB.GROUP_FLAG=0
		--abpve update statement comment by tejas for bug 30363
						
		--Added Condition by Nimesh/Nilesh on 23/08/2016 For AIA Late Mark Slab(Added Group Flag For Same Slab Details) --End
																	
										
END

