


-- Created By rohit on 20032015
-- Created For Run in the Auto Schedule for Insert Data in the Temp Inout Table
CREATE PROCEDURE [dbo].[SP_RPT_EMP_INOUT_RECORD_GET_New_For_Auto]      
 @Cmp_ID   numeric,      
 @From_Date  datetime,      
 @To_Date  datetime ,      
 @Branch_ID  numeric = 0  ,      
 @Cat_ID   numeric  = 0,      
 @Grd_ID   numeric = 0,      
 @Type_ID  numeric = 0,      
 @Dept_ID  numeric  = 0,      
 @Desig_ID  numeric = 0,      
 @Emp_ID   numeric  = 0,      
 @Constraint  varchar(5000) = '',      
 @Report_call varchar(20) = 'IN-OUT',      
 @Weekoff_Entry varchar(1) = 'Y',  
 @PBranch_ID varchar(200) = '0'
 ,@SubBranch_Id numeric = 0 
 ,@BusSegement_Id numeric  = 0
 ,@SalCyc_Id numeric  = 0
 ,@Vertical_Id numeric  = 0
 ,@SubVertical_Id numeric  = 0
      
AS      
  	SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON
    
       
       
 declare @Status as varchar(9)      
 Declare @For_Date as datetime      
 Declare @RowID as numeric       
 Declare @GradeID as numeric       
 Declare @SysDate dateTime  
      
      
 declare @LateMark as varchar(9)      
 Declare @InTime as smalldatetime       
 Declare @OutTime as smalldatetime      
 Declare @PreOutTime as smalldatetime      
        
 declare @Is_Join as varchar(1)      
 Declare @Count as numeric      
 DECLARE @dblYear as numeric      
 Declare @numofDay as numeric      
 declare @varWeekoff_Date as varchar(500)      
 declare @varHoliday_Date as varchar(500)      
  
 Declare @Join_Date    Datetime      
 Declare @Left_Date    Datetime       
 Declare @StrHoliday_Date  varchar(1000)      
 Declare @StrWeekoff_Date  varchar(1000)      
 Declare @Is_Cancel_Holiday  Numeric(1,0)      
 Declare @Is_Cancel_Weekoff  Numeric(1,0)      
 DECLARE @Holiday_Days    NUMERIC(12,1)      
 DECLARE @Weekoff_Days    NUMERIC(12,1)      
 DECLARE @Cancel_Holiday   NUMERIC(12,1)      
 DECLARE @Cancel_Weekoff      NUMERIC(12,1)      
  
  
 set @Is_Cancel_Weekoff = 0      
 set @Is_Cancel_Holiday = 0      
 Set @StrHoliday_Date = ''      
 set @StrWeekoff_Date = ''      
 Set @Holiday_Days  = 0      
 Set @Weekoff_Days  = 0      
 Set @Cancel_Holiday  = 0      
 Set @Cancel_Weekoff  = 0      
  
      
 set @Count =0      
 set @RowID =0      
   
       
 set @numofDay = Datediff(d,@From_Date,@To_Date) + 1      
      
-- for Holiday and Week Off  and LEave date      
 Declare @Total_Holiday_Date as varchar(500)      
 Declare @Total_LeaveDay_Date as varchar(500)      
 declare @strOnlyHoliday_date as varchar(500)      
  set @Total_Holiday_Date = ''      
  set @Total_LeaveDay_Date = ''      
      
 -- for Shift      
 declare @Shift_St_Time as varchar(10)      
 declare @Shift_End_Time as varchar(10)      
 declare @varShift_St_Date as varchar(20)      
 declare @dtShift_St_Date as datetime      
 declare @varShift_End_Date as varchar(20)      
 declare @dtShift_End_Date as datetime      
 Declare @TempFor_Date as smalldatetime      
 Declare @dtShift_Actual_St_Time as datetime      
 Declare @dtShift_Actual_End_Time as datetime      
 Declare @Late_Comm_Limit as varchar(5)      
 declare @Late_comm_sec as numeric       
 Declare @Leave_ID as numeric       
 Declare @Leave_Name as varchar(20)      
 Declare @Leave_Reason As varchar(100)  
 --Added by Hardik 06/12/2013 for Pakistan
 Declare @Leave_Period as Numeric(18,2)
 Declare @Half_Leave_Date as datetime
 Declare @Leave_Assign_As as Varchar(100)
 Declare @Country_Name as Varchar(100)

	Select @Country_Name = Loc_name From T0010_COMPANY_MASTER C WITH (NOLOCK) Inner Join T0001_LOCATION_MASTER L WITH (NOLOCK) On
		C.Loc_ID = L.Loc_ID where C.Cmp_Id = @Cmp_ID
      
 declare @Temp_Month_Date as datetime      
 set @Temp_Month_Date = @From_Date      
       
 declare @In_Dur as varchar(10)      
 declare @In_Out_Flag as varchar(1)      
 declare @Day_St_Time as datetime      
 declare @Day_End_Time as datetime      
       
 declare @OT_Limit_Sec as numeric      
 declare @OT_Limit as varchar(10)      
       
 declare @Temp_For_Date as varchar(11)      
 declare @Shift_Sec as numeric      
 declare @Return_Sec as numeric      
 declare @Tot_Working_Sec as numeric      
 declare @Working_Sec as numeric      
 declare @OT_Sec as numeric      
 declare @Holiday_Work_Sec as numeric      
 declare @WeekOff_Work_Sec as numeric      
       
 set @Return_Sec = 0      
 set @Holiday_Work_Sec = 0      
 set @WeekOff_Work_Sec = 0      
       
 declare @In_Date as datetime      
 declare @Out_Date as datetime      
 declare @Shift_Dur as varchar(10)      
 Declare @Temp_Date as datetime      
 declare @Min_Dur as varchar(10)      
       
 declare @Rounding_Shift_Time as numeric      
 declare @Next_Day_Working_Sec as numeric      
 Declare @Is_OT as varchar(1)      
 Declare @Fix_OT as numeric      
 Declare @Shift_End_DateTime as datetime      
 Declare @Shift_ST_DateTime as datetime      
 declare @Last_out_Date as datetime      
 Declare @Manual_Last_in_Date as datetime      
 declare @Next_day_Work_Sec as numeric  -- previous days working sec      
 declare @Temp_Working_sec as numeric      
 declare @varWagesType as varchar(20)      
 Declare @temp_out_Date as datetime      
 dECLARE @SHIFT_ID AS NUMERIC       
      
 declare @Insert_In_Date as datetime      
 Declare @Insert_Out_Date as datetime      
 DECLARE @INSERT_COUNT AS INTEGER      
 Declare @Late_In as varchar(20)      
 Declare @Late_Out as varchar(20)      
 Declare @Early_In as varchar(20)      
 Declare @Early_Out as varchar(20)      
 Declare @WORKING_HOURS as varchar(20)      
 Declare @Late_In_Count as numeric       
 Declare @Early_out_count as numeric       
 Declare @Total_less_work_sec as numeric       
 Declare @Total_More_work_sec as numeric       
       
 Declare @Late_In_Sec numeric      
 Declare @Late_Out_Sec numeric      
 Declare @Early_In_Sec numeric      
 Declare @Early_Out_Sec numeric      
       
 Declare @Toatl_Working_sec numeric       
 Declare @Total_work as varchar(20)      
 Declare @Less_Work as varchar(20)      
 Declare @More_Work as varchar(20)      
 Declare @Diff_Sec  as numeric       
 declare @Working_Sec_AfterShift as numeric       
 Declare @Working_AfterShift_Count as numeric       
 Declare @Reason as varchar(300)      
 Declare @Pre_Reason as varchar(300)      
 Declare @Last_Entry_For_check as datetime      
      
 declare @Shift_St_Sec as numeric       
 declare @Shift_En_sec as numeric      
 declare @Pre_Inout_Flag as varchar(1)      
 declare @Pre_In_Date as datetime      
 Declare @Pre_Shift_St_dateTime as datetime      
 Declare @Pre_Shift_En_DateTime as datetime       

 Declare @Early_Limit_sec as numeric   
 Declare @Early_Limit as varchar(10)    
 Set @Early_Limit_sec = 0
 Set @Early_Limit = ''
 
 Declare @Emp_OT as Numeric
 Declare @Emp_OT_Min_Limit_Sec as Numeric
 Declare @Emp_OT_Max_Limit_Sec as Numeric
 
 Declare @Monthly_Deficit_Adjust_OT_Hrs as tinyint -- Added by Hardik 25/10/2013 for Sharp Image, Pakistan
 
 --Ankit 12112013
 Declare @Second_Break_Duration as varchar(10)    
 Declare @Third_Break_Duration as varchar(10)     
	 Set @Second_Break_Duration =''	
	 Set @Third_Break_Duration =''	
 declare @Second_Break_Duration_Sec as numeric      	
 declare @Third_Break_Duration_Sec as numeric      	
--Ankit 12112013 

 Set @Emp_OT = 0
 Set @Emp_OT_Min_Limit_Sec = 0
 Set @Emp_OT_Max_Limit_Sec = 0
 Set @Monthly_Deficit_Adjust_OT_Hrs = 0
    
 set @Fix_OT = 0      
   
 set @Reason  = ''      
 set @Pre_Reason = ''      
      
 set @Shift_St_Time = ''      
 set @Shift_End_Time = ''      
 set @Shift_Dur = ''      
 set @Late_Comm_Limit = ''      
 set @Late_comm_sec = 0      
 set @Leave_Id = 0      
 set @Leave_Name = ''      
       
       
 if @Branch_ID = 0      
  set @Branch_ID = null      
 If @Cat_ID = 0      
  set @Cat_ID  = null      
        
 if @Type_ID = 0      
  set @Type_ID = null      
 if @Dept_ID = 0      
  set @Dept_ID = null      
 if @Grd_ID = 0      
  set @Grd_ID = null      
 if @Emp_ID = 0      
  set @Emp_ID = null      
 if @Desig_ID =0      
  set @Desig_ID = null      
  
  If @SubBranch_Id = 0
	Set @SubBranch_Id = null
  If @BusSegement_Id = 0
	Set @BusSegement_Id = null
  If @SalCyc_Id = 0
 	Set @SalCyc_Id = null
  If @Vertical_Id = 0
	Set @Vertical_Id = null
  If @SubVertical_Id = 0
	Set @SubVertical_Id = null    
       
 select @Late_Comm_Limit = Late_Limit,@Early_Limit = Early_Limit from T0040_GENERAL_SETTING WITH (NOLOCK) where Cmp_ID = @Cmp_ID      
 and For_Date  = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where Cmp_ID = @Cmp_ID and For_Date <=@To_Date)      
       
 set @Late_Comm_sec = dbo.F_Return_Sec(@Late_Comm_Limit) 
 set @Early_Limit_sec = dbo.F_Return_Sec(@Early_Limit)        

	CREATE TABLE #Emp_Cons 
	 (      
	   Emp_ID numeric ,     
	   Branch_ID numeric,
	   Increment_ID numeric    
	 )      

	if @Constraint <> ''
		begin
			Insert Into #Emp_Cons
			Select cast(data  as numeric),cast(data  as numeric),cast(data  as numeric) From dbo.Split(@Constraint,'#') 
		end
	else 
		begin
			if @PBranch_ID <> '0' and isnull(@Branch_ID,0) = 0
				Begin
					Insert Into #Emp_Cons      
					  select distinct emp_id,branch_id,Increment_ID from dbo.V_Emp_Cons where 
					  cmp_id=@Cmp_ID 
					   and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
					and Branch_ID in (select cast(isnull(data,0) as numeric) from dbo.Split(@PBranch_ID,'#'))					   
				   --and Branch_ID = isnull(@Branch_ID ,Branch_ID)      
				   and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
				   and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
				   and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
				   and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0)) 
				   and Isnull(subBranch_ID,0) = isnull(@SubBranch_Id ,Isnull(subBranch_ID,0))
				   and Isnull(Segment_ID,0) = isnull(@BusSegement_Id ,Isnull(Segment_ID,0))
				   and Isnull(SalDate_id,0) = isnull(@SalCyc_Id ,Isnull(SalDate_id,0))
				   and Isnull(Vertical_ID,0) = isnull(@Vertical_Id ,Isnull(Vertical_ID,0))
				   and Isnull(SubVertical_ID,0) = isnull(@SubVertical_Id ,Isnull(SubVertical_ID,0))
				   and Emp_ID = isnull(@Emp_ID ,Emp_ID)   
					  and Increment_Effective_Date <= @To_Date 
					  and 
							  ( (@From_Date  >= join_Date  and  @From_Date <= left_date )      
								or ( @To_Date  >= join_Date  and @To_Date <= left_date )      
								or (Left_date is null and @To_Date >= Join_Date)      
								or (@To_Date >= left_date  and  @From_Date <= left_date )) 
								order by Emp_ID
								
						--Delete From #Emp_Cons Where Increment_ID Not In
						--(select TI.Increment_ID from t0095_increment TI inner join
						--(Select Max(Increment_Effective_Date) as Effective_Date,Emp_ID from T0095_Increment
						--Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
						--on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Effective_Date
						--Where Increment_effective_Date <= @to_date) 
						
						Delete E From #Emp_Cons E left Join (Select Max(Increment_ID)as inc from T0095_Increment WITH (NOLOCK)
						Where  Increment_effective_Date <= @to_date Group by emp_ID) as INC_d on E.increment_id = INC_d.inc where isnull(inc_d.inc,0)=0
				End	
			Else
				Begin
					Insert Into #Emp_Cons      
					  select distinct emp_id,branch_id,Increment_ID from dbo.V_Emp_Cons where 
					  cmp_id=@Cmp_ID 
					   and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
				   and Branch_ID = isnull(@Branch_ID ,Branch_ID)      
				   and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
				   and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
				   and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
				   and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0)) 
				   and Isnull(subBranch_ID,0) = isnull(@SubBranch_Id ,Isnull(subBranch_ID,0))
				   and Isnull(Segment_ID,0) = isnull(@BusSegement_Id ,Isnull(Segment_ID,0))
				   and Isnull(SalDate_id,0) = isnull(@SalCyc_Id ,Isnull(SalDate_id,0))
				   and Isnull(Vertical_ID,0) = isnull(@Vertical_Id ,Isnull(Vertical_ID,0))
				   and Isnull(SubVertical_ID,0) = isnull(@SubVertical_Id ,Isnull(SubVertical_ID,0))
				   and Emp_ID = isnull(@Emp_ID ,Emp_ID)   
					  and Increment_Effective_Date <= @To_Date 
					  and 
							  ( (@From_Date  >= join_Date  and  @From_Date <= left_date )      
								or ( @To_Date  >= join_Date  and @To_Date <= left_date )      
								or (Left_date is null and @To_Date >= Join_Date)      
								or (@To_Date >= left_date  and  @From_Date <= left_date )) 
								order by Emp_ID
								
						--Delete From #Emp_Cons Where Increment_ID Not In
						--(select TI.Increment_ID from t0095_increment TI inner join
						--(Select Max(Increment_Effective_Date) as Effective_Date,Emp_ID from T0095_Increment
						--Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
						--on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Effective_Date
						--Where Increment_effective_Date <= @To_Date) 
						Delete E From #Emp_Cons E left Join (Select Max(Increment_ID)as inc from T0095_Increment WITH (NOLOCK)
						Where  Increment_effective_Date <= @to_date Group by emp_ID) as INC_d on E.increment_id = INC_d.inc where isnull(inc_d.inc,0)=0
				End	
		end

  
	Declare @Branch_Id_Cur as numeric
 
	Declare @leave_Footer varchar(5000)
	set @leave_Footer = ''

	SELECT  @leave_Footer = STUFF((SELECT ' ' + s.Leave_name FROM 
	( select ('  ' + Leave_Code + ' : ' + Leave_name + ' ' ) as leave_name,Cmp_ID from T0040_LEAVE_MASTER WITH (NOLOCK)
	)
	 s WHERE s.Cmp_id = t.Cmp_id FOR XML PATH('')),1,1,'')  FROM T0040_LEAVE_MASTER AS t WITH (NOLOCK) where t.Cmp_ID=@cmp_id GROUP BY t.Cmp_id
      
	if @Report_call <> 'Monthly Generate'
	BEGIN   
	if  object_id('tempdb..#Emp_Inout') IS NOT NULL --exists (select 1 from [tempdb].dbo.sysobjects where name like '#Emp_Inout' )        
	 begin      
	  drop table #Emp_Inout  
	 end  
	  
 CREATE TABLE #Emp_Inout       
  (      
   emp_id     numeric ,      
   for_Date    datetime,      
   Dept_id    numeric null ,      
   Grd_ID    numeric null,      
   Type_ID   numeric null,      
   Desig_ID    numeric null,      
   Shift_ID    numeric null ,      
   In_Time    datetime null,      
   Out_Time    datetime null,      
   Duration    varchar(20) null,      
   Duration_sec   numeric  null,      
   Late_In    varchar(20) null,      
   Late_Out    varchar(20) null,      
   Early_In    varchar(20) null,      
   Early_Out    varchar(20) null,      
   Leave     varchar(5) null,      
   Shift_Sec    numeric null,      
   Shift_Dur    varchar(20) null,      
   Total_work    varchar(20) null,      
   Less_Work    varchar(20) null,      
   More_Work    varchar(20) null,      
   Reason     varchar(200) null,         
   AB_LEAVE    VARCHAR(20) NULL,      
   Late_In_Sec   numeric null,      
   Late_In_count   numeric null,      
   Early_Out_sec   numeric null,      
   Early_Out_Count  numeric null,      
   Total_Less_work_Sec numeric null,      
   Shift_St_Datetime  datetime null,      
   Shift_en_Datetime  datetime null,      
   Working_Sec_AfterShift numeric null,      
   Working_AfterShift_Count numeric null ,      
   Leave_Reason   varchar(250) null,      
   Inout_Reason   varchar(250) null,  
   SysDate  datetime   ,  
   Total_Work_Sec numeric Null,  
   Late_Out_Sec   numeric null,  
   Early_In_sec   numeric null,
   Total_More_work_Sec numeric null,
   Is_OT_Applicable tinyint null,
   Monthly_Deficit_Adjust_OT_Hrs tinyint null,
   Late_Comm_sec  numeric null,
   Branch_Id Numeric default 0
  )      
  END
  
 Select @Is_Cancel_Holiday = Is_Cancel_Holiday ,@Is_Cancel_Weekoff = Is_Cancel_Weekoff      
 From dbo.T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID and Branch_ID = @Branch_ID      
 and For_Date = ( select max(For_Date) from dbo.T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@To_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)  
  
 DECLARE CUR_EMP CURSOR FOR      
 SELECT E.EMP_ID,Inc_Qry.Grd_ID,Inc_Qry.Type_ID,Inc_Qry.Dept_ID,Inc_Qry.Desig_ID,
	dbo.F_Return_Sec(Inc_Qry.Emp_Late_Limit),dbo.F_Return_Sec(Inc_Qry.Emp_Early_Limit),
	Emp_OT,dbo.F_Return_Sec(Inc_Qry.Emp_OT_Min_Limit),dbo.F_Return_Sec(Inc_Qry.Emp_OT_Max_Limit),Isnull(Monthly_Deficit_Adjust_OT_Hrs,0),Inc_Qry.Branch_ID
 FROM dbo.T0080_EMP_MASTER E WITH (NOLOCK) Inner join #Emp_Cons EC on E.Emp_ID = EC.Emp_ID Inner join       
 ( select I.Emp_Id ,Type_ID ,Grd_ID,Dept_ID,Desig_Id,Isnull(Emp_Late_Limit,'00:00') as Emp_Late_Limit,
		Isnull(Emp_Early_Limit,'00:00') as Emp_Early_Limit,Isnull(Emp_OT,0) as Emp_OT,
		Isnull(Emp_OT_Min_Limit,'00:00') as Emp_OT_Min_Limit,Isnull(Emp_OT_Max_Limit,'00:00') as Emp_OT_Max_Limit, Monthly_Deficit_Adjust_OT_Hrs,
		Branch_ID
	 from dbo.T0095_INCREMENT I WITH (NOLOCK) inner join       
     ( select max(Increment_effective_Date) as For_Date, Emp_ID from dbo.T0095_INCREMENT WITH (NOLOCK)     
     where Increment_effective_Date <= @To_Date      
     and Cmp_ID = @Cmp_ID      
     group by emp_ID  ) Qry      
    on I.Emp_ID = Qry.Emp_ID and      
    i.Increment_effective_Date   = Qry.For_date       
    where Cmp_ID = @Cmp_ID ) Inc_Qry on       
     e.Emp_ID = Inc_Qry.Emp_ID       
           
 WHERE E.Cmp_ID = @Cmp_ID       
 OPEN  CUR_EMP      
 FETCH NEXT FROM CUR_EMP INTO @EMP_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Late_Comm_sec,@Early_Limit_Sec,@Emp_OT,@Emp_OT_Min_Limit_Sec,@Emp_OT_Max_Limit_Sec,@Monthly_Deficit_Adjust_OT_Hrs,@Branch_Id_Cur
 WHILE @@FETCH_STATUS = 0      
  BEGIN      
      set @varWeekoff_Date = ''      
      set @varHoliday_Date = ''       
      set @Last_out_Date  = null      
      set @out_Date = null      
      set @in_Date = null      
      set @Last_Entry_For_check = null      
      set @Pre_Inout_Flag = ''      
      set @Pre_Shift_St_DateTime = null      
      set @Pre_Shift_en_DateTime = null      
      set @Working_Sec_AfterShift = 0      
      set @Working_AfterShift_Count = 0       
            
      set @Temp_Month_Date = @From_Date      
            
    set @insert_In_date = null      
    set @insert_Out_Date = null      
    set @Pre_In_Date = null      
          
    set @strOnlyHoliday_date = ''      
    set @Total_Holiday_Date = ''      
    set @Total_LeaveDay_Date  = ''      
    set @varWeekoff_Date = ''      

      --Added by Hardik 22/11/2011 for Night shift Min In and Max Out Record
      Declare @Min_In Datetime 
      Declare @Max_Out as datetime
      declare @hh as int
	  declare @mi as int
	  Declare @Shift_St_Time1 as datetime
	  Declare @Shift_End_Time1 as datetime
	  Declare @For_Date1 as datetime
	  Declare @For_Date2 as datetime
	  declare @Max_Date as datetime
	  Declare @Reason1 as Varchar(150)
	  
      --- End for Hardik 
		
      
    Declare @Temp_End_Date as datetime       
    --set @Temp_End_Date = Dateadd(d,1,@To_Date)      
    set @Temp_End_Date = @To_Date      
  
	exec dbo.SP_EMP_JOIN_LEFT_DATE_GET @Emp_ID ,@Cmp_ID ,@From_Date,@To_date,@Join_Date output,@Left_Date output
	
	Exec dbo.SP_EMP_WEEKOFF_DATE_GET @Emp_ID,@Cmp_ID,@From_Date,@To_Date,@Join_Date,@left_Date,@Is_Cancel_weekoff,@StrHoliday_Date,@StrWeekoff_Date output,@Weekoff_Days output ,@Cancel_Weekoff output      
	Exec dbo.SP_EMP_HOLIDAY_DATE_GET @Emp_ID,@Cmp_ID,@From_Date,@To_Date,@Join_Date,@left_Date,@Is_Cancel_Holiday,@StrHoliday_Date output,@Holiday_days output,@Cancel_Holiday output,0,@Branch_ID,@StrWeekoff_Date  
  
          
    while @Temp_Month_Date <= @Temp_End_Date      
     begin      
      set @shift_ID = 0      
            
   Exec dbo.SP_CURR_T0100_EMP_SHIFT_GET @emp_id,@Cmp_ID,@Temp_Month_Date,@Shift_St_Time output,@Shift_End_Time output,@Shift_Dur output,null,@Second_Break_Duration Output,@Third_Break_Duration  output,null,@shift_ID output      

      set @Shift_Sec = 0     
      set @Shift_Sec  = dbo.F_Return_Sec(@Shift_Dur)      
      set @Shift_St_Sec = dbo.F_Return_Sec(@Shift_St_Time)      
      set @Shift_En_Sec = dbo.F_Return_Sec(@Shift_End_Time)      
 
	  --Ankit 12112013
      Set @Second_Break_Duration_Sec = 0
      set @Third_Break_Duration_Sec = 0
      Set @Second_Break_Duration_Sec = dbo.F_Return_Sec(@Second_Break_Duration)
      Set @Third_Break_Duration_Sec = dbo.F_Return_Sec(@Third_Break_Duration)
   
	  --Ankit 12112013	 
            
   Set @Leave_Name = ''  
   Set @Leave_Reason = ''  
   Set @Leave_ID = 0  
   Set @Leave_Period = 0
   Set @Half_Leave_Date = ''
   Set @Leave_Assign_As =''
   
      set @Fix_OT = 86400 - @Shift_Sec       
      set @Day_St_Time = cast(cast(@Temp_Month_Date as varchar(11)) + ' ' + '00:00'  as smalldatetime)  
      set @Shift_St_Datetime = cast(cast(@Temp_Month_Date as varchar(11)) + ' ' + @Shift_St_Time as smalldatetime)      
      set @Temp_Date = dateadd(d,1,@Temp_Month_Date)      
      set @Day_End_Time = cast(cast(@Temp_Date as varchar(11)) + ' ' + '00:00'  as smalldatetime)      
      if @Shift_St_Sec > @Shift_En_Sec       
       set @Shift_End_DateTime = cast(cast(@Temp_Date as varchar(11)) + ' ' + @Shift_End_Time  as smalldatetime)      
      else      
       set @Shift_End_DateTime = cast(cast(@Temp_Month_Date as varchar(11)) + ' ' + @Shift_End_Time  as smalldatetime)      
             
      SET @Insert_IN_DATE = NULL      
      SET @Insert_Out_DATE = NULL      

      --select @Insert_In_Date = Min(In_Time) From T0150_emp_inout_record Where Emp_ID  = @Emp_ID and For_Date = @Temp_Month_Date      
      --select @Insert_Out_Date = Out_Time  From T0150_emp_inout_record Where Emp_ID = @Emp_ID and In_Time = @Insert_In_Date      

			Declare @First_In_Last_Out_For_InOut_Calculation tinyint
			set @First_In_Last_Out_For_InOut_Calculation = 0 
			Select @First_In_Last_Out_For_InOut_Calculation= isnull(First_In_Last_Out_For_InOut_Calculation,0) from dbo.T0040_GENERAL_SETTING where Cmp_ID = @Cmp_ID and Branch_ID = (Select Branch_ID from dbo.T0080_EMP_MASTER where Emp_ID=@Emp_ID)

			If @Report_call ='Inout_Page' --added by Hardik 13/10/2012 for In Out Record Page
				Set @First_In_Last_Out_For_InOut_Calculation = 0

			If @First_In_Last_Out_For_InOut_Calculation = 1
				Begin      
					-- Hardik 14/08/2012 for Night Shift Checking...
					--If CONVERT(varchar(5), @Shift_St_Time, 108) < CONVERT(varchar(5), @Shift_End_Time, 108)
						Begin
							  Declare cur_Inout cursor for       
							 -- select Min(In_time),Max(Out_Time),Reason from dbo.T0150_emp_inout_record Where Emp_ID =@Emp_ID and For_Date = @Temp_Month_Date    
								--group by Reason
								select Min(In_time),
								Case When Max_In > Max(Out_Time) Then Max_In Else Max(Out_time) End ,Reason from dbo.T0150_emp_inout_record e WITH (NOLOCK) Inner Join
								(select Max(In_time) Max_In,Emp_Id,For_Date from dbo.T0150_emp_inout_record WITH (NOLOCK) Where Emp_ID =@Emp_ID 
									and For_Date = @Temp_Month_Date Group by Emp_ID,For_Date) m
								on e.Emp_ID = M.Emp_ID and E.For_Date = M.For_Date
								Where E.Emp_ID =@Emp_ID and E.For_Date = @Temp_Month_Date
								group by Reason,Max_In								
							
						End
					 
					End
			Else
				Begin
					 	Begin
							  Declare cur_Inout cursor for       
							   select In_time,Out_Time,Reason from dbo.T0150_emp_inout_record WITH (NOLOCK) Where Emp_ID =@Emp_ID and For_Date = @Temp_Month_Date      
								order by isnull(In_time,Out_time),Out_time,Reason      
						End
				End
      open cur_inout      
      Fetch next from cur_inout  into @Insert_In_Date,@Insert_Out_Date,@Reason      
      while @@fetch_Status = 0      
       begin      
          set @working_sec = 0      
          set @Ot_sec = 0      
          set @holiday_work_sec = 0      
          set @Late_In = ''      
          set @Late_Out =''      
          set @Early_In = ''      
          set @Early_Out = ''      
          SET @WORKING_HOURS = ''      
          SET @INSERT_COUNT = 0      
                
          set @Late_In_sec = 0      
          set @Late_Out_Sec = 0      
          set @Early_In_sec = 0      
          set @Early_Out_sec = 0      
          set @Toatl_Working_sec = 0      
          set @Less_Work = ''      
          set @More_Work = ''      
          set @Total_work = ''      
          set @late_in_count = 0      
          set @Early_Out_Count = 0      
          set @Total_less_work_sec = 0      
          Set @Total_More_work_sec = 0

                
          set @Working_sec = datediff(s,@Insert_In_Date,@Insert_Out_Date)      

          if datediff(s,@Insert_In_Date,@Shift_St_Datetime) > 0       
           set @Early_In_Sec = datediff(s,@Insert_In_Date,@Shift_St_Datetime)      
          if datediff(s,@Insert_In_Date,@Shift_St_Datetime) < 0       
           set @late_In_Sec = datediff(s,@Insert_In_Date,@Shift_St_Datetime)      
          if datediff(s,@Insert_Out_Date,@Shift_End_Datetime) > 0       
           set @Early_Out_Sec = datediff(s,@Insert_Out_Date,@Shift_End_Datetime)      
          if datediff(s,@Insert_Out_Date,@Shift_End_Datetime) < 0       
           set @Late_Out_Sec = datediff(s,@Insert_Out_Date,@Shift_End_Datetime)      
      
          set @late_In_Sec  = @late_In_Sec * -1      
          set @Late_Out_Sec  = @Late_Out_Sec * -1      

		 
          if @Late_Comm_sec >=  @late_in_sec   set @late_in_sec  = 0      
          if @Late_Comm_sec >=  @late_out_sec  set @late_out_sec  = 0      
          if @Early_Limit_sec >=  @Early_In_Sec  set @Early_In_Sec  = 0      
          if @Early_Limit_sec >=  @Early_Out_Sec set  @Early_Out_Sec  = 0      
                
          if @late_in_sec  > 0  exec dbo.Return_DurHourMin  @late_In_Sec ,@late_In output       
          if @late_out_sec > 0  exec dbo.Return_DurHourMin  @late_Out_Sec ,@late_Out output       
                
          if @Early_In_Sec  > 0 exec dbo.Return_DurHourMin  @Early_In_Sec ,@Early_In output       
          if @Early_Out_Sec > 0 exec dbo.Return_DurHourMin  @Early_Out_Sec ,@Early_Out output       
          if @Working_sec > 0 exec dbo.Return_DurHourMin  @Working_Sec ,@WORKING_HOURS output        
   
          set @Toatl_Working_sec = isnull(@Toatl_Working_sec,0) + @Working_sec      
           
			Declare @DeduHour_SecondBreak as tinyint
			Declare @DeduHour_ThirdBreak as tinyint
			Declare @S_St_Time as varchar(10)      
			Declare @S_End_Time as varchar(10)     
			Declare @T_St_Time as varchar(10)      
			Declare @T_End_Time as varchar(10)     
			Declare @Shift_S_ST_DateTime as datetime
			Declare @Shift_S_End_DateTime as datetime      
			Declare @Shift_T_ST_DateTime as datetime     
			Declare @Shift_T_End_DateTime as datetime      
			Declare @Shift_Max_Outtime as Datetime
			
			
			Select @DeduHour_SecondBreak = DeduHour_SecondBreak,@DeduHour_ThirdBreak = DeduHour_ThirdBreak ,@S_St_Time=S_St_Time,@S_End_Time=S_End_Time,@T_St_Time=T_St_Time,@T_End_Time=T_End_Time
			From dbo.T0040_SHIFT_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID And Shift_ID=@SHIFT_ID
				
			Set @Shift_S_ST_DateTime = cast(cast(@Temp_Month_Date as varchar(11)) + ' ' + @S_St_Time as smalldatetime)
			Set @Shift_S_End_DateTime = cast(cast(@Temp_Month_Date as varchar(11)) + ' ' + @S_End_Time as smalldatetime)
			Set @Shift_T_ST_DateTime = cast(cast(@Temp_Month_Date as varchar(11)) + ' ' + @T_St_Time as smalldatetime)
			Set @Shift_T_End_DateTime = cast(cast(@Temp_Month_Date as varchar(11)) + ' ' + @T_End_Time as smalldatetime)


			IF @DeduHour_SecondBreak = 1 And  @DeduHour_ThirdBreak = 1 
	   			Begin	   	
	   				If @DeduHour_SecondBreak = 1 And @Insert_In_Date < @Shift_S_ST_DateTime And @Insert_Out_DATE > @Shift_S_ST_DateTime
						Begin
				 			set @Toatl_Working_sec = @Toatl_Working_sec - @Second_Break_Duration_Sec
						End

					If @DeduHour_ThirdBreak = 1 And @Insert_In_Date < @Shift_T_ST_DateTime And @Insert_Out_DATE > @Shift_T_ST_DateTime
						Begin
							set @Toatl_Working_sec = @Toatl_Working_sec - @Third_Break_Duration_Sec	
						End
				End	
			Else IF @DeduHour_SecondBreak = 1 And @Insert_In_Date < @Shift_S_ST_DateTime And @Insert_Out_DATE > @Shift_S_ST_DateTime
				Begin
		 			set @Toatl_Working_sec = @Toatl_Working_sec - @Second_Break_Duration_Sec
				End
			Else IF @DeduHour_ThirdBreak = 1 And @Insert_In_Date < @Shift_T_ST_DateTime And @Insert_Out_DATE > @Shift_T_ST_DateTime
				Begin
					set @Toatl_Working_sec = @Toatl_Working_sec - @Third_Break_Duration_Sec
				End
			            
          if @Toatl_Working_sec > 0 exec dbo.Return_DurHourMin  @Toatl_Working_sec ,@Total_work output         
                
          if @Insert_IN_Date > @Shift_End_datetime      
           begin      
            set @Working_Sec_AfterShift   =  @Working_sec + @Working_Sec_AfterShift      
            set @Working_AfterShift_Count =  1      
           end      
       
			Declare @OT_Start_ShiftEnd_Time as varchar(10)
			Declare @OT_Start_ShiftStart_Time as varchar(10)
			  Set @OT_Start_ShiftEnd_Time = ''	
			  Set @OT_Start_ShiftStart_Time = ''
			  
			Select @OT_Start_ShiftStart_Time=OT_Start_Time, @OT_Start_ShiftEnd_Time = OT_End_Time from T0050_SHIFT_DETAIL WITH (NOLOCK) where Cmp_ID=@Cmp_ID And Shift_ID=@SHIFT_ID	
	
		    IF @OT_Start_ShiftStart_Time = 1
				Begin
					Declare @OT_Start_ShiftStart_Sec numeric
	
					if datediff(s,@Insert_In_Date,@Shift_ST_DateTime) > 0       
						Begin
							set @OT_Start_ShiftStart_Sec = datediff(s,@Insert_In_Date,@Shift_ST_DateTime)
						 
							Set @Toatl_Working_sec = @Toatl_Working_sec - @OT_Start_ShiftStart_Sec
						
						End
				End

		    IF @DeduHour_SecondBreak = 0 And @DeduHour_ThirdBreak = 0
				Set @Diff_Sec  = @Toatl_Working_sec -  @Shift_Sec
			  IF @DeduHour_SecondBreak = 1 And @DeduHour_ThirdBreak = 0
				Set @Diff_Sec  = @Toatl_Working_sec -  @Shift_Sec --+ @Second_Break_Duration_Sec
			  IF @DeduHour_ThirdBreak = 1  And @DeduHour_SecondBreak = 0
				Set @Diff_Sec  = @Toatl_Working_sec -  @Shift_Sec  --+ @Third_Break_Duration_Sec
			  IF @DeduHour_SecondBreak = 1 And @DeduHour_ThirdBreak = 1
				Set @Diff_Sec  = @Toatl_Working_sec -  @Shift_Sec --+ @Second_Break_Duration_Sec  + @Third_Break_Duration_Sec

			Set @Toatl_Working_sec = @Toatl_Working_sec + Isnull(@OT_Start_ShiftStart_Sec,0)
			
			IF @OT_Start_ShiftEnd_Time = 1
				Begin
					Declare @OT_Start_ShiftEnd_Sec numeric      
					Set @OT_Start_ShiftEnd_Sec = 0

					If @First_In_Last_Out_For_InOut_Calculation = 1
						Begin					
							if datediff(s,@Insert_Out_Date,@Shift_End_Datetime) < 0  
								Begin     
									set @OT_Start_ShiftEnd_Sec = datediff(s,@Shift_End_Datetime,@Insert_Out_Date)
								End
						End
					Else
						Begin

							Select @OT_Start_ShiftEnd_Sec = SUM(Diff_Sec) From (
							Select Case When Row = 1 then
								DATEDIFF(s,@Shift_End_Datetime,Out_Time)
							 Else 
								DATEDIFF(s,In_Time,Out_Time)
							 End as Diff_Sec From 
							(select ROW_NUMBER() 
									OVER (ORDER BY IO_Tran_Id) AS Row, 
									* from T0150_EMP_INOUT_RECORD WITH (NOLOCK) where Emp_ID = @Emp_ID
							and (In_Time >= @Shift_End_Datetime or Out_Time >= @Shift_End_Datetime)
							and For_Date = @Temp_Month_Date And Emp_ID = @Emp_ID) as Qry) as Qry1						
						End
					
						If @OT_Start_ShiftEnd_Sec > 0
							set @Diff_Sec = @OT_Start_ShiftEnd_Sec	
						Else
							set @Diff_Sec = 0
				
				End
		 
   declare @WeekDay varchar(10)  
   declare @HalfStartTime varchar(10)  
   declare @HalfEndTime varchar(10)  
   declare @HalfDuration varchar(10)  
   declare @HalfDayDate varchar(500)  
   declare @curForDate datetime  
   declare @HalfMinDuration varchar(10)  
   declare @HalfStartDateTime datetime  
   declare @HalfEndDateTime datetime  
     
   
   exec dbo.GET_HalfDay_Date @Cmp_ID,@Emp_ID,@From_Date,@To_Date,0,@HalfDayDate output  
   select @WeekDay=SM.Week_Day,@HalfStartTime=SM.Half_St_Time,@HalfEndTime=SM.Half_End_Time,@HalfDuration=SM.Half_Dur,@HalfMinDuration=SM.Half_min_duration from dbo.T0040_SHIFT_MASTER SM WITH (NOLOCK) inner join           
        (select distinct Shift_ID from #Emp_Inout ) q on SM.Shift_ID =  q.shift_ID          
     where Is_Half_Day = 1   
      
   set @HalfStartDateTime = cast(cast(@Temp_Month_Date as varchar(11)) + ' ' + @HalfStartTime as smalldatetime)      
         set @HalfEndDateTime = cast(cast(@Temp_Month_Date as varchar(11)) + ' ' + @HalfEndTime  as smalldatetime)      
        
  
   if(charindex(CONVERT(nvarchar(11),@Insert_In_Date,109),@HalfDayDate) > 0)  
    begin      
     set @Diff_Sec  = @Toatl_Working_sec -  dbo.F_Return_Sec(@HalfDuration)      
  
      set @Late_In_sec = 0      
      set @Late_Out_Sec = 0      
      set @Early_In_sec = 0      
      set @Early_Out_sec = 0    
            
      if datediff(s,@Insert_In_Date,@HalfStartDateTime) > 0       
       set @Early_In_Sec = datediff(s,@Insert_In_Date,@HalfStartDateTime)      
      if datediff(s,@Insert_In_Date,@HalfStartDateTime) < 0       
       set @late_In_Sec = datediff(s,@Insert_In_Date,@HalfStartDateTime)      
      if datediff(s,@Insert_Out_Date,@HalfEndDateTime) > 0       
       set @Early_Out_Sec = datediff(s,@Insert_Out_Date,@HalfEndDateTime)      
      if datediff(s,@Insert_Out_Date,@HalfEndDateTime) < 0       
       set @Late_Out_Sec = datediff(s,@Insert_Out_Date,@HalfEndDateTime)      
  
        
      set @late_In_Sec  = @late_In_Sec * -1      
      set @Late_Out_Sec  = @Late_Out_Sec * -1      
 
      if @Late_Comm_sec >=  @late_in_sec   set @late_in_sec  = 0      
      if @Late_Comm_sec >=  @late_out_sec  set @late_out_sec  = 0      
      if @Early_Limit_sec >=  @Early_In_Sec  set @Early_In_Sec  = 0      
      if @Early_Limit_sec >=  @Early_Out_Sec set  @Early_Out_Sec  = 0      
                  
      if @late_in_sec  > 0  exec dbo.Return_DurHourMin  @late_In_Sec ,@late_In output       
      if @late_out_sec > 0  exec dbo.Return_DurHourMin  @late_Out_Sec ,@late_Out output       
                  
      if @Early_In_Sec  > 0 exec dbo.Return_DurHourMin  @Early_In_Sec ,@Early_In output       
      if @Early_Out_Sec > 0 exec dbo.Return_DurHourMin  @Early_Out_Sec ,@Early_Out output       
      if @Working_sec > 0 exec dbo.Return_DurHourMin  @Working_Sec ,@WORKING_HOURS output    
    end         
 
 	If @Diff_Sec < 0
			Begin  
				Set @Diff_Sec = @Diff_Sec * -1
				Exec dbo.Return_Without_Sec @Diff_Sec,@Diff_Sec Output
				Set @Diff_Sec = @Diff_Sec * -1
			End
		Else
			begin
				Exec dbo.Return_Without_Sec @Diff_Sec,@Diff_Sec Output
			End

		if  @Diff_Sec > 0  And @Diff_Sec > @Emp_OT_Min_Limit_Sec And (@Emp_OT = 1 or @Monthly_Deficit_Adjust_OT_Hrs = 1)
			Begin
				If @Diff_Sec < @Emp_OT_Max_Limit_Sec or @Emp_OT_Max_Limit_Sec = 0
					Begin
						exec dbo.Return_DurHourMin @Diff_Sec , @More_Work output  
						set @Total_More_work_sec = @Diff_Sec      
					End
				Else
					Begin
						exec dbo.Return_DurHourMin @Emp_OT_Max_Limit_Sec , @More_Work output  
						set @Total_More_work_sec = @Emp_OT_Max_Limit_Sec      
					End
					
			End
		else if @Diff_Sec <  0 and @Toatl_Working_sec > 0 And (@Emp_OT = 1 or @Monthly_Deficit_Adjust_OT_Hrs = 1)     
			begin      
				set @Diff_Sec = @Diff_Sec * -1      
				set @Total_Less_Work_Sec = @Diff_Sec      
				exec dbo.Return_DurHourMin @Diff_Sec , @less_Work output       
				
			end       
      
          if @late_in_Sec > 0       
           set @Late_in_count =1       
          if @Early_Out_Sec > 0      
           set @Early_Out_Count = 1       
    
       if @working_sec > @Shift_Sec  
    Begin    
     set  @working_sec=@Shift_Sec    
     set  @working_Hours=dbo.F_Return_Hours(@working_sec)          
    End  
      
			If Upper(@Country_Name) = 'PAKISTAN'
				Begin
					Declare @Chk_by_Superior as tinyint
					Declare @Half_Full_Day as varchar(30)
					Declare @Is_Cancel_Late_In as tinyint
					Declare @Is_Cancel_Early_Out as tinyint
					
					Set @Chk_by_Superior =0
					Set @Half_Full_Day =''
					Set @Is_Cancel_Late_In =0
					Set @Is_Cancel_Early_Out =0
					
					Select @Chk_by_Superior = Isnull(Chk_by_Superior,0), @Half_Full_Day = Isnull(Half_Full_Day,''),
						@Is_Cancel_Late_In = Isnull(Is_Cancel_Late_In,0), @Is_Cancel_Early_Out= Isnull(Is_Cancel_Early_Out,0)
					From dbo.T0150_EMP_INOUT_RECORD WITH (NOLOCK) Where In_Time = @Insert_IN_DATE And Emp_ID = @Emp_ID
				
					If @Chk_by_Superior = 1
						Begin
							If @Half_Full_Day = 'Full Day'
								Begin
									Set @Insert_IN_DATE =''
									Set @Insert_Out_DATE = ''
									Set @working_Hours = @Shift_Dur
									Set @working_sec = @Shift_Sec
									Set @Total_Work = @Shift_Dur
									Set @Toatl_Working_sec = @Shift_Sec
									Set @Less_Work = '-'
									Set @Total_less_work_sec = 0
									Set @More_Work = '-'
									Set @Total_More_work_sec = 0
								End
							Else if @Half_Full_Day = 'First Half' or @Half_Full_Day = 'Second Half'
								Begin
									Set @Insert_IN_DATE =''
									Set @Insert_Out_DATE = ''
									Set @working_Hours = dbo.F_Return_Hours(@Shift_Sec/2)
									Set @working_sec = @Shift_Sec/2
									Set @Total_Work = dbo.F_Return_Hours(@Shift_Sec/2)
									Set @Toatl_Working_sec = @Shift_Sec/2
									Set @Less_Work = '-'
									Set @Total_less_work_sec = 0
									Set @More_Work = '-'
									Set @Total_More_work_sec = 0
								End
							
							If @Is_Cancel_Late_In = 1 
								Begin
									Set @Late_In =''
									Set @Late_In_Sec = 0
									Set @Late_In_Count = 0
								End

							If @Is_Cancel_Early_Out = 1 
								Begin
									Set @Early_Out =''
									Set @Early_Out_Sec = 0
									Set @Early_out_count = 0
								End
							
						End
					End
			 
    if exists(select EI.Emp_ID  from #Emp_Inout as EI  where EI.Emp_ID = @Emp_ID   
      and EI.For_DAte = @temp_Month_DAte )  
    begin  
     select @Toatl_Working_sec = isnull(sum(Duration_Sec) ,0)  
     from #Emp_Inout as EI  where EI.Emp_ID = @Emp_ID   
      and EI.For_DAte = @temp_Month_DAte  
     
     select @Working_Sec_AfterShift = isnull(sum(Working_Sec_AfterShift) ,0)  
     from #Emp_Inout as EI  where EI.Emp_ID = @Emp_ID   
      and EI.For_DAte = @temp_Month_DAte  
      and EI.In_Time >= @Shift_End_datetime  
       
      set @Toatl_Working_sec = isnull(@Toatl_Working_sec,0) + @Working_sec      
	  
	     
  			Declare @Min_In_Time as Datetime
			select @Min_In_Time = MIN(In_Time) from #Emp_Inout as EI where EI.Emp_ID = @Emp_ID   
			  and EI.For_DAte = @temp_Month_Date 

			Select @DeduHour_SecondBreak = DeduHour_SecondBreak,@DeduHour_ThirdBreak = DeduHour_ThirdBreak ,@S_St_Time=S_St_Time,@S_End_Time=S_End_Time,@T_St_Time=T_St_Time,@T_End_Time=T_End_Time
			From dbo.T0040_SHIFT_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID And Shift_ID=@SHIFT_ID
				
			Set @Shift_S_ST_DateTime = cast(cast(@Temp_Month_Date as varchar(11)) + ' ' + @S_St_Time as smalldatetime)
			Set @Shift_S_End_DateTime = cast(cast(@Temp_Month_Date as varchar(11)) + ' ' + @S_End_Time as smalldatetime)
			Set @Shift_T_ST_DateTime = cast(cast(@Temp_Month_Date as varchar(11)) + ' ' + @T_St_Time as smalldatetime)
			Set @Shift_T_End_DateTime = cast(cast(@Temp_Month_Date as varchar(11)) + ' ' + @T_End_Time as smalldatetime)

			IF @DeduHour_SecondBreak = 1 And  @DeduHour_ThirdBreak = 1 
	   			Begin
			   	
	   				If @DeduHour_SecondBreak = 1 And @Min_In_Time <= @Shift_S_ST_DateTime And @Insert_Out_DATE > @Shift_S_ST_DateTime
						Begin
				 			set @Toatl_Working_sec = @Toatl_Working_sec - @Second_Break_Duration_Sec
						End

					If @DeduHour_ThirdBreak = 1 And @Min_In_Time <= @Shift_T_ST_DateTime And @Insert_Out_DATE > @Shift_T_ST_DateTime
						Begin
							set @Toatl_Working_sec = @Toatl_Working_sec - @Third_Break_Duration_Sec	
						End
				End	
			Else IF @DeduHour_SecondBreak = 1 And @Min_In_Time <= @Shift_S_ST_DateTime And @Insert_Out_DATE > @Shift_S_ST_DateTime
				Begin
		 			set @Toatl_Working_sec = @Toatl_Working_sec - @Second_Break_Duration_Sec
				End
			Else IF @DeduHour_ThirdBreak = 1 And @Min_In_Time <= @Shift_T_ST_DateTime And @Insert_Out_DATE > @Shift_T_ST_DateTime
				Begin
					set @Toatl_Working_sec = @Toatl_Working_sec - @Third_Break_Duration_Sec
				End
		 
      if @Toatl_Working_sec > 0 exec dbo.Return_DurHourMin  @Toatl_Working_sec ,@Total_work output         
   
  		IF @OT_Start_ShiftEnd_Time = 1
			Begin
					Set @OT_Start_ShiftEnd_Sec = 0

					If @First_In_Last_Out_For_InOut_Calculation = 1
						Begin					
							if datediff(s,@Insert_Out_Date,@Shift_End_Datetime) < 0  
								Begin     
									set @OT_Start_ShiftEnd_Sec = datediff(s,@Shift_End_Datetime,@Insert_Out_Date)
								End
						End
					Else
						Begin

							Select @OT_Start_ShiftEnd_Sec = SUM(Diff_Sec) From (
							Select Case When Row =1 then
								DATEDIFF(s,@Shift_End_Datetime,Out_Time)
							 Else 
								DATEDIFF(s,In_Time,Out_Time)
							 End as Diff_Sec From 
							(select ROW_NUMBER() 
									OVER (ORDER BY IO_Tran_Id) AS Row, 
									* from T0150_EMP_INOUT_RECORD WITH (NOLOCK) where Emp_ID = @Emp_ID
							and (In_Time >= @Shift_End_Datetime or Out_Time >= @Shift_End_Datetime)
							and For_Date = @Temp_Month_Date And Emp_ID = @Emp_ID) as Qry) as Qry1						
						End
					
						If @OT_Start_ShiftEnd_Sec > 0
							set @Diff_Sec = @OT_Start_ShiftEnd_Sec	- @OT_Start_ShiftStart_Sec
						Else
							set @Diff_Sec = 0
			End
		Else
			Set @Diff_Sec  = @Toatl_Working_sec -  @Shift_Sec - @OT_Start_ShiftStart_Sec	
	   	
		If @Diff_Sec < 0
			Begin  
				Set @Diff_Sec = @Diff_Sec * -1
				Exec dbo.Return_Without_Sec @Diff_Sec,@Diff_Sec Output
				Set @Diff_Sec = @Diff_Sec * -1
			End
		Else
			begin
				Exec dbo.Return_Without_Sec @Diff_Sec,@Diff_Sec Output
			End


		if  @Diff_Sec > 0 And @Diff_Sec > @Emp_OT_Min_Limit_Sec And (@Emp_OT = 1 or @Monthly_Deficit_Adjust_OT_Hrs = 1)
			Begin
				If @Diff_Sec < @Emp_OT_Max_Limit_Sec or @Emp_OT_Max_Limit_Sec = 0
					Begin
						exec dbo.Return_DurHourMin @Diff_Sec , @More_Work output  
						set @Total_More_work_sec = @Diff_Sec      
						Set @less_Work = ''
					End
				Else
					Begin
						exec dbo.Return_DurHourMin @Emp_OT_Max_Limit_Sec , @More_Work output  
						set @Total_More_work_sec = @Emp_OT_Max_Limit_Sec      
						Set @less_Work = ''
					End
			End
		else if @Diff_Sec <  0 and @Toatl_Working_sec > 0  And (@Emp_OT = 1 or @Monthly_Deficit_Adjust_OT_Hrs = 1)    
			begin      
				set @Diff_Sec = @Diff_Sec * -1      
				set @Total_Less_Work_Sec = @Diff_Sec      
				exec dbo.Return_DurHourMin @Diff_Sec , @less_Work output       
				Set @More_Work = ''
			end       
		 
		Else if @Diff_Sec = 0
			Begin
				Set @less_Work = ''
				Set @More_Work = ''
			end
  
     update #Emp_Inout     
     set Late_out = ''  
     ,   Early_Out = ''  
     , Total_Work = ''  
     , less_work = ''  
     , More_work = ''  
     , Early_Out_sec = 0  
     , Total_Less_work_sec = 0  
     , Total_More_work_Sec = 0
     , Early_Out_count = 0 
     ,Total_Work_Sec =0 
     where Emp_ID = @emp_Id and For_Date = @temp_month_Date  
       
    end   
                   INSERT INTO #Emp_Inout (Emp_id,For_Date , Dept_id ,Grd_ID,Type_ID,Desig_ID ,Shift_ID,In_Time ,Out_Time ,Duration ,      
     Duration_sec  , Late_In ,Late_Out , Early_In , Early_Out , Leave ,Shift_Sec,Shift_Dur,Total_Work,Less_Work,More_work,Reason,Late_in_sec,Early_Out_sec,Total_Less_work_sec,Late_in_Count,Early_Out_count,Shift_St_Datetime,Shift_en_Datetime      
            ,Working_Sec_AfterShift,Working_AfterShift_Count,Inout_Reason,Total_Work_Sec,Late_Out_Sec,Early_In_sec,Total_More_work_Sec, Is_OT_Applicable,Monthly_Deficit_Adjust_OT_Hrs,Late_Comm_sec,Branch_Id )          
          VALUES (@emp_id ,@Temp_Month_Date ,@Dept_id ,@Grd_ID ,@Type_ID,@Desig_ID,@Shift_ID,@Insert_IN_DATE ,@Insert_Out_DATE ,@working_Hours ,      
            @working_sec  , @late_In ,@late_Out , @Early_In , @Early_Out , '',@Shift_Sec,@Shift_Dur,@Total_Work,@Less_Work,@More_work,@Reason,@late_in_sec,@Early_Out_Sec,@Total_less_work_sec,@Late_in_Count,@Early_Out_count,@Shift_St_Time,@Shift_End_Time  -- @Pre_Shift_St_dateTime,@Pre_Shift_En_dateTime   change by rohit for shift start time and end time on 03-aug-2012
            ,@Working_Sec_AfterShift,@Working_AfterShift_Count,@Reason,isnull(@Toatl_Working_sec,0),isnull(@Late_Out_Sec,0),isnull(@Early_In_Sec,0),Isnull(@Total_More_work_Sec,0),@Emp_OT,@Monthly_Deficit_Adjust_OT_Hrs,@Late_comm_sec,@Branch_Id_Cur )

  
    ---Hardik for Total Work show only in Late in row (if Multiple In-Out Entries)  
    if exists(select EI.Emp_ID  from #Emp_Inout as EI  where EI.Emp_ID = @Emp_ID   
      and EI.For_DAte = @temp_Month_DAte )  
    begin  
     Declare @Late_In_N as varchar(10)  
       
     select top(1) @Late_In_N = Late_In from #Emp_Inout as EI where EI.Emp_ID = @Emp_ID   
      and EI.For_DAte = @temp_Month_DAte 
      
       
     If @Late_In_N <> '' or @Late_In_N <> '00:00'  
      Begin  
       update #Emp_Inout set   
       Late_In = '',Late_In_Sec = 0,Late_In_count=0  
       where Emp_ID = @emp_Id and For_Date = @temp_month_Date  and Late_In <> @Late_In_N
      End  
    end   
   
    set @Min_In_Time = ''
     select @Min_In_Time = MIN(In_Time) from #Emp_Inout as EI where EI.Emp_ID = @Emp_ID   
      and EI.For_DAte = @temp_Month_Date 
       
		update #Emp_Inout set   
		Late_In = '',Late_In_Sec = 0,Late_In_count=0  
		where Emp_ID = @emp_Id and For_Date = @temp_month_Date And In_Time <> @Min_In_Time
                             
         Fetch next from cur_inout  into @Insert_In_Date,@Insert_Out_Date,@Reason     
       end      
      close cur_Inout      
      Deallocate cur_inout     
  
  if charindex(cast(@Temp_Month_Date as varchar(11)),@StrHoliday_Date,0) > 0   
   begin  
    set @Weekoff_Entry = @Weekoff_Entry  
  
    If not exists (Select 1 From #Emp_Inout Where emp_id = @Emp_ID And for_Date = @Temp_Month_Date)  
     Begin  
      INSERT INTO #Emp_Inout   
       (Emp_id,For_Date , Dept_id ,Grd_ID,Type_ID,Desig_ID ,Shift_ID,In_Time ,Out_Time ,Duration ,      
       Duration_sec  , Late_In ,Late_Out , Early_In , Early_Out , Leave ,Shift_Sec,Shift_Dur,Total_Work,Less_Work,More_work,Reason,Late_in_sec,Early_Out_sec,Total_Less_work_sec,Late_in_Count,Early_Out_count,Shift_St_Datetime,Shift_en_Datetime      
       ,Working_Sec_AfterShift,Working_AfterShift_Count,Inout_Reason,AB_LEAVE,Total_More_work_Sec,Is_OT_Applicable,Monthly_Deficit_Adjust_OT_Hrs,Late_Comm_sec,Branch_Id )   
      VALUES   
       (@emp_id ,@Temp_Month_Date ,@Dept_id ,@Grd_ID ,@Type_ID,@Desig_ID,@Shift_ID,Null,Null ,'-',      
        0, '-' ,'-', '-', '-', '',0,'-','-','-','-','-',0,0,0,0,0,Null,Null 
       ,0,0,'-','HO',0,@Emp_OT,@Monthly_Deficit_Adjust_OT_Hrs,@Late_Comm_sec,@Branch_Id_Cur )      
     End  
    Else  
     Begin  
		If @Emp_OT = 1
			Update #Emp_Inout Set AB_LEAVE = 'HO', Total_More_work_Sec = Total_Work_Sec, More_Work = Total_work,Shift_Sec = 0 Where emp_id = @Emp_ID And for_Date = @Temp_Month_Date  
		Else
			Update #Emp_Inout Set AB_LEAVE = 'HO',Shift_Sec = 0 Where emp_id = @Emp_ID And for_Date = @Temp_Month_Date
     End  
   end   
  else if charindex(cast(@Temp_Month_Date as varchar(11)),@StrWeekoff_Date,0) > 0   
   begin  
    set @Weekoff_Entry = @Weekoff_Entry  
    If not exists (Select 1 From #Emp_Inout Where emp_id = @Emp_ID And for_Date = @Temp_Month_Date)  
     Begin  
      INSERT INTO #Emp_Inout   
       (Emp_id,For_Date , Dept_id ,Grd_ID,Type_ID,Desig_ID ,Shift_ID,In_Time ,Out_Time ,Duration ,      
       Duration_sec  , Late_In ,Late_Out , Early_In , Early_Out , Leave ,Shift_Sec,Shift_Dur,Total_Work,Less_Work,More_work,Reason,Late_in_sec,Early_Out_sec,Total_Less_work_sec,Late_in_Count,Early_Out_count,Shift_St_Datetime,Shift_en_Datetime      
       ,Working_Sec_AfterShift,Working_AfterShift_Count,Inout_Reason,AB_LEAVE,Total_More_work_Sec,Is_OT_Applicable,Monthly_Deficit_Adjust_OT_Hrs,Late_Comm_sec,Branch_Id  )      
      VALUES   
       (@emp_id ,@Temp_Month_Date ,@Dept_id ,@Grd_ID ,@Type_ID,@Desig_ID,@Shift_ID,Null,Null ,'-',      
        0, '-' ,'-', '-', '-', '',0,'-','-','-','-','-',0,0,0,0,0,Null,Null   
       ,0,0,'-','WO',0,@Emp_OT,@Monthly_Deficit_Adjust_OT_Hrs,@Late_Comm_sec,@Branch_Id_Cur  )      
     End  
    Else  
     Begin  
		If @Emp_OT = 1
			Update #Emp_Inout Set AB_LEAVE = 'WO', Total_More_work_Sec = Total_Work_Sec, More_Work = Total_work, Total_Less_work_Sec = 0,Less_Work = '',Shift_Sec = 0 Where emp_id = @Emp_ID And for_Date = @Temp_Month_Date  
		else
			Update #Emp_Inout Set AB_LEAVE = 'WO',Shift_Sec = 0 Where emp_id = @Emp_ID And for_Date = @Temp_Month_Date  
     End  
	End  
  Else If exists (Select 1 From dbo.T0120_LEAVE_APPROVAL LA WITH (NOLOCK) Inner Join   
       dbo.T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) On LA.Leave_Approval_ID = LAD.Leave_Approval_ID  
       Where From_Date <= @Temp_Month_Date And To_Date >= @Temp_Month_Date And Emp_ID = @Emp_ID And LA.Approval_Status = 'A'
	   and LA.Leave_Approval_ID  not In (select Leave_Approval_ID from dbo.T0150_LEAVE_CANCELLATION LC WITH (NOLOCK) where  LC.cmp_id=@Cmp_ID and LC.Emp_ID = @Emp_ID and LC.For_Date = @Temp_Month_Date and LC.Is_Approve=1) )  
   Begin  
  
     Select @Leave_ID = Leave_ID, @Leave_Reason = Leave_Reason, @Leave_Period = Leave_Period,@Half_Leave_Date = Half_Leave_Date, @Leave_Assign_As = Leave_Assign_As
     From dbo.T0120_LEAVE_APPROVAL LA WITH (NOLOCK) Inner Join   
       dbo.T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) On LA.Leave_Approval_ID = LAD.Leave_Approval_ID  
       Where From_Date <= @Temp_Month_Date And To_Date >= @Temp_Month_Date And Emp_ID = @Emp_ID And LA.Approval_Status = 'A'
	   and LA.Leave_Approval_ID  not In (select Leave_Approval_ID from dbo.T0150_LEAVE_CANCELLATION LC WITH (NOLOCK) where  LC.cmp_id=@Cmp_ID and LC.Emp_ID = @Emp_ID and LC.For_Date = @Temp_Month_Date and LC.Is_Approve=1)


     Select @Leave_Name = Leave_Code From dbo.T0040_LEAVE_MASTER WITH (NOLOCK) Where Leave_ID = @Leave_ID  
     
	If not exists (Select 1 From #Emp_Inout Where emp_id = @Emp_ID And for_Date = @Temp_Month_Date)  
		Begin
		
			If Upper(@Country_Name) <> 'PAKISTAN'
				Begin
					 INSERT INTO #Emp_Inout   
					  (Emp_id,For_Date , Dept_id ,Grd_ID,Type_ID,Desig_ID ,Shift_ID,In_Time ,Out_Time ,Duration ,      
					  Duration_sec  , Late_In ,Late_Out , Early_In , Early_Out , Leave ,Shift_Sec,Shift_Dur,Total_Work,Less_Work,More_work,Reason,Late_in_sec,Early_Out_sec,Total_Less_work_sec,Late_in_Count,Early_Out_count,Shift_St_Datetime,Shift_en_Datetime      
					  ,Working_Sec_AfterShift,Working_AfterShift_Count,Inout_Reason,AB_LEAVE,Total_More_work_Sec,Is_OT_Applicable,Monthly_Deficit_Adjust_OT_Hrs,Late_Comm_sec,Branch_Id )      
					 VALUES   
					  (@emp_id ,@Temp_Month_Date ,@Dept_id ,@Grd_ID ,@Type_ID,@Desig_ID,@Shift_ID,Null,Null ,'-',      
					   0, '-' ,'-', '-', '-', @Leave_Name,@Shift_Sec,@Shift_Dur,'-','-','-',@Leave_Reason,0,0,0,0,0,@Shift_St_Time,@Shift_End_Time -- Null,Null -- comment and add by rohit for shift time on 06-aug-2012   
					  ,0,0,'-',@Leave_Name,0,@Emp_OT,@Monthly_Deficit_Adjust_OT_Hrs,@Late_Comm_sec,@Branch_Id_Cur  )      
				End
			Else
				If @Leave_Assign_As = 'Full Day'
					Begin
						 INSERT INTO #Emp_Inout   
						  (Emp_id,For_Date , Dept_id ,Grd_ID,Type_ID,Desig_ID ,Shift_ID,In_Time ,Out_Time ,Duration ,      
						  Duration_sec  , Late_In ,Late_Out , Early_In , Early_Out , Leave ,Shift_Sec,Shift_Dur,Total_Work,Less_Work,More_work,Reason,Late_in_sec,Early_Out_sec,Total_Less_work_sec,Late_in_Count,Early_Out_count,Shift_St_Datetime,Shift_en_Datetime      
						  ,Working_Sec_AfterShift,Working_AfterShift_Count,Inout_Reason,AB_LEAVE,Total_More_work_Sec,Is_OT_Applicable,Monthly_Deficit_Adjust_OT_Hrs,Late_Comm_sec,Total_Work_Sec,Branch_Id)      
						 VALUES   
						  (@emp_id ,@Temp_Month_Date ,@Dept_id ,@Grd_ID ,@Type_ID,@Desig_ID,@Shift_ID,Null,Null ,'-',      
						   @Shift_Sec, '-' ,'-', '-', '-', @Leave_Name,@Shift_Sec,@Shift_Dur,@Shift_Dur,'-','-',@Leave_Reason,0,0,0,0,0,@Shift_St_Time,@Shift_End_Time -- Null,Null -- comment and add by rohit for shift time on 06-aug-2012   
						  ,0,0,'-',@Leave_Name,0,@Emp_OT,@Monthly_Deficit_Adjust_OT_Hrs,@Late_Comm_sec,@Shift_Sec,@Branch_Id_Cur  )      
					End
				Else
					Begin
						 INSERT INTO #Emp_Inout   
						  (Emp_id,For_Date , Dept_id ,Grd_ID,Type_ID,Desig_ID ,Shift_ID,In_Time ,Out_Time ,Duration ,      
						  Duration_sec  , Late_In ,Late_Out , Early_In , Early_Out , Leave ,Shift_Sec,Shift_Dur,Total_Work,Less_Work,More_work,Reason,Late_in_sec,Early_Out_sec,Total_Less_work_sec,Late_in_Count,Early_Out_count,Shift_St_Datetime,Shift_en_Datetime      
						  ,Working_Sec_AfterShift,Working_AfterShift_Count,Inout_Reason,AB_LEAVE,Total_More_work_Sec,Is_OT_Applicable,Monthly_Deficit_Adjust_OT_Hrs,Late_Comm_sec,Total_Work_Sec,Branch_Id)      
						 VALUES   
						  (@emp_id ,@Temp_Month_Date ,@Dept_id ,@Grd_ID ,@Type_ID,@Desig_ID,@Shift_ID,Null,Null ,'-',      
						   Case When @Half_Leave_Date = @Temp_Month_Date Then @Shift_Sec/2 Else @Shift_Sec End , '-' ,'-', '-', '-', @Leave_Name,@Shift_Sec,@Shift_Dur,Case When @Half_Leave_Date = @Temp_Month_Date Then dbo.F_Return_Hours(@Shift_Sec/2) Else @Shift_Dur End,'-','-',@Leave_Reason,0,0,0,0,0,@Shift_St_Time,@Shift_End_Time -- Null,Null -- comment and add by rohit for shift time on 06-aug-2012   
						  ,0,0,'-',@Leave_Name,0,@Emp_OT,@Monthly_Deficit_Adjust_OT_Hrs,@Late_Comm_sec,Case When @Half_Leave_Date = @Temp_Month_Date Then @Shift_Sec/2 Else @Shift_Sec End,@Branch_Id_Cur  )      
					End
		End
	Else
		Begin
			Update #Emp_Inout Set AB_LEAVE = @Leave_Name,Total_Less_work_Sec = 0,Less_Work = '',Total_More_work_Sec = 0, More_Work='' Where emp_id = @Emp_ID And for_Date = @Temp_Month_Date  			
		End
		
	End  
  else  
   begin  
    If not exists (Select 1 From #Emp_Inout Where emp_id = @Emp_ID And for_Date = @Temp_Month_Date)  
     Begin
     
		If @Temp_Month_Date >= @Join_Date And (@Temp_Month_Date <= @Left_Date or @Left_Date Is null)
			Begin
			  INSERT INTO #Emp_Inout
			   (Emp_id,For_Date , Dept_id ,Grd_ID,Type_ID,Desig_ID ,Shift_ID,In_Time ,Out_Time ,Duration ,      
			   Duration_sec  , Late_In ,Late_Out , Early_In , Early_Out , Leave ,Shift_Sec,Shift_Dur,Total_Work,Less_Work,More_work,Reason,Late_in_sec,Early_Out_sec,Total_Less_work_sec,Late_in_Count,Early_Out_count,Shift_St_Datetime,Shift_en_Datetime      
			   ,Working_Sec_AfterShift,Working_AfterShift_Count,Inout_Reason,AB_LEAVE,Total_More_work_Sec,Is_OT_Applicable,Monthly_Deficit_Adjust_OT_Hrs,Late_Comm_sec,Branch_Id )      
			  VALUES   
			   (@emp_id ,@Temp_Month_Date ,@Dept_id ,@Grd_ID ,@Type_ID,@Desig_ID,@Shift_ID,Null,Null ,'-',      
				0, '-' ,'-', '-', '-', '',@Shift_Sec,@Shift_Dur,'-',@Shift_Dur,'-','-',0,0,@Shift_Sec,0,0,@Shift_St_Time,@Shift_End_Time --Null,Null --comment and add by rohit for shift time on 06-aug-2012  
			   ,0,0,'-','AB',0,@Emp_OT,@Monthly_Deficit_Adjust_OT_Hrs,@Late_Comm_sec,@Branch_Id_Cur  )      
			End
     End  
   End  
     
      set @Temp_Month_Date = Dateadd(d,1,@Temp_Month_Date)       
    end       
   FETCH NEXT FROM CUR_EMP INTO @EMP_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Late_Comm_sec,@Early_Limit_Sec,@Emp_OT,@Emp_OT_Min_Limit_Sec,@Emp_OT_Max_Limit_Sec,@Monthly_Deficit_Adjust_OT_Hrs,@Branch_Id_Cur
  end      
 close cur_Emp      
 deallocate cur_Emp      
      


declare @curEmp_Id numeric
Declare @CurFor_Date Datetime
	
	Declare CusrCompanyMST cursor for	                  
	select Emp_id,For_Date from #Emp_Inout
	Open CusrCompanyMST
	Fetch next from CusrCompanyMST into @curEmp_Id,@CurFor_Date
	While @@fetch_status = 0                    
		Begin     
			declare @StrSetting as Varchar(100)
			
			if Exists(select emp_id from Emp_Inout_Temp where Emp_id=@curEmp_Id and For_date=@CurFor_Date)
			begin
			
				Update Emp_Inout_Temp
				set 			
				[Dept_id] =EI.[Dept_id],
				[Grd_ID] = EI.[Grd_ID],
				[Type_ID] = EI.[Type_ID],
				[Desig_ID] =EI.[Desig_ID],
				[Shift_ID] = EI.[Shift_ID],
				[In_Time] =EI.[In_Time] ,
				[Out_Time] = EI.[Out_Time],
				[Duration] = EI.[Duration],
				[Duration_sec] = EI.[Duration_sec] ,
				[Late_In]  = EI.[Late_In], 
				[Late_Out] = EI.[Late_Out],
				[Early_In] = EI.[Early_In],
				[Early_Out] = EI.[Early_Out], 
				[Leave] = EI.[Leave] ,
				[Shift_Sec] = EI.[Shift_Sec] ,
				[Shift_Dur] = EI.[Shift_Dur] ,
				[Total_work] = EI.[Total_work],
				[Less_Work] = EI.[Less_Work] ,
				[More_Work] = EI.[More_Work] ,
				[Reason] = EI.[Reason] ,
				[AB_LEAVE] = EI.[AB_LEAVE] ,
				[Late_In_Sec] = EI.[Late_In_Sec] ,
				[Late_In_count] = EI.[Late_In_count],
				[Early_Out_sec] = EI.[Early_Out_sec],
				[Early_Out_Count] = EI.[Early_Out_Count] ,
				[Total_Less_work_Sec] = EI.[Total_Less_work_Sec] ,
				[Shift_St_Datetime] = EI.[Shift_St_Datetime] ,
				[Shift_en_Datetime] = EI.[Shift_en_Datetime] ,
				[Working_Sec_AfterShift] = EI.[Working_Sec_AfterShift] ,
				[Working_AfterShift_Count] = EI.[Working_AfterShift_Count] ,
				[Leave_Reason] = EI.[Leave_Reason] ,
				[Inout_Reason] = EI.[Inout_Reason] ,
				[SysDate] = getdate(),
				[Total_Work_Sec] = EI.[Total_Work_Sec] ,
				[Late_Out_Sec] = EI.[Late_Out_Sec] ,
				[Early_In_sec] = EI.[Early_In_sec] ,
				[Total_More_work_Sec] = EI.[Total_More_work_Sec] ,
				[Is_OT_Applicable] = EI.[Is_OT_Applicable] ,
				[Monthly_Deficit_Adjust_OT_Hrs] = EI.[Monthly_Deficit_Adjust_OT_Hrs] ,
				[Late_Comm_sec] = EI.[Late_Comm_sec] ,
				[Branch_Id] = EI.[Branch_Id] 
	
			from Emp_Inout_Temp ET inner join 
			#Emp_Inout EI on ET.Emp_id = EI.emp_id and ET.For_date =EI.For_Date
			where EI.Emp_id=@curEmp_Id and EI.For_date=@CurFor_Date
			
			end
			else
			Begin
			
			insert into Emp_Inout_Temp
			select * from #Emp_Inout where Emp_id=@curEmp_Id and For_date=@CurFor_Date
			
			end

			fetch next from CusrCompanyMST into @curEmp_Id,@CurFor_Date	
		end
		close CusrCompanyMST                    
		deallocate CusrCompanyMST



 RETURN      



