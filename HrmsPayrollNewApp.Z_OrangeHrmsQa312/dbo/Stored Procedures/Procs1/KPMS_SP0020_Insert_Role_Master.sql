--select * from KPMS_T0020_Role_Master
--select * from T0011_LOGIN where Login_ID = 7013
--exec KPMS_SP0020_Insert_Role_Master 1,0,'Xyz','Tcs',1,1
CREATE PROCEDURE [dbo].[KPMS_SP0020_Insert_Role_Master]	
(
@Cmp_ID	Int,
@Role_ID	Int,
@Role_Code varchar(5),
@Role_Name	Varchar(20),
@IsActive	Int,
@User_ID	Int
)
as

	 IF ISNULL(@Role_Code,'') =''
		Begin 
			--Raiserror('@@Role Code Not Blank',18,2)
			select -105
			return
		End 

	 IF ISNULL(@Role_Name,'') =''
		Begin 
			--Raiserror('@@Role Name Not Blank',18,2)
			select -106
			return
		End 

IF NOT EXISTS(Select 1 From KPMS_T0020_Role_Master WHERE Role_ID=@Role_ID and IsActive < 2)

	BEGIN
	IF Exists(select 1 From dbo.KPMS_T0020_Role_Master WITH (NOLOCK) Where upper(Role_Code) = upper(@Role_Code) and Cmp_ID = @Cmp_ID and IsActive < 2)
		Begin 
			select  -101
			return
		End 

	IF Exists(select 1 From dbo.KPMS_T0020_Role_Master WITH (NOLOCK) Where upper(Role_Name) = upper(@Role_Name) and Cmp_ID = @Cmp_ID and IsActive < 2)  		
		Begin 
			select -102
			return
		End   

	SELECT  @Role_ID = Isnull(Max(Role_ID),0)+1 from KPMS_T0020_Role_Master

	INSERT INTO [KPMS_T0020_Role_Master]
				(  [Cmp_ID],
				   [Role_ID]
				   ,[Role_Code]
				   ,[Role_Name]
					 ,[IsActive]
				   ,[User_Id]
				   ,[Created_Date]
				  )
		 VALUES
			   (
					@Cmp_ID		,
					@Role_ID	,
					@Role_Code	,
					@Role_Name	,
					@IsActive	,
					@User_ID	,
					GETDATE()	
				)
	END

ELSE

	BEGIN

IF Exists(select 1 From dbo.KPMS_T0020_Role_Master WITH (NOLOCK) Where upper(Role_Code) = upper(@Role_Code) and Cmp_ID = @Cmp_ID and Role_ID <> @Role_ID and IsActive < 2)
		Begin 
			select -101
			return
		End 

 IF Exists(select 1 From dbo.KPMS_T0020_Role_Master WITH (NOLOCK) Where upper(Role_Name) = upper(@Role_Name) and Cmp_ID = @Cmp_ID and Role_ID <> @Role_ID and IsActive < 2)  
		
		Begin 
			select -102
			return
		End  
					UPDATE [KPMS_T0020_Role_Master]
					SET [Cmp_ID] =@Cmp_ID,
				   [Role_Code] =@Role_Code
				   ,[Role_Name] =@Role_Name
				,[IsActive] =@IsActive
				   ,[User_ID] =@User_ID
				   ,[Modify_Date] =GETDATE()
				   WHERE [Role_ID] =@Role_ID
	END
