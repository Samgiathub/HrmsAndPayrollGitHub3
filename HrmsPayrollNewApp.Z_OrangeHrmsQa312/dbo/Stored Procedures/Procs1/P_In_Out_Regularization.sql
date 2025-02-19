-- =============================================
-- Author:		<Jaina>
-- Create date: <26-02-2018>
-- Description:	<Bulk Regularization>
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

-- =============================================
CREATE PROCEDURE [dbo].[P_In_Out_Regularization]
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

	EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,0 ,0 ,@Segment_Id,@Vertical_Id,@SubVertical_ID,@SubBranch_ID,0,0,0,0,0,0
	
	
	
	if @Emp_ID is not null
		SET @CONSTRAINT = CAST(@Emp_ID AS varchar(10))
	ELSE IF IsNull(@CONSTRAINT,'') = ''
		BEGIN 
			SET @CONSTRAINT = NULL
			SELECT @CONSTRAINT = COALESCE(@CONSTRAINT + '#', '') + CAST(Emp_ID As Varchar(10)) FROM #Emp_Cons 
		END

	IF @Report_For <> 'BulkRegularization_Mobile'
		SET @Report_For = 'BulkRegularization'
		
	exec SP_RPT_EMP_IN_OUT_MUSTER_HOME_GET @Cmp_ID=@Cmp_ID,@From_Date=@From_Date,@To_Date=@To_Date,@Branch_ID=@Branch_ID,@Cat_ID=@Cat_ID,@Grd_ID=@Grd_ID,@Type_ID=@Type_ID,@Dept_ID=@Dept_ID,@Desig_ID=@Desig_ID,@Emp_ID =0,@Constraint=@constraint,@Report_for=@Report_For,@Shift_ID=@Shift_ID
END


