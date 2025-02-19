
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0055_Update_ResumeMaster]
	@Resume_Id					numeric(18) output
	,@Rec_Post_Id			    numeric(18,0)
	,@Initial					varchar(50)
	,@Emp_First_Name			varchar(50)
	,@Emp_Second_Name			varchar(50)
	,@Emp_Last_Name				varchar(50)
	,@Date_Of_Birth				datetime  =null
	,@Marital_Status			varchar(20)
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
	,@Final_CTC					numeric(18,2)
	,@Date_Of_Join				datetime
	,@Basic_Salary				numeric(18,2)
	,@Emp_Full_PF				numeric(18,2)
	,@Emp_Fix_Salary			numeric(18,2)
	,@HasPancard				int
	,@PanCardNo					varchar(50)
	,@PanCardAck_Path			varchar(100)
	,@Address_Proof				varchar(max)
	,@ConfirmJoining            int
	,@Comments					varchar(200)
	,@FatherName                varchar(100)
	,@Lock						int
	,@Identity_Proof            varchar(max)
	,@Present_District          varchar(50)
	,@Present_PO                varchar(50)
	,@Permanent_District        varchar(50)
	,@Permanent_PO              varchar(50)
	,@DocumentType_Identity     int
	,@FilePhoto                 varchar(max)
	,@PanCardAck_No				varchar(30)		--Add by Ripal 07Aug2013
	,@DocumentType_Address_Proof int=null			--Add by Ripal 08Aug2013
	,@DocumentType_Identity2     int=null			--Add by Sneha 18Dec2013
	,@Identity_Proof2			varchar(max)=null	--Add by Sneha 18Dec2013
	,@DocumentType_AddressProof2 int=null			--Add by Sneha 18Dec2013
	,@Address_Proof2			varchar(max)=null	--Add by Sneha 18Dec2013
	,@marriage_Document_Type_id int	=0		
	,@Marriage_Proof			varchar(max)=''	
	,@Source_Type_id			Numeric(18,0)=0
	,@Source_id					Numeric(18,0)=0
	,@tran_type				    char(1)
	,@Marriage_Date				nvarchar(200)
	,@pancardfile               nvarchar(max)=''
	,@is_physical				Numeric(18,0) = 0
	,@aadhar_Card				varchar(50)=''
	,@aadhar_Path				varchar(100)='' ----Added by Sumit on 06022017
	
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
	   
	  if @PanCardAck_No = ''		--Add by Ripal 07Aug2013
		set @PanCardAck_No = null
		
		 if @Marriage_Date =''
	 set @Marriage_Date =null  --aaded by sumit 29Aug2014
	   
BEGIN
	if @Resume_Id <> 0 or @Resume_Id <> null
		begin
			if @tran_type = 'U'
				begin
					if exists (Select 1  from T0055_Resume_Master WITH (NOLOCK) Where Resume_Id=@Resume_Id)
						begin
							update T0055_Resume_Master
							set  	 Initial=@Initial
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
									,Final_CTC=@Final_CTC
									,Date_Of_Join=@Date_Of_Join
									,Emp_Full_PF=@Emp_Full_PF
									,Emp_Fix_Salary=@Emp_Fix_Salary 
									,HasPancard = @HasPancard
									,PanCardNo = @PanCardNo
									,PanCardAck_Path = @PanCardAck_Path
									,Address_Proof=@Address_Proof
									,ConfirmJoining=@ConfirmJoining
									,Comments=@Comments
									,FatherName=@FatherName
									,Identity_Proof=@Identity_Proof
									,Lock=@Lock
									,Present_District =@Present_District          
									,Present_PO=@Present_PO                
									,Permanent_District=@Permanent_District       
									,Permanent_PO=@Permanent_PO             
									,DocumentType_Identity=@DocumentType_Identity
									,PanCardAck_No = @PanCardAck_No			--Add by Ripal 07Aug2013
									,DocumentType_Address_Proof = @DocumentType_Address_Proof --Add by Ripal 08Aug2013
									,DocumentType_Identity2 = @DocumentType_Identity2	--Add by Sneha 18Dec2013
									,Identity_Proof2 = @Identity_Proof2					--Add by Sneha 18Dec2013
									,DocumentType_AddressProof2 = @DocumentType_AddressProof2	--Add by Sneha 18Dec2013
									,Address_Proof2 = @Address_Proof2					--Add by Sneha 18Dec2013
									,DocumentType_Marriage_Proof = @marriage_Document_Type_id
									,Marriage_Proof = @Marriage_Proof 
									,Source_Type_id =@Source_Type_id								
									,Source_id=@Source_id
									,Marriage_Date=@Marriage_Date
									,PanCardProof =@pancardfile 
									,is_physical = @is_physical
									,Aadhar_CardNo=@aadhar_Card
									,Aadhar_CardPath=@aadhar_Path --Added by Sumit on 06022017
							where Resume_Id = @Resume_Id  
					-- add candidate photograph		
						if exists (Select 1  from T0090_HRMS_RESUME_HEALTH WITH (NOLOCK) Where Resume_Id=@Resume_Id)	
							begin
								update T0090_HRMS_RESUME_HEALTH
								set emp_file_name = @FilePhoto
								where Resume_ID=@Resume_Id
							END
						Else
							begin
								declare @cmpid  int
								select @cmpid=Cmp_id from T0055_Resume_Master WITH (NOLOCK) where Resume_Id=@Resume_Id
								
								exec P0090_HRMS_RESUME_HEALTH 0,@cmpid,@Resume_Id,'','','',@FilePhoto,'','I'
							End
						End
						
					-- add candidate acceptance in t0060_RESUME_FINAL	
					if @Lock = 1
						begin
							if exists(select 1 from T0060_RESUME_FINAL WITH (NOLOCK) where Resume_ID=@Resume_Id)
								begin
									update T0060_RESUME_FINAL
									set Acceptance = 1,
										Acceptance_Date = GETDATE()
										where Resume_Id=@Resume_Id
								End	
						End	
				End
		End
END


