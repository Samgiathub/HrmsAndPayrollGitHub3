-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0052_HRMS_PerformanceAnswer]
			 @PFAnswer_ID		numeric(18) output  
			,@Cmp_ID			numeric(18)   
			,@InitiateId		numeric(18)		=null 
			,@PerformanceF_ID	numeric(18)		=null 
			,@Emp_Id			numeric(18)		=null
			,@Answer			nvarchar(1000)	=null  --Changed by Deepali -03Jun22
			,@tran_type			varchar(1) 
			,@User_Id			numeric(18,0)	= 0
			,@IP_Address		varchar(30)		= '' 
			,@HOD_Feedback		nvarchar(1000)   =''  --Changed by Deepali -03Jun22
			,@GH_Feedback		nvarchar(1000)   =''  --Changed by Deepali -03Jun22
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	declare @OldValue as nvarchar(max)
	Declare @Emp_name as Varchar(250)
	Declare @Cmp_name as Varchar(250)
	Declare @OldPerformanceF_ID as varchar(10)
	Declare @Oldanswer as nvarchar(1000)
	Declare @Performance_Name as nvarchar(1000)
    Declare @OldPerformance_Name as nvarchar(1000)
	set @OldValue = ''
	
	--If Upper(@tran_type) ='I' Or Upper(@tran_type) ='U'
	--	Begin
	--		If @Answer = ''
	--			BEGIN
	--				--Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,0,'Answer is not Properly Inserted',0,'Enter Answer Vertical Name',GetDate(),'Appraisal')						
	--				Return
	--			END
	--	End
	If Upper(@tran_type) ='I'
		Begin
			select @PFAnswer_ID = isnull(max(PFAnswer_ID),0) + 1 from T0052_HRMS_PerformanceAnswer	WITH (NOLOCK)
			Insert Into T0052_HRMS_PerformanceAnswer
			(
				  PFAnswer_ID
				 ,Cmp_ID
				 ,InitiateId
				 ,PerformanceF_ID
				 ,Emp_Id
				 ,Answer		
				 ,HOD_Feedback	
				 ,GH_Feedback	 
			)
			Values
			(
				 @PFAnswer_ID
				,@Cmp_ID
				,@InitiateId
				,@PerformanceF_ID
				,@Emp_Id
				,@Answer
				,@HOD_Feedback
				,@GH_Feedback
			) 	
			--Added By Mukti(start)10112016
				select @Cmp_name=Cmp_Name from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@Cmp_ID
				select @Performance_Name=Performance_Name from T0040_PerformanceFeedback_Master WITH (NOLOCK) where PerformanceF_ID=@PerformanceF_ID
				select @Emp_name=Alpha_Emp_Code +'-'+ Emp_Full_Name from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID=@Emp_Id		
				set @OldValue = 'New Value' + '#'+ 'Company Name :' + ISNULL(@Cmp_name,'') 
											+ '#'+ 'Initiate Id :' +CONVERT(nvarchar(10),ISNULL(@InitiateId,0)) 
											+ '#'+ 'Employee :' +ISNULL(@Emp_name,'') 			
											+ '#'+ 'Performance :' +ISNULL(@Performance_Name,'') 			
											+ '#'+ 'Answer :' +ISNULL(@Answer,'')
			--Added By Mukti(end)10112016 			
		End		
	Else If  Upper(@tran_type) ='U' 
		Begin			 
			--Added By Mukti(start)10112016
				select @Cmp_name=Cmp_Name from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@Cmp_ID
				select @Oldanswer=Answer,@OldPerformanceF_ID=PerformanceF_ID from T0052_HRMS_PerformanceAnswer WITH (NOLOCK) where PFAnswer_ID = @PFAnswer_ID and InitiateId=@InitiateId
				select @Emp_name=Alpha_Emp_Code +'-'+ Emp_Full_Name from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID=@Emp_Id		
				select @Performance_Name=Performance_Name from T0040_PerformanceFeedback_Master WITH (NOLOCK) where PerformanceF_ID=@PerformanceF_ID
				select @OldPerformance_Name=Performance_Name from T0040_PerformanceFeedback_Master WITH (NOLOCK) where PerformanceF_ID=@OldPerformanceF_ID
				set @OldValue = 'old Value' + '#'+ 'Company Name :' + ISNULL(@Cmp_name,'') 
											+ '#'+ 'Initiate Id :' +CONVERT(nvarchar(10),ISNULL(@InitiateId,0)) 
											+ '#'+ 'Employee :' +ISNULL(@Emp_name,'') 
											+ '#'+ 'Performance :' +ISNULL(@Performance_Name,'') 			
											+ '#'+ 'Answer :' +ISNULL(@OldAnswer,'')
						       +'New Value' + '#'+ 'Company Name :' + ISNULL(@Cmp_name,'') 
											+ '#'+ 'Initiate Id :' +CONVERT(nvarchar(10),ISNULL(@InitiateId,0)) 
											+ '#'+ 'Employee :' +ISNULL(@Emp_name,'') 			
											+ '#'+ 'Performance :' +ISNULL(@Performance_Name,'') 			
											+ '#'+ 'Answer :' +ISNULL(@Answer,'')
			--Added By Mukti(end)10112016 		
			
			  Update T0052_HRMS_PerformanceAnswer
			  Set    Answer = @Answer,
					 HOD_Feedback = @HOD_Feedback,		
					 GH_Feedback = @GH_Feedback	 
			  Where  PFAnswer_ID = @PFAnswer_ID and InitiateId=@InitiateId
		End
	Else If  Upper(@tran_type) ='D'
		Begin
		--Added By Mukti(start)10112016
				select @Cmp_name=Cmp_Name from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@Cmp_ID
				select @Oldanswer=Answer,@OldPerformanceF_ID=PerformanceF_ID from T0052_HRMS_PerformanceAnswer WITH (NOLOCK) where PFAnswer_ID = @PFAnswer_ID and InitiateId=@InitiateId
				select @Emp_name=Alpha_Emp_Code +'-'+ Emp_Full_Name from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID=@Emp_Id		
				select @Performance_Name=Performance_Name from T0040_PerformanceFeedback_Master WITH (NOLOCK) where PerformanceF_ID=@PerformanceF_ID
				select @OldPerformance_Name=Performance_Name from T0040_PerformanceFeedback_Master WITH (NOLOCK) where PerformanceF_ID=@OldPerformanceF_ID
				set @OldValue = 'old Value' + '#'+ 'Company Name :' + ISNULL(@Cmp_name,'') 
											+ '#'+ 'Initiate Id :' +CONVERT(nvarchar(10),ISNULL(@InitiateId,0)) 
											+ '#'+ 'Employee :' +ISNULL(@Emp_name,'') 
											+ '#'+ 'Performance :' +ISNULL(@Performance_Name,'') 			
											+ '#'+ 'Answer :' +ISNULL(@OldAnswer,'')
		--Added By Mukti(end)10112016
			DELETE FROM T0052_HRMS_PerformanceAnswer WHERE PFAnswer_ID = @PFAnswer_ID
		End		
	exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Performance Answer',@OldValue,@PFAnswer_ID,@User_Id,@IP_Address	
END

--SP-12
