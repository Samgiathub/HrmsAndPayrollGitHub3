
CREATE PROCEDURE [dbo].[SP_RPT_EMP_HOLIDAY_IN_OUT_GET]
	 @CMP_ID 		NUMERIC
	,@FROM_DATE		DATETIME
	,@TO_DATE 		DATETIME
	,@BRANCH_ID		NUMERIC
	,@CAT_ID 		NUMERIC 
	,@GRD_ID 		NUMERIC
	,@TYPE_ID 		NUMERIC
	,@DEPT_ID 		NUMERIC
	,@DESIG_ID 		NUMERIC
	,@EMP_ID 		NUMERIC
	,@CONSTRAINT 	VARCHAR(MAX)
	,@REPORT_FOR    NUMERIC(18,0) = 0  --ADDED JIMIT 18082015
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	IF @BRANCH_ID = 0  
		SET @BRANCH_ID = NULL
		
	IF @CAT_ID = 0  
		SET @CAT_ID = NULL

	IF @GRD_ID = 0  
		SET @GRD_ID = NULL

	IF @TYPE_ID = 0  
		SET @TYPE_ID = NULL

	IF @DEPT_ID = 0  
		SET @DEPT_ID = NULL

	IF @DESIG_ID = 0  
		SET @DESIG_ID = NULL

	IF @EMP_ID = 0  
		SET @EMP_ID = NULL
	
	CREATE TABLE #EMP_CONS -- ANKIT 08092014 FOR SAME DATE INCREMENT
	 (      
	   EMP_ID NUMERIC ,     
	   BRANCH_ID NUMERIC,
	   INCREMENT_ID NUMERIC    
	 )   
	 
	 EXEC SP_RPT_FILL_EMP_CONS  @CMP_ID,@FROM_DATE,@TO_DATE,@BRANCH_ID,@CAT_ID,@GRD_ID,@TYPE_ID,@DEPT_ID,@DESIG_ID ,@EMP_ID ,@CONSTRAINT --,@SAL_TYPE ,@SALARY_CYCLE_ID ,@SEGMENT_ID ,@VERTICAL_ID ,@SUBVERTICAL_ID ,@SUBBRANCH_ID 	
	
	DECLARE @REQUIRED_EXEC BIT
	SET @REQUIRED_EXEC = 0;
	
	IF OBJECT_ID('tempdb..#Emp_WeekOff') IS NULL
		BEGIN
			CREATE TABLE #Emp_WeekOff
			(
				Row_ID			NUMERIC,
				Emp_ID			NUMERIC,
				For_Date		DATETIME,
				Weekoff_day		VARCHAR(10),
				W_Day			numeric(4,1),
				Is_Cancel		BIT
			)
			CREATE CLUSTERED INDEX IX_Emp_WeekOff_EmpID_ForDate ON #Emp_WeekOff(Emp_ID, For_Date)		
			SET @REQUIRED_EXEC = 1;
		END
	
	IF OBJECT_ID('tempdb..#EMP_HOLIDAY') IS NULL
		BEGIN
			CREATE TABLE #EMP_HOLIDAY(EMP_ID NUMERIC, FOR_DATE DATETIME, IS_CANCEL BIT, Is_Half tinyint, Is_P_Comp tinyint, H_DAY numeric(3,1));
			CREATE UNIQUE CLUSTERED INDEX IX_EMP_HOLIDAY_EMPID_FORDATE ON #EMP_HOLIDAY(EMP_ID, FOR_DATE);
			
			SET @REQUIRED_EXEC = 1;
		END
	IF OBJECT_ID('tempdb..#Emp_WeekOff_Holiday') IS NULL
	BEGIN
		--Holiday & WeekOff - In colon(;) seperated string (Without Cancel) : Used in SP_CALCULATE_PRESENT_DAYS
		CREATE TABLE #Emp_WeekOff_Holiday
		(
			Emp_ID				NUMERIC,
			WeekOffDate			VARCHAR(Max),
			WeekOffCount		NUMERIC(4,1),
			HolidayDate			VARCHAR(Max),
			HolidayCount		NUMERIC(4,1),
			HalfHolidayDate		VARCHAR(Max),
			HalfHolidayCount	NUMERIC(4,1),
			OptHolidayDate		VARCHAR(Max),
			OptHolidayCount		NUMERIC(4,1)
		);
		SET @REQUIRED_EXEC  = 1;
	END 
	
	IF OBJECT_ID('tempdb..#EMP_HW_CONS') IS NULL
	BEGIN	
	
		--Holiday & Weekoff - In colon(;) seperated string (With Cancel) : Used in SP_CALCULATE_PRESENT_DAYS
		CREATE TABLE #EMP_HW_CONS
		(
			Emp_ID				NUMERIC,
			WeekOffDate			Varchar(Max),
			WeekOffCount		NUMERIC(4,1),
			CancelWeekOff		Varchar(Max),
			CancelWeekOffCount	NUMERIC(4,1),
			HolidayDate			Varchar(MAX),
			HolidayCount		NUMERIC(4,1),
			HalfHolidayDate		Varchar(MAX),
			HalfHolidayCount	NUMERIC(4,1),
			CancelHoliday		Varchar(Max),
			CancelHolidayCount	NUMERIC(4,1)
		);
		
		CREATE UNIQUE CLUSTERED INDEX IX_EMP_HW_CONS_EmpID ON #EMP_HW_CONS(Emp_ID)
		
		SET @REQUIRED_EXEC  =1;		
	END
		
	IF @REQUIRED_EXEC = 1
	BEGIN
		EXEC SP_GET_HW_ALL @CONSTRAINT=@CONSTRAINT,@CMP_ID=@Cmp_ID, @FROM_DATE=@FROM_DATE, @TO_DATE=@TO_DATE, @All_Weekoff = 1, @Exec_Mode=0
	END
	  
-------- Add By Jigneh 13-Dec-2019------------  
	  CREATE TABLE #Data         
	(         
		Emp_Id   numeric ,         
		For_date DATETIME,        
		Duration_in_sec numeric,        
		Shift_ID numeric ,        
		Shift_Type numeric ,        
		Emp_OT  numeric ,        
		Emp_OT_min_Limit numeric,        
		Emp_OT_max_Limit numeric,        
		P_days  numeric(12,3) default 0,        
		OT_Sec  numeric default 0  ,
		In_Time DATETIME,
		Shift_Start_Time DATETIME,
		OT_Start_Time numeric default 0,
		Shift_Change TINYINT default 0,
		Flag int default 0,
		Weekoff_OT_Sec  numeric default 0,
		Holiday_OT_Sec  numeric default 0,
		Chk_By_Superior numeric default 0,
		IO_Tran_Id	   numeric default 0, -- io_tran_id is used for is_cmp_purpose (t0150_emp_inout)
		OUT_Time DATETIME,
		Shift_END_Time DATETIME,			--Ankit 16112013
		OT_END_Time numeric default 0,	--Ankit 16112013
		Working_Hrs_St_Time TINYINT default 0, --Hardik 14/02/2014
		Working_Hrs_END_Time TINYINT default 0, --Hardik 14/02/2014
		GatePass_Deduct_Days numeric(18,2) default 0 -- Add by Gadriwala Muslim 05012014
	)
	CREATE NONCLUSTERED INDEX ix_Data_Emp_Id_For_date_Shift_Id on #Data (Emp_Id,For_date,Shift_ID) 
	
	Exec SP_CALCULATE_PRESENT_DAYS @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@emp_ID,@constraint,4,'',0
--------- End------------
	  
	  
	DECLARE @FOR_DATE DATETIME 
	DECLARE @DATE_DIFF NUMERIC 
	DECLARE @NEW_TO_DATE DATETIME 
	DECLARE @ROW_ID	NUMERIC 
	
	SET @DATE_DIFF = DATEDIFF(D,@FROM_DATE,@TO_DATE) + 1 
	SET @DATE_DIFF = 35 - ( @DATE_DIFF)
	SET @NEW_TO_DATE = @TO_DATE --DATEADD(D,@DATE_DIFF,@TO_DATE)
	
	-- COMMENTED BY GADRIWALA MUSLIM 12102016
	--CREATE TABLE #EMP_HOLIDAY
	--  (
	--		EMP_ID		NUMERIC , 
	--		CMP_ID		NUMERIC,
	--		FOR_DATE	DATETIME,
	--		H_DAY		NUMERIC(3,1),
	--		IS_HALF_DAY TINYINT
	--  )
	DECLARE @ATT_PERIOD  TABLE
	  (
		FOR_DATE	DATETIME,
		ROW_ID		NUMERIC
	  )
	SET @FOR_DATE = @FROM_DATE
	SET @ROW_ID = 1
	WHILE @FOR_DATE <= @NEW_TO_DATE
		BEGIN
			
			INSERT INTO @ATT_PERIOD 
			SELECT @FOR_DATE ,@ROW_ID
			SET @ROW_ID =@ROW_ID + 1
			SET @FOR_DATE = DATEADD(D,1,@FOR_DATE)
		END

	
		
	IF	EXISTS (SELECT * FROM [TEMPDB].DBO.SYSOBJECTS WHERE NAME LIKE '#Yearly_Salary' )		
			BEGIN
				DROP TABLE #YEARLY_SALARY 
			END
			
	 CREATE TABLE #ATT_MUSTER 
	  (
			EMP_ID		NUMERIC , 
			CMP_ID		NUMERIC,
			FOR_DATE	DATETIME,
			STATUS		VARCHAR(10),
			LEAVE_COUNT	NUMERIC(5,1),
			WO_HO		VARCHAR(3),
			STATUS_2	VARCHAR(10),
			ROW_ID		NUMERIC ,
			IN_DATE		DATETIME,
			OUT_DATE	DATETIME,
			DURATION	VARCHAR(10)
	  )
	  
	  CREATE CLUSTERED INDEX IX_EMP_ID_CMP_ID_FOR_DATE_ATT_MUSTER ON #Att_Muster
	  (
		Emp_Id,
		Row_ID
	  )
	  
	--DECLARE @CUREMP_ID	NUMERIC
	--DECLARE	@CURCMP_ID	NUMERIC
	--DECLARE	@CURFOR_DATE DATETIME
	--DECLARE	@CURROW_ID NUMERIC 

	

	INSERT INTO #ATT_MUSTER (EMP_ID,CMP_ID,FOR_DATE,ROW_ID)
	SELECT 	EMP_ID ,@CMP_ID ,FOR_DATE,ROW_ID FROM @ATT_PERIOD CROSS JOIN #EMP_CONS
	
	/*
	UPDATE	A	SET STATUS = 'P' 
	FROM	#ATT_MUSTER A 
	WHERE EXISTS(SELECT IO_TRAN_ID FROM T0150_EMP_INOUT_RECORD WHERE EMP_ID = A.EMP_ID AND NOT IN_TIME IS NULL AND FOR_DATE = A.FOR_DATE)
	*/
	UPDATE	A	SET STATUS = 'P' 
	FROM	#ATT_MUSTER A 
	WHERE EXISTS(SELECT Emp_Id FROM #Data WHERE EMP_ID = A.EMP_ID AND NOT IN_TIME IS NULL AND FOR_DATE = A.FOR_DATE)
	
	--UPDATE A SET 
	--In_Date =EIO.in_time,
	--OUT_Date =EIO.OUT_Time,
	--DURATION=DBO.F_RETURN_HOURS(DATEDIFF(S,IN_TIME,OUT_TIME))
	--FROM #ATT_MUSTER A INNER JOIN #Data EIO
	--ON A.EMP_ID = EIO.EMP_ID AND A.FOR_DATE = EIO.FOR_DATE
	
	UPDATE A SET LEAVE_COUNT = ISNULL(LEAVE_USED,0) + ISNULL(COMPOFF_USED,0)
	FROM #ATT_MUSTER A INNER JOIN T0140_LEAVE_TRANSACTION LT ON LT.EMP_ID = A.EMP_ID  AND LT.FOR_DATE = A.FOR_DATE 
	WHERE  (LT.LEAVE_USED > 0 OR LT.COMPOFF_USED > 0)
			
	
		
	UPDATE  A	SET WO_HO = 'W' 
	FROM	#ATT_MUSTER A 
	WHERE	EXISTS(SELECT 1 FROM #EMP_HW_CONS HW WHERE HW.Emp_ID=A.EMP_ID AND CHARINDEX(CAST(A.FOR_DATE AS VARCHAR(11)), HW.WeekOffDate + ';' + HW.CancelWeekOff) > 0 ) 
	
	
	
	
	UPDATE A SET WO_HO = CASE WHEN EH.IS_HALF = 1 THEN 'HHO' ELSE 'HO' END
	FROM #ATT_MUSTER A INNER JOIN
	#EMP_HOLIDAY EH ON A.FOR_DATE = EH.FOR_DATE AND A.EMP_ID = EH.EMP_ID
	
	
	UPDATE A SET STATUS_2 ='CO'	
	FROM #ATT_MUSTER A
	WHERE  STATUS = 'P' AND ( WO_HO = 'W' OR WO_HO = 'HO' ) AND ROW_ID = A.ROW_ID AND 
			FOR_DATE = A.FOR_DATE AND EMP_ID = A.EMP_ID
	
	
		
	UPDATE A SET IN_DATE= QRY.IN_TIME , OUT_DATE=QRY.OUT_TIME
	FROM #ATT_MUSTER A INNER JOIN
	(
		SELECT  MIN(IN_TIME) AS IN_TIME,MAX(OUT_TIME) as OUT_TIME,A.EMP_ID,A.FOR_DATE FROM T0150_EMP_INOUT_RECORD EIO 
		INNER JOIN #ATT_MUSTER A ON EIO.EMP_ID = A.EMP_ID AND EIO.FOR_DATE = A.FOR_DATE
		GROUP BY A.EMP_ID,A.FOR_DATE
	)QRY ON QRY.FOR_DATE = A.FOR_DATE AND QRY.EMP_ID = A.EMP_ID AND A.STATUS_2 = 'CO'
	
	UPDATE A SET DURATION=DBO.F_RETURN_HOURS(DATEDIFF(S,IN_DATE,OUT_DATE))
	FROM #ATT_MUSTER A INNER JOIN T0150_EMP_INOUT_RECORD EIO
	ON A.EMP_ID = EIO.EMP_ID AND A.FOR_DATE = EIO.FOR_DATE
	
	DELETE FROM #ATT_MUSTER WHERE OUT_DATE IS NULL AND IN_DATE IS NULL
	
	UPDATE #ATT_MUSTER
	SET STATUS =  DBO.F_RETURN_HHMM(CAST(DATEPART(HH,IN_DATE) AS VARCHAR(2))+ ':'+ CAST(DATEPART(MI,IN_DATE) AS VARCHAR(2)))
	WHERE STATUS = 'P'
	
	UPDATE #ATT_MUSTER
	SET STATUS_2 =  DBO.F_RETURN_HHMM(CAST(DATEPART(HH,OUT_DATE) AS VARCHAR(2))+ ':'+ CAST(DATEPART(MI,OUT_DATE) AS VARCHAR(2)))
	WHERE NOT OUT_DATE IS NULL

	

	--SELECT * FROM #ATT_MUSTER WHERE WO_HO = 'HHO' OR WO_HO = 'HO'
		
	/* COMMENTED BY  GADRIWALA MUSLIM 12102016 - START
	
	-- Added by Mitesh on 13/09/2011
	DECLARE @PREVIOUSEMP NUMERIC
	DECLARE @GENEFF_DATE DATETIME
	DECLARE @PREVISOUGENFORDATE DATETIME 	
	SET @PREVISOUGENFORDATE = '1900-01-01'
	SET @PREVIOUSEMP =0;
	DECLARE @WEEKOFF_DATE1_CANCELSTR AS VARCHAR(MAX)
	SET @WEEKOFF_DATE1_CANCELSTR = ''
	
	DECLARE @EMPBRANCH_ID AS NUMERIC
	DECLARE @EMP_IS_CANCEL_WEEKOFF AS NUMERIC(1,0)
	DECLARE @STRWEEKOFF_DATE AS VARCHAR(MAX)
	DECLARE @WEEKOFF_DAYS AS VARCHAR(MAX)
	DECLARE @CANCEL_WEEKOFF AS VARCHAR(MAX)
	DECLARE @EMP_IN_DATE AS DATETIME
	DECLARE @EMP_OUT_DATE AS DATETIME
	DECLARE @EMP_DURATION AS VARCHAR(10)
	DECLARE @EMP_IS_CANCEL_HOLIDAY AS NUMERIC(1,0) --ALTER BY ROHIT 16-JULY-2013
			
	DECLARE @STRHOLIDAY_DATE AS VARCHAR(MAX)--ALTER BY ROHIT 16-JULY-2013
	DECLARE @HOLIDAY_DAYS AS VARCHAR(MAX) --ALTER BY ROHIT 16-JULY-2013
	DECLARE @CANCEL_HOLIDAY AS VARCHAR(MAX)--ALTER BY ROHIT 16-JULY-2013
	DECLARE @STRCANCEL_WEEKOFF_DATE	VARCHAR(MAX)
	DECLARE @STRCANCEL_HOLIDAY_DATE	VARCHAR(MAX)
	
	DECLARE ATT_MUSTER_UPDATE CURSOR 
	FORWARD_ONLY
	FOR
	SELECT EMP_ID,CMP_ID,FOR_DATE,ROW_ID 
	FROM #ATT_MUSTER 
	WHERE FOR_DATE >=@FROM_DATE AND FOR_DATE <=@TO_DATE
	OPEN ATT_MUSTER_UPDATE
		FETCH NEXT FROM ATT_MUSTER_UPDATE INTO  @CUREMP_ID,@CURCMP_ID,@CURFOR_DATE,@CURROW_ID 
		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF EXISTS(SELECT IO_TRAN_ID FROM T0150_EMP_INOUT_RECORD WHERE EMP_ID = @CUREMP_ID AND NOT IN_TIME IS NULL AND FOR_DATE = @CURFOR_DATE)
				BEGIN
					UPDATE #ATT_MUSTER	SET STATUS = 'P' WHERE ROW_ID = @CURROW_ID AND FOR_DATE = @CURFOR_DATE
				END 
			IF EXISTS(SELECT LEAVE_USED FROM T0140_LEAVE_TRANSACTION WHERE EMP_ID = @CUREMP_ID AND FOR_DATE = @CURFOR_DATE AND (LEAVE_USED > 0 OR COMPOFF_USED > 0)) --CHANGED BY GADRIWALA MUSLIM 02102014
				BEGIN
					DECLARE @LEAVE_USED_COUNT NUMERIC(12,2)
					SELECT @LEAVE_USED_COUNT= ISNULL(LEAVE_USED,0) + ISNULL(COMPOFF_USED,0) FROM T0140_LEAVE_TRANSACTION WHERE EMP_ID = @CUREMP_ID AND FOR_DATE = @CURFOR_DATE AND (LEAVE_USED > 0 OR COMPOFF_USED > 0) --CHANGED BY GADRIWALA MUSLIM 02102014			
					UPDATE #ATT_MUSTER	SET LEAVE_COUNT = @LEAVE_USED_COUNT WHERE ROW_ID = @CURROW_ID AND FOR_DATE = @CURFOR_DATE					
				END 
			
			
			  -- Added by Gadriwala Muslim   -- 28032015 Start - For Initilized Value	
			SET @EMPBRANCH_ID = 0
			SET @EMPBRANCH_ID = 0
			SET @EMP_IS_CANCEL_WEEKOFF = 0
			SET @STRWEEKOFF_DATE = ''
			SET @WEEKOFF_DAYS = ''
			SET @CANCEL_WEEKOFF = ''
			SET @EMP_DURATION = ''
			SET @EMP_IS_CANCEL_HOLIDAY = 0
			SET @STRHOLIDAY_DATE = ''
			SET @HOLIDAY_DAYS= ''
			SET @CANCEL_HOLIDAY = ''
			SET @EMP_IN_DATE = NULL
			SET @EMP_OUT_DATE = NULL
			SET @EMP_DURATION = ''
			
			----For Cancel Weekoff/Holiday and Employee Has punch then calculate Overt time	----Ankit 29122015-------
			
			SET @STRCANCEL_WEEKOFF_DATE = ''
			SET @STRCANCEL_HOLIDAY_DATE = ''
			-------
			
			
			-- Added by Gadriwala Muslim   -- 28032015 End - For Initilized Value	
			
			
			SELECT TOP 1 @EMPBRANCH_ID=BRANCH_ID 
			FROM T0095_INCREMENT 
			WHERE EMP_ID = @CUREMP_ID AND INCREMENT_EFFECTIVE_DATE <= @CURFOR_DATE 
			ORDER BY INCREMENT_EFFECTIVE_DATE DESC
			
			SELECT TOP 1 @EMP_IS_CANCEL_WEEKOFF=IS_CANCEL_WEEKOFF,@EMP_IS_CANCEL_HOLIDAY=IS_CANCEL_HOLIDAY, @GENEFF_DATE=GS.FOR_DATE 
			FROM T0040_GENERAL_SETTING GS INNER JOIN
			(
				SELECT MAX(FOR_DATE)AS FOR_DATE,BRANCH_ID FROM T0040_GENERAL_SETTING 
				WHERE BRANCH_ID = @EMPBRANCH_ID
			)QRY ON QRY.FOR_DATE = GS.FOR_DATE AND QRY.BRANCH_ID = GS.BRANCH_ID 
			WHERE GS.BRANCH_ID = @EMPBRANCH_ID --CHANGE BY ROHIT 16-JULY-2013
			
			
			
			IF @PREVIOUSEMP <> 	@CUREMP_ID OR @PREVISOUGENFORDATE <> @GENEFF_DATE
			BEGIN				
				SET @EMP_IS_CANCEL_WEEKOFF = 0
				SET @STRWEEKOFF_DATE = ''
				SET @WEEKOFF_DAYS = 0
				SET @CANCEL_WEEKOFF = ''
				SET @EMP_IS_CANCEL_HOLIDAY = 0
				
				SET @STRHOLIDAY_DATE = ''
				SET @HOLIDAY_DAYS = 0
				SET @CANCEL_HOLIDAY = 0
				
				SET @STRCANCEL_WEEKOFF_DATE = ''
				SET @STRCANCEL_HOLIDAY_DATE = ''
				SET @WEEKOFF_DATE1_CANCELSTR = ''
				
				EXEC SP_EMP_WEEKOFF_DATE_GET @CUREMP_ID,@CURCMP_ID,@FROM_DATE,@TO_DATE,NULL,NULL,@EMP_IS_CANCEL_WEEKOFF, '',@STRWEEKOFF_DATE OUTPUT,@WEEKOFF_DAYS OUTPUT,0,0,0,0,@WEEKOFF_DATE1_CANCELSTR OUTPUT
				EXEC SP_EMP_HOLIDAY_DATE_GET @CUREMP_ID,@CURCMP_ID,@FROM_DATE,@TO_DATE,NULL,NULL,@EMP_IS_CANCEL_HOLIDAY,@STRHOLIDAY_DATE OUTPUT,@HOLIDAY_DAYS OUTPUT,@CANCEL_HOLIDAY OUTPUT,1	,0,NULL,0,0 ,@STRCANCEL_HOLIDAY_DATE OUTPUT --ALTER BY ROHIT 16-JULY-2013
				SET @PREVIOUSEMP = 	@CUREMP_ID
				SET @PREVISOUGENFORDATE = @GENEFF_DATE
				
				SELECT	@STRCANCEL_WEEKOFF_DATE = COALESCE ( @STRCANCEL_WEEKOFF_DATE + ';', '') + DATA 
				FROM	DBO.SPLIT(@WEEKOFF_DATE1_CANCELSTR,';')
				WHERE	DATA <> '' AND NOT EXISTS ( SELECT FOR_DATE FROM T0100_WEEKOFF_ROSTER WHERE EMP_ID = @CUREMP_ID AND IS_CANCEL_WO = 1 AND FOR_DATE <> CAST( DATA AS DATETIME ) )
				
				
			END

			--'' Ankit 08012016
			IF ISNULL(@StrCancel_Weekoff_Date,'') <> '' 
				SET @StrWeekoff_Date = @StrWeekoff_Date + @StrCancel_Weekoff_Date
			
			IF ISNULL(@StrCancel_Holiday_date,'') <> '' 
				SET @StrHoliday_Date = @StrHoliday_Date + @StrCancel_Holiday_date
			--
				
			if not Charindex(CONVERT(VARCHAR(11),@curFor_Date,109),@StrWeekoff_Date,0) = 0
				begin
					
					update #Att_Muster	set WO_HO = 'W' where Row_ID = @curRow_ID and For_Date = @curFor_Date And Emp_Id = @curEmp_Id
				end
	
			Update #Att_Muster	set Status_2 ='CO'	Where Status = 'P' and 	( WO_HO = 'W' or WO_HO = 'HO' ) and Row_ID = @curRow_ID and For_Date = @curFor_Date And Emp_Id = @curEmp_Id
			
			select TOP 1 @emp_in_date=MIN(in_time) from T0150_EMP_INOUT_RECORD where Emp_ID = @curEmp_Id and For_Date = @curFor_Date
			update #Att_Muster	set In_Date=@emp_in_date where Row_ID = @curRow_ID and For_Date = @curFor_Date and STatus_2 ='CO' And Emp_Id = @curEmp_Id
			

			
			select TOP 1 @emp_out_date=MAX(Out_Time) from T0150_EMP_INOUT_RECORD where Emp_ID = @curEmp_Id and For_Date = @curFor_Date
			update #Att_Muster	set Out_Date=@emp_out_date where Row_ID = @curRow_ID and For_Date = @curFor_Date and STatus_2 ='CO' And Emp_ID = @curEmp_Id
			
			
			
			select TOP 1 @emp_duration=dbo.F_Return_Hours(Datediff(s,@emp_in_date,@emp_out_date)) from T0150_EMP_INOUT_RECORD where Emp_ID = @curEmp_Id and For_Date = @curFor_Date and Out_Time = @emp_out_date
			update #Att_Muster	set Duration=@emp_duration where Row_ID = @curRow_ID and For_Date = @curFor_Date And Emp_ID = @curEmp_Id
					
					
			--Start by paras 13/07/2013 Holiday work not show in Holidayreport
			if not Charindex(CONVERT(VARCHAR(11),@curFor_Date,109),@StrHoliday_Date,0) = 0
				begin
					
					Declare @Is_Half_Holiday tinyint
					set @Is_Half_Holiday = 0
					select TOP 1 @Is_Half_Holiday= isnull(is_Half_day,0) from #Emp_Holiday where Emp_Id = @curEmp_Id and For_Date = @curFor_Date
					
					if @Is_Half_Holiday = 0 			
						update #Att_Muster	set WO_HO = 'HO' where Row_ID = @curRow_ID and For_Date = @curFor_Date And Emp_Id = @curEmp_Id
					else
						update #Att_Muster	set WO_HO = 'HHO' where Row_ID = @curRow_ID and For_Date = @curFor_Date And Emp_Id = @curEmp_Id
					
				end
				
			Update #Att_Muster	set Status_2 ='CO'	Where  WO_HO = 'HO'  and Row_ID = @curRow_ID and For_Date = @curFor_Date And Emp_Id = @curEmp_Id
			
			select TOP 1 @emp_in_date=MIN(in_time) from T0150_EMP_INOUT_RECORD where Emp_ID = @curEmp_Id and For_Date = @curFor_Date
			update #Att_Muster	set In_Date=@emp_in_date where Row_ID = @curRow_ID and For_Date = @curFor_Date and STatus_2 ='CO' And Emp_Id = @curEmp_Id
			

			
			select @emp_out_date=MAX(Out_Time) from T0150_EMP_INOUT_RECORD where Emp_ID = @curEmp_Id and For_Date = @curFor_Date
			update #Att_Muster	set Out_Date=@emp_out_date where Row_ID = @curRow_ID and For_Date = @curFor_Date and STatus_2 ='CO' And Emp_ID = @curEmp_Id
				
			
			
			select TOP 1 @emp_duration=dbo.F_Return_Hours(Datediff(s,@emp_in_date,@emp_out_date)) from T0150_EMP_INOUT_RECORD where Emp_ID = @curEmp_Id and For_Date = @curFor_Date and Out_Time = @emp_out_date
			update #Att_Muster	set Duration=@emp_duration where Row_ID = @curRow_ID and For_Date = @curFor_Date And Emp_ID = @curEmp_Id
				
			--End			
			
			Fetch next from att_muster_update INTO  @curEmp_Id,@curCmp_ID,@curFor_Date,@curRow_ID
		End
	close att_muster_update	
	deallocate att_muster_update 
	
	
	*/
	
	
	-- Old Code commented by Mitesh on 13/09/2011
	--update #Att_Muster
	--set Status = 'P'
	--from #Att_Muster AM inner join T0150_EMP_INOUT_RECORD EIR ON AM.EMP_ID = EIR.EMP_ID
	--AND AM.FOR_DATE = EIR.FOR_DATE 
	--where NOT EIR.IN_TIME IS NULL
	--and Am.For_Date >=@From_Date and Am.For_Date <=@To_Date
	
	--update #Att_Muster
	--set Leave_Count = Leave_Used
	--from #Att_Muster AM inner join T0140_LEAVE_TRANSACTION LT ON AM.EMP_ID = LT.EMP_ID
	--AND AM.FOR_DATE = LT.FOR_DATE 
	--where LT.Leave_Used  >0
	--and Am.For_Date >=@From_Date and Am.For_Date <=@To_Date
	
	
	
	--Update #Att_Muster 
	--set WO_HO = 'W'
	--From #Att_Muster   AM inner join 
	--( select ESD.* from T0100_WEEKOFF_ADJ ESD inner join 
	--	( select max(For_Date)as For_Date ,Emp_ID from T0100_WEEKOFF_ADJ 
	--	where For_Date <= @For_Date and Cmp_Id = @Cmp_ID
	--	group by emp_ID )Q on ESD.emp_ID =Q.Emp_ID and ESD.For_DAte = Q.For_Date)Q_W 
	--	on AM.Emp_ID = Q_W.Emp_Id
	--where charindex(datename(dw,AM.For_Date),Q_W.weekoff_day,0) >0
	--and Am.For_Date >=@From_Date and Am.For_Date <=@To_Date
									
	--Update #Att_Muster
	--set Status_2 ='CO'
	--Where Status = 'P' and 	( WO_HO = 'W' or WO_HO = 'HO' )
	--and For_Date >=@From_Date and For_Date <=@To_Date
	
	
	--Update #Att_Muster
	--Set In_Date =In_time
	--From #Att_Muster AM inner join 
	--( select min(In_Time) In_Time ,Emp_Id,For_Date from T0150_EMP_INOUT_RECORD
	--	Where Cmp_ID = @cmp_ID and For_Date>=@From_Date and For_Date <=@To_Date
	--	group by Emp_ID ,for_date 
	--)q on Am.Emp_ID =q.emp_ID  and am.for_Date = Q.for_Date
	--where STatus_2 ='CO'

	--Update #Att_Muster
	--Set Out_Date = OUT_Time,
	--	Duration = q.Duration
	--From #Att_Muster AM inner join 
	--(select q1.Out_Time,Duration,q1.Emp_Id,Q1.For_date From T0150_EMP_INOUT_RECORD EIR Inner join 
	--( select Max(Out_Time) OUT_Time ,Emp_Id,For_Date from T0150_EMP_INOUT_RECORD
	--	Where Cmp_ID = @cmp_ID and For_Date>=@From_Date and For_Date <=@To_Date
	--	group by Emp_ID ,for_date )q1 on EIr.Emp_ID = Q1.Emp_ID and EIR.For_Date =Q1.for_Date and eir.Out_Time =q1.out_Time
	--)q on Am.Emp_ID =q.emp_ID  and am.for_Date = Q.for_Date
	--where STatus_2 ='CO'
	


	-- Changed By Gadriwala 21012014 - E.Emp_Code to E.Alpha_Emp_Code
	--Ronakb010824 add vertical for groupby
	IF @REPORT_FOR = 0

		BEGIN
		SELECT AM.* , E.ALPHA_EMP_CODE,E.EMP_FULL_NAME ,TYPE_NAME,BRANCH_ADDRESS,COMP_NAME
			, BRANCH_NAME , DEPT_NAME ,GRD_NAME ,DESIG_NAME,V.Vertical_Name,SubVertical_Name,SubBranch_Name,CMP_ADDRESS,CMP_NAME
			,@FROM_DATE AS P_FROM_DATE ,@TO_DATE AS P_TO_DATE,BM.BRANCH_ID,E.ENROLL_NO
		FROM #ATT_MUSTER  AM INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON AM.EMP_ID = E.EMP_ID
		INNER JOIN #EMP_CONS EC ON EC.EMP_ID = AM.EMP_ID
		INNER JOIN T0095_INCREMENT IE WITH (NOLOCK) ON IE.INCREMENT_ID = EC.INCREMENT_ID
		 /* COMMENTED BY GADRIWALA MUSLIM 12102016 INCREMENT_ID DIRECT  USE FROM #EMP_CONS
		 ( SELECT I.BRANCH_ID,I.GRD_ID,I.DEPT_ID,I.DESIG_ID,I.EMP_ID ,TYPE_ID FROM T0095_INCREMENT I INNER JOIN 
						( SELECT MAX(INCREMENT_ID) AS INCREMENT_ID , EMP_ID FROM T0095_INCREMENT	-- ANKIT 08092014 FOR SAME DATE INCREMENT
						WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
						AND CMP_ID = @CMP_ID
						GROUP BY EMP_ID  ) QRY ON
						I.EMP_ID = QRY.EMP_ID	AND I.INCREMENT_ID = QRY.INCREMENT_ID	)Q_I ON
			E.EMP_ID = Q_I.EMP_ID */
		INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON IE.GRD_ID = GM.GRD_ID 
		INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON IE.BRANCH_ID = BM.BRANCH_ID 
		LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON IE.DEPT_ID = DM.DEPT_ID 
		LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON IE.DESIG_ID = DGM.DESIG_ID 
		LEFT OUTER JOIN T0040_Vertical_Segment V WITH (NOLOCK) ON IE.Vertical_ID = V.Vertical_ID
        LEFT OUTER JOIN T0050_SubVertical SV WITH (NOLOCK) ON IE.SubVertical_ID = SV.SubVertical_ID 
        LEFT OUTER JOIN T0050_SubBranch SB  WITH (NOLOCK) ON IE.SubBranch_ID = SB.SubBranch_ID 
		LEFT OUTER JOIN T0040_TYPE_MASTER TM WITH (NOLOCK) ON IE.TYPE_ID =TM.TYPE_ID 
		INNER JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) ON AM.CMP_ID = CM.CMP_ID
		ORDER BY EMP_CODE,AM.FOR_DATE
	end
	/* COMMENTED BY GADRIWALA MUSLIM 12102016 - AS PER DISCUSSION WITH HARDIK BHAI NOT REQUIRE THIS FORMAT.    ELSE IF @REPORT_FOR = 1                  --ADDED JIMIT 18082015
		begin
			SELECT AM.* , E.ALPHA_EMP_CODE,E.EMP_FULL_NAME ,TYPE_NAME,BRANCH_ADDRESS,COMP_NAME
			, BRANCH_NAME , DEPT_NAME ,GRD_NAME , DESIG_NAME,CMP_ADDRESS,CMP_NAME
			,@FROM_DATE AS P_FROM_DATE ,@TO_DATE AS P_TO_DATE,BM.BRANCH_ID			
		,MS.DAY_SALARY
		FROM #ATT_MUSTER  AM INNER JOIN T0080_EMP_MASTER E ON AM.EMP_ID = E.EMP_ID
		INNER JOIN #EMP_CONS EC ON EC.EMP_ID = AM.EMP_ID
		INNER JOIN T0095_INCREMENT IE ON IE.INCREMENT_ID = EC.INCREMENT_ID
		/* COMMENTED BY GADRIWALA MUSLIM 12102016 INCREMENT_ID DIRECT  USE FROM #EMP_CONS
		INNER JOIN ( SELECT I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Emp_ID ,TYPE_ID,I.Increment_ID FROM T0095_Increment I inner join 
						( select max(Increment_ID) as Increment_ID , Emp_ID From T0095_Increment	
						where Increment_Effective_date <= @To_Date
						and Cmp_ID = @Cmp_ID
						group by emp_ID  ) Qry on
						I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID	)Q_I ON
			E.EMP_ID = Q_I.EMP_ID */
			INNER JOIN T0040_GRADE_MASTER GM ON IE.GRD_ID = GM.GRD_ID 
			INNER JOIN T0030_BRANCH_MASTER BM ON IE.BRANCH_ID = BM.BRANCH_ID 
			LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM ON IE.DEPT_ID = DM.DEPT_ID LEFT OUTER JOIN 
			T0040_DESIGNATION_MASTER DGM ON IE.DESIG_ID = DGM.DESIG_ID LEFT OUTER JOIN 
			T0040_TYPE_MASTER TM ON IE.TYPE_ID =TM.TYPE_ID INNER JOIN 
			T0010_COMPANY_MASTER CM ON AM.CMP_ID = CM.CMP_ID  INNER JOIN 
			T0200_MONTHLY_SALARY MS ON MS.CMP_ID = CM.CMP_ID AND MS.EMP_ID = E.EMP_ID AND MS.INCREMENT_ID = IE.INCREMENT_ID		
		ORDER BY EMP_CODE,AM.FOR_DATE	
		end*/
	RETURN




