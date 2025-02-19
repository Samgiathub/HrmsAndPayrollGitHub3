


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P_RPT_EMP_PROBATION_DETAILS_CONFIRMATION_LIST]
	 @Cmp_Id		NUMERIC  
	,@From_Date		DATETIME
	,@To_Date 		DATETIME
	,@Branch_ID		VARCHAR(MAX) = ''	
	,@Cat_ID		varchar(Max)
	,@Grd_ID		varchar(Max) 
	,@Type_ID		varchar(Max) 
	,@Dept_ID		varchar(Max) 
	,@Desig_ID		varchar(Max) 
	,@Emp_ID		numeric  = 0
	,@Constraint	varchar(max) = ''
	,@New_Join_emp	numeric = 0 
	,@Left_Emp		Numeric = 0
	,@Salary_Cycle_id numeric = NULL
	,@Segment_Id  varchar(Max) = ''	
	,@Vertical_Id varchar(Max) = ''	 
	,@SubVertical_Id varchar(Max) = ''	
	,@SubBranch_Id varchar(Max) = ''
	,@Report_Type	VARCHAR(30) = 'Probation'
	,@Format		VARCHAR(30) = 'DueList'
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	
	--IF ISNULL(@Report_Type,'') = 'ALL' OR @Report_Type = ''
	--	SET @Report_Type = NULL

	CREATE TABLE #Emp_Cons 
	 (      
	   Emp_ID		NUMERIC ,     
	   Branch_ID	NUMERIC,
	   Increment_ID NUMERIC    
	  )            
    
	--EXEC SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,0,0,0,0,0,@Emp_ID,@constraint,0,0,'','','','',0,0,0,'0',0,0               
	exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,@Salary_Cycle_id,@Segment_Id,@Vertical_Id,@SubVertical_Id,@SubBranch_Id,@New_Join_emp,@Left_Emp,0,'',0,0    
	
	--if @Report_Type = 'ALL'
		--SET @Report_Type = NULL
	IF @Format = 'DueList'
		BEGIN
			
			--SELECT --1
			--	ROW_NUMBER() over(order by EP.Emp_ID ) AS Sr_No,
			--	EP.Emp_ID,EP.Cmp_ID,I.Branch_ID,'="' + E.Alpha_Emp_Code + '"'  as Alpha_Emp_Code , E.Emp_Full_Name,B.Branch_Name,D.Desig_Name,DM.Dept_Name,T.Type_Name,CONVERT(VARCHAR(10),e.Date_Of_Join,103) AS Date_Of_Join,EP.Flag,CONVERT(VARCHAR(10),EP.Old_Probation_EndDate,103) AS Probation_End_Date,CONVERT(VARCHAR(10),EP.New_Probation_EndDate,103) AS Extended_Date, '' AS Remarks 
			--FROM dbo.T0095_EMP_PROBATION_MASTER EP	INNER JOIN
			--	#Emp_Cons EC ON EP.Emp_ID = EC.Emp_ID INNER JOIN
			--	dbo.T0080_EMP_MASTER E ON EP.Emp_ID = E.Emp_ID INNER JOIN
			--	dbo.T0095_INCREMENT I ON EC.Increment_ID = I.Increment_ID INNER JOIN
			--	dbo.T0030_BRANCH_MASTER B ON B.Branch_ID = I.Branch_ID INNER JOIN
			--	dbo.T0040_DESIGNATION_MASTER D ON D.Desig_ID = I.Desig_Id INNER JOIN
			--	dbo.T0040_GRADE_MASTER G ON G.Grd_ID = I.Grd_ID LEFT OUTER JOIN
			--	dbo.T0040_DEPARTMENT_MASTER DM On DM.Dept_Id = I.Dept_ID LEFT OUTER JOIN
			--	dbo.T0040_TYPE_MASTER T ON T.Type_ID = I.Type_ID
			--WHERE EP.Cmp_ID = @Cmp_ID AND EP.Probation_Status <>  0
			--	AND EP.New_Probation_EndDate BETWEEN @From_Date AND @To_Date	
			--	AND EP.Flag = ISNULL(@Report_Type,EP.Flag)
			
			--added By jimit 19092016
			CREATE TABLE #Emp_Trainee_Probation
			(
				--Sr_No  NUMERIC, 
				Emp_Id NUMERIC,
				cmp_Id	NUMERIC,
				Branch_Id	NUMERIC,
				Alpha_Emp_Code VARCHAR(20),
				Emp_Full_Name VARCHAR(150),
				Branch_Name VARCHAR(100),
				Desig_Name VARCHAR(100),
				Dept_Name VARCHAR(100),
				Type_Name VARCHAR(100),
				Date_Of_Join VARCHAR(50),
				Flag VARCHAR(50),
				Probation_End_Date VARCHAR(50),
				Extended_Date VARCHAR(50),
				Remarks VARCHAR(250),
				Review_type VARCHAR(25)
			)
			
			--CREATE NONCLUSTERED INDEX IX_Emp_Trainee_Probation ON #Emp_Trainee_Probation(Sr_No,EMP_ID)

			--ended
			
			IF (@Report_Type = 'Probation' or @Report_Type = 'ALL')
				begin
				
					INSERT Into #Emp_Trainee_Probation					
					SELECT 						
						EP.Emp_ID,EP.Cmp_ID,I.Branch_ID,'="' + E.Alpha_Emp_Code + '"'  as Alpha_Emp_Code , E.Emp_Full_Name,B.Branch_Name,D.Desig_Name,DM.Dept_Name,
						T.Type_Name,CONVERT(VARCHAR(10),e.Date_Of_Join,103) AS Date_Of_Join,EP.Flag,CONVERT(VARCHAR(10),EP.probation_date,103) AS Probation_End_Date,
						CONVERT(VARCHAR(10),EP.New_Probation_EndDate,103) AS Extended_Date, '' AS Remarks,EP.Probation_Review as [Review_Type] 
					FROM dbo.V0080_EMP_PROBATION_GET EP	INNER JOIN
						#Emp_Cons EC ON EP.Emp_ID = EC.Emp_ID INNER JOIN
						dbo.T0080_EMP_MASTER E WITH (NOLOCK) ON EP.Emp_ID = E.Emp_ID INNER JOIN
						dbo.T0095_INCREMENT I WITH (NOLOCK) ON EC.Increment_ID = I.Increment_ID INNER JOIN
						dbo.T0030_BRANCH_MASTER B WITH (NOLOCK) ON B.Branch_ID = I.Branch_ID INNER JOIN
						dbo.T0040_DESIGNATION_MASTER D WITH (NOLOCK) ON D.Desig_ID = I.Desig_Id INNER JOIN
						dbo.T0040_GRADE_MASTER G WITH (NOLOCK) ON G.Grd_ID = I.Grd_ID LEFT OUTER JOIN
						dbo.T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) On DM.Dept_Id = I.Dept_ID LEFT OUTER JOIN
						dbo.T0040_TYPE_MASTER T WITH (NOLOCK) ON T.Type_ID = I.Type_ID
					WHERE EP.Cmp_ID = @Cmp_ID
						AND EP.probation_date BETWEEN @From_Date AND @To_Date
						--AND EP.Flag = ISNULL(@Report_Type,EP.Flag)	
						AND Ep.Flag = (case when @Report_Type = 'Probation' then @Report_Type else Ep.Flag END)
				end
			If (@Report_Type = 'Trainee' or @Report_Type = 'ALL')
				BEGIN	
				
					INSERT Into #Emp_Trainee_Probation			
					SELECT --1						
						EP.Emp_ID,EP.Cmp_ID,I.Branch_ID,'="' + E.Alpha_Emp_Code + '"'  as Alpha_Emp_Code , E.Emp_Full_Name,B.Branch_Name,D.Desig_Name,DM.Dept_Name,
						T.Type_Name,CONVERT(VARCHAR(10),e.Date_Of_Join,103) AS Date_Of_Join,EP.Flag,CONVERT(VARCHAR(10),EP.probation_date,103) AS Probation_End_Date,
						CONVERT(VARCHAR(10),EP.New_Probation_EndDate,103) AS Extended_Date, '' AS Remarks,EP.Trainee_Review as [Review_Type]
					FROM dbo.V0080_EMP_TRAINEE_GET EP	
						INNER JOIN #Emp_Cons EC ON EP.Emp_ID = EC.Emp_ID 
						INNER JOIN dbo.T0080_EMP_MASTER E WITH (NOLOCK) ON EP.Emp_ID = E.Emp_ID 
						INNER JOIN dbo.T0095_INCREMENT I WITH (NOLOCK) ON EC.Increment_ID = I.Increment_ID 
						INNER JOIN dbo.T0030_BRANCH_MASTER B WITH (NOLOCK) ON B.Branch_ID = I.Branch_ID 
						INNER JOIN dbo.T0040_DESIGNATION_MASTER D WITH (NOLOCK) ON D.Desig_ID = I.Desig_Id 
						INNER JOIN dbo.T0040_GRADE_MASTER G WITH (NOLOCK) ON G.Grd_ID = I.Grd_ID 
						LEFT OUTER JOIN dbo.T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) On DM.Dept_Id = I.Dept_ID 
						LEFT OUTER JOIN dbo.T0040_TYPE_MASTER T WITH (NOLOCK) ON T.Type_ID = I.Type_ID
					WHERE EP.Cmp_ID = @Cmp_ID 
						AND EP.probation_date BETWEEN @From_Date AND @To_Date	
						--AND EP.Flag = ISNULL(@Report_Type,EP.Flag)
						AND Ep.Flag = (case when @Report_Type = 'Trainee' then @Report_Type else Ep.Flag END)
				END
				--ROW_NUMBER() OVER(ORDER BY Tran_ID)
				SELECT * from #Emp_Trainee_Probation
				drop TABLE #Emp_Trainee_Probation
				
		END
			
	IF @Format = 'Confirmation'
		BEGIN
			CREATE TABLE #Emp_Cons_1
			 (      
			   Emp_ID		NUMERIC,     
			   Increment_ID NUMERIC
			  )
			   
			  INSERT INTO #Emp_Cons_1
			 -- SELECT EC.Emp_ID,EC.Increment_ID,EM.Emp_Confirm_Date 
			 -- FROM #Emp_Cons EC INNER JOIN
			 -- T0080_EMP_MASTER EM ON EC.Emp_ID = EM.Emp_ID 
			 -- UNION ALL
			  
			  SELECT I1.EMP_ID, I1.INCREMENT_ID
			  FROM	T0095_INCREMENT I1 WITH (NOLOCK) INNER JOIN #Emp_Cons E1 ON I1.Emp_ID=E1.EMP_ID
					INNER JOIN ( SELECT	MAX(I2.Increment_ID) AS Increment_ID, I2.Emp_ID
								 FROM T0095_INCREMENT I2 WITH (NOLOCK) INNER JOIN #Emp_Cons E2 ON I2.Emp_ID=E2.EMP_ID
								  INNER JOIN ( SELECT MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
											   FROM	T0095_INCREMENT I3 WITH (NOLOCK) INNER JOIN #Emp_Cons E3 ON I3.Emp_ID=E3.EMP_ID
											   WHERE	I3.Increment_Effective_Date <= @To_Date AND I3.Increment_ID < E3.Increment_ID GROUP BY I3.Emp_ID
											 ) I3 ON I2.Increment_Effective_Date=I3.INCREMENT_EFFECTIVE_DATE AND I2.Emp_ID=I3.Emp_ID																		
								 WHERE	I2.Cmp_ID = @Cmp_Id AND I2.Increment_ID < E2.Increment_ID
								 GROUP BY I2.Emp_ID
								) I2 ON I1.Emp_ID=I2.Emp_ID AND I1.Increment_ID=I2.INCREMENT_ID	
				WHERE	I1.Cmp_ID=@Cmp_Id	
			
				SELECT --1
					ROW_NUMBER() over(order by EP.Emp_ID ) AS Sr_No,
					EP.Emp_ID,EP.Cmp_ID,I.Branch_ID,'="' + E.Alpha_Emp_Code + '"'  as Alpha_Emp_Code , E.Emp_Full_Name,EP.Flag,
					B1.Branch_Name AS Old_Branch, B.Branch_Name AS New_Branch, D1.Desig_Name AS Old_Designation,D.Desig_Name AS New_Designation,
					DM1.Dept_Name AS Old_Department,DM.Dept_Name AS New_Department,T1.Type_Name AS Old_Type, T.Type_Name AS New_Type,
					CONVERT(VARCHAR(10),e.Date_Of_Join,103) AS Date_Of_Join,CONVERT(VARCHAR(10),EP.Old_Probation_EndDate,103) AS Confirmation_Due_Date ,
					CONVERT(VARCHAR(10),EP.New_Probation_EndDate,103) AS Extended_Date,
					CASE WHEN EP.Probation_Status = 0 THEN CONVERT(VARCHAR(10),E.Emp_Confirm_Date,103) ELSE '' END AS Confirmation_Date, '' AS Remarks,
					EP.Review_Type					
				FROM dbo.T0095_EMP_PROBATION_MASTER EP WITH (NOLOCK)	INNER JOIN
					#Emp_Cons EC ON EP.Emp_ID = EC.Emp_ID INNER JOIN
					dbo.T0080_EMP_MASTER E WITH (NOLOCK) ON EP.Emp_ID = E.Emp_ID INNER JOIN
					dbo.T0095_INCREMENT I WITH (NOLOCK) ON EC.Increment_ID = I.Increment_ID INNER JOIN
					dbo.T0030_BRANCH_MASTER B WITH (NOLOCK) ON B.Branch_ID = I.Branch_ID INNER JOIN
					dbo.T0040_DESIGNATION_MASTER D WITH (NOLOCK) ON D.Desig_ID = I.Desig_Id INNER JOIN
					dbo.T0040_GRADE_MASTER G WITH (NOLOCK) ON G.Grd_ID = I.Grd_ID LEFT OUTER JOIN
					dbo.T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) On DM.Dept_Id = I.Dept_ID LEFT OUTER JOIN
					dbo.T0040_TYPE_MASTER T WITH (NOLOCK) ON T.Type_ID = I.Type_ID
					
					INNER JOIN
					#Emp_Cons_1 EC1 ON EP.Emp_ID = EC1.Emp_ID INNER JOIN
					dbo.T0095_INCREMENT I1 WITH (NOLOCK) ON EC1.Increment_ID = I1.Increment_ID INNER JOIN
					dbo.T0030_BRANCH_MASTER B1 WITH (NOLOCK) ON B1.Branch_ID = I1.Branch_ID INNER JOIN
					dbo.T0040_DESIGNATION_MASTER D1 WITH (NOLOCK) ON D1.Desig_ID = I1.Desig_Id INNER JOIN
					dbo.T0040_GRADE_MASTER G1 WITH (NOLOCK) ON G1.Grd_ID = I1.Grd_ID LEFT OUTER JOIN
					dbo.T0040_DEPARTMENT_MASTER DM1 WITH (NOLOCK) On DM1.Dept_Id = I1.Dept_ID LEFT OUTER JOIN
					dbo.T0040_TYPE_MASTER T1 WITH (NOLOCK) ON T1.Type_ID = I1.Type_ID
				WHERE EP.Cmp_ID = @Cmp_ID
					AND E.Emp_Confirm_Date BETWEEN @From_Date AND @To_Date	
					--AND EP.Flag = ISNULL(@Report_Type,EP.Flag) COMMENTED BY RAJPUT ON 29052018
					AND EP.FLAG = (CASE WHEN @REPORT_TYPE = 'ALL' THEN EP.FLAG ELSE @REPORT_TYPE END)
			 
		END
    
END

