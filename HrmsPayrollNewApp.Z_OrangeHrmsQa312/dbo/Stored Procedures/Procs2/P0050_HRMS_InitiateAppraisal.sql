



---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0050_HRMS_InitiateAppraisal]
	   @InitiateId			numeric(18,0) output  
      ,@Cmp_ID				numeric(18,0)
      ,@Emp_Id				numeric(18,0)
      ,@AppraiserId			numeric(18,0)
      ,@SA_Startdate		datetime     =null
      ,@SA_Enddate			datetime	 =null
      ,@SA_EmpComments		NVarchar(500) =null
      ,@SA_AppComments		NVarchar(500) =null
      ,@SA_Status			int	= null
      ,@SA_SubmissionDate	datetime     =null
      ,@SA_ApprovedDate		datetime	 =null
      ,@SA_ApprovedBy		numeric(18,0)=null
      ,@Overall_Status      int=null
      ,@SA_SendToRM         int=null
      ,@tran_type			varchar(1)	
	  ,@User_Id				numeric(18,0) = 0
	  ,@IP_Address			varchar(30)= ''
	  ,@SendToHOD			int = null --added on 15 Feb 2016
	  ,@HOD_Id				numeric(18,0) = null  --added on 25 Mar 2016
	  ,@DirectScore			as int = 0 --added on 01 Oct 2016
	  ,@Final_Evaluation    int =0--Mukti(15112016)--0 for interim process and 1 for Final -- changed by Deepali - 19May2022
	  ,@Financial_Year		int = null --added on 22 Nov 2016
	  ,@Duration_FromMonth	int	= null --added on 22 Nov 2016
	  ,@Duration_ToMonth	int	= null --added on 22 Nov 2016
	  ,@GH_Id				numeric(18,0)=null --added on 22 Feb 2017
	  ,@Rm_Required			tinyint = 1 --added on 2/8/2017	  
	  ,@Send_directly_Performance_Assessment int
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
    
declare @OldValue as Nvarchar(max)
Declare @Emp_name as Varchar(250)
Declare @Cmp_name as Varchar(250)
Declare @HOD_name as Varchar(250)
Declare @SendToRM as Varchar(10)
Declare @ApprovedBy as Varchar(250)
Declare @OldSA_AppComments as NVarchar(500)
Declare @OldSA_ApprovedBy as NVarchar(250)
Declare @OldSA_Status as Varchar(10)
Declare @OldSA_Enddate as Varchar(40)
Declare @OldOverall_Status as Varchar(10)
Declare @OldSA_EmpComments as NVarchar(500)
Declare @OldSA_SubmissionDate as Varchar(40)
Declare @OldSA_ApprovedDate as Varchar(40)
Declare @OldApprovedBy as Varchar(250)
declare @Direct_Score as varchar(5)	
declare @FinalEvaluation as varchar(5)
declare @FinancialYear as varchar(5)
declare @DurationFromMonth as varchar(5)
declare @DurationToMonth as varchar(5)

if @SA_ApprovedDate=''
	set @SA_ApprovedDate=null
if @SA_SubmissionDate=''
	set @SA_SubmissionDate=null

--added on 25 Mar 2016
if @HOD_Id =0
	set @HOD_Id = null

	If Upper(@tran_type) ='I' Or Upper(@tran_type) ='U'
		Begin
			If @Emp_Id = 0
				BEGIN
					--Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,0,'Select employee',0,'Employee not selected',GetDate(),'Appraisal')						
					Return
				END			
		End
	
	---added on 29 Nov 2016 start------------------	
	If Upper(@tran_type) ='I'
		BEGIN
		print '@tran_type'
			if @Overall_Status =0
				set @Overall_Status = null
	
				DECLARE @multiple_eval as int
				SELECT @multiple_eval=isnull(Multiple_Evaluation,0)
				FROM T0050_AppraisalLimit_Setting A WITH (NOLOCK) INNER JOIN
						(SELECT isnull(max(effective_date),(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) Effective_Date 
						 from T0050_AppraisalLimit_Setting WITH (NOLOCK) where Cmp_ID=@cmp_id
						 and isnull(Effective_Date,(SELECT From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id))<=@SA_Startdate
						 )B on B.effective_date= A.effective_date 
				WHERE a.Cmp_ID=@cmp_id 
				
				IF @multiple_eval =1
					BEGIN 		
					print @multiple_eval 
						IF EXISTS(select 1 from T0050_HRMS_InitiateAppraisal WITH (NOLOCK) where Emp_Id = @Emp_Id  AND
								  ((Duration_FromMonth BETWEEN @Duration_FromMonth and @Duration_ToMonth) or (Duration_ToMonth BETWEEN @Duration_FromMonth and @Duration_ToMonth))
								  --((Duration_FromMonth <= @Duration_FromMonth and Duration_ToMonth>=@Duration_FromMonth )or (Duration_FromMonth <= @Duration_ToMonth and Duration_ToMonth>=@Duration_ToMonth)) 
									and Financial_Year=@Financial_Year)	
							BEGIN 							
								set @InitiateId=0
								--Return
							END
					END
		END
	---added on 29 Nov 2016 end--------------------
	
	If Upper(@tran_type) ='I'
		Begin
		print '1111'
			if exists(select 1 from T0050_HRMS_InitiateAppraisal WITH (NOLOCK) where Emp_Id=@Emp_Id and Overall_Status<>5)
			BEGIN			
				set @InitiateId=0
				RETURN
			END
		else
		print 'Deepa123'
			BEGIN
			print '3333'
				select @InitiateId = isnull(max(InitiateId),0) + 1 from T0050_HRMS_InitiateAppraisal WITH (NOLOCK)
				Insert Into T0050_HRMS_InitiateAppraisal 
				(
					 InitiateId
					,Cmp_ID
					,Emp_Id
					,AppraiserId
					,SA_Startdate
					,SA_Enddate
					,SA_EmpComments
					,SA_AppComments
					,SA_Status
					,SA_SendToRM
					,SendToHOD--added on 15 Feb 2016
					,HOD_Id  --added on 25 Mar 2016
					,DirectScore	 --added on 01 Oct 2016
					,Final_Evaluation --added by Mukti(15112016)
					,Financial_Year	--added on 22 Nov 2016
					,Duration_FromMonth	--added on 22 Nov 2016
					,Duration_ToMonth	--added on 22 Nov 2016
					,GH_Id				--added on 22 Feb 2017
					,Rm_Required		--added on 02/08/2017					
					,Send_directly_Performance_Assessment							
				)
				VALUES  
				(
					 @InitiateId
					,@Cmp_ID
					,@Emp_Id
					,@AppraiserId
					,@SA_Startdate
					,@SA_Enddate
					,@SA_EmpComments
					,@SA_AppComments
					,@SA_Status
					,@SA_SendToRM
					,@SendToHOD--added on 15 Feb 2016
					,@HOD_Id --added on 25 Mar 2016
					,@DirectScore	 --added on 01 Oct 2016
					,@Final_Evaluation --added by Mukti(15112016)
					,@Financial_Year	--added on 22 Nov 2016
					,@Duration_FromMonth	--added on 22 Nov 2016
					,@Duration_ToMonth	--added on 22 Nov 2016
					,@GH_Id				--added on 22 Feb 2017
					,@Rm_Required		--added on 02/08/2017					
					,@Send_directly_Performance_Assessment					
				)
				
				IF @Rm_Required= 0 --added on 03/08/2017
					BEGIN
					 UPDATE T0050_HRMS_InitiateAppraisal SET Overall_Status = 0 WHERE InitiateId = @InitiateId
					END
				
			--Added By Mukti(start)08112016
			select @Cmp_name=Cmp_Name from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@Cmp_Id
			select @Emp_name=Alpha_Emp_Code +'-'+ Emp_Full_Name from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID=@Emp_Id
			if @HOD_Id >0			
				select @HOD_name=Alpha_Emp_Code +'-'+ Emp_Full_Name from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID=@HOD_Id
			else 
				set @HOD_name=''
				
			if @SA_SendToRM=0
				set @SendToRM='No'
			else if @SA_SendToRM=1
				set @SendToRM='Yes'
			
			if @DirectScore=1
				set @Direct_Score='Yes'
			else
				set @Direct_Score='No'
				
			if @Final_Evaluation=1
				set @FinalEvaluation='Yes'
			else
				set @FinalEvaluation='No'
			set @OldValue = 'New Value' + '#' +'Company Name :' + ISNULL(@Cmp_name,'') 
									    + '#'+ 'Initiate Id :' +CONVERT(nvarchar(10),ISNULL(@InitiateId,0)) 
										+ '#'+ 'Employee :' +ISNULL(@Emp_name,'') 
										+ '#'+ 'Appraiser Id :' +CONVERT(nvarchar(10),ISNULL(@AppraiserId,0)) 
										+ '#'+ 'Start Date :' +CONVERT(nvarchar(40),ISNULL(@SA_Startdate,'')) 
										+ '#'+ 'End Date :' +CONVERT(nvarchar(40),ISNULL(@SA_Enddate,'')) 
										+ '#'+ 'Employee Comments :' +ISNULL(@SA_EmpComments,'') 
										+ '#'+ 'Appraiser Comments :' +ISNULL(@SA_AppComments,'') 
										+ '#'+ 'Status :' +CONVERT(nvarchar(10),ISNULL(@SA_Status,0)) 
										+ '#'+ 'Send To RM :' +ISNULL(@SendToRM,'') 
										+ '#'+ 'HOD :' +ISNULL(@HOD_name,'') 
										+ '#'+ 'Direct Score :' +CONVERT(nvarchar(5),ISNULL(@Direct_Score,0)) 
										+ '#'+ 'Final Evaluation :' +CONVERT(nvarchar(5),ISNULL(@FinalEvaluation,0)) 
										+ '#'+ 'Financial Year :' +CONVERT(nvarchar(5),ISNULL(@FinancialYear,0)) 
										+ '#'+ 'Duration From Month :' +CONVERT(nvarchar(5),ISNULL(@DurationFromMonth,0)) 
										+ '#'+ 'Duration To Month :' +CONVERT(nvarchar(5),ISNULL(@DurationToMonth,0)) 
			--Added By Mukti(end)08112016
			END
			Select @OldValue
		END
	Else If  Upper(@tran_type) ='U' 
		Begin
		 --Added By Mukti(start)08112016
			select @Cmp_name=Cmp_Name from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@Cmp_Id	
					
			select @OldSA_AppComments=SA_AppComments,@OldSA_EmpComments=SA_EmpComments,@OldSA_Enddate=SA_Enddate,
				   @OldSA_Status=SA_Status,@OldSA_SubmissionDate=SA_SubmissionDate,@OldSA_ApprovedDate=SA_ApprovedDate,
				   @OldSA_ApprovedBy=SA_ApprovedBy,@OldOverall_Status=Overall_Status,@Emp_Id=Emp_Id  
			from T0050_HRMS_InitiateAppraisal WITH (NOLOCK) Where  InitiateId = @InitiateId 
			
			select @OldApprovedBy=Alpha_Emp_Code +'-'+ Emp_Full_Name from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID=@OldSA_ApprovedBy	
			select @ApprovedBy=Alpha_Emp_Code +'-'+ Emp_Full_Name from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID=@SA_ApprovedBy	
			select @Emp_name=Alpha_Emp_Code +'-'+ Emp_Full_Name from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID=@Emp_Id			
		 --Added By Mukti(end)08112016	
		
		if @OldOverall_Status=0
			set @Overall_Status=0
			
			Update T0050_HRMS_InitiateAppraisal
			  Set  				
				SA_AppComments = @SA_AppComments,
				SA_EmpComments = @SA_EmpComments,
				SA_Enddate     = @SA_Enddate,
				SA_Status      = @SA_Status,
				SA_SubmissionDate = @SA_SubmissionDate,
				SA_ApprovedDate = @SA_ApprovedDate,
				SA_ApprovedBy	= @SA_ApprovedBy,
				Overall_Status	= @Overall_Status				
				--,@Send_directly_Performance_Assessment=@Send_directly_Performance_Assessment			
			  Where  InitiateId = @InitiateId 
			  
			--Added By Mukti(start)08112016	
			set @OldValue = 'old Value' + '#' +'Company Name :' + ISNULL(@Cmp_name,'') 
										+ '#'+ 'Initiate Id :' +CONVERT(nvarchar(10),ISNULL(@InitiateId,0)) 
										+ '#'+ 'Appraiser Id :' +CONVERT(nvarchar(10),ISNULL(@AppraiserId,0))
										+ '#'+ 'Employee :' +ISNULL(@Emp_name,'') 
										+ '#'+ 'End Date :' +CONVERT(nvarchar(40),ISNULL(@OldSA_Enddate,''))
										+ '#'+ 'Submission Date :' +CONVERT(nvarchar(40),ISNULL(@OldSA_SubmissionDate,''))
										+ '#'+ 'Approved By :' +ISNULL(@OldSA_ApprovedBy,'') 		
										+ '#'+ 'Approved Date :' +CONVERT(nvarchar(40),ISNULL(@OldSA_ApprovedDate,''))
										+ '#'+ 'Employee Comments :' +ISNULL(@OldSA_EmpComments,'') 
										+ '#'+ 'Appraiser Comments :' +ISNULL(@OldSA_AppComments,'') 										
										+ '#'+ 'Status :' +CONVERT(nvarchar(10),ISNULL(@OldSA_Status,0)) 
										+ '#'+ 'Overall Status :' +CONVERT(nvarchar(10),ISNULL(@OldOverall_Status,0)) 
			               +'New Value' + '#' +'Company Name :' + ISNULL(@Cmp_name,'') 
									    + '#'+ 'Initiate Id :' +CONVERT(nvarchar(10),ISNULL(@InitiateId,0)) 
										+ '#'+ 'Employee :' +ISNULL(@Emp_name,'') 
										+ '#'+ 'End Date :' +CONVERT(nvarchar(40),ISNULL(@SA_Enddate,''))
										+ '#'+ 'Submission Date :' +CONVERT(nvarchar(40),ISNULL(@SA_SubmissionDate,''))
										+ '#'+ 'Approved By :' +ISNULL(@ApprovedBy,'') 		
										+ '#'+ 'Approved Date :' +CONVERT(nvarchar(40),ISNULL(@SA_ApprovedDate,''))
										+ '#'+ 'Employee Comments :' +ISNULL(@SA_EmpComments,'') 
										+ '#'+ 'Appraiser Comments :' +ISNULL(@SA_AppComments,'') 										
										+ '#'+ 'Status :' +CONVERT(nvarchar(10),ISNULL(@SA_Status,0)) 
										+ '#'+ 'Overall Status :' +CONVERT(nvarchar(10),ISNULL(@Overall_Status,0)) 
			--Added By Mukti(end)08112016
		End	
	Else If  Upper(@tran_type) ='D'
		begin
		--Added By Mukti(start)08112016	
			select @Cmp_name=Cmp_Name from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@Cmp_Id	
					
			select @OldSA_AppComments=SA_AppComments,@OldSA_EmpComments=SA_EmpComments,@OldSA_Enddate=SA_Enddate,
				   @OldSA_Status=SA_Status,@OldSA_SubmissionDate=SA_SubmissionDate,@OldSA_ApprovedDate=SA_ApprovedDate,
				   @OldSA_ApprovedBy=SA_ApprovedBy,@OldOverall_Status=Overall_Status,@Emp_Id=Emp_Id  
			from T0050_HRMS_InitiateAppraisal WITH (NOLOCK) Where  InitiateId = @InitiateId 
			
			select @ApprovedBy=Alpha_Emp_Code +'-'+ Emp_Full_Name from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID=@OldSA_ApprovedBy	
			select @Emp_name=Alpha_Emp_Code +'-'+ Emp_Full_Name from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID=@Emp_Id	
			
			set @OldValue = 'old Value' + '#' +'Company Name :' + ISNULL(@Cmp_name,'') 
										+ '#'+ 'Initiate Id :' +CONVERT(nvarchar(10),ISNULL(@InitiateId,0)) 
										+ '#'+ 'Appraiser Id :' +CONVERT(nvarchar(10),ISNULL(@AppraiserId,0))
										+ '#'+ 'Employee :' +ISNULL(@Emp_name,'') 
										+ '#'+ 'End Date :' +CONVERT(nvarchar(40),ISNULL(@OldSA_Enddate,''))
										+ '#'+ 'Submission Date :' +CONVERT(nvarchar(40),ISNULL(@OldSA_SubmissionDate,''))
										+ '#'+ 'Approved By :' +ISNULL(@OldSA_ApprovedBy,'') 		
										+ '#'+ 'Approved Date :' +CONVERT(nvarchar(40),ISNULL(@OldSA_ApprovedDate,''))
										+ '#'+ 'Employee Comments :' +ISNULL(@OldSA_EmpComments,'') 
										+ '#'+ 'Appraiser Comments :' +ISNULL(@OldSA_AppComments,'') 										
										+ '#'+ 'Status :' +CONVERT(nvarchar(10),ISNULL(@OldSA_Status,0)) 
										+ '#'+ 'Overall Status :' +CONVERT(nvarchar(10),ISNULL(@OldOverall_Status,0)) 
		--Added By Mukti(end)08112016		
									
			----Delete from T0052_Emp_SelfAppraisal where initiateid= @InitiateId
			----Delete from T0052_HRMS_KPA WHERE InitiateId = @InitiateId
			DELETE FROM T0050_HRMS_InitiateAppraisal WHERE InitiateId = @InitiateId
		End
	exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Appraisal Initiation',@OldValue,@InitiateId,@User_Id,@IP_Address	
END


