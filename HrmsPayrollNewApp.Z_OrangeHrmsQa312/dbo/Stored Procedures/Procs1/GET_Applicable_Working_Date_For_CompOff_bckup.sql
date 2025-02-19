CREATE PROCEDURE [dbo].[GET_Applicable_Working_Date_For_CompOff_bckup]  
 @Cmp_ID AS numeric(18,0),  
 @Branch_ID AS numeric(18,0),  
 @Emp_ID AS numeric(18,0),  
 @For_Date AS DATETIME,  
 @constraint AS varchar(max),  
 @Sanctioned_Hours AS varchar(20) = '',  
 @Search_Flag AS numeric = 0,  
 @with_table AS numeric = 0  
AS  
  
  SET NOCOUNT ON   
  SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
  SET ARITHABORT ON  
  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
   
 DECLARE @CompOff_WD_App_Days_Limit AS numeric  
 DECLARE @CompOff_WO_App_Days_Limit AS numeric  
 DECLARE @CompOff_HO_App_Days_Limit AS numeric  
 DECLARE @CompOff_WD_App_Days_Limit_Emp_Wise AS numeric  
 DECLARE @CompOff_WO_App_Days_Limit_Emp_Wise AS numeric  
 DECLARE @CompOff_HO_App_Days_Limit_Emp_Wise AS numeric  
   
 DECLARE @WD_Editable AS tinyint  
 DECLARE @WO_Editable AS tinyint  
 DECLARE @HO_Editable AS tinyint  
 DECLARE @Is_OD AS tinyint  
   
 DECLARE @From_date AS DATETIME  
 DECLARE @From_WD_Date AS DATETIME  
 DECLARE @From_HO_Date AS DATETIME  
 DECLARE @From_WO_Date AS DATETIME  
 DECLARE @Is_WD AS tinyint   
 DECLARE @Is_WO AS tinyint  
 DECLARE @Is_HO AS tinyint  
 DECLARE @CompOff_Days_temp AS numeric(18,2)   
 DECLARE @Gen_set_ID AS numeric(18,0)  
  
   
 DECLARE @Min_OD_For_Date AS DATETIME  
 DECLARE @Max_OD_For_Date AS DATETIME  
   
 SET @CompOff_Days_temp = 1  
 SET @Gen_set_ID = 0  
   
 DECLARE @From_Hours AS NUMERIC(18,2)  
 DECLARE @To_Hours AS NUMERIC(18,2)  
 DECLARE @CompOff_Days AS NUMERIC(18,2)  
 DECLARE @Slab_Type AS CHAR(1)  
 DECLARE @CompOff_Tran_ID AS NUMERIC(18,0)  
 DECLARE @OT_Hour AS VARCHAR(2000)  
 DECLARE @DayFlag AS VARCHAR(5)  
 DECLARE @Is_CompOff_Hourly AS TINYINT  
   
 SET @Is_CompOff_Hourly = 0  
   
   
 DECLARE @Is_WO_OD TINYINT  -- Added by Gadriwala Muslim 31032015  
 DECLARE @Is_HO_OD TINYINT  -- Added by Gadriwala Muslim 31032015  
 DECLARE @Is_WD_OD TINYINT  -- Added by Gadriwala Muslim 31032015  
   
 set @Is_WO_OD = 1   -- Added by Gadriwala Muslim 31032015  
 set @Is_HO_OD = 1   -- Added by Gadriwala Muslim 31032015  
 set @Is_WD_OD = 1   -- Added by Gadriwala Muslim 31032015  
   
 SELECT @Is_CompOff_Hourly = Apply_Hourly FROM T0040_LEAVE_MASTER WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND isnull(Default_Short_Name,'') = 'COMP'  
     
 SELECT @CompOff_WD_App_Days_Limit_Emp_Wise = CompOff_WD_App_Days,  
     @CompOff_WO_App_Days_Limit_Emp_Wise = CompOff_WO_App_Days,  
        @CompOff_HO_App_Days_Limit_Emp_Wise = CompOff_HO_App_Days   
 FROM V0080_Employee_master  
 WHERE Cmp_ID = @Cmp_ID AND Emp_ID = @Emp_ID  
   
 if isnull(@Branch_ID,0) = 0  
  begin  
   SELECT @branch_id = branch_id FROM dbo.T0095_INCREMENT WITH (NOLOCK)  
   WHERE Emp_ID = @Emp_ID AND Increment_ID =   
   (SELECT MAX(Increment_ID) FROM dbo.T0095_INCREMENT WITH (NOLOCK) WHERE Emp_ID = @Emp_ID AND Cmp_ID = @cmp_ID AND Increment_Effective_Date<=@For_Date)  
  end  
   
 CREATE TABLE #EMP_HOLIDAY(EMP_ID NUMERIC, FOR_DATE DATETIME, IS_CANCEL BIT, Is_Half tinyint, Is_P_Comp tinyint, H_DAY numeric(4,1));  
 CREATE UNIQUE CLUSTERED INDEX IX_EMP_HOLIDAY_EMPID_FORDATE ON #EMP_HOLIDAY(EMP_ID, FOR_DATE);  
  
 CREATE TABLE #EMP_WEEKOFF  
 (  
  Row_ID   NUMERIC,  
  Emp_ID   NUMERIC,  
  For_Date  DATETIME,  
  Weekoff_day  VARCHAR(10),  
  W_Day   numeric(4,1),  
  Is_Cancel  BIT  
 )  
 CREATE CLUSTERED INDEX IX_Emp_WeekOff_EmpID_ForDate ON #EMP_WEEKOFF(Emp_ID, For_Date)  
   
 SELECT @CompOff_WD_App_Days_Limit = CompOff_Days_Limit,  
 @CompOff_HO_App_Days_Limit = h_CompOff_Days_Limit,  
 @CompOff_WO_App_Days_Limit = W_CompOff_Days_Limit,  
 @WD_Editable = Is_Co_hour_Editable,  
 @WO_Editable = Is_W_Co_hour_Editable,  
 @HO_Editable = Is_H_Co_hour_Editable,  
 @Is_OD =  AllowShowODOptInCompOff,   
 @is_WD = ISNULL(Is_CompOff_WD,0),  
 @Is_HO = Isnull(Is_HO_CompOff,0),  
 @Is_WO = Isnull(Is_W_CompOff,0),  
 @Is_WO_OD = ISNULL(Is_WO_OD,1), -- Added by Gadriwala Muslim 31032015  
 @Is_WD_OD = ISNULL(Is_WD_OD,1), -- Added by Gadriwala Muslim 31032015  
 @Is_HO_OD = ISNULL(Is_HO_OD,1), -- Added by Gadriwala Muslim 31032015  
 @Gen_set_ID = Gen_ID  
 FROM T0040_General_Setting WITH (NOLOCK) WHERE   
 Cmp_ID = @Cmp_ID AND   
 Branch_ID = @Branch_ID   
 and For_Date = ( SELECT max(For_Date) FROM dbo.T0040_GENERAL_SETTING WITH (NOLOCK)  
   WHERE For_Date <= @For_Date AND Branch_ID = @branch_id AND Cmp_ID = @Cmp_ID)      
 Order By For_Date Desc  
   
   
   
 If @CompOff_WD_App_Days_Limit_Emp_Wise > 0   
  set @CompOff_WD_App_Days_Limit = @CompOff_WD_App_Days_Limit_Emp_Wise  
    
 If @CompOff_WO_App_Days_Limit_Emp_Wise > 0   
  set @CompOff_WO_App_Days_Limit = @CompOff_WO_App_Days_Limit_Emp_Wise  
    
 If @CompOff_Ho_App_Days_Limit_Emp_Wise > 0   
  set @CompOff_Ho_App_Days_Limit = @CompOff_Ho_App_Days_Limit_Emp_Wise  
   
   
    
 set @From_WD_Date  = Convert(varchar(25),DATEADD(D,@CompOff_WD_App_Days_Limit * -1,@For_Date))   
 set @From_WO_Date  = Convert(varchar(25),DATEADD(D,@CompOff_WO_App_Days_Limit * -1,@For_Date))   
 set @From_HO_Date  = Convert(varchar(25),DATEADD(D,@CompOff_HO_App_Days_Limit * -1,@For_Date))   
   
   
   
 IF OBJECT_ID('tempdb..#CompOff_OT') IS NOT NULL  
    DROP TABLE #CompOff_OT  
   
 CREATE TABLE #CompOff_OT  
 (  
  CompOff_Tran_ID   numeric,  
  Cmp_ID     numeric,  
  Emp_ID     numeric,  
  Branch_ID    numeric,  
  For_Date    DATETIME,  
  Shift_Hours    varchar(2000),  
  Working_Hour   varchar(2000),  
  Actual_Worked_Hrs       varchar(2000),  
  OT_Hour     varchar(2000),  
  In_Time_Actual   nvarchar(8),  
  Out_Time_Actual         nvarchar(8),  
  Is_Editable    tinyint,  
  DayFlag     varchar(5),  
  Application_Status  varchar(10),  
  CompOff_Days   numeric(18,2)  
    
 )  
   
 --IF OBJECT_ID('tempdb..#WeekOff_Holiday') IS NOT NULL  
 --   DROP TABLE #WeekOff_Holiday  
 --Create Table #WeekOff_Holiday  
 --(  
    
 -- Weekoff_days            tinyint,  
 -- Holidays                tinyint,  
 -- Weekoff_Dates           nvarchar(max),  
 -- Holiday_Dates           nvarchar(max),  
 --)  
   
 IF @Search_Flag = 0  -- Get Compoff details using Present days   
  begin  
    
      
      IF OBJECT_ID('tempdb..#CompOff_Records') IS NOT NULL  
      DROP TABLE #CompOff_Records  
           
      CREATE TABLE #CompOff_Records          
      (           
        Emp_Id   numeric ,           
        For_date DATETIME,          
        Duration_in_sec numeric,          
        Shift_ID numeric ,          
        Shift_Type numeric ,          
        Emp_OT  numeric ,          
        Emp_OT_min_Limit numeric,          
        Emp_OT_max_Limit numeric,          
        P_days  numeric(12,3) default 0,          
        OT_Sec  numeric default 0,  
        In_Time DATETIME,  
        Shift_Start_Time  DATETIME,  
        OT_Start_Time numeric default 0,  
        Shift_Change tinyint default 0,  
        Flag int default 0       ,  
        Weekoff_OT_Sec Numeric Default 0,  
        Holiday_OT_Sec Numeric Default 0   ,  
        Chk_By_Superior numeric default 0,  
        IO_Tran_Id    numeric default 0,  
        OUT_Time DATETIME,  
        Shift_End_Time DATETIME,     
        OT_End_Time numeric default 0,   
        Working_Hrs_St_Time tinyint default 0,   
        Working_Hrs_End_Time tinyint default 0,   
        GatePass_Deduct_Days numeric(18,2) default 0,   
        Working_Hour varchar(2000),  
        OT_Hour varchar(2000),  
        Actual_Worked_Hrs varchar(2000),  
        P_Days_Count  numeric(18,2),  
        Weekoff_OT_Hour varchar(2000),  
        Holiday_OT_Hour varchar(2000),  
        Application_Status char(1),  
        DayFlag varchar(5),  
        Shift_Hours varchar(2000),  
        In_Time_Actual nvarchar(8),  
        Out_Time_Actual nvarchar(8)  
      )   
             
        DECLARE @Min_From_Date AS DATETIME  
        
      Create table #Validate_Date  
      (  
       From_date DATETIME  
      )  
        
      IF @Is_WD = 1 AND @Is_WO = 1 AND @Is_HO = 1  
         begin  
           
          delete FROM #Validate_Date  
          insert into #validate_Date values(@From_WD_Date)  
        insert into #validate_Date values(@From_HO_Date)  
        insert into #validate_Date values(@From_WO_Date)   
          SELECT @Min_From_Date = MIN(from_date) FROM #Validate_Date  
            
          insert into #CompOff_Records  
        exec SP_CALCULATE_PRESENT_DAYS @cmp_ID,@Min_From_Date,@For_Date,@Branch_ID,0,0,0,0,0,@Emp_ID,'',13 -- For Weekday & Holiday & Week-Off  
           
         --select * from #CompOff_Records  
  
         delete CR_Main FROM #CompOff_Records CR_Main  inner join (        
         SELECT CR.For_date FROM #CompOff_Records CR   
         inner join (SELECT For_Date,Actual_Worked_Hrs FROM #CompOff_Records WHERE DayFlag ='HO-G')Qry  
         on  Qry.For_date = CR.For_Date  AND Qry.Actual_Worked_Hrs <= CR.Actual_Worked_Hrs  
         WHERE  DayFlag='HO') Qry on CR_Main.DayFlag='HO-G' AND CR_Main.For_date = Qry.For_date  
           
         delete CR FROM #CompOff_Records CR   
         inner join (SELECT For_Date,Actual_Worked_Hrs FROM #CompOff_Records WHERE DayFlag ='HO-G')Qry  
         on  Qry.For_date = CR.For_Date AND Qry.Actual_Worked_Hrs >= CR.Actual_Worked_Hrs  
         WHERE DayFlag = 'HO'  
           
         update #CompOff_Records set DayFlag='HO'   
         WHERE DayFlag ='HO-G'  
          
         delete CR_Main FROM #CompOff_Records CR_Main  inner join (        
         SELECT CR.For_date FROM #CompOff_Records CR   
         inner join (SELECT For_Date,Actual_Worked_Hrs FROM #CompOff_Records WHERE DayFlag ='WO-G')Qry  
         on  Qry.For_date = CR.For_Date  AND Qry.Actual_Worked_Hrs <= CR.Actual_Worked_Hrs  
         WHERE  DayFlag='WO') Qry on CR_Main.DayFlag='WO-G' AND CR_Main.For_date = Qry.For_date  
           
         delete CR FROM #CompOff_Records CR   
         inner join (SELECT For_Date,Actual_Worked_Hrs FROM #CompOff_Records WHERE DayFlag ='WO-G')Qry  
         on  Qry.For_date = CR.For_Date AND Qry.Actual_Worked_Hrs >= CR.Actual_Worked_Hrs  
         WHERE DayFlag = 'WO'  
           
         update #CompOff_Records set DayFlag='WO'   
         WHERE DayFlag ='WO-G'  
          
           
           
         delete FROM #CompOff_Records WHERE  For_date < @From_WD_Date AND DayFlag = 'WD'    
         delete FROM #CompOff_Records WHERE  For_date < @From_HO_Date AND DayFlag = 'HO'  
         delete FROM #CompOff_Records WHERE  For_date < @From_WO_Date AND DayFlag = 'WO'  
            
         end  
        ELSE IF @Is_WD = 1 AND @Is_WO = 0 AND @Is_HO = 1  
         begin  
           
          delete FROM #Validate_Date  
          insert into #validate_Date values(@From_WD_Date)  
        insert into #validate_Date values(@From_HO_Date)   
          SELECT @Min_From_Date = MIN(from_date) FROM #Validate_Date  
            
           insert into #CompOff_Records  
          exec SP_CALCULATE_PRESENT_DAYS @cmp_ID,@Min_From_Date,@For_Date,@Branch_ID,0,0,0,0,0,@Emp_ID,'',15-- For Weekday & Holiday   
         
         delete CR_Main FROM #CompOff_Records CR_Main  inner join (        
         SELECT CR.For_date FROM #CompOff_Records CR   
         inner join (SELECT For_Date,Actual_Worked_Hrs FROM #CompOff_Records WHERE DayFlag ='HO-G')Qry  
         on  Qry.For_date = CR.For_Date  AND Qry.Actual_Worked_Hrs <= CR.Actual_Worked_Hrs  
         WHERE  DayFlag='HO') Qry on CR_Main.DayFlag='HO-G' AND CR_Main.For_date = Qry.For_date  
           
         delete CR FROM #CompOff_Records CR   
         inner join (SELECT For_Date,Actual_Worked_Hrs FROM #CompOff_Records WHERE DayFlag ='HO-G')Qry  
         on  Qry.For_date = CR.For_Date AND Qry.Actual_Worked_Hrs >= CR.Actual_Worked_Hrs  
         WHERE DayFlag = 'HO'  
           
         update #CompOff_Records set DayFlag='HO'   
         WHERE DayFlag ='HO-G'  
           
           
             
         delete FROM #CompOff_Records WHERE  For_date < @From_WD_Date AND DayFlag = 'WD'    
         delete FROM #CompOff_Records WHERE  For_date < @From_HO_Date AND DayFlag = 'HO'  
          
          
         end   
        ELSE IF @Is_WD = 1 AND @Is_WO = 1 AND @Is_HO = 0  
         begin  
           
          delete FROM #Validate_Date  
          insert into #validate_Date values(@From_WD_Date)  
        insert into #validate_Date values(@From_WO_Date)   
          SELECT @Min_From_Date = MIN(from_date) FROM #Validate_Date  
            
          insert into #CompOff_Records  
         exec SP_CALCULATE_PRESENT_DAYS @cmp_ID,@Min_From_Date,@For_Date,@Branch_ID,0,0,0,0,0,@Emp_ID,'',16 -- For Weekday  & Week-Off  
          
         delete CR_Main FROM #CompOff_Records CR_Main  inner join (        
         SELECT CR.For_date FROM #CompOff_Records CR   
         inner join (SELECT For_Date,Actual_Worked_Hrs FROM #CompOff_Records WHERE DayFlag ='WO-G')Qry  
         on  Qry.For_date = CR.For_Date  AND Qry.Actual_Worked_Hrs <= CR.Actual_Worked_Hrs  
         WHERE  DayFlag='WO') Qry on CR_Main.DayFlag='WO-G' AND CR_Main.For_date = Qry.For_date  
           
         delete CR FROM #CompOff_Records CR   
         inner join (SELECT For_Date,Actual_Worked_Hrs FROM #CompOff_Records WHERE DayFlag ='WO-G')Qry  
         on  Qry.For_date = CR.For_Date AND Qry.Actual_Worked_Hrs >= CR.Actual_Worked_Hrs  
         WHERE DayFlag = 'WO'  
           
         update #CompOff_Records set DayFlag='WO'   
         WHERE DayFlag ='WO-G'  
           
        delete FROM #CompOff_Records WHERE  For_date < @From_WD_Date AND DayFlag = 'WD'    
        delete FROM #CompOff_Records WHERE  For_date < @From_WO_Date AND DayFlag = 'WO'  
         end  
        ELSE IF @Is_WD = 0 AND @Is_WO = 1 AND @Is_HO = 1  
         begin  
          delete FROM #Validate_Date  
          insert into #validate_Date values(@From_HO_Date)  
        insert into #validate_Date values(@From_WO_Date)   
          SELECT @Min_From_Date = MIN(from_date) FROM #Validate_Date  
            
          
  
          insert into #CompOff_Records  
         exec SP_CALCULATE_PRESENT_DAYS @cmp_ID,@Min_From_Date,@For_Date,@Branch_ID,0,0,0,0,0,@Emp_ID,'',14 -- For Week-Off & Holiday  
           
           
         -- Added by Gadriwala Muslim 04/09/2015 - Start - For Official go out on Week-Off  
         delete CR_Main FROM #CompOff_Records CR_Main  inner join (        
         SELECT CR.For_date FROM #CompOff_Records CR   
         inner join (SELECT For_Date,Actual_Worked_Hrs FROM #CompOff_Records WHERE DayFlag ='WO-G')Qry  
         on  Qry.For_date = CR.For_Date  AND Qry.Actual_Worked_Hrs <= CR.Actual_Worked_Hrs  
         WHERE  DayFlag='WO') Qry on CR_Main.DayFlag='WO-G' AND CR_Main.For_date = Qry.For_date  
           
         delete CR FROM #CompOff_Records CR   
         inner join (SELECT For_Date,Actual_Worked_Hrs FROM #CompOff_Records WHERE DayFlag ='WO-G')Qry  
         on  Qry.For_date = CR.For_Date AND Qry.Actual_Worked_Hrs >= CR.Actual_Worked_Hrs  
         WHERE DayFlag = 'WO'  
           
         update #CompOff_Records set DayFlag='WO'   
         WHERE DayFlag ='WO-G'  
            
         delete CR_Main FROM #CompOff_Records CR_Main  inner join (        
         SELECT CR.For_date FROM #CompOff_Records CR   
         inner join (SELECT For_Date,Actual_Worked_Hrs FROM #CompOff_Records WHERE DayFlag ='HO-G')Qry  
         on  Qry.For_date = CR.For_Date  AND Qry.Actual_Worked_Hrs <= CR.Actual_Worked_Hrs  
         WHERE  DayFlag='HO') Qry on CR_Main.DayFlag='HO-G' AND CR_Main.For_date = Qry.For_date  
           
         delete CR FROM #CompOff_Records CR   
         inner join (SELECT For_Date,Actual_Worked_Hrs FROM #CompOff_Records WHERE DayFlag ='HO-G')Qry  
         on  Qry.For_date = CR.For_Date AND Qry.Actual_Worked_Hrs >= CR.Actual_Worked_Hrs  
         WHERE DayFlag = 'HO'  
           
         update #CompOff_Records set DayFlag='HO'   
         WHERE DayFlag ='HO-G'  
            
        delete FROM #CompOff_Records WHERE  For_date < @From_HO_Date AND DayFlag = 'HO'  
        delete FROM #CompOff_Records WHERE  For_date < @From_WO_Date AND DayFlag = 'WO'   
           
         end       
        ELSE IF @Is_WD = 1 AND @Is_WO = 0 AND @Is_HO = 0  
         begin  
         insert into #CompOff_Records  
          exec SP_CALCULATE_PRESENT_DAYS @cmp_ID,@From_WD_Date,@For_Date,@Branch_ID,0,0,0,0,0,@Emp_ID,'',9 -- For Weekday     
       end  
      ELSE if @Is_WO = 1 AND @Is_WD = 0 AND @Is_HO = 0  
       begin   
          --SELECT @cmp_ID,@From_WO_Date,@For_Date,@Branch_ID,0,0,0,0,0,@Emp_ID,'',11  
         insert into #CompOff_Records  
           exec SP_CALCULATE_PRESENT_DAYS @cmp_ID,@From_WO_Date,@For_Date,@Branch_ID,0,0,0,0,0,@Emp_ID,'',11 -- For WeekOff   
          
          
          
         -- Added by Gadriwala Muslim 04/09/2015 - Start - For Official go out on Week-Off  
         delete CR_Main FROM #CompOff_Records CR_Main  inner join (        
         SELECT CR.For_date FROM #CompOff_Records CR   
         inner join (SELECT For_Date,Actual_Worked_Hrs FROM #CompOff_Records WHERE DayFlag ='WO-G')Qry  
         on  Qry.For_date = CR.For_Date  AND Qry.Actual_Worked_Hrs <= CR.Actual_Worked_Hrs  
         WHERE  DayFlag='WO') Qry on CR_Main.DayFlag='WO-G' AND CR_Main.For_date = Qry.For_date  
           
           
           
         delete CR FROM #CompOff_Records CR   
         inner join (SELECT For_Date,Actual_Worked_Hrs FROM #CompOff_Records WHERE DayFlag ='WO-G')Qry  
         on  Qry.For_date = CR.For_Date AND Qry.Actual_Worked_Hrs >= CR.Actual_Worked_Hrs  
         WHERE DayFlag = 'WO'  
           
         update #CompOff_Records set DayFlag='WO'   
         WHERE DayFlag ='WO-G'  
          
       end  
      ELSE if @Is_HO = 1 AND @Is_WD = 0 AND @is_WO = 0  
       begin  
         insert into #CompOff_Records  
           exec SP_CALCULATE_PRESENT_DAYS @cmp_ID,@From_HO_Date,@For_Date,@Branch_ID,0,0,0,0,0,@Emp_ID,'',10 -- For Holiday  
           
         -- Added by Gadriwala Muslim 04/09/2015 - Start - For Official go out on Holiday  
             
         delete CR_Main FROM #CompOff_Records CR_Main  inner join (        
         SELECT CR.For_date FROM #CompOff_Records CR   
         inner join (SELECT For_Date,Actual_Worked_Hrs FROM #CompOff_Records WHERE DayFlag ='HO-G')Qry  
         on  Qry.For_date = CR.For_Date  AND Qry.Actual_Worked_Hrs <= CR.Actual_Worked_Hrs  
         WHERE  DayFlag='HO') Qry on CR_Main.DayFlag='HO-G' AND CR_Main.For_date = Qry.For_date  
           
         delete CR FROM #CompOff_Records CR   
         inner join (SELECT For_Date,Actual_Worked_Hrs FROM #CompOff_Records WHERE DayFlag ='HO-G')Qry  
         on  Qry.For_date = CR.For_Date AND Qry.Actual_Worked_Hrs >= CR.Actual_Worked_Hrs  
         WHERE DayFlag = 'HO'  
           
         update #CompOff_Records set DayFlag='HO'   
         WHERE DayFlag ='HO-G'   
         ---------------------------------------------    
       end  
      if @Is_OD = 1  
       begin  
        DECLARE @TEMP_FROM_DATE DATETIME  
        SET @TEMP_FROM_DATE = CASE WHEN @Is_WD = 1 THEN @From_WD_Date  
               WHEN @Is_WO = 1 THEN @From_WO_Date  
               WHEN @Is_HO = 1 THEN @From_HO_Date  
               ELSE DATEADD(D, -7, @For_Date)  
             END  
  
        insert into #CompOff_Records  
        exec SP_CALCULATE_PRESENT_DAYS @cmp_ID,@TEMP_FROM_DATE,@For_Date,@Branch_ID,0,0,0,0,0,@Emp_ID,'',12  -- For Onduty  
             
             
          
  
        SELECT @Min_OD_For_Date = MIN(For_date) ,@Max_OD_For_Date = MAX(For_date)   
        FROM #CompOff_Records    
        WHERE DayFlag= 'OD' --AND Emp_Id = @Emp_ID  
  
        IF @Emp_ID > 0  
         SET @CONSTRAINT = CAST(@EMP_ID AS VARCHAR(10))  
  
        TRUNCATE TABLE #EMP_WEEKOFF  
        TRUNCATE TABLE #EMP_HOLIDAY  
        EXEC SP_GET_HW_ALL @CONSTRAINT=@CONSTRAINT,@CMP_ID=@Cmp_ID, @FROM_DATE=@Min_OD_For_Date, @TO_DATE=@Max_OD_For_Date, @All_Weekoff = 1, @Exec_Mode=0    
  
        DELETE W   
        FROM #EMP_WEEKOFF W  
        WHERE EXISTS(SELECT 1 FROM T0100_WEEKOFF_ROSTER R WITH (NOLOCK) WHERE W.Emp_ID=R.Emp_id AND W.For_Date=R.For_date AND R.is_Cancel_WO=1)  
  
        IF @Is_WO_OD = 0 --IF WEEKOFF OD IS NOT GIVEN  
         BEGIN  
          DELETE C  
          FROM #CompOff_Records C  
            INNER JOIN #EMP_WEEKOFF W ON C.Emp_Id=C.Emp_Id AND C.For_date=W.For_Date  
          WHERE DayFlag = 'OD'   
         END  
        IF @Is_HO_OD = 0 --IF HOLIDAY OD IS NOT GIVEN  
         BEGIN  
          DELETE C  
          FROM #CompOff_Records C  
            INNER JOIN #EMP_HOLIDAY H ON C.Emp_Id=C.Emp_Id AND C.For_date=H.For_Date  
          WHERE DayFlag = 'OD'   
         END  
        IF @Is_WD_OD = 0 --IF WEEK DAY OD IS NOT GIVEN  
         BEGIN  
          DELETE C  
          FROM #CompOff_Records C              
          WHERE DayFlag = 'OD'   
            AND NOT EXISTS(SELECT 1 FROM #EMP_HOLIDAY H WHERE C.For_date=H.FOR_DATE AND C.Emp_Id=H.EMP_ID)  
            AND NOT EXISTS(SELECT 1 FROM #EMP_WEEKOFF W WHERE C.For_date=W.For_Date AND C.Emp_Id=W.Emp_ID)  
         END  
            
        DELETE C   
        FROM #CompOff_Records C  
        WHERE EXISTS(SELECT 1 FROM #CompOff_Records C1 WHERE C.EMP_ID=C1.Emp_Id AND C.FOR_DATE =C1.For_date AND C1.DayFlag='OD')  
          AND C.DAYFLAG  <> 'OD'  
  
       end  
          
       DECLARE @Cur_For_date DATETIME  
         
       DECLARE @PreCompOff_Mandatory AS tinyint   
       set @PreCompOff_Mandatory  = 0  
       SELECT  @PreCompOff_Mandatory = Setting_Value  FROM T0040_SETTING WITH (NOLOCK) WHERE Cmp_ID=@Cmp_ID AND Setting_Name='Pre Comp-off Request Mandatory'  
         
       IF @PreCompOff_Mandatory = 1   
        begin  
          
          Create table #PreCompOff  
          (  
           For_date DATETIME,  
           Status  char(1)  
          )    
            
          DECLARE @cur_From_date AS DATETIME  
          DECLARE @cur_To_date AS DATETIME  
          DECLARE @cur_Status AS char(1)  
          DECLARE curPreCompOff cursor for SELECT from_date,to_date,Approval_Status   
           FROM T0120_PreCompOff_Approval WITH (NOLOCK)  WHERE cmp_ID = @Cmp_ID AND emp_ID = @Emp_ID AND Approval_Status = 'A'  
            
            
            
          Open CurPreCompOff  
            Fetch next FROM CurprecompOff into  @cur_From_date,@Cur_To_date,@cur_status  
            while @@FETCH_STATUS = 0  
             begin  
                
              exec getAllDaysBetweenTwoDate @cur_From_date,@Cur_To_date  
              insert into #PreCompOff(For_date,Status)  
               SELECT test1,@cur_Status FROM test1  
              
             Fetch next FROM CurprecompOff into  @cur_From_date,@Cur_To_date,@cur_status  
             end  
          close CurPreCompOff  
          deallocate curPreCompOff     
                    
             
         Insert into #CompOff_OT  
          SELECT ROW_NUMBER() over (order by IO_Tran_ID),@cmp_ID,Emp_Id,@Branch_ID,CR.For_date,  
          Shift_Hours,Working_Hour,Actual_Worked_Hrs,OT_Hour,In_Time_Actual,Out_Time_Actual,  
          case when DayFlag ='HO' then @Ho_Editable   
          else case when DayFlag ='WO' then @WO_Editable   
          else case when DayFlag ='WD' then @WD_Editable  
          else case when DayFlag = 'OD' then 1 end end end end,  
          DayFlag,case when Application_Status = 'P' then 'Pending'   
            else  case when Application_Status = 'R' then 'Rejected'  
            else  case when Application_Status = 'A' then 'Approved' else '-' end end end AS Application_Status,0  
          FROM #CompOff_Records CR   
          WHERE  (  
             EXISTS (SELECT 1 FROM #PreCompOff PCO WHERE PCO.For_date = cr.For_date AND cr.DayFlag in ( 'HO', 'WO', 'OD','WD'))  
             --OR CR.DayFlag = 'WD'   commented by jimit 31072019 for redmine 353  
            )  
          --inner join #PreCompOff PC on CR.For_date = PC.For_date   
            
            
           
        end  
       else  
        begin  
          
         Insert into #CompOff_OT  
          SELECT ROW_NUMBER() over (order by IO_Tran_ID),@cmp_ID,Emp_Id,@Branch_ID,For_date,  
          Shift_Hours,Working_Hour,Actual_Worked_Hrs,OT_Hour,In_Time_Actual,Out_Time_Actual,  
          case when DayFlag ='HO' then @Ho_Editable   
          else case when DayFlag ='WO' then @WO_Editable   
          else case when DayFlag ='WD' then @WD_Editable  
          else case when DayFlag = 'OD' then 1 end end end end,  
          DayFlag,case when Application_Status = 'P' then 'Pending'   
            else  case when Application_Status = 'R' then 'Rejected'  
            else  case when Application_Status = 'A' then 'Approved' else '-' end end end AS Application_Status,0  
          FROM #CompOff_Records   
        end     
          
  
          
     SELECT @Min_OD_For_Date = MIN(For_date) ,@Max_OD_For_Date = MAX(For_date)   
     FROM #CompOff_OT         
     IF @Emp_ID > 0  
      SET @CONSTRAINT = CAST(@EMP_ID AS VARCHAR(10))  
  
     TRUNCATE TABLE #EMP_WEEKOFF  
     TRUNCATE TABLE #EMP_HOLIDAY  
     EXEC SP_GET_HW_ALL @CONSTRAINT=@CONSTRAINT,@CMP_ID=@Cmp_ID, @FROM_DATE=@Min_OD_For_Date, @TO_DATE=@Max_OD_For_Date, @All_Weekoff = 1, @Exec_Mode=0    
       
  
     DELETE W   
     FROM #EMP_WEEKOFF W  
     WHERE EXISTS(SELECT 1 FROM T0100_WEEKOFF_ROSTER R WITH (NOLOCK) WHERE W.Emp_ID=R.Emp_id AND W.For_Date=R.For_date AND R.is_Cancel_WO=1)  
         
     DECLARE curCompOff  cursor fast_forward for   
     SELECT CompOff_Tran_ID,OT_Hour,DayFlag,For_Date FROM #CompOff_OT  
     open curCompOff  
      Fetch Next FROM curCompOff into @CompOff_Tran_ID,@OT_Hour,@DayFlag,@Cur_For_date  
      while @@FETCH_STATUS = 0  
      BEGIN  
            
       if @DayFlag = 'WO'  
        set @Slab_Type  ='W'  
       else if @DayFlag = 'HO'  
        set @Slab_Type  ='H'  
       else if @DayFlag = 'WD'  
        set @Slab_Type  ='C'  
       else if @DayFlag = 'OD' -- Changed by Gadriwala Muslim 25/11/2015  
        begin  
         --delete FROM  #WeekOff_Holiday  
         --exec Sp_Get_Holiday_Weekoff @cmp_ID,@Cur_For_date,@Cur_For_date,@Emp_ID  
              
         --if exists(SELECT 1 FROM #WeekOff_Holiday WHERE Holidays = 1)  
         IF EXISTS(SELECT 1 FROM #EMP_HOLIDAY WHERE For_Date=@Cur_For_date)  
          set @Slab_Type = 'H'    
         --else if exists(SELECT 1 FROM #WeekOff_Holiday WHERE Weekoff_days = 1)   
         ELSE IF EXISTS(SELECT 1 FROM #EMP_WEEKOFF WHERE For_Date=@Cur_For_date)  
          set @Slab_Type = 'W'  
         else  
          set @Slab_Type = 'C'  
        end  
       else  
         set @Slab_Type = ''  
          
          
       DECLARE curapp cursor for  
        SELECT From_hours, To_hours, Deduction_Days   
        FROM T0050_GENERAL_DETAIL_SLAB WITH (NOLOCK)  
        WHERE GEN_ID = @Gen_set_ID AND Slab_Type = @Slab_Type order by Slab_Type   
          Open curapp  
          Fetch Next FROM curapp into @From_Hours, @To_Hours, @CompOff_Days  
          WHILE @@fetch_status = 0  
         BEGIN  
           
         if @Is_CompOff_Hourly = 1  
         begin  
          set @CompOff_Days_temp = cast(dbo.f_return_Sec(@OT_Hour)/3600 AS numeric(18,2))  --Changed By Jimit 08082019 as CompOff hours are not coming correct.  
          --set @CompOff_Days_temp = cast(REPLACE(@OT_Hour, ':', '.') AS numeric(18,2))  
          set @CompOff_Days_temp = FLOOR(@CompOff_Days_temp)+ case when ROUND(@CompOff_Days_temp,0)>FLOOR(@CompOff_Days_temp) then 0.5 else 0 end  
         end  
           
         --Modified by Nimesh on 28-Dec-2015   
          --IF((cast(dbo.f_return_sec(@OT_Hour)/3600 AS numeric(18,2))) >= @From_Hours   
          -- and (cast(dbo.f_return_sec(@OT_Hour)/3600 AS numeric(18,2))) <= @To_Hours)  
         IF((cast(REPLACE(@OT_Hour, ':', '.') AS numeric(18,2))) >= @From_Hours   
           and (cast(REPLACE(@OT_Hour, ':', '.') AS numeric(18,2))) <= @To_Hours)  
         BEGIN  
            
          IF (ISNULL(@CompOff_Days, 0) <> 0)  
          begin  
              
               set @CompOff_Days = @CompOff_Days * @CompOff_Days_temp  
            --set  @CompOff_Days = FLOOR(@CompOff_Days)+ case when ROUND(@CompOff_Days,0)>FLOOR(@CompOff_Days) then 0.5 else 0 end  -- Commenetd by rohit For Compoff Credit in 0.25 AS per Slab - Cera on 21102015  
              
            update #CompOff_OT set CompOff_Days = @CompOff_Days  
            WHERE CompOff_Tran_ID = @CompOff_Tran_ID  
          end   
         END  
            
        Fetch next FROM curapp into  @From_Hours, @To_Hours, @CompOff_Days  
         END   
        Close curapp  
        Deallocate curapp  
         
       Fetch Next FROM curCompOff into @CompOff_Tran_ID,@OT_Hour,@DayFlag,@Cur_For_date  
     END  
       close curCompOff  
       deallocate curCompOff  
         
         
       if @with_table = 1  
        begin  
         Insert into #CompOff_OT_Auto  
         SELECT * FROM #CompOff_OT order by Emp_ID,For_Date   
        end  
       else  
        begin  
         SELECT * FROM #CompOff_OT order by Emp_ID,For_Date   
        end  
     
  END   
 else if @Search_Flag = 1 -- Get Compoff details Manually  
  BEGIN  
      
   --delete FROM  #WeekOff_Holiday  
   ----insert into #WeekOff_Holiday(Weekoff_days,Holidays,Weekoff_Dates,Holiday_Dates)  
   -- exec Sp_Get_Holiday_Weekoff @cmp_ID,@For_date,@For_Date,@Emp_ID  
        
   IF @Emp_ID > 0  
    SET @CONSTRAINT = CAST(@EMP_ID AS VARCHAR(10))  
  
   TRUNCATE TABLE #EMP_WEEKOFF  
   TRUNCATE TABLE #EMP_HOLIDAY  
   EXEC SP_GET_HW_ALL @CONSTRAINT=@CONSTRAINT,@CMP_ID=@Cmp_ID, @FROM_DATE=@For_Date, @TO_DATE=@For_Date, @All_Weekoff = 1, @Exec_Mode=0    
  
   DELETE W   
   FROM #EMP_WEEKOFF W  
   WHERE EXISTS(SELECT 1 FROM T0100_WEEKOFF_ROSTER R WITH (NOLOCK) WHERE W.Emp_ID=R.Emp_id AND W.For_Date=R.For_date AND R.is_Cancel_WO=1)  
  
  
   --if exists(SELECT 1 FROM #WeekOff_Holiday WHERE Holidays = 1)  
   IF EXISTS(SELECT 1 FROM #EMP_HOLIDAY WHERE FOR_DATE=@For_Date AND EMP_ID=@Emp_ID)  
    set @Slab_Type = 'H'    
   --else if exists(SELECT 1 FROM #WeekOff_Holiday WHERE Weekoff_days = 1)   
   ELSE IF EXISTS(SELECT 1 FROM #EMP_WEEKOFF WHERE FOR_DATE=@For_Date AND EMP_ID=@Emp_ID)  
    set @Slab_Type = 'W'  
   else  
    set @Slab_Type = 'C'  
     
     
   If @Sanctioned_Hours <> ''  
    begin  
       
     if @Is_CompOff_Hourly = 1  
      begin  
       set @CompOff_Days_temp = cast(dbo.f_return_Sec(@Sanctioned_Hours)/3600 AS numeric(18,2))  
       set @CompOff_Days_temp = FLOOR(@CompOff_Days_temp)+ case when ROUND(@CompOff_Days_temp,0)>FLOOR(@CompOff_Days_temp) then 0.5 else 0 end  
      end  
       
     DECLARE curapp cursor for  
     SELECT From_hours, To_hours, Deduction_Days FROM T0050_GENERAL_DETAIL_SLAB WITH (NOLOCK) WHERE GEN_ID = @Gen_set_ID AND Slab_Type = @Slab_Type order by Slab_Type   
       
     Open curapp  
     Fetch Next FROM curapp into @From_Hours, @To_Hours, @CompOff_Days  
     WHILE @@fetch_status = 0  
     BEGIN  
      --Modified by Nimesh on 21-Jan-2015   
      --IF((cast(dbo.f_return_sec(@Sanctioned_Hours)/3600 AS numeric(18,2))) >= @From_Hours AND (cast(dbo.f_return_sec(@Sanctioned_Hours)/3600 AS numeric(18,2))) <= @To_Hours)  
      IF Cast(replace(@Sanctioned_Hours, ':', '.') AS NUmeric(18,2)) >= @From_Hours AND Cast(replace(@Sanctioned_Hours, ':', '.') AS NUmeric(18,2)) <= @To_Hours  
       BEGIN  
        SET @CompOff_Days = @CompOff_Days * @CompOff_Days_temp  
        SET  @CompOff_Days = FLOOR(@CompOff_Days)+ case when ROUND(@CompOff_Days,0)>FLOOR(@CompOff_Days) then 0.5 else 0 end  
        IF (ISNULL(@CompOff_Days, 0) <> 0)    
         begin  
          SELECT case when @Slab_Type = 'H' then @HO_Editable else  
              case when @Slab_Type = 'W' then @WO_Editable else  
              case when @Slab_Type = 'C' then @WD_Editable end end end AS Is_Editable,@CompOff_Days AS CompOff_Days   
         end  
        else  
         begin  
          SELECT case when @Slab_Type = 'H' then @HO_Editable else  
              case when @Slab_Type = 'W' then @WO_Editable else  
              case when @Slab_Type = 'C' then @WD_Editable end end end AS Is_Editable,0 AS CompOff_Days   
         end           
       END  
  
       Fetch next FROM curapp into  @From_Hours, @To_Hours, @CompOff_Days  
     END   
    Close curapp  
    Deallocate curapp        
   END  
   ELSE  
    begin  
     SELECT case when @Slab_Type = 'H' then @HO_Editable else  
         case when @Slab_Type = 'W' then @WO_Editable else           case when @Slab_Type = 'C' then @WD_Editable end end end AS Is_Editable,0 AS CompOff_Days  
    end          
  END  
 RETURN  
END  
  
  