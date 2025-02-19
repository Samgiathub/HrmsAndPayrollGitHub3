

---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_LEAVE_BALANCE_WITH_AMOUNT_GET_CUST]
	 @Cmp_ID		Numeric
	,@From_Date		datetime
	,@To_Date		Datetime
	,@Branch_ID		varchar(Max) 
	,@Cat_ID		varchar(Max)
	,@Grd_ID		varchar(Max)
	,@Type_ID		varchar(Max) 
	,@Dept_Id		varchar(Max)
	,@Desig_Id		varchar(Max)
	,@Emp_ID		Numeric 
	,@Leave_ID		Numeric = 0
	,@Constraint	varchar(max)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	DECLARE @Closing AS NUMERIC(18,1)
	DECLARE @Opening AS NUMERIC(18,1)
	DECLARE @Earn AS NUMERIC(18,1)
	DECLARE @Adj_LMark AS NUMERIC(18,1)
	DECLARE @Adj_Absent AS NUMERIC(18,1)	
	DECLARE @Total_Adj AS NUMERIC(18,1)
		
	DECLARE @Emp_Leave_Bal table
	(
		Cmp_ID			numeric,
		Emp_ID			numeric,
		Branch_Id		numeric,
		Wages_Type		varchar(25),
		Increment_ID	numeric,
		Basic_Salary	numeric(18,2),
		Gross_Salary	numeric(18,2),
		calc_Amount		numeric(18,2),
		For_Date		datetime,
		Leave_Closing	numeric(18,2),
		Leave_Amount	numeric(18,2),
		Leave_ID		numeric,
		Leave_Total		Numeric(18,2),
		Leave_Amount_Total	Numeric(18,2),
		Lv_Encase_Calculation_Day Numeric(18,2)
	) 
			
	if @Branch_ID = ''
		set @Branch_ID = null
	If @Cat_ID = ''
		set @Cat_ID  = null
	if @Type_ID = ''
		set @Type_ID = null
	if @Dept_ID = ''
		set @Dept_ID = null
	if @Grd_ID = ''
		set @Grd_ID = null
	if @Desig_ID = ''
		set @Desig_ID = null
	if @Emp_ID = 0
		set @Emp_ID = null
		
 	

	Declare @Emp_Cons Table
	(
		Cmp_ID numeric,
		Emp_ID	numeric
	)
	
	if @Constraint <> ''
		begin
			Insert Into @Emp_Cons
				select  @cmp_ID,cast(data  as numeric) from dbo.Split (@Constraint,'#') 
		end
	else
		begin
			
			Insert Into @Emp_Cons
			select   I.cmp_ID,I.Emp_Id from T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID	
			Where Cmp_ID = @Cmp_ID 
			and ISNULL(Cat_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Cat_ID,ISNULL(Cat_ID,0)),'#') ) 
			and ISNULL(Branch_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Branch_ID,ISNULL(Branch_ID,0)),'#') ) 
			and ISNULL(Grd_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Grd_ID,ISNULL(Grd_ID,0)),'#') ) 
			and ISNULL(Dept_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Dept_ID,ISNULL(Dept_ID,0)),'#') )
			and ISNULL(Type_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Type_ID,ISNULL(Type_ID,0)),'#') )  
			and ISNULL(Desig_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Desig_ID,ISNULL(Desig_ID,0)),'#') ) 
			
			--and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
			--and Branch_ID = isnull(@Branch_ID ,Branch_ID)
			--and Grd_ID = isnull(@Grd_ID ,Grd_ID)
			--and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
			--and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
			--and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
			and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
			and I.Emp_ID in 
				( select Emp_Id from
				(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry
				where cmp_ID = @Cmp_ID   and  
				(( @To_Date  >= join_Date  and @To_Date <= left_date )
				or Left_date is null and @To_Date >= Join_Date)
				or @To_Date >= left_date) 
			
		end
		
		
		
		If isnull(@Leave_ID,0) = 0 
			begin
			
				Insert into @Emp_Leave_Bal
					select @Cmp_ID,Emp_ID,0,'',0,0,0,0,@To_Date,0,0,Leave_ID,0,0,Lv_Encase_Calculation_Day from T0040_LEAVE_MASTER LM WITH (NOLOCK)
					Inner join	 @Emp_Cons EC on  EC.Cmp_ID = LM.Cmp_ID
					Where LM.Leave_Type = 'Encashable'  and LM.Apply_Hourly = 0 and IsNull(Default_Short_Name,'') <> 'COMP'
			end
		else
			begin
				Insert into @Emp_Leave_Bal
					select @Cmp_ID,Emp_ID,0,'',0,0,0,0,@To_Date,0,0,Leave_ID,0,0,Lv_Encase_Calculation_Day from T0040_LEAVE_MASTER LM WITH (NOLOCK)
					Inner join	 @Emp_Cons EC on  EC.Cmp_ID = LM.Cmp_ID
					Where LM.Leave_Type = 'Encashable' and LM.Leave_ID = @leave_ID and LM.Apply_Hourly = 0
			end
		
			If isnull(@Leave_ID,0) = 0 
			begin
			
				Insert into @Emp_Leave_Bal
					select @Cmp_ID,Emp_ID,0,'',0,0,0,0,@To_Date,0,0,Leave_ID,0,0,Lv_Encase_Calculation_Day from T0040_LEAVE_MASTER LM WITH (NOLOCK)
					Inner join	 @Emp_Cons EC on  EC.Cmp_ID = LM.Cmp_ID
					Where LM.Leave_Type = 'Encashable'  and IsNull(Default_Short_Name,'') ='COMP'
			end
		
		
		
			Update @Emp_Leave_Bal set Increment_ID = Qry.Increment_ID from @Emp_Leave_Bal ELB Inner join
			( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on ELB.Emp_ID = Qry.Emp_ID	
			Where Cmp_ID = @Cmp_ID 
			
	
			
			Update @Emp_Leave_Bal set Basic_Salary = isnull(I.Basic_Salary,0),
					Gross_Salary = ISNULL(I.Gross_Salary,0),
					Branch_Id = ISNULL(I.Branch_ID,0),
					Wages_Type =ISNULL(I.wages_Type,'') 
					
			from @Emp_Leave_Bal ELB Inner join T0095_INCREMENT I 
			on ELB.Increment_ID = I.Increment_ID 
			and ELB.Emp_ID = I.Emp_ID	
			Where ELB.Cmp_ID = @Cmp_ID 
		
	
	
		If isnull(@Leave_ID,0) = 0 
			begin
				update @Emp_Leave_Bal 
				set Leave_Closing = leave_Bal.Leave_Closing  
				From @Emp_Leave_Bal  LB Inner join  
				( select lt.* From T0140_leave_Transaction LT WITH (NOLOCK) inner join 
					( select max(For_Date) For_Date , Emp_ID ,leave_ID from T0140_leave_Transaction WITH (NOLOCK) where For_date <= @To_Date and Cmp_ID = @Cmp_ID
					 Group by Emp_ID ,LEave_ID ) q on Lt.Emp_Id = Q.Emp_ID and lt.For_Date = Q.For_Date and lt.Leave_ID = Q.LEave_ID
					)Leave_Bal on LB.LEave_ID = LEave_Bal.Leave_ID and LB.Emp_ID = leave_Bal.Emp_ID 
			end
		else
			begin
				update @Emp_Leave_Bal 
				set Leave_Closing = leave_Bal.Leave_Closing  
				From @Emp_Leave_Bal  LB Inner join  
					( select lt.* From T0140_leave_Transaction LT WITH (NOLOCK) inner join 
					( select max(For_Date) For_Date , Emp_ID ,leave_ID from T0140_leave_Transaction WITH (NOLOCK) where For_date <= @To_Date and Cmp_ID = @Cmp_ID
					  and LEave_ID = @Leave_ID 
					  Group by Emp_ID ,LEave_ID ) q on Lt.Emp_Id = Q.Emp_ID and lt.For_Date = Q.For_Date and lt.Leave_ID = Q.LEave_ID
					)Leave_Bal on LB.LEave_ID = LEave_Bal.Leave_ID and LB.Emp_ID = leave_Bal.Emp_ID 
			end
	
		
		-- Added by rohit on 12032015
			declare @Leave_Emp_ID as numeric(18,0)
			declare @compOff_Leave_ID as numeric(18,0)
			Declare @Compoff_Leave_Apply_Hourly as Numeric(18,0)
			set @Compoff_Leave_Apply_Hourly = 0
			set @compOff_Leave_ID= 0
			select @compOff_Leave_ID = leave_id ,@Compoff_Leave_Apply_Hourly=isnull(Apply_Hourly,0) from T0040_LEAVE_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Default_Short_Name ='COMP' and Leave_Type = 'Encashable'  
		
		if @compOff_Leave_ID>0
		begin	
			  CREATE TABLE #temp_CompOff
						(
							Leave_opening	decimal(18,2),
							Leave_Used		decimal(18,2),
							Leave_Closing	decimal(18,2),
							Leave_Code		varchar(max),
							Leave_Name		varchar(max),
							Leave_ID		numeric,
							CompOff_String  varchar(max) default null -- Added by Gadriwala 18022015
						)	
			
					CREATE TABLE #leave_Balance_Comp_Temp
			(
							Emp_ID			numeric(18,2),
							Leave_ID		numeric	,
							For_date		varchar(25),
							Leave_Closing	decimal(18,2),
							Leave_Code		varchar(max)
			)
						
			
		
			Declare curCompOffBalance cursor for select Emp_ID from @Emp_Cons Order by Emp_ID  
									open curCompOffBalance  
										fetch next from curCompOffBalance into @Leave_Emp_ID  
											while @@fetch_status = 0  
												begin  
												    	
													delete from #temp_CompOff	
													exec GET_COMPOFF_DETAILS @To_Date,@Cmp_ID,@Leave_Emp_ID,@compOff_Leave_ID,0,0,2	
													If exists(select 1 from #temp_CompOff)
													begin
														insert into #leave_Balance_Comp_Temp
															select @Leave_Emp_ID as Emp_ID,Leave_ID,@To_Date as for_date,Leave_Closing,Leave_Code from #temp_CompOFf
													end	
													fetch next from curCompOffBalance into @Leave_Emp_ID  
											   end   
									close curCompOffBalance  
									deallocate curCompOffBalance  
		
			
		
		if @Compoff_Leave_Apply_Hourly =0
		begin
				update @Emp_Leave_Bal 
				set Leave_Closing = leave_Bal.Leave_Closing  
				From @Emp_Leave_Bal  LB Inner join  
					#leave_Balance_Comp_Temp Leave_Bal on 
					LB.LEave_ID = LEave_Bal.Leave_ID and LB.Emp_ID = leave_Bal.Emp_ID 
		end
		else
		begin
				update @Emp_Leave_Bal 
				set Leave_Closing = (leave_Bal.Leave_Closing)/ 8  
				From @Emp_Leave_Bal  LB Inner join  
					#leave_Balance_Comp_Temp Leave_Bal on 
					LB.LEave_ID = LEave_Bal.Leave_ID and LB.Emp_ID = leave_Bal.Emp_ID 
		end
		end
			-- Ended by rohit on 12032015			
			
			declare @Cur_Emp_ID as numeric
			declare @Cur_Branch_Id as numeric
			declare @Cur_Wages_Type as varchar(25)
			declare @Cur_Increment_ID as numeric
			declare @Cur_Basic_Salary as numeric(18,2)
			declare @Cur_Gross_Salary as numeric(18,2)
			declare @Cur_calc_Amount as numeric(18,2)
			declare @Cur_For_Date as datetime
			declare @Cur_Leave_Closing as numeric(18,2)
			declare @Cur_Leave_Amount as numeric(18,2)
			declare @Cur_Leave_ID as numeric
			Declare @Lv_Encash_W_Day as numeric
			Declare @IS_ROUNDING as numeric
			Declare @Lv_Encash_Cal_On as varchar(25)
			Declare @Inc_Weekoff  as numeric
			declare @manual_salary_period as numeric(18,0) 
			declare @is_salary_cycle_emp_wise as tinyint 
			declare @Month_St_Date as datetime
			declare @Month_End_Date as datetime
			declare @Sal_St_Date as datetime
			declare @Sal_End_Date as datetime
			declare @OutOf_Days numeric(18,2)
			declare @Working_Days numeric(18,2)
			declare @WeekOff_Days  numeric(18,2)
			Declare @Join_Date    Datetime    
			Declare @Left_Date    Datetime
			declare @Is_Cancel_Holiday numeric
			declare @Is_Cancel_weekoff numeric
			Declare @StrHoliday_Date  varchar(max)    
			Declare @StrWeekoff_Date  varchar(max)    
			declare @Holiday_Days		  NUMERIC(12,2)    
			declare @Cancel_Holiday	  NUMERIC(12,2)    
			declare @Cancel_Weekoff      NUMERIC(12,2)    
			declare @Salary_Cycle_id as numeric
			declare @Previous_Cur_Emp_ID as numeric
			set @Previous_Cur_Emp_ID = 0
			set @Salary_Cycle_id  = 0
			set @Month_St_Date = Dbo.GET_MONTH_ST_DATE(MONTH(@To_Date),year(@To_date))
			set @Month_End_Date = Dbo.GET_MONTH_END_DATE(MONTH(@To_Date),year(@To_date))
			set @OutOf_Days = DATEDIFF(D,@Month_St_Date,@Month_End_Date) + 1
			
			set @is_salary_cycle_emp_wise = 0
			select @is_salary_cycle_emp_wise = isnull(Setting_Value,0) from T0040_SETTING WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Setting_Name = 'Salary Cycle Employee Wise'
			
			declare @Lv_Encase_Calculation_Day as numeric(18,2)
			set @Lv_Encase_Calculation_Day =0
			
			
			
			declare Calc_Amount_Cur cursor for
				select Emp_ID,Branch_Id,Wages_Type,Increment_ID,Basic_Salary,Gross_Salary,calc_Amount,For_Date,Leave_Closing,Leave_Amount,Leave_ID,Lv_Encase_Calculation_Day from @Emp_Leave_Bal where  Leave_Closing <> 0
				
			open Calc_Amount_Cur
					fetch next from Calc_Amount_Cur into  @Cur_Emp_ID,@Cur_Branch_Id,@Cur_Wages_Type,@Cur_Increment_ID,@Cur_Basic_Salary,@Cur_Gross_Salary,@Cur_calc_Amount,@Cur_For_Date,@Cur_Leave_Closing,@Cur_Leave_Amount,@Cur_Leave_ID,@Lv_Encase_Calculation_Day
					while @@FETCH_STATUS = 0
						begin
						if @Previous_Cur_Emp_ID <> @Cur_Emp_ID
						 begin
									 Select @Left_Date = isnull(Emp_Left_Date,'') from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @Cur_Emp_ID and Cmp_ID = @cmp_ID
									 If @Left_date <> ''
										begin
											if isnull(@Sal_St_Date,'') = ''    
												begin    
													set @Sal_St_Date  = dbo.GET_MONTH_ST_DATE (MONTH(@Left_Date),year(@Left_Date))    
													set @Sal_End_Date = dbo.GET_MONTH_End_DATE (MONTH(@Left_Date),year(@Left_Date))
													set @OutOf_Days = datediff(d,@Sal_St_Date,@Sal_End_Date) + 1
												end     
											else if day(@Sal_St_Date) =1 --and month(@Sal_St_Date)= 1    
												begin    
													set @Sal_St_Date  = dbo.GET_MONTH_ST_DATE (MONTH(@Left_Date),year(@Left_Date))    
													set @Sal_End_Date = dbo.GET_MONTH_End_DATE (MONTH(@Left_Date),year(@Left_Date))
													set @OutOf_Days = datediff(d,@Sal_St_Date,@Sal_End_Date) + 1  	         
												end     
											else if @Sal_St_Date <> ''  and day(@Sal_St_Date) > 1   
												begin    
													set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@Left_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@Left_Date) )as varchar(10)) as smalldatetime)    
													set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date)) 
									
													if @Sal_End_Date>=@Left_Date
														begin 
															set @OutOf_Days = datediff(d,@Sal_St_Date,@Sal_End_Date) + 1
														end
													else
														begin
															set @Sal_St_Date = dateadd(mm,1,@Sal_St_Date)
															set @Sal_End_Date = dateadd(mm,1,@Sal_End_Date)

															set @OutOf_Days = datediff(d,@Sal_St_Date,@Sal_End_Date) + 1
														end
												end
												
													--Select @Present_Days = isnull(sum(LV_encash_apr_Days),0) from dbo.T0120_LEAVE_ENCASH_APPROVAL where Emp_ID = @Cur_Emp_ID and Cmp_ID = @cmp_ID
													--						and lv_Encash_apr_Status ='A' and Is_FNF=1
																			
													--Select  @upto_date= max(Upto_Date) from dbo.T0120_LEAVE_ENCASH_APPROVAL where Emp_ID = @Cur_Emp_ID and Cmp_ID = @cmp_ID
													--						and lv_Encash_apr_Status ='A'  and Is_FNF=1

													
													--Select @Allow_Effect_on_Leave = SUM(E_AD_AMOUNT) from dbo.T0100_EMP_EARN_DEDUCTION EED 
													--	Inner Join T0050_AD_MASTER AM on EED.AD_ID = Am.AD_ID And EED.CMP_ID = Am.CMP_ID 
													--Where INCREMENT_ID = @Increment_Id_New And EMP_ID = @Cur_Emp_ID And Isnull(AM.AD_EFFECT_ON_LEAVE,0) = 1
										end
									 else
										begin
												if @is_salary_cycle_emp_wise = 1
													begin
													
														SELECT @Salary_Cycle_id = salDate_id from T0095_Emp_Salary_Cycle WITH (NOLOCK) where emp_id = @Cur_Emp_ID AND effective_date in
															(
																SELECT max(effective_date) as effective_date from T0095_Emp_Salary_Cycle WITH (NOLOCK)
																	where emp_id = @Cur_Emp_ID AND effective_date <=  @To_Date
																	GROUP by emp_id
															)
											
															SELECT @Sal_St_Date = SALARY_ST_DATE FROM t0040_salary_cycle_master WITH (NOLOCK) where tran_id = @Salary_Cycle_id
													end
					 							else
													begin
														select @Sal_St_Date  =Sal_st_Date ,@manual_salary_period=isnull(Manual_Salary_Period ,0) 
														from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID and Branch_ID = @Cur_Branch_Id    
														and For_Date = (
																		 select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where 
																			For_Date <=@To_Date and Branch_ID = @Cur_Branch_Id and Cmp_ID = @Cmp_ID
																		)    
													end	
				
													set @manual_salary_period = isnull(@manual_salary_period,0)
			
													if isnull(@Sal_St_Date,'') = ''    
														begin    
																set @Month_St_Date  = @Month_St_Date     
																set @Month_End_Date = @Month_End_Date    
																set @OutOf_Days = @OutOf_Days
														end     
													else if day(@Sal_St_Date) =1  
														begin    
																set @Month_St_Date  = @Month_St_Date     
																set @Month_End_Date = @Month_End_Date    
																set @OutOf_Days = @OutOf_Days    	         
														end     
													else if @Sal_St_Date <> ''  and day(@Sal_St_Date) > 1   
														begin    
															if @manual_salary_period = 0 
																begin
																	set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@Month_St_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@Month_St_Date) )as varchar(10)) as smalldatetime)    
																	set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date)) 
																	set @OutOf_Days = datediff(d,@Sal_St_Date,@Sal_End_Date) + 1
																	
																	Set @Month_St_Date = @Sal_St_Date
																	Set @Month_End_Date = @Sal_End_Date 
																 end 
															else
																begin
																	select @Sal_St_Date=from_date,@Sal_End_Date=end_date from salary_period where month= month(@Month_St_Date) and YEAR=year(@Month_St_Date)
																	set @OutOf_Days = datediff(d,@Sal_St_Date,@Sal_End_Date) + 1
																	Set @Month_St_Date = @Sal_St_Date
																	Set @Month_End_Date = @Sal_End_Date 
																end   
											end
										end
										select 
										@Lv_Encash_W_Day = isnull(Lv_Encash_W_Day,0),
										@IS_ROUNDING = ISNULL(AD_Rounding,0),
										@Lv_Encash_Cal_On = isnull(Lv_Encash_Cal_On,''),
										@Inc_Weekoff =Inc_Weekoff ,
										@Is_Cancel_Holiday = isnull(is_Cancel_Holiday,0),
										@Is_Cancel_weekoff  = isnull(Is_Cancel_Weekoff,0)
										from dbo.T0040_GENERAL_SETTING WITH (NOLOCK) where 
										cmp_ID = @cmp_ID	and Branch_ID = @Cur_Branch_Id
										and For_Date = ( 
															select max(For_Date) from dbo.T0040_GENERAL_SETTING WITH (NOLOCK) where 
															For_Date <=@To_Date and Branch_ID = @Cur_Branch_Id and Cmp_ID = @Cmp_ID
														)
														
										
			
									--	  Exec SP_EMP_HOLIDAY_DATE_GET @Cur_Emp_ID,@Cmp_ID,@Month_St_Date,@Month_End_Date,@Join_Date,@left_Date,@Is_Cancel_Holiday,@StrHoliday_Date output,@Holiday_days output,@Cancel_Holiday output,0,@Cur_Branch_Id,@StrWeekoff_Date
									--	  Exec SP_EMP_WEEKOFF_DATE_GET @Cur_Emp_ID,@Cmp_ID,@Month_St_Date,@Month_End_Date,@Join_Date,@left_Date,@Is_Cancel_weekoff,@StrHoliday_Date,@StrWeekoff_Date output,@Weekoff_Days output ,@Cancel_Weekoff output    
					
										--if @Inc_Weekoff = 1 
										--	begin
										--			set	@Working_Days = @OutOf_Days
										--	end
										--else
										--	begin
										--			set @Working_Days = @OutOf_Days - @Weekoff_Days
										--	end	
										set	@Working_Days = @OutOf_Days
										
						    end
				
										
					if isnull(@Lv_Encase_Calculation_Day,0) > 0 
						set @Lv_Encash_W_Day= @Lv_Encase_Calculation_Day											
						
						
						---Added By Jimit 09022018
							DECLARE @LV_ENCASH_W_DAY_Master as NUMERIC
							SELECT @LV_ENCASH_W_DAY_Master = LEAVE_ENCASH_WORKING_DAYS 
							FROM T0080_EMP_MASTER WITH (NOLOCK)
							WHERE EMP_ID = @Cur_Emp_ID AND CMP_ID = @CMP_ID	
							
							IF @LV_ENCASH_W_DAY_Master > 0
								SET @Lv_Encash_W_Day = @LV_ENCASH_W_DAY_Master					
							---Ended
						
						If @Lv_Encash_Cal_On = 'Gross' and  @Cur_Wages_Type = 'Monthly' 
							begin
									
										if @Lv_Encash_W_Day > 0
											begin
													Update @Emp_Leave_Bal set calc_Amount = @Cur_Gross_Salary   
													where Cmp_ID= @Cmp_ID and Emp_ID = @Cur_Emp_ID
													
													Update @Emp_Leave_Bal set Leave_Amount = (calc_Amount/@Lv_Encash_W_Day)*Leave_Closing 
													from @Emp_Leave_Bal  ELB
													Inner join 
													(
															select Emp_ID,Leave_ID from @Emp_Leave_Bal where Cmp_ID =@Cmp_ID
													) Qry 
															on ELB.Emp_ID = Qry.Emp_ID and ELB.Leave_ID = Qry.Leave_ID
															where Cmp_ID= @Cmp_ID and ELB.Emp_ID = @Cur_Emp_ID and elb.Leave_ID = @Cur_Leave_ID
															
													
													
											end
										else
											begin
													Update @Emp_Leave_Bal set calc_Amount = @Cur_Gross_Salary   
														where Cmp_ID= @Cmp_ID and Emp_ID = @Cur_Emp_ID
													
													Update @Emp_Leave_Bal set Leave_Amount = (calc_Amount/@Working_Days )*Leave_Closing  
													from @Emp_Leave_Bal  ELB
													Inner join 
													(
															select Emp_ID,Leave_ID from @Emp_Leave_Bal where Cmp_ID =@Cmp_ID
													) Qry 
															on ELB.Emp_ID = Qry.Emp_ID and ELB.Leave_ID = Qry.Leave_ID
															where Cmp_ID= @Cmp_ID and ELB.Emp_ID = @Cur_Emp_ID and elb.Leave_ID = @Cur_Leave_ID
															
															
											end
							
							end
						else
							begin
							
								Update @Emp_Leave_Bal set calc_Amount = Basic_Salary + ISNULL(Qry.E_AD_AMOUNT,0)  from @Emp_Leave_Bal  ELB
									Inner join 
									(	Select SUM(E_AD_AMOUNT) as E_AD_AMOUNT,Emp_ID,INCREMENT_ID from dbo.T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK)
											Inner Join T0050_AD_MASTER AM WITH (NOLOCK) on EED.AD_ID = Am.AD_ID And EED.CMP_ID = Am.CMP_ID 
											Where Isnull(AM.AD_EFFECT_ON_LEAVE,0) = 1 group by EMP_ID,INCREMENT_ID
									 ) Qry 
										on ELB.Emp_ID = Qry.Emp_ID and  ELB.Increment_ID = Qry.INCREMENT_ID
									where Cmp_ID= @Cmp_ID and ELB.Emp_ID = @Cur_Emp_ID and elb.Leave_ID = @Cur_Leave_ID
						
								if @Lv_Encash_W_Day > 0
											begin
											
												Update @Emp_Leave_Bal set Leave_Amount = (calc_Amount/@Lv_Encash_W_Day)*Leave_Closing from @Emp_Leave_Bal  ELB
												Inner join 
												(
														select Emp_ID,Leave_ID from @Emp_Leave_Bal where Cmp_ID =@Cmp_ID) Qry 
														on ELB.Emp_ID = Qry.Emp_ID and ELB.Leave_ID = Qry.Leave_ID
														where Cmp_ID= @Cmp_ID and ELB.Emp_ID = @Cur_Emp_ID and elb.Leave_ID = @Cur_Leave_ID
													
											select 	* from @Emp_Leave_Bal
											end
								else
											begin
												Update @Emp_Leave_Bal set Leave_Amount = (calc_Amount/@Working_Days)*Leave_Closing from @Emp_Leave_Bal  ELB
												Inner join 
												(
														select Emp_ID,Leave_ID from @Emp_Leave_Bal where Cmp_ID =@Cmp_ID) Qry 
														on ELB.Emp_ID = Qry.Emp_ID and ELB.Leave_ID = Qry.Leave_ID
														where Cmp_ID= @Cmp_ID and ELB.Emp_ID = @Cur_Emp_ID and elb.Leave_ID = @Cur_Leave_ID
											end
								
							end
							set @Previous_Cur_Emp_ID = @Cur_Emp_ID
					fetch next from Calc_Amount_Cur into  @Cur_Emp_ID,@Cur_Branch_Id,@Cur_Wages_Type,@Cur_Increment_ID,@Cur_Basic_Salary,@Cur_Gross_Salary,@Cur_calc_Amount,@Cur_For_Date,@Cur_Leave_Closing,@Cur_Leave_Amount,@Cur_Leave_ID,@Lv_Encase_Calculation_Day		
					end
					close Calc_Amount_Cur
				deallocate Calc_Amount_Cur
----Ankit 09122014				
	SELECT	el.Cmp_ID ,Emp_ID ,Branch_Id ,Wages_Type ,Increment_ID ,Basic_Salary ,Gross_Salary ,calc_Amount	,For_Date ,Leave_Closing ,Leave_Amount ,el.Leave_ID ,l.Leave_Name
	Into #v_Leave_pvt 
	From @Emp_Leave_Bal el Inner Join 
		T0040_LEAVE_MASTER as l WITH (NOLOCK) on el.Leave_ID = l.Leave_ID and l.Leave_Type = 'Encashable' 
	Where Leave_Closing <> 0
	
	
	Declare @ColsPivot_Leave as varchar(max),@ColsPivot_Leave_Null as varchar(max),@ColsPivot_Leave_Amount as varchar(max),
		@qry_Leave as varchar(max),@qry_Leave_Amount as varchar(max)

		set @ColsPivot_Leave=''				
		Set @ColsPivot_Leave_Amount = ''
		
		SELECT @ColsPivot_Leave += ',' + QUOTENAME(REPLACE(CAST(Leave_Name AS VARCHAR(MAX)),' ','_' ))
		from (select distinct leave_name from #v_Leave_pvt) as a 
		
		SELECT @ColsPivot_Leave_Amount += ',' + QUOTENAME(REPLACE(CAST(Leave_Name AS VARCHAR(MAX) ),' ','_' )+ '_amount' )
		from (select distinct leave_name from #v_Leave_pvt) as a
		
			
	if exists(select * from #v_Leave_Pvt)
		begin
		
			set @qry_Leave = 'select Emp_id'+@colsPivot_Leave+' into v_Leave 
				from (select emp_id,REPLACE(CAST(Leave_Name AS VARCHAR(MAX)),'' '',''_'' ) as Leave_Name, Leave_Closing from #v_Leave_pvt) 
				as Leave_Closing pivot 
				( sum(Leave_Closing) 
				for Leave_Name in (' + isnull(STUFF(@colsPivot_Leave, 1, 1, ''),'[0]') + ') ) p ORDER BY emp_id' 
			exec (@qry_Leave)
	
		end		

	select * into #v_Leave from v_Leave
	drop table v_Leave
							
	if exists(select * from #v_Leave_Pvt)
		begin
		
			set @qry_Leave_Amount = 'select Emp_id'+ @ColsPivot_Leave_Amount+' into v_Leave_Amt 
				from (select emp_id,REPLACE(CAST(Leave_Name AS VARCHAR(MAX)),'' '',''_'' )+''_Amount'' as Leave_Name, Leave_Amount from #v_Leave_pvt) 
				as Leave_Amount pivot 
				( sum(Leave_Amount) 
				for Leave_Name in (' + isnull(STUFF(@ColsPivot_Leave_Amount, 1, 1, ''),'[0]') + ') ) p ORDER BY emp_id' 
			
			exec (@qry_Leave_Amount)
	
	
	
		end
	
		
	
	select * into #v_Leave_Amount from v_Leave_Amt
	drop table v_Leave_Amt


----Ankit 09122014

	--select --el.*,
	--	Alpha_Emp_Code,Emp_Full_Name
	--	,b.branch_name , g.Grd_name , d.dept_name,dgm.Desig_Name,vs.Vertical_Name,cm.Cmp_Name,cm.Cmp_Address,el.*,el1.*
	--From 
	--	--@Emp_Leave_Bal el Inner Join T0040_LEAVE_MASTER as l on el.Leave_ID = l.Leave_ID and l.Leave_Type = 'Encashable' inner join
	--	#v_Leave el inner join
	--	#v_Leave_Amount el1 on el.emp_id = el1.emp_id inner join 
	--	T0080_EMP_MASTER e  on el.Emp_ID =e.Emp_ID inner join 
	--	(select I.Emp_Id ,Grd_ID,Branch_ID,Dept_ID,Desig_ID,Type_ID,Vertical_ID from T0095_Increment I inner join 
	--				( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment
	--				where Increment_Effective_date <= @To_Date
	--				and Cmp_ID = @Cmp_ID
	--				group by emp_ID  ) Qry on
	--				I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID)IQ on el.Emp_ID =iq.Emp_ID Inner join
	--	 T0040_GRADE_MASTER  g on iq.Grd_ID =g.Grd_ID inner join 
	--	 T0030_Branch_Master b on iq.Branch_ID = b.Branch_ID left outer join
	--	 T0040_Department_Master d on iq.dept_ID =d.Dept_ID  left outer join 
	--	 T0040_Designation_Master dgm on iq.desig_ID =dgm.Desig_ID inner join 
	--	 T0010_Company_master as CM on e.cmp_ID = cm.Cmp_ID left Join 
	--	 T0040_Vertical_Segment VS on IQ.Vertical_ID = vs.Vertical_ID 
		 
	--	 --where el.Leave_Closing <> 0
	--ORDER BY RIGHT(REPLICATE(N' ', 500) + ALPHA_EMP_CODE, 500)--,Leave_Name 
	
Declare @str as varchar(max)

