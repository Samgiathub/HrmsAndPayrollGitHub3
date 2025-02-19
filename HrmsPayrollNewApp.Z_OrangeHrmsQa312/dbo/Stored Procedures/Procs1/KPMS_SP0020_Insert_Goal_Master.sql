--select * from KPMS_T0020_Goal_Master
--select * from T0011_LOGIN where Login_ID = 7013
--exec KPMS_SP0020_Insert_Goal_Master 1,0,'Xyz','Tcs',1,1
CREATE PROCEDURE [dbo].[KPMS_SP0020_Insert_Goal_Master]	
(
@Cmp_ID	Int,
@Goal_ID	Int,
@Goal_Name	Varchar(300),
@Section_Id Varchar(300),
@IsActive	Int,
@User_ID	Int
)
as

		 IF ISNULL(@Goal_Name,'') =''
		Begin 
			--Raiserror('@@Goal Name Not Blank',18,2)	
			select -106
			return
		End 
IF NOT EXISTS(Select 1 From KPMS_T0020_Goal_Master WHERE Goal_ID=@Goal_ID and IsActive < 2)

	BEGIN
	IF Exists(select 1 From dbo.KPMS_T0020_Goal_Master WITH (NOLOCK) Where upper(Goal_Name) = upper(@Goal_Name) and Cmp_ID = @Cmp_ID and IsActive < 2)  
		
		Begin 
			select -102
			return
		End  

	

	INSERT INTO [KPMS_T0020_Goal_Master]
				(  [Cmp_ID],
	
				   [Goal_Name]
					 ,[IsActive]
					 ,[Section_ID]
				   ,[User_Id]
				   ,[Created_Date]
				  )
		 VALUES
			   (
					@Cmp_ID		,
	
					@Goal_Name	,			
					@IsActive	,
					@Section_Id,
					@User_ID	,
					GETDATE()	
				)
	END

ELSE

	BEGIN

 IF Exists(select 1 From dbo.KPMS_T0020_Goal_Master WITH (NOLOCK) Where upper(Goal_Name) = upper(@Goal_Name) and Cmp_ID = @Cmp_ID and Goal_ID <> @Goal_ID and IsActive < 2)  
		
		Begin 
			select -102
			return
		End  
					UPDATE [KPMS_T0020_Goal_Master]
					SET [Cmp_ID] =@Cmp_ID,
				   [Goal_Name] =@Goal_Name
				,[IsActive] =@IsActive
				,[Section_ID] = @Section_Id
				   ,[User_ID] =@User_ID
				   ,[Modify_Date] =GETDATE()
				   WHERE [Goal_ID] =@Goal_ID
	END

	---delete top(6) from KPMS_T0020_Section_Master