

-- =============================================
-- Author:		MUKTI CHAUHAN	
-- Create date: 13-08-2018
-- Description: Exit_Graphical_Report
---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[Exit_Graphical_Report]
	 @Cmp_ID		Numeric 
	,@From_Date		Datetime 
	,@To_Date		Datetime
	,@Grd_ID		varchar(Max)='' 	
	,@Dept_ID		varchar(Max)=''
	,@Constraint	varchar(MAX)=''		
	,@ReportType	int = 0 
	,@flag			varchar(50)
	,@Group_Id		int
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	
	CREATE TABLE #Emp_Cons 
	 (      
	   Emp_ID numeric ,     
	   Branch_ID numeric,
	   Increment_ID numeric	  
	 )  
	DECLARE @TEMP_FROM_DATE DATETIME
	exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,'','',@Grd_ID,0,@Dept_ID,'',0,@constraint,0,0,'','','','',0,0,0,'0',0,0 
	
	DELETE FROM #Emp_Cons
	WHERE NOT EXISTS (
					select	 E.Emp_ID 
					from	#Emp_Cons as  E Inner JOIN T0095_INCREMENT as i WITH (NOLOCK) ON i.Increment_ID = E.Increment_ID
					where	 #Emp_Cons.Increment_ID = E.Increment_ID
					  --and EXISTS (select Data from dbo.Split(@PBranch_ID, ',') PB Where cast(PB.data as numeric)=Isnull(I.Branch_ID,0))
					  --and EXISTS (select Data from dbo.Split(@PVertical_ID, ',') V Where cast(v.data as numeric)=Isnull(I.Vertical_ID,0))
					  --and EXISTS (select Data from dbo.Split(@PsubVertical_ID, ',') S Where cast(S.data as numeric)=Isnull(I.SubVertical_ID,0))
					  --AND  EXISTS (select Data from dbo.Split(@PDept_ID, ',') D Where cast(D.data as numeric)=Isnull(I.Dept_ID,0))  
				)
	
	Update #Emp_Cons  set Branch_ID = a.Branch_ID from (
		SELECT DISTINCT VE.Emp_ID,VE.branch_id,VE.Increment_ID 
					  FROM dbo.V_Emp_Cons VE inner join
					  #Emp_Cons EC on  VE.Emp_ID = EC.Emp_ID
		)a
	where a.Emp_ID = #Emp_Cons.Emp_ID   	
	
	Declare @Cur_Emp_ID numeric(18,0)
	Declare @Cur_Branch_ID numeric(18,0)
	Declare @Prev_Branch_ID numeric(18,0)
	Declare @Cur_For_Date datetime
	Declare @Cur_Tran_ID numeric(18,0)
	DECLARE @TEMP_MONTH_DATE DATETIME
	
	 set @Cur_Emp_ID = 0
	 set @Cur_Branch_ID = 0
	 set @Prev_Branch_ID = 0
	 set @Cur_Tran_ID = 0	
	
	CREATE table #Exit_Details
	(      
		Month_Name VARCHAR(100),
		Exit_Month NUMERIC,
		Exit_Year NUMERIC,
		Res_Id NUMERIC,
		Reason_Name VARCHAR(500),
	    Count_Emp numeric
	   -- Dept_Name VARCHAR(500),
	   -- Grd_Name VARCHAR(500)
	)
	DECLARE @columns VARCHAR(8000)
	DECLARE @query VARCHAR(MAX)
	
	SELECT DISTINCT	RM.Reason_Name,RM.Res_Id--,IC.Dept_Name
	into #Exit_Reason
	FROM	T0200_Emp_ExitApplication LA WITH (NOLOCK)	
	INNER JOIN T0040_Reason_Master RM WITH (NOLOCK) ON RM.Res_Id=LA.reason				
	WHERE LA.last_date BETWEEN @FROM_DATE AND @TO_DATE --and ISNULL(IC.Dept_Name,'') <> ''
				
	IF @ReportType=0
		BEGIN			
		 IF @FLAG='Month Wise'
			BEGIN			
				SET @TEMP_FROM_DATE = @FROM_DATE
				WHILE @TO_DATE >= @TEMP_FROM_DATE
					BEGIN
						INSERT	INTO #Exit_Details
						SELECT DISTINCT  CAST(DATENAME(MONTH,@TEMP_FROM_DATE) AS VARCHAR(3)),
								MONTH(@TEMP_FROM_DATE),YEAR(@TEMP_FROM_DATE),Res_Id,Reason_Name,0--,IC.Dept_Name,IC.Grd_Name	
						FROM	T0040_Reason_Master RM WITH (NOLOCK)
						INNER JOIN T0200_Emp_ExitApplication EX WITH (NOLOCK) ON RM.Res_Id=EX.reason
						INNER JOIN
						(
						 SELECT T0095_INCREMENT.Emp_ID,T0095_INCREMENT.Increment_ID,Grd_ID,Desig_Id,Dept_ID,Branch_ID
						 FROM  T0095_INCREMENT WITH (NOLOCK) INNER JOIN
							   (
									SELECT MAX(Increment_ID)Increment_ID,T0095_INCREMENT.Emp_ID
									FROM  T0095_INCREMENT WITH (NOLOCK) INNER JOIN
									(
										SELECT max(Increment_Effective_Date)Increment_Effective_Date,Emp_ID
										FROM T0095_INCREMENT WITH (NOLOCK)
										WHERE Cmp_ID = @cmp_id
										GROUP BY Emp_ID
									)I2 on I2.Emp_ID = T0095_INCREMENT.Emp_ID
									WHERE Cmp_ID = @cmp_id
									GROUP BY T0095_INCREMENT.Emp_ID
							   )I1 on I1.Increment_ID = T0095_INCREMENT.Increment_ID and I1.Emp_ID = T0095_INCREMENT.Emp_ID
					  )I on I.Emp_ID = EX.Emp_ID 
						--INNER JOIN V0080_EMP_MASTER_INCREMENT_GET IC ON IC.Emp_ID=EX.emp_id
						where [Type]='Exit' and EX.cmp_id=@CMP_ID and EX.last_date BETWEEN @FROM_DATE AND @TO_DATE
						--and EX.[status] = 'A'
						
						SET @TEMP_FROM_DATE = DATEADD(MM,1,@TEMP_FROM_DATE)
					END
				--SELECT * FROM #Exit_Details
				UPDATE	#Exit_Details 
				SET		Count_Emp =ISNULL(T1.Count_Emp,0)
				FROM	  
				(
							SELECT	COUNT(LA.emp_id)Count_Emp,LA.reason,MONTH(LA.last_date)as Ex_Month,YEAR(LA.last_date)as Ex_Year
							FROM	T0200_Emp_ExitApplication LA WITH (NOLOCK)								
							WHERE LA.last_date BETWEEN @FROM_DATE AND @TO_DATE
							AND LA.CMP_ID = @CMP_ID and LA.[status] = 'A'
							GROUP BY YEAR(LA.last_date),MONTH(LA.last_date),LA.reason
							) AS T1 WHERE T1.Ex_Month = #Exit_Details.EXIT_MONTH AND T1.Ex_Year = #Exit_Details.EXIT_YEAR 
							AND T1.reason = #Exit_Details.RES_ID
				
				--SELECT * from #MONTH_LIST			
				
				SELECT @columns = COALESCE(@columns + ',[' + CAST(MONTH_NAME AS VARCHAR(1000)) + ']',
					'[' + CAST(MONTH_NAME AS VARCHAR(1000))+ ']')
				FROM	(SELECT ROW_NUMBER() OVER(ORDER BY EXIT_MONTH) AS ROW_ID,MONTH_NAME
					FROM	#Exit_Details GROUP BY EXIT_MONTH,MONTH_NAME)T
				PRINT @columns
			
				SELECT ED.* FROM #Exit_Details ED
				INNER JOIN t0010_company_master cm WITH (NOLOCK) ON cm.cmp_id=@cmp_id 
				WHERE ED.Reason_name <> '' --AND ED.COUNT_EMP >0	
				--select * from #Exit_Details
				
				--select * from #Exit_Details
				SET @query = 'SELECT Reason_Name as[Reason For Leaving],'+ @columns +'										
									FROM (
										SELECT Reason_Name,ISNULL(Count_Emp,0)Count_Emp,Month_Name
										FROM #Exit_Details EC WHERE Reason_Name<>''''																																																																
										) as s
									PIVOT	
									(				 
										MAX(Count_Emp)	
										FOR [MONTH_NAME] IN (' + @columns + ')  														 				
									)AS T
									 '
						print @query
						EXEC(@query)	
			END
		ELSE IF @FLAG='Year Wise' or @FLAG='Year Wise Comparison'
			BEGIN
				CREATE table #YEAR_EXIT_DETAILS
				(   					
					Exit_Year NUMERIC,
					Res_Id NUMERIC,
					Reason_Name VARCHAR(500),
					Count_Emp numeric				
				)
	
				SET @TEMP_FROM_DATE = @FROM_DATE
				PRINT @TEMP_FROM_DATE
				WHILE YEAR(@TO_DATE) >= YEAR(@TEMP_FROM_DATE)
					BEGIN
						INSERT INTO #YEAR_EXIT_DETAILS
						SELECT DISTINCT  YEAR(@TEMP_FROM_DATE)YEAR_EXIT,Res_Id,Reason_Name,0						
						FROM	T0040_Reason_Master RM WITH (NOLOCK)
						INNER JOIN T0200_Emp_ExitApplication EX WITH (NOLOCK) ON RM.Res_Id=EX.reason
						INNER JOIN
						(
						 SELECT T0095_INCREMENT.Emp_ID,T0095_INCREMENT.Increment_ID,Grd_ID,Desig_Id,Dept_ID,Branch_ID
						 FROM  T0095_INCREMENT WITH (NOLOCK) INNER JOIN
							   (
									SELECT MAX(Increment_ID)Increment_ID,T0095_INCREMENT.Emp_ID
									FROM  T0095_INCREMENT WITH (NOLOCK) INNER JOIN
									(
										SELECT max(Increment_Effective_Date)Increment_Effective_Date,Emp_ID
										FROM T0095_INCREMENT WITH (NOLOCK)
										WHERE Cmp_ID = @cmp_id
										GROUP BY Emp_ID
									)I2 on I2.Emp_ID = T0095_INCREMENT.Emp_ID
									WHERE Cmp_ID = @cmp_id
									GROUP BY T0095_INCREMENT.Emp_ID
							   )I1 on I1.Increment_ID = T0095_INCREMENT.Increment_ID and I1.Emp_ID = T0095_INCREMENT.Emp_ID
					  )I on I.Emp_ID = EX.Emp_ID 
						--INNER JOIN V0080_EMP_MASTER_INCREMENT_GET IC ON IC.Emp_ID=EX.emp_id
						where [Type]='Exit' and EX.cmp_id=@CMP_ID and EX.last_date BETWEEN @FROM_DATE AND @TO_DATE
						--and EX.[status] = 'A'
						
						SET @TEMP_FROM_DATE = DATEADD(YY,1,@TEMP_FROM_DATE)
					END
					--select * from #YEAR_EXIT_DETAILS
					
					--SELECT	COUNT(LA.emp_id)Count_Emp,LA.reason,YEAR(LA.last_date)as Ex_Year
					--FROM	T0200_Emp_ExitApplication LA 								
					--WHERE LA.last_date BETWEEN @FROM_DATE AND @TO_DATE
					--AND LA.CMP_ID = @CMP_ID --and LA.[status] = 'A'
					--GROUP BY YEAR(LA.last_date),LA.reason
					
				UPDATE	#YEAR_EXIT_DETAILS 
				SET		Count_Emp =ISNULL(T1.Count_Emp,0)
				FROM	  
				(
					SELECT	COUNT(LA.emp_id)Count_Emp,LA.reason,YEAR(LA.last_date)as Ex_Year
					FROM	T0200_Emp_ExitApplication LA WITH (NOLOCK)								
					WHERE LA.last_date BETWEEN @FROM_DATE AND @TO_DATE
					AND LA.CMP_ID = @CMP_ID and LA.[status] = 'A'
					GROUP BY YEAR(LA.last_date),LA.reason
					) AS T1 WHERE T1.Ex_Year= #YEAR_EXIT_DETAILS.EXIT_YEAR--T1.Ex_Month = #Exit_Details.EXIT_MONTH AND T1.Ex_Year = #Exit_Details.EXIT_YEAR AND
				 AND T1.reason = #YEAR_EXIT_DETAILS.RES_ID						
				
				SELECT @columns = COALESCE(@columns + ',[' + CAST(EXIT_YEAR AS VARCHAR(1000)) + ']',
					'[' + CAST(EXIT_YEAR AS VARCHAR(1000))+ ']')
				FROM (SELECT EXIT_YEAR FROM #YEAR_EXIT_DETAILS GROUP BY EXIT_YEAR)T	
				PRINT @columns
			
				SELECT ED.* FROM #YEAR_EXIT_DETAILS ED
				INNER JOIN t0010_company_master cm WITH (NOLOCK) ON cm.cmp_id=@cmp_id 
				WHERE ED.Reason_name <> '' --AND ED.COUNT_EMP >0	
				--select * from #Exit_Details
				
				--select * from #Exit_Details
				SET @query = 'SELECT Reason_Name as[Reason For Leaving],'+ @columns +'										
									FROM (
										SELECT Reason_Name,ISNULL(Count_Emp,0)Count_Emp,EXIT_YEAR
										FROM #YEAR_EXIT_DETAILS EC WHERE Reason_Name<>''''																																																																
										) as s
									PIVOT	
									(				 
										MAX(Count_Emp)	
										FOR [EXIT_YEAR] IN (' + @columns + ')  														 				
									)AS T
									 '
						print @query
						EXEC(@query)	
			END
		ELSE IF @FLAG='Department Wise'
			BEGIN
				select DISTINCT D.Dept_Name,T.Reason_Name,T.Res_Id,0 Count_Emp,D.Dept_ID
				INTO #DEPT_EXIT
				FROM	T0200_Emp_ExitApplication LA WITH (NOLOCK) INNER JOIN
					(
					 SELECT T0095_INCREMENT.Emp_ID,T0095_INCREMENT.Increment_ID,Grd_ID,Desig_Id,Dept_ID,Branch_ID
					 FROM  T0095_INCREMENT WITH (NOLOCK) INNER JOIN
						   (
								SELECT MAX(Increment_ID)Increment_ID,T0095_INCREMENT.Emp_ID
								FROM  T0095_INCREMENT WITH (NOLOCK) INNER JOIN
								(
									SELECT max(Increment_Effective_Date)Increment_Effective_Date,Emp_ID
									FROM T0095_INCREMENT WITH (NOLOCK)
									WHERE Cmp_ID = @cmp_id
									GROUP BY Emp_ID
								)I2 on I2.Emp_ID = T0095_INCREMENT.Emp_ID
								WHERE Cmp_ID = @cmp_id
								GROUP BY T0095_INCREMENT.Emp_ID
						   )I1 on I1.Increment_ID = T0095_INCREMENT.Increment_ID and I1.Emp_ID = T0095_INCREMENT.Emp_ID
				  )I on I.Emp_ID = LA.Emp_ID INNER JOIN
				T0040_DEPARTMENT_MASTER D WITH (NOLOCK) ON D.Dept_Id = I.Dept_ID 
				CROSS JOIN (SELECT * FROM #Exit_Reason) T
				WHERE LA.last_date BETWEEN @FROM_DATE AND @TO_DATE and ISNULL(D.Dept_Name,'')<>'' --and LA.[status] = 'A'
				ORDER BY D.Dept_Name				
				
				--SELECT * FROM #DEPT_EXIT				
				
				--SELECT	COUNT(LA.emp_id)Count_Emp,LA.reason,I.Dept_ID
				--			FROM	T0200_Emp_ExitApplication LA
				--			INNER JOIN
				--				(
				--				 SELECT T0095_INCREMENT.Emp_ID,T0095_INCREMENT.Increment_ID,Grd_ID,Desig_Id,Dept_ID,Branch_ID
				--				 FROM  T0095_INCREMENT INNER JOIN
				--					   (
				--							SELECT MAX(Increment_ID)Increment_ID,T0095_INCREMENT.Emp_ID
				--							FROM  T0095_INCREMENT INNER JOIN
				--							(
				--								SELECT max(Increment_Effective_Date)Increment_Effective_Date,Emp_ID
				--								FROM T0095_INCREMENT
				--								WHERE Cmp_ID = @cmp_id
				--								GROUP BY Emp_ID
				--							)I2 on I2.Emp_ID = T0095_INCREMENT.Emp_ID
				--							WHERE Cmp_ID = @cmp_id
				--							GROUP BY T0095_INCREMENT.Emp_ID
				--					   )I1 on I1.Increment_ID = T0095_INCREMENT.Increment_ID and I1.Emp_ID = T0095_INCREMENT.Emp_ID
				--			  )I on I.Emp_ID = LA.Emp_ID
				--			WHERE LA.last_date BETWEEN @FROM_DATE AND @TO_DATE
				--			AND LA.CMP_ID = @CMP_ID AND ISNULL(I.Dept_ID,0) > 0--and LA.[status] = 'A'
				--			GROUP BY I.Dept_ID,LA.reason
						
							
				UPDATE	#DEPT_EXIT 
				SET		Count_Emp =ISNULL(T1.Count_Emp,0)
				FROM	  
				(
							SELECT	COUNT(LA.emp_id)Count_Emp,LA.reason,I.Dept_ID
							FROM	T0200_Emp_ExitApplication LA WITH (NOLOCK)
							INNER JOIN
								(
								 SELECT T0095_INCREMENT.Emp_ID,T0095_INCREMENT.Increment_ID,Grd_ID,Desig_Id,Dept_ID,Branch_ID
								 FROM  T0095_INCREMENT WITH (NOLOCK) INNER JOIN
									   (
											SELECT MAX(Increment_ID)Increment_ID,T0095_INCREMENT.Emp_ID
											FROM  T0095_INCREMENT WITH (NOLOCK) INNER JOIN
											(
												SELECT max(Increment_Effective_Date)Increment_Effective_Date,Emp_ID
												FROM T0095_INCREMENT WITH (NOLOCK)
												WHERE Cmp_ID = @cmp_id
												GROUP BY Emp_ID
											)I2 on I2.Emp_ID = T0095_INCREMENT.Emp_ID
											WHERE Cmp_ID = @cmp_id
											GROUP BY T0095_INCREMENT.Emp_ID
									   )I1 on I1.Increment_ID = T0095_INCREMENT.Increment_ID and I1.Emp_ID = T0095_INCREMENT.Emp_ID
							  )I on I.Emp_ID = LA.Emp_ID
							WHERE LA.last_date BETWEEN @FROM_DATE AND @TO_DATE
							AND LA.CMP_ID = @CMP_ID AND ISNULL(I.Dept_ID,0) > 0 and LA.[status] = 'A'
							GROUP BY I.Dept_ID,LA.reason
							) AS T1 WHERE  T1.reason = #DEPT_EXIT.RES_ID AND T1.Dept_ID=#DEPT_EXIT.Dept_ID
							
				SELECT * FROM #DEPT_EXIT
				
				SELECT @columns = COALESCE(@columns + ',[' + CAST(DEPT_NAME AS VARCHAR(1000)) + ']',
					'[' + CAST(DEPT_NAME AS VARCHAR(1000))+ ']')
				FROM (SELECT ROW_NUMBER() OVER(ORDER BY DEPT_ID) AS ROW_ID,DEPT_NAME
					FROM	#DEPT_EXIT GROUP BY DEPT_ID,DEPT_NAME)T					
				--PRINT @columns			
				
				SET @query = 'SELECT Reason_Name as[Reason For Leaving],'+ @columns +'										
									FROM (
										SELECT Reason_Name,ISNULL(Count_Emp,0)Count_Emp,DEPT_NAME
										FROM #DEPT_EXIT EC WHERE Reason_Name<>''''																																																																
										) as s
									PIVOT	
									(				 
										MAX(Count_Emp)	
										FOR [DEPT_NAME] IN (' + @columns + ')  														 				
									)AS T'
						--print @query
						EXEC(@query)
			END			
		ELSE IF @FLAG='Grade Wise'
			BEGIN
				--SELECT * FROM #Exit_Reason	
					
				select DISTINCT G.Grd_Name,T.Reason_Name,T.Res_Id,0 Count_Emp,G.Grd_ID
				INTO #GRADE_EXIT
				FROM	T0200_Emp_ExitApplication LA WITH (NOLOCK) INNER JOIN
					(
					 SELECT T0095_INCREMENT.Emp_ID,T0095_INCREMENT.Increment_ID,Grd_ID,Desig_Id,Dept_ID,Branch_ID
					 FROM  T0095_INCREMENT WITH (NOLOCK) INNER JOIN
						   (
								SELECT MAX(Increment_ID)Increment_ID,T0095_INCREMENT.Emp_ID
								FROM  T0095_INCREMENT WITH (NOLOCK) INNER JOIN
								(
									SELECT max(Increment_Effective_Date)Increment_Effective_Date,Emp_ID
									FROM T0095_INCREMENT WITH (NOLOCK)
									WHERE Cmp_ID = @cmp_id
									GROUP BY Emp_ID
								)I2 on I2.Emp_ID = T0095_INCREMENT.Emp_ID
								WHERE Cmp_ID = @cmp_id
								GROUP BY T0095_INCREMENT.Emp_ID
						   )I1 on I1.Increment_ID = T0095_INCREMENT.Increment_ID and I1.Emp_ID = T0095_INCREMENT.Emp_ID
				  )I on I.Emp_ID = LA.Emp_ID INNER JOIN
				T0040_GRADE_MASTER G WITH (NOLOCK) ON G.Grd_ID = I.Grd_ID 
				CROSS JOIN (SELECT * FROM #Exit_Reason) T
				WHERE LA.last_date BETWEEN @FROM_DATE AND @TO_DATE and ISNULL(G.Grd_Name,'')<>'' --and LA.[status] = 'A'
				ORDER BY G.Grd_Name
				
				UPDATE	#GRADE_EXIT 
				SET		Count_Emp =ISNULL(T1.Count_Emp,0)
				FROM	  
				(
							SELECT	COUNT(LA.emp_id)Count_Emp,LA.reason,I.Grd_ID
							FROM	T0200_Emp_ExitApplication LA WITH (NOLOCK)
							INNER JOIN
								(
								 SELECT T0095_INCREMENT.Emp_ID,T0095_INCREMENT.Increment_ID,Grd_ID,Desig_Id,Dept_ID,Branch_ID
								 FROM  T0095_INCREMENT WITH (NOLOCK) INNER JOIN
									   (
											SELECT MAX(Increment_ID)Increment_ID,T0095_INCREMENT.Emp_ID
											FROM  T0095_INCREMENT WITH (NOLOCK) INNER JOIN
											(
												SELECT max(Increment_Effective_Date)Increment_Effective_Date,Emp_ID
												FROM T0095_INCREMENT WITH (NOLOCK)
												WHERE Cmp_ID = @cmp_id
												GROUP BY Emp_ID
											)I2 on I2.Emp_ID = T0095_INCREMENT.Emp_ID
											WHERE Cmp_ID = @cmp_id
											GROUP BY T0095_INCREMENT.Emp_ID
									   )I1 on I1.Increment_ID = T0095_INCREMENT.Increment_ID and I1.Emp_ID = T0095_INCREMENT.Emp_ID
							  )I on I.Emp_ID = LA.Emp_ID
							WHERE LA.last_date BETWEEN @FROM_DATE AND @TO_DATE
							AND LA.CMP_ID = @CMP_ID AND ISNULL(I.Grd_ID,0) > 0 and LA.[status] = 'A'
							GROUP BY I.Grd_ID,LA.reason
							) AS T1 WHERE  T1.reason = #GRADE_EXIT.RES_ID AND T1.Grd_ID=#GRADE_EXIT.Grd_ID
							--T1.last_date BETWEEN @FROM_DATE AND @TO_DATE AND
							--T1.Ex_Month = #Exit_Details.EXIT_MONTH AND T1.Ex_Year = #Exit_Details.EXIT_YEAR 
							
				SELECT * FROM #GRADE_EXIT
				
				SELECT @columns = COALESCE(@columns + ',[' + CAST(Grd_Name AS VARCHAR(1000)) + ']',
					'[' + CAST(Grd_Name AS VARCHAR(1000))+ ']')
				FROM (SELECT ROW_NUMBER() OVER(ORDER BY Grd_ID) AS ROW_ID,Grd_Name
					FROM	#GRADE_EXIT GROUP BY Grd_ID,Grd_Name)T					
				--PRINT @columns			
				
				SET @query = 'SELECT Reason_Name as[Reason For Leaving],'+ @columns +'										
									FROM (
										SELECT Reason_Name,ISNULL(Count_Emp,0)Count_Emp,Grd_Name
										FROM #GRADE_EXIT EC WHERE Reason_Name<>''''																																																																
										) as s
									PIVOT	
									(				 
										MAX(Count_Emp)	
										FOR [Grd_Name] IN (' + @columns + ')  														 				
									)AS T'
						--print @query
						EXEC(@query)	
			END							
		END
	ELSE IF @ReportType=1
		BEGIN
			IF @FLAG='Month Wise'
				BEGIN
					--select CAST(DATENAME(MONTH,Left_Date) AS VARCHAR(3))[MONTH_NAME],COUNT(Emp_ID)COUNT_EMP,MONTH(Left_Date)MONTH
					--	   INTO #m1
					--from T0100_LEFT_EMP 
					--where Cmp_ID=@CMP_ID and Left_Date BETWEEN '2018-01-01' AND '2018-12-31'
					--group by CAST(DATENAME(MONTH,Left_Date) AS VARCHAR(3)),MONTH(Left_Date)
					--order by MONTH(Left_Date)
					
					--SELECT * FROM #m1
					--SELECT MONTH_NAME AS[Month],COUNT_EMP AS[No. of Employees left] FROM #EXIT_MONTHWISE
					
					CREATE table #EXIT_MONTHWISE
					(   					
						Month_Name VARCHAR(10),	
						[Month] NUMERIC,					
						Count_Emp numeric				
					)
		
					SET @TEMP_FROM_DATE = @FROM_DATE
					PRINT @TEMP_FROM_DATE
					WHILE @TO_DATE >= @TEMP_FROM_DATE
						BEGIN
							INSERT INTO #EXIT_MONTHWISE
							SELECT DISTINCT  CAST(DATENAME(MONTH,@TEMP_FROM_DATE) AS VARCHAR(3)),MONTH(@TEMP_FROM_DATE),0
							SET @TEMP_FROM_DATE = DATEADD(MM,1,@TEMP_FROM_DATE)
						END
				--select * from #EXIT_MONTHWISE
				UPDATE	#EXIT_MONTHWISE 
				SET		Count_Emp =ISNULL(T1.Count_Emp,0)
				FROM	  
				(
							SELECT	COUNT(Emp_ID)COUNT_EMP,MONTH(Left_Date)[MONTH]
							FROM	T0100_LEFT_EMP LA WITH (NOLOCK)								
							WHERE LA.Left_Date BETWEEN @from_date AND @to_date
							and LA.CMP_ID = @cmp_id
							GROUP BY  MONTH(Left_Date)
							) AS T1 WHERE T1.[MONTH] = #EXIT_MONTHWISE.[Month] 
				
				SELECT * from #EXIT_MONTHWISE			
				SELECT Month_Name as [Month Name],Count_Emp as[No. of Employees Left] from #EXIT_MONTHWISE	
			END
		ELSE IF @FLAG='Year Wise' 
				BEGIN
					CREATE table #YEAR_LEFT_DETAILS
					(   					
						Exit_Year NUMERIC,					
						Count_Emp numeric				
					)
		
					SET @TEMP_FROM_DATE = @FROM_DATE
					PRINT @TEMP_FROM_DATE
					WHILE YEAR(@TO_DATE) >= YEAR(@TEMP_FROM_DATE)
						BEGIN
							INSERT INTO #YEAR_LEFT_DETAILS
							SELECT DISTINCT  YEAR(@TEMP_FROM_DATE)Exit_Year,0
							SET @TEMP_FROM_DATE = DATEADD(YY,1,@TEMP_FROM_DATE)
						END
						--select * from #YEAR_LEFT_DETAILS				
						
					UPDATE	#YEAR_LEFT_DETAILS 
					SET		Count_Emp =ISNULL(T1.Count_Emp,0)
					FROM	  
					(
						select COUNT(Emp_ID)COUNT_EMP,YEAR(Left_Date)[Year_Name]
						from T0100_LEFT_EMP WITH (NOLOCK) where Cmp_ID=@CMP_ID and Left_Date BETWEEN @from_date AND @to_date
						group by YEAR(Left_Date)
						--order by YEAR(Left_Date)
						) AS T1 WHERE T1.Year_Name= #YEAR_LEFT_DETAILS.Exit_Year
						
					SELECT * FROM #YEAR_LEFT_DETAILS 
					SELECT Exit_Year as [Year],Count_Emp as[No. of Employees Left] FROM #YEAR_LEFT_DETAILS 
				END	
		ELSE IF @FLAG='Year Wise Monthly Comparison'
				BEGIN
					SELECT ISNULL(T.T_YEAR, T1.T_YEAR)[Year],									
					--ISNULL(CAST(DATENAME(MONTH,T.T_MONTH)AS VARCHAR(3)), CAST(DATENAME(MONTH,T1.T_MONTH)AS VARCHAR(3)))[Month_Name],
					ISNULL(T.T_MONTH, T1.T_MONTH)[Month], ISNULL(T.T_COUNT, 0) AS Count_Emp,
					cast(datename(month, T1.FOR_DATE) as VARCHAR(3)) as Month_Name
					INTO #LEFT_YEARLY_COMPARISON
					FROM	(
								select Year(Left_Date) AS T_YEAR, Month(Left_Date) T_MONTH, Count(1) AS T_COUNT
								from T0100_LEFT_EMP WITH (NOLOCK)
								where Cmp_ID=@cmp_id
								Group By Year(Left_Date), Month(Left_Date)
							) T
							RIGHT OUTER JOIN (
												SELECT	YEAR(FOR_DATE) T_YEAR, MONTH(FOR_DATE) T_MONTH,FOR_DATE, 0 T_COUNT
												FROM	(
															SELECT	TOP 120 DATEADD(M,ROW_NUMBER() OVER(ORDER BY object_id) -1, @FROM_DATE) AS FOR_DATE
															FROM	SYS.objects 			
														) t
											) T1 ON T.T_YEAR=T1.T_YEAR AND T.T_MONTH=T1.T_MONTH --AND T.T_COUNT IS NULL
					WHERE	T1.FOR_DATE BETWEEN @FROM_DATE AND @TO_DATE 
					ORDER BY ISNULL(T.T_YEAR, T1.T_YEAR),ISNULL(T.T_MONTH, T1.T_MONTH)
				
				--SELECT * FROM #LEFT_YEARLY_COMPARISON	
				SELECT [Year],Month_Name,Count_Emp FROM #LEFT_YEARLY_COMPARISON 
				
				SELECT @columns = COALESCE(@columns + ',[' + CAST([Year] AS VARCHAR(1000)) + ']',
					'[' + CAST([Year] AS VARCHAR(1000))+ ']')
				FROM (SELECT [Year]
					FROM	#LEFT_YEARLY_COMPARISON GROUP BY [YEAR])T					
					
					PRINT @columns
				
				SET @query = 'SELECT Month_Name as[Month Name],'+ @columns +'										
									FROM (
										SELECT Month_Name,ISNULL(Count_Emp,0)Count_Emp,[Year],[Month]
										FROM #LEFT_YEARLY_COMPARISON EC	 																																																														
										) as s
									PIVOT	
									(				 
										MAX(Count_Emp)	
										FOR [Year] IN (' + @columns + ')  														 				
									)AS T '
						--print @query
						EXEC(@query)
				END							
			ELSE IF @FLAG='Department Wise' 
				BEGIN
					CREATE table #DEPARTMENT_LEFT_DETAILS
					(   					
						Dept_Name VARCHAR(500),					
						Count_Emp numeric				
					)
		
					INSERT INTO #DEPARTMENT_LEFT_DETAILS
					SELECT DISTINCT DEPT_NAME,0					
					from T0100_LEFT_EMP L WITH (NOLOCK) INNER JOIN
					V0080_EMP_MASTER_INCREMENT_GET I on L.Emp_ID=I.Emp_ID 
					where L.Cmp_ID=@CMP_ID and ISNULL(I.Dept_Name,'') <>''						
						
					UPDATE	#DEPARTMENT_LEFT_DETAILS 
					SET		Count_Emp =ISNULL(T1.Count_Emp,0)
					FROM	  
					(
						select COUNT(L.Emp_ID)COUNT_EMP,DEPT_NAME
						from T0100_LEFT_EMP L WITH (NOLOCK) INNER JOIN 
						V0080_EMP_MASTER_INCREMENT_GET I on L.Emp_ID=I.Emp_ID 
					where L.Cmp_ID=@CMP_ID and L.Left_Date BETWEEN @from_date AND @to_date group by DEPT_NAME
					) AS T1 WHERE T1.DEPT_NAME= #DEPARTMENT_LEFT_DETAILS.DEPT_NAME
						
					SELECT * FROM #DEPARTMENT_LEFT_DETAILS 	
					SELECT Dept_Name as [Department],Count_Emp as[No. of Employees Left] FROM #DEPARTMENT_LEFT_DETAILS 		
			END
		ELSE IF @FLAG='Grade Wise' 
				BEGIN
					CREATE table #GRADE_LEFT_DETAILS
					(   					
						Grade_Name VARCHAR(500),					
						Count_Emp numeric				
					)
		
					INSERT INTO #GRADE_LEFT_DETAILS
					SELECT DISTINCT I.Grd_Name,0					
					from T0100_LEFT_EMP L WITH (NOLOCK) INNER JOIN
					V0080_EMP_MASTER_INCREMENT_GET I on L.Emp_ID=I.Emp_ID 
					where L.Cmp_ID=@CMP_ID and ISNULL(I.Grd_Name,'') <>''						
						
					UPDATE	#GRADE_LEFT_DETAILS 
					SET		Count_Emp =ISNULL(T1.Count_Emp,0)
					FROM	  
					(
						select COUNT(L.Emp_ID)COUNT_EMP,I.Grd_Name
						from T0100_LEFT_EMP L WITH (NOLOCK) INNER JOIN 
						V0080_EMP_MASTER_INCREMENT_GET I on L.Emp_ID=I.Emp_ID 
					where L.Cmp_ID=@CMP_ID and L.Left_Date BETWEEN @from_date AND @to_date group by I.Grd_Name
					) AS T1 WHERE T1.Grd_Name= #GRADE_LEFT_DETAILS.Grade_Name
						
					SELECT * FROM #GRADE_LEFT_DETAILS 	
					SELECT Grade_Name as [Grade],Count_Emp as[No. of Employees Left] FROM #GRADE_LEFT_DETAILS 				
			END
		END
	ELSE IF @ReportType=2
		BEGIN			
			--SELECT * FROM T0200_Exit_Feedback
				SELECT T1.*,'Q'+ cast(ROW_NUMBER() OVER(ORDER BY T1.Sorting_No) as VARCHAR(10)) AS Row_Id	
					INTO #Exit_Question			
				FROM
					(SELECT DISTINCT QA.Quest_ID,QA.Question,QA.Sorting_No							
					 FROM	T0200_Exit_Feedback EF WITH (NOLOCK)	
							INNER JOIN T0200_Question_Exit_Analysis_Master QA WITH (NOLOCK) ON QA.Quest_ID=EF.question_id				
							INNER JOIN T0200_Emp_ExitApplication EA WITH (NOLOCK) ON EA.exit_id=EF.exit_id
					 WHERE	QA.Group_Id=@Group_Id and EA.[status]='A' AND EA.cmp_id=@CMP_ID AND 
							EA.last_date BETWEEN @FROM_DATE AND @TO_DATE 
					)AS T1 
				ORDER by t1.Sorting_No
					--and ISNULL(IC.Dept_Name,'') <> ''
				
				
				select DISTINCT ER.Title,T.Question,T.Quest_ID,T.Row_Id,0 Count_Emp,ER.Rating_Id,Rating				
				INTO #EXIT_FEEDABCK
				FROM	T0200_Exit_Feedback EF WITH (NOLOCK)
				INNER JOIN T0040_Exit_Analysis_rating ER WITH (NOLOCK) ON EF.Answer_rate=ER.Rating_Id
				INNER JOIN T0200_Emp_ExitApplication EA WITH (NOLOCK) ON EA.exit_id=EF.exit_id
				CROSS JOIN (SELECT * FROM #Exit_Question) T
				WHERE EA.last_date BETWEEN @FROM_DATE AND @TO_DATE AND EA.cmp_id=@CMP_ID and EA.[status]='A'
				
				
				UPDATE	#EXIT_FEEDABCK 
				SET		Count_Emp =ISNULL(T1.Count_Emp,0)
				FROM	  
				(
							SELECT	COUNT(EF.emp_id)Count_Emp,EF.Answer_rate,EF.question_id
							FROM	T0200_Exit_Feedback EF WITH (NOLOCK)		
							INNER JOIN T0200_Emp_ExitApplication EA WITH (NOLOCK) ON EA.exit_id=EF.exit_id				
							WHERE EA.last_date BETWEEN @FROM_DATE AND @TO_DATE and EF.Is_Draft=0
							AND EA.CMP_ID = @CMP_ID and EF.Answer_rate >0 and EA.[status]='A' 
							GROUP BY EF.Answer_rate,EF.question_id
							) AS T1 WHERE  T1.question_id = #EXIT_FEEDABCK.Quest_ID
							 AND T1.Answer_rate=#EXIT_FEEDABCK.Rating_Id --AND T1.Grd_ID=#EXIT_FEEDABCK.Grd_ID
							--T1.last_date BETWEEN @FROM_DATE AND @TO_DATE AND
							--T1.Ex_Month = #Exit_Details.EXIT_MONTH AND T1.Ex_Year = #Exit_Details.EXIT_YEAR 
							
				SELECT  DISTINCT * FROM #EXIT_FEEDABCK ORDER BY Row_Id,rating
				
				SELECT @columns = COALESCE(@columns + ',[' + CAST(TITLE AS VARCHAR(1000)) + ']',
					'[' + CAST(TITLE AS VARCHAR(1000))+ ']')
				FROM (SELECT ROW_NUMBER() OVER(ORDER BY RATING_ID) AS ROW_ID,TITLE
					FROM	#EXIT_FEEDABCK GROUP BY RATING_ID,TITLE)T					
				--PRINT @columns			
				--RETURN
				SET @query = 'SELECT Row_ID as[Short Code],Question,'+ @columns +'										
									FROM (
										SELECT Question,ISNULL(Count_Emp,0)Count_Emp,TITLE,Row_ID
										FROM #EXIT_FEEDABCK EC 																																																																
										) as s
									PIVOT	
									(				 
										MAX(Count_Emp)	
										FOR [TITLE] IN (' + @columns + ')  														 				
									)AS T order by Row_ID'
						--print @query
						EXEC(@query)
						
			SELECT row_id as [Short Code],Question FROM #Exit_Question	
		END
END

--IF @PBranch_ID = '0' or @PBranch_ID='' 
	--	set @PBranch_ID = null   	
		
	--if @PVertical_ID ='0' or @PVertical_ID = ''		
	--	set @PVertical_ID = null
	
	--if @PsubVertical_ID ='0' or @PsubVertical_ID = ''
	--	set @PsubVertical_ID = null
		
		
	--IF @PDept_ID = '0' or @PDept_Id='' 
	--	set @PDept_ID = NULL	 	
	

	--if @PBranch_ID is null
	--Begin	
	--	select   @PBranch_ID = COALESCE(@PBranch_ID + ',', '') + cast(Branch_ID as nvarchar(5))  from T0030_BRANCH_MASTER where Cmp_ID=@Cmp_ID 
	--	set @PBranch_ID = @PBranch_ID + ',0'
	--End
	
	--if @PVertical_ID is null
	--Begin	
	--print @PVertical_ID
	--	select   @PVertical_ID = COALESCE(@PVertical_ID + ',', '') + cast(Vertical_ID as nvarchar(5))  from T0040_Vertical_Segment where Cmp_ID=@Cmp_ID 
		
	--	If @PVertical_ID IS NULL
	--		set @PVertical_ID = '0'
				
	--	else
	--		set @PVertical_ID = @PVertical_ID + ',0'
		
	--End
	--if @PsubVertical_ID is null
	--Begin	
	--	select   @PsubVertical_ID = COALESCE(@PsubVertical_ID + ',', '') + cast(subVertical_ID as nvarchar(5))  from T0050_SubVertical where Cmp_ID=@Cmp_ID 
	--	If @PsubVertical_ID IS NULL
	--		set @PsubVertical_ID = '0';
	--	else
	--		set @PsubVertical_ID = @PsubVertical_ID + ',0'
	--End
	--IF @PDept_ID is null
	--Begin
	--	select   @PDept_ID = COALESCE(@PDept_ID + ',', '') + cast(Dept_ID as nvarchar(5))  from T0040_DEPARTMENT_MASTER where Cmp_ID=@Cmp_ID 		
	--	if @PDept_ID is null
	--		set @PDept_ID = '0';
	--	else
	--		set @PDept_ID = @PDept_ID + ',0'
	--End	
--INSERT INTO #Exit_Details
			--SELECT   DateName( month , DateAdd( month , monthid , -1 )) Name,monthid,'',0 from(  
			--SELECT  Month(DATEADD(MONTH, x.number, @From_Date)) AS MonthId  
			--FROM    master.dbo.spt_values x  
			--WHERE   x.type = 'P'          
			--AND     x.number <= DATEDIFF(MONTH, @From_Date, @to_Date)  
			--) A  
				
				
			--SELECT DATENAME(month ,last_date)
			--from T0200_Emp_ExitApplication 
			-- ORDER BY { fn MONTH(last_date) }, YEAR(last_date)
			
			--SET @FROM_DATE = DBO.GET_YEAR_START_DATE(CAST(@MONTH_YEAR AS NUMERIC),1,1)
			--SET @TO_DATE  =  DBO.GET_YEAR_END_DATE(CAST(@MONTH_YEAR AS NUMERIC),12,1)	
	--SELECT  COUNT(EA.emp_id)Count_Emp,RM.Reason_Name,DATENAME(month ,last_date)Month_Name,month(last_date)Month--,EA.last_date--,CONVERT(VARCHAR(3), DATENAME(MM,ea.last_date), 100)name
			--	INTO #Exit_Reason_Details
			--FROM T0200_Emp_ExitApplication EA					
			--		inner join T0080_EMP_MASTER EC on EA.emp_id=EC.Emp_ID 
			--		INNER JOIN T0040_Reason_Master RM ON RM.Res_Id=EA.reason 						
			--WHERE EA.cmp_id=55 --and EA.[status]='A' 			
			--GROUP BY RM.Reason_Name,DATENAME(month ,last_date),month(last_date)--,EA.last_date
			--ORDER BY month(last_date)--, YEAR(last_date)
			
			--SELECT * FROM #Exit_Details 	
			--UPDATE #Exit_Details SET Reason_name=EA.Reason_Name,Count_Emp=EA.Count_Emp
			--	FROM (select COUNT(EA.emp_id)Count_Emp,RM.Reason_Name,MONTH(EA.last_date)month_name 
			--		from T0200_Emp_ExitApplication)EA
			--		inner join T0080_EMP_MASTER EC on EA.emp_id=EC.Emp_ID 
			--		INNER JOIN T0040_Reason_Master RM ON RM.Res_Id=EA.reason 
			--		--inner join t0010_company_master cm on cm.cmp_id=ea.cmp_id			
			--	where EA.cmp_id=55 --and EA.[status]='A' 			
			--	GROUP BY RM.Reason_Name,MONTH(EA.last_date))EA		 
			--WHERE Month_ID=ea.month_name
