
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0040_PerformanceFeedback_Master]
	   @PerformanceF_ID				numeric(18) output
      ,@Cmp_ID						numeric(18)  
      ,@Performance_Name			nvarchar(100)  
      ,@Performance_Desc			nvarchar(500)
      ,@Performance_Sort			int
      ,@tran_type					varchar(1) 
	  ,@User_Id						numeric(18,0) = 0
	  ,@IP_Address					varchar(30)= '' 
	  ,@IsActive					int
	  ,@InActive_EffeDate			datetime
	  ,@Evaluation_Type				varchar(7)
	  ,@Effective_Date				datetime
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	 declare @OldValue as varchar(max)
	 declare @OldPerformance_Name as nvarchar(100)
	 declare @OldPerformance_Desc as nvarchar(500)
	 declare @oldsort as varchar(18)
	 
	  set @OldValue = ''
	  set @OldPerformance_Name = ''
	  set @OldPerformance_Desc = ''
	  set @oldsort =''
	  
	  if YEAR(@InActive_EffeDate)='1900'
		set @InActive_EffeDate = NULL
	  
	  If Upper(@tran_type) ='I' Or Upper(@tran_type) ='U'
		Begin
			If @Performance_Name = ''
				BEGIN
					--Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,0,'performance is not Properly Inserted',0,'Enter Proper Content',GetDate(),'Appraisal')						
					Return
				END
			IF EXISTS(select 1 from T0040_PerformanceFeedback_Master WITH (NOLOCK) where Performance_Sort=@Performance_Sort and PerformanceF_ID<>@PerformanceF_ID and Cmp_ID=@Cmp_ID)
				begin
					--Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,0,'Duplicate entry of sorting number',0,'Duplicate Sorting',GetDate(),'Appraisal')
					SET @PerformanceF_ID= 0 						
					Return
				End
			IF EXISTS(select 1 from T0040_PerformanceFeedback_Master WITH (NOLOCK) where Performance_Name=@Performance_Name and PerformanceF_ID<>@PerformanceF_ID and Cmp_ID=@Cmp_ID)
				BEGIN
					SET @PerformanceF_ID= 0 						
					Return
				End
		End		
	 If Upper(@tran_type) ='I'
		begin
			select @PerformanceF_ID = isnull(max(PerformanceF_ID),0) + 1 from T0040_PerformanceFeedback_Master WITH (NOLOCK)
			INSERT INTO T0040_PerformanceFeedback_Master
			(
				PerformanceF_ID,Cmp_ID,Performance_Name,Performance_Desc,Performance_Sort,IsActive,InActive_EffeDate,Evaluation_Type,Effective_Date
			)
			VAlUES
			(
				@PerformanceF_ID,@Cmp_ID,@Performance_Name,@Performance_Desc,@Performance_Sort,@IsActive,@InActive_EffeDate,@Evaluation_Type,@Effective_Date
			)
			set @OldValue = 'New Value' + '#'+ 'Performance :' +ISNULL( @Performance_Name,'') + '#' +'Performance Desc :' +ISNULL( @Performance_Desc,'') + '#' + 'Sort :' +  CAST(ISNULL( @Performance_Sort,'')AS varchar(18)) + '#'
		End
	Else If  Upper(@tran_type) ='U' 
		Begin
			select @OldPerformance_Name  =ISNULL(Performance_Name,''),@OldPerformance_Desc  =ISNULL(Performance_Desc,''),@oldsort=CAST(ISNULL(Performance_Sort,'')as varchar(18))  From dbo.T0040_PerformanceFeedback_Master WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and PerformanceF_ID = @PerformanceF_ID		
			UPDATE    T0040_PerformanceFeedback_Master
			SET       Performance_Name = @Performance_Name,
					  Performance_Desc = @Performance_Desc,
					  Performance_Sort = @Performance_Sort,
					  IsActive		   = @IsActive,
					  InActive_EffeDate = @InActive_EffeDate,
					  Evaluation_Type = @Evaluation_Type,
					  Effective_Date=@Effective_Date
			WHERE     PerformanceF_ID  = @PerformanceF_ID
			
			set @OldValue = 'old Value' + '#'+ 'Performance :' + @OldPerformance_Name  
									    + '#'+ 'Performance Desc :' + @OldPerformance_Desc 
										+ '#'+ 'Sort :' + @oldsort  
					+ '#' + 'New Value' + '#'+ 'Performance :' +ISNULL( @Performance_Name,'')
										+ '#'+ 'Performance Desc :' +ISNULL( @Performance_Desc,'') 
										+ '#'+ 'Sort :' + CAST(ISNULL( @Performance_Sort,'')as varchar(18)) 
		End
	Else If  Upper(@tran_type) ='D'
		Begin
			select @OldPerformance_Name  =ISNULL(Performance_Name,''),@OldPerformance_Desc  =ISNULL(Performance_Desc,''),@oldsort=CAST(ISNULL(Performance_Sort,'')as varchar(18))  From dbo.T0040_PerformanceFeedback_Master WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and PerformanceF_ID = @PerformanceF_ID		
			DELETE FROM T0040_PerformanceFeedback_Master WHERE PerformanceF_ID = @PerformanceF_ID					
				set @OldValue = 'old Value' + '#'+ 'Performance :' +ISNULL( @Performance_Name,'') 
										 + '#'+ 'Performance Desc :' + ISNULL(@Performance_Desc,'') 
										 + '#'+ 'Sort :' + CAST(ISNULL( @oldsort,'')as varchar(18))
		End
		exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Performance Feedback Master',@OldValue,@PerformanceF_ID,@User_Id,@IP_Address
END


