


-- =============================================
-- Author:		Sneha
-- ALTER date:21 Jan 2013
-- Description:	<Description,,>
---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0055_ResumeMaster_UpdateFilename]
	@Cmp_id as numeric(18,0),
	@Filename as varchar(100),
	--@resume_code as numeric(18,0) --commented By Mukti 15102015
	@resume_code as varchar(100) --Mukti(15102015)
AS
BEGIN

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


	If @Cmp_id<> 0
		Begin
			Update T0055_Resume_Master 
			set File_Name = @Filename 
			where Cmp_id = @Cmp_id and
			Resume_Code = @resume_code --Mukti(15102015)
			--Resume_Id = @resume_code  --commented By Mukti 15102015
			
			select *,Resume_Name as resume_full_name from T0055_Resume_Master WITH (NOLOCK)
			where Cmp_id = @Cmp_id and
			Resume_Code = @resume_code  --Mukti(15102015)
			--Resume_Id = @resume_code  --commented By Mukti 15102015
		end
END


