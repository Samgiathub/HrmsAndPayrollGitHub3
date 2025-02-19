


-- =============================================
-- Author:		<Gadriwala Muslim >
-- ALTER date: <05/01/2014>
-- Description:	<Calculate Gate Pass Deduction as Per Gate Pass Regularization>
-- =============================================
CREATE PROCEDURE [dbo].[Calc_Gate_Pass_Present_Days_Deduction] 
	 @Emp_Id numeric(18,0)
	,@cmp_Id numeric(18,0)
	,@Branch_id numeric(18,0)
	,@Sal_St_Date Datetime
	,@Sal_End_Date datetime
	,@GatePass_Deduct_Days numeric(18,2) = 0 output
	,@Constraint  nvarchar(max)
	,@Used_Table tinyint = 0
AS
BEGIN
	SET NOCOUNT ON;
	
	CREATE table #Emp_Cons 
	 (      
	   Emp_ID numeric ,     
	   Branch_ID numeric,
	   Increment_ID numeric    
	 )  
	
	IF @Constraint <> ''
		begin
			 Insert Into #Emp_Cons(Emp_ID)        
					select  cast(data  as numeric) from dbo.Split (@Constraint,'#')	      
		end
	else
		begin
			Insert into #Emp_Cons(Emp_ID)
					select @Emp_ID
		end
	
	declare @cur_emp_ID as numeric(18,0)
	set @cur_emp_ID = 0
	declare @Upto_days numeric(18,2)
						declare @Upto_Hours varchar(25)
						declare @Deduct_Days numeric(18,2)
						declare @Above_Hours varchar(25)
						declare @Deduct_Above_days numeric(18,2)
						declare @Tran_id numeric(18,0)
						declare @Gate_Pass_Sec integer
					    declare @Upto_days_Count numeric(18,0)
						Declare @Half_Shift_Duration numeric(18,2)
						Declare @Prev_Branch_ID as numeric(18,0) 
						set @Half_Shift_Duration = 0	
						set @Upto_days = 0
						set @Upto_Hours = ''
						set @Deduct_Days= 0
						set @Above_Hours = ''
						set @Deduct_Above_days = 0
						set @Upto_days_Count = 0		   
						set @Gate_Pass_Sec = 0
						set @Prev_Branch_ID = 0
						
	declare curEmp1 cursor for select emp_ID from #Emp_Cons
	open curEmp1
			fetch next from curEmp1 into @cur_emp_id
			while @@FETCH_STATUS = 0 
				begin
						
						select @Branch_id = Branch_id from dbo.T0095_INCREMENT i WITH (NOLOCK) Inner join
						( 
							select MAX(Increment_ID) as Increment_Id from dbo.T0095_INCREMENT  WITH (NOLOCK) 
							where Emp_ID = @cur_emp_id and Cmp_ID = @cmp_Id  
							and Increment_Effective_Date <= @Sal_End_Date
						) qry on Qry.Increment_Id = i.Increment_ID
						where Emp_id = @cur_emp_id and Cmp_ID = @cmp_Id and Increment_Effective_Date <= @Sal_End_Date
				
						if @Prev_Branch_ID  <> @Branch_id
						 begin
								select @Upto_days = Upto_days
									  ,@Upto_Hours = Upto_Hours
								,@Deduct_Days = Deduct_days
								,@Above_Hours = Above_Hours
								,@Deduct_Above_days = Deduct_Above_days 	
								from [dbo].[T0010_Gate_Pass_Settings]  WITH (NOLOCK) where Branch_id = @Branch_id
						  end
						if @Upto_Hours = '00:00'
							set  @Upto_Hours = ''
						if @Above_Hours = '00:00'
							set @Above_Hours = ''
						declare @For_Date_deduct_days as numeric(18,2)
						set @For_Date_deduct_days = 0
						set @GatePass_Deduct_Days = 0
							
						declare @Exempted as tinyint
						set @Exempted = 0
						Set @Upto_days_Count =0
						Declare @For_gatePass as datetime
						  
	
						Declare CurGatepass cursor for  select dbo.F_Return_Sec(REPLACE(Hours,'*','0')) as Hours,
							Exempted,isnull(DateDiff(S,Shift_St_Time,Shift_End_Time)/2,0) as Half_Shift_Duration,For_Date 
							from dbo.T0150_EMP_Gate_Pass_INOUT_RECORD EG  WITH (NOLOCK) inner join T0040_Reason_Master r  WITH (NOLOCK) on R.Res_Id = EG.Reason_id 
								and Gate_Pass_Type = 'Personal'  
								 where emp_id = @cur_emp_id and cmp_Id = @cmp_Id and Is_Approved = 1  
								 and For_date >= @Sal_St_Date and For_date <= @Sal_End_Date  	
								 order by for_date
						Open CurGatepass
							Fetch Next from CurGatepass into @Gate_Pass_Sec,@Exempted,@Half_Shift_duration,@For_gatePass
								WHILE @@fetch_status = 0
									BEGIN	
										set @For_Date_deduct_days = 0
										if @Above_Hours <> '' and @Upto_Hours <> '' 
											begin	
												if  @Gate_Pass_Sec > @Half_Shift_Duration and @Half_Shift_Duration > 0 
													begin
														set @Upto_days_Count = @Upto_days_Count + 1	
														If @Exempted = 0
															begin
																set @GatePass_Deduct_Days = @GatePass_Deduct_Days  +  1	
																set @For_Date_deduct_days = 1
															end
													end
												else if  @Gate_Pass_Sec > dbo.F_Return_Sec(@Above_Hours) 
													begin
														set @Upto_days_Count = @Upto_days_Count + 1
														If @Exempted = 0
															begin
																set @GatePass_Deduct_Days = @GatePass_Deduct_Days  +  @Deduct_Above_days
																set @For_Date_deduct_days = @Deduct_Above_days
															end
													end
												else if( @Gate_Pass_Sec <= dbo.F_Return_Sec(@Upto_Hours) or @Gate_Pass_Sec <= dbo.F_Return_Sec(@Above_Hours)  ) 
													begin
														set @Upto_days_Count = @Upto_days_Count + 1
														If @Exempted = 0
															begin
																if @Upto_days_Count > @Upto_days 
																	begin
																		set @GatePass_Deduct_Days = @GatePass_Deduct_Days  +  @Deduct_Days
																		set @For_Date_deduct_days = @Deduct_Days
																	end
															end
													end
											end
										else if @Upto_Hours <> '' and @Above_Hours = ''
											begin
												if @Gate_Pass_Sec >= 1
													begin
														set @Upto_days_Count = @Upto_days_Count + 1
														If @Exempted = 0
															begin		
																If @Gate_Pass_Sec > @Half_Shift_Duration and @Half_Shift_Duration > 0
																	begin
																		set @GatePass_Deduct_Days = @GatePass_Deduct_Days  + 1
																		set @For_Date_deduct_days = 1
																	end
																else 
																	begin
																if @Upto_days_Count > @Upto_days 
																	begin
																		set @GatePass_Deduct_Days = @GatePass_Deduct_Days  +  @Deduct_Days
																		set @For_Date_deduct_days = @Deduct_Days
																	end
															end
													end
											end
								end
								else if @Above_Hours <> '' and @Upto_Hours = ''
									begin
										If @Exempted = 0 
											begin
												If @Gate_Pass_Sec > @Half_Shift_Duration and @Half_Shift_Duration > 0 
													begin
														set @GatePass_Deduct_Days = @GatePass_Deduct_Days  +  1
														set @For_Date_deduct_days = 1
													end
												else if @Gate_Pass_Sec > dbo.F_Return_Sec(@Above_Hours) 
													begin
														set @GatePass_Deduct_Days = @GatePass_Deduct_Days  +  @Deduct_Above_days
														set @For_Date_deduct_days = @Deduct_Above_days
													end
											end		
									end
									
								if @Used_Table = 1
									begin
										Insert into #EMP_Gate_Pass
										select @cur_emp_ID,@For_gatePass,@For_Date_deduct_days
									end	
							Fetch next from CurGatepass into @Gate_Pass_Sec,@Exempted,@Half_Shift_duration,@For_gatePass
							END 
						Close CurGatepass
						Deallocate CurGatepass
						
						
						set @Prev_Branch_ID = @branch_ID
							fetch next from curEmp1 into @cur_emp_id
					end
				close curEmp1
				deallocate curEmp1
		
	
	--if @Branch_id = 0 
	--	begin
					
	--	end
		
	
     
END




