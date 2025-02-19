


CREATE PROCEDURE [dbo].[Get_MaxAttachLimit_file]

 @Cmp_Id		numeric
 ,@setting_name		varchar(100)


	
AS
BEGIN
		
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

declare @maxlimit numeric

 begin 

 select @maxlimit= (select setting_value from T0040_SETTING where setting_name = @setting_name and cmp_id = @Cmp_Id)

 end

    Select @maxlimit as setting_value  
END


