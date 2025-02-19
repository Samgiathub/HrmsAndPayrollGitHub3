
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_CALCULATE_EARLY_DEDUCTION]
	@emp_Id			numeric
	,@Company_Id		numeric
	,@Month_St_Date		datetime
	,@Month_End_Date	datetime
	,@Early_Sal_Dedu_Days numeric(18,1) output
	,@Early_Sal_Dedu_Days_cutoff NUMERIC(18, 1) OUTPUT -- added by tejas at 17092024
	,@Total_EarlyMark		int  output
	,@Total_Early_Sec	numeric output
	,@Increment_ID		numeric 
	,@StrWeekoff_Date varchar(max)='' -- Added by Hardik 10/09/2012
	,@StrHoliday_Date varchar(max)='' -- Added by Hardik 10/09/2012
	,@Return_Record_Set	numeric =0
	,@var_Return_Early_Date	varchar(1000) ='' output
	,@Temp_Extra_Count	AS NUMERIC(18,0) = 0	--For Extra Exemption in Late/Earlly Panalaty Days  --Ankit 29102015
	,@Absent_Date_String	VARCHAR(max) = '' -- Added by Nilesh Patel on 30112018
	,@total_count_all_incremnet NUMERIC(18,0) = 0 -- Added By Jimit 07112019
	,@Mid_Inc_Early_Mark_Count Numeric(18,0) = 0
AS
	
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	DECLARE @Out_Date			datetime
	DECLARE @Shift_End_Time		varchar(10)
	DECLARE @Shift_End_DateTime	datetime
	DECLARE @Curr_Month_LMark	numeric (18,1)
	DECLARE @Curr_Month_LMark_WithOut_Exemption	numeric (18,1)
	DECLARE @EarlyMark_BF		numeric(18,1)
	DECLARE @var_Shift_End_Date	varchar(20)
	DECLARE @numWorkingHoliday	numeric(18,1)
	DECLARE @varWeekOff_Date	varchar(500)
	DECLARE @dtAdjDate			datetime
	DECLARE @TempFor_Date		smalldatetime
	DECLARE @WeekOff			varchar(20)
	DECLARE @dtHoliday_Date		datetime
	DECLARE @varHoliday_Date	varchar(100)
	DECLARE @Emp_Early_Limit	varchar(10)
	DECLARE @Early_Limit_Sec	numeric
	DECLARE @Early_Adj_Day		int
	DECLARE @Division_ID		numeric 
	DECLARE @Is_Early_Mark		Numeric	
	DECLARE @Early_Dedu_Days	numeric(5,1)
	DECLARE @Early_Dedu_Type	varchar(10)
	DECLARE @numPresentDays		numeric(12,1)
	DECLARE @month				numeric
	DECLARE @Early_With_leave   numeric(1,0)
	DECLARE @Year				numeric
	DECLARE @Is_Early_CF		numeric
	DECLARE @Early_CF_Reset_On	varchar(50)
	DECLARE @Shift_End_Time_Half_Day 	varchar(10)
	DECLARE @is_Half_Day 		tinyint
	DECLARE @RoundingValue 		numeric(18,2) -- added by mitesh on 08/11/2011	
	DECLARE @Early_Exempted_Days numeric(5,2) --Alpesh 07-Oct-2011
	DECLARE @Is_Early_calc_On_HO_WO TINYINT
	DECLARE @Temp_Branch_ID		NUMERIC
	DECLARE @Early_Exempted_limit varchar(10) -- added by mitesh on 24/01/2012
	DECLARE @Early_Exempted_limit_sec numeric -- added by mitesh on 24/01/2012
	DECLARE @Shift_Exemption_End_DateTime datetime -- added by mitesh on 24/01/2012
	--Alpesh 19-Jul-2012
	DECLARE @Max_Early_Limit	varchar(50)	
	DECLARE @Shift_Max_Early_Time datetime
	DECLARE @In_Date			datetime	
	DECLARE @Shift_St_Time		varchar(10)
	DECLARE @var_Shift_St_Date	varchar(20)
	DECLARE @Shift_St_Time_Half_Day varchar(10)
	--- End ---
	DECLARE @Cutoff_date AS DATETIME
DECLARE @cutoff_month_st_date AS DATETIME
DECLARE @EMark_After_Cutoff NUMERIC(18, 2)


	----Extra Exemption	--Ankit 03112015
	DECLARE @Shift_Time_Sec		NUMERIC(18,0)	
	DECLARE @Working_Time_Sec	NUMERIC(18,0)	
	DECLARE @Extra_exemption_limit VARCHAR(10)
	DECLARE @Extra_Count_Exemption NUMERIC(18,2)
	DECLARE @Extra_Exemption AS NUMERIC(18,0)
	DECLARE @HalfDayDate varchar(500)
	DECLARE @Shift_ID numeric(18,0);
	
	
	SET @Extra_Exemption = 0
	SET @Shift_Time_Sec = 0
	SET @Working_Time_Sec = 0
	SET @Extra_Count_Exemption = 0
	SET @Extra_exemption_limit = 0
	
	----Extra Exemption
	set @EMark_After_Cutoff = 0
SELECT @cutoff_month_st_date = DATEADD(month, DATEDIFF(month, 0, @Month_End_Date), 0)

SELECT @Cutoff_date = cutoff_date
FROM T0200_MONTHLY_SALARY
WHERE MONTH(Month_End_Date) = month(dateadd(m, - 1, @Month_End_Date))
	AND year(Month_End_Date) = Year(dateadd(m, - 1, @Month_End_Date))
	AND Emp_ID = @Emp_Id
	AND cutoff_date <> Month_End_Date
	

	SET @Curr_Month_LMark_WithOut_Exemption = 0
 	SET @Curr_Month_LMark	= 0
	SET @numWorkingHoliday	= 0
	SET @varWeekOff_Date	= '' 
	SET @varHoliday_Date	= ''
	SET @EarlyMark_BF = 0
	SET @Early_Dedu_Days =0
	SET @Total_Early_Sec =0
	SET @Month	= Month(@Month_st_Date)
	SET @Year	= Year(@Month_st_Date)
	SET @var_Return_Early_Date = ''
	SET @RoundingValue = 0
	SET @Is_Early_calc_On_HO_WO = 0
	
	-- Added by nilesh on  03-Feb-2018 Add For GrindMaster -- Wrong Branch consider in case of tansfer branch
    Select TOP 1 @Increment_ID = Increment_ID 
		 From T0095_INCREMENT WITH (NOLOCK) Where Increment_Effective_Date <= @Month_End_Date and Emp_ID = @Emp_ID 
    order BY Increment_Effective_Date DESC
		
	select @Is_Early_Mark = isnull(Emp_Early_Mark,0) ,@Emp_Early_Limit = isnull(Emp_Early_Limit,'00:00'),@Division_ID =Branch_ID,
		   @Early_Dedu_Type = Early_Dedu_Type
	from T0095_Increment I WITH (NOLOCK) Where I.Emp_ID = @emp_ID and Increment_Id =@Increment_ID	
	
	
	CREATE TABLE #Absent_Dates  -- Added by Gadriwala Muslim 25062015 - Start
	(
		Absent_date DATETIME
	)
	
	IF @Absent_Date_String <> ''
		BEGIN
			INSERT INTO #Absent_Dates(Absent_date)
			SELECT data FROM dbo.Split(@Absent_Date_String,'#')
		END	

	select 
			@Early_Adj_Day =  isnull(Early_Adj_Day,0),
			@Early_Dedu_Days = isnull(Early_Deduction_Days,0),
			@Early_CF_Reset_On = isnull(Early_CF_Reset_On,''),	
			@Is_Early_CF = isnull(Is_Early_CF,0),
			@Early_With_leave =Early_with_Leave,
			@Early_Exempted_Days = Isnull(Early_Count_Exemption,0),
			@RoundingValue	= ISNULL(Early_Hour_Upper_Rounding,0),		
			@Early_Exempted_limit  = ISNULL(early_exemption_limit,'00:00'),
			@Max_Early_Limit = ISNULL(Max_Early_Limit,'00:00')	--Alpesh 19-Jul-2012
	from	T0040_General_Setting WITH (NOLOCK)
	where	Cmp_ID = @company_Id and @Division_ID = Branch_id 
			and For_date = (
							select	max(for_date) 
							From	T0040_General_Setting WITH (NOLOCK)
							where	Cmp_ID = @Company_ID and For_Date <=@Month_end_Date and  Branch_id = @Division_ID
							)
		--end
		
		
	select @Early_Limit_Sec	= dbo.F_Return_Sec(@Emp_Early_Limit)				
	select @Early_Exempted_limit_sec	= dbo.F_Return_Sec(@Early_Exempted_limit)				
	
	CREATE TABLE #Early_Data
	(
		Emp_ID		numeric ,
		Company_ID	numeric,
		Month		numeric,
		Year		numeric,
		Balance_BF	numeric,
		Curr_M_Early	numeric,
		Total_Early	numeric,
		To_Be_Adj	numeric,
		Leave_ID	numeric,
		Leave_Bal		numeric(5,1),
		Adj_Again_Leave	numeric,
		Dedu_Leave_Bal	numeric(5,1),
		Adj_Fm_Sal	numeric,
		Deduct_From_Sal	numeric(5,1),
		Total_Adj		numeric(5,1),
		Balance_CF		numeric 		
	)

	IF Object_ID('tempdb..#data') IS NUll
		BEGIN			
			CREATE TABLE #EMP_CONS
			(
				EMP_ID NUMERIC,
				BRANCH_ID NUMERIC,
				INCREMENT_ID NUMERIC
			)

			INSERT INTO #EMP_CONS VALUES (@emp_Id, @Division_ID, @Increment_ID)
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
			   Working_Hrs_End_Time tinyint default 0, --Hardik 14/02/2014
			   GatePass_Deduct_Days numeric(18,2) default 0 -- Add by Gadriwala Muslim 05012014
		   )    

		   EXEC P_GET_EMP_INOUT @Company_Id, @Month_St_Date, @Month_End_Date
		END

		
	
	IF @Is_Early_Mark = 1 
		BEGIN
			IF @Is_Early_CF =1 and CHARINDEX(CAST('#'+ @Month + '#' as varchar(10)),@Early_CF_Reset_On)>0
				BEGIN
					--SELECT  @EarlyMark_BF =  isnull(Closing,0) FROM  LMark_Transaction  
					--where emp_id = @emp_Id and company_Id = @company_Id
					--				and for_date = (select max(for_date) from LMark_Transaction
					--				where emp_id = @emp_Id and  company_Id = @Company_Id
					--				and for_Date <=  @Month_St_Date )
					SET @EarlyMark_BF = 0
				END

				SELECT	Shift_ID, Shift_St_Time, Shift_End_Time 
				INTO	#SHIFT_MASTER
				FROM	T0040_SHIFT_MASTER WITH (NOLOCK)
				WHERE	CMP_ID=@Company_Id AND Inc_Auto_Shift=1


			
			DECLARE @Leave_Assign_As varchar(max),
					@Half_Leave_Date as datetime,
					@Leave_Out_Time as datetime,
					@Leave_In_Time as datetime,
					@For_Date DateTime
				
			DECLARE curEarlyOut CURSOR FOR
			SELECT	For_Date,In_Time, OUT_Time
			from	#Data D 
					LEFT OUTER JOIN #Absent_Dates AD on D.For_Date = AD.Absent_date
			where	NOT EXISTS(SELECT 1 FROM T0150_EMP_INOUT_RECORD EIO WITH (NOLOCK)
								WHERE	EIO.Emp_ID=D.Emp_Id AND isnull(Late_Calc_Not_App,0) <> 0 AND In_Time=D.In_Time 
								--AND EIO.Chk_By_Superior <> 2 AND EIO.Reason <> ''		--COMMENTED BY RAMIZ ON 02/05/2019 , AS DATA WAS COMING WRONG, SO IT IS VALIDATED INSIDE CURSOR
								AND ((Chk_By_Superior = 2 And Reason = '') or (Chk_By_Superior = 1 and Reason <> ''))
							   )
					AND D.EMP_iD = ISNULL(@emp_Id , D.EMP_ID) AND Absent_date IS NULL and D.For_date >= @Month_St_Date and  D.For_date <= @Month_End_Date		--ADDED BY RAMIZ ON 03/01/2018
			OPEN curEarlyOut
			FETCH NEXT FROM curEarlyOut INTO @For_Date,@In_Date,@Out_Date	--Alpesh 19-Jul-2012
			WHILE @@FETCH_STATUS = 0
				BEGIN
					-- Commented by Hardik 10/09/2012
					--SET @StrWeekoff_Date = ''
					--SET @StrHoliday_Date = ''
					
					
					SELECT	@Is_Early_calc_On_HO_WO = Is_Early_Calc_On_HO_WO,
							@Is_Early_Mark = Is_Late_Mark, 
							@RoundingValue = ISNULL(Early_Hour_Upper_Rounding,0) 
					FROM	T0040_GENERAL_SETTING G WITH (NOLOCK)
							INNER JOIN (
											SELECT	MAX(For_Date) AS For_Date 
											FROM	T0040_GENERAL_SETTING  WITH (NOLOCK)   
											WHERE	cmp_id = @Company_Id AND For_Date <=@Month_End_Date AND Branch_ID=@Division_ID
										)  G1 ON G.For_Date=G1.For_Date
					WHERE	Branch_ID = @Division_ID AND Cmp_ID = @Company_Id 

					-- Commented by Hardik 10/09/2012  	
					--Exec SP_EMP_WEEKOFF_DATE_GET @Emp_Id,@Company_Id,@Month_St_Date,@Month_End_Date,null,null,0,'',@StrWeekoff_Date output,0,0
					--EXEC SP_EMP_HOLIDAY_DATE_GET @Emp_Id,@Company_Id, @Month_St_Date, @Month_End_Date,null, NULL, 0, @StrHoliday_Date OUTPUT,0, 0, 0, @Temp_Branch_ID,@StrWeekoff_Date  

					/*Commented by Nimesh 21 May, 2015
					------Hasmukh for Late effect or not on WO HO 110711 -----------
					select @Shift_End_Time = T0040_shift_MAster.Shift_End_Time,@Shift_St_Time = T0040_shift_MAster.Shift_St_Time	--Alpesh 19-Jul-2012      
						from T0100_emp_shift_Detail,T0040_shift_MAster where T0100_emp_shift_Detail.Cmp_ID = @Company_Id  and emp_id = @emp_id  
						  and for_date in (select max(for_date) from T0100_emp_shift_Detail   
						  where Cmp_ID = @Company_Id  and for_date <= @Out_Date  
						   and emp_id = @emp_id)   
						 and T0100_emp_shift_Detail.shift_id = T0040_shift_MAster.shift_id  
						 and T0100_emp_shift_Detail.Cmp_ID = T0040_shift_MAster.Cmp_ID   
					*/
							
					--Added by Nimesh 20 April, 2015  
					SET @Shift_ID = NULL;
					SET @Shift_ID = dbo.fn_get_Shift_From_Monthly_Rotation(@Company_Id, @emp_Id, @For_Date);
					
					--SELECT	@Shift_End_Time= SM.Shift_End_Time,@Shift_St_Time=SM.Shift_St_Time
					--FROM	T0040_SHIFT_MASTER SM
					--WHERE	SM.Cmp_ID=@Company_Id AND SM.Shift_ID=@Shift_ID
					
					/*The following code added by Nimesh On 23-Aug-2018 (Auto Shift Scenario does not working in Late Early Mark Report)*/
					IF EXISTS(SELECT 1 FROM #SHIFT_MASTER WHERE SHIFT_ID=@Shift_ID)
						BEGIN
							SELECT	TOP 1 @Shift_ID = Shift_ID 
							FROM	#SHIFT_MASTER
							ORDER BY ABS(DATEDIFF(S, @In_Date, @For_Date + Shift_St_Time)) ASC
						END
				
					--Added by Nimesh 21 May, 2015
					SELECT	@Shift_End_Time = SM.Shift_End_Time,@Shift_St_Time=SM.Shift_St_Time,
							@is_Half_Day=isnull(SM.Is_Half_Day,0),@Shift_End_Time_Half_Day = isnull(SM.Half_End_Time,'00:00'),
							@Shift_St_Time_Half_Day = isnull(SM.Half_St_Time,'00:00')
					FROM	T0040_SHIFT_MASTER SM WITH (NOLOCK)
					WHERE	SM.Cmp_ID=@Company_Id AND SM.Shift_ID=@Shift_ID			
					--End Nimesh
								

					--Changed by rohit on 17102013
					--SET @var_Shift_End_Date = cast(@Out_Date as varchar(11)) + ' '  + @Shift_End_Time
					IF @Shift_St_Time >@Shift_End_Time
						SET @var_Shift_End_Date = CAST(@Out_Date as varchar(11)) + ' '  + @Shift_End_Time
					ELSE
						SET @var_Shift_End_Date = CAST(@In_Date as varchar(11)) + ' '  + @Shift_End_Time
					--Ended by rohit on 17102013	  
					
					SET @var_Shift_St_Date = CAST(@In_Date as varchar(11)) + ' '  + @Shift_St_Time	--Alpesh 19-Jul-2012      

					SET @Shift_End_DateTime = CAST(@var_Shift_End_Date as datetime)  
					SET @Shift_Exemption_End_DateTime = DATEADD(s,@Early_Exempted_limit_sec*-1,@Shift_End_DateTime)  	
					SET @Shift_Max_Early_Time = DATEADD(s,dbo.F_Return_Sec(@Max_Early_Limit)*-1,@Shift_End_DateTime)	--Alpesh 19-Jul-2012			
					SET @Shift_End_DateTime = DATEADD(s,@Early_Limit_Sec*-1,@Shift_End_DateTime)  				
								
					-----Extra Exemption
					SET @Working_Time_Sec = 0
					SET @Shift_Time_Sec = 0
					SET @Working_Time_Sec = Datediff(s,@In_Date,@Out_Date) 
					SET @Shift_Time_Sec = Datediff(S,@Shift_St_Time,@Shift_End_Time) 
															
					IF (@Shift_Time_Sec - @Working_Time_Sec) > 0 
						BEGIN
							IF dbo.F_Return_Sec(@Extra_exemption_limit) >= (@Shift_Time_Sec - @Working_Time_Sec)
								BEGIN
									IF @Extra_Count_Exemption >  @Temp_Extra_Count
										SET @Extra_Exemption = 1			
									ELSE
										SET @Extra_Exemption = 0			
								END		
							ELSE
								SET @Extra_Exemption = 0			
						END
					ELSE
						SET @Extra_Exemption = 0			
					
					--Extra Exemption								
					If @Is_Early_Mark = 1
						Begin
							IF @Is_Early_calc_On_HO_WO = 0
								BEGIN		
									IF CHARINDEX(CAST(@Out_Date as varchar(11)),@StrWeekoff_Date,0) <> 0 OR CHARINDEX(CAST(@Out_Date AS VARCHAR(11)),@StrHoliday_Date,0) <> 0 
										SET @Out_Date = @Shift_End_DateTime
								END
						End
					--Hasmukh for Late effect or not on WO HO 110711 -----------
								
					--- Added by Mitesh 08/08/2011 ## Start ## ----								
					DECLARE @Is_Cancel_Early_Out tinyint
					
					SET @Is_Cancel_Early_Out = 0
					SELECT	TOP 1 @Is_Cancel_Early_Out =isnull(Is_Cancel_Early_Out,0)
					FROM	dbo.T0150_Emp_Inout_Record WITH (NOLOCK)
					WHERE	Emp_ID =@emp_id AND For_Date = CONVERT(nvarchar,@Out_Date,106)
							--AND Chk_By_Superior=1 
							--AND Chk_By_Superior <> 0 --Changed By Ramiz on 04/04/2016 as now Chk_By_Superior = 2 is also added
							--AND ((Chk_By_Superior = 2 AND Reason = '') Or (Chk_By_Superior <> 2 AND Reason <> ''))	--CONDITION CHANGED BY RAMIZ ON 02/05/2019 , DISCUSSED WITH HARDIK BHAI
							AND ((Chk_By_Superior = 2 And Reason = '') or (Chk_By_Superior = 1 and Reason <> ''))
					ORDER BY Is_Cancel_Early_Out DESC --order by change by hasmukh 25022013
								
					/*Commented by Nimesh 21 May, 2015
					--- Added by Mitesh 08/08/2011 ## End ## ----
					
					select @Shift_End_Time = dbo.T0040_shift_MAster.Shift_End_Time, @is_Half_Day=isnull(dbo.T0040_shift_MAster.Is_Half_Day,0)
						,@Shift_End_Time_Half_Day = isnull(dbo.T0040_shift_MAster.Half_End_Time,'00:00'),@Shift_St_Time_Half_Day = isnull(dbo.T0040_shift_MAster.Half_St_Time,'00:00') --Alpesh 19-Jul-2012
							from dbo.T0100_emp_shift_Detail,dbo.T0040_shift_MAster where dbo.T0100_emp_shift_Detail.Cmp_ID = @company_id  and emp_id = @emp_id
									and for_date in (select max(for_date) from dbo.T0100_emp_shift_Detail 
									where Cmp_ID = @company_id 	and for_date <= @Out_Date
										and emp_id = @emp_id) 
								and dbo.T0100_emp_shift_Detail.shift_id = dbo.T0040_shift_MAster.shift_id
								and dbo.T0100_emp_shift_Detail.Cmp_ID = dbo.T0040_shift_MAster.Cmp_ID 
					*/
		
					----Added by Nimesh 21 May, 2015
					--SELECT	@Shift_End_Time = SM.Shift_End_Time, @is_Half_Day=isnull(SM.Is_Half_Day,0)
					--		,@Shift_End_Time_Half_Day = isnull(SM.Half_End_Time,'00:00'),@Shift_St_Time_Half_Day = isnull(SM.Half_St_Time,'00:00')
					--FROM	T0040_SHIFT_MASTER SM
					--WHERE	SM.Cmp_ID=@Company_Id AND SM.Shift_ID=@Shift_ID			

					
					SET @HalfDayDate = NULL;
					
					EXEC dbo.GET_HalfDay_Date @Company_Id,@Emp_ID,@Month_st_Date,@Month_End_Date,0,@HalfDayDate output
					
					IF(CHARINDEX(CONVERT(NVARCHAR(11),@Out_Date,109),@HalfDayDate) > 0) -- Added by Mitesh
						BEGIN
							IF @is_Half_Day = 1
								BEGIN
									SET @var_Shift_St_Date = cast(@In_Date as varchar(11)) + ' '  + @Shift_St_Time_Half_Day		--Alpesh 19-Jul-2012
									SET @var_Shift_End_Date = cast(@Out_Date as varchar(11)) + ' '  + @Shift_End_Time_Half_Day
								END
							ELSE
								BEGIN
									SET @var_Shift_St_Date = cast(@In_Date as varchar(11)) + ' '  + @Shift_St_Time		--Alpesh 19-Jul-2012
									SET @var_Shift_End_Date = cast(@Out_Date as varchar(11)) + ' '  + @Shift_End_Time
								END
						END
					ELSE
						BEGIN
							SET @var_Shift_St_Date = cast(@In_Date as varchar(11)) + ' '  + @Shift_St_Time	--Alpesh 19-Jul-2012
							--SET @var_Shift_End_Date = cast(@Out_Date as varchar(11)) + ' '  + @Shift_End_Time
							if @Shift_St_Time >@Shift_End_Time
								SET @var_Shift_End_Date = cast(@Out_Date as varchar(11)) + ' '  + @Shift_End_Time
							ELSE
								SET @var_Shift_End_Date = cast(@In_Date as varchar(11)) + ' '  + @Shift_End_Time
							-- Ended by rohit on 17102013	
						END
								
								
					--SET @var_Shift_End_Date = cast(@Out_Date as varchar(11)) + ' '  + @Shift_End_Time
					
					SET @Shift_End_DateTime = cast(@var_Shift_End_Date as datetime)
					SET @Shift_Exemption_End_DateTime = dateadd(s,@Early_Exempted_limit_sec*-1,@Shift_End_DateTime)
					SET @Shift_Max_Early_Time = dateadd(s,dbo.F_Return_Sec(@Max_Early_Limit)*-1,@Shift_End_DateTime)	--Alpesh 19-Jul-2012
					SET @Shift_End_DateTime = dateadd(s,@Early_Limit_Sec*-1,@Shift_End_DateTime)
					
					-- Start half day leave condition added by mitesh on 23/01/2012
					-- if Firt half day leave is there than it will not considered late mark
					
					DECLARE @is_half_day_Leave tinyint
					DECLARE @is_Full_day_Leave tinyint

					SET @is_half_day_Leave = 0
					SET @is_Full_day_Leave = 0
													
					DECLARE @fr_dt as datetime
					--SET @fr_dt = cast(@Out_Date as date)
					SET @fr_dt = cast(convert(nvarchar(11),@Out_Date,106) + ' 00:00:00' as datetime)
					
				
					
					IF EXISTS(	SELECT	la.Leave_Approval_ID 
								FROM	T0120_LEAVE_APPROVAL la WITH (NOLOCK)
										INNER JOIN T0130_LEAVE_APPROVAL_DETAIL lad WITH (NOLOCK) on la.Leave_Approval_ID = lad.Leave_Approval_ID
								WHERE	Emp_ID = @emp_Id AND Approval_Status = 'A'
										and (
												(
													Leave_Assign_As = 'Second Half' 
													and CASE WHEN Half_Leave_Date <> '1900-01-01 00:00:00.000' 
															THEN ISNULL(Half_Leave_Date,to_date) 
														ELSE 
															NULL 
														END = @fr_dt
												) OR	CASE WHEN Leave_In_Time <> '1900-01-01 00:00:00.000' 
															THEN  Leave_In_Time 
														ELSE 
															NULL 
														END >= @Shift_End_DateTime 
												  OR	CASE WHEN Leave_out_time <> '1900-01-01 00:00:00.000' 
															THEN Leave_out_time 
														ELSE 
															NULL 
														END <= cast(@var_Shift_St_Date as datetime) 
											  ) 
										)
						BEGIN	
							SET @is_half_day_Leave = 1		
						END
				
			
			
					-- End half day leave condition added by mitesh on 23/01/2012
					
					----Full day leave condition added by hasmukh 05032013
						
					IF EXISTS(SELECT 1 FROM T0140_LEAVE_TRANSACTION T WITH (NOLOCK) INNER JOIN T0040_LEAVE_MASTER L WITH (NOLOCK) ON T.Leave_ID=L.Leave_ID 
								WHERE T.Cmp_ID=@Company_Id AND Emp_ID = @emp_id and For_Date = @fr_dt and Leave_Used >= 1 AND Apply_Hourly = 0 )
						SET @is_Full_day_Leave = 1		
						
					-------Full day leave condition  End hasmukh 05032013-----------		
					if @Out_Date < @Shift_End_DateTime and @Is_Cancel_Early_Out = 0 and @is_half_day_Leave = 0 and @is_Full_day_Leave = 0
						BEGIN
							DECLARE @Differnce_Rounding_Early_Sec numeric
							SET @Differnce_Rounding_Early_Sec = 0
												
							IF @RoundingValue > 0 
								BEGIN
									SET @Differnce_Rounding_Early_Sec = abs(datediff(s,cast(@var_Shift_End_Date as datetime) ,@Out_Date))
									SELECT @Differnce_Rounding_Early_Sec = dbo.Pro_Rounding_Sec_HH_MM(@Differnce_Rounding_Early_Sec,@RoundingValue)
								END	
							ELSE
								SET @Differnce_Rounding_Early_Sec = abs(datediff(s,@Shift_End_DateTime ,@Out_Date))
													
							--Alpesh 19-Jul-2012 put condition for deficiate with limited period	
 							if @Out_Date < @Shift_End_DateTime and @Out_Date >= @Shift_Max_Early_Time
								BEGIN
									
									IF DATEDIFF(s,@In_Date,@Out_Date) < DATEDIFF(s,@var_Shift_St_Date,@var_Shift_End_Date)
										BEGIN
											
											IF @Extra_Exemption  = 0
												BEGIN			
												
													IF @Early_Exempted_limit_sec = 0
														SET @Curr_Month_LMark = @Curr_Month_LMark + 1 
													ELSE IF @Out_Date > @Shift_Exemption_End_DateTime 
														SET @Curr_Month_LMark = @Curr_Month_LMark + 1 	
													ELSE
														SET @Curr_Month_LMark_WithOut_Exemption = @Curr_Month_LMark_WithOut_Exemption + 1 	
												END
											ELSE
												SET @Temp_Extra_Count = @Temp_Extra_Count + 1
															
											SET @Total_Early_Sec = @Total_Early_Sec + @Differnce_Rounding_Early_Sec
											SET @var_Return_Early_Date = @var_Return_Early_Date + ';' + cast(@Out_Date as varchar(11))
										END
								END	
							ELSE
								BEGIN
									
									IF @Extra_Exemption  = 0
										BEGIN
											IF  @Early_Exempted_limit_sec = 0
											BEGIN
											IF @Cutoff_date <> '' -- Added by tejas for wonser home finance late_early deduction gat in another variable
														AND @Out_Date > @Cutoff_date
														AND @Out_Date < @cutoff_month_st_date and @Out_Date < @Shift_End_DateTime  and exists(select 1 from T0200_MONTHLY_SALARY where MONTH(Month_End_Date) =  month(dateadd(m,-1,@Month_End_Date)) 
																	and year(Month_End_Date) =  Year( dateadd(m,-1,@Month_End_Date)) and Emp_ID=@Emp_Id and cutoff_date <> Month_End_Date)  
															BEGIN
															 SET @EMark_After_Cutoff = @EMark_After_Cutoff + 1 
															END
															ELSE
																SET @Curr_Month_LMark = @Curr_Month_LMark + 1 	
													END
											ELSE IF @Out_Date > @Shift_Exemption_End_DateTime 
												SET @Curr_Month_LMark = @Curr_Month_LMark + 1 	
											ELSE
												SET @Curr_Month_LMark_WithOut_Exemption = @Curr_Month_LMark_WithOut_Exemption + 1 																
										END
									ELSE
										SET @Temp_Extra_Count = @Temp_Extra_Count + 1
													
									SET @Total_Early_Sec = @Total_Early_Sec + @Differnce_Rounding_Early_Sec
									SET @var_Return_Early_Date = @var_Return_Early_Date + ';' + cast(@Out_Date as varchar(11))												
								END
										
						END
						
						
					FETCH NEXT FROM curEarlyOut INTO @For_Date,@In_Date,@Out_Date	--Alpesh 19-Jul-2012
				END
			CLOSE curEarlyOut
			DEALLOCATE curEarlyOut
		END
		
		
		
		If @Early_Dedu_Type = 'Hour'
			BEGIN
				SET @Total_EarlyMark =0
				SET @Early_Sal_Dedu_Days =0
				set @Early_Sal_Dedu_Days_cutoff = 0
			END
		ELSE
			BEGIN
				DECLARE @Tobe_Adj numeric 
				DECLARE @Dedu_From_Sal numeric(5,1)
				DECLARE @Adj_fm_sal numeric 
				DECLARE @Balance_CF numeric 
				DECLARE @Total_Adj	numeric
				
				DECLARE @Leave_Bal			numeric(5,1)
				DECLARE @Leave_ID			numeric 
				DECLARE @Adj_Again_Leave	numeric
				DECLARE @Dedu_Leave_Bal		numeric(5,1)
				DECLARE @Leave_Tran_ID      numeric
				SET @Adj_Again_Leave = 0
				SET @Dedu_Leave_Bal	 = 0
				
				
				
				--Added By Jimit 07112019 for Kich mid increment case 
				declare @ExemptOnce as int
				--SET @Total_EarlyMark = @EarlyMark_BF + @Curr_Month_LMark - @Early_Exempted_Days  --Commented By Jimit 07112019 for Kich mid increment case 
				If   @EarlyMark_BF + @Curr_Month_LMark - @Early_Exempted_Days > 0
					Begin
						SET @Total_EarlyMark = @EarlyMark_BF + @Curr_Month_LMark - @Early_Exempted_Days --Alpesh 07-Oct-2011
							SET @ExemptOnce = 1
					End
                ELSE
				    Begin
						SET @Total_EarlyMark = @EarlyMark_BF --+ @Curr_Month_LMark -- Commented by Hardik 23/02/2021 for Redmine Id : 12433
						SET @ExemptOnce = 0
						ENd
                  --Ended

				 

				IF @Total_EarlyMark < 0 
					SET @Total_EarlyMark = 0
												
				--IF @Total_EarlyMark > 0	-- Commented by Hardik / Nilesh 03/04/2019 for Gallops client									
					SET @Total_EarlyMark = @Total_EarlyMark + @Curr_Month_LMark_WithOut_Exemption -- added by mitesh on 24/01/2012
				
				

				--Added By Jimit 07112019 for Kich mid increment case
				If @Mid_Inc_Early_Mark_Count > 0 and @ExemptOnce <> 1
					Begin
						SET @Total_EarlyMark =  @Total_EarlyMark - @Early_Exempted_Days
					END
				--Ended
				
				

				SELECT	TOP 1 @Leave_ID =l.LeavE_ID ,@For_Date= l.For_Date,@Leave_Tran_ID =l.Leave_Tran_ID,@Leave_Bal =isnull(Leave_Closing,0)  
				FROM	T0140_Leave_Transaction l WITH (NOLOCK)
						INNER JOIN ( 
									SELECT Emp_ID,max(For_Date) For_Date ,lt.Leave_Id 
									FROM	T0140_Leave_Transaction lt WITH (NOLOCK)
											INNER JOIN dbo.T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LT.leave_ID=LM.leave_ID AND ISNULL(lm.Leave_paid_Unpaid,'') ='P'
												AND lm.Leave_Type<>'Company Purpose' --and isnull(Is_Late_Adj,0) =1 
									WHERE	Emp_ID =@Emp_ID AND for_Date<=@Month_End_Date 
									GROUP BY Emp_ID ,lt.Leave_ID
									) Q ON l.leavE_ID =q.leavE_ID AND l.for_Date =q.for_Date 
				WHERE l.emp_ID =@Emp_ID 
				ORDER BY Leave_Closing DESC
					
				
				SET @Tobe_Adj = 0
				SET @Dedu_From_Sal = 0


				
				 --Added By Jimit 07112019 for Kich mid increment case 
				IF @total_count_all_incremnet > 1 
				   Begin
						Set @Total_EarlyMark = @Mid_Inc_Early_Mark_Count + @Total_EarlyMark
				   End
				Else						
					Begin
						Set @Total_EarlyMark = @Total_EarlyMark
					End
					--Ended
					

				IF @Early_Adj_Day > 0 And @Total_EarlyMark > 0
					SET @Tobe_Adj = @Total_EarlyMark - (@Total_EarlyMark % @Early_Adj_Day)
				IF @Early_Dedu_Days > 0 
					SET @Adj_fm_sal =  @Tobe_Adj
				
				
					
				IF cast(@Early_Adj_Day as int) > 0
					SELECT @Dedu_From_Sal = @Adj_fm_sal * @Early_Dedu_Days / @Early_Adj_Day 
			
				SET @Total_Adj = @Adj_fm_sal
				SET @Balance_CF = @Total_EarlyMark - @Total_Adj
				SET @Total_Early_Sec  = 0 
				SET @Early_Sal_Dedu_Days = @Dedu_From_Sal

				IF cast(@Early_Adj_Day as int) > 0
					set @Early_Sal_Dedu_Days_cutoff = @EMark_After_Cutoff * @Early_Dedu_Days / @Early_Adj_Day -- added by tejas at 17092024  
				

				IF @Return_Record_SET =1 	
					BEGIN
						SELECT *,@numPresentDays AS Present_Day FROM #Early_Data
						
						INSERT INTO #Early_Data(Emp_ID,Company_ID,Month,Year,Balance_BF,Curr_M_Early,Total_Early,To_Be_adj,Leave_ID,Leave_Bal,Adj_Again_Leave,Dedu_Leave_Bal,Adj_Fm_Sal,Total_Adj,Deduct_From_Sal,Balance_CF)
						SELECT @Emp_ID,@Company_ID,@Month,@Year,@EarlyMark_BF,(@Curr_Month_LMark + @Curr_Month_LMark_WithOut_Exemption),@Total_EarlyMark,@Tobe_Adj,@Leave_ID,@Leave_Bal,@Adj_Again_Leave,@Dedu_Leave_Bal,@Adj_fm_sal,@Total_Adj,@Dedu_From_Sal,@Balance_CF
					END 
			END
		
	
	RETURN



