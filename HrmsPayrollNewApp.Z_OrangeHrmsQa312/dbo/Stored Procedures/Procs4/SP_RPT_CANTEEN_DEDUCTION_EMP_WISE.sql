

/*
AUTHOR : HARDIK BAROT
DATE : 28/11/2019
PURPOSE : TO GET EMPLOYEE WISE / DATE WISE CANTEEN PUNCHES AND AMOUNT - AS PER REQUIREMENT OF BACKBONE CLIENT
*/
---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_CANTEEN_DEDUCTION_EMP_WISE]      
	@Cmp_ID Numeric(18,0)	
	,@From_Date DateTime
	,@To_Date DateTime	
	,@Branch_ID		varchar(Max) = ''
	,@Cat_ID		varchar(Max) = ''
	,@Grd_ID		varchar(Max) = ''
	,@Type_ID		varchar(Max) = ''
	,@Dept_ID		varchar(Max) = ''
	,@Desig_ID		varchar(Max) = ''
	,@Emp_ID		numeric  = 0
	,@Constraint	varchar(max) = ''
	,@Salary_Cycle_id numeric = NULL
	,@Segment_Id  varchar(Max) = ''	
	,@Vertical_Id varchar(Max) = ''	 
	,@SubVertical_Id varchar(Max) = ''	
	,@SubBranch_Id varchar(Max) = ''
	,@CANTEEN_ID varchar(Max) = ''
	,@DeviceIPs varchar(Max) = ''
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN

	SET @From_Date = CONVERT(DateTime,CONVERT(Char(10), @From_Date, 103), 103);
	SET @To_Date= CONVERT(DateTime,CONVERT(Char(10), @To_Date, 103) + ' 23:59:59', 103);

	
	CREATE TABLE #Emp_Cons 
	(      
		Emp_ID numeric ,     
		Branch_ID numeric,
		Increment_ID numeric    
	) 

	CREATE TABLE #DATES
	(      
		For_Date Datetime
	) 

	INSERT INTO #DATES
	SELECT  TOP (DATEDIFF(DAY, @From_Date, @To_Date) + 1)
        Date = DATEADD(DAY, ROW_NUMBER() OVER(ORDER BY a.object_id) - 1, @From_Date)
	FROM    sys.all_objects a
        CROSS JOIN sys.all_objects b;


	IF @Constraint = '' AND @EMP_ID > 0
		SET @Constraint = CAST(@EMP_ID AS VARCHAR(10))
	
	EXEC dbo.SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,'1900-01-01',@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@Constraint,0,@Salary_Cycle_id,@Segment_Id,@Vertical_Id,@SubVertical_Id,@SubBranch_Id,0,0,0,'0',0,0    
	
	
	DELETE E FROM #Emp_Cons E INNER JOIN  T0080_EMP_MASTER EM ON E.Emp_ID=EM.Emp_ID
	WHERE ISNULL(EM.Enroll_No,0) = 0

		
	Alter Table  #Emp_Cons ADD Enroll_No Numeric(18,0);
	Alter Table  #Emp_Cons ADD Grade Numeric(18,0);
	
	Update #Emp_Cons 
		--SET Enroll_NO=E.Enroll_No,grade=I.grd_id
		SET Enroll_NO=E.Emp_Canteen_Code,grade=I.grd_id  -- Changed by Hardik 08/01/2019 for Backbone client as per discussion with Chintan, As per canteen code Report should be come
		From T0080_EMP_MASTER E inner join  T0095_Increment I  on E.Emp_ID = I.Emp_ID
		inner join     
		(select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)   
		where Increment_Effective_date <= @to_date and Cmp_ID = @Cmp_ID group by emp_ID) Qry on    
		I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID 
		 WHERE #Emp_Cons.Emp_ID=E.Emp_ID AND E.Cmp_ID=@Cmp_ID
	
	
	--Retrieving Canteen Details in Temp table.
	SELECT	M.Cmp_Id,M.Cnt_ID,CAST(From_Time As DateTime) As From_Time, Cast(To_Time As DateTime) As To_Time,
			Effective_Date,Amount,grd_id,Ip_id 
			,D.Subsidy_Amount,D.Total_Amount --added by  chetan 06122017
	INTO	#CANTEEN
	FROM	dbo.T0050_CANTEEN_MASTER M WITH (NOLOCK) INNER JOIN T0050_CANTEEN_DETAIL D WITH (NOLOCK) ON  M.Cnt_Id=D.Cnt_Id	and M.Cmp_Id=D.Cmp_Id 
	WHERE	D.Effective_Date <= @To_Date AND M.Cmp_ID=@Cmp_ID
	
	
	
	--Filtering Canteen Details
	IF (@CANTEEN_ID <> '' AND @CANTEEN_ID <> '0')
	BEGIN
		DELETE FROM #CANTEEN WHERE Cnt_Id NOT IN (select Data from dbo.Split(@CANTEEN_ID, '#'))   --added by chetan for multiple canteen detail
	END	
	
	SELECT	ROW_NUMBER() OVER(ORDER BY I.IO_Tran_ID) As RowID,E.Emp_ID,T.*,I.IO_DateTime,I.IP_Address,IP.Device_No, IP.Device_Name,I.IO_Tran_ID
	INTO	#TEMP 
	FROM	 dbo.T9999_DEVICE_INOUT_DETAIL I WITH (NOLOCK)
			inner JOIN T0040_IP_MASTER IP WITH (NOLOCK) ON I.IP_Address=IP.IP_ADDRESS AND IP.Cmp_ID=@CMP_ID
			INNER JOIN #Emp_Cons E ON I.Enroll_No=E.Enroll_No 
			left JOIN #CANTEEN T ON E.grade = T.grd_id  and ip.Ip_Id = T.Ip_Id
		
	WHERE	--T.Effective_Date <= I.IO_DateTime AND 
			--I.Cmp_ID=@Cmp_ID AND
			(I.In_Out_flag='10' OR I.IP_Address='Canteen' OR IP.Device_No >= 200) 
			AND (I.IO_DateTime BETWEEN @From_Date AND @To_Date) and IP.Is_Canteen =1
			order by E.Emp_ID,I.IO_DateTime 

	--Filtering Records as per Selected Device IP
	IF (@DeviceIPs <> '' AND @DeviceIPs <> '0')
	BEGIN
		DELETE FROM #TEMP WHERE IP_Address <> @DeviceIPs
	END	
	
	--Updating From_Time and To_Time for night shift
	UPDATE	#TEMP
	SET		From_Time = ((Case When (DateDiff(n, Cast(Cast(IO_DateTime As Date) AS DateTime), IO_DateTime) < 720 AND From_Time > To_Time )  
					THEN DateAdd(d,-1,From_Time) 
				ELSE
					From_Time 
				END
			) + CONVERT(DATETIME,CONVERT(CHAR(10),IO_DateTime, 103), 103)),
			To_Time = ((Case When (DateDiff(n, Cast(Cast(IO_DateTime As Date) AS DateTime), IO_DateTime) > 720 AND From_Time > To_Time )  
					THEN DateAdd(d,1,To_Time) 
				ELSE
					To_Time
				END
			) + CONVERT(DATETIME,CONVERT(CHAR(10),IO_DateTime, 103), 103))
	
	
	
	--Removing GAP between two In-Out Detail which is less than 5 minutes
	exec dbo.P0050_CANTEEN_REMOVE_IO_GAP @Cmp_ID, @From_Date, @To_Date
	

	SELECT	E.Emp_Id,E.Emp_Code,E.Alpha_Emp_Code,E.Emp_Full_Name,E.Emp_First_Name,E.Gender,E.Date_Of_Join,E.Cat_ID,
			DM.Dept_ID,DM.Dept_Name,DGM.Desig_ID,DGM.Desig_Name,GM.Grd_ID,GM.Grd_Name,
			ETM.[Type_ID],ETM.[Type_Name],BM.Branch_Name,BM.Branch_Address,BM.Comp_Name,BM.Branch_ID,
			CM.Cmp_Id,CM.Cmp_Address,CM.Cmp_Name,CT.IO_DateTime,CT.Amount,CT.From_Time,CT.To_Time,C.Cnt_Name,
			I_Q.Vertical_ID,I_Q.Vertical_Name,I_Q.SubVertical_ID,I_Q.SubVertical_Name,CT.IP_Address,CT.Device_No,CT.Device_Name
			,CONVERT(DATETIME,CONVERT(VARCHAR(10), CT.IO_DateTime, 111)) AS For_Date,CT.IO_Tran_ID,dbo.F_GET_AMPM(CT.IO_DateTime) AS In_Time	--Ankit 04032016
			,'' As Reason	
			,CT.Subsidy_Amount,CT.Total_Amount,C.Cnt_Id--added by chetan 06122017
	INTO #RPT
	FROM	dbo.T0080_EMP_MASTER E WITH (NOLOCK) left outer join dbo.T0100_Left_Emp l WITH (NOLOCK) on E.Emp_ID =  l.Emp_ID inner join
			(
				SELECT	I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Bank_ID,Inc_Bank_AC_No,
						I.Vertical_ID,I.SubVertical_ID,V.Vertical_Name,SV.SubVertical_Name
				FROM	dbo.T0095_Increment I WITH (NOLOCK) INNER JOIN 
						(
							SELECT	MAX(Increment_ID) AS Increment_ID , Emp_ID FROM dbo.T0095_Increment WITH (NOLOCK)
							WHERE	Increment_Effective_date <= @To_Date
									AND Cmp_ID = @Cmp_ID 
							GROUP BY emp_ID
						) Qry ON
						I.Emp_ID = Qry.Emp_ID AND I.Increment_ID = Qry.Increment_ID
						LEFT OUTER JOIN dbo.T0040_Vertical_Segment V WITH (NOLOCK) ON I.Cmp_ID=V.Cmp_ID And I.Vertical_ID=V.Vertical_ID			
						LEFT OUTER JOIN dbo.T0050_SubVertical SV WITH (NOLOCK) ON I.Cmp_ID=SV.Cmp_ID AND I.SubVertical_ID=SV.SubVertical_ID
			) I_Q ON E.Emp_ID = I_Q.Emp_ID  INNER JOIN 
				dbo.T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
				dbo.T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
				dbo.T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
				dbo.T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN 
				dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID  Inner join 
				dbo.T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.CMP_ID = CM.CMP_ID Inner Join
				#Emp_Cons EC on E.Emp_ID = EC.Emp_ID LEFT OUTER JOIN 
				#TEMP CT ON CT.Emp_ID=E.Emp_ID left JOIN
				dbo.T0050_CANTEEN_MASTER C WITH (NOLOCK) ON CT.Cnt_Id=C.Cnt_Id -- AND CT.Cmp_Id=C.Cmp_Id  --Removed by Nimesh on 11-Jan-2016 (Company Join is not required when In-Out is downloading from one company for another company)
	WHERE	E.Cmp_ID = @Cmp_Id 
	ORDER BY (
				Case	When IsNumeric(e.Alpha_Emp_Code) = 1 
							THEN Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
						WHEN IsNumeric(e.Alpha_Emp_Code) = 0 
							THEN Left(e.Alpha_Emp_Code + Replicate('',21), 20)
						ELSE 
							e.Alpha_Emp_Code
				END
			), CT.IO_DateTime
			
			DECLARE @cols nVARCHAR( max),
            @query nVARCHAR(max)


    SELECT @cols =
      STUFF(( SELECT ',' + QUOTENAME(cast(day(Convert(VARCHAR(max),Q.for_date,106)) AS VARCHAR(2)) + '_' + left(datename(dw,Q.for_date),2)) AS ColName FROM 
            (SELECT Distinct For_Date FROM dbo.#Dates) Q Order by Q.For_Date  
             FOR XML PATH(''), TYPE).value ('.', 'nVARCHAR(max)'), 1, 1, '')    			

    DECLARE @ALTER_COLS VARCHAR(MAX);
	DECLARE @TOTAL_COLS VARCHAR(MAX);
	DECLARE @SUM_COLS	VARCHAR(MAX);
	DECLARE @cols1	VARCHAR(MAX);

    CREATE table #Consolidated_Temp(SR_NO Numeric,Emp_Id Numeric,Employee_Code Varchar(50),Employee_Name VARCHAR(200), Meal_Type Varchar(50));

    SELECT @ALTER_COLS = COALESCE(@ALTER_COLS + ';', '') + 'ALTER TABLE  #Consolidated_Temp ADD ' + DATA + ' NUMERIC(18,0)',
		   @SUM_COLS = ISNULL(@SUM_COLS + ',','') + 'CASE WHEN ISNULL(SUM(' + DATA + '),0) = 0 then NULL ELSE ISNULL(SUM(' + DATA + '),0) ENd AS ' + DATA,
		   @cols1 = ISNULL(@cols1 + ',','') +  'CASE WHEN ' + DATA + ' = 0  then NULL ELSE ' + DATA + ' END ' + DATA
	FROM	dbo.Split(@cols, ',');

	print @cols1

	--SELECT @TOTAL_COLS = STUFF(( SELECT ',' + 'Sum(' + QUOTENAME( cast(day(Convert(VARCHAR(max),Q.for_date,106)) AS VARCHAR(2)) + '_' + left(datename(dw,Q.for_date),2) )+ ')' AS ColName FROM 
	--					(SELECT Distinct For_Date FROM dbo.#Dates) Q Order by Q.For_Date  
	--					 FOR XML PATH(''), TYPE).value ('.', 'nVARCHAR(max)'), 1, 1, '') 
	
	--print @SUM_COLS
    EXEC (@ALTER_COLS);

	ALTER TABLE #Consolidated_Temp ADD TOTAL_MEAL NUMERIC, AMOUNT NUMERIC(18,2),GROSS NUMERIC(18,2),[Signature] Varchar(10)


	
	SELECT @Query=' INSERT INTO #Consolidated_Temp
					SELECT NULL,EmpID, ''="'' + Alpha_Emp_Code + ''"'' ,Emp_Full_Name,Cnt_Name, '+@cols1+',0,0,0,''''  FROM   
					(
						SELECT	Emp_Id As EmpID, Alpha_Emp_Code,Emp_Full_Name, Cnt_Name,cast(day(for_date)as VARCHAR(2)) + ''_'' + left(datename(dw,for_date),2) AS For_Date, Emp_Id 
						FROM	#RPT 						
					)Tab1  
					PIVOT  
					(  
					Count(Emp_Id) FOR [For_Date] IN ('+@cols+')) AS Tab2  
					ORDER BY Tab2.EmpID' 
		
		print @Query
		
		
		Exec (@Query)

		

		SET @Query = 'INSERT	INTO #Consolidated_Temp(SR_NO,Emp_Id,Employee_Code,Employee_NAme,Meal_Type,' + @cols + ')
								SELECT	NULL,99999,''99999'',''TOTAL'',Meal_Type,' + @SUM_COLS + '								
								FROM	#Consolidated_Temp
								GROUP BY Meal_Type'

		
		EXEC (@Query)

		

		Update	#Consolidated_Temp 
		Set		TOTAL_MEAL = Qry.Total_Count, AMOUNT = Qry.Total_Amount
		From	#Consolidated_Temp CT Inner Join
				(
					SELECT  Emp_id, Cnt_Name,Count(Emp_Id) as Total_Count, Sum(Amount) AS Total_Amount 
					FROM	#RPT
					WHERE	Emp_Id <> 99999
					GROUP BY Emp_Id,Cnt_Name
				) Qry On CT.Emp_Id = Qry.Emp_ID and CT.Meal_Type = Cnt_Name

		Update	#Consolidated_Temp 
		Set		TOTAL_MEAL = Qry.Total_Count, AMOUNT = Qry.Total_Amount
		From	#Consolidated_Temp CT Inner Join
				(
					SELECT		Cnt_Name,Count(Emp_Id) as Total_Count, Sum(Amount) AS Total_Amount 
					FROM		#RPT
					GROUP BY	Cnt_Name
				) Qry On CT.Emp_Id = 99999 and CT.Meal_Type = Cnt_Name

		
		UPDATE	CT
		SET		GROSS = Q.GROSS
		FROM	#Consolidated_Temp CT
				INNER JOIN (
								SELECT   Emp_Id,SUM(ISNULL(AMOUNT,0)) as GROSS
								FROM	 #Consolidated_Temp
								GROUP BY Emp_Id
							)Q ON CT.Emp_Id = Q.Emp_ID
		

		UPDATE  U
		SET     Employee_Name = '',
				Employee_Code = '',
				GROSS = NULL
				
		FROM	(
					SELECT  CT.Employee_Name,CT.Employee_Code, ROW_NUMBER() OVER(PARTITION BY Emp_Id ORDER BY Emp_Id) AS RowNum,Emp_Id,CT.GROSS
					FROM    #Consolidated_Temp CT						
				) AS U
			where	RowNum > 1 --and Employee_Code <> '99999'


		
		UPDATE  U
		SET      SR_NO = RowNum				
		FROM	(
					SELECT  SR_NO,ROW_NUMBER() OVER(ORDER BY Employee_Code) AS RowNum
					FROM    #Consolidated_Temp CT	
					WHERE	Employee_Code <> ''					
				) AS U
		
		

		SELECT *
		INTO	#FINAL_Consolidated_Temp
		FROM	#Consolidated_Temp
		Order By Emp_Id
		
		ALTER TABLE #FINAL_Consolidated_Temp
		DROP Column Emp_Id

		select * from #FINAL_Consolidated_Temp
			
END

 RETURN      



