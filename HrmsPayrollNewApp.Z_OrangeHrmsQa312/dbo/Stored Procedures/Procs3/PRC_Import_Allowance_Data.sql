-- EXEC PRC_Import_Allowance_Data
-- DROP PROC PRC_Import_Allowance_Data
CREATE PROCEDURE [dbo].[PRC_Import_Allowance_Data]
@Cmp_ID NUMERIC,
@rPermissionStr VARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET ARITHABORT ON;

	DECLARE @lXML XML
	SET @lXML = CAST(@rPermissionStr AS xml)

	DECLARE @tblAllow TABLE
	(
		tid INT IDENTITY(1,1),EmpId NUMERIC,EmpName VARCHAR(50),BranchName VARCHAR(50),IncrEffctDate DATETIME,IncrType VARCHAR(30),EntryType VARCHAR(30),
		Grade VARCHAR(30),Designation VARCHAR(30),Department VARCHAR(30),BSalary NUMERIC,GSalary NUMERIC,RName VARCHAR(500),RowNo NUMERIC,CTC NUMERIC,
		GUIDStr VARCHAR(2000),AlphaEmpCode VARCHAR(50),LogStatus INT,IsYearlyCTC INT,Increment_Date DATETIME,
		GradeId NUMERIC,DeptId NUMERIC,DesignationId NUMERIC,TypeId NUMERIC,BranchId NUMERIC,CatId NUMERIC,VagesType VARCHAR(10),SalaryBasisOn VARCHAR(10),
		PaymentMode VARCHAR(20),Inc_Bank_AC_No VARCHAR(50),EmpOT VARCHAR(1),Emp_OT_Min_Limit VARCHAR(10),Emp_OT_Max_Limit VARCHAR(10),
		Increment_Per NUMERIC,IncrAmt NUMERIC,OLDBasic NUMERIC,OLDGross NUMERIC,OLDctc NUMERIC,Emp_Late_Mark CHAR(1),Emp_Full_PF CHAR(1),
		Emp_PT TINYINT,Fix_Salary CHAR(1),Emp_part_Time NUMERIC,Late_Dedu_Type VARCHAR(10),Emp_Late_Limit VARCHAR(10),Emp_PT_Amount NUMERIC(18,2),
		Emp_Childran NUMERIC,Login_ID NUMERIC,Yearly_Bonus_Amount NUMERIC(18,2),Deputation_End_Date DATETIME,Basic_Per NUMERIC(18,2),
		Calc_On VARCHAR(20),auto_vpf CHAR(1),Salary_Cycle_id NUMERIC,Vertical_ID NUMERIC,SubVertical_ID NUMERIC,subBranch_ID NUMERIC,
		Center_ID NUMERIC,Segment_ID NUMERIC,Fix_OT_Hour_Rate_WD NUMERIC,Fix_OT_Hour_Rate_WO_HO NUMERIC,BankId NUMERIC,Currency_ID NUMERIC,
		AD_Rounding INT,Min_Basic_Applicable TINYINT,Min_Basic NUMERIC,DateOfJoin DATETIME,CmpId NUMERIC,ErrorString VARCHAR(MAX),
		Sevirity INT,t_Status INT,IncrementID NUMERIC,Allow_Same_Date_Increment TINYINT,Emp_Early_Limit VARCHAR(10),ResId INT,
		EmpSuperiorId NUMERIC,AD_Other_Amount NUMERIC(18,2),t_Age NUMERIC(18,2),StateId NUMERIC,Applicable_PT_Male_Female VARCHAR(10),
		Applicable_PT_Male_Female_State NUMERIC(18,0),StateName VARCHAR(200),PTAmount NUMERIC,t_Gender VARCHAR(5),
		PT_F_T_LIMIT VARCHAR(20),PT_Deduction_Month VARCHAR(100),PT_Deduction_Type VARCHAR(100),For_date_month VARCHAR(50),
		For_Date_PT DATETIME,To_Date_PT DATETIME,AD_Other_Amount_New NUMERIC(18,2),PT_Amount_Calaculate_Qutertly NUMERIC(27,0),
		PT_CALCULATED_AMOUNT NUMERIC(27,0)
	)
	INSERT INTO @tblAllow
	SELECT T.c.value('@EmpId','INT') AS EmpId,
	T.c.value('@EmpName','VARCHAR(50)') AS EmpName,
	T.c.value('@BranchName','VARCHAR(50)') AS BranchName,
	T.c.value('@IncrEffctDate','DATETIME') AS IncrEffctDate,
	T.c.value('@IncrType','VARCHAR(50)') AS IncrType,
	T.c.value('@EntryType','VARCHAR(50)') AS EntryType,
	T.c.value('@Grade','VARCHAR(50)') AS Grade,
	T.c.value('@Designation','VARCHAR(50)') AS Designation,
	T.c.value('@Department','VARCHAR(50)') AS Department,
	T.c.value('@BSalary','NUMERIC') AS BSalary,
	T.c.value('@GSalary','NUMERIC') AS GSalary,
	T.c.value('@RName','VARCHAR(500)') AS RName,
	T.c.value('@RowNo','NUMERIC') AS RowNo,
	T.c.value('@CTC','NUMERIC') AS CTC,
	T.c.value('@GUIDStr','VARCHAR(2000)') AS GUIDStr,0,'',0,getdate(),0,0,0,0,0,0,'','','','','','','',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	null,0,'','',0,0,0,0,0,0,0,0,0,0,0,0,0,null,0,'',0,0,0,0,'00:00',0,0,0,0,0,'ALL',0,'',0,'','','','','',null,null,0,0,0
	FROM @lXML.nodes('/Permissions/Permission') AS T(c)

	UPDATE @tblAllow SET AlphaEmpCode = Alpha_Emp_Code,CmpId = Cmp_ID,DateOfJoin = Date_Of_Join,t_Age = DBO.F_GET_AGE (Date_Of_Birth,getdate(),'N','N'),t_Gender = Gender From T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = EmpId
	UPDATE @tblAllow SET IsYearlyCTC = isnull(setting_value,0) From T0040_SETTING WITH (NOLOCK) where setting_name = 'IS_YEARLY_CTC' and cmp_id = @Cmp_ID	

	Insert Into dbo.T0080_Import_Log
	select RowNo,@Cmp_Id,AlphaEmpCode,'Effective/Joning Date Does Not Exists.',GETDATE(),'Verify Effective/Joning Date',GetDate(),'Earn\Ded Data',GUIDStr
	FROM @tblAllow where (IncrEffctDate IS NULL OR ISNULL(IncrEffctDate,'') = '')
	
	UPDATE @tblAllow SET LogStatus = 1 WHERE (IncrEffctDate IS NULL OR ISNULL(IncrEffctDate,'') = '')

	Insert Into dbo.T0080_Import_Log
	select RowNo,@Cmp_Id,AlphaEmpCode,'Increment Type Date Does Not Exists.',CONVERT(varchar(11),IncrEffctDate,103),'Verify Increment Type',GetDate(),'Earn\Ded Data',GUIDStr
	FROM @tblAllow where (IncrType IS NULL OR ISNULL(IncrType,'') = '')

	UPDATE @tblAllow SET LogStatus = 1 WHERE (IncrType IS NULL OR ISNULL(IncrType,'') = '')

	Insert Into dbo.T0080_Import_Log
	select RowNo,@Cmp_Id,AlphaEmpCode,'Entry Type Date Does Not Exists.',CONVERT(varchar(11),IncrEffctDate,103),'Verify Entry Type',GetDate(),'Earn\Ded Data',GUIDStr
	FROM @tblAllow where (EntryType IS NULL OR ISNULL(EntryType,'') = '')

	UPDATE @tblAllow SET LogStatus = 1 WHERE (EntryType IS NULL OR ISNULL(EntryType,'') = '')

	UPDATE @tblAllow SET GradeId =I.Grd_ID,DeptId =Dept_ID ,
	DesignationId =i.Desig_Id,TypeId =i.Type_ID,BranchId=i.Branch_ID,CatId=i.Cat_Id,BankId=i.Bank_ID,
	Currency_ID=i.Curr_ID,VagesType=i.Wages_Type,SalaryBasisOn=i.Salary_Basis_On,PaymentMode=i.Payment_Mode
	,Inc_Bank_AC_No =i.Inc_Bank_AC_No,EmpOT=Emp_OT,Emp_OT_Min_Limit=i.Emp_OT_Min_Limit,Emp_OT_Max_Limit=i.Emp_OT_Max_Limit
	,Increment_Per=Isnull(i.Increment_Per,0),IncrAmt=Isnull(Increment_Amount,0),OldBasic=Isnull(Basic_salary,0),OldGross=Isnull(Gross_Salary,0),OldCTC = Isnull(i.CTC,0)
	,Emp_Late_Mark=isnull(i.Emp_Late_mark,0),Emp_Full_PF=i.Emp_Full_PF,Emp_PT=i.Emp_PT
	,Fix_Salary=Emp_Fix_Salary,Emp_part_Time=i.Emp_part_Time,Late_Dedu_Type=i.Late_Dedu_Type,Emp_Late_Limit=i.Emp_Late_Limit
	,Emp_PT_Amount=i.Emp_PT_Amount,Emp_Childran=i.Emp_Childran,Login_ID=i.Login_ID,Yearly_Bonus_Amount = i.Yearly_Bonus_Amount
	,Deputation_End_Date=i.Deputation_End_Date,Basic_Per = gm.Basic_Percentage,Calc_On=gm.Basic_Calc_On
	,auto_vpf=i.Emp_Auto_Vpf,Salary_Cycle_id = SalDate_id,Vertical_ID = i.Vertical_ID,SubVertical_ID =i.SubVertical_ID,subBranch_ID = i.subBranch_ID
	,Center_ID=i.Center_ID,Segment_ID=i.Segment_ID,Fix_OT_Hour_Rate_WD=i.Fix_OT_Hour_Rate_WD,Fix_OT_Hour_Rate_WO_HO=i.Fix_OT_Hour_Rate_WO_HO
	from T0095_INCREMENT i WITH (NOLOCK)
	inner join
	(
		select max(Increment_ID) Increment_ID ,Emp_ID
		from T0095_INCREMENT WITH (NOLOCK)
		INNER JOIN @tblAllow ON increment_effective_Date <= IncrEffctDate and emp_ID = empId 
		group by emp_ID
	) Q on i.emp_ID = Q.emp_ID and i.Increment_ID = q.Increment_ID
	inner join T0040_GRADE_MASTER gm WITH (NOLOCK) on gm.Grd_ID = i.Grd_ID
	where Q.emp_ID = empId

	UPDATE @tblAllow SET AD_Rounding = G.AD_Rounding FROM dbo.T0040_GENERAL_SETTING G WITH (NOLOCK) WHERE Cmp_ID=@CMP_ID AND Branch_ID=BranchId
	AND For_Date = ( SELECT MAX(For_Date) FROM T0040_GENERAL_SETTING WITH (NOLOCK) WHERE  Branch_ID = BranchId AND Cmp_ID = @Cmp_ID )

	UPDATE @tblAllow SET CTC = CASE WHEN IsYearlyCTC = 1 AND AD_Rounding = 1 THEN ISNULL(ROUND(CTC / 12,0),0) ELSE CTC / 12 END,
	BSalary = CASE WHEN BSalary = 0 THEN 
		CASE WHEN Calc_On = 'CTC' THEN
		CASE WHEN AD_Rounding = 1 THEN isnull(Round((CTC * Basic_Per)/100,0),0) ELSE isnull((CTC * Basic_Per)/100,0) END
		WHEN Calc_On = 'Gross' AND AD_Rounding = 1 THEN isnull(Round((GSalary * Basic_Per)/100,0),0) ELSE isnull((GSalary * Basic_Per)/100,0) END
	ELSE BSalary END

	UPDATE @tblAllow SET Min_Basic_Applicable = Setting_Value from T0040_SETTING WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Setting_Name ='Min. basic rules applicable'
	UPDATE @tblAllow SET Min_Basic = Isnull(G.min_basic,0) from T0040_GRADE_MASTER G WITH (NOLOCK) where Cmp_ID=@Cmp_ID And Grd_Id = GradeId
	UPDATE @tblAllow SET BSalary = Min_Basic where Min_Basic_Applicable = 1 and Min_Basic > 0 and BSalary < Min_Basic
	
	UPDATE @tblAllow SET GradeId = Grd_ID from T0040_GRADE_MASTER WITH (NOLOCK) where Upper(Grd_Name) = Upper(Grade) and Cmp_ID = @Cmp_ID

	Insert Into dbo.T0080_Import_Log
	select RowNo,@Cmp_Id,AlphaEmpCode,'Problem with Grade Name',CONVERT(varchar(11),IncrEffctDate,103),'Please Check Grade Name',GetDate(),'Earn\Ded Data',GUIDStr
	from @tblAllow LEFT JOIN T0040_GRADE_MASTER WITH (NOLOCK) ON Upper(Grd_Name) = Upper(Grade) where Cmp_ID = @Cmp_ID and tid is null

	UPDATE @tblAllow SET LogStatus = 1 from T0040_GRADE_MASTER WITH (NOLOCK) where Upper(Grd_Name) <> Upper(Grade) and Cmp_ID = @Cmp_ID

	UPDATE @tblAllow SET DesignationId = Desig_ID from T0040_DESIGNATION_MASTER  WITH (NOLOCK) where Upper(Desig_Name) = Upper(Designation) and cmp_ID = @Cmp_ID

	Insert Into dbo.T0080_Import_Log
	select RowNo,@Cmp_Id,AlphaEmpCode,'Problem with Designation Name',CONVERT(varchar(11),IncrEffctDate,103),'Please Check Designation Name',GetDate(),'Earn\Ded Data',GUIDStr
	from @tblAllow LEFT JOIN T0040_DESIGNATION_MASTER WITH (NOLOCK) ON Upper(Desig_Name) = Upper(Designation) where Cmp_ID = @Cmp_ID and tid is null

	UPDATE @tblAllow SET LogStatus = 1 from T0040_DESIGNATION_MASTER WITH (NOLOCK) where Upper(Desig_Name) <> Upper(Designation) and Cmp_ID = @Cmp_ID

	UPDATE @tblAllow SET DeptId = Dept_Id from T0040_DEPARTMENT_MASTER  WITH (NOLOCK) where Upper(Dept_Name) = Upper(Department) and cmp_ID = @Cmp_ID

	Insert Into dbo.T0080_Import_Log
	select RowNo,@Cmp_Id,AlphaEmpCode,'Problem with Department Name',CONVERT(varchar(11),IncrEffctDate,103),'Please Check Department Name',GetDate(),'Earn\Ded Data',GUIDStr
	from @tblAllow LEFT JOIN T0040_DEPARTMENT_MASTER WITH (NOLOCK) ON Upper(Dept_Name) = Upper(Department) where Cmp_ID = @Cmp_ID and tid is null

	UPDATE @tblAllow SET LogStatus = 1 from T0040_DEPARTMENT_MASTER WITH (NOLOCK) where Upper(Dept_Name) <> Upper(Department) and Cmp_ID = @Cmp_ID

	UPDATE @tblAllow SET BranchId = Branch_ID from T0030_BRANCH_MASTER  WITH (NOLOCK) where Upper(Branch_Name) = Upper(BranchName) and cmp_ID = @Cmp_ID

	Insert Into dbo.T0080_Import_Log
	select RowNo,@Cmp_Id,AlphaEmpCode,'Problem with Branch Name',CONVERT(varchar(11),IncrEffctDate,103),'Please Check Branch Name',GetDate(),'Earn\Ded Data',GUIDStr
	from @tblAllow LEFT JOIN T0030_BRANCH_MASTER WITH (NOLOCK) ON Upper(Branch_Name) = Upper(BranchName) where Cmp_ID = @Cmp_ID and tid is null

	UPDATE @tblAllow SET LogStatus = 1 from T0030_BRANCH_MASTER WITH (NOLOCK) where Upper(Branch_Name) <> Upper(BranchName) and Cmp_ID = @Cmp_ID

	UPDATE @tblAllow SET ResId = Res_Id from T0040_Reason_Master  WITH (NOLOCK) where Upper(Reason_Name) = Upper(RName)

	Insert Into dbo.T0080_Import_Log
	select RowNo,@Cmp_Id,AlphaEmpCode,'Problem with Reason Name',CONVERT(varchar(11),IncrEffctDate,103),'Please Check Reason Name',GetDate(),'Earn\Ded Data',GUIDStr
	from @tblAllow LEFT JOIN T0040_Reason_Master WITH (NOLOCK) ON Upper(Reason_Name) = Upper(RName) where tid is null

	UPDATE @tblAllow SET LogStatus = 1 from T0040_Reason_Master WITH (NOLOCK) where Upper(Reason_Name) <> Upper(RName)

	UPDATE @tblAllow SET GSalary = OLDGross where GSalary = 0 and LogStatus = 0
	UPDATE @tblAllow SET IncrAmt = BSalary - OLDBasic where BSalary > 0 and LogStatus = 0
	UPDATE @tblAllow SET Increment_Per = CASE WHEN OLDBasic > 0 THEN round(Isnull(IncrAmt,0) * 100 /OLDBasic,2) WHEN BSalary > 0 THEN 100 END WHERE LogStatus = 0

	UPDATE w SET ErrorString = '@@Cannot Update, Salary Exists@@',Sevirity = 16,t_Status = 2,LogStatus = 1
	FROM @tblAllow w INNER JOIN T0200_MONTHLY_SALARY ON EmpId = Emp_ID WHERE IncrType <> 'Joining' AND EntryType = UPPER('New')
	AND IncrEffctDate < Month_End_Date and IncrementID > 0 AND Increment_ID > IncrementID AND LogStatus = 0

	UPDATE w SET ErrorString = '@@Cannot Update, Next Increment Exists@',Sevirity = 16,t_Status = 2,LogStatus = 1
	FROM @tblAllow w INNER JOIN T0095_INCREMENT ON EmpId = Emp_ID WHERE IncrType <> 'Joining' AND EntryType = UPPER('New')
	AND Increment_ID > IncrementID AND IncrementID > 0 AND LogStatus = 0

	UPDATE @tblAllow SET Allow_Same_Date_Increment = Isnull(Setting_Value,0) FROM T0040_SETTING WITH (NOLOCK) WHERE Cmp_ID = Cmp_ID And Setting_Name like 'Allow Same Date Increment' AND LogStatus = 0
	UPDATE @tblAllow SET Emp_OT_Max_Limit = '00:00' WHERE (Emp_OT_Max_Limit ='0:' OR Emp_OT_Max_Limit ='00:' OR Emp_OT_Max_Limit ='0'OR Emp_OT_Max_Limit = '') AND LogStatus = 0
	UPDATE @tblAllow SET Emp_OT_Min_Limit = '00:00' WHERE (Emp_OT_Min_Limit ='0:' OR Emp_OT_Min_Limit ='00:' OR Emp_OT_Min_Limit ='0'OR Emp_OT_Min_Limit = '') AND LogStatus = 0
	UPDATE @tblAllow SET Emp_Late_Limit = '00:00' WHERE (Emp_Late_Limit	= '0' OR Emp_Late_Limit = '') AND LogStatus = 0
	UPDATE @tblAllow SET EmpOT = 0 WHERE EmpOT IS NULL AND LogStatus = 0

	UPDATE w SET ErrorString = '@@Cannot Transfer Employee on Joining Date@@',Sevirity = 16,t_Status = 2,LogStatus = 1 FROM @tblAllow w WHERE IncrType = 'Transfer'
	AND IncrEffctDate = DateOfJoin AND LogStatus = 0
	
	UPDATE W SET AD_Other_Amount = isnull(Amount,0)
	FROM @tblAllow W
	INNER JOIN
	(
		SELECT ISNULL(SUM(E_AD_Amount),0) AS Amount,Increment_ID,EMP_ID
		FROM T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK)
		INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON EED.AD_ID = AM.AD_ID
		INNER JOIN @tblAllow AL ON INCREMENT_ID = IncrementID AND EMP_ID = EmpId
		WHERE E_AD_Flag ='I' AND ISNULL(AD_NOT_EFFECT_SALARY,0) = 0
		AND Emp_PT = 1 AND LogStatus = 0
		GROUP BY INCREMENT_ID,EMP_ID
	) T ON T.INCREMENT_ID = IncrementID AND T.EMP_ID = EmpId
	WHERE Emp_PT = 1 AND LogStatus = 0

	UPDATE @tblAllow SET AD_Other_Amount_New = AD_Other_Amount + BSalary WHERE LogStatus = 0 AND Emp_PT = 1
	UPDATE @tblAllow SET StateId = ISNULL(State_ID,0) FROM T0030_BRANCH_MASTER WITH (NOLOCK) WHERE Branch_ID = BranchId AND Cmp_ID = @CMP_ID AND LogStatus = 0 AND Emp_PT = 1
	UPDATE @tblAllow SET Applicable_PT_Male_Female_State = ISNULL(SM.Applicable_PT_Male_Female,0), StateName = Upper(State_Name)
	FROM T0020_STATE_MASTER SM WITH (NOLOCK) WHERE State_ID = State_ID AND Cmp_ID = @CMP_ID AND LogStatus = 0 AND Emp_PT = 1

	UPDATE @tblAllow SET PTAmount = 0,PT_F_T_LIMIT = 0,AD_Other_Amount = 0,LogStatus = 2 WHERE LogStatus = 0 AND Emp_PT = 1 AND t_Age > 65 AND StateName = 'GUJARAT' AND StateId > 0
	UPDATE @tblAllow SET Applicable_PT_Male_Female = CASE t_Gender WHEN 'M' THEN 'MALE' WHEN 'F' THEN 'FEMALE' ELSE 'ALL' END
	WHERE LogStatus = 0 AND Emp_PT = 1 AND Applicable_PT_Male_Female_State = 1 AND StateId > 0

	UPDATE @tblAllow SET PT_Deduction_Month = ISNULL(S.PT_Deduction_Month,'0'),PT_Deduction_Type = ISNULL(S.PT_Deduction_Type,'Monthly') 
	From T0020_STATE_MASTER S WITH (NOLOCK) INNER JOIN t0030_branch_master B WITH (NOLOCK) on S.State_ID = B.State_ID
	where B.branch_id = BranchId AND LogStatus = 0 AND Emp_PT = 1

	UPDATE @tblAllow SET For_date_month =  charindex('#' + Cast(month(GETDATE()) as Varchar(50)) + '#','#' + PT_Deduction_Month + '#') WHERE LogStatus = 0 AND Emp_PT = 1
	
	UPDATE @tblAllow SET To_Date_PT = CASE PT_Deduction_Type WHEN 'Quaterly' THEN dbo.GET_MONTH_END_DATE((Month(GETDATE())-1),year(GETDATE()))
	WHEN 'Half Yearly' THEN dbo.GET_MONTH_END_DATE((Month(GETDATE())-1),year(GETDATE()))
	WHEN 'Yearly' THEN dbo.GET_MONTH_END_DATE((Month(GETDATE())-1),year(GETDATE())) END
	WHERE LogStatus = 0 AND Emp_PT = 1 AND For_date_month <> '0'

	UPDATE @tblAllow SET For_Date_PT = CASE PT_Deduction_Type WHEN 'Quaterly' THEN dbo.GET_MONTH_ST_DATE(Month(DATEADD(MM,-1,To_Date_PT)),Year(DATEADD(MM,-1,To_Date_PT)))
	WHEN 'Half Yearly' THEN dbo.GET_MONTH_ST_DATE(Month(DATEADD(MM,-4,To_Date_PT)),Year(DATEADD(MM,-4,To_Date_PT)))
	WHEN 'Yearly' THEN dbo.GET_MONTH_ST_DATE(Month(DATEADD(MM,-10,To_Date_PT)),Year(DATEADD(MM,-10,To_Date_PT))) END
	WHERE LogStatus = 0 AND Emp_PT = 1 AND For_date_month <> '0'
	
	UPDATE W SET PT_Amount_Calaculate_Qutertly = isnull(AMOUNT,0) FROM @tblAllow W
	INNER JOIN
	(
		SELECT Isnull(SUM(Gross_Salary),0) AS AMOUNT,Emp_ID
		From T0200_MONTHLY_SALARY WITH (NOLOCK)
		INNER JOIN @tblAllow ON Emp_ID = EmpId
		WHERE Cmp_ID = @CMP_ID  and Month_St_Date >= For_Date_PT and Month_End_Date <= To_Date_PT
		AND LogStatus = 0 AND Emp_PT = 1 AND For_date_month <> '0'
		GROUP BY Emp_ID
	) T ON EmpId = Emp_ID
	WHERE LogStatus = 0 AND Emp_PT = 1 AND For_date_month <> '0'
	
	UPDATE @tblAllow SET PT_CALCULATED_AMOUNT = PT_CALCULATED_AMOUNT + PT_Amount_Calaculate_Qutertly WHERE LogStatus = 0 AND Emp_PT = 1 AND For_date_month <> '0'
END