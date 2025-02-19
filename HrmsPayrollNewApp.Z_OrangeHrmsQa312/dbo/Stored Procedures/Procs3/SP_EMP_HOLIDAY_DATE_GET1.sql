

---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_EMP_HOLIDAY_DATE_GET1]
 @Emp_ID			numeric
,@Cmp_ID			numeric
,@From_Date			datetime
,@To_Date			datetime
,@join_Date			datetime = null
,@Left_Date			datetime = null
,@Is_Cancel_Holiday	NUMERIC(1,0)
,@StrHoliday_Date	varchar(Max) = null output 
,@HoliDay_Days		numeric(5,1) output
,@Cancel_Holiday	numeric(5,1) output
,@Use_Table			tinyint = 0
,@Branch_ID			numeric = 0
,@StrWeekoff_Date   Varchar(Max)=null
,@Is_Leave_Cal tinyint = 0
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	Declare @H_From_Date	Datetime 
	Declare @H_To_Date		Datetime 
	Declare @Date_Diff		numeric
	Declare @varHoliday_Date varchar(Max)
	Declare @For_Date		datetime
	Declare @Is_Half		tinyint
	Declare @Is_P_Comp		tinyint
	Declare @H_Days			numeric(3,1)
	Declare @Is_Cancel		tinyint
	Declare @Pre_Date_WeekOff datetime 
	Declare @Next_Date_WeekOff	Datetime
	DECLARE @Branch_Id_Temp  Numeric
	DECLARE @genral_Cancel_Holiday tinyint
	DECLARE @is_Fix varchar
	
	set @varHoliday_Date = ''
	set @Cancel_Holiday = 0
	set @HoliDay_Days = 0
	set @Is_Cancel =0
	set @Branch_Id_Temp =0 
	set @genral_Cancel_Holiday = 0
	set @is_Fix = 'N'
	
	
	
	If isnull(@join_Date,'') = ''
		Begin
			exec dbo.SP_EMP_JOIN_LEFT_DATE_GET @Emp_ID ,@Cmp_ID ,@From_Date,@To_Date,@Join_Date output ,@Left_Date output
		End

	If isnull(@Left_Date,'') <> '' 
		begin
			if @Left_Date < @Join_Date  
				set @Left_Date = null	
		end
	
	if @Join_Date > @From_Date
		set @From_Date = @Join_Date

	select @Branch_Id_Temp = Branch_ID from dbo.T0095_Increment EI WITH (NOLOCK) where Increment_Effective_Date in (select max(Increment_effective_Date) as Increment_effective_Date from dbo.T0095_Increment WITH (NOLOCK) where Increment_Effective_date <= @To_Date  and Cmp_ID = @Cmp_ID and Emp_ID = @Emp_Id) and Emp_ID = @Emp_Id
	--select @genral_Cancel_Holiday = Is_Cancel_Holiday from dbo.T0040_GENERAL_SETTING GS where For_Date in (select max(For_Date) as For_Date from dbo.T0040_GENERAL_SETTING  where For_Date <= @To_Date  and Cmp_ID = @Cmp_ID and Branch_ID = @Branch_Id_Temp) and Branch_ID = @Branch_Id_Temp
		

	
	declare curHoliday cursor fast_forward for
	--	select distinct  H_From_Date , H_To_Date ,isnull(Is_Half,0) ,isnull(Is_P_Comp,0) , is_fix from dbo.T0040_HOLIDAY_MASTER where (((@From_Date >= h_from_date and @From_Date <= h_to_date) 
	--									or (@To_Date >= h_from_date and @To_Date <= h_to_date) 
	--									or (H_to_date >= @From_Date and H_to_date <= @To_Date)) or														
	--									((month(@From_Date) = month(h_from_date) or month(@to_date) = month(h_from_date) or month(@From_Date) = month(h_to_date) or month(@to_date) = month(h_to_date))													
	--									and is_fix = 'Y'))
	--and Cmp_ID = @Cmp_ID and ISNULL(Is_Optional,0)= 0 and ( isnull(Branch_ID,0) = 0 or isnull(Branch_ID,0) =@Branch_Id_Temp) 
	-- or  Hday_ID in (SELECT Hday_ID from T0120_Op_Holiday_Approval where cmp_ID=@Cmp_ID and emp_ID=@Emp_ID and Op_Holiday_apr_Status='A')
			SELECT DISTINCT CAST(CAST(DATENAME(DAY,H_FROM_DATE) AS VARCHAR(2)) + '-' + CAST(DATENAME(MONTH,H_FROM_DATE)AS VARCHAR(3)) + '-' + CASE WHEN MONTH(H_FROM_DATE) > MONTH(@TO_DATE) THEN CAST(YEAR(@FROM_DATE)AS VARCHAR(4)) ELSE CAST(YEAR(@TO_DATE)AS VARCHAR(4)) END AS DATETIME) AS H_FROM_DATE,
				CAST(CAST(DATENAME(DAY,H_TO_DATE) AS VARCHAR(2)) + '-' + CAST(DATENAME(MONTH,H_TO_DATE)AS VARCHAR(3)) + '-' + CASE WHEN MONTH(H_TO_DATE) > MONTH(@TO_DATE) THEN CAST(YEAR(@FROM_DATE)AS VARCHAR(4)) ELSE CAST(YEAR(@TO_DATE)AS VARCHAR(4)) END AS DATETIME) AS H_TO_DATE,
				ISNULL(IS_HALF,0) ,ISNULL(IS_P_COMP,0) , IS_FIX 
			FROM T0040_HOLIDAY_MASTER WITH (NOLOCK)
				WHERE CMP_ID=@CMP_ID AND IS_FIX = 'Y' AND ISNULL(IS_OPTIONAL,0)= 0 AND (ISNULL(BRANCH_ID,0) = 0 OR ISNULL(BRANCH_ID,0) =@BRANCH_ID_TEMP) AND
					@FROM_DATE <= 
						CAST(CAST(DATENAME(DAY,H_FROM_DATE) AS VARCHAR(2)) + '-' + CAST(DATENAME(MONTH,H_FROM_DATE)AS VARCHAR(3)) + '-' + CASE WHEN MONTH(H_FROM_DATE) > MONTH(@TO_DATE) THEN CAST(YEAR(@FROM_DATE)AS VARCHAR(4)) ELSE CAST(YEAR(@TO_DATE)AS VARCHAR(4)) END AS DATETIME) 
					AND 
					@TO_DATE >= 
						CAST(CAST(DATENAME(DAY,H_FROM_DATE) AS VARCHAR(2)) + '-' + CAST(DATENAME(MONTH,H_FROM_DATE)AS VARCHAR(3)) + '-' + CASE WHEN MONTH(H_FROM_DATE) > MONTH(@TO_DATE) THEN CAST(YEAR(@FROM_DATE)AS VARCHAR(4)) ELSE CAST(YEAR(@TO_DATE)AS VARCHAR(4)) END AS DATETIME)
		UNION ALL
			SELECT DISTINCT  CAST(CAST(DATENAME(DAY,H_FROM_DATE) AS VARCHAR(2)) + '-' + CAST(DATENAME(MONTH,H_FROM_DATE)AS VARCHAR(3)) + '-' + CASE WHEN MONTH(H_FROM_DATE) > MONTH(@TO_DATE) THEN CAST(YEAR(@FROM_DATE)AS VARCHAR(4)) ELSE CAST(YEAR(@TO_DATE)AS VARCHAR(4)) END AS DATETIME) AS H_FROM_DATE,
				CAST(CAST(DATENAME(DAY,H_TO_DATE) AS VARCHAR(2)) + '-' + CAST(DATENAME(MONTH,H_TO_DATE)AS VARCHAR(3)) + '-' + CASE WHEN MONTH(H_TO_DATE) > MONTH(@TO_DATE) THEN CAST(YEAR(@FROM_DATE)AS VARCHAR(4)) ELSE CAST(YEAR(@TO_DATE)AS VARCHAR(4)) END AS DATETIME) AS H_TO_DATE,
				ISNULL(IS_HALF,0) ,ISNULL(IS_P_COMP,0) , IS_FIX 
			FROM T0040_HOLIDAY_MASTER WITH (NOLOCK) WHERE CMP_ID=@CMP_ID AND HDAY_ID IN (SELECT HDAY_ID FROM T0120_OP_HOLIDAY_APPROVAL WITH (NOLOCK)
			WHERE CMP_ID=@CMP_ID AND EMP_ID=@EMP_ID AND OP_HOLIDAY_APR_STATUS='A')
		UNION ALL
			SELECT DISTINCT  H_FROM_DATE , H_TO_DATE ,ISNULL(IS_HALF,0) ,ISNULL(IS_P_COMP,0) , IS_FIX 
			FROM T0040_HOLIDAY_MASTER WITH (NOLOCK)
			WHERE CMP_ID=@CMP_ID AND H_FROM_DATE >= @FROM_DATE AND H_TO_DATE <= @TO_DATE AND ISNULL(IS_OPTIONAL,0)=0 AND IS_FIX = 'N'
			AND (ISNULL(BRANCH_ID,0) = 0 OR ISNULL(BRANCH_ID,0) =@BRANCH_ID_TEMP)	
	 
	open curHoliday
		fetch next from curHoliday into @H_From_Date,@H_To_Date,@Is_Half,@Is_P_Comp,@is_Fix
		while @@fetch_status = 0
			begin							
				if @is_Fix = 'Y'
					begin	
						declare @get_curr_date as datetime
										set @get_curr_date = GETDATE()
						if year(@from_date) = year(@to_date) -- addded by mitesh on 23012013
							begin
								 
								set @H_From_Date = cast(DAY(@H_From_Date) as nvarchar(2)) + '-' + left(datename(MONTH, @H_From_Date ),3) + '-' + cast(year(@to_Date) as nvarchar(4)) -- @to_date changed by mitesh on 23012013
								set @H_To_Date = cast(DAY(@H_To_Date) as nvarchar(2)) + '-' + left(datename(MONTH, @H_To_Date ),3) + '-' + cast(year(@to_Date) as nvarchar(4))  -- @to_date changed by mitesh on 23012013
							end
						else
							begin								
								
								 														
								 if day(@H_From_Date) > day(@from_date)
									begin
										
										set @H_From_Date = cast(DAY(@H_From_Date) as nvarchar(2)) + '-' + left(datename(MONTH, @H_From_Date ),3) + '-' + cast(year(@from_date) as nvarchar(4)) -- @to_date changed by mitesh on 23012013
										set @H_To_Date = cast(DAY(@H_To_Date) as nvarchar(2)) + '-' + left(datename(MONTH, @H_To_Date ),3) + '-' + cast(year(@from_date) as nvarchar(4))  -- @to_date changed by mitesh on 23012013
									end
								--else if year(@H_From_Date) = year(@H_To_Date) and year(@H_From_Date) = year(@to_date)
								--	begin
											 
								--			set @H_From_Date = cast(DAY(@H_From_Date) as nvarchar(2)) + '-' + left(datename(MONTH, @H_From_Date ),3) + '-' + cast(year(@to_Date) as nvarchar(4)) -- @to_date changed by mitesh on 23012013
								--			set @H_To_Date = cast(DAY(@H_To_Date) as nvarchar(2)) + '-' + left(datename(MONTH, @H_To_Date ),3) + '-' + cast(year(@to_Date) as nvarchar(4))  -- @to_date changed by mitesh on 23012013
								--	end
								else --if @H_From_Date = @H_To_Date  
									begin 
													 
											set @H_From_Date = cast(DAY(@H_From_Date) as nvarchar(2)) + '-' + left(datename(MONTH, @H_From_Date ),3) + '-' + cast(year(@to_Date) as nvarchar(4)) -- @to_date changed by mitesh on 23012013
											set @H_To_Date = cast(DAY(@H_To_Date) as nvarchar(2)) + '-' + left(datename(MONTH, @H_To_Date ),3) + '-' + cast(year(@to_Date) as nvarchar(4))  -- @to_date changed by mitesh on 23012013
									end	
								--else  
								--	begin 
											 
								--			set @H_From_Date = cast(DAY(@H_From_Date) as nvarchar(2)) + '-' + left(datename(MONTH, @H_From_Date ),3) + '-' + cast(year(@from_date) as nvarchar(4)) -- @to_date changed by mitesh on 23012013
								--			set @H_To_Date = cast(DAY(@H_To_Date) as nvarchar(2)) + '-' + left(datename(MONTH, @H_To_Date ),3) + '-' + cast(year(@to_date) as nvarchar(4))  -- @to_date changed by mitesh on 23012013
								--	end
							end
					end
								
				If @H_From_Date < @From_Date
					set @For_Date = @From_Date
				else
					set @For_Date = @H_From_Date
					
				If @H_To_Date > @To_Date      --Add BY hasmukh 22 11 2011 when holiday from date 24/10/2011 to 02/11/2011 then holiday result was worng before
					set @H_To_Date = @To_Date
				else
					set @H_To_Date = @H_To_Date
				
				 if @Is_Half  = 1
					set @H_Days = 0.5
				 else
					set @H_Days = 1
					
				
				
				While @For_Date <=  @To_Date and @For_Date <= @H_To_Date
				begin						          
						
							set @Is_Cancel = 0
							
							if @Is_P_Comp =1 and not exists(select Emp_ID from dbo.T0150_EMP_INOUT_RECORD WITH (NOLOCK) WHERE EMP_ID =@EMP_ID AND FOR_DATE =@FOR_DATE AND
																	( NOT IN_TIME IS NULL OR NOT OUT_TIME IS NULL))
									BEGIN
										
										Set @Is_Cancel =1 
									END
							--else if exists (select lad.Leave_Approval_ID from dbo.T0120_LEAVE_APPROVAL LA inner join T0130_LEAVE_APPROVAL_DETAIL LAD on LA.Leave_Approval_ID = LAD.Leave_Approval_ID inner join dbo.T0040_LEAVE_MASTER LM on lm.Leave_ID = LAD.Leave_ID where la.Emp_ID = @Emp_Id and ((@For_date >= lad.From_Date and @For_date <= lad.To_Date) ) and Approval_Status = 'A') and exists (select 1 from dbo.T0140_LEAVE_TRANSACTION LT where  lT.Emp_ID = @Emp_Id and Lt.For_Date = @For_date and lt.Leave_Used <> 0)
							--				begin
												
							--					Set @Is_Cancel =1 
							--				end			
									
							else --if @Is_Cancel_Holiday =1 
									begin
											
											
											exec dbo.SP_RETURN_PRE_NEXT_DATE_OF_WEEKOFF @For_Date,@varHoliday_Date,@Pre_Date_WeekOff output,@Next_Date_WeekOff output
											
										
											
											if not exists(select Emp_ID from dbo.T0150_EMP_INOUT_RECORD WITH (NOLOCK) WHERE EMP_ID =@EMP_ID 
															AND (FOR_DATE =@Pre_Date_WeekOff Or For_Date=@Next_Date_WeekOff)AND--Nikunj 07-Jan-2011 Put Or in For_date Condition.For more info ask me
																			( NOT IN_TIME IS NULL OR NOT OUT_TIME IS NULL))
											Begin
													
												--Set @Is_Cancel =1 
												
												-- changed by mitesh on 26/12/2011
												
												 
											
												declare @cnt_leave_pre_next_holiday numeric(5,1)
							 					declare @chk_leave_setting_for_leave_as_holiday as tinyint
							 					declare @temp_cnt_leave_pre_next_holiday numeric(5,1)
							 					
							 					set @cnt_leave_pre_next_holiday = 0
							 					set @chk_leave_setting_for_leave_as_holiday = 0
							 					set @temp_cnt_leave_pre_next_holiday = 0
							 					
												select @cnt_leave_pre_next_holiday = COUNT(lad.Leave_Approval_ID)  ,@chk_leave_setting_for_leave_as_holiday = LM.Holiday_as_leave  from T0120_LEAVE_APPROVAL LA WITH (NOLOCK) inner join T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) on LA.Leave_Approval_ID = LAD.Leave_Approval_ID inner join T0040_LEAVE_MASTER LM WITH (NOLOCK) on lm.Leave_ID = LAD.Leave_ID where la.Emp_ID = @Emp_Id and ((@Pre_Date_WeekOff >= lad.From_Date and @Pre_Date_WeekOff <= lad.To_Date) or ( @Next_Date_WeekOff >= lad.From_Date  and   @Next_Date_WeekOff <= lad.To_Date)) and Approval_Status = 'A' group by LM.Holiday_as_leave
												
												if not @cnt_leave_pre_next_holiday >= 2 
						 							begin
						 								set @temp_cnt_leave_pre_next_holiday = 0
						 								select @temp_cnt_leave_pre_next_holiday = COUNT(lad.Leave_Approval_ID)  ,@chk_leave_setting_for_leave_as_holiday = LM.Holiday_as_leave  from T0120_LEAVE_APPROVAL LA WITH (NOLOCK) inner join T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) on LA.Leave_Approval_ID = LAD.Leave_Approval_ID inner join T0040_LEAVE_MASTER LM WITH (NOLOCK) on lm.Leave_ID = LAD.Leave_ID where la.Emp_ID = @Emp_Id and (lad.From_Date <= @Pre_Date_WeekOff and lad.To_Date >= @Next_Date_WeekOff) and Approval_Status = 'A' group by LM.Holiday_as_leave 
						 								
						 								if @temp_cnt_leave_pre_next_holiday >= 1
						 									begin	
						 										set @cnt_leave_pre_next_holiday = 2
						 									end		
						 								else
															begin																																							
																select @temp_cnt_leave_pre_next_holiday = COUNT(lad.Leave_Approval_ID)  from T0120_LEAVE_APPROVAL LA WITH (NOLOCK) inner join T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) on LA.Leave_Approval_ID = LAD.Leave_Approval_ID inner join T0040_LEAVE_MASTER LM WITH (NOLOCK) on lm.Leave_ID = LAD.Leave_ID where la.Emp_ID = @Emp_Id and ((@Pre_Date_WeekOff >= lad.From_Date and @Pre_Date_WeekOff <= lad.To_Date) or ( @Next_Date_WeekOff >= lad.From_Date  and   @Next_Date_WeekOff <= lad.To_Date)) and Approval_Status = 'A' 
																
																if @temp_cnt_leave_pre_next_holiday >=2 
																	begin	
																		select @chk_leave_setting_for_leave_as_holiday = LM.Weekoff_as_leave  from T0120_LEAVE_APPROVAL LA WITH (NOLOCK) inner join T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) on LA.Leave_Approval_ID = LAD.Leave_Approval_ID inner join T0040_LEAVE_MASTER LM WITH (NOLOCK) on lm.Leave_ID = LAD.Leave_ID where la.Emp_ID = @Emp_Id and ((@Pre_Date_WeekOff >= lad.From_Date and @Pre_Date_WeekOff <= lad.To_Date) or ( @Next_Date_WeekOff >= lad.From_Date  and   @Next_Date_WeekOff <= lad.To_Date)) and Approval_Status = 'A'  order by LM.Weekoff_as_leave  desc		
																	end
																else
																	begin	
																		select @chk_leave_setting_for_leave_as_holiday = LM.Weekoff_as_leave  from T0120_LEAVE_APPROVAL LA WITH (NOLOCK) inner join T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) on LA.Leave_Approval_ID = LAD.Leave_Approval_ID inner join T0040_LEAVE_MASTER LM WITH (NOLOCK) on lm.Leave_ID = LAD.Leave_ID where la.Emp_ID = @Emp_Id and ((@Pre_Date_WeekOff >= lad.From_Date and @Pre_Date_WeekOff <= lad.To_Date) or ( @Next_Date_WeekOff >= lad.From_Date  and   @Next_Date_WeekOff <= lad.To_Date)) and Approval_Status = 'A'  order by LM.Weekoff_as_leave  desc		
																	end
																																			
															end										 								
						 							end		
						 							
						 						
												
												--if exists (select 1 from dbo.T0120_LEAVE_APPROVAL LA inner join dbo.T0130_LEAVE_APPROVAL_DETAIL LAD on LA.Leave_Approval_ID = LAD.Leave_Approval_ID inner join dbo.T0040_LEAVE_MASTER LM on lm.Leave_ID = LAD.Leave_ID where la.Emp_ID = @Emp_Id and ((@For_date >= lad.From_Date and @For_date <= lad.To_Date) ) and Approval_Status = 'A') and exists (select 1 from dbo.T0140_LEAVE_TRANSACTION LT where  lT.Emp_ID = @Emp_Id and Lt.For_Date = @For_date and lt.Leave_Used <> 0) 
												--	begin	
												--		--if @chk_leave_setting_for_leave_as_holiday = 1
												--		--	begin
												--				Set @Is_Cancel =1 
												--		--	end
												--		--else	
												--		--	begin
												--		--		set @Is_Cancel = 0
												--		--	end
												--	end												
												else if @cnt_leave_pre_next_holiday >= 2 and @chk_leave_setting_for_leave_as_holiday = 1
										 			begin
										 				Set @Is_Cancel = 1 
													end
												else if @temp_cnt_leave_pre_next_holiday >= 2 and @chk_leave_setting_for_leave_as_holiday = 0
													begin
														set @Is_Cancel = 0
													end
												else if @genral_Cancel_Holiday = 1 and  @Is_Leave_Cal = 0 and @chk_leave_setting_for_leave_as_holiday = 1
													begin	
														Set @Is_Cancel = 1  
													end
												else if @genral_Cancel_Holiday = 1 and  @Is_Leave_Cal = 0 and @temp_cnt_leave_pre_next_holiday = 0 and @cnt_leave_pre_next_holiday = 0
													begin	
														Set @Is_Cancel = 1  
													end
												else
													begin
														Set @Is_Cancel = 0
													end
																										
											end
									end
																
									while @For_date <= @H_To_Date--Nikunj 10-Sep-2010
									Begin
										 							
									if Charindex(CONVERT(VARCHAR(11),@For_date,109),@StrWeekoff_Date,0)=0 or isnull(@StrWeekoff_Date,'') = ''  --Nikunj 10-Sep-2010 For Week Off And Holiday Crash
										Begin									
											IF @Is_Cancel =1 
												BEGIN
													set @Cancel_Holiday = @Cancel_Holiday + @H_Days
												END
											ELSE IF ISNULL(@LEFT_DATE,'') = '' And @For_date >  @Join_Date 
												BEGIN												
													if @varHoliday_Date = ''
														begin
															set @varHoliday_Date = cast(@For_date as varchar(11))
															set @HoliDay_Days = @HoliDay_Days + @H_Days
															
														end
													else
														Begin
															set @varHoliday_Date = @varHoliday_Date + ';' + cast(@For_date as varchar(11))
															set @HoliDay_Days = @HoliDay_Days + @H_Days
															
														End	
														
													if @Use_Table =1 
														begin
													
															insert into #Emp_Holiday (Emp_ID,For_Date,H_Day)
															select @Emp_ID,@For_date,@H_Days
															
														end	
												END
											Else if @Join_Date > @For_date 
												begin
													set @Cancel_Holiday = @Cancel_Holiday + @H_Days
												end
											--Else if @Is_Cancel_Holiday =0 and (@Left_Date >= @For_Date or isnull(@Left_Date,'') = '') -- Left date comment added by hasmukh 27 01 2012
											Else if (@Left_Date >= @For_Date or isnull(@Left_Date,'') = '') -- Left date comment added by hasmukh 27 01 2012
												begin
												
													if @varHoliday_Date = ''
														begin
														
															set @varHoliday_Date = cast(@For_date as varchar(11))
															set @HoliDay_Days = @HoliDay_Days + @H_Days
														end
													else
														begin
															set @varHoliday_Date = @varHoliday_Date + ';' + cast(@For_date as varchar(11))
															set @HoliDay_Days = @HoliDay_Days + @H_Days
														end	
													if @Use_Table =1 
														begin
														 
															insert into #Emp_Holiday (Emp_ID,For_Date,H_Day)
															select @Emp_ID,@For_date,@H_Days
															
														end	
												end		
											--else If @is_Cancel_Holiday = 1
											--	begin
											--		set @Cancel_Holiday = @Cancel_Holiday + @H_Days
											--	end 		
											
										End	
										
									Set @For_date = Dateadd(d,1,@For_date)			
									
									End
							--End
						Set @For_Date = dateadd(d,1,@For_Date)
						
						end 
				Fetch next from curHoliday into @H_From_Date,@H_To_Date,@Is_Half,@Is_P_Comp,@is_Fix
			end
	close curHoliday	
	deallocate curHoliday	
	set @StrHoliday_Date=@varHoliday_Date
	
	
	
	RETURN



