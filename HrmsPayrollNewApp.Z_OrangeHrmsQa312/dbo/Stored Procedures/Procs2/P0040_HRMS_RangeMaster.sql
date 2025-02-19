
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE  PROCEDURE [dbo].[P0040_HRMS_RangeMaster]
	   @Range_ID				numeric(18) output
      ,@Cmp_ID					numeric(18)  
      ,@Range_From				numeric(18,2) 
      ,@Range_To				numeric(18,2) 
      ,@Range_Type				int
      ,@Range_Level			    varchar(50)
      ,@Range_Dept				varchar(800)=null
      ,@Range_Grade				varchar(800)=null
      ,@Range_PID				numeric(18,0) = null
      ,@Range_Percent_Allocate  numeric(18,2)=null
      ,@Range_AchievementId		numeric(18,2)=null
      ,@Effective_Date			datetime = null --19 sep 2016
      ,@tran_type				varchar(1) 
	  ,@User_Id					numeric(18,0) = 0
	  ,@IP_Address				varchar(30)= '' 
AS
BEGIN

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	 declare @OldValue as varchar(max)
	 declare @OldRange_From as varchar(18)
	 declare @OldRange_To as varchar(18)
	 declare @OldRange_Type as varchar(18)
	 declare @oldRange_Level as varchar(50)
	 declare @oldRange_Dept	 as varchar(800)
	 declare @oldRange_Grade as varchar(800)
	 declare @oldRange_PID  as varchar(18)
	 declare @oldRange_Percent_Allocate as varchar(18)
	 declare @oldRange_AchievementId as varchar(18)
	 	 
	  set @OldValue = ''
	  set @OldRange_From = ''
	  set @OldRange_To = ''
	  set @OldRange_Type =''
	  set @oldRange_Level = ''
	  set @oldRange_Dept =''
	  set @oldRange_Grade = ''
	  set @oldRange_PID  = ''
	  set @oldRange_Percent_Allocate =''
	  set @oldRange_AchievementId=''
	  
	   
	  
	  If Upper(@tran_type) ='I' Or Upper(@tran_type) ='U'
		begin
			If @Range_From = null
				begin
					--Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,0,'From range is not Properly Inserted',0,'Enter range from',GetDate(),'Appraisal')						
					Return
				end
		End
	If Upper(@tran_type) ='I'
		begin
			--if exists(Select 1 from T0040_HRMS_RangeMaster WITH (NOLOCK) where Cmp_Id=@Cmp_ID and Range_Id=@Range_ID and Range_Type=@Range_Type and Effective_Date= @Effective_Date and
			--	( (@Range_From >= Range_From and @Range_From <= Range_To) or 
			--				(@Range_To >= Range_From and 	@Range_To <= Range_To) or 
			--				(Range_From >= @Range_From and @Range_From <= @Range_To) or
			--				(Range_To >= @Range_From and Range_To <= @Range_To))) 
			--Begin				
			--	RAISERROR ('Slab like this already exist' , 16, 2) 
			--	Return
			--End
		--if not exists (select 1 from T0040_HRMS_RangeMaster where Range_From=@Range_From and Range_To=@Range_To and Range_Type=@Range_Type and Range_ID<>@Range_ID and Cmp_ID=@Cmp_ID)
		--	Begin
				select @Range_ID = isnull(max(Range_ID),0) + 1 from T0040_HRMS_RangeMaster WITH (NOLOCK)
				INSERT INTO T0040_HRMS_RangeMaster
				(
					Range_ID,Cmp_ID,Range_From,Range_To,Range_Type,Range_Level,Range_Dept,Range_Grade,Range_PID,Range_Percent_Allocate,Range_AchievementId,Effective_Date --19 sep 2016
				)
				VAlUES
				(
					@Range_ID,@Cmp_ID,@Range_From,@Range_To,@Range_Type,@Range_Level,@Range_Dept,@Range_Grade,@Range_PID,@Range_Percent_Allocate,@Range_AchievementId,@Effective_Date
				)
				set @OldValue = 'New Value' + '#'+ 'Range To :' +CAST(@OldRange_To as varchar(18)) + '#' +'Range From  :' +CAST(@OldRange_From as varchar(18)) + '#' + 'Range Type :' + CAST(ISNULL( @OldRange_Type,'')as varchar(18)) + '#' + 'Range Level :' + ISNULL(@oldRange_Level,'') + '#' 
											+ '#'+ 'Range Dept :' + @oldRange_Dept +'#'+ 'Range Grade :' + @oldRange_Grade +'#'+ Isnull(@oldRange_Grade ,'') +'#' + 'Range PID :' + CAST(ISNULL(@oldRange_PID,'')as varchar(18))+'#'+ 'Range_Percent_Allocate :' + ISNULL(@oldRange_Percent_Allocate,''
											+ '#'+ 'Range_AchievementId :' + isnull(@oldRange_AchievementId,'') + '#')
			--End
		End		
	Else If  Upper(@tran_type) ='U' 	
		Begin
		
			--if exists(Select 1 from T0040_HRMS_RangeMaster where Cmp_Id=@Cmp_ID and Range_Id<>@Range_ID and Range_Type=@Range_Type and
			--	( (@Range_From >= Range_From and @Range_From <= Range_To) or 
			--				(@Range_To >= Range_From and 	@Range_To <= Range_To) or 
			--				(Range_From >= @Range_From and @Range_From <= @Range_To) or
			--				(Range_To >= @Range_From and Range_To <= @Range_To))) 
			--Begin				
			--	RAISERROR ('Slab like this already exists' , 16, 2) 
			--	Return
			--End
		
			UPDATE    T0040_HRMS_RangeMaster
			SET       Range_From	 = @Range_From,
					  Range_To		 = @Range_To,
					  Range_Type	 = @Range_Type,
					  Range_Level	 = @Range_Level,
					  Range_Dept	 = @Range_Dept,
					  Range_Grade	 = @Range_Grade,
					  Range_PID		 = @Range_PID,
					  Range_Percent_Allocate = @Range_Percent_Allocate,
					  Effective_Date = @Effective_Date, --19 Sep 2016
					  Range_AchievementId = @Range_AchievementId
			WHERE     Range_ID		 = @Range_ID
			
			set @OldValue = 'old Value' + '#'+ 'Range From :' + CAST(@OldRange_From as varchar(18)) + '#' + 
			+ 'old Value' + '#'+ 'Range To:' + CAST(@OldRange_To as varchar(18))  + '#' +
			+ 'old Value' + '#'+ 'Range Type:' + CAST(@OldRange_Type as varchar(18)) + '#' +
			+ 'old Value' + '#'+ 'Range Level:' + CAST(@oldRange_Level as varchar(50)) + '#' +
            + 'New Value' + '#'+ 'Range From :' +CAST(ISNULL( @Range_From,'') as varchar(18)) + '#' 
            + 'New Value' + '#'+ 'Range To :' +CAST(ISNULL( @Range_To,'')as varchar(18)) + '#' 
            + 'New Value' + '#'+ 'Range Type :' + CAST(ISNULL( @Range_Type,'')as varchar(18)) + '#'
            + 'New Value' + '#'+ 'Range Level :' + ISNULL( @Range_Level,'') + '#'
            + 'New Value' + '#'+ 'Range Dept :' + ISNULL( @Range_Dept,'') + '#'
            + 'New Value' + '#'+ 'Range Grade :' + ISNULL( @Range_Grade,'') + '#'
            + 'New value' + '#'+ 'Range PID :' + CAST(ISNULL(@Range_PID,'') as varchar(18)) + '#'  
            + 'New Value' + '#'+ 'Range PercentAllocate :' +CAST( ISNULL(@Range_Percent_Allocate,'') as varchar(18))+'#'
            + 'New Value' + '#'+ 'Range AchievementId :' + CAST(ISNULL(@Range_AchievementId,'')as varchar(18))+'#'
		End
	Else If  Upper(@tran_type) ='D'
		begin
			select @OldRange_From  =CAST(ISNULL( @Range_From,'') as varchar(18)),@OldRange_To  =CAST(ISNULL( @Range_To,'')as varchar(18)),@OldRange_Type=CAST(ISNULL( @Range_Type,'')as varchar(18)),@oldRange_Level=ISNULL( @Range_Level,''),@oldRange_Dept=isnull(@Range_Dept,''),@oldRange_Grade=ISNULL(@Range_Grade,''),@oldRange_PID = isnull(@Range_PID,''),@oldRange_Percent_Allocate = ISNULL(@Range_Percent_Allocate,'')  From dbo.T0040_HRMS_RangeMaster WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Range_ID = @Range_ID		
				DELETE FROM T0040_HRMS_RangeMaster WHERE Range_ID = @Range_ID					
			 set @OldValue = 'old Value' + '#'+ 'Range From :' +CAST(ISNULL( @Range_From,'') as varchar(18)) + '#' 
						   + 'old Value' + '#'+ 'Range To :' + CAST(ISNULL( @Range_To,'')as varchar(18)) + '#' 	
						   + 'old Value' + '#'	+ 'Range Type :' +CAST(ISNULL( @Range_Type,'')as varchar(18))+ '#'
						   + 'old Value' + '#'	+ 'Range Level :' +ISNULL( @Range_Level,'')+ '#'
					       + 'old Value' + '#'+ 'Range Dept :' + ISNULL( @Range_Dept,'') + '#'
						   + 'old Value' + '#'+ 'Range Grade :' + ISNULL( @Range_Grade,'') + '#'
						   + 'old Value' + '#' + 'Range PID :' + ISNULL(@Range_PID,'')+'#'
						   + 'old Value' + '#' + 'Range PercentAllocate :' + cast(ISNULL(@Range_Percent_Allocate,'')as varchar(18))+'#'
						   + 'old Value' + '#' + 'Range AchievementId :' + cast(ISNULL(@Range_AchievementId,'') as varchar(18)) +'#'
		End
		exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Range Master',@OldValue,@Range_ID,@User_Id,@IP_Address
END
----------------------------

