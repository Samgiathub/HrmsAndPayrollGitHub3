
-- =============================================
-- AUTHOR:      HARDIK BAROT
-- CREATE DATE: 09-09-2020
-- DESCRIPTION: CALCULATE LATE MARK / EARLY SLAB WISE (SCENARIO 2) WITH MONTHLY 30 MINS EXEMPTED, LATE AND EARLY COMBINE, FOR CLIENT : TANVI GOLD
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_CALCULATE_LATE_DEDUCTION_SLABWISE_COMBINE_MONTHLY_EXEMPT]
     @EMP_ID             NUMERIC
    ,@CMP_ID             NUMERIC
    ,@MONTH_ST_DATE      DATETIME
    ,@MONTH_END_DATE     DATETIME
    ,@LATE_SAL_DEDU_DAYS NUMERIC(18,2) OUTPUT
    ,@TOTAL_LMARK        INT  OUTPUT
    ,@TOTAL_LATE_SEC     NUMERIC OUTPUT
    ,@INCREMENT_ID       NUMERIC 
    ,@STRWEEKOFF_DATE VARCHAR(MAX)=''
    ,@STRHOLIDAY_DATE VARCHAR(MAX)=''
    ,@RETURN_RECORD_SET  NUMERIC =0
    ,@VAR_RETURN_LATE_DATE  VARCHAR(1000) ='' OUTPUT
    ,@RETURN_LATE_DATE_TABLE TINYINT = 0
    ,@ABSENT_DATE_STRING    VARCHAR(MAX) =''
    ,@TEMP_EXTRA_COUNT  AS NUMERIC(18,0) = 0    OUTPUT
    ,@TOTAL_LATE_OT_HOURS AS NUMERIC(18,2) = 0 OUTPUT
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
    
    DECLARE @IN_DATE            DATETIME
    DECLARE @SHIFT_ST_TIME      VARCHAR(10)
    DECLARE @SHIFT_ST_DATETIME  DATETIME
	DECLARE @SHIFT_END_DATETIME  DATETIME
    DECLARE @VAR_SHIFT_ST_DATE  VARCHAR(20)
    DECLARE @EMP_LATE_LIMIT     VARCHAR(10)
    DECLARE @LATE_LIMIT_SEC     NUMERIC
    DECLARE @BRANCH_ID          NUMERIC 
    DECLARE @EMP_LATE_MARK      INT
    DECLARE @LATE_DEDU_TYPE     VARCHAR(10)
    DECLARE @MONTH              NUMERIC
    DECLARE @VARMONTH           VARCHAR(10)
    DECLARE @LATE_WITH_LEAVE    NUMERIC(1,0)
    DECLARE @YEAR               NUMERIC
    DECLARE @SHIFT_ST_TIME_HALF_DAY     VARCHAR(10)
    DECLARE @IS_HALF_DAY    TINYINT
    DECLARE @ROUNDINGVALUE  NUMERIC(18,2) 
    DECLARE @IS_LATE_CALC_ON_HO_WO TINYINT
    DECLARE @IS_LATEMARK AS TINYINT
    DECLARE @SHIFT_MAX_LATE_TIME DATETIME
    DECLARE @OUT_DATE DATETIME  
    DECLARE @SHIFT_END_TIME VARCHAR(10)
    DECLARE @VAR_SHIFT_END_DATE VARCHAR(20)
    DECLARE @SHIFT_END_TIME_HALF_DAY VARCHAR(10)
    
    SET @TEMP_EXTRA_COUNT = 0
    SET @TOTAL_LATE_SEC =0
    SET @MONTH  = MONTH(@MONTH_ST_DATE)
    SET @VARMONTH = @MONTH
    SET @VARMONTH = '#' + @VARMONTH + '#'
    SET @ROUNDINGVALUE = 0
    
    SET @YEAR   = YEAR(@MONTH_ST_DATE)
    SET @VAR_RETURN_LATE_DATE = ''
    SET @IS_LATE_CALC_ON_HO_WO = 0
    SET @IS_LATEMARK = 0
    
    DECLARE @LATE_MARK_SCENARIO NUMERIC(5,0)
    DECLARE @GEN_ID NUMERIC(5,0)
    DECLARE @ACTUAL_SHIFT_ST_TIME DATETIME
	DECLARE @ACTUAL_SHIFT_END_TIME DATETIME
    DECLARE @ACTUAL_MIN_DIFF NUMERIC(18,2)
    DECLARE @LATE_ADJ_AGAIN_OT NUMERIC(18,0)
	DECLARE @EXEMPT_MIN_MONTHLY VARCHAR(8)
    
    SET @LATE_MARK_SCENARIO = 0
    SET @ACTUAL_MIN_DIFF = 0
    SET @GEN_ID = 0
    SET @LATE_ADJ_AGAIN_OT = 0
    
    SELECT  @EMP_LATE_MARK = ISNULL(EMP_LATE_MARK,0) ,
            @EMP_LATE_LIMIT = ISNULL(EMP_LATE_LIMIT,'00:00'),
            @BRANCH_ID =BRANCH_ID,
            @LATE_DEDU_TYPE = LATE_DEDU_TYPE
    FROM    T0095_INCREMENT I WITH (NOLOCK)
    WHERE   I.EMP_ID = @EMP_ID AND INCREMENT_ID =@INCREMENT_ID  
    
    IF OBJECT_ID('TEMPDB.DBO.#ABSENT_DATES') IS NOT NULL
        DROP TABLE #ABSENT_DATES
    
    CREATE TABLE #ABSENT_DATES  
    (
        ABSENT_DATE DATETIME
    )
    
    IF @ABSENT_DATE_STRING <> ''
        BEGIN
            INSERT INTO #ABSENT_DATES(ABSENT_DATE)
            SELECT DATA FROM DBO.SPLIT(@ABSENT_DATE_STRING,'#')
        END
    
    SELECT  @LATE_MARK_SCENARIO = ISNULL(LATE_MARK_SCENARIO,0),
            @GEN_ID = ISNULL(GEN_ID,0),
            @LATE_WITH_LEAVE = LATE_WITH_LEAVE,
            @IS_LATE_CALC_ON_HO_WO = IS_LATE_CALC_ON_HO_WO,
            @IS_LATEMARK = IS_LATE_MARK, 
            @ROUNDINGVALUE = ISNULL(EARLY_HOUR_UPPER_ROUNDING,0),
            @LATE_ADJ_AGAIN_OT = ISNULL(LATE_ADJ_AGAIN_OT,0),
			@EXEMPT_MIN_MONTHLY = Monthly_Exemption_Limit  --Added by Jaina 22-09-2020
    FROM    T0040_GENERAL_SETTING G WITH (NOLOCK)
            INNER JOIN (
                            SELECT  MAX(FOR_DATE) AS FOR_DATE 
                            FROM    T0040_GENERAL_SETTING WITH (NOLOCK)    
                   WHERE   CMP_ID = @CMP_ID AND FOR_DATE <=@MONTH_END_DATE AND BRANCH_ID=@BRANCH_ID
                        )  G1 ON G.FOR_DATE=G1.FOR_DATE
    WHERE   CMP_ID = @CMP_ID AND BRANCH_ID =@BRANCH_ID 
    
    SELECT @LATE_LIMIT_SEC  = DBO.F_RETURN_SEC(@EMP_LATE_LIMIT)
    
    IF OBJECT_ID('TEMPDB.DBO.#LATE_MARK_SLAB') IS NOT NULL
        DROP TABLE #LATE_MARK_SLAB
    
    CREATE TABLE #LATE_MARK_SLAB
    (
        CMP_ID NUMERIC(18,0),
        EMP_ID NUMERIC(18,0),
        TRANS_ID NUMERIC(18,0),
        BRANCH_ID NUMERIC(18,0),
        FROM_MIN NUMERIC(18,0),
        TO_MIN NUMERIC(18,0),
        EXMPT_COUNT NUMERIC(18,0),
        DEDUCTION NUMERIC(18,2),
        DEDUCTION_TYPE VARCHAR(100),
        GEN_ID NUMERIC(18,0),
        CURR_COUNT NUMERIC(18,0),
        ONE_TIME_EXEMPTION NUMERIC(2,0),
        Total_Deduct_Days Numeric(18,2),
        GROUP_FLAG BIT
    )   

    IF @LATE_MARK_SCENARIO = 2
        BEGIN
             INSERT INTO #LATE_MARK_SLAB(CMP_ID,EMP_ID,TRANS_ID,BRANCH_ID,FROM_MIN,TO_MIN,EXMPT_COUNT,DEDUCTION,DEDUCTION_TYPE,GEN_ID,CURR_COUNT,ONE_TIME_EXEMPTION,Total_Deduct_Days,GROUP_FLAG)
             SELECT @CMP_ID,@EMP_ID,TRANS_ID,@BRANCH_ID,FROM_MIN,TO_MIN,EXEMPTION_COUNT,DEDUCTION,DEDUCTION_TYPE,GEN_ID,0,ONE_TIME_EXEMPTION,0,0
             FROM T0050_GENERAL_LATEMARK_SLAB WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND GEN_ID = @GEN_ID 
        END
    
    IF Object_ID('tempdb..#data') IS NUll
        BEGIN
            CREATE TABLE #EMP_CONS
            (
                EMP_ID NUMERIC,
                BRANCH_ID NUMERIC,
                INCREMENT_ID NUMERIC
            )

            INSERT INTO #EMP_CONS VALUES (@emp_Id, @BRANCH_ID, @Increment_ID)
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

           EXEC P_GET_EMP_INOUT @CMP_ID, @Month_St_Date, @Month_End_Date
        END

    
    IF  @EMP_LATE_MARK = 1
        BEGIN
        
            DECLARE @HALFDAYDATE VARCHAR(500)                               
            EXEC GET_HALFDAY_DATE @CMP_ID,@EMP_ID,@MONTH_ST_DATE,@MONTH_END_DATE,0,@HALFDAYDATE OUTPUT
            
            DECLARE @FOR_DATECURR   DATETIME    
            SET @FOR_DATECURR = NULL
            
            DECLARE @IS_CANCEL_LATE_IN TINYINT
			DECLARE @IS_CANCEL_EARLY_OUT TINYINT
            DECLARE @DIFFERNCE_ROUNDING_LATE_SEC NUMERIC
            DECLARE @SHIFT_ID NUMERIC(18,0);
            
			
			DECLARE @EXEMPT_SEC_MONTHLY NUMERIC
			--SET @EXEMPT_MIN_MONTHLY = '00:30' --Comment by Jaina 22-09-2020 Get detail from general setting table
			SET @EXEMPT_SEC_MONTHLY = dbo.F_Return_Sec(@EXEMPT_MIN_MONTHLY)

            DECLARE CURLMARK CURSOR FOR
            SELECT  In_Time, OUT_Time,For_date
            FROM    #Data D 
                    LEFT OUTER JOIN #Absent_Dates AD on D.For_Date = AD.Absent_date
            where   NOT EXISTS(SELECT 1 FROM T0150_EMP_INOUT_RECORD EIO WITH (NOLOCK)
                                WHERE   EIO.Emp_ID=D.Emp_Id AND isnull(Is_Cancel_Late_In,0) <> 0 
										--AND In_Time=D.In_Time  As in mid case when approve cancel late in at that time in present day Sp In_Time is set to shift start time so need to change this with for_date
										And for_date = d.for_date
										AND ((Chk_By_Superior = 2 And Reason = '') or (Chk_By_Superior = 1 and Reason <> '')) -- Changed by Hardik 18/02/2021 for Unipath
                              )
                    AND Absent_date IS NULL 
                    AND D.For_Date BETWEEN @MONTH_ST_DATE AND @MONTH_END_DATE
            OPEN  CURLMARK
            FETCH NEXT FROM CURLMARK INTO @IN_DATE,@OUT_DATE,@FOR_DATECURR
            WHILE @@FETCH_STATUS = 0
                BEGIN
                    
                    SET @SHIFT_ID = NULL;
                    SET @SHIFT_ID = DBO.FN_GET_SHIFT_FROM_MONTHLY_ROTATION(@CMP_ID, @EMP_ID, @IN_DATE);
                    SET @ACTUAL_MIN_DIFF = 0
                    
                    SELECT  @SHIFT_ST_TIME=SM.SHIFT_ST_TIME,
                            @SHIFT_END_TIME=SM.SHIFT_END_TIME,
                            @IS_HALF_DAY=ISNULL(SM.IS_HALF_DAY,0),
                            @SHIFT_ST_TIME_HALF_DAY = ISNULL(SM.HALF_ST_TIME,'00:00'),
                            @SHIFT_END_TIME_HALF_DAY = ISNULL(SM.HALF_END_TIME,'00:00')
                    FROM    T0040_SHIFT_MASTER SM WITH (NOLOCK)
                    WHERE   SM.CMP_ID=@CMP_ID AND SM.SHIFT_ID=@SHIFT_ID
                    
                    SET @VAR_SHIFT_ST_DATE = CAST(@IN_DATE AS VARCHAR(11)) + ' '  + @SHIFT_ST_TIME  
                    SET @VAR_SHIFT_END_DATE = CAST(@OUT_DATE AS VARCHAR(11)) + ' '  + @SHIFT_END_TIME
                    
                    SET @SHIFT_ST_DATETIME = CAST(@VAR_SHIFT_ST_DATE AS DATETIME)
					SET @SHIFT_END_DATETIME = CAST(@VAR_SHIFT_END_DATE AS DATETIME)
                    
					SET @SHIFT_ST_DATETIME = DATEADD(S,@LATE_LIMIT_SEC,@SHIFT_ST_DATETIME)
                    SET @SHIFT_END_DATETIME = DATEADD(S,@LATE_LIMIT_SEC *-1,@SHIFT_END_DATETIME)
                    
                    IF @IS_LATEMARK = 1
                        BEGIN
                            IF @IS_LATE_CALC_ON_HO_WO = 0                                   
                                BEGIN
                                    IF CHARINDEX(CAST(@IN_DATE AS VARCHAR(11)),@STRWEEKOFF_DATE,0) <> 0 OR CHARINDEX(CAST(@IN_DATE AS VARCHAR(11)),@STRHOLIDAY_DATE,0) <> 0 
                                        SET @IN_DATE = @SHIFT_ST_DATETIME
                                END
                                
                                
                                        SET @IS_CANCEL_LATE_IN = 0
										SET @IS_CANCEL_EARLY_OUT = 0
                                        SELECT  TOP 1 @IS_CANCEL_LATE_IN=ISNULL(IS_CANCEL_LATE_IN,0), @IS_CANCEL_EARLY_OUT = ISNULL(Is_Cancel_Early_Out,0)
                                        FROM    DBO.T0150_EMP_INOUT_RECORD WITH (NOLOCK)
                                        WHERE   EMP_ID =@EMP_ID AND FOR_DATE = CONVERT(NVARCHAR,@IN_DATE,106)
                                                AND ISNULL(LATE_CALC_NOT_APP,0)=0 
												--AND CHK_BY_SUPERIOR <> 0 -- CHANGED BY RAMIZ ON 04/03/2016 FROM CHK_BY_SUPERIOR = 1 TO CHK_BY_SUPERIOR <> 0 AS NOW CHK_BY_SUPERIOR = 2 IS ALSO COMING
												AND ((Chk_By_Superior = 2 And Reason = '') or (Chk_By_Superior = 1 and Reason <> ''))
                                        ORDER BY IS_CANCEL_LATE_IN DESC  
                                        
                                        IF(CHARINDEX(CONVERT(NVARCHAR(11),@IN_DATE,109),@HALFDAYDATE) > 0) 
                                            BEGIN
                                                IF @IS_HALF_DAY = 1
                                                    BEGIN
                                                        SET @VAR_SHIFT_ST_DATE = CAST(@IN_DATE AS VARCHAR(11)) + ' '  + @SHIFT_ST_TIME_HALF_DAY
                                                        SET @VAR_SHIFT_END_DATE = CAST(@OUT_DATE AS VARCHAR(11)) + ' '  + @SHIFT_END_TIME_HALF_DAY                                              
													END
                                                ELSE
                                                    BEGIN
                                                        SET @VAR_SHIFT_ST_DATE = CAST(@IN_DATE AS VARCHAR(11)) + ' '  + @SHIFT_ST_TIME
                                                        SET @VAR_SHIFT_END_DATE = CAST(@OUT_DATE AS VARCHAR(11)) + ' '  + @SHIFT_END_TIME   
                                                    END
                                            END
                                        ELSE
                                            BEGIN
                                                SET @VAR_SHIFT_ST_DATE = CAST(@IN_DATE AS VARCHAR(11)) + ' '  + @SHIFT_ST_TIME
                                                SET @VAR_SHIFT_END_DATE = CAST(@OUT_DATE AS VARCHAR(11)) + ' '  + @SHIFT_END_TIME   
                                            END 
                                            
                                        SET @SHIFT_ST_DATETIME = CAST(@VAR_SHIFT_ST_DATE AS DATETIME)
										SET @SHIFT_END_DATETIME = CAST(@VAR_SHIFT_END_DATE AS DATETIME)

                                        SET @ACTUAL_SHIFT_ST_TIME = @SHIFT_ST_DATETIME
										SET @ACTUAL_SHIFT_END_TIME = @SHIFT_END_DATETIME

                                        SET @SHIFT_ST_DATETIME = DATEADD(S,@LATE_LIMIT_SEC,@SHIFT_ST_DATETIME)
										SET @SHIFT_END_DATETIME = DATEADD(S,@LATE_LIMIT_SEC*-1,@SHIFT_END_DATETIME)
                                        
                                        
                                        DECLARE @IS_HALF_DAY_LEAVE TINYINT
                                        DECLARE @IS_FULL_DAY_LEAVE TINYINT
                                        
                                        SET @IS_HALF_DAY_LEAVE = 0
                                        SET @IS_FULL_DAY_LEAVE = 0
                                        
                                        DECLARE @FR_DT AS DATETIME
                                        SET @FR_DT = CAST(CONVERT(NVARCHAR(11),@IN_DATE,106) + ' 00:00:00' AS DATETIME)
                                        
                                        --IF EXISTS(
                                        --            SELECT  LA.LEAVE_APPROVAL_ID 
                                        --            FROM    T0120_LEAVE_APPROVAL LA INNER JOIN T0130_LEAVE_APPROVAL_DETAIL LAD ON LA.LEAVE_APPROVAL_ID = LAD.LEAVE_APPROVAL_ID
                                        --            WHERE   EMP_ID = @EMP_ID AND LEAVE_ASSIGN_AS = 'FIRST HALF' 
                                        --                    AND (
                                        --                            ISNULL(HALF_LEAVE_DATE,TO_DATE) = @FR_DT OR 
                                        --                            CASE WHEN HALF_LEAVE_DATE = '01-JAN-1900' 
                                        --                                THEN TO_DATE 
                                        --                            ELSE 
                                        --                                HALF_LEAVE_DATE 
                                        --                            END = @FR_DT 
                                        --         )AND APPROVAL_STATUS = 'A')
                                        --BEGIN   
                                        --    SET @IS_HALF_DAY_LEAVE = 1      
                                        --END
                                        
                                        IF EXISTS(
                                                    SELECT  LA.LEAVE_APPROVAL_ID 
                                                    FROM    T0120_LEAVE_APPROVAL LA WITH (NOLOCK) INNER JOIN T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) ON LA.LEAVE_APPROVAL_ID = LAD.LEAVE_APPROVAL_ID
                                                    WHERE   EMP_ID = @EMP_ID AND UPPER(LEAVE_ASSIGN_AS) = 'PART DAY' 
                                                    AND (FROM_DATE= @FR_DT) AND LEAVE_OUT_TIME = @SHIFT_MAX_LATE_TIME AND APPROVAL_STATUS = 'A'
               )
                                        BEGIN   
                                            SET @IS_HALF_DAY_LEAVE = 1      
                                        END
                                        
                                        IF EXISTS(SELECT EMP_ID FROM T0140_LEAVE_TRANSACTION WITH (NOLOCK) WHERE EMP_ID = @EMP_ID AND FOR_DATE = @FR_DT AND ( LEAVE_USED >= 0.5 OR COMPOFF_USED >= 0.5 )) --COMPOFF_USED  --ANKIT 04122015
                                        BEGIN   
                                            SET @IS_FULL_DAY_LEAVE = 1      
                                        END
                                        
                                        SET @DIFFERNCE_ROUNDING_LATE_SEC = 0
                                        
                                        
                                        
                                        IF @IN_DATE > @SHIFT_ST_DATETIME AND @IS_CANCEL_LATE_IN = 0  AND @IS_HALF_DAY_LEAVE = 0 AND @IS_FULL_DAY_LEAVE = 0-- MODIFIED BY MITESH ON 08/08/2011
                                            BEGIN
                                                /* FOR SHIFT START TIME 12:00 AM & EMPLOYEE IN PUNCH EARLY THEN NOT COUNT LATE MARK (NIRMA CLIENT)  --ANKIT 07112015 */
                                                IF @ROUNDINGVALUE > 0 
                                                    BEGIN
                                                        IF DATEPART(HH,@SHIFT_ST_DATETIME) = 0 AND @IN_DATE < DATEADD(D,1,@FOR_DATECURR)
                                                            SET @DIFFERNCE_ROUNDING_LATE_SEC = DATEDIFF(S,DATEADD(D,1,@FOR_DATECURR) ,@IN_DATE)
                                                        ELSE
                                                            SET @DIFFERNCE_ROUNDING_LATE_SEC = DATEDIFF(S,CAST(@VAR_SHIFT_ST_DATE AS DATETIME) ,@IN_DATE)
                                                            
                                                        SELECT @DIFFERNCE_ROUNDING_LATE_SEC = DBO.PRO_ROUNDING_SEC_HH_MM(@DIFFERNCE_ROUNDING_LATE_SEC,@ROUNDINGVALUE)
                                                    END 
                                                ELSE
                                                    BEGIN
                                                        IF DATEPART(HH,@SHIFT_ST_DATETIME) = 0 AND @IN_DATE < DATEADD(D,1,@FOR_DATECURR)
                                                            SET @DIFFERNCE_ROUNDING_LATE_SEC = DATEDIFF(S,DATEADD(D,1,@FOR_DATECURR) ,@IN_DATE)
                                                        ELSE
                                                            SET @DIFFERNCE_ROUNDING_LATE_SEC = DATEDIFF(S,@SHIFT_ST_DATETIME ,@IN_DATE)
                                                    END

                                                IF @DIFFERNCE_ROUNDING_LATE_SEC > 0 
                                                    BEGIN 

                                                        IF (@IN_DATE > @SHIFT_ST_DATETIME)
                                                        BEGIN
                                                            
                                                            SELECT @ACTUAL_MIN_DIFF = DATEDIFF(MINUTE, @ACTUAL_SHIFT_ST_TIME , @IN_DATE)
                                                            
                                                            
                                                            --UPDATE #LATE_MARK_SLAB SET CURR_COUNT = CURR_COUNT + 1 
                                                            --WHERE @ACTUAL_MIN_DIFF BETWEEN FROM_MIN AND TO_MIN 
                                                            
                                                            SET @TOTAL_LATE_SEC = @TOTAL_LATE_SEC + @DIFFERNCE_ROUNDING_LATE_SEC                                                        
                      
                                                            SET @VAR_RETURN_LATE_DATE = @VAR_RETURN_LATE_DATE + ';' + CAST(@IN_DATE AS VARCHAR(11))
                                                        END
                                                    END
                                            
                                END

										IF @OUT_DATE < @SHIFT_END_DATETIME AND @IS_CANCEL_EARLY_OUT = 0  AND @IS_HALF_DAY_LEAVE = 0 AND @IS_FULL_DAY_LEAVE = 0-- MODIFIED BY MITESH ON 08/08/2011
                                            BEGIN

                                                /* FOR SHIFT START TIME 12:00 AM & EMPLOYEE IN PUNCH EARLY THEN NOT COUNT LATE MARK (NIRMA CLIENT)  --ANKIT 07112015 */
                                                IF @ROUNDINGVALUE > 0 
                                                    BEGIN
                                                        IF DATEPART(HH,@SHIFT_ST_DATETIME) = 0 AND @IN_DATE < DATEADD(D,1,@FOR_DATECURR)
                                                            SET @DIFFERNCE_ROUNDING_LATE_SEC = @DIFFERNCE_ROUNDING_LATE_SEC + DATEDIFF(S,DATEADD(D,1,@FOR_DATECURR) ,@IN_DATE)
                                                        ELSE
                                                            SET @DIFFERNCE_ROUNDING_LATE_SEC = @DIFFERNCE_ROUNDING_LATE_SEC + DATEDIFF(S,CAST(@VAR_SHIFT_ST_DATE AS DATETIME) ,@IN_DATE)
                                                            
                                                        SELECT @DIFFERNCE_ROUNDING_LATE_SEC = @DIFFERNCE_ROUNDING_LATE_SEC + DBO.PRO_ROUNDING_SEC_HH_MM(@DIFFERNCE_ROUNDING_LATE_SEC,@ROUNDINGVALUE)
                                                    END 
                                                ELSE
                                                    BEGIN
														SET @DIFFERNCE_ROUNDING_LATE_SEC = @DIFFERNCE_ROUNDING_LATE_SEC + DATEDIFF(S,@OUT_DATE,@SHIFT_END_DATETIME)
                                                    END
                                                IF @DIFFERNCE_ROUNDING_LATE_SEC > 0 
                                                    BEGIN 

                                                        IF (@OUT_DATE < @SHIFT_END_DATETIME)
                                                        BEGIN
                                                            
                                                            SELECT @ACTUAL_MIN_DIFF = @ACTUAL_MIN_DIFF + DATEDIFF(MINUTE, @OUT_DATE,@ACTUAL_SHIFT_END_TIME)
                                                            
                                                            
                                                            --UPDATE #LATE_MARK_SLAB SET CURR_COUNT = CURR_COUNT + 1 
                                                            --WHERE @ACTUAL_MIN_DIFF BETWEEN FROM_MIN AND TO_MIN 
                                                            
                                                            SET @TOTAL_LATE_SEC = @TOTAL_LATE_SEC + @DIFFERNCE_ROUNDING_LATE_SEC                                                        
                      
                                                            SET @VAR_RETURN_LATE_DATE = @VAR_RETURN_LATE_DATE + ';' + CAST(@IN_DATE AS VARCHAR(11))
                                                        END
                                                    END
                                            
                                END
								
										IF @EXEMPT_SEC_MONTHLY <> 0
											BEGIN
												IF @EXEMPT_SEC_MONTHLY > @DIFFERNCE_ROUNDING_LATE_SEC
													BEGIN
														SET @EXEMPT_SEC_MONTHLY = @EXEMPT_SEC_MONTHLY - @DIFFERNCE_ROUNDING_LATE_SEC
														SET @DIFFERNCE_ROUNDING_LATE_SEC = 0
														SET @ACTUAL_MIN_DIFF = 0
													END
												ELSE
													BEGIN
														SET @DIFFERNCE_ROUNDING_LATE_SEC = @DIFFERNCE_ROUNDING_LATE_SEC - @EXEMPT_SEC_MONTHLY
														SET @EXEMPT_SEC_MONTHLY = 0
														SET @ACTUAL_MIN_DIFF = (DATEPART(HOUR,dbo.F_Return_Hours(@DIFFERNCE_ROUNDING_LATE_SEC))*60) + DATEPART(MINUTE,dbo.F_Return_Hours(@DIFFERNCE_ROUNDING_LATE_SEC))
													END
											END

										IF @ACTUAL_MIN_DIFF > 0 
											BEGIN
												UPDATE #LATE_MARK_SLAB SET CURR_COUNT = CURR_COUNT + 1 
                                                WHERE @ACTUAL_MIN_DIFF BETWEEN FROM_MIN AND TO_MIN 
											END
                        END
                    FETCH NEXT FROM CURLMARK INTO @IN_DATE,@OUT_DATE,@FOR_DATECURR
                END
            CLOSE curLMark;
            DEALLOCATE curLMark;
        END
      
        Declare @EXMPT_COUNT Numeric(18,0)
        Declare @CURR_COUNT Numeric(18,0)
        Declare @DEDUCTION Numeric(18,2)
        Declare @DEDUCTION_TYPE Varchar(100)
        Declare @TRANS_ID Numeric(18,0)
        Declare @ONE_TIME_EXEMPTION Numeric(2,0)
        Declare @GROUP_FLAG Numeric(2,0)
        
        Set @EXMPT_COUNT = 0
        Set @CURR_COUNT = 0
        Set @DEDUCTION = 0.00
        Set @DEDUCTION_TYPE = ''
        Set @TRANS_ID = 0
        Set @ONE_TIME_EXEMPTION = 0
        SET @GROUP_FLAG = 0
        
        UPDATE T1
                SET     GROUP_FLAG = 1
                FROM    #LATE_MARK_SLAB T1 
        INNER JOIN (SELECT T2.FROM_MIN, T2.TO_MIN FROM #LATE_MARK_SLAB T2 
        GROUP BY T2.FROM_MIN, T2.TO_MIN 
        HAVING COUNT(1) > 1) T2 ON T1.FROM_MIN=T2.FROM_MIN AND T1.TO_MIN = T2.TO_MIN
        
        
         
        DECLARE CURLATEMARK CURSOR FOR
        SELECT EXMPT_COUNT,CURR_COUNT,DEDUCTION,DEDUCTION_TYPE,TRANS_ID,ONE_TIME_EXEMPTION,GROUP_FLAG FROM #LATE_MARK_SLAB where GROUP_FLAG = 0
        UNION
        SELECT EXMPT_COUNT,CURR_COUNT,DEDUCTION,DEDUCTION_TYPE,LB.TRANS_ID,ONE_TIME_EXEMPTION,GROUP_FLAG FROM #LATE_MARK_SLAB LB
        INNER JOIN( SELECT MAX(TRANS_ID) AS TRANS_ID,FROM_MIN,TO_MIN 
                    FROM #LATE_MARK_SLAB Where GROUP_FLAG = 1 AND CURR_COUNT > EXMPT_COUNT 
                    GROUP BY FROM_MIN,TO_MIN
                  ) As Qry
        ON LB.TRANS_ID = Qry.TRANS_ID and LB.FROM_MIN = Qry.FROM_MIN and LB.TO_MIN = Qry.TO_MIN
        Where GROUP_FLAG = 1 AND CURR_COUNT > EXMPT_COUNT
        
        OPEN CURLATEMARK
        FETCH NEXT FROM CURLATEMARK INTO @EXMPT_COUNT,@CURR_COUNT,@DEDUCTION,@DEDUCTION_TYPE,@TRANS_ID,@ONE_TIME_EXEMPTION,@GROUP_FLAG
            WHILE @@FETCH_STATUS = 0
                BEGIN
                    
                    IF @LATE_ADJ_AGAIN_OT = 0 -- For check Late Mark Adjust Again OT 
                        BEGIN
                            IF UPPER(@DEDUCTION_TYPE) = 'DAYS'
                                BEGIN
                                     If @GROUP_FLAG <> 1
                                        Begin
                                            IF @ONE_TIME_EXEMPTION = 0
                                                BEGIN
                                                    UPDATE  #LATE_MARK_SLAB 
                                                    SET TOTAL_DEDUCT_DAYS = FLOOR((@CURR_COUNT/(@EXMPT_COUNT + 1))) * @DEDUCTION
                                                    WHERE TRANS_ID = @TRANS_ID
                                                END
                                            ELSE
                                                BEGIN
                                                    
                                                    UPDATE  #LATE_MARK_SLAB 
                                                    SET TOTAL_DEDUCT_DAYS =  (Case When @CURR_COUNT > 0 THEN (@CURR_COUNT - @EXMPT_COUNT) * @DEDUCTION Else 0 End)
                                                    WHERE TRANS_ID = @TRANS_ID
                                                END
                                        End
                                    Else
                                        Begin
                                            UPDATE #LATE_MARK_SLAB
												SET TOTAL_DEDUCT_DAYS = 1 * @DEDUCTION
                                            WHERE TRANS_ID = @TRANS_ID and GROUP_FLAG = 1 
                                        End
                                END
                        END
                    ELSE
                        BEGIN
                            UPDATE  #LATE_MARK_SLAB 
                                SET TOTAL_DEDUCT_DAYS = @CURR_COUNT * @DEDUCTION
                            WHERE TRANS_ID = @TRANS_ID
                        END
                    FETCH NEXT FROM CURLATEMARK INTO @EXMPT_COUNT,@CURR_COUNT,@DEDUCTION,@DEDUCTION_TYPE,@TRANS_ID,@ONE_TIME_EXEMPTION,@GROUP_FLAG
                END
        CLOSE CURLATEMARK;
        DEALLOCATE CURLATEMARK;
        
        
        IF @LATE_ADJ_AGAIN_OT = 0
            BEgin
                SELECT @LATE_SAL_DEDU_DAYS = SUM(TOTAL_DEDUCT_DAYS),@TOTAL_LMARK = SUM(CURR_COUNT),@TOTAL_LATE_OT_HOURS = 0 FROM #LATE_MARK_SLAB
            End
        Else
            Begin
                SELECT @LATE_SAL_DEDU_DAYS = SUM(TOTAL_DEDUCT_DAYS),@TOTAL_LMARK = SUM(CURR_COUNT) FROM #LATE_MARK_SLAB Where DEDUCTION_TYPE = 'Days'
                SELECT @TOTAL_LATE_OT_HOURS = SUM(TOTAL_DEDUCT_DAYS),@TOTAL_LMARK = SUM(CURR_COUNT) FROM #LATE_MARK_SLAB Where DEDUCTION_TYPE = 'Hours'
            End 
           
        --Select * From #LATE_MARK_SLAB
        --Select @VAR_RETURN_LATE_DATE
        
        
END

