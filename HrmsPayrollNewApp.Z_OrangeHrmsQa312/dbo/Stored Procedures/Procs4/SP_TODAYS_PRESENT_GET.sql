

CREATE PROCEDURE [dbo].[SP_TODAYS_PRESENT_GET]  
	@CMP_ID NUMERIC,  
	@BRANCH_ID NUMERIC,  
	@Todate datetime,  
	@Type char(1),
	@Flag_Dashboard NUMERIC = 0,
	@P_Branch varchar(max)='',   --Added by Jaina 10-08-2016
	@P_Vertical varchar(max) = '', --Added by Jaina 10-08-2016
	@P_SubVertical varchar(max) = '', --Added by Jaina 10-08-2016
	@P_Department	varchar(max) = '', --Added by Jaina 10-08-2016  
	@Shift_ID		varchar(max) = '' --Ankit 03092016
AS  
	SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON
	
	--Added By Jaina 10-08-2016 Start

	IF	@P_Branch = '' or @P_Branch = '0'
		SET @P_Branch = NULL
			
	IF @P_Vertical = '' or @P_Vertical = '0'
		SET @P_Vertical = NULL
					
	IF @P_SubVertical = '' or @P_SubVertical='0'
		SET @P_SubVertical = NULL
				
	IF @P_Department = '' or @P_Department='0'
		SET @P_Department = NULL
			
	IF @Shift_ID = '' OR @Shift_ID = '0'
		SET @Shift_ID = NULL
		
	IF @Shift_ID IS NULL
		BEGIN	
			SELECT   @Shift_ID = COALESCE(@Shift_ID + '#', '') + CAST(Shift_ID AS NVARCHAR(5))  FROM T0040_SHIFT_MASTER WITH (NOLOCK) WHERE Cmp_ID=@Cmp_ID 
			SET		 @Shift_ID = @Shift_ID + '#0'
		END
				
						
	IF @P_Branch is null
		BEGIN	
			SELECT   @P_Branch = COALESCE(@P_Branch + '#', '') + CAST(Branch_ID AS NVARCHAR(5))  FROM T0030_BRANCH_MASTER WITH (NOLOCK) WHERE Cmp_ID=@Cmp_ID 
			SET @P_Branch = @P_Branch + '#0'
		END
				
	IF @P_Vertical is null
		BEGIN	
			SELECT   @P_Vertical = COALESCE(@P_Vertical + '#', '') + CAST(Vertical_ID AS NVARCHAR(5))  FROM T0040_Vertical_Segment WITH (NOLOCK) WHERE Cmp_ID=@Cmp_ID 
					
			IF @P_Vertical IS NULL
				SET @P_Vertical = '0';
			ELSE
				SET @P_Vertical = @P_Vertical + '#0'		
		END
				
	IF @P_SubVertical is null
		BEGIN	
			SELECT   @P_SubVertical = COALESCE(@P_SubVertical + '#', '') + CAST(subVertical_ID AS NVARCHAR(5))  FROM T0050_SubVertical WITH (NOLOCK) WHERE Cmp_ID=@Cmp_ID 
					
			IF @P_SubVertical IS NULL
				SET @P_SubVertical = '0';
			ELSE
				SET @P_SubVertical = @P_SubVertical + '#0'
		END

	IF @P_Department is null
		BEGIN
			SELECT   @P_Department = COALESCE(@P_Department + '#', '') + CAST(Dept_ID AS NVARCHAR(5))  FROM T0040_DEPARTMENT_MASTER WITH (NOLOCK) WHERE Cmp_ID=@Cmp_ID 		
					
			IF @P_Department is null
				SET @P_Department = '0';
			ELSE
				SET @P_Department = @P_Department + '#0'
		END
				
	--Added By Jaina 10-08-2016 End	


	CREATE TABLE #PRESENT
	(  
		EMP_ID   NUMERIC,  
		EMP_CODE  varchar(100),  
		EMP_FULL_NAME VARCHAR(100),  
		IN_TIME   DATETIME,
		OUT_TIME   DATETIME, -- Added By nilesh patel on 19122014
		Design_Name Varchar(500),  -- Added By nilesh patel on 19122014
		STATUS   CHAR(2),
		type     varchar(50),
		Type_Name varchar(100),
		Late_Come Varchar(10), -- Added by nilesh on 22122014 For Rotation Attendance Dashboard
		Early_Goes Varchar(10) -- Added by nilesh on 22122014 For Rotation Attendance Dashboard
	)  

	CREATE TABLE #P
	(  
		COUNT NUMERIC(18,0),  
		BRANCH_ID NUMERIC ,  
		CMP_ID NUMERIC   
	)  
	CREATE TABLE #A 
	(  
		COUNT NUMERIC(18,0) ,  
		BRANCH_ID NUMERIC ,  
		CMP_ID NUMERIC   
	)  

	CREATE TABLE #L
	(  
		COUNT NUMERIC(18,0) ,  
		BRANCH_ID NUMERIC ,  
		CMP_ID NUMERIC   
	)  

	CREATE TABLE #OD
	(  
		COUNT NUMERIC(18,0) ,  
		BRANCH_ID NUMERIC ,  
		CMP_ID NUMERIC   
	)  
	CREATE TABLE #T 
	(  
		COUNT NUMERIC(18,0) ,  
		BRANCH_ID NUMERIC ,  
		CMP_ID NUMERIC   
	)  

	CREATE TABLE #WO
	(  
		COUNT NUMERIC(18,0) ,  
		BRANCH_ID NUMERIC ,  
		CMP_ID NUMERIC   
	)  

	CREATE TABLE #LI  -- Added by nilesh on 22122014 For Rotation Attendance Dashboard
	(  
		COUNT NUMERIC(18,0) ,  
		BRANCH_ID NUMERIC ,  
		CMP_ID NUMERIC   
	) 

	CREATE TABLE #EO  -- Added by nilesh on 22122014 For Rotation Attendance Dashboard
	(  
		COUNT NUMERIC(18,0) ,  
		BRANCH_ID NUMERIC ,  
		CMP_ID NUMERIC   
	)

	---Added by Hardik 21/11/2016 
	CREATE TABLE #Emp_Cons 
	(      
		Emp_ID numeric ,     
		Branch_ID numeric,
		Increment_ID numeric    
	)      
	-- Ankit 08092014 for Same Date Increment
	--EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@Todate,@Todate,@Branch_ID,0,0,0,0,0 ,0 ,'' ,0,0,0,0,0,0,0,0,2,0 
	exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID=@Cmp_ID,@From_Date=@ToDate,@To_Date=@ToDate,@Branch_ID=@Branch_ID,@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Emp_ID=0,
							@constraint='',@Sal_Type=0,@Salary_Cycle_id=0,@Segment_Id=0,@Vertical_Id=@P_Vertical,@SubVertical_Id=@P_SubVertical,@SubBranch_Id=0,@New_Join_emp=0,
							@Left_Emp=0,@SalScyle_Flag=0,@PBranch_ID=@P_Branch,@With_Ctc=0,@Type=0    

	
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
    EXEC P_GET_EMP_INOUT @Cmp_ID,@Todate,@Todate,1  

	----Commented & Added below condition by Hardik 21/11/2016  

	--INSERT INTO #PRESENT (EMP_ID,EMP_CODE,EMP_FULL_NAME,IN_TIME,OUT_TIME,Design_Name,STATUS,type,Type_Name)   
	--(SELECT Distinct eir.Emp_ID,CAST(EM.Alpha_Emp_Code  AS varchar(100))   AS EMP_CODE, em.EMP_FULL_NAME  AS Emp_Full_Name,qry.intime,qry.outtime,DM.Desig_Name,'P','<font color="Darkblue">' + 'P' + '</font>',('<font color="green">
	--' + Type_name + '</font>') AS  Type_name FROM t0150_emp_inout_record eir
	--INNER JOIN (SELECT Min(In_time) AS intime,
	--  Case When Max_In > Max(Out_Time) Then Max_In ELSE Max(Out_time) End AS outtime,e.For_Date,e.Emp_ID FROM dbo.T0150_emp_inout_record e Inner Join
	--  (SELECT Max(In_time) Max_In,Emp_Id,For_Date FROM dbo.T0150_emp_inout_record WHERE  For_Date = @Todate Group by Emp_ID,For_Date) m
	--								on e.Emp_ID = M.Emp_ID and E.For_Date = M.For_Date
	--								WHERE  E.For_Date = @Todate
	--								group by Max_In,e.For_Date,e.Emp_ID  )as qry 
	--									on eir.Emp_ID = qry.Emp_ID AND eir.For_Date  = qry.For_Date    
	--inner join t0080_emp_master em on eir.emp_id=em.emp_id 
	--INNER JOIN T0095_INCREMENT AS I ON EM.INCREMENT_ID=I.INCREMENT_ID 
	--INNER JOIN T0040_DESIGNATION_MASTER DM on DM.Desig_ID = em.Desig_Id 
	--left outer join t0040_type_master TM on em.type_id=tm.type_id
	--WHERE month(eir.in_time)   = month(getdate()) and Year(eir.in_time) = year(getdate()) 
	--and day(eir.in_time)   = day(getdate()) AND I.BRANCH_ID = @BRANCH_ID AND I.CMP_ID = @CMP_ID --)
	--AND NOT EXISTS ( SELECT For_Date FROM  T0140_LEAVE_TRANSACTION LT  --Double Entry In Dash Board  - Ankit 05092016
	--					WHERE eir.Emp_ID = LT.Emp_ID AND eir.For_Date = LT.For_Date AND (LT.Leave_Used <> 0 OR LT.CompOff_Used <> 0) )   
	--)					

	INSERT INTO #PRESENT (EMP_ID,EMP_CODE,EMP_FULL_NAME,IN_TIME,OUT_TIME,Design_Name,STATUS,type,Type_Name)   
	(SELECT Distinct eir.Emp_ID,CAST(EM.Alpha_Emp_Code  AS varchar(100))   AS EMP_CODE, em.EMP_FULL_NAME  AS Emp_Full_Name,d.In_Time,d.OUT_Time,DM.Desig_Name,'P','<font color="Darkblue">' + 'P' + '</font>',('<font color="green">
	' + Type_name + '</font>') AS  Type_name FROM t0150_emp_inout_record eir WITH (NOLOCK)
	INNER JOIN #Data D on eir.Emp_ID = d.Emp_ID AND eir.For_Date  = d.For_Date --Changed this condition by Hardik 21/11/2016
	inner join t0080_emp_master em WITH (NOLOCK) on eir.emp_id=em.emp_id 
	INNER JOIN #Emp_Cons EC ON EC.Emp_ID = em.Emp_ID  --Added by Jaina 07-03-2017
	INNER JOIN T0095_INCREMENT AS I WITH (NOLOCK) ON EC.INCREMENT_ID=I.INCREMENT_ID 
	INNER JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on DM.Desig_ID = I.Desig_Id 
	left outer join t0040_type_master TM WITH (NOLOCK) on I.type_id=tm.type_id
	WHERE month(eir.in_time)   = month(getdate()) and Year(eir.in_time) = year(getdate()) 
	and day(eir.in_time)   = day(getdate()) AND I.BRANCH_ID = @BRANCH_ID AND I.CMP_ID = @CMP_ID --)
	AND NOT EXISTS ( SELECT For_Date FROM  T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) --Double Entry In Dash Board  - Ankit 05092016
						WHERE eir.Emp_ID = LT.Emp_ID AND eir.For_Date = LT.For_Date AND (LT.Leave_Used <> 0 OR LT.CompOff_Used <> 0) )   
	)					


	INSERT INTO #PRESENT (EMP_ID,EMP_CODE,EMP_FULL_NAME,Design_Name,STATUS,type,Type_Name)  
	SELECT DISTINCT la.Emp_ID, CAST(EM.Alpha_Emp_Code  AS varchar(100))  AS EMP_CODE,( em.EMP_FULL_NAME ) AS Emp_Full_Name,DM.Desig_Name,'L','<font color="blue">' + 'L' + '</font>' ,(Type_name)
	as  Type_name  FROM t0120_leave_approval AS la WITH (NOLOCK)  
	inner join t0080_emp_master AS em WITH (NOLOCK) on la.emp_id=em.emp_ID 
	inner JOIN #Emp_Cons EC ON EC.Emp_ID = em.Emp_ID  --Added by Jaina 07-03-2017
	INNER JOIN T0095_INCREMENT AS I WITH (NOLOCK) ON EC.INCREMENT_ID = I.INCREMENT_ID 
	inner JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) ON DM.Desig_ID = I.Desig_Id
	left outer join t0130_leave_approval_detail AS lad WITH (NOLOCK) on la.leave_approval_ID=lad.leave_approval_ID Inner join t0040_leave_master TLM WITH (NOLOCK) on lad.Leave_ID=TLM.Leave_ID 
	left outer join t0040_type_master TM WITH (NOLOCK) on I.type_id=tm.type_id Left Outer Join T0150_LEAVE_CANCELLATION AS LC WITH (NOLOCK) On lad.Leave_Approval_ID =Lc.Leave_Approval_ID 
	WHERE lad.from_Date < = @Todate and lad.To_Date >= @Todate and la.approval_status='A' AND I.BRANCH_ID=@BRANCH_ID AND I.CMP_ID=@CMP_ID And Leave_TYpe <> 'Company Purpose'-- And  Lv_can_Status=0 
	and isnull(LC.Is_Approve,0) =0 -- this line added by mihir 10012012


  
	INSERT INTO #PRESENT (EMP_ID,EMP_CODE,EMP_FULL_NAME,Design_Name,STATUS,type,Type_Name)  
	SELECT la.Emp_ID, CAST(EM.Alpha_Emp_Code  AS varchar(100))   AS EMP_CODE,( em.EMP_FULL_NAME ) AS Emp_Full_Name,DM.Desig_Name,'OD','<font color="orange">' + 'OD' + '</font>',(Type_name ) AS  Type_name 
	FROM t0120_leave_approval AS la WITH (NOLOCK)  
	inner join t0080_emp_master AS em WITH (NOLOCK) on la.emp_id=em.emp_ID 
	INNER JOIN #Emp_Cons EC ON EC.Emp_ID = em.Emp_ID  --Added by Jaina 07-03-2017
	inner JOIN T0095_INCREMENT AS I WITH (NOLOCK) ON EC.INCREMENT_ID = I.INCREMENT_ID 
	inner JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) ON DM.Desig_ID = I.Desig_Id
	left outer join   
	t0130_leave_approval_detail AS lad WITH (NOLOCK) on la.leave_approval_ID=lad.leave_approval_ID Inner join t0040_leave_master TLM WITH (NOLOCK) on lad.Leave_ID=TLM.Leave_ID 
	left outer join t0040_type_master TM WITH (NOLOCK) on I.type_id=tm.type_id
	WHERE   
	lad.from_Date < = @Todate and lad.To_Date >= @Todate and la.approval_status='A' AND isnull(I.BRANCH_ID,0)=isnull(@BRANCH_ID,isnull(I.Branch_ID,0)) AND I.CMP_ID=@CMP_ID And Leave_TYpe = 'Company Purpose'  
	AND NOT EXISTS ( SELECT Leave_Approval_ID FROM T0150_LEAVE_CANCELLATION WITH (NOLOCK) WHERE CMP_ID=@CMP_ID AND Is_Approve = 1 AND Leave_Approval_ID = lad.Leave_Approval_ID )	--Ankit 23082016



	INSERT INTO #PRESENT (EMP_ID,EMP_CODE,EMP_FULL_NAME,Design_Name,STATUS,type,Type_Name)  
	SELECT em.Emp_ID , CAST(EM.Alpha_EMP_CODE  AS varchar(100))   AS EMP_CODE,( em.EMP_FULL_NAME ) AS Emp_Full_Name,DM.Desig_Name,'A','<font color="Red">' + 'A' + '</font>',(Type_name) AS  Type_name  
	FROM t0080_emp_master em WITH (NOLOCK) inner join
	#Emp_Cons EC ON EC.Emp_ID = em.Emp_ID --Added by Jaina 07-03-2017
	inner JOIN T0095_INCREMENT I WITH (NOLOCK) ON I.Increment_ID = EC.Increment_ID
	inner JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) ON DM.Desig_ID = I.Desig_Id
	left outer join t0040_type_master TM WITH (NOLOCK) on I.type_id=tm.type_id
	WHERE em.emp_id not in (SELECT emp_id FROM #PRESENT) and EC.BRANCH_ID=@BRANCH_ID AND em.CMP_ID=@CMP_ID  
  

 
	---- Alpesh 26-May-2012 ---- to show IF week off is on that perticular date instead of absent
	--Declare @Emp_ID	numeric
	
	--Declare @Is_Cancel_Holiday  Numeric(1,0)    
	--Declare @Is_Cancel_Weekoff  Numeric(1,0)
	--Declare @Left_Date		datetime  
	--Declare @join_dt   		datetime  
	--Declare @StrHoliday_Date  varchar(max)    
	--Declare @StrWeekoff_Date  varchar(max)
	--Declare @Cancel_Weekoff	numeric(18, 0)
	--Declare @WO_Days	numeric
	--Declare @Cancel_Holiday   numeric(18, 0)
	--Declare @Emp_Left_Date	datetime
  
	--SET @Is_Cancel_Weekoff = 0 
	--SET @StrHoliday_Date = ''    
	--SET @StrWeekoff_Date = ''  
  
	--IF @Branch_ID is null
	--	BEGIN 
	--		SELECT Top 1 @Is_Cancel_Weekoff = Is_Cancel_Weekoff FROM T0040_GENERAL_SETTING WHERE cmp_ID = @cmp_ID    
	--		and For_Date = ( SELECT max(For_Date) FROM T0040_GENERAL_SETTING WHERE For_Date <= GETDATE() and Cmp_ID = @Cmp_ID)    
	--	End
	--ELSE
	--	BEGIN
	--		SELECT @Is_Cancel_Weekoff = Is_Cancel_Weekoff FROM T0040_GENERAL_SETTING WHERE cmp_ID = @cmp_ID and Branch_ID = @Branch_ID    
	--		and For_Date = ( SELECT max(For_Date) FROM T0040_GENERAL_SETTING WHERE For_Date <= GETDATE() and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)    
	--	End
  
	--Declare cur cursor for SELECT EMP_ID FROM #PRESENT
	--Open cur
	--Fetch Next FROM cur into @Emp_ID
  
	--While @@FETCH_STATUS = 0
	--	BEGIN
	--		SELECT @join_dt=Date_Of_Join,@Left_Date=Emp_Left_Date FROM T0080_EMP_MASTER WHERE Cmp_ID=@CMP_ID and Emp_ID=@Emp_ID
				
		
	--		EXEC SP_EMP_WEEKOFF_DATE_GET @Emp_ID,@Cmp_ID,@Todate,@Todate,@join_dt,@left_Date,@Is_Cancel_weekoff,@StrHoliday_Date,@StrWeekoff_Date output,@WO_Days output ,@Cancel_Weekoff output    	
		
	--		IF CHARINDEX(CONVERT(VARCHAR(11),GETDATE(),109),@StrWeekoff_Date,0) > 0
	--			BEGIN
	--				UPDATE	#PRESENT 
	--				SET		STATUS='WO',
	--						type='<font color="Green">' + 'WO' + '</font>'
	--				WHERE EMP_ID = @Emp_ID and STATUS = 'A'
	--			End
		
	--		SET @StrHoliday_Date = ''    
	--		SET @StrWeekoff_Date = ''  
  
	--		Fetch Next FROM cur into @Emp_ID
	--	End
  
	--Close cur
	--Deallocate cur
	------ End ----

--		 -- Added by nilesh on 22122014 For Rotation Attendance Dashboard --start
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
	SELECT	@CONSTRAINT = COALESCE(@CONSTRAINT + '#','') + CAST(EMP_ID AS VARCHAR(10))
	FROM	(SELECT DISTINCT EMP_ID FROM #PRESENT) T

	EXEC SP_GET_HW_ALL @CONSTRAINT=@CONSTRAINT,@CMP_ID=@Cmp_ID, @FROM_DATE=@Todate, @TO_DATE=@Todate, @All_Weekoff = 0, @Exec_Mode=1		

	UPDATE	P 
	SET		STATUS='WO',
			type='<font color="Green">WO</font>'
	FROM	#PRESENT P 
			INNER JOIN #EMP_WEEKOFF WO ON P.EMP_ID=WO.Emp_ID AND WO.For_Date=CONVERT(DATETIME, CONVERT(CHAR(10), GETDATE(), 103), 103)
	WHERE	STATUS = 'A'


	Declare @Emp_ID_INOUT	numeric
	IF @Flag_Dashboard = 1 
		BEGIN
			CREATE TABLE #inout_report
			 (
				Late_in Varchar(100),
				Early_out Varchar(100),
				Emp_ID Numeric
			 )
			 Declare cur_in_out cursor for SELECT EMP_ID FROM #PRESENT
			  Open cur_in_out
			  Fetch Next FROM cur_in_out into @Emp_ID_INOUT
		  
			  While @@FETCH_STATUS = 0
				BEGIN
					Declare @Late_In_Time Varchar
					Declare @Early_Out_Time Varchar
					insert into #inout_report  exec SP_RPT_EMP_INOUT_RECORD_GET @CMP_ID,@Todate,@Todate,@BRANCH_ID,0,0,0,0,0,0,@Emp_ID_INOUT,'IN-OUT','Y','0','D'
					SELECT @Late_In_Time = Late_in, @Early_Out_Time = Early_out FROM #inout_report IO WHERE IO.Emp_ID = @Emp_ID_INOUT
					--SELECT @Late_In_Time,@Early_Out_Time
					IF @Late_In_Time <> ''
						BEGIN
							Update #PRESENT Set
								 Late_Come = 1
							WHERE EMP_ID = @Emp_ID_INOUT and STATUS = 'P'
						End
					IF @Early_Out_Time <> ''
						BEGIN
							Update #PRESENT Set
								 Early_Goes = 1
							WHERE EMP_ID = @Emp_ID_INOUT and STATUS = 'P'
						End
					Fetch Next FROM cur_in_out into @Emp_ID_INOUT
				End
		  
			  Close cur_in_out
			  Deallocate cur_in_out
		End 
		 
--Added by nilesh on 22122014 For Rotation Attendance Dashboard --start


IF @Type = 'X'  
BEGIN

				
 SELECT CAST(P.EMP_ID AS VARCHAR(10)) AS EMP_ID,P.EMP_CODE,P.EMP_FULL_NAME  AS EMP_FULL_NAME,
 (case when Late_Come = 1 then '<font color="Red">' + isnull(convert(char(5), P.IN_TIME, 108),'00:00')  + '</font>' ELSE isnull(convert(char(5), P.IN_TIME, 108),'00:00') END)  AS IN_TIME, -- Added by nilesh on 22122014 For Rotation Attendance Dashboard
 (case when Early_Goes = 1 then  '<font color="Red">' + Isnull(convert(char(5),p.OUT_TIME, 108),'00:00') + '</font>' ELSE Isnull(convert(char(5),p.OUT_TIME, 108),'00:00') END) AS OUT_TIME, -- Added by nilesh on 22122014 For Rotation Attendance Dashboard
 P.STATUS,P.type, P.Type_Name ,p.Design_Name ,Cast(QryShift.Shift_ID As Varchar(10)) AS Shift_ID,p.Late_Come,p.Early_Goes
 FROM  #PRESENT AS p inner join 
 T0080_EMP_MASTER AS EM WITH (NOLOCK) ON P.EMP_ID = EM.EMP_ID INNER JOIN  
 --Added By Jaina 10-08-2016 Start
 	(SELECT	I1.EMP_ID, I1.INCREMENT_ID, I1.BRANCH_ID,I1.Vertical_ID,I1.SubVertical_ID,I1.Dept_ID
				FROM	T0095_INCREMENT I1 WITH (NOLOCK) INNER JOIN
						 (SELECT	MAX(I2.Increment_ID) AS Increment_ID, I2.Emp_ID
						  FROM	T0095_INCREMENT I2 WITH (NOLOCK)
								INNER JOIN (SELECT	MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
											FROM	T0095_INCREMENT I3 WITH (NOLOCK)
											WHERE	I3.Increment_Effective_Date <= @ToDate
											GROUP BY I3.Emp_ID
											) I3 ON I2.Increment_Effective_Date=I3.INCREMENT_EFFECTIVE_DATE AND I2.Emp_ID=I3.Emp_ID																		
						  WHERE	I2.Cmp_ID = @Cmp_Id 
						  GROUP BY I2.Emp_ID
						) I2 ON I1.Emp_ID=I2.Emp_ID AND I1.Increment_ID=I2.INCREMENT_ID	
				WHERE	I1.Cmp_ID=@Cmp_Id											
	) I_Q ON EM.EMP_ID=I_Q.Emp_ID	
	INNER JOIN	--Ankit 03092016	
	( SELECT shift_ID,ES.For_Date,ES.Emp_ID FROM T0100_EMP_SHIFT_DETAIL ES WITH (NOLOCK) INNER JOIN	
			(   SELECT MAX(For_Date) AS For_Date ,Emp_ID FROM T0100_EMP_SHIFT_DETAIL WITH (NOLOCK)
				WHERE For_Date <= @Todate AND cmp_ID = @CMP_ID GROUP BY Emp_ID
			)	sQry ON ES.Emp_ID = sQry.Emp_ID AND ES.For_Date = sQry.For_Date
	) QryShift ON QryShift.Emp_ID = P.EMP_ID
 WHERE em.emp_left='N' 
 and EXISTS (SELECT Data FROM dbo.Split(@P_Branch, '#') B WHERE CAST(B.data AS numeric)=Isnull(I_Q.Branch_ID,0))
 and EXISTS (SELECT Data FROM dbo.Split(@P_Vertical, '#') VE WHERE CAST(VE.data AS numeric)=Isnull(I_Q.Vertical_ID,0))
 and EXISTS (SELECT Data FROM dbo.Split(@P_SubVertical, '#') S WHERE CAST(S.data AS numeric)=Isnull(I_Q.SubVertical_ID,0))
 and EXISTS (SELECT Data FROM dbo.Split(@P_Department, '#') D WHERE CAST(D.data AS numeric)=Isnull(I_Q.Dept_ID,0))    		     
 AND EXISTS (SELECT Data FROM dbo.Split(@Shift_ID, '#') DE WHERE CAST(DE.data AS numeric)=Isnull(QryShift.shift_ID,0))   
 --Added By Jaina 10-08-2016 End					
 Order by Case When IsNumeric(em.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + em.Alpha_Emp_Code, 20)
			When IsNumeric(em.Alpha_Emp_Code) = 0 then Left(em.Alpha_Emp_Code + Replicate('',21), 20)
				ELSE em.Alpha_Emp_Code
			End 
END   
  --SELECT P.EMP_ID,P.EMP_CODE,P.EMP_FULL_NAME,P.STATUS FROM  #PRESENT AS p inner join t0080_emp_master AS em on p.Emp_ID = em.emp_id   
   
 --WHERE em.emp_left='N'   order by status desc  
ELSE IF @Type = 'Y'  
 BEGIN  
 
 --Commented by Hardik 21/11/2016 AS #Emp_Cons created above with SP
 --Added By Jaina 10-08-2016 Start
 --SELECT EM.Emp_ID 
 -- Into #Emp_Cons 
 -- FROM T0080_EMP_MASTER AS EM INNER JOIN  
	--					 (SELECT	I1.EMP_ID, I1.INCREMENT_ID, I1.BRANCH_ID,I1.Vertical_ID,I1.SubVertical_ID,I1.Dept_ID
	--							FROM	T0095_INCREMENT I1 INNER JOIN
	--											 (SELECT	MAX(I2.Increment_ID) AS Increment_ID, I2.Emp_ID
	--												FROM	T0095_INCREMENT I2 
	--														INNER JOIN (SELECT	MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
	--																	FROM	T0095_INCREMENT I3 
	--																	WHERE	I3.Increment_Effective_Date <= @ToDate
	--																	GROUP BY I3.Emp_ID
	--																	) I3 ON I2.Increment_Effective_Date=I3.INCREMENT_EFFECTIVE_DATE AND I2.Emp_ID=I3.Emp_ID																		
	--												WHERE	I2.Cmp_ID = @Cmp_Id 
	--												GROUP BY I2.Emp_ID
	--												) I2 ON I1.Emp_ID=I2.Emp_ID AND I1.Increment_ID=I2.INCREMENT_ID	
	--							WHERE	I1.Cmp_ID=@Cmp_Id											
	--					) I_Q ON EM.EMP_ID=I_Q.Emp_ID	
	
 -- WHERE em.emp_left='N' 
	--  and EXISTS (SELECT Data FROM dbo.Split(@P_Branch, '#') B WHERE CAST(B.data AS numeric)=Isnull(I_Q.Branch_ID,0))
	--  and EXISTS (SELECT Data FROM dbo.Split(@P_Vertical, '#') VE WHERE CAST(VE.data AS numeric)=Isnull(I_Q.Vertical_ID,0))
	--  and EXISTS (SELECT Data FROM dbo.Split(@P_SubVertical, '#') S WHERE CAST(S.data AS numeric)=Isnull(I_Q.SubVertical_ID,0))
	--  and EXISTS (SELECT Data FROM dbo.Split(@P_Department, '#') D WHERE CAST(D.data AS numeric)=Isnull(I_Q.Dept_ID,0))    		     

 --Added By Jaina 10-08-2016 End
	
	--'' Ankit 03092016
	IF ISNULL(@Shift_ID,'') <> ''
		BEGIN
			DELETE P
			FROM #PRESENT P INNER JOIN	
			( SELECT shift_ID,ES.For_Date,ES.Emp_ID FROM T0100_EMP_SHIFT_DETAIL ES WITH (NOLOCK) INNER JOIN	
					(   SELECT MAX(For_Date) AS For_Date ,Emp_ID FROM T0100_EMP_SHIFT_DETAIL WITH (NOLOCK) 
						WHERE For_Date <= @Todate AND cmp_ID = @CMP_ID GROUP BY Emp_ID
					)	sQry ON ES.Emp_ID = sQry.Emp_ID AND ES.For_Date = sQry.For_Date
			) QryShift ON QryShift.Emp_ID = P.EMP_ID
			WHERE NOT EXISTS (SELECT Data FROM dbo.Split(@Shift_ID, '#') D WHERE CAST(D.data AS numeric)=Isnull(QryShift.shift_ID,0))    		     
		
		END
	
		
  INSERT INTO #P  
  SELECT COUNT(distinct(P.EMP_ID)),0,0 FROM  #PRESENT AS p inner join t0080_emp_master AS em WITH (NOLOCK) on p.Emp_ID = em.emp_id inner join  #Emp_Cons E on e.Emp_id = p.Emp_id  WHERE em.emp_left='N' AND status='P'--  order by  desc  
  UPDATE #P SET BRANCH_ID=@BRANCH_ID,CMP_ID=@CMP_ID  
    
  INSERT INTO #A  
  SELECT COUNT(distinct(P.EMP_ID)),0,0 FROM  #PRESENT AS p inner join t0080_emp_master AS em WITH (NOLOCK) on p.Emp_ID = em.emp_id inner join  #Emp_Cons E on e.Emp_id = p.Emp_id  WHERE em.emp_left='N' AND status='A'--  order by  desc  
  UPDATE #A SET BRANCH_ID=@BRANCH_ID,CMP_ID=@CMP_ID  
    
  INSERT INTO #L  
  SELECT COUNT(distinct(P.EMP_ID)),0,0 FROM  #PRESENT AS p inner join t0080_emp_master AS em WITH (NOLOCK) on p.Emp_ID = em.emp_id inner join  #Emp_Cons E on e.Emp_id = p.Emp_id  WHERE em.emp_left='N' AND status='L'--  order by  desc  
  UPDATE #L SET BRANCH_ID=@BRANCH_ID,CMP_ID=@CMP_ID  
    
  INSERT INTO #OD  
  SELECT COUNT(distinct(P.EMP_ID)),0,0 FROM  #PRESENT AS p inner join t0080_emp_master AS em WITH (NOLOCK) on p.Emp_ID = em.emp_id inner join  #Emp_Cons E on e.Emp_id = p.Emp_id  WHERE em.emp_left='N' AND status='OD'--  order by  desc  
  UPDATE #OD SET BRANCH_ID=@BRANCH_ID,CMP_ID=@CMP_ID  
   
  INSERT INTO #WO  
  SELECT COUNT(distinct(P.EMP_ID)),0,0 FROM  #PRESENT AS p inner join t0080_emp_master AS em WITH (NOLOCK) on p.Emp_ID = em.emp_id inner join  #Emp_Cons E on e.Emp_id = p.Emp_id  WHERE em.emp_left='N' AND status='WO'--  order by  desc  
  UPDATE #WO SET BRANCH_ID=@BRANCH_ID,CMP_ID=@CMP_ID    
    
  INSERT INTO #T  
  SELECT COUNT(distinct(P.EMP_ID)),0,0 FROM  #PRESENT AS p inner join t0080_emp_master AS em WITH (NOLOCK) on p.Emp_ID = em.emp_id inner join  #Emp_Cons E on e.Emp_id = p.Emp_id  WHERE em.emp_left='N'  -- order by status desc  
  UPDATE #T SET BRANCH_ID=@BRANCH_ID,CMP_ID=@CMP_ID 
  
  INSERT INTO #LI   -- Added by nilesh on 22122014 For Rotation Attendance Dashboard
  SELECT COUNT(distinct(P.EMP_ID)),0,0 FROM  #PRESENT AS p inner join t0080_emp_master AS em WITH (NOLOCK) on p.Emp_ID = em.emp_id inner join  #Emp_Cons E on e.Emp_id = p.Emp_id  WHERE em.emp_left='N' AND status='P' and Late_Come = 1 --  order by  desc  
  UPDATE #LI SET BRANCH_ID=@BRANCH_ID,CMP_ID=@CMP_ID 
  
  INSERT INTO #EO  -- Added by nilesh on 22122014 For Rotation Attendance Dashboard 
  SELECT COUNT(distinct(P.EMP_ID)),0,0 FROM  #PRESENT AS p inner join t0080_emp_master AS em WITH (NOLOCK) on p.Emp_ID = em.emp_id inner join  #Emp_Cons E on e.Emp_id = p.Emp_id  WHERE em.emp_left='N' AND status='P' and Early_Goes = 1 --  order by  desc  
  UPDATE #EO SET BRANCH_ID=@BRANCH_ID,CMP_ID=@CMP_ID 
    
    
  --SELECT  P.COUNT AS PRESENT ,A.COUNT AS ABSENT,L.COUNT AS LEAVE ,OD.COUNT AS OD,T.COUNT AS TOTAL  
  --FROM #P P INNER JOIN #L L ON P.BRANCH_ID=L.BRANCH_ID INNER JOIN  
  --#A A ON L.BRANCH_ID = A.BRANCH_ID INNER JOIN #T T ON A.BRANCH_ID=T.BRANCH_ID   
  --INNER JOIN #OD OD ON T.BRANCH_ID=OD.BRANCH_ID    
  --WHERE A.CMP_ID=@CMP_ID 
  
  SELECT  P.COUNT AS PRESENT ,A.COUNT AS ABSENT,L.COUNT AS LEAVE ,OD.COUNT AS OD, WO.COUNT AS WO,T.COUNT AS TOTAL,
  LI.COUNT AS Late_Commer,EO.COUNT AS Early_Goes 
  FROM #P P INNER JOIN #L L ON P.BRANCH_ID=L.BRANCH_ID INNER JOIN  
  #A A ON L.BRANCH_ID = A.BRANCH_ID INNER JOIN #T T ON A.BRANCH_ID=T.BRANCH_ID   
  INNER JOIN #OD OD ON T.BRANCH_ID=OD.BRANCH_ID  
  INNER JOIN #WO WO ON T.BRANCH_ID=WO.BRANCH_ID 
  INNER JOIN #LI LI ON T.BRANCH_ID = LI.BRANCH_ID -- Added by nilesh on 22122014 For Rotation Attendance Dashboard
  INNER JOIN #EO EO ON T.BRANCH_ID = EO.BRANCH_ID -- Added by nilesh on 22122014 For Rotation Attendance Dashboard 
   WHERE A.CMP_ID=@CMP_ID  
 END  
RETURN  




