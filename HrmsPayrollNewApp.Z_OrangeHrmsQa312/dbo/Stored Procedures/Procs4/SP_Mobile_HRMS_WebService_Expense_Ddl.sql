
create PROCEDURE [dbo].[SP_Mobile_HRMS_WebService_Expense_Ddl]
	@Cmp_Id int
AS
BEGIN

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	select expense_type_id,Expense_Type_name,expense_type_group,GST_Applicable 
from T0040_Expense_Type_Master where cmp_Id=@Cmp_Id order by expense_type_name	

END


