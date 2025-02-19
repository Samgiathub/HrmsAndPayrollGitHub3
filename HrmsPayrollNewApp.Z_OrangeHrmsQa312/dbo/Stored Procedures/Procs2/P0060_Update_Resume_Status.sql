


-- =============================================
-- Author:		Sneha
-- ALTER date: 22 jul 2013 
-- Description:	<Description,,>
---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0060_Update_Resume_Status]
	 @Resume_Id		numeric(18) output
	,@Rec_post_Id   numeric(18,0) 
	,@CorpHr		int
	,@status        int
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	if @CorpHr =0
		begin
			Update T0060_RESUME_FINAL 
			set    Resume_Status = @status
			where Rec_post_Id = @Rec_post_Id and Resume_ID = @Resume_Id
		End
	else if @CorpHr = 1
		begin
			Update T0060_RESUME_FINAL 
			set    Level2_Approval = @status
			where Rec_post_Id = @Rec_post_Id and Resume_ID = @Resume_Id
		End
END


