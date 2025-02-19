--select * from KPMS_T0020_SubGoal_Master
--select * from T0011_LOGIN where Login_ID = 7013
--exec KPMS_SP0020_Insert_SubGoal_Master 1,0,'Xyz','Tcs',1,1
CREATE PROCEDURE [dbo].[KPMS_SP0020_Insert_SubGoal_Master]	
(
@Cmp_ID	Int,
@SubGoal_ID	Int,
@SubGoal_Name	Varchar(300),
@Goal_Id int,
@IsActive	Int,
@User_ID	Int
)
as

		 IF ISNULL(@SubGoal_Name,'') =''
		Begin 
			--Raiserror('@@SubGoal Name Not Blank',18,2)
			select -106
			return
		End 

IF NOT EXISTS(Select 1 From KPMS_T0020_SubGoal_Master WHERE SubGoal_ID=@SubGoal_ID and IsActive < 2)

	BEGIN

	IF Exists(select 1 From dbo.KPMS_T0020_SubGoal_Master WITH (NOLOCK) Where upper(SubGoal_Name) = upper(@SubGoal_Name) and Cmp_ID = @Cmp_ID and IsActive < 2)  
		
		Begin 
			select -102
			return
		End  


	INSERT INTO [KPMS_T0020_SubGoal_Master]
				(  [Cmp_ID],

				   [SubGoal_Name]
					 ,[IsActive]
					 ,[Goal_ID]
				   ,[User_Id]
				   ,[Created_Date]
				  )
		 VALUES
			   (
					@Cmp_ID		,
					
					@SubGoal_Name	,
					@IsActive	,
					@Goal_Id,
					@User_ID	,
					GETDATE()	
				)
	END

ELSE

	BEGIN

 IF Exists(select 1 From dbo.KPMS_T0020_SubGoal_Master WITH (NOLOCK) Where upper(SubGoal_Name) = upper(@SubGoal_Name) and Cmp_ID = @Cmp_ID and SubGoal_ID <> @SubGoal_ID and IsActive < 2)  
		
		Begin 
			select -102
			return
		End  
					UPDATE [KPMS_T0020_SubGoal_Master]
					SET [Cmp_ID] =@Cmp_ID,
				   [SubGoal_Name] =@SubGoal_Name
				,[IsActive] =@IsActive
				,[Goal_ID] = @Goal_Id
				   ,[User_ID] =@User_ID
				   ,[Modify_Date] =GETDATE()
				   WHERE [SubGoal_ID] =@SubGoal_ID
	END

