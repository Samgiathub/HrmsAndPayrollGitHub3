


---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0240_Perquisites_Master]
	@Perquisites_Id numeric(18,0),
	@Cmp_id numeric(18,0),
	@Tran_Type varchar(1) = 'S'
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN

	
	if @Tran_Type = 'S'
		Begin
		
			SELECT     Perquisites_Id, Name, Sort_Name, Sorting_no, Def_id, Remarks, Cmp_id
			FROM         T0240_Perquisites_Master WITH (NOLOCK)
			ORDER BY Sorting_no
			
		End
END


