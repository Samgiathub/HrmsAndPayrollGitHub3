CREATE PROCEDURE [dbo].[SP_CALCULATE_PRESENT_DAYS]    
	 @Cmp_ID  numeric    
	,@From_Date datetime    
	,@To_Date  datetime   
	,@Branch_ID numeric    
	,@Cat_ID  numeric   
	,@Grd_ID  numeric    
	,@Type_ID  numeric    
	,@Dept_ID  numeric    
	,@Desig_ID  numeric    
	,@Emp_ID  numeric    
	,@constraint varchar(MAX)    
	,@Return_Record_set numeric = 1 
	,@StrWeekoff_Date varchar(Max)  =''
	,@Is_Split_Shift_Req tinyint = 0
	,@PBranch_ID	varchar(MAX)= '' 
	,@PVertical_ID	varchar(MAX)= '' 
	,@PSubVertical_ID	varchar(MAX)= '' 
	,@PDept_ID varchar(MAX)=''  
	,@Late_SP tinyint = 0 
	,@Call_For_Leave_Cancel numeric(18,2) = 0 
	,@Reload_InOut BIT = 1
	,@Report_For varchar(50) = null
	,@flag int = 0
AS    
	SET NOCOUNT ON	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON     
     


	Declare @Count numeric   
	Declare @Tmp_Date datetime   
	SET @Tmp_Date = @From_Date    
	
	
	DECLARE @For_OT_APPROVAL AS BIT =0
	--IF @Return_Record_set = 15
	--	begin
	--		SET @For_OT_APPROVAL=1
	--		set @Return_Record_set = 2
	--	end

	
	
	--return
	if @Return_Record_set = 1 or @Return_Record_set = 2 or @Return_Record_set =3  or @Return_Record_set = 5 or @Return_Record_set = 8 OR @Return_Record_set = 9 OR @Return_Record_set = 10 OR @Return_Record_set = 11 OR @Return_Record_set = 12 OR @Return_Record_set = 13 OR @Return_Record_set = 14  or  @Return_Record_set = 15 or @return_record_set = 16 --or @Return_Record_set = 7    
		Begin    
		
			CREATE TABLE #Data   
			(   
			 Emp_Id numeric ,   
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
			 IO_Tran_Id	 numeric default 0, -- io_tran_id is used for is_cmp_purpose (t0150_emp_inout)
			 OUT_Time datetime,
			 Shift_End_Time datetime,			--Ankit 16112013
			 OT_End_Time numeric default 0,	--Ankit 16112013
			 Working_Hrs_St_Time tinyint default 0, --Hardik 14/02/2014
			 Working_Hrs_End_Time tinyint default 0, --Hardik 14/02/2014
			 GatePass_Deduct_Days numeric(18,2) default 0 -- Add by Gadriwala Muslim 05012014
			 --,Working_sec_Between_Shift numeric(18) default 0 -- Commented by Niraj(20062022)
		 )  	 
	 
		END 
 
	CREATE table #Data_temp1
	(   
		Emp_Id numeric ,   
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
		IO_Tran_Id	 numeric default 0, -- io_tran_id is used for is_cmp_purpose (t0150_emp_inout)
		OUT_Time datetime,
		Shift_End_Time datetime,			--Ankit 16112013
		OT_End_Time numeric default 0,	--Ankit 16112013
		Working_Hrs_St_Time tinyint default 0, --Hardik 14/02/2014
		Working_Hrs_End_Time tinyint default 0, --Hardik 14/02/2014
		GatePass_Deduct_Days numeric(18,2) default 0 -- Add by Gadriwala Muslim 05012014
	   --,Working_sec_Between_Shift numeric(18) default 0 -- Commented by Niraj(20062022)
	)   
	CREATE CLUSTERED INDEX ix_Data_temp1_Emp_Id_For_date on #Data_temp1(Emp_Id,For_Date);
	
	If @Is_Split_Shift_Req =1 
		Begin
			CREATE TABLE #Split_Shift_Table
			(
			 Emp_Id Numeric,
			 Split_Shift_Count Numeric(18,0),
			 Split_Shift_Dates varchar(5000),
			 Split_Shift_Allow numeric(18,3)
			)
	
	End
	
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
    
	IF @PBranch_ID = '0' or @PBranch_ID='' --Added By Jaina 25-09-2015
		set @PBranch_ID = null 	
	
	if @PVertical_ID ='0' or @PVertical_ID = ''		--Added By Jaina 25-09-2015
		set @PVertical_ID = null

	if @PsubVertical_ID ='0' or @PsubVertical_ID = ''	--Added By Jaina 25-09-2015
		set @PsubVertical_ID = null
	
	IF @PDept_ID = '0' or @PDept_Id=''  --Added By Jaina 25-09-2015
		set @PDept_ID = NULL	 
		
	--Added By Jaina 25-09-2015 Start		
	if @PBranch_ID is null
		Begin	
			select @PBranch_ID = COALESCE(@PBranch_ID + ',', '') + cast(Branch_ID as nvarchar(5))  from T0030_BRANCH_MASTER  where Cmp_ID=@Cmp_ID 
			set @PBranch_ID = @PBranch_ID + ',0'
		End
	
	if @PVertical_ID is null
		Begin	
			select @PVertical_ID = COALESCE(@PVertical_ID + ',', '') + cast(Vertical_ID as nvarchar(5))  from T0040_Vertical_Segment  where Cmp_ID=@Cmp_ID 
			If @PVertical_ID IS NULL
				set @PVertical_ID = '0';
			else
				set @PVertical_ID = @PVertical_ID + ',0'		
		End
	if @PsubVertical_ID is null
		Begin	
			select @PsubVertical_ID = COALESCE(@PsubVertical_ID + ',', '') + cast(subVertical_ID as nvarchar(5))  from T0050_SubVertical  where Cmp_ID=@Cmp_ID 
			If @PsubVertical_ID IS NULL
				set @PsubVertical_ID = '0';
			else
				set @PsubVertical_ID = @PsubVertical_ID + ',0'
		End
	IF @PDept_ID is null
		Begin
			select @PDept_ID = COALESCE(@PDept_ID + ',', '') + cast(Dept_ID as nvarchar(5))  from T0040_DEPARTMENT_MASTER  where Cmp_ID=@Cmp_ID 		
			if @PDept_ID is null
				set @PDept_ID = '0';
			else
				set @PDept_ID = @PDept_ID + ',0'
		End
	--Added By Jaina 25-09-2015 End
	
	--This Section is Added By Ramiz on 05/03/2016, This will be used in OT Approval for Filtering Purpose 
	
	IF @Return_Record_set = 2
		BEGIN
			DECLARE @BRANCH_ID_FOR_OT Numeric(18,0)
			DECLARE @DEPT_ID_FOR_OT Numeric(18,0)
			DECLARE @GRD_ID_FOR_OT Numeric(18,0)
			
			SET @BRANCH_ID_FOR_OT = @Branch_id
			SET @DEPT_ID_FOR_OT = @Dept_ID
			SET @GRD_ID_FOR_OT = @Grd_ID
		END
	--Ended By Ramiz on 05/03/2016
	--Added by Sumit as per nimesh bhai's guideline on 29122016
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
		
	 --IF OBJECT_ID('tempdb..#Emp_Cons') IS NULL
	 if (@HasConsTable = 0)
		BEGIN
			CREATE TABLE #Emp_Cons 
			(  
				Emp_ID numeric ,   
				Branch_ID numeric,
				Increment_ID numeric  
			);
			CREATE NONCLUSTERED INDEX IX_Emp_Cons_EmpID ON #Emp_Cons (Emp_ID);
	
	
			IF @Constraint <> '' And @Constraint <> '0'
				BEGIN
				
					INSERT	INTO #Emp_Cons(Emp_ID)    
					SELECT  CAST(data  AS NUMERIC) FROM dbo.Split (@Constraint,'#') 
					--Added By Rohit on 26/11/2015 as Branch_Id and Increment ID was Coming NULL---
					UPDATE	#Emp_Cons 
					SET		Branch_ID=I1.Branch_ID,
							Increment_ID =I1.Increment_ID
					FROM	#Emp_Cons EC 
							INNER JOIN T0095_INCREMENT I1  ON EC.Emp_ID=I1.Emp_ID
							INNER JOIN (
											SELECT	MAX(I2.Increment_ID) AS Increment_ID,I2.Emp_ID 
											FROM	T0095_Increment I2  INNER JOIN #Emp_Cons E ON I2.Emp_ID=E.Emp_ID	-- Ankit 12092014 for Same Date Increment --
													INNER JOIN (
																	SELECT MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
																	FROM T0095_INCREMENT I3  INNER JOIN #Emp_Cons E3 ON I3.Emp_ID=E3.Emp_ID	
																	WHERE I3.Increment_effective_Date <= @to_date AND I3.Cmp_ID =@Cmp_ID
																	GROUP BY I3.EMP_ID  
																) I3 ON I2.Increment_Effective_Date=I3.Increment_Effective_Date AND I2.EMP_ID=I3.Emp_ID																																			
											GROUP BY I2.Emp_ID
										) I ON I1.Emp_ID = I.Emp_ID AND I1.Increment_ID=I.Increment_ID
										
										
					--Ended By Rohit on 26/11/2015 as Branch_Id and Increment ID was Coming NULL---   
				END
			ELSE
				BEGIN
					INSERT	INTO #Emp_Cons  
					SELECT	DISTINCT emp_id,branch_id,Increment_ID 
					FROM	dbo.V_Emp_Cons 
					WHERE	Cmp_ID=@Cmp_ID AND ISNULL(Cat_ID,0) = ISNULL(@Cat_ID ,ISNULL(Cat_ID,0))  
							AND Grd_ID = ISNULL(@Grd_ID ,Grd_ID)  
							AND ISNULL(Dept_ID,0) = ISNULL(@Dept_ID ,ISNULL(Dept_ID,0))  
							AND ISNULL(Type_ID,0) = ISNULL(@Type_ID ,ISNULL(Type_ID,0))  
							AND ISNULL(Desig_ID,0) = ISNULL(@Desig_ID ,ISNULL(Desig_ID,0)) --Added By Jaina 25-09-2015
							AND EXISTS (select Data from dbo.Split(isnull(@PBranch_ID,0), ',') PB Where cast(PB.data as numeric)=Isnull(V_Emp_Cons.Branch_ID,0))
							AND EXISTS (select Data from dbo.Split(isnull(@PVertical_ID,0), ',') V Where cast(v.data as numeric)=Isnull(V_Emp_Cons.Vertical_ID,0))
							AND EXISTS (select Data from dbo.Split(isnull(@PsubVertical_ID ,0), ',') S Where cast(S.data as numeric)=Isnull(V_Emp_Cons.SubVertical_ID,0))
							AND EXISTS (select Data from dbo.Split(isnull(@PDept_ID,0), ',') D Where cast(D.data as numeric)=Isnull(V_Emp_Cons.Dept_ID,0)) 
							AND Emp_ID = ISNULL(@Emp_ID ,Emp_ID) AND Increment_Effective_Date <= @To_Date 
							AND (
									(@From_Date  >= join_Date  AND  @From_Date <= left_date ) 
									OR ( @To_Date  >= join_Date  and @To_Date <= left_date )  
									OR (Left_date is null and @To_Date >= Join_Date)
									OR (@To_Date >= left_date  and  @From_Date <= left_date )
								) 
					ORDER BY Emp_ID
							
					
					DELETE E FROM #Emp_Cons E
					WHERE NOT EXISTS (
										SELECT	TOP 1 1
										FROM	t0095_increment TI 
												INNER JOIN (
															SELECT	MAX(T0095_Increment.Increment_ID) AS Increment_ID,T0095_Increment.Emp_ID 
															FROM	T0095_Increment  INNER JOIN #Emp_Cons E ON T0095_INCREMENT.Emp_ID=E.Emp_ID	-- Ankit 12092014 for Same Date Increment
															WHERE	Increment_effective_Date <= @to_date AND Cmp_ID =@Cmp_Id 
															GROUP BY T0095_Increment.emp_ID
															) new_inc ON TI.Emp_ID = new_inc.Emp_ID AND Ti.Increment_ID=new_inc.Increment_ID
										WHERE	Increment_effective_Date <= @to_date AND E.Increment_ID	= TI.Increment_ID
									)


			END    
  	END


	DECLARE @Required_Execution BIT;
	SET @Required_Execution = 0;
 

	
	/*************************************************************************
	Added by Nimesh: 17/Nov/2015 
	(To get holiday/weekoff data for all employees in seperate table)
	*************************************************************************/
	IF OBJECT_ID('tempdb..#EMP_HOLIDAY') IS NULL
		BEGIN
			CREATE TABLE #EMP_HOLIDAY(EMP_ID NUMERIC, FOR_DATE DATETIME, IS_CANCEL BIT, Is_Half tinyint, Is_P_Comp tinyint, H_DAY numeric(4,1));
			CREATE UNIQUE CLUSTERED INDEX IX_EMP_HOLIDAY_EMPID_FORDATE ON #EMP_HOLIDAY(EMP_ID, FOR_DATE);
			SET @Required_Execution = 1
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
			SET @Required_Execution = 1
		END
	ELSE IF NOT EXISTS(SELECT 1 FROM #EMP_WEEKOFF)
		BEGIN
			SET @Required_Execution = 1
		END
		
  	IF OBJECT_ID('tempdb..#Emp_WeekOff_Holiday') IS NULL
	BEGIN
		--Holiday & WeekOff - In colon(;) seperated string (Without Cancel) : Used in SP_CALCULATE_PRESENT_DAYS
		CREATE TABLE #Emp_WeekOff_Holiday
		(
			Emp_ID				NUMERIC,
			WeekOffDate			VARCHAR(Max),
			WeekOffCount		NUMERIC(4,1),
			HolidayDate			VARCHAR(Max),
			HolidayCount		NUMERIC(4,1),
			HalfHolidayDate		VARCHAR(Max),
			HalfHolidayCount	NUMERIC(4,1),
			OptHolidayDate		VARCHAR(Max),
			OptHolidayCount		NUMERIC(4,1)
		);
		SET @Required_Execution  = 1;
	END 
	
	IF OBJECT_ID('tempdb..#EMP_HW_CONS') IS NULL
	BEGIN	
	
		--Holiday & Weekoff - In colon(;) seperated string (With Cancel) : Used in SP_CALCULATE_PRESENT_DAYS
		CREATE TABLE #EMP_HW_CONS
		(
			Emp_ID				NUMERIC,
			WeekOffDate			Varchar(Max),
			WeekOffCount		NUMERIC(4,1),
			CancelWeekOff		Varchar(Max),
			CancelWeekOffCount	NUMERIC(4,1),
			HolidayDate			Varchar(MAX),
			HolidayCount		NUMERIC(4,1),
			HalfHolidayDate		Varchar(MAX),
			HalfHolidayCount	NUMERIC(4,1),
			CancelHoliday		Varchar(Max),
			CancelHolidayCount	NUMERIC(4,1)
		);
		
		CREATE UNIQUE CLUSTERED INDEX IX_EMP_HW_CONS_EmpID ON #EMP_HW_CONS(Emp_ID)
		
		SET @Required_Execution  =1;		
	END
	
	
	
	IF OBJECT_ID('tempdb..#EMP_HW_CONS_SAL') IS NOT NULL
		SET @Required_Execution  = 1;
	
	IF @Required_Execution = 1
		BEGIN
			DECLARE @All_Weekoff BIT
			SET @All_Weekoff = 0;

			TRUNCATE TABLE #EMP_HW_CONS			
			EXEC SP_GET_HW_ALL @CONSTRAINT=@CONSTRAINT,@CMP_ID=@Cmp_ID, @FROM_DATE=@FROM_DATE, @TO_DATE=@TO_DATE, @All_Weekoff = @All_Weekoff, @Exec_Mode=0		
			
		END 
	
	
	CREATE TABLE #EMP_GEN_SETTINGS
	(
		EMP_ID NUMERIC PRIMARY KEY,
		BRANCH_ID NUMERIC,
		First_In_Last_Out_For_InOut_Calculation TINYINT,
		Chk_otLimit_before_after_Shift_time	TINYINT
	) 
	

  -------- Add By jignesh 30-11-2019------
			DECLARE @First_In_Last_Out_For_InOut_Calculation TINYINT 
			DECLARE @MonthExemptLimit varchar(10) = ''
			DECLARE @MonthExemptLimitInSec Numeric(18,0) = 0
			Declare @LateEarly_MonthWise Numeric(2,0)  = 0
			Declare @IsDeficit tinyint  = 0
    
			SELECT	TOP 1 @First_In_Last_Out_For_InOut_Calculation  = First_In_Last_Out_For_InOut_Calculation
			,@MonthExemptLimit = Monthly_Exemption_Limit
			,@MonthExemptLimitInSec = dbo.F_Return_Sec(Monthly_Exemption_Limit)
			,@LateEarly_MonthWise = ISNULL(LateEarly_MonthWise,0)
			,@IsDeficit = Isnull(IsDeficit,0)
			FROM	#EMP_CONS EC 
			INNER JOIN T0040_GENERAL_SETTING GS  ON EC.BRANCH_ID=GS.BRANCH_ID
			INNER JOIN (SELECT	GS1.BRANCH_ID, MAX(FOR_DATE) AS FOR_DATE
						FROM	T0040_GENERAL_SETTING GS1 
						WHERE	GS1.FOR_DATE < @TO_DATE
						GROUP BY GS1.BRANCH_ID
			) GS1 ON GS.BRANCH_ID=GS1.BRANCH_ID AND GS.FOR_DATE=GS1.FOR_DATE	
	
			
	IF @Reload_InOut = 1
	BEGIN 		
			TRUNCATE TABLE #DATA
			EXEC P_GET_EMP_INOUT @Cmp_ID, @FROM_DATE, @TO_DATE, @First_In_Last_Out_For_InOut_Calculation
	END	
	
	

	ALTER TABLE #EMP_GEN_SETTINGS ADD Tras_Week_OT TINYINT, Is_Cancel_Holiday_WO_HO_same_day TINYINT
	UPDATE	TG
	SET		Tras_Week_OT = G.Tras_Week_OT,
	Is_Cancel_Holiday_WO_HO_same_day = G.Is_Cancel_Holiday_WO_HO_same_day
	FROM	#EMP_GEN_SETTINGS TG 
				INNER JOIN  T0040_GENERAL_SETTING G  ON TG.BRANCH_ID=G.BRANCH_ID
				INNER JOIN (SELECT	MAX(GEN_ID) AS GEN_ID, G1.BRANCH_ID
							FROM	T0040_GENERAL_SETTING G1 
									INNER JOIN (SELECT	MAX(FOR_DATE) AS FOR_DATE , BRANCH_ID
												FROM	T0040_GENERAL_SETTING G2 
												WHERE	G2.For_Date <= @TO_DATE AND G2.Cmp_ID = @Cmp_Id
												GROUP	BY G2.Branch_ID) G2 ON G1.Branch_ID=G2.Branch_ID AND G1.For_Date=G2.FOR_DATE
							GROUP BY G1.Branch_ID) G1 ON G.Gen_ID=G1.GEN_ID AND G.Branch_ID=G1.Branch_ID
	
	
	--Added Following Query by Nimesh On 22-Jul-2016 (OT Should not be considered if it is disabled from Grade Master)
	Update	D
	SET		EMP_OT = 0
	FROM	#Data D INNER JOIN #Emp_Cons E ON D.Emp_Id=E.Emp_ID
			INNER JOIN T0095_INCREMENT I  ON E.Increment_ID=I.Increment_ID 
			INNER JOIN T0040_GRADE_MASTER G  ON G.Grd_ID=I.Grd_ID
	WHERE	OT_Applicable = 0
			

	--ADDED BY NIMESH ON 21-JAN-2016
	--IF USER HAS PUNCHED AFTER REGULARIZING IN-OUT. IN THAT IN-OUT TABLE WILL HAVE TWO RECORDS ONE FOR Chk_By_Superior=1 AND ANOTHER ONE IS Chk_By_Superior=0
	DELETE	D 
	FROM	#DATA D INNER JOIN (SELECT FOR_DATE,EMP_ID FROM #DATA D1 WHERE Chk_By_Superior=1) D1 ON D.EMP_ID=D1.EMP_ID AND D.FOR_DATE=D1.For_date
	WHERE	D.Chk_By_Superior = 0
		
	
	--If @First_In_Last_Out_For_InOut_Calculation = 0
	--	BEGIN
			--Modified by Nimesh on 04-Jan-2016 (The settings should be checked employee wise or branch wise)
			select	D.Emp_Id , For_date , Duration_in_sec , In_Time , Shift_Start_Time , OUT_Time , Shift_End_Time , Working_Hrs_St_Time , Working_Hrs_End_Time into 
					#temp_In_Out_Time 
			from	#Data D INNER JOIN #EMP_GEN_SETTINGS ES  ON D.EMP_ID=ES.EMP_ID 
			WHERE	First_In_Last_Out_For_InOut_Calculation=0
		--END

		
				
		declare @shift_st_time1 datetime
 
		Insert Into #Data_temp1 
		(Emp_ID,For_Date,Duration_In_sec,Emp_OT,Emp_OT_min_Limit,Emp_OT_max_Limit,In_Time,Shift_Start_Time,OT_Start_Time,Shift_Change,Chk_By_Superior,IO_Tran_Id,OUT_Time
		 
		)
		Select Emp_ID,for_Date,
		sum(isnull(Duration_in_sec,0))
		,isnull(Emp_OT,0),isnull(Emp_OT_min_Limit,0),isnull(Emp_OT_max_Limit,0),null,null,0,0,MAX(Chk_By_Superior),IO_Tran_Id,0   --MAX(Chk_By_Superior) Done by Ramiz on 04/05/2018 -- Suggestion by Nimesh bhai , As in case of Reguralization 2 Entries were Coming (when First_In_Last_Out = 0)  
		From #Data 
		Group By For_Date,Emp_ID,Emp_Ot,Emp_OT_min_Limit,Emp_OT_Max_Limit,IO_Tran_Id


		Update	#Data_temp1 set In_Time=InTime, OUT_Time=OutTime 
		from	#Data_temp1 as DT	
				inner join
				(select Min(In_Time) as InTime, Max (OUT_Time) as OutTime, For_Date,Emp_ID from #Data Group by For_Date,Emp_ID)Q
					on DT.Emp_ID=Q.Emp_ID and Dt.For_Date=Q.For_Date 	 	 	
   	--Delete From #Data  
		
		
		
		Truncate Table #Data    --Hardik 15/02/2013  
		Insert Into #data 
		select * from #Data_temp1  
	
		
		/*Commented by Nimesh
		DECLARE @Night_Shift AS NUMERIC

		DECLARE @Mst_Shift_St_time AS DATETIME
		DECLARE @Mst_Shift_End_Time AS DATETIME
		*/
		--PRINT 'STATE 2 :' + CONVERT(VARCHAR(20), GETDATE(), 114);
		--Add by Nimesh 21 April, 2015
		--This sp retrieves the Shift Rotation as per given employee id and effective date.
		--it will fetch all employee's shift rotation detail if employee id is not specified.
		IF (OBJECT_ID('tempdb..#Rotation') IS NULL)
			Create Table #Rotation (R_EmpID numeric(18,0), R_DayName varchar(25), R_ShiftID numeric(18,0), R_Effective_Date DateTime);
		--The #Rotation table gets re-created in dbo.P0050_UNPIVOT_EMP_ROTATION stored procedure
		IF EXISTS(SELECT 1 FROM T0050_Emp_Monthly_Shift_Rotation ROT INNER JOIN #Emp_Cons EC ON ROT.Emp_ID=EC.Emp_ID)
			Exec dbo.P0050_UNPIVOT_EMP_ROTATION @Cmp_ID, NULL, @To_Date, @constraint	
		
		
		
		UPDATE	#Data SET SHIFT_ID = dbo.fn_get_Shift_From_Monthly_Rotation(@Cmp_ID,Emp_Id, For_date);

		
		/*
		--Getting Shift from Shift Change Detail (Default Shift)
		UPDATE	#Data SET SHIFT_ID = SH.Shift_ID, Shift_Type=SH.Shift_Type
		FROM	#Data D,
				(	
					SELECT	SD.Emp_ID,SD.Shift_ID, D.For_date,SD.Shift_Type
					FROM	T0100_EMP_SHIFT_DETAIL SD INNER JOIN #Data D ON SD.Emp_ID=D.Emp_Id
					WHERE	SD.Emp_ID=D.EMP_ID AND SD.Cmp_ID=@CMP_ID
							AND SD.For_Date =	(Select	Max(For_Date)
												FROM	T0100_EMP_SHIFT_DETAIL SD1
												WHERE	SD1.Emp_ID	=SD.Emp_ID AND SD1.Cmp_ID=SD.Cmp_ID	AND SD1.For_Date <= D.For_date and ISNULL(SD1.Shift_Type,0)=0
												)
				) As SH
		WHERE	SH.For_date	= D.For_date AND SH.Emp_ID=D.Emp_ID
		
		
		
		--Getting Shift from Monthly Shift Rotation Detail Detail 
		UPDATE	#Data 
		SET		SHIFT_ID=SM.SHIFT_ID,Shift_Type=0
		FROM	#Data D INNER JOIN #Rotation R ON R.R_DayName = 'Day' + CAST(DATEPART(d, D.For_date) As Varchar)
						AND D.Emp_Id=R.R_EmpID
				INNER JOIN T0040_SHIFT_MASTER SM ON R.R_ShiftID	=SM.Shift_ID 
		WHERE	R.R_Effective_Date = (
										SELECT	MAX(R_Effective_Date)
										FROM	#Rotation R1 
										WHERE	R1.R_EmpID=Emp_Id AND R1.R_Effective_Date<=D.FOR_DATE
									) 
				AND NOT EXISTS(Select 1 from T0040_SHIFT_MASTER where Cmp_ID=@Cmp_ID and Inc_Auto_Shift=1 AND D.Shift_ID=D.Shift_ID)
				AND SM.Cmp_ID=@Cmp_ID	
		
		
		--Getting Shift from Shift Change Detail (Temporary)
		UPDATE	#Data SET SHIFT_ID = SH.Shift_ID, Shift_Type=SH.Shift_Type
		FROM	#Data D,
				(	
					SELECT	SD.Emp_ID,SD.Shift_ID, D.For_date,SD.Shift_Type
					FROM	T0100_EMP_SHIFT_DETAIL SD INNER JOIN #Data D ON SD.Emp_ID=D.Emp_Id
					WHERE	SD.Emp_ID=D.EMP_ID AND SD.Cmp_ID=@CMP_ID
							AND SD.For_Date =	(Select	Max(For_Date)
												FROM	T0100_EMP_SHIFT_DETAIL SD1
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
		WHERE	SH.For_date	= D.For_date AND SH.Emp_ID=D.Emp_ID
		
		--Getting Shift from Shift Change Detail (Regular)
		UPDATE	#Data SET SHIFT_ID = SH.Shift_ID, Shift_Type=SH.Shift_Type
		FROM	#Data D,
				(	
					SELECT	SD.Emp_ID,SD.Shift_ID, D.For_date,SD.Shift_Type
					FROM	T0100_EMP_SHIFT_DETAIL SD INNER JOIN #Data D ON SD.Emp_ID=D.Emp_Id
					WHERE	SD.Emp_ID=D.EMP_ID AND SD.Cmp_ID=@CMP_ID
							AND SD.For_Date =	(
													Select	Max(For_Date)
													FROM	T0100_EMP_SHIFT_DETAIL SD1
													WHERE	SD1.Emp_ID	=SD.Emp_ID AND SD1.Cmp_ID=SD.Cmp_ID	AND SD1.For_Date = D.For_date	
												)
							AND EXISTS (
											SELECT 1 FROM #Rotation R
											WHERE	SD.Emp_ID=R.R_EmpID AND R.R_DayName = 'Day' + CAST(DATEPART(d, D.For_date) As Varchar)
													AND R.R_Effective_Date = (
																				SELECT	MAX(R_Effective_Date)
																				FROM	#Rotation R1 
																				WHERE	R1.R_EmpID=D.Emp_Id AND R1.R_Effective_Date<=D.FOR_DATE
																			) 
										)													
				) As SH
		WHERE	SH.For_date	= D.For_date AND SH.Emp_ID=D.Emp_ID
		--PRINT 'CALC 5 :' + CONVERT(VARCHAR(20), GETDATE(), 114);
		*/
		
		
	UPDATE	#Data
	SET		Shift_Start_Time = CASE WHEN Is_Half_Day = 1 AND DATENAME(WEEKDAY , FOR_DATE) = Week_Day THEN ISNULL(Half_ST_Time, q.Shift_St_Time) ELSE q.Shift_St_Time END,
			OT_Start_Time=isnull(q.OT_Start_Time,0),
			Shift_End_Time = CASE WHEN Is_Half_Day = 1 AND DATENAME(WEEKDAY , FOR_DATE) = Week_Day THEN ISNULL(Half_End_Time, q.Shift_End_Time) ELSE q.Shift_End_Time END,
			OT_End_Time =  isnull(q.OT_End_Time,0), --Ankit 16112013 
			Working_Hrs_St_Time = q.Working_Hrs_St_Time,	 --Hardik 14/02/2014
			Working_Hrs_End_Time =  isnull(q.Working_Hrs_End_Time,0) --Hardik 14/02/2014
	FROM	#data d INNER JOIN 
				(
					SELECT	ST.Shift_st_time,ST.Shift_ID,ISNULL(SD.OT_Start_Time,0) AS OT_Start_Time,
							ST.Shift_End_Time ,ISNULL(SD.OT_End_Time,0) AS OT_End_Time,
							Sd.Working_Hrs_St_Time,sd.Working_Hrs_End_Time,
							ST.Half_ST_Time, ST.Half_End_Time, ST.Week_Day, ST.Is_Half_Day
					FROM	dbo.t0040_shift_master ST  LEFT OUTER JOIN dbo.t0050_shift_detail SD  
							ON ST.Shift_ID=SD.Shift_ID 
					WHERE St.Cmp_ID = @Cmp_ID
				) q ON d.shift_id=q.shift_id



  
	--Update #Data set Shift_End_Time = Case When Shift_Start_Time > Shift_End_Time or Datepart(hour,Shift_Start_Time)=0 Then  -- Or Condition added by Hardik 20/11/2015 for 12:00 Night shift for Nirma
	
		--Commented Above Code and New Code of Shift End Time is Added By Ramiz on 19/12/2016 Bcoz if Outtime is on Same Day then Shift Out Time was Coming Incorrect--
		Update #Data set Shift_End_Time = CASE WHEN Shift_Start_Time > Shift_End_Time or Datepart(hour,Shift_Start_Time)=0 THEN  -- Or Condition added by Hardik 20/11/2015 for 12:00 Night shift for Nirma
												CASE WHEN (CONVERT(VARCHAR , IN_TIME , 111) = CONVERT(VARCHAR , OUT_TIME , 111)) AND (CONVERT(VARCHAR(8), IN_TIME , 108) < CONVERT(VARCHAR(8), OUT_Time , 108)) THEN
													CAST(CONVERT(VARCHAR(11), OUT_TIME + 1, 121)  + CONVERT(VARCHAR(12), SHIFT_END_TIME, 114) AS DATETIME) 
												ELSE
													CAST(CONVERT(VARCHAR(11), OUT_TIME, 121)  + CONVERT(VARCHAR(12), SHIFT_END_TIME, 114) AS DATETIME) 
												END
											ELSE 
												--cast(CONVERT(VARCHAR(11), In_Time, 121)  + CONVERT(VARCHAR(12), Shift_End_Time, 114) as datetime) End  --Commented by Hardik 27/07/2016 as Normal Shift Time not coming when In and Out Punch is not there
												CAST(CONVERT(VARCHAR(11), For_Date, 121)  + CONVERT(VARCHAR(12), Shift_End_Time, 114) AS DATETIME) 
											END  
				FROM #Data
		--Code Ended By Ramiz on 19/12/2016
				
	Update #Data set Shift_Start_Time = case When Datepart(hour,Shift_Start_Time)=0 then -- Or Condition added by Hardik 20/11/2015 for 12:00 Night shift for Nirma
											cast(CONVERT(VARCHAR(11), OUT_Time, 121)  + CONVERT(VARCHAR(12), Shift_Start_Time, 114) as datetime)  
										else
											--cast(CONVERT(VARCHAR(11), In_time, 121)  + CONVERT(VARCHAR(12), Shift_Start_Time, 114) as datetime) --Commented by Hardik 27/07/2016 as Normal Shift Time not coming when In and Out Punch is not there
											cast(CONVERT(VARCHAR(11), For_date, 121)  + CONVERT(VARCHAR(12), Shift_Start_Time, 114) as datetime)  
										end
	from #Data


	--select isnull(datediff(s,in_time,Shift_Start_Time),0),In_Time,Shift_Start_Time from #Data

	--Update #Data set Shift_Change=1 where isnull(datediff(s,in_time,Shift_Start_Time),0)  < -14400 
	Update	#Data 
	SET		Shift_Change=1 
	WHERE	ABS(isnull(datediff(s,in_time,Shift_Start_Time),0))  > 18000 AND IsNull(Chk_By_Superior,0) <> 1
			AND CASE WHEN Shift_Start_Time > Shift_End_Time THEN  0 ELSE datediff(HH,Shift_Start_Time,Shift_End_Time) END < 23
			
	Update	#Data 
	SET		Shift_Change=0 
	WHERE	ABS(isnull(datediff(s,OUT_Time,Shift_End_Time),0))  < 18000 AND Shift_Change=1 -- 05102017 inductotherm shift issue



	/*----------Uncommented below lines for HNG and comment above shift change lines--------------------------*/
	--Update #Data set Shift_Change=1 where isnull(datediff(s,in_time,Shift_Start_Time),0)  < -14400 
	--Update #Data set Shift_Change=1 where isnull(datediff(s,in_time,Shift_Start_Time),0)  > 14400  
	
	--Update #Data set Shift_Change=0 where (In_Time <= Shift_Start_Time  and OUT_Time >= Shift_End_Time)  
	--or (OUT_Time>= dateadd(hh,4,Shift_Start_Time) and OUT_Time<=Shift_End_Time)
	/*---------------------------------------------------------------------------------------------------------*/
	
--PRINT 'CALC 6 :' + CONVERT(VARCHAR(20), GETDATE(), 114);
	-----Start By Ramiz for TimeLoss ON 29/09/2015-----------
	
	--//** EXPLANATION:- Here I have taken all the Entries of [#data] table in to [#temp_In_Out_Time], 
	--//**     as I need to Deduct the Middle Duration and then Update it in [#data] table
	--//**				 and this Code will only work if First_In_Last_Out is not ticked in General Setting
	
	--Modified by Nimesh on 04-Jan-2016 (Added #EMP_GEN_SETTINGS table in JOIN)
	--If @First_In_Last_Out_For_InOut_Calculation = 0
	--	Begin
			Update	#temp_In_Out_Time  set Shift_End_Time = d.Shift_End_Time , Shift_Start_Time = d.Shift_Start_Time 
			from	#data d 
					left join #temp_In_Out_Time t on t.For_date = d.For_date  and t.Emp_Id = d.Emp_Id
					INNER JOIN #EMP_GEN_SETTINGS ES  ON D.EMP_ID=ES.EMP_ID 
			WHERE	First_In_Last_Out_For_InOut_Calculation=0
			
			UPDATE	TIO
			SET	
				Working_Hrs_St_Time = q.Working_Hrs_St_Time,
				Working_Hrs_End_Time =  isnull(q.Working_Hrs_End_Time,0)
			FROM	#temp_In_Out_Time TIO INNER JOIN #data d ON TIO.Emp_ID=d.Emp_ID AND TIO.For_Date=d.For_Date
					INNER JOIN 
					(
						SELECT	ST.Shift_st_time,ST.Shift_ID,ISNULL(SD.OT_Start_Time,0) AS OT_Start_Time,
								ST.Shift_End_Time ,ISNULL(SD.OT_End_Time,0) AS OT_End_Time,
								Sd.Working_Hrs_St_Time,sd.Working_Hrs_End_Time
						FROM	dbo.t0040_shift_master ST  LEFT OUTER JOIN dbo.t0050_shift_detail SD 
								ON ST.Shift_ID=SD.Shift_ID 
						WHERE St.Cmp_ID = @Cmp_ID
					) q ON d.shift_id=q.shift_id
				INNER JOIN #EMP_GEN_SETTINGS ES ON D.EMP_ID=ES.EMP_ID 
			WHERE	First_In_Last_Out_For_InOut_Calculation=0
				

			Update	#temp_In_Out_Time 
			set		OUT_Time = case when OUT_Time > Shift_End_Time then Shift_End_Time else OUT_Time end 
			from	#temp_In_Out_Time t 
					INNER JOIN #EMP_GEN_SETTINGS ES ON t.EMP_ID=ES.EMP_ID 
			WHERE	First_In_Last_Out_For_InOut_Calculation = 0
					AND t.Working_Hrs_End_Time = 1
			
			UPDATE	#temp_In_Out_Time 
			SET		In_Time = case  when In_Time < Shift_Start_Time then Shift_Start_Time else In_Time end  
			FROM	#temp_In_Out_Time t 
					INNER JOIN #EMP_GEN_SETTINGS ES ON t.EMP_ID=ES.EMP_ID 
			WHERE	First_In_Last_Out_For_InOut_Calculation = 0
					AND t.Working_Hrs_St_Time = 1
	
			Update	#temp_In_Out_Time 
			SET		In_Time = case  when In_Time > Shift_End_Time and OUT_Time = Shift_End_Time then Shift_End_Time else In_Time end  
			FROM	#temp_In_Out_Time t 
					INNER JOIN #EMP_GEN_SETTINGS ES ON t.EMP_ID=ES.EMP_ID 
			WHERE	First_In_Last_Out_For_InOut_Calculation = 0
					AND t.Working_Hrs_End_Time = 1

			/*The Following Query has been commented by Nimesh on 25-Jan-2018 (We are updating Duration_In_Sec in P_GET_EMP_INOUT stored procedure)
			Update	#temp_In_Out_Time
			Set		Duration_in_sec = isnull(datediff(s,t.in_time,t.out_time),0)			
			from	#temp_In_Out_Time t
					INNER JOIN #EMP_GEN_SETTINGS ES ON t.EMP_ID=ES.EMP_ID 
			WHERE	First_In_Last_Out_For_InOut_Calculation = 0
	
					After My Calculation , Here I am Updating the Duration in Original Table . . .
			Update	#Data
			SET		Duration_in_sec = (select SUM(T.Duration_in_sec) from #temp_In_Out_Time T where T.For_date = d.For_date and T.Emp_Id = d.Emp_Id)
			FROM	#data d 
					INNER JOIN #EMP_GEN_SETTINGS ES ON d.EMP_ID=ES.EMP_ID 
			WHERE	First_In_Last_Out_For_InOut_Calculation = 0
					AND For_date = d.For_date and D.Emp_Id = d.Emp_Id
			*/
			
			--End	--Commented by Nimesh on 04-Jan-2016 (Added #EMP_GEN_SETTINGS table in JOIN)
	
	--Commented by Nimesh on 04-Jan-2016 (Added #EMP_GEN_SETTINGS table in JOIN)
	---Hardik 03/02/2014 for Kataria as they have not calculate working hour after Shift End Time
	--If @First_In_Last_Out_For_InOut_Calculation = 1
	--BEGIN
	
	
			/*The following code has been commented by Nimesh on 25-Jan-2018 (The logic has been shifted to P_GET_EMP_INOUT procedure so, we can get actual duration in seconds in every procedure)*/
		 -- SELECT *, Duration_in_sec As TotalWorkDur  INTO #Data_DURCAL FROM #DATA
			--UPDATE #Data_DURCAL SET TotalWorkDur = DATEDIFF(s, In_Time, IsNull(Out_Time, In_Time))
			
		 -- Update 	D
			--set 	Duration_in_sec = DATEDIFF(s,d.Shift_Start_Time,d.OUT_Time)
			--from 	#Data_DURCAL d 
			--		INNER JOIN #EMP_GEN_SETTINGS ES ON D.EMP_ID=ES.EMP_ID 
			--WHERE	Working_Hrs_St_Time = 1 And d.Working_Hrs_End_Time = 0 and In_Time < d.Shift_Start_Time --First_In_Last_Out_For_InOut_Calculation = 1

	  
		 -- Update 	D
			--set 	Duration_in_sec = DATEDIFF(s,In_Time,d.Shift_End_Time)
			--from 	#Data_DURCAL d 
			--		INNER JOIN #EMP_GEN_SETTINGS ES ON D.EMP_ID=ES.EMP_ID 
			--WHERE	d.Working_Hrs_St_Time = 0 And d.Working_Hrs_End_Time = 1 and OUT_Time > d.Shift_End_Time --First_In_Last_Out_For_InOut_Calculation = 1

			--Update	D
			--SET		Duration_in_sec =(
			--							Case When In_Time < Shift_Start_Time And OUT_Time > Shift_End_Time Then  DATEDIFF(s,d.Shift_Start_Time,d.Shift_End_Time) Else
			--							Case When In_Time < Shift_Start_Time Then DATEDIFF(s,d.Shift_Start_Time,OUT_Time) Else
			--							Case When OUT_Time > Shift_End_Time Then DATEDIFF(s,In_Time,d.Shift_End_Time) Else
			--							DATEDIFF(s,In_Time,OUT_Time) End End End
			--						)
			--FROM	#Data_DURCAL d Left Outer Join #EMP_HW_CONS EHW on d.Emp_Id = EHW.Emp_ID
			--		INNER JOIN #EMP_GEN_SETTINGS ES ON D.EMP_ID=ES.EMP_ID 
			--WHERE	d.Working_Hrs_St_Time = 1 And d.Working_Hrs_End_Time = 1 and ISNULL(CHARINDEX(cast(d.For_date as varchar(11)),ehw.WeekOffDate),0) = 0 and ISNULL(CHARINDEX(cast(d.For_date as varchar(11)),ehw.HolidayDate) ,0) = 0
			--		--AND First_In_Last_Out_For_InOut_Calculation = 1
					
			--UPDATE	D 
			--SET		Duration_in_sec = D.Duration_in_sec - (DD.TotalWorkDur - DD.Duration_in_sec)
			--FROM	#DATA D
			--		INNER JOIN #Data_DURCAL DD ON D.Emp_Id=DD.Emp_Id AND D.For_date=DD.For_date
			--WHERE	d.Working_Hrs_St_Time = 1 OR d.Working_Hrs_End_Time = 1
			/*The following code has been commented by Nimesh on 25-Jan-2018 (The logic has been shifted to P_GET_EMP_INOUT procedure so, we can get actual duration in seconds in every procedure)*/

			
			
			-- Deepal 25062021
		    SELECT *, Duration_in_sec As TotalWorkDur  INTO #Data_DURCAL FROM #DATA
			UPDATE #Data_DURCAL SET TotalWorkDur = DATEDIFF(s, In_Time, IsNull(Out_Time, In_Time))
			
		

		    Update 	D
			set 	Duration_in_sec = DATEDIFF(s,d.Shift_Start_Time,d.OUT_Time)
			from 	#Data_DURCAL d 
					INNER JOIN #EMP_GEN_SETTINGS ES ON D.EMP_ID=ES.EMP_ID 
			WHERE	Working_Hrs_St_Time = 1 And d.Working_Hrs_End_Time = 0 and In_Time < d.Shift_Start_Time --First_In_Last_Out_For_InOut_Calculation = 1
			
			
				    
		    Update 	D
			set 	Duration_in_sec = DATEDIFF(s,In_Time,d.Shift_End_Time)
			from 	#Data_DURCAL d 
					INNER JOIN #EMP_GEN_SETTINGS ES ON D.EMP_ID=ES.EMP_ID 
			WHERE	d.Working_Hrs_St_Time = 0 And d.Working_Hrs_End_Time = 1 and OUT_Time > d.Shift_End_Time --First_In_Last_Out_For_InOut_Calculation = 1
						
			

			Update	D
			SET		Duration_in_sec =(
										Case When In_Time < Shift_Start_Time And OUT_Time > Shift_End_Time Then  DATEDIFF(s,d.Shift_Start_Time,d.Shift_End_Time) Else
										Case When In_Time < Shift_Start_Time Then DATEDIFF(s,d.Shift_Start_Time,OUT_Time) Else
										Case When OUT_Time > Shift_End_Time Then DATEDIFF(s,In_Time,d.Shift_End_Time) Else
										DATEDIFF(s,In_Time,OUT_Time) End End End
									)
			FROM	#Data_DURCAL d Left Outer Join #EMP_HW_CONS EHW on d.Emp_Id = EHW.Emp_ID
					INNER JOIN #EMP_GEN_SETTINGS ES ON D.EMP_ID=ES.EMP_ID 
			WHERE	d.Working_Hrs_St_Time = 1 And d.Working_Hrs_End_Time = 1 
			and ISNULL(CHARINDEX(cast(d.For_date as varchar(11)),ehw.WeekOffDate),0) = 0 
			and ISNULL(CHARINDEX(cast(d.For_date as varchar(11)),ehw.HolidayDate) ,0) = 0
					--AND First_In_Last_Out_For_InOut_Calculation = 1
			
		--Select * From #Data_DURCAL
		--Select * From #DATA
			--Deepal Comment on 18062021	
			--select Duration_in_sec,* from #DATA
			--select TotalWorkDur , Duration_in_sec,* from #Data_DURCAL

			UPDATE	D 
			--SET		Duration_in_sec = D.Duration_in_sec - (DD.TotalWorkDur - DD.Duration_in_sec)
			SET		Duration_in_sec = D.Duration_in_sec
					,OT_Sec = DD.TotalWorkDur - D.Duration_in_sec
			--SET		Duration_in_sec = DD.TotalWorkDur - DD.Duration_in_sec
			FROM	#DATA D
					INNER JOIN #Data_DURCAL DD ON D.Emp_Id=DD.Emp_Id AND D.For_date=DD.For_date
			--WHERE	d.Working_Hrs_St_Time = 1 OR d.Working_Hrs_End_Time = 1  -- Commeted By Sajid 19092023
			WHERE	d.Working_Hrs_St_Time = 1 AND d.Working_Hrs_End_Time = 1 AND D.OT_Start_Time=0 and D.OT_End_Time=1 -- Added By Sajid 19092023
			--Deepal Comment on 18062021	
			
			
			-- Added By Sajid 19092023
			UPDATE	D 			
			SET		Duration_in_sec = D.Duration_in_sec
					,OT_Sec = DATEDIFF(s,d.Shift_End_Time,d.OUT_Time)			
			FROM	#DATA D
					INNER JOIN #Data_DURCAL DD ON D.Emp_Id=DD.Emp_Id AND D.For_date=DD.For_date			
			WHERE	d.Working_Hrs_St_Time = 1 AND d.Working_Hrs_End_Time = 1 AND D.OT_Start_Time=1 and D.OT_End_Time=1 
			

			---- Added By Sajid 19092023
			--UPDATE	D 			
			--SET		Duration_in_sec = D.Duration_in_sec - (DATEDIFF(s,d.Shift_End_Time,d.OUT_Time) + DATEDIFF(s,d.In_Time,d.Shift_Start_Time))					
			--FROM	#DATA D
			--		INNER JOIN #Data_DURCAL DD ON D.Emp_Id=DD.Emp_Id AND D.For_date=DD.For_date			
			--WHERE	d.Working_Hrs_St_Time = 1 AND d.Working_Hrs_End_Time = 1 AND D.OT_Start_Time=1 and D.OT_End_Time=1  and D.In_Time<=D.Shift_Start_Time

			---- Added By Sajid 19092023
			--UPDATE	D 			
			--SET		Duration_in_sec = D.Duration_in_sec - DATEDIFF(s,d.Shift_End_Time,d.OUT_Time)					
			--FROM	#DATA D
			--		INNER JOIN #Data_DURCAL DD ON D.Emp_Id=DD.Emp_Id AND D.For_date=DD.For_date			
			--WHERE	d.Working_Hrs_St_Time = 1 AND d.Working_Hrs_End_Time = 1 AND D.OT_Start_Time=1 and D.OT_End_Time=1  and D.In_Time>D.Shift_Start_Time


			-- Added By Sajid 19092023
			UPDATE	D 			
			SET		Duration_in_sec = D.Duration_in_sec
					,OT_Sec = DATEDIFF(s,d.In_Time,d.Shift_Start_Time)			
			FROM	#DATA D
					INNER JOIN #Data_DURCAL DD ON D.Emp_Id=DD.Emp_Id AND D.For_date=DD.For_date			
			WHERE	d.Working_Hrs_St_Time = 1 AND d.Working_Hrs_End_Time = 1 AND D.OT_Start_Time=0 and D.OT_End_Time=0
			
			
			-- Added By Sajid 19092023
			UPDATE	D 			
			SET		Duration_in_sec = DATEDIFF(s, DD.In_Time, IsNull(DD.Out_Time, DD.In_Time))
					,OT_Sec = (D.Duration_in_sec - DATEDIFF(s,d.Shift_Start_Time,d.Shift_END_Time))  - DATEDIFF(s,d.In_Time,d.Shift_Start_Time)		
			FROM	#DATA D
					INNER JOIN #Data_DURCAL DD ON D.Emp_Id=DD.Emp_Id AND D.For_date=DD.For_date			
			WHERE	d.Working_Hrs_St_Time = 0 AND d.Working_Hrs_End_Time = 0 AND D.OT_Start_Time=1 and D.OT_End_Time=0

					-- Added By Sajid 19092023
			UPDATE	D 			
			SET		Duration_in_sec = D.Duration_in_sec
					,OT_Sec = (D.Duration_in_sec - DATEDIFF(s,d.Shift_Start_Time,d.Shift_END_Time))
			FROM	#DATA D
					INNER JOIN #Data_DURCAL DD ON D.Emp_Id=DD.Emp_Id AND D.For_date=DD.For_date			
			WHERE	d.Working_Hrs_St_Time = 1 AND d.Working_Hrs_End_Time = 0 AND D.OT_Start_Time=1 and D.OT_End_Time=0
			
			
	


	--END--Commented by Nimesh on 04-Jan-2016 (Added #EMP_GEN_SETTINGS table in JOIN)
	  
	 ---- End by Hardik 03/02/2014
 
 --PRINT 'CALC 7 :' + CONVERT(VARCHAR(20), GETDATE(), 114);

 -- Added by rohit for if week of regularization not calculate in present if week off Work transfer to OT on 07022013
---- chk by sid for case when edit hours are kept editable
	
	--		select @Return_Record_set
	--return
	UPDATE	#Data
	SET		P_days = 1 ,
			-- Commented below 2 lines by Hardik 06/04/2020 As discussed with Ankur Sir as If in and Out time are exists then it should not replace with shift time
			--in_time = CASE WHEN Is_Cancel_Late_In = 1 THEN CASE WHEN d.in_time > CONVERT(VARCHAR(11), d.For_date, 120) + sm.shift_st_time then CONVERT(VARCHAR(11), d.For_date, 120) + sm.shift_st_time ELSE d.In_Time END ELSE d.In_Time END, 
			--out_time = CASE WHEN Is_Cancel_Early_Out = 1 THEN CASE WHEN d.Out_Time < CONVERT(VARCHAR(11), d.For_date, 120) + sm.shift_end_time THEN CONVERT(VARCHAR(11), d.For_date, 120) + sm.shift_end_time ELSE d.Out_Time END ELSE d.Out_Time END,

			-- Below condition changed by Hardik 25/11/2020 for Competent and Emerland Honda client as they want to give compoff for WO and Holiday with Attendance Regularise
			in_time = 
				CASE WHEN @Return_Record_set In (9,10,11,12,13,14,15,16) then
					CASE WHEN Is_Cancel_Late_In = 1 THEN CASE WHEN d.in_time > CONVERT(VARCHAR(11), d.For_date, 120) + sm.shift_st_time then CONVERT(VARCHAR(11), d.For_date, 120) + sm.shift_st_time ELSE d.In_Time END ELSE d.In_Time END
				Else
					CASE WHEN Is_Default_In = 1 THEN Null ELSE d.In_Time END
				END,
			out_time = 
				CASE WHEN @Return_Record_set In (9,10,11,12,13,14,15,16) then
					CASE WHEN Is_Cancel_Early_Out = 1 THEN CASE WHEN d.Out_Time < CONVERT(VARCHAR(11), d.For_date, 120) + sm.shift_end_time THEN CONVERT(VARCHAR(11), d.For_date, 120) + sm.shift_end_time ELSE d.Out_Time END ELSE d.Out_Time END
				Else
					CASE WHEN Is_Default_Out = 1 THEN Null ELSE d.Out_Time END
				END,
			duration_in_sec =
				CASE WHEN @Return_Record_set In (9,10,11,12,14,15,16) then --Remove 13 number set for getting regularized compoff date  Mr.Mehul on 12-04-2023
					dbo.F_Return_Sec(sm.shift_dur)
				WHEN @Return_Record_set In (13) then --Added by Mr.Mehul on 12-04-2023
					dbo.F_Return_Sec(TEIR.Duration)
				Else
					DATEDIFF(s,CASE WHEN Is_Default_In = 1 THEN Null ELSE d.In_Time END, CASE WHEN Is_Default_Out = 1 THEN Null ELSE d.Out_Time END) 
				End
			---duration_in_sec = dbo.F_Return_Sec(sm.shift_dur) ----- modify jignesh 21-Apr-2020--

	FROM	#Data d
	INNER JOIN dbo.T0150_EMP_INOUT_RECORD TEIR 
	ON TEIR.Emp_Id = d.Emp_Id AND TEIR.Chk_By_Superior = 1 
			AND TEIR.For_Date = d.For_date AND TEIR.Half_Full_day = 'Full Day'
	INNER JOIN T0040_SHIFT_MASTER SM  ON d.shift_id = SM.shift_id 
	WHERE	TEIR.For_Date >= @From_Date AND TEIR.For_Date <= @To_Date AND d.IO_Tran_Id = 0 
				
	


	--select  * 
	--FROM	#Data d
	--INNER JOIN dbo.T0150_EMP_INOUT_RECORD TEIR 
	--ON TEIR.Emp_Id = d.Emp_Id AND TEIR.Chk_By_Superior = 1 
	--		AND TEIR.For_Date = d.For_date AND TEIR.Half_Full_day = 'Full Day'
	--INNER JOIN T0040_SHIFT_MASTER SM  ON d.shift_id = SM.shift_id 
	--WHERE	TEIR.For_Date >= @From_Date AND TEIR.For_Date <= @To_Date AND d.IO_Tran_Id = 0 
		
	--select * from #DATA
	--	return	
	

	UPDATE #Data SET In_Time = TEIR.In_Time, OUT_Time = TEIR.Out_Time,duration_in_sec = dbo.F_Return_Sec(TEIR.Duration)				
	FROM #Data d
	INNER JOIN dbo.T0150_EMP_INOUT_RECORD TEIR 
	ON TEIR.Emp_Id = d.Emp_Id AND TEIR.Chk_By_Superior = 1 AND TEIR.For_Date = d.For_date AND TEIR.Half_Full_day = 'Full Day'
	INNER JOIN T0040_SHIFT_MASTER SM  ON d.shift_id = SM.shift_id
	where P_days = 1 AND D.In_Time is null and D.OUT_Time is null AND Reason <> ''
	AND TEIR.For_Date >= @From_Date AND TEIR.For_Date <= @To_Date AND d.IO_Tran_Id = 0

	

	-- Commented below lines by Hardik 06/04/2020 As already duration updated in above query so no need to update again
	--UPDATE	#Data
	--SET		duration_in_sec = DATEDIFF(SECOND,d.in_time,d.out_time)
	--FROM	#Data d
	--INNER JOIN dbo.T0150_EMP_INOUT_RECORD TEIR
	--ON TEIR.Emp_Id = d.Emp_Id AND TEIR.Chk_By_Superior = 1 
	--		AND TEIR.For_Date = d.For_date AND TEIR.Half_Full_day = 'Full Day'
	--INNER JOIN T0040_SHIFT_MASTER SM ON d.Shift_ID = SM.shift_id
	--WHERE	TEIR.For_Date >= @From_Date AND TEIR.For_Date <= @To_Date AND d.IO_Tran_Id = 0 


	
----chk by sid ends	
	
	/*	Wonder Comment Code --Email Dated - 31122015
	in_time = convert(varchar(11),d.For_date,120) + sm.shift_st_time,
		out_time = DATEADD(s, dbo.F_Return_Sec(sm.shift_dur)/2,  Convert(DateTime, Convert(char(10), d.For_date, 103)  + ' ' + sm.shift_st_time, 103)),
	*/

 	update #Data 
	set P_days = 0.5 ,
	------- modify jignesh 17-Apr-2020----------
	/*
	in_time = convert(varchar(11),d.For_date,120) + sm.shift_st_time
	--,out_time = (convert(varchar(11),d.For_date,120) + dbo.F_Return_Hours(dbo.F_Return_Sec(sm.shift_st_time) + (dbo.F_Return_Sec(sm.shift_dur))/2))
	,out_time = case when (dbo.F_Return_Sec(sm.shift_st_time) + (dbo.F_Return_Sec(sm.shift_dur))/2) > 86400
	 then  (convert(varchar(11),dateadd(dd,1,d.For_date),120) + dbo.F_Return_Hours((dbo.F_Return_Sec(sm.shift_st_time) + (dbo.F_Return_Sec(sm.shift_dur))/2)-86400))
	  else  (convert(varchar(11),d.For_date,120) + dbo.F_Return_Hours(dbo.F_Return_Sec(sm.shift_st_time) + (dbo.F_Return_Sec(sm.shift_dur))/2)) end
	,duration_in_sec = dbo.F_Return_Sec(sm.shift_dur)/2  
	*/
		in_time = case when ISNULL(d.in_time,'01-01-1900')='01-01-1900' then
					convert(varchar(11),d.For_date,120) + sm.shift_st_time
					else
					d.in_time
					end
					
		,out_time = case when ISNULL(d.out_time,'01-01-1900')='01-01-1900' then
					case when (dbo.F_Return_Sec(sm.shift_st_time) + (dbo.F_Return_Sec(sm.shift_dur))/2) > 86400
					then  (convert(varchar(11),dateadd(dd,1,d.For_date),120) + dbo.F_Return_Hours((dbo.F_Return_Sec(sm.shift_st_time) + (dbo.F_Return_Sec(sm.shift_dur))/2)-86400))
					else  (convert(varchar(11),d.For_date,120) + dbo.F_Return_Hours(dbo.F_Return_Sec(sm.shift_st_time) + (dbo.F_Return_Sec(sm.shift_dur))/2)) end
				  else
					d.out_time
					end
					
		,duration_in_sec =	DATEDIFF(s,
									---cast(convert(varchar(11),d.For_date,120) + sm.shift_st_time as datetime)
									case when ISNULL(d.in_time,'01-01-1900')='01-01-1900' then
									convert(varchar(11),d.For_date,120) + sm.shift_st_time
									else
									d.in_time
									end
									,cast(case when ISNULL(d.out_time,'01-01-1900')='01-01-1900' then
									case when (dbo.F_Return_Sec(sm.shift_st_time) + (dbo.F_Return_Sec(sm.shift_dur))/2) > 86400
									 then  (convert(varchar(11),dateadd(dd,1,d.For_date),120) + dbo.F_Return_Hours((dbo.F_Return_Sec(sm.shift_st_time) + (dbo.F_Return_Sec(sm.shift_dur))/2)-86400))
									  else  (convert(varchar(11),d.For_date,120) + dbo.F_Return_Hours(dbo.F_Return_Sec(sm.shift_st_time) + (dbo.F_Return_Sec(sm.shift_dur))/2)) end
									else
									d.out_time
									end as datetime)
									)
	
	from #Data d inner join  dbo.T0150_EMP_INOUT_RECORD TEIR 
	on TEIR.Emp_Id = d.Emp_Id and TEIR.Chk_By_Superior = 1 and TEIR.For_Date = d.For_date and ( TEIR.Half_Full_day = 'First Half')
	inner join T0040_SHIFT_MASTER SM  on d.Shift_ID = SM.shift_id 
	where TEIR.For_Date >= @From_Date and TEIR.For_Date <= @To_Date  and d.IO_Tran_Id  = 0 
	
		
	--update #Data 
	--set P_days = 0.5 ,in_time = (convert(varchar(11),d.For_date,120) + dbo.F_Return_Hours(dbo.F_Return_Sec(sm.shift_st_time) + (dbo.F_Return_Sec(sm.shift_dur))/2)),
	--	out_time = convert(varchar(11),d.For_date,120) + sm.shift_end_time ,duration_in_sec = dbo.F_Return_Sec(sm.shift_dur)/2  
	--from #Data d inner join  dbo.T0150_EMP_INOUT_RECORD TEIR 
	--on TEIR.Emp_Id = d.Emp_Id and TEIR.Chk_By_Superior = 1 and TEIR.For_Date = d.For_date and ( TEIR.Half_Full_day = 'Second Half')
	--inner join T0040_SHIFT_MASTER SM on d.Shift_ID = SM.shift_id 
	--where TEIR.For_Date >= @From_Date and TEIR.For_Date <= @To_Date and d.IO_Tran_Id  = 0 
	
		
	--Modified by Nimesh 28-Oct-2015 (Having issue when employee takes leave for second half and the shift time is 22:00 to 07:00)
	update #Data 
	set P_days = 0.5 
		--in_time = ((d.For_Date + Cast(sm.shift_st_time As DateTime)) - Cast('1900-01-01' As DateTime)),
		--out_time = DateAdd(s, dbo.F_Return_Sec(sm.shift_dur)/2, ((d.For_Date + Cast(sm.shift_st_time As DateTime)) - Cast('1900-01-01' As DateTime)))
		
		----jignesh 17-Apr-2020
		--in_time = DATEADD(s, CAST((dbo.F_Return_Sec(sm.shift_st_time) + (dbo.F_Return_Sec(sm.shift_dur))/2) AS NUMERIC(9,2)), d.For_date ),	--Added by Nimesh	31122015
		--out_time =  DATEADD(s, dbo.F_Return_Sec(sm.shift_dur),  Convert(DateTime, Convert(char(10), d.For_date, 103)  + ' ' + sm.shift_st_time, 103))	--Added by Nimesh	31122015
		--,duration_in_sec = dbo.F_Return_Sec(sm.shift_dur)/2  
		------------------ End ---------------
		
		,in_time = case when ISNULL(d.in_time,'01-01-1900')='01-01-1900' then
					DATEADD(s, CAST((dbo.F_Return_Sec(sm.shift_st_time) + (dbo.F_Return_Sec(sm.shift_dur))/2) AS NUMERIC(9,2)), d.For_date )
					else
					d.in_time
					end
					
		,out_time = case when ISNULL(d.out_time,'01-01-1900')='01-01-1900' then
					DATEADD(s, dbo.F_Return_Sec(sm.shift_dur),  Convert(DateTime, Convert(char(10), d.For_date, 103)  + ' ' + sm.shift_st_time, 103))
					else
					d.out_time
					end
		,duration_in_sec = DATEDIFF(s,
									---cast(DATEADD(s, CAST((dbo.F_Return_Sec(sm.shift_st_time) + (dbo.F_Return_Sec(sm.shift_dur))/2) AS NUMERIC(9,2)), d.For_date ) as datetime)
									case when ISNULL(d.in_time,'01-01-1900')='01-01-1900' then
									DATEADD(s, CAST((dbo.F_Return_Sec(sm.shift_st_time) + (dbo.F_Return_Sec(sm.shift_dur))/2) AS NUMERIC(9,2)), d.For_date )
									else
									d.in_time
									end
					,cast(case when ISNULL(d.out_time,'01-01-1900')='01-01-1900' then
									DATEADD(s, dbo.F_Return_Sec(sm.shift_dur),  Convert(DateTime, Convert(char(10), d.For_date, 103)  + ' ' + sm.shift_st_time, 103))
									else
									d.out_time
									end as datetime)
									)

	from #Data d inner join  dbo.T0150_EMP_INOUT_RECORD TEIR 
	on TEIR.Emp_Id = d.Emp_Id and TEIR.Chk_By_Superior = 1 and TEIR.For_Date = d.For_date and ( TEIR.Half_Full_day = 'Second Half')
	inner join T0040_SHIFT_MASTER SM  on d.Shift_ID = SM.shift_id 
	where TEIR.For_Date >= @From_Date and TEIR.For_Date <= @To_Date and d.IO_Tran_Id  = 0 
		
	
	---- 17-Apr-2020
	--out_time = case when ISNULL(d.out_time,'01-01-1900')='01-01-1900' then
	--				DATEADD(s, dbo.F_Return_Sec(sm.shift_dur),  Convert(DateTime, Convert(char(10), d.For_date, 103)  + ' ' + sm.shift_st_time, 103))
	--				else
	--				d.out_time
	--				end
	---select 1,* from #Data
		
-- Ended by rohit on 07022013
 			
--PRINT 'CALC 8:' + CONVERT(VARCHAR(20), GETDATE(), 114);


Declare @Emp_ID_AutoShift numeric
Declare @In_Time_Autoshift datetime
Declare @Out_Time_Autoshift datetime	--Added By Ramiz on 25/10/2016
Declare @New_Shift_ID numeric
DECLARE @AUTO_SHIFT_GRPID AS TINYINT --Added By Jimit 03022018


If exists(select 1 from T0040_SHIFT_MASTER s  where Isnull(s.Inc_Auto_Shift,0) = 1 and s.Cmp_ID=@Cmp_id)
	BEGIN
	

		Declare curautoshift cursor Fast_forward for	      
			select	d.Emp_ID,d.In_Time,d.Out_Time ,d.Shift_ID 
			from	#Data d 
					inner join T0040_SHIFT_MASTER s  on d.Shift_ID = s.Shift_ID 
			where --isnull(Shift_Change,0)=1 and Commented By  Jimit 05072019 after discussed with hardik bhai for auto shift case shift id is not picking correctly.
					Isnull(s.Inc_Auto_Shift,0) = 1 order by In_time,Emp_ID
		Open curautoshift        
			  Fetch next from curautoshift into @Emp_ID_AutoShift,@In_Time_Autoshift,@Out_Time_Autoshift ,@New_Shift_ID
		     
				While @@fetch_status = 0        
					Begin   
		     
			 --select  @Emp_ID_AutoShift,@In_Time_Autoshift
						Declare @Shift_ID_Autoshift numeric
						Declare @Shift_start_time_Autoshift varchar(12)
						Declare @Shift_End_time_Autoshift varchar(12)
						
					---------New Code of Auto Shift Kept By Ramiz on 13042015 ----------------
						SELECT @AUTO_SHIFT_GRPID = ISNULL(Auto_Shift_Group,0) 
						FROM T0040_SHIFT_MASTER  WHERE SHIFT_ID = @New_Shift_ID
						
					
						select	top 1 @Shift_ID_Autoshift =  Shift_ID ,@Shift_start_time_Autoshift = Shift_St_Time , @Shift_End_time_Autoshift = Shift_End_Time
						from	T0040_SHIFT_MASTER 
						where	Cmp_ID = @Cmp_ID AND Auto_Shift_Group = @AUTO_SHIFT_GRPID And Isnull(Inc_Auto_Shift,0)=1
						--order by ABS(datediff(s,@In_Time_Autoshift,cast(CONVERT(VARCHAR(11), @In_Time_Autoshift, 121)  + CONVERT(VARCHAR(12), Shift_St_Time, 114) as datetime)))			
						order by ABS(datediff(s,@In_Time_Autoshift,cast(CONVERT(VARCHAR(11),  Case When DATEPART(hh,Shift_St_Time)=0 And DATEPART(hh,@In_Time_Autoshift) <> 0 THEN  DATEADD(dd,1,@In_Time_Autoshift) ELSE @In_Time_Autoshift END, 121)  + CONVERT(VARCHAR(12), Shift_St_Time, 114) as datetime)))			
						

						

						--if isnull(@Shift_ID_Autoshift,0) > 0
						--Begin
						--	Update #Data set Shift_ID=@Shift_ID_Autoshift,
						--	Shift_Start_Time= cast(CONVERT(VARCHAR(11), In_time, 121)  + CONVERT(VARCHAR(12), @Shift_start_time_Autoshift, 114) as datetime) ,
						--	Shift_End_Time = cast(CONVERT(VARCHAR(11), OUT_Time, 121)  + CONVERT(VARCHAR(12), @Shift_End_time_Autoshift, 114) as datetime)					
						--	from #Data where Emp_ID=@Emp_ID_AutoShift and In_time=@In_Time_Autoshift And Shift_ID <> @Shift_ID_Autoshift
						--End
					
					/*
					If Employee has Worked on 2 different Dates (ie. Night shift) then we should not Update Shift end time , Condition Added By Ramiz on 25/10/2016
					
					 1) First I have Compared Dates , if In Date is Less then Out Date then only it will go in this Condition
					 2) Then I have Compared the Time , that If Date are Different But if Shift Start Time is Less than Shift End Time then Both Start time and End Time will be Updated
					*/
					IF ISNULL(@SHIFT_ID_AUTOSHIFT,0) > 0 AND (CAST(CONVERT(VARCHAR(11),@IN_TIME_AUTOSHIFT , 121) AS DATE) < CAST (CONVERT(VARCHAR(11) , @OUT_TIME_AUTOSHIFT , 121) AS DATE)) 
						Begin
							IF (@SHIFT_START_TIME_AUTOSHIFT < @SHIFT_END_TIME_AUTOSHIFT) 
								BEGIN
									Update #Data set Shift_ID=@Shift_ID_Autoshift,
									Shift_Start_Time= CAST(CONVERT(VARCHAR(11), In_time, 121)  + CONVERT(VARCHAR(12), @Shift_start_time_Autoshift, 114) as datetime)
									,Shift_End_Time = CAST(CONVERT(VARCHAR(11), In_time, 121)  + CONVERT(VARCHAR(12), @Shift_End_time_Autoshift, 114) as datetime)					
									from #Data 
									where Emp_ID=@Emp_ID_AutoShift and In_time=@In_Time_Autoshift 
									And Shift_ID <> @Shift_ID_Autoshift
								END
							ELSE
								BEGIN
									Update #Data set Shift_ID = @Shift_ID_Autoshift,
									Shift_Start_Time= CAST(CONVERT(VARCHAR(11), In_time, 121)  + CONVERT(VARCHAR(12), @Shift_start_time_Autoshift, 114) as datetime),
									Shift_End_Time= CAST(CONVERT(VARCHAR(11), For_date+1, 121)  + CONVERT(VARCHAR(12), @Shift_End_time_Autoshift, 114) as datetime)
									from #Data 
									where Emp_ID=@Emp_ID_AutoShift and In_time=@In_Time_Autoshift 
									And Shift_ID <> @Shift_ID_Autoshift
								END
							End
					else if isnull(@Shift_ID_Autoshift,0) > 0  --Original Condition which was kept on 13/04/2015 by Ramiz
						Begin
						
							Update #Data set Shift_ID=@Shift_ID_Autoshift,
							Shift_Start_Time= CAST(CONVERT(VARCHAR(11), In_time, 121)  + CONVERT(VARCHAR(12), @Shift_start_time_Autoshift, 114) as datetime) ,
							Shift_End_Time = CAST(CONVERT(VARCHAR(11), Coalesce(OUT_Time, In_Time,For_Date), 121)  + CONVERT(VARCHAR(12), @Shift_End_time_Autoshift, 114) as datetime)					
							from #Data 
							where Emp_ID=@Emp_ID_AutoShift and In_time=@In_Time_Autoshift 
							And Shift_ID <> @Shift_ID_Autoshift
						End
						
			---------New Code of Auto Shift Kept By Ramiz on 13042015 ----------------
					
				--	Select @Shift_ID_Autoshift=Shift_ID,@Shift_start_time_Autoshift=Shift_st_time from dbo.t0040_shift_master where cmp_id=@Cmp_id and isnull(inc_auto_shift,0)=1
			 --  and datediff(s,@In_Time_Autoshift,cast(CONVERT(VARCHAR(11), @In_Time_Autoshift, 121)  + CONVERT(VARCHAR(12), Shift_St_Time, 114) as datetime)) >-14400 and datediff(s,@In_Time_Autoshift,cast(CONVERT(VARCHAR(11), @In_Time_Autoshift, 121)  + CONVERT(VARCHAR(12), Shift_St_Time, 114) as datetime)) < 14400
				--if isnull(@Shift_ID_Autoshift,0) > 0 And isnull(@Shift_ID_Autoshift,0)<>isnull(@New_Shift_ID,0)
				--	Begin
				--		Update #Data set Shift_ID=@Shift_ID_Autoshift,Shift_Start_Time= cast(CONVERT(VARCHAR(11), In_time, 121)  + CONVERT(VARCHAR(12), @Shift_start_time_Autoshift, 114) as datetime)  from #Data
				--		where Emp_ID=@Emp_ID_AutoShift and In_time=@In_Time_Autoshift And Shift_ID <> @Shift_ID_Autoshift
						
				--	End
				--else
				--	Begin
				--	select @Shift_ID_Autoshift=Shift_ID,@Shift_start_time_Autoshift=Shift_st_time from t0040_shift_master where cmp_id=@Cmp_id and isnull(inc_auto_shift,0)=1
				--	and datediff(s,@In_Time_Autoshift,cast(CONVERT(VARCHAR(11), @In_Time_Autoshift, 121)  + CONVERT(VARCHAR(12), Shift_St_Time, 114) as datetime)) <14400

				--	if isnull(@Shift_ID_Autoshift,0) > 0
				--			Begin 
				--				Update #Data set Shift_ID=@Shift_ID_Autoshift,Shift_Start_Time= cast(CONVERT(VARCHAR(11), In_time, 121)  + CONVERT(VARCHAR(12), @Shift_start_time_Autoshift, 114) as datetime)  from #Data
				--				where Emp_ID=@Emp_ID_AutoShift and In_time=@In_Time_Autoshift And Shift_ID <> @Shift_ID_Autoshift
				--			End
				--	End
					
					
					
			fetch next from curautoshift into @Emp_ID_AutoShift,@In_Time_Autoshift,@Out_Time_Autoshift ,@New_Shift_ID
		      
		 end        
		 close curautoshift        
		 deallocate curautoshift  
		 
		 --PRINT 'CALC 9 :' + CONVERT(VARCHAR(20), GETDATE(), 114);  
		 Update #Data
			set OT_Start_Time=isnull(q.OT_Start_Time,0) ,
			OT_End_Time=isnull(q.OT_End_Time,0)	--Ankit 16112013
		 from #data d inner join 
			(select ST.Shift_st_time,ST.Shift_ID,isnull(SD.OT_Start_Time,0) as OT_Start_Time,isnull(SD.OT_End_Time,0) as OT_End_Time from dbo.t0040_shift_master ST  left outer join dbo.t0050_shift_detail SD 
			on ST.Shift_ID=SD.Shift_ID where St.Cmp_ID = @Cmp_ID ) q on d.shift_id=q.shift_id where isnull(d.shift_Change,0)=1
		  
		  
		 ---Commented by Hardik 29/11/2013 for Saudi Arabia, and Put this query in below Weekoff Cursor
		 --- Problem is, If Holiday or Weekoff than OT_Start_Time option should not deduct Early coming hours.
		 
		 --update #Data set Duration_in_sec = Duration_in_sec - datediff(s,In_time,Shift_Start_Time)
		 --where datediff(s,In_time,Shift_Start_Time) > 0  And isnull(Emp_OT,0)=1 And isnull(OT_Start_Time,0)=1
		 
		  --Update #Data    
		  --set Shift_ID = Q1.Shift_ID,    
		  -- Shift_Type = q1.Shift_type    
		  --from #Data d inner Join    
		  --(select sd.shift_ID ,sd.Emp_ID,isnull(shift_type,0)  shift_type,sd.For_Date from dbo.T0100_Emp_Shift_Detail sd   
		  --Where Cmp_ID =@Cmp_ID and isnull(shift_type,0)  =1 and For_Date >=@From_Date and For_Date <=@To_Date )q1 on    
		  --D.emp_ID = q1.For_Date And d.For_Date =Q1.For_Date 
	END
	

 CREATE TABLE #Emp_WeekOFf_Detail 
 (    
	  Emp_ID numeric    ,
	  StrWeekoff_Holiday varchar(max),
	  StrWeekoff varchar(max), --Hardik 07/09/2012  
	  StrHoliday varchar(max), --Hardik 07/09/2012  
	  strHalfday_Holiday varchar(max) -- Gadriwala 28082014 
 )  

INSERT INTO #Emp_WeekOFf_Detail 
SELECT	Emp_ID,IsNull(WeekOffDate,'') + IsNull(HolidayDate, '') , WeekOffDate, HolidayDate, HalfHolidayDate 
FROM #EMP_HW_CONS
--select Emp_ID,'','','','' from #Emp_Cons --Hardik 07/09/2012

--SELECT * FROM #EMP_HW_CONS



Delete D FROM #Emp_WeekOFf_Detail D Where not exists  (Select Emp_ID From #Data t where t.Emp_Id=D.Emp_ID) --Hardik 07/09/2012



Declare @Weekoff_Days Numeric(12,1)  
Declare @Cancel_Weekoff Numeric(12,1)  
Declare @Week_oF_Branch numeric(18,0)
Declare @tras_week_ot tinyint
Declare @Auto_OT tinyint
Declare @OT_Present tinyint
--Declare @Is_Compoff Numeric
Declare @Is_Cancel_Weekoff  Numeric(1,0) 
Declare @Is_WD Numeric
Declare @Is_WOHO Numeric
DECLARE	@Is_HO_CompOff NUMERIC			--Sid 24/02/2014
DECLARE	@Is_W_CompOff NUMERIC		

SET @OT_Present = 0

Declare @Emp_Week_Detail numeric(18,0)
Declare @strweekoff varchar(max)
/*

DECLARE curEmp_weekoff_Detail CURSOR FORWARD_ONLY FOR        
SELECT  Emp_ID FROM  #Emp_WeekOFf_Detail 
OPEN curEmp_weekoff_Detail        
FETCH NEXT FROM curEmp_weekoff_Detail INTO @Emp_Week_Detail
	WHILE @@fetch_status = 0        
		BEGIN        
			--Sid 24/02/2014
			SET @Is_Cancel_Weekoff = NULL	
			SET @Week_oF_Branch = NULL	
			SET @tras_week_ot = NULL	
			SET @Auto_OT = NULL	
			SET @OT_Present = NULL	
			SET @Is_Compoff = NULL	
			SET @Is_WD = NULL	
			SET @Is_WOHO = NULL	

			SET @Is_Cancel_Holiday = NULL	
			SET	@Is_HO_CompOff = NULL	
			SET	@Is_W_CompOff = NULL	

			set @StrWeekoff_Date=''
			set @Weekoff_Days=0
			set @Cancel_Weekoff=0
			
			--Hardik 07/09/2012
			Set @StrHoliday_Date =''
			Set @Holiday_days = 0
			Set @Cancel_Holiday =0
  
 
			SELECT	@Week_oF_Branch=Branch_ID  
			FROM	dbo.t0095_increment 
			WHERE	Increment_id in (select Max(Increment_id) from dbo.t0095_increment where emp_id=@Emp_Week_Detail)	-- Ankit 12092014 for Same Date Increment
	
 
 
			SELECT	@Is_Cancel_weekoff = Is_Cancel_weekoff ,@tras_week_ot=isnull(tras_week_ot,0)  ,@Auto_OT = Is_OT_Auto_Calc ,@OT_Present = OT_Present_days,@Is_Negative_Ot = ISNULL(Is_Negative_Ot,0), @Is_Compoff = ISNULL(Is_CompOff, 0), @Is_WD = ISNULL(Is_CompOff_WD,0), @Is_WOHO = ISNULL(Is_CompOff_WOHO,0)
					,@Is_Cancel_Holiday = Is_Cancel_Holiday --Hardik 07/09/2012
					,@Is_HO_CompOff = Is_HO_CompOff			--Sid 24/02/2014
					,@Is_W_CompOff = Is_W_CompOff			--Sid 24/02/2014
			From	dbo.T0040_GENERAL_SETTING where cmp_ID = @cmp_ID and Branch_ID = @Week_oF_Branch  
					and For_Date = ( select max(For_Date) from dbo.T0040_GENERAL_SETTING 
									where For_Date <=@To_Date and Branch_ID = @Week_oF_Branch and Cmp_ID = @Cmp_ID)  
	
			
			--Exec dbo.SP_EMP_HOLIDAY_DATE_GET @Emp_Week_Detail,@Cmp_ID,@From_Date,@To_Date,null,null,@Is_Cancel_Holiday,@StrHoliday_Date output,@Holiday_days output,@Cancel_Holiday output,1,@Branch_ID,@StrWeekoff_Date
			--Exec dbo.SP_EMP_WEEKOFF_DATE_GET @Emp_Week_Detail,@Cmp_ID,@From_Date,@To_Date,null,null,@Is_Cancel_weekoff,'',@StrWeekoff_Date output,@Weekoff_Days output ,@Cancel_Weekoff output  
		
			
		
			UPDATE	#Emp_WeekOFf_Detail 
			SET		StrWeekoff_Holiday=@StrWeekoff_Date + ';' + @StrHoliday_Date , --Hardik 07/09/2012
					StrHoliday = @StrHoliday_Date,StrWeekoff = @StrWeekoff_Date  --Hardik 07/09/2012					
			WHERE	Emp_ID=@Emp_Week_Detail --Hardik 07/09/2012
	
			SET	@HalfDay_Holiday = NULL
			SELECT	@HalfDay_Holiday = COALESCE(@HalfDay_Holiday + ';','') + CAST(FOR_DATE AS VARCHAR(11))
			FROM	(SELECT DISTINCT FOR_DATE FROM #Emp_Holiday WHERE	EMP_ID=@Emp_Week_Detail AND is_Half_day=1) T
							
			IF @HalfDay_Holiday IS NOT NULL
				UPDATE	#Emp_WeekOFf_Detail 
				SET		strHalfday_Holiday = @HalfDay_Holiday
				FROM	#Emp_WeekOFf_Detail 
				WHERE	Emp_ID=@Emp_Week_Detail 
			
	 
			if @Return_Record_set = 5
				Insert into #Data_Weekoff values(@Emp_Week_Detail,@Weekoff_Days)
			
			
			FETCH NEXT FROM curEmp_weekoff_Detail INTO @Emp_Week_Detail
		END        
	CLOSE curEmp_weekoff_Detail        
	DEALLOCATE curEmp_weekoff_Detail 
*/
	IF @Return_Record_set = 5
		BEGIN
			Insert into #Data_Weekoff  --values(@Emp_Week_Detail,@Weekoff_Days)
			SELECT E.Emp_ID, E.WeekOffCount From #EMP_HW_CONS E
		END	
		
	
	
	/* Commented by Nimesh on 03-Oct-2015 (Code added on above cursor for Half Holiday)
	Declare @Cur_Holiday_Emp_ID as numeric(18,0)
	Declare @Cur_Holiday_For_Date as datetime
	Declare @Cur_Holiday_is_Half_day as tinyint
	Declare @var_Holiday_Date as varchar(max)
	
	set @var_Holiday_Date = ''
	declare curHalfHolidayDate cursor for
	select Emp_Id,For_Date,is_Half_day from #Emp_Holiday WHERE is_Half_day=1
	
	Open curHalfHolidayDate
	fetch next from curHalfHolidayDate into @Cur_Holiday_Emp_ID,@Cur_Holiday_For_Date,@Cur_Holiday_is_Half_day
	while @@FETCH_STATUS = 0
		begin
		--if @Cur_Holiday_is_Half_day = 1	--Added condition in Cursor Select Query
		--begin					
				
				select @var_Holiday_Date= strHalfday_Holiday from #Emp_WeekOFf_Detail where Emp_ID = @Cur_Holiday_Emp_ID
				if @var_Holiday_Date = '' 
				begin
					Update 	#Emp_WeekOFf_Detail set strHalfday_Holiday =  cast(@Cur_Holiday_For_Date as varchar(25))
							where Emp_ID = @Cur_Holiday_Emp_ID
				end 
				else
				begin
						Update 	#Emp_WeekOFf_Detail set strHalfday_Holiday = strHalfday_Holiday + ';' + cast(@Cur_Holiday_For_Date as varchar(25))
							where Emp_ID = @Cur_Holiday_Emp_ID
				end
		--end 
		fetch next from curHalfHolidayDate into @Cur_Holiday_Emp_ID,@Cur_Holiday_For_Date,@Cur_Holiday_is_Half_day
	end
	Close curHalfHolidayDate
	Deallocate curHalfHolidayDate  
	*/
	
	/*Added following query by Nimesh on 30-Sep-2016 (Removed cursor from below to optimize the performance)*/
	
	UPDATE	D
	SET		Duration_in_sec = 0,
			--OT_Sec = dbo.F_Return_Without_Sec(T.OT_Sec + T.Duration_in_sec), -- Commeted By Sajid 20092023
			OT_Sec = dbo.F_Return_Without_Sec(T.Duration_in_sec), -- Added By Sajid 20092023
			P_Days = 0
	FROM	#DATA D 
			INNER JOIN (
						SELECT	D1.EMP_ID, FOR_DATE, OT_SEC, DURATION_IN_SEC
						FROM	#DATA D1 
								INNER JOIN #EMP_GEN_SETTINGS G ON D1.Emp_Id=G.EMP_ID  --Modified by by Chetan 050617 (WeeOff & Holiday Work was getting transfered to OT even not selecting option in general settings)
						WHERE	(	
									(
										NOT EXISTS(SELECT 1 FROM #EMP_HOLIDAY H1 WHERE D1.EMP_ID=H1.EMP_ID AND D1.FOR_DATE=H1.FOR_DATE AND H1.IS_CANCEL=0 AND H1.IS_HALF=1)								
										AND EXISTS(SELECT 1 FROM #EMP_HOLIDAY H1 WHERE D1.EMP_ID=H1.EMP_ID AND D1.FOR_DATE=H1.FOR_DATE AND H1.IS_CANCEL=0)
									)	OR	EXISTS(SELECT 1 FROM #EMP_WEEKOFF W1 
												 WHERE	D1.EMP_ID=W1.EMP_ID AND D1.FOR_DATE=W1.FOR_DATE 
															AND (W1.IS_CANCEL=0
																	OR EXISTS (SELECT 1 FROM T0100_WEEKOFF_ROSTER WR  WHERE WR.FOR_DATE = W1.For_Date AND WR.EMP_ID=W1.EMP_ID AND WR.is_Cancel_WO = 1)
																)
												  )		
								) AND G.Tras_Week_OT = 1
						) T ON D.EMP_ID=T.EMP_ID AND D.FOR_DATE=T.FOR_DATE
	WHERE	D.Emp_OT = 1		-- EMP OT Condition Added By Ramiz (05/12/2016) 
	
		--Select * From #Data		
	/*Commented by Nimesh on 30-Sep-2016 (Removed following cursor and added a single query above to optimize performance.)
	   
	DECLARE @For_date1 datetime 
	DECLARE @Duration_in_sec1 numeric    
  DECLARE @Emp_OT1  numeric   
  DECLARE @OT_Sec1  numeric 
 
 
	---Hardik 07/09/2012 for Weekoff1 Cursor
	DECLARE curweekoff1 CURSOR FAST_FORWARD FOR
	
	
	SELECT	DISTINCT E.Emp_Id,E.Branch_ID 
	FROM	#Emp_Cons E INNER JOIN T0040_GENERAL_SETTING G on E.Branch_ID=G.Branch_ID
			INNER JOIN #Data D ON E.Emp_ID=D.Emp_ID Inner join
			 ( 
							SELECT	MAX(For_Date) As For_Date , G1.Branch_ID FROM dbo.T0040_GENERAL_SETTING G1 
							INNER JOIN #Emp_Cons E1 ON G1.Branch_ID = E1.Branch_ID
							WHERE	For_Date <=@To_Date  and Cmp_ID = @Cmp_ID
							Group by G1.Branch_ID
						 ) qry on G.Branch_ID=Qry.Branch_ID and G.For_Date = Qry.For_Date
	Where	G.Cmp_ID = @Cmp_ID AND G.tras_week_ot = 1 AND D.Emp_OT = 1
	
	OPEN curweekoff1        
	FETCH NEXT FROM curweekoff1 INTO @Emp_Id_Temp1,@Week_oF_Branch
	WHILE @@FETCH_STATUS = 0        
		BEGIN   
			--Hardik 07/09/2012 for Weekoff 
			Declare @Weekoff_Date1 as varchar(max)
			Set @Weekoff_Date1 =''
			Declare @Half_Holiday_Date as varchar(max)
			set @Half_Holiday_Date = ''
			Declare @Weekoff_Date1_Cancel as varchar(max)
			Set @Weekoff_Date1_Cancel =''
			Declare @Holiday_Date1_Cancel as varchar(max)
			Set @Holiday_Date1_Cancel =''
			
			Select @Weekoff_Date1 = StrWeekoff_Holiday, @Half_Holiday_Date = strHalfday_Holiday from #Emp_WeekOFf_Detail where Emp_ID = @Emp_Id_Temp1
			
			/* Note : Cancel weekly off If Sandwich Policy and Employee Present on that day then its calculate Ovet Time 
				--CancelWeekOff/Holiday Added by Ankit 16122015 */
			DECLARE @Weekoff_Date1_CancelStr AS VARCHAR(MAX)
			SET @Weekoff_Date1_CancelStr = ''
			
			SELECT @Weekoff_Date1_CancelStr = ISNULL(CancelWeekOff,'')	+ ISNULL(CancelHoliday,'')
			FROM #EMP_HW_CONS
			WHERE Emp_ID = @Emp_Id_Temp1
			
			SELECT @Weekoff_Date1_Cancel = COALESCE ( @Weekoff_Date1_Cancel + ';', '') + DATA FROM dbo.Split(@Weekoff_Date1_CancelStr,';') 
			WHERE Data <> '' AND NOT EXISTS ( SELECT For_date FROM T0100_WEEKOFF_ROSTER WHERE Emp_id = @Emp_Id_Temp1 AND is_Cancel_WO = 1 AND For_date = CAST(DATA AS DATETIME ) )
			
			
			IF @Weekoff_Date1_Cancel <> ''
				SET @Weekoff_Date1 = @Weekoff_Date1 + ';' + @Weekoff_Date1_Cancel
			
			

			---Added by Hardik 29/11/2013 for Saudi Arabia, Copy this query from above side.		
			/* Commented by Nimesh on 30-Sep-2016 (OT Seconds already getting deducted from the Duration_in_Seconds so, no need to deduct it again.)
			update	#Data 
			set		Duration_in_sec = Duration_in_sec - datediff(s,In_time,Shift_Start_Time)
			where	datediff(s,In_time,Shift_Start_Time) > 0  And isnull(Emp_OT,0)=1 And isnull(OT_Start_Time,0)=1
					And For_date not In (Select Data from dbo.Split(@Weekoff_Date1,';') where Data <>'')
					And Emp_Id = @Emp_Id_Temp1 
			*/
			
			
			/*Commented by Nimesh on 19-Nov-2015 (Branch ID is taken in cursor Fetch status)
			SELECT	@Week_oF_Branch=Branch_ID  
			FROM	dbo.t0095_increment 
			WHERE	Increment_id in (
										SELECT	MAX(Increment_id) 
										FROM	dbo.t0095_increment 
										WHERE emp_id=@Emp_Id_Temp1
									)	-- Ankit 12092014 for Same Date Increment
			
			DECLARE @tras_week_ot1 AS TINYINT 
			SET @tras_week_ot1 = 0
			*/
 
			--SELECT	@tras_week_ot1=isnull(tras_week_ot,0)
			--FROM	dbo.T0040_GENERAL_SETTING where cmp_ID = @cmp_ID and Branch_ID = @Week_oF_Branch  
			--		and For_Date = ( 
			--							SELECT	MAX(For_Date) FROM dbo.T0040_GENERAL_SETTING 
			--							WHERE	For_Date <=@To_Date and Branch_ID = @Week_oF_Branch and Cmp_ID = @Cmp_ID
			--						)
			
			
			/*Commented by Nimesh on 30-Sep-2016 (Removed following cursor and added a single query above to optimize performance.)
			DECLARE curweekoff CURSOR FAST_FORWARD FOR
			SELECT	Duration_in_sec,For_date,Emp_OT,OT_Sec 
			FROM	#Data 
			WHERE	For_date In (SELECT Data FROM dbo.Split(@Weekoff_Date1,';')  WHERE Data <>'')
					And Emp_Id = @Emp_Id_Temp1  --Hardik 07/09/2012 Where condition
			ORDER BY For_date
						
			
			OPEN curweekoff        
			FETCH NEXT FROM curweekoff INTO @Duration_in_sec1,@For_date1,@Emp_OT1,@OT_Sec1
			WHILE @@FETCH_STATUS = 0        
				BEGIN
					--Commented by Nimesh on 19-Nov-2015 (Condition  added in Cursor Query to return only required employee records).
					--IF ISNULL(@Emp_OT1,0)=1 and @tras_week_ot1 = 1 
					--	BEGIN
							--Commented By Hardik 07/09/2012
							--Declare @Final_weekoff_str varchar(max)
							--set @Final_weekoff_str=''
							--select @Final_weekoff_str = isnull(Strweekoff,'') from #Emp_WeekOFf_Detail where emp_id=@Emp_Id_Temp1
							
							IF CHARINDEX(CAST(LEFT(@For_date1,11) AS VARCHAR),@Weekoff_Date1) >0
								BEGIN								
									UPDATE	#Data 
									SET		Duration_in_sec =0,Ot_sec=dbo.F_Return_Without_Sec(@OT_Sec1+@Duration_in_sec1),P_days=0 
									WHERE	Emp_Id=@Emp_Id_Temp1 and 
											For_date not in (
																SELECT Data FROM dbo.Split(@Half_Holiday_Date,';') 
																WHERE	Data <>'')
											And For_Date=@For_date1 --and OT_End_Time <>1
								End
						
						
						--END
					FETCH NEXT FROM curweekoff INTO @Duration_in_sec1,@For_date1,@Emp_OT1,@OT_Sec1
				END
			CLOSE curweekoff        
			DEALLOCATE curweekoff 

			*/

			FETCH NEXT FROM curweekoff1 INTO @Emp_Id_Temp1,@Week_oF_Branch
		END        
		CLOSE curweekoff1        
		DEALLOCATE curweekoff1

		*/


		----Add by Sid 21/05/2014 Ends 

		--If @First_In_Last_Out_For_InOut_Calculation = 1		--\\** Commented By Ramiz on 06/10/2015 , as even if it is Not First_In_Last_Out,
		--	Begin												--\\** then also Week-off Ot Should be calculated
--*****			
			--	if isnull(@Chk_otLimit_before_after_Shift_time,0) = 0 
			--	-- Commented By rohit on 21112014
			--	--begin
			--	--Update #Data Set OT_Sec = DATEDIFF(s,Shift_End_Time,OUT_Time) 
			--	-- Where OT_End_Time = 1 And OUT_Time >= Shift_End_Time And rWeekoff_OT_Sec = 0 And Holiday_OT_Sec = 0
			--	-- And isnull(Emp_OT,0)=1
				 
			--	--UPDATE	#Data
			--	--SET		OT_Sec = OT_Sec + DATEDIFF(s, In_Time, Shift_Start_Time) 
			--	--WHERE	OT_Start_Time = 0 AND In_Time <= Shift_Start_Time AND Weekoff_OT_Sec = 0 AND Holiday_OT_Sec = 0 AND ISNULL(Emp_OT,0) = 1
																		  
			
			--	--END
			--	BEGIN
				
			--	Update #Data Set OT_Sec = DATEDIFF(s,Shift_End_Time,OUT_Time) 
			--	 Where OT_End_Time = 1 And OUT_Time >= Shift_End_Time And Weekoff_OT_Sec = 0 And Holiday_OT_Sec = 0
			--	 And isnull(Emp_OT,0)=1 and DATEDIFF(s,Shift_End_Time,OUT_Time) > Emp_ot_min_limit

			--	UPDATE	#Data
			--	SET		OT_Sec = OT_Sec + DATEDIFF(s, In_Time, Shift_Start_Time) 
			--	WHERE	OT_Start_Time = 1 AND In_Time <= Shift_Start_Time AND Weekoff_OT_Sec = 0 AND Holiday_OT_Sec = 0 
			--	AND ISNULL(Emp_OT,0) = 1 and DATEDIFF(s, In_Time, Shift_Start_Time) > Emp_ot_min_limit

			--	END
			----End
 
 
 
	DECLARE @Emp_Id_Temp1 numeric
	Declare @Weekoff_Date1 as varchar(max)
	Declare @Half_Holiday_Date as varchar(max)
	Declare @Weekoff_Date1_Cancel as varchar(max)
	Declare @Holiday_Date1_Cancel as varchar(max)
	DECLARE @Weekoff_Date1_CancelStr AS VARCHAR(MAX)

	Declare @Shift_ID  numeric   
	Declare @From_Hour  numeric(12,3)    
	Declare @To_Hour  numeric(12,3)    
	Declare @Minimum_hour numeric(12,3)    
	Declare @Calculate_days numeric(12,3)    
	Declare @OT_applicable numeric(1)    
	Declare @Fix_OT_Hours numeric(12,3)    
	Declare @Shift_Dur  varchar(10)    
	Declare @Shift_Dur_sec numeric   
	Declare @Fix_W_Hours  numeric(5,2)    
	Declare @Ot_Sec_Neg Numeric(18,0)--Nikunj
   
	--Ankit 15112013
	Declare @DeduHour_SecondBreak as tinyint
	Declare @DeduHour_ThirdBreak as tinyint
	Declare @S_St_Time as varchar(10)  
	Declare @S_End_Time as varchar(10)   
	Declare @T_St_Time as varchar(10)  
	Declare @T_End_Time as varchar(10)   
	Declare @Second_Break_Duration as varchar(10)  
	Declare @Third_Break_Duration as varchar(10)
	declare @Second_Break_Duration_Sec as numeric  	
	declare @Third_Break_Duration_Sec as numeric 
	declare @HalfDayDate1 varchar(max)   	
	--Ankit 15112013    
  
 --PRINT 'CALC 10 :' + CONVERT(VARCHAR(20), GETDATE(), 114);
 --Added By Mukti 28112014(start) to deduct Break hours
 
 
	Declare Cur_Break cursor for   
	
	SELECT DISTINCT shift_id, DeduHour_SecondBreak,DeduHour_ThirdBreak,Shift_Dur,S_Duration,T_Duration,S_St_Time,T_St_Time 
	FROM	T0040_shift_master 
	WHERE	shift_id in (select distinct Shift_ID from #Data )


	  open Cur_Break   
	  fetch next from Cur_Break into @shift_ID,@DeduHour_SecondBreak,@DeduHour_ThirdBreak,@Shift_Dur,@Second_Break_Duration,@Third_Break_Duration,@S_St_Time,@T_St_Time
		  While @@Fetch_Status=0    
		 begin 
				exec GET_HalfDay_Date @Cmp_ID,@Emp_Id_Temp1,@From_Date,@To_Date,0,@HalfDayDate1 output
				select @Shift_Dur_sec = dbo.F_Return_Sec(@Shift_Dur)
			
				select @Second_Break_Duration_Sec = dbo.F_Return_Sec(@Second_Break_Duration)
				select @Third_Break_Duration_Sec = dbo.F_Return_Sec(@Third_Break_Duration)

			IF @DeduHour_SecondBreak = 1 And  @DeduHour_ThirdBreak = 1 
	 			Begin
	 		
	 				If @DeduHour_SecondBreak = 1 
						Begin
							Update #Data Set Duration_In_Sec = Duration_In_Sec - @Second_Break_Duration_Sec
				 			Where Shift_ID = @Shift_ID 
				 			And In_Time < cast(cast(In_Time as varchar(11)) + ' ' + @S_St_Time as smalldatetime) And OUT_Time > cast(cast(OUT_Time as varchar(11)) + ' ' + @S_St_Time as smalldatetime)
				 			And Duration_in_sec > 0 and For_Date not In (Select Data from dbo.Split(@HalfDayDate1,';') where DATA<>'') 
								
							-- For OT	
							
							Update #Data Set OT_Sec = OT_Sec - @Second_Break_Duration_Sec
				 			Where Shift_ID = @Shift_ID 
				 			And In_Time < cast(cast(In_Time as varchar(11)) + ' ' + @S_St_Time as smalldatetime) 
							And OUT_Time > cast(cast(OUT_Time as varchar(11)) + ' ' + @S_St_Time as smalldatetime)
				 			And Duration_in_sec = 0	And OT_Sec > 0	
				 			--and For_Date not In (Select Data from dbo.Split(@HalfDayDate1,';') where DATA<>'') 							 		
						End

					If @DeduHour_ThirdBreak = 1 
						Begin
							Update #Data Set Duration_In_Sec = Duration_In_Sec - @Third_Break_Duration_Sec
				 			Where Shift_ID = @Shift_ID  
				 			And In_Time < cast(cast(In_Time as varchar(11)) + ' ' + @T_St_Time as smalldatetime) And OUT_Time > cast(cast(OUT_Time as varchar(11)) + ' ' + @T_St_Time as smalldatetime)
				 			And Duration_in_sec > 0 and For_Date not In (Select Data from dbo.Split(@HalfDayDate1,';') where DATA<>'') 
				 			
				 			-- For OT
				 			Update #Data Set OT_Sec = OT_Sec - @Third_Break_Duration_Sec
				 			Where Shift_ID = @Shift_ID 
				 			And In_Time < cast(cast(In_Time as varchar(11)) + ' ' + @T_St_Time as smalldatetime) And OUT_Time > cast(cast(OUT_Time as varchar(11)) + ' ' + @T_St_Time as smalldatetime)
				 			And Duration_in_sec = 0 And OT_Sec > 0 
				 			--and For_Date not In (Select Data from dbo.Split(@HalfDayDate1,';') where DATA<>'')
						End
				End	
			Else IF @DeduHour_SecondBreak = 1
				Begin
					
					Update #Data Set Duration_In_Sec = Duration_In_Sec - 
															Case When @Second_Break_Duration_Sec >= Datediff(ss, cast(cast(For_Date as varchar(11)) + ' ' + @S_St_Time as smalldatetime),OUT_Time) Then
																Datediff(ss, cast(cast(For_Date as varchar(11)) + ' ' + @S_St_Time as smalldatetime),OUT_Time)
															Else @Second_Break_Duration_Sec End
		 			Where Shift_ID = @Shift_ID  
		 			And In_Time < cast(cast(For_Date as varchar(11)) + ' ' + @S_St_Time as smalldatetime) And OUT_Time > cast(cast(For_Date as varchar(11)) + ' ' + @S_St_Time as smalldatetime)
					And Duration_in_sec > 0 and For_Date not In (Select Data from dbo.Split(@HalfDayDate1,';') where DATA<>'') 

													
					---- For OT	
					--Update #Data Set OT_Sec = OT_Sec - @Second_Break_Duration_Sec
				 --	Where Shift_ID = @Shift_ID 
				 --	And In_Time < cast(cast(In_Time as varchar(11)) + ' ' + @S_St_Time as smalldatetime) And OUT_Time > cast(cast(OUT_Time as varchar(11)) + ' ' + @S_St_Time as smalldatetime)
				 --	And Duration_in_sec = 0	And OT_Sec > 0	
				End
			Else IF @DeduHour_ThirdBreak = 1 
				Begin
					Update #Data Set Duration_In_Sec = Duration_In_Sec - @Third_Break_Duration_Sec
		 			Where Shift_ID = @Shift_ID  
		 			And In_Time < cast(cast(In_Time as varchar(11)) + ' ' + @T_St_Time as smalldatetime) And OUT_Time > cast(cast(OUT_Time as varchar(11)) + ' ' + @T_St_Time as smalldatetime)
					And Duration_in_sec > 0 and For_Date not In (Select Data from dbo.Split(@HalfDayDate1,';') where DATA<>'') 
										
					-- For OT
					Update #Data Set OT_Sec = OT_Sec - @Third_Break_Duration_Sec
				 	Where Shift_ID = @Shift_ID 
				 	And In_Time < cast(cast(In_Time as varchar(11)) + ' ' + @T_St_Time as smalldatetime) And OUT_Time > cast(cast(OUT_Time as varchar(11)) + ' ' + @T_St_Time as smalldatetime)
				 	And Duration_in_sec = 0 And OT_Sec > 0 and For_Date not In (Select Data from dbo.Split(@HalfDayDate1,';') where DATA<>'')
				End		
			
			 fetch next from Cur_Break into @shift_ID,@DeduHour_SecondBreak,@DeduHour_ThirdBreak,@Shift_Dur,@Second_Break_Duration,@Third_Break_Duration,@S_St_Time,@T_St_Time
		  end    
	close Cur_Break   
	Deallocate Cur_Break 

 
 --Added By Mukti 28112014(end)
 --PRINT 'CALC 11 :' + CONVERT(VARCHAR(20), GETDATE(), 114);
 Declare @Is_Negative_Ot Int ---For negative yes or no take its value from general setting
 ---Added by Hardik 16/03/2015 for Bhashker (they have Grade Wise OT )
 Declare @OT_Applicable_Grade as tinyint
 set @OT_Applicable_Grade = 0
 --PRINT 'STATE 3 :' + CONVERT(VARCHAR(20), GETDATE(), 114);
 
 DECLARE @HalfWeekDay Varchar(12)
 DECLARE @HalfDayMinDur Varchar(8)
		
	select sd.Shift_ID ,From_Hour,To_Hour,Minimum_hour,Calculate_days,OT_applicable,Fix_OT_Hours   
		  ,Shift_Dur ,isnull(Fix_W_Hours,0) as  Fix_W_Hours,
		  DeduHour_SecondBreak,DeduHour_ThirdBreak, S_St_Time,S_End_Time,S_Duration, T_St_Time,T_End_Time,T_Duration , 
			CASE WHEN Is_Half_Day =1 THEN Week_Day Else '' END As HalfDay, Half_min_duration
	INTO	#Shift_Detail
	from dbo.T0050_shift_detail sd  inner join   
		  dbo.T0040_shift_master sm  on sd.shift_ID= sm.Shift_ID inner join   
		 (select distinct Shift_ID from #Data ) q on sm.shift_Id=  q.shift_ID    
		 order by sd.shift_Id,From_Hour  

	--select * from #Shift_Detail

	--PRINT 'STATE 4 :' + CONVERT(VARCHAR(20), GETDATE(), 114);
	-- Added by Gadriwala Muslim 28102015 - End
 	--PRINT 'CALC 12 :' + CONVERT(VARCHAR(20), GETDATE(), 114);
	CREATE TABLE #DATA_JOIN(EMP_ID NUMERIC, FOR_DATE DATETIME)

	INSERT INTO #DATA_JOIN SELECT EMP_ID, FOR_DATE FROM #Data
UPDATE_LATE_DAYS:
	IF OBJECT_ID('tempdb..#Extra_Exempted') IS NOT NULL
		BEGIN
			TRUNCATE TABLE #DATA_JOIN
			INSERT INTO #DATA_JOIN SELECT EMP_ID, FOR_DATE FROM #Extra_Exempted
		END

	-- Cliantha --			
	If Exists(Select 1 From T0140_LEAVE_TRANSACTION LT 
				Inner Join T0040_LEAVE_MASTER L  On LT.Leave_Id = L.Leave_ID And LT.Cmp_ID = L.Cmp_ID
				INNER Join #Data D On LT.Emp_Id = D.Emp_Id
				WHERE Isnull(L.Add_In_Working_Hour,0) = 1 And LT.Leave_Used > 0)
		BEGIN
			UPDATE D Set Duration_in_sec = Duration_in_sec + dbo.f_return_sec(Replace(LT.Leave_Used,'.',':'))
			From T0140_LEAVE_TRANSACTION LT 
				Inner Join T0040_LEAVE_MASTER L  On LT.Leave_Id = L.Leave_ID And LT.Cmp_ID = L.Cmp_ID
				INNER Join #Data D On LT.Emp_Id = D.Emp_Id And LT.For_Date = D.For_date
				WHERE Isnull(L.Add_In_Working_Hour,0) = 1 And LT.Leave_Used > 0
		
		END




	Declare Cur_shift cursor Fast_forward for   
		SELECT * FROM #Shift_Detail ORDER BY shift_Id, FROM_HOUR
	open cur_shift    
	  fetch next from cur_Shift into @shift_ID,@From_hour,@To_Hour,@Minimum_Hour,@Calculate_Days,@OT_Applicable,@Fix_OT_Hours,@Shift_Dur,@Fix_W_Hours
			,@DeduHour_SecondBreak ,@DeduHour_ThirdBreak ,@S_St_Time,@S_End_Time,@Second_Break_Duration,@T_St_Time,@T_End_Time,@Third_Break_Duration    
			,@HalfWeekDay,@HalfDayMinDur
		  While @@Fetch_Status=0    
		 begin     
		 
			select @Shift_Dur_sec = dbo.F_Return_Sec(@Shift_Dur) 
			select @Second_Break_Duration_Sec = dbo.F_Return_Sec(@Second_Break_Duration)
			select @Third_Break_Duration_Sec = dbo.F_Return_Sec(@Third_Break_Duration)

	
			 if @Fix_W_Hours > 0   
				 begin 
					
						Update D    
						set P_Days = @Calculate_Days, Duration_in_sec =  dbo.f_return_sec( replace(@Fix_W_Hours,'.',':'))   
						FROM #Data D LEFT OUTER JOIN #EMP_HW_CONS HW ON D.Emp_Id=HW.Emp_ID	
						INNER JOIN #EMP_GEN_SETTINGS G ON D.Emp_Id=G.EMP_ID --Checked Transfer WH Work to OT if setting applied in General Setting Otherwise it should considered as present day									--CHANGED FROM INNER JOIN TO LEFT OUTER BY RAMIZ ON 14/03/2017 (CONTINOUS ABSENT REPORT OF SAMARTH WAS COMING WRONG)
						Where	dbo.F_Return_Without_Sec(Duration_in_sec) >=dbo.f_return_sec( replace(@From_hour,'.',':')) 
								and dbo.F_Return_Without_Sec(Duration_in_sec) <= dbo.f_return_sec( replace(@To_Hour,'.',':'))    
								and Shift_ID= @shift_ID    and IO_Tran_Id  = 0 and chk_by_superior <> 1 -- Changed by rohit on 27122013	
								--and CHARINDEX(cast(d.For_date as varchar(11)),ISNULL(HW.WeekOffDate ,'')) < 1 --AND EMP_OT = 1 --Modified by Nimesh on 22-Jul-2016 ('00:00' From hours in Shift Master was creating issue on WeekOff OT Comp-Off)
								--and CHARINDEX(cast(d.For_date as varchar(11)),ISNULL(HW.HolidayDate ,'')) < 1
								--Modified following condition by Chetan on 05062017 (WeekOff & Holiday Work Transfer To OT Setting should be checked in following case)
								and (CASE WHEN G.Tras_Week_OT = 1 AND  CHARINDEX(cast(d.For_date as varchar(11)),REPLACE(ISNULL(HW.WeekOffDate ,''),ISNULL(HW.CancelWeekOff,''),'')) > 0 THEN 0 ELSE 1 END) = 1 --AND EMP_OT = 1 --Modified by Nimesh on 22-Jul-2016 ('00:00' From hours in Shift Master was creating issue on WeekOff OT Comp-Off)
								and (CASE WHEN G.Tras_Week_OT = 1 AND  CHARINDEX(cast(d.For_date as varchar(11)),REPLACE(ISNULL(HW.HolidayDate ,''),ISNULL(HW.CancelHoliday,''),'')) > 1 THEN 0 ELSE 1 END) = 1
								And (not In_Time is null or not OUT_Time is null) --added by Hardik 27/07/2016 for Single punch Present case where Attendance Regularise Applied, it is taking Full Present at GTPL
								AND EXISTS(SELECT 1 FROM #DATA_JOIN J WHERE D.EMP_ID=J.EMP_ID AND D.FOR_DATE=J.FOR_DATE)
					
				end    
			 else    
				begin    
					
					Update D    
					set P_Days = @Calculate_Days
					FROM #Data D LEFT OUTER JOIN #EMP_HW_CONS HW ON D.Emp_Id=HW.Emp_ID		--CHANGED FROM INNER JOIN TO LEFT OUTER BY RAMIZ ON 14/03/2017 (CONTINOUS ABSENT REPORT OF SAMARTH WAS COMING WRONG)		
					INNER JOIN #EMP_GEN_SETTINGS G ON D.Emp_Id=G.EMP_ID --Checked Transfer WH Work to OT if setting applied in General Setting Otherwise it should considered as present day
					Where dbo.F_Return_Without_Sec(Duration_in_sec) >= dbo.f_return_sec( replace(@From_hour,'.',':')) and dbo.F_Return_Without_Sec(Duration_in_sec) <= dbo.f_return_sec( replace(@To_Hour,'.',':'))   
							and Shift_ID= @shift_ID    and IO_Tran_Id  = 0 
							and chk_by_superior <> 1 -- Changed by rohit on 27122013
							--Modified following condition by Chetan on 05062017 (WeekOff & Holiday Work Transfer To OT Setting should be checked in following case)
							and (CASE WHEN G.Tras_Week_OT = 1 AND  CHARINDEX(cast(d.For_date as varchar(11)),REPLACE(ISNULL(HW.WeekOffDate ,''),ISNULL(HW.CancelWeekOff,''),'')) > 0 THEN 0 ELSE 1 END) = 1 --AND EMP_OT = 1 --Modified by Nimesh on 22-Jul-2016 ('00:00' From hours in Shift Master was creating issue on WeekOff OT Comp-Off)
							and (CASE WHEN G.Tras_Week_OT = 1 AND  CHARINDEX(cast(d.For_date as varchar(11)),REPLACE(ISNULL(HW.HolidayDate ,''),ISNULL(HW.CancelHoliday,''),'')) > 1 THEN 0 ELSE 1 END) = 1
							And (not In_Time is null or not OUT_Time is null) --added by Hardik 27/07/2016 for Single punch Present case where Attendance Regularise Applied, it is taking Full Present at GTPL
							AND EXISTS(SELECT 1 FROM #DATA_JOIN J WHERE D.EMP_ID=J.EMP_ID AND D.FOR_DATE=J.FOR_DATE)
				end  
				

				

			/*Added By Nimesh on 27-Feb-2019 (Tradebull : Half Day Shift (Minimum Half Day Duration) with Alternate WeekOff - Employee Present then it should consider Minimum Half Day Duration for Present Day Calculation*/		 
		  if IsNull(@HalfWeekDay,'') <> '' AND IsNull(@HalfDayMinDur, '') <> ''
				 begin    						
						UPDATE	D
						SET		P_Days = @Calculate_Days
						FROM	#Data D
						Where	dbo.F_Return_Without_Sec(Duration_in_sec) >= dbo.f_return_sec( replace(@HalfDayMinDur,'.',':')) 
								--and dbo.F_Return_Without_Sec(Duration_in_sec) <=dbo.f_return_sec( replace(@To_Hour,'.',':'))   
								and Shift_ID= @shift_ID and IO_Tran_Id  = 0  and chk_by_superior <> 1 -- CHanged by rohit on 27122013  
								And (not In_Time is null or not OUT_Time is null) --added by Hardik 27/07/2016 for Single punch Present case where Attendance Regularise Applied, it is taking Full Present at GTPL
								AND DateName(WEEKDAY, For_Date) = @HalfWeekDay
								AND EXISTS(SELECT 1 FROM #DATA_JOIN J WHERE D.EMP_ID=J.EMP_ID AND D.FOR_DATE=J.FOR_DATE)						
				 end   
	 
		 If @OT_Applicable = 1   
			begin    
				
				
			

			 if @Fix_OT_Hours > 0   
				 begin    
					
						UPDATE	D
						SET		P_Days = @Calculate_Days,    
								OT_Sec = dbo.f_return_sec( replace(@Fix_OT_Hours,'.',':')) 
						FROM	#Data D
						WHERE	dbo.F_Return_Without_Sec(Duration_in_sec) >=dbo.f_return_sec( replace(@From_hour,'.',':'))and dbo.F_Return_Without_Sec(Duration_in_sec) <=dbo.f_return_sec( replace(@To_Hour,'.',':'))   
								and Emp_OT= 1 and Shift_ID= @shift_ID  and IO_Tran_Id  = 0  and chk_by_superior <> 1 -- CHanged by rohit on 27122013
								And (not In_Time is null or not OUT_Time is null) --added by Hardik 27/07/2016 for Single punch Present case where Attendance Regularise Applied, it is taking Full Present at GTPL
								AND EXISTS(SELECT 1 FROM #DATA_JOIN J WHERE D.EMP_ID=J.EMP_ID AND D.FOR_DATE=J.FOR_DATE)
				 end    
				 else if @Minimum_Hour > 0   
				 begin    
						
						UPDATE	D
						SET		P_Days = @Calculate_Days,    
								OT_Sec = dbo.F_Return_Without_Sec(Duration_in_sec - dbo.f_return_sec( replace(@Minimum_Hour,'.',':'))) ,
								Duration_in_sec=  dbo.f_return_sec( replace(@Minimum_Hour,'.',':'))   
						FROM	#Data D
						Where	dbo.F_Return_Without_Sec(Duration_in_sec) >=dbo.f_return_sec( replace(@From_hour,'.',':')) and dbo.F_Return_Without_Sec(Duration_in_sec) <=dbo.f_return_sec( replace(@To_Hour,'.',':'))   
								and Emp_OT= 1 and Shift_ID= @shift_ID   and IO_Tran_Id  = 0  and chk_by_superior <> 1 -- CHanged by rohit on 27122013  
								And (not In_Time is null or not OUT_Time is null) --added by Hardik 27/07/2016 for Single punch Present case where Attendance Regularise Applied, it is taking Full Present at GTPL
								AND EXISTS(SELECT 1 FROM #DATA_JOIN J WHERE D.EMP_ID=J.EMP_ID AND D.FOR_DATE=J.FOR_DATE)
				 end    
				 else if @Minimum_Hour = 0   
					Begin    
						
						IF Isnull(@DeduHour_SecondBreak,0) = 1 -- Added by Hardik 10/12/2018 for Shoft shipyard client
							BEGIN
						
								Update	D    
								set		P_Days = @Calculate_Days,    
										OT_Sec = dbo.F_Return_Without_Sec(Duration_in_sec - (@Shift_Dur_sec - IsNull(Second_Break.Second_Break_Duration_Sec,0)))
								from	#Data D 
										LEFT OUTER JOIN 
											(Select Emp_Id,For_date, @Second_Break_Duration_Sec As Second_Break_Duration_Sec
											from #Data Where Shift_ID = @Shift_ID  
		 										And In_Time < cast(cast(In_Time as varchar(11)) + ' ' + @S_St_Time as smalldatetime) 
		 										And OUT_Time > cast(cast(OUT_Time as varchar(11)) + ' ' + @S_St_Time as smalldatetime)
												And Duration_in_sec > 0 
												and For_Date not In (Select Data from dbo.Split(@HalfDayDate1,';') where DATA<>'')) Second_Break ON D.Emp_Id = Second_Break.Emp_Id And D.For_date = Second_Break.For_date
								Where	dbo.F_Return_Without_Sec(Duration_in_sec) >=dbo.f_return_sec( replace(@From_hour,'.',':')) and dbo.F_Return_Without_Sec(Duration_in_sec) <=dbo.f_return_sec( replace(@To_Hour,'.',':'))    
										and Emp_OT= 1 and dbo.F_Return_Without_Sec(Duration_in_sec) > @Shift_Dur_sec - IsNull(Second_Break.Second_Break_Duration_Sec,0)    
										and Shift_ID= @shift_ID and IO_Tran_Id  = 0 
										AND EXISTS(SELECT 1 FROM #DATA_JOIN J WHERE D.EMP_ID=J.EMP_ID AND D.FOR_DATE=J.FOR_DATE)

								Update	D        
								set		P_Days = @Calculate_Days,        
										OT_Sec = dbo.F_Return_Without_Sec(OT_Sec - (IsNull(Second_Break.Second_Break_Duration_Sec,0)))
								from	#Data D 
										LEFT OUTER JOIN 
											(Select Emp_Id,For_date, @Second_Break_Duration_Sec As Second_Break_Duration_Sec
											from #Data Where Shift_ID = @Shift_ID  
		 										And In_Time < cast(cast(In_Time as varchar(11)) + ' ' + @S_St_Time as smalldatetime) 
		 										And OUT_Time > cast(cast(OUT_Time as varchar(11)) + ' ' + @S_St_Time as smalldatetime)
												And (Duration_in_sec > 0 or OT_Sec > 0)
												and For_Date not In (Select Data from dbo.Split(@HalfDayDate1,';') where DATA<>'')) Second_Break ON D.Emp_Id = Second_Break.Emp_Id And D.For_date = Second_Break.For_date
								Where	dbo.F_Return_Without_Sec(OT_Sec) >=dbo.f_return_sec( replace(@From_hour,'.',':')) and dbo.F_Return_Without_Sec(OT_Sec) <=dbo.f_return_sec( replace(@To_Hour,'.',':'))        
										and Emp_OT= 1 and dbo.F_Return_Without_Sec(OT_Sec) > @Shift_Dur_sec - IsNull(Second_Break.Second_Break_Duration_Sec,0)        
										and Shift_ID= @shift_ID and IO_Tran_Id  = 0 
										AND EXISTS(SELECT 1 FROM #DATA_JOIN J WHERE D.EMP_ID=J.EMP_ID AND D.FOR_DATE=J.FOR_DATE)
							END
						ELSE IF Isnull(@DeduHour_ThirdBreak,0) = 1 -- Added by Hardik 10/12/2018 for Shoft shipyard client
							BEGIN
							
								Update	D    
								set		P_Days = @Calculate_Days,    
										OT_Sec = dbo.F_Return_Without_Sec(Duration_in_sec - (@Shift_Dur_sec - IsNull(Third_Break.Third_Break_Duration_Sec,0)))
								from	#Data D 
										LEFT OUTER JOIN 
											(Select Emp_Id,For_date, @Third_Break_Duration_Sec As Third_Break_Duration_Sec
											from #Data Where Shift_ID = @Shift_ID  
		 										And In_Time < cast(cast(In_Time as varchar(11)) + ' ' + @T_St_Time as smalldatetime) 
		 										And OUT_Time > cast(cast(OUT_Time as varchar(11)) + ' ' + @T_St_Time as smalldatetime)
												And Duration_in_sec > 0 
												and For_Date not In (Select Data from dbo.Split(@HalfDayDate1,';') where DATA<>'')) Third_Break ON D.Emp_Id = Third_Break.Emp_Id And D.For_date = Third_Break.For_date
								Where	dbo.F_Return_Without_Sec(Duration_in_sec) >=dbo.f_return_sec( replace(@From_hour,'.',':')) and dbo.F_Return_Without_Sec(Duration_in_sec) <=dbo.f_return_sec( replace(@To_Hour,'.',':'))    
										and Emp_OT= 1 and dbo.F_Return_Without_Sec(Duration_in_sec) > @Shift_Dur_sec - IsNull(Third_Break.Third_Break_Duration_Sec,0)    
										and Shift_ID= @shift_ID and IO_Tran_Id  = 0 
										AND EXISTS(SELECT 1 FROM #DATA_JOIN J WHERE D.EMP_ID=J.EMP_ID AND D.FOR_DATE=J.FOR_DATE)
							END
						ELSE
							BEGIN
								
									--if @Calculate_days = 1
									--	 select  @From_hour,@To_Hour,
									--	 dbo.F_Return_Without_Sec(Duration_in_sec)
									--	 ,dbo.f_return_sec( replace(@From_hour,'.',':'))
									--	 ,dbo.f_return_sec( replace(@To_Hour,'.',':')) 
									--	 ,@Calculate_Days,    
									--		 dbo.F_Return_Without_Sec(Duration_in_sec - @Shift_Dur_sec),P_Days,OT_Sec,*
									--	from	#Data D
									--	Where	dbo.F_Return_Without_Sec(Duration_in_sec) >=dbo.f_return_sec( replace(@From_hour,'.',':'))
									--	and Emp_OT= 1 and dbo.F_Return_Without_Sec(Duration_in_sec) > @Shift_Dur_sec    
									--	and Shift_ID= @shift_ID  and IO_Tran_Id  = 0 
									--	AND EXISTS(SELECT 1 FROM #DATA_JOIN J WHERE D.EMP_ID=J.EMP_ID AND D.FOR_DATE=J.FOR_DATE)
									--	AND OT_Start_Time=0 AND OT_End_Time=0 AND Working_Hrs_St_Time=0 AND Working_Hrs_End_Time=0 -- Added By Sajid 19-09-2023

								Update	D    
								set		P_Days = @Calculate_Days,    
										OT_Sec = dbo.F_Return_Without_Sec(Duration_in_sec - @Shift_Dur_sec)
								from	#Data D
								Where	dbo.F_Return_Without_Sec(Duration_in_sec) >=dbo.f_return_sec( replace(@From_hour,'.',':')) 
								        --and dbo.F_Return_Without_Sec(Duration_in_sec) <=dbo.f_return_sec( replace(@To_Hour,'.',':')) --   Comment by ronakk 24012023  for Redmine Bug #27512   
										and Emp_OT= 1 and dbo.F_Return_Without_Sec(Duration_in_sec) > @Shift_Dur_sec    
										and Shift_ID= @shift_ID  and IO_Tran_Id  = 0 
										AND EXISTS(SELECT 1 FROM #DATA_JOIN J WHERE D.EMP_ID=J.EMP_ID AND D.FOR_DATE=J.FOR_DATE)
										AND OT_Start_Time=0 AND OT_End_Time=0 AND Working_Hrs_St_Time=0 AND Working_Hrs_End_Time=0 -- Added By Sajid 19-09-2023
								
							END	
							
							
						Select	@Ot_Sec_Neg=Isnull(Ot_Sec,0)From #Data D
						Where	OT_Sec < 1--Nikunj
								AND EXISTS(SELECT 1 FROM #DATA_JOIN J WHERE D.EMP_ID=J.EMP_ID AND D.FOR_DATE=J.FOR_DATE)

						If	@Ot_Sec_Neg < 1 And Isnull(@Is_Negative_Ot,0)=1--And Duration_In_sec < @Shift_Dur_sec --logic Of Negative ot			
							Begin					
								UPDATE	D				
								SET		OT_Sec = dbo.F_Return_Without_Sec(@Shift_Dur_sec - Duration_in_sec),Flag=1
								FROM	#Data D
								WHERE	Ot_Sec < 1 And dbo.F_Return_Without_Sec(Duration_In_sec) < @Shift_Dur_sec And Shift_Id = @Shift_Id And Emp_OT= 1
								
										AND EXISTS(SELECT 1 FROM #DATA_JOIN J WHERE D.EMP_ID=J.EMP_ID AND D.FOR_DATE=J.FOR_DATE)
							End  
					  
					  
					 end      
					 
					if isnull(@Report_For,'') = 'ABSENT_CON'
					begin						
						Update	D    
								set		P_Days = 1,    
										OT_Sec = dbo.F_Return_Without_Sec(Duration_in_sec - @Shift_Dur_sec)
								from	#Data D
								Where	Emp_OT= 1 and Shift_ID= @shift_ID  and IO_Tran_Id  = 0 and Chk_By_Superior <> 1
										AND EXISTS(SELECT 1 FROM #DATA_JOIN J WHERE D.EMP_ID=J.EMP_ID AND D.FOR_DATE=J.FOR_DATE)
										And (not In_Time is null or not OUT_Time is null)
						
					end
			end    
		  fetch next from cur_Shift into @shift_ID,@From_hour,@To_Hour,@Minimum_Hour,@Calculate_Days,@OT_Applicable,@Fix_OT_Hours,@Shift_Dur,@Fix_W_Hours,
				@DeduHour_SecondBreak ,@DeduHour_ThirdBreak ,@S_St_Time,@S_End_Time,@Second_Break_Duration,@T_St_Time,@T_End_Time,@Third_Break_Duration   
				,@HalfWeekDay,@HalfDayMinDur
		  end    
	close cur_Shift    
	Deallocate Cur_Shift   
	
	-- New Month Logic Of Gallpos Client Deepal Date :- 30-04-24
	if @MonthExemptLimitInSec > 0 and @LateEarly_MonthWise = 1 and @IsDeficit = 0
	BEGIN
		exec MonthLimitLateExemption @CMP_ID , @MonthExemptLimitInSec
	END
	
	IF @MonthExemptLimitInSec > 0 and @LateEarly_MonthWise = 0 and @IsDeficit = 1
	BEGIN
		exec MonthLimitIsDeficitOrNot @CMP_ID,@MonthExemptLimitInSec
	END
	
	-- New Month Logic Of Gallpos Client Deepal Date :- 30-04-24
	-- Added by Gadriwala Muslim 28102015 - Start
 
 DECLARE @LateEarly_Exemption_MaxLimit VARCHAR(10)
 DECLARE @LateEarly_Exemption_Count NUMERIC
 DECLARE @LateEarly_Exemption_Constraint VARCHAR(MAX)
 
 SET @LateEarly_Exemption_MaxLimit = '00:00'
 SET @LateEarly_Exemption_Count = 0
 
	SELECT	@LateEarly_Exemption_MaxLimit = IsNull(LateEarly_Exemption_MaxLimit, @LateEarly_Exemption_MaxLimit),
			@LateEarly_Exemption_Count = IsNull(LateEarly_Exemption_Count,@LateEarly_Exemption_Count),
			@LateEarly_Exemption_Constraint = COALESCE(@LateEarly_Exemption_Constraint + '#', '') +  CAST(EMP_ID AS VARCHAR(5))
	FROM	dbo.T0040_GENERAL_SETTING G 
			INNER JOIN (SELECT	MAX(FOR_DATE) AS FOR_DATE, G1.BRANCH_ID 
						FROM	dbo.T0040_GENERAL_SETTING G1 
								INNER JOIN #EMP_CONS E ON G1.BRANCH_ID=E.BRANCH_ID
						GROUP BY G1.BRANCH_ID) G1 ON G.FOR_DATE=G1.FOR_DATE AND G.BRANCH_ID=G1.BRANCH_ID
			INNER JOIN #EMP_CONS E ON G.Branch_ID=E.Branch_ID
	WHERE	LateEarly_Exemption_MaxLimit <> '00:00' AND LateEarly_Exemption_Count <> 0

	
	
	IF ISNULL(@LateEarly_Exemption_MaxLimit,'00:00') <> '00:00' AND @LateEarly_Exemption_Count <> 0 
		AND @Late_SP = 0 AND @LateEarly_Exemption_Constraint IS NOT NULL
		AND OBJECT_ID('tempdb..#Extra_Exempted') IS NULL
		BEGIN

			Create Table #Extra_Exempted
			(
				Emp_ID numeric(18,0),
				For_Date datetime,
				Extra_Exempted_Sec numeric(18,0) default 0,
				Extra_Exempted tinyint default 0
			)
			
			exec rpt_Late_Early_Mark_Deduction_Details @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID
			,@LateEarly_Exemption_Constraint,'Extra-Exempted',0,1,1
			
			UPDATE	#Data  
			SET		Duration_in_sec = (Duration_in_sec + Extra_Exempted_Sec) 
			FROM	#Data DA 
					inner join #Extra_Exempted EE on DA.Emp_Id = EE.Emp_ID and DA.For_date = EE.For_Date
					INNER JOIN dbo.Split(@LateEarly_Exemption_Constraint, '#') T ON DA.Emp_Id = Cast(T.Data as Numeric)
			
			GOTO UPDATE_LATE_DAYS
		END
		
--PRINT 'CALC 13 :' + CONVERT(VARCHAR(20), GETDATE(), 114);


--PRINT 'CALC 14 :' + CONVERT(VARCHAR(20), GETDATE(), 114);
	
	declare @ShiftId numeric
	declare @WeekDay varchar(10)
	declare @HalfStartTime varchar(10)
	declare @HalfEndTime varchar(10)
	declare @HalfDuration varchar(10)
	declare @HalfDayDate varchar(max)
	declare @curForDate datetime
	declare @HalfMinDuration varchar(10)

	
		--------------------Added by Mitesh on 15/09/2011 for Shift Half Day ----------------------------
	--PRINT 'CALC 15 :' + CONVERT(VARCHAR(20), GETDATE(), 114);
 ---Hardik 07/09/2012 for Weekoff1 Cursor
	declare curweekoff1 cursor Fast_forward for        
		select DISTINCT Emp_Id from #Emp_Cons
	open curweekoff1        
	fetch next from curweekoff1 into @Emp_Id_Temp1
	while @@fetch_status = 0        
	begin  
	
			exec dbo.GET_HalfDay_Date @Cmp_ID,@Emp_Id_Temp1,@From_Date,@To_Date,0,@HalfDayDate output
			
			IF IsNUll(@HalfDayDate,'') <> ''
				BEGIN 					
					select @ShiftId=SM.Shift_id,@WeekDay=SM.Week_Day,@HalfStartTime=SM.Half_St_Time,@HalfEndTime=SM.Half_End_Time,@HalfDuration=SM.Half_Dur,@HalfMinDuration=SM.Half_min_duration from dbo.T0040_SHIFT_MASTER SM inner join   
							 (select distinct Shift_ID from #Data where Emp_Id = @Emp_Id_Temp1) q on SM.Shift_ID =  q.shift_ID    
							where Is_Half_Day = 1 
					
					
					declare cur_shift_half_day cursor Fast_forward for
					Select	For_date 
					from #Data D
					Where	Emp_Id = @Emp_Id_Temp1 
							AND EXISTS (SELECT 1 FROM dbo.Split(@HalfDayDate,';') WHERE DATA <> '' AND CAST(DATA AS DATETIME) = D.For_date) --Hardik 07/09/2012 Where Condition
							AND NOT EXISTS(SELECT 1 FROM #EMP_HOLIDAY H WHERE D.For_date=H.FOR_DATE AND H.IS_CANCEL=0 AND D.Emp_Id=H.EMP_ID)
							AND NOT EXISTS(SELECT 1 FROM #EMP_WEEKOFF W WHERE D.For_date=W.FOR_DATE AND W.IS_CANCEL=0 AND D.Emp_Id=W.EMP_ID)
					OPEN cur_shift_half_day    
					fetch next from cur_shift_half_day into @curForDate
					  While @@Fetch_Status=0    
						 BEGIN
								
								if(charindex(CONVERT(nvarchar(11),@curForDate,109),@HalfDayDate) > 0)
									begin			
									
										-- Comment by rohit for week of regularization not calculate in present if Week off Work transfer to ot on 12082013
											update #Data 
											set P_days = 1 , in_time = convert(varchar(11),d.For_date,120) + @HalfStartTime,out_time = convert(varchar(11),d.For_date,120) + @HalfEndTime,duration_in_sec = dbo.F_Return_Sec(@HalfMinDuration)  
											from #Data d inner join  dbo.T0150_EMP_INOUT_RECORD TEIR 
											on TEIR.Emp_Id = d.Emp_Id and TEIR.Chk_By_Superior = 1 and TEIR.For_Date = d.For_date and TEIR.Half_Full_day = 'Full Day' 
											where TEIR.For_Date = @curForDate  and d.IO_Tran_Id  = 0 and TEIR.emp_id = @Emp_Id_Temp1
											 and not EXISTS(select 1 from #Emp_WeekOff W Where d.For_date=W.For_Date AND d.Emp_Id=W.Emp_ID AND W.Is_Cancel =0)
										-- Ended by rohit on 12082013	
		 
										
										update #Data  set
											Shift_Start_Time = convert(varchar(11),@curForDate,120) + @HalfStartTime,						
											Shift_End_Time = convert(varchar(11),@curForDate,120) + @HalfEndTime
											where For_date = @curForDate and IO_Tran_Id  = 0 And Emp_Id = @Emp_Id_Temp1 
										
																	
										UPDATE	#Data  
										SET		P_days = 1
										WHERE	For_date = @curForDate and Duration_in_sec >= dbo.F_Return_Sec(@HalfMinDuration) 
													and IO_Tran_Id  = 0 And Emp_Id = @Emp_Id_Temp1
											


										update #Data  set
											P_days = 0
											where For_date = @curForDate and Duration_in_sec < dbo.F_Return_Sec(@HalfMinDuration) and IO_Tran_Id  = 0 And Emp_Id = @Emp_Id_Temp1

												
										Update #Data    
										 set OT_Sec = 
										 dbo.F_Return_Without_Sec(case when dbo.F_Return_Sec(@HalfMinDuration) > Duration_in_sec then
											dbo.F_Return_Sec(@HalfMinDuration) - Duration_in_sec   
										 Else
											Duration_in_sec - dbo.F_Return_Sec(@HalfMinDuration)  
										 End )
										 Where Duration_in_sec >=dbo.F_Return_Sec(@HalfMinDuration)
										 and Emp_OT= 1 and For_date = @curForDate And Emp_Id = @Emp_Id_Temp1
											
										 
								 			-- Added by rohit for week of regularization not calculate in present if Week off Work transfer to OT on 12082013

								 			update #Data 
											set P_days = 0.5,in_time = convert(varchar(11),d.For_date,120) + @HalfStartTime,out_time = (convert(varchar(11),d.For_date,120) + dbo.F_Return_Hours(dbo.F_Return_Sec(@HalfStartTime) + (dbo.F_Return_Sec(@HalfMinDuration))/2)),duration_in_sec = dbo.F_Return_Sec(@HalfMinDuration)/2 
											from #Data d inner join  dbo.T0150_EMP_INOUT_RECORD TEIR 
											on TEIR.Emp_Id = d.Emp_Id and TEIR.Chk_By_Superior = 1 and TEIR.For_Date = d.For_date and ( TEIR.Half_Full_day = 'First Half')
											where TEIR.For_Date = @curForDate and d.IO_Tran_Id  = 0 and TEIR.emp_id = @Emp_Id_Temp1
											
											update #Data 
											set P_days = 0.5,in_time = (convert(varchar(11),d.For_date,120) + dbo.F_Return_Hours(dbo.F_Return_Sec(@HalfStartTime) + (dbo.F_Return_Sec(@HalfMinDuration))/2)),out_time = convert(varchar(11),d.For_date,120) + @HalfEndTime ,duration_in_sec = dbo.F_Return_Sec(@HalfMinDuration)/2 
											from #Data d inner join  dbo.T0150_EMP_INOUT_RECORD TEIR 
											on TEIR.Emp_Id = d.Emp_Id and TEIR.Chk_By_Superior = 1 and TEIR.For_Date = d.For_date and ( TEIR.Half_Full_day = 'Second Half')
											where TEIR.For_Date = @curForDate and d.IO_Tran_Id  = 0  and TEIR.emp_id = @Emp_Id_Temp1
											--Ended by rohit 12082013
											
									end
						 fetch next from cur_shift_half_day into @curForDate
						END
						 
					close cur_shift_half_day    
					Deallocate cur_shift_half_day  	 
				END

			fetch next from curweekoff1 into @Emp_Id_Temp1
		end        
 close curweekoff1        
 deallocate curweekoff1 
 
 	
 --PRINT 'CALC 16 :' + CONVERT(VARCHAR(20), GETDATE(), 114);	 
	---- start below update statment added by mitesh for regularization as only full day on 09/01/2012.
	
	-- Comment by rohit for  week of regularization not calculate in present if Week off Work Transfer to OT on 12082013
	--update #Data 
	--set P_days = 1 from #Data d inner join  dbo.T0150_EMP_INOUT_RECORD TEIR 
	--on TEIR.Emp_Id = d.Emp_Id and TEIR.Chk_By_Superior = 1 and TEIR.For_Date = d.For_date and TEIR.Half_Full_day = 'Full Day' 
	--where TEIR.For_Date >= @From_Date and TEIR.For_Date <= @To_Date and d.IO_Tran_Id  = 0 
	
	
	--update #Data 
	--set P_days = 0.5 from #Data d inner join  dbo.T0150_EMP_INOUT_RECORD TEIR 
	--on TEIR.Emp_Id = d.Emp_Id and TEIR.Chk_By_Superior = 1 and TEIR.For_Date = d.For_date and ( TEIR.Half_Full_day = 'First Half' or TEIR.Half_Full_day = 'Second Half')
	--where TEIR.For_Date >= @From_Date and TEIR.For_Date <= @To_Date and d.IO_Tran_Id  = 0 
	 --Comment end by rohit 12082013
	
	-- Changed by Gadriwala Muslim 01012015 - Start
	if @Call_For_Leave_Cancel <> 1  --Added by Jaina 05-08-2016
	BEGIN
		/*Modified following query by Nimesh on 10-Jan-2019 (If employee takes two half day leaves (CompOff and PL) andalso present for full day then leave should be deducted from present days) - Competant*/
		update dbo.#Data  -- For Regular Leave
		set P_days = (P_days - Leave_Used) from #Data d 
		inner join  (SELECT For_Date,Emp_ID, Sum(Leave_Used) As Leave_Used 
					FROM	(
								select	For_Date,Emp_ID, Sum(Leave_Used) As Leave_Used 
								from	dbo.T0140_LEAVE_TRANSACTION LT 
										Inner join dbo.T0040_LEAVE_MASTER LM on  LT.Leave_ID = LM.Leave_ID and isnull(LM.Default_Short_Name,'') <> 'COMP'
								where	leave_used = 0.5 and LT.Cmp_Id = @Cmp_Id And	-- Changed By Gadriwala Muslim 02102014
										For_Date >= @From_Date and 
										For_Date <= @To_Date and (isnull(eff_in_salary,0) <> 1 or (isnull(eff_in_salary,0) = 1 and Leave_Used > 0 )	)
										And Isnull(LM.Add_In_Working_Hour,0) = 0  --cliantha
								Group By For_Date,Emp_ID
								UNION ALL
								SELECT	For_Date,Emp_ID, Sum(CompOff_Used) As Leave_Used 
								FROM	dbo.T0140_LEAVE_TRANSACTION LT 
										INNER JOIN dbo.T0040_LEAVE_MASTER LM on  LT.Leave_ID = LM.Leave_ID and isnull(LM.Default_Short_Name,'') ='COMP'
								WHERE	(CompOff_Used - Leave_Encash_Days) = 0.5 and -- Changed By Gadriwala Muslim 02102014
										For_Date >= @From_Date and  For_Date <= @To_Date 
										and (isnull(eff_in_salary,0) <> 1 and LT.Cmp_Id = @Cmp_Id or (isnull(eff_in_salary,0) = 1 and (CompOff_Used - Leave_Encash_Days) > 0))
										And Isnull(LM.Add_In_Working_Hour,0) = 0  --cliantha
								Group By For_Date,Emp_ID
							) T
					Group By For_Date,Emp_ID
					) Qry on 
					Qry.For_Date = d.For_date and Qry.Emp_ID = d.Emp_Id where  IO_Tran_Id  = 0 and P_days =1
	END
	-- Changed by Gadriwala Muslim 01012015 - End
	-- Comment and Added by rohit on 08092014
	--Alpesh 06-Jul-2012 -> If Leave is paid then count as Leave, Not as Present 			 
	--update dbo.#Data 
	--set P_days = 0 from #Data d inner join  
	--	(select For_Date,Emp_ID from dbo.T0140_LEAVE_TRANSACTION lt inner join dbo.T0040_LEAVE_MASTER lm on lm.Leave_ID=lt.Leave_ID
	--	 where leave_used = 1 and For_Date >= @From_Date and For_Date <= @To_Date and lm.Leave_Paid_Unpaid='P') Qry 
	--	 on Qry.For_Date = d.For_date and Qry.Emp_ID = d.Emp_Id where IO_Tran_Id  = 0
	---- End ----
	---- end below update statment added by mitesh for regularization as only full day on 09/01/2012.
 
 


	--Deepal 03042022
	--update D set d.P_days = 0 
	--from #DATA D inner join  T0150_EMP_INOUT_RECORD T  on T.Emp_ID = d.Emp_Id and (t.In_Date_Time = d.In_Time and t.Out_Date_Time = d.Out_time or  
	--t.In_Time = d.In_Time and t.Out_Time = d.Out_time)
	--where t.Chk_By_Superior = 2

	
	
	--update D set d.P_days = 0 ,Duration_in_sec = case when isnull(t.Duration,'') = '' then 0 else dbo.F_Return_Sec(t.Duration) end ,OT_Sec = (case when isnull(T.Out_Date_Time,'') =  '' or isnull(t.Out_Time,'') = '' then 0 else OT_Sec end)
	--from #DATA D inner join  T0150_EMP_INOUT_RECORD T  on T.Emp_ID = d.Emp_Id 
	--and (t.In_Date_Time = d.In_Time and t.Out_Date_Time = d.Out_time or t.In_Time = d.In_Time and t.Out_Time = d.Out_time)
	--where t.Chk_By_Superior = 0 and (Reason <> '' or Other_Reason <> '')
	--and P_days > 0

	--select P_days,Duration_in_sec, * from #DATA where For_date ='2024-01-02 00:00:00.000'

 
	-- Changed by Gadriwala Muslim 01012015 - Start
	IF @CALL_FOR_LEAVE_CANCEL <> 1  --Added By Jaina 05-08-2016
	BEGIN
		update #Data  -- For Regular Leave
		set P_days = case when (1 - lt.leave_used) < 0 then 0 else (1 - lt.leave_used) end
		from #Data d
		left outer join (select emp_id,for_date,sum(case when lm.Apply_hourly = 0 then lt.leave_used else case when (lt.leave_used *0.125)>1 then 1 else (lt.leave_used *0.125) end  end)  as Leave_Used 
		from T0140_LEAVE_TRANSACTION lt 
			inner join T0040_LEAVE_MASTER lm  on lt.Leave_ID = lm.Leave_ID and isnull(lm.Default_Short_Name,'') <> 'COMP' And Isnull(LM.Add_In_Working_Hour,0) = 0  --cliantha
		where For_Date between @From_Date and @To_Date and lt.Cmp_ID=@Cmp_id
		group by Emp_ID,For_Date) as lt on
		d.emp_id = lt.emp_ID and d.for_date = lt.for_date
		Where d.P_days + lt.leave_used > 1
	 
		update #Data -- For CompOFf Leave 
		set P_days = case when (1 - lt.leave_used) < 0 then 0 else (1 - lt.leave_used) end
		from #Data d
		left outer join (
			
			select emp_id,for_date,sum(
					case when lm.Apply_hourly = 0 then  (lt.CompOff_Used - lt.Leave_Encash_Days) 
						
					else 
							case when ((lt.CompOff_Used - lt.Leave_Encash_Days)*0.125)>1 then 1 
							else ((lt.CompOff_Used - lt.Leave_Encash_Days)*0.125) 
							end  
					end)  as Leave_Used 
		from T0140_LEAVE_TRANSACTION lt 
			inner join T0040_LEAVE_MASTER lm on lt.Leave_ID = lm.Leave_ID and isnull(lm.Default_Short_Name,'') = 'COMP' And Isnull(LM.Add_In_Working_Hour,0) = 0
		where For_Date between @From_Date and @To_Date 
		group by Emp_ID,For_Date) as lt on
		d.emp_id = lt.emp_ID and d.for_date = lt.for_date
		Where d.P_days + lt.leave_used > 1
		
	END
 -- Changed by Gadriwala Muslim 01012015 - End
 -- Ende


--------------------Added by Mitesh on 15/09/2011 for Shift Half Day ----------------------------
	
  update #Data   
	set OT_Sec = isnull(Approved_OT_Sec,0),Weekoff_OT_Sec = ISNULL(OA.Approved_WO_OT_Sec,0), Holiday_OT_Sec = ISNULL(OA.Approved_HO_OT_Sec,0) -- * 3600    
  from #Data  d inner join dbo.T0160_OT_Approval OA on d.emp_ID = Oa.Emp_ID and d.For_Date = oa.For_Date and Is_Month_Wise = 0    

  

    
  -- Deepal 12122022 23482 
  UPDATE D
  SET D.P_days = 0
  FROM  #DATA D INNER JOIn  #EMP_GEN_SETTINGS G
  ON D.EMP_ID = G.EMP_ID
  WHERE G.TRAS_WEEK_OT = 1 and  (D.Weekoff_OT_Sec > 0 Or D.Holiday_OT_Sec > 0)
  -- Deepal 12122022 23482
  
  
  ---------------- Add by Jignesh Patel 14-Apr-2022---(Bug/Suggestions #20756)---------
 -- if Not exists (Select 1 from tempdb.sys.columns  where [object_id] = object_id('tempdb..#Data') 
 --            and name ='Original_OT_Sec')
	--Begin
	--	ALTER TABLE #Data
	--	ADD  Original_OT_Sec int 
	--End

 --  Update #Data SET Original_OT_Sec = OT_Sec

IF OBJECT_ID(N'tempdb..#Emp_Original_OT_Sec') IS NOT NULL
BEGIN
DROP TABLE #Emp_Original_OT_Sec
END
select Emp_id as OT_Emp_Id ,For_date,OT_Sec as Original_OT_Sec Into #Emp_Original_OT_Sec from #Data
------------------------End -------------


 Update #Data    
 set OT_Sec = 0   
 where Emp_OT_Min_Limit > OT_sec and OT_sec > 0    
    
  Update #Data    
 set OT_Sec = Emp_OT_Max_Limit    
  where OT_sec  > Emp_OT_Max_Limit  and Emp_OT_Max_Limit > 0 and OT_sec >0  


  -- Added by Hardik 03/12/2019 for Cera
  Declare @Setting_Value int
  Set @Setting_Value = 0
  Select @Setting_Value = Isnull(Setting_Value,0) 
  from T0040_SETTING where setting_name = 'Make Absent if Employee came in Different Shift' and Cmp_Id = @Cmp_Id
  
  --Code Commented and Added By Ramiz on 04/04/2017 ( Reason:- For 24 Hours Shift , We will Not Consider Shift Deviation )
	If Isnull(@Setting_Value,0) = 1
		Begin
			Update 	D 
			SET 	P_days=0 
			FROM 	#DATA D 
					INNER JOIN T0040_SHIFT_MASTER SM ON D.Shift_ID=SM.Shift_ID 
			WHERE 	Shift_Change = 1 AND NOT EXISTS (
													SELECT 1 FROM T0050_SHIFT_DETAIL SD 
													WHERE D.SHIFT_ID=SD.SHIFT_ID AND SD.FROM_HOUR < 1  AND SD.TO_HOUR > 23 
												)
					and Inc_Auto_Shift <> 1	
		End  
  
  
  --PRINT 'CALC 17 :' + CONVERT(VARCHAR(20), GETDATE(), 114);
---Add by Hardik for Diferentiate Weekoff OT And Holiday OT 

 --Declare @Is_Cancel_Holiday  Numeric(1,0)  
 Declare @Is_Cancel_Weekoff_OT  Numeric(1,0)  
 Declare @Join_Date  Datetime  
 Declare @Left_Date  Datetime   
 --Declare @StrHoliday_Date  varchar(max)  
 Declare @StrWeekoff_Date_OT  varchar(max)  
 --Declare @Holiday_Days Numeric(12,1)
 Declare @Weekoff_Days_OT Numeric(12,1)
 --Declare @Cancel_Holiday Numeric(12,1)
 Declare @Cancel_Weekoff_OT Numeric(12,1)
 Declare @Emp_Id_Cur Numeric
 Declare @For_Date Datetime
 Declare @WeekOff_Work_Sec Numeric
 Declare @Holiday_Work_Sec Numeric
 Declare @Trans_Weekoff_OT tinyint --Hardik 14/02/2013 
 
 Declare @Is_Cancel_Holiday Int
Declare @StrHoliday_Date varchar(Max)
Declare @Holiday_days Numeric(18,3)
Declare @Cancel_Holiday Numeric(18,3)
Declare @Half_Holiday_Dates Varchar(Max)
 
--- Added By Hardik 10/08/2013 for Split Shift Count and Dates for Azure Client
Declare @Is_Split_Shift as tinyint
Declare @In_Time Datetime
Declare @Out_Time Datetime
Declare @First_Working_Sec Numeric
Declare @Split_Shift_Allow numeric(18,3)
Declare @Split_Shift_Ratio numeric(18,3)

Declare @Shift_Second_St_Time Datetime
Declare @Shift_Second_End_Time Datetime
Declare @Shift_Second_Sec Numeric
Declare @Shift_Third_St_Time Datetime
Declare @Shift_Third_End_Time Datetime
Declare @Shift_Third_Sec Numeric
 
 Set @Is_Cancel_Weekoff_OT = 0
 Set @Is_Cancel_Holiday = 0  
 Set @StrHoliday_Date = ''  
 Set @StrWeekoff_Date_OT = '' 
 Set @Holiday_Days  = 0  
 Set @Weekoff_Days_OT  = 0  
 Set @Cancel_Holiday  = 0  
 Set @Cancel_Weekoff_OT  = 0  
 Set @Trans_Weekoff_OT = 0
 SET @Half_Holiday_Dates = '';

	

	Select @Is_Cancel_Holiday = Is_Cancel_Holiday,@Is_Cancel_Weekoff_OT = Is_Cancel_Weekoff
	From dbo.T0040_GENERAL_SETTING 
	Where cmp_ID = @cmp_ID and Branch_ID = @Branch_ID  
	and For_Date = (select max(For_Date) from dbo.T0040_GENERAL_SETTING where For_Date <=@To_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)  
	
	
	Declare @Split_Shift_Count Numeric --Hardik 12/08/2013 for Split Shift
	Set @Split_Shift_Count = 0
	
	--Hardik 22/11/2013 for Saudi Arabia
	Declare @Shift_End_Time_Temp as Datetime
	Declare @Diff_Sec as Numeric
	DECLARE @OT_Start_Time AS NUMERIC 
		--PRINT 'CALC 18 :' + CONVERT(VARCHAR(20), GETDATE(), 114);
	Declare Cur_HO cursor Fast_forward for
		Select Emp_Id,For_Date, Shift_End_Time from #Data --Where OT_Sec > 0
	open Cur_HO
	fetch next from Cur_HO into @Emp_Id_Cur,@For_Date,@Shift_End_Time_Temp
	While @@Fetch_Status=0
	 begin
	  

		Set @Is_Split_Shift = 0
		Set @In_Time = Null
		Set @Out_Time = Null
		Set @Shift_Second_St_Time = Null
		Set @Shift_Second_End_Time = Null
		Set @Shift_Third_St_Time = Null
		Set @Shift_Third_End_Time = Null
		Set @Shift_Second_Sec = 0
		Set @Shift_Third_Sec = 0
		Set @First_Working_Sec = 0
		Set @Split_Shift_Allow = 0
		Set @Split_Shift_Ratio = 0
		Set @Split_Shift_Count = 0
		
		--Hardik 22/11/2013 for Saudi Arabia
		Set @Diff_Sec = 0
		
	
		Select @Is_Split_Shift = Is_Split_Shift,
			@Split_Shift_Allow = S.Split_Shift_Rate, @Split_Shift_Ratio = Split_Shift_Ratio,
			@Shift_Second_St_Time = Cast(@For_Date + ' ' + S.S_St_Time as Datetime), 
			@Shift_Second_End_Time = Cast(@For_Date + ' ' + S.S_End_Time as Datetime),
			@Shift_Second_Sec = DATEDIFF(SS,@Shift_Second_St_Time,@Shift_Second_End_Time),
			@Shift_Third_St_Time = Cast(@For_Date + ' ' + S.T_St_Time as Datetime), 
			@Shift_Third_End_Time = Cast(@For_Date + ' ' + S.T_End_Time as Datetime),
			@Shift_Third_Sec = DATEDIFF(SS,@Shift_Third_St_Time,@Shift_Third_End_Time)
		From T0040_SHIFT_MASTER S Inner Join #Data D on S.Shift_ID = D.Shift_ID 
		Where For_date = @For_Date And Emp_Id = @Emp_Id_Cur


		If @Is_Split_Shift = 1 And @Is_Split_Shift_Req = 1 
			Begin
				Declare Cur_Split cursor Fast_forward for
					Select In_Time, Out_Time From T0150_EMP_INOUT_RECORD Where For_Date = @For_Date And Emp_ID = @Emp_Id_Cur
				open Cur_Split
				fetch next from Cur_Split into @In_Time,@Out_Time
				While @@Fetch_Status=0
					begin
						if DATEADD(MINUTE,-90,@Shift_Second_St_Time) <= @In_Time and DATEADD(MINUTE,90,@Shift_Second_End_Time) >= @Out_Time
							begin
								If @Shift_Second_St_Time > @In_Time
									Set @In_Time = @Shift_Second_St_Time
								
								If @Shift_Second_End_Time < @Out_Time
									Set @Out_Time = @Shift_Second_End_Time

								If @Shift_Second_Sec < Datediff(SS,@In_Time,@Out_Time)
									Begin
										Set @First_Working_Sec = @First_Working_Sec + @Shift_Second_Sec
									End
								Else
									Begin
										Set @First_Working_Sec = @First_Working_Sec + Datediff(SS,@In_Time,@Out_Time)
									End
							end
						else if DATEADD(MINUTE,-90,@Shift_Third_St_Time) <= @In_Time and DATEADD(MINUTE,90,@Shift_Third_End_Time) >= @Out_Time
							begin
								If @Shift_Third_St_Time > @In_Time
									Set @In_Time = @Shift_Third_St_Time
								
								If @Shift_Third_End_Time < @Out_Time
									Set @Out_Time = @Shift_Third_End_Time
							
								If @Shift_Third_Sec < Datediff(SS,@In_Time,@Out_Time)
									Begin
										Set @First_Working_Sec = @First_Working_Sec + @Shift_Second_Sec
									End
								Else
									Begin
										Set @First_Working_Sec = @First_Working_Sec + Datediff(SS,@In_Time,@Out_Time)
									End
							end
					
						fetch next from Cur_Split into @In_Time,@Out_Time
					End
				close Cur_Split
				deallocate Cur_Split					
				
			If (@First_Working_Sec / (@Shift_Second_Sec + @Shift_Third_Sec))*100 >= @Split_Shift_Ratio 
				Begin
				
					If Not Exists(Select 1 From #Split_Shift_Table Where Emp_Id = @Emp_Id_Cur)
						Begin
							Insert Into #Split_Shift_Table 
								(Emp_Id, Split_Shift_Count, Split_Shift_Dates,Split_Shift_Allow)
							Values
								(@Emp_ID,1,Cast(@For_Date As Varchar(11)),@Split_Shift_Allow)
						End
					Else
						Begin
							Update #Split_Shift_Table Set
								Split_Shift_Count =  Split_Shift_Count + 1,
								Split_Shift_Dates = Split_Shift_Dates +';'+ Cast(@For_Date As Varchar(11)),
								Split_Shift_Allow = Split_Shift_Allow + @Split_Shift_Allow
							Where Emp_Id = @Emp_Id_Cur
						End				
				End
				
			End

			--select @First_Working_Sec,dbo.F_Return_Hours(@first_working_sec),(@First_Working_Sec / (@Shift_Second_Sec + @Shift_Third_Sec))*100
			
		

		--- End By Hardik 10/08/2013 for Split Shift Count and Dates for Azure Client
		
		Select @Branch_ID = I.Branch_ID  from dbo.T0095_Increment I inner join   
		( select max(Increment_ID) as Increment_ID , Emp_ID From dbo.T0095_Increment    -- Ankit 12092014 for Same Date Increment
		where Increment_Effective_date <= @To_Date    
		and Cmp_ID = @Cmp_ID And Emp_ID = @Emp_Id_Cur
		group by emp_ID  ) Qry on    
		I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID 
		Where I.Emp_ID = @Emp_Id_Cur
			
			--Commented by Hardik 07/09/2012					
			--Exec SP_EMP_HOLIDAY_DATE_GET @Emp_ID_Cur,@Cmp_ID,@From_Date,@To_Date,@Join_Date,@left_Date,@Is_Cancel_Holiday,@StrHoliday_Date output,@Holiday_days output,@Cancel_Holiday output,0,@Branch_ID,@StrWeekoff_Date_OT
			--Exec SP_EMP_WEEKOFF_DATE_GET @Emp_ID_Cur,@Cmp_ID,@From_Date,@To_Date,@Join_Date,@left_Date,@Is_Cancel_Weekoff_OT,@StrHoliday_Date,@StrWeekoff_Date_OT output,@Weekoff_Days_OT output ,@Cancel_Weekoff_OT output 

			Set @StrWeekoff_Date_OT = ''
			Set @StrHoliday_Date = ''
			
			Select @StrWeekoff_Date_OT = StrWeekoff, @StrHoliday_Date = StrHoliday
			from #Emp_WeekOFf_Detail Where Emp_ID = @Emp_Id_Cur 			
			
			--SELECT @StrHoliday_Date
			/* Note : Cancel weekly off If Sandwich Policy and Employee Present on that day then its calculate Ovet Time 
				--CancelWeekOff Added by Ankit 16122015 */
			
			SET @Holiday_Date1_Cancel = '';
			SET @Weekoff_Date1_CancelStr = '';
			SET @Half_Holiday_Dates = '';
			SET @WEEKOFF_DATE1_CANCEL='';
			
			SELECT @Weekoff_Date1_CancelStr = ISNULL(CancelWeekOff,'')	,@Holiday_Date1_Cancel = ISNULL(CancelHoliday,''), @Half_Holiday_Dates = IsNull(HalfHolidayDate, '')
			FROM #EMP_HW_CONS
			Where Emp_ID = @Emp_Id_Cur
			
			SELECT @Weekoff_Date1_Cancel = COALESCE ( @Weekoff_Date1_Cancel + ';', '') + DATA FROM dbo.Split(@Weekoff_Date1_CancelStr,';') 
			WHERE Data <> '' AND NOT EXISTS ( SELECT For_date FROM T0100_WEEKOFF_ROSTER WHERE Emp_id = @Emp_Id_Temp1 AND is_Cancel_WO = 1 AND For_date = CAST(DATA AS DATETIME ) )
			
			IF @StrWeekoff_Date_OT <> ''
				SET @StrWeekoff_Date_OT = @StrWeekoff_Date_OT + @Weekoff_Date1_Cancel
			IF @Holiday_Date1_Cancel <> ''
				SET @StrHoliday_Date = @StrHoliday_Date + @Holiday_Date1_Cancel
				--Modified by Chetan on 05062017 (Trans_Week_OT is for Both Holiday & WeekOff Work Transfer to OT)
				Declare @Trans_Week_OT as tinyint 
					set @Trans_Week_OT = 0
				  Select @Trans_Week_OT = isnull(Tras_Week_OT,0)
					From dbo.T0040_GENERAL_SETTING 
					Where cmp_ID = @cmp_ID and Branch_ID = @Branch_ID  
						and For_Date = (select max(For_Date) from dbo.T0040_GENERAL_SETTING where For_Date <=@To_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)  
			
		 if (charindex(cast(@For_Date as varchar(11)),@StrHoliday_Date,0) > 0 
		 OR charindex(cast(@For_Date as varchar(11)),@Half_Holiday_Dates,0) > 0) AND @Trans_Week_OT = 1 --@Trans_Week_OT = 1  add by chetan 050617
				begin
				  --Update #Data Set Duration_in_sec = 0, OT_Sec = 0, Holiday_OT_Sec = Duration_in_sec + OT_Sec Where For_date = @For_Date And Emp_Id = @Emp_Id_Cur		
				  			
				  --Update #Data Set OT_Sec = 0, Holiday_OT_Sec = OT_Sec Where For_date = @For_Date And Emp_Id = @Emp_Id_Cur	
					  
					
					declare @shift_Work_time_Sec as numeric(18,3)
					set @shift_Work_time_Sec = 0
					
					if @Trans_Week_OT = 1 
						begin
							
  
							--Following condition modified by Nimesh on 17-Oct-2017 (If Holiday AND WeekOff is on same date and Holiday is being canceled.)
							if charindex(cast(@For_Date as varchar(11)),@StrHoliday_Date,0) > 0 AND
								charindex(cast(@For_Date as varchar(11)),@StrWeekoff_Date_OT,0) > 0 
								Update	#Data Set OT_Sec = 0, 
										Holiday_OT_Sec = OT_Sec + Holiday_OT_Sec 
								from	#Data as data_t 
										INNER JOIN #EMP_GEN_SETTINGS G ON data_t.Emp_Id=G.EMP_ID
								Where	data_t.For_date = @For_Date And Data_t.Emp_Id = @Emp_Id_Cur --and is_Half  = 0 
										AND G.Is_Cancel_Holiday_WO_HO_same_day = 0
							ELSE 
								Update	#Data Set OT_Sec = 0, Holiday_OT_Sec = OT_Sec + Holiday_OT_Sec 
								from	#Data as data_t 
								Where	data_t.For_date = @For_Date And Data_t.Emp_Id = @Emp_Id_Cur --and is_Half  = 0 

				
						
							IF charindex(cast(@For_Date as varchar(11)),@Half_Holiday_Dates,0) > 0 
								BEGIN
									select	@shift_Work_time_Sec =  Duration_In_Sec - (DATEDIFF(S,Shift_Start_Time,Shift_End_Time)/2) 
									from	#Data 
									Where	For_date = @For_Date And Emp_Id = @Emp_Id_Cur and isnull(Emp_OT,0) = 1
									
									Update	#Data Set OT_Sec = 0, Holiday_OT_Sec = @shift_Work_time_Sec, P_days = P_days - 0.5 
									from	#Data as data_t 
											--inner join #Emp_Holiday EH on EH.Emp_ID = Data_t.Emp_ID and EH.For_Date = Data_t.For_date 			
									Where	data_t.For_date = @For_Date And Data_t.Emp_Id = @Emp_Id_Cur  and P_days = 1 --and is_Half = 1
								END
						end
					Else
						Begin
							Update #Data set Holiday_OT_Sec = Ot_sec,OT_Sec=0
							where Emp_Id=@Emp_Id_Cur And For_Date=@For_Date
						End						
				end
				--AND @Trans_Week_OT = 1 add by chetan 050617 for weekoff ot  transfer option
		 --else 
		 if charindex(cast(@For_Date as varchar(11)),@StrWeekoff_Date_OT,0) > 0 AND @Trans_Week_OT = 1
				begin					
					
					--Update #Data Set Duration_in_sec = 0, OT_Sec = 0, Weekoff_OT_Sec = Duration_in_sec +  OT_Sec Where For_date = @For_Date And Emp_Id = @Emp_Id_Cur
					--If not exists (Select 1 from dbo.T0160_OT_Approval OA Where Is_Month_Wise = 0 and For_date = @For_Date And Emp_Id = @Emp_Id_Cur   )
					if CHARINDEX(CAST(@For_Date AS VARCHAR(11)),@StrHoliday_Date,0) > 0 
						Update	D
						Set		OT_Sec = 0, 
								Weekoff_OT_Sec = OT_Sec + Weekoff_OT_Sec 
						FROM	#DATA D 
								INNER JOIN #EMP_GEN_SETTINGS G ON D.Emp_Id=G.EMP_ID
						Where	D.For_date = @For_Date And D.Emp_Id = @Emp_Id_Cur
								AND G.Is_Cancel_Holiday_WO_HO_same_day = 1
					ELSE
						Update	D
						Set		OT_Sec = 0, 
								Weekoff_OT_Sec = OT_Sec + Weekoff_OT_Sec 
						FROM	#DATA D 								
						Where	For_date = @For_Date And Emp_Id = @Emp_Id_Cur								
						
				 
					--Update #Data Set  Duration_in_sec = 0,OT_Sec = 0, Weekoff_OT_Sec = Duration_in_sec + OT_Sec + Weekoff_OT_Sec Where For_date = @For_Date And Emp_Id = @Emp_Id_Cur
				end 
				
			
		
			--Hardik 22/11/2013 for OT Start From Shift End time for Multiple In Out Saudi Arabia
			--If @First_In_Last_Out_For_InOut_Calculation = 0
			--	Begin
					
					----Commented and added by Sid for OT Hours before shift time where "OT Start from Shift Start time" is not ticked in Shift Master
					/*Select @Diff_Sec =  SUM(Diff_Sec) From (
						Select Case When Row =1 then
							DATEDIFF(s,@Shift_End_Time_Temp,Out_Time)
						 Else 
							DATEDIFF(s,In_Time,Out_Time)
						 End as Diff_Sec From 
						(select ROW_NUMBER() 
								OVER (ORDER BY IO_Tran_Id) AS Row, 
								* from T0150_EMP_INOUT_RECORD where Emp_ID = @Emp_Id_Cur
						and (In_Time >= @Shift_End_Time_Temp or Out_Time >= @Shift_End_Time_Temp)
						and For_Date = @For_Date And Emp_ID = @Emp_Id_Cur) as Qry) as Qry1	*/
						
				SELECT	@ot_start_time = OT_Start_Time,@shift_st_time1 = Shift_start_time 
				FROM	#DATA D
						INNER JOIN #EMP_GEN_SETTINGS ES ON D.EMP_ID=ES.EMP_ID 
				WHERE	First_In_Last_Out_For_InOut_Calculation=0
						AND FOR_DATE = @for_date AND D.Emp_Id = @Emp_ID_Cur
				
				
				
				SELECT	@Diff_Sec = SUM(Diff_Sec)
				FROM	(SELECT	CASE WHEN Row = 1 
								THEN 
									CASE WHEN @Shift_End_Time_Temp < out_time  THEN 
										DATEDIFF(s, @Shift_End_Time_Temp,Out_Time) 
									ELSE 
										0 
									END 
									+ 
									CASE WHEN @OT_Start_Time = 0 THEN 
										CASE WHEN in_time < @shift_St_Time1 THEN 
											DATEDIFF(SECOND,in_time,@shift_St_Time1) 
										ELSE 
											0 
										END
									ELSE 
										0 
									END 
								WHEN @Shift_End_Time_Temp > In_Time AND Out_Time > @Shift_End_Time_Temp THEN 
									DATEDIFF(s, @Shift_End_Time_Temp, Out_Time)
								WHEN @Shift_End_Time_Temp > Out_Time THEN 
									0
								ELSE 
									DATEDIFF(s, In_Time, Out_Time)
								END AS Diff_Sec
						 FROM	(SELECT	ROW_NUMBER() OVER (ORDER BY IO_Tran_Id)
										AS Row, IOUT.*
								 FROM	T0150_EMP_INOUT_RECORD IOUT  
										INNER JOIN #EMP_GEN_SETTINGS ES ON IOUT.EMP_ID=ES.EMP_ID 
								 WHERE	First_In_Last_Out_For_InOut_Calculation=0
										AND (In_Time <= @Shift_St_Time1 OR Out_Time >= @Shift_End_Time_Temp) 
										AND For_Date = @For_Date AND IOUT.Emp_ID = @Emp_Id_Cur
								) AS Qry
						) AS Qry1	
				
				
				------Added by Sid Ends.
					  
					Update #Data Set OT_Sec = ISNULL(@Diff_Sec,0)  --ISNULL Added By Ramiz on 01/08/2016
					FROM	#DATA D 
							INNER JOIN #EMP_GEN_SETTINGS ES ON D.EMP_ID=ES.EMP_ID 
					WHERE	First_In_Last_Out_For_InOut_Calculation=0
							AND For_date = @For_Date And D.Emp_Id = @Emp_Id_Cur
							And OT_End_Time = 1 And Weekoff_OT_Sec = 0 And Holiday_OT_Sec = 0
							And isnull(Emp_OT,0)=1 
							and ISNULL(D.Emp_OT_min_limit,0) < ISNULL(@Diff_Sec,0)-- Added by nilesh on 12102016 update OT Sec when OT Sec is less than Emp min OT 
				--End	
			
		 fetch next from Cur_HO into @Emp_Id_Cur,@For_Date,@Shift_End_Time_Temp
	  end 
	close Cur_HO    
	Deallocate Cur_HO 
	

	


	--if isnull(@Chk_otLimit_before_after_Shift_time,0) = 0 
				-- Commented By rohit on 21112014
				--begin
				--Update #Data Set OT_Sec = DATEDIFF(s,Shift_End_Time,OUT_Time) 
				-- Where OT_End_Time = 1 And OUT_Time >= Shift_End_Time And rWeekoff_OT_Sec = 0 And Holiday_OT_Sec = 0
				-- And isnull(Emp_OT,0)=1
				 
				--UPDATE	#Data
				--SET		OT_Sec = OT_Sec + DATEDIFF(s, In_Time, Shift_Start_Time) 
				--WHERE	OT_Start_Time = 0 AND In_Time <= Shift_Start_Time AND Weekoff_OT_Sec = 0 AND Holiday_OT_Sec = 0 AND ISNULL(Emp_OT,0) = 1
																		  
			
				--END
				--BEGIN
				
				--Update #Data Set OT_Sec = DATEDIFF(s,Shift_End_Time,OUT_Time) 
				-- Where OT_End_Time = 1 And OUT_Time >= Shift_End_Time And Weekoff_OT_Sec = 0 And Holiday_OT_Sec = 0
				-- And isnull(Emp_OT,0)=1 and DATEDIFF(s,Shift_End_Time,OUT_Time) > Emp_ot_min_limit

				--UPDATE	#Data
				--SET		OT_Sec = OT_Sec + DATEDIFF(s, In_Time, Shift_Start_Time) 
				--WHERE	OT_Start_Time = 1 AND In_Time <= Shift_Start_Time AND Weekoff_OT_Sec = 0 AND Holiday_OT_Sec = 0 
				--AND ISNULL(Emp_OT,0) = 1 and DATEDIFF(s, In_Time, Shift_Start_Time) > Emp_ot_min_limit
				
				
		DECLARE @DIFF_HOUR AS NUMERIC(18,2)
		Declare @Total_second as numeric(18,2)
		SET @DIFF_HOUR = 0
		SET @Total_second = 0
		
		select @DIFF_HOUR = CAST(Setting_Value  AS numeric(18,2)) from T0040_SETTING where Cmp_ID=@Cmp_Id and Setting_Name='Remove the Gap Between Two In-Out Punch from Working Hours' and ISNUMERIC(Setting_Value)=1
		
		IF @DIFF_HOUR % 1.00 > 0
			SET @DIFF_HOUR = (@DIFF_HOUR * 100) / 60;
							
		CREATE TABLE #DIFF
		(
			EMP_ID	INT,
			FOR_DATE DATETIME,
			DIFF	INT
		)		
		
		IF @DIFF_HOUR > 0
			BEGIN
				set @Total_second = (@DIFF_HOUR * 3600)
				
				INSERT INTO #DIFF
				SELECT EMP_ID, FOR_DATE, DATEDIFF(S, IN_TIME,OUT_TIME) - Duration_in_Sec
				FROM	#Data
				Where In_Time Is not null AND OUT_Time IS NOT NULL
				
				DELETE FROM #DIFF WHERE DIFF < @Total_second
								
			END
		
		
		
	
			UPDATE	#Data 
			SET		--OT_Sec = DATEDIFF(s,D.Shift_End_Time,D.OUT_Time) -- Comment by nilesh patel on 12102016 -- (ISNULL(D.Emp_OT_Max_limit,0) > 0 Condition) Added By Ramiz on 02/02/2017 as it was not taking Overtime when Max Limit is not Provided 
					OT_Sec = (CASE WHEN DATEDIFF(s,D.Shift_End_Time,D.OUT_Time) >  ISNULL(D.Emp_OT_Max_limit,0) and  ISNULL(D.Emp_OT_Max_limit,0) > 0
					Then ISNULL(D.Emp_OT_Max_limit,0) ELSE DATEDIFF(s,D.Shift_End_Time,D.OUT_Time) END) -- - IsNull(DF.DIFF,0) Commented by deepal 25062021
			FROM	#Data D left join #Emp_WeekOFf_Detail EWD on D.emp_id = EWD.emp_id				
					INNER JOIN #EMP_GEN_SETTINGS ES ON D.EMP_ID=ES.EMP_ID 
					LEFT OUTER JOIN #DIFF DF ON D.Emp_Id=DF.EMP_ID AND D.For_date=DF.FOR_DATE
			WHERE	Chk_otLimit_before_after_Shift_time=0 
					AND OT_End_Time = 1 And OUT_Time >= Shift_End_Time And Weekoff_OT_Sec = 0 And Holiday_OT_Sec = 0
					AND isnull(Emp_OT,0)=1 and DATEDIFF(s,Shift_End_Time,OUT_Time) >= Emp_ot_min_limit AND Emp_ot_min_limit > 0
					AND D.for_date not in (select cast(data  as datetime) FROM dbo.Split(isnull(Ewd.strweekoff_Holiday,''),';'))
				 
			UPDATE	#Data Set OT_Sec=0 Where OT_Sec < 0
				

			UPDATE	#Data
			SET		OT_Sec = OT_Sec + (DATEDIFF(s, In_Time, Shift_Start_Time) - IsNull(DF.DIFF,0))
			FROM	#Data D left join #Emp_WeekOFf_Detail EWD on D.emp_id = EWD.emp_id
					INNER JOIN #EMP_GEN_SETTINGS ES ON D.EMP_ID=ES.EMP_ID 
					LEFT OUTER JOIN #DIFF DF ON D.Emp_Id=DF.EMP_ID AND D.For_date=DF.FOR_DATE AND (DATEDIFF(s, In_Time, Shift_Start_Time)  - IsNull(DF.DIFF,0)) > 0
			WHERE	Chk_otLimit_before_after_Shift_time=0
					AND OT_Start_Time = 1 AND In_Time <= Shift_Start_Time AND Weekoff_OT_Sec = 0 AND Holiday_OT_Sec = 0		/* Changed condition from AND OT_Start_Time = 0 to AND OT_Start_Time = 1 (Its calculating extra overtime)*/
					AND ISNULL(Emp_OT,0) = 1 and DATEDIFF(s, In_Time, Shift_Start_Time) >= Emp_ot_min_limit AND Emp_ot_min_limit > 0
					AND D.for_date not in (select cast(data  as datetime) FROM dbo.Split(isnull(Ewd.strweekoff_Holiday,''),';'))

			
				--END
				  
 
 
     Update #Data    
	 set OT_Sec = 0   
	 where Emp_OT_Min_Limit > OT_sec and OT_sec > 0    

	  Update #Data    
	 set OT_Sec = Emp_OT_Max_Limit    
	  where OT_sec  > Emp_OT_Max_Limit  and Emp_OT_Max_Limit > 0 and OT_sec >0  
				  
 
------------ End By Hardik for OT
--PRINT 'CALC 19 :' + CONVERT(VARCHAR(20), GETDATE(), 114);
		
			--Added by Gadriwala Muslim 07042015 
			CREATE TABLE #EMP_Gate_Pass
				(
					emp_ID numeric(18,0),
					For_date datetime,
					GatePass_Deduct_Days numeric(18,2) default 0
				)
	
		--Added By Gadriwala Muslim 05012014 - Start
		declare @GatePass_Deduct_Days as numeric(18,2)
		--select @Emp_ID,@Cmp_ID,@Branch_ID,@From_Date,@To_Date
		--select @Emp_ID as Emp_ID ,@Cmp_ID as cmp_ID ,@Branch_ID as Branch_Id,@From_Date as From_Date,@To_Date as To_date
		
		exec Calc_Gate_Pass_Present_Days_Deduction @Emp_ID,@Cmp_ID,@Branch_ID,@From_Date,@To_Date,@GatePass_Deduct_Days output,@constraint,1
		--PRINT @GatePass_Deduct_Days
		
		
		
		Update #Data set GatePass_Deduct_Days = isnull(qry.GatePass_Deduct_Days,0) 
		From #Data d inner join 
		(
			select GP.emp_ID,GP.for_Date,isnull(sum(GP.gatePass_Deduct_Days),0) as gatePass_Deduct_Days  
			from 	#Emp_Gate_Pass GP Group by GP.Emp_ID,GP.For_date
		) qry on qry.Emp_ID = d.Emp_Id and qry.For_date = d.For_date
			
		
		Update #Data_temp1 set GatePass_Deduct_Days = isnull(Qry.GatePass_Deduct_Days,0) 
		from #Data_temp1 d inner join 
		(
			select GP.emp_ID,GP.for_Date,isnull(sum(GP.gatePass_Deduct_Days),0) as gatePass_Deduct_Days  
			 from  #Emp_Gate_Pass GP  Group by GP.Emp_ID,GP.For_date
		) Qry on Qry.Emp_ID = d.Emp_Id  and Qry.For_date = d.For_date

		--Added by Nilesh Patel on 20072018 For Cliantha -- Attendance Approval Process
		Update dt
			Set dt.P_days = Q.P_Days,
				dt.OT_Sec = dt.Duration_in_sec -- (IF Employee Working On Present Day and Working day is found it is consider as OT For that days -- For Cliantha -- 20072018)
		From #Data dt Inner Join(
				SELECT	AA.Emp_id,AA.For_Date,P_Days
				FROM	T0165_Attendance_Approval AA 
				WHERE	For_Date >= @From_Date and For_Date <= @To_Date AND ATT_STATUS = 'A' and P_Days <> 0
			) as Q ON dt.Emp_ID = Q.Emp_ID and dt.For_Date = Q.For_Date

		Declare @Att_Emp_ID Numeric
		Set @Att_Emp_ID = 0
		If Exists(SELECT 1 FROM T0165_ATTENDANCE_APPROVAL WHERE CMP_ID = @CMP_ID AND FOR_DATE >=@FROM_DATE AND FOR_DATE <=@TO_DATE AND ATT_STATUS = 'A')
			Begin
				Declare CurAttApproval Cursor For 
					select distinct emp_id from #Data 
				open CurAttApproval
				fetch next from CurAttApproval into @Att_Emp_ID
					while @@fetch_status = 0
						begin

								INSERT INTO #Data
								   (Emp_Id,For_date,Duration_in_sec,Shift_ID,Shift_Type,Emp_OT ,Emp_OT_min_Limit,Emp_OT_max_Limit,P_days,OT_Sec,In_Time,Shift_Start_Time,OT_Start_Time ,Shift_Change,Flag ,Weekoff_OT_Sec ,Holiday_OT_Sec ,Chk_By_Superior ,IO_Tran_Id ,OUT_Time )
								SELECT	AA.Emp_id,AA.For_Date,		0,dbo.fn_get_Shift_From_Monthly_Rotation(Cmp_ID,Emp_ID,For_Date),			0,			1,		0,				0,				P_Days,		0,	For_Date,For_Date,		0,			0,			0,	0,0 ,				0,				0,		For_Date
								FROM	T0165_Attendance_Approval AA 
								WHERE	For_Date >= @From_Date and For_Date <= @To_Date and Emp_id = @Att_Emp_ID AND ATT_STATUS = 'A' and P_Days <> 0
										AND NOT EXISTS(Select 1 From #Data D Where D.Emp_ID = AA.Emp_ID and D.For_Date = AA.For_Date)

							fetch next from CurAttApproval into @Att_Emp_ID
						End
				Close CurAttApproval
				deallocate CurAttApproval
			End

			IF EXISTS(SELECT 1 FROM T0165_ATTENDANCE_APPROVAL WHERE CMP_ID = @CMP_ID AND FOR_DATE >=@FROM_DATE AND FOR_DATE <= DateAdd(Day,1,@TO_DATE) AND ATT_STATUS = 'A')
				BEGIN
					UPDATE DT
						SET DT.DURATION_IN_SEC = (Case When DT.DURATION_IN_SEC > Q.SHIFT_SEC Then DT.DURATION_IN_SEC - Q.SHIFT_SEC Else 0 END),
							DT.OT_SEC = CASE WHEN DT.OT_SEC > Q.SHIFT_SEC THEN 
												CASE WHEN DT.Emp_OT_Min_Limit > (DT.OT_SEC - Q.SHIFT_SEC) THEN	
													0
												ELSE  (DT.OT_SEC - Q.SHIFT_SEC) END
										ELSE 0 END,
							DT.Weekoff_OT_Sec = CASE WHEN G.Tras_Week_OT = 1 AND DT.Weekoff_OT_Sec > Q.SHIFT_SEC THEN DT.Weekoff_OT_Sec - Q.SHIFT_SEC ELSE DT.Weekoff_OT_Sec END,
							DT.Holiday_OT_Sec = CASE WHEN G.Tras_Week_OT = 1 AND DT.Holiday_OT_Sec > Q.SHIFT_SEC THEN DT.Holiday_OT_Sec - Q.SHIFT_SEC ELSE DT.Holiday_OT_Sec END
					FROM #DATA DT INNER JOIN 
					(
							SELECT EMP_ID,DATEADD(D,-1,FOR_DATE) AS FORDATE,P_DAYS,ATT_STATUS,SHIFT_SEC
							FROM T0165_ATTENDANCE_APPROVAL 
							WHERE CMP_ID = @CMP_ID AND FOR_DATE >=@FROM_DATE AND FOR_DATE <= DateAdd(Day,1,@TO_DATE) AND ATT_STATUS = 'A' and P_Days <> 0
					)Q ON DT.EMP_ID =Q.EMP_ID  AND DT.FOR_DATE = Q.FORDATE
					INNER JOIN #EMP_GEN_SETTINGS G ON DT.Emp_Id=G.EMP_ID
	END


	
----Add by Sid for OT Rounding off 21/05/2014 -----------------------------
Declare @OT_Emp numeric,
		@OT_Branch numeric,
		@OT_RoundingOff_To as numeric(18,3),
		@OT_RoundingOff_Lower as numeric

declare OTRoundCur Cursor for
select distinct emp_id from #Data 
open OTRoundCur
fetch next from OTRoundCur into @OT_Emp
while @@fetch_status = 0
begin
	select @OT_Branch = Branch_ID from T0095_INCREMENT t1 inner join (select emp_id,max(Increment_ID) as Increment_ID from t0095_increment where emp_id=@OT_Emp and Increment_Effective_Date <=@To_Date group by emp_id) t2-- Ankit 12092014 for Same Date Increment
	on t1.emp_id = t2.Emp_ID and t1.Increment_ID = t2.Increment_ID 
	where t1.emp_id = @ot_Emp

	select @OT_RoundingOff_To = OT_RoundingOff_To, @OT_RoundingOff_Lower = OT_RoundingOff_Lower from T0040_GENERAL_SETTING where branch_id = @OT_Branch 
	and For_Date = (select max(for_date) From T0040_General_Setting where Branch_ID =@OT_Branch)  --Modified By Ramiz on 16092014
	
	

	if @ot_Roundingoff_to > 0
	begin

	-----------Add by Jignesh patel 14-Apr-2022------------
	SET @OT_Roundingoff_To = case when @OT_Roundingoff_To = '0.15' then  '0.25' when @OT_Roundingoff_To = '0.30' then '0.50'
								  when @OT_Roundingoff_To = '0.45' then '0.75' when @OT_Roundingoff_To = '1' then 1 else @OT_Roundingoff_To end
	-------------- End --------------

		if @ot_roundingoff_lower = 0
		begin
		
			update #Data
			------ Modify By Jigensh Patel 14-Apr-2022---(Bug/Suggestions #20756)-----
			----set OT_Sec = (floor((cast(OT_Sec as float)/cast(3600 as float))*(1/@OT_RoundingOff_To))/(1/@OT_Roundingoff_To))*3600,
			set OT_Sec = (floor((cast(case when Emp_OT_Max_Limit > 0 then Original_OT_Sec else OT_Sec End as float)/cast(3600 as float))*(1/@OT_RoundingOff_To))/(1/@OT_Roundingoff_To))*3600,
				Weekoff_OT_Sec = (floor((cast(Weekoff_OT_Sec as float)/cast(3600 as float))*(1/@OT_RoundingOff_To))/(1/@OT_Roundingoff_To))*3600,
				Holiday_OT_Sec = (floor((cast(Holiday_OT_Sec as float)/cast(3600 as float))*(1/@OT_RoundingOff_To))/(1/@OT_Roundingoff_To))*3600

			From #Data AS A Inner join #Emp_Original_OT_Sec AS B On A.Emp_Id = B.OT_Emp_Id And A.For_date = B.For_date  ----- Add by Jigensh Patel  Bug/Suggestions #20756
			where emp_id = @OT_Emp

		end
		else if @OT_Roundingoff_lower = 1
		begin
		
			update #Data
			------ Modify By Jigensh Patel 14-Apr-2022---(Bug/Suggestions #20756)-----
			----set OT_Sec = (ceiling((cast(OT_Sec as float)/cast(3600 as float))*(1/@OT_RoundingOff_To))/(1/@OT_Roundingoff_To))*3600,
			set OT_Sec = (ceiling((cast(case when Emp_OT_Max_Limit > 0 then Original_OT_Sec else OT_Sec End as float)/cast(3600 as float))*(1/@OT_RoundingOff_To))/(1/@OT_Roundingoff_To))*3600,
				Weekoff_OT_Sec = (ceiling((cast(Weekoff_OT_Sec as float)/cast(3600 as float))*(1/@OT_RoundingOff_To))/(1/@OT_Roundingoff_To))*3600,
				Holiday_OT_Sec = (ceiling((cast(Holiday_OT_Sec as float)/cast(3600 as float))*(1/@OT_RoundingOff_To))/(1/@OT_Roundingoff_To))*3600

			From #Data AS A Inner join #Emp_Original_OT_Sec AS B On A.Emp_Id = B.OT_Emp_Id And A.For_date = B.For_date  ----- Add by Jigensh Patel  Bug/Suggestions #20756
			where emp_id = @OT_Emp
		end
		else
		begin
			begin
			update #Data
			------ Modify By Jigensh Patel 14-Apr-2022---(Bug/Suggestions #20756)-----
			----set OT_Sec = (round((cast(OT_Sec as float)/cast(3600 as float))*(1/@OT_RoundingOff_To),0)/(1/@OT_Roundingoff_To))*3600,
			set OT_Sec = (round((cast(case when Emp_OT_Max_Limit > 0 then Original_OT_Sec else OT_Sec End as float)/cast(3600 as float))*(1/@OT_RoundingOff_To),0)/(1/@OT_Roundingoff_To))*3600 ,
				Weekoff_OT_Sec = (round((cast(Weekoff_OT_Sec as float)/cast(3600 as float))*(1/@OT_RoundingOff_To),0)/(1/@OT_Roundingoff_To))*3600,
				Holiday_OT_Sec = (round((cast(Holiday_OT_Sec as float)/cast(3600 as float))*(1/@OT_RoundingOff_To),0)/(1/@OT_Roundingoff_To))*3600

			From #Data AS A Inner join #Emp_Original_OT_Sec AS B On A.Emp_Id = B.OT_Emp_Id And A.For_date = B.For_date  ----- Add by Jigensh Patel  Bug/Suggestions #20756
			where emp_id = @OT_Emp
		end
		end
	end
	fetch next from OTRoundCur into @OT_Emp
end
close OTRoundCur
deallocate OTRoundCur		
	

------------- Add by Jignesh Patel 14-Apr-2022----(Bug/Suggestions #20756)-----------
 Update #Data    
 set OT_Sec = 0   
 where Emp_OT_Min_Limit > OT_sec and OT_sec > 0    

 Update #Data    
 set OT_Sec = Emp_OT_Max_Limit    
 where OT_sec  > Emp_OT_Max_Limit  and Emp_OT_Max_Limit > 0 and OT_sec >0  
				  
------------------------End ------------------------




	
	--Added By Gadriwala Muslim 05012014 - End

	--Hardik 22/11/2013 for OT Start From Shift End time for Saudi Arabia
	

 -----Hardik 07/09/2012 for Weekoff1 Cursor
	--declare curweekoff1 cursor Fast_forward for        
	--	select Emp_Id from #Data Group by Emp_Id
	--open curweekoff1        
	--fetch next from curweekoff1 into @Emp_Id_Temp1
	--while @@fetch_status = 0        
	--begin  
	--		Select @Week_oF_Branch= Branch_ID  from dbo.t0095_increment where Increment_id in (select Max(Increment_id) from dbo.t0095_increment where emp_id=@Emp_Id_Temp1)

			
	--		Select @Is_Compoff = ISNULL(Is_CompOff,0),@Trans_Weekoff_OT = Isnull(Tras_Week_OT,0)
	--		From dbo.T0040_GENERAL_SETTING where cmp_ID = @cmp_ID and Branch_ID = @Week_oF_Branch  
	--		and For_Date = ( select max(For_Date) from dbo.T0040_GENERAL_SETTING where For_Date <=@To_Date and Branch_ID = @Week_oF_Branch and Cmp_ID = @Cmp_ID)

	--		 If(@Is_Compoff = 1) or @Trans_Weekoff_OT = 1 -- Added by Mihir Trivedi on 31/05/2012 for present days updation related to comp-off
	--			BEGIN
	--				Declare @strwoff as Varchar(Max)
	--				Declare @A_strwoff as varchar(20)
	--				Declare @D_EmpID as Numeric
	--				Declare @F_Date as Varchar(11)
	--				--Declare @Weekoff_EmpID as numeric
	--				Select @strwoff = Replace(ISNULL(Strweekoff,''),';',',') from
	--				#Emp_WeekOFf_Detail Where Emp_ID = @Emp_Id_Temp1
				
	--				--Declare curapp cursor Fast_forward for
	--				--	select Data from dbo.Split(@strwoff, ',') where Data <> ''
	--				--Open curapp
	--				--	Fetch Next from curapp into @A_strwoff
	--				--WHILE @@FETCH_STATUS = 0
	--				--	BEGIN					
	--						Declare curfinal cursor Fast_forward for
	--							Select Emp_ID, For_date from #Data
	--							Where For_Date In (Select Data from dbo.Split(@strwoff, ',') where Data <> '')
	--							And Emp_Id = @Emp_Id_Temp1
	--						Open curfinal 
	--							Fetch Next from curfinal into @D_EmpID, @F_Date
	--						WHILE @@FETCH_STATUS = 0
	--							BEGIN						

	--								--IF(@F_Date = @A_strwoff and @D_EmpID = @Emp_Id_Temp1)
	--								if charindex(cast(@F_Date as varchar(11)),@StrWeekoff_Date_OT,0) > 0 --Change By hardik 07/09/2012
	--									BEGIN
	--										Update #Data 
	--										Set P_days = 0.0
	--										Where For_date = @F_Date And Emp_Id = @Emp_Id_Temp1
	--										--Where CAST(For_date as varchar(11)) = @A_strwoff and Emp_Id = @Emp_Id_Temp1 --Commented by Hardik 07/09/2012
	--									END
	--								Fetch Next from curfinal into @D_EmpID, @F_Date
	--							END
	--						Close curfinal
	--						Deallocate curfinal
	--						--Fetch next from curapp into @A_strwoff 
	--				--	END
	--				--Close curapp
	--				--Deallocate curapp
	--			END
	--		fetch next from curweekoff1 into @Emp_Id_Temp1
	--	end        
 --close curweekoff1        
 --deallocate curweekoff1 	 
	--------End of Added by Mihir Trivedi on 31/05/2012
	
	

  if @Return_Record_set =2 or @Return_Record_set =5 or @Return_Record_set = 8 OR @Return_Record_set = 9 OR @Return_Record_set = 10 OR @Return_Record_set = 11 OR @Return_Record_set = 12 OR @Return_Record_set = 13 OR @Return_Record_set = 14  or  @Return_Record_set = 15 or @return_record_set = 16--or @Return_Record_set = 7    
 begin
  CREATE TABLE #Data_Temp   
  (   
		 Emp_Id numeric ,   
		 For_date datetime,    
		 Duration_in_sec numeric,    
		 Shift_ID numeric ,    
		 Shift_Type numeric ,    
		 Emp_OT  numeric ,    
		 Emp_OT_min_Limit numeric,    
		 Emp_OT_max_Limit numeric,    
		 P_days  numeric(12,3) default 0,    
		 OT_Sec  numeric default 0,
		 In_Time datetime,
		 Shift_Start_Time  datetime,
		 OT_Start_Time numeric default 0,
		 Shift_Change tinyint default 0,
		 Flag int default 0   ,
		 Weekoff_OT_Sec Numeric Default 0,
		 Holiday_OT_Sec Numeric Default 0 ,
		 Chk_By_Superior numeric default 0,
		 IO_Tran_Id	 numeric default 0,
		 OUT_Time datetime,
		 Shift_End_Time datetime,			--Ankit 16112013
		 OT_End_Time numeric default 0,	--Ankit 16112013
		 Working_Hrs_St_Time tinyint default 0, --Hardik 14/02/2014
		 Working_Hrs_End_Time tinyint default 0, --Hardik 14/02/2014
		 GatePass_Deduct_Days numeric(18,2) default 0 -- Add by Gadriwala Muslim 05012014
   )  
   
      
	-- Added by rohit on 26082013
   
    
   declare @Emp_ID_W numeric
   Declare @For_date_W Datetime
   
   
    DECLARE OT_Emp CURSOR  
    FOR  
     SELECT Emp_ID FROM #Emp_Cons 
     --inner join
     --t0160_Ot_Approval t  on d.Emp_ID = t.Emp_ID And d.For_Date = t.For_Date -- Added Inner join by Hardik 10/09/2012
    OPEN OT_Emp  
    fetch next from OT_Emp into @Emp_ID_W
	--select * from #Emp_Cons-- where Emp_ID in (21490,27946)
	
	--exec [dbo].[SP_CALCULATE_PRESENT_DAYS] 120,'2022-06-01 00:00:00.000','2022-06-30 00:00:00.000',0,0,0,0,0,0,0,'27182#27272#27438#23274#24529#24530#24532#25288#23065#23066#24778#24542#25287#24783#24782#25286#14803#25504#25505#21478#21147#21954#19081#22070#22280#22331#22343#22345#22347#22519#22928#23425#23995#24051#24050#24058#14560#14561#14562#14563#14564#14565#14566#14567#14568#14813#18165#21094#21105#21162#21244#21247#21253#21274#21385#21428#21431#21437#21438#21439#21440#21441#21490#21491#21492#21500#21507#21554#21555#21556#21947#21951#22009#22010#22099#22107#22116#22122#22167#22276#23062#22296#22312#22678#22698#22699#22702#22703#22704#22705#22709#22710#22711#22712#22713#22714#22715#22725#22726#22728#22729#22730#22731#22929#22931#22932#22933#22934#22935#23036#23076#23106#23214#23220#23415#23417#23446#23789#23802#23803#23804#23805#23827#23890#23906#24518#24519#24054#24053#24055#24056#24520#24521#24522#24523#24524#24525#24526#24095#24101#24489#24490#24492#24493#24494#24495#24496#24497#24498#24499#24500#24501#24517#24528#24533#24534#24539#24540#24541#24544#24545#24559#24560#24561#24562#24564#24565#24571#24573#24582#24589#24590#24591#24592#24593#24594#24595#24597#24598#24599#24600#24601#24603#24604#24605#24606#24607#24608#24609#24610#24615#24620#24621#24622#24628#24630#24631#24633#24634#24635#24637#24638#24642#24646#24647#24650#24651#24653#24654#24655#24657#24658#24659#24660#24691#24692#24693#24694#24695#24698#24700#24701#24702#24703#24710#24737#24738#24739#24740#24757#24758#24788#25241#25256#25258#25259#25260#25261#25262#25263#25264#25265#25266#25267#25268#25272#25274#25277#25278#25279#25280#25281#25282#25290#25291#25292#25293#25297#25298#25299#25379#25386#25389#25390#25392#25498#25500#25512#25516#25517#25522#25523#25688#25689#25720#25730#25731#25732#25734#25796#25797#25798#25908#25909#25910#25917#26123#26126#26773#26778#26783#26784#26785#26786#26949#26950#26955#26957#26960#27111#27126#27123#27127#27128#27154#27155#27157#27158#27159#27160#27161#27162#27175#27183#27185#27186#27188#27201#27202#27215#27217#27219#27220#27230#27235#27236#27242#27244#27245#27246#27248#27249#27254#27263#27264#27271#27273#27274#27275#27276#27285#27288#27289#27290#27291#27292#27293#27294#27350#27352#27354#27357#27358#27390#27391#27395#27397#27398#27399#27400#27401#27402#27403#27406#27407#27409#27410#27411#27430#27431#27434#27435#27436#27739#27740#27741#27742#27743#27744#27745#27752#27773#27774#27775#27776#27777#27778#27779#27780#27781#27782#27783#27784#27785#27786#27787#27788#27789#27790#27793#27794#27795#27796#27797#27798#27801#27802#27803#27804#27806#27807#27808#27809#27810#27813#27814#27815#27816#27817#27819#27820#27821#27823#27824#27825#27826#27827#27828#27829#27831#27832#27833#27834#27836#27842#27843#27865#27866#27867#27889#27890#27891#27893#27906#27908#27912#27914#27915#27918#27920#27921#27922#27923#27924#27926#27927#27928#27929#27930#27931#27932#27933#27934#27935#27940#27941#27943#27944#27945#27946#27947#27948#27949#25375#25376#25373#25374#25372#27138',2
		while @@fetch_status = 0  
			BEGIN  
			
				Declare @StrWeekoff_Date_W varchar(max)
				declare @Weekoff_Days_W varchar(max)
				declare @Cancel_Weekoff_w varchar(max)
				declare @StrHoliday_Date_W varchar(max)
				declare @Holiday_days_W varchar(max)
				declare @Cancel_Holiday_W varchar (max)
   
				declare @OD_transfer_to_ot numeric(1,0)
				Declare @Branch_id_OD numeric (4,0)
   
				select @BRANCH_ID_OD =	Branch_id from t0095_increment  
				where Increment_ID =( select max(Increment_ID) from t0095_increment where emp_id=@Emp_ID_W and increment_effective_date <=@To_Date) and emp_id=@Emp_ID_W	-- Ankit 12092014 for Same Date Increment
   
				select @OD_transfer_to_ot = Is_OD_Transfer_to_OT from t0040_general_setting where branch_id = @BRANCH_ID_OD and 
				For_Date = (select max(for_date) From T0040_General_Setting where Branch_ID =@BRANCH_ID_OD)  --Added By Ramiz on 16092014
       
				if @OD_transfer_to_ot = 1 
					BEGIN
						/*Commented by Nimesh on 17-Feb-2016*/
						--Exec dbo.SP_EMP_HOLIDAY_DATE_GET1 @Emp_ID_W,@Cmp_ID,@From_Date,@To_Date,null,null,@Is_Cancel_Holiday,@StrHoliday_Date_W output,@Holiday_days_W output,@Cancel_Holiday_W output,0,@Branch_ID,@StrWeekoff_Date_W
						--Exec dbo.SP_EMP_WEEKOFF_DATE_GET1 @Emp_ID_W,@Cmp_ID,@From_Date,@To_Date,null,null,@Is_Cancel_weekoff,'',@StrWeekoff_Date_W output,@Weekoff_Days_W output ,@Cancel_Weekoff_w output,@constraint=''
						--DROP TABLE #Emp_Holiday
						--DROP TABLE #Emp_Weekoff
						/*
						Exec dbo.SP_EMP_HOLIDAY_DATE_GET @Emp_ID_W,@Cmp_ID,@From_Date,@To_Date,null,null,9,@StrHoliday_Date_W output,@Holiday_days_W output,@Cancel_Holiday_W output,0,@Branch_ID,@StrWeekoff_Date_W
						Exec dbo.SP_EMP_WEEKOFF_DATE_GET @Emp_ID_W,@Cmp_ID,@From_Date,@To_Date,null,null,9,'',@StrWeekoff_Date_W output,@Weekoff_Days_W output ,@Cancel_Weekoff_w output
						*/
						--select * from #EMP_HW_CONS where emp_id=21490
						
						--SELECT	@StrHoliday_Date_W=IsNull(HolidayDate,''),
						--		@Holiday_days_W=IsNull(HolidayCount,0),
						--		@Cancel_Holiday_W=IsNull(CancelHoliday,''),
						--		@StrWeekoff_Date_W=IsNull(WeekOffDate,'') + IsNull(CancelWeekOff,''), /*CancelWeekOff Added By Nimesh On 30-Oct-2018 (If Employee takes OD then the Weekoff is getting cancelled) */
						--		@Weekoff_Days_W=IsNull(WeekOffCount,0),
						--		@Cancel_Weekoff_w=IsNull(CancelWeekOff,'')
						--FROM	#EMP_HW_CONS
						--WHERE	EMP_ID=@Emp_ID
						---------------------------------------------------------------------------------------------------------------------------------------
						--Condition Added By Yogesh on 19082022 to Get Data  Branch Wise in Salary OT Approval Screen START
						if @Emp_id!=null or @Emp_id=0
						begin
						SELECT	@StrHoliday_Date_W=IsNull(HolidayDate,''),
								@Holiday_days_W=IsNull(HolidayCount,0),
								@Cancel_Holiday_W=IsNull(CancelHoliday,''),
								@StrWeekoff_Date_W=IsNull(WeekOffDate,'') + IsNull(CancelWeekOff,''), /*CancelWeekOff Added By Nimesh On 30-Oct-2018 (If Employee takes OD then the Weekoff is getting cancelled) */
								@Weekoff_Days_W=IsNull(WeekOffCount,0),
								@Cancel_Weekoff_w=IsNull(CancelWeekOff,'')
						FROM	#EMP_HW_CONS
						WHERE	EMP_ID=@Emp_ID
						end
						else
						begin
						SELECT	@StrHoliday_Date_W=IsNull(HolidayDate,''),
								@Holiday_days_W=IsNull(HolidayCount,0),
								@Cancel_Holiday_W=IsNull(CancelHoliday,''),
								@StrWeekoff_Date_W=IsNull(WeekOffDate,'') + IsNull(CancelWeekOff,''), /*CancelWeekOff Added By Nimesh On 30-Oct-2018 (If Employee takes OD then the Weekoff is getting cancelled) */
								@Weekoff_Days_W=IsNull(WeekOffCount,0),
								@Cancel_Weekoff_w=IsNull(CancelWeekOff,'')
						FROM	#EMP_HW_CONS
						
						end
						--Condition Added By Yogesh on 19082022 to Get Data  Branch Wise in Salary OT Approval Screen START
						---------------------------------------------------------------------------------------------------------------------------------------
						-- select @Emp_ID as empid ,@Weekoff_Days_W as weekoff
					
						DECLARE OT_For_Date CURSOR FOR  							
						SELECT  CAST(DATA  AS DATETIME) AS For_date  
						FROM	dbo.Split ( (@StrHoliday_Date_W) ,';') 
					--select @StrHoliday_Date_W
						OPEN OT_For_Date
						FETCH NEXT FROM OT_For_Date INTO @For_date_W



						
						WHILE @@FETCH_STATUS = 0  
							BEGIN  
							--select @For_date_W as fordate,@Emp_ID_W as empid
							--change by ronakk 09022023 condtion (Is_Approved <>0) after dicuss with sandeep bhai
								IF NOT EXISTS(SELECT Tran_Id FROM dbo.t0160_Ot_Approval WHERE Emp_ID=@Emp_ID_W And For_Date=@For_date_W and Is_Approved <>0)   
									BEGIN 
									
										--Comment this condition by nilesh patel on 13082015 After Discuss with Hardik Bhai due to wrong details show in OT Approval
										INSERT INTO #Data_Temp 
												(Emp_Id,For_date,Duration_in_sec,Shift_ID,Shift_Type,Emp_OT ,Emp_OT_min_Limit,Emp_OT_max_Limit,P_days,OT_Sec,In_Time,Shift_Start_Time,OT_Start_Time ,Shift_Change,Flag ,Weekoff_OT_Sec ,Holiday_OT_Sec ,Chk_By_Superior ,IO_Tran_Id ,OUT_Time )
										SELECT	LA.Emp_id,@For_date_W,		0,	0,			0,			1,		0,				0,				0,		0,	@For_date_W,@For_date_W,		0,			0,			0,	0,case when lad.half_leave_date =@For_date_W then 28800/2 else  28800 end ,				0,				0,		@For_date_W
										FROM	T0120_LEAVE_APPROVAL LA 
												INNER JOIN T0130_LEAVE_APPROVAL_DETAIL LAD on LA.Leave_Approval_ID =LAD.Leave_Approval_ID 
												INNER JOIN T0040_LEAVE_MASTER LM on LAD.leave_id = LM.leave_id 
										WHERE	Leave_Type='Company Purpose' and @for_date_W >= LAD.From_date and @for_date_W <= LAD.To_Date and Emp_id = @Emp_ID_W
												AND LA.Approval_Status = 'A'
												
									END  
									
							
								FETCH NEXT FROM OT_For_Date INTO @For_date_W
							END  
						CLOSE OT_For_Date
						DEALLOCATE OT_For_Date
							
							
						
					--exec [dbo].[SP_CALCULATE_PRESENT_DAYS] 120,'2022-06-01 00:00:00.000','2022-06-30 00:00:00.000',0,0,0,0,0,0,0,'27182#27272#27438#23274#24529#24530#24532#25288#23065#23066#24778#24542#25287#24783#24782#25286#14803#25504#25505#21478#21147#21954#19081#22070#22280#22331#22343#22345#22347#22519#22928#23425#23995#24051#24050#24058#14560#14561#14562#14563#14564#14565#14566#14567#14568#14813#18165#21094#21105#21162#21244#21247#21253#21274#21385#21428#21431#21437#21438#21439#21440#21441#21490#21491#21492#21500#21507#21554#21555#21556#21947#21951#22009#22010#22099#22107#22116#22122#22167#22276#23062#22296#22312#22678#22698#22699#22702#22703#22704#22705#22709#22710#22711#22712#22713#22714#22715#22725#22726#22728#22729#22730#22731#22929#22931#22932#22933#22934#22935#23036#23076#23106#23214#23220#23415#23417#23446#23789#23802#23803#23804#23805#23827#23890#23906#24518#24519#24054#24053#24055#24056#24520#24521#24522#24523#24524#24525#24526#24095#24101#24489#24490#24492#24493#24494#24495#24496#24497#24498#24499#24500#24501#24517#24528#24533#24534#24539#24540#24541#24544#24545#24559#24560#24561#24562#24564#24565#24571#24573#24582#24589#24590#24591#24592#24593#24594#24595#24597#24598#24599#24600#24601#24603#24604#24605#24606#24607#24608#24609#24610#24615#24620#24621#24622#24628#24630#24631#24633#24634#24635#24637#24638#24642#24646#24647#24650#24651#24653#24654#24655#24657#24658#24659#24660#24691#24692#24693#24694#24695#24698#24700#24701#24702#24703#24710#24737#24738#24739#24740#24757#24758#24788#25241#25256#25258#25259#25260#25261#25262#25263#25264#25265#25266#25267#25268#25272#25274#25277#25278#25279#25280#25281#25282#25290#25291#25292#25293#25297#25298#25299#25379#25386#25389#25390#25392#25498#25500#25512#25516#25517#25522#25523#25688#25689#25720#25730#25731#25732#25734#25796#25797#25798#25908#25909#25910#25917#26123#26126#26773#26778#26783#26784#26785#26786#26949#26950#26955#26957#26960#27111#27126#27123#27127#27128#27154#27155#27157#27158#27159#27160#27161#27162#27175#27183#27185#27186#27188#27201#27202#27215#27217#27219#27220#27230#27235#27236#27242#27244#27245#27246#27248#27249#27254#27263#27264#27271#27273#27274#27275#27276#27285#27288#27289#27290#27291#27292#27293#27294#27350#27352#27354#27357#27358#27390#27391#27395#27397#27398#27399#27400#27401#27402#27403#27406#27407#27409#27410#27411#27430#27431#27434#27435#27436#27739#27740#27741#27742#27743#27744#27745#27752#27773#27774#27775#27776#27777#27778#27779#27780#27781#27782#27783#27784#27785#27786#27787#27788#27789#27790#27793#27794#27795#27796#27797#27798#27801#27802#27803#27804#27806#27807#27808#27809#27810#27813#27814#27815#27816#27817#27819#27820#27821#27823#27824#27825#27826#27827#27828#27829#27831#27832#27833#27834#27836#27842#27843#27865#27866#27867#27889#27890#27891#27893#27906#27908#27912#27914#27915#27918#27920#27921#27922#27923#27924#27926#27927#27928#27929#27930#27931#27932#27933#27934#27935#27940#27941#27943#27944#27945#27946#27947#27948#27949#25375#25376#25373#25374#25372#27138',2		
						DECLARE OT_For_Date CURSOR FOR  							
						SELECT  CAST(DATA  AS DATETIME) AS For_date  
						FROM	dbo.Split ( (@StrWeekoff_Date_W) ,';') 
						WHERE	CAST(DATA AS DATETIME) NOT IN (SELECT  CAST(DATA  AS DATETIME) AS For_date  FROM dbo.Split ( (@StrHoliday_Date_W) ,';') )
					
						OPEN OT_For_Date
						FETCH NEXT FROM OT_For_Date INTO @For_date_W
						WHILE @@FETCH_STATUS = 0  
							BEGIN  
								--change by ronakk 09022023 condtion (Is_Approved <>0) after dicuss with sandeep bhai
								IF NOT EXISTS(SELECT Tran_Id FROM dbo.t0160_Ot_Approval WHERE Emp_ID=@Emp_ID_W And For_Date=@For_date_W and Is_Approved <>0)  
									BEGIN
										INSERT	INTO #Data_Temp 
												(Emp_Id,For_date,Duration_in_sec,Shift_ID,Shift_Type,Emp_OT ,Emp_OT_min_Limit,Emp_OT_max_Limit,P_days,OT_Sec,In_Time,Shift_Start_Time,OT_Start_Time ,Shift_Change,Flag ,Weekoff_OT_Sec ,Holiday_OT_Sec ,Chk_By_Superior ,IO_Tran_Id ,OUT_Time )
										SELECT	LA.Emp_id,@For_date_W,		0,	0,			0,			1,		0,				0,				0,		0,	@For_date_W,@For_date_W,		0,			0,			0,	case when lad.half_leave_date =@For_date_W then 28800/2 else  28800 end ,				0,				0,				0,		@For_date_W
										FROM	T0120_LEAVE_APPROVAL LA 
												INNER JOIN T0130_LEAVE_APPROVAL_DETAIL LAD ON LA.Leave_Approval_ID =LAD.Leave_Approval_ID 
												INNER JOIN T0040_LEAVE_MASTER LM on LAD.leave_id = LM.leave_id 
										WHERE	Leave_Type='Company Purpose' AND @for_date_W >= LAD.From_date AND @for_date_W <= LAD.To_Date AND Emp_id = @Emp_ID_W
												AND LA.Approval_Status = 'A'
									END  
								FETCH NEXT FROM OT_For_Date INTO @For_date_W
							END  
						CLOSE OT_For_Date
						DEALLOCATE OT_For_Date
					END	
				FETCH NEXT FROM OT_Emp INTO @Emp_ID_W
			END  
		CLOSE OT_Emp  
		DEALLOCATE OT_Emp  
    -- Ended by rohit

   
		Declare @T_Emp_ID Numeric  
		Declare @T_For_Date datetime  
		Declare @Flag_cur_temp int
		Declare @P_Days_Count  numeric(18,3) 
			Set @P_Days_Count = 0
  
  


    DECLARE OT_cursor CURSOR  
    FOR  
     SELECT d.Emp_ID,d.For_Date FROM #Data d 
     --inner join
     --t0160_Ot_Approval t  on d.Emp_ID = t.Emp_ID And d.For_Date = t.For_Date -- Added Inner join by Hardik 10/09/2012
   OPEN OT_cursor  
    fetch next from OT_cursor into @T_Emp_ID,@T_For_Date  
    while @@fetch_status = 0  
   BEGIN  
    --Commented by Hardik 10/09/2012  
		--change by ronakk 09022023 condtion (Is_Approved <>0) after dicuss with sandeep bhai
    if Not Exists(select Tran_Id from dbo.t0160_Ot_Approval where Emp_ID=@T_Emp_ID And For_Date=@T_For_Date and Is_Approved <>0)  
     Begin  
    insert into #Data_Temp 
    select  * from #Data where Emp_ID=@T_Emp_ID And For_Date=@T_For_Date  
     End  
    fetch next from OT_cursor into @T_Emp_ID,@T_For_Date  
   END  
    CLOSE OT_cursor  
    DEALLOCATE OT_cursor  
    
    Set @P_Days_Count = (Select SUM(P_days) from #data where Emp_ID=@T_Emp_ID And Month(For_Date)=Month(@T_For_Date) and IO_Tran_Id  = 0  )   
   
   CREATE TABLE #Data_Temp_Test (Emp_Id NUMERIC ,
									  For_date DATETIME ,
									  Duration_in_sec NUMERIC ,
									  Shift_ID NUMERIC ,
									  Shift_Type NUMERIC ,
									  Emp_OT NUMERIC ,
									  Emp_OT_min_Limit NUMERIC ,
									  Emp_OT_max_Limit NUMERIC ,
									  P_days NUMERIC(12, 2) DEFAULT 0 ,
									  OT_Sec NUMERIC DEFAULT 0 ,
									  In_Time DATETIME ,
									  Shift_Start_Time DATETIME ,
									  OT_Start_Time NUMERIC DEFAULT 0 ,
									  Shift_Change TINYINT DEFAULT 0 ,
									  Flag INT DEFAULT 0 ,
									  Weekoff_OT_Sec NUMERIC DEFAULT 0 ,
									  Holiday_OT_Sec NUMERIC DEFAULT 0 ,
									  Chk_By_Superior NUMERIC DEFAULT 0 ,
									  IO_Tran_Id NUMERIC DEFAULT 0 ,
									  OUT_Time DATETIME ,
									  Shift_End_Time DATETIME ,			--Ankit 16112013
									  OT_End_Time NUMERIC DEFAULT 0	--Ankit 16112013
									  )  
   
  
	--Added By Jaina 2-12-2015 Start


	CREATE TABLE #Data_Gen   
	(
		Emp_Id numeric,
		For_Date  datetime,
		Branch_Id  Numeric,
		W_CompOff_Min_hours  varchar(500),
		H_CompOff_Min_hours varchar(500),
		CompOff_Min_hours varchar(500)
	)
	
	INSERT INTO #Data_Gen
	SELECT	I.Emp_ID,G.For_Date,I.Branch_ID,G.W_CompOff_Min_Hours,G.H_CompOff_Min_hours,G.CompOff_Min_Hours
	FROM	T0095_INCREMENT I 
		INNER JOIN (SELECT	MAX(I2.Increment_ID) AS Increment_ID
					FROM	T0095_INCREMENT I2 
							INNER JOIN (SELECT	MAX(Increment_Effective_Date) AS Increment_Effective_Date, I3.EMP_ID
										FROM	T0095_INCREMENT I3 INNER JOIN #Data_Temp T ON I3.Emp_ID=T.Emp_Id
										WHERE	Increment_Effective_Date <= @To_Date AND I3.Cmp_ID = @Cmp_ID
										GROUP BY I3.Emp_ID
										) I3 ON I2.Emp_ID=I3.Emp_ID AND I2.Increment_Effective_Date=I3.Increment_Effective_Date
					GROUP BY I2.Emp_ID										
					) I2 ON I2.Increment_ID=I.Increment_ID
		INNER JOIN T0040_GENERAL_SETTING G ON I.Branch_ID=G.Branch_ID AND G.Cmp_ID=I.Cmp_ID
		INNER JOIN (SELECT	MAX(GEN_ID) AS GEN_ID
					FROM	T0040_GENERAL_SETTING G2  
							INNER JOIN (SELECT	MAX(G3.For_Date) AS FOR_DATE, G3.Branch_ID
										FROM	T0040_GENERAL_SETTING G3  
										WHERE	G3.For_Date <= @To_Date AND G3.Cmp_ID = @Cmp_ID
										GROUP BY G3.Branch_ID
										) G3 ON G2.Branch_ID=G3.Branch_ID AND G2.For_Date=G3.FOR_DATE
					GROUP BY G2.Branch_ID
					) G2 ON G2.GEN_ID=G.Gen_ID
		
			--FROM	T0095_Increment t1
			--		INNER JOIN (SELECT emp_id,MAX(Increment_ID)AS Increment_ID
			--						  FROM t0095_increment where cmp_ID = @cmp_ID GROUP BY emp_id
			--					)AS t2 ON t1.emp_id = t2.emp_id AND t1.Increment_ID = t2.Increment_ID
					
			--		INNER JOIN (select GS.For_Date,Gs.Branch_ID,W_CompOff_Min_hours,H_CompOff_Min_hours,CompOff_Min_hours from T0040_GENERAL_SETTING GS 
			--		inner join (
			--						select MAX(For_date) as For_Date,Branch_ID from T0040_General_Setting gs 
			--								where Cmp_ID = @Cmp_ID  and For_Date <= @To_Date group by Branch_ID
			--					)Qry on Qry.Branch_ID = GS.Branch_ID and Qry.For_Date = GS.For_Date
			--	)Gen_Qry ON Gen_Qry.branch_id = t1.branch_id 
			--INNER JOIN #Data_Temp as OA ON OA.Emp_Id = T1.Emp_ID
	--Added By Jaina 2-12-2015 End															
	 

   
   if @Return_Record_set =2
		Begin
		   
				--select *,dbo.F_Return_Hours (Duration_in_Sec) as Working_Hour , dbo.F_Return_Hours (OT_SEc) as OT_Hour,Flag,@P_Days_Count As P_Days_Count, dbo.F_Return_Hours (isnull(Weekoff_OT_Sec,0)) as Weekoff_OT_Hour,
				--dbo.F_Return_Hours (Holiday_OT_Sec) as Holiday_OT_Hour from #Data_Temp OA    
				--inner join dbo.T0080_emp_master E on OA.Emp_ID = E.Emp_ID  
				--where OT_sec > 0  or Weekoff_OT_Sec > 0 or Holiday_OT_Sec > 0 
				--order by OA.For_Date  
  
  --Commented Above code and New Code Added by Ramiz on 05/03/2016 as filters was not working in OT Approval Form
  	IF @For_OT_APPROVAL = 0
			-- Added DateAdd Condition For If OT is Adjust with 05-Dec-2018 and Only Same Date OT Approval Actual OT is consider instead of Adjust OT 
			-- Added By Nilesh Patel on 18-01-2019
			--IF EXISTS(SELECT 1 FROM T0165_ATTENDANCE_APPROVAL WHERE CMP_ID = @CMP_ID AND FOR_DATE >=@FROM_DATE AND FOR_DATE <= DateAdd(Day,1,@TO_DATE) AND ATT_STATUS = 'A')
			--	BEGIN
			--		UPDATE DT
			--			SET DT.DURATION_IN_SEC = (Case When DT.DURATION_IN_SEC > Q.SHIFT_SEC Then DT.DURATION_IN_SEC - Q.SHIFT_SEC Else 0 END),
			--				DT.OT_SEC = CASE WHEN DT.OT_SEC > Q.SHIFT_SEC THEN 
			--									CASE WHEN DT.Emp_OT_Min_Limit > (DT.OT_SEC - Q.SHIFT_SEC) THEN	
			--										0
			--									ELSE  (DT.OT_SEC - Q.SHIFT_SEC) END
			--							ELSE 0 END,
			--				DT.Weekoff_OT_Sec = CASE WHEN G.Tras_Week_OT = 1 AND DT.Weekoff_OT_Sec > Q.SHIFT_SEC THEN DT.Weekoff_OT_Sec - Q.SHIFT_SEC ELSE DT.Weekoff_OT_Sec END,
			--				DT.Holiday_OT_Sec = CASE WHEN G.Tras_Week_OT = 1 AND DT.Holiday_OT_Sec > Q.SHIFT_SEC THEN DT.Holiday_OT_Sec - Q.SHIFT_SEC ELSE DT.Holiday_OT_Sec END
			--		FROM #DATA_TEMP DT INNER JOIN 
			--		(
			--				SELECT EMP_ID,DATEADD(D,-1,FOR_DATE) AS FORDATE,P_DAYS,ATT_STATUS,SHIFT_SEC
			--				FROM T0165_ATTENDANCE_APPROVAL
			--				WHERE CMP_ID = @CMP_ID AND FOR_DATE >=@FROM_DATE AND FOR_DATE <= DateAdd(Day,1,@TO_DATE) AND ATT_STATUS = 'A' and P_Days <> 0
			--		)Q ON DT.EMP_ID =Q.EMP_ID  AND DT.FOR_DATE = Q.FORDATE
			--		INNER JOIN #EMP_GEN_SETTINGS G ON DT.Emp_Id=G.EMP_ID
			--	END
			
			SELECT OA.*,QRY.Branch_ID,E.* ,DBO.F_RETURN_HOURS(DURATION_IN_SEC) AS WORKING_HOUR , DBO.F_RETURN_HOURS(OT_SEC) AS OT_HOUR,FLAG,@P_DAYS_COUNT AS P_DAYS_COUNT, DBO.F_RETURN_HOURS (ISNULL(WEEKOFF_OT_SEC,0)) AS WEEKOFF_OT_HOUR,
			DBO.F_RETURN_HOURS (HOLIDAY_OT_SEC) AS HOLIDAY_OT_HOUR , QRY.Branch_ID as INC_BRANCH_ID , QRY.Dept_ID as INC_DEPT_ID, QRY.Grd_ID as INC_GRD_ID
			FROM #DATA_TEMP OA    
			INNER JOIN DBO.T0080_EMP_MASTER E ON OA.EMP_ID = E.EMP_ID 
			INNER JOIN (SELECT	MAX(I2.Increment_ID) AS Increment_ID , I2.Emp_ID , I2.Branch_ID , I2.Dept_ID , I2.Grd_ID
						FROM	T0095_INCREMENT I2  
								INNER JOIN (SELECT	MAX(Increment_Effective_Date) AS Increment_Effective_Date, I3.EMP_ID
											FROM	T0095_INCREMENT I3 INNER JOIN #DATA_TEMP T ON I3.Emp_ID=T.Emp_Id
											WHERE	Increment_Effective_Date <= @To_Date AND I3.Cmp_ID = @Cmp_ID
											GROUP BY I3.Emp_ID
											) I3 ON I2.Emp_ID=I3.Emp_ID AND I2.Increment_Effective_Date=I3.Increment_Effective_Date
						GROUP BY I2.Emp_ID	, I2.Branch_ID, I2.Dept_ID , I2.Grd_ID								
						) QRY ON QRY.Emp_ID = OA.Emp_Id 
			INNER JOIN T0095_INCREMENT IE ON IE.EMP_ID = QRY.EMP_ID AND IE.Increment_ID=QRY.Increment_ID
			WHERE (OT_SEC > 0  OR WEEKOFF_OT_SEC > 0 OR HOLIDAY_OT_SEC > 0) 
			AND QRY.Branch_ID = IsNull(@BRANCH_ID_FOR_OT, QRY.Branch_ID)
			AND isnull(QRY.Dept_ID,0) = COALESCE(@DEPT_ID_FOR_OT , QRY.Dept_ID,0)  --Change by Jaina 18-08-2017
			AND QRY.Grd_ID = ISNULL(@GRD_ID_FOR_OT , QRY.Grd_ID )
			AND (
					(IE.EMP_HOLIDAY_OT_RATE <> 0 AND DBO.F_RETURN_HOURS (HOLIDAY_OT_SEC) <> '00:00') OR 
					(IE.EMP_WEEKOFF_OT_RATE <> 0 AND DBO.F_RETURN_HOURS (ISNULL(WEEKOFF_OT_SEC,0)) <> '00:00') OR
					(IE.EMP_WEEKDAY_OT_RATE <> 0 AND DBO.F_RETURN_HOURS(OT_SEC) <> '00:00')
				)
							
			ORDER BY OA.FOR_DATE


  -- Ended by Ramiz on 05/03/2016 as filters was not working in OT Approval Form  
   
		End
	else if @Return_Record_set = 8
   BEGIN  
   -- If (@Is_WD = 1 And @Is_WOHO = 1)
    BEGIN
    
				
       select OA.*,dbo.F_Return_Hours (Duration_in_Sec) as Working_Hour , dbo.F_Return_Hours (ISNULL(OT_SEC,0) + isnull(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) as OT_Hour, dbo.F_Return_Hours (Duration_in_Sec + ISNULL(OT_Sec,0) + ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) as Actual_Worked_Hrs,@P_Days_Count As P_Days_Count, dbo.F_Return_Hours (ISNULL(Weekoff_OT_Sec,0)) as Weekoff_OT_Hour,
				    dbo.F_Return_Hours (ISNULL(Holiday_OT_Sec,0)) as Holiday_OT_Hour, CA.Approve_Status as Application_Status from #Data_Temp OA    
        INNER JOIN dbo.T0080_emp_master E on OA.Emp_ID = E.Emp_ID  
        INNER JOIN dbo.T0120_CompOff_Approval CA on OA.Emp_Id = CA.Emp_ID and OA.For_date=CA.Extra_Work_Date 
      where Cast(Replace(dbo.F_Return_Hours (OT_SEC),':','.') as numeric(18,3)) >= Cast(Replace(E.CompOff_Min_hrs,':','.') as numeric(18,3)) or Cast(Replace(dbo.F_Return_Hours (Weekoff_OT_Sec),':','.') as numeric(18,3)) >= Cast(Replace(E.CompOff_Min_hrs,':','.') as numeric(18,3)) or Cast(Replace(dbo.F_Return_Hours (Holiday_OT_Sec),':','.') as numeric(18,3)) >= Cast(Replace(E.CompOff_Min_hrs,':','.') as numeric(18,3)) 
       UNION
      select OA.*,dbo.F_Return_Hours (Duration_in_Sec) as Working_Hour , dbo.F_Return_Hours (ISNULL(OT_SEC,0) + isnull(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) as OT_Hour, dbo.F_Return_Hours (Duration_in_Sec + ISNULL(OT_Sec,0) + ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) as Actual_Worked_Hrs, @P_Days_Count As P_Days_Count, dbo.F_Return_Hours (ISNULL(Weekoff_OT_Sec,0)) as Weekoff_OT_Hour,
				    dbo.F_Return_Hours (ISNULL(Holiday_OT_Sec,0)) as Holiday_OT_Hour, CA.Application_Status  from #Data_Temp OA    
        INNER JOIN dbo.T0080_emp_master E on OA.Emp_ID = E.Emp_ID  
        INNER JOIN dbo.T0100_CompOff_Application CA on OA.Emp_Id = CA.Emp_ID and OA.For_date=CA.Extra_Work_Date 
      where Cast(Replace(dbo.F_Return_Hours (OT_SEC),':','.') as numeric(18,3)) >= Cast(Replace(E.CompOff_Min_hrs,':','.') as numeric(18,3)) or Cast(Replace(dbo.F_Return_Hours (Weekoff_OT_Sec),':','.') as numeric(18,3)) >= Cast(Replace(E.CompOff_Min_hrs,':','.') as numeric(18,3)) or Cast(Replace(dbo.F_Return_Hours (Holiday_OT_Sec),':','.') as numeric(18,3)) >= Cast(Replace(E.CompOff_Min_hrs,':','.') as numeric(18,3)) 
       UNION					
				Select Qry1.* from 
       (select dt.*,dbo.F_Return_Hours (Duration_in_Sec) as Working_Hour , dbo.F_Return_Hours (ISNULL(OT_SEC,0) + isnull(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) as OT_Hour, dbo.F_Return_Hours (Duration_in_Sec + ISNULL(OT_Sec,0) + ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) as Actual_Worked_Hrs,@P_Days_Count As P_Days_Count, dbo.F_Return_Hours (ISNULL(Weekoff_OT_Sec,0)) as Weekoff_OT_Hour,
				    dbo.F_Return_Hours (ISNULL(Holiday_OT_Sec,0)) as Holiday_OT_Hour, '-' as application_status from #Data_Temp DT 
				    where For_date not in (      
       select For_date from #Data_Temp OA    
        INNER JOIN dbo.T0080_emp_master E on OA.Emp_ID = E.Emp_ID  
        INNER JOIN dbo.T0120_CompOff_Approval CA on OA.Emp_Id = CA.Emp_ID and OA.For_date=CA.Extra_Work_Date 
      where Cast(Replace(dbo.F_Return_Hours (OT_SEC),':','.') as numeric(18,3)) >= Cast(Replace(E.CompOff_Min_hrs,':','.') as numeric(18,3)) or Cast(Replace(dbo.F_Return_Hours (Weekoff_OT_Sec),':','.') as numeric(18,3)) >= Cast(Replace(E.CompOff_Min_hrs,':','.') as numeric(18,3)) or Cast(Replace(dbo.F_Return_Hours (Holiday_OT_Sec),':','.') as numeric(18,3)) >= Cast(Replace(E.CompOff_Min_hrs,':','.') as numeric(18,3)) 
       UNION
      select For_date from #Data_Temp OA    
        INNER JOIN dbo.T0080_emp_master E on OA.Emp_ID = E.Emp_ID  
        INNER JOIN dbo.T0100_CompOff_Application CA on OA.Emp_Id = CA.Emp_ID and OA.For_date=CA.Extra_Work_Date 
      where Cast(Replace(dbo.F_Return_Hours (OT_SEC),':','.') as numeric(18,3)) >= Cast(Replace(E.CompOff_Min_hrs,':','.') as numeric(18,3)) or Cast(Replace(dbo.F_Return_Hours (Weekoff_OT_Sec),':','.') as numeric(18,3)) >= Cast(Replace(E.CompOff_Min_hrs,':','.') as numeric(18,3)) or Cast(Replace(dbo.F_Return_Hours (Holiday_OT_Sec),':','.') as numeric(18,3)) >= Cast(Replace(E.CompOff_Min_hrs,':','.') as numeric(18,3))) 
					) Qry1 inner join dbo.T0080_EMP_MASTER em on Qry1.Emp_Id = em.Emp_ID
				Where Cast(Replace(dbo.F_Return_Hours (OT_SEC),':','.') as numeric(18,3)) >= Cast(Replace(Em.CompOff_Min_hrs,':','.') as numeric(18,3)) or Cast(Replace(dbo.F_Return_Hours (Weekoff_OT_Sec),':','.') as numeric(18,3)) >= Cast(Replace(Em.CompOff_Min_hrs,':','.') as numeric(18,3)) or Cast(Replace(dbo.F_Return_Hours (Holiday_OT_Sec),':','.') as numeric(18,3)) >= Cast(Replace(Em.CompOff_Min_hrs,':','.') as numeric(18,3))
      order by OA.For_Date
    END
			/*
    Else If (@Is_WD = 1 And @Is_WOHO = 0)
    BEGIN
			
      select OA.*,dbo.F_Return_Hours (Duration_in_Sec) as Working_Hour , dbo.F_Return_Hours (ISNULL(OT_SEC,0)) as OT_Hour, dbo.F_Return_Hours (Duration_in_Sec + ISNULL(OT_Sec,0)) as Actual_Worked_Hrs, @P_Days_Count As P_Days_Count, dbo.F_Return_Hours (ISNULL(Weekoff_OT_Sec,0)) as Weekoff_OT_Hour,
				    dbo.F_Return_Hours (ISNULL(Holiday_OT_Sec,0)) as Holiday_OT_Hour, CA.Approve_Status as Application_Status from #Data_Temp OA    
        INNER JOIN dbo.T0080_emp_master E on OA.Emp_ID = E.Emp_ID  
        INNER JOIN dbo.T0120_CompOff_Approval CA on OA.Emp_Id = CA.Emp_ID and OA.For_date=CA.Extra_Work_Date 
      where Cast(Replace(dbo.F_Return_Hours (OT_SEC),':','.') as numeric(18,3)) >= Cast(Replace(E.CompOff_Min_hrs,':','.') as numeric(18,3)) and Cast(Replace(dbo.F_Return_Hours (OT_SEC),':','.') as numeric(18,3)) <> 0 
     UNION
     select OA.*,dbo.F_Return_Hours (Duration_in_Sec) as Working_Hour , dbo.F_Return_Hours (ISNULL(OT_SEC,0)) as OT_Hour, dbo.F_Return_Hours (Duration_in_Sec + ISNULL(OT_Sec,0)) as Actual_Worked_Hrs, @P_Days_Count As P_Days_Count, dbo.F_Return_Hours (ISNULL(Weekoff_OT_Sec,0)) as Weekoff_OT_Hour,
				    dbo.F_Return_Hours (ISNULL(Holiday_OT_Sec,0)) as Holiday_OT_Hour, CA.Application_Status from #Data_Temp OA    
        INNER JOIN dbo.T0080_emp_master E on OA.Emp_ID = E.Emp_ID  
        INNER JOIN dbo.T0100_CompOff_Application CA on OA.Emp_Id = CA.Emp_ID and OA.For_date=CA.Extra_Work_Date 
      where Cast(Replace(dbo.F_Return_Hours (OT_SEC),':','.') as numeric(18,3)) >= Cast(Replace(E.CompOff_Min_hrs,':','.') as numeric(18,3)) and Cast(Replace(dbo.F_Return_Hours (OT_SEC),':','.') as numeric(18,3)) <> 0 
     UNION
     Select Qry1.* from 
       (select dt.*,dbo.F_Return_Hours (Duration_in_Sec) as Working_Hour , dbo.F_Return_Hours (ISNULL(OT_SEC,0)) as OT_Hour, dbo.F_Return_Hours (Duration_in_Sec + ISNULL(OT_Sec,0)) as Actual_Worked_Hrs,@P_Days_Count As P_Days_Count, dbo.F_Return_Hours (ISNULL(Weekoff_OT_Sec,0)) as Weekoff_OT_Hour,
				    dbo.F_Return_Hours (ISNULL(Holiday_OT_Sec,0)) as Holiday_OT_Hour, '-' as application_status from #Data_Temp DT 
				    where For_date not in (      
select For_date from #Data_Temp OA    
        INNER JOIN dbo.T0080_emp_master E on OA.Emp_ID = E.Emp_ID  
        INNER JOIN dbo.T0120_CompOff_Approval CA on OA.Emp_Id = CA.Emp_ID and OA.For_date=CA.Extra_Work_Date 
      where Cast(Replace(dbo.F_Return_Hours (OT_SEC),':','.') as numeric(18,3)) >= Cast(Replace(E.CompOff_Min_hrs,':','.') as numeric(18,3)) and Cast(Replace(dbo.F_Return_Hours (OT_SEC),':','.') as numeric(18,3)) <> 0 
       UNION
      select For_date from #Data_Temp OA    
        INNER JOIN dbo.T0080_emp_master E on OA.Emp_ID = E.Emp_ID  
        INNER JOIN dbo.T0100_CompOff_Application CA on OA.Emp_Id = CA.Emp_ID and OA.For_date=CA.Extra_Work_Date 
      where Cast(Replace(dbo.F_Return_Hours (OT_SEC),':','.') as numeric(18,3)) >= Cast(Replace(E.CompOff_Min_hrs,':','.') as numeric(18,3))) and Cast(Replace(dbo.F_Return_Hours (OT_SEC),':','.') as numeric(18,3)) <> 0 
					) Qry1 inner join T0080_EMP_MASTER em on Qry1.Emp_Id = em.Emp_ID
				Where Cast(Replace(dbo.F_Return_Hours (OT_SEC),':','.') as numeric(18,3)) >= Cast(Replace(Em.CompOff_Min_hrs,':','.') as numeric(18,3)) and Cast(Replace(dbo.F_Return_Hours (OT_SEC),':','.') as numeric(18,3)) <> 0 
      order by OA.For_Date      
    END
    Else If (@Is_WD = 0 And @Is_WOHO = 1)
    BEGIN  
			   
      select OA.*,dbo.F_Return_Hours (Duration_in_Sec) as Working_Hour , dbo.F_Return_Hours (ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) as OT_Hour, dbo.F_Return_Hours (ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) as Actual_Worked_Hrs, @P_Days_Count As P_Days_Count, dbo.F_Return_Hours (ISNULL(Weekoff_OT_Sec,0)) as Weekoff_OT_Hour,
				    dbo.F_Return_Hours (ISNULL(Holiday_OT_Sec,0)) as Holiday_OT_Hour, CA.Approve_Status as Application_Status from #Data_Temp OA    
        INNER JOIN dbo.T0080_emp_master E on OA.Emp_ID = E.Emp_ID  
        INNER JOIN dbo.T0120_CompOff_Approval CA on OA.Emp_Id = CA.Emp_ID and OA.For_date=CA.Extra_Work_Date 
      where Cast(Replace(dbo.F_Return_Hours (Weekoff_OT_Sec),':','.') as numeric(18,3)) >= Cast(Replace(E.CompOff_Min_hrs,':','.') as numeric(18,3)) or Cast(Replace(dbo.F_Return_Hours (Holiday_OT_Sec),':','.') as numeric(18,3)) >= Cast(Replace(E.CompOff_Min_hrs,':','.') as numeric(18,3)) 
        and (Cast(Replace(dbo.F_Return_Hours (Weekoff_OT_Sec),':','.') as numeric(18,3)) <> 0 or Cast(Replace(dbo.F_Return_Hours (Holiday_OT_Sec),':','.') as numeric(18,3)) <> 0)
     UNION
     select OA.*,dbo.F_Return_Hours (Duration_in_Sec) as Working_Hour , dbo.F_Return_Hours (ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) as OT_Hour, dbo.F_Return_Hours (ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) as Actual_Worked_Hrs, @P_Days_Count As P_Days_Count, dbo.F_Return_Hours (ISNULL(Weekoff_OT_Sec,0)) as Weekoff_OT_Hour,
				    dbo.F_Return_Hours (ISNULL(Holiday_OT_Sec,0)) as Holiday_OT_Hour, CA.Application_Status from #Data_Temp OA    
        INNER JOIN dbo.T0080_emp_master E on OA.Emp_ID = E.Emp_ID  
        INNER JOIN dbo.T0100_CompOff_Application CA on OA.Emp_Id = CA.Emp_ID and OA.For_date=CA.Extra_Work_Date 
      where Cast(Replace(dbo.F_Return_Hours (Weekoff_OT_Sec),':','.') as numeric(18,3)) >= Cast(Replace(E.CompOff_Min_hrs,':','.') as numeric(18,3)) or Cast(Replace(dbo.F_Return_Hours (Holiday_OT_Sec),':','.') as numeric(18,3)) >= Cast(Replace(E.CompOff_Min_hrs,':','.') as numeric(18,3))
        and (Cast(Replace(dbo.F_Return_Hours (Weekoff_OT_Sec),':','.') as numeric(18,3)) <> 0 or Cast(Replace(dbo.F_Return_Hours (Holiday_OT_Sec),':','.') as numeric(18,3)) <> 0)        
     UNION
     Select Qry1.* from 
   (select dt.*,dbo.F_Return_Hours (Duration_in_Sec) as Working_Hour , dbo.F_Return_Hours (ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) as OT_Hour, dbo.F_Return_Hours (ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) as Actual_Worked_Hrs, @P_Days_Count As P_Days_Count, dbo.F_Return_Hours (ISNULL(Weekoff_OT_Sec,0)) as Weekoff_OT_Hour,
				    dbo.F_Return_Hours (ISNULL(Holiday_OT_Sec,0)) as Holiday_OT_Hour, '-' as application_status from #Data_Temp DT 
				    where For_date not in (      
       select For_date from #Data_Temp OA    
        INNER JOIN dbo.T0080_emp_master E on OA.Emp_ID = E.Emp_ID  
        INNER JOIN dbo.T0120_CompOff_Approval CA on OA.Emp_Id = CA.Emp_ID and OA.For_date=CA.Extra_Work_Date 
      where Cast(Replace(dbo.F_Return_Hours (Weekoff_OT_Sec),':','.') as numeric(18,3)) >= Cast(Replace(E.CompOff_Min_hrs,':','.') as numeric(18,3)) or Cast(Replace(dbo.F_Return_Hours (Holiday_OT_Sec),':','.') as numeric(18,3)) >= Cast(Replace(E.CompOff_Min_hrs,':','.') as numeric(18,3)) 
        and (Cast(Replace(dbo.F_Return_Hours (Weekoff_OT_Sec),':','.') as numeric(18,3)) <> 0 or Cast(Replace(dbo.F_Return_Hours (Holiday_OT_Sec),':','.') as numeric(18,3)) <> 0)
       UNION
      select For_date from #Data_Temp OA    
        INNER JOIN dbo.T0080_emp_master E on OA.Emp_ID = E.Emp_ID  
        INNER JOIN dbo.T0100_CompOff_Application CA on OA.Emp_Id = CA.Emp_ID and OA.For_date=CA.Extra_Work_Date 
      where Cast(Replace(dbo.F_Return_Hours (Weekoff_OT_Sec),':','.') as numeric(18,3)) >= Cast(Replace(E.CompOff_Min_hrs,':','.') as numeric(18,3)) or Cast(Replace(dbo.F_Return_Hours (Holiday_OT_Sec),':','.') as numeric(18,3)) >= Cast(Replace(E.CompOff_Min_hrs,':','.') as numeric(18,3))) 
        and (Cast(Replace(dbo.F_Return_Hours (Weekoff_OT_Sec),':','.') as numeric(18,3)) <> 0 or Cast(Replace(dbo.F_Return_Hours (Holiday_OT_Sec),':','.') as numeric(18,3)) <> 0)
					) Qry1 inner join dbo.T0080_EMP_MASTER em on Qry1.Emp_Id = em.Emp_ID
				Where Cast(Replace(dbo.F_Return_Hours (Weekoff_OT_Sec),':','.') as numeric(18,3)) >= Cast(Replace(Em.CompOff_Min_hrs,':','.') as numeric(18,3)) or Cast(Replace(dbo.F_Return_Hours (Holiday_OT_Sec),':','.') as numeric(18,3)) >= Cast(Replace(Em.CompOff_Min_hrs,':','.') as numeric(18,3)) 
				 and (Cast(Replace(dbo.F_Return_Hours (Weekoff_OT_Sec),':','.') as numeric(18,3)) <> 0 or Cast(Replace(dbo.F_Return_Hours (Holiday_OT_Sec),':','.') as numeric(18,3)) <> 0)
      order by OA.For_Date
    END
    Else If (@Is_WD = 0 And @Is_WOHO = 0)
    BEGIN
      Raiserror('@@Comp-off not Applicable@@',18,2)
      Return -1
    END
    */
   End 
   
      -------------------------
			ELSE
				IF @Return_Record_set = 9
					BEGIN 
						--IF (@Is_WD = 1)
							BEGIN
								-- Added Nilesh Patel on 20072018 --For Cliantha -- if Employee Working 18 Hours next absent day adjust with previouse day OT and Deduct working hours from OT.
								--IF Exists(SELECT 1 FROM T0165_ATTENDANCE_APPROVAL WHERE CMP_ID = @CMP_ID AND FOR_DATE >=@FROM_DATE AND FOR_DATE <=@TO_DATE AND ATT_STATUS = 'A')
								--	Begin
								--		UPDATE DT
								--			SET DT.DURATION_IN_SEC = (Case When DT.DURATION_IN_SEC > Q.SHIFT_SEC Then DT.DURATION_IN_SEC - Q.SHIFT_SEC Else 0 END),
								--				DT.OT_SEC = CASE WHEN DT.OT_SEC > Q.SHIFT_SEC THEN 
								--								CASE WHEN DT.Emp_OT_Min_Limit > (DT.OT_SEC - Q.SHIFT_SEC) THEN	
								--									0
								--								ELSE  (DT.OT_SEC - Q.SHIFT_SEC) END
								--							ELSE 0 END,
								--				DT.Weekoff_OT_Sec = CASE WHEN G.Tras_Week_OT = 1 AND DT.Weekoff_OT_Sec > Q.SHIFT_SEC THEN DT.Weekoff_OT_Sec - Q.SHIFT_SEC ELSE DT.Weekoff_OT_Sec END,
								--				DT.Holiday_OT_Sec = CASE WHEN G.Tras_Week_OT = 1 AND DT.Holiday_OT_Sec > Q.SHIFT_SEC THEN DT.Holiday_OT_Sec - Q.SHIFT_SEC ELSE DT.Holiday_OT_Sec END
								--		FROM #DATA_TEMP DT INNER JOIN 
								--		(
								--				SELECT EMP_ID,DATEADD(D,-1,FOR_DATE) AS FORDATE,P_DAYS,ATT_STATUS,SHIFT_SEC
								--				FROM T0165_ATTENDANCE_APPROVAL
								--				WHERE CMP_ID = @CMP_ID AND FOR_DATE >=@FROM_DATE AND FOR_DATE <=@TO_DATE AND ATT_STATUS = 'A' AND P_DAYS <> 0
								--		)Q ON DT.EMP_ID =Q.EMP_ID  AND DT.FOR_DATE = Q.FORDATE
								--		INNER JOIN #EMP_GEN_SETTINGS G ON DT.Emp_Id=G.EMP_ID
								--	End
								
								SELECT	OA.*,
										dbo.F_Return_Hours(Duration_in_Sec - OT_SEC) AS Working_Hour,
										CASE WHEN DATEDIFF(SECOND,In_Time,shift_Start_time)>=3600 
										OR DATEDIFF(SECOND,Shift_End_Time,Out_Time)>=3600 THEN 
										dbo.F_Return_Hours(ISNULL(OT_SEC, 0)) 
										ELSE dbo.F_Return_Hours( 0) END 
										AS OT_Hour,
										dbo.F_Return_Hours(Duration_in_Sec/* + ISNULL(OT_Sec,0)*/) AS Actual_Worked_Hrs,
										@P_Days_Count AS P_Days_Count,
										dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0)) AS Weekoff_OT_Hour,
										dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec,0)) AS Holiday_OT_Hour,
										CA.Approve_Status AS Application_Status,
										'WD' AS DayFlag,dbo.F_Return_Hours(DATEDIFF(SECOND,shift_start_time,shift_end_time)) AS Shift_Hours,
										CONVERT(NVARCHAR(8),In_Time,108) AS In_Time_Actual,CONVERT(NVARCHAR(8),Out_Time,108) AS Out_Time_Actual
								FROM	#Data_Temp OA
								INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
								INNER JOIN dbo.T0120_CompOff_Approval CA ON OA.Emp_Id = CA.Emp_ID AND OA.For_date = CA.Extra_Work_Date
								INNER JOIN (SELECT	t1.emp_id, branch_id
											FROM	T0095_Increment t1  
											INNER JOIN (SELECT emp_id, MAX(Increment_ID) AS Increment_ID	-- Ankit 12092014 for Same Date Increment
														FROM  t0095_increment where cmp_ID = @cmp_ID
														GROUP BY emp_id) AS t2 ON t1.emp_id = t2.emp_id AND t1.Increment_ID = t2.Increment_ID)
										AS inc ON oa.emp_id = inc.emp_id
								INNER JOIN  (select GS.gen_ID,GS.Branch_ID,GS.CompOff_Min_hours from T0040_General_Setting GS inner join 
													(select Branch_ID,max(For_Date) as For_Date from T0040_General_Setting  
													 where cmp_ID = @Cmp_ID and For_Date <= @To_Date group by Branch_ID) qry on Qry.For_Date = GS.For_Date and Qry.Branch_ID = GS.For_Date) gs  ON gs.branch_id = inc.branch_id
								WHERE	CAST(REPLACE(dbo.F_Return_Hours(OT_SEC),':', '.') AS numeric(18,3)) >= CASE
															  WHEN CAST(REPLACE(gs.CompOff_Min_hours,':', '.') AS numeric(18,3)) = 0
															  THEN CAST(REPLACE(Isnull(Case when E.CompOff_Min_hrs = '' then '00:00' else e.CompOff_Min_hrs end ,'00:00'),':', '.') AS numeric(18,3))
															  ELSE CAST(REPLACE(gs.CompOff_Min_hours,':', '.') AS numeric(18,3))
															  END AND CAST(REPLACE(dbo.F_Return_Hours(OT_SEC),':', '.') AS numeric(18,3)) <> 0
								UNION
								SELECT	OA.*,
										dbo.F_Return_Hours(Duration_in_Sec - OT_SEC)
										AS Working_Hour,
										CASE WHEN DATEDIFF(SECOND,In_Time,shift_Start_time)>=3600 
										OR DATEDIFF(SECOND,Shift_End_Time,Out_Time)>=3600 THEN 
										dbo.F_Return_Hours(ISNULL(OT_SEC, 0)) 
										ELSE dbo.F_Return_Hours( 0) END 
										AS OT_Hour,
										dbo.F_Return_Hours(Duration_in_Sec /*+ ISNULL(OT_Sec,0)*/) AS Actual_Worked_Hrs,
										@P_Days_Count AS P_Days_Count,
										dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,
															  0)) AS Weekoff_OT_Hour,
										dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec,
															  0)) AS Holiday_OT_Hour,
										CA.Application_Status, 'WD' AS DayFlag,dbo.F_Return_Hours(DATEDIFF(SECOND,shift_start_time,shift_end_time)) AS Shift_Hours,
										CONVERT(NVARCHAR(8),In_Time,108) AS In_Time_Actual,CONVERT(NVARCHAR(8),Out_Time,108) AS Out_Time_Actual
								FROM	#Data_Temp OA
								INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
								INNER JOIN dbo.T0100_CompOff_Application CA ON OA.Emp_Id = CA.Emp_ID AND OA.For_date = CA.Extra_Work_Date
								INNER JOIN (SELECT	t1.emp_id, branch_id
											FROM	T0095_Increment t1
											INNER JOIN (SELECT emp_id,
															  MAX(Increment_ID)	-- Ankit 12092014 for Same Date Increment
															  AS Increment_ID
														FROM  t0095_increment where cmp_ID = @cmp_ID
														GROUP BY emp_id) AS t2 ON t1.emp_id = t2.emp_id AND t1.Increment_ID = t2.Increment_ID)
										AS inc ON oa.emp_id = inc.emp_id
								INNER JOIN  (select GS.gen_ID,GS.Branch_ID,GS.CompOff_Min_hours from T0040_General_Setting GS inner join 
													(select Branch_ID,max(For_Date) as For_Date from T0040_General_Setting  
													 where cmp_ID = @Cmp_ID and For_Date <= @To_Date group by Branch_ID) qry on Qry.For_Date = GS.For_Date and Qry.Branch_ID = GS.For_Date) gs  ON gs.branch_id = inc.branch_id
								WHERE	CAST(REPLACE(dbo.F_Return_Hours(OT_SEC),':', '.') AS numeric(18,3)) >= CASE
															  WHEN CAST(REPLACE(gs.CompOff_Min_hours,':', '.') AS numeric(18,3)) = 0
															  THEN CAST(REPLACE(Isnull(Case when E.CompOff_Min_hrs = '' then '00:00' else e.CompOff_Min_hrs end ,'00:00'),':', '.') AS numeric(18,3))
															  ELSE CAST(REPLACE(gs.CompOff_Min_hours,':', '.') AS numeric(18,3))
															  END AND CAST(REPLACE(dbo.F_Return_Hours(OT_SEC),':', '.') AS numeric(18,3)) <> 0
								UNION
								SELECT	Qry1.*
								FROM	(SELECT	dt.*,
												dbo.F_Return_Hours(Duration_in_Sec - OT_SEC)
												AS Working_Hour,
												CASE WHEN DATEDIFF(SECOND,In_Time,shift_Start_time)>=3600 
												OR DATEDIFF(SECOND,Shift_End_Time,Out_Time)>=3600 THEN 
												dbo.F_Return_Hours(ISNULL(OT_SEC, 0)) 
												ELSE dbo.F_Return_Hours( 0) END 
												AS OT_Hour,
												dbo.F_Return_Hours(Duration_in_Sec/* + ISNULL(OT_Sec,0)*/) AS Actual_Worked_Hrs,
												@P_Days_Count AS P_Days_Count,
												dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0)) AS Weekoff_OT_Hour,
												dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec,0)) AS Holiday_OT_Hour,
												'-' AS application_status,
												'WD' AS DayFlag,dbo.F_Return_Hours(DATEDIFF(SECOND,shift_start_time,shift_end_time)) AS Shift_Hours,
										CONVERT(NVARCHAR(8),In_Time,108) AS In_Time_Actual,CONVERT(NVARCHAR(8),Out_Time,108) AS Out_Time_Actual
										 FROM	#Data_Temp DT
										 WHERE	For_date NOT IN (
												SELECT	OA.For_Date
												FROM	[#Data_Temp] AS OA
												INNER JOIN T0080_EMP_MASTER AS E ON OA.Emp_ID = E.Emp_ID
												INNER JOIN T0120_CompOff_Approval AS CA  ON OA.Emp_Id = CA.Emp_ID AND OA.For_date = CA.Extra_Work_Date
												INNER JOIN (SELECT t1.Emp_ID, t1.Branch_ID
															FROM T0095_INCREMENT t1  
															INNER JOIN 
															(SELECT Emp_ID, MAX(Increment_ID) AS Increment_ID	-- Ankit 12092014 for Same Date Increment
															  FROM T0095_INCREMENT where cmp_ID = @cmp_ID
															  GROUP BY Emp_ID)
															  AS t2 ON t1.emp_id = t2.Emp_ID AND t1.Increment_ID = t2.Increment_ID)
														AS inc ON OA.Emp_ID = inc.Emp_ID
												INNER JOIN  (select GS.gen_ID,GS.Branch_ID,GS.CompOff_Min_hours from T0040_General_Setting GS inner join 
													(select Branch_ID,max(For_Date) as For_Date from T0040_General_Setting  
													 where cmp_ID = @Cmp_ID and For_Date <= @To_Date group by Branch_ID) qry on Qry.For_Date = GS.For_Date and qry.Branch_ID = GS.Branch_ID) gs  ON gs.branch_id = inc.branch_id
												WHERE	(CAST(REPLACE(dbo.F_Return_Hours(OT_SEC),':', '.') AS numeric(18,3)) >= CASE
															  WHEN CAST(REPLACE(gs.CompOff_Min_hours,':', '.') AS numeric(18,3)) = 0
															  THEN CAST(REPLACE(Isnull(Case when E.CompOff_Min_hrs = '' then '00:00' else e.CompOff_Min_hrs end ,'00:00'),':', '.') AS numeric(18,3))
															  ELSE CAST(REPLACE(gs.CompOff_Min_hours,':', '.') AS numeric(18,3))
															  END) AND (CAST(REPLACE(dbo.F_Return_Hours(OT_SEC),':', '.') AS numeric(18,3)) <> 0)
												UNION
												SELECT	OA.For_Date
												FROM	[#Data_Temp] AS OA
												INNER JOIN T0080_EMP_MASTER AS E ON OA.Emp_ID = E.Emp_ID
												INNER JOIN T0100_CompOff_Application AS CA  ON OA.Emp_Id = CA.Emp_ID AND OA.For_date = CA.Extra_Work_Date
												INNER JOIN (SELECT t1.Emp_ID, t1.Branch_ID 
															FROM T0095_INCREMENT t1  
															INNER JOIN (SELECT
															  Emp_ID,
															  MAX(Increment_ID)	-- Ankit 12092014 for Same Date Increment
															  AS Increment_ID
															  FROM
															  T0095_INCREMENT where cmp_ID = @cmp_ID
															  GROUP BY Emp_ID)
															  AS t2 ON t1.emp_id = t2.Emp_ID AND t1.Increment_ID = t2.Increment_ID)
														AS inc ON OA.Emp_ID = inc.Emp_ID
												INNER JOIN T0040_GENERAL_SETTING AS gs  ON gs.Branch_ID = inc.Branch_ID
												WHERE	(CAST(REPLACE(dbo.F_Return_Hours(OT_SEC),':', '.') AS numeric(18,3)) >= CASE
															  WHEN CAST(REPLACE(gs.CompOff_Min_hours,':', '.') AS numeric(18,3)) = 0
															  THEN CAST(REPLACE(E.CompOff_Min_hrs,':', '.') AS numeric(18,3))
															  ELSE CAST(REPLACE(gs.CompOff_Min_hours,':', '.') AS numeric(18,3))
															  END) AND (CAST(REPLACE(dbo.F_Return_Hours(OT_SEC),':', '.') AS numeric(18,3)) <> 0))) Qry1
								INNER JOIN T0080_EMP_MASTER em ON Qry1.Emp_Id = em.Emp_ID
								INNER JOIN (SELECT	t1.emp_id, t1.branch_id
											FROM	T0095_Increment t1  
											INNER JOIN (SELECT emp_id,MAX(Increment_ID) AS Increment_ID	-- Ankit 12092014 for Same Date Increment
														FROM  t0095_increment where cmp_ID = @cmp_ID
														GROUP BY emp_id) AS t2 ON t1.emp_id = t2.emp_id AND t1.Increment_ID = t2.Increment_ID)
										AS inc ON Qry1.Emp_ID = inc.emp_id
								INNER JOIN  (select GS.gen_ID,GS.Branch_ID,GS.CompOff_Min_hours from T0040_General_Setting GS inner join 
													(select Branch_ID,max(For_Date) as For_date	 from T0040_General_Setting  
													 where cmp_ID = @Cmp_ID and For_Date <= @To_Date group by Branch_ID) qry on Qry.For_date = GS.For_date and Qry.Branch_ID = GS.Branch_ID) gs  ON gs.branch_id = inc.branch_id
								where CAST(REPLACE(dbo.F_Return_Hours(OT_SEC),':', '.') AS numeric(18,3)) >= CASE 
															  WHEN 
															  CAST(REPLACE(isnull(															 
															  case when 
															   gs.CompOff_Min_hours ='' then '00:00' else gs.CompOff_Min_hours end															  
															  ,'00:00'),':', '.') AS numeric(18,3)) = 0
															  THEN CAST(REPLACE(isnull(
															  
															 case when  Em.CompOff_Min_hrs='' then '00:00' else Em.CompOff_Min_hrs end
															  
															  ,'00:00'),':', '.') AS numeric(18,3))
															  ELSE CAST(REPLACE(isnull(															  
															   case when gs.CompOff_Min_hours='' then '00:00' else gs.CompOff_Min_hours end															  
															  ,'00:00'),':', '.') AS numeric(18,3))
														  END AND 
														  
														  
														  CAST(REPLACE(dbo.F_Return_Hours(OT_SEC),':', '.') AS numeric(18,3)) <> 0
								ORDER BY OA.For_Date      
							END
					END
				ELSE
					IF @Return_Record_set = 10
						BEGIN 
							
							IF (@Is_HO_CompOff = 1 or @Is_HO_CompOff is null)
								BEGIN    
									SELECT	OA.*,
											dbo.F_Return_Hours(Duration_in_Sec)
											AS Working_Hour,
											--dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) AS OT_Hour,
											--dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) AS Actual_Worked_Hrs,
											CA.Extra_Work_Hours as OT_Hour,
											CA.Sanctioned_Hours as Actual_Workerd_Hrs, 
											@P_Days_Count AS P_Days_Count, dbo.F_Return_Hours(0) AS Weekoff_OT_Hour,
											dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec,0)) AS Holiday_OT_Hour,
											CA.Approve_Status AS Application_Status,'HO' AS DayFlag,dbo.F_Return_Hours(DATEDIFF(SECOND,shift_start_time,shift_end_time)) AS Shift_Hours,
										CONVERT(NVARCHAR(8),In_Time,108) AS In_Time_Actual,CONVERT(NVARCHAR(8),Out_Time,108) AS Out_Time_Actual
									FROM	#Data_Temp OA
									INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
									INNER JOIN dbo.T0120_CompOff_Approval CA ON OA.Emp_Id = CA.Emp_ID AND OA.For_date = CA.Extra_Work_Date
									INNER JOIN (SELECT	t1.emp_id,t1.branch_id
												FROM	T0095_Increment t1  
												INNER JOIN (SELECT emp_id, MAX(Increment_ID) AS Increment_ID	-- Ankit 12092014 for Same Date Increment
															FROM t0095_increment where cmp_ID = @cmp_ID
															GROUP BY emp_id)
														AS t2 ON t1.emp_id = t2.emp_id AND t1.Increment_ID = t2.Increment_ID)
											AS inc ON OA.Emp_ID = inc.emp_id
									INNER JOIN  (select GS.gen_ID,GS.Branch_ID,GS.H_CompOff_Min_hours from T0040_General_Setting GS inner join 
													(select Branch_ID,max(For_Date) as For_Date from T0040_General_Setting  
													 where cmp_ID = @Cmp_ID and For_Date <= @To_Date group by Branch_ID) qry on Qry.For_Date = GS.For_Date and Qry.Branch_ID = GS.Branch_ID) gs ON gs.branch_id = inc.branch_id
									WHERE	CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec),':', '.') AS numeric(18,3)) >= CASE
															  WHEN CAST(REPLACE(gs.H_CompOff_Min_hours,':', '.') AS numeric(18,3)) = 0
															  THEN CAST(REPLACE(Isnull(Case when E.CompOff_Min_hrs = '' then '00:00' else e.CompOff_Min_hrs end ,'00:00'),':', '.') AS numeric(18,3))
															  ELSE CAST(REPLACE(gs.H_CompOff_Min_hours,':', '.') AS numeric(18,3))
															  END AND (CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec),':', '.') AS numeric(18,3)) <> 0)
									AND EXISTS(SELECT 1 FROM #EMP_HOLIDAY HO  WHERE HO.IS_CANCEL = 0 AND HO.EMP_ID=OA.EMP_ID AND HO.FOR_DATE= OA.FOR_DATE)  -- ADDED BY GADRIWALA MUSLIM 0312016
									UNION
									SELECT	OA.*,
											dbo.F_Return_Hours(Duration_in_Sec)
											AS Working_Hour,
											dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) AS OT_Hour,
											dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) AS Actual_Worked_Hrs,
											@P_Days_Count AS P_Days_Count,dbo.F_Return_Hours(0) AS Weekoff_OT_Hour,
											dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec,0)) AS Holiday_OT_Hour,CA.Application_Status,
											'HO' AS DayFlag,dbo.F_Return_Hours(DATEDIFF(SECOND,shift_start_time,shift_end_time)) AS Shift_Hours,
										CONVERT(NVARCHAR(8),In_Time,108) AS In_Time_Actual,CONVERT(NVARCHAR(8),Out_Time,108) AS Out_Time_Actual
									FROM	#Data_Temp OA
									INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
									INNER JOIN dbo.T0100_CompOff_Application CA ON OA.Emp_Id = CA.Emp_ID AND OA.For_date = CA.Extra_Work_Date
									INNER JOIN (SELECT	t1.emp_id,t1.branch_id FROM	T0095_Increment t1  
												INNER JOIN (SELECT emp_id,MAX(Increment_ID) AS Increment_ID	-- Ankit 12092014 for Same Date Increment
															FROM t0095_increment GROUP BY emp_id)
														AS t2 ON t1.emp_id = t2.emp_id AND t1.Increment_ID = t2.Increment_ID)
											AS inc ON OA.Emp_ID = inc.emp_id inner join
									(select GS.gen_ID,GS.Branch_ID,GS.H_CompOff_Min_hours from T0040_General_Setting GS inner join 
													(select Branch_ID,max(For_Date) as For_Date from T0040_General_Setting  
													 where cmp_ID = @Cmp_ID and For_Date <= @To_Date group by Branch_ID) qry on Qry.For_Date = GS.For_Date and Qry.Branch_ID = GS.Branch_ID) gs ON gs.branch_id = inc.branch_id
									WHERE	CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec),':', '.') AS numeric(18,3)) >= CASE
															  WHEN CAST(REPLACE(gs.H_CompOff_Min_hours,':', '.') AS numeric(18,3)) = 0
															  THEN CAST(REPLACE(Isnull(Case when E.CompOff_Min_hrs = '' then '00:00' else e.CompOff_Min_hrs end ,'00:00'),':', '.') AS numeric(18,3))
															  ELSE CAST(REPLACE(gs.H_CompOff_Min_hours,':', '.') AS numeric(18,3))
															  END AND (CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec),':', '.') AS numeric(18,3)) <> 0) 
															  and OA.For_date NOT IN (SELECT	For_date
																	FROM	#Data_Temp OA
																	INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
																	INNER JOIN dbo.T0120_CompOff_Approval CA ON OA.Emp_Id = CA.Emp_ID AND OA.For_date = CA.Extra_Work_Date
																	WHERE	CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec),':', '.') AS numeric(18,3)) >= CAST(REPLACE(Isnull(Case when E.CompOff_Min_hrs = '' then '00:00' else e.CompOff_Min_hrs end ,'00:00'),':', '.') AS numeric(18,3)) AND 
																	(CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec),':', '.') AS numeric(18,3)) <> 0))
									AND EXISTS(SELECT 1 FROM #EMP_HOLIDAY HO  WHERE HO.IS_CANCEL = 0 AND HO.EMP_ID=OA.EMP_ID AND HO.FOR_DATE= OA.FOR_DATE)  -- ADDED BY GADRIWALA MUSLIM 0312016
									UNION
									SELECT	Qry1.*
									FROM	(SELECT	dt.*,dbo.F_Return_Hours(Duration_in_Sec) AS Working_Hour,
													dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) AS OT_Hour,
													dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) AS Actual_Worked_Hrs,
													@P_Days_Count AS P_Days_Count,
													dbo.F_Return_Hours(0) AS Weekoff_OT_Hour,
													dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec,0)) AS Holiday_OT_Hour,
													'-' AS application_status,'HO' AS DayFlag,dbo.F_Return_Hours(DATEDIFF(SECOND,shift_start_time,shift_end_time)) AS Shift_Hours,
										CONVERT(NVARCHAR(8),In_Time,108) AS In_Time_Actual,CONVERT(NVARCHAR(8),Out_Time,108) AS Out_Time_Actual
											 FROM	#Data_Temp DT
											 WHERE	For_date NOT IN (SELECT	For_date
																	FROM	#Data_Temp OA
																	INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
																	INNER JOIN dbo.T0120_CompOff_Approval CA ON OA.Emp_Id = CA.Emp_ID AND OA.For_date = CA.Extra_Work_Date
																	WHERE	CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec),':', '.') AS numeric(18,3)) >= CAST(REPLACE(Isnull(Case when E.CompOff_Min_hrs = '' then '00:00' else e.CompOff_Min_hrs end ,'00:00'),':', '.') AS numeric(18,3)) AND 
																	(CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec),':', '.') AS numeric(18,3)) <> 0)
													UNION
													SELECT	For_date
													FROM	#Data_Temp OA
													INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
													INNER JOIN dbo.T0100_CompOff_Application CA ON OA.Emp_Id = CA.Emp_ID AND OA.For_date = CA.Extra_Work_Date
													WHERE	CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS numeric(18,3)) >= 
															CAST(REPLACE(Isnull(case when E.CompOff_Min_hrs = '' then '00:00' else E.CompOff_Min_hrs end,'00:00'),':', '.') AS numeric(18,3)) OR 
															CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec),':', '.') AS numeric(18,3)) >= 
															CAST(REPLACE(Isnull(Case when E.CompOff_Min_hrs = '' then '00:00' else e.CompOff_Min_hrs end ,'00:00'),':', '.') AS numeric(18,3))) AND 
															(CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS numeric(18,3)) <> 0 OR 
															CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec),':', '.') AS numeric(18,3)) <> 0)) Qry1
									INNER JOIN dbo.T0080_EMP_MASTER em ON Qry1.Emp_Id = em.Emp_ID
									INNER JOIN (SELECT	t1.emp_id,t1.branch_id
												FROM	T0095_Increment t1
												INNER JOIN (SELECT emp_id,MAX(Increment_ID) AS Increment_ID	-- Ankit 12092014 for Same Date Increment
															FROM t0095_increment where cmp_ID = @cmp_ID
															GROUP BY emp_id)
														AS t2 ON t1.emp_id = t2.emp_id AND t1.Increment_ID = t2.Increment_ID)
											AS inc ON Qry1.Emp_ID = inc.emp_id
									INNER JOIN  (select GS.gen_ID,GS.Branch_ID,GS.H_CompOff_Min_hours from T0040_General_Setting GS inner join 
													(select Branch_ID,max(For_Date) as For_Date from T0040_General_Setting  
													 where cmp_ID = @Cmp_ID and For_Date <= @To_Date group by Branch_ID) qry on Qry.For_Date = GS.For_Date and qry.Branch_ID = Gs.Branch_ID) gs ON gs.branch_id = inc.branch_id
									WHERE	CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec),':', '.') AS numeric(18,3)) >= CASE
															  WHEN CAST(REPLACE(gs.H_CompOff_Min_hours,':', '.') AS numeric(18,3)) = 0
															  THEN CAST(REPLACE(Isnull(Case when Em.CompOff_Min_hrs = '' then '00:00' else em.CompOff_Min_hrs end ,'00:00'),':', '.') AS numeric(18,3))
															  ELSE CAST(REPLACE(gs.H_CompOff_Min_hours,':', '.') AS numeric(18,3))
															  END AND (CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec),':', '.') AS numeric(18,3)) <> 0)
										AND EXISTS(SELECT 1 FROM #EMP_HOLIDAY HO  WHERE HO.IS_CANCEL = 0 AND HO.EMP_ID=Qry1.EMP_ID AND HO.FOR_DATE= Qry1.FOR_DATE)  -- ADDED BY GADRIWALA MUSLIM 0312016				  
										Union -- Added By Gadriwala Muslim For Adjust CompOff Officially  Employee Go Out . 18/08/2015
										SELECT	OA.*,
											dbo.F_Return_Hours(Duration_in_Sec)
											AS Working_Hour,
											dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(DATEDIFF(s,OA.in_Time,GPQuery.in_Time),0)) AS OT_Hour,
											dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(DATEDIFF(s,OA.in_Time,GPQuery.in_Time),0)) AS Actual_Worked_Hrs,
											@P_Days_Count AS P_Days_Count, dbo.F_Return_Hours(0) AS Weekoff_OT_Hour,
											dbo.F_Return_Hours(ISNULL(DATEDIFF(s,OA.in_Time,GPQuery.in_Time),0)) AS Holiday_OT_Hour,
											'-' AS application_status,'HO-G' AS DayFlag,dbo.F_Return_Hours(DATEDIFF(SECOND,shift_start_time,shift_end_time)) AS Shift_Hours,
										CONVERT(NVARCHAR(8),OA.In_Time,108) AS In_Time_Actual,CONVERT(NVARCHAR(8),Out_Time,108) AS Out_Time_Actual
									FROM	#Data_Temp OA
									INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
									INNER JOIN (SELECT	t1.emp_id,t1.branch_id
												FROM	T0095_Increment t1  
												INNER JOIN (SELECT emp_id, MAX(Increment_ID) AS Increment_ID	
															FROM t0095_increment where cmp_ID = @cmp_ID
															GROUP BY emp_id)
														AS t2 ON t1.emp_id = t2.emp_id AND t1.Increment_ID = t2.Increment_ID)
											AS inc ON OA.Emp_ID = inc.emp_id
									INNER JOIN (select GS.For_Date,Gs.Branch_ID,H_CompOff_Min_Hours from T0040_GENERAL_SETTING GS inner join
													( 
														select MAX(For_date) as For_Date,Branch_ID from T0040_General_Setting gs 
														where Cmp_ID = @Cmp_ID  and For_Date <= @To_Date group by Branch_ID
													 )Qry on Qry.Branch_ID = GS.Branch_ID and Qry.For_Date = GS.For_Date
													) Gen_Qry ON Gen_Qry.branch_id = inc.branch_id
									Inner join ( select max(GP.In_Time) as In_Time,GP.emp_id,GP.For_Date,Is_Approved,Reason_id from T0150_EMP_Gate_Pass_INOUT_RECORD GP inner join #Data_Temp OA on OA.Emp_ID = GP.emp_id and OA.For_date = GP.For_date and GP.Is_Approved = 1 
									Inner join T0040_Reason_Master RM on RM.Res_Id = GP.Reason_id and Type = 'GatePass' and Gate_Pass_Type = 'Official' group by GP.Emp_ID,GP.For_Date,GP.Is_Approved,GP.Reason_id ) GPQuery on OA.emp_id = GPQuery.emp_ID and OA.For_date = GPQuery.For_date 
								
									WHERE	CAST(REPLACE(dbo.F_Return_Hours(DATEDIFF(s,OA.in_Time,GPQuery.in_Time)),':', '.') AS numeric(18,3)) >= CASE
															  WHEN CAST(REPLACE(Gen_Qry.H_CompOff_Min_hours,':', '.') AS numeric(18,3)) = 0
															  THEN CAST(REPLACE(Isnull(Case when E.CompOff_Min_hrs = '' then '00:00' else e.CompOff_Min_hrs end ,'00:00'),':', '.') AS numeric(18,3))
															  ELSE CAST(REPLACE(Gen_Qry.H_CompOff_Min_hours,':', '.') AS numeric(18,3))
															  END AND (CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec),':', '.') AS numeric(18,3)) <> 0)
											and OA.For_date NOT IN (SELECT	For_date
																	FROM	#Data_Temp OA
																	INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
																	INNER JOIN dbo.T0120_CompOff_Approval CA ON OA.Emp_Id = CA.Emp_ID AND OA.For_date = CA.Extra_Work_Date
																	WHERE	CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec),':', '.') AS numeric(18,3)) >= CAST(REPLACE(Isnull(Case when E.CompOff_Min_hrs = '' then '00:00' else e.CompOff_Min_hrs end ,'00:00'),':', '.') AS numeric(18,3)) AND 
																	(CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec),':', '.') AS numeric(18,3)) <> 0))
													AND EXISTS(SELECT 1 FROM #EMP_HOLIDAY HO  WHERE HO.IS_CANCEL = 0 AND HO.EMP_ID=OA.EMP_ID AND HO.FOR_DATE= OA.FOR_DATE)  -- ADDED BY GADRIWALA MUSLIM 0312016
									ORDER BY OA.For_Date
								END
						END
					ELSE
						IF @Return_Record_set = 11
							BEGIN 
								SELECT @Is_W_CompOff  = GS.Is_W_CompOff 
								FROM T0040_General_Setting GS 
									INNER JOIN 
										( select Branch_ID,max(For_Date) as For_Date from T0040_General_Setting where cmp_ID = @Cmp_ID and For_Date <= @To_Date group by Branch_ID
										) qry on Qry.For_Date = GS.For_Date and Qry.Branch_ID = GS.Branch_ID 
									INNER JOIN #Emp_Cons EC ON gs.Branch_ID = EC.Branch_ID
							
								IF (@Is_W_CompOff = 1)
									BEGIN  
								
										-- Added Nilesh Patel on 20072018 --For Cliantha -- if Employee Working 18 Hours next absent day adjust with previouse day OT and Deduct working hours from OT.
										--IF Exists(SELECT 1 FROM T0165_ATTENDANCE_APPROVAL WHERE CMP_ID = @CMP_ID AND FOR_DATE >=@FROM_DATE AND FOR_DATE <=@TO_DATE AND ATT_STATUS = 'A')
										--	Begin
										--		UPDATE DT
										--			SET DT.DURATION_IN_SEC = (Case When DT.DURATION_IN_SEC > Q.SHIFT_SEC Then DT.DURATION_IN_SEC - Q.SHIFT_SEC Else 0 END),
										--				DT.OT_SEC = CASE WHEN DT.OT_SEC > Q.SHIFT_SEC THEN 
										--								CASE WHEN DT.Emp_OT_Min_Limit > (DT.OT_SEC - Q.SHIFT_SEC) THEN	
										--									0
										--								ELSE  (DT.OT_SEC - Q.SHIFT_SEC) END
										--							ELSE 0 END,
										--				DT.Weekoff_OT_Sec = CASE WHEN G.Tras_Week_OT = 1 AND DT.Weekoff_OT_Sec > Q.SHIFT_SEC THEN DT.Weekoff_OT_Sec - Q.SHIFT_SEC ELSE DT.Weekoff_OT_Sec END,
										--				DT.Holiday_OT_Sec = CASE WHEN G.Tras_Week_OT = 1 AND DT.Holiday_OT_Sec > Q.SHIFT_SEC THEN DT.Holiday_OT_Sec - Q.SHIFT_SEC ELSE DT.Holiday_OT_Sec END
										--		FROM #DATA_TEMP DT INNER JOIN 
										--		(
										--				SELECT EMP_ID,DATEADD(D,-1,FOR_DATE) AS FORDATE,P_DAYS,ATT_STATUS,SHIFT_SEC
										--				FROM T0165_ATTENDANCE_APPROVAL
										--				WHERE CMP_ID = @CMP_ID AND FOR_DATE >=@FROM_DATE AND FOR_DATE <=@TO_DATE AND ATT_STATUS = 'A' AND P_DAYS <> 0
										--		)Q ON DT.EMP_ID =Q.EMP_ID  AND DT.FOR_DATE = Q.FORDATE
										--		INNER JOIN #EMP_GEN_SETTINGS G ON DT.Emp_Id=G.EMP_ID
										--	End

										SELECT	OA.*,
												dbo.F_Return_Hours(Duration_in_Sec)
												AS Working_Hour,
												--dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) AS OT_Hour,
												--dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) AS Actual_Worked_Hrs,
												CA.Extra_Work_Hours as OT_Hour,
												CA.Sanctioned_Hours as Actual_Workerd_Hrs, 
												@P_Days_Count AS P_Days_Count,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0)) AS Weekoff_OT_Hour,
												dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec,0)) AS Holiday_OT_Hour,
												CA.Approve_Status AS Application_Status,'WO' AS DayFlag,dbo.F_Return_Hours(DATEDIFF(SECOND,shift_start_time,shift_end_time)) AS Shift_Hours,
										CONVERT(NVARCHAR(8),In_Time,108) AS In_Time_Actual,CONVERT(NVARCHAR(8),Out_Time,108) AS Out_Time_Actual
										FROM	#Data_Temp OA
										INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
										INNER JOIN dbo.T0120_CompOff_Approval CA ON OA.Emp_Id = CA.Emp_ID AND OA.For_date = CA.Extra_Work_Date
										INNER JOIN (SELECT	t1.emp_id,t1.branch_id
													FROM	T0095_Increment t1  
													INNER JOIN (SELECT emp_id,MAX(Increment_ID)AS Increment_ID	-- Ankit 12092014 for Same Date Increment
															  FROM t0095_increment where cmp_ID = @cmp_ID GROUP BY emp_id)
															AS t2 ON t1.emp_id = t2.emp_id AND t1.Increment_ID = t2.Increment_ID)
												AS inc ON OA.Emp_ID = inc.emp_id
										INNER JOIN  (select GS.gen_ID,GS.Branch_ID,GS.W_CompOff_Min_hours from T0040_General_Setting GS inner join 
													(select Branch_ID,max(For_Date) as For_Date from T0040_General_Setting  
													 where cmp_ID = @Cmp_ID and For_Date <= @To_Date group by Branch_ID) qry on Qry.For_Date = GS.For_Date and Qry.Branch_ID = GS.Branch_ID) gs  ON gs.branch_id = inc.branch_id
										WHERE	CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS numeric(18,3)) >= CASE
															  WHEN CAST(REPLACE(gs.W_CompOff_Min_hours,':', '.') AS numeric(18,3)) = 0
															  THEN CAST(REPLACE(Isnull(Case when E.CompOff_Min_hrs = '' then '00:00' else e.CompOff_Min_hrs end ,'00:00'),':', '.') AS numeric(18,3))
															  ELSE CAST(REPLACE(gs.W_CompOff_Min_hours,':', '.') AS numeric(18,3))
															  END 
												AND (CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS numeric(18,3)) <> 0)
										  AND EXISTS(SELECT 1 FROM #EMP_WEEKOFF WK  WHERE WK.IS_CANCEL = 0 AND WK.EMP_ID=OA.EMP_ID AND WK.FOR_DATE= OA.FOR_DATE)  -- Added by Gadriwala Muslim 0312016
										UNION
										SELECT	OA.*,
												dbo.F_Return_Hours(Duration_in_Sec)
												AS Working_Hour,
												dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) AS OT_Hour,
												dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) AS Actual_Worked_Hrs,
												@P_Days_Count AS P_Days_Count,
												dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0)) AS Weekoff_OT_Hour,
												dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec,0)) AS Holiday_OT_Hour,
												CA.Application_Status,'WO' AS DayFlag,dbo.F_Return_Hours(DATEDIFF(SECOND,shift_start_time,shift_end_time)) AS Shift_Hours,
										CONVERT(NVARCHAR(8),In_Time,108) AS In_Time_Actual,CONVERT(NVARCHAR(8),Out_Time,108) AS Out_Time_Actual
										FROM	#Data_Temp OA
										INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
										INNER JOIN dbo.T0100_CompOff_Application CA ON OA.Emp_Id = CA.Emp_ID AND OA.For_date = CA.Extra_Work_Date
										INNER JOIN (SELECT	t1.emp_id,t1.branch_id FROM	T0095_Increment t1  
													INNER JOIN (SELECT emp_id,MAX(Increment_ID) AS Increment_ID	-- Ankit 12092014 for Same Date Increment
															  FROM t0095_increment where cmp_ID = @cmp_ID GROUP BY emp_id)
															AS t2 ON t1.emp_id = t2.emp_id AND t1.Increment_ID = t2.Increment_ID)
												AS inc ON OA.Emp_ID = inc.emp_id
										INNER JOIN  (select GS.gen_ID,GS.Branch_ID,GS.W_CompOff_Min_hours from T0040_General_Setting GS inner join 
													(select Branch_ID,max(For_Date) as For_Date from T0040_General_Setting  
													 where cmp_ID = @Cmp_ID and For_Date <= @To_Date group by Branch_ID) qry on Qry.For_Date = GS.For_Date and Qry.Branch_ID = GS.Branch_ID) gs  ON gs.branch_id = inc.branch_id
										WHERE	CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS numeric(18,3)) >= CASE
															  WHEN CAST(REPLACE(gs.W_CompOff_Min_hours,':', '.') AS numeric(18,3)) = 0
															  THEN CAST(REPLACE(Isnull(Case when E.CompOff_Min_hrs = '' then '00:00' else e.CompOff_Min_hrs end ,'00:00'),':', '.') AS numeric(18,3))
															  ELSE CAST(REPLACE(gs.W_CompOff_Min_hours,':', '.') AS numeric(18,3))
															  END 
      								AND (CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS numeric(18,3)) <> 0)
      								AND OA.For_date NOT IN (
														SELECT For_date
														FROM  #Data_Temp OA
														INNER JOIN dbo.T0080_emp_master E  ON OA.Emp_ID = E.Emp_ID
														INNER JOIN dbo.T0120_CompOff_Approval CA ON OA.Emp_Id = CA.Emp_ID AND OA.For_date = CA.Extra_Work_Date
														WHERE CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS numeric(18,3)) >= 
																CAST(REPLACE(Isnull(Case when E.CompOff_Min_hrs = '' then '00:00' else e.CompOff_Min_hrs end ,'00:00'),':', '.') AS numeric(18,3)) 
															  AND (CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS numeric(18,3)) <> 0) )
													 AND EXISTS(SELECT 1 FROM #EMP_WEEKOFF WK  WHERE WK.IS_CANCEL = 0 AND WK.EMP_ID=OA.EMP_ID AND WK.FOR_DATE= OA.FOR_DATE)  -- Added by Gadriwala Muslim 0312016
										UNION
										SELECT	Qry1.*
										FROM	(SELECT	dt.*,
														dbo.F_Return_Hours(Duration_in_Sec)
														AS Working_Hour,
														dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) AS OT_Hour,
														dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) AS Actual_Worked_Hrs,
														@P_Days_Count AS P_Days_Count,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0)) AS Weekoff_OT_Hour,
														dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec,0)) AS Holiday_OT_Hour,'-' AS application_status,
														'WO' AS DayFlag,dbo.F_Return_Hours(DATEDIFF(SECOND,shift_start_time,shift_end_time)) AS Shift_Hours,
														CONVERT(NVARCHAR(8),In_Time,108) AS In_Time_Actual,CONVERT(NVARCHAR(8),Out_Time,108) AS Out_Time_Actual
												 FROM	#Data_Temp DT
												 WHERE	For_date NOT IN (
														SELECT For_date
														FROM  #Data_Temp OA
														INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
														INNER JOIN dbo.T0120_CompOff_Approval CA ON OA.Emp_Id = CA.Emp_ID AND OA.For_date = CA.Extra_Work_Date
														WHERE CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS numeric(18,3)) >= 
																CAST(REPLACE(Isnull(Case when E.CompOff_Min_hrs = '' then '00:00' else e.CompOff_Min_hrs end ,'00:00'),':', '.') AS numeric(18,3)) 
															  AND (CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS numeric(18,3)) <> 0) 
														UNION
														SELECT For_date
														FROM  #Data_Temp OA
														INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
														INNER JOIN dbo.T0100_CompOff_Application CA ON OA.Emp_Id = CA.Emp_ID AND OA.For_date = CA.Extra_Work_Date
														WHERE CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS numeric(18,3)) >= 
																CAST(REPLACE(Isnull(Case when E.CompOff_Min_hrs = '' then '00:00' else e.CompOff_Min_hrs end,'00:00'),':', '.') AS numeric(18,3))) 
																AND (CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS numeric(18,3)) <> 0)) Qry1
										INNER JOIN dbo.T0080_EMP_MASTER em ON Qry1.Emp_Id = em.Emp_ID
										INNER JOIN (SELECT	t1.emp_id,t1.branch_id FROM	T0095_Increment t1  
													INNER JOIN (SELECT emp_id,MAX(Increment_ID) AS Increment_ID	-- Ankit 12092014 for Same Date Increment
															  FROM t0095_increment where cmp_ID = @cmp_ID GROUP BY emp_id)
															AS t2 ON t1.emp_id = t2.emp_id AND t1.Increment_ID = t2.Increment_ID)
												AS inc ON Qry1.Emp_ID = inc.emp_id
													INNER JOIN  (select GS.gen_ID,GS.Branch_ID,GS.W_CompOff_Min_hours from T0040_General_Setting GS inner join 
													(select Branch_ID,max(For_Date) as For_Date from T0040_General_Setting  
													 where cmp_ID = @Cmp_ID and For_Date <= @To_Date group by Branch_ID) qry on Qry.For_Date = GS.For_Date and Qry.Branch_ID = GS.Branch_ID) gs  ON gs.branch_id = inc.branch_id
										WHERE	CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS numeric(18,3)) >= CASE
															  WHEN CAST(REPLACE(gs.W_CompOff_Min_hours,':', '.') AS numeric(18,3)) = 0
															  THEN CAST(REPLACE(Isnull(Case when Em.CompOff_Min_hrs = '' then '00:00' else em.CompOff_Min_hrs end,'00:00'),':', '.') AS numeric(18,3))
															  ELSE CAST(REPLACE(gs.W_CompOff_Min_hours,':', '.') AS numeric(18,3))
															  END
												AND (CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS numeric(18,3)) <> 0)
												AND EXISTS(SELECT 1 FROM #EMP_WEEKOFF WK  WHERE WK.IS_CANCEL = 0 AND WK.EMP_ID=QRY1.EMP_ID AND WK.FOR_DATE= QRY1.FOR_DATE)  -- Added by Gadriwala Muslim 0312016
												

											union	-- Added By Gadriwala Muslim For Adjust CompOff Officially  Employee Go Out . 04/09/2015
											
											SELECT	OA.*,
												dbo.F_Return_Hours(DATEDIFF(s,OA.in_Time,GPQuery.in_Time))
												AS Working_Hour,
												dbo.F_Return_Hours(DATEDIFF(s,OA.in_Time,GPQuery.in_Time) + ISNULL(Holiday_OT_Sec,0)) AS OT_Hour,
												dbo.F_Return_Hours(DATEDIFF(s,OA.in_Time,GPQuery.in_Time) + ISNULL(Holiday_OT_Sec,0)) AS Actual_Worked_Hrs,
												@P_Days_Count AS P_Days_Count,dbo.F_Return_Hours(ISNULL(DATEDIFF(s,OA.in_Time,GPQuery.in_Time),0)) AS Weekoff_OT_Hour,
												dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec,0)) AS Holiday_OT_Hour,
												'-' AS application_status,'WO-G' AS DayFlag,dbo.F_Return_Hours(DATEDIFF(SECOND,shift_start_time,OA.shift_end_time)) AS Shift_Hours,
										CONVERT(NVARCHAR(8),OA.In_Time,108) AS In_Time_Actual,CONVERT(NVARCHAR(8),GPQuery.IN_Time,108) AS Out_Time_Actual
										FROM	#Data_Temp OA
										INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
										INNER JOIN (SELECT	t1.emp_id,t1.branch_id
													FROM	T0095_Increment t1  
													INNER JOIN (SELECT emp_id,MAX(Increment_ID)AS Increment_ID
															  FROM t0095_increment where cmp_ID = @cmp_ID GROUP BY emp_id)
															AS t2 ON t1.emp_id = t2.emp_id AND t1.Increment_ID = t2.Increment_ID)
												AS inc ON OA.Emp_ID = inc.emp_id
										INNER JOIN (select GS.For_Date,Gs.Branch_ID,W_CompOff_Min_hours from T0040_GENERAL_SETTING GS inner join
													( 
														select MAX(For_date) as For_Date,Branch_ID from T0040_General_Setting gs 
														where Cmp_ID = @Cmp_ID  and For_Date <= @To_Date group by Branch_ID
													 )Qry on Qry.Branch_ID = GS.Branch_ID and Qry.For_Date = GS.For_Date
													) Gen_Qry ON Gen_Qry.branch_id = inc.branch_id
										Inner join ( select max(GP.In_Time) as In_Time,GP.emp_id,GP.For_Date,Is_Approved,Reason_id from T0150_EMP_Gate_Pass_INOUT_RECORD GP inner join #Data_Temp OA on OA.Emp_ID = GP.emp_id and OA.For_date = GP.For_date and GP.Is_Approved = 1
										Inner join T0040_Reason_Master RM on RM.Res_Id = GP.Reason_id and Type = 'GatePass' and Gate_Pass_Type = 'Official' group by GP.Emp_ID,GP.For_Date,GP.Is_Approved,GP.Reason_id ) GPQuery on OA.emp_id = GPQuery.emp_ID and OA.For_date = GPQuery.For_date 
										where
										CAST(REPLACE(dbo.F_Return_Hours(DATEDIFF(s,OA.in_Time,GPQuery.in_Time)),':', '.') AS numeric(18,3)) >= CASE
															  WHEN CAST(REPLACE(Gen_Qry.W_CompOff_Min_hours,':', '.') AS numeric(18,3)) = 0
															  THEN CAST(REPLACE(Isnull(Case when E.CompOff_Min_hrs = '' then '00:00' else e.CompOff_Min_hrs end,'00:00'),':', '.') AS numeric(18,3))
															  ELSE CAST(REPLACE(Gen_Qry.W_CompOff_Min_hours,':', '.') AS numeric(18,3))
															  END
												AND (CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS numeric(18,3)) <> 0) and 
												OA.For_date NOT IN (
														SELECT For_date
														FROM  #Data_Temp OA
														INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
														INNER JOIN dbo.T0120_CompOff_Approval CA ON OA.Emp_Id = CA.Emp_ID AND OA.For_date = CA.Extra_Work_Date
														WHERE CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS numeric(18,3)) >= 
																CAST(REPLACE(Isnull(Case when E.CompOff_Min_hrs = '' then '00:00' else e.CompOff_Min_hrs end ,'00:00'),':', '.') AS numeric(18,3)) 
															  AND (CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS numeric(18,3)) <> 0) )
										AND EXISTS(SELECT 1 FROM #EMP_WEEKOFF WK  WHERE WK.IS_CANCEL = 0 AND WK.EMP_ID=OA.EMP_ID AND WK.FOR_DATE= OA.FOR_DATE)  -- Added by Gadriwala Muslim 0312016
										ORDER BY OA.For_Date
				
				
									END
							END
						ELSE
							IF @return_record_set = 12 -- Changed by Gadriwala Muslim 25112015 for Auto OD
								BEGIN
									EXEC getAllDaysBetweenTwoDate @from_Date,
										@to_Date
			
								
			
									INSERT	INTO #data_temp_test
											SELECT	t1.Emp_ID,t2.test1 AS For_Date,0 AS Duration_in_Sec,
													1 AS Shift_ID,0 AS shift_type,1 AS Emp_OT,0 AS Emp_OT_min_Limit,
													0 AS Emp_OT_max_Limit,0 AS P_Days, 
													( 
													
													Select case when Leave_Assign_As <> 'Full Day' and Half_Leave_Date = t2.test1
													 then dbo.F_Return_Sec(Shift_Dur)/2 
																	when Leave_Assign_As = 'Part Day' and IsNull(Half_Leave_Date,'1900-01-01') = '1900-01-01' then	-- Added by Rajput on 13122018 As per discussed with Nimesh Bhai ( Inductotherm Client )															
																case when Leave_Period % 1 > 0 Then	
																	(8/Leave_Period) * 3600
																Else
																	 Leave_Period * 3600
																End		
													 else dbo.F_Return_Sec(Shift_Dur) 
													  end as Shift_Dur  
														from	T0040_SHIFT_MASTER SM 
														WHERE	Shift_ID=dbo.fn_get_Shift_From_Monthly_Rotation(@Cmp_ID,@Emp_ID,t2.test1)
													) AS OT_Sec, 
													test1 AS In_Time,
													test1 AS Shift_Start_Time,0 AS OT_Start_Time,0 AS Shift_Change,
													0 AS Flag,0 AS Weekoff_OT_Sec,0 AS Holiday_OT_Sec,
													0 AS Chk_By_Superior,0 AS IO_Trans_ID,test1 AS OUT_Time,
													test1 AS Shift_End_Time,0 AS OT_End_Time
											FROM	(SELECT	la.Emp_ID,lad.From_Date,lad.To_Date,lad.Leave_Assign_As,lad.Half_Leave_Date, lad.Leave_Period
													 FROM	(SELECT la.* FROM T0120_LEAVE_APPROVAL la  
															 LEFT OUTER JOIN T0150_LEAVE_CANCELLATION lc ON la.Leave_Approval_ID = lc.Leave_Approval_id AND la.Cmp_ID = lc.Cmp_Id
															 WHERE ISNULL(Is_Approve,0) = 0) AS la
													 Inner JOIN T0130_LEAVE_APPROVAL_DETAIL AS lad ON la.Leave_Approval_ID = lad.Leave_Approval_ID AND la.Cmp_ID = lad.Cmp_ID
													 INNER JOIN T0040_LEAVE_MASTER
															AS lt ON la.Cmp_ID = lt.Cmp_ID AND lad.Leave_ID = lt.Leave_ID
													 WHERE	(la.Emp_ID = @Emp_ID) AND (lt.Leave_Type = 'Company Purpose') AND (la.Approval_Status = 'A'))
													AS t1
											CROSS JOIN test1 AS t2 
											WHERE	t2.test1 >= from_Date AND t2.test1 <= to_date
											ORDER BY For_Date
											
									SELECT	dtt.*, 0 as Working_Hrs_St_Time , 
												 0 as Working_Hrs_End_Time, 
												 0 as GatePass_Deduct_Days,  '00:00' AS Working_Hour,
											dbo.F_Return_Hours(dtt.OT_Sec) AS OT_Hour,
											dbo.F_Return_Hours(dtt.OT_Sec) AS Actual_Worked_Hrs,
											0.00 AS P_Days_Count,
											'00:00' AS Weekoff_OT_Hours,
											'00:00' AS Holiday_OT_Hours,
											ISNULL(ca.Application_Status, ISNULL(capr.Approve_Status,'')) AS Application_Status, -- Changed  by Gadriwala Muslim 02042015
											'OD' AS DayFlag,'00:00' AS Shift_Hours,CAST('00:00:00' AS VARCHAR(8)) AS In_Time_Actual,
											CAST('00:00:00' AS VARCHAR(8)) AS Out_Time_Actual 
									FROM	#Data_Temp_test AS dtt
									LEFT OUTER JOIN t0100_Compoff_Application AS ca ON dtt.emp_id = ca.emp_id AND dtt.For_Date = ca.Extra_Work_Date
									LEFT OUTER JOIN T0120_CompOff_Approval as CApr on dtt.Emp_Id = CApr.Emp_ID and dtt.For_date = CApr.Extra_Work_Date -- Changed  by Gadriwala Muslim 02042015
	   
								END
								ELSE IF @return_record_set = 13  -- HO & WO & WD
									BEGIN
										-- Added Nilesh Patel on 20072018 --For Cliantha -- if Employee Working 18 Hours next absent day adjust with previouse day OT and Deduct working hours from OT.
										--IF Exists(SELECT 1 FROM T0165_ATTENDANCE_APPROVAL WHERE CMP_ID = @CMP_ID AND FOR_DATE >=@FROM_DATE AND FOR_DATE <=@TO_DATE AND ATT_STATUS = 'A')
										--	Begin
										--		UPDATE DT
										--			SET DT.DURATION_IN_SEC = (Case When DT.DURATION_IN_SEC > Q.SHIFT_SEC Then DT.DURATION_IN_SEC - Q.SHIFT_SEC Else 0 END),
										--				DT.OT_SEC = CASE WHEN DT.OT_SEC > Q.SHIFT_SEC THEN 
										--								CASE WHEN DT.Emp_OT_Min_Limit > (DT.OT_SEC - Q.SHIFT_SEC) THEN	
										--									0
										--								ELSE  (DT.OT_SEC - Q.SHIFT_SEC) END
										--							ELSE 0 END,
										--							DT.Weekoff_OT_Sec = CASE WHEN G.Tras_Week_OT = 1 AND DT.Weekoff_OT_Sec > Q.SHIFT_SEC THEN DT.Weekoff_OT_Sec - Q.SHIFT_SEC ELSE DT.Weekoff_OT_Sec END,
										--							DT.Holiday_OT_Sec = CASE WHEN G.Tras_Week_OT = 1 AND DT.Holiday_OT_Sec > Q.SHIFT_SEC THEN DT.Holiday_OT_Sec - Q.SHIFT_SEC ELSE DT.Holiday_OT_Sec END
										--		FROM #DATA_TEMP DT INNER JOIN 
										--		(
										--				SELECT EMP_ID,DATEADD(D,-1,FOR_DATE) AS FORDATE,P_DAYS,ATT_STATUS,SHIFT_SEC
										--				FROM T0165_ATTENDANCE_APPROVAL
										--				WHERE CMP_ID = @CMP_ID AND FOR_DATE >=@FROM_DATE AND FOR_DATE <=@TO_DATE AND ATT_STATUS = 'A' AND P_DAYS <> 0
										--		)Q ON DT.EMP_ID =Q.EMP_ID  AND DT.FOR_DATE = Q.FORDATE
										--		INNER JOIN #EMP_GEN_SETTINGS G ON DT.Emp_Id=G.EMP_ID
										--	End
									
--hnb									


										SELECT	OA.*,
												dbo.F_Return_Hours(Duration_in_Sec)
												AS Working_Hour,
												dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) AS OT_Hour,
												dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) AS Actual_Worked_Hrs,
												@P_Days_Count AS P_Days_Count,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0)) AS Weekoff_OT_Hour,
												dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec,0)) AS Holiday_OT_Hour,
												CA.Approve_Status AS Application_Status,Cast('WO' As Varchar(20)) AS DayFlag,dbo.F_Return_Hours(DATEDIFF(SECOND,shift_start_time,shift_end_time)) AS Shift_Hours,
												CONVERT(NVARCHAR(8),In_Time,108) AS In_Time_Actual,CONVERT(NVARCHAR(8),Out_Time,108) AS Out_Time_Actual
										INTO	#HO_WO_WD
										FROM	#Data_Temp OA
												INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
												INNER JOIN dbo.T0120_CompOff_Approval CA ON OA.Emp_Id = CA.Emp_ID AND OA.For_date = CA.Extra_Work_Date										
												INNER JOIN #Data_Gen as gs ON gs.Emp_id = OA.Emp_Id 
										WHERE	CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS numeric(18,3)) >= CASE
															  WHEN CAST(REPLACE(gs.W_CompOff_Min_hours,':', '.') AS numeric(18,3)) = 0
															  THEN CAST(REPLACE(Isnull(Case when E.CompOff_Min_hrs = '' then '00:00' else e.CompOff_Min_hrs end ,'00:00'),':', '.') AS numeric(18,3))
															  ELSE CAST(REPLACE(gs.W_CompOff_Min_hours,':', '.') AS numeric(18,3))
															  END 
												AND (CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS numeric(18,3)) <> 0)
												AND EXISTS(SELECT 1 FROM #EMP_WEEKOFF WK  WHERE WK.IS_CANCEL = 0 AND WK.EMP_ID=OA.EMP_ID AND WK.FOR_DATE= OA.FOR_DATE)  -- Added by Gadriwala Muslim 0312016

									--UNION										
										INSERT	INTO #HO_WO_WD
										SELECT	OA.*,
												dbo.F_Return_Hours(Duration_in_Sec)
												AS Working_Hour,
												dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) AS OT_Hour,
												dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) AS Actual_Worked_Hrs,
												@P_Days_Count AS P_Days_Count,
												dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0)) AS Weekoff_OT_Hour,
												dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec,0)) AS Holiday_OT_Hour,
												CA.Application_Status,'WO' AS DayFlag,dbo.F_Return_Hours(DATEDIFF(SECOND,shift_start_time,shift_end_time)) AS Shift_Hours,
												CONVERT(NVARCHAR(8),In_Time,108) AS In_Time_Actual,CONVERT(NVARCHAR(8),Out_Time,108) AS Out_Time_Actual
										FROM	#Data_Temp OA
												INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
												INNER JOIN dbo.T0100_CompOff_Application CA ON OA.Emp_Id = CA.Emp_ID AND OA.For_date = CA.Extra_Work_Date										
												INNER JOIN #Data_Gen as gs ON gs.Emp_id = OA.Emp_Id 
										WHERE	CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS numeric(18,3)) >= CASE
															  WHEN CAST(REPLACE(gs.W_CompOff_Min_hours,':', '.') AS numeric(18,3)) = 0
															  THEN CAST(REPLACE(Isnull(Case when E.CompOff_Min_hrs = '' then '00:00' else e.CompOff_Min_hrs end ,'00:00'),':', '.') AS numeric(18,3))
															  ELSE CAST(REPLACE(gs.W_CompOff_Min_hours,':', '.') AS numeric(18,3))
															  END 
      								AND (CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS numeric(18,3)) <> 0)
      								AND EXISTS(SELECT 1 FROM #EMP_WEEKOFF WK  WHERE WK.IS_CANCEL = 0 AND WK.EMP_ID=OA.EMP_ID AND WK.FOR_DATE= OA.FOR_DATE)  -- Added by Gadriwala Muslim 0312016
												AND NOT EXISTS(SELECT 1 FROM #HO_WO_WD T WHERE T.Emp_Id=E.Emp_ID AND T.For_date=OA.For_date)
										--UNION	
 

										INSERT	INTO #HO_WO_WD
										SELECT	Qry1.*
										FROM	(SELECT	dt.*,
														dbo.F_Return_Hours(Duration_in_Sec)
														AS Working_Hour,
														dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) AS OT_Hour,
														dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) AS Actual_Worked_Hrs,
														@P_Days_Count AS P_Days_Count,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0)) AS Weekoff_OT_Hour,
														dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec,0)) AS Holiday_OT_Hour,'-' AS application_status,
														'WO' AS DayFlag,dbo.F_Return_Hours(DATEDIFF(SECOND,shift_start_time,shift_end_time)) AS Shift_Hours,
														CONVERT(NVARCHAR(8),In_Time,108) AS In_Time_Actual,CONVERT(NVARCHAR(8),Out_Time,108) AS Out_Time_Actual
												 FROM	#Data_Temp DT
												 WHERE	For_date NOT IN 
														(
															SELECT For_date
															FROM  #Data_Temp OA
															INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
															INNER JOIN dbo.T0120_CompOff_Approval CA ON OA.Emp_Id = CA.Emp_ID AND OA.For_date = CA.Extra_Work_Date
															WHERE CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS numeric(18,3)) >= 
																	CAST(REPLACE(Isnull(Case when E.CompOff_Min_hrs = '' then '00:00' else e.CompOff_Min_hrs end ,'00:00'),':', '.') AS numeric(18,3)) 
																  AND (CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS numeric(18,3)) <> 0) 
														UNION
															SELECT For_date
															FROM  #Data_Temp OA
															INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
															INNER JOIN dbo.T0100_CompOff_Application CA ON OA.Emp_Id = CA.Emp_ID AND OA.For_date = CA.Extra_Work_Date
															WHERE CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS numeric(18,3)) >= 
																	CAST(REPLACE(Isnull(Case when E.CompOff_Min_hrs = '' then '00:00' else e.CompOff_Min_hrs end,'00:00'),':', '.') AS numeric(18,3))) 
																	AND (CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS numeric(18,3)) <> 0)
												) Qry1
												INNER JOIN dbo.T0080_EMP_MASTER em  ON Qry1.Emp_Id = em.Emp_ID										
												INNER JOIN #Data_Gen as gs ON gs.Emp_id = Qry1.Emp_Id 
										WHERE	CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS numeric(18,3)) >= CASE
															  WHEN CAST(REPLACE(gs.W_CompOff_Min_hours,':', '.') AS numeric(18,3)) = 0
															  THEN CAST(REPLACE(Isnull(Case when Em.CompOff_Min_hrs = '' then '00:00' else em.CompOff_Min_hrs end,'00:00'),':', '.') AS numeric(18,3))
															  ELSE CAST(REPLACE(gs.W_CompOff_Min_hours,':', '.') AS numeric(18,3))
															  END
												AND (CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS numeric(18,3)) <> 0)
												AND EXISTS(SELECT 1 FROM #EMP_WEEKOFF WK  WHERE WK.IS_CANCEL = 0 AND WK.EMP_ID=QRY1.EMP_ID AND WK.FOR_DATE= QRY1.FOR_DATE)  -- ADDED BY GADRIWALA MUSLIM 0312016
												AND NOT EXISTS(SELECT 1 FROM #HO_WO_WD T WHERE T.Emp_Id=Qry1.Emp_ID AND T.For_date=Qry1.For_date)
										--union	-- Added By Gadriwala Muslim For Adjust CompOff Officially  Employee Go Out . 04/09/2015
										
										INSERT	INTO #HO_WO_WD
										SELECT	OA.*,
												dbo.F_Return_Hours(DATEDIFF(s,OA.in_Time,GPQuery.in_Time))
												AS Working_Hour,
												dbo.F_Return_Hours(DATEDIFF(s,OA.in_Time,GPQuery.in_Time) + ISNULL(Holiday_OT_Sec,0)) AS OT_Hour,
												dbo.F_Return_Hours(DATEDIFF(s,OA.in_Time,GPQuery.in_Time) + ISNULL(Holiday_OT_Sec,0)) AS Actual_Worked_Hrs,
												@P_Days_Count AS P_Days_Count,dbo.F_Return_Hours(ISNULL(DATEDIFF(s,OA.in_Time,GPQuery.in_Time),0)) AS Weekoff_OT_Hour,
												dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec,0)) AS Holiday_OT_Hour,
												'-' AS application_status,'WO-G' AS DayFlag,dbo.F_Return_Hours(DATEDIFF(SECOND,shift_start_time,OA.shift_end_time)) AS Shift_Hours,
												CONVERT(NVARCHAR(8),OA.In_Time,108) AS In_Time_Actual,CONVERT(NVARCHAR(8),GPQuery.IN_Time,108) AS Out_Time_Actual
										FROM	#Data_Temp OA
												INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID										
												INNER JOIN #Data_Gen as gs ON gs.Emp_id = OA.Emp_Id 
												INNER JOIN ( select max(GP.In_Time) as In_Time,GP.emp_id,GP.For_Date,Is_Approved,Reason_id from T0150_EMP_Gate_Pass_INOUT_RECORD GP inner join #Data_Temp OA on OA.Emp_ID = GP.emp_id and OA.For_date = GP.For_date and GP.Is_Approved = 1
												INNER JOIN T0040_Reason_Master RM on RM.Res_Id = GP.Reason_id and Type = 'GatePass' and Gate_Pass_Type = 'Official' group by GP.Emp_ID,GP.For_Date,GP.Is_Approved,GP.Reason_id ) GPQuery on OA.emp_id = GPQuery.emp_ID and OA.For_date = GPQuery.For_date 
										WHERE	CAST(REPLACE(dbo.F_Return_Hours(DATEDIFF(s,OA.in_Time,GPQuery.in_Time)),':', '.') AS numeric(18,3)) >= CASE
															  WHEN CAST(REPLACE(gs.W_CompOff_Min_hours,':', '.') AS numeric(18,3)) = 0
															  THEN CAST(REPLACE(Isnull(Case when E.CompOff_Min_hrs = '' then '00:00' else e.CompOff_Min_hrs end,'00:00'),':', '.') AS numeric(18,3))
															  ELSE CAST(REPLACE(gs.W_CompOff_Min_hours,':', '.') AS numeric(18,3))
															  END
												AND (CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS numeric(18,3)) <> 0) and 
												OA.For_date NOT IN (SELECT	For_date 
																	FROM	#Data_Temp OA
																			INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
																			INNER JOIN dbo.T0120_CompOff_Approval CA ON OA.Emp_Id = CA.Emp_ID AND OA.For_date = CA.Extra_Work_Date
																	WHERE	CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS numeric(18,3)) >= 
																			CAST(REPLACE(Isnull(Case when E.CompOff_Min_hrs = '' then '00:00' else e.CompOff_Min_hrs end ,'00:00'),':', '.') AS numeric(18,3)) 
																			AND (CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS numeric(18,3)) <> 0) 
																	)
												AND EXISTS(SELECT	1 
															FROM		#EMP_WEEKOFF WK  
															WHERE	WK.IS_CANCEL = 0 AND WK.EMP_ID=OA.EMP_ID AND WK.FOR_DATE= OA.FOR_DATE)  -- Added by Gadriwala Muslim 0312016
												AND NOT EXISTS(SELECT 1 FROM #HO_WO_WD T WHERE T.Emp_Id=OA.Emp_ID AND T.For_date=OA.For_date)
										--Added By Jaina 2-12-2015 Start
										--UNION
										INSERT	INTO #HO_WO_WD
										SELECT	OA.*,
												dbo.F_Return_Hours(Duration_in_Sec) AS Working_Hour,
												dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) AS OT_Hour,
												dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) AS Actual_Worked_Hrs,
												@P_Days_Count AS P_Days_Count,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0)) AS Weekoff_OT_Hour,
												dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec,0)) AS Holiday_OT_Hour,
												'-' AS Application_Status,'WO' AS DayFlag,dbo.F_Return_Hours(DATEDIFF(SECOND,shift_start_time,shift_end_time)) AS Shift_Hours,
												CONVERT(NVARCHAR(8),In_Time,108) AS In_Time_Actual,CONVERT(NVARCHAR(8),Out_Time,108) AS Out_Time_Actual
										FROM	#Data_Temp OA
												INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID																		
												INNER JOIN #Data_Gen as gs ON gs.Emp_id = OA.Emp_Id 				
										WHERE	CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS numeric(18,3)) >= CASE
														  WHEN CAST(REPLACE(gs.W_CompOff_Min_hours,':', '.') AS numeric(18,3)) = 0
														  THEN CAST(REPLACE(Isnull(Case when E.CompOff_Min_hrs = '' then '00:00' else e.CompOff_Min_hrs end ,'00:00'),':', '.') AS numeric(18,3))
														  ELSE CAST(REPLACE(gs.W_CompOff_Min_hours,':', '.') AS numeric(18,3))
														  END 
												AND (CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS numeric(18,3)) <> 0)
												AND NOT EXISTS(	SELECT 1 
																FROM	(
																			SELECT For_date
																			FROM  #Data_Temp OA
																			INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
																			INNER JOIN dbo.T0120_CompOff_Approval CA ON OA.Emp_Id = CA.Emp_ID AND OA.For_date = CA.Extra_Work_Date
																			WHERE CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS numeric(18,3)) >= 
																					CAST(REPLACE(Isnull(Case when E.CompOff_Min_hrs = '' then '00:00' else e.CompOff_Min_hrs end ,'00:00'),':', '.') AS numeric(18,3)) 
																				  AND (CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS numeric(18,3)) <> 0) 
																		UNION
																			SELECT For_date
																			FROM  #Data_Temp OA
																			INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
																			INNER JOIN dbo.T0100_CompOff_Application CA ON OA.Emp_Id = CA.Emp_ID AND OA.For_date = CA.Extra_Work_Date
																			WHERE CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS numeric(18,3)) >= 
																					CAST(REPLACE(Isnull(Case when E.CompOff_Min_hrs = '' then '00:00' else e.CompOff_Min_hrs end,'00:00'),':', '.') AS numeric(18,3)) 
																					AND (CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS numeric(18,3)) <> 0)
																		) T
																WHERE	T.FOR_DATE = OA.FOR_DATE
																)
												AND EXISTS(	SELECT 1 FROM #EMP_WEEKOFF WK  
															WHERE	WK.IS_CANCEL = 0 AND WK.EMP_ID=OA.EMP_ID 
																	AND WK.FOR_DATE= OA.FOR_DATE)  -- Added by Gadriwala Muslim 0312016
												AND NOT EXISTS(SELECT 1 FROM #HO_WO_WD T WHERE T.Emp_Id=OA.Emp_ID AND T.For_date=OA.For_date)


												
										--Added By Jaina 2-12-2015 End
										--Union 
										INSERT	INTO #HO_WO_WD
										SELECT	OA.*,
												dbo.F_Return_Hours(Duration_in_Sec) AS Working_Hour,
												dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) AS OT_Hour,
												dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) AS Actual_Worked_Hrs,
												@P_Days_Count AS P_Days_Count, dbo.F_Return_Hours(0) AS Weekoff_OT_Hour,
												dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec,0)) AS Holiday_OT_Hour,
												CA.Approve_Status AS Application_Status,'HO' AS DayFlag,dbo.F_Return_Hours(DATEDIFF(SECOND,shift_start_time,shift_end_time)) AS Shift_Hours,
												CONVERT(NVARCHAR(8),In_Time,108) AS In_Time_Actual,CONVERT(NVARCHAR(8),Out_Time,108) AS Out_Time_Actual
										FROM	#Data_Temp OA
												INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
												INNER JOIN dbo.T0120_CompOff_Approval CA ON OA.Emp_Id = CA.Emp_ID AND OA.For_date = CA.Extra_Work_Date									
												INNER JOIN #Data_Gen as gs ON gs.Emp_id = OA.Emp_Id 				
										WHERE	CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec),':', '.') AS numeric(18,3)) >= CASE
															  WHEN CAST(REPLACE(gs.H_CompOff_Min_hours,':', '.') AS numeric(18,3)) = 0
															  THEN CAST(REPLACE(Isnull(Case when E.CompOff_Min_hrs = '' then '00:00' else e.CompOff_Min_hrs end ,'00:00'),':', '.') AS numeric(18,3))
															  ELSE CAST(REPLACE(gs.H_CompOff_Min_hours,':', '.') AS numeric(18,3))
															  END AND (CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec),':', '.') AS numeric(18,3)) <> 0)
												AND EXISTS(SELECT 1 FROM #EMP_HOLIDAY HO  WHERE HO.IS_CANCEL = 0 AND HO.EMP_ID=OA.EMP_ID AND HO.FOR_DATE= OA.FOR_DATE)  -- ADDED BY GADRIWALA MUSLIM 0312016
												AND NOT EXISTS(SELECT 1 FROM #HO_WO_WD T WHERE T.Emp_Id=OA.Emp_ID AND T.For_date=OA.For_date)
										--UNION
										INSERT	INTO #HO_WO_WD
										SELECT	OA.*,
												dbo.F_Return_Hours(Duration_in_Sec) AS Working_Hour,
												dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) AS OT_Hour,
												dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) AS Actual_Worked_Hrs,
												@P_Days_Count AS P_Days_Count,dbo.F_Return_Hours(0) AS Weekoff_OT_Hour,
												dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec,0)) AS Holiday_OT_Hour,CA.Application_Status,
												'HO' AS DayFlag,dbo.F_Return_Hours(DATEDIFF(SECOND,shift_start_time,shift_end_time)) AS Shift_Hours,
												CONVERT(NVARCHAR(8),In_Time,108) AS In_Time_Actual,CONVERT(NVARCHAR(8),Out_Time,108) AS Out_Time_Actual
										FROM	#Data_Temp OA
												INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
												INNER JOIN dbo.T0100_CompOff_Application CA ON OA.Emp_Id = CA.Emp_ID AND OA.For_date = CA.Extra_Work_Date												
												INNER JOIN #Data_Gen as gs ON gs.Emp_id = OA.Emp_Id 				
										WHERE	CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec),':', '.') AS numeric(18,3)) >= CASE
															  WHEN CAST(REPLACE(gs.H_CompOff_Min_hours,':', '.') AS numeric(18,3)) = 0
															  THEN CAST(REPLACE(Isnull(Case when E.CompOff_Min_hrs = '' then '00:00' else e.CompOff_Min_hrs end ,'00:00'),':', '.') AS numeric(18,3))
															  ELSE CAST(REPLACE(gs.H_CompOff_Min_hours,':', '.') AS numeric(18,3))
															  END AND (CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec),':', '.') AS numeric(18,3)) <> 0)
												AND EXISTS(SELECT 1 FROM #EMP_HOLIDAY HO  WHERE HO.IS_CANCEL = 0 AND HO.EMP_ID=OA.EMP_ID AND HO.FOR_DATE= OA.FOR_DATE)  -- ADDED BY GADRIWALA MUSLIM 0312016
												AND NOT EXISTS(SELECT 1 FROM #HO_WO_WD T WHERE T.Emp_Id=OA.Emp_ID AND T.For_date=OA.For_date)
										--UNION
										INSERT	INTO #HO_WO_WD
										SELECT	Qry1.*
										FROM	(SELECT	dt.*,dbo.F_Return_Hours(Duration_in_Sec) AS Working_Hour,
														dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) AS OT_Hour,
														dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) AS Actual_Worked_Hrs,
														@P_Days_Count AS P_Days_Count,
														dbo.F_Return_Hours(0) AS Weekoff_OT_Hour,
														dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec,0)) AS Holiday_OT_Hour,
														'-' AS application_status,'HO' AS DayFlag,dbo.F_Return_Hours(DATEDIFF(SECOND,shift_start_time,shift_end_time)) AS Shift_Hours,
														CONVERT(NVARCHAR(8),In_Time,108) AS In_Time_Actual,CONVERT(NVARCHAR(8),Out_Time,108) AS Out_Time_Actual
												FROM	#Data_Temp DT
												WHERE	For_date NOT IN (SELECT	For_date
																		FROM	#Data_Temp OA
																				INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
																				INNER JOIN dbo.T0120_CompOff_Approval CA ON OA.Emp_Id = CA.Emp_ID AND OA.For_date = CA.Extra_Work_Date
																		WHERE	CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec),':', '.') AS numeric(18,3)) >= 
																					CAST(REPLACE(Isnull(Case when E.CompOff_Min_hrs = '' then '00:00' else e.CompOff_Min_hrs end ,'00:00'),':', '.') AS numeric(18,3)) AND 
																				(CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec),':', '.') AS numeric(18,3)) <> 0)
																		UNION
																		SELECT	For_date
																		FROM	#Data_Temp OA
																				INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
																				INNER JOIN dbo.T0100_CompOff_Application CA ON OA.Emp_Id = CA.Emp_ID AND OA.For_date = CA.Extra_Work_Date
																		WHERE	CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS numeric(18,3)) >= 
																				CAST(REPLACE(Isnull(case when E.CompOff_Min_hrs = '' then '00:00' else E.CompOff_Min_hrs end,'00:00'),':', '.') AS numeric(18,3)) OR 
																				CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec),':', '.') AS numeric(18,3)) >= 
																				CAST(REPLACE(Isnull(Case when E.CompOff_Min_hrs = '' then '00:00' else e.CompOff_Min_hrs end ,'00:00'),':', '.') AS numeric(18,3))
																		) 
														AND (CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS numeric(18,3)) <> 0 
															OR 
															CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec),':', '.') AS numeric(18,3)) <> 0)
												) Qry1
												INNER JOIN dbo.T0080_EMP_MASTER em ON Qry1.Emp_Id = em.Emp_ID									
												INNER JOIN #Data_Gen as gs ON gs.Emp_id = Qry1.Emp_Id 				
										WHERE	CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec),':', '.') AS numeric(18,3)) >= CASE
															  WHEN CAST(REPLACE(gs.H_CompOff_Min_hours,':', '.') AS numeric(18,3)) = 0
															  THEN CAST(REPLACE(Isnull(Case when Em.CompOff_Min_hrs = '' then '00:00' else em.CompOff_Min_hrs end ,'00:00'),':', '.') AS numeric(18,3))
															  ELSE CAST(REPLACE(gs.H_CompOff_Min_hours,':', '.') AS numeric(18,3))
															  END AND (CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec),':', '.') AS numeric(18,3)) <> 0)
												AND EXISTS(SELECT 1 FROM #EMP_HOLIDAY HO  WHERE HO.IS_CANCEL = 0 AND HO.EMP_ID=QRY1.EMP_ID AND HO.FOR_DATE= QRY1.FOR_DATE)  -- ADDED BY GADRIWALA MUSLIM 0312016
												AND NOT EXISTS(SELECT 1 FROM #HO_WO_WD T WHERE T.Emp_Id=Qry1.Emp_ID AND T.For_date=Qry1.For_date)
													  
										--Union -- Added By Gadriwala Muslim For Adjust CompOff Officially  Employee Go Out . 18/08/2015
										INSERT	INTO #HO_WO_WD
										SELECT	OA.*,
												dbo.F_Return_Hours(Duration_in_Sec) AS Working_Hour,
												dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(DATEDIFF(s,OA.in_Time,GPQuery.in_Time),0)) AS OT_Hour,
												dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(DATEDIFF(s,OA.in_Time,GPQuery.in_Time),0)) AS Actual_Worked_Hrs,
												@P_Days_Count AS P_Days_Count, dbo.F_Return_Hours(0) AS Weekoff_OT_Hour,
												dbo.F_Return_Hours(ISNULL(DATEDIFF(s,OA.in_Time,GPQuery.in_Time),0)) AS Holiday_OT_Hour,
												'-' AS application_status,'HO-G' AS DayFlag,dbo.F_Return_Hours(DATEDIFF(SECOND,shift_start_time,shift_end_time)) AS Shift_Hours,
												CONVERT(NVARCHAR(8),OA.In_Time,108) AS In_Time_Actual,CONVERT(NVARCHAR(8),Out_Time,108) AS Out_Time_Actual
										FROM	#Data_Temp OA
												INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID									
												INNER JOIN #Data_Gen as gs ON gs.Emp_id = OA.Emp_Id 				
												INNER JOIN ( select max(GP.In_Time) as In_Time,GP.emp_id,GP.For_Date,Is_Approved,Reason_id from T0150_EMP_Gate_Pass_INOUT_RECORD GP inner join #Data_Temp OA on OA.Emp_ID = GP.emp_id and OA.For_date = GP.For_date and GP.Is_Approved = 1 
												INNER JOIN T0040_Reason_Master RM on RM.Res_Id = GP.Reason_id and Type = 'GatePass' and Gate_Pass_Type = 'Official' group by GP.Emp_ID,GP.For_Date,GP.Is_Approved,GP.Reason_id ) GPQuery on OA.emp_id = GPQuery.emp_ID and OA.For_date = GPQuery.For_date 								
										WHERE	CAST(REPLACE(dbo.F_Return_Hours(DATEDIFF(s,OA.in_Time,GPQuery.in_Time)),':', '.') AS numeric(18,3)) >= CASE
															  WHEN CAST(REPLACE(gs.H_CompOff_Min_hours,':', '.') AS numeric(18,3)) = 0
															  THEN CAST(REPLACE(Isnull(Case when E.CompOff_Min_hrs = '' then '00:00' else e.CompOff_Min_hrs end ,'00:00'),':', '.') AS numeric(18,3))
															  ELSE CAST(REPLACE(gs.H_CompOff_Min_hours,':', '.') AS numeric(18,3))
															  END AND (CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec),':', '.') AS numeric(18,3)) <> 0)
												AND OA.For_date NOT IN (SELECT	For_date
																		FROM	#Data_Temp OA
																				INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
																				INNER JOIN dbo.T0120_CompOff_Approval CA ON OA.Emp_Id = CA.Emp_ID AND OA.For_date = CA.Extra_Work_Date
																		WHERE	CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec),':', '.') AS numeric(18,3)) >= CAST(REPLACE(Isnull(Case when E.CompOff_Min_hrs = '' then '00:00' else e.CompOff_Min_hrs end ,'00:00'),':', '.') AS numeric(18,3)) 
																				AND 
																				(CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec),':', '.') AS numeric(18,3)) <> 0))
												AND EXISTS(SELECT 1 FROM #EMP_HOLIDAY HO  WHERE HO.IS_CANCEL = 0 AND HO.EMP_ID=OA.EMP_ID AND HO.FOR_DATE= OA.FOR_DATE)  -- ADDED BY GADRIWALA MUSLIM 0312016
												AND NOT EXISTS(SELECT 1 FROM #HO_WO_WD T WHERE T.Emp_Id=OA.Emp_ID AND T.For_date=OA.For_date)
										--Added By Jaina 2-12-2015 For (Holiday) Start
										--UNION
										INSERT	INTO #HO_WO_WD
										SELECT	OA.*,
												dbo.F_Return_Hours(Duration_in_Sec)
												AS Working_Hour,
												dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) AS OT_Hour,
												dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) AS Actual_Worked_Hrs,
												@P_Days_Count AS P_Days_Count, dbo.F_Return_Hours(0) AS Weekoff_OT_Hour,
												dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec,0)) AS Holiday_OT_Hour,
												'-' AS application_status,'HO' AS DayFlag,dbo.F_Return_Hours(DATEDIFF(SECOND,shift_start_time,shift_end_time)) AS Shift_Hours,
												CONVERT(NVARCHAR(8),In_Time,108) AS In_Time_Actual,CONVERT(NVARCHAR(8),Out_Time,108) AS Out_Time_Actual
										FROM	#Data_Temp OA
												INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
												INNER JOIN #Data_Gen as gs ON gs.Emp_id = OA.Emp_Id 				
										WHERE	CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec),':', '.') AS numeric(18,3)) >= CASE
															  WHEN CAST(REPLACE(gs.H_CompOff_Min_hours,':', '.') AS numeric(18,3)) = 0
															  THEN CAST(REPLACE(Isnull(Case when E.CompOff_Min_hrs = '' then '00:00' else e.CompOff_Min_hrs end ,'00:00'),':', '.') AS numeric(18,3))
															  ELSE CAST(REPLACE(gs.H_CompOff_Min_hours,':', '.') AS numeric(18,3))
															  END AND (CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec),':', '.') AS numeric(18,3)) <> 0)
												AND NOT EXISTS(	SELECT 1 
																FROM	(	--Change By Jaina 9-12-2015 Filed Holiday_OT_Sec in both query
																		SELECT FOR_DATE
																		FROM	#Data_Temp OA
																				INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
																				INNER JOIN dbo.T0120_CompOff_Approval CA ON OA.Emp_Id = CA.Emp_ID AND OA.For_date = CA.Extra_Work_Date
																		WHERE	CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec),':', '.') AS numeric(18,3)) >= 
																				CAST(REPLACE(Isnull(Case when E.CompOff_Min_hrs = '' then '00:00' else e.CompOff_Min_hrs end ,'00:00'),':', '.') AS numeric(18,3)) 
																				AND (CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec),':', '.') AS numeric(18,3)) <> 0) 
																		UNION
																		SELECT  FOR_DATE
																		FROM	#Data_Temp OA
																				INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
																				INNER JOIN dbo.T0100_CompOff_Application CA ON OA.Emp_Id = CA.Emp_ID AND OA.For_date = CA.Extra_Work_Date
																		WHERE	CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec),':', '.') AS numeric(18,3)) >= 
																				CAST(REPLACE(Isnull(Case when E.CompOff_Min_hrs = '' then '00:00' else e.CompOff_Min_hrs end,'00:00'),':', '.') AS numeric(18,3)) 
																				AND (CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec),':', '.') AS numeric(18,3)) <> 0)
																		) T
																WHERE	T.FOR_DATE = OA.FOR_DATE)
												AND EXISTS(SELECT 1 FROM #EMP_HOLIDAY HO  
															WHERE HO.IS_CANCEL = 0 AND HO.EMP_ID=OA.EMP_ID AND HO.FOR_DATE= OA.FOR_DATE)  -- ADDED BY GADRIWALA MUSLIM 0312016
												AND NOT EXISTS(SELECT 1 FROM #HO_WO_WD T WHERE T.Emp_Id=OA.Emp_ID AND T.For_date=OA.For_date)
										--Added By Jaina 2-12-2015 End 													
										--UNION		
										INSERT	INTO #HO_WO_WD
										SELECT	OA.*,
												dbo.F_Return_Hours(Duration_in_Sec - OT_SEC) AS Working_Hour,
												CASE WHEN DATEDIFF(SECOND,In_Time,shift_Start_time)>=3600 
													OR DATEDIFF(SECOND,Shift_End_Time,Out_Time)>=3600 THEN 
														dbo.F_Return_Hours(ISNULL(OT_SEC, 0)) 
												ELSE dbo.F_Return_Hours( 0) END AS OT_Hour,
												dbo.F_Return_Hours(Duration_in_Sec/* + ISNULL(OT_Sec,0)*/) AS Actual_Worked_Hrs,
												@P_Days_Count AS P_Days_Count,
												dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0)) AS Weekoff_OT_Hour,
												dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec,0)) AS Holiday_OT_Hour,
												CA.Approve_Status AS Application_Status,
												'WD' AS DayFlag,dbo.F_Return_Hours(DATEDIFF(SECOND,shift_start_time,shift_end_time)) AS Shift_Hours,
												CONVERT(NVARCHAR(8),In_Time,108) AS In_Time_Actual,CONVERT(NVARCHAR(8),Out_Time,108) AS Out_Time_Actual
										FROM	#Data_Temp OA
												INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
												INNER JOIN dbo.T0120_CompOff_Approval CA ON OA.Emp_Id = CA.Emp_ID AND OA.For_date = CA.Extra_Work_Date
												INNER JOIN #Data_Gen as gs ON gs.Emp_id = OA.Emp_Id 				
										WHERE	CAST(REPLACE(dbo.F_Return_Hours(OT_SEC),':', '.') AS numeric(18,3)) >= CASE
															  WHEN CAST(REPLACE(gs.CompOff_Min_hours,':', '.') AS numeric(18,3)) = 0
															  THEN CAST(REPLACE(Isnull(Case when E.CompOff_Min_hrs = '' then '00:00' else e.CompOff_Min_hrs end ,'00:00'),':', '.') AS numeric(18,3))
															  ELSE CAST(REPLACE(gs.CompOff_Min_hours,':', '.') AS numeric(18,3))
															  END AND CAST(REPLACE(dbo.F_Return_Hours(OT_SEC),':', '.') AS numeric(18,3)) <> 0
												AND NOT EXISTS(SELECT 1 FROM #HO_WO_WD T WHERE T.Emp_Id=OA.Emp_ID AND T.For_date=OA.For_date)
										--UNION
										INSERT	INTO #HO_WO_WD
										SELECT	OA.*,
												dbo.F_Return_Hours(Duration_in_Sec - OT_SEC) AS Working_Hour,
												CASE WHEN DATEDIFF(SECOND,In_Time,shift_Start_time)>=3600 
													OR DATEDIFF(SECOND,Shift_End_Time,Out_Time)>=3600 THEN 
														dbo.F_Return_Hours(ISNULL(OT_SEC, 0)) 
												ELSE dbo.F_Return_Hours( 0) END AS OT_Hour,
												dbo.F_Return_Hours(Duration_in_Sec /*+ ISNULL(OT_Sec,0)*/) AS Actual_Worked_Hrs,
												@P_Days_Count AS P_Days_Count,
												dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0)) AS Weekoff_OT_Hour,
												dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec, 0)) AS Holiday_OT_Hour,
												CA.Application_Status, 'WD' AS DayFlag,dbo.F_Return_Hours(DATEDIFF(SECOND,shift_start_time,shift_end_time)) AS Shift_Hours,
												CONVERT(NVARCHAR(8),In_Time,108) AS In_Time_Actual,CONVERT(NVARCHAR(8),Out_Time,108) AS Out_Time_Actual
										FROM	#Data_Temp OA
												INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
												INNER JOIN dbo.T0100_CompOff_Application CA ON OA.Emp_Id = CA.Emp_ID AND OA.For_date = CA.Extra_Work_Date								
												INNER JOIN #Data_Gen as gs ON gs.Emp_id = OA.Emp_Id 				
										WHERE	CAST(REPLACE(dbo.F_Return_Hours(OT_SEC),':', '.') AS numeric(18,3)) >= CASE
															  WHEN CAST(REPLACE(gs.CompOff_Min_hours,':', '.') AS numeric(18,3)) = 0
															  THEN CAST(REPLACE(Isnull(Case when E.CompOff_Min_hrs = '' then '00:00' else e.CompOff_Min_hrs end ,'00:00'),':', '.') AS numeric(18,3))
															  ELSE CAST(REPLACE(gs.CompOff_Min_hours,':', '.') AS numeric(18,3))
															  END AND CAST(REPLACE(dbo.F_Return_Hours(OT_SEC),':', '.') AS numeric(18,3)) <> 0
												AND NOT EXISTS(SELECT 1 FROM #HO_WO_WD T WHERE T.Emp_Id=OA.Emp_ID AND T.For_date=OA.For_date)
										--UNION
										INSERT	INTO #HO_WO_WD
										SELECT	Qry1.*
										FROM	(SELECT		dt.*,
															dbo.F_Return_Hours(Duration_in_Sec - OT_SEC) AS Working_Hour,
															CASE WHEN DATEDIFF(SECOND,In_Time,shift_Start_time)>=3600 
																OR DATEDIFF(SECOND,Shift_End_Time,Out_Time)>=3600 THEN 
																	dbo.F_Return_Hours(ISNULL(OT_SEC, 0)) 
															ELSE dbo.F_Return_Hours( 0) END AS OT_Hour,
															dbo.F_Return_Hours(Duration_in_Sec/* + ISNULL(OT_Sec,0)*/) AS Actual_Worked_Hrs,
															@P_Days_Count AS P_Days_Count,
															dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0)) AS Weekoff_OT_Hour,
														dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec,0)) AS Holiday_OT_Hour,
														'-' AS application_status,
														'WD' AS DayFlag,dbo.F_Return_Hours(DATEDIFF(SECOND,shift_start_time,shift_end_time)) AS Shift_Hours,
														CONVERT(NVARCHAR(8),In_Time,108) AS In_Time_Actual,CONVERT(NVARCHAR(8),Out_Time,108) AS Out_Time_Actual
												FROM	#Data_Temp DT
												WHERE	For_date NOT IN (
																		SELECT	OA.For_Date
																		FROM	[#Data_Temp] AS OA
																				INNER JOIN T0080_EMP_MASTER AS E ON OA.Emp_ID = E.Emp_ID
																				INNER JOIN T0120_CompOff_Approval AS CA ON OA.Emp_Id = CA.Emp_ID AND OA.For_date = CA.Extra_Work_Date												
																				INNER JOIN #Data_Gen as gs ON gs.Emp_id = OA.Emp_Id 				
																		WHERE	(CAST(REPLACE(dbo.F_Return_Hours(OT_SEC),':', '.') AS numeric(18,3)) >= CASE
																				WHEN CAST(REPLACE(gs.CompOff_Min_hours,':', '.') AS numeric(18,3)) = 0
																					THEN CAST(REPLACE(Isnull(Case when E.CompOff_Min_hrs = '' then '00:00' else e.CompOff_Min_hrs end ,'00:00'),':', '.') AS numeric(18,3))
																				ELSE CAST(REPLACE(gs.CompOff_Min_hours,':', '.') AS numeric(18,3))
																					END
																				) AND (CAST(REPLACE(dbo.F_Return_Hours(OT_SEC),':', '.') AS numeric(18,3)) <> 0)
																		UNION
																		SELECT	OA.For_Date
																		FROM	[#Data_Temp] AS OA
																				INNER JOIN T0080_EMP_MASTER AS E ON OA.Emp_ID = E.Emp_ID
																				INNER JOIN T0100_CompOff_Application AS CA ON OA.Emp_Id = CA.Emp_ID AND OA.For_date = CA.Extra_Work_Date
																				INNER JOIN #Data_Gen as gs ON gs.Emp_id = OA.Emp_Id 				
																		WHERE	(CAST(REPLACE(dbo.F_Return_Hours(OT_SEC),':', '.') AS numeric(18,3)) >= CASE
																				WHEN CAST(REPLACE(gs.CompOff_Min_hours,':', '.') AS numeric(18,3)) = 0
																					THEN CAST(REPLACE(E.CompOff_Min_hrs,':', '.') AS numeric(18,3))
																				ELSE CAST(REPLACE(gs.CompOff_Min_hours,':', '.') AS numeric(18,3))
																					END
																				) AND (CAST(REPLACE(dbo.F_Return_Hours(OT_SEC),':', '.') AS numeric(18,3)) <> 0)
																		)
												) Qry1
												INNER JOIN T0080_EMP_MASTER em ON Qry1.Emp_Id = em.Emp_ID								
												INNER JOIN #Data_Gen as gs ON gs.Emp_id = Qry1.Emp_Id 				
										WHERE	CAST(REPLACE(dbo.F_Return_Hours(OT_SEC),':', '.') AS numeric(18,3)) >= CASE 
													WHEN 
														CAST(REPLACE(isnull(															 
														case when 
															gs.CompOff_Min_hours ='' then '00:00' else gs.CompOff_Min_hours end															  
														,'00:00'),':', '.') AS numeric(18,3)) = 0
														THEN CAST(REPLACE(isnull(
															  
														case when  Em.CompOff_Min_hrs='' then '00:00' else Em.CompOff_Min_hrs end
															  
														,'00:00'),':', '.') AS numeric(18,3))
														ELSE CAST(REPLACE(isnull(															  
															case when gs.CompOff_Min_hours='' then '00:00' else gs.CompOff_Min_hours end															  
														,'00:00'),':', '.') AS numeric(18,3))
													END 
												AND CAST(REPLACE(dbo.F_Return_Hours(OT_SEC),':', '.') AS numeric(18,3)) <> 0
												AND NOT EXISTS(SELECT 1 FROM #HO_WO_WD T WHERE T.Emp_Id=Qry1.Emp_ID AND T.For_date=Qry1.For_date)

										SELECT * FROM #HO_WO_WD
										ORDER BY For_Date

									END
								ELSE IF @return_record_set = 14  -- HO & WO
									BEGIN
										-- Added Nilesh Patel on 20072018 --For Cliantha -- if Employee Working 18 Hours next absent day adjust with previouse day OT and Deduct working hours from OT.
										--IF Exists(SELECT 1 FROM T0165_ATTENDANCE_APPROVAL WHERE CMP_ID = @CMP_ID AND FOR_DATE >=@FROM_DATE AND FOR_DATE <=@TO_DATE AND ATT_STATUS = 'A')
										--	Begin
										--		UPDATE DT
										--			SET DT.DURATION_IN_SEC = (Case When DT.DURATION_IN_SEC > Q.SHIFT_SEC Then DT.DURATION_IN_SEC - Q.SHIFT_SEC Else 0 END),
										--				DT.OT_SEC = CASE WHEN DT.OT_SEC > Q.SHIFT_SEC THEN 
										--								CASE WHEN DT.Emp_OT_Min_Limit > (DT.OT_SEC - Q.SHIFT_SEC) THEN	
										--									0
										--								ELSE  (DT.OT_SEC - Q.SHIFT_SEC) END
										--							ELSE 0 END,
										--				DT.Weekoff_OT_Sec = CASE WHEN G.Tras_Week_OT = 1 AND DT.Weekoff_OT_Sec > Q.SHIFT_SEC THEN DT.Weekoff_OT_Sec - Q.SHIFT_SEC ELSE DT.Weekoff_OT_Sec END,
										--				DT.Holiday_OT_Sec = CASE WHEN G.Tras_Week_OT = 1 AND DT.Holiday_OT_Sec > Q.SHIFT_SEC THEN DT.Holiday_OT_Sec - Q.SHIFT_SEC ELSE DT.Holiday_OT_Sec END
										--		FROM #DATA_TEMP DT INNER JOIN 
										--		(
										--				SELECT EMP_ID,DATEADD(D,-1,FOR_DATE) AS FORDATE,P_DAYS,ATT_STATUS,SHIFT_SEC
										--				FROM T0165_ATTENDANCE_APPROVAL
										--				WHERE CMP_ID = @CMP_ID AND FOR_DATE >=@FROM_DATE AND FOR_DATE <=@TO_DATE AND ATT_STATUS = 'A' AND P_DAYS <> 0
										--		)Q ON DT.EMP_ID =Q.EMP_ID  AND DT.FOR_DATE = Q.FORDATE
										--		INNER JOIN #EMP_GEN_SETTINGS G ON DT.Emp_Id=G.EMP_ID							
										--	End
										
										SELECT	OA.*,
												dbo.F_Return_Hours(Duration_in_Sec)
												AS Working_Hour,
												dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) AS OT_Hour,
												dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) AS Actual_Worked_Hrs,
												@P_Days_Count AS P_Days_Count,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0)) AS Weekoff_OT_Hour,
												dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec,0)) AS Holiday_OT_Hour,
												CA.Approve_Status AS Application_Status,CAST('WO' AS VARCHAR(12)) AS DayFlag,dbo.F_Return_Hours(DATEDIFF(SECOND,shift_start_time,shift_end_time)) AS Shift_Hours,
												CONVERT(NVARCHAR(8),In_Time,108) AS In_Time_Actual,CONVERT(NVARCHAR(8),Out_Time,108) AS Out_Time_Actual
										FROM	#Data_Temp OA
												INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
												INNER JOIN dbo.T0120_CompOff_Approval CA ON OA.Emp_Id = CA.Emp_ID AND OA.For_date = CA.Extra_Work_Date
												INNER JOIN (SELECT	t1.emp_id,t1.branch_id
															FROM	T0095_Increment t1
															INNER JOIN (SELECT emp_id,MAX(Increment_ID)AS Increment_ID	-- Ankit 12092014 for Same Date Increment
																		FROM t0095_increment GROUP BY emp_id)
																	AS t2 ON t1.emp_id = t2.emp_id AND t1.Increment_ID = t2.Increment_ID)
														AS inc ON OA.Emp_ID = inc.emp_id
												INNER JOIN T0040_General_Setting gs ON gs.branch_id = inc.branch_id
										WHERE	CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS numeric(18,3)) >= CASE
															  WHEN CAST(REPLACE(gs.W_CompOff_Min_hours,':', '.') AS numeric(18,3)) = 0
															  THEN CAST(REPLACE(Isnull(Case when E.CompOff_Min_hrs = '' then '00:00' else e.CompOff_Min_hrs end ,'00:00'),':', '.') AS numeric(18,3))
															  ELSE CAST(REPLACE(gs.W_CompOff_Min_hours,':', '.') AS numeric(18,3))
															  END 
												AND (CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS numeric(18,3)) <> 0)
												AND EXISTS(SELECT 1 FROM #EMP_WEEKOFF WK  WHERE WK.IS_CANCEL = 0 AND WK.EMP_ID=OA.EMP_ID AND WK.FOR_DATE= OA.FOR_DATE)  -- Added by Gadriwala Muslim 0312016												
										UNION
										SELECT	OA.*,
												dbo.F_Return_Hours(Duration_in_Sec)
												AS Working_Hour,
												dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) AS OT_Hour,
												dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) AS Actual_Worked_Hrs,
												@P_Days_Count AS P_Days_Count,
												dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0)) AS Weekoff_OT_Hour,
												dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec,0)) AS Holiday_OT_Hour,
												CA.Application_Status,'WO' AS DayFlag,dbo.F_Return_Hours(DATEDIFF(SECOND,shift_start_time,shift_end_time)) AS Shift_Hours,
												CONVERT(NVARCHAR(8),In_Time,108) AS In_Time_Actual,CONVERT(NVARCHAR(8),Out_Time,108) AS Out_Time_Actual
										FROM	#Data_Temp OA
												INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
												INNER JOIN dbo.T0100_CompOff_Application CA ON OA.Emp_Id = CA.Emp_ID AND OA.For_date = CA.Extra_Work_Date
												INNER JOIN (SELECT	t1.emp_id,t1.branch_id FROM	T0095_Increment t1  
															INNER JOIN (SELECT emp_id,MAX(Increment_ID) AS Increment_ID	-- Ankit 12092014 for Same Date Increment
																	  FROM t0095_increment GROUP BY emp_id)
																	AS t2 ON t1.emp_id = t2.emp_id AND t1.Increment_ID = t2.Increment_ID)
														AS inc ON OA.Emp_ID = inc.emp_id
												INNER JOIN T0040_General_Setting gs ON gs.branch_id = inc.branch_id
										WHERE	CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS numeric(18,3)) >= CASE
															  WHEN CAST(REPLACE(gs.W_CompOff_Min_hours,':', '.') AS numeric(18,3)) = 0
															  THEN CAST(REPLACE(Isnull(Case when E.CompOff_Min_hrs = '' then '00:00' else e.CompOff_Min_hrs end ,'00:00'),':', '.') AS numeric(18,3))
															  ELSE CAST(REPLACE(gs.W_CompOff_Min_hours,':', '.') AS numeric(18,3))
															  END 
      								AND (CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS numeric(18,3)) <> 0)
      								AND EXISTS(SELECT 1 FROM #EMP_WEEKOFF WK  WHERE WK.IS_CANCEL = 0 AND WK.EMP_ID=OA.EMP_ID AND WK.FOR_DATE= OA.FOR_DATE)  -- Added by Gadriwala Muslim 0312016

										UNION
										SELECT	Qry1.*
										FROM	(SELECT	dt.*,
														dbo.F_Return_Hours(Duration_in_Sec)
														AS Working_Hour,
														dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) AS OT_Hour,
														dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) AS Actual_Worked_Hrs,
														@P_Days_Count AS P_Days_Count,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0)) AS Weekoff_OT_Hour,
														dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec,0)) AS Holiday_OT_Hour,'-' AS application_status,
														'WO' AS DayFlag,dbo.F_Return_Hours(DATEDIFF(SECOND,shift_start_time,shift_end_time)) AS Shift_Hours,
														CONVERT(NVARCHAR(8),In_Time,108) AS In_Time_Actual,CONVERT(NVARCHAR(8),Out_Time,108) AS Out_Time_Actual
												 FROM	#Data_Temp DT
												 WHERE	For_date NOT IN (
																		SELECT	For_date
																		FROM	#Data_Temp OA
																				INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
																				INNER JOIN dbo.T0120_CompOff_Approval CA ON OA.Emp_Id = CA.Emp_ID AND OA.For_date = CA.Extra_Work_Date
																		WHERE CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS numeric(18,3)) >= 
																				CAST(REPLACE(Isnull(Case when E.CompOff_Min_hrs = '' then '00:00' else e.CompOff_Min_hrs end ,'00:00'),':', '.') AS numeric(18,3)) 
																			  AND (CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS numeric(18,3)) <> 0)  AND DT.EMP_ID=OA.EMP_ID AND DT.FOR_DATE=OA.FOR_DATE
																		UNION
																		SELECT	For_date
																		FROM	#Data_Temp OA
																				INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
																				INNER JOIN dbo.T0100_CompOff_Application CA ON OA.Emp_Id = CA.Emp_ID AND OA.For_date = CA.Extra_Work_Date
																		WHERE	CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS numeric(18,3)) >= 
																				CAST(REPLACE(Isnull(Case when E.CompOff_Min_hrs = '' then '00:00' else e.CompOff_Min_hrs end,'00:00'),':', '.') AS numeric(18,3))
																				AND DT.EMP_ID=OA.EMP_ID AND DT.FOR_DATE=OA.FOR_DATE
																			) 
														AND (CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS numeric(18,3)) <> 0)
																		
												) Qry1
												INNER JOIN dbo.T0080_EMP_MASTER em ON Qry1.Emp_Id = em.Emp_ID
												INNER JOIN (SELECT	t1.emp_id,t1.branch_id FROM	T0095_Increment t1  
															INNER JOIN (SELECT emp_id,MAX(Increment_ID) AS Increment_ID	-- Ankit 12092014 for Same Date Increment
																	  FROM t0095_increment GROUP BY emp_id)
																	AS t2 ON t1.emp_id = t2.emp_id AND t1.Increment_ID = t2.Increment_ID)
														AS inc ON Qry1.Emp_ID = inc.emp_id
												INNER JOIN T0040_General_Setting gs ON gs.branch_id = inc.branch_id
										WHERE	CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS numeric(18,3)) >= CASE
															  WHEN CAST(REPLACE(gs.W_CompOff_Min_hours,':', '.') AS numeric(18,3)) = 0
															  THEN CAST(REPLACE(Isnull(Case when Em.CompOff_Min_hrs = '' then '00:00' else em.CompOff_Min_hrs end,'00:00'),':', '.') AS numeric(18,3))
															  ELSE CAST(REPLACE(gs.W_CompOff_Min_hours,':', '.') AS numeric(18,3))
															  END
												AND (CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS numeric(18,3)) <> 0)
												AND EXISTS(SELECT 1 FROM #EMP_WEEKOFF WK  WHERE WK.IS_CANCEL = 0 AND WK.EMP_ID=Qry1.EMP_ID AND WK.FOR_DATE= Qry1.FOR_DATE)  -- Added by Gadriwala Muslim 0312016

										union	-- Added By Gadriwala Muslim For Adjust CompOff Officially  Employee Go Out . 04/09/2015
											SELECT	OA.*,
												dbo.F_Return_Hours(DATEDIFF(s,OA.in_Time,GPQuery.in_Time))
												AS Working_Hour,
												dbo.F_Return_Hours(DATEDIFF(s,OA.in_Time,GPQuery.in_Time) + ISNULL(Holiday_OT_Sec,0)) AS OT_Hour,
												dbo.F_Return_Hours(DATEDIFF(s,OA.in_Time,GPQuery.in_Time) + ISNULL(Holiday_OT_Sec,0)) AS Actual_Worked_Hrs,
												@P_Days_Count AS P_Days_Count,dbo.F_Return_Hours(ISNULL(DATEDIFF(s,OA.in_Time,GPQuery.in_Time),0)) AS Weekoff_OT_Hour,
												dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec,0)) AS Holiday_OT_Hour,
												'-' AS application_status,'WO-G' AS DayFlag,dbo.F_Return_Hours(DATEDIFF(SECOND,shift_start_time,OA.shift_end_time)) AS Shift_Hours,
										CONVERT(NVARCHAR(8),OA.In_Time,108) AS In_Time_Actual,CONVERT(NVARCHAR(8),GPQuery.IN_Time,108) AS Out_Time_Actual
										FROM	#Data_Temp OA
										INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
										INNER JOIN (SELECT	t1.emp_id,t1.branch_id
													FROM	T0095_Increment t1  
													INNER JOIN (SELECT emp_id,MAX(Increment_ID)AS Increment_ID
															  FROM t0095_increment where cmp_ID = @cmp_ID GROUP BY emp_id)
															AS t2 ON t1.emp_id = t2.emp_id AND t1.Increment_ID = t2.Increment_ID)
												AS inc ON OA.Emp_ID = inc.emp_id
										INNER JOIN (select GS.For_Date,Gs.Branch_ID,W_CompOff_Min_hours from T0040_GENERAL_SETTING GS inner join
													( 
														select MAX(For_date) as For_Date,Branch_ID from T0040_General_Setting gs 
														where Cmp_ID = @Cmp_ID  and For_Date <= @To_Date group by Branch_ID
													 )Qry on Qry.Branch_ID = GS.Branch_ID and Qry.For_Date = GS.For_Date
													) Gen_Qry ON Gen_Qry.branch_id = inc.branch_id
										Inner join ( select max(GP.In_Time) as In_Time,GP.emp_id,GP.For_Date,Is_Approved,Reason_id from T0150_EMP_Gate_Pass_INOUT_RECORD GP inner join #Data_Temp OA on OA.Emp_ID = GP.emp_id and OA.For_date = GP.For_date and GP.Is_Approved = 1
										Inner join T0040_Reason_Master RM on RM.Res_Id = GP.Reason_id and Type = 'GatePass' and Gate_Pass_Type = 'Official' group by GP.Emp_ID,GP.For_Date,GP.Is_Approved,GP.Reason_id ) GPQuery on OA.emp_id = GPQuery.emp_ID and OA.For_date = GPQuery.For_date 
										where
										CAST(REPLACE(dbo.F_Return_Hours(DATEDIFF(s,OA.in_Time,GPQuery.in_Time)),':', '.') AS numeric(18,3)) >= CASE
															  WHEN CAST(REPLACE(Gen_Qry.W_CompOff_Min_hours,':', '.') AS numeric(18,3)) = 0
															  THEN CAST(REPLACE(Isnull(Case when E.CompOff_Min_hrs = '' then '00:00' else e.CompOff_Min_hrs end,'00:00'),':', '.') AS numeric(18,3))
															  ELSE CAST(REPLACE(Gen_Qry.W_CompOff_Min_hours,':', '.') AS numeric(18,3))
															  END
												AND (CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS numeric(18,3)) <> 0) and 
												OA.For_date NOT IN (
														SELECT For_date
														FROM  #Data_Temp OA
														INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
														INNER JOIN dbo.T0120_CompOff_Approval CA ON OA.Emp_Id = CA.Emp_ID AND OA.For_date = CA.Extra_Work_Date
														WHERE CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS numeric(18,3)) >= 
																CAST(REPLACE(Isnull(Case when E.CompOff_Min_hrs = '' then '00:00' else e.CompOff_Min_hrs end ,'00:00'),':', '.') AS numeric(18,3)) 
															  AND (CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS numeric(18,3)) <> 0) )
														AND EXISTS(SELECT 1 FROM #EMP_WEEKOFF WK  WHERE WK.IS_CANCEL = 0 AND WK.EMP_ID=OA.EMP_ID AND WK.FOR_DATE= OA.FOR_DATE)  -- Added by Gadriwala Muslim 0312016

								
										Union
										SELECT	OA.*,
											dbo.F_Return_Hours(Duration_in_Sec)
											AS Working_Hour,
											dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) AS OT_Hour,
											dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) AS Actual_Worked_Hrs,
											@P_Days_Count AS P_Days_Count, dbo.F_Return_Hours(0) AS Weekoff_OT_Hour,
											dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec,0)) AS Holiday_OT_Hour,
											CA.Approve_Status AS Application_Status,CAST('HO' AS VARCHAR(25)) AS DayFlag,
											dbo.F_Return_Hours(DATEDIFF(SECOND,shift_start_time,shift_end_time)) AS Shift_Hours,
											CONVERT(NVARCHAR(8),In_Time,108) AS In_Time_Actual,CONVERT(NVARCHAR(8),Out_Time,108) AS Out_Time_Actual
									FROM	#Data_Temp OA
									INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
									INNER JOIN dbo.T0120_CompOff_Approval CA ON OA.Emp_Id = CA.Emp_ID AND OA.For_date = CA.Extra_Work_Date
									INNER JOIN (SELECT	t1.emp_id,t1.branch_id
												FROM	T0095_Increment t1
												INNER JOIN (SELECT emp_id, MAX(Increment_ID) AS Increment_ID	-- Ankit 12092014 for Same Date Increment
															FROM t0095_increment  
															GROUP BY emp_id)
														AS t2 ON t1.emp_id = t2.emp_id AND t1.Increment_ID = t2.Increment_ID)
											AS inc ON OA.Emp_ID = inc.emp_id
									INNER JOIN T0040_General_Setting gs ON gs.branch_id = inc.branch_id
									WHERE	CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec),':', '.') AS numeric(18,3)) >= CASE
															  WHEN CAST(REPLACE(gs.H_CompOff_Min_hours,':', '.') AS numeric(18,3)) = 0
															  THEN CAST(REPLACE(Isnull(Case when E.CompOff_Min_hrs = '' then '00:00' else e.CompOff_Min_hrs end ,'00:00'),':', '.') AS numeric(18,3))
															  ELSE CAST(REPLACE(gs.H_CompOff_Min_hours,':', '.') AS numeric(18,3))
															  END AND (CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec),':', '.') AS numeric(18,3)) <> 0)
											AND EXISTS(SELECT 1 FROM #EMP_HOLIDAY HO  WHERE HO.IS_CANCEL = 0 AND HO.EMP_ID=OA.EMP_ID AND HO.FOR_DATE= OA.FOR_DATE)  -- ADDED BY GADRIWALA MUSLIM 0312016
									UNION
									SELECT	OA.*,
											dbo.F_Return_Hours(Duration_in_Sec)
											AS Working_Hour,
											dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) AS OT_Hour,
											dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) AS Actual_Worked_Hrs,
											@P_Days_Count AS P_Days_Count,dbo.F_Return_Hours(0) AS Weekoff_OT_Hour,
											dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec,0)) AS Holiday_OT_Hour,CA.Application_Status,
											'HO' AS DayFlag,dbo.F_Return_Hours(DATEDIFF(SECOND,shift_start_time,shift_end_time)) AS Shift_Hours,
										CONVERT(NVARCHAR(8),In_Time,108) AS In_Time_Actual,CONVERT(NVARCHAR(8),Out_Time,108) AS Out_Time_Actual
									FROM	#Data_Temp OA
									INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
									INNER JOIN dbo.T0100_CompOff_Application CA ON OA.Emp_Id = CA.Emp_ID AND OA.For_date = CA.Extra_Work_Date
									INNER JOIN (SELECT	t1.emp_id,t1.branch_id FROM	T0095_Increment t1  
												INNER JOIN (SELECT emp_id,MAX(Increment_ID) AS Increment_ID	-- Ankit 12092014 for Same Date Increment
															FROM t0095_increment GROUP BY emp_id)
														AS t2 ON t1.emp_id = t2.emp_id AND t1.Increment_ID = t2.Increment_ID)
											AS inc ON OA.Emp_ID = inc.emp_id
									INNER JOIN T0040_General_Setting gs ON gs.branch_id = inc.branch_id
									WHERE	CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec),':', '.') AS numeric(18,3)) >= CASE
															  WHEN CAST(REPLACE(gs.H_CompOff_Min_hours,':', '.') AS numeric(18,3)) = 0
															  THEN CAST(REPLACE(Isnull(Case when E.CompOff_Min_hrs = '' then '00:00' else e.CompOff_Min_hrs end ,'00:00'),':', '.') AS numeric(18,3))
															  ELSE CAST(REPLACE(gs.H_CompOff_Min_hours,':', '.') AS numeric(18,3))
															  END AND (CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec),':', '.') AS numeric(18,3)) <> 0)
											AND EXISTS(SELECT 1 FROM #EMP_HOLIDAY HO  WHERE HO.IS_CANCEL = 0 AND HO.EMP_ID=OA.EMP_ID AND HO.FOR_DATE= OA.FOR_DATE)  -- ADDED BY GADRIWALA MUSLIM 0312016
									UNION
									SELECT	Qry1.*
									FROM	(SELECT	dt.*,dbo.F_Return_Hours(Duration_in_Sec) AS Working_Hour,
													dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) AS OT_Hour,
													dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) AS Actual_Worked_Hrs,
													@P_Days_Count AS P_Days_Count,
													dbo.F_Return_Hours(0) AS Weekoff_OT_Hour,
													dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec,0)) AS Holiday_OT_Hour,
													'-' AS application_status,'HO' AS DayFlag,dbo.F_Return_Hours(DATEDIFF(SECOND,shift_start_time,shift_end_time)) AS Shift_Hours,
										CONVERT(NVARCHAR(8),In_Time,108) AS In_Time_Actual,CONVERT(NVARCHAR(8),Out_Time,108) AS Out_Time_Actual
											 FROM	#Data_Temp DT
											 WHERE	For_date NOT IN (SELECT	For_date
																	FROM	#Data_Temp OA
																	INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
																	INNER JOIN dbo.T0120_CompOff_Approval CA ON OA.Emp_Id = CA.Emp_ID AND OA.For_date = CA.Extra_Work_Date
																	WHERE	CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec),':', '.') AS numeric(18,3)) >= CAST(REPLACE(Isnull(Case when E.CompOff_Min_hrs = '' then '00:00' else e.CompOff_Min_hrs end ,'00:00'),':', '.') AS numeric(18,3)) AND 
																	(CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec),':', '.') AS numeric(18,3)) <> 0)
													UNION
													SELECT	For_date
													FROM	#Data_Temp OA
													INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
													INNER JOIN dbo.T0100_CompOff_Application CA ON OA.Emp_Id = CA.Emp_ID AND OA.For_date = CA.Extra_Work_Date
													WHERE	CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS numeric(18,3)) >= 
															CAST(REPLACE(Isnull(case when E.CompOff_Min_hrs = '' then '00:00' else E.CompOff_Min_hrs end,'00:00'),':', '.') AS numeric(18,3)) OR 
															CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec),':', '.') AS numeric(18,3)) >= 
															CAST(REPLACE(Isnull(Case when E.CompOff_Min_hrs = '' then '00:00' else e.CompOff_Min_hrs end ,'00:00'),':', '.') AS numeric(18,3))) AND 
															(CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS numeric(18,3)) <> 0 OR 
															CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec),':', '.') AS numeric(18,3)) <> 0)) Qry1
									INNER JOIN dbo.T0080_EMP_MASTER em ON Qry1.Emp_Id = em.Emp_ID
									INNER JOIN (SELECT	t1.emp_id,t1.branch_id
												FROM	T0095_Increment t1  
												INNER JOIN (SELECT emp_id,MAX(Increment_ID) AS Increment_ID	-- Ankit 12092014 for Same Date Increment
															FROM t0095_increment  
															GROUP BY emp_id)
														AS t2 ON t1.emp_id = t2.emp_id AND t1.Increment_ID = t2.Increment_ID)
											AS inc ON Qry1.Emp_ID = inc.emp_id
									INNER JOIN T0040_General_Setting gs ON gs.branch_id = inc.branch_id
									WHERE	CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec),':', '.') AS numeric(18,3)) >= CASE
															  WHEN CAST(REPLACE(gs.H_CompOff_Min_hours,':', '.') AS numeric(18,3)) = 0
															  THEN CAST(REPLACE(Isnull(Case when Em.CompOff_Min_hrs = '' then '00:00' else em.CompOff_Min_hrs end ,'00:00'),':', '.') AS numeric(18,3))
															  ELSE CAST(REPLACE(gs.H_CompOff_Min_hours,':', '.') AS numeric(18,3))
															  END AND (CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec),':', '.') AS numeric(18,3)) <> 0)
																AND EXISTS(SELECT 1 FROM #EMP_HOLIDAY HO  WHERE HO.IS_CANCEL = 0 AND HO.EMP_ID=QRY1.EMP_ID AND HO.FOR_DATE= QRY1.FOR_DATE)  -- ADDED BY GADRIWALA MUSLIM 0312016
										Union -- Added By Gadriwala Muslim For Adjust CompOff Officially  Employee Go Out . 18/08/2015
										SELECT	OA.*,
											dbo.F_Return_Hours(Duration_in_Sec)
											AS Working_Hour,
											dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(DATEDIFF(s,OA.in_Time,GPQuery.in_Time),0)) AS OT_Hour,
											dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(DATEDIFF(s,OA.in_Time,GPQuery.in_Time),0)) AS Actual_Worked_Hrs,
											@P_Days_Count AS P_Days_Count, dbo.F_Return_Hours(0) AS Weekoff_OT_Hour,
											dbo.F_Return_Hours(ISNULL(DATEDIFF(s,OA.in_Time,GPQuery.in_Time),0)) AS Holiday_OT_Hour,
											'-' AS application_status,'HO-G' AS DayFlag,dbo.F_Return_Hours(DATEDIFF(SECOND,shift_start_time,shift_end_time)) AS Shift_Hours,
										CONVERT(NVARCHAR(8),OA.In_Time,108) AS In_Time_Actual,CONVERT(NVARCHAR(8),Out_Time,108) AS Out_Time_Actual
									FROM	#Data_Temp OA
									INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
									INNER JOIN (SELECT	t1.emp_id,t1.branch_id
												FROM	T0095_Increment t1  
												INNER JOIN (SELECT emp_id, MAX(Increment_ID) AS Increment_ID	
															FROM t0095_increment where cmp_ID = @cmp_ID
															GROUP BY emp_id)
														AS t2 ON t1.emp_id = t2.emp_id AND t1.Increment_ID = t2.Increment_ID) AS inc ON OA.Emp_ID = inc.emp_id
									INNER JOIN (select GS.For_Date,Gs.Branch_ID,H_CompOff_Min_Hours from T0040_GENERAL_SETTING GS inner join
													( 
														select MAX(For_date) as For_Date,Branch_ID from T0040_General_Setting gs 
														where Cmp_ID = @Cmp_ID  and For_Date <= @To_Date group by Branch_ID
													 )Qry on Qry.Branch_ID = GS.Branch_ID and Qry.For_Date = GS.For_Date
													) Gen_Qry ON Gen_Qry.branch_id = inc.branch_id
									Inner join ( select max(GP.In_Time) as In_Time,GP.emp_id,GP.For_Date,Is_Approved,Reason_id from T0150_EMP_Gate_Pass_INOUT_RECORD GP inner join #Data_Temp OA on OA.Emp_ID = GP.emp_id and OA.For_date = GP.For_date and GP.Is_Approved = 1 
									Inner join T0040_Reason_Master RM on RM.Res_Id = GP.Reason_id and Type = 'GatePass' and Gate_Pass_Type = 'Official' group by GP.Emp_ID,GP.For_Date,GP.Is_Approved,GP.Reason_id ) GPQuery on OA.emp_id = GPQuery.emp_ID and OA.For_date = GPQuery.For_date 
								
									WHERE	CAST(REPLACE(dbo.F_Return_Hours(DATEDIFF(s,OA.in_Time,GPQuery.in_Time)),':', '.') AS numeric(18,3)) >= CASE
															  WHEN CAST(REPLACE(Gen_Qry.H_CompOff_Min_hours,':', '.') AS numeric(18,3)) = 0
															  THEN CAST(REPLACE(Isnull(Case when E.CompOff_Min_hrs = '' then '00:00' else e.CompOff_Min_hrs end ,'00:00'),':', '.') AS numeric(18,3))
															  ELSE CAST(REPLACE(Gen_Qry.H_CompOff_Min_hours,':', '.') AS numeric(18,3))
															  END AND (CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec),':', '.') AS numeric(18,3)) <> 0)
											and OA.For_date NOT IN (SELECT	For_date
																	FROM	#Data_Temp OA
																	INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
																	INNER JOIN dbo.T0120_CompOff_Approval CA ON OA.Emp_Id = CA.Emp_ID AND OA.For_date = CA.Extra_Work_Date
																	WHERE	CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec),':', '.') AS numeric(18,3)) >= CAST(REPLACE(Isnull(Case when E.CompOff_Min_hrs = '' then '00:00' else e.CompOff_Min_hrs end ,'00:00'),':', '.') AS numeric(18,3)) AND 
																	(CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec),':', '.') AS numeric(18,3)) <> 0))
													AND EXISTS(SELECT 1 FROM #EMP_HOLIDAY HO  WHERE HO.IS_CANCEL = 0 AND HO.EMP_ID=OA.EMP_ID AND HO.FOR_DATE= OA.FOR_DATE)  -- ADDED BY GADRIWALA MUSLIM 0312016
									ORDER BY OA.For_Date
									END
								ELSE IF @return_record_set = 15  -- HO & WD
									BEGIN
										-- Added Nilesh Patel on 20072018 --For Cliantha -- if Employee Working 18 Hours next absent day adjust with previouse day OT and Deduct working hours from OT.
										--IF Exists(SELECT 1 FROM T0165_ATTENDANCE_APPROVAL WHERE CMP_ID = @CMP_ID AND FOR_DATE >=@FROM_DATE AND FOR_DATE <=@TO_DATE AND ATT_STATUS = 'A')
										--	Begin
										--		UPDATE DT
										--			SET DT.DURATION_IN_SEC = (Case When DT.DURATION_IN_SEC > Q.SHIFT_SEC Then DT.DURATION_IN_SEC - Q.SHIFT_SEC Else 0 END),
										--				DT.OT_SEC = CASE WHEN DT.OT_SEC > Q.SHIFT_SEC THEN 
										--								CASE WHEN DT.Emp_OT_Min_Limit > (DT.OT_SEC - Q.SHIFT_SEC) THEN	
										--									0
										--								ELSE  (DT.OT_SEC - Q.SHIFT_SEC) END
										--							ELSE 0 END,
										--				DT.Weekoff_OT_Sec = CASE WHEN G.Tras_Week_OT = 1 AND DT.Weekoff_OT_Sec > Q.SHIFT_SEC THEN DT.Weekoff_OT_Sec - Q.SHIFT_SEC ELSE DT.Weekoff_OT_Sec END,
										--				DT.Holiday_OT_Sec = CASE WHEN G.Tras_Week_OT = 1 AND DT.Holiday_OT_Sec > Q.SHIFT_SEC THEN DT.Holiday_OT_Sec - Q.SHIFT_SEC ELSE DT.Holiday_OT_Sec END
										--		FROM #DATA_TEMP DT INNER JOIN 
										--		(
										--				SELECT EMP_ID,DATEADD(D,-1,FOR_DATE) AS FORDATE,P_DAYS,ATT_STATUS,SHIFT_SEC
										--				FROM T0165_ATTENDANCE_APPROVAL
										--				WHERE CMP_ID = @CMP_ID AND FOR_DATE >=@FROM_DATE AND FOR_DATE <=@TO_DATE AND ATT_STATUS = 'A' AND P_DAYS <> 0
										--		)Q ON DT.EMP_ID =Q.EMP_ID  AND DT.FOR_DATE = Q.FORDATE
										--		INNER JOIN #EMP_GEN_SETTINGS G ON DT.Emp_Id=G.EMP_ID
										--	End
									
										SELECT	OA.*,
											dbo.F_Return_Hours(Duration_in_Sec)
											AS Working_Hour,
											dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) AS OT_Hour,
											dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) AS Actual_Worked_Hrs,
											@P_Days_Count AS P_Days_Count, dbo.F_Return_Hours(0) AS Weekoff_OT_Hour,
											dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec,0)) AS Holiday_OT_Hour,
											CA.Approve_Status AS Application_Status,'HO' AS DayFlag,dbo.F_Return_Hours(DATEDIFF(SECOND,shift_start_time,shift_end_time)) AS Shift_Hours,
										CONVERT(NVARCHAR(8),In_Time,108) AS In_Time_Actual,CONVERT(NVARCHAR(8),Out_Time,108) AS Out_Time_Actual
									FROM	#Data_Temp OA
									INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
									INNER JOIN dbo.T0120_CompOff_Approval CA ON OA.Emp_Id = CA.Emp_ID AND OA.For_date = CA.Extra_Work_Date
									INNER JOIN (SELECT	t1.emp_id,t1.branch_id
												FROM	T0095_Increment t1  
												INNER JOIN (SELECT emp_id, MAX(Increment_ID) AS Increment_ID	-- Ankit 12092014 for Same Date Increment
															FROM t0095_increment  
															GROUP BY emp_id)
														AS t2 ON t1.emp_id = t2.emp_id AND t1.Increment_ID = t2.Increment_ID)
											AS inc ON OA.Emp_ID = inc.emp_id
									INNER JOIN T0040_General_Setting gs ON gs.branch_id = inc.branch_id
									WHERE	CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec),':', '.') AS numeric(18,3)) >= CASE
															  WHEN CAST(REPLACE(gs.H_CompOff_Min_hours,':', '.') AS numeric(18,3)) = 0
															  THEN CAST(REPLACE(Isnull(Case when E.CompOff_Min_hrs = '' then '00:00' else e.CompOff_Min_hrs end ,'00:00'),':', '.') AS numeric(18,3))
															  ELSE CAST(REPLACE(gs.H_CompOff_Min_hours,':', '.') AS numeric(18,3))
															  END AND (CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec),':', '.') AS numeric(18,3)) <> 0)
									AND EXISTS(SELECT 1 FROM #EMP_HOLIDAY HO  WHERE HO.IS_CANCEL = 0 AND HO.EMP_ID=OA.EMP_ID AND HO.FOR_DATE= OA.FOR_DATE)  -- ADDED BY GADRIWALA MUSLIM 0312016
									UNION
									SELECT	OA.*,
											dbo.F_Return_Hours(Duration_in_Sec)
											AS Working_Hour,
											dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) AS OT_Hour,
											dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) AS Actual_Worked_Hrs,
											@P_Days_Count AS P_Days_Count,dbo.F_Return_Hours(0) AS Weekoff_OT_Hour,
											dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec,0)) AS Holiday_OT_Hour,CA.Application_Status,
											'HO' AS DayFlag,dbo.F_Return_Hours(DATEDIFF(SECOND,shift_start_time,shift_end_time)) AS Shift_Hours,
										CONVERT(NVARCHAR(8),In_Time,108) AS In_Time_Actual,CONVERT(NVARCHAR(8),Out_Time,108) AS Out_Time_Actual
									FROM	#Data_Temp OA
									INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
									INNER JOIN dbo.T0100_CompOff_Application CA ON OA.Emp_Id = CA.Emp_ID AND OA.For_date = CA.Extra_Work_Date
									INNER JOIN (SELECT	t1.emp_id,t1.branch_id FROM	T0095_Increment t1  
												INNER JOIN (SELECT emp_id,MAX(Increment_ID) AS Increment_ID	-- Ankit 12092014 for Same Date Increment
															FROM t0095_increment GROUP BY emp_id)
														AS t2 ON t1.emp_id = t2.emp_id AND t1.Increment_ID = t2.Increment_ID)
											AS inc ON OA.Emp_ID = inc.emp_id
									INNER JOIN T0040_General_Setting gs ON gs.branch_id = inc.branch_id
									WHERE	CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec),':', '.') AS numeric(18,3)) >= CASE
															  WHEN CAST(REPLACE(gs.H_CompOff_Min_hours,':', '.') AS numeric(18,3)) = 0
															  THEN CAST(REPLACE(Isnull(Case when E.CompOff_Min_hrs = '' then '00:00' else e.CompOff_Min_hrs end ,'00:00'),':', '.') AS numeric(18,3))
															  ELSE CAST(REPLACE(gs.H_CompOff_Min_hours,':', '.') AS numeric(18,3))
															  END AND (CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec),':', '.') AS numeric(18,3)) <> 0)
										AND EXISTS(SELECT 1 FROM #EMP_HOLIDAY HO  WHERE HO.IS_CANCEL = 0 AND HO.EMP_ID=OA.EMP_ID AND HO.FOR_DATE= OA.FOR_DATE)  -- ADDED BY GADRIWALA MUSLIM 0312016
									UNION
									SELECT	Qry1.*
									FROM	(SELECT	dt.*,dbo.F_Return_Hours(Duration_in_Sec) AS Working_Hour,
													dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) AS OT_Hour,
													dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) AS Actual_Worked_Hrs,
													@P_Days_Count AS P_Days_Count,
													dbo.F_Return_Hours(0) AS Weekoff_OT_Hour,
													dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec,0)) AS Holiday_OT_Hour,
													'-' AS application_status,'HO' AS DayFlag,dbo.F_Return_Hours(DATEDIFF(SECOND,shift_start_time,shift_end_time)) AS Shift_Hours,
										CONVERT(NVARCHAR(8),In_Time,108) AS In_Time_Actual,CONVERT(NVARCHAR(8),Out_Time,108) AS Out_Time_Actual
											 FROM	#Data_Temp DT
											 WHERE	For_date NOT IN (SELECT	For_date
																	FROM	#Data_Temp OA
																	INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
																	INNER JOIN dbo.T0120_CompOff_Approval CA ON OA.Emp_Id = CA.Emp_ID AND OA.For_date = CA.Extra_Work_Date
																	WHERE	CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec),':', '.') AS numeric(18,3)) >= CAST(REPLACE(Isnull(Case when E.CompOff_Min_hrs = '' then '00:00' else e.CompOff_Min_hrs end ,'00:00'),':', '.') AS numeric(18,3)) AND 
																	(CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec),':', '.') AS numeric(18,3)) <> 0)
													AND EXISTS( SELECT 1 FROM #EMP_HOLIDAY HO  WHERE HO.IS_CANCEL = 0 AND HO.FOR_DATE = OA.FOR_DATE AND HO.EMP_ID = OA.EMP_ID)  -- ADDED BY GADRIWALA MUSLIM 0312016
													UNION
													SELECT	For_date
													FROM	#Data_Temp OA
													INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
													INNER JOIN dbo.T0100_CompOff_Application CA ON OA.Emp_Id = CA.Emp_ID AND OA.For_date = CA.Extra_Work_Date
													WHERE	CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS numeric(18,3)) >= 
															CAST(REPLACE(Isnull(case when E.CompOff_Min_hrs = '' then '00:00' else E.CompOff_Min_hrs end,'00:00'),':', '.') AS numeric(18,3)) OR 
															CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec),':', '.') AS numeric(18,3)) >= 
															CAST(REPLACE(Isnull(Case when E.CompOff_Min_hrs = '' then '00:00' else e.CompOff_Min_hrs end ,'00:00'),':', '.') AS numeric(18,3))) AND 
															(CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS numeric(18,3)) <> 0 OR 
															CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec),':', '.') AS numeric(18,3)) <> 0)) Qry1
									INNER JOIN dbo.T0080_EMP_MASTER em ON Qry1.Emp_Id = em.Emp_ID
									INNER JOIN (SELECT	t1.emp_id,t1.branch_id
												FROM	T0095_Increment t1  
												INNER JOIN (SELECT emp_id,MAX(Increment_ID) AS Increment_ID	-- Ankit 12092014 for Same Date Increment
															FROM t0095_increment  
															GROUP BY emp_id)
														AS t2 ON t1.emp_id = t2.emp_id AND t1.Increment_ID = t2.Increment_ID)
											AS inc ON Qry1.Emp_ID = inc.emp_id
									INNER JOIN T0040_General_Setting gs ON gs.branch_id = inc.branch_id
									WHERE	CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec),':', '.') AS numeric(18,3)) >= CASE
															  WHEN CAST(REPLACE(gs.H_CompOff_Min_hours,':', '.') AS numeric(18,3)) = 0
															  THEN CAST(REPLACE(Isnull(Case when Em.CompOff_Min_hrs = '' then '00:00' else em.CompOff_Min_hrs end ,'00:00'),':', '.') AS numeric(18,3))
															  ELSE CAST(REPLACE(gs.H_CompOff_Min_hours,':', '.') AS numeric(18,3))
															  END AND (CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec),':', '.') AS numeric(18,3)) <> 0)
												AND EXISTS(SELECT 1 FROM #EMP_HOLIDAY HO  WHERE HO.IS_CANCEL = 0 AND HO.EMP_ID=QRY1.EMP_ID AND HO.FOR_DATE= QRY1.FOR_DATE)  -- ADDED BY GADRIWALA MUSLIM 0312016
										Union -- Added By Gadriwala Muslim For Adjust CompOff Officially  Employee Go Out . 18/08/2015
										SELECT	OA.*,
											dbo.F_Return_Hours(Duration_in_Sec)
											AS Working_Hour,
											dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(DATEDIFF(s,OA.in_Time,GPQuery.in_Time),0)) AS OT_Hour,
											dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(DATEDIFF(s,OA.in_Time,GPQuery.in_Time),0)) AS Actual_Worked_Hrs,
											@P_Days_Count AS P_Days_Count, dbo.F_Return_Hours(0) AS Weekoff_OT_Hour,
											dbo.F_Return_Hours(ISNULL(DATEDIFF(s,OA.in_Time,GPQuery.in_Time),0)) AS Holiday_OT_Hour,
											'-' AS application_status,'HO-G' AS DayFlag,dbo.F_Return_Hours(DATEDIFF(SECOND,shift_start_time,shift_end_time)) AS Shift_Hours,
										CONVERT(NVARCHAR(8),OA.In_Time,108) AS In_Time_Actual,CONVERT(NVARCHAR(8),Out_Time,108) AS Out_Time_Actual
									FROM	#Data_Temp OA
									INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
									INNER JOIN (SELECT	t1.emp_id,t1.branch_id
												FROM	T0095_Increment t1  
												INNER JOIN (SELECT emp_id, MAX(Increment_ID) AS Increment_ID	
															FROM t0095_increment where cmp_ID = @cmp_ID
															GROUP BY emp_id)
														AS t2 ON t1.emp_id = t2.emp_id AND t1.Increment_ID = t2.Increment_ID)
											AS inc ON OA.Emp_ID = inc.emp_id
									INNER JOIN (select GS.For_Date,Gs.Branch_ID,H_CompOff_Min_Hours from T0040_GENERAL_SETTING GS inner join
													( 
														select MAX(For_date) as For_Date,Branch_ID from T0040_General_Setting gs 
														where Cmp_ID = @Cmp_ID  and For_Date <= @To_Date group by Branch_ID
													 )Qry on Qry.Branch_ID = GS.Branch_ID and Qry.For_Date = GS.For_Date
													) Gen_Qry ON Gen_Qry.branch_id = inc.branch_id
									Inner join ( select max(GP.In_Time) as In_Time,GP.emp_id,GP.For_Date,Is_Approved,Reason_id from T0150_EMP_Gate_Pass_INOUT_RECORD GP inner join #Data_Temp OA on OA.Emp_ID = GP.emp_id and OA.For_date = GP.For_date and GP.Is_Approved = 1 
									Inner join T0040_Reason_Master RM on RM.Res_Id = GP.Reason_id and Type = 'GatePass' and Gate_Pass_Type = 'Official' group by GP.Emp_ID,GP.For_Date,GP.Is_Approved,GP.Reason_id ) GPQuery on OA.emp_id = GPQuery.emp_ID and OA.For_date = GPQuery.For_date 
								
									WHERE	CAST(REPLACE(dbo.F_Return_Hours(DATEDIFF(s,OA.in_Time,GPQuery.in_Time)),':', '.') AS numeric(18,3)) >= CASE
															  WHEN CAST(REPLACE(Gen_Qry.H_CompOff_Min_hours,':', '.') AS numeric(18,3)) = 0
															  THEN CAST(REPLACE(Isnull(Case when E.CompOff_Min_hrs = '' then '00:00' else e.CompOff_Min_hrs end ,'00:00'),':', '.') AS numeric(18,3))
															  ELSE CAST(REPLACE(Gen_Qry.H_CompOff_Min_hours,':', '.') AS numeric(18,3))
															  END AND (CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec),':', '.') AS numeric(18,3)) <> 0)
											and OA.For_date NOT IN (SELECT	For_date
																	FROM	#Data_Temp OA
																	INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
																	INNER JOIN dbo.T0120_CompOff_Approval CA ON OA.Emp_Id = CA.Emp_ID AND OA.For_date = CA.Extra_Work_Date
																	WHERE	CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec),':', '.') AS numeric(18,3)) >= CAST(REPLACE(Isnull(Case when E.CompOff_Min_hrs = '' then '00:00' else e.CompOff_Min_hrs end ,'00:00'),':', '.') AS numeric(18,3)) AND 
																	(CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec),':', '.') AS numeric(18,3)) <> 0))
													AND EXISTS(SELECT 1 FROM #EMP_HOLIDAY HO  WHERE HO.IS_CANCEL = 0 AND HO.EMP_ID=OA.EMP_ID AND HO.FOR_DATE= OA.FOR_DATE)  -- ADDED BY GADRIWALA MUSLIM 0312016
									union
									
								SELECT	OA.*,
										dbo.F_Return_Hours(Duration_in_Sec - OT_SEC) AS Working_Hour,
										CASE WHEN DATEDIFF(SECOND,In_Time,shift_Start_time)>=3600 
										OR DATEDIFF(SECOND,Shift_End_Time,Out_Time)>=3600 THEN 
										dbo.F_Return_Hours(ISNULL(OT_SEC, 0)) 
										ELSE dbo.F_Return_Hours( 0) END 
										AS OT_Hour,
										dbo.F_Return_Hours(Duration_in_Sec/* + ISNULL(OT_Sec,0)*/) AS Actual_Worked_Hrs,
										@P_Days_Count AS P_Days_Count,
										dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0)) AS Weekoff_OT_Hour,
										dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec,0)) AS Holiday_OT_Hour,
										CA.Approve_Status AS Application_Status,
										'WD' AS DayFlag,dbo.F_Return_Hours(DATEDIFF(SECOND,shift_start_time,shift_end_time)) AS Shift_Hours,
										CONVERT(NVARCHAR(8),In_Time,108) AS In_Time_Actual,CONVERT(NVARCHAR(8),Out_Time,108) AS Out_Time_Actual
								FROM	#Data_Temp OA
								INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
								INNER JOIN dbo.T0120_CompOff_Approval CA ON OA.Emp_Id = CA.Emp_ID AND OA.For_date = CA.Extra_Work_Date
								INNER JOIN (SELECT	t1.emp_id, branch_id
											FROM	T0095_Increment t1  
											INNER JOIN (SELECT emp_id, MAX(Increment_ID) AS Increment_ID	-- Ankit 12092014 for Same Date Increment
														FROM  t0095_increment  
														GROUP BY emp_id) AS t2 ON t1.emp_id = t2.emp_id AND t1.Increment_ID = t2.Increment_ID)
										AS inc ON oa.emp_id = inc.emp_id
								INNER JOIN T0040_General_Setting gs ON gs.branch_id = inc.branch_id
								WHERE	CAST(REPLACE(dbo.F_Return_Hours(OT_SEC),':', '.') AS numeric(18,3)) >= CASE
															  WHEN CAST(REPLACE(gs.CompOff_Min_hours,':', '.') AS numeric(18,3)) = 0
															  THEN CAST(REPLACE(Isnull(Case when E.CompOff_Min_hrs = '' then '00:00' else e.CompOff_Min_hrs end ,'00:00'),':', '.') AS numeric(18,3))
															  ELSE CAST(REPLACE(gs.CompOff_Min_hours,':', '.') AS numeric(18,3))
															  END AND CAST(REPLACE(dbo.F_Return_Hours(OT_SEC),':', '.') AS numeric(18,3)) <> 0
								UNION
								SELECT	OA.*,
										dbo.F_Return_Hours(Duration_in_Sec - OT_SEC)
										AS Working_Hour,
										CASE WHEN DATEDIFF(SECOND,In_Time,shift_Start_time)>=3600 
										OR DATEDIFF(SECOND,Shift_End_Time,Out_Time)>=3600 THEN 
										dbo.F_Return_Hours(ISNULL(OT_SEC, 0)) 
										ELSE dbo.F_Return_Hours( 0) END 
										AS OT_Hour,
										dbo.F_Return_Hours(Duration_in_Sec /*+ ISNULL(OT_Sec,0)*/) AS Actual_Worked_Hrs,
										@P_Days_Count AS P_Days_Count,
										dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,
															  0)) AS Weekoff_OT_Hour,
										dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec,
															  0)) AS Holiday_OT_Hour,
										CA.Application_Status, 'WD' AS DayFlag,dbo.F_Return_Hours(DATEDIFF(SECOND,shift_start_time,shift_end_time)) AS Shift_Hours,
										CONVERT(NVARCHAR(8),In_Time,108) AS In_Time_Actual,CONVERT(NVARCHAR(8),Out_Time,108) AS Out_Time_Actual
								FROM	#Data_Temp OA
								INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
								INNER JOIN dbo.T0100_CompOff_Application CA ON OA.Emp_Id = CA.Emp_ID AND OA.For_date = CA.Extra_Work_Date
								INNER JOIN (SELECT	t1.emp_id, branch_id
											FROM	T0095_Increment t1  
											INNER JOIN (SELECT emp_id,
															  MAX(Increment_ID)	-- Ankit 12092014 for Same Date Increment
															  AS Increment_ID
														FROM  t0095_increment  
														GROUP BY emp_id) AS t2 ON t1.emp_id = t2.emp_id AND t1.Increment_ID = t2.Increment_ID)
										AS inc ON oa.emp_id = inc.emp_id
								INNER JOIN T0040_General_Setting gs ON gs.branch_id = inc.branch_id
								WHERE	CAST(REPLACE(dbo.F_Return_Hours(OT_SEC),':', '.') AS numeric(18,3)) >= CASE
															  WHEN CAST(REPLACE(gs.CompOff_Min_hours,':', '.') AS numeric(18,3)) = 0
															  THEN CAST(REPLACE(Isnull(Case when E.CompOff_Min_hrs = '' then '00:00' else e.CompOff_Min_hrs end ,'00:00'),':', '.') AS numeric(18,3))
															  ELSE CAST(REPLACE(gs.CompOff_Min_hours,':', '.') AS numeric(18,3))
															  END AND CAST(REPLACE(dbo.F_Return_Hours(OT_SEC),':', '.') AS numeric(18,3)) <> 0
								UNION
								SELECT	Qry1.*
								FROM	(SELECT	dt.*,
												dbo.F_Return_Hours(Duration_in_Sec - OT_SEC)
												AS Working_Hour,
												CASE WHEN DATEDIFF(SECOND,In_Time,shift_Start_time)>=3600 
												OR DATEDIFF(SECOND,Shift_End_Time,Out_Time)>=3600 THEN 
												dbo.F_Return_Hours(ISNULL(OT_SEC, 0)) 
												ELSE dbo.F_Return_Hours( 0) END 
												AS OT_Hour,
												dbo.F_Return_Hours(Duration_in_Sec/* + ISNULL(OT_Sec,0)*/) AS Actual_Worked_Hrs,
												@P_Days_Count AS P_Days_Count,
												dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0)) AS Weekoff_OT_Hour,
												dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec,0)) AS Holiday_OT_Hour,
												'-' AS application_status,
												'WD' AS DayFlag,dbo.F_Return_Hours(DATEDIFF(SECOND,shift_start_time,shift_end_time)) AS Shift_Hours,
										CONVERT(NVARCHAR(8),In_Time,108) AS In_Time_Actual,CONVERT(NVARCHAR(8),Out_Time,108) AS Out_Time_Actual
										 FROM	#Data_Temp DT
										 WHERE	For_date NOT IN (
												SELECT	OA.For_Date
												FROM	[#Data_Temp] AS OA
												INNER JOIN T0080_EMP_MASTER AS E ON OA.Emp_ID = E.Emp_ID
												INNER JOIN T0120_CompOff_Approval AS CA ON OA.Emp_Id = CA.Emp_ID AND OA.For_date = CA.Extra_Work_Date
												INNER JOIN (SELECT t1.Emp_ID, t1.Branch_ID
															FROM T0095_INCREMENT t1  
															INNER JOIN 
															(SELECT Emp_ID, MAX(Increment_ID) AS Increment_ID	-- Ankit 12092014 for Same Date Increment
															  FROM T0095_INCREMENT  
															  GROUP BY Emp_ID)
															  AS t2 ON t1.emp_id = t2.Emp_ID AND t1.Increment_ID = t2.Increment_ID)
														AS inc ON OA.Emp_ID = inc.Emp_ID
												INNER JOIN T0040_GENERAL_SETTING AS gs ON gs.Branch_ID = inc.Branch_ID
												WHERE	(CAST(REPLACE(dbo.F_Return_Hours(OT_SEC),':', '.') AS numeric(18,3)) >= CASE
															  WHEN CAST(REPLACE(gs.CompOff_Min_hours,':', '.') AS numeric(18,3)) = 0
															  THEN CAST(REPLACE(Isnull(Case when E.CompOff_Min_hrs = '' then '00:00' else e.CompOff_Min_hrs end ,'00:00'),':', '.') AS numeric(18,3))
															  ELSE CAST(REPLACE(gs.CompOff_Min_hours,':', '.') AS numeric(18,3))
															  END) AND (CAST(REPLACE(dbo.F_Return_Hours(OT_SEC),':', '.') AS numeric(18,3)) <> 0)
												UNION
												SELECT	OA.For_Date
												FROM	[#Data_Temp] AS OA
												INNER JOIN T0080_EMP_MASTER AS E ON OA.Emp_ID = E.Emp_ID
												INNER JOIN T0100_CompOff_Application AS CA ON OA.Emp_Id = CA.Emp_ID AND OA.For_date = CA.Extra_Work_Date
												INNER JOIN (SELECT t1.Emp_ID, t1.Branch_ID 
															FROM T0095_INCREMENT t1  
															INNER JOIN (SELECT
															  Emp_ID,
															  MAX(Increment_ID)	-- Ankit 12092014 for Same Date Increment
															  AS Increment_ID
															  FROM
															  T0095_INCREMENT  
															  GROUP BY Emp_ID)
															  AS t2 ON t1.emp_id = t2.Emp_ID AND t1.Increment_ID = t2.Increment_ID)
														AS inc ON OA.Emp_ID = inc.Emp_ID
												INNER JOIN T0040_GENERAL_SETTING AS gs  ON gs.Branch_ID = inc.Branch_ID
												WHERE	(CAST(REPLACE(dbo.F_Return_Hours(OT_SEC),':', '.') AS numeric(18,3)) >= CASE
															  WHEN CAST(REPLACE(gs.CompOff_Min_hours,':', '.') AS numeric(18,3)) = 0
															  THEN CAST(REPLACE(E.CompOff_Min_hrs,':', '.') AS numeric(18,3))
															  ELSE CAST(REPLACE(gs.CompOff_Min_hours,':', '.') AS numeric(18,3))
															  END) AND (CAST(REPLACE(dbo.F_Return_Hours(OT_SEC),':', '.') AS numeric(18,3)) <> 0))) Qry1
								INNER JOIN T0080_EMP_MASTER em ON Qry1.Emp_Id = em.Emp_ID
								INNER JOIN (SELECT	t1.emp_id, t1.branch_id
											FROM	T0095_Increment t1  
											INNER JOIN (SELECT emp_id,MAX(Increment_ID) AS Increment_ID	-- Ankit 12092014 for Same Date Increment
														FROM  t0095_increment  
														GROUP BY emp_id) AS t2 ON t1.emp_id = t2.emp_id AND t1.Increment_ID = t2.Increment_ID)
										AS inc ON Qry1.Emp_ID = inc.emp_id
								INNER JOIN T0040_General_Setting gs ON gs.branch_id = inc.branch_id
								where CAST(REPLACE(dbo.F_Return_Hours(OT_SEC),':', '.') AS numeric(18,3)) >= CASE 
															  WHEN 
															  CAST(REPLACE(isnull(															 
															  case when 
															   gs.CompOff_Min_hours ='' then '00:00' else gs.CompOff_Min_hours end															  
															  ,'00:00'),':', '.') AS numeric(18,3)) = 0
															  THEN CAST(REPLACE(isnull(
															  
															 case when  Em.CompOff_Min_hrs='' then '00:00' else Em.CompOff_Min_hrs end
															  
															  ,'00:00'),':', '.') AS numeric(18,3))
															  ELSE CAST(REPLACE(isnull(															  
															   case when gs.CompOff_Min_hours='' then '00:00' else gs.CompOff_Min_hours end															  
															  ,'00:00'),':', '.') AS numeric(18,3))
														  END AND 
														  
														  
														  CAST(REPLACE(dbo.F_Return_Hours(OT_SEC),':', '.') AS numeric(18,3)) <> 0
								      
									ORDER BY OA.For_Date
									END
								ELSE IF @return_record_set = 16  -- WO & WD
									BEGIN
										-- Added Nilesh Patel on 20072018 --For Cliantha -- if Employee Working 18 Hours next absent day adjust with previouse day OT and Deduct working hours from OT.
										--IF Exists(SELECT 1 FROM T0165_ATTENDANCE_APPROVAL WHERE CMP_ID = @CMP_ID AND FOR_DATE >=@FROM_DATE AND FOR_DATE <=@TO_DATE AND ATT_STATUS = 'A')
										--	Begin
										--		UPDATE DT
										--			SET DT.DURATION_IN_SEC =(Case When DT.DURATION_IN_SEC > Q.SHIFT_SEC Then DT.DURATION_IN_SEC - Q.SHIFT_SEC Else 0 END),
										--				DT.OT_SEC = CASE WHEN DT.OT_SEC > Q.SHIFT_SEC THEN 
										--								CASE WHEN DT.Emp_OT_Min_Limit > (DT.OT_SEC - Q.SHIFT_SEC) THEN	
										--									0
										--								ELSE  (DT.OT_SEC - Q.SHIFT_SEC) END
										--							ELSE 0 END,
										--				DT.Weekoff_OT_Sec = CASE WHEN G.Tras_Week_OT = 1 AND DT.Weekoff_OT_Sec > Q.SHIFT_SEC THEN DT.Weekoff_OT_Sec - Q.SHIFT_SEC ELSE DT.Weekoff_OT_Sec END,
										--				DT.Holiday_OT_Sec = CASE WHEN G.Tras_Week_OT = 1 AND DT.Holiday_OT_Sec > Q.SHIFT_SEC THEN DT.Holiday_OT_Sec - Q.SHIFT_SEC ELSE DT.Holiday_OT_Sec END
										--		FROM #DATA_TEMP DT INNER JOIN 
										--		(
										--				SELECT EMP_ID,DATEADD(D,-1,FOR_DATE) AS FORDATE,P_DAYS,ATT_STATUS,SHIFT_SEC
										--				FROM T0165_ATTENDANCE_APPROVAL
										--				WHERE CMP_ID = @CMP_ID AND FOR_DATE >=@FROM_DATE AND FOR_DATE <=@TO_DATE AND ATT_STATUS = 'A' AND P_DAYS <> 0
										--		)Q ON DT.EMP_ID =Q.EMP_ID  AND DT.FOR_DATE = Q.FORDATE
										--		INNER JOIN #EMP_GEN_SETTINGS G ON DT.Emp_Id=G.EMP_ID	
										--	End
										
										SELECT	OA.*,
											dbo.F_Return_Hours(Duration_in_Sec)
											AS Working_Hour,
											dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) AS OT_Hour,
											dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) AS Actual_Worked_Hrs,
											@P_Days_Count AS P_Days_Count,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0)) AS Weekoff_OT_Hour,
											dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec,0)) AS Holiday_OT_Hour,
											CA.Approve_Status AS Application_Status,'WO' AS DayFlag,dbo.F_Return_Hours(DATEDIFF(SECOND,shift_start_time,shift_end_time)) AS Shift_Hours,
										CONVERT(NVARCHAR(8),In_Time,108) AS In_Time_Actual,CONVERT(NVARCHAR(8),Out_Time,108) AS Out_Time_Actual
										FROM	#Data_Temp OA
										INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
										INNER JOIN dbo.T0120_CompOff_Approval CA ON OA.Emp_Id = CA.Emp_ID AND OA.For_date = CA.Extra_Work_Date
										INNER JOIN (SELECT	t1.emp_id,t1.branch_id
													FROM	T0095_Increment t1  
													INNER JOIN (SELECT emp_id,MAX(Increment_ID)AS Increment_ID	-- Ankit 12092014 for Same Date Increment
															  FROM t0095_increment GROUP BY emp_id)
															AS t2 ON t1.emp_id = t2.emp_id AND t1.Increment_ID = t2.Increment_ID)
												AS inc ON OA.Emp_ID = inc.emp_id
										INNER JOIN T0040_General_Setting gs  ON gs.branch_id = inc.branch_id
										WHERE	CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS numeric(18,3)) >= CASE
															  WHEN CAST(REPLACE(gs.W_CompOff_Min_hours,':', '.') AS numeric(18,3)) = 0
															  THEN CAST(REPLACE(Isnull(Case when E.CompOff_Min_hrs = '' then '00:00' else e.CompOff_Min_hrs end ,'00:00'),':', '.') AS numeric(18,3))
															  ELSE CAST(REPLACE(gs.W_CompOff_Min_hours,':', '.') AS numeric(18,3))
															  END 
												AND (CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS numeric(18,3)) <> 0)
												  AND EXISTS(SELECT 1 FROM #EMP_WEEKOFF WK  WHERE WK.IS_CANCEL = 0 AND WK.EMP_ID=OA.EMP_ID AND WK.FOR_DATE= OA.FOR_DATE)  -- Added by Gadriwala Muslim 0312016
										UNION
										SELECT	OA.*,
												dbo.F_Return_Hours(Duration_in_Sec)
												AS Working_Hour,
												dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) AS OT_Hour,
												dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) AS Actual_Worked_Hrs,
												@P_Days_Count AS P_Days_Count,
												dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0)) AS Weekoff_OT_Hour,
												dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec,0)) AS Holiday_OT_Hour,
												CA.Application_Status,'WO' AS DayFlag,dbo.F_Return_Hours(DATEDIFF(SECOND,shift_start_time,shift_end_time)) AS Shift_Hours,
										CONVERT(NVARCHAR(8),In_Time,108) AS In_Time_Actual,CONVERT(NVARCHAR(8),Out_Time,108) AS Out_Time_Actual
										FROM	#Data_Temp OA
										INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
										INNER JOIN dbo.T0100_CompOff_Application CA ON OA.Emp_Id = CA.Emp_ID AND OA.For_date = CA.Extra_Work_Date
										INNER JOIN (SELECT	t1.emp_id,t1.branch_id FROM	T0095_Increment t1  
													INNER JOIN (SELECT emp_id,MAX(Increment_ID) AS Increment_ID	-- Ankit 12092014 for Same Date Increment
															  FROM t0095_increment GROUP BY emp_id)
															AS t2 ON t1.emp_id = t2.emp_id AND t1.Increment_ID = t2.Increment_ID)
												AS inc ON OA.Emp_ID = inc.emp_id
										INNER JOIN T0040_General_Setting gs  ON gs.branch_id = inc.branch_id
										WHERE	CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS numeric(18,3)) >= CASE
															  WHEN CAST(REPLACE(gs.W_CompOff_Min_hours,':', '.') AS numeric(18,3)) = 0
															  THEN CAST(REPLACE(Isnull(Case when E.CompOff_Min_hrs = '' then '00:00' else e.CompOff_Min_hrs end ,'00:00'),':', '.') AS numeric(18,3))
															  ELSE CAST(REPLACE(gs.W_CompOff_Min_hours,':', '.') AS numeric(18,3))
															  END 
 								AND (CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS numeric(18,3)) <> 0)
      							  AND EXISTS(SELECT 1 FROM #EMP_WEEKOFF WK  WHERE WK.IS_CANCEL = 0 AND WK.EMP_ID=OA.EMP_ID AND WK.FOR_DATE= OA.FOR_DATE)  -- Added by Gadriwala Muslim 0312016
										UNION
										SELECT	Qry1.*
										FROM	(SELECT	dt.*,
														dbo.F_Return_Hours(Duration_in_Sec)
														AS Working_Hour,
														dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) AS OT_Hour,
														dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) AS Actual_Worked_Hrs,
														@P_Days_Count AS P_Days_Count,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0)) AS Weekoff_OT_Hour,
														dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec,0)) AS Holiday_OT_Hour,'-' AS application_status,
														'WO' AS DayFlag,dbo.F_Return_Hours(DATEDIFF(SECOND,shift_start_time,shift_end_time)) AS Shift_Hours,
														CONVERT(NVARCHAR(8),In_Time,108) AS In_Time_Actual,CONVERT(NVARCHAR(8),Out_Time,108) AS Out_Time_Actual
												 FROM	#Data_Temp DT
												 WHERE	For_date NOT IN (
														SELECT For_date
														FROM  #Data_Temp OA
														INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
														INNER JOIN dbo.T0120_CompOff_Approval CA ON OA.Emp_Id = CA.Emp_ID AND OA.For_date = CA.Extra_Work_Date
														WHERE CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS numeric(18,3)) >= 
																CAST(REPLACE(Isnull(Case when E.CompOff_Min_hrs = '' then '00:00' else e.CompOff_Min_hrs end ,'00:00'),':', '.') AS numeric(18,3)) 
															  AND (CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS numeric(18,3)) <> 0) 
														UNION
														SELECT For_date
														FROM  #Data_Temp OA
														INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
														INNER JOIN dbo.T0100_CompOff_Application CA ON OA.Emp_Id = CA.Emp_ID AND OA.For_date = CA.Extra_Work_Date
														WHERE CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS numeric(18,3)) >= 
																CAST(REPLACE(Isnull(Case when E.CompOff_Min_hrs = '' then '00:00' else e.CompOff_Min_hrs end,'00:00'),':', '.') AS numeric(18,3))) 
																AND (CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS numeric(18,3)) <> 0)) Qry1
										INNER JOIN dbo.T0080_EMP_MASTER em ON Qry1.Emp_Id = em.Emp_ID
										INNER JOIN (SELECT	t1.emp_id,t1.branch_id FROM	T0095_Increment t1  
													INNER JOIN (SELECT emp_id,MAX(Increment_ID) AS Increment_ID	-- Ankit 12092014 for Same Date Increment
															  FROM t0095_increment GROUP BY emp_id)
															AS t2 ON t1.emp_id = t2.emp_id AND t1.Increment_ID = t2.Increment_ID)
												AS inc ON Qry1.Emp_ID = inc.emp_id
										INNER JOIN T0040_General_Setting gs ON gs.branch_id = inc.branch_id
										WHERE	CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS numeric(18,3)) >= CASE
															  WHEN CAST(REPLACE(gs.W_CompOff_Min_hours,':', '.') AS numeric(18,3)) = 0
															  THEN CAST(REPLACE(Isnull(Case when Em.CompOff_Min_hrs = '' then '00:00' else em.CompOff_Min_hrs end,'00:00'),':', '.') AS numeric(18,3))
															  ELSE CAST(REPLACE(gs.W_CompOff_Min_hours,':', '.') AS numeric(18,3))
															  END
												AND (CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS numeric(18,3)) <> 0)
											  AND EXISTS(SELECT 1 FROM #EMP_WEEKOFF WK  WHERE WK.IS_CANCEL = 0 AND WK.EMP_ID=qry1.EMP_ID AND WK.FOR_DATE= qry1.FOR_DATE)  -- Added by Gadriwala Muslim 0312016
									union	-- Added By Gadriwala Muslim For Adjust CompOff Officially  Employee Go Out . 04/09/2015
											SELECT	OA.*,
												dbo.F_Return_Hours(DATEDIFF(s,OA.in_Time,GPQuery.in_Time))
												AS Working_Hour,
												dbo.F_Return_Hours(DATEDIFF(s,OA.in_Time,GPQuery.in_Time) + ISNULL(Holiday_OT_Sec,0)) AS OT_Hour,
												dbo.F_Return_Hours(DATEDIFF(s,OA.in_Time,GPQuery.in_Time) + ISNULL(Holiday_OT_Sec,0)) AS Actual_Worked_Hrs,
												@P_Days_Count AS P_Days_Count,dbo.F_Return_Hours(ISNULL(DATEDIFF(s,OA.in_Time,GPQuery.in_Time),0)) AS Weekoff_OT_Hour,
												dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec,0)) AS Holiday_OT_Hour,
												'-' AS application_status,'WO-G' AS DayFlag,dbo.F_Return_Hours(DATEDIFF(SECOND,shift_start_time,OA.shift_end_time)) AS Shift_Hours,
										CONVERT(NVARCHAR(8),OA.In_Time,108) AS In_Time_Actual,CONVERT(NVARCHAR(8),GPQuery.IN_Time,108) AS Out_Time_Actual
										FROM	#Data_Temp OA
										INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
										INNER JOIN (SELECT	t1.emp_id,t1.branch_id
													FROM	T0095_Increment t1  
													INNER JOIN (SELECT emp_id,MAX(Increment_ID)AS Increment_ID
															  FROM t0095_increment where cmp_ID = @cmp_ID GROUP BY emp_id)
															AS t2 ON t1.emp_id = t2.emp_id AND t1.Increment_ID = t2.Increment_ID)
												AS inc ON OA.Emp_ID = inc.emp_id
										INNER JOIN (select GS.For_Date,Gs.Branch_ID,W_CompOff_Min_hours from T0040_GENERAL_SETTING GS inner join
													( 
														select MAX(For_date) as For_Date,Branch_ID from T0040_General_Setting gs 
														where Cmp_ID = @Cmp_ID  and For_Date <= @To_Date group by Branch_ID
													 )Qry on Qry.Branch_ID = GS.Branch_ID and Qry.For_Date = GS.For_Date
													) Gen_Qry ON Gen_Qry.branch_id = inc.branch_id
										Inner join ( select max(GP.In_Time) as In_Time,GP.emp_id,GP.For_Date,Is_Approved,Reason_id from T0150_EMP_Gate_Pass_INOUT_RECORD GP inner join #Data_Temp OA on OA.Emp_ID = GP.emp_id and OA.For_date = GP.For_date and GP.Is_Approved = 1
										Inner join T0040_Reason_Master RM on RM.Res_Id = GP.Reason_id and Type = 'GatePass' and Gate_Pass_Type = 'Official' group by GP.Emp_ID,GP.For_Date,GP.Is_Approved,GP.Reason_id ) GPQuery on OA.emp_id = GPQuery.emp_ID and OA.For_date = GPQuery.For_date 
										where
										CAST(REPLACE(dbo.F_Return_Hours(DATEDIFF(s,OA.in_Time,GPQuery.in_Time)),':', '.') AS numeric(18,3)) >= CASE
															  WHEN CAST(REPLACE(Gen_Qry.W_CompOff_Min_hours,':', '.') AS numeric(18,3)) = 0
															  THEN CAST(REPLACE(Isnull(Case when E.CompOff_Min_hrs = '' then '00:00' else e.CompOff_Min_hrs end,'00:00'),':', '.') AS numeric(18,3))
															  ELSE CAST(REPLACE(Gen_Qry.W_CompOff_Min_hours,':', '.') AS numeric(18,3))
															  END
												AND (CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS numeric(18,3)) <> 0) and 
												OA.For_date NOT IN (
														SELECT For_date
														FROM  #Data_Temp OA
														INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
														INNER JOIN dbo.T0120_CompOff_Approval CA ON OA.Emp_Id = CA.Emp_ID AND OA.For_date = CA.Extra_Work_Date
														WHERE CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS numeric(18,3)) >= 
																CAST(REPLACE(Isnull(Case when E.CompOff_Min_hrs = '' then '00:00' else e.CompOff_Min_hrs end ,'00:00'),':', '.') AS numeric(18,3)) 
															  AND (CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS numeric(18,3)) <> 0) )
														 AND EXISTS(SELECT 1 FROM #EMP_WEEKOFF WK  WHERE WK.IS_CANCEL = 0 AND WK.EMP_ID=OA.EMP_ID AND WK.FOR_DATE= OA.FOR_DATE)  -- Added by Gadriwala Muslim 0312016
										union
										
								SELECT	OA.*,
										dbo.F_Return_Hours(Duration_in_Sec - OT_SEC) AS Working_Hour,
										CASE WHEN DATEDIFF(SECOND,In_Time,shift_Start_time)>=3600 
										OR DATEDIFF(SECOND,Shift_End_Time,Out_Time)>=3600 THEN 
										dbo.F_Return_Hours(ISNULL(OT_SEC, 0)) 
										ELSE dbo.F_Return_Hours( 0) END 
										AS OT_Hour,
										dbo.F_Return_Hours(Duration_in_Sec/* + ISNULL(OT_Sec,0)*/) AS Actual_Worked_Hrs,
										@P_Days_Count AS P_Days_Count,
										dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0)) AS Weekoff_OT_Hour,
										dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec,0)) AS Holiday_OT_Hour,
										CA.Approve_Status AS Application_Status,
										'WD' AS DayFlag,dbo.F_Return_Hours(DATEDIFF(SECOND,shift_start_time,shift_end_time)) AS Shift_Hours,
										CONVERT(NVARCHAR(8),In_Time,108) AS In_Time_Actual,CONVERT(NVARCHAR(8),Out_Time,108) AS Out_Time_Actual
								FROM	#Data_Temp OA
								INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
								INNER JOIN dbo.T0120_CompOff_Approval CA ON OA.Emp_Id = CA.Emp_ID AND OA.For_date = CA.Extra_Work_Date
								INNER JOIN (SELECT	t1.emp_id, branch_id
											FROM	T0095_Increment t1  
											INNER JOIN (SELECT emp_id, MAX(Increment_ID) AS Increment_ID	-- Ankit 12092014 for Same Date Increment
														FROM  t0095_increment  
														GROUP BY emp_id) AS t2 ON t1.emp_id = t2.emp_id AND t1.Increment_ID = t2.Increment_ID)
										AS inc ON oa.emp_id = inc.emp_id
								INNER JOIN T0040_General_Setting gs ON gs.branch_id = inc.branch_id
								WHERE	CAST(REPLACE(dbo.F_Return_Hours(OT_SEC),':', '.') AS numeric(18,3)) >= CASE
															  WHEN CAST(REPLACE(gs.CompOff_Min_hours,':', '.') AS numeric(18,3)) = 0
															  THEN CAST(REPLACE(Isnull(Case when E.CompOff_Min_hrs = '' then '00:00' else e.CompOff_Min_hrs end ,'00:00'),':', '.') AS numeric(18,3))
															  ELSE CAST(REPLACE(gs.CompOff_Min_hours,':', '.') AS numeric(18,3))
															  END AND CAST(REPLACE(dbo.F_Return_Hours(OT_SEC),':', '.') AS numeric(18,3)) <> 0
								UNION
								SELECT	OA.*,
										dbo.F_Return_Hours(Duration_in_Sec - OT_SEC)
										AS Working_Hour,
										CASE WHEN DATEDIFF(SECOND,In_Time,shift_Start_time)>=3600 
										OR DATEDIFF(SECOND,Shift_End_Time,Out_Time)>=3600 THEN 
										dbo.F_Return_Hours(ISNULL(OT_SEC, 0)) 
										ELSE dbo.F_Return_Hours( 0) END 
										AS OT_Hour,
										dbo.F_Return_Hours(Duration_in_Sec /*+ ISNULL(OT_Sec,0)*/) AS Actual_Worked_Hrs,
										@P_Days_Count AS P_Days_Count,
										dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,
															  0)) AS Weekoff_OT_Hour,
										dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec,
															  0)) AS Holiday_OT_Hour,
										CA.Application_Status, 'WD' AS DayFlag,dbo.F_Return_Hours(DATEDIFF(SECOND,shift_start_time,shift_end_time)) AS Shift_Hours,
										CONVERT(NVARCHAR(8),In_Time,108) AS In_Time_Actual,CONVERT(NVARCHAR(8),Out_Time,108) AS Out_Time_Actual
								FROM	#Data_Temp OA
								INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
								INNER JOIN dbo.T0100_CompOff_Application CA ON OA.Emp_Id = CA.Emp_ID AND OA.For_date = CA.Extra_Work_Date
								INNER JOIN (SELECT	t1.emp_id, branch_id
											FROM	T0095_Increment t1  
											INNER JOIN (SELECT emp_id,
															  MAX(Increment_ID)	-- Ankit 12092014 for Same Date Increment
															  AS Increment_ID
														FROM  t0095_increment  
														GROUP BY emp_id) AS t2 ON t1.emp_id = t2.emp_id AND t1.Increment_ID = t2.Increment_ID)
										AS inc ON oa.emp_id = inc.emp_id
								INNER JOIN T0040_General_Setting gs ON gs.branch_id = inc.branch_id
								WHERE	CAST(REPLACE(dbo.F_Return_Hours(OT_SEC),':', '.') AS numeric(18,3)) >= CASE
															  WHEN CAST(REPLACE(gs.CompOff_Min_hours,':', '.') AS numeric(18,3)) = 0
															  THEN CAST(REPLACE(Isnull(Case when E.CompOff_Min_hrs = '' then '00:00' else e.CompOff_Min_hrs end ,'00:00'),':', '.') AS numeric(18,3))
															  ELSE CAST(REPLACE(gs.CompOff_Min_hours,':', '.') AS numeric(18,3))
															  END AND CAST(REPLACE(dbo.F_Return_Hours(OT_SEC),':', '.') AS numeric(18,3)) <> 0
								UNION
								SELECT	Qry1.*
								FROM	(SELECT	dt.*,
												dbo.F_Return_Hours(Duration_in_Sec - OT_SEC)
												AS Working_Hour,
												CASE WHEN DATEDIFF(SECOND,In_Time,shift_Start_time)>=3600 
												OR DATEDIFF(SECOND,Shift_End_Time,Out_Time)>=3600 THEN 
												dbo.F_Return_Hours(ISNULL(OT_SEC, 0)) 
												ELSE dbo.F_Return_Hours( 0) END 
												AS OT_Hour,
												dbo.F_Return_Hours(Duration_in_Sec/* + ISNULL(OT_Sec,0)*/) AS Actual_Worked_Hrs,
												@P_Days_Count AS P_Days_Count,
												dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0)) AS Weekoff_OT_Hour,
												dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec,0)) AS Holiday_OT_Hour,
												'-' AS application_status,
												'WD' AS DayFlag,dbo.F_Return_Hours(DATEDIFF(SECOND,shift_start_time,shift_end_time)) AS Shift_Hours,
										CONVERT(NVARCHAR(8),In_Time,108) AS In_Time_Actual,CONVERT(NVARCHAR(8),Out_Time,108) AS Out_Time_Actual
										 FROM	#Data_Temp DT
										 WHERE	For_date NOT IN (
												SELECT	OA.For_Date
												FROM	[#Data_Temp] AS OA
												INNER JOIN T0080_EMP_MASTER AS E ON OA.Emp_ID = E.Emp_ID
												INNER JOIN T0120_CompOff_Approval AS CA ON OA.Emp_Id = CA.Emp_ID AND OA.For_date = CA.Extra_Work_Date
												INNER JOIN (SELECT t1.Emp_ID, t1.Branch_ID
															FROM T0095_INCREMENT t1  
															INNER JOIN 
															(SELECT Emp_ID, MAX(Increment_ID) AS Increment_ID	-- Ankit 12092014 for Same Date Increment
															  FROM T0095_INCREMENT  
															  GROUP BY Emp_ID)
															  AS t2 ON t1.emp_id = t2.Emp_ID AND t1.Increment_ID = t2.Increment_ID)
														AS inc ON OA.Emp_ID = inc.Emp_ID
												INNER JOIN T0040_GENERAL_SETTING AS gs ON gs.Branch_ID = inc.Branch_ID
												WHERE	(CAST(REPLACE(dbo.F_Return_Hours(OT_SEC),':', '.') AS numeric(18,3)) >= CASE
															  WHEN CAST(REPLACE(gs.CompOff_Min_hours,':', '.') AS numeric(18,3)) = 0
															  THEN CAST(REPLACE(Isnull(Case when E.CompOff_Min_hrs = '' then '00:00' else e.CompOff_Min_hrs end ,'00:00'),':', '.') AS numeric(18,3))
															  ELSE CAST(REPLACE(gs.CompOff_Min_hours,':', '.') AS numeric(18,3))
															  END) AND (CAST(REPLACE(dbo.F_Return_Hours(OT_SEC),':', '.') AS numeric(18,3)) <> 0)
												UNION
												SELECT	OA.For_Date
												FROM	[#Data_Temp] AS OA
												INNER JOIN T0080_EMP_MASTER AS E ON OA.Emp_ID = E.Emp_ID
												INNER JOIN T0100_CompOff_Application AS CA ON OA.Emp_Id = CA.Emp_ID AND OA.For_date = CA.Extra_Work_Date
												INNER JOIN (SELECT t1.Emp_ID, t1.Branch_ID 
															FROM T0095_INCREMENT t1  
															INNER JOIN (SELECT
															  Emp_ID,
															  MAX(Increment_ID)	-- Ankit 12092014 for Same Date Increment
															  AS Increment_ID
															  FROM
															  T0095_INCREMENT  
															  GROUP BY Emp_ID)
															  AS t2 ON t1.emp_id = t2.Emp_ID AND t1.Increment_ID = t2.Increment_ID)
														AS inc ON OA.Emp_ID = inc.Emp_ID
												INNER JOIN T0040_GENERAL_SETTING AS gs ON gs.Branch_ID = inc.Branch_ID
												WHERE	(CAST(REPLACE(dbo.F_Return_Hours(OT_SEC),':', '.') AS numeric(18,3)) >= CASE
															  WHEN CAST(REPLACE(gs.CompOff_Min_hours,':', '.') AS numeric(18,3)) = 0
															  THEN CAST(REPLACE(E.CompOff_Min_hrs,':', '.') AS numeric(18,3))
															  ELSE CAST(REPLACE(gs.CompOff_Min_hours,':', '.') AS numeric(18,3))
															  END) AND (CAST(REPLACE(dbo.F_Return_Hours(OT_SEC),':', '.') AS numeric(18,3)) <> 0))) Qry1
								INNER JOIN T0080_EMP_MASTER em ON Qry1.Emp_Id = em.Emp_ID
								INNER JOIN (SELECT	t1.emp_id, t1.branch_id
											FROM	T0095_Increment t1  
											INNER JOIN (SELECT emp_id,MAX(Increment_ID) AS Increment_ID	-- Ankit 12092014 for Same Date Increment
														FROM  t0095_increment  
														GROUP BY emp_id) AS t2 ON t1.emp_id = t2.emp_id AND t1.Increment_ID = t2.Increment_ID)
										AS inc ON Qry1.Emp_ID = inc.emp_id
								INNER JOIN T0040_General_Setting gs ON gs.branch_id = inc.branch_id
								where CAST(REPLACE(dbo.F_Return_Hours(OT_SEC),':', '.') AS numeric(18,3)) >= CASE 
															  WHEN 
															  CAST(REPLACE(isnull(															 
															  case when 
															   gs.CompOff_Min_hours ='' then '00:00' else gs.CompOff_Min_hours end															  
															  ,'00:00'),':', '.') AS numeric(18,3)) = 0
															  THEN CAST(REPLACE(isnull(
															  
															 case when  Em.CompOff_Min_hrs='' then '00:00' else Em.CompOff_Min_hrs end
															  
															  ,'00:00'),':', '.') AS numeric(18,3))
															  ELSE CAST(REPLACE(isnull(															  
															   case when gs.CompOff_Min_hours='' then '00:00' else gs.CompOff_Min_hours end															  
															  ,'00:00'),':', '.') AS numeric(18,3))
														  END AND 
														  
														  
														  CAST(REPLACE(dbo.F_Return_Hours(OT_SEC),':', '.') AS numeric(18,3)) <> 0
								ORDER BY OA.For_Date      
									END	
		 -------------------------

   
 end    

  
  else if @Return_Record_set = 1   
 begin  
	--IF EXISTS(SELECT 1 FROM T0165_ATTENDANCE_APPROVAL WHERE CMP_ID = @CMP_ID AND FOR_DATE >=@FROM_DATE AND FOR_DATE <= Dateadd(Day,1,@TO_DATE) AND ATT_STATUS = 'A')
	--	BEGIN

	--		UPDATE DT
	--			SET DT.DURATION_IN_SEC = (Case When DT.DURATION_IN_SEC > Q.SHIFT_SEC Then DT.DURATION_IN_SEC - Q.SHIFT_SEC Else 0 END),
	--				DT.OT_SEC = CASE WHEN DT.OT_SEC > Q.SHIFT_SEC AND G.Tras_Week_OT = 0 THEN 
	--								CASE WHEN DT.Emp_OT_Min_Limit > (DT.OT_SEC - Q.SHIFT_SEC) THEN	
	--									0
	--								ELSE  (DT.OT_SEC - Q.SHIFT_SEC) END
	--							ELSE 0 END,
	--				DT.Weekoff_OT_Sec = CASE WHEN G.Tras_Week_OT = 1 AND DT.Weekoff_OT_Sec > Q.SHIFT_SEC THEN DT.Weekoff_OT_Sec - Q.SHIFT_SEC ELSE DT.Weekoff_OT_Sec END,
	--				DT.Holiday_OT_Sec = CASE WHEN G.Tras_Week_OT = 1 AND DT.Holiday_OT_Sec > Q.SHIFT_SEC THEN DT.Holiday_OT_Sec - Q.SHIFT_SEC ELSE DT.Holiday_OT_Sec END
	--		FROM #DATA DT INNER JOIN 
	--		(
	--				SELECT EMP_ID,DATEADD(D,-1,FOR_DATE) AS FORDATE,P_DAYS,ATT_STATUS,SHIFT_SEC
	--				FROM T0165_ATTENDANCE_APPROVAL AA
	--				WHERE CMP_ID = @CMP_ID AND FOR_DATE >=@FROM_DATE AND FOR_DATE <= Dateadd(Day,1,@TO_DATE) AND ATT_STATUS = 'A' and P_Days <> 0
	--		)Q ON DT.EMP_ID =Q.EMP_ID  AND DT.FOR_DATE = Q.FORDATE
	--		INNER JOIN #EMP_GEN_SETTINGS G ON DT.Emp_Id=G.EMP_ID
	--	END
	

	
		SELECT *,dbo.F_Return_Hours (Duration_in_Sec) as Working_Hour ,dbo.F_Return_Hours (OT_SEc) as OT_Hour,Flag , dbo.F_Return_Hours (Weekoff_OT_Sec) as Weekoff_OT_Hour,
			dbo.F_Return_Hours (Holiday_OT_Sec) as Holiday_OT_Hour, Shift_Name,Shift_St_Time,OA.Shift_End_Time,Shift_Dur 
			,REPLACE(CONVERT(VARCHAR(20) , FOR_DATE , 106), ' ' , '-') AS ForDate,CONVERT(VARCHAR(20) , In_Time , 108) AS InTime , CONVERT(VARCHAR(20) , OUT_Time , 108) AS OutTime , SM.Shift_End_Time as Shift_En_Time	--Added for Excel Export Only (Ramiz-29/09/2018)
		FROM #Data  OA 
			INNER JOIN dbo.T0080_EMP_MASTER E  on OA.Emp_ID = E.Emp_ID 
			LEFT OUTER JOIN dbo.T0040_SHIFT_MASTER SM on OA.Shift_ID = SM.Shift_ID  
		ORDER BY E.emp_ID,For_Date   
		

	
   
  
 end    
  else if @Return_Record_set =3    
 begin    
   
  /*update #Data   
   set OT_Sec = 0    
  from #Data  d inner join T0160_OT_Approval OA on d.emp_ID = Oa.Emp_ID   
    
   update #Data   
   set OT_Sec = isnull(Approved_OT_Sec,0)  * 3600    
  from #Data  d inner join T0160_OT_Approval OA on d.emp_ID = Oa.Emp_ID and d.For_Date = oa.For_Date 

        
  */  
  
  
  
  CREATE TABLE #Data_Temp_3   
  (   
		 Emp_Id numeric ,   
		 For_date datetime,    
		 Duration_in_sec numeric,    
		 Shift_ID numeric ,    
		 Shift_Type numeric ,    
		 Emp_OT  numeric ,    
		 Emp_OT_min_Limit numeric,    
		 Emp_OT_max_Limit numeric,    
		 P_days  numeric(12,3) default 0,    
		 OT_Sec  numeric default 0 ,
		 In_Time datetime,
		 Shift_Start_Time  datetime,
		 OT_Start_Time numeric default 0,
		 Shift_Change tinyint default 0,
     Flag int default 0,
		 Weekoff_OT_Sec Numeric Default 0,
		 Holiday_OT_Sec Numeric Default 0 ,
		 Chk_By_Superior numeric default 0,
		 IO_Tran_Id	 numeric default 0,
		 OUT_Time Datetime,
		 Shift_End_Time datetime,			--Ankit 16112013
		 OT_End_Time numeric default 0,	--Ankit 16112013
		 Working_Hrs_St_Time tinyint default 0, --Hardik 14/02/2014
		 Working_Hrs_End_Time tinyint default 0, --Hardik 14/02/2014
		 GatePass_Deduct_Days numeric(18,2) default 0 -- Add by Gadriwala Muslim 05012014
		 
   ) 
    
   Declare @T_Emp_ID_3 Numeric  
   Declare @T_For_Date_3 datetime  
   Declare @Flag_cur As Int   	
   	
   	
   	   	
    --delete from #Data_Temp_3  
    Truncate Table #Data_Temp_3  --Hardik 15/02/2013
    
   -- Added by rohit on 26082013
   
   --declare @Emp_ID_W numeric
   --Declare @For_date_W Datetime
   
   
    
    DECLARE OT_Emp CURSOR  
    FOR  
     SELECT Emp_ID FROM #Emp_Cons 
     --inner join
     --t0160_Ot_Approval t  on d.Emp_ID = t.Emp_ID And d.For_Date = t.For_Date -- Added Inner join by Hardik 10/09/2012
   OPEN OT_Emp  
    fetch next from OT_Emp into @Emp_ID_W
    while @@fetch_status = 0  
   BEGIN  
   --Declare @StrWeekoff_Date_W varchar(max)
   --declare @Weekoff_Days_W varchar(max)
   --declare @Cancel_Weekoff_w varchar(max)
   --declare @StrHoliday_Date_W varchar(max)
   --declare @Holiday_days_W varchar(max)
   --declare @Cancel_Holiday_W varchar (max)
   
   --declare @OD_transfer_to_ot numeric(1,0)
   --Declare @Branch_id_OD numeric (4,0)
   
    
   select @BRANCH_ID_OD =	Branch_id from t0095_increment  where Increment_ID =( select max(Increment_ID) from t0095_increment where emp_id=@Emp_ID_W and increment_effective_date <=@To_Date) and emp_id = @Emp_ID_W	-- Ankit 12092014 for Same Date Increment
    
   select @OD_transfer_to_ot = Is_OD_Transfer_to_OT from t0040_general_setting where branch_id = @BRANCH_ID_OD
   
   if @OD_transfer_to_ot = 1 
   begin
   --Exec dbo.SP_EMP_HOLIDAY_DATE_GET1 @Emp_Week_Detail,@Cmp_ID,@From_Date,@To_Date,null,null,@Is_Cancel_Holiday,@StrHoliday_Date_W output,@Holiday_days_W output,@Cancel_Holiday_W output,0,@Branch_ID,@StrWeekoff_Date_W			
   --Exec dbo.SP_EMP_WEEKOFF_DATE_GET1 @Emp_ID_W,@Cmp_ID,@From_Date,@To_Date,null,null,@Is_Cancel_weekoff,'',@StrWeekoff_Date_W output,@Weekoff_Days_W output ,@Cancel_Weekoff_w output,@constraint=''
   IF OBJECT_ID('tempdb..#Emp_Holiday') IS Not NULL
			BEGIN		
				drop table #Emp_Holiday
			END --Added by Sumit after discussion with Nimesh bhai on 05122016
    Exec dbo.SP_EMP_HOLIDAY_DATE_GET @Emp_ID_W,@Cmp_ID,@From_Date,@To_Date,null,null,9,@StrHoliday_Date_W output,@Holiday_days_W output,@Cancel_Holiday_W output,0,@Branch_ID,@StrWeekoff_Date_W
		 IF OBJECT_ID('tempdb..#Emp_WeekOff') IS Not NULL
			BEGIN		
				drop table #Emp_WeekOff
			END --Added by Sumit after discussion with Nimesh bhai on 05122016
		Exec dbo.SP_EMP_WEEKOFF_DATE_GET @Emp_ID_W,@Cmp_ID,@From_Date,@To_Date,null,null,9,'',@StrWeekoff_Date_W output,@Weekoff_Days_W output ,@Cancel_Weekoff_w output
   
   

				   DECLARE OT_For_Date CURSOR  
						 FOR  							
							select  cast(data  as Datetime) as For_date  from dbo.Split ( (@StrHoliday_Date_W) ,';') 
							--select inactive_effective_date from t0040_leave_master
							OPEN OT_For_Date
							fetch next from OT_For_Date into @For_date_W
							while @@fetch_status = 0  
							BEGIN  
						
						--select @For_date_W as fordate,@Emp_ID_W as empid
							if Not Exists(select Tran_Id from dbo.t0160_Ot_Approval where Emp_ID=@Emp_ID_W And For_Date=@For_date_W)  
							
								 Begin  
										insert into #Data_Temp_3 
											(Emp_Id,For_date,Duration_in_sec,Shift_ID,Shift_Type,Emp_OT ,Emp_OT_min_Limit,Emp_OT_max_Limit,P_days,OT_Sec,In_Time,Shift_Start_Time,OT_Start_Time ,Shift_Change,Flag ,Weekoff_OT_Sec ,Holiday_OT_Sec ,Chk_By_Superior ,IO_Tran_Id ,OUT_Time )
									select LA.Emp_id,@For_date_W,		0,	0,			0,			1,		0,				0,				0,		0,	@For_date_W,@For_date_W,		0,			0,			0,	0,case when lad.half_leave_date =@For_date_W then 28800/2 else  28800 end ,				0,				0,		@For_date_W
									from T0120_LEAVE_APPROVAL LA inner join 
									T0130_LEAVE_APPROVAL_DETAIL LAD on LA.Leave_Approval_ID =LAD.Leave_Approval_ID inner join
									T0040_LEAVE_MASTER LM on LAD.leave_id = LM.leave_id 
									where Leave_Type='Company Purpose' and @for_date_W >= LAD.From_date and @for_date_W <= LAD.To_Date and Emp_id = @Emp_ID_W
									
								 End  


							fetch next from OT_For_Date into @For_date_W
							END  
							CLOSE OT_For_Date
							DEALLOCATE OT_For_Date
							
						DECLARE OT_For_Date CURSOR  
						 FOR  							
							select  cast(data  as Datetime) as For_date  from dbo.Split ( (@StrWeekoff_Date_W) ,';') where cast(data  as Datetime) not in (select cast(data  as Datetime) from dbo.Split ( (@StrHoliday_Date_W) ,';')) 
							--select inactive_effective_date from t0040_leave_master
							OPEN OT_For_Date
							fetch next from OT_For_Date into @For_date_W
							while @@fetch_status = 0  
							BEGIN  
						

							if Not Exists(select Tran_Id from dbo.t0160_Ot_Approval where Emp_ID=@Emp_ID_W And For_Date=@For_date_W)  
								 Begin  
										insert into #Data_Temp_3 
											(Emp_Id,For_date,Duration_in_sec,Shift_ID,Shift_Type,Emp_OT ,Emp_OT_min_Limit,Emp_OT_max_Limit,P_days,OT_Sec,In_Time,Shift_Start_Time,OT_Start_Time ,Shift_Change,Flag ,Weekoff_OT_Sec ,Holiday_OT_Sec ,Chk_By_Superior ,IO_Tran_Id ,OUT_Time )
									select LA.Emp_id,@For_date_W,		0,	0,			0,			1,		0,				0,				0,		0,	@For_date_W,@For_date_W,		0,			0,			0,	case when lad.half_leave_date =@For_date_W then 28800/2 else  28800 end ,				0,				0,				0,		@For_date_W
									from T0120_LEAVE_APPROVAL LA inner join 
									T0130_LEAVE_APPROVAL_DETAIL LAD on LA.Leave_Approval_ID =LAD.Leave_Approval_ID inner join
									T0040_LEAVE_MASTER LM on LAD.leave_id = LM.leave_id 
									where Leave_Type='Company Purpose' and @for_date_W >= LAD.From_date and @for_date_W <= LAD.To_Date and Emp_id = @Emp_ID_W
									
								 End  


							fetch next from OT_For_Date into @For_date_W
							END  
							CLOSE OT_For_Date
							DEALLOCATE OT_For_Date
			end	
				
    fetch next from OT_Emp into @Emp_ID_W
   END  
    CLOSE OT_Emp  
    DEALLOCATE OT_Emp  
    -- Ended by rohit
    
    DECLARE OT_cursor CURSOR  
    FOR  
	    SELECT d.Emp_ID,d.For_Date,Flag FROM #Data D
	    --Commented By rohit under the Guidance by Miteshbhai for Showing Ot hours Without Approved. 07-dec-2012
	  --   d inner join
			--t0160_Ot_Approval t  on d.Emp_ID = t.Emp_ID And d.For_Date = t.For_Date -- Added Inner join by Hardik 10/09/2012
   OPEN OT_cursor  
    fetch next from OT_cursor into @T_Emp_ID_3,@T_For_Date_3,@Flag_cur 
    while @@fetch_status = 0  
   BEGIN  
				--Commented by Hardik 10/09/2012    
				If Not Exists(Select Tran_Id from dbo.t0160_Ot_Approval where Emp_ID=@T_Emp_ID_3 And For_Date=@T_For_Date_3)  ----Commented By rohit under the Guidance by Miteshbhai for Showing Ot hours Without Approved. 07-dec-2012
					Begin  	     
							insert into #Data_Temp_3 
							select * from #Data where Emp_ID=@T_Emp_ID_3 And For_Date=@T_For_Date_3  						
						If @Flag_cur=1
							Begin
								Update #Data_Temp_3 Set OT_Sec = (OT_Sec* -1) Where  Emp_ID=@T_Emp_ID_3 And For_Date=@T_For_Date_3  
							End						
					End  
								
     
    fetch next from OT_cursor into @T_Emp_ID_3,@T_For_Date_3,@Flag_cur 
   END  
    CLOSE OT_cursor  
    DEALLOCATE OT_cursor 



   
   -- Added by rohit For match the ot hours  monthly ot and daily ot  on 04-dec-2012
    
   delete from #Data_Temp_3 Where Emp_Id = @Emp_Id and ( ISNULL(Weekoff_OT_Sec,0) = 0 or ISNULL(Holiday_OT_Sec,0) = 0)
						and For_Date in (Select Extra_Work_Date from dbo.T0120_CompOff_Approval where Extra_Work_Date >= @From_Date and Extra_Work_Date <= @To_Date and Cmp_ID = @Cmp_ID and Emp_ID = @T_Emp_ID_3 and Approve_Status = 'A')
    
    update #Data_Temp_3 set OT_Sec=0 Where Emp_Id = @Emp_Id and ( ISNULL(Weekoff_OT_Sec,0) = 0 and ISNULL(Holiday_OT_Sec,0) = 0)
						and For_Date in (Select Extra_Work_Date from dbo.T0120_CompOff_Approval where Extra_Work_Date >= @From_Date and Extra_Work_Date <= @To_Date and Cmp_ID = @Cmp_ID and Emp_ID = @T_Emp_ID_3 and Approve_Status = 'A')
		-- ended by rohit For match the ot hours for monthly ot and daily ot on 04-dec-2012				  
   
      
      Declare @Emp_Temp table  
      (  
        Emp_ID numeric(18,0),  
        For_Date dateTime,  
        Emp_full_Name varchar(50),  
        Working_Hour Varchar(20),  
        --Working_Hour numeric(18,5),  
        OT_Hour numeric(18,5),
        Weekoff_OT_Hour Numeric(18,5),
					Holiday_OT_Hour Numeric(18,5),
					P_Days numeric(18,3)  
      )  
     
      
   insert into @Emp_Temp(Emp_ID,For_Date,Emp_full_Name,Working_Hour,OT_Hour,Weekoff_OT_Hour,Holiday_OT_Hour,P_Days)  
   --select OA.Emp_ID,Max(For_Date)For_Date,E.Emp_Full_Name, CONVERT(decimal(10,2), sum(Duration_in_Sec)/3600) as Working_Hour ,CONVERT(decimal(10,2),(sum(OT_SEc)))  as OT_Hour ,sum(P_days) as Present_Days    
   Select OA.Emp_ID,Max(For_Date)For_Date,E.Emp_Full_Name,dbo.F_Return_Hours(Sum(Duration_in_Sec)) As Working_Hour ,CONVERT(decimal(10,2),(sum(OT_SEc)))  as OT_Hour ,CONVERT(decimal(10,2),(sum(Weekoff_OT_Sec)))  as Weekoff_OT_Sec,CONVERT(decimal(10,2),(sum(Holiday_OT_Sec))) as Holiday_OT_Sec,sum(P_days) as Present_Days
		From #Data_Temp_3  OA inner join dbo.T0080_emp_master E on OA.Emp_ID = E.Emp_ID    
		where OT_sec > 0 or Weekoff_OT_Sec > 0 or Holiday_OT_Sec > 0 --or Night_ot_sec > 0 --(Comment Night_ot_sec -Ankit 08042015 Not exist in templarty talbe #Data_Temp_3) 
		Group by OA.emp_ID,E.Emp_Full_Name   
  
 select OA1.Emp_ID,Max(For_Date)For_Date,E1.Alpha_Emp_code ,E1.Emp_Full_Name,Working_Hour,dbo.F_Return_Hours(OT_HOur) as OT_Hour, P_days, E1.Emp_Superior,dbo.F_Return_Hours(Weekoff_OT_Hour) as Weekoff_OT_Hour,dbo.F_Return_Hours(Holiday_OT_Hour) as Holiday_OT_Hour,E1.branch_id
  From @Emp_Temp  OA1 inner join dbo.T0080_emp_master E1 on OA1.Emp_ID = E1.Emp_ID    
  Group by OA1.emp_ID,E1.Alpha_Emp_code , E1.Emp_Full_Name ,For_Date,  Working_Hour,OT_Hour,P_days ,Emp_Superior ,Weekoff_OT_Hour,Holiday_OT_Hour,E1.branch_id 
 end  
  
  else if @Return_Record_set = 4    
 begin    
 


  
	 -- IF EXISTS(SELECT 1 FROM T0165_ATTENDANCE_APPROVAL WHERE CMP_ID = @CMP_ID AND FOR_DATE >=@FROM_DATE AND FOR_DATE <=Dateadd(Day,1,@TO_DATE) AND ATT_STATUS = 'A')
		--BEGIN

		--	UPDATE DT
		--		SET DT.DURATION_IN_SEC = (Case When DT.DURATION_IN_SEC > Q.SHIFT_SEC Then DT.DURATION_IN_SEC - Q.SHIFT_SEC Else 0 END),
		--			DT.OT_SEC = CASE WHEN DT.OT_SEC > Q.SHIFT_SEC AND G.Tras_Week_OT = 0 THEN 
		--							CASE WHEN DT.Emp_OT_Min_Limit > (DT.OT_SEC - Q.SHIFT_SEC) THEN	
		--								0
		--							ELSE  (DT.OT_SEC - Q.SHIFT_SEC) END
		--						ELSE 0 END,
		--			DT.Weekoff_OT_Sec = CASE WHEN G.Tras_Week_OT = 1 AND DT.Weekoff_OT_Sec > Q.SHIFT_SEC THEN DT.Weekoff_OT_Sec - Q.SHIFT_SEC ELSE DT.Weekoff_OT_Sec END,
		--			DT.Holiday_OT_Sec = CASE WHEN G.Tras_Week_OT = 1 AND DT.Holiday_OT_Sec > Q.SHIFT_SEC THEN DT.Holiday_OT_Sec - Q.SHIFT_SEC ELSE DT.Holiday_OT_Sec END
		--	FROM #DATA DT INNER JOIN 
		--	(
		--			SELECT EMP_ID,DATEADD(D,-1,FOR_DATE) AS FORDATE,P_DAYS,ATT_STATUS,SHIFT_SEC
		--			FROM T0165_ATTENDANCE_APPROVAL AA
		--			WHERE CMP_ID = @CMP_ID AND FOR_DATE >=@FROM_DATE AND FOR_DATE <=Dateadd(Day,1,@TO_DATE) AND ATT_STATUS = 'A' and P_Days <> 0
		--	)Q ON DT.EMP_ID =Q.EMP_ID  AND DT.FOR_DATE = Q.FORDATE
		--	INNER JOIN #EMP_GEN_SETTINGS G ON DT.Emp_Id=G.EMP_ID
		--END
  
  --update #Data  Set OT_Sec = 0 From #Data   
  /*  
	declare @Emp_Id_Temp numeric    
	declare @For_date datetime 
	 declare @Duration_in_sec numeric    
  declare @Emp_OT  numeric   
  declare @OT_Sec  numeric 
 
 declare curweekoff cursor Fast_forward for        
  select  Duration_in_sec,Emp_Id,For_date,Emp_OT,OT_Sec from  #Data order by For_date
 open curweekoff        
  fetch next from curweekoff into @Duration_in_sec,@Emp_Id_Temp,@For_date,@Emp_OT,@OT_Sec
  while @@fetch_status = 0        
 begin        
 
	if isnull(@Emp_OT,0)=1
		Begin
			if charindex(cast(left(@For_date,11) as varchar),@StrWeekoff_Date) >0
				Begin
					Update #Data set Duration_in_sec =0,Ot_sec=@OT_Sec+@Duration_in_sec,P_days=0 where Emp_Id=@Emp_Id_Temp
					And For_Date=@For_date
				
				End
		End
	
   
 fetch next from curweekoff into @Duration_in_sec,@Emp_Id_Temp,@For_date,@Emp_OT,@OT_Sec
 end        
 close curweekoff      
 deallocate curweekoff 
   */
	
    If @OT_Present =1 and @Auto_OT =1
   Begin  
					
	
					
				 --Update #Data   
					--set OT_Sec = isnull(Approved_OT_Sec,0) -- * 3600    
					--from #Data  d inner join T0160_OT_Approval OA on d.emp_ID = Oa.Emp_ID and d.For_Date = oa.For_Date 		
											
				
				Update #Data    
					set P_Days = P_Days + 0.5,OT_Sec=0 
				Where  OT_Sec >=3600 and OT_Sec <=18000   
				and Shift_ID= @shift_ID  and IO_Tran_Id  = 0  
				
				
				Update #Data    
					set P_Days = P_Days + 1,OT_Sec=0 
				Where  OT_Sec >=18001 and OT_Sec <=36000
				and Shift_ID= @shift_ID and IO_Tran_Id  = 0  
				
				
				Update #Data    
					set P_Days = P_Days + 1.5,OT_Sec=0   
				Where  OT_Sec >=36001 and OT_Sec <=54000
				and Shift_ID= @shift_ID and IO_Tran_Id  = 0  
				
				
				Update #Data    
					set P_Days = P_Days + 2.5,OT_Sec =0
				Where  OT_Sec >=54001 and OT_Sec <=99999
				and Shift_ID= @shift_ID and IO_Tran_Id  = 0  
				
				
   end
   Else if @OT_Present =0 and @Auto_OT =1
		Begin	
		
			update #Data   
			set OT_Sec = isnull(Approved_OT_Sec,0)  --* 3600    
			from #Data  d inner join dbo.T0160_OT_Approval OA on d.emp_ID = Oa.Emp_ID and d.For_Date = oa.For_Date   
			
		End  
	 Else if @OT_Present =0 and @Auto_OT =0
		Begin				
					  
		  --Update #Data set OT_Sec =0
			
			update #Data   
			set OT_Sec = isnull(Approved_OT_Sec,0) -- * 3600    
			from #Data  d inner join dbo.T0160_OT_Approval OA on d.emp_ID = Oa.Emp_ID and d.For_Date = oa.For_Date   
  
  
		End  	
 End  
  If @Return_Record_set = 5
	Begin
	
	CREATE TABLE #Data_Temp_5   
  (   
		 Emp_Id numeric ,   
		 For_date datetime,    
		 Duration_in_sec numeric,    
		 Shift_ID numeric ,    
		 Shift_Type numeric ,    
		 Emp_OT  numeric ,    
		 Emp_OT_min_Limit numeric,    
		 Emp_OT_max_Limit numeric,    
		 P_days  numeric(12,3) default 0,    
		 OT_Sec  numeric default 0,
		 In_Time datetime,
		 Shift_Start_Time  datetime ,
		 OT_Start_Time numeric default 0 ,
		 Shift_Change tinyint default 0,
     Flag int default 0   ,
		 Weekoff_OT_Sec Numeric Default 0,
		 Holiday_OT_Sec Numeric Default 0,
		 Chk_By_Superior numeric default 0,
		 IO_Tran_Id	 numeric default 0, -- io_tran_id is used for is_cmp_purpose (t0150_emp_inout)
		 OUT_Time Datetime,
		 Shift_End_Time datetime,			--Ankit 16112013
		 OT_End_Time numeric default 0,	--Ankit 16112013
		 Working_Hrs_St_Time tinyint default 0, --Hardik 14/02/2014
		 Working_Hrs_End_Time tinyint default 0, --Hardik 14/02/2014	
		 GatePass_Deduct_Days numeric(18,2) default 0 -- Add by Gadriwala Muslim 05012014

   ) 
   
    Declare @Temp Table
   (
			Emp_ID numeric ,
			For_Date datetime,
			p_Days numeric(12,3) default 0,
			OT_Sec numeric default 0,
			Weekoff_OT_Sec Numeric Default 0,
		  Holiday_OT_Sec Numeric Default 0,
			OT_Hours Numeric(18,5),
			Flag int default 0,
			Weekoff_OT_Hour Numeric(18,5),
			Holiday_OT_Hour Numeric(18,5)
   )
    
   Declare @T_Emp_ID_5 Numeric  
   Declare @T_For_Date_5 datetime  
   Declare @Flag_cur_5 As Int
   
    --delete from #Data_Temp_5  
    Truncate Table #Data_Temp_5  --Hardik 15/02/2013
    
    DECLARE OT_cursor CURSOR  
    FOR  
     SELECT Emp_ID,For_Date,Flag FROM #Data 
   OPEN OT_cursor  
    fetch next from OT_cursor into @T_Emp_ID_5,@T_For_Date_5,@Flag_cur_5  
    while @@fetch_status = 0  
   BEGIN  
    
					insert into #Data_Temp_5 
					select  * from #Data where Emp_ID=@T_Emp_ID_5 And For_Date=@T_For_Date_5  

 
			   
			    Insert Into @Temp
			    select Emp_Id,For_Date,P_Days,OT_sec,weekoff_ot_sec,Holiday_OT_Sec,cast(Round(OT_Sec/3600,2)as numeric(18,3)),flag,cast(Round(Weekoff_OT_Sec/3600,2)as numeric(18,3)),cast(Round(Holiday_OT_Sec/3600,2)as numeric(18,3))
			   From #Data where Emp_ID=@T_Emp_ID_5 And For_Date=@T_For_Date_5
			    --select Emp_Id,For_Date,P_Days,OT_sec,dbo.F_Return_Hours(OT_Sec),flag From #Data where Emp_ID=@T_Emp_ID_5 And For_Date=@T_For_Date_5  
			    
			    If @Flag_cur_5=1
						Begin 
							Update @temp Set Ot_Sec = (Ot_Sec * -1),Weekoff_OT_Sec = (Weekoff_OT_Sec * -1),Holiday_OT_Sec = (Holiday_OT_Sec * -1)
							 Where Emp_ID=@T_Emp_ID_5 And For_Date=@T_For_Date_5 And Flag=1
							--Update @temp Set OT_Hours = dbo.F_Return_Hours(OT_Sec) Where Emp_ID=@T_Emp_ID_5 And For_Date=@T_For_Date_5 And Flag=1
							Update @temp Set OT_Hours = '-'+ OT_Hours, Weekoff_OT_Hour = '-'+ Weekoff_OT_Hour, Holiday_OT_Hour = '-'+ Holiday_OT_Hour
							  Where Emp_ID=@T_Emp_ID_5 And For_Date=@T_For_Date_5 And Flag=1
						End		
     
    fetch next from OT_cursor into @T_Emp_ID_5,@T_For_Date_5,@Flag_cur_5 
   END  
    CLOSE OT_cursor  
    DEALLOCATE OT_cursor  
    


    Declare @Emp_Temp_5 table  
    (  
    Emp_ID numeric(18,0),  
    For_Date dateTime,  
    Emp_full_Name varchar(50),  
    --Working_Hour Varchar(20),  
    Working_Hour numeric(18,5),  
    OT_Hour numeric(18,5),  
    P_Days numeric(18,3),
			Weekoff_OT_Hour Numeric(18,5),
			Holiday_OT_Hour Numeric(18,5) 
    ) 
  
	  
		insert into @Emp_Temp_5(Emp_ID,For_Date,Emp_full_Name,Working_Hour,OT_Hour,P_Days,Weekoff_OT_Hour,Holiday_OT_Hour)  
		SELECT	OA.Emp_ID,Max(For_Date)For_Date,E.Emp_Full_Name, CONVERT(decimal(10,2), sum(Duration_in_Sec)/3600) as Working_Hour ,
				CONVERT(decimal(10,2),(sum(OT_SEc)))  as OT_Hour ,sum(P_days) as Present_Days , CONVERT(decimal(10,2),
				(sum(Weekoff_OT_Sec)))  as Weekoff_OT_Hour,CONVERT(decimal(10,2),(sum(Holiday_OT_Sec)))  as Holiday_OT_Hour   
		--Select OA.Emp_ID,Max(For_Date)For_Date,E.Emp_Full_Name,dbo.F_Return_Hours(Sum(Duration_in_Sec)) As Working_Hour ,CONVERT(decimal(10,2),(sum(OT_SEc)))  as OT_Hour ,sum(P_days) as Present_Days    
		From #Data_Temp_5  OA inner join dbo.T0080_emp_master E on OA.Emp_ID = E.Emp_ID    
		Group by OA.emp_ID,E.Emp_Full_Name   	
		---Select * from #data_temp	
							
		insert into #Data_MOTIF
		--Select Emp_ID,For_Date,p_Days, dbo.F_Return_Hours(OT_SEc),Flag From #Data_Temp_5 OA    							
		Select Emp_ID,For_Date,p_Days,dbo.F_Lower_Round(OT_Hours, @Cmp_ID),Weekoff_OT_Hour,Holiday_OT_Hour  From @temp OA    							
		Order by OA.For_Date   
		--End  					
									
																
		insert into #Att_Detail 
  		SELECT	OA1.Emp_ID,P_days,dbo.F_Return_Hours(OT_HOur),0,0,0,0,0,0,0,dbo.F_Return_Hours(Weekoff_OT_Hour),
				dbo.F_Return_Hours(Holiday_OT_Hour)
		From @Emp_Temp_5  OA1 inner join dbo.T0080_emp_master E1 on OA1.Emp_ID = E1.Emp_ID    
		Group by OA1.emp_ID,E1.Emp_Full_Name ,For_Date,  Working_Hour,OT_Hour,P_days ,Weekoff_OT_Hour,Holiday_OT_Hour
				
	   
	End  	
		
--PRINT 'CALC 35 :' + CONVERT(VARCHAR(20), GETDATE(), 114);	
 RETURN  
