

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P0040_Suggestion_MASTER] 
	@Email_ID Varchar(500),
	@Subject Varchar(500),
	@Message Varchar(Max),
	@UserID Varchar(100)
AS

        SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	

    Declare @Trans_ID Numeric(10,0)
    Set @Trans_ID = 0
    
    Select @Trans_ID = MAX(Trans_ID) + 1 From T0040_Suggestion_MASTER WITH (NOLOCK)
    
    insert into T0040_Suggestion_MASTER(Trans_ID,Email_ID,Email_Subject,Email_Description,User_ID,Modify_Date)
    VALUES(@Trans_ID,@Email_ID,@Subject,@Message,@UserID,GETDATE())
    
END

