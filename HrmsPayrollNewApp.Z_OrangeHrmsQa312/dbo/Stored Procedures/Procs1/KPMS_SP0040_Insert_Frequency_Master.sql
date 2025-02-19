--select * from KPMS_T0040_Frequency_Master
--select * from T0011_LOGIN where Login_ID = 7013
--exec KPMS_SP0040_Insert_Frequency_Master 1,0,'Xyz','Tcs',1,1
CREATE PROCEDURE [dbo].[KPMS_SP0040_Insert_Frequency_Master]
(
@Cmp_ID	Int,
@Frequency_ID	Int,
@Frequency_Code varchar(5),
@Frequency	Varchar(20),
@IsActive	Int,
@User_ID	Int
)
as

	 IF ISNULL(@Frequency_Code,'') =''
		Begin 
			--Raiserror('@@Role Code Not Blank',18,2)
			select -105
			return
		End 

		 IF ISNULL(@Frequency,'') =''
		Begin 
			--Raiserror('@@Role Name Not Blank',18,2)
			select -106
			return
		End 

IF NOT EXISTS(Select 1 From KPMS_T0040_Frequency_Master WHERE Frequency_ID=@Frequency_ID and IsActive < 2 )

	BEGIN
	IF Exists(select 1  From dbo.KPMS_T0040_Frequency_Master WITH (NOLOCK) Where upper(Frequency_Code) = upper(@Frequency_Code) and Cmp_ID = @Cmp_ID and IsActive < 2)
		Begin 
			select -101
			return
		End 

	IF Exists(select 1 From dbo.KPMS_T0040_Frequency_Master WITH (NOLOCK) Where upper(Frequency) = upper(@Frequency) and Cmp_ID = @Cmp_ID and IsActive < 2)  
		
		Begin 
			select -102
			return
		End  

	SELECT  @Frequency_ID = Isnull(Max(Frequency_ID),0)+1 from KPMS_T0040_Frequency_Master

	INSERT INTO [KPMS_T0040_Frequency_Master]
				(  [Cmp_ID],
				   [Frequency_ID]
				   ,[Frequency_Code]
				   ,[Frequency]
			 ,[IsActive]
				   ,[User_Id]
				   ,[Created_Date]
				  )
		 VALUES
			   (
					@Cmp_ID		,
					@Frequency_ID	,
					@Frequency_Code	,
					@Frequency	,
				@IsActive	,
					@User_ID	,
					GETDATE()	
				)
	END

ELSE

	BEGIN

IF Exists(select 1 From dbo.KPMS_T0040_Frequency_Master WITH (NOLOCK) Where upper(Frequency_Code) = upper(@Frequency_Code) and Cmp_ID = @Cmp_ID and Frequency_ID <> @Frequency_ID and IsActive < 2)
		Begin 
			select -101
			return
		End 

 IF Exists(select 1 From dbo.KPMS_T0040_Frequency_Master WITH (NOLOCK) Where upper(Frequency) = upper(@Frequency) and Cmp_ID = @Cmp_ID and Frequency_ID <> @Frequency_ID and IsActive < 2)  
		
		Begin 
			select -102
			return
		End  
					UPDATE [KPMS_T0040_Frequency_Master]
					SET [Cmp_ID] =@Cmp_ID,
				   [Frequency_Code] =@Frequency_Code
				   ,[Frequency] =@Frequency
				,[IsActive] =@IsActive
				   ,[User_ID] =@User_ID
				   ,[Modify_Date] =GETDATE()
				   WHERE [Frequency_ID] =@Frequency_ID
	END
	