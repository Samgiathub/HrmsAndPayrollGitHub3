


CREATE PROCEDURE [dbo].[P0090_HRMS_RESUME_DOCUMENT]
	 @Doc_ID			NUMERIC(18,0) OUTPUT
	,@Cmp_ID			NUMERIC(18,0)
	,@Resume_ID			NUMERIC(18,0)
	,@Doc_Type_ID		NUMERIC(18,0)
	,@Resume_Final_ID	NUMERIC(18,0)
	,@File_Name			VARCHAR(Max)
AS

        SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN
	if @Resume_Final_ID=0
		set @Resume_Final_ID=NULL
		
			SELECT @Doc_ID = ISNULL(MAX(Doc_ID),0) + 1 FROM t0090_HRMS_RESUME_DOCUMENT WITH (NOLOCK)
			Insert Into t0090_HRMS_RESUME_DOCUMENT(Doc_ID, Cmp_ID,DocType_ID, Resume_ID,Resume_Final_ID, File_Name)
			Values(@Doc_ID, @Cmp_ID,@Doc_Type_ID, @Resume_ID,@Resume_Final_ID, @File_Name)
			
END


