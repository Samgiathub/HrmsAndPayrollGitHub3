--select * from KPMS_T0020_Dependency_Master
--select * from T0011_LOGIN where Login_ID = 7013
--exec KPMS_SP0020_Insert_Dependency_Master 1,0,'Xyz','Tcs',1,1
CREATE PROCEDURE [dbo].[KPMS_SP0020_Insert_Dependency_Master]	
(
@Cmp_ID	Int,
@Dependency_ID	Int,
@Dependency_Code varchar(5),
@Dependency_Type	Varchar(20),
@IsActive	Int,
@User_ID	Int
)
as

	 IF ISNULL(@Dependency_Code,'') =''
		Begin 
			--Raiserror('@@Dependency Code Not Blank',18,2)
			select -105
			return
		End 

		 IF ISNULL(@Dependency_Type,'') =''
		Begin 
			--Raiserror('@@Dependency Name Not Blank',18,2)
			select -106
			return
		End 

IF NOT EXISTS(Select 1 From KPMS_T0020_Dependency_Master WHERE Dependency_ID=@Dependency_ID and IsActive < 2)

	BEGIN
	IF Exists(select 1 From dbo.KPMS_T0020_Dependency_Master WITH (NOLOCK) Where upper(Dependency_Code) = upper(@Dependency_Code) and Cmp_ID = @Cmp_ID and IsActive < 2)
		Begin 
			select  -101
			return
		End 

	IF Exists(select 1 From dbo.KPMS_T0020_Dependency_Master WITH (NOLOCK) Where upper(Dependency_Type) = upper(@Dependency_Type) and Cmp_ID = @Cmp_ID and IsActive < 2)  
		
		Begin 
			select -102
			return
		End  

	SELECT  @Dependency_ID = Isnull(Max(Dependency_ID),0)+1 from KPMS_T0020_Dependency_Master

	INSERT INTO [KPMS_T0020_Dependency_Master]
				(  [Cmp_ID],
				   [Dependency_ID]
				   ,[Dependency_Code]
				   ,[Dependency_Type]
					 ,[IsActive]
				   ,[User_Id]
				   ,[Created_Date]
				  )
		 VALUES
			   (
					@Cmp_ID		,
					@Dependency_ID	,
					@Dependency_Code	,
					@Dependency_Type	,
					@IsActive	,
					@User_ID	,
					GETDATE()	
				)
	END

ELSE

	BEGIN

IF Exists(select 1 From dbo.KPMS_T0020_Dependency_Master WITH (NOLOCK) Where upper(Dependency_Code) = upper(@Dependency_Code) and Cmp_ID = @Cmp_ID and Dependency_ID <> @Dependency_ID and IsActive < 2)
		Begin 
			select -101
			return
		End 

 IF Exists(select 1 From dbo.KPMS_T0020_Dependency_Master WITH (NOLOCK) Where upper(Dependency_Type) = upper(@Dependency_Type) and Cmp_ID = @Cmp_ID and Dependency_ID <> @Dependency_ID and IsActive < 2)  
		
		Begin 
			select -102
			return
		End  
					UPDATE [KPMS_T0020_Dependency_Master]
					SET [Cmp_ID] =@Cmp_ID,
				   [Dependency_Code] =@Dependency_Code
				   ,[Dependency_Type] =@Dependency_Type
				,[IsActive] =@IsActive
				   ,[User_ID] =@User_ID
				   ,[Modify_Date] =GETDATE()
				   WHERE [Dependency_ID] =@Dependency_ID
	END
