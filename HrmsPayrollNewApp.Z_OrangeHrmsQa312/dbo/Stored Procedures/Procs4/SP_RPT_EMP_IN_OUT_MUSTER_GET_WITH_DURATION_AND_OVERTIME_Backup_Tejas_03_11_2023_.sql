create PROCEDURE [dbo].[SP_RPT_EMP_IN_OUT_MUSTER_GET_WITH_DURATION_AND_OVERTIME_Backup_Tejas(03/11/2023)]  
     @Cmp_ID        numeric  
    ,@From_Date     datetime  
    ,@To_Date       datetime  
    ,@Branch_ID     numeric  
    ,@Cat_ID        numeric   
    ,@Grd_ID        numeric  
    ,@Type_ID       numeric  
    ,@Dept_ID       numeric  
    ,@Desig_ID      numeric  
    ,@Emp_ID        numeric  
    ,@constraint    varchar(MAX)  
    ,@Report_For    varchar(10)  
AS  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
SET ANSI_WARNINGS OFF;  
  
      
    IF @Branch_ID = 0    
        set @Branch_ID = null  
          
    IF @Cat_ID = 0    
        set @Cat_ID = null  
  
    IF @Grd_ID = 0    
        set @Grd_ID = null  
  
    IF @Type_ID = 0    
        set @Type_ID = null  
  
    IF @Dept_ID = 0    
        set @Dept_ID = null  
  
    IF @Desig_ID = 0    
        set @Desig_ID = null  
  
    IF @Emp_ID = 0    
        set @Emp_ID = null  
          
    CREATE TABLE #Emp_Cons  
    (  
        Emp_ID          NUMERIC,  
        INCREMENT_ID    NUMERIC,  
        BRANCH_ID       NUMERIC  
    )  
  
    IF @Constraint <> ''  
        BEGIN  
            Insert Into #Emp_Cons(Emp_ID, INCREMENT_ID, BRANCH_ID)  
            SELECT  I.EMP_ID,I.INCREMENT_ID,I.BRANCH_ID  
            FROM    T0095_Increment I WITH (NOLOCK)   
                    INNER JOIN (SELECT  MAX(INCREMENT_ID) AS INCREMENT_ID, I1.EMP_ID  
                                FROM    T0095_INCREMENT I1 WITH (NOLOCK)  
                                        INNER JOIN (SELECT  MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I2.EMP_ID  
                                                    FROM    T0095_INCREMENT I2 WITH (NOLOCK)  
                                                    WHERE   I2.INCREMENT_EFFECTIVE_DATE <= @TO_DATE  
                                                    GROUP BY I2.EMP_ID) I2 ON I1.EMP_ID=I2.EMP_ID AND I1.INCREMENT_EFFECTIVE_DATE=I2.INCREMENT_EFFECTIVE_DATE  
                                GROUP BY I1.EMP_ID) I1 ON I.INCREMENT_ID=I1.INCREMENT_ID          
            WHERE   EXISTS (SELECT 1 FROM dbo.Split (@Constraint,'#') WHERE DATA <> '' AND CAST(DATA AS NUMERIC) = I.EMP_ID)  
        end  
    else  
        begin  
            Insert Into #Emp_Cons(Emp_ID, INCREMENT_ID, BRANCH_ID)  
            SELECT  I.Emp_Id, I.INCREMENT_ID, I.BRANCH_ID             
            FROM    T0095_Increment I  WITH (NOLOCK)  
                    INNER JOIN (SELECT  MAX(INCREMENT_ID) AS INCREMENT_ID, I1.EMP_ID  
                                FROM    T0095_INCREMENT I1 WITH (NOLOCK)  
                                        INNER JOIN (SELECT  MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I2.EMP_ID  
                                                    FROM    T0095_INCREMENT I2 WITH (NOLOCK)  
                                                    WHERE   I2.INCREMENT_EFFECTIVE_DATE <= @TO_DATE  
                                                    GROUP BY I2.EMP_ID) I2 ON I1.EMP_ID=I2.EMP_ID AND I1.INCREMENT_EFFECTIVE_DATE=I2.INCREMENT_EFFECTIVE_DATE  
                                GROUP BY I1.EMP_ID) I1 ON I.INCREMENT_ID=I1.INCREMENT_ID                      
            Where Cmp_ID = @Cmp_ID   
                    and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))  
                    and Branch_ID = isnull(@Branch_ID ,Branch_ID)  
                    and Grd_ID = isnull(@Grd_ID ,Grd_ID)  
                    and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))  
                    and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))  
                    and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))  
                    and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID)   
                    AND EXISTS (SELECT 1   
                                FROM    (SELECT     EMP_ID, CMP_ID, JOIN_DATE, isnull(left_Date, @To_date) as left_Date   
                                         FROM       T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry  
                  WHERE   cmp_ID = @Cmp_ID  AND    
                                        (  
                                            (  
                                                    (@From_Date >= join_Date  and  @From_Date <= left_date)   
                                                OR ( @To_Date  >= join_Date  and @To_Date <= left_date )  
                                                OR Left_date IS NULL AND @To_Date >= Join_Date  
                                            )  
                                            OR @To_Date >= left_date  and  @From_Date <= left_date   
                                        ) AND qry.EMP_ID=I.EMP_ID  
                                )  
        end  
      
    declare @For_Date datetime   
    Declare @Date_Diff numeric   
    Declare @New_To_Date datetime   
    Declare @Total_Overtime as numeric(18,2)  
    Declare @Present_days as numeric(18,2)  
       
    set @Date_Diff = datediff(d,@From_Date,@to_DAte) + 1   
    set @Date_Diff = 35 - ( @Date_Diff)  
    set @New_To_Date = @To_Date  
    set @Total_Overtime = 0  
    set @Present_days = 0  
  
 --added Deepali 15062023  
 Declare @RET_DAYS as Int  
 set @RET_DAYS =0  
     
     
    -------------- Add By Jignesh Patel 29-12-2021  
  
    SELECT GS.Branch_ID,INC_HOLIDAY,INC_WEEKOFF      
    INTO #GENERAL_SETTING      
    FROM T0040_GENERAL_SETTING GS WITH (NOLOCK)      
    INNER JOIN(      
     SELECT MAX(FOR_DATE) AS FOR_DATE,GS1.Branch_ID      
     FROM DBO.T0040_GENERAL_SETTING GS1 WITH (NOLOCK)      
     INNER JOIN #Emp_Cons EC ON GS1.Branch_ID=EC.Branch_ID      
     WHERE FOR_DATE < = @TO_DATE AND CMP_ID = @CMP_ID       
     GROUP BY GS1.Branch_ID       
    ) GS1 ON GS1.Branch_ID = GS.Branch_ID AND GS.FOR_DATE = GS1.FOR_DATE    
    --------------- End --------------------  
  
    IF  exists (select 1 from [tempdb].dbo.sysobjects where name like '#Att_Muster' )         
            BEGIN  
                drop table #Att_Muster  
            END  
      
     CREATE TABLE #Att_Muster   
      (  
            Emp_Id      numeric ,   
            Cmp_ID      numeric,  
            For_Date    datetime,  
            Leave_Count numeric(5,1),  
            WO_COHO     varchar(4),  
            Status_1_1  varchar(22),  
            Status_2_1  varchar(22),  
            Status_3_1  varchar(22),  
            Status_4_1  varchar(22),  
            Second_5_1  numeric(18,0),  
            Status_6_1  varchar(22),    --Ramiz  
            Status_7_1  varchar(22),    --Ramiz  
            Status_1_2  varchar(22),  
            Status_2_2  varchar(22),  
            Status_3_2  varchar(22),  
            Status_4_2  varchar(22),  
            Second_5_2  numeric(18,0),  
            Status_6_2  varchar(22),    --Ramiz  
            Status_7_2  varchar(22),    --Ramiz  
            Status_1_3  varchar(22),  
            Status_2_3  varchar(22),  
            Status_3_3  varchar(22),  
            Status_4_3  varchar(22),  
            Second_5_3  numeric(18,0),  
            Status_6_3  varchar(22),    --Ramiz  
            Status_7_3  varchar(22),    --Ramiz  
            Status_1_4  varchar(22),  
            Status_2_4  varchar(22),  
            Status_3_4  varchar(22),  
            Status_4_4  varchar(22),  
            Second_5_4  numeric(18,0),  
            Status_6_4  varchar(22),    --Ramiz  
            Status_7_4  varchar(22),    --Ramiz  
            Status_1_5  varchar(22),  
            Status_2_5  varchar(22),  
            Status_3_5  varchar(22),  
            Status_4_5  varchar(22),  
            Second_5_5  numeric(18,0),  
            Status_6_5  varchar(22),    --Ramiz  
            Status_7_5  varchar(22),    --Ramiz  
            Status_1_6  varchar(22),  
            Status_2_6  varchar(22),  
            Status_3_6  varchar(22),  
            Status_4_6  varchar(22),  
            Second_5_6  numeric(18,0),  
            Status_6_6  varchar(22),    --Ramiz  
            Status_7_6  varchar(22),    --Ramiz  
            Status_1_7  varchar(22),  
            Status_2_7  varchar(22),  
            Status_3_7  varchar(22),  
            Status_4_7  varchar(22),  
            Second_5_7  numeric(18,0),  
            Status_6_7  varchar(22),    --Ramiz  
            Status_7_7  varchar(22),    --Ramiz  
            Status_1_8  varchar(22),  
            Status_2_8  varchar(22),  
            Status_3_8  varchar(22),  
            Status_4_8  varchar(22),  
            Second_5_8  numeric(18,0),  
            Status_6_8  varchar(22),    --Ramiz  
            Status_7_8  varchar(22),    --Ramiz  
            Status_1_9  varchar(22),  
            Status_2_9  varchar(22),  
            Status_3_9  varchar(22),  
            Status_4_9  varchar(22),  
            Second_5_9  numeric(18,0),  
            Status_6_9  varchar(22),    --Ramiz  
            Status_7_9  varchar(22),    --Ramiz  
            Status_1_10 varchar(22),  
            Status_2_10 varchar(22),  
            Status_3_10 varchar(22),  
            Status_4_10 varchar(22),  
            Second_5_10  numeric(18,0),  
            Status_6_10 varchar(22),    --Ramiz  
            Status_7_10 varchar(22),    --Ramiz  
            Status_1_11 varchar(22),  
            Status_2_11 varchar(22),  
            Status_3_11 varchar(22),  
            Status_4_11 varchar(22),  
            Second_5_11  numeric(18,0),  
            Status_6_11 varchar(22),    --Ramiz  
            Status_7_11 varchar(22),    --Ramiz  
            Status_1_12 varchar(22),  
            Status_2_12 varchar(22),  
            Status_3_12 varchar(22),  
            Status_4_12 varchar(22),  
            Second_5_12  numeric(18,0),  
            Status_6_12 varchar(22),    --Ramiz  
            Status_7_12 varchar(22),    --Ramiz  
            Status_1_13 varchar(22),  
            Status_2_13 varchar(22),  
            Status_3_13 varchar(22),  
            Status_4_13 varchar(22),  
            Second_5_13  numeric(18,0),  
            Status_6_13 varchar(22),    --Ramiz  
            Status_7_13 varchar(22),    --Ramiz  
            Status_1_14 varchar(22),  
            Status_2_14 varchar(22),  
            Status_3_14 varchar(22),  
            Status_4_14 varchar(22),  
            Second_5_14  numeric(18,0),  
            Status_6_14 varchar(22),    --Ramiz  
            Status_7_14 varchar(22),    --Ramiz  
            Status_1_15 varchar(22),  
            Status_2_15 varchar(22),  
            Status_3_15 varchar(22),  
            Status_4_15 varchar(22),  
            Second_5_15  numeric(18,0),  
            Status_6_15 varchar(22),    --Ramiz  
            Status_7_15 varchar(22),    --Ramiz  
            Status_1_16 varchar(22),  
            Status_2_16 varchar(22),  
            Status_3_16 varchar(22),  
            Status_4_16 varchar(22),  
            Second_5_16  numeric(18,0),  
            Status_6_16 varchar(22),    --Ramiz  
            Status_7_16 varchar(22),    --Ramiz  
            Status_1_17 varchar(22),  
            Status_2_17 varchar(22),  
            Status_3_17 varchar(22),  
            Status_4_17 varchar(22),  
            Second_5_17  numeric(18,0),  
            Status_6_17 varchar(22),    --Ramiz  
            Status_7_17 varchar(22),    --Ramiz  
            Status_1_18 varchar(22),  
            Status_2_18 varchar(22),  
            Status_3_18 varchar(22),  
            Status_4_18 varchar(22),  
            Second_5_18  numeric(18,0),  
            Status_6_18 varchar(22),    --Ramiz  
            Status_7_18 varchar(22),    --Ramiz  
            Status_1_19 varchar(22),  
            Status_2_19 varchar(22),  
            Status_3_19 varchar(22),  
            Status_4_19 varchar(22),  
            Second_5_19  numeric(18,0),  
            Status_6_19 varchar(22),    --Ramiz  
            Status_7_19 varchar(22),    --Ramiz  
            Status_1_20 varchar(22),  
            Status_2_20 varchar(22),  
            Status_3_20 varchar(22),  
            Status_4_20 varchar(22),  
            Second_5_20  numeric(18,0),  
            Status_6_20 varchar(22),    --Ramiz  
            Status_7_20 varchar(22),    --Ramiz  
            Status_1_21 varchar(22),  
            Status_2_21 varchar(22),  
            Status_3_21 varchar(22),  
            Status_4_21 varchar(22),  
            Second_5_21  numeric(18,0),  
            Status_6_21 varchar(22),    --Ramiz  
            Status_7_21 varchar(22),    --Ramiz  
            Status_1_22 varchar(22),  
            Status_2_22 varchar(22),  
            Status_3_22 varchar(22),  
            Status_4_22 varchar(22),  
            Second_5_22  numeric(18,0),  
            Status_6_22 varchar(22),    --Ramiz  
            Status_7_22 varchar(22),    --Ramiz  
            Status_1_23 varchar(22),  
            Status_2_23 varchar(22),  
            Status_3_23 varchar(22),  
            Status_4_23 varchar(22),  
            Second_5_23  numeric(18,0),  
            Status_6_23 varchar(22),    --Ramiz  
            Status_7_23 varchar(22),    --Ramiz  
            Status_1_24 varchar(22),  
            Status_2_24 varchar(22),  
            Status_3_24 varchar(22),  
            Status_4_24 varchar(22),  
            Second_5_24  numeric(18,0),  
            Status_6_24 varchar(22),    --Ramiz  
            Status_7_24 varchar(22),    --Ramiz  
            Status_1_25 varchar(22),  
            Status_2_25 varchar(22),  
            Status_3_25 varchar(22),  
            Status_4_25 varchar(22),  
            Second_5_25  numeric(18,0),  
            Status_6_25 varchar(22),    --Ramiz  
            Status_7_25 varchar(22),    --Ramiz  
            Status_1_26 varchar(22),  
            Status_2_26 varchar(22),  
            Status_3_26 varchar(22),  
            Status_4_26 varchar(22),  
            Second_5_26  numeric(18,0),  
            Status_6_26 varchar(22),    --Ramiz  
            Status_7_26 varchar(22),    --Ramiz  
            Status_1_27 varchar(22),  
            Status_2_27 varchar(22),  
            Status_3_27 varchar(22),  
            Status_4_27 varchar(22),  
            Second_5_27  numeric(18,0),  
            Status_6_27 varchar(22),    --Ramiz  
            Status_7_27 varchar(22),    --Ramiz  
            Status_1_28 varchar(22),  
            Status_2_28 varchar(22),  
            Status_3_28 varchar(22),  
            Status_4_28 varchar(22),  
            Second_5_28  numeric(18,0),  
            Status_6_28 varchar(22),    --Ramiz  
            Status_7_28 varchar(22),    --Ramiz  
            Status_1_29 varchar(22),  
            Status_2_29 varchar(22),  
            Status_3_29 varchar(22),  
            Status_4_29 varchar(22),  
            Second_5_29  numeric(18,0),  
            Status_6_29 varchar(22),    --Ramiz  
            Status_7_29 varchar(22),    --Ramiz  
            Status_1_30 varchar(22),  
            Status_2_30 varchar(22),  
            Status_3_30 varchar(22),  
            Status_4_30 varchar(22),  
            Second_5_30  numeric(18,0),  
            Status_6_30 varchar(22),    --Ramiz  
            Status_7_30 varchar(22),    --Ramiz  
            Status_1_31 varchar(22),  
            Status_2_31 varchar(22),  
            Status_3_31 varchar(22),  
            Status_4_31 varchar(22),  
            Second_5_31  numeric(18,0),  
            Status_6_31 varchar(22),    --Ramiz  
            Status_7_31 varchar(22),    --Ramiz  
            Present_days Numeric(18,2),  
            Total_Overtime varchar(22),  
   WO_Count numeric(5,2),   ------ Jignesh Patel 29-12-2021--  
   HO_Count numeric(5,2)   ------ Jignesh Patel 29-12-2021--  
      )  
      create unique nonclustered index ix_Att_Muster on #Att_Muster(Emp_ID)  
  
  
    if OBJECT_ID('tempdb..#Data') IS NULL  
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
               IO_Tran_Id      numeric default 0, -- io_tran_id is used for is_cmp_purpose (t0150_emp_inout)  
               OUT_Time datetime,  
               Shift_End_Time datetime,  
               OT_End_Time numeric default 0,  
               Working_Hrs_St_Time tinyint default 0,  
               Working_Hrs_End_Time tinyint default 0,  
               GatePass_Deduct_Days numeric(18,2) default 0
			   
           )  
             
           create nonclustered index ix_Data on #Data(Emp_ID, For_Date)    
        END  
          
    Declare @Is_Cancel_Holiday  numeric(1,0)  
    Declare @Is_Cancel_Weekoff  numeric(1,0)      
    Declare @strHoliday_Date As Varchar(max)  
    Declare @StrWeekoff_Date  varchar(max)  
    DECLARE @LEFT_DATE AS DATETIME  
    DECLARE @DEFAULTDATE AS DATETIME; -- DECLARED @TEMP FOR CASTING IT IN DATETIME  
    SET @DEFAULTDATE = '1900-01-01';  
  
    Set @StrHoliday_Date = ''        
    set @StrWeekoff_Date = ''  
    --set @Left_Date=@To_Date;  
  
   
    
    IF OBJECT_ID('tempdb..#EMP_HOLIDAY') IS NULL  
        BEGIN  
            CREATE TABLE #EMP_HOLIDAY(EMP_ID NUMERIC, FOR_DATE DATETIME, IS_CANCEL BIT, Is_Half tinyint, Is_P_Comp tinyint, H_DAY numeric(3,1));  
            CREATE UNIQUE CLUSTERED INDEX IX_EMP_HOLIDAY_EMPID_FORDATE ON #EMP_HOLIDAY(EMP_ID, FOR_DATE);  
        END  
     IF OBJECT_ID('tempdb..#Emp_WeekOff') IS NULL  
        BEGIN  
            CREATE TABLE #Emp_WeekOff  
            (  
                Row_ID          NUMERIC,  
                Emp_ID          NUMERIC,  
                For_Date        DATETIME,  
                Weekoff_day     VARCHAR(10),  
                W_Day           numeric(3,1),  
                Is_Cancel       BIT  
            )  
            CREATE CLUSTERED INDEX IX_Emp_WeekOff_EmpID_ForDate ON #Emp_WeekOff(Emp_ID, For_Date)         
        END  
      
    If @Report_For = 'Format 3' OR @Report_For= 'EMP RECORD'  ----------- EMP RECORD Add By Jignesh Patel 29-12-2021  
        BEGIN  
            CREATE TABLE #ATT_DAYS  
            (  
                EMP_ID      NUMERIC,  
                P_DAYS      NUMERIC(18,2),  
                A_DAYS      NUMERIC(18,2),  
                HF_DAYS     NUMERIC(18,2),  
                L_DAYS      NUMERIC(18,2),                
                WO_DAYS     NUMERIC(18,2),  
                HO_DAYS     NUMERIC(18,2) ,  
    PAYABLE_DAYS NUMERIC(18,2) ,  
    RET_DAYS NUMERIC(18,2) default 0, --- Added By deepali-15062023  
	 AvgTime varchar(max) default ''
            )  
            CREATE CLUSTERED INDEX IX_ATT_DAYS_EmpID ON #ATT_DAYS(Emp_ID)         
        END   
      
    exec SP_CALCULATE_PRESENT_DAYS @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint , 4   
          
          
   -------SELECT 100, * from #Data  
  
  
    INSERT INTO #Att_Muster (Emp_ID,Cmp_ID,For_Date)  
    SELECT  Emp_ID ,@Cmp_ID ,@From_date from #Emp_Cons  
   
 --Added by Jaina 17-11-2017  
 DECLARE @Comp_OD_As_Present AS Bit  
 SELECT @Comp_OD_As_Present = ISNULL(SETTING_VALUE,0) FROM T0040_SETTING  WITH (NOLOCK)  
 WHERE SETTING_NAME = 'OD and CompOff Leave Consider As Present' AND CMP_ID = @CMP_ID  
   
  --Select * From #Data   
   
 -- Added By Sajid 02-05-2023  
 DELETE D     
 FROM #Emp_WeekOff D     
 INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK)  ON D.Emp_Id=E.Emp_ID    
 WHERE (D.For_date < E.Date_Of_Join OR D.For_date > ISNULL(E.EMP_LEFT_DATE, @TO_DATE))    
  
 -- Added By Sajid 02-05-2023  
 DELETE D     
 FROM #EMP_HOLIDAY D     
 INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK)  ON D.Emp_Id=E.Emp_ID    
 WHERE (D.For_date < E.Date_Of_Join OR D.For_date > ISNULL(E.EMP_LEFT_DATE, @TO_DATE))    
   
 --Added By Sajid and Deepali 15062023 Start  
 declare @curCM_ID as Numeric  
 Declare @curemp_id as Numeric  
 Declare @curTempDate as datetime   
   
 UPDATE #Emp_WeekOff SET Is_Cancel=1  
 FROM #Emp_WeekOff EW  
 LEFT OUTER JOIN T0100_EMP_RETAINTION_STATUS ERS ON ERS.Emp_ID = EW.Emp_ID   
 where  EW.For_Date between ERS.Start_Date and ERS.End_Date  
  
 UPDATE #EMP_HOLIDAY SET Is_Cancel=1  
 FROM #EMP_HOLIDAY EH  
 LEFT OUTER JOIN T0100_EMP_RETAINTION_STATUS ERS1 ON ERS1.Emp_ID = EH.Emp_ID   
 where  EH.For_Date between ERS1.Start_Date and ERS1.End_Date  
  
 DELETE #DATA   
 FROM #DATA DA  
 LEFT OUTER JOIN T0100_EMP_RETAINTION_STATUS ERS2 ON ERS2.Emp_ID = DA.Emp_ID   
 where  DA.For_Date between ERS2.Start_Date and ERS2.End_Date  
   
 --Added By Sajid and Deepali 15062023 Start     
  
    If @Report_For = 'Format 3' OR    @Report_For= 'EMP RECORD' --- Emp Record Add By Jignsh Patel 29-12-2021---  
        BEGIN  
          
              
            INSERT INTO #ATT_DAYS(EMP_ID, P_DAYS, A_DAYS, HF_DAYS, L_DAYS, WO_DAYS, HO_DAYS)  
            SELECT  E.Emp_ID,IsNull(P_DAY.TOTAL_P_DAYS,0),0,IsNull(TOTAL_HF_DAYS,0),0,IsNull(Total_WO,0),IsNull(Total_HO,0)  
            FROM    #Emp_Cons E   
                    LEFT OUTER JOIN (SELECT EMP_ID, SUM(P_DAYS) AS TOTAL_P_DAYS FROM #DATA WHERE For_Date BETWEEN @From_Date AND @To_Date AND P_days = 1 GROUP BY Emp_ID) P_DAY ON E.Emp_ID=P_DAY.Emp_ID  
                    LEFT OUTER JOIN (SELECT EMP_ID, SUM(W_Day) AS Total_WO FROM #Emp_WeekOff WHERE For_Date BETWEEN @From_Date AND @To_Date AND Is_Cancel=0 and W_Day > 0 GROUP BY Emp_ID) WO ON E.Emp_ID=WO.Emp_ID  
                    LEFT OUTER JOIN (SELECT EMP_ID, SUM(H_DAY) AS Total_HO FROM #EMP_HOLIDAY WHERE For_Date BETWEEN @From_Date AND @To_Date AND Is_Cancel=0 and H_DAY > 0 GROUP BY Emp_ID) HO ON E.Emp_ID=HO.Emp_ID           
                    LEFT OUTER JOIN (SELECT EMP_ID, COUNT(1) AS TOTAL_HF_DAYS   
                                    FROM #DATA D WHERE For_Date BETWEEN @From_Date AND @To_Date AND P_days = 0.5 GROUP BY Emp_ID) D_P ON E.Emp_ID=D_P.Emp_ID  
                    --LEFT OUTER JOIN (SELECT EMP_ID, SUM(P_DAYS) AS TOTAL_P_DAYS, SUM(CASE WHEN ISNULL(P_DAYS,0) = 0.5 THEN 1 ELSE 0 END) AS TOTAL_HF_DAYS   
                                    --FROM #DATA D WHERE For_Date BETWEEN @From_Date AND @To_Date AND P_days > 1 GROUP BY Emp_ID) D_P ON E.Emp_ID=D_P.Emp_ID  
               
    --Added by Jaina 17-11-2017  
   if @Comp_OD_As_Present = 1  
    begin  
     UPDATE A  
      SET P_DAYS =cast(Round(A.P_DAYS + Isnull(Q1.OD_Compoff,0),2) as numeric(18,2)) --Q.P_DAYS + ISNULL(Q1.OD_COMPOFF,0)  
     FROM #ATT_DAYS A  LEFT OUTER JOIN   
       (select sum((IsNull(LT.CompOff_Used,0) + IsNull(LT.Leave_Used,0)) * CASE WHEN LM.Apply_Hourly = 1 THEN 0.125 ELSE 1 END)  AS OD_Compoff,lt.Emp_ID  
       from T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)  
         INNER JOIN  T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LT.Leave_ID=LM.Leave_ID        
       where (Leave_Type='Company Purpose' OR Leave_Code = 'COMP') and LT.Cmp_ID=@Cmp_ID  
         AND LT.FOR_DATE BETWEEN @FROM_DATE AND @TO_dATE  
       group by Emp_ID  
       )Q1 on A.Emp_ID = Q1.Emp_ID        
       
    end   
                              
   END  
      
    --For Format 3 (Attedance Days)  
    --DECLARE @A_DAYS NUMERIC(18,2)  
    DECLARE @L_DAYS NUMERIC(18,2)  
   
   
    Declare @Temp_Date datetime  
    Declare @count numeric   
    Declare @OutRuchi AS DateTime  
    Declare @tmp_InTime DateTime  
    Declare @tmp_OutTime DateTime  
              
    declare @Shift_St_Time as varchar(10)        
    declare @Shift_End_Time as varchar(10)        
    declare @Shift_Id as Numeric  
    declare @Shift_Dur as varchar(10)  
    Declare @Shift_End_DateTime as datetime        
    Declare @Shift_ST_DateTime as datetime            
    declare @Shift_St_Sec as numeric         
    declare @Shift_En_sec as numeric      
    Declare @Temp_Date1 as datetime   
    Declare @Night_Shift as tinyint          
              
    declare @status_1 varchar(100)  
    declare @status_2 varchar(100)  
    declare @status_3 varchar(100)  
    declare @status_4 varchar(100)  
    declare @status_5 varchar(100)  
    declare @status_6 varchar(100)  --Added By Ramiz  
    declare @status_7 varchar(100)  --Added By Ramiz  
    declare @strQry nvarchar(max)     
	Declare @AvgTime time(7) 
  
 Declare @WorkingDuration as varchar(100) -------- jignesh patel 06-04-2022  
  
      
 DECLARE @EMP_JOINING_DATE AS DATETIME      
  
 --Added by Deepali-06132023-start  
 declare   @curRetDate as datetime  
 set @curRetDate = @From_Date  
  
   
    --Added by Deepali-06132023-End   
  
    Declare @Emp_Id_Cur As Numeric(18,0)  
    Set @Emp_Id_Cur=0  
    -- Select A.Emp_Id ,E.Emp_LefT_Date From #Att_Muster A  INNER JOIN T0080_Emp_Master E WITH (NOLOCK) on E.Emp_ID=A.Emp_ID AND E.Cmp_ID=A.Cmp_ID  
    Declare Att_Cursor Cursor For   
  
    Select  A.Emp_Id,E.Emp_LefT_Date   
    From    #Att_Muster A   
            INNER JOIN T0080_Emp_Master E WITH (NOLOCK) on E.Emp_ID=A.Emp_ID   
            AND E.Cmp_ID=A.Cmp_ID  
     
   --Select Emp_Id From #Att_Muster   
    Open Att_Cursor  
    Fetch Next From Att_Cursor INTO @Emp_Id_Cur,@Left_Date  
    while @@fetch_status = 0  
        Begin   
  
            SELECT @Branch_ID = BRANCH_ID FROM #EMP_CONS WHERE EMP_ID=@EMP_ID  
  
            SELECT  @Is_Cancel_Holiday = isnull(Is_Cancel_Holiday,0)  ,@Is_Cancel_Weekoff = isnull(Is_Cancel_Weekoff,0)  
            from    dbo.T0040_GENERAL_SETTING WITH (NOLOCK)  
            where   cmp_ID = @cmp_ID    and Branch_ID = @Branch_ID  
                    and For_Date = ( select max(For_Date) from dbo.T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@To_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)  
              
              
            SET @Temp_Date = NULL  
            SET @count = NULL  
            SET @OutRuchi = NULL  
            SET @tmp_InTime = NULL  
            SET @tmp_OutTime = NULL  
              
            SET @Shift_St_Time = NULL  
            SET @Shift_End_Time = NULL  
            SET @Shift_Id = NULL  
            SET @Shift_Dur = NULL  
            SET @Shift_End_DateTime = NULL  
            SET @Shift_ST_DateTime = NULL  
            SET @Shift_St_Sec = NULL  
            SET @Shift_En_sec = NULL  
            SET @Temp_Date1 = NULL  
            SET @Night_Shift = NULL  
              
            SET @status_1 = NULL  
            SET @status_2 = NULL  
            SET @status_3 = NULL  
            SET @status_4 = NULL  
            SET @status_5 = NULL  
            SET @status_6 = NULL  
            SET @status_7 = NULL  
            SET @strQry = NULL  
            SET @AvgTime = NULL  
              
  
            --SET @A_DAYS = 0;  
            SET @L_DAYS = 0;  
  
                 
            Set @Night_Shift = 0  
              
            set @Temp_Date = @From_Date   
            set @count = 1   
            while @Temp_Date <=@To_Date   
                Begin             
                      
                    set @status_1 = 'Status_1_'+ cast(@count as varchar(2))  
                    set @status_2 = 'Status_2_'+ cast(@count as varchar(2))   
                    set @status_3 = 'Status_3_'+ cast(@count as varchar(2))   
                    set @status_4 = 'Status_4_'+ cast(@count as varchar(2))   
                    set @status_5 = 'Second_5_'+ cast(@count as varchar(2))   
                    set @status_6 = 'Status_6_'+ cast(@count as varchar(2)) --Added By Ramiz  
                    set @status_7 = 'Status_7_'+ cast(@count as varchar(2)) --Added By Ramiz  
                      
                    --If @Night_Shift = 0   
                    --  Begin  
    ---------------------------------------------/* Here we are Inserting In-Time in Status_1  */-----------------------------------------------------------  
  
                    set @strQry = 'UPDATE   AM   
                                    Set     ' + @Status_1 + ' = dbo.F_Return_HHMM(D.In_time),  
         ' + @status_2 + ' = dbo.F_Return_HHMM(Out_Time)  
                                    FROM    #Att_Muster AM   
                                            INNER JOIN #Data D on Am.Emp_ID =D.emp_ID  
                                    WHERE   D.For_Date = ''' + cast(@Temp_Date as varchar(11)) + ''' AND D.Emp_Id = ' + cast(@Emp_Id_Cur as varchar(11))  
                                              
                    exec(@strQry)  
                      
                      
                --Added by Jaina 18-11-2016 Start  
                Select  @tmp_InTime=In_time   
    ,@WorkingDuration = isnull(Duration_in_sec,0)  ---------- Add by jigensh patel 06-04-2022  
                From    #Data D  
                Where   D.For_Date=@Temp_Date and D.Emp_Id=@Emp_Id_Cur  
                  
                SELECT  @tmp_OutTime=D.Out_Time   
                FROM    #DATA D  
                WHERE   FOR_DATE=@Temp_Date AND Emp_ID=@Emp_Id_Cur  
                --Added by Jaina 18-11-2016 End  
                  
                      
                    If @tmp_OutTime is not null   --Change By Jaina 18-11-2016  
                            Begin  
  
  
       -------------- Modify By Jigensh Patel 06-04-2022----------------  
                            --Set @strQry = 'Update #Att_Muster  
                            --                set ' + @status_5 + ' = ' + cast(isnull(ROUND(datediff(SECOND,@tmp_InTime,@tmp_OutTime),2),0) AS varchar(10)) + '  
                            --                where Emp_Id = ' + cast(@Emp_Id_Cur as varchar(10))  
                            --Exec (@strQry)  
                              
       Set @strQry = 'Update #Att_Muster  
                                            set ' + @status_5 + ' = ' + @WorkingDuration + '  
                                            where Emp_Id = ' + cast(@Emp_Id_Cur as varchar(10))  
                            Exec (@strQry)  
       ---------------------- End -----------------------  
                                              
                            Set @strQry = 'Update #Att_Muster  
                                            set ' + @status_4 + ' = dbo.F_Return_Hours(' + @status_5 + ')  
                                            where Emp_Id = ' + cast(@Emp_Id_Cur as varchar(10))  
                            Exec (@strQry)  
  
  
                        End  
  
------------------------------------/* Here we are Inserting Week-Off in Status_3 and If employee has Worked on Week-Off then Status_4 is Made Null ,  
--                                      because it will be Printed in Status_6 as Overtime */-------------------------------------------------------      
                          
                    --If exists (Select 1 from #Emp_Weekoff EW Where EW.Emp_Id = @Emp_Id_Cur And EW.For_Date = @Temp_Date And W_Day > 0 and EW.For_Date<=isnull(@Left_Date,EW.For_Date))  
                    --  Begin  
                    --      set @strQry =  'Update #Att_Muster  
             --      set WO_COHO = ''WO'', ' + @status_3 + ' = ''WO'',  
                    --      ' + @status_4 + ' = NULL  
                    --      Where Emp_Id = ' + cast(@Emp_Id_Cur as varchar(10))  
                              
                    --      Exec (@StrQry)  
                    --  End  
                  
------------------------------------/* Here we are Inserting Holiday in Status_3 and If employee has Worked on Holiday then Status_4 is Made Null ,  
--                                      because it will be Printed in Status_6 as Overtime */-------------------------------------------------------                              
                      
                    --If exists (Select 1 from #Emp_Holiday EH Where EH.Emp_Id = @Emp_Id_Cur And EH.For_Date = @Temp_Date and isnull(EH.is_Half,0) = 0 and EH.For_Date<=isnull(@Left_Date,EH.For_Date))  
                    --  Begin  
                          
                    --      set @strQry =  'Update #Att_Muster  
                    --   set WO_COHO = ''HO'', ' + @status_3 + ' = ''HO'',  
                    --      ' + @status_4 + ' = NULL  
                    --      Where Emp_Id = ' + cast(@Emp_Id_Cur as varchar(10))  
                              
                    --      Exec (@StrQry)  
                    --  End  
-------------------------------------------------/* Here we are Inserting Half-Holiday in Status_3 */-----------------------------------------------------------                              
                          
                    --If exists (Select 1 from #Emp_Holiday EH Where EH.Emp_Id = @Emp_Id_Cur And EH.For_Date = @Temp_Date and isnull(EH.is_Half,0) = 1 and EH.For_Date<=isnull(@Left_Date,EH.For_Date))  
                    --  Begin  
                    --      set @strQry =  'Update #Att_Muster  
                    --      set WO_COHO = ''HHO'', ' + @status_3 + ' = ''HHO''   
                    --      Where Emp_Id = ' + cast(@Emp_Id_Cur as varchar(10))  
                              
                    --      Exec (@StrQry)  
                    --  End  
-----------------------------------------------/* Here we are Inserting Leaves in Status_3  */-----------------------------------------------------------                         
                    /* --------------------- Modify Jignesh Patel 27-Dec-2021-------------- Move Below Code  after Inserting (Overtime in Status_6)  
                    Set @strQry = 'Update #Att_Muster  
                                    set ' + @status_3 + ' = Leave_code,  
                                    Leave_Count = isnull(Leave_Used,0) + isnull(CompOff_Used,0)  
                                    from #Att_Muster AM inner join T0140_LEAVE_TRANSACTION LT ON AM.EMP_ID = LT.EMP_ID Inner join  
                                    T0040_leave_master lm on lt.leavE_ID = lm.leave_ID   
                                    AND ''' + cast(@Temp_date as varchar(11)) + ''' = LT.FOR_DATE  
                                    and Day(LT.FOR_DATE)=Day(''' + cast(@Temp_date as varchar(11)) + ''')   
                                    where (LT.Leave_Used  > 0 or LT.CompOff_Used > 0) And Am.Emp_Id = ' + cast(@Emp_Id_Cur as varchar(11))  
           
                    Exec (@strqry)  
     */------------------------------ End -----------------------------  
  
                    --SELECT * from #Att_Muster where for_Date= '2017-01-02'  
-----------------------------------------------/* Here we are Inserting (Overtime in Status_6) and (Name_of_Shift in Status_7)  */-----------------------------------------------------------                         
                    If exists (Select 1 from #Data DM Where DM.Emp_Id = @Emp_Id_Cur And DM.For_Date = @Temp_Date)  
                        Begin                                     
                            Set @strQry = ' Update #Att_Muster  
                                            set ' + @status_6 + ' = dbo.F_Return_Hours(Q.Total_OT),  
                                            ' + @status_7 + ' = Left(SM.Shift_Name , 3),  
                                            ' + @status_3 + ' =   
                 Case When  P_days = ''1.000''   
                                                                     Then ''P''  
                                                                     When  P_days = ''0.500''  
                                                                     Then ''HF''  
                                                                     When  P_days = ''0'' --AND ' + @status_3 + ' NOT IN (''HO'',''HHO'' , ''WO'')  
                                                                     Then ''AB''  
                                                                     Else '+ @status_3 +' End  
                                            FROM #Att_Muster AM   
                                            INNER JOIN  
                                                ( select Emp_Id,For_Date ,Shift_id ,P_days ,In_Time ,Out_Time,(OT_sec + Weekoff_OT_Sec + Holiday_OT_Sec) Total_OT  from #Data   
                                                  Where For_Date >= ''' + cast(@Temp_Date as varchar(11)) + ''' and For_Date <= ''' + cast(@Temp_Date as varchar(11)) + '''   
                                                        and Emp_id = '+ cast(@Emp_Id_Cur as varchar(10)) + '  
                                                )q on AM.Emp_ID = Q.emp_ID   
                                            INNER JOIN T0040_SHIFT_MASTER SM WITH (NOLOCK) on SM.Shift_ID = q.Shift_ID  
                                            where AM.Emp_Id = ' + cast(@Emp_Id_Cur as varchar(10))    
                                                                  
                           Exec (@strQry)  
                              
                     End  
  
 --  
  
-----------------------------------------------/* Here we are Inserting Leaves in Status_3  */-----------------------------------------------------------                         
    -- --------------------- Add By Jignesh Patel 27-Dec-2021--------------   
                    Set @strQry = 'Update #Att_Muster  
                                    set ' + @status_3 + ' = Leave_code,  
                                    Leave_Count =  isnull(Leave_Used,0) + isnull(CompOff_Used,0)  
                                    from #Att_Muster AM inner join T0140_LEAVE_TRANSACTION LT ON AM.EMP_ID = LT.EMP_ID Inner join  
                                    T0040_leave_master lm on lt.leavE_ID = lm.leave_ID   
                                    AND ''' + cast(@Temp_date as varchar(11)) + ''' = LT.FOR_DATE  
                                    and Day(LT.FOR_DATE)=Day(''' + cast(@Temp_date as varchar(11)) + ''')   
                                    where (LT.Leave_Used  > 0 or LT.CompOff_Used > 0) And Am.Emp_Id = ' + cast(@Emp_Id_Cur as varchar(11))  
                    Exec (@strqry)  
    -------------------------------- End -----------------------------  
  
  
  
                ----------------------/* Here we are Inserting Week-Off in Status_3 and If employee has Worked on Week-Off then Status_4 is Made Null ,  
                    --because it will be Printed in Status_6 as Overtime */-------------------------------------------------------    
                      
                        If exists (Select 1 from #Emp_Weekoff EW Where EW.Emp_Id = @Emp_Id_Cur And EW.For_Date = @Temp_Date And W_Day > 0 and EW.For_Date<=isnull(@Left_Date,EW.For_Date))  
                        Begin  
                            set @strQry =  'Update #Att_Muster  
                            set WO_COHO = ''WO'', ' + @status_3 + ' = ''WO'',  
                            ' + @status_4 + ' = NULL  
                            Where Emp_Id = ' + cast(@Emp_Id_Cur as varchar(10))  
                              
                            Exec (@StrQry)  
                        End  
                    ------------------------/* Here we are Inserting Holiday in Status_3 and If employee has Worked on Holiday then Status_4 is Made Null ,  
                    --because it will be Printed in Status_6 as Overtime */-------------------------------------------------------                            
                      
                        If exists (Select 1 from #Emp_Holiday EH Where EH.Emp_Id = @Emp_Id_Cur And EH.For_Date = @Temp_Date and isnull(EH.is_Half,0) = 0 and EH.For_Date<=isnull(@Left_Date,EH.For_Date))  
                        Begin  
                          
                            set @strQry =  'Update #Att_Muster  
                            set WO_COHO = ''HO'', ' + @status_3 + ' = ''HO'',  
                            ' + @status_4 + ' = NULL  
                            Where Emp_Id = ' + cast(@Emp_Id_Cur as varchar(10))  
                              
                            Exec (@StrQry)  
                        End  
                    -------------------------------------------------/* Here we are Inserting Half-Holiday in Status_3 */-----------------------------------------------------------                              
  
                        If exists (Select 1 from #Emp_Holiday EH Where EH.Emp_Id = @Emp_Id_Cur And EH.For_Date = @Temp_Date and isnull(EH.is_Half,0) = 1 and EH.For_Date<=isnull(@Left_Date,EH.For_Date))  
                        Begin  
                            set @strQry =  'Update #Att_Muster  
                            set WO_COHO = ''HHO'', ' + @status_3 + ' = ''HHO''   
                            Where Emp_Id = ' + cast(@Emp_Id_Cur as varchar(10))  
                              
                            Exec (@StrQry)  
                        End  
                          
     -------------------------------------------------/* Here we are Updating ABSENT in NULL Records  */-----------------------------------------------------------                          
                          
     --               IF NOT EXISTS(SELECT 1 FROM #Emp_WeekOff WO WHERE WO.EMP_ID=@Emp_Id_Cur AND WO.FOR_DATE=@Temp_Date )                                  
     --                   BEGIN  
     --                       SET @A_DAYS = @A_DAYS + 1;        
     --                       SELECT  @A_DAYS = @A_DAYS - (ISNULL(LEAVE_USED,0) + ISNULL(CompOff_Used,0) + ISNULL(H_DAY,0) + CASE WHEN ISNULL(D.P_days,0) = 0.5 THEN 1 ELSE ISNULL(D.P_days,0) END )  
     --                       FROM    #Data D LEFT OUTER JOIN T0140_LEAVE_TRANSACTION T ON D.Emp_Id=T.Emp_ID AND D.For_date=T.For_Date                                              
     --                               LEFT OUTER JOIN #EMP_HOLIDAY HO  ON D.For_date=HO.FOR_DATE AND D.Emp_Id=HO.EMP_ID  
     --                       WHERE   D.Emp_ID=@Emp_Id_Cur AND D.For_Date=@Temp_Date   
     --                   END   
  
     -----' + @status_3 + ' = CASE WHEN '''+ CAST(isnull(@Left_Date,@DEFAULTDATE) AS VARCHAR(25))+''' = '''+cast(@DEFAULTDATE as varchar(25))+'''  THEN ''AB'' ELSE ''-'' END  
  
     -- Changed By Sajid 02-05-2023  
                    set @strQry =  'Update #Att_Muster  
                        set WO_COHO = ''AB'',   
      ' + @status_3 + ' = ''AB''  
      --CASE WHEN '''+ CAST(isnull(@Left_Date,@DEFAULTDATE) AS VARCHAR(25))+''' = '''+cast(@DEFAULTDATE as varchar(25))+'''  THEN  ''AB''  ELSE ''-'' END  
                        Where Emp_Id = ' + cast(@Emp_Id_Cur as varchar(10)) +  
                        ' And ' + @Status_1 + ' Is Null' + ' And ' + @Status_2 + ' Is Null' +  
                        ' And ' + @Status_3 + ' Is Null' + ' And (' + @Status_4 + ' = ''00:00'' or ' + @Status_4 + ' Is NULL)' +  
                        ' And ' + @status_5 + ' Is Null' + ' And ' + @Status_6 + ' Is Null'  
                                          
                    Exec (@strqry)  
  
     -------------- Add By Jignesh Patel 29-12-2021 Ref. Sandip Patel ---------------  
     ---set ' + @status_3 + ' = case When Day(''' + cast(@Temp_date as varchar(11))+ ''')  > Day(Getdate()) Then ''-'' Else ' + @status_3 + ' End   
      ---Where  Emp_Id = ' + cast(@Emp_Id_Cur as varchar(10))   
     set @strQry =  'Update #Att_Muster  
      set ' + @status_3 + ' = case When Day(''' + cast(@Temp_date as varchar(11))+ ''')  > Day( Getdate() ) Then ''-'' Else ' + @status_3 + ' End   
                        Where  Getdate() < cast(''' + cast(@Temp_date as varchar(11))+ ''' as datetime) And  Emp_Id = ' + cast(@Emp_Id_Cur as varchar(10))   
  
                    Exec (@strqry)      
     ------------- End -----------------  
       
     
-- added by Deepali -13062023    -- Working Code for single Employee  
----Added By Sajid & Deepali 16-03-2023  
IF  EXISTS(select 1 from T0100_EMP_RETAINTION_STATUS OA where OA.Emp_Id = @Emp_Id_Cur and  OA.is_retain_On = 0 )     
Begin   
  
    select @curRetDate = For_Date from #Att_Muster where @Emp_ID = @Emp_Id_Cur  
 Declare Curs_Retain cursor for                     
 select emp_id,CMP_Id, For_Date from #Att_Muster  where For_Date between @From_Date and @To_Date  and emp_Id =@Emp_Id_Cur  
 -- set @RET_DAYS= 0  
 Open Curs_Retain  
 Fetch next from Curs_Retain into @curemp_id,@curCM_ID, @curTempDate  
 While @@fetch_status = 0                      
   Begin     
     print @curRetDate  
     
      if  (( select 1 from T0100_EMP_RETAINTION_STATUS OA where   OA.Emp_Id = @curemp_id and OA.Cmp_Id= @curCM_ID and @curRetDate between OA.Start_Date and OA.End_Date and OA.is_retain_On =0 )= 1)  
      Begin   
       set @strQry =  'Update #Att_Muster  
                            set  ' + @status_3 + ' = ''RT''                             
       Where For_Date = ''' + cast(@curTempDate as varchar(11)) + ''' and Emp_Id = ' + cast(@curemp_id as varchar(10))+''  
       print @StrQry    
       Exec (@StrQry)  
          
        set @RET_DAYS= @RET_DAYS+1  
             
      End  
       
   fetch next from Curs_Retain into @curemp_id,@curCM_ID, @curTempDate  
    
     set @curRetDate= DATEADD(day,1,@curRetDate )  
    print @RET_DAYS  
      
   end  
 close Curs_Retain                      
 deallocate Curs_Retain  
 End  
  
      
--  -- added by Deepali -13062023  
  
  
     --Added By Jimit 30092019   
     SELECT @EMP_JOINING_DATE = DATE_OF_JOIN   
     FROM T0080_EMP_MASTER WITH (NOLOCK)  
     WHERE EMP_ID = @Emp_Id_Cur  
      
     --IF (@EMP_JOINING_DATE >= @FROM_DATE AND @EMP_JOINING_DATE <= @TO_DATE)  
     IF @Temp_date < @EMP_JOINING_DATE  
      BEGIN  
        
        
       SET @STRQRY = 'UPDATE AM   
           SET  ' + @status_3 + ' = ''-'',  
           WO_COHO = ''-''  
           FROM  #ATT_MUSTER AM             
           WHERE FOR_DATE < ''' + CAST(@EMP_JOINING_DATE AS VARCHAR(11)) + '''   
           AND AM.EMP_ID = ' + CAST(@EMP_ID_CUR AS VARCHAR(11))  
      
       EXECUTE(@STRQRY);  
      END    
     --Ended  
     --Select * From #ATT_MUSTER  
     --RETURN  
      
       
     -- Added By Sajid 02-05-2023  
     IF @Temp_date > @LEFT_DATE  
      BEGIN  
      --Select 123,@Temp_date  
       SET @STRQRY = 'UPDATE AM   
           SET  ' + @status_3 + ' = ''-'',  
           WO_COHO = ''-''  
           FROM  #ATT_MUSTER AM             
           WHERE FOR_DATE < ''' + CAST(@LEFT_DATE AS VARCHAR(11)) + '''   
          AND AM.EMP_ID = ' + CAST(@EMP_ID_CUR AS VARCHAR(11))      
         
       EXECUTE(@STRQRY);  
      END    
  
        
  
                    set @tmp_InTime = null  
                    set @tmp_OutTime = null                                                                       
                    set @Temp_Date = dateadd(d,1,@Temp_date)  
                      
                    set @count = @count + 1    
                End  
  
      
  
  
                If @Report_For = 'Format 3' OR @Report_For= 'EMP RECORD'  ----------- EMP RECORD Add By Jignesh Patel 29-12-2021  
                    BEGIN  
  
  
       
      IF @Comp_OD_As_Present = 1  
       SELECT @L_DAYS = IsNull(Leave_Used,0)  
       FROM #ATT_DAYS A    
         LEFT OUTER JOIN (SELECT SUM(IsNull(LT.Leave_Used,0) * CASE WHEN LM.Apply_Hourly = 1 THEN 0.125 ELSE 1 END)  AS Leave_Used,lt.Emp_ID  
              FROM T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)  
               INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LT.Leave_ID=LM.Leave_ID        
              WHERE (Leave_Type <> 'Company Purpose' AND Leave_Code <> 'COMP') and LT.Cmp_ID=@Cmp_ID  
               AND LT.FOR_DATE BETWEEN @FROM_DATE AND @TO_dATE and lm.Leave_Paid_Unpaid <> 'U' --Added by ronakk 10032023  
              GROUP BY Emp_ID)Q1 on A.Emp_ID = Q1.Emp_ID   
       WHERE A.Emp_ID=@Emp_Id_Cur  
      ELSE  
       SELECT  @L_DAYS = IsNull(SUM(Leave_Used),0) + IsNull(SUM(LT.CompOff_Used),0)  
       FROM    T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)  
         Inner join T0040_leave_master lm WITH (NOLOCK) on lt.leavE_ID = lm.leave_ID                                     
       WHERE   (LT.Leave_Used  > 0 or LT.CompOff_Used > 0) And lt.Emp_Id = @Emp_Id_Cur   
         and lt.for_date between @From_Date and @To_Date and lm.Leave_Paid_Unpaid <> 'U' --Added by ronakk 10032023  
                          
                          
                        UPDATE #ATT_DAYS SET  L_DAYS=@L_DAYS WHERE EMP_ID=@Emp_Id_Cur  
                         
        -------------- Modify Jignesh Patel 29-12-2021------ Ref. Sandip Patel  
        ---SET @Date_Diff = DATEDIFF(d, @From_Date, @To_Date) + 1  
          
        SET @Date_Diff = DATEDIFF(d, @From_Date, case when @To_Date<  Getdate() then @To_Date else GETDATE() end ) + 1  -- comment by sandip  
      --SS  
        
         
       --Added By Sajid 02-05-2023  
      IF @From_Date<@EMP_JOINING_DATE   
         SET @Date_Diff = DATEDIFF(d, @EMP_JOINING_DATE, case when @To_Date<  Getdate() then @To_Date else GETDATE() end ) + 1  
        
      -- Added By Sajid 02-05-2023  
      IF @To_Date>@LEFT_DATE  
         SET @Date_Diff = DATEDIFF(d, @From_Date, case when @LEFT_DATE<  Getdate() then @LEFT_DATE else GETDATE() end ) + 1  
  
      --IF @Comp_OD_As_Present = 1  
      -- UPDATE A   
      -- SET  A_DAYS = (@Date_Diff - ((P_DAYS + L_DAYS + HO_DAYS + WO_DAYS + HF_DAYS) - IsNull(OD_Compoff,0)) )  
      -- FROM #ATT_DAYS A    
      --   LEFT OUTER JOIN (SELECT SUM((IsNull(LT.CompOff_Used,0) + IsNull(LT.Leave_Used,0)) * CASE WHEN LM.Apply_Hourly = 1 THEN 0.125 ELSE 1 END)  AS OD_Compoff,lt.Emp_ID  
      --        FROM T0140_LEAVE_TRANSACTION LT   
      --         INNER JOIN T0040_LEAVE_MASTER LM ON LT.Leave_ID=LM.Leave_ID        
      --        WHERE (Leave_Type='Company Purpose' OR Leave_Code = 'COMP') and LT.Cmp_ID=@Cmp_ID  
      --         AND LT.FOR_DATE BETWEEN @FROM_DATE AND @TO_dATE  
      --        GROUP BY Emp_ID)Q1 on A.Emp_ID = Q1.Emp_ID   
      --ELSE  
        
      --added by Deepali -06142023 -start   
      --UPDATE #ATT_DAYS SET  A_DAYS=(@Date_Diff - (P_DAYS + L_DAYS + HO_DAYS + WO_DAYS + (HF_DAYS / 2))) WHERE EMP_ID=@Emp_Id_Cur  
        
      print @RET_DAYS  
      UPDATE #ATT_DAYS SET  A_DAYS=(@Date_Diff - (P_DAYS + L_DAYS + HO_DAYS + WO_DAYS + (HF_DAYS / 2) + @RET_DAYS)) , RET_Days= @RET_DAYS WHERE EMP_ID=@Emp_Id_Cur  
        
      --added by Deepali -06142023 -end  
                    END  
            set  @RET_DAYS =0  
   set @curRetDate = @From_Date  
   Fetch Next From Att_Cursor INTO @Emp_Id_Cur,@Left_Date  
      
  
        End  
    Close Att_Cursor  
    Deallocate Att_Cursor  
  
  
  
  
  
    --Added by Hardik 05/01/2016  
    Declare @OD_Compoff_As_Present tinyint   
      
    Set @OD_Compoff_As_Present = 0   
      
    Select @OD_Compoff_As_Present = Isnull(Setting_Value,0) From T0040_SETTING WITH (NOLOCK) Where Setting_Name = 'OD and CompOff Leave Consider As Present' And Cmp_ID = @Cmp_ID  
  
    Update #Att_Muster   
    Set Present_Days = Case When @OD_Compoff_As_Present = 0 Then P_days Else Qry.P_Days + Isnull(Qry1.OD_Compoff_Leave,0) End,Total_Overtime= Qry.OT_hours  
    From #Att_Muster A Inner JOIN (Select Emp_Id,Isnull(Sum(P_days),0) as P_Days, dbo.F_Return_Hours(Isnull(Sum(OT_Sec + Weekoff_OT_Sec + Holiday_OT_Sec),0)) as OT_hours   
                                From #Data d  Group by Emp_Id) Qry  on A.Emp_Id = Qry.Emp_Id                              
        Left Outer JOIN (Select Am.Emp_Id, isnull(Sum(Leave_Used),0) + isnull(Sum(CompOff_Used),0) As OD_Compoff_Leave  from #Att_Muster AM inner join   
                            T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) ON AM.EMP_ID = LT.EMP_ID Inner join  
                            T0040_leave_master lm WITH (NOLOCK) on lt.leavE_ID = lm.leave_ID  
                            where (LT.Leave_Used  > 0 or LT.CompOff_Used > 0) And LT.For_date between @From_Date And @To_Date  
                            And (Leave_Type = 'Company Purpose' or Default_Short_Name='COMP')  
                            Group by AM.Emp_Id) Qry1 on A.Emp_Id = Qry1.Emp_Id  
   
   
 -------------------- Add by Jignesh Patel 29-12-2021 for  PAYABLE_DAYS ---------------  
 UPDATE  T       
 SET  PAYABLE_DAYS = (      
       --ISNULL(CAST((CASE WHEN PAYABLE_PRESENT_DAYS = '0' THEN '0.0' ELSE ISNULL(PAYABLE_PRESENT_DAYS,0) END) AS NUMERIC(18,2)),0) +  --- Commented by Hardik 04/07/2019 for Teksun as Total days goes above the Month days, added below line for Present add
  
       ----ISNULL(CAST((CASE WHEN P_DAYS = '' THEN '0.0' ELSE ISNULL(P_DAYS,0) END) AS NUMERIC(18,2)),0) +       
       ----CASE WHEN Inc_Holiday=0 THEN '0.0' ELSE ISNULL(CAST((CASE WHEN HO_DAYS = '' THEN '0.0' ELSE ISNULL(HO_DAYS,0) END) AS NUMERIC(18,2)),0) END +       
       ----CASE WHEN Inc_Weekoff=0 THEN '0.0' ELSE ISNULL(CAST((CASE WHEN WO_DAYS = '' THEN '0.0' ELSE ISNULL(WO_DAYS,0) END) AS NUMERIC(18,2)),0) END +        
       ----ISNULL(CAST((CASE WHEN L_DAYS = '' THEN '0.0' ELSE ISNULL(L_DAYS,0) END) AS NUMERIC(18,2)),0)  
    ISNULL(CAST((CASE WHEN isnull(P_DAYS,0) = 0 THEN 0 ELSE ISNULL(P_DAYS,0) END) AS NUMERIC(18,2)),0) +     
       CASE WHEN Inc_Holiday=0 THEN 0 ELSE ISNULL(CAST((CASE WHEN isnull(HO_DAYS,0) = 0 THEN 0 ELSE ISNULL(HO_DAYS,0) END) AS NUMERIC(18,2)),0) END +       
       CASE WHEN Inc_Weekoff=0 THEN 0 ELSE ISNULL(CAST((CASE WHEN isnull(WO_DAYS,0) = 0 THEN 0 ELSE ISNULL(WO_DAYS,0) END) AS NUMERIC(18,2)),0) END +       
       ISNULL(CAST((CASE WHEN isnull(L_DAYS,0) = 0 THEN 0 ELSE ISNULL(L_DAYS,0) END) AS NUMERIC(18,2)),0)  
      )     
        
 FROM #ATT_DAYS T       
   INNER JOIN T0080_EMP_MASTER EM ON T.EMP_ID=EM.EMP_ID  --COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS AND CMP_ID = @CMP_ID      
   INNER JOIN #EMP_CONS EC ON T.EMP_ID=EC.EMP_ID      
   INNER JOIN #GENERAL_SETTING GS ON GS.Branch_ID=EC.Branch_ID      
        
 UPDATE  #ATT_DAYS   SET  PAYABLE_DAYS = 0  WHERE PAYABLE_DAYS < 0    
 ----------------------------- End ------------------------------  
  
       
    if @Report_For = 'Format 3'  
        BEGIN  
            Select AM.*  
                ,ATT.P_DAYS,ATT.A_DAYS,ATT.HF_DAYS,ATT.L_DAYS,ATT.WO_DAYS,ATT.HO_DAYS  
                ,E.Emp_code,E.Emp_full_Name ,Branch_Address,Comp_Name  
                , Branch_Name , Dept_Name ,Grd_Name , Desig_Name  
                ,Cmp_Name,Cmp_Address  
                ,@From_Date as P_From_date ,@To_Date as P_To_Date , E.Alpha_Emp_Code + '-' + E.Emp_Full_Name as 'Emp_Code_Name' --Emp_Code_name added by Mihir 07112011  
                , E.Alpha_Emp_Code , E.Emp_First_Name,BM.BRANCH_ID,TM.type_name,E.Enroll_No  
                ,DGM.Desig_Dis_No  
                ,VS.Vertical_Name,SV.SubVertical_Name,SB.SubBranch_Name   --added by jimit 09022017  
            From #Att_Muster  AM   
                LEFT OUTER JOIN #ATT_DAYS ATT ON AM.Emp_Id=ATT.EMP_ID  
                INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON AM.EMP_ID = E.EMP_ID AND AM.CMp_ID=E.CMp_ID  
                INNER JOIN (   
                            SELECT  I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Emp_ID,i.type_id,I.Cmp_ID,Vertical_ID,SubVertical_ID,I.subBranch_ID  
                            FROM    T0095_Increment I WITH (NOLOCK)  
                            WHERE   I.Increment_ID=(  
                                                        SELECT  TOP 1 INCREMENT_ID  
                                                        FROM    T0095_INCREMENT I2 WITH (NOLOCK)  
                                                        WHERE   I.Cmp_ID=I2.Cmp_ID AND I.Emp_ID=I2.Emp_ID  
                                                                AND I2.Increment_Effective_Date <= @To_Date  
                                                        ORDER BY I2.Increment_Effective_Date DESC, I2.Increment_ID DESC  
                                                    )                                         
                            )Q_I ON E.EMP_ID = Q_I.EMP_ID AND E.Cmp_ID=Q_I.Cmp_ID   
                INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON Q_I.Grd_Id = gm.Grd_ID  AND Q_I.Cmp_ID=GM.Cmp_ID   
                INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Q_I.BRANCH_ID = BM.BRANCH_ID AND Q_I.Cmp_ID=BM.Cmp_ID   
                LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON Q_I.DEPT_ID = DM.DEPT_ID AND Q_I.Cmp_ID=DM.Cmp_Id   
                LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON Q_I.DESIG_ID = DGM.DESIG_ID AND Q_I.Cmp_ID=DGM.Cmp_Id   
           Inner join T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.CMP_ID = CM.CMP_id   
                left outer join t0040_type_master TM WITH (NOLOCK) ON Q_I.type_id = Tm.type_id  AND Q_I.Cmp_ID=Tm.Cmp_Id  
                LEFT OUTER JOIN T0040_VERTICAL_SEGMENT VS WITH (NOLOCK) ON VS.VERTICAL_ID = Q_I.VERTICAL_ID  
                LEFT OUTER JOIN T0050_SUBVERTICAL SV WITH (NOLOCK) ON SV.SUBVERTICAL_ID = Q_I.SUBVERTICAL_ID  
                LEFT OUTER JOIN T0050_SUBBRANCH SB WITH (NOLOCK) ON SB.SUBBRANCH_ID = Q_I.SUBBRANCH_ID  
            WHERE AM.Cmp_ID=@Cmp_ID  
            --Order by Emp_Code,Am.For_Date  
            --ORDER BY RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500) --, Am.For_Date  
            ORDER BY Case When IsNumeric(Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + Alpha_Emp_Code, 20)  
                        When IsNumeric(Alpha_Emp_Code) = 0 then Left(Alpha_Emp_Code + Replicate('',21), 20)  
                        Else Alpha_Emp_Code  
                     End  
        END  
    ELSE  
        BEGIN         
            Select AM.* , E.Emp_code,E.Emp_full_Name ,Branch_Address,Comp_Name  
                , Branch_Name , Dept_Name ,Grd_Name , Desig_Name  
                ,Cmp_Name,Cmp_Address  
                ,@From_Date as P_From_date ,@To_Date as P_To_Date , E.Alpha_Emp_Code + '-' + E.Emp_Full_Name as 'Emp_Code_Name' --Emp_Code_name added by Mihir 07112011  
                , E.Alpha_Emp_Code , E.Emp_First_Name,BM.BRANCH_ID,TM.type_name,E.Enroll_No  
                ,DGM.Desig_Dis_No  
                ,VS.Vertical_Name,SV.SubVertical_Name,SB.SubBranch_Name   --added by jimit 09022017  
       
     ,ATT.P_DAYS,ATT.A_DAYS,ATT.HF_DAYS,ATT.L_DAYS,ATT.WO_DAYS,ATT.HO_DAYS,ATT.PAYABLE_DAYS,ATT.RET_DAYS as RT_Days    -------------- Add By Deepali-15062023  
       
            From #Att_Muster  AM   
                INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON AM.EMP_ID = E.EMP_ID AND AM.CMp_ID=E.CMp_ID  
                INNER JOIN (   
                            SELECT  I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Emp_ID,i.type_id,I.Cmp_ID,Vertical_ID,SubVertical_ID,I.subBranch_ID  
                            FROM    T0095_Increment I WITH (NOLOCK)  
                            WHERE   I.Increment_ID=(  
                                                        SELECT  TOP 1 INCREMENT_ID  
                                                        FROM    T0095_INCREMENT I2 WITH (NOLOCK)  
                                                        WHERE   I.Cmp_ID=I2.Cmp_ID AND I.Emp_ID=I2.Emp_ID  
                                                                AND I2.Increment_Effective_Date <= @To_Date  
                                                        ORDER BY I2.Increment_Effective_Date DESC, I2.Increment_ID DESC  
                                                    )                                         
                            )Q_I ON E.EMP_ID = Q_I.EMP_ID AND E.Cmp_ID=Q_I.Cmp_ID   
                INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON Q_I.Grd_Id = gm.Grd_ID  AND Q_I.Cmp_ID=GM.Cmp_ID   
                INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Q_I.BRANCH_ID = BM.BRANCH_ID AND Q_I.Cmp_ID=BM.Cmp_ID   
                LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON Q_I.DEPT_ID = DM.DEPT_ID AND Q_I.Cmp_ID=DM.Cmp_Id   
                LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON Q_I.DESIG_ID = DGM.DESIG_ID AND Q_I.Cmp_ID=DGM.Cmp_Id   
                Inner join T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.CMP_ID = CM.CMP_id   
                left outer join t0040_type_master TM WITH (NOLOCK) on Q_I.type_id = Tm.type_id  AND Q_I.Cmp_ID=Tm.Cmp_Id  
                LEFT OUTER JOIN T0040_VERTICAL_SEGMENT VS WITH (NOLOCK) ON VS.VERTICAL_ID = Q_I.VERTICAL_ID  
                LEFT OUTER JOIN T0050_SUBVERTICAL SV WITH (NOLOCK) ON SV.SUBVERTICAL_ID = Q_I.SUBVERTICAL_ID  
                LEFT OUTER JOIN T0050_SUBBRANCH SB WITH (NOLOCK) ON SB.SUBBRANCH_ID = Q_I.SUBBRANCH_ID  
  
    LEFT OUTER JOIN #ATT_DAYS ATT ON AM.Emp_Id=ATT.EMP_ID   -------------- Add By Jignesh Patel 29-12-2021  
  
            WHERE AM.Cmp_ID=@Cmp_ID  
            --Order by Emp_Code,Am.For_Date  
            --ORDER BY RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500) --, Am.For_Date  
            ORDER BY Case When IsNumeric(Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + Alpha_Emp_Code, 20)  
                        When IsNumeric(Alpha_Emp_Code) = 0 then Left(Alpha_Emp_Code + Replicate('',21), 20)  
                        Else Alpha_Emp_Code  
						End  
        END  
    RETURN  
  
  
  
  