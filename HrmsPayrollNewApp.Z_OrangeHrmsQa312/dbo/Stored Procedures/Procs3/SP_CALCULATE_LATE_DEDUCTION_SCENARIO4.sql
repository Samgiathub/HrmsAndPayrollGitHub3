    
    
    
-- Create By : Nilesh Patel    
-- Create Date : 15-04-2019     
-- Description : For Late Deduction Scenario-4    
CREATE PROCEDURE [dbo].[SP_CALCULATE_LATE_DEDUCTION_SCENARIO4]    
     @emp_Id                NUMERIC    
    ,@Cmp_ID                NUMERIC    
    ,@Month_St_Date         DATETIME    
    ,@Month_End_Date        DATETIME    
    ,@Late_Sal_Dedu_Days    NUMERIC(18,1) OUTPUT    
    ,@Increment_ID          NUMERIC     
    ,@StrWeekoff_Date       VARCHAR(max)= ''     
    ,@StrHoliday_Date       VARCHAR(max)= ''     
    ,@Return_Record_Set     NUMERIC =0    
    ,@var_Return_Late_Date  VARCHAR(max) = '' OUTPUT    
    ,@Return_Late_Date_Table TINYINT = 0    
    ,@Absent_Date_String    VARCHAR(max) = ''     
AS    
    SET NOCOUNT ON     
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED    
 SET ARITHABORT ON    
        
 DECLARE @Emp_Late_Mark INT    
 DECLARE @Emp_Late_Limit VARCHAR(10)    
 DECLARE @Branch_ID NUMERIC    
 DECLARE @Late_With_leave    NUMERIC(1,0)    
 DECLARE @Is_Late_calc_On_HO_WO NUMERIC(1,0)    
 DECLARE @Late_Limit_Sec NUMERIC(18,0)    
 DECLARE @Late_Mark_Scenario Tinyint    
 DECLARE @GEN_ID Numeric    
    
    Select TOP 1 @Increment_ID = Increment_ID     
   From T0095_INCREMENT WITH (NOLOCK) Where Increment_Effective_Date <= @Month_End_Date and Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID    
    order BY Increment_Effective_Date DESC    
    
    
    SELECT  @Emp_Late_Mark = isnull(Emp_Late_Mark,0),    
   @Emp_Late_Limit = ISNULL(Emp_Late_Limit,'00:00'),    
   @Branch_ID =Branch_ID    
    FROM    T0095_Increment I WITH (NOLOCK)    
    WHERE   I.Emp_ID = @emp_ID and Increment_Id =@Increment_ID      
     
     
 Declare @Late_Deduction Numeric(3,2)    
 Set @Late_Deduction = 0    
    
    CREATE TABLE #Absent_Dates      
    (    
        Absent_date DATETIME    
    )    
        
    IF @Absent_Date_String <> ''    
        BEGIN    
            INSERT INTO #Absent_Dates(Absent_date)    
            SELECT data FROM dbo.Split(@Absent_Date_String,'#')    
        END    
        
 Declare @Late_Limit Varchar(10)    
    
    SELECT  @Late_With_leave = Isnull(Late_with_Leave,0),    
            @Late_Limit = ISNULL(Late_Limit,'00:00'),    
   @Is_Late_calc_On_HO_WO = Isnull(Is_Late_Calc_On_HO_WO,0),    
   @Late_Mark_Scenario = Isnull(Late_Mark_Scenario,0),    
   @GEN_ID = Gen_ID    
    FROM    T0040_GENERAL_SETTING G WITH (NOLOCK)     
            INNER JOIN (    
                            SELECT  MAX(For_Date) AS For_Date     
                            FROM    T0040_GENERAL_SETTING WITH (NOLOCK)        
                            WHERE   cmp_id = @cmp_id AND For_Date <=@Month_End_Date AND Branch_ID=@Branch_ID    
                        )  G1 ON G.For_Date=G1.For_Date    
    WHERE   Cmp_ID = @Cmp_ID and Branch_ID =@Branch_ID     
    
 if @Emp_Late_Limit = '00:00'    
  Set @Emp_Late_Limit = @Late_Limit    
                
    Set @Late_Limit_Sec  = dbo.F_Return_Sec(@Emp_Late_Limit)    
    
 IF Object_ID('Tempdb..#EMP_LATE_DATA') Is not null    
  DROP TABLE #EMP_LATE_DATA    
    
    CREATE TABLE #EMP_LATE_DATA    
    (    
        EMP_ID   NUMERIC,    
        FOR_DATE  DATETIME,    
  IN_TIME   DATETIME,    
  SHIFT_ID  NUMERIC,    
  SHIFT_ST_TIME   DATETIME,    
  SHIFT_END_TIME  DATETIME,    
  ACTUAL_SHIFT_TIME DATETIME,    
  LATE_SEC  NUMERIC,    
  GROUP_ID  TINYINT,    
  DEDUCTION  NUMERIC(6,2),    
  MAIN_GROUP  TINYINT    
    )     
     
  If OBJECT_ID('tempdb..#EMP_CONS') is null    
  Begin    
   CREATE TABLE #EMP_CONS    
    (    
    EMP_ID NUMERIC,    
    BRANCH_ID NUMERIC,    
    INCREMENT_ID NUMERIC    
    )    
    INSERT INTO #EMP_CONS VALUES (@emp_Id, @Branch_ID, @Increment_ID)    
  End    
     
     
 IF Object_ID('tempdb..#data') IS NUll    
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
               Shift_End_Time datetime,         --Ankit 16112013    
               OT_End_Time numeric default 0,   --Ankit 16112013    
               Working_Hrs_St_Time tinyint default 0, --Hardik 14/02/2014    
               Working_Hrs_End_Time tinyint default 0, --Hardik 14/02/2014    
               GatePass_Deduct_Days numeric(18,2) default 0 -- Add by Gadriwala Muslim 05012014    
           )        
    
           EXEC P_GET_EMP_INOUT @Cmp_ID, @Month_St_Date, @Month_End_Date    
        END    
     
     
 IF Object_ID('Tempdb..#EMP_LATE_SLAB') Is not null    
  DROP TABLE #EMP_LATE_SLAB    
   print @GEN_ID ---mansi    
 Create Table #EMP_LATE_SLAB    
 (    
  Emp_ID Numeric,    
  From_Min Numeric,    
  To_Min Numeric,    
  From_Count Numeric,    
  To_Count Numeric,    
  Is_Group tinyint,    
  Deduction Numeric(6,2),    
  For_Date Datetime,    
  Main_Group tinyint    
 )      
     
 INSERT INTO #EMP_LATE_SLAB    
 Select EC.EMP_ID,LS.From_Min,LS.To_Min,LS.From_Count,LS.To_Count,ROW_NUMBER() Over(Partition By From_Min Order By Emp_ID),LS.Deduction,NULL,NULL    
  From #Emp_Cons EC    
 CROSS APPLY  T0050_GENERAL_LATEMARK_SLAB_SCENARIO4 LS WITH (NOLOCK)    
 WHERE LS.Gen_ID = @GEN_ID    
    
     
 Update ELS     
  SET  Main_Group = Q.Main_Group    
 From #EMP_LATE_SLAB ELS    
 Inner Join(    
    Select Count(1) as W_Count,From_Min,To_Min,ROW_NUMBER() Over(order by From_Min,To_Min) as Main_Group    
     From #EMP_LATE_SLAB     
    Group By From_Min,To_Min    
     ) as Q ON ELS.From_Min = Q.From_Min AND ELS.To_Min = Q.To_Min    
    
 If Object_ID('tempdb..#Late_Slab_Group') Is not null    
  Begin    
   Drop Table #Late_Slab_Group    
  End    
    
 Create Table #Late_Slab_Group    
 (    
  From_Min Numeric,    
  To_Min Numeric,    
  Main_Group Numeric    
 )    
    
 Insert into #Late_Slab_Group    
 Select From_Min,To_Min,ROW_NUMBER() Over(order by From_Min,To_Min) as Main_Group    
  From #EMP_LATE_SLAB     
 Group By From_Min,To_Min    
    
    IF  @Emp_Late_Mark = 1 AND @Late_Mark_Scenario = 4    
        BEGIN     
       
   INSERT INTO #EMP_LATE_DATA    
   SELECT  D.EMP_ID,D.For_date,IN_TIME,D.Shift_ID,Shift_Start_Time,Shift_End_Time,dateadd(s,0,Shift_Start_Time),0,0,0,0    
            FROM    #DATA D     
                    LEFT OUTER JOIN #ABSENT_DATES AD ON D.FOR_DATE = AD.ABSENT_DATE    
            WHERE   NOT EXISTS(SELECT 1 FROM T0150_EMP_INOUT_RECORD EIO WITH (NOLOCK)    
                                WHERE   EIO.EMP_ID=D.EMP_ID AND ISNULL(IS_CANCEL_LATE_IN,0) <> 0 AND IN_TIME=D.IN_TIME)    
                    AND ABSENT_DATE IS NULL AND D.EMP_ID = ISNULL(@EMP_ID , D.EMP_ID) AND (P_days <> 0 OR Weekoff_OT_Sec > 0 OR Holiday_OT_Sec > 0)    
                    AND D.FOR_DATE BETWEEN @MONTH_ST_DATE AND @MONTH_END_DATE    
    
       
   IF @Is_Late_calc_On_HO_WO = 0    
    Begin    
     Update ELD     
      SET ELD.IN_TIME = ELD.SHIFT_ST_TIME     
     From #EMP_LATE_DATA ELD    
     Inner Join(    
        Select cast(data as datetime) as For_Date     
         From dbo.Split(@StrWeekoff_Date,';') where Data <> ''    
         ) as t    
     ON ELD.FOR_DATE = t.For_Date    
    
     Update ELD     
      SET ELD.IN_TIME = ELD.SHIFT_ST_TIME     
     From #EMP_LATE_DATA ELD    
     Inner Join(    
        Select cast(data as datetime) as For_Date     
         From dbo.Split(@StrHoliday_Date,';') where Data <> ''    
         ) as t    
     ON ELD.FOR_DATE = t.For_Date    
    End    
       
   Update E    
    SET LATE_SEC = CASE WHEN E.IN_TIME > E.ACTUAL_SHIFT_TIME THEN DATEDIFF(S,E.ACTUAL_SHIFT_TIME,E.IN_TIME) ELSE 0 END,    
     MAIN_GROUP = LSG.Main_Group    
   FROM #EMP_LATE_DATA E INNER JOIN #Late_Slab_Group LSG     
   ON DATEDIFF(S,E.ACTUAL_SHIFT_TIME,E.IN_TIME)/60 BETWEEN LSG.From_Min AND LSG.To_Min    
    
    
   UPDATE ELD    
    SET ELD.LATE_SEC = 0     
            FROM    dbo.T0150_Emp_Inout_Record EIO INNER JOIN #EMP_LATE_DATA ELD    
     ON EIO.For_Date = ELD.FOR_DATE AND EIO.Emp_ID = ELD.EMP_ID    
            WHERE   ISNULL(EIO.Late_Calc_Not_App,0)=0 AND EIO.Chk_By_Superior <> 0    
    
   DELETE FROM #EMP_LATE_DATA WHERE LATE_SEC = 0    
    
   UPDATE T     
    SET T.GROUP_ID = EL.Is_Group,    
        T.DEDUCTION = EL.Deduction    
   From      
   (SELECT ROW_NUMBER() Over(Partition by MAIN_GROUP Order By Emp_ID,For_Date) AS Row_ID,Emp_ID,GROUP_ID,DEDUCTION,(LATE_SEC/60) as LATE_SEC    
    FROM #EMP_LATE_DATA    
   WHERE LATE_SEC > 0) T     
   INNER JOIN #EMP_LATE_SLAB EL ON T.EMP_ID = EL.Emp_ID     
   AND Row_ID BETWEEN From_Count AND To_Count AND LATE_SEC BETWEEN From_Min AND To_Min    
    
    
   Update T1     
    Set T1.Deduction = 0    
   From #EMP_LATE_DATA T1     
   Right Outer join (Select Max(T2.GROUP_ID) as Grp,Emp_ID,Main_Group From #EMP_LATE_DATA T2 Group By Emp_ID,Main_Group) as Qry     
   ON T1.Emp_ID = Qry.Emp_ID and T1.GROUP_ID < Qry.Grp and T1.Main_Group = Qry.Main_Group    
    
       
    
   IF OBJECT_ID('tempdb..#Emp_Late_Scenario4') Is not null    
    Begin    
    
     Insert into #Emp_Late_Scenario4    
     Select @Cmp_ID,t.EMP_ID,EL.From_Min,EL.To_Min,EL.From_Count,EL.To_Count,t.DEDUCTION,t.FOR_DATE    
     From     
     (    
      SELECT EMP_ID,GROUP_ID,MAIN_GROUP,FOR_DATE =     
       STUFF((SELECT ', ' + CONVERT(VARCHAR(11),A.FOR_DATE,105)    
           FROM #EMP_LATE_DATA A     
           WHERE B.GROUP_ID = A.GROUP_ID AND B.MAIN_GROUP = A.MAIN_GROUP    
          FOR XML PATH('')), 1, 2, ''),DEDUCTION    
      FROM #EMP_LATE_DATA B    
      WHERE GROUP_ID <> 0    
      GROUP BY GROUP_ID,EMP_ID,DEDUCTION,MAIN_GROUP    
      --ORDER BY MAIN_GROUP,GROUP_ID    
     ) t Inner join #EMP_LATE_SLAB EL    
     ON EL.Emp_ID = t.EMP_ID and El.Is_Group = t.GROUP_ID AND EL.Main_Group = t.MAIN_GROUP    
     ORDER BY EL.MAIN_GROUP,EL.Is_Group    
    
     return    
    End    
    
    Select @Late_Sal_Dedu_Days = SUM(DEDUCTION)     
    From     
    (     
     Select GROUP_ID,EMP_ID,DEDUCTION,MAIN_GROUP From #EMP_LATE_DATA    
      Where DEDUCTION <> 0    
     Group By GROUP_ID,EMP_ID,DEDUCTION,MAIN_GROUP    
    ) as t    
        END 