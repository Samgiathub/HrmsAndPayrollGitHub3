

CREATE PROCEDURE [dbo].[P_GET_EMP_INOUT_02062022]    
 @Cmp_ID  NUMERIC(9,0),    
 @From_Date DateTime,  
 @To_Date DateTime,  
 @First_In_Last_OUT_Flag tinyint=0 ---Hardik 28/04/2017 for Today's Attendance on Home Page  
AS  
BEGIN  
 SET NOCOUNT ON;  
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;  
 SET ANSI_WARNINGS OFF  

 
 --Following Code added by Nimesh on 19-Sep-2018  
 --To Optmize the application performance  
 --If this procedure is already executed before in different stored procedure but in same transaction  
 IF OBJECT_ID('tempdb..#EMP_CONS_INOUT') IS NOT NULL  
  AND OBJECT_ID('tempdb..#DATA_INOUT') IS NOT NULL  
  BEGIN  
   --if both data has same data  
  
--select * from #DATA_INOUT
--return
   IF EXISTS(SELECT 1 FROM #EMP_CONS_INOUT EI FULL OUTER JOIN #EMP_CONS EC ON EI.EMP_ID=EC.EMP_ID WHERE EI.Emp_ID IS NULL OR EC.Emp_ID IS NULL)  
    BEGIN  
		TRUNCATE TABLE #DATA  
		INSERT INTO #DATA  
		SELECT  * FROM #DATA_INOUT  
     RETURN  
    END  
  END  
   
   --SELECT * FROM #DATA
   
 --PRINT 'P_GET_EMP_INOUT -STAGE 1: ' + CONVERT(VARCHAR(20), GETDATE(), 114)  
 DECLARE @IsNight BIT  
 DECLARE @First_In_Last_Out_For_InOut_Calculation TINYINT   
 DECLARE @First_In_Last_Out_For_InOut_Calculation_Actual TINYINT   
   
 /********************************************************************************  
 THE FOLLOWING CASE IS ADDED FOR ONLY NIGHT SHIFT + FIRST IN LAST OUT SCENARIO  
 REST FOR THE SETTINGS WILL BE APPLIED AS BELLOW.  
 *********************************************************************************/  
 SELECT @IsNight = ISNULL(SETTING_VALUE,0) FROM T0040_SETTING WITH (NOLOCK)  WHERE SETTING_NAME='Enable Night Shift Scenario for In Out' AND CMP_ID=@Cmp_ID  
   
 IF @IsNight = 1   
  BEGIN   

  SELECT TOP 1 @First_In_Last_Out_For_InOut_Calculation  = First_In_Last_Out_For_InOut_Calculation  
   FROM #EMP_CONS EC   
     INNER JOIN T0040_GENERAL_SETTING GS WITH (NOLOCK) ON EC.BRANCH_ID=GS.BRANCH_ID  
     INNER JOIN (SELECT GS1.BRANCH_ID, MAX(FOR_DATE) AS FOR_DATE  
        FROM T0040_GENERAL_SETTING GS1  WITH (NOLOCK)   
        WHERE GS1.FOR_DATE < @TO_DATE  
        GROUP BY GS1.BRANCH_ID) GS1 ON GS.BRANCH_ID=GS1.BRANCH_ID AND GS.FOR_DATE=GS1.FOR_DATE   
   --IF @First_In_Last_Out_For_InOut_Calculation = 1  
    BEGIN  
     EXEC [P_GET_EMP_INOUT_CACHE] @Cmp_ID=@Cmp_ID, @From_Date=@From_Date, @To_Date=@To_Date, @First_In_Last_OUT_Flag=@First_In_Last_OUT_Flag  
     GOTO END_OF_CALL;  
    END  
  END  
    
 IF OBJECT_ID('tempdb..#TMP_EMP_0150_INOUT') IS NULL  
  BEGIN  
    
   SElECT TOP 0 * INTO #TMP_EMP_0150_INOUT FROM T0150_EMP_INOUT_RECORD WITH (NOLOCK)  WHERE 1<>1  
   CREATE CLUSTERED INDEX IX_TMP_INOUT ON #TMP_EMP_0150_INOUT (For_Date Desc,Emp_ID, In_Time,Out_Time)  
     
   INSERT INTO #TMP_EMP_0150_INOUT  
   --SELECT EIR.*  
   --FROM dbo.T0150_EMP_INOUT_RECORD EIR WITH (NOLOCK)  INNER JOIN #EMP_CONS EC ON EIR.EMP_ID=EC.EMP_ID  
   --WHERE FOR_DATE BETWEEN (@FROM_DATE - 7) AND (@To_Date + 7)  
   SELECT IO_Tran_Id,EIR.Emp_ID,Cmp_ID,For_Date,case when isnull(In_Time,'') = '' then In_Date_Time else In_Time end as In_Time   
   ,case when Out_Time is null then Out_Date_Time else Out_Time end as Out_Time ,Duration,Reason,Ip_Address,In_Date_Time,Out_Date_Time,Skip_Count,Late_Calc_Not_App,Chk_By_Superior,Sup_Comment,Half_Full_day,Is_Cancel_Late_In,Is_Cancel_Early_Out,Is_Default_In,Is_Default_Out,Cmp_prp_in_flag,Cmp_prp_out_flag,is_Cmp_purpose,App_Date,Apr_Date,System_date,Other_Reason,ManualEntryFlag,StatusFlag,In_Admin_Time,Out_Admin_Time FROM dbo.T0150_EMP_INOUT_RECORD EIR WITH (NOLOCK)  INNER JOIN #EMP_CONS EC ON EIR.EMP_ID=EC.EMP_ID  
   WHERE FOR_DATE BETWEEN (@FROM_DATE - 7) AND (@To_Date + 7)  
  END  
  
  --Select   from #TMP_EMP_0150_INOUT  
   
 IF OBJECT_ID('tempdb..#EMP_GEN_SETTINGS') IS NULL  
  BEGIN  
   CREATE TABLE #EMP_GEN_SETTINGS  
   (  
    EMP_ID  NUMERIC PRIMARY KEY,  
    BRANCH_ID NUMERIC,  
    First_In_Last_Out_For_InOut_Calculation TINYINT,  
    Chk_otLimit_before_after_Shift_time TINYINT  
   )   
  END  
  

 IF OBJECT_ID('tempdb..#Data') IS NULL  
  BEGIN  
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
      IO_Tran_Id    numeric default 0, -- io_tran_id is used for is_cmp_purpose (t0150_emp_inout)  
      OUT_Time datetime,  
      Shift_End_Time datetime,   --Ankit 16112013  
      OT_End_Time numeric default 0, --Ankit 16112013  
      Working_Hrs_St_Time tinyint default 0, --Hardik 14/02/2014  
      Working_Hrs_End_Time tinyint default 0, --Hardik 14/02/2014  
      GatePass_Deduct_Days numeric(18,2) default 0 -- Add by Gadriwala Muslim 05012014  
	 ,Working_sec_Between_Shift numeric(18) default 0
     )      
  END  
   
  
   
 DECLARE @cBrh AS NUMERIC   
 DECLARE @Chk_otLimit_before_after_Shift_time TINYINT   
  
 DECLARE @curEmp_ID NUMERIC(9,0)  
 Declare @Is_OT numeric -- Hardik 03/02/2014  
  
  
 IF Isnull(@IsNight,0) = 1  
  BEGIN   
   DECLARE @Shift_Id_N AS NUMERIC  
   DECLARE @Shift_St_Sec AS NUMERIC  
   DECLARE @Shift_En_sec AS NUMERIC  
   DECLARE @Shift_St_Time AS VARCHAR(10)  
   DECLARE @Shift_End_Time AS VARCHAR(10)  
   DECLARE @Shift_Dur_N AS VARCHAR(10)  
   DECLARE @Shift_ST_DateTime AS DATETIME  
   DECLARE @Temp_Date AS DATETIME  
     
   DECLARE @Shift_End_DateTime AS DATETIME  
   DECLARE @Insert_In_Date AS DATETIME  
   DECLARE @Insert_Out_Date AS DATETIME  
     
   DECLARE @Shift_St_Sec_Next_day AS NUMERIC  
   DECLARE @Shift_En_sec_Next_day AS NUMERIC  
   DECLARE @Shift_St_Time_Next_day AS VARCHAR(10)  
   DECLARE @Shift_End_Time_Next_day AS VARCHAR(10)  
   DECLARE @Shift_End_DateTime_Next_day AS DATETIME  
   DECLARE @Shift_ST_DateTime_Next_day AS DATETIME  
   DECLARE @Shift_Id_N_Next_day AS NUMERIC  
   DECLARE @Shift_Dur_N_Next_Day AS VARCHAR(10)  
   DECLARE @Add_Hrs_Shift_End_Time AS NUMERIC(18,3)  
   DECLARE @Minus_Hrs_Shift_St_Time AS NUMERIC  
   DECLARE @Temp_Date_Next_Day AS DATETIME  
     
   /*Half Day Shift*/  
   DECLARE @Is_Half_Day As numeric;  
   DECLARE @Half_WeekDay Varchar(10);  
   DECLARE @Half_Shift_St_Time As DATETIME;  
   DECLARE @Half_Shift_End_Time As DATETIME;     
   DECLARE @Half_Shift_Day AS BIT;  
   /*Half Day Shift*/  
   DECLARE @Temp_End_Date AS DATETIME  
   DECLARE @Temp_Month_Date AS DATETIME  
   DECLARE @PREVIOUS_END_TIME DATETIME  
   
   DECLARE curNightShift CURSOR FOR  
   SELECT Emp_ID FROM #Emp_Cons   
   OPEN curNightShift                        
   FETCH NEXT FROM curNightShift INTO @curEmp_ID  
    WHILE @@FETCH_STATUS = 0  
    BEGIN  
     SET @Temp_Month_Date = dateadd(dd,-1, @From_Date) --Added Day -1 to get Previous Out Time to check whether employee has continuous shift or not.   
     SET @Temp_End_Date = @To_Date        
     SET @PREVIOUS_END_TIME = @Temp_Month_Date;  
  
               
     WHILE @Temp_Month_Date <= @Temp_End_Date        
      BEGIN  
  
       SET @Shift_Id_N = 0        
       SET @Half_Shift_Day = 0;    
       SET @Half_Shift_St_Time = NULL;  
       SET @Half_Shift_End_Time = NULL;  
       SET @Half_WeekDay = NULL;  
       SET @Is_Half_Day = NULL;  
              
       Exec SP_CURR_T0100_EMP_SHIFT_GET @curEmp_ID,@Cmp_ID,@Temp_Month_Date,@Shift_St_Time output,@Shift_End_Time output,@Shift_Dur_N output,null,null,null,null,@Shift_Id_N output,@Is_Half_Day OUTPUT, @Half_WeekDay OUTPUT, @Half_Shift_St_Time OUTPUT, @Half_Shift_End_Time OUTPUT         
       IF DATENAME(WEEKDAY, @Temp_Month_Date) = @Half_WeekDay AND @Is_Half_Day = 1 AND @Half_Shift_St_Time IS NOT NULL  
        BEGIN  
         SET @Shift_St_Time = dbo.F_Return_HHMM(@Half_Shift_St_Time);  
         SET @Shift_End_Time = dbo.F_Return_HHMM(@Half_Shift_End_Time);  
         SET @Half_Shift_Day = 1;          
        END  
          
       SET @Add_Hrs_Shift_End_Time =7  
       SET @Minus_Hrs_Shift_St_Time = 7  
  
       SET @Shift_St_Sec = dbo.F_Return_Sec(@Shift_St_Time)        
       SET @Shift_En_Sec = dbo.F_Return_Sec(@Shift_End_Time)        
       --SET @Second_Break_Duration_Sec = dbo.F_Return_Sec(@Second_Break_Duration)                      
  
  
       SET @Shift_St_Datetime = cast(cast(@Temp_Month_Date as varchar(11)) + ' ' + @Shift_St_Time as smalldatetime)        
       SET @Temp_Date = dateadd(d,1,@Temp_Month_Date)   
         
  
       IF @Shift_St_Sec > @Shift_En_Sec         
        SET @Shift_End_DateTime = cast(cast(@Temp_Date as varchar(11)) + ' ' + @Shift_End_Time  as smalldatetime)        
       else        
        SET @Shift_End_DateTime = cast(cast(@Temp_Month_Date as varchar(11)) + ' ' + @Shift_End_Time  as smalldatetime)        
         
        
        ----Hardik 09/05/2016  
        --IF CONVERT(varchar(5), @Shift_St_Time, 108) > CONVERT(varchar(5), @Shift_End_Time, 108)  
        --BEGIN  
         SET @Half_Shift_St_Time = NULL;  
         SET @Half_WeekDay = NULL;  
         SET @Is_Half_Day = NULL;  
         SET @Half_Shift_End_Time = NULL;  
           
         SET @Temp_Month_Date = dateadd(day,1,@Temp_Month_Date)  
           
         Exec SP_CURR_T0100_EMP_SHIFT_GET @curEmp_ID,@Cmp_ID,@Temp_Month_Date,@Shift_St_Time_Next_Day output,@Shift_End_Time_Next_Day output,@Shift_Dur_N_Next_Day output,null,null,null,null,@Shift_Id_N_Next_Day output,@Is_Half_Day OUTPUT, @Half_WeekDay OUTPUT, @Half_Shift_St_Time OUTPUT, @Half_Shift_End_Time OUTPUT   
           
           
         IF DATENAME(WEEKDAY, @Temp_Month_Date) = @Half_WeekDay AND @Is_Half_Day = 1 AND @Half_Shift_St_Time IS NOT NULL  
          BEGIN  
           SET @Shift_St_Time_Next_day = dbo.F_Return_HHMM(@Half_Shift_St_Time);  
           SET @Shift_End_Time_Next_day = dbo.F_Return_HHMM(@Half_Shift_End_Time);             
          END           
           
         SET @Shift_St_Sec_Next_day = dbo.F_Return_Sec(@Shift_St_Time_Next_day)        
         SET @Shift_En_sec_Next_day = dbo.F_Return_Sec(@Shift_End_Time_Next_day)        
  
         SET @Shift_ST_DateTime_Next_day = cast(cast(@Temp_Month_Date as varchar(11)) + ' ' + @Shift_St_Time_Next_day as smalldatetime)        
         SET @Temp_Date_Next_Day = dateadd(d,1,@Temp_Month_Date)        
           
           
         SET @Add_Hrs_Shift_End_Time = DATEDIFF(hh, @Shift_End_DateTime, @Shift_ST_DateTime_Next_day)  
           
         IF @Shift_St_Sec_Next_day > @Shift_En_sec_Next_day         
          SET @Shift_End_DateTime_Next_day = cast(cast(@Temp_Date_Next_Day as varchar(11)) + ' ' + @Shift_End_Time_Next_day  as smalldatetime)        
         else        
          SET @Shift_End_DateTime_Next_day = cast(cast(@Temp_Month_Date as varchar(11)) + ' ' + @Shift_End_Time_Next_day  as smalldatetime)        
           
         SET @Temp_Month_Date = dateadd(day,-1,@Temp_Month_Date)  
           
  
           
         IF datediff(SECOND,@Shift_End_DateTime,@Shift_ST_DateTime_Next_day) <= 3600  
          SET @Add_Hrs_Shift_End_Time = datediff(SECOND,@Shift_End_DateTime,@Shift_ST_DateTime_Next_day)/3600  
           
         IF @Add_Hrs_Shift_End_Time <= 0  
          SET @Add_Hrs_Shift_End_Time = 1            
           
           
         IF @Add_Hrs_Shift_End_Time > 10  
          SET @Add_Hrs_Shift_End_Time = Case When @Add_Hrs_Shift_End_Time > 16 Then 16 ELSE @Add_Hrs_Shift_End_Time END - 5;  
           
           
         --Scope Hours cannot be greater than difference of next shift start time but, there should not be continue shift.  
         IF DateDiff(hh,@Shift_End_Datetime,@Shift_ST_DateTime_Next_day) > 1   
          AND @Add_Hrs_Shift_End_Time >= DateDiff(hh,@Shift_End_Datetime,@Shift_ST_DateTime_Next_day)  
          SET @Add_Hrs_Shift_End_Time = DateDiff(hh,@Shift_End_Datetime,@Shift_ST_DateTime_Next_day)  - 1  
         --select @Shift_St_Time_Next_Day,@Shift_End_Time_Next_Day,@Shift_ST_DateTime_Next_day,@Shift_End_DateTime_Next_day,@Shift_End_DateTime  
        --END  
  
        SET @cBrh = NULL;  
        SET @First_In_Last_Out_For_InOut_Calculation = NULL;  
        SET @Chk_otLimit_before_after_Shift_time = NULL;  
          
          
        SELECT @cBrh  = Branch_ID from T0095_Increment EI where Increment_Effective_Date in (select max(Increment_effective_Date) as Increment_effective_Date   
        from T0095_Increment  where Increment_Effective_date <= @To_Date  and Cmp_ID = @Cmp_ID and Emp_ID = @curEmp_ID) and Emp_ID = @curEmp_ID  
          
          
        select @First_In_Last_Out_For_InOut_Calculation  = First_In_Last_Out_For_InOut_Calculation,@Chk_otLimit_before_after_Shift_time=Chk_otLimit_before_after_Shift_time,@Is_OT = ISNULL(Is_OT,0)  
        from dbo.T0040_GENERAL_SETTING WITH (NOLOCK)  where Branch_ID = @cBrh  and For_Date in (select MAX(For_Date) as for_date from dbo.T0040_GENERAL_SETTING WITH (NOLOCK)  
		where For_Date <= @To_Date and Cmp_ID = Cmp_ID and Branch_ID = @cBrh) and Cmp_ID = @Cmp_ID     
          
          
        IF NOT EXISTS(SELECT 1 FROM #EMP_GEN_SETTINGS WHERE EMP_ID=@curEmp_ID)  
         INSERT INTO #EMP_GEN_SETTINGS VALUES (@curEmp_ID,@cBrh,@First_In_Last_Out_For_InOut_Calculation,@Chk_otLimit_before_after_Shift_time);  
          
        --Hardik 28/04/2017     
        IF Isnull(@First_In_Last_OUT_Flag,0)=1  
         SET @First_In_Last_Out_For_InOut_Calculation= 1  
     
	 
        IF @First_In_Last_Out_For_InOut_Calculation = 1  
         Begin   

          --SET @buffer_Shift_Start_Time_Hrs = 0;  
          --SET @buffer_Shift_Start_Time_Hrs = DATEDIFF(hh,@PREVIOUS_END_TIME,@Shift_St_Datetime)                    
            --if @temp_month_Date = '2018-01-19' and object_id('tempdb..#tmp') is not null  
            -- begin  --NMS   
            --  SELECT 1  
            -- end  
		
          INSERT INTO #Data (Emp_ID,For_Date,Duration_In_sec,Emp_OT,Emp_OT_min_Limit,Emp_OT_max_Limit,In_Time,Shift_Start_Time,Shift_End_Time,OT_Start_Time,Shift_Change,Chk_By_Superior
		  ,IO_Tran_Id,OUT_Time,Shift_ID,Working_sec_Between_Shift)          
          SELECT Emp_Id,Shift_St_Datetime,datediff(SECOND,min (In_Time), max(OUT_Time)) as Duration_In_sec,Emp_OT,Emp_OT_min_Limit,  
            Emp_OT_max_Limit, min(Qry.In_Time) As In_Time,Shift_Start_Time,@Shift_End_DateTime As Shift_End_Time,OT_Start_Time,Shift_Change,Chk_By_Superior,IO_Tran_Id,  
            Max(OUT_Time) as OUT_Time,Shift_ID,0 --,WorkingSecShift
			--,sum(datediff(SECOND,min(Shift_St_Datetime), Case When IsNull(In_Time, '1900-01-01 00:00') <> IsNull(OUT_Time, '1900-01-01 00:00') THEN min(OUT_Time) ELSE NULL END))  -- Comment by deepal for getting error 06052022
          FROM (             
             SELECT DISTINCT EC.Emp_ID ,Cast(@Shift_St_Datetime as varchar(11)) as Shift_St_Datetime,  
             ISNULL(DATEDIFF(s,In_Date,IsNUll(Out_Date,In_Date)),0) as Duration_In_sec,  
             Case When @Is_OT = 0 Then @Is_OT Else isnull(Emp_OT,0)End as Emp_OT ,dbo.F_Return_Sec(Emp_OT_min_Limit) as Emp_OT_min_Limit,  
             dbo.F_Return_Sec(Emp_OT_max_Limit) as Emp_OT_max_Limit,  
             In_Date as In_Time,@Shift_ST_DateTime as Shift_Start_Time,0 as OT_Start_Time,0 as Shift_Change,isnull(Q3.Chk_By_Sup,0) as Chk_By_Superior,0 as IO_Tran_Id,  
             Case When IsNull(IN_Date, '1900-01-01 00:00') <> IsNull(Out_Date, '1900-01-01 00:00') THEN Out_Date ELSE NULL END as OUT_Time, @Shift_Id_N as Shift_ID  
			-- ,sum(datediff(SECOND,min(@Shift_ST_DateTime), Case When IsNull(IN_Date, '1900-01-01 00:00') <> IsNull(Out_Date, '1900-01-01 00:00') THEN min(Out_Date) ELSE NULL END))  as WorkingSecShift
             FROM #Emp_Cons Ec   
               INNER JOIN (  
                  SELECT I.Increment_ID,I.Emp_ID,Emp_OT,isnull(Emp_OT_min_Limit,'00:00')Emp_OT_min_Limit,isnull(Emp_OT_max_Limit,'00:00')Emp_OT_max_Limit   
                  FROM dbo.T0095_Increment  I WITH (NOLOCK)   Where  Emp_ID=@curEmp_ID  
                  ) IQ on EC.Emp_ID=IQ.emp_ID AND IQ.Increment_ID = EC.Increment_ID  
               LEFT OUTER JOIN (  
                  SELECT Emp_Id, Min(In_Time) In_Date   
                  FROM #TMP_EMP_0150_INOUT   
                  WHERE In_Time >= (CASE WHEN DATEDIFF(hh,@PREVIOUS_END_TIME,@Shift_St_Datetime) > 5 THEN DateAdd(hh,-5,@Shift_St_Datetime) ELSE @PREVIOUS_END_TIME END)   
                    --AND  In_Time <= Dateadd(hh,20,@Shift_St_Datetime)    
                    AND  In_Time <= Case When @Shift_ST_DateTime_Next_day < Dateadd(hh,20,@Shift_St_Datetime)  Then DateAdd(hh, -5, @Shift_ST_DateTime_Next_day) Else Dateadd(hh,20,@Shift_St_Datetime) END  
                    AND Emp_ID=@curEmp_ID  
                  Group By Emp_Id  
                  ) Q1 ON EC.Emp_Id = Q1.Emp_Id                 
               LEFT OUTER JOIN   
                  (  
                  SELECT ISNULL(T1.EMP_ID, T2.EMP_ID) AS EMP_ID,   
                    (CASE WHEN (DATEDIFF(HH, @Shift_End_Datetime, Min_Out_Date) > @Add_Hrs_Shift_End_Time   
                       AND Max_Out_Date IS NOT NULL AND @Add_Hrs_Shift_End_Time < 2) OR Min_Out_Date IS NULL  
                     THEN   
                      Max_Out_Date   
                     ELSE   
                      Min_Out_Date   
                    END) AS OUT_DATE  
                  FROM (  
                     SELECT Emp_Id, (CASE WHEN (DATEDIFF(hh, @Shift_End_Datetime, @Shift_ST_DateTime_Next_day) >= @Add_Hrs_Shift_End_Time) THEN  
                          MAX(IsNull(Out_Time,In_Time)) --Commented by Hardik 30/11/2017 for RKM and AIA as In Time and Out time is showing Same time (If you comment the ODD punch case will not work (ie. missing out punch case, last in punch should be considered as out punch)  
                          --MAX(Out_Time)  
                         ELSE  
                          --Min(Out_Time)  
                          Min(IsNull(Out_Time,In_Time))  --Commented by Hardik 30/11/2017 for RKM and AIA as In Time and Out time is showing Same time  
                         END) Min_Out_Date   
                     From #TMP_EMP_0150_INOUT   
                     Where --Out_Time >= @Shift_End_Datetime   --Change > to >= for Continuous shift 11-7 and 7-5.  
                       IsNull(Out_Time,In_Time) > @Shift_End_Datetime  --Commented by Hardik 30/11/2017 for RKM and AIA as In Time and Out time is showing Same time  
                       AND Emp_ID=@curEmp_ID  
                       AND (CASE WHEN (DATEDIFF(hh, @Shift_End_Datetime, @Shift_ST_DateTime_Next_day) >= @Add_Hrs_Shift_End_Time) THEN  
                         DateAdd(hh,@Add_Hrs_Shift_End_Time,@Shift_End_Datetime)  
                         ELSE  
                         DATEADD(n, 1, IsNull(IN_TIME, Out_Time))  
                         END) > IsNull(IN_TIME, Out_Time)  
                       --AND OUT_TIME < DateAdd(hh,1, @Shift_ST_DateTime_Next_day) --Out Time is not considering if out punch is taken after shift start  
                       AND IsNull(OUT_TIME,In_Time) < DateAdd(hh,1, @Shift_ST_DateTime_Next_day)  --Commented by Hardik 30/11/2017 for RKM and AIA as In Time and Out time is showing Same time  
                     Group By Emp_Id  
                     ) T1   
                     FULL JOIN ( SELECT Emp_Id,   
                          Max(IsNull(Out_Time,In_Time)) Max_Out_Date --Commented by Hardik 30/11/2017 for RKM and AIA as In Time and Out time is showing Same time  
                          --Max(Out_Time) Max_Out_Date   
                        From #TMP_EMP_0150_INOUT   
                        Where --Out_Time <= @Shift_End_Datetime   
                          IsNull(Out_Time,In_Time) <= @Shift_End_Datetime --Commented by Hardik 30/11/2017 for RKM and AIA as In Time and Out time is showing Same time  
                          AND Emp_ID=@curEmp_ID  
                          AND IsNull(Out_Time,In_Time) >  @PREVIOUS_END_TIME AND (ABS(DATEDIFF(HH, IsNull(Out_Time,In_Time), @Shift_End_Datetime)) < 20) --Commented by Hardik 30/11/2017 for RKM and AIA as In Time and Out time is showing Same time  
                          --AND Out_Time >  @PREVIOUS_END_TIME AND (ABS(DATEDIFF(HH,Out_Time, @Shift_End_Datetime)) < 20)  
                        Group By Emp_Id  
                       ) T2 ON T1.EMP_ID=T2.EMP_ID  
                  ) Q2 ON EC.Emp_Id = Q2.Emp_Id                               
               LEFT OUTER JOIN   
                  (  
                  SELECT DISTINCT Emp_ID,Chk_By_Superior Chk_By_Sup,For_Date   
                  FROM #TMP_EMP_0150_INOUT   
                  WHERE Chk_By_Superior <> 0 And Emp_ID=@curEmp_ID And For_Date BETWEEN @from_Date And @To_date  
                  ) Q3 ON EC.Emp_Id = Q3.Emp_Id  And CAST(CAST(@Shift_St_Datetime AS VARCHAR(11))AS DATETIME) = Q3.For_Date  
             WHERE ec.Emp_ID = @curEmp_ID   
               And (  
                 CASE WHEN (CONVERT(varchar(5), @Shift_St_Time, 108) > CONVERT(varchar(5), @Shift_End_Time, 108) AND In_Date IS NULL AND DATEDIFF(hh, @Shift_ST_DateTime, OUT_DATE) > 20)   
                    OR (CONVERT(varchar(5), @Shift_St_Time, 108) > CONVERT(varchar(5), @Shift_End_Time, 108) AND OUT_DATE IS NULL AND DATEDIFF(hh, @Shift_ST_DateTime, In_Date) > 12) THEN  
                  0  
                 ELSE  
                  1  
                 END  = 1  
                )  
				GROUP BY EC.Emp_ID,Emp_OT,Emp_OT_min_Limit,Emp_OT_max_Limit,out_Date,Chk_By_Sup,In_Date --,WorkingSecShift
            ) Qry  
          WHERE (OUT_Time IS NOT NULL OR In_Time IS NOT NULL)  
          GROUP BY Emp_Id,Shift_St_Datetime,Emp_OT,Emp_OT_min_Limit,  
             Emp_OT_max_Limit, Shift_Start_Time,OT_Start_Time,Shift_Change,Chk_By_Superior,IO_Tran_Id,Shift_ID  
          ORDER BY Cast(Shift_St_Datetime as varchar(11))  
  
            
             
         End   
           
             
         ------------------end--------------------  
        Else  
         Begin  
          
          IF CONVERT(varchar(5), @Shift_St_Time, 108) < CONVERT(varchar(5), @Shift_End_Time, 108)  
           Begin   
                          
            INSERT INTO #Data (Emp_ID,For_Date,Duration_In_sec,Emp_OT,Emp_OT_min_Limit,Emp_OT_max_Limit,In_Time,Shift_Start_Time,OT_Start_Time,Shift_Change,Chk_By_Superior,IO_Tran_Id,OUT_Time,Shift_Id)          
            SELECT EIR.Emp_ID ,EIR.for_Date,SUM(ISNULL(DATEDIFF(s,in_time,out_time),0)) ,Case When @Is_OT = 0 Then @Is_OT Else isnull(Emp_OT,0)End,  
              dbo.F_Return_Sec(Emp_OT_min_Limit),dbo.F_Return_Sec(Emp_OT_max_Limit),In_Time,null,0,0,Chk_By_Superior,isnull(EIR.is_cmp_purpose ,0),  
              Out_Time ,@Shift_Id_N  
            FROM #TMP_EMP_0150_INOUT EIR Inner join #Emp_Cons Ec on EIR.Emp_Id = ec.Emp_ID inner Join     
              (  
              SELECT I.Increment_ID,I.Emp_ID,Emp_OT,ISNULL(Emp_OT_min_Limit,'00:00')Emp_OT_min_Limit,isnull(Emp_OT_max_Limit,'00:00')Emp_OT_max_Limit   
              FROM dbo.T0095_Increment I  WITH (NOLOCK)   
              ) IQ on EIR.Emp_ID = IQ.emp_ID AND IQ.Increment_ID=EC.Increment_ID  
                           
            WHERE cmp_Id= @Cmp_ID AND EIR.for_Date =@Temp_Month_Date AND ec.Emp_ID = @curEmp_ID  
            GROUP BY EIR.Emp_ID,EIR.For_Date,Emp_OT,Emp_OT_min_Limit,Emp_OT_max_Limit,In_Time,Chk_By_Superior ,EIR.is_cmp_purpose,Out_Time    
            ORDER BY EIR.For_Date  
              
              
           End  
          Else  
           BEGIN    
                                  
            INSERT INTO #Data(Emp_ID,For_Date,Duration_In_sec,Emp_OT,Emp_OT_min_Limit,Emp_OT_max_Limit,In_Time,  
              Shift_Start_Time,Shift_ID,OT_Start_Time,Shift_Change,Chk_By_Superior,IO_Tran_Id,OUT_Time)                           
            SELECT EIR.Emp_ID ,  
              CAST(@Shift_St_Datetime AS VARCHAR(11)),  
              SUM(ISNULL(DATEDIFF(s,in_time,out_time),0)),  
              ISNULL(Emp_OT,0),dbo.F_Return_Sec(Emp_OT_min_Limit),dbo.F_Return_Sec(Emp_OT_max_Limit),In_Time,  
              @Shift_St_Time,@Shift_Id_N,0,0,Chk_By_Superior,ISNULL(EIR.is_cmp_purpose ,0),Out_Time  
            FROM #TMP_EMP_0150_INOUT  EIR   
              INNER JOIN #Emp_Cons Ec ON EIR.Emp_Id = ec.Emp_ID   
              INNER JOIN (  
                 SELECT I.Increment_ID,I.Emp_ID,Emp_OT,ISNULL(Emp_OT_min_Limit,'00:00')Emp_OT_min_Limit,  
                   ISNULL(Emp_OT_max_Limit,'00:00')Emp_OT_max_Limit   
                 FROM T0095_Increment  I WITH (NOLOCK)   
                 ) IQ ON EIR.Emp_ID = IQ.emp_ID AND IQ.Increment_ID=EC.Increment_ID                           
            WHERE cmp_Id= @Cmp_ID   
                
              AND EIR.In_Time >=Dateadd(hh,-5,@Shift_St_Datetime)   
              AND EIR.Out_Time <=Dateadd(hh,5,@Shift_End_Datetime)   
                
            GROUP BY EIR.Emp_ID,Emp_OT,Emp_OT_min_Limit,Emp_OT_max_Limit,In_Time,Chk_By_Superior ,EIR.is_cmp_purpose,Out_Time    
            ORDER BY Cast(@Shift_St_Datetime as varchar(11))  
  
              
           End             
         End  
           
        
      SET @PREVIOUS_END_TIME = CASE WHEN ISNULL(@PREVIOUS_END_TIME, '1900-01-01') >  @Temp_Month_Date THEN @PREVIOUS_END_TIME ELSE @Temp_Month_Date END ;  
  
        
      SELECT @PREVIOUS_END_TIME = COALESCE(OUT_TIME,DATEADD(n,1,In_Time), @PREVIOUS_END_TIME)  
      FROM #DATA   
      WHERE EMP_ID=@curEmp_ID AND FOR_DATE=@Temp_Month_Date  
      SET @Temp_Month_Date = Dateadd(d,1,@Temp_Month_Date)         
     END                  
       
     FETCH NEXT FROM curNightShift INTO @curEmp_ID  
    END  
   CLOSE curNightShift                      
   DEALLOCATE curNightShift  
        
   --Update #Data SET Shift_ID= null   
   Delete From #Data Where For_Date = DateAdd(dd,-1, @From_Date)  
  END  
 ELSE  
  BEGIN   
   declare @Max_OT_Limit int  
   declare @Min_OT_Limit int  
    
  
   DECLARE curBranch CURSOR FAST_FORWARD FOR  
   SELECT DISTINCT Branch_ID FROM #EMP_CONS  
   OPEN curBranch   
   FETCH NEXT FROM curBranch INTO @cBrh  
   WHILE @@FETCH_STATUS = 0  
    BEGIN  
     --print 'loop 1: ' + convert(varchar(20), getdate(), 114)  
     SET @First_In_Last_Out_For_InOut_Calculation = NULL;  
     SET @Chk_otLimit_before_after_Shift_time = NULL;       
     SET @Is_OT = 1;  
       
     SELECT @First_In_Last_Out_For_InOut_Calculation  = First_In_Last_Out_For_InOut_Calculation,  
       @Is_OT = CASE WHEN @Is_OT = 0 THEN 0 ELSE ISNULL(Is_OT,0) END,  
       @Chk_otLimit_before_after_Shift_time=Chk_otLimit_before_after_Shift_time  
     FROM dbo.T0040_GENERAL_SETTING G WITH (NOLOCK)   
       INNER JOIN (SELECT Branch_ID, Max(For_Date) As For_Date  
          FROM dbo.T0040_GENERAL_SETTING G1 WITH (NOLOCK)   
          WHERE G1.For_Date <= @To_Date  
          Group By Branch_ID) G1 ON G.Branch_ID=G1.Branch_ID And G.For_Date=G1.For_Date  
     WHERE G.Branch_ID = @cBrh    
     SET @First_In_Last_Out_For_InOut_Calculation_Actual = @First_In_Last_Out_For_InOut_Calculation  
       
     IF NOT EXISTS(SELECT 1 FROM #EMP_GEN_SETTINGS WHERE BRANCH_ID=@cBrh)  
      INSERT INTO #EMP_GEN_SETTINGS   
      SELECT distinct EMP_ID,@cBrh,@First_In_Last_Out_For_InOut_Calculation,@Chk_otLimit_before_after_Shift_time  
      FROM #EMP_CONS  
      WHERE BRANCH_ID=@cBrh  
      --VALUES (@curEmp_ID,@cBrh,@First_In_Last_Out_For_InOut_Calculation,@Chk_otLimit_before_after_Shift_time);  
     
       
     --Hardik 28/04/2017     
     IF Isnull(@First_In_Last_OUT_Flag,0)=1  
      SET @First_In_Last_Out_For_InOut_Calculation= 1  
  
        
     IF @First_In_Last_Out_For_InOut_Calculation = 1  
      BEGIN    
  
         --print 'code 2'  
         INSERT INTO #Data (Emp_ID,For_Date,Duration_In_sec,Emp_OT,Emp_OT_min_Limit,Emp_OT_max_Limit,  
              In_Time,Shift_Start_Time,OT_Start_Time,Shift_Change,Chk_By_Superior,IO_Tran_Id,OUT_Time, Shift_ID)  
           
         SELECT EMP_ID,For_Date,ISNULL( DATEDIFF(S, IN_TIME, OUT_TIME),0) AS Duration, Emp_OT ,Emp_OT_min_Limit,Emp_OT_max_Limit,  
              In_Time,null,0,0,Chk_By_Sup, is_cmp_purpose,OUT_Time,dbo.fn_get_Shift_From_Monthly_Rotation(@Cmp_ID,Emp_ID,For_Date) As Shift_ID  
         FROM (  
            SELECT DISTINCT EIR.Emp_ID ,EIR.for_Date,  
              Case When @Is_OT = 1 Then I.Emp_OT Else 0 End  As Emp_OT,  
              dbo.F_Return_Sec(isnull(I.Emp_OT_min_Limit,'00:00')) Emp_OT_min_Limit,dbo.F_Return_Sec(isnull(I.Emp_OT_max_Limit,'00:00')) Emp_OT_max_Limit,  
              cast(CONVERT(varchar(16),Q1.In_Date,120)as datetime) As In_Time,isnull(Q3.Chk_By_Sup,0) As Chk_By_Sup,isnull(EIR.is_cmp_purpose ,0) As is_cmp_purpose,  
              CASE WHEN CAST(CONVERT(varchar(16),Max_In_Date,120)as datetime) > CAST(CONVERT(varchar(16),Out_Date,120)as datetime) Then cast(CONVERT(varchar(16),Max_In_Date,120)as datetime) Else cast(CONVERT(varchar(16),Out_Date,120)as datetime) End As Out_Time  
            FROM #TMP_EMP_0150_INOUT  EIR   
              INNER JOIN #Emp_Cons Ec on EIR.Emp_Id = EC.Emp_ID   
              INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK)  on EIR.Emp_ID=EM.Emp_ID and EIR.Cmp_ID=EM.Cmp_ID               
              INNER JOIN T0095_INCREMENT I WITH (NOLOCK)  ON EC.Increment_ID=I.Increment_ID  
              INNER JOIN (  
                 SELECT T.Emp_Id, Min(In_Time) In_Date,For_Date   
                 FROM #TMP_EMP_0150_INOUT T  
                   INNER JOIN #EMP_CONS EC ON T.EMP_ID=EC.EMP_ID AND EC.BRANCH_ID = @cBrh  
                 --WHERE Emp_ID = @curEmp_ID   
                 Group By T.Emp_Id,For_Date  
                 ) Q1 ON EIR.Emp_Id = Q1.Emp_Id AND EIR.For_Date = Q1.For_Date  
              INNER JOIN (  
                 SELECT T.Emp_Id, Max(Out_Time) Out_Date,For_Date   
                 FROM #TMP_EMP_0150_INOUT T  
                   INNER JOIN #EMP_CONS EC ON T.EMP_ID=EC.EMP_ID AND EC.BRANCH_ID = @cBrh  
                 --WHERE Emp_ID = @curEmp_ID   
                 Group By T.Emp_Id,For_Date) Q2 ON EIR.Emp_Id = Q2.Emp_Id AND EIR.For_Date = Q2.For_Date  
              INNER JOIN  
                 --Added by Hardik 23/07/2012 for First IN And Last OUT (it will take Max In Punch as OUT and calculate Hours)  
                 (  
                 SELECT T.Emp_Id, Max(In_Time) Max_In_Date,For_Date   
                 FROM #TMP_EMP_0150_INOUT T  
                   INNER JOIN #EMP_CONS EC ON T.EMP_ID=EC.EMP_ID AND EC.BRANCH_ID = @cBrh  
                 --WHERE  Emp_ID = @curEmp_ID   
                 Group By T.Emp_Id,For_Date  
                 ) Q4 ON EIR.Emp_Id = Q4.Emp_Id AND EIR.For_Date = Q4.For_Date  
              LEFT OUTER JOIN   
                 (  
                 SELECT T.Emp_ID,Max(Chk_By_Superior) Chk_By_Sup,For_Date   
                 FROM #TMP_EMP_0150_INOUT T  
                   INNER JOIN #EMP_CONS EC ON T.EMP_ID=EC.EMP_ID AND EC.BRANCH_ID = @cBrh  
                 WHERE Chk_By_Superior=1 --and Emp_ID = @curEmp_ID  
                 GROUP BY T.Emp_ID,For_Date   
                 ) Q3 ON EIR.Emp_Id = Q3.Emp_Id AND EIR.For_Date = Q3.For_Date  
            WHERE EIR.cmp_Id= @Cmp_ID AND EIR.for_Date >=@From_Date   
              AND EIR.For_Date <=@To_Date AND ec.Branch_ID = @cBrh               
            GROUP BY EIR.Emp_ID,EIR.For_Date,In_Time,In_Date,out_Date,Chk_By_Sup ,EIR.is_cmp_purpose,  
               OUT_Time,Max_In_Date,I.Emp_OT_min_Limit,I.Emp_OT_max_Limit,I.Emp_OT  
              
           ) T  
         ORDER BY T.For_Date  
                   
       ------------------end--------------------                   
      End  
     ELSE  
      BEGIN  
       
	   
       INSERT INTO #Data (Emp_ID,For_Date,Duration_In_sec,Emp_OT,Emp_OT_min_Limit,Emp_OT_max_Limit,In_Time,Shift_Start_Time,OT_Start_Time,Shift_Change  
       ,Chk_By_Superior,IO_Tran_Id,OUT_Time,Shift_ID)     
	   
       SELECT EIR.Emp_ID ,EIR.for_Date,        
         SUM(ISNULL(DATEDIFF(s,CAST(CONVERT(VARCHAR(16),In_Time,120) AS DATETIME),CAST(CONVERT(VARCHAR(16),out_time,120) AS DATETIME)),0)) ,  
         Case When @Is_OT = 0 Then @Is_OT Else isnull(Emp_OT,0)End,dbo.F_Return_Sec(Emp_OT_min_Limit),dbo.F_Return_Sec(Emp_OT_max_Limit),  
          -- CAST(CONVERT(VARCHAR(16),In_Time,120) AS DATETIME)/*In_Time*/ -- commented by Deepal 11102021  
           CAST(CONVERT(VARCHAR(16),isnull(In_Date_Time,In_Time),120) AS DATETIME)  
         ,null,0,0,Chk_By_Superior,ISNULL(EIR.is_cmp_purpose ,0)  
         
		 --,CAST(CONVERT(VARCHAR(16),Out_Time,120) AS DATETIME)/*Out_Time*/ -- commented by Deepal 11102021  
         
		 ,CAST(CONVERT(VARCHAR(16),isnull(Out_Date_Time,Out_Time),120) AS DATETIME)  

         ,dbo.fn_get_Shift_From_Monthly_Rotation(@Cmp_ID,EIR.Emp_ID,EIR.for_Date) As Shift_ID  
       FROM #TMP_EMP_0150_INOUT  EIR   
         INNER JOIN #Emp_Cons Ec ON EIR.Emp_Id = ec.Emp_ID   
         INNER JOIN (  
            SELECT I.Increment_ID,I.Emp_ID,Emp_OT, ISNULL(Emp_OT_min_Limit,'00:00')Emp_OT_min_Limit, ISNULL(Emp_OT_max_Limit,'00:00') Emp_OT_max_Limit   
            FROM dbo.T0095_Increment  I  WITH (NOLOCK)   
            ) IQ on EIR.Emp_ID = IQ.emp_ID AND IQ.Increment_ID=EC.Increment_ID  
         INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK)  ON EC.EMP_ID=EM.EMP_ID  
       WHERE EM.Cmp_ID= @Cmp_ID AND EIR.for_Date >= @From_Date AND EIR.For_Date <=@To_Date   
         AND ec.Branch_ID = @cBrh   
         --ec.Emp_ID = @curEmp_ID  
         --AND EIR.For_Date <= ISNULL(Em.Emp_Left_Date,@To_Date)          
       GROUP BY EIR.Emp_ID,EIR.For_Date,Emp_OT,Emp_OT_min_Limit,Emp_OT_max_Limit  
       ,In_Time,Out_Time    
       ,Chk_By_Superior ,EIR.is_cmp_purpose  
       ,In_Date_Time,Out_Date_Time  
       ORDER BY EIR.For_Date          
      END  
  
  
       
     FETCH NEXT FROM curBranch INTO @cBrh  
    END  
   CLOSE curBranch  
   DEALLOCATE curBranch  
      
  END  
   
   
 INSERT INTO #Data (Emp_ID,For_Date,Duration_In_sec,Emp_OT,Emp_OT_min_Limit,Emp_OT_max_Limit,In_Time,Shift_Start_Time,OT_Start_Time,Shift_Change,Chk_By_Superior,IO_Tran_Id,OUT_Time,Shift_Id)          
 SELECT EIR.Emp_ID,EIR.FOR_DATE,SUM(ISNULL(DATEDIFF(s,EIR.in_time,EIR.out_time),0)),0,  
   dbo.F_Return_Sec(IQ.Emp_OT_min_Limit),dbo.F_Return_Sec(IQ.Emp_OT_max_Limit),EIR.In_Time,null,0,0,1,isnull(EIR.is_cmp_purpose ,0),  
   EIR.Out_Time,dbo.fn_get_Shift_From_Monthly_Rotation(@Cmp_ID,EIR.Emp_ID,EIR.For_Date) AS Shift_ID  
 FROM (  
    SELECT EIR.EMP_ID, EIR.FOR_DATE, MIN(EIR.IN_TIME) AS IN_TIME, MAX(EIR.OUT_TIME) AS OUT_TIME,MAX(EIR.is_cmp_purpose) AS is_cmp_purpose  --Put Max() in is_cmp_purpose field to avoid multiple records when there are both records exists in table in continue shift case.  
    FROM #TMP_EMP_0150_INOUT EIR INNER JOIN #EMP_CONS E ON EIR.EMP_ID=E.EMP_ID  
    WHERE EIR.FOR_DATE BETWEEN @FROM_DATE AND @TO_DATE AND EIR.Chk_By_Superior=1  
    GROUP BY EIR.EMP_ID,EIR.FOR_DATE  
   ) EIR   
   INNER JOIN #Emp_Cons Ec ON EIR.Emp_Id = ec.Emp_ID   
   INNER JOIN (  
      SELECT I.Increment_ID,I.Emp_ID,Emp_OT, ISNULL(Emp_OT_min_Limit,'00:00')Emp_OT_min_Limit, ISNULL(Emp_OT_max_Limit,'00:00') Emp_OT_max_Limit   
      FROM dbo.T0095_Increment  I  WITH (NOLOCK)   
      ) IQ on EIR.Emp_ID = IQ.emp_ID AND IQ.Increment_ID=EC.Increment_ID  
   LEFT OUTER JOIN #DATA D ON EIR.EMP_ID=D.EMP_ID AND EIR.FOR_DATE = D.FOR_DATE  
   INNER JOIN T0080_EMP_MASTER EM  WITH (NOLOCK) ON EC.EMP_ID=EM.EMP_ID  
 WHERE D.EMP_ID IS NULL  
   --AND EIR.For_Date <= ISNULL(Em.Emp_Left_Date,@To_Date)          
 GROUP BY EIR.Emp_ID,EIR.For_Date,IQ.Emp_OT,IQ.Emp_OT_min_Limit,IQ.Emp_OT_max_Limit,EIR.In_Time,EIR.is_cmp_purpose,EIR.Out_Time    
 ORDER BY EIR.For_Date   
    
    
  
 DELETE D   
 FROM #Data D   
   INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK)  ON D.Emp_Id=E.Emp_ID  
 WHERE (D.For_date < E.Date_Of_Join OR D.For_date > ISNULL(E.EMP_LEFT_DATE, @TO_DATE))  
  
     
 DELETE D   
 FROM #Data D   
 WHERE In_Time IS NULL AND OUT_Time IS NULL  
  
   
 --Start commented by Deepal 11102021  
 --UPDATE D  
 --SET  IO_Tran_Id=isnull(EIR.is_cmp_purpose ,0),  
 --  In_Time = CASE WHEN Is_Default_In = 1 THEN Null ELSE d.In_Time END,  --- Added by Hardik 18/07/2020 for Emerland Honda as they don't want to show default inserted time   
 --  OUT_Time = CASE WHEN Is_Default_Out = 1 THEN Null ELSE d.Out_Time END --- Added by Hardik 18/07/2020 for Emerland Honda as they don't want to show default inserted time  
 --FROM #Data D INNER JOIN #TMP_EMP_0150_INOUT EIR ON D.Emp_Id=EIR.Emp_ID AND D.For_date=EIR.For_Date  
 --END commented by Deepal 11102021  
  
 Update D  
 SET  Duration_in_sec = DateDiff(s, In_Time, Out_Time)  
 FROM #Data D  
  
     
  IF Isnull(@IsNight,0) = 0  
   BEGIN   
    /*GETTING SHIFT DETAIL*/  
    /*DECLARE @ROWCOUNT BIGINT  
    SET @ROWCOUNT = CAST(DATEDIFF(D,@FROM_DATE, @TO_DATE) AS BIGINT)+1  
    SET ROWCOUNT @ROWCOUNT;*/  
      
      
    SELECT @FROM_DATE = Min(For_date), @To_date = Max(For_date)  
    FROM #Data  
      
    SELECT ROW_ID, DATEADD(D, ROW_ID-1, @FROM_DATE) AS FOR_DATE  
    INTO #SHIFT_DATE  
    FROM (SELECT ROW_NUMBER() OVER(ORDER BY OBJECT_ID) AS ROW_ID  
       FROM sys.tables ) t  
    WHERE ROW_ID <= CAST(DATEDIFF(D,@FROM_DATE, @TO_DATE) AS BIGINT)+1  
    /*SET ROWCOUNT  0*/  
  
  
  
    CREATE TABLE #EMP_SHIFT_DETAIL  
    (  
     EMP_ID  NUMERIC,  
     FOR_DATE DATETIME,  
     SHIFT_ID NUMERIC,  
     START_TIME DATETIME,  
     END_TIME DATETIME,  
     DURATION VARCHAR(6)  
    )  
    CREATE UNIQUE NONCLUSTERED INDEX IX_EMP_SHIFT_DETAIL ON #EMP_SHIFT_DETAIL(EMP_ID, FOR_DATE)  
  
    INSERT INTO #EMP_SHIFT_DETAIL(EMP_ID,FOR_DATE)  
    SELECT Distinct EMP_ID,FOR_DATE      --added distinct
    FROM #EMP_CONS,#SHIFT_DATE  
  
      
    /*Default Shift*/  
    UPDATE  S  
    SET     SHIFT_ID=dbo.fn_get_Shift_From_Monthly_Rotation(@Cmp_ID,Emp_ID,For_Date)  
    FROM    #EMP_SHIFT_DETAIL S  
      
    --UPDATE S  
    --SET  SHIFT_ID= SD.SHIFT_ID  
    --FROM #EMP_SHIFT_DETAIL S  
    --  INNER JOIN T0100_EMP_SHIFT_DETAIL SD ON S.EMP_ID=SD.EMP_ID  
    --  CROSS APPLY (SELECT SD1.Emp_ID, MAX(SD1.FOR_DATE) AS FOR_DATE  
    --     FROM T0100_EMP_SHIFT_DETAIL SD1  
    --     WHERE ISNULL(SD1.Shift_Type,0) = 0 AND SD1.For_Date <= S.FOR_DATE  
    --       AND SD1.Emp_ID=SD.EMP_ID AND SD1.For_Date=SD.For_Date  
    --     GROUP BY SD1.Emp_ID) SD1   
  
      
    /*Default Shift*/  
    UPDATE S  
    SET  SHIFT_ID= SD.SHIFT_ID  
    FROM #EMP_SHIFT_DETAIL S  
      INNER JOIN T0100_EMP_SHIFT_DETAIL SD WITH (NOLOCK)  ON S.EMP_ID=SD.EMP_ID AND SD.FOR_DATE=S.FOR_DATE  
  
    UPDATE S  
    SET  START_TIME = FOR_DATE + SM.Shift_St_Time,  
      END_TIME = FOR_DATE + CASE WHEN SM.Shift_St_Time > SM.Shift_End_Time THEN 1 ELSE 0 END  + CASE WHEN SM.Is_Half_Day=1 AND SM.Week_Day=DATENAME(WEEKDAY, S.FOR_DATE) THEN SM.Half_End_Time ELSE SM.Shift_End_Time END,  
      DURATION = SM.F_Duration  
    FROM #EMP_SHIFT_DETAIL S  
      INNER JOIN T0040_SHIFT_MASTER SM WITH (NOLOCK)  ON S.SHIFT_ID=SM.Shift_ID  
  
    UPDATE D  
    SET  SHIFT_ID=SD.SHIFT_ID,Shift_Start_Time=SD.START_TIME, Shift_End_Time=SD.END_TIME  
    FROM #Data D  
      INNER JOIN #EMP_SHIFT_DETAIL SD WITH (NOLOCK)  ON D.Emp_Id=SD.EMP_ID AND D.For_date=SD.FOR_DATE  
  
    DROP TABLE #EMP_SHIFT_DETAIL  
   END  
  
   
   
 --Added by Jaina 16-03-2017 Start  
 DECLARE @DIFF_HOUR AS NUMERIC(18,4)  
 SET @DIFF_HOUR = 0   
 SELECT @DIFF_HOUR = CAST(Setting_Value  AS numeric(18,2)) from T0040_SETTING WITH (NOLOCK)  where Cmp_ID=@Cmp_Id and Setting_Name='Remove the Gap Between Two In-Out Punch from Working Hours' and ISNUMERIC(Setting_Value)=1  
        
 IF @DIFF_HOUR > 0  
  BEGIN  
   DECLARE @Total_second AS NUMERIC(18)  
   SET @Total_second = 0  
  
   IF @DIFF_HOUR % 1.00 > 0  
    SET @DIFF_HOUR = (@DIFF_HOUR * 100) / 60;  
  
   CREATE table #Data_EIO_Diff  
   (           
    Emp_Id   NUMERIC ,           
    For_date DATETIME,          
    Out_Time DATETIME,  
    In_Time DATETIME,  
    Diff_Sec NUMERIC  
   )           
   CREATE NONCLUSTERED INDEX ix_Data_temp1_Diff_Emp_Id_For_date ON #Data_EIO_Diff(Emp_Id,For_Date,In_Time);  
    
  
   set @Total_second = (@DIFF_HOUR * 3600)  
   
   --Added by Jaina 16-03-2017 End  
    
   SELECT ROW_NUMBER() OVER(PARTITION BY EIO1.Emp_ID ORDER BY FOR_DATE,ISNULL(IN_TIME, OUT_TIME)) AS ROW_ID, EIO1.Emp_ID,For_Date,In_Time,Out_Time   
   INTO #EIO  
   FROM T0150_EMP_INOUT_RECORD EIO1 WITH (NOLOCK)  INNER JOIN  
     #Emp_Cons Ec ON EIO1.Emp_Id = ec.Emp_ID  
   WHERE --EIO1.Emp_ID = @curEmp_ID  
     EIO1.cmp_Id= @Cmp_ID  and EIO1.for_Date >=@From_Date and EIO1.For_Date <=@To_Date   
  
     
   ;WITH Q(ROW_ID,Emp_ID,For_Date,In_Time,Out_Time,LVL, DIFF,DiffSe) AS  
   (  
    SELECT ROW_ID, EIO1.Emp_ID,For_Date,In_Time,Out_Time, 'U' AS LVL, CAST(NULL AS DATETIME) AS DIFF ,CAST(0 AS INT) AS DiffSe  
    FROM #EIO EIO1  
    WHERE ROW_ID=1  
    UNION ALL  
    SELECT EIO2.ROW_ID,EIO2.Emp_ID,EIO2.For_Date,EIO2.In_Time,EIO2.Out_Time,'D' AS LVL,Q.Out_Time ,CAST(DATEDIFF(S,Q.out_Time,EIO2.In_Time) AS INT) AS DiffSe --CAST(EIO2.In_Time - Q.Out_Time AS DATETIME) AS DIFF  
    FROM #EIO EIO2 INNER JOIN Q ON EIO2.ROW_ID = (Q.ROW_ID + 1) AND Q.Emp_ID=EIO2.Emp_ID  
   )   
   
     
   INSERT INTO #Data_EIO_Diff  
   SELECT Q.Emp_id,Q.For_Date,Q.DIFF,Q.In_Time,Q.DiffSe  
   FROM Q INNER JOIN (SELECT FOR_DATE, EMP_ID FROM Q Where Isnull(Out_Time,'')<>'' GROUP BY EMP_ID,FOR_DATE HAVING COUNT(1) >1 ) Q1 ON Q.FOR_DATE=Q1.FOR_DATE AND Q.EMP_ID=Q1.EMP_ID  ---Isnull(Out_Time,'')<>'' condition added by Hardik 21/07/2017 for Dishman Pharma  
     --INNER JOIN (SELECT MAX(ROW_ID) AS ROW_ID,EMP_ID,FOR_DATE FROM Q GROUP BY FOR_DATE,EMP_ID ) Q2 ON Q.ROW_ID=Q2.ROW_ID and Q2.Emp_ID=Q1.Emp_ID  
   WHERE LVL='D' AND Q.DiffSe <= 36000 AND Q.DiffSe >= @Total_second OPTION(MAXRECURSION 0) --(More thatn 5 Hours)  --Change by Jaina 16-03-2017  
     
   /*Records should not be considered before shift start*/  
   DELETE EIO  
   FROM #Data_EIO_Diff EIO  
     INNER JOIN #Data D ON EIO.Emp_ID=D.Emp_Id AND EIO.For_date=D.For_date  
   WHERE EXISTS (SELECT 1 FROM T0050_SHIFT_DETAIL SD WITH (NOLOCK)  WHERE D.Shift_ID=SD.Shift_ID AND ISNULL(SD.Working_Hrs_St_Time,0) = 1)  
     AND EIO.In_Time < D.Shift_Start_Time  
   /*Records should not be considered after shift end*/  
   DELETE EIO  
   FROM #Data_EIO_Diff EIO  
     INNER JOIN #Data D ON EIO.Emp_ID=D.Emp_Id AND EIO.For_date=D.For_date  
   WHERE EXISTS (SELECT 1 FROM T0050_SHIFT_DETAIL SD WITH (NOLOCK)  WHERE D.Shift_ID=SD.Shift_ID AND ISNULL(SD.Working_Hrs_End_Time,0) = 1)  
     AND EIO.Out_Time > D.Shift_End_Time  
     
   /*Difference should be calculated after shift start only*/  
   UPDATE EIO  
   SET  Out_Time = D.Shift_Start_Time,  
     Diff_Sec = DateDiff(s, D.Shift_Start_Time, EIO.In_Time)  
   FROM #Data_EIO_Diff EIO  
     INNER JOIN #Data D ON EIO.Emp_ID=D.Emp_Id AND EIO.For_date=D.For_date  
   WHERE EXISTS (SELECT 1 FROM T0050_SHIFT_DETAIL SD WITH (NOLOCK)  WHERE D.Shift_ID=SD.Shift_ID AND ISNULL(SD.Working_Hrs_St_Time,0) = 1)  
     AND D.Shift_Start_Time BETWEEN EIO.Out_Time AND EIO.IN_TIME  
  
   if @First_In_Last_Out_For_InOut_Calculation = 1  
    UPDATE D  
    SET  Duration_in_sec = DateDiff(s, D1.In_Time, D1.OUT_Time)  
    FROM #Data D  
      INNER JOIN (SELECT D.Emp_ID,D.For_Date,  
           CASE WHEN From_ST_Start = 1 AND In_Time < Shift_Start_Time Then Shift_Start_Time ELSE D.In_Time END AS In_Time,  
           CASE WHEN To_ST_End = 1  AND OUT_Time > Shift_End_Time Then Shift_End_Time ELSE D.OUT_Time END AS Out_Time  
         FROM #Data D  
           INNER JOIN (SELECT SD.Shift_ID,   
                IsNull(Max(SD.Working_Hrs_St_Time),0) As From_ST_Start,   
                IsNull(Max(SD.Working_Hrs_End_Time), 0) As To_ST_End  
              FROM T0050_SHIFT_DETAIL SD WITH (NOLOCK)   
              WHERE Cmp_ID=@Cmp_ID  
              GROUP BY SD.Shift_ID) SD ON D.Shift_ID=SD.Shift_ID  
         ) D1 ON D.Emp_Id=D1.Emp_Id AND D.For_date=D1.For_date  
    WHERE EXISTS (SELECT 1   
        FROM T0050_SHIFT_DETAIL SD  WITH (NOLOCK)   
        WHERE D.Shift_ID=SD.Shift_ID   
          AND (ISNULL(SD.Working_Hrs_St_Time,0) = 1 OR ISNULL(SD.Working_Hrs_End_Time,0) = 1)  
        )        
    
   /*Difference should be calculated before shift end only*/  
   UPDATE EIO  
   SET  In_Time = D.Shift_End_Time,  
     Diff_Sec = DateDiff(s, EIO.Out_Time, D.Shift_End_Time)  
   FROM #Data_EIO_Diff EIO  
     INNER JOIN #Data D ON EIO.Emp_ID=D.Emp_Id AND EIO.For_date=D.For_date  
   WHERE EXISTS (SELECT 1 FROM T0050_SHIFT_DETAIL SD  WITH (NOLOCK) WHERE D.Shift_ID=SD.Shift_ID AND ISNULL(SD.Working_Hrs_End_Time,0) = 1)  
     AND D.Shift_End_Time BETWEEN EIO.Out_Time AND EIO.IN_TIME  
     
     
  
   IF OBJECT_ID('tempdb..#Data_NOT_FILO') IS NULL  
    BEGIN   
     CREATE table #Data_NOT_FILO  
     (           
        Emp_Id   NUMERIC ,           
        For_date DATETIME,        
        Diff_Sec NUMERIC  
     )           
     CREATE NONCLUSTERED INDEX ix_Data_temp1_Diff_Emp_Id_For_date ON #Data_NOT_FILO(Emp_Id,For_Date);    
    END  
     
   INSERT INTO #Data_NOT_FILO  
   SELECT DT.EMP_ID, DT.FOR_DATE, SUM(Diff_Sec) AS Diff_Sec   
   FROM #Data_EIO_Diff DT   
     INNER JOIN #Data D  ON D.Emp_Id = DT.Emp_Id AND D.For_date = DT.For_date  
   WHERE (DT.Out_Time BETWEEN D.In_Time AND D.OUT_Time) AND  
      (DT.In_Time BETWEEN D.In_Time AND D.OUT_Time)  
   GROUP BY DT.EMP_ID, DT.FOR_DATE  
  
   UPDATE #Data  
   SET  Duration_in_sec = Duration_in_sec - ISNULL(DT.Diff_Sec,0)  
   FROM #Data D   
     LEFT OUTER JOIN #Data_NOT_FILO DT ON D.Emp_Id = DT.Emp_Id AND D.For_date = DT.For_date  
   WHERE D.Duration_in_sec > 0 --and D.Emp_Id = @curEmp_ID -- Comment by Nilesh Patel on 29-03-2019 -- @CurEmp_ID Scope is complete -- Getting issue in Cliantha Absent Report  
  
   DROP TABLE #EIO  
  END  
   
   
  
  -- Commented by Hardik 05/12/2019 for Iconic as they have different policy in branches so added condition in Where at below 2 codes  
  --if  @First_In_Last_Out_For_InOut_Calculation_Actual = 0  
  -- BEGIN    
    UPDATE D  
    SET  Working_Hrs_St_Time = SD.Working_Hrs_St_Time,  
      Working_Hrs_End_Time = SD.Working_Hrs_End_Time,  
      OT_Start_Time = SD.OT_Start_Time,  
      OT_End_Time = SD.OT_End_Time  
    FROM #Data D   
      INNER JOIN (SELECT Shift_ID, Max(Working_Hrs_St_Time) As Working_Hrs_St_Time, Max(Working_Hrs_End_Time) As Working_Hrs_End_Time,   
           Max(OT_Start_Time) As OT_Start_Time, Max(OT_End_Time) As OT_End_Time  
         FROM T0050_SHIFT_DETAIL SD WITH (NOLOCK)   
         GROUP BY Shift_ID) SD ON D.Shift_ID=SD.Shift_ID  
      INNER JOIN #EMP_GEN_SETTINGS EGS ON D.Emp_Id = EGS.EMP_ID  
    WHERE EGS.First_In_Last_Out_For_InOut_Calculation = 0  
     
         
           
    UPDATE D  
    SET  Duration_In_Sec = D1.Actual_Work  
    FROM #DATA D        
      INNER JOIN (SELECT Distinct Emp_ID, For_Date, Sum(DateDiff(s, In_Time, Out_Time)) As Actual_Work  
         FROM (SELECT Distinct D1.Emp_ID, D1.For_Date, Case When EIR.In_Time < D1.Shift_Start_Time AND D1.Working_Hrs_St_Time=1 Then D1.Shift_Start_Time  
                     When EIR.In_Time > D1.Shift_End_Time AND D1.Working_Hrs_End_Time=1 Then D1.Shift_End_Time  
                   Else EIR.In_Time END As In_Time,  
                   Case When EIR.Out_Time > D1.Shift_End_Time AND D1.Working_Hrs_End_Time=1 Then D1.Shift_End_Time  
                     When EIR.Out_Time < D1.Shift_Start_Time AND D1.Working_Hrs_St_Time=1 Then D1.Shift_Start_Time  
                   Else EIR.Out_Time END As Out_Time  
           FROM #Data D1  
             INNER JOIN #TMP_EMP_0150_INOUT EIR ON D1.Emp_Id=EIR.Emp_ID   
                 AND EIR.In_Time BETWEEN D1.In_Time AND ISNULL(D1.Out_Time, D1.In_Time)  
           WHERE EIR.Duration <> '0') T  
         GROUP BY Emp_ID, For_Date  
         ) D1 ON D.Emp_Id=D1.Emp_Id AND D.For_date=D1.For_date  
      INNER JOIN #EMP_GEN_SETTINGS EGS ON D.Emp_Id = EGS.EMP_ID  
    WHERE EGS.First_In_Last_Out_For_InOut_Calculation = 0  
  
   --END  

--------------- Add By Jignesh 03-Dec-2019(For Multi Recored )------  

if  @First_In_Last_Out_For_InOut_Calculation_Actual = 1  
  set @First_In_Last_OUT_Flag = 1  
  
 if @First_In_Last_OUT_Flag = 0  
 BEGIN     
  
    IF  OBJECT_ID('tempdb..#DATA_IO') IS NULL   
       BEGIN  
        IF  object_id('tempdb..#DATA_IO') IS NOT NULL   
        begin  
         DROP TABLE #DATA_IO    
        end  
        SELECT * INTO #DATA_IO FROM #DATA  WHERE 1=2  
       END  
  
   IF  object_id('tempdb..#DATA_IO') IS NOT NULL   
    BEGIN        
  
      
     INSERT INTO #DATA_IO  
     SELECT DISTINCT  
     A.Emp_Id,A.For_date,Duration_in_sec,A.Shift_ID,A.Shift_Type,A.Emp_OT,Emp_OT_min_Limit,A.Emp_OT_max_Limit,  
     A.P_days   
     ,A.OT_Sec ,B.In_Time ,A.Shift_Start_Time ,A.OT_Start_Time ,A.Shift_Change ,A.Flag ,A.Weekoff_OT_Sec ,A.Holiday_OT_Sec ,A.Chk_By_Superior   
     ,A.IO_Tran_Id ,B.OUT_Time ,A.Shift_End_Time ,A.OT_End_Time ,A.Working_Hrs_St_Time ,A.Working_Hrs_End_Time ,A.GatePass_Deduct_Days
	 ,0 -- Added by Prapti 30052022
	

     FROM #DATA AS A Inner JOIN #TMP_EMP_0150_INOUT AS B  
     ON A.emp_id = B.Emp_id  
     --And A.for_date = B.For_Date  
     ------------ Modify jignesh 20-Apr-2020-----  
     --And B.out_Time between Isnull(A.In_Time,A.Shift_Start_Time) AND isnull(A.out_time,A.Shift_End_Time)  
     And (  
      B.In_Time between Isnull(A.In_Time,A.Shift_Start_Time) AND isnull(A.out_time,A.Shift_End_Time)  
      OR  
      B.out_Time between Isnull(A.In_Time,A.Shift_Start_Time) AND isnull(A.out_time,A.Shift_End_Time)  
         )  
     ------------- end ---------------20-Apr-2020----  
     ORDER BY B.in_time  
      
      
      
     UPDATE D      
     SET  Emp_OT = CASE WHEN D.Emp_OT = 1 THEN I.Emp_OT ELSE 0 END,  
       Emp_OT_Min_Limit = dbo.F_Return_Sec(I.Emp_OT_Min_Limit) --DateDiff(s,'1900-01-01',I.Emp_OT_Min_Limit)  
       ,Emp_OT_Max_Limit = dbo.F_Return_Sec(I.Emp_OT_Max_Limit) --DateDiff(s,'1900-01-01',I.Emp_OT_Max_Limit)  
     FROM #DATA_IO D  
       INNER JOIN #EMP_CONS EC ON D.EMP_ID=EC.EMP_ID  
       INNER JOIN T0095_INCREMENT I  WITH (NOLOCK) ON EC.INCREMENT_ID=I.INCREMENT_ID   
     Where I.Emp_OT_Min_Limit <> '24:00'   
 
       
       
     Update #DATA_IO   
     SET Duration_In_Sec = CASE WHEN A.In_Time = MaxTime THEN Duration_In_Sec else 0 END   
     From #DATA_IO AS A Left Outer JOIN  
     (select emp_id,for_date,MIN(In_time)as MinTime,MAX(In_time)as MaxTime from #DATA_IO  
     group by emp_id,for_date) as B ON A.emp_id = B.emp_id  
     And A.for_Date = B.for_Date  
        
      --print 'k'  
        
        
     DELETE FROM #DATA  
  
     INSERT INTO #DATA   
     SELECT * FROM #DATA_IO   
       
        
    END    
     
 END  
 ----------------- End -----------------------    
  
   
END_OF_CALL:  
  
 IF OBJECT_ID('tempdb..#EMP_CONS_INOUT') IS NOT NULL  
  AND OBJECT_ID('tempdb..#DATA_INOUT') IS NOT NULL  
  BEGIN  
   SELECT * INTO #EMP_CONS_INOUT FROM #EMP_CONS  
   SELECT * INTO #DATA_INOUT FROM #DATA  
  END  
END  
  
