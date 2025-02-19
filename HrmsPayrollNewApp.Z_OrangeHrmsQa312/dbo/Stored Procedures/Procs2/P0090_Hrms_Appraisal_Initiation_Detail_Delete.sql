


-- =============================================
-- Author:		Ripal Patel
-- Create date: 16 July 2014
-- Description:	<Description,,>
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0090_Hrms_Appraisal_Initiation_Detail_Delete]
	@Appr_Int_Id		Numeric(18, 0),
	@Emp_Id				Numeric(18,0)
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
    
	--Final Score Detail delete
	Delete from T0090_HRMS_FINAL_SCORE where Appr_Int_Id = @Appr_Int_Id and Emp_ID = @Emp_Id
	--Skill Data Delete
	Declare @start_date as datetime
	Declare @End_date as datetime
	select @start_date = start_date from t0090_hrms_appraisal_initiation_detail WITH (NOLOCK) where Appr_Int_Id = @Appr_Int_Id  and Emp_ID = @Emp_Id
	select @End_date = End_date from t0090_hrms_appraisal_initiation_detail WITH (NOLOCK) where Appr_Int_Id = @Appr_Int_Id  and Emp_ID = @Emp_Id
	
	update T0090_HRMS_EMP_SKILL_SETTING Set
		Skill_Rate_Employee = null,
		Skill_Rate_Superior = null
	where
		Skill_R_ID in (select Skill_R_ID from T0055_HRMS_EMP_SKILL_DETAILS WITH (NOLOCK) where
							for_date >= @start_date and for_date <= @End_date and 
							emp_id = @Emp_Id)
	
	--Goal Data Delete
	Delete from t0091_Employee_Goal_Score 
		where appr_detail_id in (select Appr_Detail_Id from T0090_Hrms_Appraisal_Initiation_Detail WITH (NOLOCK)
										where Appr_Int_Id = @Appr_Int_Id  and Emp_ID = @Emp_Id)
	--Introspection Data Delete
	Delete from T0090_Hrms_Employee_Introspection 
		where appr_detail_id in (select Appr_Detail_Id from T0090_Hrms_Appraisal_Initiation_Detail WITH (NOLOCK)
										where Appr_Int_Id = @Appr_Int_Id  and Emp_ID = @Emp_Id)

	Delete From T0090_Hrms_Appraisal_Initiation_Detail where Appr_Int_Id = @Appr_Int_Id  and Emp_ID = @Emp_Id	
	If Not Exists(Select Appr_Detail_Id from T0090_Hrms_Appraisal_Initiation_Detail WITH (NOLOCK) Where Appr_Int_Id = @Appr_Int_Id)							
		Begin
				Delete From T0090_Hrms_Appraisal_Initiation Where Appr_Int_Id = @Appr_Int_Id
		End
	
END

