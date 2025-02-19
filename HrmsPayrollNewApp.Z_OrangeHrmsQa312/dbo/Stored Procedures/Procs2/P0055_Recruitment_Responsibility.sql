

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0055_Recruitment_Responsibility]
	   @Rec_Resp_Id			numeric(18,0) OUTPUT
      ,@Cmp_Id				numeric(18,0)
      ,@Rec_Req_ID			numeric(18,0)
      ,@Responsibility		Varchar(Max)
      ,@Tran_Type			char(1)
	  ,@User_Id				numeric(18,0)	
	  ,@IP_Address			varchar(100)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN	
	If @Tran_Type = 'I'
		BEGIN
			if @Rec_Req_ID=0
				begin
					select @Rec_Req_ID= max(Rec_Req_ID)  from T0050_HRMS_Recruitment_Request WITH (NOLOCK) where cmp_id = @cmp_Id
				end
			select @Rec_Resp_Id = isnull(max(Rec_Resp_Id),0)+1 from T0055_Recruitment_Responsibility WITH (NOLOCK)
			
			Insert into T0055_Recruitment_Responsibility
			(
				  Rec_Resp_Id
				  ,Cmp_Id
				  ,Rec_Req_ID	
				  ,Responsibility
			)
			VALUES
			(
				   @Rec_Resp_Id
				  ,@Cmp_Id
				  ,@Rec_Req_ID	
				  ,@Responsibility
			)
		END
	Else If @Tran_Type = 'U'
		BEGIN
			Update T0055_Recruitment_Responsibility
			SET  Responsibility = @Responsibility
			WHERE Rec_Resp_Id = @Rec_Resp_Id
		END
	Else If @Tran_Type = 'D'
		BEGIN
			Delete from T0055_Recruitment_Responsibility where Rec_Resp_Id = @Rec_Resp_Id
		END
END

