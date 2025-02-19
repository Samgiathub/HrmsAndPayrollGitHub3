

---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_EMP_INOUT_RECORD_LUBI] 
	@Cmp_ID   numeric,      
	@From_Date  DATETIME,      
	@To_Date  DATETIME ,      
	@Branch_ID  numeric   ,      
	@Cat_ID   numeric  ,      
	@Grd_ID   numeric ,      
	@Type_ID  numeric ,      
	@Dept_ID  numeric  ,      
	@Desig_ID  numeric ,      
	@Emp_ID   numeric  ,      
	@Constraint  VARCHAR(max) = '',      
	@Report_call VARCHAR(50) = 'IN-OUT',      
	@Weekoff_Entry VARCHAR(1) = 'Y',  
	@PBranch_ID VARCHAR(max) = '0' ,
	@InOut_Tag VARCHAR(200) = '0' , 
	@Order_By	varchar(30) = 'Code' ,
	@Is_Column Numeric = 0

AS      
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON 
    
    
	IF @Branch_ID = 0      
		SET @Branch_ID = null      
	IF @Cat_ID = 0      
		SET @Cat_ID  = null      
	    
	IF @Type_ID = 0      
		SET @Type_ID = null      
	IF @Dept_ID = 0      
		SET @Dept_ID = null      
	IF @Grd_ID = 0      
		SET @Grd_ID = null      
	IF @Emp_ID = 0      
		SET @Emp_ID = null      
	IF @Desig_ID =0      
		SET @Desig_ID = null      
	
	IF OBJECT_ID('tempdb..#Emp_Cons') is not null
		Drop table #Emp_Cons   
	
	CREATE table #Emp_Cons 
	(      
		Emp_ID numeric ,     
		Branch_ID numeric,
		Increment_ID numeric    
	)  

	if @Is_Column = 1
		Begin
			Select '' as Alpha_Emp_Code, '' as Emp_Full_Name,'' as Desig_Name,'' as For_Date,'' as Shift_St_Time,'' as Shift_End_Time, '' as Shift_Duration, '' as In_Time,'' as Out_Time,'' as Duration,'' as Att_Days,'' as Att_Status
			return
		End

	EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,0,0,0,0,0,0,0,0,2,@PBranch_ID 
	
	IF Object_ID('tempdb..#Month_CTE') is not null
		Begin
			Drop Table #Month_CTE
		End

	CREATE TABLE #Month_CTE(ROW_ID NUMERIC,For_Date datetime PRIMARY KEY);
    
    INSERT INTO #Month_CTE (For_Date)
    SELECT  DATEADD(d, ROW_ID, @From_Date)
    FROM    (SELECT (ROW_NUMBER() OVER (ORDER BY OBJECT_ID) -1) AS ROW_ID
             FROM sys.objects) T
    WHERE   DATEADD(d, ROW_ID, @From_Date) <= @To_Date 
	
	Update  M
    SET     ROW_ID = T.ROW_ID
    FROM    #Month_CTE M INNER JOIN 
            (SELECT ROW_NUMBER() over (ORDER BY For_Date,DATENAME(dw,For_Date)) AS ROW_ID, For_Date
             FROM #Month_CTE T) T on M.For_Date=T.For_Date


	IF Object_ID('tempdb..#EmpAttendance') Is not null
		Begin
			Drop Table #EmpAttendance
		End

	Create Table #EmpAttendance
	(
		ROW_ID Numeric,
		Cmp_ID Numeric,
		Emp_ID Numeric,
		For_Date DateTime,
		Shift_ID Numeric,
		Shift_St_Time Varchar(10),
		Shift_End_Time Varchar(10),
		Shift_Duration Varchar(10),
		In_Time Varchar(10),
		Out_Time Varchar(10),
		Duration Varchar(10),
		P_Day Numeric(5,2),
		Att_Status VARCHAR(10),
		Leave_Day Numeric(5,2),
		Leave_Code Varchar(20),
		Absent_Days Numeric(6,3)
		
	)

	INSERT INTO #EmpAttendance(ROW_ID,Cmp_ID,Emp_ID,For_Date)
	Select MC.ROW_ID,@Cmp_ID,EC.Emp_ID,MC.For_Date From #Emp_Cons EC Cross Join #Month_CTE MC

	IF OBJECT_ID('tempdb..#EMP_HOLIDAY') IS NULL
		BEGIN
			CREATE TABLE #EMP_HOLIDAY(EMP_ID NUMERIC, FOR_DATE DATETIME, IS_CANCEL BIT, Is_Half tinyint, Is_P_Comp tinyint, H_DAY numeric(4,1));
			CREATE UNIQUE CLUSTERED INDEX IX_EMP_HOLIDAY_EMPID_FORDATE ON #EMP_HOLIDAY(EMP_ID, FOR_DATE);
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
		END

	If Object_ID('tempdb..#Data') is not null
		Drop Table #Data

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
	   
	   Exec SP_CALCULATE_PRESENT_DAYS @Cmp_ID=@Cmp_ID,@From_Date=@From_Date,@To_Date=@To_Date,@Branch_ID='0',@Cat_ID='0',@Grd_ID=0,@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Emp_ID=0,@constraint=@constraint,@Return_Record_set=4,@PBranch_ID='0',@PVertical_ID='0',@PSubVertical_ID='0',@PDept_ID='0'   

	   Update E
		Set E.Shift_ID = D.Shift_ID,
			E.In_Time = dbo.F_GET_AMPM (case when  datepart(s,D.In_Time) > 30 then DATEADD(ss,30,D.In_Time) ELSE D.In_Time END ),
			E.Out_Time = dbo.F_GET_AMPM (case when  datepart(s,D.Out_Time) > 30 then DATEADD(ss,30,D.Out_Time) ELSE D.Out_Time END ),
			E.Duration = dbo.F_Return_Hours(D.Duration_in_sec),
			E.P_Day = D.P_days,
			E.Att_Status = Case When D.P_days <> 0 Then 'P' ELSE '-' END
	From #EmpAttendance E Inner Join #Data D 
	ON E.Emp_ID = D.Emp_ID and E.For_Date = D.For_date

	
	Update EA
		Set EA.Att_Status = 'HO',
			EA.P_Day = 0
		From #EmpAttendance EA 
	Inner Join #EMP_HOLIDAY EH ON EA.Emp_ID = EH.Emp_ID AND EA.For_Date = EH.FOR_DATE
	Where NOT EXISTS(Select 1 From #Data D Where D.Emp_ID = EH.Emp_ID AND D.For_Date = EH.FOR_DATE AND P_Day = 1)

	Update EA
		Set EA.Att_Status = 'WO',
			EA.P_Day = 0
		From #EmpAttendance EA 
	Inner Join #Emp_WeekOff EW ON EA.Emp_ID = EW.Emp_ID AND EA.For_Date = EW.FOR_DATE
	Where NOT EXISTS(Select 1 From #Data D Where D.Emp_ID = EW.Emp_ID AND D.For_Date = EW.FOR_DATE AND P_Day = 1)

	Update EA
		Set EA.Shift_St_Time = SM.Shift_St_Time,
			EA.Shift_End_Time = SM.Shift_End_Time,
			EA.Shift_Duration = SM.Shift_Dur
		From #EmpAttendance EA 
	Inner Join T0040_SHIFT_MASTER SM ON EA.Shift_ID = SM.Shift_ID

	IF OBJECT_ID('tempdb..#LeaveData') is not null
		Begin
			Drop Table #LeaveData
		End

	Create Table #LeaveData
	(
		Emp_ID Numeric,
		For_Date Datetime,
		Leave_ID Numeric,
		Leave_Type Varchar(25),
		Leave_Days Numeric(6,3),
		Leave_Approval_ID Numeric,
		Leave_Code Varchar(20)
	)


	Insert into #LeaveData
	SELECT	LT.Emp_ID,LT.For_Date,LT.Leave_ID,'' As Leave_Type,
			LT.CompOff_Used + Case When LM.Apply_Hourly = 1 AND LT.Leave_Used % 1 = 0  Then LT.Leave_Used * 0.125 Else LT.Leave_Used End As Leave_Days, 0 As Leave_Approval_ID,LM.Leave_Code
	FROM	T0140_Leave_Transaction LT	WITH (NOLOCK)
			INNER JOIN T0040_Leave_Master LM WITH (NOLOCK) ON LT.Leave_ID=LM.Leave_ID
			INNER JOIN #EmpAttendance EA ON LT.EMP_ID=EA.EMP_ID AND LT.FOR_DATE=EA.FOR_DATE
	WHERE	(LT.Leave_Used + LT.CompOff_Used) > 0 and LT.For_Date Between @From_Date AND @To_Date

	UPDATE	LL
	SET		Leave_Approval_ID = LA.Leave_Approval_ID,
			Leave_Type = Case 	When LL.For_Date = LAD.Half_Leave_Date OR IsNull(LAD.Half_Leave_Date, '1900-01-01') = '1900-01-01' Then 
									LAD.Leave_Assign_As 								
								Else 
									'Full Day' 
						End
	FROM	#LeaveData LL
			INNER JOIN T0130_Leave_Approval_Detail LAD ON LL.Leave_ID=LAD.Leave_ID AND LL.For_Date Between LAD.From_Date AND LAD.To_Date
			INNER JOIN T0120_Leave_Approval LA ON LL.Emp_ID=LA.Emp_ID AND LAD.Leave_Approval_ID=LA.Leave_Approval_ID
	Where	NOT EXISTS(Select 1 FROM T0150_Leave_Cancellation LC WITH (NOLOCK)
						WHERE LC.For_Date=LL.For_Date AND LC.Leave_Approval_ID=LA.Leave_Approval_ID)
			AND LA.Approval_Status = 'A'

	
	Update EA	
		SET EA.Leave_Day = Qry.Leave_Days
	From #EmpAttendance EA 
	Inner Join (Select SUM(Leave_Days) as Leave_Days,For_Date,Emp_ID From #LeaveData
				Group by For_Date,Emp_ID
				) as Qry
    ON EA.For_Date = Qry.For_Date and EA.Emp_ID = Qry.Emp_ID

	Update #EmpAttendance 
		SET Absent_Days = Case When (Isnull(P_Day,0) + Isnull(Leave_Day,0)) < 1 then 1 - (Isnull(P_Day,0) + Isnull(Leave_Day,0)) Else 0 END
	Where Isnull(Att_Status,'') NOT IN('WO','HO')

	
	SELECT '="' + E.Alpha_Emp_Code + '"' as Alpha_Emp_Code,E.Emp_Full_Name,DM.Desig_Name,Replace(CONVERT(VARCHAR(15),For_Date,106),' ','/') as For_Date  ,Shift_St_Time,Shift_End_Time,Shift_Duration,In_Time,Out_Time,Duration,Cast(Att_Days as Varchar(10)) as Att_Days,D_Status as Att_Status
	FROM	(
		Select ROW_ID,Emp_ID,For_Date,Shift_St_Time,Shift_End_Time,Shift_Duration,In_Time,Out_Time,Duration,P_Day as Att_Days,(Case When Isnull(Att_Status,'') = 'WO' and Isnull(P_Day,0) = 0 Then 'WO' WHEN Isnull(Att_Status,'') = 'HO' and Isnull(P_Day,0) = 0 Then 'HO' ELSE 'P' END) As D_Status, 1 AS Label_ID From #EmpAttendance Where (P_Day <> 0 OR Isnull(Att_Status,'') IN('WO','HO'))
		UNION ALL
		Select ROW_ID,EA.Emp_ID,EA.For_Date,Shift_St_Time,Shift_End_Time,Shift_Duration,'' as In_Time,'' as Out_Time,'' as Duration,LD.Leave_Days as Att_Days, LD.Leave_Code As D_Status, 2 AS Label_ID 
		From #EmpAttendance EA
		Inner Join #LeaveData LD ON EA.For_Date = LD.For_Date and EA.Emp_ID = LD.Emp_ID Where Leave_Day <> 0
		UNION ALL
		Select ROW_ID,Emp_ID,For_Date,Shift_St_Time,Shift_End_Time,Shift_Duration,In_Time,Out_Time,Duration,Absent_Days as Att_Days, 'A' As D_Status, 3 AS Label_ID From #EmpAttendance Where Absent_Days <> 0  
	) T
	Inner Join #Emp_Cons EC ON T.Emp_ID = EC.Emp_ID
	Inner Join T0080_EMP_MASTER E WITH (NOLOCK) ON T.Emp_ID = E.Emp_ID
	Inner Join T0095_INCREMENT I WITH (NOLOCK) ON I.Increment_ID = EC.Increment_ID
	Left Outer Join T0040_DESIGNATION_MASTER DM WITH (NOLOCK) ON I.Desig_Id = Dm.Desig_ID
	ORDER BY E.EMP_ID,ROW_ID
