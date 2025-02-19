

---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- exec [dbo].[SP_RPT_CALCULATE_PRESENT_DAYS] 2,'2022-06-01 00:00:00','2022-06-30 00:00:00',0,0,0,0,0,0,0,'2661',2,'0','0','0','0'
CREATE PROCEDURE [dbo].[SP_RPT_CALCULATE_PRESENT_DAYS_temp]      
  @Cmp_ID    numeric      
 ,@From_Date   datetime      
 ,@To_Date    datetime       
 ,@Branch_ID   numeric      
 ,@Cat_ID    numeric       
 ,@Grd_ID    numeric      
 ,@Type_ID    numeric      
 ,@Dept_ID    numeric      
 ,@Desig_ID    numeric      
 ,@Emp_ID    numeric      
 ,@constraint   varchar(max)      
 ,@Return_Record_set numeric =1  
 ,@StrWeekoff_Date varchar(max) = ''     
 ,@PBranch_ID varchar(200) = '0'  
 ,@max_OTDaily numeric (18,2) = 0
 ,@max_OTMonthly numeric(18,2)  =0
 ,@Report_Type	tinyint = 0   --Added By Jaina 12-09-2016
AS      
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON        
         
Declare @Count   numeric       
Declare @Tmp_Date datetime

Declare @Sal_St_Date as datetime
Declare @Sal_End_Date as datetime
declare @Manual_Salary as tinyint
declare @Month numeric
declare @year numeric
set @Month=MONTH(@FROM_DATE);
set @year= YEAR(@FROM_DATE);--YEAR(@FROM_DATE)-1;        

/*
declare @data table
( /*
   Emp_Id   numeric ,       
   For_date datetime,      
   Duration_in_sec numeric,      
   Shift_ID numeric ,      
   Shift_Type numeric ,      
   Emp_OT  varchar(10) ,      
   Emp_OT_min_Limit numeric,      
   Emp_OT_max_Limit numeric,      
   P_days  numeric(12,1) default 0,      
   OT_Sec  numeric default 0  ,
	Emp_Full_Name varchar(100),
	Emp_Code numeric(22,0),
	Shift_Name varchar(100),
	Cmp_Name varchar(100),
	Cmp_Address varchar(500),
	Branch_Address varchar(500),
	Dept_Name varchar(50),
	Comp_Name varchar(100),
	Desig_Name varchar(50),
	Type_Name varchar(50),
	Grd_Name varchar(50),
	Branch_Name varchar(50),
	Date_of_Join datetime,
	Gender varchar,
	Working_Hour  numeric(22,2),
	OT_Hour   numeric(22,2),
	Basic_Salary numeric(18,2) Default 0,
	Weekoff_OT_Sec  numeric default 0,
	Holiday_OT_Sec  numeric default 0
	,Weekoff_OT_Hour   numeric(22,2), -- Added by mitesh on 18042012
	Holiday_OT_Hour   numeric(22,2)*/
	Emp_Id   numeric ,         
   For_date datetime,        
   Duration_in_sec numeric,        
   Shift_ID numeric ,        
   Shift_Type numeric ,        
   Emp_OT  numeric ,        
   Emp_OT_min_Limit numeric,        
   Emp_OT_max_Limit numeric,        
   --P_days  numeric(12,1) default 0, 
   P_days  numeric(12,3) default 0,	--Ankit 07072014       
   OT_Sec  numeric default 0  ,
   In_Time datetime,
   Shift_Start_Time datetime,
   OT_Start_Time numeric default 0,
   Shift_Change tinyint default 0,
   Flag int default 0,
   Weekoff_OT_Sec  numeric default 0,
   Holiday_OT_Sec  numeric default 0,
	--Weekoff_OT_Hour   numeric(22,2),   
	--Holiday_OT_Hour   numeric(22,2)
   Chk_By_Superior numeric default 0,
   IO_Tran_Id	   numeric default 0, -- io_tran_id is used for is_cmp_purpose (t0150_emp_inout)
   OUT_Time datetime,
   Shift_End_Time datetime,			--Ankit 16112013
   OT_End_Time numeric default 0,	--Ankit 16112013
   Working_Hrs_St_Time tinyint default 0, --Hardik 14/02/2014
   Working_Hrs_End_Time tinyint default 0, --Hardik 14/02/2014
   GatePass_Deduct_Days numeric(18,2) default 0 -- Add by Gadriwala Muslim 05012014
)      */
set @Tmp_Date = @From_Date      

--CREATE table #Emp_Holiday
--	  (
--			Emp_Id		numeric , 
--			Cmp_ID		numeric,
--			For_Date	datetime,
--			H_Day		numeric(3,1),
--			is_Half_day tinyint
--	  )	

--Added By Ramiz on 27/11/2015------
/*---Added by Sumit on 16-feb-2017----------------------------*/
if(charindex('#',@constraint,0)=0 and @constraint<>'')
	Begin
		set @Emp_ID=@constraint
	
	   SELECT @Branch_ID =I.Branch_ID FROM T0095_Increment I WITH (NOLOCK) inner join 
				(
					select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
					(
							Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
							Where Increment_effective_Date <= @to_date 
							and Emp_ID=@Emp_ID 
							Group by emp_ID
					)		new_inc on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
							Where TI.Increment_effective_Date <= @to_date 
							and TI.Emp_ID=@Emp_ID
							group by ti.emp_id
				) Qry on I.Increment_Id = Qry.Increment_Id 
							
	End	
		
		SELECT	@Sal_St_Date = GS.Sal_St_Date,@Manual_Salary=ISNULL(GS.Manual_Salary_Period,0)
			FROM T0040_GENERAL_SETTING GS WITH (NOLOCK) INNER JOIN
								( 
									SELECT MAX(For_Date) AS For_Date,Branch_ID FROM T0040_GENERAL_SETTING WITH (NOLOCK)
									WHERE  Cmp_ID = @cmp_ID AND Branch_ID = isnull(@BRANCH_ID,Branch_ID) 
									GROUP BY Branch_ID
								) Qry ON Qry.Branch_ID = GS.Branch_ID AND GS.For_Date = Qry.For_Date
							WHERE Cmp_ID = @cmp_ID AND GS.Branch_ID = isnull(@BRANCH_ID,GS.Branch_ID)
		
		if (@Manual_Salary=1)
		Begin
			select @Sal_St_Date = from_date,@SAL_END_DATE=end_date from Salary_Period 
			where MONTH=@Month and year=@year;
		End							  
							  
		set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date));	


		if (DAY(@FROM_DATE) < DAY(@Sal_St_Date))
				Begin					
					if (@Month = 1 )
						Begin
							set @Month=12;
							set @year= YEAR(@FROM_DATE) - 1;
						End
					Else
						Begin
							set @Month=@Month-1;							
						End	
					set @Sal_St_Date =CAST(CAST(@Month AS VARCHAR(20)) + '-' + CAST(DAY(@Sal_St_Date) AS VARCHAR(20)) + '-' + CAST(@year AS VARCHAR(20)) AS DATETIME)
				End
			Else
				Begin	
					set @Sal_St_Date =CAST(CAST(MONTH(@FROM_DATE) AS VARCHAR(20)) + '-' + CAST(DAY(@Sal_St_Date) AS VARCHAR(20)) + '-' + CAST(YEAR(@FROM_DATE) AS VARCHAR(20)) AS DATETIME)
				End
			
			set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date)) 			
			
		if(@Sal_St_Date is not null and @Sal_End_Date is not null)
			Begin
				set @From_Date=@Sal_St_Date
				set @To_Date=@Sal_End_Date
			End	


/*--------------------------------------------------*/

IF OBJECT_ID('tempdb..#EMP_HOLIDAY') IS NULL
		BEGIN
			CREATE TABLE #EMP_HOLIDAY
			(
				EMP_ID NUMERIC,
				FOR_DATE DATETIME,
				IS_CANCEL BIT,
				Is_Half tinyint,
				Is_P_Comp tinyint,
				H_DAY numeric(3,1)
			);
			CREATE UNIQUE CLUSTERED INDEX IX_EMP_HOLIDAY_EMPID_FORDATE ON #EMP_HOLIDAY(EMP_ID, FOR_DATE);
		END 
	  
if @Return_Record_set = 1 or @Return_Record_set = 2 or @Return_Record_set =3  or @Return_Record_set =6   or    @Return_Record_set =7 or @Return_Record_set = 8 OR @Return_Record_set = 9 or @Return_Record_set = 10 or @Return_Record_set = 11
 Begin      
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
   --P_days  numeric(12,1) default 0, 
   P_days  numeric(12,3) default 0,	--Ankit 07072014       
   OT_Sec  numeric default 0  ,
   In_Time datetime,
   Shift_Start_Time datetime,
   OT_Start_Time numeric default 0,
   Shift_Change tinyint default 0,
   Flag int default 0,
   Weekoff_OT_Sec  numeric default 0,
   Holiday_OT_Sec  numeric default 0,   
   Chk_By_Superior numeric default 0,
   IO_Tran_Id	   numeric default 0, -- io_tran_id is used for is_cmp_purpose (t0150_emp_inout)
   OUT_Time datetime,
   Shift_End_Time datetime,			--Ankit 16112013
   OT_End_Time numeric default 0,	--Ankit 16112013
   Working_Hrs_St_Time tinyint default 0, --Hardik 14/02/2014
   Working_Hrs_End_Time tinyint default 0, --Hardik 14/02/2014
   GatePass_Deduct_Days numeric(18,2) default 0 -- Add by Gadriwala Muslim 05012014
   --Weekoff_OT_Hour   numeric(22,2),   
   --Holiday_OT_Hour   numeric(22,2)
   )     
	exec SP_CALCULATE_PRESENT_DAYS @Cmp_ID=@Cmp_ID,@From_Date=@From_Date,@To_Date=@To_Date,@Branch_ID=@Branch_ID,@Cat_ID=@Cat_ID,@Grd_ID=@Grd_ID,@Type_ID=@Type_ID,@Dept_ID=@Dept_ID,@Desig_ID=@Desig_ID,@Emp_ID=@Emp_ID,@constraint=@constraint,@Return_Record_set=4
   Alter Table  #Data Add Weekoff_OT_Hour   numeric(22,2);
   Alter Table  #Data Add Holiday_OT_Hour   numeric(22,2);
  
  
  
   Declare @Data_temp1 table---For Multi inout Solution         
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
	   IO_Tran_Id	   numeric default 0, -- io_tran_id is used for is_cmp_purpose (t0150_emp_inout)
	   OUT_Time datetime,
	   Shift_End_Time datetime,			--Ankit 16112013
	   OT_End_Time numeric default 0,	--Ankit 16112013
	   Working_Hrs_St_Time tinyint default 0, --Hardik 14/02/2014
	   Working_Hrs_End_Time tinyint default 0, --Hardik 14/02/2014
	   GatePass_Deduct_Days numeric(18,2) default 0, -- Add by Gadriwala Muslim 05012014
	   Weekoff_OT_Hour   numeric(22,2),
	   Holiday_OT_Hour   numeric(22,2)
   )        
 end        
        
 --Ankit 05112015
 IF @Return_Record_set = 8 OR @Return_Record_set = 9 
	BEGIN
		
		ALTER TABLE  #Data 
		ADD Duration varchar(10)
		
		ALTER TABLE  #Data 
		ADD No_of_Days numeric(18,2)
		
		DECLARE @BRANCH_ID_OD NUMERIC
		DECLARE @Emp_ID_OD NUMERIC
		DECLARE @Is_Cancel_Holiday INT
		Declare @StrHoliday_Date varchar(Max)
		Declare @Is_Cancel_Weekoff  Numeric(1,0) 
		declare @StrHoliday_Date_W varchar(max)
		declare @Holiday_days_W varchar(max)
		declare @Cancel_Holiday_W varchar (max)
		Declare @StrWeekoff_Date_W varchar(max)
		declare @Weekoff_Days_W varchar(max)
		declare @Cancel_Weekoff_w varchar(max)
		Declare @For_date_W Datetime
		
		Set @StrHoliday_Date = ''
		
		CREATE TABLE #OD_Emp_Weekoff
		  (
				Emp_Id		numeric , 
				For_Date	datetime,
				W_Day		numeric(3,1)
		  )	
		  
		 CREATE TABLE #Emp_Weekoff_temp
		  (
				Emp_Id		numeric , 
				For_Date	datetime
		  )
	END
  

  


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
     
    /*
	 CREATE TABLE #Emp_Cons -- Ankit 06092014 for Same Date Increment
	 (      
	   Emp_ID numeric ,     
	   Branch_ID numeric,
	   Increment_ID numeric    
	 )  
	
	EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,0 ,0 ,0,0,0,0,0,0,2,@PBranch_ID      
 
    
 --Declare #Emp_Cons Table      
 --(      
 -- Emp_ID numeric      
 --)      
       
 --if @Constraint <> ''      
 -- begin      
 --  Insert Into #Emp_Cons(Emp_ID)      
 --  select  cast(data  as numeric) from dbo.Split (@Constraint,'#')       
 -- end      
 --else      
 -- begin      
 --  if @PBranch_ID <> '0' and isnull(@Branch_ID,0) = 0
	--	begin
			
	--		Insert Into #Emp_Cons(Emp_ID)      
		      
	--	   select I.Emp_Id from T0095_Increment I inner join       
	--		 ( select max(Increment_effective_Date) as For_Date , Emp_ID From T0095_Increment      
	--		 where Increment_Effective_date <= @To_Date      
	--		 and Cmp_ID = @Cmp_ID      
	--		 group by emp_ID  ) Qry on      
	--		 I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date       
		             
	--	   Where Cmp_ID = @Cmp_ID     
	--	   and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
	--	   and Branch_ID in (select cast(isnull(data,0) as numeric) from dbo.Split(@PBranch_ID,'#'))
	--	   --and Branch_ID = isnull(@Branch_ID ,Branch_ID)      
	--	   and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
	--	   and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
	--	   and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
	--	   and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))      
	--	   and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID)   
		   
	--	end
	--else	
	--	begin
				
	--	   Insert Into #Emp_Cons(Emp_ID)      
		      
	--	   select I.Emp_Id from T0095_Increment I inner join       
	--		 ( select max(Increment_effective_Date) as For_Date , Emp_ID From T0095_Increment      
	--		 where Increment_Effective_date <= @To_Date      
	--		 and Cmp_ID = @Cmp_ID      
	--		 group by emp_ID  ) Qry on      
	--		 I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date       
		             
	--	   Where Cmp_ID = @Cmp_ID       
	--	   and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
	--	   and Branch_ID = isnull(@Branch_ID ,Branch_ID)      
	--	   and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
	--	   and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
	--	   and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
	--	   and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))      
	--	   and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID)   
		   
	--	end          
 -- end      
       
       
 --Insert into #Data (Emp_ID,For_Date,Duration_In_sec,Emp_OT,Emp_OT_min_Limit,Emp_OT_max_Limit,In_Time,Shift_Start_Time,OT_Start_Time,Shift_Change)        
              
 --     select eir.Emp_ID ,for_Date,sum(isnull(datediff(s,in_time,out_time),0)) ,isnull(Emp_OT,0),dbo.F_Return_Sec(Emp_OT_min_Limit),dbo.F_Return_Sec(Emp_OT_max_Limit),In_Time,null,0,0      
 --  from T0150_emp_inout_Record  EIR Inner join #Emp_Cons Ec on EIR.Emp_Id = ec.Emp_ID inner Join        
 --   (select I.Emp_ID,Emp_OT,isnull(Emp_OT_min_Limit,'00:00')Emp_OT_min_Limit,isnull(Emp_OT_max_Limit,'00:00')Emp_OT_max_Limit from T0095_Increment  I inner join         
 --   (select max(increment_effective_Date)IE_Date ,Emp_ID from T0095_Increment         
 --    where increment_effective_Date <=@To_Date and Cmp_ID =@Cmp_ID group by Emp_ID)q on I.emp_ID =q.Emp_ID and         
 --   I.Increment_effective_Date = q.IE_Date ) IQ on eir.Emp_ID =iq.emp_ID        
 --  Where cmp_Id= @Cmp_ID        
 --  and for_Date >=@From_Date and For_Date <=@To_Date        
 --  group by eir.Emp_ID,eir.For_Date,Emp_OT,Emp_OT_min_Limit,Emp_OT_max_Limit,In_Time 
 
 
 declare @curEmp_ID numeric
	
	--Declare curautobranch cursor for	                  
	--select Emp_ID from #Emp_Cons 
	--Open curautobranch                      
	--Fetch next from curautobranch into @curEmp_ID
	   
	--	While @@fetch_status = 0                    
	--	Begin     
         
	--		Declare @First_In_Last_Out_For_InOut_Calculation tinyint 

	--		Select @First_In_Last_Out_For_InOut_Calculation= isnull(First_In_Last_Out_For_InOut_Calculation,0) from T0040_GENERAL_SETTING where Cmp_ID = @Cmp_ID and Branch_ID = (Select Branch_ID from T0080_EMP_MASTER where Emp_ID=@curEmp_ID)
			
	--		if @First_In_Last_Out_For_InOut_Calculation = 1
	--			Begin				
				
	--				----- changed to get record with only Min(InTime) and Max(OutTime) ------

	--					  Insert into #Data (Emp_ID,For_Date,Duration_In_sec,Emp_OT,Emp_OT_min_Limit,Emp_OT_max_Limit,In_Time,Shift_Start_Time,OT_Start_Time,Shift_Change)        
					              
	--				   select distinct eir.Emp_ID ,EIR.for_Date,isnull(datediff(s,In_Date,Case when Max_In_Date > Out_Date Then Max_In_Date Else Out_Date End),0) ,isnull(Emp_OT,0),dbo.F_Return_Sec(Emp_OT_min_Limit),dbo.F_Return_Sec(Emp_OT_max_Limit),In_Date,null,0,0      
	--				   from T0150_emp_inout_Record  EIR Inner join #Emp_Cons Ec on EIR.Emp_Id = ec.Emp_ID inner Join        
	--					(select I.Emp_ID,Emp_OT,isnull(Emp_OT_min_Limit,'00:00')Emp_OT_min_Limit,isnull(Emp_OT_max_Limit,'00:00')Emp_OT_max_Limit from T0095_Increment  I inner join         
	--					(select max(increment_effective_Date)IE_Date ,Emp_ID from T0095_Increment         
	--					 where increment_effective_Date <=@To_Date and Cmp_ID =@Cmp_ID group by Emp_ID)q on I.emp_ID =q.Emp_ID and         
	--					I.Increment_effective_Date = q.IE_Date ) IQ on eir.Emp_ID =iq.emp_ID 
	--					Inner Join
	--					(select Emp_Id, Min(In_Time) In_Date,For_Date From T0150_Emp_Inout_Record Group By Emp_Id,For_Date) Q1 on EIR.Emp_Id = Q1.Emp_Id 
	--					And EIR.For_Date = Q1.For_Date
	--					Inner Join
	--					(select Emp_Id, Max(Out_Time) Out_Date,For_Date From T0150_Emp_Inout_Record Group By Emp_Id,For_Date) Q2 on EIR.Emp_Id = Q2.Emp_Id 
	--					And EIR.For_Date = Q2.For_Date  inner join
	--					--Added by Hardik 23/07/2012 for First IN And Last OUT (it will take Max In Punch as OUT and calculate Hours)
	--					(select Emp_Id, Max(In_Time) Max_In_Date,For_Date From T0150_Emp_Inout_Record Group By Emp_Id,For_Date) Q4 on EIR.Emp_Id = Q4.Emp_Id  
	--					And EIR.For_Date = Q4.For_Date
	--				   Where cmp_Id= @Cmp_ID        
	--				   and EIR.for_Date >=@From_Date and EIR.For_Date <=@To_Date  and ec.Emp_ID = @curEmp_ID      
	--				   group by eir.Emp_ID,eir.For_Date,Emp_OT,Emp_OT_min_Limit,Emp_OT_max_Limit,In_Time,In_Date ,out_Date ,Max_In_Date
					   
	--				 ------------------end--------------------         
	--			End
	--		Else
	--			Begin

	--				Insert into #Data (Emp_ID,For_Date,Duration_In_sec,Emp_OT,Emp_OT_min_Limit,Emp_OT_max_Limit,In_Time,Shift_Start_Time,OT_Start_Time,Shift_Change)        
				      
	--				  select eir.Emp_ID ,for_Date,sum(isnull(datediff(s,in_time,out_time),0)) ,isnull(Emp_OT,0),dbo.F_Return_Sec(Emp_OT_min_Limit),dbo.F_Return_Sec(Emp_OT_max_Limit),In_Time,null,0,0      
	--				   from T0150_emp_inout_Record  EIR Inner join #Emp_Cons Ec on EIR.Emp_Id = ec.Emp_ID inner Join        
	--					(select I.Emp_ID,Emp_OT,isnull(Emp_OT_min_Limit,'00:00')Emp_OT_min_Limit,isnull(Emp_OT_max_Limit,'00:00')Emp_OT_max_Limit from T0095_Increment  I inner join         
	--					(select max(increment_effective_Date)IE_Date ,Emp_ID from T0095_Increment         
	--					 where increment_effective_Date <=@To_Date and Cmp_ID =@Cmp_ID group by Emp_ID)q on I.emp_ID =q.Emp_ID and         
	--					I.Increment_effective_Date = q.IE_Date ) IQ on eir.Emp_ID =iq.emp_ID        
	--				   Where cmp_Id= @Cmp_ID        
	--				   and for_Date >=@From_Date and For_Date <=@To_Date   and ec.Emp_ID = @curEmp_ID
	--				   group by eir.Emp_ID,eir.For_Date,Emp_OT,Emp_OT_min_Limit,Emp_OT_max_Limit,In_Time  
					   
	--			End
			
	--		fetch next from curautobranch into @curEmp_ID
		  
	--	end                    
	--close curautobranch                    
	--deallocate curautobranch
	declare @In_Date as datetime      
	declare @Out_Date as datetime      
	declare @Shift_Dur_N as varchar(10)      
	Declare @Temp_Date as datetime      
	declare @Min_Dur as varchar(10)      
	declare @Shift_Id_N as Numeric
	--Declare @Shift_Sec as Numeric
	declare @Shift_St_Sec as numeric       
	declare @Shift_En_sec as numeric    
	declare @Shift_St_Time as varchar(10)      
	declare @Shift_End_Time as varchar(10)      

	Declare @Shift_End_DateTime as datetime      
	Declare @Shift_ST_DateTime as datetime			
	declare @Insert_In_Date as datetime      
	Declare @Insert_Out_Date as datetime      
	Declare @Second_Break_Duration as varchar(10)
	Declare @Second_Break_Duration_Sec as Numeric
	
	Declare curautobranch cursor for	                  
	select Emp_ID from #Emp_Cons 
	Open curautobranch                      
	Fetch next from curautobranch into @curEmp_ID
	   
		While @@fetch_status = 0
		Begin
			Declare @Temp_End_Date as datetime       
			Declare @Temp_Month_Date as datetime
			--set @Temp_End_Date = Dateadd(d,1,@To_Date)   
			set @Temp_Month_Date = @From_Date   
			set @Temp_End_Date = @To_Date      
		          
			while @Temp_Month_Date <= @Temp_End_Date      
			 begin      
				set @Shift_Id_N = 0      
		            
				Exec SP_CURR_T0100_EMP_SHIFT_GET @curEmp_ID,@Cmp_ID,@Temp_Month_Date,@Shift_St_Time output,@Shift_End_Time output,@Shift_Dur_N output,null,@Second_Break_Duration Output,null,null,@Shift_Id_N output      
		        
		        
				set @Shift_St_Sec = dbo.F_Return_Sec(@Shift_St_Time)      
				set @Shift_En_Sec = dbo.F_Return_Sec(@Shift_End_Time)      
				Set @Second_Break_Duration_Sec = dbo.F_Return_Sec(@Second_Break_Duration)      		            


				set @Shift_St_Datetime = cast(cast(@Temp_Month_Date as varchar(11)) + ' ' + @Shift_St_Time as smalldatetime)      
				set @Temp_Date = dateadd(d,1,@Temp_Month_Date)      

				if @Shift_St_Sec > @Shift_En_Sec       
					set @Shift_End_DateTime = cast(cast(@Temp_Date as varchar(11)) + ' ' + @Shift_End_Time  as smalldatetime)      
				else      
					set @Shift_End_DateTime = cast(cast(@Temp_Month_Date as varchar(11)) + ' ' + @Shift_End_Time  as smalldatetime)      
				     

						Declare @First_In_Last_Out_For_InOut_Calculation tinyint 
						declare @cBrh as numeric
						
						select @cBrh  = Branch_ID from T0095_Increment EI where Increment_Effective_Date in (select max(Increment_effective_Date) as Increment_effective_Date from T0095_Increment  where Increment_Effective_date <= @From_Date  and Cmp_ID = @Cmp_ID and Emp_ID = @curEmp_ID) and Emp_ID = @curEmp_ID
						select @First_In_Last_Out_For_InOut_Calculation  = isnull(First_In_Last_Out_For_InOut_Calculation,0) from T0040_GENERAL_SETTING where Branch_ID = @cBrh  and For_Date in (select MAX(For_Date) as for_date from T0040_GENERAL_SETTING where For_Date <= @From_Date and Cmp_ID = Cmp_ID and Branch_ID = @cBrh) and Cmp_ID = @Cmp_ID			
						
						if @First_In_Last_Out_For_InOut_Calculation = 1
							Begin				
								----- changed to get record with only Min(InTime) and Max(OutTime) ------
								If CONVERT(varchar(5), @Shift_St_Time, 108) < CONVERT(varchar(5), @Shift_End_Time, 108)
									Begin
										
										Insert into #Data (Emp_ID,For_Date,Duration_In_sec,Emp_OT,Emp_OT_min_Limit,Emp_OT_max_Limit,In_Time,Shift_Start_Time,OT_Start_Time,Shift_Change,Shift_ID)        
										Select distinct eir.Emp_ID ,EIR.for_Date,isnull(datediff(s,In_Date,Case when Max_In_Date > Out_Date Then Max_In_Date Else Out_Date End),0) - Isnull(@Second_Break_Duration_Sec,0) ,isnull(Emp_OT,0),dbo.F_Return_Sec(Emp_OT_min_Limit),dbo.F_Return_Sec(Emp_OT_max_Limit),In_Date,null,0,0, @Shift_Id_N
										from T0150_emp_inout_Record  EIR Inner join #Emp_Cons Ec on EIR.Emp_Id = ec.Emp_ID inner Join        
											(select I.Emp_ID,Emp_OT,isnull(Emp_OT_min_Limit,'00:00')Emp_OT_min_Limit,isnull(Emp_OT_max_Limit,'00:00')Emp_OT_max_Limit from T0095_Increment  I inner join         
											(select max(Increment_ID)Increment_ID ,Emp_ID from T0095_Increment         -- Ankit 06092014 for Same Date Increment
											 where increment_effective_Date <=@To_Date and Cmp_ID =@Cmp_ID group by Emp_ID)q on I.emp_ID =q.Emp_ID and         
											I.Increment_ID = q.Increment_ID ) IQ on eir.Emp_ID =iq.emp_ID 
											Inner Join
											(select Emp_Id, Min(In_Time) In_Date,For_Date From T0150_Emp_Inout_Record Group By Emp_Id,For_Date) Q1 on EIR.Emp_Id = Q1.Emp_Id 
											And EIR.For_Date = Q1.For_Date
											Inner Join
											(select Emp_Id, Max(Out_Time) Out_Date,For_Date From T0150_Emp_Inout_Record Group By Emp_Id,For_Date) Q2 on EIR.Emp_Id = Q2.Emp_Id 
											And EIR.For_Date = Q2.For_Date
											Inner Join
											--Added by Hardik 23/07/2012 for First IN And Last OUT (it will take Max In Punch as OUT and calculate Hours)
											(select Emp_Id, Max(In_Time) Max_In_Date,For_Date From T0150_Emp_Inout_Record Group By Emp_Id,For_Date) Q4 on EIR.Emp_Id = Q4.Emp_Id  
											And EIR.For_Date = Q4.For_Date
											Left Outer Join 
											(Select Emp_ID,Chk_By_Superior Chk_By_Sup,For_Date from T0150_EMP_INOUT_RECORD where Chk_By_Superior=1) Q3 on EIR.Emp_Id = Q3.Emp_Id 
											And EIR.For_Date = Q3.For_Date
										Where cmp_Id= @Cmp_ID        
											and EIR.for_Date >=@Temp_Month_Date and EIR.For_Date <=@Temp_Month_Date  and ec.Emp_ID = @curEmp_ID      
										group by eir.Emp_ID,EIR.for_Date,Emp_OT,Emp_OT_min_Limit,Emp_OT_max_Limit,In_Time,In_Date,out_Date,Chk_By_Sup ,EIR.is_cmp_purpose,OUT_Time,Max_In_Date 
										order by EIR.for_Date		

																
									End
								Else ---Below Query For Night Shift
									Begin
									
										Insert into #Data (Emp_ID,For_Date,Duration_In_sec,Emp_OT,Emp_OT_min_Limit,Emp_OT_max_Limit,In_Time,Shift_Start_Time,OT_Start_Time,Shift_Change,Shift_ID)        
										Select distinct eir.Emp_ID ,Cast(@Shift_St_Datetime as varchar(11)),isnull(datediff(s,In_Date,Case when Max_In_Date > Out_Date Then Max_In_Date Else Out_Date End),0),isnull(Emp_OT,0),dbo.F_Return_Sec(Emp_OT_min_Limit),dbo.F_Return_Sec(Emp_OT_max_Limit),In_Date,null,0,0, @Shift_Id_N
										from T0150_emp_inout_Record  EIR Inner join #Emp_Cons Ec on EIR.Emp_Id = ec.Emp_ID inner Join        
											(select I.Emp_ID,Emp_OT,isnull(Emp_OT_min_Limit,'00:00')Emp_OT_min_Limit,isnull(Emp_OT_max_Limit,'00:00')Emp_OT_max_Limit from T0095_Increment  I inner join         
											(select max(Increment_ID)Increment_ID ,Emp_ID from T0095_Increment         -- Ankit 06092014 for Same Date Increment
											 where increment_effective_Date <=@To_Date and Cmp_ID =@Cmp_ID group by Emp_ID)q on I.emp_ID =q.Emp_ID and         
											I.Increment_ID = q.Increment_ID ) IQ on eir.Emp_ID =iq.emp_ID 
											Inner Join
											(select Emp_Id, Min(In_Time) In_Date, cast(@Shift_St_Datetime as varchar(11)) as For_Date From T0150_Emp_Inout_Record Where In_Time >=Dateadd(hh,-5,@Shift_St_Datetime) Group By Emp_Id) Q1 on EIR.Emp_Id = Q1.Emp_Id 
											And EIR.For_Date = Q1.For_Date
											Inner Join
											(select Emp_Id, Max(Out_Time) Out_Date, cast(@Shift_St_Datetime as varchar(11)) as For_Date From T0150_Emp_Inout_Record Where Out_Time <=Dateadd(hh,10,@Shift_End_Datetime) Group By Emp_Id) Q2 on EIR.Emp_Id = Q2.Emp_Id 
											And EIR.For_Date = Q2.For_Date
											Inner Join
											--Added by Hardik 23/07/2012 for First IN And Last OUT (it will take Max In Punch as OUT and calculate Hours)
											(select Emp_Id, Max(In_Time) Max_In_Date, cast(@Shift_St_Datetime as varchar(11)) as For_Date From T0150_Emp_Inout_Record Where Out_Time <=Dateadd(hh,10,@Shift_End_Datetime) Group By Emp_Id) Q4 on EIR.Emp_Id = Q4.Emp_Id  
											And EIR.For_Date = Q4.For_Date
											Left Outer Join 
											(Select Emp_ID,Chk_By_Superior Chk_By_Sup,For_Date from T0150_EMP_INOUT_RECORD where Chk_By_Superior=1) Q3 on EIR.Emp_Id = Q3.Emp_Id 
											And EIR.For_Date = Q3.For_Date
										Where cmp_Id= @Cmp_ID        
											--and EIR.In_Time >=Dateadd(hh,-5,@Shift_St_Datetime) and EIR.Out_Time <=Dateadd(hh,10,@Shift_End_Datetime) 
											and ec.Emp_ID = @curEmp_ID      
										group by eir.Emp_ID,Emp_OT,Emp_OT_min_Limit,Emp_OT_max_Limit,In_Time,In_Date,out_Date,Chk_By_Sup ,EIR.is_cmp_purpose,OUT_Time,Max_In_Date 
										order by Cast(@Shift_St_Datetime as varchar(11))									
								
									End								  
									------------------end--------------------
							End
						Else
							Begin
								If CONVERT(varchar(5), @Shift_St_Time, 108) < CONVERT(varchar(5), @Shift_End_Time, 108)
									Begin
										
										
										Insert into #Data 
											(Emp_ID,For_Date,Duration_In_sec,Emp_OT,Emp_OT_min_Limit,Emp_OT_max_Limit,In_Time,
											Shift_Start_Time,Shift_ID,OT_Start_Time,Shift_Change)        
									      
										  select eir.Emp_ID ,For_Date,sum(isnull(datediff(s,in_time,out_time),0)) ,isnull(Emp_OT,0),dbo.F_Return_Sec(Emp_OT_min_Limit),dbo.F_Return_Sec(Emp_OT_max_Limit),In_Time,
												@Shift_St_Time,@Shift_Id_N,0,0
										   from T0150_emp_inout_Record  EIR Inner join #Emp_Cons Ec on EIR.Emp_Id = ec.Emp_ID inner Join			
											(select I.Emp_ID,Emp_OT,isnull(Emp_OT_min_Limit,'00:00')Emp_OT_min_Limit,isnull(Emp_OT_max_Limit,'00:00')Emp_OT_max_Limit from T0095_Increment  I inner join         
											(select max(Increment_ID)Increment_ID ,Emp_ID from T0095_Increment         -- Ankit 06092014 for Same Date Increment
											 where increment_effective_Date <=@To_Date and Cmp_ID =@Cmp_ID group by Emp_ID)q on I.emp_ID =q.Emp_ID and         
											I.Increment_ID = q.Increment_ID ) IQ on eir.Emp_ID =iq.emp_ID 
																       
										   Where cmp_Id= @Cmp_ID        
										   and EIR.For_Date >=@Temp_Month_Date and EIR.For_Date <= @Temp_Month_Date and ec.Emp_ID = @curEmp_ID
										   group by eir.Emp_ID,Emp_OT,Emp_OT_min_Limit,Emp_OT_max_Limit,In_Time,Chk_By_Superior ,EIR.is_cmp_purpose,Out_Time, For_Date
										   order by For_Date
									End
								Else
									Begin
										Insert into #Data 
											(Emp_ID,For_Date,Duration_In_sec,Emp_OT,Emp_OT_min_Limit,Emp_OT_max_Limit,In_Time,
											Shift_Start_Time,Shift_ID,OT_Start_Time,Shift_Change)        
									      
										  select eir.Emp_ID ,Cast(@Shift_St_Datetime as varchar(11)),sum(isnull(datediff(s,in_time,out_time),0)) ,isnull(Emp_OT,0),dbo.F_Return_Sec(Emp_OT_min_Limit),dbo.F_Return_Sec(Emp_OT_max_Limit),In_Time,
												@Shift_St_Time,@Shift_Id_N,0,0
										   from T0150_emp_inout_Record  EIR Inner join #Emp_Cons Ec on EIR.Emp_Id = ec.Emp_ID inner Join			
											(select I.Emp_ID,Emp_OT,isnull(Emp_OT_min_Limit,'00:00')Emp_OT_min_Limit,isnull(Emp_OT_max_Limit,'00:00')Emp_OT_max_Limit from T0095_Increment  I inner join         
											(select max(Increment_ID)Increment_ID ,Emp_ID from T0095_Increment         -- Ankit 06092014 for Same Date Increment
											 where increment_effective_Date <=@To_Date and Cmp_ID =@Cmp_ID group by Emp_ID)q on I.emp_ID =q.Emp_ID and         
											I.Increment_ID = q.Increment_ID ) IQ on eir.Emp_ID =iq.emp_ID 
																       
										   Where cmp_Id= @Cmp_ID        
										   and EIR.In_Time >=Dateadd(hh,-5,@Shift_St_Datetime) and EIR.Out_Time <=Dateadd(hh,10,@Shift_End_Datetime) and ec.Emp_ID = @curEmp_ID
										   group by eir.Emp_ID,Emp_OT,Emp_OT_min_Limit,Emp_OT_max_Limit,In_Time,Chk_By_Superior ,EIR.is_cmp_purpose,Out_Time  
										   order by Cast(@Shift_St_Datetime as varchar(11))
										End								   
							End


				set @Temp_Month_Date = Dateadd(d,1,@Temp_Month_Date)       
			 end 		        
	 
			fetch next from curautobranch into @curEmp_ID
		  
		End                 
	close curautobranch                    
	deallocate curautobranch


     -- select * from #Data
           --Insert Into @Data_temp1 (Emp_ID,For_Date,Duration_In_sec,Emp_OT,Emp_OT_min_Limit,Emp_OT_max_Limit,In_Time,Shift_Start_Time,OT_Start_Time,Shift_Change)
           --Select Emp_ID,for_Date,sum(isnull(Duration_in_sec,0)),isnull(Emp_OT,0),dbo.F_Return_Sec(isnull(Emp_OT_min_Limit,0)),dbo.F_Return_Sec(isnull(Emp_OT_max_Limit,0)),null,null,0,0             
           -- From #Data Group By For_Date,Emp_ID,Emp_Ot,Emp_OT_min_Limit,Emp_OT_Max_Limit
     
            Insert Into @Data_temp1 (Emp_ID,For_Date,Duration_In_sec,Emp_OT,Emp_OT_min_Limit,Emp_OT_max_Limit,In_Time,Shift_Start_Time,OT_Start_Time,Shift_Change)
           Select Emp_ID,for_Date,sum(isnull(Duration_in_sec,0)),isnull(Emp_OT,0),isnull(Emp_OT_min_Limit,0),isnull(Emp_OT_max_Limit,0),null,null,0,0             
            From #Data Group By For_Date,Emp_ID,Emp_Ot,Emp_OT_min_Limit,Emp_OT_Max_Limit

	   Update @Data_temp1 set In_Time=InTime
	   from  @Data_temp1 as DT	
	   inner join
	   (select Min(In_Time) as InTime,For_Date,Emp_ID from #Data Group by For_Date,Emp_ID)Q
	   on DT.Emp_ID=Q.Emp_ID and Dt.For_Date=Q.For_Date 	 	   	
           
		Delete From #Data          
		
		Insert Into #data 
		select * from @Data_temp1
		
	
 
 	--Add by Nimesh 21 April, 2015
	--This sp retrieves the Shift Rotation as per given employee id and effective date.
	--it will fetch all employee's shift rotation detail if employee id is not specified.
	IF (OBJECT_ID('tempdb..#Rotation') IS NULL)
		Create Table #Rotation (R_EmpID numeric(18,0), R_DayName varchar(25), R_ShiftID numeric(18,0), R_Effective_Date DateTime);
	--The #Rotation table gets re-created in dbo.P0050_UNPIVOT_EMP_ROTATION stored procedure
	Exec dbo.P0050_UNPIVOT_EMP_ROTATION @Cmp_ID, NULL, @To_Date, @constraint

 
	SET @Tmp_Date =@From_Date      
      	
	WHILE @Tmp_Date <=@To_Date BEGIN      
	   /*Commented by Nimesh 20 May 2015
	   Update #Data        
		 set Shift_ID   = Q1.Shift_ID,          
	   Shift_Type = q1.Shift_type 
		 from #Data d inner Join        
		 (select q.Shift_ID ,q.Emp_ID,shift_type,q.For_Date from T0100_Emp_Shift_Detail sd inner join        
		 (select for_Date ,Emp_Id,Shift_ID   from T0100_Emp_Shift_Detail    as esdsub       
		 where Cmp_Id =@Cmp_ID and shift_Type = 0 and for_Date = (select max(for_Date) from T0100_Emp_Shift_Detail where emp_id = esdsub.emp_id and Cmp_Id =@Cmp_ID and shift_Type = 0 and For_Date <= @Tmp_Date ) )q on sd.Emp_ID =q.Emp_ID and sd.For_Date =q.For_Date)q1  on d.emp_ID = q1.emp_ID         
		Where D.For_Date = @tmp_Date     

	                                 
	  Update #Data        
		set Shift_ID   = Q1.Shift_ID,          
	  Shift_Type = q1.Shift_type        
	  from #Data d inner Join        
		(select q.Shift_ID ,q.Emp_ID,shift_type,q.For_Date from T0100_Emp_Shift_Detail   sd inner join        
		(select for_Date ,Emp_Id,Shift_ID   from T0100_Emp_Shift_Detail          as esdsub   
		 where Cmp_Id =@Cmp_ID and shift_Type = 1 and for_Date = (select max(for_Date) from T0100_Emp_Shift_Detail where  emp_id = esdsub.emp_id and Cmp_Id =@Cmp_ID and  shift_Type = 1 and For_Date <= @Tmp_Date ) )q on sd.Emp_ID =q.Emp_ID and sd.For_Date =q.For_Date)q1  on d.emp_ID = q1.emp_ID         
	   Where D.For_Date = @tmp_Date 
	   
	   
	   Update #Data
		set Shift_Start_Time = q.Shift_St_Time,
		OT_Start_Time=isnull(q.OT_Start_Time,0) 
		from #data d inner join 
		(select ST.Shift_st_time,ST.Shift_ID,isnull(SD.OT_Start_Time,0) as OT_Start_Time from t0040_shift_master ST left outer join t0050_shift_detail SD 
		on ST.Shift_ID=SD.Shift_ID ) q on d.shift_id=q.shift_id
		*/
	    
		--Modified by Nimesh 20 May 2015
		--Updating default shift info From Shift Detail
		UPDATE	#Data SET SHIFT_ID = Shf.Shift_ID, Shift_Type=Shf.Shift_Type
		FROM	#Data D INNER JOIN (SELECT esd.Shift_ID, esd.Emp_ID, esd.Shift_Type
		FROM	T0100_EMP_SHIFT_DETAIL esd INNER JOIN  
				(SELECT MAX(For_Date) AS For_Date,Emp_ID FROM T0100_EMP_SHIFT_DETAIL 
					WHERE Cmp_ID = ISNULL(@Cmp_ID,Cmp_ID) AND For_Date <= @Tmp_Date GROUP BY Emp_ID) S ON 
					esd.Emp_ID = S.Emp_ID AND esd.For_Date=s.For_Date) Shf ON 
				Shf.Emp_ID = D.EMP_ID 
		WHERE	D.For_Date=@Tmp_Date
	    
		--Updating Shift ID From Rotation
		UPDATE	#Data 
		SET		SHIFT_ID=SM.SHIFT_ID,Shift_Type=0
		FROM	#Rotation R INNER JOIN T0040_SHIFT_MASTER SM ON R.R_ShiftID=SM.Shift_ID					
		WHERE	SM.Cmp_ID=@Cmp_ID AND R.R_DayName = 'Day' + CAST(DATEPART(d, @Tmp_Date) As Varchar) AND
				Emp_Id=R.R_EmpID AND R.R_Effective_Date=(SELECT MAX(R_Effective_Date)
					FROM #Rotation R1 WHERE R1.R_EmpID=Emp_Id AND 
						 R_Effective_Date<=@Tmp_Date) 
				AND For_Date=@Tmp_Date
				
		
		--Updating Shift ID from Employee Shift Detail where ForDate=@TempDate ANd Shift_Type=0 
		--And Rotation should be assigned to that particular employee
		UPDATE	#Data 
		SET		SHIFT_ID=ESD.SHIFT_ID,Shift_Type=ESD.Shift_Type
		FROM	#Data D INNER JOIN (SELECT esd.Shift_ID, esd.Emp_ID, esd.Shift_Type,esd.For_Date
				FROM T0100_EMP_SHIFT_DETAIL esd WHERE Cmp_ID = ISNULL(@Cmp_ID,Cmp_ID) AND For_Date = @Tmp_Date) ESD ON
				D.Emp_Id=ESD.Emp_ID AND D.For_date=ESD.For_Date				
		WHERE	ESD.Emp_ID IN (Select R.R_EmpID FROM #Rotation R
					WHERE R_DayName = 'Day' + CAST(DATEPART(d, @Tmp_Date) As Varchar) AND R_Effective_Date<=@Tmp_Date
					GROUP BY R.R_EmpID) 
				AND D.For_date=@Tmp_Date

		--Updating Shift ID from Employee Shift Detail where ForDate=@TempDate ANd Shift_Type=1 
		--And Rotation should not be assigned to that particular employee
		UPDATE	#Data 
		SET		SHIFT_ID=ESD.SHIFT_ID,Shift_Type=ESD.Shift_Type
		FROM	#Data D INNER JOIN (SELECT esd.Shift_ID, esd.Emp_ID, esd.Shift_Type,esd.For_Date
				FROM T0100_EMP_SHIFT_DETAIL esd WHERE Cmp_ID = ISNULL(@Cmp_ID,Cmp_ID) AND For_Date = @Tmp_Date) ESD ON
				D.Emp_Id=ESD.Emp_ID AND D.For_date=ESD.For_Date				
		WHERE	IsNull(ESD.Shift_Type,0)=1 AND ESD.Emp_ID NOT IN (Select R.R_EmpID FROM #Rotation R
					WHERE R_DayName = 'Day' + CAST(DATEPART(d, @Tmp_Date) As Varchar) AND R_Effective_Date<=@Tmp_Date
					GROUP BY R.R_EmpID) 
				AND D.For_date=@Tmp_Date
		--End Nimesh
	  
		Update #Data set Shift_Start_Time= cast(CONVERT(VARCHAR(11), In_time, 121)  + CONVERT(VARCHAR(12), Shift_Start_Time, 114) as datetime)  from #Data
		SET @Tmp_Date = dateadd(d,1,@tmp_date)            
	 END  
	 
 Update #Data set Shift_Change=1 where isnull(datediff(s,in_time,Shift_Start_Time),0)  < -14400  
 Update #Data set Shift_Change=1 where isnull(datediff(s,in_time,Shift_Start_Time),0)  > 14400  

 
Declare @Emp_ID_AutoShift numeric
Declare @In_Time_Autoshift datetime
Declare @New_Shift_ID numeric
 declare curautoshift cursor for                    
    select Emp_ID,In_Time,d.Shift_ID from #Data d inner join T0040_SHIFT_MASTER s on d.Shift_ID = s.Shift_ID 
  where isnull(Shift_Change,0)=1 And isnull(Emp_OT,0)=1 and Isnull(s.Inc_Auto_Shift,0) = 1 order by In_time,Emp_ID
 open curautoshift                      
  fetch next from curautoshift into @Emp_ID_AutoShift,@In_Time_Autoshift,@New_Shift_ID
               
  while @@fetch_status = 0                    
   begin                    
       --select  @Emp_ID_AutoShift,@In_Time_Autoshift
       declare @Shift_ID_Autoshift numeric
       declare @Shift_start_time_Autoshift varchar(12)
       select @Shift_ID_Autoshift=Shift_ID,@Shift_start_time_Autoshift=Shift_st_time from t0040_shift_master where cmp_id=@Cmp_id and isnull(inc_auto_shift,0)=1 
       and datediff(s,@In_Time_Autoshift,cast(CONVERT(VARCHAR(11), @In_Time_Autoshift, 121)  + CONVERT(VARCHAR(12), Shift_St_Time, 114) as datetime)) >-14400
       
       if isnull(@Shift_ID_Autoshift,0) > 0 And isnull(@Shift_ID_Autoshift,0)<>isnull(@New_Shift_ID,0)
			Begin
				Update #Data set Shift_ID=@Shift_ID_Autoshift,Shift_Start_Time= cast(CONVERT(VARCHAR(11), In_time, 121)  + CONVERT(VARCHAR(12), @Shift_start_time_Autoshift, 114) as datetime)  from #Data
				where Emp_ID=@Emp_ID_AutoShift and In_time=@In_Time_Autoshift And Shift_ID <> @Shift_ID_Autoshift
				
			End
		else
			Begin
			select @Shift_ID_Autoshift=Shift_ID,@Shift_start_time_Autoshift=Shift_st_time from t0040_shift_master where cmp_id=@Cmp_id and isnull(inc_auto_shift,0)=1
			and datediff(s,@In_Time_Autoshift,cast(CONVERT(VARCHAR(11), @In_Time_Autoshift, 121)  + CONVERT(VARCHAR(12), Shift_St_Time, 114) as datetime)) <14400
			
			if isnull(@Shift_ID_Autoshift,0) > 0
					Begin 
						Update #Data set Shift_ID=@Shift_ID_Autoshift,Shift_Start_Time= cast(CONVERT(VARCHAR(11), In_time, 121)  + CONVERT(VARCHAR(12), @Shift_start_time_Autoshift, 114) as datetime)  from #Data
				        where Emp_ID=@Emp_ID_AutoShift and In_time=@In_Time_Autoshift And Shift_ID <> @Shift_ID_Autoshift
					End
			End
    fetch next from curautoshift into @Emp_ID_AutoShift,@In_Time_Autoshift,@New_Shift_ID
                  
   end                    
 close curautoshift                    
 deallocate curautoshift    
   
 Update #Data
    set OT_Start_Time=isnull(q.OT_Start_Time,0) 
    from #data d inner join 
    (select ST.Shift_st_time,ST.Shift_ID,isnull(SD.OT_Start_Time,0) as OT_Start_Time from t0040_shift_master ST left outer join t0050_shift_detail SD 
    on ST.Shift_ID=SD.Shift_ID ) q on d.shift_id=q.shift_id where isnull(d.shift_Change,0)=1
 
 
 update #Data set Duration_in_sec = Duration_in_sec - datediff(s,In_time,Shift_Start_Time)
 where datediff(s,In_time,Shift_Start_Time) > 0  And isnull(Emp_OT,0)=1 And isnull(OT_Start_Time,0)=1
 
 
  Update #Data        
  set Shift_ID   = Q1.Shift_ID,          
   Shift_Type = q1.Shift_type        
  from #Data d inner Join        
  (select sd.shift_ID ,sd.Emp_ID,shift_type,sd.For_Date from T0100_Emp_Shift_Detail   sd         
  Where Cmp_ID =@Cmp_ID and Shift_Type =1 and For_Date >=@From_Date and For_Date <=@To_Date )q1 on        
  D.emp_ID = q1.For_Date And d.For_Date =Q1.For_Date      
         
        
        
  -- Coment and Add by rohit on 12072013      

-- Declare @Emp_WeekOFf_Detail Table        
-- (        
--  Emp_ID numeric        ,
--  Strweekoff varchar(Max)    
-- )  

--insert into @Emp_WeekOFf_Detail 
--select Emp_ID,'' from #Emp_Cons



--Declare @Emp_Week_Detail numeric(18,0)
--Declare @strweekoff varchar(max)
--Declare @Is_Negative_Ot Int ---For negative yes or no take its value from general setting
-- declare curEmp_weekoff_Detail cursor for                    
--  select    Emp_ID from  #Emp_Cons order by Emp_ID
-- open curEmp_weekoff_Detail                      
--  fetch next from curEmp_weekoff_Detail into @Emp_Week_Detail
--  while @@fetch_status = 0                    
--   begin                    

--    Declare @Is_Cancel_Weekoff  Numeric(1,0) 
--    Declare @Weekoff_Days   Numeric(12,1)    
--	Declare @Cancel_Weekoff   Numeric(12,1)  
--	Declare @Week_oF_Branch numeric(18,0)
--	Declare @tras_week_ot tinyint
	
--	select @Week_oF_Branch=Branch_ID  from t0095_increment where Increment_id in (select Max(Increment_id) from t0095_increment where emp_id=@Emp_Week_Detail)
	
 
--	select @Is_Cancel_weekoff = Is_Cancel_weekoff ,@tras_week_ot=isnull(tras_week_ot,0)   
--	from T0040_GENERAL_SETTING where cmp_ID = @cmp_ID and Branch_ID = @Week_oF_Branch    
--	and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING where For_Date <=@To_Date and Branch_ID = @Week_oF_Branch and Cmp_ID = @Cmp_ID)    

--			set @StrWeekoff_Date=''
--			set @Weekoff_Days=0
--			set @Cancel_Weekoff=0
--			Exec SP_EMP_WEEKOFF_DATE_GET @Emp_Week_Detail,@Cmp_ID,@From_Date,@To_Date,null,null,@Is_Cancel_weekoff,'',@StrWeekoff_Date output,@Weekoff_Days output ,@Cancel_Weekoff output    



--	if isnull(@tras_week_ot,0)=1
--		Begin
		
--			--set @StrWeekoff_Date=''
--			--set @Weekoff_Days=0
--			--set @Cancel_Weekoff=0
--			--Exec SP_EMP_WEEKOFF_DATE_GET @Emp_Week_Detail,@Cmp_ID,@From_Date,@To_Date,null,null,@Is_Cancel_weekoff,'',@StrWeekoff_Date output,@Weekoff_Days output ,@Cancel_Weekoff output    
--			--Update 	@Emp_WeekOFf_Detail set Strweekoff=@StrWeekoff_Date where Emp_ID=@Emp_Week_Detail
		
--			declare @H_From_Date datetime
--			declare @H_To_Date datetime
			
--			declare cur1 cursor for 
--			select h_from_date,h_to_date  from t0040_holiday_master 
--			where cmp_Id = @Cmp_ID
--			and ( (convert(varchar(10),@From_Date,120)>=convert(varchar(10),h_from_date,120) and convert(varchar(10),@From_Date,120)<=convert(varchar(10),h_to_date,120))
--			or (convert(varchar(10),@To_Date,120)>=convert(varchar(10),h_from_date,120) and convert(varchar(10),@To_Date,120)<=convert(varchar(10),h_to_date,120))
--			or (convert(varchar(10),h_from_date,120)>=convert(varchar(10),@From_Date,120) and convert(varchar(10),h_from_date,120)<=convert(varchar(10),@To_Date,120))
--			or (convert(varchar(10),h_to_date,120)>=convert(varchar(10),@From_Date,120) and convert(varchar(10),h_to_date,120)<=convert(varchar(10),@To_Date,120)) )
--			order by H_from_date

--			open cur1
--			fetch next from cur1 into @H_From_Date,@H_To_Date

--			while @@fetch_status = 0
--			begin
--				if @H_From_Date = @H_To_Date
--					set @StrWeekoff_Date= @StrWeekoff_Date+';'+convert(varchar(11),@H_From_Date,100)
--				else 
--					begin
--						while @H_From_Date <= @H_To_Date
--						begin
--							set @StrWeekoff_Date= @StrWeekoff_Date+';'+ convert(varchar(11),@H_From_Date,100)
--							set @H_From_Date = dateadd(d,1,@H_From_Date)
							
--						end
--					end
--			fetch next from cur1 into @H_From_Date,@H_To_Date
--			end
--			close cur1
--			deallocate cur1
--			------------------------------End-------------------------------
			
--			Update 	@Emp_WeekOFf_Detail set Strweekoff=@StrWeekoff_Date where Emp_ID=@Emp_Week_Detail
			
--		End
	
--	fetch next from curEmp_weekoff_Detail into @Emp_Week_Detail
--   end                    
-- close curEmp_weekoff_Detail                    
-- deallocate curEmp_weekoff_Detail   
 
-- 	declare @Emp_Id_Temp1   numeric          
--	declare @For_date1 datetime   
--	declare @Duration_in_sec1 numeric          
--    declare @Emp_OT1  numeric         
--    declare @OT_Sec1  numeric 
   
   
   
--   declare curweekoff cursor for                    
--  select    Duration_in_sec,Emp_Id,For_date,Emp_OT,OT_Sec from  #Data  order by For_date
-- open curweekoff                      
--  fetch next from curweekoff into @Duration_in_sec1,@Emp_Id_Temp1,@For_date1,@Emp_OT1,@OT_Sec1
--  while @@fetch_status = 0                    
--   begin                    
   
--	if isnull(@Emp_OT1,0)=1
--		Begin
--			Declare @Final_weekoff_str varchar(max)
--			set @Final_weekoff_str=''
			
--			select @Final_weekoff_str = isnull(Strweekoff,'') from @Emp_WeekOFf_Detail where emp_id=@Emp_Id_Temp1
		
--			if charindex(cast(left(@For_date1,11) as varchar),@Final_weekoff_str) >0
--				Begin
						
--					Update #Data set Duration_in_sec =0,Ot_sec=dbo.F_Return_Without_Sec(@OT_Sec1+@Duration_in_sec1),P_days=0 where Emp_Id=@Emp_Id_Temp1
--					And For_Date=@For_date1
				
--				End
--		End
--	fetch next from curweekoff into @Duration_in_sec1,@Emp_Id_Temp1,@For_date1,@Emp_OT1,@OT_Sec1
--   end                    
-- close curweekoff                    
-- deallocate curweekoff    

    
Declare @Emp_WeekOFf_Detail Table        
 (        
  Emp_ID numeric        ,
  StrWeekoff_Holiday varchar(max),
  StrWeekoff varchar(max), --Hardik 07/09/2012    
  StrHoliday varchar(max), --Hardik 07/09/2012    
  strHalfday_Holiday varchar(max) -- Gadriwala 28082014 
 )  
 
 insert into @Emp_WeekOFf_Detail 
select Emp_ID,'','','','' from #Emp_Cons --Hardik 07/09/2012

Delete @Emp_WeekOFf_Detail Where Emp_ID Not In (Select Emp_ID From #Data Group By Emp_ID) --Hardik 07/09/2012


Declare @Emp_Week_Detail numeric(18,0)
Declare @strweekoff varchar(max)
Declare @Is_Negative_Ot Int ---For negative yes or no take its value from general setting

 declare curEmp_weekoff_Detail cursor Fast_forward for                    
  select    Emp_ID from  #Emp_Cons order by Emp_ID
 open curEmp_weekoff_Detail                      
  fetch next from curEmp_weekoff_Detail into @Emp_Week_Detail
  while @@fetch_status = 0                    
   begin                    

    Declare @Is_Cancel_Weekoff  Numeric(1,0) 
    Declare @Weekoff_Days   Numeric(12,1)    
	Declare @Cancel_Weekoff   Numeric(12,1)  
	Declare @Week_oF_Branch numeric(18,0)
	Declare @tras_week_ot tinyint
	Declare @Auto_OT tinyint
	Declare @OT_Present tinyint
	Declare @Is_Compoff Numeric
	Declare @Is_WD Numeric
    Declare @Is_WOHO Numeric
    
    Declare @Is_Cancel_Holiday Int
    Declare @StrHoliday_Date varchar(Max)
    Declare @Holiday_days Numeric(18,2)
    Declare @Cancel_Holiday Numeric(18,2)
    
    
 
	select @Week_oF_Branch=Branch_ID  from dbo.t0095_increment where Increment_id in (select Max(Increment_id) from dbo.t0095_increment where emp_id=@Emp_Week_Detail)
	
 
	Select @Is_Cancel_weekoff = Is_Cancel_weekoff ,@tras_week_ot=isnull(tras_week_ot,0)  ,@Auto_OT = Is_OT_Auto_Calc ,@OT_Present = OT_Present_days,@Is_Negative_Ot = ISNULL(Is_Negative_Ot,0), @Is_Compoff = ISNULL(Is_CompOff, 0), @Is_WD = ISNULL(Is_CompOff_WD,0), @Is_WOHO = ISNULL(Is_CompOff_WOHO,0)
		,@Is_Cancel_Holiday = Is_Cancel_Holiday --Hardik 07/09/2012
		From dbo.T0040_GENERAL_SETTING where cmp_ID = @cmp_ID and Branch_ID = @Week_oF_Branch    
		and For_Date = ( select max(For_Date) from dbo.T0040_GENERAL_SETTING where For_Date <=@To_Date and Branch_ID = @Week_oF_Branch and Cmp_ID = @Cmp_ID)    
	
  
			set @StrWeekoff_Date=''
			set @Weekoff_Days=0
			set @Cancel_Weekoff=0
			
			--Hardik 07/09/2012
			Set @StrHoliday_Date =''
			Set @Holiday_days = 0
			Set @Cancel_Holiday =0
			
			
			Exec dbo.SP_EMP_HOLIDAY_DATE_GET @Emp_Week_Detail,@Cmp_ID,@From_Date,@To_Date,null,null,@Is_Cancel_Holiday,@StrHoliday_Date output,@Holiday_days output,@Cancel_Holiday output,1,@Branch_ID,@StrWeekoff_Date
			Exec dbo.SP_EMP_WEEKOFF_DATE_GET @Emp_Week_Detail,@Cmp_ID,@From_Date,@To_Date,null,null,@Is_Cancel_weekoff,'',@StrWeekoff_Date output,@Weekoff_Days output ,@Cancel_Weekoff output    


	---Commented If Condition by Hardik 07/09/2012
	
	--if isnull(@tras_week_ot,0)=1
	--	Begin	
	--		-- Alpesh 17-Aug-2011 For Including Holiday with WeekOff into OT Calculation
	--		declare @H_From_Date datetime
	--		declare @H_To_Date datetime
			
	--		declare cur1 cursor Fast_forward for 
	--		select h_from_date,h_to_date  from t0040_holiday_master 
	--		where cmp_Id = @Cmp_ID
	--		and ( (convert(varchar(10),@From_Date,120)>=convert(varchar(10),h_from_date,120) and convert(varchar(10),@From_Date,120)<=convert(varchar(10),h_to_date,120))
	--		or (convert(varchar(10),@To_Date,120)>=convert(varchar(10),h_from_date,120) and convert(varchar(10),@To_Date,120)<=convert(varchar(10),h_to_date,120))
	--		or (convert(varchar(10),h_from_date,120)>=convert(varchar(10),@From_Date,120) and convert(varchar(10),h_from_date,120)<=convert(varchar(10),@To_Date,120))
	--		or (convert(varchar(10),h_to_date,120)>=convert(varchar(10),@From_Date,120) and convert(varchar(10),h_to_date,120)<=convert(varchar(10),@To_Date,120)) )
	--		order by H_from_date

	--		open cur1
	--		fetch next from cur1 into @H_From_Date,@H_To_Date

	--		while @@fetch_status = 0
	--		begin
	--			if @H_From_Date = @H_To_Date
	--				set @StrWeekoff_Date= @StrWeekoff_Date+';'+convert(varchar(11),@H_From_Date,100)
	--			else 
	--				begin
	--					while @H_From_Date <= @H_To_Date
	--					begin
	--						set @StrWeekoff_Date= @StrWeekoff_Date+';'+ convert(varchar(11),@H_From_Date,100)
	--						set @H_From_Date = dateadd(d,1,@H_From_Date)
							
	--					end
	--				end
	--		fetch next from cur1 into @H_From_Date,@H_To_Date
	--		end
	--		close cur1
	--		deallocate cur1
	--	End
			------------------------------End-------------------------------
			
	Update 	@Emp_WeekOFf_Detail 
	Set StrWeekoff_Holiday=@StrWeekoff_Date + ';' + @StrHoliday_Date , --Hardik 07/09/2012
		StrHoliday = @StrHoliday_Date,StrWeekoff = @StrWeekoff_Date  --Hardik 07/09/2012
	where Emp_ID=@Emp_Week_Detail --Hardik 07/09/2012
	

	if @Return_Record_set = 5
		Begin 
			Insert into #Data_Weekoff values(@Emp_Week_Detail,@Weekoff_Days)
			
		End
	fetch next from curEmp_weekoff_Detail into @Emp_Week_Detail
   end                    
 close curEmp_weekoff_Detail                    
 deallocate curEmp_weekoff_Detail   
 
Declare @Cur_Holiday_Emp_ID as numeric(18,0)
Declare @Cur_Holiday_For_Date as datetime
Declare @Cur_Holiday_is_Half_day as tinyint
Declare @var_Holiday_Date as varchar(max)
set @var_Holiday_Date = ''
declare curHalfHolidayDate cursor for
	select Emp_Id,For_Date,is_Half_day from #Emp_Holiday
	Open curHalfHolidayDate
		fetch next from curHalfHolidayDate into @Cur_Holiday_Emp_ID,@Cur_Holiday_For_Date,@Cur_Holiday_is_Half_day
		while @@FETCH_STATUS = 0
		begin
		if @Cur_Holiday_is_Half_day = 1 
		begin
					
				select @var_Holiday_Date= strHalfday_Holiday from @Emp_WeekOFf_Detail where Emp_ID = @Cur_Holiday_Emp_ID
				if @var_Holiday_Date = '' 
				begin
					Update 	@Emp_WeekOFf_Detail set strHalfday_Holiday =  cast(@Cur_Holiday_For_Date as varchar(25))
							where Emp_ID = @Cur_Holiday_Emp_ID
				end 
				else
				begin
						Update 	@Emp_WeekOFf_Detail set strHalfday_Holiday = strHalfday_Holiday + ';' + cast(@Cur_Holiday_For_Date as varchar(25))
							where Emp_ID = @Cur_Holiday_Emp_ID
				end
		end 
		fetch next from curHalfHolidayDate into @Cur_Holiday_Emp_ID,@Cur_Holiday_For_Date,@Cur_Holiday_is_Half_day
		end
		Close curHalfHolidayDate
		Deallocate curHalfHolidayDate 
		 
 	declare @Emp_Id_Temp1   numeric          
	declare @For_date1 datetime   
	declare @Duration_in_sec1 numeric          
    declare @Emp_OT1  numeric         
    declare @OT_Sec1  numeric 
    
  ---Hardik 07/09/2012 for Weekoff1 Cursor
   declare curweekoff1 cursor Fast_forward for                    
		select Emp_Id from #Data Group by Emp_Id
 open curweekoff1                      
  fetch next from curweekoff1 into @Emp_Id_Temp1
  while @@fetch_status = 0                    
   begin       

			--Hardik 07/09/2012 for Weekoff 
			Declare @Weekoff_Date1 as varchar(max)
			Set @Weekoff_Date1 =''
			Declare @Half_Holiday_Date as varchar(max)
			set @Half_Holiday_Date = ''
			
			Select @Weekoff_Date1 = StrWeekoff_Holiday, @Half_Holiday_Date = strHalfday_Holiday from @Emp_WeekOFf_Detail where Emp_ID = @Emp_Id_Temp1

		   declare curweekoff cursor Fast_forward for                    
				select Duration_in_sec,For_date,Emp_OT,OT_Sec from #Data 
				Where For_date In (Select Data from dbo.Split(@Weekoff_Date1,';') where Data <>'')
				And Emp_Id = @Emp_Id_Temp1  --Hardik 07/09/2012 Where condition
				order by For_date
		 open curweekoff                      
		  fetch next from curweekoff into @Duration_in_sec1,@For_date1,@Emp_OT1,@OT_Sec1
		  while @@fetch_status = 0                    
		   begin       
		   
		   declare @tras_week_ot1 as tinyint 
		   set @tras_week_ot1 = 0
		   
		   select @Week_oF_Branch=Branch_ID  from dbo.t0095_increment where Increment_id in (select Max(Increment_id) from dbo.t0095_increment where emp_id=@Emp_Id_Temp1)
			
		 
			Select @tras_week_ot1=isnull(tras_week_ot,0)
				From dbo.T0040_GENERAL_SETTING where cmp_ID = @cmp_ID and Branch_ID = @Week_oF_Branch    
				and For_Date = ( select max(For_Date) from dbo.T0040_GENERAL_SETTING where For_Date <=@To_Date and Branch_ID = @Week_oF_Branch and Cmp_ID = @Cmp_ID)    
			
		               
		   
			if isnull(@Emp_OT1,0)=1 and @tras_week_ot1 = 1
				Begin
					--Commented By Hardik 07/09/2012
					--Declare @Final_weekoff_str varchar(max)
					--set @Final_weekoff_str=''
					--select @Final_weekoff_str = isnull(Strweekoff,'') from @Emp_WeekOFf_Detail where emp_id=@Emp_Id_Temp1
				
					if charindex(cast(left(@For_date1,11) as varchar),@Weekoff_Date1) >0
						Begin
								
							Update #Data set Duration_in_sec =0,Ot_sec=dbo.F_Return_Without_Sec(@OT_Sec1+@Duration_in_sec1),P_days=0 where Emp_Id=@Emp_Id_Temp1
							And For_Date=@For_date1 and For_date not in (Select Data from dbo.Split(@Half_Holiday_Date,';') where Data <>'')
						
						End
				End
			fetch next from curweekoff into @Duration_in_sec1,@For_date1,@Emp_OT1,@OT_Sec1
		   end                    
		 close curweekoff                    
		 deallocate curweekoff   

	fetch next from curweekoff1 into @Emp_Id_Temp1
   end                    
 close curweekoff1                    
 deallocate curweekoff1   
 
 
 -- Ended by rohit on 12072013       
        
 Declare @Shift_ID  numeric       
 Declare @From_Hour  numeric(12,3)      
 Declare @To_Hour  numeric(12,3)      
 Declare @Minimum_hour numeric(12,3)      
 Declare @Calculate_days numeric(12,1)      
 Declare @OT_applicable numeric(1)      
 Declare @Fix_OT_Hours numeric(12,3)      
 Declare @Shift_Dur  varchar(10)      
 Declare @Shift_Dur_sec numeric       
 Declare @Fix_W_Hours  numeric(5,2)        
 Declare @Ot_Sec_Neg Numeric(18,0)--Nikunj
      
      
      
 Declare Cur_shift cursor for       
  select sd.Shift_ID ,From_Hour,To_Hour,Minimum_hour,Calculate_days,OT_applicable,Fix_OT_Hours       
    ,Shift_Dur,isnull(Fix_W_Hours,0) as  Fix_W_Hours       
  from T0050_shift_detail sd inner join       
    T0040_shift_master sm on sd.shift_ID= sm.Shift_ID inner join       
     (select distinct Shift_ID from #Data ) q on sm.shift_Id=  q.shift_ID      
  order by sd.shift_Id,From_Hour      
 open cur_shift      
 fetch next from cur_Shift into @shift_ID,@From_hour,@To_Hour,@Minimum_Hour,@Calculate_Days,@OT_Applicable,@Fix_OT_Hours,@Shift_Dur,@Fix_W_Hours       
 While @@Fetch_Status=0      
  begin      
  select @Shift_Dur_sec = dbo.F_Return_Sec(@Shift_Dur) 
		      
			 if @Fix_W_Hours > 0         
				begin         
					Update #Data        
					set P_Days = @Calculate_Days, Duration_in_sec = dbo.f_return_sec( replace(@Fix_W_Hours,'.',':'))    
					Where Duration_in_sec >=dbo.f_return_sec( replace(@From_hour,'.',':')) and Duration_in_sec <= dbo.f_return_sec( replace(@To_Hour,'.',':'))        
					and Shift_ID= @shift_ID         
				end        
			 else        
				begin
					Update #Data        
					set P_Days = @Calculate_Days        
					Where Duration_in_sec >= dbo.f_return_sec( replace(@From_hour,'.',':')) and Duration_in_sec <= dbo.f_return_sec( replace(@To_Hour,'.',':'))        
					and Shift_ID= @shift_ID         
				end        
		   
		   If @OT_Applicable =1         
			begin            
			   if @Fix_OT_Hours > 0         
				   begin        
						Update #Data        
						 set P_Days = @Calculate_Days,        
						  OT_Sec =  dbo.f_return_sec( replace(@Fix_OT_Hours,'.',':'))        
						   Where Duration_in_sec >=dbo.f_return_sec( replace(@From_hour,'.',':')) and Duration_in_sec <=dbo.f_return_sec( replace(@To_Hour,'.',':'))        
						  and Emp_OT= 1 and Shift_ID= @shift_ID         
				   end        
				 else if @Minimum_Hour > 0         
				   begin        
						Update #Data        
						 set P_Days = @Calculate_Days,        
						  OT_Sec = dbo.F_Return_Without_Sec(dbo.f_return_sec( replace(Duration_in_sec - @Minimum_Hour,'.',':')))
						 Where Duration_in_sec >=dbo.f_return_sec( replace(@From_hour,'.',':')) and Duration_in_sec <=dbo.f_return_sec( replace(@To_Hour,'.',':'))         
						  and Emp_OT= 1 and Shift_ID= @shift_ID         
				   end        
				 else if @Minimum_Hour = 0         
					Begin        
				
						Update #Data        
						set P_Days = @Calculate_Days,        
							OT_Sec = dbo.F_Return_Without_Sec(Duration_in_sec - @Shift_Dur_sec)  ,        
							Duration_in_sec= @Shift_Dur_sec        
							Where Duration_in_sec >=dbo.f_return_sec( replace(@From_hour,'.',':')) and Duration_in_sec <=dbo.f_return_sec( replace(@To_Hour,'.',':'))        
							and Emp_OT= 1 and Duration_in_sec > @Shift_Dur_sec        
							and Shift_ID= @shift_ID  
							
							Select @Ot_Sec_Neg=Isnull(Ot_Sec,0)From #Data Where OT_Sec < 1--Nikunj

						If	@Ot_Sec_Neg < 1 And Isnull(@Is_Negative_Ot,0)=1--And Duration_In_sec < @Shift_Dur_sec --logic Of Negative ot			
							Begin					
								Update #Data				
								Set OT_Sec = dbo.F_Return_Without_Sec(@Shift_Dur_sec - Duration_in_sec),Flag=1
								Where Ot_Sec < 1 And Duration_In_sec < @Shift_Dur_sec And Shift_Id = @Shift_Id And Emp_OT= 1										
							End    
			   
					 end              
			end       
   fetch next from cur_Shift into @shift_ID,@From_hour,@To_Hour,@Minimum_Hour,@Calculate_Days,@OT_Applicable,@Fix_OT_Hours,@Shift_Dur,@Fix_W_Hours       
  end      
 close cur_Shift      
 Deallocate Cur_Shift       
     
     
     
--------------------Added by Mitesh on 15/09/2011 for Shift Half Day ----------------------------
	
	declare @ShiftId numeric
	declare @WeekDay varchar(10)
	declare @HalfStartTime varchar(10)
	declare @HalfEndTime varchar(10)
	declare @HalfDuration varchar(10)
	declare @HalfDayDate varchar(500)
	declare @curForDate datetime
	declare @HalfMinDuration varchar(10)
	
	exec GET_HalfDay_Date @Cmp_ID,@Emp_ID,@From_Date,@To_Date,0,@HalfDayDate output
	
  
	
	select @ShiftId=SM.Shift_id,@WeekDay=SM.Week_Day,@HalfStartTime=SM.Half_St_Time,@HalfEndTime=SM.Half_End_Time,@HalfDuration=SM.Half_Dur,@HalfMinDuration=SM.Half_min_duration from T0040_SHIFT_MASTER SM inner join         
			   (select distinct Shift_ID from #Data ) q on SM.Shift_ID =  q.shift_ID        
			where Is_Half_Day = 1 
	
	declare cur_shift_half_day Cursor for
			select For_date from #Data
	OPEN cur_shift_half_day        
	fetch next from cur_shift_half_day into @curForDate
	  While @@Fetch_Status=0        
		   BEGIN
				
				if(charindex(CONVERT(nvarchar(11),@curForDate,109),@HalfDayDate) > 0)
					begin						
						update #Data  set
							Shift_Start_Time = @HalfStartTime							
							where For_date = @curForDate
						
													
						update #Data  set
							P_days = 1
							where For_date = @curForDate and Duration_in_sec >= dbo.F_Return_Sec(@HalfMinDuration)
							
						update #Data  set
							P_days = 0
							where For_date = @curForDate and Duration_in_sec < dbo.F_Return_Sec(@HalfMinDuration)
							
						Update #Data        
						 set OT_Sec = 
						 case when dbo.F_Return_Sec(@HalfMinDuration) > Duration_in_sec then
							dbo.F_Return_Sec(@HalfMinDuration) - Duration_in_sec         
						 Else
							Duration_in_sec - dbo.F_Return_Sec(@HalfMinDuration)  
						 End 
						 Where Duration_in_sec >=dbo.F_Return_Sec(@HalfMinDuration)
						 and Emp_OT= 1 and For_date = @curForDate    
							
					end
		   fetch next from cur_shift_half_day into @curForDate
		   END
	close cur_shift_half_day        
	Deallocate cur_shift_half_day  	   
		   
	---- start below update statment added by mitesh for regularization as only full day on 09/01/2012.
	
	update #Data 
	set P_days = 1 from #Data d inner join  T0150_EMP_INOUT_RECORD TEIR 
	on TEIR.Emp_Id = d.Emp_Id and TEIR.Chk_By_Superior = 1 and TEIR.For_Date = d.For_date and TEIR.Half_Full_day = 'Full Day' 
	where TEIR.For_Date >= @From_Date and TEIR.For_Date <= @To_Date
	
	
	update #Data 
	set P_days = 0.5 from #Data d inner join  T0150_EMP_INOUT_RECORD TEIR 
	on TEIR.Emp_Id = d.Emp_Id and TEIR.Chk_By_Superior = 1 and TEIR.For_Date = d.For_date and ( TEIR.Half_Full_day = 'First Half' or TEIR.Half_Full_day = 'Second Half')
	where TEIR.For_Date >= @From_Date and TEIR.For_Date <= @To_Date
	
	update dbo.#Data 
	set P_days = (P_days - 0.5) from #Data d inner join  
				(select For_Date,Emp_ID from dbo.T0140_LEAVE_TRANSACTION 
					where leave_used = 0.5 and 
					For_Date >= @From_Date and 
					For_Date <= @To_Date and (isnull(eff_in_salary,0) <> 1 
					or (isnull(eff_in_salary,0) = 1 and Leave_Used > 0)
					)) Qry on 
				Qry.For_Date = d.For_date and Qry.Emp_ID = d.Emp_Id where    P_days =1
	
	---- end below update statment added by mitesh for regularization as only full day on 09/01/2012.
	
     --Alpesh 06-Jul-2012 -> If Leave is paid then count as Leave, Not as Present 			 
	update dbo.#Data 
	set P_days = 0 from #Data d inner join  
		(select For_Date,Emp_ID from dbo.T0140_LEAVE_TRANSACTION lt inner join T0040_LEAVE_MASTER lm on lm.Leave_ID=lt.Leave_ID
		 where leave_used = 1 and For_Date >= @From_Date and For_Date <= @To_Date and lm.Leave_Paid_Unpaid='P') Qry 
		 on Qry.For_Date = d.For_date and Qry.Emp_ID = d.Emp_Id 
	---- End ----   
--------------------Added by Mitesh on 15/09/2011 for Shift Half Day ----------------------------
    
   --''Ankit 07072014--''
  	
  	update #Data
	set P_days = P_days - lt.leave_used
	from #Data d
	left outer join (select emp_id,for_date,sum(case when lm.Apply_hourly = 0 then lt.leave_used else lt.leave_used*0.125 end) as Leave_Used
	from T0140_LEAVE_TRANSACTION lt inner join 
		T0040_LEAVE_MASTER lm on lt.Leave_ID = lm.Leave_ID 
		where For_Date between @From_Date and @To_Date group by Emp_ID,For_Date) as lt on
		d.emp_id = lt.emp_ID and d.for_date = lt.for_date
	Where d.P_days + lt.leave_used > 1
	
	
--''Ankit 07072014--''	 
     
 update #Data       
 set OT_Sec = isnull(Approved_OT_Sec,0)  --* 3600      
	, Weekoff_OT_Sec = isnull(OA.Approved_WO_OT_Sec,0)
	, Holiday_OT_Sec = ISNULL(OA.Approved_HO_OT_Sec,0)
	, Weekoff_OT_Hour = ISNULL(oa.Approved_WO_OT_Hours,0)
	, Holiday_OT_Hour = ISNULL(OA.Approved_HO_OT_Hours,0)
 from #Data  d inner join T0160_OT_Approval OA on d.emp_ID = Oa.Emp_ID and d.For_Date = oa.For_Date  and Is_Month_Wise = 0     
       
       
       
 Update #Data      
 set OT_Sec = 0       
 where Emp_OT_Min_Limit >= OT_sec and OT_sec >0      

      
       
 Update #Data      
 set OT_Sec = Emp_OT_Max_Limit      
 where OT_sec  > Emp_OT_Max_Limit  and Emp_OT_Max_Limit > 0 and OT_sec >0      

-- Added by rohit on 12072013
 Declare @Is_Cancel_Weekoff_OT  Numeric(1,0)    
 Declare @Join_Date    Datetime    
 Declare @Left_Date    Datetime     
 --Declare @StrHoliday_Date  varchar(max)    
 Declare @StrWeekoff_Date_OT  varchar(max)    
 --Declare @Holiday_Days   Numeric(12,1)
 Declare @Weekoff_Days_OT   Numeric(12,1)
 --Declare @Cancel_Holiday   Numeric(12,1)
 Declare @Cancel_Weekoff_OT   Numeric(12,1)
 Declare @Emp_Id_Cur Numeric
 Declare @For_Date Datetime
 Declare @WeekOff_Work_Sec Numeric
 Declare @Holiday_Work_Sec Numeric
 Declare @Trans_Weekoff_OT tinyint --Hardik 14/02/2013 
 
 Set @Is_Cancel_Weekoff_OT = 0
 Set @Is_Cancel_Holiday = 0    
 Set @StrHoliday_Date = ''    
 Set @StrWeekoff_Date_OT = '' 
 Set @Holiday_Days  = 0    
 Set @Weekoff_Days_OT  = 0    
 Set @Cancel_Holiday  = 0    
 Set @Cancel_Weekoff_OT  = 0  
 Set @Trans_Weekoff_OT = 0

	Select @Is_Cancel_Holiday = Is_Cancel_Holiday,@Is_Cancel_Weekoff_OT = Is_Cancel_Weekoff
	From dbo.T0040_GENERAL_SETTING 
	Where cmp_ID = @cmp_ID and Branch_ID = @Branch_ID    
	and For_Date = (select max(For_Date) from dbo.T0040_GENERAL_SETTING where For_Date <=@To_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)    
	
	
		
	Declare Cur_HO cursor Fast_forward for
		Select Emp_Id,For_Date from #Data --Where OT_Sec > 0
	open Cur_HO
	fetch next from Cur_HO into @Emp_Id_Cur,@For_Date
	While @@Fetch_Status=0
	   begin
	   
	  
		Select @Branch_ID = I.Branch_ID  from dbo.T0095_Increment I inner join         
		( select max(Increment_ID) as Increment_ID , Emp_ID From dbo.T0095_Increment        -- Ankit 06092014 for Same Date Increment
		where Increment_Effective_date <= @To_Date        
		and Cmp_ID = @Cmp_ID And Emp_ID = @Emp_Id_Cur
		group by emp_ID  ) Qry on        
		I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID 
		Where I.Emp_ID = @Emp_Id_Cur
			
			--Commented by Hardik 07/09/2012					
			--Exec SP_EMP_HOLIDAY_DATE_GET @Emp_ID_Cur,@Cmp_ID,@From_Date,@To_Date,@Join_Date,@left_Date,@Is_Cancel_Holiday,@StrHoliday_Date output,@Holiday_days output,@Cancel_Holiday output,0,@Branch_ID,@StrWeekoff_Date_OT
			--Exec SP_EMP_WEEKOFF_DATE_GET @Emp_ID_Cur,@Cmp_ID,@From_Date,@To_Date,@Join_Date,@left_Date,@Is_Cancel_Weekoff_OT,@StrHoliday_Date,@StrWeekoff_Date_OT output,@Weekoff_Days_OT output ,@Cancel_Weekoff_OT output   

			Set @StrWeekoff_Date_OT = ''
			Set @StrHoliday_Date = ''
			
			Select @StrWeekoff_Date_OT = StrWeekoff, @StrHoliday_Date = StrHoliday
			from @Emp_WeekOFf_Detail Where Emp_ID = @Emp_Id_Cur 			
			
			if charindex(cast(@For_Date as varchar(11)),@StrWeekoff_Date_OT,0) > 0
				begin
					--Update #Data Set Duration_in_sec = 0, OT_Sec = 0, Weekoff_OT_Sec = Duration_in_sec +  OT_Sec Where For_date = @For_Date And Emp_Id = @Emp_Id_Cur
					Update #Data Set  OT_Sec = 0, Weekoff_OT_Sec = OT_Sec Where For_date = @For_Date And Emp_Id = @Emp_Id_Cur
				end 
			else if charindex(cast(@For_Date as varchar(11)),@StrHoliday_Date,0) > 0
				begin
					
				    --Update #Data Set Duration_in_sec = 0, OT_Sec = 0, Holiday_OT_Sec = Duration_in_sec + OT_Sec Where For_date = @For_Date And Emp_Id = @Emp_Id_Cur					
				 -- Changed By Gadriwala Muslim 27082014 - Start   
				   -- Update #Data Set OT_Sec = 0, Holiday_OT_Sec = OT_Sec Where For_date = @For_Date And Emp_Id = @Emp_Id_Cur	
				    
				 --   Update #Data Set OT_Sec = 0, Holiday_OT_Sec = OT_Sec from #Data as data_t inner join
 				--	#Emp_Holiday EH on EH.Emp_ID = Data_t.Emp_ID and EH.For_Date = Data_t.For_date 			
					--Where data_t.For_date = @For_Date And Data_t.Emp_Id = @Emp_Id_Cur and is_Half_Day = 0
					
					--Update #Data Set OT_Sec = 0, Holiday_OT_Sec = 0, P_days = isnull(H_day,0) from #Data as data_t inner join
 				--	#Emp_Holiday EH on EH.Emp_ID = Data_t.Emp_ID and EH.For_Date = Data_t.For_date 			
					--Where data_t.For_date = @For_Date And Data_t.Emp_Id = @Emp_Id_Cur and is_Half_Day = 1			
					
					Declare @Trans_Week_OT as tinyint   
						set @Trans_Week_OT = 0
					    Select @Trans_Week_OT = isnull(Tras_Week_OT,0)
						From dbo.T0040_GENERAL_SETTING 
						Where cmp_ID = @cmp_ID and Branch_ID = @Branch_ID    
						and For_Date = (select max(For_Date) from dbo.T0040_GENERAL_SETTING where For_Date <=@To_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)    
					
					declare @shift_Work_time_Sec as numeric(18,2)
					set @shift_Work_time_Sec = 0
		    
					
					if @tras_week_ot = 1 
					begin
					
						    Update #Data Set OT_Sec = 0, Holiday_OT_Sec = OT_Sec from #Data as data_t inner join
 							#Emp_Holiday EH on EH.Emp_ID = Data_t.Emp_ID and EH.For_Date = Data_t.For_date 			
							Where data_t.For_date = @For_Date And Data_t.Emp_Id = @Emp_Id_Cur and is_Half_Day = 0
							
							select  @shift_Work_time_Sec = dbo.F_Return_Sec(sm.Shift_Dur)/2 
							 from T0050_shift_detail sd inner join       
								T0040_shift_master sm on sd.shift_ID= sm.Shift_ID inner join       
							(select distinct Shift_ID from #Data ) q on sm.shift_Id=  q.shift_ID      
							order by sd.shift_Id,From_Hour
						
						   select @shift_Work_time_Sec = Duration_in_sec - isnull(@shift_Work_time_Sec,0) from #Data 
							Where For_date = @For_Date And Emp_Id = @Emp_Id_Cur and isnull(Emp_OT,0) = 1
							
							Update #Data Set OT_Sec = 0, Holiday_OT_Sec = @shift_Work_time_Sec , P_days = P_days - 0.5 from #Data as data_t
							 inner join #Emp_Holiday EH on EH.Emp_ID = Data_t.Emp_ID and EH.For_Date = Data_t.For_date 			
							Where data_t.For_date = @For_Date And Data_t.Emp_Id = @Emp_Id_Cur and is_Half_Day = 1 and P_days = 1	
					
					end
					
					
				 
				 -- Changed By Gadriwala Muslim 27082014 - End
				end

		 fetch next from Cur_HO into @Emp_Id_Cur,@For_Date
	  end        
	close Cur_HO        
	Deallocate Cur_HO   

------------ End By Hardik for OT

 ---Hardik 07/09/2012 for Weekoff1 Cursor
	declare curweekoff1 cursor Fast_forward for                    
		select Emp_Id from #Data Group by Emp_Id
	open curweekoff1                      
	fetch next from curweekoff1 into @Emp_Id_Temp1
	while @@fetch_status = 0                    
	begin  
			Select @Week_oF_Branch= Branch_ID  from dbo.t0095_increment where Increment_id in (select Max(Increment_id) from dbo.t0095_increment where emp_id=@Emp_Id_Temp1)
			
			Select @Is_Compoff = ISNULL(Is_CompOff,0),@Trans_Weekoff_OT = Isnull(Tras_Week_OT,0)
			From dbo.T0040_GENERAL_SETTING where cmp_ID = @cmp_ID and Branch_ID = @Week_oF_Branch    
			and For_Date = ( select max(For_Date) from dbo.T0040_GENERAL_SETTING where For_Date <=@To_Date and Branch_ID = @Week_oF_Branch and Cmp_ID = @Cmp_ID)

			 If(@Is_Compoff = 1) or @Trans_Weekoff_OT = 1 -- Added by Mihir Trivedi on 31/05/2012 for present days updation related to comp-off
				BEGIN
					Declare @strwoff as Varchar(Max)
					Declare @A_strwoff as varchar(20)
					Declare @D_EmpID as Numeric
					Declare @F_Date as Varchar(11)
					--Declare @Weekoff_EmpID as numeric
					Select @strwoff = Replace(ISNULL(Strweekoff,''),';',',') from
					@Emp_WeekOFf_Detail Where Emp_ID = @Emp_Id_Temp1
				
					--Declare curapp cursor Fast_forward for
					--	select Data from dbo.Split(@strwoff, ',') where Data <> ''
					--Open curapp
					--	Fetch Next from curapp into @A_strwoff
					--WHILE @@FETCH_STATUS = 0
					--	BEGIN					
							Declare curfinal cursor Fast_forward for
								Select Emp_ID, For_date from #Data
								Where For_Date In (Select Data from dbo.Split(@strwoff, ',') where Data <> '')
								And Emp_Id = @Emp_Id_Temp1
							Open curfinal 
								Fetch Next from curfinal into @D_EmpID, @F_Date
							WHILE @@FETCH_STATUS = 0
								BEGIN						

									--IF(@F_Date = @A_strwoff and @D_EmpID = @Emp_Id_Temp1)
									if charindex(cast(@F_Date as varchar(11)),@StrWeekoff_Date_OT,0) > 0 --Change By hardik 07/09/2012
										BEGIN
											Update #Data 
											Set P_days = 0.0
											Where For_date = @F_Date And Emp_Id = @Emp_Id_Temp1
											--Where CAST(For_date as varchar(11)) = @A_strwoff and Emp_Id = @Emp_Id_Temp1 --Commented by Hardik 07/09/2012
										END
									Fetch Next from curfinal into @D_EmpID, @F_Date
								END
							Close curfinal
							Deallocate curfinal
							--Fetch next from curapp into @A_strwoff 
					--	END
					--Close curapp
					--Deallocate curapp
				END
			fetch next from curweekoff1 into @Emp_Id_Temp1
		end                    
 close curweekoff1                    
 deallocate curweekoff1   	   
 
 -- Ended by rohit on 12072013
      */
      
 
 --select * from #Data
 if @Return_Record_set = 1 
	BEGIN
	SELECT	OA.Emp_ID,For_Date,Duration_in_Sec,OA.Shift_ID,Shift_Type,Emp_OT,Emp_OT_min_Limit,
			P_days,OT_Sec,Emp_Full_Name,Emp_Code,Shift_Name,Cmp_Name,Cmp_Address,Branch_Address,
			Dept_Name,Comp_Name,Desig_Name,[Type_Name],Grd_Name,Branch_Name,Date_of_Join,Gender,0 As Working_Hour,
			0 As OT_Hour,Basic_Salary,Weekoff_OT_Sec,Holiday_OT_Sec,Holiday_OT_Sec,Weekoff_OT_Hour,Holiday_OT_Hour
	FROM	#Data   OA      
			inner join T0080_emp_master E WITH (NOLOCK) on OA.Emp_ID = E.Emp_ID   inner join    
			T0040_shift_master SM WITH (NOLOCK) On OA.Shift_ID=SM.Shift_ID inner join
			T0010_company_master CM WITH (NOLOCK) On E.CMP_ID =CM.CMP_ID inner join  
			 ( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID from T0095_Increment I WITH (NOLOCK) inner join     
				 ( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)   -- Ankit 06092014 for Same Date Increment
				 where Increment_Effective_date <= @To_Date    
				 and Cmp_ID = @Cmp_ID    
				 group by emp_ID  ) Qry on    
				 I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID  ) I_Q     
				on E.Emp_ID = I_Q.Emp_ID  inner join    
				 T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN    
				 T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN    
				 T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN    
				 T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN            
				 T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID         
	Where	OT_Sec > 0  or Weekoff_OT_Sec > 0 or Holiday_OT_Sec > 0       
    order by For_Date 
 END
  if @Return_Record_set =2       
	BEGIN   
			--Added By Jaina 12-09-2016
		    If @Report_Type = 1 --Pending
			begin
		
     				select OA.Emp_Id,OA.For_date,OA.Duration_in_sec,OA.Shift_ID,OA.Shift_Type,OA.Emp_OT,OA.Emp_OT_min_Limit,OA.Emp_OT_max_Limit,OA.P_days,
				 case when @max_OTDaily = 0 then OA.OT_Sec when dbo.F_Return_Sec(replace(@max_OTDaily,'.',':')) < OA.OT_Sec then dbo.F_Return_Sec(replace(@max_OTDaily,'.',':')) else oa.OT_Sec end as OT_Sec   ,
				   E.Emp_Full_Name as Emp_Full_Name,E.Alpha_Emp_Code,SM.Shift_Name,CM.Cmp_Name,CM.Cmp_Address,Branch_Address,Dept_Name,Comp_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Gender
				  ,Replace(dbo.F_Return_Hours(Duration_in_Sec),':','.') as Working_Hour ,
				 case when @max_OTDaily = 0 then replace(dbo.F_Return_Hours(OA.OT_Sec),':','.') when dbo.F_Return_Sec(replace(@max_OTDaily,'.',':')) < OA.OT_Sec then replace(@max_OTDaily,':','.') else replace(dbo.F_Return_Hours(OA.OT_Sec),':','.') end as OT_Hour,
				  E.Basic_Salary , OA.Weekoff_OT_Sec,
				  OA.Holiday_OT_Sec,oa.Weekoff_OT_Hour,oa.Holiday_OT_Hour
				  ,DGM.Desig_Dis_No
				  --, OTA.Comments      --added jimit 24082015	--Comments Added By Ramiz on 04/09/2015
				   , case when isnull(OTA.Comments,'')<>'' then OTA.Comments else case when oa.Weekoff_OT_Sec>0 then 'Week Off' when Oa.Holiday_OT_Sec>0 then 'Holiday' else '' end end as Comments      --added jimit 24082015	--Comments Added By Ramiz on 04/09/2015
				  ,case when OTA.Is_Approved = 1 then 'Approved' else  case when OTA.Is_Approved = 0 then 'Rejected' else 'Pending' end end as OT_Status,
				  OTA.Remark
				  INTO #Data_T
				  from #Data   OA      
					 inner join			T0080_emp_master E WITH (NOLOCK) on OA.Emp_ID = E.Emp_ID   
					 inner join			T0040_shift_master SM WITH (NOLOCK) On OA.Shift_ID=SM.Shift_ID AND E.Cmp_ID=SM.Cmp_ID 
					 inner join			T0010_company_master CM WITH (NOLOCK) On E.CMP_ID =CM.CMP_ID 
					 inner join			( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID from T0095_Increment I WITH (NOLOCK)
					 inner join			( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment  WITH (NOLOCK)  -- Ankit 06092014 for Same Date Increment
										where Increment_Effective_date <= @To_Date  and Cmp_ID = @Cmp_ID group by emp_ID  ) Qry on    
										I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID  ) I_Q on E.Emp_ID = I_Q.Emp_ID  
					inner join			T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID 
					LEFT OUTER JOIN		T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID 
					LEFT OUTER JOIN		T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id 
					LEFT OUTER JOIN		T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id 
					INNER JOIN			T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID 
					Left OUTER JOIN	T0160_OT_APPROVAL OTA WITH (NOLOCK) on E.Emp_ID = OTA.Emp_ID and OTA.For_Date = OA.For_date		--Added By Ramiz
					
					Where				(OA.OT_Sec > 0  or OA.Weekoff_OT_Sec > 0 or OA.Holiday_OT_Sec > 0)       
										and Is_Approved  is null    
					 order by For_Date 

				END
		ELSE IF @REPORT_TYPE = 2 -- APPROVED
			BEGIN
				print 12324
				select OA.Emp_Id,OA.For_date,OA.Duration_in_sec,OA.Shift_ID,OA.Shift_Type,OA.Emp_OT,OA.Emp_OT_min_Limit,OA.Emp_OT_max_Limit,OA.P_days,
				 case when @max_OTDaily = 0 then OA.OT_Sec when dbo.F_Return_Sec(replace(@max_OTDaily,'.',':')) < OA.OT_Sec then dbo.F_Return_Sec(replace(@max_OTDaily,'.',':')) else oa.OT_Sec end as OT_Sec   ,
				   E.Emp_Full_Name as Emp_Full_Name,E.Alpha_Emp_Code,SM.Shift_Name,CM.Cmp_Name,CM.Cmp_Address,Branch_Address,Dept_Name,Comp_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Gender
				  ,Replace(dbo.F_Return_Hours(Duration_in_Sec),':','.') as Working_Hour ,
				 case when @max_OTDaily = 0 then replace(dbo.F_Return_Hours(OA.OT_Sec),':','.') when dbo.F_Return_Sec(replace(@max_OTDaily,'.',':')) < OA.OT_Sec then replace(@max_OTDaily,':','.') else replace(dbo.F_Return_Hours(OA.OT_Sec),':','.') end as OT_Hour,
				  E.Basic_Salary , OA.Weekoff_OT_Sec,
				  OA.Holiday_OT_Sec,oa.Weekoff_OT_Hour,oa.Holiday_OT_Hour
				  ,DGM.Desig_Dis_No
				  --, OTA.Comments      --added jimit 24082015	--Comments Added By Ramiz on 04/09/2015
				   , case when isnull(OTA.Comments,'')<>'' then OTA.Comments else case when oa.Weekoff_OT_Sec>0 then 'Week Off' when Oa.Holiday_OT_Sec>0 then 'Holiday' else '' end end as Comments      --added jimit 24082015	--Comments Added By Ramiz on 04/09/2015
				  ,case when OTA.Is_Approved = 1 then 'Approved' else  case when OTA.Is_Approved = 0 then 'Rejected' else 'Pending' end end as OT_Status,
				  OTA.Remark
				  INTO #Data_T1
				  from #Data   OA      
					 inner join			T0080_emp_master E WITH (NOLOCK) on OA.Emp_ID = E.Emp_ID   
					 inner join			T0040_shift_master SM WITH (NOLOCK) On OA.Shift_ID=SM.Shift_ID AND E.Cmp_ID=SM.Cmp_ID 
					 inner join			T0010_company_master CM WITH (NOLOCK) On E.CMP_ID =CM.CMP_ID 
					 inner join			( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID from T0095_Increment I WITH (NOLOCK)
					 inner join			( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment  WITH (NOLOCK)  -- Ankit 06092014 for Same Date Increment
										where Increment_Effective_date <= @To_Date  and Cmp_ID = @Cmp_ID group by emp_ID  ) Qry on    
										I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID  ) I_Q on E.Emp_ID = I_Q.Emp_ID  
					inner join			T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID 
					LEFT OUTER JOIN		T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID 
					LEFT OUTER JOIN		T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id 
					LEFT OUTER JOIN		T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id 
					INNER JOIN			T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID 
					Left OUTER JOIN	T0160_OT_APPROVAL OTA WITH (NOLOCK) on E.Emp_ID = OTA.Emp_ID and OTA.For_Date = OA.For_date		--Added By Ramiz
					
					Where				(OA.OT_Sec > 0  or OA.Weekoff_OT_Sec > 0 or OA.Holiday_OT_Sec > 0)       
										and ota.Is_Approved = 1    
					 order by For_Date 
					
			
			END
			
			ELSE IF @REPORT_TYPE = 3 -- REJECTED
			BEGIN
				select OA.Emp_Id,OA.For_date,OA.Duration_in_sec,OA.Shift_ID,OA.Shift_Type,OA.Emp_OT,OA.Emp_OT_min_Limit,OA.Emp_OT_max_Limit,OA.P_days,
				 case when @max_OTDaily = 0 then OA.OT_Sec when dbo.F_Return_Sec(replace(@max_OTDaily,'.',':')) < OA.OT_Sec then dbo.F_Return_Sec(replace(@max_OTDaily,'.',':')) else oa.OT_Sec end as OT_Sec   ,
				   E.Emp_Full_Name as Emp_Full_Name,E.Alpha_Emp_Code,SM.Shift_Name,CM.Cmp_Name,CM.Cmp_Address,Branch_Address,Dept_Name,Comp_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Gender
				  ,Replace(dbo.F_Return_Hours(Duration_in_Sec),':','.') as Working_Hour ,
				 case when @max_OTDaily = 0 then replace(dbo.F_Return_Hours(OA.OT_Sec),':','.') when dbo.F_Return_Sec(replace(@max_OTDaily,'.',':')) < OA.OT_Sec then replace(@max_OTDaily,':','.') else replace(dbo.F_Return_Hours(OA.OT_Sec),':','.') end as OT_Hour,
				  E.Basic_Salary , OA.Weekoff_OT_Sec,
				  OA.Holiday_OT_Sec,oa.Weekoff_OT_Hour,oa.Holiday_OT_Hour
				  ,DGM.Desig_Dis_No
				  --, OTA.Comments      --added jimit 24082015	--Comments Added By Ramiz on 04/09/2015
				   , case when isnull(OTA.Comments,'')<>'' then OTA.Comments else case when oa.Weekoff_OT_Sec>0 then 'Week Off' when Oa.Holiday_OT_Sec>0 then 'Holiday' else '' end end as Comments      --added jimit 24082015	--Comments Added By Ramiz on 04/09/2015
				  ,case when OTA.Is_Approved = 1 then 'Approved' else  case when OTA.Is_Approved = 0 then 'Rejected' else 'Pending' end end as OT_Status,
				  OTA.Remark
				  INTO #Data_T2
				  from #Data   OA      
					 inner join			T0080_emp_master E WITH (NOLOCK) on OA.Emp_ID = E.Emp_ID   
					 inner join			T0040_shift_master SM WITH (NOLOCK) On OA.Shift_ID=SM.Shift_ID AND E.Cmp_ID=SM.Cmp_ID 
					 inner join			T0010_company_master CM WITH (NOLOCK) On E.CMP_ID =CM.CMP_ID 
					 inner join			( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID from T0095_Increment I WITH (NOLOCK)
					 inner join			( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment  WITH (NOLOCK)  -- Ankit 06092014 for Same Date Increment
										where Increment_Effective_date <= @To_Date  and Cmp_ID = @Cmp_ID group by emp_ID  ) Qry on    
										I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID  ) I_Q on E.Emp_ID = I_Q.Emp_ID  
					inner join			T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID 
					LEFT OUTER JOIN		T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID 
					LEFT OUTER JOIN		T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id 
					LEFT OUTER JOIN		T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id 
					INNER JOIN			T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID 
					Left OUTER JOIN	T0160_OT_APPROVAL OTA WITH (NOLOCK) on E.Emp_ID = OTA.Emp_ID and OTA.For_Date = OA.For_date		--Added By Ramiz
					
					Where				(OA.OT_Sec > 0  or OA.Weekoff_OT_Sec > 0 or OA.Holiday_OT_Sec > 0)
										and Is_Approved = 0    
					 order by For_Date 
			END
			ELSE  --All
			BEGIN
				select OA.Emp_Id,OA.For_date,OA.Duration_in_sec,OA.Shift_ID,OA.Shift_Type,OA.Emp_OT,OA.Emp_OT_min_Limit,OA.Emp_OT_max_Limit,OA.P_days,
				 case when @max_OTDaily = 0 then OA.OT_Sec when dbo.F_Return_Sec(replace(@max_OTDaily,'.',':')) < OA.OT_Sec then dbo.F_Return_Sec(replace(@max_OTDaily,'.',':')) else oa.OT_Sec end as OT_Sec   ,
				   E.Emp_Full_Name as Emp_Full_Name,E.Alpha_Emp_Code,SM.Shift_Name,CM.Cmp_Name,CM.Cmp_Address,Branch_Address,Dept_Name,Comp_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Gender
				  ,Replace(dbo.F_Return_Hours(Duration_in_Sec),':','.') as Working_Hour ,
				 case when @max_OTDaily = 0 then replace(dbo.F_Return_Hours(OA.OT_Sec),':','.') when dbo.F_Return_Sec(replace(@max_OTDaily,'.',':')) < OA.OT_Sec then replace(@max_OTDaily,':','.') else replace(dbo.F_Return_Hours(OA.OT_Sec),':','.') end as OT_Hour,
				  E.Basic_Salary , OA.Weekoff_OT_Sec,
				  OA.Holiday_OT_Sec,oa.Weekoff_OT_Hour,oa.Holiday_OT_Hour
				  ,DGM.Desig_Dis_No
				  --, OTA.Comments      --added jimit 24082015	--Comments Added By Ramiz on 04/09/2015
				   , case when isnull(OTA.Comments,'')<>'' then OTA.Comments else case when oa.Weekoff_OT_Sec>0 then 'Week Off' when Oa.Holiday_OT_Sec>0 then 'Holiday' else '' end end as Comments      --added jimit 24082015	--Comments Added By Ramiz on 04/09/2015
				  ,case when OTA.Is_Approved = 1 then 'Approved' else  case when OTA.Is_Approved = 0 then 'Rejected' else 'Pending' end end as OT_Status,
				  OTA.Remark
				  INTO #Data_T3
				  from #Data   OA      
					 inner join			T0080_emp_master E WITH (NOLOCK) on OA.Emp_ID = E.Emp_ID   
					 inner join			T0040_shift_master SM WITH (NOLOCK) On OA.Shift_ID=SM.Shift_ID AND E.Cmp_ID=SM.Cmp_ID 
					 inner join			T0010_company_master CM WITH (NOLOCK) On E.CMP_ID =CM.CMP_ID 
					 inner join			( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID from T0095_Increment I WITH (NOLOCK)
					 inner join			( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment  WITH (NOLOCK)  -- Ankit 06092014 for Same Date Increment
										where Increment_Effective_date <= @To_Date  and Cmp_ID = @Cmp_ID group by emp_ID  ) Qry on    
										I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID  ) I_Q on E.Emp_ID = I_Q.Emp_ID  
					inner join			T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID 
					LEFT OUTER JOIN		T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID 
					LEFT OUTER JOIN		T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id 
					LEFT OUTER JOIN		T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id 
					INNER JOIN			T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID 
					Left OUTER JOIN	T0160_OT_APPROVAL OTA WITH (NOLOCK) on E.Emp_ID = OTA.Emp_ID and OTA.For_Date = OA.For_date		--Added By Ramiz
					
					Where				OA.OT_Sec > 0  or OA.Weekoff_OT_Sec > 0 or OA.Holiday_OT_Sec > 0       
										
					 order by For_Date 
			ENd
		
    -- 			if exists(select 1 from tempdb.sys.tables where name ='#MaxOtData')
				--	BEGIN 
				--		drop table #MaxOtData	
				--	END
				
				--if isnull(@max_OTMonthly,0) <> 0 or isnull(@max_OTDaily,0) <> 0
				--	BEGIN
				--		select sum(b.OT_Sec ) as Sum_ot,a.* into #MaxOtData
				--		from #Data_T a cross join #Data_T b
				--		where b.for_date <= a.for_date and a.Emp_Id =b.Emp_Id 
				--		group by a.Basic_Salary,a.Branch_Address ,a.Branch_Name ,a.Cmp_Address ,a.Cmp_Name ,a.Comp_Name ,a.Date_of_Join ,a.Date_of_Join ,
				--		a.Dept_Name ,a.Desig_Name ,a.Duration_in_sec ,a.Alpha_Emp_Code ,a.Emp_Full_Name ,a.Emp_Id ,a.Emp_OT ,a.Emp_OT_max_Limit ,a.Emp_OT_min_Limit ,
				--		a.For_date ,a.Gender ,a.Grd_Name ,a.Holiday_OT_Hour ,a.Holiday_OT_Sec ,a.OT_Hour ,a.OT_Sec ,a.P_days ,a.Shift_ID ,a.Shift_Name ,
				--		a.Shift_Type ,a.Type_Name ,a.Weekoff_OT_Hour ,a.Weekoff_OT_Sec ,a.Working_Hour , a.Desig_Dis_No , a.Comments	--Comments Added By Ramiz on 04/09/2015
				--	END
   
     	if exists(select 1 from tempdb.sys.tables where name ='#MaxOtData')
				begin 
					drop table #MaxOtData	
				end
		else if exists(select 1 from tempdb.sys.tables where name ='#MaxOtData1')
				begin 
					drop table #MaxOtData1	
				end
		else if exists(select 1 from tempdb.sys.tables where name ='#MaxOtData2')
				begin 
					drop table #MaxOtData2	
				end		
		else if exists(select 1 from tempdb.sys.tables where name ='#MaxOtData3')
				begin 
					drop table #MaxOtData3
				end		
				
				if isnull(@max_OTMonthly,0) <> 0 or isnull(@max_OTDaily,0) <> 0
				begin
						if @Report_Type = 1 -- Pending
							begin
								select sum(b.OT_Sec ) as Sum_ot,a.* into #MaxOtData
								from #Data_T a cross join #Data_T b
								where b.for_date <= a.for_date and a.Emp_Id =b.Emp_Id 
								group by a.Basic_Salary,a.Branch_Address ,a.Branch_Name ,a.Cmp_Address ,a.Cmp_Name ,a.Comp_Name ,a.Date_of_Join ,a.Date_of_Join ,
								a.Dept_Name ,a.Desig_Name ,a.Duration_in_sec ,a.Alpha_Emp_Code ,a.Emp_Full_Name ,a.Emp_Id ,a.Emp_OT ,a.Emp_OT_max_Limit ,a.Emp_OT_min_Limit ,
								a.For_date ,a.Gender ,a.Grd_Name ,a.Holiday_OT_Hour ,a.Holiday_OT_Sec ,a.OT_Hour ,a.OT_Sec ,a.P_days ,a.Shift_ID ,a.Shift_Name ,
								a.Shift_Type ,a.Type_Name ,a.Weekoff_OT_Hour ,a.Weekoff_OT_Sec ,a.Working_Hour , a.Desig_Dis_No , a.Comments,a.OT_Status	--Comments Added By Ramiz on 04/09/2015
							end
						else if  @Report_Type = 2 -- Approved
							begin
								select sum(b.OT_Sec ) as Sum_ot,a.* into #MaxOtData1
								from #Data_T1 a cross join #Data_T1 b
								where b.for_date <= a.for_date and a.Emp_Id =b.Emp_Id 
								group by a.Basic_Salary,a.Branch_Address ,a.Branch_Name ,a.Cmp_Address ,a.Cmp_Name ,a.Comp_Name ,a.Date_of_Join ,a.Date_of_Join ,
								a.Dept_Name ,a.Desig_Name ,a.Duration_in_sec ,a.Alpha_Emp_Code ,a.Emp_Full_Name ,a.Emp_Id ,a.Emp_OT ,a.Emp_OT_max_Limit ,a.Emp_OT_min_Limit ,
								a.For_date ,a.Gender ,a.Grd_Name ,a.Holiday_OT_Hour ,a.Holiday_OT_Sec ,a.OT_Hour ,a.OT_Sec ,a.P_days ,a.Shift_ID ,a.Shift_Name ,
								a.Shift_Type ,a.Type_Name ,a.Weekoff_OT_Hour ,a.Weekoff_OT_Sec ,a.Working_Hour , a.Desig_Dis_No , a.Comments,a.OT_Status	--Comments Added By Ramiz on 04/09/2015
							end
						else if  @Report_Type = 3 -- Rejected
							begin
								select sum(b.OT_Sec ) as Sum_ot,a.* into #MaxOtData2
								from #Data_T2 a cross join #Data_T2 b
								where b.for_date <= a.for_date and a.Emp_Id =b.Emp_Id 
								group by a.Basic_Salary,a.Branch_Address ,a.Branch_Name ,a.Cmp_Address ,a.Cmp_Name ,a.Comp_Name ,a.Date_of_Join ,a.Date_of_Join ,
								a.Dept_Name ,a.Desig_Name ,a.Duration_in_sec ,a.Alpha_Emp_Code ,a.Emp_Full_Name ,a.Emp_Id ,a.Emp_OT ,a.Emp_OT_max_Limit ,a.Emp_OT_min_Limit ,
								a.For_date ,a.Gender ,a.Grd_Name ,a.Holiday_OT_Hour ,a.Holiday_OT_Sec ,a.OT_Hour ,a.OT_Sec ,a.P_days ,a.Shift_ID ,a.Shift_Name ,
								a.Shift_Type ,a.Type_Name ,a.Weekoff_OT_Hour ,a.Weekoff_OT_Sec ,a.Working_Hour , a.Desig_Dis_No , a.Comments,a.OT_Status	--Comments Added By Ramiz on 04/09/2015
							end
						
						else  -- All
							begin
								select ((a.OT_Sec+a.Holiday_OT_Sec+a.Weekoff_OT_Sec)/3600)as ot_cnt,a.OT_Hour as ot_1,sum(b.OT_Sec ) as Sum_ot,a.* into #MaxOtData3
								from #Data_T3 a cross join #Data_T3 b
								where b.for_date <= a.for_date and a.Emp_Id =b.Emp_Id 
								group by a.Basic_Salary,a.Branch_Address ,a.Branch_Name ,a.Cmp_Address ,a.Cmp_Name ,a.Comp_Name ,a.Date_of_Join ,a.Date_of_Join ,
								a.Dept_Name ,a.Desig_Name ,a.Duration_in_sec ,a.Alpha_Emp_Code ,a.Emp_Full_Name ,a.Emp_Id ,a.Emp_OT ,a.Emp_OT_max_Limit ,a.Emp_OT_min_Limit ,
								a.For_date ,a.Gender ,a.Grd_Name ,a.Holiday_OT_Hour ,a.Holiday_OT_Sec ,a.OT_Hour ,a.OT_Sec ,a.P_days ,a.Shift_ID ,a.Shift_Name ,
								a.Shift_Type ,a.Type_Name ,a.Weekoff_OT_Hour ,a.Weekoff_OT_Sec ,a.Working_Hour , a.Desig_Dis_No , a.Comments,a.OT_Status
								,a.remark--Comments Added By Ramiz on 04/09/2015
							end
							
					end		
				--added by mansi start 
						if exists(select 1 from tempdb.sys.tables where name ='#TotalMaxOtData')
						begin 
							drop table #TotalMaxOtData	
						end
						else if exists(select 1 from tempdb.sys.tables where name ='#TotalMaxOtData1')
						begin 
							drop table #TotalMaxOtData1
						end
					   else if exists(select 1 from tempdb.sys.tables where name ='#TotalMaxOtData2')
						begin 
							drop table #TotalMaxOtData2	
						end		
					   else if exists(select 1 from tempdb.sys.tables where name ='#TotalMaxOtData3')
						begin 
							drop table #TotalMaxOtData3
						end	


						if isnull(@max_OTMonthly,0) <> 0
					begin
					 
						if @Report_Type = 1
							begin
								select sum(cast(OT_Hour as numeric(18,0)))as total_ot_cnt,Emp_Id into #TotalMaxOtData
								from #MaxOtData --where For_date >=@From_Date and For_date >=@To_Date
								group by Emp_Id

								--select * from #MaxOtData  --where  sum_ot_hr<@max_OTMonthly 
								--order by For_date
							end
						else if @Report_Type = 2
							begin
									select sum(cast(OT_Hour as numeric(18,0)))as total_ot_cnt,Emp_Id into #TotalMaxOtData1
								from #MaxOtData1 --where For_date >=@From_Date and For_date >=@To_Date
								group by Emp_Id

								--select * from #MaxOtData1  --where  sum_ot_hr<@max_OTMonthly 
								--order by For_date
							end
						else if @Report_Type = 3
							begin
								select sum(cast(OT_Hour as numeric(18,0)))as total_ot_cnt,Emp_Id into #TotalMaxOtData2
								from #MaxOtData2 --where For_date >=@From_Date and For_date >=@To_Date
								group by Emp_Id
								--where  sum_ot_hr<@max_OTMonthly  
								order by For_date 
								--select * from #MaxOtData2  --where  sum_ot_hr<@max_OTMonthly 
								--order by For_date	
							end
						else
							begin
							 	select sum(ot_cnt)as total_ot_cnt,Emp_Id into #TotalMaxOtData3
								from #MaxOtData3 --where For_date >=@From_Date and For_date >=@To_Date
								group by Emp_Id
								--where  sum_ot_hr<@max_OTMonthly  
								--order by For_date 
								--select * from #MaxOtData3  --where  sum_ot_hr<@max_OTMonthly 
								--order by For_date
							end
					end

					if isnull(@max_OTDaily,0) = 0   and isnull(@max_OTMonthly,0) = 0
					begin
						if @Report_Type = 1
							begin
								select * from #Data_T order by For_date 
							end
						else if @Report_Type = 2
							begin
								select * from #Data_T1 order by For_date
							end
						else if @Report_Type = 3
							begin
								select * from #Data_T2 order by For_date	
							end
						else
							begin
								select * from #Data_T3 order by For_date
							end
					end
				else if isnull(@max_OTDaily,0) <> 0   and isnull(@max_OTMonthly,0) = 0
					begin
					  --print 1111111111
						if @Report_Type = 1
							begin
								select * from #MaxOtData where  OT_Hour<@max_OTDaily  
								order by For_date 
							end
						else if @Report_Type = 2
							begin
								select * from #MaxOtData1  where  OT_Hour<@max_OTDaily
								order by For_date
							end
						else if @Report_Type = 3
							begin
								select * from #MaxOtData2  where  OT_Hour<@max_OTDaily
								order by For_date	
							end
						else
							begin
								select * from #MaxOtData3  where  OT_Hour<@max_OTDaily
								order by For_date
							end
					end
				else if isnull(@max_OTDaily,0) = 0   and isnull(@max_OTMonthly,0) <> 0
					begin
					  --print 101010101010
						if @Report_Type = 1
							begin
							  	select * from #MaxOtData o1
								inner join #TotalMaxOtData o2 on o1.Emp_Id=o2.Emp_Id
								 where  o2.total_ot_cnt<=@max_OTMonthly
								order by For_date 
								--select * from #MaxOtData where  ot_hr_cnt<=@max_OTDaily  
								--order by For_date 
							end
						else if @Report_Type = 2
							begin
									select * from #MaxOtData1 o1
								inner join #TotalMaxOtData1 o2 on o1.Emp_Id=o2.Emp_Id
								 where  o2.total_ot_cnt<=@max_OTMonthly
								order by For_date 
								--select * from #MaxOtData1  where  ot_hr_cnt<=@max_OTDaily
								--order by For_date
							end
						else if @Report_Type = 3
							begin
									select * from #MaxOtData2 o1
								inner join #TotalMaxOtData2 o2 on o1.Emp_Id=o2.Emp_Id
								 where  o2.total_ot_cnt<=@max_OTMonthly
								order by For_date 
								--select * from #MaxOtData2  where  ot_hr_cnt<=@max_OTDaily
								--order by For_date	
							end
						else
							begin
								select * from #MaxOtData3 o1
								inner join #TotalMaxOtData3 o2 on o1.Emp_Id=o2.Emp_Id
								 where  o2.total_ot_cnt<=@max_OTMonthly
								order by For_date 
								
							
								--select * from #MaxOtData3  where  ot_hr_cnt<=@max_OTDaily
								--order by For_date
							end
					end

				else 
					begin
					  --print 1212121212
						if @Report_Type = 1
							begin
						        select * from #MaxOtData o1
								inner join #TotalMaxOtData o2 on o1.Emp_Id=o2.Emp_Id
								 where  o1.OT_Hour<=@max_OTDaily  and o2.total_ot_cnt<=@max_OTMonthly
								order by For_date 
								--select * from #MaxOtData where  ot_hr_cnt<=@max_OTDaily  
								--order by For_date 
							end
						else if @Report_Type = 2
							begin
								select * from #MaxOtData1 o1
								inner join #TotalMaxOtData1 o2 on o1.Emp_Id=o2.Emp_Id
								 where  o1.OT_Hour<=@max_OTDaily  and o2.total_ot_cnt<=@max_OTMonthly
								order by For_date 
								--select * from #MaxOtData1  where  ot_hr_cnt<=@max_OTDaily
								--order by For_date
							end
						else if @Report_Type = 3
							begin
								select * from #MaxOtData2 o1
								inner join #TotalMaxOtData2 o2 on o1.Emp_Id=o2.Emp_Id
								 where  o1.OT_Hour<=@max_OTDaily  and o2.total_ot_cnt<=@max_OTMonthly
								order by For_date 
								--select * from #MaxOtData2  where  ot_hr_cnt<=@max_OTDaily
								--order by For_date	
							end
						else
							begin
								select * from #MaxOtData3 o1
								inner join #TotalMaxOtData3 o2 on o1.Emp_Id=o2.Emp_Id
								 where  o1.OT_Hour<=@max_OTDaily  and o2.total_ot_cnt<=@max_OTMonthly
								order by For_date 
								--select * from #MaxOtData3  where  ot_hr_cnt<=@max_OTDaily
								--order by For_date
							end
					end
				--added by mansi end
				
 ----------------Comments By NIlay 3- nov -2010 -----------------------
  
			--	update #Data 
			--	set OT_Sec = 0
			--	from #Data  d inner join T0160_OT_Approval OA on d.emp_ID = Oa.Emp_ID 
				

			--	update #Data 
			--	set OT_Sec = isnull(Approved_OT_Sec,0)  --* 3600
			--	from #Data  d inner join T0160_OT_Approval OA on d.emp_ID = Oa.Emp_ID and d.For_Date = oa.For_Date 
		    --select * from #data
				----------------Comments By NIlay 3- nov -2010 -----------------------
		
			-- Comment By Jaina 12-09-2016 Start
			--	if isnull(@max_OTMonthly,0) = 0
			--	begin

			--		Insert into #Data_T
			--		--select OA.Emp_ID,NULL,0,0,0,0,0 ,0,sum(P_days) as Present_Days,Sum(OT_Sec) as OT_Sec,
			--		--'Total',E.Emp_Code,'',CM.Cmp_Name,CM.Cmp_Address,Branch_Address,Dept_Name,Comp_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Gender
			--		--,replace(dbo.F_Return_Hours(sum(Duration_in_Sec)),':','.') as Working_Hour
			--		--,replace(dbo.F_Return_Hours(sum(OT_SEc)) ,':','.')as OT_Hour ,0, Isnull(OA.Weekoff_OT_Sec,0),Isnull(OA.Holiday_OT_Sec,0),Isnull(oa.Weekoff_OT_Hour,0),Isnull(oa.Holiday_OT_Hour,0)
			--		select OA.Emp_ID,NULL,0,0,0,0,0 ,0,sum(P_days) as Present_Days,
			--		Sum(case when @max_OTDaily = 0 then OA.OT_Sec when dbo.F_Return_Sec(replace(@max_OTDaily,'.',':')) < OT_SEc then dbo.F_Return_Sec(replace(@max_OTDaily,'.',':')) else OT_Sec end ) as OT_Sec,				
			--		'Total',E.Alpha_Emp_Code,'',CM.Cmp_Name,CM.Cmp_Address,Branch_Address,Dept_Name,Comp_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Gender
			--		,replace(dbo.F_Return_Hours(sum(Duration_in_Sec)),':','.') as Working_Hour
			--		,replace(dbo.F_Return_Hours(Sum(case when @max_OTDaily = 0 then OA.OT_Sec when dbo.F_Return_Sec(replace(@max_OTDaily,'.',':')) < OT_SEc then dbo.F_Return_Sec(replace(@max_OTDaily,'.',':')) else OT_Sec end )) ,':','.') as OT_Hour ,0,
			--		 Isnull(OA.Weekoff_OT_Sec,0),
			--		 Isnull(OA.Holiday_OT_Sec,0)
			--		 ,Isnull(oa.Weekoff_OT_Hour,0),Isnull(oa.Holiday_OT_Hour,0)
			--		 ,DGM.Desig_Dis_No , ''     --added jimit 24082015		--Blank Space ('') Added By Ramiz as No Need of Comments in total
			--		From #Data  OA inner join T0080_emp_master E on OA.Emp_ID = E.Emp_ID
			--		inner join  T0040_shift_master SM On OA.Shift_ID=SM.Shift_ID inner join   
			--		T0010_company_master CM On E.CMP_ID =CM.CMP_ID inner join  
			--		(select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID from T0095_Increment I inner join     
			--		(select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment    -- Ankit 06092014 for Same Date Increment
			--			where Increment_Effective_date <= @To_Date    
			--				and Cmp_ID = @Cmp_ID    
			--				group by emp_ID  ) Qry on    
			--		I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID  ) I_Q     
			--		on E.Emp_ID = I_Q.Emp_ID  inner join    
			--		T0040_GRADE_MASTER GM ON I_Q.Grd_ID = GM.Grd_ID AND GM.Cmp_ID=E.Cmp_ID LEFT OUTER JOIN    
			--		T0040_TYPE_MASTER ETM ON I_Q.Type_ID = ETM.Type_ID AND ETM.CMp_ID=E.Cmp_ID LEFT OUTER JOIN    
			--		T0040_DESIGNATION_MASTER DGM ON I_Q.Desig_Id = DGM.Desig_Id AND DGM.Cmp_ID=E.Cmp_ID LEFT OUTER JOIN    
			--		T0040_DEPARTMENT_MASTER DM ON I_Q.Dept_Id = DM.Dept_Id AND DM.Cmp_Id=E.Cmp_ID INNER JOIN     
			--		T0030_BRANCH_MASTER BM ON I_Q.BRANCH_ID = BM.BRANCH_ID and BM.CMp_ID=E.Cmp_ID 
			--		where (oa.ot_sec >0 or oa.Weekoff_OT_Sec > 0 or oa.Holiday_OT_Sec > 0) and e.Cmp_ID=@Cmp_ID
			--		Group by  OA.Emp_Id,E.Emp_Full_Name,E.Alpha_Emp_Code,SM.Shift_Name,CM.Cmp_Name,CM.Cmp_Address,Branch_Address,Dept_Name,Comp_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Gender, Isnull(OA.Weekoff_OT_Sec,0),Isnull(OA.Holiday_OT_Sec,0),Isnull(oa.Weekoff_OT_Hour,0),Isnull(oa.Holiday_OT_Hour,0),Desig_Dis_No
	    
			--		select * from #Data_T order by for_date
			--	end	
			--else
			--	begin
			--		delete from #MaxOtData where Sum_ot > dbo.F_Return_Sec(replace(@max_OTMonthly,'.',':'))
			--		insert into #MaxOtData
			--		select 0,Emp_Id,null,sum(Duration_in_sec),0,0,0,0,0,sum(P_days),sum(OT_Sec),'Total',Emp_Code,'',Cmp_Name,Cmp_Address,Branch_Address,Dept_Name,Comp_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Gender,sum(Working_Hour),sum(OT_Hour),0,0,0,0,0
			--		from #MaxOtData
			--		group by Emp_Id,Emp_Code,Cmp_Name,Cmp_Address,Branch_Address,Dept_Name,Comp_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Gender
					
			--		select * from #MaxOtData
			--	end
			-- Comment By Jaina 12-09-2016 End	
	  --      --comment by mansi start
			----Added By Jaina 12-09-2016 Start
			--if isnull(@max_OTMonthly,0) = 0
			--		begin
			--			if @Report_Type = 1
			--				begin
			--					select * from #Data_T order by For_date
			--				end
			--			else if @Report_Type = 2
			--				begin
			--					select * from #Data_T1 order by For_date
			--				end
			--			else if @Report_Type = 3
			--				begin
			--					select * from #Data_T2 order by For_date	
			--				end
			--			else
			--				begin
							
			--					select * from #Data_T3 order by For_date
			--				end
			--		end
			--	else
			--		begin
			--			if @Report_Type = 1
			--				begin
			--					select * from #MaxOtData order by For_date
			--				end
			--			else if @Report_Type = 2
			--				begin
			--					select * from #MaxOtData1 order by For_date
			--				end
			--			else if @Report_Type = 3
			--				begin
			--					select * from #MaxOtData2 order by For_date	
			--				end
			--			else
			--				begin
			--				  print 11
			--					select * from #MaxOtData3 order by For_date
			--				end
			--		end
			--	--Added By Jaina 12-09-2016 End
			--	--comment by mansi end
  end      
  Else if @Return_Record_set=3 or @Return_Record_set =6 or @Return_Record_set = 7
    BEGIN
			update #Data 
			set OT_Sec = 0
			from #Data  d inner join T0160_OT_Approval OA on d.emp_ID = Oa.Emp_ID 

			update #Data 
			set OT_Sec = isnull(Approved_OT_Sec,0)  --* 3600 comment by : Falak on 27-OCT-2010
			from #Data  d inner join T0160_OT_Approval OA on d.emp_ID = Oa.Emp_ID and d.For_Date = oa.For_Date 
				
				
			If @Return_Record_set =3
				BEGIN
					
					select OA.Emp_ID,Max(For_Date)For_Date,E.Emp_Full_Name, dbo.F_Return_Hours(sum(Duration_in_Sec)) as Working_Hour ,dbo.F_Return_Hours(sum(OT_SEc)) as OT_Hour ,
					sum(P_days) as Present_Days,
					E.Emp_Code,SM.Shift_Name,CM.Cmp_Name,CM.Cmp_Address,Branch_Address,Dept_Name,Comp_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Gender
						
					From #Data  OA inner join T0080_emp_master E WITH (NOLOCK) on OA.Emp_ID = E.Emp_ID
					inner join  T0040_shift_master SM WITH (NOLOCK) On OA.Shift_ID=SM.Shift_ID inner join   
					T0010_company_master CM WITH (NOLOCK) On E.CMP_ID =CM.CMP_ID inner join  
					 
	  
					(select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID from T0095_Increment I WITH (NOLOCK) inner join     
					(select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment    WITH (NOLOCK) -- Ankit 06092014 for Same Date Increment
						where Increment_Effective_date <= @To_Date    
							and Cmp_ID = @Cmp_ID    
							group by emp_ID  ) Qry on    
					I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID  ) I_Q     
					on E.Emp_ID = I_Q.Emp_ID  inner join    
					T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN    
					T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN    
					T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN    
					T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN     
					T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID     
					Group by  OA.Emp_Id,E.Emp_Full_Name,E.Emp_Code,SM.Shift_Name,CM.Cmp_Name,CM.Cmp_Address,Branch_Address,Dept_Name,Comp_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Gender
				END
			If @Return_Record_set =6
				BEGIN
			
					select OA.Emp_ID,Max(For_Date)For_Date,E.Emp_Full_Name, dbo.F_Return_Hours(sum(Duration_in_Sec)) as Working_Hour ,dbo.F_Return_Hours(sum(OT_SEc)) as OT_Hour ,
					sum(P_days) as Present_Days,
					E.Emp_Code,E.Alpha_Emp_Code,E.Emp_First_Name,CM.Cmp_Name,CM.Cmp_Address,Branch_Address,Dept_Name,Comp_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,I_Q.Branch_ID,isnull(Leave_Qry.Leave_Used,0) as od_leave
					,Vs.Vertical_Name,sv.SubVertical_Name  --added jimit 28042016
					From #Data  OA inner join T0080_emp_master E WITH (NOLOCK) on OA.Emp_ID = E.Emp_ID
					inner join  T0040_shift_master SM WITH (NOLOCK) On OA.Shift_ID=SM.Shift_ID inner join   
					T0010_company_master CM WITH (NOLOCK) On E.CMP_ID =CM.CMP_ID inner join  
					(select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,I.Vertical_ID,I.SubVertical_ID from T0095_Increment I WITH (NOLOCK) inner join     
						(select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)   -- Ankit 06092014 for Same Date Increment
							where Increment_Effective_date <= @To_Date    
							and Cmp_ID = @Cmp_ID    
							group by emp_ID  ) Qry on    
					I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID  ) I_Q     
					on E.Emp_ID = I_Q.Emp_ID  inner join    
					T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN    
					T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN    
					T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN    
					T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN     
					T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID   Left Outer JOIN
					T0040_Vertical_Segment Vs WITH (NOLOCK) On vs.Vertical_ID = I_Q.Vertical_ID Left Outer JOIN
					T0050_SubVertical sv WITH (NOLOCK) On sv.SubVertical_ID = I_Q.SubVertical_ID Left Outer join 
					( select SUM(leave_used) as Leave_Used, LT.Emp_ID from T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)  inner join
						T0040_LEAVE_MASTER LM WITH (NOLOCK) on LM.Leave_ID = LT.Leave_ID --inner join
						--#Emp_Cons ec on ec.Emp_ID = LT.Emp_ID --Modified by Nimesh 29-May-2015 (We are using SP_CALCULATE_PRESENT_DAYS sp.)
						--#Data ec on ec.Emp_ID = LT.Emp_ID Commented by Sumit on 02082016 after discussion with Nimesh bhai...
						where  LT.cmp_ID = @Cmp_ID  and LM.Leave_Paid_Unpaid = 'P' And Leave_Type = 'Company Purpose' and LT.For_Date >= @From_Date and LT.For_Date <= @To_Date Group By LT.Emp_ID)  Leave_Qry on  Leave_Qry.Emp_ID = E.Emp_ID
					Group by  OA.Emp_Id,E.Emp_Full_Name,E.Emp_Code,E.ALPHA_EMP_CODE,E.Emp_First_Name,CM.Cmp_Name,CM.Cmp_Address,Branch_Address,Dept_Name,Comp_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,I_Q.Branch_ID,Leave_Qry.Leave_Used
								,vs.vertical_Name,sv.SubVertical_Name
					Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
			When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
				Else e.Alpha_Emp_Code
			End
					--ORDER BY RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500)
			END
			If @Return_Record_set = 7
				BEGIN
					select Emp_Id,sum(P_days) as p_days from #Data group by Emp_Id
				END
				
	END		      
	--Added By Ramiz on 14/10/2015 for counting No. of Extra days Worked like on Week-Off & Holiday 
  Else If @Return_Record_set = 8
				BEGIN
					UPDATE #Data SET Duration = dbo.F_Return_Hours(Datediff(s,In_Time,OUT_Time)) 
					FROM #Data D WHERE Emp_ID = D.Emp_ID and For_Date = d.For_date
					
					UPDATE #Data SET No_of_Days = Qry.Calculate_Days
					FROM	#Data T
							INNER JOIN  (
											SELECT	SD.Calculate_Days , D.For_date, d.Emp_Id
											FROM	T0050_SHIFT_DETAIL SD WITH (NOLOCK) INNER JOIN #Data D on D.Shift_ID = SD.Shift_ID 
													and Emp_Id = D.Emp_Id and For_Date = d.For_date
													and Cast(replace(D.Duration,':','.') as numeric(18,2)) >= From_Hour 
													and Cast(replace(D.Duration,':','.') as numeric(18,2)) <= To_Hour
													LEFT OUTER JOIN T0160_OT_APPROVAL ot WITH (NOLOCK) ON D.Emp_Id=ot.Emp_ID and D.For_date=ot.For_Date
											WHERE P_days = 0 and (D.Weekoff_OT_Sec > 0 or D.Holiday_OT_Sec > 0)	or ot.For_Date is not null	
										 ) QRY  ON t.Emp_Id=QRY.Emp_Id and t.For_date=QRY.For_date
							LEFT OUTER JOIN T0160_OT_APPROVAL OT WITH (NOLOCK) ON T.EMP_ID=OT.EMP_ID and T.FOR_DATE=OT.FOR_DATE
					WHERE (P_days = 0 AND (t.Weekoff_OT_Sec > 0 or t.Holiday_OT_Sec > 0)) 
							OR (OT.Weekoff_OT_Sec > 0 or OT.Holiday_OT_Sec > 0)
					

					SELECT D.Emp_Id,E.Alpha_Emp_Code , E.Emp_Full_Name, Branch_name, Desig_Name, Dept_Name, Grd_Name, Type_Name , Vertical_Name , 
					SubVertical_Name, sum(D.P_days) as Present_Days ,Isnull(sum(D.No_of_Days),0) as Extra_Days
					, ISnull((sum(D.P_days) + sum(ISNULL(D.NO_of_Days,0))),0) as Total_Worked_Days , CM.Cmp_Name,CM.Cmp_Address 	
					 FROM #Data D 
					 INNER JOIN T0080_emp_master E WITH (NOLOCK) on D.Emp_ID = E.Emp_ID
					 INNER JOIN T0010_company_master CM WITH (NOLOCK) On E.CMP_ID =CM.CMP_ID
					 INNER JOIN  
							(SELECT I.Emp_Id ,Branch_ID,Cat_ID,Desig_ID,Dept_ID , Grd_ID ,Type_ID , Vertical_ID , SubVertical_ID  from T0095_Increment I WITH (NOLOCK)
							INNER JOIN 
								(SELECT max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK) where Increment_Effective_date <= @To_Date    
										and Cmp_ID = @Cmp_ID GROUP BY emp_ID  ) Qry on I.Emp_ID = Qry.Emp_ID 
										and I.Increment_ID = Qry.Increment_ID  ) I_Q on E.Emp_ID = I_Q.Emp_ID 
					 INNER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id
					 INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID
					 INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.Branch_ID = BM.Branch_ID
					 LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id
					 LEFT OUTER JOIN T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID
					 LEFT OUTER JOIN T0040_Vertical_Segment VS WITH (NOLOCK) ON I_Q.Vertical_ID = VS.Vertical_ID
					 LEFT OUTER JOIN T0050_SubVertical SV WITH (NOLOCK) ON I_Q.SubVertical_ID = SV.SubVertical_ID	 	
					GROUP BY D.Emp_Id ,E.Alpha_Emp_Code,E.Emp_Full_Name,Branch_name,Desig_Name,Dept_Name ,Grd_Name , Type_Name ,Vertical_Name , SubVertical_Name , CM.Cmp_Name,CM.Cmp_Address--,LQry.OD_Days
					
				END	
	-- For RKM 1. OD Leave ON WO/HO	2. Single punch then calculate Full day --- Ankit 05112015
  Else If @Return_Record_set = 9
				BEGIN
					Set @StrHoliday_Date = ''
						
					DECLARE WO_HO_Emp_ID CURSOR FAST_FORWARD FOR  
						 SELECT DISTINCT Emp_ID From #Data 
					OPEN WO_HO_Emp_ID  
					FETCH NEXT FROM WO_HO_Emp_ID INTO @Emp_ID_OD
					WHILE @@FETCH_STATUS = 0  
						BEGIN
							SET @StrWeekoff_Date = ''
							SET @StrHoliday_Date = ''
							SET @Is_Cancel_Holiday = 0
							SET @Is_Cancel_Weekoff = 0
							
							SELECT @BRANCH_ID_OD =	Branch_id 
							FROM t0095_increment  WITH (NOLOCK)
							WHERE Increment_ID =( SELECT MAX(Increment_ID) FROM t0095_increment WITH (NOLOCK) WHERE emp_id=@Emp_ID_OD AND increment_effective_date <=@To_Date) 
							AND emp_id = @Emp_ID_OD
							
							Select @Is_Cancel_Holiday = Is_Cancel_Holiday , @Is_Cancel_Weekoff = Is_Cancel_Weekoff
							From dbo.T0040_GENERAL_SETTING WITH (NOLOCK)
							Where cmp_ID = @cmp_ID and Branch_ID = @BRANCH_ID_OD    
							and For_Date = (select max(For_Date) from dbo.T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@To_Date and Branch_ID = @BRANCH_ID_OD and Cmp_ID = @Cmp_ID)    
							
							Exec dbo.SP_EMP_HOLIDAY_DATE_GET1 @Emp_ID_OD,@Cmp_ID,@From_Date,@To_Date,null,null,@Is_Cancel_Holiday,@StrHoliday_Date_W output,@Holiday_days_W output,@Cancel_Holiday_W output,0,@Branch_ID,@StrWeekoff_Date_W
							Exec dbo.SP_EMP_WEEKOFF_DATE_GET1 @Emp_ID_OD,@Cmp_ID,@From_Date,@To_Date,null,null,@Is_Cancel_weekoff,'',@StrWeekoff_Date_W output,@Weekoff_Days_W output ,@Cancel_Weekoff_w output,@constraint=''
							
							INSERT INTO #Emp_Weekoff_temp
							SELECT @Emp_ID_OD, CAST(DATA  AS DATETIME) FROM dbo.Split ( (@StrHoliday_Date_W) ,';')
							 
							INSERT INTO #Emp_Weekoff_temp
							SELECT @Emp_ID_OD, CAST(DATA  AS DATETIME) AS For_date  FROM dbo.Split ( (@StrWeekoff_Date_W) ,';') WHERE CAST(DATA AS DATETIME) <> '1900-01-01 00:00:00.000' AND CAST(DATA AS DATETIME) NOT IN (SELECT  CAST(DATA  AS DATETIME) AS For_date  FROM dbo.Split ( (@StrHoliday_Date_W) ,';') )
							 	
							INSERT INTO #OD_Emp_Weekoff
							SELECT LT.Emp_ID,LT.For_Date,LT.Leave_Used FROM T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) INNER JOIN
									T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LM.Leave_ID = LT.Leave_ID
							WHERE  LT.cmp_ID = @Cmp_ID AND lt.Leave_Used > 0 AND LM.Leave_Paid_Unpaid = 'P' AND Leave_Type = 'Company Purpose' 
									--AND LT.For_Date IN ( SELECT  CAST(DATA  AS DATETIME) AS For_date  FROM dbo.Split ( (@StrHoliday_Date_W) ,';'))
									AND EXISTS (SELECT  CAST(DATA  AS DATETIME) FROM dbo.Split ( (@StrHoliday_Date_W) ,';') WHERE Data = LT.For_Date )
									and LT.Emp_ID = @Emp_ID_OD
							 
							INSERT INTO #OD_Emp_Weekoff
							SELECT LT.Emp_ID,LT.For_Date,LT.Leave_Used FROM T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)INNER JOIN
									T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LM.Leave_ID = LT.Leave_ID
							WHERE  LT.cmp_ID = @Cmp_ID AND lt.Leave_Used > 0 AND LM.Leave_Paid_Unpaid = 'P' AND Leave_Type = 'Company Purpose' 
									AND LT.For_Date IN ( SELECT  CAST(DATA  AS DATETIME) AS For_date  FROM dbo.Split ( (@StrWeekoff_Date_W) ,';') WHERE CAST(DATA AS DATETIME) NOT IN (SELECT  CAST(DATA  AS DATETIME) AS For_date  FROM dbo.Split ( (@StrHoliday_Date_W) ,';') ))
									and LT.Emp_ID = @Emp_ID_OD
   
							FETCH NEXT FROM WO_HO_Emp_ID INTO @Emp_ID_OD
						END
					 CLOSE WO_HO_Emp_ID  
					 DEALLOCATE WO_HO_Emp_ID  	
					
					--For single punch then calculate Full day
					
					update #Data set Duration = dbo.F_Return_Hours(Datediff(s,In_Time,OUT_Time)) from #Data D where Emp_ID = D.Emp_ID and For_Date = d.For_date
					
					update #Data 
					set Duration = dbo.F_Return_Hours(Datediff(s, case when In_Time is null THEN D.Shift_Start_Time ELSE D.In_Time END,case when OUT_Time IS NULL THEN D.Shift_End_Time ELSE D.OUT_Time end)) 
						,Weekoff_OT_Sec = DATEDIFF(s,case when In_Time is null THEN D.Shift_Start_Time ELSE D.In_Time END,case when OUT_Time IS NULL THEN D.Shift_End_Time ELSE D.OUT_Time end ) 
					from #Data D where Emp_ID = D.Emp_ID and For_Date = d.For_date
					   AND (D.In_Time is NULL or D.OUT_Time is NULL)
					   and EXISTS ( SELECT For_date FROM #Emp_Weekoff_temp WHERE For_date = D.For_Date AND Emp_Id = D.Emp_ID ) 
					
					
					update #Data set No_of_Days = Qry.Calculate_Days
					from	#Data T
							INNER JOIN  (
											SELECT	SD.Calculate_Days , D.For_date, d.Emp_Id
											FROM	T0050_SHIFT_DETAIL SD WITH (NOLOCK) INNER JOIN #Data D on D.Shift_ID = SD.Shift_ID 
													and Emp_Id = D.Emp_Id and For_Date = d.For_date
													and Cast(replace(D.Duration,':','.') as numeric(18,2)) >= From_Hour 
													and Cast(replace(D.Duration,':','.') as numeric(18,2)) <= To_Hour
													LEFT OUTER JOIN T0160_OT_APPROVAL ot WITH (NOLOCK) ON D.Emp_Id=ot.Emp_ID and D.For_date=ot.For_Date
											where P_days = 0 and (D.Weekoff_OT_Sec > 0 or D.Holiday_OT_Sec > 0)	or ot.For_Date is not null			
										) QRY  ON t.Emp_Id=QRY.Emp_Id and t.For_date=QRY.For_date
							LEFT OUTER JOIN T0160_OT_APPROVAL ot WITH (NOLOCK) ON T.Emp_Id=ot.Emp_ID and T.For_date=ot.For_Date
					where (P_days = 0 and (t.Weekoff_OT_Sec > 0 or t.Holiday_OT_Sec > 0))
							OR (OT.Weekoff_OT_Sec > 0 or OT.Holiday_OT_Sec > 0)
					
					
					--DELETE FROM #Data WHERE No_of_Days > 0 AND EXISTS (SELECT For_date FROM #OD_Emp_Weekoff WHERE For_date = #Data.For_Date )
					
					-----OD Leave ON WO/HO	--------
					
					
					select D.Emp_Id,E.Alpha_Emp_Code , E.Emp_Full_Name, Branch_name, Desig_Name, Dept_Name, Grd_Name, Type_Name , Vertical_Name , SubVertical_Name, sum(D.P_days) as Present_Days ,Isnull(sum(D.No_of_Days),0) as Extra_Days,ISNULL(LQry.OD_Days,0) AS OD_Leave_Days , ISnull((sum(D.P_days) + sum(ISNULL(D.NO_of_Days,0)) + ISNULL(LQry.OD_Days,0)  ),0) as Total_Worked_Days , CM.Cmp_Name,CM.Cmp_Address 
						
					 from #Data D 
					 INNER JOIN T0080_emp_master E WITH (NOLOCK) on D.Emp_ID = E.Emp_ID
					 INNER JOIN T0010_company_master CM WITH (NOLOCK) On E.CMP_ID =CM.CMP_ID
					 INNER JOIN  
							(select I.Emp_Id ,Branch_ID,Cat_ID,Desig_ID,Dept_ID , Grd_ID ,Type_ID , Vertical_ID , SubVertical_ID  from T0095_Increment I WITH (NOLOCK)
							INNER JOIN 
								(select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK) where Increment_Effective_date <= @To_Date    
										and Cmp_ID = @Cmp_ID group by emp_ID  ) Qry on I.Emp_ID = Qry.Emp_ID 
										and I.Increment_ID = Qry.Increment_ID  ) I_Q on E.Emp_ID = I_Q.Emp_ID 
					 INNER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id
					 INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID
					 INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.Branch_ID = BM.Branch_ID
					 LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id
					 LEFT OUTER JOIN T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID
					 LEFT OUTER JOIN T0040_Vertical_Segment VS WITH (NOLOCK) ON I_Q.Vertical_ID = VS.Vertical_ID
					 LEFT OUTER JOIN T0050_SubVertical SV WITH (NOLOCK) ON I_Q.SubVertical_ID = SV.SubVertical_ID
					 LEFT OUTER JOIN ( SELECT SUM(W_Day) AS OD_Days,Emp_Id FROM #OD_Emp_Weekoff WHERE For_Date >= @From_Date AND For_Date <= @To_Date GROUP BY  Emp_ID ) LQry ON LQry.Emp_ID = I_Q.Emp_Id
					
					group by D.Emp_Id ,E.Alpha_Emp_Code,E.Emp_Full_Name,Branch_name,Desig_Name,Dept_Name ,Grd_Name , Type_Name ,Vertical_Name , SubVertical_Name , CM.Cmp_Name,CM.Cmp_Address,LQry.OD_Days
				
				END	 
  		
  Else If @Return_Record_set = 10
		BEGIN			
			SELECT t1.Emp_id,t1.Emp_code,t1.Emp_Full_Name,Sum(WorkDay) As WorkDay,Shift
			INTO #TMP
			from(
				Select QRy.emp_id , QRy.Emp_code ,  QRy.Emp_Full_Name ,  Sum(Qry.P_days) as WorkDay, 
					(Case WHEN QRy.Shift_ID in (SELECT Shift_ID FROM T0040_SHIFT_MASTER WITH (NOLOCK)
												where 
													(CASE WHEN CONVERT(VARCHAR(8),Shift_St_Time,108) > CONVERT(VARCHAR(8),Shift_End_Time,108) OR CONVERT(VARCHAR(8),Shift_St_Time,108) = '00:00' THEN 
														1
													END
													) = 1
												) THEN 'Night' ELSE 'Day' END) As Shift from 
						(	
							SELECT D.Emp_id , D.Shift_ID , SM.Shift_Name, Em.Emp_code , Em.Emp_Full_Name , D.P_days as P_days , D.For_date
							from #Data D
							Inner JOin T0040_Shift_master SM WITH (NOLOCK) ON SM.Shift_ID = D.Shift_ID
							INNER JOIN T0080_EMP_MASTER Em WITH (NOLOCK) on Em.Emp_ID = D.Emp_Id
						)QRy

				GROUP BY QRy.Shift_ID , QRy.emp_id , QRy.Emp_code , QRy.Emp_Full_Name 
			) t1 
			GROUP BY t1.Emp_id,t1.Emp_Full_Name,t1.Emp_code , Shift


					 SELECT D.Emp_Id,E.Alpha_Emp_Code , E.Emp_Full_Name, Branch_name, Desig_Name, Dept_Name, Grd_Name, Type_Name , Vertical_Name , 
					 SubVertical_Name, CM.Cmp_Name,CM.Cmp_Address , QryShift.Work_day , QryShift.WorkNight	
					 from #Data D 
					 INNER JOIN T0080_emp_master E WITH (NOLOCK) on D.Emp_ID = E.Emp_ID
					 INNER JOIN T0010_company_master CM WITH (NOLOCK) On E.CMP_ID =CM.CMP_ID
					 INNER JOIN  
							(select I.Emp_Id ,Branch_ID,Cat_ID,Desig_ID,Dept_ID , Grd_ID ,Type_ID , Vertical_ID , SubVertical_ID  from T0095_Increment I WITH (NOLOCK)
							INNER JOIN 
								(select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK) where Increment_Effective_date <= @To_Date    
										and Cmp_ID = @Cmp_ID group by emp_ID  ) Qry on I.Emp_ID = Qry.Emp_ID 
										and I.Increment_ID = Qry.Increment_ID  ) I_Q on E.Emp_ID = I_Q.Emp_ID 
					 INNER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id
					 INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID
					 INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.Branch_ID = BM.Branch_ID
					 LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id
					 LEFT OUTER JOIN T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID
					 LEFT OUTER JOIN T0040_Vertical_Segment VS WITH (NOLOCK) ON I_Q.Vertical_ID = VS.Vertical_ID
					 LEFT OUTER JOIN T0050_SubVertical SV WITH (NOLOCK) ON I_Q.SubVertical_ID = SV.SubVertical_ID
					 Inner JOIN (	
					 --SELECT t1.emp_id as Emp_id, t1.WorkDay as Work_day , Isnull(t2.WorkDayNight,0) as WorkNight FROM #tmp t1	 -- change by rohit for Case employee do work for night whole month on 04012017
					 --LEFT OUTER JOIN (select WorkDay  As WorkDayNight, emp_id from #TMP where Shift = 'Night') t2 ON t1.emp_id=t2.emp_id
					 --where t1.Shift='Day'
					 SELECT isnull(t1.emp_id,t2.emp_id) as Emp_id, isnull(t1.WorkDay,0) as Work_day , Isnull(t2.WorkDayNight,0) as WorkNight FROM (select WorkDay  As WorkDay, emp_id ,shift from #TMP where Shift = 'Day') t1	
						full OUTER JOIN (select WorkDay  As WorkDayNight, emp_id ,shift from #TMP where Shift = 'Night') t2 ON t1.emp_id=t2.emp_id
						where (isnull(t1.Shift,'Day')='Day' )
									)QryShift on QryShift.Emp_id = I_Q.Emp_ID					 
					group by D.Emp_Id ,E.Alpha_Emp_Code,E.Emp_Full_Name,Branch_name,Desig_Name,Dept_Name ,Grd_Name , Type_Name ,Vertical_Name , SubVertical_Name , CM.Cmp_Name,CM.Cmp_Address , QryShift.Work_day , QryShift.WorkNight			
					
	END	 
	ELSE IF @RETURN_RECORD_SET = 11  --For OverTime Tracking Report Added By Jimit 07052018------
		 BEGIN
				
						IF OBJECT_ID('DBO.TEMPDB..#RMRORM') IS NOT NULL
						DROP TABLE #RMRORM
					
						CREATE TABLE #RMRORM
						(
							EMP_ID				NUMERIC,
							R_EMP_ID			NUMERIC				
						)
						
						CREATE table #Emp_Cons 
						(      
							Emp_ID numeric ,     
							Branch_ID numeric,
							Increment_ID numeric    
						)     				 
						
						if @Constraint <> ''
							begin
								Insert Into #Emp_Cons
								Select	cast(data  as numeric),cast(data  as numeric),cast(data  as numeric) 
								From	dbo.Split(@Constraint,'#') 
							end
						
						Insert	INTO #RMRORM
						SELECT	EC.Emp_Id,RM.R_Emp_ID 
						From	#Emp_Cons EC Inner Join 
								V0010_Get_Max_Reporting_manager RM ON EC.Emp_ID = RM.Emp_ID
						
						
						UPDATE  RM
						SET	    RM.R_Emp_Id = Q.R_Emp_ID 
						FROM	#RMRORM RM INNER JOIN
								#Emp_Cons EC On Ec.Emp_ID = Rm.Emp_ID INNER JOIN
								(
									SELECT	ERD.R_Emp_ID , ERD.Emp_ID
									FROM	
											T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN
											(
												SELECT	 MAX(Effect_Date) as Effect_Date, Emp_ID 
												FROM	 T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
												WHERE	 Effect_Date <= GETDATE()
												GROUP BY emp_ID
											) RQry on  ERD.Emp_ID = RQry.Emp_ID and ERD.Effect_Date = RQry.Effect_Date
											INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON E.EMP_ID = ERD.R_EMP_ID 
									WHERE EXISTS (
													SELECT	DISTINCT ERD1.EMP_ID
													FROM	T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK) INNER JOIN
															(
																SELECT	 MAX(Effect_Date) as Effect_Date, Emp_ID 
																from	 T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
																WHERE	 Effect_Date <= GETDATE()
																GROUP BY emp_ID
															) RQry on  ERD1.Emp_ID = RQry.Emp_ID and ERD1.Effect_Date = RQry.Effect_Date
													INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON E.EMP_ID = ERD1.R_EMP_ID AND ERD.Emp_ID = E.Emp_ID 
													Inner Join #Emp_Cons ECS On ECS.Emp_ID  = ERD1.Emp_ID 				
												)
								)Q On Q.Emp_ID = Rm.R_EMP_ID
								
								
								
						SELECT * FROM 
					(
							select	distinct OA.Emp_Id,OA.For_date,OA.P_days,case when @max_OTDaily = 0 then OA.OT_Sec 
											   when dbo.F_Return_Sec(replace(@max_OTDaily,'.',':')) < OA.OT_Sec then dbo.F_Return_Sec(replace(@max_OTDaily,'.',':')) 
											   else oa.OT_Sec end as OT_Sec,
									E.Emp_Full_Name as Emp_Full_Name,E.Alpha_Emp_Code,CM.Cmp_Name,CM.Cmp_Address,Branch_Address,Dept_Name,
									Comp_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,DGM.Desig_Dis_No,
									Replace(dbo.F_Return_Hours(Duration_in_Sec),':','.') as Working_Hour,
									case when @max_OTDaily = 0 then replace(dbo.F_Return_Hours(OA.OT_Sec),':','.') when dbo.F_Return_Sec(replace(@max_OTDaily,'.',':')) < OA.OT_Sec then replace(@max_OTDaily,':','.') else replace(dbo.F_Return_Hours(OA.OT_Sec),':','.') end as OT_Hour,
									OA.Weekoff_OT_Sec,OA.Holiday_OT_Sec,Replace(dbo.F_Return_Hours(OA.Weekoff_OT_Sec),':','.') Weekoff_OT_Hour, Replace(dbo.F_Return_Hours(OA.Holiday_OT_Sec),':','.') Holiday_OT_Hour,			  							
									case when OTA.Is_Approved = 1 then 'Approved' 
									else case when OTA.Is_Approved = 0 then 'Rejected' else 'Pending' end 
									end as OT_Status,
									(Qry_Reporting.Alpha_Emp_Code + ' - ' + Qry_Reporting.Emp_Full_Name) as Manager	
									,SD.Rpt_Level
									,@FROM_DATE as FROM_DATE ,@TO_DATE as TO_DATE,ota.System_Date as Approved_Date	  
							from	#Data   OA   inner join			
									T0080_emp_master E WITH (NOLOCK) on OA.Emp_ID = E.Emp_ID		inner join			
									T0010_company_master CM WITH (NOLOCK) On E.CMP_ID =CM.CMP_ID	inner join			
									( 
										select	I.Emp_Id,Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID 
										from	T0095_Increment I WITH (NOLOCK) inner join			
												(
													select	max(Increment_ID) as Increment_ID , Emp_ID 
													from	T0095_Increment WITH (NOLOCK)
													where	Increment_Effective_date <= @To_Date  and Cmp_ID = @Cmp_ID 
													group by emp_ID
												) Qry on I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID  
									) I_Q on E.Emp_ID = I_Q.Emp_ID inner join			
									T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN		
									T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN		
									T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN		
									T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN			
									T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID 	Left Outer join
									(
										SELECT  R1.Emp_ID, Effect_Date AS Effect_Date,Alpha_Emp_Code, Em.emp_full_name,R_Emp_ID
										FROM    dbo.T0090_EMP_REPORTING_DETAIL R1 WITH (NOLOCK) INNER JOIN 
												(
													SELECT		MAX(ROW_ID) AS ROW_ID, R2.Emp_ID
													FROM		T0090_EMP_REPORTING_DETAIL R2 WITH (NOLOCK) INNER JOIN 
																(
																	SELECT	MAX(R3.Effect_Date) AS Effect_Date, R3.Emp_ID 
																	FROM	T0090_EMP_REPORTING_DETAIL R3 WITH (NOLOCK) 
																	WHERE	R3.Effect_Date < GETDATE() 
																	GROUP BY R3.Emp_ID
																)R3 ON R2.Emp_ID=R3.Emp_ID AND R2.Effect_Date=R3.Effect_Date 
													GROUP BY R2.Emp_ID
												) R2 ON R1.Row_ID=R2.ROW_ID AND R1.Emp_ID=R2.Emp_ID	INNER JOIN 
												T0080_EMP_MASTER Em WITH (NOLOCK) on R1.R_emp_id = Em.emp_id
									) AS Qry_Reporting ON E.Emp_ID = Qry_Reporting.Emp_ID	Left Outer join 
									T0095_EMP_SCHEME ES WITH (NOLOCK) on OA.Emp_ID = ES.Emp_ID Inner Join
										 (
											select	 MAX(Effective_Date) as For_Date, Emp_ID,Cmp_ID 
											from	 T0095_EMP_SCHEME WITH (NOLOCK)
											where    Effective_Date<=GETDATE() And Type = 'Over Time' and Cmp_ID = @Cmp_ID
											GROUP BY emp_ID,Cmp_ID
										 ) QES on ES.Emp_ID = QES.Emp_ID AND ES.Effective_Date = QES.For_Date AND Type = 'Over Time'	
										 AND ES.Cmp_ID = QES.Cmp_ID INNER JOIN 
									T0050_Scheme_Detail SD WITH (NOLOCK) on ES.Scheme_ID=SD.Scheme_Id AND ES.Type='Over Time'	 Left OUTER JOIN	
									T0115_OT_LEVEL_APPROVAL OTA WITH (NOLOCK) on E.Emp_ID = OTA.Emp_ID and OTA.For_Date = OA.For_date
									and OTA.Rpt_Level = Sd.Rpt_Level		
						Where		(OA.OT_Sec > 0 or OA.Weekoff_OT_Sec > 0 or OA.Holiday_OT_Sec > 0)  AND
									(SD.Is_RM=1 and sd.Is_RMToRM = 0)
						--						order by	For_Date
						
						UNION 
						
						select	distinct OA.Emp_Id,OA.For_date,OA.P_days,case when @max_OTDaily = 0 then OA.OT_Sec 
											   when dbo.F_Return_Sec(replace(@max_OTDaily,'.',':')) < OA.OT_Sec then dbo.F_Return_Sec(replace(@max_OTDaily,'.',':')) 
											   else oa.OT_Sec end as OT_Sec,
								E.Emp_Full_Name as Emp_Full_Name,E.Alpha_Emp_Code,CM.Cmp_Name,CM.Cmp_Address,Branch_Address,Dept_Name,
								Comp_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,E.Date_of_Join,DGM.Desig_Dis_No,
								Replace(dbo.F_Return_Hours(Duration_in_Sec),':','.') as Working_Hour,
								case when @max_OTDaily = 0 then replace(dbo.F_Return_Hours(OA.OT_Sec),':','.') when dbo.F_Return_Sec(replace(@max_OTDaily,'.',':')) < OA.OT_Sec then replace(@max_OTDaily,':','.') else replace(dbo.F_Return_Hours(OA.OT_Sec),':','.') end as OT_Hour,
								OA.Weekoff_OT_Sec,OA.Holiday_OT_Sec,Replace(dbo.F_Return_Hours(OA.Weekoff_OT_Sec),':','.') Weekoff_OT_Hour, Replace(dbo.F_Return_Hours(OA.Holiday_OT_Sec),':','.') Holiday_OT_Hour,			  										  							
								case when OTA.Is_Approved = 1 then 'Approved' 
								else case when OTA.Is_Approved = 0 then 'Rejected' else 'Pending' end 
								end as OT_Status,
								(isnull(RM.Alpha_Emp_Code,E.Alpha_Emp_Code) + ' - ' + isnull(RM.Emp_Full_Name,E.Emp_Full_Name)) as Manager	,SD.Rpt_Level			  
								,@FROM_DATE as FROM_DATE ,@TO_DATE as TO_DATE,ota.System_Date as Approved_Date	
						from	T0050_Scheme_Detail SD WITH (NOLOCK)
								inner join T0095_EMP_SCHEME ES WITH (NOLOCK)
								Inner Join
										 (select	MAX(Effective_Date) as For_Date, Emp_ID from T0095_EMP_SCHEME WITH (NOLOCK)
													where Effective_Date<=GETDATE() And Type = 'Over Time'
													GROUP BY emp_ID
										 ) QES on ES.Emp_ID = QES.Emp_ID and ES.Effective_Date = QES.For_Date and Type = 'Over Time'										  
								on ES.Scheme_ID=SD.Scheme_Id and ES.Type='Over Time'   inner join 
								T0080_EMP_MASTER E WITH (NOLOCK) on E.Emp_ID=ES.Emp_ID	 LEFt Outer Join
								#Data   OA On oa.Emp_Id = E.Emp_Id  inner join			
								T0080_emp_master RM WITH (NOLOCK) ON RM.Emp_ID=SD.App_Emp_ID  inner join			
								T0010_company_master CM WITH (NOLOCK) On E.CMP_ID =CM.CMP_ID inner join			
								( 
									select	I.Emp_Id,Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID 
									from	T0095_Increment I WITH (NOLOCK) inner join			
											(
												select	max(Increment_ID) as Increment_ID , Emp_ID 
												from	T0095_Increment WITH (NOLOCK)
												where	Increment_Effective_date <= @To_Date  and Cmp_ID = @Cmp_ID 
												group by emp_ID
											) Qry on I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID  
								) I_Q on E.Emp_ID = I_Q.Emp_ID inner join			
								T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN		
								T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN		
								T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN		
								T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN			
								T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID Left OUTER JOIN	
								T0115_OT_LEVEL_APPROVAL OTA WITH (NOLOCK) on E.Emp_ID = OTA.Emp_ID and OTA.For_Date = OA.For_date and  OTA.Rpt_Level = Sd.Rpt_Level		Left join
								(
									SELECT  R1.Emp_ID, Effect_Date AS Effect_Date,Alpha_Emp_Code, Em.emp_full_name,R_Emp_ID
									FROM    dbo.T0090_EMP_REPORTING_DETAIL R1 WITH (NOLOCK) INNER JOIN 
											(
												SELECT		MAX(ROW_ID) AS ROW_ID, R2.Emp_ID
												FROM		T0090_EMP_REPORTING_DETAIL R2 WITH (NOLOCK) INNER JOIN 
															(
																SELECT	MAX(R3.Effect_Date) AS Effect_Date, R3.Emp_ID 
																FROM	T0090_EMP_REPORTING_DETAIL R3 WITH (NOLOCK)
																WHERE	R3.Effect_Date < GETDATE() 
																GROUP BY R3.Emp_ID
															)R3 ON R2.Emp_ID=R3.Emp_ID AND R2.Effect_Date=R3.Effect_Date 
												GROUP BY R2.Emp_ID
											) R2 ON R1.Row_ID=R2.ROW_ID AND R1.Emp_ID=R2.Emp_ID	INNER JOIN 
											T0080_EMP_MASTER Em WITH (NOLOCK) on R1.R_emp_id = Em.emp_id
								) AS Qry_Reporting ON E.Emp_ID = Qry_Reporting.Emp_ID				
						Where	(OA.OT_Sec > 0 or OA.Weekoff_OT_Sec > 0 or OA.Holiday_OT_Sec > 0) and
								(SD.Is_RM=0 and SD.Is_RMToRM =0)       									
						
						
						UNION
						
						select DISTINCT	OA.Emp_Id,OA.For_date,OA.P_days,case when @max_OTDaily = 0 then OA.OT_Sec 
											   when dbo.F_Return_Sec(replace(@max_OTDaily,'.',':')) < OA.OT_Sec then dbo.F_Return_Sec(replace(@max_OTDaily,'.',':')) 
											   else oa.OT_Sec end as OT_Sec,
								E.Emp_Full_Name as Emp_Full_Name,E.Alpha_Emp_Code,CM.Cmp_Name,CM.Cmp_Address,Branch_Address,Dept_Name,
								Comp_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,E.Date_of_Join,DGM.Desig_Dis_No,
								Replace(dbo.F_Return_Hours(Duration_in_Sec),':','.') as Working_Hour,
								case when @max_OTDaily = 0 then replace(dbo.F_Return_Hours(OA.OT_Sec),':','.') when dbo.F_Return_Sec(replace(@max_OTDaily,'.',':')) < OA.OT_Sec then replace(@max_OTDaily,':','.') else replace(dbo.F_Return_Hours(OA.OT_Sec),':','.') end as OT_Hour,
								OA.Weekoff_OT_Sec,OA.Holiday_OT_Sec,Replace(dbo.F_Return_Hours(OA.Weekoff_OT_Sec),':','.') Weekoff_OT_Hour, Replace(dbo.F_Return_Hours(OA.Holiday_OT_Sec),':','.') Holiday_OT_Hour,			  										  							
								case when OTA.Is_Approved = 1 then 'Approved' 
								else case when OTA.Is_Approved = 0 then 'Rejected' else 'Pending' end 
								end as OT_Status,
								(Q.Alpha_Emp_Code + ' - ' + Q.Emp_Full_Name) as Manager	,SD.Rpt_Level			  
								,@FROM_DATE as FROM_DATE ,@TO_DATE as TO_DATE,ota.System_Date as Approved_Date	
						from	#Data  OA inner join			
								T0080_emp_master E WITH (NOLOCK) ON E.Emp_ID = OA.Emp_ID Left OUTER JOIN 
								(
									select		R1.Emp_ID,Alpha_Emp_Code, Em.emp_full_name,R_Emp_ID
									 FROM		#RMRORM R1 Inner JOIN 
												T0080_EMP_MASTER Em WITH (NOLOCK) On R1.R_emp_id = Em.emp_id											 
								) Q On Q.EMP_ID = e.Emp_ID inner join			
								T0010_company_master CM WITH (NOLOCK) On E.CMP_ID =CM.CMP_ID inner join			
								( 
									select	I.Emp_Id,Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID 
									from	T0095_Increment I WITH (NOLOCK) inner join			
											(
												select	max(Increment_ID) as Increment_ID , Emp_ID 
												from	T0095_Increment WITH (NOLOCK)
												where	Increment_Effective_date <= @To_Date  and Cmp_ID = @Cmp_ID 
												group by emp_ID
											) Qry on I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID  
								) I_Q on E.Emp_ID = I_Q.Emp_ID inner join			
								T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN		
								T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN		
								T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN		
								T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN			
								T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID 	Left join								(
									SELECT  R1.Emp_ID, Effect_Date AS Effect_Date,Alpha_Emp_Code, Em.emp_full_name,R_Emp_ID
									FROM    dbo.T0090_EMP_REPORTING_DETAIL R1 WITH (NOLOCK) INNER JOIN 
											(
												SELECT		MAX(ROW_ID) AS ROW_ID, R2.Emp_ID
												FROM		T0090_EMP_REPORTING_DETAIL R2 WITH (NOLOCK) INNER JOIN 
															(
																SELECT	MAX(R3.Effect_Date) AS Effect_Date, R3.Emp_ID 
																FROM	T0090_EMP_REPORTING_DETAIL R3 WITH (NOLOCK)
																WHERE	R3.Effect_Date < GETDATE() 
																GROUP BY R3.Emp_ID
															)R3 ON R2.Emp_ID=R3.Emp_ID AND R2.Effect_Date=R3.Effect_Date 
												GROUP BY R2.Emp_ID
											) R2 ON R1.Row_ID=R2.ROW_ID AND R1.Emp_ID=R2.Emp_ID	INNER JOIN 
											T0080_EMP_MASTER Em WITH (NOLOCK) on R1.R_emp_id = Em.emp_id
								) AS Qry_Reporting ON E.Emp_ID = Qry_Reporting.Emp_ID	Left join 
								T0095_EMP_SCHEME ES WITH (NOLOCK) on OA.Emp_ID = ES.Emp_ID Inner Join
								 (
									select	MAX(Effective_Date) as For_Date, Emp_ID,Cmp_ID 
									from	T0095_EMP_SCHEME WITH (NOLOCK)
									where	Effective_Date<=GETDATE() And Type = 'Over Time' and Cmp_ID = @Cmp_ID
									GROUP BY emp_ID,Cmp_ID
								 ) QES on ES.Emp_ID = QES.Emp_ID AND ES.Effective_Date = QES.For_Date
										 AND Type = 'Over Time' AND ES.Cmp_ID = QES.Cmp_ID INNER JOIN 
								T0050_Scheme_Detail SD 	WITH (NOLOCK) on ES.Scheme_ID=SD.Scheme_Id AND ES.Type='Over Time' Left OUTER JOIN	
								T0115_OT_LEVEL_APPROVAL OTA WITH (NOLOCK) on E.Emp_ID = OTA.Emp_ID and OTA.For_Date = OA.For_date
								and OTA.Rpt_Level = Sd.Rpt_Level		
						Where	(OA.OT_Sec > 0 or OA.Weekoff_OT_Sec > 0 or OA.Holiday_OT_Sec > 0) and
								(SD.Is_RM=0 and sd.Is_RMToRM = 1) 
						
						
						
						UNION
						
						select	distinct OA.Emp_Id,OA.For_date,OA.P_days,case when @max_OTDaily = 0 then OA.OT_Sec 
											   when dbo.F_Return_Sec(replace(@max_OTDaily,'.',':')) < OA.OT_Sec then dbo.F_Return_Sec(replace(@max_OTDaily,'.',':')) 
											   else oa.OT_Sec end as OT_Sec,
								E.Emp_Full_Name as Emp_Full_Name,E.Alpha_Emp_Code,CM.Cmp_Name,CM.Cmp_Address,Branch_Address,Dept_Name,
								Comp_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,E.Date_of_Join,DGM.Desig_Dis_No,
								Replace(dbo.F_Return_Hours(Duration_in_Sec),':','.') as Working_Hour,
								case when @max_OTDaily = 0 then replace(dbo.F_Return_Hours(OA.OT_Sec),':','.') when dbo.F_Return_Sec(replace(@max_OTDaily,'.',':')) < OA.OT_Sec then replace(@max_OTDaily,':','.') else replace(dbo.F_Return_Hours(OA.OT_Sec),':','.') end as OT_Hour,
								OA.Weekoff_OT_Sec,OA.Holiday_OT_Sec,Replace(dbo.F_Return_Hours(OA.Weekoff_OT_Sec),':','.') Weekoff_OT_Hour, Replace(dbo.F_Return_Hours(OA.Holiday_OT_Sec),':','.') Holiday_OT_Hour,			  										  							
								case when OTA.Is_Approved = 1 then 'Approved' 
								else case when OTA.Is_Approved = 0 then 'Rejected' else 'Pending' end 
								end as OT_Status,
								(isnull(EM1.Alpha_Emp_Code,E.Alpha_Emp_Code) + ' - ' + isnull(EM1.Emp_Full_Name,E.Emp_Full_Name)) as Manager
								,SD.Rpt_Level			  
								,@FROM_DATE as FROM_DATE ,@TO_DATE as TO_DATE,ota.System_Date as Approved_Date	
						from	T0050_Scheme_Detail SD WITH (NOLOCK)
								inner join T0095_EMP_SCHEME ES WITH (NOLOCK)
								Inner Join
										 (select	MAX(Effective_Date) as For_Date, Emp_ID from T0095_EMP_SCHEME WITH (NOLOCK)
													where Effective_Date<=GETDATE() And Type = 'Over Time'
													GROUP BY emp_ID
										 ) QES on ES.Emp_ID = QES.Emp_ID and ES.Effective_Date = QES.For_Date and Type = 'Over Time'										  
								on ES.Scheme_ID=SD.Scheme_Id and ES.Type='Over Time' and Sd.Is_Bm = 1  inner join 
								T0080_EMP_MASTER E WITH (NOLOCK) on E.Emp_ID=ES.Emp_ID	 LEFt Outer Join
								#Data OA On oa.Emp_Id = E.Emp_Id and Oa.Emp_Id = Es.Emp_ID inner join											
								T0010_company_master CM WITH (NOLOCK) On E.CMP_ID =CM.CMP_ID inner join			
								( 
									select	I.Emp_Id,Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID 
									from	T0095_Increment I WITH (NOLOCK) inner join			
											(
												select	max(Increment_ID) as Increment_ID , Emp_ID 
												from	T0095_Increment WITH (NOLOCK)
												where	Increment_Effective_date <= @To_Date  and Cmp_ID = @Cmp_ID 
												group by emp_ID
											) Qry on I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID  
								) I_Q on E.Emp_ID = I_Q.Emp_ID inner join			
								T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN		
								T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN		
								T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN		
								T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN			
								T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID Left OUTER JOIN	
								T0115_OT_LEVEL_APPROVAL OTA WITH (NOLOCK) on E.Emp_ID = OTA.Emp_ID and OTA.For_Date = OA.For_date and OTA.Rpt_Level = Sd.Rpt_Level	 	Left join
								(
									SELECT  R1.Emp_ID, Effective_Date AS Effect_Date,R1.Branch_ID
									FROM    dbo.T0095_MANAGERS R1 WITH (NOLOCK) INNER JOIN 
											(
												SELECT		MAX(R2.Tran_id) AS ROW_ID, R2.Emp_ID
												FROM		T0095_MANAGERS R2 WITH (NOLOCK) INNER JOIN 
															(
																SELECT	MAX(R3.Effective_Date) AS Effect_Date, R3.Emp_ID 
																FROM	T0095_MANAGERS R3 WITH (NOLOCK)
																WHERE	R3.Effective_Date < GETDATE() 
																GROUP BY R3.Emp_ID
															)R3 ON R2.Emp_ID=R3.Emp_ID AND R2.Effective_Date=R3.Effect_Date 
												GROUP BY R2.Emp_ID
											) R2 ON R1.Emp_ID=R2.Emp_ID 	
								) AS Qry_Reporting ON E.Branch_ID = Qry_Reporting.branch_id	 	Inner join
								T0080_Emp_Master Em1 WITH (NOLOCK) On Em1.Emp_Id = Qry_Reporting.Emp_id								
						Where	(OA.OT_Sec > 0 or OA.Weekoff_OT_Sec > 0 or OA.Holiday_OT_Sec > 0) and
								(SD.Is_BM=1)
						
						)Q
					order by Emp_Id,For_Date,rpt_Level
						
								
				
		 END 

  		
RETURN      


