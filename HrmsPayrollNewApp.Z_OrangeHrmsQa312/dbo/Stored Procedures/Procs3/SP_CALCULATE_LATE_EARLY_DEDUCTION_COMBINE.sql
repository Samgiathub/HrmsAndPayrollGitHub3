

-- Create By : Nilesh Patel
-- Create Date : 04-06-2018 
-- Description : For Late and Early count deduction combine
---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_CALCULATE_LATE_EARLY_DEDUCTION_COMBINE]
     @emp_Id                NUMERIC
    ,@Cmp_ID                NUMERIC
    ,@Month_St_Date         DATETIME
    ,@Month_End_Date        DATETIME
    ,@Late_Sal_Dedu_Days    NUMERIC(18,1) OUTPUT
    ,@Total_LMark           INT  OUTPUT
    ,@Total_Late_Sec        NUMERIC OUTPUT
    ,@Increment_ID          NUMERIC 
    ,@StrWeekoff_Date       VARCHAR(max)= '' -- Added by Hardik 10/09/2012
    ,@StrHoliday_Date       VARCHAR(max)= '' -- Added by Hardik 10/09/2012
    ,@Return_Record_Set     NUMERIC =0
    ,@var_Return_Late_Date  VARCHAR(max) = '' OUTPUT
    ,@Return_Late_Date_Table TINYINT = 0
    ,@Absent_Date_String    VARCHAR(max) = '' -- Added by Gadriwala Muslim 25062015
    ,@Temp_Extra_Count      NUMERIC(18,0) = 0 OUTPUT    --For Extra Exemption in Late/Earlly Panalaty Days  --Ankit 29102015
	,@Report_Flag			NUMERIC = 0
	,@Sal_Tran_ID			NUMERIC = 0
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
    
    DECLARE @In_Date            DATETIME
    DECLARE @Shift_St_Time      VARCHAR(10)
    DECLARE @Shift_St_DATETIME  DATETIME
    DECLARE @Curr_Month_LMark   numeric (18,1)
    DECLARE @Curr_Month_LMark_WithOut_Exemption numeric (18,1)
    DECLARE @LMark_BF           NUMERIC(18,1)
    DECLARE @var_Shift_St_Date  VARCHAR(20)
    DECLARE @numWorkingHoliday  NUMERIC(18,1)
    DECLARE @Emp_Late_Limit     VARCHAR(10)
    DECLARE @Late_Limit_Sec     NUMERIC
    DECLARE @Late_Adj_Day       INT
    DECLARE @Branch_ID          NUMERIC 
    DECLARE @Emp_Late_Mark      INT
    DECLARE @Late_Dedu_Days     NUMERIC(5,1)
    DECLARE @Late_Dedu_Type     VARCHAR(10)
    DECLARE @numPresentDays     NUMERIC(12,1)
    DECLARE @month              NUMERIC
    DECLARE @varMonth           VARCHAR(10)
    DECLARE @Late_With_leave    NUMERIC(1,0)
    DECLARE @Year               NUMERIC
    DECLARE @Is_Late_CF         NUMERIC
    DECLARE @Late_CF_Reset_On   VARCHAR(50)
    DECLARE @Shift_St_Time_Half_Day     VARCHAR(10)
    DECLARE @is_Half_Day        TINYINT
    DECLARE @Late_Exempted_Days NUMERIC(5,2) --Alpesh 07-Oct-2011
    DECLARE @RoundingValue      NUMERIC(18,2) -- added by mitesh on 08/11/2011
    DECLARE @Is_Late_calc_On_HO_WO TINYINT
    DECLARE @Temp_Branch_ID     NUMERIC
    DECLARE @Is_LateMark        TINYINT
    DECLARE @Late_Exempted_limit VARCHAR(10) -- added by mitesh on 24/01/2012
    DECLARE @Late_Exempted_limit_sec numeric -- added by mitesh on 24/01/2012
    DECLARE @Shift_Exemption_St_DATETIME DATETIME -- added by mitesh on 24/01/2012
    --Alpesh 18-Jul-2012
    DECLARE @Max_Late_Limit     VARCHAR(50) 
    DECLARE @Shift_Max_Late_Time DATETIME
    DECLARE @Out_Date           DATETIME    
    DECLARE @Shift_End_Time     VARCHAR(10)
    DECLARE @var_Shift_End_Date VARCHAR(20)
    DECLARE @Shift_End_Time_Half_Day VARCHAR(10)
    --- End ---
    
    ----Extra Exemption --Ankit 03112015
    DECLARE @Shift_Time_Sec     NUMERIC(18,0)   
    DECLARE @Working_Time_Sec   NUMERIC(18,0)   
    DECLARE @Extra_exemption_limit VARCHAR(10)
    DECLARE @Extra_Count_Exemption NUMERIC(18,2)
    DECLARE @Extra_Exemption    NUMERIC(18,0)
	DECLARE @Shift_Exemption_St_MAX_DATETIME DATETIME
    SET @Temp_Extra_Count = 0
    SET @Extra_Exemption = 0
    SET @Shift_Time_Sec = 0
    SET @Working_Time_Sec = 0
    SET @Extra_Count_Exemption = 0
    SET @Extra_exemption_limit = 0
    ----Extra Exemption
            
    SET @Curr_Month_LMark   = 0
    SET @Curr_Month_LMark_WithOut_Exemption = 0
    SET @numWorkingHoliday  = 0
    SET @LMark_BF = 0
    SET @Late_Dedu_Days =0
    SET @Total_Late_Sec =0
    SET @Month  = Month(@Month_st_Date)
    SET @varMonth = @Month
    SET @varMonth = '#' + @varMonth + '#'
    SET @RoundingValue = 0

  
    SET @Year   = Year(@Month_st_Date)
    SET @var_Return_Late_Date = ''
    SET @Is_Late_calc_On_HO_WO = 0
    SET @Is_LateMark = 0

	--For Early Mark 
	Declare @Emp_Early_Mark Numeric(18,0)
	DECLARE @Early_Adj_Day		int
	DECLARE @Early_Dedu_Days	numeric(5,1)
	DECLARE @Early_Dedu_Type	varchar(10)
	DECLARE @Early_Exempted_Days numeric(5,2)
	DECLARE @Max_Early_Limit	varchar(50)
	DECLARE @Early_Exempted_limit varchar(10)
	DECLARE @Shift_End_DateTime	datetime
	DECLARE @Shift_Max_Early_Time datetime
	DECLARE @Emp_Early_Limit	varchar(10)
	DECLARE @Early_Limit_Sec	numeric
	DECLARE @Early_Exempted_limit_sec numeric
	DECLARE @Is_Early_Mark		Numeric
	DECLARE @Shift_Exemption_End_DateTime datetime
	Declare @var_Return_Early_Date Varchar(max)

	Set @Emp_Early_Mark = 0
	Set @Early_Adj_Day = 0
	Set @Early_Dedu_Days = 0
	Set @Early_Dedu_Type = 0
	Set @Early_Exempted_Days = 0
	Set @Max_Early_Limit = ''
	Set @Early_Exempted_limit = ''
	SET @Early_Limit_Sec = 0
	SET @Early_Exempted_limit_sec = 0
	SET @Is_Early_Mark = 0
	Set @var_Return_Early_Date = ''

	Declare @Chk_Last_Late_Early_Month Numeric(2,0)
	Set @Chk_Last_Late_Early_Month = 0

    -- Added by nilesh on  03-Feb-2018 Add For GrindMaster -- Wrong Branch consider in case of tansfer branch
    Select TOP 1 @Increment_ID = Increment_ID 
		 From T0095_INCREMENT WITH (NOLOCK) Where Increment_Effective_Date <= @Month_End_Date and Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID
    order BY Increment_Effective_Date DESC

    SELECT  @Emp_Late_Mark = isnull(Emp_Late_Mark,0),
			@Emp_Late_Limit = ISNULL(Emp_Late_Limit,'00:00'),
			@Branch_ID =Branch_ID,
            @Late_Dedu_Type = Late_Dedu_Type,
			@Emp_Early_Mark = isnull(Emp_Early_mark,0),
			@Emp_Early_Limit = isnull(Emp_Early_Limit,'00:00')
    FROM    T0095_Increment I WITH (NOLOCK)
    WHERE   I.Emp_ID = @emp_ID and Increment_Id =@Increment_ID  

	Declare @Early_Deduction Numeric(3,2)
	Set @Early_Deduction = 0
	Declare @Late_Deduction Numeric(3,2)
	Set @Late_Deduction = 0

    CREATE TABLE #Absent_Dates  -- Added by Gadriwala Muslim 25062015 - Start
    (
        Absent_date DATETIME
    )
    
    IF @Absent_Date_String <> ''
        BEGIN
            INSERT INTO #Absent_Dates(Absent_date)
            SELECT data FROM dbo.Split(@Absent_Date_String,'#')
        END
    

    SELECT  @Late_Adj_Day =  isnull(Late_Adj_Day,0),
			@Late_Dedu_Days = isnull(Late_Deduction_Days,0),
            @Late_CF_Reset_On = isnull(Late_CF_Reset_On,''),   
			@Is_Late_CF = isnull(Is_Late_CF,0),
			@Late_With_leave =Late_with_Leave,
            @Late_Exempted_Days = Isnull(Late_Count_Exemption,0),
            @RoundingValue  = ISNULL(Late_Hour_Upper_Rounding,0),
            @Late_Exempted_limit = ISNULL(late_exemption_limit,'00:00'), 
            @Max_Late_Limit=ISNULL(Max_Late_Limit,'00:00'),
            @Extra_exemption_limit = CASE WHEN LateEarly_Exemption_MaxLimit = '' THEN '00:00' ELSE ISNULL(LateEarly_Exemption_MaxLimit,'00:00') END,
            @Extra_Count_Exemption = ISNULL(LateEarly_Exemption_Count,0),
			@Early_Adj_Day =  isnull(Early_Adj_Day,0),
			@Early_Dedu_Days = isnull(Early_Deduction_Days,0),
			@Early_Dedu_Days = isnull(Early_Deduction_Days,0),
			@Early_Exempted_Days = Isnull(Early_Count_Exemption,0),
			@Max_Early_Limit = ISNULL(Max_Early_Limit,'00:00'),
			@Early_Exempted_limit  = ISNULL(early_exemption_limit,'00:00'),
			@Chk_Last_Late_Early_Month = Isnull(Chk_Last_Late_Early_Month,0)
    FROM    T0040_GENERAL_SETTING G WITH (NOLOCK)
            INNER JOIN (
                            SELECT  MAX(For_Date) AS For_Date 
                            FROM    T0040_GENERAL_SETTING  WITH (NOLOCK)   
                            WHERE   cmp_id = @cmp_id AND For_Date <=@Month_End_Date AND Branch_ID=@Branch_ID
                        )  G1 ON G.For_Date=G1.For_Date
    WHERE   Cmp_ID = @Cmp_ID and Branch_ID =@Branch_ID 
            
	
    SELECT @Late_Limit_Sec  = dbo.F_Return_Sec(@Emp_Late_Limit)
    SELECT @Late_Exempted_limit_sec = dbo.F_Return_Sec(@Late_Exempted_limit)    -- added by mitesh on 24/01/2012

	select @Early_Limit_Sec	= dbo.F_Return_Sec(@Emp_Early_Limit)				
	select @Early_Exempted_limit_sec	= dbo.F_Return_Sec(@Early_Exempted_limit)

	Declare @Flag_Laps_Exemption_Count Numeric
	Set @Flag_Laps_Exemption_Count = 0

	------------------- Late Validation for Enpay ----------------------
	IF @Chk_Last_Late_Early_Month > 0 
		Begin
			if OBJECT_ID('tempdb..#Last_Late_Early_Mark') is not null
				Begin
					Drop Table #Last_Late_Early_Mark
				End
			
			Create Table #Last_Late_Early_Mark
			(
				Emp_ID Numeric,
				Late_Early_Count Numeric,
				Sal_Month Numeric,
				Sal_Year Numeric
			)

			Declare @From_Laps_Date Datetime
			Set @From_Laps_Date = DATEADD(m,(@Chk_Last_Late_Early_Month * -1),@Month_End_Date)

			Declare @Last_Month_Count Numeric
			Set @Last_Month_Count = 0
			
			While @From_Laps_Date <= @Month_St_Date
				Begin
					Insert into #Last_Late_Early_Mark
					Select @Emp_ID,0,Month(@From_Laps_Date),Year(@From_Laps_Date)

					Update LM
						SET Late_Early_Count = Isnull(Qry.LateCount,0) + Isnull(Qry_1.EarlyCount,0)
					From #Last_Late_Early_Mark LM
						 Inner Join(
									Select Count(1) as LateCount,Sal_Month,Sal_Year,Emp_ID From T0160_Late_Early_Validation WITH (NOLOCK)
										Where Emp_ID = @Emp_ID and Flag_No_Exepmtion = 0 and Isnull(Late_Sec,0) > 0 
									Group by Sal_Month,Sal_Year,Emp_ID
								   ) as Qry
						 ON LM.Emp_ID = Qry.Emp_ID and LM.Sal_Month = Qry.Sal_Month and LM.Sal_Year = Qry.Sal_Year	
						 Inner Join(
									Select Count(1) as EarlyCount,Sal_Month,Sal_Year,Emp_ID From T0160_Late_Early_Validation WITH (NOLOCK)
										Where Emp_ID = @Emp_ID and Flag_No_Exepmtion = 0 and Isnull(Early_Sec,0) > 0 
									Group by Sal_Month,Sal_Year,Emp_ID
								   ) as Qry_1
						 ON LM.Emp_ID = Qry_1.Emp_ID and LM.Sal_Month = Qry_1.Sal_Month and LM.Sal_Year = Qry_1.Sal_Year
					
					Set @From_Laps_Date = DateAdd(m,1,@From_Laps_Date)
				End 

			Select @Last_Month_Count = Count(1)
				From #Last_Late_Early_Mark
				Where Emp_ID = @Emp_ID and Late_Early_Count >= (@Late_Exempted_Days + @Extra_Count_Exemption)


			If @Chk_Last_Late_Early_Month = @Last_Month_Count
				SET @Flag_Laps_Exemption_Count = 1

		End
	

	------------------- Late Validation for Enpay ----------------------

    CREATE TABLE #Late_Data
    (
        Emp_ID          NUMERIC,
        Cmp_ID          NUMERIC,
        [Month]         NUMERIC,
        [Year]          NUMERIC,
        Late_Balance_BF NUMERIC,
        Curr_M_Late     NUMERIC,
        Total_Late      NUMERIC,
        To_Be_Adj       NUMERIC,
        Leave_ID        NUMERIC,
        Leave_Bal       NUMERIC(5,1),
        Adj_Again_Leave NUMERIC,
        Dedu_Leave_Bal  NUMERIC(5,1),
        Adj_Fm_Sal      NUMERIC,
        Deduct_From_Sal NUMERIC(5,1),
        Total_Adj       NUMERIC(5,1),
        Balance_CF      NUMERIC         
    )       
     
                

    IF Object_ID('tempdb..#data') IS NUll
        BEGIN
            CREATE TABLE #EMP_CONS
            (
                EMP_ID NUMERIC,
                BRANCH_ID NUMERIC,
                INCREMENT_ID NUMERIC
            )

            INSERT INTO #EMP_CONS VALUES (@emp_Id, @Branch_ID, @Increment_ID)
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
               IO_Tran_Id      numeric default 0, -- io_tran_id is used for is_cmp_purpose (t0150_emp_inout)
               OUT_Time datetime,
               Shift_End_Time datetime,         --Ankit 16112013
               OT_End_Time numeric default 0,   --Ankit 16112013
               Working_Hrs_St_Time tinyint default 0, --Hardik 14/02/2014
               Working_Hrs_End_Time tinyint default 0, --Hardik 14/02/2014
               GatePass_Deduct_Days numeric(18,2) default 0 -- Add by Gadriwala Muslim 05012014
           )    

           EXEC P_GET_EMP_INOUT @Cmp_ID, @Month_St_Date, @Month_End_Date
        END


    IF  @Emp_Late_Mark = 1 and @Emp_Early_Mark = 1
        BEGIN       
            if @Is_Late_CF =1 and   charindex(@varMonth,@Late_CF_Reset_On)>0            
                BEGIN
                        SELECT  @LMARK_BF =  ISNULL(LATE_CLOSING,0) 
                        FROM    T0140_LATE_TRANSACTION T WITH (NOLOCK)
                                INNER JOIN (SELECT  MAX(FOR_DATE) AS FOR_DATE 
                                            FROM    T0140_LATE_TRANSACTION WITH (NOLOCK)
                                            WHERE   EMP_ID=@EMP_ID AND CMP_ID=@CMP_ID AND FOR_DATE<=@MONTH_ST_DATE 
                                            ) T2 ON T.FOR_DATE=T2.FOR_DATE
                        WHERE   EMP_ID = @EMP_ID AND CMP_ID = @CMP_ID
                END
                
            DECLARE @HalfDayDate VARCHAR(500)                               
            exec GET_HalfDay_Date @Cmp_ID,@Emp_ID,@Month_st_Date,@Month_End_Date,0,@HalfDayDate output
                
            DECLARE @For_DateCurr   DATETIME    --Ankit 07112015    
            SET @For_DateCurr = NULL
            
            DECLARE @Is_Cancel_Late_In tinyint
            DECLARE @Differnce_Rounding_Late_Sec numeric
            DECLARE @Shift_ID NUMERIC(18,0);

			DECLARE @FLAG_LATE_MARK Tinyint
			SET @FLAG_LATE_MARK = 0

			DECLARE @FLAG_EARLY_MARK Tinyint
			SET @FLAG_EARLY_MARK = 0

			DECLARE @FLAG_PENLATY Tinyint
			SET @FLAG_PENLATY = 0
            
            SELECT  @Is_Late_calc_On_HO_WO = Is_Late_Calc_On_HO_WO,@Is_LateMark = Is_Late_Mark, @RoundingValue = ISNULL(Early_Hour_Upper_Rounding,0), 
					@Is_Early_Mark = Is_Late_Mark
            FROM    T0040_GENERAL_SETTING G WITH (NOLOCK)
                    INNER JOIN (
                                    SELECT  MAX(For_Date) AS For_Date 
                                    FROM    T0040_GENERAL_SETTING WITH (NOLOCK)  
                                    WHERE   Cmp_ID = @Cmp_ID AND For_Date <=@Month_End_Date AND Branch_ID=@Branch_ID
                                )  G1 ON G.For_Date=G1.For_Date
            WHERE   Branch_ID = @Branch_ID AND Cmp_ID = @Cmp_ID 
            
            DECLARE CURLMARK CURSOR FOR
            SELECT  IN_TIME, OUT_TIME,FOR_DATE,Emp_ID
            FROM    #DATA D 
                    LEFT OUTER JOIN #ABSENT_DATES AD ON D.FOR_DATE = AD.ABSENT_DATE
            WHERE   NOT EXISTS(SELECT 1 FROM T0150_EMP_INOUT_RECORD EIO WITH (NOLOCK)
                                WHERE   EIO.EMP_ID=D.EMP_ID AND ISNULL(IS_CANCEL_LATE_IN,0) <> 0 AND IN_TIME=D.IN_TIME)
                    AND ABSENT_DATE IS NULL AND D.EMP_ID = ISNULL(@EMP_ID , D.EMP_ID) AND P_days <> 0
                    AND D.FOR_DATE BETWEEN @MONTH_ST_DATE AND @MONTH_END_DATE
               
            OPEN curLMark
            FETCH NEXT FROM curLMark INTO @In_Date,@Out_Date,@For_DateCurr,@Emp_ID
            WHILE @@FETCH_STATUS = 0
                BEGIN
                    
                    SET @Shift_ID = NULL;
                    SET @Shift_ID = dbo.fn_get_Shift_From_Monthly_Rotation(@Cmp_ID, @emp_Id, @In_Date);
        
                    SELECT  @Shift_St_Time=SM.Shift_St_Time,
							@Shift_End_Time=SM.Shift_End_Time
                    FROM    T0040_SHIFT_MASTER SM WITH (NOLOCK)
                    WHERE   SM.Cmp_ID=@Cmp_ID AND SM.Shift_ID=@Shift_ID

                    SET @var_Shift_St_Date = cast(@In_Date as VARCHAR(11)) + ' '  + @Shift_St_Time 
					If @Out_Date > @For_DateCurr 
						Begin
							SET @var_Shift_End_Date = cast(@For_DateCurr as VARCHAR(11)) + ' '  + @Shift_End_Time 
						End
					Else
						Begin
							SET @var_Shift_End_Date = cast(@Out_Date as VARCHAR(11)) + ' '  + @Shift_End_Time 
						End

                    SET @Shift_St_DATETIME = cast(@var_Shift_St_Date as DATETIME)  
                    SET @Shift_Exemption_St_DATETIME = dateadd(s,@Late_Exempted_limit_sec,@Shift_St_DATETIME)
                    SET @Shift_Max_Late_Time = dateadd(s,dbo.F_Return_Sec(@Max_Late_Limit),@Shift_St_DATETIME) 
                    SET @Shift_St_DATETIME = dateadd(s,@Late_Limit_Sec,@Shift_St_DATETIME)   
				
					SET @Shift_End_DateTime = CAST(@var_Shift_End_Date as datetime)
					SET @Shift_Exemption_End_DateTime = DATEADD(s,@Early_Exempted_limit_sec*-1,@Shift_End_DateTime)
					SET @Shift_Max_Early_Time = DATEADD(s,dbo.F_Return_Sec(@Max_Early_Limit)*-1,@Shift_End_DateTime)               
                    SET @Shift_End_DateTime = DATEADD(s,@Early_Limit_Sec*-1,@Shift_End_DateTime)

                    -----Extra Exemption
                    SET @Working_Time_Sec = 0
                    SET @Shift_Time_Sec = 0
                    
                    SET @Working_Time_Sec = Datediff(s,@In_Date,@Out_Date) 
                    SET @Shift_Time_Sec = Datediff(S,@Shift_St_Time,@Shift_End_Time) 
              
  
                    IF @Is_LateMark = 1 and @Is_Early_Mark = 1
                        BEGIN
                            IF @Is_Late_calc_On_HO_WO = 0                                   
                                BEGIN
                                    IF CHARINDEX(CAST(@In_Date AS VARCHAR(11)),@StrWeekoff_Date,0) <> 0 OR CHARINDEX(CAST(@In_Date AS VARCHAR(11)),@StrHoliday_Date,0) <> 0 
                                        SET @In_Date = @Shift_St_DATETIME
                                END
                        END
                    

                    IF @Return_Record_SET = 1  AND 
                        EXISTS(SELECT 1 FROM dbo.T0100_EMP_LATE_DETAIL WITH (NOLOCK) WHERE Emp_ID =@Emp_ID AND Month(For_Date)=@month AND Year(For_Date) =@Year ) 
                        BEGIN
                            INSERT INTO #Late_Data(Emp_ID,Cmp_ID,Month,Year,Late_Balance_BF,Curr_M_Late,Total_Late,To_Be_adj,Leave_ID,Leave_Bal,Adj_Again_Leave,Deduct_From_Sal,Total_Adj,Adj_Fm_Sal,Balance_CF)
                            SELECT @Emp_ID,@Cmp_ID,@Month,@Year,Late_Balance_BF,Late_Curr_Days,Late_total_Days,Late_Tobe_Adj_days,LeavE_Id,0,Late_adj_Agn_Leave,Late_adj_Agn_Leave,Late_total_adj_Days,0,Late_closing From T0100_EMP_LATE_DETAIL WITH (NOLOCK) where Emp_ID =@Emp_ID and Month(for_DatE)=@month and Year(for_Date) =@Year
                        END
                    ELSE
                        BEGIN
                            
                            SET     @Is_Cancel_Late_In = 0
                            SELECT  TOP 1 @Is_Cancel_Late_In=isnull(Is_Cancel_Late_In,0)
                            FROM    dbo.T0150_Emp_Inout_Record WITH (NOLOCK)
                            WHERE   Emp_ID =@emp_Id AND For_Date = CONVERT(NVARCHAR,@In_Date,106)
                                    AND ISNULL(Late_Calc_Not_App,0)=0 AND Chk_By_Superior <> 0 
                            ORDER BY Is_Cancel_Late_In DESC  
                            
							DECLARE @Is_Cancel_Early_Out tinyint
							SET @Is_Cancel_Early_Out = 0
							SELECT	TOP 1 @Is_Cancel_Early_Out =isnull(Is_Cancel_Early_Out,0)
							FROM	dbo.T0150_Emp_Inout_Record WITH (NOLOCK)
							WHERE	Emp_ID =@emp_id AND For_Date = CONVERT(nvarchar,@Out_Date,106)
									AND Chk_By_Superior <> 0 
							ORDER BY Is_Cancel_Early_Out DESC 
							                                            
                                            
                            SELECT  @Shift_St_Time=SM.Shift_St_Time,@is_Half_Day=isnull(SM.Is_Half_Day,0),
                                    @Shift_St_Time_Half_Day = isnull(SM.Half_St_Time,'00:00'),
                                    @Shift_End_Time_Half_Day = isnull(SM.Half_End_Time,'00:00')
                            FROM    T0040_SHIFT_MASTER SM WITH (NOLOCK)
                            WHERE   SM.Cmp_ID=@Cmp_ID AND SM.Shift_ID=@Shift_ID
                                            
                                                                
                            IF(CHARINDEX(CONVERT(NVARCHAR(11),@In_Date,109),@HalfDayDate) > 0) 
                                BEGIN
                                    IF @is_Half_Day = 1
                                        BEGIN
                                            SET @var_Shift_St_Date = cast(@In_Date as VARCHAR(11)) + ' '  + @Shift_St_Time_Half_Day
                                            SET @var_Shift_End_Date = cast(@Out_Date as VARCHAR(11)) + ' '  + @Shift_End_Time_Half_Day  
                                        END
                                    ELSE
                                        BEGIN
                                            SET @var_Shift_St_Date = cast(@In_Date as VARCHAR(11)) + ' '  + @Shift_St_Time
                                            SET @var_Shift_End_Date = cast(@Out_Date as VARCHAR(11)) + ' '  + @Shift_End_Time   
                                        END
                                END
                            ELSE
                                BEGIN
                                    SET @var_Shift_St_Date = cast(@In_Date as VARCHAR(11)) + ' '  + @Shift_St_Time
                                    If @Out_Date > @For_DateCurr 
										SET @var_Shift_End_Date = cast(@For_DateCurr as VARCHAR(11)) + ' '  + @Shift_End_Time  
									Else
										SET @var_Shift_End_Date = cast(@Out_Date as VARCHAR(11)) + ' '  + @Shift_End_Time 
                                END                                         
                                                            
                                
                            SET @Shift_St_DATETIME = cast(@var_Shift_St_Date as DATETIME)
                            SET @Shift_Exemption_St_DATETIME = dateadd(s,@Late_Exempted_limit_sec,@Shift_St_DATETIME)
                            SET @Shift_Max_Late_Time = dateadd(s,dbo.F_Return_Sec(@Max_Late_Limit),@Shift_St_DATETIME) 
                            SET @Shift_St_DATETIME = dateadd(s,@Late_Limit_Sec,@Shift_St_DATETIME)

							SET @Shift_End_DateTime = cast(@var_Shift_End_Date as datetime)

							if @Shift_End_DateTime < @Shift_St_DATETIME
								Set @Shift_End_DateTime = DateAdd(d,1,@Shift_End_DateTime)

							SET @Shift_Exemption_End_DateTime = dateadd(s,@Early_Exempted_limit_sec*-1,@Shift_End_DateTime)
							SET @Shift_Max_Early_Time = dateadd(s,dbo.F_Return_Sec(@Max_Early_Limit)*-1,@Shift_End_DateTime)
							SET @Shift_End_DateTime = dateadd(s,@Early_Limit_Sec*-1,@Shift_End_DateTime)
                        
                            
                            DECLARE @is_half_day_Leave tinyint
                            DECLARE @is_Full_day_Leave tinyint

                            SET @is_half_day_Leave = 0
                            SET @is_Full_day_Leave = 0
                                                            
                            DECLARE @fr_dt as DATETIME
                            SET @fr_dt = cast(convert(nVARCHAR(11),@In_Date,106) + ' 00:00:00' as DATETIME)
                            
                            IF EXISTS(
                                        SELECT  la.Leave_Approval_ID 
                                        FROM    T0120_LEAVE_APPROVAL la WITH (NOLOCK) inner join T0130_LEAVE_APPROVAL_DETAIL lad WITH (NOLOCK) on la.Leave_Approval_ID = lad.Leave_Approval_ID
                                        WHERE   Emp_ID = @emp_Id and Leave_Assign_As = 'First Half' 
                                                AND (
                                                        ISNULL(Half_Leave_Date,To_date) = @fr_dt OR 
                                                        CASE WHEN Half_Leave_Date = '01-Jan-1900' 
                                                            THEN To_date 
                                                        ELSE 
                                                            Half_Leave_Date 
                                                        End = @fr_dt 
                                                    ) AND Approval_Status = 'A'
                                                AND NOT EXISTS(Select 1 From T0150_LEAVE_CANCELLATION LC WITH (NOLOCK) Where LC.Leave_Approval_ID = la.Leave_Approval_ID)
                                     )          
                                BEGIN   
                                    SET @is_half_day_Leave = 1      
                                END

                                IF EXISTS(
                                        SELECT  la.Leave_Approval_ID 
                                        FROM    T0120_LEAVE_APPROVAL la WITH (NOLOCK) inner join T0130_LEAVE_APPROVAL_DETAIL lad WITH (NOLOCK) on la.Leave_Approval_ID = lad.Leave_Approval_ID
                                        WHERE   Emp_ID = @emp_Id and upper(Leave_Assign_As) = 'PART DAY' 
                                                AND (From_Date= @fr_dt) and Leave_out_time = @Shift_Max_Late_Time AND Approval_Status = 'A'
                                                AND NOT EXISTS(Select 1 From T0150_LEAVE_CANCELLATION LC WITH (NOLOCK) Where LC.Leave_Approval_ID = la.Leave_Approval_ID)
                                        )
                                BEGIN   
                                    SET @is_half_day_Leave = 1      
                                END
                                
                            IF EXISTS(SELECT Emp_id FROM T0140_LEAVE_TRANSACTION WITH (NOLOCK)WHERE Emp_ID = @emp_id and For_Date = @fr_dt and ( Leave_Used >= 1 OR CompOff_Used >= 1 )) --CompOff_Used  --Ankit 04122015
                                BEGIN   
                                    SET @is_Full_day_Leave = 1      
                                END
                                                               
                            SET @Differnce_Rounding_Late_Sec = 0

							SET @FLAG_LATE_MARK = 0
						    SET @FLAG_EARLY_MARK = 0

                            IF @In_Date > @Shift_St_DATETIME and @Is_Cancel_Late_In = 0  and @is_half_day_Leave = 0 and @is_Full_day_Leave = 0-- Modified by Mitesh on 08/08/2011
                                BEGIN
                                    if @RoundingValue > 0 
                                        BEGIN
                                            IF DATEPART(hh,@Shift_St_DATETIME) = 0 AND @In_Date < DATEADD(D,1,@For_DateCurr)
                                                SET @Differnce_Rounding_Late_Sec = datediff(s,DATEADD(D,1,@For_DateCurr) ,@In_Date)
                                            ELSE
                                                SET @Differnce_Rounding_Late_Sec = datediff(s,cast(@var_Shift_St_Date as DATETIME) ,@In_Date)
                                                
                                            SELECT @Differnce_Rounding_Late_Sec = dbo.Pro_Rounding_Sec_HH_MM(@Differnce_Rounding_Late_Sec,@RoundingValue)
                                        END 
                                    Else
                                        BEGIN
                                            IF DATEPART(hh,@Shift_St_DATETIME) = 0 AND @In_Date < DATEADD(D,1,@For_DateCurr)
                                                SET @Differnce_Rounding_Late_Sec = datediff(s,DATEADD(D,1,@For_DateCurr) ,@In_Date)
                                            ELSE
                                                SET @Differnce_Rounding_Late_Sec = datediff(s,@Shift_St_DATETIME ,@In_Date)
                                        END
                                    
                                    IF @Differnce_Rounding_Late_Sec > 0 
                                        BEGIN
                                            IF (@In_Date > @Shift_St_DATETIME and @In_Date <= @Shift_Max_Late_Time)
                                                BEGIN
												   --Comment by Nilesh Patl 25102018 -- Woking Hours is greater than shift hours -- Late Mark is cancelled but in Genchi it is not require
                                                   --IF DATEDIFF(s,@In_Date,@Out_Date) < DATEDIFF(s,@var_Shift_St_Date,@var_Shift_End_Date)
                                                        --BEGIN
															 SET @FLAG_LATE_MARK = 1
                                                       -- END
                                                END
                                            ELSE    
                                                BEGIN
														SET @FLAG_LATE_MARK = 2
                                                END
                                        END
								 END

							IF @FLAG_LATE_MARK = 1
								SET @Curr_Month_LMark = @Curr_Month_LMark + 1
							ELSE IF @FLAG_LATE_MARK = 2
								SET @Curr_Month_LMark_WithOut_Exemption = @Curr_Month_LMark_WithOut_Exemption + 1
	
							SET @FLAG_PENLATY = 0
							IF @Flag_Laps_Exemption_Count = 0
								Begin
									IF (@Curr_Month_LMark > @Late_Exempted_Days or @Curr_Month_LMark_WithOut_Exemption > @Extra_Count_Exemption) and (@FLAG_LATE_MARK = 2) 
										Begin
											SET @FLAG_PENLATY = 1
										End
									--Else if @Curr_Month_LMark > @Late_Exempted_Days and @Curr_Month_LMark_WithOut_Exemption > @Extra_Count_Exemption and (@FLAG_LATE_MARK = 1)
									Else if @Curr_Month_LMark > @Late_Exempted_Days AND (@Curr_Month_LMark + @Curr_Month_LMark_WithOut_Exemption) > (@Late_Exempted_Days + @Extra_Count_Exemption) and (@FLAG_LATE_MARK = 1)
										Begin
											SET @FLAG_PENLATY = 1
										End
									Else if @Curr_Month_LMark > (@Late_Exempted_Days + @Extra_Count_Exemption) and (@FLAG_LATE_MARK = 1)
										Begin
											SET @FLAG_PENLATY = 1 
										End
								End
							Else
								Begin
									SET @FLAG_PENLATY = 1 
								End

							IF @Report_Flag = 0 and (@FLAG_LATE_MARK >= 1)
								Begin
									Set @Early_Deduction = 0
									Set @Late_Deduction = 0
									IF @FLAG_PENLATY = 1
										Begin
											IF @FLAG_LATE_MARK >= 1
												Set @Late_Deduction = @Late_Dedu_Days
										End

									Insert into T0160_Late_Early_Validation
									(Cmp_ID,Emp_ID,Sal_Tran_ID,For_Date,Sal_Month,Sal_Year,Late_Sec,Early_Sec,Late_Deduction,Early_Deduction,Flag_No_Exepmtion)
									Values(@Cmp_ID,@Emp_ID,@Sal_Tran_ID,@For_DateCurr,Month(@Month_End_Date),Year(@Month_End_Date),(@Differnce_Rounding_Late_Sec + @Late_Limit_Sec),0,@Late_Deduction,0,@Flag_Laps_Exemption_Count)
									
								End	
							-- For Showing Details in Report --Start
							
							IF @Report_Flag = 1 and (@FLAG_LATE_MARK >= 1 )
								Begin
									Set @Early_Deduction = 0
									Set @Late_Deduction = 0
									IF @FLAG_PENLATY = 1
										Begin
											IF @FLAG_LATE_MARK >= 1
												Set @Late_Deduction = @Late_Dedu_Days
										End
								
									INSERT INTO #Emp_Late_Early(Cmp_ID,Emp_ID,For_Date,In_Time,Out_Time,Shift_St_Time,Shift_End_Time,Late_Sec,Early_Sec,Late_Limit,Early_Limit,Late_Deduction,Early_Deduction)
									Values(@Cmp_ID,@Emp_ID,@For_DateCurr,@In_Date,@Out_Date,cast(@var_Shift_St_Date as DATETIME),cast(@var_Shift_End_Date as DATETIME),(@Differnce_Rounding_Late_Sec + @Late_Limit_Sec),0,@Emp_Late_Limit,NULL,@Late_Deduction,0)
								End	

							DECLARE @Differnce_Rounding_Early_Sec numeric
							SET @Differnce_Rounding_Early_Sec = 0

							IF EXISTS(
										SELECT  LA.LEAVE_APPROVAL_ID 
											FROM    T0120_LEAVE_APPROVAL LA WITH (NOLOCK)
											INNER JOIN T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) ON LA.LEAVE_APPROVAL_ID = LAD.LEAVE_APPROVAL_ID
										WHERE  EMP_ID = @EMP_ID AND LEAVE_ASSIGN_AS = 'SECOND HALF' 
                                            AND (
                                                    ISNULL(HALF_LEAVE_DATE,TO_DATE) = @FR_DT OR 
                                                    CASE WHEN HALF_LEAVE_DATE = '01-JAN-1900' 
                                                        THEN TO_DATE 
                                                    ELSE 
                                                        HALF_LEAVE_DATE 
                                                    END = @FR_DT 
                                                ) AND APPROVAL_STATUS = 'A'
                                            AND NOT EXISTS(Select 1 From T0150_LEAVE_CANCELLATION LC WITH (NOLOCK) Where LC.Leave_Approval_ID = la.Leave_Approval_ID)
                                    )
                            BEGIN   
                                SET @IS_HALF_DAY_LEAVE = 1      
                            END
							IF @Out_Date < @Shift_End_DateTime and @Is_Cancel_Early_Out = 0 and @is_half_day_Leave = 0 and @is_Full_day_Leave = 0
								BEGIN
									IF @RoundingValue > 0 
										BEGIN
											SET @Differnce_Rounding_Early_Sec = abs(datediff(s,cast(@var_Shift_End_Date as datetime) ,@Out_Date))
											SELECT @Differnce_Rounding_Early_Sec = dbo.Pro_Rounding_Sec_HH_MM(@Differnce_Rounding_Early_Sec,@RoundingValue)
										END	
									ELSE
										BEGIN
											SET @Differnce_Rounding_Early_Sec = abs(datediff(s,@Shift_End_DateTime ,@Out_Date))
										END

									if @Differnce_Rounding_Early_Sec > 0
										Begin
											if @Out_Date < @Shift_End_DateTime and @Out_Date >= @Shift_Max_Early_Time
												BEGIN
													--Comment by Nilesh Patl 25102018 -- Woking Hours is greater than shift hours -- Late Mark is cancelled but in Genchi it is not require
													--IF DATEDIFF(s,@In_Date,@Out_Date) < DATEDIFF(s,@var_Shift_St_Date,@var_Shift_End_Date)
														--BEGIN
															SET @FLAG_EARLY_MARK = 1
														--END
												END	
											ELSE
												BEGIN
													SET @FLAG_EARLY_MARK = 2									
												END
										End
								END

							IF @FLAG_EARLY_MARK = 1
								SET @Curr_Month_LMark = @Curr_Month_LMark + 1
							ELSE IF @FLAG_EARLY_MARK = 2 
								SET @Curr_Month_LMark_WithOut_Exemption = @Curr_Month_LMark_WithOut_Exemption + 1

							SET @FLAG_PENLATY = 0
							IF @Flag_Laps_Exemption_Count = 0
								Begin
									IF (@Curr_Month_LMark > @Late_Exempted_Days or @Curr_Month_LMark_WithOut_Exemption > @Extra_Count_Exemption) and (@FLAG_EARLY_MARK = 2) 
										Begin
											SET @FLAG_PENLATY = 1
										End
									Else if (@Curr_Month_LMark + @Curr_Month_LMark_WithOut_Exemption) > (@Late_Exempted_Days + @Extra_Count_Exemption) and (@FLAG_EARLY_MARK = 1)
										Begin
											SET @FLAG_PENLATY = 1
										End
									Else if @Curr_Month_LMark > (@Late_Exempted_Days + @Extra_Count_Exemption) and (@FLAG_EARLY_MARK = 1)
										Begin
											SET @FLAG_PENLATY = 1 
										End
								End
							Else
								Begin
									SET @FLAG_PENLATY = 1 
								End

							IF @Report_Flag = 0 and (@FLAG_EARLY_MARK >= 1)
								Begin
									Set @Early_Deduction = 0
									Set @Late_Deduction = 0
									IF @FLAG_PENLATY = 1
										Begin
											IF @FLAG_EARLY_MARK >= 1
												Set @Early_Deduction = @Early_Dedu_Days
										End

									if Exists(Select 1 From T0160_Late_Early_Validation  WITH (NOLOCK) Where Emp_ID = @Emp_ID and For_Date = @For_DateCurr)
										Begin
											Update T0160_Late_Early_Validation
											Set 
												Early_Sec = @Differnce_Rounding_Early_Sec + @Early_Limit_Sec,
												Early_Deduction = @Early_Deduction
											Where Emp_ID = @Emp_ID and For_Date = @For_DateCurr
										End
									Else
										Begin
											Insert into T0160_Late_Early_Validation
											(Cmp_ID,Emp_ID,Sal_Tran_ID,For_Date,Sal_Month,Sal_Year,Late_Sec,Early_Sec,Late_Deduction,Early_Deduction,Flag_No_Exepmtion)
											Values(@Cmp_ID,@Emp_ID,@Sal_Tran_ID,@For_DateCurr,Month(@Month_End_Date),Year(@Month_End_Date),0,(@Differnce_Rounding_Early_Sec  + @Early_Limit_Sec),0,@Early_Deduction,@Flag_Laps_Exemption_Count)
										End

									
								End	
							-- For Showing Details in Report --Start
							IF @Report_Flag = 1 and ( @FLAG_EARLY_MARK >= 1)
								Begin
									Set @Early_Deduction = 0
									Set @Late_Deduction = 0
									IF @FLAG_PENLATY = 1
										Begin
											IF @FLAG_EARLY_MARK >= 1
												Set @Early_Deduction = @Early_Dedu_Days
										End
									if Exists(Select 1 From #Emp_Late_Early Where Emp_ID = @Emp_ID and For_Date = @For_DateCurr)
										Begin
											Update #Emp_Late_Early
												SET Early_Sec = @Differnce_Rounding_Early_Sec + @Early_Limit_Sec,
													Early_Limit = @Max_Early_Limit,
													Early_Deduction = @Early_Deduction
											Where Emp_ID = @Emp_ID and For_Date = @For_DateCurr
										End
									Else
										Begin
											INSERT INTO #Emp_Late_Early(Cmp_ID,Emp_ID,For_Date,In_Time,Out_Time,Shift_St_Time,Shift_End_Time,Late_Sec,Early_Sec,Late_Limit,Early_Limit,Late_Deduction,Early_Deduction)
											Values(@Cmp_ID,@Emp_ID,@For_DateCurr,@In_Date,@Out_Date,cast(@var_Shift_St_Date as DATETIME),cast(@var_Shift_End_Date as DATETIME),0,(@Differnce_Rounding_Early_Sec + @Early_Limit_Sec),NULL,@Emp_Early_Limit,0,@Early_Deduction)
										End
								End	
							-- For Showing Details in Report --End
						END
                    FETCH NEXT FROM curLMark INTO @In_Date,@Out_Date,@For_DateCurr,@Emp_ID  
                END
            CLOSE curLMark;
            DEALLOCATE curLMark;
        END

		
	
		IF @Report_Flag = 0
			Begin
				Declare @qry as varchar(max) = ''
				if @Late_Exempted_Days > 0
				Begin 
						
						IF (EXISTS (SELECT TABLE_NAME 
											 FROM INFORMATION_SCHEMA.TABLES 
											 WHERE TABLE_NAME = 'TmpLateEmpDays'))
							BEGIN
							drop table  TmpLateEmpDays
						END
						set @qry = 'Select Top ' + cast (cast(@Late_Exempted_Days as int) as varchar(5))  + ' * 
						into TmpLateEmpDays from T0160_Late_Early_Validation 
						where emp_Id = ' + cast(@Emp_ID as varchar(50)) + ' and (Late_sec < ' + cast(@Late_Exempted_limit_sec as varchar(50)) + ' and Early_sec < ' + cast(@Late_Exempted_limit_sec as varchar(50)) + ') order by for_date'
						exec(@qry)
					
						UPDATE A
						SET A.Late_Deduction = 0
							,A.Early_Deduction = 0
						FROM T0160_Late_Early_Validation A
						JOIN TmpLateEmpDays B
							ON A.For_date = B.for_date

							
						UPDATE T0160_Late_Early_Validation
						SET 
							Early_Deduction = 0
						where Early_Deduction > 0 and Late_deduction > 0

				END

					Select @Late_Sal_Dedu_Days = Isnull(Sum(Late_Deduction),0) + Isnull(Sum(Early_Deduction),0),
					@Total_Late_Sec = 0 -- Isnull(Sum(Late_Sec),0) + Isnull(Sum(Early_Sec),0)
					From T0160_Late_Early_Validation WITH (NOLOCK) Where Emp_ID = @Emp_ID and Sal_Tran_ID = @Sal_Tran_ID
				
			End

    RETURN 

