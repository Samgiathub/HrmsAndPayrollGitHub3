


-- =============================================
-- Author:		Nilesh Patel
-- Create date: 20/07/2019
-- Description:	Relationship Master
-- =============================================
CREATE PROCEDURE [dbo].[P_Insert_Relationship_Master]
	@Cmp_ID Numeric
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	
	
	Declare @Relationship_ID Numeric(10,0)
	Set @Relationship_ID = 0

    If Not Exists(Select 1 From T0040_Relationship_Master WITH (NOLOCK) Where Cmp_Id = @Cmp_ID)
	BEGIN
		Select @Relationship_ID = Isnull(Max(Relationship_ID),0) + 1 From T0040_Relationship_Master WITH (NOLOCK)
		
		Insert into T0040_Relationship_Master(Relationship_ID,Relationship,Cmp_Id)
		Select @Relationship_ID + 1,'Father',@Cmp_ID
		Union
		Select @Relationship_ID + 2,'Mother',@Cmp_ID
		Union
		Select @Relationship_ID + 3,'Brother',@Cmp_ID
		Union
		Select @Relationship_ID + 4,'Sister',@Cmp_ID
		Union
		Select @Relationship_ID + 5,'Spouse',@Cmp_ID
		Union
		Select @Relationship_ID + 6,'Son',@Cmp_ID
		Union
		Select @Relationship_ID + 7,'Daughter',@Cmp_ID
		
	END
END

