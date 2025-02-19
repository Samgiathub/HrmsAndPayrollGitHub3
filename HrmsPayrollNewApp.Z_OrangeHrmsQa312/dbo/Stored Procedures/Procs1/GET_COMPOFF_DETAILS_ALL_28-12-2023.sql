    
    
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---    
Create PROCEDURE [dbo].[GET_COMPOFF_DETAILS_ALL_28-12-2023]     
 @For_Date datetime,    
 @Cmp_ID numeric(18,0),    
 @Constraint  Varchar(max),    
 @leave_ID numeric(18,0),    
 @Exec_For numeric(18,0) = 0    
AS    
BEGIN    
SET NOCOUNT ON     
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED    
SET ARITHABORT ON    
    
 CREATE table #Weekday_OT    
 (    
  Weekday_OT_Trans  numeric,    
  Cmp_ID     numeric,    
  Emp_ID     numeric,    
  For_Date    datetime,    
  CompOff_Credit   numeric(18,2),    
  CompOff_Debit   numeric(18,2),    
  CompOff_balance   numeric(18,2),    
  Branch_ID    numeric,    
  Is_CompOff    numeric,    
  CompOff_Days_Limit  numeric,    
  CompOff_Type   varchar(2)    
 )    
 CREATE table #WeekOff_OT    
 (    
  WeekOff_OT_Trans  numeric,    
  Cmp_ID     numeric,    
  Emp_ID     numeric,    
  For_Date    datetime,    
  CompOff_Credit   numeric(18,2),    
  CompOff_Debit   numeric(18,2),    
  CompOff_balance   numeric(18,2),    
  Branch_ID    numeric,    
  Is_CompOff    numeric,    
  CompOff_Days_Limit  numeric,    
  CompOff_Type   varchar(2)    
 )    
 CREATE table #Holiday_OT    
 (    
  Holiday_OT_Trans  numeric,    
  Cmp_ID     numeric,    
  Emp_ID     numeric,    
  For_Date    datetime,    
  CompOff_Credit   numeric(18,2),    
  CompOff_Debit   numeric(18,2),    
  CompOff_balance   numeric(18,2),    
  Branch_ID    numeric,    
  Is_CompOff    numeric,    
  CompOff_Days_Limit  numeric,    
  CompOff_Type   varchar(2)    
 )    
 CREATE table #General_OT    
 (    
  Leave_Tran_ID   numeric,    
  Cmp_ID     numeric,    
  Emp_ID     numeric,    
  For_Date    datetime,    
  CompOff_Credit   numeric(18,2),    
  CompOff_Debit   numeric(18,2),    
  CompOff_balance   numeric(18,2),    
  Branch_ID    numeric,    
  Is_CompOff    numeric,    
  CompOff_Days_Limit  numeric,    
  CompOff_Type   varchar(2)    
 )    
     
    
 CREATE TABLE #Emp_Cons     
 (          
  Emp_ID numeric ,         
  Branch_ID numeric,    
  Increment_ID numeric    
 )          
      
 EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@For_Date,@For_Date,0,0,0,0,0,0,0,@constraint ,0 ,0 ,0,0,0,0,0,0,0,0,0,0    
     
 CREATE UNIQUE CLUSTERED INDEX IX_EMP_CONS_EMPID ON #Emp_Cons (EMP_ID,Increment_ID);    
  --select * from #Emp_Cons--mansi    
    
 CREATE TABLE #EMP_SETTING    
 (    
  Emp_ID Numeric,    
  Holiday_CompOff_Limit numeric,    
  Holiday_From_Date varchar(11),    
  Weekoff_CompOff_Limit numeric,    
  Weekoff_From_Date varchar(11),    
  Weekday_CompOff_Limit numeric,    
  Weekday_From_Date varchar(11)    
 )    
    
 INSERT INTO #EMP_SETTING(EMP_ID,Weekday_CompOff_Limit,Weekoff_CompOff_Limit,Holiday_CompOff_Limit)    
 SELECT E.EMP_ID, E.CompOff_WD_Avail_Days,E.CompOff_WO_Avail_Days,E.CompOff_HO_Avail_Days     
 FROM T0080_EMP_MASTER E WITH (NOLOCK) INNER JOIN #EMP_CONS EC ON E.EMP_ID=EC.EMP_ID    
    
    
     
 Declare @Emp_Week_Detail numeric(18,0)    
 --Declare @Weekoff_Days   Numeric(12,1)     
 --Declare @StrHoliday_Date varchar(Max)    
 --Declare @StrWeekoff_Date varchar(Max)    
 --Declare @Is_Cancel_Holiday Int    
 Declare @strweekoff varchar(max)    
 --Declare @Cancel_Weekoff   Numeric(12,1)     
 --Declare @Holiday_days Numeric(18,2)    
 --Declare @Cancel_Holiday Numeric(18,2)     
 Declare @Week_oF_Branch numeric(18,0)    
     
     
    
 CREATE TABLE #GENERAL_SETTING    
 (    
  Branch_ID Numeric,    
  Is_Cancel_weekoff TinyInt,    
  tras_week_ot TinyInt,    
  Auto_OT TinyInt,    
  OT_Present TinyInt,    
  Is_Compoff TinyInt,     
  Is_WD TinyInt,     
  Is_WOHO TinyInt,    
  Is_Cancel_Holiday TinyInt,     
  Is_HO_CompOff TinyInt,     
  Is_W_CompOff TinyInt,      
  Weekday_CompOff_Limit_BranchWise Numeric,    
  Holiday_CompOff_Limit_BranchWise Numeric,    
  Weekoff_CompOff_Limit_BranchWise Numeric     
 )    
    
 INSERT INTO #GENERAL_SETTING(Branch_ID, Is_Cancel_weekoff,tras_week_ot,Auto_OT,OT_Present,Is_Compoff,Is_WD,Is_WOHO,Is_Cancel_Holiday,    
   Is_HO_CompOff,Is_W_CompOff,Weekday_CompOff_Limit_BranchWise,Holiday_CompOff_Limit_BranchWise,Weekoff_CompOff_Limit_BranchWise)    
 SELECT B.Branch_ID, Is_Cancel_weekoff,tras_week_ot,Is_OT_Auto_Calc,OT_Present_days,Is_Compoff,Is_CompOff_WD,Is_CompOff_WOHO,Is_Cancel_Holiday,    
   Is_HO_CompOff,Is_W_CompOff,CompOff_Avail_Days,H_CompOff_Avail_Days,W_CompOff_Avail_Days    
 FROM (SELECT DISTINCT BRANCH_ID FROM #Emp_Cons ) B    
   INNER JOIN T0040_GENERAL_SETTING G WITH (NOLOCK) ON B.Branch_ID=G.Branch_ID    
   INNER JOIN (SELECT G1.Branch_ID, MAX(FOR_DATE) AS FOR_DATE    
      FROM T0040_GENERAL_SETTING G1 WITH (NOLOCK)    
      WHERE G1.FOR_DATE <= @For_Date    
      GROUP BY G1.Branch_ID) G1 ON G.Branch_ID=G1.Branch_ID AND G.For_Date=G1.FOR_DATE    
    
 Update ES    
 SET  Weekday_CompOff_Limit = Case When IsNull(Weekday_CompOff_Limit, 0) = 0 THEN Weekday_CompOff_Limit_BranchWise Else Weekday_CompOff_Limit END,    
   Weekoff_CompOff_Limit = Case When IsNull(Weekoff_CompOff_Limit, 0) = 0 THEN Weekoff_CompOff_Limit_BranchWise Else Weekoff_CompOff_Limit END,    
   Holiday_CompOff_Limit = Case When IsNull(Holiday_CompOff_Limit, 0) = 0 THEN Holiday_CompOff_Limit_BranchWise Else Holiday_CompOff_Limit END    
 FROM #EMP_SETTING ES INNER JOIN    
   #EMP_CONS EC ON ES.Emp_ID = EC.EMP_ID INNER JOIN    
   #GENERAL_SETTING GS ON GS.Branch_ID = EC.Branch_ID    
    
    
 Update ES    
 SET  Weekday_CompOff_Limit = Case When IsNull(Weekday_CompOff_Limit, 0) = 0 THEN 60 Else Weekday_CompOff_Limit END,    
   Weekoff_CompOff_Limit = Case When IsNull(Weekoff_CompOff_Limit, 0) = 0 THEN 60 Else Weekoff_CompOff_Limit END,    
   Holiday_CompOff_Limit = Case When IsNull(Holiday_CompOff_Limit, 0) = 0 THEN 60 Else Holiday_CompOff_Limit END    
 FROM #EMP_SETTING ES    
 Where IsNull(Weekday_CompOff_Limit, 0) = 0 Or IsNull(Weekoff_CompOff_Limit, 0) = 0 Or IsNull(Holiday_CompOff_Limit, 0) = 0    
     
     
 Update ES    
 SET  Holiday_From_Date = Convert(varchar(11),DATEADD(D,isnull(Holiday_CompOff_Limit,0) * -1,@For_Date)),  --Updated by Jaina 21-04-2020    
   Weekoff_From_Date = Convert(varchar(11),DATEADD(D,isnull(Weekoff_CompOff_Limit,0)* -1,@For_Date)),    
   Weekday_From_Date = Convert(varchar(11),DATEADD(D,isnull(Weekday_CompOff_Limit,0) * -1,@For_Date))    
 FROM #EMP_SETTING ES    
     
    
     
 --declare @Holiday_CompOff_Limit as numeric    
 --declare @Holiday_From_Date as varchar(11)    
 --Declare @Weekoff_CompOff_Limit as numeric    
 --declare @Weekoff_From_Date as varchar(11)    
 --Declare @Weekday_CompOff_Limit as numeric    
 --declare @Weekday_From_Date as varchar(11)    
     
 --Declare @Weekday_CompOff_Limit_BranchWise as numeric    
 --declare @Holiday_CompOff_Limit_BranchWise as numeric    
 --Declare @Weekoff_CompOff_Limit_BranchWise as numeric    
 -- Added by Gadriwala Muslim 13052015 - Start    
 Declare @CompOff_with_Current_Date as tinyint     
     
 set @CompOff_with_Current_Date  = 0    
 select  @CompOff_with_Current_Date = Setting_Value  from T0040_SETTING WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Setting_Name='Comp-off Balance show as on date wise'    
 IF @CompOff_with_Current_Date = 1     
  set @For_Date = GETDATE()    
      
 -- Added by Gadriwala Muslim 13052015 - End    
     
     
 --select @branch_id = branch_id from dbo.T0095_INCREMENT    
 --where Emp_ID = @Emp_ID and Increment_ID =     
 --(select MAX(Increment_ID) from dbo.T0095_INCREMENT where Emp_ID = @Emp_ID and cmp_ID = @cmp_ID and Increment_Effective_Date<=@For_Date)    
     
     
 -- First Employeewise Limit Setting    
 --select @Weekday_CompOff_Limit = CompOff_WD_Avail_Days ,    
 --    @Weekoff_CompOff_Limit =CompOff_WO_Avail_Days,     
 --    @Holiday_CompOff_Limit= CompOff_HO_Avail_Days     
 --from dbo.T0080_EMP_MASTER where Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID    
     
 --Select @Is_Cancel_weekoff = Is_Cancel_weekoff ,    
 --  @tras_week_ot=isnull(tras_week_ot,0)  ,    
 --  @Auto_OT = Is_OT_Auto_Calc ,    
 --  @OT_Present = OT_Present_days,    
 --  @Is_Compoff = ISNULL(Is_CompOff, 0),     
 --  @Is_WD = ISNULL(Is_CompOff_WD,0),     
 --  @Is_WOHO = ISNULL(Is_CompOff_WOHO,0),    
 --  @Is_Cancel_Holiday = Is_Cancel_Holiday ,     
 --  @Is_HO_CompOff = Is_HO_CompOff,     
 --  @Is_W_CompOff = Is_W_CompOff,      
 --  @Weekday_CompOff_Limit_BranchWise = isnull(CompOff_Avail_Days,0),    
 --  @Holiday_CompOff_Limit_BranchWise = isnull(H_CompOff_Avail_Days,0),    
 --  @Weekoff_CompOff_Limit_BranchWise = isnull(W_CompOff_Avail_Days,0)     
 --From dbo.T0040_GENERAL_SETTING where cmp_ID = @cmp_ID and Branch_ID = @branch_id    
 --  and For_Date = ( select max(For_Date) from dbo.T0040_GENERAL_SETTING     
 --where For_Date <= @For_Date and Branch_ID = @branch_id and Cmp_ID = @Cmp_ID)        
     
 --Second Branchwise Limit Setting     
 --If @Weekday_CompOff_Limit = 0     
 -- set @Weekday_CompOff_Limit = isnull(@Weekday_CompOff_Limit_BranchWise,0)    
 --If @Holiday_CompOff_Limit = 0     
 -- set @Holiday_CompOff_Limit = isnull(@Holiday_CompOff_Limit_BranchWise,0)    
 --If @Weekoff_CompOff_Limit = 0     
 -- set @Weekoff_CompOff_Limit = isnull(@Weekoff_CompOff_Limit_BranchWise,0)    
     
     
 -- Third Default Limit Setting if Employee & Branch wise Zero    
 --if  @Weekday_CompOff_Limit = 0     
 -- set @Weekday_CompOff_Limit = 60    
 --if  @Holiday_CompOff_Limit = 0     
 -- set @Holiday_CompOff_Limit = 60    
 --if @Weekoff_CompOff_Limit = 0    
 -- set @Weekoff_CompOff_Limit = 60    
     
      
 --set  @Holiday_From_Date = Convert(varchar(25),DATEADD(D,@Holiday_CompOff_Limit * -1,@For_Date))      
 --set  @Weekoff_From_Date = Convert(varchar(25),DATEADD(D,@Weekoff_CompOff_Limit * -1,@For_Date))    
 --set  @Weekday_From_Date = Convert(varchar(25),DATEADD(D,@Weekday_CompOff_Limit * -1,@For_Date))      
    
 /********************************************************************    
 Added by Nimesh : Using new employee weekoff/holiday stored procedure    
 *********************************************************************/    
 IF OBJECT_ID('tempdb..#Emp_WeekOff') IS NULL    
 BEGIN    
  --Holiday & WeekOff - In colon(;) seperated string (Without Cancel) : Used in SP_CALCULATE_PRESENT_DAYS    
  CREATE TABLE #Emp_WeekOff_Holiday    
  (    
   Emp_ID    NUMERIC,    
   WeekOffDate   VARCHAR(Max),    
   WeekOffCount  NUMERIC(4,1),    
   HolidayDate   VARCHAR(Max),    
   HolidayCount  NUMERIC(4,1),    
   HalfHolidayDate  VARCHAR(Max),    
   HalfHolidayCount NUMERIC(4,1),    
   OptHolidayDate  VARCHAR(Max),    
   OptHolidayCount  NUMERIC(4,1)    
  )    
     
  --Holiday - by Date : Used in SP_RPT_EMP_ATTENDANCE_MUSTER_GET_ALL    
  CREATE TABLE #EMP_HOLIDAY(EMP_ID NUMERIC, FOR_DATE DATETIME, IS_CANCEL BIT, Is_Half tinyint, Is_P_Comp tinyint, H_DAY numeric(4,1));    
  CREATE UNIQUE CLUSTERED INDEX IX_EMP_HOLIDAY_EMPID_FORDATE ON #EMP_HOLIDAY(EMP_ID, FOR_DATE);    
     
  --WeekOff - by Date : Used in SP_RPT_EMP_ATTENDANCE_MUSTER_GET_ALL    
  CREATE TABLE #Emp_WeekOff    
  (    
   Row_ID   NUMERIC,    
   Emp_ID   NUMERIC,    
   For_Date  DATETIME,    
   Weekoff_day  VARCHAR(10),    
   W_Day   numeric(4,1),    
   Is_Cancel  BIT    
  )    
  CREATE CLUSTERED INDEX IX_Emp_WeekOff_EMPID_FORDATE ON #Emp_WeekOff(Emp_ID,For_Date);    
      
      
  --Holiday & Weekoff - In colon(;) seperated string (With Cancel) : Used in SP_CALCULATE_PRESENT_DAYS    
  CREATE TABLE #EMP_HW_CONS    
  (    
   Emp_ID    NUMERIC,    
   WeekOffDate   Varchar(Max),    
   WeekOffCount  NUMERIC(4,1),    
   CancelWeekOff  Varchar(Max),    
   CancelWeekOffCount NUMERIC(4,1),    
   HolidayDate   Varchar(MAX),    
   HolidayCount  NUMERIC(4,1),    
   HalfHolidayDate  Varchar(MAX),    
   HalfHolidayCount NUMERIC(4,1),    
   CancelHoliday  Varchar(Max),    
   CancelHolidayCount NUMERIC(4,1)    
  )    
  CREATE UNIQUE CLUSTERED INDEX IX_EMP_HW_CONS_EmpID ON #EMP_HW_CONS(Emp_ID)    
      
      
  --EXEC SP_GET_HW_ALL @CONSTRAINT=@CONSTRAINT,@CMP_ID=@Cmp_ID, @FROM_DATE=@FROM_DATE, @TO_DATE=@TO_DATE, @All_Weekoff = 0, @Exec_Mode=0    
      
  --Here Condition is Added By Ramiz on 14/04/2016 after discussion with Hardik Bhai    
  DECLARE @HW_FROM_DATE DATETIME    
  DECLARE @HW_TO_DATE DATETIME    
    
  SELECT @HW_FROM_DATE  = Min(Case When Weekday_From_Date < Weekoff_From_Date AND Weekday_From_Date < Holiday_From_Date Then Weekday_From_Date    
          When Weekoff_From_Date < Weekday_From_Date AND Weekoff_From_Date < Holiday_From_Date Then Weekoff_From_Date    
          When Holiday_From_Date < Weekday_From_Date AND Holiday_From_Date < Weekoff_From_Date Then Holiday_From_Date    
         END),    
    @HW_TO_DATE  = Min(Case When Weekday_From_Date > Weekoff_From_Date AND Weekday_From_Date > Holiday_From_Date Then Weekday_From_Date    
          When Weekoff_From_Date > Weekday_From_Date AND Weekoff_From_Date > Holiday_From_Date Then Weekoff_From_Date    
          When Holiday_From_Date > Weekday_From_Date AND Holiday_From_Date > Weekoff_From_Date Then Holiday_From_Date    
         END)    
  FROM #EMP_SETTING    
    
  EXEC SP_GET_HW_ALL @CONSTRAINT=@CONSTRAINT,@CMP_ID=@Cmp_ID, @FROM_DATE=@HW_FROM_DATE, @TO_DATE=@HW_TO_DATE, @All_Weekoff = 0, @Exec_Mode=0    
      
 END    
    
     
     
 ---- Auto CarryFoward Compoff Leave --Ankit 01022016    
 IF @Exec_For = 55 /* 55 : Auto CarryForward SQL Job : SP--P_JOB_GET_COMPOFF_BALANCE_AUTOCREDIT */    
  BEGIN    
   --SET @For_Date = @Weekoff_From_Date    
   --SET @Weekoff_From_Date = Convert(varchar(25),DATEADD(D,@Weekoff_CompOff_Limit * -1,@Weekoff_From_Date))    
   SELECT @For_Date = Weekoff_From_Date FROM #EMP_SETTING     
   UPDATE #EMP_SETTING SET Weekday_From_Date = Convert(varchar(25),DATEADD(D,Weekoff_CompOff_Limit * -1,Weekoff_From_Date))    
  END    
     
 --set @StrWeekoff_Date=''    
 --set @Weekoff_Days=0    
 --set @Cancel_Weekoff=0    
      
 --Set @StrHoliday_Date =''    
 --Set @Holiday_days = 0    
 --Set @Cancel_Holiday =0    
      
 /*For WeekDay OT*/    
 Insert into #Weekday_OT (Weekday_OT_Trans,cmp_ID,Emp_ID,For_Date,CompOff_Credit,CompOff_Debit,CompOff_Balance,Branch_ID,    
        Is_CompOFF,CompOFF_Days_Limit,CompOff_Type)    
 SELECT Leave_Tran_ID,@Cmp_ID,LT.Emp_ID,LT.For_Date,Compoff_Credit,CompOFf_Debit,CompOFF_Balance,EC.Branch_ID,Comoff_Flag,Weekday_CompOff_Limit,'WD'        
 FROM dbo.T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)    
   INNER JOIN #Emp_Cons EC ON LT.Emp_ID=EC.Emp_ID     
   INNER JOIN #EMP_SETTING ES ON LT.Emp_ID=ES.Emp_ID AND LT.For_Date BETWEEN ES.Weekday_From_Date AND @For_Date        
   INNER JOIN #GENERAL_SETTING G ON EC.Branch_ID=G.Branch_ID    
   LEFT OUTER JOIN #Emp_WeekOff W ON LT.For_Date=W.For_Date AND LT.Emp_ID=W.Emp_ID    
   LEFT OUTER JOIN #Emp_Holiday H ON LT.For_Date=H.For_Date AND LT.Emp_ID=H.Emp_ID    
 WHERE Leave_ID = @leave_ID AND Comoff_Flag = 1 AND (W.Emp_ID IS NULL AND H.Emp_Id IS NULL) AND Is_WD=1    
    
 /*For WeekOff OT*/    
 Insert into #Weekday_OT (Weekday_OT_Trans,cmp_ID,Emp_ID,For_Date,CompOff_Credit,CompOff_Debit,CompOff_Balance,Branch_ID,    
        Is_CompOFF,CompOFF_Days_Limit,CompOff_Type)    
 SELECT Leave_Tran_ID,@Cmp_ID,LT.Emp_ID,LT.For_Date,Compoff_Credit,CompOFf_Debit,CompOFF_Balance,EC.Branch_ID,Comoff_Flag,Weekday_CompOff_Limit,'WO'        
 FROM dbo.T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)    
   INNER JOIN #Emp_Cons EC ON LT.Emp_ID=EC.Emp_ID     
   INNER JOIN #EMP_SETTING ES ON LT.Emp_ID=ES.Emp_ID AND LT.For_Date BETWEEN ES.Weekday_From_Date AND @For_Date        
   INNER JOIN #GENERAL_SETTING G ON EC.Branch_ID=G.Branch_ID    
   INNER JOIN #Emp_WeekOff W ON LT.For_Date=W.For_Date AND LT.Emp_ID=W.Emp_ID        
 WHERE Leave_ID = @leave_ID AND Comoff_Flag = 1 AND Is_W_CompOff=1    
        
 /*For Holiday OT*/    
 Insert into #Weekday_OT (Weekday_OT_Trans,cmp_ID,Emp_ID,For_Date,CompOff_Credit,CompOff_Debit,CompOff_Balance,Branch_ID,    
        Is_CompOFF,CompOFF_Days_Limit,CompOff_Type)    
 SELECT Leave_Tran_ID,@Cmp_ID,LT.Emp_ID,LT.For_Date,Compoff_Credit,CompOFf_Debit,CompOFF_Balance,EC.Branch_ID,Comoff_Flag,Weekday_CompOff_Limit,'HO'        
 FROM dbo.T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)    
   INNER JOIN #Emp_Cons EC ON LT.Emp_ID=EC.Emp_ID     
   INNER JOIN #EMP_SETTING ES ON LT.Emp_ID=ES.Emp_ID AND LT.For_Date BETWEEN ES.Weekday_From_Date AND @For_Date        
   INNER JOIN #GENERAL_SETTING G ON EC.Branch_ID=G.Branch_ID    
   INNER JOIN #Emp_Holiday H ON LT.For_Date=H.For_Date AND LT.Emp_ID=H.Emp_ID        
 WHERE Leave_ID = @leave_ID AND Comoff_Flag = 1 AND Is_HO_CompOff=1    
      
  --If @Is_WD = 1    
  -- begin    
  --  --Exec dbo.SP_EMP_HOLIDAY_DATE_GET @emp_ID,@Cmp_ID,@Weekday_From_Date,@For_Date,null,null,@Is_Cancel_Holiday,@StrHoliday_Date output,@Holiday_days output,@Cancel_Holiday output,0,@Branch_ID,@StrWeekoff_Date    
  --  --Exec dbo.SP_EMP_WEEKOFF_DATE_GET @emp_ID,@Cmp_ID,@Weekday_From_Date,@For_Date,null,null,@Is_Cancel_weekoff,'',@StrWeekoff_Date output,@Weekoff_Days output ,@Cancel_Weekoff output        
        
  --  Insert into #Weekday_OT (Weekday_OT_Trans,cmp_ID,Emp_ID,For_Date,CompOff_Credit,CompOff_Debit,CompOff_Balance,Branch_ID,Is_CompOFF,CompOFF_Days_Limit,CompOff_Type)    
  --  select Leave_Tran_ID,@Cmp_ID,@Emp_ID,For_Date,Compoff_Credit,CompOFf_Debit,CompOFF_Balance,    
  --  @branch_id,Comoff_Flag,@Weekday_CompOff_Limit,'WD' from dbo.T0140_LEAVE_TRANSACTION     
  --  where Leave_ID = @leave_ID and For_Date >= @Weekday_From_Date and For_date <=@For_Date and Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID and Comoff_Flag = 1    
       
  --  delete from #Weekday_OT where For_Date  in (Select Data from dbo.Split(@StrWeekoff_Date,';') where Data <> '') and Cmp_ID =@Cmp_ID and Emp_ID =@Emp_ID    
  --  delete from #Weekday_OT where For_Date  in (Select Data from dbo.Split(@StrHoliday_Date,';') where Data <> '') and Cmp_ID =@Cmp_ID and Emp_ID =@Emp_ID    
  -- end     
  --if @Is_HO_CompOff = 1 and  ( @Weekday_CompOff_Limit <> @Holiday_CompOff_Limit or @Is_WD = 0)    
  -- Begin    
  --  Exec dbo.SP_EMP_HOLIDAY_DATE_GET @emp_ID,@Cmp_ID,@Holiday_From_Date,@For_Date,null,null,@Is_Cancel_Holiday,@StrHoliday_Date output,@Holiday_days output,@Cancel_Holiday output,0,@Branch_ID,@StrWeekoff_Date    
  -- End    
     
  --If @Is_W_CompOff = 1 and  ( @Weekday_CompOff_Limit <> @Weekoff_CompOff_Limit or @Is_WD = 0)    
  -- Begin    
  --  Exec dbo.SP_EMP_WEEKOFF_DATE_GET @emp_ID,@Cmp_ID,@Weekoff_From_Date,@For_Date,null,null,@Is_Cancel_weekoff,'',@StrWeekoff_Date output,@Weekoff_Days output ,@Cancel_Weekoff output        
  -- End    
      
  --If @StrHoliday_Date <> '' and @Is_HO_CompOff = 1    
  -- begin    
  --  Insert into #Holiday_OT (Holiday_OT_Trans,cmp_ID,Emp_ID,For_Date,CompOff_Credit,CompOff_Debit,CompOff_Balance,Branch_ID,Is_CompOFF,CompOFF_Days_Limit,CompOff_Type)    
  --   select Leave_Tran_ID,@Cmp_ID,@Emp_ID,For_Date,Compoff_Credit,CompOFf_Debit,CompOFF_Balance,    
  --   @branch_id,Comoff_Flag,@Holiday_CompOff_Limit,'HO' from dbo.T0140_LEAVE_TRANSACTION     
  --   where Leave_ID = @leave_ID  and     
  --   For_Date in (Select Data from dbo.Split(@StrHoliday_Date,';') where Data <>'') and Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID    
  -- end    
      
  --IF @StrWeekoff_Date <> '' and @Is_W_CompOff = 1    
  -- begin    
  --  Insert into #WeekOff_OT (WeekOff_OT_Trans,cmp_ID,Emp_ID,For_Date,CompOff_Credit,CompOff_Debit,CompOff_Balance,Branch_ID,Is_CompOFF,CompOFF_Days_Limit,CompOff_Type)    
  --   select  Leave_Tran_ID,@Cmp_ID,@Emp_ID,For_Date,Compoff_Credit,CompOFf_Debit,CompOFF_Balance,    
  --   @branch_id,Comoff_Flag,@Weekoff_CompOff_Limit,'WO' from dbo.T0140_LEAVE_TRANSACTION     
  --   where Leave_ID = @leave_ID and For_Date in (Select Data from dbo.Split(@StrWeekoff_Date,';') where Data <>'') and Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID    
         
  --   delete from #WeekOff_OT where For_Date  in (Select Data from dbo.Split(@StrHoliday_Date,';') where Data <> '') and Cmp_ID =@Cmp_ID and Emp_ID =@Emp_ID     
  -- end    
      
 --If not exists(select 1 from #Weekday_OT) and not exists(select 1 from #WeekOff_OT) and not exists(select 1 from #Holiday_OT)    
 -- Begin    
 --  return    
 -- end    
     
     
     
 Declare @strLeave_CompOff_dates varchar(max)    
 set @strLeave_CompOff_dates = ''    
     
     
 CREATE TABLE #LEAVE_COMPOFF_DATES    
 (    
  EMP_ID NUMERIC,    
  COMPOFF_DATES VARCHAR(MAX)    
 )    
 CREATE CLUSTERED INDEX IX_LEAVE_COMPOFF_DATES ON #LEAVE_COMPOFF_DATES(EMP_ID)    
    
 INSERT INTO #LEAVE_COMPOFF_DATES    
 SELECT  EMP_ID, STUFF((SELECT '#' + Leave_CompOff_Dates    
        FROM  T0110_LEAVE_APPLICATION_DETAIL LAD WITH (NOLOCK)          
        INNER JOIN T0100_LEAVE_APPLICATION LA WITH (NOLOCK) ON LA.Leave_Application_ID=LAD.Leave_Application_ID    
        INNER JOIN #Emp_Cons EC ON LA.Emp_ID=EC.Emp_ID    
        LEFT OUTER JOIN (SELECT LLA.Leave_Application_ID     
             FROM T0115_Leave_Level_Approval LLA  WITH (NOLOCK)     
              INNER JOIN (SELECT MAX(TRAN_ID) AS TRAN_ID, LA1.Leave_Application_ID    
                 FROM T0115_Leave_Level_Approval LLA1  WITH (NOLOCK)    
                   INNER JOIN T0110_LEAVE_APPLICATION_DETAIL LAD1 WITH (NOLOCK) ON LLA1.Leave_Application_ID=LAD1.Leave_Application_ID    
                   INNER JOIN T0100_LEAVE_APPLICATION LA1 WITH (NOLOCK) ON LAD1.Leave_Application_ID=LA1.Leave_Application_ID                       
                 WHERE LA1.Application_Status='P' AND LLA1.Approval_Status='A' AND LAD1.Leave_ID=@leave_ID    
                   AND LA1.Emp_ID=EC.Emp_ID    
                 GROUP BY LA1.Leave_Application_ID) LLA1 ON LLA.Leave_Application_ID=LLA1.Leave_Application_ID AND LLA.Tran_ID=LLA1.TRAN_ID    
             ) LLA ON LAD.Leave_Application_ID=LLA.Leave_Application_ID    
      WHERE LA.Application_Status='P' AND LAD.Leave_ID=@leave_ID     
        AND IsNull(LAD.Leave_CompOff_Dates, '') <> '' AND LLA.Leave_Application_ID IS NULL    
        AND EC.Emp_ID=LA.Emp_ID    
      FOR XML PATH('')), 1, 1, '') AS Leave_CompOff_Dates    
 FROM #Emp_Cons EC    
    
 --select * from #LEAVE_COMPOFF_DATES
     
 --if @Leave_Application_ID = 0     
 -- begin       
   --SELECT  @strLeave_CompOff_dates = @strLeave_CompOff_dates + '#' + Leave_CompOff_Dates      
   --FROM dbo.V0110_LEAVE_APPLICATION_DETAIL VLAD left  join    
   --(    
   -- select  Leave_Application_ID from dbo.T0115_Leave_Level_Approval LLA inner join    
   -- (    
   --      select max(Tran_ID) as Tran_ID from  dbo.T0115_Leave_Level_Approval LLA inner join     
   --      dbo.T0100_LEAVE_APPLICATION  LA on LLA.Leave_Application_ID = LA.Leave_Application_ID and LLA.Emp_ID = La.Emp_ID and Application_Status = 'P'    
   --      where LLA.Emp_ID = @Emp_ID and Approval_Status = 'A' and Leave_ID = @Leave_ID and LLA.cmp_ID = @cmp_ID  group by LLA.Leave_Application_ID    
   -- )sub_Qry on Sub_Qry.Tran_ID = LLA.Tran_ID    
        
   -- ) Qry on Qry.Leave_Application_ID = VLAD.LEave_Application_ID      
   --where Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID     
   --and Application_Status = 'P' and Leave_ID = @leave_ID     
   --and  isnull(Leave_CompOff_Dates,'') <> ''     
   --and  isnull(Qry.Leave_Application_ID ,0)=0    
 -- end    
 --else    
 -- begin    
       
 --  select  @strLeave_CompOff_dates = @strLeave_CompOff_dates + '#' + Leave_CompOff_Dates      
 --  from dbo.V0110_LEAVE_APPLICATION_DETAIL VLAD left outer join    
 --  (    
 --   select  Leave_Application_ID from dbo.T0115_Leave_Level_Approval LLA inner join    
 --   (    
 --        select max(Tran_ID) as Tran_ID from  dbo.T0115_Leave_Level_Approval LLA inner join     
 --        dbo.T0100_LEAVE_APPLICATION  LA on LLA.Leave_Application_ID = LA.Leave_Application_ID and LLA.Emp_ID = La.Emp_ID and Application_Status = 'P'    
 --        where LLA.Emp_ID = @Emp_ID and Approval_Status = 'A' and Leave_ID = @Leave_ID and LLA.cmp_ID = @cmp_ID group by LLA.Leave_Application_ID    
 --   )sub_Qry on Sub_Qry.Tran_ID = LLA.Tran_ID    
        
 --   ) Qry on Qry.Leave_Application_ID <> VLAD.LEave_Application_ID      
 --  where Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID     
 --  and Application_Status = 'P' and Leave_ID = @leave_ID     
 --  and  isnull(Leave_CompOff_Dates,'') <> '' and VLAD.Leave_Application_ID <> @Leave_Application_ID     
 -- end    
    
 UPDATE LCD    
 SET  COMPOFF_DATES = IsNull(COMPOFF_DATES + '#', '') + Leave_CompOff_Dates    
 FROM #LEAVE_COMPOFF_DATES LCD    
   INNER JOIN T0100_LEAVE_ENCASH_APPLICATION LEA ON LCD.EMP_ID=LEA.Emp_ID    
 WHERE Lv_Encash_App_Status = 'P' AND Leave_ID=@leave_ID AND IsNull(Leave_CompOff_Dates,'') <> ''       
      
 --if @Leave_Encash_App_ID = 0    
  --begin    
  -- select @strLeave_CompOff_dates = @strLeave_CompOff_dates + '#' + Leave_CompOff_Dates     
  -- from dbo.T0100_Leave_Encash_Application where Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID    
  -- and Lv_Encash_App_Status = 'P' and Leave_ID = @leave_ID and isnull(Leave_CompOff_Dates,'') <> ''    
  --end    
 --else    
 -- begin    
 --   select @strLeave_CompOff_dates = @strLeave_CompOff_dates + '#' + Leave_CompOff_Dates     
 --  from dbo.T0100_Leave_Encash_Application where Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID    
 --  and Lv_Encash_App_Status = 'P' and Leave_ID = @leave_ID and Lv_Encash_App_ID <> @Leave_Encash_App_ID and isnull(Leave_CompOff_Dates,'') <> ''    
 -- end    
 CREATE table #Leave_Applied    
 (    
  Emp_ID  Numeric,    
  Leave_Date Varchar(50), --update datatype from datetime to varchar(50) by Yogesh on 07-12-2023  
  Leave_Period NUMERIC(18,2)    
 )    
 INSERT INTO #Leave_Applied(Emp_ID,Leave_date,Leave_Period)    
 SELECT  LCD.EMP_ID,C_DATE,C_PERIOD    
 FROM #LEAVE_COMPOFF_DATES LCD    
   CROSS APPLY (SELECT Left(DATA,CHARINDEX(';',DATA)-1) AS C_DATE,SUBSTRING(DATA,CHARINDEX(';',DATA)+1,10) AS C_PERIOD    
       FROM dbo.SPlit(LCD.COMPOFF_DATES,'#') WHERE Data <> '') CD     
    
 --Insert into #Leave_Applied(Leave_date,Leave_Period)    
 -- select  Left(DATA,CHARINDEX(';',DATA)-1),SUBSTRING(DATA,CHARINDEX(';',DATA)+1,10)     
 -- from dbo.SPlit(@strLeave_CompOff_dates,'#') where Data <> ''    
     
 --Declare @Leave_Approve_ID as numeric(18,0)    
 --Declare @Leave_Encash_Approve_ID as numeric(18,0)    
 --set @Leave_Approve_ID = 0    
 --set @Leave_Encash_Approve_ID = 0    
     
 --set @strLeave_CompOff_dates = ''    
     
 --If @Leave_Application_ID > 0     
 -- begin    
 --  select @strLeave_CompOff_dates = @strLeave_CompOff_dates + '#' + isnull(Leave_CompOff_Dates,'')       
 --  from  dbo.V0130_Leave_Approval_Details where Leave_Application_ID = @Leave_Application_ID and Approval_Status = 'A' and Cmp_ID = @Cmp_ID    
 -- end    
      
 --If @Leave_Encash_App_ID > 0    
 -- begin      
 --  select @strLeave_CompOff_dates = @strLeave_CompOff_dates + '#' + isnull(Leave_CompOff_Dates,'')     
 --   from  dbo.V0120_LEAVE_Encash_Approval where Lv_Encash_App_ID = @Leave_Encash_App_ID and Lv_Encash_App_Status = 'A' and Cmp_ID = @Cmp_ID    
 -- end     
    
     
 CREATE table #Leave_Approved    
 (    
  Emp_ID Numeric,    
  Leave_Appr_Date datetime,    
  Leave_Period numeric(18,2)    
 )    
      
 --Insert into #Leave_Approved (Leave_Appr_Date,Leave_Period)    
 -- select  Left(DATA,CHARINDEX(';',DATA)-1),SUBSTRING(DATA,CHARINDEX(';',DATA)+1,10)     
 -- from dbo.SPlit(@strLeave_CompOff_dates,'#') where Data <> ''    
     
 --set @strLeave_CompOff_dates = ''    
    
 --UPDATE LCD    
 --SET  COMPOFF_DATES = COMPOFF_DATES + IsNull((SELECT '#' + Leave_CompOff_Dates    
 --            FROM T0110_LEAVE_APPLICATION_DETAIL LAD           
 --              INNER JOIN T0100_LEAVE_APPLICATION LA ON LA.Leave_Application_ID=LAD.Leave_Application_ID    
 --              INNER JOIN #Emp_Cons EC ON LA.Emp_ID=EC.Emp_ID    
 --              INNER JOIN (SELECT LLA.Leave_Application_ID     
 --                 FROM T0115_Leave_Level_Approval LLA     
 --                  INNER JOIN (SELECT MAX(TRAN_ID) AS TRAN_ID, LA1.Leave_Application_ID    
 --                     FROM T0115_Leave_Level_Approval LLA1     
 --                       INNER JOIN T0110_LEAVE_APPLICATION_DETAIL LAD1 ON LLA1.Leave_Application_ID=LAD1.Leave_Application_ID    
 --                       INNER JOIN T0100_LEAVE_APPLICATION LA1 ON LAD1.Leave_Application_ID=LA1.Leave_Application_ID    
 --                       INNER JOIN #Emp_Cons EC1 ON LA1.Emp_ID=EC1.Emp_ID    
 --                     WHERE LA1.Application_Status='P' AND LLA1.Approval_Status='A' AND LAD1.Leave_ID=@leave_ID    
 --                     GROUP BY LA1.Leave_Application_ID) LLA1 ON LLA.Leave_Application_ID=LLA1.Leave_Application_ID AND LLA.Tran_ID=LLA1.TRAN_ID    
 --                 ) LLA ON LAD.Leave_Application_ID=LLA.Leave_Application_ID    
 --            WHERE LAD.Leave_ID=@leave_ID AND IsNull(LAD.Leave_CompOff_Dates, '') <> ''    
 --            FOR XML PATH('')), '')    
 --FROM #LEAVE_COMPOFF_DATES LCD     
 --  INNER JOIN #Emp_Cons EC ON LCD.EMP_ID=EC.Emp_ID    
     
     
 --If @Leave_Application_ID > 0      
 -- begin    
   --select @strLeave_CompOff_dates = @strLeave_CompOff_dates + '#' + isnull(Leave_CompOff_dates,'')     
   --from dbo.T0115_Leave_Level_Approval LLA Inner join    
   --(    
   -- select max(Tran_ID) as Tran_ID from  dbo.T0115_Leave_Level_Approval LLA inner join    
   -- dbo.T0100_LEAVE_APPLICATION LA on LLA.Leave_Application_ID = LA.Leave_Application_ID and LLA.Emp_ID =LA.Emp_ID and LA.Application_Status = 'P'    
   -- where LA.Emp_ID = @Emp_ID and Approval_Status = 'A' and Leave_ID = @Leave_ID   and LA.cmp_ID = @Cmp_ID    
   -- group by LLA.Leave_Application_ID    
   -- ) Qry on Qry.Tran_ID = LLA.Tran_ID    
   --where Leave_Application_ID <> @Leave_Application_ID    
 -- end    
 --else    
 -- begin    
 --  select @strLeave_CompOff_dates = @strLeave_CompOff_dates + '#' + isnull(Leave_CompOff_dates,'')     
 --  from dbo.T0115_Leave_Level_Approval LLA inner join     
 --  (    
 --   select max(Tran_ID) as Tran_ID from  dbo.T0115_Leave_Level_Approval LLA  inner join     
 --   dbo.T0100_LEAVE_APPLICATION LA on LA.Leave_Application_ID = LLA.Leave_Application_ID and  LA.Emp_ID = LLA.Emp_ID and Application_Status = 'P'    
 --   where LLA.Emp_ID = @Emp_ID and Approval_Status = 'A' and Leave_ID = @Leave_ID and LLA.Cmp_ID = @Cmp_ID    
 --   group by LLA.Leave_Application_ID    
 --  )  Qry on Qry.Tran_ID = LLA.Tran_ID    
 -- end    
 CREATE table #Leave_Level_Approved    
 (    
  Emp_ID Numeric,    
  Leave_Appr_Date Varchar(50), --update datatype from datetime to varchar(50) by Yogesh on 07-12-2023  
  Leave_Period numeric(18,2)    
 )    
 INSERT INTO #Leave_Level_Approved(Emp_ID, Leave_Appr_Date,Leave_Period)    
 SELECT  LCD.Emp_ID,C_DATE, C_PERIOD    
 FROM (    
    SELECT EMP_ID, STUFF((SELECT '#' + Leave_CompOff_Dates    
          FROM T0110_LEAVE_APPLICATION_DETAIL LAD WITH (NOLOCK)          
            INNER JOIN T0100_LEAVE_APPLICATION LA WITH (NOLOCK) ON LA.Leave_Application_ID=LAD.Leave_Application_ID    
            INNER JOIN #Emp_Cons EC ON LA.Emp_ID=EC.Emp_ID    
            INNER JOIN (SELECT LLA.Leave_Application_ID     
               FROM T0115_Leave_Level_Approval LLA WITH (NOLOCK)    
                INNER JOIN (SELECT MAX(TRAN_ID) AS TRAN_ID, LA1.Leave_Application_ID    
                   FROM T0115_Leave_Level_Approval LLA1 WITH (NOLOCK)    
                     INNER JOIN T0110_LEAVE_APPLICATION_DETAIL LAD1 WITH (NOLOCK) ON LLA1.Leave_Application_ID=LAD1.Leave_Application_ID    
                     INNER JOIN T0100_LEAVE_APPLICATION LA1 WITH (NOLOCK) ON LAD1.Leave_Application_ID=LA1.Leave_Application_ID                         
                   WHERE LA1.Application_Status='P' AND LLA1.Approval_Status='A' AND LAD1.Leave_ID=@leave_ID    
                     AND EC.Emp_ID=LA1.Emp_ID    
                   GROUP BY LA1.Leave_Application_ID) LLA1 ON LLA.Leave_Application_ID=LLA1.Leave_Application_ID AND LLA.Tran_ID=LLA1.TRAN_ID    
               ) LLA ON LAD.Leave_Application_ID=LLA.Leave_Application_ID    
          WHERE LAD.Leave_ID=@leave_ID AND IsNull(LAD.Leave_CompOff_Dates, '') <> ''    
            AND LA.Emp_ID=EC.Emp_ID    
          FOR XML PATH('')),1,1, '') AS COMPOFF_DATES    
    FROM #Emp_Cons EC    
   ) LCD CROSS APPLY (SELECT Left(DATA,CHARINDEX(';',DATA)-1) AS C_DATE,SUBSTRING(DATA,CHARINDEX(';',DATA)+1,10) AS C_PERIOD    
       FROM dbo.SPlit(LCD.COMPOFF_DATES,'#') WHERE Data <> '') CD     
     
 --Insert into #Leave_Level_Approved(Leave_Appr_Date,Leave_Period)    
 -- select  Left(DATA,CHARINDEX(';',DATA)-1),SUBSTRING(DATA,CHARINDEX(';',DATA)+1,10)     
 -- from dbo.SPlit(@strLeave_CompOff_dates,'#') where Data <> ''    
     
     
     
 Insert into #General_OT      
 select * from #Weekday_OT     
 union all     
 select * from #WeekOff_OT    
 union all    
 select * from #Holiday_OT      
     
     
 UPDATE GOT     
 SET  CompOff_Debit = Compoff_Debit + Qry.Leave_Period,    
   CompOff_balance = CompOff_balance - Qry.Leave_Period     
 FROM #General_OT GOT     
   INNER JOIN (SELECT ISNULL(SUM(leave_Period),0) AS Leave_Period,Leave_Date,Emp_ID    
      FROM #Leave_Applied LA     
      GROUP BY Leave_Date,Emp_ID) Qry ON Qry.Leave_Date = For_Date AND Qry.Emp_ID=GOT.Emp_ID    
      
 UPDATE #General_OT     
 SET  CompOff_Debit = Compoff_Debit + Qry.Leave_Period,    
   CompOff_balance = CompOff_balance - Qry.Leave_Period     
 FROM #General_OT GOT     
   INNER JOIN (SELECT IsNull(Sum(leave_Period),0) AS Leave_Period,Leave_Appr_Date,Emp_ID    
      FROM #Leave_Level_Approved LA     
      GROUP BY Leave_Appr_Date,Emp_ID) Qry on Qry.Leave_Appr_Date = For_Date AND Qry.Emp_ID=GOT.Emp_ID    
      
 UPDATE GOT    
 SET  CompOff_Debit = Compoff_Debit - Qry.Leave_Period,    
   CompOff_balance = CompOff_balance + Qry.Leave_Period     
 FROM #General_OT GOT     
   INNER JOIN (SELECT IsNull(Sum(leave_Period),0) AS Leave_Period,Leave_Appr_Date,Emp_ID    
      FROM #Leave_Approved LA     
      GROUP BY Leave_Appr_Date,Emp_ID) Qry ON Qry.Leave_Appr_Date = For_Date AND Qry.Emp_ID=GOT.Emp_ID    
     
 --Added Following Line by Nimesh on 20-Feb-2017    
 DELETE FROM #General_OT WHERE CompOff_balance < 0    
      
 Declare @Total_Balance as numeric(18,2)    
  SET @Total_Balance = 0    
 Declare @Leave_Code as varchar(max)    
 Declare @Leave_Name as varchar(max)    
 Declare @Leave_Display as tinyint    
 Declare @CompOff_Balance as numeric(18,2)    
 Declare @Cur_CompOff_balance numeric(18,2)    
 Declare @Cur_For_Date datetime    
 Declare @CompOff_String nvarchar(max)    
 Declare @Cur_Total_Balance numeric(18,2)    
 IF @Exec_For = 0    
  BEGIN    
   select @Total_Balance = isnull(SUM(CompOff_balance),0) from #General_OT where CompOff_balance > 0 Group By Emp_ID    
   select *,@Total_Balance as Total_Balance from #General_OT where CompOff_balance > 0 order by For_Date    
  END    
 ELSE IF @Exec_For = 2 OR  @Exec_For = 55 -- Show All Data    
  BEGIN    
  --added #temp_CompOff tbl mansi start 081121    
      CREATE TABLE #temp_CompOff            
      (            
    Emp_ID   Numeric,    
    Leave_ID  numeric ,       
    Leave_Code  VARCHAR(max),     
    Leave_Name  VARCHAR(max),       
    Leave_opening decimal(18,2),            
    Leave_Used  decimal(18,2),            
    Leave_Closing decimal(18,2),            
    CompOff_String  VARCHAR(max) default null     
      )       
      --added #temp_CompOff tbl mansi end 081121    
   INSERT INTO #temp_CompOff(Emp_ID, Leave_ID, Leave_Code, Leave_Name, Leave_Opening, Leave_Used, Leave_Closing, CompOff_String)    
   SELECT G.EMP_ID, @leave_ID, LM.LEAVE_CODE, LM.LEAVE_NAME ,     
     IsNull(Sum(CompOff_credit),0),IsNull(Sum(CompOFf_Debit),0),IsNull(Sum(CompOff_Balance),0),    
     STUFF((SELECT '#' + REPLACE(CONVERT(varchar(11),@Cur_For_Date,106),' ','-')    
        FROM  #General_OT GOT    
        WHERE  GOT.Emp_ID=G.EMP_ID FOR XML PATH('')), 1,1,'')     
   FROM #General_OT G INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LM.LEAVE_ID=@leave_ID    
   GROUP BY Emp_ID, LM.LEAVE_CODE, LM.LEAVE_NAME    
  END    
 ELSE    
  BEGIN    
   declare @msg Varchar(256)    
   set @msg = 'Code does not exist for parameter @Exec_For=' + Cast(@Exec_For As Varchar(128))    
   RAISERROR(@msg, 1,16)    
  END    
END 