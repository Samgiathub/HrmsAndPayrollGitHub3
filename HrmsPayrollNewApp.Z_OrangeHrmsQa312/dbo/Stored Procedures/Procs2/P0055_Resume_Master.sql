
---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0055_Resume_Master]

 @Resume_Id					numeric(18) output
,@cmp_id					numeric(18,0)
,@Rec_Post_Id			    numeric(18,0)
,@Initial					varchar(50)
,@Emp_First_Name			varchar(50)
,@Emp_Second_Name			varchar(50)
,@Emp_Last_Name				varchar(50)
,@Date_Of_Birth				datetime  =null
,@Marital_Status			varchar(20)
,@Marriage_Date            datetime  ----Add by Manisha
,@Gender					char(1)
,@Present_Street			nvarchar(250)
,@Present_City				varchar(50)
,@Present_State             varchar(50)
,@Present_Post_Box          varchar(50)
,@Present_Loc				numeric(18,0)
,@Permanent_Street			varchar(250)
,@Permanent_City            varchar(50)
,@Permanent_State			varchar(50)
,@Permanentt_Post_Box		varchar(50)
,@Permanent_Loc_ID			numeric(18,0)
,@Home_Tel_no				varchar(30)
,@Mobile_No					varchar(30)
,@Primary_email				varchar(100)
,@Other_Email				varchar(100)
,@Non_Technical_Skill	    varchar(500)
,@Cur_CTC					numeric(18,2)
,@Exp_CTC					numeric(18,2)
,@Total_exp			        numeric(18,2)
,@Resume_Name				varchar(50)
,@File_Name                 varchar(100)
,@Resume_Status				tinyint
,@Final_CTC					numeric(18,2)
,@Date_Of_Join				datetime
,@Basic_Salary				numeric(18,2)
,@Emp_Full_PF				numeric(18,2)
,@Emp_Fix_Salary			numeric(18,2)
,@Source_Type_id			Numeric(18,0)=0
,@Source_id					Numeric(18,0)=0
,@FatherName				varchar(max)=''
,@PAN						Nvarchar(Max)=''
,@Resume_ScreeningStatus	Numeric(18,0)=null --added by sneha on 19 dec 2014
,@Resume_ScreeningBy		numeric(18,0)=null --added by sneha on 19 dec 2014
,@PAN_Ack						Nvarchar(Max)=''
,@Source_Name				varchar(100)=''
,@tran_type				    char(1)
,@aadhar_Card				varchar(50) =''
,@aadhar_Path				varchar(100) ='' --Added by Sumit on 06022017
,@StateDomicile				Numeric(18,0)=0 --Added by Mukti(05102018)
,@PlaceofBirth				varchar(150)='' --Added by Mukti(05102018)
,@TrainingSeminars			varchar(500)='' --Added by Mukti(05102018)
,@jobProfile				varchar(500)='' --Added by Mukti(05102018)
,@Location_Preference		varchar(500)='' --Mukti(27112018)
,@Response_of_Candidate		varchar(100)='' --Mukti(10012019)
,@Response_Comments			varchar(1000)='' --Mukti(10012019)
,@Religion					Varchar(50) =''
,@Caste						Varchar(50)=''
,@Caste_Category			Varchar(50)=''
,@No_Of_children			int = 0
,@Shirt_Size				Varchar(20) =''
,@Pant_Size					Varchar(20)=''
,@Shoe_Size					Varchar(20)=''
,@Is_Physical_Disable		tinyint =0
,@Physical_Disable_Perc		float =0 
,@Video_Resume				nvarchar(max) =''
,@Nationality			    Varchar(150)=''
,@Mother_Tongue				Varchar(100)=''

AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	if @Initial =''
	  set @Initial =null
	  
	if @Marital_Status =''
	  set @Marital_Status =null 
	    
	if @Gender =''
	   set @Gender =null
	    
	if @Emp_Second_Name =''
	     set @Emp_Second_Name =null
	     
	if @Present_City =''
	    set @Present_City =null
	    
	if @Present_State =''
	  set @Present_State =null    
	  
	if @Permanentt_Post_Box =''
	  set @Permanentt_Post_Box =null
	  
	if @Permanent_State =''
	  set @Permanent_State =null
	  
	if @Home_Tel_no =''
	 set @Home_Tel_no =null
	 
	if @Date_Of_Join =''
	 set @Date_Of_Join =null

	 if @Other_Email =''
	  set @Other_Email =null  
	  
	 if @Final_CTC =0
	  set @Final_CTC =null  
	  
	  if @Non_Technical_Skill =''
	  set @Non_Technical_Skill =null  
	  
	  if @File_Name =''
	     set @File_Name =null
	       
	  if @Present_Loc = 0 
	    set @Present_Loc =null        
	         
	  if @Permanent_Loc_ID = 0
	   set @Permanent_Loc_ID =null

	   Declare @date1 as DateTime
       set @date1 = cast(getdate() as varchar(11))
	
	--Mukti(start) 04122015
    DECLARE @prev_resume_date as datetime 
	DECLARE @resume_date as datetime 
	DECLARE @resume_code as VARCHAR(25)	
	set @resume_code =''
	--Mukti(end) 04122015	
	      
	if Upper(@tran_type) ='I' 
		begin
		--Mukti(start)04122015
		select @prev_resume_date=system_date from T0055_Resume_Master WITH (NOLOCK) Where cmp_id=@CMP_ID AND Emp_First_Name=@Emp_First_Name  AND Emp_Last_Name=@Emp_Last_Name AND Date_Of_Birth = @Date_Of_Birth
		set @resume_date=DateAdd(Month, 6, @prev_resume_date)
		
		if exists (Select Resume_Id  from T0055_Resume_Master WITH (NOLOCK) Where cmp_id=@CMP_ID AND Emp_First_Name=@Emp_First_Name  AND Emp_Last_Name=@Emp_Last_Name AND Date_Of_Birth = @Date_Of_Birth)
				begin
					Select @resume_code=Resume_Code from T0055_Resume_Master WITH (NOLOCK) Where cmp_id=@CMP_ID AND Emp_First_Name=@Emp_First_Name  AND Emp_Last_Name=@Emp_Last_Name AND Date_Of_Birth=@Date_Of_Birth and ISNULL(Resume_Code,'') <> ''
				END
		--Mukti(end)04122015
		
			if exists (Select Resume_Id  from T0055_Resume_Master WITH (NOLOCK) Where cmp_id=@CMP_ID AND Emp_First_Name=@Emp_First_Name  AND Emp_Last_Name=@Emp_Last_Name AND Date_Of_Birth = @Date_Of_Birth and getdate()< @resume_date) --condition added getdate()< @resume_date by Mukti 04122015)
					begin
							set @Resume_Id=0
							raiserror('@@Already Exists@@',16,2)
							return -1 
					end
				
					select @Resume_Id = isnull(max(Resume_Id),0) + 1 from T0055_Resume_Master WITH (NOLOCK)
						
					insert into T0055_Resume_Master(
											Resume_Id
											,cmp_id
											,Rec_Post_Id 
											,Resume_Posted_date
											,Initial
											,Emp_First_Name
											,Emp_Second_Name
											,Emp_Last_Name
											,Date_Of_Birth
											,Marital_Status
											,Marriage_Date
											,Gender
											,Present_Street
											,Present_City
											,Present_State
											,Present_Post_Box
											,Present_Loc
											,Permanent_Street
											,Permanent_City            
											,Permanent_State			
											,Permanentt_Post_Box
											,Permanent_Loc_ID
											,Home_Tel_no
											,Mobile_No
											,Primary_email
											,Other_Email
											,Non_Technical_Skill
											,Cur_CTC
											,Exp_CTC
											,Total_exp
											,Resume_Name
											,File_Name
											,Resume_Status
											,Final_CTC
											,Date_Of_Join
											,Basic_Salary
											,Emp_Full_PF
											,Emp_Fix_Salary
											,System_Date
											,Source_type_id
											,Source_Id
											,FatherName 
											,PanCardNo
											,Resume_ScreeningStatus --added by sneha on 19 dec 2014
											,Resume_ScreeningBy --added by sneha on 19 dec 2014
											,PanCardAck_No
											,Source_Name
											,Aadhar_CardNo
											,Aadhar_CardPath
											,StateDomicile
											,PlaceofBirth
											,TrainingSeminars
											,jobProfile
											,Location_Preference
											,Response_of_Candidate
											,Response_Comments
											,Religion
											,Caste
											,Caste_Category
											,No_Of_children
											,Shirt_Size
											,Pant_Size
											,Shoe_Size
											,Is_Physical_Disable
											,Physical_Disable_Perc
											,Video_Resume
											,Nationality
											,Mother_Tongue
										) 
		
								values( @Resume_Id
									   ,@cmp_id
									   ,@Rec_Post_Id 
									   ,@date1
									   ,@Initial
									   ,@Emp_First_Name
									   ,@Emp_Second_Name
									   ,@Emp_Last_Name
									   ,@Date_Of_Birth
									   ,@Marital_Status
									   ,@Marriage_Date
									   ,@Gender
									   ,@Present_Street
									   ,@Present_City
									   ,@Present_State
									   ,@Present_Post_Box
										,@Present_Loc
										,@Permanent_Street
										,@Permanent_City            
										,@Permanent_State			
										,@Permanentt_Post_Box
										,@Permanent_Loc_ID
									    ,@Home_Tel_no
									    ,@Mobile_No
										,@Primary_email
										,@Other_Email
										,@Non_Technical_Skill
										,@Cur_CTC
										,@Exp_CTC
										,@Total_exp										
										,@Resume_Name
										,@File_Name
										,@Resume_Status
										,@Final_CTC
										,@Date_Of_Join
										,@Basic_Salary
										,@Emp_Full_PF
										,@Emp_Fix_Salary
										,getdate()
										,@Source_Type_id
										,@Source_id
										,@FatherName
										,@PAN
										,@Resume_ScreeningStatus --added by sneha on 19 dec 2014
										,@Resume_ScreeningBy --added by sneha on 19 dec 2014
										,@PAN_Ack
										,@Source_Name --added on 30062016 sneha
										,@aadhar_Card --Added by Sumit on 06022017
										,@aadhar_Path
										,@StateDomicile
										,@PlaceofBirth
										,@TrainingSeminars
										,@jobProfile
										,@Location_Preference
										,@Response_of_Candidate
										,@Response_Comments
										,@Religion
										,@Caste
										,@Caste_Category 
										,@No_Of_children
										,@Shirt_Size
										,@Pant_Size
										,@Shoe_Size
										,@Is_Physical_Disable
										,@Physical_Disable_Perc
										,@Video_Resume
										,@Nationality
										,@Mother_Tongue
									   )
		if @File_Name <> ''
			BEGIN
				update t0055_resume_master set File_Name = cast(@cmp_id as varchar(18)) +'_'+ cast(@resume_id as varchar(18)) +'_'+@File_Name where Resume_Id = @Resume_Id
			END	
		--Mukti(start)04122015		
		IF @resume_code <> ''
				begin
					update t0055_resume_master set resume_code =@resume_code where cmp_id=@cmp_id and resume_id =@resume_id 			
				end
		else
				BEGIN
					update t0055_resume_master set resume_code =('R' + cast(@cmp_id as varchar(20)) + ':' + cast(1000 + isnull(@Resume_id,0) as varchar(20)) ) where cmp_id=@cmp_id and resume_id =@resume_id
				end
		--Mukti(end)04122015
	end 
	
	else if upper(@tran_type) ='U' 
		begin
			PRINT @Date_Of_Birth
	--Mukti(start)04122015	
		if exists (Select  Resume_Id  from T0055_Resume_Master WITH (NOLOCK) Where cmp_id=@CMP_ID AND Emp_First_Name=@Emp_First_Name  AND Emp_Last_Name=@Emp_Last_Name AND CONVERT(VARCHAR(15),Date_Of_Birth,103) = CONVERT(VARCHAR(15),@Date_Of_Birth,103))
				begin
				print '1111'
				Select @resume_id = Resume_Id  from T0055_Resume_Master WITH (NOLOCK) Where cmp_id=@CMP_ID AND Emp_First_Name=@Emp_First_Name  AND Emp_Last_Name=@Emp_Last_Name AND CONVERT(VARCHAR(15),Date_Of_Birth,103) = CONVERT(VARCHAR(15),@Date_Of_Birth,103)
				Select @resume_code=Resume_Code from T0055_Resume_Master WITH (NOLOCK) Where cmp_id=@CMP_ID AND Emp_First_Name=@Emp_First_Name  AND Emp_Last_Name=@Emp_Last_Name AND CONVERT(VARCHAR(15),Date_Of_Birth,103)=CONVERT(VARCHAR(15),@Date_Of_Birth,103) and ISNULL(Resume_Code,'') <> ''
			print 'Resum_Code'
			print @resume_code
			print @resume_id
			END	
				
		IF @resume_code <>''
				begin
					update t0055_resume_master set resume_code =@resume_code where cmp_id=@cmp_id and resume_id =@resume_id 			
				end
		else
				BEGIN
					update t0055_resume_master set resume_code =('R' + cast(@cmp_id as varchar(20)) + ':' + cast(1000 + isnull(@Resume_id,0) as varchar(20)) ) where cmp_id=@cmp_id and resume_id =@resume_id
				end
	--Mukti(end)04122015

			PRINT @resume_code
			PRINT @resume_id
			Print '112222'
				Update T0055_Resume_Master                  
								Set    		
											Resume_Posted_date =@date1
											,Initial=@Initial
											,Emp_First_Name =@Emp_First_Name
											,Emp_Second_Name=@Emp_Second_Name
											,Emp_Last_Name=@Emp_Last_Name
											,Date_Of_Birth=@Date_Of_Birth
											,Marital_Status=@Marital_Status
											,Gender =@Gender
											,Present_Street =@Present_Street
											,Present_City =@Present_City
											,Present_State = @Present_State
											,Present_Post_Box=@Present_Post_Box
											,Present_Loc=@Present_Loc
											,Permanent_Street = @Permanent_Street
											,Permanent_City = @Permanent_City
											,Permanent_State = @Permanent_State
											,Permanentt_Post_Box  = @Permanentt_Post_Box
											,Permanent_Loc_ID=@Permanent_Loc_ID
											,Home_Tel_no=@Home_Tel_no
											,Mobile_No=@Mobile_No
											,Primary_email=@Primary_email
											,Other_Email=@Other_Email
											,Non_Technical_Skill=@Non_Technical_Skill
											,Cur_CTC=@Cur_CTC
											,Exp_CTC=@Exp_CTC
											,Total_exp = @Total_exp											
											,Resume_Name=@Resume_Name
											,File_Name=@File_Name
											,Resume_Status=@Resume_Status
											,Final_CTC=@Final_CTC
											,Emp_Full_PF=@Emp_Full_PF
											,Emp_Fix_Salary=@Emp_Fix_Salary  
											,System_date=getdate()  
											,Source_Type_id =@Source_Type_id								
											,Source_id=@Source_id
											,FatherName =@FatherName
											,PanCardNo =@PAN
											,Resume_ScreeningStatus=@Resume_ScreeningStatus --added by sneha on 19 dec 2014
											,Resume_ScreeningBy=@Resume_ScreeningBy --added by sneha on 19 dec 2014
											,PanCardAck_No = @PAN_Ack
											,Source_Name = @Source_Name
											,resume_code =('R' + cast(@cmp_id as varchar(20)) + ':' + cast(1000 + isnull(@Resume_id,0) as varchar(20))) --COMMENETD By Mukti 05122015
											,Aadhar_CardNo=@aadhar_Card
											,Aadhar_CardPath=@aadhar_Path --Added by Sumit on 06022017
											,StateDomicile=@StateDomicile
											,PlaceofBirth=@PlaceofBirth
											,TrainingSeminars=@TrainingSeminars
											,jobProfile=@jobProfile
											,Location_Preference=@Location_Preference
											,Response_of_Candidate=@Response_of_Candidate
										    ,Response_Comments=@Response_Comments
										    ,Religion=@Religion
											,Caste=@Caste
											,Caste_Category=@Caste_Category
											,No_Of_children=@No_Of_children
											,Shirt_Size=@Shirt_Size
											,Pant_Size=@Pant_Size
											,Shoe_Size=@Shoe_Size
											,Is_Physical_Disable=@Is_Physical_Disable
											,Physical_Disable_Perc=@Physical_Disable_Perc
											,Video_Resume=Video_Resume
											,Nationality=@Nationality
											,Mother_Tongue=@Mother_Tongue
										where Resume_Id = @Resume_Id  
				
		end	
	else if upper(@tran_type) ='D'
		Begin
			DECLARE @Transfer_ResumeId AS INT
			
			IF EXISTS(SELECT 1 FROM T0055_Resume_Master WITH (NOLOCK) WHERE ISNULL(Transfer_ResumeId,0) > 0)	
				BEGIN	
					SELECT @Transfer_ResumeId=ISNULL(Transfer_ResumeId,0) FROM T0055_Resume_Master WITH (NOLOCK) WHERE ISNULL(Transfer_ResumeId,0) > 0
					
					UPDATE T0055_Resume_Master SET Transfer_CmpId=NULL,Transfer_RecPostId=NULL,Transfer_LocationId=NULL
					WHERE Resume_Id=@Transfer_ResumeId					
				END
			delete from T0090_HRMS_RESUME_EXPERIENCE where Resume_Id=@Resume_Id 
			delete from T0090_HRMS_RESUME_NOMINEE where Resume_Id=@Resume_Id 
			delete from T0090_HRMS_RESUME_Skill where Resume_Id=@Resume_Id
			delete from T0090_HRMS_RESUME_qualification where Resume_Id=@Resume_Id
			delete from T0090_HRMS_RESUME_IMMIGRATION where Resume_Id=@Resume_Id
			delete from T0091_HRMS_RESUME_HEALTH_DETAIL where row_id in (select row_id from T0090_HRMS_RESUME_HEALTH WITH (NOLOCK) where Resume_Id=@Resume_Id)
			delete from T0090_HRMS_RESUME_HEALTH where Resume_Id=@Resume_Id
			delete from T0090_HRMS_RESUME_EARN_DEDUCTION where Resume_Id=@Resume_Id
			delete from T0090_HRMS_RESUME_BANK where Resume_Id=@Resume_Id  --Mukti 26112015
			delete from t0090_HRMS_RESUME_DOCUMENT where Resume_Id=@Resume_Id
			delete  from T0055_Resume_Master where Resume_Id=@Resume_Id			
		end
	RETURN




