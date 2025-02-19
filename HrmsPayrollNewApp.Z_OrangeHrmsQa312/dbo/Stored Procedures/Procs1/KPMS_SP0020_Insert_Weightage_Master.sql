--select * from KPMS_T0020_Weightage_Master
--select * from T0011_LOGIN where Login_ID = 7013
--exec KPMS_SP0020_Insert_Weightage_Master 1,0,'Xyz','Tcs',1,1
CREATE PROCEDURE [dbo].[KPMS_SP0020_Insert_Weightage_Master]	
(
@Cmp_ID	Int,
@Weightage_ID	Int,
@Weightage_Code varchar(5),
@Weightage_Type	Varchar(20),
@IsActive	Int,
@User_ID	Int
)
as

	 IF ISNULL(@Weightage_Code,'') =''
		Begin 
			--Raiserror('@@Weightage Code Not Blank',18,2)
			select -105
			return
		End 

		 IF ISNULL(@Weightage_Type,'') =''
		Begin 
			--Raiserror('@@Weightage Name Not Blank',18,2)
			select -106
			return
		End 

IF NOT EXISTS(Select 1 From KPMS_T0020_Weightage_Master WHERE Weightage_ID=@Weightage_ID and IsActive < 2)

	BEGIN
	IF Exists(select 1 From dbo.KPMS_T0020_Weightage_Master WITH (NOLOCK) Where upper(Weightage_Code) = upper(@Weightage_Code) and Cmp_ID = @Cmp_ID and IsActive < 2)
		Begin 
			select  -101
			return
		End 

	IF Exists(select 1 From dbo.KPMS_T0020_Weightage_Master WITH (NOLOCK) Where upper(Weightage_Type) = upper(@Weightage_Type) and Cmp_ID = @Cmp_ID and IsActive < 2)  
		
		Begin 
			select -102
			return
		End  

	SELECT  @Weightage_ID = Isnull(Max(Weightage_ID),0)+1 from KPMS_T0020_Weightage_Master

	INSERT INTO [KPMS_T0020_Weightage_Master]
				(  [Cmp_ID],
				   [Weightage_ID]
				   ,[Weightage_Code]
				   ,[Weightage_Type]
					 ,[IsActive]
				   ,[User_Id]
				   ,[Created_Date]
				  )
		 VALUES
			   (
					@Cmp_ID		,
					@Weightage_ID	,
					@Weightage_Code	,
					@Weightage_Type	,
					@IsActive	,
					@User_ID	,
					GETDATE()	
				)
	END

ELSE

	BEGIN

IF Exists(select 1 From dbo.KPMS_T0020_Weightage_Master WITH (NOLOCK) Where upper(Weightage_Code) = upper(@Weightage_Code) and Cmp_ID = @Cmp_ID and Weightage_ID <> @Weightage_ID and IsActive < 2)
		Begin 
			select -101
			return
		End 

 IF Exists(select 1 From dbo.KPMS_T0020_Weightage_Master WITH (NOLOCK) Where upper(Weightage_Type) = upper(@Weightage_Type) and Cmp_ID = @Cmp_ID and Weightage_ID <> @Weightage_ID and IsActive < 2)  
		
		Begin 
			select -102
			return
		End  
					UPDATE [KPMS_T0020_Weightage_Master]
					SET [Cmp_ID] =@Cmp_ID,
				   [Weightage_Code] =@Weightage_Code
				   ,[Weightage_Type] =@Weightage_Type
				,[IsActive] =@IsActive
				   ,[User_ID] =@User_ID
				   ,[Modify_Date] =GETDATE()
				   WHERE [Weightage_ID] =@Weightage_ID
	END
