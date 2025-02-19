
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE  PROCEDURE [dbo].[SP_RPT_LAST_DRAWN_SALARY]
	@Company_id		Numeric  
	,@From_Date		Datetime
	,@To_Date 		Datetime
	,@Branch_ID		Numeric	= 0
	,@Grade_ID 		Numeric = 0
	,@Type_ID 		Numeric = 0
	,@Dept_ID 		Numeric = 0
	,@Desig_ID 		Numeric = 0
	,@Emp_ID 		Numeric = 0
	,@Constraint	Varchar(max) =''
	,@Cat_ID        Numeric = 0
	,@is_column		tinyint = 0
	,@Salary_Cycle_id  NUMERIC  = 0
	,@Segment_ID	Numeric = 0 
	,@Vertical		Numeric = 0 
	,@SubVertical	Numeric = 0 
	,@subBranch		Numeric = 0 
 
AS	
	BEGIN

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	
	CREATE Table #Emp_Cons
	(
		emp_id	NUMERIC(18,0)
	)
	
	if @Constraint <> ''
	BEGIN
		INSERT Into #Emp_Cons
		Select data from dbo.Split(@Constraint,'#') 
	END
					
			 	
	SELECT CM.Cmp_Name,BM.Branch_Name,EM.Emp_Full_Name,EM.Emp_ID,DM.Dept_Name ,DGM.Desig_Name,GM.Grd_Name,VS.Vertical_Name,
	convert(varchar(15),MSS.Month_St_Date,103) as Salary_Start_Date,convert(varchar(15),MSS.Month_End_Date,103) as Salary_End_Date,MSS.Sal_Generate_Date as Salary_Generate_Date,IQ.Gross_Salary,MSS.Salary_Amount ,MSS.Net_Amount,DATENAME(month,MSS.Month_End_Date) as month ,DATENAME(YEAR,MSS.Month_End_Date) as year  
	,BM.Branch_ID
	FROM T0080_EMP_MASTER EM WITH (NOLOCK)
	INNER JOIN #Emp_Cons E ON EM.Emp_ID = E.emp_id 
	INNER JOIN (SELECT MAX(month_end_date) as max_date,Emp_ID  FROM T0200_MONTHLY_SALARY WITH (NOLOCK)
	where cmp_id = @Company_id and Month_End_Date <= @to_date GROUP BY Emp_ID ) MS on EM.Emp_ID = MS.Emp_ID
	inner JOIN T0200_MONTHLY_SALARY MSS WITH (NOLOCK) ON EM.Emp_ID = MSS.Emp_ID and ms.max_date = MSS.Month_End_Date 
	inner JOIN T0095_INCREMENT IQ WITH (NOLOCK) ON MSS.Increment_ID =IQ.Increment_ID and Mss.Emp_ID = IQ.Emp_ID
	INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON IQ.Grd_ID = GM.Grd_ID 
	INNER JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) On IQ.Cmp_ID = CM.Cmp_Id 
	LEFT OUTER JOIN T0040_TYPE_MASTER ETM WITH (NOLOCK) ON IQ.Type_ID = ETM.Type_ID 
	LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON IQ.Desig_Id = DGM.Desig_Id 
	LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON IQ.Dept_Id = DM.Dept_Id 
	INNER JOIN T0030_Branch_Master BM WITH (NOLOCK) on IQ.Branch_ID = BM.Branch_ID 
	LEFT JOIN T0040_Vertical_Segment VS WITH (NOLOCK) on IQ.Vertical_ID = vs.Vertical_ID 
	LEFT JOIN T0040_TYPE_MASTER TM WITH (NOLOCK) ON IQ.Type_ID = TM.Type_ID
	WHERE EM.Cmp_ID = @Company_id 
	

End
