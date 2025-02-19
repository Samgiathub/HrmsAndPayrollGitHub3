
-- =============================================
-- Author:		Binal Prajapati
-- Create date: 25082020
-- Description:	This sp used for salary dashboard at admin side
-- =============================================
CREATE PROCEDURE [dbo].[SP_Employee_Salary_Dashboard] 
	-- Add the parameters for the stored procedure here
	@Cmp_ID Numeric(18,2),
	@From_Date DateTime,
	@To_Date DateTime,
	@Branch_Id Varchar(max)='',
	@Department_ID Varchar(max)='',
	@Type varchar(25)='Main' --main means count data of salary etc else details of Employee 
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




	--EXEC SP_RPT_FILL_EMP_CONS @Cmp_ID,@From_Date,@To_Date,@Branch_Id,0,0,0,@Department_ID,0,0,'',0,0,0,0,0,0,0,0,0,0,0,0   
			
	--EXEC SP_RPT_FILL_EMP_CONS @CMP_ID,@FROM_DATE,@TO_DATE,@BRANCH_ID,@CAT_ID,@GRD_ID,@TYPE_ID,@DEPT_ID,@DESIG_ID,@EMP_ID,@CONSTRAINT,0,0,0,0,0,0,0,0,0,0,0,0   
	
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


   IF  RTRIM(LTRIM(LOWER(@Type)))='main' 
   BEGIN
   
			CREATE TABLE #SALARY_DASHBOARD 
			(
				Total_Employee Numeric(18,0) NULL,
				Processed Numeric(18,0) NULL,
				OnHold Numeric(18,0) NULL,
				Pending Numeric(18,0) NULL,
				Leave_Pending Numeric(18,0) NULL,
				Attendance_Pending Numeric(18,0) NULL,
				Last_First_Salary_Title Varchar(50) NULL,
				Last_First_Salary_Amount Varchar(50) NULL,
				Last_Second_Salary_Title Varchar(50) NULL,
				Last_Second_Salary_Amount Varchar(50) NULL,
				Last_Third_Salary_Title Varchar(50) NULL,
				Last_Third_Salary_Amount Varchar(50) NULL,
				PF_Eligible Numeric(18,0) NULL,
				PF_Non_Eligible Numeric(18,0) NULL,
				ESIC Numeric(18,0) NULL,
				Non_ESIC Numeric(18,0) NULL,
				PT Numeric(18,0) NULL,
				Fixed_Salary Numeric(18,0) NULL
			)
			
		
			DECLARE @Total_Emp AS NUMERIC(18,0)
			DECLARE @Total_Process_Emp AS NUMERIC(18,0)
			DECLARE @Total_Pending_Emp AS NUMERIC(18,0)
			DECLARE @Total_Hold_Emp AS NUMERIC(18,0)
			DECLARE	@StartDate AS DATETIME
			DECLARE	@EndDate AS DATETIME
			DECLARE @LastPaidMonthName AS VARCHAR(15)
			DECLARE @LastPaidAmount AS Numeric(18,2)
			DECLARE @Total_Emp_PF AS Numeric(18,2)
			DECLARE @Total_Emp_NON_PF AS Numeric(18,2)
			DECLARE @Total_Emp_ESIC AS Numeric(18,2)
			DECLARE @Total_Emp_NON_ESIC AS Numeric(18,2)
			DECLARE @Total_Emp_Fixed_Salary AS Numeric(18,2)
			DECLARE @Total_Emp_PT  AS Numeric(18,2)
			
			
			INSERT INTO #SALARY_DASHBOARD(Total_Employee)
			SELECT  COUNT(1) 
			FROM #EMP_CONS
			
			UPDATE #SALARY_DASHBOARD
			SET Processed=(SELECT	COUNT(EC.Emp_ID) 
						   FROM	    #EMP_CONS EC
									INNER JOIN T0200_MONTHLY_SALARY MS WITH(NOLOCK) ON EC.EMP_ID = MS.Emp_ID
						   WHERE	MS.Month_End_Date BETWEEN @From_Date AND @To_Date)
		    
			UPDATE #SALARY_DASHBOARD
			SET OnHold=(SELECT	COUNT(EC.Emp_ID) 
						 FROM	#EMP_CONS EC
								INNER JOIN T0200_MONTHLY_SALARY MS WITH(NOLOCK) ON EC.EMP_ID = MS.Emp_ID
						 WHERE	MS.Month_End_Date BETWEEN @From_Date AND @To_Date AND MS.Salary_Status = 'Hold')
		    
			SET @Total_Emp=(SELECT Total_Employee FROM #SALARY_DASHBOARD WITH(NOLOCK))
			SET @Total_Process_Emp=(SELECT Processed FROM #SALARY_DASHBOARD WITH(NOLOCK))
			SET @Total_Hold_Emp=(SELECT OnHold FROM #SALARY_DASHBOARD WITH(NOLOCK))
		    
			SET @Total_Pending_Emp = @Total_Emp - @Total_Process_Emp - @Total_Hold_Emp
		    
			UPDATE #SALARY_DASHBOARD
			SET Pending=@Total_Pending_Emp

			UPDATE #SALARY_DASHBOARD
			SET Attendance_Pending=(SELECT COUNT(IO_Tran_Id) 
						 FROM	View_Late_Emp  AR
						  inner join #EMP_CONS E on E.EMP_ID = AR.Emp_ID --Added by ronakk 20122023
						 WHERE	Cmp_id=@Cmp_ID And Chk_By_Superior = 0 
								AND For_Date BETWEEN @From_Date AND @To_Date)
			

			--Added by ronakk 20122023
			DECLARE @Emp_ID_String VARCHAR(max) 
			SELECT @Emp_ID_String = COALESCE(@Emp_ID_String + ', ', '') + cast(EMP_ID as varchar) 
			FROM #EMP_CONS

			CREATE TABLE #Pending_Leave_Emp_Count
			(	
				Emp_Count NUMERIC(18,0)
			)
			DECLARE @Qry AS VARCHAR(MAX) = N'(Application_Status = ''P'' or Application_Status = ''F'') And From_Date >= '''+CONVERT(varchar(10), @From_date, 111)+''' and To_Date <= '''+CONVERT(varchar(10), @To_date, 111)+''' and Emp_ID in ('+ @Emp_ID_String +') ' --Change by ronakk 20122023
		
			
			INSERT INTO #Pending_Leave_Emp_Count
			EXEC SP_Get_Leave_Application_Records @Cmp_ID=@Cmp_ID,@Emp_ID=0,@Rpt_level=0,@Constrains=@Qry,@Type = 2
			
			

			UPDATE #SALARY_DASHBOARD
			SET Leave_Pending=(SELECT * FROM #Pending_Leave_Emp_Count WITH(NOLOCK)) 

			SET @StartDate=( SELECT DATEADD(MONTH, DATEDIFF(MONTH, 0, DATEADD(MONTH, -3,@To_Date) )-1, 0) )
			SET @EndDate=(SELECT DATEADD(MONTH, -3, @To_Date))

			SET @LastPaidMonthName= Convert(char(3), @EndDate, 0) + '-' +CONVERT(Varchar(4), Year(@EndDate)) 
			SET @LastPaidAmount=(SELECT isnull(SUM(Net_Amount),0) FROM T0200_MONTHLY_SALARY MS WITH(NOLOCK) 
									inner join #EMP_CONS E on E.EMP_ID = MS.Emp_ID --Added by ronakk 20122023
									WHERE	Month(MS.Month_End_Date) = Month(@EndDate) And Year(MS.Month_End_Date) = Year(@EndDate) AND Cmp_ID=@Cmp_ID)
									--WHERE	MS.Month_End_Date BETWEEN @StartDate AND @EndDate AND Cmp_ID=@Cmp_ID)

			UPDATE #SALARY_DASHBOARD
			SET Last_First_Salary_Title=@LastPaidMonthName

			UPDATE #SALARY_DASHBOARD
			SET Last_First_Salary_Amount= @LastPaidAmount
			
			SET @StartDate=( SELECT DATEADD(MONTH, DATEDIFF(MONTH, 0, DATEADD(MONTH, -2,@To_Date) )-1, 0) )
			SET @EndDate=(SELECT DATEADD(MONTH, -2, @To_Date))

			SET @LastPaidMonthName= Convert(char(3), @EndDate, 0) + '-' +CONVERT(Varchar(4), Year(@EndDate)) 
			SET @LastPaidAmount=(SELECT  isnull(SUM(Net_Amount),0) FROM T0200_MONTHLY_SALARY MS WITH(NOLOCK) 
									inner join #EMP_CONS E on E.EMP_ID = MS.Emp_ID --Added by ronakk 20122023
									WHERE	Month(MS.Month_End_Date) = Month(@EndDate) And Year(MS.Month_End_Date) = Year(@EndDate) AND Cmp_ID=@Cmp_ID)
									--WHERE	MS.Month_End_Date BETWEEN @StartDate AND @EndDate AND Cmp_ID=@Cmp_ID)

			UPDATE #SALARY_DASHBOARD
			SET Last_Second_Salary_Title=@LastPaidMonthName

			UPDATE #SALARY_DASHBOARD
			SET Last_Second_Salary_Amount= @LastPaidAmount
			
			SET @StartDate=( SELECT DATEADD(MONTH, DATEDIFF(MONTH, 0, DATEADD(MONTH, -1,@To_Date) )-1, 0) )
			SET @EndDate=(SELECT DATEADD(MONTH, -1, @To_Date))

			SET @LastPaidMonthName= Convert(char(3), @EndDate, 0) + '-' +CONVERT(Varchar(4), Year(@EndDate)) 
			SET @LastPaidAmount=(SELECT isnull(SUM(Net_Amount),0) FROM T0200_MONTHLY_SALARY MS WITH(NOLOCK) 
									inner join #EMP_CONS E on E.EMP_ID = MS.Emp_ID --Added by ronakk 20122023
									WHERE	Month(MS.Month_End_Date) = Month(@EndDate) And Year(MS.Month_End_Date) = Year(@EndDate) AND Cmp_ID=@Cmp_ID)
									--WHERE	MS.Month_End_Date BETWEEN @StartDate AND @EndDate AND Cmp_ID=@Cmp_ID)

			UPDATE #SALARY_DASHBOARD
			SET Last_Third_Salary_Title=@LastPaidMonthName

			UPDATE #SALARY_DASHBOARD
			SET Last_Third_Salary_Amount= @LastPaidAmount
			

			--Start PF_Eligible  PF_Non_Eligible

			SET @Total_Emp_PF=( SELECT	 Count(1) 
								FROM	#EMP_CONS EC WITH(NOLOCK)
										INNER JOIN T0210_MONTHLY_AD_DETAIL ADM WITH(NOLOCK) ON  EC.EMP_ID=ADM.Emp_ID
										INNER JOIN T0050_AD_MASTER TAD WITH(NOLOCK) ON ADM.AD_ID=TAD.AD_ID
								WHERE TAD.Cmp_ID=@Cmp_ID AND TAD.AD_DEF_ID=2 
										AND ADM.To_date BETWEEN @From_Date AND @To_Date)
			SET @Total_Emp_NON_PF=@Total_Emp-@Total_Emp_PF

			UPDATE #SALARY_DASHBOARD
			SET PF_Eligible=@Total_Emp_PF

			UPDATE #SALARY_DASHBOARD
			SET PF_Non_Eligible= @Total_Emp_NON_PF

			--End PF_Eligible  PF_Non_Eligible
			
			--Start ESIC_Eligible  ESIC_Non_Eligible

			SET @Total_Emp_ESIC=(SELECT	 Count(1) 
								FROM	#EMP_CONS EC WITH(NOLOCK)
										INNER JOIN T0210_MONTHLY_AD_DETAIL ADM WITH(NOLOCK) ON  EC.EMP_ID=ADM.Emp_ID
										INNER JOIN T0050_AD_MASTER TAD WITH(NOLOCK) ON ADM.AD_ID=TAD.AD_ID
								WHERE TAD.Cmp_ID=@Cmp_ID AND TAD.AD_DEF_ID=3
										AND ADM.To_date BETWEEN @From_Date AND @To_Date)
			SET @Total_Emp_NON_ESIC=@Total_Emp-@Total_Emp_ESIC

			UPDATE #SALARY_DASHBOARD
			SET ESIC=@Total_Emp_ESIC

			UPDATE #SALARY_DASHBOARD
			SET Non_ESIC= @Total_Emp_NON_ESIC

			--End PF_Eligible  PF_Non_Eligible
			
			--Start PT Eligible

		


			--SET @Total_Emp_PT=(SELECT	 Count(1) 
			--					FROM	#EMP_CONS EC WITH(NOLOCK)
			--							INNER JOIN T0210_MONTHLY_AD_DETAIL ADM WITH(NOLOCK) ON  EC.EMP_ID=ADM.Emp_ID
			--							INNER JOIN T0050_AD_MASTER TAD WITH(NOLOCK) ON ADM.AD_ID=TAD.AD_ID
			--					WHERE TAD.Cmp_ID=@Cmp_ID AND TAD.AD_DEF_ID=9
			--							AND ADM.To_date BETWEEN @From_Date AND @To_Date)
		
		   --Change by ronakk 20122023
		   SET @Total_Emp_PT=(	select Count(Emp_PT) from #EMP_CONS EC
								INNER JOIN T0095_INCREMENT I WITH(NOLOCK) ON EC.Increment_ID = I.Increment_ID and Emp_PT = 1)

			UPDATE #SALARY_DASHBOARD
			SET PT= @Total_Emp_PT

			--end PT Eligible

			--Start Fixed Salary
			SET	@Total_Emp_Fixed_Salary =(SELECT	 Count(1) 
										  FROM	#EMP_CONS EC WITH(NOLOCK)
										  INNER JOIN T0095_INCREMENT I WITH(NOLOCK) ON EC.Increment_ID = I.Increment_ID AND I.Emp_ID=EC.EMP_ID 
										  WHERE I.Emp_Fix_Salary=1
										  )

										  

						
			UPDATE #SALARY_DASHBOARD
			SET Fixed_Salary= @Total_Emp_Fixed_Salary

			--end Fixed Salary

			SELECT * 
			FROM	#SALARY_DASHBOARD WITH(NOLOCK)
			
	END    
	ELSE
    BEGIN
			IF  RTRIM(LTRIM(LOWER(@Type)))='active' 
			BEGIN			
				SELECT  E.Alpha_Emp_code,E.Emp_full_Name,E.Date_Of_Join,B.Branch_Name,D.Dept_Name,DE.Desig_Name
				FROM	#EMP_CONS EC WITH(NOLOCK)
						INNER JOIN T0080_EMP_MASTER E WITH(NOLOCK)  ON EC.Emp_ID = E.Emp_ID
						INNER JOIN T0095_INCREMENT I WITH(NOLOCK) ON EC.Increment_ID = I.Increment_ID
						LEFT JOIN T0030_BRANCH_MASTER B WITH(NOLOCK) ON I.Branch_ID = B.Branch_ID
						LEFT JOIN T0040_DEPARTMENT_MASTER D WITH(NOLOCK) ON I.Dept_ID = D.Dept_Id
						LEFT JOIN T0040_DESIGNATION_MASTER DE WITH(NOLOCK) ON I.Desig_Id = DE.Desig_ID
			END
			ELSE IF  RTRIM(LTRIM(LOWER(@Type)))='processed' 
			BEGIN		
				SELECT	E.Alpha_Emp_code,E.Emp_full_Name,E.Date_Of_Join,B.Branch_Name,D.Dept_Name,DE.Desig_Name
				FROM	#EMP_CONS EC WITH(NOLOCK)
						INNER JOIN T0200_MONTHLY_SALARY MS WITH(NOLOCK) ON EC.EMP_ID = MS.Emp_ID
						INNER JOIN T0080_EMP_MASTER E WITH(NOLOCK)  ON EC.Emp_ID = E.Emp_ID	
						INNER JOIN T0095_INCREMENT I WITH(NOLOCK) ON EC.Increment_ID = I.Increment_ID
						LEFT JOIN T0030_BRANCH_MASTER B WITH(NOLOCK) ON I.Branch_ID = B.Branch_ID
						LEFT JOIN T0040_DEPARTMENT_MASTER D WITH(NOLOCK) ON I.Dept_ID = D.Dept_Id
						LEFT JOIN T0040_DESIGNATION_MASTER DE WITH(NOLOCK) ON I.Desig_Id = DE.Desig_ID				
				WHERE	MS.Month_End_Date BETWEEN @From_Date AND @To_Date
			END
			ELSE IF  RTRIM(LTRIM(LOWER(@Type)))='onhold' 
			BEGIN		
				SELECT	E.Alpha_Emp_code,E.Emp_full_Name,E.Date_Of_Join,B.Branch_Name,D.Dept_Name,DE.Desig_Name 
				FROM	#EMP_CONS EC
						INNER JOIN T0200_MONTHLY_SALARY MS WITH(NOLOCK) ON EC.EMP_ID = MS.Emp_ID
						INNER JOIN T0080_EMP_MASTER E WITH(NOLOCK)  ON EC.Emp_ID = E.Emp_ID
						INNER JOIN T0095_INCREMENT I WITH(NOLOCK) ON EC.Increment_ID = I.Increment_ID
						LEFT JOIN T0030_BRANCH_MASTER B WITH(NOLOCK) ON I.Branch_ID = B.Branch_ID
						LEFT JOIN T0040_DEPARTMENT_MASTER D WITH(NOLOCK) ON I.Dept_ID = D.Dept_Id
						LEFT JOIN T0040_DESIGNATION_MASTER DE WITH(NOLOCK) ON I.Desig_Id = DE.Desig_ID				
				WHERE	MS.Month_End_Date BETWEEN @From_Date AND @To_Date AND MS.Salary_Status = 'Hold'
			END
			ELSE IF  RTRIM(LTRIM(LOWER(@Type)))='pending' 
			BEGIN		
				SELECT	E.Alpha_Emp_code,E.Emp_full_Name,E.Date_Of_Join,B.Branch_Name,D.Dept_Name,DE.Desig_Name
				FROM	#EMP_CONS EC
						INNER JOIN T0095_INCREMENT I WITH(NOLOCK) ON EC.Increment_ID = I.Increment_ID
						--left JOIN T0200_MONTHLY_SALARY MS WITH(NOLOCK) ON EC.EMP_ID = MS.Emp_ID
						Left JOIN T0080_EMP_MASTER E WITH(NOLOCK)  ON E.Emp_ID = EC.Emp_ID
						LEFT JOIN T0030_BRANCH_MASTER B WITH(NOLOCK) ON I.Branch_ID = B.Branch_ID
						LEFT JOIN T0040_DEPARTMENT_MASTER D WITH(NOLOCK) ON I.Dept_ID = D.Dept_Id
						LEFT JOIN T0040_DESIGNATION_MASTER DE WITH(NOLOCK) ON I.Desig_Id = DE.Desig_ID			
				WHERE	EC.EMP_ID NOT IN (SELECT EMP_ID 
										  FROM T0200_MONTHLY_SALARY MS WITH(NOLOCK)
										  WHERE MS.Month_End_Date BETWEEN @From_Date AND @To_Date and Cmp_id = @Cmp_ID)
			END
						   	
			


    
    
    END
    
END