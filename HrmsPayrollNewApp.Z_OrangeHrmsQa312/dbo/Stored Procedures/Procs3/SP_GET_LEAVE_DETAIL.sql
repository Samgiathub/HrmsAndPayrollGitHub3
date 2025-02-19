


-- =============================================
-- Author	  :	Alpesh
-- ALTER date: 10-Apr-2012
-- Description:	
---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_GET_LEAVE_DETAIL]
	@Cmp_ID		numeric(18, 0),
	@Leave_ID	numeric(18, 0),
	@Default_Short_Name	varchar(15)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	
	
	If @Leave_ID <> 0
		Begin
			Select * from T0040_LEAVE_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Leave_ID=@Leave_ID 	
		End
	Else If @Default_Short_Name <> ''
		Begin
			Select * from T0040_LEAVE_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Default_Short_Name=@Default_Short_Name	
		End	
    
END


