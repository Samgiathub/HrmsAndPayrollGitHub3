




CREATE PROCEDURE DBO.SP_Back_Up   
AS
	--Modified By nikunj 14-Feb-2011
	Declare @Strquey As Varchar(20)		
	Declare @StrBackup As varchar(200)
	Select @Strquey= Convert(Varchar(20), GetDate(),106)
	Set @StrBackup = 'D:\Backup_Orange_Hrms\Orange_hrms_'+ @Strquey +'.bak'
	Set @StrBackup= Replace(@StrBackup,' ','_')
	
	BACKUP DATABASE orange_hrms 
	TO DISK = @StrBackup
	WITH INIT
	
	RETURN




