-- =============================================
-- Author:		Binal Prajapati
-- Create date: 25082020
-- Description:	This sp used for salary dashboard at admin side for getting epmoyee details for total count
-- =============================================

CREATE PROCEDURE [dbo].[SP_Employee_Salary_Dashboard_Details]
	@Cmp_ID Numeric(18,2),
	@From_Date DateTime,
	@To_Date DateTime,
	@GroupType varchar(25)='Department'
	,@PrivilegeID int =0 --Added by ronakk 19122023
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    CREATE TABLE #EMP_CONS 
	(      
		EMP_ID NUMERIC ,     
		BRANCH_ID NUMERIC,
		INCREMENT_ID NUMERIC
	)	
	--EXEC SP_RPT_FILL_EMP_CONS @Cmp_ID,@From_Date,@To_Date,0,0,0,0,0,0,0,'',0,0,0,0,0,0,0,0,0,0,0,0  
	
	--EXEC SP_RPT_FILL_EMP_CONS @Cmp_ID,@From_Date,@To_Date,0,0,0,0,0,0,0,'',0,0,0,0,0,0,0,0,0,0,0,0   

	--Added by ronakk 19122023
	Declare @BranchMulti nvarchar(max)
	Declare @VerticalMulti nvarchar(max)
	Declare @SubvertMulti nvarchar(max)
	Declare @DeptMulti nvarchar(max)

	select @BranchMulti = Branch_Id_Multi
		  ,@VerticalMulti = Vertical_ID_Multi
		  ,@SubvertMulti = SubVertical_ID_Multi
		  ,@DeptMulti = Department_Id_Multi
   
   from T0020_PRIVILEGE_MASTER where Privilege_ID = @PrivilegeID

	--End by ronakk 19122023

	exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@BranchMulti,0,0,0,@DeptMulti,0,0,'',0,0,0,@VerticalMulti,@SubvertMulti,0,0,0,0,'0',0,0,0   

  



	CREATE TABLE #Final_Table
		(
			Title_ID NUMERIC(18,0),
			Title VARCHAR(500),
			Total_Emp NUMERIC(18,0),
			Process_Emp	NUMERIC(18,0),
			Hold_Emp NUMERIC(18,0),
			Pending_Emp NUMERIC(18,0),
			Total_Amount_Paid NUMERIC(18,2)
		)
		
		If @GroupType = 'department'
			BEGIN
				INSERT INTO #Final_Table (Title_ID,Title)
				SELECT Dept_ID,Dept_Name FROM T0040_DEPARTMENT_MASTER WITH(NOLOCK) WHERE Cmp_id = @Cmp_ID
			END
		ELSE
			BEGIN
				INSERT INTO #Final_Table (Title_ID,Title)
				SELECT Branch_ID,Branch_Name FROM T0030_BRANCH_MASTER WITH(NOLOCK) WHERE Cmp_id = @Cmp_ID
			END
		
		
		SELECT	Count (E.EMP_ID) as Emp_Count,
				CASE WHEN @GroupType = 'department' THEN D.Dept_Name ELSE B.Branch_Name END as Title,
				CASE WHEN @GroupType = 'department' THEN D.Dept_ID ELSE B.Branch_ID END as Title_ID,
				'Total' as ColSatus
		INTO #t1
		FROM	#EMP_CONS E WITH(NOLOCK)
				INNER JOIN T0095_INCREMENT I WITH(NOLOCK) ON E.INCREMENT_ID = I.Increment_ID and E.Emp_ID = I.Emp_ID
				LEFT JOIN T0040_DEPARTMENT_MASTER D WITH(NOLOCK) ON I.Dept_ID = D.Dept_Id
				LEFT JOIN T0030_BRANCH_MASTER  B WITH(NOLOCK) ON I.Branch_ID = B.Branch_ID
		GROUP BY CASE WHEN @GroupType = 'department' THEN D.Dept_Name ELSE B.Branch_Name END,
					CASE WHEN @GroupType = 'department' THEN D.Dept_ID ELSE B.Branch_ID END
		
		
		SELECT	Count (M.EMP_ID) as Emp_Count,
				CASE WHEN @GroupType = 'department' THEN D.Dept_Name ELSE B.Branch_Name END as Title,
				CASE WHEN @GroupType = 'department' THEN D.Dept_ID ELSE B.Branch_ID END as Title_ID,
				'Processed' as ColSatus
		INTO #t2
		FROM	#EMP_CONS E WITH(NOLOCK)
				INNER JOIN T0095_INCREMENT I WITH(NOLOCK) ON E.INCREMENT_ID = I.Increment_ID and E.Emp_ID = I.Emp_ID
				INNER JOIN T0200_MONTHLY_SALARY  M WITH(NOLOCK) ON E.EMP_ID = M.Emp_ID
				LEFT JOIN T0040_DEPARTMENT_MASTER D WITH(NOLOCK) ON I.Dept_ID = D.Dept_Id
				LEFT JOIN T0030_BRANCH_MASTER  B WITH(NOLOCK) ON I.Branch_ID = B.Branch_ID
		WHERE	M.Month_END_Date BETWEEN @From_Date AND @To_Date AND M.Salary_Status = 'Done'
		GROUP BY CASE WHEN @GroupType = 'department' THEN D.Dept_Name ELSE B.Branch_Name END,
					CASE WHEN @GroupType = 'department' THEN D.Dept_ID ELSE B.Branch_ID END
		

		SELECT	Count (M.EMP_ID) as Emp_Count,
				CASE WHEN @GroupType = 'department' THEN D.Dept_Name ELSE B.Branch_Name END as Title,
				CASE WHEN @GroupType = 'department' THEN D.Dept_ID ELSE B.Branch_ID END as Title_ID,
				'Hold' as ColSatus
		INTO #t3
		FROM	#EMP_CONS E
				INNER JOIN T0095_INCREMENT I WITH(NOLOCK) ON E.INCREMENT_ID = I.Increment_ID and E.Emp_ID = I.Emp_ID
				INNER JOIN T0200_MONTHLY_SALARY  M WITH(NOLOCK) ON E.EMP_ID = M.Emp_ID
				LEFT JOIN T0040_DEPARTMENT_MASTER D WITH(NOLOCK) ON I.Dept_ID = D.Dept_Id
				LEFT JOIN T0030_BRANCH_MASTER  B WITH(NOLOCK) ON I.Branch_ID = B.Branch_ID
		WHERE	M.Month_END_Date BETWEEN @From_Date AND @To_Date AND M.Salary_Status = 'Hold'
		GROUP BY CASE WHEN @GroupType = 'department' THEN D.Dept_Name ELSE B.Branch_Name END,
					CASE WHEN @GroupType = 'department' THEN D.Dept_ID ELSE B.Branch_ID END
		
		

		SELECT	Count (E.EMP_ID) as Emp_Count,
				CASE WHEN @GroupType = 'department' THEN D.Dept_Name ELSE B.Branch_Name END as Title,
				CASE WHEN @GroupType = 'department' THEN D.Dept_ID ELSE B.Branch_ID END as Title_ID,
				'Pending' as ColSatus
		INTO #t4
		FROM	#EMP_CONS E WITH(NOLOCK)
				INNER JOIN T0095_INCREMENT I WITH(NOLOCK) ON E.INCREMENT_ID = I.Increment_ID and E.Emp_ID = I.Emp_ID
				LEFT JOIN T0040_DEPARTMENT_MASTER D WITH(NOLOCK) ON I.Dept_ID = D.Dept_Id
				LEFT JOIN T0030_BRANCH_MASTER  B WITH(NOLOCK) ON I.Branch_ID = B.Branch_ID
		WHERE	E.Emp_ID not in (
									SELECT EMP_ID 
									FROM T0200_MONTHLY_SALARY MS WITH(NOLOCK)
									WHERE MS.Month_END_Date BETWEEN @From_Date AND @To_Date AND Cmp_id = @Cmp_ID
								)
		GROUP BY CASE WHEN @GroupType = 'department' THEN D.Dept_Name ELSE B.Branch_Name END,
					CASE WHEN @GroupType = 'department' THEN D.Dept_ID ELSE B.Branch_ID END


		SELECT	SUM (MS1.Net_Amount) as Emp_Count,
				CASE WHEN @GroupType = 'department' THEN D.Dept_Name ELSE B.Branch_Name END as Title,
				CASE WHEN @GroupType = 'department' THEN D.Dept_ID ELSE B.Branch_ID END as Title_ID,
				'Total_Amount_Paid' as ColSatus
		INTO #t5
		FROM	#EMP_CONS E WITH(NOLOCK)
				INNER JOIN T0095_INCREMENT I WITH(NOLOCK) ON E.INCREMENT_ID = I.Increment_ID and E.Emp_ID = I.Emp_ID
				INNER JOIN T0200_MONTHLY_SALARY MS1 WITH(NOLOCK) ON MS1.Emp_ID=E.EMP_ID
				LEFT JOIN T0040_DEPARTMENT_MASTER D WITH(NOLOCK) ON I.Dept_ID = D.Dept_Id
				LEFT JOIN T0030_BRANCH_MASTER  B WITH(NOLOCK) ON I.Branch_ID = B.Branch_ID
		WHERE	MS1.Month_End_Date BETWEEN @From_Date AND @To_Date AND MS1.Cmp_ID=@Cmp_ID
		GROUP BY CASE WHEN @GroupType = 'department' THEN D.Dept_Name ELSE B.Branch_Name END,
					CASE WHEN @GroupType = 'department' THEN D.Dept_ID ELSE B.Branch_ID END

									
		UPDATE	F
		SET		Total_Emp = isNull(t.Emp_Count,0)
		FROM	#Final_Table F
				LEFT JOIN #t1 t on t.Title_ID = f.Title_ID
		
		UPDATE	F
		SET		Process_Emp = isNull(t.Emp_Count,0)
		FROM	#Final_Table F
				LEFT JOIN #t2 t on t.Title_ID = f.Title_ID

		UPDATE	F
		SET		Hold_Emp = isNull(t.Emp_Count,0)
		FROM	#Final_Table F
				LEFT JOIN #t3 t on t.Title_ID = f.Title_ID

		UPDATE	F
		SET		Pending_Emp = isNull(t.Emp_Count,0)
		FROM	#Final_Table F
				LEFT JOIN #t4 t on t.Title_ID = f.Title_ID

		UPDATE	F
		SET		Total_Amount_Paid = isNull(t.Emp_Count,0)
		FROM	#Final_Table F
				LEFT JOIN #t5 t on t.Title_ID = f.Title_ID


				
	
		SELECT * FROM #Final_Table
END
