

/*
OPTIMIZED ON :	27-Jan-2016
OPTIMIZED BY :	NIMESH
DESCRIPTION  :	CALCULATE_PRESENT_DAYS AND HOLIDAY/WEEKOFF STORED PROCEDURE 
				EXECUTED OUT SIDE OF THE CURSOR. DECLARATIONS TAKEN OUTSIDE FROM THE CURSOR.
				UNNECESSARY CURSOR REPLACED WITH SINGLE SQL STATEMENT.
*/
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

CREATE PROCEDURE [dbo].[Rpt_Emp_Late_Early_Penalty_Days]    
  @Cmp_ID		NUMERIC      
 ,@From_Date	DATETIME      
 ,@To_Date		DATETIME       
 ,@Branch_ID	NUMERIC   
 ,@Cat_ID		NUMERIC 
 ,@Grd_ID		NUMERIC 
 ,@Type_ID		NUMERIC  
 ,@Dept_ID		NUMERIC  
 ,@Desig_ID		NUMERIC 
 ,@Emp_ID		NUMERIC 
 ,@Constraint	VARCHAR(max) = ''      
 
 AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	
	DECLARE @sal_st_date		DATETIME    
	DECLARE @sal_end_date		DATETIME     
	DECLARE @outof_days			NUMERIC           
	DECLARE @Increment_ID		NUMERIC    
	DECLARE @is_late_slabwise	TINYINT
	DECLARE @is_early_slabwise	TINYINT
	DECLARE @late_dedu_type_inc	VARCHAR(10)
	DECLARE @early_dedu_type_inc		VARCHAR(10)
	DECLARE @penalty_days_early_late	NUMERIC(18,1) 
	DECLARE @gen_id				NUMERIC   
	DECLARE @StrHoliday_Date	VARCHAR(max)    
	DECLARE @StrWeekoff_Date	VARCHAR(max)    
	DECLARE @Join_Date			DATETIME    
	DECLARE @left_Date			DATETIME    
	DECLARE @Holiday_Days		NUMERIC(9,2)    
	DECLARE @Weekoff_Days		NUMERIC(9,2)    
	DECLARE @Cancel_Holiday		NUMERIC(9,2)    
	DECLARE @Cancel_Weekoff     NUMERIC(9,2) 
	DECLARE @Temp_Extra_Count	NUMERIC(18,0)
	Declare @Late_Mark_Scenario Numeric(18,0)
			
	SET @Holiday_Days	= 0
	SET @Weekoff_Days	= 0
	SET @Cancel_Holiday	= 0
	SET @Cancel_Weekoff	= 0
	
	SET @is_late_slabwise		= 0
	SET @is_early_slabwise		= 0
	SET @late_dedu_type_inc		= 0
	SET @early_dedu_type_inc	= 0
	SET @outof_days = DATEDIFF(d,@From_Date,@To_Date) + 1 
	SET @gen_id		= 0
	Set @Late_Mark_Scenario = 0
	
	IF @Branch_ID = 0      
		SET @Branch_ID = null  
	IF @Cat_ID = 0      
		SET @Cat_ID = null      
	IF @Type_ID = 0      
		SET @Type_ID = null      
	IF @Dept_ID = 0      
		SET @Dept_ID = null      
	IF @Grd_ID = 0      
		SET @Grd_ID = null      
	IF @Emp_ID = 0      
		SET @Emp_ID = null      
	IF @Desig_ID = 0      
		SET @Desig_ID = null  
		
	
	CREATE TABLE #Emp_Penalty 
	(
		Cmp_id NUMERIC,
		Emp_ID NUMERIC,      
		From_Date  datetime,      
		To_Date  datetime,      
		Late_days NUMERIC(3,1) ,
		Early_days NUMERIC(3,1) ,
		Penalty_days NUMERIC(3,1)
	)      
	 
	 
	CREATE TABLE #Emp_Cons	-- Ankit 08092014 for Same Date Increment
	(      
		Emp_ID NUMERIC ,     
		Branch_ID NUMERIC,
		Increment_ID NUMERIC    
	)   
	 
	EXEC dbo.SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint --,@Sal_Type ,@Salary_Cycle_id ,@Segment_Id ,@Vertical_Id ,@SubVertical_Id ,@SubBranch_Id 
	 
	 
	IF OBJECT_ID('tempdb..#Emp_WeekOff') IS NULL
		BEGIN
			--Holiday & Weekoff - In colon(;) seperated string (With Cancel) : Used in SP_CALCULATE_PRESENT_DAYS
			CREATE TABLE #EMP_HW_CONS
			(
				Emp_ID				NUMERIC,
				WeekOffDate			VARCHAR(Max),
				WeekOffCount		NUMERIC(3,1),
				CancelWeekOff		VARCHAR(Max),
				CancelWeekOffCount	NUMERIC(3,1),
				HolidayDate			VARCHAR(MAX),
				HolidayCount		NUMERIC(3,1),
				HalfHolidayDate		VARCHAR(MAX),
				HalfHolidayCount	NUMERIC(3,1),
				CancelHoliday		VARCHAR(Max),
				CancelHolidayCount	NUMERIC(3,1)
			)
			CREATE UNIQUE CLUSTERED INDEX IX_EMP_HW_CONS_EmpID ON #EMP_HW_CONS(Emp_ID)
			
			EXEC dbo.SP_GET_HW_ALL @CONSTRAINT=@CONSTRAINT,@CMP_ID=@Cmp_ID, @FROM_DATE=@FROM_DATE, @TO_DATE=@TO_DATE, @All_Weekoff = 0, @Exec_Mode=0
			
			SELECT * INTO #EMP_HW_CONS_T1 FROM #EMP_HW_CONS
			
			DROP TABLE #EMP_HW_CONS
		END
	
	
    
	CREATE TABLE #Data      
	(     
		Emp_Id     NUMERIC ,     
		For_date   datetime,    
		Duration_in_sec  NUMERIC,    
		Shift_ID   NUMERIC ,    
		Shift_Type   NUMERIC ,    
		Emp_OT    NUMERIC ,    
		Emp_OT_min_Limit NUMERIC,    
		Emp_OT_max_Limit NUMERIC,   
		P_days    NUMERIC(12,2) DEFAULT 0,    
		OT_Sec    NUMERIC DEFAULT 0,
		In_Time datetime DEFAULT null,
		Shift_Start_Time datetime DEFAULT null,
		OT_Start_Time NUMERIC DEFAULT 0,
		Shift_Change TINYINT DEFAULT 0 ,
		Flag Int DEFAULT 0  ,
		Weekoff_OT_Sec  NUMERIC DEFAULT 0,
		Holiday_OT_Sec  NUMERIC DEFAULT 0,
		Chk_By_Superior NUMERIC DEFAULT 0,
		IO_Tran_Id	   NUMERIC DEFAULT 0,
		Out_time datetime DEFAULT null,
		Shift_End_Time datetime,			--Ankit 16112013
		OT_End_Time NUMERIC DEFAULT 0,	--Ankit 16112013
		Working_Hrs_St_Time TINYINT DEFAULT 0, --Hardik 14/02/2014
		Working_Hrs_End_Time TINYINT DEFAULT 0, --Hardik 14/02/2014
		GatePass_Deduct_Days NUMERIC(18,2) DEFAULT 0 -- Add by Gadriwala Muslim 05012014
	)  
	CREATE NONCLUSTERED INDEX IX_Data ON dbo.#data(Emp_Id,Shift_ID,For_Date) 
	
	EXEC dbo.SP_CALCULATE_PRESENT_DAYS  @Cmp_ID,@From_Date,@To_Date,0,0,0,0,0,0,0,@Constraint,4,'',1   
	
	-------------------- late deduction ---------------------------    
	DECLARE @late_absent_day	NUMERIC(18,1)    
	DECLARE @total_lmark		NUMERIC(18,1)    
	DECLARE @total_late_sec		NUMERIC     
	DECLARE @late_dedu_amount	NUMERIC     
	DECLARE @extra_late_dedu_amount NUMERIC    
	DECLARE @late_extra_amount	NUMERIC  
	DECLARE @late_is_slabwise	TINYINT
	
	DECLARE @Absent_date_String NVARCHAR(max)
	--DECLARE @Absent_For_date as datetime
	DECLARE @Prev_Branch_ID		NUMERIC;
	
	--FOR EARLY DEDUCT
	DECLARE @Early_Adj_Day		NUMERIC(5,2)   
	DECLARE @Early_Sal_Dedu_Days  NUMERIC(18,1)    
	DECLARE @Total_EarlyMark	NUMERIC(18,1)    
	DECLARE @Total_Early_Sec	NUMERIC    		
	DECLARE @Extra_Early_Deduction NUMERIC(3,1)    
	DECLARE @Early_is_slabwise	TINYINT
	
	-----------Slabwise--calculation--for--late/early-- 
	DECLARE @Total_Total_Sec NUMERIC
	DECLARE @Total_penalty_days NUMERIC(3,1)
	DECLARE @Total_Late_Hours NVARCHAR(10)
	DECLARE @Total_Early_Hours NVARCHAR(10)
	DECLARE @Total_LE_Hours NVARCHAR(10)
	
	SET @Prev_Branch_ID = 0;

	DECLARE CURH_DAYS CURSOR FOR                  
	SELECT	E.Emp_ID,E.Branch_ID,ISNULL(Late_Dedu_Type,'') As Late_Dedu_Type, ISNULL(Early_Dedu_Type,'') As Early_Dedu_Type , E.Increment_Id
	FROM	#Emp_Cons E INNER JOIN dbo.T0095_INCREMENT I WITH (NOLOCK) ON E.Increment_ID=I.Increment_ID
	ORDER BY E.Branch_ID,E.Emp_ID
	
	OPEN CURH_DAYS                      
	FETCH NEXT FROM CURH_DAYS INTO @emp_id,@branch_id,@late_dedu_type_inc,@early_dedu_type_inc , @Increment_ID
	WHILE @@FETCH_STATUS = 0                    
		BEGIN   		
			SET @is_late_slabwise  = 0
			SET @is_early_slabwise  = 0
			SET @late_dedu_type_inc  = 0
			SET @early_dedu_type_inc = 0
			SET @gen_id = 0   


			SET @late_absent_day  = 0;
			SET @total_lmark   = 0;
			SET @total_late_sec   = 0;
			SET @late_dedu_amount  = NULL;
			SET @extra_late_dedu_amount = NULL;
			SET @late_extra_amount = NULL;
			SET @late_is_slabwise = NULL;
			SET @Temp_Extra_Count = 0

			SET @StrHoliday_Date = ''
			SET @StrWeekoff_Date = ''

			--For Early Deduct
			SET @Early_is_slabwise = 0
			SET @Early_Adj_Day = 0
			SET @Early_Sal_Dedu_Days = 0    
			SET @Total_EarlyMark = 0    
			SET @Total_Early_Sec =0   
			SET @Extra_Early_Deduction = 0    



			--SELECT	@late_dedu_type_inc=isnull(late_dedu_type,''),@early_dedu_type_inc=isnull(early_dedu_type,'')
			--FROM	T0095_INCREMENT I
			--WHERE	I.Increment_ID = @increment_id    

			--Exec SP_EMP_HOLIDAY_DATE_GET @Emp_ID,@Cmp_ID,@From_Date,@To_Date,@Join_Date,@left_Date,0,@StrHoliday_Date OUTPUT,@Holiday_days OUTPUT,@Cancel_Holiday OUTPUT,0,@Branch_ID,@StrWeekoff_Date
			--Exec SP_EMP_WEEKOFF_DATE_GET @Emp_ID,@Cmp_ID,@From_Date,@To_Date,@Join_Date,@left_Date,0,@StrHoliday_Date,@StrWeekoff_Date OUTPUT,@Weekoff_Days OUTPUT ,@Cancel_Weekoff OUTPUT    



			Select	@StrWeekoff_Date = WeekOffDate,@Weekoff_Days=WeekOffCount,@Cancel_Weekoff=CancelWeekOffCount,
					@StrHoliday_Date=HolidayDate, @Holiday_days=HolidayCount, @Cancel_Holiday=CancelHolidayCount
			FROM	#EMP_HW_CONS_T1
			WHERE	Emp_ID=@Emp_ID
			
			IF (@Prev_Branch_ID <> @Branch_ID)
			BEGIN
				SET @Prev_Branch_ID = @Branch_ID
				SELECT	@gen_id=Gen_ID, @late_is_slabwise=ISNULL(is_Late_Calc_Slabwise,0),@Early_is_slabwise = isnull(is_Early_Calc_Slabwise,0),
						@Late_Mark_Scenario = Isnull(Late_Mark_Scenario,1)
				FROM	T0040_GENERAL_SETTING G WITH (NOLOCK)
						INNER JOIN (
										SELECT	MAX(For_Date) AS For_Date 
										FROM	T0040_GENERAL_SETTING  WITH (NOLOCK)   
										WHERE	cmp_id = @cmp_id AND For_Date <=@To_Date AND Branch_ID=@Branch_ID
									)  G1 ON G.For_Date=G1.For_Date
				WHERE	Cmp_ID = @Cmp_ID AND Branch_ID =@Branch_ID 
			END
	
			--Added by Gadriwala Muslim 24062015 - Start		
			--Exec dbo.SP_CALCULATE_PRESENT_DAYS @Cmp_ID,@From_Date,@To_Date,0,0,0,0,0,0,0,@emp_id,4,'',1   
       
			
			SET		@Absent_date_String = NULL;
			
			SELECT	@Absent_date_String = COALESCE(@Absent_date_String + '#','') + CAST(For_Date AS VARCHAR(25)) 	
			FROM	#Data 
			WHERE	Emp_Id = @Emp_Id AND For_date >= @From_Date AND For_date <= @To_Date AND P_days = 0
	 
			/*Commented by Nimesh On 25-Jan-2016 (optimized)
			DECLARE curCheckAbsent cursor for select For_Date from #Data 
			where Emp_Id = @Emp_Id AND For_date >= @From_Date AND For_date <= @To_Date AND P_days = 0
			open curCheckAbsent
				Fetch next from curCheckAbsent into @Absent_For_date
				 while @@FETCH_STATUS = 0 
					begin
						 if @Absent_date_String = '' 
							SET @Absent_date_String = cast(@Absent_For_date as VARCHAR(25))
						 else
							SET @Absent_date_String = @Absent_date_String + '#' +  cast(@Absent_For_date as VARCHAR(25)) 	
						 			
						Fetch next from curCheckAbsent into @Absent_For_date
					end
			close curCheckAbsent
			deallocate curcheckAbsent	
			*/
			--Added by Gadriwala Muslim 24062015 - End   
      	
			
			if @Late_Mark_Scenario = 2 
				Begin
					
					exec SP_CALCULATE_LATE_DEDUCTION_SLABWISE @emp_Id,@Cmp_ID,@From_Date,@To_Date,@Late_Absent_Day output,@Total_LMark output,@Total_Late_Sec output,@Increment_ID,@StrWeekoff_Date,@StrHoliday_Date,0,'',0,@Absent_date_String    
				End
			Else
				Begin
					exec dbo.SP_CALCULATE_LATE_DEDUCTION      @emp_Id,@Cmp_ID,@From_Date,@To_Date,@Late_Absent_Day OUTPUT,@Total_LMark OUTPUT,@total_late_sec OUTPUT,@Increment_ID,@StrWeekoff_Date,@StrHoliday_Date,0,'',0,@Absent_date_String, @Temp_Extra_Count OUTPUT	
				End
			
			
			------------------------Early--------
			--select @Gen_Id = Gen_ID ,  @Early_is_slabwise = isnull(is_Early_Calc_Slabwise,0)
			--	from T0040_General_Setting where Cmp_ID = @Cmp_ID AND Branch_ID =@Branch_ID AND For_date = (select max(for_date) From T0040_General_Setting     
			--	where Cmp_ID = @Cmp_ID AND For_Date <=@To_Date AND Branch_ID =@Branch_ID)  
			exec dbo.SP_CALCULATE_EARLY_DEDUCTION @emp_Id,@Cmp_ID,@From_Date,@To_Date,@Early_Sal_Dedu_Days OUTPUT,@Total_EarlyMark OUTPUT,@Total_Early_Sec OUTPUT,@Increment_ID    ,@StrWeekoff_Date   ,@StrHoliday_Date, 0,'' , @Temp_Extra_Count
			---------------------Early-----------

		

			-----------Slabwise--calculation--for--late/early-- 
			SET @Total_Total_Sec = 0;
			SET @Total_penalty_days = 0;
			SET @Total_Late_Hours = 0;
			SET @Total_Early_Hours = 0;
			SET @Total_LE_Hours = 0;
			SET @penalty_days_early_late = 0


			SET @Total_Late_Hours = dbo.F_Return_Hours(@Total_Late_Sec)
			SET @Total_Early_Hours = dbo.F_Return_Hours(@Total_Early_Sec)
			SET @Total_LE_Hours = dbo.F_Return_Hours(@Total_Late_Sec + @Total_Early_Sec)


			
			IF @Late_is_slabwise = 1 AND @Early_is_slabwise = 1 AND @Early_Dedu_Type_inc = 'Hour' AND @Late_Dedu_Type_inc = 'Hour' 
				BEGIN			
					EXEC dbo.SP_GET_LATE_EARLY_SLABWISE @Cmp_ID,@Gen_Id,@Total_LE_Hours ,@Total_penalty_days OUTPUT,0				
					SET @Penalty_days_Early_Late = @Total_penalty_days
				END
			ELSE IF @Late_is_slabwise = 1 AND @Late_Dedu_Type_inc = 'Hour' 
				BEGIN
					EXEC dbo.SP_GET_LATE_EARLY_SLABWISE @Cmp_ID,@Gen_Id,@Total_Late_Hours,@Total_penalty_days OUTPUT,0
					SET @Late_Absent_Day = @Total_penalty_days
				END
			ELSE IF @Early_is_slabwise = 1 AND @Early_Dedu_Type_inc = 'Hour'  
				BEGIN
					EXEC dbo.SP_GET_LATE_EARLY_SLABWISE @Cmp_ID,@Gen_Id,@Total_Early_Hours,@Total_penalty_days OUTPUT,0	
					SET @Early_Sal_Dedu_Days = @Total_penalty_days
				END 
					
			------------------------------------------
			IF  @Late_Absent_Day > 0 or @Early_Sal_Dedu_Days > 0 or @Penalty_days_Early_Late 	> 0
				BEGIN
					INSERT INTO #Emp_Penalty 
					SELECT @Cmp_ID,@Emp_ID,@From_Date,@To_Date, @Late_Absent_Day ,@Early_Sal_Dedu_Days , @Penalty_days_Early_Late 
				END	
				
			FETCH NEXT FROM CURH_DAYS INTO @emp_id,@branch_id,@late_dedu_type_inc,@early_dedu_type_inc , @Increment_ID
	   END
	CLOSE curH_Days                    
	DEALLOCATE curH_Days 
	 
	---------------------commented jimit 28042016------------------------
	--SELECT	EP.*,EM.Alpha_Emp_Code,EM.Emp_Full_Name,CM.Cmp_Name,cm.Cmp_Address,bm.Branch_Name,bm.Branch_Address,bm.Branch_ID 
	--FROM	#Emp_Penalty EP
	--		INNER JOIN #EMP_CONS E ON EP.Emp_ID=E.Emp_ID
	--		INNER JOIN dbo.T0080_EMP_MASTER EM on EM.Emp_ID =EP.Emp_ID 
	--		INNER JOIN dbo.T0010_COMPANY_MASTER CM on cm.Cmp_Id = EP.Cmp_id
	--		INNER JOIN dbo.T0030_BRANCH_MASTER BM on E.Branch_ID=BM.Branch_ID
	
	-------------------------------ended------------------------------------
	
	SELECT	EP.*,EM.Alpha_Emp_Code,EM.Emp_Full_Name,CM.Cmp_Name,cm.Cmp_Address,bm.Branch_Name,bm.Branch_Address,bm.Branch_ID 
			,GM.GRD_NAME,TM.TYPE_NAME,VS.VERTICAL_NAME,SV.SUBVERTICAL_NAME,DM.DEPT_NAME,DE.DESIG_NAME  --added jimit 28042016
			,BM.COMP_NAME                     --added jimit 04102016
	FROM	#Emp_Penalty EP
			INNER JOIN #EMP_CONS E ON EP.Emp_ID=E.Emp_ID
			INNER JOIN dbo.T0080_EMP_MASTER EM WITH (NOLOCK) on EM.Emp_ID =EP.Emp_ID 
			INNER JOIN dbo.T0010_COMPANY_MASTER CM WITH (NOLOCK) on cm.Cmp_Id = EP.Cmp_id
			INNER JOIN dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK) on E.Branch_ID=BM.Branch_ID
			Inner JOIN #Emp_Cons EC On Ec.Emp_ID = Em.Emp_ID
			INNER JOIN T0095_INCREMENT Iq WITH (NOLOCK) On Iq.Increment_ID = Ec.Increment_ID and iq.Emp_ID = Ec.Emp_ID			
			LEFT OUTER JOIN T0040_TYPE_MASTER TM WITH (NOLOCK) ON TM.TYPE_ID = IQ.TYPE_ID
			LEFT OUTER JOIN T0040_VERTICAL_SEGMENT VS	WITH (NOLOCK) ON VS.VERTICAL_ID = IQ.VERTICAL_ID
			LEFT OUTER JOIN T0050_SUBVERTICAL SV WITH (NOLOCK) ON SV.SUBVERTICAL_ID = IQ.SUBVERTICAL_ID
			LEFT OUTER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON GM.GRD_ID = IQ.GRD_ID 
			LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON DM.DEPT_ID = IQ.DEPT_ID
			LEFT OUTER JOIN T0040_DESIGNATION_MASTER DE WITH (NOLOCK) ON DE.DESIG_ID = IQ.DESIG_ID
	
	  
	 
RETURN




