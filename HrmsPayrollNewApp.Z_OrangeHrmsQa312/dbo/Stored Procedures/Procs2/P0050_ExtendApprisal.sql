


---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

CREATE PROCEDURE [dbo].[P0050_ExtendApprisal]
	 @cmp_id as numeric(18,0)
	,@InitId as numeric(18,0) =null
	,@extendate as datetime
	,@type		int = 0
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


BEGIN
	if	@type = 0
		begin  
				IF EXISTS(SELECT 1 FROM T0055_Hrms_Initiate_KPASetting WITH (NOLOCK) WHERE Cmp_Id = @cmp_id AND KPA_InitiateId = @InitId AND Initiate_Status in(4,0,3,2))
				BEGIN 				
					UPDATE T0055_Hrms_Initiate_KPASetting
					SET KPA_EndDate = @extendate
					WHERE KPA_InitiateId = @InitId
					
					SELECT KPA_InitiateId,Emp_Id FROM T0055_Hrms_Initiate_KPASetting WITH (NOLOCK) WHERE KPA_InitiateId = @InitId
				END
		END
	ELSE IF	@type = 1
		BEGIN 
			IF not exists(select 1 from T0050_HRMS_InitiateAppraisal WITH (NOLOCK) where Cmp_ID=@cmp_id and InitiateId=@InitId and SA_Status=1 or SA_Startdate>@extendate)
				BEGIN	
						update T0050_HRMS_InitiateAppraisal set SA_Enddate = @extendate where InitiateId=@InitId and Cmp_ID=@cmp_id
					select InitiateId,emp_id from T0050_HRMS_InitiateAppraisal WITH (NOLOCK) where Cmp_ID=@cmp_id and InitiateId=@InitId
				End		
		END
END

