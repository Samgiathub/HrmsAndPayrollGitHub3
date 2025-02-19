
---12/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0250_REPORT_FORMAT_SETTING_GET]
	
	@CMP_ID AS numeric = null
	--@Module_name AS nvarchar(50)
	
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	SELECT    Module_Name, Cmp_id, Tran_Id, isnull(Paper_Value,'Potrait') as Paper_Value, isnull(Format_Value,'Default') as Format_Value, Sorting_No,isnull(Format_Name,'') as Format_Name
	FROM      T0250_REPORT_FORMAT_SETTING WITH (NOLOCK)
	--WHERE     (Module_Name = @Module_name) AND (Cmp_id = @CMP_ID)
	WHERE    Isnull(Cmp_id,0) = isnull(@CMP_ID ,Isnull(Cmp_id,0))
	ORDER BY  Sorting_No
	
	RETURN




