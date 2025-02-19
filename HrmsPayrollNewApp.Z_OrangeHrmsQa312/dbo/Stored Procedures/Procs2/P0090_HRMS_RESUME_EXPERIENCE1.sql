



---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0090_HRMS_RESUME_EXPERIENCE1]
	 @Row_ID numeric(18,0) output
	,@Cmp_ID  numeric(18,0) 
	,@Resume_ID numeric(18,0)
	,@Employer varchar(50)
	,@Desig_Name Varchar(50)
	,@St_Date DateTime
 	,@End_Date DateTime
 	,@ExpProof varchar(max)
 	,@DocumentType varchar(100)
 	,@Transtype char(1)
 	,@Fromdate datetime   -- added on 30 july 2013
 	,@Todate datetime    -- added on 30 july 2013
 	,@GrossSalary numeric(18,0)    -- added on 30 july 2013
 	,@ProfessionalTax numeric(18,0)  -- added on 30 july 2013
 	,@Surcharge numeric(18,0) -- added on 30 july 2013
 	,@EducationCess numeric(18,0) -- added on 30 july 2013
 	,@TDS numeric(18,0) -- added on 30 july 2013
	,@ITax numeric(18,0) = null-- added on 22 jan 2014
	,@FYear varchar(50)=null --added on 22 Jan 2014
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	if 	@St_Date =''
	  set @St_Date =null
	  
	if  @End_Date =''
	  set @End_Date =null
	  
	-- added on 30 july 2013-=================
	if @Fromdate =''
		set @Fromdate=null
	if @Todate = ''
		set @Todate = null
		
--=======================================

	
	if  @Transtype ='I' 
	   Begin 
	   
	       if exists (Select Row_ID from T0090_HRMS_Resume_Experience1 WITH (NOLOCK) where  Resume_id=@Resume_ID and Employer=@Employer) 
	         Begin 
	              set @Row_ID =0
	              Return    
	         End
	         
			select @Row_ID = isnull(max(Row_ID),0) + 1 from T0090_HRMS_Resume_Experience1 WITH (NOLOCK)
			
			Insert into T0090_HRMS_Resume_Experience1
							(Row_ID,Cmp_ID ,Resume_ID ,Employer_Name,Desig_Name ,St_Date ,End_Date,ExpProof,DocumentType,Fromdate,Todate,GrossSalary,ProfessionalTax,Surcharge,EducationCess,TDS,ITax,FYear)
					values	(@Row_ID,@Cmp_ID ,@Resume_ID ,@Employer,@Desig_Name ,@St_Date ,@End_Date,@ExpProof,@DocumentType,@Fromdate,@Todate,@GrossSalary,@ProfessionalTax,@Surcharge,@EducationCess,@TDS,@ITax,@FYear)
					
				
	   End
	
	 Else if @Transtype ='U' 
	 
	   Begin
				Update T0090_HRMS_Resume_Experience1 
				
				   set Row_ID  =@Row_ID,Cmp_ID=@Cmp_ID,Resume_ID= @Resume_ID,Employer_Name=@Employer,Desig_Name=@Desig_Name
				       ,St_Date=@St_Date , End_Date=@End_Date,ExpProof=@ExpProof,DocumentType=@DocumentType,Fromdate=@Fromdate
				       ,Todate=@Todate,GrossSalary=@GrossSalary,ProfessionalTax=@ProfessionalTax,Surcharge=@Surcharge,EducationCess=@EducationCess
				       ,TDS=@TDS,ITax=@ITax,FYear=@FYear
					where Row_ID=@Row_ID
	   
	   End
	
	Else if @Transtype='D'
	   Begin 
	   
	              Delete from T0090_HRMS_Resume_Experience where Row_ID=@Row_ID
	   
	   End
	
	RETURN




