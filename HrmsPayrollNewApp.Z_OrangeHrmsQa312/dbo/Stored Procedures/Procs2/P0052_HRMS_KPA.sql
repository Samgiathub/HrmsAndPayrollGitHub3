
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0052_HRMS_KPA]
	 @KPA_ID		 numeric(18) output  
	,@Cmp_ID			numeric(18)   
	,@InitiateId		numeric(18)		=null 
	,@Emp_Id			numeric(18)		=null
	,@KPA_Content		nvarchar(1000)	=null --changed By Deepali -04-Apr-22- for unicode 
	,@KPA_Achievement	numeric(18,2)	=null
	,@KPA_Critical		nvarchar(1000)	=null  --changed By Deepali -04-Apr-22- for unicode 
	,@KPA_Score			numeric(18,2)	=null
	,@KPA_Final			numeric(18,2)	=null
	,@tran_type			varchar(1) 
	,@KPA_Target		nvarchar(1000)	= null --added by sneha 5 Feb 2015  --changed By Deepali -04-Apr-22- for unicode 
	,@KPA_Weightage		numeric(18,2)	= null --added by sneha 5 Feb 2015
	,@KPA_AchievementEmp  numeric(18,2)	= null --added by sneha 7 oct 2015
	,@KPA_AchievementRM   numeric(18,2)	= null --added by sneha 7 oct 2015
	,@User_Id			numeric(18,0)	= 0
	,@IP_Address		varchar(30)		= '' 
	,@RM_comments nvarchar(max)			= ''  --changed By Deepali -04-Apr-22- for unicode 
	,@RM_Weightage numeric(18,2)		= 0
	,@RM_Rating numeric(18,2)			= 0
	,@HOD_Weightage numeric(18,2)		= 0
	,@HOD_Rating numeric(18,2)			= 0
	,@KPA_AchievementHOD numeric(18,2)	= 0
	,@HOD_comments nvarchar(max)			= '' --changed By Deepali -04-Apr-22- for unicode 
	,@GH_Weightage numeric(18,2)		= 0
	,@GH_Rating numeric(18,2)			= 0
	,@KPA_AchievementGH numeric(18,2)	= 0
	,@GH_comments nVarchar(max)			= ''   --changed By Deepali -04-Apr-22- for unicode 
	,@KPA_Type_ID numeric(18,0)			= null
	,@Actual_Achievement nvarchar(1000)	= ''
	,@KPA_Performace_Measure nvarchar(500)	= ''   --changed By Deepali -04-Apr-22- for unicode 
	,@Achievement_Percentage_Emp numeric(18,2)	= 0
	,@Achievement_Percentage_RM numeric(18,2)	= 0
	,@Achievement_Percentage_HOD numeric(18,2)	= 0
	,@Achievement_Percentage_GH numeric(18,2)	= 0
	,@Completion_Date datetime 
	,@Attach_Docs varchar(1000)
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

    
declare @OldValue as nvarchar(max)  --changed By Deepali -04-Apr-22- for unicode 
declare @OldKPA_Content as nvarchar(1000) --changed By Deepali -04-Apr-22- for unicode 
declare @OldKPA_Critical as nvarchar(1000)  --changed By Deepali -04-Apr-22- for unicode 
declare @OldKPA_Achievement as varchar(10) 
declare @OldKPA_Target as nvarchar(1000) --changed By Deepali -04-Apr-22- for unicode 
declare @OldKPA_Weightage as varchar(10)
declare @OldKPA_AchievementEmp as varchar(10)
declare @OldKPA_AchievementRM as varchar(10)
Declare @Emp_name as Varchar(250)
Declare @Cmp_name as Varchar(250)
declare @OldKPA_Manager_comments as nvarchar(max) --changed By Deepali -04-Apr-22- for unicode 

set @OldValue = ''

if @KPA_Achievement		= 0
	set	@KPA_Achievement=null
if @KPA_Critical		= ''
	set	@KPA_Critical	=null
if @KPA_Score			= 0
	set	@KPA_Score		=null
if @KPA_Final			= 0
	set	@KPA_Final		=null
if @KPA_AchievementEmp	= 0
	set	@KPA_AchievementEmp =null	 --added by sneha 7 oct 2015
if @KPA_AchievementRM	= 0
	set	@KPA_AchievementRM =null	--added by sneha 7 oct 2015
	
 --added by sneha 5 Feb 2015
if @KPA_Target = ''
	set @KPA_Target = null
if @KPA_Weightage = 0 
	set @KPA_Weightage = null
	
if @RM_Weightage	= 0
	set	@RM_Weightage=null
if @HOD_Weightage		= 0
	set	@HOD_Weightage=null
if @GH_Weightage		= 0
	set	@GH_Weightage=null
if @KPA_Type_ID =0 
	set @KPA_Type_ID=NULL

	declare @SendToHOD as int
	declare @SendToRM as int

	select @SendToHOD=isnull(SendToHOD,0),@SendToRM=ISNULL(Rm_Required,0)
	from T0050_HRMS_InitiateAppraisal WITH (NOLOCK) where cmp_id=@cmp_id and emp_id =@emp_id and InitiateId=@InitiateId
		
		If Upper(@tran_type) ='I' Or Upper(@tran_type) ='U'
		Begin
			If @KPA_Content = ''
				BEGIN
					update 	T0050_HRMS_InitiateAppraisal set
							kpa_Score = @KPA_Score,
							kpa_Final = @KPA_Final
					Where InitiateId = @InitiateId and Cmp_ID=@Cmp_ID	
					--Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,0,'Answer is not Properly Inserted',0,'Enter Answer',GetDate(),'Appraisal')										
					Return
				END
		End
	If Upper(@tran_type) ='I'
		Begin
			select @KPA_ID = isnull(max(KPA_ID),0) + 1 from T0052_HRMS_KPA WITH (NOLOCK)
			Insert into T0052_HRMS_KPA
			(
				 KPA_ID
				,Cmp_ID
				,InitiateId
				,Emp_Id
				,KPA_Content
				,KPA_Achievement
				,KPA_Critical
				,KPA_Target			--added by sneha 5 Feb 2015
				,KPA_Weightage		--added by sneha 5 Feb 2015
				,KPA_AchievementEmp   --added by sneha 7 oct 2015
				,KPA_AchievementRM	--added by sneha 7 oct 2015
				,RM_Comments  --Mukti(06122016)
				,RM_Weightage
				,RM_Rating
				,HOD_Weightage
				,HOD_Rating
				,KPA_AchievementHOD
				,HOD_Comments
				,GH_Weightage
				,GH_Rating
				,KPA_AchievementGH
				,GH_Comments
				,KPA_Type_ID
				,Actual_Achievement
				,KPA_Performace_Measure
				,Achievement_Percentage_Emp
				,Achievement_Percentage_RM
				,Achievement_Percentage_HOD 
				,Achievement_Percentage_GH
				,Completion_Date
				,Attach_Docs
			)
			values
			(
				 @KPA_ID
				,@Cmp_ID
				,@InitiateId
				,@Emp_Id
				,@KPA_Content
				,@KPA_Achievement
				,@KPA_Critical
				,@KPA_Target		--added by sneha 5 Feb 2015
				,@KPA_Weightage		--added by sneha 5 Feb 2015
				,@KPA_AchievementEmp   --added by sneha 7 oct 2015
				,@KPA_AchievementRM	--added by sneha 7 oct 2015
				,@RM_comments   --Mukti(06122016)
				,@RM_Weightage
				,@RM_Rating
				,@HOD_Weightage
				,@HOD_Rating
				,@KPA_AchievementHOD
				,@HOD_Comments
				,@GH_Weightage
				,@GH_Rating
				,@KPA_AchievementGH
				,@GH_Comments				
				,@KPA_Type_ID
				,@Actual_Achievement
				,@KPA_Performace_Measure
				,@Achievement_Percentage_Emp
				,@Achievement_Percentage_RM
				,@Achievement_Percentage_HOD 
				,@Achievement_Percentage_GH	
				,@Completion_Date
				,@Attach_Docs		
			)
			
			--Added By Mukti(start)08112016
			select @Cmp_name=Cmp_Name from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@Cmp_Id
			select @Emp_name=Alpha_Emp_Code +'-'+ Emp_Full_Name from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID=@Emp_Id
				
			set @OldValue = 'New Value' + '#' +'Company Name :' + ISNULL(@Cmp_name,'') 
									    + '#'+ 'Initiate Id :' +CONVERT(nvarchar(10),ISNULL(@InitiateId,0)) 
										+ '#'+ 'Employee :' +ISNULL(@Emp_name,'') 
										+ '#'+ 'KPA Content :' +ISNULL(@KPA_Content,'') 
										+ '#'+ 'KPA Achievement :' + CONVERT(nvarchar(10),ISNULL(@KPA_Achievement,0)) 
										+ '#'+ 'KPA Critical :' +ISNULL(@KPA_Critical,'') 
										+ '#'+ 'KPA Target :' +ISNULL(@KPA_Target,'') 
										+ '#'+ 'KPA Weightage :' + CONVERT(nvarchar(10),ISNULL(@KPA_Weightage,0)) 
										+ '#'+ 'KPA Achievement Employee :' + CONVERT(nvarchar(10),ISNULL(@KPA_AchievementEmp,0)) 
										+ '#'+ 'KPA Achievement RM :' + CONVERT(nvarchar(10),ISNULL(@KPA_AchievementRM,0)) 
										+ '#'+ 'Reporting Manager Comments :' +ISNULL(@RM_comments,'') 
			--Added By Mukti(end)08112016
		End
	Else If  Upper(@tran_type) ='U' 	
		Begin
			--Added By Mukti(start)08112016
			select @Cmp_name=Cmp_Name from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@Cmp_Id
			select @Emp_name=Alpha_Emp_Code +'-'+ Emp_Full_Name from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID=@Emp_Id
			
			select @OldKPA_Content=KPA_Content,@OldKPA_Critical=KPA_Critical,@OldKPA_Achievement=KPA_Achievement,
				   @OldKPA_Target=KPA_Target,@OldKPA_Weightage=KPA_Weightage,@OldKPA_AchievementEmp=KPA_AchievementEmp,
				   @OldKPA_AchievementRM=KPA_AchievementRM,@OldKPA_Manager_comments=RM_Comments
			from T0052_HRMS_KPA WITH (NOLOCK) where KPA_ID = @KPA_ID and InitiateId = @InitiateId			 
			--Added By Mukti(end)08112016
			
			  Update T0052_HRMS_KPA
			  Set    KPA_Content		=	@KPA_Content
					,KPA_Critical		=	@KPA_Critical
					,KPA_Achievement	=	@KPA_Achievement
					,KPA_Target			=	@KPA_Target			--added by sneha 5 Feb 2015
					,KPA_Weightage		=	@KPA_Weightage		--added by sneha 5 Feb 2015
					,KPA_AchievementEmp	=	@KPA_AchievementEmp   --added by sneha 7 oct 2015
					,KPA_AchievementRM	=	@KPA_AchievementRM	--added by sneha 7 oct 2015
					,RM_Comments        =   @RM_Comments --added by Mukti(06122016)
					,RM_Weightage		=	@RM_Weightage
					,RM_Rating			=	@RM_Rating
					,HOD_Weightage      =   @HOD_Weightage
					,HOD_Rating         =   @HOD_Rating
					,KPA_AchievementHOD =   @KPA_AchievementHOD
					,HOD_Comments       =   @HOD_Comments
					,GH_Weightage       =   @GH_Weightage
					,GH_Rating          =   @GH_Rating
					,KPA_AchievementGH  =   @KPA_AchievementGH
					,GH_Comments        =   @GH_Comments			
					,KPA_Type_ID		=   @KPA_Type_ID
					,Actual_Achievement =   @Actual_Achievement
					,KPA_Performace_Measure = @KPA_Performace_Measure					
					,Achievement_Percentage_Emp=@Achievement_Percentage_Emp
					,Achievement_Percentage_RM=@Achievement_Percentage_RM
					,Achievement_Percentage_HOD =@Achievement_Percentage_HOD
					,Achievement_Percentage_GH=@Achievement_Percentage_GH
					,Completion_Date=@Completion_Date
					,Attach_Docs=@Attach_Docs
			  Where  KPA_ID = @KPA_ID and InitiateId = @InitiateId
			  
			--Added By Mukti(start)08112016
			set @OldValue = 'old Value' + '#' +'Company Name :' + ISNULL(@Cmp_name,'') 
										+ '#'+ 'Initiate Id :' +CONVERT(nvarchar(10),ISNULL(@InitiateId,0)) 
										+ '#'+ 'Employee :' +ISNULL(@Emp_name,'') 
										+ '#'+ 'KPA Content :' +ISNULL(@OldKPA_Content,'') 
										+ '#'+ 'KPA Achievement :' +CONVERT(nvarchar(10),ISNULL(@OldKPA_Achievement,0)) 
										+ '#'+ 'KPA Critical :' +ISNULL(@OldKPA_Critical,'') 
										+ '#'+ 'KPA Target :' +ISNULL(@OldKPA_Target,'') 
										+ '#'+ 'KPA Weightage :' +CONVERT(nvarchar(10),ISNULL(@OldKPA_Weightage,0)) 
										+ '#'+ 'KPA Achievement Employee :' +CONVERT(nvarchar(10),ISNULL(@OldKPA_AchievementEmp,0)) 
										+ '#'+ 'KPA Achievement RM :' +CONVERT(nvarchar(10),ISNULL(@OldKPA_AchievementRM,0))
										+ '#'+ 'Reporting Manager Comments :' +ISNULL(@OldKPA_Manager_comments,'') 
					 + '#' +'New Value' + '#' +'Company Name :' + ISNULL(@Cmp_name,'') 
										+ '#'+ 'Initiate Id :' +CONVERT(nvarchar(10),ISNULL(@InitiateId,0))  
										+ '#'+ 'Employee :' +ISNULL(@Emp_name,'') 
										+ '#'+ 'KPA Content :' +ISNULL(@KPA_Content,'') 
										+ '#'+ 'KPA Achievement :' + CONVERT(nvarchar(10),ISNULL(@KPA_Achievement,0)) 
										+ '#'+ 'KPA Critical :' +ISNULL(@KPA_Critical,'') 
										+ '#'+ 'KPA Target :' +ISNULL(@KPA_Target,'') 
										+ '#'+ 'KPA Weightage :' + CONVERT(nvarchar(10),ISNULL(@KPA_Weightage,0)) 
										+ '#'+ 'KPA Achievement Employee :' + CONVERT(nvarchar(10),ISNULL(@KPA_AchievementEmp,0)) 
										+ '#'+ 'KPA Achievement RM :' + CONVERT(nvarchar(10),ISNULL(@KPA_AchievementRM,0))
										+ '#'+ 'Reporting Manager Comments :' +ISNULL(@RM_comments,'')  					 
			--Added By Mukti(end)08112016
		End
	Else If  Upper(@tran_type) ='D'
		Begin
		--Added By Mukti(start)08112016
			select @Cmp_name=Cmp_Name from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@Cmp_Id
			select @Emp_name=Alpha_Emp_Code +'-'+ Emp_Full_Name from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID=@Emp_Id
			
			select @OldKPA_Content=KPA_Content,@OldKPA_Critical=KPA_Critical,@OldKPA_Achievement=KPA_Achievement,
				   @OldKPA_Target=KPA_Target,@OldKPA_Weightage=KPA_Weightage,@OldKPA_AchievementEmp=KPA_AchievementEmp,
				   @OldKPA_AchievementRM=KPA_AchievementRM,@OldKPA_Manager_comments=RM_Comments
			from T0052_HRMS_KPA WITH (NOLOCK) where KPA_ID = @KPA_ID and InitiateId = @InitiateId
		--Added By Mukti(end)08112016	
		
			DELETE FROM T0052_HRMS_KPA WHERE KPA_ID = @KPA_ID
			
			--Added By Mukti(start)08112016
			set @OldValue = 'old Value' + '#' +'Company Name :' + ISNULL(@Cmp_name,'') 
										+ '#'+ 'Initiate Id :' +CONVERT(nvarchar(10),ISNULL(@InitiateId,0)) 
										+ '#'+ 'Employee :' +ISNULL(@Emp_name,'') 
										+ '#'+ 'KPA Content :' +ISNULL(@OldKPA_Content,'') 
										+ '#'+ 'KPA Achievement :' +CONVERT(nvarchar(10),ISNULL(@OldKPA_Achievement,0)) 
										+ '#'+ 'KPA Critical :' +ISNULL(@OldKPA_Critical,'') 
										+ '#'+ 'KPA Target :' +ISNULL(@OldKPA_Target,'') 
										+ '#'+ 'KPA Weightage :' +CONVERT(nvarchar(10),ISNULL(@OldKPA_Weightage,0)) 
										+ '#'+ 'KPA Achievement Employee :' +CONVERT(nvarchar(10),ISNULL(@OldKPA_AchievementEmp,0)) 
										+ '#'+ 'KPA Achievement RM :' +CONVERT(nvarchar(10),ISNULL(@OldKPA_AchievementRM,0))
										+ '#'+ 'Reporting Manager Comments :' +ISNULL(@OldKPA_Manager_comments,'') 
			--Added By Mukti(end)08112016
		End	
	
	update 	T0050_HRMS_InitiateAppraisal set
			kpa_Score = @KPA_Score,
			kpa_Final = @KPA_Final
	Where InitiateId = @InitiateId and Cmp_ID=@Cmp_ID
	
	if @SendToHOD =0
		begin
			update 	T0052_HRMS_KPA set
				HOD_Rating=null,
				HOD_Weightage=null,
				KPA_AchievementHOD=null
			Where InitiateId = @InitiateId and Cmp_ID=@Cmp_ID and Emp_Id=@Emp_Id
		end	

	if @SendToRM =0
		begin
			update 	T0052_HRMS_KPA set
				RM_Rating=null,
				RM_Weightage=null,
				KPA_AchievementRM=null,
				Achievement_Percentage_RM=null
			Where InitiateId = @InitiateId and Cmp_ID=@Cmp_ID and Emp_Id=@Emp_Id
		end	
		
	exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Employee KPA',@OldValue,@KPA_ID,@User_Id,@IP_Address	
END
