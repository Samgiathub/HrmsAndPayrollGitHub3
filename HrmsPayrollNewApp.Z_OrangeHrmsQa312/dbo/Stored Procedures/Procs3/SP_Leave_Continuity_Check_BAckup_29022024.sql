  
-- DETAILS FOR CREATING A STORED PROCEDURE  
-- AUTHOR = MR.MEHUL  
-- SP USE = CALCULATING LEAVE CONTINUITY LOGIC (ISSUE RAISED BY AMIT FOR CLIENT JSLPS)  
-- DATE = 27-MAR-2023  
  
  
CREATE PROCEDURE [dbo].[SP_Leave_Continuity_Check_BAckup_29022024]  
@Cmp_ID numeric(18,0),  
@Leave_ID numeric(18,0),  
@Emp_ID numeric(18,0),  
@App_Date DATETIME,  
@From_Date DATETIME,  
@Period numeric(18,0),  
@Rpt_Level numeric  
  
AS  
Begin  
  
SET NOCOUNT ON;  
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
  
CREATE TABLE #TMP(  
 CMP_ID NUMERIC,  
 APP_EMP_ID NUMERIC,  
 LEAVE_DAYS NUMERIC,  
 RPT_LEVEL NUMERIC  
)  
  
  
CREATE TABLE #TMP_DAYS(  
 CMP_ID NUMERIC,  
 APP_EMP_ID NUMERIC,  
 LEAVE_DAYS NUMERIC,  
 RPT_LEVEL NUMERIC  
)  
  
CREATE TABLE #TMP_PERIOD(  
 LEAVE_DAYS_FINAL NUMERIC,  
)  
  
  
DECLARE @SETTINGVAL AS NUMERIC = 0  
,@To_Date as Datetime  
,@DAYBEFORE AS DATETIME  
,@DAYAFTER AS DATETIME  
,@TOTAL_PERIOD AS NUMERIC  
,@SCHEME_ID AS NUMERIC  
,@MAXDAYS AS NUMERIC  
,@SCHEMEID AS NUMERIC  
,@FLAG AS VARCHAR(10) = ''  
,@COUNT AS NUMERIC = 0   
,@IVAL AS NUMERIC = 1   
,@ADDITIONAL_DAYS AS NUMERIC = 0  
,@C_VAL NUMERIC = 0  
,@CONSTRAINT VARCHAR(250) = ''  
,@Sett_WeekOff Numeric = 0  
,@Sett_Holiday Numeric = 0  
,@Employee_Cons VARCHAR(250) = ''  
,@StartDate  DATETIME  
,@EndDate    DATETIME  
,@StartDate1  DATETIME  
,@EndDate1    DATETIME 
,@CountforWeekHoli Numeric = 0  
  
 SELECT @SETTINGVAL = ISNULL(Leave_Continuity,0) FROM T0040_LEAVE_MASTER WHERE Cmp_ID = @Cmp_ID AND Leave_ID = @Leave_ID  
 SELECT @Sett_WeekOff = ISNULL(Weekoff_as_leave,0) FROM T0040_LEAVE_MASTER WHERE Cmp_ID = @Cmp_ID AND Leave_ID = @Leave_ID  
 SELECT @Sett_Holiday = ISNULL(Holiday_as_leave,0) FROM T0040_LEAVE_MASTER WHERE Cmp_ID = @Cmp_ID AND Leave_ID = @Leave_ID  
  
 
  
 IF @SETTINGVAL = 1  
 BEGIN   
     -- Code update by Yogesh on 29022024---------START---------------------------------------------------
	SELECT Distinct @SCHEMEID = ES.Scheme_ID from T0095_EMP_SCHEME ES WITH (NOLOCK) 
	inner join T0050_Scheme_Detail SD WITH (NOLOCK)  on es.Scheme_ID=sd.Scheme_Id where Type = 'Leave'  and es.Cmp_Id =  @Cmp_ID and es.emp_Id =@Emp_ID and es.Effective_Date <= @From_Date    and sd.Leave = Cast(@Leave_ID as varchar)
  -- Code update by Yogesh on 29022024---------END---------------------------------------------------
  set @MAXDAYS=(select Leave_days from T0050_Scheme_Detail where rpt_level= (select Max(Rpt_Level)from T0050_Scheme_Detail where Scheme_Id=@SCHEMEID)and Scheme_Id=@SCHEMEID)
  --select @MAXDAYS
   SET @TOTAL_PERIOD = @Period  
   --SET @TOTAL_PERIOD = 0  
   SET @DAYBEFORE = DATEADD(day, -@MAXDAYS, @From_Date)  
   SET @DAYAFTER = DATEADD(day, @MAXDAYS, @From_Date)  
   SET @To_Date = DATEADD(day, @Period, @From_Date)  
  
     
     
  
   if @Period < 28  
   begin  
   
         SET @StartDate1 = DATEADD(mm, DATEDIFF(m,0,@From_Date),0)  
     SET @EndDate1 = DATEADD(DD,-(DAY(GETDATE())), DATEADD(MM, 0, @From_Date))
	 
     SET @StartDate = DATEADD(mm, DATEDIFF(m,0,@From_Date),@MAXDAYS)  
     SET @EndDate = DATEADD(DD,-(DAY(GETDATE())), DATEADD(MM, 1, @From_Date))  
       
   end  
   else  
   begin   
       
     SET @StartDate = @From_Date  
     SET @EndDate = DATEADD(day, @Period, @From_Date)  
   end  
  
    IF OBJECT_ID('tempdb..#Emp_WeekOff') IS NULL  
    BEGIN  
       
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
      
      CREATE TABLE #EMP_HOLIDAY(EMP_ID NUMERIC, FOR_DATE DATETIME, IS_CANCEL BIT, Is_Half tinyint, Is_P_Comp tinyint, H_DAY numeric(4,1));  
      CREATE UNIQUE CLUSTERED INDEX IX_EMP_HOLIDAY_EMPID_FORDATE ON #EMP_HOLIDAY(EMP_ID, FOR_DATE);  
      
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
        
      SET @Employee_Cons = CAST(@Emp_ID AS varchar) + '#'  
  
  --select @Employee_Cons,@Cmp_ID,@StartDate,@EndDate
      EXEC SP_GET_HW_ALL @CONSTRAINT=@Employee_Cons,@CMP_ID=@Cmp_ID, @FROM_DATE=@StartDate, @TO_DATE=@EndDate, @All_Weekoff = 0, @Exec_Mode=0  
  
    END  
   
      
   if @Sett_WeekOff = 1  
   begin  
        --THIS LOGIC WAS ADDED TO CHECK BACK-DATED LEAVE APPLICATION   
      IF EXISTS(SELECT Leave_Period FROM T0110_LEAVE_APPLICATION_DETAIL  LAD inner join T0100_LEAVE_APPLICATION LA on La.Leave_Application_ID = lad.Leave_Application_ID   
      WHERE LAd.Cmp_ID = @Cmp_ID  AND From_Date = @DAYBEFORE and Emp_ID = @Emp_ID  
      )  --AND Leave_ID = @Leave_ID  
      BEGIN   
          
        SET @TOTAL_PERIOD = @TOTAL_PERIOD + (SELECT Leave_Period FROM T0110_LEAVE_APPLICATION_DETAIL Lad inner join T0100_LEAVE_APPLICATION LA on La.Leave_Application_ID = lad.Leave_Application_ID   
        WHERE lad.Cmp_ID = @Cmp_ID  AND From_Date = @DAYBEFORE and Emp_ID = @Emp_ID) --AND Leave_ID = @Leave_ID  
          
        SET @FLAG = 'BD'  
      END  
        
      --THIS LOGIC WAS ADDED TO CHECK FUTURE-DATE LEAVE APPLICATION   
      IF EXISTS(SELECT Leave_Period FROM T0110_LEAVE_APPLICATION_DETAIL LAD inner join T0100_LEAVE_APPLICATION LA on La.Leave_Application_ID = lad.Leave_Application_ID   
      WHERE lad.Cmp_ID = @Cmp_ID  AND From_Date = @DAYAFTER and Emp_ID = @Emp_ID) --AND Leave_ID = @Leave_ID  
      BEGIN   
        
        SET @TOTAL_PERIOD = @TOTAL_PERIOD + (SELECT Leave_Period FROM T0110_LEAVE_APPLICATION_DETAIL LAD inner join T0100_LEAVE_APPLICATION LA on La.Leave_Application_ID = lad.Leave_Application_ID   
        WHERE lad.Cmp_ID = @Cmp_ID  AND From_Date = @DAYAFTER and Emp_ID = @Emp_ID) --AND Leave_ID = @Leave_ID  
          
        IF @FLAG <> ''  
        BEGIN  
         SET @FLAG = 'BDFD'   
        END  
        ELSE  
        BEGIN   
         SET @FLAG = 'FD'   
        END  
      END  
      SET @FLAG = 'WEEKOFF'  
   end  
   else  
   begin  
        
        
      if exists (Select 1 from #Emp_WeekOff where For_Date between @DAYBEFORE and @From_Date)  
      begin  
	  
        Set @CountforWeekHoli = @CountforWeekHoli + (Select Count(1) from #Emp_WeekOff where For_Date between @DAYBEFORE and @From_Date)  
        SET @FLAG = 'BYPASS'  
      end  
  
      if exists (Select 1 from #Emp_WeekOff where For_Date between @DAYAFTER and @From_Date)  
      begin  
	  
        Set @CountforWeekHoli = @CountforWeekHoli + (Select Count(1) from #Emp_WeekOff where For_Date between @DAYAFTER and @From_Date)  
        SET @FLAG = 'BYPASS'  
      end  
  
   end  
  
     
   if @Sett_Holiday = 1  
   begin  
         --THIS LOGIC WAS ADDED TO CHECK BACK-DATED LEAVE APPLICATION   
      IF EXISTS(SELECT Leave_Period FROM T0110_LEAVE_APPLICATION_DETAIL LAD inner join T0100_LEAVE_APPLICATION LA on La.Leave_Application_ID = lad.Leave_Application_ID   
      WHERE lad.Cmp_ID = @Cmp_ID  AND From_Date = @DAYBEFORE and Emp_ID = @Emp_ID) --AND Leave_ID = @Leave_ID  
      BEGIN   
        SET @TOTAL_PERIOD = @TOTAL_PERIOD + (SELECT Leave_Period FROM T0110_LEAVE_APPLICATION_DETAIL LAD inner join T0100_LEAVE_APPLICATION LA on La.Leave_Application_ID = lad.Leave_Application_ID   
        WHERE lad.Cmp_ID = @Cmp_ID  AND From_Date = @DAYBEFORE and Emp_ID = @Emp_ID) --AND Leave_ID = @Leave_ID  
        SET @FLAG = 'BD'  
      END  
        
      --THIS LOGIC WAS ADDED TO CHECK FUTURE-DATE LEAVE APPLICATION   
      IF EXISTS(SELECT Leave_Period FROM T0110_LEAVE_APPLICATION_DETAIL LAD inner join T0100_LEAVE_APPLICATION LA on La.Leave_Application_ID = lad.Leave_Application_ID   
      WHERE lad.Cmp_ID = @Cmp_ID  AND From_Date = @DAYAFTER and Emp_ID = @Emp_ID) --AND Leave_ID = @Leave_ID  
      BEGIN   
        SET @TOTAL_PERIOD = @TOTAL_PERIOD + (SELECT Leave_Period FROM T0110_LEAVE_APPLICATION_DETAIL LAD inner join T0100_LEAVE_APPLICATION LA on La.Leave_Application_ID = lad.Leave_Application_ID  
        WHERE lad.Cmp_ID = @Cmp_ID  AND From_Date = @DAYAFTER and Emp_ID = @Emp_ID) --AND Leave_ID = @Leave_ID  
          
        IF @FLAG <> ''  
        BEGIN  
         SET @FLAG = 'BDFD'   
        END  
        ELSE  
        BEGIN   
         SET @FLAG = 'FD'   
        END  
      END  
      SET @FLAG = 'HOLIDAY'  
   end  
   else  
   begin  
        
        
      if exists (Select 1 from #EMP_HOLIDAY where For_Date between @DAYBEFORE and @From_Date)  
      begin  
        Set @CountforWeekHoli = @CountforWeekHoli + (Select Count(1) from #EMP_HOLIDAY where For_Date between @DAYBEFORE and @From_Date)  
        SET @FLAG = 'BYPASS'  
      end  
  
      if exists (Select 1 from #EMP_HOLIDAY where For_Date between @DAYAFTER and @From_Date)  
      begin   
        Set @CountforWeekHoli = @CountforWeekHoli + (Select Count(1) from #EMP_HOLIDAY where For_Date between @DAYAFTER and @From_Date)  
        SET @FLAG = 'BYPASS'  
      end  
  
   end  
     
  
     
   IF @FLAG <> 'BYPASS'  
   BEGIN  
      
    IF @FLAG <> 'WEEKOFF' OR @FLAG <> 'HOLIDAY'  
    BEGIN  
  
     
  
  
       --THIS LOGIC WAS ADDED TO CHECK BACK-DATED LEAVE APPLICATION   
      IF EXISTS(SELECT sum(Leave_Period) as Leave_Period FROM T0110_LEAVE_APPLICATION_DETAIL  LAD inner join T0100_LEAVE_APPLICATION LA on La.Leave_Application_ID = lad.Leave_Application_ID   
      WHERE lad.Cmp_ID = @Cmp_ID  AND From_Date between @DAYBEFORE and @From_Date and Emp_ID = @Emp_ID) --AND Leave_ID = @Leave_ID  
      BEGIN   
	  
        SET @TOTAL_PERIOD = @TOTAL_PERIOD + (SELECT sum(Leave_Period) as Leave_Period FROM T0110_LEAVE_APPLICATION_DETAIL  LAD inner join T0100_LEAVE_APPLICATION LA on La.Leave_Application_ID = lad.Leave_Application_ID   
        WHERE lad.Cmp_ID = @Cmp_ID  AND From_Date  between @DAYBEFORE and @From_Date and Emp_ID = @Emp_ID)  
        SET @FLAG = 'BD'  
		--select @TOTAL_PERIOD
      END  
		        
      --THIS LOGIC WAS ADDED TO CHECK FUTURE-DATE LEAVE APPLICATION   
      IF EXISTS(SELECT sum(Leave_Period) as Leave_Period FROM T0110_LEAVE_APPLICATION_DETAIL LAD inner join T0100_LEAVE_APPLICATION LA on La.Leave_Application_ID = lad.Leave_Application_ID   
      WHERE lad.Cmp_ID = @Cmp_ID  AND From_Date between  @From_Date and @DAYAFTER and Emp_ID = @Emp_ID) --AND Leave_ID = @Leave_ID  
      BEGIN  
	  --select @DAYAFTER
        SET @TOTAL_PERIOD = @TOTAL_PERIOD + (SELECT sum(Leave_Period) as Leave_Period FROM T0110_LEAVE_APPLICATION_DETAIL LAD inner join T0100_LEAVE_APPLICATION LA on La.Leave_Application_ID = lad.Leave_Application_ID   
        WHERE lad.Cmp_ID = @Cmp_ID  AND From_Date  between   @From_Date and @DAYAFTER and Emp_ID = @Emp_ID) --AND Leave_ID = @Leave_ID  
          
        IF @FLAG <> ''  
        BEGIN  
		
         SET @FLAG = 'BDFD'   
        END  
        ELSE  
        BEGIN   
		
         SET @FLAG = 'FD'   
        END  
      END  
        
  
  
    END  
   
   END  
  
   ELSE  
   BEGIN  
  
     declare @var_count as numeric = 0,@datechkback as datetime, @datechkfrwd as datetime,@datechkback1 as datetime, @datechkfrwd1 as datetime  
  
     Set @var_count = @CountforWeekHoli  
     Set @datechkback = DATEADD(day, -(@CountforWeekHoli), @From_Date)  
     Set @datechkfrwd = DATEADD(day, @CountforWeekHoli, @From_Date)  
       
  
      --select @datechkback,@datechkfrwd
     --Checking backdated Leave Application   
     if exists(SELECT Leave_Period FROM T0110_LEAVE_APPLICATION_DETAIL  LAD inner join T0100_LEAVE_APPLICATION LA   
     on La.Leave_Application_ID = lad.Leave_Application_ID   
     WHERE lad.Cmp_ID = @Cmp_ID  AND From_Date = @datechkback and Emp_ID = @Emp_ID)  
     begin  
	 
       set @TOTAL_PERIOD = @TOTAL_PERIOD + (SELECT Leave_Period FROM T0110_LEAVE_APPLICATION_DETAIL  LAD inner join T0100_LEAVE_APPLICATION LA on La.Leave_Application_ID = lad.Leave_Application_ID WHERE lad.Cmp_ID = @Cmp_ID  AND From_Date = @datechkback and Emp_ID = @Emp_ID)       end  
  
     --Checking future dated leave application   
     if exists(SELECT Leave_Period FROM T0110_LEAVE_APPLICATION_DETAIL  LAD inner join T0100_LEAVE_APPLICATION LA   
     on La.Leave_Application_ID = lad.Leave_Application_ID   
     WHERE lad.Cmp_ID = @Cmp_ID  AND From_Date = @datechkfrwd and Emp_ID = @Emp_ID)  
     begin  
       set @TOTAL_PERIOD = @TOTAL_PERIOD + (SELECT Leave_Period FROM T0110_LEAVE_APPLICATION_DETAIL  LAD inner join T0100_LEAVE_APPLICATION LA on La.Leave_Application_ID = lad.Leave_Application_ID WHERE lad.Cmp_ID = @Cmp_ID  AND From_Date = @datechkfrwd and Emp_ID = @Emp_ID)       end  
  
       
     
   END  
     -- set  @TOTAL_PERIOD=@TOTAL_PERIOD-@Period
    --Set @Period = @Period + @TOTAL_PERIOD  
      --select @TOTAL_PERIOD
    Set @Period =  @TOTAL_PERIOD  
      
     
  
  
    --select @Period,@TOTAL_PERIOD  
      
    --SELECT @SCHEME_ID = Scheme_ID from T0095_EMP_SCHEME WITH (NOLOCK) where Type = 'Leave'  and Cmp_Id = @Cmp_ID and emp_Id = @Emp_ID and Effective_Date <= @From_Date   --Code commented by Yogesh on 29022024
	-- Code update by Yogesh on 29022024---------START---------------------------------------------------
	SELECT Distinct @SCHEME_ID = ES.Scheme_ID from T0095_EMP_SCHEME ES WITH (NOLOCK) 
	inner join T0050_Scheme_Detail SD WITH (NOLOCK)  on es.Scheme_ID=sd.Scheme_Id where Type = 'Leave'  and es.Cmp_Id =  @Cmp_ID and es.emp_Id =@Emp_ID and es.Effective_Date <= @From_Date    and sd.Leave = Cast(@Leave_ID as varchar)
  -- Code update by Yogesh on 29022024---------END---------------------------------------------------
  
  
  
     INSERT INTO #TMP  
     SELECT Cmp_Id,App_Emp_ID,Leave_Days,Rpt_Level FROM T0050_Scheme_Detail WHERE Cmp_Id = @Cmp_ID AND Scheme_Id = @SCHEME_ID   
  
     SELECT @COUNT =COUNT(APP_EMP_ID) FROM #TMP       
  
  
  -- select * FROM #TMP  
  
     WHILE (@IVAL <= @COUNT)  
     BEGIN  
  
      declare @var_val as numeric = 0  


  
      SELECT @ADDITIONAL_DAYS = LEAVE_DAYS FROM (  
      SELECT ROW_NUMBER() OVER (ORDER BY RPT_LEVEL ASC) AS rownumber,  
      ISNULL(LEAVE_DAYS,0) AS LEAVE_DAYS FROM #TMP) AS foo  
      WHERE rownumber = @IVAL  
  
  
  
        Set @var_val =  @ADDITIONAL_DAYS - @Period  
		
          
          INSERT INTO #TMP_DAYS  
          Select * from #TMP where LEAVE_DAYS = @ADDITIONAL_DAYS  
    
          if @ADDITIONAL_DAYS > @var_val and @var_val > 0 or @var_val = 0  
          begin  
            Break  
          end  
  
      SET @IVAL = @IVAL + 1  
  
     END  
       
     Select * from #TMP_DAYS where RPT_LEVEL = @Rpt_Level  
  
 END  
  
   
 DROP TABLE #TMP  
 DROP TABLE #TMP_DAYS  
End