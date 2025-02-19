
CREATE PROCEDURE [dbo].[P0040_Retaintion_Rate_DeleteBYRate_ID]
@RRate_ID numeric(9) = null,      
 @Grd_Id numeric(9) = null
AS
BEGIN
-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
SET NOCOUNT ON;

   delete from T0051_Retaintion_Rate_Details Where Grd_Id = @Grd_Id and RRate_ID= @RRate_ID

END
