--select * from KPMS_T0040_Level_Master
--select * from T0011_LOGIN where Login_ID = 7013
--exec KPMS_SP0040_Insert_Level_Master 1,0,'Xyz','Tcs',1,1
CREATE PROCEDURE [dbo].[KPMS_SP0040_Insert_Level_Master]
(
@Cmp_ID	Int,
@Level_ID	Int,
@Level_Code varchar(5),
@Level_Name	Varchar(20),
@IsActive	Int,
@User_ID	Int,
@lvlGrp_Id Int
)
as



IF NOT EXISTS(Select 1 From KPMS_T0040_Level_Master WHERE Level_ID=@Level_ID and IsActive < 2)

	BEGIN
	IF Exists(select 1  From dbo.KPMS_T0040_Level_Master WITH (NOLOCK) Where upper(Level_Code) = upper(@Level_Code) and Cmp_ID = @Cmp_ID and level_Grp_Id = @lvlGrp_Id and IsActive < 2)
		Begin 
			select -101
			return
		End 

	IF Exists(select 1 From dbo.KPMS_T0040_Level_Master WITH (NOLOCK) Where upper(Level_Name) = upper(@Level_Name) and Cmp_ID = @Cmp_ID and level_Grp_Id = @lvlGrp_Id and IsActive < 2)  
		
		Begin 
			select -102
			return
		End  

	SELECT  @Level_ID = Isnull(Max(Level_ID),0)+1 from KPMS_T0040_Level_Master

	INSERT INTO [KPMS_T0040_Level_Master]
				(  [Cmp_ID],
				   [Level_ID]
				   ,[Level_Code]
				   ,[Level_Name]
			 ,[IsActive]
				   ,[User_Id]
				   ,[Created_Date]
				   ,[level_Grp_Id]
				  )
		 VALUES
			   (
					@Cmp_ID		,
					@Level_ID	,
					@Level_Code	,
					@Level_Name	,
				@IsActive	,
					@User_ID	,
					GETDATE()	,
					@lvlGrp_Id
				)
	END

ELSE

	BEGIN

IF Exists(select 1 From dbo.KPMS_T0040_Level_Master WITH (NOLOCK) Where upper(Level_Code) = upper(@Level_Code) and level_Grp_Id = @lvlGrp_Id and Cmp_ID = @Cmp_ID and Level_ID <> @Level_ID and IsActive < 2)
		Begin 
			select -101
			return
		End 

 IF Exists(select 1 From dbo.KPMS_T0040_Level_Master WITH (NOLOCK) Where upper(Level_Name) = upper(@Level_Name) and level_Grp_Id = @lvlGrp_Id  and Cmp_ID = @Cmp_ID and Level_ID <> @Level_ID and IsActive < 2)  
		
		Begin 
			select -102
			return
		End  
					UPDATE [KPMS_T0040_Level_Master]
					SET [Cmp_ID] =@Cmp_ID,
				   [Level_Code] =@Level_Code
				   ,[Level_Name] =@Level_Name
				,[IsActive] =@IsActive
				   ,[User_ID] =@User_ID
				   ,[Modify_Date] =GETDATE()
				   ,[level_Grp_Id] = @lvlGrp_Id
				   WHERE [Level_ID] =@Level_ID
	END
	