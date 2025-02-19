
CREATE PROCEDURE [dbo].[mobile_HRMS_P_In_Out_Regularization]
	 @Cmp_ID 		numeric
	,@From_Date		datetime
	,@To_Date 		datetime
	,@Branch_ID		NUMERIC(18,2)
	,@Cat_ID 		NUMERIC(18,2)
	,@Grd_ID 		NUMERIC(18,2)
	,@Type_ID 		NUMERIC(18,2)
	,@Dept_ID 		NUMERIC(18,2)
	,@Desig_ID 		NUMERIC(18,2)
	,@Emp_ID 		NUMERIC(18,2)	
	,@constraint 	varchar(MAX)
	,@Report_For	varchar(50) = 'EMP RECORD'
	,@Segment_Id	NUMERIC(18,2)
	,@SubBranch_ID	NUMERIC(18,2)
	,@Vertical_Id	NUMERIC(18,2)
	,@SubVertical_ID NUMERIC(18,2)
	,@Shift_ID      NUMERIC = 0
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN

	
	IF @Branch_ID = 0  
		set @Branch_ID = null
		
	IF @Cat_ID = 0  
		set @Cat_ID = null

	IF @Grd_ID = 0  
		set @Grd_ID = null

	IF @Type_ID = 0  
		set @Type_ID = null

	IF @Dept_ID = 0  
		set @Dept_ID = null

	IF @Desig_ID = 0  
		set @Desig_ID = null

	IF @Emp_ID = 0  
		set @Emp_ID = null
		
	if @Segment_Id = 0
		set @Segment_Id = NULL
		
	if @SubBranch_ID = 0
		set @SubBranch_ID = NULL
		
	if @Vertical_Id = 0
		set @Vertical_Id = NULL
		
	if @SubVertical_ID = 0
		set @SubVertical_ID = NULL
	
	CREATE TABLE #Emp_Cons 
	(      
		Emp_ID numeric ,     
		Branch_ID numeric,
		Increment_ID numeric    
	)  

	EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint 
	,0 ,0 ,@Segment_Id,@Vertical_Id,@SubVertical_ID,@SubBranch_ID,0,0,0,0,0,0
	

	--Select	T.emp_id,emp_full_name,Alpha_Emp_Code,cast(Alpha_Emp_Code as varchar) + ' - '+ Emp_Full_Name as Emp_Name_Code,
	--		I.branch_id,T.Dept_ID,BM.branch_name,DEPT.dept_name,
	--		Dm.Desig_Name , T.Date_Of_Join,T.Cmp_ID,co.Cmp_Name,I.CTC  --added jimit 03022016
	--		,I.Desig_Id  --Added by Jaina 15-03-2019
	--		,I.Increment_ID
	--INTO #TMP
	--FROM T0080_EMP_MASTER T WITH (NOLOCK) INNER JOIN #EMP_CONS E ON T.Emp_ID=E.EMP_ID --	AND T.Increment_ID=E.Increment_ID
	--	INNER JOIN (
	--					SELECT	INCREMENT_ID,I.Emp_ID,I.Cmp_ID,I.Branch_ID, I.Dept_ID,I.Desig_Id,I.CTC
	--					FROM	T0095_INCREMENT I WITH (NOLOCK)
	--					WHERE	I.Increment_ID = (
	--												SELECT	TOP 1 I1.Increment_ID
	--												FROM	T0095_INCREMENT I1 WITH (NOLOCK)
	--												WHERE	I1.Emp_ID=I.Emp_ID AND I1.Cmp_ID=I.Cmp_ID 
	--												ORDER	BY I1.Increment_Effective_Date DESC, I1.Increment_ID DESC
	--												)
	--					) I ON  T.Emp_ID=I.Emp_ID AND T.Cmp_ID=I.Cmp_ID
	--	INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I.CMP_ID=BM.CMP_ID AND I.Branch_ID=BM.Branch_ID
	--	LEFT OUTER JOIN  T0040_DEPARTMENT_MASTER DEPT WITH (NOLOCK) ON I.Cmp_ID=DEPT.Cmp_Id AND I.Dept_ID=DEPT.Dept_Id
	--	LEFT OUTER JOIN  T0040_DESIGNATION_MASTER DM WITH (NOLOCK) On Dm.Desig_ID = I.Desig_Id AND I.Cmp_ID = DM.Cmp_ID	
	--	INNER JOIN T0010_COMPANY_MASTER co WITH (NOLOCK) on co.Cmp_Id=T.Cmp_ID		
	--	where e.Branch_ID = 0
		
	
	--update E set 
	--E.Branch_ID = T.Branch_ID,
	--E.Increment_ID = T.Increment_ID
	--from #Emp_Cons E inner join #TMP T on E.Emp_ID = T.Emp_ID

	if @Emp_ID is not null
		SET @CONSTRAINT = CAST(@Emp_ID AS varchar(10))
	ELSE IF IsNull(@CONSTRAINT,'') = ''
		BEGIN 
			SET @CONSTRAINT = NULL
			SELECT @CONSTRAINT = COALESCE(@CONSTRAINT + '#', '') + CAST(Emp_ID As Varchar(10)) FROM #Emp_Cons 
		END

	IF @Report_For <> 'BulkRegularization_Mobile'
		SET @Report_For = 'BulkRegularization'
		
	exec Mobile_HRMS_SP_RPT_EMP_IN_OUT_MUSTER_HOME_GET @Cmp_ID=@Cmp_ID,@From_Date=@From_Date,@To_Date=@To_Date,@Branch_ID=@Branch_ID
	,@Cat_ID=@Cat_ID,@Grd_ID=@Grd_ID,@Type_ID=@Type_ID,@Dept_ID=@Dept_ID,@Desig_ID=@Desig_ID,@Emp_ID =0,@Constraint=@constraint,
	@Report_for=@Report_For,@Shift_ID=@Shift_ID
END


