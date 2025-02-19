
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Mobile_HRMS_WebService_JobOpeningDetails] 
	@Cmp_ID numeric(18,0),
	@Initial Varchar(10),
	@Emp_First_Name Varchar(50),  
	@Emp_Second_Name Varchar(50),  
	@Emp_Last_Name Varchar(50),  
	@Data_Of_Birth datetime,
	@Address Varchar(Max),  
	@City Varchar(50),  
	@State Varchar(50),  
	@Pincode varchar(50),  
	@PhoneNo varchar(50),  
	@MobileNo varchar(50),  
	@Email varchar(50),  
	@Current_CTC numeric(18,2),
	@Expected_CTC numeric(18,2),
	@Resume_Name varchar(50),  
	@File_Name varchar(50),  
	@Type char(1),  
	@Result varchar(50) OUTPUT  
   
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

DECLARE @Resume_Id numeric(18,0)



IF @Type = 'I'
	BEGIN
		BEGIN TRY
			--DECLARE @EmpFullName varchar(50)

			--SET @EmpFullName = (@Initial + ' ' + @Emp_First_Name + ISNULL(@Emp_Second_Name,'') + ISNULL(@Emp_Last_Name,''))
			
			EXECUTE [P0055_Resume_Master] 
			@Resume_Id	OUTPUT,@Cmp_id = @Cmp_ID,@Rec_Post_Id = 0,@Initial = @Initial,@Emp_First_Name = @Emp_First_Name,@Emp_Second_Name = @Emp_Second_Name,
			@Emp_Last_Name = @Emp_Last_Name,@Date_Of_Birth = @Data_Of_Birth,@Marital_Status = '',@Gender = '',@Present_Street = @Address,
			@Present_City = @City,@Present_State = @State,@Present_Post_Box = @Pincode,@Present_Loc = 1,@Permanent_Street = @Address,
			@Permanent_City = @City,@Permanent_State = @State,@Permanentt_Post_Box = @Pincode,@Permanent_Loc_ID = 1,@Home_Tel_no = @PhoneNo,
			@Mobile_No = @MobileNo,@Primary_email = @Email,@Other_Email = '',@Non_Technical_Skill = '',@Cur_CTC = @Current_CTC,@Exp_CTC = @Expected_CTC,
			@Total_exp = 0.0,@Resume_Name = @Resume_Name,@File_Name =	@File_Name,@Resume_Status = 0,@Final_CTC = @Expected_CTC,@Date_Of_Join = '1900-01-01',
			@Basic_Salary = @Expected_CTC,@Emp_Full_PF  = 0,@Emp_Fix_Salary	= 0.0,@Source_Type_id = 0,@Source_id = 0,
			@FatherName = @Emp_Second_Name,@PAN = '',@Resume_ScreeningStatus = 0,@Resume_ScreeningBy = 0,@PAN_Ack = '',
			@Source_Name = '',@tran_type = @Type,@aadhar_Card = '',@aadhar_Path = ''
				
			SET @Result = 'Resume Upload Successfully#True#' + CAST(@Resume_Id AS varchar(50))
		END TRY
		BEGIN CATCH
			SET @Result = ERROR_MESSAGE()+'#False#0'
		END CATCH
	END
ELSE IF @Type = 'D' -- For Current Opening from HRMS
	BEGIN
		SELECT Job_Title,Job_Description,Cmp_id,No_of_vacancies,CONVERT(varchar(11),Posted_date,103) AS 'Posted_date',Posted_status,Rec_Post_Code,
		Rec_Req_ID,CONVERT(varchar(11), Rec_Start_date,103) AS 'Rec_Start_date',CONVERT(varchar(11), Rec_End_date,103) AS 'Rec_End_date',
		Rec_Post_Id,Qual_Detail,Skill_detail,Experience_year,Location
		FROM V0052_HRMS_Recruitement_Posted
	END

