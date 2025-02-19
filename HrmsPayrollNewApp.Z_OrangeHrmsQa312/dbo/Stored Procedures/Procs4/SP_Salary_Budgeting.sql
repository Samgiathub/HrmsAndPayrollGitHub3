



 ---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Salary_Budgeting]
	@Cmp_ID numeric(18,0),
	@Groupby varchar(50),
	@DepartmentID varchar(MAX) = NULL,
	@BranchID varchar(MAX) = NULL,
	@VerticalID varchar(MAX) = NULL,
	@SubVeticalID varchar(MAX) = NULL,
	@InitFromDate datetime    = NULL,--added on 07/10/2017 sneha
	@InitToDate		datetime  = NULL,--added on 07/10/2017 sneha
	@Condition_Str	varchar(MAX) = NULL --added on 14/11/2017 sneha 
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

IF @DepartmentID IS NULL OR @DepartmentID = '0'
	BEGIN
		SELECT @DepartmentID = COALESCE(@DepartmentID + '#', '') + CAST(Dept_ID AS NVARCHAR(5)) FROM T0040_DEPARTMENT_MASTER WITH (NOLOCK) WHERE Cmp_ID=@Cmp_ID 		
		SET @DepartmentID = @DepartmentID + '#0'
	END
IF @BranchID IS NULL OR @BranchID = '0'
	BEGIN	
		SELECT @BranchID = COALESCE(@BranchID + '#', '') + CAST(Branch_ID AS NVARCHAR(5)) FROM T0030_BRANCH_MASTER WITH (NOLOCK) WHERE Cmp_ID=@Cmp_ID 
		SET @BranchID = @BranchID + '#0'
	END
IF @VerticalID IS NULL OR @VerticalID = '0'
	BEGIN
		SELECT @VerticalID = COALESCE(@VerticalID + '#', '') + CAST(Vertical_ID AS NVARCHAR(5)) FROM T0040_Vertical_Segment WITH (NOLOCK) WHERE Cmp_ID=@Cmp_ID 
		SET @VerticalID = @VerticalID + '#0'		
	END
IF @SubVeticalID IS NULL OR @SubVeticalID = '0'
	BEGIN
		SELECT @SubVeticalID = COALESCE(@SubVeticalID + '#', '') + CAST(SubVertical_ID AS NVARCHAR(5)) FROM T0050_SubVertical WITH (NOLOCK) WHERE Cmp_ID=@Cmp_ID 
		SET @SubVeticalID = @SubVeticalID + '#0'
	END

IF @Condition_Str is NULL
	SET @Condition_Str= ''
	
	IF @Groupby <> 'Appraisal Rating'
		BEGIN
		SELECT EM.Emp_ID AS 'ID',EM.Alpha_Emp_Code AS 'Code', (EM.Alpha_Emp_Code +' - '+EM.Initial + ' '+ EM.Emp_First_Name + ' ' + ISNULL(EM.Emp_Second_Name,'')+' '+ ISNULL(EM.Emp_Last_Name,'')  ) AS 'Name',
		ROUND(CAST(ISNULL(IC.Basic_Salary,0) AS numeric(18,2)),2) AS 'OldBasic_Salary',
		ROUND(CAST(ISNULL(IC.Gross_Salary,0) AS numeric(18,2)),2) AS 'OldGross_Salary',
		--ROUND(CAST(SUM((((TEED.E_AD_PERCENTAGE * ISNULL(IC.Basic_Salary,0))/100) + TEED.E_AD_AMOUNT)) + ISNULL(IC.Basic_Salary,0) AS numeric(18,2)),2) AS 'OldCTC',
		ISNULL(ROUND(CAST(SUM(TEED.E_AD_AMOUNT) + IC.Basic_Salary AS numeric(18,2)),2),0.0) AS 'OldCTC',
		
		0 AS 'IncBasicAmt',0 AS 'IncGrossAmt',0 AS 'IncCTCAmt',0 AS 'NewBasicAmt',0 AS 'NewGrossAmt',0 AS 'NewCTCAmt',
		ISNULL(IC.Branch_ID,0) AS 'Branch_ID',ISNULL(IC.subBranch_ID,0) AS 'SubBranch_ID',
		ISNULL(IC.Grd_ID,0) AS 'Grd_ID',ISNULL(IC.Type_ID,0) AS 'Type_ID',ISNULL(IC.Dept_ID,0) AS 'Dept_ID',ISNULL(IC.Desig_Id,0) AS 'Desig_ID',
		ISNULL(IC.Cat_ID,0) AS 'Cat_ID',ISNULL(IC.Segment_ID,0) AS 'Segment_ID',ISNULL(IC.Vertical_ID,0) AS 'Vertical_ID',
		ISNULL(IC.SubVertical_ID,0) AS 'SubVertical_ID',0 AS 'Increment'
		INTO #EmpSalary
		FROM T0095_INCREMENT IC WITH (NOLOCK)
		INNER JOIN
		(
			 
			SELECT P.Increment_ID,P.Increment_Effective_Date,P.Emp_ID FROM T0095_INCREMENT P WITH (NOLOCK)
			INNER JOIN
				(
					SELECT Max(Increment_ID) AS 'Increment_ID',Max(Increment_Effective_Date) as 'Increment_Effective_Date',Emp_ID
					FROM T0095_INCREMENT WITH (NOLOCK)
					GROUP BY Emp_ID
				)T ON P.Increment_Effective_Date =T.Increment_Effective_Date AND P.Increment_ID = T.Increment_ID AND P.Emp_ID = T.Emp_ID
		) AS TIC ON IC.Increment_ID = TIC.Increment_ID
		--INNER JOIN T0100_EMP_EARN_DEDUCTION  TEED ON TIC.Increment_ID = TEED.Increment_ID
		INNER JOIN
		(
			SELECT ED.INCREMENT_ID,(CASE WHEN ED.E_AD_FLAG = 'I' THEN ED.E_AD_AMOUNT ELSE 0.0 END) AS 'E_AD_AMOUNT' 
			FROM T0100_EMP_EARN_DEDUCTION ED WITH (NOLOCK)
			INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON ED.AD_ID = AM.AD_ID
			WHERE AM.AD_PART_OF_CTC = 1 -- AND ED.INCREMENT_ID = 22
		) TEED  ON TIC.Increment_ID = TEED.Increment_ID
		INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON IC.Emp_ID = EM.Emp_ID 
		INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON IC.Grd_ID = GM.Grd_ID
		WHERE IC.Cmp_ID = @Cmp_ID AND EM.Emp_Left<>'Y'
		GROUP BY EM.Emp_ID,EM.Alpha_Emp_Code,EM.Emp_First_Name,EM.Initial,EM.Emp_Second_Name,EM.Emp_Last_Name,
		IC.Branch_ID,IC.subBranch_ID,IC.Grd_ID,IC.Type_ID,IC.Dept_ID,IC.Desig_Id,
		IC.Cat_ID,IC.Segment_ID,IC.Vertical_ID,IC.SubVertical_ID,IC.Gross_Salary,IC.Basic_Salary 
	
		--SELECT * FROM #EmpSalary
		--RETURN
		END	
	ELSE
		BEGIN
			SELECT EM.Emp_ID AS 'ID',EM.Alpha_Emp_Code AS 'Code', (EM.Alpha_Emp_Code +' - '+EM.Initial + ' '+ EM.Emp_First_Name + ' ' + ISNULL(EM.Emp_Second_Name,'')+' '+ ISNULL(EM.Emp_Last_Name,'')  ) AS 'Name',
			ROUND(CAST(ISNULL(IC.Basic_Salary,0) AS numeric(18,2)),2) AS 'OldBasic_Salary',
			ROUND(CAST(ISNULL(IC.Gross_Salary,0) AS numeric(18,2)),2) AS 'OldGross_Salary',
			--ROUND(CAST(SUM((((TEED.E_AD_PERCENTAGE * ISNULL(IC.Basic_Salary,0))/100) + TEED.E_AD_AMOUNT)) + ISNULL(IC.Basic_Salary,0) AS numeric(18,2)),2) AS 'OldCTC',
			ISNULL(ROUND(CAST(SUM(TEED.E_AD_AMOUNT) + IC.Basic_Salary AS numeric(18,2)),2),0.0) AS 'OldCTC',
			
			0 AS 'IncBasicAmt',0 AS 'IncGrossAmt',0 AS 'IncCTCAmt',0 AS 'NewBasicAmt',0 AS 'NewGrossAmt',0 AS 'NewCTCAmt',
			ISNULL(IC.Branch_ID,0) AS 'Branch_ID',ISNULL(IC.subBranch_ID,0) AS 'SubBranch_ID',
			ISNULL(IC.Grd_ID,0) AS 'Grd_ID',ISNULL(IC.Type_ID,0) AS 'Type_ID',ISNULL(IC.Dept_ID,0) AS 'Dept_ID',ISNULL(IC.Desig_Id,0) AS 'Desig_ID',
			ISNULL(IC.Cat_ID,0) AS 'Cat_ID',ISNULL(IC.Segment_ID,0) AS 'Segment_ID',ISNULL(IC.Vertical_ID,0) AS 'Vertical_ID',
			ISNULL(IC.SubVertical_ID,0) AS 'SubVertical_ID',0 AS 'Increment',HI4.Achivement_Id--,RM.Range_Level
			INTO #EmpSalary1
			FROM T0095_INCREMENT IC WITH (NOLOCK)
			INNER JOIN
			(
				 
				SELECT P.Increment_ID,P.Increment_Effective_Date,P.Emp_ID FROM T0095_INCREMENT P WITH (NOLOCK)
				INNER JOIN
					(
						SELECT Max(Increment_ID) AS 'Increment_ID',Max(Increment_Effective_Date) as 'Increment_Effective_Date',Emp_ID
						FROM T0095_INCREMENT WITH (NOLOCK)
						GROUP BY Emp_ID
					)T ON P.Increment_Effective_Date =T.Increment_Effective_Date AND P.Increment_ID = T.Increment_ID AND P.Emp_ID = T.Emp_ID
			) AS TIC ON IC.Increment_ID = TIC.Increment_ID
			--INNER JOIN T0100_EMP_EARN_DEDUCTION  TEED ON TIC.Increment_ID = TEED.Increment_ID
			INNER JOIN
			(
				SELECT ED.INCREMENT_ID,(CASE WHEN ED.E_AD_FLAG = 'I' THEN ED.E_AD_AMOUNT ELSE 0.0 END) AS 'E_AD_AMOUNT' 
				FROM T0100_EMP_EARN_DEDUCTION ED WITH (NOLOCK)
				INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON ED.AD_ID = AM.AD_ID
				WHERE AM.AD_PART_OF_CTC = 1 -- AND ED.INCREMENT_ID = 22
			) TEED  ON TIC.Increment_ID = TEED.Increment_ID
			INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON IC.Emp_ID = EM.Emp_ID 
			INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON IC.Grd_ID = GM.Grd_ID
			INNER JOIN 
			(
				SELECT HI2.InitiateId,HI2.Emp_Id,HI2.SA_Startdate,HI2.Overall_Score,HI2.Achivement_Id
				FROM T0050_HRMS_InitiateAppraisal HI2 WITH (NOLOCK) INNER JOIN
				(
					SELECT MAX(HI.InitiateId)InitiateId,HI.Emp_Id,HI1.SA_Startdate
					FROM T0050_HRMS_InitiateAppraisal HI WITH (NOLOCK)
					INNER JOIN (
									SELECT MAX(SA_Startdate)SA_Startdate,Emp_Id
													FROM  T0050_HRMS_InitiateAppraisal WITH (NOLOCK)
													WHERE Overall_Status = 5 AND SA_Startdate>= @InitFromDate AND SA_Startdate <= @InitToDate 
									GROUP BY Emp_Id		
							  )HI1 ON HI1.Emp_Id = HI.Emp_Id
					WHERE Overall_Status = 5
					GROUP BY HI.Emp_Id,HI1.SA_Startdate
				)HI3 ON HI3.InitiateId = HI2.InitiateId AND HI3.Emp_Id = HI2.Emp_Id
			)HI4 ON HI4.Emp_Id = EM.Emp_ID 
			--INNER JOIN T0040_HRMS_RangeMaster RM ON RM.Range_ID = HI4.Achivement_Id 
			WHERE IC.Cmp_ID = @Cmp_ID AND EM.Emp_Left<>'Y'
			GROUP BY EM.Emp_ID,EM.Alpha_Emp_Code,EM.Emp_First_Name,EM.Initial,EM.Emp_Second_Name,EM.Emp_Last_Name,
			IC.Branch_ID,IC.subBranch_ID,IC.Grd_ID,IC.Type_ID,IC.Dept_ID,IC.Desig_Id,
			IC.Cat_ID,IC.Segment_ID,IC.Vertical_ID,IC.SubVertical_ID,IC.Gross_Salary,IC.Basic_Salary 
				,HI4.Achivement_Id--,RM.Range_Level
				
			--SELECT * FROM #EmpSalary1 order by id
			--RETURN
		END

IF @Groupby = 'Branch'
	BEGIN
	
		SELECT BM.Branch_ID AS 'ID',BM.Branch_Code AS 'Code',BM.Branch_Name AS 'Name',0 AS 'Increment', 
		SUM(OldBasic_Salary) AS 'OldBasic_Salary',
		SUM(OldGross_Salary) AS 'OldGross_Salary',
		SUM(OldCTC) AS 'OldCTC',
		0 AS 'IncBasicAmt',0 AS 'IncGrossAmt',0 AS 'IncCTCAmt',0 AS 'NewBasicAmt',0 AS 'NewGrossAmt',0 AS 'NewCTCAmt'
		FROM #EmpSalary EM
		INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON EM.Branch_ID = BM.Branch_ID
		WHERE BM.Branch_ID IN (SELECT data FROM dbo.Split(@BranchID,'#'))
		GROUP BY BM.Branch_ID,BM.Branch_Name,BM.Branch_Code
		 
	END
ELSE IF @Groupby = 'Department'
	BEGIN
		 
		SELECT DM.Dept_Id AS 'ID',DM.Dept_Code AS 'Code', DM.Dept_Name AS 'Name',0 AS 'Increment',
		SUM(OldBasic_Salary) AS 'OldBasic_Salary',
		SUM(OldGross_Salary) AS 'OldGross_Salary',
		SUM(OldCTC) AS 'OldCTC',
		0 AS 'IncBasicAmt',0 AS 'IncGrossAmt',0 AS 'IncCTCAmt',0 AS 'NewBasicAmt',0 AS 'NewGrossAmt',0 AS 'NewCTCAmt'
		FROM #EmpSalary EM
		INNER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON EM.Dept_ID = DM.Dept_Id
		WHERE EM.Dept_ID IN (SELECT data FROM dbo.Split(@DepartmentID,'#'))
		GROUP BY DM.Dept_Id,DM.Dept_Name,DM.Dept_Code
	END
ELSE IF @Groupby = 'Designation'
	BEGIN
		 
		SELECT TDM.Desig_ID AS 'ID',TDM.Desig_Code AS 'Code', TDM.Desig_Name AS 'Name',0 AS 'Increment',
		SUM(OldBasic_Salary) AS 'OldBasic_Salary',
		SUM(OldGross_Salary) AS 'OldGross_Salary',
		SUM(OldCTC) AS 'OldCTC',
		0 AS 'IncBasicAmt',0 AS 'IncGrossAmt',0 AS 'IncCTCAmt',0 AS 'NewBasicAmt',0 AS 'NewGrossAmt',0 AS 'NewCTCAmt'
		FROM #EmpSalary EM
		INNER JOIN T0040_DESIGNATION_MASTER TDM WITH (NOLOCK) ON EM.Desig_Id = TDM.Desig_ID
		GROUP BY TDM.Desig_ID,TDM.Desig_Name,TDM.Desig_Code
	END
ELSE IF @Groupby = 'Grade'
	BEGIN
		 
		SELECT GM.Grd_ID AS 'ID','' AS 'Code', GM.Grd_Name AS 'Name',0 AS 'Increment',
		SUM(OldBasic_Salary) AS 'OldBasic_Salary',
		SUM(OldGross_Salary) AS 'OldGross_Salary',
		SUM(OldCTC) AS 'OldCTC',
		0 AS 'IncBasicAmt',0 AS 'IncGrossAmt',0 AS 'IncCTCAmt',0 AS 'NewBasicAmt',0 AS 'NewGrossAmt',0 AS 'NewCTCAmt'
		FROM #EmpSalary EM
		INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON EM.Grd_ID = GM.Grd_ID
		GROUP BY GM.Grd_ID,GM.Grd_Name
	END
ELSE IF @Groupby = 'Employee'
	BEGIN
		
		SELECT * FROM #EmpSalary 
		WHERE Branch_ID IN (SELECT data FROM dbo.Split(@BranchID,'#')) 
		AND Dept_ID IN (SELECT data FROM dbo.Split(@DepartmentID,'#')) 
		AND Vertical_ID IN (SELECT data FROM dbo.Split(@VerticalID,'#')) 
		AND SubVertical_ID IN (SELECT data FROM dbo.Split(@SubVeticalID,'#')) 
			 
		
	END
ELSE IF @Groupby = 'Appraisal Rating'	
	BEGIN
		DECLARE @Query VARCHAR(MAX)	
		
		SET @Query= ' SELECT Range_AchievementId  AS ''ID'','''' AS ''Code'',RM.Range_Level as ''Name'',0 AS ''Increment'',
					SUM(OldBasic_Salary) AS ''OldBasic_Salary'',
					SUM(OldGross_Salary) AS ''OldGross_Salary'',
					SUM(OldCTC) AS ''OldCTC'',
					0 AS ''IncBasicAmt'',0 AS ''IncGrossAmt'',0 AS ''IncCTCAmt'',0 AS ''NewBasicAmt'',0 AS ''NewGrossAmt'',0 AS ''NewCTCAmt''
					--,Branch_ID,SubBranch_id,Grd_Id,TYPE_ID,dept_Id,desig_Id,Cat_id,Segment_Id,Vertical_Id,SubVertical_Id,Increment,Achivement_Id
					FROM #EmpSalary1 EM
					INNER JOIN T0040_HRMS_RangeMaster RM WITH (NOLOCK) On RM.Range_ID = EM.Achivement_Id
					WHERE Branch_ID IN (SELECT data FROM dbo.Split(''' + @BranchID + ''',''#'')) 
					AND Dept_ID IN (SELECT data FROM dbo.Split(''' + @DepartmentID + ''',''#'')) 
					AND Vertical_ID IN (SELECT data FROM dbo.Split('''+ @VerticalID + ''',''#'')) 
					AND SubVertical_ID IN (SELECT data FROM dbo.Split('''+ @SubVeticalID + ''',''#''))'		
					--,Branch_ID,SubBranch_id,Grd_Id,TYPE_ID,dept_Id,desig_Id,Cat_id,Segment_Id,Vertical_Id,SubVertical_Id,Increment,Achivement_Id
	--Range_ID
		IF @Condition_Str =''  
			EXEC(@Query + ' GROUP BY RM.Range_AchievementId,RM.Range_Level')
		ELSE
			EXEC(@Query + @Condition_Str + ' GROUP BY RM.Range_AchievementId,RM.Range_Level')
	END	
	
