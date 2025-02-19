

---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_LEAVE_CF_DAILY_BASE]  
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
 
	---- To Calculate Present Days
	CREATE TABLE #Data     
	(     
		Emp_Id     NUMERIC ,     
		For_date   DATETIME,    
		Duration_in_sec  NUMERIC,    
		Shift_ID   NUMERIC ,    
		Shift_Type   NUMERIC ,    
		Emp_OT    NUMERIC ,    
		Emp_OT_min_Limit NUMERIC,    
		Emp_OT_MAX_Limit NUMERIC,    
		P_days    NUMERIC(12,1) default 0,    
		OT_Sec    NUMERIC default 0,
		In_Time DATETIME default null,
		Shift_Start_Time DATETIME default null,
		OT_Start_Time NUMERIC default 0,
		Shift_Change TINYINT default 0 ,
		Flag INT Default 0  ,
		Weekoff_OT_Sec  NUMERIC default 0,
		Holiday_OT_Sec  NUMERIC default 0	,
		Chk_By_Superior NUMERIC default 0,
		IO_Tran_Id	   NUMERIC default 0,
		OUT_Time DATETIME,
		Shift_END_Time DATETIME,			--Ankit 16112013
		OT_END_Time NUMERIC default 0,		--Ankit 16112013 
		Working_Hrs_St_Time TINYINT default 0, --Hardik 14/02/2014
		Working_Hrs_END_Time TINYINT default 0, --Hardik 14/02/2014
		GatePass_Deduct_Days NUMERIC(18,2) default 0 -- Add by Gadriwala Muslim 05012014
	)    
	---- END ----   

	
	DECLARE @Cmp_Id			NUMERIC
	DECLARE @From_Date		DATETIME
	DECLARE @To_Date		DATETIME

	DECLARE @Leave_ID		NUMERIC   
	DECLARE @Leave_MAX_Bal	NUMERIC   
	DECLARE @Leave_CF_Type	VARCHAR(50)  
	DECLARE @Leave_PDays	NUMERIC(12,5)  
	DECLARE @Leave_get_Against_PDays NUMERIC(12,5)  
	DECLARE @Leave_Precision	NUMERIC(2)   
	DECLARE @P_Days				NUMERIC(12,5)  
	DECLARE @Leave_CF_Days		NUMERIC(18,5)  
	DECLARE @Leave_Closing		NUMERIC(18,5)  
	DECLARE @CF_Full_Days		NUMERIC(1,0)  
	DECLARE @CF_Days			NUMERIC(18,5)  
	DECLARE @C_Paid_Days		NUMERIC(5,1)
	DECLARE @Weekoff_Days		NUMERIC(12,1)
	DECLARE @UnPaid_Days		NUMERIC(12,1)
	DECLARE @Working_Days		NUMERIC(12,1)
	DECLARE @Leave_Paid_Days	NUMERIC(18,5)

	DECLARE @Is_CF_On_Sal_Days	TINYINT
	DECLARE @Days_As_Per_Sal_Days	TINYINT
	DECLARE @MAX_Accumulate_Balance	NUMERIC(18, 2)
	DECLARE @Min_Present_Days	NUMERIC(18, 2)
	DECLARE @CF_Effective_Date	DATETIME
	DECLARE @CF_Type_ID			NUMERIC(18, 0)
	DECLARE @Reset_Months		NUMERIC(18, 0)
	DECLARE @Duration			VARCHAR(15)
	DECLARE @CF_Months			NVARCHAR(50)
	DECLARE @Release_Month		NUMERIC(18, 0)
	DECLARE @Reset_Month_String NVARCHAR(50)
	DECLARE @is_leave_CF_Rounding	TINYINT
	DECLARE @is_leave_CF_Prorata	TINYINT

	DECLARE @Type_Id			NUMERIC
	DECLARE @Emp_ID				NUMERIC
	
	DECLARE @Grd_ID				NUMERIC
	DECLARE @Branch_ID			NUMERIC

	--DECLARE @Is_Cancel_Holiday	NUMERIC(1,0)    
	--DECLARE @Is_Cancel_Weekoff	NUMERIC(1,0)
	--DECLARE @StrHoliday_Date	VARCHAR(MAX)    
	--DECLARE @StrWeekoff_Date	VARCHAR(MAX)
	--DECLARE @Cancel_Weekoff		NUMERIC(18, 0)
	--DECLARE @Cancel_Holiday		NUMERIC(18, 0)
	--DECLARE @Emp_Left_Date		DATETIME

	DECLARE @Sal_St_Date		DATETIME    
	DECLARE @Sal_END_Date		DATETIME  

	DECLARE @WO_Days			NUMERIC
	DECLARE @HO_Days			NUMERIC
	DECLARE @Inc_HOWO			INT
	DECLARE @Temp_For_Date		DATETIME
	DECLARE @Leave_CF_ID		NUMERIC
	DECLARE @Comp_Paid_Days		NUMERIC(18,5)

	 ---- Added by Rajput on 06022019 ----

	  DECLARE @Inc_Holiday NUMERIC(1,0) --Added by rajput on 06022019
	  DECLARE @Inc_Weekoff NUMERIC(1,0) --Added by rajput on 06022019
		
	  ---- End by Rajput on 06022019 ----
	  
	--Added By Ramiz ON 12/04/2016	
	DECLARE @RESET_DATE			DATETIME
	SET @RESET_DATE = ''  
  
	DECLARE @LEAVE_TRAN_ID		NUMERIC(18,0)
	SET @LEAVE_TRAN_ID = 0
  
	DECLARE @LEAVE_CREDIT		NUMERIC(18,5)
	SET @LEAVE_CREDIT = 0
	--ENDed By Ramiz ON 12/04/2016	
  
	--SET @Is_Cancel_Weekoff = 0    
	--SET @Is_Cancel_Holiday = 0    
	--SET @StrHoliday_Date = ''    
	--SET @StrWeekoff_Date = ''  
	SET @Leave_Paid_Days = 0  
	SET @WO_Days = 0
	SET @HO_Days = 0
	SET @Inc_HOWO = 0
	SET @Leave_CF_ID = 0
	SET @Comp_Paid_Days =0		
	If Month(GETDATE())= 1
		BEGIN
			SET @From_Date = dbo.GET_MONTH_ST_DATE(12,YEAR(GETDATE())-1)
		END
	ELSE
		BEGIN
			SET @From_Date = dbo.GET_MONTH_ST_DATE(MONTH(GETDATE())-1,YEAR(GETDATE()))
		END

	SET @To_Date = DATEADD(dd,-1,GETDATE())		

	CREATE TABLE #Emp_Cons 
	(      
		Emp_ID NUMERIC ,     
		Branch_ID NUMERIC,
		Increment_ID NUMERIC    
	)   
 
 
	/*************************************************************************
	Added by Nimesh: 17/Nov/2015 
	(To get holiday/weekoff data for all employees in seperate table)
	*************************************************************************/
	CREATE TABLE #EMP_HOLIDAY(EMP_ID NUMERIC, FOR_DATE DATETIME, IS_CANCEL BIT, Is_Half tinyint, Is_P_Comp tinyint, H_DAY numeric(4,1));
	CREATE UNIQUE CLUSTERED INDEX IX_EMP_HOLIDAY_EMPID_FORDATE ON #EMP_HOLIDAY(EMP_ID, FOR_DATE);
	
	CREATE TABLE #EMP_WEEKOFF
	(
		Row_ID			NUMERIC,
		Emp_ID			NUMERIC,
		For_Date		DATETIME,
		Weekoff_day		VARCHAR(10),
		W_Day			numeric(4,1),
		Is_Cancel		BIT
	)
	CREATE CLUSTERED INDEX IX_Emp_WeekOff_EmpID_ForDate ON #EMP_WEEKOFF(Emp_ID, For_Date)		
	
	DECLARE @CONSTRAINT VARCHAR(MAX)

	CREATE TABLE #EMP_CONS_TEMP 
	(
		Emp_ID NUMERIC ,     
		Branch_ID NUMERIC,
		Increment_ID NUMERIC  
	)

	CREATE TABLE #EMP_HOLIDAY_TEMP(EMP_ID NUMERIC, FOR_DATE DATETIME, IS_CANCEL BIT, Is_Half tinyint, Is_P_Comp tinyint, H_DAY numeric(4,1));
	CREATE UNIQUE CLUSTERED INDEX IX_EMP_HOLIDAY_TEMP_EMPID_FORDATE ON #EMP_HOLIDAY_TEMP(EMP_ID, FOR_DATE);
	
	CREATE TABLE #EMP_WEEKOFF_TEMP
	(
		Row_ID			NUMERIC,
		Emp_ID			NUMERIC,
		For_Date		DATETIME,
		Weekoff_day		VARCHAR(10),
		W_Day			numeric(4,1),
		Is_Cancel		BIT
	)
	CREATE CLUSTERED INDEX IX_Emp_WeekOff_TEMP_EmpID_ForDate ON #EMP_WEEKOFF_TEMP(Emp_ID, For_Date)

 
	  
	DECLARE curCompany CURSOR FAST_FORWARD FOR

	SELECT	LM.Cmp_ID,LM.leavE_Id,CF.TYPE_ID,LM.leave_MAX_Bal,Leave_CF_Type,CPD.Present_Day AS Leave_Pdays, CPD.Leave_Again_Present_Day AS Leave_Get_Against_PDays,
			IsNull(Leave_Precision,0),Leave_Days,LM.MAX_Accumulate_Balance,Min_Present_Days,is_leave_CF_Rounding,is_leave_CF_Prorata,QRY.Effective_Date,
			CF.CF_Type_ID,CF.Reset_Months,CF.Duration,CF.CF_Months,CF.Release_Month,CF.Reset_Month_String,IsNull(Is_Ho_Wo,0),LD.Grd_ID, 
			IsNull(lm.Including_Holiday,0),IsNull(lm.Including_WeekOff,0) -- ADDED BY RAJPUT ON 06022019 
	FROM	T0040_leave_master LM WITH (NOLOCK) 
			INNER JOIN T0050_LEave_Detail LD WITH (NOLOCK) ON LM.Leave_ID = LD.Leave_ID   
			INNER JOIN T0050_CF_EMP_TYPE_DETAIL CF WITH (NOLOCK) ON CF.Leave_ID=LM.Leave_ID
			INNER JOIN T0050_LEAVE_CF_Present_Day CPD WITH (NOLOCK) ON CPD.Leave_ID = LM.Leave_ID AND CPD.Type_ID = CF.Type_ID
			INNER JOIN (SELECT	MAX(Effective_Date) AS Effective_Date,Leave_ID 
						FROM	T0050_CF_EMP_TYPE_DETAIL WITH (NOLOCK)
						GROUP BY Leave_ID) QRY ON QRY.Leave_ID=CF.Leave_ID AND QRY.Effective_Date=CF.Effective_Date	
	WHERE	CF_Type_ID = 1 AND --LM.Leave_Id = 15 AND
			(LM.Leave_CF_Type = 'Daily (On Present Day)' OR LM.Leave_CF_Type = 'Daily (Fix)')
	
	OPEN curCompany
	FETCH NEXT FROM curCompany INTO @Cmp_Id,@Leave_ID,@Type_Id,@Leave_MAX_Bal,@Leave_CF_Type,@Leave_Pdays,@Leave_Get_Against_PDays,@Leave_Precision,@Leave_CF_Days,@MAX_Accumulate_Balance,@Min_Present_Days,@is_leave_CF_Rounding,@is_leave_CF_Prorata,@CF_Effective_Date,@CF_Type_ID,@Reset_Months,@Duration,@CF_Months,@Release_Month,@Reset_Month_String,@Inc_HOWO,@Grd_ID,@Inc_Holiday,@Inc_Weekoff
	WHILE @@FETCH_STATUS = 0
		BEGIN
			IF @RESET_MONTHS > 0
				SET @RESET_DATE	= (DBO.GET_MONTH_END_DATE(IsNull(@RESET_MONTHS,0) , YEAR(GETDATE()))) + 1 --HERE 1 IS ADDED AS WE NEED TO RESET IT ON NEXT DAY

			INSERT	INTO #Emp_Cons      
			SELECT	DISTINCT emp_id,branch_id,Increment_ID 
			FROM	dbo.V_Emp_Cons 
			WHERE	Cmp_ID=@Cmp_ID AND IsNull(Type_ID,0) = IsNull(@Type_ID ,IsNull(Type_ID,0))
					AND IsNull(Grd_ID,0) = IsNull(@Grd_ID ,IsNull(Grd_ID,0)) 
					AND Increment_Effective_Date <= @To_Date 
					AND (	
								(@From_Date  >= join_Date  AND  @From_Date <= left_date )      
							OR ( @To_Date  >= join_Date  AND @To_Date <= left_date )      
							OR (Left_date is null AND @To_Date >= Join_Date)      
							OR (@To_Date >= left_date  AND  @From_Date <= left_date )
						) 
			ORDER BY Emp_ID

			--INSERT	 INTO #EMP_CONS_TEMP
			--SELECT * FROM #Emp_Cons EC WHERE NOT EXISTS(SELECT 1 FROM #EMP_CONS_TEMP T WHERE EC.Emp_ID=T.Emp_ID)
			
			SET @CONSTRAINT  = NULL
			SELECT	@CONSTRAINT = COALESCE(@CONSTRAINT+ '#', '') + CAST(EMP_ID AS VARCHAR(5)) 
			FROM	#Emp_Cons EC 
			WHERE	NOT EXISTS(SELECT 1 FROM #EMP_WEEKOFF_TEMP T WHERE EC.Emp_ID=T.Emp_ID)
 

			EXEC SP_GET_HW_ALL @CONSTRAINT=@CONSTRAINT,@CMP_ID=@Cmp_ID, @FROM_DATE=@FROM_DATE, @TO_DATE=@TO_DATE, @All_Weekoff = 0, @Exec_Mode=0		

			INSERT INTO #EMP_WEEKOFF_TEMP
			SELECT * FROM #EMP_WEEKOFF W WHERE NOT EXISTS(SELECT 1 FROM #EMP_WEEKOFF_TEMP T WHERE T.Emp_ID=W.Emp_ID AND T.For_Date=W.For_Date)

			INSERT INTO #EMP_HOLIDAY_TEMP
			SELECT * FROM #EMP_HOLIDAY H WHERE NOT EXISTS(SELECT 1 FROM #EMP_HOLIDAY_TEMP T WHERE T.Emp_ID=H.Emp_ID AND T.For_Date=H.For_Date)

			TRUNCATE TABLE #EMP_WEEKOFF
			TRUNCATE TABLE #EMP_HOLIDAY

					
			--	Delete FROM #Emp_Cons WHERE Increment_ID Not In	--Ankit 30012014
			--(SELECT TI.Increment_ID FROM t0095_increment TI inner join
			--(SELECT MAX(Increment_Effective_Date) AS Effective_Date,Emp_ID FROM T0095_Increment
			--WHERE Increment_effective_Date <= @to_date GROUP BY emp_ID) new_inc
			--on TI.Emp_ID = new_inc.Emp_ID AND Ti.Increment_Effective_Date=new_inc.Effective_Date
			--WHERE Increment_effective_Date <= @to_date)		
				
			-- comment AND added by rohit ON 29072016
			Delete #Emp_Cons FROM  #Emp_Cons EC Left Outer Join
			(SELECT MAX(TI.Increment_ID) Increment_Id,ti.Emp_ID FROM t0095_increment TI WITH (NOLOCK) inner join
			(SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date,Emp_ID FROM T0095_Increment WITH (NOLOCK)
			WHERE Increment_effective_Date <= @to_date GROUP BY emp_ID) new_inc
			on TI.Emp_ID = new_inc.Emp_ID AND Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
			WHERE TI.Increment_effective_Date <= @to_date GROUP BY ti.emp_id) Qry ON EC.Increment_Id = QRY.Increment_Id
			WHERE QRY.Increment_ID is null


			DECLARE Cur_Emp CURSOR FAST_FORWARD FOR
			SELECT	I.Emp_Id ,I.Grd_ID, I.Branch_ID,I.Type_ID	--,Emp_Left_Date 
			FROM	T0095_Increment I WITH (NOLOCK) 
					INNER JOIN (SELECT	MAX(Increment_effective_Date) AS For_Date,Emp_ID 
								FROM	T0095_Increment WITH (NOLOCK)
								WHERE	Increment_Effective_date <= @To_Date AND Cmp_ID = @Cmp_ID 
								GROUP BY emp_ID) Qry ON I.Emp_ID = QRY.Emp_ID and I.Increment_effective_Date = QRY.For_Date INNER JOIN #Emp_Cons ec ON i.emp_ID =ec.emp_ID 
					--INNER JOIN T0080_EMP_MASTER e ON e.emp_ID=ec.emp_ID 
			WHERE	I.Cmp_ID = @Cmp_ID   
				--and I.Emp_ID = 2
				--and I.Emp_ID=1304
			OPEN Cur_Emp
			FETCH NEXT FROM Cur_Emp INTO @Emp_ID,@Grd_ID,@Branch_ID,@Type_ID--,@Emp_Left_Date   
			WHILE @@FETCH_STATUS = 0
				BEGIN

					SELECT	@Sal_St_Date = Sal_st_Date,
							--@Is_Cancel_Holiday = Is_Cancel_Holiday,@Is_Cancel_Weekoff = Is_Cancel_Weekoff    
							@Is_CF_On_Sal_Days = IsNull(Is_CF_On_Sal_Days,0) , @Days_As_Per_Sal_Days = IsNull(Days_As_Per_Sal_Days,0) 
					FROM	T0040_GENERAL_SETTING WITH (NOLOCK)
					WHERE	Cmp_ID = @cmp_ID AND Branch_ID = @Branch_ID 
							AND For_Date = (SELECT	MAX(For_Date) 
											FROM	T0040_GENERAL_SETTING WITH (NOLOCK)
											WHERE	For_Date <=@To_Date AND Branch_ID = @Branch_ID AND Cmp_ID = @Cmp_ID)    


					If @CF_Type_ID = 1  -- For Against Present Day
						BEGIN
							--Exec SP_EMP_WEEKOFF_DATE_GET @Emp_ID,@Cmp_ID,@From_Date,@To_Date,Null,Null,@Is_Cancel_weekoff,@StrHoliday_Date,@StrWeekoff_Date output,@WO_Days output ,@Cancel_Weekoff output    
							--Exec SP_EMP_HOLIDAY_DATE_GET @Emp_ID,@Cmp_ID,@From_Date,@To_Date,Null,Null,@Is_Cancel_Holiday,@StrHoliday_Date output,@HO_Days output,@Cancel_Holiday output,0,@Branch_ID,@StrWeekoff_Date
							

							Exec SP_CALCULATE_PRESENT_DAYS @Cmp_ID,@From_Date,@To_Date,0,0,0,0,0,0,@emp_ID,'',4  
							SET @Temp_For_Date = @From_Date
								
							While @Temp_For_Date <= @To_Date
								BEGIN
							
									--If CHARINDEX(Cast(@Temp_For_Date AS VARCHAR(11)),@StrWeekoff_Date) > 0 
									IF EXISTS(SELECT 1 FROM #EMP_WEEKOFF_TEMP WHERE Emp_ID=@Emp_ID AND For_Date=@Temp_For_Date AND Is_Cancel=0)
										SET @WO_Days = 1
									ELSE
										SET @WO_Days = 0
		
		
									--If CHARINDEX(Cast(@Temp_For_Date AS VARCHAR(11)),@StrHoliday_Date) > 0 
									IF EXISTS(SELECT 1 FROM #EMP_HOLIDAY_TEMP WHERE Emp_ID=@Emp_ID AND For_Date=@Temp_For_Date AND Is_Cancel=0)
										SET @HO_Days = 1
									ELSE
										SET @HO_Days = 0
								
									SELECT @P_Days = IsNull(sum(P_Days),0) FROM #Data WHERE Emp_ID=@emp_ID AND For_Date = @Temp_For_Date
							
															
									-- Commented by rohit ON 23012015
									--SELECT @C_Paid_Days = IsNull(sum(leave_used),0) + IsNull(sum(Back_Dated_Leave),0) FROM T0140_LEavE_Transaction WHERE Emp_Id =@Emp_ID 
									--and For_Date = @Temp_For_Date AND Leave_ID in 
									--(SELECT Leave_ID FROM T0040_LEave_Master WHERE Cmp_Id =@Cmp_ID AND Leave_Type ='Company Purpose')


									--SELECT @Leave_Paid_Days = IsNull(sum(leave_used),0)+ IsNull(sum(Back_Dated_Leave),0) FROM T0140_LEavE_Transaction WHERE Emp_Id = @Emp_ID  
									--and For_Date = @Temp_For_Date AND Leave_ID in 
									--(SELECT Leave_ID FROM T0040_LEave_Master WHERE Cmp_Id =@Cmp_ID AND Leave_Type <> 'Company Purpose' AND Leave_Paid_Unpaid = 'P')
	
									SELECT @C_Paid_Days = IsNull(sum(case when LM.Apply_Hourly =1 AND Leave_Used > 8 then 1 when LM.Apply_Hourly =1 then leave_used /8 ELSE Leave_Used END ),0) + IsNull(sum(case when LM.Apply_Hourly =1 AND Back_Dated_Leave > 8 then 1 when LM.Apply_Hourly =1 then Back_Dated_Leave /8 ELSE Back_Dated_Leave END ),0) FROM T0140_LEavE_Transaction LT WITH (NOLOCK)
									INNER JOIN (SELECT * FROM T0040_LEave_Master WITH (NOLOCK) WHERE Cmp_Id =@Cmp_ID AND Leave_Type ='Company Purpose') AS LM 
									on LT.Leave_ID = LM.leave_id AND Lt.Cmp_ID=LM.cmp_id
									WHERE Emp_Id =@Emp_ID 
									and For_Date = @Temp_For_Date 
									
									SELECT @Comp_Paid_Days = IsNull(sum(case when LM.Apply_Hourly =1 AND CompOff_Used - Leave_Encash_Days  > 8 then 1 when LM.Apply_Hourly =1 then (CompOff_Used -Leave_Encash_Days) /8 ELSE (CompOff_Used- Leave_Encash_Days) END ),0) + IsNull(sum(case when LM.Apply_Hourly =1 AND Back_Dated_Leave > 8 then 1 when LM.Apply_Hourly =1 then Back_Dated_Leave /8 ELSE Back_Dated_Leave END ),0) FROM T0140_LEavE_Transaction LT WITH (NOLOCK)
									INNER JOIN (SELECT * FROM T0040_LEave_Master WITH (NOLOCK) WHERE Cmp_Id =@Cmp_ID AND Default_Short_Name  ='COMP') AS LM 
									on LT.Leave_ID = LM.leave_id AND Lt.Cmp_ID=LM.cmp_id
									WHERE Emp_Id =@Emp_ID 
									and For_Date = @Temp_For_Date 
									
									SELECT @Leave_Paid_Days = IsNull(sum(case when LM.Apply_Hourly =1 AND Leave_Used > 8 then 1 when LM.Apply_Hourly =1 then leave_used /8 ELSE Leave_Used END ),0) + IsNull(sum(case when LM.Apply_Hourly =1 AND Back_Dated_Leave > 8 then 1 when LM.Apply_Hourly =1 then Back_Dated_Leave /8 ELSE Back_Dated_Leave END ),0) FROM T0140_LEavE_Transaction LT WITH (NOLOCK)
									INNER JOIN (SELECT * FROM T0040_LEave_Master WITH (NOLOCK) WHERE Cmp_Id =@Cmp_ID AND Leave_Type <> 'Company Purpose'  AND Leave_Paid_Unpaid = 'P') AS LM 
									on LT.Leave_ID = LM.leave_id AND Lt.Cmp_ID=LM.cmp_id
									WHERE Emp_Id =@Emp_ID 
									and For_Date = @Temp_For_Date 
									
									--ADDED BY RAJPUT PATEL ON 06022019 - START
									IF @Inc_HOWO = 1 AND @Inc_Holiday = 1 AND @Inc_Weekoff = 1
										set @P_Days = Isnull(@P_Days,0) + isnull(@C_Paid_Days,0) + isnull(@WO_Days,0) + isnull(@HO_Days,0) + isnull(@Leave_Paid_Days,0)+@Comp_Paid_Days
									ELSE IF @Inc_HOWO = 1 AND @Inc_Holiday = 1 
										set @P_Days = Isnull(@P_Days,0) + isnull(@C_Paid_Days,0) + isnull(@HO_Days,0) + isnull(@Leave_Paid_Days,0) + @Comp_Paid_Days
									ELSE IF @Inc_HOWO = 1 AND @Inc_Weekoff = 1
										set @P_Days = Isnull(@P_Days,0) + isnull(@C_Paid_Days,0) + isnull(@WO_Days,0) + isnull(@Leave_Paid_Days,0) + @Comp_Paid_Days
									
									ELSE IF @Inc_Holiday = 1 AND @Inc_Weekoff = 1
										SET @P_Days = IsNull(@P_Days,0) + isnull(@C_Paid_Days,0) + IsNull(@WO_Days,0) + IsNull(@HO_Days,0) + @Comp_Paid_Days  
									ELSE IF @Inc_Holiday = 1 
										SET @P_Days = IsNull(@P_Days,0) + isnull(@C_Paid_Days,0) + IsNull(@HO_Days,0) + @Comp_Paid_Days 
									ELSE IF @Inc_Weekoff = 1
										SET @P_Days = IsNull(@P_Days,0) + isnull(@C_Paid_Days,0) + IsNull(@WO_Days,0) + @Comp_Paid_Days 
									ELSE IF @Inc_HOWO = 1
										SET @P_Days = IsNull(@P_Days,0) + isnull(@C_Paid_Days,0) +  @Comp_Paid_Days 
									ELSE
										set @P_Days = Isnull(@P_Days,0) + isnull(@C_Paid_Days,0) + @Comp_Paid_Days
									--ADDED BY RAJPUT PATEL ON 06022019 - END 
									
									
									-- COMMENTED BY RAJPUT ON 06022019 As per discussed With Hardik Bhai (Inductotherm Client CASE : Daily Leave Carry Forward Auto)
									--If @Inc_HOWO = 1											
									--	SET @P_Days = IsNull(@P_Days,0) + IsNull(@C_Paid_Days,0) + IsNull(@WO_Days,0) + IsNull(@HO_Days,0) + IsNull(@Leave_Paid_Days,0)+@Comp_Paid_Days
									--ELSE
									--	SET @P_Days = IsNull(@P_Days,0) + IsNull(@C_Paid_Days,0)+@Comp_Paid_Days

						
									If @Leave_Get_Against_PDays > 0 AND @Leave_pDays > 0	
  										BEGIN
  										
  											If @Leave_CF_Type = 'Daily (On Present Day)'
  												BEGIN
  													If @is_leave_CF_Rounding = 1 
  														BEGIN
  															SET @Leave_CF_Days = Round(@P_Days * IsNull(@Leave_Get_Against_PDays,0)/@Leave_Pdays,0)  
  														END
  													ELSE 
  														BEGIN
  															SET @Leave_CF_Days = @P_Days * IsNull(@Leave_Get_Against_PDays,0)/@Leave_Pdays
  														END
  												END
  											ELSE if @Leave_CF_Type = 'Daily (Fix)'
  												BEGIN
  													If @is_leave_CF_Rounding = 1 
  														SET @Leave_CF_Days = Round(IsNull(@Leave_Get_Against_PDays,0)/@Leave_Pdays,0)  
  													ELSE
  														SET @Leave_CF_Days = IsNull(@Leave_Get_Against_PDays,0)/@Leave_Pdays
  														--SELECT @Temp_For_Date,@Leave_CF_Days
  												END
		  																					
  										END	
									
						
									--SELECT @Leave_CF_Days,@Leave_Get_Against_PDays,@Leave_Pdays
									If IsNull(@Leave_CF_Days,0) > 0 --and @Temp_For_Date <> '07-aug-2014'
										BEGIN
											If exists (SELECT 1 FROM T0100_LEAVE_CF_DETAIL WITH (NOLOCK) WHERE Emp_ID = @Emp_ID AND CF_For_Date = @Temp_For_Date AND Leave_ID =@Leave_ID )
												BEGIN
												
													UPDATE  T0100_LEAVE_CF_DETAIL SET 
															CF_For_Date = @Temp_For_Date
														   ,CF_From_Date = @Temp_For_Date
														   ,CF_To_Date = @Temp_For_Date
														   ,CF_P_Days = @P_Days
														   ,CF_Leave_Days = @Leave_CF_Days
														   ,CF_Type = @Leave_CF_Type
													 WHERE CF_For_Date = @Temp_For_Date AND Emp_ID =@Emp_ID AND Leave_ID =@Leave_ID
													 

												END
											ELSE
												BEGIN
													 SELECT @Leave_CF_ID = IsNull(MAX(Leave_CF_ID),0) + 1  FROM T0100_LEAVE_CF_DETAIL WITH (NOLOCK)  
													 
													 INSERT INTO T0100_LEAVE_CF_DETAIL  
															(Leave_CF_ID, Cmp_ID, Emp_ID, Leave_ID, CF_For_Date, CF_From_Date, CF_To_Date, CF_P_Days, CF_Leave_Days, CF_Type)  
													 VALUES (@Leave_CF_ID, @Cmp_ID, @Emp_ID, @Leave_ID, @Temp_For_Date, @Temp_For_Date, @Temp_For_Date, @P_Days, @Leave_CF_Days, @Leave_CF_Type)  
												END
										END
										
										--HERE CODE OF LEAVE BALANCE RESET IS ADDED BY RAMIZ ON 12-APR-2016
										IF  @RESET_MONTHS > 0 AND @RESET_MONTHS <= 12 
										BEGIN
											IF CONVERT(VARCHAR, @RESET_DATE , 106) = CONVERT(VARCHAR, @TEMP_FOR_DATE , 106) 
												BEGIN
													IF EXISTS(SELECT LEAVE_TRAN_ID FROM T0140_LEAVE_TRANSACTION WITH (NOLOCK) WHERE EMP_ID=@EMP_ID AND LEAVE_ID=@LEAVE_ID AND FOR_DATE = @TEMP_FOR_DATE)
														BEGIN												
															SELECT @LEAVE_TRAN_ID = LEAVE_TRAN_ID, @LEAVE_CLOSING = LEAVE_CLOSING , @LEAVE_CREDIT = LEAVE_CREDIT FROM T0140_LEAVE_TRANSACTION WITH (NOLOCK) WHERE EMP_ID=@EMP_ID AND LEAVE_ID=@LEAVE_ID AND FOR_DATE=@TEMP_FOR_DATE
											
															UPDATE T0140_LEAVE_TRANSACTION SET
																LEAVE_OPENING = 0,
																LEAVE_CLOSING = @LEAVE_CREDIT,
																LEAVE_POSTING = @LEAVE_CLOSING
															WHERE LEAVE_TRAN_ID = @LEAVE_TRAN_ID 

														END
													ELSE
														BEGIN								
															SELECT @LEAVE_CLOSING = LT.LEAVE_CLOSING FROM T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)
																INNER JOIN 
																	(
																		SELECT IsNull(MAX(LEAVE_TRAN_ID),0) AS Leave_Tran_ID 
																		FROM T0140_LEAVE_TRANSACTION WITH (NOLOCK) 
																		WHERE EMP_ID = @Emp_ID  AND LEAVE_ID=@LEAVE_ID
																	)QRY ON LT.LEAVE_TRAN_ID = QRY.LEAVE_TRAN_ID
															WHERE EMP_ID= @EMP_ID  AND LEAVE_ID=@LEAVE_ID
															
															SELECT @LEAVE_TRAN_ID = IsNull(MAX(LEAVE_TRAN_ID),0) + 1 FROM T0140_LEAVE_TRANSACTION WITH (NOLOCK)
															
															INSERT INTO T0140_LEAVE_TRANSACTION(LEAVE_TRAN_ID,EMP_ID,LEAVE_ID,CMP_ID,FOR_DATE,LEAVE_OPENING,LEAVE_USED,LEAVE_CLOSING,LEAVE_CREDIT,LEAVE_POSTING)
															VALUES(@LEAVE_TRAN_ID,@EMP_ID,@LEAVE_ID,@CMP_ID,@TEMP_FOR_DATE,0,0,0,0,@LEAVE_CLOSING)
														END
												END
										END
									--RESET CODE OF LEAVE BALANCE ENDS HERE
									
									SET @Temp_For_Date = DATEADD(dd,1,@Temp_For_Date)
								END
						END

						Delete #Data
						
					FETCH NEXT FROM Cur_Emp INTO @Emp_ID,@Grd_ID,@Branch_ID,@Type_ID--,@Emp_Left_Date   
				END
			Close Cur_Emp
			Deallocate Cur_Emp

			delete #Emp_Cons
			
			SET @RESET_DATE = ''
			
			FETCH NEXT FROM curCompany INTO @Cmp_Id,@Leave_ID,@Type_Id,@Leave_MAX_Bal,@Leave_CF_Type,@Leave_Pdays,@Leave_Get_Against_PDays,@Leave_Precision,@Leave_CF_Days,@MAX_Accumulate_Balance,@Min_Present_Days,@is_leave_CF_Rounding,@is_leave_CF_Prorata,@CF_Effective_Date,@CF_Type_ID,@Reset_Months,@Duration,@CF_Months,@Release_Month,@Reset_Month_String,@Inc_HOWO,@Grd_ID,@Inc_Holiday,@Inc_Weekoff
		END
	Close curCompany
	Deallocate curCompany
    
 
 RETURN  
  
  


