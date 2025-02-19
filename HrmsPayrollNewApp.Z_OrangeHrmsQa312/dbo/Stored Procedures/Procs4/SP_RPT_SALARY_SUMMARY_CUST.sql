

-- =============================================
-- Author:		<Ankit>
-- Create date: <21052015,,>
-- Description:	<Yearly Salary Summery Report,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_RPT_SALARY_SUMMARY_CUST]
	@Cmp_ID			Numeric,
	@From_Date		Datetime,
	@To_Date		Datetime,
	@Report_Type	Numeric
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON


BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	
	CREATE TABLE #Emp_Cons 
	 (      
	   Emp_ID numeric ,     
	   Increment_ID numeric
	 )      
 
	
	INSERT INTO #Emp_Cons      
	SELECT DISTINCT emp_id,Increment_ID from V_Emp_Cons 
	WHERE CMP_ID=@CMP_ID 
		   			
	DELETE  FROM #EMP_CONS WHERE INCREMENT_ID NOT IN (SELECT MAX(INCREMENT_ID) FROM T0095_INCREMENT WITH (NOLOCK)
		WHERE  INCREMENT_EFFECTIVE_DATE <= @TO_DATE
		GROUP BY EMP_ID)	
			
					
	IF @REPORT_TYPE = 1	--Branch
		BEGIN 
			SELECT	DM.Dept_Name,COUNT(EC.Emp_ID) AS Total_Emp ,
					SUM(MS.Salary_Amount) AS Salary_Amount , SUM(MS.Gross_Salary) AS Gross_Salary,SUM(MS.Net_Amount ) AS Net_Amount
			FROM	T0200_Monthly_Salary MS WITH (NOLOCK) INNER JOIN 
					#Emp_Cons EC on MS.Emp_ID = EC.Emp_ID INNER JOIN 
						( SELECT I.Emp_Id , Branch_ID,Dept_ID from T0095_Increment I WITH (NOLOCK) INNER JOIN       
							( SELECT MAX(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)     
								where Increment_Effective_date <= @To_Date and Cmp_ID = @Cmp_ID      
								group by emp_ID  
							 ) Qry on I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID  ) I_Q       
						on MS.Emp_ID = I_Q.Emp_ID  INNER JOIN      
					T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN
					T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.DEPT_ID
			WHERE	MS.Cmp_ID = @Cmp_ID AND Month_End_Date between @From_Date and @To_Date

			GROUP BY DM.Dept_Name
		END 
	
	
		 
END


