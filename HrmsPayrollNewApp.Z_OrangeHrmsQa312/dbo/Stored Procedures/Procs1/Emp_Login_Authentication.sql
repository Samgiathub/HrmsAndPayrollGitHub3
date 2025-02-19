

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Emp_Login_Authentication] 
	-- Add the parameters for the stored procedure here
	@Username Varchar(100),
	@Password Varchar(100)
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	
	
	IF Object_ID('tempdb..#EmpDetails') is not null
		drop TABLE #EmpDetails
	
	Create Table #EmpDetails
	(
		Emp_Code Varchar(100),
		Emp_Name Varchar(500),
		Cmp_Name Varchar(200),
		Branch_Name Varchar(100),
		Dept_Name Varchar(100),
		Desig_Name Varchar(100),
		DOB Varchar(11),
		Age Varchar(5),
		DOJ Varchar(11),
		DOR Varchar(11),
		Gender Varchar(10)
	)
	
	Declare @Emp_ID Numeric(18,0)
	Set @Emp_ID = 0
	
	Declare @Cmp_ID Numeric(18,0)
	Set @Cmp_ID = 0
    
    If Exists(Select 1 From T0011_LOGIN WITH (NOLOCK) Where UPPER(Login_Name) = UPPER(@Username) and UPPER(Login_Password) = UPPER(@Password) AND Isnull(Emp_ID,0) <> 0)
		BEGIN
			SELECT @Emp_ID = Emp_ID,@Cmp_ID = Cmp_ID From T0011_LOGIN WITH (NOLOCK) Where UPPER(Login_Name) = UPPER(@Username) and UPPER(Login_Password) = UPPER(@Password) AND Isnull(Emp_ID,0) <> 0
			Insert INTO #EmpDetails(Emp_Code,Emp_Name,Cmp_Name,Branch_Name,Dept_Name,Desig_Name,DOB,Age,DOJ,DOR,Gender)
			SELECT	ISNULL(EM.Alpha_Emp_Code,''),
							EM.Emp_Full_Name,
							CM.Cmp_Name,
							BM.BRANCH_NAME,
							ISNULL(Dept_Name,'') as Dept_Name ,
							ISNULL(DM.Desig_Name,'') as Desig_Name,
							Replace(CONVERT(varchar(11),EM.Date_Of_Birth,105),'-','/') as DOB,
							(CASE ISNULL(EM.Date_Of_Birth,'') WHEN '' THEN '' ELSE dbo.F_GET_AGE(EM.Date_Of_Birth,getdate(),'Y','N') END ) AS Age,
							Replace(CONVERT(varchar(11),EM.Date_OF_Join,105),'-','/') as DOJ,
							(CASE ISNULL(EM.Emp_Left_Date,'') WHEN '' THEN '' ELSE Replace(CONVERT(varchar(11),EM.Emp_Left_Date,105),'-','/') END) as DOR,
							CASE WHEN EM.Gender = 'M' OR EM.Gender = '' THEN 
									'Male' 
								WHEN EM.Gender = 'F' THEN 
									'Female' 
							END 
					From	T0080_EMP_MASTER EM	WITH (NOLOCK)		
							LEFT JOIN T0080_EMP_MASTER EM1 WITH (NOLOCK) On EM.Emp_Superior = EM1.Emp_ID			
							LEFT JOIN (Select	i.Cmp_ID, i.CTC,i.Emp_ID,i.Desig_Id,I.subBranch_ID,i.Increment_Type,i.Increment_Effective_Date,I.Payment_Mode,I.Inc_Bank_AC_No,I.Emp_Full_PF,I.Emp_PT,I.Emp_Fix_Salary,I.Emp_Part_Time,I.Late_Dedu_Type,I.wages_type,I.Center_ID,I.Gross_Salary,I.SalDate_id,I.Segment_ID 
										From		T0095_Increment i WITH (NOLOCK)
												INNER JOIN (SELECT	MAX(Increment_effective_Date) as Increment_effective_Date, Emp_ID 
															FROM	T0095_Increment WITH (NOLOCK)   
															WHERE	Increment_Effective_date <= GETDATE() 
															GROUP BY emp_ID) AS inc ON inc.Emp_ID = i.Emp_ID AND inc.Increment_effective_Date = i.Increment_Effective_Date
										) Qry ON EM.Emp_ID = Qry.Emp_ID
							LEFT JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) On Qry.Desig_Id = DM.Desig_Id
							LEFT JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) On EM.Grd_ID = GM.Grd_ID	
							LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DeptM WITH (NOLOCK) On EM.Dept_ID = DeptM.Dept_Id
							LEFT OUTER JOIN T0040_Type_Master TM WITH (NOLOCK) On EM.Type_ID = TM.Type_ID	
							INNER JOIN dbo.T0011_LOGIN Ln WITH (NOLOCK) ON em.Emp_ID = Ln.Emp_ID				 -- Added By Gadriwala Muslim 18042014
							INNER JOIN dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK) ON em.Branch_ID = BM.Branch_ID -- Added By Gadriwala Muslim 18042014
							--Left Outer Join T0040_Type_Master TM On EM.Type_ID = TM.Type_ID	
							LEFT OUTER JOIN T0030_CATEGORY_MASTER CTM WITH (NOLOCK) on EM.Cat_ID=CTM.Cat_ID
							LEFT OUTER JOIN T0040_Vertical_Segment VTS WITH (NOLOCK) on VTS.Vertical_ID=EM.Vertical_ID
							LEFT OUTER JOIN T0050_SubVertical SubVT WITH (NOLOCK) on SubVT.SubVertical_ID=EM.SubVertical_ID
							LEFT OUTER JOIN T0040_BANK_MASTER BN WITH (NOLOCK) on Bn.Bank_ID=EM.Bank_ID
							LEFT OUTER JOIN T0040_COST_CENTER_MASTER CCM WITH (NOLOCK) on CCM.Center_ID=Qry.Center_ID
							LEFT OUTER JOIN T0040_Salary_Cycle_Master SCM WITH (NOLOCK) on SCm.Tran_Id=Qry.SalDate_id
							LEFT OUTER JOIN T0040_Business_Segment BS WITH (NOLOCK) on BS.Segment_ID=Qry.Segment_ID
							LEFT OUTER JOIN T0050_SubBranch SBM WITH (NOLOCK) on  Qry.SubBranch_ID = SBM.subBranch_ID
							LEFT OUTER JOIN T0100_LEFT_EMP LEM WITH (NOLOCK) on LEM.Emp_ID=EM.Emp_ID 
							LEFT OUTER JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) on Qry.Cmp_ID = CM.Cmp_Id
					Where	EM.Emp_ID = @Emp_ID and EM.Cmp_ID = @Cmp_ID
		End
	Else
		Begin
			Insert INTO #EmpDetails(Emp_Code,Emp_Name,Cmp_Name,Branch_Name,Dept_Name,Desig_Name,DOB,Age,DOJ,DOR,Gender)
			Select '0','','','','','','','','','',''
		End
	Select * From #EmpDetails
END

