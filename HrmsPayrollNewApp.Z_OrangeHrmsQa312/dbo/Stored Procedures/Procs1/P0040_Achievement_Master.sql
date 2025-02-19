
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0040_Achievement_Master]
	 @AchievementId		as	numeric(18,0) Output
	,@Cmp_ID			as	numeric(18,0)
	,@Achievement_Level as	varchar(50)
	,@Achievement_Sort  as	int
	,@Achievement_Type  as	int
	,@Effective_Date	as	datetime	--added on 19 sep 2016
	,@tran_type			as	varchar(1) 
	,@User_Id			as	numeric(18,0) = 0
	,@IP_Address		as	varchar(30)= '' 
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


BEGIN
	declare @OldValue as varchar(max)
	declare @OldAchievement_Level as varchar(50)
	declare @oldAchievement_Sort as varchar(18)
	declare @oldAchievement_Type as varchar(18)
	 
	set @OldValue = ''
	set @OldAchievement_Level = ''
	set @oldAchievement_Sort = ''
	set @oldAchievement_Type = ''
	
	
	If Upper(@tran_type) ='I' Or Upper(@tran_type) ='U'
		Begin
			If @Achievement_Level = ''
				BEGIN
					--Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,0,'Achieve is not Properly Inserted',0,'Enter Proper Content',GetDate(),'Appraisal')						
					Return
				END
			if exists(select 1 from T0040_Achievement_Master WITH (NOLOCK) where Achievement_Sort =@Achievement_Sort and AchievementId<>@AchievementId and Cmp_ID=@Cmp_ID and Achievement_Type=@Achievement_Type and Effective_Date = @Effective_Date)--added effective date 19 sep 2016
				begin
					--Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,0,'Duplicate entry of sorting number',0,'Duplicate Sorting',GetDate(),'Appraisal')
					SET @AchievementId= 0 						
					Return
				End
		End
	If Upper(@tran_type) ='I'	
		Begin
			select @AchievementId = isnull(max(AchievementId),0) + 1 from T0040_Achievement_Master WITH (NOLOCK)
			INSERT INTO T0040_Achievement_Master
			(
				AchievementId,Cmp_ID,Achievement_Level,Achievement_Sort,Achievement_Type,Effective_Date
			)
			VAlUES
			(
				@AchievementId,@Cmp_ID,@Achievement_Level,@Achievement_Sort,@Achievement_Type,@Effective_Date
			)
			set @OldValue = 'New Value' + '#'+ 'Achievement Level :' +ISNULL( @Achievement_Level,'') + '#' + 'Sort :' +  CAST(ISNULL( @Achievement_Sort,'')AS varchar(18)) + '#' + CAST(ISNULL(@Achievement_Type,'')As varchar(18)) + '#'
		End
	Else If  Upper(@tran_type) ='U' 
		Begin
			UPDATE    T0040_Achievement_Master
			SET       Achievement_Level = @Achievement_Level,
					  Achievement_Sort = @Achievement_Sort,
					  Achievement_Type = @Achievement_Type,
					  Effective_Date = @Effective_Date --19 Sep 2016
			WHERE     AchievementId  = @AchievementId
			
			set @OldValue = 'old Value' + '#'+ 'Achievement Level :' + @Achievement_Level  + '#' + 
			+ 'old Value' + '#'+ 'Sort :' + CAST(ISNULL( @Achievement_Sort,'')as varchar(18)) + '#' +
			+ 'old Value' + '#'+ 'Type :' +CAST(ISNULL(@Achievement_Type,'') as varchar(18))  + '#' +	
            + 'New Value' + '#'+ 'Achievement Level :' +ISNULL( @Achievement_Level,'') + '#' 
            + 'New Value' + '#'+ 'Sort :' + CAST(ISNULL( @Achievement_Sort,'')as varchar(18)) + '#'
            + 'New Value' + '#'+ 'Type :' + CAST(ISNULL(@Achievement_Type,'') as varchar(18)) + '#'
		End
	Else If  Upper(@tran_type) ='D'
		Begin
			select @OldAchievement_Level  =ISNULL(@Achievement_Level,''),@oldAchievement_Sort=CAST(ISNULL( @Achievement_Sort,'')as varchar(18))  From dbo.T0040_Achievement_Master WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and AchievementId = @AchievementId		
			DELETE FROM T0040_Achievement_Master WHERE AchievementId = @AchievementId					
			set @OldValue = 'old Value' + '#'+ 'Achievement Level :' +ISNULL( @Achievement_Level,'') + '#' 
						   + 'old Value' + '#'	+ 'Sort :' + CAST(ISNULL( @Achievement_Sort,'')as varchar(18)) + '#'
						   + 'old Value' + '#'+ 'Type :' + CAST(ISNULL( @Achievement_Type,'')as varchar(18))  
		End
		exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Achievement Master',@OldValue,@AchievementId,@User_Id,@IP_Address
END
-------------

