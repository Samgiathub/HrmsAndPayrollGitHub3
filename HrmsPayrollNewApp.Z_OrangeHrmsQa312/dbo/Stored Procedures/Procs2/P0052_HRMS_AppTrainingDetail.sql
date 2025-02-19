


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0052_HRMS_AppTrainingDetail]
	   @App_Trainingdetail_Id		numeric(18,0) output
      ,@Cmp_ID						numeric(18,0)	
      ,@InitiateId					numeric(18,0)	=null
      ,@Emp_Id						numeric(18,0)	=null
      ,@Type						nvarchar(50)		=null  --Changed by Deepali -03Jun22
      ,@TrainingAreas				varchar(8000)	=null   
      ,@Attend_LastYear				nvarchar(1000)	=null  --Changed by Deepali -03Jun22
      ,@Recommended_ThisYear		nvarchar(1000)	=null  --Changed by Deepali -03Jun22
      ,@OtherTraining				nvarchar(1000)	=null  --Changed by Deepali -03Jun22 
      ,@tran_type					varchar(1)		
	  ,@User_Id						numeric(18,0)	= 0
	  ,@IP_Address					varchar(30)		= '' 
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	declare @OldValue as nvarchar(max)  --Changed by Deepali -03Jun22
	Declare @Emp_name as Varchar(250)
	Declare @Cmp_name as Varchar(250)
	declare @OldTrainingAreas as Varchar(8000)
	set @OldValue = ''
	
	If Upper(@tran_type) ='I' Or Upper(@tran_type) ='U'
		Begin
			if @Type = ''
				begin	
					--Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,0,'type is not Properly Inserted',0,'Enter type',GetDate(),'Appraisal')										
					Return
				End
		End
	If Upper(@tran_type) ='I'
		Begin
			select @App_Trainingdetail_Id = isnull(max(App_Trainingdetail_Id),0) + 1 from T0052_HRMS_AppTrainingDetail WITH (NOLOCK)
			Insert into T0052_HRMS_AppTrainingDetail
			(
				 App_Trainingdetail_Id
				,Cmp_ID
				,InitiateId
				,Emp_Id
				,Type
				,TrainingAreas
			)
			values
			(
				 @App_Trainingdetail_Id
				,@Cmp_ID
				,@InitiateId
				,@Emp_Id
				,@Type
				,@TrainingAreas
			)
			--Added By Mukti(start)10112016
				select @Cmp_name=Cmp_Name from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@Cmp_ID
				select @Emp_name=Alpha_Emp_Code +'-'+ Emp_Full_Name from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID=@Emp_Id		
				set @OldValue = 'New Value' + '#'+ 'Company Name :' + ISNULL(@Cmp_name,'') 
											+ '#'+ 'Initiate Id :' +CONVERT(nvarchar(10),ISNULL(@InitiateId,0)) 
											+ '#'+ 'Employee :' +ISNULL(@Emp_name,'') 			
											+ '#'+ 'Type :' +ISNULL(@Type,'') 			
											+ '#'+ 'Training Areas :' +ISNULL(@TrainingAreas,'')
			--Added By Mukti(end)10112016 			
			exec p0052_HRMS_AppTrainDetail  0,@Cmp_ID,@InitiateId,@Emp_Id,@type,@Attend_LastYear,@Recommended_ThisYear,@OtherTraining,@tran_type,@User_Id,@IP_Address
		End
	Else If  Upper(@tran_type) ='U' 	
		Begin
			--Added By Mukti(start)10112016
				select @Cmp_name=Cmp_Name from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@Cmp_ID
				select @Emp_name=Alpha_Emp_Code +'-'+ Emp_Full_Name from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID=@Emp_Id	
				select @OldTrainingAreas =TrainingAreas from  T0052_HRMS_AppTrainingDetail WITH (NOLOCK)
				Where App_Trainingdetail_Id = @App_Trainingdetail_Id and InitiateId = @InitiateId
				
				set @OldValue = 'old Value' + '#'+ 'Company Name :' + ISNULL(@Cmp_name,'') 
											+ '#'+ 'Initiate Id :' +CONVERT(nvarchar(10),ISNULL(@InitiateId,0)) 
											+ '#'+ 'Employee :' +ISNULL(@Emp_name,'') 
											+ '#'+ 'Type :' +ISNULL(@Type,'') 			
											+ '#'+ 'Training Areas :' +ISNULL(@OldTrainingAreas,'')
							   +'New Value' + '#'+ 'Company Name :' + ISNULL(@Cmp_name,'') 
											+ '#'+ 'Initiate Id :' +CONVERT(nvarchar(10),ISNULL(@InitiateId,0)) 
											+ '#'+ 'Employee :' +ISNULL(@Emp_name,'') 			
											+ '#'+ 'Type :' +ISNULL(@Type,'') 			
											+ '#'+ 'Training Areas :' +ISNULL(@TrainingAreas,'')
			--Added By Mukti(end)10112016
			
			 Update  T0052_HRMS_AppTrainingDetail
			  Set    TrainingAreas		=	@TrainingAreas
			  Where  App_Trainingdetail_Id = @App_Trainingdetail_Id and InitiateId = @InitiateId
			  
			  exec p0052_HRMS_AppTrainDetail  0,@Cmp_ID,@InitiateId,@Emp_Id,@type,@Attend_LastYear,@Recommended_ThisYear,@OtherTraining,@tran_type,@User_Id,@IP_Address
		End
	Else If  Upper(@tran_type) ='D'
		Begin
		--Added By Mukti(start)10112016
				select @Cmp_name=Cmp_Name from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@Cmp_ID
				select @Emp_name=Alpha_Emp_Code +'-'+ Emp_Full_Name from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID=@Emp_Id	
				select @OldTrainingAreas =TrainingAreas from  T0052_HRMS_AppTrainingDetail WITH (NOLOCK)
				Where App_Trainingdetail_Id = @App_Trainingdetail_Id and InitiateId = @InitiateId
				
				set @OldValue = 'old Value' + '#'+ 'Company Name :' + ISNULL(@Cmp_name,'') 
											+ '#'+ 'Initiate Id :' +CONVERT(nvarchar(10),ISNULL(@InitiateId,0)) 
											+ '#'+ 'Employee :' +ISNULL(@Emp_name,'') 
											+ '#'+ 'Type :' +ISNULL(@Type,'') 			
											+ '#'+ 'Training Areas :' +ISNULL(@OldTrainingAreas,'')
		--Added By Mukti(end)10112016									
			DELETE FROM T0052_HRMS_AppTrainingDetail WHERE App_Trainingdetail_Id = @App_Trainingdetail_Id
		End	
		
	exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Appraisal Training Details',@OldValue,@App_Trainingdetail_Id,@User_Id,@IP_Address	
END


