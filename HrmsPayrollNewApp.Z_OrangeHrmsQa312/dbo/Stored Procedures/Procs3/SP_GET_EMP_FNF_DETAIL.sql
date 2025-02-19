
CREATE PROCEDURE [dbo].[SP_GET_EMP_FNF_DETAIL]
	 @Cmp_ID		numeric
	,@From_Date		datetime
	,@To_Date		datetime 
	,@Branch_ID		numeric = 0
	,@Cat_ID		numeric = 0
	,@Grd_ID		numeric = 0
	,@Type_ID		numeric = 0
	,@Dept_ID		numeric = 0
	,@Desig_ID		numeric = 0
	,@Emp_ID		numeric = 0
	,@Constraint	varchar(max) =''
AS
	SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET ARITHABORT OFF;


	if @Branch_ID = 0
		set @Branch_ID = null
	if @Cat_ID = 0
		set @Cat_ID = null
	if @Type_ID = 0
		set @Type_ID = null
	if @Dept_ID = 0
		set @Dept_ID = null
	if @Grd_ID = 0
		set @Grd_ID = null
	if @Emp_ID = 0
		set @Emp_ID = null
		
	If @Desig_ID = 0
		set @Desig_ID = null
		
	CREATE table #Data     
  (     
	  Emp_Id     numeric ,     
	  For_date   datetime,    
	  Duration_in_sec  numeric,    
	  Shift_ID   numeric ,    
	  Shift_Type   numeric ,    
	  Emp_OT    numeric ,    
	  Emp_OT_min_Limit numeric,    
	  Emp_OT_max_Limit numeric,    
	  P_days    numeric(12,1) default 0,    
	  OT_Sec    numeric default 0,
	  In_Time datetime default null,
	  Shift_Start_Time datetime default null,
	  OT_Start_Time numeric default 0,
	  Shift_Change tinyint default 0 ,
	  Flag Int Default 0  ,
	  Weekoff_OT_Sec  numeric default 0,
	  Holiday_OT_Sec  numeric default 0	,
	  Chk_By_Superior numeric default 0 ,
	  IO_Tran_Id	   numeric default 0,
	  OUT_Time datetime,
	  Shift_End_Time datetime,			--Ankit 16112013
      OT_End_Time numeric default 0,	--Ankit 16112013
      Working_Hrs_St_Time tinyint default 0, --Hardik 14/02/2014
	  Working_Hrs_End_Time tinyint default 0, --Hardik 14/02/2014
	  GatePass_Deduct_Days numeric(18,2) default 0 -- Add by Gadriwala Muslim 05012014
  )    
 
	CREATE table #tempCF
	(
		 Leave_CF_ID  numeric
		,CF_LEAVE_Days numeric(18,2)
		,CF_P_DAYS numeric(5,1)
		,cf_type nvarchar(25)
		,Leave_ID numeric
		,Emp_ID numeric
		,Advance_Leave_Balance Numeric(18,2)
	)
	   	
	--CREATE TABLE #Absent
	--(
	--	 Emp_Id numeric
	--	,Cmp_Id numeric
	--	,For_Date Datetime
	--	,Status Varchar(100)
	--	,A_Days Numeric(18,2)
	--	,Emp_Code Varchar(100)
	--	,Emp_Full_Name Varchar(200)
	--)

	
	--select @Branch_ID=Branch_ID , @Grd_ID = Grd_ID from T0095_INCREMENT where Increment_ID = 
	--(select max(Increment_ID) as Increment_ID from T0095_Increment  where Increment_Effective_date <= @To_Date  --Changed by Hardik 09/09/2014 for Same Date Increment
	--and Cmp_ID = @Cmp_ID and Emp_ID = @Emp_Id) and Cmp_ID = @Cmp_ID and Emp_ID = @Emp_Id
	
	
	--NEW CODE ADDED BY RAMIZ FOR LATEST INCREMENT--
	
	
	SELECT @BRANCH_ID = I.BRANCH_ID , @GRD_ID = I.GRD_ID --, @INCREMENT_ID = I.INCREMENT_ID
	FROM T0095_INCREMENT I WITH(NOLOCK)
	 		INNER JOIN 
					( SELECT MAX(I.INCREMENT_ID) AS INCREMENT_ID, I.EMP_ID 
						FROM T0095_INCREMENT I WITH(NOLOCK)
						INNER JOIN 
						(
								SELECT MAX(i3.INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
								FROM T0095_INCREMENT I3 WITH(NOLOCK)
								WHERE I3.Increment_effective_Date <= @To_Date
								GROUP BY I3.EMP_ID  
							) I3 ON I.Increment_Effective_Date=I3.Increment_Effective_Date AND I.EMP_ID = I3.Emp_ID	
					   where I.INCREMENT_EFFECTIVE_DATE <= @To_Date and I.Cmp_ID = @Cmp_ID
					   group by I.emp_ID  
					) Qry on	I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID 
		WHERE CMP_ID = @Cmp_ID AND I.EMP_ID = @Emp_Id	
	-- CODE ENDS HERE --
	
	--Added By Jimit 05022018(As not getting Transfer Increment Id WCl)
	DECLARE @INCREMENT_ID AS NUMERIC
	SET @INCREMENT_ID = 0
	
	SELECT @INCREMENT_ID = I.INCREMENT_ID
	FROM T0095_INCREMENT I WITH(NOLOCK)
	 		INNER JOIN 
					( SELECT MAX(I.INCREMENT_ID) AS INCREMENT_ID, I.EMP_ID 
						FROM T0095_INCREMENT I WITH(NOLOCK)
						INNER JOIN 
						(
								SELECT MAX(i3.INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
								FROM T0095_INCREMENT I3 WITH(NOLOCK)
								WHERE I3.Increment_effective_Date <= @To_Date and I3.Increment_Type <> 'Transfer'
								GROUP BY I3.EMP_ID  
							) I3 ON I.Increment_Effective_Date=I3.Increment_Effective_Date AND I.EMP_ID = I3.Emp_ID	
					   where I.INCREMENT_EFFECTIVE_DATE <= @To_Date and I.Cmp_ID = @Cmp_ID and I.Increment_Type <> 'Transfer'
					   group by I.emp_ID  
					) Qry on	I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID 
		WHERE CMP_ID = @Cmp_ID AND I.EMP_ID = @Emp_Id	
	---Ended--------
	
	
	Declare @Sal_St_Date   Datetime    
	Declare @Sal_end_Date   Datetime
	
	If @Branch_ID is null
		Begin 
			  SELECT TOP 1 @SAL_ST_DATE  = SAL_ST_DATE 
			  FROM T0040_GENERAL_SETTING WITH(NOLOCK) 
			  WHERE CMP_ID = @CMP_ID    
			  AND FOR_DATE = ( SELECT MAX(FOR_DATE) 
							  FROM T0040_GENERAL_SETTING WITH(NOLOCK) 
							  WHERE FOR_DATE <=@TO_DATE AND CMP_ID = @CMP_ID)    
		End
	Else
		Begin
			  SELECT @SAL_ST_DATE  =SAL_ST_DATE 
			  FROM T0040_GENERAL_SETTING WITH(NOLOCK) 
			  WHERE CMP_ID = @CMP_ID AND BRANCH_ID = @BRANCH_ID    
			  AND FOR_DATE = ( SELECT MAX(FOR_DATE) 
							  FROM T0040_GENERAL_SETTING WITH(NOLOCK) 
							  WHERE FOR_DATE <=@TO_DATE AND BRANCH_ID = @BRANCH_ID AND CMP_ID = @CMP_ID)    
		End 
		
		Declare @Left_Date datetime
		Select @Left_Date =Left_Date from T0100_Left_Emp where Emp_ID =@Emp_ID
		
		--if day(@Sal_St_Date) > 1   -- Added by mitesh on 14/03/2012 for 26 salary period getting problem
		--begin
		--	if day(@left_date) >= day(@Sal_St_Date) 
		--		begin
		--			set @From_Date = cast('01/' + cast(dbo.F_GET_MONTH_NAME(Month(DATEADD(MM,1,@left_date))) as nvarchar) + '/' + cast(YEAR(@left_date) as nvarchar) as datetime)
		--		end
		--	else if day(@To_Date) > day(@Sal_St_Date)
		--		begin
		--			set @From_Date = cast('01/' + cast(dbo.F_GET_MONTH_NAME(Month(DATEADD(MM,1,@To_Date))) as nvarchar) + '/' + cast(YEAR(@To_Date) as nvarchar) as datetime)
		--		end
				
		--end
	if @Left_Date >= @To_Date  -- Added by rohit on 26062013 for next month fnf
	begin 
		if day(@Sal_St_Date) > 1    -- Added by mitesh on 14/03/2012 for 26 salary period getting problem
		begin
			if day(@left_date) >= day(@Sal_St_Date) 
				begin
					if month(@left_date) = 12
						begin
							--set @Month_St_Date = cast('01/' + cast(dbo.F_GET_MONTH_NAME(Month(DATEADD(MM,1,@left_date))) as nvarchar) + '/' + cast((YEAR(@left_date) + 1) as nvarchar) as datetime)
							set @From_Date = cast('01/' + cast(dbo.F_GET_MONTH_NAME(Month(DATEADD(MM,1,@left_date))) as nvarchar) + '/' + cast((YEAR(@left_date) + 1) as nvarchar) as datetime)
						end
					else
						begin
							set @From_Date = cast('01/' + cast(dbo.F_GET_MONTH_NAME(Month(DATEADD(MM,1,@left_date))) as nvarchar) + '/' + cast(YEAR(@left_date) as nvarchar) as datetime)
						end
				end
			else if day(@To_Date) > day(@Sal_St_Date)
				begin
					set @From_Date = cast('01/' + cast(dbo.F_GET_MONTH_NAME(Month(DATEADD(MM,1,@From_Date))) as nvarchar) + '/' + cast(YEAR(@From_Date) as nvarchar) as datetime)
				end
				
		end
	end
	
	if isnull(@Sal_St_Date,'') = ''    
		  begin    
			   set @From_Date  = @From_Date     
			   set @To_Date = @To_Date    			   
		  end     
	 else if day(@Sal_St_Date) =1 --and month(@Sal_St_Date)= 1    
		  begin    
			   set @From_Date  = @From_Date     
			   set @To_Date = @To_Date    			   
		  end     
	 else if @Sal_St_Date <> ''  and day(@Sal_St_Date) > 1   
		  begin    
			   set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@From_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@From_Date) )as varchar(10)) as smalldatetime)    
			   set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date)) 
			   
			   
			   Set @From_Date = @Sal_St_Date
			   Set @To_Date = @Sal_End_Date    
		  end
	
	
	Declare @Is_Compoff as int
	declare @comp_off_leave_id  as numeric
	
	set @comp_off_leave_id = 0
	Set @Is_Compoff = 0
	
	 create table #temp_CompOff
		(
			Leave_opening	decimal(18,2),
			Leave_Used		decimal(18,2),
			Leave_Closing	decimal(18,2),
			Leave_Code		varchar(max) COLLATE SQL_Latin1_General_CP1_CI_AS,
			Leave_Name		varchar(max) COLLATE SQL_Latin1_General_CP1_CI_AS, --Add collation by Hardik 06/06/2016
			Leave_ID		numeric,
			CompOff_String  varchar(max) default null -- Added by Gadriwala 18022015
		)	
	
	Declare @Resig_Date Datetime
	Declare @Short_Fall_Days numeric(5,1)	
	Declare @Advance_Amount numeric(12,2)	
	Declare @tmp_dt datetime
	Declare @Leave_CF_ID as numeric
	Declare @short_Fall_days_general as numeric(5,1)
	DECLARE @Is_Short_Fall_Grade_wise as numeric(5,1)
	
	set @short_Fall_days_general =0
	set @Advance_Amount = 0
	set @Is_Short_Fall_Grade_wise = 0
	--Select @Left_Date = Emp_Left_Date  from T0080_EMP_MASTER where Emp_ID = @Emp_ID
	
	
	
	--- For Leave Encashment
	
	--set @tmp_dt = Dateadd(day,1,@To_Date)
	set @tmp_dt = Dateadd(day,1,@Left_Date)
	set @Leave_CF_ID = 0
	
	
	SELECT @COMP_OFF_LEAVE_ID = LEAVE_ID 
	FROM T0040_LEAVE_MASTER
	WHERE ISNULL(DEFAULT_SHORT_NAME,'') = 'COMP' AND CMP_ID = @CMP_ID
		
	SELECT @IS_COMPOFF = ISNULL(IS_COMPOFF,0) 
	FROM T0040_GENERAL_SETTING WITH(NOLOCK)
	WHERE FOR_DATE = (
							SELECT MAX(FOR_DATE) 
							FROM T0040_GENERAL_SETTING  WITH(NOLOCK)
							WHERE BRANCH_ID = @BRANCH_ID AND CMP_ID = @CMP_ID
						) AND BRANCH_ID = @BRANCH_ID
	
	
	
	
	If @Is_Compoff = 1 
		exec GET_COMPOFF_DETAILS @For_Date = @tmp_dt,@Emp_ID = @emp_id,@Cmp_ID = @cmp_id,@leave_ID = @comp_off_leave_id,@Leave_Application_ID = 0 ,@Leave_Encash_App_ID = 0,@Exec_For =1
		
	
	DECLARE @LEAVE_TRAN_DATE DATETIME
	SET @LEAVE_TRAN_DATE = NULL
	SET @LEAVE_CF_ID = 0
	DECLARE CUR_LEAVE_CF CURSOR FOR
		SELECT LM.LEAVE_ID 
		FROM T0040_LEAVE_MASTER LM WITH(NOLOCK)
			INNER JOIN T0050_LEAVE_DETAIL LD WITH(NOLOCK) ON LM.LEAVE_ID = LD.LEAVE_ID -- ADDED BY HARDIK 17/01/2019 FOR SHAILY ENG., THERE ARE SO MANY LEAVES WHICH NOT ASSIGNED TO GRADE SO NO NEED TO COME THOSE LEAVE IN CURSOR
		WHERE LM.CMP_ID =@CMP_ID AND ISNULL(LEAVE_CF_TYPE,'None') <> 'None' AND LEAVE_PAID_UNPAID ='P'	AND ISNULL(IS_ADVANCE_LEAVE_BALANCE,0) <> 1	--ALPESH 25-JUL-2012
			And LD.Grd_ID = @Grd_ID
		--select leavE_Id from T0040_leave_master where cmp_ID =@Cmp_ID 
		--and (( Leave_CF_Type ='Yearly') Or (leave_CF_Type ='Monthly') )  
		--and LeavE_Paid_Unpaid ='P'
		 
	OPEN CUR_LEAVE_CF
	FETCH NEXT FROM CUR_LEAVE_CF INTO @LEAVE_CF_ID
	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		SELECT @LEAVE_TRAN_DATE = MAX(ISNULL(CF_FOR_DATE,'')) 
		FROM T0100_LEAVE_CF_DETAIL WITH(NOLOCK)
		WHERE LEAVE_ID = @LEAVE_CF_ID AND EMP_ID = @EMP_ID 
												
		IF @LEAVE_TRAN_DATE IS NULL
			SELECT @LEAVE_TRAN_DATE = MIN(FOR_DATE) 
			FROM T0140_LEAVE_TRANSACTION WITH(NOLOCK)
			WHERE EMP_ID = @EMP_ID AND LEAVE_ID = @LEAVE_CF_ID  
		
		IF @LEAVE_TRAN_DATE IS NULL
			SELECT @LEAVE_TRAN_DATE = DATE_OF_JOIN  
			FROM T0080_EMP_MASTER WITH(NOLOCK)
			WHERE EMP_ID = @EMP_ID 
      
      Declare @TmpFrom_Date		datetime
			Declare @TmpTo_Date		datetime
		set @TmpFrom_Date  = CONVERT(Date,@LEAVE_TRAN_DATE,105)
			set @TmpTo_Date  = CONVERT(Date,@To_Date,105)
		
		
	IF DATEDIFF(YY,@LEAVE_TRAN_DATE,@TO_DATE)<= 1
			BEGIN
				INSERT INTO #TEMPCF
			    EXEC SP_LEAVE_CF 0,@CMP_ID,@TmpFrom_Date,@TmpTo_Date ,@TmpTo_Date,0,0,0,0,0,0,@EMP_ID,'',@LEAVE_CF_ID,1

			END
		
		FETCH NEXT FROM CUR_LEAVE_CF INTO @LEAVE_CF_ID
	END
	
	CLOSE CUR_LEAVE_CF
	DEALLOCATE CUR_LEAVE_CF
	
	--select lt.Leave_ID,lm.Leave_Name,dbo.f_lower_round(CompOff_Debit,lt.Cmp_ID) as Leave_Closing,* from T0140_LEave_Transaction lt inner join
	--	(select max(For_Date)For_Date,Emp_ID,LEave_ID from T0140_LEave_Transaction
	--	where emp_ID =@Emp_ID and For_Date <= @tmp_dt
	--	group by emp_ID,LeavE_ID )Q on lt.emp_ID =q.emp_ID and lt.leave_ID =q.leavE_ID and lt.for_Date =q.for_Date inner join
	--	T0040_leave_master lm on lt.leavE_id =lm.leave_id and  leave_type = 'Encashable' and lm.Default_Short_Name = 'COMP'
	
	if object_ID('tempdb..#Advance_Leave_Balance') is not null
		drop TABLE #Advance_Leave_Balance
		
	Create Table #Advance_Leave_Balance
	(
		Cmp_ID Numeric,
		Emp_ID Numeric,
		Leave_ID Numeric,
		Leave_Name Varchar(200) collate SQL_Latin1_General_CP1_CI_AS ,
		Leave_Type Varchar(200) collate SQL_Latin1_General_CP1_CI_AS ,
		Leave_CF_Type Varchar(200) collate SQL_Latin1_General_CP1_CI_AS,
		Leave_Opening Numeric(18,2),
		Advance_Leave_assign Numeric(18,2),
		Actula_Leave_Calculation Numeric(18,2),
		Advance_Leave_Balance Numeric(18,2)
	)
	
	INSERT INTO #ADVANCE_LEAVE_BALANCE
	SELECT @CMP_ID,@EMP_ID,LM.LEAVE_ID,LM.LEAVE_NAME,LM.LEAVE_TYPE,LM.LEAVE_CF_TYPE,0,0,0,0
	FROM T0040_LEAVE_MASTER LM 
		INNER JOIN T0050_LEAVE_DETAIL LD   ON LM.LEAVE_ID = LD.LEAVE_ID -- Added by Hardik 17/01/2019 for Shaily Eng., there are so many leaves which not assigned to Grade so no need to come those leave in cursor
	--inner join T0050_CF_EMP_TYPE_DETAIL cf on cf.Leave_ID=lm.Leave_ID
	--inner join (Select Max(Effective_Date) as Effective_Date,Leave_ID,Type_ID from T0050_CF_EMP_TYPE_DETAIL where Cmp_ID = @Cmp_ID group by Leave_ID,Type_ID) qry
	--on qry.Leave_ID=cf.Leave_ID and qry.Effective_Date=cf.Effective_Date and qry.Type_ID = cf.Type_ID
	WHERE LEAVE_TYPE = 'Encashable' AND ISNULL(DEFAULT_SHORT_NAME,'') <> 'COMP' 
	AND LM.CMP_ID = @CMP_ID AND ISNULL(IS_ADVANCE_LEAVE_BALANCE,0) = 1 AND LD.GRD_ID = @GRD_ID 
	
	
	
	Update ALB
		SET Advance_Leave_assign = CF.Advance_Leave_Balance
	From #Advance_Leave_Balance ALB
	Inner Join T0100_LEAVE_CF_Advance_Leave_Balance CF  on ALB.Emp_ID = CF.Emp_ID and ALB.Leave_ID = CF.Leave_ID
	where ALB.Emp_ID = @Emp_ID and ALB.Cmp_ID = @Cmp_ID 
	and (CASE WHEN ALB.Leave_CF_Type = 'Monthly' then @tmp_dt WHEN ALB.Leave_CF_Type = 'Yearly' then @tmp_dt /*dateadd(yyyy,-1,@tmp_dt)*/ else @tmp_dt END)  between CF.CF_From_Date AND CF.CF_To_Date 
	
	
	Declare @tmp_dt_start Datetime
	
	Set @tmp_dt_start = dbo.GET_MONTH_ST_DATE(MONTH(@tmp_dt),Year(@tmp_dt))
	
	
	Update ALB SET Leave_Opening = lt.Leave_Closing
	from T0140_LEave_Transaction lt  inner join
		(select max(For_Date)For_Date,Emp_ID,LEave_ID 
		from T0140_LEave_Transaction 
		where emp_ID =@Emp_ID and For_Date <= @tmp_dt
		group by emp_ID,LeavE_ID )Q 
		on lt.emp_ID =q.emp_ID and lt.leave_ID =q.leavE_ID and lt.for_Date =q.for_Date inner join
		T0040_leave_master lm  on lt.leavE_id =lm.leave_id and  leave_type = 'Encashable' and ISNULL(lm.Default_Short_Name,'') <> 'COMP'
		and lm.Is_Advance_Leave_Balance = 1
		inner JOIN #Advance_Leave_Balance ALB On ALB.Leave_ID = lt.Leave_ID and ALB.Emp_ID = lt.Emp_ID
	
	
	
	CREATE table #tempCFAdvance
	(
		 Leave_CF_ID  numeric
		,CF_LEAVE_Days numeric(10,2)
		,CF_P_DAYS numeric(10,2)
		,cf_type nvarchar(25)
		,Leave_ID numeric
		,Emp_ID numeric
		,Advance_Leave_Balance Numeric(18,2)
	)
	
	Declare @Adv_leave_Tran_Date Datetime
	Declare @Adv_LEave_CF_ID Numeric(10,0)
	
	set @Adv_leave_Tran_Date = null
	set @Adv_LEave_CF_ID = 0
	

	
	Declare Cur_Advace_Leave Cursor For
	Select Leave_ID From #Advance_Leave_Balance
	open Cur_Advace_Leave
	fetch next from Cur_Advace_Leave into @Adv_LEave_CF_ID
		while @@fetch_Status = 0
			Begin
				
				select @Adv_leave_Tran_Date = max(isnull(CF_For_Date,'')) from T0100_LEAVE_CF_DETAIL WITH(NOLOCK)  where Leave_ID = @Adv_LEave_CF_ID and Emp_ID = @Emp_Id 
											
				if @Adv_leave_Tran_Date is null
					select @Adv_leave_Tran_Date = min(for_date) from T0140_LEAVE_TRANSACTION  WITH(NOLOCK)where Emp_ID = @Emp_Id and Leave_ID = @Adv_LEave_CF_ID  
		
				if @Adv_leave_Tran_Date is null
					select @Adv_leave_Tran_Date = Date_Of_Join  from T0080_EMP_MASTER WITH(NOLOCK) where Emp_ID = @Emp_Id 
				
				If Datediff(yy,@leave_Tran_Date,@To_Date)<= 1
					Begin				
                    Declare @TmpFrom_Date1		datetime
			Declare @TmpTo_Date1		datetime
		set @TmpFrom_Date1  = CONVERT(Date,@Adv_leave_Tran_Date,105)
			set @TmpTo_Date1  = CONVERT(Date,@To_Date,105)
						
						 insert into #tempCFAdvance
						 Exec SP_LEAVE_CF 0,@cmp_ID,@TmpFrom_Date1 ,@TmpTo_Date1 ,@To_Date,0,0,0,0,0,0,@Emp_Id,'',@Adv_LEave_CF_ID,1

						 --Exec SP_LEAVE_CF 0,@cmp_ID,@Adv_leave_Tran_Date ,@To_Date ,@To_Date,0,0,0,0,0,0,@Emp_Id,'',@Adv_LEave_CF_ID,1 -- Old Code
					End
			
				fetch next from Cur_Advace_Leave into @Adv_LEave_CF_ID
			End 
	Close Cur_Advace_Leave
	deallocate Cur_Advace_Leave
	
	Update ALB
		Set ALB.Actula_Leave_Calculation = CFA.CF_LEAVE_Days,
		Advance_Leave_Balance = CFA.Advance_Leave_Balance
	From #Advance_Leave_Balance ALB
	inner join #tempCFAdvance CFA on ALB.Leave_ID = CFA.Leave_ID and ALB.Emp_ID = CFA.Emp_ID
	
	--Select * From #tempCFAdvance
	--Select * From #Advance_Leave_Balance
	
	DELETE T0100_LEAVE_CF_DETAIL WHERE LEAVE_CF_ID IN (SELECT LEAVE_CF_ID FROM #tempCFAdvance)
	drop TABLE #tempCFAdvance

  
			--ADDED BY JIMIT 03082019	As per Genchi case in FNF 
			DECLARE @BRANCH_WISE_LEAVE AS TINYINT
			SET @BRANCH_WISE_LEAVE = 0
	
			SELECT @BRANCH_WISE_LEAVE = SETTING_VALUE FROM T0040_SETTING WITH(NOLOCK) WHERE CMP_ID = @CMP_ID AND SETTING_NAME = 'BRANCH WISE LEAVE' 				
	
			IF OBJECT_ID('TEMPDB..#LEAVE_NAME_BRANCH_WISE') IS NOT NULL  
						  DROP TABLE #LEAVE_NAME_BRANCH_WISE
				
						CREATE TABLE #LEAVE_NAME_BRANCH_WISE
							(
								LEAVE_ID NUMERIC(18,0),
								LEAVE_NAME NVARCHAR(250)
							)
					
	
	
			IF @BRANCH_WISE_LEAVE = 1  
				BEGIN
						INSERT INTO #LEAVE_NAME_BRANCH_WISE					
						EXEC GET_LEAVE_DETAILS @CMP_ID,@GRD_ID,@EMP_ID,@BRANCH_ID,'',0					
				END
			ELSE 
			  BEGIN
						INSERT INTO #LEAVE_NAME_BRANCH_WISE					
						SELECT ALB.LEAVE_ID,LM.LEAVE_NAME 
						FROM  #ADVANCE_LEAVE_BALANCE ALB
							  INNER JOIN T0040_LEAVE_MASTER LM ON LM.LEAVE_ID = ALB.LEAVE_ID
	    
			  END
			--ENDED
	
	
	
		
	 SELECT LT.LEAVE_ID,LM.LEAVE_NAME COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS AS LEAVE_NAME,DBO.F_LOWER_ROUND(LEAVE_CLOSING,LT.CMP_ID) AS LEAVE_CLOSING,0 AS LEAVE_RECOVER 
	 FROM T0140_LEAVE_TRANSACTION LT WITH(NOLOCK) INNER JOIN
		(SELECT MAX(FOR_DATE)FOR_DATE,EMP_ID,LEAVE_ID 
		 FROM T0140_LEAVE_TRANSACTION WITH(NOLOCK)
		 WHERE EMP_ID =@EMP_ID AND FOR_DATE <= @TMP_DT
		 GROUP BY EMP_ID,LEAVE_ID 
		 )Q ON LT.EMP_ID =Q.EMP_ID AND LT.LEAVE_ID =Q.LEAVE_ID AND LT.FOR_DATE =Q.FOR_DATE INNER JOIN
		T0040_LEAVE_MASTER LM WITH(NOLOCK) ON LT.LEAVE_ID =LM.LEAVE_ID AND  LEAVE_TYPE = 'Encashable' and ISNULL(lm.Default_Short_Name,'') <> 'COMP' and Isnull(lm.Is_Advance_Leave_Balance,0) <> 1
	  UNION 
	  SELECT TC.LEAVE_ID,TC.LEAVE_NAME,DBO.F_LOWER_ROUND(LEAVE_CLOSING,@CMP_ID) AS LEAVE_CLOSING ,0 AS LEAVE_RECOVER 
	  FROM #TEMP_COMPOFF TC INNER JOIN
		T0040_LEAVE_MASTER LM WITH(NOLOCK) ON TC.LEAVE_ID =LM.LEAVE_ID AND  LM.LEAVE_TYPE = 'Encashable' and ISNULL(lm.Default_Short_Name,'') = 'COMP'
	  UNION
	  SELECT LEAVE_ID,LEAVE_NAME,(CASE WHEN ADVANCE_LEAVE_ASSIGN > ACTULA_LEAVE_CALCULATION THEN (ISNULL(LEAVE_OPENING,0) - (ISNULL(ADVANCE_LEAVE_ASSIGN,0)- ISNULL(ACTULA_LEAVE_CALCULATION,0))) ELSE /*(CASE WHEN (ISNULL(LEAVE_OPENING,0) - (ISNULL(ADVANCE_LEAVE_BALANCE,0) - ISNULL(ACTULA_LEAVE_CALCULATION,0))) > 0 THEN (ISNULL(LEAVE_OPENING,0) - (ISNULL(ADVANCE_LEAVE_BALANCE,0) - ISNULL(ACTULA_LEAVE_CALCULATION,0))) ELSE 0 END) */ (CASE WHEN ISNULL(LEAVE_OPENING,0) > 0 THEN (ISNULL(LEAVE_OPENING,0) - ((ISNULL(ADVANCE_LEAVE_BALANCE,0) - ISNULL(ACTULA_LEAVE_CALCULATION,0)))) ELSE 0 END) END) 
	  ,(CASE WHEN ADVANCE_LEAVE_ASSIGN > ACTULA_LEAVE_CALCULATION THEN (ISNULL(ADVANCE_LEAVE_ASSIGN,0)- ISNULL(ACTULA_LEAVE_CALCULATION,0)) ELSE 0 END)  AS LEAVE_RECOVER
	  FROM #ADVANCE_LEAVE_BALANCE ALB
	   WHERE EXISTS (SELECT 1 FROM #LEAVE_NAME_BRANCH_WISE LNB WHERE LNB.LEAVE_ID = ALB.LEAVE_ID)
	--- End

	--- For Loan ---
	--Comment by nilesh patel on 29072015 -start
	--Select * from T0140_LOAN_TRANSACTION lt inner join 
	--	(Select max(For_Date) For_Date,Emp_ID,Loan_ID from T0140_LOAN_TRANSACTION where Emp_ID = @Emp_ID group by Emp_ID,Loan_ID) q 
	--on lt.Emp_ID=q.Emp_ID and lt.Loan_ID=q.Loan_ID and lt.For_Date=q.For_Date
	--inner join T0040_LOAN_MASTER lm on lt.Loan_ID=lm.Loan_ID	
	--where Loan_Closing > 0
	--Comment by nilesh patel on 29072015 -End
	
	CREATE table #tempLaon
	(
		 Loan_ID  numeric
		,Loan_Name Varchar(200)
		,For_Date Datetime
		,Loan_Amount nvarchar(25)
		,Interest_Amount numeric(18,2)
		,Is_First_Deduct_Principal_Flag numeric
		,Loan_Apr_Id numeric
	)
	Declare @Emp_Left_Date Datetime
	Declare @Loan_To_Date Datetime
	Select @Emp_Left_Date = Emp_Left_Date  From T0080_EMP_MASTER Where Emp_ID = @Emp_ID
	if @Emp_Left_Date <> ''
		Set @Loan_To_Date = @Emp_Left_Date
	else
		Set @Loan_To_Date = @To_Date
	exec SP_FNF_Loan_Interest_Calcultion @Cmp_ID,@From_Date,@Loan_To_Date,@Emp_ID
	Select * From #tempLaon
	--- End ---
	
	-- Changed by Mitesh On 07/12/2011
	
	--- For Earning ---
	SELECT AD_NAME,AD_ID FROM  T0050_AD_MASTER WITH(NOLOCK)  WHERE
	  AD_FLAG = 'I' AND ISNULL(FOR_FNF,0) = 1 AND CMP_ID = @CMP_ID AND ALLOWANCE_TYPE <> 'R'
		AND HIDE_IN_REPORTS=0  --ADDED BY JAINA 19-05-2017
	
	--- End ---
	
	
	--THIS FULL CODE IS COMMENTED BY RAMIZ ON 19/04/2017
	--REASONS: 1) INCREMENT JOIN WAS NOT APPLIED
		--	 2)	GRADE ID WAS TAKEN FROM EMPLOYEE MASTER
				 			
	--For Deduction ---
	--Comment By Jaina 06-06-2016
	--select Ad_Name,Ad_ID from  t0050_ad_master where
	--  AD_FLAG = 'D' And isnull(FOR_FNF,0) = 1 and CMP_ID = @Cmp_ID
	
		----Added By Jaina 06-06-2016 
	--SELECT AD.AD_ID,AD.AD_NAME,qry.Emp_ID,case when AD_CALCULATE_ON = 'FNF Recovery (NOC)' THEN isnull(qry.Recovery_Amt,0)  ELSE 0 END  as Recovery_Amt
	--	  FROM T0050_AD_MASTER AS AD INNER JOIN
	--		T0120_GRADEWISE_ALLOWANCE As G ON G.Ad_ID = AD.AD_ID INNER JOIN
	--		T0080_EMP_MASTER AS E ON E.Grd_ID = G.Grd_ID left OUTER JOIN 
	--		(
	--			SELECT CA.Emp_ID,SUM(CAD.Recovery_Amt)as Recovery_Amt--,E.AD_ID 
	--				FROM T0300_Exit_Clearance_Approval CA INNER JOIN
	--				T0350_Exit_Clearance_Approval_Detail CAD ON CAD.Approval_id = CA.Approval_Id --LEFT OUTER JOIN
	--			--	T0100_EMP_EARN_DEDUCTION E ON E.Emp_ID = CA.Emp_ID
	--			where CA.Emp_ID = @Emp_ID
	--			GROUP BY CA.Emp_ID--,E.AD_ID
			
	--		) qry ON qry.Emp_ID = E.Emp_ID  INNER JOIN --AND qry.AD_ID = AD.AD_ID
	--		T0100_EMP_EARN_DEDUCTION ER ON ER.AD_ID = AD.AD_ID AND ER.EMP_ID = E.Emp_ID   --Added By Jaina 27-10-2016
	--		WHERE e.Emp_ID = @Emp_Id AND AD.AD_FLAG = 'D' And isnull(AD.FOR_FNF,0) = 1 and E.CMP_ID = @Cmp_ID

	----- End ---
	
	--COMMENTS ENDS HERE , NEW CODE ADDED BELOW. LATEST INCREMENT CODE IS ON TOP.
	
	
	--FOR DEDUCTIONS--ADDED BY RAMIZ ON 17/04/2017--
	Create table #FNF_Deduction
	(
		Ad_Id Numeric(18,0),
		AD_NAME VArchar(500),
		EMP_ID Numeric(18,0),
		Recovery_Amt Numeric(18,2)
	)

	Insert INTO #FNF_Deduction
	SELECT AD.AD_ID,AD.AD_NAME,QRY.EMP_ID,
		CASE WHEN AD_CALCULATE_ON = 'FNF Recovery (NOC)' THEN ISNULL(QRY.RECOVERY_AMT,0)  ELSE 0 END  as RECOVERY_AMT
	FROM T0050_AD_MASTER AS AD  
	INNER JOIN		T0120_GRADEWISE_ALLOWANCE As G  ON G.Ad_ID = AD.AD_ID 
	INNER JOIN		T0095_INCREMENT AS INC  ON INC.Grd_ID = G.Grd_ID
	LEFT OUTER JOIN 
					(
						SELECT CA.Emp_ID,SUM(CAD.Recovery_Amt)as Recovery_Amt
						FROM T0300_Exit_Clearance_Approval CA  
						INNER JOIN	T0350_Exit_Clearance_Approval_Detail CAD  ON CAD.Approval_id = CA.Approval_Id
						WHERE CA.EMP_ID = @EMP_ID and CA.Noc_Status <> 'R'  --Change by Jaina 10-09-2018
						GROUP BY CA.Emp_ID
					) QRY ON qry.Emp_ID = INC.EMP_ID  
	INNER JOIN		T0100_EMP_EARN_DEDUCTION ER ON ER.AD_ID = AD.AD_ID AND ER.EMP_ID = INC.Emp_ID AND ER.INCREMENT_ID = @INCREMENT_ID
	WHERE	INC.Emp_ID = @Emp_Id AND AD.AD_FLAG = 'D' AND ISNULL(AD.FOR_FNF,0) = 1 
			AND INC.CMP_ID = @Cmp_ID AND INC.Increment_ID = @INCREMENT_ID AND AD_CALCULATE_ON = 'FNF Recovery (NOC)'
	ORDER BY AD.AD_LEVEL
	--CODE ENDS--
	--- For 
			--Added by JAina  26-10-2020 - Wonder Cement
			Declare @For_FNF tinyint=0
			Declare @Claim_ID numeric(18,0)=0
			Declare @Claim_Amount numeric(18,0) = 0
			DEclare @Exp_Month numeric(18,2) = 0
			Declare @Exp_year numeric(18,1) =0.0
			DEclare @Deduction_Per numeric(18,2) = 0
			DEclare @Date_Of_Join datetime
			Declare @Claim_FNF_Amt numeric(18,2) = 0
			Declare @Claim_Approval_Date datetime

		
			--print 'Experience'
			--print @Exp_year
		

			SELECT 	@Claim_Amount=ISNULL(SUM(CLAIM_CLOSING),0),@Claim_ID = CLM.Claim_ID,@For_FNF = Claim_For_FNF,@Claim_Approval_Date = CAD.Claim_Apr_Date 
			FROM 	T0140_CLAIM_TRANSACTION AS CT WITH(NOLOCK)
			INNER JOIN ( SELECT distinct CLAIM_APR_ID,CLAIM_ID,MAX(CLAIM_APR_DATE) as CLAIM_APR_DATE,CMP_ID 
						 FROM T0130_CLAIM_APPROVAL_DETAIL WITH(NOLOCK) 
						 Group by Claim_Apr_ID,Cmp_ID,Claim_ID
						) CAD ON CAD.CLAIM_APR_DATE = CT.FOR_DATE  
			INNER JOIN T0120_CLAIM_APPROVAL AS CA WITH(NOLOCK) ON CA.CLAIM_APR_ID = CAD.CLAIM_APR_ID AND CT.EMP_ID=CA.EMP_ID AND CT.CLAIM_ID=CAD.CLAIM_ID 
			INNER JOIN T0040_CLAIM_MASTER CLM WITH(NOLOCK) ON CLM.CLAIM_ID=CAD.CLAIM_ID AND CLM.CMP_ID=CAD.CMP_ID 
			Left join T0050_AD_MASTER AD WITH(NOLOCK) ON AD.Claim_ID = CAD.Claim_ID
			WHERE CT.CMP_ID=@CMP_ID AND CT.EMP_ID=@EMP_ID AND CA.CLAIM_APR_DATE<=GETDATE() 
					AND CLM.CLAIM_APR_DEDUCT_FROM_SAL=1 and AD_FLAG='D'
					AND Claim_For_FNF=1
			GROUP BY CLM.CLAIM_ID,CLAIM_FOR_FNF,CAD.Claim_Apr_Date
			--print @Claim_Amount
			

			SELECT @EXP_MONTH = DATEDIFF(MONTH, @CLAIM_APPROVAL_DATE,EMP_LEFT_DATE),@DATE_OF_JOIN = DATE_OF_JOIN  
			FROM T0080_EMP_MASTER  WITH(NOLOCK) 
			WHERE EMP_ID=@EMP_ID

			SET @EXP_YEAR = @EXP_MONTH / 12
								
			IF EXISTS(SELECT 1 FROM T0045_CLAIM_FNF_DEDUCTION_SLAB WITH(NOLOCK) WHERE CMP_ID=@CMP_ID AND CLAIM_ID=@CLAIM_ID)
			BEGIN
				SELECT @DEDUCTION_PER = DEDU_IN_PER 
				FROM T0045_CLAIM_FNF_DEDUCTION_SLAB WITH(NOLOCK)
				WHERE CMP_ID=@CMP_ID AND CLAIM_ID=@CLAIM_ID AND @EXP_YEAR BETWEEN NO_OF_YEAR-1 AND NO_OF_YEAR

				
				SET @CLAIM_FNF_AMT = (@CLAIM_AMOUNT * @DEDUCTION_PER)/100
																		
			END
			IF @CLAIM_FNF_AMT > 0
			BEGIN

				INSERT INTO #FNF_DEDUCTION
				SELECT DISTINCT AD.AD_ID,AD.AD_NAME,ED.EMP_ID,@CLAIM_FNF_AMT
				FROM T0050_AD_MASTER AD INNER JOIN 
					 T0100_EMP_EARN_DEDUCTION ED  ON AD.AD_ID = ED.AD_ID 
				WHERE ED.CMP_ID=@CMP_ID AND ED.EMP_ID = @EMP_ID AND AD.FOR_FNF=1 AND ED.INCREMENT_ID = @INCREMENT_ID and ad.Claim_ID = @Claim_ID

			END
			--Added by Deepali 24nov21- start
			else
			begin
			INSERT INTO #FNF_DEDUCTION
				SELECT DISTINCT AD.AD_ID,AD.AD_NAME,ED.EMP_ID,@CLAIM_FNF_AMT
				FROM T0050_AD_MASTER AD INNER JOIN 
					 T0100_EMP_EARN_DEDUCTION ED  ON AD.AD_ID = ED.AD_ID 
				WHERE ED.CMP_ID=@CMP_ID AND ED.EMP_ID = @EMP_ID AND AD.FOR_FNF=1 AND ED.INCREMENT_ID = @INCREMENT_ID and AD.AD_FLAG = 'D'
			end
			--Added by Deepali 24nov21- End
				
			SELECT * FROM #FNF_DEDUCTION
	--- For Asset ---
	--select * from V0090_EMP_ASSET_DETAIL where Cmp_ID= @Cmp_ID And Emp_Id=@Emp_ID And isnull(return_date,'')='' order by Asset_Name asc --commented By Mukti 16102015
	SELECT TOP 1 * FROM T0040_ASSET_DETAILS WITH(NOLOCK) 
	WHERE CMP_ID= @CMP_ID ORDER BY ASSET_ID ASC --ADDED By Mukti 16102015
	--- End -- 		
	
	--select @Is_Short_Fall_Grade_wise = Is_Shortfall_Gradewise , @short_Fall_days_general = Short_Fall_Days from T0040_GENERAL_SETTING where Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID
	
	--if @Is_Short_Fall_Grade_wise = 1
	--	begin
	--		select @short_Fall_days_general = Short_Fall_Days from T0040_GRADE_MASTER where Grd_ID = @Grd_ID
	--	end	
	
	-- Added By Ali For Emp Notice Period -- Start
		Declare @Emp_Notice_Period as numeric(18,0)
		DECLARE @Is_Retire tinyint --Added by Hardik 29/06/2017 
		DECLARE @Is_Death tinyint --Added by Hardik 29/06/2017
		
		Set @Emp_Notice_Period = 0
		SELECT @EMP_NOTICE_PERIOD = EMP_NOTICE_PERIOD 
		FROM T0080_EMP_MASTER WITH(NOLOCK) 
		WHERE CMP_ID= @CMP_ID AND EMP_ID=@EMP_ID
		
		IF ISNULL(@EMP_NOTICE_PERIOD,0) = 0
			BEGIN
				SELECT @IS_SHORT_FALL_GRADE_WISE = IS_SHORTFALL_GRADEWISE , @SHORT_FALL_DAYS_GENERAL = SHORT_FALL_DAYS 
				FROM T0040_GENERAL_SETTING  WITH(NOLOCK) 
				WHERE BRANCH_ID = @BRANCH_ID AND CMP_ID = @CMP_ID
				AND FOR_DATE = ( SELECT MAX(FOR_DATE) 
								 FROM T0040_GENERAL_SETTING WITH(NOLOCK) 
								 WHERE FOR_DATE <=@TO_DATE AND BRANCH_ID = @BRANCH_ID AND CMP_ID = @CMP_ID)    
				
				IF @IS_SHORT_FALL_GRADE_WISE = 1
					BEGIN
						SELECT @SHORT_FALL_DAYS_GENERAL = SHORT_FALL_DAYS 
						FROM T0040_GRADE_MASTER WITH(NOLOCK)
						WHERE GRD_ID = @GRD_ID
					END	
			END
		ELSE
			BEGIN
				SET @SHORT_FALL_DAYS_GENERAL = @EMP_NOTICE_PERIOD
			END
	-- Added By Ali For Emp Notice Period -- Start

	SELECT @RESIG_DATE = ISNULL(REG_DATE,LEFT_DATE), @LEFT_DATE =LEFT_DATE, @IS_RETIRE = ISNULL(IS_RETIRE,0), @IS_DEATH = ISNULL(IS_DEATH,0)
	FROM T0100_LEFT_EMP WITH(NOLOCK) 
	WHERE EMP_ID =@EMP_ID 
	
	
	Set @Short_Fall_Days = ((@short_Fall_days_general - 1) - datediff(d,@Resig_Date,@Left_Date))

	-- Added by Hardik 10/07/2014 for Absent days should show under Short Fall Days in Wonder
	Declare @Absent_Days as numeric(18,2)
	Set @Absent_Days = 0
	
	--Insert Into #Absent
	--exec SP_RPT_EMP_ATTENDANCE_MUSTER_IN_EXCEL_New @Cmp_ID,@Reg_Accept_Date,@Left_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@Constraint,@Report_For='Absent_Summary',@Type=0,@Export_Type='FNF'

CREATE table #Att_Muster_Excel 
	  (	
			Emp_Id		numeric , 
			Cmp_ID		numeric,
			For_Date	datetime,
			Status		varchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS,
			Leave_Count	numeric(5,2),
			WO_HO		varchar(3) COLLATE SQL_Latin1_General_CP1_CI_AS,
			Status_2	varchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS,
			Row_ID		numeric ,
			WO_HO_Day	numeric(3,2) default 0,
			P_days		numeric(5,2) default 0,
			A_days		numeric(5,2) default 0 ,
			Join_Date	Datetime default null,
			Left_Date	Datetime default null,
			Gate_Pass_Days numeric(18,2) default 0,  -- Added by Gadriwala Muslim 07042015
			Late_Deduct_Days numeric(18,2) default 0, -- Added by Gadriwala Muslim 07042015
			Early_Deduct_Days numeric(18,2) default 0, -- Added by Gadriwala Muslim 07042015
			Emp_code    varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
			Emp_Full_Name  varchar(300) COLLATE SQL_Latin1_General_CP1_CI_AS,
			Branch_Address varchar(300) COLLATE SQL_Latin1_General_CP1_CI_AS,
			comp_name varchar(200) COLLATE SQL_Latin1_General_CP1_CI_AS,
			Branch_Name varchar(200) COLLATE SQL_Latin1_General_CP1_CI_AS,
			Dept_Name  varchar(200) COLLATE SQL_Latin1_General_CP1_CI_AS,
			Grd_Name varchar(200) COLLATE SQL_Latin1_General_CP1_CI_AS,
			Desig_Name varchar(200) COLLATE SQL_Latin1_General_CP1_CI_AS,
			P_From_date  datetime,
			P_To_Date datetime,
			BRANCH_ID numeric(18,0) ,
			Desig_Dis_No numeric(18,2) default 0,          ---added jimit 31082015
			SUBBRANCH_NAME VARCHAR(200) DEFAULT '' COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS
	  )
	  
	  
	  
CREATE NONCLUSTERED INDEX IX_Data ON dbo.#Att_Muster_Excel
	(	Emp_Id,Emp_code,Row_ID ) 
	
--exec SP_RPT_EMP_ATTENDANCE_MUSTER_GET @Cmp_ID,@Resig_Date,@To_Date,@Branch_ID,
--									  @Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,
--									  @Emp_ID,@Constraint,'','EXCEL'

if DATEDIFF(mm,@Resig_Date, @To_Date) > 6 -- Added by Rajput on 08112017
		exec SP_RPT_EMP_ATTENDANCE_MUSTER_GET @Cmp_ID,@To_Date,@To_Date,@Branch_ID,
										  @Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,
										  @Emp_ID,@Constraint,'','EXCEL'
	else
		exec SP_RPT_EMP_ATTENDANCE_MUSTER_GET @Cmp_ID,@Resig_Date,@To_Date,@Branch_ID,
									  @Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,
									  @Emp_ID,@Constraint,'','EXCEL'

  --changed By Jimit as it Consider Absent Days from Resignatio accept Date (WCL Case) 10072017

	--Select @Absent_Days = Sum(A_Days) from #Absent
	Select @Absent_Days = Sum(A_Days) from #Att_Muster_Excel

	Set @Short_Fall_Days = @Short_Fall_Days + ISNULL(@Absent_Days,0) --Comment Absent_Days not calculte in short fall days --Ankit 24082015
	-- End Hardik 10/07/2014
	
	
	if @Short_Fall_Days  < 0 or @Is_Retire =1 or @Is_Death=1 --- Retire and Death Condition added by Hardik 29/06/2017, For Cera, As Retire or Death Employee has no shortfall day calculate
		begin
			set @Short_Fall_Days  = 0
		end
	
	select top 1  @Advance_Amount = isnull(Adv_Closing,0) from T0140_Advance_Transaction where emp_id = @Emp_ID order by Adv_Tran_ID desc	
	
	
	-- Present Days --
	---Attendance Import Condition Added by Hardik 08/08/2018 for Aatash Client, As they have attendance import and present not showing in F&F
	DECLARE @Present_Days Numeric(18,5)
	Set @Present_Days = 0
	
	IF EXISTS(SELECT EMP_ID FROM  T0170_EMP_ATTENDANCE_IMPORT WITH(NOLOCK) WHERE Cmp_ID=@Cmp_ID and EMP_ID=@EMP_ID AND [Month]=Month(@To_Date) and [year]=YEAR(@To_Date))
		Begin									
			EXEC SP_GET_PRESENT_DAYS @EMP_ID,@Cmp_ID,@From_Date,@To_Date, @Present_Days output,0,0,0,0,@From_Date
			
			Set @Present_Days = @Present_Days			
		End 						
	ELSE
		BEGIN
			Exec SP_CALCULATE_PRESENT_DAYS @Cmp_ID,@From_Date,@To_Date,0,0,0,0,0,0,@Emp_ID,'',4	
			
			SELECT @Present_Days = isnull(sum(P_Days),0) - ISNULL(sum(GatePass_Deduct_Days),0)  --changed by jimit 26072019 redmine bug no 297
			FROM  #Data WHERE Emp_ID=@emp_ID and For_Date>=@From_Date and For_Date <=@To_Date  
		END
	
		Select @Present_Days As Present_Days, isnull(@Short_Fall_Days,0) as Short_Fall_Days, @Advance_Amount as Advance_Amount 
	---
	
	DELETE T0100_LEAVE_CF_DETAIL  WHERE LEAVE_CF_ID IN (SELECT LEAVE_CF_ID FROM #TEMPCF)
	
	DROP TABLE #TEMPCF
	
	declare @Extra_Days as numeric 
	SET @Extra_Days = 0
	
	
	--Arear Days --  Gadriwala 03122013
	if  not exists (Select Emp_ID From T0200_MONTHLY_SALARY WITH(NOLOCK)  WHERE EMP_ID =@EMP_ID AND Month(Month_End_Date)  = MONTH(@Left_Date) AND  Year(Month_End_Date) = YEAR(@Left_Date) )
			Select  Extra_Days,Extra_Day_Month,Extra_Day_Year  
			From T0190_MONTHLY_PRESENT_IMPORT WITH(NOLOCK) 
			WHERE EMP_ID =@EMP_ID AND MONTH = MONTH(@Left_Date) AND YEAR = YEAR(@Left_Date)
	else
			select @Extra_Days as Extra_Days,Month(Getdate()) as Extra_Day_Month , Year(Getdate()) as Extra_Day_Year
			
	
	
	RETURN

