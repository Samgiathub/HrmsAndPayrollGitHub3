  
  
-- =============================================  
-- Author:  Nimesh Parmar  
-- ALTER date: 17 Dec,2015  
-- Description: This procedure is used to give cancel weekoff effect after getting  
--    weekoff detail from SP_EMP_HOLIDAY_WEEKOFF_ALL procedure.  
-- =============================================  
CREATE PROCEDURE [dbo].[SP_EMP_WEEKOFF_DATE_GET_ALL]  
 @Constraint   varchar(max)  
 ,@Cmp_ID   numeric  
 ,@From_Date   Datetime  
 ,@To_Date   Datetime  
 ,@All_Weekoff   BIT =0 --0 : With Cancel Weekoff; 1: All Weekoff (Without cancelling weekoff)  
 ,@Is_FNF tinyint =0  
 ,@Is_Leave_Cal tinyint = 0  
 ,@Allowed_Full_WeekOff_MidJoining tinyint = 0  
 ,@Type numeric = 0  
 ,@Use_Table tinyint = 0  
AS   
 SET NOCOUNT ON;  
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;  
 SET ARITHABORT ON;    
   
 DECLARE @Month int;  
 DECLARE @Year int;  
 DECLARE @WeekDay varchar(100);  
 DECLARE @Start datetime;  
 DECLARE @End datetime ;  
 DECLARE @EMP_ID numeric;  
 DECLARE @Cancel_WeekOff NUMERIC(5,1);  
 DECLARE @CancelHolidayIfOneSideAbsent tinyint  
   
 SET @month = MONTH(@TO_DATE);  
 SET @YEAR = YEAR(@TO_DATE);  
   
 SET @Start=DATEADD(mm,@Month-1,DATEADD(yy,@Year-1900,0));  
 SET @End=@To_Date  
   
    
 IF (OBJECT_ID('tempdb..#EMP_HW_CONS') IS NULL)  
  CREATE table #EMP_HW_CONS  
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
   
   
 IF NOT EXISTS (SELECT 1 FROM #EMP_HW_CONS)  
 BEGIN    
 -- select @Cmp_ID, @From_Date, @To_Date, 1, @Constraint  
  EXEC dbo.SP_EMP_HOLIDAY_WEEKOFF_ALL  @Cmp_ID, @From_Date, @To_Date, 1, @Constraint  
 END   
   
   
 DECLARE @Var_All_H_Date VARCHAR(MAX);  
 DECLARE @WeekOff varchar(10);  
 DECLARE @For_Date datetime;  
 DECLARE @Weekoff_Day_Val numeric(9,2);  
 DECLARE @Pre_Date_WeekOff DATETIME;  
 DECLARE @Next_Date_WeekOff DATETIME;  
 DECLARE @Join_Date DATETIME;  
 DECLARE @Left_Date DATETIME;  
 DECLARE @Prev_Emp Numeric;   
 DECLARE @Is_Cancel BIT;  
 DECLARE @strHoliday_Date VARCHAR(MAX);  
 DECLARE @shift_ID int  
 
 DECLARE @Branch_Id Numeric;  
 DECLARE @Genral_Cancel_Weekoff NUMERIC;  
   
 DECLARE @strHoliday_Output varchar(max);  
  
 DECLARE @Has_Leave_Pre_Next tinyint  
   
 DECLARE @NEXT_EFF_DATE DATETIME   
 SET @NEXT_EFF_DATE  = @FROM_DATE  
   
 SET @Prev_Emp = 0;  
   
 declare @cnt_leave_pre_next_weekoff numeric(5,1)  
 declare @temp_cnt_leave_pre_next_weekoff numeric(5,1)  
 declare @chk_leave_setting_for_leave_as_weekoff as tinyint  
 declare @is_sandwitch_leave_od bit  
   
 DECLARE @Reverse_Leave_Cancel_Sett NUMERIC --Ankit 16032016  
 SET @Reverse_Leave_Cancel_Sett = 0  
 SELECT @Reverse_Leave_Cancel_Sett = Setting_Value   
 FROM T0040_SETTING   
 WHERE Cmp_ID = @Cmp_ID AND Setting_Name = 'Reverse Current WO/HO Cancel Policy'  
   
 DECLARE @CANCEL_REASON VARCHAR(128);  
 DECLARE @LEAVE_TYPE VARCHAR(32);  
 DECLARE @FH_SH_LEAVE VARCHAR(32);  
 DECLARE @WO_LEAVE NUMERIC(5,2);  
 DECLARE @Pre_Leave as Numeric(5,2);  
 DECLARE @Next_Leave as Numeric(5,2);  
 DECLARE @Pre_Leave_FHSH as Varchar(16);  
 DECLARE @Next_Leave_FHSH as Varchar(16);  
 DECLARE @Pre_Leave_CancelWO as tinyint;  
 DECLARE @Next_Leave_CancelWO as tinyint;  
 DECLARE @Pre_Leave_Type VARCHAR(16)  
 DECLARE @Next_Leave_Type VARCHAR(16)  
  
 DECLARE @DEFAULT_CANCEL_WEEKOFF SMALLINT  
  
 SET @DEFAULT_CANCEL_WEEKOFF = -1  
 IF OBJECT_ID('tempdb..#WH_SETTINGS') IS NOT NULL  
  BEGIN  
   SELECT @DEFAULT_CANCEL_WEEKOFF = CANCEL_WEEKOFF FROM #WH_SETTINGS  
  END  
   
 DECLARE @Cancel_WO_HalfDay_Abs_Leave BIT  
 SELECT @Cancel_WO_HalfDay_Abs_Leave = Cast(IsNull(Setting_Value,0) As BIT)  
 FROM T0040_SETTING WITH (NOLOCK)  
 WHERE Setting_Name='Sandwich Policy not Applicable if Employee Present on before or after Holiday/WeekOff (QD/HF/3QD)'  
   AND Cmp_ID=@Cmp_ID  
   
  
 DECLARE @Max_Consecutive_Leave_Days_For_Cancel_WO TINYINT  
 SELECT @Max_Consecutive_Leave_Days_For_Cancel_WO = Cast(IsNull(Setting_Value,0) As TinyInt)  
 FROM T0040_SETTING  WITH (NOLOCK)  
 WHERE Setting_Name='Cancel Holiday/WeekOff if Leave applied for given Number of Days (Before Holiday/WeekOff)'  
   AND Cmp_ID=@Cmp_ID  
  
  
 DECLARE @Consecutive_Leave_Days DECIMAL(5,2)  
  
 Declare @LogReason BIT  
 SET @LogReason = 0  
 IF OBJECT_ID('tempdb..#Emp_Cancel_HOWO_Reason') IS NOT NULL  
  SET @LogReason = 1  
   
 DECLARE @ABS_DAYS DECIMAL(9,3)  
 
 
 Declare curWeekOff cursor fast_forward for  
      
    SELECT W.Emp_ID, W_Day,W.For_Date,W_Day ,ESD.Shift_ID 
 FROM #Emp_WeekOff W   
 INNER JOIN T0100_EMP_SHIFT_DETAIL ESD With (NOLOCK) ON ESD.Emp_ID = W.Emp_ID and ESD.for_date between @from_date and @To_date -- add by tejas at 19-11-2024 for support 31873
 ORDER BY W.Emp_ID  
   
 OPEN curWeekOff  
 FETCH NEXT FROM curWeekOff INTO @Emp_ID, @WeekOff ,@For_Date,@Weekoff_Day_Val,@shift_ID  
 WHILE (@@FETCH_STATUS=0)  
  BEGIN  
	
     
   if @Prev_Emp <> @Emp_ID OR (@NEXT_EFF_DATE IS NOT NULL AND  @For_Date >= @NEXT_EFF_DATE) OR @Branch_Id IS NULL  
   BEGIN  
    EXEC dbo.SP_EMP_JOIN_LEFT_DATE_GET @Emp_ID ,@Cmp_ID ,@From_Date,@To_date,@Join_Date OUTPUT,@Left_Date OUTPUT  
      
    SELECT @Branch_Id = Branch_ID   
    FROM dbo.T0095_Increment EI  WITH (NOLOCK)  
    WHERE Increment_ID = (  
          SELECT MAX(Increment_ID) AS Increment_ID   
          FROM dbo.T0095_Increment   WITH (NOLOCK)  
          WHERE Increment_Effective_date <= @To_Date  and Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID  
          )   
      and Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID   
      
    IF @DEFAULT_CANCEL_WEEKOFF > -1  
     SET @Genral_Cancel_Weekoff = @DEFAULT_CANCEL_WEEKOFF  
    ELSE  
     SELECT top 1 @Genral_Cancel_Weekoff = Is_Cancel_Weekoff,@CancelHolidayIfOneSideAbsent = Is_Cancel_Weekoff_IfOneSideAbsent  
     FROM dbo.T0040_GENERAL_SETTING GS  WITH (NOLOCK)  
     WHERE For_Date=(  
          SELECT MAX(For_Date) AS For_Date   
          FROM dbo.T0040_GENERAL_SETTING  WITH (NOLOCK)   
          WHERE For_Date <= @To_Date  AND Cmp_ID = @Cmp_ID and Branch_ID = @Branch_Id  
          ) and Branch_ID = @Branch_Id and Cmp_ID = @Cmp_ID  
           
     SELECT  @NEXT_EFF_DATE = MIN(FOR_DATE)  
     FROM dbo.T0040_GENERAL_SETTING   WITH (NOLOCK)  
     WHERE For_Date > @For_Date  AND Cmp_ID = @Cmp_ID and Branch_ID = @Branch_Id  
      
      
    IF @All_Weekoff = 1  
     SET @Genral_Cancel_Weekoff = 0;  
      
      
    IF @All_Weekoff <> 1   
    BEGIN       
     SET @Var_All_H_Date = NULL;  
     SET @strHoliday_Date = NULL;  
       
     SELECT @Var_All_H_Date=(ISNULL(WH.WeekOffDate,'') + ISNULL(WH.HolidayDate,'') + ISNULL(WH.OptHolidayDate,''))  
     FROM #Emp_WeekOff_Holiday WH  
     WHERE WH.Emp_ID=@EMP_ID  
       
     select @strHoliday_Date =  ISNULL(HolidayDate, '') + ISNULL(HalfHolidayDate, '')  
     from #EMP_HW_CONS  
     WHERE Emp_ID=@EMP_ID  
         
     --SET @Var_All_H_Date = IsNull(@strHoliday_Date, '') + IsNUll(@Var_All_H_Date, '');  
     if (@strHoliday_Date IS NULL)  
      set @strHoliday_Date = ''  
     if (@Var_All_H_Date IS NULL)  
      set @Var_All_H_Date = ''  
    END  
      
    DECLARE @HOLIDAY_COUNT NUMERIC  
    DECLARE @CANCEL_HOLIDAY_COUNT NUMERIC  
    ---EXEC SP_EMP_HOLIDAY_DATE_GET @EMP_ID,@Cmp_ID,@From_Date,@To_Date,@Join_Date,@Left_Date,0, @strHoliday_Output OUTPUT, @HOLIDAY_COUNT OUTPUT, @CANCEL_HOLIDAY_COUNT OUTPUT, 0, @Branch_Id  
      
      
    SET @Prev_Emp = @Emp_ID  
   END  
     
     
     
   SET @cnt_leave_pre_next_weekoff = 0  
   SET @temp_cnt_leave_pre_next_weekoff = 0  
   SET @chk_leave_setting_for_leave_as_weekoff = 0     
     
   SET @Has_Leave_Pre_Next = 0  
  
   SET @Is_Cancel = 0  
  
   --IF (CASE WHEN @Allowed_Full_WeekOff_MidJoining =1 THEN @From_Date  ELSE @Join_Date  END) > @For_Date  
   -- BEGIN  
   --  SET  @CANCEL_REASON = ' Allowed Full WeekOff MidJoining '  
   --  SET @Is_Cancel = 1  
   --  GOTO CONTINUE_LOOP;  
   -- END  
   --ELSE   
   IF CHARINDEX(CONVERT(VARCHAR(11),@For_Date,109),@strHoliday_Date,0) > 0  
    BEGIN  
     SET  @CANCEL_REASON = ' Holiday On Same Date (WeekOff Canceled)'  
     SET @Is_Cancel = 1  
     GOTO CONTINUE_LOOP;  
    END  
   ELSE IF @All_Weekoff = 1      
    GOTO CONTINUE_LOOP;        
   --For Sandwitch Policy  
   EXEC dbo.SP_RETURN_PRE_NEXT_DATE_OF_WEEKOFF @For_Date,@Var_All_H_Date,@Pre_Date_WeekOff OUTPUT,@Next_Date_WeekOff OUTPUT  
        

   --select @Pre_Date_WeekOff  
   SET @FH_SH_LEAVE = NULL;  
   SET @LEAVE_TYPE = NULL  
   SELECT @FH_SH_LEAVE = IsNull(Max(A.Leave_Assign_As),''),   
     @LEAVE_TYPE=IsNull(Max(L.Leave_Type), ''),   
     @WO_LEAVE = IsNull(SUM((CASE WHEN IsNull(T.CompOff_Used,0) > 0 THEN T.CompOff_Used ELSE T.Leave_Used END) - ISNULL(Leave_Encash_Days,0)),0)  
   FROM T0140_LEAVE_TRANSACTION T WITH (NOLOCK)  
     INNER JOIN T0040_LEAVE_MASTER L WITH (NOLOCK) ON T.LEAVE_ID=L.LEAVE_ID  
     INNER JOIN (SELECT LA.Emp_ID,LAD.Leave_Assign_As, LAD.From_Date,LAD.To_Date  
        FROM T0120_LEAVE_APPROVAL LA WITH (NOLOCK)   
          INNER JOIN T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) ON LA.Leave_Approval_ID=LAD.Leave_Approval_ID  
        WHERE LA.Emp_ID=@EMP_ID) A ON T.EMP_ID=A.EMP_ID AND T.FOR_DATE BETWEEN A.FROM_DATE AND A.TO_DATE  
   WHERE (IsNull(Leave_Used,0) + IsNull(CompOff_Used,0)) > 0 AND FOR_DATE = @For_Date --AND L.Leave_Type <>'Company Purpose'  
     AND T.Emp_ID=@EMP_ID  
  
  
   IF IsNull(@FH_SH_LEAVE,'') <> ''  
    SET @Weekoff_Day_Val = 1 - @WO_LEAVE          
  
     
   IF @Weekoff_Day_Val <= 0   
    BEGIN  
     SET  @CANCEL_REASON = ' Full Day Leave '  
     SET @Is_Cancel = 1  
     SET @Weekoff_Day_Val= 0  
     GOTO CONTINUE_LOOP;  
    END  
   
             
   IF @Genral_Cancel_Weekoff = 1  
    BEGIN  
     /*Sandwich Policy Start*/  
     /*Getting Total Leave used on Previous Day of WeekOff*/  
      
     SELECT @Pre_Leave= IsNull(SUM((CASE WHEN IsNull(T.CompOff_Used,0) > 0 THEN T.CompOff_Used ELSE T.Leave_Used END) - ISNULL(Leave_Encash_Days,0)),0)-ISNULL(SUM(Cn_Leave_period),0),   
       ---@Pre_Leave_FHSH=IsNull(MAX(A.Leave_Assign_As),''),   
       @Pre_Leave_FHSH=IsNull(Min(A.Leave_Assign_As),''),   
       @Pre_Leave_CancelWO=IsNull(Max(LM.Weekoff_as_leave),''),  
       @Pre_Leave_Type = IsNull(Max(LM.Leave_Type), '')  
     FROM T0140_LEAVE_TRANSACTION T WITH (NOLOCK)  
       INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON T.Leave_ID=LM.Leave_ID  
       INNER JOIN (SELECT LA.Emp_ID,LAD.Leave_Assign_As, LAD.From_Date,LAD.To_Date,Cn_Leave_period  
          FROM T0120_LEAVE_APPROVAL LA  WITH (NOLOCK)  
            INNER JOIN T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) ON LA.Leave_Approval_ID=LAD.Leave_Approval_ID  
            LEFT OUTER JOIN T0150_LEAVE_CANCELLATION LC WITH (NOLOCK) ON LA.Leave_Approval_id=LC.Leave_Approval_id AND LC.For_Date=@For_Date AND  
                LC.EMP_ID=LA.Emp_ID  
            ---- Add By jignesh  04-Mar-2020----  
              Left Outer Join (select Leave_Approval_ID,Isnull(Leave_period,0) as Cn_Leave_period from T0150_LEAVE_CANCELLATION WITH (NOLOCK) where Emp_id =@EMP_ID) as CNL  
              ON LA.Leave_Approval_ID=CNL.Leave_Approval_ID  
            -------- End ----  
           
          WHERE LA.Emp_ID=@EMP_ID AND LC.Tran_id IS NULL  
            
          ) A ON T.EMP_ID=A.EMP_ID AND T.FOR_DATE BETWEEN A.FROM_DATE AND A.TO_DATE  
            
     WHERE For_Date=@Pre_Date_WeekOff AND T.Emp_ID=@EMP_ID AND LM.Leave_Type <>'Company Purpose'         
       AND (Leave_Used > 0 Or CompOff_Used > 0) ---Added By Jimit 13062018 as case at RK LWP and PL exists for same date but LWP with Leave Used 0 count (03-06-2018 and Emp_Code : 3829)  
  
  
     IF @Pre_Leave_FHSH = 'First Half' AND @Pre_Leave = 0.5   
      SET @Pre_Leave = 0 --Only Second Half Leave should be considered as a consicutive to WeekOff Day  
  
       
     --select @Next_Leave_CancelWO --ronak  
     /*Getting Total Leave used on Next Day of WeekOff*/  
     SELECT @Next_Leave=IsNull(SUM((CASE WHEN IsNull(T.CompOff_Used,0) > 0 THEN T.CompOff_Used ELSE T.Leave_Used END) - ISNULL(Leave_Encash_Days,0)),0)-ISNULL(SUM(Cn_Leave_period),0),   
       @Next_Leave_FHSH=IsNull(MAX(A.Leave_Assign_As),''),   
       @Next_Leave_CancelWO=IsNull(Max(LM.Weekoff_as_leave),''),  
         
       @Next_Leave_Type = IsNull(Max(LM.Leave_Type), '')  
     FROM T0140_LEAVE_TRANSACTION T WITH (NOLOCK)  
       INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON T.Leave_ID=LM.Leave_ID  
       INNER JOIN (SELECT LA.Emp_ID,LAD.Leave_Assign_As, LAD.From_Date,LAD.To_Date,Cn_Leave_period  
          FROM T0120_LEAVE_APPROVAL LA  WITH (NOLOCK)  
            INNER JOIN T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) ON LA.Leave_Approval_ID=LAD.Leave_Approval_ID  
            LEFT OUTER JOIN T0150_LEAVE_CANCELLATION LC WITH (NOLOCK) ON LA.Leave_Approval_id=LC.Leave_Approval_id AND LC.For_Date=@For_Date AND  
                ----LC.EMP_ID=LA.Leave_Approval_ID  
                LC.EMP_ID=LA.EMP_ID  ----- Add By Jignesh 04-Mar-2020  
       ---- Add By jignesh  04-Mar-2020----  
        Left Outer Join (select Leave_Approval_ID,Isnull(Leave_period,0) as Cn_Leave_period from T0150_LEAVE_CANCELLATION  WITH (NOLOCK) where Emp_id =@EMP_ID) as CNL  
        ON LA.Leave_Approval_ID=CNL.Leave_Approval_ID  
       -------- End -----  
             
          WHERE LA.Emp_ID=@EMP_ID AND LC.Tran_id IS NULL  
  
          ) A ON T.EMP_ID=A.EMP_ID AND T.FOR_DATE BETWEEN A.FROM_DATE AND A.TO_DATE  
     WHERE For_Date=@Next_Date_WeekOff AND T.Emp_ID=@EMP_ID  AND LM.Leave_Type <>'Company Purpose'   
       AND (Leave_Used > 0 OR CompOff_Used > 0) ---Added By Jimit 13062018 as case at RK LWP and PL exists for same date but LWP with Leave Used 0 count (03-06-2018 and Emp_Code : 3829)       
       
     IF @Next_Leave_FHSH = 'Second Half' AND @Next_Leave = 0.5   
      SET @Next_Leave = 0  --Only First Half Leave should be considered as a consicutive to WeekOff Day  
        
          
     --IF OBJECT_ID('tempdb..#tmp') IS NOT NULL AND @For_Date = '2016-10-30'  
     -- SELECT *  
     -- FROM T0140_LEAVE_TRANSACTION T  
     --   INNER JOIN T0040_LEAVE_MASTER LM ON T.Leave_ID=LM.Leave_ID  
     --   INNER JOIN (SELECT LA.Emp_ID,LAD.Leave_Assign_As, LAD.From_Date,LAD.To_Date  
     --      FROM T0120_LEAVE_APPROVAL LA   
     --        INNER JOIN T0130_LEAVE_APPROVAL_DETAIL LAD ON LA.Leave_Approval_ID=LAD.Leave_Approval_ID  
     --      WHERE LA.Emp_ID=@EMP_ID) A ON T.EMP_ID=A.EMP_ID AND T.FOR_DATE BETWEEN A.FROM_DATE AND A.TO_DATE  
     -- WHERE For_Date=@Next_Date_WeekOff AND T.Emp_ID=@EMP_ID --AND (Leave_Used > 0 OR CompOff_Used > 0) --AND LM.Leave_Type <>'Company Purpose'         
       
     /*If Previous Day has Leave for Second Half or Full Day and Next Day have First Half or Full Day Leave  
     With Cancel Weekoff Policy*/  
      
     IF (@Pre_Leave >= 0.5 AND @Next_Leave >= 0.5) AND @Pre_Leave_Type <> 'Company Purpose'  AND @Next_Leave_Type <> 'Company Purpose'  
      AND @Pre_Leave_CancelWO = 1 AND @Next_Leave_CancelWO = 1   
      BEGIN
       SET  @CANCEL_REASON = ' Sandwich Policy : Prev: ' + @Pre_Leave_FHSH + ' - ' + Cast(@Pre_Leave as Varchar) + ', Next: ' + @Next_Leave_FHSH + ' - ' + Cast(@Next_Leave as Varchar)   
       SET @Is_Cancel = 1  
         
      END  
        
     /*If Previous Day has Leave for Second Half or Full Day and Next Day have First Half or Full Day Leave  
     With the Reverse Cancel Weekoff Policy*/  
      
     ELSE IF (@Pre_Leave >= 0.5 AND @Next_Leave >= 0.5) /*If Previous Day has Leave for Second Half or Full Day and Next Day have First Half or Full Day Leave*/  
       AND (@Pre_Leave_CancelWO = 1 OR @Next_Leave_CancelWO = 1)  
       AND @Reverse_Leave_Cancel_Sett = 1 AND (@Pre_Leave_Type <> 'Company Purpose'  OR @Next_Leave_Type <> 'Company Purpose')  
      BEGIN   
       SET  @CANCEL_REASON = ' Reverse Sandwich Policy : Prev: ' + @Pre_Leave_FHSH + ' - ' + Cast(@Pre_Leave as Varchar) + ', Next: ' + @Next_Leave_FHSH + ' - ' + Cast(@Next_Leave as Varchar)   
       SET @Is_Cancel = 1   
        
      END    
	 
     /*If Employee absent on Next Day of Weekoff for First Half Or Full Day  
     With Cancel Weekoff Policy*/  
     ELSE IF (NOT EXISTS(SELECT 1 FROM #DATA_WOHO   
          WHERE EMP_ID=@EMP_ID AND FOR_DATE = @Next_Date_WeekOff AND P_DAYS > 0) --For Next: Full Day Absent  
       OR EXISTS(SELECT 1 FROM #DATA_WOHO  
          WHERE EMP_ID=@EMP_ID AND FOR_DATE = @Next_Date_WeekOff   
            AND DATEDIFF(n,Shift_Start_Time, In_Time) > 130               
            AND IsNull(Chk_By_Superior,0)<>1)) --For Next: First Half Absent  
       AND @Next_Date_WeekOff <= GETDATE() AND @Pre_Date_WeekOff <= GETDATE()  
       AND (@Pre_Leave_Type <> 'Company Purpose'  OR @Next_Leave_Type <> 'Company Purpose' )  
       AND (@Next_Leave = 0  OR (@Next_Leave > 0 AND @Next_Leave_CancelWO = 1))  
      BEGIN   
			--For Prev: Full/Half Leave, Next : Full/Half Day Absent  
			IF (@Pre_Leave >= 0.5 AND @Pre_Leave_CancelWO = 1) OR (@Next_Leave = 0 AND @Pre_Leave > 0 AND @Reverse_Leave_Cancel_Sett=1)  
				BEGIN  
				
				 SET  @CANCEL_REASON = ' Sandwich Policy 1 : Prev: ' + @Pre_Leave_FHSH + ' - ' + Cast(@Pre_Leave as Varchar) + ', Next: Full/SH Day Absent'  
				 SET @Is_Cancel = 1  
				END  
			ELSE IF @Pre_Leave >= 0.5 AND @Pre_Leave_CancelWO = 0  
				BEGIN  
					
				 --DO NOTHING  
				 SET @Is_Cancel = 0;  
				END  
			ELSE IF NOT EXISTS(SELECT 1 FROM #DATA_WOHO  --For Prev: Full Absent, Next : Full/Half Day Absent  
				WHERE EMP_ID=@EMP_ID AND FOR_DATE = @Pre_Date_WeekOff AND P_DAYS > 0)   
				OR EXISTS(SELECT 1 FROM #DATA_WOHO  --For Prev: Second Half Absent, Next : Full/Half Day Absent  
				  WHERE EMP_ID=@EMP_ID AND FOR_DATE = @Pre_Date_WeekOff   
				    AND (OUT_TIME IS NULL OR  DATEDIFF(n,Out_Time, Shift_End_Time) > 130) --"OutTime Is Null" Condition for miss punch  
				    AND IsNull(Chk_By_Superior,0)<>1)   
				BEGIN
				 SET  @CANCEL_REASON = ' Sandwich Policy 1 : Both Side Full/Half Day Absent '  
				 SET @Is_Cancel = 1  
				    
				END    
		
      END  
	  
      --///////////////// Added By tejas at 29-08-2024 for slab wise sandwich policy ////////////////////////////////////////////////////
	 
	  /*If Employee absent on Next Day of Weekoff for First Half Or Full Day  
     With Cancel Weekoff Policy*/  
     ELSE IF (NOT EXISTS(SELECT 1 FROM #DATA_WOHO   
          WHERE EMP_ID=@EMP_ID AND FOR_DATE = @Next_Date_WeekOff AND P_DAYS > 0) --For Next: Full Day Absent  
       OR EXISTS(SELECT 1 FROM #DATA_WOHO  
				INNER JOIN V0050_SHIFT_DETAILs VS ON Vs.Cmp_ID = @Cmp_ID and VS.Shift_ID = @shift_ID and vs.Shift_Tran_ID <> 0 and vs.Calculate_Days = '0.50'
          WHERE EMP_ID=@EMP_ID AND FOR_DATE = @Next_Date_WeekOff   
            AND DATEDIFF(hh,In_Time, Out_Time) >= VS.From_Hour
			AND DATEDIFF(hh,In_Time, Out_Time) <= VS.To_Hour
            AND IsNull(Chk_By_Superior,0)<>1)) --For Next: First Half Absent  
       AND @Next_Date_WeekOff <= GETDATE() AND @Pre_Date_WeekOff <= GETDATE()  
       AND (@Pre_Leave_Type <> 'Company Purpose'  OR @Next_Leave_Type <> 'Company Purpose' )  
       AND (@Next_Leave = 0  OR (@Next_Leave > 0 AND @Next_Leave_CancelWO = 1))  
      BEGIN   
			
			--For Prev: Full/Half Leave, Next : Full/Half Day Absent  
			IF (@Pre_Leave >= 0.5 AND @Pre_Leave_CancelWO = 1) OR (@Next_Leave = 0 AND @Pre_Leave > 0 AND @Reverse_Leave_Cancel_Sett=1)  
				BEGIN  
				
				 SET  @CANCEL_REASON = ' Sandwich Policy 1 : Prev: ' + @Pre_Leave_FHSH + ' - ' + Cast(@Pre_Leave as Varchar) + ', Next: Full/SH Day Absent'  
				 SET @Is_Cancel = 1  
				END  
			ELSE IF @Pre_Leave >= 0.5 AND @Pre_Leave_CancelWO = 0  
				BEGIN  
					
				 --DO NOTHING  
				 SET @Is_Cancel = 0;  
				END  
			ELSE IF NOT EXISTS(SELECT 1 FROM #DATA_WOHO  --For Prev: Full Absent, Next : Full/Half Day Absent  
				WHERE EMP_ID=@EMP_ID AND FOR_DATE = @Pre_Date_WeekOff AND P_DAYS > 0)   
				OR EXISTS(SELECT 1 FROM #DATA_WOHO  --For Prev: Second Half Absent, Next : Full/Half Day Absent 
						INNER JOIN V0050_SHIFT_DETAILs VS ON Vs.Cmp_ID = @Cmp_ID and VS.Shift_ID = @shift_ID and vs.Shift_Tran_ID <> 0 and vs.Calculate_Days = '0.50'	
				  WHERE EMP_ID=@EMP_ID AND FOR_DATE = @Pre_Date_WeekOff   
				    AND (OUT_TIME IS NULL OR  DATEDIFF(hh,In_Time, Out_Time) >= VS.From_Hour) --"OutTime Is Null" Condition for miss punch  
					AND (OUT_TIME IS NULL OR  DATEDIFF(hh,In_Time, Out_Time) <= VS.To_Hour)
				    AND IsNull(Chk_By_Superior,0)<>1)   
				BEGIN
				 SET  @CANCEL_REASON = ' Sandwich Policy 1 : Both Side Full/Half Day Absent '  
				 SET @Is_Cancel = 1  
				    
				END    
		
      END  
	 
	  --/////////////////// End BY tejas //////////////////////////////////////////////////////////

     /*If Employee absent on Previous Day of Weekoff for First Half Or Full Day  
     With Cancel Weekoff Policy*/  
     ELSE IF (NOT EXISTS(SELECT 1 FROM #DATA_WOHO  --For Prev: Full Day Absent  
          WHERE EMP_ID=@EMP_ID AND FOR_DATE = @Pre_Date_WeekOff AND P_DAYS > 0)   
       OR EXISTS(SELECT 1 FROM #DATA_WOHO  --For Prev: Second Half Absent  
          WHERE EMP_ID=@EMP_ID AND FOR_DATE = @Pre_Date_WeekOff   
            AND (OUT_TIME IS NULL OR  DATEDIFF(n,Out_Time, Shift_End_Time) > 130)  
            AND IsNull(Chk_By_Superior,0)<>1) )  
       AND @Next_Date_WeekOff <= GETDATE() AND @Pre_Date_WeekOff <= GETDATE()  
       AND (@Pre_Leave_Type <> 'Company Purpose'  OR @Next_Leave_Type <> 'Company Purpose' )  
       AND (@Pre_Leave = 0 OR (@Pre_Leave > 0 AND @Pre_Leave_CancelWO = 1))  
      --select * from #DATA_WOHO --ronak  
      BEGIN    
       --IF @For_Date = '2017-08-26'  
       -- SELECT @Next_Leave_CancelWO  
       --For Prev: Full/Half Day Absent, Next : Full/Half Leave  
         
			IF (@Next_Leave >= 0.5 AND @Next_Leave_CancelWO = 1) OR (@Next_Leave > 0 AND @Pre_Leave = 0 AND @Reverse_Leave_Cancel_Sett=1)  
			BEGIN  
         SET  @CANCEL_REASON = ' Sandwich Policy 2 : Prev: Full/SH Day Absent, Next: ' + @Next_Leave_FHSH + ' - ' + Cast(@Next_Leave as Varchar)   
         SET @Is_Cancel = 1  
             
        END  
		ELSE IF @Next_Leave >= 0.5 AND @Next_Leave_CancelWO = 0  
			BEGIN  
         --DO NOTHING  
         SET @Is_Cancel = 0;  
        END  
       ELSE IF NOT EXISTS(SELECT 1 FROM #DATA_WOHO   
          WHERE EMP_ID=@EMP_ID AND FOR_DATE = @Next_Date_WeekOff AND P_DAYS > 0)  --For Prev: Full/Half Day Absent, Next : Full Absent  
         OR EXISTS(SELECT 1 FROM #DATA_WOHO   
          WHERE EMP_ID=@EMP_ID AND FOR_DATE = @Next_Date_WeekOff   
            AND DATEDIFF(n,Shift_Start_Time, In_Time) > 130  
            AND IsNull(Chk_By_Superior,0)<>1)  --For Prev: Full/Half Day Absent, Next : Half Day Absent  
			BEGIN      
				 SET  @CANCEL_REASON = ' Sandwich Policy 2 : Both Side Full/Half Day Absent '  
				 SET @Is_Cancel = 1  
          
        END         
      END  
       
--///////////////// Added By tejas at 29-08-2024 for slab wise sandwich policy ////////////////////////////////////////////////////       
	ELSE IF (NOT EXISTS(SELECT 1 FROM #DATA_WOHO  --For Prev: Full Day Absent  
          WHERE EMP_ID=@EMP_ID AND FOR_DATE = @Pre_Date_WeekOff AND P_DAYS > 0)   
       OR EXISTS(SELECT 1 FROM #DATA_WOHO  --For Prev: Second Half Absent  
				INNER JOIN V0050_SHIFT_DETAILs VS ON Vs.Cmp_ID = @Cmp_ID and VS.Shift_ID = @shift_ID and vs.Shift_Tran_ID <> 0 and vs.Calculate_Days = '0.50'		
          WHERE EMP_ID=@EMP_ID AND FOR_DATE = @Pre_Date_WeekOff   
            AND (OUT_TIME IS NULL OR  DATEDIFF(hh,In_Time, Out_Time) >= vs.From_Hour)
			AND (OUT_TIME IS NULL OR  DATEDIFF(hh,In_Time, Out_Time) <= vs.To_Hour)
            AND IsNull(Chk_By_Superior,0)<>1) )  
       AND @Next_Date_WeekOff <= GETDATE() AND @Pre_Date_WeekOff <= GETDATE()  
       AND (@Pre_Leave_Type <> 'Company Purpose'  OR @Next_Leave_Type <> 'Company Purpose' )  
       AND (@Pre_Leave = 0 OR (@Pre_Leave > 0 AND @Pre_Leave_CancelWO = 1))  
      --select * from #DATA_WOHO --ronak  
      BEGIN    
	  
       --IF @For_Date = '2017-08-26'  
       -- SELECT @Next_Leave_CancelWO  
       --For Prev: Full/Half Day Absent, Next : Full/Half Leave  
         
			IF (@Next_Leave >= 0.5 AND @Next_Leave_CancelWO = 1) OR (@Next_Leave > 0 AND @Pre_Leave = 0 AND @Reverse_Leave_Cancel_Sett=1)  
			BEGIN  
         SET  @CANCEL_REASON = ' Sandwich Policy 2 : Prev: Full/SH Day Absent, Next: ' + @Next_Leave_FHSH + ' - ' + Cast(@Next_Leave as Varchar)   
         SET @Is_Cancel = 1  
             
        END  
		ELSE IF @Next_Leave >= 0.5 AND @Next_Leave_CancelWO = 0  
			BEGIN  
         --DO NOTHING  
         SET @Is_Cancel = 0;  
        END  
       ELSE IF NOT EXISTS(SELECT 1 FROM #DATA_WOHO   
          WHERE EMP_ID=@EMP_ID AND FOR_DATE = @Next_Date_WeekOff AND P_DAYS > 0)  --For Prev: Full/Half Day Absent, Next : Full Absent  
         OR EXISTS(SELECT 1 FROM #DATA_WOHO
				 INNER JOIN V0050_SHIFT_DETAILs VS ON Vs.Cmp_ID = @Cmp_ID and VS.Shift_ID = @shift_ID and vs.Shift_Tran_ID <> 0 and vs.Calculate_Days = '0.50'			
          WHERE EMP_ID=@EMP_ID AND FOR_DATE = @Next_Date_WeekOff   
            AND DATEDIFF(hh,In_Time, Out_Time) >= vs.From_Hour
			AND DATEDIFF(hh,In_Time, Out_Time) <= vs.To_Hour
            AND IsNull(Chk_By_Superior,0)<>1)  --For Prev: Full/Half Day Absent, Next : Half Day Absent  
			BEGIN      
				 SET  @CANCEL_REASON = ' Sandwich Policy 2 : Both Side Full/Half Day Absent '  
				 SET @Is_Cancel = 1  
          
        END         
      END  
--/////////////////// End BY tejas //////////////////////////////////////////////////////////

  
     /*Following Condition added by Nimesh on 21-Jan-2019   
     (Corona - If any WeekOff canceled due to half day leave or absent or employee present even for half day before weekoff and after weekoff   
        and @Cancel_WO_HalfDay_Abs_Leave setting is off then WeekOff should not be canceled */  
     --select  @Cancel_WO_HalfDay_Abs_Leave,@Is_Cancel,@Pre_Leave_Type,@Pre_Date_WeekOff,@Next_Date_WeekOff,@EMP_ID  
  
     IF @Cancel_WO_HalfDay_Abs_Leave = 1 AND @Is_Cancel = 1  
      AND @Pre_Leave_Type <> 'Company Purpose'  AND @Next_Leave_Type <> 'Company Purpose'   
      AND EXISTS(SELECT 1 FROM #DATA_WOHO D WHERE D.EMP_ID=@EMP_ID AND (D.For_Date BETWEEN @Pre_Date_WeekOff AND @Next_Date_WeekOff) AND P_Days > 0)          
      BEGIN    
       SET  @CANCEL_REASON = '';  
       SET @Is_Cancel = 0  
      END     
       
     if @CancelHolidayIfOneSideAbsent = 1 and ((@Pre_Leave >= 1 and @Pre_Leave_Type <> 'Company Purpose') or (@Next_Leave >= 1 and @Next_Leave_Type <> 'Company Purpose')) AND @Is_Cancel = 1  
     begin  
      SET  @CANCEL_REASON = ' Sandwich Policy new : one side Full Day Absent '  
      SET @Is_Cancel = 1  
        
     end  
     
	 if @CancelHolidayIfOneSideAbsent = 1  
     begin        
      IF NOT EXISTS(SELECT 1 FROM #DATA_WOHO   
         WHERE EMP_ID=@EMP_ID AND (FOR_DATE = @Pre_Date_WeekOff) )  --For Prev: Full/Half Day Absent, Next : Full Absent             
       BEGIN             
        SET  @CANCEL_REASON = ' Sandwich Policy new : one side Full day absent '  
        SET @Is_Cancel = 1  
           
       END   
         
       IF NOT EXISTS(SELECT 1 FROM #DATA_WOHO   
         WHERE EMP_ID=@EMP_ID AND (FOR_DATE = @Next_Date_WeekOff) )  --For Prev: Full/Half Day Absent, Next : Full Absent             
       BEGIN             
        SET  @CANCEL_REASON = ' Sandwich Policy new : one side Full Day Absent '  
        SET @Is_Cancel = 1  
          
       END   
     end  
      
     IF @Is_Cancel  = 0 AND @Max_Consecutive_Leave_Days_For_Cancel_WO > 0  
      Begin  
  
       --- Added by Hardik 16/09/2019 for Shoft Shipyard for before 3 days there is holiday or weekoff then it should skip and check before days.  
       DECLARE @Max_Pre_Date_Temp DATETIME  
       DECLARE @Max_Pre_Date DATETIME  
       DECLARE @Counter INT = 0  
  
       SET @Max_Pre_Date_Temp = DateAdd(D,(@Max_Consecutive_Leave_Days_For_Cancel_WO - 1) * -1, @Pre_Date_WeekOff)  
  
       WHILE @Counter = 0  
        BEGIN   
         IF CHARINDEX(CAST(@Max_Pre_Date_Temp as varchar(11)),@Var_All_H_Date,0) = 0   
          BEGIN  
           SET @Counter = 1  
           SET @Max_Pre_Date = @Max_Pre_Date_Temp  
          END  
         SET @Max_Pre_Date_Temp = dateadd(d,-1,@Max_Pre_Date_Temp)     
        END  
       --- End Hardik 16/09/2019 for Shoft Shipyard for before 3 days there is holiday or weekoff then it should skip and check before days.         
               
       SET @ABS_DAYS = @Max_Consecutive_Leave_Days_For_Cancel_WO  
       SELECT @ABS_DAYS = @ABS_DAYS - IsNull(Sum(P_DAYS),0)  
       FROM #DATA_WOHO D  
       WHERE D.Emp_ID=@EMP_ID AND D.For_Date BETWEEN @Max_Pre_Date AND @Pre_Date_WeekOff  
         
       SELECT @Consecutive_Leave_Days = IsNull(Sum(Case When LM.Apply_Hourly = 1 AND Leave_Used > 1 Then Leave_Used * 0.125 Else Leave_Used End + CompOff_Used),0)  
       FROM T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)  
         INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LT.Leave_ID=LM.Leave_ID  
       WHERE For_Date  BETWEEN DateAdd(D,(@Max_Consecutive_Leave_Days_For_Cancel_WO - 1) * -1, @Pre_Date_WeekOff) AND @Pre_Date_WeekOff  
         AND Emp_ID=@EMP_ID AND (Leave_Used > 0 OR CompOff_Used > 0) AND Leave_Type <> 'Company Purpose'  
         
       SET @ABS_DAYS = @ABS_DAYS - @Consecutive_Leave_Days  
         
       IF (@Consecutive_Leave_Days + @ABS_DAYS) >= @Max_Consecutive_Leave_Days_For_Cancel_WO AND @Pre_Leave_Type <> 'Company Purpose' AND @Next_Leave_Type <> 'Company Purpose'  
        BEGIN   
         -- After take 3 Consecutive leave week-off should be cancelled but if employee is working on week-off day consider it as OT   
         -- Added by Nilesh Patel on 12072019  
          
         IF Not Exists(SELECT 1 From T0150_EMP_INOUT_RECORD  WITH (NOLOCK) Where Emp_ID = @EMP_ID and For_Date = @For_Date)  
          Begin  
           SET  @CANCEL_REASON = ' Sandwich Policy 3 : Leave has been taken Before WeekOff for ' + Cast(@Consecutive_Leave_Days as varchar(5)) + ' consecutive days'  
           SET @Is_Cancel = 1  
           
          End   
        END         
      End    
  
     IF @Is_Cancel = 1  
      GOTO CONTINUE_LOOP;  
  
     /*Sandwich Policy End*/  
  
    END  

CONTINUE_LOOP:  
  
   IF (@Is_Cancel = 1 OR @Weekoff_Day_Val <> 1)     
    BEGIN       
     UPDATE #Emp_WeekOff  
     SET  Is_Cancel = @Is_Cancel, W_Day = @Weekoff_Day_Val  
     WHERE Emp_ID=@EMP_ID AND For_Date=@For_Date  
       
     --IF (@CANCEL_REASON  <> '')  
     -- PRINT 'WEEKOFF CANCEL REASON ' + @CANCEL_REASON  + ' FOR ' + CONVERT(VARCHAR(10), @For_Date,103)  
       
     if @LogReason = 1  
      INSERT INTO #Emp_Cancel_HOWO_Reason(Emp_ID,For_Date,HW_Flag,HW_Day,Reason)  
      Values (@EMP_ID,@For_Date,'WO', @Weekoff_Day_Val, @CANCEL_REASON)  
  
     SET @CANCEL_REASON  = '';       
    END  
     
              
   SET @For_Date = dateadd(d,1,@For_Date)  
   FETCH NEXT FROM curWeekOff INTO @Emp_ID, @WeekOff ,@For_Date,@Weekoff_Day_Val,@shift_ID  
  END  
    
 CLOSE curWeekOff  
 DEALLOCATE curWeekOff  
  
 /**CANCEL WEEKOFF FROM ROSTER**/  
 --Modified by Nimesh on 04-April-2016  
 --Commented and moved following query to SP_EMP_HOLIDAY_WEEKOFF_ALL stored procedure  
 --To take cancel weekoff effect for Sandwitch Policy  
   
    
 --UPDATE #Emp_WeekOff SET Is_Cancel=1, W_Day=0  
 --FROM #Emp_WeekOff E INNER JOIN T0100_WEEKOFF_ROSTER R ON R.For_date=E.For_Date AND E.Emp_ID=R.Emp_id   
 --WHERE R.is_Cancel_WO=1    
   
 --INSERT INTO #Emp_WeekOff   
 --SELECT 0, R.EMP_ID, R.FOR_DATE,DATENAME(dw, R.FOR_DATE),1, 0  
 --FROM T0100_WEEKOFF_ROSTER R  
 --  INNER JOIN (SELECT CAST(DATA AS NUMERIC) AS Emp_ID FROM dbo.Split(@Constraint, '#') T Where Data <> '')  T on R.Emp_id=T.Emp_ID  
 --WHERE NOT EXISTS(SELECT 1 FROM #Emp_WeekOff E WHERE E.Emp_ID=R.Emp_id AND E.For_Date=R.For_date)  
 --  AND R.is_Cancel_WO=0 and For_date between @from_date and @To_date  
     
 /**CANCEL WEEKOFF FROM ROSTER**/  
  
   
 UPDATE #EMP_HW_CONS  
 SET  WeekOffDate   = W1.WeekOff,  
   WeekOffCount  = W1.WeekOffCount,  
   CancelWeekOff  = W1.CancelWeekOff,  
   CancelWeekOffCount = W1.CancelWeekOffCount  
 FROM (  
    SELECT IsNull(REPLACE(REPLACE((  
         SELECT ';' + CAST(W.For_Date AS VARCHAR(11)) AS FOR_DATE FROM #Emp_WeekOff W  
         WHERE W.Emp_ID = W1.Emp_ID AND W_Day <> 0 FOR XML PATH('')  
        ), '<FOR_DATE>', ''), '</FOR_DATE>', ''), '') WeekOff,  
      Sum(W1.W_Day) As WeekOffCount,  
      IsNull(REPLACE(REPLACE((  
         SELECT ';' + CAST(W.For_Date AS VARCHAR(11)) AS FOR_DATE FROM #Emp_WeekOff W  
         WHERE W.Emp_ID = W1.Emp_ID AND Is_Cancel = 1 FOR XML PATH('')  
        ), '<FOR_DATE>', ''), '</FOR_DATE>', ''), '') As CancelWeekOff,  
      Sum(Cast(W1.Is_Cancel As Numeric)) As CancelWeekOffCount, W1.Emp_ID  
    FROM #Emp_WeekOff W1   
    GROUP BY W1.Emp_ID  
   ) W1  
 WHERE W1.EMP_ID=#EMP_HW_CONS.Emp_ID  
  
---Ronak --Weekoff_as_leave parameter check -if checkbox value 0 then set W
