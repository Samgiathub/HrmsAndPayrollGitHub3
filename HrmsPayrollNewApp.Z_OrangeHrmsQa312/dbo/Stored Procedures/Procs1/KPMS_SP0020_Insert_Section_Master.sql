--select * from KPMS_T0020_Section_Master
--select * from T0011_LOGIN where Login_ID = 7013
--exec KPMS_SP0020_Insert_Section_Master 1,0,'Xyz','Tcs',1,1
CREATE PROCEDURE [dbo].[KPMS_SP0020_Insert_Section_Master]	
(
@Cmp_ID	Int,
@Section_ID	Int,
@Section_Name	Varchar(20),
@IsActive	Int,
@User_ID	Int
)
as

		 IF ISNULL(@Section_Name,'') =''
		Begin 
			--Raiserror('@@Section Name Not Blank',18,2)
			select -106
			return
		End 

IF NOT EXISTS(Select 1 From KPMS_T0020_Section_Master WHERE Section_ID=@Section_ID and IsActive < 2)

	BEGIN

	IF Exists(select 1 From dbo.KPMS_T0020_Section_Master WITH (NOLOCK) Where upper(Section_Name) = upper(@Section_Name) and Cmp_ID = @Cmp_ID and IsActive < 2)  
		
		Begin 
			select -102
			return
		End  

	

	INSERT INTO [KPMS_T0020_Section_Master]
				(  [Cmp_ID],			  
				   [Section_Name]
					 ,[IsActive]
				   ,[User_Id]
				   ,[Created_Date]
				  )
		 VALUES
			   (
					@Cmp_ID		,					
					@Section_Name	,
					@IsActive	,
					@User_ID	,
					GETDATE()	
				)
	END

ELSE

	BEGIN

 IF Exists(select 1 From dbo.KPMS_T0020_Section_Master WITH (NOLOCK) Where upper(Section_Name) = upper(@Section_Name) and Cmp_ID = @Cmp_ID and Section_ID <> @Section_ID and IsActive < 2)  
		
		Begin 
			select -102
			return
		End  
					UPDATE [KPMS_T0020_Section_Master]
					SET [Cmp_ID] =@Cmp_ID,
				   [Section_Name] =@Section_Name
				,[IsActive] =@IsActive
				   ,[User_ID] =@User_ID
				   ,[Modify_Date] =GETDATE()
				   WHERE [Section_ID] =@Section_ID
	END

