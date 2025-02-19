
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0090_HRMS_RESUME_EXPERIENCE_aswini]
	 @Row_ID numeric(18,0) output
	,@Cmp_ID  numeric(18,0) 
	,@Resume_ID numeric(18,0)
	,@Employer varchar(100)
	,@Desig_Name Varchar(100)
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
	,@StillContinue	int = 0 --added on 18 Mar 2017
	,@Fresher	int = 0 --added on 18 Mar 2017
	,@CTC numeric(18,2)=0
	,@Manager_Name varchar(50)=''
	,@Manager_Contact_No varchar(15)=''
	,@Reason_For_Leaving varchar(500)=''
	
	--- changes on 21-may-2010 by Falak 
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
	-- Added by rohit on 20-feb-2014 for import
	if @Transtype <> 'D' and @Transtype <> 'U'  --Added By Mukti 13022015  
	begin
			if exists (select resume_id from T0090_HRMS_Resume_Experience WITH (NOLOCK) where Resume_ID=@Resume_ID and Cmp_ID=@cmp_id and Employer_Name=@Employer and Desig_Name=@Desig_Name and St_Date= @St_Date and End_Date = @End_Date  )
				begin
					set @Transtype = 'U'
				end
			else
				begin
					set @Transtype = 'I'
				end
	end
		
	-- ended by rohit on 20-feb-2014 for import
	
	---added on 18 Mar 2017--start
	--if @Fresher = 0
	--	BEGIN
	--		IF EXISTS(select 1 from T0090_HRMS_Resume_Experience where Resume_ID = @Resume_ID and Fresher = 1)
	--			BEGIN
	--				set @Row_ID =0
	--				Return  
	--			END
	--	END
	--ELSE 
	--	BEGIN
	--		IF EXISTS(select 1 from T0090_HRMS_Resume_Experience where Resume_ID = @Resume_ID and Fresher = 0)
	--			BEGIN
	--				set @Row_ID =0
	--				Return  
	--			END
	--		ELSE
	--			BEGIN
	--				IF EXISTS(select 1 from T0090_HRMS_Resume_Experience where Resume_ID = @Resume_ID and Fresher = 1)
	--				BEGIN
	--					SET @Transtype ='U'
	--				END	
	--			END			
	--	END 
	---added on 18 Mar 2017--end	
	
	IF @StillContinue =1
		set @End_Date='1900-01-01'
		
	IF  @Transtype ='I' 
	   Begin 
			
		   -- Comment By Ripal 09Aug2013
	       --if exists (Select Row_ID from T0090_HRMS_Resume_Experience where  Resume_id=@Resume_ID and Employer_Name=@Employer) 
	       --  Begin 
	       --       set @Row_ID =0
	       --       Return    
	       --  End
	       	
	        --Added by Mukti(24012019)if Fresher entry exist then delete 
	        IF EXISTS(SELECT Resume_ID FROM T0090_HRMS_Resume_Experience WITH (NOLOCK) WHERE Resume_ID=@Resume_ID AND Cmp_ID=@Cmp_ID AND ISNULL(Fresher,0)=1) 
				BEGIN				
					DELETE FROM T0090_HRMS_Resume_Experience WHERE Resume_ID=@Resume_ID AND Cmp_ID=@Cmp_ID AND ISNULL(Fresher,0)=1
				END
			select @Row_ID = isnull(max(Row_ID),0) + 1 from T0090_HRMS_Resume_Experience WITH (NOLOCK)
			
			Insert into T0090_HRMS_Resume_Experience
					(Row_ID,Cmp_ID ,Resume_ID ,Employer_Name,Desig_Name ,St_Date ,End_Date,ExpProof,DocumentType,Fromdate,Todate,GrossSalary,ProfessionalTax,Surcharge,EducationCess,TDS,ITax,FYear,StillContinue,Fresher,CTC,Manager_Name,Manager_Contact_No,Reason_For_Leaving)
			values	(@Row_ID,@Cmp_ID ,@Resume_ID ,@Employer,@Desig_Name ,@St_Date ,@End_Date,@ExpProof,@DocumentType,@Fromdate,@Todate,@GrossSalary,@ProfessionalTax,@Surcharge,@EducationCess,@TDS,@ITax,@FYear,@StillContinue,@Fresher,@CTC,@Manager_Name,@Manager_Contact_No,@Reason_For_Leaving)
					
				
	   End
	
	 Else if @Transtype ='U' 
	 
	   Begin
				Update T0090_HRMS_Resume_Experience 				
				set Row_ID  =@Row_ID,Cmp_ID=@Cmp_ID,
				Resume_ID= @Resume_ID , 
				Employer_Name=@Employer,Desig_Name=@Desig_Name
				       ,St_Date=@St_Date , End_Date=@End_Date,ExpProof=@ExpProof,DocumentType=@DocumentType,Fromdate=@Fromdate
				       ,Todate=@Todate,GrossSalary=@GrossSalary,ProfessionalTax=@ProfessionalTax,Surcharge=@Surcharge,EducationCess=@EducationCess
				       ,TDS=@TDS,ITax=@ITax,FYear=@FYear,StillContinue=@StillContinue,Fresher=@Fresher
				       ,CTC=@CTC,Manager_Name=@Manager_Name,Manager_Contact_No=@Manager_Contact_No,Reason_For_Leaving=@Reason_For_Leaving
				where Row_ID=@Row_ID
	   
	   End
	
	Else if @Transtype='D'
	   Begin 
	           Delete from T0090_HRMS_Resume_Experience where Row_ID=@Row_ID
	   End
	
	RETURN







