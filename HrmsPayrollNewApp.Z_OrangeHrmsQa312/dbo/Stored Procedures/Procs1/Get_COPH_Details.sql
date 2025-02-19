

CREATE PROCEDURE [dbo].[Get_COPH_Details]
	@FOR_DATE DATETIME,
	@CMP_ID NUMERIC(18,0),
	@EMP_ID  NUMERIC(18,0),
	@LEAVE_ID NUMERIC(18,0),
	@LEAVE_APPLICATION_ID NUMERIC(18,0) = 0,
	@EXEC_FOR NUMERIC(18,0) = 0,
	@LEAVE_PERIOD NUMERIC(18,2) = 0 -- ADDED BY GADRIWALA MUSLIM 18052015	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON
	
	DECLARE @MONTH_ST_DATE AS DATETIME
	DECLARE @MONTH_END_DATE AS DATETIME
	
	SET @MONTH_ST_DATE = dbo.GET_MONTH_ST_DATE(MONTH(GETDATE()),YEAR(GETDATE())) -- ADDED BY GADRIWALA MUSLIM 06-06-2016 FOR ADVANCE COPH
	SET @MONTH_END_DATE = CONVERT(DATE,GETDATE()) -- ADDED BY GADRIWALA MUSLIM 06-06-2016 FOR ADVANCE COPH
	--dbo.GET_MONTH_END_DATE(MONTH(GETDATE()),YEAR(GETDATE()))
	IF OBJECT_ID('tempdb..#Emp_WeekOff') IS NULL   -- ADDED BY GADRIWALA MUSLIM 06-06-2016 FOR ADVANCE COPH
		BEGIN
		
		
			CREATE TABLE #EMP_CONS(EMP_ID NUMERIC, BRANCH_ID NUMERIC, INCREMENT_ID NUMERIC);
			
			
			INSERT INTO #EMP_CONS(EMP_ID,BRANCH_ID,INCREMENT_ID)
			SELECT IE.EMP_ID,IE.BRANCH_ID,IE.INCREMENT_ID  FROM T0095_INCREMENT IE WITH (NOLOCK) INNER JOIN
			(
				SELECT MAX(IE.INCREMENT_ID) AS INCREMENT_ID FROM T0095_INCREMENT IE  WITH (NOLOCK) INNER JOIN
				( 
					SELECT MAX(IE.INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE FROM T0095_INCREMENT IE  WITH (NOLOCK) 
					WHERE IE.CMP_ID = @CMP_ID AND IE.EMP_ID = @EMP_ID AND IE.INCREMENT_EFFECTIVE_DATE < @FOR_DATE	
				)INNER_QRY ON INNER_QRY.INCREMENT_EFFECTIVE_DATE = IE.INCREMENT_EFFECTIVE_DATE 
				WHERE IE.EMP_ID = @EMP_ID AND IE.INCREMENT_EFFECTIVE_DATE < @FOR_DATE	AND IE.CMP_ID = @CMP_ID 
			)IN_QRY ON  IN_QRY.INCREMENT_ID = IE.INCREMENT_ID
			WHERE IE.EMP_ID = @EMP_ID AND IE.CMP_ID = @CMP_ID 
		
			CREATE TABLE #EMP_WEEKOFF_HOLIDAY
			(
				EMP_ID				NUMERIC,
				WEEKOFFDATE			VARCHAR(MAX),
				WEEKOFFCOUNT		NUMERIC(3,1),
				HOLIDAYDATE			VARCHAR(MAX),
				HOLIDAYCOUNT		NUMERIC(3,1),
				HALFHOLIDAYDATE		VARCHAR(MAX),
				HALFHOLIDAYCOUNT	NUMERIC(3,1),
				OPTHOLIDAYDATE		VARCHAR(MAX),
				OPTHOLIDAYCOUNT		NUMERIC(3,1)
			)
	
	
		
			CREATE TABLE #EMP_WEEKOFF
			(
				ROW_ID			NUMERIC,
				EMP_ID			NUMERIC,
				FOR_DATE		DATETIME,
				WEEKOFF_DAY		VARCHAR(10),
				W_DAY			NUMERIC(3,1),
				IS_CANCEL		BIT
			)
			CREATE CLUSTERED INDEX IX_Emp_WeekOff_EMPID_FORDATE ON #Emp_WeekOff(Emp_ID,For_Date);
			
			CREATE TABLE #EMP_HOLIDAY
			(	EMP_ID NUMERIC, 
				FOR_DATE DATETIME, 
				IS_CANCEL BIT, 
				Is_Half tinyint, 
				Is_P_Comp tinyint, 
				H_DAY numeric(3,1)
			);
			CREATE UNIQUE CLUSTERED INDEX IX_EMP_HOLIDAY_EMPID_FORDATE ON #EMP_HOLIDAY(EMP_ID, FOR_DATE);
			
		
			EXEC SP_GET_HW_ALL @CONSTRAINT=@EMP_ID,@CMP_ID=@CMP_ID, @FROM_DATE=@MONTH_ST_DATE, @TO_DATE=@MONTH_END_DATE, @ALL_WEEKOFF = 0, @EXEC_MODE=0
			--EXEC SP_GET_HW_ALL @CONSTRAINT=@EMP_ID,@CMP_ID=@CMP_ID, @FROM_DATE='01-Aug-2016', @TO_DATE='31-Aug-2016', @ALL_WEEKOFF = 0, @EXEC_MODE=0
		
		--select * from #EMP_HOLIDAY
		END
		
		DECLARE @HOLIDAY_STR AS NVARCHAR(MAX) -- ADDED BY GADRIWALA MUSLIM 06-06-2016 FOR ADVANCE COPH
		DECLARE @WEEKOFF_STR AS NVARCHAR(MAX) -- ADDED BY GADRIWALA MUSLIM 06-06-2016 FOR ADVANCE COPH
		
		SET @HOLIDAY_STR = ''
		SET @WEEKOFF_STR = ''
		
			
		--select * from #EMP_WEEKOFF_HOLIDAY
		
		
		SELECT @HOLIDAY_STR =(HOLIDAYDATE + ISNULL(OPTHOLIDAYDATE,'')),@WEEKOFF_STR = WEEKOFFDATE  FROM #EMP_WEEKOFF_HOLIDAY -- ADDED BY GADRIWALA MUSLIM 06-06-2016 FOR ADVANCE COPH
		
		
	CREATE TABLE #COPH_OT
		(
			Leave_Tran_ID			numeric,
			Cmp_ID					numeric,
			Emp_ID					numeric,
			For_Date				datetime,
			COPH_Credit				numeric(18,2),
			COPH_Debit				numeric(18,2),
			COPH_balance			numeric(18,2),
			Branch_ID				numeric,
			Is_CompOff				numeric,
			COPH_Days_Limit			numeric,
			COPH_Type				varchar(4),
			Selected				tinyint
		)
	
	declare @branch_id as numeric(18,0)
	declare @COPH_Avail_limit as numeric(18,0)
	declare @COPH_From_Date as varchar(25)
	
	
	set @COPH_Avail_limit = 0
	
	
	
	DECLARE @TYPE_ID AS NUMERIC(18,0)
	SELECT @TYPE_ID = TYPE_ID , @BRANCH_ID = BRANCH_ID FROM T0095_INCREMENT IE  WITH (NOLOCK) INNER JOIN
	(
		SELECT MAX(IE.INCREMENT_ID) AS INCREMENT_ID FROM T0095_INCREMENT IE  WITH (NOLOCK) INNER JOIN
		( 
			SELECT MAX(IE.INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE FROM T0095_INCREMENT IE  WITH (NOLOCK) 
			WHERE IE.CMP_ID = @CMP_ID AND IE.EMP_ID = @EMP_ID AND IE.INCREMENT_EFFECTIVE_DATE < @FOR_DATE	
		)INNER_QRY ON INNER_QRY.INCREMENT_EFFECTIVE_DATE = IE.INCREMENT_EFFECTIVE_DATE 
		WHERE IE.EMP_ID = @EMP_ID AND IE.INCREMENT_EFFECTIVE_DATE < @FOR_DATE	AND IE.CMP_ID = @CMP_ID 
	)IN_QRY ON  IN_QRY.INCREMENT_ID = IE.INCREMENT_ID
	WHERE IE.EMP_ID = @EMP_ID AND IE.CMP_ID = @CMP_ID 
	
	
	select @COPH_Avail_limit = COPH_Avail_limit
	From dbo.T0040_GENERAL_SETTING  WITH (NOLOCK) where cmp_ID = @cmp_ID and Branch_ID = @branch_id
		and For_Date = ( select max(For_Date) from dbo.T0040_GENERAL_SETTING  WITH (NOLOCK) 
			where For_Date <= @For_Date and Branch_ID = @branch_id and Cmp_ID = @Cmp_ID)    
	

	
	set @COPH_From_Date = CONVERT(VARCHAR(25),DATEADD(D,@COPH_AVAIL_LIMIT * -1,@FOR_DATE));
	
	
	
	DECLARE @LEAVE_CREDIT_DAYS as NUMERIC(18,2)
	
	
					
    SELECT @LEAVE_CREDIT_DAYS = ISNULL(CF_M_DAYS,0) FROM T0050_LEAVE_CF_MONTHLY_SETTING LCF  WITH (NOLOCK) INNER JOIN		
	(
		SELECT MAX(EFFECTIVE_DATE) AS EFFECTIVE_DATE
		FROM T0050_LEAVE_CF_MONTHLY_SETTING  WITH (NOLOCK) 
		WHERE CMP_ID = @CMP_ID AND LEAVE_ID = @LEAVE_ID AND CF_M_DAYS > 0 AND TYPE_ID = @TYPE_ID 
		
	)QRY ON QRY.EFFECTIVE_DATE = LCF.EFFECTIVE_DATE 
	WHERE CMP_ID = @CMP_ID AND LEAVE_ID = @LEAVE_ID AND TYPE_ID = @TYPE_ID AND CF_M_DAYS > 0
	
	
	
	IF ( @LEAVE_CREDIT_DAYS IS NULL) OR (@LEAVE_CREDIT_DAYS = 0)
	 SET @LEAVE_CREDIT_DAYS = 1
	 
	 --	SELECT 0 AS LEAVE_TRAN_ID,@CMP_ID AS CMP_ID,@EMP_ID AS EMP_ID,HD.DATA AS FOR_DATE,@LEAVE_CREDIT_DAYS AS COPH_CREDIT ,0 AS COPH_DEBIT,
		--@LEAVE_CREDIT_DAYS AS COPH_BALANCE,@BRANCH_ID AS BRANCH_ID,1 AS IS_COMPOFF,@COPH_AVAIL_LIMIT AS COPH_DAYS_LIMIT ,'COPH' AS COPH_TYPE 
		--FROM SPLIT(@HOLIDAY_STR,';') HD INNER JOIN SPLIT(@WEEKOFF_STR,';') WO ON HD.DATA = WO.DATA LEFT OUTER JOIN
		--DBO.T0140_LEAVE_TRANSACTION LT ON LT.FOR_DATE = HD.DATA AND LT.EMP_ID = @EMP_ID AND LT.LEAVE_ID = @LEAVE_ID AND LT.CompOff_Balance > 0
		--LEFT OUTER JOIN T0200_MONTHLY_SALARY MS ON MONTH(MS.MONTH_END_DATE) = MONTH(GETDATE()) AND YEAR(MS.MONTH_END_DATE) = YEAR(GETDATE()) AND MS.EMP_ID = @EMP_ID
		--WHERE HD.DATA <> ''  AND LT.FOR_DATE IS NULL AND MS.MONTH_END_DATE IS NULL
		--return
		
		--SELECT @COPH_FROM_DATE,@FOR_DATE
		--SELECT * FROM SPLIT(@HOLIDAY_STR,';')
		----SELECT * FROM SPLIT(@WEEKOFF_STR,';')
		
	
		INSERT INTO #COPH_OT(LEAVE_TRAN_ID,CMP_ID,EMP_ID,FOR_DATE,COPH_CREDIT,COPH_DEBIT,COPH_BALANCE,BRANCH_ID,IS_COMPOFF,COPH_DAYS_LIMIT,COPH_TYPE,Selected)
				SELECT LEAVE_TRAN_ID,@CMP_ID,@EMP_ID,FOR_DATE,COMPOFF_CREDIT,COMPOFF_DEBIT,COMPOFF_BALANCE,
				@BRANCH_ID,COMOFF_FLAG,@COPH_AVAIL_LIMIT,'COPH',0 FROM DBO.T0140_LEAVE_TRANSACTION  WITH (NOLOCK) 
				WHERE LEAVE_ID = @LEAVE_ID AND FOR_DATE >= CAST(@COPH_FROM_DATE AS DATETIME) AND FOR_DATE <=@FOR_DATE AND CMP_ID = @CMP_ID AND EMP_ID = @EMP_ID AND COMOFF_FLAG = 1
				AND (COMPOFF_CREDIT> 0 OR COMPOFF_DEBIT > 0 OR COMPOFF_BALANCE > 0)
		UNION	-- ADDED BY GADRIWALA MUSLIM 06-06-2016 FOR ADVANCE COPH
		SELECT 0 AS LEAVE_TRAN_ID,@CMP_ID AS CMP_ID,@EMP_ID AS EMP_ID,HD.DATA AS FOR_DATE,@LEAVE_CREDIT_DAYS AS COPH_CREDIT ,0 AS COPH_DEBIT,
		@LEAVE_CREDIT_DAYS AS COPH_BALANCE,@BRANCH_ID AS BRANCH_ID,1 AS IS_COMPOFF,@COPH_AVAIL_LIMIT AS COPH_DAYS_LIMIT ,'COPH' AS COPH_TYPE,0
		FROM SPLIT(@HOLIDAY_STR,';') HD INNER JOIN 
			SPLIT(@WEEKOFF_STR,';') WO ON HD.DATA = WO.DATA LEFT OUTER JOIN
			DBO.T0140_LEAVE_TRANSACTION LT  WITH (NOLOCK) ON LT.FOR_DATE = HD.DATA AND LT.EMP_ID = @EMP_ID AND LT.LEAVE_ID = @LEAVE_ID AND LT.CompOff_Balance > 0
		LEFT OUTER JOIN T0200_MONTHLY_SALARY MS  WITH (NOLOCK) ON MONTH(MS.MONTH_END_DATE) = MONTH(GETDATE()) AND YEAR(MS.MONTH_END_DATE) = YEAR(GETDATE()) AND MS.EMP_ID = @EMP_ID
		WHERE HD.DATA <> ''  AND LT.FOR_DATE IS NULL AND MS.MONTH_END_DATE IS NULL
		AND CAST(HD.DATA AS DATETIME) >= CAST(@COPH_FROM_DATE AS DATETIME) AND CAST(HD.DATA AS DATETIME) <= @FOR_DATE
		
		--select * from #COPH_OT
		
	Create Table #Leave_Applied
	(
		Leave_Date datetime,
		Leave_Period numeric(18,2)
	 )
	 Create Table #Leave_Approved
	(
		Leave_Appr_Date datetime,
		Leave_Period numeric(18,2)
	 )
	  Create Table #Leave_Level_Approved
	(
		Leave_Appr_Date datetime,
		Leave_Period numeric(18,2)
	 )
	Declare @strLeave_COPH_dates varchar(max)
	set @strLeave_COPH_dates = ''
	
	if @Leave_Application_ID = 0 
		begin
		
			select  @strLeave_COPH_dates = @strLeave_COPH_dates + '#' + Leave_CompOff_Dates  
			from dbo.V0110_LEAVE_APPLICATION_DETAIL VLAD left  join
			(
				select  Leave_Application_ID from dbo.T0115_Leave_Level_Approval LLA  WITH (NOLOCK) inner join
				(
									select max(Tran_ID) as Tran_ID from  dbo.T0115_Leave_Level_Approval LLA  WITH (NOLOCK) inner join 
									dbo.T0100_LEAVE_APPLICATION  LA  WITH (NOLOCK) on LLA.Leave_Application_ID = LA.Leave_Application_ID and LLA.Emp_ID = La.Emp_ID and Application_Status = 'P'
									where LLA.Emp_ID = @Emp_ID and Approval_Status = 'A' and Leave_ID = @Leave_ID and LLA.cmp_ID = @cmp_ID  group by LLA.Leave_Application_ID
				)sub_Qry on Sub_Qry.Tran_ID = LLA.Tran_ID
				
			 ) Qry on Qry.Leave_Application_ID = VLAD.LEave_Application_ID  
			where Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID 
			and Application_Status = 'P' and Leave_ID = @leave_ID 
			and  isnull(Leave_CompOff_Dates,'') <> '' 
			and  isnull(Qry.Leave_Application_ID ,0)=0
			
		
		end
	else
		begin
			
			select  @strLeave_COPH_dates = @strLeave_COPH_dates + '#' + Leave_CompOff_Dates  
			from dbo.V0110_LEAVE_APPLICATION_DETAIL VLAD left outer join
			(
				select  Leave_Application_ID from dbo.T0115_Leave_Level_Approval LLA  WITH (NOLOCK) inner join
				(
									select max(Tran_ID) as Tran_ID from  dbo.T0115_Leave_Level_Approval LLA  WITH (NOLOCK) inner join 
									dbo.T0100_LEAVE_APPLICATION  LA  WITH (NOLOCK) on LLA.Leave_Application_ID = LA.Leave_Application_ID and LLA.Emp_ID = La.Emp_ID and Application_Status = 'P'
									where LLA.Emp_ID = @Emp_ID and Approval_Status = 'A' and Leave_ID = @Leave_ID and LLA.cmp_ID = @cmp_ID group by LLA.Leave_Application_ID
				)sub_Qry on Sub_Qry.Tran_ID = LLA.Tran_ID
				
			 ) Qry on Qry.Leave_Application_ID <> VLAD.LEave_Application_ID  
			where Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID 
			and Application_Status = 'P' and Leave_ID = @leave_ID 
			and  isnull(Leave_CompOff_Dates,'') <> '' 			
			--and VLAD.Leave_Application_ID <> @Leave_Application_ID 
		end	
		
		Insert into #Leave_Applied(Leave_date,Leave_Period)
		select  Left(DATA,CHARINDEX(';',DATA)-1),SUBSTRING(DATA,CHARINDEX(';',DATA)+1,10) 
		from dbo.SPlit(@strLeave_COPH_dates,'#') where Data <> ''	
		
		
		
		update CP set CP.Selected=1 
		from #COPH_OT CP inner join #Leave_Applied LA
		on CP.For_Date=LA.Leave_Date and CP.COPH_Credit=LA.Leave_Period
		where CP.Cmp_ID=@CMP_ID
		
		
		
		--select * from dbo.V0110_LEAVE_APPLICATION_DETAIL where Emp_ID=@EMP_ID and Cmp_ID=@CMP_ID and Leave_Application_ID <> @LEAVE_APPLICATION_ID and Application_Status = 'P' and Leave_ID = @leave_ID
		IF Exists(select 1 from dbo.V0110_LEAVE_APPLICATION_DETAIL where Emp_ID=@EMP_ID and Cmp_ID=@CMP_ID and Leave_Application_ID = @LEAVE_APPLICATION_ID and Application_Status = 'P' and Leave_ID = @leave_ID)
			Begin
				--truncate table #Leave_Applied;
				Delete from #Leave_Applied;
			End			
		
	
		set @strLeave_COPH_dates = ''
	
	
	If @Leave_Application_ID > 0 
		begin
			select @strLeave_COPH_dates = @strLeave_COPH_dates + '#' + isnull(Leave_CompOff_Dates,'')   
			from  dbo.V0130_Leave_Approval_Details where Leave_Application_ID = @Leave_Application_ID and Approval_Status = 'A' and Cmp_ID = @Cmp_ID
		end	
	else -- ADDED BY GADRIWALA MUSLIM 06-06-2016 FOR ADVANCE COPH
		begin
			
			IF NOT EXISTS (SELECT 1 FROM	T0200_MONTHLY_SALARY MS   WITH (NOLOCK) WHERE  EMP_ID = @EMP_ID AND MONTH(MS.MONTH_END_DATE) = MONTH(GETDATE()) AND YEAR(MS.MONTH_END_DATE) = YEAR(GETDATE()))
				BEGIN
					select @strLeave_COPH_dates = @strLeave_COPH_dates + '#' + isnull(Leave_CompOff_Dates,'')   
					FROM  DBO.V0130_LEAVE_APPROVAL_DETAILS 
					where Leave_ID = @leave_ID AND MONTH(GETDATE()) = MONTH(SYSTEM_DATE) 
					AND YEAR(GETDATE()) = YEAR(SYSTEM_DATE) AND APPROVAL_STATUS = 'A' AND CMP_ID = @CMP_ID and Emp_ID = @EMP_ID
				END
		end	
		
		
	IF @LEAVE_APPLICATION_ID > 0
		BEGIN	
			INSERT INTO #LEAVE_APPROVED	(LEAVE_APPR_DATE,LEAVE_PERIOD)
			SELECT  LEFT(DATA,CHARINDEX(';',DATA)-1),SUBSTRING(DATA,CHARINDEX(';',DATA)+1,10) 
			FROM DBO.SPLIT(@STRLEAVE_COPH_DATES,'#') WHERE DATA <> ''
		END
	ELSE -- ADDED BY GADRIWALA MUSLIM 06-06-2016 FOR ADVANCE COPH
		BEGIN
			 INSERT INTO #LEAVE_APPROVED	(LEAVE_APPR_DATE,LEAVE_PERIOD)
		   	 SELECT  LEFT(DATA,CHARINDEX(';',DATA)-1),SUBSTRING(DATA,CHARINDEX(';',DATA)+1,10) 
			 FROM DBO.SPLIT(@STRLEAVE_COPH_DATES,'#') WHERE  DATA <> ''
		
			 DELETE FROM #LEAVE_APPROVED WHERE LEAVE_APPR_DATE NOT BETWEEN @MONTH_ST_DATE AND @MONTH_END_DATE 
			 
		END
		
	
	set @strLeave_COPH_dates = ''
	If @Leave_Application_ID > 0  
		begin
			select @strLeave_COPH_dates = @strLeave_COPH_dates + '#' + isnull(Leave_CompOff_dates,'') 
			from dbo.T0115_Leave_Level_Approval LLA  WITH (NOLOCK) Inner join
			(
				select max(Tran_ID) as Tran_ID from  dbo.T0115_Leave_Level_Approval LLA  WITH (NOLOCK) inner join
				dbo.T0100_LEAVE_APPLICATION LA  WITH (NOLOCK) on LLA.Leave_Application_ID = LA.Leave_Application_ID and LLA.Emp_ID =LA.Emp_ID and LA.Application_Status = 'P'
				where LA.Emp_ID = @Emp_ID and Approval_Status = 'A' and Leave_ID = @Leave_ID   and LA.cmp_ID = @Cmp_ID
				group by LLA.Leave_Application_ID
			 )	Qry on Qry.Tran_ID = LLA.Tran_ID
			where Leave_Application_ID <> @Leave_Application_ID
		end
	else
		begin
			select @strLeave_COPH_dates = @strLeave_COPH_dates + '#' + isnull(Leave_CompOff_dates,'') 
			from dbo.T0115_Leave_Level_Approval LLA  WITH (NOLOCK) inner join 
			(
				select max(Tran_ID) as Tran_ID from  dbo.T0115_Leave_Level_Approval LLA  WITH (NOLOCK)  inner join 
				dbo.T0100_LEAVE_APPLICATION LA  WITH (NOLOCK) on LA.Leave_Application_ID = LLA.Leave_Application_ID and  LA.Emp_ID = LLA.Emp_ID and Application_Status = 'P'
				where LLA.Emp_ID = @Emp_ID and Approval_Status = 'A' and Leave_ID = @Leave_ID and LLA.Cmp_ID = @Cmp_ID
				group by LLA.Leave_Application_ID
			)  Qry on Qry.Tran_ID = LLA.Tran_ID
		end
	
		
	
		Insert into #Leave_Level_Approved(Leave_Appr_Date,Leave_Period)
		select  Left(DATA,CHARINDEX(';',DATA)-1),SUBSTRING(DATA,CHARINDEX(';',DATA)+1,10) 
		from dbo.SPlit(@strLeave_COPH_dates,'#') where Data <> ''
		
		
	
	    	Update #COPH_OT set COPH_Debit = COPH_Debit + Qry.Leave_Period,
			COPH_balance	= COPH_balance - Qry.Leave_Period from #COPH_OT GOT 
			inner join (select isnull(SUM(leave_Period),0) as Leave_Period,Leave_Date
			from  #Leave_Applied LA Group By Leave_Date) Qry on Qry.Leave_Date = For_Date		
		
			Update #COPH_OT set COPH_Debit = COPH_Debit + Qry.Leave_Period,
			COPH_balance	= COPH_balance - Qry.Leave_Period from #COPH_OT GOT 
			inner join (select isnull(SUM(leave_Period),0) as Leave_Period,Leave_Appr_Date 
			from  #Leave_Level_Approved LA Group By Leave_Appr_Date) Qry on Qry.Leave_Appr_Date = For_Date
			
			
			--Update #COPH_OT set Selected=1 
			--from #COPH_OT GOT 			
			--Inner Join V0110_LEAVE_APPLICATION_DETAIL VLAD on VLAD.From_Date=GOT.For_Date and VLAD.
	
		IF  @LEAVE_APPLICATION_ID > 0
			BEGIN
			
				UPDATE #COPH_OT SET COPH_DEBIT = COPH_DEBIT - QRY.LEAVE_PERIOD,
				COPH_BALANCE	= COPH_BALANCE + QRY.LEAVE_PERIOD
				FROM #COPH_OT GOT 
				INNER JOIN (SELECT ISNULL(SUM(LEAVE_PERIOD),0) AS LEAVE_PERIOD,LEAVE_APPR_DATE
				FROM  #LEAVE_APPROVED LA GROUP BY LEAVE_APPR_DATE) QRY ON QRY.LEAVE_APPR_DATE = FOR_DATE
				
			END
		ELSE
			BEGIN
				UPDATE #COPH_OT SET COPH_DEBIT = QRY.LEAVE_PERIOD ,
				COPH_BALANCE	= COPH_BALANCE - QRY.LEAVE_PERIOD FROM #COPH_OT GOT 
				INNER JOIN (SELECT ISNULL(SUM(LEAVE_PERIOD),0) AS LEAVE_PERIOD,LEAVE_APPR_DATE 
				FROM  #LEAVE_APPROVED LA GROUP BY LEAVE_APPR_DATE) QRY ON QRY.LEAVE_APPR_DATE = FOR_DATE
				
			END
			
	DECLARE @TOTAL_BALANCE AS NUMERIC(18,2)
		SET @TOTAL_BALANCE = 0
	DECLARE @LEAVE_CODE AS VARCHAR(MAX)
    DECLARE @LEAVE_NAME AS VARCHAR(MAX)
	DECLARE @LEAVE_DISPLAY AS TINYINT
	DECLARE @COPH_BALANCE AS NUMERIC(18,2)
	DECLARE @CUR_COPH_BALANCE NUMERIC(18,2)
	DECLARE @CUR_FOR_DATE DATETIME
	DECLARE @COPH_STRING NVARCHAR(MAX)
	DECLARE @CUR_TOTAL_BALANCE NUMERIC(18,2)
	
	if @Exec_For = 0
	begin
		select @Total_Balance = isnull(SUM(COPH_balance),0) from #COPH_OT where COPH_balance > 0 Group By Emp_ID
		select *,ISNULL(@Total_Balance,0) as Total_Balance from #COPH_OT where COPH_balance > 0 order by For_Date
	end
	else if @Exec_For = 1  -- Only Show Data IF Leave_Display 1 of leave
	begin
		
		set @COPH_Balance = 0
		set @Leave_Display = 0
		select @Leave_Code = Leave_Code , @Leave_Name = Leave_Name, @Leave_Display = isnull(Display_leave_balance,0) from dbo.T0040_Leave_Master WITH (NOLOCK)  where Leave_ID = @Leave_ID		
		if @Leave_Display = 1
		begin 
			select @COPH_Balance = isnull(sum(COPH_Balance),0) from #COPH_OT 
			if @COPH_Balance > 0
			begin 
				Insert into #temp_COPH
					select isnull(sum(COPH_credit),0),isnull(Sum(COPH_Debit),0),isnull(sum(COPH_Balance),0),@Leave_Code,@Leave_Name,@Leave_ID,'' from #COPH_OT 
			end
				
		end
	end
	else if @Exec_For = 2  -- COPH Show All Data
			begin
				
							select @Total_Balance = isnull(SUM(COPH_Balance),0) from #COPH_OT where COPH_Balance > 0 Group By Emp_ID
							set @Leave_Display = 0
							select @Leave_Code = Leave_Code , @Leave_Name = Leave_Name from dbo.T0040_Leave_Master  WITH (NOLOCK) where Leave_ID = @Leave_ID and cmp_ID = @cmp_ID		
							
							
					if @Total_Balance > 0
						begin
				
							
							set @COPH_String = ''
									
									Declare Cur_COPH cursor for
												select For_Date,COPH_Balance,@Total_Balance from #COPH_OT
								
									open Cur_COPH
												Fetch next from Cur_COPH into  @Cur_For_Date,@Cur_COPH_balance,@Cur_Total_Balance
										While @@Fetch_Status =0  
										begin
											
												If @COPH_String = ''
													set	@COPH_String = replace(CONVERT(varchar(11),@Cur_For_Date,106),' ','-')  + ';' + cast(@Cur_COPH_balance as varchar(15))
						   					    else
												    set	@COPH_String = @COPH_String  +  '#' + replace(CONVERT(varchar(11),@Cur_For_Date,106),' ','-')  + ';' + cast(@Cur_COPH_balance as varchar(15))
										                    
												Fetch next from Cur_COPH into @Cur_For_Date,@Cur_COPH_balance,@Cur_Total_Balance
										end
								 	close Cur_COPH
								 	deallocate Cur_COPH
						
						Insert into #temp_COPH
							select isnull(sum(COPH_credit),0) as COPH_credit,isnull(Sum(COPH_Debit),0) as  COPH_Debit,isnull(sum(COPH_Balance),0) as COPH_Balance ,@Leave_Code as Leave_Code,@Leave_Name as Leave_Name,@Leave_ID as Leave_ID  ,@COPH_String as COPH_String   from #COPH_OT 
							
							
					end
					
					
			end
	   else if @Exec_For = 3   -- COPH Leave Approval Using Import
			begin
					select @Total_Balance = isnull(SUM(COPH_Balance),0) from #COPH_OT where COPH_Balance > 0 Group By Emp_ID
						set @Leave_Display = 0
					select @Leave_Code = Leave_Code , @Leave_Name = Leave_Name from dbo.T0040_Leave_Master  WITH (NOLOCK) where Leave_ID = @Leave_ID	and Cmp_ID = @Cmp_ID	
					
							
					if @Total_Balance >= @Leave_Period
						begin
						
							Declare @Temp_Leave_Period numeric(18,2)
							set @Temp_Leave_Period = @Leave_Period
							set @COPH_String = ''
									
									Declare Cur_COPH cursor for
												select For_Date,COPH_Balance,@Total_Balance from #COPH_OT
								
									open Cur_COPH
												Fetch next from Cur_COPH into  @Cur_For_Date,@Cur_COPH_balance,@Cur_Total_Balance
										While @@Fetch_Status =0  
										begin
											IF @Temp_Leave_Period >  0 
											  begin		
												If @Cur_COPH_balance < = @Temp_Leave_Period	
												  begin
													set @Temp_Leave_Period = @Temp_Leave_Period - @Cur_COPH_balance
													If @COPH_String = ''
														set	@COPH_String = replace(CONVERT(varchar(11),@Cur_For_Date,106),' ','-')  + ';' + cast(@Cur_COPH_balance as varchar(15))
						   							else
														set	@COPH_String = @COPH_String  +  '#' + replace(CONVERT(varchar(11),@Cur_For_Date,106),' ','-')  + ';' + cast(@Cur_COPH_balance as varchar(15))
												  end
												else
													begin
														If @COPH_String = ''
															set	@COPH_String = replace(CONVERT(varchar(11),@Cur_For_Date,106),' ','-')  + ';' + cast(@Temp_Leave_Period as varchar(15))
						   								else
															set	@COPH_String = @COPH_String  +  '#' + replace(CONVERT(varchar(11),@Cur_For_Date,106),' ','-')  + ';' + cast(@Temp_Leave_Period as varchar(15))
														
														set @Temp_Leave_Period = 0
													end              
											  end
											     
												Fetch next from Cur_COPH into @Cur_For_Date,@Cur_COPH_balance,@Cur_Total_Balance
										end
								 	close Cur_COPH
								 	deallocate Cur_COPH
						
						Insert into #temp_CompOff
							select 0 as COPH_credit,0 as  COPH_Debit,0 as COPH_Balance ,@Leave_Code as Leave_Code,@Leave_Name as Leave_Name,@Leave_ID as Leave_ID  ,@COPH_String as COPH_String   from #COPH_OT 
					end
			end
			
			
END

