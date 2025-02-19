


CREATE PROCEDURE [dbo].[SP_GET_HW_ALL_test_Yogesh]  
 @Constraint   varchar(max)  
 ,@Cmp_ID    numeric  
 ,@From_Date   Datetime  
 ,@To_Date    Datetime  
 ,@All_Weekoff   BIT =0
 ,@Is_FNF   tinyint =0  
 ,@Is_Leave_Cal  tinyint = 0  
 ,@Allowed_Full_WeekOff_MidJoining tinyint = 0  
 ,@Type    numeric = 0  
 ,@Use_Table   tinyint = 0  
 ,@Exec_Mode   tinyint = 0  
 ,@Delete_Cancel_HW bit = 1  
AS  
 SET NOCOUNT ON;  
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;  
 SET ARITHABORT ON;  
   
 DECLARE @WEEKOFF TINYINT;  
 DECLARE @HOLIDAY TINYINT;  
   
 SET  @WEEKOFF = 1  
 SET  @HOLIDAY = 2  
    


 IF OBJECT_ID('tempdb..#EMP_CONS') IS NULL  
 BEGIN  
  CREATE TABLE #EMP_CONS(EMP_ID NUMERIC, BRANCH_ID NUMERIC, INCREMENT_ID NUMERIC);  
    
  EXEC dbo.SP_RPT_FILL_EMP_CONS @Cmp_ID=@Cmp_ID, @From_Date=@From_Date, @To_Date=@To_Date, @Branch_ID=0,@Cat_ID=0, @Grd_ID=0, @Type_ID=0, @Dept_ID=0, @Desig_ID=0,@Emp_ID=0,@Constraint=@Constraint   
    
 END  
   

   

 IF OBJECT_ID('tempdb..#Emp_WeekOff') IS NULL  
  BEGIN  
   CREATE TABLE #Emp_WeekOff  
   (  
    Row_ID   NUMERIC,  
    Emp_ID   NUMERIC,  
	--Cmp_ID   NUMERIC,  
    For_Date  DATETIME,  
    Weekoff_day  VARCHAR(10),  
    W_Day   numeric(4,1),  
    Is_Cancel  BIT  
   )  
   CREATE CLUSTERED INDEX IX_Emp_WeekOff_EmpID_ForDate ON #Emp_WeekOff(Emp_ID, For_Date)    
  END  
   
     
 IF OBJECT_ID('tempdb..#Emp_WeekOff_Holiday') IS NULL  
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
  CREATE UNIQUE CLUSTERED INDEX IX_Emp_WeekOff_Holiday_EMPID ON #Emp_WeekOff_Holiday(Emp_ID);  
 END  
  
 IF OBJECT_ID('tempdb..#EMP_HW_CONS') IS NULL  
 BEGIN   
  CREATE TABLE #EMP_HW_CONS  
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
  CREATE UNIQUE CLUSTERED INDEX IX_EMP_HW_CONS_EmpID ON #EMP_HW_CONS(Emp_ID)  
 END  
   
 IF OBJECT_ID('tempdb..#EMP_HOLIDAY') IS NULL  
  BEGIN  
   CREATE TABLE #EMP_HOLIDAY(EMP_ID NUMERIC, FOR_DATE DATETIME, IS_CANCEL BIT, Is_Half tinyint, Is_P_Comp tinyint, H_DAY numeric(4,1));  
   CREATE UNIQUE CLUSTERED INDEX IX_EMP_HOLIDAY_EMPID_FORDATE ON #EMP_HOLIDAY(EMP_ID, FOR_DATE);  
  END  
 IF OBJECT_ID('tempdb..#HW_DETAIL') IS NULL  
  BEGIN  
   CREATE TABLE #HW_DETAIL(EMP_ID NUMERIC, FOR_DATE DATETIME, Is_UnPaid TinyInt);  
   CREATE CLUSTERED INDEX IX_HW_DETAIL_EMPID_FORDATE ON #HW_DETAIL(EMP_ID, FOR_DATE);  

  END    
 IF OBJECT_ID('tempdb..#data') IS NOT NULL  
  BEGIN  
   SELECT * INTO #DATA_BACK FROM #DATA  
   TRUNCATE TABLE #DATA  
  END  
   
   
  
 IF OBJECT_ID('tempdb..#DATA') IS NULL  
  CREATE TABLE #DATA  
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
    --,Working_sec_Between_Shift numeric(18) default 0 -- Commented by Niraj(20062022)
  )      
   
  
 DECLARE @T_FROM_DATE DATETIME  
 DECLARE @T_TO_DATE DATETIME  
 SET @T_FROM_DATE = DATEADD(D, -7, @From_Date)  
 SET @T_TO_DATE = DATEADD(D, 7, @To_Date)  
     
 --- Modify By jignesh 30-11-2019----  
 ---EXEC dbo.P_GET_EMP_INOUT @Cmp_ID=@Cmp_ID, @From_Date=@T_FROM_DATE, @To_Date=@T_TO_DATE, @First_In_Last_OUT_Flag = 1  
 DECLARE @First_In_Last_Out_For_InOut_Calculation TINYINT   
 SELECT TOP 1 @First_In_Last_Out_For_InOut_Calculation  = First_In_Last_Out_For_InOut_Calculation  
   FROM #EMP_CONS EC   
     INNER JOIN T0040_GENERAL_SETTING GS WITH (NOLOCK) ON EC.BRANCH_ID=GS.BRANCH_ID  
     INNER JOIN (SELECT GS1.BRANCH_ID, MAX(FOR_DATE) AS FOR_DATE  
        FROM T0040_GENERAL_SETTING GS1  WITH (NOLOCK)   
        WHERE GS1.FOR_DATE < @TO_DATE  
        GROUP BY GS1.BRANCH_ID) GS1 ON GS.BRANCH_ID=GS1.BRANCH_ID AND GS.FOR_DATE=GS1.FOR_DATE  
          
		
 EXEC dbo.P_GET_EMP_INOUT @Cmp_ID=@Cmp_ID, @From_Date=@T_FROM_DATE, @To_Date=@T_TO_DATE, @First_In_Last_OUT_Flag = @First_In_Last_Out_For_InOut_Calculation  
 

 SELECT Distinct Emp_Id,For_date,In_Time,Out_Time,Shift_ID,Shift_Start_Time,Shift_End_Time,Chk_By_Superior,Duration_in_sec,P_days  
 INTO #DATA_WOHO   
 FROM #DATA  

 
 --TRUNCATE TABLE #DATA  
   
 ----- Modify jignesh 30-11-2019----  
 ----CREATE UNIQUE NONCLUSTERED INDEX IX_DATA_WOHO ON #DATA_WOHO (EMP_ID,FOR_DATE)  
 
 IF @First_In_Last_Out_For_InOut_Calculation =1  
 BEGIN   
  CREATE NONCLUSTERED INDEX IX_DATA_WOHO ON #DATA_WOHO (EMP_ID,FOR_DATE)  
 END  
  
 --SELECT In_Time, OUT_Time, Shift_Start_Time,Shift_End_Time, * FROM #DATA_WOHO  
 IF OBJECT_ID('tempdb..#DATA_BACK') IS NOT NULL  
  BEGIN  
   /*Following IF Condition is used to   
   */  
   IF EXISTS(SELECT 1 FROM #DATA_BACK)   
    BEGIN  
	
     TRUNCATE TABLE #DATA  
     INSERT INTO #DATA  
     SELECT * FROM #DATA_BACK  
    END   
      

   DROP TABLE #DATA_BACK  
  END   
  
    
 -- Added Isnull condition for D.Duration_In_Sec column by Hardik 08/10/2020 for BGD Client as they are using single punch present  
 UPDATE D  
 SET  P_days = (SELECT Top 1 Calculate_Days   
      FROM  T0050_SHIFT_DETAIL SD  WITH (NOLOCK)   
      Where  D.Shift_ID=SD.Shift_ID AND Isnull(D.Duration_in_sec,0) BETWEEN dbo.F_Return_Sec(REPLACE(From_Hour, '.', ':')) AND dbo.F_Return_Sec(REPLACE(To_Hour, '.',':')))  
 FROM #DATA_WOHO D  
  
 UPDATE D  
 SET  P_days = Case When Half_Full_day = 'Full Day' Then 1 Else 0.5 End  
 FROM #DATA_WOHO D INNER JOIN  
   T0150_EMP_INOUT_RECORD E  WITH (NOLOCK) ON D.Emp_Id = E.Emp_ID And D.For_date = E.For_Date   
 WHERE Isnull(E.Chk_By_Superior,0) = 1  
   
   


 UPDATE D  
 SET  P_days = IsNull(P_days,0) + LT.Leave_used  
 FROM #DATA_WOHO D   
   INNER JOIN (SELECT LT.EMP_ID, LT.FOR_DATE, SUM(Leave_used) As Leave_used  
      FROM T0140_LEAVE_TRANSACTION LT  WITH (NOLOCK)   
        INNER JOIN T0040_LEAVE_MASTER LM  WITH (NOLOCK) ON LT.Leave_ID=LM.Leave_ID  
        INNER JOIN #DATA D ON LT.Emp_ID=D.Emp_Id AND LT.For_Date=D.For_date  
      WHERE LM.Leave_Type = 'Company Purpose'  
      GROUP BY LT.EMP_ID, LT.FOR_DATE) LT ON D.Emp_Id = LT.Emp_ID And D.For_date = LT.For_Date   
   
   



 
 INSERT INTO #DATA_WOHO (EMP_ID, FOR_DATE, P_days)  
 SELECT LT.Emp_ID, LT.For_Date, LT.Leave_used  
 FROM (SELECT LT.EMP_ID, LT.FOR_DATE, SUM(Leave_used) As Leave_used  
   FROM T0140_LEAVE_TRANSACTION LT  WITH (NOLOCK)   
     INNER JOIN T0040_LEAVE_MASTER LM  WITH (NOLOCK) ON LT.Leave_ID=LM.Leave_ID       
   WHERE LM.Leave_Type = 'Company Purpose'  
     AND LT.FOR_DATE BETWEEN @FROM_DATE AND @TO_DATE       AND NOT EXISTS(SELECT 1 FROM #DATA D WHERE LT.Emp_id=D.Emp_ID AND LT.For_Date=D.For_Date)  
   GROUP BY LT.EMP_ID, LT.FOR_DATE) LT  
 

 

 if exists (SELECT 1 from #EMP_HOLIDAY) --Added by Jaina 13-11-2017  
  DELETE FROM #EMP_HOLIDAY  

 --SELECT * FROM #DATA_WOHO 
 
 
 
 IF @Exec_Mode <> @WEEKOFF --IF NOT ONLY WEEKOFF  
 Begin
 
  EXEC SP_EMP_HOLIDAY_DATE_GET_ALL  @Constraint=@Constraint,@Cmp_ID=@Cmp_ID,@From_Date=@From_Date,@To_Date=@To_Date,@All_Weekoff=@All_Weekoff,@Is_FNF=@Is_FNF,@Is_Leave_Cal=@Is_Leave_Cal,@Allowed_Full_WeekOff_MidJoining=@Allowed_Full_WeekOff_MidJoining,@Type=@Type,@Use_Table=@Use_Table    
  

 ENd

 IF @Exec_Mode <> @HOLIDAY --IF NOT ONLY WEEKOFF  
 Begin 
 
  EXEC SP_EMP_WEEKOFF_DATE_GET_ALL  @Constraint=@Constraint,@Cmp_ID=@Cmp_ID,@From_Date=@From_Date,@To_Date=@To_Date,@All_Weekoff=@All_Weekoff,@Is_FNF=@Is_FNF,@Is_Leave_Cal=@Is_Leave_Cal,@Allowed_Full_WeekOff_MidJoining=@Allowed_Full_WeekOff_MidJoining,@Type=@Type,@Use_Table=@Use_Table  
  
 END
	
 
 
 
 /*Removing buffered weekoff holiday dates*/  
 DELETE FROM #Emp_WeekOff  
   WHERE For_Date NOT BETWEEN @From_Date AND @To_Date  
  
         
 DELETE FROM #EMP_HOLIDAY  
   WHERE For_Date NOT BETWEEN @From_Date AND @To_Date  
   
 /*Flag added to delete the records from Holiday Weekoff tables which are canceled(Half Day Provision).*/  
 

 --   --commented by mansi start 18_12_21
 -- UPDATE #EMP_HOLIDAY   
 --SET  Is_Cancel = 0  
 --WHERE H_DAY < 1 AND H_DAY > 0 AND Is_Cancel=1  
  --   --commented by mansi end 18_12_21
    --added by mansi start 18_12_21
 
  --added by mansi end 18_12_21
 --   --commented by mansi start 17_12_21
 --UPDATE #Emp_WeekOff  
 --SET  Is_Cancel = 0  
 --WHERE W_DAY < 1 AND W_DAY > 0 AND Is_Cancel=1  
 --   --commented by mansi start 17_12_21
 
 --added by mansi start 17_12_21
 UPDATE #EMP_HOLIDAY   
 SET  Is_Cancel = 0  
	--WHERE	H_DAY < 1 AND H_DAY > 0 AND Is_Cancel=1  -- Commeted By Sajid 05072023 due to Half Holiday not cancel sandwich
	WHERE	H_DAY < 0.5 AND H_DAY > 0 AND Is_Cancel=1  -- Added By Sajid 05072023
 
 select * from #EMP_HOLIDAY

 UPDATE #Emp_WeekOff  
 SET  Is_Cancel = 0  
 WHERE W_DAY < 1 AND W_DAY > 0 AND Is_Cancel=1   -- Deepal 24082022 add the = sign Ticket# 22262
  --added by mansi end 17_12_21

--select * from T0100_LEAVE_APPLICATION where Emp_ID = 28127
--select * from #Emp_WeekOff  
--select * from T0110_LEAVE_APPLICATION_DETAIL where Leave_Application_ID = 5419
--select * from T0120_LEAVE_APPROVAL where Emp_ID = 28127
--select Weekoff_as_leave,* from T0040_LEAVE_MASTER where leave_id = 994

--SELECT * FROM T0100_LEAVE_APPLICATION WHERE EMP_ID = 27409
--SELECT * FROM T0100_LEAVE_APPLICATION WHERE EMP_ID = 24492


--select * from #Emp_WeekOff w inner join T0100_LEAVE_APPLICATION l on l.emp_id = w.emp_id 
--			inner join T0110_LEAVE_APPLICATION_DETAIL ld on ld.Leave_Application_ID = l.Leave_Application_ID
--			inner JOIN T0040_LEAVE_MASTER LM ON LD.Leave_ID = LM.Leave_ID
--			inner join #emp_cons e on w.emp_id = e.Emp_id
--			where W.FOR_DATE BETWEEN LD.From_Date AND LD.To_Date AND LM.Weekoff_as_leave=0

--ADDED BY MEHUL 04102022 FOR GETTING SANDWHICH POLICY PROPER AS PER THE SCENARIO
Create table #tempdata(
	row_id numeric,
	emp_id numeric
)

Insert into #tempdata
select w.row_id,w.Emp_ID from #Emp_WeekOff w inner join T0100_LEAVE_APPLICATION l on l.emp_id = w.emp_id 
left outer join T0110_LEAVE_APPLICATION_DETAIL ld on ld.Leave_Application_ID = l.Leave_Application_ID
LEFT OUTER JOIN T0040_LEAVE_MASTER LM ON LD.Leave_ID = LM.Leave_ID
left outer join #emp_cons e on w.emp_id = e.Emp_id
where W.FOR_DATE BETWEEN LD.From_Date AND LD.To_Date AND LM.Weekoff_as_leave=0
			
if exists (select w.row_id from #Emp_WeekOff w inner join T0100_LEAVE_APPLICATION l on l.emp_id = w.emp_id 
			left outer join T0110_LEAVE_APPLICATION_DETAIL ld on ld.Leave_Application_ID = l.Leave_Application_ID
			LEFT OUTER JOIN T0040_LEAVE_MASTER LM ON LD.Leave_ID = LM.Leave_ID
			left outer join #emp_cons e on w.emp_id = e.Emp_id
			where W.FOR_DATE BETWEEN LD.From_Date AND LD.To_Date AND LM.Weekoff_as_leave=0)
begin	

			UPDATE #Emp_WeekOff  
			SET  Is_Cancel = 0 
			WHERE Row_ID IN (
			select W.Row_ID from #Emp_WeekOff w 
			inner join T0100_LEAVE_APPLICATION l on l.emp_id = w.emp_id 
			left outer join T0110_LEAVE_APPLICATION_DETAIL ld on ld.Leave_Application_ID = l.Leave_Application_ID
			left outer join #emp_cons e on w.emp_id = e.Emp_id
			left outer join #tempdata td on w.Row_ID = td.row_id
			where W.FOR_DATE BETWEEN LD.From_Date AND LD.To_Date and w.Row_ID in(td.row_id) and w.Emp_ID in (td.emp_id))
			and Emp_id in (select W.Emp_ID from #Emp_WeekOff w 
			inner join T0100_LEAVE_APPLICATION l on l.emp_id = w.emp_id 
			left outer join T0110_LEAVE_APPLICATION_DETAIL ld on ld.Leave_Application_ID = l.Leave_Application_ID
			left outer join #emp_cons e on w.emp_id = e.Emp_id
			left outer join #tempdata td on w.Row_ID = td.row_id
			where W.FOR_DATE BETWEEN LD.From_Date AND LD.To_Date and w.Row_ID in(td.row_id) and w.Emp_ID in (td.emp_id))
end

IF @Delete_Cancel_HW = 1  
	DELETE FROM #Emp_WeekOff WHERE Is_Cancel = 1  	

DROP TABLE #tempdata

--end by mehul 04102022 for getting sandwhich policy proper as per the scenario

 IF OBJECT_ID('tempdb..#EMP_HOLIDAY') IS NOT NULL AND @Delete_Cancel_HW = 1  
  DELETE FROM #EMP_HOLIDAY WHERE Is_Cancel = 1  
   --select * from #EMP_HOLIDAY-----mansi
  -- select * from #EMP_HW_CONS --ronak
 /********************************************************************************************************************************************  
 *********************************************   IMPORTANT NOTES BEFORE USING THIS STORED PROCEDURE   ****************************************  
 *********************************************************************************************************************************************  
  
 1. TO GET WEEKOFF RECORDS IN A TABLE BY DATE THEN CREATE FOLLOWING TABLE BEFORE EXECUTING THIS STORED PROCEDURE  
  
 CREATE TABLE #Emp_WeekOff(Row_ID NUMERIC, Emp_ID NUMERIC, For_Date DATETIME, Weekoff_day VARCHAR(10), W_Day numeric(4,1),Is_Cancel BIT);  
  
   
 =========================================================================================================================================  
 =========================================================================================================================================  
  
 2. TO GET HOLIDAY RECORDS IN A TABLE BY DATE THEN CREATE FOLLOWING TABLE BEFORE EXECUTING THIS STORED PROCEDURE  
  
 CREATE TABLE #EMP_HOLIDAY(EMP_ID NUMERIC, FOR_DATE DATETIME, IS_CANCEL BIT, Is_Half tinyint, Is_P_Comp tinyint, H_DAY numeric(4,1));  
 CREATE UNIQUE CLUSTERED INDEX IX_EMP_HOLIDAY_EMPID_FORDATE ON #EMP_HOLIDAY(EMP_ID, FOR_DATE);  
  
 =========================================================================================================================================  
 =========================================================================================================================================  
  
 3. TO GET BOTH HOLIDAY AND WEEKOFF DATA IN A COLON SEPERATED STRING FOR EACH EMPLOYEE IN A TABLE THEN CREATE FOLLOWING TABLE BEFORE  
  EXECUTING THIS STORED PROCEDURE  
  
  
 CREATE TABLE #EMP_HW_CONS  
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
 CREATE UNIQUE CLUSTERED INDEX IX_EMP_HW_CONS_EmpID ON #EMP_HW_CONS(Emp_ID)  
  
********************************************************************************************************************************************  
********************************************************************************************************************************************  
********************************************************************************************************************************************/  

  
  