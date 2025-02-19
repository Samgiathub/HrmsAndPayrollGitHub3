CREATE PROCEDURE [dbo].[SP_RPT_EMP_LATE_RECORD_GET]    
 @Cmp_ID   numeric    
 ,@From_Date  datetime    
 ,@To_Date   datetime     
 ,@Branch_ID  numeric    
 ,@Cat_ID   numeric     
 ,@Grd_ID   numeric    
 ,@Type_ID   numeric    
 ,@Dept_ID   numeric    
 ,@Desig_ID   numeric    
 ,@Emp_ID   numeric    
 ,@constraint  varchar(MAX)    
 ,@Report_Type varchar(50)=''  
 ,@Order_By varchar(30) = 'Code'  
AS    
 SET NOCOUNT ON   
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
 SET ARITHABORT ON  
     
 IF @Branch_ID = 0      
  SET @Branch_ID = null    
      
 IF @Cat_ID = 0      
  SET @Cat_ID = null    
    
 IF @Grd_ID = 0      
  SET @Grd_ID = null    
    
 IF @Type_ID = 0      
  SET @Type_ID = null    
    
 IF @Dept_ID = 0      
  SET @Dept_ID = null    
    
 IF @Desig_ID = 0      
  SET @Desig_ID = null    
    
 IF @Emp_ID = 0      
  SET @Emp_ID = null    
  
 CREATE table #Emp_Cons   
 (        
  Emp_ID numeric ,       
  Branch_ID numeric,  
  Increment_ID numeric      
 )              
           
 -- Ankit 08092014 for Same Date Increment  
 EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint --,@Sal_Type ,@Salary_Cycle_id ,@Segment_Id ,@Vertical_Id ,@SubVertical_Id ,@SubBranch_Id   
  
  
 DECLARE @RoundingValue  numeric(18,2)  
 SET @RoundingValue  = 0  
  
 DECLARE @RoundingValue_Early  numeric(18,2)  
 SET @RoundingValue_Early  = 0  
  
  
 CREATE table #Emp_Late     
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
  Shift_ID    numeric,  -- Added by Gadriwala Muslim 30062015   
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
  Extra_Exempted_Sec numeric(18,0) default 0, -- Added by Gadriwala Muslim 28102015  
  Extra_Exempted tinyint default 0 ,  -- Added by Gadriwala Muslim 28102015  
  Late_Mark_Scenario tinyint default 1,  
  Is_Late_Mark_Percentage tinyint default 0  
     
  )    
    
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
    IO_Tran_Id    numeric default 0,  
    Out_time datetime default null,  
    Shift_End_Time datetime,   --Ankit 16112013  
    OT_End_Time numeric default 0, --Ankit 16112013  
     Working_Hrs_St_Time tinyint default 0, --Hardik 14/02/2014  
    Working_Hrs_End_Time tinyint default 0, --Hardik 14/02/2014  
    GatePass_Deduct_Days numeric(18,2) default 0 -- Add by Gadriwala Muslim 05012014  
  )    
 CREATE NONCLUSTERED INDEX IX_Data ON dbo.#data  
 (  
 Emp_Id,  
 Shift_ID,  
 For_Date)    
    
  EXEC dbo.P_GET_EMP_INOUT @cmp_id, @From_Date, @To_Date, 1    --Added by Jaina 17-11-2016  
    
    
 insert into #Emp_Late  (Emp_ID,Cmp_ID,For_Date,Late_Limit_Sec,Increment_ID,Branch_Id,Late_Limit,Early_Limit_Sec,Early_Limit)    
 select e.Emp_ID,Cmp_ID ,  
    For_Date  
    ,dbo.F_Return_Sec(Emp_Late_Limit),IQ.Increment_ID,IQ.Branch_Id,Emp_Late_Limit,dbo.F_Return_Sec(Emp_Early_Limit),Emp_early_Limit  
  From T0150_Emp_inout_Record E WITH (NOLOCK) Inner join #Emp_Cons ec on     
  e.Emp_ID =Ec.emp_ID Inner join    
   (select I.Emp_Id,Emp_Late_Limit,Emp_Late_Mark,I.Increment_ID,Branch_Id,Emp_Early_mark,Emp_Early_Limit from T0095_Increment I WITH (NOLOCK) inner join     
   (select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK) -- Ankit 08092014 for Same Date Increment  
   where Increment_Effective_date <= @To_Date    
   and Cmp_ID = @Cmp_ID    
   group by emp_ID  ) Qry on    
   I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID)IQ on    
   --e.emp_ID =iq.Emp_ID and Emp_Late_MArk =1    --commented by mansi  
    e.emp_ID =iq.Emp_ID and (Emp_Late_MArk =1  or Emp_Early_mark=1 ) --added by mansi  
   Where For_Date >=@From_Date and For_Date <=@to_Date and e.Cmp_Id =@Cmp_ID   
   AND (E.Chk_By_Superior = 0   
   OR (E.Chk_By_Superior = 1 and (E.Is_Cancel_Early_Out = 0  or E.Is_Cancel_Late_In = 0)) -- changed by gadriwala muslim 03062015  
   OR (E.Chk_By_Superior = 2 and (E.Is_Cancel_Early_Out = 0 or E.Is_Cancel_Late_In = 0) AND E.Half_Full_day='')  
   OR (E.Chk_By_Superior = 2 AND E.Half_Full_day<>'')) --For Reject Case by chetan 020817  
   group by E.Emp_ID ,e.Cmp_ID,e.For_date,Emp_Late_Limit,IQ.Increment_ID,IQ.Branch_Id,Emp_Early_Limit    
  
-----------Hasmukh for effect late effect or not on HO & WO  110711---------------  
  
  
--SET @StrWeekoff_Date = ''  
--SET @StrHoliday_Date = ''  
  
--SELECT @Temp_Branch_ID = Branch_id,@Temp_Emp_id = el.Emp_ID FROM #emp_late el Inner join #Emp_Cons ec on ec.Emp_ID =El.emp_ID   
--SELECT @Is_Late_calc_On_HO_WO = Is_Late_Calc_On_HO_WO FROM dbo.T0040_GENERAL_SETTING WHERE Branch_ID = @Temp_Branch_ID AND Cmp_ID = @Cmp_ID  
      
--Exec SP_EMP_WEEKOFF_DATE_GET @Temp_Emp_id,@Cmp_ID,@From_Date,@To_Date,null,null,0,'',@StrWeekoff_Date output,0,0  
--EXEC SP_EMP_HOLIDAY_DATE_GET @Temp_Emp_id, @Cmp_ID, @From_Date, @To_Date,null, NULL, 0, @StrHoliday_Date OUTPUT,0, 0, 0, @Temp_Branch_ID,@StrWeekoff_Date      
  
-------------For effect HO & Wo--------------------------------------------   
  
-- Commented and Added by rohit For First in last out Calculation on 27092013  
 --Update #Emp_Late Set    
 -- In_time  = q.In_time    
 --,Out_Time = Q2.Out_Time  
 --from #Emp_Late  el inner Join     
 --(Select eir.Emp_ID,for_Date,min(In_time )In_time From T0150_Emp_inout_Record eir inner join    
 --#Emp_Cons ec on eir.Emp_ID =ec.emp_ID group by eir.emp_Id,eir.For_Date)Q on el.emp_ID =q.Emp_ID and el.for_Date =q.For_Date    
 --inner Join (Select eir.Emp_ID,for_Date,max(Out_Time)Out_Time From T0150_Emp_inout_Record eir inner join --Alpesh 23-Jul-2012  
 --#Emp_Cons ec on eir.Emp_ID =ec.emp_ID group by eir.emp_Id,eir.For_Date)Q2 on el.emp_ID =Q2.Emp_ID and el.for_Date =Q2.For_Date  --Alpesh 23-Jul-2012  
   
--Added by Jaina 17-11-2016   
 UPDATE EL  
 SET  IN_TIME = D.IN_TIME,  
   OUT_TIME = D.OUT_TIME  
 FROM #Emp_Late EL INNER JOIN #Data D ON EL.Emp_ID=D.Emp_Id AND EL.For_Date=D.For_date  
  --Comment by Jaina 17-11-2016  
    
    
    
 /*Update #Emp_Late Set    
  In_time  = q.In_time    
 ,Out_Time = Case when Q4.Max_In_Date > Q2.Out_Time Then Q4.Max_In_Date Else  Q2.Out_Time End  
 from #Emp_Late  el inner Join     
 (Select eir.Emp_ID,for_Date,min(In_time )In_time From T0150_Emp_inout_Record eir   
 inner join #Emp_Cons ec on eir.Emp_ID =ec.emp_ID where For_Date between @From_Date and @To_Date group by eir.emp_Id,eir.For_Date )Q on el.emp_ID =q.Emp_ID and el.for_Date =q.For_Date    
 inner Join (Select eir.Emp_ID,for_Date,max(Out_Time)Out_Time From T0150_Emp_inout_Record eir   
 inner join #Emp_Cons ec on eir.Emp_ID =ec.emp_ID where For_Date between @From_Date and @To_Date group by eir.emp_Id,eir.For_Date )Q2 on el.emp_ID =Q2.Emp_ID and el.for_Date =Q2.For_Date  --Alpesh 23-Jul-2012  
   
inner join (select eir.Emp_Id, Max(In_Time) Max_In_Date,For_Date From dbo.T0150_Emp_Inout_Record eir   
inner join #Emp_Cons ec on eir.Emp_ID =ec.emp_ID where For_Date between @From_Date and @To_Date group by eir.emp_Id,eir.For_Date  ) Q4 on el.Emp_Id = Q4.Emp_Id And el.For_Date = Q4.For_Date  
  
Left Outer Join (Select eir.Emp_ID,Chk_By_Superior Chk_By_Sup,For_Date from dbo.T0150_EMP_INOUT_RECORD eir  
inner join #Emp_Cons ec on eir.Emp_ID =ec.emp_ID where Chk_By_Superior=1) Q3 on el.Emp_Id = Q3.Emp_Id And el.For_Date = Q3.For_Date   */  
    
    
  -- ended by  rohit For First in last out Calculation on 27092013   
     
 Declare @For_Date datetime     
 declare @Shift_St_Time  varchar(10)    
 declare @Shift_St_DateTime datetime    
 Declare @In_Date   Datetime    
 declare @var_Shift_St_Date varchar(20)    
 declare @Emp_Late_Limit  varchar(10)    
 declare @Late_Limit_Sec  numeric    
 DECLARE @StrWeekoff_Date VARCHAR(1000)  
 DECLARE @StrHoliday_Date VARCHAR(1000)  
 DECLARE @Is_Late_calc_On_HO_WO TINYINT  
 DECLARE @Temp_Branch_ID NUMERIC  
 Declare @Is_LateMark as tinyint  
 --Alpesh 23-Jul-2012  
 declare @Shift_End_Time  varchar(10)  
 declare @Shift_End_DateTime datetime    
 Declare @Out_Date   Datetime    
 declare @var_Shift_End_Date varchar(20)   
 Declare @Max_Late_Limit  varchar(10)    
 Declare @Shift_Max_DateTime datetime  
 --- End ---     
 -- Rohit 23-mar-2013  
 Declare @Is_EarlyMark as TINYINT  
 declare @Emp_Early_Limit  varchar(10)    
 declare @Early_Limit_Sec  numeric    
 DECLARE @Is_Early_calc_On_HO_WO TINYINT  
 Declare @Max_Early_Limit  varchar(10)    
 Declare @Shift_End_Max_DateTime DATETIME  
 DECLARE @Emp_LateMark AS TINYINT  
 DECLARE @Emp_EarlyMark AS TINYINT  
 declare @is_halfDay varchar(15) --added by Mukti 12062014  
 declare @Shift_Day varchar(15)  --added by Mukti 12062014  
 --End--  
   
   
 SET @Is_LateMark = 1  
 SET @Is_Late_calc_On_HO_WO = 0  
   
 -- Rohit 23-mar-2013  
 SET @Is_EarlyMark = 1  
 SET @Is_Early_calc_On_HO_WO = 0  
 SET @Emp_LateMark = 1  
 SET @Emp_Early_Limit = 1  
   
 -- End ---  
   
   
 /*************************************************************************  
 Added by Nimesh: 01/Mar/2016  
 (To get holiday/weekoff data for all employees in seperate table)  
 *************************************************************************/  
 DECLARE @Required_Execution BIT;  
 SET @Required_Execution = 0;  
   IF OBJECT_ID('tempdb..#Emp_WeekOff_Holiday') IS NULL  
 BEGIN  
  --Holiday & WeekOff - In colon(;) seperated string (Without Cancel) : Used in SP_CALCULATE_PRESENT_DAYS  
  CREATE TABLE #Emp_WeekOff_Holiday  
  (  
   Emp_ID    NUMERIC,  
   WeekOffDate   VARCHAR(Max),  
   WeekOffCount  NUMERIC(3,1),  
   HolidayDate   VARCHAR(Max),  
   HolidayCount  NUMERIC(3,1),  
   HalfHolidayDate  VARCHAR(Max),  
   HalfHolidayCount NUMERIC(3,1),  
   OptHolidayDate  VARCHAR(Max),  
   OptHolidayCount  NUMERIC(3,1)  
  );  
  SET @Required_Execution  = 1;  
 END   
   
 IF OBJECT_ID('tempdb..#EMP_HW_CONS') IS NULL  
 BEGIN   
   
  --Holiday & Weekoff - In colon(;) seperated string (With Cancel) : Used in SP_CALCULATE_PRESENT_DAYS  
  CREATE TABLE #EMP_HW_CONS  
  (  
   Emp_ID    NUMERIC,  
   WeekOffDate   Varchar(Max),  
   WeekOffCount  NUMERIC(3,1),  
   CancelWeekOff  Varchar(Max),  
   CancelWeekOffCount NUMERIC(3,1),  
   HolidayDate   Varchar(MAX),  
   HolidayCount  NUMERIC(3,1),  
   HalfHolidayDate  Varchar(MAX),  
   HalfHolidayCount NUMERIC(3,1),  
   CancelHoliday  Varchar(Max),  
   CancelHolidayCount NUMERIC(3,1)  
  );  
    
  CREATE UNIQUE CLUSTERED INDEX IX_EMP_HW_CONS_EmpID ON #EMP_HW_CONS(Emp_ID)  
    
  SET @Required_Execution  =1;    
 END  
   
 IF @Required_Execution = 1  
 BEGIN  
  DECLARE @All_Weekoff BIT  
  SET @All_Weekoff = 0;  
    
  SET @CONSTRAINT = NULL;  
  SELECT @CONSTRAINT = COALESCE(@CONSTRAINT + '#', '') + CAST(EMP_ID AS VARCHAR(10))  
  FROM (SELECT DISTINCT EMP_ID FROM #Emp_Late T) T  
     
  EXEC SP_GET_HW_ALL @CONSTRAINT=@CONSTRAINT,@CMP_ID=@Cmp_ID, @FROM_DATE=@FROM_DATE, @TO_DATE=@TO_DATE, @All_Weekoff = @All_Weekoff, @Exec_Mode=0    
 END   
   
 SELECT Shift_ID, Shift_St_Time, Shift_End_Time   
 INTO #SHIFT_MASTER  
 FROM T0040_SHIFT_MASTER WITH (NOLOCK)  
 WHERE CMP_ID=@Cmp_ID AND Inc_Auto_Shift=1  
 --Add by Nimesh 21 April, 2015  
 --This sp retrieves the Shift Rotation as per given employee id and effective date.  
 --it will fetch all employee's shift rotation detail if employee id is not specified.  
 IF (OBJECT_ID('tempdb..#Rotation') IS NULL)  
  Create Table #Rotation (R_EmpID numeric(18,0), R_DayName varchar(25), R_ShiftID numeric(18,0), R_Effective_Date DateTime);  
 --The #Rotation table gets re-created in dbo.P0050_UNPIVOT_EMP_ROTATION stored procedure  
 IF EXISTS(SELECT 1 FROM T0050_EMP_MONTHLY_SHIFT_ROTATION R WITH (NOLOCK) INNER JOIN #Emp_Late L ON R.Emp_ID=L.Emp_ID)  
  Exec dbo.P0050_UNPIVOT_EMP_ROTATION @Cmp_ID, NULL, @To_Date, @Constraint  
   
   
 DECLARE @PREV_EMP_ID NUMERIC;  
 SET @PREV_EMP_ID = 0;  
   
   DECLARE @Is_Half_Day As numeric;  
   DECLARE @Half_WeekDay Varchar(10);  
   DECLARE @Half_Shift_St_Time As varchar(10);  
   DECLARE @Half_Shift_End_Time As  varchar(10);     
   DECLARE @Half_Shift_Day AS BIT;  
   declare @Shift_Dur as varchar(10)  
     
 Declare curLate cursor for select Emp_ID,For_Date,In_Time,Late_Limit_Sec,Branch_Id,Out_Time,Early_Limit_Sec From #Emp_Late order by Emp_ID,For_Date   --Rohit on 23042013  
 Open curLate    
 Fetch Next From curLate into @Emp_ID,@For_Date,@In_Date,@Late_Limit_Sec,@Temp_Branch_ID,@Out_Date,@Early_limit_Sec -- Rohit on 23042013  
 While @@fetch_status = 0     
  BEGIN      
     
   IF @PREV_EMP_ID  <> @Emp_ID  
   BEGIN   
    SET @StrWeekoff_Date = ''  
    SET @StrHoliday_Date = ''  
  
    SELECT @Is_Late_calc_On_HO_WO = Is_Late_Calc_On_HO_WO,@Is_LateMark = Is_Late_Mark, @RoundingValue = ISNULL(Early_Hour_Upper_Rounding,0)   
    ,@Max_Late_Limit=isnull(Max_Late_Limit,'00:00')   
    ,@Is_Early_calc_On_HO_WO = Is_Early_Calc_On_HO_WO,@Max_Early_Limit=isnull(Max_Early_Limit,'00:00'),@RoundingValue_early = ISNULL(Late_Hour_Upper_Rounding,0)   -- rohit 23-apr-2013  
    FROM dbo.T0040_GENERAL_SETTING WITH (NOLOCK) WHERE Branch_ID = @Temp_Branch_ID AND Cmp_ID = @Cmp_ID --Alpesh 23-Jul-2012  
    AND For_Date = ( select MAX(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where Cmp_ID = @Cmp_ID and For_Date <= @To_Date and Branch_ID = @Temp_Branch_ID)    --Added By Ramiz on 16/03/2016  
    --Exec SP_EMP_WEEKOFF_DATE_GET @Emp_Id,@Cmp_ID,@From_Date,@To_Date,null,null,0,'',@StrWeekoff_Date output,0,0  
    --EXEC SP_EMP_HOLIDAY_DATE_GET @Emp_Id,@Cmp_ID, @From_Date, @To_Date,null, NULL, 0, @StrHoliday_Date OUTPUT,0, 0, 0, @Temp_Branch_ID,@StrWeekoff_Date      
      
    Select @StrWeekoff_Date = HW.WeekOffDate, @StrHoliday_Date=HW.HolidayDate FROM #EMP_HW_CONS HW WHERE HW.Emp_ID=@Emp_ID  
      
    SET @PREV_EMP_ID  = @Emp_ID  
   END  
       
   --select @Shift_St_Time = T0040_shift_MAster.Shift_St_Time,@Shift_End_Time = T0040_shift_MAster.Shift_End_Time --Alpesh 23-Jul-2012    
   --from T0100_emp_shift_Detail,T0040_shift_MAster where T0100_emp_shift_Detail.Cmp_ID = @Cmp_ID  and emp_id = @emp_id    
   --and for_date in (select max(for_date) from T0100_emp_shift_Detail where Cmp_ID = @Cmp_ID  and for_date <= @For_Date    
   --and emp_id = @emp_id) and T0100_emp_shift_Detail.shift_id = T0040_shift_MAster.shift_id and T0100_emp_shift_Detail.Cmp_ID = T0040_shift_MAster.Cmp_ID   
  
   /*Commented by Nimesh  
   --added By Mukti 12062014(start)  
   select @is_halfDay=sm.Week_Day from T0040_shift_MAster SM  
   Inner Join T0100_emp_shift_Detail ESD on ESD.Cmp_ID = SM.Cmp_ID And ESd.Shift_ID = SM.Shift_ID and esd.For_Date in  
   (select max(for_date) from T0100_emp_shift_Detail where Cmp_ID = @Cmp_ID  and for_date <= @For_Date and emp_id = @emp_id)  
   where ESD.Cmp_ID = @Cmp_ID  and esd.Emp_ID = @emp_id    
   */  
  
   --Added by Nimesh 20 April, 2015  
   --We are using fn_get_Shift_From_Monthly_Rotation scalar function which will return the exact shift id from   
   --the rotation if it is assigned to any employee otherwise it will be taken from Employee Shift Details.  
   DECLARE @Shift_ID numeric(18,0);  
   SET @Shift_ID = NULL;  
   SELECT @Shift_ID = dbo.fn_get_Shift_From_Monthly_Rotation(@Cmp_ID, @Emp_ID, @For_Date);  
   --SELECT @Shift_ID = Shift_ID  
   --FROM T0100_EMP_SHIFT_DETAIL ESD   
   --WHERE ESD.For_Date=@For_Date AND ESD.Cmp_ID=@Cmp_ID AND ESD.Emp_ID=@Emp_ID  
     
    
   --If EXISTS(Select 1 From #Rotation R Where R.R_EmpID=@Emp_ID) AND @Shift_ID IS NULL  
   -- BEGIN  
   --  SELECT @Shift_ID=R_ShiftID  
   --  FROM #Rotation R   
   --  WHERE R.R_EmpID=@Emp_ID AND R.R_DayName = 'Day' + CAST(DATEPART(d, @For_Date) As Varchar)  
   --    AND R.R_Effective_Date=(  
   --           SELECT MAX(R_Effective_Date) FROM #Rotation   
   --           WHERE R_Effective_Date <=@For_Date AND R_EmpID=@Emp_ID  
   --          )            
   -- END  
     
   --IF @Shift_ID IS NULL  
   -- BEGIN  
   --  SELECT @Shift_ID = Shift_ID  
   --  FROM T0100_EMP_SHIFT_DETAIL ESD   
   --  WHERE ESD.For_Date=(  
   --     SELECT MAX(FOR_DATE)  
   --     FROM T0100_EMP_SHIFT_DETAIL ESD1  
   --     WHERE ESD1.Emp_ID=@Emp_ID AND ESD1.Cmp_ID=@Cmp_ID  
   --       AND ESD1.For_Date<=@For_Date AND ISNULL(ESD1.Shift_Type, 0) <> 1  
   --    ) AND ESD.Cmp_ID=@Cmp_ID   AND ESD.Emp_ID=@EMP_ID        
   -- END  
     
   /*The following code added by Nimesh On 23-Aug-2018 (Auto Shift Scenario does not working in Late Early Mark Report)*/  
   IF EXISTS(SELECT 1 FROM #SHIFT_MASTER WHERE SHIFT_ID=@Shift_ID)  
    BEGIN  
     SELECT TOP 1 @Shift_ID = Shift_ID   
     FROM #SHIFT_MASTER  
     ORDER BY ABS(DATEDIFF(S, @In_Date, @For_Date + Shift_St_Time)) ASC  
    END  
     
         
   --SELECT @is_halfDay=sm.Week_Day   
   --FROM T0040_SHIFT_MASTER SM   
   --WHERE Shift_ID=@Shift_ID  
   --End Nimesh  
     
     
   ---aadded By Jimit 19122017----  
     
   --SET @Shift_Id = 0  
     
   SET @Shift_Dur = ''  
   SET @Half_Shift_Day = 0;    
   SET @Half_Shift_St_Time = NULL;  
   SET @Half_Shift_End_Time = NULL;  
   SET @Half_WeekDay = NULL;  
   SET @Is_Half_Day = NULL;  
     
   --Exec SP_CURR_T0100_EMP_SHIFT_GET @Emp_ID,@Cmp_ID,@For_Date,@Shift_St_Time output,@Shift_End_Time output,@Shift_Dur output  
   --        ,null,null,null,null,@Shift_Id output,@Is_Half_Day OUTPUT, @Half_WeekDay OUTPUT, @Half_Shift_St_Time OUTPUT,  
   --        @Half_Shift_End_Time OUTPUT         
     
  
   SELECT @Shift_Dur =  CASE WHEN Is_Half_Day=1 AND datename(WEEKDAY,@In_Date) = Week_Day AND Half_Dur Is NOT NULL Then  Half_Dur Else  Shift_Dur END,   
     @Shift_St_Time=CASE WHEN Is_Half_Day=1 AND datename(WEEKDAY,@In_Date) = Week_Day AND Half_St_Time Is NOT NULL Then  Half_St_Time Else  Shift_St_Time END,   
     @Shift_End_Time=CASE WHEN Is_Half_Day=1 AND datename(WEEKDAY,@In_Date) = Week_Day AND Half_End_Time Is NOT NULL Then  Half_End_Time Else  Shift_End_Time END  
   FROM T0040_SHIFT_MASTER WITH (NOLOCK)  
   WHERE shift_id= @Shift_ID  
     
     
   --SELECT @is_halfDay=sm.Week_Day   
   --FROM T0040_SHIFT_MASTER SM   
   --WHERE Shift_ID=@Shift_ID  
   --End Nimesh  
     
   --SET @Shift_Day = datename(WEEKDAY,@In_Date)   
      
   -- If @Shift_Day = @Half_WeekDay   
   --   Begin  
   --     SET @Shift_St_Time = @Half_Shift_St_Time  
   --     SET @Shift_End_Time = @Half_Shift_End_Time  
   --   END  
     
   --SET @Shift_Day = datename(WEEKDAY,@In_Date)   
         
   --IF @Shift_Day=@is_halfDay  
   -- BEGIN  
   --     /*Commented by Nimesh  
   --     select @Shift_St_Time = SM.Half_St_Time,@Shift_End_Time = SM.Half_End_Time --Alpesh 23-Jul-2012    
   --  from T0100_emp_shift_Detail ESD Inner Join T0040_shift_MAster SM on ESD.Cmp_ID = SM.Cmp_ID And ESd.Shift_ID = SM.Shift_ID   
   --  where ESD.Cmp_ID = @Cmp_ID  and emp_id = @emp_id    
   --  and for_date in (select max(for_date) from T0100_emp_shift_Detail where Cmp_ID = @Cmp_ID  and for_date <= @For_Date    
   --  and emp_id = @emp_id) and ESD.shift_id = SM.shift_id and ESD.Cmp_ID = SM.Cmp_ID     
   --  */  
   --  --Add by Nimesh 20 April, 2015  
   --  SELECT @Shift_St_Time = SM.Half_St_Time,@Shift_End_Time = SM.Half_End_Time  
   --  FROM T0040_SHIFT_MASTER SM   
   --  WHERE Shift_ID=@Shift_ID     
   --  --End Nimesh  
   -- END  
   --ELSE  
   -- BEGIN  
   --  /*Commented by Nimesh  
   --  select @Shift_St_Time = SM.Shift_St_Time,@Shift_End_Time = SM.Shift_End_Time --Alpesh 23-Jul-2012    
   --  from T0100_emp_shift_Detail ESD Inner Join T0040_shift_MAster SM on ESD.Cmp_ID = SM.Cmp_ID And ESd.Shift_ID = SM.Shift_ID   
   --  where ESD.Cmp_ID = @Cmp_ID  and emp_id = @emp_id    
   --  and for_date in (select max(for_date) from T0100_emp_shift_Detail where Cmp_ID = @Cmp_ID  and for_date <= @For_Date    
   --  and emp_id = @emp_id) and ESD.shift_id = SM.shift_id and ESD.Cmp_ID = SM.Cmp_ID     
   --  */  
   --  --Add by Nimesh 20 April, 2015  
       
   --  SELECT @Shift_St_Time = SM.Shift_St_Time,@Shift_End_Time = SM.Shift_End_Time  
   --  FROM T0040_SHIFT_MASTER SM   
   --  WHERE Shift_ID=@Shift_ID     
   --  --End Nimesh  
   -- END  
   --added By Mukti 12062014(end)  
  
   SET @var_Shift_St_Date = cast(@In_Date as varchar(11)) + ' '  + @Shift_St_Time  
        
   -- SET @var_Shift_End_Date = ISNULL(cast(@Out_Date as varchar(11)),cast(@In_Date as varchar(11))) + ' '  + @Shift_End_Time --Alpesh 23-Jul-2012    
   -- Commented and change by rohit on 17102013 for Out on next date  
   --SET @var_Shift_End_Date = ISNULL(cast(@Out_Date as varchar(11)),cast(@In_Date as varchar(11))) + ' '  + @Shift_End_Time --Alpesh 23-Jul-2012    
   if @Shift_St_Time > @Shift_End_Time  
    SET @var_Shift_End_Date = ISNULL(cast(@Out_Date as varchar(11)),cast(@In_Date as varchar(11))) + ' '  + @Shift_End_Time --Alpesh 23-Jul-2012    
   else  
    SET @var_Shift_End_Date = ISNULL(cast(@In_Date as varchar(11)),cast(@Out_Date as varchar(11))) + ' '  + @Shift_End_Time --Alpesh 23-Jul-2012    
   -- Commented and change by rohit on 17102013 for Out on next date  
  
   SET @Shift_Max_DateTime = dateadd(s,dbo.F_Return_Sec(@Max_Late_Limit),@var_Shift_St_Date)  --Alpesh 23-Jul-2012     
        
   SET @Shift_End_Max_DateTime = dateadd(s,dbo.F_Return_Sec(@Max_Early_Limit)*(-1) ,@var_Shift_End_Date)  --rohit 23-apr-2013   
     
      
   SET @Shift_St_DateTime = cast(@var_Shift_St_Date as datetime)    
   SET @Shift_St_DateTime = dateadd(s,@Late_Limit_Sec,@Shift_St_DateTime)    
      
   --Alpesh 23-Jul-2012    
   SET @Shift_End_DateTime = cast(@var_Shift_End_Date as datetime)   
   SET @Shift_End_DateTime = dateadd(s,@Early_Limit_Sec*(-1),@Shift_End_DateTime)    
  
  
  
   Update #Emp_Late    
   Set Shift_Max_St_Time=@Shift_Max_DateTime  
   ,shift_max_ed_time = @Shift_End_Max_DateTime , Shift_ID = @Shift_ID ,  
   Is_Late_Calc_Ho_WO = @Is_Late_calc_On_HO_WO,  
   Is_Early_Calc_Ho_Wo = @Is_Early_calc_On_HO_WO  -- Added by Gadriwala Muslim 03072015  
   Where Emp_ID=@Emp_ID and For_Date =@For_Date   
   --- End ---  
     
    
   select @Emp_LateMark=I.Emp_Late_mark, @Emp_EarlyMark = I.Emp_Early_mark   
   from T0095_Increment I WITH (NOLOCK) inner join     
     ( select max(Increment_ID) as Increment_ID , Emp_ID From T0095_Increment WITH (NOLOCK) -- Ankit 08092014 for Same Date Increment  
     where Increment_Effective_date <= @To_Date    
     and Cmp_ID = @Cmp_ID    
     group by emp_ID  ) Qry on    
     I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID     
      WHERE I.emp_id=@Emp_ID  
  
    ------Hasmukh for Late effect or not on WO HO 110711 -----------  
         
       
   If @Is_LateMark = 1  
    Begin  
     IF @Emp_LateMark = 1  
     BEGIN  
      IF @Is_Late_calc_On_HO_WO = 1  
       BEGIN        
          
          update #Emp_Late    
          set Shift_Time =@Shift_St_DateTime  
          --,Shift_End_Time=@Shift_End_Max_DateTime  --Alpesh 23-Jul-2012      
          Where Emp_ID=@Emp_ID and For_Date =@For_Date    
       END  
      ELSE  
       BEGIN  
        if charindex(cast(@For_Date as varchar(11)),@StrWeekoff_Date,0) <> 0 or charindex(cast(@For_Date as varchar(11)),@StrHoliday_Date,0) <> 0   
         Begin   
           update #Emp_Late    
           set In_Time =@Shift_St_DateTime,Shift_Time =@Shift_St_DateTime  
           --,Shift_End_Time=@Shift_End_Max_DateTime  --Alpesh 23-Jul-2012        
           Where Emp_ID=@Emp_ID and For_Date =@For_Date    
          End  
        Else  
         Begin  
           update #Emp_Late    
           set Shift_Time =@Shift_St_DateTime  
           --,Shift_End_Time=@Shift_End_DateTime  --Alpesh 23-Jul-2012       
           Where Emp_ID=@Emp_ID and For_Date =@For_Date    
         End  
       END  
      END  
     ELSE  
      BEGIN  
       update #Emp_Late    
       set In_Time =@Shift_St_DateTime,Shift_Time =@Shift_St_DateTime  
       --,out_time=@Shift_end_DateTime        
       Where Emp_ID=@Emp_ID and For_Date =@For_Date    
      END   
      -- ROhit 23-apr-2013  
     IF @Emp_EarlyMark = 1   
     BEGIN  
      IF @Is_Early_calc_On_HO_WO = 1  
       BEGIN              
          update #Emp_Late    
          set   
          --Shift_Time =@Shift_St_DateTime  
          --Shift_End_Time=@Shift_End_Max_DateTime  --Comment By Jaina 11-03-2016  
          Shift_End_Time = @Shift_End_DateTime   --Added By Jaina 11-03-2016  
          Where Emp_ID=@Emp_ID and For_Date =@For_Date    
       END  
      ELSE  
       BEGIN    
        if charindex(cast(@For_Date as varchar(11)),@StrWeekoff_Date,0) <> 0 or charindex(cast(@For_Date as varchar(11)),@StrHoliday_Date,0) <> 0   
         Begin  
           update #Emp_Late    
           set   
           --In_Time =@Shift_St_DateTime,Shift_Time =@Shift_St_DateTime  
           out_time = @Shift_end_DateTime  
           ,Shift_End_Time=@Shift_End_DateTime  --Alpesh 23-Jul-2012        
           Where Emp_ID=@Emp_ID and For_Date =@For_Date    
          End  
        Else  
         Begin  
           update #Emp_Late    
           SET  
           -- Shift_Time =@Shift_St_DateTime  
           Shift_End_Time=@Shift_End_DateTime    
           Where Emp_ID=@Emp_ID and For_Date =@For_Date    
         End  
       END  
      END  
      ELSE  
      BEGIN  
        update #Emp_Late    
        set Shift_End_Time=@Shift_End_DateTime ,out_time=@Shift_end_DateTime        
       Where Emp_ID=@Emp_ID and For_Date =@For_Date   
      END   
        
    End  
   Else  
    Begin  
       update #Emp_Late    
       set In_Time =@Shift_St_DateTime,Shift_Time =@Shift_St_DateTime,Shift_End_Time=@Shift_End_DateTime  --Alpesh 23-Jul-2012  
       ,out_time=@Shift_end_DateTime        
       Where Emp_ID=@Emp_ID and For_Date =@For_Date    
    End    
    
   FETCH NEXT FROM curLate into @Emp_ID,@For_Date,@In_Date,@Late_Limit_Sec,@Temp_Branch_ID,@Out_Date,@Early_Limit_Sec   --Alpesh 23-Jul-2012  
  END  
 CLOSE curLate    
 DEALLOCATE curLate    
     
  
  
 --Update #Emp_Late    
 --Changed by Hardik 17/03/2015 for Wonder as if Somebody comes Late after Grace Period than Grace Period should deduct from Late Sec (10 Mins)  
 --  set Late_sec = datediff(s,Shift_Max_St_Time,In_Time)--+Late_Limit_sec  
 --,  Late_Hour = dbo.F_Return_Hours (datediff(s,Shift_Max_St_Time,In_Time))--+Late_Limit_sec)    
  
 --set Late_sec = datediff(s,Shift_Time,In_Time) -- Shift_Max_St_Time--+Late_Limit_sec  
 --,  Late_Hour = dbo.F_Return_Hours (datediff(s,Shift_Time,In_Time))-- Shift_Max_St_Time --+Late_Limit_sec)    
 --,Is_Late = 1  -- Added by rohit on 01022016  
 --where datediff(s,Shift_Time,cast(cast(in_time as varchar(11)) + ' ' + dbo.F_Return_HHMM(in_time) as datetime)) > 0    
  
    
  Update #Emp_Late  set      
   Late_sec = datediff(s,Shift_Time,In_Time),  
   Late_Hour = dbo.F_Return_Hours (datediff(s,Shift_Time,In_Time)),  
   Is_Late = 1  
   where datediff(s,Shift_Time,In_Time) > 0    
   
   
   
  -- Rohit 23-apr-2013  
   
  --  set Early_sec = datediff(s,out_time,Shift_End_Time)--+Early_Limit_sec  
  --,  Early_Hour = dbo.F_Return_Hours (datediff(s,out_time,Shift_End_Time))--+Late_Limit_sec)    
 Update #Emp_Late    
  set Early_sec = datediff(s,out_time,Shift_max_Ed_Time)--+Early_Limit_sec  
  ,  Early_Hour = dbo.F_Return_Hours (datediff(s,out_time,Shift_max_Ed_Time))--+Late_Limit_sec)    
  where datediff(s,cast(cast(Out_Time as varchar(11)) + ' ' + dbo.F_Return_HHMM(Out_Time) as datetime),Shift_End_Time) > 0    
  --End--  
      
     
      
  --Alpesh 23-Jul-2012    
  Update #Emp_Late    
  set Late_sec = 0,Late_Hour = 0  
  where datediff(s,Shift_Time,In_Time) > 0 and (In_Time >= Shift_Time and In_Time <= Shift_Max_St_Time and datediff(s,dateadd(s,-1*Late_Limit_Sec,Shift_Time),Shift_End_Time)<=datediff(s,In_Time,Out_Time))  
   
  
 --Hardik 12/02/2015 as If employee In at 9:10:29 AM and allowed up to 9:10 AM then 29 Second should not calculate for Late Mark  
  Update #Emp_Late    
  set Late_sec = 0,Late_Hour = 0  
  where Late_Sec < 60  
    
    
  -- comment by rohit for --already add it to before set shift_max_st time. on 01022016  
  --Update #Emp_Late  set    --Added by Gadriwala Muslim 0302015  
  -- Late_sec = datediff(s,Shift_Time,In_Time),  
  -- Late_Hour = dbo.F_Return_Hours (datediff(s,Shift_Time,In_Time)),  
  -- Is_Late = 1  
  -- where datediff(s,Shift_Time,In_Time) > 0    
   
   
 --select dateadd(s,-1*Late_Limit_Sec,Shift_Time),Shift_End_Time,In_Time,Out_Time,datediff(s,dateadd(s,-1*Late_Limit_Sec,Shift_Time),Shift_End_Time),datediff(s,In_Time,Out_Time) from #Emp_Late where For_Date='01-Jun-2012'  
 --select dateadd(s,-1*Late_Limit_Sec,Shift_Time),In_Time,Shift_Max_St_Time,Shift_End_Time,Out_Time from #Emp_Late where For_Date='01-Jun-2012'  
 --- End ---   
  
-- Rohit 23-apr-2013  
  Update #Emp_Late    
  set Early_sec = 0,Early_Hour = 0  
  where datediff(s,Out_time,Shift_End_Time) > 0 and (Out_Time >= Shift_End_Time and Out_Time <= Shift_Max_ed_Time and datediff(s,dateadd(s,Early_Limit_Sec,Shift_End_Time),shift_time)<=datediff(s,In_Time,Out_Time))  
 -- End --  
  
 --Hardik 12/02/2015 as If employee Out at 6:10:29 AM and allowed up to 5:50 AM then 29 Second should not calculate for Early Mark  
  Update #Emp_Late    
  set Early_sec = 0,Early_Hour = 0  
  where Early_sec < 60  
  
 Update #Emp_Late  set    --Added by Jaina 11-03-2016  
   Early_sec = datediff(s,Out_Time,Shift_End_Time),  
   Early_Hour = dbo.F_Return_Hours (datediff(s,Out_Time,Shift_End_Time))  
   where datediff(s,Shift_End_Time,Out_Time) < 0    
     
   -- Start half day leave condition added by mitesh on 23/01/2012   
      
   Update #Emp_Late    
 set Late_sec = 0,    
  Late_Hour = 0  
   from #Emp_Late EL  
  inner join (select la.Leave_Approval_ID,la.Emp_ID,lad.To_Date from T0120_LEAVE_APPROVAL la WITH (NOLOCK)  
    inner join T0130_LEAVE_APPROVAL_DETAIL lad WITH (NOLOCK) on la.Leave_Approval_ID = lad.Leave_Approval_ID  
    where Leave_Assign_As = 'First Half' and Approval_Status = 'A') Qry   
  on Qry.Emp_ID = el.Emp_ID and Qry.To_Date = el.For_Date   
  and Qry.Leave_Approval_ID   
  NOT IN(Select Leave_Approval_id   
       From T0150_LEAVE_CANCELLATION LC WITH (NOLOCK)  
       INNER Join #Emp_Late EL   
       ON LC.Emp_Id = EL.Emp_ID and EL.For_Date = LC.For_date and LC.Is_Approve=1  
       )  
    
    
    -- End half day leave condition added by mitesh on 23/01/2012   
      
      
   -- rohit 23-apr-2013    
      
   Update #Emp_Late    
 set Early_sec = 0,    
  Early_Hour = 0  
   from #Emp_Late EL  
  inner join (select la.Leave_Approval_ID,la.Emp_ID,lad.To_Date from T0120_LEAVE_APPROVAL la WITH (NOLOCK)  
    inner join T0130_LEAVE_APPROVAL_DETAIL lad WITH (NOLOCK) on la.Leave_Approval_ID = lad.Leave_Approval_ID  
    where Leave_Assign_As = 'Second Half' and Approval_Status = 'A') Qry   
  on Qry.Emp_ID = el.Emp_ID and Qry.To_Date = el.For_Date  
  -- end 23-apr-2013  
      
     -- Added by rohit on 23-may-2014  
    Update #Emp_Late    
 set Early_sec = 0,    
  Early_Hour = 0,  
  Late_sec = 0,    
  Late_Hour = 0  
   from #Emp_Late EL  
  inner join t0140_leave_transaction Qry   
  on Qry.Emp_ID = el.Emp_ID and Qry.For_Date = el.For_Date and (qry.leave_used = 1  or qry.CompOff_Used = 1) -- changed By Gadriwala Muslim 01102014  
    
  -- Ended by rohit on 23-may-2014  
      
       -- Start Part Day leave condition added by Rohit on 03/03/2015   
      
   Update #Emp_Late    
 set Late_sec = 0,    
  Late_Hour = 0  
   from #Emp_Late EL  
  inner join (select la.Leave_Approval_ID,la.Emp_ID,lad.To_Date,Leave_out_time ,Leave_In_Time  from T0120_LEAVE_APPROVAL la WITH (NOLOCK)  
    inner join T0130_LEAVE_APPROVAL_DETAIL lad WITH (NOLOCK) on la.Leave_Approval_ID = lad.Leave_Approval_ID  
    where upper(Leave_Assign_As) = 'PART DAY' and Approval_Status = 'A') Qry   
  on Qry.Emp_ID = el.Emp_ID and Qry.To_Date = el.For_Date and Qry.Leave_out_time =EL.Shift_Max_St_Time    
    
  
   Update #Emp_Late    
 set Early_sec = 0,    
  Early_Hour = 0  
   from #Emp_Late EL  
  inner join (select la.Leave_Approval_ID,la.Emp_ID,lad.To_Date,Leave_out_time ,Leave_In_Time  from T0120_LEAVE_APPROVAL la WITH (NOLOCK)  
    inner join T0130_LEAVE_APPROVAL_DETAIL lad WITH (NOLOCK) on la.Leave_Approval_ID = lad.Leave_Approval_ID  
    where upper(Leave_Assign_As) = 'PART DAY' and Approval_Status = 'A') Qry   
  on Qry.Emp_ID = el.Emp_ID and Qry.To_Date = el.For_Date and Qry.Leave_In_Time =EL.Shift_End_Time   
    
   -- End Part Day leave condition added by Rohit on 03/03/2015  
   -- Added by Gadriwala Muslim 03062015-Start  
     
   update #Emp_Late  
   set Late_Sec = 0   
    ,Late_Hour = 0  
    from #Emp_Late EL  
    inner join ( select Chk_By_Superior,Is_Cancel_Early_Out,Is_Cancel_Late_In,Emp_ID,For_Date   
     from T0150_EMP_INOUT_RECORD E WITH (NOLOCK) where   
     For_Date >=@From_Date and For_Date <=@to_Date and e.Cmp_Id =@Cmp_ID  
      --and Chk_By_Superior <> 0 comment by chetan 020817  
      and ((IsNull(Chk_By_Superior,0)= 1 and ISNULL(E.Half_Full_day,'') <> '') OR (ISNULL(E.Half_Full_day,'') = '' AND IsNull(Chk_By_Superior,0)= 2))  
       and Is_Cancel_Late_In =  1)Qry  --Changed by Ramiz on 29/03/2016 , Previously it was Chk_By_Superior = 1 , but as now Chk_By_Superior = 2 is also included , so Condition is changed  
   on Qry.Emp_ID =el.Emp_ID and Qry.For_Date = el.For_Date   
     
     
    
   update #Emp_Late  
   set Early_sec = 0   
    ,Early_Hour = 0  
    from #Emp_Late EL  
    inner join ( select Chk_By_Superior,Is_Cancel_Early_Out,Is_Cancel_Late_In,Emp_ID,For_Date   
     from T0150_EMP_INOUT_RECORD E WITH (NOLOCK) where   
     For_Date >=@From_Date and For_Date <=@to_Date and e.Cmp_Id =@Cmp_ID   
     --and Chk_By_Superior <> 0 comment by chetan 020817  
     and ((IsNull(Chk_By_Superior,0)= 1 and ISNULL(E.Half_Full_day,'') <> '') OR (ISNULL(E.Half_Full_day,'') = '' AND IsNull(Chk_By_Superior,0)= 2))  
     and Is_Cancel_Early_Out =  1)Qry --Changed by Ramiz on 29/03/2016 , Previously it was Chk_By_Superior = 1 , but as now Chk_By_Superior = 2 is also included , so Condition is changed  
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
 from T0050_Shift_Detail SD WITH (NOLOCK) inner join #Emp_Late EL on EL.shift_ID = Sd.Shift_ID  order by SD.shift_ID,Calculate_Days   
          
   
   Declare curCheckAbsent cursor for   
  select emp_ID,Branch_ID,For_Date from #Emp_Late where Is_Late = 1 and For_Date >= @From_date and For_Date <= @To_Date and out_Time is null   
  union -- Records which Calculate Days greater than 0 Check for Absent  
  select EL.emp_ID,EL.Branch_ID,EL.For_Date from #Emp_Late EL inner join  
  #Shift_Details Qry on Qry.Shift_ID = El.Shift_ID and Qry.Row_ID = 1  
  where  EL.Is_Late = 1 and Datediff(s,In_Time,Out_Time)/3600  < From_hour  and out_time is not null   
  and Calculate_days > 0   and EL.For_Date >= @From_date and EL.For_Date <= @To_Date   
  union   -- Records which Calculate Days is 0 Check for Absent  
  select EL.emp_ID,EL.Branch_ID,EL.For_Date from #Emp_Late EL inner join  
  #Shift_Details Qry on Qry.Shift_ID = El.Shift_ID and Qry.Row_ID = 1  
  where  EL.Is_Late = 1 and Datediff(s,In_Time,Out_Time)/3600  >= From_hour and  Datediff(s,In_Time,Out_Time)/3600  <= To_Hour  and out_time is not null   
  and Calculate_days = 0   and EL.For_Date >= @From_date and EL.For_Date <= @To_Date  
  order by emp_id   
   
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
    
  DECLARE @ABS_FROM_DATE DATETIME,  
    @ABS_TO_DATE DATETIME;  
      
      
  select @ABS_FROM_DATE= MIN(For_Date),@ABS_TO_DATE= MAX(For_Date)   
  FROM   
  (SELECT Distinct For_Date from #Emp_Late where Is_Late = 1 and For_Date >= @From_date and For_Date <= @To_Date and out_Time is null   
  union -- Records which Calculate Days greater than 0 Check for Absent  
  select EL.For_Date from #Emp_Late EL inner join  
  #Shift_Details Qry on Qry.Shift_ID = El.Shift_ID and Qry.Row_ID = 1  
  where  EL.Is_Late = 1 and Datediff(s,In_Time,Out_Time)/3600  < From_hour  and out_time is not null   
  and Calculate_days > 0   and EL.For_Date >= @From_date and EL.For_Date <= @To_Date   
  union   -- Records which Calculate Days is 0 Check for Absent  
  select EL.For_Date from #Emp_Late EL inner join  
  #Shift_Details Qry on Qry.Shift_ID = El.Shift_ID and Qry.Row_ID = 1  
  where  EL.Is_Late = 1 and Datediff(s,In_Time,Out_Time)/3600  >= From_hour and  Datediff(s,In_Time,Out_Time)/3600  <= To_Hour  and out_time is not null   
  and Calculate_days = 0   and EL.For_Date >= @From_date and EL.For_Date <= @To_Date) t  
   
  truncate table #Data   --Added by Jaina 17-11-2016     
  Exec dbo.SP_CALCULATE_PRESENT_DAYS @Cmp_ID,@ABS_FROM_DATE,@ABS_TO_DATE,0,0,0,0,0,0,0,@ABS_CONSTRAINT,4,'',1    
    
  update #Emp_Late set Late_Sec = 0   
  from #Emp_Late EL inner join    
    #Data D on EL.For_Date = D.For_date and EL.Emp_ID = D.Emp_ID  and D.P_days = 0  
  where Cmp_ID = @Cmp_ID   
    
  update #Emp_Late set Is_Late = 1   
  from #Emp_Late EL inner join    
    #Data D on EL.For_Date = D.For_date and EL.Emp_ID = D.Emp_ID  and D.P_days = 0  
  where Cmp_ID = @Cmp_ID and ( EL.Is_Late_Calc_Ho_WO = 1 and ( D.Weekoff_OT_Sec > 0 or D.Holiday_OT_Sec > 0))  
    
    
  Update #Emp_Late set Late_Hour = 0 ,Late_Sec = 0 where Is_Late = 0  
    
   --declare curCheckAbsent cursor for select emp_ID,Branch_ID,For_Date from #Emp_Late where   
   -- open curCheckAbsent  
   --Fetch next from curCheckAbsent into @Absent_emp_Id,@Absent_Branch_ID,@Absent_For_date  
   -- while @@FETCH_STATUS = 0   
   -- begin  
      
   --  Exec dbo.SP_CALCULATE_PRESENT_DAYS @Cmp_ID,@Absent_For_date,@Absent_For_date,@Absent_Branch_ID,0,0,0,0,0,@Absent_emp_Id,'',4,'',1     
   --   if exists (select 1 from #Data where For_date =@Absent_For_date and Emp_Id = @Absent_emp_Id  and P_days = 0 )  
   --   begin  
   --     update #Emp_Late set  Late_Sec = 0 ,Late_Hour = 0 where For_Date = @Absent_For_date and Emp_ID = @Absent_emp_Id  
   --   end  
            
   --  Fetch next from curCheckAbsent into @Absent_emp_Id,@Absent_Branch_ID,@Absent_For_date  
   -- end  
   -- close curCheckAbsent  
   -- deallocate curcheckAbsent   
   --Added by Gadriwala Muslim 24062015 - End  
     
     
        
  if @Report_Type ='Summary'    
  begin    
      
    select qry.*, isnull(late_time,'') as late_time,isnull(Early_time,'') as Early_time from   
  (  
     select @From_Date as From_Date,@To_Date as to_Date,sum(Late_Sec) Total_Late_sec, El.Emp_ID,  
     dbo.F_Return_Hours (sum(Late_Sec))total_Late_Hours,    
     em.Emp_full_name,em.emp_code,em.alpha_Emp_code,em.Emp_First_Name,  
     bm.branch_name,bm.comp_name,bm.branch_address,cm.cmp_name,  
     cm.cmp_address ,DSM.Desig_name,Dm.Dept_Name,DSM.Desig_Dis_No  
     ,Count(Late_Sec) as Total_Late_Count  
     ,vs.Vertical_Name,sv.SubVertical_Name,GM.Grd_Name,TM.Type_Name --added jimit 28042016  
     from  #Emp_Late el     
     inner join T0080_EMP_MASTER em WITH (NOLOCK) on  el.emp_id = em.emp_id     
     inner join T0030_BRANCH_MASTER bm WITH (NOLOCK) on em.branch_id=bm.branch_id    
     inner join t0010_company_master cm WITH (NOLOCK) on em.cmp_id = cm.cmp_id     
     left join t0040_designation_master DSM WITH (NOLOCK) on em.Desig_id = DSM.Desig_id   
     left join T0040_department_master DM WITH (NOLOCK) on em.Dept_id = DM.Dept_id  
      left outer JOIN T0040_Vertical_Segment VS WITH (NOLOCK) On em.Vertical_ID = VS.Vertical_ID  --added jimit 28042016  
      left outer JOIN T0050_SubVertical SV WITH (NOLOCK) On em.SubVertical_ID = sv.SubVertical_ID --added jimit 28042016  
      left join T0040_TYPE_MASTER TM WITH (NOLOCK) on em.Type_ID = TM.Type_ID      --added jimit 28042016  
      left join T0040_GRADE_MASTER GM WITH (NOLOCK) on em.Grd_ID = GM.Grd_ID    --added jimit 28042016    
     Where Late_sec >0  OR early_sec > 0     --Change By Jaina 29-10-2015  
     group by el.emp_ID,em.Emp_full_name,em.Emp_code,em.alpha_Emp_code,em.Emp_First_Name,bm.Branch_Name,bm.branch_address,cm.cmp_name,cm.cmp_address,bm.Comp_Name,DSM.Desig_name,Dm.Dept_Name,DSM.Desig_Dis_No    
      ,vs.Vertical_Name,sv.SubVertical_Name,GM.Grd_Name,TM.Type_Name   
     --order by el.emp_ID  
     )  qry left join (select isnull(late_hour,0) as late_time,isnull(Early_Hour,0) as Early_time,Emp_ID,For_Date  from #Emp_Late  where for_date = @to_date) as ele on Qry.emp_id = ele.emp_id and ele.For_Date=@to_date   
     ORDER BY RIGHT(REPLICATE(N' ', 500) + Qry.Alpha_Emp_Code, 500)  
     
  end  
  else if @Report_Type='LateSecond'  
  begin  
    
   insert into #Emp_Late_Second (Emp_Id,Cmp_Id,For_Date,Late_Sec)  
   select El.Emp_ID,em.cmp_id,el.For_Date as From_Date,sum(Late_Sec) Late_sec  
   from  #Emp_Late el     
     inner join T0080_EMP_MASTER em WITH (NOLOCK) on  el.emp_id = em.emp_id     
     inner join T0030_BRANCH_MASTER bm WITH (NOLOCK) on em.branch_id=bm.branch_id    
     inner join t0010_company_master cm WITH (NOLOCK) on em.cmp_id = cm.cmp_id     
     Where Late_sec >0  and el.Emp_ID=@Emp_ID   
     group by El.Emp_ID,em.cmp_id,el.For_Date,Late_sec, em.alpha_Emp_code  
     --order by el.emp_ID  
     ORDER BY RIGHT(REPLICATE(N' ', 500) + em.Alpha_Emp_Code, 500)  
  
  
            
  end   
  else if @report_Type='Late_Reminder'  
  begin  
    select   
   el.Emp_ID    ,    
   el.Cmp_ID    ,    
   el.Increment_ID ,    
   el.For_Date  as For_Date,  
   el.In_Time    ,    
   dateadd(s,el.Late_Limit_Sec*-1 ,el.SHIFT_TIME) as Shift_Time ,  
   el.Late_Sec  ,    
   el.Late_Limit_Sec  ,    
   el.Late_Hour ,   
   el.Branch_Id ,  
   el.Late_Limit ,  
   el.Out_Time        
   ,el.Shift_End_Time    
   ,dateadd(s,el.Late_Limit_Sec*-1 ,el.SHIFT_TIME) as Shift_Time   
   ,dateadd(s,el.Early_Limit_Sec,el.SHIFT_end_time) as Shift_End_Time   
   ,el.Early_Sec   
   ,el.Early_Limit_Sec  
   ,el.Early_Hour   
   ,el.Early_Limit      ,el.shift_Id  
   ,el.Is_Late    
   from #Emp_Late el   
   Where Late_sec > 0  OR early_sec > 0  
  end  
  else    
    BEGIN 
	 --select * from #Emp_Late
	--print 50000
	
	DECLARE @Late_Count_Exemption AS VARCHAR(100) = '',@inSeconds as numeric,@Monthly_Exemption_Limit as varchar(100) = '',@ValCount as numeric = 0,@Wloop as numeric = 0
	,@durationtotal as NUMERIC(18,2),@rownum as numeric = 0,@intime as datetime,@frdate as varchar(500),@lthour as NUMERIC(18,2),@lthourtemp as Numeric(18,2)
	,@Intimetemp as Datetime,@frdatetemp as varchar(200)
	
	SELECT @Late_Count_Exemption = Late_Count_Exemption,@Monthly_Exemption_Limit = Monthly_Exemption_Limit FROM T0040_GENERAL_SETTING WHERE CMP_ID = @Cmp_ID AND BRANCH_ID = @Temp_Branch_ID
	--SELECT @Late_Count_Exemption,@Max_Late_Limit--,@Temp_Branch_ID
	--RETURN

	IF @Late_Count_Exemption = '-1.00' AND @Max_Late_Limit IS NOT NULL
	BEGIN 

			CREATE TABLE #TMPDATA(
				EMP_ID NUMERIC,
				INC_ID NUMERIC,
				FOR_DATE VARCHAR(500),
				IN_TIME DATETIME,
				OUT_TIME DATETIME,
				LATE_HOUR VARCHAR(500),
				MAX_LATE_LIMIT VARCHAR(250),
				TOTAL_DURATION NUMERIC(18,2)
			)

			CREATE TABLE #TMPABS(
				LATE_HOUR VARCHAR(500),
				IN_TIME DATETIME,
				FOR_DATE VARCHAR(500)
			)

			SET @Max_Late_Limit =  Stuff(@Max_Late_Limit, 3, 3, '') 
			SET @inSeconds = (CAST(@Max_Late_Limit AS numeric) * 60) * 60
			SET @Monthly_Exemption_Limit =  REPLACE(@Monthly_Exemption_Limit, ':', '.');
			
			INSERT INTO #TMPDATA
			select el.Emp_ID,el.Increment_ID,convert(varchar(10),el.For_Date ,103) as For_Date,el.In_Time,el.Out_Time,Late_Hour,@Monthly_Exemption_Limit AS MAX_LATE_LIMIT,     
		   Cast(@Monthly_Exemption_Limit as  numeric(18,2)) - Cast(Replace(Late_Hour,':','.') as numeric(18,2)) as DurationTotal
		   from #Emp_Late el inner join T0095_Increment i WITH (NOLOCK) on el.increment_ID=i.Increment_ID    
		   inner join T0080_EMP_MASTER em WITH (NOLOCK) on  el.emp_id = em.emp_id    
		   inner join T0030_BRANCH_MASTER bm WITH (NOLOCK) on em.branch_id=bm.branch_id    
		   inner join t0010_company_master cm WITH (NOLOCK) on em.cmp_id = cm.cmp_id  
		   left join t0040_designation_master DSM WITH (NOLOCK) on i.Desig_id = DSM.Desig_id    
		      left join T0040_department_master DM WITH (NOLOCK) on i.Dept_id = DM.Dept_id           
		      left join T0040_TYPE_MASTER TM WITH (NOLOCK) on i.Type_ID = TM.Type_ID   
		      left join T0040_GRADE_MASTER GM WITH (NOLOCK) on i.Grd_ID = GM.Grd_ID    
		      left outer JOIN T0040_Vertical_Segment VS WITH (NOLOCK) On vs.Vertical_ID = i.Vertical_ID  
		      left outer JOIN T0050_SubVertical SV WITH (NOLOCK) On sv.SubVertical_ID = i.SubVertical_ID 
		   Where Late_sec < @inSeconds AND (Late_sec > 0 OR early_sec > 0) and Early_hour = '0'
		   ORDER BY   
		   CASE WHEN @Order_By='Enroll_No' THEN RIGHT(REPLICATE('0',21) + CAST(EM.Enroll_No AS VARCHAR), 21)  
		   WHEN @Order_By='Name' THEN EM.Emp_Full_Name  
		   When @order_by = 'Designation' then (CASE WHEN DSM.Desig_dis_No  = 0 THEN DSM.Desig_Name ELSE RIGHT(REPLICATE('0',21) + CAST(DSM.Desig_dis_No AS VARCHAR), 21)  END)     
		   End  
		   ,Case When IsNumeric(Replace(Replace(EM.Alpha_Emp_Code,'="',''),'"','')) = 1 then Right(Replicate('0',21) + Replace(Replace(EM.Alpha_Emp_Code,'="',''),'"',''), 20)  
		   When IsNumeric(Replace(Replace(EM.Alpha_Emp_Code,'="',''),'"','')) = 0 then Left(Replace(Replace(EM.Alpha_Emp_Code,'="',''),'"','') + Replicate('',21), 20)  
		   Else Replace(Replace(em.Alpha_Emp_Code,'="',''),'"','') End  
		   ,el.For_Date  

		   --select * from #TMPDATA
		   --select * from #TMPDATA
		   --select @Wloop
		   --select (@Wloop + 1)
		   --RETURN
		   
		   SELECT @ValCount = Count(EMP_ID) FROM #TMPDATA
		   
		   while @Wloop < @ValCount
		   begin
				
				if @Wloop > 0 
				begin 
					
					Select @rownum = RowNum, @durationtotal = TOTAL_DURATION
					From (SELECT ROW_NUMBER() OVER(ORDER BY Emp_id) AS RowNum,TOTAL_DURATION
					From #TMPDATA) as sub
					Where sub.RowNum = (@Wloop)


					Select @intime = IN_TIME, @frdate = FOR_DATE,@lthour = Cast(Replace(Late_Hour,':','.') as numeric(18,2))
					From (SELECT ROW_NUMBER() OVER(ORDER BY Emp_id) AS RowNum,IN_TIME,FOR_DATE,LATE_HOUR
					From #TMPDATA) as sub
					Where sub.RowNum = (@Wloop + 1)
					
					if @durationtotal > @lthour
					begin 
						
							Update #TMPDATA set TOTAL_DURATION = Cast(@durationtotal as  numeric(18,2)) - Cast(Replace(Late_Hour,':','.') as numeric(18,2))
							where IN_TIME = @intime and FOR_DATE = @frdate 

					end
					else
					begin
							--SELECT * FROM #TMPDATA
							INSERT INTO #TMPABS
							SELECT Distinct LATE_HOUR,IN_TIME,FOR_DATE 
							From (SELECT ROW_NUMBER() OVER(ORDER BY Emp_id) AS RowNum,LATE_HOUR,IN_TIME,FOR_DATE
							From #TMPDATA) as sub
							Where sub.RowNum > @Wloop
							order by  LATE_HOUR asc

							Select @lthourtemp = Cast(Replace(Late_Hour,':','.') as numeric(18,2)), @Intimetemp = IN_TIME, @frdatetemp = FOR_DATE From #TMPABS 
							--Select * From #TMPABS Order by LATE_HOUR Asc
							--select @lthourtemp , @Intimetemp , @frdatetemp 


							Update #TMPDATA set TOTAL_DURATION = Cast(@durationtotal as  numeric(18,2)) - Cast(Replace(@lthourtemp,':','.') as numeric(18,2))
							where IN_TIME = @Intimetemp and FOR_DATE = @frdatetemp
							
					end
				end
				set @Wloop = @Wloop + 1
		   end
		   --SELECT * FROM #TMPDATA
		   --return
		   --Select DISTINCT * From #TMPABS
		   --RETURN
			select      
		      el.Emp_ID    ,    
		      el.Cmp_ID    ,    
		      el.Increment_ID ,    
		      convert(varchar(10),el.For_Date ,103) as For_Date,  
		      el.In_Time    ,    
		      --el.Shift_Time   ,   
		      dateadd(s,el.Late_Limit_Sec*-1 ,el.SHIFT_TIME) as Shift_Time ,  
		      el.Late_Sec  ,    
		      el.Late_Limit_Sec  ,    
		      el.Late_Hour ,   
		      el.Branch_Id ,  
		      el.Late_Limit ,  
		      el.Out_Time        
		     --,el.Shift_End_Time   
		   ,@From_Date as From_date,@To_Date as To_date,Emp_full_name,  
		   emp_code,alpha_Emp_code,Emp_First_Name,branch_name,comp_name,  
		   branch_address,cmp_name,cmp_address,  
		   dbo.F_Return_Hours(isnull(el.Late_Limit_Sec,0)) as Late_Limit_Hour ,   
		   CASE WHEN dbo.F_Return_Hours(dbo.Pro_Rounding_Sec_HH_MM(el.Late_Sec,@RoundingValue))='00:00' THEN '-' ELSE dbo.F_Return_Hours(dbo.Pro_Rounding_Sec_HH_MM(el.Late_Sec,@RoundingValue)) end as Late_Hour_Rounding  
		   --,dbo.F_Return_HHMM (el.SHIFT_TIME) as SHIFTTIME  
		   ,dbo.F_Return_HHMM (dateadd(s,el.Late_Limit_Sec*-1 ,el.SHIFT_TIME))  as SHIFTTIME  
		      ,dbo.F_Return_HHMM (el.IN_TIME) as INTIME        
		      ,convert(varchar(10),el.for_date,103) As For_Date_A  
		        
		      --,dateadd(s,el.Early_Limit_Sec ,el.SHIFT_end_time) as Shift_End_Time   
		      --,el.SHIFT_end_time as Shift_End_Time   
		      --,el.Shift_max_Ed_Time as Shift_End_Time   
		      ----,el.SHIFT_end_time as Shift_End_Time ''Changed by Rohit 26052015  
			  ,dbo.F_Return_HHMM (dateadd(s,el.Early_Limit_Sec,el.SHIFT_end_time) )  as SHIFTENDTIME --Added by ronakk 16092022
		     ,dateadd(s,el.Early_Limit_Sec,el.SHIFT_end_time) as Shift_End_Time   
		      --''Changed by Rohit 26052015  
		      ,el.Early_Sec   
		     ,el.Early_Limit_Sec  
		     ,el.Early_Hour   
		     ,el.Early_Limit   
		     ,dbo.F_Return_Hours(isnull(el.Early_Limit_Sec,0)) as Early_Limit_Hour    
		     ,CASE WHEN dbo.F_Return_Hours(dbo.Pro_Rounding_Sec_HH_MM(el.Early_Sec ,@RoundingValue_Early))='00:00' THEN '-' ELSE dbo.F_Return_Hours(dbo.Pro_Rounding_Sec_HH_MM(el.Early_Sec ,@RoundingValue_Early)) END as Early_Hour_Rounding  
		     ,dbo.F_Return_HHMM (el.out_TIME) as OutTIME  
		     ,el.For_Date as Ord_For_Date  
		     ,dsm.Desig_Name,dm.Dept_Name,tm.Type_Name,GM.Grd_Name          --added jimit 18062015  
		   ,Dm.Dept_Dis_no      --added jimit 03092015   
		   ,el.shift_Id  --added jimit 28102015  
		   ,DSM.Desig_Dis_No -- added by nilesh patel on 01042016  
		   ,vs.Vertical_Name,sv.SubVertical_Name --added jimit 28042016  
		   --,
		   --(  CAST(@Monthly_Exemption_Limit AS TIME) - CAST(Late_Hour as time)) as DurationTotal
		   --Cast(@Monthly_Exemption_Limit as  numeric(18,2)) - Cast(Replace(Late_Hour,':','.') as numeric(18,2)) as DurationTotal
		   ,TOTAL_DURATION
		   from #Emp_Late el inner join T0095_Increment i WITH (NOLOCK) on el.increment_ID=i.Increment_ID    
		   inner join T0080_EMP_MASTER em WITH (NOLOCK) on  el.emp_id = em.emp_id    
		   inner join T0030_BRANCH_MASTER bm WITH (NOLOCK) on em.branch_id=bm.branch_id    
		   inner join t0010_company_master cm WITH (NOLOCK) on em.cmp_id = cm.cmp_id  
		   left join t0040_designation_master DSM WITH (NOLOCK) on i.Desig_id = DSM.Desig_id    --added jimit 18062015  
		      left join T0040_department_master DM WITH (NOLOCK) on i.Dept_id = DM.Dept_id           --added jimit 18062015  
		      left join T0040_TYPE_MASTER TM WITH (NOLOCK) on i.Type_ID = TM.Type_ID      --added jimit 18062015  
		      left join T0040_GRADE_MASTER GM WITH (NOLOCK) on i.Grd_ID = GM.Grd_ID    --added jimit 18062015   
		      left outer JOIN T0040_Vertical_Segment VS WITH (NOLOCK) On vs.Vertical_ID = i.Vertical_ID  --added jimit 28042016  
		      left outer JOIN T0050_SubVertical SV WITH (NOLOCK) On sv.SubVertical_ID = i.SubVertical_ID --added jimit 28042016   
			  left outer join #TMPDATA TDA on TDA.EMP_ID = el.Emp_ID  and TDA.INC_ID = EL.Increment_ID and el.IN_TIME = TDA.IN_TIME and TDA.OUT_TIME = El.Out_Time
		   Where --Late_sec > 0  OR early_sec > 0  AND
		   Late_sec < @inSeconds AND (Late_sec > 0 OR early_sec > 0)  AND TOTAL_DURATION is null	or TOTAL_DURATION < 0 
		   --order by el.emp_id,For_Date    
		   ORDER BY   
		      CASE WHEN @Order_By='Enroll_No' THEN RIGHT(REPLICATE('0',21) + CAST(EM.Enroll_No AS VARCHAR), 21)  --Added by Jaina 31 July 2015 start  
		       WHEN @Order_By='Name' THEN EM.Emp_Full_Name  
		       When @order_by = 'Designation' then (CASE WHEN DSM.Desig_dis_No  = 0 THEN DSM.Desig_Name ELSE RIGHT(REPLICATE('0',21) + CAST(DSM.Desig_dis_No AS VARCHAR), 21)  END)     
		       --ELSE RIGHT(REPLICATE(N' ', 500) + EM.ALPHA_EMP_CODE, 500)   
		      End  
		      ,Case When IsNumeric(Replace(Replace(EM.Alpha_Emp_Code,'="',''),'"','')) = 1 then Right(Replicate('0',21) + Replace(Replace(EM.Alpha_Emp_Code,'="',''),'"',''), 20)  
		         When IsNumeric(Replace(Replace(EM.Alpha_Emp_Code,'="',''),'"','')) = 0 then Left(Replace(Replace(EM.Alpha_Emp_Code,'="',''),'"','') + Replicate('',21), 20)  
		         Else Replace(Replace(em.Alpha_Emp_Code,'="',''),'"','') End  
		      ,el.For_Date  
		      --RIGHT(REPLICATE(N' ', 500) + EM.ALPHA_EMP_CODE, 500),Ord_For_Date    

			  DROP TABLE #TMPDATA
			  DROP TABLE #TMPABS
	END
	ELSE
	BEGIN
			
			select      
      el.Emp_ID    ,    
      el.Cmp_ID    ,    
      el.Increment_ID ,    
      convert(varchar(10),el.For_Date ,103) as For_Date,  
      el.In_Time    ,    
      --el.Shift_Time   ,   
      dateadd(s,el.Late_Limit_Sec*-1 ,el.SHIFT_TIME) as Shift_Time ,  
      el.Late_Sec  ,    
      el.Late_Limit_Sec  ,    
      el.Late_Hour ,   
      el.Branch_Id ,  
      el.Late_Limit ,  
      el.Out_Time        
     --,el.Shift_End_Time   
   ,@From_Date as From_date,@To_Date as To_date,Emp_full_name,  
   emp_code,alpha_Emp_code,Emp_First_Name,branch_name,comp_name,  
   branch_address,cmp_name,cmp_address,  
   dbo.F_Return_Hours(isnull(el.Late_Limit_Sec,0)) as Late_Limit_Hour ,   
   CASE WHEN dbo.F_Return_Hours(dbo.Pro_Rounding_Sec_HH_MM(el.Late_Sec,@RoundingValue))='00:00' THEN '-' ELSE dbo.F_Return_Hours(dbo.Pro_Rounding_Sec_HH_MM(el.Late_Sec,@RoundingValue)) end as Late_Hour_Rounding  
   --,dbo.F_Return_HHMM (el.SHIFT_TIME) as SHIFTTIME  
   ,dbo.F_Return_HHMM (dateadd(s,el.Late_Limit_Sec*-1 ,el.SHIFT_TIME))  as SHIFTTIME  
      ,dbo.F_Return_HHMM (el.IN_TIME) as INTIME        
      ,convert(varchar(10),for_date,103) As For_Date_A  
        
      --,dateadd(s,el.Early_Limit_Sec ,el.SHIFT_end_time) as Shift_End_Time   
      --,el.SHIFT_end_time as Shift_End_Time   
      --,el.Shift_max_Ed_Time as Shift_End_Time   
      ----,el.SHIFT_end_time as Shift_End_Time ''Changed by Rohit 26052015  
	  ,dbo.F_Return_HHMM (dateadd(s,el.Early_Limit_Sec,el.SHIFT_end_time) )  as SHIFTENDTIME --Added by ronakk 16092022
     ,dateadd(s,el.Early_Limit_Sec,el.SHIFT_end_time) as Shift_End_Time   
      --''Changed by Rohit 26052015  
      ,el.Early_Sec   
     ,el.Early_Limit_Sec  
     ,el.Early_Hour   
     ,el.Early_Limit   
     ,dbo.F_Return_Hours(isnull(el.Early_Limit_Sec,0)) as Early_Limit_Hour    
     ,CASE WHEN dbo.F_Return_Hours(dbo.Pro_Rounding_Sec_HH_MM(el.Early_Sec ,@RoundingValue_Early))='00:00' THEN '-' ELSE dbo.F_Return_Hours(dbo.Pro_Rounding_Sec_HH_MM(el.Early_Sec ,@RoundingValue_Early)) END as Early_Hour_Rounding  
     ,dbo.F_Return_HHMM (el.out_TIME) as OutTIME  
     ,el.For_Date as Ord_For_Date  
     ,dsm.Desig_Name,dm.Dept_Name,tm.Type_Name,GM.Grd_Name          --added jimit 18062015  
   ,Dm.Dept_Dis_no      --added jimit 03092015   
   ,el.shift_Id  --added jimit 28102015  
   ,DSM.Desig_Dis_No -- added by nilesh patel on 01042016  
   ,vs.Vertical_Name,sv.SubVertical_Name --added jimit 28042016  
   from #Emp_Late el inner join T0095_Increment i WITH (NOLOCK) on el.increment_ID=i.Increment_ID    
   inner join T0080_EMP_MASTER em WITH (NOLOCK) on  el.emp_id = em.emp_id    
   inner join T0030_BRANCH_MASTER bm WITH (NOLOCK) on em.branch_id=bm.branch_id    
   inner join t0010_company_master cm WITH (NOLOCK) on em.cmp_id = cm.cmp_id  
   left join t0040_designation_master DSM WITH (NOLOCK) on i.Desig_id = DSM.Desig_id    --added jimit 18062015  
      left join T0040_department_master DM WITH (NOLOCK) on i.Dept_id = DM.Dept_id           --added jimit 18062015  
      left join T0040_TYPE_MASTER TM WITH (NOLOCK) on i.Type_ID = TM.Type_ID      --added jimit 18062015  
      left join T0040_GRADE_MASTER GM WITH (NOLOCK) on i.Grd_ID = GM.Grd_ID    --added jimit 18062015   
      left outer JOIN T0040_Vertical_Segment VS WITH (NOLOCK) On vs.Vertical_ID = i.Vertical_ID  --added jimit 28042016  
      left outer JOIN T0050_SubVertical SV WITH (NOLOCK) On sv.SubVertical_ID = i.SubVertical_ID --added jimit 28042016   
   Where Late_sec > 0  OR early_sec > 0  
   --order by el.emp_id,For_Date    
   ORDER BY   
      CASE WHEN @Order_By='Enroll_No' THEN RIGHT(REPLICATE('0',21) + CAST(EM.Enroll_No AS VARCHAR), 21)  --Added by Jaina 31 July 2015 start  
       WHEN @Order_By='Name' THEN EM.Emp_Full_Name  
       When @order_by = 'Designation' then (CASE WHEN DSM.Desig_dis_No  = 0 THEN DSM.Desig_Name ELSE RIGHT(REPLICATE('0',21) + CAST(DSM.Desig_dis_No AS VARCHAR), 21)  END)     
       --ELSE RIGHT(REPLICATE(N' ', 500) + EM.ALPHA_EMP_CODE, 500)   
      End  
      ,Case When IsNumeric(Replace(Replace(EM.Alpha_Emp_Code,'="',''),'"','')) = 1 then Right(Replicate('0',21) + Replace(Replace(EM.Alpha_Emp_Code,'="',''),'"',''), 20)  
         When IsNumeric(Replace(Replace(EM.Alpha_Emp_Code,'="',''),'"','')) = 0 then Left(Replace(Replace(EM.Alpha_Emp_Code,'="',''),'"','') + Replicate('',21), 20)  
         Else Replace(Replace(em.Alpha_Emp_Code,'="',''),'"','') End  
      ,el.For_Date  
      --RIGHT(REPLICATE(N' ', 500) + EM.ALPHA_EMP_CODE, 500),Ord_For_Date    


	END
   
     
    end     
      
   
     
 RETURN
