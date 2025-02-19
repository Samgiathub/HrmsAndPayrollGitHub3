


-- =============================================
-- Author:		<Ankit>
-- Create date: <01102015,,>
-- Description:	<Description,,Ess Employee Company Policy Read Document Detail>
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0090_EMP_POLICY_DOC_READ_DETAIL]
	@Cmp_Id			Numeric
	,@Emp_ID		Numeric
	,@Policy_Doc_ID	Numeric
	,@Doc_Type tinyint = 0		 --Added By Ashwin 07/03/2017 For Mobile Read
	,@Is_Mobile_Read tinyint = 0 --Added By Ashwin 07/03/2017 For Mobile Read
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

	
	DECLARE @Row_ID	NUMERIC
	DECLARE	@Read_Datetime	DATETIME
	
	SET @Row_ID = 0
	SET @Read_Datetime = GETDATE()
	
	SELECT @Row_ID = ISNULL(MAX(Row_ID),0 ) + 1 FROM T0090_EMP_POLICY_DOC_READ_DETAIL WITH (NOLOCK)
	
	INSERT INTO T0090_EMP_POLICY_DOC_READ_DETAIL 
		(Row_ID,Cmp_ID,Emp_ID,Policy_Doc_ID,Read_Datetime,Doc_Type,Is_Mobile_Read)		   --Two Fields added By Ashwin 07/03/2017 For Mobile Read
	VALUES 	
		(@Row_ID,@Cmp_ID,@Emp_ID,@Policy_Doc_ID,@Read_Datetime,@Doc_Type,@Is_Mobile_Read)  --Two Parameters added By Ashwin 07/03/2017 For Mobile Read
	     
END


