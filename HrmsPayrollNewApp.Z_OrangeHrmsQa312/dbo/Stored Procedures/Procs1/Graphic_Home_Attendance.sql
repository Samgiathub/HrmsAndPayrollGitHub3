
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Graphic_Home_Attendance]
	@CMP_ID NUMERIC,  
	@Branch_ID NUMERIC,  
	@Todate DATETIME,  
	@Type char(1)     
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	IF @Branch_ID =0
		SET @Branch_ID = NULL
 
	DECLARE @PRESENT TABLE  
	(  
		EMP_ID   NUMERIC,  
		EMP_CODE  VARCHAR(100),  
		EMP_FULL_NAME VARCHAR(100),  
		IN_TIME   DATETIME,  
		STATUS   CHAR(2),
		type     VARCHAR(50),
		Type_Name VARCHAR(100)  
	)  

	DECLARE @P TABLE  
	(  
		COUNT NUMERIC(18,0),  
		BRANCH_ID NUMERIC ,  
		CMP_ID NUMERIC   
	)  
	DECLARE @A TABLE  
	(  
		COUNT NUMERIC(18,0) ,  
		BRANCH_ID NUMERIC ,  
		CMP_ID NUMERIC   
	)  
	DECLARE @L TABLE  
	(  
		COUNT NUMERIC(18,0) ,  
		BRANCH_ID NUMERIC ,  
		CMP_ID NUMERIC   
	)  
	DECLARE @OD TABLE  
	(  
		COUNT NUMERIC(18,0) ,  
		BRANCH_ID NUMERIC ,  
		CMP_ID NUMERIC   
	)  
	DECLARE @T TABLE  
	(  
		COUNT NUMERIC(18,0) ,  
		BRANCH_ID NUMERIC ,  
		CMP_ID NUMERIC   
	)  
	DECLARE @WO TABLE  
	(  
		COUNT NUMERIC(18,0) ,  
		BRANCH_ID NUMERIC ,  
		CMP_ID NUMERIC   
	)  
	
	CREATE TABLE #Emp_Cons	-- Ankit 05092014 for Same Date Increment
	(      
		Emp_ID NUMERIC ,     
		Branch_ID NUMERIC,
		Increment_ID NUMERIC    
	)   

	DECLARE @From_Date DATETIME
	DECLARE @To_Date DATETIME

	SET @From_Date = DATEADD(D, DAY(GETDATE()) * -1, GETDATE()) + 1
	SET @From_Date = CONVERT(DATETIME, CONVERT(CHAR(10), @From_Date, 103), 103);
	SET @To_Date = DATEADD(M, 1, @From_Date)-1;
	 
	--EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID=@Cmp_ID,@From_Date=@From_Date,@To_Date=@To_Date,@Branch_ID=@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,@Sal_Type ,@Salary_Cycle_id ,@Segment_Id ,@Vertical_Id ,@SubVertical_Id ,@SubBranch_Id 
	EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID=@Cmp_ID,@From_Date=@From_Date,@To_Date=@To_Date,@Branch_ID=@Branch_ID,@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Emp_ID=0,@Constraint=''
	
	DECLARE @CONSTRAINT VARCHAR(MAX)
	SELECT	@CONSTRAINT = COALESCE(@CONSTRAINT + '#','') + CAST(EMP_ID AS VARCHAR(10))
	FROM	#Emp_Cons EC 
  
  
	INSERT	INTO @PRESENT (EMP_ID,EMP_CODE,EMP_FULL_NAME,IN_TIME,STATUS,type,Type_Name)   
	SELECT	EIR.Emp_ID,cast(EM.EMP_CODE  as VARCHAR(10)) AS EMP_CODE, em.EMP_FULL_NAME  as Emp_Full_Name,eir.in_time,'P',
			'<font color="Darkblue">' + 'P' + '</font>',('<font color="green">' + Type_name + '</font>') as  Type_name 
	FROM	T0150_EMP_INOUT_RECORD EIR WITH (NOLOCK)   
			INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EIR.Emp_ID=EM.Emp_ID 		
			INNER JOIN #Emp_Cons EC ON EM.Emp_ID=EC.Emp_ID
			--INNER JOIN T0095_INCREMENT AS I ON EM.INCREMENT_ID=I.INCREMENT_ID 
			LEFT OUTER JOIN T0040_TYPE_MASTER TM WITH (NOLOCK) ON EM.Type_ID=TM.Type_ID
	where	MONTH(EIR.In_Time) = MONTH(GETDATE()) AND YEAR(EIR.In_Time) = YEAR(GETDATE()) 
			AND DAY(EIR.In_Time) = DAY(GETDATE()) 
  
  
  
	INSERT	INTO @PRESENT (EMP_ID,EMP_CODE,EMP_FULL_NAME,STATUS,type,Type_Name)  
	SELECT	LA.Emp_ID, CAST(EM.Emp_code  AS VARCHAR(10)) AS Emp_code,EM.Emp_Full_Name,'L','<font color="blue">' + 'L' + '</font>' ,(Type_name) AS [Type_Name]  
	FROM	T0120_LEAVE_APPROVAL AS LA WITH (NOLOCK)
			INNER JOIN T0080_EMP_MASTER AS EM WITH (NOLOCK) ON LA.Emp_ID=EM.Emp_ID 
			INNER JOIN #Emp_Cons AS EC ON EM.Emp_ID = EC.Emp_ID
			LEFT OUTER JOIN T0130_LEAVE_APPROVAL_DETAIL AS LAD WITH (NOLOCK) ON LA.leave_approval_ID=LAD.Leave_Approval_ID 
			INNER JOIN T0040_LEAVE_MASTER TLM WITH (NOLOCK) ON LAD.Leave_ID=TLM.Leave_ID 
			LEFT OUTER JOIN T0040_TYPE_MASTER TM WITH (NOLOCK) ON EM.Type_ID=TM.Type_ID 
			LEFT OUTER JOIN T0135_LEAVE_CANCELATION AS LC WITH (NOLOCK) ON LAD.Leave_Approval_ID = LC.Leave_Approval_ID 
	WHERE	LAD.From_Date <= @Todate AND LAD.To_Date >= @Todate AND LA.Approval_Status='A' 
			AND Leave_Type <> 'Company Purpose' AND isnull(Lv_can_Status,0) = 0
  
  
	INSERT	INTO @PRESENT (EMP_ID,EMP_CODE,EMP_FULL_NAME,STATUS,type,Type_Name)  
	SELECT	la.Emp_ID, cast(EM.EMP_CODE  as VARCHAR(10))   as EMP_CODE,( em.EMP_FULL_NAME ) as Emp_Full_Name,'OD','<font color="orange">' + 'OD' + '</font>',(Type_name ) as  Type_name 
	FROM	T0120_LEAVE_APPROVAL AS LA WITH (NOLOCK)
			INNER JOIN T0080_EMP_MASTER AS EM WITH (NOLOCK) ON LA.Emp_ID=EM.Emp_ID 
			INNER JOIN #Emp_Cons EC ON EM.Emp_ID=EC.Emp_ID
			LEFT OUTER JOIN T0130_LEAVE_APPROVAL_DETAIL AS LAD WITH (NOLOCK) ON LA.Leave_Approval_ID=LAD.Leave_Approval_ID 
			INNER JOIN T0040_LEAVE_MASTER TLM WITH (NOLOCK) ON LAD.Leave_ID=TLM.Leave_ID 
			LEFT OUTER JOIN T0040_TYPE_MASTER TM WITH (NOLOCK) ON EM.Type_ID=TM.Type_ID
	WHERE   LAD.From_Date <= @Todate AND LAD.To_Date >= @Todate 
			AND LA.Approval_Status='A' And Leave_TYpe = 'Company Purpose'  
  
  
	INSERT	INTO @PRESENT (EMP_ID,EMP_CODE,EMP_FULL_NAME,STATUS,type,Type_Name)  
	SELECT	EM.Emp_ID,CAST(EM.EMP_CODE  AS VARCHAR(10)) AS EMP_CODE,EM.Emp_Full_Name,'A','<font color="Red">' + 'A' + '</font>',(Type_name) as  Type_name  
	FROM	T0080_EMP_MASTER EM WITH (NOLOCK)
			INNER JOIN #Emp_Cons EC ON EM.Emp_ID=EC.Emp_ID
			INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON EC.Increment_ID=I.Increment_ID
			LEFT OUTER JOIN T0040_TYPE_MASTER TM WITH (NOLOCK) on I.Type_ID=TM.Type_ID
	WHERE	NOT EXISTS (SELECT 1 FROM @present T WHERE T.EMP_ID=EM.Emp_ID) 			
  
  

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
		
	EXEC SP_GET_HW_ALL @CONSTRAINT=@CONSTRAINT,@CMP_ID=@Cmp_ID, @FROM_DATE=@FROM_DATE, @TO_DATE=@TO_DATE, @All_Weekoff = 0, @Exec_Mode=1		

	UPDATE	P
	SET		STATUS='WO',
			type='<font color="Green">' + 'WO' + '</font>'
	FROM	@PRESENT P
			INNER JOIN #EMP_WEEKOFF W ON P.EMP_ID=W.Emp_ID
	WHERE	STATUS = 'A' AND W.For_Date=CONVERT(DATETIME, CONVERT(CHAR(10), GETDATE(), 103), 103)


	---- Alpesh 26-May-2012 ---- to show if week off is on that perticular date instead of absent
	--DECLARE @Emp_ID				NUMERIC
	--DECLARE @Is_Cancel_Weekoff  NUMERIC(1,0)
	--DECLARE @Left_Date			DATETIME  
	--DECLARE @join_dt   			DATETIME  
	--DECLARE @StrHoliday_Date	VARCHAR(MAX)    
	--DECLARE @StrWeekoff_Date	VARCHAR(MAX)
	--DECLARE @Cancel_Weekoff		NUMERIC(18, 0)
	--DECLARE @WO_Days			NUMERIC
  
  
	--SET @Is_Cancel_Weekoff = 0 
	--SET @StrHoliday_Date = ''    
	--SET @StrWeekoff_Date = ''  
  
	--IF @Branch_ID is null
	--	BEGIN 
	--		SELECT	TOP 1 @Is_Cancel_Weekoff = Is_Cancel_Weekoff 
	--		FROM	T0040_GENERAL_SETTING 
	--		WHERE	Cmp_ID = @cmp_ID    
	--				AND For_Date = ( select MAX(For_Date) from T0040_GENERAL_SETTING where For_Date <= GETDATE() and Cmp_ID = @Cmp_ID)    
	--	END
	--Else
	--	Begin
	--		select @Is_Cancel_Weekoff = Is_Cancel_Weekoff from T0040_GENERAL_SETTING where cmp_ID = @cmp_ID and Branch_ID = @Branch_ID    
	--		and For_Date = ( select MAX(For_Date) from T0040_GENERAL_SETTING where For_Date <= GETDATE() and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)    
	--	End

  
--  DECLARE cur cursor for Select EMP_ID from @PRESENT
--  Open cur
--  Fetch Next From cur into @Emp_ID
  
--  While @@FETCH_STATUS = 0
--	Begin
--		Select @join_dt=Date_Of_Join,@Left_Date=Emp_Left_Date from T0080_EMP_MASTER where Cmp_ID=@CMP_ID and Emp_ID=@Emp_ID
				
		
--		Exec SP_EMP_WEEKOFF_DATE_GET @Emp_ID,@Cmp_ID,@Todate,@Todate,@join_dt,@left_Date,@Is_Cancel_weekoff,@StrHoliday_Date,@StrWeekoff_Date output,@WO_Days output ,@Cancel_Weekoff output    	
		
--		If charindex(CONVERT(VARCHAR(11),GETDATE(),109),@StrWeekoff_Date,0) > 0
--			Begin
--				Update @PRESENT Set
--					 STATUS='WO'
--					,type='<font color="Green">' + 'WO' + '</font>'
--				Where EMP_ID = @Emp_ID and STATUS = 'A'
--			End
		
--		SET @StrHoliday_Date = ''    
--		SET @StrWeekoff_Date = ''  
  
--		Fetch Next From cur into @Emp_ID
--	End
  
--  Close cur
--  Deallocate cur
------ End ----


	IF @Type = 'X'  
		SELECT	DISTINCT(P.EMP_ID),P.EMP_CODE,P.EMP_FULL_NAME  as EMP_FULL_NAME,P.STATUS,P.type, P.Type_Name 
		FROM	@PRESENT AS P 
				INNER JOIN T0080_EMP_MASTER AS EM WITH (NOLOCK) ON P.EMP_ID = EM.Emp_ID   
		WHERE	EM.Emp_Left='N'   
		ORDER BY STATUS DESC  
	ELSE IF @Type = 'Y'  
		BEGIN  
			INSERT	INTO @P  
			SELECT	COUNT(DISTINCT(P.EMP_ID)),0,0 
			FROM	@PRESENT as p 
					INNER JOIN T0080_EMP_MASTER AS EM WITH (NOLOCK) ON P.Emp_ID = EM.Emp_ID 
			WHERE	EM.Emp_Left='N' AND STATUS='P'
		  
			UPDATE @P SET BRANCH_ID=@Branch_ID,CMP_ID=@CMP_ID  
    
			INSERT	INTO @A  
			SELECT	COUNT(DISTINCT(P.EMP_ID)),0,0 
			FROM	@PRESENT AS P 
					INNER JOIN T0080_EMP_MASTER AS EM WITH (NOLOCK) ON P.Emp_ID = EM.Emp_ID 
			WHERE	EM.Emp_Left='N' AND STATUS='A'--  order by  desc  
		  
			UPDATE @A SET BRANCH_ID=@Branch_ID,CMP_ID=@CMP_ID  
    
			INSERT	INTO @L  
			SELECT	COUNT(DISTINCT(P.EMP_ID)),0,0 
			FROM	@PRESENT AS P 
					INNER JOIN T0080_EMP_MASTER AS EM WITH (NOLOCK) ON P.Emp_ID = EM.Emp_ID 
			WHERE	EM.Emp_Left='N' AND STATUS='L'--  order by  desc  
			
			UPDATE @L SET BRANCH_ID=@Branch_ID,CMP_ID=@CMP_ID  
    
			INSERT	INTO @OD  
			SELECT	COUNT(DISTINCT(P.EMP_ID)),0,0 
			FROM	@PRESENT AS P INNER JOIN T0080_EMP_MASTER AS EM WITH (NOLOCK) ON P.Emp_ID = EM.Emp_ID 
			WHERE	EM.Emp_Left='N' AND STATUS='OD'
			
			UPDATE @OD SET BRANCH_ID=@Branch_ID,CMP_ID=@CMP_ID  
   
			INSERT	INTO @WO  
			SELECT	COUNT(DISTINCT(P.EMP_ID)),0,0 
			FROM	@PRESENT AS P 
					INNER JOIN T0080_EMP_MASTER AS EM WITH (NOLOCK) ON P.Emp_ID = EM.Emp_ID 
			WHERE	EM.Emp_Left='N' AND STATUS='WO'--  order by  desc  
			
			UPDATE @WO SET BRANCH_ID=@Branch_ID,CMP_ID=@CMP_ID    
    
			INSERT	INTO @T  
			SELECT	COUNT(DISTINCT(P.EMP_ID)),0,0 
			FROM	@PRESENT AS P 
					INNER JOIN T0080_EMP_MASTER AS EM WITH (NOLOCK) ON P.Emp_ID = EM.Emp_ID 
			WHERE	EM.Emp_Left='N'  -- order by status desc  
			
			UPDATE	@T SET BRANCH_ID=@Branch_ID,CMP_ID=@CMP_ID   
		
			IF @Branch_ID >0 
				BEGIN  
					SELECT  P.COUNT AS PRESENT ,A.COUNT AS ABSENT,L.COUNT AS LEAVE ,OD.COUNT AS OD, WO.COUNT AS WO,T.COUNT AS TOTAL  
					FROM	@P P 
							INNER JOIN @L L ON P.BRANCH_ID=L.BRANCH_ID 
							INNER JOIN @A A ON L.BRANCH_ID = A.BRANCH_ID 
							INNER JOIN @T T ON A.BRANCH_ID=T.BRANCH_ID   
							INNER JOIN @OD OD ON T.BRANCH_ID=OD.BRANCH_ID  
							INNER JOIN @WO WO ON T.BRANCH_ID=WO.BRANCH_ID  
					WHERE	A.CMP_ID=@CMP_ID  
				END
			ELSE
				BEGIN
					SELECT  P.COUNT AS PRESENT ,A.COUNT AS ABSENT,L.COUNT AS LEAVE ,OD.COUNT AS OD, WO.COUNT AS WO,T.COUNT AS TOTAL  
					FROM	@P P 
							INNER JOIN @L L ON P.Cmp_ID=L.Cmp_ID 
							INNER JOIN @A A ON L.Cmp_ID = A.Cmp_ID 
							INNER JOIN @T T ON A.Cmp_ID=T.Cmp_ID   
							INNER JOIN @OD OD ON T.Cmp_ID=OD.Cmp_ID  
							INNER JOIN @WO WO ON T.Cmp_ID=WO.Cmp_ID  
					WHERE	A.CMP_ID=@CMP_ID 
				END 
		END  
RETURN


