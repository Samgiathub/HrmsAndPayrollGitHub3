

-- =============================================
-- Author:		Ripal Patel
-- Create date: 24Sep2014
-- Description:	<Description,,>
---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_CALCULATE_PRESENT_DAYS_WebServices]        
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
 ,@constraint   varchar(MAX)        
 ,@Return_Record_set numeric = 1 
 ,@StrWeekoff_Date varchar(Max)  =''
 ,@Is_Split_Shift_Req tinyint = 0
AS        
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON        
           
Declare @Count   numeric         
Declare @Tmp_Date datetime         
set @Tmp_Date = @From_Date        


if @Return_Record_set = 1 or @Return_Record_set = 2 or @Return_Record_set =3  or @Return_Record_set = 5 or @Return_Record_set = 8 OR @Return_Record_set = 9 OR @Return_Record_set = 10 OR @Return_Record_set = 11 OR @Return_Record_set = 12 --or @Return_Record_set = 7        
 Begin        
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
	   IO_Tran_Id	   numeric default 0, -- io_tran_id is used for is_cmp_purpose (t0150_emp_inout)
	   OUT_Time datetime,
	   Shift_End_Time datetime,			--Ankit 16112013
	   OT_End_Time numeric default 0,	--Ankit 16112013
	   Working_Hrs_St_Time tinyint default 0, --Hardik 14/02/2014
	   Working_Hrs_End_Time tinyint default 0 --Hardik 14/02/2014
   )      

 
		        
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
	   Working_Hrs_End_Time tinyint default 0 --Hardik 14/02/2014
	   
   )        
   
 end        

If @Is_Split_Shift_Req =1 
	Begin
		CREATE TABLE #Split_Shift_Table
		(
		 Emp_Id Numeric,
		 Split_Shift_Count Numeric(18,0),
		 Split_Shift_Dates varchar(5000),
		 Split_Shift_Allow numeric(18,2)
		)
	
	End
        
  
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
   Emp_ID numeric ,     
  Branch_ID numeric,
  Increment_ID numeric    
 )            
  --Added by Gadriwala Muslim    26082014
CREATE table #Emp_Holiday
	  (
			Emp_Id		numeric , 
			Cmp_ID		numeric,
			For_Date	datetime,
			H_Day		numeric(3,1),
			is_Half_day tinyint
	  )	  

 if @Constraint <> ''        
  begin        
   Insert Into #Emp_Cons(Emp_ID)        
   select  cast(data  as numeric) from dbo.Split (@Constraint,'#')         
  end        
 else        
  begin        
          
		Insert Into #Emp_Cons      
		  select distinct emp_id,branch_id,Increment_ID from dbo.V_Emp_Cons where 
		  cmp_id=@Cmp_ID 
		   and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
	   and Branch_ID = isnull(@Branch_ID ,Branch_ID)      
	   and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
	   and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
	   and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
	   and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0)) 
	   and Emp_ID = isnull(@Emp_ID ,Emp_ID)   
		 and Increment_Effective_Date <= @To_Date 
			  and 
					  ( (@From_Date  >= join_Date  and  @From_Date <= left_date )      
						or ( @To_Date  >= join_Date  and @To_Date <= left_date )      
						or (Left_date is null and @To_Date >= Join_Date)      
						or (@To_Date >= left_date  and  @From_Date <= left_date )) 
						order by Emp_ID
					
					Delete From #Emp_Cons Where Increment_ID Not In	--Ankit 30012014
				(select TI.Increment_ID from t0095_increment TI WITH (NOLOCK) inner join
				(Select Max(Increment_ID) as Increment_ID,Emp_ID from T0095_Increment WITH (NOLOCK)	-- Ankit 12092014 for Same Date Increment
				Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
				on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_ID=new_inc.Increment_ID
				Where Increment_effective_Date <= @to_date)			


        
	--select I.Emp_Id from T0095_Increment I inner join         
	--( select max(Increment_effective_Date) as For_Date , Emp_ID From T0095_Increment        
	--where Increment_Effective_date <= @To_Date        
	--and Cmp_ID = @Cmp_ID        
	--group by emp_ID  ) Qry on        
	--I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date         
               
 --  Where Cmp_ID = @Cmp_ID         
 --  and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))        
 --  and Branch_ID = isnull(@Branch_ID ,Branch_ID)        
 --  and Grd_ID = isnull(@Grd_ID ,Grd_ID)        
 --  and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))        
 --  and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))        
 --  and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))        
 --  and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID)         
  end        
  
	declare @curEmp_ID numeric
	Declare @Is_OT numeric -- Hardik 03/02/2014
	
	Declare curautobranch cursor Fast_forward for	                  
	select Emp_ID from #Emp_Cons 
	Open curautobranch                      
	Fetch next from curautobranch into @curEmp_ID
	   
		While @@fetch_status = 0                    
		Begin     
         
			Declare @First_In_Last_Out_For_InOut_Calculation tinyint 
			Declare  @Chk_otLimit_before_after_Shift_time tinyint 
			
			declare @cBrh as numeric
			
			select @cBrh  = Branch_ID from dbo.T0095_Increment EI WITH (NOLOCK)
			where Increment_ID in (select max(Increment_ID) as Increment_ID from dbo.T0095_Increment WITH (NOLOCK) where Increment_Effective_date <= @To_Date  and Cmp_ID = @Cmp_ID and Emp_ID = @curEmp_ID) and Emp_ID = @curEmp_ID	-- Ankit 12092014 for Same Date Increment
			select @First_In_Last_Out_For_InOut_Calculation  = First_In_Last_Out_For_InOut_Calculation,@Is_OT = ISNULL(Is_OT,0)
			,@Chk_otLimit_before_after_Shift_time=Chk_otLimit_before_after_Shift_time
			from dbo.T0040_GENERAL_SETTING WITH (NOLOCK) where Branch_ID = @cBrh  and For_Date in (select MAX(For_Date) as for_date from dbo.T0040_GENERAL_SETTING WITH (NOLOCK)  where For_Date <= @To_Date and Cmp_ID = Cmp_ID and Branch_ID = @cBrh) and Cmp_ID = @Cmp_ID			
			
			if @First_In_Last_Out_For_InOut_Calculation = 1
				Begin				
				
					----- changed to get record with only Min(InTime) and Max(OutTime) ------

						  Insert into #Data (Emp_ID,For_Date,Duration_In_sec,Emp_OT,Emp_OT_min_Limit,Emp_OT_max_Limit,In_Time,Shift_Start_Time,OT_Start_Time,Shift_Change,Chk_By_Superior,IO_Tran_Id,OUT_Time)        
					              
					   select distinct eir.Emp_ID ,EIR.for_Date,isnull(datediff(s,In_Date,Case when Max_In_Date > Out_Date Then Max_In_Date Else Out_Date End),0) ,Case When @Is_OT = 0 Then @Is_OT Else isnull(Emp_OT,0)End,dbo.F_Return_Sec(Emp_OT_min_Limit),dbo.F_Return_Sec(Emp_OT_max_Limit),In_Date,null,0,0,isnull(Q3.Chk_By_Sup,0),isnull(EIR.is_cmp_purpose ,0),Case when Max_In_Date > Out_Date Then Max_In_Date Else Out_Date End 
					   from dbo.T0150_emp_inout_Record  EIR WITH (NOLOCK) Inner join #Emp_Cons Ec on EIR.Emp_Id = ec.Emp_ID inner Join        
						(select I.Emp_ID,Emp_OT,isnull(Emp_OT_min_Limit,'00:00')Emp_OT_min_Limit,isnull(Emp_OT_max_Limit,'00:00')Emp_OT_max_Limit from dbo.T0095_Increment  I WITH (NOLOCK) inner join         
						(select max(Increment_ID)Increment_ID ,Emp_ID from dbo.T0095_Increment WITH (NOLOCK)        -- Ankit 12092014 for Same Date Increment
						 where increment_effective_Date <=@To_Date and Cmp_ID =@Cmp_ID group by Emp_ID)q on I.emp_ID =q.Emp_ID and         
						I.Increment_ID = q.Increment_ID ) IQ on eir.Emp_ID =iq.emp_ID 
						Inner Join
						(select Emp_Id, Min(In_Time) In_Date,For_Date From dbo.T0150_Emp_Inout_Record WITH (NOLOCK) Group By Emp_Id,For_Date) Q1 on EIR.Emp_Id = Q1.Emp_Id 
						And EIR.For_Date = Q1.For_Date
						Inner Join
						(select Emp_Id, Max(Out_Time) Out_Date,For_Date From dbo.T0150_Emp_Inout_Record WITH (NOLOCK) Group By Emp_Id,For_Date) Q2 on EIR.Emp_Id = Q2.Emp_Id 
						And EIR.For_Date = Q2.For_Date
						Inner Join
						--Added by Hardik 23/07/2012 for First IN And Last OUT (it will take Max In Punch as OUT and calculate Hours)
						(select Emp_Id, Max(In_Time) Max_In_Date,For_Date From dbo.T0150_Emp_Inout_Record WITH (NOLOCK) Group By Emp_Id,For_Date) Q4 on EIR.Emp_Id = Q4.Emp_Id  
						And EIR.For_Date = Q4.For_Date
						Left Outer Join 
						(Select Emp_ID,Chk_By_Superior Chk_By_Sup,For_Date from dbo.T0150_EMP_INOUT_RECORD WITH (NOLOCK) where Chk_By_Superior=1) Q3 on EIR.Emp_Id = Q3.Emp_Id 
						And EIR.For_Date = Q3.For_Date
					   Where cmp_Id= @Cmp_ID        
					   and EIR.for_Date >=@From_Date and EIR.For_Date <=@To_Date  and ec.Emp_ID = @curEmp_ID      
					   group by eir.Emp_ID,eir.For_Date,Emp_OT,Emp_OT_min_Limit,Emp_OT_max_Limit,In_Time,In_Date,out_Date,Chk_By_Sup ,EIR.is_cmp_purpose,OUT_Time,Max_In_Date 
					   order by EIR.For_Date
					   
					 ------------------end--------------------
					  
				End
			Else
				Begin

					Insert into #Data (Emp_ID,For_Date,Duration_In_sec,Emp_OT,Emp_OT_min_Limit,Emp_OT_max_Limit,In_Time,Shift_Start_Time,OT_Start_Time,Shift_Change,Chk_By_Superior,IO_Tran_Id,OUT_Time)        
				      
					  select eir.Emp_ID ,EIR.for_Date,sum(isnull(datediff(s,in_time,out_time),0)) ,Case When @Is_OT = 0 Then @Is_OT Else isnull(Emp_OT,0)End,dbo.F_Return_Sec(Emp_OT_min_Limit),dbo.F_Return_Sec(Emp_OT_max_Limit),In_Time,null,0,0,Chk_By_Superior,isnull(EIR.is_cmp_purpose ,0),Out_Time 
					   from dbo.T0150_emp_inout_Record  EIR WITH (NOLOCK) Inner join #Emp_Cons Ec on EIR.Emp_Id = ec.Emp_ID inner Join			
						(select I.Emp_ID,Emp_OT,isnull(Emp_OT_min_Limit,'00:00')Emp_OT_min_Limit,isnull(Emp_OT_max_Limit,'00:00')Emp_OT_max_Limit from dbo.T0095_Increment  I WITH (NOLOCK) inner join         
						(select max(Increment_ID)Increment_ID ,Emp_ID from dbo.T0095_Increment WITH (NOLOCK)        -- Ankit 12092014 for Same Date Increment
						 where increment_effective_Date <=@To_Date and Cmp_ID =@Cmp_ID group by Emp_ID)q on I.emp_ID =q.Emp_ID and         
						I.Increment_ID = q.Increment_ID ) IQ on eir.Emp_ID =iq.emp_ID 
											       
					   Where cmp_Id= @Cmp_ID        
					   and EIR.for_Date >=@From_Date and EIR.For_Date <=@To_Date and ec.Emp_ID = @curEmp_ID
					   group by eir.Emp_ID,eir.For_Date,Emp_OT,Emp_OT_min_Limit,Emp_OT_max_Limit,In_Time,Chk_By_Superior ,EIR.is_cmp_purpose,Out_Time  
					   order by EIR.For_Date
					   
				End				
			
			fetch next from curautobranch into @curEmp_ID
		  
		end                    
	close curautobranch                    
	deallocate curautobranch
	 
	 
	   
	 --- Start Cursor curAttRegularize -> cursor Fast_forward for regularize attendance Alpesh 09-Dec-2011
	 declare @shift_st_time datetime
	 --declare @shift_end_time datetime
	 --declare @temp_st_time datetime
	 --declare @temp_end_time datetime
	 --declare @attEmpId numeric
	 --declare @attFor_Date datetime
	 --declare @attIO_Tran_Id Numeric			
				
	 
	 --if @First_In_Last_Out_For_InOut_Calculation = 1
	 --  Begin	 
		-- declare curAttRegularize cursor Fast_forward for select Emp_ID,For_Date from #Data where Chk_By_Superior = 1
		-- open curAttRegularize
		-- fetch next from curAttRegularize into @attEmpId,@attFor_Date
		 
		-- while @@FETCH_STATUS = 0
		--	 Begin
			 
				
		--		Select @shift_st_time=Shift_St_Time,@shift_end_time=Shift_End_Time from T0100_EMP_SHIFT_DETAIL ESD 
		--			Inner Join T0040_SHIFT_MASTER SM on SM.Shift_ID=ESD.Shift_ID 
		--		Where Emp_ID=@attEmpId and For_Date=(Select max(For_Date) from T0100_EMP_SHIFT_DETAIL where Emp_ID=@attEmpId and For_Date <= @attFor_Date)
				
		--		set @shift_st_time =cast(cast(@attFor_Date as varchar(11))+ ' ' + convert(varchar(20),@shift_st_time,108) as datetime)
		--		set @shift_end_time =cast(cast(@attFor_Date as varchar(11))+ ' ' +  convert(varchar(20),@shift_end_time,108) as datetime)
				
				
		--		select top 1 @temp_st_time = (case when Is_Cancel_Late_In=1 and In_Time > @shift_st_time then @shift_st_time else In_Time end)
		--		from T0150_EMP_INOUT_RECORD where Emp_ID=@attEmpId and For_date = @attFor_Date and Chk_By_Superior=1
				
		--		select top 1 @temp_end_time =(case when Is_Cancel_Early_Out=1 and Out_Time < @shift_end_time then @shift_end_time else Out_Time end) 
		--		from T0150_EMP_INOUT_RECORD where Emp_ID=@attEmpId and For_date = @attFor_Date and Chk_By_Superior=1 order by Out_Time desc
				
								
		--		Update #Data Set Duration_In_sec = isnull(datediff(s,@temp_st_time,@temp_end_time),0) where Emp_ID=@attEmpId and For_date = @attFor_Date
				
		--		fetch next from curAttRegularize into @attEmpId,@attFor_Date
		--	 End
		-- close curAttRegularize
		-- deallocate curAttRegularize
	 --  End
	 --else
	 --  Begin
	 --  	 declare curAttRegularize cursor Fast_forward for select Emp_ID,For_Date,IO_Tran_Id from #Data where Chk_By_Superior = 1
		-- open curAttRegularize
		-- fetch next from curAttRegularize into @attEmpId,@attFor_Date,@attIO_Tran_Id
		 
		-- while @@FETCH_STATUS = 0
		--	 Begin
		--		Select @shift_st_time=Shift_St_Time,@shift_end_time=Shift_End_Time from T0100_EMP_SHIFT_DETAIL ESD 
		--			Inner Join T0040_SHIFT_MASTER SM on SM.Shift_ID=ESD.Shift_ID 
		--		Where Emp_ID=@attEmpId and For_Date=(Select max(For_Date) from T0100_EMP_SHIFT_DETAIL where Emp_ID=@attEmpId and For_Date <= @attFor_Date)
				
		--		set @shift_st_time =cast(cast(@attFor_Date as varchar(11))+ ' ' + convert(varchar(20),@shift_st_time,108) as datetime)
		--		set @shift_end_time =cast(cast(@attFor_Date as varchar(11))+ ' ' +  convert(varchar(20),@shift_end_time,108) as datetime)
				
				
		--		--select top 1 @temp_st_time = (case when Is_Cancel_Late_In=1 and In_Time > @shift_st_time then @shift_st_time else In_Time end)
		--		--from T0150_EMP_INOUT_RECORD where Emp_ID=@attEmpId and For_date = @attFor_Date and Chk_By_Superior=1 and IO_Tran_Id=@attIO_Tran_Id
				
		--		--select top 1 @temp_end_time =(case when Is_Cancel_Early_Out=1 and Out_Time < @shift_end_time then @shift_end_time else Out_Time end) 
		--		--from T0150_EMP_INOUT_RECORD where Emp_ID=@attEmpId and For_date = @attFor_Date and Chk_By_Superior=1 and IO_Tran_Id=@attIO_Tran_Id order by Out_Time desc
				
		--		select @temp_st_time = (case when Is_Cancel_Late_In=1 and In_Time > @shift_st_time then @shift_st_time else In_Time end)
		--		from T0150_EMP_INOUT_RECORD where Emp_ID=@attEmpId and For_date = @attFor_Date and Chk_By_Superior=1 and IO_Tran_Id=@attIO_Tran_Id
				
		--		select @temp_end_time =(case when Is_Cancel_Early_Out=1 and Out_Time < @shift_end_time then @shift_end_time else Out_Time end) 
		--		from T0150_EMP_INOUT_RECORD where Emp_ID=@attEmpId and For_date = @attFor_Date and Chk_By_Superior=1 and IO_Tran_Id=@attIO_Tran_Id 
												
		--		Update #Data Set Duration_In_sec = isnull(datediff(s,@temp_st_time,@temp_end_time),0) where Emp_ID=@attEmpId and For_date = @attFor_Date and IO_Tran_Id=@attIO_Tran_Id
		--		set @temp_st_time=''
		--		set @temp_end_time=''
				
		--		fetch next from curAttRegularize into @attEmpId,@attFor_Date,@attIO_Tran_Id
		--	 End
		-- close curAttRegularize
		-- deallocate curAttRegularize
	 --  End
	 
	 --- End Cursor curAttRegularize
	
		
     ---- select * from #Data
     --      --Insert Into @Data_temp1 (Emp_ID,For_Date,Duration_In_sec,Emp_OT,Emp_OT_min_Limit,Emp_OT_max_Limit,In_Time,Shift_Start_Time,OT_Start_Time,Shift_Change)
     --      --Select Emp_ID,for_Date,sum(isnull(Duration_in_sec,0)),isnull(Emp_OT,0),dbo.F_Return_Sec(isnull(Emp_OT_min_Limit,0)),dbo.F_Return_Sec(isnull(Emp_OT_max_Limit,0)),null,null,0,0             
     --      -- From #Data Group By For_Date,Emp_ID,Emp_Ot,Emp_OT_min_Limit,Emp_OT_Max_Limit
           
            Insert Into @Data_temp1 (Emp_ID,For_Date,Duration_In_sec,Emp_OT,Emp_OT_min_Limit,Emp_OT_max_Limit,In_Time,Shift_Start_Time,OT_Start_Time,Shift_Change,Chk_By_Superior,IO_Tran_Id,OUT_Time)
           Select Emp_ID,for_Date,sum(isnull(Duration_in_sec,0)),isnull(Emp_OT,0),isnull(Emp_OT_min_Limit,0),isnull(Emp_OT_max_Limit,0),null,null,0,0,Chk_By_Superior,IO_Tran_Id,0             
            From #Data Group By For_Date,Emp_ID,Emp_Ot,Emp_OT_min_Limit,Emp_OT_Max_Limit,Chk_By_Superior,IO_Tran_Id

	   Update @Data_temp1 set In_Time=InTime, OUT_Time=OutTime 
	   from  @Data_temp1 as DT	
	   inner join
	   (select Min(In_Time) as InTime, Max (OUT_Time) as OutTime, For_Date,Emp_ID from #Data Group by For_Date,Emp_ID)Q
	   on DT.Emp_ID=Q.Emp_ID and Dt.For_Date=Q.For_Date 	 	   	
           
           
		--Delete From #Data         
		Truncate Table #Data        --Hardik 15/02/2013  
		
		Insert Into #data 
		select * from @Data_temp1
			
	DECLARE @Night_Shift AS NUMERIC

	DECLARE @Mst_Shift_St_time AS DATETIME
	DECLARE @Mst_Shift_End_Time AS DATETIME
				
	--Add by Nimesh 21 April, 2015
	--This sp retrieves the Shift Rotation as per given employee id and effective date.
	--it will fetch all employee's shift rotation detail if employee id is not specified.
	IF (OBJECT_ID('tempdb..#Rotation') IS NULL)
		Create Table #Rotation (R_EmpID numeric(18,0), R_DayName varchar(25), R_ShiftID numeric(18,0), R_Effective_Date DateTime);
	--The #Rotation table gets re-created in dbo.P0050_UNPIVOT_EMP_ROTATION stored procedure
	
	Exec dbo.P0050_UNPIVOT_EMP_ROTATION  @Cmp_ID, NULL, @To_Date , @constraint
			
		
	set @Tmp_Date =@From_Date        
    while @Tmp_Date <=@To_Date        
    begin  
               
        
  -- Update #Data        
  --   set Shift_ID   = Q1.Shift_ID,          
  -- Shift_Type = q1.Shift_type 
  --   from #Data d inner Join        
  --   (select sd.shift_ID ,sd.Emp_ID,shift_type,sd.For_Date from T0100_Emp_Shift_Detail sd inner join        
  --   (select MaX(for_Date) for_Date ,Emp_Id,Shift_ID   from T0100_Emp_Shift_Detail        
  --   where Cmp_Id =@Cmp_ID and shift_Type = 0 and for_Date <=@Tmp_Date group by Emp_ID ,Shift_Id)q on sd.Emp_ID =q.Emp_ID and sd.For_Date =q.For_Date)q1  on d.emp_ID = q1.emp_ID         
  --  Where D.For_Date = @tmp_Date     
       
                                 
  --Update #Data        
  --  set Shift_ID   = Q1.Shift_ID,          
  --Shift_Type = q1.Shift_type        
  --from #Data d inner Join        
  --  (select sd.shift_ID ,sd.Emp_ID,shift_type,sd.For_Date from T0100_Emp_Shift_Detail   sd inner join        
  --  (select MaX(for_Date) for_Date ,Emp_Id,Shift_ID   from T0100_Emp_Shift_Detail        
  --  where Cmp_Id =@Cmp_ID and shift_Type = 1 and for_Date =@Tmp_Date group by Emp_ID ,Shift_Id)q on sd.Emp_ID =q.Emp_ID and sd.For_Date =q.For_Date)q1  on d.emp_ID = q1.emp_ID         
  -- Where D.For_Date = @tmp_Date     
-----Changed by Sid
		SET @Mst_Shift_St_time = (SELECT Shift_St_Time FROM dbo.T0040_SHIFT_MASTER WITH (NOLOCK) WHERE Shift_ID = (SELECT TOP 1 Shift_ID From #data WHERE for_date = @Tmp_Date ))
		SET @Mst_Shift_End_Time = (SELECT Shift_End_Time FROM dbo.T0040_SHIFT_MASTER WITH (NOLOCK) WHERE Shift_ID = (SELECT TOP 1 Shift_ID From #data WHERE for_date = @Tmp_Date ))
		
		SET @Night_Shift = CASE WHEN @Mst_Shift_St_time < @Mst_Shift_End_Time THEN 0 ELSE 1 END 
-----Changed by Sid ends
  
  
		--Updating default latest shift info from Employee Shift Detail table
		UPDATE	#Data        
		SET		Shift_ID   = Q1.Shift_ID,          
				Shift_Type = q1.Shift_type 
		FROM	#Data d inner Join        
				(select		q.Shift_ID ,q.Emp_ID,isnull(shift_type,0) shift_type ,q.For_Date from dbo.T0100_Emp_Shift_Detail sd WITH (NOLOCK) inner join        
				(select		for_Date ,Emp_Id,Shift_ID   from dbo.T0100_Emp_Shift_Detail    as esdsub WITH (NOLOCK)      
					WHERE	Cmp_Id =@Cmp_ID and for_Date = (select max(for_Date) from dbo.T0100_Emp_Shift_Detail WITH (NOLOCK) where emp_id = esdsub.emp_id and Cmp_Id =@Cmp_ID and isnull(shift_type,0)  = 0 and For_Date <= @Tmp_Date ) )q on sd.Emp_ID =q.Emp_ID and sd.For_Date =q.For_Date)q1  on d.emp_ID = q1.emp_ID         
		WHERE	D.For_Date = @tmp_Date  
       
		/*Commented by Nimesh 21 May 2015                          
  Update #Data        
    set Shift_ID   = Q1.Shift_ID,          
  Shift_Type = q1.Shift_type        
  from #Data d inner Join        
    (select q.Shift_ID ,q.Emp_ID,isnull(shift_type,0) shift_type,q.For_Date from dbo.T0100_Emp_Shift_Detail   sd inner join        
    (select for_Date ,Emp_Id,Shift_ID   from dbo.T0100_Emp_Shift_Detail          as esdsub   
     where Cmp_Id =@Cmp_ID and isnull(shift_type,0)  = 1 and for_Date = (select max(for_Date) from dbo.T0100_Emp_Shift_Detail where  emp_id = esdsub.emp_id and Cmp_Id =@Cmp_ID and  isnull(shift_type,0)  = 1 and For_Date <= @Tmp_Date ) )q on sd.Emp_ID =q.Emp_ID and sd.For_Date =q.For_Date)q1  on d.emp_ID = q1.emp_ID And d.For_date = q1.For_Date	--And d.For_date = q1.For_Date --Ankit 12092014
   Where D.For_Date = @tmp_Date 
		*/
		
		--Added by Nimesh 22 April, 2015
		--Updating Shift ID From Rotation
		UPDATE	#Data 
		SET		SHIFT_ID=SM.SHIFT_ID,Shift_Type=0
		FROM	#Rotation R INNER JOIN T0040_SHIFT_MASTER SM ON R.R_ShiftID=SM.Shift_ID					
		WHERE	SM.Cmp_ID=@Cmp_ID AND R.R_DayName = 'Day' + CAST(DATEPART(d, @Tmp_Date) As Varchar) AND
				Emp_Id=R.R_EmpID AND R.R_Effective_Date=(SELECT MAX(R_Effective_Date)
					FROM #Rotation R1 WHERE R1.R_EmpID=Emp_Id AND 
						 R_Effective_Date<=@Tmp_Date) AND 
				For_date=@Tmp_Date


		--Updating Shift ID from Employee Shift Detail where ForDate=@TempDate ANd Shift_Type=1 
		--And Rotation should be assigned to that particular employee
		UPDATE	#Data 
		SET		SHIFT_ID=ESD.SHIFT_ID,Shift_Type=ESD.Shift_Type
		FROM	#Data D INNER JOIN (SELECT esd.Shift_ID, esd.Emp_ID, esd.Shift_Type,esd.For_Date
				FROM T0100_EMP_SHIFT_DETAIL esd WITH (NOLOCK) WHERE Cmp_ID = ISNULL(@Cmp_ID,Cmp_ID) AND For_Date = @Tmp_Date) ESD ON
				D.Emp_Id=ESD.Emp_ID AND D.For_date=ESD.For_Date				
		WHERE	ESD.Emp_ID IN (Select R.R_EmpID FROM #Rotation R
					WHERE R_DayName = 'Day' + CAST(DATEPART(d, @Tmp_Date) As Varchar) AND R_Effective_Date<=@Tmp_Date
					GROUP BY R.R_EmpID) AND D.For_date=@Tmp_Date

		--Updating Shift ID from Employee Shift Detail where ForDate=@TempDate ANd Shift_Type=1 
		--And Rotation should not be assigned to that particular employee
		UPDATE	#Data 
		SET		SHIFT_ID=ESD.SHIFT_ID,Shift_Type=ESD.Shift_Type
		FROM	#Data D INNER JOIN (SELECT esd.Shift_ID, esd.Emp_ID, esd.Shift_Type,esd.For_Date
				FROM T0100_EMP_SHIFT_DETAIL esd WITH (NOLOCK) WHERE Cmp_ID = ISNULL(@Cmp_ID,Cmp_ID) AND For_Date = @Tmp_Date) ESD ON
				D.Emp_Id=ESD.Emp_ID AND D.For_date=ESD.For_Date				
		WHERE	IsNull(ESD.Shift_Type,0)=1 AND ESD.Emp_ID NOT IN (Select R.R_EmpID FROM #Rotation R
					WHERE R_DayName = 'Day' + CAST(DATEPART(d, @Tmp_Date) As Varchar) AND R_Effective_Date<=@Tmp_Date
					GROUP BY R.R_EmpID) AND D.For_date=@Tmp_Date
		--End Nimesh   	

   
-- Update #Data set Shift_End_Time   = cast(CONVERT(VARCHAR(11), OUT_Time, 121)  + CONVERT(VARCHAR(12), Shift_End_Time, 114) as datetime)  from #Data	--Ankit 16112013
  
    set @Tmp_Date = dateadd(d,1,@tmp_date)            
 end  
 
	--Modified by Nimesh 21 May, 2015
	UPDATE	#Data
	SET		Shift_Start_Time = q.Shift_St_Time,
			OT_Start_Time=ISNULL(q.OT_Start_Time,0),
			Shift_End_Time = q.Shift_End_Time,	   --Ankit 16112013
			OT_End_Time =  ISNULL(q.OT_End_Time,0), --Ankit 16112013 
			Working_Hrs_St_Time = q.Working_Hrs_St_Time,	   --Hardik 14/02/2014
			Working_Hrs_End_Time =  ISNULL(q.Working_Hrs_End_Time,0) --Hardik 14/02/2014
	FROM	#data d INNER JOIN 
				(
					SELECT	ST.Shift_st_time,ST.Shift_ID,ISNULL(SD.OT_Start_Time,0) AS OT_Start_Time,
							ST.Shift_End_Time ,ISNULL(SD.OT_End_Time,0) AS OT_End_Time,
							Sd.Working_Hrs_St_Time,sd.Working_Hrs_End_Time
					FROM	dbo.T0040_SHIFT_MASTER ST WITH (NOLOCK)
							LEFT OUTER JOIN dbo.T0050_SHIFT_DETAIL SD WITH (NOLOCK) ON ST.Shift_ID=SD.Shift_ID 
					WHERE	St.Cmp_ID = @Cmp_ID 
				) q ON d.shift_id=q.shift_id
  
  Update #Data set Shift_End_Time   = Case When Shift_Start_Time > Shift_End_Time Then cast(CONVERT(VARCHAR(11), OUT_Time, 121)  + CONVERT(VARCHAR(12), Shift_End_Time, 114) as datetime) Else cast(CONVERT(VARCHAR(11), In_Time, 121)  + CONVERT(VARCHAR(12), Shift_End_Time, 114) as datetime) End  from #Data	--Ankit 16112013  
  Update #Data set Shift_Start_Time = cast(CONVERT(VARCHAR(11), In_time, 121)  + CONVERT(VARCHAR(12), Shift_Start_Time, 114) as datetime)  from #Data

 
 Update #Data set Shift_Change=1 where isnull(datediff(s,in_time,Shift_Start_Time),0)  < -14400 
 Update #Data set Shift_Change=1 where isnull(datediff(s,in_time,Shift_Start_Time),0)  > 14400  
 
	
	
	---Hardik 03/02/2014 for Kataria as they have not calculate working hour after Shift End Time

   Update #Data
    set Duration_in_sec = DATEDIFF(s,d.Shift_Start_Time,d.OUT_Time)
    from #data d 
    Where Working_Hrs_St_Time = 1 And d.Working_Hrs_End_Time = 0 and In_Time < d.Shift_Start_Time
    
   Update #Data
    set Duration_in_sec = DATEDIFF(s,In_Time,d.Shift_End_Time)
    from #data d 
    Where d.Working_Hrs_St_Time = 0 And d.Working_Hrs_End_Time = 1 and OUT_Time > d.Shift_End_Time

   Update #Data
    set Duration_in_sec =
    Case When In_Time < Shift_Start_Time And OUT_Time > Shift_End_Time Then  DATEDIFF(s,d.Shift_Start_Time,d.Shift_End_Time) Else
    Case When In_Time < Shift_Start_Time Then DATEDIFF(s,d.Shift_Start_Time,OUT_Time) Else
    Case When OUT_Time > Shift_End_Time Then DATEDIFF(s,In_Time,d.Shift_End_Time) Else
		DATEDIFF(s,In_Time,OUT_Time) End End End
    from #data d 
    Where d.Working_Hrs_St_Time = 1 And d.Working_Hrs_End_Time = 1

    
 ---- End by Hardik 03/02/2014
 
 
 
 -- Added by rohit for if week of regularization not calculate in present if week off Work transfer to OT on 07022013
---- chk by sid for case when edit hours are kept editable
	UPDATE	#Data
	SET		P_days = 1 ,
			in_time = CASE WHEN Is_Cancel_Late_In = 1 THEN CASE WHEN d.in_time > CONVERT(VARCHAR(11), d.For_date, 120) + sm.shift_st_time then CONVERT(VARCHAR(11), d.For_date, 120) + sm.shift_st_time ELSE d.In_Time END ELSE d.In_Time END,
			out_time = CASE WHEN Is_Cancel_Early_Out = 1 THEN CASE WHEN d.Out_Time < CONVERT(VARCHAR(11), d.For_date, 120) + sm.shift_end_time THEN CONVERT(VARCHAR(11), d.For_date, 120) + sm.shift_end_time ELSE d.Out_Time END ELSE d.Out_Time END,
			duration_in_sec = dbo.F_Return_Sec(sm.shift_dur)
	FROM	#Data d
	INNER JOIN dbo.T0150_EMP_INOUT_RECORD TEIR
	ON TEIR.Emp_Id = d.Emp_Id AND TEIR.Chk_By_Superior = 1 
			AND TEIR.For_Date = d.For_date AND TEIR.Half_Full_day = 'Full Day'
	INNER JOIN T0040_SHIFT_MASTER SM ON d.shift_id = SM.shift_id 
	WHERE	TEIR.For_Date >= @From_Date AND TEIR.For_Date <= @To_Date AND d.IO_Tran_Id = 0 
	
	
	
	UPDATE	#Data
	SET		duration_in_sec = DATEDIFF(SECOND,d.in_time,d.out_time)
	FROM	#Data d
	INNER JOIN dbo.T0150_EMP_INOUT_RECORD TEIR
	ON TEIR.Emp_Id = d.Emp_Id AND TEIR.Chk_By_Superior = 1 
			AND TEIR.For_Date = d.For_date AND TEIR.Half_Full_day = 'Full Day'
	INNER JOIN T0040_SHIFT_MASTER SM ON d.Shift_ID = SM.shift_id
	WHERE	TEIR.For_Date >= @From_Date AND TEIR.For_Date <= @To_Date AND d.IO_Tran_Id = 0 



----chk by sid ends	
	
	
	update #Data 
	set P_days = 0.5 ,in_time = convert(varchar(11),d.For_date,120) + sm.shift_st_time,out_time = (convert(varchar(11),d.For_date,120) + dbo.F_Return_Hours(dbo.F_Return_Sec(sm.shift_st_time) + (dbo.F_Return_Sec(sm.shift_dur))/2)),duration_in_sec = dbo.F_Return_Sec(sm.shift_dur)/2  
	from #Data d inner join  dbo.T0150_EMP_INOUT_RECORD TEIR 
	on TEIR.Emp_Id = d.Emp_Id and TEIR.Chk_By_Superior = 1 and TEIR.For_Date = d.For_date and ( TEIR.Half_Full_day = 'First Half')
	inner join T0040_SHIFT_MASTER SM on d.Shift_ID = SM.shift_id 
	where TEIR.For_Date >= @From_Date and TEIR.For_Date <= @To_Date   and d.IO_Tran_Id  = 0 
	
	
	update #Data 
	set P_days = 0.5 ,in_time = (convert(varchar(11),d.For_date,120) + dbo.F_Return_Hours(dbo.F_Return_Sec(sm.shift_st_time) + (dbo.F_Return_Sec(sm.shift_dur))/2)),out_time = convert(varchar(11),d.For_date,120) + sm.shift_end_time ,duration_in_sec = dbo.F_Return_Sec(sm.shift_dur)/2  
	from #Data d inner join  dbo.T0150_EMP_INOUT_RECORD TEIR 
	on TEIR.Emp_Id = d.Emp_Id and TEIR.Chk_By_Superior = 1 and TEIR.For_Date = d.For_date and ( TEIR.Half_Full_day = 'Second Half')
	inner join T0040_SHIFT_MASTER SM on d.Shift_ID = SM.shift_id 
	where TEIR.For_Date >= @From_Date and TEIR.For_Date <= @To_Date   and d.IO_Tran_Id  = 0 
	
	
-- Ended by rohit on 07022013
 

Declare @Emp_ID_AutoShift numeric
Declare @In_Time_Autoshift datetime
Declare @New_Shift_ID numeric
 Declare curautoshift cursor Fast_forward for	                  
	select Emp_ID,In_Time,d.Shift_ID from #Data d inner join T0040_SHIFT_MASTER s WITH (NOLOCK) on d.Shift_ID = s.Shift_ID 
	where isnull(Shift_Change,0)=1 and Isnull(s.Inc_Auto_Shift,0) = 1 order by In_time,Emp_ID
Open curautoshift                      
	  Fetch next from curautoshift into @Emp_ID_AutoShift,@In_Time_Autoshift,@New_Shift_ID
               
		While @@fetch_status = 0                    
			Begin     
               
       --select  @Emp_ID_AutoShift,@In_Time_Autoshift
			Declare @Shift_ID_Autoshift numeric
			Declare @Shift_start_time_Autoshift varchar(12)
	        Select @Shift_ID_Autoshift=Shift_ID,@Shift_start_time_Autoshift=Shift_st_time from dbo.t0040_shift_master WITH (NOLOCK) where cmp_id=@Cmp_id and isnull(inc_auto_shift,0)=1
       and datediff(s,@In_Time_Autoshift,cast(CONVERT(VARCHAR(11), @In_Time_Autoshift, 121)  + CONVERT(VARCHAR(12), Shift_St_Time, 114) as datetime)) >-14400
        if isnull(@Shift_ID_Autoshift,0) > 0 And isnull(@Shift_ID_Autoshift,0)<>isnull(@New_Shift_ID,0)
			Begin
				Update #Data set Shift_ID=@Shift_ID_Autoshift,Shift_Start_Time= cast(CONVERT(VARCHAR(11), In_time, 121)  + CONVERT(VARCHAR(12), @Shift_start_time_Autoshift, 114) as datetime)  from #Data
				where Emp_ID=@Emp_ID_AutoShift and In_time=@In_Time_Autoshift And Shift_ID <> @Shift_ID_Autoshift
				
			End
		else
			Begin
			select @Shift_ID_Autoshift=Shift_ID,@Shift_start_time_Autoshift=Shift_st_time from t0040_shift_master WITH (NOLOCK) where cmp_id=@Cmp_id and isnull(inc_auto_shift,0)=1
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
    set OT_Start_Time=isnull(q.OT_Start_Time,0) ,
    OT_End_Time=isnull(q.OT_End_Time,0)	--Ankit 16112013
 from #data d inner join 
    (select ST.Shift_st_time,ST.Shift_ID,isnull(SD.OT_Start_Time,0) as OT_Start_Time,isnull(SD.OT_End_Time,0) as OT_End_Time from dbo.t0040_shift_master ST WITH (NOLOCK) left outer join dbo.t0050_shift_detail SD WITH (NOLOCK)
    on ST.Shift_ID=SD.Shift_ID where St.Cmp_ID = @Cmp_ID ) q on d.shift_id=q.shift_id where isnull(d.shift_Change,0)=1
 
 ---Commented by Hardik 29/11/2013 for Saudi Arabia, and Put this query in below Weekoff Cursor
 --- Problem is, If Holiday or Weekoff than OT_Start_Time option should not deduct Early coming hours.
 
 --update #Data set Duration_in_sec = Duration_in_sec - datediff(s,In_time,Shift_Start_Time)
 --where datediff(s,In_time,Shift_Start_Time) > 0  And isnull(Emp_OT,0)=1 And isnull(OT_Start_Time,0)=1
 
  Update #Data        
  set Shift_ID   = Q1.Shift_ID,          
   Shift_Type = q1.Shift_type        
  from #Data d inner Join        
  (select sd.shift_ID ,sd.Emp_ID,isnull(shift_type,0)  shift_type,sd.For_Date from dbo.T0100_Emp_Shift_Detail   sd  WITH (NOLOCK)        
  Where Cmp_ID =@Cmp_ID and isnull(shift_type,0)  =1 and For_Date >=@From_Date and For_Date <=@To_Date )q1 on        
  D.emp_ID = q1.For_Date And d.For_Date =Q1.For_Date   


	
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
    Declare @Holiday_days Numeric(18,3)
    Declare @Cancel_Holiday Numeric(18,3)
    DECLARE	@Is_HO_CompOff NUMERIC			--Sid 24/02/2014
	DECLARE	@Is_W_CompOff NUMERIC			--Sid 24/02/2014
    
    
 
	select @Week_oF_Branch=Branch_ID  from dbo.t0095_increment WITH (NOLOCK) where Increment_id in (select Max(Increment_id) from dbo.t0095_increment WITH (NOLOCK) where emp_id=@Emp_Week_Detail)	-- Ankit 12092014 for Same Date Increment
	
 
	Select @Is_Cancel_weekoff = Is_Cancel_weekoff ,@tras_week_ot=isnull(tras_week_ot,0)  ,@Auto_OT = Is_OT_Auto_Calc ,@OT_Present = OT_Present_days,@Is_Negative_Ot = ISNULL(Is_Negative_Ot,0), @Is_Compoff = ISNULL(Is_CompOff, 0), @Is_WD = ISNULL(Is_CompOff_WD,0), @Is_WOHO = ISNULL(Is_CompOff_WOHO,0)
		,@Is_Cancel_Holiday = Is_Cancel_Holiday --Hardik 07/09/2012
		, @Is_HO_CompOff = Is_HO_CompOff			--Sid 24/02/2014
		, @Is_W_CompOff = Is_W_CompOff			--Sid 24/02/2014
		From dbo.T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID and Branch_ID = @Week_oF_Branch    
		and For_Date = ( select max(For_Date) from dbo.T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@To_Date and Branch_ID = @Week_oF_Branch and Cmp_ID = @Cmp_ID)    
	
  
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
		select Emp_Id from #Emp_Cons
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
			
			
			---Added by Hardik 29/11/2013 for Saudi Arabia, Copy this query from above side.		
			update #Data set Duration_in_sec = Duration_in_sec - datediff(s,In_time,Shift_Start_Time)
			where datediff(s,In_time,Shift_Start_Time) > 0  And isnull(Emp_OT,0)=1 And isnull(OT_Start_Time,0)=1
			And For_date not In (Select Data from dbo.Split(@Weekoff_Date1,';') where Data <>'')
			And Emp_Id = @Emp_Id_Temp1 
			
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
		   
		   select @Week_oF_Branch=Branch_ID  from dbo.t0095_increment WITH (NOLOCK)
		   where Increment_id in (select Max(Increment_id) from dbo.t0095_increment WITH (NOLOCK) where emp_id=@Emp_Id_Temp1)	-- Ankit 12092014 for Same Date Increment
			
		 
			Select @tras_week_ot1=isnull(tras_week_ot,0)
				From dbo.T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID and Branch_ID = @Week_oF_Branch    
				and For_Date = ( select max(For_Date) from dbo.T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@To_Date and Branch_ID = @Week_oF_Branch and Cmp_ID = @Cmp_ID)    
			
		               
		   
			if isnull(@Emp_OT1,0)=1 and @tras_week_ot1 = 1 
				Begin
					--Commented By Hardik 07/09/2012
					--Declare @Final_weekoff_str varchar(max)
					--set @Final_weekoff_str=''
					--select @Final_weekoff_str = isnull(Strweekoff,'') from @Emp_WeekOFf_Detail where emp_id=@Emp_Id_Temp1
				
					if charindex(cast(left(@For_date1,11) as varchar),@Weekoff_Date1) >0
						Begin
								
							Update #Data   set Duration_in_sec =0,Ot_sec=dbo.F_Return_Without_Sec(@OT_Sec1+@Duration_in_sec1),P_days=0 
							 where Emp_Id=@Emp_Id_Temp1 and For_date not in (Select Data from dbo.Split(@Half_Holiday_Date,';') where Data <>'')
							And For_Date=@For_date1
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

        
 Declare @Shift_ID  numeric         
 Declare @From_Hour  numeric(12,3)        
 Declare @To_Hour  numeric(12,3)        
 Declare @Minimum_hour numeric(12,3)        
 Declare @Calculate_days numeric(12,3)        
 Declare @OT_applicable numeric(1)        
 Declare @Fix_OT_Hours numeric(12,3)        
 Declare @Shift_Dur  varchar(10)        
 Declare @Shift_Dur_sec numeric         
 Declare @Fix_W_Hours  numeric(5,2)        
 Declare @Ot_Sec_Neg Numeric(18,0)--Nikunj
         
--Ankit 15112013
Declare @DeduHour_SecondBreak as tinyint
Declare @DeduHour_ThirdBreak as tinyint
Declare @S_St_Time as varchar(10)      
Declare @S_End_Time as varchar(10)     
Declare @T_St_Time as varchar(10)      
Declare @T_End_Time as varchar(10)     
Declare @Second_Break_Duration as varchar(10)    
Declare @Third_Break_Duration as varchar(10)
declare @Second_Break_Duration_Sec as numeric      	
declare @Third_Break_Duration_Sec as numeric      	
--Ankit 15112013        
   
   
	 Declare Cur_shift cursor Fast_forward for         
		   select sd.Shift_ID ,From_Hour,To_Hour,Minimum_hour,Calculate_days,OT_applicable,Fix_OT_Hours         
		  ,Shift_Dur ,isnull(Fix_W_Hours,0) as  Fix_W_Hours,
		  DeduHour_SecondBreak,DeduHour_ThirdBreak, S_St_Time,S_End_Time,S_Duration, T_St_Time,T_End_Time,T_Duration        
		   from dbo.T0050_shift_detail sd WITH (NOLOCK) inner join         
		  dbo.T0040_shift_master sm WITH (NOLOCK) on sd.shift_ID= sm.Shift_ID inner join         
		   (select distinct Shift_ID from #Data ) q on sm.shift_Id=  q.shift_ID        
		   order by sd.shift_Id,From_Hour        
	  open cur_shift        
	  fetch next from cur_Shift into @shift_ID,@From_hour,@To_Hour,@Minimum_Hour,@Calculate_Days,@OT_Applicable,@Fix_OT_Hours,@Shift_Dur,@Fix_W_Hours ,@DeduHour_SecondBreak ,@DeduHour_ThirdBreak ,@S_St_Time,@S_End_Time,@Second_Break_Duration,@T_St_Time,@T_End_Time,@Third_Break_Duration        
		  While @@Fetch_Status=0        
		   begin           
		   
			select @Shift_Dur_sec = dbo.F_Return_Sec(@Shift_Dur) 
		    select @Second_Break_Duration_Sec = dbo.F_Return_Sec(@Second_Break_Duration)
			select @Third_Break_Duration_Sec = dbo.F_Return_Sec(@Third_Break_Duration)
			
			IF @DeduHour_SecondBreak = 1 And  @DeduHour_ThirdBreak = 1 
	   			Begin
	   				If @DeduHour_SecondBreak = 1 
						Begin
				 			Update #Data Set Duration_In_Sec = Duration_In_Sec - @Second_Break_Duration_Sec
				 			Where Shift_ID = @Shift_ID 
				 			And In_Time < cast(cast(In_Time as varchar(11)) + ' ' + @S_St_Time as smalldatetime) And OUT_Time > cast(cast(OUT_Time as varchar(11)) + ' ' + @S_St_Time as smalldatetime)
				 			And Duration_in_sec > 0

							-- For Weekoff OT And Holiday OT
				 			Update #Data Set OT_Sec = OT_Sec - @Second_Break_Duration_Sec
				 			Where Shift_ID = @Shift_ID 
				 			And In_Time < cast(cast(In_Time as varchar(11)) + ' ' + @S_St_Time as smalldatetime) And OUT_Time > cast(cast(OUT_Time as varchar(11)) + ' ' + @S_St_Time as smalldatetime)
				 			And Duration_in_sec = 0	And OT_Sec > 0			 			
						End

					If @DeduHour_ThirdBreak = 1 
						Begin
				 			Update #Data Set Duration_In_Sec = Duration_In_Sec - @Third_Break_Duration_Sec
				 			Where Shift_ID = @Shift_ID 
				 			And In_Time < cast(cast(In_Time as varchar(11)) + ' ' + @T_St_Time as smalldatetime) And OUT_Time > cast(cast(OUT_Time as varchar(11)) + ' ' + @T_St_Time as smalldatetime)
				 			And Duration_in_sec > 0

							-- For Weekoff OT And Holiday OT
				 			Update #Data Set OT_Sec = OT_Sec - @Third_Break_Duration_Sec
				 			Where Shift_ID = @Shift_ID 
				 			And In_Time < cast(cast(In_Time as varchar(11)) + ' ' + @T_St_Time as smalldatetime) And OUT_Time > cast(cast(OUT_Time as varchar(11)) + ' ' + @T_St_Time as smalldatetime)
				 			And Duration_in_sec = 0 And OT_Sec > 0
						End
				End	
			Else IF @DeduHour_SecondBreak = 1
				Begin
		 			Update #Data Set Duration_In_Sec = Duration_In_Sec - @Second_Break_Duration_Sec
		 			Where Shift_ID = @Shift_ID 
		 			And In_Time < cast(cast(In_Time as varchar(11)) + ' ' + @S_St_Time as smalldatetime) And OUT_Time > cast(cast(OUT_Time as varchar(11)) + ' ' + @S_St_Time as smalldatetime)
				End
			Else IF @DeduHour_ThirdBreak = 1 
				Begin
		 			Update #Data Set Duration_In_Sec = Duration_In_Sec - @Third_Break_Duration_Sec
		 			Where Shift_ID = @Shift_ID 
		 			And In_Time < cast(cast(In_Time as varchar(11)) + ' ' + @T_St_Time as smalldatetime) And OUT_Time > cast(cast(OUT_Time as varchar(11)) + ' ' + @T_St_Time as smalldatetime)
				End		
				   
		 if @Fix_W_Hours > 0         
			 begin         
					Update #Data        
					set P_Days = @Calculate_Days, Duration_in_sec = dbo.f_return_sec( replace(@Fix_W_Hours,'.',':'))     
					Where Duration_in_sec >=dbo.f_return_sec( replace(@From_hour,'.',':')) and Duration_in_sec <= dbo.f_return_sec( replace(@To_Hour,'.',':'))        
					and Shift_ID= @shift_ID        and IO_Tran_Id  = 0   and chk_by_superior <> 1 -- Changed by rohit on 27122013
					
					
			end        
		 else        
			begin        
					
					Update #Data        
					set P_Days = @Calculate_Days        
					Where Duration_in_sec >= dbo.f_return_sec( replace(@From_hour,'.',':')) and Duration_in_sec <= dbo.f_return_sec( replace(@To_Hour,'.',':'))       
					and Shift_ID= @shift_ID        and IO_Tran_Id  = 0   and chk_by_superior <> 1 -- Changed by rohit on 27122013
					
			end        
		   
		   If @OT_Applicable =1         
			begin            
				
			   if @Fix_OT_Hours > 0         
				   begin        
					
						Update #Data        
						 set P_Days = @Calculate_Days,        
						  OT_Sec = dbo.f_return_sec( replace(@Fix_OT_Hours,'.',':')) 
						   Where Duration_in_sec >=dbo.f_return_sec( replace(@From_hour,'.',':'))and Duration_in_sec <=dbo.f_return_sec( replace(@To_Hour,'.',':'))         
						  and Emp_OT= 1 and Shift_ID= @shift_ID      and IO_Tran_Id  = 0  and chk_by_superior <> 1 -- CHanged by rohit on 27122013 
				   end        
				 else if @Minimum_Hour > 0         
				   begin        
						
						Update #Data        
						 set P_Days = @Calculate_Days,        
						  OT_Sec = dbo.F_Return_Without_Sec(Duration_in_sec - dbo.f_return_sec( replace(@Minimum_Hour,'.',':'))) ,
						  Duration_in_sec=  dbo.f_return_sec( replace(@Minimum_Hour,'.',':'))         
						 Where Duration_in_sec >=dbo.f_return_sec( replace(@From_hour,'.',':')) and Duration_in_sec <=dbo.f_return_sec( replace(@To_Hour,'.',':'))         
						  and Emp_OT= 1 and Shift_ID= @shift_ID         and IO_Tran_Id  = 0  and chk_by_superior <> 1 -- CHanged by rohit on 27122013  
				   end        
				 else if @Minimum_Hour = 0         
					Begin        
						
						Update #Data        
						set P_Days = @Calculate_Days,        
							OT_Sec = dbo.F_Return_Without_Sec(Duration_in_sec - @Shift_Dur_sec)
							--Duration_in_sec= @Shift_Dur_sec -- Comm Ankit 15112013        
							Where Duration_in_sec >=dbo.f_return_sec( replace(@From_hour,'.',':')) and Duration_in_sec <=dbo.f_return_sec( replace(@To_Hour,'.',':'))        
							and Emp_OT= 1 and Duration_in_sec > @Shift_Dur_sec        
							and Shift_ID= @shift_ID    and IO_Tran_Id  = 0  and chk_by_superior <> 1 -- CHanged by rohit on 27122013 
							
							Select @Ot_Sec_Neg=Isnull(Ot_Sec,0)From #Data Where OT_Sec < 1--Nikunj

						If	@Ot_Sec_Neg < 1 And Isnull(@Is_Negative_Ot,0)=1--And Duration_In_sec < @Shift_Dur_sec --logic Of Negative ot			
							Begin					
								Update #Data				
								Set OT_Sec = dbo.F_Return_Without_Sec(@Shift_Dur_sec - Duration_in_sec),Flag=1
								Where Ot_Sec < 1 And Duration_In_sec < @Shift_Dur_sec And Shift_Id = @Shift_Id And Emp_OT= 1										
							End    
					  
					 end              
					 
					 
					 
			end        
		  fetch next from cur_Shift into @shift_ID,@From_hour,@To_Hour,@Minimum_Hour,@Calculate_Days,@OT_Applicable,@Fix_OT_Hours,@Shift_Dur,@Fix_W_Hours,@DeduHour_SecondBreak ,@DeduHour_ThirdBreak ,@S_St_Time,@S_End_Time,@Second_Break_Duration,@T_St_Time,@T_End_Time,@Third_Break_Duration         
		  end        
	close cur_Shift        
 Deallocate Cur_Shift         

----Add by Sid for OT Rounding off 21/05/2014 -----------------------------

Declare @OT_Emp numeric,
		@OT_Branch numeric,
		@OT_RoundingOff_To as numeric(18,2),
		@OT_RoundingOff_Lower as numeric

declare OTRoundCur Cursor for
select distinct emp_id from #Data 
open OTRoundCur
fetch next from OTRoundCur into @OT_Emp
while @@fetch_status = 0
begin
	select @OT_Branch = Branch_ID from T0095_INCREMENT t1 WITH (NOLOCK) inner join (select emp_id,max(Increment_ID) as Increment_ID from t0095_increment WITH (NOLOCK) group by emp_id) t2-- Ankit 12092014 for Same Date Increment
	on t1.emp_id = t2.Emp_ID and t1.Increment_ID = t2.Increment_ID 
	where t1.emp_id = @ot_Emp

	select @OT_RoundingOff_To = OT_RoundingOff_To, @OT_RoundingOff_Lower = OT_RoundingOff_Lower from T0040_GENERAL_SETTING WITH (NOLOCK) where branch_id = @OT_Branch 
	and For_Date = (select max(for_date) From T0040_General_Setting WITH (NOLOCK) where Branch_ID =@OT_Branch)  --Modified By Ramiz on 16092014
	
	if @ot_Roundingoff_to > 0
	begin
		if @ot_roundingoff_lower = 0
		begin
			update #Data
			set OT_Sec = (floor((cast(OT_Sec as float)/cast(3600 as float))*(1/@OT_RoundingOff_To))/(1/@OT_Roundingoff_To))*3600
			where emp_id = @OT_Emp
		end
		else if @OT_Roundingoff_lower = 1
		begin
			update #Data
			set OT_Sec = (ceiling((cast(OT_Sec as float)/cast(3600 as float))*(1/@OT_RoundingOff_To))/(1/@OT_Roundingoff_To))*3600
			where emp_id = @OT_Emp
		end
		else
		begin
			begin
			update #Data
			set OT_Sec = (round((cast(OT_Sec as float)/cast(3600 as float))*(1/@OT_RoundingOff_To),0)/(1/@OT_Roundingoff_To))*3600
			where emp_id = @OT_Emp
		end
		end
	end
	fetch next from OTRoundCur into @OT_Emp
end
close OTRoundCur
deallocate OTRoundCur

----Add by Sid 21/05/2014 Ends 


 
--------------------Added by Mitesh on 15/09/2011 for Shift Half Day ----------------------------
	
	declare @ShiftId numeric
	declare @WeekDay varchar(10)
	declare @HalfStartTime varchar(10)
	declare @HalfEndTime varchar(10)
	declare @HalfDuration varchar(10)
	declare @HalfDayDate varchar(max)
	declare @curForDate datetime
	declare @HalfMinDuration varchar(10)



 ---Hardik 07/09/2012 for Weekoff1 Cursor
	declare curweekoff1 cursor Fast_forward for                    
		select Emp_Id from #Emp_Cons
	open curweekoff1                      
	fetch next from curweekoff1 into @Emp_Id_Temp1
	while @@fetch_status = 0                    
	begin  
	
			exec dbo.GET_HalfDay_Date @Cmp_ID,@Emp_Id_Temp1,@From_Date,@To_Date,0,@HalfDayDate output
			
			select @ShiftId=SM.Shift_id,@WeekDay=SM.Week_Day,@HalfStartTime=SM.Half_St_Time,@HalfEndTime=SM.Half_End_Time,@HalfDuration=SM.Half_Dur,@HalfMinDuration=SM.Half_min_duration from dbo.T0040_SHIFT_MASTER SM WITH (NOLOCK) inner join         
					   (select distinct Shift_ID from #Data where Emp_Id = @Emp_Id_Temp1) q on SM.Shift_ID =  q.shift_ID        
					where Is_Half_Day = 1 
			
			
			declare cur_shift_half_day cursor Fast_forward for
					Select For_date from #Data 
					Where Emp_Id = @Emp_Id_Temp1 And For_Date In (Select Data from dbo.Split(@HalfDayDate,';') where DATA<>'') --Hardik 07/09/2012 Where Condition
			OPEN cur_shift_half_day        
			fetch next from cur_shift_half_day into @curForDate
			  While @@Fetch_Status=0        
				   BEGIN
						
						if(charindex(CONVERT(nvarchar(11),@curForDate,109),@HalfDayDate) > 0)
							begin			
							
								-- Comment by rohit for week of regularization not calculate in present if Week off Work transfer to ot on 12082013
									update #Data 
									set P_days = 1 , in_time = convert(varchar(11),d.For_date,120) + @HalfStartTime,out_time = convert(varchar(11),d.For_date,120) + @HalfEndTime,duration_in_sec = dbo.F_Return_Sec(@HalfMinDuration)  from #Data d inner join  dbo.T0150_EMP_INOUT_RECORD TEIR 
									on TEIR.Emp_Id = d.Emp_Id and TEIR.Chk_By_Superior = 1 and TEIR.For_Date = d.For_date and TEIR.Half_Full_day = 'Full Day' 
									where TEIR.For_Date = @curForDate  and d.IO_Tran_Id  = 0 and TEIR.emp_id = @Emp_Id_Temp1
								-- Ended by rohit on 12082013	
 
										
								update #Data  set
									Shift_Start_Time = convert(varchar(11),@curForDate,120) + @HalfStartTime							
									where For_date = @curForDate
								
															
								update #Data  set
									P_days = 1
									where For_date = @curForDate and Duration_in_sec >= dbo.F_Return_Sec(@HalfMinDuration)   and IO_Tran_Id  = 0 And Emp_Id = @Emp_Id_Temp1
									
								update #Data  set
									P_days = 0
									where For_date = @curForDate and Duration_in_sec < dbo.F_Return_Sec(@HalfMinDuration)   and IO_Tran_Id  = 0 And Emp_Id = @Emp_Id_Temp1

									
								Update #Data        
								 set OT_Sec = OT_Sec +
								 dbo.F_Return_Without_Sec(case when dbo.F_Return_Sec(@HalfMinDuration) > Duration_in_sec then
									dbo.F_Return_Sec(@HalfMinDuration) - Duration_in_sec         
								 Else
									Duration_in_sec - dbo.F_Return_Sec(@HalfMinDuration)  
								 End )
								 Where Duration_in_sec >=dbo.F_Return_Sec(@HalfMinDuration)
								 and Emp_OT= 1 and For_date = @curForDate And Emp_Id = @Emp_Id_Temp1

								 
								 	-- Added by rohit for week of regularization not calculate in present if Week off Work transfer to OT on 12082013

								 	update #Data 
									set P_days = 0.5,in_time = convert(varchar(11),d.For_date,120) + @HalfStartTime,out_time = (convert(varchar(11),d.For_date,120) + dbo.F_Return_Hours(dbo.F_Return_Sec(@HalfStartTime) + (dbo.F_Return_Sec(@HalfMinDuration))/2)),duration_in_sec = dbo.F_Return_Sec(@HalfMinDuration)/2   from #Data d inner join  dbo.T0150_EMP_INOUT_RECORD TEIR 
									on TEIR.Emp_Id = d.Emp_Id and TEIR.Chk_By_Superior = 1 and TEIR.For_Date = d.For_date and ( TEIR.Half_Full_day = 'First Half')
									where TEIR.For_Date = @curForDate and d.IO_Tran_Id  = 0 and TEIR.emp_id = @Emp_Id_Temp1
									
									update #Data 
									set P_days = 0.5,in_time = (convert(varchar(11),d.For_date,120) + dbo.F_Return_Hours(dbo.F_Return_Sec(@HalfStartTime) + (dbo.F_Return_Sec(@HalfMinDuration))/2)),out_time = convert(varchar(11),d.For_date,120) + @HalfEndTime ,duration_in_sec = dbo.F_Return_Sec(@HalfMinDuration)/2 from #Data d inner join  dbo.T0150_EMP_INOUT_RECORD TEIR 
									on TEIR.Emp_Id = d.Emp_Id and TEIR.Chk_By_Superior = 1 and TEIR.For_Date = d.For_date and ( TEIR.Half_Full_day = 'Second Half')
									where TEIR.For_Date = @curForDate and d.IO_Tran_Id  = 0  and TEIR.emp_id = @Emp_Id_Temp1
									--Ended by rohit 12082013
									
							end
				   fetch next from cur_shift_half_day into @curForDate
				   END
			close cur_shift_half_day        
			Deallocate cur_shift_half_day  	   

			fetch next from curweekoff1 into @Emp_Id_Temp1
		end                    
 close curweekoff1                    
 deallocate curweekoff1   	   
	---- start below update statment added by mitesh for regularization as only full day on 09/01/2012.
	
	-- Comment by rohit for  week of regularization not calculate in present if Week off Work Transfer to OT on 12082013
	--update #Data 
	--set P_days = 1 from #Data d inner join  dbo.T0150_EMP_INOUT_RECORD TEIR 
	--on TEIR.Emp_Id = d.Emp_Id and TEIR.Chk_By_Superior = 1 and TEIR.For_Date = d.For_date and TEIR.Half_Full_day = 'Full Day' 
	--where TEIR.For_Date >= @From_Date and TEIR.For_Date <= @To_Date   and d.IO_Tran_Id  = 0 
	
	
	--update #Data 
	--set P_days = 0.5 from #Data d inner join  dbo.T0150_EMP_INOUT_RECORD TEIR 
	--on TEIR.Emp_Id = d.Emp_Id and TEIR.Chk_By_Superior = 1 and TEIR.For_Date = d.For_date and ( TEIR.Half_Full_day = 'First Half' or TEIR.Half_Full_day = 'Second Half')
	--where TEIR.For_Date >= @From_Date and TEIR.For_Date <= @To_Date   and d.IO_Tran_Id  = 0 
	 --Comment end by rohit 12082013
	
	update dbo.#Data 
	set P_days = (P_days - 0.5) from #Data d inner join  
				(select For_Date,Emp_ID from dbo.T0140_LEAVE_TRANSACTION WITH (NOLOCK)
					where leave_used = 0.5 and 
					For_Date >= @From_Date and 
					For_Date <= @To_Date and (isnull(eff_in_salary,0) <> 1 
					or (isnull(eff_in_salary,0) = 1 and Leave_Used > 0)
					)) Qry on 
				Qry.For_Date = d.For_date and Qry.Emp_ID = d.Emp_Id where    IO_Tran_Id  = 0 and P_days =1
	
	-- Comment and Added by rohit on 08092014
	--Alpesh 06-Jul-2012 -> If Leave is paid then count as Leave, Not as Present 			 
	--update dbo.#Data 
	--set P_days = 0 from #Data d inner join  
	--	(select For_Date,Emp_ID from dbo.T0140_LEAVE_TRANSACTION lt inner join dbo.T0040_LEAVE_MASTER lm on lm.Leave_ID=lt.Leave_ID
	--	 where leave_used = 1 and For_Date >= @From_Date and For_Date <= @To_Date and lm.Leave_Paid_Unpaid='P') Qry 
	--	 on Qry.For_Date = d.For_date and Qry.Emp_ID = d.Emp_Id where IO_Tran_Id  = 0
	---- End ----
	---- end below update statment added by mitesh for regularization as only full day on 09/01/2012.
 
 
 update #Data
	set P_days = (1 - lt.leave_used)
	from #Data d
	left outer join (select emp_id,for_date,sum(case when lm.Apply_hourly = 0 then lt.leave_used else lt.leave_used*0.125 end) as Leave_Used
	from T0140_LEAVE_TRANSACTION lt WITH (NOLOCK) inner join T0040_LEAVE_MASTER lm WITH (NOLOCK) on lt.Leave_ID = lm.Leave_ID where For_Date between @From_Date and @To_Date and lm.Leave_Paid_Unpaid='P' group by Emp_ID,For_Date) as lt on
	d.emp_id = lt.emp_ID and d.for_date = lt.for_date
	Where d.P_days + lt.leave_used > 1
 
 -- Ende
--------------------Added by Mitesh on 15/09/2011 for Shift Half Day ----------------------------
    
    update #Data         
   set OT_Sec = isnull(Approved_OT_Sec,0) -- * 3600        
    from #Data  d inner join dbo.T0160_OT_Approval OA on d.emp_ID = Oa.Emp_ID and d.For_Date = oa.For_Date and Is_Month_Wise = 0        
           
  Update #Data        
   set OT_Sec = 0         
   where Emp_OT_Min_Limit >= OT_sec and OT_sec > 0        
        
  Update #Data        
   set OT_Sec = Emp_OT_Max_Limit        
  where OT_sec  > Emp_OT_Max_Limit  and Emp_OT_Max_Limit > 0 and OT_sec >0    
  
  
---Add by Hardik for Diferentiate Weekoff OT And Holiday OT 

 --Declare @Is_Cancel_Holiday  Numeric(1,0)    
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
	From dbo.T0040_GENERAL_SETTING WITH (NOLOCK) 
	Where cmp_ID = @cmp_ID and Branch_ID = @Branch_ID    
	and For_Date = (select max(For_Date) from dbo.T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@To_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)    
	
	
	Declare @Split_Shift_Count Numeric --Hardik 12/08/2013 for Split Shift
	Set @Split_Shift_Count = 0
	
	--Hardik 22/11/2013 for Saudi Arabia
	Declare @Shift_End_Time_Temp as Datetime
	Declare @Diff_Sec as Numeric
	DECLARE @OT_Start_Time AS NUMERIC 
		
	Declare Cur_HO cursor Fast_forward for
		Select Emp_Id,For_Date, Shift_End_Time from #Data --Where OT_Sec > 0
	open Cur_HO
	fetch next from Cur_HO into @Emp_Id_Cur,@For_Date,@Shift_End_Time_Temp
	While @@Fetch_Status=0
	   begin
	   
		--- Added By Hardik 10/08/2013 for Split Shift Count and Dates for Azure Client
		Declare @Is_Split_Shift as tinyint
		Declare @In_Time Datetime
		Declare @Out_Time Datetime
		Declare @First_Working_Sec Numeric
		Declare @Split_Shift_Allow Numeric(18,2)
		Declare @Split_Shift_Ratio Numeric(18,2)
		
		Declare @Shift_Second_St_Time Datetime
		Declare @Shift_Second_End_Time Datetime
		Declare @Shift_Second_Sec Numeric
		Declare @Shift_Third_St_Time Datetime
		Declare @Shift_Third_End_Time Datetime
		Declare @Shift_Third_Sec Numeric

		Set @Is_Split_Shift = 0
		Set @In_Time = Null
		Set @Out_Time = Null
		Set @Shift_Second_St_Time = Null
		Set @Shift_Second_End_Time = Null
		Set @Shift_Third_St_Time = Null
		Set @Shift_Third_End_Time = Null
		Set @Shift_Second_Sec = 0
		Set @Shift_Third_Sec = 0
		Set @First_Working_Sec = 0
		Set @Split_Shift_Allow = 0
		Set @Split_Shift_Ratio = 0
		Set @Split_Shift_Count = 0
		
		--Hardik 22/11/2013 for Saudi Arabia
		Set @Diff_Sec = 0
		
		
		
		Select @Is_Split_Shift = Is_Split_Shift,
			@Split_Shift_Allow = S.Split_Shift_Rate, @Split_Shift_Ratio = Split_Shift_Ratio,
			@Shift_Second_St_Time = Cast(@For_Date + ' ' + S.S_St_Time as Datetime), 
			@Shift_Second_End_Time = Cast(@For_Date + ' ' + S.S_End_Time as Datetime),
			@Shift_Second_Sec = DATEDIFF(SS,@Shift_Second_St_Time,@Shift_Second_End_Time),
			@Shift_Third_St_Time = Cast(@For_Date + ' ' + S.T_St_Time as Datetime), 
			@Shift_Third_End_Time = Cast(@For_Date + ' ' + S.T_End_Time as Datetime),
			@Shift_Third_Sec = DATEDIFF(SS,@Shift_Third_St_Time,@Shift_Third_End_Time)
		From T0040_SHIFT_MASTER S WITH (NOLOCK) Inner Join #Data D on S.Shift_ID = D.Shift_ID 
		Where For_date = @For_Date And Emp_Id = @Emp_Id_Cur


		If @Is_Split_Shift = 1 And @Is_Split_Shift_Req = 1 
			Begin
				Declare Cur_Split cursor Fast_forward for
					Select In_Time, Out_Time From T0150_EMP_INOUT_RECORD WITH (NOLOCK) Where For_Date = @For_Date And Emp_ID = @Emp_Id_Cur
				open Cur_Split
				fetch next from Cur_Split into @In_Time,@Out_Time
				While @@Fetch_Status=0
					begin
						if DATEADD(MINUTE,-90,@Shift_Second_St_Time) <= @In_Time and DATEADD(MINUTE,90,@Shift_Second_End_Time) >= @Out_Time
							begin
								If @Shift_Second_St_Time > @In_Time
									Set @In_Time = @Shift_Second_St_Time
								
								If @Shift_Second_End_Time < @Out_Time
									Set @Out_Time = @Shift_Second_End_Time

								If @Shift_Second_Sec < Datediff(SS,@In_Time,@Out_Time)
									Begin
										Set @First_Working_Sec = @First_Working_Sec + @Shift_Second_Sec
									End
								Else
									Begin
										Set @First_Working_Sec = @First_Working_Sec + Datediff(SS,@In_Time,@Out_Time)
									End
							end
						else if DATEADD(MINUTE,-90,@Shift_Third_St_Time) <= @In_Time and DATEADD(MINUTE,90,@Shift_Third_End_Time) >= @Out_Time
							begin
								If @Shift_Third_St_Time > @In_Time
									Set @In_Time = @Shift_Third_St_Time
								
								If @Shift_Third_End_Time < @Out_Time
									Set @Out_Time = @Shift_Third_End_Time
							
								If @Shift_Third_Sec < Datediff(SS,@In_Time,@Out_Time)
									Begin
										Set @First_Working_Sec = @First_Working_Sec + @Shift_Second_Sec
									End
								Else
									Begin
										Set @First_Working_Sec = @First_Working_Sec + Datediff(SS,@In_Time,@Out_Time)
									End
							end
					
						fetch next from Cur_Split into @In_Time,@Out_Time
					End
				close Cur_Split
				deallocate Cur_Split					
				
			If (@First_Working_Sec / (@Shift_Second_Sec + @Shift_Third_Sec))*100 >= @Split_Shift_Ratio 
				Begin
				
					If Not Exists(Select 1 From #Split_Shift_Table Where Emp_Id = @Emp_Id_Cur)
						Begin
							Insert Into #Split_Shift_Table 
								(Emp_Id, Split_Shift_Count, Split_Shift_Dates,Split_Shift_Allow)
							Values
								(@Emp_ID,1,Cast(@For_Date As Varchar(11)),@Split_Shift_Allow)
						End
					Else
						Begin
							Update #Split_Shift_Table Set
								Split_Shift_Count =  Split_Shift_Count + 1,
								Split_Shift_Dates = Split_Shift_Dates +';'+ Cast(@For_Date As Varchar(11)),
								Split_Shift_Allow = Split_Shift_Allow + @Split_Shift_Allow
							Where Emp_Id = @Emp_Id_Cur
						End				
				End
				
			End

			--select @First_Working_Sec,dbo.F_Return_Hours(@first_working_sec),(@First_Working_Sec / (@Shift_Second_Sec + @Shift_Third_Sec))*100
			


		--- End By Hardik 10/08/2013 for Split Shift Count and Dates for Azure Client
		
		Select @Branch_ID = I.Branch_ID  from dbo.T0095_Increment I WITH (NOLOCK) inner join         
		( select max(Increment_ID) as Increment_ID , Emp_ID From dbo.T0095_Increment WITH (NOLOCK)       -- Ankit 12092014 for Same Date Increment
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
				    			
				    --Update #Data Set OT_Sec = 0, Holiday_OT_Sec = OT_Sec Where For_date = @For_Date And Emp_Id = @Emp_Id_Cur	
						Declare @Trans_Week_OT as tinyint   
						set @Trans_Week_OT = 0
					    Select @Trans_Week_OT = isnull(Tras_Week_OT,0)
						From dbo.T0040_GENERAL_SETTING WITH (NOLOCK)
						Where cmp_ID = @cmp_ID and Branch_ID = @Branch_ID    
						and For_Date = (select max(For_Date) from dbo.T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@To_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)    
					
					declare @shift_Work_time_Sec as numeric(18,2)
					set @shift_Work_time_Sec = 0
					if @tras_week_ot = 1 
					begin
						 Update #Data Set OT_Sec = 0, Holiday_OT_Sec = OT_Sec from #Data as data_t inner join
 							#Emp_Holiday EH on EH.Emp_ID = Data_t.Emp_ID and EH.For_Date = Data_t.For_date 			
							Where data_t.For_date = @For_Date And Data_t.Emp_Id = @Emp_Id_Cur and is_Half_Day = 0
				
						select @shift_Work_time_Sec =  Duration_In_Sec - (DATEDIFF(S,Shift_Start_Time,Shift_End_Time)/2) from #Data 
							Where For_date = @For_Date And Emp_Id = @Emp_Id_Cur and isnull(Emp_OT,0) = 1
							
							Update #Data Set OT_Sec = 0, Holiday_OT_Sec = @shift_Work_time_Sec, P_days = P_days - 0.5 from #Data as data_t inner join
 					#Emp_Holiday EH on EH.Emp_ID = Data_t.Emp_ID and EH.For_Date = Data_t.For_date 			
					Where data_t.For_date = @For_Date And Data_t.Emp_Id = @Emp_Id_Cur and is_Half_Day = 1 and P_days = 1
					
					end
					
					
				end
			
			--Hardik 22/11/2013 for OT Start From Shift End time for Multiple In Out Saudi Arabia
			If @First_In_Last_Out_For_InOut_Calculation = 0
				Begin
					
					----Commented and added by Sid for OT Hours before shift time where "OT Start from Shift Start time" is not ticked in Shift Master
					/*Select @Diff_Sec =  SUM(Diff_Sec) From (
						Select Case When Row =1 then
							DATEDIFF(s,@Shift_End_Time_Temp,Out_Time)
						 Else 
							DATEDIFF(s,In_Time,Out_Time)
						 End as Diff_Sec From 
						(select ROW_NUMBER() 
								OVER (ORDER BY IO_Tran_Id) AS Row, 
								* from T0150_EMP_INOUT_RECORD where Emp_ID = @Emp_Id_Cur
						and (In_Time >= @Shift_End_Time_Temp or Out_Time >= @Shift_End_Time_Temp)
						and For_Date = @For_Date And Emp_ID = @Emp_Id_Cur) as Qry) as Qry1	*/
						
				SELECT @ot_start_time = OT_Start_Time,@shift_st_time = Shift_start_time FROM #data
				WHERE FOR_DATE = @for_date
				AND Emp_Id = @Emp_ID_Cur
				
				
				
				SELECT	@Diff_Sec = SUM(Diff_Sec)
				FROM	(SELECT	CASE WHEN Row = 1 
								THEN 
									CASE WHEN @Shift_End_Time_Temp < out_time 
									THEN DATEDIFF(s, @Shift_End_Time_Temp,Out_Time) 
									ELSE 0 
								END + CASE WHEN @OT_Start_Time = 0 
										THEN 
											CASE WHEN in_time < @shift_St_Time 
											THEN DATEDIFF(SECOND,in_time,@shift_St_Time) 
											ELSE 0 END
										ELSE 0 END 
									 ELSE DATEDIFF(s, In_Time, Out_Time)
								END AS Diff_Sec
						 FROM	(SELECT	ROW_NUMBER() OVER (ORDER BY IO_Tran_Id)
										AS Row, *
								 FROM	T0150_EMP_INOUT_RECORD WITH (NOLOCK)
								 WHERE	Emp_ID = @Emp_Id_Cur AND (In_Time <= @Shift_St_Time OR Out_Time >= @Shift_End_Time_Temp) 
								 AND For_Date = @For_Date AND Emp_ID = @Emp_Id_Cur)
								AS Qry) AS Qry1	
				
				
				------Added by Sid Ends.

				
					Update #Data Set OT_Sec = @Diff_Sec 
					Where For_date = @For_Date And Emp_Id = @Emp_Id_Cur
						And OT_End_Time = 1 And Weekoff_OT_Sec = 0 And Holiday_OT_Sec = 0
						And isnull(Emp_OT,0)=1
				End	
				
		 fetch next from Cur_HO into @Emp_Id_Cur,@For_Date,@Shift_End_Time_Temp
	  end        
	close Cur_HO        
	Deallocate Cur_HO   
------------ End By Hardik for OT

	--Hardik 22/11/2013 for OT Start From Shift End time for Saudi Arabia
	If @First_In_Last_Out_For_InOut_Calculation = 1
		Begin
		
			if isnull(@Chk_otLimit_before_after_Shift_time,0) = 0 
			begin
			Update #Data Set OT_Sec = DATEDIFF(s,Shift_End_Time,OUT_Time) 
			 Where OT_End_Time = 1 And OUT_Time >= Shift_End_Time And Weekoff_OT_Sec = 0 And Holiday_OT_Sec = 0
			 And isnull(Emp_OT,0)=1

		----Added by Sid for OT Hours before shift time where "OT Start from Shift Start time" is not ticked in Shift Master
			 
			UPDATE	#Data
			SET		OT_Sec = OT_Sec + DATEDIFF(s, In_Time, Shift_Start_Time) 
			WHERE	OT_Start_Time = 0 AND In_Time <= Shift_Start_Time AND Weekoff_OT_Sec = 0 AND Holiday_OT_Sec = 0 AND ISNULL(Emp_OT,0) = 1
																	  
		----Added by Sid Ends
			END
			BEGIN
			
			Update #Data Set OT_Sec = DATEDIFF(s,Shift_End_Time,OUT_Time) 
			 Where OT_End_Time = 1 And OUT_Time >= Shift_End_Time And Weekoff_OT_Sec = 0 And Holiday_OT_Sec = 0
			 And isnull(Emp_OT,0)=1 and DATEDIFF(s,Shift_End_Time,OUT_Time) > Emp_ot_min_limit
			 
			UPDATE	#Data
			SET		OT_Sec = OT_Sec + DATEDIFF(s, In_Time, Shift_Start_Time) 
			WHERE	OT_Start_Time = 0 AND In_Time <= Shift_Start_Time AND Weekoff_OT_Sec = 0 AND Holiday_OT_Sec = 0 AND ISNULL(Emp_OT,0) = 1 and DATEDIFF(s, In_Time, Shift_Start_Time) > Emp_ot_min_limit

			END
		End
		

 -----Hardik 07/09/2012 for Weekoff1 Cursor
	--declare curweekoff1 cursor Fast_forward for                    
	--	select Emp_Id from #Data Group by Emp_Id
	--open curweekoff1                      
	--fetch next from curweekoff1 into @Emp_Id_Temp1
	--while @@fetch_status = 0                    
	--begin  
	--		Select @Week_oF_Branch= Branch_ID  from dbo.t0095_increment where Increment_id in (select Max(Increment_id) from dbo.t0095_increment where emp_id=@Emp_Id_Temp1)

			
	--		Select @Is_Compoff = ISNULL(Is_CompOff,0),@Trans_Weekoff_OT = Isnull(Tras_Week_OT,0)
	--		From dbo.T0040_GENERAL_SETTING where cmp_ID = @cmp_ID and Branch_ID = @Week_oF_Branch    
	--		and For_Date = ( select max(For_Date) from dbo.T0040_GENERAL_SETTING where For_Date <=@To_Date and Branch_ID = @Week_oF_Branch and Cmp_ID = @Cmp_ID)

	--		 If(@Is_Compoff = 1) or @Trans_Weekoff_OT = 1 -- Added by Mihir Trivedi on 31/05/2012 for present days updation related to comp-off
	--			BEGIN
	--				Declare @strwoff as Varchar(Max)
	--				Declare @A_strwoff as varchar(20)
	--				Declare @D_EmpID as Numeric
	--				Declare @F_Date as Varchar(11)
	--				--Declare @Weekoff_EmpID as numeric
	--				Select @strwoff = Replace(ISNULL(Strweekoff,''),';',',') from
	--				@Emp_WeekOFf_Detail Where Emp_ID = @Emp_Id_Temp1
				
	--				--Declare curapp cursor Fast_forward for
	--				--	select Data from dbo.Split(@strwoff, ',') where Data <> ''
	--				--Open curapp
	--				--	Fetch Next from curapp into @A_strwoff
	--				--WHILE @@FETCH_STATUS = 0
	--				--	BEGIN					
	--						Declare curfinal cursor Fast_forward for
	--							Select Emp_ID, For_date from #Data
	--							Where For_Date In (Select Data from dbo.Split(@strwoff, ',') where Data <> '')
	--							And Emp_Id = @Emp_Id_Temp1
	--						Open curfinal 
	--							Fetch Next from curfinal into @D_EmpID, @F_Date
	--						WHILE @@FETCH_STATUS = 0
	--							BEGIN						

	--								--IF(@F_Date = @A_strwoff and @D_EmpID = @Emp_Id_Temp1)
	--								if charindex(cast(@F_Date as varchar(11)),@StrWeekoff_Date_OT,0) > 0 --Change By hardik 07/09/2012
	--									BEGIN
	--										Update #Data 
	--										Set P_days = 0.0
	--										Where For_date = @F_Date And Emp_Id = @Emp_Id_Temp1
	--										--Where CAST(For_date as varchar(11)) = @A_strwoff and Emp_Id = @Emp_Id_Temp1 --Commented by Hardik 07/09/2012
	--									END
	--								Fetch Next from curfinal into @D_EmpID, @F_Date
	--							END
	--						Close curfinal
	--						Deallocate curfinal
	--						--Fetch next from curapp into @A_strwoff 
	--				--	END
	--				--Close curapp
	--				--Deallocate curapp
	--			END
	--		fetch next from curweekoff1 into @Emp_Id_Temp1
	--	end                    
 --close curweekoff1                    
 --deallocate curweekoff1   	   
	--------End of Added by Mihir Trivedi on 31/05/2012
	
  if @Return_Record_set =2   or @Return_Record_set =5 or @Return_Record_set = 8 OR @Return_Record_set = 9 OR @Return_Record_set = 10 OR @Return_Record_set = 11 OR @Return_Record_set = 12 --or @Return_Record_set = 7        
   begin
    CREATE TABLE #Data_Temp         
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
		   OT_Sec  numeric default 0,
		   In_Time datetime,
		   Shift_Start_Time  datetime,
           OT_Start_Time numeric default 0,
           Shift_Change tinyint default 0,
           Flag int default 0       ,
		   Weekoff_OT_Sec Numeric Default 0,
		   Holiday_OT_Sec Numeric Default 0   ,
		   Chk_By_Superior numeric default 0,
		   IO_Tran_Id	   numeric default 0,
		   OUT_Time datetime,
		   Shift_End_Time datetime,			--Ankit 16112013
		   OT_End_Time numeric default 0,	--Ankit 16112013
		   Working_Hrs_St_Time tinyint default 0, --Hardik 14/02/2014
		   Working_Hrs_End_Time tinyint default 0 --Hardik 14/02/2014
       )    
       
              
	-- Added by rohit on 26082013
       
         declare @Emp_ID_W numeric
         Declare @For_date_W Datetime
       
       
         
        DECLARE OT_Emp CURSOR  
        FOR  
           SELECT Emp_ID FROM #Emp_Cons 
           --inner join
           --t0160_Ot_Approval t  on d.Emp_ID = t.Emp_ID And d.For_Date = t.For_Date -- Added Inner join by Hardik 10/09/2012
         OPEN OT_Emp  
          fetch next from OT_Emp into @Emp_ID_W
          while @@fetch_status = 0  
         BEGIN  
         Declare @StrWeekoff_Date_W varchar(max)
         declare @Weekoff_Days_W varchar(max)
         declare @Cancel_Weekoff_w varchar(max)
         declare @StrHoliday_Date_W varchar(max)
         declare @Holiday_days_W varchar(max)
         declare @Cancel_Holiday_W varchar (max)
         
         declare @OD_transfer_to_ot numeric(1,0)
         Declare @Branch_id_OD numeric (4,0)
         
         select @BRANCH_ID_OD =	Branch_id from t0095_increment  WITH (NOLOCK)
         where Increment_ID =( select max(Increment_ID) from t0095_increment WITH (NOLOCK) where emp_id=@Emp_ID_W and increment_effective_date <=@To_Date) and emp_id=@Emp_ID_W	-- Ankit 12092014 for Same Date Increment
         
         select @OD_transfer_to_ot = Is_OD_Transfer_to_OT from t0040_general_setting WITH (NOLOCK) where branch_id = @BRANCH_ID_OD and 
         For_Date = (select max(for_date) From T0040_General_Setting WITH (NOLOCK) where Branch_ID =@BRANCH_ID_OD)  --Added By Ramiz on 16092014
         
         
         if @OD_transfer_to_ot = 1 
         begin
         Exec dbo.SP_EMP_HOLIDAY_DATE_GET1 @Emp_Week_Detail,@Cmp_ID,@From_Date,@To_Date,null,null,@Is_Cancel_Holiday,@StrHoliday_Date_W output,@Holiday_days_W output,@Cancel_Holiday_W output,0,@Branch_ID,@StrWeekoff_Date_W
         Exec dbo.SP_EMP_WEEKOFF_DATE_GET1 @Emp_ID_W,@Cmp_ID,@From_Date,@To_Date,null,null,@Is_Cancel_weekoff,'',@StrWeekoff_Date_W output,@Weekoff_Days_W output ,@Cancel_Weekoff_w output,@constraint=''
         
         
         
				     DECLARE OT_For_Date CURSOR  
						 FOR  							
							select  cast(data  as Datetime) as For_date  from dbo.Split ( (@StrHoliday_Date_W) ,';') 
							--select inactive_effective_date from t0040_leave_master
							OPEN OT_For_Date
							fetch next from OT_For_Date into @For_date_W
							while @@fetch_status = 0  
							BEGIN  
						

							if Not Exists(select Tran_Id from dbo.t0160_Ot_Approval WITH (NOLOCK) where Emp_ID=@Emp_ID_W And For_Date=@For_date_W)  
								   Begin  
										insert into #Data_Temp   
											(Emp_Id,For_date,Duration_in_sec,Shift_ID,Shift_Type,Emp_OT ,Emp_OT_min_Limit,Emp_OT_max_Limit,P_days,OT_Sec,In_Time,Shift_Start_Time,OT_Start_Time ,Shift_Change,Flag ,Weekoff_OT_Sec ,Holiday_OT_Sec ,Chk_By_Superior ,IO_Tran_Id ,OUT_Time )
									select LA.Emp_id,@For_date_W,		0,	0,			0,			1,		0,				0,				0,		0,	@For_date_W,@For_date_W,		0,			0,			0,	0,case when lad.half_leave_date =@For_date_W then 28920/2 else  28920 end ,				0,				0,		@For_date_W
									from T0120_LEAVE_APPROVAL LA WITH (NOLOCK) inner join 
									T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) on LA.Leave_Approval_ID =LAD.Leave_Approval_ID inner join
									T0040_LEAVE_MASTER LM WITH (NOLOCK) on LAD.leave_id = LM.leave_id 
									where Leave_Type='Company Purpose' and @for_date_W >= LAD.From_date and @for_date_W <= LAD.To_Date and Emp_id = @Emp_ID_W
									
								   End  


							fetch next from OT_For_Date into @For_date_W
							END  
							CLOSE OT_For_Date
							DEALLOCATE OT_For_Date
							
						DECLARE OT_For_Date CURSOR  
						 FOR  							
							select  cast(data  as Datetime) as For_date  from dbo.Split ( (@StrWeekoff_Date_W) ,';') where cast(data as datetime) not in (select  cast(data  as Datetime) as For_date  from dbo.Split ( (@StrHoliday_Date_W) ,';') )
							--select inactive_effective_date from t0040_leave_master
							OPEN OT_For_Date
							fetch next from OT_For_Date into @For_date_W
							while @@fetch_status = 0  
							BEGIN  
						

							if Not Exists(select Tran_Id from dbo.t0160_Ot_Approval WITH (NOLOCK) where Emp_ID=@Emp_ID_W And For_Date=@For_date_W)  
								   Begin  
										insert into #Data_Temp   
											(Emp_Id,For_date,Duration_in_sec,Shift_ID,Shift_Type,Emp_OT ,Emp_OT_min_Limit,Emp_OT_max_Limit,P_days,OT_Sec,In_Time,Shift_Start_Time,OT_Start_Time ,Shift_Change,Flag ,Weekoff_OT_Sec ,Holiday_OT_Sec ,Chk_By_Superior ,IO_Tran_Id ,OUT_Time )
									select LA.Emp_id,@For_date_W,		0,	0,			0,			1,		0,				0,				0,		0,	@For_date_W,@For_date_W,		0,			0,			0,	case when lad.half_leave_date =@For_date_W then 28920/2 else  28920 end ,				0,				0,				0,		@For_date_W
									from T0120_LEAVE_APPROVAL LA WITH (NOLOCK) inner join 
									T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) on LA.Leave_Approval_ID =LAD.Leave_Approval_ID inner join
									T0040_LEAVE_MASTER LM WITH (NOLOCK) on LAD.leave_id = LM.leave_id 
									where Leave_Type='Company Purpose' and @for_date_W >= LAD.From_date and @for_date_W <= LAD.To_Date and Emp_id = @Emp_ID_W
									
								   End  


							fetch next from OT_For_Date into @For_date_W
							END  
							CLOSE OT_For_Date
							DEALLOCATE OT_For_Date
			end	
				
          fetch next from OT_Emp into @Emp_ID_W
         END  
        CLOSE OT_Emp  
        DEALLOCATE OT_Emp  
        -- Ended by rohit
     
       
       Declare @T_Emp_ID Numeric  
       Declare @T_For_Date datetime  
       Declare @Flag_cur_temp int
       Declare @P_Days_Count  Numeric(18,2) 
			Set @P_Days_Count = 0
       
        
        DECLARE OT_cursor CURSOR  
        FOR  
           SELECT d.Emp_ID,d.For_Date FROM #Data d 
           --inner join
           --t0160_Ot_Approval t  on d.Emp_ID = t.Emp_ID And d.For_Date = t.For_Date -- Added Inner join by Hardik 10/09/2012
         OPEN OT_cursor  
          fetch next from OT_cursor into @T_Emp_ID,@T_For_Date  
          while @@fetch_status = 0  
         BEGIN  
          --Commented by Hardik 10/09/2012  
          if Not Exists(select Tran_Id from dbo.t0160_Ot_Approval WITH (NOLOCK) where Emp_ID=@T_Emp_ID And For_Date=@T_For_Date)  
           Begin  
            insert into #Data_Temp   
            select  * from #Data where Emp_ID=@T_Emp_ID And For_Date=@T_For_Date  
           End  
          fetch next from OT_cursor into @T_Emp_ID,@T_For_Date  
         END  
        CLOSE OT_cursor  
        DEALLOCATE OT_cursor  
        
        Set @P_Days_Count = (Select SUM(P_days) from #data where Emp_ID=@T_Emp_ID And Month(For_Date)=Month(@T_For_Date) and IO_Tran_Id  = 0  )       
       
       CREATE TABLE #Data_Temp_Test (Emp_Id NUMERIC ,
									  For_date DATETIME ,
									  Duration_in_sec NUMERIC ,
									  Shift_ID NUMERIC ,
									  Shift_Type NUMERIC ,
									  Emp_OT NUMERIC ,
									  Emp_OT_min_Limit NUMERIC ,
									  Emp_OT_max_Limit NUMERIC ,
									  P_days NUMERIC(12, 2) DEFAULT 0 ,
									  OT_Sec NUMERIC DEFAULT 0 ,
									  In_Time DATETIME ,
									  Shift_Start_Time DATETIME ,
									  OT_Start_Time NUMERIC DEFAULT 0 ,
									  Shift_Change TINYINT DEFAULT 0 ,
									  Flag INT DEFAULT 0 ,
									  Weekoff_OT_Sec NUMERIC DEFAULT 0 ,
									  Holiday_OT_Sec NUMERIC DEFAULT 0 ,
									  Chk_By_Superior NUMERIC DEFAULT 0 ,
									  IO_Tran_Id NUMERIC DEFAULT 0 ,
									  OUT_Time DATETIME ,
									  Shift_End_Time DATETIME ,			--Ankit 16112013
									  OT_End_Time NUMERIC DEFAULT 0	--Ankit 16112013
									  )    
       
       
       
     if @Return_Record_set =2
		Begin               
           select *,dbo.F_Return_Hours (Duration_in_Sec) as Working_Hour , dbo.F_Return_Hours (OT_SEc) as OT_Hour,Flag,@P_Days_Count As P_Days_Count, dbo.F_Return_Hours (isnull(Weekoff_OT_Sec,0)) as Weekoff_OT_Hour,
				dbo.F_Return_Hours (Holiday_OT_Sec) as Holiday_OT_Hour from #Data_Temp   OA        
                inner join dbo.T0080_emp_master E WITH (NOLOCK) on OA.Emp_ID = E.Emp_ID  
                where OT_sec > 0    or Weekoff_OT_Sec > 0 or Holiday_OT_Sec > 0 
                order by OA.For_Date        
		End
	else if @Return_Record_set = 8
       BEGIN  
          If (@Is_WD = 1 And @Is_WOHO = 1)
            BEGIN
            
                 select OA.*,dbo.F_Return_Hours (Duration_in_Sec) as Working_Hour , dbo.F_Return_Hours (ISNULL(OT_SEC,0) + isnull(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) as OT_Hour, dbo.F_Return_Hours (Duration_in_Sec + ISNULL(OT_Sec,0) + ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) as Actual_Worked_Hrs,@P_Days_Count As P_Days_Count, dbo.F_Return_Hours (ISNULL(Weekoff_OT_Sec,0)) as Weekoff_OT_Hour,
				        dbo.F_Return_Hours (ISNULL(Holiday_OT_Sec,0)) as Holiday_OT_Hour, CA.Approve_Status as Application_Status from #Data_Temp   OA        
                        INNER JOIN dbo.T0080_emp_master E WITH (NOLOCK) on OA.Emp_ID = E.Emp_ID  
                        INNER JOIN dbo.T0120_CompOff_Approval CA WITH (NOLOCK) on OA.Emp_Id = CA.Emp_ID and OA.For_date=CA.Extra_Work_Date 
                  where Cast(Replace(dbo.F_Return_Hours (OT_SEC),':','.') as numeric(18,2)) >= Cast(Replace(E.CompOff_Min_hrs,':','.') as numeric(18,2)) or Cast(Replace(dbo.F_Return_Hours (Weekoff_OT_Sec),':','.') as numeric(18,2)) >= Cast(Replace(E.CompOff_Min_hrs,':','.') as numeric(18,2)) or Cast(Replace(dbo.F_Return_Hours (Holiday_OT_Sec),':','.') as numeric(18,2)) >= Cast(Replace(E.CompOff_Min_hrs,':','.') as numeric(18,2)) 
                 UNION
                  select OA.*,dbo.F_Return_Hours (Duration_in_Sec) as Working_Hour , dbo.F_Return_Hours (ISNULL(OT_SEC,0) + isnull(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) as OT_Hour, dbo.F_Return_Hours (Duration_in_Sec + ISNULL(OT_Sec,0) + ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) as Actual_Worked_Hrs, @P_Days_Count As P_Days_Count, dbo.F_Return_Hours (ISNULL(Weekoff_OT_Sec,0)) as Weekoff_OT_Hour,
				        dbo.F_Return_Hours (ISNULL(Holiday_OT_Sec,0)) as Holiday_OT_Hour, CA.Application_Status  from #Data_Temp   OA        
                        INNER JOIN dbo.T0080_emp_master E WITH (NOLOCK) on OA.Emp_ID = E.Emp_ID  
                        INNER JOIN dbo.T0100_CompOff_Application CA WITH (NOLOCK) on OA.Emp_Id = CA.Emp_ID and OA.For_date=CA.Extra_Work_Date 
                  where Cast(Replace(dbo.F_Return_Hours (OT_SEC),':','.') as numeric(18,2)) >= Cast(Replace(E.CompOff_Min_hrs,':','.') as numeric(18,2)) or Cast(Replace(dbo.F_Return_Hours (Weekoff_OT_Sec),':','.') as numeric(18,2)) >= Cast(Replace(E.CompOff_Min_hrs,':','.') as numeric(18,2)) or Cast(Replace(dbo.F_Return_Hours (Holiday_OT_Sec),':','.') as numeric(18,2)) >= Cast(Replace(E.CompOff_Min_hrs,':','.') as numeric(18,2)) 
                 UNION					
				Select Qry1.* from 
                   (select dt.*,dbo.F_Return_Hours (Duration_in_Sec) as Working_Hour , dbo.F_Return_Hours (ISNULL(OT_SEC,0) + isnull(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) as OT_Hour, dbo.F_Return_Hours (Duration_in_Sec + ISNULL(OT_Sec,0) + ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) as Actual_Worked_Hrs,@P_Days_Count As P_Days_Count, dbo.F_Return_Hours (ISNULL(Weekoff_OT_Sec,0)) as Weekoff_OT_Hour,
				        dbo.F_Return_Hours (ISNULL(Holiday_OT_Sec,0)) as Holiday_OT_Hour, '-' as application_status from #Data_Temp DT 
				        where For_date not in (                
                 select For_date from #Data_Temp   OA        
                        INNER JOIN dbo.T0080_emp_master E WITH (NOLOCK) on OA.Emp_ID = E.Emp_ID  
                        INNER JOIN dbo.T0120_CompOff_Approval CA WITH (NOLOCK) on OA.Emp_Id = CA.Emp_ID and OA.For_date=CA.Extra_Work_Date 
                  where Cast(Replace(dbo.F_Return_Hours (OT_SEC),':','.') as numeric(18,2)) >= Cast(Replace(E.CompOff_Min_hrs,':','.') as numeric(18,2)) or Cast(Replace(dbo.F_Return_Hours (Weekoff_OT_Sec),':','.') as numeric(18,2)) >= Cast(Replace(E.CompOff_Min_hrs,':','.') as numeric(18,2)) or Cast(Replace(dbo.F_Return_Hours (Holiday_OT_Sec),':','.') as numeric(18,2)) >= Cast(Replace(E.CompOff_Min_hrs,':','.') as numeric(18,2)) 
                 UNION
                  select For_date from #Data_Temp   OA        
                        INNER JOIN dbo.T0080_emp_master E WITH (NOLOCK) on OA.Emp_ID = E.Emp_ID  
                        INNER JOIN dbo.T0100_CompOff_Application CA WITH (NOLOCK) on OA.Emp_Id = CA.Emp_ID and OA.For_date=CA.Extra_Work_Date 
                  where Cast(Replace(dbo.F_Return_Hours (OT_SEC),':','.') as numeric(18,2)) >= Cast(Replace(E.CompOff_Min_hrs,':','.') as numeric(18,2)) or Cast(Replace(dbo.F_Return_Hours (Weekoff_OT_Sec),':','.') as numeric(18,2)) >= Cast(Replace(E.CompOff_Min_hrs,':','.') as numeric(18,2)) or Cast(Replace(dbo.F_Return_Hours (Holiday_OT_Sec),':','.') as numeric(18,2)) >= Cast(Replace(E.CompOff_Min_hrs,':','.') as numeric(18,2))) 
					) Qry1 inner join dbo.T0080_EMP_MASTER em WITH (NOLOCK) on Qry1.Emp_Id = em.Emp_ID
				Where Cast(Replace(dbo.F_Return_Hours (OT_SEC),':','.') as numeric(18,2)) >= Cast(Replace(Em.CompOff_Min_hrs,':','.') as numeric(18,2)) or Cast(Replace(dbo.F_Return_Hours (Weekoff_OT_Sec),':','.') as numeric(18,2)) >= Cast(Replace(Em.CompOff_Min_hrs,':','.') as numeric(18,2)) or Cast(Replace(dbo.F_Return_Hours (Holiday_OT_Sec),':','.') as numeric(18,2)) >= Cast(Replace(Em.CompOff_Min_hrs,':','.') as numeric(18,2))
                order by OA.For_Date
            END
          Else If (@Is_WD = 1 And @Is_WOHO = 0)
            BEGIN
              select OA.*,dbo.F_Return_Hours (Duration_in_Sec) as Working_Hour , dbo.F_Return_Hours (ISNULL(OT_SEC,0)) as OT_Hour, dbo.F_Return_Hours (Duration_in_Sec + ISNULL(OT_Sec,0)) as Actual_Worked_Hrs, @P_Days_Count As P_Days_Count, dbo.F_Return_Hours (ISNULL(Weekoff_OT_Sec,0)) as Weekoff_OT_Hour,
				        dbo.F_Return_Hours (ISNULL(Holiday_OT_Sec,0)) as Holiday_OT_Hour, CA.Approve_Status as Application_Status from #Data_Temp   OA        
                        INNER JOIN dbo.T0080_emp_master E WITH (NOLOCK) on OA.Emp_ID = E.Emp_ID  
                        INNER JOIN dbo.T0120_CompOff_Approval CA WITH (NOLOCK) on OA.Emp_Id = CA.Emp_ID and OA.For_date=CA.Extra_Work_Date 
                  where Cast(Replace(dbo.F_Return_Hours (OT_SEC),':','.') as numeric(18,2)) >= Cast(Replace(E.CompOff_Min_hrs,':','.') as numeric(18,2)) and Cast(Replace(dbo.F_Return_Hours (OT_SEC),':','.') as numeric(18,2)) <> 0 
             UNION
               select OA.*,dbo.F_Return_Hours (Duration_in_Sec) as Working_Hour , dbo.F_Return_Hours (ISNULL(OT_SEC,0)) as OT_Hour, dbo.F_Return_Hours (Duration_in_Sec + ISNULL(OT_Sec,0)) as Actual_Worked_Hrs, @P_Days_Count As P_Days_Count, dbo.F_Return_Hours (ISNULL(Weekoff_OT_Sec,0)) as Weekoff_OT_Hour,
				        dbo.F_Return_Hours (ISNULL(Holiday_OT_Sec,0)) as Holiday_OT_Hour, CA.Application_Status from #Data_Temp   OA        
                        INNER JOIN dbo.T0080_emp_master E WITH (NOLOCK) on OA.Emp_ID = E.Emp_ID  
                        INNER JOIN dbo.T0100_CompOff_Application CA WITH (NOLOCK) on OA.Emp_Id = CA.Emp_ID and OA.For_date=CA.Extra_Work_Date 
                  where Cast(Replace(dbo.F_Return_Hours (OT_SEC),':','.') as numeric(18,2)) >= Cast(Replace(E.CompOff_Min_hrs,':','.') as numeric(18,2)) and Cast(Replace(dbo.F_Return_Hours (OT_SEC),':','.') as numeric(18,2)) <> 0   
             UNION
               Select Qry1.* from 
                   (select dt.*,dbo.F_Return_Hours (Duration_in_Sec) as Working_Hour , dbo.F_Return_Hours (ISNULL(OT_SEC,0)) as OT_Hour, dbo.F_Return_Hours (Duration_in_Sec + ISNULL(OT_Sec,0)) as Actual_Worked_Hrs,@P_Days_Count As P_Days_Count, dbo.F_Return_Hours (ISNULL(Weekoff_OT_Sec,0)) as Weekoff_OT_Hour,
				        dbo.F_Return_Hours (ISNULL(Holiday_OT_Sec,0)) as Holiday_OT_Hour, '-' as application_status from #Data_Temp DT 
				        where For_date not in (                
                 select For_date from #Data_Temp   OA        
                        INNER JOIN dbo.T0080_emp_master E WITH (NOLOCK) on OA.Emp_ID = E.Emp_ID  
                        INNER JOIN dbo.T0120_CompOff_Approval CA WITH (NOLOCK) on OA.Emp_Id = CA.Emp_ID and OA.For_date=CA.Extra_Work_Date 
                  where Cast(Replace(dbo.F_Return_Hours (OT_SEC),':','.') as numeric(18,2)) >= Cast(Replace(E.CompOff_Min_hrs,':','.') as numeric(18,2)) and Cast(Replace(dbo.F_Return_Hours (OT_SEC),':','.') as numeric(18,2)) <> 0 
                 UNION
                  select For_date from #Data_Temp   OA        
                        INNER JOIN dbo.T0080_emp_master E WITH (NOLOCK) on OA.Emp_ID = E.Emp_ID  
                        INNER JOIN dbo.T0100_CompOff_Application CA WITH (NOLOCK) on OA.Emp_Id = CA.Emp_ID and OA.For_date=CA.Extra_Work_Date 
                  where Cast(Replace(dbo.F_Return_Hours (OT_SEC),':','.') as numeric(18,2)) >= Cast(Replace(E.CompOff_Min_hrs,':','.') as numeric(18,2))) and Cast(Replace(dbo.F_Return_Hours (OT_SEC),':','.') as numeric(18,2)) <> 0 
					) Qry1 inner join T0080_EMP_MASTER em WITH (NOLOCK) on Qry1.Emp_Id = em.Emp_ID
				Where Cast(Replace(dbo.F_Return_Hours (OT_SEC),':','.') as numeric(18,2)) >= Cast(Replace(Em.CompOff_Min_hrs,':','.') as numeric(18,2)) and Cast(Replace(dbo.F_Return_Hours (OT_SEC),':','.') as numeric(18,2)) <> 0 
                order by OA.For_Date                  
            END
          Else If (@Is_WD = 0 And @Is_WOHO = 1)
            BEGIN             
              select OA.*,dbo.F_Return_Hours (Duration_in_Sec) as Working_Hour , dbo.F_Return_Hours (ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) as OT_Hour, dbo.F_Return_Hours (ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) as Actual_Worked_Hrs, @P_Days_Count As P_Days_Count, dbo.F_Return_Hours (ISNULL(Weekoff_OT_Sec,0)) as Weekoff_OT_Hour,
				        dbo.F_Return_Hours (ISNULL(Holiday_OT_Sec,0)) as Holiday_OT_Hour, CA.Approve_Status as Application_Status from #Data_Temp   OA        
                        INNER JOIN dbo.T0080_emp_master E WITH (NOLOCK) on OA.Emp_ID = E.Emp_ID  
                        INNER JOIN dbo.T0120_CompOff_Approval CA WITH (NOLOCK) on OA.Emp_Id = CA.Emp_ID and OA.For_date=CA.Extra_Work_Date 
                  where Cast(Replace(dbo.F_Return_Hours (Weekoff_OT_Sec),':','.') as numeric(18,2)) >= Cast(Replace(E.CompOff_Min_hrs,':','.') as numeric(18,2)) or Cast(Replace(dbo.F_Return_Hours (Holiday_OT_Sec),':','.') as numeric(18,2)) >= Cast(Replace(E.CompOff_Min_hrs,':','.') as numeric(18,2)) 
                    and (Cast(Replace(dbo.F_Return_Hours (Weekoff_OT_Sec),':','.') as numeric(18,2)) <> 0 or Cast(Replace(dbo.F_Return_Hours (Holiday_OT_Sec),':','.') as numeric(18,2)) <> 0)
             UNION
               select OA.*,dbo.F_Return_Hours (Duration_in_Sec) as Working_Hour , dbo.F_Return_Hours (ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) as OT_Hour, dbo.F_Return_Hours (ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) as Actual_Worked_Hrs, @P_Days_Count As P_Days_Count, dbo.F_Return_Hours (ISNULL(Weekoff_OT_Sec,0)) as Weekoff_OT_Hour,
				        dbo.F_Return_Hours (ISNULL(Holiday_OT_Sec,0)) as Holiday_OT_Hour, CA.Application_Status from #Data_Temp   OA        
                        INNER JOIN dbo.T0080_emp_master E WITH (NOLOCK) on OA.Emp_ID = E.Emp_ID  
                        INNER JOIN dbo.T0100_CompOff_Application CA WITH (NOLOCK) on OA.Emp_Id = CA.Emp_ID and OA.For_date=CA.Extra_Work_Date 
                  where Cast(Replace(dbo.F_Return_Hours (Weekoff_OT_Sec),':','.') as numeric(18,2)) >= Cast(Replace(E.CompOff_Min_hrs,':','.') as numeric(18,2)) or Cast(Replace(dbo.F_Return_Hours (Holiday_OT_Sec),':','.') as numeric(18,2)) >= Cast(Replace(E.CompOff_Min_hrs,':','.') as numeric(18,2))
                    and (Cast(Replace(dbo.F_Return_Hours (Weekoff_OT_Sec),':','.') as numeric(18,2)) <> 0 or Cast(Replace(dbo.F_Return_Hours (Holiday_OT_Sec),':','.') as numeric(18,2)) <> 0)                        
             UNION
               Select Qry1.* from 
                   (select dt.*,dbo.F_Return_Hours (Duration_in_Sec) as Working_Hour , dbo.F_Return_Hours (ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) as OT_Hour, dbo.F_Return_Hours (ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) as Actual_Worked_Hrs, @P_Days_Count As P_Days_Count, dbo.F_Return_Hours (ISNULL(Weekoff_OT_Sec,0)) as Weekoff_OT_Hour,
				        dbo.F_Return_Hours (ISNULL(Holiday_OT_Sec,0)) as Holiday_OT_Hour, '-' as application_status from #Data_Temp DT 
				        where For_date not in (                
                 select For_date from #Data_Temp   OA        
                        INNER JOIN dbo.T0080_emp_master E WITH (NOLOCK) on OA.Emp_ID = E.Emp_ID  
                        INNER JOIN dbo.T0120_CompOff_Approval CA WITH (NOLOCK) on OA.Emp_Id = CA.Emp_ID and OA.For_date=CA.Extra_Work_Date 
                  where Cast(Replace(dbo.F_Return_Hours (Weekoff_OT_Sec),':','.') as numeric(18,2)) >= Cast(Replace(E.CompOff_Min_hrs,':','.') as numeric(18,2)) or Cast(Replace(dbo.F_Return_Hours (Holiday_OT_Sec),':','.') as numeric(18,2)) >= Cast(Replace(E.CompOff_Min_hrs,':','.') as numeric(18,2)) 
                    and (Cast(Replace(dbo.F_Return_Hours (Weekoff_OT_Sec),':','.') as numeric(18,2)) <> 0 or Cast(Replace(dbo.F_Return_Hours (Holiday_OT_Sec),':','.') as numeric(18,2)) <> 0)
                 UNION
                  select For_date from #Data_Temp   OA        
                        INNER JOIN dbo.T0080_emp_master E WITH (NOLOCK) on OA.Emp_ID = E.Emp_ID  
                        INNER JOIN dbo.T0100_CompOff_Application CA WITH (NOLOCK) on OA.Emp_Id = CA.Emp_ID and OA.For_date=CA.Extra_Work_Date 
                  where Cast(Replace(dbo.F_Return_Hours (Weekoff_OT_Sec),':','.') as numeric(18,2)) >= Cast(Replace(E.CompOff_Min_hrs,':','.') as numeric(18,2)) or Cast(Replace(dbo.F_Return_Hours (Holiday_OT_Sec),':','.') as numeric(18,2)) >= Cast(Replace(E.CompOff_Min_hrs,':','.') as numeric(18,2))) 
                    and (Cast(Replace(dbo.F_Return_Hours (Weekoff_OT_Sec),':','.') as numeric(18,2)) <> 0 or Cast(Replace(dbo.F_Return_Hours (Holiday_OT_Sec),':','.') as numeric(18,2)) <> 0)
					) Qry1 inner join dbo.T0080_EMP_MASTER em WITH (NOLOCK) on Qry1.Emp_Id = em.Emp_ID
				Where Cast(Replace(dbo.F_Return_Hours (Weekoff_OT_Sec),':','.') as numeric(18,2)) >= Cast(Replace(Em.CompOff_Min_hrs,':','.') as numeric(18,2)) or Cast(Replace(dbo.F_Return_Hours (Holiday_OT_Sec),':','.') as numeric(18,2)) >= Cast(Replace(Em.CompOff_Min_hrs,':','.') as numeric(18,2)) 
				 and (Cast(Replace(dbo.F_Return_Hours (Weekoff_OT_Sec),':','.') as numeric(18,2)) <> 0 or Cast(Replace(dbo.F_Return_Hours (Holiday_OT_Sec),':','.') as numeric(18,2)) <> 0)
                order by OA.For_Date
            END
          Else If (@Is_WD = 0 And @Is_WOHO = 0)
            BEGIN
              Raiserror('@@Comp-off not Applicable@@',18,2)
              Return -1
            END
            
       End   
       
              -------------------------
			ELSE
				IF @Return_Record_set = 9
					BEGIN 
						IF (@Is_WD = 1)
							BEGIN
								
								SELECT	OA.*,
										dbo.F_Return_Hours(Duration_in_Sec - OT_SEC) AS Working_Hour,
										CASE WHEN DATEDIFF(SECOND,In_Time,shift_Start_time)>=3600 
										OR DATEDIFF(SECOND,Shift_End_Time,Out_Time)>=3600 THEN 
										dbo.F_Return_Hours(ISNULL(OT_SEC, 0)) 
										ELSE dbo.F_Return_Hours( 0) END 
										AS OT_Hour,
										dbo.F_Return_Hours(Duration_in_Sec/* + ISNULL(OT_Sec,0)*/) AS Actual_Worked_Hrs,
										@P_Days_Count AS P_Days_Count,
										dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0)) AS Weekoff_OT_Hour,
										dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec,0)) AS Holiday_OT_Hour,
										CA.Approve_Status AS Application_Status,
										'WD' AS DayFlag,dbo.F_Return_Hours(DATEDIFF(SECOND,shift_start_time,shift_end_time)) AS Shift_Hours,
										CONVERT(NVARCHAR(8),In_Time,108) AS In_Time_Actual,CONVERT(NVARCHAR(8),Out_Time,108) AS Out_Time_Actual
								FROM	#Data_Temp OA
								INNER JOIN dbo.T0080_emp_master E WITH (NOLOCK) ON OA.Emp_ID = E.Emp_ID
								INNER JOIN dbo.T0120_CompOff_Approval CA WITH (NOLOCK) ON OA.Emp_Id = CA.Emp_ID AND OA.For_date = CA.Extra_Work_Date
								INNER JOIN (SELECT	t1.emp_id, branch_id
											FROM	T0095_Increment t1 WITH (NOLOCK)
											INNER JOIN (SELECT emp_id, MAX(Increment_ID) AS Increment_ID	-- Ankit 12092014 for Same Date Increment
														FROM  t0095_increment WITH (NOLOCK)
														GROUP BY emp_id) AS t2 ON t1.emp_id = t2.emp_id AND t1.Increment_ID = t2.Increment_ID)
										AS inc ON oa.emp_id = inc.emp_id
								INNER JOIN T0040_General_Setting gs WITH (NOLOCK) ON gs.branch_id = inc.branch_id
								WHERE	CAST(REPLACE(dbo.F_Return_Hours(OT_SEC),':', '.') AS NUMERIC(18,2)) >= CASE
															  WHEN CAST(REPLACE(gs.CompOff_Min_hours,':', '.') AS NUMERIC(18,2)) = 0
															  THEN CAST(REPLACE(E.CompOff_Min_hrs,':', '.') AS NUMERIC(18,2))
															  ELSE CAST(REPLACE(gs.CompOff_Min_hours,':', '.') AS NUMERIC(18,2))
															  END AND CAST(REPLACE(dbo.F_Return_Hours(OT_SEC),':', '.') AS NUMERIC(18,2)) <> 0
								UNION
								SELECT	OA.*,
										dbo.F_Return_Hours(Duration_in_Sec - OT_SEC)
										AS Working_Hour,
										CASE WHEN DATEDIFF(SECOND,In_Time,shift_Start_time)>=3600 
										OR DATEDIFF(SECOND,Shift_End_Time,Out_Time)>=3600 THEN 
										dbo.F_Return_Hours(ISNULL(OT_SEC, 0)) 
										ELSE dbo.F_Return_Hours( 0) END 
										AS OT_Hour,
										dbo.F_Return_Hours(Duration_in_Sec /*+ ISNULL(OT_Sec,0)*/) AS Actual_Worked_Hrs,
										@P_Days_Count AS P_Days_Count,
										dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,
															  0)) AS Weekoff_OT_Hour,
										dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec,
															  0)) AS Holiday_OT_Hour,
										CA.Application_Status, 'WD' AS DayFlag,dbo.F_Return_Hours(DATEDIFF(SECOND,shift_start_time,shift_end_time)) AS Shift_Hours,
										CONVERT(NVARCHAR(8),In_Time,108) AS In_Time_Actual,CONVERT(NVARCHAR(8),Out_Time,108) AS Out_Time_Actual
								FROM	#Data_Temp OA
								INNER JOIN dbo.T0080_emp_master E WITH (NOLOCK) ON OA.Emp_ID = E.Emp_ID
								INNER JOIN dbo.T0100_CompOff_Application CA WITH (NOLOCK) ON OA.Emp_Id = CA.Emp_ID AND OA.For_date = CA.Extra_Work_Date
								INNER JOIN (SELECT	t1.emp_id, branch_id
											FROM	T0095_Increment t1 WITH (NOLOCK)
											INNER JOIN (SELECT emp_id,
															  MAX(Increment_ID)	-- Ankit 12092014 for Same Date Increment
															  AS Increment_ID
														FROM  t0095_increment WITH (NOLOCK)
														GROUP BY emp_id) AS t2 ON t1.emp_id = t2.emp_id AND t1.Increment_ID = t2.Increment_ID)
										AS inc ON oa.emp_id = inc.emp_id
								INNER JOIN T0040_General_Setting gs WITH (NOLOCK) ON gs.branch_id = inc.branch_id
								WHERE	CAST(REPLACE(dbo.F_Return_Hours(OT_SEC),':', '.') AS NUMERIC(18,2)) >= CASE
															  WHEN CAST(REPLACE(gs.CompOff_Min_hours,':', '.') AS NUMERIC(18,2)) = 0
															  THEN CAST(REPLACE(E.CompOff_Min_hrs,':', '.') AS NUMERIC(18,2))
															  ELSE CAST(REPLACE(gs.CompOff_Min_hours,':', '.') AS NUMERIC(18,2))
															  END AND CAST(REPLACE(dbo.F_Return_Hours(OT_SEC),':', '.') AS NUMERIC(18,2)) <> 0
								UNION
								SELECT	Qry1.*
								FROM	(SELECT	dt.*,
												dbo.F_Return_Hours(Duration_in_Sec - OT_SEC)
												AS Working_Hour,
												CASE WHEN DATEDIFF(SECOND,In_Time,shift_Start_time)>=3600 
												OR DATEDIFF(SECOND,Shift_End_Time,Out_Time)>=3600 THEN 
												dbo.F_Return_Hours(ISNULL(OT_SEC, 0)) 
												ELSE dbo.F_Return_Hours( 0) END 
												AS OT_Hour,
												dbo.F_Return_Hours(Duration_in_Sec/* + ISNULL(OT_Sec,0)*/) AS Actual_Worked_Hrs,
												@P_Days_Count AS P_Days_Count,
												dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0)) AS Weekoff_OT_Hour,
												dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec,0)) AS Holiday_OT_Hour,
												'-' AS application_status,
												'WD' AS DayFlag,dbo.F_Return_Hours(DATEDIFF(SECOND,shift_start_time,shift_end_time)) AS Shift_Hours,
										CONVERT(NVARCHAR(8),In_Time,108) AS In_Time_Actual,CONVERT(NVARCHAR(8),Out_Time,108) AS Out_Time_Actual
										 FROM	#Data_Temp DT
										 WHERE	For_date NOT IN (
												SELECT	OA.For_Date
												FROM	[#Data_Temp] AS OA
												INNER JOIN T0080_EMP_MASTER AS E WITH (NOLOCK) ON OA.Emp_ID = E.Emp_ID
												INNER JOIN T0120_CompOff_Approval 
														AS CA ON OA.Emp_Id = CA.Emp_ID AND OA.For_date = CA.Extra_Work_Date
												INNER JOIN (SELECT t1.Emp_ID, t1.Branch_ID
															FROM T0095_INCREMENT t1 WITH (NOLOCK)
															INNER JOIN 
															(SELECT Emp_ID, MAX(Increment_ID) AS Increment_ID	-- Ankit 12092014 for Same Date Increment
															  FROM T0095_INCREMENT WITH (NOLOCK)
															  GROUP BY Emp_ID)
															  AS t2 ON t1.emp_id = t2.Emp_ID AND t1.Increment_ID = t2.Increment_ID)
														AS inc ON OA.Emp_ID = inc.Emp_ID
												INNER JOIN T0040_GENERAL_SETTING 
														AS gs ON gs.Branch_ID = inc.Branch_ID
												WHERE	(CAST(REPLACE(dbo.F_Return_Hours(OT_SEC),':', '.') AS NUMERIC(18,2)) >= CASE
															  WHEN CAST(REPLACE(gs.CompOff_Min_hours,':', '.') AS NUMERIC(18,2)) = 0
															  THEN CAST(REPLACE(E.CompOff_Min_hrs,':', '.') AS NUMERIC(18,2))
															  ELSE CAST(REPLACE(gs.CompOff_Min_hours,':', '.') AS NUMERIC(18,2))
															  END) AND (CAST(REPLACE(dbo.F_Return_Hours(OT_SEC),':', '.') AS NUMERIC(18,2)) <> 0)
												UNION
												SELECT	OA.For_Date
												FROM	[#Data_Temp] AS OA
												INNER JOIN T0080_EMP_MASTER AS E WITH (NOLOCK) ON OA.Emp_ID = E.Emp_ID
												INNER JOIN T0100_CompOff_Application 
														AS CA ON OA.Emp_Id = CA.Emp_ID AND OA.For_date = CA.Extra_Work_Date
												INNER JOIN (SELECT t1.Emp_ID, t1.Branch_ID 
															FROM T0095_INCREMENT t1 WITH (NOLOCK)
															INNER JOIN (SELECT
															  Emp_ID,
															  MAX(Increment_ID)	-- Ankit 12092014 for Same Date Increment
															  AS Increment_ID
															  FROM
															  T0095_INCREMENT WITH (NOLOCK)
															  GROUP BY Emp_ID)
															  AS t2 ON t1.emp_id = t2.Emp_ID AND t1.Increment_ID = t2.Increment_ID)
														AS inc ON OA.Emp_ID = inc.Emp_ID
												INNER JOIN T0040_GENERAL_SETTING 
														AS gs ON gs.Branch_ID = inc.Branch_ID
												WHERE	(CAST(REPLACE(dbo.F_Return_Hours(OT_SEC),':', '.') AS NUMERIC(18,2)) >= CASE
															  WHEN CAST(REPLACE(gs.CompOff_Min_hours,':', '.') AS NUMERIC(18,2)) = 0
															  THEN CAST(REPLACE(E.CompOff_Min_hrs,':', '.') AS NUMERIC(18,2))
															  ELSE CAST(REPLACE(gs.CompOff_Min_hours,':', '.') AS NUMERIC(18,2))
															  END) AND (CAST(REPLACE(dbo.F_Return_Hours(OT_SEC),':', '.') AS NUMERIC(18,2)) <> 0))) Qry1
								INNER JOIN T0080_EMP_MASTER em WITH (NOLOCK) ON Qry1.Emp_Id = em.Emp_ID
								INNER JOIN (SELECT	t1.emp_id, t1.branch_id
											FROM	T0095_Increment t1 WITH (NOLOCK)
											INNER JOIN (SELECT emp_id,MAX(Increment_ID) AS Increment_ID	-- Ankit 12092014 for Same Date Increment
														FROM  t0095_increment WITH (NOLOCK)
														GROUP BY emp_id) AS t2 ON t1.emp_id = t2.emp_id AND t1.Increment_ID = t2.Increment_ID)
										AS inc ON Qry1.Emp_ID = inc.emp_id
								INNER JOIN T0040_General_Setting gs WITH (NOLOCK) ON gs.branch_id = inc.branch_id
								where CAST(REPLACE(dbo.F_Return_Hours(OT_SEC),':', '.') AS numeric(18,2)) >= CASE 
															  WHEN 
															  CAST(REPLACE(isnull(															 
															    case when 
															       gs.CompOff_Min_hours ='' then '00:00' else gs.CompOff_Min_hours end															  
															  ,'00:00'),':', '.') AS numeric(18,2)) = 0
															  THEN CAST(REPLACE(isnull(
															  
															 case when  Em.CompOff_Min_hrs='' then '00:00' else Em.CompOff_Min_hrs end
															  
															  ,'00:00'),':', '.') AS numeric(18,2))
															  ELSE CAST(REPLACE(isnull(															  
															     case when gs.CompOff_Min_hours='' then '00:00' else gs.CompOff_Min_hours end															  
															  ,'00:00'),':', '.') AS numeric(18,2))
														  END AND 
														  
														  
														  CAST(REPLACE(dbo.F_Return_Hours(OT_SEC),':', '.') AS numeric(18,2)) <> 0
								ORDER BY OA.For_Date                  
							END
					END
				ELSE
					IF @Return_Record_set = 10
						BEGIN 
							IF (@Is_HO_CompOff = 1)
								BEGIN          
									SELECT	OA.*,
											dbo.F_Return_Hours(Duration_in_Sec)
											AS Working_Hour,
											dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) AS OT_Hour,
											dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) AS Actual_Worked_Hrs,
											@P_Days_Count AS P_Days_Count, dbo.F_Return_Hours(0) AS Weekoff_OT_Hour,
											dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec,0)) AS Holiday_OT_Hour,
											CA.Approve_Status AS Application_Status,'HO' AS DayFlag,'00:00' AS Shift_Hours,
										CONVERT(NVARCHAR(8),In_Time,108) AS In_Time_Actual,CONVERT(NVARCHAR(8),Out_Time,108) AS Out_Time_Actual
									FROM	#Data_Temp OA
									INNER JOIN dbo.T0080_emp_master E WITH (NOLOCK) ON OA.Emp_ID = E.Emp_ID
									INNER JOIN dbo.T0120_CompOff_Approval CA WITH (NOLOCK) ON OA.Emp_Id = CA.Emp_ID AND OA.For_date = CA.Extra_Work_Date
									INNER JOIN (SELECT	t1.emp_id,t1.branch_id
												FROM	T0095_Increment t1 WITH (NOLOCK)
												INNER JOIN (SELECT emp_id, MAX(Increment_ID) AS Increment_ID	-- Ankit 12092014 for Same Date Increment
															FROM t0095_increment WITH (NOLOCK)
															GROUP BY emp_id)
														AS t2 ON t1.emp_id = t2.emp_id AND t1.Increment_ID = t2.Increment_ID)
											AS inc ON OA.Emp_ID = inc.emp_id
									INNER JOIN T0040_General_Setting gs WITH (NOLOCK) ON gs.branch_id = inc.branch_id
									WHERE	CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec),':', '.') AS NUMERIC(18,2)) >= CASE
															  WHEN CAST(REPLACE(gs.H_CompOff_Min_hours,':', '.') AS NUMERIC(18,2)) = 0
															  THEN CAST(REPLACE(E.CompOff_Min_hrs,':', '.') AS NUMERIC(18,2))
															  ELSE CAST(REPLACE(gs.H_CompOff_Min_hours,':', '.') AS NUMERIC(18,2))
															  END AND (CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec),':', '.') AS NUMERIC(18,2)) <> 0)
									UNION
									SELECT	OA.*,
											dbo.F_Return_Hours(Duration_in_Sec)
											AS Working_Hour,
											dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) AS OT_Hour,
											dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) AS Actual_Worked_Hrs,
											@P_Days_Count AS P_Days_Count,dbo.F_Return_Hours(0) AS Weekoff_OT_Hour,
											dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec,0)) AS Holiday_OT_Hour,CA.Application_Status,
											'HO' AS DayFlag,'00:00' AS Shift_Hours,
										CONVERT(NVARCHAR(8),In_Time,108) AS In_Time_Actual,CONVERT(NVARCHAR(8),Out_Time,108) AS Out_Time_Actual
									FROM	#Data_Temp OA
									INNER JOIN dbo.T0080_emp_master E WITH (NOLOCK) ON OA.Emp_ID = E.Emp_ID
									INNER JOIN dbo.T0100_CompOff_Application CA WITH (NOLOCK) ON OA.Emp_Id = CA.Emp_ID AND OA.For_date = CA.Extra_Work_Date
									INNER JOIN (SELECT	t1.emp_id,t1.branch_id FROM	T0095_Increment t1 WITH (NOLOCK)
												INNER JOIN (SELECT emp_id,MAX(Increment_ID) AS Increment_ID	-- Ankit 12092014 for Same Date Increment
															FROM t0095_increment WITH (NOLOCK) GROUP BY emp_id)
														AS t2 ON t1.emp_id = t2.emp_id AND t1.Increment_ID = t2.Increment_ID)
											AS inc ON OA.Emp_ID = inc.emp_id
									INNER JOIN T0040_General_Setting gs WITH (NOLOCK) ON gs.branch_id = inc.branch_id
									WHERE	CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec),':', '.') AS NUMERIC(18,2)) >= CASE
															  WHEN CAST(REPLACE(gs.H_CompOff_Min_hours,':', '.') AS NUMERIC(18,2)) = 0
															  THEN CAST(REPLACE(E.CompOff_Min_hrs,':', '.') AS NUMERIC(18,2))
															  ELSE CAST(REPLACE(gs.H_CompOff_Min_hours,':', '.') AS NUMERIC(18,2))
															  END AND (CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec),':', '.') AS NUMERIC(18,2)) <> 0)
									UNION
									SELECT	Qry1.*
									FROM	(SELECT	dt.*,dbo.F_Return_Hours(Duration_in_Sec) AS Working_Hour,
													dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) AS OT_Hour,
													dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) AS Actual_Worked_Hrs,
													@P_Days_Count AS P_Days_Count,
													dbo.F_Return_Hours(0) AS Weekoff_OT_Hour,
													dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec,0)) AS Holiday_OT_Hour,
													'-' AS application_status,'HO' AS DayFlag,'00:00' AS Shift_Hours,
										CONVERT(NVARCHAR(8),In_Time,108) AS In_Time_Actual,CONVERT(NVARCHAR(8),Out_Time,108) AS Out_Time_Actual
											 FROM	#Data_Temp DT
											 WHERE	For_date NOT IN (SELECT	For_date
																	FROM	#Data_Temp OA
																	INNER JOIN dbo.T0080_emp_master E WITH (NOLOCK) ON OA.Emp_ID = E.Emp_ID
																	INNER JOIN dbo.T0120_CompOff_Approval CA WITH (NOLOCK) ON OA.Emp_Id = CA.Emp_ID AND OA.For_date = CA.Extra_Work_Date
																	WHERE	CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec),':', '.') AS NUMERIC(18,2)) >= CAST(REPLACE(E.CompOff_Min_hrs,':', '.') AS NUMERIC(18,2)) AND 
																	(CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec),':', '.') AS NUMERIC(18,2)) <> 0)
													UNION
													SELECT	For_date
													FROM	#Data_Temp OA
													INNER JOIN dbo.T0080_emp_master E WITH (NOLOCK) ON OA.Emp_ID = E.Emp_ID
													INNER JOIN dbo.T0100_CompOff_Application CA WITH (NOLOCK) ON OA.Emp_Id = CA.Emp_ID AND OA.For_date = CA.Extra_Work_Date
													WHERE	CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS NUMERIC(18,2)) >= 
															CAST(REPLACE(E.CompOff_Min_hrs,':', '.') AS NUMERIC(18,2)) OR 
															CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec),':', '.') AS NUMERIC(18,2)) >= 
															CAST(REPLACE(E.CompOff_Min_hrs,':', '.') AS NUMERIC(18,2))) AND 
															(CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS NUMERIC(18,2)) <> 0 OR 
															CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec),':', '.') AS NUMERIC(18,2)) <> 0)) Qry1
									INNER JOIN dbo.T0080_EMP_MASTER em WITH (NOLOCK) ON Qry1.Emp_Id = em.Emp_ID
									INNER JOIN (SELECT	t1.emp_id,t1.branch_id
												FROM	T0095_Increment t1 WITH (NOLOCK)
												INNER JOIN (SELECT emp_id,MAX(Increment_ID) AS Increment_ID	-- Ankit 12092014 for Same Date Increment
															FROM t0095_increment WITH (NOLOCK)
															GROUP BY emp_id)
														AS t2 ON t1.emp_id = t2.emp_id AND t1.Increment_ID = t2.Increment_ID)
											AS inc ON Qry1.Emp_ID = inc.emp_id
									INNER JOIN T0040_General_Setting gs WITH (NOLOCK) ON gs.branch_id = inc.branch_id
									WHERE	CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec),':', '.') AS NUMERIC(18,2)) >= CASE
															  WHEN CAST(REPLACE(gs.H_CompOff_Min_hours,':', '.') AS NUMERIC(18,2)) = 0
															  THEN CAST(REPLACE(Em.CompOff_Min_hrs,':', '.') AS NUMERIC(18,2))
															  ELSE CAST(REPLACE(gs.H_CompOff_Min_hours,':', '.') AS NUMERIC(18,2))
															  END AND (CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec),':', '.') AS NUMERIC(18,2)) <> 0)
									ORDER BY OA.For_Date
								END
						END
					ELSE
						IF @Return_Record_set = 11
							BEGIN 
								IF (@Is_W_CompOff = 1)
									BEGIN             
										SELECT	OA.*,
												dbo.F_Return_Hours(Duration_in_Sec)
												AS Working_Hour,
												dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) AS OT_Hour,
												dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) AS Actual_Worked_Hrs,
												@P_Days_Count AS P_Days_Count,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0)) AS Weekoff_OT_Hour,
												dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec,0)) AS Holiday_OT_Hour,
												CA.Approve_Status AS Application_Status,'W' AS DayFlag,'00:00' AS Shift_Hours,
										CONVERT(NVARCHAR(8),In_Time,108) AS In_Time_Actual,CONVERT(NVARCHAR(8),Out_Time,108) AS Out_Time_Actual
										FROM	#Data_Temp OA
										INNER JOIN dbo.T0080_emp_master E WITH (NOLOCK) ON OA.Emp_ID = E.Emp_ID
										INNER JOIN dbo.T0120_CompOff_Approval CA WITH (NOLOCK) ON OA.Emp_Id = CA.Emp_ID AND OA.For_date = CA.Extra_Work_Date
										INNER JOIN (SELECT	t1.emp_id,t1.branch_id
													FROM	T0095_Increment t1 WITH (NOLOCK)
													INNER JOIN (SELECT emp_id,MAX(Increment_ID)AS Increment_ID	-- Ankit 12092014 for Same Date Increment
															  FROM t0095_increment WITH (NOLOCK) GROUP BY emp_id)
															AS t2 ON t1.emp_id = t2.emp_id AND t1.Increment_ID = t2.Increment_ID)
												AS inc ON OA.Emp_ID = inc.emp_id
										INNER JOIN T0040_General_Setting gs WITH (NOLOCK) ON gs.branch_id = inc.branch_id
										WHERE	CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS NUMERIC(18,2)) >= CASE
															  WHEN CAST(REPLACE(gs.W_CompOff_Min_hours,':', '.') AS NUMERIC(18,2)) = 0
															  THEN CAST(REPLACE(E.CompOff_Min_hrs,':', '.') AS NUMERIC(18,2))
															  ELSE CAST(REPLACE(gs.W_CompOff_Min_hours,':', '.') AS NUMERIC(18,2))
															  END 
												AND (CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS NUMERIC(18,2)) <> 0)
										UNION
										SELECT	OA.*,
												dbo.F_Return_Hours(Duration_in_Sec)
												AS Working_Hour,
												dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) AS OT_Hour,
												dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) AS Actual_Worked_Hrs,
												@P_Days_Count AS P_Days_Count,
												dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0)) AS Weekoff_OT_Hour,
												dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec,0)) AS Holiday_OT_Hour,
												CA.Application_Status,'W' AS DayFlag,'00:00' AS Shift_Hours,
										CONVERT(NVARCHAR(8),In_Time,108) AS In_Time_Actual,CONVERT(NVARCHAR(8),Out_Time,108) AS Out_Time_Actual
										FROM	#Data_Temp OA
										INNER JOIN dbo.T0080_emp_master E WITH (NOLOCK) ON OA.Emp_ID = E.Emp_ID
										INNER JOIN dbo.T0100_CompOff_Application CA WITH (NOLOCK) ON OA.Emp_Id = CA.Emp_ID AND OA.For_date = CA.Extra_Work_Date
										INNER JOIN (SELECT	t1.emp_id,t1.branch_id FROM	T0095_Increment t1 WITH (NOLOCK)
													INNER JOIN (SELECT emp_id,MAX(Increment_ID) AS Increment_ID	-- Ankit 12092014 for Same Date Increment
															  FROM t0095_increment WITH (NOLOCK) GROUP BY emp_id)
															AS t2 ON t1.emp_id = t2.emp_id AND t1.Increment_ID = t2.Increment_ID)
												AS inc ON OA.Emp_ID = inc.emp_id
										INNER JOIN T0040_General_Setting gs WITH (NOLOCK) ON gs.branch_id = inc.branch_id
										WHERE	CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS NUMERIC(18,2)) >= CASE
															  WHEN CAST(REPLACE(gs.W_CompOff_Min_hours,':', '.') AS NUMERIC(18,2)) = 0
															  THEN CAST(REPLACE(E.CompOff_Min_hrs,':', '.') AS NUMERIC(18,2))
															  ELSE CAST(REPLACE(gs.W_CompOff_Min_hours,':', '.') AS NUMERIC(18,2))
															  END 
                  								AND (CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS NUMERIC(18,2)) <> 0)
										UNION
										SELECT	Qry1.*
										FROM	(SELECT	dt.*,
														dbo.F_Return_Hours(Duration_in_Sec)
														AS Working_Hour,
														dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) AS OT_Hour,
														dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) AS Actual_Worked_Hrs,
														@P_Days_Count AS P_Days_Count,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0)) AS Weekoff_OT_Hour,
														dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec,0)) AS Holiday_OT_Hour,'-' AS application_status,
														'W' AS DayFlag,'00:00' AS Shift_Hours,
														CONVERT(NVARCHAR(8),In_Time,108) AS In_Time_Actual,CONVERT(NVARCHAR(8),Out_Time,108) AS Out_Time_Actual
												 FROM	#Data_Temp DT
												 WHERE	For_date NOT IN (
														SELECT For_date
														FROM  #Data_Temp OA
														INNER JOIN dbo.T0080_emp_master E WITH (NOLOCK) ON OA.Emp_ID = E.Emp_ID
														INNER JOIN dbo.T0120_CompOff_Approval CA WITH (NOLOCK) ON OA.Emp_Id = CA.Emp_ID AND OA.For_date = CA.Extra_Work_Date
														WHERE CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS NUMERIC(18,2)) >= 
																CAST(REPLACE(E.CompOff_Min_hrs,':', '.') AS NUMERIC(18,2)) 
															  AND (CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS NUMERIC(18,2)) <> 0) 
														UNION
														SELECT For_date
														FROM  #Data_Temp OA
														INNER JOIN dbo.T0080_emp_master E WITH (NOLOCK) ON OA.Emp_ID = E.Emp_ID
														INNER JOIN dbo.T0100_CompOff_Application CA WITH (NOLOCK) ON OA.Emp_Id = CA.Emp_ID AND OA.For_date = CA.Extra_Work_Date
														WHERE CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS NUMERIC(18,2)) >= 
																CAST(REPLACE(E.CompOff_Min_hrs,':', '.') AS NUMERIC(18,2))) 
																AND (CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS NUMERIC(18,2)) <> 0)) Qry1
										INNER JOIN dbo.T0080_EMP_MASTER em WITH (NOLOCK) ON Qry1.Emp_Id = em.Emp_ID
										INNER JOIN (SELECT	t1.emp_id,t1.branch_id FROM	T0095_Increment t1 WITH (NOLOCK)
													INNER JOIN (SELECT emp_id,MAX(Increment_ID) AS Increment_ID	-- Ankit 12092014 for Same Date Increment
															  FROM t0095_increment WITH (NOLOCK) GROUP BY emp_id)
															AS t2 ON t1.emp_id = t2.emp_id AND t1.Increment_ID = t2.Increment_ID)
												AS inc ON Qry1.Emp_ID = inc.emp_id
										INNER JOIN T0040_General_Setting gs WITH (NOLOCK) ON gs.branch_id = inc.branch_id
										WHERE	CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS NUMERIC(18,2)) >= CASE
															  WHEN CAST(REPLACE(gs.W_CompOff_Min_hours,':', '.') AS NUMERIC(18,2)) = 0
															  THEN CAST(REPLACE(Em.CompOff_Min_hrs,':', '.') AS NUMERIC(18,2))
															  ELSE CAST(REPLACE(gs.W_CompOff_Min_hours,':', '.') AS NUMERIC(18,2))
															  END
												AND (CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec),':', '.') AS NUMERIC(18,2)) <> 0)
										ORDER BY OA.For_Date
				
				
									END
							END
						ELSE
							IF @return_record_set = 12
								BEGIN
									EXEC getAllDaysBetweenTwoDate @from_Date,
										@to_Date
			
									INSERT	INTO #data_temp_test
											SELECT	t1.Emp_ID,t2.test1 AS For_Date,0 AS Duration_in_Sec,
													1 AS Shift_ID,0 AS shift_type,1 AS Emp_OT,0 AS Emp_OT_min_Limit,
													0 AS Emp_OT_max_Limit,0 AS P_Days, 0 AS OT_Sec,test1 AS In_Time,
													test1 AS Shift_Start_Time,0 AS OT_Start_Time,0 AS Shift_Change,
													0 AS Flag,0 AS Weekoff_OT_Sec,0 AS Holiday_OT_Sec,
													0 AS Chk_By_Superior,0 AS IO_Trans_ID,test1 AS OUT_Time,
													test1 AS Shift_End_Time,0 AS OT_End_Time
											FROM	(SELECT	la.Emp_ID,lad.From_Date,lad.To_Date
													 FROM	(SELECT la.* FROM T0120_LEAVE_APPROVAL la WITH (NOLOCK)
															 LEFT OUTER JOIN T0150_LEAVE_CANCELLATION lc WITH (NOLOCK) ON la.Leave_Approval_ID = lc.Leave_Approval_id AND la.Cmp_ID = lc.Cmp_Id
															 WHERE ISNULL(Is_Approve,0) = 0) AS la
													 INNER JOIN T0110_LEAVE_APPLICATION_DETAIL 
															AS lad ON la.Leave_Application_ID = lad.Leave_Application_ID AND la.Cmp_ID = lad.Cmp_ID
													 INNER JOIN T0040_LEAVE_MASTER 
															AS lt ON la.Cmp_ID = lt.Cmp_ID AND lad.Leave_ID = lt.Leave_ID
													 WHERE	(la.Emp_ID = @Emp_ID) AND (lt.Leave_Type = 'Company Purpose') AND (la.Approval_Status = 'A'))
													AS t1
											CROSS JOIN test1 AS t2 
											WHERE	t2.test1 >= from_Date AND t2.test1 <= to_date
											ORDER BY For_Date
									SELECT	dtt.*, '00:00' AS Working_Hour,
											'00:00' AS OT_Hour,
											'00:00' AS Actual_Worked_Hrs,
											0.00 AS P_Days_Count,
											'00:00' AS Weekoff_OT_Hours,
											'00:00' AS Holiday_OT_Hours,
											ISNULL(Application_Status, '-') AS Application_Status,
											'OD' AS DayFlag,'00:00' AS Shift_Hours,CAST('00:00:00' AS VARCHAR(8)) AS In_Time_Actual,
											CAST('00:00:00' AS VARCHAR(8)) AS Out_Time_Actual 
									FROM	#Data_Temp_test AS dtt
									LEFT OUTER JOIN t0100_Compoff_Application 
											AS ca ON dtt.emp_id = ca.emp_id AND dtt.For_Date = ca.Extra_Work_Date
	       
								END
		   -------------------------

       
   end        
    
  else if @Return_Record_set = 1         
   begin 
		
    --select *, CONVERT(decimal(10,2), Duration_in_Sec/3600)   as Working_Hour ,CONVERT(decimal(10,2), OT_SEc/3600) as OT_Hour from #Data  OA    
    
    Select OA.Emp_Id,E.Alpha_Emp_Code+' - '+E.Emp_Full_Name as Emp_Full_Name,For_date ,cast(In_Time as time)In_Time,cast(OUT_Time as time)OUT_Time ,dbo.F_Return_Hours (Duration_in_Sec) as Duration,Shift_Name,Shift_St_Time,OA.Shift_End_Time,Shift_Dur
	from #Data  OA inner join 
		 dbo.T0080_emp_master E WITH (NOLOCK) on OA.Emp_ID = E.Emp_ID Left Outer Join 
		 dbo.T0040_SHIFT_MASTER SM WITH (NOLOCK) on OA.Shift_ID = SM.Shift_ID
    order by E.emp_ID,For_Date
    
    --    where OT_sec > 0 or Weekoff_OT_Sec > 0 or Holiday_OT_Sec > 0   
   
   end        
  else if @Return_Record_set =3        
   begin        
       
    /*update #Data         
     set OT_Sec = 0        
    from #Data  d inner join T0160_OT_Approval OA on d.emp_ID = Oa.Emp_ID         
        
       update #Data         
     set OT_Sec = isnull(Approved_OT_Sec,0)  * 3600        
    from #Data  d inner join T0160_OT_Approval OA on d.emp_ID = Oa.Emp_ID and d.For_Date = oa.For_Date   

                    
      */  
      
      
      
    CREATE TABLE #Data_Temp_3         
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
		   OT_Sec  numeric default 0 ,
		   In_Time datetime,
		   Shift_Start_Time  datetime,
		   OT_Start_Time numeric default 0,
		   Shift_Change tinyint default 0,
           Flag int default 0,
		   Weekoff_OT_Sec Numeric Default 0,
		   Holiday_OT_Sec Numeric Default 0 ,
		   Chk_By_Superior numeric default 0,
		   IO_Tran_Id	   numeric default 0,
		   OUT_Time Datetime,
		   Shift_End_Time datetime,			--Ankit 16112013
		   OT_End_Time numeric default 0,	--Ankit 16112013
		   Working_Hrs_St_Time tinyint default 0, --Hardik 14/02/2014
		   Working_Hrs_End_Time tinyint default 0 --Hardik 14/02/2014
       )   
        
         Declare @T_Emp_ID_3 Numeric  
         Declare @T_For_Date_3 datetime  
         Declare @Flag_cur As Int       	
       	
       	
       	       	
        --delete from #Data_Temp_3  
        Truncate Table #Data_Temp_3  --Hardik 15/02/2013
        
         -- Added by rohit on 26082013
       
         --declare @Emp_ID_W numeric
         --Declare @For_date_W Datetime
       
       
         
        DECLARE OT_Emp CURSOR  
        FOR  
           SELECT Emp_ID FROM #Emp_Cons 
           --inner join
           --t0160_Ot_Approval t  on d.Emp_ID = t.Emp_ID And d.For_Date = t.For_Date -- Added Inner join by Hardik 10/09/2012
         OPEN OT_Emp  
          fetch next from OT_Emp into @Emp_ID_W
          while @@fetch_status = 0  
         BEGIN  
         --Declare @StrWeekoff_Date_W varchar(max)
         --declare @Weekoff_Days_W varchar(max)
         --declare @Cancel_Weekoff_w varchar(max)
         --declare @StrHoliday_Date_W varchar(max)
         --declare @Holiday_days_W varchar(max)
         --declare @Cancel_Holiday_W varchar (max)
         
         --declare @OD_transfer_to_ot numeric(1,0)
         --Declare @Branch_id_OD numeric (4,0)
         
        
         select @BRANCH_ID_OD =	Branch_id from t0095_increment  WITH (NOLOCK) where Increment_ID =( select max(Increment_ID) from t0095_increment WITH (NOLOCK) where emp_id=@Emp_ID_W and increment_effective_date <=@To_Date) and emp_id = @Emp_ID_W	-- Ankit 12092014 for Same Date Increment
        
         select @OD_transfer_to_ot = Is_OD_Transfer_to_OT from t0040_general_setting WITH (NOLOCK) where branch_id = @BRANCH_ID_OD
        
         if @OD_transfer_to_ot = 1 
         begin
         Exec dbo.SP_EMP_HOLIDAY_DATE_GET1 @Emp_Week_Detail,@Cmp_ID,@From_Date,@To_Date,null,null,@Is_Cancel_Holiday,@StrHoliday_Date_W output,@Holiday_days_W output,@Cancel_Holiday_W output,0,@Branch_ID,@StrWeekoff_Date_W
         Exec dbo.SP_EMP_WEEKOFF_DATE_GET1 @Emp_ID_W,@Cmp_ID,@From_Date,@To_Date,null,null,@Is_Cancel_weekoff,'',@StrWeekoff_Date_W output,@Weekoff_Days_W output ,@Cancel_Weekoff_w output,@constraint=''
         
         
         
				     DECLARE OT_For_Date CURSOR  
						 FOR  							
							select  cast(data  as Datetime) as For_date  from dbo.Split ( (@StrHoliday_Date_W) ,';') 
							--select inactive_effective_date from t0040_leave_master
							OPEN OT_For_Date
							fetch next from OT_For_Date into @For_date_W
							while @@fetch_status = 0  
							BEGIN  
						

							if Not Exists(select Tran_Id from dbo.t0160_Ot_Approval WITH (NOLOCK) where Emp_ID=@Emp_ID_W And For_Date=@For_date_W)  
								   Begin  
										insert into #Data_Temp_3   
											(Emp_Id,For_date,Duration_in_sec,Shift_ID,Shift_Type,Emp_OT ,Emp_OT_min_Limit,Emp_OT_max_Limit,P_days,OT_Sec,In_Time,Shift_Start_Time,OT_Start_Time ,Shift_Change,Flag ,Weekoff_OT_Sec ,Holiday_OT_Sec ,Chk_By_Superior ,IO_Tran_Id ,OUT_Time )
									select LA.Emp_id,@For_date_W,		0,	0,			0,			1,		0,				0,				0,		0,	@For_date_W,@For_date_W,		0,			0,			0,	0,case when lad.half_leave_date =@For_date_W then 28800/2 else  28800 end ,				0,				0,		@For_date_W
									from T0120_LEAVE_APPROVAL LA WITH (NOLOCK) inner join 
									T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) on LA.Leave_Approval_ID =LAD.Leave_Approval_ID inner join
									T0040_LEAVE_MASTER LM WITH (NOLOCK) on LAD.leave_id = LM.leave_id 
									where Leave_Type='Company Purpose' and @for_date_W >= LAD.From_date and @for_date_W <= LAD.To_Date and Emp_id = @Emp_ID_W
									
								   End  


							fetch next from OT_For_Date into @For_date_W
							END  
							CLOSE OT_For_Date
							DEALLOCATE OT_For_Date
							
						DECLARE OT_For_Date CURSOR  
						 FOR  							
							select  cast(data  as Datetime) as For_date  from dbo.Split ( (@StrWeekoff_Date_W) ,';') where cast(data  as Datetime) not in (select cast(data  as Datetime) from dbo.Split ( (@StrHoliday_Date_W) ,';')) 
							--select inactive_effective_date from t0040_leave_master
							OPEN OT_For_Date
							fetch next from OT_For_Date into @For_date_W
							while @@fetch_status = 0  
							BEGIN  
						

							if Not Exists(select Tran_Id from dbo.t0160_Ot_Approval WITH (NOLOCK) where Emp_ID=@Emp_ID_W And For_Date=@For_date_W)  
								   Begin  
										insert into #Data_Temp_3   
											(Emp_Id,For_date,Duration_in_sec,Shift_ID,Shift_Type,Emp_OT ,Emp_OT_min_Limit,Emp_OT_max_Limit,P_days,OT_Sec,In_Time,Shift_Start_Time,OT_Start_Time ,Shift_Change,Flag ,Weekoff_OT_Sec ,Holiday_OT_Sec ,Chk_By_Superior ,IO_Tran_Id ,OUT_Time )
									select LA.Emp_id,@For_date_W,		0,	0,			0,			1,		0,				0,				0,		0,	@For_date_W,@For_date_W,		0,			0,			0,	case when lad.half_leave_date =@For_date_W then 28800/2 else  28800 end ,				0,				0,				0,		@For_date_W
									from T0120_LEAVE_APPROVAL LA WITH (NOLOCK) inner join 
									T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) on LA.Leave_Approval_ID =LAD.Leave_Approval_ID inner join
									T0040_LEAVE_MASTER LM WITH (NOLOCK) on LAD.leave_id = LM.leave_id 
									where Leave_Type='Company Purpose' and @for_date_W >= LAD.From_date and @for_date_W <= LAD.To_Date and Emp_id = @Emp_ID_W
									
								   End  


							fetch next from OT_For_Date into @For_date_W
							END  
							CLOSE OT_For_Date
							DEALLOCATE OT_For_Date
			end	
				
          fetch next from OT_Emp into @Emp_ID_W
         END  
        CLOSE OT_Emp  
        DEALLOCATE OT_Emp  
        -- Ended by rohit
        
        DECLARE OT_cursor CURSOR  
        FOR  
	        SELECT d.Emp_ID,d.For_Date,Flag FROM #Data D
	        --Commented By rohit under the Guidance by Miteshbhai for Showing Ot hours Without Approved. 07-dec-2012
	  --       d inner join
			--t0160_Ot_Approval t  on d.Emp_ID = t.Emp_ID And d.For_Date = t.For_Date -- Added Inner join by Hardik 10/09/2012
         OPEN OT_cursor  
          fetch next from OT_cursor into @T_Emp_ID_3,@T_For_Date_3,@Flag_cur   
          while @@fetch_status = 0  
         BEGIN  
				--Commented by Hardik 10/09/2012            
				If Not Exists(Select Tran_Id from dbo.t0160_Ot_Approval WITH (NOLOCK) where Emp_ID=@T_Emp_ID_3 And For_Date=@T_For_Date_3)  ----Commented By rohit under the Guidance by Miteshbhai for Showing Ot hours Without Approved. 07-dec-2012
					Begin  	           
							insert into #Data_Temp_3   
							select * from #Data where Emp_ID=@T_Emp_ID_3 And For_Date=@T_For_Date_3  						
						If @Flag_cur=1
							Begin
								Update #Data_Temp_3 Set OT_Sec = (OT_Sec* -1) Where  Emp_ID=@T_Emp_ID_3 And For_Date=@T_For_Date_3  
							End						
					End  
								
           
          fetch next from OT_cursor into @T_Emp_ID_3,@T_For_Date_3,@Flag_cur 
         END  
        CLOSE OT_cursor  
        DEALLOCATE OT_cursor 
        
         -- Added by rohit For match the ot hours  monthly ot and daily ot  on 04-dec-2012
        
         delete from #Data_Temp_3 Where Emp_Id = @Emp_Id and ( ISNULL(Weekoff_OT_Sec,0) = 0 or ISNULL(Holiday_OT_Sec,0) = 0)
						and For_Date in (Select Extra_Work_Date from dbo.T0120_CompOff_Approval WITH (NOLOCK) where Extra_Work_Date >= @From_Date and Extra_Work_Date <= @To_Date and Cmp_ID = @Cmp_ID and Emp_ID = @T_Emp_ID_3 and Approve_Status = 'A')
        
        update #Data_Temp_3 set OT_Sec=0 Where Emp_Id = @Emp_Id and ( ISNULL(Weekoff_OT_Sec,0) = 0 and ISNULL(Holiday_OT_Sec,0) = 0)
						and For_Date in (Select Extra_Work_Date from dbo.T0120_CompOff_Approval WITH (NOLOCK) where Extra_Work_Date >= @From_Date and Extra_Work_Date <= @To_Date and Cmp_ID = @Cmp_ID and Emp_ID = @T_Emp_ID_3 and Approve_Status = 'A')
		-- ended by rohit For match the ot hours for monthly ot and daily ot on 04-dec-2012				    
       
                  
                Declare @Emp_Temp table  
                (  
                    Emp_ID numeric(18,0),  
                    For_Date dateTime,  
                    Emp_full_Name varchar(50),  
                    Working_Hour Varchar(20),  
                    --Working_Hour numeric(18,5),  
                    OT_Hour numeric(18,5),
                    Weekoff_OT_Hour Numeric(18,5),
					Holiday_OT_Hour Numeric(18,5),
					P_Days numeric(18,2)  
                )  
                  
       insert into @Emp_Temp(Emp_ID,For_Date,Emp_full_Name,Working_Hour,OT_Hour,Weekoff_OT_Hour,Holiday_OT_Hour,P_Days)  
       --select OA.Emp_ID,Max(For_Date)For_Date,E.Emp_Full_Name, CONVERT(decimal(10,2), sum(Duration_in_Sec)/3600)   as Working_Hour ,CONVERT(decimal(10,2),(sum(OT_SEc)))  as OT_Hour ,sum(P_days) as Present_Days        
       Select OA.Emp_ID,Max(For_Date)For_Date,E.Emp_Full_Name,dbo.F_Return_Hours(Sum(Duration_in_Sec)) As Working_Hour ,CONVERT(decimal(10,2),(sum(OT_SEc)))  as OT_Hour ,CONVERT(decimal(10,2),(sum(Weekoff_OT_Sec)))  as Weekoff_OT_Sec,CONVERT(decimal(10,2),(sum(Holiday_OT_Sec))) as Holiday_OT_Sec,sum(P_days) as Present_Days
		From #Data_Temp_3  OA inner join dbo.T0080_emp_master E WITH (NOLOCK) on OA.Emp_ID = E.Emp_ID        
		where OT_sec > 0 or Weekoff_OT_Sec > 0 or Holiday_OT_Sec > 0       
		Group by OA.emp_ID,E.Emp_Full_Name     
      
   select OA1.Emp_ID,Max(For_Date)For_Date,E1.Emp_Full_Name,Working_Hour,dbo.F_Return_Hours(OT_HOur) as OT_Hour, P_days, E1.Emp_Superior,dbo.F_Return_Hours(Weekoff_OT_Hour) as Weekoff_OT_Hour,dbo.F_Return_Hours(Holiday_OT_Hour) as Holiday_OT_Hour,E1.branch_id
    From @Emp_Temp  OA1 inner join dbo.T0080_emp_master E1 WITH (NOLOCK) on OA1.Emp_ID = E1.Emp_ID        
    Group by OA1.emp_ID,E1.Emp_Full_Name ,For_Date,  Working_Hour,OT_Hour,P_days ,Emp_Superior ,Weekoff_OT_Hour,Holiday_OT_Hour,E1.branch_id 
   end  
    
  else if @Return_Record_set = 4        
   begin        
      
      
    --update #Data  Set OT_Sec = 0 From #Data         
    /*  
	declare @Emp_Id_Temp   numeric          
	declare @For_date datetime   
	 declare @Duration_in_sec numeric          
    declare @Emp_OT  numeric         
    declare @OT_Sec  numeric 
   
   declare curweekoff cursor Fast_forward for                    
  select    Duration_in_sec,Emp_Id,For_date,Emp_OT,OT_Sec from  #Data order by For_date
 open curweekoff                      
  fetch next from curweekoff into @Duration_in_sec,@Emp_Id_Temp,@For_date,@Emp_OT,@OT_Sec
  while @@fetch_status = 0                    
   begin                    
   
	if isnull(@Emp_OT,0)=1
		Begin
			if charindex(cast(left(@For_date,11) as varchar),@StrWeekoff_Date) >0
				Begin
					Update #Data set Duration_in_sec =0,Ot_sec=@OT_Sec+@Duration_in_sec,P_days=0 where Emp_Id=@Emp_Id_Temp
					And For_Date=@For_date
				
				End
		End
	
       
   fetch next from curweekoff into @Duration_in_sec,@Emp_Id_Temp,@For_date,@Emp_OT,@OT_Sec
   end                    
 close curweekoff                    
 deallocate curweekoff   
       */
        If @OT_Present =1 and @Auto_OT =1
         Begin      
					
	
					
				 --Update #Data         
					--set OT_Sec = isnull(Approved_OT_Sec,0) -- * 3600        
					--from #Data  d inner join T0160_OT_Approval OA on d.emp_ID = Oa.Emp_ID and d.For_Date = oa.For_Date 		
											
				
				Update #Data        
					set P_Days = P_Days + 0.5,OT_Sec=0   
				Where  OT_Sec >=3600 and OT_Sec <=18000         
				and Shift_ID= @shift_ID  and IO_Tran_Id  = 0  
				
				
				Update #Data        
					set P_Days = P_Days + 1,OT_Sec=0   
				Where  OT_Sec >=18001 and OT_Sec <=36000
				and Shift_ID= @shift_ID and IO_Tran_Id  = 0  
				
				
				Update #Data        
					set P_Days = P_Days + 1.5,OT_Sec=0     
				Where  OT_Sec >=36001 and OT_Sec <=54000
				and Shift_ID= @shift_ID and IO_Tran_Id  = 0  
				
				
				Update #Data        
					set P_Days = P_Days + 2.5,OT_Sec =0
				Where  OT_Sec >=54001 and OT_Sec <=99999
				and Shift_ID= @shift_ID and IO_Tran_Id  = 0  
				
				
         end
       Else if @OT_Present =0 and @Auto_OT =1
		Begin	
			
			update #Data         
			set OT_Sec = isnull(Approved_OT_Sec,0)  --* 3600        
			from #Data  d inner join dbo.T0160_OT_Approval OA on d.emp_ID = Oa.Emp_ID and d.For_Date = oa.For_Date         
      
		End    
	 Else if @OT_Present =0 and @Auto_OT =0
		Begin				
					  
		    Update #Data set OT_Sec =0
         
			update #Data         
			set OT_Sec = isnull(Approved_OT_Sec,0) -- * 3600        
			from #Data  d inner join dbo.T0160_OT_Approval OA on d.emp_ID = Oa.Emp_ID and d.For_Date = oa.For_Date         
      
		End    	
   End      
  If @Return_Record_set = 5
	Begin
	
	CREATE TABLE #Data_Temp_5         
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
		   OT_Sec  numeric default 0,
		   In_Time datetime,
		   Shift_Start_Time  datetime ,
		   OT_Start_Time numeric default 0 ,
		   Shift_Change tinyint default 0,
           Flag int default 0       ,
		   Weekoff_OT_Sec Numeric Default 0,
		   Holiday_OT_Sec Numeric Default 0,
		   Chk_By_Superior numeric default 0,
		   IO_Tran_Id	   numeric default 0, -- io_tran_id is used for is_cmp_purpose (t0150_emp_inout)
		   OUT_Time Datetime,
		   Shift_End_Time datetime,			--Ankit 16112013
		   OT_End_Time numeric default 0,	--Ankit 16112013
		   Working_Hrs_St_Time tinyint default 0, --Hardik 14/02/2014
		   Working_Hrs_End_Time tinyint default 0 --Hardik 14/02/2014	

       )   
       
        Declare @Temp Table
       (
			Emp_ID numeric ,
			For_Date datetime,
			p_Days numeric(12,3) default 0,
			OT_Sec numeric default 0,
			Weekoff_OT_Sec Numeric Default 0,
		    Holiday_OT_Sec Numeric Default 0,
			OT_Hours Numeric(18,5),
			Flag int default 0,
			Weekoff_OT_Hour Numeric(18,5),
			Holiday_OT_Hour Numeric(18,5)
       )
        
       Declare @T_Emp_ID_5 Numeric  
       Declare @T_For_Date_5 datetime  
       Declare @Flag_cur_5 As Int
       
        --delete from #Data_Temp_5  
        Truncate Table #Data_Temp_5  --Hardik 15/02/2013
        
        DECLARE OT_cursor CURSOR  
        FOR  
           SELECT Emp_ID,For_Date,Flag FROM #Data   
         OPEN OT_cursor  
          fetch next from OT_cursor into @T_Emp_ID_5,@T_For_Date_5,@Flag_cur_5    
          while @@fetch_status = 0  
         BEGIN  
            
					insert into #Data_Temp_5   
					select  * from #Data where Emp_ID=@T_Emp_ID_5 And For_Date=@T_For_Date_5  

 
			         
			        Insert Into @Temp
			        select Emp_Id,For_Date,P_Days,OT_sec,weekoff_ot_sec,Holiday_OT_Sec,cast(Round(OT_Sec/3600,2)as numeric(18,2)),flag,cast(Round(Weekoff_OT_Sec/3600,2)as numeric(18,2)),cast(Round(Holiday_OT_Sec/3600,2)as numeric(18,2))
			         From #Data where Emp_ID=@T_Emp_ID_5 And For_Date=@T_For_Date_5
			        --select Emp_Id,For_Date,P_Days,OT_sec,dbo.F_Return_Hours(OT_Sec),flag From #Data where Emp_ID=@T_Emp_ID_5 And For_Date=@T_For_Date_5  
			        
			        If @Flag_cur_5=1
						Begin 
							Update @temp Set Ot_Sec = (Ot_Sec * -1),Weekoff_OT_Sec = (Weekoff_OT_Sec * -1),Holiday_OT_Sec = (Holiday_OT_Sec * -1)
							 Where Emp_ID=@T_Emp_ID_5 And For_Date=@T_For_Date_5 And Flag=1
							--Update @temp Set OT_Hours = dbo.F_Return_Hours(OT_Sec) Where Emp_ID=@T_Emp_ID_5 And For_Date=@T_For_Date_5 And Flag=1
							Update @temp Set OT_Hours = '-'+ OT_Hours, Weekoff_OT_Hour = '-'+ Weekoff_OT_Hour, Holiday_OT_Hour = '-'+ Holiday_OT_Hour
							  Where Emp_ID=@T_Emp_ID_5 And For_Date=@T_For_Date_5 And Flag=1
						End		
             
          fetch next from OT_cursor into @T_Emp_ID_5,@T_For_Date_5,@Flag_cur_5   
         END  
        CLOSE OT_cursor  
        DEALLOCATE OT_cursor  
          
                Declare @Emp_Temp_5 table  
                (  
                    Emp_ID numeric(18,0),  
                    For_Date dateTime,  
                    Emp_full_Name varchar(50),  
                    --Working_Hour Varchar(20),  
                    Working_Hour numeric(18,5),  
                    OT_Hour numeric(18,5),  
                    P_Days numeric(18,2),
					Weekoff_OT_Hour Numeric(18,5),
					Holiday_OT_Hour Numeric(18,5)   
                ) 
      
	  
							insert into @Emp_Temp_5(Emp_ID,For_Date,Emp_full_Name,Working_Hour,OT_Hour,P_Days,Weekoff_OT_Hour,Holiday_OT_Hour)  
							select OA.Emp_ID,Max(For_Date)For_Date,E.Emp_Full_Name, CONVERT(decimal(10,2), sum(Duration_in_Sec)/3600)   as Working_Hour ,CONVERT(decimal(10,2),(sum(OT_SEc)))  as OT_Hour ,sum(P_days) as Present_Days , CONVERT(decimal(10,2),(sum(Weekoff_OT_Sec)))  as Weekoff_OT_Hour,CONVERT(decimal(10,2),(sum(Holiday_OT_Sec)))  as Holiday_OT_Hour       
							--Select OA.Emp_ID,Max(For_Date)For_Date,E.Emp_Full_Name,dbo.F_Return_Hours(Sum(Duration_in_Sec)) As Working_Hour ,CONVERT(decimal(10,2),(sum(OT_SEc)))  as OT_Hour ,sum(P_days) as Present_Days        
							From #Data_Temp_5  OA inner join dbo.T0080_emp_master E WITH (NOLOCK) on OA.Emp_ID = E.Emp_ID     
							Group by OA.emp_ID,E.Emp_Full_Name     	
							---Select * from #data_temp	
							
							insert into #Data_MOTIF
							--Select Emp_ID,For_Date,p_Days, dbo.F_Return_Hours(OT_SEc),Flag From #Data_Temp_5   OA          							
							Select Emp_ID,For_Date,p_Days,OT_Hours,Weekoff_OT_Hour,Holiday_OT_Hour  From @temp   OA          							
							Order by OA.For_Date     
							--End    					
									
																
							insert into #Att_Detail   
  							Select OA1.Emp_ID,P_days,dbo.F_Return_Hours(OT_HOur),0,0,0,0,0,0,0,dbo.F_Return_Hours(Weekoff_OT_Hour),dbo.F_Return_Hours(Holiday_OT_Hour)
							From @Emp_Temp_5  OA1 inner join dbo.T0080_emp_master E1 WITH (NOLOCK) on OA1.Emp_ID = E1.Emp_ID          
							Group by OA1.emp_ID,E1.Emp_Full_Name ,For_Date,  Working_Hour,OT_Hour,P_days ,Weekoff_OT_Hour,Holiday_OT_Hour
							
    -- insert into @Emp_Temp_5(Emp_ID,For_Date,Emp_full_Name,Working_Hour,OT_Hour,P_Days)  
   --      select OA.Emp_ID,Max(For_Date)For_Date,E.Emp_Full_Name, CONVERT(decimal(10,2), sum(Duration_in_Sec)/3600)   as Working_Hour ,CONVERT(decimal(10,2),(sum(OT_SEc)))  as OT_Hour ,sum(P_days) as Present_Days        
   --      From #Data_Temp_5  OA inner join T0080_emp_master E on OA.Emp_ID = E.Emp_ID        
   --      Group by OA.emp_ID,E.Emp_Full_Name     
     
	
		 --insert into #Data_MOTIF
		 --select Emp_ID,For_Date,p_Days, dbo.F_Return_Hours (OT_SEc)   from #Data_Temp   OA          
		 --order by OA.For_Date      
		
		
	  --   insert into #Att_Detail   
  	--     select OA1.Emp_ID,P_days,dbo.F_Return_Hours(OT_HOur),0,0,0,0,0,0,0  
	  --   From @Emp_Temp_5  OA1 inner join T0080_emp_master E1 on OA1.Emp_ID = E1.Emp_ID          
	  --   Group by OA1.emp_ID,E1.Emp_Full_Name ,For_Date,  Working_Hour,OT_Hour,P_days 
	     
	End      	
	
 RETURN    

