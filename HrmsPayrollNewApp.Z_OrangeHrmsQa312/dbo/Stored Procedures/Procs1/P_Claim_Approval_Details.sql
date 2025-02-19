CREATE PROCEDURE [dbo].[P_Claim_Approval_Details]
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
	,@Claim_Id INT	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET ARITHABORT ON;
		
	DECLARE @columns VARCHAR(MAX)
	DECLARE @query nVARCHAR(MAX)
	
	IF @Claim_Id='0'
		SET @Claim_Id = NULL

	CREATE TABLE #Emp_Cons 
	 (      
	   Emp_ID		NUMERIC ,     
	   Branch_ID	NUMERIC,
	   Increment_ID NUMERIC    
	 )    
	
	EXEC SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,@Salary_Cycle_id,@Segment_Id,@Vertical_Id,@SubVertical_Id,@SubBranch_Id,@New_Join_emp,@Left_Emp,0,'',0,0    
		
	SELECT DISTINCT CI.Alpha_Emp_Code,CI.Emp_ID,CI.Emp_Full_Name,CI.Mobile_No
	FROM V0120_Claim_Approval_Detail_Status EI
	INNER JOIN #Emp_Cons E ON EI.EMP_ID=E.Emp_ID	
	INNER JOIN V0100_CLAIM_APPLICATION CI ON CI.Claim_App_ID=EI.Claim_App_ID
	where EI.CMP_ID=@CMP_ID AND Claim_ID=ISNULL(@Claim_Id,Claim_ID)	 and Claim_Apr_Date between @From_Date and @To_Date AND Claim_App_Status='A'
	ORDER BY EMP_ID
	
	SELECT DISTINCT EI.Alpha_Emp_Code as[Employee Code],EI.Emp_Full_Name as [Employee Name],BM.Branch_Name as[Branch],CAM.Cat_Name AS [Place of Posing],DSM.Desig_Name as[Designation],
				    DM.Dept_Name as[Department],GM.Grd_Name AS [Grade],
					CONVERT(VARCHAR(15),CI.Date_Of_JOIN,103) as[Date Of Join],CI.Claim_Name as[Claim Name],case when isnull(CM.Claim_Limit_Type,0) = 1 THEN 'Monthly' ELSE 'Daily' END As Claim_Limit_Typ,
					CASE WHEN CM.Desig_Wise_Limit = 1 THEN CMD.Max_Limit_Km WHEN CM.Grade_Wise_Limit = 1 THEN CMG.Max_Limit_Km WHEN CM.Branch_Wise_Limit = 1 THEN CMB.Max_Limit_Km 
					WHEN CM.Basic_Salary_wise = 1 THEN IC.Basic_Salary WHEN CM.Gross_Salary_wise = 1 THEN ICG.Gross_Salary END[Claim Max Limit Amount],
					CONVERT(VARCHAR(15),CI.Claim_App_Date,103)[Claim Application Date],CONVERT(VARCHAR(15),EI.Claim_Apr_Date,103) [Claim Approval Date],
					ci.Claim_App_Amount as [Reimbursement Amount],CA.Claim_Apr_Amount AS [Claim Approval Amount],DATENAME(month,(EI.Claim_Apr_Date)) as[Reimbusement Month],DATENAME(year,(EI.Claim_Apr_Date)) as[Reimbusement Year],
					CASE WHEN Claim_App_Status='A' THEN 'Approved' WHEN Claim_App_Status='P' THEN 'Pending' WHEN  Claim_App_Status='R' THEN 'Rejected' end [Status]
	FROM V0120_Claim_Approval_Detail_Status EI
	INNER JOIN T0130_CLAIM_APPROVAL_DETAIL CA ON CA.Claim_Apr_ID=EI.Claim_Apr_ID
	INNER JOIN #Emp_Cons E ON EI.EMP_ID=E.Emp_ID
	INNER JOIN	
					(SELECT I.EMP_ID,I.Increment_ID,I.DESIG_ID,I.BRANCH_ID,I.Cat_ID,I.Dept_ID,I.Grd_ID,Basic_Salary,Gross_Salary
					FROM T0095_INCREMENT I INNER JOIN
						(SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,T0095_INCREMENT.EMP_ID
						 FROM T0095_INCREMENT Inner JOIN
							(
								SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date , EMP_ID 
								FROM T0095_INCREMENT WHERE CMP_ID = @cmp_id AND Increment_Effective_date <= @To_Date GROUP BY EMP_ID
							) inqry on inqry.Emp_ID = T0095_INCREMENT.Emp_ID
						 WHERE CMP_ID = @cmp_id
						 GROUP BY T0095_INCREMENT.EMP_ID) QRY ON I.EMP_ID = QRY.EMP_ID	AND I.INCREMENT_ID = QRY.INCREMENT_ID
					where I.Cmp_ID= @cmp_id
					)IE on ie.Emp_ID = E.Emp_ID
	INNER JOIN V0100_CLAIM_APPLICATION CI ON CI.Claim_App_ID=EI.Claim_App_ID
	INNER JOIN T0040_CLAIM_MASTER CM ON CM.Claim_ID=CI.Claim_ID
	LEFT JOIN dbo.T0030_BRANCH_MASTER BM  WITH (NOLOCK) ON IE.Branch_ID = BM.Branch_ID 
    LEFT JOIN dbo.T0040_DESIGNATION_MASTER DSM  WITH (NOLOCK) ON DSM.Desig_Id = IE.Desig_ID
	LEFT JOIN dbo.T0040_DEPARTMENT_MASTER DM  WITH (NOLOCK) ON DM.Dept_Id = IE.Dept_Id
	LEFT JOIN dbo.T0030_CATEGORY_MASTER CAM WITH (NOLOCK) ON CAM.Cat_ID = IE.Cat_ID 
	LEFT JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON GM.Grd_ID=IE.Grd_ID
	LEFT JOIN T0041_Claim_Maxlimit_Design CMD ON CM.Claim_ID = CMD.Claim_ID AND CM.Desig_Wise_Limit = 1 AND CMD.Desig_ID =IE.Desig_Id 
	LEFT JOIN T0041_Claim_Maxlimit_Design CMG ON CM.Claim_ID = CMG.Claim_ID AND CM.Grade_Wise_Limit = 1 AND CMG.Grade_ID =IE.GRD_ID
	LEFT JOIN T0041_Claim_Maxlimit_Design CMB ON CM.Claim_ID = CMB.Claim_ID AND CM.Branch_Wise_Limit = 1 AND CMB.Branch_ID =IE.Branch_ID
	CROSS APPLY DBO.fn_getEmpIncrement(@CMP_ID,IE.EMP_ID,ei.Claim_Apr_Date)BSM 
	CROSS APPLY DBO.fn_getEmpIncrement(@CMP_ID,IE.EMP_ID,ei.Claim_Apr_Date)GSM 
	LEFT JOIN T0095_INCREMENT IC ON IC.Increment_ID=BSM.Increment_ID  
	LEFT JOIN T0095_INCREMENT ICG ON ICG.Increment_ID=GSM.Increment_ID  
	where EI.CMP_ID=@CMP_ID AND CM.Claim_ID=ISNULL(@Claim_Id,CM.Claim_ID) and ei.Claim_Apr_Date between @From_Date and @To_Date AND Claim_App_Status='A'
	ORDER BY ci.Claim_Name,EI.Alpha_Emp_Code

END