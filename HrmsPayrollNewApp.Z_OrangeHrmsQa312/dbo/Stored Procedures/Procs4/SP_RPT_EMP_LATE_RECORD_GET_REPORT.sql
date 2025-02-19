
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_EMP_LATE_RECORD_GET_REPORT]  
  @Cmp_ID   NUMERIC  
 ,@From_Date  DATETIME  
 ,@To_Date   DATETIME   
 ,@Branch_ID  NUMERIC  
 ,@Cat_ID   NUMERIC   
 ,@Grd_ID   NUMERIC  
 ,@Type_ID   NUMERIC  
 ,@Dept_ID   NUMERIC  
 ,@Desig_ID   NUMERIC  
 ,@Emp_ID   NUMERIC  
 ,@constraint  VARCHAR(max)  
 ,@Report_Type VARCHAR(50)=''  
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	IF @Branch_ID = 0    
		SET @Branch_ID = NULL  
    
	IF @Cat_ID = 0    
		SET @Cat_ID = NULL  
  
	IF @Grd_ID = 0    
		SET @Grd_ID = NULL  
  
	IF @Type_ID = 0    
		SET @Type_ID = NULL  
  
	IF @Dept_ID = 0    
		SET @Dept_ID = NULL  
  
	IF @Desig_ID = 0    
		SET @Desig_ID = NULL  
  
	IF @Emp_ID = 0    
		SET @Emp_ID = NULL  
    
	--DECLARE #EMP_CONS Table  
	--(  
	--	Emp_ID NUMERIC  
	--)  
   
	-- IF @Constraint <> ''  
	--	  BEGIN  
	--		   INSERT INTO #EMP_CONS(Emp_ID)  
	--		   SELECT CAST(DATA  AS NUMERIC) FROM dbo.Split (@Constraint,'#')   
	--	  END  
	-- ELSE  
	--	  BEGIN  
	--		   INSERT INTO #EMP_CONS(Emp_ID)  
		  
	--		   SELECT	I.Emp_Id 
	--		   FROM		T0095_Increment I 
	--					INNER JOIN (SELECT	MAX(Increment_effective_Date) AS For_Date, Emp_ID 
	--								FROM	T0095_INCREMENT  
	--								WHERE	Increment_Effective_Date <= @To_Date AND Cmp_ID = @Cmp_ID  
	--								GROUP BY Emp_ID) Qry ON I.Emp_ID = Qry.Emp_ID AND I.Increment_effective_Date = Qry.For_Date   		         
	--		   WHERE	Cmp_ID = @Cmp_ID AND IsNull(Cat_ID,0) = IsNull(@Cat_ID ,IsNull(Cat_ID,0))  
	--					AND Branch_ID = IsNull(@Branch_ID ,Branch_ID)  
	--					AND Grd_ID = IsNull(@Grd_ID ,Grd_ID)  
	--					AND IsNull(Dept_ID,0) = IsNull(@Dept_ID ,IsNull(Dept_ID,0))  
	--					AND IsNull(Type_ID,0) = IsNull(@Type_ID ,IsNull(Type_ID,0))  
	--					AND IsNull(Desig_ID,0) = IsNull(@Desig_ID ,IsNull(Desig_ID,0))  
	--					AND I.Emp_ID = IsNull(@Emp_ID ,I.Emp_ID)   
	--					AND EXISTS(SELECT	1	
	--							   FROM		T0110_EMP_LEFT_JOIN_TRAN LJ
	--							   WHERE	LJ.Emp_ID=I.Emp_ID 
	--										AND ISNULL(LJ.Left_Date, @TO_DATE) BETWEEN @FROM_DATE AND @TO_DATE
	--										AND LJ.Join_Date <= @TO_DATE
	--							   )
	--			--		AND I.Emp_ID IN (SELECT Emp_Id 
	--			--						FROM	(SELECT Emp_ID, Cmp_ID, Join_Date, IsNull(Left_Date, @To_date) AS Left_Date 
	--			--								 FROM	T0110_EMP_LEFT_JOIN_TRAN) QRY  
	--			--						WHERE	Cmp_ID = @Cmp_ID 
	--			--								AND (
	--			--										(@From_Date >= Join_Date AND @From_Date <= Left_Date)   
	--			--									 OR (@To_Date >= Join_Date AND @To_Date <= left_date)  
	--			--									 OR Left_date is NULL AND @To_Date >= Join_Date)  
	--			--or @To_Date >= left_date  AND  @From_Date <= left_date )   	      
	--	  END  
	CREATE TABLE #EMP_CONS 
	(      
		EMP_ID NUMERIC ,     
		BRANCH_ID NUMERIC,
		INCREMENT_ID NUMERIC    
	)  

	EXEC SP_RPT_FILL_EMP_CONS  @CMP_ID=@CMP_ID,@FROM_DATE=@FROM_DATE,@TO_DATE=@TO_DATE,@BRANCH_ID=@BRANCH_ID,@Cat_ID=0,@GRD_ID=0,@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@EMP_ID=@EMP_ID,@CONSTRAINT=@CONSTRAINT
	
	CREATE NONCLUSTERED INDEX IX_EMPCONS ON #EMP_CONS (EMP_ID)



	DECLARE @RoundingValue NUMERIC(18,2)
	SET @RoundingValue = 0

	DECLARE @RoundingValue_Early NUMERIC(18,2)
	SET @RoundingValue_Early = 0


	CREATE TABLE #Emp_Late   
	(  
		Emp_ID   NUMERIC ,  
		Cmp_ID   NUMERIC ,  
		Increment_ID NUMERIC,  
		For_Date  DATETIME ,  
		In_Time   DATETIME ,  
		Shift_Time  DATETIME ,  
		Late_Sec  int default 0 ,  
		Late_Limit_Sec int default 0,  
		Late_Hour  VARCHAR(10), 
		Branch_Id NUMERIC,
		Late_Limit VARCHAR(100),
		Out_Time   DATETIME,			--Alpesh 23-Jul-2012
		Shift_END_Time  DATETIME,	--Alpesh 23-Jul-2012
		Shift_Max_St_Time DATETIME,	--Alpesh 23-Jul-2012
		Shift_max_Ed_Time DATETIME,  -- Rohit 23-apr-2013
		Early_Sec INT DEFAULT 0,     -- Rohit 23-apr-2013
		Early_Limit_Sec int default 0, -- Rohit 23-apr-2013
		Early_hour VARCHAR(10), -- Rohit 23-apr-2013
		Early_Limit VARCHAR(100) -- Rohit 23-apr-2013
	)  
  
	INSERT	INTO #Emp_Late  (Emp_ID,Cmp_ID,For_Date,Late_Limit_Sec,Increment_ID,Branch_Id,Late_Limit,Early_Limit_Sec,Early_Limit)  
	SELECT	E.Emp_ID,E.Cmp_ID,For_Date,dbo.F_Return_Sec(Emp_Late_Limit),EC.Increment_ID,EC.Branch_Id,Emp_Late_Limit,dbo.F_Return_Sec(Emp_Early_Limit),Emp_early_Limit
	FROM	T0150_EMP_INOUT_RECORD E WITH (NOLOCK)
			INNER JOIN #EMP_CONS EC ON E.Emp_ID =Ec.emp_ID 
			INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON EC.INCREMENT_ID=I.Increment_ID AND Emp_Late_MArk =1    
	WHERE	For_Date >=@From_Date AND For_Date <=@to_Date AND e.Cmp_Id =@Cmp_ID 
			AND E.Chk_By_Superior = 0 -- Changed by Ramiz ON 29/03/2016 , previously it was "E.Chk_By_Superior <> 1"
	GROUP BY E.Emp_ID ,e.Cmp_ID,e.For_date,Emp_Late_Limit,EC.Increment_ID,EC.Branch_Id,Emp_Early_Limit  
  

	UPDATE	#Emp_Late 
	SET		In_time  = Q.In_time,
			Out_Time = Case when Q4.Max_In_Date > Q2.Out_Time Then Q4.Max_In_Date ELSE  Q2.Out_Time END
	FROM	#Emp_Late  EL 
			INNER JOIN (SELECT	EIR.Emp_ID,for_Date,min(In_time )In_time 
						FROM	T0150_EMP_INOUT_RECORD EIR WITH (NOLOCK)
								INNER JOIN #EMP_CONS EC ON EIR.Emp_ID =ec.emp_ID 
						GROUP BY EIR.emp_Id,EIR.For_Date) Q ON EL.emp_ID = Q.Emp_ID AND EL.for_Date = Q.For_Date  
			INNER JOIN (SELECT	EIR.Emp_ID,for_Date,MAX(Out_Time)Out_Time 
						FROM	T0150_EMP_INOUT_RECORD EIR WITH (NOLOCK)
								INNER JOIN	#EMP_CONS EC ON EIR.Emp_ID =ec.emp_ID 
						GROUP BY EIR.emp_Id,EIR.For_Date) Q2 ON EL.emp_ID =Q2.Emp_ID AND EL.for_Date =Q2.For_Date  --Alpesh 23-Jul-2012 
			INNER JOIN (SELECT	EIR.Emp_Id, MAX(In_Time) Max_In_Date,For_Date 
						FROM	dbo.T0150_EMP_INOUT_RECORD EIR WITH (NOLOCK)
								INNER JOIN	#EMP_CONS EC ON EIR.Emp_ID =ec.emp_ID 
						GROUP BY EIR.emp_Id,EIR.For_Date) Q4 ON EL.Emp_Id = Q4.Emp_Id AND EL.For_Date = Q4.For_Date
			LEFT OUTER JOIN (SELECT	EIR.Emp_ID,Chk_By_Superior Chk_By_Sup,For_Date 
							 FROM	dbo.T0150_EMP_INOUT_RECORD EIR WITH (NOLOCK)
									INNER JOIN	#EMP_CONS EC ON EIR.Emp_ID =ec.emp_ID 
							 WHERE	Chk_By_Superior=1) Q3 ON EL.Emp_Id = Q3.Emp_Id AND EL.For_Date = Q3.For_Date
     
	DECLARE @For_Date DATETIME   
	DECLARE @Shift_St_Time  VARCHAR(10)  
	DECLARE @Shift_St_DATETIME DATETIME  
	DECLARE @In_Date   DATETIME  
	DECLARE @var_Shift_St_Date VARCHAR(20)  
	DECLARE @Emp_Late_Limit  VARCHAR(10)  
	DECLARE @Late_Limit_Sec  NUMERIC  
	--DECLARE @StrWeekoff_Date VARCHAR(1000)
	--DECLARE @StrHoliday_Date VARCHAR(1000)
	DECLARE @Is_Late_calc_On_HO_WO TINYINT
	DECLARE @Temp_Branch_ID NUMERIC
	DECLARE @Is_LateMark AS tinyint
	DECLARE @Shift_END_Time  VARCHAR(10)
	DECLARE @Shift_END_DATETIME DATETIME  
	DECLARE @Out_Date   DATETIME  
	DECLARE @var_Shift_END_Date VARCHAR(20) 
	DECLARE @Max_Late_Limit  VARCHAR(10)  
	DECLARE @Shift_Max_DATETIME DATETIME
	DECLARE @Is_EarlyMark AS TINYINT
	DECLARE @Emp_Early_Limit  VARCHAR(10)  
	DECLARE @Early_Limit_Sec  NUMERIC  
	DECLARE @Is_Early_calc_On_HO_WO TINYINT
	DECLARE @Max_Early_Limit  VARCHAR(10)  
	DECLARE @Shift_END_Max_DATETIME DATETIME
	DECLARE @Emp_LateMark AS TINYINT
	DECLARE @Emp_EarlyMark AS TINYINT
	SET @Is_LateMark = 1
	SET @Is_Late_calc_On_HO_WO = 0
	SET @Is_EarlyMark = 1
	SET @Is_Early_calc_On_HO_WO = 0
	SET @Emp_LateMark = 1
	SET @Emp_Early_Limit = 1

	/*************************************************************************
	Added by Nimesh: 17/Nov/2015 
	(To get holiday/weekoff data for all employees in seperate table)
	*************************************************************************/
	DECLARE @Required_Execution BIT;
	SET @Required_Execution = 0;
	IF OBJECT_ID('tempdb..#EMP_HOLIDAY') IS NULL
		BEGIN
			CREATE TABLE #EMP_HOLIDAY(EMP_ID NUMERIC, FOR_DATE DATETIME, IS_CANCEL BIT, Is_Half tinyint, Is_P_Comp tinyint, H_DAY numeric(4,1));
			CREATE UNIQUE CLUSTERED INDEX IX_EMP_HOLIDAY_EMPID_FORDATE ON #EMP_HOLIDAY(EMP_ID, FOR_DATE);
			SET @Required_Execution = 1;
		END
	IF OBJECT_ID('tempdb..#Emp_WeekOff') IS NULL
		BEGIN
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
			SET @Required_Execution = 1;
		END
	
	IF @Required_Execution = 1
		BEGIN			
			EXEC SP_GET_HW_ALL @CONSTRAINT=@CONSTRAINT,@CMP_ID=@Cmp_ID, @FROM_DATE=@FROM_DATE, @TO_DATE=@TO_DATE, @All_Weekoff = 0, @Exec_Mode=0		
		END 
	

   
	 DECLARE curLate CURSOR FAST_FORWARD FOR 
	 SELECT	Emp_ID,For_Date,In_Time,Late_Limit_Sec,Branch_Id,Out_Time,Early_Limit_Sec 
	 FROM	#Emp_Late 
	 ORDER BY Emp_ID,For_Date   --Rohit ON 23042013

	 OPEN curLate  
	 FETCH NEXT FROM curLate INTO @Emp_ID,@For_Date,@In_Date,@Late_Limit_Sec,@Temp_Branch_ID,@Out_Date,@Early_limit_Sec -- Rohit ON 23042013
	 While @@fetch_status = 0   
		BEGIN	   
	  
			--SET @StrWeekoff_Date = ''
			--SET @StrHoliday_Date = ''

			SELECT	@Is_Late_calc_On_HO_WO = Is_Late_Calc_On_HO_WO,@Is_LateMark = Is_Late_Mark, @RoundingValue = IsNull(Early_Hour_Upper_Rounding,0),
					@Max_Late_Limit=IsNull(Max_Late_Limit,'00:00'),@Is_Early_calc_On_HO_WO = Is_Early_Calc_On_HO_WO,
					@Max_Early_Limit=IsNull(Max_Early_Limit,'00:00'),@RoundingValue_Early = IsNull(Late_Hour_Upper_Rounding,0)   -- rohit 23-apr-2013
			FROM	dbo.T0040_GENERAL_SETTING  WITH (NOLOCK)
			WHERE	Branch_ID = @Temp_Branch_ID AND Cmp_ID = @Cmp_ID	--Alpesh 23-Jul-2012
				  	
			--Exec SP_EMP_WEEKOFF_DATE_GET @Emp_Id,@Cmp_ID,@From_Date,@To_Date,NULL,NULL,0,'',@StrWeekoff_Date output,0,0
			--EXEC SP_EMP_HOLIDAY_DATE_GET @Emp_Id,@Cmp_ID, @From_Date, @To_Date,NULL, NULL, 0, @StrHoliday_Date OUTPUT,0, 0, 0, @Temp_Branch_ID,@StrWeekoff_Date    

			/*Commented by Nimesh 20 May 2015    
			SELECT @Shift_St_Time = T0040_shift_MAster.Shift_St_Time,@Shift_END_Time = T0040_shift_MAster.Shift_END_Time	--Alpesh 23-Jul-2012  
			from T0100_emp_shift_Detail,T0040_shift_MAster WHERE T0100_emp_shift_Detail.Cmp_ID = @Cmp_ID  AND emp_id = @emp_id  
			AND for_date in (SELECT MAX(for_date) FROM T0100_emp_shift_Detail WHERE Cmp_ID = @Cmp_ID  AND for_date <= @For_Date  
			AND emp_id = @emp_id) AND T0100_emp_shift_Detail.shift_id = T0040_shift_MAster.shift_id AND T0100_emp_shift_Detail.Cmp_ID = T0040_shift_MAster.Cmp_ID   
			*/
			
			--Added by Nimesh 20 April, 2015
			--We are using fn_get_Shift_From_Monthly_Rotation scalar function which will return the exact shift id FROM 
			--the rotation IF it is assigned to any employee otherwise it will be taken FROM Employee Shift Details.
			DECLARE @Shift_ID NUMERIC(18,0);
			SELECT @Shift_ID = dbo.fn_get_Shift_From_Monthly_Rotation(@Cmp_ID, @Emp_ID, @For_Date);
			
			SELECT	@Shift_St_Time = SM.Shift_St_Time,@Shift_END_Time = SM.Shift_END_Time
			FROM	T0040_SHIFT_MASTER SM WITH (NOLOCK)
			WHERE	Shift_ID=@Shift_ID
			--END Nimesh
	  
			SET @var_Shift_St_Date = cast(@In_Date AS VARCHAR(11)) + ' '  + @Shift_St_Time
	     
	     	IF @Shift_St_Time > @Shift_END_Time
				BEGIN
					SET @var_Shift_END_Date = IsNull(cast(@Out_Date AS VARCHAR(11)),cast(@In_Date AS VARCHAR(11))) + ' '  + @Shift_END_Time	--Alpesh 23-Jul-2012  
				END
			ELSE
				BEGIN
					SET @var_Shift_END_Date = IsNull(cast(@In_Date AS VARCHAR(11)),cast(@Out_Date AS VARCHAR(11))) + ' '  + @Shift_END_Time	--Alpesh 23-Jul-2012  
				END      			  
			  	      
			SET @Shift_Max_DATETIME = DATEADD(s,dbo.F_Return_Sec(@Max_Late_Limit),@var_Shift_St_Date)  --Alpesh 23-Jul-2012   		  
			SET @Shift_END_Max_DATETIME = DATEADD(s,dbo.F_Return_Sec(@Max_Early_Limit)*(-1) ,@var_Shift_END_Date)  --rohit 23-apr-2013 
	  
	  
			SET @Shift_St_DATETIME = cast(@var_Shift_St_Date AS DATETIME)  
			SET @Shift_St_DATETIME = DATEADD(s,@Late_Limit_Sec,@Shift_St_DATETIME)  
	       
			SET @Shift_END_DATETIME = cast(@var_Shift_END_Date AS DATETIME) 
			SET @Shift_END_DATETIME = DATEADD(s,@Early_Limit_Sec*(-1),@Shift_END_DATETIME)  
	      
	     
			UPDATE	#Emp_Late  
			SET		Shift_Max_St_Time=@Shift_Max_DATETIME,
					shift_max_ed_time = @Shift_END_Max_DATETIME
			WHERE	Emp_ID=@Emp_ID AND For_Date =@For_Date 
			      
			SELECT	@Emp_LateMark=I.Emp_Late_mark, @Emp_EarlyMark = I.Emp_Early_mark 
			FROM	T0095_INCREMENT I WITH (NOLOCK)
					INNER JOIN #EMP_CONS EC ON I.Increment_ID=EC.INCREMENT_ID
			WHERE	I.emp_id=@Emp_ID
	            
			IF @Is_LateMark = 1
				BEGIN
					IF @Emp_LateMark = 1
						BEGIN
							IF @Is_Late_calc_On_HO_WO = 1
								BEGIN      
									UPDATE	#Emp_Late  
									SET		Shift_Time =@Shift_St_DATETIME
									WHERE	Emp_ID=@Emp_ID AND For_Date =@For_Date  
								END
							ELSE
								BEGIN		
									--IF charindex(cast(@For_Date AS VARCHAR(11)),@StrWeekoff_Date,0) <> 0 or charindex(cast(@For_Date AS VARCHAR(11)),@StrHoliday_Date,0) <> 0 
									IF EXISTS(SELECT 1 FROM #EMP_WEEKOFF WHERE For_Date=@For_Date AND Is_Cancel=0)
										OR EXISTS(SELECT 1 FROM #EMP_HOLIDAY WHERE For_Date=@For_Date AND Is_Cancel=0)
										BEGIN
											UPDATE	#Emp_Late  
											SET		In_Time =@Shift_St_DATETIME,Shift_Time =@Shift_St_DATETIME
											WHERE	Emp_ID=@Emp_ID AND For_Date =@For_Date  
										END
									ELSE
										BEGIN
											UPDATE	#Emp_Late  
											SET		Shift_Time =@Shift_St_DATETIME
											WHERE	Emp_ID=@Emp_ID AND For_Date =@For_Date  
										END
								END
						END
					ELSE
						BEGIN
							UPDATE	#Emp_Late  
							SET		In_Time =@Shift_St_DATETIME,Shift_Time =@Shift_St_DATETIME
							WHERE	Emp_ID=@Emp_ID AND For_Date =@For_Date  
						END	
						-- ROhit 23-apr-2013
					IF @Emp_EarlyMark = 1	
						BEGIN
							IF @Is_Early_calc_On_HO_WO = 1
								BEGIN      
									UPDATE	#Emp_Late  
									SET		Shift_END_Time=@Shift_END_Max_DATETIME  
									WHERE	Emp_ID=@Emp_ID AND For_Date =@For_Date  
								END
							ELSE
								BEGIN		
									--IF charindex(cast(@For_Date AS VARCHAR(11)),@StrWeekoff_Date,0) <> 0 or charindex(cast(@For_Date AS VARCHAR(11)),@StrHoliday_Date,0) <> 0 
									IF EXISTS(SELECT 1 FROM #EMP_WEEKOFF WHERE For_Date=@For_Date AND Is_Cancel=0)
										OR EXISTS(SELECT 1 FROM #EMP_HOLIDAY WHERE For_Date=@For_Date AND Is_Cancel=0)
										BEGIN
											UPDATE	#Emp_Late  
											SET		Out_Time = @Shift_END_DATETIME,
													Shift_END_Time=@Shift_END_DATETIME  --Alpesh 23-Jul-2012      
											WHERE	Emp_ID=@Emp_ID AND For_Date =@For_Date  
										 END
									ELSE
										BEGIN
											UPDATE	#Emp_Late  
											SET		Shift_END_Time=@Shift_END_DATETIME  
											WHERE	Emp_ID=@Emp_ID AND For_Date =@For_Date  
										END
								END
						END
					ELSE
						BEGIN
							UPDATE	#Emp_Late  
							SET		Shift_END_Time=@Shift_END_DATETIME ,out_time=@Shift_END_DATETIME      
							WHERE	Emp_ID=@Emp_ID AND For_Date =@For_Date 
						END							
				END
			ELSE
				BEGIN
					UPDATE	#Emp_Late  
					SET		In_Time = @Shift_St_DATETIME,Shift_Time = @Shift_St_DATETIME,
							Shift_END_Time=@Shift_END_DATETIME,Out_Time=@Shift_END_DATETIME      
					WHERE	Emp_ID=@Emp_ID AND For_Date =@For_Date  
				END		
		
			FETCH NEXT FROM curLate INTO @Emp_ID,@For_Date,@In_Date,@Late_Limit_Sec,@Temp_Branch_ID,@Out_Date,@Early_Limit_Sec   --Alpesh 23-Jul-2012
		END   

	CLOSE curLate  
	DEALLOCATE curLate  
  
  
  
	UPDATE	#Emp_Late  
	SET		Late_sec = DATEDIFF(s,Shift_Time,In_Time),
			Late_Hour = dbo.F_Return_Hours (DATEDIFF(s,Shift_Time,In_Time))
	WHERE	DATEDIFF(s,Shift_Time,In_Time) > 0  
  
	UPDATE	#Emp_Late  
	SET		Early_sec = DATEDIFF(s,out_time,Shift_END_Time),
			Early_Hour = dbo.F_Return_Hours (DATEDIFF(s,out_time,Shift_END_Time))
	WHERE	DATEDIFF(s,out_time,Shift_END_Time) > 0  
  
	UPDATE	#Emp_Late  
	SET		Late_sec = 0,Late_Hour = 0
	WHERE	DATEDIFF(s,Shift_Time,In_Time) > 0 AND (In_Time >= Shift_Time AND In_Time <= Shift_Max_St_Time 
			AND DATEDIFF(s,DATEADD(s,-1*Late_Limit_Sec,Shift_Time),Shift_END_Time)<=DATEDIFF(s,In_Time,Out_Time))
 
	UPDATE	#Emp_Late  
	SET		Early_sec = 0,Early_Hour = 0
	WHERE	DATEDIFF(s,Out_time,Shift_END_Time) > 0 AND (Out_Time >= Shift_END_Time AND Out_Time <= Shift_Max_ed_Time 
			AND DATEDIFF(s,DATEADD(s,Early_Limit_Sec,Shift_END_Time),shift_time)<=DATEDIFF(s,In_Time,Out_Time))
    
	UPDATE	EL
	SET		Late_sec = 0,  
			Late_Hour = 0
	FROM	#Emp_Late EL
			INNER JOIN (SELECT	LA.Leave_Approval_ID,LA.Emp_ID,lad.To_Date 
						FROM	T0120_LEAVE_APPROVAL LA WITH (NOLOCK)
								INNER JOIN T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) ON LA.Leave_Approval_ID = LAD.Leave_Approval_ID
						WHERE	Leave_Assign_As = 'First Half' AND Approval_Status = 'A') Qry ON Qry.Emp_ID = EL.Emp_ID AND Qry.To_Date = EL.For_Date
    
	UPDATE	EL
	SET		Early_sec = 0,
			Early_Hour = 0
	FROM	#Emp_Late EL INNER JOIN (SELECT LA.Leave_Approval_ID,LA.Emp_ID,lad.To_Date FROM T0120_LEAVE_APPROVAL LA WITH (NOLOCK)
				INNER JOIN T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) ON LA.Leave_Approval_ID = LAD.Leave_Approval_ID
				WHERE Leave_Assign_As = 'Second Half' AND Approval_Status = 'A') Qry 
		on Qry.Emp_ID = EL.Emp_ID AND Qry.To_Date = EL.For_Date

    CREATE TABLE #Emp_Late_New
	(  
		Emp_ID		NUMERIC,  
		Cmp_ID		NUMERIC,  
		From_Date	DATETIME,
		LAte_Sec	INT DEFAULT 0, 
		Early_Sec	INT DEFAULT 0,
		LAteCount	INT DEFAULT 0,
		EarlyCount	INT DEFAULT 0,
	)  
  
	IF @Report_Type ='Summary'  
		BEGIN  				   
			SELECT	@From_Date AS From_Date,@To_Date AS to_Date,SUM(Late_Sec) Total_Late_sec, EL.Emp_ID,
					dbo.F_Return_Hours (SUM(Late_Sec)) total_Late_Hours,  
					EM.Emp_full_name,EM.emp_code,EM.alpha_Emp_code,EM.Emp_First_Name,
					BM.branch_name,BM.comp_name,BM.branch_address,CM.cmp_name,
					CM.cmp_address 
			FROM	#Emp_Late EL   
					INNER JOIN T0080_EMP_MASTER em WITH (NOLOCK) ON  EL.Emp_ID = EM.Emp_ID   
					INNER JOIN T0030_BRANCH_MASTER bm WITH (NOLOCK) ON EM.Branch_ID=BM.Branch_ID  
					INNER JOIN t0010_company_master cm WITH (NOLOCK) ON EM.Cmp_ID = CM.Cmp_Id   
			WHERE	Late_Sec >0  
			GROUP BY EL.emp_ID,EM.Emp_full_name,EM.Emp_code,EM.alpha_Emp_code,EM.Emp_First_Name,BM.Branch_Name,BM.branch_address,CM.cmp_name,CM.cmp_address,BM.Comp_Name  		   
			ORDER BY RIGHT(REPLICATE(N' ', 500) + EM.Alpha_Emp_Code, 500)
		END  
	ELSE IF @Report_Type='LateSecond'
		BEGIN	
			--select * from #Emp_Late
			INSERT	INTO #Emp_Late_New
			SELECT	EL.Emp_ID,EM.cmp_id,EL.For_Date,SUM(Late_Sec),SUM(Early_Sec),0,0
			FROM	#Emp_Late EL   
					LEFT JOIN T0080_EMP_MASTER em WITH (NOLOCK) ON  EL.emp_id = EM.emp_id   
					LEFT JOIN T0030_BRANCH_MASTER bm WITH (NOLOCK) ON EM.branch_id=BM.branch_id  
					LEFT JOIN t0010_company_master cm WITH (NOLOCK) ON EM.cmp_id = CM.cmp_id   
			WHERE	(Late_Sec > 0 or Early_Sec > 0) --AND EL.Emp_ID=@Emp_ID    commented by jimit 18112016
			GROUP BY EL.Emp_ID,EM.cmp_id,EL.For_Date,Late_sec, EM.alpha_Emp_code 
			   
			UPDATE	#Emp_Late_New 
			SET		LAteCount = (SELECT COUNT(Late_Sec) FROM #Emp_Late_New WHERE LAte_Sec > 0),
					EarlyCount = (SELECT COUNT(Early_Sec) FROM #Emp_Late_New WHERE Early_Sec > 0)
			   
			SELECT	* FROM #Emp_Late_New
			   
		END	
	ELSE  
	   BEGIN  
			SELECT	EL.Emp_ID,EL.Cmp_ID,EL.Increment_ID,CONVERT(VARCHAR(10),EL.For_Date ,103) AS For_Date,
					EL.In_Time,DATEADD(S,EL.Late_Limit_Sec*-1 ,EL.SHIFT_TIME) AS Shift_Time,EL.Late_Sec,  
					EL.Late_Limit_Sec,EL.Late_Hour,EL.Branch_Id,EL.Late_Limit,EL.Out_Time,@From_Date AS From_date,@To_Date AS To_date,Emp_full_name,
					Emp_code,Alpha_Emp_Code,Emp_First_Name,Branch_Name,Comp_Name,
					Branch_Address,Cmp_Name,Cmp_Address,dbo.F_Return_Hours(IsNull(EL.Late_Limit_Sec,0)) AS LAte_Limit_Hour , 
					CASE WHEN dbo.F_Return_Hours(dbo.Pro_Rounding_Sec_HH_MM(EL.Late_Sec,@RoundingValue))='00:00' THEN '-' ELSE dbo.F_Return_Hours(dbo.Pro_Rounding_Sec_HH_MM(EL.Late_Sec,@RoundingValue)) END AS LAte_Hour_Rounding,
					dbo.F_Return_HHMM (DATEADD(s,EL.Late_Limit_Sec*-1 ,EL.SHIFT_TIME))  AS SHIFTTIME,
					dbo.F_Return_HHMM (EL.IN_TIME) AS INTIME,
					CONVERT(VARCHAR(10),for_date,103) AS For_Date_A,DATEADD(s,EL.Early_Limit_Sec ,EL.SHIFT_END_time) AS Shift_END_Time,
					EL.Early_Sec,EL.Early_Limit_Sec,EL.Early_Hour,EL.Early_Limit,
					dbo.F_Return_Hours(IsNull(EL.Early_Limit_Sec,0)) AS Early_Limit_Hour,
					CASE WHEN dbo.F_Return_Hours(dbo.Pro_Rounding_Sec_HH_MM(EL.Early_Sec ,@RoundingValue_Early))='00:00' THEN '-' ELSE dbo.F_Return_Hours(dbo.Pro_Rounding_Sec_HH_MM(EL.Early_Sec ,@RoundingValue_Early)) END AS Early_Hour_Rounding,
					dbo.F_Return_HHMM (EL.out_TIME) AS OutTIME,EL.For_Date AS Ord_For_Date		    
			FROM	#Emp_Late EL 
					INNER JOIN T0095_Increment i WITH (NOLOCK) ON EL.increment_ID=i.Increment_ID  
					INNER JOIN T0080_EMP_MASTER em WITH (NOLOCK) ON  EL.emp_id = EM.emp_id  
					INNER JOIN T0030_BRANCH_MASTER bm WITH (NOLOCK) ON EM.branch_id=BM.branch_id  
					INNER JOIN t0010_company_master cm WITH (NOLOCK) ON EM.cmp_id = CM.cmp_id    
			WHERE	Late_Sec > 0  OR Early_Sec > 0
			ORDER BY RIGHT(REPLICATE(N' ', 500) + EM.Alpha_Emp_Code, 500),Ord_For_Date  
	   END  
  
 RETURN  




