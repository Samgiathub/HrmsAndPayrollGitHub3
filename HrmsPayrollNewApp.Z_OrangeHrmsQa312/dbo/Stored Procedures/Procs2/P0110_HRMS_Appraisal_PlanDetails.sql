---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0110_HRMS_Appraisal_PlanDetails]
	 @HPD_Id numeric(18,0) output,  
	 @Row_ID  numeric(18,0),  
	 @Cmp_ID  numeric(18,0),  
	 @Emp_ID  numeric(18,0),  
	 @Initiateid numeric(18,0),  
	 @Plan_Name nvarchar(500),  --Changed by Deepali -03Jun22
	 @Area nvarchar(500),  --Changed by Deepali -03Jun22
	 @Method_Id numeric(18, 2),
	 @TimeFrame_Id numeric(18, 2),
     @Comments nvarchar(500),  --Changed by Deepali -03Jun22
	 @Approval_Level varchar(20),	
	 @User_Id	numeric(18,0)	= 0,
	 @IP_Address	varchar(30)	= '', 
	 @tran_type			varchar(1) 
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
    
   if @TimeFrame_Id=0
	set @TimeFrame_Id=NULL
   if @Method_Id=0
	set @Method_Id=NULL
--declare @HAO_Id as numeric(18,0)
BEGIN	
	If Upper(@tran_type) ='I'
		Begin
			--delete from T0110_HRMS_Appraisal_PlanDetails Where AO_Id=@Action and cmp_id=@Cmp_ID and Emp_ID=@Emp_ID and InitiateId=@Initiateid and Approval_Level=@Approval_Level
					select @HPD_Id = isnull(max(HPD_Id),0) + 1 from T0110_HRMS_Appraisal_PlanDetails WITH (NOLOCK)
					Insert into T0110_HRMS_Appraisal_PlanDetails
					(
					HPD_Id,
					Row_ID,
					Cmp_ID,
					Emp_ID,
					InitiateId,
					[Plan],
					Area,
					Method_Id,
					TimeFrame_Id,
					Comments,
					Approval_Level
					)
					values
					(
					@HPD_Id,
					@Row_ID,
					@Cmp_ID,
					@Emp_ID,
					@InitiateId,
					@Plan_Name,
					@Area,
					@Method_Id,
					@TimeFrame_Id,
					@Comments,
					@Approval_Level
					)
		END			

END

--SP-10
