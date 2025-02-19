



CREATE PROCEDURE [dbo].[SP_CALCULATE_PRESENT_DAYS_15062012]        
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
 ,@constraint   varchar(5000)        
 ,@Return_Record_set numeric = 1 
 ,@StrWeekoff_Date varchar(Max)  =''
AS        
   SET NOCOUNT ON 
   SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
   SET ARITHABORT ON           
           
Declare @Count   numeric         
Declare @Tmp_Date datetime         
set @Tmp_Date = @From_Date        


if @Return_Record_set = 1 or @Return_Record_set = 2 or @Return_Record_set =3  or @Return_Record_set = 5 or @Return_Record_set = 8--or @Return_Record_set = 7        
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
	   P_days  numeric(12,1) default 0,        
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
	   OUT_Time datetime
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
	   P_days  numeric(12,1) default 0,        
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
	   OUT_Time datetime
   )        
 end        
        
  
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
          
 Declare @Emp_Cons Table        
 (        
  Emp_ID numeric        
 )        
         

 if @Constraint <> ''        
  begin        
   Insert Into @Emp_Cons(Emp_ID)        
   select  cast(data  as numeric) from dbo.Split (@Constraint,'#')         
  end        
 else        
  begin        
          
      Insert Into @Emp_Cons(Emp_ID)        
        
	select I.Emp_Id from T0095_Increment I WITH (NOLOCK) inner join         
	( select max(Increment_effective_Date) as For_Date , Emp_ID From T0095_Increment WITH (NOLOCK)       
	where Increment_Effective_date <= @To_Date        
	and Cmp_ID = @Cmp_ID        
	group by emp_ID  ) Qry on        
	I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date         
               
   Where Cmp_ID = @Cmp_ID         
   and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))        
   and Branch_ID = isnull(@Branch_ID ,Branch_ID)        
   and Grd_ID = isnull(@Grd_ID ,Grd_ID)        
   and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))        
   and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))        
   and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))        
   and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID)         
  end        
  
	declare @curEmp_ID numeric
	
	Declare curautobranch cursor for	                  
	select Emp_ID from @Emp_Cons 
	Open curautobranch                      
	Fetch next from curautobranch into @curEmp_ID
	   
		While @@fetch_status = 0                    
		Begin     
         
			Declare @First_In_Last_Out_For_InOut_Calculation tinyint 
			
			declare @cBrh as numeric
			
			select @cBrh  = Branch_ID from T0095_Increment EI WITH (NOLOCK) where Increment_Effective_Date in (select max(Increment_effective_Date) as Increment_effective_Date from T0095_Increment WITH (NOLOCK) where Increment_Effective_date <= @From_Date  and Cmp_ID = @Cmp_ID and Emp_ID = @curEmp_ID) and Emp_ID = @curEmp_ID
			select @First_In_Last_Out_For_InOut_Calculation  = First_In_Last_Out_For_InOut_Calculation from T0040_GENERAL_SETTING WITH (NOLOCK) where Branch_ID = @cBrh  and For_Date in (select MAX(For_Date) as for_date from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <= @From_Date and Cmp_ID = Cmp_ID and Branch_ID = @cBrh) and Cmp_ID = @Cmp_ID			
			
			if @First_In_Last_Out_For_InOut_Calculation = 1
				Begin				
				
					----- changed to get record with only Min(InTime) and Max(OutTime) ------

						  Insert into #Data (Emp_ID,For_Date,Duration_In_sec,Emp_OT,Emp_OT_min_Limit,Emp_OT_max_Limit,In_Time,Shift_Start_Time,OT_Start_Time,Shift_Change,Chk_By_Superior,IO_Tran_Id,OUT_Time)        
					              
					   select distinct eir.Emp_ID ,EIR.for_Date,isnull(datediff(s,In_Date,out_Date),0) ,isnull(Emp_OT,0),dbo.F_Return_Sec(Emp_OT_min_Limit),dbo.F_Return_Sec(Emp_OT_max_Limit),In_Date,null,0,0,isnull(Q3.Chk_By_Sup,0),isnull(EIR.is_cmp_purpose ,0),Out_Date 
					   from T0150_emp_inout_Record  EIR WITH (NOLOCK) Inner join @Emp_Cons Ec on EIR.Emp_Id = ec.Emp_ID inner Join        
						(select I.Emp_ID,Emp_OT,isnull(Emp_OT_min_Limit,'00:00')Emp_OT_min_Limit,isnull(Emp_OT_max_Limit,'00:00')Emp_OT_max_Limit from T0095_Increment  I WITH (NOLOCK) inner join         
						(select max(increment_effective_Date)IE_Date ,Emp_ID from T0095_Increment WITH (NOLOCK)      
						 where increment_effective_Date <=@To_Date and Cmp_ID =@Cmp_ID group by Emp_ID)q on I.emp_ID =q.Emp_ID and         
						I.Increment_effective_Date = q.IE_Date ) IQ on eir.Emp_ID =iq.emp_ID 
						Inner Join
						(select Emp_Id, Min(In_Time) In_Date,For_Date From T0150_Emp_Inout_Record WITH (NOLOCK) Group By Emp_Id,For_Date) Q1 on EIR.Emp_Id = Q1.Emp_Id 
						And EIR.For_Date = Q1.For_Date
						Inner Join
						(select Emp_Id, Max(Out_Time) Out_Date,For_Date From T0150_Emp_Inout_Record WITH (NOLOCK) Group By Emp_Id,For_Date) Q2 on EIR.Emp_Id = Q2.Emp_Id 
						And EIR.For_Date = Q2.For_Date
						Left Outer Join 
						(Select Emp_ID,Chk_By_Superior Chk_By_Sup,For_Date from T0150_EMP_INOUT_RECORD WITH (NOLOCK) where Chk_By_Superior=1) Q3 on EIR.Emp_Id = Q3.Emp_Id 
						And EIR.For_Date = Q3.For_Date
					   Where cmp_Id= @Cmp_ID        
					   and EIR.for_Date >=@From_Date and EIR.For_Date <=@To_Date  and ec.Emp_ID = @curEmp_ID      
					   group by eir.Emp_ID,eir.For_Date,Emp_OT,Emp_OT_min_Limit,Emp_OT_max_Limit,In_Time,In_Date,out_Date,Chk_By_Sup ,EIR.is_cmp_purpose,OUT_Time 
					   order by EIR.For_Date
					 ------------------end--------------------
					  
				End
			Else
				Begin

					Insert into #Data (Emp_ID,For_Date,Duration_In_sec,Emp_OT,Emp_OT_min_Limit,Emp_OT_max_Limit,In_Time,Shift_Start_Time,OT_Start_Time,Shift_Change,Chk_By_Superior,IO_Tran_Id,OUT_Time)        
				      
					  select eir.Emp_ID ,EIR.for_Date,sum(isnull(datediff(s,in_time,out_time),0)) ,isnull(Emp_OT,0),dbo.F_Return_Sec(Emp_OT_min_Limit),dbo.F_Return_Sec(Emp_OT_max_Limit),In_Time,null,0,0,Chk_By_Superior,isnull(EIR.is_cmp_purpose ,0),Out_Time 
					   from T0150_emp_inout_Record  EIR WITH (NOLOCK) Inner join @Emp_Cons Ec on EIR.Emp_Id = ec.Emp_ID inner Join			
						(select I.Emp_ID,Emp_OT,isnull(Emp_OT_min_Limit,'00:00')Emp_OT_min_Limit,isnull(Emp_OT_max_Limit,'00:00')Emp_OT_max_Limit from T0095_Increment  I WITH (NOLOCK) inner join         
						(select max(increment_effective_Date)IE_Date ,Emp_ID from T0095_Increment WITH (NOLOCK)         
						 where increment_effective_Date <=@To_Date and Cmp_ID =@Cmp_ID group by Emp_ID)q on I.emp_ID =q.Emp_ID and         
						I.Increment_effective_Date = q.IE_Date ) IQ on eir.Emp_ID =iq.emp_ID 
											       
					   Where cmp_Id= @Cmp_ID        
					   and EIR.for_Date >=@From_Date and EIR.For_Date <=@To_Date and ec.Emp_ID = @curEmp_ID
					   group by eir.Emp_ID,eir.For_Date,Emp_OT,Emp_OT_min_Limit,Emp_OT_max_Limit,In_Time,Chk_By_Superior ,EIR.is_cmp_purpose,Out_Time  
					   order by EIR.For_Date
					   
				End				
			
			fetch next from curautobranch into @curEmp_ID
		  
		end                    
	close curautobranch                    
	deallocate curautobranch
	 
	 
	   
	 --- Start Cursor curAttRegularize -> cursor for regularize attendance Alpesh 09-Dec-2011
	 --declare @shift_st_time datetime
	 --declare @shift_end_time datetime
	 --declare @temp_st_time datetime
	 --declare @temp_end_time datetime
	 --declare @attEmpId numeric
	 --declare @attFor_Date datetime
	 --declare @attIO_Tran_Id Numeric			
				
	 
	 --if @First_In_Last_Out_For_InOut_Calculation = 1
	 --  Begin	 
		-- declare curAttRegularize cursor for select Emp_ID,For_Date from #Data where Chk_By_Superior = 1
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
	 --  	 declare curAttRegularize cursor for select Emp_ID,For_Date,IO_Tran_Id from #Data where Chk_By_Superior = 1
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
           
		Delete From #Data          
		Insert Into #data 
		select * from @Data_temp1
		
			
		
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
  
  
   Update #Data        
     set Shift_ID   = Q1.Shift_ID,          
   Shift_Type = q1.Shift_type 
     from #Data d inner Join        
     (select q.Shift_ID ,q.Emp_ID,shift_type,q.For_Date from T0100_Emp_Shift_Detail sd WITH (NOLOCK) inner join        
     (select for_Date ,Emp_Id,Shift_ID   from T0100_Emp_Shift_Detail    as esdsub WITH (NOLOCK)      
     where Cmp_Id =@Cmp_ID and shift_Type = 0 and for_Date = (select max(for_Date) from T0100_Emp_Shift_Detail WITH (NOLOCK) where emp_id = esdsub.emp_id and Cmp_Id =@Cmp_ID and shift_Type = 0 and For_Date <= @Tmp_Date ) )q on sd.Emp_ID =q.Emp_ID and sd.For_Date =q.For_Date)q1  on d.emp_ID = q1.emp_ID         
    Where D.For_Date = @tmp_Date     
       
                                 
  Update #Data        
    set Shift_ID   = Q1.Shift_ID,          
  Shift_Type = q1.Shift_type        
  from #Data d inner Join        
    (select q.Shift_ID ,q.Emp_ID,shift_type,q.For_Date from T0100_Emp_Shift_Detail   sd WITH (NOLOCK) inner join        
    (select for_Date ,Emp_Id,Shift_ID   from T0100_Emp_Shift_Detail          as esdsub   WITH (NOLOCK)
     where Cmp_Id =@Cmp_ID and shift_Type = 1 and for_Date = (select max(for_Date) from T0100_Emp_Shift_Detail WITH (NOLOCK) where  emp_id = esdsub.emp_id and Cmp_Id =@Cmp_ID and  shift_Type = 1 and For_Date <= @Tmp_Date ) )q on sd.Emp_ID =q.Emp_ID and sd.For_Date =q.For_Date)q1  on d.emp_ID = q1.emp_ID         
   Where D.For_Date = @tmp_Date 


   Update #Data
    set Shift_Start_Time = q.Shift_St_Time,
    OT_Start_Time=isnull(q.OT_Start_Time,0) 
    from #data d inner join 
    (select ST.Shift_st_time,ST.Shift_ID,isnull(SD.OT_Start_Time,0) as OT_Start_Time from t0040_shift_master ST WITH (NOLOCK) left outer join t0050_shift_detail SD WITH (NOLOCK)
    on ST.Shift_ID=SD.Shift_ID ) q on d.shift_id=q.shift_id
   
  Update #Data set Shift_Start_Time= cast(CONVERT(VARCHAR(11), In_time, 121)  + CONVERT(VARCHAR(12), Shift_Start_Time, 114) as datetime)  from #Data
    set @Tmp_Date = dateadd(d,1,@tmp_date)            
 end  
 Update #Data set Shift_Change=1 where isnull(datediff(s,in_time,Shift_Start_Time),0)  < -14400  
 Update #Data set Shift_Change=1 where isnull(datediff(s,in_time,Shift_Start_Time),0)  > 14400  
 
 

Declare @Emp_ID_AutoShift numeric
Declare @In_Time_Autoshift datetime
Declare @New_Shift_ID numeric
 Declare curautoshift cursor for	                  
  select Emp_ID,In_Time,Shift_ID from #Data where isnull(Shift_Change,0)=1 And isnull(Emp_OT,0)=1 order by In_time,Emp_ID
	Open curautoshift                      
	  Fetch next from curautoshift into @Emp_ID_AutoShift,@In_Time_Autoshift,@New_Shift_ID
               
		While @@fetch_status = 0                    
			Begin     
               
       --select  @Emp_ID_AutoShift,@In_Time_Autoshift
			Declare @Shift_ID_Autoshift numeric
			Declare @Shift_start_time_Autoshift varchar(12)
	        Select @Shift_ID_Autoshift=Shift_ID,@Shift_start_time_Autoshift=Shift_st_time from t0040_shift_master WITH (NOLOCK) where cmp_id=@Cmp_id and isnull(inc_auto_shift,0)=1
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
    set OT_Start_Time=isnull(q.OT_Start_Time,0) 
    from #data d inner join 
    (select ST.Shift_st_time,ST.Shift_ID,isnull(SD.OT_Start_Time,0) as OT_Start_Time from t0040_shift_master ST WITH (NOLOCK) left outer join t0050_shift_detail SD WITH (NOLOCK)
    on ST.Shift_ID=SD.Shift_ID ) q on d.shift_id=q.shift_id where isnull(d.shift_Change,0)=1
 
 
 update #Data set Duration_in_sec = Duration_in_sec - datediff(s,In_time,Shift_Start_Time)
 where datediff(s,In_time,Shift_Start_Time) > 0  And isnull(Emp_OT,0)=1 And isnull(OT_Start_Time,0)=1
 
  Update #Data        
  set Shift_ID   = Q1.Shift_ID,          
   Shift_Type = q1.Shift_type        
  from #Data d inner Join        
  (select sd.shift_ID ,sd.Emp_ID,shift_type,sd.For_Date from T0100_Emp_Shift_Detail   sd  WITH (NOLOCK)       
  Where Cmp_ID =@Cmp_ID and Shift_Type =1 and For_Date >=@From_Date and For_Date <=@To_Date )q1 on        
  D.emp_ID = q1.For_Date And d.For_Date =Q1.For_Date   
  
 Declare @Emp_WeekOFf_Detail Table        
 (        
  Emp_ID numeric        ,
  Strweekoff varchar(max)    
 )  

insert into @Emp_WeekOFf_Detail 
select Emp_ID,'' from @Emp_Cons

Declare @Emp_Week_Detail numeric(18,0)
Declare @strweekoff varchar(max)
Declare @Is_Negative_Ot Int ---For negative yes or no take its value from general setting
 declare curEmp_weekoff_Detail cursor for                    
  select    Emp_ID from  @Emp_Cons order by Emp_ID
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
 
	select @Week_oF_Branch=Branch_ID  from t0095_increment WITH (NOLOCK) where Increment_id in (select Max(Increment_id) from t0095_increment WITH (NOLOCK) where emp_id=@Emp_Week_Detail)
	
 
	Select @Is_Cancel_weekoff = Is_Cancel_weekoff ,@tras_week_ot=isnull(tras_week_ot,0)  ,@Auto_OT = Is_OT_Auto_Calc ,@OT_Present = OT_Present_days,@Is_Negative_Ot = ISNULL(Is_Negative_Ot,0), @Is_Compoff = ISNULL(Is_CompOff, 0), @Is_WD = ISNULL(Is_CompOff_WD,0), @Is_WOHO = ISNULL(Is_CompOff_WOHO,0)
		From T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID and Branch_ID = @Week_oF_Branch    
		and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@To_Date and Branch_ID = @Week_oF_Branch and Cmp_ID = @Cmp_ID)    
	
  
			set @StrWeekoff_Date=''
			set @Weekoff_Days=0
			set @Cancel_Weekoff=0
			Exec SP_EMP_WEEKOFF_DATE_GET @Emp_Week_Detail,@Cmp_ID,@From_Date,@To_Date,null,null,@Is_Cancel_weekoff,'',@StrWeekoff_Date output,@Weekoff_Days output ,@Cancel_Weekoff output    



	if isnull(@tras_week_ot,0)=1
		Begin	
			-- Alpesh 17-Aug-2011 For Including Holiday with WeekOff into OT Calculation
			declare @H_From_Date datetime
			declare @H_To_Date datetime
			
			declare cur1 cursor for 
			select h_from_date,h_to_date  from t0040_holiday_master WITH (NOLOCK) 
			where cmp_Id = @Cmp_ID
			and ( (convert(varchar(10),@From_Date,120)>=convert(varchar(10),h_from_date,120) and convert(varchar(10),@From_Date,120)<=convert(varchar(10),h_to_date,120))
			or (convert(varchar(10),@To_Date,120)>=convert(varchar(10),h_from_date,120) and convert(varchar(10),@To_Date,120)<=convert(varchar(10),h_to_date,120))
			or (convert(varchar(10),h_from_date,120)>=convert(varchar(10),@From_Date,120) and convert(varchar(10),h_from_date,120)<=convert(varchar(10),@To_Date,120))
			or (convert(varchar(10),h_to_date,120)>=convert(varchar(10),@From_Date,120) and convert(varchar(10),h_to_date,120)<=convert(varchar(10),@To_Date,120)) )
			order by H_from_date

			open cur1
			fetch next from cur1 into @H_From_Date,@H_To_Date

			while @@fetch_status = 0
			begin
				if @H_From_Date = @H_To_Date
					set @StrWeekoff_Date= @StrWeekoff_Date+';'+convert(varchar(11),@H_From_Date,100)
				else 
					begin
						while @H_From_Date <= @H_To_Date
						begin
							set @StrWeekoff_Date= @StrWeekoff_Date+';'+ convert(varchar(11),@H_From_Date,100)
							set @H_From_Date = dateadd(d,1,@H_From_Date)
							
						end
					end
			fetch next from cur1 into @H_From_Date,@H_To_Date
			end
			close cur1
			deallocate cur1
			------------------------------End-------------------------------
		End
	Update 	@Emp_WeekOFf_Detail set Strweekoff=@StrWeekoff_Date where Emp_ID=@Emp_Week_Detail
	

	if @Return_Record_set = 5
		Begin 
			Insert into #Data_Weekoff values(@Emp_Week_Detail,@Weekoff_Days)
			
		End
	fetch next from curEmp_weekoff_Detail into @Emp_Week_Detail
   end                    
 close curEmp_weekoff_Detail                    
 deallocate curEmp_weekoff_Detail   
 
 	declare @Emp_Id_Temp1   numeric          
	declare @For_date1 datetime   
	declare @Duration_in_sec1 numeric          
    declare @Emp_OT1  numeric         
    declare @OT_Sec1  numeric 


		
   declare curweekoff cursor for                    
  select    Duration_in_sec,Emp_Id,For_date,Emp_OT,OT_Sec from  #Data  order by For_date
 open curweekoff                      
  fetch next from curweekoff into @Duration_in_sec1,@Emp_Id_Temp1,@For_date1,@Emp_OT1,@OT_Sec1
  while @@fetch_status = 0                    
   begin                    
   
	if isnull(@Emp_OT1,0)=1
		Begin
			Declare @Final_weekoff_str varchar(max)
			set @Final_weekoff_str=''
			select @Final_weekoff_str = isnull(Strweekoff,'') from @Emp_WeekOFf_Detail where emp_id=@Emp_Id_Temp1
		
			if charindex(cast(left(@For_date1,11) as varchar),@Final_weekoff_str) >0
				Begin
						
					Update #Data set Duration_in_sec =0,Ot_sec=@OT_Sec1+@Duration_in_sec1,P_days=0 where Emp_Id=@Emp_Id_Temp1
					And For_Date=@For_date1
				
				End
		End
	fetch next from curweekoff into @Duration_in_sec1,@Emp_Id_Temp1,@For_date1,@Emp_OT1,@OT_Sec1
   end                    
 close curweekoff                    
 deallocate curweekoff   
 
          
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
		  ,Shift_Dur ,isnull(Fix_W_Hours,0) as  Fix_W_Hours        
		   from T0050_shift_detail sd WITH (NOLOCK) inner join         
		  T0040_shift_master sm WITH (NOLOCK) on sd.shift_ID= sm.Shift_ID inner join         
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
					set P_Days = @Calculate_Days, Duration_in_sec = @Fix_W_Hours * 3600        
					Where Duration_in_sec >=( @From_hour * 3600) and Duration_in_sec <= ( @To_Hour * 3600 )        
					and Shift_ID= @shift_ID        and IO_Tran_Id  = 0   
			end        
			 else        
			begin        
					
					Update #Data        
					set P_Days = @Calculate_Days        
					Where Duration_in_sec >= (@From_hour * 3600) and Duration_in_sec <= ( @To_Hour * 3600 )        
					and Shift_ID= @shift_ID        and IO_Tran_Id  = 0   
			end        
		   
		   If @OT_Applicable =1         
			begin            
			   if @Fix_OT_Hours > 0         
				   begin        
					
						Update #Data        
						 set P_Days = @Calculate_Days,        
						  OT_Sec = @Fix_OT_Hours * 3600         
						   Where Duration_in_sec >=@From_hour * 3600 and Duration_in_sec <=@To_Hour * 3600         
						  and Emp_OT= 1 and Shift_ID= @shift_ID      and IO_Tran_Id  = 0     
				   end        
				 else if @Minimum_Hour > 0         
				   begin        
						
						Update #Data        
						 set P_Days = @Calculate_Days,        
						  OT_Sec = Duration_in_sec - @Minimum_Hour * 3600 ,
						  Duration_in_sec=  @Minimum_Hour * 3600         
						 Where Duration_in_sec >=@From_hour * 3600 and Duration_in_sec <=@To_Hour * 3600         
						  and Emp_OT= 1 and Shift_ID= @shift_ID         and IO_Tran_Id  = 0  
				   end        
				 else if @Minimum_Hour = 0         
					Begin        
						
						Update #Data        
						set P_Days = @Calculate_Days,        
							OT_Sec = Duration_in_sec - @Shift_Dur_sec  ,        
							Duration_in_sec= @Shift_Dur_sec        
							Where Duration_in_sec >=@From_hour * 3600 and Duration_in_sec <=@To_Hour * 3600         
							and Emp_OT= 1 and Duration_in_sec > @Shift_Dur_sec        
							and Shift_ID= @shift_ID    and IO_Tran_Id  = 0
							
							Select @Ot_Sec_Neg=Isnull(Ot_Sec,0)From #Data Where OT_Sec < 1--Nikunj

						If	@Ot_Sec_Neg < 1 And Isnull(@Is_Negative_Ot,0)=1--And Duration_In_sec < @Shift_Dur_sec --logic Of Negative ot			
							Begin					
								Update #Data				
								Set OT_Sec = @Shift_Dur_sec - Duration_in_sec,Flag=1
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
	
	select @ShiftId=SM.Shift_id,@WeekDay=SM.Week_Day,@HalfStartTime=SM.Half_St_Time,@HalfEndTime=SM.Half_End_Time,@HalfDuration=SM.Half_Dur,@HalfMinDuration=SM.Half_min_duration from T0040_SHIFT_MASTER SM WITH (NOLOCK) inner join         
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
							where For_date = @curForDate and Duration_in_sec >= dbo.F_Return_Sec(@HalfMinDuration)   and IO_Tran_Id  = 0
							
						update #Data  set
							P_days = 0
							where For_date = @curForDate and Duration_in_sec < dbo.F_Return_Sec(@HalfMinDuration)   and IO_Tran_Id  = 0
							
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
	where TEIR.For_Date >= @From_Date and TEIR.For_Date <= @To_Date   and d.IO_Tran_Id  = 0 
	
	
	update #Data 
	set P_days = 0.5 from #Data d inner join  T0150_EMP_INOUT_RECORD TEIR 
	on TEIR.Emp_Id = d.Emp_Id and TEIR.Chk_By_Superior = 1 and TEIR.For_Date = d.For_date and ( TEIR.Half_Full_day = 'First Half' or TEIR.Half_Full_day = 'Second Half')
	where TEIR.For_Date >= @From_Date and TEIR.For_Date <= @To_Date   and d.IO_Tran_Id  = 0 
	
	update dbo.#Data 
	set P_days = (P_days - 0.5) from #Data d inner join  
				(select For_Date,Emp_ID from dbo.T0140_LEAVE_TRANSACTION WITH (NOLOCK)
					where leave_used = 0.5 and 
					For_Date >= @From_Date and 
					For_Date <= @To_Date and (isnull(eff_in_salary,0) <> 1 
					or (isnull(eff_in_salary,0) = 1 and Leave_Used > 0)
					)) Qry on 
				Qry.For_Date = d.For_date and Qry.Emp_ID = d.Emp_Id where    IO_Tran_Id  = 0 and P_days =1
	
	---- end below update statment added by mitesh for regularization as only full day on 09/01/2012.
 
--------------------Added by Mitesh on 15/09/2011 for Shift Half Day ----------------------------
    
    update #Data         
   set OT_Sec = isnull(Approved_OT_Sec,0) -- * 3600        
    from #Data  d inner join T0160_OT_Approval OA on d.emp_ID = Oa.Emp_ID and d.For_Date = oa.For_Date         
           
  Update #Data        
   set OT_Sec = 0         
   where Emp_OT_Min_Limit >= OT_sec and OT_sec > 0        
        
  Update #Data        
   set OT_Sec = Emp_OT_Max_Limit        
  where OT_sec  > Emp_OT_Max_Limit  and Emp_OT_Max_Limit > 0 and OT_sec >0    
  
  
---Add by Hardik for Diferentiate Weekoff OT And Holiday OT 

 Declare @Is_Cancel_Holiday  Numeric(1,0)    
 Declare @Is_Cancel_Weekoff_OT  Numeric(1,0)    
 Declare @Join_Date    Datetime    
 Declare @Left_Date    Datetime     
 Declare @StrHoliday_Date  varchar(max)    
 Declare @StrWeekoff_Date_OT  varchar(max)    
 Declare @Holiday_Days   Numeric(12,1)
 Declare @Weekoff_Days_OT   Numeric(12,1)
 Declare @Cancel_Holiday   Numeric(12,1)
 Declare @Cancel_Weekoff_OT   Numeric(12,1)
 Declare @Emp_Id_Cur Numeric
 Declare @For_Date Datetime
 Declare @WeekOff_Work_Sec Numeric
 Declare @Holiday_Work_Sec Numeric
 
 Set @Is_Cancel_Weekoff_OT = 0
 Set @Is_Cancel_Holiday = 0    
 Set @StrHoliday_Date = ''    
 Set @StrWeekoff_Date_OT = '' 
 Set @Holiday_Days  = 0    
 Set @Weekoff_Days_OT  = 0    
 Set @Cancel_Holiday  = 0    
 Set @Cancel_Weekoff_OT  = 0  

	Select @Is_Cancel_Holiday = Is_Cancel_Holiday,@Is_Cancel_Weekoff_OT = Is_Cancel_Weekoff    
	From T0040_GENERAL_SETTING WITH (NOLOCK)
	Where cmp_ID = @cmp_ID and Branch_ID = @Branch_ID    
	and For_Date = (select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@To_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)    
	
		
	Declare Cur_HO cursor for
		Select Emp_Id,For_Date from #Data --Where OT_Sec > 0
	open Cur_HO
	fetch next from Cur_HO into @Emp_Id_Cur,@For_Date
	While @@Fetch_Status=0
	   begin
	   
	  
		Select @Branch_ID = I.Branch_ID  from T0095_Increment I WITH (NOLOCK) inner join         
		( select max(Increment_effective_Date) as For_Date , Emp_ID From T0095_Increment WITH (NOLOCK)      
		where Increment_Effective_date <= @To_Date        
		and Cmp_ID = @Cmp_ID And Emp_ID = @Emp_Id_Cur
		group by emp_ID  ) Qry on        
		I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date 
		Where I.Emp_ID = @Emp_Id_Cur
								
			Exec SP_EMP_WEEKOFF_DATE_GET @Emp_ID_Cur,@Cmp_ID,@From_Date,@To_Date,@Join_Date,@left_Date,@Is_Cancel_Weekoff_OT,@StrHoliday_Date,@StrWeekoff_Date_OT output,@Weekoff_Days_OT output ,@Cancel_Weekoff_OT output   
			Exec SP_EMP_HOLIDAY_DATE_GET @Emp_ID_Cur,@Cmp_ID,@From_Date,@To_Date,@Join_Date,@left_Date,@Is_Cancel_Holiday,@StrHoliday_Date output,@Holiday_days output,@Cancel_Holiday output,0,@Branch_ID,@StrWeekoff_Date_OT
			
			if charindex(cast(@For_Date as varchar(11)),@StrWeekoff_Date_OT,0) > 0
				begin
					--Update #Data Set Duration_in_sec = 0, OT_Sec = 0, Weekoff_OT_Sec = Duration_in_sec +  OT_Sec Where For_date = @For_Date And Emp_Id = @Emp_Id_Cur
					Update #Data Set  OT_Sec = 0, Weekoff_OT_Sec = OT_Sec Where For_date = @For_Date And Emp_Id = @Emp_Id_Cur
				end 
			else if charindex(cast(@For_Date as varchar(11)),@StrHoliday_Date,0) > 0
				begin
				    --Update #Data Set Duration_in_sec = 0, OT_Sec = 0, Holiday_OT_Sec = Duration_in_sec + OT_Sec Where For_date = @For_Date And Emp_Id = @Emp_Id_Cur					
				    Update #Data Set OT_Sec = 0, Holiday_OT_Sec = OT_Sec Where For_date = @For_Date And Emp_Id = @Emp_Id_Cur					
				end

		 fetch next from Cur_HO into @Emp_Id_Cur,@For_Date
	  end        
	close Cur_HO        
	Deallocate Cur_HO   

------------ End By Hardik for OT
      
         
  if @Return_Record_set =2   or @Return_Record_set =5 or @Return_Record_set = 8
   begin
    CREATE table #Data_Temp         
      (         
		   Emp_Id   numeric ,         
		   For_date datetime,        
		   Duration_in_sec numeric,        
		   Shift_ID numeric ,        
		   Shift_Type numeric ,        
		   Emp_OT  numeric ,        
		   Emp_OT_min_Limit numeric,        
		   Emp_OT_max_Limit numeric,        
		   P_days  numeric(12,1) default 0,        
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
		   OUT_Time Datetime
       )    
       
       Declare @T_Emp_ID Numeric  
       Declare @T_For_Date datetime  
       Declare @Flag_cur_temp int
       Declare @P_Days_Count  Numeric(18,2) 
			Set @P_Days_Count = 0
       
        delete from #Data_Temp  
        DECLARE OT_cursor CURSOR  
        FOR  
           SELECT Emp_ID,For_Date FROM #Data   
         OPEN OT_cursor  
          fetch next from OT_cursor into @T_Emp_ID,@T_For_Date  
          while @@fetch_status = 0  
         BEGIN  
            
          if Not Exists(select Tran_Id from t0160_Ot_Approval WITH (NOLOCK) where Emp_ID=@T_Emp_ID And For_Date=@T_For_Date)  
           Begin  
            insert into #Data_Temp   
            select  * from #Data where Emp_ID=@T_Emp_ID And For_Date=@T_For_Date  
           End  
          fetch next from OT_cursor into @T_Emp_ID,@T_For_Date  
         END  
        CLOSE OT_cursor  
        DEALLOCATE OT_cursor  
        
        Set @P_Days_Count = (Select SUM(P_days) from #data where Emp_ID=@T_Emp_ID And Month(For_Date)=Month(@T_For_Date) and IO_Tran_Id  = 0  )       
      
       
     if @Return_Record_set =2
		Begin               
           select *,dbo.F_Return_Hours (Duration_in_Sec) as Working_Hour , dbo.F_Return_Hours (OT_SEc) as OT_Hour,Flag,@P_Days_Count As P_Days_Count, dbo.F_Return_Hours (isnull(Weekoff_OT_Sec,0)) as Weekoff_OT_Hour,
				dbo.F_Return_Hours (Holiday_OT_Sec) as Holiday_OT_Hour from #Data_Temp   OA        
                inner join T0080_emp_master E WITH (NOLOCK) on OA.Emp_ID = E.Emp_ID  
                where OT_sec > 0    or Weekoff_OT_Sec > 0 or Holiday_OT_Sec > 0 
                order by OA.For_Date        
		End
	else if @Return_Record_set = 8
       Begin 
          If (@Is_WD = 1 And @Is_WOHO = 1)
            BEGIN
                 select OA.*,dbo.F_Return_Hours (Duration_in_Sec) as Working_Hour , dbo.F_Return_Hours (ISNULL(OT_SEC,0) + isnull(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) as OT_Hour, dbo.F_Return_Hours (Duration_in_Sec + ISNULL(OT_Sec,0) + ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) as Actual_Worked_Hrs,@P_Days_Count As P_Days_Count, dbo.F_Return_Hours (ISNULL(Weekoff_OT_Sec,0)) as Weekoff_OT_Hour,
				        dbo.F_Return_Hours (ISNULL(Holiday_OT_Sec,0)) as Holiday_OT_Hour, CA.Approve_Status as Application_Status from #Data_Temp   OA        
                        INNER JOIN T0080_emp_master E WITH (NOLOCK) on OA.Emp_ID = E.Emp_ID  
                        INNER JOIN T0120_CompOff_Approval CA WITH (NOLOCK) on OA.Emp_Id = CA.Emp_ID and OA.For_date=CA.Extra_Work_Date 
                  where Cast(Replace(dbo.F_Return_Hours (OT_SEC),':','.') as numeric(18,2)) >= Cast(Replace(E.CompOff_Min_hrs,':','.') as numeric(18,2)) or Cast(Replace(dbo.F_Return_Hours (Weekoff_OT_Sec),':','.') as numeric(18,2)) >= Cast(Replace(E.CompOff_Min_hrs,':','.') as numeric(18,2)) or Cast(Replace(dbo.F_Return_Hours (Holiday_OT_Sec),':','.') as numeric(18,2)) >= Cast(Replace(E.CompOff_Min_hrs,':','.') as numeric(18,2)) 
                 UNION
                  select OA.*,dbo.F_Return_Hours (Duration_in_Sec) as Working_Hour , dbo.F_Return_Hours (ISNULL(OT_SEC,0) + isnull(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) as OT_Hour, dbo.F_Return_Hours (Duration_in_Sec + ISNULL(OT_Sec,0) + ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) as Actual_Worked_Hrs, @P_Days_Count As P_Days_Count, dbo.F_Return_Hours (ISNULL(Weekoff_OT_Sec,0)) as Weekoff_OT_Hour,
				        dbo.F_Return_Hours (ISNULL(Holiday_OT_Sec,0)) as Holiday_OT_Hour, CA.Application_Status  from #Data_Temp   OA        
                        INNER JOIN T0080_emp_master E WITH (NOLOCK) on OA.Emp_ID = E.Emp_ID  
                        INNER JOIN T0100_CompOff_Application CA WITH (NOLOCK) on OA.Emp_Id = CA.Emp_ID and OA.For_date=CA.Extra_Work_Date 
                  where Cast(Replace(dbo.F_Return_Hours (OT_SEC),':','.') as numeric(18,2)) >= Cast(Replace(E.CompOff_Min_hrs,':','.') as numeric(18,2)) or Cast(Replace(dbo.F_Return_Hours (Weekoff_OT_Sec),':','.') as numeric(18,2)) >= Cast(Replace(E.CompOff_Min_hrs,':','.') as numeric(18,2)) or Cast(Replace(dbo.F_Return_Hours (Holiday_OT_Sec),':','.') as numeric(18,2)) >= Cast(Replace(E.CompOff_Min_hrs,':','.') as numeric(18,2)) 
                 UNION					
				Select Qry1.* from 
                   (select dt.*,dbo.F_Return_Hours (Duration_in_Sec) as Working_Hour , dbo.F_Return_Hours (ISNULL(OT_SEC,0) + isnull(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) as OT_Hour, dbo.F_Return_Hours (Duration_in_Sec + ISNULL(OT_Sec,0) + ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) as Actual_Worked_Hrs,@P_Days_Count As P_Days_Count, dbo.F_Return_Hours (ISNULL(Weekoff_OT_Sec,0)) as Weekoff_OT_Hour,
				        dbo.F_Return_Hours (ISNULL(Holiday_OT_Sec,0)) as Holiday_OT_Hour, '-' as application_status from #Data_Temp DT 
				        where For_date not in (                
                 select For_date from #Data_Temp   OA        
                        INNER JOIN T0080_emp_master E WITH (NOLOCK) on OA.Emp_ID = E.Emp_ID  
                        INNER JOIN T0120_CompOff_Approval CA WITH (NOLOCK) on OA.Emp_Id = CA.Emp_ID and OA.For_date=CA.Extra_Work_Date 
                  where Cast(Replace(dbo.F_Return_Hours (OT_SEC),':','.') as numeric(18,2)) >= Cast(Replace(E.CompOff_Min_hrs,':','.') as numeric(18,2)) or Cast(Replace(dbo.F_Return_Hours (Weekoff_OT_Sec),':','.') as numeric(18,2)) >= Cast(Replace(E.CompOff_Min_hrs,':','.') as numeric(18,2)) or Cast(Replace(dbo.F_Return_Hours (Holiday_OT_Sec),':','.') as numeric(18,2)) >= Cast(Replace(E.CompOff_Min_hrs,':','.') as numeric(18,2)) 
                 UNION
                  select For_date from #Data_Temp   OA        
                        INNER JOIN T0080_emp_master E WITH (NOLOCK) on OA.Emp_ID = E.Emp_ID  
                        INNER JOIN T0100_CompOff_Application CA WITH (NOLOCK) on OA.Emp_Id = CA.Emp_ID and OA.For_date=CA.Extra_Work_Date 
                  where Cast(Replace(dbo.F_Return_Hours (OT_SEC),':','.') as numeric(18,2)) >= Cast(Replace(E.CompOff_Min_hrs,':','.') as numeric(18,2)) or Cast(Replace(dbo.F_Return_Hours (Weekoff_OT_Sec),':','.') as numeric(18,2)) >= Cast(Replace(E.CompOff_Min_hrs,':','.') as numeric(18,2)) or Cast(Replace(dbo.F_Return_Hours (Holiday_OT_Sec),':','.') as numeric(18,2)) >= Cast(Replace(E.CompOff_Min_hrs,':','.') as numeric(18,2))) 
					) Qry1 inner join T0080_EMP_MASTER em WITH (NOLOCK) on Qry1.Emp_Id = em.Emp_ID
				Where Cast(Replace(dbo.F_Return_Hours (OT_SEC),':','.') as numeric(18,2)) >= Cast(Replace(Em.CompOff_Min_hrs,':','.') as numeric(18,2)) or Cast(Replace(dbo.F_Return_Hours (Weekoff_OT_Sec),':','.') as numeric(18,2)) >= Cast(Replace(Em.CompOff_Min_hrs,':','.') as numeric(18,2)) or Cast(Replace(dbo.F_Return_Hours (Holiday_OT_Sec),':','.') as numeric(18,2)) >= Cast(Replace(Em.CompOff_Min_hrs,':','.') as numeric(18,2))
                order by OA.For_Date
            END
          Else If (@Is_WD = 1 And @Is_WOHO = 0)
            BEGIN
              select OA.*,dbo.F_Return_Hours (Duration_in_Sec) as Working_Hour , dbo.F_Return_Hours (ISNULL(OT_SEC,0)) as OT_Hour, dbo.F_Return_Hours (Duration_in_Sec + ISNULL(OT_Sec,0)) as Actual_Worked_Hrs, @P_Days_Count As P_Days_Count, dbo.F_Return_Hours (ISNULL(Weekoff_OT_Sec,0)) as Weekoff_OT_Hour,
				        dbo.F_Return_Hours (ISNULL(Holiday_OT_Sec,0)) as Holiday_OT_Hour, CA.Approve_Status as Application_Status from #Data_Temp   OA        
                        INNER JOIN T0080_emp_master E WITH (NOLOCK) on OA.Emp_ID = E.Emp_ID  
                        INNER JOIN T0120_CompOff_Approval CA WITH (NOLOCK) on OA.Emp_Id = CA.Emp_ID and OA.For_date=CA.Extra_Work_Date 
                  where Cast(Replace(dbo.F_Return_Hours (OT_SEC),':','.') as numeric(18,2)) >= Cast(Replace(E.CompOff_Min_hrs,':','.') as numeric(18,2)) and Cast(Replace(dbo.F_Return_Hours (OT_SEC),':','.') as numeric(18,2)) <> 0 
             UNION
               select OA.*,dbo.F_Return_Hours (Duration_in_Sec) as Working_Hour , dbo.F_Return_Hours (ISNULL(OT_SEC,0)) as OT_Hour, dbo.F_Return_Hours (Duration_in_Sec + ISNULL(OT_Sec,0)) as Actual_Worked_Hrs, @P_Days_Count As P_Days_Count, dbo.F_Return_Hours (ISNULL(Weekoff_OT_Sec,0)) as Weekoff_OT_Hour,
				        dbo.F_Return_Hours (ISNULL(Holiday_OT_Sec,0)) as Holiday_OT_Hour, CA.Application_Status from #Data_Temp   OA        
                        INNER JOIN T0080_emp_master E WITH (NOLOCK) on OA.Emp_ID = E.Emp_ID  
                        INNER JOIN T0100_CompOff_Application CA WITH (NOLOCK) on OA.Emp_Id = CA.Emp_ID and OA.For_date=CA.Extra_Work_Date 
                  where Cast(Replace(dbo.F_Return_Hours (OT_SEC),':','.') as numeric(18,2)) >= Cast(Replace(E.CompOff_Min_hrs,':','.') as numeric(18,2)) and Cast(Replace(dbo.F_Return_Hours (OT_SEC),':','.') as numeric(18,2)) <> 0   
             UNION
               Select Qry1.* from 
                   (select dt.*,dbo.F_Return_Hours (Duration_in_Sec) as Working_Hour , dbo.F_Return_Hours (ISNULL(OT_SEC,0)) as OT_Hour, dbo.F_Return_Hours (Duration_in_Sec + ISNULL(OT_Sec,0)) as Actual_Worked_Hrs,@P_Days_Count As P_Days_Count, dbo.F_Return_Hours (ISNULL(Weekoff_OT_Sec,0)) as Weekoff_OT_Hour,
				        dbo.F_Return_Hours (ISNULL(Holiday_OT_Sec,0)) as Holiday_OT_Hour, '-' as application_status from #Data_Temp DT 
				        where For_date not in (                
                 select For_date from #Data_Temp   OA        
                        INNER JOIN T0080_emp_master E WITH (NOLOCK) on OA.Emp_ID = E.Emp_ID  
                        INNER JOIN T0120_CompOff_Approval CA WITH (NOLOCK) on OA.Emp_Id = CA.Emp_ID and OA.For_date=CA.Extra_Work_Date 
                  where Cast(Replace(dbo.F_Return_Hours (OT_SEC),':','.') as numeric(18,2)) >= Cast(Replace(E.CompOff_Min_hrs,':','.') as numeric(18,2)) and Cast(Replace(dbo.F_Return_Hours (OT_SEC),':','.') as numeric(18,2)) <> 0 
                 UNION
                  select For_date from #Data_Temp   OA        
                        INNER JOIN T0080_emp_master E WITH (NOLOCK) on OA.Emp_ID = E.Emp_ID  
                        INNER JOIN T0100_CompOff_Application CA WITH (NOLOCK) on OA.Emp_Id = CA.Emp_ID and OA.For_date=CA.Extra_Work_Date 
                  where Cast(Replace(dbo.F_Return_Hours (OT_SEC),':','.') as numeric(18,2)) >= Cast(Replace(E.CompOff_Min_hrs,':','.') as numeric(18,2))) and Cast(Replace(dbo.F_Return_Hours (OT_SEC),':','.') as numeric(18,2)) <> 0 
					) Qry1 inner join T0080_EMP_MASTER em WITH (NOLOCK) on Qry1.Emp_Id = em.Emp_ID
				Where Cast(Replace(dbo.F_Return_Hours (OT_SEC),':','.') as numeric(18,2)) >= Cast(Replace(Em.CompOff_Min_hrs,':','.') as numeric(18,2)) and Cast(Replace(dbo.F_Return_Hours (OT_SEC),':','.') as numeric(18,2)) <> 0 
                order by OA.For_Date                  
            END
          Else If (@Is_WD = 0 And @Is_WOHO = 1)
            BEGIN             
              select OA.*,dbo.F_Return_Hours (Duration_in_Sec) as Working_Hour , dbo.F_Return_Hours (ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) as OT_Hour, dbo.F_Return_Hours (ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) as Actual_Worked_Hrs, @P_Days_Count As P_Days_Count, dbo.F_Return_Hours (ISNULL(Weekoff_OT_Sec,0)) as Weekoff_OT_Hour,
				        dbo.F_Return_Hours (ISNULL(Holiday_OT_Sec,0)) as Holiday_OT_Hour, CA.Approve_Status as Application_Status from #Data_Temp   OA        
                        INNER JOIN T0080_emp_master E WITH (NOLOCK) on OA.Emp_ID = E.Emp_ID  
                        INNER JOIN T0120_CompOff_Approval CA WITH (NOLOCK) on OA.Emp_Id = CA.Emp_ID and OA.For_date=CA.Extra_Work_Date 
                  where Cast(Replace(dbo.F_Return_Hours (Weekoff_OT_Sec),':','.') as numeric(18,2)) >= Cast(Replace(E.CompOff_Min_hrs,':','.') as numeric(18,2)) or Cast(Replace(dbo.F_Return_Hours (Holiday_OT_Sec),':','.') as numeric(18,2)) >= Cast(Replace(E.CompOff_Min_hrs,':','.') as numeric(18,2)) 
                    and (Cast(Replace(dbo.F_Return_Hours (Weekoff_OT_Sec),':','.') as numeric(18,2)) <> 0 or Cast(Replace(dbo.F_Return_Hours (Holiday_OT_Sec),':','.') as numeric(18,2)) <> 0)
             UNION
               select OA.*,dbo.F_Return_Hours (Duration_in_Sec) as Working_Hour , dbo.F_Return_Hours (ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) as OT_Hour, dbo.F_Return_Hours (ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) as Actual_Worked_Hrs, @P_Days_Count As P_Days_Count, dbo.F_Return_Hours (ISNULL(Weekoff_OT_Sec,0)) as Weekoff_OT_Hour,
				        dbo.F_Return_Hours (ISNULL(Holiday_OT_Sec,0)) as Holiday_OT_Hour, CA.Application_Status from #Data_Temp   OA        
                        INNER JOIN T0080_emp_master E WITH (NOLOCK) on OA.Emp_ID = E.Emp_ID  
                        INNER JOIN T0100_CompOff_Application CA WITH (NOLOCK) on OA.Emp_Id = CA.Emp_ID and OA.For_date=CA.Extra_Work_Date 
                  where Cast(Replace(dbo.F_Return_Hours (Weekoff_OT_Sec),':','.') as numeric(18,2)) >= Cast(Replace(E.CompOff_Min_hrs,':','.') as numeric(18,2)) or Cast(Replace(dbo.F_Return_Hours (Holiday_OT_Sec),':','.') as numeric(18,2)) >= Cast(Replace(E.CompOff_Min_hrs,':','.') as numeric(18,2))
                    and (Cast(Replace(dbo.F_Return_Hours (Weekoff_OT_Sec),':','.') as numeric(18,2)) <> 0 or Cast(Replace(dbo.F_Return_Hours (Holiday_OT_Sec),':','.') as numeric(18,2)) <> 0)                        
             UNION
               Select Qry1.* from 
                   (select dt.*,dbo.F_Return_Hours (Duration_in_Sec) as Working_Hour , dbo.F_Return_Hours (ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) as OT_Hour, dbo.F_Return_Hours (ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) as Actual_Worked_Hrs, @P_Days_Count As P_Days_Count, dbo.F_Return_Hours (ISNULL(Weekoff_OT_Sec,0)) as Weekoff_OT_Hour,
				        dbo.F_Return_Hours (ISNULL(Holiday_OT_Sec,0)) as Holiday_OT_Hour, '-' as application_status from #Data_Temp DT 
				        where For_date not in (                
                 select For_date from #Data_Temp   OA        
                        INNER JOIN T0080_emp_master E WITH (NOLOCK) on OA.Emp_ID = E.Emp_ID  
                        INNER JOIN T0120_CompOff_Approval CA WITH (NOLOCK) on OA.Emp_Id = CA.Emp_ID and OA.For_date=CA.Extra_Work_Date 
                  where Cast(Replace(dbo.F_Return_Hours (Weekoff_OT_Sec),':','.') as numeric(18,2)) >= Cast(Replace(E.CompOff_Min_hrs,':','.') as numeric(18,2)) or Cast(Replace(dbo.F_Return_Hours (Holiday_OT_Sec),':','.') as numeric(18,2)) >= Cast(Replace(E.CompOff_Min_hrs,':','.') as numeric(18,2)) 
                    and (Cast(Replace(dbo.F_Return_Hours (Weekoff_OT_Sec),':','.') as numeric(18,2)) <> 0 or Cast(Replace(dbo.F_Return_Hours (Holiday_OT_Sec),':','.') as numeric(18,2)) <> 0)
                 UNION
                  select For_date from #Data_Temp   OA        
                        INNER JOIN T0080_emp_master E WITH (NOLOCK) on OA.Emp_ID = E.Emp_ID  
                        INNER JOIN T0100_CompOff_Application CA WITH (NOLOCK) on OA.Emp_Id = CA.Emp_ID and OA.For_date=CA.Extra_Work_Date 
                  where Cast(Replace(dbo.F_Return_Hours (Weekoff_OT_Sec),':','.') as numeric(18,2)) >= Cast(Replace(E.CompOff_Min_hrs,':','.') as numeric(18,2)) or Cast(Replace(dbo.F_Return_Hours (Holiday_OT_Sec),':','.') as numeric(18,2)) >= Cast(Replace(E.CompOff_Min_hrs,':','.') as numeric(18,2))) 
                    and (Cast(Replace(dbo.F_Return_Hours (Weekoff_OT_Sec),':','.') as numeric(18,2)) <> 0 or Cast(Replace(dbo.F_Return_Hours (Holiday_OT_Sec),':','.') as numeric(18,2)) <> 0)
					) Qry1 inner join T0080_EMP_MASTER em WITH (NOLOCK) on Qry1.Emp_Id = em.Emp_ID
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
   end        
    
  else if @Return_Record_set = 1         
   begin 
	IF(@Is_Compoff = 1) -- Added by Mihir Trivedi on 31/05/2012 for present days updation related to comp-off
		BEGIN
			Declare @strwoff as Varchar(Max)
			Declare @A_strwoff as varchar(20)
			Declare @D_EmpID as Numeric
			Declare @F_Date as Varchar(11)
			Declare @Weekoff_EmpID as numeric
			Select @Weekoff_EmpID = Emp_ID,@strwoff = Replace(ISNULL(Strweekoff,''),';',',') from @Emp_WeekOFf_Detail
		
			Declare curapp cursor for
				select Data from dbo.Split(@strwoff, ',') where Data <> ''
			Open curapp
				Fetch Next from curapp into @A_strwoff
			WHILE @@FETCH_STATUS = 0
				BEGIN					
					Declare curfinal cursor for
						Select Emp_ID,CAST(For_date as varchar(11)) from #Data
					Open curfinal 
						Fetch Next from curfinal into @D_EmpID, @F_Date
					WHILE @@FETCH_STATUS = 0
						BEGIN									
							IF(@F_Date = @A_strwoff and @D_EmpID = @Weekoff_EmpID)
								BEGIN
									Update #Data 
									Set P_days = 0.0
									Where CAST(For_date as varchar(11)) = @A_strwoff and Emp_Id = @Weekoff_EmpID
								END
							Fetch Next from curfinal into @D_EmpID, @F_Date
						END
					Close curfinal
					Deallocate curfinal
					Fetch next from curapp into @A_strwoff 
				END
			Close curapp
			Deallocate curapp
		END
	------End of Added by Mihir Trivedi on 31/05/2012		  
    --select *, CONVERT(decimal(10,2), Duration_in_Sec/3600)   as Working_Hour ,CONVERT(decimal(10,2), OT_SEc/3600) as OT_Hour from #Data  OA        
    Select *,dbo.F_Return_Hours (Duration_in_Sec) as Working_Hour , dbo.F_Return_Hours (OT_SEc) as OT_Hour,Flag , dbo.F_Return_Hours (Weekoff_OT_Sec) as Weekoff_OT_Hour,
			dbo.F_Return_Hours (Holiday_OT_Sec) as Holiday_OT_Hour
	 from #Data  OA 
    inner join T0080_emp_master E WITH (NOLOCK) on OA.Emp_ID = E.Emp_ID   
--    where OT_sec > 0 or Weekoff_OT_Sec > 0 or Holiday_OT_Sec > 0           
    order by E.emp_ID,For_Date        
    
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
      
      
      
    CREATE table #Data_Temp_3         
      (         
		   Emp_Id   numeric ,         
		   For_date datetime,        
		   Duration_in_sec numeric,        
		   Shift_ID numeric ,        
		   Shift_Type numeric ,        
		   Emp_OT  numeric ,        
		   Emp_OT_min_Limit numeric,        
		   Emp_OT_max_Limit numeric,        
		   P_days  numeric(12,1) default 0,        
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
		   OUT_Time Datetime
       )   
        
         Declare @T_Emp_ID_3 Numeric  
         Declare @T_For_Date_3 datetime  
         Declare @Flag_cur As Int       	
       	
       	
       	       	
       	       	
        delete from #Data_Temp_3  
        
        DECLARE OT_cursor CURSOR  
        FOR  
           SELECT Emp_ID,For_Date,Flag FROM #Data   
         OPEN OT_cursor  
          fetch next from OT_cursor into @T_Emp_ID_3,@T_For_Date_3,@Flag_cur   
          while @@fetch_status = 0  
         BEGIN  
            
				If Not Exists(Select Tran_Id from t0160_Ot_Approval WITH (NOLOCK) where Emp_ID=@T_Emp_ID_3 And For_Date=@T_For_Date_3)  
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
		From #Data_Temp_3  OA inner join T0080_emp_master E WITH (NOLOCK) on OA.Emp_ID = E.Emp_ID        
		where OT_sec > 0 or Weekoff_OT_Sec > 0 or Holiday_OT_Sec > 0       
		Group by OA.emp_ID,E.Emp_Full_Name     
      
   select OA1.Emp_ID,Max(For_Date)For_Date,E1.Emp_Full_Name,Working_Hour,dbo.F_Return_Hours(OT_HOur) as OT_Hour, P_days, E1.Emp_Superior,dbo.F_Return_Hours(Weekoff_OT_Hour) as Weekoff_OT_Hour,dbo.F_Return_Hours(Holiday_OT_Hour) as Holiday_OT_Hour
    From @Emp_Temp  OA1 inner join T0080_emp_master E1 WITH (NOLOCK) on OA1.Emp_ID = E1.Emp_ID        
    Group by OA1.emp_ID,E1.Emp_Full_Name ,For_Date,  Working_Hour,OT_Hour,P_days ,Emp_Superior ,Weekoff_OT_Hour,Holiday_OT_Hour 
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
   
   declare curweekoff cursor for                    
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
			from #Data  d inner join T0160_OT_Approval OA on d.emp_ID = Oa.Emp_ID and d.For_Date = oa.For_Date         
      
		End    
	 Else if @OT_Present =0 and @Auto_OT =0
		Begin				
					  
		    Update #Data set OT_Sec =0
         
			update #Data         
			set OT_Sec = isnull(Approved_OT_Sec,0) -- * 3600        
			from #Data  d inner join T0160_OT_Approval OA on d.emp_ID = Oa.Emp_ID and d.For_Date = oa.For_Date         
      
		End    	
   End      
  If @Return_Record_set = 5
	Begin
	
	CREATE table #Data_Temp_5         
      (         
		   Emp_Id   numeric ,         
		   For_date datetime,        
		   Duration_in_sec numeric,        
		   Shift_ID numeric ,        
		   Shift_Type numeric ,        
		   Emp_OT  numeric ,        
		   Emp_OT_min_Limit numeric,        
		   Emp_OT_max_Limit numeric,        
		   P_days  numeric(12,1) default 0,        
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
			OUT_Time Datetime

       )   
       
        Declare @Temp Table
       (
			Emp_ID numeric ,
			For_Date datetime,
			p_Days numeric(12,1) default 0,
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
       
        delete from #Data_Temp_5  
        
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
							From #Data_Temp_5  OA inner join T0080_emp_master E WITH (NOLOCK) on OA.Emp_ID = E.Emp_ID        
							Group by OA.emp_ID,E.Emp_Full_Name     	
							---Select * from #data_temp	
							
							insert into #Data_MOTIF
							--Select Emp_ID,For_Date,p_Days, dbo.F_Return_Hours(OT_SEc),Flag From #Data_Temp_5   OA          							
							Select Emp_ID,For_Date,p_Days,OT_Hours,Weekoff_OT_Hour,Holiday_OT_Hour  From @temp   OA          							
							Order by OA.For_Date     
							--End    					
									
																
							insert into #Att_Detail   
  							Select OA1.Emp_ID,P_days,dbo.F_Return_Hours(OT_HOur),0,0,0,0,0,0,0,dbo.F_Return_Hours(Weekoff_OT_Hour),dbo.F_Return_Hours(Holiday_OT_Hour)
							From @Emp_Temp_5  OA1 inner join T0080_emp_master E1 WITH (NOLOCK) on OA1.Emp_ID = E1.Emp_ID          
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



