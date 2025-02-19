      
      
      
CREATE PROCEDURE [dbo].[rpt_Late_Mark_Scenario4]      
  @Cmp_ID  numeric        
 ,@From_Date datetime        
 ,@To_Date  datetime         
 ,@Branch_ID numeric        
 ,@Cat_ID  numeric         
 ,@Grd_ID  numeric        
 ,@Type_ID  numeric        
 ,@Dept_ID  numeric        
 ,@Desig_ID  numeric        
 ,@Emp_ID  numeric        
 ,@constraint varchar(MAX)        
 ,@Flag         tinyint = 0      
AS      
      
        SET NOCOUNT ON       
  SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED      
  SET ARITHABORT ON      
      
      
BEGIN      
        
      
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
      
 IF @Flag = 0      
  Begin      
   IF OBJECT_ID('tempdb..#Emp_Cons') IS Not NULL      
    BEGIN         
     Drop Table #Emp_Cons      
    END      
      
   CREATE TABLE #Emp_Cons       
   (            
    Emp_ID numeric,           
    Branch_ID numeric,      
    Increment_ID numeric          
   )      
  END      
      
 IF Object_ID('tempdb..#Emp_Late_Scenario4') Is not null      
  Begin      
   Drop Table #Emp_Late_Scenario4      
  End      
      
 Create Table #Emp_Late_Scenario4      
 (      
  Cmp_ID Numeric,      
  Emp_ID Numeric,       
  From_Min Numeric,      
  To_Min Numeric,      
  From_Count Numeric,      
  To_Count Numeric,      
  Deduction Numeric(6,2),      
  For_Date Varchar(Max)      
 )      
      
 IF OBJECT_ID('tempdb..#EMP_HOLIDAY') IS NULL      
  BEGIN      
   CREATE TABLE #EMP_HOLIDAY(EMP_ID NUMERIC, FOR_DATE DATETIME, IS_CANCEL BIT, Is_Half tinyint, Is_P_Comp tinyint, H_DAY numeric(4,1));      
   CREATE UNIQUE CLUSTERED INDEX IX_EMP_HOLIDAY_EMPID_FORDATE ON #EMP_HOLIDAY(EMP_ID, FOR_DATE);      
  END      
      
 IF OBJECT_ID('tempdb..#Emp_WeekOff') IS NULL      
  BEGIN      
   CREATE TABLE #EMP_WEEKOFF      
   (      
    Row_ID   NUMERIC,      
    Emp_ID   NUMERIC,      
    For_Date  DATETIME,      
    Weekoff_day  VARCHAR(10),      
    W_Day   numeric(4,1),      
    Is_Cancel  BIT      
   )      
   CREATE CLUSTERED INDEX IX_Emp_WeekOff_EmpID_ForDate ON #EMP_WEEKOFF(Emp_ID, For_Date)        
  END      
       
 CREATE table #Data      
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
 )           
 EXEC SP_GET_HW_ALL @CONSTRAINT=@constraint,@CMP_ID=@Cmp_ID, @FROM_DATE=@FROM_DATE, @TO_DATE=@TO_DATE, @All_Weekoff = 0, @Exec_Mode=0, @Delete_Cancel_HW =0      
      
 Exec SP_CALCULATE_PRESENT_DAYS @Cmp_ID=@Cmp_ID,@FROM_DATE=@From_Date,@TO_DATE=@To_Date,@Branch_ID=0,@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Emp_ID=0,@CONSTRAINT=@constraint,@Return_Record_set=4      
       
 DECLARE @ABSENT_DATE_STRING VARCHAR(MAX)      
 SET @ABSENT_DATE_STRING = ''      
 DECLARE @WEEKOFF_DATE_STRING VARCHAR(MAX)      
 SET @WEEKOFF_DATE_STRING = ''      
 DECLARE @HOLIDAY_DATE_STRING VARCHAR(MAX)      
 SET @HOLIDAY_DATE_STRING = ''      
      
 DECLARE @LATE_ABSENT_DAY NUMERIC(18,2)      
 SET @LATE_ABSENT_DAY = 0      
      
 Declare @Total_LMark NUMERIC(18,2)      
 SET @Total_LMark = 0      
      
 DECLARE @INCREMENT_ID NUMERIC      
 SET @INCREMENT_ID = 0      
      
 Declare @Total_Late_Sec Numeric      
 Set @Total_Late_Sec = 0      
      
 Declare Cur_Emp Cursor For      
 Select Emp_ID,Increment_ID From #Emp_Cons      
 Open Cur_Emp      
 Fetch Next From Cur_Emp into @Emp_ID,@INCREMENT_ID      
  While @@FETCH_STATUS = 0      
   Begin      
    SET @ABSENT_DATE_STRING = ''      
    SET @WEEKOFF_DATE_STRING = ''      
    SET @HOLIDAY_DATE_STRING = ''      
    SELECT @ABSENT_DATE_STRING = COALESCE(@ABSENT_DATE_STRING + '#', '') + CAST(FOR_DATE AS VARCHAR(11))       
     FROM #DATA       
    WHERE EMP_ID = @EMP_ID AND FOR_DATE >= @FROM_DATE AND FOR_DATE <= @TO_DATE AND P_DAYS = 0      
    AND NOT EXISTS(SELECT 1 FROM #DATA Where Weekoff_OT_Sec > 0 OR Holiday_OT_Sec > 0)      
      
    SELECT @WEEKOFF_DATE_STRING = COALESCE(@WEEKOFF_DATE_STRING + ';', '') + CAST(FOR_DATE AS VARCHAR(11))       
     FROM #EMP_WEEKOFF      
    WHERE EMP_ID = @EMP_ID      
      
    SELECT @HOLIDAY_DATE_STRING = COALESCE(@HOLIDAY_DATE_STRING + ';', '') + CAST(FOR_DATE AS VARCHAR(11))       
     FROM #EMP_HOLIDAY      
    WHERE EMP_ID = @EMP_ID    
  
    exec SP_CALCULATE_LATE_DEDUCTION_SCENARIO4 @Emp_ID,@Cmp_ID,@From_Date,@To_Date,@Late_Absent_Day output,@Increment_ID,@WEEKOFF_DATE_STRING,@HOLIDAY_DATE_STRING,0,'',0,@Absent_date_String      
     
    Fetch Next From Cur_Emp into @Emp_ID,@INCREMENT_ID   
   End      
 Close Cur_Emp      
 Deallocate Cur_Emp      
      
 Select EM.EMP_ID,EM.Alpha_Emp_Code,Emp_Full_Name,BM.Branch_Name,dbo.F_Return_Hours(From_Min*60) as From_Min,dbo.F_Return_Hours(To_min*60) as To_Min ,From_Count,To_Count,Deduction,For_Date,CM.Cmp_Name,CM.Cmp_Address,      
 Replace(Convert(varchar(11),@From_Date,104),'.','/') as From_Date,Replace(Convert(varchar(11),@To_Date,104),'.','/') as To_Date,BM.Branch_Address,BM.Comp_Name      
 From #Emp_Late_Scenario4 LE      
 Inner join T0080_EMP_MASTER EM WITH (NOLOCK) ON LE.EMP_ID = EM.EMP_ID      
 Inner Join #Emp_Cons EC ON EC.Emp_ID = LE.Emp_ID      
 INNER Join T0095_INCREMENT I WITH (NOLOCK) ON I.Increment_ID = EC.Increment_ID      
 INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON BM.Branch_ID = I.Branch_ID      
 Inner join T0010_COMPANY_MASTER CM WITH (NOLOCK) ON CM.Cmp_Id = LE.Cmp_ID      
END 