
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
					   
CREATE PROCEDURE [dbo].[SP_EMP_WEEKOFF_DATE_GET]
	 @Emp_Id 		numeric	
	,@Cmp_ID 		numeric
	,@From_Date 		Datetime
	,@To_Date 		Datetime
	,@Join_Date		Datetime = null
	,@Left_Date		Datetime = null
	,@Is_Cancel_Weekoff 	NUMERIC(1,0)
	,@strHoliday_Date 	varchar(Max)
	,@varWeekOff_Date 	varchar(max)= null output 
	,@numWeekOff 		numeric(5,1) output
	,@Cancel_WeekOff 	numeric(5,1) output 
	,@Use_Table		tinyint =0
	,@Is_FNF	tinyint =0
	,@Is_Leave_Cal tinyint = 0
	,@varCancelWeekOff_Date 	varchar(max)= '' output -- add by mitesh for roster on 13052013
	,@Allowed_Full_WeekOff_MidJoining tinyint = 0 --Hardik 16/10/2013
	,@Type numeric = 0 -- Prakash Patel 07012015
AS	

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


	Declare @dtAdjDate as datetime
	set @Cancel_WeekOff = 0
	
	Declare @TempFor_Date 	DateTime
	Declare @WeekOff 	Varchar(100)
	Declare @Effe_weekoff 	Varchar(100)
	Declare @Temp_weekoff 	Varchar(100)
	Declare @Effe_Date 	Datetime
	Declare @Weekoff_Day_Value varchar(100)
	Declare @Eff_Weekoff_Day_Value varchar(100)
	Declare @Weekoff_Value	numeric(3,1)
	Declare @Var_All_H_Date	varchar(max)
	Declare @Pre_Date_WeekOff datetime 
	Declare @Next_Date_WeekOff	Datetime 
	Declare @Alt_W_Name			Varchar(100)
	Declare @Alt_W_Full_Day_cont	varchar(50)
	Declare @Alt_W_Half_Day_cont	varchar(50)
	Declare @varCount				varchar(3)
	Declare @IS_P_Comp			tinyint
	DECLARE @Branch_Id  Numeric
	DECLARE @genral_Cancel_Weekoff tinyint
	declare @monthyear_frm_date varchar(20)
	declare @monthyear_join_date varchar(20) --Added by Sumit 04/06/2016

	DECLARE @CancelHolidayIfOneSideAbsent tinyint

	--DECLARE @Allowed_Full_WeekOff_MidJoining tinyint
	
	DECLARE @Has_Leave_Flag BIT
	DECLARE @Has_Leave_Pre_Next tinyint
	DECLARE @Pre_Next_Leave_Type Varchar(32)
	
	Set @Effe_weekoff = ''
	set @numWeekOff = 0								
	set @varWeekOff_Date = ''
	set @Weekoff_Day_Value =''
	set @Eff_Weekoff_Day_Value =''
	set @Weekoff_Value = 0
	set @genral_Cancel_Weekoff = 0
	set @Branch_Id = 0
	
	DECLARE @Reverse_Leave_Cancel_Sett NUMERIC	--Ankit 22032016
	SET @Reverse_Leave_Cancel_Sett = 1
	SELECT @Reverse_Leave_Cancel_Sett = Setting_Value FROM T0040_SETTING WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND Setting_Name = 'Reverse Current WO/HO Cancel Policy'
	
	
	exec SP_EMP_WEEKOFF_HOLIDAY_DATE_GET @Emp_Id,@Cmp_ID,@From_Date,@To_Date,NULL,NULL,0,'',@Var_All_H_Date output,0,0,0,0,0 
	
	PRINT @Var_All_H_Date

	Declare @T_Weekoff Table 
	(
		Weekoff_Data	varchar(100) 
	)
	 
	Declare @T_W_Count	 Table
	( 
		W_NAme		varchar(20),
		W_Count		int default 0
	)
	
	insert into @T_W_Count 	select 'Sunday' ,0
	insert into @T_W_Count 	select 'Monday' ,0
	insert into @T_W_Count 	select 'Tuesday' ,0
	insert into @T_W_Count 	select 'Wednesday' ,0
	insert into @T_W_Count 	select 'Thursday' ,0
	insert into @T_W_Count 	select 'Friday' ,0
	insert into @T_W_Count 	select 'Saturday' ,0
	
	
	if @Is_FNF = 0
		Begin
	
			If isnull(@join_Date,'') = '' or isnull(@Left_Date,'') = '' --Added by Nilesh Patel on 29032018 -- Left date get null -- Wrong weekoff calculation in Left Emp - Hari Auto 
				Begin
					exec dbo.SP_EMP_JOIN_LEFT_DATE_GET @Emp_ID ,@Cmp_ID ,@From_Date,@To_date,@Join_Date output,@Left_Date output
				End

			If isnull(@Left_Date,'') <> '' 
				begin
					If @Left_Date < @Join_Date  
						set @Left_Date = null	
				end
		End
	else
		Begin
			select @left_Date = Emp_Left_Date from dbo.T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @Emp_Id
			If isnull(@join_Date,'') = ''
				Begin
					Declare @Temp_Left_Date 	Datetime
					set @Temp_Left_Date = 	@Left_Date
					exec dbo.SP_EMP_JOIN_LEFT_DATE_GET @Emp_ID ,@Cmp_ID ,@From_Date,@To_date,@Join_Date output,@Left_Date output
					set @Left_Date=@Temp_Left_Date 
				End
	
		End	
		
	/*	
	select @Branch_Id = Branch_ID from dbo.T0095_Increment EI inner join
	 (
		select max(Increment_ID) as Increment_ID from dbo.T0095_Increment  
		where Increment_Effective_date <= @To_Date  and Cmp_ID = @Cmp_ID and Emp_ID = @Emp_Id
	 ) Qry on qry.Increment_ID = EI.increment_ID 
	 where  Emp_ID = @Emp_Id and Cmp_ID = @Cmp_ID 
	*/
	SELECT	@Branch_Id = I1.BRANCH_ID
	FROM	T0095_INCREMENT I1 WITH (NOLOCK)
			INNER JOIN (SELECT	MAX(I2.Increment_ID) AS Increment_ID
						FROM	T0095_INCREMENT I2 WITH (NOLOCK)
								INNER JOIN (SELECT	MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE
											FROM	T0095_INCREMENT I3 WITH (NOLOCK)
											WHERE	I3.Increment_Effective_Date <= @To_Date and Cmp_ID = @Cmp_ID and Emp_ID = @Emp_Id
											) I3 ON I2.Increment_Effective_Date=I3.INCREMENT_EFFECTIVE_DATE
						WHERE	I2.Cmp_ID = @Cmp_Id and Emp_ID = @Emp_Id
						) I2 ON I1.Increment_ID=I2.INCREMENT_ID	
	WHERE	I1.Cmp_ID=@Cmp_Id and Emp_ID = @Emp_Id	

	
	select @genral_Cancel_Weekoff = Is_Cancel_Weekoff,@CancelHolidayIfOneSideAbsent = ISNULL(Is_Cancel_Weekoff_IfOneSideAbsent,0) 
	 from dbo.T0040_GENERAL_SETTING GS WITH (NOLOCK) inner join
	 (
		select max(For_Date) as For_Date from dbo.T0040_GENERAL_SETTING  WITH (NOLOCK)
		where For_Date <= @to_Date  and Cmp_ID = @Cmp_ID and Branch_ID = @Branch_Id
	  ) Qry on Qry.For_Date = GS.For_Date where  Branch_ID = @Branch_Id and Cmp_ID = @Cmp_ID
	


	-- Added by rohit For Get all Week off without Cancel it. this is Added for get all Week off in this SP without Cancel It.(Sp_Inout_Record_Daily_Get)
	if isnull(@Is_Cancel_Weekoff,0) = 9 
	begin
		set @genral_Cancel_Weekoff = 0
	end
	
	
	Declare @Alt_Weekoff Table
	(Row_Id Numeric,
	 Alt_Date Datetime
	)				
				
	--Added by hardik 06/10/2012
	DECLARE  @WeekOfMonth varchar(5)
	Set @WeekOfMonth=0
	
	--if @Join_Date > @From_Date 
	--		set @From_Date = @Join_Date
				

				Declare curWeekOff cursor fast_forward for
								
				    select Weekoff_Day, 
				    --case when @Allowed_Full_WeekOff_MidJoining =1 then @From_Date  else WAD.For_Date  end as For_Date
				      case when @Allowed_Full_WeekOff_MidJoining =1 then  @From_Date--Case for Mid Join is 0 and Midleft is 1
						 when @Allowed_Full_WeekOff_MidJoining = 2 then  WAD.For_Date--WAD.For_Date --Case for Mid Join is 0 and Midleft is 1
						 when @Allowed_Full_WeekOff_MidJoining = 3 then @From_Date --Case for Mid Join is 1 and Midleft is 1
					else WAD.For_Date  end
				     as For_Date
				    ,Weekoff_Day_Value ,isnull(Alt_W_Name,'') ,isnull(Alt_W_Full_Day_cont,'') ,isnull(Alt_W_Half_Day_cont,'') 
					,isnull(IS_P_Comp,0)
					from dbo.T0100_WEEKOFF_ADJ WAD WITH (NOLOCK) 
					inner join (select max(for_Date) as for_date from dbo.T0100_WEEKOFF_ADJ WITH (NOLOCK) 
					where Emp_ID = @Emp_ID and cmp_ID = @cmp_ID and for_Date <= @To_Date ) Qry on Qry.for_date = WAD.For_Date
					where cmp_ID = @cmp_ID and Emp_id = @Emp_ID and Weekoff_Day <> 'N' and isnull(WAD.IsMakerChecker,0) <> 1 --condtion added by ronakk 20092022
				
				
			open curWeekOff
				fetch next from curWeekOff into @WeekOff ,@Effe_Date,@Weekoff_Day_Value,@Alt_W_Name,@Alt_W_Full_day_Cont,@Alt_W_Half_Day_Cont,@IS_P_Comp
				while @@fetch_status = 0
					begin
						
						

					    select @WeekOff =  dbo.F_Weekoff_Day(@WeekOff)
						set @TempFor_Date = @From_Date
						set @Temp_weekoff = @WeekOff						
						
						Delete from @T_Weekoff 
						insert into @T_Weekoff 
						Select data from dbo.Split(@Weekoff_Day_Value,'#')

						
						while @TempFor_Date <= @To_Date							
							begin
							
						--		if @Effe_Date >= @From_Date and @TempFor_Date <= @Effe_Date 
						--			begin
										
						--				select @Effe_weekoff = Weekoff_Day  ,@Eff_Weekoff_Day_Value = Weekoff_day_Value 
						--						,@Alt_W_Name = isnull(Alt_W_Name,'') ,@Alt_W_Full_Day_cont = isnull(Alt_W_Full_Day_cont,'') ,@Alt_W_Half_Day_cont = isnull(Alt_W_Half_Day_cont,'') 
						--						,@IS_P_Comp = isnull(IS_P_Comp,0)
						--				From dbo.T0100_WEEKOFF_ADJ where Emp_id = @Emp_ID and Weekoff_Day <> 'N' 
						--				and for_date = (select max(for_Date) as for_date 
						--				from dbo.T0100_WEEKOFF_ADJ where Emp_ID = @Emp_ID and for_Date <= @TempFor_Date )
										
						--				select @WeekOff = dbo.F_Weekoff_Day(@Effe_weekoff)
																				
						--				Delete from @T_Weekoff 
						--				insert into @T_Weekoff 
						--				Select data from dbo.Split(@Eff_Weekoff_Day_Value,'#')											

						--			end
						--		else
						--			begin	
						--				set @WeekOff = @Temp_weekoff	
						--			end							
								
								--- Added Condition by Hardik 25/12/2014 for TOTO, Some Mid Join Case wrong.. so change this condition
								if @Effe_Date >= @From_Date and @TempFor_Date <= @Effe_Date and @TempFor_Date <= @Join_Date --and @Join_Date <= @Effe_Date --Commented Condtion by Hardik 04/10/2019 for HMP has query for Allow mid joining case where 1st Sep 2019 Weekoff not count
									begin
								
										select @Effe_weekoff = Weekoff_Day  ,@Eff_Weekoff_Day_Value = Weekoff_day_Value 
												,@Alt_W_Name = isnull(Alt_W_Name,'') ,@Alt_W_Full_Day_cont = isnull(Alt_W_Full_Day_cont,'') ,@Alt_W_Half_Day_cont = isnull(Alt_W_Half_Day_cont,'') 
												,@IS_P_Comp = isnull(IS_P_Comp,0)
										From dbo.T0100_WEEKOFF_ADJ WAD WITH (NOLOCK) 
										inner join
										(
											select min(for_Date) as for_date 
											from dbo.T0100_WEEKOFF_ADJ WITH (NOLOCK) where Emp_ID = @Emp_ID  and Cmp_ID = @Cmp_ID and for_Date >= @TempFor_Date 
										) Qry on  Qry.for_date = WAD.for_Date
										 where Emp_id = @Emp_ID and Cmp_ID = @Cmp_ID and Weekoff_Day <> 'N'  and isnull(WAD.IsMakerChecker,0) <> 1 --condtion added by ronakk 20092022
										
																	
										select @WeekOff = dbo.F_Weekoff_Day(@Effe_weekoff)

																				
										Delete from @T_Weekoff 
										insert into @T_Weekoff 
										Select data from dbo.Split(@Eff_Weekoff_Day_Value,'#')											

									end
								else if @Effe_Date >= @From_Date and @TempFor_Date <= @Effe_Date 
									Begin
									
										select @Effe_weekoff = Weekoff_Day  ,@Eff_Weekoff_Day_Value = Weekoff_day_Value 
												,@Alt_W_Name = isnull(Alt_W_Name,'') ,@Alt_W_Full_Day_cont = isnull(Alt_W_Full_Day_cont,'') ,@Alt_W_Half_Day_cont = isnull(Alt_W_Half_Day_cont,'') 
												,@IS_P_Comp = isnull(IS_P_Comp,0)
										From dbo.T0100_WEEKOFF_ADJ WAD WITH (NOLOCK) Inner join
										(
											select max(for_Date) as for_date 
											from dbo.T0100_WEEKOFF_ADJ WITH (NOLOCK) where Emp_ID = @Emp_ID and for_Date <= @TempFor_Date 
										 ) Qry on Qry.for_date = WAD.For_Date
										where Emp_id = @Emp_ID and Weekoff_Day <> 'N' and isnull(WAD.IsMakerChecker,0) <> 1 --condtion added by ronakk 20092022
										
																	
										select @WeekOff = dbo.F_Weekoff_Day(@Effe_weekoff)

																				
										Delete from @T_Weekoff 
										insert into @T_Weekoff 
										Select data from dbo.Split(@Eff_Weekoff_Day_Value,'#')											
									End
								else
									begin	
										set @WeekOff = @Temp_weekoff	
									end		
									
								--set @Var_All_H_Date =  isnull(@strHoliday_Date,'') + '' + @WeekOff								
								
																			
								exec dbo.SP_RETURN_PRE_NEXT_DATE_OF_WEEKOFF @TempFor_Date,@Var_All_H_Date,@Pre_Date_WeekOff output,@Next_Date_WeekOff output								
								
								
									
								select @Weekoff_Value = isnull(replace(Weekoff_Data,datename(dw,@TempFor_Date),''),1) from @T_Weekoff where charindex(datename(dw,@TempFor_Date) ,Weekoff_Data,0) > 0												
								
								if isnull(@Weekoff_Value,0) =0
									set @Weekoff_Value = 1
								
									
								if charindex(datename(dw,@TempFor_Date) ,@WeekOff,0) >0 
									begin
										update @T_W_Count set W_Count =W_Count  + 1 + @WeekOfMonth Where W_Name = datename(dw,@TempFor_Date)
									end
									
								
								if @Alt_W_Name <> '' and charindex(@Alt_W_Name,datename(dw,@TempFor_Date),0) >0 
									begin
										Select  @varCount = W_Count  From @T_W_Count Where W_Name = @Alt_W_Name
										
										set @varCount = '#' + @varCount   + '#'
										
													

										--added by Hardik 21/09/2012
										--SET @WeekOfMonth = DATEDIFF(week, DATEADD(MONTH, DATEDIFF(MONTH, 0, @TempFor_Date), 0), @TempFor_Date) +1
										select @WeekOfMonth = dbo.fn_getWeekNumberOfMonth (@TempFor_Date)
							


										--if @Alt_W_Full_day_Cont <> '' and charindex(@varCount,@Alt_W_Full_day_Cont,0) >0
										
										---Commented by Hardik on 03/04/2015 as Alternate 2nd and 4th Sunday coming wrong for Apr-2015
									
										if @Alt_W_Full_day_Cont <> '' and charindex(@WeekOfMonth,@Alt_W_Full_day_Cont,0) >0
											begin 
												set @Weekoff_Value =1 												
											end																				
											
										--else if @Alt_W_Half_day_Cont <> '' and charindex(@varCount,@Alt_W_Half_day_Cont,0) >0
										else if @Alt_W_Half_day_Cont <> '' and charindex(@WeekOfMonth,@Alt_W_Half_day_Cont,0) >0																						
											begin										
												set @Weekoff_Value = 0.5 												
											end
										ELSE IF EXISTS(SELECT 1 FROM T0100_WEEKOFF_ROSTER WITH (NOLOCK) WHERE EMP_ID=@EMP_ID AND FOR_DATE=@TempFor_Date)
											BEGIN 
												set @Weekoff_Value = 1
											END 
										ELSE
											BEGIN											
												SET @Weekoff_Value = 0												 
											END										
									end						
									
								
								declare @cnt_leave_pre_next_weekoff numeric(5,1)
								declare @temp_cnt_leave_pre_next_weekoff numeric(5,1)
								declare @chk_leave_setting_for_leave_as_weekoff as tinyint
								DECLARE @PreNextLeaveType Varchar(32)
								
								set @cnt_leave_pre_next_weekoff = 0
								set @temp_cnt_leave_pre_next_weekoff = 0
								set @chk_leave_setting_for_leave_as_weekoff = 0
								
								
								set @monthyear_frm_date='';
								set @monthyear_join_date='';
								
								
								set @monthyear_frm_date =cast(cast(MONTH(@From_Date) as varchar(20)) + '-' + cast(YEAR(@From_Date) as varchar(20)) as varchar(20))
								set @monthyear_join_date =cast(cast(MONTH(@Join_Date) as varchar(20)) + '-' + cast(YEAR(@Join_Date) as varchar(20)) as varchar(20))
								
								SET @Has_Leave_Pre_Next = 0
								
								IF @Genral_Cancel_Weekoff = 1 AND @TempFor_Date >= '2018-01-01'
									BEGIN 	
										SET  @Has_Leave_Flag = 0
											SELECT	@Has_Leave_Pre_Next = 1,
													@temp_cnt_leave_pre_next_weekoff = L.Weekoff_as_leave,
													@Has_Leave_Flag = 1,
													@Pre_Next_Leave_Type = L.Leave_Type
											FROM	T0140_LEAVE_TRANSACTION T WITH (NOLOCK)
													INNER JOIN T0040_LEAVE_MASTER L WITH (NOLOCK) ON T.LEAVE_ID=L.LEAVE_ID
													INNER JOIN (SELECT	LA.Emp_ID,LAD.Leave_Assign_As, LAD.From_Date,LAD.To_Date
																FROM	T0120_LEAVE_APPROVAL LA WITH (NOLOCK)
																		INNER JOIN T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) ON LA.Leave_Approval_ID=LAD.Leave_Approval_ID
																WHERE	LA.Emp_ID=@EMP_ID) A ON T.EMP_ID=A.EMP_ID AND T.FOR_DATE BETWEEN A.FROM_DATE AND A.TO_DATE
											WHERE	Leave_Used >= 0.5 AND FOR_DATE = @Pre_Date_WeekOff  --AND L.Leave_Type <>'Company Purpose'
													AND A.Leave_Assign_As IN ('Second Half', 'Full Day') AND T.Emp_ID=@EMP_ID
											
											IF @Has_Leave_Flag = 0
												AND NOT EXISTS(SELECT 1 FROM T0150_EMP_INOUT_RECORD WITH (NOLOCK) WHERE Emp_ID=@EMP_ID AND For_Date=@Pre_Date_WeekOff)
												BEGIN
													SET @Has_Leave_Pre_Next = 1
													SET @temp_cnt_leave_pre_next_weekoff = 1
												END
											ELSE IF @Pre_Next_Leave_Type = 'Company Purpose' Or @chk_leave_setting_for_leave_as_weekoff = 0
												BEGIN
													SET @Has_Leave_Flag = 0
													SET @Has_Leave_Pre_Next = 0
													SET @chk_leave_setting_for_leave_as_weekoff = 0
												END
												
											SET  @Has_Leave_Flag = 0
											SELECT	@Has_Leave_Pre_Next = @Has_Leave_Pre_Next + 1,
													@temp_cnt_leave_pre_next_weekoff = @temp_cnt_leave_pre_next_weekoff + l.Weekoff_as_leave,
													@Has_Leave_Flag = 1,
													@Pre_Next_Leave_Type = L.Leave_Type
											FROM	T0140_LEAVE_TRANSACTION T WITH (NOLOCK)
													INNER JOIN T0040_LEAVE_MASTER L WITH (NOLOCK) ON T.LEAVE_ID=L.LEAVE_ID
													INNER JOIN (SELECT	LA.Emp_ID,LAD.Leave_Assign_As, LAD.From_Date,LAD.To_Date
																FROM	T0120_LEAVE_APPROVAL LA WITH (NOLOCK)
																		INNER JOIN T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) ON LA.Leave_Approval_ID=LAD.Leave_Approval_ID
																WHERE	LA.Emp_ID=@EMP_ID) A ON T.EMP_ID=A.EMP_ID AND T.FOR_DATE BETWEEN A.FROM_DATE AND A.TO_DATE
											WHERE	Leave_Used >= 0.5 AND FOR_DATE = @Next_Date_WeekOff --AND L.Leave_Type <>'Company Purpose' 
												AND A.Leave_Assign_As IN ('First Half', 'Full Day') AND T.Emp_ID=@EMP_ID
												
											IF @Has_Leave_Flag = 0
												AND NOT EXISTS(SELECT 1 FROM T0150_EMP_INOUT_RECORD WITH (NOLOCK) WHERE Emp_ID=@EMP_ID AND For_Date=@Next_Date_WeekOff)
												BEGIN
													SET @Has_Leave_Pre_Next = @Has_Leave_Pre_Next + 1
													SET @temp_cnt_leave_pre_next_weekoff = @temp_cnt_leave_pre_next_weekoff + 1
												END
											ELSE IF @Pre_Next_Leave_Type = 'Company Purpose' Or @chk_leave_setting_for_leave_as_weekoff = 0
												BEGIN
													SET @Has_Leave_Flag = 0
													SET @Has_Leave_Pre_Next = 0
													SET @chk_leave_setting_for_leave_as_weekoff = 0
												END
												
											
											IF @Has_Leave_Pre_Next = 2
												AND (@temp_cnt_leave_pre_next_weekoff = 2 OR (@temp_cnt_leave_pre_next_weekoff = 1 AND @Reverse_Leave_Cancel_Sett = 1))
												SET @Has_Leave_Pre_Next = 2
											ELSE
												SET @Has_Leave_Pre_Next = 0
									
									END
								
								IF (charindex(datename(dw,@TempFor_date) ,@WeekOff,0) >0  or (@Alt_W_Name <> '' and charindex(@Alt_W_Name,datename(dw,@TempFor_Date),0) >0 ))
								And 
								--case when @Allowed_Full_WeekOff_MidJoining =1 then @From_Date  else @Join_Date  end <=@TempFor_date
								(
									(@Allowed_Full_WeekOff_MidJoining = 0 and (@monthyear_frm_date=@monthyear_join_date) and @Left_Date is not null and @TempFor_Date between @Join_Date and @left_date)	--Same month join and left
									or 
									(@Allowed_Full_WeekOff_MidJoining = 0 and (@monthyear_frm_date=@monthyear_join_date) and @Left_Date is null and @TempFor_Date between @Join_Date and @To_Date)	--same month join only
									or
									(@Allowed_Full_WeekOff_MidJoining = 0 and (@monthyear_frm_date <> @monthyear_join_date) and @TempFor_Date between @From_Date and @To_Date AND @TempFor_Date >= @Join_Date)
									OR 
									(@Allowed_Full_WeekOff_MidJoining = 1 and @TempFor_Date between @From_Date and isnull(@Left_Date,@To_Date))
									or 
									(@Allowed_Full_WeekOff_MidJoining = 2 and (@monthyear_frm_date=@monthyear_join_date) and @TempFor_Date between @Join_Date and @To_Date)
									or 
									(@Allowed_Full_WeekOff_MidJoining = 2 and (@monthyear_frm_date<>@monthyear_join_date) and @TempFor_Date between @From_Date and @To_Date)
									or 
									(@Allowed_Full_WeekOff_MidJoining = 3 and @TempFor_Date between @From_Date and @To_Date)
								)
									Begin	
										
									if Charindex(CONVERT(VARCHAR(11),@TempFor_date,109),@strHoliday_Date,0)=0--Nikunj 08-August-2010 For Week Off And Holiday Crash											
									Begin		
										 
										 
										 --If @Is_Cancel_Weekoff =1 and not exists(select Emp_ID from T0150_EMP_INOUT_RECORD WHERE EMP_ID =@EMP_ID AND 
										 If not exists(select Emp_ID from T0150_EMP_INOUT_RECORD WITH (NOLOCK) WHERE EMP_ID =@EMP_ID AND 
															cast(for_date as varchar(11)) in (@Pre_Date_WeekOff,@Next_Date_WeekOff) 
															--and 1 = (case when reason <> '' and not Apr_Date is null then isnull(Chk_by_Superior,0) else 1 end)) 
															AND 1 = (CASE WHEN In_Time IS NOT NULL OR Out_Time IS NOT NULL THEN 1 ELSE ISNULL(Chk_by_Superior,0) END))
															and (@TempFor_Date <= @Left_Date or @Left_Date is null) 
															AND (@TempFor_Date >= @Join_Date)
															BEGIN
																
															
																SELECT	@cnt_leave_pre_next_weekoff = Isnull(sum(IsNull(T.CompOff_Used,T.Leave_Used)),0) ,-- COUNT(lad.Leave_Approval_ID),
																		@chk_leave_setting_for_leave_as_weekoff = Case When @Reverse_Leave_Cancel_Sett = 1 Then  Max(LM.Weekoff_as_leave) Else  Min(LM.Weekoff_as_leave) End,
																		@PreNextLeaveType = Max(LM.Leave_Type)
																FROM	T0120_LEAVE_APPROVAL LA WITH (NOLOCK)  INNER JOIN T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) on LA.Leave_Approval_ID = LAD.Leave_Approval_ID 
																		INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) on lm.Leave_ID = LAD.Leave_ID 
																		LEFT JOIN T0150_LEAVE_CANCELLATION LC WITH (NOLOCK) ON LA.Leave_Approval_ID = LC.Leave_Approval_id and LC.Is_Approve = 1 
																		And  LC.For_date Between @Pre_Date_WeekOff and @Next_Date_WeekOff
																		INNER JOIN T0140_LEAVE_TRANSACTION T WITH (NOLOCK) ON LA.Emp_ID=T.Emp_ID AND LM.Leave_ID=T.Leave_ID AND (T.For_Date =@Pre_Date_WeekOff or t.For_Date=@Next_Date_WeekOff)
																WHERE	la.Emp_ID = @Emp_Id AND (
																									(@Pre_Date_WeekOff >= lad.From_Date and @Pre_Date_WeekOff <= lad.To_Date) or 
																									( @Next_Date_WeekOff >= lad.From_Date  and   @Next_Date_WeekOff <= lad.To_Date)
																								) AND Approval_Status = 'A' and LC.Leave_Approval_id is null

																if not @cnt_leave_pre_next_weekoff >= 2 
																	begin
																		
																		--set @temp_cnt_leave_pre_next_weekoff = 0
																		
																		select	@temp_cnt_leave_pre_next_weekoff = COUNT(lad.Leave_Approval_ID)  ,
																				@chk_leave_setting_for_leave_as_weekoff = LM.Weekoff_as_leave  
																		from	T0120_LEAVE_APPROVAL LA WITH (NOLOCK)
																				inner join T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) on LA.Leave_Approval_ID = LAD.Leave_Approval_ID 
																				inner join T0040_LEAVE_MASTER LM WITH (NOLOCK) on lm.Leave_ID = LAD.Leave_ID 
																		where	la.Emp_ID = @Emp_Id and (lad.From_Date <= @Pre_Date_WeekOff and lad.To_Date >= @Next_Date_WeekOff) 
																				and Approval_Status = 'A' 
																		group by LM.Weekoff_as_leave 
																	
																	
																		if @temp_cnt_leave_pre_next_weekoff >= 1
																			begin	
																			
																				set @cnt_leave_pre_next_weekoff = 2
																			end				
																		else
																			begin																																							
																				select @temp_cnt_leave_pre_next_weekoff = COUNT(lad.Leave_Approval_ID)  from T0120_LEAVE_APPROVAL LA WITH (NOLOCK) inner join T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) on LA.Leave_Approval_ID = LAD.Leave_Approval_ID inner join T0040_LEAVE_MASTER LM WITH (NOLOCK) on lm.Leave_ID = LAD.Leave_ID where la.Emp_ID = @Emp_Id and ((@Pre_Date_WeekOff >= lad.From_Date and @Pre_Date_WeekOff <= lad.To_Date) or ( @Next_Date_WeekOff >= lad.From_Date  and   @Next_Date_WeekOff <= lad.To_Date)) and Approval_Status = 'A' 
																				
																				
																				if @temp_cnt_leave_pre_next_weekoff >=2 
																					begin	
																						--select @chk_leave_setting_for_leave_as_weekoff = LM.Weekoff_as_leave  from T0120_LEAVE_APPROVAL LA inner join T0130_LEAVE_APPROVAL_DETAIL LAD on LA.Leave_Approval_ID = LAD.Leave_Approval_ID inner join T0040_LEAVE_MASTER LM on lm.Leave_ID = LAD.Leave_ID where la.Emp_ID = @Emp_Id and ((@Pre_Date_WeekOff >= lad.From_Date and @Pre_Date_WeekOff <= lad.To_Date) or ( @Next_Date_WeekOff >= lad.From_Date  and   @Next_Date_WeekOff <= lad.To_Date)) and Approval_Status = 'A'  order by LM.Weekoff_as_leave  desc	
																						
																						----Ankit 22032016
																						/* If 'CL - WO - PL' Then WO Cancel */
																						IF	ISNULL(@Reverse_Leave_Cancel_Sett,0) = 0
																							BEGIN
																								SELECT @chk_leave_setting_for_leave_as_weekoff = LM.Weekoff_as_leave  FROM T0120_LEAVE_APPROVAL LA WITH (NOLOCK) INNER JOIN T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) ON LA.Leave_Approval_ID = LAD.Leave_Approval_ID INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON lm.Leave_ID = LAD.Leave_ID WHERE la.Emp_ID = @Emp_Id AND ((@Pre_Date_WeekOff >= lad.From_Date AND @Pre_Date_WeekOff <= lad.To_Date) OR ( @Next_Date_WeekOff >= lad.From_Date  AND   @Next_Date_WeekOff <= lad.To_Date)) AND Approval_Status = 'A'  ORDER BY LM.Weekoff_as_leave  DESC	
																							END
																						ELSE
																							BEGIN
																								SELECT TOP 1 @chk_leave_setting_for_leave_as_weekoff = LM.Weekoff_as_leave  FROM T0120_LEAVE_APPROVAL LA WITH (NOLOCK) INNER JOIN T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) ON LA.Leave_Approval_ID = LAD.Leave_Approval_ID INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON lm.Leave_ID = LAD.Leave_ID WHERE la.Emp_ID = @Emp_Id AND ((@Pre_Date_WeekOff >= lad.From_Date AND @Pre_Date_WeekOff <= lad.To_Date) OR ( @Next_Date_WeekOff >= lad.From_Date  AND   @Next_Date_WeekOff <= lad.To_Date)) AND Approval_Status = 'A'  ORDER BY LM.Weekoff_as_leave  DESC	
																							END	
																					end
																				else
																					begin	
																						select @chk_leave_setting_for_leave_as_weekoff = LM.Weekoff_as_leave  from T0120_LEAVE_APPROVAL LA WITH (NOLOCK) inner join T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) on LA.Leave_Approval_ID = LAD.Leave_Approval_ID inner join T0040_LEAVE_MASTER LM WITH (NOLOCK) on lm.Leave_ID = LAD.Leave_ID where la.Emp_ID = @Emp_Id and ((@Pre_Date_WeekOff >= lad.From_Date and @Pre_Date_WeekOff <= lad.To_Date) or ( @Next_Date_WeekOff >= lad.From_Date  and   @Next_Date_WeekOff <= lad.To_Date)) and Approval_Status = 'A'  order by LM.Weekoff_as_leave  desc		
																						
																						----Ankit 22032016
																						/* If 'Leave - WO - Absent' Then WO Cancel */
																						IF ISNULL(@Reverse_Leave_Cancel_Sett,0) = 1 AND @Genral_Cancel_Weekoff = 1 AND
																								EXISTS( SELECT	1
																										FROM	T0120_LEAVE_APPROVAL LA WITH (NOLOCK) INNER JOIN T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) ON LA.Leave_Approval_ID = LAD.Leave_Approval_ID 
																												INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON lm.Leave_ID = LAD.Leave_ID 
																												LEFT JOIN T0150_LEAVE_CANCELLATION LC WITH (NOLOCK) ON LA.Leave_Approval_ID = LC.Leave_Approval_id AND LC.Is_Approve = 1 
																										WHERE la.Emp_ID = @Emp_Id AND 
																											(
																												( @Pre_Date_WeekOff >= lad.From_Date AND @Pre_Date_WeekOff <= lad.To_Date ) OR 
																												( @Next_Date_WeekOff >= lad.From_Date  AND   @Next_Date_WeekOff <= lad.To_Date)
																											) AND Approval_Status = 'A' AND LC.Leave_Approval_id IS NULL AND LM.Weekoff_as_leave = 0
																											and LM.Leave_Type <>'Company Purpose' --Added by Hardik 07/11/2016 as OD-WO-Absent case wrong in Aculife
																										) 
																							BEGIN
																								SET @chk_leave_setting_for_leave_as_weekoff = 1
																							END
																					end
																																							
																			end						 								
																	end			
																ELSE IF @cnt_leave_pre_next_weekoff = 2
																	BEGIN
																		/*THIS CONDITION ADDED BY NIMESH ON 31-AUG-2016*/
																		/*I.E. IF USER TAKES OD ON SAT AND MON THEN SUN(WEEKOFF) SHOULD NOT BE CANCELED*/
																		IF EXISTS(SELECT 1 FROM T0120_LEAVE_APPROVAL LA WITH (NOLOCK) INNER JOIN T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) on LA.Leave_Approval_ID = LAD.Leave_Approval_ID 
																					INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LAD.LEAVE_ID=LM.LEAVE_ID
																					LEFT OUTER JOIN T0150_LEAVE_CANCELLATION LC WITH (NOLOCK) ON LA.Leave_Approval_ID = LC.Leave_Approval_id and LC.Is_Approve = 1 
																						And  LC.For_date Between @Pre_Date_WeekOff and @Next_Date_WeekOff
																						WHERE	LA.Emp_ID = @Emp_Id AND (
																										(@Pre_Date_WeekOff >= LAD.From_Date and @Pre_Date_WeekOff <= LAD.To_Date) or 
																										( @Next_Date_WeekOff >= LAD.From_Date  and   @Next_Date_WeekOff <= LAD.To_Date)
																									) AND Approval_Status = 'A' and LC.Leave_Approval_id is null AND LEAVE_TYPE='Company Purpose')
																		BEGIN
														
																			SELECT @cnt_leave_pre_next_weekoff = COUNT(1) FROM T0120_LEAVE_APPROVAL LA WITH (NOLOCK)
																					INNER JOIN T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) on LA.Leave_Approval_ID = LAD.Leave_Approval_ID 
																					INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LAD.LEAVE_ID=LM.LEAVE_ID
																					LEFT OUTER JOIN T0150_LEAVE_CANCELLATION LC WITH (NOLOCK) ON LA.Leave_Approval_ID = LC.Leave_Approval_id and LC.Is_Approve = 1 
																						And  LC.For_date Between @Pre_Date_WeekOff and @Next_Date_WeekOff
																						WHERE	LA.Emp_ID = @Emp_Id AND (
																										(@Pre_Date_WeekOff >= LAD.From_Date and @Pre_Date_WeekOff <= LAD.To_Date) or 
																										( @Next_Date_WeekOff >= LAD.From_Date  and   @Next_Date_WeekOff <= LAD.To_Date)
																									) AND Approval_Status = 'A' and LC.Leave_Approval_id is null AND LEAVE_TYPE='Company Purpose'

																			IF @cnt_leave_pre_next_weekoff <> 0
																				set @chk_leave_setting_for_leave_as_weekoff = 0
														
														
																			IF (NOT EXISTS(SELECT 1 FROM T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)
																					INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LT.LEAVE_ID=LM.LEAVE_ID																
																						WHERE	LT.Emp_ID = @Emp_Id AND LT.FOR_DATE=@TempFor_Date AND LEAVE_TYPE='Company Purpose' AND LEAVE_USED > 0))															
																				AND @cnt_leave_pre_next_weekoff = 2

																				SET @cnt_leave_pre_next_weekoff = 1

																		END													
																	ELSE 
																			BEGIN
																				SELECT	@chk_leave_setting_for_leave_as_weekoff = LM.Weekoff_as_leave
																				FROM	T0140_LEAVE_TRANSACTION t WITH (NOLOCK)
																						INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LM.Leave_ID = T.Leave_ID 
																				WHERE	t.Emp_ID = @Emp_Id AND T.For_Date = @Pre_Date_WeekOff 
																				
																				
																				IF @chk_leave_setting_for_leave_as_weekoff = 0
																					SET @cnt_leave_pre_next_weekoff = 1
																			END		
																	END	
																
																
																IF @PreNextLeaveType = 'Company Purpose' AND @Reverse_Leave_Cancel_Sett = 0
																	BEGIN
																		IF NOT EXISTS(SELECT 1 FROM T0140_LEAVE_TRANSACTION WITH (NOLOCK) WHERE EMP_ID=@EMP_ID AND FOR_DATE=@TempFor_Date AND LEAVE_USED > 0)
																			BEGIN
																				SET @chk_leave_setting_for_leave_as_weekoff = 0;																																								
																			END
																	END
																if exists (select 1 from T0120_LEAVE_APPROVAL LA WITH (NOLOCK) inner join T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) on LA.Leave_Approval_ID = LAD.Leave_Approval_ID inner join T0040_LEAVE_MASTER LM WITH (NOLOCK) on lm.Leave_ID = LAD.Leave_ID where la.Emp_ID = @Emp_Id and ( @TempFor_Date >= lad.From_Date  and   @TempFor_Date <= lad.To_Date) and Approval_Status = 'A')
																  and exists (select 1 from T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)
																  where  lT.Emp_ID = @Emp_Id and Lt.For_Date = @TempFor_Date
																    -- and (lt.Leave_Used <> 0 OR lt.CompOff_Used <> 0)) and isnull(@Is_Cancel_Weekoff,0) <> 9 
																    and (CASE	WHEN CompOff_Used > 0 AND CompOff_Used = Leave_Encash_Days THEN 0
																										WHEN Leave_Used > 0 AND Leave_Used = Leave_Encash_Days THEN 0
																										WHEN (lt.Leave_Used <> 0 OR lt.CompOff_Used <> 0) THEN 1
																										ELSE 0
																								 END) =1)
																							and isnull(@Is_Cancel_Weekoff,0) <> 9 
																	begin
																			PRINT 'REASON 1 ' + CONVERT(CHAR(10), @TempFor_Date , 103)
																			--if @chk_leave_setting_for_leave_as_weekoff = 1
																			--	begin
																					Set	@Cancel_WeekOff = @Cancel_WeekOff + @Weekoff_Value	
																					set @varCancelWeekOff_Date = @varCancelWeekOff_Date + ';' +  cast(@TempFor_Date as varchar(11))		
																			--	end
																			--else
																			--	begin
																			--		set @numWeekOff =  @numWeekOff + @Weekoff_Value
																			--		set @varWeekOff_Date = @varWeekOff_Date + ';' +  cast(@TempFor_Date as varchar(11))		
																					
																			--		if @Use_Table =1 
																			--			begin   
																			--				insert into #Emp_Weekoff (Emp_ID,Cmp_ID,For_Date,W_Day)
																			--				select @Emp_ID ,@Cmp_Id,@TempFor_Date,@Weekoff_Value																
																			--			end	
																			--	end
																	end
																else if @cnt_leave_pre_next_weekoff >= 2 and @chk_leave_setting_for_leave_as_weekoff = 1 and isnull(@Is_Cancel_Weekoff,0) <> 9 
																	begin
																		PRINT 'REASON 2 ' + CONVERT(CHAR(10), @TempFor_Date , 103)

																		Set	@Cancel_WeekOff = @Cancel_WeekOff + @Weekoff_Value	
																		set @varCancelWeekOff_Date = @varCancelWeekOff_Date + ';' +  cast(@TempFor_Date as varchar(11))	
																	end
																else if @temp_cnt_leave_pre_next_weekoff >= 2 and @chk_leave_setting_for_leave_as_weekoff = 0 and @Weekoff_Value > 0
																	begin
																		
																		set @numWeekOff =  @numWeekOff + @Weekoff_Value
																		set @varWeekOff_Date = @varWeekOff_Date + ';' +  cast(@TempFor_Date as varchar(11))		
																			
																		if @Use_Table =1 
																			begin   
																				insert into #Emp_Weekoff (Emp_ID,Cmp_ID,For_Date,W_Day)
																				select @Emp_ID ,@Cmp_Id,@TempFor_Date,@Weekoff_Value																
																			end	
																	end								
																--else if @genral_Cancel_Weekoff = 1 and @chk_leave_setting_for_leave_as_weekoff = 1
																--	begin	
																--		Set	@Cancel_WeekOff = @Cancel_WeekOff + @Weekoff_Value	
																--	end																										
																else if @genral_Cancel_Weekoff = 1 and @Is_Leave_Cal = 0 and @chk_leave_setting_for_leave_as_weekoff = 1 and isnull(@Is_Cancel_Weekoff,0) <> 9  --and charindex(datename(dw,@Pre_Date_WeekOff) ,@WeekOff,0) = 0 and charindex(datename(dw,@Next_Date_WeekOff) ,@WeekOff,0) = 0 
																	begin		
																		PRINT 'REASON 3 ' + CONVERT(CHAR(10), @TempFor_Date , 103)																		
																		Set	@Cancel_WeekOff = @Cancel_WeekOff + @Weekoff_Value	
																		set @varCancelWeekOff_Date = @varCancelWeekOff_Date + ';' +  cast(@TempFor_Date as varchar(11))	
																	end
																else if @genral_Cancel_Weekoff = 1 and @Is_Leave_Cal = 0 and @temp_cnt_leave_pre_next_weekoff = 2 --0 -- changed by hardik 04/06/2020 for WCL, both side absent not working due to 0..
																			and @cnt_leave_pre_next_weekoff = 2 --0  -- changed by hardik 04/06/2020 for WCL, both side absent not working due to 0..
																			and isnull(@Is_Cancel_Weekoff,0) <> 9 
																	begin		
																		PRINT 'REASON 4 ' + CONVERT(CHAR(10), @TempFor_Date , 103)
																		Set	@Cancel_WeekOff = @Cancel_WeekOff + @Weekoff_Value	
																		set @varCancelWeekOff_Date = @varCancelWeekOff_Date + ';' +  cast(@TempFor_Date as varchar(11))	
																		 	
																	end
																else if @Weekoff_Value > 0	AND @Genral_Cancel_Weekoff = 1 AND ISNULL(@Reverse_Leave_Cancel_Sett,0) = 1	/* Ankit 16032016 */
																	BEGIN
																	
																		DECLARE @LeaveID			NUMERIC
																		DECLARE @CountLeaveAprID	NUMERIC
																		SET @LeaveID = 0
																		SET @CountLeaveAprID = 0
														
																		/* CL - WO - CL : WO Not Cancel AND CL - WO - LWP : WO Cancel  */
																		SELECT	@LeaveID = LAD.Leave_ID 
																				,@CountLeaveAprID = COUNT(lad.Leave_Approval_ID)
																		FROM	T0120_LEAVE_APPROVAL LA WITH (NOLOCK) INNER JOIN T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) on LA.Leave_Approval_ID = LAD.Leave_Approval_ID 
																				INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) on lm.Leave_ID = LAD.Leave_ID 
																				LEFT JOIN T0150_LEAVE_CANCELLATION LC WITH (NOLOCK) ON LA.Leave_Approval_ID = LC.Leave_Approval_id and LC.Is_Approve = 1 
																		WHERE	la.Emp_ID = @Emp_Id AND 
																				(  ( @Pre_Date_WeekOff >= lad.From_Date and @Pre_Date_WeekOff <= lad.To_Date) or 
																				   ( @Next_Date_WeekOff >= lad.From_Date  and   @Next_Date_WeekOff <= lad.To_Date)
																				) AND Approval_Status = 'A' and LC.Leave_Approval_id IS NULL AND LM.Weekoff_as_leave = 0
																				AND LM.Leave_Paid_Unpaid = 'P'
																				and (LM.Leave_Type <> 'Company Purpose' AND LM.Default_Short_Name <> 'COMP')
																		GROUP BY LAD.Leave_ID 
																		
																		
																		
																		IF @CountLeaveAprID >= 2
																			BEGIN
																				set @numWeekOff =  @numWeekOff + @Weekoff_Value
																				set @varWeekOff_Date = @varWeekOff_Date + ';' +  cast(@TempFor_Date as varchar(11))		
																			 
																			 	
																				if @Use_Table =1 
																					begin   
																						insert into #Emp_Weekoff (Emp_ID,Cmp_ID,For_Date,W_Day)
																						select @Emp_ID ,@Cmp_Id,@TempFor_Date,@Weekoff_Value																
																					end	
																			END
																		ELSE IF EXISTS ( SELECT	1 FROM	T0120_LEAVE_APPROVAL LA WITH (NOLOCK) inner join T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) on LA.Leave_Approval_ID = LAD.Leave_Approval_ID 
																								inner join T0040_LEAVE_MASTER LM WITH (NOLOCK) on lm.Leave_ID = LAD.Leave_ID 
																								LEFT JOIN T0150_LEAVE_CANCELLATION LC WITH (NOLOCK) ON LA.Leave_Approval_ID = LC.Leave_Approval_id and LC.Is_Approve = 1 
																							WHERE la.Emp_ID = @Emp_Id and 
																							( ( @Pre_Date_WeekOff >= lad.From_Date and @Pre_Date_WeekOff <= lad.To_Date ) or 
																								( @Next_Date_WeekOff >= lad.From_Date  and   @Next_Date_WeekOff <= lad.To_Date )
																							) and Approval_Status = 'A' and LC.Leave_Approval_id is null AND LM.Weekoff_as_leave = 0
																							and (LM.Leave_Type = 'Company Purpose' or LM.Default_Short_Name = 'COMP')
																						) 
																			BEGIN	/* CL - WO - COMP/Cmp Purpose Not Cancel */
																				set @numWeekOff =  @numWeekOff + @Weekoff_Value
																				set @varWeekOff_Date = @varWeekOff_Date + ';' +  cast(@TempFor_Date as varchar(11))	
																				
																				if @Use_Table =1 
																					begin   
																						insert into #Emp_Weekoff (Emp_ID,Cmp_ID,For_Date,W_Day)
																						select @Emp_ID ,@Cmp_Id,@TempFor_Date,@Weekoff_Value																
																					end	
																			END	
																		ELSE IF EXISTS ( SELECT	1 FROM	T0120_LEAVE_APPROVAL LA WITH (NOLOCK) inner join T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) on LA.Leave_Approval_ID = LAD.Leave_Approval_ID 
																								inner join T0040_LEAVE_MASTER LM WITH (NOLOCK) on lm.Leave_ID = LAD.Leave_ID 
																								LEFT JOIN T0150_LEAVE_CANCELLATION LC WITH (NOLOCK) ON LA.Leave_Approval_ID = LC.Leave_Approval_id and LC.Is_Approve = 1 
																							WHERE la.Emp_ID = @Emp_Id 
																							--AND (LM.LEAVE_TYPE <> 'Company Purpose' or LM.Default_Short_Name = 'COMP')
																							and  ( ( @Pre_Date_WeekOff >= lad.From_Date and @Pre_Date_WeekOff <= lad.To_Date ) or 
																								( @Next_Date_WeekOff >= lad.From_Date  and   @Next_Date_WeekOff <= lad.To_Date )
																							) and Approval_Status = 'A' and LC.Leave_Approval_id is null AND LM.Weekoff_as_leave = 0
																							AND LM.Leave_Paid_Unpaid = 'U' 
																						) AND IsNull(@Is_Cancel_Weekoff,0) <> 9 
																			BEGIN	/* CL - WO - LWP (Unpaid Leave) :Cancel WO */
																				PRINT 'REASON 5 ' + CONVERT(CHAR(10), @TempFor_Date , 103)
																				Set	@Cancel_WeekOff = @Cancel_WeekOff + @Weekoff_Value	
																				set @varCancelWeekOff_Date = @varCancelWeekOff_Date + ';' +  cast(@TempFor_Date as varchar(11))	
																		 	END
																	END
																	
																else if @Weekoff_Value > 0
																	begin				
																		if @Join_Date <= @Tempfor_Date And (@Left_Date is null or @Tempfor_Date <= @Left_Date)
																		Begin 
																			set @numWeekOff =  @numWeekOff + @Weekoff_Value
																			set @varWeekOff_Date = @varWeekOff_Date + ';' +  cast(@TempFor_Date as varchar(11))		
																			
																				
																			if @Use_Table =1 
																				begin   
																					insert into #Emp_Weekoff (Emp_ID,Cmp_ID,For_Date,W_Day)
																					select @Emp_ID ,@Cmp_Id,@TempFor_Date,@Weekoff_Value																
																				end	
																		End
																	end

																if @CancelHolidayIfOneSideAbsent = 1
																begin
																	PRINT 'REASON new ' + CONVERT(CHAR(10), @TempFor_Date , 103)

																		Set	@Cancel_WeekOff = @Cancel_WeekOff + @Weekoff_Value	
																		set @varCancelWeekOff_Date = @varCancelWeekOff_Date + ';' +  cast(@TempFor_Date as varchar(11))	
																end
																															
															END										 					
										 Else if exists (select lad.Leave_Approval_ID from T0120_LEAVE_APPROVAL LA WITH (NOLOCK)
															inner join T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) on LA.Leave_Approval_ID = LAD.Leave_Approval_ID 
															inner join T0040_LEAVE_MASTER LM WITH (NOLOCK) on lm.Leave_ID = LAD.Leave_ID where la.Emp_ID = @Emp_Id 
																		and ( @TempFor_Date >= lad.From_Date  and   @TempFor_Date <= lad.To_Date) 
																		and Approval_Status = 'A' AND LM.Leave_Type <> 'Company Purpose') 
												and exists (select 1 from T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) where  lT.Emp_ID = @Emp_Id 
																	and Lt.For_Date = @TempFor_Date and (lt.Leave_Used <> 0 OR lt.CompOff_Used <> 0)) 
												and isnull(@Is_Cancel_Weekoff,0) <> 9 
											begin												
												PRINT 'REASON 6 ' + CONVERT(CHAR(10), @TempFor_Date , 103)
												Set	@Cancel_WeekOff = @Cancel_WeekOff + @Weekoff_Value	
												set @varCancelWeekOff_Date = @varCancelWeekOff_Date + ';' +  cast(@TempFor_Date as varchar(11))	
											end	
										 ELSE IF EXISTS(SELECT 1 FROM T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)
														INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LT.Leave_ID=LM.Leave_ID
													WHERE	LT.Emp_ID=@EMP_ID AND LT.For_Date=@TempFor_Date 
															AND (LT.Leave_Used > 0 OR (LT.CompOff_Used  - ISNULL(LT.Leave_Encash_Days,0)) > 0))
													AND isnull(@Is_Cancel_Weekoff,0) <> 9 
											BEGIN
												PRINT'REASON 7 ' + CONVERT(CHAR(10), @TempFor_Date , 103)
												Set	@Cancel_WeekOff = @Cancel_WeekOff + @Weekoff_Value	
												set @varCancelWeekOff_Date = @varCancelWeekOff_Date + ';' +  cast(@TempFor_Date as varchar(11))	
											END
										ELSE IF @Has_Leave_Pre_Next = 2 -- OR (@Reverse_Leave_Cancel_Sett = 1 AND @Has_Leave_Pre_Next = 1)
											BEGIN												
												--SET  @CANCEL_REASON = 'REASON 10'
												PRINT'REASON 8 ' + CONVERT(CHAR(10), @TempFor_Date , 103)
												set	@Cancel_WeekOff = @Cancel_WeekOff + @Weekoff_Value												
												set @varCancelWeekOff_Date = @varCancelWeekOff_Date + ';' +  cast(@TempFor_Date as varchar(11))	
											END
										ELSE If @Left_Date is null And @Weekoff_Value > 0
											begin			
											
													set @numWeekOff =  @numWeekOff + @Weekoff_Value
													set @varWeekOff_Date = @varWeekOff_Date + ';' +  cast(@TempFor_Date as varchar(11))													
													--print 'f'												

														

													if @Use_Table =1 
														begin   
															insert into #Emp_Weekoff (Emp_ID,Cmp_ID,For_Date,W_Day)
															select @Emp_ID ,@Cmp_Id,@TempFor_Date,@Weekoff_Value																
														end	
													
											end									
										--Else If @Left_Date >= @TempFor_Date And @Weekoff_Value > 0 --Added By Ramiz for alternate Week-off Case Not Working for Left Employee
										Else If (@Left_Date >= @TempFor_Date or (@Allowed_Full_WeekOff_MidJoining =1 or @Allowed_Full_WeekOff_MidJoining =2 or @Allowed_Full_WeekOff_MidJoining =3)) And @Weekoff_Value > 0  --Ramiz Added this on 27/02/2016
											begin																					
												set @numWeekOff =  @numWeekOff + @Weekoff_Value						
												set @varWeekOff_Date = @varWeekOff_Date + ';' +  cast(@TempFor_Date as varchar(11))
													
														
												if @Use_Table =1 
													begin
														insert into #Emp_Weekoff (Emp_ID,Cmp_ID,For_Date,W_Day)
														select @Emp_ID ,@Cmp_Id,@TempFor_Date,@Weekoff_Value															
													end	
												end												
										Else IF isnull(@Is_Cancel_Weekoff,0) <> 9 	
											begin
												PRINT 'REASON 9' + ' ' + CONVERT(CHAR(10), @TempFor_Date , 103)
											 	set	@Cancel_WeekOff = @Cancel_WeekOff + @Weekoff_Value												
												set @varCancelWeekOff_Date = @varCancelWeekOff_Date + ';' +  cast(@TempFor_Date as varchar(11))	
											end										
										End
									End
								  Else if charindex(datename(dw,@TempFor_Date) ,@WeekOff,0) >0  and isnull(@Is_Cancel_Weekoff,0) <> 9 
									Begin		
										PRINT 'REASON 10' + ' ' + CONVERT(CHAR(10), @TempFor_Date , 103)
										set	@Cancel_WeekOff =	 + @Weekoff_Value		
									End
																		
									set @TempFor_Date = dateadd(d,1,@TempFor_Date)
							end
							
NEXT_RECORD:
							
						fetch next from curWeekOff into @WeekOff ,@Effe_Date,@Weekoff_Day_Value,@Alt_W_Name,@Alt_W_Full_day_Cont,@Alt_W_Half_Day_Cont,@IS_P_Comp
					end 										
			close curWeekOff
			deallocate curWeekOff	
		
		 
		 
		 
		set @Pre_Date_WeekOff = NULL 
		set @Next_Date_WeekOff = NULL
		
		set @Weekoff_Value = 1
		
		
		
		
	 	
		Declare @for_date_roster as datetime
		Declare @Is_Cancel_WO_Roster	As Numeric
		set @Is_Cancel_WO_Roster =0
			
		Declare curWeekOffRoster cursor for
			SELECT  for_date ,is_Cancel_WO  FROM T0100_WEEKOFF_ROSTER WITH (NOLOCK) WHERE FOR_DATE >= @From_Date AND FOR_DATE <= @To_Date and Emp_id = @Emp_Id 		  
		open curWeekOffRoster
		fetch next from curWeekOffRoster into @for_date_roster,@Is_Cancel_WO_Roster
			while @@fetch_status = 0
				begin
					--set @Var_All_H_Date = datename(dw,@for_date_roster)
					
					
					set @TempFor_Date = @for_date_roster
					--set @numWeekOff =  @numWeekOff + 1						
					--set @varWeekOff_Date = @varWeekOff_Date + ';' +  cast(@for_date_roster as varchar(11))
						
					--if @Use_Table =1 
					--	begin
					--		insert into #Emp_Weekoff (Emp_ID,Cmp_ID,For_Date,W_Day)
					--		select @Emp_ID ,@Cmp_Id,@for_date_roster,1															
					--	end	
					
					
						--declare @cnt_leave_pre_next_weekoff numeric(5,1)
						--		declare @temp_cnt_leave_pre_next_weekoff numeric(5,1)
						--		declare @chk_leave_setting_for_leave_as_weekoff as tinyint
				
				--'' Ankit 21042015
				IF @Is_Cancel_WO_Roster = 1
					Begin
					
						Set	@Cancel_WeekOff = @Cancel_WeekOff + @Weekoff_Value	
						set @varCancelWeekOff_Date = @varCancelWeekOff_Date + ';' +  cast(@TempFor_Date as varchar(11))	
						
						if CHARINDEX(cast(@TempFor_Date as varchar(11)),@varWeekOff_Date)>0 
							Begin
							
								Set @varWeekOff_Date = REPLACE(@varWeekOff_Date,';' + cast(@TempFor_Date as varchar(11)),'')

								Set @numWeekOff = @numWeekOff - 1
								
								
								if @Use_Table =1	--Delete temprary table
									begin   
										Delete FROM #Emp_Weekoff WHERE Emp_id = @Emp_Id And Cmp_id = @Cmp_ID And For_Date = @TempFor_Date
									end	
							end
					End				
				--'' Ankit 21042015			

				
				if charindex(CONVERT(VARCHAR(11),@TempFor_date,109) ,@varWeekOff_Date,0) <= 0 and charindex(CONVERT(VARCHAR(11),@TempFor_date,109) ,@varCancelWeekOff_Date,0) <= 0
					begin
								 
								exec dbo.SP_RETURN_PRE_NEXT_DATE_OF_WEEKOFF @TempFor_Date,@Var_All_H_Date,@Pre_Date_WeekOff output,@Next_Date_WeekOff output								
								
								
								
								set @cnt_leave_pre_next_weekoff = 0
								set @temp_cnt_leave_pre_next_weekoff = 0
								set @chk_leave_setting_for_leave_as_weekoff = 0
								
								
						
								--IF  case when @Allowed_Full_WeekOff_MidJoining =1 then @From_Date  else @Join_Date  end <=@TempFor_date
								--	Begin	
	
									if Charindex(CONVERT(VARCHAR(11),@TempFor_date,109),@strHoliday_Date,0)=0--Nikunj 08-August-2010 For Week Off And Holiday Crash
									Begin		
									
																			
										 --If @Is_Cancel_Weekoff =1 and not exists(select Emp_ID from T0150_EMP_INOUT_RECORD WHERE EMP_ID =@EMP_ID AND 
										 If not exists(select Emp_ID from T0150_EMP_INOUT_RECORD WITH (NOLOCK) WHERE EMP_ID =@EMP_ID AND 
															cast(for_date as varchar(11)) in (@Pre_Date_WeekOff,@Next_Date_WeekOff)) and (@TempFor_Date <= @Left_Date or @Left_Date is null) 

															BEGIN
																 
																select @cnt_leave_pre_next_weekoff = COUNT(lad.Leave_Approval_ID)  ,@chk_leave_setting_for_leave_as_weekoff = LM.Weekoff_as_leave  from T0120_LEAVE_APPROVAL LA WITH (NOLOCK) inner join T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) on LA.Leave_Approval_ID = LAD.Leave_Approval_ID inner join T0040_LEAVE_MASTER LM WITH (NOLOCK) on lm.Leave_ID = LAD.Leave_ID where la.Emp_ID = @Emp_Id and ((@Pre_Date_WeekOff >= lad.From_Date and @Pre_Date_WeekOff <= lad.To_Date) or ( @Next_Date_WeekOff >= lad.From_Date  and   @Next_Date_WeekOff <= lad.To_Date)) and Approval_Status = 'A' group by LM.Weekoff_as_leave order by LM.Weekoff_as_leave  desc
																if @CancelHolidayIfOneSideAbsent = 1
																begin
																	PRINT 'REASON new ' + CONVERT(CHAR(10), @TempFor_Date , 103)

																		Set	@Cancel_WeekOff = @Cancel_WeekOff + @Weekoff_Value	
																		set @varCancelWeekOff_Date = @varCancelWeekOff_Date + ';' +  cast(@TempFor_Date as varchar(11))	
																end
																if not @cnt_leave_pre_next_weekoff >= 2 
																	begin
																		set @temp_cnt_leave_pre_next_weekoff = 0
																		
																		select @temp_cnt_leave_pre_next_weekoff = COUNT(lad.Leave_Approval_ID)  ,@chk_leave_setting_for_leave_as_weekoff = LM.Weekoff_as_leave  from T0120_LEAVE_APPROVAL LA WITH (NOLOCK) inner join T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) on LA.Leave_Approval_ID = LAD.Leave_Approval_ID inner join T0040_LEAVE_MASTER LM WITH (NOLOCK) on lm.Leave_ID = LAD.Leave_ID where la.Emp_ID = @Emp_Id and (lad.From_Date <= @Pre_Date_WeekOff and lad.To_Date >= @Next_Date_WeekOff) and Approval_Status = 'A' group by LM.Weekoff_as_leave 
																		
																		if @temp_cnt_leave_pre_next_weekoff >= 1
																			begin	
																				set @cnt_leave_pre_next_weekoff = 2
																			end				
																		else
																			begin																																							
																				select @temp_cnt_leave_pre_next_weekoff = COUNT(lad.Leave_Approval_ID)  from T0120_LEAVE_APPROVAL LA WITH (NOLOCK) inner join T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) on LA.Leave_Approval_ID = LAD.Leave_Approval_ID inner join T0040_LEAVE_MASTER LM WITH (NOLOCK) on lm.Leave_ID = LAD.Leave_ID where la.Emp_ID = @Emp_Id and ((@Pre_Date_WeekOff >= lad.From_Date and @Pre_Date_WeekOff <= lad.To_Date) or ( @Next_Date_WeekOff >= lad.From_Date  and   @Next_Date_WeekOff <= lad.To_Date)) and Approval_Status = 'A' 
																				
																				if @temp_cnt_leave_pre_next_weekoff >=2 
																					begin	
																						select @chk_leave_setting_for_leave_as_weekoff = LM.Weekoff_as_leave  from T0120_LEAVE_APPROVAL LA WITH (NOLOCK) inner join T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) on LA.Leave_Approval_ID = LAD.Leave_Approval_ID inner join T0040_LEAVE_MASTER LM WITH (NOLOCK) on lm.Leave_ID = LAD.Leave_ID where la.Emp_ID = @Emp_Id and ((@Pre_Date_WeekOff >= lad.From_Date and @Pre_Date_WeekOff <= lad.To_Date) or ( @Next_Date_WeekOff >= lad.From_Date  and   @Next_Date_WeekOff <= lad.To_Date)) and Approval_Status = 'A'  order by LM.Weekoff_as_leave  desc		
																					end
																				else
																					begin	
																						select @chk_leave_setting_for_leave_as_weekoff = LM.Weekoff_as_leave  from T0120_LEAVE_APPROVAL LA WITH (NOLOCK) inner join T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) on LA.Leave_Approval_ID = LAD.Leave_Approval_ID inner join T0040_LEAVE_MASTER LM WITH (NOLOCK) on lm.Leave_ID = LAD.Leave_ID where la.Emp_ID = @Emp_Id and ((@Pre_Date_WeekOff >= lad.From_Date and @Pre_Date_WeekOff <= lad.To_Date) or ( @Next_Date_WeekOff >= lad.From_Date  and   @Next_Date_WeekOff <= lad.To_Date)) and Approval_Status = 'A'  order by LM.Weekoff_as_leave  desc		
																					end
																																							
																			end						 								
																	end			
																
																if exists (select 1 from T0120_LEAVE_APPROVAL LA WITH (NOLOCK) inner join T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) on LA.Leave_Approval_ID = LAD.Leave_Approval_ID inner join T0040_LEAVE_MASTER LM WITH (NOLOCK) on lm.Leave_ID = LAD.Leave_ID where la.Emp_ID = @Emp_Id and ( @TempFor_Date >= lad.From_Date  and   @TempFor_Date <= lad.To_Date) and Approval_Status = 'A')  and exists (select 1 from T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) where  lT.Emp_ID = @Emp_Id and Lt.For_Date = @TempFor_Date and (lt.Leave_Used <> 0 OR lt.CompOff_Used <> 0)) and isnull(@Is_Cancel_Weekoff,0) <> 9 
																	begin
																			--if @chk_leave_setting_for_leave_as_weekoff = 1
																			--	begin
																					Set	@Cancel_WeekOff = @Cancel_WeekOff + @Weekoff_Value	
																			--	end
																			--else
																			--	begin
																			--		set @numWeekOff =  @numWeekOff + @Weekoff_Value
																			--		set @varWeekOff_Date = @varWeekOff_Date + ';' +  cast(@TempFor_Date as varchar(11))		
																					
																			--		if @Use_Table =1 
																			--			begin   
																			--				insert into #Emp_Weekoff (Emp_ID,Cmp_ID,For_Date,W_Day)
																			--				select @Emp_ID ,@Cmp_Id,@TempFor_Date,@Weekoff_Value																
																			--			end	
																			--	end
																	end
																else if @cnt_leave_pre_next_weekoff >= 2 and @chk_leave_setting_for_leave_as_weekoff = 1 and isnull(@Is_Cancel_Weekoff,0) <> 9 
																	begin
																		
																		Set	@Cancel_WeekOff = @Cancel_WeekOff + @Weekoff_Value	
																		set @varCancelWeekOff_Date = @varCancelWeekOff_Date + ';' +  cast(@TempFor_Date as varchar(11))	
																	end
																else if @temp_cnt_leave_pre_next_weekoff >= 2 and @chk_leave_setting_for_leave_as_weekoff = 0 and @Weekoff_Value > 0
																	begin
																	
																		set @numWeekOff =  @numWeekOff + @Weekoff_Value
																		set @varWeekOff_Date = @varWeekOff_Date + ';' +  cast(@TempFor_Date as varchar(11))		
																		
																		
																		if @Use_Table =1 
																			begin   
																				insert into #Emp_Weekoff (Emp_ID,Cmp_ID,For_Date,W_Day)
																				select @Emp_ID ,@Cmp_Id,@TempFor_Date,@Weekoff_Value																
																			end	
																	end								
																--else if @genral_Cancel_Weekoff = 1 and @chk_leave_setting_for_leave_as_weekoff = 1
																--	begin	
																--		Set	@Cancel_WeekOff = @Cancel_WeekOff + @Weekoff_Value	
																--	end																										
																else if @genral_Cancel_Weekoff = 1 and @Is_Leave_Cal = 0 and @chk_leave_setting_for_leave_as_weekoff = 1 and isnull(@Is_Cancel_Weekoff,0) <> 9 --and charindex(datename(dw,@Pre_Date_WeekOff) ,@WeekOff,0) = 0 and charindex(datename(dw,@Next_Date_WeekOff) ,@WeekOff,0) = 0 
																	begin
																	
																		Set	@Cancel_WeekOff = @Cancel_WeekOff + @Weekoff_Value	
																		set @varCancelWeekOff_Date = @varCancelWeekOff_Date + ';' +  cast(@TempFor_Date as varchar(11))	
																	end
																else if @genral_Cancel_Weekoff = 1 and @Is_Leave_Cal = 0 and @temp_cnt_leave_pre_next_weekoff = 0 and @cnt_leave_pre_next_weekoff = 0 and isnull(@Is_Cancel_Weekoff,0) <> 9 
																	begin		
																
																		Set	@Cancel_WeekOff = @Cancel_WeekOff + @Weekoff_Value	
																		set @varCancelWeekOff_Date = @varCancelWeekOff_Date + ';' +  cast(@TempFor_Date as varchar(11))	
																		
																	end
																else --if @Weekoff_Value > 0
																	begin				
																
																		set @numWeekOff =  @numWeekOff + @Weekoff_Value
																		set @varWeekOff_Date = @varWeekOff_Date + ';' +  cast(@TempFor_Date as varchar(11))		
																		
																		
																		if @Use_Table =1 
																			begin   
																				insert into #Emp_Weekoff (Emp_ID,Cmp_ID,For_Date,W_Day)
																				select @Emp_ID ,@Cmp_Id,@TempFor_Date,@Weekoff_Value																
																			end	
																	end
																															
															END										 					
										 Else if exists (select lad.Leave_Approval_ID from T0120_LEAVE_APPROVAL LA WITH (NOLOCK) inner join T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) on LA.Leave_Approval_ID = LAD.Leave_Approval_ID inner join T0040_LEAVE_MASTER LM WITH (NOLOCK) on lm.Leave_ID = LAD.Leave_ID where la.Emp_ID = @Emp_Id and ( @TempFor_Date >= lad.From_Date  and   @TempFor_Date <= lad.To_Date) and Approval_Status = 'A') and exists (select 1 from T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) where  lT.Emp_ID = @Emp_Id and Lt.For_Date = @TempFor_Date and (lt.Leave_Used <> 0 OR lt.CompOff_Used <> 0))and isnull(@Is_Cancel_Weekoff,0) <> 9 
											begin
											
												Set	@Cancel_WeekOff = @Cancel_WeekOff + @Weekoff_Value	
												set @varCancelWeekOff_Date = @varCancelWeekOff_Date + ';' +  cast(@TempFor_Date as varchar(11))	
											end	
										 ELSE If @Left_Date is null And @Weekoff_Value > 0
											begin			
									
													set @numWeekOff =  @numWeekOff + @Weekoff_Value
													set @varWeekOff_Date = @varWeekOff_Date + ';' +  cast(@TempFor_Date as varchar(11))													
													
													
													if @Use_Table =1 
														begin   
													
															insert into #Emp_Weekoff (Emp_ID,Cmp_ID,For_Date,W_Day)
															select @Emp_ID ,@Cmp_Id,@TempFor_Date,@Weekoff_Value																
														end	
													
											end									
										--Else If @Left_Date >= @TempFor_Date
										Else If (@Left_Date >= @TempFor_Date or (@Allowed_Full_WeekOff_MidJoining =1 or @Allowed_Full_WeekOff_MidJoining =2 or @Allowed_Full_WeekOff_MidJoining =3)) And @Weekoff_Value > 0  --Ramiz Added this on 27/02/2016
											begin				
									
													set @numWeekOff =  @numWeekOff + @Weekoff_Value						
													set @varWeekOff_Date = @varWeekOff_Date + ';' +  cast(@TempFor_Date as varchar(11))
													
														
													if @Use_Table =1 
														begin
															insert into #Emp_Weekoff (Emp_ID,Cmp_ID,For_Date,W_Day)
															select @Emp_ID ,@Cmp_Id,@TempFor_Date,@Weekoff_Value															
														end	
											end												
										Else	
											begin
									
												set	@Cancel_WeekOff = @Cancel_WeekOff + @Weekoff_Value												
												set @varCancelWeekOff_Date = @varCancelWeekOff_Date + ';' +  cast(@TempFor_Date as varchar(11))	
											end
										End
									--End
								  Else if charindex(datename(dw,@TempFor_Date) ,@WeekOff,0) >0 
									Begin
									
										set	@Cancel_WeekOff = @Cancel_WeekOff + @Weekoff_Value		
									End
									--set @TempFor_Date = dateadd(d,1,@TempFor_Date)
						
					end
				fetch next from curWeekOffRoster into @for_date_roster ,@Is_Cancel_WO_Roster
			end 										
		close curWeekOffRoster
		deallocate curWeekOffRoster	
	

	

IF @Type = 0
	Begin
		 
		RETURN
	End 
Else if @Type = 1
	Begin
		
		Select @varWeekOff_Date
	End
