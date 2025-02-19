




CREATE PROCEDURE [dbo].[P0250_REPORT_FORMAT_SETTING]
	
	@CMP_ID AS numeric,
	@Module_name AS nvarchar(50)
	
	
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

	
	SELECT    Module_Name, Cmp_id, Tran_Id, isnull(Paper_value,0) as Paper_value, isnull(Format_value,0) as Format_value, Sorting_No
	FROM      T0250_REPORT_FORMAT_SETTING WITH (NOLOCK)
	WHERE     (lower(Module_Name) = lower(@Module_name)) AND (Cmp_id = @CMP_ID)
	ORDER BY  Sorting_No
	
	RETURN




