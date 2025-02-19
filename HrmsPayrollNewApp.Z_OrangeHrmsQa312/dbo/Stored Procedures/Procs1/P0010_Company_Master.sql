
CREATE PROCEDURE [dbo].[P0010_Company_Master] 
  @Cmp_Id NUMERIC(18, 0) OUTPUT
, @Cmp_Name VARCHAR(100)
, @Cmp_Address VARCHAR(250)
, @Loc_ID NUMERIC(18, 0)
, @Cmp_City VARCHAR(50)
, @Cmp_PinCode VARCHAR(10)
, @Cmp_Phone VARCHAR(20)
, @Cmp_Email VARCHAR(50)
, @Cmp_Web VARCHAR(50)
, @Date_Format VARCHAR(5)
, @From_Date DATETIME
, @To_Date DATETIME
, @PF_No VARCHAR(40)
, @ESIC_No VARCHAR(50)
, @Domain_Name VARCHAR(50)
, @Image_Name VARCHAR(200)
, @Default_Holiday VARCHAR(200) = NULL
, @tran_type CHAR(1)
, @Tan_No VARCHAR(30)
, @pan_No VARCHAR(30)
, @Is_Organise_chart TINYINT = 0
, @Image_file_path VARCHAR(1000) = ''
, @Cmp_Code VARCHAR(50) = ''
, @Is_Auto_Alpha_Numeric_Code TINYINT = 0
, @No_Of_Digit_Emp_Code NUMERIC(10) = 4
, @Cmp_Signature NVARCHAR(MAX) = ''
, @is_GroupOFCmp TINYINT = 0
, @is_Main TINYINT = 0
, @Is_Organo_designationwise TINYINT = 0
, @ImageObj IMAGE = ''
, @Inout_Duration NUMERIC(10, 0) = 300
, @Is_Alpha_Numeric_Branchwise TINYINT = 0
, @Is_Contractor_Company TINYINT = 0
, @Has_Digital_Certi TINYINT = 0
, @Digital_Certi_FileName VARCHAR(100) = ''
, @Digital_Certi_Password VARCHAR(50) = ''
, @taxmanagerform16 VARCHAR(150) =''
, @FathernameForm16 VARCHAR(150) =''
, @Desigmanagerform16 VARCHAR(50) = ''
, @CitAddress VARCHAR(500) = ''
, @CITcity VARCHAR(50) = ''
, @Citpin VARCHAR(10) = ''
, @Dateform16submit DATETIME = NULL
, @Cmp_LicenseNo VARCHAR(50)=''   
, @Cmp_RegistrationNo VARCHAR(50) ='' 
, @Cmp_NatureOfBusiness VARCHAR(50) ='' 
, @Date_Of_Establishment DATETIME =NULL 
, @Factory_Type VARCHAR(50) =''   
, @License_Office VARCHAR(50) =''    
, @User_Id NUMERIC(18, 0) = 0 
, @IP_Address VARCHAR(30)= '' 
, @Is_Company_Wise TINYINT = 0   
, @Is_Date_Wise TINYINT = 0   
, @Is_JoiningDate_Wise TINYINT = 0   
, @DateFormat VARCHAR(10)  = ''  
, @is_Reset_Sequance TINYINT = 0   
, @cmp_Hr_Manager VARCHAR(MAX) = ''
, @Cmp_Hr_Manager_Desig VARCHAR(MAX) = ''
, @Max_Emp_Code VARCHAR(50) = 'Company_Wise' 
, @Sample_Emp_Code VARCHAR(500) = ''    
, @Is_Desig TINYINT = 0  
, @Is_Cate TINYINT = 0  
, @Is_EmpType TINYINT = 0  
, @Is_DateofBirth TINYINT = 0   
, @Is_Current_Date TINYINT = 0  
, @DateFormat_Birth VARCHAR(10) = '' 
, @DateFormat_Current VARCHAR(10) = '' 
, @State VARCHAR(100)    
, @PfTrustNo VARCHAR(100)
, @Is_Pf_Applicable NUMERIC(18, 0) = 0 
, @Is_ESIC_APPLICABLE NUMERIC(18, 0) = 0 
, @Alt_W_Name VARCHAR(100) = '' 
, @Alt_W_Full_Day_Cont VARCHAR(50) = '' 
, @Cmp_Header VARCHAR(200) = '' 
, @Cmp_Footer VARCHAR(200) = '' 
, @GST TINYINT = 0  
, @GST_No VARCHAR(50)=''  
, @GST_Cmp_Name VARCHAR(250) = ''  
, @LWF_Number VARCHAR(100) = '' 
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

DECLARE @loginname AS VARCHAR(50)
DECLARE @Prv_Domain_Name AS VARCHAR(50)
DECLARE @Login_ID AS NUMERIC
SET @Login_ID =0

IF @DateFormat_Birth = '' SET @DateFormat_Birth = NULL
IF @DateFormat_Current = '' SET @DateFormat_Current = NULL

DECLARE @Old_Cmp_Name VARCHAR(100)
DECLARE @Old_Cmp_Address VARCHAR(250)
DECLARE @Old_Loc_ID NUMERIC(18, 0)
DECLARE @Old_Location_Name VARCHAR(100)
DECLARE @New_Location_Name VARCHAR(100)
DECLARE @Old_Cmp_City VARCHAR(50)
DECLARE @Old_Cmp_PinCode VARCHAR(10)
DECLARE @Old_Cmp_Phone VARCHAR(20)
DECLARE @Old_Cmp_Email VARCHAR(50)
DECLARE @Old_Cmp_Web VARCHAR(50)
DECLARE @Old_From_Date DATETIME
DECLARE @Old_To_Date DATETIME
DECLARE @Old_PF_No VARCHAR(40)
DECLARE @Old_ESIC_No VARCHAR(50)
DECLARE @Old_Tan_No VARCHAR(30)
DECLARE @Old_pan_No VARCHAR(30)
DECLARE @Old_Domain_Name VARCHAR(50)
DECLARE @Old_Cmp_Code VARCHAR(50)
DECLARE @Old_Default_Holiday VARCHAR(200)
DECLARE @Old_Inout_Duration NUMERIC(10, 0)
DECLARE @Old_Is_Auto_Alpha_Numeric_Code TINYINT
DECLARE @Old_No_Of_Digit_Emp_Code NUMERIC(10)
DECLARE @Old_Is_Contractor_Company TINYINT
DECLARE @Old_Is_Alpha_Numeric_Branchwise TINYINT
DECLARE @Old_Is_Organo_designationwise TINYINT
DECLARE @Old_Has_Digital_Certi TINYINT
DECLARE @OldValue VARCHAR(MAX)
DECLARE @Old_Is_Company_Wise TINYINT   
DECLARE @Old_Is_Date_Wise TINYINT   
DECLARE @Old_Is_JoiningDate_Wise TINYINT   
DECLARE @Old_Is_CurrentDate_Wise TINYINT   
DECLARE @Old_DateFormat VARCHAR(10)   
DECLARE @Old_is_Reset_Sequance TINYINT   
DECLARE @Old_cmp_Hr_Manager VARCHAR(MAX)
DECLARE @Old_Cmp_Hr_Manager_Desig VARCHAR(MAX)
DECLARE @Old_Max_Emp_Code VARCHAR(50)
DECLARE @Old_Sample_Emp_Code VARCHAR(500)
DECLARE @Old_Is_Desig VARCHAR(1)
DECLARE @Old_Is_Cate VARCHAR(1)
DECLARE @Old_Is_EmpType VARCHAR(1)
DECLARE @Old_Is_DateofBirth VARCHAR(1)
DECLARE @Old_Is_Current_Date VARCHAR(1)
DECLARE @Old_DateFormat_Birth VARCHAR(10)
DECLARE @Old_DateFormat_Current VARCHAR(10)
DECLARE @State_Id NUMERIC(18, 0) 
DECLARE @CMP_State_Name VARCHAR(50)
DECLARE @Old_Is_Pf_Applicable NUMERIC(18, 0)
DECLARE @Old_Is_ESIC_APPLICABLE NUMERIC(18, 0)
DECLARE @Old_Alt_W_Name VARCHAR(50)
DECLARE @Old_Alt_W_Full_Day_Cont VARCHAR(50)

SET @Old_Cmp_Name = ''
SET @Old_Cmp_Address = ''
SET @Old_Loc_ID = 0
SET @Old_Location_Name = ''
SET @New_Location_Name = ''
SET @Old_Cmp_City = ''
SET @Old_Cmp_PinCode = ''
SET @Old_Cmp_Phone = ''
SET @Old_Cmp_Email = ''
SET @Old_Cmp_Web = ''
SET @Old_From_Date = NULL
SET @Old_To_Date = NULL
SET @Old_PF_No = ''
SET @Old_ESIC_No = ''
SET @Old_Tan_No  = ''
SET @Old_pan_No  = ''
SET @Old_Domain_Name = ''
SET @Old_Cmp_Code = ''
SET @Old_Default_Holiday = ''
SET @Old_Inout_Duration  = 300
SET @Old_Is_Auto_Alpha_Numeric_Code = 0
SET @Old_No_Of_Digit_Emp_Code = 4
SET @Old_Is_Contractor_Company = 0
SET @Old_Is_Alpha_Numeric_Branchwise = 0
SET @Old_Is_Organo_designationwise = 0
SET @Old_Has_Digital_Certi = 0
SET @OldValue = ''
SET @Old_Is_Company_Wise = 0   
SET @Old_Is_Date_Wise = 0   
SET @Old_Is_JoiningDate_Wise = 0   
SET @Old_DateFormat = NULL   
SET @Old_is_Reset_Sequance = 0   
SET @Old_cmp_Hr_Manager =''
SET @Old_Cmp_Hr_Manager_Desig =''
SET @Old_Max_Emp_Code = ''
SET @Old_Sample_Emp_Code = ''
SET @Old_Is_Desig = ''
SET @Old_Is_Cate = ''
SET @Old_Is_EmpType = ''
SET @Old_Is_DateofBirth  = ''
SET @Old_Is_Current_Date = ''
SET @Old_DateFormat_Birth = ''
SET @Old_DateFormat_Current = ''

IF LEFT(@Domain_Name, 1)<> '@' SET @Domain_Name = '@' + @Domain_Name

IF @tran_type ='I' BEGIN
  IF EXISTS (SELECT Cmp_ID
      FROM dbo.T0010_COMPANY_MASTER WITH (NOLOCK)
    WHERE UPPER(Cmp_Name)=UPPER(@Cmp_Name)) BEGIN
    SET @Cmp_Id = 0
    RETURN
  END
  ELSE IF EXISTS (SELECT Cmp_ID
      FROM dbo.T0010_COMPANY_MASTER WITH (NOLOCK)
    WHERE UPPER(Domain_Name) = UPPER(@Domain_Name)) BEGIN
    SET @Cmp_Id = -1
    RETURN
  END

  
  SELECT @Cmp_Id = ISNULL(MAX(Cmp_Id), 0)+1
  FROM dbo.T0010_COMPANY_MASTER WITH (NOLOCK)
  
  EXEC P0020_STATE_MASTER_DEFAULT @Cmp_Id
  SELECT @State_Id = State_Id, @CMP_State_Name = STATE_NAME FROM T0020_STATE_MASTER WITH (NOLOCK) WHERE cmp_id=@Cmp_Id AND UPPER(State_Name)=UPPER(@State)
  
  INSERT INTO dbo.T0010_COMPANY_MASTER(Cmp_Id, Cmp_Name, Cmp_Address, Cmp_City, Cmp_PinCode, Cmp_Phone, Cmp_Email, Cmp_Web, Date_Format, From_Date, To_Date, PF_No, ESIC_No, Domain_Name, Image_name, Loc_ID, Default_Holiday, Cmp_Pan_No, Cmp_tan_no, Is_Organise_chart, Image_file_Path, Cmp_Code, Is_Auto_Alpha_Numeric_Code, No_Of_Digit_Emp_Code, Cmp_Signature, is_GroupOFCmp, is_Main, is_Organo_designationwise, cmp_logo, Inout_Duration, Is_Alpha_Numeric_Branchwise, Is_Contractor_Company, Is_CompanyWise, Is_DateWise, Is_JoiningDateWise, DateFormat, Reset_Sequance, CMP_STATE_NAME, Cmp_HR_Manager, Cmp_HR_Manager_Desig, Max_Emp_Code, Sample_Emp_Code, Is_Desig, Is_Cate, Is_Emptype, Is_DateofBirth, Is_Current_Date, DateFormat_Birth, DateFormat_Current, State_ID, PfTrustNo, Is_Pf_Applicable, Is_ESIC_APPLICABLE, Alt_W_Name, Alt_W_Full_Day_Cont, Cmp_Header, Cmp_Footer, GST, GST_No, GST_Cmp_Name, LWF_Number)
  VALUES(@Cmp_Id, @Cmp_Name, @Cmp_Address, @Cmp_City, @Cmp_PinCode, @Cmp_Phone, @Cmp_Email, @Cmp_Web, @Date_Format, @From_Date, @To_Date, @PF_No, @ESIC_No, @Domain_Name, @Image_Name, @Loc_ID, @Default_Holiday, @pan_No, @Tan_No, @Is_Organise_chart, @Image_file_path, @Cmp_Code, @Is_Auto_Alpha_Numeric_Code, @No_Of_Digit_Emp_Code, @Cmp_Signature, @is_GroupOFCmp, @is_Main, @Is_Organo_designationwise, @ImageObj, @Inout_Duration, @Is_Alpha_Numeric_Branchwise, @Is_Contractor_Company, @Is_Company_Wise, @Is_Date_Wise, @Is_JoiningDate_Wise, @DateFormat, @is_Reset_Sequance, @CMP_State_Name, @cmp_Hr_Manager, @Cmp_Hr_Manager_Desig, @Max_Emp_Code, @Sample_Emp_Code, @Is_Desig, @Is_Cate, @Is_EmpType, @Is_DateofBirth, @Is_Current_Date, @DateFormat_Birth, @DateFormat_Current, @State_Id, @PfTrustNo, @Is_Pf_Applicable, @Is_ESIC_APPLICABLE, @Alt_W_Name, @Alt_W_Full_Day_Cont, @Cmp_Header, @Cmp_Footer, @GST, @GST_No, @GST_Cmp_Name, @LWF_Number)

  INSERT INTO dbo.T0011_COMPANY_DETAIL(CMP_ID, CMP_NAME, CMP_ADDRESS, EFFECT_DATE)
  VALUES(@Cmp_Id, @Cmp_Name, @Cmp_Address, @From_Date)

  DECLARE @Row_ID NUMERIC
  DECLARE @fordate VARCHAR(11)
  SET @fordate = GETDATE()
  SELECT @Row_ID = ISNULL(MAX(Row_ID), 0) + 1 FROM T0012_COMPANY_CRT_LOGIN_MASTER WITH (NOLOCK)

  INSERT INTO T0012_COMPANY_CRT_LOGIN_MASTER(Row_ID, Cmp_Id, Create_date)
  VALUES(@Row_ID, @Cmp_Id, @fordate)

  SET @loginname = 'admin' + @Domain_Name
  EXEC p0011_Login @Login_ID OUTPUT, @Cmp_Id, @loginname, 'VuMs/PGYS74=', NULL, NULL, NULL, 'I', 1

  DELETE FROM dbo.T0090_EMP_PRIVILEGE_DETAILS WHERE Login_Id = @Login_ID

  EXEC P0040_LICENSE_MASTER 0, @Cmp_Id, 'Driving', '', 'I'
  EXEC P0040_LICENSE_MASTER 0, @Cmp_Id, 'Rifle', '', 'I'

  
  DECLARE @l_id AS INTEGER
  SET @l_id = (SELECT Loc_ID FROM T0001_LOCATION_MASTER WITH (NOLOCK) WHERE Loc_name = 'india') DECLARE @Branch_ID AS NUMERIC(18, 0)

  EXEC P0030_BRANCH_MASTER @Branch_ID OUTPUT, @Cmp_Id, @State_Id, 'HO', 'Head Office', @Cmp_City, '', '', 'I', 0, 0, '', @l_id
  EXEC p0040_grade_master 0, @Cmp_Id, 0, 'MANAGEMENT', 'MANAGEMENT', 0, 'I', 0, 0, 0, ''
  EXEC p0040_designation_master @Desig_ID = 0, @Cmp_Id = @Cmp_Id, @Desig_Name = 'MANAGER', @Desig_Dis_No = 0, @Def_ID = 0, @Parent_ID = NULL, @is_Main = 0, @tran_type = 'I', @Desig_Code = 'MNGR'
  EXEC P0040_QUALIFICATION_MASTER 0, @Cmp_Id, 'Aviation', 'I'
  EXEC P0040_QUALIFICATION_MASTER 0, @Cmp_Id, 'B.A', 'I'
  EXEC P0040_QUALIFICATION_MASTER 0, @Cmp_Id, 'B.Arch', 'I'
  EXEC P0040_QUALIFICATION_MASTER 0, @Cmp_Id, 'B.B.A', 'I'
  EXEC P0040_QUALIFICATION_MASTER 0, @Cmp_Id, 'BCA', 'I'
  EXEC P0040_QUALIFICATION_MASTER 0, @Cmp_Id, 'B.Com', 'I'
  EXEC P0040_QUALIFICATION_MASTER 0, @Cmp_Id, 'BDS', 'I'
  EXEC P0040_QUALIFICATION_MASTER 0, @Cmp_Id, 'B.E/B.Tech', 'I'
  EXEC P0040_QUALIFICATION_MASTER 0, @Cmp_Id, 'B.Ed', 'I'
  EXEC P0040_QUALIFICATION_MASTER 0, @Cmp_Id, 'BHM', 'I'
  EXEC P0040_QUALIFICATION_MASTER 0, @Cmp_Id, 'BL/LLB', 'I'
  EXEC P0040_QUALIFICATION_MASTER 0, @Cmp_Id, 'B.Pharm', 'I'
  EXEC P0040_QUALIFICATION_MASTER 0, @Cmp_Id, 'B.Sc', 'I'
  EXEC P0040_QUALIFICATION_MASTER 0, @Cmp_Id, 'CA', 'I'
  EXEC P0040_QUALIFICATION_MASTER 0, @Cmp_Id, 'Class 12', 'I'
  EXEC P0040_QUALIFICATION_MASTER 0, @Cmp_Id, 'CS', 'I'
  EXEC P0040_QUALIFICATION_MASTER 0, @Cmp_Id, 'Diploma', 'I'
  EXEC P0040_QUALIFICATION_MASTER 0, @Cmp_Id, 'ICWA', 'I'
  EXEC P0040_QUALIFICATION_MASTER 0, @Cmp_Id, 'M.A', 'I'
  EXEC P0040_QUALIFICATION_MASTER 0, @Cmp_Id, 'M.Arch', 'I'
  EXEC P0040_QUALIFICATION_MASTER 0, @Cmp_Id, 'MBA', 'I'
  EXEC P0040_QUALIFICATION_MASTER 0, @Cmp_Id, 'MBBS', 'I'
  EXEC P0040_QUALIFICATION_MASTER 0, @Cmp_Id, 'MCA', 'I'
  EXEC P0040_QUALIFICATION_MASTER 0, @Cmp_Id, 'M.Com', 'I'
  EXEC P0040_QUALIFICATION_MASTER 0, @Cmp_Id, 'MD/MS', 'I'
  EXEC P0040_QUALIFICATION_MASTER 0, @Cmp_Id, 'M.Ed', 'I'
  EXEC P0040_QUALIFICATION_MASTER 0, @Cmp_Id, 'M.E/M.Tech/MS', 'I'
  EXEC P0040_QUALIFICATION_MASTER 0, @Cmp_Id, 'ML/LLM', 'I'
  EXEC P0040_QUALIFICATION_MASTER 0, @Cmp_Id, 'M.Pharm', 'I'
  EXEC P0040_QUALIFICATION_MASTER 0, @Cmp_Id, 'Mphil', 'I'
  EXEC P0040_QUALIFICATION_MASTER 0, @Cmp_Id, 'M.Sc', 'I'
  EXEC P0040_QUALIFICATION_MASTER 0, @Cmp_Id, 'PGDCA', 'I'
  EXEC P0040_QUALIFICATION_MASTER 0, @Cmp_Id, 'PG Diploma', 'I'
  EXEC P0040_QUALIFICATION_MASTER 0, @Cmp_Id, 'PGDM', 'I'
  EXEC P0040_QUALIFICATION_MASTER 0, @Cmp_Id, 'Phd', 'I'
  EXEC P0040_QUALIFICATION_MASTER 0, @Cmp_Id, 'Other', 'I'

  EXEC P0040_BANK_MASTER 0, @Cmp_Id, 'BOB', 'Bank of Baroda', '', '', '', '', 0, 'I', ''
  EXEC P0040_BANK_MASTER 0, @Cmp_Id, 'BOI', 'Bank of India', '', '', '', '', 0, 'I', ''
  EXEC P0040_BANK_MASTER 0, @Cmp_Id, 'HDFC', 'HDFC Bank', '', '', '', '', 0, 'I', ''
  EXEC P0040_BANK_MASTER 0, @Cmp_Id, 'ICICI', 'ICICI Bank', '', '', '', '', 0, 'I', ''
  EXEC P0040_BANK_MASTER 0, @Cmp_Id, 'AXIS', 'AXIS Bank', '', '', '', '', 0, 'I', ''
  EXEC P0040_BANK_MASTER 0, @Cmp_Id, 'IDBI', 'IDBI Bank', '', '', '', '', 0, 'I', ''
  EXEC P0040_BANK_MASTER 0, @Cmp_Id, 'SBI', 'State Bank of India', '', '', '', '', 0, 'I', ''
  EXEC P0040_SKILL_MASTER 0, 'COMMUNICATION', @Cmp_Id, '', 'I'
  EXEC P0040_SKILL_MASTER 0, 'MARKETING', @Cmp_Id, '', 'I'
  EXEC P0040_SKILL_MASTER 0, 'MANAGEMENT', @Cmp_Id, '', 'I'


  EXEC P0040_LANGUAGE_MASTER 0, @Cmp_Id, 'ENGLISH', 'I'
  EXEC P0040_LANGUAGE_MASTER 0, @Cmp_Id, 'HINDI', 'I'
  EXEC P0040_LANGUAGE_MASTER 0, @Cmp_Id, 'GUJARATI', 'I'
  EXEC P0040_LANGUAGE_MASTER 0, @Cmp_Id, 'MARATHI', 'I'
  EXEC P0040_LANGUAGE_MASTER 0, @Cmp_Id, 'TAMIL', 'I'
  EXEC P0040_LANGUAGE_MASTER 0, @Cmp_Id, 'BENGALI', 'I'
  EXEC P0040_LANGUAGE_MASTER 0, @Cmp_Id, 'PUNJABI', 'I'

  EXEC p0040_CURRENCY_MASTER 0, @Cmp_Id, 'Rupees', 0, '', 'Rs.', '', 'I'
  EXEC P0040_DOCUMENT_MASTER 0, @Cmp_Id, 'EDUCATION CERTIFICATE', '', 'I'
  EXEC P0040_DOCUMENT_MASTER 0, @Cmp_Id, 'ACHIVEMENT CERTIFICATE', '', 'I'

  EXEC p0040_shift_master 0, @Cmp_Id, 'General Shift', '09:00', '17:00', '08:00', '09:00', '17:00', '08:00', '00:00', '00:00', '00:00', '00:00', '00:00', '00:00', 'I'

  DECLARE @EMAIL_NTF_ID NUMERIC
  SELECT @EMAIL_NTF_ID = ISNULL(MAX(EMAIL_NTF_ID), 0) + 1 FROM T0040_Email_Notification_Config WITH (NOLOCK)

  EXEC P0040_EmailNotificaiton_Config 0, 'Leave Application', @Cmp_Id, 0, 2, 'I'
  EXEC P0040_EmailNotificaiton_Config 0, 'Leave Approval', @Cmp_Id, 0, 3, 'I'
  EXEC P0040_EmailNotificaiton_Config 0, 'Loan Application', @Cmp_Id, 0, 4, 'I'
  EXEC P0040_EmailNotificaiton_Config 0, 'Loan Approval', @Cmp_Id, 0, 5, 'I'
  EXEC P0040_EmailNotificaiton_Config 0, 'Loan Payment', @Cmp_Id, 0, 6, 'I'
  EXEC P0040_EmailNotificaiton_Config 0, 'Appraisal Initiation', @Cmp_Id, 0, 7, 'I'
  EXEC P0040_EmailNotificaiton_Config 0, 'Claim Approval', @Cmp_Id, 0, 8, 'I'
  EXEC P0040_EmailNotificaiton_Config 0, 'Claim Payment', @Cmp_Id, 0, 9, 'I'
  EXEC P0040_EmailNotificaiton_Config 0, 'Claim Application', @Cmp_Id, 0, 10, 'I'
  EXEC P0040_EmailNotificaiton_Config 0, 'Appraisal Approval', @Cmp_Id, 0, 11, 'I'
  EXEC P0040_EmailNotificaiton_Config 0, 'Recruitment Approval', @Cmp_Id, 0, 12, 'I'
  EXEC P0040_EmailNotificaiton_Config 0, 'Interview Schedule', @Cmp_Id, 0, 13, 'I'
  EXEC P0040_EmailNotificaiton_Config 0, 'Forget Password', @Cmp_Id, 1, 15, 'I'
  EXEC P0040_EmailNotificaiton_Config 0, 'GatePass', @Cmp_Id, 1, 81, 'I'
  EXEC P0040_WEEKOFF_MASTER 0, @Cmp_Id, 0, 'Sunday', 1, @Login_ID, 'I'
  EXEC P0040_WEEKOFF_MASTER 0, @Cmp_Id, 0, 'Monday', 1, @Login_ID, 'I'
  EXEC P0040_WEEKOFF_MASTER 0, @Cmp_Id, 0, 'Tuesday', 1, @Login_ID, 'I'
  EXEC P0040_WEEKOFF_MASTER 0, @Cmp_Id, 0, 'Wednesday', 1, @Login_ID, 'I'
  EXEC P0040_WEEKOFF_MASTER 0, @Cmp_Id, 0, 'Thursday', 1, @Login_ID, 'I'
  EXEC P0040_WEEKOFF_MASTER 0, @Cmp_Id, 0, 'Friday', 1, @Login_ID, 'I'
  EXEC P0040_WEEKOFF_MASTER 0, @Cmp_Id, 0, 'Saturday', 1, @Login_ID, 'I'
  EXEC GuestUsers @Cmp_Id, @Domain_Name
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2019-04-01', 'M', 1, 250000, 0, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 1'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2019-04-01', 'M', 250001, 500000, 5, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 1'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2019-04-01', 'M', 500001, 1000000, 20, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 1'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2019-04-01', 'M', 1000001, 999999999, 30, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 1'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2019-04-01', 'F', 1, 250000, 0, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 1'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2019-04-01', 'F', 250001, 500000, 5, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 1'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2019-04-01', 'F', 500001, 1000000, 20, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 1'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2019-04-01', 'F', 1000001, 999999999, 30, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 1'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2019-04-01', 'S', 1, 300000, 0, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 1'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2019-04-01', 'S', 300001, 500000, 5, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 1'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2019-04-01', 'S', 500001, 1000000, 20, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 1'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2019-04-01', 'S', 1000001, 999999999, 30, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 1'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2019-04-01', 'V', 1, 500000, 0, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 1'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2019-04-01', 'V', 500001, 1000000, 20, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 1'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2019-04-01', 'V', 1000001, 999999999, 30, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 1'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2020-04-01', 'M', 1, 250000, 0, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 1'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2020-04-01', 'M', 250001, 500000, 5, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 1'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2020-04-01', 'M', 500001, 1000000, 20, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 1'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2020-04-01', 'M', 1000001, 999999999, 30, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 1'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2020-04-01', 'F', 1, 250000, 0, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 1'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2020-04-01', 'F', 250001, 500000, 5, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 1'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2020-04-01', 'F', 500001, 1000000, 20, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 1'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2020-04-01', 'F', 1000001, 999999999, 30, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 1'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2020-04-01', 'S', 1, 300000, 0, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 1'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2020-04-01', 'S', 300001, 500000, 5, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 1'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2020-04-01', 'S', 500001, 1000000, 20, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 1'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2020-04-01', 'S', 1000001, 999999999, 30, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 1'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2020-04-01', 'V', 1, 500000, 0, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 1'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2020-04-01', 'V', 500001, 1000000, 20, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 1'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2020-04-01', 'V', 1000001, 999999999, 30, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 1'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2020-04-01', 'M', 1, 250000, 0, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 2'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2020-04-01', 'M', 250001, 500000, 5, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 2'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2020-04-01', 'M', 500001, 750000, 10, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 2'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2020-04-01', 'M', 750001, 1000000, 15, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 2'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2020-04-01', 'M', 1000001, 1250000, 20, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 2'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2020-04-01', 'M', 1250001, 1500000, 25, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 2'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2020-04-01', 'M', 1500001, 999999999, 30, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 2'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2020-04-01', 'F', 1, 250000, 0, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 2'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2020-04-01', 'F', 250001, 500000, 5, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 2'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2020-04-01', 'F', 500001, 750000, 10, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 2'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2020-04-01', 'F', 750001, 1000000, 15, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 2'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2020-04-01', 'F', 1000001, 1250000, 20, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 2'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2020-04-01', 'F', 1250001, 1500000, 25, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 2'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2020-04-01', 'F', 1500001, 999999999, 30, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 2'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2020-04-01', 'S', 1, 300000, 0, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 2'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2020-04-01', 'S', 300001, 500000, 5, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 2'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2020-04-01', 'S', 500001, 750000, 10, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 2'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2020-04-01', 'S', 750001, 1000000, 15, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 2'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2020-04-01', 'S', 1000001, 1250000, 20, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 2'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2020-04-01', 'S', 1250001, 1500000, 25, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 2'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2020-04-01', 'S', 1500001, 999999999, 30, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 2'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2020-04-01', 'V', 1, 500000, 0, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 2'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2020-04-01', 'V', 500001, 750000, 10, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 2'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2020-04-01', 'V', 750001, 1000000, 15, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 2'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2020-04-01', 'V', 1000001, 1250000, 20, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 2'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2020-04-01', 'V', 1250001, 1500000, 25, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 2'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2020-04-01', 'V', 1500001, 999999999, 30, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 2'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2023-04-01', 'M', 1, 300000, 0, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 2'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2023-04-01', 'M', 300001, 600000, 5, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 2'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2023-04-01', 'M', 600001, 900000, 10, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 2'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2023-04-01', 'M', 900001, 1200000, 15, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 2'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2023-04-01', 'M', 1200001, 1500000, 20, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 2'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2023-04-01', 'M', 1500001, 999999999, 30, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 2'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2023-04-01', 'F', 1, 300000, 0, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 2'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2023-04-01', 'F', 300001, 600000, 5, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 2'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2023-04-01', 'F', 600001, 900000, 10, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 2'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2023-04-01', 'F', 900001, 1200000, 15, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 2'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2023-04-01', 'F', 1200001, 1500000, 20, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 2'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2023-04-01', 'F', 1500001, 999999999, 30, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 2'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2023-04-01', 'S', 1, 300000, 0, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 2'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2023-04-01', 'S', 300001, 600000, 5, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 2'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2023-04-01', 'S', 600001, 900000, 10, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 2'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2023-04-01', 'S', 900001, 1200000, 15, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 2'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2023-04-01', 'S', 1200001, 1500000, 20, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 2'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2023-04-01', 'S', 1500001, 999999999, 30, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 2'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2023-04-01', 'V', 1, 300000, 0, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 2'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2023-04-01', 'V', 300001, 600000, 5, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 2'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2023-04-01', 'V', 600001, 900000, 10, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 2'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2023-04-01', 'V', 900001, 1200000, 15, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 2'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2023-04-01', 'V', 1200001, 1500000, 20, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 2'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2023-04-01', 'V', 1500001, 999999999, 30, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 2'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2023-04-01', 'M', 1, 250000, 0, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 1'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2023-04-01', 'M', 250001, 500000, 5, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 1'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2023-04-01', 'M', 500001, 1000000, 20, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 1'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2023-04-01', 'M', 1000001, 999999999, 30, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 1'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2023-04-01', 'F', 1, 250000, 0, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 1'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2023-04-01', 'F', 250001, 500000, 5, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 1'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2023-04-01', 'F', 500001, 1000000, 20, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 1'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2023-04-01', 'F', 1000001, 999999999, 30, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 1'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2023-04-01', 'S', 1, 300000, 0, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 1'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2023-04-01', 'S', 300001, 500000, 5, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 1'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2023-04-01', 'S', 500001, 1000000, 20, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 1'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2023-04-01', 'S', 1000001, 999999999, 30, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 1'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2023-04-01', 'V', 1, 500000, 0, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 1'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2023-04-01', 'V', 500001, 1000000, 20, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 1'
  EXEC [P0040_TAX_LIMIT] 0, @Cmp_Id, '2023-04-01', 'V', 1000001, 999999999, 30, 0, NULL, 'I', NULL, 'By Default', 'Tax Regime 1'



  EXEC P0040_Form_Master 0, @Cmp_Id, 'Income Tax', 0, '', @fordate, @Login_ID, 'I'

  DECLARE @Loc_Name AS VARCHAR(100)
  DECLARE @Fin_year AS VARCHAR(20)

  SELECT @Loc_Name = Loc_name
  FROM T0001_LOCATION_MASTER WITH (NOLOCK)
  WHERE Loc_ID = @Loc_ID

  IF MONTH(@From_Date) > 3 BEGIN
    SET @Fin_year =  CAST(DATENAME(YYYY, @From_Date) AS VARCHAR(10)) + '-' + CAST(DATENAME(YYYY, @From_Date)+ 1 AS VARCHAR(10))
  END
  ELSE BEGIN
    SET @Fin_year =  CAST(DATENAME(YYYY, @From_Date) - 1 AS VARCHAR(10)) + '-' + CAST(DATENAME(YYYY, @From_Date) AS VARCHAR(10))
  END

  IF UPPER(@Loc_Name) = 'PAKISTAN' BEGIN
    EXEC P0100_IT_FORM_DESIGN_DEFAULT_Pak @Cmp_Id, @Fin_year
  END
  ELSE BEGIN
    EXEC P0070_IT_MASTER_DEFAULT @Cmp_Id, @Login_ID
    EXEC P0100_IT_FORM_DESIGN_DEFAULT @Cmp_Id, @Fin_year, @Login_ID
  END

  EXEC [P0040_LEAVE_MASTER] 0, @Cmp_Id, 'LWP', 'LWP', '--', 0, 'U', 0, 0, 0, 0, 0, 0, 0, 0, 'None', 0, 0, 'M', 0, 'Ins', 0, 1, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1, 1, 0, 0, 0, 0, 'LWP'
  EXEC [P0040_LEAVE_MASTER] 0, @Cmp_Id, 'COMP', 'Comp-Off Leave', '--', 0, 'P', 0, 0, 0, 0, 0, 0, 0, 0, 'None', 0, 0, 'M', 0, 'Ins', 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1, 1, 0, 0, 0, 0, 'COMP'
  EXEC Insert_Default_Settings @Cmp_Id
  EXEC Insert_Default_Display_Fields @Cmp_Id
  EXEC Insert_Default_Mail_Settings_New @Cmp_Id
  EXEC Insert_Default_Mandatory_Fields @Cmp_Id
  EXEC Update_Default_Mail_Settings_New @Cmp_Id
  EXEC P0011_module_detail 0, 'Appraisal1', @Cmp_Id, 0
  EXEC P0011_module_detail 0, 'Appraisal2', @Cmp_Id, 0
  EXEC P0011_module_detail 0, 'Appraisal3', @Cmp_Id, 0
  EXEC P0011_module_detail 0, 'MOBILE', @Cmp_Id, 0
  EXEC P0011_module_detail 0, 'GPF', @Cmp_Id, 0
  EXEC P0011_module_detail 0, 'CPS', @Cmp_Id, 0
  EXEC P0011_module_detail 0, 'Payroll', @Cmp_Id, 1
  EXEC P0011_module_detail 0, 'Timesheet', @Cmp_Id, 0
  EXEC P0011_module_detail 0, 'Transport', @Cmp_Id, 0
  EXEC P0011_module_detail 0, 'Task', @Cmp_Id, 0


  DECLARE @per_tran_id AS NUMERIC
  SET @per_tran_id = 0

  SELECT @per_tran_id = ISNULL(MAX(Perquisites_Id), 0) FROM T0240_Perquisites_Master WITH (NOLOCK)

  INSERT INTO [dbo].[T0240_Perquisites_Master]([Perquisites_Id], [Cmp_id], [Name], [Sort_Name], [Sorting_no], [Def_id], [Remarks])
  SELECT @per_tran_id + 1, @Cmp_Id, N'Accommodation', N'RFA', 1, 0, NULL
  UNION ALL
  SELECT @per_tran_id + 2, @Cmp_Id, N'Cars / Other automotive', N'Car', 2, 0, NULL
  UNION ALL
  SELECT @per_tran_id + 3, @Cmp_Id, N'Sweeper, gardener, watchman or personal attendant', N'Clerk', 3, 0, NULL
  UNION ALL
  SELECT @per_tran_id + 4, @Cmp_Id, N'Gas, electricity, water', N'Facilities', 4, 0, NULL
  UNION ALL
  SELECT @per_tran_id + 5, @Cmp_Id, N'Interest free or concessional Loans', N'Interest', 5, 0, NULL
  UNION ALL
  SELECT @per_tran_id + 6, @Cmp_Id, N'Holiday expenses', N'Holiday', 6, 0, NULL
  UNION ALL
  SELECT @per_tran_id + 7, @Cmp_Id, N'Free or concessional travel', N'Travel', 7, 0, NULL
  UNION ALL
  SELECT @per_tran_id + 8, @Cmp_Id, N'Free meals', N'Meals', 8, 0, NULL
  UNION ALL
  SELECT @per_tran_id + 9, @Cmp_Id, N'Free Education', N'Education', 9, 0, NULL
  UNION ALL
  SELECT @per_tran_id + 10, @Cmp_Id, N'Gifts, vouchers etc', N'Gift', 10, 0, NULL
  UNION ALL
  SELECT @per_tran_id + 11, @Cmp_Id, N'Credit card expenses', N'Credit', 11, 0, NULL
  UNION ALL
  SELECT @per_tran_id + 12, @Cmp_Id, N'Club expenses', N'Club', 12, 0, NULL
  UNION ALL
  SELECT @per_tran_id + 13, @Cmp_Id, N'Use of movable assets by employees', N'Assets', 13, 0, NULL
  UNION ALL
  SELECT @per_tran_id + 14, @Cmp_Id, N'Transfer of assets to employees', N'TAssets ', 14, 0, NULL
  UNION ALL
  SELECT @per_tran_id + 15, @Cmp_Id, N'Value of any other benefit / amenity / service / privilege', N'Benefits', 15, 0, NULL
  UNION ALL
  SELECT @per_tran_id + 16, @Cmp_Id, N'Stock options (non-qualified options)', N'Stock', 16, 0, NULL
  UNION ALL
  SELECT @per_tran_id + 17, @Cmp_Id, N'Other benefits or amenities', N'Other', 17, 0, NULL

  DECLARE @Status_ID NUMERIC
  SELECT @Status_ID = ISNULL(MAX(Project_Status_ID), 0) + 1
  FROM T0040_Project_Status WITH (NOLOCK)
  INSERT INTO [T0040_Project_Status](Project_Status_ID, [Project_Status], [Remarks], [Cmp_ID], [Created_Date])
  VALUES(@Status_ID, 'Pending', 'Pending', @Cmp_Id, GETDATE())

  SELECT @Status_ID = ISNULL(MAX(Project_Status_ID), 0) + 1
  FROM T0040_Project_Status WITH (NOLOCK)
  INSERT INTO [T0040_Project_Status](Project_Status_ID, [Project_Status], [Remarks], [Cmp_ID], [Created_Date])
  VALUES(@Status_ID, 'Approved', 'Approved', @Cmp_Id, GETDATE())

  SELECT @Status_ID = ISNULL(MAX(Project_Status_ID), 0) + 1
  FROM T0040_Project_Status WITH (NOLOCK)
  INSERT INTO [T0040_Project_Status](Project_Status_ID, [Project_Status], [Remarks], [Cmp_ID], [Created_Date])
  VALUES(@Status_ID, 'Rejected', 'Rejected', @Cmp_Id, GETDATE())


  DECLARE @TransportDesig NUMERIC(18, 0)
  SELECT @TransportDesig = ISNULL(MAX(Designation_ID), 0) + 1
  FROM T0040_DESIGNATION_MASTER_TRANSPORT WITH (NOLOCK)
  INSERT INTO T0040_DESIGNATION_MASTER_TRANSPORT(Designation_ID, Designation_Name, Designation_Code)
  VALUES(@TransportDesig, 'Driver', 'Driver')

  SELECT @TransportDesig = ISNULL(MAX(Designation_ID), 0) + 1
  FROM T0040_DESIGNATION_MASTER_TRANSPORT WITH (NOLOCK)
  INSERT INTO T0040_DESIGNATION_MASTER_TRANSPORT(Designation_ID, Designation_Name, Designation_Code)
  VALUES(@TransportDesig, 'Extra Driver', 'Extra Driver')

  SELECT @TransportDesig = ISNULL(MAX(Designation_ID), 0) + 1
  FROM T0040_DESIGNATION_MASTER_TRANSPORT WITH (NOLOCK)
  INSERT INTO T0040_DESIGNATION_MASTER_TRANSPORT(Designation_ID, Designation_Name, Designation_Code)
  VALUES(@TransportDesig, 'Conductor', 'Conductor')

  

  EXEC P0040_PROFESSIONAL_SETTING_With_state_Map @Branch_ID, @State_Id
  

END
ELSE IF @tran_type ='U' BEGIN

  SELECT @State_Id=State_Id, @CMP_State_Name = STATE_NAME
  FROM T0020_STATE_MASTER WITH (NOLOCK)
  WHERE cmp_id=@Cmp_Id AND UPPER(State_Name)=UPPER(@State)

  IF EXISTS (SELECT Cmp_ID
      FROM dbo.T0010_COMPANY_MASTER WITH (NOLOCK)
    WHERE UPPER(Cmp_Name)=UPPER(@Cmp_Name) AND Cmp_ID <> @Cmp_Id) BEGIN
    SET @Cmp_Id = 0
    RETURN
  END
  ELSE IF EXISTS (SELECT Cmp_ID
      FROM dbo.T0010_COMPANY_MASTER WITH (NOLOCK)
    WHERE UPPER(Domain_Name) = UPPER(@Domain_Name) AND Cmp_ID <> @Cmp_Id) BEGIN
    SET @Cmp_Id = -1
    RETURN
  END

  DECLARE @old_image_file AS NVARCHAR(1000)
  SELECT @Prv_Domain_Name = Domain_Name, @old_image_file = Image_file_Path
  FROM dbo.T0010_COMPANY_MASTER WITH (NOLOCK)
  WHERE Cmp_ID = @Cmp_Id

  IF ISNULL(@Image_file_path, '') = '' BEGIN
    SET @Image_file_path = @old_image_file
  END

  IF @Has_Digital_Certi = 0 BEGIN
    UPDATE dbo.T0010_COMPANY_MASTER
    SET Digital_Certi_FileName = NULL,
    Digital_Certi_Password = NULL
    WHERE Cmp_Id =@Cmp_Id
  END

  SELECT @Old_Cmp_Name = Cmp_Name, @Old_Cmp_Address = Cmp_Address, @Old_Cmp_City = Cmp_City, @Old_Cmp_PinCode = Cmp_PinCode, @Old_Cmp_Phone   = Cmp_Phone, @Old_Cmp_Email   = Cmp_Email, @Old_Cmp_Web     = Cmp_Web, @Old_From_Date   = From_Date, @Old_To_Date = To_Date, @Old_PF_No = PF_No, @Old_ESIC_No = ESIC_No, @Old_Domain_Name = Domain_Name, @Old_Loc_ID = Loc_ID, @Old_Default_Holiday = Default_Holiday, @Old_pan_No = Cmp_PAN_No, @Old_Tan_No = Cmp_TAN_No, @Old_Cmp_Code = Cmp_Code, @Old_Is_Auto_Alpha_Numeric_Code = Is_Auto_Alpha_Numeric_Code, @Old_No_Of_Digit_Emp_Code = No_Of_Digit_Emp_Code, @Old_Inout_Duration = Inout_Duration, @Old_Is_Contractor_Company = Is_Contractor_Company, @Old_Is_Alpha_Numeric_Branchwise = Is_Alpha_Numeric_Branchwise, @Old_Is_Organo_designationwise = is_Organo_designationwise, @Old_Has_Digital_Certi = Has_Digital_Certi, @Old_Is_Company_Wise = Is_CompanyWise, @Old_Is_Date_Wise = Is_DateWise, @Old_Is_JoiningDate_Wise = Is_JoiningDateWise, @Old_DateFormat = DateFormat, @Old_is_Reset_Sequance = Reset_Sequance, @Old_cmp_Hr_Manager =cmp_hr_manager, @Old_Cmp_Hr_Manager_Desig =Cmp_HR_Manager_Desig, @Old_Max_Emp_Code = Max_Emp_Code, @Old_Sample_Emp_Code = Sample_Emp_Code, @Old_Is_Desig = Is_Desig, @Old_Is_Cate = Is_Cate, @Old_Is_EmpType = Is_EmpType, @Old_Is_DateofBirth = Is_DateofBirth, @Old_Is_Current_Date = Is_Current_Date, @Old_DateFormat_Birth = DateFormat_Birth, @Old_DateFormat_Current = DateFormat_Current, @Old_Is_Pf_Applicable=Is_Pf_Applicable, @Old_Is_ESIC_APPLICABLE=Is_ESIC_APPLICABLE, @Old_Alt_W_Name = Alt_W_Name, @Old_Alt_W_Full_Day_Cont = Alt_W_Full_Day_Cont, @Cmp_Header = Cmp_Header, @Cmp_Footer = Cmp_Footer
  FROM T0010_COMPANY_MASTER WITH (NOLOCK)
  WHERE Cmp_Id =@Cmp_Id
  SET @Old_Location_Name = (SELECT Loc_name FROM T0001_Location_Master WITH (NOLOCK) WHERE Loc_ID = @Old_Loc_ID) UPDATE dbo.T0010_COMPANY_MASTER
  SET Cmp_City    = @Cmp_City
  , Cmp_PinCode = @Cmp_PinCode
  , Cmp_Phone   = @Cmp_Phone
  , Cmp_Email   = @Cmp_Email
  , Cmp_Web     = @Cmp_Web
  , [Date_Format] = @Date_Format
  , From_Date   = @From_Date
  , To_Date = @To_Date
  , PF_No = @PF_No
  , ESIC_No = @ESIC_No
  , Domain_Name = @Domain_Name
  , Loc_ID = @Loc_ID
  , Default_Holiday = @Default_Holiday
  , Cmp_Pan_No = @pan_No
  , Cmp_Tan_No =@Tan_No
  , Is_Organise_chart = @Is_Organise_chart
  , Image_file_Path = @Image_file_path
  , Cmp_Code = @Cmp_Code
  , Is_Auto_Alpha_Numeric_Code=@Is_Auto_Alpha_Numeric_Code
  , is_Organo_designationwise =@Is_Organo_designationwise
  , No_Of_Digit_Emp_Code = @No_Of_Digit_Emp_Code
  , Cmp_Signature = @Cmp_Signature
  , is_GroupOFCmp = @is_GroupOFCmp
  , is_Main = @is_Main
  , Inout_Duration = @Inout_Duration
  , Is_Alpha_Numeric_Branchwise = @Is_Alpha_Numeric_Branchwise
  , Is_Contractor_Company = @Is_Contractor_Company  
  , Has_Digital_Certi = @Has_Digital_Certi    
  , tax_manager_form_16 = @taxmanagerform16    
  , father_name_form_16 = @FathernameForm16    
  , Designation_manager_Form_16 = @Desigmanagerform16    
  , cit_Address = @CitAddress    
  , Cit_City = @CITcity    
  , Cit_pin = @Citpin    
  , Date_Form_16_Submit = @Dateform16submit    
  , License_No = @Cmp_LicenseNo
  , Registration_No = @Cmp_RegistrationNo
  , Nature_of_Business = @Cmp_NatureOfBusiness
  , Date_Of_Establishment = @Date_Of_Establishment
  , Factory_Type = @Factory_Type
  , License_Office = @License_Office
  , Is_CompanyWise = @Is_Company_Wise  
  , Is_DateWise = @Is_Date_Wise   
  , Is_JoiningDateWise = @Is_JoiningDate_Wise   
  , [DateFormat] = @DateFormat   
  , Reset_Sequance = @is_Reset_Sequance  
  , CMP_State_NAme = @CMP_State_Name
  , Cmp_HR_Manager = @cmp_Hr_Manager
  , Cmp_HR_Manager_Desig = @Cmp_Hr_Manager_Desig
  , Max_Emp_Code = @Max_Emp_Code
  , Sample_Emp_Code = @Sample_Emp_Code
  , Is_Desig = @Is_Desig
  , Is_Cate = @Is_Cate
  , Is_EmpType = @Is_EmpType
  , Is_DateofBirth = @Is_DateofBirth
  , Is_Current_Date = @Is_Current_Date
  , DateFormat_Birth = @DateFormat_Birth
  , DateFormat_Current = @DateFormat_Current
  , State_Id=@State_Id 
  , PfTrustNo = @PfTrustNo
  , Is_Pf_Applicable = @Is_Pf_Applicable 
  , Is_ESIC_APPLICABLE = @Is_ESIC_APPLICABLE 
  , Alt_W_Name = @Alt_W_Name 
  , Alt_W_Full_Day_Cont = @Alt_W_Full_Day_Cont 
  , Cmp_Header = @Cmp_Header
  , Cmp_Footer = @Cmp_Footer
  , Gst  = @GST  
  , Gst_No = @GST_No  
  , GST_Cmp_Name = @GST_Cmp_Name 
  , LWF_Number  = @LWF_Number  
  WHERE Cmp_Id =@Cmp_Id

  IF EXISTS (SELECT 1
      FROM T0040_SETTING WITH (NOLOCK)
    WHERE Setting_Name='Enable Effective Date Wise Company Name' AND Setting_Value=0 AND Cmp_ID=@Cmp_Id) DECLARE @MaxEffectiveDate AS DATETIME
  SET @MaxEffectiveDate=(SELECT MAX(Effect_Date)
      FROM T0011_COMPANY_DETAIL
    WHERE Cmp_id=@Cmp_Id) UPDATE dbo.T0010_COMPANY_MASTER
  SET Cmp_Name = @Cmp_Name, Cmp_Address = @Cmp_Address
  WHERE Cmp_Id =@Cmp_Id

  UPDATE T0011_COMPANY_DETAIL
  SET Cmp_Name=@Cmp_Name, Cmp_Address=@Cmp_Address
  WHERE Cmp_Id=@Cmp_Id AND Effect_Date=@MaxEffectiveDate

  IF @Prv_Domain_Name <> @Domain_Name BEGIN
    UPDATE T0011_login
    SET Login_Name = LEFT(login_Name, CHARINDEX('@', Login_Name, 1)-1)  + ''+ @Domain_Name
    WHERE Cmp_ID = @Cmp_Id AND CHARINDEX('@', Login_Name, 1) > 0
  END

  SET @New_Location_Name = (SELECT Loc_name
      FROM T0001_Location_Master WITH (NOLOCK)
    WHERE Loc_ID = @Loc_ID) SET @OldValue = 'old Value' + '#'+ 'Company Name :' + ISNULL(@Old_Cmp_Name, '')
  + '#' + 'Company Address :' + ISNULL(@Old_Cmp_Address, '')
  + '#' + 'City :' + ISNULL(@Old_Cmp_City, '')
  + '#' + 'Country :' + ISNULL(@Old_Location_Name, '')
  + '#' + 'Phone No  :' + ISNULL(@Old_Cmp_Phone, '')
  + '#' + 'Pin Code :' + ISNULL(@Old_Cmp_PinCode, '')
  + '#' + 'Email Address :' + ISNULL(@Old_Cmp_Email, '')
  + '#' + 'Website :' + ISNULL(@Old_Cmp_Web, '')
  + '#' + 'From Date :' + CAST(ISNULL(@Old_From_Date, '') AS NVARCHAR(11))
  + '#' + 'PF No :' + ISNULL(@Old_PF_No, '')
  + '#' + 'ESIC No :' + ISNULL(@Old_ESIC_No, '')
  + '#' + 'TAN No  :' + ISNULL(@Old_Tan_No, '')
  + '#' + 'PAN No :' + ISNULL(@Old_pan_No, '')
  + '#' + 'Domain Name :' + ISNULL(@Old_Domain_Name, '')
  + '#' + 'Company Code :' + ISNULL(@Old_Cmp_Code, '')
  + '#' + 'Digits For Emp Code :' + CONVERT(NVARCHAR(20), ISNULL(@Old_No_Of_Digit_Emp_Code, 0))
  + '#' + 'In-Out Duration (in Sec) :' + CONVERT(NVARCHAR(20), ISNULL(@Old_Inout_Duration, 0))
  + '#' + 'Alpha Numeric Code :' + CASE ISNULL(@Old_Is_Auto_Alpha_Numeric_Code, 0) WHEN 0 THEN 'N' ELSE 'Y' END
  + '#' + 'Contractor Company  :' + CASE ISNULL(@Old_Is_Contractor_Company, 0) WHEN 0 THEN 'N' ELSE 'Y' END
  + '#' + 'Branch abc wise Code   :' + CASE ISNULL(@Old_Is_Alpha_Numeric_Branchwise, 0) WHEN 0 THEN 'N' ELSE 'Y' END
  + '#' + 'Reporting Hierarchy Designation wise  :' + CASE ISNULL(@Old_Is_Organo_designationwise, 0) WHEN 0 THEN 'N' ELSE 'Y' END
  + '#' + 'Digital Signature :' + CASE ISNULL(@Old_Has_Digital_Certi, 0) WHEN 0 THEN 'N' ELSE 'Y' END
  + '#' + 'Select Week off day :' + ISNULL(@Old_Default_Holiday, '')
  + '#' + 'Comany wise Code :' + CASE ISNULL(@Old_Is_Company_Wise, 0) WHEN 0 THEN 'N' ELSE 'Y' END
  + '#' + 'Date wise Code :' + CASE ISNULL(@Old_Is_Date_Wise, 0) WHEN 0 THEN 'N' ELSE 'Y' END
  + '#' + 'Joining Date wise Code :' + CASE ISNULL(@Old_Is_JoiningDate_Wise, 0) WHEN 0 THEN 'N' ELSE 'Y' END
  + '#' + 'Date Format for Code :' + ISNULL(@Old_DateFormat, '')
  + '#' + 'Reset Sequance :' + CASE ISNULL(@Old_is_Reset_Sequance, 0) WHEN 0 THEN 'N' ELSE 'Y' END
  + '#' + 'Company Hr Manager :' + ISNULL(@Old_cmp_Hr_Manager, '')
  + '#' + 'Company Hr Manager Designation :' + ISNULL(@Old_Cmp_Hr_Manager_Desig, '')
  + '#' + 'Max Emp Code :' + ISNULL(@Old_Max_Emp_Code, '')
  + '#' + 'Sample Emp Code :' + ISNULL(@Old_Sample_Emp_Code, '')
  + '#' + 'Designation code :' + ISNULL(@Old_Is_Desig, '')
  + '#' + 'Category code :' + ISNULL(@Old_Is_Cate, '')
  + '#' + 'Emp Type code :' + ISNULL(@Old_Is_EmpType, '')
  + '#' + 'Code Date OF Birth :' + ISNULL(@Old_Is_DateofBirth, '')
  + '#' + 'Code Date OF Current :' + ISNULL(@Old_Is_Current_Date, '')
  + '#' + 'Code Date Format Birth :' + ISNULL(@Old_DateFormat_Birth, '')
  + '#' + 'Code Date Format Current :' + ISNULL(@Old_DateFormat_Current, '')
  + '#' +  'New Value' + '#'+ 'Company Name :' + ISNULL(@Cmp_Name, '')
  + '#' + 'Company Address :' + ISNULL(@Cmp_Address, '')
  + '#' + 'City :' + ISNULL(@Cmp_City, '')
  + '#' + 'Country :' + ISNULL(@New_Location_Name, '')
  + '#' + 'Phone No  :' + ISNULL(@Cmp_Phone, '')
  + '#' + 'Pin Code :' + ISNULL(@Cmp_PinCode, '')
  + '#' + 'Email Address :' + ISNULL(@Cmp_Email, '')
  + '#' + 'Website :' + ISNULL(@Cmp_Web, '')
  + '#' + 'From Date :' + CAST(ISNULL(@From_Date, '') AS NVARCHAR(11))
  + '#' + 'PF No :' + ISNULL(@PF_No, '')
  + '#' + 'ESIC No :' + ISNULL(@ESIC_No, '')
  + '#' + 'TAN No  :' + ISNULL(@Tan_No, '')
  + '#' + 'PAN No :' + ISNULL(@pan_No, '')
  + '#' + 'Domain Name :' + ISNULL(@Domain_Name, '')
  + '#' + 'Company Code :' + ISNULL(@Cmp_Code, '')
  + '#' + 'Digits For Emp Code :' + CONVERT(NVARCHAR(20), ISNULL(@No_Of_Digit_Emp_Code, 0))
  + '#' + 'In-Out Duration (in Sec) :' + CONVERT(NVARCHAR(20), ISNULL(@Inout_Duration, 0))
  + '#' + 'Alpha Numeric Code :' + CASE ISNULL(@Is_Auto_Alpha_Numeric_Code, 0) WHEN 0 THEN 'N' ELSE 'Y' END
  + '#' + 'Contractor Company  :' + CASE ISNULL(@Is_Contractor_Company, 0) WHEN 0 THEN 'N' ELSE 'Y' END
  + '#' + 'Branch abc wise Code   :' + CASE ISNULL(@Is_Alpha_Numeric_Branchwise, 0) WHEN 0 THEN 'N' ELSE 'Y' END
  + '#' + 'Reporting Hierarchy Designation wise  :' + CASE ISNULL(@Is_Organo_designationwise, 0) WHEN 0 THEN 'N' ELSE 'Y' END
  + '#' + 'Digital Signature :' + CASE ISNULL(@Has_Digital_Certi, 0) WHEN 0 THEN 'N' ELSE 'Y' END
  + '#' + 'Select Week off day :' + ISNULL(@Default_Holiday, '')
  + '#' + 'Comany wise Code :' + CASE ISNULL(@Is_Company_Wise, 0) WHEN 0 THEN 'N' ELSE 'Y' END
  + '#' + 'Date wise Code :' + CASE ISNULL(@Is_Date_Wise, 0) WHEN 0 THEN 'N' ELSE 'Y' END
  + '#' + 'Joining Date wise Code :' + CASE ISNULL(@Is_JoiningDate_Wise, 0) WHEN 0 THEN 'N' ELSE 'Y' END
  + '#' + 'Date Format for Code :' + ISNULL(@DateFormat, '')
  + '#' + 'Reset Sequance :' + CASE ISNULL(@is_Reset_Sequance, 0) WHEN 0 THEN 'N' ELSE 'Y' END
  + '#' + 'Company Hr Manager :' + ISNULL(@cmp_Hr_Manager, '')
  + '#' + 'Company Hr Manager Designation :' + ISNULL(@Cmp_Hr_Manager_Desig, '')
  + '#' + 'Max Emp Code :' + ISNULL(@Max_Emp_Code, '')
  + '#' + 'Sample Emp Code :' + ISNULL(@Sample_Emp_Code, '')
  + '#' + 'Designation code :' + CAST(ISNULL(@Is_Desig, '') AS VARCHAR(1))
  + '#' + 'Category code :' + CAST(ISNULL(@Is_Cate, '') AS VARCHAR(1))
  + '#' + 'Emp Type code :' + CAST(ISNULL(@Is_EmpType, '') AS VARCHAR(1))
  + '#' + 'Code Date OF Birth :' + CAST(ISNULL(@Is_DateofBirth, '') AS VARCHAR(1))
  + '#' + 'Code Date OF Current :' + CAST(ISNULL(@Is_Current_Date, '') AS VARCHAR(1))
  + '#' + 'Code Date Format Birth :' + ISNULL(@DateFormat_Birth, '')
  + '#' + 'Code Date Format Current :' + ISNULL(@DateFormat_Current, '')


  EXEC P9999_Audit_Trail @Cmp_Id, @tran_type, 'Company Information', @OldValue, @Cmp_Id, @User_Id, @IP_Address



END
ELSE IF @tran_type ='M' BEGIN
  UPDATE dbo.T0010_COMPANY_MASTER
  SET Image_name = @Image_Name
  , cmp_logo = @ImageObj
  , Image_file_Path = @Image_file_path
  WHERE Cmp_Id =@Cmp_Id
END
ELSE IF @tran_type = 'C' BEGIN
  UPDATE dbo.T0010_COMPANY_MASTER
  SET Has_Digital_Certi = @Has_Digital_Certi, Digital_Certi_FileName = @Digital_Certi_FileName, Digital_Certi_Password = @Digital_Certi_Password
  WHERE Cmp_Id =@Cmp_Id
END
ELSE IF @tran_type = 'H' BEGIN
  UPDATE dbo.T0010_COMPANY_MASTER
  SET Cmp_Header = @Cmp_Header
  WHERE Cmp_Id =@Cmp_Id
END
ELSE IF @tran_type = 'F' BEGIN
  UPDATE dbo.T0010_COMPANY_MASTER
  SET Cmp_Footer = @Cmp_Footer
  WHERE Cmp_Id =@Cmp_Id
END


IF NOT EXISTS (SELECT 1 FROM T0000_DEFAULT_FORM) 
BEGIN
	EXEC P0000_Default_Form_New 2
	EXEC P0000_Default_Form_New 1
	EXEC Default_settings_Rohit
END

RETURN