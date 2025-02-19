



---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Appraisal_GET_DASHBOARD_DETAILS]	 
	@Appr_int_Id As Numeric(18,0)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON;
	
	Declare @temp table
	(
		Pending  Numeric(18,0),
		Accepted  Numeric(18,0)
	)
	
	insert into @temp	
	Select Count(Emp_Id)As Pending,0 From dbo.T0090_hrms_appraisal_Initiation_detail WITH (NOLOCK) where Appr_Int_Id=@Appr_Int_Id And Is_Accept=2
	
	update @temp Set Accepted =(select Count(Emp_Id) From dbo.T0090_hrms_appraisal_Initiation_detail WITH (NOLOCK) where Appr_Int_Id=@Appr_Int_Id And Is_Accept=1)
	
	Select * from @temp
	    
	RETURN




