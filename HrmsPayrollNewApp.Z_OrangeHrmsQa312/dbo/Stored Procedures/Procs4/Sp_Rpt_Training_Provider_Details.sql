


---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

CREATE PROCEDURE [dbo].[Sp_Rpt_Training_Provider_Details]

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
 
SELECT     TPM.*, TM.Training_name  

FROM         T0040_Hrms_Training_master TM WITH (NOLOCK) RIGHT OUTER JOIN  
             dbo.T0050_HRMS_Training_Provider_master TPM WITH (NOLOCK) ON   
             TM.Training_id = TPM.Training_id  

Return




