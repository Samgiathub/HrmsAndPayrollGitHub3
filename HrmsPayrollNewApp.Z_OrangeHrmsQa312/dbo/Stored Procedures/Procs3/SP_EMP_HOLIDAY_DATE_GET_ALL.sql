-- =============================================
-- Author:		Nimesh Parmar
-- Create date: 17 Dec,2015
-- Description:	This procedure is used to give cancel holiday effect after getting
--				holiday detail from SP_EMP_HOLIDAY_WEEKOFF_ALL procedure.
-- =============================================
CREATE PROCEDURE [dbo].[SP_EMP_HOLIDAY_DATE_GET_ALL]
	@Constraint 		varchar(max)
	,@Cmp_ID 		numeric
	,@From_Date 		Datetime
	,@To_Date 		Datetime
	,@All_Weekoff 		BIT =0	--0 : With Cancel Weekoff; 1: All Weekoff (Without cancelling weekoff)
	,@Is_FNF	tinyint =0
	,@Is_Leave_Cal tinyint = 0
	,@Allowed_Full_WeekOff_MidJoining tinyint = 0
	,@Type numeric = 0
	,@Use_Table tinyint = 0
AS
	Set Nocount on 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON

	--select @Constraint As Constraint1,@Cmp_ID As Cmp_ID,@From_Date As From_Date,@To_Date As To_Date,@All_Weekoff As All_Weekoff,@Is_FNF AS Is_FNF,@Is_Leave_Cal AS Is_Leave_Cal,@Allowed_Full_WeekOff_MidJoining AS Allowed_Full_WeekOff_MidJoining,@Type AS Type,@Use_Table AS Use_Table
		
	IF (OBJECT_ID('tempdb..#EMP_HW_CONS') IS NULL)
		CREATE TABLE #EMP_HW_CONS
		(
			Emp_ID				NUMERIC,
			WeekOffDate			Varchar(Max),
			WeekOffCount		NUMERIC(3,1),
			CancelWeekOff		Varchar(Max),
			CancelWeekOffCount	NUMERIC(3,1),
			HolidayDate			Varchar(MAX),
			HolidayCount		NUMERIC(3,1),
			HalfHolidayDate		Varchar(MAX),
			HalfHolidayCount	NUMERIC(3,1),
			CancelHoliday		Varchar(Max),
			CancelHolidayCount	NUMERIC(3,1)
		)
		
	IF OBJECT_ID('tempdb..#EMP_HOLIDAY') IS NULL
		BEGIN		
			
			CREATE TABLE #EMP_HOLIDAY(EMP_ID NUMERIC, FOR_DATE DATETIME, IS_CANCEL BIT, Is_Half tinyint, Is_P_Comp tinyint, H_DAY numeric(3,1));
			CREATE UNIQUE CLUSTERED INDEX IX_EMP_HOLIDAY_EMPID_FORDATE ON #EMP_HOLIDAY(EMP_ID, FOR_DATE);
		END

	
	/*******EMPLOYEE WEEKOFF HOLIDAY ALL*******/
		
	IF OBJECT_ID('tempdb..#EMP_CONS') IS NULL
		BEGIN		
			CREATE TABLE #EMP_CONS(EMP_ID NUMERIC, BRANCH_ID NUMERIC, INCREMENT_ID NUMERIC);
		
			EXEC dbo.SP_RPT_FILL_EMP_CONS @Cmp_ID=@Cmp_ID, @From_Date=@From_Date, @To_Date=@To_Date, @Branch_ID=0,@Cat_ID=0, @Grd_ID=0, @Type_ID=0, @Dept_ID=0, @Desig_ID=0,@Emp_ID=0,@Constraint=@Constraint 
		END
		
		
	IF NOT EXISTS (SELECT 1 FROM #EMP_HW_CONS)
	BEGIN
		EXEC dbo.SP_EMP_HOLIDAY_WEEKOFF_ALL  @Cmp_ID, @From_Date, @To_Date, 1, @Constraint
	END
	
	DECLARE @DEFAULT_CANCEL_HOLIDAY SMALLINT

	SET @DEFAULT_CANCEL_HOLIDAY = -1
	IF OBJECT_ID('tempdb..#WH_SETTINGS') IS NOT NULL
		BEGIN
			SELECT @DEFAULT_CANCEL_HOLIDAY=CANCEL_HOLIDAY FROM #WH_SETTINGS
		END
	
	
	DECLARE @ABS_DAYS DECIMAL(9,3)
	DECLARE @WO_DAYS DECIMAL(9,3)
			
	--EXEC dbo.SP_EMP_HOLIDAY_WEEKOFF_ALL  55, @From_Date, @To_Date, @All_Weekoff, @Constraint

	DECLARE @Cancel_WO_HalfDay_Abs_Leave BIT
	SELECT	@Cancel_WO_HalfDay_Abs_Leave = Cast(IsNull(Setting_Value,0) As BIT)
	FROM	T0040_SETTING WITH (NOLOCK)
	WHERE	Setting_Name='Sandwich Policy not Applicable if Employee Present on before or after Holiday/WeekOff (QD/HF/3QD)'
			AND Cmp_ID=@Cmp_ID

	DECLARE @Max_Consecutive_Leave_Days_For_Cancel_WO TINYINT
	SELECT	@Max_Consecutive_Leave_Days_For_Cancel_WO = Cast(IsNull(Setting_Value,0) As TinyInt)
	FROM	T0040_SETTING  WITH (NOLOCK)
	WHERE	Setting_Name='Cancel Holiday/WeekOff if Leave applied for given Number of Days (Before Holiday/WeekOff)'
			AND Cmp_ID=@Cmp_ID
	DECLARE @Consecutive_Leave_Days DECIMAL(5,2)
	
	
	/*******BRANCH WISE HOLIDAY*******/

	DECLARE @Date_Diff		numeric;
	DECLARE @varHoliday_Date varchar(Max);
	DECLARE @varHoliday_PreNext_Date varchar(Max);
	DECLARE @For_Date		datetime;
	DECLARE @Is_Half		tinyint;
	DECLARE @Is_P_Comp		tinyint;
	DECLARE @H_Days			numeric(9,2);
	DECLARE @Is_Cancel		tinyint;
	DECLARE @Pre_Date_WeekOff datetime;
	DECLARE @Next_Date_WeekOff	Datetime;
	DECLARE @Branch_Id_Temp  Numeric;
	DECLARE @Genral_Cancel_Holiday tinyint;
	DECLARE @StrWeekoff_Date VARCHAR(MAX);
	DECLARE @Is_Cancel_Holiday_WO_HO_Same_Day tinyint;

	DECLARE @CancelHolidayIfOneSideAbsent tinyint

	DECLARE @NEXT_EFF_DATE DATETIME 
	SET @NEXT_EFF_DATE  = @FROM_DATE
	
	
	SET @varHoliday_Date = ''
	SET @Is_Cancel =0
	SET @Branch_Id_Temp =0 
	SET @Genral_Cancel_Holiday = 0
	SET @Is_Cancel_Holiday_WO_HO_Same_Day = 0
	 
	--select 
	DECLARE @Cnt_Leave_Pre_Next_Holiday NUMERIC(5,1)
	DECLARE @Chk_Leave_Setting_For_Leave_As_Holiday as tinyint
	DECLARE @Temp_Cnt_Leave_Pre_Next_Holiday numeric(5,1)
	DECLARE @Pre_Emp	NUMERIC;
	DECLARE @Emp_ID		NUMERIC;
	DECLARE @Branch_ID	NUMERIC;
	DECLARE @Join_Date	DATETIME;
	DECLARE @Left_Date	DATETIME;
	
	SET	@Pre_Emp = 0;
	
	DECLARE @Reverse_Leave_Cancel_Sett NUMERIC	--Ankit 16032016
	SET @Reverse_Leave_Cancel_Sett = 0
	
	DECLARE @CANCEL_REASON VARCHAR(128);
	DECLARE @LEAVE_TYPE VARCHAR(32);
	DECLARE @FH_SH_LEAVE VARCHAR(32);
	DECLARE @HO_LEAVE NUMERIC(5,2);
	DECLARE @Pre_Leave as Numeric(5,2);
	DECLARE @Next_Leave as Numeric(5,2);
	DECLARE @Pre_Leave_FHSH as Varchar(16);
	DECLARE @Next_Leave_FHSH as Varchar(16);
	DECLARE @Pre_Leave_CancelHO as tinyint;
	DECLARE @Next_Leave_CancelHO as tinyint;
	DECLARE @Pre_Leave_Type as Varchar(32);
	DECLARE @Next_Leave_Type as Varchar(32);
	
	
	SELECT @Reverse_Leave_Cancel_Sett = Setting_Value FROM T0040_SETTING WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND Setting_Name = 'Reverse Current WO/HO Cancel Policy'
	

	DECLARE curHoliday CURSOR FORWARD_ONLY FOR 
	SELECT	H.EMP_ID, E.BRANCH_ID, H.FOR_DATE, H.Is_Half,Is_P_Comp
	FROM	#EMP_HOLIDAY H INNER JOIN #EMP_CONS E ON H.EMP_ID=E.EMP_ID
	
	OPEN curHoliday 
	FETCH NEXT FROM curHoliday INTO @Emp_ID, @Branch_ID,@For_Date,@Is_Half,@Is_P_Comp
	WHILE (@@FETCH_STATUS = 0)
		BEGIN			
			IF @Is_Half = 1
				SET @H_Days = 0.5;
			ELSE	
				SET @H_Days = 1 
			
			
			SET @Is_Cancel = 0
			SET  @CANCEL_REASON = ''
			
					IF @Pre_Emp <> @Emp_ID OR (@NEXT_EFF_DATE IS NOT NULL AND  @For_Date >= @NEXT_EFF_DATE)
					BEGIN
						
						SET @Join_Date = NULL
						EXEC dbo.SP_EMP_JOIN_LEFT_DATE_GET @Emp_ID ,@Cmp_ID ,@From_Date,@To_Date,@Join_Date OUTPUT ,@Left_Date OUTPUT

						IF ISNULL(@Left_Date,'') <> '' 
							BEGIN
								IF @Left_Date < @Join_Date  
									SET @Left_Date = null	
							END
						
						SET @Pre_Emp = @Emp_ID
					 
					
							
						SELECT	@Branch_Id = Branch_ID 
						FROM	dbo.T0095_INCREMENT EI  WITH (NOLOCK)
						WHERE	Increment_ID = (
												SELECT	MAX(Increment_ID) AS Increment_ID 
												FROM	dbo.T0095_INCREMENT   WITH (NOLOCK)
												WHERE	Increment_Effective_date <= @To_Date  and Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID
												) 
								and Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID 
						
						SELECT	top 1 @Genral_Cancel_Holiday = GS.Is_Cancel_Holiday, @Is_Cancel_Holiday_WO_HO_Same_Day = GS.Is_Cancel_Holiday_WO_HO_same_day,@CancelHolidayIfOneSideAbsent = Is_Cancel_Holiday_IfOneSideAbsent
						FROM	dbo.T0040_GENERAL_SETTING GS WITH (NOLOCK) 
						WHERE	For_Date=(
											SELECT	MAX(For_Date) AS For_Date 
											FROM	dbo.T0040_GENERAL_SETTING   WITH (NOLOCK)
											WHERE	For_Date <= @To_Date  AND Cmp_ID = @Cmp_ID and Branch_ID = @Branch_Id
											) and Branch_ID = @Branch_Id and Cmp_ID = @Cmp_ID
						
						SELECT  @NEXT_EFF_DATE = MIN(FOR_DATE)
						FROM	dbo.T0040_GENERAL_SETTING   WITH (NOLOCK)
						WHERE	For_Date > @For_Date  AND Cmp_ID = @Cmp_ID and Branch_ID = @Branch_Id

						IF @DEFAULT_CANCEL_HOLIDAY > -1
							SET @Genral_Cancel_Holiday = @DEFAULT_CANCEL_HOLIDAY

								 
						IF @All_Weekoff = 1
							SET @Genral_Cancel_Holiday = 0;
						
						--IF @Join_Date > @From_Date
						--	SET @From_Date = @Join_Date
						
						SET @varHoliday_PreNext_Date = '';
						SELECT	@varHoliday_PreNext_Date = ISNULL(WeekOffDate, '') + ISNULL(HolidayDate, '') + ISNULL(OptHolidayDate, ''),
								@StrWeekoff_Date = WH.WeekOffDate
						FROM	#Emp_WeekOff_Holiday WH
						WHERE	Emp_ID=@Emp_ID
						
						if (@varHoliday_PreNext_Date IS NULL)
							set @varHoliday_PreNext_Date = '';	
						if @StrWeekoff_Date	IS NULL
							set @StrWeekoff_Date = '';
					END
					

					--IF	(CASE WHEN @Allowed_Full_WeekOff_MidJoining =1 THEN @From_Date  ELSE @Join_Date  END) > @For_Date
					--	BEGIN
					--		SET  @CANCEL_REASON = ' Allowed Full Holiday/WeekOff MidJoining (Cancel Holiday)'
					--		SET	@Is_Cancel = 1
					--		GOTO CONTINUE_LOOP;
					--	END
					--ELSE IF 
					
					IF CHARINDEX(CONVERT(VARCHAR(11),@For_Date,109),@StrWeekoff_Date,0) > 0 and @Is_Cancel_Holiday_WO_HO_Same_Day = 1
						BEGIN
							SET  @CANCEL_REASON = 'WeekOff On Same Date (Cancel Holiday)'
							SET	@Is_Cancel = 1
							GOTO CONTINUE_LOOP;
						END
					ELSE IF @All_Weekoff = 1				
						GOTO CONTINUE_LOOP;				

					--For Sandwitch Policy
					EXEC dbo.SP_RETURN_PRE_NEXT_DATE_OF_WEEKOFF @For_Date,@varHoliday_PreNext_Date,@Pre_Date_WeekOff OUTPUT,@Next_Date_WeekOff OUTPUT		

					SET @FH_SH_LEAVE = NULL;
					SET @LEAVE_TYPE = NULL
					SELECT	@FH_SH_LEAVE = IsNull(Max(A.Leave_Assign_As),''), 
							@LEAVE_TYPE=IsNull(Max(L.Leave_Type),''), 
							@HO_LEAVE = IsNull(SUM((CASE WHEN IsNull(T.CompOff_Used,0) > 0 THEN T.CompOff_Used ELSE T.Leave_Used END) - ISNULL(Leave_Encash_Days,0)),0)
					FROM	T0140_LEAVE_TRANSACTION T WITH (NOLOCK)
							INNER JOIN T0040_LEAVE_MASTER L WITH (NOLOCK) ON T.LEAVE_ID=L.LEAVE_ID
							INNER JOIN (SELECT	LA.Emp_ID,LAD.Leave_Assign_As, LAD.From_Date,LAD.To_Date
										FROM	T0120_LEAVE_APPROVAL LA  WITH (NOLOCK)
												INNER JOIN T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) ON LA.Leave_Approval_ID=LAD.Leave_Approval_ID
										WHERE	LA.Emp_ID=@EMP_ID) A ON T.EMP_ID=A.EMP_ID AND T.FOR_DATE BETWEEN A.FROM_DATE AND A.TO_DATE
					WHERE	(IsNull(Leave_Used,0) + IsNull(CompOff_Used,0)) > 0 AND FOR_DATE = @For_Date --AND L.Leave_Type <>'Company Purpose'
							AND T.Emp_ID=@EMP_ID

					
					
					IF IsNull(@FH_SH_LEAVE,'') <> ''
						BEGIN
							SET @H_Days = 1 - @HO_LEAVE							
						END
					
					IF	@H_Days <= 0 
						BEGIN								
							SET  @CANCEL_REASON = ' Full Day Leave '
							SET @H_Days = 0
							SET	@Is_Cancel = 1
							GOTO CONTINUE_LOOP;
						END

					
					
					IF @Genral_Cancel_Holiday = 1
						BEGIN
							/*Sandwich Policy Start*/
							/*Getting Total Leave used on Previous Day of WeekOff*/
							SELECT	@Pre_Leave=IsNull(SUM((CASE WHEN IsNull(T.CompOff_Used,0) > 0 THEN T.CompOff_Used ELSE T.Leave_Used END) - ISNULL(Leave_Encash_Days,0)),0), 
									@Pre_Leave_FHSH=IsNull(MAX(A.Leave_Assign_As),''), 
									@Pre_Leave_CancelHO=IsNull(Max(LM.Holiday_As_Leave),''),
									@Pre_Leave_Type = IsNull(Max(LM.Leave_Type), '')
							FROM	T0140_LEAVE_TRANSACTION T WITH (NOLOCK)
									INNER JOIN T0040_LEAVE_MASTER LM  WITH (NOLOCK)ON T.Leave_ID=LM.Leave_ID
									INNER JOIN (SELECT	LA.Emp_ID,LAD.Leave_Assign_As, LAD.From_Date,LAD.To_Date
												FROM	T0120_LEAVE_APPROVAL LA  WITH (NOLOCK)
														INNER JOIN T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) ON LA.Leave_Approval_ID=LAD.Leave_Approval_ID
												WHERE	LA.Emp_ID=@EMP_ID) A ON T.EMP_ID=A.EMP_ID AND T.FOR_DATE BETWEEN A.FROM_DATE AND A.TO_DATE
							WHERE	For_Date=@Pre_Date_WeekOff AND T.Emp_ID=@EMP_ID And (Leave_Used > 0 OR CompOff_Used > 0)--AND LM.Leave_Type <>'Company Purpose'							
							IF @Pre_Leave_FHSH = 'First Half' AND @Pre_Leave = 0.5 
								SET	@Pre_Leave = 0	--Only Second Half Leave should be considered as a consicutive to WeekOff Day

							
							/*Getting Total Leave used on Next Day of WeekOff*/
							SELECT	@Next_Leave=IsNull(SUM((CASE WHEN IsNull(T.CompOff_Used,0) > 0 THEN T.CompOff_Used ELSE T.Leave_Used END) - ISNULL(Leave_Encash_Days,0)),0), 
									@Next_Leave_FHSH=IsNull(MAX(A.Leave_Assign_As),''), 
									@Next_Leave_CancelHO=IsNull(Max(LM.Holiday_As_Leave),''),
									@Next_Leave_Type = IsNull(Max(LM.Leave_Type), '')
							FROM	T0140_LEAVE_TRANSACTION T WITH (NOLOCK)
									INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON T.Leave_ID=LM.Leave_ID
									INNER JOIN (SELECT	LA.Emp_ID,LAD.Leave_Assign_As, LAD.From_Date,LAD.To_Date
												FROM	T0120_LEAVE_APPROVAL LA  WITH (NOLOCK)
														INNER JOIN T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) ON LA.Leave_Approval_ID=LAD.Leave_Approval_ID
												WHERE	LA.Emp_ID=@EMP_ID ) A ON T.EMP_ID=A.EMP_ID AND T.FOR_DATE BETWEEN A.FROM_DATE AND A.TO_DATE
							WHERE	For_Date=@Next_Date_WeekOff AND T.Emp_ID=@EMP_ID And (Leave_Used > 0 OR CompOff_Used > 0) --AND LM.Leave_Type <>'Company Purpose'							
							IF @Next_Leave_FHSH = 'Second Half' AND @Next_Leave = 0.5 
								SET	@Next_Leave = 0  --Only First Half Leave should be considered as a consicutive to WeekOff Day
						
							
							/*If Previous Day has Leave for Second Half or Full Day and Next Day have First Half or Full Day Leave
							With Cancel Weekoff Policy*/
							IF (@Pre_Leave >= 0.5 AND @Next_Leave >= 0.5) AND @Pre_Leave_Type <> 'Company Purpose'  AND @Next_Leave_Type <> 'Company Purpose'
								AND @Pre_Leave_CancelHO = 1 AND @Next_Leave_CancelHO = 1
								BEGIN 
									SET  @CANCEL_REASON = ' Sandwich Policy : Prev: ' + @Pre_Leave_FHSH + ' - ' + Cast(@Pre_Leave as Varchar) + ', Next: ' + @Next_Leave_FHSH + ' - ' + Cast(@Next_Leave as Varchar) 
									SET	@Is_Cancel = 1							
								END
							/*If Previous Day has Leave for Second Half or Full Day and Next Day have First Half or Full Day Leave
							With the Reverse Cancel Weekoff Policy*/
							ELSE IF (@Pre_Leave >= 0.5 AND @Next_Leave >= 0.5)	/*If Previous Day has Leave for Second Half or Full Day and Next Day have First Half or Full Day Leave*/
									AND (@Pre_Leave_CancelHO = 1 OR @Next_Leave_CancelHO = 1)
									AND @Reverse_Leave_Cancel_Sett = 1
									AND (@Pre_Leave_Type <> 'Company Purpose'  OR @Next_Leave_Type <> 'Company Purpose')
								BEGIN 
									SET  @CANCEL_REASON = ' Reverse Sandwich Policy : Prev: ' + @Pre_Leave_FHSH + ' - ' + Cast(@Pre_Leave as Varchar) + ', Next: ' + @Next_Leave_FHSH + ' - ' + Cast(@Next_Leave as Varchar) 
									SET	@Is_Cancel = 1							
								END	
							/*If Employee absent on Next Day of Weekoff for First Half Or Full Day
							With Cancel Weekoff Policy*/
							ELSE IF (NOT EXISTS(SELECT 1 FROM #DATA_WOHO 
												WHERE	EMP_ID=@EMP_ID AND FOR_DATE = @Next_Date_WeekOff AND P_DAYS > 0)	--For Next: Full Day Absent
									OR EXISTS(SELECT 1 FROM #DATA_WOHO
												WHERE	EMP_ID=@EMP_ID AND FOR_DATE = @Next_Date_WeekOff 
														AND DATEDIFF(n,Shift_Start_Time, In_Time) > 239 AND IsNull(Chk_By_Superior,0)<>1))	--For Next: First Half Absent														
									AND @Next_Date_WeekOff <= GETDATE() AND @Pre_Date_WeekOff <= GETDATE()
									AND (@Pre_Leave_Type <> 'Company Purpose'  Or @Next_Leave_Type <> 'Company Purpose' )
									AND (@Next_Leave = 0 or (@Next_Leave > 0 AND @Next_Leave_CancelHO = 1))
								BEGIN
									
									--For Prev: Full/Half Leave, Next : Full/Half Day Absent
									IF @Pre_Leave >= 0.5 AND @Pre_Leave_CancelHO = 1	
										BEGIN
											SET  @CANCEL_REASON = ' Sandwich Policy 1 : Prev: ' + @Pre_Leave_FHSH + ' - ' + Cast(@Pre_Leave as Varchar) + ', Next: Full/SH Day Absent'
											SET	@Is_Cancel = 1
										END
									ELSE IF @Pre_Leave >= 0.5 AND @Pre_Leave_CancelHO = 0
										BEGIN
											--DO NOTHING
											SET	@Is_Cancel = 0;
										END
									ELSE IF NOT EXISTS(SELECT 1 FROM #DATA_WOHO		--For Prev: Full Absent, Next : Full/Half Day Absent
												WHERE EMP_ID=@EMP_ID AND FOR_DATE = @Pre_Date_WeekOff AND P_DAYS > 0)	
											OR	EXISTS(SELECT 1 FROM #DATA_WOHO		--For Prev: Second Half Absent, Next : Full/Half Day Absent
												WHERE EMP_ID=@EMP_ID AND FOR_DATE = @Pre_Date_WeekOff 
														AND (OUT_TIME IS NULL OR  DATEDIFF(n,Out_Time, Shift_End_Time) > 239)	--"OutTime Is Null" Condition for miss punch
														AND IsNull(Chk_By_Superior,0)<>1)	
										BEGIN
											
											SET  @CANCEL_REASON = ' Sandwich Policy 1 : Both Side Full/Half Day Absent '
											SET	@Is_Cancel = 1
										END							
								END
							/*If Employee absent on Previous Day of Weekoff for First Half Or Full Day
							With Cancel Weekoff Policy*/
							ELSE IF (NOT EXISTS(SELECT 1 FROM #DATA_WOHO		--For Prev: Full Day Absent
												WHERE	EMP_ID=@EMP_ID AND FOR_DATE = @Pre_Date_WeekOff AND P_DAYS > 0)	
									OR EXISTS(SELECT 1 FROM #DATA_WOHO		--For Prev: Second Half Absent
												WHERE	EMP_ID=@EMP_ID AND FOR_DATE = @Pre_Date_WeekOff 
														AND (OUT_TIME IS NULL OR  DATEDIFF(n,Out_Time, Shift_End_Time) > 239)
														AND IsNull(Chk_By_Superior,0)<>1))
									AND @Next_Date_WeekOff <= GETDATE() AND @Pre_Date_WeekOff <= GETDATE() 	
									AND (@Pre_Leave_Type <> 'Company Purpose')
									AND (@Pre_Leave = 0 or (@Pre_Leave > 0 AND @Pre_Leave_CancelHO = 1))
								BEGIN		
									IF (NOT EXISTS(SELECT 1 FROM #DATA_WOHO		--For Prev: Full Day Absent
												WHERE	EMP_ID=@EMP_ID AND FOR_DATE = @Pre_Date_WeekOff AND P_DAYS > 0)	
									OR EXISTS(SELECT 1 FROM #DATA_WOHO		--For Prev: Second Half Absent
												WHERE	EMP_ID=@EMP_ID AND FOR_DATE = @Pre_Date_WeekOff 
														AND (OUT_TIME IS NULL OR  DATEDIFF(n,Out_Time, Shift_End_Time) > 239)
														AND IsNull(Chk_By_Superior,0)<>1))
									AND @Next_Date_WeekOff <= GETDATE() AND @Pre_Date_WeekOff <= GETDATE() 	
									AND (@Next_Leave_Type <> 'Company Purpose' )
									AND (@Pre_Leave = 0 or (@Pre_Leave > 0 AND @Pre_Leave_CancelHO = 1))
									BEGIN
										--For Prev: Full/Half Day Absent, Next : Full/Half Leave
										IF @Next_Leave >= 0.5 AND @Next_Leave_CancelHO = 1	
											BEGIN
									
												SET  @CANCEL_REASON = ' Sandwich Policy 2 : Prev: Full/SH Day Absent, Next: ' + @Next_Leave_FHSH + ' - ' + Cast(@Next_Leave as Varchar) 
												SET	@Is_Cancel = 1
											END
										ELSE IF @Next_Leave >= 0.5 AND @Next_Leave_CancelHO = 0
											BEGIN
												--DO NOTHING
												SET	@Is_Cancel = 0;
											END
										ELSE IF NOT EXISTS(SELECT 1 FROM #DATA_WOHO 
													WHERE EMP_ID=@EMP_ID AND FOR_DATE = @Next_Date_WeekOff AND P_DAYS > 0)		--For Prev: Full/Half Day Absent, Next : Full Absent
												OR	EXISTS(SELECT 1 FROM #DATA_WOHO	
													WHERE EMP_ID=@EMP_ID AND FOR_DATE = @Next_Date_WeekOff 
															AND DATEDIFF(n,Shift_Start_Time, In_Time) > 239
															AND IsNull(Chk_By_Superior,0)<>1)		--For Prev: Full/Half Day Absent, Next : Half Day Absent
											BEGIN
										
												SET  @CANCEL_REASON = ' Sandwich Policy 2 : Both Side Full/Half Day Absent '
												SET	@Is_Cancel = 1
											END
										END
								END
																
								
							--SELECT @IS_CANCEL_HOLIDAY_WO_HO_SAME_DAY,@FOR_DATE,@IS_CANCEL
						


						/*Following Condition added by Nimesh on 21-Jan-2019 
						(Corona - If any WeekOff canceled due to half day leave or absent or employee present even for half day before weekoff and after weekoff 
									and @Cancel_WO_HalfDay_Abs_Leave setting is off then WeekOff should not be canceled */
						IF @Cancel_WO_HalfDay_Abs_Leave = 1 AND @Is_Cancel = 1
							AND @Pre_Leave_Type <> 'Company Purpose'  AND @Next_Leave_Type <> 'Company Purpose' 
							AND EXISTS(SELECT 1 FROM #DATA_WOHO D WHERE D.EMP_ID=@EMP_ID AND (D.For_Date BETWEEN @Pre_Date_WeekOff AND @Next_Date_WeekOff) AND P_Days > 0)								
							BEGIN							
								SET  @CANCEL_REASON = '';
								SET	@Is_Cancel = 0
							END	
					
					if @CancelHolidayIfOneSideAbsent = 1 and ((@Pre_Leave >= 1 and @Pre_Leave_Type <> 'Company Purpose') or (@Next_Leave >= 1 and @Next_Leave_Type <> 'Company Purpose')) AND @Is_Cancel = 1
								begin
									SET  @CANCEL_REASON = ' Sandwich Policy new : one side Full Day Absent '
									SET	@Is_Cancel = 1
								end
								if @CancelHolidayIfOneSideAbsent = 1
							begin						
								IF NOT EXISTS(SELECT 1 FROM #DATA_WOHO 
											WHERE EMP_ID=@EMP_ID AND (FOR_DATE = @Pre_Date_WeekOff) )		--For Prev: Full/Half Day Absent, Next : Full Absent											
									BEGIN											
										SET  @CANCEL_REASON = ' Sandwich Policy new : one side Full Day Absent '
										SET	@Is_Cancel = 1
										
									END	
							
									IF NOT EXISTS(SELECT 1 FROM #DATA_WOHO 
											WHERE EMP_ID=@EMP_ID AND (FOR_DATE = @Next_Date_WeekOff) )		--For Prev: Full/Half Day Absent, Next : Full Absent											
									BEGIN											
										SET  @CANCEL_REASON = ' Sandwich Policy new : one side Full Day Absent '
										SET	@Is_Cancel = 1
										
									END	
							end
						
						IF @Is_Cancel  = 0 AND @Max_Consecutive_Leave_Days_For_Cancel_WO > 0
							Begin										
								SET @ABS_DAYS = @Max_Consecutive_Leave_Days_For_Cancel_WO
								SET @WO_DAYS = 0

								SELECT	@ABS_DAYS = @ABS_DAYS - IsNull(Sum(P_DAYS),0)
								FROM	#DATA_WOHO D
								WHERE	D.Emp_ID=@EMP_ID AND D.For_Date BETWEEN DateAdd(D,(@Max_Consecutive_Leave_Days_For_Cancel_WO - 1) * -1, @Pre_Date_WeekOff) AND @Pre_Date_WeekOff

								--- Added by Hardik 31/12/2019 for Shoft Shipyard to check Weekoff, if weekoff is coming in between then Holiday should not cancel
								SELECT @WO_DAYS = Isnull(Count(data),0)
								FROM dbo.Split(@StrWeekoff_Date,';') 
								WHERE replace(replace(replace(data,'</FOR_DATE><FOR_DATE>',''),'</FOR_DATE>',''),'FOR_DATE>','') <> ''
										AND Cast(replace(replace(replace(data,'</FOR_DATE><FOR_DATE>',''),'</FOR_DATE>',''),'FOR_DATE>','') As Datetime) BETWEEN DateAdd(D,(@Max_Consecutive_Leave_Days_For_Cancel_WO - 1) * -1, @Pre_Date_WeekOff) AND @Pre_Date_WeekOff	
							
								SELECT	@Consecutive_Leave_Days = IsNull(Sum(Case When LM.Apply_Hourly = 1 AND Leave_Used > 1 Then Leave_Used * 0.125 Else Leave_Used End + CompOff_Used),0)
								FROM	T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)
										INNER JOIN T0040_LEAVE_MASTER LM  WITH (NOLOCK) ON LT.Leave_ID=LM.Leave_ID
								WHERE	For_Date  BETWEEN DateAdd(D,(@Max_Consecutive_Leave_Days_For_Cancel_WO - 1) * -1, @Pre_Date_WeekOff) AND @Pre_Date_WeekOff
										AND Emp_ID=@EMP_ID AND (Leave_Used > 0 OR CompOff_Used > 0) AND Leave_Type <> 'Company Purpose'
							
								SET @ABS_DAYS = @ABS_DAYS - @Consecutive_Leave_Days - @WO_DAYS
							
								--IF (@Consecutive_Leave_Days + @ABS_DAYS) >= @Max_Consecutive_Leave_Days_For_Cancel_WO AND @Pre_Leave_Type <> 'Company Purpose' AND @Next_Leave_Type <> 'Company Purpose'
								IF (@Consecutive_Leave_Days) >= @Max_Consecutive_Leave_Days_For_Cancel_WO AND @Pre_Leave_Type <> 'Company Purpose' AND @Next_Leave_Type <> 'Company Purpose' -- above condition comment by tejas for bug #30368
									BEGIN 
										-- After take 3 Consecutive leave week-off should be cancelled but if employee is working on week-off day consider it as OT 
										-- Added by Nilesh Patel on 12072019
										IF Not Exists(SELECT 1 From T0150_EMP_INOUT_RECORD WITH (NOLOCK) Where Emp_ID = @EMP_ID and For_Date = @For_Date)
											Begin
												SET  @CANCEL_REASON = ' Sandwich Policy 3 : Leave has been taken Before WeekOff for ' + Cast(@Consecutive_Leave_Days as varchar(5)) + ' consecutive days'
												SET	@Is_Cancel = 1
											End
									END							
							End		


							IF @Is_Cancel = 1
								GOTO CONTINUE_LOOP;

							/*Sandwich Policy End*/				

					END
CONTINUE_LOOP:
								
			
			
			--if (@Is_Cancel = 1 OR @H_Days <> 1)			
				BEGIN					
					UPDATE	#EMP_HOLIDAY
					SET		Is_Cancel = @Is_Cancel, H_DAY = @H_Days
					WHERE	Emp_ID=@EMP_ID AND For_Date=@For_Date

					
					--IF (@CANCEL_REASON  <> '')
					--	PRINT 'HOLIDAY CANCEL REASON ' + @CANCEL_REASON  + ' FOR ' + CONVERT(VARCHAR(10), @For_Date,103)

					SET @CANCEL_REASON  = '';					
				END
				
				
			SET @For_Date = DATEADD(d,1,@For_Date)
				
			FETCH NEXT FROM curHoliday INTO @Emp_ID, @Branch_ID,@For_Date,@Is_Half,@Is_P_Comp
		END
	CLOSE curHoliday;
	DEALLOCATE curHoliday;
	
	--Added Condition on 29/01/2018 by Hardik & Nimesh, For Aculife, As Same Date Holiday and WO and that time Compoff not coming in Application due to Holiday Cancel Date
	Delete H From #EMP_HOLIDAY H Where IS_CANCEL = 1 And Exists(Select 1 From #Emp_Weekoff W Where H.For_Date=W.For_Date And H.Emp_Id=W.Emp_Id And W.Is_Cancel = 0)

	UPDATE	#EMP_HW_CONS
	SET		HolidayDate			=	H1.Holiday,
			HolidayCount		=	H1.HolidayCount,
			CancelHoliday		=	H1.CancelHoliday,
			CancelHolidayCount	=	H1.CancelHolidayCount,
			HalfHolidayDate		=	H1.Half_Holiday,		--Ankit/Nimesh --22082016
			HalfHolidayCount	=	H1.Half_HolidayCount	--Ankit/Nimesh --22082016
	FROM	(
				SELECT	IsNull(REPLACE(REPLACE((
									SELECT	';' + CAST(H.For_Date AS VARCHAR(11)) AS FOR_DATE FROM	#EMP_HOLIDAY H
									WHERE	H.Emp_ID = H1.Emp_ID AND H.IS_CANCEL = 0 and H_DAY =1 ---H_DAY Ankit 22082016
									FOR XML PATH('')
								), '<FOR_DATE>', ''), '</FOR_DATE>', ''), '') Holiday,
						Sum(CASE WHEN H1.IS_CANCEL = 1  OR H_DAY <> 1 THEN 0 ELSE 1 END) As HolidayCount,
						IsNull(REPLACE(REPLACE((
									SELECT	';' + CAST(H.For_Date AS VARCHAR(11)) AS FOR_DATE FROM	#EMP_HOLIDAY H
									WHERE	H.Emp_ID = H1.Emp_ID AND H.Is_Cancel = 1 FOR XML PATH('')
								), '<FOR_DATE>', ''), '</FOR_DATE>', ''), '') As CancelHoliday,
						Sum(CASE WHEN H1.IS_CANCEL = 1 THEN 1 ELSE 0 END) As CancelHolidayCount, H1.Emp_ID
						----Half Day Holiday --Ankit/Nimesh --22082016
						,IsNull(REPLACE(REPLACE((
									SELECT	';' + CAST(H.For_Date AS VARCHAR(11)) AS FOR_DATE FROM	#EMP_HOLIDAY H
									WHERE	H.Emp_ID = H1.Emp_ID AND H.IS_CANCEL = 0 and H_DAY =0.5
									FOR XML PATH('')
								), '<FOR_DATE>', ''), '</FOR_DATE>', ''), '') Half_Holiday
						,Sum(CASE WHEN H1.IS_CANCEL = 1 OR H_DAY <> 0.5 THEN 0 ELSE 1 END) As Half_HolidayCount
						----
				FROM #EMP_HOLIDAY H1 
				GROUP BY H1.EMP_ID
			) H1
	WHERE	H1.EMP_ID=#EMP_HW_CONS.Emp_ID
	
	

	--IF @Type = 0
	--	Begin
	--		set @StrHoliday_Date=@varHoliday_Date
	--	End 
	--Else if @Type = 1
	--	Begin
	--		Select @varHoliday_Date
	--	End	


