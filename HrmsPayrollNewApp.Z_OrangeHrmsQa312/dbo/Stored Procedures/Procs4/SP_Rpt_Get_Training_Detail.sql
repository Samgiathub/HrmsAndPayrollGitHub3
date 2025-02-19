




CREATE PROCEDURE [dbo].[SP_Rpt_Get_Training_Detail]
	 @Cmp_ID		numeric
	,@From_Date		datetime
	,@To_Date		datetime 
	,@Branch_ID		numeric  
	,@Cat_ID		numeric  
	,@Grd_ID		numeric 
	,@Type_ID		numeric 
	,@Dept_ID		numeric 
	,@Desig_ID		numeric 
	,@Emp_ID		numeric 
	,@Constraint	varchar(5000) = ''
    ,@Training_id   NUMERIC(18,0) 
	
	
AS

        SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON



	/* SET NOCOUNT ON */
	
	  Select * from V0120_HRMS_TRAINING_APPROVAL where cmp_id=@cmp_id and Training_id=@Training_id
	RETURN




