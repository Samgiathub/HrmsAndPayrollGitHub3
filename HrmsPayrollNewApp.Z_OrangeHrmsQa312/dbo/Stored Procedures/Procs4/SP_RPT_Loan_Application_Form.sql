CREATE PROCEDURE [dbo].[SP_RPT_Loan_Application_Form] @Cmp_ID NUMERIC
	,@From_Date DATETIME
	,@To_Date DATETIME
	,@Branch_ID NUMERIC
	,@Cat_ID NUMERIC
	,@Grd_ID NUMERIC
	,@Type_ID NUMERIC
	,@Dept_ID NUMERIC
	,@Desig_ID NUMERIC
	,@Emp_ID NUMERIC
	,@constraint VARCHAR(MAX)
	,@Sal_Type NUMERIC = 0
	,@Bank_id NUMERIC = 0
	,@Payment_mode VARCHAR(100) = ''
	,@Salary_Cycle_id NUMERIC = 0
	,@Segment_Id NUMERIC = 0
	,@Vertical_Id NUMERIC = 0
	,@SubVertical_Id NUMERIC = 0
	,@SubBranch_Id NUMERIC = 0
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

IF @Branch_ID = 0
	SET @Branch_ID = NULL

IF @Cat_ID = 0
	SET @Cat_ID = NULL

IF @Grd_ID = 0
	SET @Grd_ID = NULL

IF @Type_ID = 0
	SET @Type_ID = NULL

IF @Dept_ID = 0
	SET @Dept_ID = NULL

IF @Desig_ID = 0
	SET @Desig_ID = NULL

IF @Emp_ID = 0
	SET @Emp_ID = NULL

IF @Salary_Cycle_id = 0
	SET @Salary_Cycle_id = NULL

IF @Segment_Id = 0
	SET @Segment_Id = NULL

IF @Vertical_Id = 0
	SET @Vertical_Id = NULL

IF @SubVertical_Id = 0
	SET @SubVertical_Id = NULL

IF @SubBranch_Id = 0
	SET @SubBranch_Id = NULL

CREATE TABLE #Emp_Cons (
	Emp_ID NUMERIC
	,Branch_ID NUMERIC
	,Increment_ID NUMERIC
	)

IF @Constraint <> ''
BEGIN
	INSERT INTO #Emp_Cons
	SELECT cast(data AS NUMERIC)
		,cast(data AS NUMERIC)
		,cast(data AS NUMERIC)
	FROM dbo.Split(@Constraint, '#')
END
ELSE
BEGIN
	INSERT INTO #Emp_Cons
	EXEC SP_RPT_FILL_EMP_CONS @Cmp_ID
		,@From_Date
		,@To_Date
		,@Branch_ID
		,@Cat_ID
		,@Grd_ID
		,@Type_ID
		,@Dept_ID
		,@Desig_ID
		,@Emp_ID
		,@constraint
		,@Sal_Type
		,@Salary_Cycle_id
		,@Segment_Id
		,@Vertical_Id
		,@SubVertical_Id
		,@SubBranch_Id
END

--   Select LA.Loan_App_ID, LA.Loan_App_Date,BM.Branch_Name,EM.Alpha_Emp_Code,EM.Emp_First_Name,EM.Father_name,EM.Emp_Last_Name,EM.Emp_Full_Name,
--DM.Dept_Name,DS.Desig_Name,EM.Date_Of_Join,EM.Street_1 +' '+ EM.City +' '+ EM.Mobile_No+' '+EM.Work_Tel_No As Address_Details,
--BK.Bank_Name +'-'+ I_Q.Inc_Bank_AC_No AS BankDetails ,I_Q.Increment_ID,LA.Loan_App_Amount
--,EM.Basic_Salary,qry.Gurantor_Name,
--qry.G_Desgination,qry.G_Address,isnull(qry1.Pending_loan_Amount,0) as Pending_loan_Amount,
--LA.Loan_App_Comments as Loan_Comment
--From T0100_LOAN_APPLICATION LA inner JOIN T0080_EMP_MASTER EM on LA.Emp_ID = EM.Emp_ID 
--INNER JOIN (Select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,I.Increment_ID,I.Bank_ID,I.Inc_Bank_AC_No from T0095_Increment I inner join 
--					(Select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment
--						Where Increment_Effective_date <= @To_Date
--						And Cmp_ID = @Cmp_ID 
--						Group by emp_ID  ) Qry on
--							I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date	 ) I_Q 
--							On EM.Emp_ID = I_Q.Emp_ID
--INNER JOIN T0030_BRANCH_MASTER BM ON I_Q.Branch_ID = BM.Branch_ID
--INNER JOIN T0040_DEPARTMENT_MASTER DM ON I_Q.Dept_Id = DM.Dept_ID
--INNER JOIN T0040_DESIGNATION_MASTER DS ON I_Q.Desig_ID = DS.Desig_Id
--INNER JOIN T0040_BANK_MASTER BK ON I_Q.Bank_ID = BK.Bank_ID
--Inner JOIN #Emp_Cons EC ON EC.Emp_ID = I_Q.Emp_ID
--Left OUTER JOIN(SELECT GEM.Emp_Full_Name as Gurantor_Name,GEM.Emp_ID,GLA.Loan_App_ID,GDM.Desig_Name As G_Desgination,  
--GEM.Street_1 +' '+ GEM.City +' '+ GEM.Mobile_No+' '+ GEM.Work_Tel_No As G_Address
--From T0080_EMP_MASTER GEM Inner JOIN T0100_LOAN_APPLICATION GLA on Isnull(GLA.Guarantor_Emp_ID,0) = GEM.Emp_ID
--Inner JOIN T0040_DESIGNATION_MASTER GDM ON GDM.Desig_ID = GEM.Desig_Id
--) as qry
--on qry.Loan_App_ID = LA.Loan_App_ID 
--LEFT OUTER Join( Select SUM(isnull(Loan_Apr_Pending_Amount,0)) as Pending_loan_Amount,Loan_ID,Emp_ID From T0120_LOAN_APPROVAL 
--GROUP By Loan_ID,Emp_ID
--)as qry1
--on qry1.Emp_ID = I_Q.Emp_ID and LA.Loan_ID = qry1.Loan_ID
--where EM.Cmp_ID = @Cmp_ID 
SELECT LA.Loan_App_ID
	,LA.Loan_App_Date
	,BM.Branch_Name
	,EM.Alpha_Emp_Code
	,EM.Emp_First_Name
	,EM.Father_name
	,EM.Emp_Last_Name
	,EM.Emp_Full_Name
	,DM.Dept_Name
	,DS.Desig_Name
	,EM.Date_Of_Join
	,EM.Street_1 + ' ' + EM.City + ' ' + EM.Mobile_No + ' ' + EM.Work_Tel_No AS Address_Details
	,BK.Bank_Name + '-' + I_Q.Inc_Bank_AC_No AS BankDetails
	,I_Q.Increment_ID
	,Isnull(qry_2.Loan_Apr_Amount, LA.Loan_App_Amount) AS Loan_App_Amount
	,I_Q.Basic_Salary
	,qry.Gurantor_Name
	,qry.G_Desgination
	,qry.G_Address
	,isnull(qry1.Pending_loan_Amount, 0) AS Pending_loan_Amount
	,LA.Loan_App_Comments AS Loan_Comment
	,CM.cmp_logo
	,CM.Cmp_Name
	,qry2.Gurantor_Name AS Gurantor_Name2
	,qry2.G_Desgination G_Desgination2
	,qry2.G_Address AS G_Address2
	,LM.Loan_Name --Added By Mukti 19112015 for 2nd Gurantor details
	,EM.Dealer_Code --Added by nilesh patel on 31032016
	,LAP.Loan_Apr_Amount
	,isnull(LAP.Loan_Apr_Intrest_Per, LA.Loan_Interest_Per) AS Rate_of_Intrest
	,isnull(LAP.Loan_Apr_Installment_Amount, LA.Loan_App_Installment_Amount) Installment_Amount
	,isnull(LAP.Loan_Apr_No_of_Installment, LA.Loan_App_No_of_Insttlement) No_of_Insttlement
	,isnull(LAP.Loan_Apr_Intrest_Type, LA.Loan_Interest_Type) Interest_Type
FROM T0100_LOAN_APPLICATION LA WITH (NOLOCK)
FULL OUTER JOIN T0120_LOAN_APPROVAL LAP WITH (NOLOCK) ON LA.Loan_App_ID = LAP.Loan_App_ID
INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON LA.Emp_ID = EM.Emp_ID
INNER JOIN (
	SELECT I.Emp_Id
		,Grd_ID
		,Branch_ID
		,Cat_ID
		,Desig_ID
		,Dept_ID
		,Type_ID
		,I.Increment_ID
		,I.Bank_ID
		,I.Inc_Bank_AC_No
		,I.Basic_Salary
	FROM T0095_Increment I WITH (NOLOCK)
	INNER JOIN (
		SELECT MAX(Increment_ID) AS Increment_ID
			,MI.Emp_ID
		FROM T0095_INCREMENT MI WITH (NOLOCK)
		INNER JOIN (
			SELECT max(Increment_effective_Date) AS For_Date
				,Emp_ID
			FROM T0095_Increment WITH (NOLOCK)
			WHERE Increment_Effective_date <= @To_Date
				AND Cmp_ID = @Cmp_ID
			GROUP BY emp_ID
			) Qry ON MI.Emp_ID = Qry.Emp_ID
			AND MI.Increment_effective_Date = Qry.For_Date
		GROUP BY MI.Emp_ID
		) I_Q_1 ON I.Increment_ID = I_Q_1.Increment_ID
		AND I_Q_1.Emp_ID = I.Emp_ID
	) I_Q ON I_Q.Emp_ID = EM.Emp_ID
INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.Branch_ID = BM.Branch_ID
LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_ID
INNER JOIN T0040_DESIGNATION_MASTER DS WITH (NOLOCK) ON I_Q.Desig_ID = DS.Desig_Id
LEFT OUTER JOIN T0040_BANK_MASTER BK WITH (NOLOCK) ON I_Q.Bank_ID = BK.Bank_ID
INNER JOIN #Emp_Cons EC ON EC.Emp_ID = EM.Emp_ID
LEFT OUTER JOIN (
	SELECT GEM.Emp_Full_Name AS Gurantor_Name
		,GEM.Emp_ID
		,GLA.Loan_App_ID
		,GDM.Desig_Name AS G_Desgination
		,GEM.Street_1 + ' ' + GEM.City + ' ' + GEM.Mobile_No + ' ' + GEM.Work_Tel_No AS G_Address
	FROM T0080_EMP_MASTER GEM WITH (NOLOCK)
	INNER JOIN T0100_LOAN_APPLICATION GLA WITH (NOLOCK) ON Isnull(GLA.Guarantor_Emp_ID, 0) = GEM.Emp_ID
	INNER JOIN T0040_DESIGNATION_MASTER GDM WITH (NOLOCK) ON GDM.Desig_ID = GEM.Desig_Id
	) AS qry ON qry.Loan_App_ID = LA.Loan_App_ID
LEFT OUTER JOIN (
	SELECT SUM(isnull(Loan_Apr_Pending_Amount, 0)) AS Pending_loan_Amount
		,Loan_ID
		,Emp_ID
	FROM T0120_LOAN_APPROVAL WITH (NOLOCK)
	GROUP BY Loan_ID
		,Emp_ID
	) AS qry1 ON qry1.Emp_ID = I_Q.Emp_ID
	AND LA.Loan_ID = qry1.Loan_ID
--Added By Mukti(start)19112015 for 2nd Gurantor details
LEFT OUTER JOIN (
	SELECT GEM2.Emp_Full_Name AS Gurantor_Name
		,GEM2.Emp_ID
		,GLA2.Loan_App_ID
		,GDM2.Desig_Name AS G_Desgination
		,GEM2.Street_1 + ' ' + GEM2.City + ' ' + CASE 
			WHEN isnull(GEM2.Mobile_No, '0') = '0'
				THEN ''
			ELSE GEM2.Mobile_No
			END + ' ' + CASE 
			WHEN isnull(GEM2.Work_Tel_No, '0') = '0'
				THEN ''
			ELSE GEM2.Work_Tel_No
			END AS G_Address
	FROM T0080_EMP_MASTER GEM2 WITH (NOLOCK)
	INNER JOIN T0100_LOAN_APPLICATION GLA2 WITH (NOLOCK) ON Isnull(GLA2.Guarantor_Emp_ID2, 0) = GEM2.Emp_ID
	INNER JOIN T0040_DESIGNATION_MASTER GDM2 WITH (NOLOCK) ON GDM2.Desig_ID = GEM2.Desig_Id
	) AS qry2 ON qry2.Loan_App_ID = LA.Loan_App_ID
--Added By Mukti(end)19112015
INNER JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) ON CM.Cmp_Id = EM.Cmp_ID
INNER JOIN T0040_LOAN_Master LM WITH (NOLOCK) ON LM.Loan_Id = LA.Loan_Id
	AND LM.cmp_id = LA.cmp_Id --Mukti 19112015
LEFT OUTER JOIN (
	SELECT LLA.EMP_ID
		,LLA.Loan_App_ID
		,LLA.Loan_Apr_Amount
	FROM T0115_Loan_Level_Approval LLA WITH (NOLOCK)
	INNER JOIN (
		SELECT Max(Rpt_Level) AS Rpt_Level
			,T0115_Loan_Level_Approval.Loan_App_ID
			,T0115_Loan_Level_Approval.Emp_Id
		FROM T0115_Loan_Level_Approval WITH (NOLOCK)
		INNER JOIN #Emp_Cons ON T0115_Loan_Level_Approval.Emp_Id = #Emp_Cons.Emp_ID
		GROUP BY T0115_Loan_Level_Approval.Loan_App_ID
			,T0115_Loan_Level_Approval.Emp_Id
		) AS Qry_1 ON LLA.Loan_App_ID = Qry_1.Loan_App_ID
		AND LLA.Emp_ID = Qry_1.Emp_ID
		AND LLA.Rpt_Level = Qry_1.Rpt_Level
	) AS qry_2 ON LA.Emp_ID = qry_2.EMP_ID
	AND LA.Loan_App_ID = qry_2.Loan_App_ID
WHERE EM.Cmp_ID = @Cmp_ID
	AND La.Loan_App_Date >= @from_date
	AND La.Loan_App_Date <= @To_date
-- and LA.Loan_status<>'A'
--added by mansi 13-07-2023

UNION ALL

SELECT LA.Loan_App_ID
	,LA.Loan_Apr_Date AS Loan_App_Date
	,BM.Branch_Name
	,EM.Alpha_Emp_Code
	,EM.Emp_First_Name
	,EM.Father_name
	,EM.Emp_Last_Name
	,EM.Emp_Full_Name
	,DM.Dept_Name
	,DS.Desig_Name
	,EM.Date_Of_Join
	,EM.Street_1 + ' ' + EM.City + ' ' + EM.Mobile_No + ' ' + EM.Work_Tel_No AS Address_Details
	,BK.Bank_Name + '-' + I_Q.Inc_Bank_AC_No AS BankDetails
	,I_Q.Increment_ID
	,qry_2.Loan_Apr_Amount AS Loan_App_Amount
	,I_Q.Basic_Salary
	,qry.Gurantor_Name
	,qry.G_Desgination
	,qry.G_Address
	,isnull(qry1.Pending_loan_Amount, 0) AS Pending_loan_Amount
	,'' AS Loan_Comment
	,CM.cmp_logo
	,CM.Cmp_Name
	,qry2.Gurantor_Name AS Gurantor_Name2
	,qry2.G_Desgination G_Desgination2
	,qry2.G_Address AS G_Address2
	,LM.Loan_Name --Added By Mukti 19112015 for 2nd Gurantor details
	,EM.Dealer_Code --Added by nilesh patel on 31032016
	,LA.Loan_Apr_Amount
	,Loan_Apr_Intrest_Per AS Rate_of_Intrest
	,Loan_Apr_Installment_Amount AS Installment_Amount
	,Loan_Apr_No_of_Installment AS No_of_Insttlement
	,Loan_Apr_Intrest_Type AS Interest_Type
FROM T0120_LOAN_APPROVAL LA WITH (NOLOCK)
--full outer join T0120_LOAN_APPROVAL LAP WITH (NOLOCK) on LA.Loan_App_ID = LAP.Loan_App_ID 
INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON LA.Emp_ID = EM.Emp_ID
INNER JOIN (
	SELECT I.Emp_Id
		,Grd_ID
		,Branch_ID
		,Cat_ID
		,Desig_ID
		,Dept_ID
		,Type_ID
		,I.Increment_ID
		,I.Bank_ID
		,I.Inc_Bank_AC_No
		,I.Basic_Salary
	FROM T0095_Increment I WITH (NOLOCK)
	INNER JOIN (
		SELECT MAX(Increment_ID) AS Increment_ID
			,MI.Emp_ID
		FROM T0095_INCREMENT MI WITH (NOLOCK)
		INNER JOIN (
			SELECT max(Increment_effective_Date) AS For_Date
				,Emp_ID
			FROM T0095_Increment WITH (NOLOCK)
			WHERE Increment_Effective_date <= @To_Date
				AND Cmp_ID = @Cmp_ID
			GROUP BY emp_ID
			) Qry ON MI.Emp_ID = Qry.Emp_ID
			AND MI.Increment_effective_Date = Qry.For_Date
		GROUP BY MI.Emp_ID
		) I_Q_1 ON I.Increment_ID = I_Q_1.Increment_ID
		AND I_Q_1.Emp_ID = I.Emp_ID
	) I_Q ON I_Q.Emp_ID = EM.Emp_ID
INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.Branch_ID = BM.Branch_ID
LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_ID
INNER JOIN T0040_DESIGNATION_MASTER DS WITH (NOLOCK) ON I_Q.Desig_ID = DS.Desig_Id
LEFT OUTER JOIN T0040_BANK_MASTER BK WITH (NOLOCK) ON I_Q.Bank_ID = BK.Bank_ID
INNER JOIN #Emp_Cons EC ON EC.Emp_ID = EM.Emp_ID
LEFT OUTER JOIN (
	SELECT GEM.Emp_Full_Name AS Gurantor_Name
		,GEM.Emp_ID
		,GLA.Loan_App_ID
		,GDM.Desig_Name AS G_Desgination
		,GEM.Street_1 + ' ' + GEM.City + ' ' + GEM.Mobile_No + ' ' + GEM.Work_Tel_No AS G_Address
	FROM T0080_EMP_MASTER GEM WITH (NOLOCK)
	INNER JOIN T0120_LOAN_APPROVAL GLA WITH (NOLOCK) ON Isnull(GLA.Guarantor_Emp_ID, 0) = GEM.Emp_ID
	INNER JOIN T0040_DESIGNATION_MASTER GDM WITH (NOLOCK) ON GDM.Desig_ID = GEM.Desig_Id
	) AS qry ON qry.Loan_App_ID = LA.Loan_App_ID
LEFT OUTER JOIN (
	SELECT SUM(isnull(Loan_Apr_Pending_Amount, 0)) AS Pending_loan_Amount
		,Loan_ID
		,Emp_ID
	FROM T0120_LOAN_APPROVAL WITH (NOLOCK)
	GROUP BY Loan_ID
		,Emp_ID
	) AS qry1 ON qry1.Emp_ID = I_Q.Emp_ID
	AND LA.Loan_ID = qry1.Loan_ID
--Added By Mukti(start)19112015 for 2nd Gurantor details
LEFT OUTER JOIN (
	SELECT GEM2.Emp_Full_Name AS Gurantor_Name
		,GEM2.Emp_ID
		,GLA2.Loan_App_ID
		,GDM2.Desig_Name AS G_Desgination
		,GEM2.Street_1 + ' ' + GEM2.City + ' ' + CASE 
			WHEN isnull(GEM2.Mobile_No, '0') = '0'
				THEN ''
			ELSE GEM2.Mobile_No
			END + ' ' + CASE 
			WHEN isnull(GEM2.Work_Tel_No, '0') = '0'
				THEN ''
			ELSE GEM2.Work_Tel_No
			END AS G_Address
	FROM T0080_EMP_MASTER GEM2 WITH (NOLOCK)
	INNER JOIN T0120_LOAN_APPROVAL GLA2 WITH (NOLOCK) ON Isnull(GLA2.Guarantor_Emp_ID2, 0) = GEM2.Emp_ID
	INNER JOIN T0040_DESIGNATION_MASTER GDM2 WITH (NOLOCK) ON GDM2.Desig_ID = GEM2.Desig_Id
	) AS qry2 ON qry2.Loan_App_ID = LA.Loan_App_ID
--Added By Mukti(end)19112015
INNER JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) ON CM.Cmp_Id = EM.Cmp_ID
INNER JOIN T0040_LOAN_Master LM WITH (NOLOCK) ON LM.Loan_Id = LA.Loan_Id
	AND LM.cmp_id = LA.cmp_Id --Mukti 19112015
LEFT OUTER JOIN (
	SELECT LLA.EMP_ID
		,LLA.Loan_App_ID
		,LLA.Loan_Apr_Amount
	FROM T0115_Loan_Level_Approval LLA WITH (NOLOCK)
	INNER JOIN (
		SELECT Max(Rpt_Level) AS Rpt_Level
			,T0115_Loan_Level_Approval.Loan_App_ID
			,T0115_Loan_Level_Approval.Emp_Id
		FROM T0115_Loan_Level_Approval WITH (NOLOCK)
		INNER JOIN #Emp_Cons ON T0115_Loan_Level_Approval.Emp_Id = #Emp_Cons.Emp_ID
		GROUP BY T0115_Loan_Level_Approval.Loan_App_ID
			,T0115_Loan_Level_Approval.Emp_Id
		) AS Qry_1 ON LLA.Loan_App_ID = Qry_1.Loan_App_ID
		AND LLA.Emp_ID = Qry_1.Emp_ID
		AND LLA.Rpt_Level = Qry_1.Rpt_Level
	) AS qry_2 ON LA.Emp_ID = qry_2.EMP_ID
	AND LA.Loan_App_ID = qry_2.Loan_App_ID
WHERE EM.Cmp_ID = @Cmp_ID
	AND Loan_Apr_Date >= @From_Date
	AND Loan_Apr_Date <= @To_Date
	AND la.Loan_App_ID IS NULL

--ended by mansi 13-07-2023
RETURN
