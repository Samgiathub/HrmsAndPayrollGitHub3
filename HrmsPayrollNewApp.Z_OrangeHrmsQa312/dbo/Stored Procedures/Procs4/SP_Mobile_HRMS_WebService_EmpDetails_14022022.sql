
CREATE PROCEDURE [dbo].[SP_Mobile_HRMS_WebService_EmpDetails_14022022]
	@Emp_ID numeric(18,0),
	@Cmp_ID numeric(18,0),
	@Vertical_ID numeric(18,0),
	@Emp_Code Varchar(50),
	@Address Varchar(Max),
	@City Varchar(50),
	@State Varchar(100),
	@Pincode varchar(50),
	@PhoneNo varchar(50),
	@MobileNo varchar(50),
	@Email varchar(50),
	@ImageName varchar(50),
	@Branch_ID numeric(18,0),
	@Department_ID numeric(18,0),
	@Type char(1),
	@Result varchar(50) OUTPUT
	
	
AS
SET NOCOUNT ON		
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON

IF @Type = 'U' -- For Update Employee Details
	BEGIN
		UPDATE T0080_EMP_MASTER SET Present_Street = @Address,Present_City =@City,Present_State= @State,
		Present_Post_Box = @Pincode,Home_Tel_no = @PhoneNo,Mobile_No = @MobileNo,Other_Email = @Email
		WHERE Emp_ID = @Emp_ID
		
		SET @Result = 'Employee Update Successfully'
		Select @Result -- Niraj(12082021)
	END
ELSE IF @Type = 'E' -- For Get Employee Details
	BEGIN
		DECLARE @PASSEXPIRYDATE DATETIME
		DECLARE @ENABLEVALIDATION TINYINT
		DECLARE @MINCHAR TINYINT
		DECLARE @UPPERCHAR TINYINT
		DECLARE @LOWERCHAR TINYINT
		DECLARE @ISDIGIT TINYINT
		DECLARE @SPECIALCHAR TINYINT
		DECLARE @PASSEXPDAYS INT
		DECLARE @REMINDERDAYS INT
		DECLARE @EFFECTIVEDATE DATETIME
		DECLARE @PASSWORDFORMAT NVARCHAR(MAX)
		
		DECLARE @MAILSERVER NVARCHAR(MAX)
		DECLARE @MAILSERVER_PORT INT
		DECLARE @MAILSERVER_USERNAME NVARCHAR(MAX)
		DECLARE @MAILSERVER_PASSWORD NVARCHAR(MAX)
		DECLARE @SSL NVARCHAR(MAX)
		DECLARE @MAILSERVER_DISPLAYNAME NVARCHAR(MAX)
		DECLARE @FROM_EMAIL NVARCHAR(MAX)
		
		SELECT @ENABLEVALIDATION = Enable_Validation,@MINCHAR = Min_Chars,@UPPERCHAR = Upper_Char,
		@LOWERCHAR = Lower_Char,@ISDIGIT = Is_Digit,@SPECIALCHAR = Special_Char,@PASSEXPDAYS = Pass_Exp_Days,
		@REMINDERDAYS = Reminder_Days,@PASSWORDFORMAT = '' -- password formate blank by Niraj(21012022)
		FROM T0011_Password_Settings WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID
		
		SELECT @MAILSERVER = MailServer,@MAILSERVER_PORT = MailServer_Port,@MAILSERVER_USERNAME = MailServer_UserName,
		@MAILSERVER_PASSWORD = MailServer_Password,@SSL = Ssl,@MAILSERVER_DISPLAYNAME = MailServer_DisplayName,
		@FROM_EMAIL = From_Email
		FROM T0010_Email_Setting  WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID
				
		IF @ENABLEVALIDATION = 1
			BEGIN
				SELECT @EFFECTIVEDATE = ISNULL(MAX(Effective_From_Date),'') FROM T0250_Change_Password_History  WITH (NOLOCK) 
				WHERE Cmp_ID = @Cmp_ID And Emp_ID = @Emp_ID
				
				IF @EFFECTIVEDATE = '1900-01-01 00:00:00.000'
					BEGIN
						SELECT @PASSEXPIRYDATE = System_Date 
						FROM T0080_EMP_MASTER  WITH (NOLOCK) 
						WHERE  Cmp_ID = @Cmp_ID And Emp_ID = @Emp_ID
					END
				ELSE
					BEGIN
						set @PASSEXPIRYDATE = DATEADD(dd, @PASSEXPDAYS , @EFFECTIVEDATE)
					END
			END
		
		SELECT Emp_ID,VM.Cmp_ID,Alpha_Emp_Code AS 'Emp_code',Emp_Full_Name_new,CONVERT(varchar(11),Date_Of_Join,103) AS 'Date_Of_Join',
		Gender,ISNULL(Dept_ID,0) AS 'Dept_ID',Dept_Name,ISNULL(Grd_ID,0) AS 'Grd_ID',Grd_Name,ISNULL(Desig_Id,0) AS 'Desig_Id',
		Desig_Name,ISNULL(Branch_ID,0) AS 'Branch_ID',Branch_Name,Work_Tel_No,Mobile_No,Emp_Full_Name_Superior,Work_Email,
		REPLACE(Present_Street,'"','') AS 'Street_1',ISNULL(Present_City,'') AS 'City',ISNULL(Present_State,'') as 'State',Present_Post_Box AS 'Zip_code',Home_Tel_no,Mobile_No,Other_Email,
		(CASE WHEN Image_Name = '0.jpg' OR Image_Name = '' THEN (CASE WHEN Gender = 'Male' THEN 'Emp_Default.png' ELSE 'Emp_Default_Female.png' END) ELSE Image_Name END) AS 'Image_Name',
		'' AS 'Image_Path',Loc_name,BM.Bank_Name,VM.Bank_Branch_Name,Father_name,CONVERT(varchar(11),Date_Of_Birth,103) AS 'DOB',
		VM.Inc_Bank_AC_No,VM.Ifsc_Code,VM.Pan_No,VM.Aadhar_Card_No,UAN_No,Blood_Group,VM.SIN_No AS 'ESIC_No',VM.Emp_Superior,
		
		@ENABLEVALIDATION AS 'PasswordEnableValidation',
		@MINCHAR AS 'MinChar',@UPPERCHAR AS 'UpperChar',@LOWERCHAR AS 'LowerChar',@ISDIGIT AS 'ISDigit',
		@SPECIALCHAR AS 'SpecialChar',ISNULL(@PASSEXPDAYS,0) AS 'PassExpireDays',ISNULL(@PASSEXPIRYDATE,'') AS 'PassExpireDate',
		ISNULL(@REMINDERDAYS,'') AS 'ReminderDays',@PASSWORDFORMAT AS 'PasswordFormat',
		
		
		ISNULL(@MAILSERVER,'') AS 'MAILSERVER',ISNULL(@MAILSERVER_PORT,0) AS 'MAILSERVER_PORT',ISNULL(@MAILSERVER_USERNAME,'') AS 'MAILSERVER_USERNAME',
		ISNULL(@MAILSERVER_PASSWORD,'') AS 'MAILSERVER_PASSWORD',ISNULL(@SSL,'') AS 'SSL',ISNULL(@MAILSERVER_DISPLAYNAME,'') AS 'MAILSERVER_DISPLAYNAME',
		ISNULL(@FROM_EMAIL,'') AS 'FROM_EMAIL','ankita.s@orangewebtech.com' AS 'RECIPIENT',7 AS 'FeedbackDays'
		
		FROM V0080_Employee_Master VM
		LEFT JOIN T0040_BANK_MASTER BM   WITH (NOLOCK) ON VM.Bank_ID = BM.Bank_ID
		WHERE Emp_ID = @Emp_ID AND VM.Cmp_ID = @Cmp_ID
		
		SELECT AD_NAME,E_AD_FLAG,E_AD_MODE,E_AD_PERCENTAGE,E_AD_AMOUNT FROM V0100_EMP_EARN_DEDUCTION 
		WHERE EMP_ID = @Emp_ID AND CMP_ID = @Cmp_ID AND AD_PART_OF_CTC = 1
				
	END
ELSE IF @Type = 'I' -- For Get Employee Image Name
	BEGIN
		select @Result = (CASE WHEN Image_Name = '0.jpg' OR Image_Name = '' THEN (CASE WHEN Gender = 'Male' THEN 'Emp_Default.png' ELSE 'Emp_Default_Female.png' END) ELSE Image_Name END)
		FROM V0080_Employee_Master
		WHERE Emp_ID = @Emp_ID AND Cmp_ID = @Cmp_ID

		select @Result
	END
ELSE IF @Type = 'P' -- For Update Employee Image
	BEGIN
		UPDATE T0080_EMP_MASTER SET Image_Name = @ImageName
		WHERE Emp_ID = @Emp_ID AND Cmp_ID = @Cmp_ID
		
		IF @ImageName = ''
			BEGIN
				SELECT @ImageName = (CASE WHEN Image_Name = '0.jpg' OR Image_Name = '' THEN (CASE WHEN Gender = 'Male' THEN 'Emp_Default.png' ELSE 'Emp_Default_Female.png' END) ELSE Image_Name END)
				FROM V0080_Employee_Master
				WHERE Emp_ID = @Emp_ID AND Cmp_ID = @Cmp_ID
			END
			
		SET @Result = 'Photo Update Successfully#' + @ImageName
		Select @Result -- Niraj(12082021)
	END
ELSE IF @Type = 'S' -- Get EmpDetails From Emp Code
	BEGIN
		SELECT Emp_ID,VM.Cmp_ID,Alpha_Emp_Code AS 'Emp_code',Emp_Full_Name_new,CONVERT(varchar(11),Date_Of_Join,103) AS 'Date_Of_Join',Gender,ISNULL(Dept_ID,0) AS 'Dept_ID',
		Dept_Name,ISNULL(Grd_ID,0) AS 'Grd_ID',Grd_Name,ISNULL(Desig_Id,0) AS 'Desig_Id',Desig_Name,ISNULL(Branch_ID,0) AS 'Branch_ID',Branch_Name,Work_Tel_No,Mobile_No,Emp_Full_Name_Superior,
		Work_Email,Present_Street AS 'Street_1',ISNULL(Present_City,'') AS 'City',ISNULL(Present_State,'') as 'State',Present_Post_Box AS 'Zip_code',Home_Tel_no,Mobile_No,Other_Email,
		(CASE WHEN Image_Name = '0.jpg' OR Image_Name = '' THEN (CASE WHEN Gender = 'Male' THEN 'Emp_Default.png' ELSE 'Emp_Default_Female.png' END) ELSE Image_Name END) AS 'Image_Name',
		'' AS 'Image_Path',Loc_name,BM.Bank_Name,VM.Bank_Branch_Name,Father_name,CONVERT(varchar(11),Date_Of_Birth,103) AS 'DOB',
		VM.Inc_Bank_AC_No,VM.Ifsc_Code,VM.Pan_No,VM.Aadhar_Card_No,VM.SIN_No AS 'ESIC_No',VM.Emp_Superior
		FROM V0080_Employee_Master VM
		LEFT JOIN T0040_BANK_MASTER BM   WITH (NOLOCK) ON VM.Bank_ID = BM.Bank_ID
		WHERE VM.Emp_code = @Emp_Code
	END
ELSE IF @Type = 'V' -- Get Employee Assigned Vertical / Distributor for Vivo Gujarat
	BEGIN
		DECLARE @strVerticalID varchar(255)
		
		SELECT @strVerticalID  = Vertical_ID  FROM T0050_Assign_VerticalSubVertical   WITH (NOLOCK) WHERE Emp_id = @Emp_ID
		
		SELECT VS.Vertical_ID,VS.Vertical_Name 
		FROM T0040_Vertical_Segment VS  WITH (NOLOCK) 
		INNER JOIN 
		(
			SELECT Data FROM dbo.Split(@strVerticalID,'#')
		) AV ON VS.Vertical_ID = AV.Data
	END
ELSE IF @Type = 'L' -- Get Employee Assigned Vertical / Distributor for Vivo Gujarat
	BEGIN
	
		SELECT SubVertical_ID,SubVertical_Name
		FROM T0050_SubVertical  WITH (NOLOCK) 
		WHERE Vertical_ID = @Vertical_ID
	END
ELSE IF @Type = 'A' -- Get All Employee
	BEGIN
		SELECT Emp_ID,Cmp_ID,Alpha_Emp_Code,Emp_Full_Name_new AS 'Emp_Full_Name',Emp_Full_Name_Superior,Date_Of_Join,
		Date_Of_Birth,Dept_Name,Desig_Name,Branch_Name,Vertical_Name,Mobile_No,Work_Email,Gender,Blood_Group,
		(CASE WHEN Image_Name = '0.jpg' OR Image_Name = '' THEN (CASE WHEN Gender = 'Male' THEN 'Emp_Default.png' ELSE 'Emp_Default_Female.png' END) ELSE Image_Name END) AS 'Image_Name',
		'' AS 'Image_Path',Emp_Left,Emp_Left_Date
		FROM V0080_Employee_Master 
		WHERE Cmp_ID = @Cmp_ID AND (Emp_Left = 'N' OR (Emp_Left = 'Y' AND Emp_Left_Date > GETDATE()))
		--WHERE Cmp_ID = @Cmp_ID AND Emp_ID <> @Emp_ID AND (Emp_Left = 'N' OR (Emp_Left = 'Y' AND Emp_Left_Date > GETDATE()))
		--AND Branch_ID = @Branch_ID AND Dept_ID = @Department_ID
	END
ELSE IF @Type = 'B' -- Bind Branch Records & Department
	BEGIN
		SELECT Branch_ID,Branch_Name 
		FROM T0030_BRANCH_MASTER   WITH (NOLOCK) 
		WHERE Cmp_ID = @Cmp_ID 
		ORDER BY Branch_Name

		SELECT Dept_Id,Dept_Name 
		FROM T0040_Department_Master  WITH (NOLOCK)  
		WHERE InActive_EffeDate > GETDATE() OR InActive_EffeDate IS NULL AND Cmp_Id = @Cmp_ID 
		ORDER BY Dept_Name
	END
