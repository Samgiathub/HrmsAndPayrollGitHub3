
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[RPT_Audit_EMP_INOUT_RECORD_GET] 
 @Cmp_ID   numeric,      
 @From_Date  datetime,      
 @To_Date  datetime ,      
 @Branch_ID  numeric   ,      
 @Cat_ID   numeric  ,      
 @Grd_ID   numeric ,      
 @Type_ID  numeric ,      
 @Dept_ID  numeric  ,      
 @Desig_ID  numeric ,      
 @Emp_ID   numeric  ,      
 @Constraint  varchar(max) = '',      
 @Report_call varchar(50) = 'IN-OUT',      
 @Weekoff_Entry varchar(1) = 'Y',  
 @PBranch_ID varchar(200) = '0' ,
 @InOut_Tag varchar(200) = '0' ,  -- Added by nilesh on 22122014 For Rotation Attendance Dashboard 
 @Order_By	varchar(30) = 'Code' --Added by Jaina 31-Jul-2015 (To sort by Code/Name/Enroll No)      
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
 Declare @Leave_Days numeric(18,2)
  
  
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
 
  -- Added by rohit on 20082014
 Declare @leave_out_time as datetime
 Declare @leave_in_time as datetime
 Declare @leave_Detail as Varchar(max)
 declare @apply_hourly as varchar(100)
 set @leave_Detail=''
 set @leave_out_time ='01-jan-1900'
 set @leave_in_time ='01-jan-1900'
 set @apply_hourly = ''

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
 Declare @Other_Reason as varchar(MAX)    --Added By Jaina 12-09-2015
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
       
-- Added by rohit on 22082014
Declare @Is_Half_Day	tinyint	
Declare @Week_Day	varchar(10)	
Declare @Half_St_Time	varchar(10)	
Declare @Half_End_Time	varchar(10)	
Declare @Half_Dur	varchar(10)	

set @Is_Half_Day = 0  
set @Week_Day	= '' 
set @Half_St_Time		= '' 
set @Half_End_Time		= '' 
set @Half_Dur	= '' 
       
   
      
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
       
       
 select @Late_Comm_Limit = Late_Limit,@Early_Limit = Early_Limit from T0040_GENERAL_SETTING WITH (NOLOCK) where Cmp_ID = @Cmp_ID      
 and For_Date  = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where Cmp_ID = @Cmp_ID and For_Date <=@To_Date) 
        
 set @Late_Comm_sec = dbo.F_Return_Sec(@Late_Comm_Limit) 
 set @Early_Limit_sec = dbo.F_Return_Sec(@Early_Limit)        

CREATE table #Emp_Cons 
 (      
	Emp_ID numeric ,     
	Branch_ID numeric,
	Increment_ID numeric    
 )      
	-- Ankit 08092014 for Same Date Increment
	EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,0,0,0,0,0,0,0,0,2,@PBranch_ID 

	--if @Constraint <> ''
	--	begin
	--		Insert Into #Emp_Cons
	--		Select cast(data  as numeric),cast(data  as numeric),cast(data  as numeric) From dbo.Split(@Constraint,'#') 
	--	end
	--else 
	--	begin
	--		if @PBranch_ID <> '0' and isnull(@Branch_ID,0) = 0
	--			Begin
	--				Insert Into #Emp_Cons      
	--				  select distinct emp_id,branch_id,Increment_ID from dbo.V_Emp_Cons where 
	--				  cmp_id=@Cmp_ID 
	--				   and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
	--				and Branch_ID in (select cast(isnull(data,0) as numeric) from dbo.Split(@PBranch_ID,'#'))					   
	--			   --and Branch_ID = isnull(@Branch_ID ,Branch_ID)      
	--			   and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
	--			   and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
	--			   and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
	--			   and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0)) 
	--			   and Emp_ID = isnull(@Emp_ID ,Emp_ID)   
	--				  and Increment_Effective_Date <= @To_Date 
	--				  and 
	--						  ( (@From_Date  >= join_Date  and  @From_Date <= left_date )      
	--							or ( @To_Date  >= join_Date  and @To_Date <= left_date )      
	--							or (Left_date is null and @To_Date >= Join_Date)      
	--							or (@To_Date >= left_date  and  @From_Date <= left_date )) 
	--							order by Emp_ID
								
	--					Delete From #Emp_Cons Where Increment_ID Not In
	--					(select TI.Increment_ID from t0095_increment TI inner join
	--					(Select Max(Increment_Effective_Date) as Effective_Date,Emp_ID from T0095_Increment
	--					Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
	--					on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Effective_Date
	--					Where Increment_effective_Date <= @to_date) 
	--			End	
	--		Else
	--			Begin
	--				Insert Into #Emp_Cons      
	--				  select distinct emp_id,branch_id,Increment_ID from dbo.V_Emp_Cons where 
	--				  cmp_id=@Cmp_ID 
	--				   and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
	--			   and Branch_ID = isnull(@Branch_ID ,Branch_ID)      
	--			   and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
	--			   and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
	--			   and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
	--			   and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0)) 
	--			   and Emp_ID = isnull(@Emp_ID ,Emp_ID)   
	--				  and Increment_Effective_Date <= @To_Date 
	--				  and 
	--						  ( (@From_Date  >= join_Date  and  @From_Date <= left_date )      
	--							or ( @To_Date  >= join_Date  and @To_Date <= left_date )      
	--							or (Left_date is null and @To_Date >= Join_Date)      
	--							or (@To_Date >= left_date  and  @From_Date <= left_date )) 
	--							order by Emp_ID
								
	--					Delete From #Emp_Cons Where Increment_ID Not In
	--					(select TI.Increment_ID from t0095_increment TI inner join
	--					(Select Max(Increment_Effective_Date) as Effective_Date,Emp_ID from T0095_Increment
	--					Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
	--					on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Effective_Date
	--					Where Increment_effective_Date <= @to_date) 
	--			End	
	--	end


      
-- Declare #Emp_Cons Table      
-- (      
--  Emp_ID numeric      
-- )      
       
--if @Constraint <> ''      
--	begin      
--		Insert Into #Emp_Cons(Emp_ID)      
--		select  cast(data  as numeric) from dbo.Split (@Constraint,'#')       
--	end      
--else      
--	begin      
--		if @PBranch_ID <> '0' and isnull(@Branch_ID,0) = 0  
--			Begin  
--				Insert Into #Emp_Cons(Emp_ID)      
--				select I.Emp_Id from T0095_Increment I inner join       
--				( select max(Increment_effective_Date) as For_Date , Emp_ID From T0095_Increment      
--				where Increment_Effective_date <= @To_Date      
--				and Cmp_ID = @Cmp_ID      
--				group by emp_ID  ) Qry on      
--				I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date       

--				Where Cmp_ID = @Cmp_ID       
--				and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
--				and Branch_ID in (select cast(isnull(data,0) as numeric) from dbo.Split(@PBranch_ID,'#'))  
--				--and Branch_ID = isnull(@Branch_ID ,Branch_ID)      
--				and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
--				and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
--				and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
--				and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))      
--				and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID)       
--				AND I.Emp_ID in (select emp_Id from      
--				(select emp_id, Cmp_ID, join_Date, isnull(left_Date, @To_Date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN) qry      
--				where Cmp_ID = @Cmp_ID   and        
--				(( @From_Date  >= join_Date  and  @From_Date <= left_date )       
--				or ( @From_Date <= join_Date  and @To_Date >= left_date )       
--				or ( @To_Date  >= join_Date  and @To_Date <= left_date )      
--				or left_date is null and  @To_Date >= Join_Date))       
--			end  
--	else  
--		Begin  
--			Insert Into #Emp_Cons(Emp_ID)      
--			select I.Emp_Id from T0095_Increment I inner join       
--			( select max(Increment_effective_Date) as For_Date , Emp_ID From T0095_Increment      
--			where Increment_Effective_date <= @To_Date      
--			and Cmp_ID = @Cmp_ID      
--			group by emp_ID  ) Qry on      
--			I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date       

--			Where Cmp_ID = @Cmp_ID       
--			and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))  
--			and Branch_ID = isnull(@Branch_ID ,Branch_ID)      
--			and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
--			and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
--			and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
--			and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))      
--			and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID)       
--			AND I.Emp_ID in (select emp_Id from      
--			(select emp_id, Cmp_ID, join_Date, isnull(left_Date, @To_Date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN) qry      
--			where Cmp_ID = @Cmp_ID   and        
--			(( @From_Date  >= join_Date  and  @From_Date <= left_date )       
--			or ( @From_Date <= join_Date  and @To_Date >= left_date )       
--			or ( @To_Date  >= join_Date  and @To_Date <= left_date )      
--			or left_date is null and  @To_Date >= Join_Date))              
--		end       
-- end      
    
    
 Declare @Branch_Id_Cur as numeric
    
-- Added by rohit For Leave Name Showing With Leave Code in Footer on 08082013
Declare @leave_Footer varchar(5000)
set @leave_Footer = ''

SELECT  @leave_Footer = STUFF((SELECT ' ' + s.Leave_name FROM 
( select ('  ' + Leave_Code + ' : ' + Leave_name + ' ' ) as leave_name,Cmp_ID from T0040_LEAVE_MASTER WITH (NOLOCK)
)
 s WHERE s.Cmp_id = t.Cmp_id FOR XML PATH('')),1,1,'')  FROM T0040_LEAVE_MASTER AS t WITH (NOLOCK) where t.Cmp_ID=@cmp_id GROUP BY t.Cmp_id
 
 --select @leave_Footer
 
 -- Ended by rohit on 08082013

 -- Added by rohit for monthly Auto Generate mail For muni seva Ashram on 24092013       
if @Report_call <> 'Monthly Generate'
BEGIN   
if  object_id('tempdb..#Emp_Inout') IS NOT NULL --exists (select 1 from [tempdb].dbo.sysobjects where name like '#Emp_Inout' )        
 begin      
  drop table #Emp_Inout  
 end  
           
       
 CREATE table #Emp_Inout       
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
   Other_Reason varchar(300) null, --Added By Jaina 12-09-2015        
   AB_LEAVE    VARCHAR(Max) NULL,      
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
   Branch_Id Numeric default 0,
   P_days	numeric(5,2) default 0,
  )      
  END
  
--Added by Gadriwala Muslim   28082014
CREATE table #Emp_Holiday
	  (
			Emp_Id		numeric , 
			Cmp_ID		numeric,
			For_Date	datetime,
			H_Day		numeric(3,1),
			is_Half_day tinyint
	  )	    
	  
	    Declare @Is_Late_Calc_On_HO_WO  as numeric
	  Declare @Is_Early_Calc_On_HO_WO as numeric
	  
	  set @Is_Late_Calc_On_HO_WO=0
	  set @Is_Early_Calc_On_HO_WO=0
	  
	  
 Select @Is_Cancel_Holiday = Is_Cancel_Holiday ,@Is_Cancel_Weekoff = Is_Cancel_Weekoff   
 ,@Is_Late_Calc_On_HO_WO=Is_Late_Calc_On_HO_WO, @Is_Early_Calc_On_HO_WO =Is_Early_Calc_On_HO_WO        
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
     ( select max(Increment_ID) as Increment_ID, Emp_ID from dbo.T0095_INCREMENT WITH (NOLOCK)	-- Ankit 08092014 for Same Date Increment    
     where Increment_effective_Date <= @To_Date      
     and Cmp_ID = @Cmp_ID      
     group by emp_ID  ) Qry      
    on I.Emp_ID = Qry.Emp_ID and      
    i.Increment_ID   = Qry.Increment_ID       
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
	 Set @StrHoliday_Date = ''      
	 set @StrWeekoff_Date = ''      
	 Set @Holiday_Days  = 0      
	 Set @Weekoff_Days  = 0      
	 Set @Cancel_Holiday  = 0      
	 Set @Cancel_Weekoff  = 0      
          

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
	Exec dbo.SP_EMP_HOLIDAY_DATE_GET @Emp_ID,@Cmp_ID,@From_Date,@To_Date,@Join_Date,@left_Date,@Is_Cancel_Holiday,@StrHoliday_Date output,@Holiday_days output,@Cancel_Holiday output,1,@Branch_ID,@StrWeekoff_Date  
          
    while @Temp_Month_Date <= @Temp_End_Date      
     begin      
      set @shift_ID = 0      
            
   Exec dbo.SP_CURR_T0100_EMP_SHIFT_GET @emp_id,@Cmp_ID,@Temp_Month_Date,@Shift_St_Time output,@Shift_End_Time output,@Shift_Dur output,null,@Second_Break_Duration Output,@Third_Break_Duration  output,null,@shift_ID output,@Is_Half_Day	output,@Week_Day output,@Half_St_Time output,@Half_End_Time	output,@Half_Dur output
	
	
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

      --select @Insert_In_Date = Min(In_Time) From T0150_AUDIT_EMP_INOUT_RECORD Where Emp_ID  = @Emp_ID and For_Date = @Temp_Month_Date      
      --select @Insert_Out_Date = Out_Time  From T0150_AUDIT_EMP_INOUT_RECORD Where Emp_ID = @Emp_ID and In_Time = @Insert_In_Date      

			Declare @First_In_Last_Out_For_InOut_Calculation tinyint
			set @First_In_Last_Out_For_InOut_Calculation = 0 
			--Select @First_In_Last_Out_For_InOut_Calculation= isnull(First_In_Last_Out_For_InOut_Calculation,0) from dbo.T0040_GENERAL_SETTING 
			--where Cmp_ID = @Cmp_ID and Branch_ID = (Select Branch_ID from dbo.T0080_EMP_MASTER where Emp_ID=@Emp_ID)
			
			--Commented and Changed by Ramiz on 07102014
			Declare @branch_id_new as numeric
			Declare @Tras_Week_ot as numeric
			select @branch_id_new = Branch_ID from dbo.T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID=@Emp_ID
			Select @First_In_Last_Out_For_InOut_Calculation= isnull(First_In_Last_Out_For_InOut_Calculation,0),
			@Tras_Week_ot = Isnull(Tras_Week_ot,0) --Added by nilesh patel on 12082015 
			from dbo.T0040_GENERAL_SETTING WITH (NOLOCK)
			where Cmp_ID = @Cmp_ID and Branch_ID = @branch_id_new and For_Date = ( select max(For_Date) from dbo.T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@To_Date and Branch_ID = @Branch_ID_new and Cmp_ID = @Cmp_ID)
			-- Ended by Ramiz on 07102014
			
			-- Added by nilesh on 22122014 For Rotation Attendance Dashboard --Start
			if @InOut_Tag = 'D' 
				Begin
					Set @First_In_Last_Out_For_InOut_Calculation = 1
				End 
			-- Added by nilesh on 22122014 For Rotation Attendance Dashboard --End
			
			If @Report_call ='Inout_Page' --added by Hardik 13/10/2012 for In Out Record Page
				Set @First_In_Last_Out_For_InOut_Calculation = 0
			
			If @Report_call ='Time_Loss' --Added By Ramiz as Time Loss is only Useful when First In Last Out is Not ticked
				Set @First_In_Last_Out_For_InOut_Calculation = 0


			If @First_In_Last_Out_For_InOut_Calculation = 1
				Begin      
					-- Hardik 14/08/2012 for Night Shift Checking...
					--If CONVERT(varchar(5), @Shift_St_Time, 108) < CONVERT(varchar(5), @Shift_End_Time, 108)
						Begin
							  Declare cur_Inout cursor for       
							 -- select Min(In_time),Max(Out_Time),Reason from dbo.T0150_AUDIT_EMP_INOUT_RECORD Where Emp_ID =@Emp_ID and For_Date = @Temp_Month_Date    
								--group by Reason
								select Min(In_time),
									Case When Max_In > Max(Out_Time) Then Max_In Else Max(Out_time) End ,max(Reason)
									,MAX(Other_Reason) As Other_Reason  --Added By Jaina 12-09-2015 Other Reason
								from dbo.T0150_AUDIT_EMP_INOUT_RECORD e WITH (NOLOCK) Inner Join  
								(select Max(In_time) Max_In,Emp_Id,For_Date from dbo.T0150_AUDIT_EMP_INOUT_RECORD WITH (NOLOCK) Where Emp_ID =@Emp_ID 
									and For_Date = @Temp_Month_Date Group by Emp_ID,For_Date) m
								on e.Emp_ID = M.Emp_ID and E.For_Date = M.For_Date
								Where E.Emp_ID =@Emp_ID and E.For_Date = @Temp_Month_Date
								group by Max_In								
							
						End
					--Else			
					--	Begin
					--		 Declare cur_Inout cursor for   
					--			Select Min(In_Time),Max(Out_Time),Reason From (
					--			Select distinct In_Time,Case when Max_In_Date > Out_Date Then Max_In_Date Else Out_Date End Out_Time, Eir.Reason
					--			from T0150_AUDIT_EMP_INOUT_RECORD  EIR Inner join #Emp_Cons Ec on EIR.Emp_Id = ec.Emp_ID inner Join        
					--				(select I.Emp_ID,Emp_OT,isnull(Emp_OT_min_Limit,'00:00')Emp_OT_min_Limit,isnull(Emp_OT_max_Limit,'00:00')Emp_OT_max_Limit from T0095_Increment  I inner join         
					--				(select max(increment_effective_Date)IE_Date ,Emp_ID from T0095_Increment         
					--				 where increment_effective_Date <=@To_Date and Cmp_ID =@Cmp_ID group by Emp_ID)q on I.emp_ID =q.Emp_ID and         
					--				I.Increment_effective_Date = q.IE_Date ) IQ on eir.Emp_ID =iq.emp_ID 
					--				Inner Join
					--				(select Emp_Id, Min(In_Time) In_Date,For_Date From T0150_AUDIT_EMP_INOUT_RECORD Where In_Time >=Dateadd(hh,-5,@Shift_St_Datetime) Group By Emp_Id,For_Date) Q1 on EIR.Emp_Id = Q1.Emp_Id 
					--				And EIR.For_Date = Q1.For_Date
					--				Inner Join
					--				(select Emp_Id, Max(Out_Time) Out_Date,For_Date From T0150_AUDIT_EMP_INOUT_RECORD Where Out_Time <=Dateadd(hh,5,@Shift_End_Datetime) Group By Emp_Id,For_Date) Q2 on EIR.Emp_Id = Q2.Emp_Id 
					--				And EIR.For_Date = Q2.For_Date
					--				Inner Join
					--				--Added by Hardik 23/07/2012 for First IN And Last OUT (it will take Max In Punch as OUT and calculate Hours)
					--				(select Emp_Id, Max(In_Time) Max_In_Date,For_Date From T0150_AUDIT_EMP_INOUT_RECORD Where Out_Time <=Dateadd(hh,5,@Shift_End_Datetime) Group By Emp_Id,For_Date) Q4 on EIR.Emp_Id = Q4.Emp_Id  
					--				And EIR.For_Date = Q4.For_Date
					--				Left Outer Join 
					--				(Select Emp_ID,Chk_By_Superior Chk_By_Sup,For_Date from T0150_AUDIT_EMP_INOUT_RECORD where Chk_By_Superior=1) Q3 on EIR.Emp_Id = Q3.Emp_Id 
					--				And EIR.For_Date = Q3.For_Date
					--			Where cmp_Id= @Cmp_ID        
					--				and EIR.In_Time >=Dateadd(hh,-5,@Shift_St_Datetime) and EIR.Out_Time <=Dateadd(hh,5,@Shift_End_Datetime) and ec.Emp_ID = @Emp_Id      
					--			group by In_Time,out_Date,Reason,Max_In_Date) Qry
					--			Group by Reason
														 
					--	End
					End
			Else
				Begin
					-- Hardik 14/08/2012 for Night Shift Checking...
					--If CONVERT(varchar(5), @Shift_St_Time, 108) < CONVERT(varchar(5), @Shift_End_Time, 108)
						Begin
							  Declare cur_Inout cursor for       
							   select In_time,Out_Time,Reason,Other_Reason from dbo.T0150_AUDIT_EMP_INOUT_RECORD WITH (NOLOCK) Where Emp_ID =@Emp_ID and For_Date = @Temp_Month_Date      --Added By Jaina 12-09-2015 Other Reason
								order by isnull(In_time,Out_time),Out_time,Reason      
						End
					--Else			
					--	Begin
					--	  Declare cur_Inout cursor for       
					--	   select In_time,Out_Time,Reason from T0150_AUDIT_EMP_INOUT_RECORD Where Emp_ID =@Emp_ID 
					--		and In_Time >= Dateadd(hh,-2,@Shift_St_Datetime) And
					--			Out_Time <= Dateadd(hh,2,@Shift_End_Datetime)
					--		order by isnull(In_time,Out_time),Out_time,Reason      
					--	End
				End
      open cur_inout      
      Fetch next from cur_inout  into @Insert_In_Date,@Insert_Out_Date,@Reason,@Other_Reason
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

                
          set @Working_sec = isnull(datediff(s,@Insert_In_Date,@Insert_Out_Date),0)

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

			-- Commented by Hardik 17/08/2012                          
           --exec Return_Without_Sec @late_in_sec ,@late_in_sec output      
           --exec Return_Without_Sec @late_out_sec ,@late_out_sec output      
           --exec Return_Without_Sec @Early_In_Sec ,@Early_In_Sec output      
           --exec Return_Without_Sec @Early_Out_Sec ,@Early_Out_Sec output      
           --exec Return_Without_Sec @Working_sec ,@Working_sec output       
                
            -- Commented by rohit on 21082014             
          --if @Late_Comm_sec >=  @late_in_sec   set @late_in_sec  = 0      
          --if @Late_Comm_sec >=  @late_out_sec  set @late_out_sec  = 0      
          --if @Early_Limit_sec >=  @Early_In_Sec  set @Early_In_Sec  = 0      
          --if @Early_Limit_sec >=  @Early_Out_Sec set  @Early_Out_Sec  = 0      
                
          --if @late_in_sec  > 0  exec dbo.Return_DurHourMin  @late_In_Sec ,@late_In output       
          --if @late_out_sec > 0  exec dbo.Return_DurHourMin  @late_Out_Sec ,@late_Out output       
                
          --if @Early_In_Sec  > 0 exec dbo.Return_DurHourMin  @Early_In_Sec ,@Early_In output       
          --if @Early_Out_Sec > 0 exec dbo.Return_DurHourMin  @Early_Out_Sec ,@Early_Out output       
          --if @Working_sec > 0 exec dbo.Return_DurHourMin  @Working_Sec ,@WORKING_HOURS output        
		
          set @Toatl_Working_sec = isnull(@Toatl_Working_sec,0) + @Working_sec      
          
          
          
          --Ankit Start 12112013
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
			declare @HalfDayDate1 varchar(500)  --added By Mukti 28112014 
			
			Select @DeduHour_SecondBreak = DeduHour_SecondBreak,@DeduHour_ThirdBreak = DeduHour_ThirdBreak ,@S_St_Time=S_St_Time,@S_End_Time=S_End_Time,@T_St_Time=T_St_Time,@T_End_Time=T_End_Time
			From dbo.T0040_SHIFT_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID And Shift_ID=@SHIFT_ID
				
			Set @Shift_S_ST_DateTime = cast(cast(@Temp_Month_Date as varchar(11)) + ' ' + @S_St_Time as smalldatetime)
			Set @Shift_S_End_DateTime = cast(cast(@Temp_Month_Date as varchar(11)) + ' ' + @S_End_Time as smalldatetime)
			Set @Shift_T_ST_DateTime = cast(cast(@Temp_Month_Date as varchar(11)) + ' ' + @T_St_Time as smalldatetime)
			Set @Shift_T_End_DateTime = cast(cast(@Temp_Month_Date as varchar(11)) + ' ' + @T_End_Time as smalldatetime)

			exec dbo.GET_HalfDay_Date @Cmp_ID,@Emp_ID,@From_Date,@To_Date,0,@HalfDayDate1 output --added By Mukti 28112014 
									
			if not (charindex(CONVERT(nvarchar(11),@Insert_In_Date,109),@HalfDayDate1) > 0)  --added By Mukti 28112014 
			begin   
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
			end						
			
			--Ankit End 12112013  
                       
          if @Toatl_Working_sec > 0 exec dbo.Return_DurHourMin  @Toatl_Working_sec ,@Total_work output         
                           
          if @Insert_IN_Date > @Shift_End_datetime      
           begin      
            set @Working_Sec_AfterShift   =  @Working_sec + @Working_Sec_AfterShift      
            set @Working_AfterShift_Count =  1      
           end      
      
                
          --set @Diff_Sec  = @Toatl_Working_sec -  @Shift_Sec       
          --Ankit start 13112013
			Declare @OT_Start_ShiftEnd_Time as varchar(10)
			Declare @OT_Start_ShiftStart_Time as varchar(10)
			  Set @OT_Start_ShiftEnd_Time = ''	
			  Set @OT_Start_ShiftStart_Time = ''
			  
			 
			Select @OT_Start_ShiftStart_Time=OT_Start_Time, @OT_Start_ShiftEnd_Time = OT_End_Time from T0050_SHIFT_DETAIL WITH (NOLOCK) where Cmp_ID=@Cmp_ID And Shift_ID=@SHIFT_ID	
			
			--select @OT_Start_ShiftStart_Time,@OT_Start_ShiftEnd_Time, from T0050_SHIFT_DETAIL where Cmp_ID=@Cmp_ID And Shift_ID=@SHIFT_ID
			--return
		    IF @OT_Start_ShiftStart_Time = 1
				Begin
					Declare @OT_Start_ShiftStart_Sec numeric
					SET @OT_Start_ShiftStart_Sec =0
	
					if datediff(s,@Insert_In_Date,@Shift_ST_DateTime) > 0       
						Begin
							set @OT_Start_ShiftStart_Sec = datediff(s,@Insert_In_Date,@Shift_ST_DateTime)
							--set @OT_Start_ShiftStart_Sec  = @OT_Start_ShiftStart_Sec * -1   
						
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
			
			
			
			IF @OT_Start_ShiftStart_Time = 1
			BEGIN
				Set @Toatl_Working_sec = @Toatl_Working_sec + Isnull(@OT_Start_ShiftStart_Sec,0)
			END
			
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
									* from T0150_AUDIT_EMP_INOUT_RECORD WITH (NOLOCK) where Emp_ID = @Emp_ID
							and (In_Time >= @Shift_End_Datetime or Out_Time >= @Shift_End_Datetime)
							and For_Date = @Temp_Month_Date And Emp_ID = @Emp_ID) as Qry) as Qry1						
						End
						
						If @OT_Start_ShiftEnd_Sec > 0
							set @Diff_Sec = @OT_Start_ShiftEnd_Sec	
						Else
							set @Diff_Sec = 0
						
				End
		  --Ankit End 13112013 
		  
         
          ---Hardik 21/11/2011 for Half day shift  
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
   select @WeekDay=SM.Week_Day,@HalfStartTime=SM.Half_St_Time,@HalfEndTime=SM.Half_End_Time,@HalfDuration=SM.Half_Dur,@HalfMinDuration=SM.Half_min_duration 
	from dbo.T0040_SHIFT_MASTER SM WITH (NOLOCK)
		--inner join (select distinct Shift_ID from #Emp_Inout ) q on SM.Shift_ID =  q.shift_ID          
     where Is_Half_Day = 1   and SM.Shift_ID=@SHIFT_ID
    
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
  
  --added by rohit on 21082014
		
		
		set @Shift_St_Time = @HalfStartTime
		
		set @Shift_End_Time = @HalfEndTime
		
		set @shift_Dur= @Half_Dur       
			
		set @Shift_Sec = 0     
		set @Shift_Sec  = dbo.F_Return_Sec(@Shift_Dur) 
        
      set @late_In_Sec  = @late_In_Sec * -1      
      set @Late_Out_Sec  = @Late_Out_Sec * -1      

		-- Commented by Hardik 17/08/2012                            
       --exec Return_Without_Sec @late_in_sec ,@late_in_sec output      
       --exec Return_Without_Sec @late_out_sec ,@late_out_sec output      
       --exec Return_Without_Sec @Early_In_Sec ,@Early_In_Sec output      
       --exec Return_Without_Sec @Early_Out_Sec ,@Early_Out_Sec output      
       --exec Return_Without_Sec @Working_sec ,@Working_sec output       
                  
         -- Commented by rohit on 21082014         
      --if @Late_Comm_sec >=  @late_in_sec   set @late_in_sec  = 0      
      --if @Late_Comm_sec >=  @late_out_sec  set @late_out_sec  = 0      
      --if @Early_Limit_sec >=  @Early_In_Sec  set @Early_In_Sec  = 0      
      --if @Early_Limit_sec >=  @Early_Out_Sec set  @Early_Out_Sec  = 0      
                  
      --if @late_in_sec  > 0  exec dbo.Return_DurHourMin  @late_In_Sec ,@late_In output       
      --if @late_out_sec > 0  exec dbo.Return_DurHourMin  @late_Out_Sec ,@late_Out output       
                  
      --if @Early_In_Sec  > 0 exec dbo.Return_DurHourMin  @Early_In_Sec ,@Early_In output       
      --if @Early_Out_Sec > 0 exec dbo.Return_DurHourMin  @Early_Out_Sec ,@Early_Out output       
      --if @Working_sec > 0 exec dbo.Return_DurHourMin  @Working_Sec ,@WORKING_HOURS output    
    end         
    
     -- Added By Rohit On 08102014 for Inductotherm late not Calculate on Week off
	  IF @Is_Late_Calc_On_HO_WO=0
	  BEGIN
	  
		  if(charindex(CONVERT(nvarchar(11),@Insert_In_Date,109),@StrWeekoff_Date) > 0)  
			begin      
			  set @Late_In_sec = 0      
			  set @Late_Out_Sec = 0      
			    
			end    
	  
	  END
  
	  if @Is_Early_Calc_On_HO_WO=0
	  begin
			if(charindex(CONVERT(nvarchar(11),@Insert_In_Date,109),@StrWeekoff_Date) > 0)  
			begin      
			  set @Early_In_sec = 0      
			  set @Early_Out_sec = 0    
			end    
    END
    --ended by rohit on 08102014
    
  ------------ End for Half shift  
-- Added by rohit on 21082014
  if @Late_Comm_sec >=  @late_in_sec   set @late_in_sec  = 0      
      if @Late_Comm_sec >=  @late_out_sec  set @late_out_sec  = 0      
      if @Early_Limit_sec >=  @Early_In_Sec  set @Early_In_Sec  = 0      
      if @Early_Limit_sec >=  @Early_Out_Sec set  @Early_Out_Sec  = 0      
                  
      if @late_in_sec  > 0  exec dbo.Return_DurHourMin  @late_In_Sec ,@late_In output       
      if @late_out_sec > 0  exec dbo.Return_DurHourMin  @late_Out_Sec ,@late_Out output       
	  PRINT @late_Out	                  
      if @Early_In_Sec  > 0 exec dbo.Return_DurHourMin  @Early_In_Sec ,@Early_In output       
      if @Early_Out_Sec > 0 exec dbo.Return_DurHourMin  @Early_Out_Sec ,@Early_Out output       
      if @Working_sec > 0 exec dbo.Return_DurHourMin  @Working_Sec ,@WORKING_HOURS output    
      
      
		If @Diff_Sec < 0
			Begin  
				--print 2
				Set @Diff_Sec = @Diff_Sec * -1
				Exec dbo.Return_Without_Sec @Diff_Sec,@Diff_Sec Output
				Set @Diff_Sec = @Diff_Sec * -1
			End
		Else
			begin
				--print 3
				
				Exec dbo.Return_Without_Sec @Diff_Sec,@Diff_Sec Output
				
			End
		
		--select  @Diff_Sec as Diff_Sec ,@Emp_OT_Max_Limit_Sec as Emp_OT_Max_Limit_Sec,@Emp_OT_Min_Limit_Sec as Emp_OT_Min_Limit_Sec
		if  @Diff_Sec > 0  And @Diff_Sec > @Emp_OT_Min_Limit_Sec And (@Emp_OT = 1 or @Monthly_Deficit_Adjust_OT_Hrs = 1)
			Begin
				
				If @Diff_Sec < @Emp_OT_Max_Limit_Sec or @Emp_OT_Max_Limit_Sec = 0
					Begin
						
						exec dbo.Return_DurHourMin @Diff_Sec , @More_Work output  
						set @Total_More_work_sec = @Diff_Sec    
						--select @More_Work,@Diff_Sec  
					End
				Else
					Begin
						print 2
						exec dbo.Return_DurHourMin @Emp_OT_Max_Limit_Sec , @More_Work output  
						set @Total_More_work_sec = @Emp_OT_Max_Limit_Sec      
					End
					
			End
		else if @Diff_Sec <  0 and @Toatl_Working_sec > 0 And (@Emp_OT = 1 or @Monthly_Deficit_Adjust_OT_Hrs = 1)     
			begin      
				print 3
				set @Diff_Sec = @Diff_Sec * -1      
				set @Total_Less_Work_Sec = @Diff_Sec      
				exec dbo.Return_DurHourMin @Diff_Sec , @less_Work output       
				
			end       
      --print @Emp_OT_Max_Limit_Sec
      --print @More_Work
      --print 453
          if @late_in_Sec > 0       
           set @Late_in_count =1       
          if @Early_Out_Sec > 0      
           set @Early_Out_Count = 1       
       
   --Nilay 30 May 2009 Working hour > shift hours set working hours = shift hours    
     if @working_sec > @Shift_Sec  
    Begin    
     set  @working_sec=@Shift_Sec    
     set  @working_Hours=dbo.F_Return_Hours(@working_sec)          
    End  
      

			---Hardik 13/12/2013 for Pakistan
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
					From dbo.T0150_AUDIT_EMP_INOUT_RECORD WITH (NOLOCK) Where In_Time = @Insert_IN_DATE And Emp_ID = @Emp_ID
				
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
			---- End for Hardik 13/12/2013 for Pakistan
      
      
    ---Hardik for Total Work show only in Last row (if Multiple In-Out Entries)  
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
	  
	      --Ankit Start 12112013
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
			--Ankit End 12112013			
					
				
      if @Toatl_Working_sec > 0 exec dbo.Return_DurHourMin  @Toatl_Working_sec ,@Total_work output         
  
       --Set @Diff_Sec  = @Toatl_Working_sec -  @Shift_Sec       

       
	   --Ankit 14112013	
	   
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
									* from T0150_AUDIT_EMP_INOUT_RECORD WITH (NOLOCK) where Emp_ID = @Emp_ID
							and (In_Time >= @Shift_End_Datetime or Out_Time >= @Shift_End_Datetime)
							and For_Date = @Temp_Month_Date And Emp_ID = @Emp_ID) as Qry) as Qry1						
						End
					
						If @OT_Start_ShiftEnd_Sec > 0
							set @Diff_Sec = @OT_Start_ShiftEnd_Sec	- @OT_Start_ShiftStart_Sec
						Else
							set @Diff_Sec = 0
			End
		Else
			Set @Diff_Sec  = @Toatl_Working_sec -  @Shift_Sec - Isnull(@OT_Start_ShiftStart_Sec	,0)
			
	   --Ankit 14112013
	  	
	  		
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
						set @Total_Less_Work_Sec =0
					End
				Else
					Begin
					
						exec dbo.Return_DurHourMin @Emp_OT_Max_Limit_Sec , @More_Work output  
						set @Total_More_work_sec = @Emp_OT_Max_Limit_Sec      
						Set @less_Work = ''
						set @Total_Less_Work_Sec =0
					End
			End
		else if @Diff_Sec <  0 and @Toatl_Working_sec > 0  And (@Emp_OT = 1 or @Monthly_Deficit_Adjust_OT_Hrs = 1)    
			begin      
				
				set @Diff_Sec = @Diff_Sec * -1      
				set @Total_Less_Work_Sec = @Diff_Sec      
				exec dbo.Return_DurHourMin @Diff_Sec , @less_Work output       
				Set @More_Work = ''
				set @Total_More_work_sec =0
				
			end       
		--Else if condition added by Hardik 18/11/2013 for Diff_Sec zero
		Else if @Diff_Sec = 0
			Begin
				Set @less_Work = ''
				Set @More_Work = ''
				set @Total_More_work_sec =0
				set @Total_Less_Work_Sec =0
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
                ------------ End for Hardik   
	
		
	
	INSERT INTO #Emp_Inout (Emp_id,For_Date , Dept_id ,Grd_ID,Type_ID,Desig_ID ,Shift_ID,In_Time ,Out_Time ,Duration ,      
			Duration_sec  , Late_In ,Late_Out , Early_In , Early_Out , Leave ,Shift_Sec,Shift_Dur,Total_Work,Less_Work,More_work,Reason,Other_Reason,Late_in_sec,Early_Out_sec,Total_Less_work_sec,Late_in_Count,Early_Out_count,Shift_St_Datetime,Shift_en_Datetime      
			,Working_Sec_AfterShift,Working_AfterShift_Count,Inout_Reason,Total_Work_Sec,Late_Out_Sec,Early_In_sec,Total_More_work_Sec, Is_OT_Applicable,Monthly_Deficit_Adjust_OT_Hrs,Late_Comm_sec,Branch_Id )          
	VALUES (@emp_id ,@Temp_Month_Date ,@Dept_id ,@Grd_ID ,@Type_ID,@Desig_ID,@Shift_ID,@Insert_IN_DATE ,@Insert_Out_DATE ,@working_Hours ,      
			@working_sec  , @late_In ,@late_Out , @Early_In , @Early_Out , '',@Shift_Sec,@Shift_Dur,@Total_Work,@Less_Work,@More_work,@Reason,@Other_Reason,@late_in_sec,@Early_Out_Sec,@Total_less_work_sec,@Late_in_Count,@Early_Out_count,@Shift_St_Time,@Shift_End_Time  -- @Pre_Shift_St_dateTime,@Pre_Shift_En_dateTime   change by rohit for shift start time and end time on 03-aug-2012 Added By Jaina 12-09-2015 other reason
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
     ------------ End for Hardik   
    
    --- Hardik for Late In Hours show only on First Row (If Multiple In-Out Entries)
	 --Declare @Min_In_Time as Datetime	--Comment By Ankit 30112013 For Update Shift Break Deduction
	 set @Min_In_Time = ''
     select @Min_In_Time = MIN(In_Time) from #Emp_Inout as EI where EI.Emp_ID = @Emp_ID   
      and EI.For_DAte = @temp_Month_Date 
       
		update #Emp_Inout set   
		Late_In = '',Late_In_Sec = 0,Late_In_count=0  
		where Emp_ID = @emp_Id and For_Date = @temp_month_Date And In_Time <> @Min_In_Time
     ------------ End for Hardik   
                             
         Fetch next from cur_inout  into @Insert_In_Date,@Insert_Out_Date,@Reason,@Other_Reason --Added By Jaina 12-09-2015     
       end      
      close cur_Inout      
      Deallocate cur_inout     
  -------------------------------------------------------------------------
  ---------Added by Sumit 19092015-------------------------------------------------------------------
  
Declare @Emp_ID_AutoShift numeric
Declare @In_Time_Autoshift datetime
Declare @Out_Time_Autoshift datetime
Declare @New_Shift_ID numeric
Declare @Shift_St_Time_Autoshift datetime
Declare @Shift_End_Time_Autoshift as datetime
If exists(select 1 from T0040_SHIFT_MASTER s WITH (NOLOCK) where Isnull(s.Inc_Auto_Shift,0) = 1 and s.Cmp_ID=@Cmp_id)
	BEGIN
		 Declare curautoshift cursor Fast_forward for	                  
		select distinct d.Emp_ID,Em.In_Time,d.Shift_ID,Em.Out_Time,cast(CONVERT(varchar(11),Em.in_Time,120) + s.Shift_St_Time as datetime),cast(CONVERT(varchar(11),Em.out_time,120) + s.Shift_End_Time as datetime) from T0100_EMP_SHIFT_DETAIL d WITH (NOLOCK) inner join T0040_SHIFT_MASTER s WITH (NOLOCK) on d.Shift_ID = s.Shift_ID 
				inner join T0150_AUDIT_EMP_INOUT_RECORD EM WITH (NOLOCK) on Em.Emp_ID=d.Emp_ID and d.Cmp_ID=Em.Cmp_ID
				inner join #Emp_Cons Ec on EC.Emp_ID=d.Emp_ID
				where Isnull(s.Inc_Auto_Shift,0) = 1 
				and Em.For_Date >=@from_date and Em.For_Date<=@to_date
				and (isnull(datediff(s, cast(EM.In_Time as datetime),cast(CONVERT(varchar(11),Em.in_Time,120) + s.Shift_St_Time as datetime) ),0)  < -14300		
						or isnull(datediff(s,Em.in_Time,cast(CONVERT(varchar(11),Em.in_Time,120) + s.Shift_St_Time as datetime)),0) > 14300
					)
			and d.Cmp_ID=@Cmp_ID	
			 order by d.Emp_ID 
		
				Open curautoshift                      
			  Fetch next from curautoshift into @Emp_ID_AutoShift,@In_Time_Autoshift,@New_Shift_ID,@Out_Time_Autoshift,@Shift_St_Time_Autoshift,@Shift_End_Time_Autoshift
		              
				While @@fetch_status = 0                    
					Begin   
					Declare @Shift_ID_Autoshift numeric
					Declare @Shift_start_time_Autoshift varchar(12)
			select top 1 @Shift_ID_Autoshift =  Shift_ID 
			from T0040_SHIFT_MASTER WITH (NOLOCK)
			where Cmp_ID = @Cmp_ID 
			order by ABS(datediff(s,@In_Time_Autoshift,cast(CONVERT(VARCHAR(11), @In_Time_Autoshift, 121)  + CONVERT(VARCHAR(12), Shift_St_Time, 114) as datetime)))
			
				 if isnull(@Shift_ID_Autoshift,0) > 0
				 Begin
				 select top 1 @Shift_ID_Autoshift =  Shift_ID 
					from T0040_SHIFT_MASTER WITH (NOLOCK)
					where Cmp_ID = @Cmp_ID 
					order by ABS(datediff(s,@In_Time_Autoshift,cast(CONVERT(VARCHAR(11), @In_Time_Autoshift, 121)  + CONVERT(VARCHAR(12), Shift_St_Time, 114) as datetime)))				
				declare @Shift_st_time_auto as datetime
				declare @Shift_Out_time_auto as datetime
				
				select @Shift_st_time_auto =cast(CONVERT(VARCHAR(11), @In_Time_Autoshift, 121)  + CONVERT(VARCHAR(12), Shift_St_Time, 114) as datetime)
				,@Shift_Out_time_auto=cast(CONVERT(VARCHAR(11), @Out_Time_Autoshift, 121)  + CONVERT(VARCHAR(12), Shift_End_Time, 114) as datetime)
				from T0040_SHIFT_MASTER WITH (NOLOCK) where Shift_ID=@Shift_ID_Autoshift and Cmp_ID=@Cmp_ID
				
					declare @late_insec as numeric
					declare @Working_secAt as numeric(18,0)
					declare @late_out_sec_auto as numeric
					declare @Erlyoutsec as numeric(18,0)
					set @Working_secAt = isnull(datediff(s,@In_Time_Autoshift,@Shift_Out_time_auto),0)
					
					  if datediff(s,@In_Time_Autoshift,@Shift_st_time_auto) > 0  					      
					   set @Early_In_Sec = datediff(s,@In_Time_Autoshift,@Shift_st_time_auto)   
					      
					  if datediff(s,@In_Time_Autoshift,@Shift_st_time_auto) < 0 
					   set @late_insec = datediff(s,@In_Time_Autoshift,@Shift_st_time_auto)      
					   
					  if datediff(s,@Out_Time_Autoshift,@Shift_Out_time_auto) > 0       
					   set @Erlyoutsec = datediff(s,@Out_Time_Autoshift,@Shift_Out_time_auto)  
					   --select  @Erlyoutsec   
					  if datediff(s,@Out_Time_Autoshift,@Shift_Out_time_auto) < 0       
					   set @late_out_sec_auto = datediff(s,@Out_Time_Autoshift,@Shift_Out_time_auto)      
						
						
						
						 --select @late_out_sec_auto
						set @late_insec  = @late_insec * -1      
						set @late_out_sec_auto  = @late_out_sec_auto * -1 
						
						if datediff(s,@Out_Time_Autoshift,@Shift_Out_time_auto) = 0
							Begin							
								set @Erlyoutsec=0
							End
						
						if @late_insec is null
							Begin							
								set @late_insec=0
							End
						if @late_out_sec_auto is null
							Begin							
								set @late_out_sec_auto=0
							End	
						  if @late_insec  > 0         
							  Begin
								exec dbo.Return_DurHourMin @late_insec ,@late_In output
								--select @late_insec
							  End
						  Else if @late_insec  < 0      
								Begin
									set @late_insec=replace(@late_insec,'-','')
									exec dbo.Return_DurHourMin @late_insec ,@late_In output
								End
						  Else
							Begin
								set @late_in=''
							End		  
						  if @late_insec > 0
							Begin
								exec dbo.Return_DurHourMin  @late_insec ,@late_Out output
							End
						  Else
							Begin
								set @Late_Out=''					
							End	
						  if @Early_In_Sec  > 0 exec dbo.Return_DurHourMin  @Early_In_Sec ,@Early_In output  
						  
						  if @Erlyoutsec > 0 exec dbo.Return_DurHourMin  @Erlyoutsec ,@Early_Out output       
						  --select @Working_sec,@Early_In,@Working_secAt,@WORKING_HOURS
						  --print 'sdp'
						  if @Working_sec > 0 exec dbo.Return_DurHourMin  @Working_secAt ,@WORKING_HOURS output 
						  --print 'sdp'
						   if @late_out_sec_auto > 0  exec dbo.Return_DurHourMin  @late_out_sec_auto ,@late_Out output  
							 
							if @Erlyoutsec=0
								Begin
									set @Early_Out=''
								End
						
						 if @late_out_sec_auto=0
							Begin
								set @late_out=''
							End
						if @late_insec=0
							Begin
								set @late_in=''
							End	
							--select @In_Time_Autoshift
						--select * from #Emp_Inout
						--return
						if @Early_In_Sec>0
							Begin
								set @late_in=''
							End
						
						set @Toatl_Working_sec = isnull(@Toatl_Working_sec,0) + @Working_secAt
										 update #Emp_Inout set Shift_ID=@Shift_ID_Autoshift,
										 Late_In=@Late_In,
										 Late_Out=@Late_Out,
										 Early_In=@Early_In,
										 Early_Out=@Early_Out,
										 Late_In_Sec=@late_insec,
										 Shift_St_Datetime=@Shift_st_time_auto,
										 Shift_en_Datetime=@Shift_Out_time_auto,
										 Late_Out_Sec=0
										where emp_id=@Emp_ID_AutoShift and In_Time=@In_Time_Autoshift
										And Shift_ID <> @Shift_ID_Autoshift
						--select * from #Emp_Inout
						--return				
				
					--Update #Data set Shift_ID=@Shift_ID_Autoshift,Shift_Start_Time= cast(CONVERT(VARCHAR(11), In_time, 121)  + CONVERT(VARCHAR(12), @Shift_start_time_Autoshift, 114) as datetime)  from #Data
					--where Emp_ID=@Emp_ID_AutoShift and In_time=@In_Time_Autoshift And Shift_ID <> @Shift_ID_Autoshift
				 End					
			fetch next from curautoshift into @Emp_ID_AutoShift,@In_Time_Autoshift,@New_Shift_ID,@Out_Time_Autoshift,@Shift_St_Time_Autoshift,@Shift_End_Time_Autoshift
		                  
			end 
		            
		 close curautoshift                    
		 deallocate curautoshift   
-------------Ended by Sumit 19092015------------------------------------------------------------------------------  
   End         
  
  
        -- Added by rohit on 22082014
      exec dbo.GET_HalfDay_Date @Cmp_ID,@Emp_ID,@From_Date,@To_Date,0,@HalfDayDate output  
     
   if(charindex(CONVERT(nvarchar(11),@Temp_Month_Date,109),@HalfDayDate) > 0)  
    begin      
		
	set @Shift_St_Time = @Half_St_Time
	set @Shift_End_Time = @Half_End_Time
	 set @shift_Dur= @Half_Dur       
	  set @Shift_Sec = 0     
	  set @Shift_Sec  = dbo.F_Return_Sec(@Shift_Dur) 
    end 
  -- Ended by rohit
  
  
  
  ---- Added by Hardik on 11/10/2011 for Holiday, Weekoff and Leave checking  
  if charindex(cast(@Temp_Month_Date as varchar(11)),@StrHoliday_Date,0) > 0   
   begin  
    set @Weekoff_Entry = @Weekoff_Entry  
  
    If not exists (Select 1 From #Emp_Inout Where emp_id = @Emp_ID And for_Date = @Temp_Month_Date)  
     Begin  
		Declare @Is_Half_Holiday tinyint
		set @Is_Half_Holiday = 0
		
		select @Is_Half_Holiday= isnull(is_Half_day,0) from #Emp_Holiday where Emp_Id = @Emp_ID and For_Date = @Temp_Month_Date
		if @Is_Half_Holiday = 0 
		begin
			 INSERT INTO #Emp_Inout   
			(Emp_id,For_Date , Dept_id ,Grd_ID,Type_ID,Desig_ID ,Shift_ID,In_Time ,Out_Time ,Duration ,      
			  Duration_sec  , Late_In ,Late_Out , Early_In , Early_Out , Leave ,Shift_Sec,Shift_Dur,Total_Work,Less_Work,More_work,Reason,Late_in_sec,Early_Out_sec,Total_Less_work_sec,Late_in_Count,Early_Out_count,Shift_St_Datetime,Shift_en_Datetime      
			  ,Working_Sec_AfterShift,Working_AfterShift_Count,Inout_Reason,AB_LEAVE,Total_More_work_Sec,Is_OT_Applicable,Monthly_Deficit_Adjust_OT_Hrs,Late_Comm_sec,Branch_Id )   
			  VALUES   
			 (@emp_id ,@Temp_Month_Date ,@Dept_id ,@Grd_ID ,@Type_ID,@Desig_ID,@Shift_ID,Null,Null ,'-',      
			   0, '-' ,'-', '-', '-', '',0,'-','-','-','-','-',0,0,0,0,0,Null,Null 
			  ,0,0,'-','HO',0,@Emp_OT,@Monthly_Deficit_Adjust_OT_Hrs,@Late_Comm_sec,@Branch_Id_Cur )      
	   end
       else
       begin
		  INSERT INTO #Emp_Inout   
			(Emp_id,For_Date , Dept_id ,Grd_ID,Type_ID,Desig_ID ,Shift_ID,In_Time ,Out_Time ,Duration ,      
			  Duration_sec  , Late_In ,Late_Out , Early_In , Early_Out , Leave ,Shift_Sec,Shift_Dur,Total_Work,Less_Work,More_work,Reason,Late_in_sec,Early_Out_sec,Total_Less_work_sec,Late_in_Count,Early_Out_count,Shift_St_Datetime,Shift_en_Datetime      
			  ,Working_Sec_AfterShift,Working_AfterShift_Count,Inout_Reason,AB_LEAVE,Total_More_work_Sec,Is_OT_Applicable,Monthly_Deficit_Adjust_OT_Hrs,Late_Comm_sec,Branch_Id )   
		  VALUES   
			  (@emp_id ,@Temp_Month_Date ,@Dept_id ,@Grd_ID ,@Type_ID,@Desig_ID,@Shift_ID,Null,Null ,'-',      
			  0, '-' ,'-', '-', '-', '',0,'-','-','-','-','-',0,0,0,0,0,Null,Null 
			 ,0,0,'-','HHO',0,@Emp_OT,@Monthly_Deficit_Adjust_OT_Hrs,@Late_Comm_sec,@Branch_Id_Cur )     
		end 
     End  
    Else  
     Begin  
		
		If @Emp_OT = 1
		begin
			Update #Emp_Inout Set AB_LEAVE = 'HO', Total_More_work_Sec = Total_Work_Sec, More_Work = Total_work,Shift_Sec = 0 
			from #Emp_Inout EI inner join #Emp_Holiday EH  on EH.Emp_Id = EI.emp_id and EH.For_Date = EI.for_Date 
			 Where EI.emp_id = @Emp_ID And EI.for_Date = @Temp_Month_Date and EH.is_Half_day = 0
			  
			 Update #Emp_Inout Set AB_LEAVE = 'HHO', Total_More_work_Sec = cast(Total_Work_Sec as numeric(18,2)) - Datediff(s,Shift_St_Datetime,Shift_en_Datetime)/2, More_Work =  dbo.F_Return_Hours(cast(isnull(Total_Work_Sec,0) as numeric(18,2))- Datediff(s,Shift_St_Datetime,Shift_en_Datetime)/2),Shift_Sec = 0 
			from #Emp_Inout EI inner join #Emp_Holiday EH  on EH.Emp_Id = EI.emp_id and EH.For_Date = EI.for_Date 
			 Where EI.emp_id = @Emp_ID And EI.for_Date = @Temp_Month_Date and EH.is_Half_day = 1
			 
			if @Tras_Week_ot = 0  --Added by nilesh patel on 12082015(Working on Weekoff & Transfer weekoff is not select that time consider as working our
					Begin
					
						if @Diff_Sec > 0 
							Begin
								Declare @More_Work_2 Varchar(100)
								Set @More_Work_2 = '-'
								exec dbo.Return_DurHourMin @Diff_Sec , @More_Work_2 output
								
								Update #Emp_Inout Set More_Work = @More_Work_2, Total_More_work_Sec = @Diff_Sec Where emp_id = @Emp_ID And for_Date = @Temp_Month_Date and AB_LEAVE = 'HO'
							End
						Else
							Begin
						
								Update #Emp_Inout Set More_Work = '-', Total_More_work_Sec = 0 Where emp_id = @Emp_ID And for_Date = @Temp_Month_Date and AB_LEAVE = 'HO'  
							End
					End
		end
		Else
		begin
			Update #Emp_Inout Set AB_LEAVE = 'HO',Shift_Sec = 0 
			from #Emp_Inout EI inner join #Emp_Holiday EH  on EH.Emp_Id = EI.emp_id and EH.For_Date = EI.for_Date 
			Where EI.emp_id = @Emp_ID And EI.for_Date = @Temp_Month_Date and EH.is_Half_day = 0
			
			Update #Emp_Inout Set AB_LEAVE = 'HHO',Shift_Sec = 0 
			from #Emp_Inout EI inner join #Emp_Holiday EH  on EH.Emp_Id = EI.emp_id and EH.For_Date = EI.for_Date 
			Where EI.emp_id = @Emp_ID And EI.for_Date = @Temp_Month_Date and EH.is_Half_day = 1
		end
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
        0, '-' ,'-', '-', '-', '',0,'-','-','-','-','-',0,0,0,0,0 ,@Shift_St_Time,@Shift_End_Time --,Null,Null   
       ,0,0,'-','WO',0,@Emp_OT,@Monthly_Deficit_Adjust_OT_Hrs,@Late_Comm_sec,@Branch_Id_Cur  )  
       
         
     End  
    Else  
     Begin  
		
		If @Emp_OT = 1
			Begin 
				Update #Emp_Inout Set AB_LEAVE = 'WO', Total_More_work_Sec = Total_Work_Sec, More_Work = Total_work, Total_Less_work_Sec = 0,Less_Work = '',Shift_Sec = 0 Where emp_id = @Emp_ID And for_Date = @Temp_Month_Date   
				
				if @Tras_Week_ot = 0  --Added by nilesh patel on 12082015(Working on Weekoff & Transfer weekoff is not select that time consider as working our
					Begin
					
						if @Diff_Sec > 0 
							Begin
								Declare @More_Work_1 Varchar(100)
								Set @More_Work_1 = '-'
								exec dbo.Return_DurHourMin @Diff_Sec , @More_Work_1 output
								
								Update #Emp_Inout Set More_Work = @More_Work_1, Total_More_work_Sec = @Diff_Sec Where emp_id = @Emp_ID And for_Date = @Temp_Month_Date and AB_LEAVE = 'WO'
								
							End
						Else
							Begin
								Update #Emp_Inout Set More_Work = '-', Total_More_work_Sec = 0 Where emp_id = @Emp_ID And for_Date = @Temp_Month_Date and AB_LEAVE = 'WO' 
							End
					End
			End
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
     ,@leave_out_time=isnull(LAD.leave_out_time,'01-jan-1900'),@leave_in_time=isnull(lad.leave_in_time,'01-jan-1900')
     From dbo.T0120_LEAVE_APPROVAL LA WITH (NOLOCK) Inner Join   
       dbo.T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) On LA.Leave_Approval_ID = LAD.Leave_Approval_ID  
       Where From_Date <= @Temp_Month_Date And To_Date >= @Temp_Month_Date And Emp_ID = @Emp_ID And LA.Approval_Status = 'A'
	   and LA.Leave_Approval_ID  not In (select Leave_Approval_ID from dbo.T0150_LEAVE_CANCELLATION LC WITH (NOLOCK) where  LC.cmp_id=@Cmp_ID and LC.Emp_ID = @Emp_ID and LC.For_Date = @Temp_Month_Date and LC.Is_Approve=1)
	

     Select @Leave_Name = Leave_Code,@apply_hourly = isnull(apply_hourly,0) From dbo.T0040_LEAVE_MASTER WITH (NOLOCK) Where Leave_ID = @Leave_ID  
     Select @Leave_Days = isnull(leave_used,0) From dbo.T0140_LEAVE_TRANSACTION  WITH (NOLOCK) Where Leave_ID = @Leave_ID  and Emp_ID=@Emp_ID and For_Date = @Temp_Month_Date
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
					
						-- Added by rohit on 20082014
					if @Report_Call='Shift_End' or @Report_Call='Time_Loss'			----Time_Loss is Added By Ramiz on 29/09/2015
					begin
					set @leave_Detail=''
					if @apply_hourly = 0
					begin
						set @leave_Detail=@leave_Detail + 'Day Leave ,'
						if upper(@Leave_Assign_As) = 'PART DAY'
						begin
							set @leave_Detail=@leave_Detail + isnull(LTRIM(RIGHT(CONVERT(VARCHAR(20), @leave_out_time, 100), 7)),'') + ' - ' + isnull(LTRIM(RIGHT(CONVERT(VARCHAR(20), @leave_in_time, 100), 7)),'') 
						end
						else
						begin
						
							set @leave_Detail=@leave_Detail + ' - ' + @Leave_Assign_As + ' - ' + cast(@Leave_Days as varchar(10))
							
						end
					end
					else if @apply_hourly = 1
					begin
						set @leave_Detail=@leave_Detail + 'Hourly Leave,'
						set @leave_Detail=@leave_Detail + isnull(LTRIM(RIGHT(CONVERT(VARCHAR(20), @leave_out_time, 100), 7)),'') + ' - ' + isnull(LTRIM(RIGHT(CONVERT(VARCHAR(20), @leave_in_time, 100), 7)),'') 
					end
					 
					 Update #Emp_Inout Set AB_LEAVE = @Leave_Name + ' - ' + @leave_Detail  Where emp_id = @Emp_ID And for_Date = @Temp_Month_Date  			
					-- Ended by rohit
						-- Added by rohit on 08102014
					if @Shift_St_Datetime =@leave_out_time
					 begin
						Update #Emp_Inout Set  Late_In = 0,late_in_sec=0,late_in_count=0  Where emp_id = @Emp_ID And for_Date = @Temp_Month_Date  			
					 end
					 if @Shift_End_dateTime = @leave_In_Time
					 begin
						Update #Emp_Inout Set Early_Out = 0,early_out_sec=0,Early_Out_count=0  Where emp_id = @Emp_ID And for_Date = @Temp_Month_Date  			
					 end
										
					if upper(@Leave_Assign_As) = 'FIRST HALF'
					begin
						Update #Emp_Inout Set  Late_In = 0,late_in_sec=0,late_in_count=0  Where emp_id = @Emp_ID And for_Date = @Temp_Month_Date  			
					end
					
					if upper(@Leave_Assign_As) = 'SECOND HALF'
					begin
					Update #Emp_Inout Set Early_Out = 0,early_out_sec=0,Early_Out_count=0  Where emp_id = @Emp_ID And for_Date = @Temp_Month_Date  			
					end
					
					-- Ended by rohit on 08102014
			
					
					End
					
		End
	Else
		Begin
			Update #Emp_Inout Set AB_LEAVE = @Leave_Name,Total_Less_work_Sec = 0,Less_Work = '',Total_More_work_Sec = 0, More_Work='' Where emp_id = @Emp_ID And for_Date = @Temp_Month_Date  			
			
				-- Added by rohit on 20082014
			if @Report_Call='Shift_End' or @Report_call = 'Time_loss'		--Time_Loss is Added By Ramiz on 29/09/2015
			begin
			
			set @leave_Detail=''
			if @apply_hourly = 0
			begin
				set @leave_Detail=@leave_Detail + 'Day Leave ,'
				if upper(@Leave_Assign_As) = 'PART DAY'
				begin
					set @leave_Detail=@leave_Detail + isnull(LTRIM(RIGHT(CONVERT(VARCHAR(20), @leave_out_time, 100), 7)),'') + ' - ' + isnull(LTRIM(RIGHT(CONVERT(VARCHAR(20), @leave_in_time, 100), 7)),'') 
				end
				else
				begin
					set @leave_Detail=@leave_Detail + ' - ' + cast(@Leave_Assign_As as varchar) + ' - ' + cast(@Leave_Days as varchar(10))
				end
			end
			else if @apply_hourly = 1
			begin
				set @leave_Detail=@leave_Detail + 'Hourly Leave,'
				set @leave_Detail=@leave_Detail + isnull(LTRIM(RIGHT(CONVERT(VARCHAR(20), @leave_out_time, 100), 7)),'') + ' - ' + isnull(LTRIM(RIGHT(CONVERT(VARCHAR(20), @leave_in_time, 100), 7)),'') 
			end
			 
			 Update #Emp_Inout Set AB_LEAVE = @Leave_Name + ' - ' + @leave_Detail  Where emp_id = @Emp_ID And for_Date = @Temp_Month_Date  		
			 
			 	-- Added by rohit on 08102014
					if @Shift_St_Datetime =@leave_out_time
					 begin
						Update #Emp_Inout Set  Late_In = 0,late_in_sec=0,late_in_count=0  Where emp_id = @Emp_ID And for_Date = @Temp_Month_Date  			
					 end
					 if @Shift_End_dateTime = @leave_In_Time
					 begin
						Update #Emp_Inout Set Early_Out = 0,early_out_sec=0,Early_Out_count=0  Where emp_id = @Emp_ID And for_Date = @Temp_Month_Date  			
					 end
										
					if upper(@Leave_Assign_As) = 'FIRST HALF'
					begin
						Update #Emp_Inout Set  Late_In = 0,late_in_sec=0,late_in_count=0  Where emp_id = @Emp_ID And for_Date = @Temp_Month_Date  			
					end
					
					if upper(@Leave_Assign_As) = 'SECOND HALF'
					begin
					Update #Emp_Inout Set Early_Out = 0,early_out_sec=0,Early_Out_count=0  Where emp_id = @Emp_ID And for_Date = @Temp_Month_Date  			
					end
					
					-- Ended by rohit on 08102014
			
			 	
			end
			-- Ended by rohit
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
  ------------- End by Hardik   
            
      
      set @Temp_Month_Date = Dateadd(d,1,@Temp_Month_Date)       
     end       
   FETCH NEXT FROM CUR_EMP INTO @EMP_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Late_Comm_sec,@Early_Limit_Sec,@Emp_OT,@Emp_OT_Min_Limit_Sec,@Emp_OT_Max_Limit_Sec,@Monthly_Deficit_Adjust_OT_Hrs,@Branch_Id_Cur
  end      
 close cur_Emp      
 deallocate cur_Emp      
      

 
 If @Report_call = 'IN-OUT' or @Report_call = 'Inout_Page'
 begin 
	
	  if (@InOut_Tag = 'D') -- Added by nilesh on 22122014 For Rotation Attendance Dashboard --Start 
		begin
			   select E_IO.Late_In,E_IO.Early_Out,E_IO.emp_id
			   From #Emp_Inout as E_IO inner join dbo.T0080_EMP_MASTER E WITH (NOLOCK) on E.emp_ID = E_IO.Emp_Id Left Outer join  
			   dbo.T0040_SHIFT_MASTER WITH (NOLOCK) on       
			   dbo.T0040_SHIFT_MASTER.Shift_ID = E_IO.Shift_ID inner join dbo.T0040_GRADE_MASTER WITH (NOLOCK) on      
			   dbo.T0040_GRADE_MASTER.Grd_ID = E_IO.Grd_ID  left join dbo.T0040_DEPARTMENT_MASTER WITH (NOLOCK) on       
			   dbo.T0040_DEPARTMENT_MASTER.Dept_id = E_IO.dept_id left outer join dbo.T0040_TYPE_MASTER Et WITH (NOLOCK) on       
			   E_IO.Type_ID = Et.Type_ID left Outer Join dbo.T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on       
			   E_IO.Desig_ID = DM.Desig_ID inner join dbo.T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.Cmp_ID = CM.CMP_ID Inner Join
			   T0030_BRANCH_MASTER BM WITH (NOLOCK) on E_IO.Branch_Id = BM.Branch_ID
			   Where cast(cast(For_Date as varchar(11)) as smalldatetime) >= cast(cast(@From_Date  as varchar(11)) as smalldatetime)  
			   and cast(cast(For_Date as varchar(11)) as smalldatetime) <= cast(cast(@To_Date  as varchar(11)) as smalldatetime)   
			   and ( In_Time is not null  or Out_Time is not null  or ab_leave is not null ) 
			   Order by RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500) 
	    
		End  -- Added by nilesh on 22122014 For Rotation Attendance Dashboard --End
	 Else
		Begin		
						
			   select E_IO.*,Emp_full_Name,Alpha_Emp_Code, Emp_Code,Grd_Name,Shift_name,dept_name ,Type_Name,Desig_Name,CMP_NAME,CMP_ADDRESS,      
					   @From_Date as P_From_date ,@To_Date as P_To_Date  
					   ,dbo.F_GET_AMPM (Shift_St_Datetime) as Shift_Start_Time,
					   dbo.F_GET_AMPM (Shift_End_Time) as Shift_End_Time,
					   
					   --- Modify Jignesh 23-Oct-2012 ( add 1 min if Sec > 30 )
					   --dbo.F_GET_AMPM (In_Time) as Actual_In_Time,
					   dbo.F_GET_AMPM (case when  datepart(s,In_Time) > 30 then DATEADD(ss,30,In_Time) else In_Time end ) as  Actual_In_Time,  
					   --dbo.F_GET_AMPM (Out_Time) as Actual_Out_Time , 
					   dbo.F_GET_AMPM (case when  datepart(s,Out_Time) > 30 then DATEADD(ss,30,Out_Time) else Out_Time end ) as  Actual_Out_Time,  
					   
					   convert(varchar(10),for_date,103)as On_Date  --CAST(for_Date as varchar(11)) as On_Date,
					   ,@leave_Footer as Leave_Footer
					   --,Is_OT_Applicable,Monthly_Deficit_Adjust_OT_Hrs
					   ,Branch_Name
					   ,BM.Comp_Name, BM.Branch_Address --Added by Nimesh 31-Jul-2015 (For Employee's Branch Address)
						,DM.Desig_Dis_No ---added jimit 24082015
			   From #Emp_Inout as E_IO inner join dbo.T0080_EMP_MASTER E WITH (NOLOCK) on E.emp_ID = E_IO.Emp_Id Left Outer join  
					   dbo.T0040_SHIFT_MASTER WITH (NOLOCK) on       
					   dbo.T0040_SHIFT_MASTER.Shift_ID = E_IO.Shift_ID inner join dbo.T0040_GRADE_MASTER WITH (NOLOCK) on      
					   dbo.T0040_GRADE_MASTER.Grd_ID = E_IO.Grd_ID  left join dbo.T0040_DEPARTMENT_MASTER WITH (NOLOCK) on       
					   dbo.T0040_DEPARTMENT_MASTER.Dept_id = E_IO.dept_id left outer join dbo.T0040_TYPE_MASTER Et WITH (NOLOCK) on       
					   E_IO.Type_ID = Et.Type_ID left Outer Join dbo.T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on       
					   E_IO.Desig_ID = DM.Desig_ID inner join dbo.T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.Cmp_ID = CM.CMP_ID Inner Join
					   T0030_BRANCH_MASTER BM WITH (NOLOCK) on E_IO.Branch_Id = BM.Branch_ID
			  Where cast(cast(For_Date as varchar(11)) as smalldatetime) >= cast(cast(@From_Date  as varchar(11)) as smalldatetime)  
					  and cast(cast(For_Date as varchar(11)) as smalldatetime) <= cast(cast(@To_Date  as varchar(11)) as smalldatetime)   
					  and ( In_Time is not null  or Out_Time is not null  or ab_leave is not null ) 
			  Order by CASE WHEN @Order_By='Enroll_No' THEN RIGHT(REPLICATE('0',21) + CAST(E.Enroll_No AS VARCHAR), 21)  --Added by Jaina 31 July 2015 start
							WHEN @Order_By='Name' THEN E.Emp_Full_Name
							When @Order_By = 'Designation' then (CASE WHEN  Dm.Desig_dis_No  = 0 THEN DM.Desig_Name ELSE RIGHT(REPLICATE('0',21) + CAST(DM.Desig_dis_No AS VARCHAR), 21)   END)     --added jimit 25092015
							--ELSE RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500) 
						End,Case When IsNumeric(Replace(Replace(E.Alpha_Emp_Code,'="',''),'"','')) = 1 then Right(Replicate('0',21) + Replace(Replace(E.Alpha_Emp_Code,'="',''),'"',''), 20)
								 When IsNumeric(Replace(Replace(E.Alpha_Emp_Code,'="',''),'"','')) = 0 then Left(Replace(Replace(E.Alpha_Emp_Code,'="',''),'"','') + Replicate('',21), 20)
								 Else Replace(Replace(E.Alpha_Emp_Code,'="',''),'"','') End
						--RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500)
				  --Added by Jaina 31 July 2015 end
				  
				  return
				 End
		end      
else if @Report_call = 'SUMMARY'      
 begin 
      
  select * from       
   ( select E_IO.Emp_ID,E_IO.SysDate,Emp_full_Name,Alpha_Emp_Code,Emp_Code,Grd_Name,Shift_name,dept_name,Type_Name,Desig_Name,
   SUM(Total_Work_Sec) - SUM(ISNULL(Total_More_work_Sec,0)) as Total_Work_Sec, SUM(Shift_Sec) as Shift_Sec,
    sum(Late_in_sec) as Late_in_sec ,sum(Early_Out_sec) as Early_Out_sec, sum(Total_Less_Work_sec) as Total_Less_Work_sec,
    sum(Total_More_Work_sec) as Total_More_Work_sec,
    sum(Late_In_Count) as Late_In_Count,sum(Early_Out_Count) as Early_Out_Count      
    ,sum(Working_sec_afterShift) as Working_sec_afterShift,
    sum(Working_afterShift_count) as Working_afterShift_count     
    , dbo.F_Return_Hours(sum(Total_Work_Sec)- SUM(ISNULL(Total_More_work_Sec,0))) as Total_Work_Hours       
    , dbo.F_Return_Hours(sum(Shift_Sec)) as Shift_Hours       
    , dbo.F_Return_Hours(sum(late_in_sec)) as Late_in_Hours       
    , dbo.F_Return_Hours(sum(Early_Out_sec)) as Early_Out_Hours       
    , dbo.F_Return_Hours(sum(Total_More_work_Sec)) as Total_More_Work_Hours       
    , dbo.F_Return_Hours(sum(Total_Less_Work_sec)) as Total_Less_Work_Hours       
    , dbo.F_Return_Hours(sum(Working_Sec_AfterShift)) as Working_AfterShift_Hours
    ,COUNT(Case When Shift_Sec = 0 OR AB_LEAVE = 'WO' or AB_LEAVE = 'HO' OR AB_LEAVE = '-' Then Null Else 1 End) as Working_Days
    ,Late_Comm_sec, (Late_Comm_sec/3600) As Late_Grace_Hour
    ,Case When Monthly_Deficit_Adjust_OT_Hrs = 1 then 
		Case When Sum(Total_Less_work_Sec) > SUM(Total_More_work_Sec)  Then
			0
		Else 				
			Case When Is_OT_Applicable = 1 Then
				SUM(Total_More_work_Sec) - Sum(Total_Less_work_Sec)
			Else 0 End
		End
	Else 
		Case When Is_OT_Applicable = 1 Then SUM(Total_More_work_Sec) Else 0 End 
	End As Actual_OT_Sec

	,dbo.F_Return_Hours(Case When Monthly_Deficit_Adjust_OT_Hrs = 1 then 
		Case When Sum(Total_Less_work_Sec) > SUM(Total_More_work_Sec)  Then
			0
		Else 				
			Case When Is_OT_Applicable = 1 Then
				SUM(Total_More_work_Sec) - Sum(Total_Less_work_Sec)
			Else 0 End
		End
	Else 
		Case When Is_OT_Applicable = 1 Then SUM(Total_More_work_Sec) Else 0 End 
	End) As Actual_OT_Hour	

    ,Case When Monthly_Deficit_Adjust_OT_Hrs = 1 then 
		Case When Sum(Total_Less_work_Sec) > SUM(Total_More_work_Sec) Then
			Case When COUNT(Case When Shift_Sec = 0 OR AB_LEAVE = 'WO' or AB_LEAVE = 'HO' Then Null Else 1 End) * Isnull(Late_Comm_sec,0) > Sum(Total_Less_work_Sec) - SUM(Total_More_work_Sec) Then
					0
				Else (Sum(Total_Less_work_Sec) - SUM(Total_More_work_Sec)) - (COUNT(Case When Shift_Sec = 0 OR AB_LEAVE = 'WO' or AB_LEAVE = 'HO' Then Null Else 1 End) * Isnull(Late_Comm_sec,0))
			End
		Else 0 End
	Else 
		SUM(Total_Less_work_Sec)
	End As Actual_Deficit_Sec

	,dbo.F_Return_Hours(Case When Monthly_Deficit_Adjust_OT_Hrs = 1 then 
		Case When Sum(Total_Less_work_Sec) > COUNT(Case When Shift_Sec = 0 OR AB_LEAVE = 'WO' or AB_LEAVE = 'HO' Then Null Else 1 End) * Isnull(Late_Comm_sec,0) Then
			Case When SUM(Total_More_work_Sec) > Sum(Total_Less_work_Sec) - COUNT(Case When Shift_Sec = 0 OR AB_LEAVE = 'WO' or AB_LEAVE = 'HO' Then Null Else 1 End) * Isnull(Late_Comm_sec,0) Then
					0
				Else (Sum(Total_Less_work_Sec) - COUNT(Case When Shift_Sec = 0 OR AB_LEAVE = 'WO' or AB_LEAVE = 'HO' Then Null Else 1 End) * Isnull(Late_Comm_sec,0)) - SUM(Total_More_work_Sec)
			End
		Else 0 End
	Else 
		SUM(Total_More_work_Sec)
	End) As Actual_Deficit_Hour
		
    ,Is_OT_Applicable,Monthly_Deficit_Adjust_OT_Hrs
    ,CMP_NAME,CMP_ADDRESS      
    ,@From_Date as P_From_date ,@To_Date as P_To_Date   
    ,DM.Desig_Dis_No,E.Enroll_No   --added jimit 24082015      
   from #Emp_Inout as E_IO inner join dbo.T0080_EMP_MASTER E WITH (NOLOCK) on E.emp_ID = E_IO.Emp_Id inner join   
    dbo.T0040_SHIFT_MASTER WITH (NOLOCK) on       
    dbo.T0040_SHIFT_MASTER.Shift_ID = E_IO.Shift_ID inner join dbo.T0040_GRADE_MASTER WITH (NOLOCK) on      
    dbo.T0040_GRADE_MASTER.Grd_ID = E_IO.Grd_ID  left join dbo.T0040_DEPARTMENT_MASTER WITH (NOLOCK) on       
    dbo.T0040_DEPARTMENT_MASTER.Dept_id = E_IO.dept_id left outer  join dbo.T0040_TYPE_MASTER Et WITH (NOLOCK) on       
    E_IO.Type_ID = Et.Type_ID left Outer Join dbo.T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on       
    E_IO.Desig_ID = DM.Desig_ID  inner join dbo.T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.Cmp_ID = CM.CMP_ID      
   Where cast(cast(For_Date as varchar(11)) as smalldatetime) >= cast(cast(@From_Date  as varchar(11)) as smalldatetime)      
    and cast(cast(For_Date as varchar(11)) as smalldatetime) <= cast(cast(@To_Date  as varchar(11)) as smalldatetime)       
   Group by E_IO.Emp_ID,Emp_full_Name,Emp_Code,Grd_Name,Shift_name,dept_name,Type_Name,Desig_Name      
    ,CMP_NAME,CMP_ADDRESS, E_IO.Sysdate,Is_OT_Applicable,Monthly_Deficit_Adjust_OT_Hrs ,Late_Comm_sec,Alpha_Emp_Code,Desig_Dis_No,E.Enroll_No    
   )Qry      
  Where Qry.Late_In_Count > 0 or Qry.Early_Out_Count > 0 or Total_less_Work_sec > 0 or Total_More_Work_sec > 0 --or Qry.Working_afterShift_count > 0      
 end       
 else if @Report_call = 'SALARY'      
 begin      
 
  select * Into ##Salary from       
   ( select E_IO.Emp_ID,E_IO.SysDate,Emp_full_Name,Alpha_Emp_Code,Emp_Code,Grd_Name,Shift_name,dept_name,Type_Name,Desig_Name,
   SUM(Total_Work_Sec) as Total_Work_Sec, SUM(Shift_Sec) as Shift_Sec,
    sum(Late_in_sec) as Late_in_sec ,sum(Early_Out_sec) as Early_Out_sec, sum(Total_Less_Work_sec) as Total_Less_Work_sec,
    sum(Total_More_Work_sec) as Total_More_Work_sec,
    sum(Late_In_Count) as Late_In_Count,sum(Early_Out_Count) as Early_Out_Count      
    ,sum(Working_sec_afterShift) as Working_sec_afterShift,
    sum(Working_afterShift_count) as Working_afterShift_count     
    , dbo.F_Return_Hours(sum(Total_Work_Sec)) as Total_Work_Hours       
    , dbo.F_Return_Hours(sum(Shift_Sec)) as Shift_Hours       
    , dbo.F_Return_Hours(sum(late_in_sec)) as Late_in_Hours       
    , dbo.F_Return_Hours(sum(Early_Out_sec)) as Early_Out_Hours       
    , dbo.F_Return_Hours(sum(Total_More_work_Sec)) as Total_More_Work_Hours       
    , dbo.F_Return_Hours(sum(Total_Less_Work_sec)) as Total_Less_Work_Hours       
    , dbo.F_Return_Hours(sum(Working_Sec_AfterShift)) as Working_AfterShift_Hours
    ,COUNT(Case When Shift_Sec = 0 OR AB_LEAVE = 'WO' or AB_LEAVE = 'HO' OR AB_LEAVE = '-' Then Null Else 1 End) as Working_Days
    ,Late_Comm_sec, (Late_Comm_sec/3600) As Late_Grace_Hour
    ,Case When Monthly_Deficit_Adjust_OT_Hrs = 1 then 
		Case When Sum(Total_Less_work_Sec) > SUM(Total_More_work_Sec)  Then
			0
		Else 				
			Case When Is_OT_Applicable = 1 Then
				SUM(Total_More_work_Sec) - Sum(Total_Less_work_Sec)
			Else 0 End
		End
	Else 
		Case When Is_OT_Applicable = 1 Then SUM(Total_More_work_Sec) Else 0 End 
	End As Actual_OT_Sec

	,dbo.F_Return_Hours(Case When Monthly_Deficit_Adjust_OT_Hrs = 1 then 
		Case When Sum(Total_Less_work_Sec) > SUM(Total_More_work_Sec)  Then
			0
		Else 				
			Case When Is_OT_Applicable = 1 Then
				SUM(Total_More_work_Sec) - Sum(Total_Less_work_Sec)
			Else 0 End
		End
	Else 
		Case When Is_OT_Applicable = 1 Then SUM(Total_More_work_Sec) Else 0 End 
	End) As Actual_OT_Hour	

    ,Case When Monthly_Deficit_Adjust_OT_Hrs = 1 then 
		Case When Sum(Total_Less_work_Sec) > SUM(Total_More_work_Sec) Then
			Case When COUNT(Case When Shift_Sec = 0 OR AB_LEAVE = 'WO' or AB_LEAVE = 'HO' Then Null Else 1 End) * Isnull(Late_Comm_sec,0) > Sum(Total_Less_work_Sec) - SUM(Total_More_work_Sec) Then
					0
				Else (Sum(Total_Less_work_Sec) - SUM(Total_More_work_Sec)) - (COUNT(Case When Shift_Sec = 0 OR AB_LEAVE = 'WO' or AB_LEAVE = 'HO' Then Null Else 1 End) * Isnull(Late_Comm_sec,0))
			End
		Else 0 End
	Else 
		SUM(Total_Less_work_Sec)
	End As Actual_Deficit_Sec

	,dbo.F_Return_Hours(Case When Monthly_Deficit_Adjust_OT_Hrs = 1 then 
		Case When Sum(Total_Less_work_Sec) > COUNT(Case When Shift_Sec = 0 OR AB_LEAVE = 'WO' or AB_LEAVE = 'HO' Then Null Else 1 End) * Isnull(Late_Comm_sec,0) Then
			Case When SUM(Total_More_work_Sec) > Sum(Total_Less_work_Sec) - COUNT(Case When Shift_Sec = 0 OR AB_LEAVE = 'WO' or AB_LEAVE = 'HO' Then Null Else 1 End) * Isnull(Late_Comm_sec,0) Then
					0
				Else (Sum(Total_Less_work_Sec) - COUNT(Case When Shift_Sec = 0 OR AB_LEAVE = 'WO' or AB_LEAVE = 'HO' Then Null Else 1 End) * Isnull(Late_Comm_sec,0)) - SUM(Total_More_work_Sec)
			End
		Else 0 End
	Else 
		SUM(Total_More_work_Sec)
	End) As Actual_Deficit_Hour
		
    ,Is_OT_Applicable,Monthly_Deficit_Adjust_OT_Hrs
    ,CMP_NAME,CMP_ADDRESS      
    ,@From_Date as P_From_date ,@To_Date as P_To_Date         
   from #Emp_Inout as E_IO inner join dbo.T0080_EMP_MASTER E WITH (NOLOCK) on E.emp_ID = E_IO.Emp_Id inner join   
    dbo.T0040_SHIFT_MASTER WITH (NOLOCK) on       
    dbo.T0040_SHIFT_MASTER.Shift_ID = E_IO.Shift_ID inner join dbo.T0040_GRADE_MASTER WITH (NOLOCK) on      
    dbo.T0040_GRADE_MASTER.Grd_ID = E_IO.Grd_ID  left join dbo.T0040_DEPARTMENT_MASTER WITH (NOLOCK) on       
    dbo.T0040_DEPARTMENT_MASTER.Dept_id = E_IO.dept_id left outer  join dbo.T0040_TYPE_MASTER Et WITH (NOLOCK) on       
    E_IO.Type_ID = Et.Type_ID left Outer Join dbo.T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on       
    E_IO.Desig_ID = DM.Desig_ID  inner join dbo.T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.Cmp_ID = CM.CMP_ID      
   Where cast(cast(For_Date as varchar(11)) as smalldatetime) >= cast(cast(@From_Date  as varchar(11)) as smalldatetime)      
    and cast(cast(For_Date as varchar(11)) as smalldatetime) <= cast(cast(@To_Date  as varchar(11)) as smalldatetime)       
   Group by E_IO.Emp_ID,Emp_full_Name,Emp_Code,Grd_Name,Shift_name,dept_name,Type_Name,Desig_Name      
    ,CMP_NAME,CMP_ADDRESS, E_IO.Sysdate,Is_OT_Applicable,Monthly_Deficit_Adjust_OT_Hrs ,Late_Comm_sec,Alpha_Emp_Code     
   )Qry      
  Where Qry.Late_In_Count > 0 or Qry.Early_Out_Count > 0 or Total_less_Work_sec > 0 or Total_More_Work_sec > 0 --or Qry.Working_afterShift_count > 0      
 end       
 
 ELSE IF @Report_call = 'OFF SHIFT'      
 begin      
  select E_IO.*,Emp_full_Name,Emp_Code,Grd_Name,Shift_name,dept_name ,Type_Name,Desig_Name,CMP_NAME,CMP_ADDRESS      
   ,@From_Date as P_From_date ,@To_Date as P_To_Date         
  From #Emp_Inout as E_IO inner join dbo.T0080_EMP_MASTER E WITH (NOLOCK) on E.emp_ID = E_IO.Emp_Id  inner join      
   dbo.T0040_SHIFT_MASTER WITH (NOLOCK) on       
   dbo.T0040_SHIFT_MASTER.Shift_ID = E_IO.Shift_ID inner join dbo.T0040_GRADE_MASTER WITH (NOLOCK) on      
   dbo.T0040_GRADE_MASTER.Grd_ID = E_IO.Grd_ID  left join dbo.T0040_DEPARTMENT_MASTER WITH (NOLOCK) on       
   dbo.T0040_DEPARTMENT_MASTER.Dept_id = E_IO.dept_id Left outer join dbo.T0040_TYPE_MASTER Et WITH (NOLOCK) on       
   E_IO.Type_ID = Et.Type_ID left Outer Join dbo.T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on       
   E_IO.Desig_ID = DM.Desig_ID  inner join dbo.T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.Cmp_ID = CM.CMP_ID      
  Where cast(cast(For_Date as varchar(11)) as smalldatetime) >= cast(cast(@From_Date  as varchar(11)) as smalldatetime)      
   and cast(cast(For_Date as varchar(11)) as smalldatetime) <= cast(cast(@To_Date  as varchar(11)) as smalldatetime)       
   and Working_afterShift_count > 0       
 end    
  else If @Report_call = 'Shift_End' 
 begin      
   
  Update #Emp_Inout set Shift_St_Datetime = cast(CONVERT(VARCHAR(11), For_Date, 121)  + CONVERT(VARCHAR(12), Shift_St_Datetime, 114) as datetime)  from #Emp_Inout
  Update #Emp_Inout set Shift_en_Datetime   = cast(CONVERT(VARCHAR(11), For_Date, 121)  + CONVERT(VARCHAR(12), Shift_en_Datetime, 114) as datetime)  from #Emp_Inout	
  
   
  select 
  --E_IO.*,
  E_IO.emp_id,E_IO.for_Date,E_IO.Dept_id,E_IO.Grd_ID,E_IO.Type_ID,E_IO.Desig_ID,E_IO.Shift_ID,
  E_IO.In_Time,case when E_IO.Out_Time >  Shift_en_Datetime  then Shift_en_Datetime else E_IO.Out_Time end as  Out_Time
  ,E_IO.Duration,
  E_IO.Duration_sec
  ,E_IO.Late_In,
  case when E_IO.Out_Time >  Shift_en_Datetime  then '' ELSE E_IO.Late_Out END AS Late_Out ,
  E_IO.Early_In,E_IO.Early_Out,
  E_IO.Leave,
  E_IO.Shift_Sec,
  E_IO.Shift_Dur,
  case when E_IO.Out_Time >  Shift_en_Datetime then DBO.F_Return_Hours(DATEDIFF(S,E_IO.In_Time,Shift_en_Datetime)) else E_IO.Total_work end as Total_work ,
  --E_IO.Less_Work
  --,E_IO.More_Work
  case when E_IO.Out_Time >  Shift_en_Datetime then cast( DBO.F_Return_Hours(case when (( (E_IO.Shift_Sec) - DATEDIFF(S,E_IO.In_Time,Shift_en_Datetime) ) ) < 0 then 0 else ((E_IO.Shift_Sec) - (DATEDIFF(S,E_IO.In_Time,Shift_en_Datetime) ) ) end)  as varchar) else E_IO.Less_Work end as Less_Work
  , case when E_IO.Out_Time >  Shift_en_Datetime then cast( DBO.F_Return_Hours(case when ((DATEDIFF(S,E_IO.In_Time,Shift_en_Datetime) )- (E_IO.Shift_Sec)) < 0 then 0 else ((DATEDIFF(S,E_IO.In_Time,Shift_en_Datetime) )- (E_IO.Shift_Sec)) end)  as varchar) else E_IO.More_Work end as More_Work
  ,Reason,
  E_IO.AB_LEAVE,E_IO.Late_In_Sec,E_IO.Late_In_count,E_IO.Early_Out_sec,E_IO.Early_Out_Count,
  --E_IO.Total_Less_work_Sec,
  case when E_IO.Out_Time >  Shift_en_Datetime then (case when (( (E_IO.Shift_Sec) - DATEDIFF(S,E_IO.In_Time,Shift_en_Datetime) ) ) < 0 then 0 else ((E_IO.Shift_Sec) - (DATEDIFF(S,E_IO.In_Time,Shift_en_Datetime) ) ) end)   else E_IO.Total_Less_work_Sec end as Total_Less_work_Sec,
  
  E_IO.Shift_St_Datetime,E_IO.Shift_en_Datetime,
  E_IO.Working_Sec_AfterShift,E_IO.Working_AfterShift_Count,E_IO.Leave_Reason,E_IO.Inout_Reason,
  E_IO.SysDate,
  case when E_IO.Out_Time >  Shift_en_Datetime then DATEDIFF(S,E_IO.In_Time,Shift_en_Datetime) else  E_IO.Total_Work_Sec end as Total_Work_Sec,
  0 as Late_Out_Sec,
  E_IO.Early_In_sec
 -- ,E_IO.Total_More_work_Sec,
  , case when E_IO.Out_Time >  Shift_en_Datetime then (case when ((DATEDIFF(S,E_IO.In_Time,Shift_en_Datetime) )- (E_IO.Shift_Sec)) < 0 then 0 else ((DATEDIFF(S,E_IO.In_Time,Shift_en_Datetime) )- (E_IO.Shift_Sec)) end)  else E_IO.Total_More_work_Sec end as Total_More_work_Sec
  ,E_IO.Is_OT_Applicable,E_IO.Monthly_Deficit_Adjust_OT_Hrs,E_IO.Late_Comm_sec
  ,E_IO.P_days
  ,Emp_full_Name,Alpha_Emp_Code, Emp_Code,Grd_Name,Shift_name,dept_name ,Type_Name,Desig_Name,CMP_NAME,CMP_ADDRESS,      
   @From_Date as P_From_date ,@To_Date as P_To_Date  
   ,dbo.F_GET_AMPM (Shift_St_Datetime) as Shift_Start_Time,
   dbo.F_GET_AMPM (Shift_End_Time) as Shift_End_Time,
   
   --- Modify Jignesh 23-Oct-2012 ( add 1 min if Sec > 30 )
   --dbo.F_GET_AMPM (In_Time) as Actual_In_Time,
   dbo.F_GET_AMPM (case when  datepart(s,In_Time) > 30 then DATEADD(ss,30,In_Time) else In_Time end ) as  Actual_In_Time,  
   --dbo.F_GET_AMPM (Out_Time) as Actual_Out_Time , 
   dbo.F_GET_AMPM (case when  datepart(s,Out_Time) > 30 then DATEADD(ss,30,Out_Time) else Out_Time end ) as  Actual_Out_Time,  
   
   convert(varchar(10),for_date,103)as On_Date  --CAST(for_Date as varchar(11)) as On_Date,
   ,@leave_Footer as Leave_Footer,Is_OT_Applicable,Monthly_Deficit_Adjust_OT_Hrs
   ,DM.Desig_Dis_No       --added jimit 01092015
   
   From #Emp_Inout as E_IO inner join dbo.T0080_EMP_MASTER E WITH (NOLOCK) on E.emp_ID = E_IO.Emp_Id Left Outer join  
   dbo.T0040_SHIFT_MASTER WITH (NOLOCK) on       
   dbo.T0040_SHIFT_MASTER.Shift_ID = E_IO.Shift_ID inner join dbo.T0040_GRADE_MASTER WITH (NOLOCK) on      
   dbo.T0040_GRADE_MASTER.Grd_ID = E_IO.Grd_ID  left join dbo.T0040_DEPARTMENT_MASTER WITH (NOLOCK) on       
   dbo.T0040_DEPARTMENT_MASTER.Dept_id = E_IO.dept_id left outer join dbo.T0040_TYPE_MASTER Et WITH (NOLOCK) on       
   E_IO.Type_ID = Et.Type_ID left Outer Join dbo.T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on       
   E_IO.Desig_ID = DM.Desig_ID inner join dbo.T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.Cmp_ID = CM.CMP_ID      
  Where cast(cast(For_Date as varchar(11)) as smalldatetime) >= cast(cast(@From_Date  as varchar(11)) as smalldatetime)  
  and cast(cast(For_Date as varchar(11)) as smalldatetime) <= cast(cast(@To_Date  as varchar(11)) as smalldatetime)   
  and ( In_Time is not null  or Out_Time is not null  or ab_leave is not null ) 
 -- Order by 
  Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
			When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
				Else e.Alpha_Emp_Code
			End
--e.Emp_code
     --RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500) 
 end	
  else if @Report_call = 'SUMMARY1'      
 begin      
  
  select * from       
   ( select E_IO.Emp_ID,Emp_full_Name,Alpha_Emp_Code,sum(Shift_Sec) as Total_Work_sec, 
   Cast(Replace(dbo.F_Return_Hours(Total_Work_Sec_new - Required_Hrs_Till_date),':','.') As numeric(18,2)) as Total_Work_Hours,
	Required_Hrs_Till_date, Cast(Replace(dbo.F_Return_Hours(Required_Hrs_Till_date),':','.') As numeric(18,2)) as Total_Required_Hours_Till_Date,
	Dur_Sec  As Achieved_Sec,Cast(Replace(dbo.F_Return_Hours(Dur_Sec ),':','.') As numeric(18,2)) as Achieved_Hours
	,Required_Hrs_Till_date - Dur_Sec as Short_Sec, 
	 Cast(Replace(dbo.F_Return_Hours(Required_Hrs_Till_date - Dur_Sec),':','.')As numeric(18,2)) as Short_Hours,
	Sum(Total_More_Work_sec) as Total_More_Work_sec
    , Cast(Replace(dbo.F_Return_Hours(sum(Total_More_work_Sec) ),':','.') As numeric(18,2)) as Total_More_Work_Hours
    ,@From_Date as P_From_date ,@To_Date as P_To_Date         
	
   from #Emp_Inout as E_IO inner join dbo.T0080_EMP_MASTER E WITH (NOLOCK) on E.emp_ID = E_IO.Emp_Id inner join   
    dbo.T0040_SHIFT_MASTER WITH (NOLOCK) on       
    dbo.T0040_SHIFT_MASTER.Shift_ID = E_IO.Shift_ID inner join dbo.T0040_GRADE_MASTER WITH (NOLOCK) on      
    dbo.T0040_GRADE_MASTER.Grd_ID = E_IO.Grd_ID  left join dbo.T0040_DEPARTMENT_MASTER WITH (NOLOCK) on       
    dbo.T0040_DEPARTMENT_MASTER.Dept_id = E_IO.dept_id left outer  join dbo.T0040_TYPE_MASTER Et WITH (NOLOCK) on       
    E_IO.Type_ID = Et.Type_ID left Outer Join dbo.T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on       
    E_IO.Desig_ID = DM.Desig_ID  inner join dbo.T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.Cmp_ID = CM.CMP_ID Left Outer Join
    (Select Emp_Id,Isnull(SUM(Shift_Sec),0) as Required_Hrs_Till_date From
    (select Distinct Emp_id, Isnull((Shift_Sec),0) as Shift_Sec, For_Date 
		From #Emp_Inout 
		Where cast(cast(For_Date as varchar(11)) as smalldatetime) >= cast(cast(@From_Date as varchar(11)) as smalldatetime)      
		and cast(cast(For_Date as varchar(11)) as smalldatetime) <= cast(cast(GETDATE()  as varchar(11)) as smalldatetime)       
		And (AB_LEAVE <> 'WO' AND AB_LEAVE <> 'HO') OR AB_LEAVE Is null)As Qry1 Group by Emp_id) As Qry4 
	on E_IO.emp_id = Qry4.emp_id Left Outer Join
    (Select Emp_id, Isnull(SUM(Duration_sec),0) as Dur_Sec 
	    From #Emp_Inout 
		Where (AB_LEAVE <> 'WO' AND AB_LEAVE <> 'HO') OR AB_LEAVE Is null Group by Emp_id) Qry2 on E_IO.emp_id = Qry2.emp_id
    Left Outer Join
    (select Emp_id, Isnull(SUM(Shift_Sec),0) as Total_Work_Sec_new
		From #Emp_Inout 
		Where cast(cast(For_Date as varchar(11)) as smalldatetime) >= cast(cast(@From_Date as varchar(11)) as smalldatetime)      
		and cast(cast(For_Date as varchar(11)) as smalldatetime) <= cast(cast(@To_Date  as varchar(11)) as smalldatetime)       
		And (AB_LEAVE <> 'WO' AND AB_LEAVE <> 'HO') OR AB_LEAVE Is null Group by Emp_id) Qry3 
	on E_IO.emp_id = Qry3.emp_id 
		
   Where cast(cast(For_Date as varchar(11)) as smalldatetime) >= cast(cast(@From_Date  as varchar(11)) as smalldatetime)      
    and cast(cast(For_Date as varchar(11)) as smalldatetime) <= cast(cast(@To_Date  as varchar(11)) as smalldatetime)       
   Group by E_IO.Emp_ID,Emp_full_Name,Alpha_Emp_Code,Required_Hrs_Till_date,Dur_Sec ,Total_Work_Sec_new            
   )Qry      
  
 end  

-------------Below Portion is Added By Ramiz on 29/09/2015 for Time Loss Report , It is Generated from In-Out Summary Form  ------------------

Else if @Report_call = 'Time_Loss'      
	BEGIN


		UPDATE	#Emp_Inout
		SET		Shift_St_Datetime = q.Shift_St_Time,			
				Shift_en_Datetime = q.Shift_End_Time
		FROM	#Emp_Inout d INNER JOIN 
					(
						SELECT	ST.Shift_st_time,ST.Shift_ID,ISNULL(SD.OT_Start_Time,0) AS OT_Start_Time,
								ST.Shift_End_Time ,ISNULL(SD.OT_End_Time,0) AS OT_End_Time,
								Sd.Working_Hrs_St_Time,sd.Working_Hrs_End_Time
						FROM	dbo.t0040_shift_master ST WITH (NOLOCK) LEFT OUTER JOIN dbo.t0050_shift_detail SD  WITH (NOLOCK)
								ON ST.Shift_ID=SD.Shift_ID 
						WHERE St.Cmp_ID = @Cmp_ID
					) q ON d.shift_id=q.shift_id


		Update #Emp_Inout set Shift_St_Datetime = cast(CONVERT(VARCHAR(11), For_Date, 121)  + CONVERT(VARCHAR(12), Shift_St_Datetime, 114) as datetime)  from #Emp_Inout
		Update #Emp_Inout set Shift_en_Datetime   = cast(CONVERT(VARCHAR(11), For_Date, 121)  + CONVERT(VARCHAR(12), Shift_en_Datetime, 114) as datetime)  from #Emp_Inout	

		Update #Emp_Inout 
		set OUT_Time = case when OUT_Time > Shift_en_Datetime then Shift_en_Datetime else OUT_Time end 
		from #Emp_Inout t
	
		Update #Emp_Inout 
		set In_Time = case  when In_Time < Shift_St_Datetime then Shift_St_Datetime else In_Time end  
		from #Emp_Inout t

		Update #Emp_Inout 
		set In_Time = case  when In_Time > Shift_en_Datetime and OUT_Time = Shift_en_Datetime then Shift_en_Datetime else In_Time end  
		from #Emp_Inout t 
		
		Update #Emp_Inout
		Set Shift_Sec = (Shift_Sec/2), In_Time = case when In_Time < (select Shift_en_Datetime - dbo.F_Return_Hours(Shift_Sec/2) from #Emp_Inout where AB_LEAVE like '%Half%') then (select Shift_St_Datetime + dbo.F_Return_Hours(Shift_Sec/2)  from #Emp_Inout where AB_LEAVE like '%Half%') else In_Time end 
		from #Emp_Inout t where AB_LEAVE like '%First Half%'
			
		Update #Emp_Inout
		Set Shift_Sec = (Shift_Sec/2), Out_Time = case when OUT_Time > (select Shift_St_Datetime + dbo.F_Return_Hours(Shift_Sec/2)  from #Emp_Inout where AB_LEAVE like '%Half%') then (select Shift_St_Datetime + dbo.F_Return_Hours(Shift_Sec/2)  from #Emp_Inout where AB_LEAVE like '%Half%') else OUT_Time end 
		from #Emp_Inout t where AB_LEAVE like '%Second Half%'
		
		Update #Emp_Inout
		Set Duration_sec = isnull(datediff(s,t.in_time,t.out_time),0)
		from #Emp_Inout t
		
		Update #Emp_Inout
		Set Duration = Cast(Replace(dbo.F_Return_Hours(Duration_sec ),':','.') As numeric(18,2))
		from #Emp_Inout t


		select * from       
	   ( select E_IO.Emp_ID,Emp_full_Name,Alpha_Emp_Code,Total_Work_Sec_new, 
	   Cast(Replace(dbo.F_Return_Hours(Total_Work_Sec_new - Required_Hrs_Till_date),':','.') As numeric(18,2)) as Total_Work_Hours,
		Required_Hrs_Till_date, Cast(Replace(dbo.F_Return_Hours(Required_Hrs_Till_date),':','.') As numeric(18,2)) as Total_Required_Hours_Till_Date,
		Dur_Sec  As Achieved_Sec,Cast(Replace(dbo.F_Return_Hours(Dur_Sec ),':','.') As numeric(18,2)) as Achieved_Hours
		,Required_Hrs_Till_date - Dur_Sec as Short_Sec, 
		 Cast(Replace(dbo.F_Return_Hours(Required_Hrs_Till_date - Dur_Sec),':','.')As numeric(18,2)) as Short_Hours,
		Sum(Total_More_Work_sec) as Total_More_Work_sec
		, Cast(Replace(dbo.F_Return_Hours(sum(Total_More_work_Sec) ),':','.') As numeric(18,2)) as Total_More_Work_Hours
		,cm.Cmp_Name as Cmp_Name , cm.Cmp_Address as Cmp_Address
		,GRM.Grd_Name , et.Type_Name , DPM.Dept_Name , DM.Desig_Name
		,@From_Date as P_From_date ,@To_Date as P_To_Date
		   from #Emp_Inout as E_IO 
		   inner join dbo.T0080_EMP_MASTER E		 WITH (NOLOCK) on E.emp_ID = E_IO.Emp_Id 
		   inner join dbo.T0040_SHIFT_MASTER SM		 WITH (NOLOCK) on SM.Shift_ID = E_IO.Shift_ID 
		   inner join dbo.T0040_GRADE_MASTER GRM	 WITH (NOLOCK) on GRM.Grd_ID = E_IO.Grd_ID  
		   left join dbo.T0040_DEPARTMENT_MASTER DPM WITH (NOLOCK) on DPM.Dept_id = E_IO.dept_id 
		   left outer join dbo.T0040_TYPE_MASTER Et  WITH (NOLOCK) on E_IO.Type_ID = Et.Type_ID 
		   left Outer Join dbo.T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on E_IO.Desig_ID = DM.Desig_ID  
		   inner join dbo.T0010_COMPANY_MASTER CM	 WITH (NOLOCK) ON E.Cmp_ID = CM.CMP_ID 
		   Left Outer Join
				(Select Emp_Id,Isnull(SUM(Shift_Sec),0) as Required_Hrs_Till_date From
				(select Distinct Emp_id, Isnull((Shift_Sec),0) as Shift_Sec, For_Date 
				From #Emp_Inout 
				Where cast(cast(For_Date as varchar(11)) as smalldatetime) >= cast(cast(@From_Date as varchar(11)) as smalldatetime)      
				and cast(cast(For_Date as varchar(11)) as smalldatetime) <= cast(cast(GETDATE()  as varchar(11)) as smalldatetime)       
				And (AB_LEAVE <> 'WO' AND AB_LEAVE <> 'HO' AND AB_LEAVE <> 'AB' and AB_LEAVE not like '%Full day%') OR AB_LEAVE Is null)As Qry1 Group by Emp_id) As Qry4 
				on E_IO.emp_id = Qry4.emp_id 
			Left Outer Join
				(Select Emp_id, Isnull(SUM(Duration_sec),0) as Dur_Sec 
				From #Emp_Inout 
				Where (AB_LEAVE <> 'WO' AND AB_LEAVE <> 'HO' AND AB_LEAVE <> 'AB' and  AB_LEAVE not like '%Full day%') OR AB_LEAVE Is null Group by Emp_id) Qry2 on E_IO.emp_id = Qry2.emp_id
			Left Outer Join
				(select Emp_id, Isnull(SUM(Shift_Sec),0) as Total_Work_Sec_new
				From #Emp_Inout 
				Where cast(cast(For_Date as varchar(11)) as smalldatetime) >= cast(cast(@From_Date as varchar(11)) as smalldatetime)      
				and cast(cast(For_Date as varchar(11)) as smalldatetime) <= cast(cast(@To_Date  as varchar(11)) as smalldatetime)       
				And (AB_LEAVE <> 'WO' AND AB_LEAVE <> 'HO' AND AB_LEAVE <> 'AB' and  AB_LEAVE not like '%Full day%') OR AB_LEAVE Is null Group by Emp_id) Qry3 
				on E_IO.emp_id = Qry3.emp_id 
			
			   Where cast(cast(For_Date as varchar(11)) as smalldatetime) >= cast(cast(@From_Date  as varchar(11)) as smalldatetime)      
				and cast(cast(For_Date as varchar(11)) as smalldatetime) <= cast(cast(@To_Date  as varchar(11)) as smalldatetime)       
			   Group by E_IO.Emp_ID,Emp_full_Name,Alpha_Emp_Code,Required_Hrs_Till_date,Dur_Sec ,Total_Work_Sec_new , Cmp_Name , Cmp_Address   ,GRM.Grd_Name , et.Type_Name , DPM.Dept_Name , DM.Desig_Name
			   )Qry
	END
    
RETURN      



