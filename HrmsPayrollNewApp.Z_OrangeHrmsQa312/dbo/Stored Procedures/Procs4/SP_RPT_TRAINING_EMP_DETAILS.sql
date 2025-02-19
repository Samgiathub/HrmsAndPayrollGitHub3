
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_TRAINING_EMP_DETAILS]
	
	 @Cmp_ID		numeric
	,@From_Date		datetime
	,@To_Date		datetime 
	,@Branch_ID		numeric   = 0
	,@Cat_ID        numeric = 0
	,@Grd_ID		numeric = 0
	,@Type_ID       numeric = 0  
	,@Dept_ID		numeric  = 0
	,@Desig_ID		numeric = 0
	,@Emp_ID		numeric  = 0
	,@Constraint	varchar(5000) = ''
	,@training_id    numeric = 8
AS
	
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	if @Branch_ID = 0
		set @Branch_ID = null
	if @Dept_ID = 0
		set @Dept_ID = null
	if @Grd_ID = 0
		set @Grd_ID = null
	if @Emp_ID = 0
		set @Emp_ID = null
	If @Desig_ID = 0
		set @Desig_ID = null
    if @Type_ID = 0
		set @Type_ID = null		
	if @Cat_ID = 0
		set @Cat_ID = null	
	

SELECT     TED.Tran_emp_Detail_ID, TED.Training_App_ID, 
                      TED.Training_Apr_ID, TED.Emp_tran_status, 
                      TED.cmp_id, 
                      dbo.V0080_Employee_Master.Dept_Name, dbo.V0080_Employee_Master.Emp_Full_Name_new, 
                      TED.Emp_ID, dbo.V0080_Employee_Master.Desig_Name, 
                      dbo.V0080_Employee_Master.Emp_First_Name, TA.Training_id, 
                      TA.Training_Date, TM.Training_name, 
                      TA.Description, TA.Training_End_Date, 
                      CASE WHEN TA.Training_Type = 0 THEN 'Internal' ELSE 'External' END AS Type, TA.emp_feedback, 
                      TA.Sup_feedback, TP.Provider_Name, 
                       dbo.V0080_Employee_Master.Emp_Full_Name, dbo.V0080_Employee_Master.Desig_Id, 
                      dbo.V0080_Employee_Master.Dept_ID, dbo.V0080_Employee_Master.Branch_ID, dbo.V0080_Employee_Master.Emp_code
FROM	T0120_HRMS_TRAINING_APPROVAL TA  WITH (NOLOCK) 
		LEFT OUTER JOIN T0050_HRMS_Training_Provider_master TP WITH (NOLOCK) ON TA.Training_Pro_ID = TP.Training_Pro_ID 
		LEFT OUTER JOIN T0040_Hrms_Training_master TM WITH (NOLOCK) ON TA.Training_id = TM.Training_id 
		RIGHT OUTER JOIN T0130_HRMS_TRAINING_EMPLOYEE_DETAIL TED WITH (NOLOCK) ON TA.Training_Apr_ID = TED.Training_Apr_ID 
		LEFT OUTER JOIN V0080_Employee_Master ON TED.Emp_ID = dbo.V0080_Employee_Master.Emp_ID 
where	ta.Training_Date >= cast(@From_Date as varchar(12)) and ta.Training_End_Date <= @To_Date and ta.cmp_id = @cmp_id and Emp_tran_status = 1 and ta.training_apr_id = isnull(@training_id,0) order by emp_first_name asc
	RETURN




