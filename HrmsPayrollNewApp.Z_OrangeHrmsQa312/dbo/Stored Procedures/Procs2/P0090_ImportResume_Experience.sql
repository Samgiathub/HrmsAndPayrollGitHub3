

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0090_ImportResume_Experience]
	 @cmp_id			numeric(18,0)
	,@Resume_Code		varchar(100)
	,@Experience_Type   varchar(15) --Mukti(21032017)
	,@Employer_Name		varchar(100)
	,@Desig_Name        varchar(100)
	,@St_Date			datetime
	,@End_Date			datetime
	,@StillContinue	int = 0  --Mukti(21032017)
AS
BEGIN

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


	declare @Resume_ID numeric(18,0)
	declare @ExperienceType numeric(18,0)
	if @Experience_Type='Experienced'
		set @ExperienceType=0
	ELSE
		set @ExperienceType=1
		
	if @Resume_Code <> ''
		begin
			if exists(select 1 from T0055_Resume_Master WITH (NOLOCK) where Resume_Code= @Resume_Code)				
				begin
					select @Resume_ID=Resume_Id from T0055_Resume_Master WITH (NOLOCK) where Resume_Code=@Resume_Code
					exec P0090_HRMS_RESUME_EXPERIENCE 0,@cmp_id,@Resume_ID,@Employer_Name,@Desig_Name,@St_Date,@End_Date,'','','I',null,null,null,null,null,null,null,NULL,null,@StillContinue,@ExperienceType
				End
			Else
				Begin
					Raiserror('This resume donot exists,Please enter resume details first.',16,2)
				End
		End
	Else
		Begin
			Raiserror('Enter Resume Code',16,2)
		End
END

