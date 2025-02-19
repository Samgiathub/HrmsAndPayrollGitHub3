


-- =============================================
-- Author:		Sneha
-- ALTER date: 31 jul 2013
-- Description:	
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0060_HRMS_RESUME_Update]
	 @Cmp_ID		numeric(18, 0)	
	,@Resume_ID		numeric(18, 0)	
	,@FileName		varchar(max)
	,@Type          varchar(50)
	,@AckNo			varchar(50)=''
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


Declare @Row_ID numeric(18,0)
BEGIN
	if(@Type ='Photo')
		begin
			If exists(select 1 from  T0090_HRMS_RESUME_HEALTH WITH (NOLOCK) where Resume_ID=@Resume_ID)
				Begin
					Update T0090_HRMS_RESUME_HEALTH 
					set    emp_file_name = @FileName
					where  Resume_ID = @Resume_ID   and Cmp_ID = @Cmp_ID
				End
			else
				Begin					
					select @Row_ID= Isnull(max(Row_ID),0) + 1 	From T0090_HRMS_RESUME_HEALTH WITH (NOLOCK)
			
					INSERT INTO T0090_HRMS_RESUME_HEALTH
							  (Row_ID
								,Cmp_ID
								,Resume_ID
								,Blood_group
								,Height
								,weight
								,emp_file_name
								,file_name
								)
						VALUES	(@Row_ID
								,@Cmp_ID
								,@Resume_ID
								,null
								,null
								,null
								,null
								,@FileName)					
				End
		End	
	else if(@Type='Pancard')
		begin
			If exists(select 1 from  T0055_Resume_Master WITH (NOLOCK) where Resume_ID=@Resume_ID)
				begin
					Update T0055_Resume_Master 
					set    PanCardProof = @FileName,
							HasPancard = 1,
							PanCardNo=@AckNo
					where  Resume_Id = @Resume_ID and Cmp_id = @Cmp_ID
				End
		End
	else if (@Type='PanAck')
		begin
			If exists(select 1 from  T0055_Resume_Master WITH (NOLOCK) where Resume_ID=@Resume_ID)
				begin
					Update T0055_Resume_Master 
					set    PanCardAck_Path = @FileName,
							PanCardAck_No=@AckNo,
							PanCardNo='0'
					where  Resume_Id = @Resume_ID and Cmp_id = @Cmp_ID
				End
		End
END


