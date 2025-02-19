


---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_EMP_ATTENDANCE_MUSTER_GET_NEW]
	 @Cmp_ID 		numeric
	,@From_Date		datetime
	,@To_Date 		datetime
	,@Branch_ID		numeric
	,@Cat_ID 		numeric 
	,@Grd_ID 		numeric
	,@Type_ID 		numeric
	,@Dept_ID 		numeric
	,@Desig_ID 		numeric
	,@Emp_ID 		numeric
	,@constraint 	varchar(5000)
	,@Report_For	varchar(50) = 'EMP RECORD'	
	,@Type			numeric = 0

AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	declare @Export_type as varchar(max) 
	SET @Export_type = ''

	EXEC [dbo].[SP_RPT_EMP_ATTENDANCE_MUSTER_IN_EXCEL_New]
		@cmp_id = @Cmp_ID
		,@from_date = @From_Date
		,@to_date = @To_Date
		,@branch_id = @Branch_ID
		,@Cat_ID = @Cat_ID
		,@grd_id = @Grd_ID
		,@Type_id = @Type_ID
		,@dept_ID = @Dept_ID
		,@desig_ID = @Desig_ID
		,@emp_id = @Emp_ID
		,@constraint = @constraint
		,@Report_For = @Report_For
		,@Export_Type = @Export_type
		,@Type = @Type


END

