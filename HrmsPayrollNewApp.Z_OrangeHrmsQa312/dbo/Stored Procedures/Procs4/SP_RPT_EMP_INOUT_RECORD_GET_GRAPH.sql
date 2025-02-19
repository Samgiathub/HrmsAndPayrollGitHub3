
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_EMP_INOUT_RECORD_GET_GRAPH]      
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
 @Constraint  varchar(5000) = '',      
 @Report_call varchar(20) = 'IN-OUT',      
 @Weekoff_Entry varchar(1) = 'Y',  
 @PBranch_ID varchar(200) = '0'      
      
AS      
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON 


	Set @to_Date = getdate()

	--Set @From_Date = '01-may-2013'
	--Set @To_Date  = '31-may-2013'  
       
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
 Declare @First_In_Last_Out_For_InOut_Calculation tinyint
 
 Set @Emp_OT = 0
 Set @Emp_OT_Min_Limit_Sec = 0
 Set @Emp_OT_Max_Limit_Sec = 0
       
       
      
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
       
       
 --select @Late_Comm_Limit = Late_Limit,@Early_Limit = Early_Limit from T0040_GENERAL_SETTING where Cmp_ID = @Cmp_ID      
 --and For_Date  = ( select max(For_Date) from T0040_GENERAL_SETTING where Cmp_ID = @Cmp_ID and For_Date <=@To_Date)      
       
 --set @Late_Comm_sec = dbo.F_Return_Sec(@Late_Comm_Limit) 
 --set @Early_Limit_sec = dbo.F_Return_Sec(@Early_Limit)        

CREATE table #Emp_Cons 
 (      
   Emp_ID numeric ,     
  Branch_ID numeric,
  Increment_ID numeric    
 )      

	-- Hardik 18/01/2016
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
								
	--				delete  from #emp_cons where Increment_ID not in (select max(Increment_ID) from dbo.T0095_Increment
	--					where  Increment_effective_Date <= @to_date
	--					group by emp_ID)
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
								
	--				delete  from #emp_cons where Increment_ID not in (select max(Increment_ID) from dbo.T0095_Increment
	--					where  Increment_effective_Date <= @to_date
	--					group by emp_ID)
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
   Total_More_work_Sec numeric null      
  )      
 
	If not @Branch_ID Is null   --Added by Hardik 18/01/2016
		BEGIN
			 Select @Is_Cancel_Holiday = Is_Cancel_Holiday ,@Is_Cancel_Weekoff = Is_Cancel_Weekoff,@Late_Comm_Limit = Late_Limit,@Early_Limit = Early_Limit      
			 From dbo.T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID and Branch_ID = @Branch_ID      
			 and For_Date = ( select max(For_Date) from dbo.T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@To_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)  
		End
	Else
		BEGIN
			 Select @Is_Cancel_Holiday = Is_Cancel_Holiday ,@Is_Cancel_Weekoff = Is_Cancel_Weekoff,@Late_Comm_Limit = Late_Limit,@Early_Limit = Early_Limit      
			 From dbo.T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID 
			 and For_Date = ( select max(For_Date) from dbo.T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@To_Date AND Cmp_ID = @Cmp_ID)  
		End
		 
	 set @Late_Comm_sec = dbo.F_Return_Sec(@Late_Comm_Limit) 
	 set @Early_Limit_sec = dbo.F_Return_Sec(@Early_Limit)        

      
 DECLARE CUR_EMP CURSOR fast_forward FOR      
	SELECT E.EMP_ID,I.Grd_ID,I.Type_ID,I.Dept_ID,I.Desig_ID,
		dbo.F_Return_Sec(I.Emp_Late_Limit),dbo.F_Return_Sec(I.Emp_Early_Limit),
		Emp_OT,dbo.F_Return_Sec(I.Emp_OT_Min_Limit),dbo.F_Return_Sec(I.Emp_OT_Max_Limit)
	FROM	dbo.T0080_EMP_MASTER E WITH (NOLOCK)
			Inner join #Emp_Cons EC on E.Emp_ID = EC.Emp_ID 
			Inner join       
					(
						select	I.Emp_Id ,Type_ID ,Grd_ID,Dept_ID,Desig_Id,Isnull(Emp_Late_Limit,'00:00') as Emp_Late_Limit,
								Isnull(Emp_Early_Limit,'00:00') as Emp_Early_Limit,Isnull(Emp_OT,0) as Emp_OT,
								Isnull(Emp_OT_Min_Limit,'00:00') as Emp_OT_Min_Limit,Isnull(Emp_OT_Max_Limit,'00:00') as Emp_OT_Max_Limit,I.Increment_ID
						from	dbo.T0095_INCREMENT I WITH (NOLOCK)
								inner join       
											(
												SELECT	MAX(I2.Increment_ID) AS Increment_ID, I2.Emp_ID
												FROM	T0095_INCREMENT I2 WITH (NOLOCK) INNER JOIN #Emp_Cons E2 ON I2.Emp_ID=E2.EMP_ID
														inner join (
																		select	max(I.Increment_effective_Date) as For_Date, I.Emp_ID
																		from	dbo.T0095_INCREMENT  I WITH (NOLOCK)
																				Inner join #Emp_Cons EC on I.Emp_ID = EC.Emp_ID    
																		where	I.Increment_effective_Date <= @To_Date and I.Cmp_ID = @Cmp_ID      
																		group by I.emp_ID
																	) I3 ON I2.Increment_Effective_Date=I3.For_Date AND I2.Emp_ID=I3.Emp_ID	
												WHERE	I2.Cmp_ID = IsNull(@Cmp_Id , I2.Cmp_ID)
												GROUP BY I2.Emp_ID
												) I2 ON I.Emp_ID=I2.Emp_ID AND I.Increment_ID=I2.INCREMENT_ID  
											--) Qry  on I.Emp_ID = Qry.Emp_ID and i.Increment_effective_Date   = Qry.For_date       
						where	Cmp_ID = @Cmp_ID 
					 ) I ON E.EMP_ID=I.Emp_ID       
	WHERE	E.Cmp_ID = @Cmp_ID
	      
 OPEN  CUR_EMP      
 FETCH NEXT FROM CUR_EMP INTO @EMP_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Late_Comm_sec,@Early_Limit_Sec,@Emp_OT,@Emp_OT_Min_Limit_Sec,@Emp_OT_Max_Limit_Sec
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
	  Declare @Reason1 as Varchar(150),
			  @Is_Half_Day tinyint,
			  @Week_day varchar(10),
			  @Half_St_Time varchar(10),
			  @Half_End_Time varchar(10),
			  @Half_Dur varchar(10);
	  
      --- End for Hardik 
		
      
    Declare @Temp_End_Date as datetime       
    --set @Temp_End_Date = Dateadd(d,1,@To_Date)      
    set @Temp_End_Date = @To_Date      
  
	Exec dbo.SP_EMP_WEEKOFF_DATE_GET @Emp_ID,@Cmp_ID,@From_Date,@To_Date,@Join_Date,@left_Date,@Is_Cancel_weekoff,@StrHoliday_Date,@StrWeekoff_Date output,@Weekoff_Days output ,@Cancel_Weekoff output      
	Exec dbo.SP_EMP_HOLIDAY_DATE_GET @Emp_ID,@Cmp_ID,@From_Date,@To_Date,@Join_Date,@left_Date,@Is_Cancel_Holiday,@StrHoliday_Date output,@Holiday_days output,@Cancel_Holiday output,0,@Branch_ID,@StrWeekoff_Date  
        
          
    while @Temp_Month_Date <= @Temp_End_Date      
     begin      
      set @shift_ID = 0      
   
   SET @Is_Half_Day = 0;
   SET @Week_day = '';
   Exec dbo.SP_CURR_T0100_EMP_SHIFT_GET @emp_id,@Cmp_ID,@Temp_Month_Date,@Shift_St_Time output,@Shift_End_Time output,@Shift_Dur output,null,null,null,null,@shift_ID output,@Is_Half_Day output, @Week_day output, @Half_St_Time output, @Half_End_Time output, @Half_Dur output; --Modified by Nimesh 11-Jun-2015 (Hours are calculating incorrectly for half day)
 
	--Added by Nimesh 11-Jun-2015(If shift is having half day then the total hours are calcuating incorrectly)
	IF (@Is_Half_Day > 0 AND DATENAME(weekday,@Temp_Month_Date) = @Week_day)      
	BEGIN 
		SET @Shift_St_Time = @Half_St_Time;
		SET @Shift_End_Time = @Half_End_Time;
		SET @Shift_Dur = @Half_Dur;
	END
           
      set @Shift_Sec = 0     
      set @Shift_Sec  = dbo.F_Return_Sec(@Shift_Dur)      
      set @Shift_St_Sec = dbo.F_Return_Sec(@Shift_St_Time)      
      set @Shift_En_Sec = dbo.F_Return_Sec(@Shift_End_Time)      
            
   Set @Leave_Name = ''  
   Set @Leave_Reason = ''  
   Set @Leave_ID = 0  
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

			set @First_In_Last_Out_For_InOut_Calculation = 0 
			
			Select @First_In_Last_Out_For_InOut_Calculation= isnull(First_In_Last_Out_For_InOut_Calculation,0) 
			from dbo.T0040_GENERAL_SETTING WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Branch_ID = (Select Branch_ID from dbo.T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID=@Emp_ID)

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
					--Else			
					--	Begin
					--		 Declare cur_Inout cursor for   
					--			Select Min(In_Time),Max(Out_Time),Reason From (
					--			Select distinct In_Time,Case when Max_In_Date > Out_Date Then Max_In_Date Else Out_Date End Out_Time, Eir.Reason
					--			from T0150_emp_inout_Record  EIR Inner join #Emp_Cons Ec on EIR.Emp_Id = ec.Emp_ID inner Join        
					--				(select I.Emp_ID,Emp_OT,isnull(Emp_OT_min_Limit,'00:00')Emp_OT_min_Limit,isnull(Emp_OT_max_Limit,'00:00')Emp_OT_max_Limit from T0095_Increment  I inner join         
					--				(select max(increment_effective_Date)IE_Date ,Emp_ID from T0095_Increment         
					--				 where increment_effective_Date <=@To_Date and Cmp_ID =@Cmp_ID group by Emp_ID)q on I.emp_ID =q.Emp_ID and         
					--				I.Increment_effective_Date = q.IE_Date ) IQ on eir.Emp_ID =iq.emp_ID 
					--				Inner Join
					--				(select Emp_Id, Min(In_Time) In_Date,For_Date From T0150_Emp_Inout_Record Where In_Time >=Dateadd(hh,-5,@Shift_St_Datetime) Group By Emp_Id,For_Date) Q1 on EIR.Emp_Id = Q1.Emp_Id 
					--				And EIR.For_Date = Q1.For_Date
					--				Inner Join
					--				(select Emp_Id, Max(Out_Time) Out_Date,For_Date From T0150_Emp_Inout_Record Where Out_Time <=Dateadd(hh,5,@Shift_End_Datetime) Group By Emp_Id,For_Date) Q2 on EIR.Emp_Id = Q2.Emp_Id 
					--				And EIR.For_Date = Q2.For_Date
					--				Inner Join
					--				--Added by Hardik 23/07/2012 for First IN And Last OUT (it will take Max In Punch as OUT and calculate Hours)
					--				(select Emp_Id, Max(In_Time) Max_In_Date,For_Date From T0150_Emp_Inout_Record Where Out_Time <=Dateadd(hh,5,@Shift_End_Datetime) Group By Emp_Id,For_Date) Q4 on EIR.Emp_Id = Q4.Emp_Id  
					--				And EIR.For_Date = Q4.For_Date
					--				Left Outer Join 
					--				(Select Emp_ID,Chk_By_Superior Chk_By_Sup,For_Date from T0150_EMP_INOUT_RECORD where Chk_By_Superior=1) Q3 on EIR.Emp_Id = Q3.Emp_Id 
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
							   select In_time,Out_Time,Reason from dbo.T0150_emp_inout_record WITH (NOLOCK) Where Emp_ID =@Emp_ID and For_Date = @Temp_Month_Date      
								order by isnull(In_time,Out_time),Out_time,Reason      
						End
					--Else			
					--	Begin
					--	  Declare cur_Inout cursor for       
					--	   select In_time,Out_Time,Reason from T0150_emp_inout_record Where Emp_ID =@Emp_ID 
					--		and In_Time >= Dateadd(hh,-2,@Shift_St_Datetime) And
					--			Out_Time <= Dateadd(hh,2,@Shift_End_Datetime)
					--		order by isnull(In_time,Out_time),Out_time,Reason      
					--	End
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
                       
          if @Toatl_Working_sec > 0 exec dbo.Return_DurHourMin  @Toatl_Working_sec ,@Total_work output         
                
          if @Insert_IN_Date > @Shift_End_datetime      
           begin      
            set @Working_Sec_AfterShift   =  @Working_sec + @Working_Sec_AfterShift      
            set @Working_AfterShift_Count =  1      
           end      
      
                
          set @Diff_Sec  = @Toatl_Working_sec -  @Shift_Sec       
         
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
     
   If EXISTS(Select 1 from dbo.T0040_SHIFT_MASTER SM WITH (NOLOCK) where Is_Half_Day = 1 and SM.Cmp_ID = @Cmp_Id) --Added by Hardik 18/01/2016
   BEGIN
	   exec dbo.GET_HalfDay_Date @Cmp_ID,@Emp_ID,@From_Date,@To_Date,0,@HalfDayDate output  
	   select @WeekDay=SM.Week_Day,@HalfStartTime=SM.Half_St_Time,@HalfEndTime=SM.Half_End_Time,@HalfDuration=SM.Half_Dur,@HalfMinDuration=SM.Half_min_duration 
	   from dbo.T0040_SHIFT_MASTER SM WITH (NOLOCK) inner join           
			(select distinct Shift_ID from #Emp_Inout ) q on SM.Shift_ID =  q.shift_ID          
		 where Is_Half_Day = 1   
	      
	   set @HalfStartDateTime = cast(cast(@Temp_Month_Date as varchar(11)) + ' ' + @HalfStartTime as smalldatetime)      
			 set @HalfEndDateTime = cast(cast(@Temp_Month_Date as varchar(11)) + ' ' + @HalfEndTime  as smalldatetime)      
	END        
  
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

		-- Commented by Hardik 17/08/2012                            
       --exec Return_Without_Sec @late_in_sec ,@late_in_sec output      
       --exec Return_Without_Sec @late_out_sec ,@late_out_sec output      
       --exec Return_Without_Sec @Early_In_Sec ,@Early_In_Sec output      
       --exec Return_Without_Sec @Early_Out_Sec ,@Early_Out_Sec output      
       --exec Return_Without_Sec @Working_sec ,@Working_sec output       
                  
                  
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
  ------------ End for Half shift  
  
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
		
		if  @Diff_Sec > 0  And @Diff_Sec > @Emp_OT_Min_Limit_Sec And @Emp_OT = 1
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
		else if @Diff_Sec <  0 and @Toatl_Working_sec > 0 And @Emp_OT = 1     
			begin      
				set @Diff_Sec = @Diff_Sec * -1      
				set @Total_Less_Work_Sec = @Diff_Sec      
				exec dbo.Return_DurHourMin @Diff_Sec , @less_Work output       
			end       
      
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

             if @Toatl_Working_sec > 0 exec dbo.Return_DurHourMin  @Toatl_Working_sec ,@Total_work output         
  
       Set @Diff_Sec  = @Toatl_Working_sec -  @Shift_Sec       
  
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


		if  @Diff_Sec > 0 And @Diff_Sec > @Emp_OT_Min_Limit_Sec And @Emp_OT = 1
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
		else if @Diff_Sec <  0 and @Toatl_Working_sec > 0  And @Emp_OT = 1    
			begin      
				set @Diff_Sec = @Diff_Sec * -1      
				set @Total_Less_Work_Sec = @Diff_Sec      
				exec dbo.Return_DurHourMin @Diff_Sec , @less_Work output       
				Set @More_Work = ''
				set @Total_More_work_sec =0
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
     where Emp_ID = @emp_Id and For_Date = @temp_month_Date  
       
    end   
                ------------ End for Hardik   
                  
          INSERT INTO #Emp_Inout (Emp_id,For_Date , Dept_id ,Grd_ID,Type_ID,Desig_ID ,Shift_ID,In_Time ,Out_Time ,Duration ,      
            Duration_sec  , Late_In ,Late_Out , Early_In , Early_Out , Leave ,Shift_Sec,Shift_Dur,Total_Work,Less_Work,More_work,Reason,Late_in_sec,Early_Out_sec,Total_Less_work_sec,Late_in_Count,Early_Out_count,Shift_St_Datetime,Shift_en_Datetime      
            ,Working_Sec_AfterShift,Working_AfterShift_Count,Inout_Reason,Total_Work_Sec,Late_Out_Sec,Early_In_sec,Total_More_work_Sec)          
          VALUES (@emp_id ,@Temp_Month_Date ,@Dept_id ,@Grd_ID ,@Type_ID,@Desig_ID,@Shift_ID,@Insert_IN_DATE ,@Insert_Out_DATE ,@working_Hours ,      
            @working_sec  , @late_In ,@late_Out , @Early_In , @Early_Out , '',@Shift_Sec,@Shift_Dur,@Total_Work,@Less_Work,@More_work,@Reason,@late_in_sec,@Early_Out_Sec,@Total_less_work_sec,@Late_in_Count,@Early_Out_count,@Shift_St_Time,@Shift_End_Time  -- @Pre_Shift_St_dateTime,@Pre_Shift_En_dateTime   change by rohit for shift start time and end time on 03-aug-2012
            ,@Working_Sec_AfterShift,@Working_AfterShift_Count,@Reason,isnull(@Toatl_Working_sec,0),isnull(@Late_Out_Sec,0),isnull(@Early_In_Sec,0),Isnull(@Total_More_work_Sec,0))
  
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
	 Declare @Min_In_Time as Datetime
     select @Min_In_Time = MIN(In_Time) from #Emp_Inout as EI where EI.Emp_ID = @Emp_ID   
      and EI.For_DAte = @temp_Month_Date 
       
		update #Emp_Inout set   
		Late_In = '',Late_In_Sec = 0,Late_In_count=0  
		where Emp_ID = @emp_Id and For_Date = @temp_month_Date And In_Time <> @Min_In_Time
     ------------ End for Hardik   
                             
         Fetch next from cur_inout  into @Insert_In_Date,@Insert_Out_Date,@Reason     
       end      
      close cur_Inout      
      Deallocate cur_inout     
  
  
  ---- Added by Hardik on 11/10/2011 for Holiday, Weekoff and Leave checking  
  if charindex(cast(@Temp_Month_Date as varchar(11)),@StrHoliday_Date,0) > 0   
   begin  
    set @Weekoff_Entry = @Weekoff_Entry  
  
    If not exists (Select 1 From #Emp_Inout Where emp_id = @Emp_ID And for_Date = @Temp_Month_Date)  
     Begin  
      INSERT INTO #Emp_Inout   
       (Emp_id,For_Date , Dept_id ,Grd_ID,Type_ID,Desig_ID ,Shift_ID,In_Time ,Out_Time ,Duration ,      
       Duration_sec  , Late_In ,Late_Out , Early_In , Early_Out , Leave ,Shift_Sec,Shift_Dur,Total_Work,Less_Work,More_work,Reason,Late_in_sec,Early_Out_sec,Total_Less_work_sec,Late_in_Count,Early_Out_count,Shift_St_Datetime,Shift_en_Datetime      
       ,Working_Sec_AfterShift,Working_AfterShift_Count,Inout_Reason,AB_LEAVE,Total_More_work_Sec)   
      VALUES   
       (@emp_id ,@Temp_Month_Date ,@Dept_id ,@Grd_ID ,@Type_ID,@Desig_ID,@Shift_ID,Null,Null ,'-',      
        0, '-' ,'-', '-', '-', '',0,'-','-','-','-','-',0,0,0,0,0,Null,Null 
       ,0,0,'-','HO',0)      
     End  
    Else  
     Begin  
		If @Emp_OT = 1
			Update #Emp_Inout Set AB_LEAVE = 'HO', Total_More_work_Sec = Total_Work_Sec, More_Work = Total_work Where emp_id = @Emp_ID And for_Date = @Temp_Month_Date  
		Else
			Update #Emp_Inout Set AB_LEAVE = 'HO' Where emp_id = @Emp_ID And for_Date = @Temp_Month_Date
     End  
   end            
  Else If exists (Select 1 From dbo.T0120_LEAVE_APPROVAL LA WITH (NOLOCK) Inner Join   
       dbo.T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) On LA.Leave_Approval_ID = LAD.Leave_Approval_ID  
       Where From_Date <= @Temp_Month_Date And To_Date >= @Temp_Month_Date And Emp_ID = @Emp_ID And LA.Approval_Status = 'A'
	   and LA.Leave_Approval_ID  not In (select Leave_Approval_ID from dbo.T0150_LEAVE_CANCELLATION LC WITH (NOLOCK) where  LC.cmp_id=@Cmp_ID and LC.Emp_ID = @Emp_ID and LC.For_Date = @Temp_Month_Date and LC.Is_Approve=1) )  
   Begin  
  
     
     Select @Leave_ID = Leave_ID, @Leave_Reason = Leave_Reason  From dbo.T0120_LEAVE_APPROVAL LA WITH (NOLOCK) Inner Join   
       dbo.T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) On LA.Leave_Approval_ID = LAD.Leave_Approval_ID  
       Where From_Date <= @Temp_Month_Date And To_Date >= @Temp_Month_Date And Emp_ID = @Emp_ID And LA.Approval_Status = 'A'
	   and LA.Leave_Approval_ID  not In (select Leave_Approval_ID from dbo.T0150_LEAVE_CANCELLATION LC WITH (NOLOCK) where  LC.cmp_id=@Cmp_ID and LC.Emp_ID = @Emp_ID and LC.For_Date = @Temp_Month_Date and LC.Is_Approve=1)
      
     Select @Leave_Name = Leave_Code From dbo.T0040_LEAVE_MASTER WITH (NOLOCK) Where Leave_ID = @Leave_ID  
       
     INSERT INTO #Emp_Inout   
      (Emp_id,For_Date , Dept_id ,Grd_ID,Type_ID,Desig_ID ,Shift_ID,In_Time ,Out_Time ,Duration ,      
      Duration_sec  , Late_In ,Late_Out , Early_In , Early_Out , Leave ,Shift_Sec,Shift_Dur,Total_Work,Less_Work,More_work,Reason,Late_in_sec,Early_Out_sec,Total_Less_work_sec,Late_in_Count,Early_Out_count,Shift_St_Datetime,Shift_en_Datetime      
      ,Working_Sec_AfterShift,Working_AfterShift_Count,Inout_Reason,AB_LEAVE,Total_More_work_Sec)      
     VALUES   
      (@emp_id ,@Temp_Month_Date ,@Dept_id ,@Grd_ID ,@Type_ID,@Desig_ID,@Shift_ID,Null,Null ,'-',      
       0, '-' ,'-', '-', '-', @Leave_Name,0,@Shift_Dur,'-','-','-',@Leave_Reason,0,0,0,0,0,@Shift_St_Time,@Shift_End_Time -- Null,Null -- comment and add by rohit for shift time on 06-aug-2012   
      ,0,0,'-',@Leave_Name,0)      
     
  
   End  
  
  else if charindex(cast(@Temp_Month_Date as varchar(11)),@StrWeekoff_Date,0) > 0   
   begin  
    set @Weekoff_Entry = @Weekoff_Entry  
    If not exists (Select 1 From #Emp_Inout Where emp_id = @Emp_ID And for_Date = @Temp_Month_Date)  
     Begin  
      INSERT INTO #Emp_Inout   
       (Emp_id,For_Date , Dept_id ,Grd_ID,Type_ID,Desig_ID ,Shift_ID,In_Time ,Out_Time ,Duration ,      
       Duration_sec  , Late_In ,Late_Out , Early_In , Early_Out , Leave ,Shift_Sec,Shift_Dur,Total_Work,Less_Work,More_work,Reason,Late_in_sec,Early_Out_sec,Total_Less_work_sec,Late_in_Count,Early_Out_count,Shift_St_Datetime,Shift_en_Datetime      
       ,Working_Sec_AfterShift,Working_AfterShift_Count,Inout_Reason,AB_LEAVE,Total_More_work_Sec)      
      VALUES   
       (@emp_id ,@Temp_Month_Date ,@Dept_id ,@Grd_ID ,@Type_ID,@Desig_ID,@Shift_ID,Null,Null ,'-',      
        0, '-' ,'-', '-', '-', '',0,'-','-','-','-','-',0,0,0,0,0,Null,Null   
       ,0,0,'-','WO',0)      
     End  
    Else  
     Begin  
		If @Emp_OT = 1
			Update #Emp_Inout Set AB_LEAVE = 'WO', Total_More_work_Sec = Total_Work_Sec, More_Work = Total_work Where emp_id = @Emp_ID And for_Date = @Temp_Month_Date  
		else
			Update #Emp_Inout Set AB_LEAVE = 'WO' Where emp_id = @Emp_ID And for_Date = @Temp_Month_Date  
     End  
   End  
  else  
   begin  
    If not exists (Select 1 From #Emp_Inout Where emp_id = @Emp_ID And for_Date = @Temp_Month_Date)  
     Begin  
      INSERT INTO #Emp_Inout   
       (Emp_id,For_Date , Dept_id ,Grd_ID,Type_ID,Desig_ID ,Shift_ID,In_Time ,Out_Time ,Duration ,      
       Duration_sec  , Late_In ,Late_Out , Early_In , Early_Out , Leave ,Shift_Sec,Shift_Dur,Total_Work,Less_Work,More_work,Reason,Late_in_sec,Early_Out_sec,Total_Less_work_sec,Late_in_Count,Early_Out_count,Shift_St_Datetime,Shift_en_Datetime      
       ,Working_Sec_AfterShift,Working_AfterShift_Count,Inout_Reason,AB_LEAVE,Total_More_work_Sec)      
      VALUES   
       (@emp_id ,@Temp_Month_Date ,@Dept_id ,@Grd_ID ,@Type_ID,@Desig_ID,@Shift_ID,Null,Null ,'-',      
        0, '-' ,'-', '-', '-', '',@Shift_Sec,@Shift_Dur,'-', @Shift_Dur ,'-','-',0,0,@Shift_Sec,0,0,@Shift_St_Time,@Shift_End_Time --Null,Null --comment and add by rohit for shift time on 06-aug-2012  
       ,0,0,'-','AB',0)      
     End  
   End  
  ------------- End by Hardik   
            
      
      set @Temp_Month_Date = Dateadd(d,1,@Temp_Month_Date)       
     end       
   FETCH NEXT FROM CUR_EMP INTO @EMP_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Late_Comm_sec,@Early_Limit_Sec,@Emp_OT,@Emp_OT_Min_Limit_Sec,@Emp_OT_Max_Limit_Sec
  end      
 close cur_Emp      
 deallocate cur_Emp      
      
     
       
 If @Report_call = 'IN-OUT' or @Report_call = 'Inout_Page'
 begin      
   
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
  --Order by 
  Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
			When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
				Else e.Alpha_Emp_Code
			End
--e.Emp_code
    -- RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500) 
 end      
 else if @Report_call = 'SUMMARY'      
 begin 
 
  select * from       
   ( select E_IO.Emp_ID,Emp_full_Name,Alpha_Emp_Code,sum(Shift_Sec) as Total_Work_sec, 
   Cast(Replace(dbo.F_Return_Hours(Total_Work_Sec_new - Required_Hrs_Till_date),':','.') As numeric(18,2)) as Total_Work_Hours,
	Required_Hrs_Till_date, Cast(Replace(dbo.F_Return_Hours(Required_Hrs_Till_date),':','.') As numeric(18,2)) as Total_Required_Hours_Till_Date,
	Dur_Sec  As Achieved_Sec,Cast(Replace(dbo.F_Return_Hours(Dur_Sec ),':','.') As numeric(18,2)) as Achieved_Hours
	--,Required_Hrs_Till_date - Dur_Sec as Short_Sec, 
	,sum(E_IO.Total_Less_work_Sec) as Short_Sec, 
	 Cast(Replace(dbo.F_Return_Hours((sum(E_IO.Total_Less_work_Sec))),':','.')As numeric(18,2)) as Short_Hours,
	Sum(Total_More_Work_sec) as Total_More_Work_sec
    , Cast(Replace(dbo.F_Return_Hours(sum(Total_More_work_Sec) ),':','.') As numeric(18,2)) as Total_More_Work_Hours
    ,@From_Date as P_From_date ,@To_Date as P_To_Date         
   from #Emp_Inout as E_IO inner join dbo.T0080_EMP_MASTER E on E.emp_ID = E_IO.Emp_Id inner join   
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
       
 RETURN      
  

