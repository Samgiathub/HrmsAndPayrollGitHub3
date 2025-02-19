

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0055_JobResponsibility]
	@Job_Resp_Id			numeric(18,0)   OUTPUT
      ,@Cmp_Id				numeric(18,0)
      ,@Job_Id				numeric(18,0)
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
			if @Job_Id=0
				begin
					select @Job_Id = max(Job_Id)  from T0050_JobDescription_Master WITH (NOLOCK)
				end
			select @Job_Resp_Id = isnull(max(Job_Resp_Id),0)+1 from T0055_JobResponsibility WITH (NOLOCK)
		
			Insert into T0055_JobResponsibility
			(
				  Job_Resp_Id
				  ,Cmp_Id
				  ,Job_Id
				  ,Responsibility
			)
			VALUES
			(
				   @Job_Resp_Id
				  ,@Cmp_Id
				  ,@Job_Id
				  ,@Responsibility
			)
			
			update T0090_Emp_JD_Responsibilty
			set Responsibilty=@Responsibility
			where JDCode_Id=@Job_Id
		END
	Else If @Tran_Type = 'U'
		BEGIN
			Update T0055_JobResponsibility
			SET  Responsibility = @Responsibility
			WHERE Job_Resp_Id = @Job_Resp_Id
			
			update T0090_Emp_JD_Responsibilty
			set Responsibilty=@Responsibility
			where JDCode_Id=@Job_Id
		END
	Else If @Tran_Type = 'D'
		BEGIN
			Delete from T0055_JobResponsibility where Job_Resp_Id = @Job_Resp_Id
		END
END
