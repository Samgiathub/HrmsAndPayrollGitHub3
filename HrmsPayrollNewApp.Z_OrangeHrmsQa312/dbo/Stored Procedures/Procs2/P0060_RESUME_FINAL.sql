
---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0060_RESUME_FINAL]  
 @Tran_ID			numeric(18, 0)	output
,@Resume_ID			numeric(18, 0)	
,@Resume_Status		int	
,@Cmp_ID			numeric(18, 0)	
,@Rec_post_Id		numeric(18, 0)	
,@Comments			varchar(500)	
,@Branch_id			numeric(18, 0)	
,@Grd_id			numeric(18, 0)	
,@Desig_id			numeric(18, 0)	
,@Dept_id			numeric(18, 0)	
,@Acceptance		int	
,@Acceptance_Date	datetime	
,@Medical_inspection	int	
,@Police_Incpection	int	
,@Ref_1				varchar(500)	
,@Ref_2				varchar(500)	
,@Joining_date		datetime	
,@Basic_Salay		numeric(18, 2)	
,@Login_id			numeric(18, 0)	
,@Joining_status	numeric(18, 0)	
,@Total_CTC			numeric(18,2)
,@ReportingManager_Id numeric(18,2)
,@BusinessHead      numeric(18,2)
,@Level2_Approval   int
,@SalaryCycle_Id    numeric(18,0)
,@ShiftId           numeric(18,0)
,@EmploymentTypeId  numeric(18,0)
,@BusinessSegment_Id numeric(18,0) --on 27th july 2013
,@Vertical_Id        numeric(18,0) --on 27th july 2013
,@SubVertical_Id     numeric(18,0) --on 27th july 2013
,@Assigned_Cmpid     numeric(18,0) -- on 1st oct 2013
,@Latter_Format numeric(3,0) = 0
,@LatterFile_Name varchar(Max) = ''
,@Salary_File_Name Nvarchar(Max)=''
,@Trans_Type		char(1)
,@Notice_Period  numeric(18,0) = 0 --Added by Ramiz on 13102014
,@R_Cmp_Id numeric(18,0) = 0 --Added by Mukti on 11042015
,@Appoint_Latter_Format numeric(18,0) = 0 --Mukti 18052015
,@Appoint_LatterFile_Name varchar(Max) = '' --Mukti 18052015
,@Background_Verification Int = 0 --Mukti 22012016
,@offer_Date varchar(100)=''
,@Gross_Salary	numeric(18,2) = 0 --added on 14/09/2017 sneha
,@IFSC_Code varchar(25) = '' --Mukti(28102017)
,@Category_ID int =0
AS
 
	SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON
 
  if @Branch_id=0
	set @Branch_id=null				
  if @Grd_id=0
	set @Grd_id=null					
  if @Desig_id=0	
	set @Desig_id=null				
  if @Dept_id=0		
	set @Dept_id=null		
  if @Login_id=0			
    set @Login_id=null
  if @Joining_date=''
	set @Joining_date=null
  if @Acceptance_Date=''
	set @Acceptance_Date=null
  if @BusinessSegment_Id = 0
	set @BusinessSegment_Id = null
  if @Vertical_Id = 0
    set @Vertical_Id = null
  if @SubVertical_Id = 0
	set @SubVertical_Id = null	
if @Assigned_Cmpid = 0
	set @Assigned_Cmpid = null
if @Category_ID=0
		set @Category_ID=null
	

  declare @for_date as datetime
  
  set @for_date=cast(getdate() as varchar(11))
  
  if isnull(@offer_Date,'') = ''	
   set @offer_Date	= Null
  
  
   If @Trans_Type ='I'   
   begin  
  
     If Exists(Select Tran_ID From T0060_RESUME_FINAL WITH (NOLOCK) Where Resume_ID=@Resume_ID and Rec_post_Id=@Rec_post_Id and cmp_id = @cmp_id)
      Begin  
		 set @Tran_ID=0
		 Return        
      End   
     select @Tran_ID = isnull(max(Tran_ID),0) + 1  From T0060_RESUME_FINAL WITH (NOLOCK) 
       
						INSERT INTO T0060_RESUME_FINAL  
                           (Tran_ID
							,Resume_ID
							,Resume_Status
							,Cmp_ID
							,Rec_post_Id
							,Approval_Date
							,Comments
							,Branch_id
							,Grd_id
							,Desig_id
							,Dept_id
							,Acceptance
							,Acceptance_Date
							,Medical_inspection
							,Police_Incpection
							,Ref_1
							,Ref_2
							,Joining_date
							,Basic_Salay
							,Login_id
							,Joining_status 
							,Total_CTC
							,ReportingManager_Id
							,BusinessHead			--3Aug2013 
							,Level2_Approval		--3Aug2013 
							,SalaryCycle_Id			--3Aug2013 
							,ShiftId				--3Aug2013 
							,EmploymentTypeId		--3Aug2013 
							,BusinessSegment_Id		--3Aug2013 
							,Vertical_Id			--3Aug2013 
							,SubVertical_Id			--3Aug2013
							,Assigned_Cmpid			--1Oct2013	 
							,Latter_Format
							,LatterFile_Name
							,Salary_File_name
							,Notice_Period
							,R_Cmp_Id
							,Appointment_Letter_Format  --Mukti 18052015
							,Appointment_Letter_File  --Mukti 18052015
							,Background_Verification  --Mukti 22012016
							,offer_date
							,Gross_Salary  
							,IFSC_Code
							,Category_ID
							)		  
                           
						VALUES     
						(	@Tran_ID
							,@Resume_ID
							,@Resume_Status
							,@Cmp_ID
							,@Rec_post_Id
							,@for_date
							,@Comments
							,@Branch_id
							,@Grd_id
							,@Desig_id
							,@Dept_id
							,@Acceptance
							,@Acceptance_Date
							,@Medical_inspection
							,@Police_Incpection
							,@Ref_1
							,@Ref_2
							,@Joining_date
							,@Basic_Salay
							,@Login_id
							,@Joining_status 
							,@Total_CTC
							,@ReportingManager_Id
							,@BusinessHead			--3Aug2013 
							,@Level2_Approval		--3Aug2013 
							,@SalaryCycle_Id			--3Aug2013 
							,@ShiftId				--3Aug2013 
							,@EmploymentTypeId		--3Aug2013 
							,@BusinessSegment_Id		--3Aug2013 
							,@Vertical_Id			--3Aug2013 
							,@SubVertical_Id		--3Aug2013
							,@Assigned_Cmpid		--1Oct2013	 		 
							,@Latter_Format
							,@LatterFile_Name
							,@Salary_File_Name
							,@Notice_Period
							,@R_Cmp_Id
							,@Appoint_Latter_Format  --Mukti 18052015
							,@Appoint_LatterFile_Name  --Mukti 18052015
							,@Background_Verification  --Mukti 22012016
							,@offer_Date
							,@Gross_Salary       --added on 14092017
							,@IFSC_Code --Mukti(28102017)
							,@Category_ID
							)		
							
    update T0055_Resume_Master set Resume_Status=@Resume_Status where Resume_Id=@Resume_ID and Cmp_id=@Cmp_ID --added By Mukti 25072015
    end   
   else If @Trans_Type ='U'   
   begin  
		select @Joining_status=Joining_status from  T0060_RESUME_FINAL WITH (NOLOCK) where Tran_ID=@Tran_ID
		if (@Joining_status<>1)
			begin
				update T0060_RESUME_FINAL
				set			Resume_Status=@Resume_Status
							,Approval_Date=@for_date
							,Comments=@Comments
							,Branch_id=@Branch_id
							,Grd_id=@Grd_id
							,Desig_id=@Desig_id
							,Dept_id=@Dept_id
							,Acceptance=@Acceptance
							,Acceptance_Date=@Acceptance_Date
							,Medical_inspection=@Medical_inspection
							,Police_Incpection=@Police_Incpection
							,Ref_1=@Ref_1
							,Ref_2=@Ref_2
							,Joining_date=@Joining_date
							,Basic_Salay=@Basic_Salay
							,Login_id=@Login_id
							,Joining_status=@Joining_status
							,Total_CTC=@Total_CTC
							,ReportingManager_Id=@ReportingManager_Id
							,BusinessHead = @BusinessHead
							,Level2_Approval = @Level2_Approval
							,SalaryCycle_Id = @SalaryCycle_Id
							,ShiftId = @ShiftId
							,EmploymentTypeId = @EmploymentTypeId
							,BusinessSegment_Id = @BusinessSegment_Id
							,Vertical_Id = @Vertical_Id
							,SubVertical_Id = @SubVertical_Id
							,Assigned_Cmpid = @Assigned_Cmpid   -- 1Oct 2013
							,Latter_Format = @Latter_Format
							,Latterfile_Name = @LatterFile_Name
							,Salary_File_name=@Salary_File_Name
							,Notice_Period = @Notice_Period
							,R_Cmp_Id=@R_Cmp_Id
							,Appointment_Letter_Format=@Appoint_Latter_Format  --Mukti 18052015
							,Appointment_Letter_File=@Appoint_LatterFile_Name  --Mukti 18052015
							,Background_Verification=@Background_Verification  --Mukti 22012016
							,Offer_date = @offer_Date 
							,Gross_Salary = @Gross_Salary  --14/09/2017
							,IFSC_Code = @IFSC_Code --Mukti(28102017)
							,Category_ID=@Category_ID
						where Tran_ID=@Tran_ID
						
			    update T0055_Resume_Master set Resume_Status=@Resume_Status where Resume_Id=@Resume_ID and Cmp_id=@Cmp_ID --added By Mukti 25072015						
				
			end
		else
			set @Tran_ID=-1
    end
    else If @Trans_Type ='D'   
   begin  
		delete T0060_RESUME_FINAL where Tran_ID=@Tran_ID 
		
    end
 RETURN  
  
  











