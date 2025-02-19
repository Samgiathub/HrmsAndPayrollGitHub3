
---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Sp_Inout_Record_Daily_Get]        
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
	 ,@str varchar(max) =''
	 ,@For_Get numeric = 0
	 ,@Order_By			Varchar(50) = ''	--Ankit 03062015
	 ,@Segment_ID		Numeric = 0		--Ankit 10072015
	 ,@subBranch_ID		Numeric = 0		--Ankit 10072015
	 ,@Vertical_ID		Numeric = 0		--Ankit 10072015
	 ,@SubVertical_ID	Numeric = 0		--Ankit 10072015
	 ,@Shift_ID			Numeric = 0
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

		IF @Shift_ID = 0
			Set @Shift_ID = NULL             

		IF @Segment_ID	 = 0
			SET @Segment_ID	 = NULL
		IF @subBranch_ID = 0
			SET @subBranch_ID = NULL
		IF @Vertical_ID	 = 0
			SET @Vertical_ID = NULL
		IF @SubVertical_ID	= 0	
			SET @SubVertical_ID = NULL
			  
		 create table #Emp_Cons
		 (        
		  EMP_ID NUMERIC,  
		  BRANCH_ID NUMERIC,
		  INCREMENT_ID NUMERIC,
		 -- DEPT_ID NUMERIC,			--Added By Ramiz on 03062016 as previuosly it was taken from EMP_MASTER
		 -- VERTICAL_ID NUMERIC,		--Added By Ramiz on 03062016 as previuosly it was taken from EMP_MASTER
		 -- SUBVERTICAL_ID NUMERIC	--Added By Ramiz on 03062016 as previuosly it was taken from EMP_MASTER
		 )      
		
		If @str = 'Shift_Time'
			EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,'' ,0 ,0 ,@Segment_ID,@Vertical_ID,@SubVertical_Id,@SubBranch_Id,0,0,0,0,0,0
		Else
		BEGIN
			EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@str ,0 ,0 ,@Segment_ID,@Vertical_ID,@SubVertical_Id,@SubBranch_Id,0,0,0,0,0,0
		END
		CREATE UNIQUE CLUSTERED INDEX IX_EMP_CONS_EMPID ON #Emp_Cons (EMP_ID);
	
		ALTER table #Emp_Cons add DEPT_ID NUMERIC
		ALTER table #Emp_Cons add VERTICAL_ID NUMERIC
		ALTER table #Emp_Cons add SUBVERTICAL_ID NUMERIC
	
		Update E
		set E.DEPT_ID = I.Dept_ID
			,E.VERTICAL_ID = I.Vertical_ID
			,E.SUBVERTICAL_ID = I.SubVertical_ID
		from	#Emp_Cons E
				inner join T0095_INCREMENT I on E.EMP_ID = I.Emp_ID and E.INCREMENT_ID = I.Increment_ID
			 
		 -- Insert Into #Emp_Cons--(Emp_ID)   
			--   select distinct EMP_ID,ISNULL(BRANCH_ID,0),ISNULL(Increment_ID,0) , ISNULL(DEPT_ID,0) , ISNULL(VERTICAL_ID,0) ,ISNULL(SUBVERTICAL_ID,0) 
			--   from dbo.V_Emp_Cons where 
			--	   cmp_id=@Cmp_ID 
			--	   and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
			--	   and Branch_ID = isnull(@Branch_ID ,Branch_ID)      
			--	   and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
			--	   and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
			--	   and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
			--	   and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
			--	   and Isnull(Segment_ID,0) = isnull(@Segment_ID ,Isnull(Segment_ID,0))
			--	   and Isnull(subBranch_ID,0) = isnull(@subBranch_ID ,Isnull(subBranch_ID,0))
			--	   and Isnull(Vertical_ID,0) = isnull(@Vertical_ID ,Isnull(Vertical_ID,0))
			--	   and Isnull(SubVertical_ID,0) = isnull(@SubVertical_ID ,Isnull(SubVertical_ID,0))
			--	   and Emp_ID = isnull(@Emp_ID ,Emp_ID)   
			--	   and Increment_Effective_Date <= @To_Date 
			--	   and 
			--		  ( (@From_Date  >= join_Date  and  @From_Date <= left_date )      
			--			or ( @To_Date  >= join_Date  and @To_Date <= left_date )      
			--			or (Left_date is null and @To_Date >= Join_Date)      
			--			or (@To_Date >= left_date  and  @From_Date <= left_date )) 
			--			order by Emp_ID
						
			--		delete  from #Emp_Cons where Increment_ID not in (select max(Increment_ID) from T0095_Increment
			--		where  Increment_effective_Date <= @to_date
			--		group by emp_ID)
		
		
					
			--select I.Emp_Id from T0095_Increment I inner join   ----Comment By Ankit for not show Left Employee on 08072013      
			--	( select max(Increment_effective_Date) as For_Date , Emp_ID From T0095_Increment        
			--	where Increment_Effective_date <= @To_Date        
			--	and Cmp_ID = @Cmp_ID        
			--	group by emp_ID  ) Qry on        
			--	I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date                        
		 --  Where Cmp_ID = @Cmp_ID         
		 --  and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))        
		 --  and Branch_ID = isnull(@Branch_ID ,Branch_ID)        
		 --  and Grd_ID = isnull(@Grd_ID ,Grd_ID)        
		 --  and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))        
		 --  and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))        
		 --  and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))        
		 --  and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID)        
	   
	   
	   -- Added by rohit For Week off and Holiday not Added on 17102013
	 Declare @Emp_WeekOFf_Detail Table        
	 (        
	  Emp_ID numeric        ,
	  StrWeekoff_Holiday varchar(max),
	  StrWeekoff varchar(max), 
	  StrHoliday varchar(max),
	  strHalfday varchar(max)
	 )  

	Declare @StrWeekoff_Date varchar(max)

	insert into @Emp_WeekOFf_Detail 
	select Emp_ID,'','','','' from #Emp_Cons 



	Declare @Emp_Week_Detail numeric(18,0)
	Declare @strweekoff varchar(max)
	Declare @Is_Negative_Ot Int 

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
		
		declare @HalfDayDate varchar(max)
		
	 
		select @Week_oF_Branch=Branch_ID  from dbo.t0095_increment WITH (NOLOCK) where Increment_id in (select Max(Increment_id) from dbo.t0095_increment WITH (NOLOCK) where emp_id=@Emp_Week_Detail)
		
	 
		Select @Is_Cancel_weekoff = Is_Cancel_weekoff ,@tras_week_ot=isnull(tras_week_ot,0)  ,@Auto_OT = Is_OT_Auto_Calc ,@OT_Present = OT_Present_days,@Is_Negative_Ot = ISNULL(Is_Negative_Ot,0), @Is_Compoff = ISNULL(Is_CompOff, 0), @Is_WD = ISNULL(Is_CompOff_WD,0), @Is_WOHO = ISNULL(Is_CompOff_WOHO,0)
			,@Is_Cancel_Holiday = Is_Cancel_Holiday 
			From dbo.T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID and Branch_ID = @Week_oF_Branch    
			and For_Date = ( select max(For_Date) from dbo.T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@To_Date and Branch_ID = @Week_oF_Branch and Cmp_ID = @Cmp_ID)    
		
	  
				set @StrWeekoff_Date=''
				set @Weekoff_Days=0
				set @Cancel_Weekoff=0
				
				Set @StrHoliday_Date =''
				Set @Holiday_days = 0
				Set @Cancel_Holiday =0
				set @HalfDayDate=''
				
				
				Exec dbo.SP_EMP_HOLIDAY_DATE_GET @Emp_Week_Detail,@Cmp_ID,@From_Date,@To_Date,null,null,9,@StrHoliday_Date output,@Holiday_days output,@Cancel_Holiday output,0,@Branch_ID,@StrWeekoff_Date
				Exec dbo.SP_EMP_WEEKOFF_DATE_GET @Emp_Week_Detail,@Cmp_ID,@From_Date,@To_Date,null,null,9,'',@StrWeekoff_Date output,@Weekoff_Days output ,@Cancel_Weekoff output    
				-- Added by rohit on 26112013
				exec dbo.GET_HalfDay_Date @Cmp_ID,@Emp_Week_Detail,@From_Date,@To_Date,0,@HalfDayDate output
				--ended by rohit on 26112013
				
				
				
		Update 	@Emp_WeekOFf_Detail 
		Set StrWeekoff_Holiday=@StrWeekoff_Date + ';' + @StrHoliday_Date ,
			StrHoliday = @StrHoliday_Date,StrWeekoff = @StrWeekoff_Date
			,strhalfday = @HalfDayDate   
		where Emp_ID=@Emp_Week_Detail 


		fetch next from curEmp_weekoff_Detail into @Emp_Week_Detail
	   end                    
	 close curEmp_weekoff_Detail                    
	 deallocate curEmp_weekoff_Detail   
	   
	   --ended by rohit on 17102013
	   --select * from @Emp_WeekOFf_Detail
	   
	   CREATE table #temp_table         
	   (         
		   Emp_Id   numeric(18,0) ,         
		   Alpha_Emp_Code varchar(50),
		   emp_full_name varchar(200),
		   io_tran_id numeric(10,0),
		   For_date datetime,  
		   In_Time varchar(15),
		   Out_Time varchar(15),
		   Duration varchar(10),        
		   Reason Varchar(500),
		   Late_Calc_Not_App numeric(2,0),
		   out_Date Datetime,
		   Tel_No varchar(20),
		   Branch_Id numeric(18,0), --Added By Jaina 23-09-2015
		   Vertical_Id numeric(18,0), --Added By Jaina 23-09-2015
		   SubVertical_Id numeric(18,0), --Added By Jaina 23-09-2015
		   Dept_Id numeric(18,0), --Added By Jaina 23-09-2015
		   Is_Cancel_Late_In numeric(2,0),		--Added By Ramiz on 07/10/2015
		   Is_Cancel_Early_Out numeric(2,0),	--Added By Ramiz on 07/10/2015
		   App_Date datetime,					--Added By Ramiz on 07/10/2015
		   Apr_date datetime,					--Added By Ramiz on 07/10/2015
		   In_Date Datetime ---Added by Hardik 30/01/2017
		  )       
		  
				Declare @Temp_End_Date as datetime       
				Declare @Temp_Month_Date as datetime
				
				set @Temp_Month_Date = @From_Date 
			
			if Object_ID('tempdb..#Shift_Details') is not null
				drop TABLE #Shift_Details
				
				Create Table #Shift_Details
			 (
				Cmp_ID numeric(10,0),
				Emp_ID Numeric(10,0),
				Shift_ID Numeric(5,0),
				Shift_For_Date Datetime
			 )
			  
			  
			  Declare @Cur_Shift_Emp_ID Numeric(18,0)
			  Declare @Cur_Shift_ID Numeric(18,0)
			  
			  Declare @Shift_Temp_Month_Date Datetime
			  SET @Shift_Temp_Month_Date = @From_Date   	
			  
			  
			  
			  Declare Cur_Shift_Details Cursor For
			  Select Emp_ID From #Emp_Cons order by Emp_ID
			  Open Cur_Shift_Details 
			  fetch next from Cur_Shift_Details into @Cur_Shift_Emp_ID
				while @@fetch_status = 0 
					Begin 
						While @Shift_Temp_Month_Date <= @To_Date
							Begin
							  Set @Cur_Shift_ID = NULL
							  EXEC SP_CURR_T0100_EMP_SHIFT_GET @Cur_Shift_Emp_ID,@Cmp_ID,@Shift_Temp_Month_Date,null,null,null,null,null,null,null,@Cur_Shift_ID output,0,'','','',''
							  
							  insert into #Shift_Details VALUES(@Cmp_ID,@Cur_Shift_Emp_ID,@Cur_Shift_ID,@Shift_Temp_Month_Date)
							  
							  Set @Shift_Temp_Month_Date = DATEADD(d,1,@Shift_Temp_Month_Date)
							End 
							SET @Shift_Temp_Month_Date = @From_Date  
						fetch next from Cur_Shift_Details into @Cur_Shift_Emp_ID
					End
			  Close Cur_Shift_Details
			  deallocate Cur_Shift_Details  
			  

	if @str=''
	   begin
			
		
			 
			if @For_Get = 0 
				begin

					--NMS
					SET @Temp_Month_Date=@From_Date
					while @Temp_Month_Date <= @To_Date  
						Begin														
							insert into #temp_table
							select E.Emp_Id,EM.Alpha_Emp_Code ,Em.emp_full_name,
									isnull(EIR.io_tran_id,0) as io_tran_id ,
									isnull(EIR.For_Date,@Temp_Month_Date) as For_Date
									, isnull(dbo.F_GET_AMPM (In_Time),'') as In_Time,
									isnull(dbo.F_GET_AMPM (Out_Time),'') as Out_Time,
									isnull(Duration,0) as Duration ,
									isnull(Reason,'') as Reason
									,isnull(Late_Calc_Not_App,0) as  Late_Calc_Not_App
									,isnull(EIR.Out_Time,@Temp_Month_Date) as out_date
									,ISNULL(EM.Work_Tel_No , 0)  as Work_Tel_No,
									E.Branch_ID,E.Vertical_ID,E.SubVertical_ID,E.Dept_ID  --Added By Jaina 23-09-2015
									,ISNULL(EIR.Is_Cancel_Late_In , 0) as Is_Cancel_Late_In		--Added By Ramiz on 07/10/2015
									,ISnull(EIR.Is_Cancel_Early_Out,0) as Is_Cancel_Early_Out	--Added By Ramiz on 07/10/2015
									,EIR.App_Date as App_date ,EIR.Apr_Date as Apr_date			--Added By Ramiz on 07/10/2015
									,EIR.In_Time --Added by Hardik 30/01/2017
							from	#Emp_Cons E 
									inner join t0080_emp_master EM WITH (NOLOCK) on E.Emp_id = EM.Emp_id
									left join T0150_EMP_INOUT_RECORD EIR WITH (NOLOCK) on E.Emp_id = EIR.Emp_id and EIR.For_Date >= @Temp_Month_Date and EIR.For_Date <= @Temp_Month_Date
									inner join @Emp_WeekOFf_Detail EWD on E.Emp_id = EWD.Emp_id  
												and @Temp_Month_Date not in (select  cast(data  as Datetime) from dbo.Split (StrWeekoff_Holiday,';')   ) -- Rohit on 17102013   							
									--left join ( select L.*,LM.Apply_Hourly from T0140_LEAVE_TRANSACTION L 
									--								inner join T0040_LEAVE_MASTER LM on L.Leave_ID = LM.Leave_ID )LT on E.Emp_ID = LT.Emp_ID 
									--																	and (LT.Leave_Used > 0 or LT.Leave_Used > 0) 
									--																	and LT.For_Date <= @Temp_Month_Date 
									--																	and DATEADD(DD,case when (lt.Leave_Used=0.5) then 0.5 else ((case when lt.Leave_Used = 0 then lt.Leave_Used else lt.Leave_Used end )-1) end ,LT.For_Date) >= @Temp_Month_Date
							where	--(isnull(LT.Leave_Used,0)=0 and isnull(LT.Leave_Used,0) = 0)  -- Changed By Gadriwala Muslim 01102014
									--add by chetan 040517 for emp record come after join date and before left date
									--AND 
									EM.Date_Of_Join <= @Temp_Month_Date 
									AND ISNULL(EM.Emp_Left_Date,@Temp_Month_Date) >= @Temp_Month_Date
									AND NOT EXISTS(SELECT 1 FROM T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) WHERE LT.EMP_ID=E.EMP_ID AND LT.For_Date=@Temp_Month_Date AND (Leave_Used > 0 OR isNull(CompOff_Used,0) > 0))
							-------------------
							
						
							set @Temp_Month_Date = Dateadd(d,1,@Temp_Month_Date)   
						end
		
				end
			else
				Begin
				
					while @Temp_Month_Date <= @To_Date 
						begin
							insert into #temp_table
							select E.Emp_Id,EM.Alpha_Emp_Code ,Em.emp_full_name,
									isnull(EIR.io_tran_id,0) as io_tran_id ,
									isnull(EIR.For_Date,@Temp_Month_Date) as For_Date
									, isnull(dbo.F_GET_AMPM (In_Time),'') as In_Time,
									isnull(dbo.F_GET_AMPM (Out_Time),'') as Out_Time,
									isnull(Duration,0) as Duration ,
									isnull(Reason,'') as Reason
									,isnull(Late_Calc_Not_App,0) as  Late_Calc_Not_App
									,isnull(EIR.Out_Time,@Temp_Month_Date) as out_date
									,ISNULL(EM.Work_Tel_No , 0)  as Work_Tel_No
									,E.Branch_ID,E.Vertical_ID,E.SubVertical_ID,E.Dept_ID  --Added By Jaina 23-09-2015
									,ISNULL(EIR.Is_Cancel_Late_In , 0) as Is_Cancel_Late_In		--Added By Ramiz on 07/10/2015
									,ISnull(EIR.Is_Cancel_Early_Out,0) as Is_Cancel_Early_Out	--Added By Ramiz on 07/10/2015
									,EIR.App_Date as App_date,EIR.Apr_Date as Apr_date			--Added By Ramiz on 07/10/2015
									,EIR.In_Time --Added by Hardik 30/01/2017
							from #Emp_Cons E inner join t0080_emp_master EM WITH (NOLOCK) on E.Emp_id = EM.Emp_id
									inner join T0150_EMP_INOUT_RECORD EIR WITH (NOLOCK) on E.Emp_id = EIR.Emp_id and EIR.For_Date >= @Temp_Month_Date and EIR.For_Date <= @Temp_Month_Date
									inner join @Emp_WeekOFf_Detail EWD on E.Emp_id = EWD.Emp_id  and @Temp_Month_Date not in (select  cast(data  as Datetime) from dbo.Split (StrWeekoff_Holiday,';')   ) -- Rohit on 17102013   
									--left join T0140_LEAVE_TRANSACTION LT on E.Emp_ID = LT.Emp_ID and (LT.Leave_Used > 0 or LT.Leave_Used > 0) and LT.For_Date <= @Temp_Month_Date and DATEADD(DD,case when (lt.Leave_Used=0.5 or lt.Leave_Used = 0.5) then 0.5 else ((case when lt.Leave_Used = 0 then lt.Leave_Used else lt.Leave_Used end )-1) end ,LT.For_Date) >= @Temp_Month_Date
							where 
									--(isnull(LT.Leave_Used,0)=0 and isnull(LT.Leave_Used,0) = 0)  -- Changed By Gadriwala Muslim 01102014
									--and
									isnull(EIR.Out_Time,0) = 0 
										--add by chetan 040517 for emp record come after join date and before left date
									AND EM.Date_Of_Join <= @Temp_Month_Date 
									AND ISNULL(EM.Emp_Left_Date,@Temp_Month_Date) >= @Temp_Month_Date
							-------------------
							--set @Temp_Month_Date = Dateadd(d,1,@Temp_Month_Date)  
							set @Temp_Month_Date = Dateadd(d,1,@Temp_Month_Date)    
						end
				End
		end
		
	else if @str='Shift_Time'
		begin
		
		if @For_Get = 0 
			begin
			
			while @Temp_Month_Date <= @To_Date  
			begin
			
				insert into #temp_table
				select Distinct E.Emp_Id,EM.Alpha_Emp_Code ,Em.emp_full_name,
				isnull(EIR.io_tran_id,0) as io_tran_id,
				isnull(EIR.For_Date,@Temp_Month_Date) as For_Date
				--, isnull(dbo.F_GET_AMPM (EIR.In_Time), dbo.F_GET_AMPM(Shift_Detail.Shift_St_Time) ) as In_Time,
				--isnull(dbo.F_GET_AMPM (EIR.Out_Time),dbo.F_GET_AMPM(Shift_Detail.Shift_End_Time) ) as Out_Time,
				--isnull(EIR.Duration,Shift_Detail.Shift_Dur) as Duration,
				,Case When isnull(dbo.F_GET_AMPM (EIR.In_Time),'')='' then case when isnull(EWD_Halfday.strhalfday,'') = '' then dbo.F_GET_AMPM(Shift_Detail.Shift_St_Time) else dbo.F_GET_AMPM(Shift_Detail.half_st_Time) end else dbo.F_GET_AMPM (EIR.In_Time) end as In_Time,
				 Case When isnull(dbo.F_GET_AMPM (EIR.Out_Time),'')='' then case when isnull(EWD_Halfday.strhalfday,'') = '' then dbo.F_GET_AMPM(Shift_Detail.Shift_End_Time) else dbo.F_GET_AMPM(Shift_Detail.half_End_Time) end  else dbo.F_GET_AMPM (EIR.Out_Time) end as In_Time,
				 Case When isnull(EIR.Duration,'')='' then case when isnull(EWD_Halfday.strhalfday,'') = '' then Shift_Detail.Shift_Dur else Shift_Detail.half_Dur end  else EIR.Duration end as Duration,
				
				isnull(Reason,'') as Reason
				,isnull(Late_Calc_Not_App,0) as  Late_Calc_Not_App
				--,isnull(EIR.Out_Time, (case when (Shift_Detail.Shift_End_Time > Shift_Detail.Shift_St_Time) then @Temp_Month_Date else @Temp_Month_Date + 1 end ) ) as out_date
				,ISNULL(EIR.Out_Time,(CASE WHEN (Shift_Detail.Shift_End_Time > Shift_Detail.Shift_St_Time)  OR CHARINDEX(CAST(isnull(EIR.For_Date,@Temp_Month_Date) AS VARCHAR(11)), EWD_Halfday.strhalfday) > 0
											THEN @Temp_Month_Date 
										ELSE 
											@Temp_Month_Date + 1  
										end ) 
						) as OUT_DATE
					
				,ISNULL(EM.Work_Tel_No , 0)  as Work_Tel_No
				,E.Branch_ID,E.Vertical_ID,E.SubVertical_ID,E.Dept_ID  --Added By Jaina 23-09-2015
				,ISNULL(EIR.Is_Cancel_Late_In , 0) as Is_Cancel_Late_In		--Added By Ramiz on 07/10/2015
				,ISnull(EIR.Is_Cancel_Early_Out,0) as Is_Cancel_Early_Out	--Added By Ramiz on 07/10/2015
				,EIR.App_Date as App_date,EIR.Apr_Date as Apr_date			--Added By Ramiz on 07/10/2015
				,EIR.In_Time --Added by Hardik 30/01/2017
				from #Emp_Cons E inner join t0080_emp_master EM WITH (NOLOCK) on E.Emp_id = EM.Emp_id		
				left join T0150_EMP_INOUT_RECORD EIR WITH (NOLOCK) on E.Emp_id = EIR.Emp_id and EIR.For_Date >= @Temp_Month_Date and EIR.For_Date <= @Temp_Month_Date	
				inner join
				(
					select  Shift_ID,Shift_St_Time,Shift_End_Time,
							Shift_Dur,half_st_time,half_end_time,half_Dur
					
					
					--FROM V0100_Emp_shift_Change 
					--inner join (SELECT MAX(For_Date) as for_date, V0100_Emp_shift_Change.emp_id 
					--			FROM V0100_Emp_shift_Change 
					--					inner join #Emp_Cons EC on V0100_Emp_shift_Change.emp_id = EC.emp_id
					--			where	For_Date <= @Temp_Month_Date
					--			group by V0100_Emp_shift_Change.emp_id) mytemp ON V0100_EMP_SHIFT_CHANGE.Emp_ID = mytemp.Emp_ID AND V0100_EMP_SHIFT_CHANGE.For_Date =mytemp.for_date 
					--inner join T0040_SHIFT_MASTER SM on V0100_Emp_shift_Change.shift_id = SM.shift_id and V0100_Emp_shift_Change.cmp_id = SM.cmp_id
						
					From T0040_SHIFT_MASTER SM WITH (NOLOCK)
				) as Shift_Detail on Shift_Detail.Shift_ID = dbo.fn_get_Shift_From_Monthly_Rotation(EM.CMP_ID,E.EMP_ID,ISNULL(EIR.FOR_DATE,@TEMP_MONTH_DATE))						
				inner join @Emp_WeekOFf_Detail EWD on E.Emp_id = EWD.Emp_id  and @Temp_Month_Date not in (select  cast(data  as Datetime) from dbo.Split (StrWeekoff_Holiday,';')   ) -- Rohit on 17102013
				left join @Emp_WeekOFf_Detail EWD_Halfday on E.Emp_id = EWD_Halfday.Emp_id  and @Temp_Month_Date in (select  cast(data  as Datetime) from dbo.Split (EWD_Halfday.strhalfday,';')   ) -- Rohit on 26112013
				left join T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) on E.Emp_ID = LT.Emp_ID and (lt.Leave_Used > 0 or lt.Leave_Used > 0) and LT.For_Date <= @Temp_Month_Date and DATEADD(DD,case when (lt.Leave_Used=0.5) then 0.5 else ((case when lt.Leave_Used = 0 then lt.Leave_Used else lt.Leave_Used end)-1)end ,LT.For_Date)>= @Temp_Month_Date
				where (isnull(LT.Leave_Used,0)=0 and ISNULL(LT.Leave_Used,0) = 0)  -- Changed By Gadriwala Muslim  01102014 for Comp-Off
				--add by chetan 040517 for emp record come after join date and before left date
				AND EM.Date_Of_Join <= @Temp_Month_Date 
				AND ISNULL(EM.Emp_Left_Date,@Temp_Month_Date) >= @Temp_Month_Date
				-------------------
			
				set @Temp_Month_Date = Dateadd(d,1,@Temp_Month_Date)   
				end
			end
			else
			begin
				while @Temp_Month_Date <= @To_Date  
			begin
			
				insert into #temp_table
				select Distinct E.Emp_Id,EM.Alpha_Emp_Code ,Em.emp_full_name,
				isnull(EIR.io_tran_id,0) as io_tran_id,
				isnull(EIR.For_Date,@Temp_Month_Date) as For_Date
				--, isnull(dbo.F_GET_AMPM (EIR.In_Time), dbo.F_GET_AMPM(Shift_Detail.Shift_St_Time) ) as In_Time,
				--isnull(dbo.F_GET_AMPM (EIR.Out_Time),dbo.F_GET_AMPM(Shift_Detail.Shift_End_Time) ) as Out_Time,
				--isnull(EIR.Duration,Shift_Detail.Shift_Dur) as Duration ,
				, Case When isnull(dbo.F_GET_AMPM (EIR.In_Time),'')='' then case when isnull(EWD_Halfday.strhalfday,'') = '' then dbo.F_GET_AMPM(Shift_Detail.Shift_St_Time) else dbo.F_GET_AMPM(Shift_Detail.half_st_Time) end else dbo.F_GET_AMPM (EIR.In_Time) end as In_Time,
				 Case When isnull(dbo.F_GET_AMPM (EIR.Out_Time),'')='' then case when isnull(EWD_Halfday.strhalfday,'') = '' then dbo.F_GET_AMPM(Shift_Detail.Shift_End_Time) else dbo.F_GET_AMPM(Shift_Detail.half_End_Time) end  else dbo.F_GET_AMPM (EIR.Out_Time) end as In_Time,
				--Case When isnull(EIR.Duration,'')='' then case when isnull(EWD_Halfday.strhalfday,'') = '' then Shift_Detail.Shift_Dur else Shift_Detail.half_Dur end  else EIR.Duration end as Duration,
				case when (datediff(s,EIR.In_Time,(cast(CONVERT(VARCHAR(11), EIR.In_Time, 121)  + CONVERT(VARCHAR(12), Shift_Detail.Shift_End_Time, 114) as datetime)))) < 0 then '-' + cast( dbo.F_Return_Hours((datediff(s,EIR.In_Time,(cast(CONVERT(VARCHAR(11), EIR.In_Time, 121)  + CONVERT(VARCHAR(12), Shift_Detail.Shift_End_Time, 114) as datetime))))*(-1)) as varchar(max)) else dbo.F_Return_Hours(datediff(s,EIR.In_Time,(cast(CONVERT(VARCHAR(11), EIR.In_Time, 121)  + CONVERT(VARCHAR(12), Shift_Detail.Shift_End_Time, 114) as datetime)))) end as Duration ,
				
				isnull(Reason,'') as Reason
				,isnull(Late_Calc_Not_App,0) as  Late_Calc_Not_App
				,isnull(EIR.Out_Time, (case when (Shift_Detail.Shift_End_Time > Shift_Detail.Shift_St_Time) then @Temp_Month_Date else @Temp_Month_Date + 1 end ) ) as out_date
				,ISNULL(EM.Work_Tel_No , 0)  as Work_Tel_No
				,E.Branch_ID,E.Vertical_ID,E.SubVertical_ID,E.Dept_ID  --Added By Jaina 23-09-2015
				,ISNULL(EIR.Is_Cancel_Late_In , 0) as Is_Cancel_Late_In		--Added By Ramiz on 07/10/2015
				,ISnull(EIR.Is_Cancel_Early_Out,0) as Is_Cancel_Early_Out	--Added By Ramiz on 07/10/2015
				,EIR.App_Date as App_date,EIR.Apr_Date as Apr_date			--Added By Ramiz on 07/10/2015
				,EIR.In_Time --Added by Hardik 30/01/2017
				
				from #Emp_Cons E inner join t0080_emp_master EM WITH (NOLOCK) on E.Emp_id = EM.Emp_id
				left join T0150_EMP_INOUT_RECORD EIR WITH (NOLOCK) on E.Emp_id = EIR.Emp_id and EIR.For_Date >= @Temp_Month_Date and EIR.For_Date <= @Temp_Month_Date
				inner join
				(		
						
						select  Shift_ID,Shift_St_Time,Shift_End_Time,
								Shift_Dur,half_st_time,half_end_time,half_Dur
						--select  Shift_Tran_ID,mytemp.Emp_ID,V0100_Emp_shift_Change.Cmp_ID,V0100_Emp_shift_Change.Shift_ID , mytemp.For_Date,  
						--Emp_code, Emp_First_Name, Emp_Full_Name, 
						--Branch_ID, Branch_Name, 
						--Emp_Superior, Alpha_Emp_Code
						--,SM.Shift_St_Time,Sm.Shift_End_Time,Sm.Shift_Dur,Sm.half_st_time,Sm.half_end_time,Sm.half_Dur
						
						--FROM V0100_Emp_shift_Change 
						--inner join (SELECT MAX(For_Date) as for_date, V0100_Emp_shift_Change.emp_id FROM V0100_Emp_shift_Change 
						--			inner join #Emp_Cons EC on V0100_Emp_shift_Change.emp_id = EC.emp_id
						--			where For_Date <= @Temp_Month_Date
						--			group by V0100_Emp_shift_Change.emp_id) mytemp 
						--			ON V0100_EMP_SHIFT_CHANGE.Emp_ID = mytemp.Emp_ID AND V0100_EMP_SHIFT_CHANGE.For_Date =mytemp.for_date 
						--inner join T0040_SHIFT_MASTER SM on V0100_Emp_shift_Change.shift_id = SM.shift_id and V0100_Emp_shift_Change.cmp_id = SM.cmp_id
							 
						From T0040_SHIFT_MASTER SM	WITH (NOLOCK) 
				) as Shift_Detail on Shift_Detail.Shift_ID = dbo.fn_get_Shift_From_Monthly_Rotation(EM.CMP_ID,E.EMP_ID,ISNULL(EIR.FOR_DATE,@TEMP_MONTH_DATE))						
				inner join @Emp_WeekOFf_Detail EWD on E.Emp_id = EWD.Emp_id  and @Temp_Month_Date not in (select  cast(data  as Datetime) from dbo.Split (StrWeekoff_Holiday,';')   ) -- Rohit on 17102013
				left join @Emp_WeekOFf_Detail EWD_Halfday on E.Emp_id = EWD_Halfday.Emp_id  and @Temp_Month_Date in (select  cast(data  as Datetime) from dbo.Split (EWD_Halfday.strhalfday,';')   ) -- Rohit on 26112013
				--left join T0140_LEAVE_TRANSACTION LT on E.Emp_ID = LT.Emp_ID and (lt.Leave_Used > 0 or lt.Leave_Used > 0) and LT.For_Date <= @Temp_Month_Date and DATEADD(DD,case when (lt.Leave_Used=0.5 or Lt.Leave_Used = 0.5) then 0.5 else ((case when lt.Leave_Used = 0 then lt.Leave_Used else lt.Leave_Used end)-1)end ,LT.For_Date)>= @Temp_Month_Date
				where 
				--(isnull(LT.Leave_Used,0)=0 and ISNULL(LT.Leave_Used,0) = 0)  -- Changed By Gadriwala Muslim  01102014 for Comp-Off
				--and 
				isnull(EIR.Out_Time,0)= 0
				--add by chetan 040517 for emp record come after join date and before left date
				AND EM.Date_Of_Join <= @Temp_Month_Date 
				AND ISNULL(EM.Emp_Left_Date,@Temp_Month_Date) >= @Temp_Month_Date
				-------------------
				
				set @Temp_Month_Date = Dateadd(d,1,@Temp_Month_Date)   
				end
			end	
			
			
		   
			--Add by Nimesh 20 May, 2015
			--This sp retrieves the Shift Rotation as per given employee id and effective date.
			--it will fetch all employee's shift rotation detail if employee id is not specified.
			IF (OBJECT_ID('tempdb..#Rotation') IS NULL)
				Create Table #Rotation (R_EmpID numeric(18,0), R_DayName varchar(25) COLLATE SQL_Latin1_General_CP1_CI_AS, R_ShiftID numeric(18,0), R_Effective_Date DateTime);
			--The #Rotation table gets re-created in dbo.P0050_UNPIVOT_EMP_ROTATION stored procedure
			DECLARE @constraint varchar(max);

			IF (SELECT COUNT(1) FROM #Emp_Cons) = 1
				SELECT @constraint = cast(Emp_ID as varchar) From #Emp_Cons
			ELSE
				SELECT @constraint = COALESCE( @constraint + '#', '') + cast(Emp_ID as varchar) From #Emp_Cons
				
			
			Exec dbo.P0050_UNPIVOT_EMP_ROTATION @Cmp_ID, NULL, @To_Date, @constraint
			
			
			
			--Modified by Nimesh 28-May-2015
			SET @Temp_Month_Date = @From_Date   	
			WHILE @Temp_Month_Date <= @To_Date  
				BEGIN
				
					--Added by Nimesh 27 May, 2015
					--Updating Shift ID From Rotation
					UPDATE	#temp_table 
					SET		In_Time=(CASE WHEN ISNULL(EIO.In_Time,'') = '' THEN SM.Shift_St_Time  COLLATE SQL_Latin1_General_CP1_CI_AS ELSE p.In_Time END), 
							Out_Time=(CASE WHEN ISNULL(EIO.Out_Time,'') = '' THEN SM.Shift_End_Time  COLLATE SQL_Latin1_General_CP1_CI_AS ELSE p.Out_Time END),
							out_Date=(	Case WHEN ISNULL(EIO.Out_Time,'') = '' THEN 
											(CASE WHEN SM.Shift_St_Time > SM.Shift_End_Time THEN @Temp_Month_Date + 1 ELSE @Temp_Month_Date END) 
										ELSE
											p.out_Date
										END
									  )
					FROM	#temp_table p INNER JOIN  #Rotation R ON p.Emp_ID=R.R_EmpID AND R.R_DayName = ('Day' + CAST(DATEPART(d, p.For_Date) As Varchar))  COLLATE SQL_Latin1_General_CP1_CI_AS
							INNER JOIN 
							(
								SELECT	(CASE WHEN Is_Half_Day=1 AND DATENAME(dw, @Temp_Month_Date) = Week_Day THEN Half_St_Time ELSE	Shift_St_Time END) As Shift_St_Time,
										(CASE WHEN Is_Half_Day=1 AND DATENAME(dw, @Temp_Month_Date) = Week_Day THEN Half_End_Time ELSE Shift_End_Time END) As Shift_End_Time,
										Shift_ID, Cmp_ID
								FROM T0040_SHIFT_MASTER WITH (NOLOCK)
								WHERE	Cmp_ID=@CMP_ID
							) SM ON R.R_ShiftID=SM.Shift_ID					
							LEFT OUTER JOIN T0150_EMP_INOUT_RECORD EIO WITH (NOLOCK) ON EIO.For_Date=@Temp_Month_Date AND EIO.Cmp_ID=@Cmp_ID AND EIO.Emp_ID=p.Emp_ID
					WHERE	SM.Cmp_ID=@Cmp_ID AND R.R_DayName = ('Day' + CAST(DATEPART(d, @Temp_Month_Date) As Varchar)) COLLATE SQL_Latin1_General_CP1_CI_AS AND
							p.Emp_Id=R.R_EmpID AND R.R_Effective_Date=(SELECT MAX(R_Effective_Date)
								FROM #Rotation R1 WHERE R1.R_EmpID=p.Emp_Id AND R_Effective_Date<=@Temp_Month_Date) AND 
							p.For_Date=@Temp_Month_Date 
					
					
					--Updating Shift ID For Shift_Type=0
					UPDATE	#temp_table 
					SET		In_Time=(CASE WHEN ISNULL(EIO.In_Time,'') = '' THEN SM.Shift_St_Time COLLATE SQL_Latin1_General_CP1_CI_AS ELSE p.In_Time END), 
							Out_Time=(CASE WHEN ISNULL(EIO.Out_Time,'') = '' THEN SM.Shift_End_Time COLLATE SQL_Latin1_General_CP1_CI_AS ELSE p.Out_Time END),
							out_Date=(	Case WHEN ISNULL(EIO.Out_Time,'') = '' THEN 
											(CASE WHEN SM.Shift_St_Time > SM.Shift_End_Time THEN @Temp_Month_Date + 1 ELSE @Temp_Month_Date END) 
										ELSE
											p.out_Date
										END
									  )
					FROM	#temp_table p INNER JOIN (
												SELECT	esd.Shift_ID, esd.Emp_ID, esd.Shift_Type, esd.For_Date
												FROM	T0100_EMP_SHIFT_DETAIL esd WITH (NOLOCK)
												WHERE	Cmp_ID=@Cmp_ID
												) ES ON ES.Emp_ID=p.Emp_Id AND ES.For_Date=p.For_date 
							INNER JOIN 
							(
								SELECT	(CASE WHEN Is_Half_Day=1 AND DATENAME(dw, @Temp_Month_Date) = Week_Day THEN Half_St_Time ELSE	Shift_St_Time END) As Shift_St_Time,
										(CASE WHEN Is_Half_Day=1 AND DATENAME(dw, @Temp_Month_Date) = Week_Day THEN Half_End_Time ELSE Shift_End_Time END) As Shift_End_Time,
										Shift_ID, Cmp_ID
								FROM T0040_SHIFT_MASTER WITH (NOLOCK)
								WHERE	Cmp_ID=@CMP_ID
							) SM ON ES.Shift_ID=SM.Shift_ID	AND SM.Cmp_ID=@Cmp_ID
							LEFT OUTER JOIN T0150_EMP_INOUT_RECORD EIO WITH (NOLOCK) ON p.Emp_ID=EIO.Emp_ID AND EIO.For_Date=@Temp_Month_Date AND EIO.Cmp_ID=@Cmp_ID
					WHERE	p.For_Date=@Temp_Month_Date 
							AND ES.Emp_ID IN (
												Select	DISTINCT R.R_EmpID 
												FROM	#Rotation R
												WHERE	R_DayName = ('Day' + CAST(DATEPART(d, @Temp_Month_Date) As Varchar ) ) COLLATE SQL_Latin1_General_CP1_CI_AS
														AND R_Effective_Date<=@Temp_Month_Date
											)															
					
					--Updating Shift ID For Shift_Type=1
					UPDATE	#temp_table 
					SET		In_Time=(CASE WHEN ISNULL(EIO.In_Time,'') = '' THEN SM.Shift_St_Time COLLATE SQL_Latin1_General_CP1_CI_AS ELSE p.In_Time END), 
							Out_Time=(CASE WHEN ISNULL(EIO.Out_Time,'') = '' THEN SM.Shift_End_Time COLLATE SQL_Latin1_General_CP1_CI_AS ELSE p.Out_Time END),
							out_Date=(	Case WHEN ISNULL(EIO.Out_Time,'') = '' THEN 
											(CASE WHEN SM.Shift_St_Time > SM.Shift_End_Time THEN @Temp_Month_Date + 1 ELSE @Temp_Month_Date END) 
										ELSE
											p.out_Date
										END
									  )
					FROM	#temp_table p INNER JOIN (
												SELECT	esd.Shift_ID, esd.Emp_ID, esd.Shift_Type, esd.For_Date
												FROM	T0100_EMP_SHIFT_DETAIL esd  WITH (NOLOCK)
												WHERE	Cmp_ID=@Cmp_ID
												) ES ON ES.Emp_ID=p.Emp_Id AND ES.For_Date=p.For_date 
							INNER JOIN 
							(
								SELECT	(CASE WHEN Is_Half_Day=1 AND DATENAME(dw, @Temp_Month_Date) = Week_Day THEN Half_St_Time ELSE	Shift_St_Time END) As Shift_St_Time,
										(CASE WHEN Is_Half_Day=1 AND DATENAME(dw, @Temp_Month_Date) = Week_Day THEN Half_End_Time ELSE Shift_End_Time END) As Shift_End_Time,
										Shift_ID, Cmp_ID
								FROM T0040_SHIFT_MASTER WITH (NOLOCK)
								WHERE	Cmp_ID=@CMP_ID
							) SM ON ES.Shift_ID=SM.Shift_ID	AND SM.Cmp_ID=@Cmp_ID
							LEFT OUTER JOIN T0150_EMP_INOUT_RECORD EIO WITH (NOLOCK) ON p.Emp_ID=EIO.Emp_ID AND EIO.For_Date=@Temp_Month_Date AND EIO.Cmp_ID=@Cmp_ID
					WHERE	p.For_date=@Temp_Month_Date AND IsNull(ES.Shift_Type,0)=1
							AND ES.Emp_ID NOT IN (
												Select	DISTINCT R.R_EmpID 
												FROM	#Rotation R
												WHERE	R_DayName = ('Day' + CAST(DATEPART(d, @Temp_Month_Date) As Varchar ) ) COLLATE SQL_Latin1_General_CP1_CI_AS
														AND R_Effective_Date<=@Temp_Month_Date
											)				
						
					
					
					SET @Temp_Month_Date = DATEADD(d,1,@Temp_Month_Date);
				END
			--End Nimesh	
		end
		
		
		UPDATE	#temp_table
		SET		Duration=   case when (datediff(s,Cast(In_Time As DateTime),(cast(CONVERT(VARCHAR(11), Cast(In_Time As DateTime), 121)  + CONVERT(VARCHAR(12), Cast(Out_Time As DateTime), 114) as datetime)))) < 0 then 
								'-' + cast( dbo.F_Return_Hours((datediff(s,Cast(In_Time As DateTime),(cast(CONVERT(VARCHAR(11), Cast(In_Time As DateTime), 121)  + CONVERT(VARCHAR(12), Cast(Out_Time As DateTime), 114) as datetime))))*(-1)) as varchar(max)) 
							else 
								dbo.F_Return_Hours(datediff(s,Cast(In_Time As DateTime),(cast(CONVERT(VARCHAR(11), Cast(In_Time As DateTime), 121)  + CONVERT(VARCHAR(12), Cast(Out_Time As DateTime), 114) as datetime)))) 
							end
		WHERE	ISNULL(In_Time,'') <> '' AND  ISNULL(Out_Time,'') <> '' 
				AND DateDiff(s,(For_date + In_time),(Out_date + Out_Time)) < 0
				
		
		--UPDATE	#temp_table
		--SET		Duration = dbo.F_Return_Hours(DateDiff(s,(Cast(Cast(For_Date As DateTime) As DateTime) + In_time),(Cast(Cast(Out_date As DateTime) As DateTime) + OUt_time)))
		--WHERE	ISNULL(In_Time,'') <> '' AND  ISNULL(Out_Time,'') <> '' 
		--		AND DateDiff(s,(For_date + In_time),(Out_date + Out_Time)) > 0
		
		UPDATE	#temp_table
		SET		Duration = 
			--dbo.F_Return_Hours(DateDiff(s,(Cast(Cast(For_Date As DateTime) As DateTime) + In_time) --Commented by Hardik 30/01/2017 as In Time from For date is wrong for Night shift at Nirma when employee punch after 12 AM so added In Date column
			dbo.F_Return_Hours(DateDiff(s,In_Date
		,case when convert(Time,Cast(Out_date As DateTime)) = '00:00:00:000' then (Cast(Cast(Out_date As DateTime) As DateTime) + OUt_time)
		Else Cast(Out_date As DateTime)  End )) 
		WHERE	ISNULL(In_Time,'') <> '' AND  ISNULL(Out_Time,'') <> '' 
				--AND DateDiff(s,(For_date + In_time),(Out_date + Out_Time)) > 0 --Commented by Hardik 30/01/2017
				AND DateDiff(s,In_Date,(Out_date + Out_Time)) > 0
		
		--Added Above case when in Out Date column Time is already coming so no need to add + Ou time so added case when for the same 09012016-----------------------------------------------------
		
		
		UPDATE	#temp_table 
		SET		In_Time = Ltrim(Right(CONVERT(varchar(20),CAST(In_Time AS DateTime),100),8)),
				Out_Time = Ltrim(Right(CONVERT(varchar(20),CAST(Out_Time AS DateTime),100),8))
		WHERE	IsNull(In_Time,'') <> '' AND IsNull(Out_Time,'') <> ''
		

		
		--RETURN STATEMENET
		
		IF @Order_By = ''
			BEGIN
				if @str='Shift_Time' 
					Begin
						--select * from #temp_table order by RIGHT(REPLICATE(N' ', 500) + ALPHA_EMP_CODE, 500),For_Date
						select TT.*,SD.Shift_ID,SM.Shift_Name from #temp_table TT
						Inner JOIN #Shift_Details SD ON SD.Shift_For_Date = TT.For_date and SD.Emp_ID = TT.Emp_Id
						Inner JOIN T0040_SHIFT_MASTER SM WITH (NOLOCK) ON SM.Shift_ID = SD.Shift_ID
						where SD.Shift_ID = isnull(@Shift_ID,SD.Shift_ID)
						order by RIGHT(REPLICATE(N' ', 500) + ALPHA_EMP_CODE, 500),For_Date
						
					End
				Else
					Begin
					
						select TT.*,SD.Shift_ID,SM.Shift_Name from #temp_table TT
						Inner JOIN #Shift_Details SD ON SD.Shift_For_Date = TT.For_date and SD.Emp_ID = TT.Emp_Id
						Inner JOIN T0040_SHIFT_MASTER SM WITH (NOLOCK) ON SM.Shift_ID = SD.Shift_ID
						where SD.Shift_ID = isnull(@Shift_ID,SD.Shift_ID)
						order by RIGHT(REPLICATE(N' ', 500) + ALPHA_EMP_CODE, 500),For_Date
					End
			END	
		ELSE
			BEGIN
				Declare @exec Varchar(MAX)
				
				 IF (CHARINDEX('Duration', @Order_By, 1) > 0)
					  SET @Order_By = REPLACE(@Order_By, 'Duration', 'dbo.F_Return_Sec(Duration)');
					  
				SET @exec= 'SELECT * FROM #temp_table  order by ' + @Order_By
				EXEC(@exec)
				
			END	
	 END 


