
---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

CREATE PROCEDURE [dbo].[RPT_Joining_Left_Summary_with_Salary_Detail]
	 @Cmp_ID		numeric
	,@From_Date		datetime
	,@To_Date		datetime 
	,@Branch_ID		varchar(Max)
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
	,@Report_Type varchar(50) = ''
	,@Report_Type_Emp  Numeric = 0 -- 0 For Summary Report & 1 For Detiles Report
	,@Report_id Numeric(18,0) = 11
	,@Report_For Numeric = 0  --0 for left Employee & 1 for New Employee ''added jimit 01082015
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

    
    CREATE table #Emp_Cons 
	(      
		Emp_ID numeric ,     
		Branch_ID numeric,
		Increment_ID numeric    
	)  

	exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,@Salary_Cycle_id,@Segment_Id,@Vertical_Id,@SubVertical_Id,@SubBranch_Id,@New_Join_emp,@Left_Emp,0,'0',0,5    
 
	CREATE TABLE #FINAL_TABLE
		(
			CMP_ID INT,
			COMPANY_NAME VARCHAR(150),
			ACTIVE_EMP_COUNT NUMERIC,
			NEW_JOINEE_COUNT NUMERIC,
			LEFT_EMP_COUNT NUMERIC,
			ACTUAL_BASIC NUMERIC(18,4),
			ACTUAL_GROSS NUMERIC(18,4),
			EPF_EMPLOYER_SHARE NUMERIC(18,4),
			ESIC_EMPLOYER_SHARE NUMERIC(18,4),
			TOTAL_PT_AMOUNT NUMERIC(18,4),
			TOTAL_NET_AMOUNT NUMERIC(18,4)
		)

	INSERT INTO #FINAL_TABLE (CMP_ID,COMPANY_NAME,ACTIVE_EMP_COUNT)
	SELECT CM.CMP_ID, CM.Cmp_Name, COUNT(EC.EMP_ID)
	FROM #Emp_Cons EC INNER JOIN 
		T0080_EMP_MASTER EM WITH (NOLOCK) ON EC.Emp_ID = EM.Emp_ID INNER JOIN
		T0010_COMPANY_MASTER CM WITH (NOLOCK) ON EM.Cmp_ID = CM.Cmp_Id
	GROUP BY CM.CMP_ID, CM.Cmp_Name

	UPDATE FT
	SET NEW_JOINEE_COUNT = ISNULL(NEW_JOINEE,0),
		LEFT_EMP_COUNT = ISNULL(LEFT_EMP,0),
		ACTUAL_BASIC = ISNULL(SAL_AMOUNT,0),
		ACTUAL_GROSS = ISNULL(GROSS,0),
		TOTAL_PT_AMOUNT = ISNULL(PT_AMOUNT,0),
		TOTAL_NET_AMOUNT = ISNULL(NET,0),
		EPF_EMPLOYER_SHARE = ISNULL(EPF_EMPLOYER,0),
		ESIC_EMPLOYER_SHARE = ISNULL(ESIC_EMPLOYER,0)
	FROM #FINAL_TABLE FT LEFT OUTER JOIN
		(SELECT COUNT(1) NEW_JOINEE, Cmp_ID 
			FROM T0080_EMP_MASTER WITH (NOLOCK)
		WHERE Date_Of_Join Between @From_Date And @To_Date
		GROUP BY Cmp_ID) New_J On FT.CMP_ID = New_J.Cmp_ID LEFT OUTER JOIN
		(SELECT COUNT(1) LEFT_EMP, Cmp_ID 
			FROM T0080_EMP_MASTER WITH (NOLOCK)
		WHERE Emp_Left_Date Between @From_Date And @To_Date
		GROUP BY Cmp_ID) Left_Emp On FT.CMP_ID = Left_Emp.Cmp_ID LEFT OUTER JOIN
		(SELECT Cmp_ID, SUM(Salary_Amount) SAL_AMOUNT, SUM(GROSS_SALARY) GROSS, SUM(PT_AMOUNT) PT_AMOUNT, SUM(Net_Amount) NET
			FROM T0200_MONTHLY_SALARY WITH (NOLOCK)
		WHERE Month_End_Date Between @From_Date And @To_Date
		GROUP BY Cmp_ID) SALARY On FT.CMP_ID = SALARY.Cmp_ID LEFT OUTER JOIN
		(SELECT MAD.Cmp_ID, SUM(M_AD_Amount) EPF_EMPLOYER
			FROM T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK) INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON MAD.AD_ID = AM.AD_ID
		WHERE To_date Between @From_Date And @To_Date AND AM.AD_DEF_ID = 5
		GROUP BY MAD.Cmp_ID) EPF_EMP On FT.CMP_ID = EPF_EMP.Cmp_ID LEFT OUTER JOIN
		(SELECT MAD.Cmp_ID, SUM(M_AD_Amount) ESIC_EMPLOYER
			FROM T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK) INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON MAD.AD_ID = AM.AD_ID
		WHERE To_date Between @From_Date And @To_Date AND AM.AD_DEF_ID = 6
		GROUP BY MAD.Cmp_ID) ESIC_EMP On FT.CMP_ID = ESIC_EMP.Cmp_ID


		SELECT * FROM #FINAL_TABLE ORDER BY COMPANY_NAME ASC

RETURN 	
