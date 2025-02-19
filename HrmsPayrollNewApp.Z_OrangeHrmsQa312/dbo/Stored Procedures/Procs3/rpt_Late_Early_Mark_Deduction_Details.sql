
CREATE PROCEDURE [dbo].[rpt_Late_Early_Mark_Deduction_Details]
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
 ,@Format_Type	varchar(50) = ''
 ,@Report_Type	tinyint = 0
 ,@Used_Table	tinyint = 0 
 ,@flag			tinyint = 0 
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

	if @flag = 0
	BEGIN			
		IF OBJECT_ID('tempdb..#Emp_Cons') IS Not NULL
			BEGIN 
				SELECT * INTO #Emp_Cons_ORG FROM #Emp_Cons
				Truncate TABLE #Emp_Cons
			END
		ELSE
		BEGIN			
				CREATE TABLE #Emp_Cons 
				(      
					Emp_ID numeric ,     
					Branch_ID numeric,
					Increment_ID numeric    
				 )   
		END

		EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint 

		CREATE TABLE #Emp_Cons_Late
		(      
			Emp_ID numeric ,     
			Branch_ID numeric,
			Increment_ID numeric    
		) 
		CREATE UNIQUE CLUSTERED INDEX IX_EMP_CONS_LATE_EMPID ON #Emp_Cons_Late (EMP_ID);
		INSERT INTO #Emp_Cons_Late SELECT distinct * FROM #Emp_Cons

		IF OBJECT_ID('tempdb..#Emp_Cons_ORG') IS NOT NULL
		BEGIN
				TRUNCATE TABLE #Emp_Cons
				INSERT INTO #Emp_Cons SELECT * FROM #Emp_Cons_ORG
				DROP TABLE #Emp_Cons_ORG
		END
	END
	
	Declare @LateEarly_MonthWise Numeric(2,0) 
    SET @LateEarly_MonthWise = 0
	Declare @IsDeficit Numeric(2,0) 
    SET @IsDeficit = 0
	DECLARE @MonthExemptLimitInSec Numeric(18,0) = 0

	/*
	DECLARE @HasConsTable BIT
	SET @HasConsTable = 1;
	IF OBJECT_ID('tempdb..#Emp_Cons') IS Not NULL
		Begin
			if EXISTS(Select 1 FROM  dbo.split(@Constraint, '#') T Where T.Data <> ''
				AND Not Exists(Select 1 From #Emp_Cons E Where Cast(T.Data  As Numeric) = Emp_ID))
				Begin							
					SET @HasConsTable = 0;
				End
		End
	Else
		Begin
			SET @HasConsTable = 0;
		End	 
		
	IF @HasConsTable = 0
		BEGIN
			CREATE TABLE #Emp_Cons 
			 (      
				Emp_ID numeric ,     
				Branch_ID numeric,
				Increment_ID numeric    
			 )       
			
			EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint 
			
			CREATE UNIQUE CLUSTERED INDEX IX_EMP_CONS_EMPID ON #Emp_Cons (EMP_ID);
			
	
		END
	*/

	DECLARE @HasDataTable BIT
	DECLARE @ONLY_INOUT BIT
	SET @HasDataTable = 1;
	SET @ONLY_INOUT = 0;
	IF OBJECT_ID('tempdb..#Data') IS Not NULL
		Begin			
			if EXISTS(Select 1 FROM  dbo.split(@Constraint, '#') T Where T.Data <> ''
				AND Not Exists(Select 1 From #Data D Where Cast(T.Data  As Numeric) = Emp_ID))
				Begin																					
					SET @HasDataTable = 0;
				End
		End
	Else
		Begin
			SET @HasDataTable = 0;
		End	 
	 
	CREATE TABLE #Data_LATE     
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
		GatePass_Deduct_Days numeric(18,2) default 0 -- Add by Gadriwala Muslim 05012014
		--,Working_sec_Between_Shift numeric(18) default 0 -- Commented by Niraj(20062022)
	)  
	CREATE NONCLUSTERED INDEX IX_Data_Late ON dbo.#DATA_LATE(Emp_Id,Shift_ID,For_Date) 
	---Changed by Hardik and Nimesh on 09/02/2017 as Attendance Muster and In Out record Form getting slow

	

	If @HasDataTable = 0
		Begin
			IF OBJECT_ID('tempdb..#DATA_ORG') IS NULL
				BEGIN
					CREATE TABLE #Data      
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
						GatePass_Deduct_Days numeric(18,2) default 0 -- Add by Gadriwala Muslim 05012014
					)  
				END
			ELSE
				BEGIN
					SELECT * INTO #DATA_ORG FROM #DATA 
					TRUNCATE TABLE #Data
				END
				
				

			EXEC dbo.P_GET_EMP_INOUT @cmp_id, @From_Date, @To_Date	   --Added by Jaina 17-11-2016

			
			
			--SET @ONLY_INOUT = 1; -- Commented by Hardik 05/10/2020 for Gallops as they are not calculate late on Half day or absent
			SET @ONLY_INOUT = 0;  -- Put 0 for Gallops as they are not calculate late on Half day or absent --by Hardik 05/10/2020

			-- Added update query by Hardik 02/04/2019 for Gallops client
			Update #Data Set P_days = Case Qry.Half_Full_day When 'Full Day' Then 1 WHEN 'First Half' THEN 0.5 WHEN 'Second Half' THEN 0.5 ELSE 0 END
				From #Data D Inner Join 
					(Select EIR.Emp_Id,EIR.For_date, EIR.Half_Full_day From T0150_EMP_INOUT_RECORD EIR WITH (NOLOCK) Inner Join #Data DA On EIR.Emp_ID = DA.Emp_Id
						Where DA.For_date BETWEEN @From_Date And @To_Date And DA.Chk_By_Superior = 1
						GROUP by EIR.Emp_Id,EIR.For_date, EIR.Half_Full_day) Qry On D.Emp_Id = Qry.Emp_ID And D.For_date = Qry.For_Date
			Where D.Chk_By_Superior=1

			
			INSERT INTO #DATA_LATE 
			SELECT * FROM #DATA

			

			IF OBJECT_ID('tempdb..#DATA_ORG') IS NOT NULL
				BEGIN
					TRUNCATE TABLE #DATA 
					INSERT INTO #DATA 
					SELECT * FROM #DATA_ORG
					DROP TABLE #DATA_ORG
				END
		End
	ELSE
		INSERT INTO #DATA_LATE
		SELECT * FROM #DATA
	

	
	
	if @Format_Type = 'Late' OR @Format_Type = 'All' --OR @Format_Type = 'Early'
		Begin
			-- Added By Nilesh Patel on 30052016 --start
			if Object_ID('tempdb..#Emp_Cons_Scenario') is not null
				BEGIN
					Drop TABLE #Emp_Cons_Scenario
				End
				
			Create Table #Emp_Cons_Scenario
			(
				Emp_ID numeric ,     
				Branch_ID numeric,
				Increment_ID numeric  
			)

			Insert INTO #Emp_Cons_Scenario
			Select EC.Emp_ID,EC.Branch_ID,EC.Increment_ID 
			FROM #Emp_Cons EC Inner Join T0040_GENERAL_SETTING GS WITH (NOLOCK) 
			INNER JOIN(
						Select MAX(For_Date) as ForDate,Branch_ID From T0040_GENERAL_SETTING  WITH (NOLOCK) 
						Where Cmp_ID = @Cmp_ID
						GROUP By Branch_ID
					  ) as qry
			ON GS.For_Date = qry.ForDate and GS.Branch_ID = qry.Branch_ID
			ON EC.Branch_ID = GS.Branch_ID
			Where GS.Late_Mark_Scenario = 2	
			
			Delete FROM #Emp_Cons where Emp_ID IN(Select Emp_ID From #Emp_Cons_Scenario)
			-- Added By Nilesh Patel on 30052016 --End
			SELECT TOP 1 @MonthExemptLimitInSec = dbo.F_Return_Sec(Monthly_Exemption_Limit)
			, @LateEarly_MonthWise = ISNULL(LateEarly_MonthWise, 0)
			,@IsDeficit = Isdeficit
			FROM #Emp_Cons_Scenario EC
			INNER JOIN T0040_GENERAL_SETTING GS ON EC.BRANCH_ID = GS.BRANCH_ID
			INNER JOIN (
				SELECT GS1.BRANCH_ID ,MAX(FOR_DATE) AS FOR_DATE
				FROM T0040_GENERAL_SETTING GS1 WHERE GS1.FOR_DATE < @TO_DATE
				GROUP BY GS1.BRANCH_ID
			) GS1 ON GS.BRANCH_ID = GS1.BRANCH_ID AND GS.FOR_DATE = GS1.FOR_DATE

		End
	
	--if @Format_Type = 'Early'
	--BEGIN 
			
	--		Select EC.Emp_ID,EC.Branch_ID,EC.Increment_ID,IsDeficit
	--		FROM #Emp_Cons EC Inner Join T0040_GENERAL_SETTING GS WITH (NOLOCK) 
	--		INNER JOIN(
	--					Select MAX(For_Date) as ForDate,Branch_ID 
	--					From T0040_GENERAL_SETTING  WITH (NOLOCK) 
	--					Where Cmp_ID = @Cmp_ID
	--					GROUP By Branch_ID
	--		) as qry
	--		ON GS.For_Date = qry.ForDate and GS.Branch_ID = qry.Branch_ID
	--		ON EC.Branch_ID = GS.Branch_ID
	--		Where GS.Late_Mark_Scenario = 2	
			
	--END
	

	DECLARE @HasLateTable BIT
	SET @HasLateTable = 1
	if OBJECT_ID('tempdb..#Emp_Late') IS NULL
		BEGIN
			CREATE TABLE #Emp_Late   
			(  
				Emp_ID   numeric ,  
				Cmp_ID   numeric ,  
				Increment_ID numeric,  
				For_Date  Datetime ,  
				In_Time   Datetime ,  
				Shift_Time  Datetime ,  
				Late_Sec  int default 0 ,  
				Late_Limit_Sec int default 0,  
				Late_Hour  varchar(10), 
				Branch_Id NUMERIC,
				Late_Limit Varchar(100),
				Out_Time   Datetime,		
				Shift_ID	   numeric,	 -- Added by Gadriwala Muslim 30062015	
				Shift_End_Time  Datetime,	
				Shift_Max_St_Time Datetime,
				Shift_max_Ed_Time DATETIME,
				Early_Sec INT DEFAULT 0,
				Early_Limit_Sec int default 0,
				Early_hour VARCHAR(10),
				Early_Limit Varchar(100),
				Late_Deduct_Days numeric(18,2) default 0, 
				Early_Deduct_Days numeric(18,2) default 0,
				Is_Early tinyint default 0,
				Is_Late tinyint default 0 ,
				Is_Maximum_Late tinyint default 0,-- Changed by Gadriwala Muslim 23062015 
				Is_Late_Calc_Ho_WO tinyint default 0, --Changed by Gadriwala Muslim 03072015 
				Is_Early_Calc_Ho_Wo tinyint default 0, --Changed by Gadriwala Muslim 03072015 
				Extra_Exempted_Sec numeric(18,0) default 0,	-- Added by Gadriwala Muslim 28102015
				Extra_Exempted tinyint default 0	,		-- Added by Gadriwala Muslim 28102015
				Late_Mark_Scenario tinyint default 1,
				Is_Late_Mark_Percentage tinyint default 0,
				Actualtime numeric(18,0),
				IsDeficit tinyint,
				MonthExemptLimit numeric(18,0)
			)  

			CREATE NONCLUSTERED INDEX ix_Emp_Late_EmpID_For_Date ON #Emp_Late(Emp_ID,For_Date) ;
			SET @HasLateTable = 0
		END
	  
	
	

	 -- Insert   Late, Early Limit
	 --select * from #Emp_Cons
	 --select  * from T0095_INCREMENT where emp_id=28201 
	
	 
	    
		insert into #Emp_Late  (Emp_ID,Cmp_ID,For_Date,Late_Limit_Sec,Increment_ID,Branch_Id,Late_Limit,Early_Limit_Sec,Early_Limit,MonthExemptLimit,IsDeficit)  
		select e.Emp_ID,E.Cmp_ID,E.For_Date,dbo.F_Return_Sec(Emp_Late_Limit),IQ.Increment_ID,IQ.Branch_Id,Emp_Late_Limit,
				dbo.F_Return_Sec(Emp_Early_Limit),Emp_early_Limit,dbo.F_Return_Sec(Monthly_Exemption_Limit),IsDeficit 
				From (
					SELECT	E.Emp_ID, Cmp_ID,For_Date,Max(Chk_By_Superior) As Chk_By_Superior ,Max(Is_Cancel_Early_Out) As Is_Cancel_Early_Out,
							Max(Is_Cancel_Late_In) As Is_Cancel_Late_In,Max(Half_Full_day) As Half_Full_day
					FROM	T0150_Emp_inout_Record E  WITH (NOLOCK) 
							Inner join #Emp_Cons EC1 on e.Emp_ID = EC1.emp_ID 
					where	For_Date BETWEEN @From_Date AND @To_Date
					Group By E.Emp_ID, Cmp_ID,For_Date
				) E 
				Inner join #Emp_Cons ec on e.Emp_ID =Ec.emp_ID 
				inner JOIN T0095_Increment IQ WITH (NOLOCK)  ON EC.Emp_ID=IQ.Emp_ID AND EC.Increment_ID=IQ.Increment_ID
				inner join T0040_GENERAL_SETTING GS on GS.Branch_ID = Ec.Branch_ID
			--	Inner join  
			--	(
			--		select I.Emp_Id,Emp_Late_Limit,Emp_Late_Mark,I.Increment_ID,Branch_Id,Emp_Early_mark,
			--		Emp_Early_Limit from T0095_Increment I inner join   
			--		(
			--			select max(i2.Increment_ID) as Increment_ID , I2.Emp_ID 
			--			from T0095_Increment I2 INNER JOIN #Emp_Cons E ON I2.Emp_ID=E.Emp_ID
			--			where Increment_Effective_date <= @To_Date and Cmp_ID = @Cmp_ID group by I2.emp_ID 
			--	    ) Qry on I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID
				    
			--)IQ on e.emp_ID =iq.Emp_ID and Emp_Late_MArk =1    
	   Where E.For_Date >=@From_Date and E.For_Date <=@to_Date and e.Cmp_Id =@Cmp_ID 
			 AND (E.Chk_By_Superior = 0 
					OR (E.Chk_By_Superior = 1 and (E.Is_Cancel_Early_Out = 0  or E.Is_Cancel_Late_In = 0)) -- changed by gadriwala muslim 03062015
					OR (E.Chk_By_Superior = 2 and (E.Is_Cancel_Early_Out = 0 or E.Is_Cancel_Late_In = 0))	--Added By Ramiz on 29/03/2016
					OR (E.Chk_By_Superior = 2 AND E.Half_Full_day<>'')
				)	--For Reject Case by chetan 020817
			AND 1 = (case when @Format_Type='Early' then Emp_Early_mark else Emp_Late_mark end)
	   --group by E.Emp_ID ,e.Cmp_ID,e.For_date,Emp_Late_Limit,IQ.Increment_ID,IQ.Branch_Id,Emp_Early_Limit  
	   

		--Added by Jaina 17-11-2016
		UPDATE	EL
		SET		IN_TIME = D.IN_TIME,
				OUT_TIME = D.OUT_TIME
		FROM	#Emp_Late EL INNER JOIN #DATA_LATE D ON EL.Emp_ID=D.Emp_Id AND EL.For_Date=D.For_date
			

		--Comment by Jaina 17-11-2016
	   /*Update #Emp_Late Set In_time  = q.In_time,
						  Out_Time = Case when Q4.Max_In_Date > Q2.Out_Time Then 
										Q4.Max_In_Date 
									 Else 
										Q2.Out_Time 
									 End
		 from #Emp_Late  el inner Join   
		 (
			Select eir.Emp_ID,for_Date,min(In_time )In_time From T0150_Emp_inout_Record eir inner join 
			#Emp_Cons ec on eir.Emp_ID =ec.emp_ID 
			where For_Date between @From_Date and @To_Date 
			group by eir.emp_Id,eir.For_Date 
		  )Q on el.emp_ID =q.Emp_ID and el.for_Date =q.For_Date  
		 inner Join 
		 (
				Select eir.Emp_ID,eir.for_Date,max(eir.Out_Time)Out_Time From T0150_Emp_inout_Record eir  inner join	
				#Emp_Cons ec on eir.Emp_ID =ec.emp_ID 
				where eir.For_Date between @From_Date and @To_Date 
				group by eir.emp_Id,eir.For_Date 
				--select eir.Emp_ID,D.for_Date,max(d.Out_Time)Out_Time  from #DATA_LATE  D 
				--inner JOIN #Emp_Cons E on E.Emp_ID=D.Emp_Id
				--inner JOIN T0150_EMP_INOUT_RECORD eir ON eir.Emp_ID = E.Emp_ID
				--where D.For_Date between @From_Date and @To_Date 
				--group by eir.emp_Id,D.For_Date 
		
		 )Q2 on el.emp_ID =Q2.Emp_ID and el.for_Date =Q2.For_Date  
		 inner join 
		 (
			select eir.Emp_Id, Max(In_Time) Max_In_Date,For_Date From dbo.T0150_Emp_Inout_Record eir 
			inner join	#Emp_Cons ec on eir.Emp_ID =ec.emp_ID 
			where For_Date between @From_Date and @To_Date 
			group by eir.emp_Id,eir.For_Date  
		 ) Q4 on el.Emp_Id = Q4.Emp_Id And el.For_Date = Q4.For_Date
		 Left Outer Join 
		 (
			Select eir.Emp_ID,Chk_By_Superior Chk_By_Sup,For_Date from dbo.T0150_EMP_INOUT_RECORD eir
			inner join	#Emp_Cons ec on eir.Emp_ID =ec.emp_ID where Chk_By_Superior <> 0
		 ) Q3 on el.Emp_Id = Q3.Emp_Id And el.For_Date = Q3.For_Date  */
  
  
	
   /********************************************************************
	Added by Nimesh : Using new employee weekoff/holiday stored procedure
	*********************************************************************/

	
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
		CREATE UNIQUE CLUSTERED INDEX IX_EMP_HW_CONS_EmpID ON #EMP_HW_CONS(Emp_ID)
		
		EXEC SP_GET_HW_ALL @CONSTRAINT=@constraint,@CMP_ID=@Cmp_ID, @FROM_DATE=@From_Date, @TO_DATE=@To_Date, @All_Weekoff = 0, @Exec_Mode=0
	END
	/********************************************************************
	Added by Nimesh : End of Declaration
	*********************************************************************/
   
   
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
	
	---Extra Exemp-------Ankit 03112015
	DECLARE @Extra_Count_Exemption NUMERIC(18,2)
	DECLARE @Extra_exemption_limit VARCHAR(10)
	DECLARE @Temp_Extra_Count AS NUMERIC(18,2)
	DECLARE @Extra_Exemption AS NUMERIC(18,2)
	SET @Extra_Count_Exemption = 0
	SET @Extra_exemption_limit = 0
	SET @Temp_Extra_Count = 0
	SET @Extra_Exemption = 0	
	---------------------

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
	
	Declare @Late_Mark_Scenario Numeric
	Set @Late_Mark_Scenario = 1

	SELECT	Shift_ID, Shift_St_Time, Shift_End_Time 
	INTO	#SHIFT_MASTER
	FROM	T0040_SHIFT_MASTER  WITH (NOLOCK) 
	WHERE	CMP_ID=@Cmp_ID AND Inc_Auto_Shift=1
	 
	--PRINT 'LATE 5 :' + CONVERT(VARCHAR(20), GETDATE(), 114);
	--Add by Nimesh 21 April, 2015
	--This sp retrieves the Shift Rotation as per given employee id and effective date.
	--it will fetch all employee's shift rotation detail if employee id is not specified.
	

	IF (OBJECT_ID('tempdb..#Rotation') IS NULL)
		CREATE TABLE #Rotation (R_EmpID numeric(18,0), R_DayName varchar(25), R_ShiftID numeric(18,0), R_Effective_Date DateTime);
	--The #Rotation table gets re-created in dbo.P0050_UNPIVOT_EMP_ROTATION stored procedure
	IF EXISTS(SELECT 1 FROM T0050_SHIFT_ROTATION_MASTER WITH (NOLOCK)  WHERE Cmp_ID=@Cmp_ID)
		Exec dbo.P0050_UNPIVOT_EMP_ROTATION @Cmp_ID, null, @To_Date, @constraint

	DECLARE @Shift_ID numeric(18,0);
	
		

		Declare curLate cursor for 
		select Emp_ID,For_Date,In_Time,
			   Late_Limit_Sec,Branch_Id,Out_Time,Early_Limit_Sec 
		From #Emp_Late 
		order by Branch_Id,Emp_ID,For_Date

	    Open curLate  
			Fetch Next From curLate into @Emp_ID,@For_Date,@In_Date,@Late_Limit_Sec,@Temp_Branch_ID,@Out_Date,@Early_limit_Sec 
			While @@fetch_status = 0   
				BEGIN	   

						If @previous_Branch_ID <> @Temp_Branch_ID
							begin
								SELECT 
									@Is_Late_calc_On_HO_WO = Is_Late_Calc_On_HO_WO,
									@Is_LateMark = Is_Late_Mark,
								 	@RoundingValue = ISNULL(Early_Hour_Upper_Rounding,0),
									@Max_Late_Limit=isnull(Max_Late_Limit,'00:00'),
									@Is_Early_calc_On_HO_WO = Is_Early_Calc_On_HO_WO,
									@Max_Early_Limit=isnull(Max_Early_Limit,'00:00'),
									@RoundingValue_early = ISNULL(Late_Hour_Upper_Rounding,0), 
									@Late_Is_Slabwise = Isnull(is_late_calc_slabwise,0),
									@Early_Is_Slabwise = isnull(is_Early_Calc_Slabwise,0),
									@Late_Mark_Scenario = isnull(Late_Mark_Scenario,1)
								FROM dbo.T0040_GENERAL_SETTING WITH (NOLOCK) 
								WHERE Branch_ID = @Temp_Branch_ID AND Cmp_ID = @Cmp_ID 
								and For_Date = (
												select MAX(For_Date) from T0040_GENERAL_SETTING  WITH (NOLOCK) 
												where Cmp_ID = @Cmp_ID and For_Date <= @To_Date and Branch_ID = @Temp_Branch_ID
										    )
							end
							
						if @Previous_Emp_ID <> @Emp_ID
							begin	
								SET @StrWeekoff_Date = ''
								SET @StrHoliday_Date = ''		  	
								
								/************************************
								Added by Nimesh on 16-Nov-2015
								Using #EMP_HW_CONS table that contains 
								all employee holiday weekoff records 
								instead of calling sp individually
								*************************************/
								SELECT	@StrWeekoff_Date=HW.WeekOffDate, @StrHoliday_Date = HW.HolidayDate + ISNULL(HW.HalfHolidayDate,'')
								FROM	#EMP_HW_CONS HW
								WHERE	Emp_ID=@Emp_ID
								--Exec SP_EMP_WEEKOFF_DATE_GET @Emp_Id,@Cmp_ID,@From_date,@To_Date,null,null,0,'',@StrWeekoff_Date output,0,0
								--EXEC SP_EMP_HOLIDAY_DATE_GET @Emp_Id,@Cmp_ID, @From_date,@To_Date,null, NULL, 0, @StrHoliday_Date OUTPUT,0, 0, 0, @Temp_Branch_ID,@StrWeekoff_Date    
							end
						
						Select @Shift_ID = Shift_ID FROM #Data Where Emp_ID=@Emp_ID AND For_Date = @For_Date

						

						/*
						--Added by Nimesh 22 April, 2015
						--Setting @Shift_ID to null 
						SET @Shift_ID = NULL;
						--Retrieving Shift ID from Employee Shift Detail Table if defined.						
						--Shift_Type=1 if Rotation is not exist
						SELECT	@Shift_ID=Shift_ID
						FROM	T0100_EMP_SHIFT_DETAIL ESD
						WHERE	ESD.Cmp_ID=@Cmp_ID And ESD.Emp_ID=@Emp_ID AND ESD.Shift_Type=1 AND 
								ESD.Emp_ID NOT IN (	
													SELECT R_EmpID From #Rotation Where R_Effective_Date<=@For_Date 
												) 
								AND ESD.For_Date=@For_Date
						IF (@Shift_ID IS NULL) BEGIN --IS NOT NULL changed Nimesh 02-Jun-2015
							--Retrieving Shift ID from Employee Shift Detail Table if defined.						
							--Shift_Type=0 if Rotation is exist
							SELECT	@Shift_ID=Shift_ID
							FROM	T0100_EMP_SHIFT_DETAIL ESD
							WHERE	ESD.Cmp_ID=@Cmp_ID And ESD.Emp_ID=@Emp_ID AND 
									ESD.Emp_ID IN (	
														SELECT R_EmpID From #Rotation Where R_Effective_Date<=@For_Date
													) 
									AND ESD.For_Date=@For_Date
							
							IF (@Shift_ID IS NULL) BEGIN	--Then fetch from Rotation
								SELECT	@Shift_ID = R_ShiftID
								FROM	#Rotation R 
								WHERE	R.R_EmpID=@Emp_ID AND R.R_DayName='Day' + CAST(DATEPART(d, @For_Date) As Varchar) AND
										R.R_Effective_Date=(
															Select MAX(R_Effective_Date) From #Rotation R1 
															Where R1.R_EmpID=R.R_EmpID AND R1.R_Effective_Date <=@For_Date
															)									
								IF (@Shift_ID IS NULL) BEGIN	--Then fetch Default Shift ID									
									SELECT	@Shift_ID=Shift_ID
									FROM	T0100_EMP_SHIFT_DETAIL ESD
									WHERE	ESD.Cmp_ID=@Cmp_ID And ESD.Emp_ID=@Emp_ID AND 
											ESD.For_Date=(
															SELECT MAX(For_Date) FROM T0100_EMP_SHIFT_DETAIL ESD1
															WHERE ESD1.Cmp_ID=ESD.Cmp_ID AND ESD1.Emp_ID=ESD.Emp_ID AND
															ESD1.For_Date<=@For_Date and ISNULL(ESD1.Shift_Type,0)=0 --Added this condition by Sumit on 30122016
														 )
								END
							END
															
						END 
						*/
										
						--nms
						/*The following code added by Nimesh On 23-Aug-2018 (Auto Shift Scenario does not working in Late Early Mark Report)*/
						IF EXISTS(SELECT 1 FROM #SHIFT_MASTER WHERE SHIFT_ID=@Shift_ID)
							BEGIN
								SELECT	TOP 1 @Shift_ID = Shift_ID 
								FROM	#SHIFT_MASTER
								ORDER BY ABS(DATEDIFF(S, @In_Date, @For_Date + Shift_St_Time)) ASC					
						
							END
						
						/*Commented by Nimesh 21 May, 2015
						select @is_halfDay=sm.Week_Day from T0040_shift_MAster SM
						Inner Join T0100_emp_shift_Detail ESD on ESD.Cmp_ID = SM.Cmp_ID And ESd.Shift_ID = SM.Shift_ID and esd.For_Date in
						(
							select max(for_date) from T0100_emp_shift_Detail 
							where Cmp_ID = @Cmp_ID  and for_date <= @For_Date and emp_id = @emp_id
						)
						where ESD.Cmp_ID = @Cmp_ID  and esd.Emp_ID = @emp_id  
						*/
						
						--Added by Nimesh 21 May, 2015
						SELECT	@is_halfDay=SM.Week_Day 
						FROM	T0040_SHIFT_MASTER SM WITH (NOLOCK) 
						WHERE	SM.Shift_ID=@Shift_ID AND SM.Cmp_ID=@Cmp_ID
						
						

						update #Emp_Late 
								set Shift_ID = @Shift_ID , 
								Is_Late_Calc_Ho_WO = @Is_Late_calc_On_HO_WO , 
								Is_Early_Calc_Ho_WO = @Is_Early_Calc_On_HO_WO 
						Where Emp_ID=@Emp_ID and For_Date =@For_Date  and cmp_ID = @Cmp_ID  -- Added by Gadriwala Muslim 30062015
					
						set @Shift_Day = datename(WEEKDAY,@In_Date) 
				
					    if @Shift_Day=@is_halfDay
							begin
								/*Commented by Nimesh 21 May, 2015
    						  select @Shift_St_Time = SM.Half_St_Time,@Shift_End_Time = SM.Half_End_Time	
							  from T0100_emp_shift_Detail ESD Inner Join T0040_shift_MAster SM on ESD.Cmp_ID = SM.Cmp_ID And ESd.Shift_ID = SM.Shift_ID 
							  where ESD.Cmp_ID = @Cmp_ID  and emp_id = @emp_id  
							  and for_date in (select max(for_date) from T0100_emp_shift_Detail where Cmp_ID = @Cmp_ID  and for_date <= @For_Date  
							  and emp_id = @emp_id) and ESD.shift_id = SM.shift_id and ESD.Cmp_ID = SM.Cmp_ID   
							  */
								SELECT	@Shift_St_Time=SM.Half_St_Time,
										@Shift_End_Time=SM.Half_End_Time	
								FROM	T0040_SHIFT_MASTER SM WITH (NOLOCK) 
								WHERE	SM.Cmp_ID=@Cmp_ID AND SM.Shift_ID=@Shift_ID
							end
						else
							begin
								/*
								  select @Shift_St_Time = SM.Shift_St_Time,@Shift_End_Time = SM.Shift_End_Time	
								  from T0100_emp_shift_Detail ESD Inner Join T0040_shift_MAster SM on ESD.Cmp_ID = SM.Cmp_ID And ESd.Shift_ID = SM.Shift_ID 
								  where ESD.Cmp_ID = @Cmp_ID  and emp_id = @emp_id  
								  and for_date in (select max(for_date) from T0100_emp_shift_Detail where Cmp_ID = @Cmp_ID  and for_date <= @For_Date  
								  and emp_id = @emp_id) and ESD.shift_id = SM.shift_id and ESD.Cmp_ID = SM.Cmp_ID   
								*/
								SELECT	@Shift_St_Time=SM.Shift_St_Time,
										@Shift_End_Time=SM.Shift_End_Time
								FROM	T0040_SHIFT_MASTER SM WITH (NOLOCK)  
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
							
							
						  Update #Emp_Late  
						  Set Shift_Max_St_Time=@Shift_Max_DateTime
						  ,shift_max_ed_time = @Shift_End_Max_DateTime
						  ,Late_Mark_Scenario = @Late_Mark_Scenario
						  Where Emp_ID=@Emp_ID and For_Date =@For_Date 
					      
					      
      
						select @Emp_LateMark=I.Emp_Late_mark,
							  @Emp_EarlyMark = I.Emp_Early_mark 
						from T0095_Increment I WITH (NOLOCK) 
						inner join( 
										select max(Increment_ID) as Increment_ID , Emp_ID From T0095_Increment WITH (NOLOCK)  
										where Increment_Effective_date <= @To_Date and Cmp_ID = @Cmp_ID  
										group by emp_ID  
								  ) Qry on I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID   
						WHERE I.emp_id=@Emp_ID
						
						
						
						If @Is_LateMark = 1
							Begin
								
								IF @Emp_LateMark = 1
									BEGIN
										IF @Is_Late_calc_On_HO_WO = 1
											BEGIN      											
												update #Emp_Late  
												set Shift_Time =@Shift_St_DateTime
												Where Emp_ID=@Emp_ID and For_Date =@For_Date  
											END
										ELSE
											BEGIN	   
												if charindex(cast(@For_Date as varchar(11)),@StrWeekoff_Date,0) <> 0 or charindex(cast(@For_Date as varchar(11)),@StrHoliday_Date,0) <> 0 
													Begin	
													  update #Emp_Late  
													  set In_Time =@Shift_St_DateTime,
																	Shift_Time =@Shift_St_DateTime
													  Where Emp_ID=@Emp_ID and For_Date =@For_Date  
													End
												Else
													Begin
														update #Emp_Late  
														set Shift_Time =@Shift_St_DateTime  
														Where Emp_ID=@Emp_ID and For_Date =@For_Date  
													End
											END
									 END
								ELSE
									BEGIN
											update #Emp_Late 
												set In_Time =@Shift_St_DateTime,
													Shift_Time =@Shift_St_DateTime 
											Where Emp_ID=@Emp_ID and For_Date =@For_Date  
									END	
								IF @Emp_EarlyMark = 1	
									BEGIN
										IF @Is_Early_calc_On_HO_WO = 1
											BEGIN      
												update #Emp_Late 
													set Shift_End_Time=@Shift_End_DateTime
												Where Emp_ID=@Emp_ID and For_Date =@For_Date  
											END
										ELSE
											BEGIN		
												if charindex(cast(@For_Date as varchar(11)),@StrWeekoff_Date,0) <> 0 or charindex(cast(@For_Date as varchar(11)),@StrHoliday_Date,0) <> 0 
													Begin
														update #Emp_Late 
															set out_time = @Shift_end_DateTime,
															Shift_End_Time=@Shift_End_DateTime 
														Where Emp_ID=@Emp_ID and For_Date =@For_Date  
													 End
												Else
													Begin
														update #Emp_Late 
															SET Shift_End_Time=@Shift_End_DateTime  
														Where Emp_ID=@Emp_ID and For_Date =@For_Date  
													End
											END
									END
								ELSE
									BEGIN
										update #Emp_Late  
											set Shift_End_Time=@Shift_End_DateTime--,
											--out_time=@Shift_end_DateTime      
										Where Emp_ID=@Emp_ID and For_Date =@For_Date 
									END	
							End
						Else
							Begin
								update #Emp_Late 
								set In_Time = @Shift_St_DateTime,
								Shift_Time =@Shift_St_DateTime,
								Shift_End_Time=@Shift_End_DateTime--,
								--out_time=@Shift_end_DateTime      
								Where Emp_ID=@Emp_ID and For_Date =@For_Date  
							End
							
						set @previous_Branch_ID = @Temp_Branch_ID
						set @Previous_Emp_ID = @Emp_ID
				fetch next from curLate into @Emp_ID,@For_Date,@In_Date,@Late_Limit_Sec,@Temp_Branch_ID,@Out_Date,@Early_Limit_Sec  
			end   
		close curLate  
		deallocate curLate 
		
		IF Object_ID('tempdb..#EMP_GEN_SETTINGS_LATE') IS NOT NULL
		DROP TABLE #EMP_GEN_SETTINGS_LATE

		CREATE TABLE #EMP_GEN_SETTINGS_LATE
		(
			EMP_ID NUMERIC PRIMARY KEY,
			BRANCH_ID NUMERIC,
			First_In_Last_Out_For_InOut_Calculation TINYINT,
			Chk_otLimit_before_after_Shift_time	TINYINT
		)
		
		ALTER TABLE #EMP_GEN_SETTINGS_LATE ADD Tras_Week_OT TINYINT, Is_Cancel_Holiday_WO_HO_same_day TINYINT
		
		--Added by Hardik 03/04/2019 and commented below Update query for Chiripal
		INSERT INTO #EMP_GEN_SETTINGS_LATE
		SELECT EC.EMP_ID, EC.Branch_ID,G.First_In_Last_Out_For_InOut_Calculation, G.Chk_otLimit_before_after_Shift_time
		,	G.Tras_Week_OT, G.Is_Cancel_Holiday_WO_HO_same_day
		FROM	#EMP_CONS EC
				INNER JOIN  T0040_GENERAL_SETTING G WITH (NOLOCK)  ON EC.BRANCH_ID=G.BRANCH_ID
				INNER JOIN (SELECT	MAX(GEN_ID) AS GEN_ID, G1.BRANCH_ID
							FROM	T0040_GENERAL_SETTING G1 WITH (NOLOCK) 
									INNER JOIN (SELECT	MAX(FOR_DATE) AS FOR_DATE , BRANCH_ID
												FROM	T0040_GENERAL_SETTING G2 WITH (NOLOCK) 
												WHERE	G2.For_Date <= @TO_DATE
												GROUP	BY G2.Branch_ID) G2 ON G1.Branch_ID=G2.Branch_ID AND G1.For_Date=G2.FOR_DATE
							GROUP BY G1.Branch_ID) G1 ON G.Gen_ID=G1.GEN_ID AND G.Branch_ID=G1.Branch_ID
		

		/*
		UPDATE	TG
		SET		Tras_Week_OT = G.Tras_Week_OT,
				Is_Cancel_Holiday_WO_HO_same_day = G.Is_Cancel_Holiday_WO_HO_same_day
		FROM	#EMP_GEN_SETTINGS_LATE TG 
				INNER JOIN  T0040_GENERAL_SETTING G ON TG.BRANCH_ID=G.BRANCH_ID
				INNER JOIN (SELECT	MAX(GEN_ID) AS GEN_ID, G1.BRANCH_ID
							FROM	T0040_GENERAL_SETTING G1
									INNER JOIN (SELECT	MAX(FOR_DATE) AS FOR_DATE , BRANCH_ID
												FROM	T0040_GENERAL_SETTING G2
												WHERE	G2.For_Date <= @TO_DATE
												GROUP	BY G2.Branch_ID) G2 ON G1.Branch_ID=G2.Branch_ID AND G1.For_Date=G2.FOR_DATE
							GROUP BY G1.Branch_ID) G1 ON G.Gen_ID=G1.GEN_ID AND G.Branch_ID=G1.Branch_ID
		
		*/		
		
		select sd.Shift_ID ,From_Hour,To_Hour,Calculate_days--,OT_applicable,Fix_OT_Hours         
		  ,Shift_Dur ,isnull(Fix_W_Hours,0) as  Fix_W_Hours,sd.Working_Hrs_End_Time --,
		  --DeduHour_SecondBreak,DeduHour_ThirdBreak, S_St_Time,S_End_Time,S_Duration, T_St_Time,T_End_Time,T_Duration        
		INTO	#Shift_Detail
		from dbo.T0050_shift_detail sd WITH (NOLOCK)  inner join         
			  dbo.T0040_shift_master sm WITH (NOLOCK)  on sd.shift_ID= sm.Shift_ID inner join         
			   (select distinct Shift_ID from #Data ) q on sm.shift_Id=  q.shift_ID        
			   order by sd.shift_Id,From_Hour  
		
		
		Declare @From_Hour  numeric(12,3)      
		Declare @To_Hour numeric(12,3)        
		Declare @Calculate_days numeric(12,3)       
		Declare @Shift_Dur  varchar(10)        
		Declare @Shift_Dur_sec numeric         
		Declare @Fix_W_Hours  numeric(5,2)
		Declare @Working_hours_End_Time tinyint
	
		
	
		Declare Cur_shift cursor Fast_forward for         
			SELECT * FROM #Shift_Detail ORDER BY shift_Id, FROM_HOUR
			open cur_shift        
			  fetch next from cur_Shift into @shift_ID,@From_hour,@To_Hour,@Calculate_Days,@Shift_Dur,@Fix_W_Hours,@Working_hours_End_Time
				  While @@Fetch_Status=0        
				   begin           
				   
				     select @Shift_Dur_sec = dbo.F_Return_Sec(@Shift_Dur) 
				     
				     Update DL  
						Set Duration_in_sec = 
							Case When @Working_hours_End_Time = 1 AND  DL.Out_time > DL.Shift_End_Time Then DATEDIFF(minute,DL.In_Time,DL.Shift_End_Time) * 60 ELSE Duration_in_sec END 
				     From #DATA_LATE DL 
				     Where Shift_ID= @shift_ID

					 Update DL  
						Set Duration_in_sec = 
							Case When @Working_hours_End_Time = 1 AND  DL.In_Time < DL.Shift_Start_Time Then DATEDIFF(minute,DL.Shift_Start_Time,DL.Out_time) * 60 ELSE Duration_in_sec END 
				     From #DATA_LATE DL 
				     Where Shift_ID= @shift_ID
				     
					 if @Fix_W_Hours > 0         
						 begin   
							
								Update D        
								set P_Days = @Calculate_Days, Duration_in_sec =  dbo.f_return_sec( replace(@Fix_W_Hours,'.',':'))     
								FROM #DATA_LATE D LEFT OUTER JOIN #EMP_HW_CONS HW ON D.Emp_Id=HW.Emp_ID	
								INNER JOIN #EMP_GEN_SETTINGS_LATE G ON D.Emp_Id=G.EMP_ID --Checked Transfer WH Work to OT if setting applied in General Setting Otherwise it should considered as present day									--CHANGED FROM INNER JOIN TO LEFT OUTER BY RAMIZ ON 14/03/2017 (CONTINOUS ABSENT REPORT OF SAMARTH WAS COMING WRONG)
								Where	dbo.F_Return_Without_Sec(Duration_in_sec) >=dbo.f_return_sec( replace(@From_hour,'.',':')) 
										and dbo.F_Return_Without_Sec(Duration_in_sec) <= dbo.f_return_sec( replace(@To_Hour,'.',':'))        
										and Shift_ID= @shift_ID        and IO_Tran_Id  = 0   and chk_by_superior <> 1 -- Changed by rohit on 27122013	
										--and CHARINDEX(cast(d.For_date as varchar(11)),ISNULL(HW.WeekOffDate ,'')) < 1 --AND EMP_OT = 1 --Modified by Nimesh on 22-Jul-2016 ('00:00' From hours in Shift Master was creating issue on WeekOff OT Comp-Off)
										--and CHARINDEX(cast(d.For_date as varchar(11)),ISNULL(HW.HolidayDate ,'')) < 1
										--Modified following condition by Chetan on 05062017 (WeekOff & Holiday Work Transfer To OT Setting should be checked in following case)
										and (CASE WHEN G.Tras_Week_OT = 1 AND  CHARINDEX(cast(d.For_date as varchar(11)),ISNULL(HW.WeekOffDate ,'')) > 0 THEN 0 ELSE 1 END) = 1 --AND EMP_OT = 1 --Modified by Nimesh on 22-Jul-2016 ('00:00' From hours in Shift Master was creating issue on WeekOff OT Comp-Off)
										and (CASE WHEN G.Tras_Week_OT = 1 AND  CHARINDEX(cast(d.For_date as varchar(11)),ISNULL(HW.HolidayDate ,'')) > 1 THEN 0 ELSE 1 END) = 1
										And (not In_Time is null or not OUT_Time is null) --added by Hardik 27/07/2016 for Single punch Present case where Attendance Regularise Applied, it is taking Full Present at GTPL
							
						end        
					 else        
						begin        
							
							Update D        
							set P_Days = @Calculate_Days
							FROM #DATA_LATE D LEFT OUTER JOIN #EMP_HW_CONS HW ON D.Emp_Id=HW.Emp_ID		--CHANGED FROM INNER JOIN TO LEFT OUTER BY RAMIZ ON 14/03/2017 (CONTINOUS ABSENT REPORT OF SAMARTH WAS COMING WRONG)		
							INNER JOIN #EMP_GEN_SETTINGS_LATE G ON D.Emp_Id=G.EMP_ID --Checked Transfer WH Work to OT if setting applied in General Setting Otherwise it should considered as present day
							Where dbo.F_Return_Without_Sec(Duration_in_sec) >= dbo.f_return_sec( replace(@From_hour,'.',':')) and dbo.F_Return_Without_Sec(Duration_in_sec) <= dbo.f_return_sec( replace(@To_Hour,'.',':'))       
									and Shift_ID= @shift_ID        and IO_Tran_Id  = 0   
									and chk_by_superior <> 1 -- Changed by rohit on 27122013
									--Modified following condition by Chetan on 05062017 (WeekOff & Holiday Work Transfer To OT Setting should be checked in following case)
									and (CASE WHEN G.Tras_Week_OT = 1 AND  CHARINDEX(cast(d.For_date as varchar(11)),ISNULL(HW.WeekOffDate ,'')) > 0 THEN 0 ELSE 1 END) = 1 --AND EMP_OT = 1 --Modified by Nimesh on 22-Jul-2016 ('00:00' From hours in Shift Master was creating issue on WeekOff OT Comp-Off)
									and (CASE WHEN G.Tras_Week_OT = 1 AND  CHARINDEX(cast(d.For_date as varchar(11)),ISNULL(HW.HolidayDate ,'')) > 1 THEN 0 ELSE 1 END) = 1
									And (not In_Time is null or not OUT_Time is null) --added by Hardik 27/07/2016 for Single punch Present case where Attendance Regularise Applied, it is taking Full Present at GTPL
									
						end  
						
				  fetch next from cur_Shift into @shift_ID,@From_hour,@To_Hour,@Calculate_Days,@Shift_Dur,@Fix_W_Hours,@Working_hours_End_Time
				  end        
			close cur_Shift        
		 Deallocate Cur_Shift 
		
		--Update  Late Mark Second and Late Mark Hour
		--PRINT 'LATE 6 :' + CONVERT(VARCHAR(20), GETDATE(), 114);
		
		---- For Shift Start time 12:00 AM & Employee In punch Early then cancel Late Mark (Nirma Client)  ---Ankit 07112015
		--Deepal add the #data in inner join Date :- 29082022 Bug ID ticket 22260 Comment the below Query
		update E
		SET 
			Late_sec =	CASE WHEN (DATEPART(hh,DATEADD(SECOND,-Late_Limit_Sec,Shift_Time)) = 0 AND E.In_Time < DATEADD(D,1,E.For_Date) ) THEN  DATEDIFF(s,DATEADD(D,1,E.For_Date),E.In_Time)
						ELSE DATEDIFF(s,Shift_Time,E.In_Time) END,
			Late_Hour = dbo.F_Return_Hours (DATEDIFF(s,Shift_Time,E.In_Time)),
			Is_Late = 1
		from #Emp_Late E inner join #Data_LATE D on E.Emp_ID = D.Emp_Id and E.For_Date = D.For_date
		where DATEDIFF(s,Shift_Time,E.In_Time) > 0 and P_days = 1
		
		--UPDATE #Emp_Late  
		--SET 
		--	Late_sec =	CASE WHEN (DATEPART(hh,DATEADD(SECOND,-Late_Limit_Sec,Shift_Time)) = 0 AND In_Time < DATEADD(D,1,For_Date) ) THEN  DATEDIFF(s,DATEADD(D,1,For_Date),In_Time)
		--				ELSE DATEDIFF(s,Shift_Time,In_Time) END,
		--	Late_Hour = dbo.F_Return_Hours (DATEDIFF(s,Shift_Time,In_Time)),
		--	Is_Late = 1
		--WHERE DATEDIFF(s,Shift_Time,In_Time) > 0  
		--Deepal add the #data in inner join Date :- 29082022 Bug ID ticket 22260 Comment the Above Query
		
		--select * from #Emp_Late
		-- Added by Hardik 25/01/2020 for Manaksia as they have 15 mins max limit so below 15 min will not show as exempted
		--delete #Emp_Late WHERE DATEDIFF(s,Shift_Time,In_Time) <= 0
		--delete #Emp_Late WHERE datediff(s,out_time,Shift_End_Time) <= 0
		
		

		--Update #Emp_Late  set 
		--	Late_sec = datediff(s,Shift_Time,In_Time),
		--	Late_Hour = dbo.F_Return_Hours (datediff(s,Shift_Time,In_Time)),
		--	Is_Late = 1
		--	where datediff(s,Shift_Time,In_Time) > 0  
  
		--Update  Early Mark Second and Late Mark Hour
		
		Update #Emp_Late  set 
			Early_sec = datediff(s,out_time,Shift_End_Time), 
			Early_Hour = dbo.F_Return_Hours (datediff(s,out_time,Shift_End_Time)),
			is_early = 1
			where datediff(s,out_time,Shift_End_Time) > 0  
			
			

		 -- Update  Late Mark Second and Late Mark Hour zero when below maximum limit of shift time
		Update #Emp_Late set 
			Late_sec = 0,Late_Hour = 0
			where datediff(s,Shift_Time,In_Time) > 0 and 
					(
						In_Time >= Shift_Time and In_Time <= Shift_Max_St_Time 
						and datediff(s,dateadd(s,-1*Late_Limit_Sec,Shift_Time),Shift_End_Time)<=datediff(s,In_Time,Out_Time)
					)

		-- Update  Late Mark Second and Late Mark Hour zero when below 1 minuites 
		
		
	    Update #Emp_Late  
			set Late_sec = 0,Late_Hour = 0
			where Late_Sec < 60

		-- Update  Early Mark Second and Early Mark Hour zero when below maximum limit of shift time
		
		Update #Emp_Late  set 
			Early_sec = 0,Early_Hour = 0
			where datediff(s,Out_time,Shift_End_Time) > 0 and 
				  (
					Out_Time >= Shift_End_Time and Out_Time <= Shift_Max_ed_Time
					and datediff(s,dateadd(s,Early_Limit_Sec,Shift_End_Time),shift_time)<=datediff(s,In_Time,Out_Time)
				   )
				   
				
	 	
		-- Update  Late Mark Second and Late Mark Hour zero when below 1 minuites  
		Update #Emp_Late  set 
			Early_sec = 0,Early_Hour = 0
			where Early_sec < 60
 	      
	
		--First	Half Leave	    
		Update #Emp_Late  set 
			Late_sec = 0,Late_Hour = 0
		from #Emp_Late EL
		inner join (
					select la.Leave_Approval_ID,la.Emp_ID,lad.To_Date from T0120_LEAVE_APPROVAL la  WITH (NOLOCK) 
					inner join T0130_LEAVE_APPROVAL_DETAIL lad  WITH (NOLOCK) on la.Leave_Approval_ID = lad.Leave_Approval_ID
					where Leave_Assign_As = 'First Half' and Approval_Status = 'A'
					) Qry 
					on Qry.Emp_ID = el.Emp_ID and Qry.To_Date = el.For_Date
					
					
		--Second Half Leave
  
		 Update #Emp_Late set 
			Early_sec = 0,Early_Hour = 0
		 from #Emp_Late EL
		inner join (
					select la.Leave_Approval_ID,la.Emp_ID,lad.To_Date from T0120_LEAVE_APPROVAL la  WITH (NOLOCK) 
					inner join T0130_LEAVE_APPROVAL_DETAIL lad WITH (NOLOCK)  on la.Leave_Approval_ID = lad.Leave_Approval_ID
					where Leave_Assign_As = 'Second Half' and Approval_Status = 'A'
					) Qry 
					on Qry.Emp_ID = el.Emp_ID and Qry.To_Date = el.For_Date
					
					
					
		-- Full Day Leave
		
		 Update #Emp_Late set 
			Early_sec = 0, Early_Hour = 0,
			Late_sec = 0,  Late_Hour = 0
		 from #Emp_Late EL inner join 
		 t0140_leave_transaction Qry WITH (NOLOCK)  on Qry.Emp_ID = el.Emp_ID and Qry.For_Date = el.For_Date 
		 and (qry.leave_used = 1  or qry.CompOff_Used = 1) 
		 
		 
		 -- Part Day Leave
		 
		Update #Emp_Late  set 
			Late_sec = 0,Late_Hour = 0
		from #Emp_Late EL 
		inner join (
						select la.Leave_Approval_ID,la.Emp_ID,lad.To_Date,Leave_out_time ,Leave_In_Time,From_Date
						from T0120_LEAVE_APPROVAL la WITH (NOLOCK)  inner join T0130_LEAVE_APPROVAL_DETAIL lad WITH (NOLOCK)  on la.Leave_Approval_ID = lad.Leave_Approval_ID
						where upper(Leave_Assign_As) = 'PART DAY' and Approval_Status = 'A'
				    ) Qry 
					--on Qry.Emp_ID = el.Emp_ID and Qry.To_Date = el.For_Date and Qry.Leave_out_time =EL.Shift_Max_St_Time  --and Qry.Leave_out_time =EL.Shift_Time -- changed by rohit on 20042016
					--Above commented by Sumit on 09012017 for Night Shift Short Leave Case because to date is changing in that case
					on Qry.Emp_ID = el.Emp_ID and Qry.From_Date = el.For_Date and Qry.Leave_out_time =EL.Shift_Max_St_Time
 
	     Update #Emp_Late set 
	     Early_sec = 0, Early_Hour = 0
		 from #Emp_Late EL
   		inner join (
   					 select la.Leave_Approval_ID,la.Emp_ID,lad.To_Date,Leave_out_time ,Leave_In_Time  
   					 from T0120_LEAVE_APPROVAL la WITH (NOLOCK)  inner join T0130_LEAVE_APPROVAL_DETAIL lad WITH (NOLOCK)  on la.Leave_Approval_ID = lad.Leave_Approval_ID
					 where upper(Leave_Assign_As) = 'PART DAY' and Approval_Status = 'A'
					) Qry 
					on Qry.Emp_ID = el.Emp_ID and Qry.To_Date = el.For_Date  and Qry.Leave_In_Time =EL.Shift_max_Ed_Time  --and Qry.Leave_In_Time =EL.Shift_End_Time  -- changed by rohit on 20042016
			
		
		 -- Added by Gadriwala Muslim 03062015-Start
		 --comment by chetan 170717
		
		
   update #Emp_Late
   set Late_Sec = 0 
	   ,Late_Hour = 0
	   from #Emp_Late EL
	   inner join ( select Chk_By_Superior,Is_Cancel_Early_Out,Is_Cancel_Late_In,Emp_ID,For_Date 
					from T0150_EMP_INOUT_RECORD E WITH (NOLOCK)  where 
					For_Date >=@From_Date and For_Date <=@to_Date and e.Cmp_Id =@Cmp_ID 
					--and IsNull(Chk_By_Superior,0) <> 0 and ISNULL(E.Half_Full_day,'') = '' updated by chetan 170717					
					and ((IsNull(Chk_By_Superior,0)= 1 and ISNULL(E.Half_Full_day,'') <> '') OR (ISNULL(E.Half_Full_day,'') = '' AND IsNull(Chk_By_Superior,0)= 2))
					and Is_Cancel_Late_In =  1
					)Qry		--Changed by Ramiz on 29/03/2016 , Previously it was Chk_By_Superior = 1 , but as now Chk_By_Superior = 2 is also included , so Condition is changed
			on Qry.Emp_ID =el.Emp_ID and Qry.For_Date = el.For_Date 
			
			
  
   update #Emp_Late
   set Early_sec = 0 
	   ,Early_Hour = 0
	   from #Emp_Late EL
	   inner join ( select Chk_By_Superior,Is_Cancel_Early_Out,Is_Cancel_Late_In,Emp_ID,For_Date 
					from T0150_EMP_INOUT_RECORD E WITH (NOLOCK)  where 
					For_Date >=@From_Date and For_Date <=@to_Date and e.Cmp_Id =@Cmp_ID 
					and ((IsNull(Chk_By_Superior,0)= 1 and ISNULL(E.Half_Full_day,'') <> '') OR (ISNULL(E.Half_Full_day,'') = '' AND IsNull(Chk_By_Superior,0)= 2))
					--and Chk_By_Superior <> 0 comment by chetan 170717
					and Is_Cancel_Early_Out =  1)Qry	--Changed by Ramiz on 29/03/2016 , Previously it was Chk_By_Superior = 1 , but as now Chk_By_Superior = 2 is also included , so Condition is changed
			on Qry.Emp_ID =el.Emp_ID and Qry.For_Date = el.For_Date 
   -- Added by Gadriwala Muslim 03062015 -End	
   
   
   
   --Added by Gadriwala Muslim 24062015 - Start		
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
	from T0050_Shift_Detail SD inner join #Emp_Late EL on EL.shift_ID = Sd.Shift_ID  order by SD.shift_ID,Calculate_Days 
        
     /*Commented by Nimesh On 19-Dec-2017 (Creating major problem while processing bulk salary with mix policy)
     
	DECLARE @ABS_CONSTRAINT VARCHAR(MAX);
		
	SELECT @ABS_CONSTRAINT= COALESCE(@ABS_CONSTRAINT + '#', '') + CAST(EMP_ID as varchar(18)) 
	FROM
	(SELECT Distinct EMP_ID from #Emp_Late where Is_Late = 1 and For_Date >= @From_date and For_Date <= @To_Date and out_Time is null 
	union -- Records which Calculate Days greater than 0 Check for Absent
	select EL.emp_ID from #Emp_Late EL inner join
	#Shift_Details Qry on Qry.Shift_ID = El.Shift_ID and Qry.Row_ID = 1
	where  EL.Is_Late = 1 and Datediff(s,In_Time,Out_Time)/3600  < From_hour  and out_time is not null 
	and Calculate_days > 0   and EL.For_Date >= @From_date and EL.For_Date <= @To_Date	
	union   -- Records which Calculate Days is 0 Check for Absent
	select EL.emp_ID from #Emp_Late EL inner join
	#Shift_Details Qry on Qry.Shift_ID = El.Shift_ID and Qry.Row_ID = 1
	where  EL.Is_Late = 1 and Datediff(s,In_Time,Out_Time)/3600  >= From_hour and  Datediff(s,In_Time,Out_Time)/3600  <= To_Hour  and out_time is not null 
	and Calculate_days = 0   and EL.For_Date >= @From_date and EL.For_Date <= @To_Date) t
	
	
	
	---- Comment by nilesh patel on 24102016 For Absenet day Calculate as Early Out Days 
		
					
	--Exec dbo.SP_CALCULATE_PRESENT_DAYS @Cmp_ID,@ABS_FROM_DATE,@ABS_TO_DATE,0,0,0,0,0,0,0,@ABS_CONSTRAINT,4,'',1 
	--Exec dbo.SP_CALCULATE_PRESENT_DAYS @Cmp_ID =@Cmp_ID,@From_Date=@ABS_FROM_DATE,@To_Date=@ABS_TO_DATE,@Branch_ID=0,@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Emp_ID=0,@constraint=@ABS_CONSTRAINT,@Return_Record_set=4,@StrWeekoff_Date='',@Is_Split_Shift_Req=1 ,@Late_SP=1  

		--Added Condition by Hardik and nimesh on 09/02/2017 
		If Isnull(@ABS_CONSTRAINT,'') <> ''
			Begin				
				truncate table #DATA   --Added by Jaina 17-11-2016
				Exec dbo.SP_CALCULATE_PRESENT_DAYS @Cmp_ID =@Cmp_ID,@From_Date=@From_Date,@To_Date=@To_Date,@Branch_ID=0,@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Emp_ID=0,@constraint=@ABS_CONSTRAINT,@Return_Record_set=4,@StrWeekoff_Date='',@Is_Split_Shift_Req=1 ,@Late_SP=1  
			End

	 
	
		*/

		-- Commented & Added Below Portion by Hardik 02/12/2020 for Nandan client as they have Second Half leave and First Half Employee came for Half day with Late Mark
		--update	#Emp_Late 
		--		set Is_Late = 0,Is_Early = 0
		--	from #Emp_Late EL
		--	inner join  #DATA_LATE D on EL.For_Date = D.For_date and EL.Emp_ID = D.Emp_ID  and D.P_days <> 1
		--where Cmp_ID = @Cmp_ID AND @ONLY_INOUT=0

		-- Added by Hardik 02/12/2020 for Nandan client as they have Second Half leave and First Half Employee came for Half day with Late Mark
		
		
	--changed by Deepali for 'Early'  type Report-29nov2021
	--if (@Format_Type <> 'Early' and @Format_Type <> 'Late' )
	--print '33333'
	--begin 
		If @Format_Type <> 'Extra-Exempted'    -- Added Else condition and above If condition by Hardik 23/02/2021 for Manubhai Client
			update	#Emp_Late 
					set Is_Late = 0,Is_Early = 0
				from #Emp_Late EL
				inner join  #DATA_LATE D on EL.For_Date = D.For_date and EL.Emp_ID = D.Emp_ID
			where EL.Cmp_ID = @Cmp_ID AND @ONLY_INOUT=0 and D.P_days <> 1 
				And Not Exists(Select 1 From t0140_leave_transaction Qry Where Qry.Emp_ID = el.Emp_ID and Qry.For_Date = el.For_Date And (qry.leave_used > 0 or qry.CompOff_Used > 0))
	
		Else -- Added Else condition and above If condition by Hardik 23/02/2021 for Manubhai Client
			update	#Emp_Late 
					set Is_Late = 0,Is_Early = 0
				from #Emp_Late EL
				inner join  #DATA_LATE D on EL.For_Date = D.For_date and EL.Emp_ID = D.Emp_ID
			where EL.Cmp_ID = @Cmp_ID AND @ONLY_INOUT=0 and D.P_days = 1
				And Not Exists(Select 1 From t0140_leave_transaction Qry Where Qry.Emp_ID = el.Emp_ID and Qry.For_Date = el.For_Date And (qry.leave_used > 0 or qry.CompOff_Used > 0))
	
	 --end

	 ------------

	 	update	#Emp_Late 
				set Is_Late = 1
		from #Emp_Late EL
				inner join  #DATA_LATE D on EL.For_Date = D.For_date and EL.Emp_ID = D.Emp_ID  and D.P_days = 0
		where Cmp_ID = @Cmp_ID and ( EL.Is_Late_Calc_Ho_WO = 1 and ( D.Weekoff_OT_Sec > 0 or D.Holiday_OT_Sec > 0))
				AND @ONLY_INOUT=0
	
		
		-----------------------------------------------------------------------------------------------------------
							-- Late Mark Deduction --------			
		-----------------------------------------------------------------------------------------------------------
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
		
				--if @Late_is_slabwise = 1 and @Early_is_slabwise = 1 and @Early_Dedu_Type_inc = 'Hour' and @Late_Dedu_Type_inc = 'Hour' 
				--	begin			
				--		exec SP_GET_LATE_EARLY_SLABWISE @Cmp_ID,@Gen_Id,@Total_LE_Hours ,@Total_penalty_days output,0				
				--		set @Penalty_days_Early_Late = @Total_penalty_days
						
				--	end
				--else if @Late_is_slabwise = 1 and @Late_Dedu_Type_inc = 'Hour' 
				--	begin
						
				--		exec SP_GET_LATE_EARLY_SLABWISE @Cmp_ID,@Gen_Id,@Total_Late_Hours,@Total_penalty_days output,0
				--		set @Late_Absent_Day = @Total_penalty_days
							
										
				--	end
				--else if @Early_is_slabwise = 1 and @Early_Dedu_Type_inc = 'Hour'  
				--	begin
				--		exec SP_GET_LATE_EARLY_SLABWISE @Cmp_ID,@Gen_Id,@Total_Early_Hours,@Total_penalty_days output,0	
				--		set @Early_Sal_Dedu_Days = @Total_penalty_days
							
				--	end 
	
	

		declare @Not_Calculate_Work_After_ShiftEnd TinyInt
		declare @Not_Calculate_Work_Before_ShiftStart TinyInt
		
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
													Early_Limit_Sec,
													Shift_ID
													from #Emp_Late el 
													where ( is_Late = 1 or is_Early =1 )
													order by Emp_ID,For_Date
													
													
		Open curdeduction  
			Fetch Next From curdeduction into @cur_Emp_ID,@cur_Branch_ID,@cur_For_date,@cur_Late_Hour,@cur_Early_Hour,@cur_Late_Seconds,@cur_Early_Seconds,@Working_Time_sec,@Shift_Time_Sec,@Cur_In_Time,@Cur_Out_Time,@Cur_Shift_st_Time,@cur_Shift_End_Time,@Cur_Late_Limit_Sec,@Cur_Early_Limit_Sec,@Shift_ID
			While @@fetch_status = 0   
				BEGIN
						SELECT	@Not_Calculate_Work_After_ShiftEnd = Max(SD.Working_Hrs_End_Time), 
								@Not_Calculate_Work_Before_ShiftStart = MAX(SD.Working_Hrs_St_Time)  
						FROM	T0050_SHIFT_DETAIL SD  WITH (NOLOCK) 
						Where	Shift_ID = @Shift_ID
						
						
						IF @Not_Calculate_Work_After_ShiftEnd = 1
							SELECT	@Working_Time_sec = @Working_Time_sec - DATEDIFF(S,@cur_Shift_End_Time,@Cur_Out_Time)
							FROM	#Emp_Late
							WHERE	Out_Time > @cur_Shift_End_Time and For_Date= @cur_For_date AND  Emp_ID=@cur_Emp_ID

						IF @Not_Calculate_Work_Before_ShiftStart = 1
							SELECT	@Working_Time_sec = @Working_Time_sec - DATEDIFF(S, @Cur_In_Time, @Cur_Shift_st_Time)
							FROM	#Emp_Late
							WHERE	@Cur_In_Time < @Cur_Shift_st_Time and For_Date= @cur_For_date AND  Emp_ID=@cur_Emp_ID
						
							If @cur_Emp_ID <> @Previous_Emp_ID
								begin
									set @Late_Exempted_Count = 0
									set @Early_Exempted_Count = 0
									set @Total_Early_Adjust_days = 0
									set @Total_Late_Adjust_days = 0
									set @Temp_Extra_Count = 0
									set @Extra_Exemption = 0
								end
							
							 IF @previous_Branch_ID <> @cur_Branch_ID 
								begin
											SELECT  
													@gen_ID =  gen_ID,
													@Late_Limit = case when late_limit = '' then '00:00' else isnull(late_limit,'00:00')end ,
													@Late_Adj_Day =	isnull(Late_Adj_Day,0) , 
													@Late_Deduction_Days =  isnull(Late_Deduction_Days,0),
													@Late_CF_Reset_On =  isnull(Late_CF_Reset_On,''),
													@Is_late_CF =  isnull(Is_Late_CF,0),
													@Late_with_Leave = isnull(Late_with_Leave,0),
													@Late_Count_Exemption = Isnull(Late_Count_Exemption,0),
													@Late_Hour_Upper_Rounding = ISNULL(Late_Hour_Upper_Rounding,0),	
													@late_exemption_limit = case when late_exemption_limit = '' then '00:00' else ISNULL(late_exemption_limit,'00:00')end,	    
													@Max_Late_Limit = case when Max_Late_Limit = '' then '00:00' else ISNULL(Max_Late_Limit,'00:00')end,
													@Late_Is_Slabwise = Isnull(is_Late_Calc_Slabwise,0),
													@Late_Calculate_Type =  isnull(Late_Calculate_Type,'Day'),
													@Late_Extra_Deduction = isnull(Late_Extra_Deduction,0),
													@Is_Late_CF = isnull(Is_Late_CF,0),
													@Is_Late_Calc_On_HO_WO = isnull(Is_Late_Calc_On_HO_WO,0),
													@Early_Limit = case when Early_Limit = '' then '00:00' else isnull(Early_Limit,'00:00')end ,
													@Early_Adj_Day = isnull(Early_Adj_Day,0),
													@Early_Deduction_Days = isnull(Early_Deduction_Days,0),
													@Early_Extra_Deduction = isnull(Early_Extra_Deduction,0),
													@Max_Early_Limit = case when Max_Early_Limit = '' then '00:00' else isnull(Max_Early_Limit,'00:00')end,
													@Early_Exemption_Limit = case when early_exemption_limit = '' then '00:00' else ISNULL(early_exemption_limit,'00:00')end,
													@Early_CF_Reset_On = isnull(Early_CF_Reset_On,''),
													@Is_Early_Calc_On_HO_WO = isnull(Is_Early_Calc_On_HO_WO,0),
													@Is_Early_CF = isnull(Is_Early_CF,0) ,
													@Early_With_Leave = isnull(Early_With_Leave,0) ,
													@Early_Count_Exemption = isnull(Early_Count_Exemption,0),
													@Early_Is_Slabwise = isnull(is_Early_Calc_Slabwise,0),
													@Early_Calculate_type = isnull(Early_Calculate_type,'Day'),
													@Extra_exemption_limit = case when LateEarly_Exemption_MaxLimit = '' then '00:00' else ISNULL(LateEarly_Exemption_MaxLimit,'00:00')end ,
													@Extra_Count_Exemption = isnull(LateEarly_Exemption_Count,0),
													@Late_Mark_Scenario = isnull(Late_Mark_Scenario,1)
											 FROM dbo.T0040_GENERAL_SETTING WITH (NOLOCK)  WHERE Branch_ID = @cur_Branch_ID AND Cmp_ID = @Cmp_ID and
											For_Date = 
											(
												select MAX(For_Date) from T0040_GENERAL_SETTING  WITH (NOLOCK) 
												where Cmp_ID = @Cmp_ID and For_Date <= @To_Date and Branch_ID = @cur_Branch_ID
										    )
										   
									end
							
							-----Extra Exemption	
							IF (@Shift_Time_Sec - @Working_Time_Sec) <> 0 
								BEGIN
								
									IF  dbo.F_Return_Sec(@Extra_exemption_limit) >= (@Shift_Time_Sec - @Working_Time_Sec)
										BEGIN
											IF @Extra_Count_Exemption >  @Temp_Extra_Count
												BEGIN
													SET @Extra_Exemption = 1			
												END
											ELSE
												BEGIN
													SET @Extra_Exemption = 0			
												END
										END		
									ELSE
										BEGIN
											SET @Extra_Exemption = 0			
										END
								END
							ELSE
								BEGIN
									SET @Extra_Exemption = 0			
								END

						-----Extra Exemption
							
							--Changed by Gadriwala Muslim 22062015 - Start
							Declare @Max_Late_Limit_Datetime as datetime
							Declare @Max_Exemption_Late_Limit_Datetime as datetime
							Declare @Max_Early_Limit_Datetime as datetime
							Declare @Max_Exemption_Early_Limit_datetime as datetime
							
							
							if @Cur_Late_Limit_Sec	 > 0 
								begin	   
									set @Max_Late_Limit_Datetime = 	dateadd(s,dbo.F_Return_Sec(@Max_Late_Limit),Dateadd(s,-@Cur_Late_Limit_Sec,@Cur_Shift_st_Time))	 -- Added by Gadriwala Muslim 22062015
									set @Max_Exemption_Late_Limit_Datetime =  dateadd(s,dbo.F_Return_Sec(@late_exemption_limit),dateadd(s,-@Cur_Late_Limit_Sec,@Cur_Shift_St_Time)) -- Added by Gadriwala Muslim 22062015
								end
							else
								begin
									set @Max_Late_Limit_Datetime = 	dateadd(s,dbo.F_Return_Sec(@Max_Late_Limit),@Cur_Shift_st_Time)	 -- Added by Gadriwala Muslim 22062015
									set @Max_Exemption_Late_Limit_Datetime =  dateadd(s,dbo.F_Return_Sec(@late_exemption_limit),@Cur_Shift_St_Time) -- Added by Gadriwala Muslim 22062015
								end
							
							if @Cur_Early_Limit_Sec > 0 
								begin
									set @Max_Early_Limit_Datetime =	dateadd(s,dbo.F_Return_Sec(@Max_Early_Limit) * -1,dateadd(s,@Cur_Early_Limit_Sec,@Cur_Shift_End_Time))	
									set @Max_Exemption_Early_Limit_datetime = 	dateadd(s,dbo.F_Return_Sec(@Early_Exemption_Limit) * -1,dateadd(s,@Cur_Early_Limit_Sec,@Cur_Shift_End_Time))									
								end	
							else
								begin
									set @Max_Early_Limit_Datetime =	dateadd(s,dbo.F_Return_Sec(@Max_Early_Limit) * -1,@Cur_Shift_End_Time)	
									set @Max_Exemption_Early_Limit_datetime = 	dateadd(s,dbo.F_Return_Sec(@Early_Exemption_Limit) * -1,@Cur_Shift_End_Time)									
								end
							--Changed by Gadriwala Muslim 22062015 - End	
							
							if isnull(@cur_Late_Hour,'') <> ''
								begin
											if @Late_Calculate_Type = 'Hour' and @Late_Is_Slabwise = 1
												begin  
													exec SP_GET_LATE_EARLY_SLABWISE @Cmp_ID,@Gen_Id,@cur_Late_Hour,@Late_Deduction_Days output,0								
												end		
										    If @Late_Limit <> '00:00'
												begin
													If isnull(@cur_Late_Seconds,0) > 0 
														set @cur_Late_Seconds = @cur_Late_Seconds - isnull(dbo.F_Return_Sec(@Late_Limit),0) 						
											end
											
										if @Cur_In_Time > @Cur_Shift_st_Time and @Cur_In_Time <=  @Max_Late_Limit_Datetime  -- Changed by Gadriwala Muslim 22062015 dateadd(s,dbo.F_Return_Sec(@Max_Late_Limit),@Cur_Shift_st_Time)											
											BEGIN
												--Changed by deepali
												--If @Shift_Time_Sec > @Working_Time_Sec -- Surplus Works Late come Late Going, Early come Early Going
												--	begin	
														
														if  dbo.F_Return_Sec(@late_exemption_limit) = 0  or @cur_In_Time <=  @Max_Exemption_Late_Limit_Datetime   -- Changed by Gadriwala Muslim 22062015 --dateadd(s,dbo.F_Return_Sec(@late_exemption_limit),@Cur_Shift_St_Time)
															begin
																
																set @Late_Exempted_Count = @Late_Exempted_Count + 1
																	If @Late_adj_Day > 0 
																			begin
																				
																				If @Late_Count_Exemption < @Late_Exempted_Count 
																					begin
																						
																							set @Total_Late_Adjust_days = @Total_Late_Adjust_days + 1	
																							if @Late_Adj_Day <= @Total_Late_Adjust_days
																							  begin		
																									SET @Total_Late_Adjust_days = 0	
																									IF @Extra_Exemption = 0	
																										BEGIN	 
																											update #Emp_Late set Late_Deduct_Days = @Late_Deduction_Days
																											where For_Date = @cur_For_date and Emp_ID = @cur_Emp_ID 
																											and Cmp_ID = @Cmp_ID
																										END
																									ELSE
																										BEGIN
																											SET @Temp_Extra_Count = @Temp_Extra_Count + 1
																											UPDATE #Emp_Late SET Extra_Exempted = 1 , Extra_Exempted_Sec = (@Shift_Time_Sec - @Working_Time_Sec)
																											WHERE For_Date = @cur_For_date AND Emp_ID = @cur_Emp_ID AND Cmp_ID = @Cmp_ID		
																										END	
																							  end
																						end
																			end
																		else
																			begin
																				
																				If @Late_Count_Exemption < @Late_Exempted_Count 
																					begin
																						
																						IF @Extra_Exemption  = 0
																							BEGIN
																								
																								update #Emp_Late set Late_Deduct_Days = @Late_Deduction_Days
																								 where For_Date = @cur_For_date and Emp_ID = @cur_Emp_ID 
																								 and Cmp_ID = @Cmp_ID	
																							END
																						ELSE
																							BEGIN
																								
																								SET @Temp_Extra_Count = @Temp_Extra_Count + 1
																								UPDATE #Emp_Late SET Extra_Exempted = 1 , Extra_Exempted_Sec = (@Shift_Time_Sec - @Working_Time_Sec)
																								WHERE For_Date = @cur_For_date AND Emp_ID = @cur_Emp_ID AND Cmp_ID = @Cmp_ID		
																							END	
																					end
																			end
															end
														else
															begin
																select 10
																	If @Late_Adj_Day > 0 
																			begin
																			select 11
																					set @Total_Late_Adjust_days = @Total_Late_Adjust_days + 1
																					if @Total_Late_Adjust_days >= @Late_Adj_Day
																						begin
																							select 12
																							  set @Total_Late_Adjust_days = 0
																							   IF @Extra_Exemption = 0
																									BEGIN
																										
																									  update #Emp_Late set Late_Deduct_Days = @Late_Deduction_Days 
																									  where For_Date = @cur_For_date 
																									   and Emp_ID = @cur_Emp_ID 
																									   and Cmp_ID = @Cmp_ID	
																									 END
																								ELSE
																									BEGIN
																										
																										SET @Temp_Extra_Count = @Temp_Extra_Count + 1
																										UPDATE #Emp_Late SET Extra_Exempted = 1 , Extra_Exempted_Sec = (@Shift_Time_Sec - @Working_Time_Sec)
																										WHERE For_Date = @cur_For_date AND Emp_ID = @cur_Emp_ID AND Cmp_ID = @Cmp_ID		
																									END 	   
																							   
																						end
																			end
																		else
																			begin
																				IF @Extra_Exemption = 0
																					BEGIN
																						
																						update #Emp_Late set Late_Deduct_Days = @Late_Deduction_Days 
																						 where For_Date = @cur_For_date and Emp_ID = @cur_Emp_ID and Cmp_ID = @Cmp_ID		
																					END
																				ELSE
																					BEGIN
																						
																						SET @Temp_Extra_Count = @Temp_Extra_Count + 1
																						UPDATE #Emp_Late SET Extra_Exempted = 1 , Extra_Exempted_Sec = (@Shift_Time_Sec - @Working_Time_Sec)
																						WHERE For_Date = @cur_For_date AND Emp_ID = @cur_Emp_ID AND Cmp_ID = @Cmp_ID		
																					END 	 
																			end
															end

														
												--	end
												end
											else
												begin  
													
													   if  dbo.F_Return_Sec(@late_exemption_limit) = 0  or @cur_In_Time <= @Max_Exemption_Late_Limit_Datetime -- Changed by Gadriwala Muslim 22062015 --dateadd(s, dbo.F_Return_Sec(@late_exemption_limit),@Cur_Shift_St_Time)
															begin
																
																		set @Late_Exempted_Count = @Late_Exempted_Count + 1
																			If @Late_adj_Day > 0 
																				begin
																				
																					If @Late_Count_Exemption < @Late_Exempted_Count 
																						begin
																							set @Total_Late_Adjust_days = @Total_Late_Adjust_days + 1	
																							if @Late_Adj_Day <= @Total_Late_Adjust_days
																							  begin		
																									set @Total_Late_Adjust_days = 0		 
																									IF @Extra_Exemption = 0
																										BEGIN
																											update #Emp_Late set Late_Deduct_Days = @Late_Deduction_Days
																											where For_Date = @cur_For_date and Emp_ID = @cur_Emp_ID 
																											and Cmp_ID = @Cmp_ID		
																										END
																									ELSE
																										BEGIN
																											SET @Temp_Extra_Count = @Temp_Extra_Count + 1
																											UPDATE #Emp_Late SET Extra_Exempted = 1 , Extra_Exempted_Sec = (@Shift_Time_Sec - @Working_Time_Sec)
																											WHERE For_Date = @cur_For_date AND Emp_ID = @cur_Emp_ID AND Cmp_ID = @Cmp_ID		
																										END		
																						  end
																					end
																				end
																			else
																				begin
																					If @Late_Count_Exemption < @Late_Exempted_Count 
																						begin
																							IF @Extra_Exemption = 0
																								BEGIN
																									UPDATE #Emp_Late SET Late_Deduct_Days = @Late_Deduction_Days
																									WHERE For_Date = @cur_For_date AND Emp_ID = @cur_Emp_ID 
																									AND Cmp_ID = @Cmp_ID		
																								END
																							ELSE
																								BEGIN
																									SET @Temp_Extra_Count = @Temp_Extra_Count + 1
																									UPDATE #Emp_Late SET Extra_Exempted = 1 , Extra_Exempted_Sec = (@Shift_Time_Sec - @Working_Time_Sec)
																									WHERE For_Date = @cur_For_date AND Emp_ID = @cur_Emp_ID AND Cmp_ID = @Cmp_ID		
																								END	
																						end
																				end
																		end
													   else
														    begin
																				If @Late_Adj_Day > 0 
																						begin
																						
																								set @Total_Late_Adjust_days = @Total_Late_Adjust_days + 1
																								if @Total_Late_Adjust_days >= @Late_Adj_Day
																									begin
																										  set @Total_Late_Adjust_days = 0
																										  if @Extra_Exemption = 0
																												begin
																													  update #Emp_Late set Late_Deduct_Days = @Late_Deduction_Days ,Is_Maximum_Late = 1 -- Changed by Gadriwala Muslim 23062015
																													  where For_Date = @cur_For_date 
																													   and Emp_ID = @cur_Emp_ID 
																													   and Cmp_ID = @Cmp_ID	
																												END
																										  ELSE
																												BEGIN
																													SET @Temp_Extra_Count = @Temp_Extra_Count + 1
																													UPDATE #Emp_Late SET Extra_Exempted = 1 , Extra_Exempted_Sec = (@Shift_Time_Sec - @Working_Time_Sec)
																													WHERE For_Date = @cur_For_date AND Emp_ID = @cur_Emp_ID AND Cmp_ID = @Cmp_ID		
																												END
																									end
																						end
																					else
																						begin
																							IF @Extra_Exemption = 0
																								BEGIN
																										UPDATE #Emp_Late SET Late_Deduct_Days = @Late_Deduction_Days ,Is_Maximum_Late = 1 -- Changed by Gadriwala Muslim 23062015
																										 WHERE For_Date = @cur_For_date AND Emp_ID = @cur_Emp_ID AND Cmp_ID = @Cmp_ID		
																								END
																							ELSE
																								BEGIN
																									SET @Temp_Extra_Count = @Temp_Extra_Count + 1
																									UPDATE #Emp_Late SET Extra_Exempted = 1 , Extra_Exempted_Sec = (@Shift_Time_Sec - @Working_Time_Sec)
																										WHERE For_Date = @cur_For_date AND Emp_ID = @cur_Emp_ID AND Cmp_ID = @Cmp_ID		
																								END
																								
																						end
																		end	
																	
												end		
									  			
								end	    
							if isnull(@cur_Early_Hour,'') <> ''
								begin
										   if @Late_Calculate_Type = 'Hour' and @Late_Is_Slabwise = 1
												begin
													exec SP_GET_LATE_EARLY_SLABWISE @Cmp_ID,@Gen_Id,@cur_Early_Hour,@Early_Deduction_Days output,0								
												end											
										   If @Early_Limit <> '00:00'
											begin 
											
												If isnull(@cur_Early_Seconds,0) > 0 
													set @cur_Early_Seconds = @cur_Early_Seconds - isnull(dbo.F_Return_Sec(@Early_Limit),0) 						
											end
											
										
											if @cur_Out_Time < @cur_Shift_End_Time and @Cur_Out_Time >=  @Max_Early_Limit_Datetime  --  changed by Gadriwala Muslim 22062015 --dateadd(s,dbo.F_Return_Sec(@Max_Early_Limit) * -1,@Cur_Shift_End_Time)											
												begin 
															--select dbo.F_Return_Sec(@Early_Exemption_Limit),@cur_Out_Time,@Cur_Shift_End_Time,dateadd(s,dbo.F_Return_Sec(@Early_Exemption_Limit) * -1,@Cur_Shift_End_Time)
															--Added by Deepali
													--If @Shift_Time_Sec > @Working_Time_Sec -- Surplus Works Late come Late Going, Early come Early Going
													--  begin  	
														if  dbo.F_Return_Sec(@Early_Exemption_Limit) = 0  or @cur_Out_Time >=  @Max_Exemption_Early_Limit_datetime  --changed by Gadriwala Muslim 22062015  -- dateadd(s,dbo.F_Return_Sec(@Early_Exemption_Limit) * -1,@Cur_Shift_End_Time)
															begin
														
																set @Early_Exempted_Count = @Early_Exempted_Count + 1
																
																If @Early_Adj_Day > 0 
																	begin
																			If @Early_Count_Exemption < @Early_Exempted_Count 
																				begin
																					set @Total_Early_Adjust_days = @Total_Early_Adjust_days + 1	
																					if @Early_Adj_Day  <= @Total_Early_Adjust_days
																					  begin		
																							set @Total_Early_Adjust_days = 0		
																							IF @Extra_Exemption = 0 
																								BEGIN
																									UPDATE #Emp_Late SET Early_Deduct_Days = @Early_Deduction_Days
																									WHERE For_Date = @cur_For_date AND Emp_ID = @cur_Emp_ID 
																									AND Cmp_ID = @Cmp_ID
																								END
																							ELSE
																								BEGIN
																									SET @Temp_Extra_Count = @Temp_Extra_Count + 1
																									UPDATE #Emp_Late SET Extra_Exempted = 1 , Extra_Exempted_Sec = (@Shift_Time_Sec - @Working_Time_Sec)
																									WHERE For_Date = @cur_For_date AND Emp_ID = @cur_Emp_ID AND Cmp_ID = @Cmp_ID		
																								END
																					  end
																				end
																	end
																else
																	begin
																			If @Early_Count_Exemption < @Early_Exempted_Count 
																			begin
																				IF @Extra_Exemption = 0 
																					BEGIN
																						UPDATE #Emp_Late SET Early_Deduct_Days = @Early_Deduction_Days
																						 WHERE For_Date = @cur_For_date AND Emp_ID = @cur_Emp_ID 
																						 AND Cmp_ID = @Cmp_ID
																					END
																				ELSE
																					BEGIN
																						SET @Temp_Extra_Count = @Temp_Extra_Count + 1
																						UPDATE #Emp_Late SET Extra_Exempted = 1 , Extra_Exempted_Sec = (@Shift_Time_Sec - @Working_Time_Sec)
																						WHERE For_Date = @cur_For_date AND Emp_ID = @cur_Emp_ID AND Cmp_ID = @Cmp_ID		
																					END
																			end
																	end
															end
														else
															begin
																If @Early_Adj_Day > 0 
																	begin
																			set @Total_Early_Adjust_days = @Total_Early_Adjust_days + 1
																			if @Total_Early_Adjust_days >= @Early_Adj_Day
																				begin
																					set @Total_Early_Adjust_days = 0
																					IF @Extra_Exemption = 0
																						BEGIN 
																							 UPDATE #Emp_Late SET Early_Deduct_Days = @Early_Deduction_Days 
																							 WHERE For_Date = @cur_For_date AND Emp_ID = @cur_Emp_ID AND Cmp_ID = @Cmp_ID
																						END
																					ELSE
																						BEGIN
																							SET @Temp_Extra_Count = @Temp_Extra_Count + 1
																							UPDATE #Emp_Late SET Extra_Exempted = 1 , Extra_Exempted_Sec = (@Shift_Time_Sec - @Working_Time_Sec)
																							WHERE For_Date = @cur_For_date AND Emp_ID = @cur_Emp_ID AND Cmp_ID = @Cmp_ID		
																						END	 	
																				end
																	end
																else
																	begin
																		IF @Extra_Exemption = 0
																			BEGIN
																				UPDATE #Emp_Late SET Early_Deduct_Days = @Early_Deduction_Days 
																				WHERE For_Date = @cur_For_date AND Emp_ID = @cur_Emp_ID AND Cmp_ID = @Cmp_ID		
																			END
																		ELSE
																			BEGIN
																				SET @Temp_Extra_Count = @Temp_Extra_Count + 1
																				UPDATE #Emp_Late SET Extra_Exempted = 1 , Extra_Exempted_Sec = (@Shift_Time_Sec - @Working_Time_Sec)
																				WHERE For_Date = @cur_For_date AND Emp_ID = @cur_Emp_ID AND Cmp_ID = @Cmp_ID		
																			END	
																	END

															end
													  --end
												end
											else
												begin 	
											
																if  dbo.F_Return_Sec(@Early_Exemption_Limit) = 0  or @cur_Out_Time >=  @Max_Exemption_Early_Limit_datetime -- Changed by Gadriwala Muslim 2262015 -- dateadd(s,dbo.F_Return_Sec(@Early_Exemption_Limit) * -1,@Cur_Shift_End_Time)
																	begin 
																		
																		set @Early_Exempted_Count = @Early_Exempted_Count + 1
																		
																		If @Early_Adj_Day > 0 
																			begin
																				If @Early_Count_Exemption < @Early_Exempted_Count 
																				begin
																					
																					set @Total_Early_Adjust_days = @Total_Early_Adjust_days + 1	
																					if @Early_Adj_Day <= @Total_Early_Adjust_days
																					  begin		
																							
																							set @Total_Early_Adjust_days = 0		
																							IF @Extra_Exemption = 0
																								BEGIN 
																									UPDATE #Emp_Late SET Early_Deduct_Days = @Early_Deduction_Days
																									WHERE For_Date = @cur_For_date AND Emp_ID = @cur_Emp_ID 
																									AND Cmp_ID = @Cmp_ID
																								END
																							ELSE
																								BEGIN
																									SET @Temp_Extra_Count = @Temp_Extra_Count + 1
																									UPDATE #Emp_Late SET Extra_Exempted = 1 , Extra_Exempted_Sec = (@Shift_Time_Sec - @Working_Time_Sec)
																									WHERE For_Date = @cur_For_date AND Emp_ID = @cur_Emp_ID AND Cmp_ID = @Cmp_ID		
																								END
																								
																					  end
																				end
																			end
																		else
																			begin
																	
																			If @Early_Count_Exemption <= @Early_Exempted_Count 
																			begin
																				IF @Extra_Exemption = 0 
																					BEGIN
																						UPDATE #Emp_Late SET Early_Deduct_Days = @Early_Deduction_Days
																						 WHERE For_Date = @cur_For_date AND Emp_ID = @cur_Emp_ID 
																						 AND Cmp_ID = @Cmp_ID	
																					END
																				ELSE
																					BEGIN
																						SET @Temp_Extra_Count = @Temp_Extra_Count + 1
																						UPDATE #Emp_Late SET Extra_Exempted = 1 , Extra_Exempted_Sec = (@Shift_Time_Sec - @Working_Time_Sec)
																						WHERE For_Date = @cur_For_date AND Emp_ID = @cur_Emp_ID AND Cmp_ID = @Cmp_ID		
																					END
																			end
																	end
																	end
																else
																	begin 
																		If @Early_Adj_Day > 0 
																			begin
																				set @Total_Early_Adjust_days = @Total_Early_Adjust_days + 1
																				if @Total_Early_Adjust_days >= @Early_Adj_Day
																					begin
																						  set @Total_Early_Adjust_days = 0
																						  IF @Extra_Exemption = 0
																								BEGIN
																									UPDATE #Emp_Late SET Early_Deduct_Days = @Early_Deduction_Days 
																									WHERE For_Date = @cur_For_date AND Emp_ID = @cur_Emp_ID AND Cmp_ID = @Cmp_ID
																								END
																						   ELSE
																								BEGIN
																									SET @Temp_Extra_Count = @Temp_Extra_Count + 1
																									UPDATE #Emp_Late SET Extra_Exempted = 1 , Extra_Exempted_Sec = (@Shift_Time_Sec - @Working_Time_Sec)
																									WHERE For_Date = @cur_For_date AND Emp_ID = @cur_Emp_ID AND Cmp_ID = @Cmp_ID		
																								END
																					end
																			end
																		else
																			begin
																				IF @Extra_Exemption = 0
																					BEGIN
																						UPDATE #Emp_Late SET Early_Deduct_Days = @Early_Deduction_Days 
																						WHERE For_Date = @cur_For_date AND Emp_ID = @cur_Emp_ID AND Cmp_ID = @Cmp_ID
																					END
																				ELSE
																					BEGIN
																						SET @Temp_Extra_Count = @Temp_Extra_Count + 1
																						UPDATE #Emp_Late SET Extra_Exempted = 1 , Extra_Exempted_Sec = (@Shift_Time_Sec - @Working_Time_Sec)
																						WHERE For_Date = @cur_For_date AND Emp_ID = @cur_Emp_ID AND Cmp_ID = @Cmp_ID		
																					END
																			end
																	end
												end
												
								end	
							
							set @Previous_Emp_ID = @cur_Emp_ID
							set @previous_Branch_ID = @cur_Branch_ID		
					
					Fetch Next From curdeduction into @cur_Emp_ID,@cur_Branch_ID,@cur_For_date,@cur_Late_Hour,@cur_Early_Hour,@cur_Late_Seconds,@cur_Early_Seconds,@Working_Time_sec,@Shift_Time_Sec,@Cur_In_Time,@Cur_Out_Time,@Cur_Shift_st_Time,@cur_Shift_End_Time,@Cur_Late_Limit_Sec,@Cur_Early_Limit_Sec,@Shift_ID
				End
		close curdeduction
		deallocate curdeduction		
		
		
		Select * Into #Emp_Late_Scenario From #Emp_Late
		Select * Into #Data_Scenario From #DATA_LATE
				
		Truncate table #Emp_Late_Scenario
		Truncate table #Data_Scenario
		
		
		if @Format_Type = 'Late' OR @Format_Type = 'All'  -- Added By Nilesh Patel on 01062016
			Begin
				
				if Exists(SELECT 1 From #Emp_Cons_Scenario)
				 BEGIN 
						
						
						DECLARE @Emp_Constraint Varchar(Max)
						Set @Emp_Constraint = NULL
						
						Select @Emp_Constraint = COALESCE(@Emp_Constraint+'#','') + Cast(Emp_ID AS varchar(100)) From #Emp_Cons_Scenario
						
						Exec rpt_Late_Early_Mark_Scenario @Cmp_ID,@From_Date,@To_Date,@Emp_Constraint
												
						
				 END
			End

		IF @HasLateTable = 1
			RETURN 
		
		--select * from #Emp_Late_Scenario

		-- Multi Punch
		Update E2
		set E2.Out_Time = a.OutTime
		from #Emp_Late_Scenario E2 inner join (
		select E1.emp_Id,E1.For_Date,Min(E1.In_Time) as Intime ,case when MAX(E1.IN_TIME) > MAX(isnull(E1.Out_Time,0)) then  MAX(E1.IN_TIME) else MAX(isnull(E1.Out_Time,0)) END  as OutTime
		--,Count(E1.For_Date)
		from #Emp_Late_Scenario E inner join T0150_EMP_INOUT_RECORD E1 on e.Emp_ID = e1.Emp_ID and E.For_Date = e1.For_Date
		Group by E1.For_Date,E1.emp_Id
		Having  Count(E1.For_Date) > 1
		) a on E2.Emp_ID = a.Emp_ID and E2.For_Date = a.For_Date
		-- Multi Punch
		
		delete d from #Emp_Late_Scenario d inner join  (
				select d.For_date , d.emp_id from #DATA D 
				inner join  T0140_LEAVE_TRANSACTION L 
				on d.EMP_ID = L.Emp_ID and d.for_date = l.For_Date
				inner join T0040_LEAVE_MASTER LM on L.Leave_Id = LM.LEave_Id
				where Leave_Used > 0 and LM.Leave_Type <> 'Company Purpose'
		) as a on a.emp_id = d.emp_id and d.for_date = a.for_date

		

		--select E1.emp_Id,E1.For_Date,Min(E1.In_Time) as Intime ,case when MAX(E1.IN_TIME) > MAX(isnull(E1.Out_Time,0)) then  MAX(E1.IN_TIME) else MAX(isnull(E1.Out_Time,0)) END  as OutTime
		----,Count(E1.For_Date)
		--from #Emp_Late_Scenario E inner join T0150_EMP_INOUT_RECORD E1 on e.Emp_ID = e1.Emp_ID and E.For_Date = e1.For_Date
		--Group by E1.For_Date,E1.emp_Id
		--Having  Count(E1.For_Date) > 1
		--select * from #Emp_Late_Scenario

		if exists( select 1 from #Emp_Late_Scenario where cast(out_time as time) < cast(Shift_end_time as time))
		BEGIN
			--delete from #Emp_Late_Scenario where cast(out_time as time) < cast(Shift_end_time as time) --Deepal Last change in 02072024
			delete from #Emp_Late_Scenario where cast(out_time as DATETime) < cast(Shift_end_time as DATETime)
		END
		--select * from #Emp_Late_Scenario

	-- Deepal - 30-04-2024

	

	 --Select * From  Tempdb.Sys.Columns Where Object_ID = Object_ID('tempdb..#TempTable')
	 IF NOT EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'IsLeaveflag'
          AND Object_ID = Object_ID('tempdb..#TempTable'))
	BEGIN
		Alter Table #Emp_Late_Scenario Add IsLeaveflag bit
	END
	
	
	UPDATE EL set
	EL.IsLeaveflag = 1
	FROM #Emp_Late_Scenario EL
	inner join (
		Select distinct E.For_date, E.EMP_ID
		from #Emp_Late_Scenario E
		inner join T0140_LEAVE_TRANSACTION L on E.EMP_ID = L.Emp_ID and E.for_date = l.For_Date and Leave_Used > 0
		inner join T0040_LEAVE_MASTER LM on L.Leave_Id = LM.LEave_Id and LM.Leave_Type = 'Company Purpose'
	) a on EL.Emp_ID  = A.Emp_ID and El.For_Date = A.For_Date

	-- Deepal Add the condition with OD is of Full day and late and not to calculate on 120 logic 03-07-24
	Delete E from #Emp_Late_Scenario E
		inner join T0140_LEAVE_TRANSACTION L on E.EMP_ID = L.Emp_ID and E.for_date = l.For_Date and Leave_Used = 1
		inner join T0040_LEAVE_MASTER LM on L.Leave_Id = LM.LEave_Id and LM.Leave_Type = 'Company Purpose'

	Delete E from #Emp_Late_Scenario E
	--select E.* from #Emp_Late_Scenario E
		inner join T0140_LEAVE_TRANSACTION L on E.EMP_ID = L.Emp_ID and E.for_date = l.For_Date and CompOff_Used > 0
		inner join T0040_LEAVE_MASTER LM on L.Leave_Id = LM.LEave_Id and LM.Leave_code = 'Comp'
	-- Deepal Add the condition with OD is of Full day and late and not to calculate on 120 logic 03-07-24
	
	--select * from #EMP_LATE_SCENARIO where for_date = '2024-07-04'

	if @MonthExemptLimitInSec > 0 and @LateEarly_MonthWise = 1 and @IsDeficit = 0
	BEGIN
		SELECT  ROW_NUMBER() OVER(PARTITION BY Emp_Id Order by Shift_Max_St_Time) AS RowNo
		,@MonthExemptLimitInSec as MonthExemptLimitInSec,* 
		INTO #TEMPDATA 
		FROM #Emp_Late_Scenario
		order by For_Date

		--Select E.For_Date,E.Emp_ID,E.Shift_ID,s.Calculate_Days 
		--from #EMP_LATE_SCENARIO E 
		--inner join T0050_Shift_Detail S on E.Shift_Id = S.Shift_ID and E.Actualtime BETWEEN dbo.F_Return_Sec(Replace(S.From_Hour,'.',':'))  and dbo.F_Return_Sec(Replace(S.To_Hour,'.',':'))
		--inner join #TEMPDATA T on T.For_Date = e.For_Date and T.Emp_ID = e.Emp_ID --and T.RowNo = @Counter

		Declare @EmpCount as int = 0
		select @EmpCount = count(1) from #EMP_Cons
		DECLARE @EmpCounter INT = 1
		Declare @EmpMonthExemptLimitInSec as numeric(9,0)  = 0
		WHILE (@EmpCounter <= @EmpCount)
		BEGIN
					Declare @EmpId as numeric(10,0) = 0
					select @EmpId = a.Emp_ID from (
						Select ROW_NUMBER() Over (order by EMP_Id) Rn,EMP_Id from #Emp_Cons
					) a where Rn= @EmpCounter
					
					SET @EmpMonthExemptLimitInSec = @MonthExemptLimitInSec

					Declare @rowCount As Int = 0
					select @rowCount = count(1) from #TEMPDATA where Emp_ID = @EmpId
					Declare @LateMinuteSec as numeric(18,0) = 0
					Declare @ActualLateLimit as numeric(18,0) = 0
					Declare @ForDate as DATE
					DECLARE @Counter INT = 1
					WHILE (@Counter <= @rowCount)
					BEGIN
						select @ActualLateLimit = Late_Sec ,@ForDate = For_Date
						from #TEMPDATA where RowNo = @Counter and Emp_ID = @EmpId
						
						if @ActualLateLimit > 0
						BEGIN	
								
								--select @ForDate,@ActualLateLimit,(@EmpMonthExemptLimitInSec- @ActualLateLimit), dbo.F_Return_Hours(@ActualLateLimit), dbo.F_Return_Hours(@EmpMonthExemptLimitInSec), dbo.F_Return_Hours(@ActualLateLimit)
								if ((@EmpMonthExemptLimitInSec- @ActualLateLimit) < 0) 
								BEGIN	
								
											--delete E1
											--from #EMP_LATE_SCENARIO E1 
											--inner join (
											--	Select E.For_Date,E.Emp_ID,E.Shift_ID,s.Calculate_Days 
											--	from #EMP_LATE_SCENARIO E 
											--	inner join T0050_Shift_Detail S on E.Shift_Id = S.Shift_ID and E.Actualtime BETWEEN dbo.F_Return_Sec(Replace(S.From_Hour,'.',':'))  and dbo.F_Return_Sec(Replace(S.To_Hour,'.',':'))
											--	inner join #TEMPDATA T on T.For_Date = e.For_Date and T.Emp_ID = e.Emp_ID and T.RowNo = @Counter
											--)  E2 on e1.For_date = E2.For_date and E1.Emp_ID = E2.Emp_ID
											--where E2.Calculate_Days = 0.5 
											
												--Select E.For_Date,E.Emp_ID,E.Shift_ID,s.Calculate_Days 
												--from #EMP_LATE_SCENARIO E 
												--inner join T0050_Shift_Detail S on E.Shift_Id = S.Shift_ID and E.Actualtime BETWEEN dbo.F_Return_Sec(Replace(S.From_Hour,'.',':'))  and dbo.F_Return_Sec(Replace(S.To_Hour,'.',':'))
												--inner join #TEMPDATA T on T.For_Date = e.For_Date and T.Emp_ID = e.Emp_ID and T.RowNo = @Counter
												--where isnull(E.IsLeaveflag,0) = 0 and S.Cmp_ID = @Cmp_ID
											delete E1
											from #EMP_LATE_SCENARIO E1 
											inner join (
												Select E.For_Date,E.Emp_ID,E.Shift_ID,s.Calculate_Days 
												from #EMP_LATE_SCENARIO E 
												inner join T0050_Shift_Detail S on E.Shift_Id = S.Shift_ID and E.Actualtime BETWEEN dbo.F_Return_Sec(Replace(S.From_Hour,'.',':'))  and dbo.F_Return_Sec(Replace(S.To_Hour,'.',':'))
												inner join #TEMPDATA T on T.For_Date = e.For_Date and T.Emp_ID = e.Emp_ID and T.RowNo = @Counter
												where isnull(E.IsLeaveflag,0) = 0 and S.Cmp_ID = @Cmp_ID
											)  E2 on e1.For_date = E2.For_date and E1.Emp_ID = E2.Emp_ID
											where E2.Calculate_Days = 0.5 
											

											update #TEMPDATA set Late_Deduct_Days = 0.5 where RowNo = @Counter  and Emp_ID = @EmpId
								END
								if ((@EmpMonthExemptLimitInSec- @ActualLateLimit) >= 0) 
								BEGIN	
									
									update #TEMPDATA set Late_Deduct_Days = 0 where RowNo = @Counter  and Emp_ID = @EmpId
								END
						END
						IF ((@EmpMonthExemptLimitInSec- @ActualLateLimit) >= 0) --and @ActualLateLimit <= 7200
						BEGIN	
							 SET @EmpMonthExemptLimitInSec = @EmpMonthExemptLimitInSec - @ActualLateLimit
						END
						SET @Counter  = @Counter  + 1
					END -- While @Counter

					set @EmpCounter = @EmpCounter + 1
		END -- While @EmpCounter
		
	
	
	
		--SS
		Update d SET d.Late_Deduct_Days = t.Late_Deduct_Days
		FROM #Emp_Late_Scenario d 
		INNER JOIN #TEMPDATA T 
		ON d.For_date = t.For_date and D.Emp_Id = T.Emp_Id
		
		--select lt.*,el.Late_Deduct_Days
		--from #Emp_Late_Scenario EL
		--inner join T0140_Leave_Transaction LT on LT.Emp_ID = EL.EMP_ID and LT.For_Date = EL.For_Date
		--where LT.Leave_Used>0
		
		
		-- Added By Sajid 06-05-2024
		Update #Emp_Late_Scenario  set 
			Late_Deduct_Days = 0
			from #Emp_Late_Scenario EL
		inner join T0140_Leave_Transaction LT on LT.Emp_ID = EL.EMP_ID and LT.For_Date = EL.For_Date
		where LT.Leave_Used=1

		--Update #Emp_Late_Scenario  set 
		--	Late_Deduct_Days = 0
		--	from #Emp_Late_Scenario EL
		--inner join T0140_Leave_Transaction LT on LT.Emp_ID = EL.EMP_ID and LT.For_Date = EL.For_Date
		--where LT.Leave_Used=1
					
		--Update #Emp_Late_Scenario  set 
		--	Late_Deduct_Days = 0
		--from #Emp_Late_Scenario EL
		--inner join (
		--			select la.Leave_Approval_ID,la.Emp_ID,lad.To_Date,LT.For_Date from T0120_LEAVE_APPROVAL la 
		--			inner join T0130_LEAVE_APPROVAL_DETAIL lad on la.Leave_Approval_ID = lad.Leave_Approval_ID
		--			inner join T0140_Leave_Transaction LT on LT.Emp_ID = LA.EMP_ID AND LT.Leave_ID = LAD.Leave_ID
		--			where Leave_Assign_As = 'Full Day' and Approval_Status = 'A' and LT.Leave_Used>0
		--			) Qry 
		--			on Qry.Emp_ID = el.Emp_ID and Qry.For_Date = el.For_Date

		
		--Select * From #Emp_Late_Scenario

		delete E from #Emp_Late_Scenario E inner join (
		select d.P_days,e.Late_Deduct_Days,d.For_date,e.Emp_ID
		from #Emp_Late_Scenario E 
		inner join #Data_LATE D on E.Emp_ID = D.Emp_Id and e.For_Date = D.For_date and P_days = Late_Deduct_Days
		where Late_Deduct_Days > 0 and P_days = 0
		) a on E.Emp_id = a.Emp_id and E.For_Date = A.For_date

		-- Deepal 22-05-2024 Update the late days to 0 then delete from #Emp_Late_Scenario
		Update  #Emp_Late_Scenario set Late_Deduct_Days = 0  where Late_Sec > 7200
		delete from #Emp_Late_Scenario where Late_Sec > 7200

		--END Deepal 22-05-2024 Update the late days to 0 then delete from #Emp_Late_Scenario
			
	END
	-- Deepal - 30-04-2024
	--select * from #Emp_Late

	-- Deepal - Early and LATE
	 --select @IsDeficit,@MonthExemptLimitInSec,@LateEarly_MonthWise
	if @Format_Type = 'Early'
	BEGIN
		Select 1,* from #Emp_Late where is_late = 1 OR is_Early = 1
	END

		if @Format_Type = 'Late'
			begin
				If @Report_Type = 0
						begin
						
						If @used_table = 1 
							begin
								Insert into #Late_Early_Deduction
									select	 
										 el.Emp_ID,
										 el.for_date,
										 el.Late_Deduct_Days,
										 el.Early_Deduct_Days
										 , 0 as Deduct_days -- Deepal For Vega 17112024
									from #Emp_Late el inner join T0095_Increment i WITH (NOLOCK)  on el.increment_ID=i.Increment_ID  
									inner join T0080_EMP_MASTER em  WITH (NOLOCK) on  el.emp_id = em.emp_id  
									inner join T0030_BRANCH_MASTER bm WITH (NOLOCK)  on em.branch_id=bm.branch_id  
									inner join t0010_company_master cm WITH (NOLOCK)  on em.cmp_id = cm.cmp_id    
									Where (Late_sec > 0  and Is_Late = 1) or (el.Early_Sec>0 and el.Is_Early=1) --Commented Early by Hardik 19/06/2017 As Attendance Register is showing Early Out as * but Early policy is not applicable for Aculife
									--ORDER BY RIGHT(REPLICATE(N' ', 500) + em.Alpha_Emp_Code, 500),El.For_Date
									UNION ALL
									
									select	
										 el.Emp_ID,
										 el.for_date,
										 el.Late_Deduct_Days,
										 el.Early_Deduct_Days
										 , 0 as Deduct_days -- Deepal For Vega 17112024
									from #Emp_Late_Scenario el inner join T0095_Increment i WITH (NOLOCK)  on el.increment_ID=i.Increment_ID  
									inner join T0080_EMP_MASTER em WITH (NOLOCK)  on  el.emp_id = em.emp_id  
									inner join T0030_BRANCH_MASTER bm  WITH (NOLOCK) on em.branch_id=bm.branch_id  
									inner join t0010_company_master cm WITH (NOLOCK)  on em.cmp_id = cm.cmp_id    
									Where (Late_sec > 0  and Is_Late = 1) or (el.Early_Sec>0 and el.Is_Early=1) --Commented Early by Hardik 19/06/2017 As Attendance Register is showing Early Out as * but Early policy is not applicable for Aculife
									--ORDER BY RIGHT(REPLICATE(N' ', 500) + em.Alpha_Emp_Code, 500),El.For_Date
								
							end
						else

							begin
														
						----need to check for late count
						print'11111'
						--select * from #Emp_Late
						--select * from #Emp_Late_Scenario
						
				select	@From_Date as From_date,
									@To_Date as To_date,
									el.Emp_ID,
									el.Branch_Id,
									el.Cmp_ID, 
									convert(varchar(10),el.For_Date ,103) as For_Date,
									dateadd(s,el.Late_Limit_Sec*-1 ,el.SHIFT_TIME) as Shift_Start_Time,
									dateadd(s,el.Early_Limit_Sec,el.SHIFT_end_time) as Shift_End_Time,
									el.In_Time ,
								el.Late_Sec,
								el.Late_Limit_Sec,
								el.Late_Hour ,
								el.Late_Limit,
								el.Out_Time,
								dbo.F_Return_Hours(isnull(el.Late_Limit_Sec,0)) as Late_Limit_Hour , 
								CASE WHEN dbo.F_Return_Hours(dbo.Pro_Rounding_Sec_HH_MM(el.Late_Sec + el.Late_Limit_Sec,@RoundingValue))='00:00' THEN 
										'-' 
								ELSE 
										dbo.F_Return_Hours(dbo.Pro_Rounding_Sec_HH_MM(el.Late_Sec + el.Late_Limit_Sec,@RoundingValue)) 
								end as Late_Hour_Rounding,
								el.Early_Sec ,
								el.Early_Limit_Sec,
								el.Early_Hour ,
								el.Early_Limit 
								,dbo.F_Return_Hours(isnull(el.Early_Limit_Sec,0)) as Early_Limit_Hour  
								,CASE WHEN dbo.F_Return_Hours(dbo.Pro_Rounding_Sec_HH_MM(el.Early_Sec + el.Early_Limit_Sec ,@RoundingValue_Early))='00:00' THEN 
										'-' 
								ELSE 
										dbo.F_Return_Hours(dbo.Pro_Rounding_Sec_HH_MM(el.Early_Sec + el.Early_Limit_Sec ,@RoundingValue_Early)) 
								END as Early_Hour_Rounding
								,el.Late_Deduct_Days,el.Early_Deduct_Days,el.is_Maximum_late,
								Emp_full_name,emp_code,alpha_Emp_code,Emp_First_Name,branch_name,comp_name,
								branch_address,cmp_name,cmp_address
								,dsm.Desig_Name,dm.Dept_Name,tm.Type_Name,GM.Grd_Name          --added jimit 04092015
								,Dm.Dept_Dis_no      --added jimit 04092015
								,DSM.Desig_Dis_No --added by nilesh patel on 01042016 
								,vs.Vertical_Name,sv.SubVertical_Name,el.Late_Mark_Scenario,0 as Is_Late_Mark_Percentage  --added jimit 28042016								
							from #Emp_Late el inner join T0095_Increment i WITH (NOLOCK)  on el.increment_ID=i.Increment_ID  
							inner join T0080_EMP_MASTER em WITH (NOLOCK)  on  el.emp_id = em.emp_id  
							inner join T0030_BRANCH_MASTER bm WITH (NOLOCK)  on em.branch_id=bm.branch_id  
							inner join t0010_company_master cm WITH (NOLOCK)  on em.cmp_id = cm.cmp_id 
							left join t0040_designation_master DSM  WITH (NOLOCK) on i.Desig_id = DSM.Desig_id    --added jimit 04092015
							left join T0040_department_master DM WITH (NOLOCK)  on i.Dept_id = DM.Dept_id           --added jimit 04092015
							left join T0040_TYPE_MASTER TM WITH (NOLOCK)  on i.Type_ID = TM.Type_ID      --added jimit 04092015
							left join T0040_GRADE_MASTER GM  WITH (NOLOCK) on i.Grd_ID = GM.Grd_ID    --added jimit 04092015
							LEFT JOIN T0040_Vertical_Segment vs WITH (NOLOCK)  on vs.Vertical_ID = i.Vertical_ID   --added jimit 28042016
							LEFT JOIN T0050_SubVertical sv  WITH (NOLOCK) on sv.SubVertical_ID = i.SubVertical_ID   --added jimit 28042016
							Where Late_sec > 0  and Is_Late = 1 
							--ORDER BY RIGHT(REPLICATE(N' ', 500) + em.Alpha_Emp_Code, 500),El.For_Date
							
							UNION ALL
							
							select	@From_Date as From_date,
									@To_Date as To_date,
									el.Emp_ID,
									el.Branch_Id,
									el.Cmp_ID, 
									convert(varchar(10),el.For_Date ,103) as For_Date,
									dateadd(s,el.Late_Limit_Sec*-1 ,el.SHIFT_TIME) as Shift_Start_Time,
									dateadd(s,el.Early_Limit_Sec,el.SHIFT_end_time) as Shift_End_Time,
									el.In_Time ,
								el.Late_Sec,
								el.Late_Limit_Sec,
								el.Late_Hour ,
								el.Late_Limit,
								el.Out_Time,
								dbo.F_Return_Hours(isnull(el.Late_Limit_Sec,0)) as Late_Limit_Hour , 
								CASE WHEN dbo.F_Return_Hours(dbo.Pro_Rounding_Sec_HH_MM(el.Late_Sec + el.Late_Limit_Sec,@RoundingValue))='00:00' THEN 
										'-' 
								ELSE 
										dbo.F_Return_Hours(dbo.Pro_Rounding_Sec_HH_MM(el.Late_Sec + el.Late_Limit_Sec,@RoundingValue)) 
								end as Late_Hour_Rounding,
								el.Early_Sec ,
								el.Early_Limit_Sec,
								el.Early_Hour ,
								el.Early_Limit 
								,dbo.F_Return_Hours(isnull(el.Early_Limit_Sec,0)) as Early_Limit_Hour  
								,CASE WHEN dbo.F_Return_Hours(dbo.Pro_Rounding_Sec_HH_MM(el.Early_Sec + el.Early_Limit_Sec ,@RoundingValue_Early))='00:00' THEN 
										'-' 
								ELSE 
										dbo.F_Return_Hours(dbo.Pro_Rounding_Sec_HH_MM(el.Early_Sec + el.Early_Limit_Sec ,@RoundingValue_Early)) 
								END as Early_Hour_Rounding
								,
								(Case When el.Late_Mark_Scenario = 2 and el.Is_Late_Mark_Percentage = 0 THEN el.Late_Deduct_Days Else 0 END) as Late_Deduct_Days,
								--el.Late_Deduct_Days,
								el.Early_Deduct_Days,el.is_Maximum_late,
								Emp_full_name,emp_code,alpha_Emp_code,Emp_First_Name,branch_name,comp_name,
								branch_address,cmp_name,cmp_address
								,dsm.Desig_Name,dm.Dept_Name,tm.Type_Name,GM.Grd_Name          --added jimit 04092015
								,Dm.Dept_Dis_no      --added jimit 04092015
								,DSM.Desig_Dis_No --added by nilesh patel on 01042016 
								,vs.Vertical_Name,sv.SubVertical_Name,el.Late_Mark_Scenario,Is_Late_Mark_Percentage  --added jimit 28042016								
							from #Emp_Late_Scenario el inner join T0095_Increment i WITH (NOLOCK)  on el.increment_ID=i.Increment_ID  
							inner join T0080_EMP_MASTER em WITH (NOLOCK)  on  el.emp_id = em.emp_id  
							inner join T0030_BRANCH_MASTER bm WITH (NOLOCK)  on em.branch_id=bm.branch_id  
							inner join t0010_company_master cm WITH (NOLOCK)  on em.cmp_id = cm.cmp_id 
							left join t0040_designation_master DSM WITH (NOLOCK)  on i.Desig_id = DSM.Desig_id    --added jimit 04092015
							left join T0040_department_master DM  WITH (NOLOCK) on i.Dept_id = DM.Dept_id           --added jimit 04092015
							left join T0040_TYPE_MASTER TM WITH (NOLOCK)  on i.Type_ID = TM.Type_ID      --added jimit 04092015
							left join T0040_GRADE_MASTER GM  WITH (NOLOCK) on i.Grd_ID = GM.Grd_ID    --added jimit 04092015
							LEFT JOIN T0040_Vertical_Segment vs WITH (NOLOCK)  on vs.Vertical_ID = i.Vertical_ID   --added jimit 28042016
							LEFT JOIN T0050_SubVertical sv  WITH (NOLOCK) on sv.SubVertical_ID = i.SubVertical_ID   --added jimit 28042016
							Where Late_sec > 0  and Is_Late = 1 
							--ORDER BY RIGHT(REPLICATE(N' ', 500) + em.Alpha_Emp_Code, 500),El.For_Date
							
							end
							
						end
					else if  @Report_Type = 1 -- Deduction Days Only
						begin
						
							
							select	@From_Date as From_date,
											@To_Date as To_date,
											el.Emp_ID,
											el.Branch_Id,
											el.Cmp_ID, 
											convert(varchar(10),el.For_Date ,103) as For_Date,
											dateadd(s,el.Late_Limit_Sec*-1 ,el.SHIFT_TIME) as Shift_Start_Time,
											dateadd(s,el.Early_Limit_Sec,el.SHIFT_end_time) as Shift_End_Time,
											el.In_Time ,
										el.Late_Sec,
										el.Late_Limit_Sec,
										el.Late_Hour ,
										el.Late_Limit,
										el.Out_Time,
										dbo.F_Return_Hours(isnull(el.Late_Limit_Sec,0)) as Late_Limit_Hour , 
										CASE WHEN dbo.F_Return_Hours(dbo.Pro_Rounding_Sec_HH_MM(el.Late_Sec + el.Late_Limit_Sec,@RoundingValue))='00:00' THEN 
												'-' 
										ELSE 
												dbo.F_Return_Hours(dbo.Pro_Rounding_Sec_HH_MM(el.Late_Sec + el.Late_Limit_Sec,@RoundingValue)) 
										end as Late_Hour_Rounding,
										el.Early_Sec ,
										el.Early_Limit_Sec,
										el.Early_Hour ,
										el.Early_Limit 
										,dbo.F_Return_Hours(isnull(el.Early_Limit_Sec,0)) as Early_Limit_Hour  
										,CASE WHEN dbo.F_Return_Hours(dbo.Pro_Rounding_Sec_HH_MM(el.Early_Sec + el.Early_Limit_Sec ,@RoundingValue_Early))='00:00' THEN 
												'-' 
										ELSE 
												dbo.F_Return_Hours(dbo.Pro_Rounding_Sec_HH_MM(el.Early_Sec + el.Early_Limit_Sec  ,@RoundingValue_Early)) 
										END as Early_Hour_Rounding
										,el.Late_Deduct_Days,el.Early_Deduct_Days,el.is_Maximum_late,
										Emp_full_name,emp_code,alpha_Emp_code,Emp_First_Name,branch_name,comp_name,
										branch_address,cmp_name,cmp_address
										,dsm.Desig_Name,dm.Dept_Name,tm.Type_Name,GM.Grd_Name          --added jimit 04092015
										,Dm.Dept_Dis_no      --added jimit 04092015
										,DSM.Desig_Dis_No --added by nilesh patel on 01042016 
										,vs.Vertical_Name,sv.SubVertical_Name  --added jimit 28042016
									from #Emp_Late el inner join T0095_Increment i WITH (NOLOCK)  on el.increment_ID=i.Increment_ID  
									inner join T0080_EMP_MASTER em WITH (NOLOCK)  on  el.emp_id = em.emp_id  
									inner join T0030_BRANCH_MASTER bm WITH (NOLOCK)  on em.branch_id=bm.branch_id  
									inner join t0010_company_master cm WITH (NOLOCK)  on em.cmp_id = cm.cmp_id
									left join t0040_designation_master DSM  WITH (NOLOCK) on i.Desig_id = DSM.Desig_id    --added jimit 04092015
									left join T0040_department_master DM WITH (NOLOCK)  on i.Dept_id = DM.Dept_id           --added jimit 04092015
									left join T0040_TYPE_MASTER TM  WITH (NOLOCK) on i.Type_ID = TM.Type_ID      --added jimit 04092015
									left join T0040_GRADE_MASTER GM WITH (NOLOCK)  on i.Grd_ID = GM.Grd_ID    --added jimit 04092015 
									LEFT JOIN T0040_Vertical_Segment vs WITH (NOLOCK)  on vs.Vertical_ID = i.Vertical_ID   --added jimit 28042016
									LEFT JOIN T0050_SubVertical sv WITH (NOLOCK)  on sv.SubVertical_ID = i.SubVertical_ID   --added jimit 28042016   
									Where Late_sec > 0  and Is_Late = 1  and Late_Deduct_Days > 0
									--ORDER BY RIGHT(REPLICATE(N' ', 500) + em.Alpha_Emp_Code, 500),El.For_Date
									UNION ALL
									
									select	@From_Date as From_date,
											@To_Date as To_date,
											el.Emp_ID,
											el.Branch_Id,
											el.Cmp_ID, 
											convert(varchar(10),el.For_Date ,103) as For_Date,
											dateadd(s,el.Late_Limit_Sec*-1 ,el.SHIFT_TIME) as Shift_Start_Time,
											dateadd(s,el.Early_Limit_Sec,el.SHIFT_end_time) as Shift_End_Time,
											el.In_Time ,
										el.Late_Sec,
										el.Late_Limit_Sec,
										el.Late_Hour ,
										el.Late_Limit,
										el.Out_Time,
										dbo.F_Return_Hours(isnull(el.Late_Limit_Sec,0)) as Late_Limit_Hour , 
										CASE WHEN dbo.F_Return_Hours(dbo.Pro_Rounding_Sec_HH_MM(el.Late_Sec + el.Late_Limit_Sec,@RoundingValue))='00:00' THEN 
												'-' 
										ELSE 
												dbo.F_Return_Hours(dbo.Pro_Rounding_Sec_HH_MM(el.Late_Sec + el.Late_Limit_Sec,@RoundingValue)) 
										end as Late_Hour_Rounding,
										el.Early_Sec ,
										el.Early_Limit_Sec,
										el.Early_Hour ,
										el.Early_Limit 
										,dbo.F_Return_Hours(isnull(el.Early_Limit_Sec,0)) as Early_Limit_Hour  
										,CASE WHEN dbo.F_Return_Hours(dbo.Pro_Rounding_Sec_HH_MM(el.Early_Sec + el.Early_Limit_Sec ,@RoundingValue_Early))='00:00' THEN 
												'-' 
										ELSE 
												dbo.F_Return_Hours(dbo.Pro_Rounding_Sec_HH_MM(el.Early_Sec + el.Early_Limit_Sec  ,@RoundingValue_Early)) 
										END as Early_Hour_Rounding
										,el.Late_Deduct_Days,el.Early_Deduct_Days,el.is_Maximum_late,
										Emp_full_name,emp_code,alpha_Emp_code,Emp_First_Name,branch_name,comp_name,
										branch_address,cmp_name,cmp_address
										,dsm.Desig_Name,dm.Dept_Name,tm.Type_Name,GM.Grd_Name          --added jimit 04092015
										,Dm.Dept_Dis_no      --added jimit 04092015
										,DSM.Desig_Dis_No --added by nilesh patel on 01042016 
										,vs.Vertical_Name,sv.SubVertical_Name  --added jimit 28042016
									from #Emp_Late_Scenario el inner join T0095_Increment i WITH (NOLOCK)  on el.increment_ID=i.Increment_ID  
									inner join T0080_EMP_MASTER em WITH (NOLOCK)  on  el.emp_id = em.emp_id  
									inner join T0030_BRANCH_MASTER bm WITH (NOLOCK)  on em.branch_id=bm.branch_id  
									inner join t0010_company_master cm WITH (NOLOCK)  on em.cmp_id = cm.cmp_id
									left join t0040_designation_master DSM WITH (NOLOCK)  on i.Desig_id = DSM.Desig_id    --added jimit 04092015
									left join T0040_department_master DM WITH (NOLOCK)  on i.Dept_id = DM.Dept_id           --added jimit 04092015
									left join T0040_TYPE_MASTER TM WITH (NOLOCK)  on i.Type_ID = TM.Type_ID      --added jimit 04092015
									left join T0040_GRADE_MASTER GM WITH (NOLOCK)  on i.Grd_ID = GM.Grd_ID    --added jimit 04092015 
									LEFT JOIN T0040_Vertical_Segment vs WITH (NOLOCK)  on vs.Vertical_ID = i.Vertical_ID   --added jimit 28042016
									LEFT JOIN T0050_SubVertical sv WITH (NOLOCK)  on sv.SubVertical_ID = i.SubVertical_ID   --added jimit 28042016   
									Where Late_sec > 0  and Is_Late = 1  and Late_Deduct_Days > 0
						end
					else if  @Report_Type = 3 -- LP2 Records
						begin
							select	@From_Date as From_date,
											@To_Date as To_date,
											el.Emp_ID,
											el.Branch_Id,
											el.Cmp_ID, 
											convert(varchar(10),el.For_Date ,103) as For_Date,
											dateadd(s,el.Late_Limit_Sec*-1 ,el.SHIFT_TIME) as Shift_Start_Time,
											dateadd(s,el.Early_Limit_Sec,el.SHIFT_end_time) as Shift_End_Time,
											el.In_Time ,
										el.Late_Sec,
										el.Late_Limit_Sec,
										el.Late_Hour ,
										el.Late_Limit,
										el.Out_Time,
										dbo.F_Return_Hours(isnull(el.Late_Limit_Sec,0)) as Late_Limit_Hour , 
										CASE WHEN dbo.F_Return_Hours(dbo.Pro_Rounding_Sec_HH_MM(el.Late_Sec + el.Late_Limit_Sec ,@RoundingValue))='00:00' THEN 
												'-' 
										ELSE 
												dbo.F_Return_Hours(dbo.Pro_Rounding_Sec_HH_MM(el.Late_Sec + el.Late_Limit_Sec,@RoundingValue)) 
										end as Late_Hour_Rounding,
										el.Early_Sec ,
										el.Early_Limit_Sec,
										el.Early_Hour ,
										el.Early_Limit 
										,dbo.F_Return_Hours(isnull(el.Early_Limit_Sec,0)) as Early_Limit_Hour  
										,CASE WHEN dbo.F_Return_Hours(dbo.Pro_Rounding_Sec_HH_MM(el.Early_Sec + el.Early_Limit_Sec ,@RoundingValue_Early))='00:00' THEN 
												'-' 
										ELSE 
												dbo.F_Return_Hours(dbo.Pro_Rounding_Sec_HH_MM(el.Early_Sec + el.Early_Limit_Sec ,@RoundingValue_Early)) 
										END as Early_Hour_Rounding
										,el.Late_Deduct_Days,el.Early_Deduct_Days,el.is_Maximum_late,
										Emp_full_name,emp_code,alpha_Emp_code,Emp_First_Name,branch_name,comp_name,
										branch_address,cmp_name,cmp_address
										,dsm.Desig_Name,dm.Dept_Name,tm.Type_Name,GM.Grd_Name          --added jimit 04092015
										,Dm.Dept_Dis_no      --added jimit 04092015
										,DSM.Desig_Dis_No --added by nilesh patel on 01042016 
										,vs.Vertical_Name,sv.SubVertical_Name  --added jimit 28042016
									from #Emp_Late el inner join T0095_Increment i WITH (NOLOCK)  on el.increment_ID=i.Increment_ID  
									inner join T0080_EMP_MASTER em  WITH (NOLOCK) on  el.emp_id = em.emp_id  
									inner join T0030_BRANCH_MASTER bm WITH (NOLOCK)  on em.branch_id=bm.branch_id  
									inner join t0010_company_master cm  WITH (NOLOCK) on em.cmp_id = cm.cmp_id  
									left join t0040_designation_master DSM  WITH (NOLOCK) on i.Desig_id = DSM.Desig_id    --added jimit 04092015
									left join T0040_department_master DM  WITH (NOLOCK) on i.Dept_id = DM.Dept_id           --added jimit 04092015
									left join T0040_TYPE_MASTER TM WITH (NOLOCK)  on i.Type_ID = TM.Type_ID      --added jimit 04092015
									left join T0040_GRADE_MASTER GM WITH (NOLOCK)  on i.Grd_ID = GM.Grd_ID    --added jimit 04092015   
									LEFT JOIN T0040_Vertical_Segment vs WITH (NOLOCK)  on vs.Vertical_ID = i.Vertical_ID   --added jimit 28042016
									LEFT JOIN T0050_SubVertical sv WITH (NOLOCK)  on sv.SubVertical_ID = i.SubVertical_ID   --added jimit 28042016
									Where Late_sec > 0  and Is_Late = 1  and Late_Deduct_Days > 0 and Is_Maximum_Late = 1
									--ORDER BY RIGHT(REPLICATE(N' ', 500) + em.Alpha_Emp_Code, 500),El.For_Date
									UNION ALL
									
									select	@From_Date as From_date,
											@To_Date as To_date,
											el.Emp_ID,
											el.Branch_Id,
											el.Cmp_ID, 
											convert(varchar(10),el.For_Date ,103) as For_Date,
											dateadd(s,el.Late_Limit_Sec*-1 ,el.SHIFT_TIME) as Shift_Start_Time,
											dateadd(s,el.Early_Limit_Sec,el.SHIFT_end_time) as Shift_End_Time,
											el.In_Time ,
										el.Late_Sec,
										el.Late_Limit_Sec,
										el.Late_Hour ,
										el.Late_Limit,
										el.Out_Time,
										dbo.F_Return_Hours(isnull(el.Late_Limit_Sec,0)) as Late_Limit_Hour , 
										CASE WHEN dbo.F_Return_Hours(dbo.Pro_Rounding_Sec_HH_MM(el.Late_Sec + el.Late_Limit_Sec ,@RoundingValue))='00:00' THEN 
												'-' 
										ELSE 
												dbo.F_Return_Hours(dbo.Pro_Rounding_Sec_HH_MM(el.Late_Sec + el.Late_Limit_Sec,@RoundingValue)) 
										end as Late_Hour_Rounding,
										el.Early_Sec ,
										el.Early_Limit_Sec,
										el.Early_Hour ,
										el.Early_Limit 
										,dbo.F_Return_Hours(isnull(el.Early_Limit_Sec,0)) as Early_Limit_Hour  
										,CASE WHEN dbo.F_Return_Hours(dbo.Pro_Rounding_Sec_HH_MM(el.Early_Sec + el.Early_Limit_Sec ,@RoundingValue_Early))='00:00' THEN 
												'-' 
										ELSE 
												dbo.F_Return_Hours(dbo.Pro_Rounding_Sec_HH_MM(el.Early_Sec + el.Early_Limit_Sec ,@RoundingValue_Early)) 
										END as Early_Hour_Rounding
										,el.Late_Deduct_Days,el.Early_Deduct_Days,el.is_Maximum_late,
										Emp_full_name,emp_code,alpha_Emp_code,Emp_First_Name,branch_name,comp_name,
										branch_address,cmp_name,cmp_address
										,dsm.Desig_Name,dm.Dept_Name,tm.Type_Name,GM.Grd_Name          --added jimit 04092015
										,Dm.Dept_Dis_no      --added jimit 04092015
										,DSM.Desig_Dis_No --added by nilesh patel on 01042016 
										,vs.Vertical_Name,sv.SubVertical_Name  --added jimit 28042016
									from #Emp_Late_Scenario el inner join T0095_Increment i WITH (NOLOCK)  on el.increment_ID=i.Increment_ID  
									inner join T0080_EMP_MASTER em WITH (NOLOCK)  on  el.emp_id = em.emp_id  
									inner join T0030_BRANCH_MASTER bm WITH (NOLOCK)  on em.branch_id=bm.branch_id  
									inner join t0010_company_master cm  WITH (NOLOCK) on em.cmp_id = cm.cmp_id  
									left join t0040_designation_master DSM WITH (NOLOCK)  on i.Desig_id = DSM.Desig_id    --added jimit 04092015
									left join T0040_department_master DM WITH (NOLOCK)  on i.Dept_id = DM.Dept_id           --added jimit 04092015
									left join T0040_TYPE_MASTER TM  WITH (NOLOCK) on i.Type_ID = TM.Type_ID      --added jimit 04092015
									left join T0040_GRADE_MASTER GM WITH (NOLOCK)  on i.Grd_ID = GM.Grd_ID    --added jimit 04092015   
									LEFT JOIN T0040_Vertical_Segment vs WITH (NOLOCK)  on vs.Vertical_ID = i.Vertical_ID   --added jimit 28042016
									LEFT JOIN T0050_SubVertical sv  WITH (NOLOCK) on sv.SubVertical_ID = i.SubVertical_ID   --added jimit 28042016
									Where Late_sec > 0  and Is_Late = 1  and Late_Deduct_Days > 0 and Is_Maximum_Late = 1
						end
					else if  @Report_Type = 2 -- LP1 Records
						begin
							select	@From_Date as From_date,
											@To_Date as To_date,
											el.Emp_ID,
											el.Branch_Id,
											el.Cmp_ID, 
											convert(varchar(10),el.For_Date ,103) as For_Date,
											dateadd(s,el.Late_Limit_Sec*-1 ,el.SHIFT_TIME) as Shift_Start_Time,
											dateadd(s,el.Early_Limit_Sec,el.SHIFT_end_time) as Shift_End_Time,
											el.In_Time ,
										el.Late_Sec,
										el.Late_Limit_Sec,
										el.Late_Hour ,
										el.Late_Limit,
										el.Out_Time,
										dbo.F_Return_Hours(isnull(el.Late_Limit_Sec,0)) as Late_Limit_Hour , 
										CASE WHEN dbo.F_Return_Hours(dbo.Pro_Rounding_Sec_HH_MM(el.Late_Sec + el.Late_Limit_Sec,@RoundingValue))='00:00' THEN 
												'-' 
										ELSE 
												dbo.F_Return_Hours(dbo.Pro_Rounding_Sec_HH_MM(el.Late_Sec + el.Late_Limit_Sec,@RoundingValue)) 
										end as Late_Hour_Rounding,
										el.Early_Sec ,
										el.Early_Limit_Sec,
										el.Early_Hour ,
										el.Early_Limit 
										,dbo.F_Return_Hours(isnull(el.Early_Limit_Sec,0)) as Early_Limit_Hour  
										,CASE WHEN dbo.F_Return_Hours(dbo.Pro_Rounding_Sec_HH_MM(el.Early_Sec + el.Early_Limit_Sec ,@RoundingValue_Early))='00:00' THEN 
												'-' 
										ELSE 
												dbo.F_Return_Hours(dbo.Pro_Rounding_Sec_HH_MM(el.Early_Sec + el.Early_Limit_Sec ,@RoundingValue_Early)) 
										END as Early_Hour_Rounding
										,el.Late_Deduct_Days,el.Early_Deduct_Days,el.is_Maximum_late,
										Emp_full_name,emp_code,alpha_Emp_code,Emp_First_Name,branch_name,comp_name,
										branch_address,cmp_name,cmp_address
										,dsm.Desig_Name,dm.Dept_Name,tm.Type_Name,GM.Grd_Name          --added jimit 04092015
										,Dm.Dept_Dis_no      --added jimit 04092015
										,DSM.Desig_Dis_No --added by nilesh patel on 01042016 
										,vs.Vertical_Name,sv.SubVertical_Name  --added jimit 28042016
									from #Emp_Late el inner join T0095_Increment i WITH (NOLOCK)  on el.increment_ID=i.Increment_ID  
									inner join T0080_EMP_MASTER em WITH (NOLOCK)  on  el.emp_id = em.emp_id  
									inner join T0030_BRANCH_MASTER bm WITH (NOLOCK)  on em.branch_id=bm.branch_id  
									inner join t0010_company_master cm WITH (NOLOCK)  on em.cmp_id = cm.cmp_id   
									left join t0040_designation_master DSM WITH (NOLOCK)  on i.Desig_id = DSM.Desig_id    --added jimit 04092015
									left join T0040_department_master DM WITH (NOLOCK)  on i.Dept_id = DM.Dept_id           --added jimit 04092015
									left join T0040_TYPE_MASTER TM WITH (NOLOCK)  on i.Type_ID = TM.Type_ID      --added jimit 04092015
									left join T0040_GRADE_MASTER GM WITH (NOLOCK)  on i.Grd_ID = GM.Grd_ID    --added jimit 04092015  
									LEFT JOIN T0040_Vertical_Segment vs  WITH (NOLOCK) on vs.Vertical_ID = i.Vertical_ID   --added jimit 28042016
									LEFT JOIN T0050_SubVertical sv  WITH (NOLOCK) on sv.SubVertical_ID = i.SubVertical_ID   --added jimit 28042016
									Where Late_sec > 0  and Is_Late = 1  and Late_Deduct_Days > 0 and Is_Maximum_Late = 0
									--ORDER BY RIGHT(REPLICATE(N' ', 500) + em.Alpha_Emp_Code, 500),El.For_Date
							UNION ALL
								select	@From_Date as From_date,
											@To_Date as To_date,
											el.Emp_ID,
											el.Branch_Id,
											el.Cmp_ID, 
											convert(varchar(10),el.For_Date ,103) as For_Date,
											dateadd(s,el.Late_Limit_Sec*-1 ,el.SHIFT_TIME) as Shift_Start_Time,
											dateadd(s,el.Early_Limit_Sec,el.SHIFT_end_time) as Shift_End_Time,
											el.In_Time ,
										el.Late_Sec,
										el.Late_Limit_Sec,
										el.Late_Hour ,
										el.Late_Limit,
										el.Out_Time,
										dbo.F_Return_Hours(isnull(el.Late_Limit_Sec,0)) as Late_Limit_Hour , 
										CASE WHEN dbo.F_Return_Hours(dbo.Pro_Rounding_Sec_HH_MM(el.Late_Sec + el.Late_Limit_Sec,@RoundingValue))='00:00' THEN 
												'-' 
										ELSE 
												dbo.F_Return_Hours(dbo.Pro_Rounding_Sec_HH_MM(el.Late_Sec + el.Late_Limit_Sec,@RoundingValue)) 
										end as Late_Hour_Rounding,
										el.Early_Sec ,
										el.Early_Limit_Sec,
										el.Early_Hour ,
										el.Early_Limit 
										,dbo.F_Return_Hours(isnull(el.Early_Limit_Sec,0)) as Early_Limit_Hour  
										,CASE WHEN dbo.F_Return_Hours(dbo.Pro_Rounding_Sec_HH_MM(el.Early_Sec + el.Early_Limit_Sec ,@RoundingValue_Early))='00:00' THEN 
												'-' 
										ELSE 
												dbo.F_Return_Hours(dbo.Pro_Rounding_Sec_HH_MM(el.Early_Sec + el.Early_Limit_Sec ,@RoundingValue_Early)) 
										END as Early_Hour_Rounding
										,el.Late_Deduct_Days,el.Early_Deduct_Days,el.is_Maximum_late,
										Emp_full_name,emp_code,alpha_Emp_code,Emp_First_Name,branch_name,comp_name,
										branch_address,cmp_name,cmp_address
										,dsm.Desig_Name,dm.Dept_Name,tm.Type_Name,GM.Grd_Name          --added jimit 04092015
										,Dm.Dept_Dis_no      --added jimit 04092015
										,DSM.Desig_Dis_No --added by nilesh patel on 01042016 
										,vs.Vertical_Name,sv.SubVertical_Name  --added jimit 28042016
									from #Emp_Late_Scenario el inner join T0095_Increment i WITH (NOLOCK)  on el.increment_ID=i.Increment_ID  
									inner join T0080_EMP_MASTER em WITH (NOLOCK)  on  el.emp_id = em.emp_id  
									inner join T0030_BRANCH_MASTER bm  WITH (NOLOCK) on em.branch_id=bm.branch_id  
									inner join t0010_company_master cm WITH (NOLOCK)  on em.cmp_id = cm.cmp_id   
									left join t0040_designation_master DSM  WITH (NOLOCK) on i.Desig_id = DSM.Desig_id    --added jimit 04092015
									left join T0040_department_master DM  WITH (NOLOCK) on i.Dept_id = DM.Dept_id           --added jimit 04092015
									left join T0040_TYPE_MASTER TM WITH (NOLOCK)  on i.Type_ID = TM.Type_ID      --added jimit 04092015
									left join T0040_GRADE_MASTER GM WITH (NOLOCK)  on i.Grd_ID = GM.Grd_ID    --added jimit 04092015  
									LEFT JOIN T0040_Vertical_Segment vs WITH (NOLOCK)  on vs.Vertical_ID = i.Vertical_ID   --added jimit 28042016
									LEFT JOIN T0050_SubVertical sv  WITH (NOLOCK) on sv.SubVertical_ID = i.SubVertical_ID   --added jimit 28042016
									Where Late_sec > 0  and Is_Late = 1  and Late_Deduct_Days > 0 and Is_Maximum_Late = 0
									--ORDER BY RIGHT(REPLICATE(N' ', 500) + em.Alpha_Emp_Code, 500),El.For_Date
						end
			end
		else if @Format_Type = 'Early' 
			BEGIN
				IF @Report_Type = 0 
					begin
							--select * from #Emp_Late
							
								select	@From_Date as From_date,
									@To_Date as To_date,
									el.Emp_ID,
									el.Branch_Id,
									el.Cmp_ID, 
									convert(varchar(10),el.For_Date ,103) as For_Date,
									dateadd(s,el.Late_Limit_Sec*-1 ,el.SHIFT_TIME) as Shift_Start_Time,
									dateadd(s,el.Early_Limit_Sec,el.SHIFT_end_time) as Shift_End_Time,
									el.In_Time ,
								el.Late_Sec,
								el.Late_Limit_Sec,
								el.Late_Hour ,
								el.Late_Limit,
								el.Out_Time,
								dbo.F_Return_Hours(isnull(el.Late_Limit_Sec,0)) as Late_Limit_Hour , 
								CASE WHEN dbo.F_Return_Hours(dbo.Pro_Rounding_Sec_HH_MM(el.Late_Sec + el.Late_Limit_Sec,@RoundingValue))='00:00' THEN 
										'-' 
								ELSE 
										dbo.F_Return_Hours(dbo.Pro_Rounding_Sec_HH_MM(el.Late_Sec + el.Late_Limit_Sec,@RoundingValue)) 
								end as Late_Hour_Rounding,
								el.Early_Sec ,
								el.Early_Limit_Sec,
								el.Early_Hour ,
								el.Early_Limit 
								,dbo.F_Return_Hours(isnull(el.Early_Limit_Sec,0)) as Early_Limit_Hour  
								,CASE WHEN dbo.F_Return_Hours(dbo.Pro_Rounding_Sec_HH_MM(el.Early_Sec + el.Early_Limit_Sec ,@RoundingValue_Early))='00:00' THEN 
										'-' 
								ELSE 
										dbo.F_Return_Hours(dbo.Pro_Rounding_Sec_HH_MM(el.Early_Sec  + el.Early_Limit_Sec ,@RoundingValue_Early)) 
								END as Early_Hour_Rounding
								,el.Late_Deduct_Days,el.Early_Deduct_Days,
								Emp_full_name,emp_code,alpha_Emp_code,Emp_First_Name,branch_name,comp_name,
								branch_address,cmp_name,cmp_address
								,dsm.Desig_Name,dm.Dept_Name,tm.Type_Name,GM.Grd_Name          --added jimit 04092015
								,Dm.Dept_Dis_no      --added jimit 04092015
								,DSM.Desig_Dis_No --added by nilesh patel on 01042016 
								,vs.Vertical_Name,sv.SubVertical_Name  --added jimit 28042016
							from #Emp_Late el inner join T0095_Increment i WITH (NOLOCK)  on el.increment_ID=i.Increment_ID  
							inner join T0080_EMP_MASTER em WITH (NOLOCK)  on  el.emp_id = em.emp_id  
							inner join T0030_BRANCH_MASTER bm WITH (NOLOCK)  on em.branch_id=bm.branch_id  
							inner join t0010_company_master cm WITH (NOLOCK) on em.cmp_id = cm.cmp_id    
							left join t0040_designation_master DSM WITH (NOLOCK) on i.Desig_id = DSM.Desig_id    --added jimit 04092015
							left join T0040_department_master DM WITH (NOLOCK) on i.Dept_id = DM.Dept_id           --added jimit 04092015
							left join T0040_TYPE_MASTER TM WITH (NOLOCK) on i.Type_ID = TM.Type_ID      --added jimit 04092015
							left join T0040_GRADE_MASTER GM WITH (NOLOCK) on i.Grd_ID = GM.Grd_ID    --added jimit 04092015 
							LEFT JOIN T0040_Vertical_Segment vs WITH (NOLOCK)  on vs.Vertical_ID = i.Vertical_ID   --added jimit 28042016
							LEFT JOIN T0050_SubVertical sv  WITH (NOLOCK) on sv.SubVertical_ID = i.SubVertical_ID   --added jimit 28042016
							Where Early_Sec > 0  and Is_Early = 1 
							ORDER BY RIGHT(REPLICATE(N' ', 500) + em.Alpha_Emp_Code, 500),El.For_Date
					end
				else
					begin
						
						select	@From_Date as From_date,
									@To_Date as To_date,
									el.Emp_ID,
									el.Branch_Id,
									el.Cmp_ID, 
									convert(varchar(10),el.For_Date ,103) as For_Date,
									dateadd(s,el.Late_Limit_Sec*-1 ,el.SHIFT_TIME) as Shift_Start_Time,
									dateadd(s,el.Early_Limit_Sec,el.SHIFT_end_time) as Shift_End_Time,
									el.In_Time ,
								el.Late_Sec,
								el.Late_Limit_Sec,
								el.Late_Hour ,
								el.Late_Limit,
								el.Out_Time,
								dbo.F_Return_Hours(isnull(el.Late_Limit_Sec,0)) as Late_Limit_Hour , 
								CASE WHEN dbo.F_Return_Hours(dbo.Pro_Rounding_Sec_HH_MM(el.Late_Sec  + el.Late_Limit_Sec,@RoundingValue))='00:00' THEN 
										'-' 
								ELSE 
										dbo.F_Return_Hours(dbo.Pro_Rounding_Sec_HH_MM(el.Late_Sec + el.Late_Limit_Sec,@RoundingValue)) 
								end as Late_Hour_Rounding,
								el.Early_Sec ,
								el.Early_Limit_Sec,
								el.Early_Hour ,
								el.Early_Limit 
								,dbo.F_Return_Hours(isnull(el.Early_Limit_Sec,0)) as Early_Limit_Hour  
								,CASE WHEN dbo.F_Return_Hours(dbo.Pro_Rounding_Sec_HH_MM(el.Early_Sec + el.Early_Limit_Sec ,@RoundingValue_Early))='00:00' THEN 
										'-' 
								ELSE 
										dbo.F_Return_Hours(dbo.Pro_Rounding_Sec_HH_MM(el.Early_Sec  + el.Early_Limit_Sec ,@RoundingValue_Early)) 
								END as Early_Hour_Rounding
								,el.Late_Deduct_Days,el.Early_Deduct_Days,
								Emp_full_name,emp_code,alpha_Emp_code,Emp_First_Name,branch_name,comp_name,
								branch_address,cmp_name,cmp_address
								,dsm.Desig_Name,dm.Dept_Name,tm.Type_Name,GM.Grd_Name          --added jimit 04092015
								,Dm.Dept_Dis_no      --added jimit 04092015
								,DSM.Desig_Dis_No --added by nilesh patel on 01042016 
								,vs.Vertical_Name,sv.SubVertical_Name  --added jimit 28042016
							from #Emp_Late el inner join T0095_Increment i WITH (NOLOCK)  on el.increment_ID=i.Increment_ID  
							inner join T0080_EMP_MASTER em WITH (NOLOCK)  on  el.emp_id = em.emp_id  
							inner join T0030_BRANCH_MASTER bm WITH (NOLOCK)  on em.branch_id=bm.branch_id  
							inner join t0010_company_master cm WITH (NOLOCK)  on em.cmp_id = cm.cmp_id    
							left join t0040_designation_master DSM WITH (NOLOCK)  on i.Desig_id = DSM.Desig_id    --added jimit 04092015
							left join T0040_department_master DM  WITH (NOLOCK) on i.Dept_id = DM.Dept_id           --added jimit 04092015
							left join T0040_TYPE_MASTER TM  WITH (NOLOCK) on i.Type_ID = TM.Type_ID      --added jimit 04092015
							left join T0040_GRADE_MASTER GM WITH (NOLOCK)  on i.Grd_ID = GM.Grd_ID    --added jimit 04092015 
							LEFT JOIN T0040_Vertical_Segment vs WITH (NOLOCK)  on vs.Vertical_ID = i.Vertical_ID   --added jimit 28042016
							LEFT JOIN T0050_SubVertical sv WITH (NOLOCK)  on sv.SubVertical_ID = i.SubVertical_ID   --added jimit 28042016
							Where Early_Sec > 0  and Is_Early = 1  and Early_Deduct_Days > 0
							ORDER BY RIGHT(REPLICATE(N' ', 500) + em.Alpha_Emp_Code, 500),El.For_Date
					end
				
			end
	else if @Format_Type = 'Extra-Exempted'
			begin
				If @used_table = 1 
							begin
							
								Insert into #Extra_Exempted
									select	
										 el.Emp_ID,
										 el.for_date,
										 el.Extra_Exempted_Sec,
										 el.Extra_Exempted
									from #Emp_Late el inner join T0095_Increment i WITH (NOLOCK)  on el.increment_ID=i.Increment_ID  
									inner join T0080_EMP_MASTER em WITH (NOLOCK)  on  el.emp_id = em.emp_id  
									inner join T0030_BRANCH_MASTER bm WITH (NOLOCK)  on em.branch_id=bm.branch_id  
									inner join t0010_company_master cm WITH (NOLOCK)  on em.cmp_id = cm.cmp_id    
									where Extra_Exempted = 1 AND el.Extra_Exempted_Sec > 0 --el.Extra_Exempted_Sec > 0  - Ankit 08092016
									ORDER BY RIGHT(REPLICATE(N' ', 500) + em.Alpha_Emp_Code, 500),El.For_Date
							end	
			end
					
END


