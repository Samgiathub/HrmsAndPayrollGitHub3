CREATE PROCEDURE [dbo].[SP_Leave_Continuity_Check]            
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
,@Counter Numeric = 0            
,@Countt Numeric = 0            
,@Employee_Cons VARCHAR(250) = ''            
,@StartDate  DATETIME            
,@EndDate    DATETIME            
,@StartDate1  DATETIME            
,@EndDate1    DATETIME            
,@CountforWeekHoli Numeric = 0            
,@WEEKHOLI_FROM_DATE  DATETIME            
,@wEEKHOLI_TO_DATE   DATETIME     
            
 SELECT @SETTINGVAL = ISNULL(Leave_Continuity,0) FROM T0040_LEAVE_MASTER WHERE Cmp_ID = @Cmp_ID AND Leave_ID = @Leave_ID            
 SELECT @Sett_WeekOff = ISNULL(Weekoff_as_leave,0) FROM T0040_LEAVE_MASTER WHERE Cmp_ID = @Cmp_ID AND Leave_ID = @Leave_ID            
 SELECT @Sett_Holiday = ISNULL(Holiday_as_leave,0) FROM T0040_LEAVE_MASTER WHERE Cmp_ID = @Cmp_ID AND Leave_ID = @Leave_ID            
            
     -- Code update by Yogesh on 29022024---------START---------------------------------------------------          
 SELECT Distinct @SCHEMEID = ES.Scheme_ID from T0095_EMP_SCHEME ES WITH (NOLOCK)           
 inner join T0050_Scheme_Detail SD WITH (NOLOCK)  on es.Scheme_ID=sd.Scheme_Id where Type = 'Leave'  and es.Cmp_Id =  @Cmp_ID and es.emp_Id =@Emp_ID and es.Effective_Date <= @From_Date 
  and (select top 1 cast(data  as numeric) from dbo.split(sd.Leave,'#')) in (Cast(@Leave_ID as varchar) )
 --and sd.Leave = Cast(@Leave_ID as varchar)          
           
 set @MAXDAYS=(select Leave_days from T0050_Scheme_Detail where rpt_level= (select Max(Rpt_Level)from T0050_Scheme_Detail where Scheme_Id=@SCHEMEID)and Scheme_Id=@SCHEMEID)          
  -- Code update by Yogesh on 29022024---------END---------------------------------------------------          
           
        
 IF @SETTINGVAL = 1            
 BEGIN             
            
            
  --select @MAXDAYS          
   --SET @TOTAL_PERIOD = @Period            
   SET @TOTAL_PERIOD = 0            
   SET @DAYBEFORE = DATEADD(day, -@MAXDAYS, @From_Date)            
   SET @DAYAFTER = DATEADD(day, @MAXDAYS, @From_Date)            
   SET @To_Date = DATEADD(day, @Period, @From_Date)            
            
               
               
            
   if @Period < 28            
   begin            
             
          
  SET @StartDate1 = DATEADD(mm, DATEDIFF(m,0,@From_Date),0)          
 SET @EndDate1 = DATEADD(DD,-(DAY(GETDATE())), DATEADD(MM, 1, @From_Date))          
                 
     SET @StartDate = DATEADD(mm, DATEDIFF(m,0,@From_Date),@MAXDAYS)            
     SET @EndDate = DATEADD(DD,-(DAY(GETDATE())), DATEADD(MM, 1, @From_Date))            
                 
   end            
   else            
   begin             
     --select 1234     
   set @StartDate1=@EndDate1    
   SET @EndDate1  =DATEADD(day, @Period, @From_Date)            
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
            
 --select @Employee_Cons,@Cmp_ID,@StartDate1,@EndDate1          
      EXEC SP_GET_HW_ALL @CONSTRAINT=@Employee_Cons,@CMP_ID=@Cmp_ID, @FROM_DATE=@StartDate1, @TO_DATE=@EndDate1, @All_Weekoff = 0, @Exec_Mode=0            
  --select * from #Emp_WeekOff          
    END            
             
                
   if @Sett_WeekOff = 1            
   begin           
             
        --THIS LOGIC WAS ADDED TO CHECK BACK-DATED LEAVE APPLICATION             
      IF EXISTS(SELECT Leave_Period FROM T0110_LEAVE_APPLICATION_DETAIL  LAD inner join T0100_LEAVE_APPLICATION LA on La.Leave_Application_ID = lad.Leave_Application_ID             
      WHERE LAd.Cmp_ID = @Cmp_ID  AND From_Date = @DAYBEFORE and Emp_ID = @Emp_ID            
      )  --AND Leave_ID = @Leave_ID            
      BEGIN             
                    
		set @DAYBEFORE=@From_Date          
			set @Counter=1          
	 WHILE ( @Counter < @MAXDAYS)          
		BEGIN          
	 --select @Counter          
		   set @DAYBEFORE= DATEADD(dd, DATEDIFF(d,0,@From_Date),-@Counter)            
		   --select @DAYBEFORE          
		   set @Countt=0          
		   set @Countt=(SELECT Distinct 1 Leave_Period FROM T0110_LEAVE_APPLICATION_DETAIL  LAD inner join T0100_LEAVE_APPLICATION LA on La.Leave_Application_ID = lad.Leave_Application_ID            
		   inner join T0040_LEAVE_MASTER LM on lm.Leave_ID=lad.Leave_ID          
		   left join T0120_LEAVE_APPROVAL LAP on lap.Leave_Application_ID=la.Leave_Application_ID          
		   inner join T0150_LEAVE_CANCELLATION LC on LC.Leave_Approval_id=lap.Leave_Approval_ID          
				WHERE lad.Cmp_ID = @Cmp_ID  AND  @DAYBEFORE between From_Date and To_Date and la.Emp_ID = @Emp_ID and lm.Leave_Continuity=1 and LA.Application_Status !='R'
				and LAP.Leave_Approval_ID Not in (select Distinct Leave_Approval_id from T0150_LEAVE_CANCELLATION where cmp_id=@Cmp_ID and emp_id=@Emp_ID and For_date between @StartDate1 and @EndDate1))
            
		   if isnull(@Countt,0)!=0          
		   begin          
			set @TOTAL_PERIOD=@TOTAL_PERIOD+@Countt          
          
			set @Counter=@Counter+1          
			  end          
		   else          
		   begin          
             
		   BREAK           
		   end          
            
	END          
        --SET @TOTAL_PERIOD = @TOTAL_PERIOD + (SELECT Leave_Period FROM T0110_LEAVE_APPLICATION_DETAIL Lad inner join T0100_LEAVE_APPLICATION LA on La.Leave_Application_ID = lad.Leave_Application_ID             
        --WHERE lad.Cmp_ID = @Cmp_ID  AND From_Date = @DAYBEFORE and Emp_ID = @Emp_ID) --AND Leave_ID = @Leave_ID            
                    
		SET @FLAG = 'BD'            
      END            
                  
      --THIS LOGIC WAS ADDED TO CHECK FUTURE-DATE LEAVE APPLICATION             
      IF EXISTS(SELECT Leave_Period FROM T0110_LEAVE_APPLICATION_DETAIL LAD inner join T0100_LEAVE_APPLICATION LA on La.Leave_Application_ID = lad.Leave_Application_ID             
      WHERE lad.Cmp_ID = @Cmp_ID  AND From_Date = @DAYAFTER and Emp_ID = @Emp_ID) --AND Leave_ID = @Leave_ID            
      BEGIN             
        set @DAYAFTER=@From_Date          
		set @Counter=1          
             
			WHILE ( @Counter < @MAXDAYS)          
		BEGIN          
   --select @Counter          
            
   --select @DAYAFTER          
   set @Countt=0          
   set @Countt=(SELECT Distinct 1 Leave_Period FROM T0110_LEAVE_APPLICATION_DETAIL  LAD inner join T0100_LEAVE_APPLICATION LA on La.Leave_Application_ID = lad.Leave_Application_ID           
   inner join T0040_LEAVE_MASTER LM on lm.Leave_ID=lad.Leave_ID          
   left join T0120_LEAVE_APPROVAL LAP on lap.Leave_Application_ID=la.Leave_Application_ID          
inner join T0150_LEAVE_CANCELLATION LC on LC.Leave_Approval_id!=lap.Leave_Approval_ID          
        WHERE lad.Cmp_ID = @Cmp_ID  AND  @DAYAFTER between From_Date and To_Date and la.Emp_ID = @Emp_ID and lm.Leave_Continuity=1 and LA.Application_Status !='R'
		and LAP.Leave_Approval_ID Not in (select Distinct Leave_Approval_id from T0150_LEAVE_CANCELLATION where cmp_id=@Cmp_ID and emp_id=@Emp_ID and For_date between @StartDate1 and @EndDate1))
  end          
          
       -- SET @TOTAL_PERIOD = @TOTAL_PERIOD + (SELECT Leave_Period FROM T0110_LEAVE_APPLICATION_DETAIL LAD inner join T0100_LEAVE_APPLICATION LA on La.Leave_Application_ID = lad.Leave_Application_ID             
        --WHERE lad.Cmp_ID = @Cmp_ID  AND From_Date = @DAYAFTER and Emp_ID = @Emp_ID) --AND Leave_ID = @Leave_ID            
                    
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
--   else            
--   begin            
--               --select * from #Emp_WeekOff 
--     --=================================WEEK-OFF CALCULATION===============================================
                  
--      if exists (Select 1 from #Emp_WeekOff where For_Date between @DAYBEFORE and @From_Date)            
--      begin            
	  
--	 -- select @DAYBEFORE,@From_Date
--	 -- select * from T0110_LEAVE_APPLICATION_DETAIL
--	 -- --===================================================================================================================================================
--	 -- Select Count(1) from #Emp_WeekOff EW inner join  T0100_LEAVE_APPLICATION LA on La.Emp_ID=ew.emp_id 
--		--inner join T0110_LEAVE_APPLICATION_DETAIL LAD   on lad.Leave_Application_ID=la.Leave_Application_ID 
--		-- left join T0120_LEAVE_APPROVAL LAP on lap.Leave_Application_ID=la.Leave_Application_ID    
--		--where For_Date between @DAYBEFORE and @From_Date and ew.For_Date between lad.From_Date and To_Date  
--		--and LAP.Leave_Approval_ID Not in (select Distinct Leave_Approval_id from T0150_LEAVE_CANCELLATION where cmp_id=@Cmp_ID and emp_id=@Emp_ID and  For_date between @StartDate1 and @EndDate1)
--		--and LA.Application_Status !='R'
--	  --===================================================================================================================================================
----  Select Count(1) from #Emp_WeekOff EW inner join  T0100_LEAVE_APPLICATION LA on La.Emp_ID=ew.emp_id inner join T0110_LEAVE_APPLICATION_DETAIL LAD   on lad.Leave_Application_ID=la.Leave_Application_ID  where For_Date between @DAYBEFORE and @From_Date and ew.For_Date between lad.From_Date and To_Date
            
--        --Set @CountforWeekHoli = @CountforWeekHoli + (Select Count(1) from #Emp_WeekOff where For_Date between @DAYBEFORE and @From_Date)            
--		Set @CountforWeekHoli = @CountforWeekHoli + (Select Count(1) from #Emp_WeekOff EW inner join  T0100_LEAVE_APPLICATION LA on La.Emp_ID=ew.emp_id 
--		inner join T0110_LEAVE_APPLICATION_DETAIL LAD   on lad.Leave_Application_ID=la.Leave_Application_ID 
--		 left join T0120_LEAVE_APPROVAL LAP on lap.Leave_Application_ID=la.Leave_Application_ID    
--		where For_Date between @DAYBEFORE and @From_Date and ew.For_Date between lad.From_Date and To_Date  
--		and LAP.Leave_Approval_ID Not in (select Distinct Leave_Approval_id from T0150_LEAVE_CANCELLATION where cmp_id=@Cmp_ID and emp_id=@Emp_ID and  For_date between @StartDate1 and @EndDate1)
--		and LA.Application_Status !='R')            
	
--        SET @FLAG = 'BYPASS' 
		
--      end            
            
--      if exists (Select 1 from #Emp_WeekOff where For_Date between @From_Date and @DAYAFTER )            
--      begin        
	  
----	    Select Count(1) from #Emp_WeekOff EW inner join  T0100_LEAVE_APPLICATION LA on La.Emp_ID=ew.emp_id inner join T0110_LEAVE_APPLICATION_DETAIL LAD   on lad.Leave_Application_ID=la.Leave_Application_ID  where For_Date between @From_Date and @DAYAFTER and ew.For_Date between lad.From_Date and To_Date
--       -- Select * from #Emp_WeekOff where For_Date between  @From_Date and @DAYAFTER
	   
--	           Set @CountforWeekHoli = @CountforWeekHoli + (Select Count(1) from #Emp_WeekOff EW inner join  T0100_LEAVE_APPLICATION LA on La.Emp_ID=ew.emp_id 
--			   inner join T0110_LEAVE_APPLICATION_DETAIL LAD   on lad.Leave_Application_ID=la.Leave_Application_ID 
--			   left join T0120_LEAVE_APPROVAL LAP on lap.Leave_Application_ID=la.Leave_Application_ID    
--			   where For_Date between @From_Date and @DAYAFTER and ew.For_Date between lad.From_Date and To_Date 
--			   and LAP.Leave_Approval_ID Not in (select Distinct Leave_Approval_id from T0150_LEAVE_CANCELLATION where cmp_id=@Cmp_ID and emp_id=@Emp_ID and For_date between @StartDate1 and @EndDate1)
--			    and LA.Application_Status !='R')            
--        --Set @CountforWeekHoli = @CountforWeekHoli + (Select Count(1) from #Emp_WeekOff where For_Date between @From_Date and @DAYAFTER )            
--        SET @FLAG = 'BYPASS'
--		--select @DAYAFTER,@CountforWeekHoli
--      end 
--	 --=================================WEEK-OFF CALCULATION===============================================
            
--   end            
            
               
   if @Sett_Holiday = 1            
   begin           
             
         --THIS LOGIC WAS ADDED TO CHECK BACK-DATED LEAVE APPLICATION             
      IF EXISTS(SELECT Leave_Period FROM T0110_LEAVE_APPLICATION_DETAIL LAD inner join T0100_LEAVE_APPLICATION LA on La.Leave_Application_ID = lad.Leave_Application_ID             
      WHERE lad.Cmp_ID = @Cmp_ID  AND From_Date = @DAYBEFORE and Emp_ID = @Emp_ID) --AND Leave_ID = @Leave_ID            
      BEGIN           
             
	  set @DAYBEFORE=@From_Date          
      set @Counter=1          
   WHILE ( @Counter < @MAXDAYS)          
     BEGIN          
	 --select @Counter          
	   set @DAYBEFORE= DATEADD(dd, DATEDIFF(d,0,@From_Date),-@Counter)            
	   --select @DAYBEFORE          
	   set @Countt=0          
	   set @Countt=(SELECT Distinct 1 Leave_Period FROM T0110_LEAVE_APPLICATION_DETAIL  LAD inner join T0100_LEAVE_APPLICATION LA on La.Leave_Application_ID = lad.Leave_Application_ID            
	   inner join T0040_LEAVE_MASTER LM on lm.Leave_ID=lad.Leave_ID           
	   left join T0120_LEAVE_APPROVAL LAP on lap.Leave_Application_ID=la.Leave_Application_ID          
	   --inner join T0150_LEAVE_CANCELLATION LC on LC.Leave_Approval_id=lap.Leave_Approval_ID          
			WHERE lad.Cmp_ID = @Cmp_ID  AND  @DAYBEFORE between From_Date and To_Date and la.Emp_ID = @Emp_ID and lm.Leave_Continuity=1 and LA.Application_Status !='R'
			and LAP.Leave_Approval_ID Not in (select Distinct Leave_Approval_id from T0150_LEAVE_CANCELLATION where cmp_id=@Cmp_ID and emp_id=@Emp_ID and For_date between @StartDate1 and @EndDate1))
            
	   if isnull(@Countt,0)!=0          
	   begin          
		set @TOTAL_PERIOD=@TOTAL_PERIOD+@Countt          
          
		set @Counter=@Counter+1          
		  end          
	   else          
	   begin          
             
	   BREAK           
	   end          
            
 END          
          
        --SET @TOTAL_PERIOD = @TOTAL_PERIOD + (SELECT Leave_Period FROM T0110_LEAVE_APPLICATION_DETAIL LAD inner join T0100_LEAVE_APPLICATION LA on La.Leave_Application_ID = lad.Leave_Application_ID             
       -- WHERE lad.Cmp_ID = @Cmp_ID  AND From_Date = @DAYBEFORE and Emp_ID = @Emp_ID) --AND Leave_ID = @Leave_ID            
        SET @FLAG = 'BD'            
      END        
                  
      --THIS LOGIC WAS ADDED TO CHECK FUTURE-DATE LEAVE APPLICATION             
      IF EXISTS(SELECT Leave_Period FROM T0110_LEAVE_APPLICATION_DETAIL LAD inner join T0100_LEAVE_APPLICATION LA on La.Leave_Application_ID = lad.Leave_Application_ID             
      WHERE lad.Cmp_ID = @Cmp_ID  AND From_Date = @DAYAFTER and Emp_ID = @Emp_ID) --AND Leave_ID = @Leave_ID            
      BEGIN            
		   set @DAYAFTER=@From_Date          
		   set @Counter=1          
             
			   WHILE ( @Counter < @MAXDAYS)          
			   BEGIN          
			   --select @Counter          
            
			   --select @DAYAFTER          
				   set @Countt=0          
				   set @Countt=(SELECT Distinct 1 Leave_Period FROM T0110_LEAVE_APPLICATION_DETAIL  LAD inner join T0100_LEAVE_APPLICATION LA on La.Leave_Application_ID = lad.Leave_Application_ID           
				   inner join T0040_LEAVE_MASTER LM on lm.Leave_ID=lad.Leave_ID          
				   left join T0120_LEAVE_APPROVAL LAP on lap.Leave_Application_ID=la.Leave_Application_ID          
				   --inner join T0150_LEAVE_CANCELLATION LC on LC.Leave_Approval_id!=lap.Leave_Approval_ID          
						WHERE lad.Cmp_ID = @Cmp_ID  AND  @DAYAFTER between From_Date and To_Date and la.Emp_ID = @Emp_ID and lm.Leave_Continuity=1 and LA.Application_Status !='R'
						and LAP.Leave_Approval_ID Not in (select Distinct Leave_Approval_id from T0150_LEAVE_CANCELLATION where cmp_id=@Cmp_ID and emp_id=@Emp_ID and For_date between @StartDate1 and @EndDate1))
            
						   if isnull(@Countt,0)!=0          
						   begin          
             
							set @TOTAL_PERIOD=@TOTAL_PERIOD+@Countt          
							set @DAYAFTER= DATEADD(dd, DATEDIFF(d,0,@From_Date),@Counter)            
							  end          
						   else          
						   begin          
             
						   BREAK           
						   end          
          
						  set @Counter=@Counter+1          
			 END          
          
        --SET @TOTAL_PERIOD = @TOTAL_PERIOD + (SELECT Leave_Period FROM T0110_LEAVE_APPLICATION_DETAIL LAD inner join T0100_LEAVE_APPLICATION LA on La.Leave_Application_ID = lad.Leave_Application_ID            
        --WHERE lad.Cmp_ID = @Cmp_ID  AND From_Date = @DAYAFTER and Emp_ID = @Emp_ID) --AND Leave_ID = @Leave_ID            
                    
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
  -- else            
  -- begin            
             
         
  --      --================================HOLIDAY CALCULATION===============================================          
  --    if exists (Select 1 from #EMP_HOLIDAY where For_Date between @DAYBEFORE and @From_Date)            
  --    begin        
	 -- --Select Count(1) from #EMP_HOLIDAY EH inner join  T0100_LEAVE_APPLICATION LA on La.Emp_ID=EH.emp_id inner join T0110_LEAVE_APPLICATION_DETAIL LAD   on lad.Leave_Application_ID=la.Leave_Application_ID  where For_Date between @DAYBEFORE and @From_Date and EH.For_Date between lad.From_Date and To_Date
  --      --Set @CountforWeekHoli = @CountforWeekHoli + (Select Count(1) from #EMP_HOLIDAY where For_Date between @DAYBEFORE and @From_Date)            
		--Set @CountforWeekHoli = @CountforWeekHoli + (Select Count(1) from #EMP_HOLIDAY EH 
		--inner join  T0100_LEAVE_APPLICATION LA on La.Emp_ID=EH.emp_id 
		--inner join T0110_LEAVE_APPLICATION_DETAIL LAD   on lad.Leave_Application_ID=la.Leave_Application_ID 
		-- left join T0120_LEAVE_APPROVAL LAP on lap.Leave_Application_ID=la.Leave_Application_ID 
		--where For_Date between @DAYBEFORE and @From_Date and EH.For_Date between lad.From_Date and To_Date
		-- and LAP.Leave_Approval_ID Not in (select Distinct Leave_Approval_id from T0150_LEAVE_CANCELLATION where cmp_id=@Cmp_ID and emp_id=@Emp_ID and For_date between @StartDate1 and @EndDate1)
		--	    and LA.Application_Status !='R')            
  --      SET @FLAG = 'BYPASS'            
            
  --    end            
            
  --    if exists (Select 1 from #EMP_HOLIDAY where For_Date between @From_Date and @DAYAFTER  )            
  --    begin             
  --           --Select Count(1) from #EMP_HOLIDAY EH inner join  T0100_LEAVE_APPLICATION LA on La.Emp_ID=EH.emp_id inner join T0110_LEAVE_APPLICATION_DETAIL LAD   on lad.Leave_Application_ID=la.Leave_Application_ID  where For_Date between @From_Date and @DAYBEFORE and   EH.For_Date between lad.From_Date and To_Date
  --      --Set @CountforWeekHoli = @CountforWeekHoli + (Select Count(1) from #EMP_HOLIDAY where For_Date between @DAYAFTER and @From_Date)          
		--        Set @CountforWeekHoli = @CountforWeekHoli + (Select Count(1) from #EMP_HOLIDAY EH 
		--		inner join  T0100_LEAVE_APPLICATION LA on La.Emp_ID=EH.emp_id 
		--		inner join T0110_LEAVE_APPLICATION_DETAIL LAD   on lad.Leave_Application_ID=la.Leave_Application_ID
		--		 left join T0120_LEAVE_APPROVAL LAP on lap.Leave_Application_ID=la.Leave_Application_ID 
		--		where For_Date between @From_Date and @DAYAFTER and   EH.For_Date between lad.From_Date and To_Date
		--		 and LAP.Leave_Approval_ID Not in (select Distinct Leave_Approval_id from T0150_LEAVE_CANCELLATION where cmp_id=@Cmp_ID and emp_id=@Emp_ID and For_date between @StartDate1 and @EndDate1)
		--	    and LA.Application_Status !='R')            
  --      SET @FLAG = 'BYPASS'            
  --    end            
  --     --================================HOLIDAY CALCULATION===============================================          
  -- end            
               
            
               
		   IF @FLAG <> 'BYPASS'            
		   BEGIN            
                --=============================WEEKOFF-HOLIDAY CALCULATION===============================================================
			IF @FLAG <> 'WEEKOFF' OR @FLAG <> 'HOLIDAY'            
		  BEGIN            
            
               
            
            
       --THIS LOGIC WAS ADDED TO CHECK BACK-DATED LEAVE APPLICATION             
      IF EXISTS(SELECT sum(Leave_Period) as Leave_Period FROM T0110_LEAVE_APPLICATION_DETAIL  LAD inner join T0100_LEAVE_APPLICATION LA on La.Leave_Application_ID = lad.Leave_Application_ID             
      WHERE lad.Cmp_ID = @Cmp_ID  AND From_Date between @DAYBEFORE and @From_Date and Emp_ID = @Emp_ID) --AND Leave_ID = @Leave_ID            
      BEGIN             
              --=========================================================OLD Code================================================================          
        --SET @TOTAL_PERIOD = @TOTAL_PERIOD + (SELECT sum(Leave_Period) as Leave_Period FROM T0110_LEAVE_APPLICATION_DETAIL  LAD inner join T0100_LEAVE_APPLICATION LA on La.Leave_Application_ID = lad.Leave_Application_ID             
       -- WHERE lad.Cmp_ID = @Cmp_ID  AND From_Date  between @DAYBEFORE and @From_Date and Emp_ID = @Emp_ID)            
			--=========================================================OLD Code================================================================   
          
				set @DAYBEFORE=@From_Date          
				set @Counter=1   
				
			WHILE ( @Counter < @MAXDAYS)          
				  BEGIN          
					--select * from #Emp_WeekOff
					 --select @Counter          
					   set @DAYBEFORE= DATEADD(dd, DATEDIFF(d,0,@From_Date),-@Counter)            
							
					   set @Countt=0          
					   set @Countt=(SELECT Distinct 1  FROM T0110_LEAVE_APPLICATION_DETAIL  LAD inner join T0100_LEAVE_APPLICATION LA on La.Leave_Application_ID = lad.Leave_Application_ID            
					   inner join T0040_LEAVE_MASTER LM on lm.Leave_ID=lad.Leave_ID          
					   left join T0120_LEAVE_APPROVAL LAP on lap.Leave_Application_ID=la.Leave_Application_ID          
					  -- inner join T0150_LEAVE_CANCELLATION LC on LC.Leave_Approval_id=lap.Leave_Approval_ID          
							WHERE lad.Cmp_ID = @Cmp_ID  AND  @DAYBEFORE between From_Date and To_Date and la.Emp_ID = @Emp_ID and lm.Leave_Continuity=1 and LA.Application_Status !='R'
							and LAP.Leave_Approval_ID Not in (select Distinct Leave_Approval_id from T0150_LEAVE_CANCELLATION where cmp_id=@Cmp_ID and emp_id=@Emp_ID and For_date between @StartDate1 and @EndDate1))
						--select @Countt        
						   if isnull(@Countt,0)!=0          
						   begin          
		 				A:
							set @TOTAL_PERIOD=@TOTAL_PERIOD+@Countt          
          
							set @Counter=@Counter+1          
       
							  end        
         
						   else          
						   begin  
						   
						   if EXISTS(select 1 from #Emp_WeekOff where For_Date=@DAYBEFORE)
						   begin
						   set @Countt=1
						   goto A
						   end
						   else
						   begin
						   SET @WEEKHOLI_FROM_DATE=@DAYBEFORE
						    BREAK
						   end
						   
							
						             
						   end          
            
			 END          
          
		   --=====================================================================================================
		   --============================================================WEEKOFF====================================================================
		  if @Sett_WeekOff = 0
			BEGIN     
			
				  if exists (Select 1 from #Emp_WeekOff where For_Date between @DAYBEFORE and @From_Date)            
				  begin            
	  	         
					--Set @CountforWeekHoli = @CountforWeekHoli + (Select Count(1) from #Emp_WeekOff EW inner join  T0100_LEAVE_APPLICATION LA on La.Emp_ID=ew.emp_id 
					--inner join T0110_LEAVE_APPLICATION_DETAIL LAD   on lad.Leave_Application_ID=la.Leave_Application_ID 
					-- left join T0120_LEAVE_APPROVAL LAP on lap.Leave_Application_ID=la.Leave_Application_ID    
					--where For_Date between @WEEKHOLI_FROM_DATE and @From_Date and ew.For_Date between lad.From_Date and To_Date  
					--and LAP.Leave_Approval_ID Not in (select Distinct Leave_Approval_id from T0150_LEAVE_CANCELLATION where cmp_id=@Cmp_ID and emp_id=@Emp_ID and  For_date between @StartDate1 and @EndDate1)
					--and LA.Application_Status !='R')
					Set @CountforWeekHoli = @CountforWeekHoli + (Select Count(1) from #Emp_WeekOff     
					where For_Date between @WEEKHOLI_FROM_DATE and @From_Date) 
	
					SET @FLAG = 'BYPASS' 
		
				  end  
				  
			END
			--============================================================WEEKOFF====================================================================
			--============================================================HOLIDAY====================================================================
			 if @Sett_Holiday = 0    
			 BEGIN 
			  if exists (Select 1 from #EMP_HOLIDAY where For_Date between @DAYBEFORE and @From_Date)            
				  begin        
				  --Select Count(1) from #EMP_HOLIDAY EH inner join  T0100_LEAVE_APPLICATION LA on La.Emp_ID=EH.emp_id inner join T0110_LEAVE_APPLICATION_DETAIL LAD   on lad.Leave_Application_ID=la.Leave_Application_ID  where For_Date between @DAYBEFORE and @From_Date and EH.For_Date between lad.From_Date and To_Date
					--Set @CountforWeekHoli = @CountforWeekHoli + (Select Count(1) from #EMP_HOLIDAY where For_Date between @DAYBEFORE and @From_Date)            
					--Set @CountforWeekHoli = @CountforWeekHoli + (Select Count(1) from #EMP_HOLIDAY EH 
					--inner join  T0100_LEAVE_APPLICATION LA on La.Emp_ID=EH.emp_id 
					--inner join T0110_LEAVE_APPLICATION_DETAIL LAD   on lad.Leave_Application_ID=la.Leave_Application_ID 
					-- left join T0120_LEAVE_APPROVAL LAP on lap.Leave_Application_ID=la.Leave_Application_ID 
					--where For_Date between @WEEKHOLI_FROM_DATE and @From_Date and EH.For_Date between lad.From_Date and To_Date
					-- and LAP.Leave_Approval_ID Not in (select Distinct Leave_Approval_id from T0150_LEAVE_CANCELLATION where cmp_id=@Cmp_ID and emp_id=@Emp_ID and For_date between @StartDate1 and @EndDate1)
					--		and LA.Application_Status !='R')
					Set @CountforWeekHoli = @CountforWeekHoli + (Select Count(1) from #EMP_HOLIDAY
					where For_Date between @WEEKHOLI_FROM_DATE and @From_Date)
				  
					SET @FLAG = 'BYPASS'            
            
				end 
			 END
			 --============================================================HOLIDAY====================================================================
		   --=====================================================================================================

          
        SET @FLAG = 'BD'            
      END            
                    
      --THIS LOGIC WAS ADDED TO CHECK FUTURE-DATE LEAVE APPLICATION             
      IF EXISTS(SELECT sum(Leave_Period) as Leave_Period FROM T0110_LEAVE_APPLICATION_DETAIL LAD inner join T0100_LEAVE_APPLICATION LA on La.Leave_Application_ID = lad.Leave_Application_ID             
      WHERE lad.Cmp_ID = @Cmp_ID  AND From_Date between  @From_Date and @DAYAFTER and Emp_ID = @Emp_ID) --AND Leave_ID = @Leave_ID            
      BEGIN            
             
   --select @DAYAFTER          
   --=========================================================OLD Code================================================================          
        --SET @TOTAL_PERIOD = @TOTAL_PERIOD + (SELECT sum(Leave_Period) as Leave_Period FROM T0110_LEAVE_APPLICATION_DETAIL LAD inner join T0100_LEAVE_APPLICATION LA on La.Leave_Application_ID = lad.Leave_Application_ID             
        --WHERE lad.Cmp_ID = @Cmp_ID  AND From_Date  between   @From_Date and @DAYAFTER and Emp_ID = @Emp_ID) --AND Leave_ID = @Leave_ID            
          --=========================================================OLD Code================================================================          
               
     set @DAYAFTER=@From_Date          
   set @Counter=1          
             
   WHILE ( @Counter < @MAXDAYS)          
   BEGIN     
   
   --select @Counter          
            
   --select @DAYAFTER          
   set @Countt=0          
   set @Countt=(SELECT Distinct 1 Leave_Period FROM T0110_LEAVE_APPLICATION_DETAIL  LAD inner join T0100_LEAVE_APPLICATION LA on La.Leave_Application_ID = lad.Leave_Application_ID           
   inner join T0040_LEAVE_MASTER LM on lm.Leave_ID=lad.Leave_ID          
   left join T0120_LEAVE_APPROVAL LAP on lap.Leave_Application_ID=la.Leave_Application_ID          
   --inner join T0150_LEAVE_CANCELLATION LC on LC.Leave_Approval_id=lap.Leave_Approval_ID          
        WHERE lad.Cmp_ID = @Cmp_ID  AND  @DAYAFTER between From_Date and To_Date and la.Emp_ID = @Emp_ID and lm.Leave_Continuity=1 and LA.Application_Status !='R'
		and LAP.Leave_Approval_ID Not in (select Distinct Leave_Approval_id from T0150_LEAVE_CANCELLATION where cmp_id=@Cmp_ID and emp_id=@Emp_ID and For_date between @StartDate1 and @EndDate1))
            
   if isnull(@Countt,0)!=0          
   begin          
      B:      
    set @TOTAL_PERIOD=@TOTAL_PERIOD+@Countt          
    set @DAYAFTER= DATEADD(dd, DATEDIFF(d,0,@From_Date),@Counter) 
	set @Counter=@Counter+1  
      end          
   else          
   begin    
   if EXISTS(select 1 from #Emp_WeekOff where For_Date=@DAYAFTER)
	begin
		set @Countt=1
		goto B
	end
	else
	begin
		SET @WEEKHOLI_TO_DATE=@DAYAFTER
		BREAK
	end




             
   BREAK           
   end          
          
          
 END          
         
		  --=====================================================================================================
		  --================================================WEEKOFF======================================================================================
		  if @Sett_WeekOff = 0
			BEGIN        
				   if exists (Select 1 from #Emp_WeekOff where For_Date between @From_Date and @DAYAFTER )            
					 begin        
	  
			--	    Select Count(1) from #Emp_WeekOff EW inner join  T0100_LEAVE_APPLICATION LA on La.Emp_ID=ew.emp_id inner join T0110_LEAVE_APPLICATION_DETAIL LAD   on lad.Leave_Application_ID=la.Leave_Application_ID  where For_Date between @From_Date and @DAYAFTER and ew.For_Date between lad.From_Date and To_Date
				   -- Select * from #Emp_WeekOff where For_Date between  @From_Date and @DAYAFTER
	   
						 --  Set @CountforWeekHoli = @CountforWeekHoli + (Select Count(1) from #Emp_WeekOff EW inner join  T0100_LEAVE_APPLICATION LA on La.Emp_ID=ew.emp_id 
						 --  inner join T0110_LEAVE_APPLICATION_DETAIL LAD   on lad.Leave_Application_ID=la.Leave_Application_ID 
						 --  left join T0120_LEAVE_APPROVAL LAP on lap.Leave_Application_ID=la.Leave_Application_ID    
						 --  where For_Date between @From_Date and @WEEKHOLI_TO_DATE and ew.For_Date between lad.From_Date and To_Date 
						 --  and LAP.Leave_Approval_ID Not in (select Distinct Leave_Approval_id from T0150_LEAVE_CANCELLATION where cmp_id=@Cmp_ID and emp_id=@Emp_ID and For_date between @StartDate1 and @EndDate1)
							--and LA.Application_Status !='R') 
							Set @CountforWeekHoli = @CountforWeekHoli + (Select Count(1) from #Emp_WeekOff 
						   where For_Date between @From_Date and @WEEKHOLI_TO_DATE)
						     
					--Set @CountforWeekHoli = @CountforWeekHoli + (Select Count(1) from #Emp_WeekOff where For_Date between @From_Date and @DAYAFTER )            
					SET @FLAG = 'BYPASS'
					--select @DAYAFTER,@CountforWeekHoli
				  end 
						END
						--================================================WEEKOFF======================================================================================
			--================================================HOLIDAY======================================================================================
			if @Sett_Holiday = 0    
			BEGIN
					if exists (Select 1 from #EMP_HOLIDAY where For_Date between @From_Date and @DAYAFTER  )            
      begin             
             --Select Count(1) from #EMP_HOLIDAY EH inner join  T0100_LEAVE_APPLICATION LA on La.Emp_ID=EH.emp_id inner join T0110_LEAVE_APPLICATION_DETAIL LAD   on lad.Leave_Application_ID=la.Leave_Application_ID  where For_Date between @From_Date and @DAYBEFORE and   EH.For_Date between lad.From_Date and To_Date
        --Set @CountforWeekHoli = @CountforWeekHoli + (Select Count(1) from #EMP_HOLIDAY where For_Date between @DAYAFTER and @From_Date)          
		  --      Set @CountforWeekHoli = @CountforWeekHoli + (Select Count(1) from #EMP_HOLIDAY EH 
				--inner join  T0100_LEAVE_APPLICATION LA on La.Emp_ID=EH.emp_id 
				--inner join T0110_LEAVE_APPLICATION_DETAIL LAD   on lad.Leave_Application_ID=la.Leave_Application_ID
				-- left join T0120_LEAVE_APPROVAL LAP on lap.Leave_Application_ID=la.Leave_Application_ID 
				--where For_Date between @From_Date and @DAYAFTER and   EH.For_Date between lad.From_Date and To_Date
				-- and LAP.Leave_Approval_ID Not in (select Distinct Leave_Approval_id from T0150_LEAVE_CANCELLATION where cmp_id=@Cmp_ID and emp_id=@Emp_ID and For_date between @StartDate1 and @EndDate1)
			 --   and LA.Application_Status !='R') 
			 Set @CountforWeekHoli = @CountforWeekHoli + (Select Count(1) from #EMP_HOLIDAY 
				where For_Date between @From_Date and @DAYAFTER )
				 SET @FLAG = 'BYPASS'            
				end     
			END
			--================================================HOLIDAY======================================================================================
		   --=====================================================================================================


          
          
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
	 
              
            
    --select @datechkback,@datechkfrwd,@From_Date       
     --Checking backdated Leave Application             
     if exists(SELECT Leave_Period FROM T0110_LEAVE_APPLICATION_DETAIL  LAD inner join T0100_LEAVE_APPLICATION LA             
     on La.Leave_Application_ID = lad.Leave_Application_ID             
     WHERE lad.Cmp_ID = @Cmp_ID  AND From_Date = @From_Date and Emp_ID = @Emp_ID)            
     begin    

	  


    
  --=====================================================================================  
   set @DAYBEFORE=@From_Date
   set @Counter=1   
       --select @DAYBEFORE  
          
   WHILE ( @Counter < @MAXDAYS)          
 BEGIN          
           
          
   set @DAYBEFORE= DATEADD(dd, DATEDIFF(d,0,@From_Date),-@Counter)            
             
   set @Countt=0          
    set @Countt=(SELECT Distinct 1  FROM T0110_LEAVE_APPLICATION_DETAIL  LAD inner join T0100_LEAVE_APPLICATION LA on La.Leave_Application_ID = lad.Leave_Application_ID            
   inner join T0040_LEAVE_MASTER LM on lm.Leave_ID=lad.Leave_ID          
   left join T0120_LEAVE_APPROVAL LAP on lap.Leave_Application_ID=la.Leave_Application_ID          
   --inner join T0150_LEAVE_CANCELLATION LC on LC.Leave_Approval_id=lap.Leave_Approval_ID          
        WHERE lad.Cmp_ID = @Cmp_ID  AND  @DAYBEFORE between From_Date and To_Date and la.Emp_ID = @Emp_ID and lm.Leave_Continuity=1 and LA.Application_Status !='R'  
  and LAP.Leave_Approval_ID Not in (select Distinct Leave_Approval_id from T0150_LEAVE_CANCELLATION where cmp_id=@Cmp_ID and emp_id=@Emp_ID and For_date between @StartDate1 and @EndDate1))     
    --select @DAYBEFORE        
   if isnull(@Countt,0)!=0          
   begin          
         
    set @TOTAL_PERIOD=@TOTAL_PERIOD+@Countt  
          
    set @Counter=@Counter+1          
       
      end        
         
   else          
   begin 
   
   BREAK           
   end          
            
 END    
  --=====================================================================================  
            
			
       --set @TOTAL_PERIOD = @TOTAL_PERIOD + (SELECT Leave_Period FROM T0110_LEAVE_APPLICATION_DETAIL  LAD inner join T0100_LEAVE_APPLICATION LA on La.Leave_Application_ID = lad.Leave_Application_ID WHERE lad.Cmp_ID = @Cmp_ID  AND From_Date = @datechkback and Emp_ID = @Emp_ID)       end            
            
     --Checking future dated leave application             
     if exists(SELECT Leave_Period FROM T0110_LEAVE_APPLICATION_DETAIL  LAD inner join T0100_LEAVE_APPLICATION LA             
     on La.Leave_Application_ID = lad.Leave_Application_ID             
     WHERE lad.Cmp_ID = @Cmp_ID  AND From_Date = @From_Date and Emp_ID = @Emp_ID)            
     begin    

	 
    
   --=====================================================================================  
   set @DAYAFTER=@From_Date          
     set @Counter=1  
	 
   WHILE ( @Counter < @MAXDAYS)          
 BEGIN          
           
        
		
	
   set @DAYAFTER= DATEADD(dd, DATEDIFF(d,0,@From_Date),@Counter-1)        
          
   set @Countt=0          
   set @Countt=(SELECT Distinct isnull(1,0)  FROM T0110_LEAVE_APPLICATION_DETAIL  LAD inner join T0100_LEAVE_APPLICATION LA on La.Leave_Application_ID = lad.Leave_Application_ID            
   inner join T0040_LEAVE_MASTER LM on lm.Leave_ID=lad.Leave_ID          
   left join T0120_LEAVE_APPROVAL LAP on lap.Leave_Application_ID=la.Leave_Application_ID          
   --inner join T0150_LEAVE_CANCELLATION LC on LC.Leave_Approval_id=lap.Leave_Approval_ID          
        WHERE lad.Cmp_ID = @Cmp_ID  AND  @DAYAFTER between From_Date and To_Date and la.Emp_ID = @Emp_ID and lm.Leave_Continuity=1 and LA.Application_Status !='R'  
  and LAP.Leave_Approval_ID Not in (select Distinct Leave_Approval_id from T0150_LEAVE_CANCELLATION where cmp_id=@Cmp_ID and emp_id=@Emp_ID and For_date between @StartDate1 and @EndDate1))          
     
     
   
   if isnull(@Countt,0)!=0          
   begin          
         
    set @TOTAL_PERIOD=@TOTAL_PERIOD+@Countt          
          
    set @Counter=@Counter+1          
       
      end        
         
   else          
   begin
   
  -- if @TOTAL_PERIOD>@CountforWeekHoli 
  -- begin
  
   -- set @TOTAL_PERIOD=@TOTAL_PERIOD-@CountforWeekHoli
	--end
	
      BREAK           
   end       
   end  
   end         
 END    
  --=====================================================================================  
       --set @TOTAL_PERIOD = @TOTAL_PERIOD + (SELECT Leave_Period FROM T0110_LEAVE_APPLICATION_DETAIL  LAD inner join T0100_LEAVE_APPLICATION LA on La.Leave_Application_ID = lad.Leave_Application_ID WHERE lad.Cmp_ID = @Cmp_ID  AND From_Date = @datechkfrwd and Emp_ID = @Emp_ID)       end            
            
        --select @TOTAL_PERIOD         
               
   END            
       
     -- set  @TOTAL_PERIOD=@TOTAL_PERIOD-@Period          
    --Set @Period = @Period + @TOTAL_PERIOD            
   
 set @TOTAL_PERIOD=@TOTAL_PERIOD-@CountforWeekHoli
   
   --SELECT @CountforWeekHoli AS CountforWeekHoli
   --SELECT @TOTAL_PERIOD
   if @total_period =0     
   begin    
     SET @TOTAL_PERIOD = @Period     
   end    
   else    
   begin    
   
    Set @Period =  @TOTAL_PERIOD            
   End     
                   
                
    --SELECT @SCHEME_ID = Scheme_ID from T0095_EMP_SCHEME WITH (NOLOCK) where Type = 'Leave'  and Cmp_Id = @Cmp_ID and emp_Id = @Emp_ID and Effective_Date <= @From_Date   --Code commented by Yogesh on 29022024          
 -- Code update by Yogesh on 29022024---------START---------------------------------------------------          
		SELECT Distinct @SCHEME_ID = ES.Scheme_ID from T0095_EMP_SCHEME ES WITH (NOLOCK)           
		inner join T0050_Scheme_Detail SD WITH (NOLOCK)  on es.Scheme_ID=sd.Scheme_Id where Type = 'Leave'  and es.Cmp_Id =  @Cmp_ID and es.emp_Id =@Emp_ID and es.Effective_Date <= @From_Date   
		and (select top 1 cast(data  as numeric) from dbo.split(sd.Leave,'#')) in (Cast(@Leave_ID as varchar) )
 
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