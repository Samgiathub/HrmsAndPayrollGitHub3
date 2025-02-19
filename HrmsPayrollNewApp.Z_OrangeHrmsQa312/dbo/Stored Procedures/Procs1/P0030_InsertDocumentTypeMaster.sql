

-- =============================================
-- Author:		<Author,,Rohit Patel>
-- Create date: <Create Date,,29012014>
-- Description:	<Description,,Insert Document type in T0030_DOCUMENT_TYPE_MASTER>
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0030_InsertDocumentTypeMaster] 
AS
BEGIN

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON



		Declare @DOCUMENT_TYPE_MASTER Table(Doc_Type_ID  numeric,Doc_Type_Name varchar(MAX),Doc_Comments varchar(MAX))

		INSERT INTO @DOCUMENT_TYPE_MASTER([Doc_Type_ID], [Doc_Type_Name],[Doc_Comments]) VALUES (1, N'Address Proof','')
		INSERT INTO @DOCUMENT_TYPE_MASTER([Doc_Type_ID], [Doc_Type_Name],[Doc_Comments]) VALUES (2, N'Identity Proof','')
		INSERT INTO @DOCUMENT_TYPE_MASTER([Doc_Type_ID], [Doc_Type_Name],[Doc_Comments]) VALUES (3, N'Marriage Proof','')
		INSERT INTO @DOCUMENT_TYPE_MASTER([Doc_Type_ID], [Doc_Type_Name],[Doc_Comments]) VALUES (4, N'Education Proof','')
		INSERT INTO @DOCUMENT_TYPE_MASTER([Doc_Type_ID], [Doc_Type_Name],[Doc_Comments]) VALUES (5, N'Other Proof','')
		--Select * from @DOCUMENT_TYPE_MASTER

		DECLARE @Doc_Type_ID numeric, 
				@Doc_Type_Name varchar(100),
				@Doc_Comments varchar(max)

		DECLARE L_Master CURSOR FOR SELECT Doc_Type_ID,Doc_Type_Name,Doc_Comments FROM @DOCUMENT_TYPE_MASTER
		OPEN L_Master
		FETCH NEXT FROM L_Master INTO @Doc_Type_ID, @Doc_Type_Name,@Doc_Comments
		WHILE @@FETCH_STATUS = 0
		BEGIN

			DECLARE @CNT as int
			DECLARE @Doc_Type_ID_max as int
			SET @CNT = 0	
			SET @Doc_Type_ID_max = 0
			SET @CNT = (Select COUNT(*) from T0030_DOCUMENT_TYPE_MASTER WITH (NOLOCK) WHERE UPPER(Doc_Type_Name) = UPPER(@Doc_Type_Name))
			IF @CNT = 0
			BEGIN
			   select @Doc_Type_ID_max = isnull(max(Doc_Type_ID),0) + 1 from T0030_DOCUMENT_TYPE_MASTER WITH (NOLOCK)
			   INSERT INTO T0030_DOCUMENT_TYPE_MASTER (Doc_Type_ID,Doc_Type_Name,Doc_Comments) VALUES (@Doc_Type_ID_max,@Doc_Type_Name,@Doc_Comments)
		   END
		   FETCH NEXT FROM L_Master INTO @Doc_Type_ID, @Doc_Type_Name,@Doc_Comments
		END

		CLOSE L_Master
		DEALLOCATE L_Master
END

