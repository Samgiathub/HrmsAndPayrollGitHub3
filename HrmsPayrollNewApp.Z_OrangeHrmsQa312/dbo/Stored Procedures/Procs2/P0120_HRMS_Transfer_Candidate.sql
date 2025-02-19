

---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0120_HRMS_Transfer_Candidate]
	@Rec_Post_ID numeric 
	,@Cmp_ID numeric
	,@Location_ID numeric
	,@TransferCmp_ID numeric
	,@Resume_ID numeric output
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

DECLARE @ctrResumeId as INT
DECLARE @Resume_code as VARCHAR(20)
--Resume Status	0 -Pending 
			  --1 -Approved
			  --2 -Reject
			  --3 -HOld
			  --4 -All
			  --5 -Shortlisted
			
Begin
SELECT @Resume_code=Resume_Code FROM T0055_Resume_Master WITH (NOLOCK) WHERE Resume_Id=@Resume_ID and Cmp_id=@Cmp_ID

	IF EXISTS(SELECT 1 FROM T0055_Resume_Master WITH (NOLOCK) WHERE Resume_Id=@Resume_ID and Cmp_id=@Cmp_ID and ISNULL(Transfer_RecPostId,0) > 0)
		BEGIN
			raiserror('@@Candidate already Transferred.@@',16,2)
			return
		END
		
	IF EXISTS(SELECT 1 FROM T0060_RESUME_FINAL WITH (NOLOCK) WHERE Resume_Id=@Resume_ID and Cmp_id=@Cmp_ID and ISNULL(IsEmployee,0)=1)
		BEGIN
			raiserror('@@Cannot be Transferred,Candidate converted to Employee.@@',16,2)
			return
		END
		
	IF EXISTS(SELECT 1 FROM T0055_Resume_Master WITH (NOLOCK) WHERE Resume_Id=@Resume_ID and Cmp_id=@TransferCmp_ID and Rec_post_Id=@Rec_Post_ID and ISNULL(Location_Preference,'')=cast(@Location_ID as VARCHAR(15)))
		BEGIN
			raiserror('@@Candidate exist with same Job Title and Location@@',16,2)
			return
		END
		PRINT 'm'
	UPDATE T0055_Resume_Master 
	SET Transfer_CmpId=@TransferCmp_ID,Transfer_RecPostId=@Rec_Post_ID,
	    Transfer_LocationId=@Location_ID
	WHERE Resume_Id=@Resume_ID and Cmp_id=@Cmp_ID
		
   SELECT  @ctrResumeId = ISNULL(max(Resume_Id),0) + 1  From T0055_Resume_Master  WITH (NOLOCK) 
    --PRINT @ctrResumeId
   INSERT INTO T0055_Resume_Master(Resume_Id,cmp_id
			,Rec_Post_Id 
			,Resume_Posted_date
			,Initial
			,Emp_First_Name
			,Emp_Second_Name
			,Emp_Last_Name
			,Date_Of_Birth
			,Marital_Status
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
			,Resume_ScreeningStatus 
			,Resume_ScreeningBy 
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
			,Transfer_CmpId
			,Transfer_RecPostId
			,Transfer_LocationId)
   SELECT @ctrResumeId as Resume_Id
  			,@TransferCmp_ID as Cmp_Id
			,@Rec_Post_ID as Rec_Post_Id 
			,Resume_Posted_date
			,Initial
			,Emp_First_Name
			,Emp_Second_Name
			,Emp_Last_Name
			,Date_Of_Birth
			,Marital_Status
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
			,0 Resume_Status
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
			,Resume_ScreeningStatus 
			,Resume_ScreeningBy 
			,PanCardAck_No
			,Source_Name
			,Aadhar_CardNo
			,Aadhar_CardPath
			,StateDomicile
			,PlaceofBirth
			,TrainingSeminars
			,jobProfile
			,@Location_ID as Location_Preference
			,Response_of_Candidate
			,Response_Comments
			,null Transfer_CmpId
			,null Transfer_RecPostId
			,null Transfer_LocationId
   FROM T0055_Resume_Master WITH (NOLOCK)
   WHERE Resume_Id=@Resume_ID and Cmp_id=@Cmp_ID 
  
  
  --print ('R' + cast(@TransferCmp_ID as varchar(20)) + ':' + cast(1000 + isnull(@ctrResumeId,0) as varchar(20)) )  
  UPDATE t0055_resume_master 
  SET resume_code =('R' + cast(@TransferCmp_ID as varchar(20)) + ':' + cast(1000 + isnull(@ctrResumeId,0) as varchar(20))),
	  Transfer_ResumeId=@Resume_ID --previous Resume_Id	 
  WHERE cmp_id=@TransferCmp_ID and resume_id =@ctrResumeId
  
  --PRINT @ctrResumeId
  set @Resume_ID=@ctrResumeId
  RETURN @Resume_ID
End			



--select count(1) from INFORMATION_SCHEMA.COLUMNS where table_Name='T0055_Resume_Master'
