  
  
-- =============================================  
-- Author:  Jaina Desai  
-- Create date: 02-Feb-2017  
-- Description: To Determine whether leave is exist for the same period  
---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
-- =============================================  
CREATE PROCEDURE [dbo].[P_Check_Leave_Availability]  
 @Cmp_Id   NUMERIC,  
 @Emp_Id   NUMERIC,  
 @From_Date  DATETIME,  
 @To_Date  DATETIME,  
 @Half_Date  DATETIME,  
 @Leave_type  VARCHAR(15),  
 @Leave_Application_Id NUMERIC = null,  
 @Raise_Error BIT = 0,  
 @From_time  DATETIME = null,  
 @To_time  DATETIME = null,  
 @Leave_Period NUMERIC(5,2) = 0  
AS  
  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
  
BEGIN  
  
   
  
 DECLARE @TEMP_DATE DATETIME  
 DECLARE @TEMP_LEAVE_TYPE VARCHAR(20)  
 DECLARE @HALF_LEAVE_DATE DATETIME  
  
   
 SET @TEMP_DATE = @From_Date  
  
 IF @Leave_Application_Id IS NULL  
  SET @Leave_Application_Id = 0;  
  
 IF DATEDIFF(D, @FROM_DATE, @FROM_TIME) >1  
  BEGIN  
   SET @FROM_TIME = (@FROM_TIME - CONVERT(DATETIME,CONVERT(CHAR(10), @FROM_TIME, 103), 103)) + @From_Date  
   SET @To_time = (@To_time - CONVERT(DATETIME,CONVERT(CHAR(10), @To_time, 103), 103)) + @To_Date     
  END  
  
 --FOR HOURLY LEAVE  
 DECLARE @Shift_ID   NUMERIC(18,0)  
 DECLARE @First_Half_Start DATETIME  
 DECLARE @First_Half_End  DATETIME  
 DECLARE @Second_Half_Start DATETIME  
 DECLARE @Second_Half_END DATETIME  
 DECLARE @Shift_St_Time  DATETIME  
 DECLARE @Shift_End_Time  DATETIME  
 DECLARE @S_St_Time   DATETIME  
 DECLARE @FROMTIME   DATETIME  
 DECLARE @TOTIME    DATETIME  
 DECLARE @Part_Leave_Period NUMERIC(5,2)  
 DECLARE @FLAG    TINYINT  = 0  
  
 SET @Shift_ID = 0   
  
 IF ISNULL(@Half_Date, '1900-01-01') = '1900-01-01'  
  SET @Half_Date = null  
  
 SELECT @SHIFT_ID = SHIFT_ID FROM DBO.F_GET_CURR_SHIFT(@EMP_ID,IsNull(@Half_Date,@FROM_DATE))  
  
 SELECT @SHIFT_ST_TIME = SM.SHIFT_ST_TIME + @From_Date,   
   @SHIFT_END_TIME = SM.SHIFT_END_TIME + @From_Date  
    
 FROM DBO.T0040_SHIFT_MASTER AS SM WITH (NOLOCK)  
 WHERE SM.SHIFT_ID=@SHIFT_ID  
  
 if @S_ST_TIME is null  
  set @S_ST_TIME = dateadd(hh, DATEDIFF(hh, @SHIFT_ST_TIME, @SHIFT_END_TIME) / 2, @SHIFT_ST_TIME)  
  
    
  
 set @First_Half_Start = @SHIFT_ST_TIME  
 set @First_Half_End = @S_ST_TIME  
 set @Second_Half_Start = @S_ST_TIME  
 set @Second_Half_END = @SHIFT_END_TIME  
  
   
 DECLARE @LEAVE_USED NUMERIC(5,2)  
 ---select @First_Half_Start as First_Half_Start,@First_Half_End as First_Half_End,@Second_Half_Start as Second_Half_Start,@Second_Half_END as Second_Half_END  
  
 IF @Half_Date IS NULL AND @From_Date = @TO_DATE AND @Leave_Period % 1 = 0.5  
  SET @Half_Date = @FROM_DATE  
    
   
 IF (@Half_Date IS NULL AND @Leave_type = 'Part Day')   
  BEGIN  
   IF (@Leave_Period >= 1 AND @Leave_Period % 1 = 0)  
    SET @Part_Leave_Period = @Leave_Period * 0.125  
  
     
     
   --GET LEAVE PERIOD FROM (FROMDATE AND TODATE)  
  
  
   SELECT @LEAVE_USED =  CASE WHEN CompOff_Used - IsNull(Leave_Encash_Days,0) > 0 Then CompOff_Used - IsNull(Leave_Encash_Days,0) Else Leave_Used + Isnull(Back_Dated_Leave,0) END  
   FROM T0140_LEAVE_TRANSACTION T WITH (NOLOCK)  
     --INNER JOIN T0040_LEAVE_MASTER L ON T.Leave_ID=L.Leave_ID  
   WHERE For_Date = @From_Date AND Emp_ID=@EMP_ID   
     
     
   IF @LEAVE_USED > 1  
    SET @LEAVE_USED = @LEAVE_USED * 0.125  
       
   IF  (@LEAVE_USED + @Part_Leave_Period) > 1  
    BEGIN   
           
     if @Raise_Error = 0  
	 
      SELECT  'Leave on particular date already exists.' As [Status]  
     ELSE  
      RAISERROR('@@Leave on particular date already exists.@@',16,2)      
     RETURN  
    END  
   ELSE IF @LEAVE_USED = 0.5 or @LEAVE_USED = 0.25   --Chnage by Jaina 19-06-2017  
    BEGIN  
       
     --CHECK EXISTING LEAVE IS HOURLY OR FH/SH  
     --SET @LEAVE_TAKEN_FROM  
     --SET @LEAVE_TAKEN_TO   
      
     --CASE  
      --HALF LEAVE APP  
      --FULL DAY LEAVE APP -> HALF APPROVAL  
      --FULL DAY LEAVE APP -> FULL APPROVAL -> HALF CANCELLATION  
                
     --Approval Exits (0.5 First/Second)  
     if exists (select LAD.Leave_Assign_As   
       from T0120_LEAVE_APPROVAL LA WITH (NOLOCK)  
       inner JOIN T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) ON LA.Leave_Approval_ID = LAD.Leave_Approval_ID AND (LAD.Leave_Period = 0.5 or LAD.Leave_Period = 0.25)  --Change by Jaina 19-06-2017  
       where LA.Emp_ID=@emp_ID and (LAD.From_Date = @From_Date OR LAD.Half_Leave_Date= @From_Date )and la.Approval_Status='A')  
      BEGIN    
             
        select @TEMP_LEAVE_TYPE = LAD.Leave_Assign_As,  
            @FROMTIME = LEAVE_OUT_TIME - Convert(datetime, Convert(Char(10),LEAVE_OUT_TIME,103), 103) + @From_Date ,  
            @TOTIME = LEAVE_IN_TIME - Convert(datetime, Convert(Char(10),LEAVE_IN_TIME,103), 103) + @To_Date  
        from T0120_LEAVE_APPROVAL LA WITH (NOLOCK)  
        inner JOIN T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) ON LA.Leave_Approval_ID = LAD.Leave_Approval_ID  
        where LA.Emp_ID=@emp_ID and (LAD.From_Date = @From_Date OR LAD.Half_Leave_Date= @From_Date )and la.Approval_Status='A'  
          
       
        --IF convert(varchar(8),@FROMTIME,108) = '00:00:00' AND Convert(varchar(8),@TOTIME,108) ='00:00:00'  
        BEGIN  
          SET @FLAG =0  
          IF  @TEMP_LEAVE_TYPE = 'First Half'   
           BEGIN  
            IF (@From_time BETWEEN @First_Half_Start and DATEADD(n,-1,@First_Half_End))   
             OR (@To_time BETWEEN @First_Half_Start and DATEADD(n,-1,@First_Half_End)) --Change And condition to OR to check whether In time is in first half part or in second half part on 19-May-2017 : Nimesh  
             SET @FLAG =1  
           END  
          ELSE IF @TEMP_LEAVE_TYPE = 'Second Half'  
           BEGIN  
            IF (@From_time between @Second_Half_Start and @Second_Half_END)   
             OR (@To_time between @Second_Half_Start and @Second_Half_END) --Change And condition to OR to check whether In time is in first half part or in second half part on 19-May-2017 : Nimesh  
             SET @FLAG = 1  
           END  
          else if @TEMP_LEAVE_TYPE = 'Part Day'   --Added by Jaina 19-06-2017  
          begin  
              
            declare @F_date as datetime  
            declare @t_date as datetime  
            set @F_date = Convert(datetime, CONVERT(time,@From_time,103), 103) + @From_Date  
            set @t_date = Convert(datetime, CONVERT(time,@To_time,103), 103) + @To_Date  
              
            --select @FROMTIME,@F_date,@TOTIME,@t_date  
            --IF (@FROMTIME >= @F_date and @TOTIME > @t_date or @FROMTIME =< @F_date and @TOTIME > @t_date )  
            IF ( @F_date between @FROMTIME and @TOTIME  or @t_date between @FROMTIME and @TOTIME)  --Change by Jaina 21-07-2017  
               set @FLAG = 1  
      
          END  
          If @FLAG = 1  
           Begin  
            if @Raise_Error = 0  
             SELECT  'Leave on particular date already exists.' As [Status]  
            ELSE  
             RAISERROR('@@Leave on particular date already exists.@@',16,2)      
            RETURN  
           END  
         
         END  
         
      END  
       
      --Cancellation Exits (0.5 First/Second)  
     IF EXISTS(SELECT 1 FROM T0150_LEAVE_CANCELLATION WITH (NOLOCK) WHERE Emp_Id=@EMP_ID AND For_date=@From_Date   
           AND Is_Approve=1 )  
      BEGIN  
       SELECT @TEMP_LEAVE_TYPE = Day_type,  
         @FROMTIME = CONVERT(TIME,LEAVE_OUT_TIME),  
         @TOTIME = CONVERT(TIME,LEAVE_IN_TIME)   
       FROM T0150_LEAVE_CANCELLATION LC WITH (NOLOCK) inner JOIN   
         T0120_LEAVE_APPROVAL LA WITH (NOLOCK) ON LA.Leave_Approval_ID = LC.Leave_Approval_ID inner JOIN   
         T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) ON LA.Leave_Approval_ID = LAD.Leave_Approval_ID   
       WHERE LC.Emp_Id=@EMP_ID AND LC.For_date=@From_Date AND LC.Is_Approve=1  
        
         
         
       IF convert(varchar(8),@FROMTIME,108) = '00:00:00' AND Convert(varchar(8),@TOTIME,108) ='00:00:00'  
        BEGIN  
         
         IF  @TEMP_LEAVE_TYPE = 'First Half'   
          BEGIN  
           IF (@From_time BETWEEN @First_Half_Start AND DateAdd(n,1,@First_Half_End))  
            OR (@To_time BETWEEN @First_Half_Start AND DateAdd(n,1,@First_Half_End)) --Change And condition to OR to check whether In time is in first half part or in second half part on 19-May-2017 : Nimesh  
            SET @FLAG =0  
           ELSE  
            SET @FLAG = 1  
          END  
         ELSE IF @TEMP_LEAVE_TYPE = 'Second Half'  
          BEGIN  
           IF (@From_time between @Second_Half_Start and @Second_Half_END) or (@To_time between @Second_Half_Start and @Second_Half_END) --Change And condition to OR to check whether In time is in first half part or in second half part on 19-May-2017 : Nimesh  
            SET @FLAG = 0  
           ELSE  
            SET @FLAG = 1  
          END  
         
  
         If @FLAG = 1  
          BEGIN  
           IF @Raise_Error = 0  
            SELECT  'Leave on particular date already exists.' As [Status]  
           ELSE  
            RAISERROR('@@Leave on particular date already exists.@@',16,2)      
           RETURN  
          END  
        END  
      END   
    END  
   ELSE   
    BEGIN  
       
     --IF EXIST IN APP NOT IN APPROVAL  
     --CHECK EXISTING LEAVE IS HOURLY OR FH/SH  
     --SET @LEAVE_TAKEN_FROM  
     --SET @LEAVE_TAKEN_TO   
     IF EXISTS(SELECT 1 FROM T0100_LEAVE_APPLICATION LA WITH (NOLOCK)  
         INNER JOIN T0110_LEAVE_APPLICATION_DETAIL LAD WITH (NOLOCK) ON LA.Leave_Application_ID=LAD.Leave_Application_ID  
            WHERE LA.Emp_ID=@EMP_ID AND @TEMP_DATE BETWEEN FROM_DATE AND TO_DATE AND LAD.Leave_Application_Id  <> @Leave_Application_Id   
         AND NOT EXISTS(SELECT 1 FROM T0120_LEAVE_APPROVAL LA1 WITH (NOLOCK) WHERE LA1.Leave_Application_ID=LA.Leave_Application_ID))  
     BEGIN  
         
       --Added by Jaina 11-08-2017 start  
       DECLARE @LEAVE_COUNT INT  
       SELECT @LEAVE_COUNT = COUNT(1)  
       FROM T0100_LEAVE_APPLICATION LA WITH (NOLOCK)   
         INNER JOIN T0110_LEAVE_APPLICATION_DETAIL LAD WITH (NOLOCK) ON LA.Leave_Application_ID=LAD.Leave_Application_ID  
       WHERE LA.Emp_ID=@EMP_ID AND   
         @TEMP_DATE BETWEEN FROM_DATE AND TO_DATE  
         --AND LAD.Half_Leave_Date=@TEMP_DATE  
         AND LA.Application_Status = 'P'  
         and LA.Leave_Application_ID <> @Leave_Application_Id   
         AND NOT EXISTS(SELECT 1 FROM T0120_LEAVE_APPROVAL LA1 WITH (NOLOCK) WHERE LA1.Leave_Application_ID=LA.Leave_Application_ID)  
       --Added by Jaina 11-08-2017 start     
           
        SELECT @TEMP_LEAVE_TYPE = CASE WHEN IsNull(LAD.Half_Leave_Date, '1900-01-01')=@TEMP_DATE THEN        
                 LAD.Leave_Assign_As   
                WHEN LAD.Leave_Assign_As <> 'Part Day' THEN  
                 'Full Day'  
                ELSE  
                 LAD.Leave_Assign_As   
                END,  
           @FROMTIME = LEAVE_OUT_TIME, @TOTIME = LEAVE_IN_TIME  
         FROM T0100_LEAVE_APPLICATION LA WITH (NOLOCK)   
          INNER JOIN T0110_LEAVE_APPLICATION_DETAIL LAD WITH (NOLOCK) ON LA.Leave_Application_ID=LAD.Leave_Application_ID  
         WHERE LA.Emp_ID=@EMP_ID AND   
          @TEMP_DATE BETWEEN FROM_DATE AND TO_DATE  
          --AND LAD.Half_Leave_Date=@TEMP_DATE  
          AND LA.Application_Status = 'P'  
          and LA.Leave_Application_ID <> @Leave_Application_Id   
          AND NOT EXISTS(SELECT 1 FROM T0120_LEAVE_APPROVAL LA1 WITH (NOLOCK) WHERE LA1.Leave_Application_ID=LA.Leave_Application_ID)  
          
           
          
         IF DATEDIFF(D, @FROM_DATE, @FROM_TIME) <> 0  
          BEGIN  
           SET @FROM_TIME = (@FROM_TIME - CONVERT(DATETIME,CONVERT(CHAR(10), @FROM_TIME, 103), 103)) + @From_Date  
           SET @TO_TIME = (@TO_TIME - CONVERT(DATETIME,CONVERT(CHAR(10), @TO_TIME, 103), 103)) + @To_Date     
          END  
         IF DATEDIFF(D, @FROM_DATE, @FROMTIME) <> 0  
          BEGIN  
           SET @FROMTIME = (@FROMTIME - CONVERT(DATETIME,CONVERT(CHAR(10), @FROMTIME, 103), 103)) + @From_Date  
           SET @TOTIME = (@TOTIME - CONVERT(DATETIME,CONVERT(CHAR(10), @TOTIME, 103), 103)) + @To_Date     
          END  
           
         /*  
         --Existing Leave Detail  
         if @TEMP_LEAVE_TYPE = 'Part Day'  
          Begin  
           IF (@FROMTIME between @First_Half_Start and DateAdd(n,-1, @First_Half_End))   
            OR  (@TOTIME between @First_Half_Start and DateAdd(n,-1, @First_Half_End)) --Change And condition to OR to check whether In time is in first half part or in second half part on 19-May-2017 : Nimesh  
            SET @TEMP_LEAVE_TYPE = 'First Half'  
           ELSE IF (@FROMTIME between @Second_Half_Start and @Second_Half_END)   
             OR (@TOTIME between @Second_Half_Start and @Second_Half_END) --Change And condition to OR to check whether In time is in first half part or in second half part on 19-May-2017 : Nimesh  
            SET @TEMP_LEAVE_TYPE = 'Second Half'  
          End  
           
          
         --New Leave Detail  
         IF (@From_time >= @First_Half_Start and @From_time < DateAdd(n,-1, @First_Half_End))   
          OR (@To_time >= @First_Half_Start and @To_time < @First_Half_End) --Change And condition to OR to check whether In time is in first half part or in second half part on 19-May-2017 : Nimesh  
          SET @LEAVE_TYPE = 'First Half'  
         ELSE IF (@From_time between @Second_Half_Start and @Second_Half_END)   
          OR (@To_time between @Second_Half_Start and @Second_Half_END) --Change And condition to OR to check whether In time is in first half part or in second half part on 19-May-2017 : Nimesh  
          SET @LEAVE_TYPE = 'Second Half'*/  
           
            
  
         IF @TEMP_LEAVE_TYPE = 'Part Day'  
          BEGIN  
           SET @FROMTIME = DATEADD(N,1,@FROMTIME)  
           SET @TOTIME = DATEADD(N,-1,@TOTIME)  
             
           IF (@FROMTIME between @From_time and @To_time)   
            OR (@TOTIME between @From_time and @To_time)   
            OR (@From_time between @FROMTIME and @TOTIME)   
            OR (@To_time between @FROMTIME and @TOTIME) or  @LEAVE_COUNT > 1  --Change by Jaina 11-08-2017  
            BEGIN               
             IF @Raise_Error = 0  
              SELECT  'Leave on particular date already exists.' As [Status]  
             ELSE  
              RAISERROR('@@Leave on particular date already exists.@@',16,2)      
             RETURN  
            END  
          END  
         ELSE IF (@LEAVE_TYPE = 'Full Day') or  @LEAVE_COUNT > 1   --Change by Jaina 11-08-2017  
          BEGIN      
		  
           if @Raise_Error = 0  
            SELECT  'Leave on particular date already exists.' As [Status]  
           ELSE  
            RAISERROR('@@Leave on particular date already exists.@@',16,2)      
           RETURN  
          END  
      END       
      
    END  
  
   
   --IF @LEAVE_TAKEN_FROM  IS NOT NULL  
    --BEGIN   
     --IF FH/SH THEN  
      --GET SHIFT TIME  
      --IF @LEAVE_TAKEN_FROM <= @FROM_DATE AND @LEAVE_TAKEN_TO >= @FROM_DATE  
      --   02:00 PM    04:00pm   07:00 pm    04:00pm  
      --  OR @LEAVE_TAKEN_FROM <= @FROM_DATE AND @LEAVE_TAKEN_TO >= @FROM_DATE  
      --   02:00 PM    06:00pm   07:00 pm    06:00pm  
    --END  
     
     
     
  END  
 ELSE  
  BEGIN --FOR FULL DAY  OR FIRST HALF AND SECOND HALF DAY LEAVE  
   WHILE @TEMP_DATE <= @TO_DATE  
    BEGIN   
      
     IF @TEMP_DATE = IsNull(@Half_Date , '1900-01-01') OR (@TEMP_DATE = @TO_DATE AND @Leave_type NOT IN ('Full Day', 'Part Day'))  
      BEGIN        
         
        ----Leave App Exist without Approval (Half Leave Date Case )  
       IF EXISTS(SELECT 1 FROM T0100_LEAVE_APPLICATION LA WITH (NOLOCK)  
           INNER JOIN T0110_LEAVE_APPLICATION_DETAIL LAD WITH (NOLOCK) ON LA.Leave_Application_ID=LAD.Leave_Application_ID  
          WHERE LA.Emp_ID=@EMP_ID AND   
           @TEMP_DATE BETWEEN FROM_DATE AND TO_DATE  
           --AND LAD.Half_Leave_Date=@TEMP_DATE   
           AND LA.Application_Status ='P'  
           and LA.Leave_Application_ID <> @Leave_Application_Id  
           AND NOT EXISTS(SELECT 1 FROM T0120_LEAVE_APPROVAL LA1 WITH (NOLOCK) WHERE LA1.Leave_Application_ID=LA.Leave_Application_ID))  
        BEGIN  
          
            
         DECLARE @L_COUNT INT  
         SELECT @TEMP_LEAVE_TYPE = CASE WHEN Max(IsNull(LAD.Half_Leave_Date, '1900-01-01'))=@TEMP_DATE THEN  
                Max(LAD.Leave_Assign_As)  
               ELSE  
                Max(LAD.Leave_Assign_As) --- 'Full Day'                
               END,  
               @FROMTIME = LEAVE_OUT_TIME - Convert(datetime, Convert(Char(10),LEAVE_OUT_TIME,103), 103) + @From_Date ,  
               @TOTIME = LEAVE_IN_TIME - Convert(datetime, Convert(Char(10),LEAVE_IN_TIME,103), 103) + @To_Date,  
               --@FROMTIME = LEAVE_OUT_TIME,  
               --@TOTIME = LEAVE_IN_TIME,   
               @L_COUNT = COUNT(1)   
         FROM T0100_LEAVE_APPLICATION LA WITH (NOLOCK)  
          INNER JOIN T0110_LEAVE_APPLICATION_DETAIL LAD WITH (NOLOCK) ON LA.Leave_Application_ID=LAD.Leave_Application_ID  
         WHERE LA.Emp_ID=@EMP_ID AND   
          @TEMP_DATE BETWEEN FROM_DATE AND TO_DATE           
          AND LA.Application_Status ='P'  
          and LA.Leave_Application_ID <> @Leave_Application_Id  
          AND NOT EXISTS(SELECT 1 FROM T0120_LEAVE_APPROVAL LA1 WITH (NOLOCK) WHERE LA1.Leave_Application_ID=LA.Leave_Application_ID)  
         group BY LAD.leave_Out_time,LAD.leave_In_time  
           
           
          
         if @TEMP_LEAVE_TYPE = 'Part Day'  
          Begin  
           IF (@fromtime >= @First_Half_Start and @fromtime < @First_Half_End) or (@totime >= @First_Half_Start and @totime < @First_Half_End) --Change And condition to OR to check whether In time is in first half part or in second half part on 19-May-2017 : Nimesh  
            set @TEMP_LEAVE_TYPE = 'First Half'  
           else if (@fromtime >= @Second_Half_Start and @fromtime < @Second_Half_END) or (@totime > @Second_Half_Start and @totime <= @Second_Half_END) --Change And condition to OR to check whether In time is in first half part or in second half part on 19-May-2017 : Nimesh  
            set @TEMP_LEAVE_TYPE = 'Second Half'  
          End          
         IF @TEMP_LEAVE_TYPE IN ('Full Day', @LEAVE_TYPE) or @L_COUNT > 1   
          Begin      
             
           if @Raise_Error = 0  
            SELECT  'Leave on particular date already exists.' As [Status]  
           ELSE  
            RAISERROR('@@Leave on particular date already exists.@@',16,2)      
           RETURN  
          END  
             
        END      
  
       SELECT @LEAVE_USED = CASE WHEN CompOff_Used - IsNull(Leave_Encash_Days,0) > 0 Then CompOff_Used - IsNull(Leave_Encash_Days,0) Else Leave_Used + Isnull(Back_Dated_Leave,0) END --(IsNUll(Leave_Used,0) + ISNULL(CompOff_Used,0))  
       FROM T0140_LEAVE_TRANSACTION WITH (NOLOCK)  
          WHERE EMP_ID=@EMP_ID AND FOR_DATE=@TEMP_DATE   
       IF @LEAVE_USED > 1  
        SET @LEAVE_USED = @LEAVE_USED * 0.125  
          
       --More than 0.5 Leave Approval Is Exist  
       IF @LEAVE_USED > 0.5  
        BEGIN        
         if @Raise_Error = 0  
          SELECT  'Leave on particular date already exists.' As [Status]  
         ELSE  
          RAISERROR('@@Leave on particular date already exists.@@',16,2)      
         RETURN  
        END  
       Else IF (@LEAVE_USED = 0.5)  
        BEGIN  
           
          
         IF EXISTS(SELECT 1 FROM T0150_LEAVE_CANCELLATION WITH (NOLOCK) WHERE Emp_Id=@EMP_ID AND For_date=@TEMP_DATE   
           AND Is_Approve=1)  
          BEGIN  
           SELECT @TEMP_LEAVE_TYPE = Day_type  
           FROM T0150_LEAVE_CANCELLATION WITH (NOLOCK)  
           WHERE Emp_Id=@EMP_ID AND For_date=@TEMP_DATE AND Is_Approve=1  
            
           --IF @TEMP_LEAVE_TYPE <> @LEAVE_TYPE  
           IF (@TEMP_LEAVE_TYPE <> @LEAVE_TYPE or @LEAVE_TYPE = 'Full Day')  
           BEGIN  
		   
            if @Raise_Error = 0  
             SELECT  'Leave on particular date already exists.' As [Status]  
            ELSE  
             RAISERROR('@@Leave on particular date already exists.@@',16,2)      
            RETURN  
           END  
          END   
         else   --Approval Exits (0.5 First/Second)  
          Begin  
             
           SELECT @TEMP_LEAVE_TYPE = LAD.Leave_Assign_As, @HALF_LEAVE_DATE = LAD.Half_Leave_Date,  
             @FROMTIME = LAD.Leave_In_Time, @TOTIME=LAD.Leave_out_time    
           FROM T0120_LEAVE_APPROVAL LA WITH (NOLOCK)  
             INNER JOIN T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) ON LA.Leave_Approval_ID = LAD.Leave_Approval_ID  
           WHERE LA.Emp_ID=@emp_ID AND (LAD.From_Date = @TEMP_DATE OR LAD.Half_Leave_Date= @TEMP_DATE)  
             AND la.Approval_Status='A'  
             
             
             
           SET @FLAG =0  
           --Added by Jaina 19-06-2017 start  --If already take FH/SH leave and add in out for FH/SH  
           IF DATEDIFF(D, @FROM_DATE, @FROM_TIME) <> 0  
           begin  
            SET @FROM_TIME = (@FROM_TIME - CONVERT(DATETIME,CONVERT(CHAR(10), @FROM_TIME, 103), 103)) + @From_Date  
            SET @TO_TIME = (@TO_TIME - CONVERT(DATETIME,CONVERT(CHAR(10), @TO_TIME, 103), 103)) + @To_Date     
              
           ENd  
             
           IF  @TEMP_LEAVE_TYPE = 'First Half'   
            BEGIN  
             --IF(@FROM_TIME BETWEEN @First_Half_Start and @First_Half_End)   
             --   OR (@TO_TIME BETWEEN @First_Half_Start and @First_Half_End)  
             -- SET @FLAG =1  
             IF @Leave_type = 'First Half'  
              SET @FLAG =1  
            END  
           ELSE IF @TEMP_LEAVE_TYPE = 'Second Half'  
            BEGIN  
               
             --IF(@FROM_TIME between @Second_Half_Start and @Second_Half_END)   
             --   OR (@TO_TIME between @Second_Half_Start and @Second_Half_END)  
             -- SET @FLAG = 1  
             IF @Leave_type = 'Second Half'  
              SET @FLAG =1  
            END  
           --Added by Jaina 19-06-2017 start  --If already take FH/SH leave and add in out for FH/SH  
             
           ELSE IF @TEMP_LEAVE_TYPE = 'Part Day'   
            BEGIN  
             IF DATEDIFF(D, @FROM_DATE, @FROMTIME) <> 0  
             BEGIN  
              SET @FROMTIME = (@FROMTIME - CONVERT(DATETIME,CONVERT(CHAR(10), @FROMTIME, 103), 103)) + @From_Date  
              SET @TOTIME = (@TOTIME - CONVERT(DATETIME,CONVERT(CHAR(10), @TOTIME, 103), 103)) + @To_Date     
  
              SET @FROMTIME = DATEADD(N,1,@FROMTIME)  
              SET @TOTIME = DATEADD(N,-1,@TOTIME)  
             END  
             IF  @LEAVE_TYPE = 'First Half'   
              AND ((@FROMTIME BETWEEN @First_Half_Start and @First_Half_End)   
                OR (@TOTIME BETWEEN @First_Half_Start and @First_Half_End))                
              SET @FLAG =1                
             ELSE IF @LEAVE_TYPE = 'Second Half'  
              AND ((@FROMTIME between @Second_Half_Start and @Second_Half_END)   
                OR (@TOTIME between @Second_Half_Start and @Second_Half_END))  
              SET @FLAG = 1                 
                 
            END  
            else   --Without Inout time case set flag value  
            begin  
             SET @FLAG = 2  
            end  
                             
              
            if @FLAG = 1  --Added by Jaina 19-06-2017  
            BEGIN  
               
             if @Raise_Error = 0  

              SELECT  'Leave on particular date already exists.' As [Status]  
             ELSE  
              RAISERROR('@@Leave on particular date already exists.@@',16,2)      
             RETURN  
            END  
              
            if @FLAG = 2  
            begin  
             IF ((@TEMP_LEAVE_TYPE = @LEAVE_TYPE or @LEAVE_TYPE = 'Full Day')   
              or (@HALF_LEAVE_DATE =  @TEMP_DATE and (@TEMP_LEAVE_TYPE = @LEAVE_TYPE or @LEAVE_TYPE = 'Full Day')))  
             begin  
              if @Raise_Error = 0  
               SELECT  'Leave on particular date already exists.' As [Status]  
              ELSE  
               RAISERROR('@@Leave on particular date already exists.@@',16,2)      
              RETURN  
             end  
            end  
            
          End       
        END  
      END   
     ELSE  
      BEGIN  
         
       --Leave App -> Approval / Leave Approval / Leave Approval -> Partial Cancellation  
      
       IF EXISTS(SELECT 1 FROM T0140_LEAVE_TRANSACTION WITH (NOLOCK) WHERE For_Date = @TEMP_DATE AND Emp_ID=@EMP_ID AND (Leave_Used > 0 Or Isnull(Back_Dated_Leave,0)>0 Or (CompOff_Used - Leave_Encash_Days) > 0))  
        BEGIN   
		
         if @Raise_Error = 0  
          BEGIN  
           SELECT  'Leave on particular date already exists.' As [Status]  
          END  
         ELSE  
          RAISERROR('@@Leave on particular date already exists.@@',16,2)      
         RETURN  
        END  
       --Leave App Only Without Approval  
         
        
             
       IF EXISTS(SELECT 1 FROM T0100_LEAVE_APPLICATION LA WITH (NOLOCK)  
           INNER JOIN T0110_LEAVE_APPLICATION_DETAIL LAD WITH (NOLOCK) ON LA.Leave_Application_ID=LAD.Leave_Application_ID  
           WHERE LA.Emp_ID=@EMP_ID AND @TEMP_DATE BETWEEN FROM_DATE AND TO_DATE AND LAD.Leave_Application_Id  <> @Leave_Application_Id  
           AND NOT EXISTS(SELECT 1 FROM T0120_LEAVE_APPROVAL LA1 WITH (NOLOCK) WHERE LA1.Leave_Application_ID=LA.Leave_Application_ID))  
        BEGIN  
                           
         if @Raise_Error = 0  
          SELECT  'Leave on particular date already exists.' As [Status]  
         ELSE  
          RAISERROR('@@Leave on particular date already exists.@@',16,2)      
         RETURN  
        END  
      END  
     SET @TEMP_DATE = DATEADD(d, 1, @TEMP_DATE);  
    END  
  END   
 END  