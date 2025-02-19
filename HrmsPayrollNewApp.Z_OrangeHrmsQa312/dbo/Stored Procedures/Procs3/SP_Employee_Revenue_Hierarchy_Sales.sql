

---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Employee_Revenue_Hierarchy_Sales]
	-- Add the parameters for the stored procedure here
	@Cmp_ID Numeric,
	@Emp_ID Numeric,
	@From_Date Datetime,
	@To_Date Datetime,
	@Bussiness_Level Numeric = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	Delete From #Emp_Caption
	
	/*Getting all employees*/
	INSERT INTO #Emp_Caption
	SELECT	DISTINCT E.Cmp_ID,E.Emp_ID,0,0,E.Alpha_Emp_Code,E.Alpha_Emp_Code + '-' + E.Emp_First_Name + ' ' + E.Emp_Second_Name + ' ' + E.Emp_Last_Name as EMp_NAME,0, BM.Branch_Name
	From	T0080_EMP_MASTER E WITH (NOLOCK) LEFT JOIN OT_SalesMIS.dbo.SalesMIS_Revenue SR ON E.Alpha_Emp_Code = SR.EmployeeeCode
			INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON E.Branch_ID=BM.Branch_ID
	Where E.Emp_ID = @Emp_ID
			
	Select DISTINCT EC.EMP_ID,SR.SUB_BRANCH_CODE
	Into #Emp_Branch
	From	#Emp_Caption EC INNER JOIN OT_SalesMIS.dbo.SalesMIS_Revenue SR ON  EC.Alpha_Emp_Code = SR.EmployeeeCode
	Where	TrxDt >= @From_Date and TrxDt <= @To_Date and  EC.Emp_ID = @Emp_ID
	
	INSERT INTO #Emp_Downline (Alpha_Emp_Code,Caption,Emp_ID,R_Level,P_ID,SUB_BRANCH_CODE,Emp_Group_ID)
	Select EC.Alpha_Emp_Code,EC.Emp_First_Name + ' ' + EC.Emp_Second_Name + ' ' + EC.Emp_Last_Name ,EC.EMP_ID,0,0,Isnull(EB.SUB_BRANCH_CODE,0),EC.EMP_ID
	From #Emp_Caption EC 
	Left outer Join #Emp_Branch EB ON EC.EMP_ID = EB.Emp_ID
	
	
END
