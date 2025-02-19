

CREATE PROCEDURE [DBO].[SP_RPT_EMP_INOUT_RECORD_GET_CONSOLIDATED_21012020]      
    @Cmp_ID         NUMERIC,      
    @From_Date      DATETIME,      
    @To_Date        DATETIME ,      
    @Branch_ID      NUMERIC   ,      
    @Cat_ID         NUMERIC  ,      
    @Grd_ID         NUMERIC ,      
    @Type_ID        NUMERIC ,      
    @Dept_ID        NUMERIC  ,      
    @Desig_ID       NUMERIC ,      
    @Emp_ID         NUMERIC  ,      
    @Constraint     VARCHAR(MAX) = '',      
    @Report_call    VARCHAR(20) = 'IN-OUT',      
    @Weekoff_Entry  VARCHAR(1) = 'Y',  
    @PBranch_ID     VARCHAR(200) = '0',
    @Order_By       VARCHAR(30) = 'Code' --Added by Nimesh 14-Jul-2015 (To sort by Code/Name/Enroll No)      
AS      
    SET NOCOUNT ON 
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
    SET ARITHABORT ON     
       
       
    DECLARE @Status     AS VARCHAR(9)      
    DECLARE @For_Date   AS DATETIME      
    DECLARE @RowID      AS NUMERIC       
    DECLARE @GradeID    AS NUMERIC       
    DECLARE @SysDate    AS DATETIME  
      
      
    DECLARE @LateMark   AS VARCHAR(9)      
    DECLARE @InTime     AS SMALLDATETIME       
    DECLARE @OutTime    AS SMALLDATETIME      
    DECLARE @PreOutTime AS SMALLDATETIME      
        
    DECLARE @Is_Join            AS VARCHAR(1)      
    DECLARE @Count              AS NUMERIC      
    DECLARE @dblYear            AS NUMERIC      
    DECLARE @numofDay           AS NUMERIC      
    DECLARE @varWeekoff_Date    AS VARCHAR(500)      
    DECLARE @varHoliday_Date    AS VARCHAR(500)      

    DECLARE @Join_Date                  AS DATETIME      
    DECLARE @Left_Date                  AS DATETIME       
    DECLARE @StrHoliday_Date            AS VARCHAR(MAX)      
    DECLARE @StrWeekoff_Date            AS VARCHAR(MAX)      
    DECLARE @Is_Cancel_Holiday          AS NUMERIC(1,0)      
    DECLARE @Is_Cancel_Weekoff          AS NUMERIC(1,0)      
    DECLARE @Holiday_Days               AS NUMERIC(12,1)      
    DECLARE @Weekoff_Days               AS NUMERIC(12,1)      
    DECLARE @Cancel_Holiday             AS NUMERIC(12,1)      
    DECLARE @Cancel_Weekoff             AS NUMERIC(12,1)      
    DECLARE @StrCancelWeekoff_Date      AS VARCHAR(MAX)--Ankit 30122015
    DECLARE @StrCancelHoliday_Date      AS VARCHAR(MAX)--Ankit 30122015
    DECLARE @Weekoff_Date1_CancelStr    AS VARCHAR(MAX)--Ankit 30122015

    SET @Is_Cancel_Weekoff = 0      
    SET @Is_Cancel_Holiday = 0      
    SET @StrHoliday_Date = ''      
    SET @StrWeekoff_Date = ''      
    SET @Holiday_Days  = 0      
    SET @Weekoff_Days  = 0      
    SET @Cancel_Holiday  = 0      
    SET @Cancel_Weekoff  = 0      
    SET @StrCancelWeekoff_Date = ''
    SET @StrCancelHoliday_Date = ''
    SET @Weekoff_Date1_CancelStr = ''

    SET @Count =0      
    SET @RowID =0      
   
    --PRINT CONVERT(VARCHAR(20), GETDATE(), 114) + ' STEP 1'
    SET @numofDay = Datediff(d,@From_Date,@To_Date) + 1      
      
    -- for Holiday and Week Off  and LEave date      
    DECLARE @Total_Holiday_Date     AS VARCHAR(MAX)      
    DECLARE @Total_LeaveDay_Date    AS VARCHAR(MAX)      
    DECLARE @strOnlyHoliday_date    AS VARCHAR(MAX)      
    SET @Total_Holiday_Date = ''      
    SET @Total_LeaveDay_Date = ''      
      
    -- for Shift      
    DECLARE @Shift_St_Time              AS VARCHAR(10)      
    DECLARE @Shift_End_Time             AS VARCHAR(10)      
    DECLARE @varShift_St_Date           AS VARCHAR(20)      
    DECLARE @dtShift_St_Date            AS DATETIME      
    DECLARE @varShift_End_Date          AS VARCHAR(20)      
    DECLARE @dtShift_End_Date           AS DATETIME      
    DECLARE @TempFor_Date               AS SMALLDATETIME      
    DECLARE @dtShift_Actual_St_Time     AS DATETIME      
    DECLARE @dtShift_Actual_End_Time    AS DATETIME      
    DECLARE @Late_Comm_Limit            AS VARCHAR(5)      
    DECLARE @Late_comm_sec              AS NUMERIC       
    DECLARE @Leave_ID                   AS NUMERIC       
    DECLARE @Leave_Name                 AS VARCHAR(20)      
    DECLARE @Leave_Reason               AS VARCHAR(100)  
    --Added by Hardik 06/12/2013 for Pakistan
    DECLARE @Leave_Period               AS NUMERIC(18,2)
    DECLARE @Half_Leave_Date            AS DATETIME
    DECLARE @Leave_Assign_As            AS VARCHAR(100)
    DECLARE @Country_Name               AS VARCHAR(100)
    DECLARE @test                       AS VARCHAR(MAX)    
    DECLARE @test1                      AS VARCHAR(MAX) 
    DECLARE @Col_Str                    AS VARCHAR(Max)
    DECLARE @Col_Str_Sum                AS VARCHAR(Max)  
    
    SELECT  @Country_Name = Loc_name 
    FROM    T0010_COMPANY_MASTER C Inner Join T0001_LOCATION_MASTER L On C.Loc_ID = L.Loc_ID 
    WHERE   C.Cmp_Id = @Cmp_ID
      
    DECLARE @Temp_Month_Date AS DATETIME      
    SET @Temp_Month_Date = @From_Date      
    
    --Added by Jaina 17-11-2017
    DECLARE @Comp_OD_As_Present AS Bit
    SELECT @Comp_OD_As_Present = ISNULL(SETTING_VALUE,0) FROM T0040_SETTING  
    WHERE SETTING_NAME = 'OD and CompOff Leave Consider As Present' AND CMP_ID = @CMP_ID
    
    CREATE table #Leave 
    (   
        Emp_Id NUMERIC,
        Leave_Id NUMERIC,
        Leave_Name VARCHAR(50),
        Leave_Days NUMERIC(18,2),
        FH_SH VARCHAR(2)
    )
    CREATE NONCLUSTERED INDEX ix_Leave_Balance_EmpId_LeaveId on #Leave (Emp_Id,Leave_Id)       


    CREATE table #Leave_Balance
    ( 
        Emp_ID NUMERIC,
        Leave_ID NUMERIC,
        Leave_Closing decimal(18,2),
        For_Date DATETIME,
        Leave_Name VARCHAR(50)
    )   
    CREATE NONCLUSTERED INDEX ix_Leave_Balance_EmpId_LeaveId_ForDate on #Leave_Balance (Emp_Id,For_date,Leave_Id)      

    CREATE table #Data     
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
        Holiday_OT_Sec  NUMERIC default 0   ,
        Chk_By_Superior NUMERIC default 0,
        IO_Tran_Id     NUMERIC default 0,
        OUT_Time DATETIME, 
        Shift_End_Time DATETIME,        --Ankit 16112013
        OT_End_Time NUMERIC default 0,  --Ankit 16112013
        Working_Hrs_St_Time tinyint default 0, --Hardik 14/02/2014
        Working_Hrs_End_Time tinyint default 0, --Hardik 14/02/2014
        GatePass_Deduct_Days NUMERIC(18,2) default 0 -- Add by Gadriwala Muslim 05012014
    )        

    CREATE NONCLUSTERED INDEX ix_Data_Emp_Id_For_date_Shift_Id on #Data (Emp_Id,For_date,Shift_ID) 

      
    DECLARE @In_Dur AS VARCHAR(10)      
    DECLARE @In_Out_Flag AS VARCHAR(1)      
    DECLARE @Day_St_Time AS DATETIME      
    DECLARE @Day_End_Time AS DATETIME      
       
    DECLARE @OT_Limit_Sec AS NUMERIC      
    DECLARE @OT_Limit AS VARCHAR(10)      
       
    DECLARE @Temp_For_Date AS VARCHAR(11)      
    DECLARE @Shift_Sec AS NUMERIC      
    DECLARE @Return_Sec AS NUMERIC      
    DECLARE @Tot_Working_Sec AS NUMERIC      
    DECLARE @Working_Sec AS NUMERIC      
    DECLARE @OT_Sec AS NUMERIC      
    DECLARE @Holiday_Work_Sec AS NUMERIC      
    DECLARE @WeekOff_Work_Sec AS NUMERIC      
       
    SET @Return_Sec = 0      
    SET @Holiday_Work_Sec = 0      
    SET @WeekOff_Work_Sec = 0      
       
    DECLARE @In_Date AS DATETIME   
    DECLARE @Out_Date AS DATETIME      
    DECLARE @Shift_Dur AS VARCHAR(10)      
    DECLARE @Temp_Date AS DATETIME      
    DECLARE @Min_Dur AS VARCHAR(10)      
       
    DECLARE @Rounding_Shift_Time AS NUMERIC      
    DECLARE @Next_Day_Working_Sec AS NUMERIC      
    DECLARE @Is_OT AS VARCHAR(1)      
    DECLARE @Fix_OT AS NUMERIC      
    DECLARE @Shift_End_DateTime AS DATETIME      
    DECLARE @Shift_ST_DateTime AS DATETIME      
    DECLARE @Last_out_Date AS DATETIME      
    DECLARE @Manual_Last_in_Date AS DATETIME      
    DECLARE @Next_day_Work_Sec AS NUMERIC  -- previous days working sec      
    DECLARE @Temp_Working_sec AS NUMERIC      
    DECLARE @varWagesType AS VARCHAR(20)      
    DECLARE @temp_out_Date AS DATETIME      
    DECLARE @SHIFT_ID AS NUMERIC       
      
    DECLARE @Insert_In_Date AS DATETIME      
    DECLARE @Insert_Out_Date AS DATETIME      
    DECLARE @INSERT_COUNT AS INTEGER      
    DECLARE @Late_In AS VARCHAR(20)      
    DECLARE @Late_Out AS VARCHAR(20)      
    DECLARE @Early_In AS VARCHAR(20)      
    DECLARE @Early_Out AS VARCHAR(20)      
    DECLARE @WORKING_HOURS AS VARCHAR(20)      
    DECLARE @Late_In_Count AS NUMERIC       
    DECLARE @Early_out_count AS NUMERIC       
    DECLARE @Total_less_work_sec AS NUMERIC       
    DECLARE @Total_More_work_sec AS NUMERIC       
       
    DECLARE @Late_In_Sec NUMERIC      
    DECLARE @Late_Out_Sec NUMERIC      
    DECLARE @Early_In_Sec NUMERIC      
    DECLARE @Early_Out_Sec NUMERIC      
       
    DECLARE @Toatl_Working_sec NUMERIC       
    DECLARE @Total_work AS VARCHAR(20)      
    DECLARE @Less_Work AS VARCHAR(20)      
    DECLARE @More_Work AS VARCHAR(20)      
    DECLARE @Diff_Sec  AS NUMERIC       
    DECLARE @Working_Sec_AfterShift AS NUMERIC       
    DECLARE @Working_AfterShift_Count AS NUMERIC       
    DECLARE @Reason AS VARCHAR(300)      
    DECLARE @Pre_Reason AS VARCHAR(300)      
    DECLARE @Last_Entry_For_check AS DATETIME      
      
    DECLARE @Shift_St_Sec AS NUMERIC       
    DECLARE @Shift_En_sec AS NUMERIC      
    DECLARE @Pre_Inout_Flag AS VARCHAR(1)      
    DECLARE @Pre_In_Date AS DATETIME      
    DECLARE @Pre_Shift_St_dateTime AS DATETIME      
    DECLARE @Pre_Shift_En_DateTime AS DATETIME       

    DECLARE @Early_Limit_sec AS NUMERIC   
    DECLARE @Early_Limit AS VARCHAR(10)    
    SET @Early_Limit_sec = 0
    SET @Early_Limit = ''

    DECLARE @Emp_OT AS NUMERIC
    DECLARE @Emp_OT_Min_Limit_Sec AS NUMERIC
    DECLARE @Emp_OT_Max_Limit_Sec AS NUMERIC
 
    DECLARE @Monthly_Deficit_Adjust_OT_Hrs AS tinyint -- Added by Hardik 25/10/2013 for Sharp Image, Pakistan
 
    --Ankit 12112013
    DECLARE @Second_Break_Duration AS VARCHAR(10)    
    DECLARE @Third_Break_Duration AS VARCHAR(10)     
    SET @Second_Break_Duration =''  
    SET @Third_Break_Duration =''   
    DECLARE @Second_Break_Duration_Sec AS NUMERIC       
    DECLARE @Third_Break_Duration_Sec AS NUMERIC        
    --Ankit 12112013 

    DECLARE @Emp_Late_Mark AS tinyint
    DECLARE @Emp_Early_Mark AS tinyint
        
    SET @Emp_Late_Mark = 0
    SET @Emp_Early_Mark = 0

    SET @Emp_OT = 0
    SET @Emp_OT_Min_Limit_Sec = 0
    SET @Emp_OT_Max_Limit_Sec = 0
    SET @Monthly_Deficit_Adjust_OT_Hrs = 0
    SET @Fix_OT = 0      
    SET @Reason  = ''      
    SET @Pre_Reason = ''      
      
    SET @Shift_St_Time = ''      
    SET @Shift_End_Time = ''      
    SET @Shift_Dur = ''      
    SET @Late_Comm_Limit = ''      
    SET @Late_comm_sec = 0      
    SET @Leave_Id = 0      
    SET @Leave_Name = '' 
    SET @Col_Str = ''
    SET @Col_Str_Sum = ''      
       
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
       
       
    SELECT  @Late_Comm_Limit = Late_Limit,@Early_Limit = Early_Limit
    FROM    T0040_GENERAL_SETTING 
    WHERE   Cmp_ID = @Cmp_ID and For_Date  = ( SELECT max(For_Date) FROM T0040_GENERAL_SETTING WHERE Cmp_ID = @Cmp_ID and For_Date <=@To_Date)      
       
    SET @Late_Comm_sec = dbo.F_Return_Sec(@Late_Comm_Limit) 
    SET @Early_Limit_sec = dbo.F_Return_Sec(@Early_Limit)        

    CREATE table #Emp_Cons 
    (      
        Emp_ID NUMERIC ,     
        Branch_ID NUMERIC,
        Increment_ID NUMERIC    
    )      

    CREATE NONCLUSTERED INDEX IX_Data1 ON dbo.#Emp_Cons (Emp_ID) 

---------- Month Table----------
IF  OBJECT_ID('tempdb..#tblMonthDay') IS NOT NULL 
            DROP TABLE #tblMonthDay  
Create Table #tblMonthDay
(
CurrentDate  Date
)

DECLARE @StartDate AS DATETIME
DECLARE @EndDate AS DATETIME
DECLARE @CurrentDate AS DATETIME

SET @StartDate = cast(CAST(MONTH( @From_Date) as varchar(5))+'-01-'++CAST(year(@From_Date) as varchar(5)) AS datetime)
SET @EndDate = DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0, @From_Date)+1,0))

SET @CurrentDate = @StartDate

WHILE (@CurrentDate < @EndDate)
BEGIN
		INSERT INTO  #tblMonthDay(CurrentDate) SELECT @CurrentDate
    SET @CurrentDate = convert(varchar(30), dateadd(day,1, @CurrentDate), 101); /*increment current date*/
END

--------- End------------


    EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,0 ,0 ,0 ,0 ,0 ,0,0,0,0,@PBranch_ID

    DECLARE @Branch_Id_Cur AS NUMERIC

    -- Added by rohit For Leave Name Showing With Leave Code in Footer on 08082013
    DECLARE @leave_Footer VARCHAR(5000)
    SET @leave_Footer = ''

    SELECT  @leave_Footer = STUFF((SELECT ' ' + s.Leave_name FROM 
    ( SELECT ('  ' + Leave_Code + ' : ' + Leave_name + ' ' ) AS leave_name,Cmp_ID FROM T0040_LEAVE_MASTER
    ) s WHERE s.Cmp_id = t.Cmp_id FOR XML PATH('')),1,1,'')  FROM T0040_LEAVE_MASTER AS t WHERE t.Cmp_ID=@cmp_id GROUP BY t.Cmp_id
  
    
IF @Report_call <> 'Monthly Generate'
    BEGIN   
        IF  OBJECT_ID('tempdb..#Emp_Inout') IS NOT NULL --exists (SELECT 1 FROM [tempdb].dbo.sysobjects WHERE name like '#Emp_Inout' )        
            DROP TABLE #Emp_Inout  
 
        --IF  object_id('Consolidated_Temp') IS NOT NULL 
        -- begin      
        --  drop table Consolidated_Temp  
        -- end  

        --IF  object_id('Leave_Count_Pivot') IS NOT NULL 
        -- begin      
        --  drop table Leave_Count_Pivot  
        -- end  

        --IF  object_id('Final_Table') IS NOT NULL 
        -- begin      
        --  drop table Final_Table  
        -- end  

           
           
        CREATE table #Emp_Inout       
        (      
            emp_id     NUMERIC ,      
            for_Date    DATETIME,      
            Dept_id    NUMERIC null ,      
            Grd_ID    NUMERIC null,      
            Type_ID   NUMERIC null,      
            Desig_ID    NUMERIC null,      
            Shift_ID    NUMERIC null ,      
            In_Time    DATETIME null,      
            Out_Time    DATETIME null,      
            Duration    VARCHAR(20) null,      
            Duration_sec   NUMERIC  null,      
            Late_In    VARCHAR(20) null,      
            Late_Out    VARCHAR(20) null,      
            Early_In    VARCHAR(20) null,      
            Early_Out    VARCHAR(20) null,      
            Leave     VARCHAR(5) null,      
            Shift_Sec    NUMERIC null,      
            Shift_Dur    VARCHAR(20) null,      
            Total_work    VARCHAR(20) null,      
            Less_Work    VARCHAR(20) null,      
            More_Work    VARCHAR(20) null,      
            Reason     VARCHAR(200) null,         
            AB_LEAVE    VARCHAR(50) NULL,      
            Late_In_Sec   NUMERIC null,      
            Late_In_count   NUMERIC null,      
            Early_Out_sec   NUMERIC null,      
            Early_Out_Count  NUMERIC null,      
            Total_Less_work_Sec NUMERIC null,      
            Shift_St_Datetime  DATETIME null,      
            Shift_en_Datetime  DATETIME null,      
            Working_Sec_AfterShift NUMERIC null,      
            Working_AfterShift_Count NUMERIC null ,      
            Leave_Reason   VARCHAR(250) null,      
            Inout_Reason   VARCHAR(250) null,  
            SysDate  DATETIME   ,  
            Total_Work_Sec NUMERIC Null,  
            Late_Out_Sec   NUMERIC null,  
            Early_In_sec   NUMERIC null,
            Total_More_work_Sec NUMERIC null,
            Is_OT_Applicable tinyint null,
            Monthly_Deficit_Adjust_OT_Hrs tinyint null,
            Late_Comm_sec  NUMERIC null,
            Branch_Id NUMERIC default 0,
            Check_by_superior tinyint default 0,
            P_days NUMERIC(18,2) default 0,
            A_days NUMERIC(18,2) default 0,
            Leave_Days NUMERIC(18,2) default 0,
            WeekOff_Days NUMERIC(18,2) default 0,
            Temp_LvDays NUMERIC(18,2) default 0
            
        )     
  
        CREATE NONCLUSTERED INDEX IX_Emp_Inout ON dbo.#Emp_Inout (Emp_ID,for_Date) INCLUDE(In_Time,Out_Time) 
 
    END
  
  --PRINT CONVERT(VARCHAR(20), GETDATE(), 114) + ' STEP 3'
    /********************************************************************
    Added by Nimesh : Using new employee weekoff/holiday stored procedure
    *********************************************************************/
    IF OBJECT_ID('tempdb..#Emp_WeekOff') IS NULL
    BEGIN
        --Holiday & WeekOff - In colon(;) seperated string (Without Cancel) : Used in SP_CALCULATE_PRESENT_DAYS
        CREATE table #Emp_WeekOff_Holiday
        (
            Emp_ID              NUMERIC,
            WeekOffDate         VARCHAR(Max),
            WeekOffCount        NUMERIC(3,1),
            HolidayDate         VARCHAR(Max),
            HolidayCount        NUMERIC(3,1),
            HalfHolidayDate     VARCHAR(Max),
            HalfHolidayCount    NUMERIC(3,1),
            OptHolidayDate      VARCHAR(Max),
            OptHolidayCount     NUMERIC(3,1)
        )
    
        --Holiday - by Date : Used in SP_RPT_EMP_ATTENDANCE_MUSTER_GET_ALL
        CREATE table #EMP_HOLIDAY(EMP_ID NUMERIC, FOR_DATE DATETIME, IS_CANCEL BIT, Is_Half tinyint, Is_P_Comp tinyint, H_DAY NUMERIC(3,1));
        CREATE UNIQUE CLUSTERED INDEX IX_EMP_HOLIDAY_EMPID_FORDATE ON #EMP_HOLIDAY(EMP_ID, FOR_DATE);
    
        --WeekOff - by Date : Used in SP_RPT_EMP_ATTENDANCE_MUSTER_GET_ALL
        CREATE table #Emp_WeekOff
        (
            Row_ID          NUMERIC,
            Emp_ID          NUMERIC,
            For_Date        DATETIME,
            Weekoff_day     VARCHAR(10),
            W_Day           numeric(3,1),
            Is_Cancel       BIT
        )
        CREATE CLUSTERED INDEX IX_Emp_WeekOff_EMPID_FORDATE ON #Emp_WeekOff(Emp_ID,For_Date);
        
        
        --Holiday & Weekoff - In colon(;) seperated string (With Cancel) : Used in SP_CALCULATE_PRESENT_DAYS
        CREATE table #EMP_HW_CONS
        (
            Emp_ID              NUMERIC,
            WeekOffDate         VARCHAR(Max),
            WeekOffCount        NUMERIC(3,1),
            CancelWeekOff       VARCHAR(Max),
            CancelWeekOffCount  NUMERIC(3,1),
            HolidayDate         VARCHAR(MAX),
            HolidayCount        NUMERIC(3,1),
            HalfHolidayDate     VARCHAR(MAX),
            HalfHolidayCount    NUMERIC(3,1),
            CancelHoliday       VARCHAR(Max),
            CancelHolidayCount  NUMERIC(3,1)
        )
        CREATE UNIQUE CLUSTERED INDEX IX_EMP_HW_CONS_EmpID ON #EMP_HW_CONS(Emp_ID)
        
        
        
        EXEC SP_GET_HW_ALL @CONSTRAINT=@CONSTRAINT,@CMP_ID=@Cmp_ID, @FROM_DATE=@FROM_DATE, @TO_DATE=@TO_DATE, @All_Weekoff = 0, @Exec_Mode=0
        
    END
				    
    /********************************************************************
    Added by Nimesh : End of Declaration
    *********************************************************************/
    Exec SP_CALCULATE_PRESENT_DAYS @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@emp_ID,@constraint,4,'',0


  
Insert INTO #Data(emp_id,for_Date)
Select  Emp_ID,CurrentDate From (
select Emp_ID,CurrentDate from  #Emp_Cons Cross join #tblMonthDay
) as E 
Where NOT EXISTS (SELECT 1 from  #Data as I Where  I.emp_id = E.Emp_ID AND I.for_Date = E.CurrentDate)
           
	Insert INTO #Emp_Inout (emp_id,for_Date,In_Time,Out_Time,Duration_sec,P_days,Shift_ID,Shift_St_Datetime,
	Shift_en_Datetime,
	More_Work,
	Total_More_work_Sec,
	A_days
	,Late_In_Sec
	,Early_Out_sec
	,Total_Work_Sec
	,Shift_Sec
	,AB_LEAVE
	 )

	SELECT emp_id,for_Date,In_Time,Out_Time,Duration_in_sec,P_days,Shift_ID,Shift_Start_Time,
	Shift_End_Time, 
	cast(dbo.F_Return_Hours(isnull(OT_Sec,0)+  isnull(Weekoff_OT_Sec,0) + isnull(Holiday_OT_Sec,0))AS Varchar) as More_Work
	,isnull(OT_Sec,0)+  isnull(Weekoff_OT_Sec,0) + isnull(Holiday_OT_Sec,0) as Total_More_work_Sec,
	
	----CASE When P_days >0 then 0 else 1 end   as A_days
	---CASE WHEN for_Date < getdate() then (CASE When P_days >0 then 0 else 1 end ) else 0 end as A_days
	CASE WHEN for_Date < getdate() then (CASE When P_days >0 then 1-P_days else 1 end ) else 0 end as A_days
	
	
	,CASE WHEN datediff(s,In_Time,Shift_Start_Time)< 0 THEN  datediff(s,In_Time,Shift_Start_Time)*-1 ELSE 0 End as Late_In_Sec
	,CASE WHEN datediff(s,OUT_Time,Shift_End_Time)>= 0 THEN  datediff(s,OUT_Time,Shift_End_Time) ELSE 0 End  as Early_Out_sec
	,Duration_in_sec
	,Shift_Dur
	,CASE WHEN for_Date < getdate() then NULL else '-' end as AB_LEAVE
	from #Data left OUTER JOIN
	(	SELECT Shift_ID as Sh_ID,dbo.F_Return_Sec(Shift_Dur)as Shift_Dur 
		from T0040_SHIFT_MASTER 
	)as SM
		On #Data.Shift_ID = SM.Sh_ID 
    
    Update #Emp_Inout SET Shift_ID= DATA.Shift_ID ,Shift_Sec =DATA.Shift_Sec 
    ,Shift_St_Datetime=DATA.Shift_St_Datetime,
	Shift_en_Datetime=DATA.Shift_en_Datetime
     From #Emp_Inout AS E Inner Join 
    (
    select  ROW_NUMBER() OVER(PARTITION BY emp_id ORDER BY for_Date DESC) 
    AS Row#, emp_id,Shift_ID,Shift_Sec,for_Date,Shift_St_Datetime,Shift_en_Datetime from #Emp_Inout
    where isnull(Shift_ID,0)>0
    ) as DATA 
    ON E.emp_id = DATA.emp_id
    And((E.A_days >0 AND isnull(E.Shift_ID,0) =0 AND E.for_Date < DATA.for_Date)OR (E.for_Date Between DATA.for_Date and GETDATE()))
    Where Row#=1

    Update #Emp_Inout SET Total_Less_Work_Sec	= 
										 Case WHEN isnull(Total_Work_Sec,0) <Isnull(Shift_Sec,0)  Then 
										Isnull(Shift_Sec,0)-isnull(Total_Work_Sec,0)
										ELSE 0
										End
										Where Total_Work_Sec >0  OR Shift_Sec>0
           
	UPDATE #Emp_Inout SET Dept_id = Inc_Qry.Dept_id,Grd_ID = Inc_Qry.Grd_ID,
	Type_ID = Inc_Qry.Type_ID ,Desig_ID =Inc_Qry.Desig_ID ,Branch_ID=Inc_Qry.Branch_ID
	,Duration= cast(dbo.F_Return_Hours((Duration_sec)) AS Varchar)
	,Total_work= cast(dbo.F_Return_Hours(Duration_sec) AS Varchar)
	From  #Emp_Inout AS A Inner JOIN 
	( SELECT    I.Emp_Id ,Type_ID ,Grd_ID,Dept_ID,Desig_Id,Isnull(Emp_Late_Limit,'00:00') AS Emp_Late_Limit,
							Isnull(Emp_Early_Limit,'00:00') AS Emp_Early_Limit,Isnull(Emp_OT,0) AS Emp_OT,
							Isnull(Emp_OT_Min_Limit,'00:00') AS Emp_OT_Min_Limit,Isnull(Emp_OT_Max_Limit,'00:00') AS Emp_OT_Max_Limit, Monthly_Deficit_Adjust_OT_Hrs,
							Branch_ID,Isnull(Emp_Late_mark,0) Emp_Late_mark, Isnull(Emp_Early_mark,0) Emp_Early_mark
				FROM    dbo.T0095_INCREMENT I inner join       
							( SELECT    max(I.Increment_ID) AS Increment_ID, I.Emp_ID FROM dbo.T0095_INCREMENT I Inner Join #Emp_Cons EC on I.Emp_ID = EC.Emp_ID     -- Ankit 11092014 for Same Date Increment     
							WHERE   Increment_effective_Date <= @To_Date and Cmp_ID = @Cmp_ID      
							group by I.emp_ID  ) Qry on I.Emp_ID = Qry.Emp_ID and      
						i.Increment_ID   = Qry.Increment_ID        
				WHERE Cmp_ID = @Cmp_ID ) Inc_Qry
	on A.Emp_ID = Inc_Qry.Emp_ID 

UPDATE  #Emp_Inout SET AB_LEAVE ='WO' ,A_days =0,WeekOff_Days=1 
	,Shift_ID= NULL 
	,Shift_Sec =0
    ,Shift_St_Datetime=NULL,
	Shift_en_Datetime=NULL
FROM  #Emp_Inout AS EI Inner JOIN
#Emp_WeekOff as W ON EI.emp_id = W.Emp_ID And EI.for_Date = W.For_Date
	
-------------- Holiday / Week Off -----------


IF  OBJECT_ID('tempdb..#EmpHoliday') IS NOT NULL 
            DROP TABLE #EmpHoliday  
Create table #EmpHoliday
(
Emp_Id  int,
HoDate  date
)
DECLARE @iEmp_Id int  
DECLARE @dHolidaydate varchar(4000)  

DECLARE CurHolidayDt CURSOR FOR 
select Emp_ID,HolidayDate as HoDate from #EMP_HW_CONS

OPEN CurHolidayDt  
FETCH NEXT FROM CurHolidayDt INTO @iEmp_Id,  @dHolidaydate

WHILE @@FETCH_STATUS = 0  
BEGIN  
      Insert INTO #EmpHoliday(Emp_Id,HoDate)
      select @iEmp_Id,data from dbo.Split((SELECT HolidayDate from #EMP_HW_CONS where Emp_ID = @iEmp_Id), ';')
      FETCH NEXT FROM CurHolidayDt INTO @iEmp_Id,  @dHolidaydate 
END 

CLOSE CurHolidayDt  
DEALLOCATE CurHolidayDt 
--------------------End Holiday Cursor---------------------
UPDATE  #Emp_Inout SET AB_LEAVE ='HO' ,A_days =0 FROM  #Emp_Inout AS EI 
Inner JOIN
(select Emp_ID,HoDate as HoDate from #EmpHoliday )as HO
ON EI.emp_id = HO.Emp_ID And EI.for_Date= cast(HO.HoDate as date)
	
-------- Leave Details ------------

Update E SET AB_LEAVE = 
case when left(Leave_Desc ,1)='-' Then replace(Leave_Desc ,'-','')else Leave_Desc End

,A_days= case When E.AB_LEAVE LIKE '%WO%' THEN 0 ELSE  
1-(ISNULL(E.P_days,0)+Isnull(Leave_Used,0))
END 

,Leave_Days=Isnull(Leave_Used,0)
,WeekOff_Days = CASE WHEN E.AB_LEAVE LIKE '%WO%' THEN WeekOff_Days-Leave_Used ELSE 0 END
,Temp_LvDays =Leave_Used_1
FROM #Emp_Inout E INNER JOIN
(select 
ROW_NUMBER() over( PARTITION BY Emp_ID,For_Date  ORDER BY For_Date,Leave_Desc desc) as RowNo,
Emp_ID,For_Date,Left(Leave_Desc,LEN(Leave_Desc)-1)as Leave_Desc,

case When Isnull(sum(Leave_Used),0)>1 THEN 1 ELSE Isnull(sum(Leave_Used),0)END as Leave_Used 

,Case When Isnull(sum(Leave_Used_1),0)>1 THEN 1 ELSE Isnull(sum(Leave_Used_1),0)END as Leave_Used_1 

from 
(
SELECT p1.Emp_ID,p1.For_Date,
	Case When Lm.Leave_Code like '%LWP%' AND p1.Leave_Used =1 THEN 0 ELSE 
    CASE WHEN  LM.APPLY_HOURLY =1 THEN (p1.Leave_Used*.125) ELSE  isnull(Leave_Used,0)+isnull(Compoff_Used,0) END  END  Leave_Used,
     
    Case When Lm.Leave_Code like '%LWP%' AND p1.Leave_Used < 1 THEN  isnull(Leave_Used,0) ELSE 
    CASE WHEN  LM.APPLY_HOURLY =1 THEN (p1.Leave_Used*.125) ELSE  0 END END  Leave_Used_1,
    
      Case IsNULL(Leave_Assign_As,'')  When  'First Half' Then 'FH' When 'Second Half' Then 'SH' Else '' END  
	  +Case When IsNULL(Leave_Assign_As,'')='' then '' else '-' End
      +( SELECT Leave_Code + ' ' + 
        Case When isnull(Apply_Hourly,0)=0 then '' else 
       left(CAST (A.Leave_Used as varchar(10)),4) 
       +CASE WHEN isnull(Apply_Hourly,0)=0 then ' ' ELSE '0 Hrs' End end +'/'
         from  T0140_Leave_Transaction AS A 
          Left Outer JOIN T0040_LEAVE_MASTER P2
          On A.Leave_ID = P2.Leave_ID
          Where
           A.Emp_ID = P1.Emp_ID
          AND A.For_Date = P1.For_Date
          AND A.Leave_Used +A.CompOff_Used >0
          ORDER BY Leave_Code
            FOR XML PATH('') ) 
            AS Leave_Desc
      FROM T0140_Leave_Transaction p1
      Inner JOIN #Emp_Cons  On #Emp_Cons.Emp_ID =p1.emp_id
      Left Outer JOIN T0040_LEAVE_MASTER LM
      On p1.Leave_ID = LM.Leave_ID
      LEFT outer JOIN 
      (Select Emp_ID,LD.From_Date, Leave_Assign_As  From T0120_LEAVE_APPROVAL US Inner Join  
		T0130_LEAVE_APPROVAL_DETAIL LD On US.Leave_Approval_ID = LD.Leave_Approval_ID 
    	) as Q
		ON p1.Emp_ID = Q.Emp_ID And p1.For_Date = Q.From_Date
	  where p1.Leave_Used+Compoff_Used >0
	  
      GROUP BY p1.Emp_ID,p1.For_Date,LM.APPLY_HOURLY,Leave_Code,Leave_Used,Compoff_Used,Leave_Assign_As 
 ) as Qry 
 group BY Emp_ID,For_Date,Leave_Desc 
)as TLeave 
ON E.emp_id = TLeave.Emp_ID And E.for_Date = TLeave.For_Date 
WHERE RowNo =1


Update #Emp_Inout SET A_days =Leave_Days-Temp_LvDays,Leave_Days= Temp_LvDays  
Where AB_LEAVE LIKE '%LWP%' AND Temp_LvDays>0 AND WeekOff_Days = 0

Update #Emp_Inout SET A_days =Leave_Days ,Leave_Days=0   Where AB_LEAVE LIKE '%LWP%' AND WeekOff_Days>0

Update #Emp_Inout SET P_days=0,A_days=0,Leave_Days=0,WeekOff_Days=0,AB_LEAVE='-'
From  #Emp_Inout AS A Inner JOIN 
T0080_EMP_MASTER As B On A.emp_id = B.Emp_ID
Where A.for_Date < B.Date_Of_Join 

Update #Emp_Inout SET P_days=0,A_days=0,Leave_Days=0,WeekOff_Days=0,AB_LEAVE='-'
From  #Emp_Inout AS A Inner JOIN 
T0080_EMP_MASTER As B On A.emp_id = B.Emp_ID
Where A.for_Date > B.Emp_Left_Date 

/*

Update E SET AB_LEAVE = Leave_Assign_As
--,A_days=0
,A_days=PartLeaveAB+Case When (Leave_Assign_As like '%LWP-FH%' OR Leave_Assign_As like '%LWP-SH%') Then 0.5 else 0 End
FROM #Emp_Inout E INNER JOIN
(
SELECT A.Emp_ID,A.Leave_ID,A.For_Date,

CASE WHEN  LM.APPLY_HOURLY =1 And A.LEAVE_USED >= 8 THEN 1 else 
CASE WHEN  LM.APPLY_HOURLY =1 THEN 1 -(A.Leave_Used*.125) ELSE 0 END END AS PartLeaveAB

,CASE WHEN Isnull(B.Leave_Assign_As,'') ='' THEN 
	ISNULL(LM.Leave_Code,'')+' '+CASE WHEN A.Leave_Used < 0.50 OR isnull(Apply_Hourly,0)=1   THEN Replace(CAST(A.Leave_Used as varchar),'0','') ELSE  '' END 
	+CASE WHEN isnull(Apply_Hourly,0)=0 then ' ' ELSE '0 Hrs' End
ELSE
	Isnull(B.Leave_Assign_As,'')
END AS  Leave_Assign_As 


from T0140_Leave_Transaction AS A LEFT OUTER JOIN
(
Select Emp_id,From_Date,Half_Leave_Date ,
(
		SELECT 
		
		LM.Leave_Code+'-' + Case IsNULL(Leave_Assign_As,'')  When  'First Half' Then 'FH' When 'Second Half' Then 'SH' Else '' END +';' 
		FROM T0120_LEAVE_APPROVAL US Inner Join  
		T0130_LEAVE_APPROVAL_DETAIL LD On US.Leave_Approval_ID = LD.Leave_Approval_ID 
		
		INNER JOIN T0040_LEAVE_MASTER AS LM ON LM.Leave_ID = LD.Leave_ID  
		WHERE US.Emp_ID = LA.Emp_ID And LD.From_Date = LAD.From_Date 
		FOR XML PATH('')) Leave_Assign_As
		from dbo.T0120_LEAVE_APPROVAL LA 
		Inner Join  
		T0130_LEAVE_APPROVAL_DETAIL LAD On LA.Leave_Approval_ID = LAD.Leave_Approval_ID
		WHERE Approval_Status = 'A'
		AND NOT Exists(SELECT Leave_Approval_ID FROM dbo.T0150_LEAVE_CANCELLATION as  LC 
		WHERE LC.cmp_id=LA.cmp_id AND LC.Emp_Id = LA.Emp_Id and LC.Is_Approve=1)
		GROUP BY LA.Emp_ID,From_Date,Half_Leave_Date ,LAD.Leave_Period 

)AS B
on A.emp_id = B.Emp_id  
And A.For_Date= isnull(B.Half_Leave_Date,B.From_Date)
INNER JOIN T0040_LEAVE_MASTER AS LM ON LM.Leave_ID = A.Leave_ID 
Inner JOIN #Emp_Cons  On #Emp_Cons.Emp_ID =A.emp_id
WHERE A.For_Date >=@FROM_DATE And A.For_Date <=@to_date
AND A.Leave_Used>0
)as TLeave 
ON E.emp_id = TLeave.Emp_ID And E.for_Date = TLeave.For_Date 
*/
---------- End Leave -------------

---select * from #Emp_Inout
 /* -----13-Nov-2019----  
     
    DECLARE CUR_EMP CURSOR FOR      
    SELECT  E.EMP_ID,Inc_Qry.Grd_ID,Inc_Qry.Type_ID,Inc_Qry.Dept_ID,Inc_Qry.Desig_ID,
            dbo.F_Return_Sec(Inc_Qry.Emp_Late_Limit),dbo.F_Return_Sec(Inc_Qry.Emp_Early_Limit),
            Emp_OT,dbo.F_Return_Sec(Inc_Qry.Emp_OT_Min_Limit),dbo.F_Return_Sec(Inc_Qry.Emp_OT_Max_Limit),Isnull(Monthly_Deficit_Adjust_OT_Hrs,0),Inc_Qry.Branch_ID,
            Emp_Late_mark, Emp_Early_mark
    FROM    dbo.T0080_EMP_MASTER E Inner join #Emp_Cons EC on E.Emp_ID = EC.Emp_ID Inner join       
            ( SELECT    I.Emp_Id ,Type_ID ,Grd_ID,Dept_ID,Desig_Id,Isnull(Emp_Late_Limit,'00:00') AS Emp_Late_Limit,
                Isnull(Emp_Early_Limit,'00:00') AS Emp_Early_Limit,Isnull(Emp_OT,0) AS Emp_OT,
                        Isnull(Emp_OT_Min_Limit,'00:00') AS Emp_OT_Min_Limit,Isnull(Emp_OT_Max_Limit,'00:00') AS Emp_OT_Max_Limit, Monthly_Deficit_Adjust_OT_Hrs,
                        Branch_ID,Isnull(Emp_Late_mark,0) Emp_Late_mark, Isnull(Emp_Early_mark,0) Emp_Early_mark
            FROM    dbo.T0095_INCREMENT I inner join       
                        ( SELECT    max(I.Increment_ID) AS Increment_ID, I.Emp_ID FROM dbo.T0095_INCREMENT I Inner Join #Emp_Cons EC on I.Emp_ID = EC.Emp_ID     -- Ankit 11092014 for Same Date Increment     
                        WHERE   Increment_effective_Date <= @To_Date and Cmp_ID = @Cmp_ID      
                        group by I.emp_ID  ) Qry on I.Emp_ID = Qry.Emp_ID and      
                    i.Increment_ID   = Qry.Increment_ID        
            WHERE Cmp_ID = @Cmp_ID ) Inc_Qry on e.Emp_ID = Inc_Qry.Emp_ID       
           
    WHERE   E.Cmp_ID = @Cmp_ID       
    
    OPEN  CUR_EMP      
    FETCH NEXT FROM CUR_EMP INTO @EMP_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Late_Comm_sec,@Early_Limit_Sec,@Emp_OT,@Emp_OT_Min_Limit_Sec,@Emp_OT_Max_Limit_Sec,@Monthly_Deficit_Adjust_OT_Hrs,@Branch_Id_Cur,@Emp_Late_Mark,@Emp_Early_Mark
    WHILE @@FETCH_STATUS = 0      
        BEGIN      
            --PRINT CONVERT(VARCHAR(20), GETDATE(), 114) + ' STEP 5:001'
            SET @varWeekoff_Date = ''      
            SET @varHoliday_Date = ''       
            SET @Last_out_Date  = null      
            SET @out_Date = null      
            SET @in_Date = null      
            SET @Last_Entry_For_check = null      
            SET @Pre_Inout_Flag = ''      
            SET @Pre_Shift_St_DateTime = null      
            SET @Pre_Shift_en_DateTime = null      
            SET @Working_Sec_AfterShift = 0      
            SET @Working_AfterShift_Count = 0       
                
            SET @Temp_Month_Date = @From_Date      
                
            SET @insert_In_date = null      
            SET @insert_Out_Date = null      
            SET @Pre_In_Date = null      
              
            SET @strOnlyHoliday_date = ''      
            SET @Total_Holiday_Date = ''      
            SET @Total_LeaveDay_Date  = ''      
            SET @varWeekoff_Date = ''      
            SET @StrHoliday_Date = ''      
            SET @StrWeekoff_Date = ''      
            SET @Holiday_Days  = 0      
            SET @Weekoff_Days  = 0      
            SET @Cancel_Holiday  = 0      
            SET @Cancel_Weekoff  = 0      
            SET @StrCancelWeekoff_Date = ''
            SET @StrCancelHoliday_Date = ''
            SET @Weekoff_Date1_CancelStr = ''

            --Added by Hardik 22/11/2011 for Night shift Min In and Max Out Record
            DECLARE @Min_In DATETIME 
            DECLARE @Max_Out AS DATETIME
            DECLARE @hh AS int
            DECLARE @mi AS int
            DECLARE @Shift_St_Time1 AS DATETIME
            DECLARE @Shift_End_Time1 AS DATETIME
            DECLARE @For_Date1 AS DATETIME
            DECLARE @For_Date2 AS DATETIME
            DECLARE @Max_Date AS DATETIME
			DECLARE @Reason1 AS VARCHAR(150)

            --- End for Hardik 
        

            DECLARE @Temp_End_Date AS DATETIME       
            --SET @Temp_End_Date = Dateadd(d,1,@To_Date)      
            SET @Temp_End_Date = @To_Date      

            exec dbo.SP_EMP_JOIN_LEFT_DATE_GET @Emp_ID ,@Cmp_ID ,@From_Date,@To_date,@Join_Date output,@Left_Date output

            --PRINT CONVERT(VARCHAR(20), GETDATE(), 114) + ' STEP 5:002'
            DECLARE @First_In_Last_Out_For_InOut_Calculation tinyint
            DECLARE @Tras_Weekoff_OT AS tinyint
            DECLARE @Is_Late_Mark AS tinyint

            SET @First_In_Last_Out_For_InOut_Calculation = 0 
            SET @Tras_Weekoff_OT = 0



            SELECT @First_In_Last_Out_For_InOut_Calculation= isnull(First_In_Last_Out_For_InOut_Calculation,0),@Tras_Weekoff_OT = Isnull(tras_week_ot,0),
                @Is_Cancel_weekoff = Isnull(Is_Cancel_Weekoff,0),@Is_Cancel_Holiday = Isnull(Is_Cancel_Holiday,0),@Is_Late_Mark = Isnull(Is_Late_Mark,0)
            from dbo.T0040_GENERAL_SETTING WHERE Cmp_ID = @Cmp_ID and Branch_ID = (SELECT Branch_ID FROM dbo.T0080_EMP_MASTER WHERE Emp_ID=@Emp_ID)

            --PRINT CONVERT(VARCHAR(20), GETDATE(), 114) + ' STEP 5:003'
            --Exec dbo.SP_EMP_WEEKOFF_DATE_GET @Emp_ID,@Cmp_ID,@From_Date,@To_Date,@Join_Date,@left_Date,@Is_Cancel_weekoff,@StrHoliday_Date,@StrWeekoff_Date output,@Weekoff_Days output ,@Cancel_Weekoff output   ,0 ,0 ,0,@Weekoff_Date1_CancelStr OUTPUT    
            SELECT @StrWeekoff_Date = WeekOffDate, @Weekoff_Days=WeekOffCount, @Cancel_Weekoff=CancelWeekOffCount, @Weekoff_Date1_CancelStr=CancelWeekOff FROM #EMP_HW_CONS WHERE EMP_ID=@Emp_ID
            --Exec dbo.SP_EMP_HOLIDAY_DATE_GET @Emp_ID,@Cmp_ID,@From_Date,@To_Date,@Join_Date,@left_Date,@Is_Cancel_Holiday,@StrHoliday_Date output,@Holiday_days output,@Cancel_Holiday output,0,@Branch_ID,@StrWeekoff_Date  ,0,0,@StrCancelHoliday_Date OUTPUT
            SELECT @StrHoliday_Date = HolidayDate, @Holiday_days=HolidayCount, @Cancel_Holiday=CancelHolidayCount, @StrCancelHoliday_Date=CancelHoliday FROM #EMP_HW_CONS WHERE EMP_ID=@Emp_ID
            
            
            /*
			  Following Code Added By Nimesh On 27-Jul-2018
              If WeekOff Or Holiday is getting cancelled due to Sandwich Policy 
              Then Report should not display the WO and it should be count in Absent Days
            */
            if len(@Weekoff_Date1_CancelStr) > 0
				SELECT @StrWeekoff_Date = REPLACE(@StrWeekoff_Date, DATA + ';', '') FROM dbo.Split(@Weekoff_Date1_CancelStr, ';') T where data <> ''
				
				
			if len(@StrCancelHoliday_Date) > 0
				SELECT @StrHoliday_Date = REPLACE(@StrHoliday_Date, DATA + ';', '') FROM dbo.Split(@StrCancelHoliday_Date, ';') T where data <> ''
                        			

            SELECT @StrCancelWeekoff_Date = COALESCE ( @StrCancelWeekoff_Date + ';', '') + DATA FROM dbo.Split(@Weekoff_Date1_CancelStr,';') 
            WHERE Data <> '' AND NOT EXISTS ( SELECT For_date FROM T0100_WEEKOFF_ROSTER WHERE Emp_id = @Emp_ID AND is_Cancel_WO = 1 AND For_date = CAST(DATA AS DATETIME ) )
            
            DECLARE @HalfDayDate VARCHAR(500)
            exec dbo.GET_HalfDay_Date @Cmp_ID,@Emp_ID,@From_Date,@To_Date,0,@HalfDayDate output    


			
            --IF @StrCancelWeekoff_Date <> ''
            --    SET @StrWeekoff_Date = @StrWeekoff_Date + @StrCancelWeekoff_Date

            --IF @StrCancelHoliday_Date <> ''
            --    SET @StrHoliday_Date = @StrHoliday_Date + @StrCancelHoliday_Date    
            
            --PRINT CONVERT(VARCHAR(20), GETDATE(), 114) + ' STEP 5:004'
            WHILE @Temp_Month_Date <= @Temp_End_Date      
                BEGIN      
                    SET @shift_ID = 0      
                    --PRINT CONVERT(VARCHAR(20), GETDATE(), 114) + ' STEP 5:005'
                    Exec dbo.SP_CURR_T0100_EMP_SHIFT_GET @emp_id,@Cmp_ID,@Temp_Month_Date,@Shift_St_Time output,@Shift_End_Time output,@Shift_Dur output,null,@Second_Break_Duration Output,@Third_Break_Duration  output,null,@shift_ID output      
                    --PRINT CONVERT(VARCHAR(20), GETDATE(), 114) + ' STEP 5:006'
                    SET @Shift_Sec = 0     
                    SET @Shift_Sec  = dbo.F_Return_Sec(@Shift_Dur)      
                    SET @Shift_St_Sec = dbo.F_Return_Sec(@Shift_St_Time)      
                    SET @Shift_En_Sec = dbo.F_Return_Sec(@Shift_End_Time)      
          				    
                    --Ankit 12112013
                    SET @Second_Break_Duration_Sec = 0
                    SET @Third_Break_Duration_Sec = 0
                    SET @Second_Break_Duration_Sec = dbo.F_Return_Sec(@Second_Break_Duration)
                    SET @Third_Break_Duration_Sec = dbo.F_Return_Sec(@Third_Break_Duration)

                    --Ankit 12112013     
                        
                    SET @Leave_Name = ''  
                    SET @Leave_Reason = ''  
                    SET @Leave_ID = 0  
                    SET @Leave_Period = 0
                    SET @Half_Leave_Date = ''
                    SET @Leave_Assign_As =''

                    SET @Fix_OT = 86400 - @Shift_Sec       
                    SET @Day_St_Time = cast(cast(@Temp_Month_Date AS VARCHAR(11)) + ' ' + '00:00'  AS SMALLDATETIME)  
                    SET @Shift_St_Datetime = cast(cast(@Temp_Month_Date AS VARCHAR(11)) + ' ' + @Shift_St_Time AS SMALLDATETIME)      
                    SET @Temp_Date = dateadd(d,1,@Temp_Month_Date)      
                    SET @Day_End_Time = cast(cast(@Temp_Date AS VARCHAR(11)) + ' ' + '00:00'  AS SMALLDATETIME)      
                    IF @Shift_St_Sec > @Shift_En_Sec       
                        SET @Shift_End_DateTime = cast(cast(@Temp_Date AS VARCHAR(11)) + ' ' + @Shift_End_Time  AS SMALLDATETIME)      
                    ELSE      
                        SET @Shift_End_DateTime = cast(cast(@Temp_Month_Date AS VARCHAR(11)) + ' ' + @Shift_End_Time  AS SMALLDATETIME)      
                         
                    SET @Insert_IN_DATE = NULL      
                    SET @Insert_Out_DATE = NULL      


                    IF @Report_call ='Inout_Page' --added by Hardik 13/10/2012 for In Out Record Page
                        SET @First_In_Last_Out_For_InOut_Calculation = 0
                    
                    --PRINT CONVERT(VARCHAR(20), GETDATE(), 114) + ' STEP 5:007'
                    IF @First_In_Last_Out_For_InOut_Calculation = 1
                        Begin      
                        
                            -- Hardik 14/08/2012 for Night Shift Checking...
                            --IF CONVERT(VARCHAR(5), @Shift_St_Time, 108) < CONVERT(VARCHAR(5), @Shift_End_Time, 108)
                            DECLARE cur_Inout cursor for       
                            -- SELECT Min(In_time),Max(Out_Time),Reason FROM dbo.T0150_emp_inout_record WHERE Emp_ID =@Emp_ID and For_Date = @Temp_Month_Date    
                            --group by Reason
                            SELECT Min(In_time),
                                    Case When Max_In > Max(Out_Time) Then Max_In Else Max(Out_time) End ,Reason 
                            FROM    dbo.T0150_emp_inout_record e Inner Join
                                    (SELECT Max(In_time) Max_In,Emp_Id,For_Date FROM dbo.T0150_emp_inout_record WHERE Emp_ID =@Emp_ID 
                                        and For_Date = @Temp_Month_Date Group by Emp_ID,For_Date) m
                                    on e.Emp_ID = M.Emp_ID and E.For_Date = M.For_Date
                            Where   E.Emp_ID =@Emp_ID and E.For_Date = @Temp_Month_Date
                            group by Reason,Max_In                              
                                                    
                        END
                    ELSE
                        BEGIN

                        -- Hardik 14/08/2012 for Night Shift Checking...
                        --IF CONVERT(VARCHAR(5), @Shift_St_Time, 108) < CONVERT(VARCHAR(5), @Shift_End_Time, 108)
                            DECLARE cur_Inout cursor for       
                         
                            SELECT In_time,Out_Time,Reason FROM dbo.T0150_emp_inout_record 
                            WHERE Emp_ID =@Emp_ID and For_Date = @Temp_Month_Date      
                            order by isnull(In_time,Out_time),Out_time,Reason   
                         
                        --Else          
                        --  Begin
                        --    DECLARE cur_Inout cursor for       
                        --     SELECT In_time,Out_Time,Reason FROM T0150_emp_inout_record WHERE Emp_ID =@Emp_ID 
                        --      and In_Time >= Dateadd(hh,-2,@Shift_St_Datetime) And
                        --          Out_Time <= Dateadd(hh,2,@Shift_End_Datetime)
                        --      order by isnull(In_time,Out_time),Out_time,Reason      
                        --  End
                        END
                
                OPEN cur_inout      
                FETCH NEXT FROM cur_inout INTO @Insert_In_Date,@Insert_Out_Date,@Reason      
                
                WHILE @@FETCH_STATUS = 0      
                    BEGIN      
                        --PRINT CONVERT(VARCHAR(20), GETDATE(), 114) + ' STEP 5:007:001'
                        SET @working_sec = 0      
                        SET @Ot_sec = 0      
                        SET @holiday_work_sec = 0      
                        SET @Late_In = ''      
                        SET @Late_Out =''      
                        SET @Early_In = ''      
                        SET @Early_Out = ''      
                        SET @WORKING_HOURS = ''      
                        SET @INSERT_COUNT = 0      
                            
                        SET @Late_In_sec = 0      
                        SET @Late_Out_Sec = 0      
                        SET @Early_In_sec = 0      
                        SET @Early_Out_sec = 0      
                        SET @Toatl_Working_sec = 0      
                        SET @Less_Work = ''      
                        SET @More_Work = ''      
                        SET @Total_work = ''      
                        SET @late_in_count = 0      
                        SET @Early_Out_Count = 0      
                        SET @Total_less_work_sec = 0      
                        SET @Total_More_work_sec = 0

                            
                        SET @Working_sec = datediff(s,@Insert_In_Date,@Insert_Out_Date)      

                        IF datediff(s,@Insert_In_Date,@Shift_St_Datetime) > 0       
                            SET @Early_In_Sec = datediff(s,@Insert_In_Date,@Shift_St_Datetime)      
                        IF datediff(s,@Insert_In_Date,@Shift_St_Datetime) < 0       
                            SET @late_In_Sec = datediff(s,@Insert_In_Date,@Shift_St_Datetime)      
                        IF datediff(s,@Insert_Out_Date,@Shift_End_Datetime) > 0       
                            SET @Early_Out_Sec = datediff(s,@Insert_Out_Date,@Shift_End_Datetime)      
                        IF datediff(s,@Insert_Out_Date,@Shift_End_Datetime) < 0       
                            SET @Late_Out_Sec = datediff(s,@Insert_Out_Date,@Shift_End_Datetime)      

                        SET @late_In_Sec  = @late_In_Sec * -1      
                        SET @Late_Out_Sec  = @Late_Out_Sec * -1      

                        -- Commented by Hardik 17/08/2012                          
                        --exec Return_Without_Sec @late_in_sec ,@late_in_sec output      
                        --exec Return_Without_Sec @late_out_sec ,@late_out_sec output      
                        --exec Return_Without_Sec @Early_In_Sec ,@Early_In_Sec output      
                        --exec Return_Without_Sec @Early_Out_Sec ,@Early_Out_Sec output      
                        --exec Return_Without_Sec @Working_sec ,@Working_sec output       
                                    
                        IF @Is_Late_Mark = 0 Or @Emp_Late_Mark = 0
                            Begin
                                SET @late_in_sec  = 0
                                SET @late_out_sec  = 0
                            End
                         
                        IF @Is_Late_Mark = 0 Or @Emp_Early_Mark = 0
                            Begin
                                SET @Early_In_Sec  = 0
                                SET @Early_Out_Sec  = 0
                    End

                        IF @Late_Comm_sec >=  @late_in_sec   SET @late_in_sec  = 0      
                        IF @Late_Comm_sec >=  @late_out_sec  SET @late_out_sec  = 0      
                        IF @Early_Limit_sec >=  @Early_In_Sec  SET @Early_In_Sec  = 0      
                        IF @Early_Limit_sec >=  @Early_Out_Sec SET  @Early_Out_Sec  = 0      

                        IF @late_in_sec  > 0  exec dbo.Return_DurHourMin  @late_In_Sec ,@late_In output       
                        IF @late_out_sec > 0  exec dbo.Return_DurHourMin  @late_Out_Sec ,@late_Out output       

                        IF @Early_In_Sec  > 0 exec dbo.Return_DurHourMin  @Early_In_Sec ,@Early_In output       
                        IF @Early_Out_Sec > 0 exec dbo.Return_DurHourMin  @Early_Out_Sec ,@Early_Out output       
                        IF @Working_sec > 0 exec dbo.Return_DurHourMin  @Working_Sec ,@WORKING_HOURS output        
               
  
                        SET @Toatl_Working_sec = isnull(@Toatl_Working_sec,0) + @Working_sec      
          
                        --Ankit Start 12112013
                        DECLARE @DeduHour_SecondBreak AS tinyint
                        DECLARE @DeduHour_ThirdBreak AS tinyint
                        DECLARE @S_St_Time AS VARCHAR(10)      
                        DECLARE @S_End_Time AS VARCHAR(10)     
                        DECLARE @T_St_Time AS VARCHAR(10)      
                        DECLARE @T_End_Time AS VARCHAR(10)     
                        DECLARE @Shift_S_ST_DateTime AS DATETIME
                        DECLARE @Shift_S_End_DateTime AS DATETIME      
                        DECLARE @Shift_T_ST_DateTime AS DATETIME     
                        DECLARE @Shift_T_End_DateTime AS DATETIME      
                        DECLARE @Shift_Max_Outtime AS DATETIME

                        --PRINT CONVERT(VARCHAR(20), GETDATE(), 114) + ' STEP 5:007:002'
                        SELECT @DeduHour_SecondBreak = DeduHour_SecondBreak,@DeduHour_ThirdBreak = DeduHour_ThirdBreak ,@S_St_Time=S_St_Time,@S_End_Time=S_End_Time,@T_St_Time=T_St_Time,@T_End_Time=T_End_Time
                        From dbo.T0040_SHIFT_MASTER WHERE Cmp_ID=@Cmp_ID And Shift_ID=@SHIFT_ID
                            
                        SET @Shift_S_ST_DateTime = cast(cast(@Temp_Month_Date AS VARCHAR(11)) + ' ' + @S_St_Time AS SMALLDATETIME)
                        SET @Shift_S_End_DateTime = cast(cast(@Temp_Month_Date AS VARCHAR(11)) + ' ' + @S_End_Time AS SMALLDATETIME)
                        SET @Shift_T_ST_DateTime = cast(cast(@Temp_Month_Date AS VARCHAR(11)) + ' ' + @T_St_Time AS SMALLDATETIME)
                        SET @Shift_T_End_DateTime = cast(cast(@Temp_Month_Date AS VARCHAR(11)) + ' ' + @T_End_Time AS SMALLDATETIME)


                        IF @DeduHour_SecondBreak = 1 And  @DeduHour_ThirdBreak = 1 
                            Begin       
                                IF @DeduHour_SecondBreak = 1 And @Insert_In_Date < @Shift_S_ST_DateTime And @Insert_Out_DATE > @Shift_S_ST_DateTime
                                    SET @Toatl_Working_sec = @Toatl_Working_sec - @Second_Break_Duration_Sec
                                IF @DeduHour_ThirdBreak = 1 And @Insert_In_Date < @Shift_T_ST_DateTime And @Insert_Out_DATE > @Shift_T_ST_DateTime
                                    SET @Toatl_Working_sec = @Toatl_Working_sec - @Third_Break_Duration_Sec 
                            End 
                        Else IF @DeduHour_SecondBreak = 1 And @Insert_In_Date < @Shift_S_ST_DateTime And @Insert_Out_DATE > @Shift_S_ST_DateTime
                            SET @Toatl_Working_sec = @Toatl_Working_sec - @Second_Break_Duration_Sec
                        Else IF @DeduHour_ThirdBreak = 1 And @Insert_In_Date < @Shift_T_ST_DateTime And @Insert_Out_DATE > @Shift_T_ST_DateTime
                            SET @Toatl_Working_sec = @Toatl_Working_sec - @Third_Break_Duration_Sec
                                    
                     --PRINT CONVERT(VARCHAR(20), GETDATE(), 114) + ' STEP 5:007:003'
                        --Ankit End 12112013  
                                   
                        IF @Toatl_Working_sec > 0 exec dbo.Return_DurHourMin  @Toatl_Working_sec ,@Total_work output         
                            
                        IF @Insert_IN_Date > @Shift_End_datetime      
                            BEGIN      
                                SET @Working_Sec_AfterShift   =  @Working_sec + @Working_Sec_AfterShift      
                                SET @Working_AfterShift_Count =  1      
                            END      
      
                        --PRINT CONVERT(VARCHAR(20), GETDATE(), 114) + ' STEP 5:007:004'
                        --SET @Diff_Sec  = @Toatl_Working_sec -  @Shift_Sec       
                        --Ankit start 13112013
                        DECLARE @OT_Start_ShiftEnd_Time AS VARCHAR(10)
                        DECLARE @OT_Start_ShiftStart_Time AS VARCHAR(10)
                        SET @OT_Start_ShiftEnd_Time = ''    
                        SET @OT_Start_ShiftStart_Time = ''
              
                        SELECT @OT_Start_ShiftStart_Time=OT_Start_Time, @OT_Start_ShiftEnd_Time = OT_End_Time 
                        FROM T0050_SHIFT_DETAIL WHERE Cmp_ID=@Cmp_ID And Shift_ID=@SHIFT_ID 
    
                        IF @OT_Start_ShiftStart_Time = 1
                            Begin
                                DECLARE @OT_Start_ShiftStart_Sec NUMERIC                
                                IF datediff(s,@Insert_In_Date,@Shift_ST_DateTime) > 0       
                                    Begin
                                        SET @OT_Start_ShiftStart_Sec = datediff(s,@Insert_In_Date,@Shift_ST_DateTime)
                                        SET @Toatl_Working_sec = @Toatl_Working_sec - @OT_Start_ShiftStart_Sec
                                    End
                            End

                        IF @DeduHour_SecondBreak = 0 And @DeduHour_ThirdBreak = 0
                            SET @Diff_Sec  = @Toatl_Working_sec -  @Shift_Sec
                        IF @DeduHour_SecondBreak = 1 And @DeduHour_ThirdBreak = 0
                            SET @Diff_Sec  = @Toatl_Working_sec -  @Shift_Sec --+ @Second_Break_Duration_Sec
                        IF @DeduHour_ThirdBreak = 1  And @DeduHour_SecondBreak = 0
                            SET @Diff_Sec  = @Toatl_Working_sec -  @Shift_Sec  --+ @Third_Break_Duration_Sec
                        IF @DeduHour_SecondBreak = 1 And @DeduHour_ThirdBreak = 1
                            SET @Diff_Sec  = @Toatl_Working_sec -  @Shift_Sec --+ @Second_Break_Duration_Sec  + @Third_Break_Duration_Sec

                        SET @Toatl_Working_sec = @Toatl_Working_sec + Isnull(@OT_Start_ShiftStart_Sec,0)
                        
                        --PRINT CONVERT(VARCHAR(20), GETDATE(), 114) + ' STEP 5:007:005'            
                        IF @OT_Start_ShiftEnd_Time = 1
                            Begin
                                DECLARE @OT_Start_ShiftEnd_Sec NUMERIC      
                                SET @OT_Start_ShiftEnd_Sec = 0

                                IF @First_In_Last_Out_For_InOut_Calculation = 1
                                    BEGIN                   
                                        IF datediff(s,@Insert_Out_Date,@Shift_End_Datetime) < 0  
                                            SET @OT_Start_ShiftEnd_Sec = datediff(s,@Shift_End_Datetime,@Insert_Out_Date)
                                    END
                                ELSE
                                    BEGIN
                                        SELECT @OT_Start_ShiftEnd_Sec = SUM(Diff_Sec) FROM (
                                        SELECT Case When Row = 1 then
                               DATEDIFF(s,@Shift_End_Datetime,Out_Time)
                                                Else 
                                                    DATEDIFF(s,In_Time,Out_Time)
                                                End AS Diff_Sec 
                                        FROM    (SELECT ROW_NUMBER() 
                                                    OVER (ORDER BY IO_Tran_Id) AS Row, 
                                                        In_Time,Out_Time FROM T0150_EMP_INOUT_RECORD WHERE Emp_ID = @Emp_ID
                                                        and (In_Time >= @Shift_End_Datetime or Out_Time >= @Shift_End_Datetime)
                                                        and For_Date = @Temp_Month_Date And Emp_ID = @Emp_ID
                                                    ) AS Qry
                                                ) AS Qry1                       
                                    End
                                
                                    IF @OT_Start_ShiftEnd_Sec > 0
                                        SET @Diff_Sec = @OT_Start_ShiftEnd_Sec  
                                    Else
                                        SET @Diff_Sec = 0                           
                            End
                        --Ankit End 13112013 

                        --PRINT CONVERT(VARCHAR(20), GETDATE(), 114) + ' STEP 5:007:006'         
                        ---Hardik 21/11/2011 for Half day shift  
                        DECLARE @WeekDay VARCHAR(10)  
                        DECLARE @HalfStartTime VARCHAR(10)  
                        DECLARE @HalfEndTime VARCHAR(10)  
                        DECLARE @HalfDuration VARCHAR(10)                       
                        DECLARE @curForDate DATETIME  
                        DECLARE @HalfMinDuration VARCHAR(10)  
                        DECLARE @HalfStartDateTime DATETIME  
                        DECLARE @HalfEndDateTime DATETIME  
                         
                        
                        
                        --PRINT CONVERT(VARCHAR(20), GETDATE(), 114) + ' STEP 5:007:007'                        
                        SELECT  @WeekDay=SM.Week_Day,@HalfStartTime=SM.Half_St_Time,@HalfEndTime=SM.Half_End_Time,@HalfDuration=SM.Half_Dur,@HalfMinDuration=SM.Half_min_duration 
                        FROM    dbo.T0040_SHIFT_MASTER SM inner join           
                                (SELECT distinct Shift_ID FROM #Emp_Inout ) q on SM.Shift_ID =  q.shift_ID          
                        WHERE   Is_Half_Day = 1   

                        SET @HalfStartDateTime = cast(cast(@Temp_Month_Date AS VARCHAR(11)) + ' ' + @HalfStartTime AS SMALLDATETIME)      
                        SET @HalfEndDateTime = cast(cast(@Temp_Month_Date AS VARCHAR(11)) + ' ' + @HalfEndTime  AS SMALLDATETIME)      
                        --PRINT CONVERT(VARCHAR(20), GETDATE(), 114) + ' STEP 5:007:008'        
  
                        IF(CHARINDEX(CONVERT(NVARCHAR(11),@Insert_In_Date,109),@HalfDayDate) > 0)  
                            BEGIN      
                                SET @Diff_Sec  = @Toatl_Working_sec -  dbo.F_Return_Sec(@HalfDuration)      

                                SET @Late_In_sec = 0      
                                SET @Late_Out_Sec = 0      
                                SET @Early_In_sec = 0      
                                SET @Early_Out_sec = 0    
                                                            
                                IF datediff(s,@Insert_In_Date,@HalfStartDateTime) > 0       
                                    SET @Early_In_Sec = datediff(s,@Insert_In_Date,@HalfStartDateTime)      
                                IF datediff(s,@Insert_In_Date,@HalfStartDateTime) < 0       
                                    SET @late_In_Sec = datediff(s,@Insert_In_Date,@HalfStartDateTime)      
                                IF datediff(s,@Insert_Out_Date,@HalfEndDateTime) > 0       
                                    SET @Early_Out_Sec = datediff(s,@Insert_Out_Date,@HalfEndDateTime)      
                                IF datediff(s,@Insert_Out_Date,@HalfEndDateTime) < 0       
                                    SET @Late_Out_Sec = datediff(s,@Insert_Out_Date,@HalfEndDateTime)      


                                SET @late_In_Sec  = @late_In_Sec * -1      
                                SET @Late_Out_Sec  = @Late_Out_Sec * -1      

                                -- Commented by Hardik 17/08/2012                            
                                --exec Return_Without_Sec @late_in_sec ,@late_in_sec output      
                                --exec Return_Without_Sec @late_out_sec ,@late_out_sec output      
                                --exec Return_Without_Sec @Early_In_Sec ,@Early_In_Sec output      
                                --exec Return_Without_Sec @Early_Out_Sec ,@Early_Out_Sec output      
                                --exec Return_Without_Sec @Working_sec ,@Working_sec output       

                                IF @Is_Late_Mark = 0 Or @Emp_Late_Mark = 0
                                    Begin
                                        SET @late_in_sec  = 0
                                        SET @late_out_sec  = 0
                                    End
                                     
                                IF  @Is_Late_Mark = 0 Or @Emp_Early_Mark = 0
                                    Begin
                                        SET @Early_In_Sec  = 0
                                        SET @Early_Out_Sec  = 0
                                    End
                  
                                          
                                IF @Late_Comm_sec >=  @late_in_sec   SET @late_in_sec  = 0      
                                IF @Late_Comm_sec >=  @late_out_sec  SET @late_out_sec  = 0      
                                IF @Early_Limit_sec >=  @Early_In_Sec  SET @Early_In_Sec  = 0      
                                IF @Early_Limit_sec >=  @Early_Out_Sec SET  @Early_Out_Sec  = 0      
                                          
                                IF @late_in_sec  > 0  exec dbo.Return_DurHourMin  @late_In_Sec ,@late_In output       
                                IF @late_out_sec > 0  exec dbo.Return_DurHourMin  @late_Out_Sec ,@late_Out output       
                                          
                                IF @Early_In_Sec  > 0 exec dbo.Return_DurHourMin  @Early_In_Sec ,@Early_In output       
                                IF @Early_Out_Sec > 0 exec dbo.Return_DurHourMin  @Early_Out_Sec ,@Early_Out output       
                                IF @Working_sec > 0 exec dbo.Return_DurHourMin  @Working_Sec ,@WORKING_HOURS output    
                            END         
                        ------------ End for Half shift  
                        --PRINT CONVERT(VARCHAR(20), GETDATE(), 114) + ' STEP 5:007:009'
                        IF @Diff_Sec < 0
                            Begin  
                                SET @Diff_Sec = @Diff_Sec * -1
                                Exec dbo.Return_Without_Sec @Diff_Sec,@Diff_Sec Output
                                SET @Diff_Sec = @Diff_Sec * -1
                            End
                        Else
                            begin
                                Exec dbo.Return_Without_Sec @Diff_Sec,@Diff_Sec Output
                            End
                        --PRINT CONVERT(VARCHAR(20), GETDATE(), 114) + ' STEP 5:007:010'
                        IF  @Diff_Sec > 0  And @Diff_Sec > @Emp_OT_Min_Limit_Sec And (@Emp_OT = 1 or @Monthly_Deficit_Adjust_OT_Hrs = 1)
                            Begin                           
                                IF @Diff_Sec < @Emp_OT_Max_Limit_Sec or @Emp_OT_Max_Limit_Sec = 0
                             Begin
                                        EXEC dbo.Return_DurHourMin @Diff_Sec , @More_Work output  
                                        SET @Total_More_work_sec = @Diff_Sec      
                                    End
                                Else
                                    Begin                                   
                                        exec dbo.Return_DurHourMin @Emp_OT_Max_Limit_Sec , @More_Work output  
                                        SET @Total_More_work_sec = @Emp_OT_Max_Limit_Sec      
                                    End                                 
                            END
                        ELSE IF @Diff_Sec <  0 and @Toatl_Working_sec > 0 And (@Emp_OT = 1 or @Monthly_Deficit_Adjust_OT_Hrs = 1)     
                            BEGIN      
                                SET @Diff_Sec = @Diff_Sec * -1      
                                SET @Total_Less_Work_Sec = @Diff_Sec      
                                EXEC dbo.Return_DurHourMin @Diff_Sec , @less_Work output       
                            END       
                        --PRINT CONVERT(VARCHAR(20), GETDATE(), 114) + ' STEP 5:007:011'
                        IF @late_in_Sec > 0       
                            SET @Late_in_count =1       
                        IF @Early_Out_Sec > 0      
                            SET @Early_Out_Count = 1       
           
                        --Nilay 30 May 2009 Working hour > shift hours SET working hours = shift hours    
                        IF @working_sec > @Shift_Sec  
                            BEGIN    
                                SET  @working_sec=@Shift_Sec    
                                SET  @working_Hours=dbo.F_Return_Hours(@working_sec)          
                            End  

                            
                        ---Hardik 13/12/2013 for Pakistan
                        --IF Upper(@Country_Name) = 'PAKISTAN'
                            Begin
                                DECLARE @Chk_by_Superior AS tinyint
                                DECLARE @Half_Full_Day AS VARCHAR(30)
                                DECLARE @Is_Cancel_Late_In AS tinyint
                                DECLARE @Is_Cancel_Early_Out AS tinyint
                                DECLARE @P_Days AS NUMERIC(18,2)
                                
                                
                                SET @Chk_by_Superior =0
                                SET @Half_Full_Day =''
                                SET @Is_Cancel_Late_In =0
                                SET @Is_Cancel_Early_Out =0

                                --PRINT CONVERT(VARCHAR(20), GETDATE(), 114) + ' STEP 5:007:011'
                                SELECT @Chk_by_Superior = Isnull(Chk_by_Superior,0), @Half_Full_Day = Isnull(Half_Full_Day,''),
                                    @Is_Cancel_Late_In = Isnull(Is_Cancel_Late_In,0), @Is_Cancel_Early_Out= Isnull(Is_Cancel_Early_Out,0)
                                From dbo.T0150_EMP_INOUT_RECORD WHERE In_Time = @Insert_IN_DATE And Emp_ID = @Emp_ID
                                --PRINT CONVERT(VARCHAR(20), GETDATE(), 114) + ' STEP 5:007:012'

                                
                                IF @Chk_by_Superior = 1
                                    Begin                                       
                                        IF @Half_Full_Day = 'Full Day'
                                            Begin
                                                SET @Insert_IN_DATE =isnull(@Insert_In_Date,'') --'' -Sumit on 27082016
                                                SET @Insert_Out_DATE = isnull(@Insert_Out_DATE,'')--'' -Sumit on 27082016
                                                SET @working_Hours = @Shift_Dur
                                  SET @working_sec = @Shift_Sec
                                                SET @Total_Work = cast(@Shift_Dur + ' *' as varchar(50)) --Added by Sumit for Regularized Data 27082016--@Shift_Dur --
                                                SET @Toatl_Working_sec = @Shift_Sec
                                                SET @Less_Work = '-'
                                                SET @Total_less_work_sec = 0
                                                SET @More_Work = '-'
                                                SET @Total_More_work_sec = 0
                                                SET @P_Days = 1
                                            End
                                        Else IF @Half_Full_Day = 'First Half' or @Half_Full_Day = 'Second Half'
                                            Begin
                                                SET @Insert_IN_DATE =isnull(@Insert_In_Date,'') --'' --Sumit on 27082016
                                                SET @Insert_Out_DATE = isnull(@Insert_Out_DATE,'')--'' -Sumit on 27082016
                                                SET @working_Hours = dbo.F_Return_Hours(@Shift_Sec/2)
                                                SET @working_sec = @Shift_Sec/2
                                                SET @Total_Work = cast(dbo.F_Return_Hours(@Shift_Sec/2) + ' *' as varchar(50))--Added by Sumit for Regularized Data 27082016--dbo.F_Return_Hours(@Shift_Sec/2)
                                                SET @Toatl_Working_sec = @Shift_Sec/2
                                                SET @Less_Work = '-'
                                                SET @Total_less_work_sec = 0
                                                SET @More_Work = '-'
                                                SET @Total_More_work_sec = 0
                                                SET @P_Days = 0.5
                                            End
                                        
                                        IF @Is_Cancel_Late_In = 1 
                                            Begin
                                                SET @Late_In =''
                                                SET @Late_In_Sec = 0
                                                SET @Late_In_Count = 0
                                            End

                                        IF @Is_Cancel_Early_Out = 1 
                                            Begin
                                                SET @Early_Out =''
                                                SET @Early_Out_Sec = 0
                                                SET @Early_out_count = 0
                                            End                                     
                                    End
                            End
                            ---- End for Hardik 13/12/2013 for Pakistan

                        --PRINT CONVERT(VARCHAR(20), GETDATE(), 114) + ' STEP 5:007:012'
                        ---Hardik for Total Work show only in Last row (IF Multiple In-Out Entries)  
                        IF EXISTS(SELECT EI.Emp_ID  FROM #Emp_Inout AS EI  WHERE EI.Emp_ID = @Emp_ID and EI.For_DAte = @temp_Month_DAte )  
                            BEGIN  
                                --PRINT CONVERT(VARCHAR(20), GETDATE(), 114) + ' STEP 5:007:013'
                                SELECT  @Toatl_Working_sec = isnull(sum(Duration_Sec) ,0)  
                                FROM    #Emp_Inout AS EI  WHERE EI.Emp_ID = @Emp_ID and EI.For_DAte = @temp_Month_DAte  
     
                                SELECT  @Working_Sec_AfterShift = isnull(sum(Working_Sec_AfterShift) ,0)  
                                FROM    #Emp_Inout AS EI  
                                WHERE   EI.Emp_ID = @Emp_ID and EI.For_DAte = @temp_Month_DAte and EI.In_Time >= @Shift_End_datetime  
       
                                SET @Toatl_Working_sec = isnull(@Toatl_Working_sec,0) + @Working_sec      
      
                                --Ankit Start 12112013
                                DECLARE @Min_In_Time AS DATETIME
                                SELECT @Min_In_Time = MIN(In_Time) FROM #Emp_Inout AS EI WHERE EI.Emp_ID = @Emp_ID and EI.For_DAte = @temp_Month_Date 

                                SELECT @DeduHour_SecondBreak = DeduHour_SecondBreak,@DeduHour_ThirdBreak = DeduHour_ThirdBreak ,@S_St_Time=S_St_Time,@S_End_Time=S_End_Time,@T_St_Time=T_St_Time,@T_End_Time=T_End_Time
                                From dbo.T0040_SHIFT_MASTER WHERE Cmp_ID=@Cmp_ID And Shift_ID=@SHIFT_ID
                
                                SET @Shift_S_ST_DateTime = cast(cast(@Temp_Month_Date AS VARCHAR(11)) + ' ' + @S_St_Time AS SMALLDATETIME)
                                SET @Shift_S_End_DateTime = cast(cast(@Temp_Month_Date AS VARCHAR(11)) + ' ' + @S_End_Time AS SMALLDATETIME)
                                SET @Shift_T_ST_DateTime = cast(cast(@Temp_Month_Date AS VARCHAR(11)) + ' ' + @T_St_Time AS SMALLDATETIME)
                                SET @Shift_T_End_DateTime = cast(cast(@Temp_Month_Date AS VARCHAR(11)) + ' ' + @T_End_Time AS SMALLDATETIME)

                                IF @DeduHour_SecondBreak = 1 And  @DeduHour_ThirdBreak = 1 
                                    Begin
                                    
                                        IF @DeduHour_SecondBreak = 1 And @Min_In_Time <= @Shift_S_ST_DateTime And @Insert_Out_DATE > @Shift_S_ST_DateTime
                                            Begin
                                                SET @Toatl_Working_sec = @Toatl_Working_sec - @Second_Break_Duration_Sec
                                            End

                                        IF @DeduHour_ThirdBreak = 1 And @Min_In_Time <= @Shift_T_ST_DateTime And @Insert_Out_DATE > @Shift_T_ST_DateTime
                                            Begin
                                                SET @Toatl_Working_sec = @Toatl_Working_sec - @Third_Break_Duration_Sec 
                                            End
                                    End 
                                Else IF @DeduHour_SecondBreak = 1 And @Min_In_Time <= @Shift_S_ST_DateTime And @Insert_Out_DATE > @Shift_S_ST_DateTime
                                    Begin
                                        SET @Toatl_Working_sec = @Toatl_Working_sec - @Second_Break_Duration_Sec
                                    End
                                Else IF @DeduHour_ThirdBreak = 1 And @Min_In_Time <= @Shift_T_ST_DateTime And @Insert_Out_DATE > @Shift_T_ST_DateTime
                                    Begin
                                        SET @Toatl_Working_sec = @Toatl_Working_sec - @Third_Break_Duration_Sec
                                    End
                                --Ankit End 12112013            
                    
                                --PRINT CONVERT(VARCHAR(20), GETDATE(), 114) + ' STEP 5:007:014'
                                IF @Toatl_Working_sec > 0 exec dbo.Return_DurHourMin  @Toatl_Working_sec ,@Total_work output         

                                --SET @Diff_Sec  = @Toatl_Working_sec -  @Shift_Sec       
                                --Ankit 14112013    

                                IF @OT_Start_ShiftEnd_Time = 1
                                    Begin
                                        SET @OT_Start_ShiftEnd_Sec = 0

                                        IF @First_In_Last_Out_For_InOut_Calculation = 1
                                            Begin                   
                                                IF datediff(s,@Insert_Out_Date,@Shift_End_Datetime) < 0  
                                                    SET @OT_Start_ShiftEnd_Sec = datediff(s,@Shift_End_Datetime,@Insert_Out_Date)
                       End
                                        Else
                                            Begin

                                                SELECT @OT_Start_ShiftEnd_Sec = SUM(Diff_Sec) FROM (
                                                SELECT Case When Row =1 then
                                                            DATEDIFF(s,@Shift_End_Datetime,Out_Time)
                                                        Else 
                                                            DATEDIFF(s,In_Time,Out_Time)
                                                        End AS Diff_Sec 
                                                FROM    (SELECT ROW_NUMBER() 
                                                            OVER (ORDER BY IO_Tran_Id) AS Row, 
                                                                    * FROM T0150_EMP_INOUT_RECORD WHERE Emp_ID = @Emp_ID
                                                                and (In_Time >= @Shift_End_Datetime or Out_Time >= @Shift_End_Datetime)
                                                                and For_Date = @Temp_Month_Date And Emp_ID = @Emp_ID
                                                            ) AS Qry
                                                        ) AS Qry1                       
                                            End
                                        
                                        IF @OT_Start_ShiftEnd_Sec > 0
                                            SET @Diff_Sec = @OT_Start_ShiftEnd_Sec  - @OT_Start_ShiftStart_Sec
                                        Else
                                            SET @Diff_Sec = 0
                                    End
                                Else
                                    SET @Diff_Sec  = @Toatl_Working_sec -  @Shift_Sec - @OT_Start_ShiftStart_Sec    
                               --Ankit 14112013
                                --PRINT CONVERT(VARCHAR(20), GETDATE(), 114) + ' STEP 5:007:015'        
                                    
                                IF @Diff_Sec < 0
                                    Begin  
                                        SET @Diff_Sec = @Diff_Sec * -1
                                        Exec dbo.Return_Without_Sec @Diff_Sec,@Diff_Sec Output
                                        SET @Diff_Sec = @Diff_Sec * -1
                                    End
                                Else
                                    Exec dbo.Return_Without_Sec @Diff_Sec,@Diff_Sec Output

                                IF  @Diff_Sec > 0 And @Diff_Sec > @Emp_OT_Min_Limit_Sec And (@Emp_OT = 1 or @Monthly_Deficit_Adjust_OT_Hrs = 1)
                                    Begin
                                        IF @Diff_Sec < @Emp_OT_Max_Limit_Sec or @Emp_OT_Max_Limit_Sec = 0
                                            Begin
                                                exec dbo.Return_DurHourMin @Diff_Sec , @More_Work output  
                                                SET @Total_More_work_sec = @Diff_Sec      
                                                SET @less_Work = ''
                                            End
                                        Else
                                            Begin
                                                exec dbo.Return_DurHourMin @Emp_OT_Max_Limit_Sec , @More_Work output  
                                                SET @Total_More_work_sec = @Emp_OT_Max_Limit_Sec      
                                                SET @less_Work = ''
                                            End
                                    End
                                else IF @Diff_Sec <  0 and @Toatl_Working_sec > 0  And (@Emp_OT = 1 or @Monthly_Deficit_Adjust_OT_Hrs = 1)    
                                    begin    
									  SET @Diff_Sec = @Diff_Sec * -1      
                                        SET @Total_Less_Work_Sec = @Diff_Sec      
                                        exec dbo.Return_DurHourMin @Diff_Sec , @less_Work output       
                                        SET @More_Work = ''
                                    end       
                                --Else IF condition added by Hardik 18/11/2013 for Diff_Sec zero
                                Else IF @Diff_Sec = 0
                                    Begin
                                        SET @less_Work = ''
                                        SET @More_Work = ''
                                    end
                                --PRINT CONVERT(VARCHAR(20), GETDATE(), 114) + ' STEP 5:007:016'
                                UPDATE  #Emp_Inout     
                                SET     Late_out = '',
                                        Early_Out = '',
                                        Total_Work = '',
                                        less_work = '',
                                        More_work = '',
                                        Early_Out_sec = 0,
                                        Total_Less_work_sec = 0,
                                        Total_More_work_Sec = 0,
                                        Early_Out_count = 0,
                                        Total_Work_Sec =0 
                                WHERE   Emp_ID = @emp_Id and For_Date = @temp_month_Date  

                            END   
                        ------------ End for Hardik   
    
    
                        --PRINT CONVERT(VARCHAR(20), GETDATE(), 114) + ' STEP 5:007:017'
                        
                        INSERT INTO #Emp_Inout (Emp_id,For_Date , Dept_id ,Grd_ID,Type_ID,Desig_ID ,Shift_ID,In_Time ,Out_Time ,Duration ,      
                                    Duration_sec  , Late_In ,Late_Out , Early_In , Early_Out , Leave ,Shift_Sec,Shift_Dur,Total_Work,Less_Work,More_work,Reason,Late_in_sec,Early_Out_sec,Total_Less_work_sec,Late_in_Count,Early_Out_count,Shift_St_Datetime,Shift_en_Datetime      
                                    ,Working_Sec_AfterShift,Working_AfterShift_Count,Inout_Reason,Total_Work_Sec,Late_Out_Sec,Early_In_sec,Total_More_work_Sec, Is_OT_Applicable,Monthly_Deficit_Adjust_OT_Hrs,Late_Comm_sec,Branch_Id,Check_by_superior,P_days )          
                        VALUES (@emp_id ,@Temp_Month_Date ,@Dept_id ,@Grd_ID ,@Type_ID,@Desig_ID,@Shift_ID,@Insert_IN_DATE ,@Insert_Out_DATE ,@working_Hours ,      
                                    @working_sec  , @late_In ,@late_Out , @Early_In , @Early_Out , '',@Shift_Sec,@Shift_Dur,@Total_Work,@Less_Work,@More_work,@Reason,@late_in_sec,@Early_Out_Sec,@Total_less_work_sec,@Late_in_Count,@Early_Out_count,@Shift_St_Time,@Shift_End_Time  -- @Pre_Shift_St_dateTime,@Pre_Shift_En_dateTime   change by rohit for shift start time and end time on 03-aug-2012
                                    ,@Working_Sec_AfterShift,@Working_AfterShift_Count,@Reason,isnull(@Toatl_Working_sec,0),isnull(@Late_Out_Sec,0),isnull(@Early_In_Sec,0),Isnull(@Total_More_work_Sec,0),@Emp_OT,@Monthly_Deficit_Adjust_OT_Hrs,@Late_comm_sec,@Branch_Id_Cur,@Chk_by_Superior,@P_Days )
                        
                        
                        --PRINT CONVERT(VARCHAR(20), GETDATE(), 114) + ' STEP 5:007:018'
                        ---Hardik for Total Work show only in Late in row (IF Multiple In-Out Entries)  
                        IF exists(SELECT EI.Emp_ID  FROM #Emp_Inout AS EI  WHERE EI.Emp_ID = @Emp_ID AND EI.For_DAte = @temp_Month_DAte )  
                            BEGIN  
                                DECLARE @Late_In_N AS VARCHAR(10)  
       
                                SELECT top(1) @Late_In_N = Late_In FROM #Emp_Inout AS EI WHERE EI.Emp_ID = @Emp_ID and EI.For_DAte = @temp_Month_DAte 
      
      
                                IF @Late_In_N <> '' or @Late_In_N <> '00:00'  
                                    BEGIN  
                                        UPDATE  #Emp_Inout 
                                        SET     Late_In = '',Late_In_Sec = 0,Late_In_count=0  
                                        WHERE   Emp_ID = @emp_Id and For_Date = @temp_month_Date  and Late_In <> @Late_In_N
                                    END  
                            END   
                        ------------ End for Hardik   
    
                        --- Hardik for Late In Hours show only on First Row (IF Multiple In-Out Entries)
                        --DECLARE @Min_In_Time AS DATETIME  --Comment By Ankit 30112013 For Update Shift Break Deduction
                        SET @Min_In_Time = ''
                        
                        SELECT @Min_In_Time = MIN(In_Time) FROM #Emp_Inout AS EI WHERE EI.Emp_ID = @Emp_ID   
                        and EI.For_DAte = @temp_Month_Date 
       
                        update #Emp_Inout SET   
                        Late_In = '',Late_In_Sec = 0,Late_In_count=0  
                        where Emp_ID = @emp_Id and For_Date = @temp_month_Date And In_Time <> @Min_In_Time
                        ------------ End for Hardik   
                        --PRINT CONVERT(VARCHAR(20), GETDATE(), 114) + ' STEP 5:007:019'
                                                     
                        FETCH NEXT FROM cur_inout INTO @Insert_In_Date,@Insert_Out_Date,@Reason     
                    END      
                CLOSE cur_Inout      
                DEALLOCATE cur_inout     
                
                --PRINT CONVERT(VARCHAR(20), GETDATE(), 114) + ' STEP 5:008'  
                    
                    
                ---- Added by Hardik on 11/10/2011 for Holiday, Weekoff and Leave checking  
                IF CHARINDEX(CAST(@Temp_Month_Date AS VARCHAR(11)),@StrHoliday_Date,0) > 0   
                    BEGIN  
                        SET @Weekoff_Entry = @Weekoff_Entry  
                        --if (@Temp_Month_Date='11-Oct-2016')
                        --  Begin
                        --      select @StrHoliday_Date--* from #Emp_Inout
                        --  End 
                        IF not exists (SELECT 1 FROM #Emp_Inout WHERE emp_id = @Emp_ID And for_Date = @Temp_Month_Date)  
                            BEGIN  
                                --PRINT CONVERT(VARCHAR(20), GETDATE(), 114) + ' STEP 5:009'                                
                                INSERT INTO #Emp_Inout   
                                       (Emp_id,For_Date , Dept_id ,Grd_ID,Type_ID,Desig_ID ,Shift_ID,In_Time ,Out_Time ,Duration ,      
                                       Duration_sec  , Late_In ,Late_Out , Early_In , Early_Out , Leave ,Shift_Sec,Shift_Dur,Total_Work,Less_Work,More_work,Reason,Late_in_sec,Early_Out_sec,Total_Less_work_sec,Late_in_Count,Early_Out_count,Shift_St_Datetime,Shift_en_Datetime      
                                       ,Working_Sec_AfterShift,Working_AfterShift_Count,Inout_Reason,AB_LEAVE,Total_More_work_Sec,Is_OT_Applicable,Monthly_Deficit_Adjust_OT_Hrs,Late_Comm_sec,Branch_Id )   
                                VALUES   
                                       (@emp_id ,@Temp_Month_Date ,@Dept_id ,@Grd_ID ,@Type_ID,@Desig_ID,@Shift_ID,Null,Null ,'-',      
                                        0, '-' ,'-', '-', '-', '',0,'-','-','-','-','-',0,0,0,0,0,Null,Null 
                                       ,0,0,'-','HO',0,@Emp_OT,@Monthly_Deficit_Adjust_OT_Hrs,@Late_Comm_sec,@Branch_Id_Cur )      
                                
                                ---Added Code by Sumit on 10112016--------------------------------------------------------     
                                update EI set EI.AB_LEAVE='OHO'
                                from #Emp_Inout EI inner join #Emp_WeekOff_Holiday EWH on EI.Emp_ID=EWH.Emp_ID
                                where CHARINDEX(CAST(@Temp_Month_Date AS VARCHAR(11)),EWH.OptHolidayDate,0) > 0
                                and EI.For_Date=@Temp_Month_Date
                                ------------------------------------------------------------------------------
                                       
                            END  
                        ELSE  
                            BEGIN  
                                --PRINT CONVERT(VARCHAR(20), GETDATE(), 114) + ' STEP 5:010'                                
                                IF @Emp_OT = 1
                                    --Update #Emp_Inout SET AB_LEAVE = 'HO', Total_More_work_Sec = Case When @Tras_Weekoff_OT = 1 Then Total_Work_Sec End, More_Work = Case When @Tras_Weekoff_OT = 1 Then Total_work End,Shift_Sec = 0 WHERE emp_id = @Emp_ID And for_Date = @Temp_Month_Date  
                                    IF CHARINDEX(cast(@Temp_Month_Date AS VARCHAR(11)),@StrCancelHoliday_Date,0) > 0    /* IF Sandwich Policy Applicable and employee has present on Holiday Then cancel Holiday    --Ankit 08012015  */
                                        Update #Emp_Inout SET AB_LEAVE = '', Total_More_work_Sec = Case When @Tras_Weekoff_OT = 1 Then Total_Work_Sec End, More_Work = Case When @Tras_Weekoff_OT = 1 Then Total_work End,Shift_Sec = 0 WHERE emp_id = @Emp_ID And for_Date = @Temp_Month_Date  
                                    ELSE
                                        Update #Emp_Inout SET AB_LEAVE = 'HO', Total_More_work_Sec = Case When @Tras_Weekoff_OT = 1 Then Total_Work_Sec End, More_Work = Case When @Tras_Weekoff_OT = 1 Then Total_work End,Shift_Sec = 0 WHERE emp_id = @Emp_ID And for_Date = @Temp_Month_Date    
                                Else
                                    Update #Emp_Inout SET AB_LEAVE = 'HO',Shift_Sec = 0 WHERE emp_id = @Emp_ID And for_Date = @Temp_Month_Date
                            END  
                    END   
                ELSE IF charindex(cast(@Temp_Month_Date AS VARCHAR(11)),@StrWeekoff_Date,0) > 0   
                    BEGIN  
                    
                        SET @Weekoff_Entry = @Weekoff_Entry  
                        IF not exists (SELECT 1 FROM #Emp_Inout WHERE emp_id = @Emp_ID And for_Date = @Temp_Month_Date)  
                            Begin  
                                --PRINT CONVERT(VARCHAR(20), GETDATE(), 114) + ' STEP 5:011'
                                INSERT INTO #Emp_Inout   
                                        (Emp_id,For_Date , Dept_id ,Grd_ID,Type_ID,Desig_ID ,Shift_ID,In_Time ,Out_Time ,Duration ,      
                                        Duration_sec  , Late_In ,Late_Out , Early_In , Early_Out , Leave ,Shift_Sec,Shift_Dur,Total_Work,Less_Work,More_work,Reason,Late_in_sec,Early_Out_sec,Total_Less_work_sec,Late_in_Count,Early_Out_count,Shift_St_Datetime,Shift_en_Datetime      
                                        ,Working_Sec_AfterShift,Working_AfterShift_Count,Inout_Reason,AB_LEAVE,Total_More_work_Sec,Is_OT_Applicable,Monthly_Deficit_Adjust_OT_Hrs,Late_Comm_sec,Branch_Id  )      
                                VALUES   
                                        (@emp_id ,@Temp_Month_Date ,@Dept_id ,@Grd_ID ,@Type_ID,@Desig_ID,@Shift_ID,Null,Null ,'-',      
                                        0, '-' ,'-', '-', '-', '',0,'-','-','-','-','-',0,0,0,0,0,Null,Null   
                                        ,0,0,'-','WO',0,@Emp_OT,@Monthly_Deficit_Adjust_OT_Hrs,@Late_Comm_sec,@Branch_Id_Cur  )      
                            END  
                        ELSE  
                            BEGIN  
                                --PRINT CONVERT(VARCHAR(20), GETDATE(), 114) + ' STEP 5:012'
                                IF @Emp_OT = 1
                                    --Update #Emp_Inout SET AB_LEAVE = 'WO', Total_More_work_Sec = Case When @Tras_Weekoff_OT = 1 Then Total_Work_Sec End, More_Work = Case When @Tras_Weekoff_OT = 1 Then Total_work End, Total_Less_work_Sec = 0,Less_Work = '',Shift_Sec = 0 WHERE emp_id = @Emp_ID And for_Date = @Temp_Month_Date      
                                    IF CHARINDEX(cast(@Temp_Month_Date AS VARCHAR(11)),@StrCancelWeekoff_Date,0) > 0
                                        UPDATE #Emp_Inout SET AB_LEAVE = '', Total_More_work_Sec = Case When @Tras_Weekoff_OT = 1 Then Total_Work_Sec End, More_Work = Case When @Tras_Weekoff_OT = 1 Then Total_work End, Total_Less_work_Sec = 0,Less_Work = '',Shift_Sec = 0 WHERE emp_id = @Emp_ID And for_Date = @Temp_Month_Date  
                                    ELSE
                                        UPDATE #Emp_Inout SET AB_LEAVE = 'WO', Total_More_work_Sec = Case When @Tras_Weekoff_OT = 1 Then Total_Work_Sec End, More_Work = Case When @Tras_Weekoff_OT = 1 Then Total_work End, Total_Less_work_Sec = 0,Less_Work = '',Shift_Sec = 0 WHERE emp_id = @Emp_ID And for_Date = @Temp_Month_Date    
                                ELSE
                                    UPDATE #Emp_Inout SET AB_LEAVE = 'WO',Shift_Sec = 0 WHERE emp_id = @Emp_ID And for_Date = @Temp_Month_Date  
                            END  
                    END     
                Else IF EXISTS (SELECT 1 FROM dbo.T0120_LEAVE_APPROVAL LA Inner Join   
                                            dbo.T0130_LEAVE_APPROVAL_DETAIL LAD On LA.Leave_Approval_ID = LAD.Leave_Approval_ID  
                                WHERE From_Date <= @Temp_Month_Date And To_Date >= @Temp_Month_Date And Emp_ID = @Emp_ID And LA.Approval_Status = 'A'
                                and LA.Leave_Approval_ID  not In (SELECT Leave_Approval_ID FROM dbo.T0150_LEAVE_CANCELLATION LC 
                                                                    WHERE  LC.cmp_id=@Cmp_ID and LC.Emp_ID = @Emp_ID and LC.For_Date = @Temp_Month_Date and LC.Is_Approve=1) )  
                    BEGIN  
                        
                
                        --PRINT CONVERT(VARCHAR(20), GETDATE(), 114) + ' STEP 5:013'
                        SELECT  @Leave_ID = Leave_ID, @Leave_Reason = Leave_Reason, @Leave_Period = Leave_Period,@Half_Leave_Date = Half_Leave_Date, @Leave_Assign_As = Leave_Assign_As
                        FROM    dbo.T0120_LEAVE_APPROVAL LA Inner Join   
                                dbo.T0130_LEAVE_APPROVAL_DETAIL LAD On LA.Leave_Approval_ID = LAD.Leave_Approval_ID  
                        WHERE   From_Date <= @Temp_Month_Date And To_Date >= @Temp_Month_Date And Emp_ID = @Emp_ID And LA.Approval_Status = 'A'
                                and LA.Leave_Approval_ID  not In (SELECT Leave_Approval_ID FROM dbo.T0150_LEAVE_CANCELLATION LC WHERE  LC.cmp_id=@Cmp_ID and LC.Emp_ID = @Emp_ID and LC.For_Date = @Temp_Month_Date and LC.Is_Approve=1)


                        SELECT @Leave_Name = Leave_Code FROM dbo.T0040_LEAVE_MASTER WHERE Leave_ID = @Leave_ID  
                        -- Changed by Gadriwala Muslim 02102014 for CompOff
                        SELECT  @Leave_Period = Sum(isnull(Leave_Used,0) + ISNULL(CompOff_Used,0)) 
                        FROM    dbo.T0140_Leave_Transaction 
                        WHERE Emp_Id = @Emp_ID And For_Date = @Temp_Month_Date -- And Leave_Id = @Leave_Id 

                        
                        
                        --PRINT CONVERT(VARCHAR(20), GETDATE(), 114) + ' STEP 5:014'
                        IF NOT EXISTS (SELECT 1 FROM #Emp_Inout WHERE emp_id = @Emp_ID And for_Date = @Temp_Month_Date)  
                            BEGIN
                            
                                --PRINT CONVERT(VARCHAR(20), GETDATE(), 114) + ' STEP 5:015'
                                IF UPPER(@Country_Name) <> 'PAKISTAN'
                                    BEGIN   
                                                            
   INSERT INTO #Emp_Inout   
                                                (Emp_id,For_Date , Dept_id ,Grd_ID,Type_ID,Desig_ID ,Shift_ID,In_Time ,Out_Time ,Duration ,      
                                                Duration_sec  , Late_In ,Late_Out , Early_In , Early_Out , Leave ,Shift_Sec,Shift_Dur,Total_Work,Less_Work,More_work,Reason,Late_in_sec,Early_Out_sec,Total_Less_work_sec,Late_in_Count,Early_Out_count,Shift_St_Datetime,Shift_en_Datetime      
                                                ,Working_Sec_AfterShift,Working_AfterShift_Count,Inout_Reason,AB_LEAVE,Total_More_work_Sec,Is_OT_Applicable,Monthly_Deficit_Adjust_OT_Hrs,Late_Comm_sec,Branch_Id,Leave_Days )      
                                        VALUES   
                                                (@emp_id ,@Temp_Month_Date ,@Dept_id ,@Grd_ID ,@Type_ID,@Desig_ID,@Shift_ID,Null,Null ,'-',      
                                                0, '-' ,'-', '-', '-', @Leave_Name,@Shift_Sec,@Shift_Dur,'-','-','-',@Leave_Reason,0,0,0,0,0,@Shift_St_Time,@Shift_End_Time -- Null,Null -- comment and add by rohit for shift time on 06-aug-2012   
                                                ,0,0,'-',Case When @Leave_Period % 1 <> 1 then @Leave_Name + '-' + cast(@Leave_Period AS VARCHAR(4)) Else @Leave_Name End  ,0,@Emp_OT,@Monthly_Deficit_Adjust_OT_Hrs,@Late_Comm_sec,@Branch_Id_Cur,@Leave_Period  )      
                                    
                              
                                        Update #Emp_Inout SET AB_LEAVE = 
                                                Case when @Leave_Period < 1 
                                                    then @Leave_Name + Case @Leave_Assign_As When  'First Half' Then '-FH' 
                                                                                                 When 'Second Half' Then '-SH' End 
                                                    Else @Leave_Name End,
                                            P_days = 
                                                Case when P_days = 1 
                                                    then Case When (@Leave_Assign_As = 'First Half' OR @Leave_Assign_As = 'First Half')  Then 0.5 End End,                      
                                            A_days = 
                                                Case when A_days = 0 And P_Days=0 And @Leave_Period < 1 
                                                    then 0.5 
                                                ELSE
                                                    1 - (IsNull(P_days,0) + @Leave_Period)
                                                End,                        
                                            Total_Less_work_Sec = 0,Less_Work = '',Total_More_work_Sec = 0, More_Work='' 
                                            WHERE emp_id = @Emp_ID And for_Date = @Temp_Month_Date                      
                              
                                        IF not exists(SELECT 1 FROM #Leave WHERE Emp_Id = @Emp_Id And Leave_Id = @Leave_ID)
                                            Insert Into #Leave (Emp_Id,Leave_Id,Leave_Name,Leave_Days)
                                            Values (@Emp_Id,@Leave_ID,@Leave_Name,@Leave_Period)
                                        Else
                                            Update #Leave SET Leave_Days = Leave_Days + @Leave_Period WHERE Emp_Id = @Emp_ID And Leave_Id = @Leave_ID
                                
                                    END
                                ELSE
                                    IF @Leave_Assign_As = 'Full Day'
                                        BEGIN
                                            INSERT INTO #Emp_Inout   
                                                    (Emp_id,For_Date , Dept_id ,Grd_ID,Type_ID,Desig_ID ,Shift_ID,In_Time ,Out_Time ,Duration ,      
                Duration_sec  , Late_In ,Late_Out , Early_In , Early_Out , Leave ,Shift_Sec,Shift_Dur,Total_Work,Less_Work,More_work,Reason,Late_in_sec,Early_Out_sec,Total_Less_work_sec,Late_in_Count,Early_Out_count,Shift_St_Datetime,Shift_en_Datetime      
                                                    ,Working_Sec_AfterShift,Working_AfterShift_Count,Inout_Reason,AB_LEAVE,Total_More_work_Sec,Is_OT_Applicable,Monthly_Deficit_Adjust_OT_Hrs,Late_Comm_sec,Total_Work_Sec,Branch_Id)      
                                            VALUES   
                                                    (@emp_id ,@Temp_Month_Date ,@Dept_id ,@Grd_ID ,@Type_ID,@Desig_ID,@Shift_ID,Null,Null ,'-',      
                                                    @Shift_Sec, '-' ,'-', '-', '-', @Leave_Name,@Shift_Sec,@Shift_Dur,@Shift_Dur,'-','-',@Leave_Reason,0,0,0,0,0,@Shift_St_Time,@Shift_End_Time -- Null,Null -- comment and add by rohit for shift time on 06-aug-2012   
                                                    ,0,0,'-',@Leave_Name,0,@Emp_OT,@Monthly_Deficit_Adjust_OT_Hrs,@Late_Comm_sec,@Shift_Sec,@Branch_Id_Cur  )      
                                        End
                                    ELSE
                                        BEGIN
                                            INSERT INTO #Emp_Inout   
                                                    (Emp_id,For_Date , Dept_id ,Grd_ID,Type_ID,Desig_ID ,Shift_ID,In_Time ,Out_Time ,Duration ,      
                                                    Duration_sec  , Late_In ,Late_Out , Early_In , Early_Out , Leave ,Shift_Sec,Shift_Dur,Total_Work,Less_Work,More_work,Reason,Late_in_sec,Early_Out_sec,Total_Less_work_sec,Late_in_Count,Early_Out_count,Shift_St_Datetime,Shift_en_Datetime      
                                                    ,Working_Sec_AfterShift,Working_AfterShift_Count,Inout_Reason,AB_LEAVE,Total_More_work_Sec,Is_OT_Applicable,Monthly_Deficit_Adjust_OT_Hrs,Late_Comm_sec,Total_Work_Sec,Branch_Id)      
                                            VALUES   
                                                    (@emp_id ,@Temp_Month_Date ,@Dept_id ,@Grd_ID ,@Type_ID,@Desig_ID,@Shift_ID,Null,Null ,'-',      
                                                    Case When @Half_Leave_Date = @Temp_Month_Date Then @Shift_Sec/2 Else @Shift_Sec End , '-' ,'-', '-', '-', @Leave_Name,@Shift_Sec,@Shift_Dur,Case When @Half_Leave_Date = @Temp_Month_Date Then dbo.F_Return_Hours(@Shift_Sec/2) Else @Shift_Dur End,'-','-',@Leave_Reason,0,0,0,0,0,@Shift_St_Time,@Shift_End_Time -- Null,Null -- comment and add by rohit for shift time on 06-aug-2012   
                                                    ,0,0,'-',@Leave_Name,0,@Emp_OT,@Monthly_Deficit_Adjust_OT_Hrs,@Late_Comm_sec,Case When @Half_Leave_Date = @Temp_Month_Date Then @Shift_Sec/2 Else @Shift_Sec End,@Branch_Id_Cur  )      
                                        End
                                --PRINT CONVERT(VARCHAR(20), GETDATE(), 114) + ' STEP 5:016'
                            END
                        ELSE
                            BEGIN
                                
                                
                                UPDATE  EI 
                                SET     AB_LEAVE = Case when @Leave_Period < 1 then 
                                                        @Leave_Name + 
                                                           Case @Leave_Assign_As When  'First Half' Then 
                                                                    '-FH' 
                                                                When 'Second Half' Then 
                                                                    '-SH' 
                                                                Else
                                                                    ''
                                                            End 
                 Else 
                @Leave_Name 
                                                    End,
                                        P_days = Case when D.P_days = 1 then 
                                                    Case When (@Leave_Assign_As = 'First Half' OR @Leave_Assign_As = 'First Half')  Then 
                                                        0.5 
                                                    Else 
                                                        IsNull(D.P_Days, 1)
                                                    End 
                                                End,                        
                                        A_days = Case when A_days = 0 then 
                                                    Case When (@Leave_Assign_As = 'First Half' OR @Leave_Assign_As = 'First Half')  Then 
                                                        0.5 
                                                    Else
                                                        1 - (IsNull(D.P_Days, 0) + IsNull(@Leave_Period,0))
                                                    End 
                                                End,                        
                                        Total_Less_work_Sec = 0,
                                        Less_Work = '',
                                        Total_More_work_Sec = 0,
                                        More_Work='',
                                        Leave_Days = @Leave_Period
                                FROM    #Emp_Inout EI LEFT OUTER JOIN #Data D ON EI.Emp_ID=D.Emp_ID AND EI.For_Date=D.For_Date
                                WHERE   EI.emp_id = @Emp_ID And EI.for_Date = @Temp_Month_Date              
            
            
                                    
                                IF NOT EXISTS(SELECT 1 FROM #Leave WHERE Emp_Id = @Emp_Id And Leave_Id = @Leave_ID)
                                    BEGIN
                                        INSERT INTO #Leave (Emp_Id,Leave_Id,Leave_Name,Leave_Days)
                                        VALUES (@Emp_Id,@Leave_ID,@Leave_Name,@Leave_Period)
                                    END
                                ELSE
                                    BEGIN
                                        Update #Leave SET Leave_Days = Leave_Days + @Leave_Period WHERE Emp_Id = @Emp_ID And Leave_Id = @Leave_ID
                                    END
            
                            END
                    END  
                ELSE  
                    BEGIN  
                        IF not exists (SELECT 1 FROM #Emp_Inout WHERE emp_id = @Emp_ID And for_Date = @Temp_Month_Date)  
                            Begin   
                                --PRINT CONVERT(VARCHAR(20), GETDATE(), 114) + ' STEP 5:017'
                                IF @Temp_Month_Date >= @Join_Date And (@Temp_Month_Date <= @Left_Date or @Left_Date Is null)
                                    BEGIN
                                        INSERT INTO #Emp_Inout
                                                (Emp_id,For_Date , Dept_id ,Grd_ID,Type_ID,Desig_ID ,Shift_ID,In_Time ,Out_Time ,Duration ,      
                                                Duration_sec  , Late_In ,Late_Out , Early_In , Early_Out , Leave ,Shift_Sec,Shift_Dur,Total_Work,Less_Work,More_work,Reason,Late_in_sec,Early_Out_sec,Total_Less_work_sec,Late_in_Count,Early_Out_count,Shift_St_Datetime,Shift_en_Datetime      
                                                ,Working_Sec_AfterShift,Working_AfterShift_Count,Inout_Reason,AB_LEAVE,Total_More_work_Sec,Is_OT_Applicable,Monthly_Deficit_Adjust_OT_Hrs,Late_Comm_sec,Branch_Id,A_days )      
                                        VALUES   
                                               (@emp_id ,@Temp_Month_Date ,@Dept_id ,@Grd_ID ,@Type_ID,@Desig_ID,@Shift_ID,Null,Null ,'-',      
                         0, '-' ,'-', '-', '-', '',@Shift_Sec,@Shift_Dur,'-',@Shift_Dur,'-','-',0,0,@Shift_Sec,0,0,@Shift_St_Time,@Shift_End_Time --Null,Null --comment and add by rohit for shift time on 06-aug-2012  
                                               ,0,0,'-','AB',0,@Emp_OT,@Monthly_Deficit_Adjust_OT_Hrs,@Late_Comm_sec,@Branch_Id_Cur,1)      
                                    END
                            END  
                    END  
                ------------- End by Hardik   
                --PRINT CONVERT(VARCHAR(20), GETDATE(), 114) + ' STEP 5:018'
                SET @Temp_Month_Date = Dateadd(d,1,@Temp_Month_Date)       
            END       
        --PRINT CONVERT(VARCHAR(20), GETDATE(), 114) + ' STEP 5:019'
        FETCH NEXT FROM CUR_EMP INTO @EMP_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Late_Comm_sec,@Early_Limit_Sec,@Emp_OT,@Emp_OT_Min_Limit_Sec,@Emp_OT_Max_Limit_Sec,@Monthly_Deficit_Adjust_OT_Hrs,@Branch_Id_Cur,@Emp_Late_Mark,@Emp_Early_Mark
    END      
    CLOSE cur_Emp      
    DEALLOCATE cur_Emp      

  ----------- */
   
    --Update E SET A_days = 1 FROM #Data D inner join #Emp_Inout E on D.Emp_Id = E.emp_id And D.For_date = E.for_Date WHERE d.P_days=0 And AB_LEAVE Is null --And E.Emp_Id = @Emp_Id
    --Update E SET A_days = 1 - (IsNull(Leave_Days, 0) + D.P_days) FROM #Data D inner join #Emp_Inout E on D.Emp_Id = E.emp_id And D.For_date = E.for_Date WHERE d.P_days=0.5 ---And AB_LEAVE Is null --And E.Emp_Id = @Emp_Id            
    
    ----Update E SET AB_LEAVE =(CASE WHEN D.P_DAYS = 0.25 OR  D.P_DAYS = 0.375 OR D.P_DAYS = 0.125 THEN 'QD' END ), A_days = 1 - (IsNull(Leave_Days, 0) + D.P_days) FROM #Data D inner join #Emp_Inout E on D.Emp_Id = E.emp_id And D.For_date = E.for_Date WHERE D.P_DAYS IN (0.125, 0.25, 0.375 , 0.5 , 0.625,  0.75, 0.875)
    ----Update E SET AB_LEAVE = (CASE WHEN D.P_DAYS = 0.75 OR D.P_DAYS = 0.625 OR D.P_DAYS = 0.875 THEN '3QD' END ), A_days = 1 - (IsNull(Leave_Days, 0) + D.P_days) FROM #Data D inner join #Emp_Inout E on D.Emp_Id = E.emp_id And D.For_date = E.for_Date WHERE D.P_DAYS IN (0.125, 0.25, 0.375 , 0.5 , 0.625,  0.75, 0.875)
                    
    Update E SET A_days = 1 - (IsNull(Leave_Days, 0) + E.P_days) FROM #Data D inner join #Emp_Inout E on D.Emp_Id = E.emp_id And D.For_date = E.for_Date WHERE  E.P_days=0.5 
    --2000
    ---Update E SET A_days = 0.5 FROM  #Emp_Inout E WHERE (ISNULL(AB_LEAVE,'') LIKE '%SH%' OR ISNULL(AB_LEAVE,'') LIKE '%FH%') AND E.P_days =0
        
    Update  E 
    SET     P_days = D.P_days 
    FROM    #Data D 
            INNER JOIN #Emp_Inout E on D.Emp_Id = E.emp_id And D.For_date = E.for_Date and Total_work <> '' And total_work <> '-' 
    
       
    Update E SET AB_LEAVE = 'HF' FROM #Data D inner join #Emp_Inout E on D.Emp_Id = E.emp_id And D.For_date = E.for_Date WHERE E.P_days=0.5 And E.A_Days=0.5 --And E.Emp_Id = @Emp_Id
    
    Update E SET AB_LEAVE = AB_LEAVE + '-C' FROM #Data D inner join #Emp_Inout E on D.Emp_Id = E.emp_id And D.For_date = E.for_Date WHERE E.P_days = 1 and (AB_Leave = 'HO' or AB_Leave = 'WO' or AB_Leave = 'OHO')
    
    Update E SET AB_LEAVE = 'P' FROM #Data D inner join #Emp_Inout E on D.Emp_Id = E.emp_id And D.For_date = E.for_Date WHERE E.P_days=1 and AB_Leave is null
    
    Update E SET AB_LEAVE = AB_LEAVE + '/W' FROM #Data D inner join #Emp_Inout E on D.Emp_Id = E.emp_id And D.For_date = E.for_Date WHERE E.WeekOff_Days=0.5 
    
    --Update E SET AB_LEAVE = 'AB' FROM #Data D inner join #Emp_Inout E on D.Emp_Id = E.emp_id And D.For_date = E.for_Date WHERE E.A_days=1
    Update E SET AB_LEAVE = CASE WHEN AB_LEAVE LIKE '%LWP%' THEN AB_LEAVE ELSE 'AB' end FROM #Data D inner join #Emp_Inout E on D.Emp_Id = E.emp_id And D.For_date = E.for_Date WHERE E.A_days=1
    
    
    --Added by Hardik on 09/01/2016 AS per Client requirement QD (Quarter Day)
    
    Update E SET AB_LEAVE =(CASE WHEN D.P_DAYS = 0.25 OR  D.P_DAYS = 0.375 OR D.P_DAYS = 0.125 THEN 
    CASE WHEN isnull(AB_LEAVE,'') LIKE '%FH%' THEN  isnull(AB_LEAVE,'AB')+'/QD' ELSE 'QD/'+isnull(AB_LEAVE,'AB') END
     END ), A_days = 1 - (IsNull(Leave_Days, 0) + D.P_days) FROM #Data D inner join #Emp_Inout E on D.Emp_Id = E.emp_id And D.For_date = E.for_Date WHERE D.P_DAYS IN (0.125, 0.25, 0.375  )--, 0.625,  0.75, 0.875
            
    Update E SET AB_LEAVE = (CASE WHEN D.P_DAYS = 0.75 OR D.P_DAYS = 0.625 OR D.P_DAYS = 0.875 THEN 
    CASE WHEN isnull(AB_LEAVE,'') LIKE '%FH%' THEN  isnull(AB_LEAVE,'AB')+'/3QD' ELSE '3QD/'+isnull(AB_LEAVE,'AB') END
    END ), A_days = 1 - (IsNull(Leave_Days, 0) + D.P_days) FROM #Data D inner join #Emp_Inout E on D.Emp_Id = E.emp_id And D.For_date = E.for_Date WHERE D.P_DAYS IN ( 0.625,  0.75, 0.875)
   
    
	---select * into Tbl_Emp_Data_Consol FROM #Emp_Inout 
   
    DECLARE @cols nVARCHAR( max),
            @query nVARCHAR(max),
            @cols1 nVARCHAR( max)

	
	
    SELECT @cols =
      STUFF(( SELECT ',' + QUOTENAME(cast(day(Convert(VARCHAR(max),Q.for_date,106)) AS VARCHAR(2)) + '_' + left(datename(dw,Q.for_date),2)) AS ColName FROM 
            (SELECT Distinct T.For_Date FROM dbo.#Emp_Inout t) Q Order by Q.For_Date  
             FOR XML PATH(''), TYPE).value ('.', 'nVARCHAR(max)'), 1, 1, '')     

    --SELECT @cols1 =
    --  STUFF(( SELECT ',Left(Convert( NVARCHAR(12), Cast(Isnull(' + QUOTENAME(cast(day(Convert(VARCHAR(max),Q.for_date,106)) AS VARCHAR(2)) + '_' + left(datename(dw,Q.for_date),1)) + ',''Jan  1 1900 12:00AM'') AS DATETIME) ,114),5) AS '+QUOTENAME(cast(day(Convert(VARCHAR(max),Q.for_date,106)) AS VARCHAR(2)) + '_' + left(datename(dw,Q.for_date),1))+' ' AS ColName                                
    --      From 
    --      (SELECT Distinct T.For_Date FROM dbo.#Emp_Inout t) Q Order by Q.For_Date  
    --         FOR XML PATH(''), TYPE).value ('.', 'nVARCHAR(max)'), 1, 1, '')     

    SELECT @cols1 =
      STUFF(( SELECT ', case When not ' + QUOTENAME(cast(day(Convert(VARCHAR(max),Q.for_date,106)) AS VARCHAR(2)) + '_' + left(datename(dw,Q.for_date),2)) + ' Is null Then Left(Convert( NVARCHAR(12), Cast(Isnull(' + QUOTENAME(cast(day(Convert(VARCHAR(max),Q.for_date,106)) AS VARCHAR(2)) + '_' + left(datename(dw,Q.for_date),2)) + ',''Jan  1 1900 12:00AM'') AS DATETIME) ,114),5) Else ' + QUOTENAME(cast(day(Convert(VARCHAR(max),Q.for_date,106)) AS VARCHAR(2)) + '_' + left(datename(dw,Q.for_date),2)) + ' End AS '+QUOTENAME(cast(day(Convert(VARCHAR(max),Q.for_date,106)) AS VARCHAR(2)) + '_' + left(datename(dw,Q.for_date),2))+' ' AS ColName                                
            From 
            (SELECT Distinct T.For_Date FROM dbo.#Emp_Inout t) Q Order by Q.For_Date  
             FOR XML PATH(''), TYPE).value ('.', 'nVARCHAR(max)'), 1, 1, '')  

    SELECT Emp_Id,For_Date,MIN(In_Time) AS Min_In_Time,MAX(Out_Time) AS Max_Out_time into #Emp_Inout1 FROM #Emp_Inout Group by Emp_Id,For_Date

    --Overtime Added By Ramiz on 25/08/2015
    --PRINT CONVERT(VARCHAR(20), GETDATE(), 114) + ' STEP 7'
    DECLARE @ALTER_COLS VARCHAR(MAX);

    CREATE table #Consolidated_Temp(Emp_ID NUMERIC, PvtColumns VARCHAR(32),OrderColumns NUMERIC);

    SELECT @ALTER_COLS = COALESCE(@ALTER_COLS + ';', '') + 'ALTER TABLE  #Consolidated_Temp ADD ' + DATA + ' VARCHAR(32)' FROM dbo.Split(@cols, ',');
    EXEC (@ALTER_COLS);

    SET @query =
     'Insert Into #Consolidated_Temp
      SELECT * FROM (
            SELECT T.Emp_Id,cast(day(t.for_date)as VARCHAR(2)) + ''_'' + left(datename(dw,t.for_date),2) AS For_Date, 
            COALESCE(o.In_Time, o.Out_Time, o.Duration, o.AB_Leave, o.Shift_St_Datetime , o.Total_More_work_Sec, o.Late_In_Sec) AS PvtVals,o.PvtColumns, o.OrderColumns 
            FROM dbo.#Emp_Inout t Inner Join #Emp_Inout1 t1 on t.Emp_Id = t1.Emp_Id And t.For_Date = t1.For_date CROSS APPLY (
                                           VALUES(Case When  cast(t.In_Time AS VARCHAR(max)) <> ''Jan  1 1900 12:00AM'' Then cast(t1.Min_In_Time AS VARCHAR(max)) Else Null End ,Null,NULL, NULL,Null,NULL,Null,''In_Time'', 1),
                                                 (NULL, Case When cast(t.Out_Time AS VARCHAR(max)) <> ''Jan  1 1900 12:00AM'' Then cast(t1.Max_Out_Time AS VARCHAR(max)) Else Null End,Null, NULL,Null,NULL,NULL,''Out_Time'', 2),
                                                 (NULL, NULL, t.Total_Work,Null,Null,NULL,NULL,''Duration'', 3),
                                                 (NULL, NULL, NULL,t.AB_Leave,Null,NULL,NULL,''WOHO'', 4),
                                                 (NULL, NULL, NULL,Null, Convert(char(5),t.Shift_st_Datetime,108) + ''-'' +  Convert(char(5),t.Shift_en_Datetime,108) ,NULL,NULL, ''Shift_Time'', 5),
                                                 (NULL, NULL, NULL,NULL,NULL,cast(dbo.F_Return_Hours(Total_More_work_Sec) AS Varchar),NULL,''OverTime'', 6),
                                                 (NULL, NULL, NULL,NULL,NULL,NULL,cast(dbo.F_Return_Hours(Late_In_Sec) AS Varchar),''Late_Hrs'', 7)
                                           ) o (In_Time, Out_Time, Duration,AB_Leave,Shift_St_Datetime , Total_More_work_Sec,Late_In_Sec, PvtColumns,OrderColumns)
            ) p
      PIVOT
       (      
        MAX(PvtVals) FOR For_Date IN (' + @cols + ')
        ) AS pvt
      ORDER BY pvt.OrderColumns '
  
    EXEC(@query) 
    
    --PRINT CONVERT(VARCHAR(20), GETDATE(), 114) + ' STEP 8'

    --SELECT * into #Consolidated_Temp FROM Consolidated_Temp



    DECLARE @colsPivot_leave VARCHAR(max)


    SELECT @colsPivot_leave = STUFF((SELECT ',' + QUOTENAME(cast(Leave_Name AS VARCHAR(max))) 
                                    from (SELECT Distinct Leave_Name FROM  #Leave) Q
                                    order by Leave_Name 
                            FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')


    --SET @query = 'Alter  Table #Consolidated_Temp Add P_Days NUMERIC(18,2), A_Days NUMERIC(18,2), Weekoff NUMERIC(18,2), Holiday NUMERIC(18,2),' + Replace(@colsPivot_leave,']','] NUMERIC(18,2)')
    
    --SET @query = 'Alter  Table #Consolidated_Temp Add P_Days NUMERIC(18,2), A_Days NUMERIC(18,2), Weekoff NUMERIC(18,2), Holiday NUMERIC(18,2)'
    ---19 12 2019
    SET @query = 'Alter  Table #Consolidated_Temp Add P_Days NUMERIC(18,2), A_Days NUMERIC(18,2), Weekoff NUMERIC(18,2), Holiday NUMERIC(18,2), Leave NUMERIC(18,2)'
    
    
    Exec (@query)
    --PRINT CONVERT(VARCHAR(20), GETDATE(), 114) + ' STEP 9'
    --SET @query = 'Update #Consolidated_Temp SET P_Days = 0, A_Days = 0, Weekoff =0 , Holiday = 0'
    --Exec (@query)



    insert INTO #Leave_Balance
    SELECT distinct LT.Emp_ID,LT.Leave_ID,LT.Leave_Closing,qry.For_Date,LM.Leave_Name
    From T0140_LEAVE_TRANSACTION LT inner JOIN 
    (
        SELECT Emp_ID,Leave_ID,Max(For_Date) AS For_Date  FROM T0140_LEAVE_TRANSACTION group by Emp_ID,Leave_ID
    ) AS qry ON qry.For_Date = LT.For_Date and qry.Emp_ID = LT.Emp_ID and qry.Leave_ID = LT.Leave_ID 
    inner JOIN #Emp_Inout1 EO on LT.Emp_ID = EO.Emp_ID 
    inner JOIN T0040_LEAVE_MASTER LM on LM.Leave_ID = LT.Leave_ID
    Where  --LT.Leave_Closing <> 0 and 
			LM.Leave_Name <> 'LWP' 
			and isnull(lm.Display_leave_balance,0)=1
    
    --PRINT CONVERT(VARCHAR(20), GETDATE(), 114) + ' STEP 10'
    DECLARE @Leave_Name_1 VARCHAR(100)
	
		
    DECLARE Att_Master CURSOR FOR  
    SELECT distinct  Leave_Name + '_Closing' FROM #Leave_Balance group by Leave_Name
    
    OPEN Att_Master
    FETCH NEXT FROM Att_Master into @Leave_Name_1
    WHILE @@FETCH_STATUS = 0
        BEGIN
            --PRINT CONVERT(VARCHAR(20), GETDATE(), 114) + ' STEP 10:01'
            SET @Leave_Name_1=replace(@Leave_Name_1,' ','_')
            SET @Leave_Name_1=replace(@Leave_Name_1,'-','_')
            SET @test ='alter  table #Emp_Inout ADD ['+ @Leave_Name_1 +']  decimal(18,2) default ''''' 
                 
			
          IF @Col_Str = ''
                SET @Col_Str =  'Case When OrderColumns = 1 Then ' + @Leave_Name_1 + ' Else Null End AS ' + @Leave_Name_1
            else
                SET @Col_Str = @Col_Str + ',' + 'Case When OrderColumns = 1 Then ' + @Leave_Name_1 + ' Else Null End AS ' + @Leave_Name_1 --@Leave_Name_1   

            IF @Col_Str_Sum = ''
                SET @Col_Str_Sum =  'SUM(Isnull('+ @Leave_Name_1 + ',0)) AS ' + @Leave_Name_1 + ''
            else
                SET @Col_Str_Sum = @Col_Str_Sum + ',' + 'SUM(Isnull('+ @Leave_Name_1 + ',0)) AS ' + @Leave_Name_1 + ''

            exec(@test)         
            SET @test=''
            --PRINT CONVERT(VARCHAR(20), GETDATE(), 114) + ' STEP 10:02'
            
            --SET @test1 ='Update EI  SET '+ @Leave_Name_1 + ' = LB.Leave_Closing FROM #Emp_Inout EI inner join #Leave_Balance LB on  LB.EMP_ID = EI.Emp_ID and replace(LB.Leave_Name,'' '',''_'') = ''' + @Leave_Name_1 + ''''
            SET @test1 ='Update EI  SET '+ @Leave_Name_1 + ' = LB.Leave_Closing FROM #Emp_Inout EI inner join( SELECT Min(For_Date) AS For_Date FROM #Emp_Inout group by Emp_ID) qry on qry.For_Date = EI.For_Date inner join #Leave_Balance LB on  LB.EMP_ID = EI.Emp_ID and replace(LB.Leave_Name,'' '',''_'')+''_Closing'' = ''' + @Leave_Name_1 + ''''
           
            exec(@test1)
            SET @test1=''  
            --PRINT CONVERT(VARCHAR(20), GETDATE(), 114) + ' STEP 10:03'
            
            FETCH NEXT FROM Att_Master INTO @Leave_Name_1
        End 
    CLOSE Att_Master         
    DEALLOCATE Att_Master 
    
    --PRINT CONVERT(VARCHAR(20), GETDATE(), 114) + ' STEP 11'

    IF @Col_Str = ''
        BEGIN
            SET @Col_Str =  'Case When OrderColumns = 1 Then Leave_Closing Else Null End AS Leave_Closing ' 
            SET @Col_Str_Sum =  '0 AS Leave_Closing'
        END


    Update #Consolidated_Temp SET P_days = Isnull(E.P_days,0)
        From #Consolidated_Temp T Inner Join (SELECT Emp_Id, Sum(P_days) P_Days FROM #Emp_Inout Group by emp_id) E on T.Emp_Id=E.emp_id 
    Where Pvtcolumns = 'In_Time'

    Update #Consolidated_Temp SET A_days = E.A_days 
        From #Consolidated_Temp T Inner Join (SELECT Emp_Id, Sum(A_days) A_Days FROM #Emp_Inout Group by emp_id) E on T.Emp_Id=E.emp_id 
    Where Pvtcolumns = 'In_Time'

    --Update #Consolidated_Temp SET Weekoff = E.Weekoff
    --    From #Consolidated_Temp T Inner Join (SELECT Emp_Id, Count(AB_LEAVE) Weekoff FROM #Emp_Inout WHERE AB_LEAVE = 'WO' or AB_LEAVE = 'WO-C'  Group by emp_id) E on T.Emp_Id=E.emp_id 
    --Where Pvtcolumns = 'In_Time'

     Update #Consolidated_Temp SET Weekoff = E.Weekoff
     From #Consolidated_Temp T Inner Join (SELECT Emp_Id, Sum(WeekOff_Days) Weekoff FROM #Emp_Inout Group by emp_id) E on T.Emp_Id=E.emp_id 
     Where Pvtcolumns = 'In_Time'
  
    Update #Consolidated_Temp SET Holiday = E.Holiday
        From #Consolidated_Temp T Inner Join (SELECT Emp_Id, Count(AB_LEAVE) Holiday FROM #Emp_Inout WHERE AB_LEAVE = 'HO' or AB_LEAVE = 'HO-C' or AB_Leave = 'OHO' Group by emp_id) E on T.Emp_Id=E.emp_id 
    Where Pvtcolumns = 'In_Time'
    --PRINT CONVERT(VARCHAR(20), GETDATE(), 114) + ' STEP 12'
	
	---Add By Jignesh 19-12-2019----
	Update #Consolidated_Temp SET Leave = E.Leave
        From #Consolidated_Temp T Inner Join (SELECT Emp_Id, Sum(Leave_Days) Leave FROM #Emp_Inout where Isnull(Leave_Days,0)>0 Group by emp_id) E on T.Emp_Id=E.emp_id 
    Where Pvtcolumns = 'In_Time'
            
    CREATE table #Leave_Count_Pivot(Emp_id NUMERIC,ID INT);

    SET     @ALTER_COLS = null
    Select  @ALTER_COLS = COALESCE(@ALTER_COLS + ';', '') + 'ALTER TABLE  #Leave_Count_Pivot ADD ' + DATA + ' VARCHAR(32)' FROM dbo.Split(@colsPivot_leave, ',');
    EXEC (@ALTER_COLS);


    --PRINT CONVERT(VARCHAR(20), GETDATE(), 114) + ' STEP 13'

    SET @query = 'insert into #Leave_Count_Pivot SELECT Emp_id,1 AS ID,'+@colsPivot_leave+' 
       from (SELECT Emp_ID,Leave_Name,Leave_Days FROM #leave) 
            as data pivot 
            ( sum(Leave_Days) 
            for Leave_Name in ('+ @colsPivot_leave +') ) p' 
            
    --PRINT CONVERT(VARCHAR(20), GETDATE(), 114) + ' STEP 14'
    CREATE table #Final_Table(Emp_ID NUMERIC,OrderColumns NUMERIC, PvtColumns VARCHAR(32));

    SET     @ALTER_COLS = null
    Select  @ALTER_COLS = COALESCE(@ALTER_COLS + ';', '') + 'ALTER TABLE  #Final_Table ADD ' + DATA + ' VARCHAR(20)' FROM dbo.Split(@cols, ',');
    EXEC (@ALTER_COLS);
    ALTER TABLE  #Final_Table ADD P_Days VARCHAR(10);
    ALTER TABLE  #Final_Table ADD A_Days VARCHAR(10);
    ALTER TABLE  #Final_Table ADD Weekoff VARCHAR(10);
    ALTER TABLE  #Final_Table ADD Holiday VARCHAR(10);
    ALTER TABLE  #Final_Table ADD Leave VARCHAR(10);
    
    SET     @ALTER_COLS = null
    Select  @ALTER_COLS = COALESCE(@ALTER_COLS + ';', '') + 'ALTER TABLE  #Final_Table ADD ' + DATA + ' VARCHAR(20)' FROM dbo.Split(@colsPivot_leave, ',');
    EXEC (@ALTER_COLS);
    --PRINT CONVERT(VARCHAR(20), GETDATE(), 114) + ' STEP 15'
    IF not @query Is null       
        Begin
            exec(@query)
            
            SET @query= 'Insert INTO #Final_Table SELECT * FROM ( SELECT C.Emp_Id,OrderColumns,PvtColumns,' + @Cols1 + ',P_Days,A_Days,Weekoff,Holiday,Leave,' + @colsPivot_leave + ' FROM #consolidated_Temp C Left Outer Join #Leave_Count_Pivot L On C.Emp_Id = L.Emp_Id and C.OrderColumns = L.Id
                Where PvtColumns = ''In_Time'' or PvtColumns = ''Out_Time''
                Union
                SELECT C.Emp_Id,OrderColumns,PvtColumns,' + @Cols + ',P_Days,A_Days,Weekoff,Holiday,Leave,' + @colsPivot_leave + 'from #consolidated_Temp C Left Outer Join #Leave_Count_Pivot L On C.Emp_Id = L.Emp_Id and C.OrderColumns = L.Id
                Where PvtColumns = ''Duration'' or PvtColumns = ''WOHO'' or PvtColumns = ''Shift_Time'' or PvtColumns = ''OverTime'' or PvtColumns = ''Late_Hrs'')p'

                    
        End

    Else
        Begin

            SET @query= 'Insert INTO #Final_Table SELECT * FROM (SELECT C.Emp_Id,OrderColumns,PvtColumns,' + @Cols1 + ',P_Days,A_Days,Weekoff,Holiday,Leave FROM #consolidated_Temp C 
                Where PvtColumns = ''In_Time'' or PvtColumns = ''Out_Time''
                Union
                SELECT C.Emp_Id,OrderColumns,PvtColumns,' + @Cols + ',P_Days,A_Days,Weekoff,Holiday,Leave FROM #consolidated_Temp C 
                Where PvtColumns = ''Duration'' or PvtColumns = ''WOHO'' or PvtColumns = ''Shift_Time'' or PvtColumns = ''OverTime'' or PvtColumns = ''Late_Hrs'')p '
        End
   
       exec(@query)



    --PRINT CONVERT(VARCHAR(20), GETDATE(), 114) + ' STEP 16'
    --Added by Jaina 17-11-2017
    if @Comp_OD_As_Present = 1
        begin
            UPDATE A
                SET P_DAYS =cast(Round(A.P_DAYS + Isnull(Q1.OD_Compoff,0),2) as numeric(18,2)) --Q.P_DAYS + ISNULL(Q1.OD_COMPOFF,0)
            FROM #Final_Table A     LEFT OUTER JOIN 
                    (select sum((IsNull(LT.CompOff_Used,0) + IsNull(LT.Leave_Used,0)) * CASE WHEN LM.Apply_Hourly = 1 THEN 0.125 ELSE 1 END)  AS OD_Compoff,lt.Emp_ID
                    from    T0140_LEAVE_TRANSACTION LT 
                            INNER JOIN  T0040_LEAVE_MASTER LM ON LT.Leave_ID=LM.Leave_ID                        
                    where   (Leave_Type='Company Purpose' OR Leave_Code = 'COMP') and LT.Cmp_ID=@Cmp_ID
                            AND LT.FOR_DATE BETWEEN @FROM_DATE AND @TO_dATE
                    group by Emp_ID
                    )Q1 on A.Emp_ID = Q1.Emp_ID 
        end 

	 

    DECLARE @Columns AS nVARCHAR(max)
    SET @Columns = @Cols
    --SELECT @Columns = STUFF((SELECT ',' + QUOTENAME(COLUMN_NAME) FROM INFORMATION_SCHEMA.COLUMNS
    --WHERE TABLE_NAME = '#Final_Table' And COLUMN_NAME Not like 'OrderColumns' And COLUMN_NAME Not like 'Emp_id' And COLUMN_NAME Not like'PvtColumns'
    --                      FOR XML PATH('')) ,1, 1, '') 
    

    IF (@Order_By = 'Code') 
        SET @Order_By = 'Alpha_Emp_Code'
    ELSE IF (@Order_By = 'Name') 
        SET @Order_By = 'Emp_Full_Name'
    ELSE IF (@Order_By = 'Designation')
        SET @Order_By = 'Desig_Dis_No'
    ELSE IF (@Order_By = '') 
        SET @Order_By = 'F.Emp_ID'

    SET @query = 'SELECT Case When OrderColumns = 1 Then Row_No Else NULL End AS Sr_No,
                        Case When OrderColumns = 1 Then Alpha_Emp_Code Else Null End Emp_Code,
                        Case When OrderColumns = 1 Then Emp_Full_Name Else Null End Emp_Name, 
                        Case When OrderColumns = 1 Then Branch_Name Else Null End Branch_Name, 
                        Case When OrderColumns = 1 Then Grd_Name Else Null End Grade_Name,                  
                        Case When OrderColumns = 1 Then Desig_Name Else Null End Designation_Name,
                        Case When OrderColumns = 1 Then dept_name Else Null End Department_name,
                        Case When OrderColumns = 1 Then Type_Name Else Null End Type_Name,
                        case when OrderColumns = 1 Then SCM.Name Else Null End AS Salary_Cycle,
                        case when OrderColumns = 1 Then BS.Segment_Name Else Null End AS Segment_Name,
                        case when OrderColumns = 1 Then VS.Vertical_Name Else Null End AS Vertical_Name,
                        case when OrderColumns = 1 Then SV.SubVertical_Name Else Null End AS SubVertical_Name,
                        case when OrderColumns = 1 Then SB.SubBranch_Name Else Null End AS SubBranch_Name,
                        case when OrderColumns = 1 Then B.Branch_Id Else Null End AS Branch_Id,
                        case when OrderColumns = 1 Then DD.Desig_Dis_No Else Null End AS Desig_Dis_No,
                        PvtColumns AS Description,
                        '+  @Columns + ' ,
                        Case When OrderColumns = 1 Then P_Days Else Null End P_Days,
                        Case When OrderColumns = 1 Then A_Days Else Null End A_Days,
                        Case When OrderColumns = 1 Then Weekoff Else Null End Weekoff,
                        Case When OrderColumns = 1 Then Holiday Else Null End Holiday,
                        Case When OrderColumns = 1 Then Leave Else Null End Leave,
                        Case When OrderColumns = 1 Then Late_Days Else Null End Late_Days,
                        Case When OrderColumns = 1 Then Early_Days Else Null End Early_Days,
                        Case When OrderColumns = 1 Then Late_In_Hours Else Null End Late_In_Hours,
                        Case When OrderColumns = 1 Then Early_Out_Hours Else Null End Early_Out_Hours,
                        Case When OrderColumns = 1 Then Total_Hours Else Null End Required_Working_Hours,
                        Case When OrderColumns = 1 Then Total_Require Else Null End Actual_Worked_Hours,
                        Case When OrderColumns = 1 Then Total_Short_hours Else Null End Short_Hours,
                        Case When OrderColumns = 1 Then OT_Hours Else Null End OT_Hours,
                        '+  @Col_Str + '
                        --Case When OrderColumns = 1 Then NameOne Else Null End NameOne
                        --Case when OrderColumns = 1 Then SCM.Name Else Null End SCM.Name
                        
                        --SCM.Name AS Salary_Cycle,
                        
                From #Final_Table F Inner Join 
                (SELECT Emp_Id,Grd_Id,Branch_Id,Desig_ID,Dept_Id,Type_Id, dbo.F_Return_Hours(sum(late_in_sec)) AS Late_In_Hours,
                        dbo.F_Return_Hours(sum(Early_Out_sec)) AS Early_Out_Hours, dbo.F_Return_Hours(sum(Total_More_work_Sec)) AS OT_Hours,
                        count(case when Late_In_sec = 0 then Null else 1 end) AS Late_Days,
                        count(case when Early_Out_sec = 0 then Null else 1 end) AS Early_Days,dbo.F_Return_Hours(SUM(Shift_Sec)) AS Total_Hours,dbo.F_Return_Hours(SUM(Total_Work_Sec)) AS Total_Require, dbo.F_Return_Hours(SUM(Total_Less_work_sec)) AS Total_Short_hours,'+ @Col_Str_Sum + '
                    From #Emp_Inout Group by Emp_Id,Grd_Id,Branch_Id,Desig_ID,Dept_Id,Type_Id) Q on F.Emp_Id = Q.Emp_Id inner Join 
                    (SELECT I.Emp_Id,I.Increment_ID,I.Vertical_ID,I.SubVertical_ID,I.subBranch_ID,I.SalDate_id,I.Segment_ID,I.Increment_effective_Date FROM dbo.T0095_Increment I inner join dbo.T0080_Emp_Master e on i.Emp_ID = E.Emp_ID inner join
                    (SELECT Max(TI.Increment_ID) Increment_Id,ti.Emp_ID FROM t0095_increment TI inner join
                    (SELECT Max(Increment_Effective_Date) AS Increment_Effective_Date,Emp_ID FROM T0095_Increment
                    Where Increment_effective_Date <='''+ cast(@to_date AS VARCHAR(max))+''' Group by emp_ID) new_inc
                    on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date              
                    Where TI.Increment_effective_Date <= '''+ cast(@to_date AS VARCHAR(max))+''' group by ti.emp_id) I_Q on I_Q.Emp_ID=I.emp_id and I_Q.Increment_ID=I.Increment_ID) Qry on Qry.Emp_ID=F.Emp_ID inner join
                T0030_Branch_Master B On Q.Branch_Id = B.Branch_Id Inner Join
                T0080_Emp_Master E on Q.Emp_Id = E.Emp_Id Left Outer Join
                T0040_Grade_Master G on Q.Grd_Id = G.Grd_Id Left Outer Join
                T0040_DEPARTMENT_MASTER D on Q.Dept_Id = D.Dept_Id Left Outer Join
                T0040_Designation_Master DD on Q.Desig_Id = DD.Desig_Id Left Outer Join
                T0040_Type_Master T on Q.Type_Id = T.Type_Id left join
                --T0095_Emp_Salary_Cycle ESC on ESC.Emp_ID=Q.Emp_ID left join
                T0040_Salary_Cycle_Master SCM on SCM.Tran_ID=Qry.SalDate_id left join
                T0040_Business_Segment BS on BS.Segment_ID=Qry.Segment_ID left join
                T0040_Vertical_Segment VS on VS.Vertical_ID=Qry.Vertical_ID left join
                T0050_SubVertical SV on SV.SubVertical_ID=Qry.SubVertical_ID left join
                T0050_SubBranch SB on SB.SubBranch_ID=Qry.SubBranch_ID inner join 
                (SELECT Row_Number() OVER(Order By ' + @Order_By + ') AS Row_No, T.emp_id AS empid FROM 
                    (SELECT Emp_ID,Desig_ID FROM #Emp_Inout Group By Emp_ID,Desig_ID) T INNER JOIN T0080_EMP_MASTER E ON T.Emp_ID=E.Emp_ID left outer join T0040_Designation_Master DD on DD.Desig_Id = T.Desig_ID) RID on RID.empid=Q.Emp_ID
                Order by RID.Row_No,F.OrderColumns'


    Exec(@Query)

 RETURN      

