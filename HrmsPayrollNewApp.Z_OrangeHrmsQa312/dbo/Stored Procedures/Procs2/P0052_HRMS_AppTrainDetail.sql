
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0052_HRMS_AppTrainDetail]
	   @App_Traindetail_Id				numeric(18,0) output
      ,@Cmp_ID						numeric(18,0)	
      ,@InitiateId					numeric(18,0)	=null
      ,@Emp_Id						numeric(18,0)	=null
      ,@Type						nvarchar(50)	=null   --Changed by Deepali -03Jun22
      ,@Attend_LastYear				nvarchar(1000)	=null   --Changed by Deepali -03Jun22
      ,@Recommended_ThisYear		nvarchar(1000)	=null   --Changed by Deepali -03Jun22
      ,@OtherTraining				nvarchar(1000)	=null   --Changed by Deepali -03Jun22
      ,@tran_type					varchar(1)		
	  ,@User_Id						numeric(18,0)	= 0
	  ,@IP_Address					varchar(30)		= '' 
AS
BEGIN

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	declare @OldValue as nvarchar(max)
	set @OldValue = ''
	
	If Upper(@tran_type) ='I' Or Upper(@tran_type) ='U'
		Begin
			if @Type = ''
				begin	
					--Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,0,'type is not Properly Inserted',0,'Enter type',GetDate(),'Appraisal')										
					Return
				End
			if @Attend_LastYear='' and @Recommended_ThisYear='' and @OtherTraining=''
				begin
					Return
				End
		End
	If Upper(@tran_type) ='I'
		Begin 
			if not exists (select 1 from T0052_HRMS_AppTrainDetail WITH (NOLOCK) where InitiateId=@InitiateId and [Type]=@Type)
				begin 
					select @App_Traindetail_Id = isnull(max(App_Traindetail_Id),0) + 1 from T0052_HRMS_AppTrainDetail WITH (NOLOCK)
				
					Insert into T0052_HRMS_AppTrainDetail
					(
						 App_Traindetail_Id
						,Cmp_ID
						,InitiateId
						,Emp_Id
						,Type
						,Attend_LastYear
						,Recommended_ThisYear
						,OtherTraining
					)
					values
					(
						 @App_Traindetail_Id
						,@Cmp_ID
						,@InitiateId
						,@Emp_Id
						,@Type
						,@Attend_LastYear
						,@Recommended_ThisYear
						,@OtherTraining
					)
				
				End
		End	
	Else If  Upper(@tran_type) ='U' 	
		Begin
			 Update T0052_HRMS_AppTrainDetail
			 Set    Attend_LastYear			=	@Attend_LastYear
				   ,Recommended_ThisYear	=	@Recommended_ThisYear
				   ,OtherTraining			=	@OtherTraining
			 Where  App_Traindetail_Id = @App_Traindetail_Id and InitiateId = @InitiateId
		End
	Else If  Upper(@tran_type) ='D'
		Begin
			DELETE FROM T0052_HRMS_AppTrainDetail WHERE App_Traindetail_Id = @App_Traindetail_Id
		End			
	exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'HRMS_AppTrainDetail',@OldValue,@App_Traindetail_Id,@User_Id,@IP_Address
END
