
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_Form_25]
	 @Cmp_ID		NUMERIC
	,@From_Date		DATETIME
	,@To_Date		DATETIME 
	,@Branch_ID		NUMERIC = 0
	,@Cat_ID		NUMERIC = 0
	,@Grd_ID		NUMERIC = 0
	,@Type_ID		NUMERIC = 0
	,@Dept_ID		NUMERIC = 0
	,@Desig_ID		NUMERIC = 0
	,@Emp_ID		NUMERIC = 0
	,@Constraint	VARCHAR(MAX) = ''
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	IF @Branch_ID = 0
		SET @Branch_ID = NULL
	IF @Cat_ID = 0
		SET @Cat_ID = NULL
	IF @Type_ID = 0
		SET @Type_ID = NULL
	IF @Dept_ID = 0
		SET @Dept_ID = NULL
	IF @Grd_ID = 0
		SET @Grd_ID = NULL
	IF @Emp_ID = 0
		SET @Emp_ID = NULL
	IF @Desig_ID = 0
		SET @Desig_ID = NULL
		
	
	
	DECLARE @Emp_Cons TABLE
	(
		Emp_ID	NUMERIC,
		Branch_ID numeric(18,0)
	)
	
	IF @Constraint <> ''
		BEGIN
		
			INSERT INTO @Emp_Cons (Emp_Id)
			SELECT  CAST(data  AS NUMERIC) FROM dbo.Split (@Constraint,'#') 

			UPDATE	@Emp_Cons
			SET		BRANCH_ID = I.BRANCH_ID
			FROM	@Emp_Cons E 
					INNER JOIN (
									SELECT	EMP_ID, INCREMENT_ID, BRANCH_ID
									FROM	T0095_INCREMENT I1 WITH (NOLOCK)
									WHERE	I1.Increment_ID = (
																SELECT	MAX(INCREMENT_ID)
																FROM	T0095_INCREMENT I2 WITH (NOLOCK)
																WHERE	I2.Increment_Effective_Date = (
																										SELECT	MAX(INCREMENT_EFFECTIVE_DATE)
																										FROM	T0095_INCREMENT I3 WITH (NOLOCK)
																										WHERE	I3.Emp_ID=I2.Emp_ID 
																												AND Increment_Effective_Date <= @To_Date
																										)
																		AND I2.Emp_ID=I1.Emp_ID
															)
								) I ON E.EMP_ID=I.Emp_ID
								
								--select * from @Emp_Cons


		end	
	else 
		BEGIN
			INSERT INTO @Emp_Cons

			SELECT	I.Emp_Id,I.Branch_ID
			FROM	T0095_Increment I WITH (NOLOCK)
					inner join (
								 SELECT max(Increment_effective_Date) AS For_Date , Emp_ID 
								 FROM	T0095_Increment WITH (NOLOCK)
								 WHERE	Increment_Effective_date <= @To_Date
										and Cmp_ID = @Cmp_ID
								 GROUP BY emp_ID
								) Qry ON I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date
			WHERE	Cmp_ID = @Cmp_ID 
					and IsNULL(Cat_ID,0) = IsNULL(@Cat_ID ,IsNULL(Cat_ID,0))
					and Branch_ID = isNULL(@Branch_ID ,Branch_ID)
					and Grd_ID = isNULL(@Grd_ID ,Grd_ID)
					and isNULL(Dept_ID,0) = isNULL(@Dept_ID ,isNULL(Dept_ID,0))
					and IsNULL(Type_ID,0) = isNULL(@Type_ID ,IsNULL(Type_ID,0))
					and IsNULL(Desig_ID,0) = isNULL(@Desig_ID ,IsNULL(Desig_ID,0))
					and I.Emp_ID = isNULL(@Emp_ID ,I.Emp_ID) 
					and I.Emp_ID in 
					( SELECT Emp_Id from
					(SELECT emp_id, cmp_ID, join_Date, isNULL(left_Date, @To_date) AS left_Date FROM T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry
					WHERE cmp_ID = @Cmp_ID   AND  
					(( @From_Date  >= join_Date  AND  @From_Date <= left_date) 
					OR ( @To_Date  >= join_Date  AND @To_Date <= left_date)
					OR Left_date is NULL AND @To_Date >= Join_Date)
					OR @To_Date >= left_date AND  @From_Date <= left_date) 			
		End
		
	DECLARE @Weekoff AS VARCHAR(200)		
	DECLARE @Int AS tinyint
	DECLARE @Count AS tinyint
	DECLARE @WeekName AS VARCHAR(20)
	DECLARE @WeekDay AS NUMERIC
	DECLARE @Total_WeekDay AS NUMERIC
	DECLARE @Total_Working_Day AS NUMERIC
	DECLARE @Total_Holiday AS NUMERIC
	
	SELECT @Weekoff = Default_Holiday FROM T0010_COMPANY_MASTER WITH (NOLOCK) WHERE Cmp_Id = @Cmp_ID
	SELECT @Count=IsNULL(COUNT(*),0) FROM dbo.Split (@Weekoff,'#')
	
	SET @Int = 1
	SET @Total_WeekDay = 0
	SET @Total_Holiday = 0
	
	While @Int <= @Count
		BEGIN
			SELECT @WeekName = DATA FROM dbo.Split (@Weekoff,'#') WHERE Id = @Int
			SELECT @WeekDay = [dbo].[F_Get_No_Of_Days_In_Period] (@From_Date,@To_Date,@WeekName)
			
			SET @Total_WeekDay = @Total_WeekDay + @WeekDay
			SET @Int = @Int	+ 1
			--print @Total_WeekDay  
		End
	
	SELECT @Total_Working_Day = [dbo].[F_Get_No_Of_Days_In_Period] (@From_Date,@To_Date,'')
	print  @Total_Working_Day
	--SELECT @Total_Holiday = SUM(No_of_Holiday) FROM T0040_HOLIDAY_MASTER WHERE cmp_Id = @Cmp_ID

	---For Working day of Employees
	--DECLARE @Is_Cancel_Weekoff  NUMERIC(1,0) 
    --DECLARE @Weekoff_Days   NUMERIC(12,1)  
	--DECLARE @Cancel_Weekoff   NUMERIC(12,1)  
	--DECLARE @Week_oF_Branch NUMERIC(18,0)
	--DECLARE @StrWeekoff_Date VARCHAR(Max)
	--DECLARE @Emp_Id_Cur NUMERIC
	--DECLARE @Emp_Weekoff_Day_Men NUMERIC(18,1)
	
	--DECLARE @Emp_Weekoff_Day_Women NUMERIC(18,1)
	--DECLARE @Emp_Working_Day_Men NUMERIC(18,1)
	--DECLARE @Emp_Working_Day_Women NUMERIC(18,1)
	
	--SET @Emp_Weekoff_Day_Men = 0
	--SET @Total_Emp_Weekoff_Day_Men = 0
	--SET @Emp_Working_Day_Men = 0
	--SET @Total_Emp_Working_Day_Men = 0
	--SET @Emp_Working_Day_Women = 0
	--SET @Total_Emp_Working_Day_Women = 0
	--SET @Emp_Weekoff_Day_Women = 0
	--SET @Total_Emp_Weekoff_Day_Women = 0

	
	--SELECT @Week_oF_Branch=Branch_ID  FROM T0095_INCREMENT 
	--WHERE Increment_id in (SELECT Max(Increment_id) FROM T0095_INCREMENT WHERE Emp_ID=@Emp_Id_Cur)
	
	--SELECT @Is_Cancel_weekoff = Is_Cancel_weekoff
	--From T0040_GENERAL_SETTING WHERE Cmp_ID = @Cmp_ID AND Branch_ID = @Week_of_Branch
	--And For_Date = 
	--(SELECT max(For_Date) FROM T0040_GENERAL_SETTING WHERE For_Date <= @To_Date AND Branch_ID = @Week_oF_Branch AND Cmp_ID = @Cmp_ID)
		
	--DECLARE curweekoff cursor for                    
	--	SELECT EC.Emp_Id FROM @Emp_Cons EC Inner Join T0080_Emp_Master EM ON EC.Emp_Id = EM.Emp_Id WHERE Gender ='M'
	--open curweekoff                      
	--fetch next FROM curweekoff into @Emp_Id_Cur
	--while @@fetch_status = 0                    
	--	BEGIN 
	--		Exec SP_EMP_WEEKOFF_DATE_GET @Emp_Id_Cur,@Cmp_ID,@From_Date,@To_Date,NULL,NULL,@Is_Cancel_Weekoff,'',@StrWeekoff_Date output,@Weekoff_Days output ,@Cancel_Weekoff output
	--		SET @Emp_Weekoff_Day_Men = @WeekDay
	--		SET @Total_Emp_Weekoff_Day_Men = @Total_Emp_Weekoff_Day_Men + @Emp_Weekoff_Day_Men
			
	--		SELECT @Emp_Working_Day_Men = [dbo].[F_Get_No_Of_Days_In_Period] (@From_Date,@To_Date,'') --For take Working days
	--		SET @Total_Emp_Working_Day_Men = @Total_Emp_Working_Day_Men + @Emp_Working_Day_Men

	--		SET @Emp_Weekoff_Day_Men = 0
	--		SET @Emp_Working_Day_Men = 0
	--		fetch next FROM curweekoff into @Emp_Id_Cur
	--	End
	--close curweekoff                    
	--deallocate curweekoff   

	--DECLARE curweekoff cursor for                    
	--	SELECT EC.Emp_Id FROM @Emp_Cons EC Inner Join T0080_Emp_Master EM ON EC.Emp_Id = EM.Emp_Id WHERE Gender ='F'
	--open curweekoff                      
	--fetch next FROM curweekoff into @Emp_Id_Cur
	--while @@fetch_status = 0                    
	--	BEGIN 
	--		Exec SP_EMP_WEEKOFF_DATE_GET @Emp_Id_Cur,@Cmp_ID,@From_Date,@To_Date,NULL,NULL,@Is_Cancel_Weekoff,'',@StrWeekoff_Date output,@Weekoff_Days output ,@Cancel_Weekoff output
	--		SET @Emp_Weekoff_Day_Women = @WeekDay
	--		SET @Total_Emp_Weekoff_Day_Women = @Total_Emp_Weekoff_Day_Women + @Emp_Weekoff_Day_Women
			
	--		SELECT @Emp_Working_Day_Women = [dbo].[F_Get_No_Of_Days_In_Period] (@From_Date,@To_Date,'') --For take Working days
	--		SET @Total_Emp_Working_Day_Women = @Total_Emp_Working_Day_Women + @Emp_Working_Day_Women
				
	--		SET @Emp_Weekoff_Day_Women = 0
	--		SET @Emp_Working_Day_Women = 0
	--		fetch next FROM curweekoff into @Emp_Id_Cur
	--	End
	--close curweekoff                    
	--deallocate curweekoff   
	

	/*************************************************************************
	Added by Nimesh: 17/Nov/2015 
	(To get holiday/weekoff data for all employees in seperate table)
	*************************************************************************/
	DECLARE @Required_Execution BIT;
	SET @Required_Execution = 0;
	
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
			SET @Required_Execution = 1
		END

	IF OBJECT_ID('tempdb..#EMP_HOLIDAY') IS NULL
		BEGIN
		
			CREATE TABLE #EMP_HOLIDAY(EMP_ID NUMERIC, FOR_DATE DATETIME, IS_CANCEL BIT, Is_Half tinyint, Is_P_Comp tinyint, H_DAY numeric(4,1));
			CREATE UNIQUE CLUSTERED INDEX IX_EMP_HOLIDAY_EMPID_FORDATE ON #EMP_HOLIDAY(EMP_ID, FOR_DATE);
		END
				
	IF @Required_Execution = 1
		BEGIN
		
			EXEC SP_GET_HW_ALL @CONSTRAINT=@CONSTRAINT,@CMP_ID=@Cmp_ID, @FROM_DATE=@FROM_DATE, @TO_DATE=@TO_DATE, @All_Weekoff = 0, @Exec_Mode=0		
		END 

	
	
		select @Total_Holiday = COUNT(1) From (
		select FOR_DATE from #EMP_HOLIDAY group by FOR_DATE) Qry
	---select * from #EMP_HOLIDAY
		DECLARE @Total_Emp_Weekoff_Day_Men NUMERIC(18,1)
		DECLARE @Total_Emp_Weekoff_Day_Women NUMERIC(18,1)
		DECLARE @Total_Emp_Working_Day_Men NUMERIC(18,1)
		DECLARE @Total_Emp_Working_Day_Women NUMERIC(18,1)

		SET @Total_Emp_Weekoff_Day_Men = 0
		SET @Total_Emp_Working_Day_Men = 0
		SET @Total_Emp_Working_Day_Women = 0
		SET @Total_Emp_Weekoff_Day_Women = 0
		--select * from #EMP_WEEKOFF
		SELECT	@Total_Emp_Weekoff_Day_Women = SUM(W_DAY)
		FROM	#EMP_WEEKOFF WO
				INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON WO.Emp_ID=E.Emp_ID
				INNER JOIN @Emp_Cons EC ON E.EMP_ID=EC.Emp_ID						--Added By Jimit 20082019
				INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON BM.Branch_ID = EC.Branch_ID    --Added By Jimit 20082019
		WHERE	E.Gender='F'
		GROUP BY EC.Branch_Id    --Added By Jimit 20082019

		SET		@Total_Emp_Working_Day_Women = @Total_Emp_Working_Day_Women + @Total_Emp_Weekoff_Day_Women
	
		SELECT	@Total_Emp_Weekoff_Day_Men = SUM(W_DAY)
		FROM	#EMP_WEEKOFF WO
				INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON WO.Emp_ID=E.Emp_ID
				INNER JOIN @Emp_Cons EC ON E.EMP_ID=EC.Emp_ID						--Added By Jimit 20082019
				INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON BM.Branch_ID = EC.Branch_ID    --Added By Jimit 20082019
		WHERE	E.Gender='M'	
		GROUP BY EC.Branch_Id   --Added By Jimit 20082019

		SET		@Total_Emp_Working_Day_Men = @Total_Emp_Working_Day_Men + @Total_Emp_Weekoff_Day_Men
		
	--- End for Working day of Employee
		
		DECLARE @Sal_Cal_Days_Male	NUMERIC(18,2)
		DECLARE @Sal_Cal_Days_Female	NUMERIC(18,2)
		SET @Sal_Cal_Days_Male	= 0
		SET @Sal_Cal_Days_Female = 0
		
		SELECT	@Sal_Cal_Days_Male = Sum(Present_Days) + Sum(Holiday_Days) + Sum(Paid_Leave_Days)  ---paid_leave added by aswini 26072024
		FROM	T0200_MOnthly_Salary MS WITH (NOLOCK)
				Inner Join T0080_Emp_Master EM WITH (NOLOCK) ON MS.Emp_id = EM.Emp_Id
				INNER JOIN @Emp_Cons EC ON EM.EMP_ID=EC.Emp_ID						--Added By Jimit 20082019
				INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON BM.Branch_ID = EC.Branch_ID	--Added By Jimit 20082019
		WHERE	MS.Cmp_id = @Cmp_id AND Month_st_date >= @From_Date AND Month_End_date <= @To_Date AND Gender = 'M'
		GROUP BY EC.Branch_Id   --Added By Jimit 20082019

		SELECT	@Sal_Cal_Days_Female = Sum(Present_Days) + Sum(Holiday_Days) + Sum(Paid_Leave_Days)    ----paid_leave added by aswini 26072024
		FROM	T0200_MOnthly_Salary MS WITH (NOLOCK)
				Inner Join T0080_Emp_Master EM WITH (NOLOCK) ON MS.Emp_id = EM.Emp_Id
				INNER JOIN @Emp_Cons EC ON EM.EMP_ID=EC.Emp_ID						--Added By Jimit 20082019
				INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON BM.Branch_ID = EC.Branch_ID	--Added By Jimit 20082019
		WHERE	MS.Cmp_id = @Cmp_id AND Month_st_date >= @From_Date AND Month_End_date <= @To_Date AND Gender = 'F'
		GROUP BY EC.Branch_Id   --Added By Jimit 20082019



		




		
		SELECT	C.Cmp_Id, C.Cmp_Name,C.Cmp_Address,C.Cmp_City,C.Cmp_State_Name,C.Cmp_Pincode,c.Nature_of_Business,C.Registration_No,C.License_No,C.NIC_Code_No,c.Tax_Manager_Form_16,
				COUNT(CASE WHEN Gender = 'M' THEN 1 ELSE NULL END) AS Male,
				COUNT(CASE WHEN Gender = 'F' THEN 1 ELSE NULL END) AS Female,Count(E.Emp_ID)As Total,
				@From_Date AS From_Date, @To_Date AS To_Date, @Total_Working_Day AS Total_Working_Day,
				@Total_WeekDay AS Total_WeekDay,@Total_Holiday AS Total_Holiday,
				@Total_Emp_Weekoff_Day_Men AS Emp_Weekoff_Day_Men ,@Total_Emp_Working_Day_Men AS Total_Emp_Working_Day_Men,
				@Total_Emp_Weekoff_Day_Women AS Emp_Weekoff_Day_Women,@Total_Emp_Working_Day_Women AS Total_Emp_Working_Day_Women,
				@Sal_Cal_Days_Male AS Sal_Cal_Days_Male,@Sal_Cal_Days_Female AS Sal_Cal_Days_Female
		FROM	T0080_Emp_Master AS E WITH (NOLOCK)
				INNER JOIN T0040_Designation_Master AS D WITH (NOLOCK) ON E.Desig_Id=D.Desig_ID
				INNER JOIN T0010_Company_Master AS c WITH (NOLOCK) ON C.Cmp_Id = E.Cmp_Id
				INNER JOIN @Emp_Cons EC ON E.EMP_ID=EC.Emp_ID
				INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON BM.Branch_ID = EC.Branch_ID
		WHERE	E.Cmp_ID = @Cmp_Id 
		GROUP BY BM.Branch_ID,C.Cmp_Id,C.Cmp_Name,C.Cmp_Address,C.Cmp_State_Name,C.Cmp_City,C.Cmp_PinCode,c.Nature_of_Business,C.Registration_No,
				C.License_No,C.NIC_Code_No,c.Tax_Manager_Form_16
		
RETURN



