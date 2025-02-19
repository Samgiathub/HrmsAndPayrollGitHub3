

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P0040_Asset_Update]
	-- Add the parameters for the stored procedure here
	 @Cmp_ID numeric
	,@status varchar(2)
	,@assetid numeric
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	update T0040_Asset_Details set Asset_Status=@status,allocation=0 where Cmp_ID=@Cmp_ID and Asset_ID=@assetid 
		
END


