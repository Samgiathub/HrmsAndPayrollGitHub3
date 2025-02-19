

-- =============================================
-- Author:		<Author,,Jimit Soni>
-- Create date: <Create Date,,01052019>
-- Description:	<Description,,For Updating fields in Employee Directory Tables>
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0040_EMPLOYEE_DIRECTORY_COLUMNS]
	@CMP_ID		 NUMERIC(18,0),
	@FIELDS		 VARCHAR(MAX)
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	UPDATE	T0040_Employee_Directory_Columns 
	SET		Is_Show = 0 
	Where	Cmp_ID =  @CMP_ID

	--UPDATE	T0040_Employee_Directory_Columns 
	--SET		Is_Show= 1 
	--Where	Cmp_ID = @CMP_ID 
	--		AND FIELD_NAME in 
	--			(
	--				select	substring(data,0,CHARINDEX(';',data)) 
	--				from	dbo.Split(@FIELDS,'#')
	--			)

	UPDATE	 EDC
	SET	     Is_Show= 1,
			 EDC.SORT_INDEX  = QRY.SORT_INDEX
	FROM	 T0040_Employee_Directory_Columns EDC INNER JOIN
			 (
				SELECT	SUBSTRING(data , LEN(data) -  CHARINDEX(';',REVERSE(data)) + 2, LEN(data)) AS SORT_INDEX,
						substring(data,0,CHARINDEX(';',data))  AS FIELD_NAME
				from	dbo.Split(@FIELDS,'#')
			 )QRY ON QRY.FIELD_NAME = EDC.Field_Name

END
