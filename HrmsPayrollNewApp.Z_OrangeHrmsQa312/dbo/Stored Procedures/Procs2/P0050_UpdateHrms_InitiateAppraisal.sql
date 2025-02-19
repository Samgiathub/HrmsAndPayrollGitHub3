


---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0050_UpdateHrms_InitiateAppraisal]
	 @InitiateId			as numeric(18,0) output
	,@Cmp_ID				as numeric(18,0)
    ,@Emp_Id				as numeric(18,0)
    ,@Overall_Score			as numeric(18,2)	=null
    ,@Achivement_Id			as numeric(18,0)	=null
    ,@AppraiserComment		as varchar(500)		=null
    ,@Promo_YesNo			as int				=null
    ,@Promo_Desig			as numeric(18,0)	=null
    ,@Promo_Wef				as datetime			=null
    ,@JR_YesNo				as int				=null
	,@JR_From				as datetime			=null
	,@JR_To					as datetime			=null
	,@Inc_YesNo				as int				=null
	,@Inc_Reason			as varchar(500)		=null
	,@ReviewerComment		as varchar(500)		=null
	,@Appraiser_Date		as datetime			=null
	,@Per_ApprovedBy		as numeric(18,0)	=null
	,@Overall_Status		as int				=null
	,@GH_Comment			as varchar(500)		=null
	,@HOD_Comment			as varchar(500)		= '' --added on 8 Mar 2016
	,@HOD_ApprovedOn		as datetime			= null	 --added on 8 Mar 2016
	,@HOD_ApprovedBy		as numeric(18,0)	= null  --added on 8 Mar 2016
	,@Promo_Grade			as numeric(18,0)    = null  --added on 14 Dec 2016
	,@User_Id				numeric(18,0) = 0
	,@IP_Address			varchar(30)= ''
	,@DirectHODScore        as int =0 ---added on 15 Dec 2016
	,@Emp_Engagement		int	   = null --added on 14/08/2017
	,@Emp_Engagement_Comment	varchar(100) --added on 14/08/2017
	,@Send_directly_Performance_Assessment int
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
    
--Added By Mukti(start)10112016
declare @OldValue as varchar(max)
Declare @Emp_name as Varchar(250)
Declare @Cmp_name as Varchar(250)
Declare @Promo_Yes_No as Varchar(10)
Declare @JR_Yes_No as Varchar(10)
Declare @Inc_Yes_No as Varchar(10)
Declare @HODApproved_Name as Varchar(250)
Declare @Achivement_Level as Varchar(50)
Declare @Promo_Desig_Name as Varchar(50)
Declare @OldOverall_Score as Varchar(10)
Declare @OldAchivement_Level as Varchar(50)
Declare @OldPromo_Yes_No as Varchar(10)
Declare @OldPromo_Desig_Name as Varchar(250)
Declare @OldPromo_Wef as Varchar(40)
Declare @OldJR_Yes_No as Varchar(10)
Declare @OldJR_From as Varchar(40)
Declare @OldJR_To as Varchar(40)
Declare @OldInc_Yes_No as Varchar(10)
Declare @OldInc_Reason as Varchar(500)
Declare @OldReviewerComment as Varchar(500)
Declare @OldGH_Comment as Varchar(500)
Declare @OldOverall_Status as Varchar(10)
Declare @OldHODApproved_Name as Varchar(250)
Declare @OldHOD_Comment as Varchar(500)
Declare @OldHOD_ApprovedOn as Varchar(40)
Declare @OldHOD_ApprovedBy as Varchar(250)
Declare @AppraiserId as  numeric(18,0)
Declare @OldPromo_YesNo as Varchar(10)
Declare @OldInc_YesNo as Varchar(10)
Declare @OldJR_YesNo as Varchar(10)
--Added By Mukti(end)10112016
if @Promo_Wef=''
	set @Promo_Wef=null
if @JR_From=''
	set @JR_From=null
if @JR_To=''
	set @JR_To=null
if @Appraiser_Date=''
	set @Appraiser_Date=null
if @Overall_Status=0
	set @Overall_Status=null
--added on 8 Mar 2016 start
if @HOD_ApprovedBy =0
	set @HOD_ApprovedBy = null
if @HOD_ApprovedOn=''
	set @HOD_ApprovedOn = null
--added on 8 Mar 2016 end

	if @InitiateId <> 0
		begin
				--Added By Mukti(start)10112016
				select @Cmp_name=Cmp_Name from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@Cmp_Id
						
				select @OldOverall_Score=Overall_Score,@OldHOD_ApprovedBy=HOD_ApprovedBy,@OldOverall_Status=Overall_Status,
				@AppraiserId=AppraiserId,@OldPromo_YesNo=Promo_YesNo,@OldInc_YesNo=Inc_YesNo,@OldJR_YesNo=JR_YesNo
				from T0050_HRMS_InitiateAppraisal WITH (NOLOCK) Where  InitiateId = @InitiateId 
				
				select @OldHODApproved_Name=Alpha_Emp_Code +'-'+ Emp_Full_Name from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID=@OldHOD_ApprovedBy	
				select @OldAchivement_Level=Range_ID from T0040_HRMS_RangeMaster WITH (NOLOCK) where Range_ID=@Achivement_Id	
				select @HODApproved_Name=Alpha_Emp_Code +'-'+ Emp_Full_Name from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID=@HOD_ApprovedBy	
				select @Achivement_Level=Range_ID from T0040_HRMS_RangeMaster WITH (NOLOCK) where Range_ID=@Achivement_Id					
				select @Emp_name=Alpha_Emp_Code +'-'+ Emp_Full_Name from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID=@Emp_Id		
				select @Promo_Desig_Name=Desig_Name from T0040_DESIGNATION_MASTER WITH (NOLOCK) where Desig_ID=@Promo_Desig		
				
				if @Promo_YesNo=1
					set @Promo_Yes_No='Yes'
				else if @Promo_YesNo=0
					set @Promo_Yes_No='No'
					
				if @JR_YesNo=1
					set @JR_Yes_No='Yes'
				else if @Promo_YesNo=0
					set @JR_Yes_No='No'
					
				if @Inc_YesNo=1
					set @Inc_Yes_No='Yes'
				else if @Inc_YesNo=0
					set @Inc_Yes_No='No'	
					
				if @OldPromo_YesNo=1
					set @OldPromo_Yes_No='Yes'
				else if @OldPromo_YesNo=0
					set @OldPromo_Yes_No='No'
					
				if @OldJR_YesNo=1
					set @OldJR_YesNo='Yes'
				else if @OldJR_YesNo=0
					set @OldJR_YesNo='No'
					
				if @OldInc_YesNo=1
					set @OldInc_Yes_No='Yes'
				else if @OldInc_YesNo=0
					set @OldInc_Yes_No='No'
				--Added By Mukti(end)10112016
				
		IF @DirectHODScore =0
			BEGIN		
				IF @Per_ApprovedBy = 0
					BEGIN
						Update	T0050_HRMS_InitiateAppraisal
						set		 Overall_Score		=	@Overall_Score
								,Achivement_Id		=	@Achivement_Id
								,AppraiserComment	=	@AppraiserComment
								,Promo_YesNo		=	@Promo_YesNo
								,Promo_Desig		=	@Promo_Desig
								,Promo_Wef			=	@Promo_Wef
								,JR_YesNo			=	@JR_YesNo
								,JR_From			=	@JR_From
								,JR_To				=	@JR_To
								,Inc_YesNo			=	@Inc_YesNo
								,Inc_Reason			=	@Inc_Reason
								,ReviewerComment	=	@ReviewerComment
								,Overall_Status		=	@Overall_Status
								,GH_Comment			=	@GH_Comment
								,HOD_Comment		=	@HOD_Comment		--added on 8 Mar 2016
								,HOD_ApprovedOn		=	@HOD_ApprovedOn		--added on 8 Mar 2016
								,HOD_ApprovedBy		=	@HOD_ApprovedBy		--added on 8 Mar 2016
								,Promo_Grade		=	@Promo_Grade		--added on 14 Dec 2016
								,Emp_Engagement	= @Emp_Engagement			--added on 14/08/2017
								,Emp_Engagement_Comment = @Emp_Engagement_Comment --added on 14/08/2017														
						where	InitiateId	=	@InitiateId 
					End
				ELSE
					BEGIN
						Update	T0050_HRMS_InitiateAppraisal
						set		 Overall_Score		=	@Overall_Score
								,Achivement_Id		=	@Achivement_Id
								,AppraiserComment	=	@AppraiserComment
								,Promo_YesNo		=	@Promo_YesNo
								,Promo_Desig		=	@Promo_Desig
								,Promo_Wef			=	@Promo_Wef
								,JR_YesNo			=	@JR_YesNo
								,JR_From			=	@JR_From
								,JR_To				=	@JR_To
								,Inc_YesNo			=	@Inc_YesNo
								,Inc_Reason			=	@Inc_Reason
								,ReviewerComment	=	@ReviewerComment
								,Appraiser_Date		=	@Appraiser_Date
								,Per_ApprovedBy		=	@Per_ApprovedBy
								,SA_ApprovedDate	=	@Appraiser_Date
								,SA_ApprovedBy		=	@Per_ApprovedBy
								,Overall_Status		=	@Overall_Status
								,GH_Comment			=	@GH_Comment
								,HOD_Comment		=	@HOD_Comment		--added on 8 Mar 2016
								,HOD_ApprovedOn		=	@HOD_ApprovedOn		--added on 8 Mar 2016
								,HOD_ApprovedBy		=	@HOD_ApprovedBy		--added on 8 Mar 2016
								,Promo_Grade		=	@Promo_Grade		--added on 14 Dec 2016
								,Emp_Engagement	= @Emp_Engagement			--added on 14/08/2017
								,Emp_Engagement_Comment = @Emp_Engagement_Comment --added on 14/08/2017												
						where	InitiateId	=	@InitiateId 
				 End
			END
		ELSE
			BEGIN
				Update	T0050_HRMS_InitiateAppraisal
						set		 Overall_Score		=	@Overall_Score
								,HOD_Score			=	@Overall_Score
								,Achivement_Id		=	@Achivement_Id								
								,Promo_YesNo		=	@Promo_YesNo
								,Promo_Desig		=	@Promo_Desig
								,Promo_Wef			=	@Promo_Wef								
								,Overall_Status		=	@Overall_Status								
								,HOD_ApprovedOn		=	@HOD_ApprovedOn		
								,HOD_ApprovedBy		=	@HOD_ApprovedBy		
								,Promo_Grade		=	@Promo_Grade	
								,Emp_Engagement	= @Emp_Engagement			--added on 14/08/2017
								,Emp_Engagement_Comment = @Emp_Engagement_Comment --added on 14/08/2017												
						where	InitiateId	=	@InitiateId 
			END
			 --Added By Mukti(start)10112016	
			set @OldValue = 'old Value' + '#'+ 'Company Name :' + ISNULL(@Cmp_name,'') 
										+ '#'+ 'Initiate Id :' +CONVERT(nvarchar(10),ISNULL(@InitiateId,0)) 
										+ '#'+ 'Appraiser Id :' +CONVERT(nvarchar(10),ISNULL(@AppraiserId,0))
										+ '#'+ 'Employee :' +ISNULL(@Emp_name,'') 
										+ '#'+ 'Overall Score :' +CONVERT(nvarchar(10),ISNULL(@OldOverall_Score,0)) 
										+ '#'+ 'Achivement :' + ISNULL(@OldAchivement_Level,'') 
										+ '#'+ 'Promotion Yes/No :' +ISNULL(@OldPromo_Yes_No,'') 
										+ '#'+ 'Promotion Designation :' +ISNULL(@OldPromo_Desig_Name,'') 
										+ '#'+ 'Promotion Date :' +CONVERT(nvarchar(40),ISNULL(@OldPromo_Wef,''))
										+ '#'+ 'Job Rotation Yes/No :' +ISNULL(@OldJR_YesNo,'') 
										+ '#'+ 'Job Rotation From Date :' +CONVERT(nvarchar(40),ISNULL(@OldJR_From,''))
										+ '#'+ 'Job Rotation To Date :' +CONVERT(nvarchar(40),ISNULL(@OldJR_To,''))
										+ '#'+ 'Increment Yes/No :' +ISNULL(@OldInc_Yes_No,'') 
										+ '#'+ 'Increment Reason :' +ISNULL(@OldInc_Reason,'') 
										+ '#'+ 'Reviewer Comment  :' +ISNULL(@OldReviewerComment,'')										
										+ '#'+ 'Overall Status :' +CONVERT(nvarchar(10),ISNULL(@OldOverall_Status,0)) 
										+ '#'+ 'Group Head Comment :' +ISNULL(@OldGH_Comment,'')
										+ '#'+ 'HOD Comment :' +ISNULL(@OldHOD_Comment,'')
										+ '#'+ 'HOD Approved On :' +CONVERT(nvarchar(40),ISNULL(@OldHOD_ApprovedOn,''))
										+ '#'+ 'HOD Approved By :' +ISNULL(@OldHOD_ApprovedBy,'')
			               +'New Value' + '#'+ 'Company Name :' + ISNULL(@Cmp_name,'') 
									    + '#'+ 'Initiate Id :' +CONVERT(nvarchar(10),ISNULL(@InitiateId,0)) 
									    + '#'+ 'Appraiser Id :' +CONVERT(nvarchar(10),ISNULL(@AppraiserId,0))
										+ '#'+ 'Employee :' +ISNULL(@Emp_name,'')																				
										+ '#'+ 'Overall Score :' +CONVERT(nvarchar(10),ISNULL(@Overall_Score,0)) 
										+ '#'+ 'Achivement :' + ISNULL(@Achivement_Level,'') 
										+ '#'+ 'Promotion Yes/No :' +ISNULL(@Promo_Yes_No,'') 
										+ '#'+ 'Promotion Designation :' +ISNULL(@Promo_Desig_Name,'') 
										+ '#'+ 'Promotion Date :' +CONVERT(nvarchar(40),ISNULL(@Promo_Wef,''))
										+ '#'+ 'Job Rotation Yes/No :' +ISNULL(@JR_Yes_No,'') 
										+ '#'+ 'Job Rotation From Date :' +CONVERT(nvarchar(40),ISNULL(@JR_From,''))
										+ '#'+ 'Job Rotation To Date :' +CONVERT(nvarchar(40),ISNULL(@JR_To,''))
										+ '#'+ 'Increment Yes/No :' +ISNULL(@Inc_Yes_No,'') 
										+ '#'+ 'Increment Reason :' +ISNULL(@Inc_Reason,'') 
										+ '#'+ 'Reviewer Comment  :' +ISNULL(@ReviewerComment,'')										
										+ '#'+ 'Overall Status :' +CONVERT(nvarchar(10),ISNULL(@Overall_Status,0)) 
										+ '#'+ 'Group Head Comment :' +ISNULL(@GH_Comment,'')
										+ '#'+ 'HOD Comment :' +ISNULL(@HOD_Comment,'')
										+ '#'+ 'HOD Approved On :' +CONVERT(nvarchar(40),ISNULL(@HOD_ApprovedOn,''))
										+ '#'+ 'HOD Approved By :' +ISNULL(@HODApproved_Name,'')
			--Added By Mukti(end)10112016	
			exec P9999_Audit_Trail @Cmp_ID,'U','Appraisal Initiation',@OldValue,@InitiateId,@User_Id,@IP_Address	
		End
	else
		begin
			--Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,0,'enter initiation id ',0, 'initiation id not send',GetDate(),'Appraisal')						
			Return
		End	
END


