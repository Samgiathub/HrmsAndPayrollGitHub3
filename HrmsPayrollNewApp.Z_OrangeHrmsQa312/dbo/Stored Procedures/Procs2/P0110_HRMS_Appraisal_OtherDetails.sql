
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0110_HRMS_Appraisal_OtherDetails]
	 @HAO_Id numeric(18,0) output,  
	 @Cmp_ID  numeric(18,0),  
	 @Emp_ID  numeric(18,0),  
	 @Initiateid numeric(18,0),  
	 @Action numeric(18, 0),
	 @Justification nvarchar(Max), --Changed by Deepali -02Jun22
	 @TimeFrame_Id numeric(18, 2),
     @Promo_Desig numeric(18, 2),
     @From_Date datetime,
     @To_Date datetime,
	 @Approval_Level nvarchar(10),	--Changed by Deepali -02Jun22
	 @Is_Applicable int,
	 @User_Id	numeric(18,0)	= 0,
	 @IP_Address	varchar(30)	= '', 
	 @tran_type			varchar(1) 
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

    
--declare @HAO_Id as numeric(18,0)
BEGIN	
	If Upper(@tran_type) ='I'
		Begin
			--delete from T0110_HRMS_Appraisal_OtherDetails Where AO_Id=@Action and cmp_id=@Cmp_ID and Emp_ID=@Emp_ID and InitiateId=@Initiateid and Approval_Level=@Approval_Level
			
			if not exists(select 1 from T0110_HRMS_Appraisal_OtherDetails WITH (NOLOCK) where AO_Id=@Action and cmp_id=@Cmp_ID and Emp_ID=@Emp_ID and InitiateId=@Initiateid and Approval_Level=@Approval_Level)
				BEGIN
				print 'm'
					select @HAO_Id = isnull(max(HAO_Id),0) + 1 from T0110_HRMS_Appraisal_OtherDetails WITH (NOLOCK)
					Insert into T0110_HRMS_Appraisal_OtherDetails
					(
					HAO_Id,
					Cmp_ID,
					Emp_ID,
					InitiateId,
					AO_Id,
					Justification,
					TimeFrame_Id,
					Promo_Desig,
					From_Date,
					To_Date,
					Approval_Level,
					Is_Applicable
					)
					values
					(
					@HAO_Id,
					@Cmp_ID,
					@Emp_ID,
					@InitiateId,
					@Action,
					@Justification,
					@TimeFrame_Id,
					@Promo_Desig,
					@From_Date,
					@To_Date,
					@Approval_Level,
					@Is_Applicable
					)
				END
			ELSE
				Begin	
				print 'k'		
				  Update T0110_HRMS_Appraisal_OtherDetails
				  Set				 
					Justification=@Justification,
					TimeFrame_Id=@TimeFrame_Id,
					Promo_Desig=@Promo_Desig,
					From_Date=@From_Date,
					To_Date=@To_Date,					
					Approval_Level=@Approval_Level,
					Is_Applicable=@Is_Applicable
				  Where AO_Id=@Action and cmp_id=@Cmp_ID and Emp_ID=@Emp_ID and InitiateId=@Initiateid and Approval_Level=@Approval_Level
				 				 
				End		
		End
END

--SP-9

