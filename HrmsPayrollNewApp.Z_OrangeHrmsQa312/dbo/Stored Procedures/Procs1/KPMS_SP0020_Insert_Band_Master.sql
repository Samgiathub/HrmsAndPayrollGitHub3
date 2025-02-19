--select * from KPMS_T0020_Band_Master
--select * from T0011_LOGIN where Login_ID = 7013
--exec KPMS_SP0020_Insert_Band_Master 1,0,'Xyz','Tcs',1,1
CREATE PROCEDURE [dbo].[KPMS_SP0020_Insert_Band_Master]	
(
@Cmp_ID	Int,
@Band_ID	Int,
@Band_Code varchar(5),
@Band_Name	Varchar(20),
@IsActive	Int,
@User_ID	Int
)
as

IF NOT EXISTS(Select 1 From KPMS_T0020_Band_Master WHERE Band_ID=@Band_ID and IsActive < 2)

	BEGIN
	IF Exists(select 1 From dbo.KPMS_T0020_Band_Master WITH (NOLOCK) Where upper(Band_Code) = upper(@Band_Code) and Cmp_ID = @Cmp_ID and IsActive < 2)
		Begin 
			select -101
			return
		End 

	IF Exists(select 1 From dbo.KPMS_T0020_Band_Master WITH (NOLOCK) Where upper(Band_Name) = upper(@Band_Name) and Cmp_ID = @Cmp_ID and IsActive < 2)  
		
		Begin 
			select -102
			return
		End  

	SELECT  @Band_ID = Isnull(Max(Band_ID),0)+1 from KPMS_T0020_Band_Master

	INSERT INTO [KPMS_T0020_Band_Master]
				(  [Cmp_ID],
				   [Band_ID]
				   ,[Band_Code]
				   ,[Band_Name]
					 ,[IsActive]
				   ,[User_Id]
				   ,[Created_Date]
				  )
		 VALUES
			   (
					@Cmp_ID		,
					@Band_ID	,
					@Band_Code	,
					@Band_Name	,
					@IsActive	,
					@User_ID	,
					GETDATE()	
				)
	END

ELSE

	BEGIN

IF Exists(select 1 From dbo.KPMS_T0020_Band_Master WITH (NOLOCK) Where upper(Band_Code) = upper(@Band_Code) and Cmp_ID = @Cmp_ID and Band_ID <> @Band_ID and IsActive < 2)
		Begin 
			select -101
			return
		End 

 IF Exists(select 1 From dbo.KPMS_T0020_Band_Master WITH (NOLOCK) Where upper(Band_Name) = upper(@Band_Name) and Cmp_ID = @Cmp_ID and Band_ID <> @Band_ID and IsActive < 2)  
		
		Begin 
			select -102
			return
		End  
					UPDATE [KPMS_T0020_Band_Master]
					SET [Cmp_ID] =@Cmp_ID,
				   [Band_Code] =@Band_Code
				   ,[Band_Name] =@Band_Name
				,[IsActive] =@IsActive
				   ,[User_ID] =@User_ID
				   ,[Modify_Date] =GETDATE()
				   WHERE [Band_ID] =@Band_ID
	END
