


-- =============================================
-- Author:		Sneha
-- ALTER date: 05 Sep 2013
-- Description:	exec P0090_Appraisal_FreezeUnfreeze @cmpid=9,@empid=1284,@appid='25',@emp_status=1,@type='Freeze'
-- exec P0090_Appraisal_FreezeUnfreeze @cmpid=9,@empid=1284,@appid='25',@emp_status=0,@type='Unfreeze'
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0090_Appraisal_FreezeUnfreeze]
	@cmpid as int,
	@empid as int,
	@appid as int,
	@emp_status as int,
	@type as varchar(50)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
    
	declare @app_detail_id as int
	select @app_detail_id=Appr_Detail_Id from T0090_hrms_Appraisal_Initiation_detail WITH (NOLOCK) where Appr_Int_Id=@appid and Emp_Id=@empid
	--select @app_detail_id
	if(@emp_status=0) --for employee
		begin
			if (@type='freeze')
				begin
					--from final score
					Update [T0090_HRMS_FINAL_SCORE]
					set [Inspection_status] =1
					where Appr_Int_Id = @appid and Emp_ID=@empid and Cmp_ID=@cmpid and 
					Emp_Status = @emp_status				
					--from introspection
					Update T0090_Hrms_Employee_Introspection
					set  Inspection_Status = 1
					where Appr_Detail_Id = @app_detail_id and Cmp_ID=@cmpid and 
					Emp_Status = @emp_status				
					--from goal
					Update T0091_Employee_Goal_Score
					set  Goal_status = 1
					where Appr_Detail_Id = @app_detail_id and 
					Emp_Status = @emp_status										
				End
			Else if(@type='Unfreeze')
				begin
					--from final score
					Update [T0090_HRMS_FINAL_SCORE]
					set [Inspection_status] =0
					where Appr_Int_Id = @appid and Emp_ID=@empid and Cmp_ID=@cmpid and 
					Emp_Status = @emp_status				
					--from introspection
					Update T0090_Hrms_Employee_Introspection
					set  Inspection_Status = 0
					where Appr_Detail_Id = @app_detail_id and Cmp_ID=@cmpid and 
					Emp_Status = @emp_status				
					--from goal
					Update T0091_Employee_Goal_Score
					set  Goal_status = 0
					where Appr_Detail_Id = @app_detail_id and 
					Emp_Status = @emp_status					
				End
		End
	else if (@emp_status=1)
		begin
			if (@type='freeze')
				begin
					--from final score
					Update [T0090_HRMS_FINAL_SCORE]
					set [Inspection_status] =1
					where Appr_Int_Id = @appid and 
					Emp_ID=@empid and 
					Cmp_ID=@cmpid and 
					Emp_Status = @emp_status
					--from introspection
					Update T0090_Hrms_Employee_Introspection
					set  Inspection_Status = 1
					where Appr_Detail_Id = @app_detail_id and Cmp_ID=@cmpid and 
					Emp_Status = @emp_status
					--from goal
					Update T0091_Employee_Goal_Score
					set  Goal_status = 1
					where Appr_Detail_Id = @app_detail_id and 
					Emp_Status = @emp_status					
				End
			Else if(@type='Unfreeze')
				begin
					--from final score
					Update [T0090_HRMS_FINAL_SCORE]
					set [Inspection_status] =0
					where Appr_Int_Id = @appid and Emp_ID=@empid and Cmp_ID=@cmpid and 
					Emp_Status = @emp_status
					--from introspection
					Update T0090_Hrms_Employee_Introspection
					set  Inspection_Status = 0
					where Appr_Detail_Id = @app_detail_id and Cmp_ID=@cmpid and 
					Emp_Status = @emp_status
					
					--select @app_detail_id,@emp_status
					--from goal
					Update T0091_Employee_Goal_Score
					set  Goal_status = 0
					where Appr_Detail_Id = @app_detail_id and 
					Emp_Status = @emp_status	 
				End
		End
END


