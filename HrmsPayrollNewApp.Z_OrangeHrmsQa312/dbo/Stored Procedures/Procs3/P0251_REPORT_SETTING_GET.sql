

---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0251_REPORT_SETTING_GET]
	
	@CMP_ID AS numeric = null,
	@Report_Name AS nvarchar(200)=null,
	@Format AS numeric = 0
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	if Exists ( select cmp_id from T0251_Report_Setting WITH (NOLOCK) where cmp_id = ISNULL(@CMP_ID,0) and upper(report_name) = ISNULL(upper(@Report_Name),0) and Format=@Format)
	begin
	select * from T0251_Report_Setting WITH (NOLOCK) where cmp_id = ISNULL(@CMP_ID,0) and upper(report_name) = ISNULL(upper(@Report_Name),0) and Format=@Format
	return
	end
	else if Exists ( select cmp_id from T0251_Report_Setting WITH (NOLOCK) where cmp_id = 0 and upper(report_name) = ISNULL(upper(@Report_Name),0) and Format=@Format )	
	begin
	select * from T0251_Report_Setting WITH (NOLOCK) where cmp_id = 0 and upper(report_name) = ISNULL(upper(@Report_Name),0) and Format=@Format
	RETURN
	end
	else
	Begin
	select  0 as Tran_Id,0 as Cmp_Id,0 as Report_Name,0 as Report_File_Name,GETDATE() as Modufy_Date
	RETURN
	end




