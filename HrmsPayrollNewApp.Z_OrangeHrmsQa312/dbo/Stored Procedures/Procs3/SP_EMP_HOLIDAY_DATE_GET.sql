

CREATE PROCEDURE [dbo].[SP_EMP_HOLIDAY_DATE_GET]
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
,@Type numeric = 0 -- Prakash Patel 07012015
,@varCancelHoliday_Date varchar(max)= '' output	--Ankit 08012015
,@Allowed_Full_WeekOff_MidJoining tinyint = 0 --Hardik 09/11/2020 For Gujarat Foil Client
AS
	Set Nocount on 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON


  
	Declare @H_From_Date	Datetime 
	Declare @H_To_Date		Datetime 
	Declare @Date_Diff		numeric
	Declare @varHoliday_Date varchar(Max)
	Declare @varHoliday_PreNext_Date varchar(Max)
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
	DECLARE @CancelHolidayIfOneSideAbsent tinyint

	set @varHoliday_Date = ''
	set @Cancel_Holiday = 0
	set @HoliDay_Days = 0
	set @Is_Cancel =0
	set @Branch_Id_Temp =0 
	set @genral_Cancel_Holiday = 0
	set @is_Fix = 'N'
	 
	
	DECLARE @Reverse_Leave_Cancel_Sett NUMERIC	--Ankit 16032016
	SET @Reverse_Leave_Cancel_Sett = 0
	
	SELECT @Reverse_Leave_Cancel_Sett = Setting_Value FROM T0040_SETTING WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND Setting_Name = 'Reverse Current WO/HO Cancel Policy'

	
	exec SP_EMP_WEEKOFF_HOLIDAY_DATE_GET @Emp_Id,@Cmp_ID,@From_Date,@To_Date,NULL,NULL,0,'',@varHoliday_PreNext_Date output,'',0,0,0,0 
	
	If isnull(@join_Date,'') = ''
		Begin
			exec dbo.SP_EMP_JOIN_LEFT_DATE_GET @Emp_ID ,@Cmp_ID ,@From_Date,@To_Date,@Join_Date output ,@Left_Date output
		End

	If isnull(@Left_Date,'') <> '' 
		begin
			if @Left_Date < @Join_Date  
				set @Left_Date = null	
		end
	
	if @Join_Date > @From_Date And @Allowed_Full_WeekOff_MidJoining = 0
		set @From_Date = @Join_Date
	-- Commented by Gadriwala Muslim 5/10/2015
	
	--select @Branch_Id_Temp = Branch_ID from dbo.T0095_Increment EI where Increment_Effective_Date in (select max(Increment_effective_Date) as Increment_effective_Date from dbo.T0095_Increment  where Increment_Effective_date <= @To_Date  and Cmp_ID = @Cmp_ID and Emp_ID = @Emp_Id) and Emp_ID = @Emp_Id
	--select @genral_Cancel_Holiday = Is_Cancel_Holiday from dbo.T0040_GENERAL_SETTING GS where For_Date in (select max(For_Date) as For_Date from dbo.T0040_GENERAL_SETTING  where For_Date <= @To_Date  and Cmp_ID = @Cmp_ID and Branch_ID = @Branch_Id_Temp) and Branch_ID = @Branch_Id_Temp
	
	-- Changed by Gadriwala Muslim 05/10/2015 - Start
	--select @Branch_Id_Temp = Branch_ID from dbo.T0095_Increment EI inner join (
	--select max(Increment_ID) as Increment_ID from dbo.T0095_Increment  
	--where Increment_Effective_date <= @To_Date  and Cmp_ID = @Cmp_ID and Emp_ID = @Emp_Id
	--)Qry on Qry.Increment_ID = EI.Increment_ID  
	--where  Emp_ID = @Emp_Id and cmp_ID = @cmp_ID

	If @Emp_Id > 0
		SELECT	@Branch_Id_Temp = I1.BRANCH_ID
		FROM	T0095_INCREMENT I1 WITH (NOLOCK) 
				INNER JOIN (SELECT	MAX(I2.Increment_ID) AS Increment_ID
							FROM	T0095_INCREMENT I2 WITH (NOLOCK) 
									INNER JOIN (SELECT	MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE
												FROM	T0095_INCREMENT I3 WITH (NOLOCK) 
												WHERE	I3.Increment_Effective_Date <= @To_Date and Cmp_ID = @Cmp_ID and Emp_ID = @Emp_Id
												) I3 ON I2.Increment_Effective_Date=I3.INCREMENT_EFFECTIVE_DATE
							WHERE	I2.Cmp_ID = @Cmp_Id and Emp_ID = @Emp_Id
							) I2 ON I1.Increment_ID=I2.INCREMENT_ID	
		WHERE	I1.Cmp_ID=@Cmp_Id	and Emp_ID = @Emp_Id
	Else
		Set @Branch_Id_Temp = @Branch_Id
	
	 
	select @genral_Cancel_Holiday = Is_Cancel_Holiday,@CancelHolidayIfOneSideAbsent = ISNULL(Is_Cancel_Holiday_IfOneSideAbsent,0) from dbo.T0040_GENERAL_SETTING GS  WITH (NOLOCK) 
	Inner join (select max(For_Date) as For_Date from dbo.T0040_GENERAL_SETTING   WITH (NOLOCK) 
	where For_Date <= @To_Date  and Cmp_ID = @Cmp_ID and Branch_ID = @Branch_Id_Temp) Qry
	on Qry.For_Date = GS.For_Date
	Where Branch_ID = @Branch_Id_Temp and Cmp_ID = @Cmp_ID
	-- Changed by Gadriwala Muslim 05/10/2015 - End
		
		-- Added by rohit For Get all holiday without Cancel it. this is Added for get all Holiday in this SP without Cancel It.(Sp_Inout_Record_Daily_Get)
		if isnull(@Is_Cancel_Holiday,0)=9
		begin 
		set @genral_Cancel_Holiday=0
		end
		
	
	CREATE TABLE #TMP_HOLIDAY
	(
		H_FROM_DATE DATETIME,
		H_TO_DATE DATETIME,
	    IS_HALF BIT,
	    IS_P_COMP BIT,
		IS_FIX CHAR(1)
	)

	
	
	INSERT INTO #TMP_HOLIDAY
	SELECT DISTINCT CAST(CAST(DATENAME(DAY,H_FROM_DATE) AS VARCHAR(2)) + '-' + CAST(DATENAME(MONTH,H_FROM_DATE)AS VARCHAR(3)) + '-' + CASE WHEN MONTH(H_FROM_DATE) > MONTH(@TO_DATE) THEN CAST(YEAR(@FROM_DATE)AS VARCHAR(4)) ELSE CAST(YEAR(@TO_DATE)AS VARCHAR(4)) END AS DATETIME) AS H_FROM_DATE,
				CAST(CAST(DATENAME(DAY,H_TO_DATE) AS VARCHAR(2)) + '-' + CAST(DATENAME(MONTH,H_TO_DATE)AS VARCHAR(3)) + '-' + CASE WHEN MONTH(H_TO_DATE) > MONTH(@TO_DATE) THEN CAST(YEAR(@FROM_DATE)AS VARCHAR(4)) ELSE CAST(YEAR(@TO_DATE)AS VARCHAR(4)) END AS DATETIME) AS H_TO_DATE,
				ISNULL(IS_HALF,0) AS IS_HALF ,ISNULL(IS_P_COMP,0) AS IS_P_COMP , IS_FIX 
			FROM T0040_HOLIDAY_MASTER  WITH (NOLOCK) 
				WHERE CMP_ID=@CMP_ID AND IS_FIX = 'Y' AND ISNULL(IS_OPTIONAL,0)= 0 AND (ISNULL(BRANCH_ID,0) = 0 OR ISNULL(BRANCH_ID,0) =@BRANCH_ID_TEMP) AND
					@FROM_DATE <= 
						CAST(CAST(DATENAME(DAY,H_FROM_DATE) AS VARCHAR(2)) + '-' + CAST(DATENAME(MONTH,H_FROM_DATE)AS VARCHAR(3)) + '-' + CASE WHEN MONTH(H_FROM_DATE) > MONTH(@TO_DATE) THEN CAST(YEAR(@FROM_DATE)AS VARCHAR(4)) ELSE CAST(YEAR(@TO_DATE)AS VARCHAR(4)) END AS DATETIME) 
					AND 
					@TO_DATE >= 
						CAST(CAST(DATENAME(DAY,H_FROM_DATE) AS VARCHAR(2)) + '-' + CAST(DATENAME(MONTH,H_FROM_DATE)AS VARCHAR(3)) + '-' + CASE WHEN MONTH(H_FROM_DATE) > MONTH(@TO_DATE) THEN CAST(YEAR(@FROM_DATE)AS VARCHAR(4)) ELSE CAST(YEAR(@TO_DATE)AS VARCHAR(4)) END AS DATETIME)
					And ISNULL(Is_P_Comp,0) = 0 --Added by nilesh patel for Compulsory Present on holiday 
		UNION ALL
			SELECT DISTINCT  CAST(CAST(DATENAME(DAY,H_FROM_DATE) AS VARCHAR(2)) + '-' + CAST(DATENAME(MONTH,H_FROM_DATE)AS VARCHAR(3)) + '-' + CASE WHEN MONTH(H_FROM_DATE) > MONTH(@TO_DATE) THEN CAST(YEAR(@FROM_DATE)AS VARCHAR(4)) ELSE CAST(YEAR(@TO_DATE)AS VARCHAR(4)) END AS DATETIME) AS H_FROM_DATE,
				CAST(CAST(DATENAME(DAY,H_TO_DATE) AS VARCHAR(2)) + '-' + CAST(DATENAME(MONTH,H_TO_DATE)AS VARCHAR(3)) + '-' + CASE WHEN MONTH(H_TO_DATE) > MONTH(@TO_DATE) THEN CAST(YEAR(@FROM_DATE)AS VARCHAR(4)) ELSE CAST(YEAR(@TO_DATE)AS VARCHAR(4)) END AS DATETIME) AS H_TO_DATE,
				ISNULL(IS_HALF,0) ,ISNULL(IS_P_COMP,0) , IS_FIX 
			FROM T0040_HOLIDAY_MASTER WITH (NOLOCK)  WHERE CMP_ID=@CMP_ID AND HDAY_ID IN (SELECT HDAY_ID FROM T0120_OP_HOLIDAY_APPROVAL WITH (NOLOCK)  
			WHERE CMP_ID=@CMP_ID AND EMP_ID=@EMP_ID AND OP_HOLIDAY_APR_STATUS='A') And ISNULL(Is_P_Comp,0) = 0 AND
			(
				(@FROM_DATE BETWEEN H_FROM_DATE AND H_To_Date) OR 
				(@TO_DATE BETWEEN H_FROM_DATE AND H_To_Date) OR
				(H_FROM_DATE BETWEEN @FROM_DATE AND @TO_DATE) OR
				(H_To_Date BETWEEN @FROM_DATE AND @TO_DATE) 	
			)

		UNION ALL
			SELECT DISTINCT  H_FROM_DATE , H_TO_DATE ,ISNULL(IS_HALF,0) ,ISNULL(IS_P_COMP,0) , IS_FIX 
			FROM T0040_HOLIDAY_MASTER  WITH (NOLOCK) 
			WHERE CMP_ID=@CMP_ID AND
			--AND H_FROM_DATE >= @FROM_DATE AND H_TO_DATE <= @TO_DATE --Comment by Nilesh Patel on 03122015 
			-- Added by nilesh for Consider between Holidays
			(
				(@FROM_DATE BETWEEN H_FROM_DATE AND H_To_Date) OR 
				(@TO_DATE BETWEEN H_FROM_DATE AND H_To_Date) OR
				(H_FROM_DATE BETWEEN @FROM_DATE AND @TO_DATE) OR
				(H_To_Date BETWEEN @FROM_DATE AND @TO_DATE) 	
			)
			AND ISNULL(IS_OPTIONAL,0)=0 AND IS_FIX = 'N'
			AND (ISNULL(BRANCH_ID,0) = 0 OR ISNULL(BRANCH_ID,0) =@BRANCH_ID_TEMP) And ISNULL(Is_P_Comp,0) = 0
	
	--IF SAME DATE 2 HOLIDAY ADDED , FOR THAT DELETE HOLIDAY WHERE IS FIX =N
	DELETE T FROM #TMP_HOLIDAY T
		INNER JOIN (SELECT H_From_Date, T1.H_TO_DATE FROM #TMP_HOLIDAY T1 WHERE T1.IS_FIX='Y') T1 ON T.H_FROM_DATE=T1.H_FROM_DATE AND T.H_TO_DATE=T1.H_TO_DATE
	WHERE T.IS_FIX='N'
	 		
	DECLARE curHoliday CURSOR FAST_FORWARD FOR
	SELECT H_FROM_DATE,H_TO_DATE,IS_HALF,IS_P_COMP,IS_FIX FROM #TMP_HOLIDAY
	
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
										if year(@H_From_Date) = year(@to_date)	--Ankit 04032016 /* Case: Default Employee In out Period for 2 month then HO date must not get in Record list (Mantis Bug ID - 0003769) */
											BEGIN
												set @H_From_Date = cast(DAY(@H_From_Date) as nvarchar(2)) + '-' + left(datename(MONTH, @H_From_Date ),3) + '-' + cast(year(@to_Date) as nvarchar(4)) -- @to_date changed by mitesh on 23012013
												set @H_To_Date = cast(DAY(@H_To_Date) as nvarchar(2)) + '-' + left(datename(MONTH, @H_To_Date ),3) + '-' + cast(year(@to_Date) as nvarchar(4))  -- @to_date changed by mitesh on 23012013
											END
										ELSE	
											BEGIN
												set @H_From_Date = cast(DAY(@H_From_Date) as nvarchar(2)) + '-' + left(datename(MONTH, @H_From_Date ),3) + '-' + cast(year(@from_date) as nvarchar(4)) -- @to_date changed by mitesh on 23012013
												set @H_To_Date = cast(DAY(@H_To_Date) as nvarchar(2)) + '-' + left(datename(MONTH, @H_To_Date ),3) + '-' + cast(year(@from_date) as nvarchar(4))  -- @to_date changed by mitesh on 23012013
											END
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
				
						  IF EXISTS( SELECT Data FROM DBO.SPLIT(@VARHOLIDAY_DATE,';') where Data = @For_Date) -- added by gadriwala muslim 0312016 Repeat Holiday duplication.. 
								BEGIN
									GOTO end1
								END
							
							set @Is_Cancel = 0
							
							if @Is_P_Comp =1 and not exists(select Emp_ID from dbo.T0150_EMP_INOUT_RECORD WITH (NOLOCK)  WHERE EMP_ID =@EMP_ID AND FOR_DATE =@FOR_DATE AND
																	( NOT IN_TIME IS NULL OR NOT OUT_TIME IS NULL)) and isnull(@Is_Cancel_Holiday,0)<> 9
									BEGIN
										Set @Is_Cancel =1 
									END
							else if exists (select lad.Leave_Approval_ID from dbo.T0120_LEAVE_APPROVAL LA  WITH (NOLOCK) inner join T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK)  on LA.Leave_Approval_ID = LAD.Leave_Approval_ID inner join dbo.T0040_LEAVE_MASTER LM WITH (NOLOCK)  on lm.Leave_ID = LAD.Leave_ID where la.Emp_ID = @Emp_Id and ((@For_date >= lad.From_Date and @For_date <= lad.To_Date) ) and Approval_Status = 'A') 
									and exists ( select 1 from dbo.T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)  where  lT.Emp_ID = @Emp_Id and Lt.For_Date = @For_date 
													--and (lt.Leave_Used <> 0 OR lt.CompOff_Used <> 0) 
													and ( 
														   ( (lt.Leave_Used <> 0 OR lt.CompOff_Used <> 0) AND @H_Days = 1 ) OR
														   ( (lt.Leave_Used > 0.5 OR lt.CompOff_Used > 0.5) AND @H_Days = 0.5 ) 
														 )
											   ) and isnull(@Is_Cancel_Holiday,0)<> 9
											begin
												Set @Is_Cancel =1 
											end			
									
							else --if @Is_Cancel_Holiday =1 
									begin
											 
											exec dbo.SP_RETURN_PRE_NEXT_DATE_OF_WEEKOFF @For_Date,@varHoliday_PreNext_Date,@Pre_Date_WeekOff output,@Next_Date_WeekOff output
											 
											 
											if not exists(select Emp_ID from dbo.T0150_EMP_INOUT_RECORD WITH (NOLOCK)  WHERE EMP_ID =@EMP_ID 
															AND (FOR_DATE =@Pre_Date_WeekOff Or For_Date=@Next_Date_WeekOff)AND--Nikunj 07-Jan-2011 Put Or in For_date Condition.For more info ask me
																			( NOT IN_TIME IS NULL OR NOT OUT_TIME IS NULL))
											Begin												
												
													if @CancelHolidayIfOneSideAbsent = 1
																begin
																	PRINT 'REASON new ' + CONVERT(CHAR(10), @varCancelHoliday_Date , 103)

																		Set @Is_Cancel = 1  																											
																	set @varCancelHoliday_Date = @varCancelHoliday_Date + ';' +  cast(@For_Date as varchar(11))	
																end
												--Set @Is_Cancel =1 
												
												-- changed by mitesh on 26/12/2011
												 
												declare @cnt_leave_pre_next_holiday numeric(5,1)
							 					declare @chk_leave_setting_for_leave_as_holiday as tinyint
							 					declare @temp_cnt_leave_pre_next_holiday numeric(5,1)
							 					
							 					set @cnt_leave_pre_next_holiday = 0
							 					set @chk_leave_setting_for_leave_as_holiday = 0
							 					set @temp_cnt_leave_pre_next_holiday = 0
							 					
												--select @cnt_leave_pre_next_holiday = COUNT(lad.Leave_Approval_ID) ,@chk_leave_setting_for_leave_as_holiday = LM.Holiday_as_leave  
												--from T0120_LEAVE_APPROVAL LA inner join T0130_LEAVE_APPROVAL_DETAIL LAD on LA.Leave_Approval_ID = LAD.Leave_Approval_ID inner join 
												--T0040_LEAVE_MASTER LM on lm.Leave_ID = LAD.Leave_ID 
												--LEFT JOIN T0150_LEAVE_CANCELLATION LC ON LA.Leave_Approval_ID = LC.Leave_Approval_id and LC.Is_Approve = 1 -- Added by nilesh patel on 26022016 For Cosider Leave Cancellation
												--where la.Emp_ID = @Emp_Id and 
												--((@Pre_Date_WeekOff >= lad.From_Date and @Pre_Date_WeekOff <= lad.To_Date) or 
												--( @Next_Date_WeekOff >= lad.From_Date  and   @Next_Date_WeekOff <= lad.To_Date)) and 
												--Approval_Status = 'A' and LC.Leave_Approval_id is null
												--group by LM.Holiday_as_leave 
												----order by LM.Holiday_as_leave  desc
												--order by LM.Holiday_as_leave -- Added by nilesh Patel on 26022016 Holiday is not consider when CL & Holiday & PL Leave
												SELECT	@Cnt_Leave_Pre_Next_Holiday = COUNT(lad.Leave_Approval_ID),
														@Chk_Leave_Setting_For_Leave_As_Holiday = Max(LM.Holiday_as_leave)													
												FROM	T0120_LEAVE_APPROVAL LA WITH (NOLOCK)  INNER JOIN T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK)  on LA.Leave_Approval_ID = LAD.Leave_Approval_ID 
														INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK)  on lm.Leave_ID = LAD.Leave_ID 
														LEFT JOIN T0150_LEAVE_CANCELLATION LC WITH (NOLOCK)  ON LA.Leave_Approval_ID = LC.Leave_Approval_id and LC.Is_Approve = 1 

														And  LC.For_date = @Pre_Date_WeekOff and LC.For_date = @Next_Date_WeekOff
												WHERE	la.Emp_ID = @Emp_Id AND (
																					(@Pre_Date_WeekOff >= lad.From_Date and @Pre_Date_WeekOff <= lad.To_Date) or 
																					( @Next_Date_WeekOff >= lad.From_Date  and   @Next_Date_WeekOff <= lad.To_Date)
																				) AND Approval_Status = 'A' and LC.Leave_Approval_id is null

														AND (CASE WHEN @Reverse_Leave_Cancel_Sett = 1 THEN 1 WHEN @Reverse_Leave_Cancel_Sett = 0 AND (LM.Holiday_as_leave = 1 OR LM.Leave_Type = 'Company Purpose') THEN 1 ELSE 0 END)=1
							


												if not @cnt_leave_pre_next_holiday >= 2 
						 							begin
						 								set @temp_cnt_leave_pre_next_holiday = 0
						 								
						 								select @temp_cnt_leave_pre_next_holiday = COUNT(lad.Leave_Approval_ID)  ,@chk_leave_setting_for_leave_as_holiday = LM.Holiday_as_leave  
						 								from T0120_LEAVE_APPROVAL LA WITH (NOLOCK)  inner join T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK)  on LA.Leave_Approval_ID = LAD.Leave_Approval_ID inner join 
						 								T0040_LEAVE_MASTER LM WITH (NOLOCK)  on lm.Leave_ID = LAD.Leave_ID 
						 								LEFT JOIN T0150_LEAVE_CANCELLATION LC WITH (NOLOCK)  ON LA.Leave_Approval_ID = LC.Leave_Approval_id and LC.Is_Approve = 1 -- Added by nilesh patel on 26022016 For Cosider Leave Cancellation
						 								where la.Emp_ID = @Emp_Id and 
						 								(lad.From_Date <= @Pre_Date_WeekOff and lad.To_Date >= @Next_Date_WeekOff) and 
						 								Approval_Status = 'A' and LC.Leave_Approval_id is null
						 								group by LM.Holiday_as_leave  
						 								--order by LM.Holiday_as_leave  desc
						 								order by LM.Holiday_as_leave -- Comment by nilesh Patel on 26022016 Holiday is not consider when CL & Holiday & PL Leave
						 								
						 								if @temp_cnt_leave_pre_next_holiday >= 1
						 									begin	
						 										set @cnt_leave_pre_next_holiday = 2
						 									end		
						 								else
															begin																																							
																select @temp_cnt_leave_pre_next_holiday = COUNT(lad.Leave_Approval_ID)  from T0120_LEAVE_APPROVAL LA WITH (NOLOCK)  inner join T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK)  on LA.Leave_Approval_ID = LAD.Leave_Approval_ID inner join T0040_LEAVE_MASTER LM WITH (NOLOCK)  on lm.Leave_ID = LAD.Leave_ID where la.Emp_ID = @Emp_Id and ((@Pre_Date_WeekOff >= lad.From_Date and @Pre_Date_WeekOff <= lad.To_Date) or ( @Next_Date_WeekOff >= lad.From_Date  and   @Next_Date_WeekOff <= lad.To_Date)) and Approval_Status = 'A' 

																
																
																--Ankit 22032016 /* Below Code Reference SP : SP_EMP_WEEKOFF_DATE_GET */
																IF @Temp_Cnt_Leave_Pre_Next_Holiday >=2
																	BEGIN
																		IF ISNULL(@Reverse_Leave_Cancel_Sett,0) = 0
																			BEGIN
																				SELECT	@Chk_Leave_Setting_For_Leave_As_Holiday = LM.Holiday_as_leave  
																				FROM	T0120_LEAVE_APPROVAL LA WITH (NOLOCK)  INNER JOIN T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK)  ON LA.Leave_Approval_ID = LAD.Leave_Approval_ID 
																						INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK)  ON lm.Leave_ID = LAD.Leave_ID 
																						LEFT JOIN T0150_LEAVE_CANCELLATION LC WITH (NOLOCK)  ON LA.Leave_Approval_ID = LC.Leave_Approval_id and LC.Is_Approve = 1
																				WHERE	LA.Emp_ID = @Emp_Id 
																						AND (
																								(@Pre_Date_WeekOff >= LAD.From_Date AND @Pre_Date_WeekOff <= LAD.To_Date) OR 
																								(@Next_Date_WeekOff >= LAD.From_Date AND @Next_Date_WeekOff <= LAD.To_Date)
																							) AND LA.Approval_Status = 'A' and LC.Leave_Approval_id is null
																				ORDER BY LM.Holiday_as_leave DESC
																			END
																		ELSE
																			BEGIN
																				SELECT	TOP 1 @Chk_Leave_Setting_For_Leave_As_Holiday = LM.Holiday_as_leave  
																				FROM	T0120_LEAVE_APPROVAL LA WITH (NOLOCK)  INNER JOIN T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK)  ON LA.Leave_Approval_ID = LAD.Leave_Approval_ID 
																						INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK)  ON lm.Leave_ID = LAD.Leave_ID 
																						LEFT JOIN T0150_LEAVE_CANCELLATION LC WITH (NOLOCK)  ON LA.Leave_Approval_ID = LC.Leave_Approval_id and LC.Is_Approve = 1
																				WHERE	LA.Emp_ID = @Emp_Id 
																						AND (
																								(@Pre_Date_WeekOff >= LAD.From_Date AND @Pre_Date_WeekOff <= LAD.To_Date) OR 
																								(@Next_Date_WeekOff >= LAD.From_Date AND @Next_Date_WeekOff <= LAD.To_Date)
																							) AND LA.Approval_Status = 'A' and LC.Leave_Approval_id is null
																				ORDER BY LM.Holiday_as_leave DESC
																			END		
																	END
																ELSE	
																	BEGIN
																		SELECT	TOP 1 @Chk_Leave_Setting_For_Leave_As_Holiday = LM.Holiday_as_leave  
																		FROM	T0120_LEAVE_APPROVAL LA WITH (NOLOCK)  INNER JOIN T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK)  ON LA.Leave_Approval_ID = LAD.Leave_Approval_ID 
																				INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK)  ON lm.Leave_ID = LAD.Leave_ID 
																				LEFT JOIN T0150_LEAVE_CANCELLATION LC WITH (NOLOCK)  ON LA.Leave_Approval_ID = LC.Leave_Approval_id and LC.Is_Approve = 1
																		WHERE	LA.Emp_ID = @Emp_Id 
																				AND (
																						(@Pre_Date_WeekOff >= LAD.From_Date AND @Pre_Date_WeekOff <= LAD.To_Date) OR 
																						(@Next_Date_WeekOff >= LAD.From_Date AND @Next_Date_WeekOff <= LAD.To_Date)
																					) AND LA.Approval_Status = 'A' and LC.Leave_Approval_id is null
																		ORDER BY LM.Holiday_as_leave
																		
																		/* If 'Leave - HO - Absent' Then WO Cancel */
																		IF ISNULL(@Reverse_Leave_Cancel_Sett,0) = 1 AND @Genral_Cancel_Holiday = 1 AND
																			EXISTS ( SELECT	1
																					FROM	T0120_LEAVE_APPROVAL LA WITH (NOLOCK)  INNER JOIN T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK)  ON LA.Leave_Approval_ID = LAD.Leave_Approval_ID 
																							INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK)  ON lm.Leave_ID = LAD.Leave_ID 
																							LEFT JOIN T0150_LEAVE_CANCELLATION LC WITH (NOLOCK)  ON LA.Leave_Approval_ID = LC.Leave_Approval_id AND LC.Is_Approve = 1 
																					WHERE la.Emp_ID = @Emp_Id AND (
																													(@Pre_Date_WeekOff >= lad.From_Date AND @Pre_Date_WeekOff <= lad.To_Date) OR 
																													( @Next_Date_WeekOff >= lad.From_Date  AND   @Next_Date_WeekOff <= lad.To_Date)
																												) AND Approval_Status = 'A' AND LC.Leave_Approval_id IS NULL AND LM.Holiday_as_leave = 0
																												and LM.Leave_Type <>'Company Purpose' --Added by Hardik 07/11/2016 as OD-HO-Absent case wrong in Aculife
																					) 
																			BEGIN
																				SET @Chk_Leave_Setting_For_Leave_As_Holiday = 1
																			END
																	END
																	
																	--Below Condition Comment by Ankit And add above condition as per WO SP 
																	--select @chk_leave_setting_for_leave_as_holiday = LM.Holiday_as_leave  from T0120_LEAVE_APPROVAL LA inner join T0130_LEAVE_APPROVAL_DETAIL LAD on LA.Leave_Approval_ID = LAD.Leave_Approval_ID inner join T0040_LEAVE_MASTER LM on lm.Leave_ID = LAD.Leave_ID where la.Emp_ID = @Emp_Id and ((@Pre_Date_WeekOff >= lad.From_Date and @Pre_Date_WeekOff <= lad.To_Date) or ( @Next_Date_WeekOff >= lad.From_Date  and   @Next_Date_WeekOff <= lad.To_Date)) and Approval_Status = 'A'  order by LM.Holiday_as_leave  desc		
																--Ankit 22032016
																
																
																--Changed By Nilay:26-Mar-2015  (due to Bhaskar issues)---
																--if @temp_cnt_leave_pre_next_holiday >=2 
																--	begin	
																--		select @chk_leave_setting_for_leave_as_holiday = LM.Weekoff_as_leave  from T0120_LEAVE_APPROVAL LA inner join T0130_LEAVE_APPROVAL_DETAIL LAD on LA.Leave_Approval_ID = LAD.Leave_Approval_ID inner join T0040_LEAVE_MASTER LM on lm.Leave_ID = LAD.Leave_ID where la.Emp_ID = @Emp_Id and ((@Pre_Date_WeekOff >= lad.From_Date and @Pre_Date_WeekOff <= lad.To_Date) or ( @Next_Date_WeekOff >= lad.From_Date  and   @Next_Date_WeekOff <= lad.To_Date)) and Approval_Status = 'A'  order by LM.Weekoff_as_leave  desc		
																--	end
																--else
																--	begin	
																--		select @chk_leave_setting_for_leave_as_holiday = LM.Weekoff_as_leave  from T0120_LEAVE_APPROVAL LA inner join T0130_LEAVE_APPROVAL_DETAIL LAD on LA.Leave_Approval_ID = LAD.Leave_Approval_ID inner join T0040_LEAVE_MASTER LM on lm.Leave_ID = LAD.Leave_ID where la.Emp_ID = @Emp_Id and ((@Pre_Date_WeekOff >= lad.From_Date and @Pre_Date_WeekOff <= lad.To_Date) or ( @Next_Date_WeekOff >= lad.From_Date  and   @Next_Date_WeekOff <= lad.To_Date)) and Approval_Status = 'A'  order by LM.Weekoff_as_leave  desc		
																--	end
																--Changed By Nilay:26-Mar-2015  (due to Bhaskar issues)---
																																			
															end									 								
						 							end		
						 						ELSE IF @Cnt_Leave_Pre_Next_Holiday = 2
													BEGIN												
														/*THIS CONDITION ADDED BY NIMESH ON 31-AUG-2016*/
														/*I.E. IF USER TAKES OD ON SAT AND MON THEN SUN(WEEKOFF) SHOULD NOT BE CANCELED*/
														IF EXISTS(SELECT 1 FROM T0120_LEAVE_APPROVAL LA WITH (NOLOCK)  INNER JOIN T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK)  on LA.Leave_Approval_ID = LAD.Leave_Approval_ID 
																	INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK)  ON LAD.LEAVE_ID=LM.LEAVE_ID
																	LEFT OUTER JOIN T0150_LEAVE_CANCELLATION LC WITH (NOLOCK)  ON LA.Leave_Approval_ID = LC.Leave_Approval_id and LC.Is_Approve = 1 
																					AND LC.For_date=@Pre_Date_WeekOff AND LC.For_date=@Next_Date_WeekOff
																		WHERE	LA.Emp_ID = @Emp_Id AND (
																						(@Pre_Date_WeekOff >= LAD.From_Date and @Pre_Date_WeekOff <= LAD.To_Date) or 
																						( @Next_Date_WeekOff >= LAD.From_Date  and   @Next_Date_WeekOff <= LAD.To_Date)
																					) AND Approval_Status = 'A' and LC.Leave_Approval_id is null AND LEAVE_TYPE='Company Purpose')
														BEGIN
															SELECT @Cnt_Leave_Pre_Next_Holiday = COUNT(1) FROM T0120_LEAVE_APPROVAL LA  WITH (NOLOCK) 
																	INNER JOIN T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK)  on LA.Leave_Approval_ID = LAD.Leave_Approval_ID 
																	INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK)  ON LAD.LEAVE_ID=LM.LEAVE_ID
																	LEFT OUTER JOIN T0150_LEAVE_CANCELLATION LC WITH (NOLOCK)  ON LA.Leave_Approval_ID = LC.Leave_Approval_id and LC.Is_Approve = 1 
																				AND LC.For_date=@Pre_Date_WeekOff AND LC.For_date=@Next_Date_WeekOff
																		WHERE	LA.Emp_ID = @Emp_Id AND (
																						(@Pre_Date_WeekOff >= LAD.From_Date and @Pre_Date_WeekOff <= LAD.To_Date) or 
																						( @Next_Date_WeekOff >= LAD.From_Date  and   @Next_Date_WeekOff <= LAD.To_Date)
																					) AND Approval_Status = 'A' and LC.Leave_Approval_id is null 
																					AND LEAVE_TYPE='Company Purpose'

															IF @Cnt_Leave_Pre_Next_Holiday <> 0
																set @Chk_Leave_Setting_For_Leave_As_Holiday = 0
													
													
															IF (NOT EXISTS(SELECT 1 FROM T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) 
																	INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK)  ON LT.LEAVE_ID=LM.LEAVE_ID																
																		WHERE	LT.Emp_ID = @Emp_Id AND LT.FOR_DATE=@For_Date AND LEAVE_TYPE='Company Purpose' AND LEAVE_USED > 0))															
																AND @Cnt_Leave_Pre_Next_Holiday = 2

																SET @Cnt_Leave_Pre_Next_Holiday = 1

														END													
													END	
						 						
												
												if exists (select 1 from dbo.T0120_LEAVE_APPROVAL LA WITH (NOLOCK)  inner join dbo.T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK)  on LA.Leave_Approval_ID = LAD.Leave_Approval_ID inner join dbo.T0040_LEAVE_MASTER LM  WITH (NOLOCK) on lm.Leave_ID = LAD.Leave_ID where la.Emp_ID = @Emp_Id and ((@For_date >= lad.From_Date and @For_date <= lad.To_Date) ) and Approval_Status = 'A') and exists (select 1 from dbo.T0140_LEAVE_TRANSACTION LT  WITH (NOLOCK) where  lT.Emp_ID = @Emp_Id and Lt.For_Date = @For_date and (lt.Leave_Used <> 0 OR lt.CompOff_Used <> 0 ))  and isnull(@Is_Cancel_Holiday,0)<> 9
													begin	
														--if @chk_leave_setting_for_leave_as_holiday = 1
														--	begin
																Set @Is_Cancel =1 
														--	end
														--else	
														--	begin
														--		set @Is_Cancel = 0
														--	end
														
																--For Cancel Holiday	--Ankit 08012016
																set @varCancelHoliday_Date = @varCancelHoliday_Date + ';' +  cast(@For_Date as varchar(11))
													end												
												else if @cnt_leave_pre_next_holiday >= 2 and @chk_leave_setting_for_leave_as_holiday = 1 and isnull(@Is_Cancel_Holiday,0)<> 9
										 			begin
										 				Set @Is_Cancel = 1 
										 				
										 				--For Cancel Holiday	--Ankit 08012016
														set @varCancelHoliday_Date = @varCancelHoliday_Date + ';' +  cast(@For_Date as varchar(11))	
													end
												else if @temp_cnt_leave_pre_next_holiday >= 2 and @chk_leave_setting_for_leave_as_holiday = 0
													begin
														set @Is_Cancel = 0
													end
												else if @genral_Cancel_Holiday = 1 and  @Is_Leave_Cal = 0 and @chk_leave_setting_for_leave_as_holiday = 1 and isnull(@Is_Cancel_Holiday,0)<> 9
													begin	
														Set @Is_Cancel = 1  
														
														--For Cancel Holiday	--Ankit 08012016
														set @varCancelHoliday_Date = @varCancelHoliday_Date + ';' +  cast(@For_Date as varchar(11))	
													end
												else if @genral_Cancel_Holiday = 1 and  @Is_Leave_Cal = 0 and @temp_cnt_leave_pre_next_holiday = 0 and @cnt_leave_pre_next_holiday = 0 and isnull(@Is_Cancel_Holiday,0)<> 9
													begin	
														Set @Is_Cancel = 1  
														
														--For Cancel Holiday	--Ankit 08012016
														set @varCancelHoliday_Date = @varCancelHoliday_Date + ';' +  cast(@For_Date as varchar(11))	
													end
												ELSE IF @Genral_Cancel_Holiday = 1 AND ISNULL(@Reverse_Leave_Cancel_Sett,0) = 1	/* Ankit 16032016 */
													BEGIN
														DECLARE @LeaveID		NUMERIC
														DECLARE @CountLeaveAprID	NUMERIC
														
														SELECT	@LeaveID = LAD.Leave_ID 
																,@CountLeaveAprID = COUNT(lad.Leave_Approval_ID)
														FROM	T0120_LEAVE_APPROVAL LA WITH (NOLOCK)  INNER JOIN T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK)  on LA.Leave_Approval_ID = LAD.Leave_Approval_ID 
																INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK)  on lm.Leave_ID = LAD.Leave_ID 
																LEFT JOIN T0150_LEAVE_CANCELLATION LC WITH (NOLOCK)  ON LA.Leave_Approval_ID = LC.Leave_Approval_id and LC.Is_Approve = 1 
														WHERE	la.Emp_ID = @Emp_Id AND 
																(  ( @Pre_Date_WeekOff >= lad.From_Date and @Pre_Date_WeekOff <= lad.To_Date) or 
																   ( @Next_Date_WeekOff >= lad.From_Date  and   @Next_Date_WeekOff <= lad.To_Date)
																) AND Approval_Status = 'A' and LC.Leave_Approval_id IS NULL AND LM.Holiday_as_leave = 0
																AND LM.Leave_Paid_Unpaid = 'P'
														GROUP BY LAD.Leave_ID 
														
														
														
														IF @CountLeaveAprID >= 2	/* CL - WO - CL : HO Not Cancel */
															BEGIN
																SET @Is_Cancel = 0;
															END
														ELSE IF EXISTS ( SELECT	1 FROM	T0120_LEAVE_APPROVAL LA WITH (NOLOCK)  inner join T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK)  on LA.Leave_Approval_ID = LAD.Leave_Approval_ID 
																				inner join T0040_LEAVE_MASTER LM WITH (NOLOCK)  on lm.Leave_ID = LAD.Leave_ID 
																				LEFT JOIN T0150_LEAVE_CANCELLATION LC WITH (NOLOCK)  ON LA.Leave_Approval_ID = LC.Leave_Approval_id and LC.Is_Approve = 1 
																			WHERE la.Emp_ID = @Emp_Id and 
																			( ( @Pre_Date_WeekOff >= lad.From_Date and @Pre_Date_WeekOff <= lad.To_Date ) or 
																				( @Next_Date_WeekOff >= lad.From_Date  and   @Next_Date_WeekOff <= lad.To_Date )
																			) and Approval_Status = 'A' and LC.Leave_Approval_id is null AND LM.Holiday_as_leave = 0
																			and (LM.Leave_Type = 'Company Purpose' or LM.Default_Short_Name = 'COMP')
																		) 
															BEGIN	/* CL - WO - COMP/Cmp Purpose : HO Not Cancel */
																SET @Is_Cancel = 0;
															END	
														ELSE IF EXISTS ( SELECT	1 FROM	T0120_LEAVE_APPROVAL LA WITH (NOLOCK)  inner join T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK)  on LA.Leave_Approval_ID = LAD.Leave_Approval_ID 
																				inner join T0040_LEAVE_MASTER LM WITH (NOLOCK)  on lm.Leave_ID = LAD.Leave_ID 
																				LEFT JOIN T0150_LEAVE_CANCELLATION LC WITH (NOLOCK)  ON LA.Leave_Approval_ID = LC.Leave_Approval_id and LC.Is_Approve = 1 
																			WHERE la.Emp_ID = @Emp_Id and 
																			( ( @Pre_Date_WeekOff >= lad.From_Date and @Pre_Date_WeekOff <= lad.To_Date ) or 
																				( @Next_Date_WeekOff >= lad.From_Date  and   @Next_Date_WeekOff <= lad.To_Date )
																			) and Approval_Status = 'A' and LC.Leave_Approval_id is null AND LM.Holiday_as_leave = 0
																			AND LM.Leave_Paid_Unpaid = 'U'
																		) 
															BEGIN	/* CL - WO - LWP (Unpaid Leave) : HO Cancel  */
																set @varCancelHoliday_Date = @varCancelHoliday_Date + ';' +  cast(@For_Date as varchar(11))
															END
													END	
												else
													begin
														Set @Is_Cancel = 0
													end
																										
											end
									end
																
									--while @For_date <= @H_To_Date  and @For_Date <= @H_To_Date--Nikunj 10-Sep-2010
									--Begin
										
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
															insert into #Emp_Holiday (Emp_ID,Cmp_ID,For_Date,H_Day,is_Half_Day)
															select @Emp_ID ,@Cmp_Id,@For_date,@H_Days,@Is_Half
															
														end	
												END
											Else if @Join_Date > @For_date And @Allowed_Full_WeekOff_MidJoining = 0
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
														 
															insert into #Emp_Holiday (Emp_ID,Cmp_ID,For_Date,H_Day,is_Half_Day)
															select @Emp_ID ,@Cmp_Id,@For_date,@H_Days,@Is_Half
															
														end	
												end		
											--else If @is_Cancel_Holiday = 1
											--	begin
											--		set @Cancel_Holiday = @Cancel_Holiday + @H_Days
											--	end 		
											
										End	
										
									--Set @For_date = Dateadd(d,1,@For_date)			
									
									--End
							--End	
					end1:		
						Set @For_Date = dateadd(d,1,@For_Date)
						 
						
						end 
						
				Fetch next from curHoliday into @H_From_Date,@H_To_Date,@Is_Half,@Is_P_Comp,@is_Fix
			end
	close curHoliday	
	deallocate curHoliday	

--- Prakash Patel 07012015 ---

IF @Type = 0
	Begin
		set @StrHoliday_Date=@varHoliday_Date
		--For Cancel Holiday	--Ankit 08012016
		SET @varCancelHoliday_Date = @varCancelHoliday_Date 
		RETURN
	End 
Else if @Type = 1
	Begin
		Select @varHoliday_Date
	End
	


