


---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0080_EMP_MASTER_IMPORT_NEW_RonakbBK171123] 
	@Cmp_ID numeric,  
	@Log_Status Varchar(max)  = 0 OUTPUT,
	@Str_Xml  xml,
	@User_Id numeric(18,0) = 0, -- Added by nilesh patel on 10052016 
    @IP_Address varchar(30)= '' -- Added by nilesh patel on 10052016 
AS 
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

   Declare @Emp_code			NUMERIC(18,0)  
   Declare @Initial				VARCHAR(10)   
   Declare @Emp_First_Name		VARCHAR(100)  
   Declare @Emp_Second_Name		VARCHAR(100)  
   Declare @Emp_Last_Name		VARCHAR(100) 
   Declare @Branch_Name			VARCHAR(100)     
   Declare @Grd_Name			VARCHAR(100)     
   Declare @Dept_Name			VARCHAR(100)     
   Declare @Product_Name		VARCHAR(100)     
   Declare @Desig_Name			VARCHAR(100)     
   Declare @Type_Name			VARCHAR(100)     
   Declare @Shift_Name			VARCHAR(100)     
   Declare @Bank_Name			VARCHAR(100)   
   Declare @Curr_Name			VARCHAR(100)     
   Declare @Date_Of_Join		DATETIME  
   Declare @Pan_No				VARCHAR(30)  
   Declare @ESIC_No				VARCHAR(30)  
   Declare @PF_No				VARCHAR(30)  
   Declare @Date_Of_Birth		DATETIME	
   Declare @Marital_Status		VARCHAR(20) 
   Declare @Gender				CHAR(1)		
   Declare @Nationality			VARCHAR(20)	
   Declare @Loc_Name			VARCHAR(100)
   Declare @Street_1			VARCHAR(250)  
   Declare @City				VARCHAR(30)  
   Declare @State				VARCHAR(20)  
   Declare @Zip_code			VARCHAR(20)  
   Declare @Home_Tel_no			VARCHAR(30)  
   Declare @Mobile_No			VARCHAR(30)  
   Declare @Work_Tel_No			VARCHAR(30)  
   Declare @Work_Email			VARCHAR(50)  
   Declare @Other_Email			VARCHAR(50)  
   Declare @Present_Street		VARCHAR(250)  
   Declare @Present_City		VARCHAR(30)  
   Declare @Present_State		VARCHAR(30)  
   Declare @Present_Post_Box	VARCHAR(20)  
   Declare @Basic_Salary		NUMERIC(18,2)  
   Declare @Gross_salary		NUMERIC(18,2)  
   Declare @Wages_Type			VARCHAR(10)	
   Declare @Salary_Basis_On		VARCHAR(20)	
   Declare @Payment_Mode		VARCHAR(20) 
   Declare @Inc_Bank_AC_No		VARCHAR(20)  
   Declare @Emp_OT				NUMERIC(1)	
   Declare @Emp_OT_Min_Limit	VARCHAR(10) 
   Declare @Emp_OT_Max_Limit	VARCHAR(10) 
   Declare @Emp_Late_mark		NUMERIC(18) 
   Declare @Emp_Full_PF			NUMERIC(18) 
   Declare @Emp_PT				NUMERIC(18) 
   Declare @Emp_Fix_Salary		NUMERIC(18) 
   Declare @Blood_Group			VARCHAR(10)  
   Declare @Enroll_No			NUMERIC (18,0)  
   Declare @Father_Name			VARCHAR(100) 
   Declare @Emp_IFSC_No			VARCHAR(100) 
   Declare @Adult_NO			NUMERIC(18,0) 
   Declare @Confirm_Date		DATETIME  
   Declare @Probation			NUMERIC(18,0)
   Declare @Superior			NUMERIC(18,0)
   Declare @Old_Ref_No			VARCHAR(50)	
   Declare @Row_No				NUMERIC(18,0)
   Declare @Alpha_Code			VARCHAR(10) 
   Declare @Emp_Superior		VARCHAR(20) 
   Declare @Is_LWF 				INT
   Declare @WeekDay_OT_Rate		NUMERIC(18,3) 
   Declare @Weekoff_OT_Rate		NUMERIC(18,3) 
   Declare @Holiday_OT_Rate		NUMERIC(18,3) 
   Declare @Business_Segment 	VARCHAR(50) 
   Declare @Vertical			VARCHAR(50) 
   Declare @sub_Vertical		VARCHAR(50) 
   Declare @sub_Branch			VARCHAR(50) 
   Declare @Group_of_Joining	DATETIME	
   Declare @Salary_Cycle		VARCHAR(50) 
   Declare @Cmp_Full_PF			NUMERIC(18) 
   DECLARE @totalRecords INT
   DECLARE @w_Count INT
   DECLARE @Emp_ID			As NUMERIC(18,0)   
   DECLARE @Branch_ID		As NUMERIC(18,0)
   DECLARE @Cat_ID			As NUMERIC(18,0)  
   DECLARE @Grd_ID			As NUMERIC(18,0)  
   DECLARE @Dept_ID		    As NUMERIC(18,0)  
   DECLARE @Desig_Id		As NUMERIC(18,0)
   DECLARE @Type_ID		As NUMERIC(18,0)  
   DECLARE @Shift_ID		As NUMERIC(18,0)  
   DECLARE @Bank_ID		As NUMERIC(18,0)  
   DECLARE @Curr_ID		As NUMERIC(18,0)  
   DECLARE @Increment_ID	As NUMERIC(18,0)   
   DECLARE @Loc_ID			As NUMERIC(18,0)  
   DECLARE @State_ID		As NUMERIC(18,0)  
   DECLARE @Login_ID		As NUMERIC(18,0)   
   DECLARE @Chg_Pwd		As INT   
   DECLARE @emp_Id_sup		AS NUMERIC(18,0)  
   SET @emp_Id_sup = 0  
   DECLARE @Segment_ID		As NUMERIC(18,0) 
   DECLARE @Vertical_ID	As NUMERIC(18,0) 
   DECLARE @SubVertical_ID As NUMERIC(18,0)
   DECLARE @SubBranch_ID	As NUMERIC(18,0)
   Declare @Salary_Cycle_ID As Numeric(18,0)
   DECLARE @HasResult Varchar(max) 
   DECLARE @Date_Of_Retirement Datetime 
   DECLARE @Pay_Scale_Name Varchar(500) 
   DECLARE @Pay_Scale_ID Numeric
   DECLARE @Customer_Audit tinyint --Added By Jaina 09-09-2016
   Declare @Auto_LeaveCredit_Setting as NUMERIC(18,0)--Mukti(08092017)
   Declare @EssPassword as Varchar(500)
   Declare @CTC as Numeric(18,2)
   DECLARE @Tran_ID AS INT
   SET @CTC = 0
   
	SET @Emp_Second_Name = ''
	SET @Date_Of_Birth	 = NULL 
	SET @Marital_Status	 = '-1'
    SET @Gender			 = ''  
    SET @Nationality	 = 'Indian'  
    SET @Loc_Name		 = 'India'  
    SET @Wages_Type		 = 'Monthly'  
    SET @Salary_Basis_On = 'Day'  
    SET @Payment_Mode	 = 'Cash' 
    SET @Emp_OT			 = 0  
    SET @Emp_OT_Min_Limit	= '00:00'  
    SET @Emp_OT_Max_Limit	= '00:00'  
    SET @Emp_Late_mark	    = 0  
    SET @Emp_Full_PF	    = 0		--Here 0 is Done by RamiZ on 10/09/2015
    SET @Emp_PT				= 0  
    SET @Emp_Fix_Salary		= 0  
    SET @Father_Name		= ''  
    SET @Emp_IFSC_No		= ''  
    SET @Adult_NO			= 0 
    SET  @Probation			= 0  
    SET @Superior			= NULL 
    SET @Old_Ref_No			= NULL  
    SET @Row_No				= 0 
    SET @Alpha_Code			= ''   
	SET @Emp_Superior		= ''     
    SET @Is_LWF 			=0  
    SET @WeekDay_OT_Rate	= 0  
    SET @Weekoff_OT_Rate	= 0  
    SET @Holiday_OT_Rate	= 0  
    SET @Business_Segment 	= NULL	
    SET @Vertical			= NULL	
    SET @sub_Vertical		= NULL	
    SET @sub_Branch			= NULL	
    SET @Group_of_Joining	= NULL	
    SET @Salary_Cycle		= NULL	
    SET @Cmp_Full_PF		= 0		--Here 0 is Done by RamiZ on 10/09/2015
    SET @HasResult			= ''
    SET @Date_Of_Retirement = Null
    Set @Pay_Scale_Name = ''
    Set @Pay_Scale_ID = 0
    Set @Customer_Audit = 0   --Added By Jaina 09-09-2016
    Set @EssPassword = ''
	set @Emp_code=0
	Set @Log_Status = '0'

    --ADMIN SETTING PORTION ADDED BY RAMIZ ON 21/01/2019--
   DECLARE @Add_Initial_In_Emp_Full_Name TINYINT
   SET @Add_Initial_In_Emp_Full_Name = 0
   
   SELECT @Add_Initial_In_Emp_Full_Name = SETTING_VALUE FROM T0040_SETTING  WITH (NOLOCK) WHERE cmp_id = @Cmp_ID and SETTING_NAME = 'Add initial in employee full name'
	
BEGIN	
	SET NOCOUNT ON;
	SET @Login_ID = 0  
	SET @Chg_Pwd = 0  
	Set @Salary_Cycle_ID = 0

	Set @Str_Xml = REPLACE(cast(@Str_Xml as nvarchar(max)),'Table1','Sheet1OLE')
	
	---- Add by Jignesh 24-02-2020-----
	Set @Str_Xml = REPLACE(cast(@Str_Xml as nvarchar(max)),'(Gerenal_x0020_Shift/text())[1]','(General_x0020_Shift/text())[1]')
	Set @Str_Xml = REPLACE(cast(@Str_Xml as nvarchar(max)),'Gerenal_x0020_Shift','General_x0020_Shift')
	-------- End-----------
		
    select dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(Emp_x0020_Code/text())[1]','numeric(18,0)')) as Emp_Code,
    dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(Initial_x0020_Name/text())[1]','Varchar(100)')) as Emp_int_Name,
    dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(First_x0020_Name/text())[1]','Varchar(100)')) as Emp_First_Name,
    dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(Second_x0020_Name/text())[1]','Varchar(100)')) as Emp_Second_Name,
    dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(Last_x0020_Name/text())[1]','Varchar(100)')) as Emp_Last_Name,
    dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(Branch/text())[1]','Varchar(100)')) as Branch,
    dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(Grade/text())[1]','Varchar(100)')) as Garde,
    dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(Department/text())[1]','Varchar(100)')) as Dept,
    dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(Category/text())[1]','Varchar(100)')) as Category,
    dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(Designation/text())[1]','Varchar(100)')) as Designation,
    dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(TYPE/text())[1]','Varchar(100)')) as Type,
    
    ----- Modify Jignesh 24-02-2020---
    ----Sheet1OLE.value('(Gerenal_x0020_Shift/text())[1]','Varchar(100)') as Shift,
    dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(General_x0020_Shift/text())[1]','Varchar(100)')) as Shift,
					  
    dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(BANK_x0020_NAME/text())[1]','Varchar(100)')) as Bank_name,
    dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(CURR_x0020_NAME/text())[1]','Varchar(100)')) as Curr_name,
    --Sheet1OLE.value('(DOJ/text())[1]','datetime') as DOJ,
    dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('substring((DOJ/text())[1], 1, 19)','datetime')) as DOJ,
    dbo.fnc_ReverseHTMLTags(isnull(Sheet1OLE.value('(Pan_x0020_No/text())[1]','Varchar(100)'),'')) as Pan_No,
    dbo.fnc_ReverseHTMLTags(isnull(Sheet1OLE.value('(Esic_x0020_No/text())[1]','Varchar(100)'),'')) as EsicNo,
    dbo.fnc_ReverseHTMLTags(isnull(Sheet1OLE.value('(PF_x0020_no/text())[1]','Varchar(100)'),'')) as PFno,
    --Sheet1OLE.value('(DOB/text())[1]','datetime') as BOD,
    dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('substring((DOB/text())[1], 1, 19)','datetime')) as BOD,
    dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(MARITAL_x0020_STATUS/text())[1]','Varchar(100)')) as Marital_status,
    dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(GENDER/text())[1]','Varchar(100)')) as Gender,
    dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(NATIONALITY/text())[1]','Varchar(100)')) as Nationality,
    dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(LOCATION/text())[1]','Varchar(100)')) as Location,
    dbo.fnc_ReverseHTMLTags(isnull(Sheet1OLE.value('(ADDRESS/text())[1]','Varchar(500)'),'')) as Address,
    dbo.fnc_ReverseHTMLTags(isnull(Sheet1OLE.value('(CITY/text())[1]','Varchar(100)'),'')) as City,
    dbo.fnc_ReverseHTMLTags(isnull(Sheet1OLE.value('(STATE/text())[1]','Varchar(100)'),'')) as State,
    dbo.fnc_ReverseHTMLTags(isnull(Sheet1OLE.value('(POST_x0020_BOX/text())[1]','Varchar(100)'),'')) as PostBox,
    dbo.fnc_ReverseHTMLTags(isnull(Sheet1OLE.value('(Tel_x0020_No/text())[1]','Varchar(100)'),'')) as Tel_No,
    dbo.fnc_ReverseHTMLTags(isnull(Sheet1OLE.value('(MOBILE_x0020_NO/text())[1]','Varchar(100)'),'')) as Mobile,
    dbo.fnc_ReverseHTMLTags(isnull(Sheet1OLE.value('(Work_x0020_Tel_x0020_No/text())[1]','Varchar(100)'),'')) as Work_Tel_No,
    dbo.fnc_ReverseHTMLTags(isnull(Sheet1OLE.value('(Work_x0020_Email/text())[1]','Varchar(100)'),'')) as Work_Email,
    dbo.fnc_ReverseHTMLTags(isnull(Sheet1OLE.value('(Other_x0020_Email/text())[1]','Varchar(100)'),'')) as Other_Email,
	dbo.fnc_ReverseHTMLTags(isnull(Sheet1OLE.value('(ADDRESS1/text())[1]','Varchar(100)'),'')) as Present_ADDRESS,
	dbo.fnc_ReverseHTMLTags(isnull(Sheet1OLE.value('(CITY1/text())[1]','Varchar(100)'),'')) as Present_City,
    dbo.fnc_ReverseHTMLTags(isnull(Sheet1OLE.value('(State1/text())[1]','Varchar(100)'),'')) as Present_State,
    dbo.fnc_ReverseHTMLTags(isnull(Sheet1OLE.value('(Post_x0020_Box1/text())[1]','Varchar(100)'),'')) as Present_Postbox,
    dbo.fnc_ReverseHTMLTags(isnull(Sheet1OLE.value('(SALARY/text())[1]','Numeric(18,2)'),0)) as Salary,
    dbo.fnc_ReverseHTMLTags(isnull(Sheet1OLE.value('(Gross_Salary/text())[1]','Numeric(18,2)'),0)) as Gross,
    dbo.fnc_ReverseHTMLTags(isnull(Sheet1OLE.value('(CTC/text())[1]','Numeric(18,2)'),0)) as CTC,
    dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(Wages_Type/text())[1]','Varchar(100)')) as Wages,
    dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(Salary_Basis_On/text())[1]','Varchar(100)')) as Salary_Basic_on,
    dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(Payment_Mode/text())[1]','Varchar(100)')) as Payment_mode,
    dbo.fnc_ReverseHTMLTags(isnull(Sheet1OLE.value('(Emp_Bank_Ac_No/text())[1]','Varchar(100)'),'')) as Bank_Acc_No,
    dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(Emp_OT/text())[1]','Varchar(100)')) as Emp_OT,
    dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(Min_x0020_limit/text())[1]','Varchar(100)')) as Min_Limit,
    dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(Max_x0020_Limit/text())[1]','Varchar(100)')) as Max_Limit,
    dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(Late_x0020_Mark/text())[1]','Varchar(100)')) as Late_Mark,
    dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(Full_x0020_PF/text())[1]','Varchar(100)')) as Full_PF,
    --Sheet1OLE.value('(Prof._x0020_Tax/text())[1]','Varchar(100)') as Prof_Tax,
	dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(Prof_x0023__x0020_Tax/text())[1]','Varchar(100)')) as Prof_Tax,
    dbo.fnc_ReverseHTMLTags(Isnull(Sheet1OLE.value('(Fix_x0020_Salary/text())[1]','Numeric(1,0)'),0)) as Fix_Salary,
    dbo.fnc_ReverseHTMLTags(isnull(Sheet1OLE.value('(Blood_Group/text())[1]','Varchar(100)'),'')) as Blood_Group,
    dbo.fnc_ReverseHTMLTags(isnull(Sheet1OLE.value('(Enroll_No/text())[1]','Varchar(100)'),'0')) as Enroll_No,
    dbo.fnc_ReverseHTMLTags(isnull(Sheet1OLE.value('(Father_Name/text())[1]','Varchar(100)'),'')) as Father_Name,
    dbo.fnc_ReverseHTMLTags(isnull(Sheet1OLE.value('(Bank_IFSC_NO/text())[1]','Varchar(100)'),'')) as Bank_IFSC_NO,
    --Sheet1OLE.value('(Confirmation_Date/text())[1]','DateTime') as Confirmation_Date,
    dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('substring((Confirmation_Date/text())[1], 1, 19)','datetime')) as Confirmation_Date,
    --Sheet1OLE.value('(Probation/text())[1]','DateTime') as Probation,
	dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(Probation/text())[1]','Varchar(100)')) as Probation,
	dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(Old_Ref_No/text())[1]','Varchar(100)')) as Old_Ref_No,
	dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(Alpha_Code/text())[1]','Varchar(100)')) as Alpha_Code,
	dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(Emp_Superior/text())[1]','Varchar(100)')) as Emp_Superior,
    dbo.fnc_ReverseHTMLTags(isnull(Sheet1OLE.value('(Is_LWF/text())[1]','Numeric(18,0)'),0)) as IS_LWF,
    dbo.fnc_ReverseHTMLTags(isnull(Sheet1OLE.value('(Weekday_OT_Rate/text())[1]','Numeric(18,2)'),0)) as Weekday_OT_Rate,
    dbo.fnc_ReverseHTMLTags(Isnull(Sheet1OLE.value('(Weekoff_OT_Rate/text())[1]','Numeric(18,2)'),0)) as Weekoff_OT_Rate,
    dbo.fnc_ReverseHTMLTags(Isnull(Sheet1OLE.value('(Holiday_OT_Rate/text())[1]','Numeric(18,2)'),0)) as Holiday_OT_Rate,
    dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(Business_x0020_Segment/text())[1]','Varchar(100)')) as Business,
    dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(Vertical/text())[1]','Varchar(100)')) as Vertical,
    dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(sub_Vertical/text())[1]','Varchar(100)')) as sub_Vertical,
    ---Sheet1OLE.value('(Group_x0020_of_x0020_Joining/text())[1]','datetime') as Group_Of_Join,
    dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('substring((Group_x0020_of_x0020_Joining/text())[1], 1, 19)','datetime')) as Group_Of_Join,
    dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(sub_Branch/text())[1]','Varchar(100)')) as sub_Branch,
    dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(Salary_Cycle/text())[1]','Varchar(100)')) as Salary_Cycle,
    dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(Company_x0020_Full_x0020_PF/text())[1]','Varchar(100)')) as Company_Full_PF,
    dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(Pay_Scale_Name/text())[1]','Varchar(100)')) as Pay_Scale_Name,
    dbo.fnc_ReverseHTMLTags(isnull(Sheet1OLE.value('(Customer_Audit/text())[1]','Numeric(18,0)'),0)) as Customer_Audit,   --Added By Jaina 09-09-2016
    dbo.fnc_ReverseHTMLTags(isnull(Sheet1OLE.value('(Password/text())[1]','Varchar(500)'),0)) as EssPassword
    into #Temptable from @Str_Xml.nodes('/NewDataSet/Sheet1OLE') as Temp(Sheet1OLE)

	
	CREATE TABLE #Emp_Code_Detail
	(
		Alpha_Code Varchar(128),
		Emp_Code Numeric
	)
	
	
	CREATE table #Error_Details 
	(      
		Log_Status NUMERIC ,     
		Alpha_Code Varchar(100),
		Error_Description Varchar(1000)    
	) 
	
    Declare @Restrict_Other_Master Numeric(2,0) --Added By Nilesh patel on 04042016
	DECLARE @ErrString VARCHAR(1000)  
	--Validiating some Fields in which SPACE is not Allowed-- Ramiz on 01/04/2019
	UPDATE #Temptable
	SET PAN_NO		= REPLACE(REPLACE(RTRIM(LTRIM(PAN_NO)) , ' ',''),'  ',''),
		Work_Email  = REPLACE(REPLACE(RTRIM(LTRIM(Work_Email)) , ' ',''),'  ',''),
		Other_Email = REPLACE(REPLACE(RTRIM(LTRIM(Other_Email)) , ' ',''),'  ','')
	
	--select Prof_Tax,* from #Temptable
    declare curXml cursor for 
		select Marital_status,Gender,Emp_int_Name,Nationality,Location,Wages,Salary,Payment_mode,Min_Limit,Max_Limit,Full_PF,Company_Full_PF,
		Prof_Tax,Alpha_Code,Emp_Superior,Salary_Cycle,Emp_Last_Name,Group_Of_Join,Branch,Garde,Shift,Emp_Code,Emp_First_Name,Emp_Second_Name,DOJ,
		Designation,Type,Bank_name,Curr_name,Category,Business,Vertical,sub_Vertical,sub_Branch,Address,City,State,PostBox,Tel_No,Mobile,Work_Tel_No,
		Work_Email,Other_Email,Present_ADDRESS,Present_City,Present_State,Present_Postbox,Enroll_No,Blood_Group,Father_Name,Bank_IFSC_NO,Confirmation_Date,
		Probation,Old_Ref_No,IS_LWF,Weekday_OT_Rate,Weekoff_OT_Rate,Holiday_OT_Rate,Group_Of_Join,Late_Mark,Pan_No,EsicNo,PFno,BOD,Gross,Salary_Basic_on,
		Bank_Acc_No,Emp_OT,cast(Fix_Salary AS numeric(1,0)),Dept,Pay_Scale_Name,Customer_Audit,EssPassword,CTC from #Temptable                  
	open curXml                        
		fetch next from curXml into @Marital_Status,@Gender,@Initial,@Nationality,@Loc_Name,@Wages_Type,@Basic_Salary,@Payment_Mode,@Emp_OT_Min_Limit,@Emp_OT_Max_Limit,@Emp_Full_PF,@Cmp_Full_PF,@Emp_PT,@Alpha_Code,@Emp_Superior,@Salary_Cycle,@Emp_Last_Name,@Group_of_Joining,@Branch_Name,@Grd_Name,@Shift_Name,@Emp_Code,@Emp_First_Name,@Emp_Second_Name,@Date_Of_Join,@desig_Name,@Type_Name,@Bank_Name,@Curr_Name,@Product_name,@Business_Segment,@Vertical,@Sub_Vertical,@Sub_Branch,@Street_1,@City,@State,@Zip_code,@Home_Tel_no,@Mobile_No,@Work_Tel_No,@Work_Email,@Other_Email,@Present_Street,@Present_City,@Present_State,@Present_Post_Box,@Enroll_No,@Blood_Group,@Father_Name,@Emp_IFSC_No,@Confirm_Date,@Probation,@Old_Ref_No,@IS_LWF,@Weekday_OT_Rate,@Weekoff_OT_Rate,@Holiday_OT_Rate,@Group_of_Joining,@Emp_LATE_MARK,@Pan_No,@ESIC_No,@PF_No,@Date_Of_Birth,@Gross_salary,@Salary_Basis_On,@Inc_Bank_Ac_No,@Emp_OT,@Emp_Fix_Salary,@Dept_Name,@Pay_Scale_Name,@Customer_Audit,@EssPassword,@CTC  --Change by Jaina 09-09-2016
		while @@fetch_status >= 0 
		Begin                     
			 BEGIN TRY
			 
				 
				
				  DECLARE @Emp_Full_Name  VARCHAR(250)  
				  DECLARE @loginname   VARCHAR(50)  
				  DECLARE @Domain_Name  VARCHAR(50)  
				  DECLARE @old_Join_Date  DATETIME   
				  DECLARE @Default_Weekof  VARCHAR(50)   
				  DECLARE @Cmp_Code AS VARCHAR(5)  
				  DECLARE @Branch_Code_1 AS VARCHAR(10)  
				  DECLARE @Alpha_Emp_Code AS VARCHAR(50)  
				  DECLARE @Is_Auto_Alpha_Numeric_Code TINYINT  
				  DECLARE @No_Of_Digits NUMERIC
				  --add by chetan 060717
				  DECLARE @Alt_W_Name  VARCHAR(20)  
				  DECLARE @Alt_W_Full_Day_Cont  VARCHAR(20)  
				  
				  Declare @Retirement_Year Numeric(18,0) 
				  SET @Retirement_Year	= 0  -- Added by nilesh patel on 30012015
				   
				  select @Retirement_Year = Setting_Value from T0040_SETTING WITH (NOLOCK) where cmp_id = @Cmp_ID and Setting_Name='Employee Retirement Age'
				  
				  select @Restrict_Other_Master = Setting_Value from T0040_SETTING WITH (NOLOCK) where cmp_id = @Cmp_ID and Setting_Name='Restrict other master creation when Emplyee Master Import'
				 
				  if @date_of_Birth = '01/01/1900'  -- Added by Gadriwala Muslim 0512016
					set @date_of_Birth = null
					
				IF @Date_Of_Birth is not null and @Retirement_Year <> 0
					BEGIN
						SET @Date_Of_Retirement = DATEADD(YEAR,@Retirement_Year,@Date_Of_Birth)
					END
				ELSE
					Set @Date_Of_Retirement = NULL	
					
				--Added BY Jimit 14032019
				IF @Date_Of_Birth > GETDATE()
					BEGIN
							INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Future Birth Date is not Allowed.',0,'Enter Valid Birth Date',GETDATE(),'Employee Master','') 
							SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
							Goto ABC;
					END
				IF DATEDIFF(YEAR,@Date_Of_Birth,@Date_Of_Join) < 18
					BEGIN
							INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Employee Age below 18yrs.',0,'Enter Valid Birth date',GETDATE(),'Employee Master','') 
							SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
							Goto ABC;
					END
				--ENDED

				if @Emp_code is null  --added by aswini 7/11/2023
				BEGIN
							INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Employee Code is required.',0,'Enter Employee Code',GETDATE(),'Employee Master','') 
							SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
							Goto ABC;
					END
				

				If @Emp_Second_Name IS NULL
					Set @Emp_Second_Name = ''
			 
				IF IsNull(@Marital_Status,'') = '' OR ISNUMERIC(@Marital_Status) = 0
					SET @Marital_Status = '-1'  
				  
				--IF IsNull(@Gender,'') = ''
				--	SET @Gender = 'M'
				 
				 -- If @Initial = 'Ms.' Or @Initial = 'Ms' Or @Initial = 'Mrs.' Or @Initial = 'Mrs'
					--BEGIN
					--	Set @Gender = 'F'
					--END
				 -- ELSE
					--BEGIN
					--	Set @Gender = 'M'
					--END
					
				 -- IF @Nationality IS NULL  
					--SET @Nationality = 'Indian'  
		     
				 -- IF IsNull(@Loc_Name,'') = ''
					--SET @Loc_Name = 'India'  
		       
				  IF @Wages_Type IS NULL     
					SET @Wages_Type = 'Monthly'  
		    
				 -- IF @Salary_Basis_On IS NULL 
					--SET @Salary_Basis_On = 'Day'  
					
				  IF @Emp_OT_Min_Limit IS NULL   
					SET @Emp_OT_Min_Limit = '00:00'
					  

				  if @Emp_OT_Min_Limit IS NOT NULL
					 Begin
						DECLARE @OT_Min_HOURS NUMERIC = null
						DECLARE @OT_Min_MINUTES NUMERIC = null
						SELECT @OT_Min_HOURS = CAST(DATA AS NUMERIC) FROM dbo.Split(@Emp_OT_Min_Limit, ':') where id=1 AND IsNumeric(Data) = 1 
						SELECT @OT_Min_MINUTES = CAST(DATA AS NUMERIC) FROM dbo.Split(@Emp_OT_Min_Limit, ':') where id=2  AND IsNumeric(Data) = 1 

						IF @OT_Min_MINUTES > 59
							SET @OT_Min_MINUTES = NULL

						IF @OT_Min_HOURS > 380
							SET @OT_Min_HOURS = NULL

						DECLARE @OT_Min_LENGTH INT = 2
						IF @OT_Min_HOURS > 99
							SET @OT_Min_LENGTH = 3

						IF @OT_Min_HOURS IS NULL OR @OT_Min_MINUTES IS NULL
							BEGIN
								INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Enter Validation Details of OT Min Limit.',0,'Enter Valid OT Min Limit',GETDATE(),'Employee Master','') 
								SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
								Goto ABC;
							END
						ELSE
							BEGIN
								SET  @Emp_OT_Min_Limit = RIGHT('0' + CAST(@OT_Min_HOURS AS VARCHAR(4)),@OT_Min_LENGTH) + ':' + RIGHT('0' + CAST(@OT_Min_MINUTES AS VARCHAR(2)),2)
							END
					 End
		    
				  IF @Emp_OT_Max_Limit IS NULL  
					SET @Emp_OT_Max_Limit = '00:00'  

				  if @Emp_OT_Max_Limit IS NOT NULL
					Begin
						DECLARE @HOURS NUMERIC = null
						DECLARE @MINUTES NUMERIC = null
						SELECT @HOURS = CAST(DATA AS NUMERIC) FROM dbo.Split(@Emp_OT_Max_Limit, ':') where id=1 AND IsNumeric(Data) = 1 
						SELECT @MINUTES = CAST(DATA AS NUMERIC) FROM dbo.Split(@Emp_OT_Max_Limit, ':') where id=2  AND IsNumeric(Data) = 1 

						IF @MINUTES > 59
							SET @MINUTES = NULL

						IF @HOURS > 380
							SET @HOURS = NULL

						DECLARE @LENGTH INT = 2
						IF @HOURS > 99
							SET @LENGTH = 3

						IF @HOURS IS NULL OR @MINUTES IS NULL
							BEGIN
								INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Enter Validation Details of OT Max Limit.',0,'Enter Valid OT Max Limit',GETDATE(),'Employee Master','') 
								SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
								Goto ABC;
							END
						ELSE
							BEGIN
								SET  @Emp_OT_Max_Limit = RIGHT('0' + CAST(@HOURS AS VARCHAR(4)),@LENGTH) + ':' + RIGHT('0' + CAST(@MINUTES AS VARCHAR(2)),2)
							END
					End
				    
				  IF @Emp_Full_PF IS NULL  
					SET @Emp_Full_PF = 0	--Here 0 is Done by RamiZ on 10/09/2015 ,previously it was 1  
				    
				  IF @Cmp_Full_PF IS NULL  
					SET @Cmp_Full_PF = 0	--Here 0 is Done by RamiZ on 10/09/2015 ,previously it was 1  
				    
				  IF @Emp_PT IS NULL  
					SET @Emp_PT = 0
			   
				  IF @Alpha_Code IS NULL  
					SET @Alpha_Code = NULL   
				   
				  IF @Emp_Superior IS NULL  
					SET @Emp_Superior = '0'
				  
					
				  IF @Salary_Cycle IS NULL   
					SET @Salary_Cycle = '0'  
					
				  IF @Emp_Last_Name is Null or @Emp_Last_Name = ''
					set @Emp_Last_Name = ' '
					
				  IF @Group_of_Joining IS NULL or @Group_of_Joining ='1900-01-01 00:00:00.000'
					 set @Group_of_Joining = @Date_Of_Join 

				Declare @Backdate_Allowed Numeric
				Select @Backdate_Allowed = Setting_Value From T0040_SETTING WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Setting_Name='Allowed Backdated Joining upto Days'

				if @Backdate_Allowed > 0
					Begin
						if Not Exists(SELECT 1 FROM T0011_LOGIN WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Login_ID = @User_Id and Login_Name LIKE 'admin@%')
						BEGIN
							DECLARE @Dt_From_Date Datetime
							DECLARE @Dt_To_Date Datetime
						
							SET @Dt_To_Date = CAST(Convert(char(11),GETDATE(),113) AS datetime)
							SET @Dt_From_Date =  DATEADD(d,((@Backdate_Allowed) * (-1)),@Dt_To_Date)
						
							if @Date_of_Join < @Dt_From_Date 
								Begin
									Declare @Errormsg1  varchar(500)
									set @Errormsg1 = '@@You can enter date of joining upto ' + ' ' + Cast(CONVERT(varchar(11),@Dt_From_Date,103) as Varchar(11)) + ' ' + ' Date,for more detail contact to administrator.@@.'
									
									INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,@Errormsg1,0,'Enter Correct Date of Joining',GETDATE(),'Employee Master','') 
									SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
									Goto ABC;
								End	
						End	
					End

				SET @HasResult = ''

				IF IsNull(@Gender,'') = ''
					BEGIN
						INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Gender is not specified',@Loc_Name,'Please specify the gender of the employee',GETDATE(),'Employee Master','')  
						SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
					END
				IF IsNull(@Nationality,'') = ''
					BEGIN
						INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Nationality is not specified',@Loc_Name,'Please specify the nationality of the employee',GETDATE(),'Employee Master','')  
						SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
					END
				IF IsNull(@Salary_Basis_On, '') = ''
					BEGIN
						INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Salary Basic On is not specified',@Loc_Name,'Please specify the Salary Basic On of the employee',GETDATE(),'Employee Master','')  
						SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
					END
				IF IsNull(@Payment_Mode, '') = ''
					BEGIN
						INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Payment Mode is not specified',@Loc_Name,'Please specify the Payment Mode of the employee',GETDATE(),'Employee Master','')  
						SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
					END
               


				if @Grd_Name <> ''   --added by aswini 7/11/2023
				

				
	begin
                      --IF (@Grd_Name LIKE '%[^a-zA-Z0-9]%')

					  if(@Grd_Name like '%[&''"]%')
                       begin
					   INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Grade Name contain Special Character',@Emp_Superior,'Enter Correct Grade Name',GETDATE(),'Employee Master','')  
								SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
								Goto ABC;
							End
							end
                if @Branch_Name <> ''   --added by aswini 7/11/2023
				

				
	begin
                      IF (@Branch_Name LIKE '%[&''"]%')
                       begin
					   INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Branch Name contain Special Character',@Branch_Name,'Enter Correct Branch Name',GETDATE(),'Employee Master','')  
								SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
								Goto ABC;
							End
							end
                   if @Dept_Name<>''   --added by aswini 7/11/2023
                    begin
                      IF (@Dept_Name LIKE '%[&''"]%')
                       begin
					   INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Department Name contain Special Character',@Dept_Name,'Enter Correct Department Name',GETDATE(),'Employee Master','')  
								SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
								Goto ABC;
							End
							end
		 		if @desig_Name<>''
begin
                      IF (@desig_Name LIKE '%[&''"]%')
                       begin
					   INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Designation Name contain Special Character',@desig_Name,'Enter Correct Designation Name',GETDATE(),'Employee Master','')  
								SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
								Goto ABC;
							End
							end
              --  @Product_name
			  if @Product_name<>''
begin
                      IF (@Product_name LIKE '%[&''"]%')
                       begin
					   INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Category Name contain Special Character',@Product_name,'Enter Correct Category Name',GETDATE(),'Employee Master','')  
								SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
								Goto ABC;
							End
							end

                      

              if @Vertical<>''
                           begin
                      IF (@Vertical LIKE '%[&''"]%')
                       begin
					   INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Vertical Name contain Special Character',@Vertical,'Enter Correct Vertical Name',GETDATE(),'Employee Master','')  
								SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
								Goto ABC;
							End
							end
							--@SubVertical_ID

                       if @Sub_Vertical<>''
                           begin
                      IF (@Sub_Vertical LIKE '%[&''"]%')
                       begin
					   INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Sub Vertical Name contain Special Character',@Sub_Vertical,'Enter Correct Sub Vertical Name',GETDATE(),'Employee Master','')  
								SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
								Goto ABC;
							End
							end
--@Sub_Branch
                         if @Sub_Branch<>''
                           begin
                      IF (@Sub_Branch LIKE '%[&''"]%')
                       begin
					   INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Sub Branch Name contain Special Character',@Sub_Branch,'Enter Correct Sub Branch Name',GETDATE(),'Employee Master','')  
								SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
								Goto ABC;
							End
							end

				if @Restrict_Other_Master <> 0 
					Begin	
					  IF EXISTS(SELECT LOC_ID FROM T0001_LOCATION_MASTER WITH (NOLOCK) WHERE LOC_Name =@LOC_Name)  
							BEGIN    
								SELECT @Loc_ID = LOC_ID FROM T0001_LOCATION_MASTER WITH (NOLOCK) WHERE LOC_Name =@LOC_Name 
							END  
					  ELSE  
							BEGIN   
								IF @Loc_Name is not NULL
									BEGIN  
										EXEC P0001_LOCATION_MASTER @Loc_ID OUTPUT ,@Loc_Name  
									END  
							ELSE  
								BEGIN  
									INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Location Name is Not Proper',@Loc_Name,'Please Enter Location Name',GETDATE(),'Employee Master','')  
									SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
								END   
							END
					End
				 Else
					Begin
						IF EXISTS(SELECT LOC_ID FROM T0001_LOCATION_MASTER WITH (NOLOCK) WHERE LOC_Name =@LOC_Name)  
							BEGIN    
								SELECT @Loc_ID = LOC_ID FROM T0001_LOCATION_MASTER WITH (NOLOCK) WHERE LOC_Name =@LOC_Name 
							END  
						Else
							Begin
								print 'Location'
								INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Location Name Not Exits',@Emp_Superior,'Enter Correct Location Name',GETDATE(),'Employee Master','')  
								SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
								Goto ABC;
							End
					End	 
				 
				





				 if @Restrict_Other_Master <> 0 
					Begin
					 





					
						 IF EXISTS(SELECT Branch_ID FROM T0030_Branch_Master WITH (NOLOCK) WHERE Branch_Name =@Branch_Name AND Cmp_ID=@Cmp_ID)  
							BEGIN 
								SELECT @Branch_ID = Branch_ID,@State_id=State_ID FROM dbo.T0030_Branch_Master WITH (NOLOCK) WHERE Branch_Name =@Branch_Name AND Cmp_ID=@Cmp_ID 
							END  
						 ELSE  
							BEGIN  
							 IF @Branch_Name is not NULL
								BEGIN 
									DECLARE @BRANCH_CODE2 VARCHAR(10)
									DECLARE @TEMP_BRANCH_NAME VARCHAR(100)
									DECLARE @Branch_Code VARCHAR(10)  
									SET @Branch_Code = NULL
									SET @BRANCH_CODE2 = NULL
									--SET @Branch_Code = LEFT(@Branch_Name,3)  -- Commented By Ramiz on 12/12/2016 , **Case:- If We Import 2 Employees Abu-North & Abu-South , then Branch Code will become Same , so this will not work

									SET @temp_Branch_Name = REPLACE(REPLACE(REPLACE(REPLACE(@Branch_Name , '.' , ''), '-', ''), '(',''),')','');
									Set @Branch_Code2 = LEFT(REPLACE(@temp_Branch_Name, ' ',''),3)
								
									IF (CHARINDEX(' ', @temp_Branch_Name) > 0)
										BEGIN
											SELECT	@Branch_Code = COALESCE(@Branch_Code,'') +  left(data, 1)
											FROM	dbo.Split(@temp_Branch_Name, ' ' )
										END
									
									SET @Branch_Code =  ISNULL(@Branch_Code, @Branch_Code2);
									
									IF  EXISTS(SELECT 1 FROM T0030_BRANCH_MASTER WITH (NOLOCK)
												WHERE	Branch_Code = @Branch_Code AND Cmp_ID=@Cmp_ID)
										BEGIN 
											DECLARE @INDEX_BRANCH INT
											SELECT	@INDEX_BRANCH = IsNull(COUNT(1), 0) + 1
											FROM	T0030_BRANCH_MASTER WITH (NOLOCK)
											WHERE	Branch_Code LIKE @Branch_Code + '_%' AND Cmp_ID=@Cmp_ID											

											SET @Branch_Code = @Branch_Code + '_' + CAST(@INDEX_BRANCH AS VARCHAR(2))
											
											--IF  EXISTS(SELECT 1 FROM T0030_BRANCH_MASTER
											--	WHERE	Branch_Code = @Branch_Code2)
											--	SET @Branch_Code = UPPER(@temp_Branch_Name);
											--ELSE
											--	SET @Branch_Code = UPPER(@Branch_Code2);
										END

									EXEC P0030_BRANCH_MASTER @Branch_ID OUTPUT ,@Cmp_ID,@State_ID,@Branch_Code,@Branch_Name,'','','','I',0,0,'',0,0,0,'','','','',1,NULL,NULL,NULL,'',1 
								END  
							ELSE  
								BEGIN  
									INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Branch Name is Not Proper',@Branch_Name,'Please Enter Branch Name',GETDATE(),'Employee Master','')  
									SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
								END    
						   END 
					End
				Else
					BEGIN
						IF EXISTS(SELECT Branch_ID FROM T0030_Branch_Master WITH (NOLOCK) WHERE Branch_Name =@Branch_Name AND Cmp_ID=@Cmp_ID)  
							BEGIN 
								SELECT @Branch_ID = Branch_ID,@State_id=State_ID FROM dbo.T0030_Branch_Master WITH (NOLOCK) WHERE Branch_Name =@Branch_Name AND Cmp_ID=@Cmp_ID 
							END
						Else
							BEGIN
								print 'Branch'
								INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Branch Name Not Exits',@Emp_Superior,'Enter Correct Branch Name',GETDATE(),'Employee Master','')  
								SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
								Goto ABC;
						    END   
					END  
				
				if @Restrict_Other_Master <> 0
					
				begin
					

						IF EXISTS(SELECT Grd_ID FROM T0040_GRADE_Master WITH (NOLOCK) WHERE Grd_Name =@Grd_Name AND Cmp_ID=@Cmp_ID)  
							BEGIN  
								SELECT @Grd_ID = Grd_ID FROM T0040_GRADE_Master WITH (NOLOCK) WHERE Grd_Name =@Grd_Name AND Cmp_ID=@Cmp_ID 
							END  
						ELSE  
							BEGIN 
								
								IF @Grd_Name is not NULL  
									BEGIN
										EXEC p0040_GRADE_MASTER @Grd_ID OUTPUT ,@Cmp_ID,0,@Grd_Name,@Grd_Name,0,'I',0,0,0,''
									END  
								ELSE  
									BEGIN 
										INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Grade Name is Not Proper',@Grd_Name,'Please Enter Grade Name',GETDATE(),'Employee Master','')  
										SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
									END    
							END	
					end
				Else
					Begin
						IF EXISTS(SELECT Grd_ID FROM T0040_GRADE_Master WITH (NOLOCK) WHERE Grd_Name =@Grd_Name AND Cmp_ID=@Cmp_ID)  
							BEGIN  
								SELECT @Grd_ID = Grd_ID FROM T0040_GRADE_Master WITH (NOLOCK) WHERE Grd_Name =@Grd_Name AND Cmp_ID=@Cmp_ID 
							END
						Else
							BEGIN
							print 'grade'
								INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Grade Name Not Exits',@Emp_Superior,'Enter Correct Grade Name',GETDATE(),'Employee Master','')  
								SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
								Goto ABC;
						    END
					End
			
				if @Restrict_Other_Master <> 0
					Begin
						IF EXISTS(SELECT Dept_ID FROM T0040_Department_Master WITH (NOLOCK) WHERE Dept_Name =@Dept_Name AND Cmp_ID=@Cmp_ID)  
							BEGIN  
								SELECT @Dept_ID = Dept_ID FROM T0040_Department_Master WITH (NOLOCK) WHERE Dept_Name =@Dept_Name AND Cmp_ID=@Cmp_ID  
							END  
						ELSE  
							BEGIN        
								IF @Dept_Name <> ''  
									BEGIN  
										EXEC P0040_DEPARTMENT_MASTER @Dept_ID OUTPUT ,@Cmp_ID,@Dept_Name,0,'','I'
									END   
								ELSE  
									BEGIN  
										SET @Dept_ID = NULL  
									END  
							END
					END
				Else
					BEGIN
					  IF EXISTS(SELECT Dept_ID FROM T0040_Department_Master WITH (NOLOCK) WHERE Dept_Name =@Dept_Name AND Cmp_ID=@Cmp_ID)  
							BEGIN  
								SELECT @Dept_ID = Dept_ID FROM T0040_Department_Master WITH (NOLOCK) WHERE Dept_Name =@Dept_Name AND Cmp_ID=@Cmp_ID  
							END
					  Else
							BEGIN
								IF @Dept_Name <> '' or @Dept_Name is not null
									Begin
										print 'Department'
										INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Department Name Not Exits',@Emp_Superior,'Enter Correct Department Details',GETDATE(),'Employee Master','')  
										SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
										Goto ABC;
									End
								ELSE  
									BEGIN  
										SET @Dept_ID =NULL  
									END
						    END
					End
				
				if @Restrict_Other_Master <> 0
					Begin
						IF EXISTS(SELECT Desig_ID FROM T0040_Designation_Master WITH (NOLOCK) WHERE Desig_Name =@desig_Name AND Cmp_ID=@Cmp_ID)  
							BEGIN  
								SELECT @Desig_ID = Desig_ID FROM T0040_Designation_Master WITH (NOLOCK) WHERE Desig_Name =@desig_Name AND Cmp_ID=@Cmp_ID
							END  
					    ELSE  
							BEGIN  
								IF @Desig_Name IS NOT NULL  
									BEGIN 
										Declare @Desig_Code Varchar(5)
										Declare @Desig_Code2 Varchar(5)
										Declare @TEMP_DESIG_NAME Varchar(100)
										SET @Desig_Code = NULL
										SET @Desig_Code2 = NULL
										--Set @Desig_Code = LEFT(@Desig_Name,3) -- Commented By Ramiz on 12/12/2016 , **Case:- If We Import 2 employees Senior Developer & Senior Tester , then Designation Code will become Same , so this will not work
										
										SET @TEMP_DESIG_NAME = REPLACE(REPLACE(REPLACE(REPLACE(@DESIG_NAME , '.' , ''), '-', ''), '(',''),')','');
										Set @Desig_Code2 = LEFT(REPLACE(@TEMP_DESIG_NAME, ' ',''),3)
								
										
										IF (CHARINDEX(' ', @temp_Desig_Name) > 0)
											BEGIN
												SELECT	@Desig_Code = COALESCE(@Desig_Code,'') +  left(data, 1)
												FROM	dbo.Split(@temp_Desig_Name, ' ' )	
												
											END
										
										SET @Desig_Code =  ISNULL(@Desig_Code, @Desig_Code2);										
										
										
										IF  EXISTS(SELECT 1 FROM T0040_DESIGNATION_MASTER WITH (NOLOCK) 
													WHERE	Desig_Code = @Desig_Code  AND Cmp_ID=@Cmp_ID)
											BEGIN 
												DECLARE @INDEX INT
												SELECT	@INDEX = IsNull(COUNT(1),0) + 1
												FROM	T0040_DESIGNATION_MASTER WITH (NOLOCK)
												WHERE	Desig_Code LIKE @Desig_Code + '_%' AND Cmp_ID=@Cmp_ID
												
												SET @Desig_Code = @Desig_Code + '_' + CAST(@INDEX AS VARCHAR(2))

												
												--IF  EXISTS(SELECT 1 FROM T0040_DESIGNATION_MASTER
												--	WHERE	Desig_Code = @Desig_Code2  AND Cmp_ID=@Cmp_ID)
												--	BEGIN 
														
												--		SELECT	@INDEX = COUNT(1) 
												--		FROM	T0040_DESIGNATION_MASTER
												--		WHERE	Desig_Code = @Desig_Code2  AND Cmp_ID=@Cmp_ID
												--		SET @Desig_Code = UPPER(@temp_Desig_Name);
												--	END
												--ELSE
												--	SET @Desig_Code = UPPER(@Desig_Code2);
											END
										
										EXEC P0040_DESIGNATION_MASTER @Desig_ID OUTPUT ,@Cmp_ID,@Desig_Name,0,0,0,0,'I','',0,'',0,@Desig_Code,1,null,'',0
									END  
								ELSE  
									BEGIN  
										print 'Designation'
										INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Designation Name is Not Proper',@Desig_Name,'Please Enter Designation Name',GETDATE(),'Employee Master','')  
										SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
										Goto ABC;
									END    
							END
					End
				Else
					Begin
						IF EXISTS(SELECT Desig_ID FROM T0040_Designation_Master WITH (NOLOCK) WHERE Desig_Name =@desig_Name AND Cmp_ID=@Cmp_ID)  
							BEGIN  
								SELECT @Desig_ID = Desig_ID FROM T0040_Designation_Master WITH (NOLOCK) WHERE Desig_Name =@desig_Name AND Cmp_ID=@Cmp_ID
							END
						Else
							Begin
								print 'Designation'
								INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Designation Name Not Exits',@Emp_Superior,'Enter Correct Designation Details',GETDATE(),'Employee Master','')  
								SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
								Goto ABC;
							End
					End  
					 
				if @Restrict_Other_Master <> 0
					Begin
						IF EXISTS(SELECT TYPE_ID FROM T0040_TYPE_Master WITH (NOLOCK) WHERE TYPE_NAME =@Type_Name AND Cmp_ID=@Cmp_ID)  
							BEGIN  
								SELECT @Type_ID = TYPE_ID FROM T0040_TYPE_Master WITH (NOLOCK) WHERE TYPE_NAME =@Type_Name AND Cmp_ID=@Cmp_ID 
							END  
						ELSE  
							BEGIN  
								IF @Type_Name is not NULL  
									BEGIN  
										EXEC P0040_TYPE_MASTER @Type_ID OUTPUT ,@Cmp_ID,@Type_Name,0,0,'I'  
									END  
								ELSE  
									BEGIN  
										INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Type Name is Not Proper',@Type_Name,'Please Enter Type Name',GETDATE(),'Employee Master','')  
										SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
										Goto ABC;
									END    
							END
					End
				Else
					Begin
						IF EXISTS(SELECT TYPE_ID FROM T0040_TYPE_Master WITH (NOLOCK) WHERE TYPE_NAME =@Type_Name AND Cmp_ID=@Cmp_ID)  
							BEGIN  
								SELECT @Type_ID = TYPE_ID FROM T0040_TYPE_Master WITH (NOLOCK) WHERE TYPE_NAME =@Type_Name AND Cmp_ID=@Cmp_ID 
							END
						Else
							Begin
								print 'Employee Type'
								INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Employee Type Name Not Exits',@Emp_Superior,'Enter Correct Employee Type Details',GETDATE(),'Employee Master','')  
								SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
								Goto ABC;
							End
					End 
				
				
				if @Restrict_Other_Master <> 0
					Begin
						IF EXISTS(SELECT Shift_ID FROM T0040_SHIFT_MASTER WITH (NOLOCK) WHERE Shift_Name =@Shift_Name  AND Cmp_ID=@Cmp_ID)  
							BEGIN  
								SELECT @Shift_ID = Shift_ID FROM T0040_SHIFT_MASTER WITH (NOLOCK) WHERE Shift_Name =@Shift_Name  AND Cmp_ID=@Cmp_ID 
							END  
						ELSE  
							BEGIN  
								IF @Shift_Name is not NULL
									BEGIN  
										EXEC P0040_Shift_Master @Shift_ID OUTPUT ,@Cmp_ID,@Shift_Name,'09:00','17:00','08:00','09:00','17:00','08:00','','','','','','','I'  
									END  
								ELSE  
									BEGIN  
										INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Shift Name is Not Proper',@Shift_Name,'Please Enter Shift Name',GETDATE(),'Employee Master','')  
										SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
									END     
							END
					End
				Else
					Begin
						IF EXISTS(SELECT Shift_ID FROM T0040_SHIFT_MASTER WITH (NOLOCK) WHERE Shift_Name =@Shift_Name  AND Cmp_ID=@Cmp_ID)  
							BEGIN  
								PRINT 'sh'
								SELECT @Shift_ID = Shift_ID FROM T0040_SHIFT_MASTER WITH (NOLOCK) WHERE Shift_Name =@Shift_Name  AND Cmp_ID=@Cmp_ID 
							END
						Else
							Begin
								print 'shift'
								INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Shift Name Not Exits',@Emp_Superior,'Enter Correct Shift Details',GETDATE(),'Employee Master','')  
								SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
								Goto ABC;
							End
					End
					
				 
				if @Restrict_Other_Master <> 0
					Begin
						IF EXISTS(SELECT Bank_ID FROM T0040_Bank_Master WITH (NOLOCK) WHERE Bank_Name = @Bank_Name AND Cmp_ID=@Cmp_ID)  
							BEGIN  
						SELECT @Bank_ID = Bank_ID FROM T0040_Bank_Master WITH (NOLOCK) WHERE Bank_Name = @Bank_Name AND Cmp_ID=@Cmp_ID  
							END  
						ELSE  
							BEGIN  
								IF @Bank_Name <> ''
									BEGIN  
										DECLARE @Bank_Code VARCHAR(10) , @Bank_Branch_Name VARCHAR(50) 
										SET @Bank_Code = LEFT(@Bank_Name,3)  

										Select @Bank_Branch_Name = Cmp_City from T0010_COMPANY_MASTER Where Cmp_ID=@Cmp_ID 
										
										EXEC P0040_BANK_MASTER @Bank_ID OUTPUT ,@Cmp_ID,@Bank_Code,@Bank_Name,'00000000','',@Bank_Branch_Name,'','N','I',@Emp_IFSC_No  
									END  
								ELSE  
									BEGIN  
										SET @Bank_ID =NULL  
									END  
							END
					End
				Else
					Begin
						IF EXISTS(SELECT Bank_ID FROM T0040_Bank_Master WITH (NOLOCK) WHERE Bank_Name =@Bank_Name AND Cmp_ID=@Cmp_ID)  
							BEGIN  
								SELECT @Bank_ID = Bank_ID FROM T0040_Bank_Master WITH (NOLOCK) WHERE Bank_Name =@Bank_Name AND Cmp_ID=@Cmp_ID  
							END
						Else
							Begin
								IF @Bank_Name is not NULL
									BEGIN
										print 'Bank'
										INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Bank Name Not Exits',@Emp_Superior,'Enter Correct Bank Details',GETDATE(),'Employee Master','')  
										SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
										Goto ABC;
									END
								ELSE  
									BEGIN  
										SET @Bank_ID =NULL  
									END
							End
					End	
				 
				if @Restrict_Other_Master <> 0
					Begin
						IF EXISTS(SELECT Curr_ID FROM T0040_Currency_MAster  WITH (NOLOCK)  WHERE Curr_Name =@Curr_Name AND Cmp_ID=@Cmp_ID)  
							BEGIN  
								SELECT @Curr_ID = Curr_ID FROM T0040_Currency_MAster WITH (NOLOCK) WHERE Curr_Name =@Curr_Name AND Cmp_ID=@Cmp_ID 
							END  
						ELSE  
							BEGIN  
								IF @Curr_Name <> ''  
									BEGIN  
										EXEC P0040_CURRENCY_MASTER @Curr_ID OUTPUT ,@Cmp_ID,@Curr_Name,0,'N','','','I'  
									END  
								ELSE  
									BEGIN  
										SET @Curr_ID = NULL  
									END    
							END
					End
				Else
					Begin
						IF EXISTS(SELECT Curr_ID FROM T0040_Currency_MAster WITH (NOLOCK) WHERE Curr_Name =@Curr_Name AND Cmp_ID=@Cmp_ID)  
							BEGIN  
								SELECT @Curr_ID = Curr_ID FROM T0040_Currency_MAster WITH (NOLOCK) WHERE Curr_Name =@Curr_Name AND Cmp_ID=@Cmp_ID 
							END
						Else
							Begin
								print 'Currency'
								INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Currency Code Not Exits',@Emp_Superior,'Enter Correct Currency Details',GETDATE(),'Employee Master','')  
								SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
								Goto ABC;
							End
					End
				
				if @Restrict_Other_Master <> 0
					Begin
						IF EXISTS(SELECT Cat_ID FROM T0030_Category_master WITH (NOLOCK) WHERE Cat_Name =@Product_name AND Cmp_ID=@Cmp_ID)  
							BEGIN    
								SELECT @Cat_ID = Cat_ID FROM T0030_Category_master WITH (NOLOCK) WHERE Cat_Name =@Product_name AND Cmp_ID=@Cmp_ID  
							END  
						ELSE  
							BEGIN  
								IF @Product_name <> ''  
									BEGIN  
										EXEC P0030_Category_master @Cat_ID OUTPUT ,@Product_name,@Cmp_ID,'','I'  
									END   
								ELSE  
									BEGIN  
										SET @Cat_ID = NULL  
									END    
							END
					End
				Else
					Begin
						IF EXISTS(SELECT Cat_ID FROM T0030_Category_master WITH (NOLOCK) WHERE Cat_Name =@Product_name AND Cmp_ID=@Cmp_ID)  
							BEGIN    
								SELECT @Cat_ID = Cat_ID FROM T0030_Category_master WITH (NOLOCK) WHERE Cat_Name =@Product_name AND Cmp_ID=@Cmp_ID  
							END
						Else
							Begin
								IF @Product_name <> '' or @Product_name is not null
									Begin
									print 'Cat'
										INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Category Name Not Exits',@Emp_Superior,'Enter Correct Category Details',GETDATE(),'Employee Master','')  
										SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
										Goto ABC;
									End
								Else
									Begin
										SET @Cat_ID = NULL
									End
							End
					End
					
				if @Restrict_Other_Master <> 0
					Begin
						IF EXISTS(SELECT Segment_ID FROM T0040_Business_Segment WITH (NOLOCK) WHERE Segment_Name = @Business_Segment AND Cmp_ID = @Cmp_ID )
							BEGIN
								SELECT @Segment_ID = Segment_ID FROM T0040_Business_Segment WITH (NOLOCK) WHERE Segment_Name = @Business_Segment AND Cmp_ID = @Cmp_ID
							END
						ELSE
							BEGIN
								IF @Business_Segment <> ''
									BEGIN
										Declare @Segment_Code As Varchar(50)					
										Set @Segment_Code = Substring(@Business_Segment,1,3)
										
										IF  EXISTS(SELECT 1 FROM T0040_Business_Segment WITH (NOLOCK) 
													WHERE	Segment_Code = @Segment_Code  AND Cmp_ID=@Cmp_ID)
											BEGIN 
												DECLARE @INDEX_SEG INT
												SELECT	@INDEX_SEG = IsNull(COUNT(1),0) + 1
												FROM	T0040_Business_Segment WITH (NOLOCK)
												WHERE	Segment_Code LIKE @Segment_Code + '_%' AND Cmp_ID=@Cmp_ID
												
												SET @Segment_Code = @Segment_Code + '_' + CAST(@INDEX_SEG AS VARCHAR(2))
											END

										EXEC P0040_BUSINESS_SEGEMENT @Segment_ID OUTPUT,@cmp_ID,@Segment_Code,@Business_Segment,'','I'
									END
								ELSE
									BEGIN
										SET @Segment_ID = NULL
									END
							END
					End
				Else
					Begin
						IF EXISTS(SELECT Segment_ID FROM T0040_Business_Segment WITH (NOLOCK) WHERE Segment_Name = @Business_Segment AND Cmp_ID = @Cmp_ID )
							BEGIN
								SELECT @Segment_ID = Segment_ID FROM T0040_Business_Segment WITH (NOLOCK) WHERE Segment_Name = @Business_Segment AND Cmp_ID = @Cmp_ID
							END
						Else
							Begin
								IF @Business_Segment <> '' or @Business_Segment is not null
									Begin
										print 'Business'
										INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Business Segment Name Not Exits',@Emp_Superior,'Enter Correct Business Segment Details',GETDATE(),'Employee Master','')  
										SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
										Goto ABC;
									End
								Else
									Begin
										SET @Segment_ID = NULL
									End
							End
					End
					
					
				 if @Restrict_Other_Master <> 0
					Begin
						IF EXISTS(SELECT Vertical_ID FROM T0040_Vertical_Segment WITH (NOLOCK) WHERE Vertical_Name = @Vertical AND Cmp_ID = @Cmp_ID )
							BEGIN
								SELECT @Vertical_ID = Vertical_ID FROM T0040_Vertical_Segment WITH (NOLOCK) WHERE Vertical_Name = @Vertical AND Cmp_ID = @Cmp_ID
							END
						ELSE
							BEGIN
								IF @Vertical <> ''
									BEGIN
										
										Declare @Vertical_Code As Varchar(50)			
										Set @Vertical_Code = Substring(@Vertical,1,3)	
										
										IF  EXISTS(SELECT 1 FROM T0040_Vertical_Segment WITH (NOLOCK) 
													WHERE	Vertical_Code = @Vertical_Code  AND Cmp_ID=@Cmp_ID)
											BEGIN 
												DECLARE @INDEXX INT
												SELECT	@INDEXX = IsNull(COUNT(1),0) + 1
												FROM	T0040_Vertical_Segment WITH (NOLOCK)
												WHERE	Vertical_Code LIKE @Vertical_Code + '_%' AND Cmp_ID=@Cmp_ID
												
												SET @Vertical_Code = @Vertical_Code + '_' + CAST(@INDEXX AS VARCHAR(2))
											END

										EXEC P0040_Vertical @Vertical_ID OUTPUT,@cmp_ID, @Vertical_Code, @Vertical, '', 'I'
									END

								ELSE
									BEGIN
										SET @Vertical_ID = NULL
									END
							END
					End
				 Else
					Begin
						IF EXISTS(SELECT Vertical_ID FROM T0040_Vertical_Segment WITH (NOLOCK) WHERE Vertical_Name = @Vertical AND Cmp_ID = @Cmp_ID )
							BEGIN
								SELECT @Vertical_ID = Vertical_ID FROM T0040_Vertical_Segment WITH (NOLOCK) WHERE Vertical_Name = @Vertical AND Cmp_ID = @Cmp_ID
							END
						Else
							Begin
								IF @Vertical <> '' or @Vertical is not null
									Begin 
										INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Vertical Name Not Exits',@Emp_Superior,'Enter Correct Vertical Details',GETDATE(),'Employee Master','')  
										SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
										Goto ABC;
									End
								Else
									Begin
										SET @Vertical_ID = NULL
									End
							End
					End	
				 	
				if @Restrict_Other_Master <> 0
					Begin
						IF EXISTS(SELECT SubVertical_ID FROM T0050_SubVertical WITH (NOLOCK) WHERE SubVertical_Name = @Sub_Vertical AND Vertical_ID = @Vertical_ID AND Cmp_ID = @Cmp_ID )
							BEGIN
								SELECT @SubVertical_ID = SubVertical_ID FROM T0050_SubVertical WITH (NOLOCK) WHERE SubVertical_Name = @Sub_Vertical AND Vertical_ID = @Vertical_ID AND Cmp_ID = @Cmp_ID
							END
						ELSE
							BEGIN
								IF @Sub_Vertical <> ''
									BEGIN
										Declare @SubVertical_Code As Varchar(50)			
										Set @SubVertical_Code = Substring(@sub_Vertical,1,3)	

										IF  EXISTS(SELECT 1 FROM T0050_SubVertical WITH (NOLOCK) 
													WHERE	SubVertical_Code = @SubVertical_Code  AND Cmp_ID=@Cmp_ID)
											BEGIN 
												DECLARE @INDEX_SUB INT
												SELECT	@INDEX_SUB = IsNull(COUNT(1),0) + 1
												FROM	T0050_SubVertical WITH (NOLOCK)
												WHERE	SubVertical_Code LIKE @SubVertical_Code + '_%' AND Cmp_ID=@Cmp_ID
												
												SET @SubVertical_Code = @SubVertical_Code + '_' + CAST(@INDEX_SUB AS VARCHAR(2))
											END

										EXEC P0050_SubVertical @subvertical_ID OUTPUT,@cmp_ID,@Vertical_ID,@SubVertical_Code,@sub_Vertical,'','I'
									END
								 ELSE
									BEGIN
										SET @SubVertical_ID = NULL
									END
							END
					End
				Else
					Begin
						IF EXISTS(SELECT SubVertical_ID FROM T0050_SubVertical WITH (NOLOCK) WHERE SubVertical_Name = @Sub_Vertical AND Vertical_ID = @Vertical_ID AND Cmp_ID = @Cmp_ID )
							BEGIN
								SELECT @SubVertical_ID = SubVertical_ID FROM T0050_SubVertical WITH (NOLOCK) WHERE SubVertical_Name = @Sub_Vertical AND Vertical_ID = @Vertical_ID AND Cmp_ID = @Cmp_ID
							END
						Else
							Begin
								IF @Sub_Vertical <> '' or @Sub_Vertical is not null
									Begin
										print 'sub Vertical'
										INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Sub-Vertical Name Not Exits',@Emp_Superior,'Enter Correct Sub-Vertical Details',GETDATE(),'Employee Master','')  
										SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
										Goto ABC;
									End
								Else
									Begin
										SET @SubVertical_ID = NULL
									End
							End
					End
					
				
				if @Restrict_Other_Master <> 0
					Begin
						IF EXISTS(SELECT SubBranch_ID FROM T0050_SubBranch WITH (NOLOCK) WHERE SubBranch_Name = @Sub_Branch AND Branch_ID = @Branch_ID AND Cmp_ID = @Cmp_ID )
							BEGIN
								SELECT @SubBranch_ID = SubBranch_ID FROM T0050_SubBranch WITH (NOLOCK) WHERE SubBranch_Name = @sub_Branch AND Branch_ID = @Branch_ID AND Cmp_ID = @Cmp_ID
							END
						ELSE
							BEGIN
								IF @sub_Branch <> '' 
									BEGIN
										Declare @SubBranch_Code As Varchar(50)					
										Set @SubBranch_Code = Substring(@sub_Branch,1,3)	
										

									--Added by ronakk 22082022

										IF  EXISTS(SELECT 1 FROM T0050_SubBranch WITH (NOLOCK) 
													WHERE	SubBranch_Code = @SubBranch_Code  AND Cmp_ID=@Cmp_ID)
											BEGIN 
												DECLARE @INDEX_SUBB INT
												SELECT	@INDEX_SUBB = IsNull(COUNT(1),0) + 1
												FROM	T0050_SubBranch WITH (NOLOCK)
												WHERE	SubBranch_Code LIKE @SubBranch_Code + '_%' AND Cmp_ID=@Cmp_ID
												
												SET @SubBranch_Code = @SubBranch_Code + '_' + CAST(@INDEX_SUBB AS VARCHAR(2))
											END

								  --End by ronakk 22082022

										EXEC P0050_SubBranch @subBranch_ID OUTPUT,@cmp_ID,@Branch_ID,@SubBranch_Code,@sub_Branch,'','I'
									END
								ELSE
									BEGIN
										SET @SubBranch_ID = NULL
									END
						END
					End
				Else
					Begin
					  IF EXISTS(SELECT SubBranch_ID FROM T0050_SubBranch WITH (NOLOCK) WHERE SubBranch_Name = @Sub_Branch AND Branch_ID = @Branch_ID AND Cmp_ID = @Cmp_ID )
							BEGIN
								SELECT @SubBranch_ID = SubBranch_ID FROM T0050_SubBranch WITH (NOLOCK) WHERE SubBranch_Name = @sub_Branch AND Branch_ID = @Branch_ID AND Cmp_ID = @Cmp_ID
							END
					  Else
							Begin
								IF @sub_Branch <> '' or @sub_Branch is not null
									Begin
										print 'Sub Branch'
										INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Sub-Branch Name Not Exits',@Emp_Superior,'Enter Correct Sub-Branch Details',GETDATE(),'Employee Master','')  
										SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
										Goto ABC;
									End
								Else
									Begin
										SET @sub_Branch = NULL
									End
							End
					End		
					
				
				IF @Salary_Cycle <> '0'
					BEGIN 
						
						IF NOT EXISTS(SELECT Tran_ID FROM dbo.T0040_Salary_Cycle_Master WITH (NOLOCK) WHERE Name = @Salary_Cycle AND Cmp_Id = @Cmp_ID)  
							BEGIN   
								print 'salary Cycle'   
								INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Salary Cycle Not Exits',@Emp_Superior,'Please First Add Salary Cycle In Master',GETDATE(),'Employee Master','')  
								SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
								--Set @Status_Details = cast(@Emp_Code as varchar(100)) + ',' 
								
							END  
						ELSE  
							BEGIN  
								SELECT @Salary_Cycle_ID = Tran_ID FROM dbo.T0040_Salary_Cycle_Master WITH (NOLOCK) WHERE Cmp_Id = @cmp_Id AND Name = @Salary_Cycle  
							END     
					END
				
				-- Added by Gadriwala Muslim 09022015 - Start
				IF @Emp_Superior <> '0' 
						BEGIN 
								print @Log_Status
								IF NOT EXISTS(SELECT Emp_Id FROM dbo.T0080_Emp_Master WITH (NOLOCK) WHERE Alpha_Emp_Code=@Emp_Superior AND Cmp_Id=@Cmp_ID)  
									BEGIN  
										INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Superior Code Not Exits',@Emp_Superior,'Please First ALTER Employee To Assign',GETDATE(),'Employee Master','')  
										SET @Log_Status=1
										RETURN  
									END  
								ELSE  
									BEGIN  
										SELECT @emp_Id_sup = Emp_Id FROM dbo.T0080_Emp_Master WITH (NOLOCK) WHERE Cmp_Id=@cmp_Id AND Alpha_Emp_Code=@Emp_Superior  
									END 
									  
						END   
				-- Added by Gadriwala Muslim 09022015 - End	
				
				
				-- Added by Nilesh Patel on 08082015 - Start
				
				if @Pay_Scale_Name = ''
					Set @Pay_Scale_Name = NULL
				
				SET @Pay_Scale_ID = 0	
				IF @Pay_Scale_Name is not null  
						BEGIN 
								IF NOT EXISTS(SELECT Pay_Scale_ID FROM dbo.T0040_PAY_SCALE_MASTER WITH (NOLOCK) WHERE Pay_Scale_Name = @Pay_Scale_Name AND Cmp_Id = @Cmp_ID)  
									BEGIN   
									print 'pay cycle'   
										INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Pay Scale Details Not Exits',@Pay_Scale_Name,'Please First Add Pay Scale In Master',GETDATE(),'Employee Master','')  
										SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
										Goto ABC; 
									END  
								ELSE  
									BEGIN  
										SELECT @Pay_Scale_ID = Pay_Scale_ID FROM dbo.T0040_PAY_SCALE_MASTER WITH (NOLOCK) WHERE Cmp_Id = @cmp_Id AND Pay_Scale_Name = @Pay_Scale_Name  
									END       
						END   
				-- Added by Nilesh Patel on 08082015 - End	
				
				IF @Cat_ID = 0  
					SET @Cat_ID = NULL  
			 
				IF @Dept_ID = 0  
					SET @Dept_ID = NULL   
					
				IF @Desig_Id = 0  
					SET @Desig_Id = NULL 
					 
				IF @Type_ID =0  
					SET @Type_ID = NULL  
			 
				IF @Loc_ID =0  
					SET @Loc_ID = NULL  
		
				IF @Curr_ID =0  
					SET @Curr_ID = NULL  
			 
				IF @Bank_ID =0  
					SET @Bank_ID = NULL  
				
				--IF @Payment_Mode IS NULL
				--	SET @Payment_Mode= 'Cash'  
				
				IF @Inc_Bank_AC_No IS NULL
					SET @Inc_Bank_AC_No = NULL  
			 
				IF @Confirm_Date IS NULL
					SET @Confirm_Date = NULL
					  
				IF @Segment_ID = 0
					SET @Segment_ID = NULL	
			   
				IF @Vertical_ID  = 0
					SET @Vertical_ID = NULL 
			 
				IF @SubVertical_ID = 0 
					SET @SubVertical_ID = NULL 
			  
				IF @SubBranch_ID = 0 
					SET @SubBranch_ID = NULL  
			  
				IF @Group_of_Joining IS NULL or @Group_of_Joining ='1900-01-01 00:00:00.000'
					SET @Group_of_Joining = NULL  
					
				IF IsNull(@Date_Of_Join, '1900-01-01') = '1900-01-01'
					BEGIN  
						INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Date Of Join is Not Proper',NULL,'Enter Date Of Join Proper It Must be dd-MMM-yyyy',GETDATE(),'Employee Master','')  
						SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
						SET @Emp_ID = 0   
					END   
				--added by jimit 23062017
				IF (Cast(@Marital_Status As INT) > 3 or Cast(@Marital_Status AS INT) < 0)
					BEGIN
						INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Marital Status is Not Proper',NULL,'Enter Marital Status should be < 3',GETDATE(),'Employee Master','')  
						SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
						SET @Emp_ID = 0   
					END
				
				IF @Emp_Code = 0  
					BEGIN        
						INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Employee Code is Null Or 0 Or Was Not Properly Inserted',@Emp_Code,'Enter Employee Code Proper',GETDATE(),'Employee Master','')     
					END  
		    
				IF @Emp_First_Name IS NULL 
					BEGIN  
						print 'emp full name '
						INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Employee First Name is Null Was Not Properly Inserted',@Emp_Code,'Enter Proper Employee First Name',GETDATE(),'Employee Master','')     
						SET @HasResult = cast(@Emp_Code as varchar(100)) + ',' 
						--Set @Status_Details = @Status_Details + cast(@Emp_Code as varchar(100)) + ','
					END  
				
				IF @Emp_Code=0 OR @Date_Of_Join Is NULL OR @Shift_Name Is NULL OR @Type_Name Is NULL OR @Desig_Name Is NULL OR @Grd_Name Is NULL OR @LOC_Name Is NULL OR @Branch_Name Is NULL OR @Emp_ID=0  
				 BEGIN 
					SET @HasResult = cast(@Emp_Code as varchar(100)) + ',' 
					--Set @Status_Details = @Status_Details + cast(@Emp_Code as varchar(100)) + ','
				 END

				 if Isnull(@Enroll_No,0) <> 0
					Begin
						IF Exists(Select 1 From T0010_COMPANY_MASTER WITH (NOLOCK) Where Cmp_Id = @Cmp_ID and is_GroupOFCmp = 1)
							Begin
								if Object_ID('tempdb..#GroupCompany') is not NULL
									BEGIN
										Drop TABLE #GroupCompany
									End

								Create table #GroupCompany(Cmp_ID Numeric(18,0))

								insert into #GroupCompany 
								Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1

								IF Exists(Select 1 From T0080_EMP_MASTER EM WITH (NOLOCK) Inner Join #GroupCompany GC ON EM.Cmp_ID = GC.Cmp_ID Where EM.Enroll_No = @Enroll_No AND Emp_Left_Date is null)
									Begin 
										INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Employee Enroll No. is exists so please check it.',@Emp_Code,'Employee Enroll No. is exists so please check it.',GETDATE(),'Employee Master','')     
										SET @HasResult = cast(@Emp_Code as varchar(100)) + ',' 
										SET @Log_Status=1
										RETURN 
									End

							End
						Else 
							Begin
								IF Exists(Select 1 From T0080_EMP_MASTER EM  WITH (NOLOCK) Where EM.Enroll_No = @Enroll_No AND Emp_Left_Date is null)
									Begin 
										INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Employee Enroll No. is exists so please check it.',@Emp_Code,'Employee Enroll No. is exists so please check it.',GETDATE(),'Employee Master','')     
										SET @HasResult = cast(@Emp_Code as varchar(100)) + ',' 
										SET @Log_Status=1
										RETURN 
									End
							End
					END
				
				-----------Added By Jimit 08012018--------------
				if @Esic_no = ''
					Set @Esic_no = NULL
				
				if @Pf_No = ''
					Set @Pf_No = NULL
					
				if @Pan_No = ''
					Set @Pan_No = NULL

				
				if @Esic_no Is Not Null or @Pf_No Is Not Null or @Pan_No Is Not Null or @Inc_Bank_Ac_No is not null  -- Added by Hardik 26/06/2020 for Bug id 9023, @Inc_Bank_AC_No
					BEGIN
							IF Object_ID('tempdb..#COLUMN_VALUE') is null
								BEGIN		
										CREATE TABLE #COLUMN_VALUE
										(      
											COLUMN_NAME  Varchar(50),
											COLUMN_VALUE Varchar(50)							
										)							
								END	

					END
				
				if @Esic_no Is Not Null
					BEGIN
						 INSERT INTO #COLUMN_VALUE(COLUMN_NAME,Column_Value)
						 EXEC P_EMP_UAN_PAN_VALIDATION @Cmp_ID,@Emp_ID,@Emp_First_Name,@Emp_Last_Name,@Date_OF_Birth,'','ESIC',@Esic_no
						 
						 
						 
						 IF EXISTS(SELECT 1 FROM #COLUMN_VALUE)
							BEGIN
								  INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'ESIC No is alredy Exist',@Emp_Code,'Enter Proper ESIC No',GETDATE(),'Employee Master','')     
								  SET @HasResult = cast(@Emp_Code as varchar(100)) + ',' 
								  
								  DELETE FROM #COLUMN_VALUE
							END
							
						 
					END
				if @Pf_No Is Not Null
					BEGIN					
						
						 INSERT INTO #COLUMN_VALUE(COLUMN_NAME,Column_Value)
						 EXEC P_EMP_UAN_PAN_VALIDATION @Cmp_ID,@Emp_ID,@Emp_First_Name,@Emp_Last_Name,@Date_OF_Birth,'','PF',@Pf_No
						 
						 IF EXISTS(SELECT 1 FROM #COLUMN_VALUE)
							BEGIN
								  INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'PF No is alredy Exist',@Emp_Code,'Enter Proper PF No',GETDATE(),'Employee Master','')     
								  SET @HasResult = cast(@Emp_Code as varchar(100)) + ',' 
								  
								  DELETE FROM #COLUMN_VALUE
								  
							END
							
						
					END

				if @Pan_No Is Not Null
					BEGIN
		 						 
						 INSERT INTO #COLUMN_VALUE(COLUMN_NAME,Column_Value)
						 EXEC P_EMP_UAN_PAN_VALIDATION @Cmp_ID,@Emp_ID,@Emp_First_Name,@Emp_Last_Name,@Date_OF_Birth,'','PAN',@Pan_No
	 
						 IF EXISTS(SELECT 1 FROM #COLUMN_VALUE)
							BEGIN
								  INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'PAN No is alredy Exist',@Emp_Code,'Enter Proper PAN No',GETDATE(),'Employee Master','')     
								  SET @HasResult = cast(@Emp_Code as varchar(100)) + ',' 
								  
								 DELETE FROM #COLUMN_VALUE 
								  
							END
					END
				-----------ended-----------------
				
				--added by Krushna 12032020
				if @Inc_Bank_Ac_No is not NULL
					BEGIN
					
						 INSERT INTO #COLUMN_VALUE(COLUMN_NAME,Column_Value)
						 EXEC P_EMP_UAN_PAN_VALIDATION @Cmp_ID,@Emp_ID,@Emp_First_Name,@Emp_Last_Name,@Date_OF_Birth,'','BANK_ACCOUNT',@Inc_Bank_Ac_No
						 
						 IF EXISTS(SELECT 1 FROM #COLUMN_VALUE)
							BEGIN
								INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Bank Account No is alredy Exist',@Emp_Code,'Enter Proper Bank Account',GETDATE(),'Employee Master','')
								SET @HasResult = cast(@Emp_Code as varchar(100)) + ',' 
								DELETE FROM #COLUMN_VALUE 
							END
					END
				--End Krushna
				
				 --ADDED BY MUKTI(09072020)START
				 
				DECLARE @AGE NUMERIC				
				DECLARE @MaxAgeLimit INT
				SET @AGE = dbo.F_GET_AGE (@Date_Of_Birth,GETDATE(),'N','N')
				SELECT @MaxAgeLimit = Setting_Value from T0040_SETTING WITH (NOLOCK) where cmp_id = @Cmp_ID and Setting_Name='Maximum Age Limit for Employee Joining'
				
				IF @AGE >@MaxAgeLimit
				BEGIN				
					SET @ErrString='Employee Age is more than ' + ' ' +  cast(@MaxAgeLimit as varchar(15))  + ' ' + ' years'	
					INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,@ErrString,0,@ErrString,GETDATE(),'Employee Master','') 
					SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
					Goto ABC;
				END
			--ADDED BY MUKTI(09072020)END
				
				IF @Increment_ID = 0   
				  SET @Increment_ID= NULL
				 
				IF @Increment_ID <> 0   
				  SET @Increment_ID= NULL
				   
				Declare @Is_GroupOFCmp Numeric	--Hardik 12/11/2020 for Trident to check Duplicate Emp Code
				DECLARE @Is_Alpha_Numeric_Branchwise TINYINT --Hardik 12/11/2020 for Trident to check Duplicate Emp Code
				DECLARE @Max_Emp_Code Varchar(64)
				Set @Is_GroupOFCmp = 0
				Set @Is_Alpha_Numeric_Branchwise = 0

				
				SELECT @Domain_Name = Domain_Name,@Cmp_Code = Cmp_Code,@Is_Auto_Alpha_Numeric_Code = Is_Auto_Alpha_Numeric_Code,
					@No_Of_Digits = No_Of_Digit_Emp_Code,@Is_GroupOFCmp = ISNULL(Is_GroupOFCmp,0), 
					@Is_Alpha_Numeric_Branchwise = isnull(Is_Alpha_Numeric_Branchwise,0),@Max_Emp_Code = Max_Emp_Code  
				FROM dbo.T0010_COMPANY_MASTER WITH (NOLOCK) WHERE CMP_ID = @CMP_ID  
			    
				IF SUBSTRING(@Domain_Name,1,1) <> '@'   
					SET @Domain_Name = '@' + @Domain_Name  
			   
				DECLARE @len AS NUMERIC(18,0)
				SET @len = LEN(CAST (@emp_code AS VARCHAR(20)))  
				
				IF @len > @No_Of_Digits  
					SET @len = @No_Of_Digits  
			   
				SELECT @Branch_Code = Branch_Code FROM T0030_BRANCH_MASTER WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND Branch_ID = @Branch_ID   
				declare @Get_Emp_code  as varchar(40)		
				declare @Get_Alpha_code  as varchar(10)
			   
				set @Get_Emp_code = ''	
				set @Get_Alpha_code = ''
				
				insert into #Emp_Code_Detail
				exec Get_Employee_Code @cmp_ID,@Branch_ID,@Date_Of_Join,@Get_Emp_Code output,@Get_Alpha_Code output,1 ,@Desig_Id,@Cat_ID,@Type_ID,@Date_OF_Birth

				if @Alpha_Code is NULL
				begin
					set @Alpha_Code = @Get_Alpha_Code
				end
				
				if @Is_Auto_Alpha_Numeric_Code = 1
					begin
						if @Emp_code <> 0 and @Alpha_Code <> ''
							begin
								set @Alpha_Emp_Code = @Alpha_Code +  REPLICATE ('0',@No_Of_Digits - @len) + Cast(@Emp_code as Varchar(20))
							end	
						else
							begin
								set @Alpha_Emp_Code =   REPLICATE ('0',@No_Of_Digits - @len) + Cast(@Emp_code as Varchar(20)) 
							end
					end
				 else
					begin
						set @Alpha_Emp_Code =  REPLICATE ('0',@No_Of_Digits - @len) + Cast(@Emp_code as Varchar(20)) 
					end
					
			   --Set @Emp_Full_Name = @Initial  + RTRIM(' ' + LTRIM(@Emp_First_Name)) + RTRIM(' ' + LTRIM(@Emp_Second_Name)) + RTRIM(' ' + LTRIM(@Emp_Last_Name)) 
			   --ADDED BY RAMIZ ON 21/01/2019
				If @Add_Initial_In_Emp_Full_Name = 1
					BEGIN 
						SET @Emp_Full_Name = @Initial  + RTRIM(' ' + LTRIM(@Emp_First_Name)) + RTRIM(' ' + LTRIM(@Emp_Second_Name)) + RTRIM(' ' + LTRIM(@Emp_Last_Name)) 
					END
				ELSE
					BEGIN 
						SET @Emp_Full_Name = RTRIM(LTRIM(@Emp_First_Name)) + RTRIM(' ' + LTRIM(@Emp_Second_Name)) + RTRIM(' ' + LTRIM(@Emp_Last_Name)) 
					END 
			   
			   --Added by Nilesh Patel on 29032019 -- For Kataria Client 
			   Declare @Employee_Strength_Setting tinyint
			   select @Employee_Strength_Setting = setting_value from T0040_SETTING WITH (NOLOCK) where cmp_id = @Cmp_ID and setting_name = 'Restrict Entry based on Employee Strength Master'
			   
			   IF @Employee_Strength_Setting = 1
				 Begin
					IF @Branch_ID > 0 AND @Desig_Id > 0
					Begin
						Declare @Branch_Desig_Wise_Count Numeric(18,0)
						Set @Branch_Desig_Wise_Count = 0

						Declare @Branch_Desig_Strength_Count Numeric(18,0)
						Set @Branch_Desig_Strength_Count = 0

						Select 
							@Branch_Desig_Wise_Count = Count(1)
						FROM
							(SELECT	
								I1.EMP_ID, I1.DESIG_ID, I1.BRANCH_ID
							FROM	T0095_INCREMENT I1 WITH (NOLOCK)
							INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON E.EMP_ID = I1.EMP_ID AND (E.Emp_Left_Date IS NULL OR ISNULL(Emp_Left,'N') = 'N')
							INNER JOIN (
										SELECT	
											MAX(I2.Increment_ID) AS Increment_ID, I2.Emp_ID
										FROM	T0095_INCREMENT I2 WITH (NOLOCK)
										INNER JOIN (
														SELECT	
															MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
														FROM	T0095_INCREMENT I3 WITH (NOLOCK)
														WHERE	I3.Increment_Effective_Date <= Getdate() AND Cmp_ID = @Cmp_ID
														GROUP BY I3.Emp_ID
													) I3 ON I2.Increment_Effective_Date=I3.INCREMENT_EFFECTIVE_DATE AND I2.Emp_ID=I3.Emp_ID																		
										WHERE	I2.Cmp_ID = @Cmp_Id 
										GROUP BY I2.Emp_ID
									) I2 ON I1.Emp_ID=I2.Emp_ID AND I1.Increment_ID=I2.INCREMENT_ID	
							WHERE	I1.Cmp_ID=@Cmp_Id	
							AND NOT EXISTS(SELECT 1 FROM T0200_EMP_EXITAPPLICATION EE WITH (NOLOCK) WHERE EE.EMP_ID = I1.EMP_ID AND EE.status NOT IN('R','LR'))									
							) I
						WHERE I.Branch_ID = @Branch_ID AND I.Desig_Id = @Desig_Id 

						Select @Branch_Desig_Strength_Count = ESM.Strength
							From T0040_Employee_Strength_Master ESM WITH (NOLOCK)
							INNER JOIN(
										Select Max(Effective_Date) as For_Date,Branch_ID,Desig_Id 
											From T0040_Employee_Strength_Master  WITH (NOLOCK)
										Where Branch_Id <> 0 and Desig_Id <> 0
										Group By Branch_ID,Desig_Id 
							) as Qry 
						ON ESM.Effective_Date = Qry.For_Date AND ESM.Branch_Id = Qry.Branch_Id AND ESM.Desig_Id = Qry.Desig_Id
						Where ESM.Branch_Id = @Branch_ID AND ESM.Desig_Id = @Desig_Id

						if @Branch_Desig_Wise_Count >= @Branch_Desig_Strength_Count
							Begin
								set @Emp_ID = 0
								INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Employee count is greater than set employee strength count in strength Master',0,'Check Employee Count Details in Employee Strength',GETDATE(),'Employee Master','')    
								SET @HasResult = cast(@Emp_Code as varchar(100)) + ',' 
							End
					End
				End 
			--Added by Nilesh Patel on 29032019 -- For Kataria Client

			   if @Alpha_Code = '' --Added by nilesh patel on 30072015
				Begin
					Set @Alpha_Code = NULL
				End 

			  DECLARE @validateEmail as int
			  IF (@Work_Email<>'') --Mukti(10112020)check for duplicate Official Email ID
				BEGIN
					IF EXISTS(SELECT 1 FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Work_Email =@Work_Email AND Alpha_Emp_Code <> @Alpha_Emp_Code AND Cmp_ID=@Cmp_ID)  
					BEGIN  
						INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Official Email ID already exist',0,'Official Email ID already exist',GETDATE(),'Employee Master','')  
						SET @HasResult = cast(@Emp_Code as varchar(100)) + ',' 
						SET @Log_Status=1   
						RETURN  
					END  

					
					SELECT  @validateEmail= dbo.ValidEmail(@Work_Email)
					IF (@validateEmail = 0)  --Mukti(10112020)check for proper Work Email ID
					BEGIN				
						INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Enter proper Work Email ID',0,'Enter proper Work Email ID',GETDATE(),'Employee Master','')  
						SET @HasResult = cast(@Emp_Code as varchar(100)) + ',' 
						SET @Log_Status=1   
						RETURN 
					END
				END
				
				IF (@Other_Email<>'') --Mukti(10112020)check for proper Work Other ID
				BEGIN						
						SELECT  @validateEmail= dbo.ValidEmail(@Other_Email)
						IF (@validateEmail = 0) 
						BEGIN				
							INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Enter proper Other Email ID',0,'Enter proper Other Email ID',GETDATE(),'Employee Master','')  
							SET @HasResult = cast(@Emp_Code as varchar(100)) + ',' 
							SET @Log_Status=1   
							RETURN 
						END
				END

				DECLARE @EXISTING_DETAIL VARCHAR(256)
				SET @EXISTING_DETAIL = NULL

			    IF EXISTS(SELECT Emp_ID FROM dbo.T0080_EMP_MASTER WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND Alpha_Emp_Code = @Alpha_Emp_Code) AND @Is_GroupOFCmp = 0
					BEGIN
							print 'same emp code' 
							INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Same Employess code already available in system',0,'Enter Employee Code Proper',GETDATE(),'Employee Master','')
							SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
							--Set @Status_Details = @Status_Details + cast(@Emp_Code as varchar(100)) + ','
					END
				ELSE IF Exists(select Emp_ID From dbo.T0080_EMP_MASTER WITH (NOLOCK) WHERE Alpha_Emp_Code = @Alpha_Emp_Code And Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1))
							AND @Max_Emp_Code = 'Group_Company_Wise' AND @Is_GroupOFCmp = 1
							BEGIN			
								SELECT	@EXISTING_DETAIL = Cmp_Name 
								FROM	T0080_EMP_MASTER E WITH (NOLOCK)
										INNER JOIN T0010_COMPANY_MASTER C WITH (NOLOCK) ON e.Cmp_ID=c.Cmp_Id 
								WHERE	Alpha_Emp_Code = @Alpha_Emp_Code AND C.is_GroupOFCmp=1
								SET @EXISTING_DETAIL = 'Employee Code already exist in "' + @EXISTING_DETAIL + '" Company.'

								IF (@EXISTING_DETAIL IS NOT NULL)
									BEGIN
										INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Alpha_Emp_Code,@EXISTING_DETAIL,0,'Enter Employee Code Proper',GETDATE(),'Employee Master','')
										SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
									END						

							END
				ELSE If Exists(select Emp_ID From dbo.T0080_EMP_MASTER WITH (NOLOCK) WHERE (Alpha_Emp_Code = @Alpha_Emp_Code) And Cmp_ID = @Cmp_ID)
							AND @Max_Emp_Code = 'Company_Wise'  And @Is_Alpha_Numeric_Branchwise = 0 AND @Is_GroupOFCmp = 1
							begin																	
								SET @EXISTING_DETAIL = 'Employee Code already exist in Current Company.'

								IF (@EXISTING_DETAIL IS NOT NULL)
									BEGIN
										INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Alpha_Emp_Code,@EXISTING_DETAIL,0,'Enter Employee Code Proper',GETDATE(),'Employee Master','')
										SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
									END						

							END
				ELSE If Exists(select Emp_ID From dbo.T0080_EMP_MASTER WITH (NOLOCK) WHERE (Alpha_Emp_Code = @Alpha_Emp_Code) And Cmp_ID = @Cmp_ID And Branch_ID = @Branch_Id)
							AND @Max_Emp_Code = 'Company_Wise' And @Is_Alpha_Numeric_Branchwise = 1 AND @Is_GroupOFCmp = 1
							begin																	
								SET @EXISTING_DETAIL = 'Employee Code already exist in Current Company.'
								IF (@EXISTING_DETAIL IS NOT NULL)
									BEGIN
										INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Alpha_Emp_Code,@EXISTING_DETAIL,0,'Enter Employee Code Proper',GETDATE(),'Employee Master','')
										SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
									END						
							END
				ELSE
					BEGIN  
						DECLARE @Count AS NUMERIC(18,0) 
						DECLARE @Emp_LCount NUMERIC  
						
						SELECT @Count =COUNT(Emp_ID) FROM dbo.T0080_EMP_MASTER WITH (NOLOCK) WHERE  Emp_Left <> 'y'        
						SELECT @Emp_LCount = dbo.decrypt(Emp_License_Count) FROM dbo.Emp_Lcount  
			     
						IF @Count > @Emp_LCount  
							BEGIN  
								SET @Emp_ID = 0  
								
								INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Employee Limit Exceed Contact Administrator: Total Employee =' ,CAST(@Count AS VARCHAR(18)),'Please Contact with Administration',GETDATE(),'Employee Master','')  
								SET @HasResult = '90'
								Goto A;
							END
						
						SELECT @Emp_ID = ISNULL(MAX(Emp_ID),0) + 1  FROM dbo.T0080_EMP_MASTER WITH (NOLOCK)
						SELECT @Adult_No = ISNULL(MAX(Worker_Adult_No),0) + 1 FROM dbo.T0080_EMP_MASTER WITH (NOLOCK) WHERE Cmp_ID=@Cmp_ID     
			     
						
						IF EXISTS (SELECT Module_Id FROM T0011_module_detail WITH (NOLOCK) WHERE Cmp_Id=@Cmp_ID AND chg_pwd=1)  
							BEGIN  
								SET @Chg_Pwd=1  
							END  
						
						IF @HasResult <> ''
							GOTO ABC;
							-- added by rohit on 07072016
							
						Declare @IS_EARLY_limit as varchar(15)
						Declare @IS_EARLY_mark as numeric
						set @IS_EARLY_limit  = '00:00'
						set @IS_EARLY_mark = 0
						
							if exists(select gen_id from T0040_GENERAL_SETTING WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Branch_ID=@Branch_ID and For_Date = (select max(for_date) From T0040_General_Setting WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Branch_ID =@branch_id))
							begin
									
									select @IS_EARLY_limit  = isnull(Early_Limit,'00:00') from T0040_GENERAL_SETTING WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Branch_ID=@Branch_ID and For_Date = (select max(for_date) From T0040_General_Setting WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Branch_ID =@branch_id)
							if (isnull(@IS_EARLY_limit,'00:00') <> '00:00' and isnull(@IS_EARLY_limit,'00:00') <> '' )
							begin
								set @IS_EARLY_mark = 1
							end
							
							end
							-- ended by rohit on 07072016	

							--- Added Minimum Basic Condition by Hardik 16/08/2018 for Corona
							Declare @Min_Basic_Applicable tinyint
							Declare @Min_Basic Numeric(18,5)

							Set @Min_Basic_Applicable = 0
							Set @Min_Basic = 0

							Select @Min_Basic_Applicable = Setting_Value  from T0040_SETTING WITH (NOLOCK) where Cmp_ID=@Cmp_ID  and Setting_Name = 'Min. basic rules applicable'
							Select @Min_Basic = Isnull(min_basic,0)  from T0040_GRADE_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID And Grd_Id = @Grd_Id

							IF @Basic_Salary = 0
								AND EXISTS(select 1 from T0040_GRADE_MASTER WITH (NOLOCK) where Grd_ID=@Grd_ID AND Basic_Percentage > 0)
								BEGIN
									SELECT	@Basic_Salary = Basic_Percentage * CASE WHEN Basic_Calc_On = 'CTC' THEN @CTC else @Gross_salary end / 100
									FROM	T0040_GRADE_MASTER WITH (NOLOCK) where Grd_ID=@Grd_ID 
								
									If @Min_Basic_Applicable = 1 And @Min_Basic > 0 And @Basic_Salary < @Min_Basic --- Added by Hardik 16/08/2018
										Set @Basic_Salary = @Min_Basic
								END
							ELSE IF @Basic_Salary = 0 And @Min_Basic_Applicable = 1 And @Min_Basic > 0 --- Added by Hardik 16/08/2018
								BEGIN
									Set @Basic_Salary = @Min_Basic
								END	
												
							--- Ended Minimum Basic Condition by Hardik 16/08/2018 for Corona

							--if Object_ID('tempdb..#DynamicValidation') Is not null
							--	Begin
							--		Drop Table #DynamicValidation
							--	End

							--Create Table #DynamicValidation
							--(
							--	Alpha_Emp_Code Varchar(100),
							--	Validation_Msg Varchar(500)
							--)
							
							-- Below Code is Created by Darshan on 19/01/2021 for Auto Active Mobile User during Employee Creation
							
							DECLARE @lSettingValueForAutoActiveMobileUser INT,@lLicenceCount INT,@lActiveEmpCount INT
							SELECT @lSettingValueForAutoActiveMobileUser = ISNULL(Setting_Value,0)
							FROM T0040_SETTING WITH (NOLOCK) WHERE cmp_id = @Cmp_ID and setting_name = 'Auto Active Mobile User during Employee Creation'

							IF @lSettingValueForAutoActiveMobileUser = 1
								BEGIN
									SELECT @lLicenceCount = dbo.Decrypt(Emp_License_Count_Mobile) FROM Emp_Lcount
									SELECT @lActiveEmpCount = COUNT(1) FROM Active_InActive_Users_Mobile WHERE Cmp_ID = @Cmp_ID and is_for_mobile_Access = 1

									IF @lActiveEmpCount >= @lLicenceCount
										BEGIN
											SET @Emp_ID = 0

											INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Mobile Activation Failed due to Mobile License Limit has been exceed: For Employee = ' + CONVERT(VARCHAR,@Alpha_Emp_Code),@Emp_Code,'Please Contact with Administrator',GETDATE(),'Employee Master','')  
											SET @HasResult = '90'
											SET @Log_Status=1
											Goto A;
										END									
								END

							-- Code end for Auto Active Mobile User during Employee Creation
						Declare @Image_Name as varchar(50) = ''
                        If Upper(@Initial)= 'MS.' or Upper(@Initial) = 'MRS.'
                                Set @Image_Name= 'Emp_Default_Female.png'
                        ELSE
                                Set @Image_Name = 'Emp_Default.png'


							INSERT INTO dbo.T0080_EMP_MASTER  
									(Emp_ID, Cmp_ID, Branch_ID, Cat_ID, Grd_ID, Dept_ID, Desig_Id, TYPE_ID, Shift_ID, Bank_ID, Emp_code,Initial, Emp_First_Name, Emp_Second_Name,   
									Emp_Last_Name, Curr_ID, Date_Of_Join, SSN_No, SIN_No, Dr_Lic_No, Pan_No, Date_Of_Birth, Marital_Status, Gender, Dr_Lic_Ex_Date, Nationality,   
									Loc_ID, Street_1, City, STATE, Zip_code, Home_Tel_no, Mobile_No, Work_Tel_No, Work_Email, Other_Email, Basic_Salary, Image_Name,Emp_Full_Name,  
									Emp_Left,Present_Street,Present_City,Present_State,Present_Post_Box ,Blood_Group,Enroll_No,Tally_Led_Name,Religion,Height,Emp_Mark_Of_Identification  
									,Despencery,Doctor_Name,DespenceryAddress,Insurance_No,Is_Gr_App,Is_Yearly_Bonus,Yearly_Leave_days,Yearly_Leave_Amount,Yearly_bonus_Per,Yearly_bonus_Amount,  
									Worker_Adult_No,Father_name,Ifsc_Code,Emp_Confirm_Date,IS_ON_Probation,Old_Ref_No,Chg_Pwd,Alpha_Code,Alpha_Emp_Code,Emp_Superior,Is_LWF
									,Segment_ID,Vertical_ID,SubVertical_ID,subBranch_ID,GroupJoiningDate,Date_of_Retirement
									,EmpName_Alias_PrimaryBank,EmpName_Alias_SecondaryBank,EmpName_Alias_PF,EmpName_Alias_PT,EmpName_Alias_Tax,EmpName_Alias_ESIC,EmpName_Alias_Salary
									,Emp_Shirt_Size,Emp_Pent_Size,Emp_Shoe_Size,Emp_Canteen_Code,Login_ID,System_Date)  
								VALUES (@Emp_ID,@Cmp_ID,@Branch_ID,@Cat_ID,@Grd_ID,@Dept_ID,@Desig_Id,@Type_ID,@Shift_ID,@Bank_ID,@Emp_code,@Initial,@Emp_First_Name,@Emp_Second_Name,  
									@Emp_Last_Name,@Curr_ID,@Date_Of_Join,@PF_No,@ESIC_No,'',@Pan_No,@Date_Of_Birth,@Marital_Status,@Gender,NULL,@Nationality,  
									@Loc_ID,@Street_1,@City,@State,@Zip_code,@Home_Tel_no,@Mobile_No,@Work_Tel_No,@Work_Email,@Other_Email,@Basic_Salary,@Image_Name,@Emp_Full_Name,  
									'N',@Present_Street,@Present_City,@Present_State,@Present_Post_Box,@Blood_Group,@Enroll_No,NULL,NULL,NULL,NULL,  
									NULL,NULL,NULL,NULL,0,0.0,0.0,0.0,0.0,0.0,@Adult_No,@Father_Name,@Emp_IFSC_No,@Confirm_Date,@Probation,@Old_Ref_No,@Chg_Pwd,@Alpha_Code,@Alpha_Emp_Code,@emp_Id_sup,@Is_LWF
									,@Segment_ID,@Vertical_ID,@SubVertical_ID,@SubBranch_ID,@Group_of_Joining,@Date_Of_Retirement
									,@Emp_Full_Name,@Emp_Full_Name,@Emp_Full_Name,@Emp_Full_Name,@Emp_Full_Name,@Emp_Full_Name,@Emp_Full_Name
									,0,0,0,0,@User_Id,Getdate()) 
							
							-- Below Code is Created by Darshan on 19/01/2021 for Auto Active Mobile User during Employee Creation

							IF @lSettingValueForAutoActiveMobileUser = 1
								BEGIN
									UPDATE T0080_EMP_MASTER SET is_for_mobile_Access = 1 
									WHERE Emp_ID = @Emp_ID AND Cmp_ID = @Cmp_ID
								END

							-- Code end for Auto Active Mobile User during Employee Creation

							SELECT @Default_Weekof = Default_Holiday, @Alt_W_Name =  Alt_W_Name ,@Alt_W_Full_Day_Cont = Alt_W_Full_Day_Cont  FROM dbo.T0010_COMPANY_MASTER WITH (NOLOCK) WHERE Cmp_Id = @Cmp_ID  
						
							--If Exists(Select 1 From #DynamicValidation)
							--	Begin
							--	    Declare @Dynamic_Msg as varchar(500)
							--		Select @Dynamic_Msg = Validation_Msg From #DynamicValidation
							--		INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,@Dynamic_Msg,0,'Dynamic Mandatory Fields',GETDATE(),'Employee Master','')    
							--		SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
							--		SET @Log_Status=1
							--		RETURN
							--	End
						
							IF @Alpha_Emp_Code IS NOT NULL  
								BEGIN  
									SET @loginname = CAST(@Alpha_Emp_Code AS VARCHAR(50)) + @Domain_Name  
								END  
							ELSE  
								BEGIN  
									SET @loginname = CAST(@Emp_Code AS VARCHAR(10)) + @Domain_Name  
								END   
			   
						
							-------Select * From T0080_EMP_MASTER Where Emp_ID = @Emp_ID
						
							IF NOT EXISTS(SELECT Row_ID FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) WHERE Cmp_ID=@Cmp_ID AND Emp_ID=@Emp_ID)  
								BEGIN  
									IF @emp_Id_sup IS NOT NULL And @emp_Id_sup > 0
										BEGIN  
											EXEC P0090_EMP_REPORTING_DETAIL 0,@Emp_ID,@Cmp_ID,'Supervisor',@emp_Id_sup,'Direct','i' ,0,0, '',@Date_OF_Join  
										END  
								END
						
							--EXEC p0011_Login @Login_ID OUTPUT,@Cmp_Id,@loginname,'VuMs/PGYS74=',@Emp_ID,NULL,NULL,'I',2
							EXEC p0011_Login @Login_ID OUTPUT,@Cmp_Id,@loginname,@EssPassword,@Emp_ID,NULL,NULL,'I',2
							EXEC P0110_EMP_LEFT_JOIN_TRAN @EMP_ID,@CMP_ID,@Date_Of_Join,'','',0  
							EXEC P0100_EMP_SHIFT_INSERT @emp_ID,@cmp_ID,@Shift_ID,@Date_of_Join,NULL 
							Declare @i Numeric(1,0)
						
							IF Exists(Select 1 From T0040_GRADE_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Grd_ID = @Grd_ID and Isnull(Grd_WAGES_TYPE,'') <> '')
								Begin
									Select @Wages_Type = Grd_WAGES_TYPE From T0040_GRADE_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Grd_ID = @Grd_ID
								End
							EXEC P0095_INCREMENT_INSERT @Increment_ID OUTPUT ,@Emp_ID,@Cmp_ID,@Branch_ID,@Cat_ID,@Grd_ID,@Dept_ID,@Desig_Id,@Type_ID,@Bank_ID
								,@Curr_ID,@Wages_Type,@Salary_Basis_On,@Basic_Salary,@Gross_salary,'Joining',@Date_OF_Join,@Date_OF_Join,@Payment_Mode
								,@Inc_Bank_AC_No,@Emp_OT,@Emp_OT_Min_Limit,@Emp_OT_Max_Limit,0,0,0,0,'',@Emp_LATE_MARK,@Emp_Full_PF,@Emp_PT,@Emp_Fix_Salary,0,'',0,1,@Login_ID,0
								,NULL,@emp_Id_sup,1,0,@CTC,0,0,0,0,0,0,@IS_EARLY_mark,'','00:00',0,'','',0,@WeekDay_OT_Rate,@Weekoff_OT_Rate,@Holiday_OT_Rate,0,0,0,0,0,0,0
								,@Salary_Cycle_ID
								,@Cmp_Full_PF
								,@Segment_ID ,@Vertical_ID,@SubVertical_ID,@SubBranch_ID,0,0,0,0,'','','','',0,'',@User_Id,@IP_Address,@Customer_Audit  --Change By Jaina 09-09-2016
							
						
							EXEC P0100_EMP_GRADEWISE_ALLOWANCE @Cmp_ID,@Emp_ID,@Grd_ID,@Date_Of_Join,@Increment_ID  
							--added By Mukti(start)27032017						
							if @Gross_salary=0
							BEGIN
								declare @E_AD_AMOUNT as numeric(18,2)
								set @E_AD_AMOUNT=0
								select @E_AD_AMOUNT=isnull(sum(E_AD_AMOUNT),0) from V0100_EMP_EARN_DEDUCTION where EMP_ID=@Emp_ID and CMP_ID=@Cmp_ID
								and AD_NOT_EFFECT_SALARY=0 and E_AD_FLAG='I'
							
								set @Gross_salary= @Basic_Salary + @E_AD_AMOUNT
								update T0095_INCREMENT SET Gross_Salary=@Gross_salary where EMP_ID=@Emp_ID and CMP_ID=@Cmp_ID
							END
							--added By Mukti(end)27032017
							--update by chetan 070717
						
							IF (ISNULL(@Default_Weekof,'') <> '')  or (ISNULL(@Alt_W_Name,'') <> '')
								EXEC P0100_WEEKOFF_ADJ 0,@Cmp_ID,@Emp_ID,@Date_Of_Join,@Default_Weekof,'',@Alt_W_Name,@Alt_W_Full_Day_Cont,'',0,'I'  
			   
							UPDATE dbo.T0080_EMP_MASTER SET Increment_ID = @Increment_ID  WHERE Emp_ID = @Emp_ID  
						
							if @Pay_Scale_ID <> 0 
								Begin
									EXEC P0050_EMP_PAY_SCALE_DETAIL @Cmp_ID,0,@Emp_ID,@Pay_Scale_ID,@Date_Of_Join,1
								End 
							
							--Added by Mukti(02082017)start
							select @Auto_LeaveCredit_Setting=isnull(Setting_Value,0) 
							from T0040_SETTING WITH (NOLOCK)
							--where Cmp_ID=@CMP_ID and Setting_Name='Auto Leave Credit Days while Import Employee Master' 
							where Cmp_ID=@CMP_ID and Setting_Name='Advance Leave balance assign from Import Employee' 
						
											
							if @Auto_LeaveCredit_Setting = 1
								EXEC SP_Get_Advance_Leave_Details @Cmp_ID=@Cmp_ID,@Type_ID=	@Type_ID,@Join_Date=@Date_OF_Join,@Branch_ID=@Branch_ID,@flag='Import',@Emp_ID=@Emp_ID,@Grade_ID = @Grd_ID
							--Added by Mukti(02082017)end
						
						
							if @Increment_ID <> 0 
								Begin
									Declare @NewValue Varchar(Max)
									Set @NewValue = ''
									Set @NewValue = 'New Value'
										  + '#Emp_Code ' + ' : ' +  isnull(Cast(@Emp_code AS varchar(20)),'')
										  + '#Emp_int_Name    ' + ' : ' +  isnull(Cast(@Initial AS varchar(10)),'')
										  + '#Emp_First_Name  ' + ' : ' +  isnull(@Emp_First_Name,'')
										  + '#Emp_Second_Name ' + ' : ' +  isnull(@Emp_Second_Name,'') 
										  + '#Emp_Last_Name   ' + ' : ' + isnull(@Emp_Last_Name,'')
										  + '#Branch		' + ' : ' + isnull(@Branch_Name,'') 
										  + '#Garde			' + ' : ' + isnull(@Grd_Name,'') 
										  +	'#Dept			' + ' : ' + isnull(@Dept_Name,'') 
										  + '#Category		' + ' : ' + isnull(@Product_name,'')
										  + '#Designation   ' + ' : ' + isnull(@desig_Name,'') 
										  + '#Type			' + ' : ' + isnull(@Type_Name,'')
										  + '#Shift         ' + ' : ' + isnull(@Shift_Name,'') 
										  + '#Bank_name     ' + ' : ' + isnull(@Bank_Name,'')
										  + '#Curr_name     ' + ' : ' + isnull(@Curr_Name,'')
										  + '#DOJ  ' + ' : ' + isnull(Replace(Convert(varchar(11),@Date_Of_Join,106),' ','-'),'')
										  + '#Pan_No    ' + ' : ' + isnull(@Pan_No,'') 
										  + '#EsicNo	' + ' : ' + isnull(@ESIC_No,'')
										  + '#PFno      ' + ' : ' + isnull(@PF_No,'') 
										  + '#BOD       ' + ' : ' + isnull(Replace(Convert(varchar(11),@Date_Of_Birth,106),' ','-'),'') 
										  + '#Marital_status' + ' : ' + isnull(Cast(@Marital_Status AS varchar(2)),'')  
										  + '#Gender    ' + ' : ' +   isnull(@Gender,'') 
										  + '#Nationality' + ' : ' +  isnull(@Nationality,'')  
										  + '#Location   ' + ' : ' +  isnull(@Loc_Name,'') 
										  + '#Address	 ' + ' : ' +  isnull(@Street_1,'')  
										  + '#City       ' + ' : ' +  isnull(@City,'') 
										  + '#State      ' + ' : ' +  isnull(@State,'') 
										  + '#PostBox    ' + ' : ' +  isnull(Cast(@Zip_code AS varchar(10)),'') 
										  + '#Tel_No	 ' + ' : ' +  isnull(Cast(@Home_Tel_no AS varchar(10)),'')  
										  + '#Mobile     ' + ' : ' +  isnull(Cast(@Mobile_No AS varchar(10)),'') 
										  + '#Work_Tel_No' + ' : ' +  isnull(Cast(@Work_Tel_No AS varchar(10)),'') 
										  + '#Work_Email ' + ' : ' +  isnull(@Work_Email,'') 
										  + '#Other_Email' + ' : ' +  isnull(@Other_Email,'') 
										  + '#Present_ADDRESS' + ' : ' + isnull(@Present_Street,'') 
										  + '#Present_City   ' + ' : ' + isnull(@Present_City,'') 
										  + '#Present_State  ' + ' : ' + isnull(@Present_State,'')
										  + '#Present_Postbox' + ' : ' + isnull(Cast(@Present_Post_Box AS varchar(10)),'')
										  + '#Salary         ' + ' : ' + isnull(Cast(@Basic_Salary AS varchar(10)),'')
										  + '#GROSS			 ' + ' : ' + isnull(Cast(@GROSS_SALARY  AS varchar(10)),'')
										  + '#WAGES          ' + ' : ' + isnull(@WAGES_TYPE,'')
										  +	'#SALARY_BASIC_ON' + ' : ' + isnull(@SALARY_BASIS_ON,'')
										  + '#PAYMENT_MODE   ' + ' : ' + isnull(@PAYMENT_MODE,'')
										  + '#BANK_ACC_NO    ' + ' : ' + isnull(Cast(@INC_BANK_AC_NO AS varchar(10)),'')
										  + '#EMP_OT         ' + ' : ' + isnull(Cast(@EMP_OT AS varchar(10)),'')
										  + '#Min_Limit      ' + ' : ' + isnull(Cast(@Emp_OT_Min_Limit as varchar(5)),'') 
										  + '#Max_Limit      ' + ' : ' + isnull(Cast(@Emp_OT_Max_Limit as varchar(5)),'') 
										  + '#Late_Mark		 ' + ' : ' + isnull(Cast(@Emp_LATE_MARK as varchar(2)),'') 
										  + '#Full_PF        ' + ' : ' + isnull(Cast(@Emp_Full_PF AS varchar(2)),'') 	
										  + '#Prof_Tax		 ' + ' : ' + isnull(Cast(@Emp_PT as varchar(2)),'')	
										  + '#Fix_Salary     ' + ' : ' + isnull(Cast(@Emp_Fix_Salary as varchar(2)),'')			
										  + '#Blood_Group    ' + ' : ' + isnull(@Blood_Group,'')
										  + '#Enroll_No      ' + ' : ' + isnull(Cast(@Enroll_No as varchar(20)),'')	 
										  + '#Father_Name	 ' + ' : ' + isnull(@Father_Name,'') 
										  + '#Bank_IFSC_NO   ' + ' : ' + isnull(Cast(@Emp_IFSC_No as varchar(10)),'')	
										  + '#Confirmation_Date' + ' : ' + (case when @Confirm_Date is null then Replace(Convert(varchar(11),@Confirm_Date,106),' ','-') else '' END)
										  + '#Probation		 ' + ' : ' + isnull(Cast(@Probation as varchar(10)),'')
										  + '#Old_Ref_No     ' + ' : ' + isnull(Cast(@Old_Ref_No as varchar(10)),'')
										  + '#Alpha_Code     ' + ' : ' + isnull(Cast(@Alpha_Code as varchar(20)),'')
										  + '#Emp_Superior   ' + ' : ' + isnull(Cast(@Emp_Superior as varchar(6)),'') 
										  + '#IS_LWF         ' + ' : ' + isnull(Cast(@IS_LWF as varchar(6)),'')
										  + '#Weekday_OT_Rate' + ' : ' + isnull(Cast(@Weekday_OT_Rate as varchar(6)),'')
										  + '#Weekoff_OT_Rate' + ' : ' + isnull(Cast(@Weekoff_OT_Rate as varchar(6)),'')
										  + '#Holiday_OT_Rate' + ' : ' + isnull(Cast(@Holiday_OT_Rate as varchar(6)),'')
										  + '#Business		 ' + ' : ' + isnull(Cast(@Business_Segment as varchar(6)),'')    
										  + '#Vertical		 ' + ' : ' + isnull(Cast(@Vertical as varchar(6)),'')
										  + '#sub_Vertical   ' + ' : ' + isnull(Cast(@Sub_Vertical as varchar(6)),'')
										  + '#Group_Of_Join  ' + ' : ' + isnull(Cast(@Group_of_Joining as varchar(6)),'')
										  + '#sub_Branch     ' + ' : ' + isnull(Cast(@Sub_Branch as varchar(6)),'')
										  + '#Salary_Cycle   ' + ' : ' + isnull(Cast(@Salary_Cycle as varchar(6)),'')
										  + '#Company_Full_PF' + ' : ' + isnull(Cast(@Cmp_Full_PF as varchar(6)),'')
										  + '#Pay_Scale_Name ' + ' : ' + isnull(Cast(@Pay_Scale_Name as varchar(200)),'')
										  + '#Customer_Audit ' + ' : ' + ISNULL(CAST(@Customer_Audit as varchar(10)),'')  --Added By Jaina 09-09-2016
						
									--exec P9999_Audit_Trail @Cmp_ID,'I','Employee Import',@NewValue,@Emp_ID,7931,'',1
									  exec P9999_Audit_Trail @Cmp_ID,'I','Employee Import',@NewValue,@Emp_Id,@User_Id,@IP_Address,1
								End 
							

							---Added By Jimit 02052019 For Inserting Default Scheme to Employees
								SELECT @Tran_ID = ISNULL(MAX(Tran_ID),0) + 1 FROM T0095_EMP_SCHEME WITH (NOLOCK)

								Insert Into T0095_EMP_SCHEME(Tran_ID, Cmp_ID, Emp_ID, Scheme_ID, Type, Effective_Date)
								select  ROW_NUMBER() Over(Order By Scheme_Id asc) + @Tran_ID,@Cmp_ID, @Emp_ID,SCHEME_ID,SCHEME_TYPE,Cast(Cast(@Date_Of_Join As Varchar(11)) As Datetime)
								FROM    T0040_SCHEME_MASTER WITH (NOLOCK)
								WHERE   DEFAULT_SCHEME = 1 AND CMP_ID = @CMP_ID 
										AND	NOT EXISTS(
														SELECT	1 
														FROM	T0095_EMP_SCHEME WITH (NOLOCK)
														WHERE	EMP_ID = @EMP_ID AND TYPE = SCHEME_TYPE 
																AND EFFECTIVE_DATE = GETDATE()
													  )
							--Ended

						END 
				
					
				END TRY
				BEGIN CATCH 
					DECLARE @w_error VARCHAR(200) 
					SET @w_error= NULL
				
					SET @w_error = error_message()
					IF @w_error is not NULL 
						BEGIN
							SET @HasResult = cast(@Emp_Code as varchar(100)) + ','				
							INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,@w_error,0,'Error in Import Data',GETDATE(),'Employee Master','') 
						End   
				END CATCH
			ABC:
				IF IsNull(@HasResult,'') <> ''
					SET @Log_Status = @Log_Status + @HasResult
				
			FETCH NEXT FROM curXml INTO @Marital_Status,@Gender,@Initial,@Nationality,@Loc_Name,@Wages_Type,@Basic_Salary,@Payment_Mode,@Emp_OT_Min_Limit,@Emp_OT_Max_Limit,@Emp_Full_PF,@Cmp_Full_PF,@Emp_PT,@Alpha_Code,@Emp_Superior,@Salary_Cycle,@Emp_Last_Name,@Group_of_Joining,@Branch_Name,@Grd_Name,@Shift_Name,@Emp_Code,@Emp_First_Name,@Emp_Second_Name,@Date_Of_Join,@desig_Name,@Type_Name,@Bank_Name,@Curr_Name,@Product_name,@Business_Segment,@Vertical,@Sub_Vertical,@Sub_Branch,@Street_1,@City,@State,@Zip_code,@Home_Tel_no,@Mobile_No,@Work_Tel_No,@Work_Email,@Other_Email,@Present_Street,@Present_City,@Present_State,@Present_Post_Box,@Enroll_No,@Blood_Group,@Father_Name,@Emp_IFSC_No,@Confirm_Date,@Probation,@Old_Ref_No,@IS_LWF,@Weekday_OT_Rate,@Weekoff_OT_Rate,@Holiday_OT_Rate,@Group_of_Joining,@Emp_LATE_MARK,@Pan_No,@ESIC_No,@PF_No,@Date_Of_Birth,@Gross_salary,@Salary_Basis_On,@Inc_Bank_Ac_No,@Emp_OT,@Emp_Fix_Salary,@Dept_Name,@Pay_Scale_Name,@Customer_Audit,@EssPassword,@CTC  --Change By Jaina 09-09-2016
	   END  
	CLOSE curXml                      
	DEALLOCATE curXml
		A:
		
		if @HasResult = '' And @Log_Status = ''
			begin
				Set @Log_Status = '0'
				return 
			End	
		Else
			begin
				If @Log_Status = ''
					Set @Log_Status = @HasResult
				
				--Set @Log_Status_Details = @Status_Details
				return  
			End

			
END













--USE [Orange_Version_03102019]
--GO
--/****** Object:  StoredProcedure [dbo].[P0080_EMP_MASTER_IMPORT_NEW]    Script Date: 11/6/2023 3:57:26 PM ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO


-----28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
--ALTER PROCEDURE [dbo].[P0080_EMP_MASTER_IMPORT_NEW] 
--	@Cmp_ID numeric,  
--	@Log_Status Varchar(max)  = 0 OUTPUT,
--	@Str_Xml  xml,
--	@User_Id numeric(18,0) = 0, -- Added by nilesh patel on 10052016 
--    @IP_Address varchar(30)= '' -- Added by nilesh patel on 10052016 
--AS 
--SET NOCOUNT ON 
--SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
--SET ARITHABORT ON

--   Declare @Emp_code			NUMERIC(18,0)  
--   Declare @Initial				VARCHAR(10)   
--   Declare @Emp_First_Name		VARCHAR(100)  
--   Declare @Emp_Second_Name		VARCHAR(100)  
--   Declare @Emp_Last_Name		VARCHAR(100) 
--   Declare @Branch_Name			VARCHAR(100)     
--   Declare @Grd_Name			VARCHAR(100)     
--   Declare @Dept_Name			VARCHAR(100)     
--   Declare @Product_Name		VARCHAR(100)     
--   Declare @Desig_Name			VARCHAR(100)     
--   Declare @Type_Name			VARCHAR(100)     
--   Declare @Shift_Name			VARCHAR(100)     
--   Declare @Bank_Name			VARCHAR(100)   
--   Declare @Curr_Name			VARCHAR(100)     
--   Declare @Date_Of_Join		DATETIME  
--   Declare @Pan_No				VARCHAR(30)  
--   Declare @ESIC_No				VARCHAR(30)  
--   Declare @PF_No				VARCHAR(30)  
--   Declare @Date_Of_Birth		DATETIME	
--   Declare @Marital_Status		VARCHAR(20) 
--   Declare @Gender				CHAR(1)		
--   Declare @Nationality			VARCHAR(20)	
--   Declare @Loc_Name			VARCHAR(100)
--   Declare @Street_1			VARCHAR(250)  
--   Declare @City				VARCHAR(30)  
--   Declare @State				VARCHAR(20)  
--   Declare @Zip_code			VARCHAR(20)  
--   Declare @Home_Tel_no			VARCHAR(30)  
--   Declare @Mobile_No			VARCHAR(30)  
--   Declare @Work_Tel_No			VARCHAR(30)  
--   Declare @Work_Email			VARCHAR(50)  
--   Declare @Other_Email			VARCHAR(50)  
--   Declare @Present_Street		VARCHAR(250)  
--   Declare @Present_City		VARCHAR(30)  
--   Declare @Present_State		VARCHAR(30)  
--   Declare @Present_Post_Box	VARCHAR(20)  
--   Declare @Basic_Salary		NUMERIC(18,2)  
--   Declare @Gross_salary		NUMERIC(18,2)  
--   Declare @Wages_Type			VARCHAR(10)	
--   Declare @Salary_Basis_On		VARCHAR(20)	
--   Declare @Payment_Mode		VARCHAR(20) 
--   Declare @Inc_Bank_AC_No		VARCHAR(20)  
--   Declare @Emp_OT				NUMERIC(1)	
--   Declare @Emp_OT_Min_Limit	VARCHAR(10) 
--   Declare @Emp_OT_Max_Limit	VARCHAR(10) 
--   Declare @Emp_Late_mark		NUMERIC(18) 
--   Declare @Emp_Full_PF			NUMERIC(18) 
--   Declare @Emp_PT				NUMERIC(18) 
--   Declare @Emp_Fix_Salary		NUMERIC(18) 
--   Declare @Blood_Group			VARCHAR(10)  
--   Declare @Enroll_No			NUMERIC (18,0)  
--   Declare @Father_Name			VARCHAR(100) 
--   Declare @Emp_IFSC_No			VARCHAR(100) 
--   Declare @Adult_NO			NUMERIC(18,0) 
--   Declare @Confirm_Date		DATETIME  
--   Declare @Probation			NUMERIC(18,0)
--   Declare @Superior			NUMERIC(18,0)
--   Declare @Old_Ref_No			VARCHAR(50)	
--   Declare @Row_No				NUMERIC(18,0)
--   Declare @Alpha_Code			VARCHAR(10) 
--   Declare @Emp_Superior		VARCHAR(20) 
--   Declare @Is_LWF 				INT
--   Declare @WeekDay_OT_Rate		NUMERIC(18,3) 
--   Declare @Weekoff_OT_Rate		NUMERIC(18,3) 
--   Declare @Holiday_OT_Rate		NUMERIC(18,3) 
--   Declare @Business_Segment 	VARCHAR(50) 
--   Declare @Vertical			VARCHAR(50) 
--   Declare @sub_Vertical		VARCHAR(50) 
--   Declare @sub_Branch			VARCHAR(50) 
--   Declare @Group_of_Joining	DATETIME	
--   Declare @Salary_Cycle		VARCHAR(50) 
--   Declare @Cmp_Full_PF			NUMERIC(18) 
--   DECLARE @totalRecords INT
--   DECLARE @w_Count INT
--   DECLARE @Emp_ID			As NUMERIC(18,0)   
--   DECLARE @Branch_ID		As NUMERIC(18,0)
--   DECLARE @Cat_ID			As NUMERIC(18,0)  
--   DECLARE @Grd_ID			As NUMERIC(18,0)  
--   DECLARE @Dept_ID		    As NUMERIC(18,0)  
--   DECLARE @Desig_Id		As NUMERIC(18,0)
--   DECLARE @Type_ID		As NUMERIC(18,0)  
--   DECLARE @Shift_ID		As NUMERIC(18,0)  
--   DECLARE @Bank_ID		As NUMERIC(18,0)  
--   DECLARE @Curr_ID		As NUMERIC(18,0)  
--   DECLARE @Increment_ID	As NUMERIC(18,0)   
--   DECLARE @Loc_ID			As NUMERIC(18,0)  
--   DECLARE @State_ID		As NUMERIC(18,0)  
--   DECLARE @Login_ID		As NUMERIC(18,0)   
--   DECLARE @Chg_Pwd		As INT   
--   DECLARE @emp_Id_sup		AS NUMERIC(18,0)  
--   SET @emp_Id_sup = 0  
--   DECLARE @Segment_ID		As NUMERIC(18,0) 
--   DECLARE @Vertical_ID	As NUMERIC(18,0) 
--   DECLARE @SubVertical_ID As NUMERIC(18,0)
--   DECLARE @SubBranch_ID	As NUMERIC(18,0)
--   Declare @Salary_Cycle_ID As Numeric(18,0)
--   DECLARE @HasResult Varchar(max) 
--   DECLARE @Date_Of_Retirement Datetime 
--   DECLARE @Pay_Scale_Name Varchar(500) 
--   DECLARE @Pay_Scale_ID Numeric
--   DECLARE @Customer_Audit tinyint --Added By Jaina 09-09-2016
--   Declare @Auto_LeaveCredit_Setting as NUMERIC(18,0)--Mukti(08092017)
--   Declare @EssPassword as Varchar(500)
--   Declare @CTC as Numeric(18,2)
--   DECLARE @Tran_ID AS INT
--   SET @CTC = 0
   
--	SET @Emp_Second_Name = ''
--	SET @Date_Of_Birth	 = NULL 
--	SET @Marital_Status	 = '-1'
--    SET @Gender			 = ''  
--    SET @Nationality	 = 'Indian'  
--    SET @Loc_Name		 = 'India'  
--    SET @Wages_Type		 = 'Monthly'  
--    SET @Salary_Basis_On = 'Day'  
--    SET @Payment_Mode	 = 'Cash' 
--    SET @Emp_OT			 = 0  
--    SET @Emp_OT_Min_Limit	= '00:00'  
--    SET @Emp_OT_Max_Limit	= '00:00'  
--    SET @Emp_Late_mark	    = 0  
--    SET @Emp_Full_PF	    = 0		--Here 0 is Done by RamiZ on 10/09/2015
--    SET @Emp_PT				= 0  
--    SET @Emp_Fix_Salary		= 0  
--    SET @Father_Name		= ''  
--    SET @Emp_IFSC_No		= ''  
--    SET @Adult_NO			= 0 
--    SET  @Probation			= 0  
--    SET @Superior			= NULL 
--    SET @Old_Ref_No			= NULL  
--    SET @Row_No				= 0 
--    SET @Alpha_Code			= ''   
--	SET @Emp_Superior		= ''     
--    SET @Is_LWF 			=0  
--    SET @WeekDay_OT_Rate	= 0  
--    SET @Weekoff_OT_Rate	= 0  
--    SET @Holiday_OT_Rate	= 0  
--    SET @Business_Segment 	= NULL	
--    SET @Vertical			= NULL	
--    SET @sub_Vertical		= NULL	
--    SET @sub_Branch			= NULL	
--    SET @Group_of_Joining	= NULL	
--    SET @Salary_Cycle		= NULL	
--    SET @Cmp_Full_PF		= 0		--Here 0 is Done by RamiZ on 10/09/2015
--    SET @HasResult			= ''
--    SET @Date_Of_Retirement = Null
--    Set @Pay_Scale_Name = ''
--    Set @Pay_Scale_ID = 0
--    Set @Customer_Audit = 0   --Added By Jaina 09-09-2016
--    Set @EssPassword = ''

--	Set @Log_Status = '0'

--    --ADMIN SETTING PORTION ADDED BY RAMIZ ON 21/01/2019--
--   DECLARE @Add_Initial_In_Emp_Full_Name TINYINT
--   SET @Add_Initial_In_Emp_Full_Name = 0
   
--   SELECT @Add_Initial_In_Emp_Full_Name = SETTING_VALUE FROM T0040_SETTING  WITH (NOLOCK) WHERE cmp_id = @Cmp_ID and SETTING_NAME = 'Add initial in employee full name'
	
--BEGIN	
--	SET NOCOUNT ON;
--	SET @Login_ID = 0  
--	SET @Chg_Pwd = 0  
--	Set @Salary_Cycle_ID = 0

--	Set @Str_Xml = REPLACE(cast(@Str_Xml as nvarchar(max)),'Table1','Sheet1OLE')
	
--	---- Add by Jignesh 24-02-2020-----
--	Set @Str_Xml = REPLACE(cast(@Str_Xml as nvarchar(max)),'(Gerenal_x0020_Shift/text())[1]','(General_x0020_Shift/text())[1]')
--	Set @Str_Xml = REPLACE(cast(@Str_Xml as nvarchar(max)),'Gerenal_x0020_Shift','General_x0020_Shift')
--	-------- End-----------
		
--    select dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(Emp_x0020_Code/text())[1]','numeric(18,0)')) as Emp_Code,
--    dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(Initial_x0020_Name/text())[1]','Varchar(100)')) as Emp_int_Name,
--    dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(First_x0020_Name/text())[1]','Varchar(100)')) as Emp_First_Name,
--    dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(Second_x0020_Name/text())[1]','Varchar(100)')) as Emp_Second_Name,
--    dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(Last_x0020_Name/text())[1]','Varchar(100)')) as Emp_Last_Name,
--    dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(Branch/text())[1]','Varchar(100)')) as Branch,
--    dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(Grade/text())[1]','Varchar(100)')) as Garde,
--    dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(Department/text())[1]','Varchar(100)')) as Dept,
--    dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(Category/text())[1]','Varchar(100)')) as Category,
--    dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(Designation/text())[1]','Varchar(100)')) as Designation,
--    dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(TYPE/text())[1]','Varchar(100)')) as Type,
    
--    ----- Modify Jignesh 24-02-2020---
--    ----Sheet1OLE.value('(Gerenal_x0020_Shift/text())[1]','Varchar(100)') as Shift,
--    dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(General_x0020_Shift/text())[1]','Varchar(100)')) as Shift,
					  
--    dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(BANK_x0020_NAME/text())[1]','Varchar(100)')) as Bank_name,
--    dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(CURR_x0020_NAME/text())[1]','Varchar(100)')) as Curr_name,
--    --Sheet1OLE.value('(DOJ/text())[1]','datetime') as DOJ,
--    dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('substring((DOJ/text())[1], 1, 19)','datetime')) as DOJ,
--    dbo.fnc_ReverseHTMLTags(isnull(Sheet1OLE.value('(Pan_x0020_No/text())[1]','Varchar(100)'),'')) as Pan_No,
--    dbo.fnc_ReverseHTMLTags(isnull(Sheet1OLE.value('(Esic_x0020_No/text())[1]','Varchar(100)'),'')) as EsicNo,
--    dbo.fnc_ReverseHTMLTags(isnull(Sheet1OLE.value('(PF_x0020_no/text())[1]','Varchar(100)'),'')) as PFno,
--    --Sheet1OLE.value('(DOB/text())[1]','datetime') as BOD,
--    dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('substring((DOB/text())[1], 1, 19)','datetime')) as BOD,
--    dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(MARITAL_x0020_STATUS/text())[1]','Varchar(100)')) as Marital_status,
--    dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(GENDER/text())[1]','Varchar(100)')) as Gender,
--    dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(NATIONALITY/text())[1]','Varchar(100)')) as Nationality,
--    dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(LOCATION/text())[1]','Varchar(100)')) as Location,
--    dbo.fnc_ReverseHTMLTags(isnull(Sheet1OLE.value('(ADDRESS/text())[1]','Varchar(500)'),'')) as Address,
--    dbo.fnc_ReverseHTMLTags(isnull(Sheet1OLE.value('(CITY/text())[1]','Varchar(100)'),'')) as City,
--    dbo.fnc_ReverseHTMLTags(isnull(Sheet1OLE.value('(STATE/text())[1]','Varchar(100)'),'')) as State,
--    dbo.fnc_ReverseHTMLTags(isnull(Sheet1OLE.value('(POST_x0020_BOX/text())[1]','Varchar(100)'),'')) as PostBox,
--    dbo.fnc_ReverseHTMLTags(isnull(Sheet1OLE.value('(Tel_x0020_No/text())[1]','Varchar(100)'),'')) as Tel_No,
--    dbo.fnc_ReverseHTMLTags(isnull(Sheet1OLE.value('(MOBILE_x0020_NO/text())[1]','Varchar(100)'),'')) as Mobile,
--    dbo.fnc_ReverseHTMLTags(isnull(Sheet1OLE.value('(Work_x0020_Tel_x0020_No/text())[1]','Varchar(100)'),'')) as Work_Tel_No,
--    dbo.fnc_ReverseHTMLTags(isnull(Sheet1OLE.value('(Work_x0020_Email/text())[1]','Varchar(100)'),'')) as Work_Email,
--    dbo.fnc_ReverseHTMLTags(isnull(Sheet1OLE.value('(Other_x0020_Email/text())[1]','Varchar(100)'),'')) as Other_Email,
--	dbo.fnc_ReverseHTMLTags(isnull(Sheet1OLE.value('(ADDRESS1/text())[1]','Varchar(100)'),'')) as Present_ADDRESS,
--	dbo.fnc_ReverseHTMLTags(isnull(Sheet1OLE.value('(CITY1/text())[1]','Varchar(100)'),'')) as Present_City,
--    dbo.fnc_ReverseHTMLTags(isnull(Sheet1OLE.value('(State1/text())[1]','Varchar(100)'),'')) as Present_State,
--    dbo.fnc_ReverseHTMLTags(isnull(Sheet1OLE.value('(Post_x0020_Box1/text())[1]','Varchar(100)'),'')) as Present_Postbox,
--    dbo.fnc_ReverseHTMLTags(isnull(Sheet1OLE.value('(SALARY/text())[1]','Numeric(18,2)'),0)) as Salary,
--    dbo.fnc_ReverseHTMLTags(isnull(Sheet1OLE.value('(Gross_Salary/text())[1]','Numeric(18,2)'),0)) as Gross,
--    dbo.fnc_ReverseHTMLTags(isnull(Sheet1OLE.value('(CTC/text())[1]','Numeric(18,2)'),0)) as CTC,
--    dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(Wages_Type/text())[1]','Varchar(100)')) as Wages,
--    dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(Salary_Basis_On/text())[1]','Varchar(100)')) as Salary_Basic_on,
--    dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(Payment_Mode/text())[1]','Varchar(100)')) as Payment_mode,
--    dbo.fnc_ReverseHTMLTags(isnull(Sheet1OLE.value('(Emp_Bank_Ac_No/text())[1]','Varchar(100)'),'')) as Bank_Acc_No,
--    dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(Emp_OT/text())[1]','Varchar(100)')) as Emp_OT,
--    dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(Min_x0020_limit/text())[1]','Varchar(100)')) as Min_Limit,
--    dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(Max_x0020_Limit/text())[1]','Varchar(100)')) as Max_Limit,
--    dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(Late_x0020_Mark/text())[1]','Varchar(100)')) as Late_Mark,
--    dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(Full_x0020_PF/text())[1]','Varchar(100)')) as Full_PF,
--    --Sheet1OLE.value('(Prof._x0020_Tax/text())[1]','Varchar(100)') as Prof_Tax,
--	dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(Prof_x0023__x0020_Tax/text())[1]','Varchar(100)')) as Prof_Tax,
--    dbo.fnc_ReverseHTMLTags(Isnull(Sheet1OLE.value('(Fix_x0020_Salary/text())[1]','Numeric(1,0)'),0)) as Fix_Salary,
--    dbo.fnc_ReverseHTMLTags(isnull(Sheet1OLE.value('(Blood_Group/text())[1]','Varchar(100)'),'')) as Blood_Group,
--    dbo.fnc_ReverseHTMLTags(isnull(Sheet1OLE.value('(Enroll_No/text())[1]','Varchar(100)'),'0')) as Enroll_No,
--    dbo.fnc_ReverseHTMLTags(isnull(Sheet1OLE.value('(Father_Name/text())[1]','Varchar(100)'),'')) as Father_Name,
--    dbo.fnc_ReverseHTMLTags(isnull(Sheet1OLE.value('(Bank_IFSC_NO/text())[1]','Varchar(100)'),'')) as Bank_IFSC_NO,
--    --Sheet1OLE.value('(Confirmation_Date/text())[1]','DateTime') as Confirmation_Date,
--    dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('substring((Confirmation_Date/text())[1], 1, 19)','datetime')) as Confirmation_Date,
--    --Sheet1OLE.value('(Probation/text())[1]','DateTime') as Probation,
--	dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(Probation/text())[1]','Varchar(100)')) as Probation,
--	dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(Old_Ref_No/text())[1]','Varchar(100)')) as Old_Ref_No,
--	dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(Alpha_Code/text())[1]','Varchar(100)')) as Alpha_Code,
--	dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(Emp_Superior/text())[1]','Varchar(100)')) as Emp_Superior,
--    dbo.fnc_ReverseHTMLTags(isnull(Sheet1OLE.value('(Is_LWF/text())[1]','Numeric(18,0)'),0)) as IS_LWF,
--    dbo.fnc_ReverseHTMLTags(isnull(Sheet1OLE.value('(Weekday_OT_Rate/text())[1]','Numeric(18,2)'),0)) as Weekday_OT_Rate,
--    dbo.fnc_ReverseHTMLTags(Isnull(Sheet1OLE.value('(Weekoff_OT_Rate/text())[1]','Numeric(18,2)'),0)) as Weekoff_OT_Rate,
--    dbo.fnc_ReverseHTMLTags(Isnull(Sheet1OLE.value('(Holiday_OT_Rate/text())[1]','Numeric(18,2)'),0)) as Holiday_OT_Rate,
--    dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(Business_x0020_Segment/text())[1]','Varchar(100)')) as Business,
--    dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(Vertical/text())[1]','Varchar(100)')) as Vertical,
--    dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(sub_Vertical/text())[1]','Varchar(100)')) as sub_Vertical,
--    ---Sheet1OLE.value('(Group_x0020_of_x0020_Joining/text())[1]','datetime') as Group_Of_Join,
--    dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('substring((Group_x0020_of_x0020_Joining/text())[1], 1, 19)','datetime')) as Group_Of_Join,
--    dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(sub_Branch/text())[1]','Varchar(100)')) as sub_Branch,
--    dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(Salary_Cycle/text())[1]','Varchar(100)')) as Salary_Cycle,
--    dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(Company_x0020_Full_x0020_PF/text())[1]','Varchar(100)')) as Company_Full_PF,
--    dbo.fnc_ReverseHTMLTags(Sheet1OLE.value('(Pay_Scale_Name/text())[1]','Varchar(100)')) as Pay_Scale_Name,
--    dbo.fnc_ReverseHTMLTags(isnull(Sheet1OLE.value('(Customer_Audit/text())[1]','Numeric(18,0)'),0)) as Customer_Audit,   --Added By Jaina 09-09-2016
--    dbo.fnc_ReverseHTMLTags(isnull(Sheet1OLE.value('(Password/text())[1]','Varchar(500)'),0)) as EssPassword
--    into #Temptable from @Str_Xml.nodes('/NewDataSet/Sheet1OLE') as Temp(Sheet1OLE)

	
--	CREATE TABLE #Emp_Code_Detail
--	(
--		Alpha_Code Varchar(128),
--		Emp_Code Numeric
--	)
	
	
--	CREATE table #Error_Details 
--	(      
--		Log_Status NUMERIC ,     
--		Alpha_Code Varchar(100),
--		Error_Description Varchar(1000)    
--	) 
	
--    Declare @Restrict_Other_Master Numeric(2,0) --Added By Nilesh patel on 04042016
--	DECLARE @ErrString VARCHAR(1000)  
--	--Validiating some Fields in which SPACE is not Allowed-- Ramiz on 01/04/2019
--	UPDATE #Temptable
--	SET PAN_NO		= REPLACE(REPLACE(RTRIM(LTRIM(PAN_NO)) , ' ',''),'  ',''),
--		Work_Email  = REPLACE(REPLACE(RTRIM(LTRIM(Work_Email)) , ' ',''),'  ',''),
--		Other_Email = REPLACE(REPLACE(RTRIM(LTRIM(Other_Email)) , ' ',''),'  ','')
	
--	--select Prof_Tax,* from #Temptable
--    declare curXml cursor for 
--		select Marital_status,Gender,Emp_int_Name,Nationality,Location,Wages,Salary,Payment_mode,Min_Limit,Max_Limit,Full_PF,Company_Full_PF,
--		Prof_Tax,Alpha_Code,Emp_Superior,Salary_Cycle,Emp_Last_Name,Group_Of_Join,Branch,Garde,Shift,Emp_Code,Emp_First_Name,Emp_Second_Name,DOJ,
--		Designation,Type,Bank_name,Curr_name,Category,Business,Vertical,sub_Vertical,sub_Branch,Address,City,State,PostBox,Tel_No,Mobile,Work_Tel_No,
--		Work_Email,Other_Email,Present_ADDRESS,Present_City,Present_State,Present_Postbox,Enroll_No,Blood_Group,Father_Name,Bank_IFSC_NO,Confirmation_Date,
--		Probation,Old_Ref_No,IS_LWF,Weekday_OT_Rate,Weekoff_OT_Rate,Holiday_OT_Rate,Group_Of_Join,Late_Mark,Pan_No,EsicNo,PFno,BOD,Gross,Salary_Basic_on,
--		Bank_Acc_No,Emp_OT,cast(Fix_Salary AS numeric(1,0)),Dept,Pay_Scale_Name,Customer_Audit,EssPassword,CTC from #Temptable                  
--	open curXml                        
--		fetch next from curXml into @Marital_Status,@Gender,@Initial,@Nationality,@Loc_Name,@Wages_Type,@Basic_Salary,@Payment_Mode,@Emp_OT_Min_Limit,@Emp_OT_Max_Limit,@Emp_Full_PF,@Cmp_Full_PF,@Emp_PT,@Alpha_Code,@Emp_Superior,@Salary_Cycle,@Emp_Last_Name,@Group_of_Joining,@Branch_Name,@Grd_Name,@Shift_Name,@Emp_Code,@Emp_First_Name,@Emp_Second_Name,@Date_Of_Join,@desig_Name,@Type_Name,@Bank_Name,@Curr_Name,@Product_name,@Business_Segment,@Vertical,@Sub_Vertical,@Sub_Branch,@Street_1,@City,@State,@Zip_code,@Home_Tel_no,@Mobile_No,@Work_Tel_No,@Work_Email,@Other_Email,@Present_Street,@Present_City,@Present_State,@Present_Post_Box,@Enroll_No,@Blood_Group,@Father_Name,@Emp_IFSC_No,@Confirm_Date,@Probation,@Old_Ref_No,@IS_LWF,@Weekday_OT_Rate,@Weekoff_OT_Rate,@Holiday_OT_Rate,@Group_of_Joining,@Emp_LATE_MARK,@Pan_No,@ESIC_No,@PF_No,@Date_Of_Birth,@Gross_salary,@Salary_Basis_On,@Inc_Bank_Ac_No,@Emp_OT,@Emp_Fix_Salary,@Dept_Name,@Pay_Scale_Name,@Customer_Audit,@EssPassword,@CTC  --Change by Jaina 09-09-2016
--		while @@fetch_status >= 0 
--		Begin                     
--			 BEGIN TRY
			 
				 
				
--				  DECLARE @Emp_Full_Name  VARCHAR(250)  
--				  DECLARE @loginname   VARCHAR(50)  
--				  DECLARE @Domain_Name  VARCHAR(50)  
--				  DECLARE @old_Join_Date  DATETIME   
--				  DECLARE @Default_Weekof  VARCHAR(50)   
--				  DECLARE @Cmp_Code AS VARCHAR(5)  
--				  DECLARE @Branch_Code_1 AS VARCHAR(10)  
--				  DECLARE @Alpha_Emp_Code AS VARCHAR(50)  
--				  DECLARE @Is_Auto_Alpha_Numeric_Code TINYINT  
--				  DECLARE @No_Of_Digits NUMERIC
--				  --add by chetan 060717
--				  DECLARE @Alt_W_Name  VARCHAR(20)  
--				  DECLARE @Alt_W_Full_Day_Cont  VARCHAR(20)  
				  
--				  Declare @Retirement_Year Numeric(18,0) 
--				  SET @Retirement_Year	= 0  -- Added by nilesh patel on 30012015
				   
--				  select @Retirement_Year = Setting_Value from T0040_SETTING WITH (NOLOCK) where cmp_id = @Cmp_ID and Setting_Name='Employee Retirement Age'
				  
--				  select @Restrict_Other_Master = Setting_Value from T0040_SETTING WITH (NOLOCK) where cmp_id = @Cmp_ID and Setting_Name='Restrict other master creation when Emplyee Master Import'
				 
--				  if @date_of_Birth = '01/01/1900'  -- Added by Gadriwala Muslim 0512016
--					set @date_of_Birth = null
					
--				IF @Date_Of_Birth is not null and @Retirement_Year <> 0
--					BEGIN
--						SET @Date_Of_Retirement = DATEADD(YEAR,@Retirement_Year,@Date_Of_Birth)
--					END
--				ELSE
--					Set @Date_Of_Retirement = NULL	
					
--				--Added BY Jimit 14032019
--				IF @Date_Of_Birth > GETDATE()
--					BEGIN
--							INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Future Birth Date is not Allowed.',0,'Enter Valid Birth Date',GETDATE(),'Employee Master','') 
--							SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
--							Goto ABC;
--					END
--				IF DATEDIFF(YEAR,@Date_Of_Birth,@Date_Of_Join) < 18
--					BEGIN
--							INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Employee Age below 18yrs.',0,'Enter Valid Birth date',GETDATE(),'Employee Master','') 
--							SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
--							Goto ABC;
--					END
--				--ENDED

				

--				If @Emp_Second_Name IS NULL
--					Set @Emp_Second_Name = ''
			 
--				IF IsNull(@Marital_Status,'') = '' OR ISNUMERIC(@Marital_Status) = 0
--					SET @Marital_Status = '-1'  
				  
--				--IF IsNull(@Gender,'') = ''
--				--	SET @Gender = 'M'
				 
--				 -- If @Initial = 'Ms.' Or @Initial = 'Ms' Or @Initial = 'Mrs.' Or @Initial = 'Mrs'
--					--BEGIN
--					--	Set @Gender = 'F'
--					--END
--				 -- ELSE
--					--BEGIN
--					--	Set @Gender = 'M'
--					--END
					
--				 -- IF @Nationality IS NULL  
--					--SET @Nationality = 'Indian'  
		     
--				 -- IF IsNull(@Loc_Name,'') = ''
--					--SET @Loc_Name = 'India'  
		       
--				  IF @Wages_Type IS NULL     
--					SET @Wages_Type = 'Monthly'  
		    
--				 -- IF @Salary_Basis_On IS NULL 
--					--SET @Salary_Basis_On = 'Day'  
					
--				  IF @Emp_OT_Min_Limit IS NULL   
--					SET @Emp_OT_Min_Limit = '00:00'
					  

--				  if @Emp_OT_Min_Limit IS NOT NULL
--					 Begin
--						DECLARE @OT_Min_HOURS NUMERIC = null
--						DECLARE @OT_Min_MINUTES NUMERIC = null
--						SELECT @OT_Min_HOURS = CAST(DATA AS NUMERIC) FROM dbo.Split(@Emp_OT_Min_Limit, ':') where id=1 AND IsNumeric(Data) = 1 
--						SELECT @OT_Min_MINUTES = CAST(DATA AS NUMERIC) FROM dbo.Split(@Emp_OT_Min_Limit, ':') where id=2  AND IsNumeric(Data) = 1 

--						IF @OT_Min_MINUTES > 59
--							SET @OT_Min_MINUTES = NULL

--						IF @OT_Min_HOURS > 380
--							SET @OT_Min_HOURS = NULL

--						DECLARE @OT_Min_LENGTH INT = 2
--						IF @OT_Min_HOURS > 99
--							SET @OT_Min_LENGTH = 3

--						IF @OT_Min_HOURS IS NULL OR @OT_Min_MINUTES IS NULL
--							BEGIN
--								INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Enter Validation Details of OT Min Limit.',0,'Enter Valid OT Min Limit',GETDATE(),'Employee Master','') 
--								SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
--								Goto ABC;
--							END
--						ELSE
--							BEGIN
--								SET  @Emp_OT_Min_Limit = RIGHT('0' + CAST(@OT_Min_HOURS AS VARCHAR(4)),@OT_Min_LENGTH) + ':' + RIGHT('0' + CAST(@OT_Min_MINUTES AS VARCHAR(2)),2)
--							END
--					 End
		    
--				  IF @Emp_OT_Max_Limit IS NULL  
--					SET @Emp_OT_Max_Limit = '00:00'  

--				  if @Emp_OT_Max_Limit IS NOT NULL
--					Begin
--						DECLARE @HOURS NUMERIC = null
--						DECLARE @MINUTES NUMERIC = null
--						SELECT @HOURS = CAST(DATA AS NUMERIC) FROM dbo.Split(@Emp_OT_Max_Limit, ':') where id=1 AND IsNumeric(Data) = 1 
--						SELECT @MINUTES = CAST(DATA AS NUMERIC) FROM dbo.Split(@Emp_OT_Max_Limit, ':') where id=2  AND IsNumeric(Data) = 1 

--						IF @MINUTES > 59
--							SET @MINUTES = NULL

--						IF @HOURS > 380
--							SET @HOURS = NULL

--						DECLARE @LENGTH INT = 2
--						IF @HOURS > 99
--							SET @LENGTH = 3

--						IF @HOURS IS NULL OR @MINUTES IS NULL
--							BEGIN
--								INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Enter Validation Details of OT Max Limit.',0,'Enter Valid OT Max Limit',GETDATE(),'Employee Master','') 
--								SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
--								Goto ABC;
--							END
--						ELSE
--							BEGIN
--								SET  @Emp_OT_Max_Limit = RIGHT('0' + CAST(@HOURS AS VARCHAR(4)),@LENGTH) + ':' + RIGHT('0' + CAST(@MINUTES AS VARCHAR(2)),2)
--							END
--					End
				    
--				  IF @Emp_Full_PF IS NULL  
--					SET @Emp_Full_PF = 0	--Here 0 is Done by RamiZ on 10/09/2015 ,previously it was 1  
				    
--				  IF @Cmp_Full_PF IS NULL  
--					SET @Cmp_Full_PF = 0	--Here 0 is Done by RamiZ on 10/09/2015 ,previously it was 1  
				    
--				  IF @Emp_PT IS NULL  
--					SET @Emp_PT = 0
			   
--				  IF @Alpha_Code IS NULL  
--					SET @Alpha_Code = NULL   
				   
--				  IF @Emp_Superior IS NULL  
--					SET @Emp_Superior = '0'
				  
					
--				  IF @Salary_Cycle IS NULL   
--					SET @Salary_Cycle = '0'  
					
--				  IF @Emp_Last_Name is Null or @Emp_Last_Name = ''
--					set @Emp_Last_Name = ' '
					
--				  IF @Group_of_Joining IS NULL or @Group_of_Joining ='1900-01-01 00:00:00.000'
--					 set @Group_of_Joining = @Date_Of_Join 

--				Declare @Backdate_Allowed Numeric
--				Select @Backdate_Allowed = Setting_Value From T0040_SETTING WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Setting_Name='Allowed Backdated Joining upto Days'

--				if @Backdate_Allowed > 0
--					Begin
--						if Not Exists(SELECT 1 FROM T0011_LOGIN WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Login_ID = @User_Id and Login_Name LIKE 'admin@%')
--						BEGIN
--							DECLARE @Dt_From_Date Datetime
--							DECLARE @Dt_To_Date Datetime
						
--							SET @Dt_To_Date = CAST(Convert(char(11),GETDATE(),113) AS datetime)
--							SET @Dt_From_Date =  DATEADD(d,((@Backdate_Allowed) * (-1)),@Dt_To_Date)
						
--							if @Date_of_Join < @Dt_From_Date 
--								Begin
--									Declare @Errormsg1  varchar(500)
--									set @Errormsg1 = '@@You can enter date of joining upto ' + ' ' + Cast(CONVERT(varchar(11),@Dt_From_Date,103) as Varchar(11)) + ' ' + ' Date,for more detail contact to administrator.@@.'
									
--									INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,@Errormsg1,0,'Enter Correct Date of Joining',GETDATE(),'Employee Master','') 
--									SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
--									Goto ABC;
--								End	
--						End	
--					End

--				SET @HasResult = ''

--				IF IsNull(@Gender,'') = ''
--					BEGIN
--						INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Gender is not specified',@Loc_Name,'Please specify the gender of the employee',GETDATE(),'Employee Master','')  
--						SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
--					END
--				IF IsNull(@Nationality,'') = ''
--					BEGIN
--						INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Nationality is not specified',@Loc_Name,'Please specify the nationality of the employee',GETDATE(),'Employee Master','')  
--						SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
--					END
--				IF IsNull(@Salary_Basis_On, '') = ''
--					BEGIN
--						INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Salary Basic On is not specified',@Loc_Name,'Please specify the Salary Basic On of the employee',GETDATE(),'Employee Master','')  
--						SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
--					END
--				IF IsNull(@Payment_Mode, '') = ''
--					BEGIN
--						INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Payment Mode is not specified',@Loc_Name,'Please specify the Payment Mode of the employee',GETDATE(),'Employee Master','')  
--						SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
--					END
				

--				if @Restrict_Other_Master <> 0 
--					Begin	
--					  IF EXISTS(SELECT LOC_ID FROM T0001_LOCATION_MASTER WITH (NOLOCK) WHERE LOC_Name =@LOC_Name)  
--							BEGIN    
--								SELECT @Loc_ID = LOC_ID FROM T0001_LOCATION_MASTER WITH (NOLOCK) WHERE LOC_Name =@LOC_Name 
--							END  
--					  ELSE  
--							BEGIN   
--								IF @Loc_Name is not NULL
--									BEGIN  
--										EXEC P0001_LOCATION_MASTER @Loc_ID OUTPUT ,@Loc_Name  
--									END  
--							ELSE  
--								BEGIN  
--									INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Location Name is Not Proper',@Loc_Name,'Please Enter Location Name',GETDATE(),'Employee Master','')  
--									SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
--								END   
--							END
--					End
--				 Else
--					Begin
--						IF EXISTS(SELECT LOC_ID FROM T0001_LOCATION_MASTER WITH (NOLOCK) WHERE LOC_Name =@LOC_Name)  
--							BEGIN    
--								SELECT @Loc_ID = LOC_ID FROM T0001_LOCATION_MASTER WITH (NOLOCK) WHERE LOC_Name =@LOC_Name 
--							END  
--						Else
--							Begin
--								print 'Location'
--								INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Location Name Not Exits',@Emp_Superior,'Enter Correct Location Name',GETDATE(),'Employee Master','')  
--								SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
--								Goto ABC;
--							End
--					End	 
				 
--				 if @Restrict_Other_Master <> 0 
--					Begin
--						 IF EXISTS(SELECT Branch_ID FROM T0030_Branch_Master WITH (NOLOCK) WHERE Branch_Name =@Branch_Name AND Cmp_ID=@Cmp_ID)  
--							BEGIN 
--								SELECT @Branch_ID = Branch_ID,@State_id=State_ID FROM dbo.T0030_Branch_Master WITH (NOLOCK) WHERE Branch_Name =@Branch_Name AND Cmp_ID=@Cmp_ID 
--							END  
--						 ELSE  
--							BEGIN  
--							 IF @Branch_Name is not NULL
--								BEGIN 
--									DECLARE @BRANCH_CODE2 VARCHAR(10)
--									DECLARE @TEMP_BRANCH_NAME VARCHAR(100)
--									DECLARE @Branch_Code VARCHAR(10)  
--									SET @Branch_Code = NULL
--									SET @BRANCH_CODE2 = NULL
--									--SET @Branch_Code = LEFT(@Branch_Name,3)  -- Commented By Ramiz on 12/12/2016 , **Case:- If We Import 2 Employees Abu-North & Abu-South , then Branch Code will become Same , so this will not work

--									SET @temp_Branch_Name = REPLACE(REPLACE(REPLACE(REPLACE(@Branch_Name , '.' , ''), '-', ''), '(',''),')','');
--									Set @Branch_Code2 = LEFT(REPLACE(@temp_Branch_Name, ' ',''),3)
								
--									IF (CHARINDEX(' ', @temp_Branch_Name) > 0)
--										BEGIN
--											SELECT	@Branch_Code = COALESCE(@Branch_Code,'') +  left(data, 1)
--											FROM	dbo.Split(@temp_Branch_Name, ' ' )
--										END
									
--									SET @Branch_Code =  ISNULL(@Branch_Code, @Branch_Code2);
									
--									IF  EXISTS(SELECT 1 FROM T0030_BRANCH_MASTER WITH (NOLOCK)
--												WHERE	Branch_Code = @Branch_Code AND Cmp_ID=@Cmp_ID)
--										BEGIN 
--											DECLARE @INDEX_BRANCH INT
--											SELECT	@INDEX_BRANCH = IsNull(COUNT(1), 0) + 1
--											FROM	T0030_BRANCH_MASTER WITH (NOLOCK)
--											WHERE	Branch_Code LIKE @Branch_Code + '_%' AND Cmp_ID=@Cmp_ID											

--											SET @Branch_Code = @Branch_Code + '_' + CAST(@INDEX_BRANCH AS VARCHAR(2))
											
--											--IF  EXISTS(SELECT 1 FROM T0030_BRANCH_MASTER
--											--	WHERE	Branch_Code = @Branch_Code2)
--											--	SET @Branch_Code = UPPER(@temp_Branch_Name);
--											--ELSE
--											--	SET @Branch_Code = UPPER(@Branch_Code2);
--										END

--									EXEC P0030_BRANCH_MASTER @Branch_ID OUTPUT ,@Cmp_ID,@State_ID,@Branch_Code,@Branch_Name,'','','','I',0,0,'',0,0,0,'','','','',1,NULL,NULL,NULL,'',1 
--								END  
--							ELSE  
--								BEGIN  
--									INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Branch Name is Not Proper',@Branch_Name,'Please Enter Branch Name',GETDATE(),'Employee Master','')  
--									SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
--								END    
--						   END 
--					End
--				Else
--					BEGIN
--						IF EXISTS(SELECT Branch_ID FROM T0030_Branch_Master WITH (NOLOCK) WHERE Branch_Name =@Branch_Name AND Cmp_ID=@Cmp_ID)  
--							BEGIN 
--								SELECT @Branch_ID = Branch_ID,@State_id=State_ID FROM dbo.T0030_Branch_Master WITH (NOLOCK) WHERE Branch_Name =@Branch_Name AND Cmp_ID=@Cmp_ID 
--							END
--						Else
--							BEGIN
--								print 'Branch'
--								INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Branch Name Not Exits',@Emp_Superior,'Enter Correct Branch Name',GETDATE(),'Employee Master','')  
--								SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
--								Goto ABC;
--						    END   
--					END  
					 
--				if @Restrict_Other_Master <> 0
--					Begin
--						IF EXISTS(SELECT Grd_ID FROM T0040_GRADE_Master WITH (NOLOCK) WHERE Grd_Name =@Grd_Name AND Cmp_ID=@Cmp_ID)  
--							BEGIN  
--								SELECT @Grd_ID = Grd_ID FROM T0040_GRADE_Master WITH (NOLOCK) WHERE Grd_Name =@Grd_Name AND Cmp_ID=@Cmp_ID 
--							END  
--						ELSE  
--							BEGIN 
								
--								IF @Grd_Name is not NULL  
--									BEGIN
--										EXEC p0040_GRADE_MASTER @Grd_ID OUTPUT ,@Cmp_ID,0,@Grd_Name,@Grd_Name,0,'I',0,0,0,''
--									END  
--								ELSE  
--									BEGIN 
--										INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Grade Name is Not Proper',@Grd_Name,'Please Enter Grade Name',GETDATE(),'Employee Master','')  
--										SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
--									END    
--							END	
--					End
--				Else
--					Begin
--						IF EXISTS(SELECT Grd_ID FROM T0040_GRADE_Master WITH (NOLOCK) WHERE Grd_Name =@Grd_Name AND Cmp_ID=@Cmp_ID)  
--							BEGIN  
--								SELECT @Grd_ID = Grd_ID FROM T0040_GRADE_Master WITH (NOLOCK) WHERE Grd_Name =@Grd_Name AND Cmp_ID=@Cmp_ID 
--							END
--						Else
--							BEGIN
--							print 'grade'
--								INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Grade Name Not Exits',@Emp_Superior,'Enter Correct Grade Name',GETDATE(),'Employee Master','')  
--								SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
--								Goto ABC;
--						    END
--					End
				
--				if @Restrict_Other_Master <> 0
--					Begin
--						IF EXISTS(SELECT Dept_ID FROM T0040_Department_Master WITH (NOLOCK) WHERE Dept_Name =@Dept_Name AND Cmp_ID=@Cmp_ID)  
--							BEGIN  
--								SELECT @Dept_ID = Dept_ID FROM T0040_Department_Master WITH (NOLOCK) WHERE Dept_Name =@Dept_Name AND Cmp_ID=@Cmp_ID  
--							END  
--						ELSE  
--							BEGIN        
--								IF @Dept_Name <> ''  
--									BEGIN  
--										EXEC P0040_DEPARTMENT_MASTER @Dept_ID OUTPUT ,@Cmp_ID,@Dept_Name,0,'','I'
--									END   
--								ELSE  
--									BEGIN  
--										SET @Dept_ID = NULL  
--									END  
--							END
--					END
--				Else
--					BEGIN
--					  IF EXISTS(SELECT Dept_ID FROM T0040_Department_Master WITH (NOLOCK) WHERE Dept_Name =@Dept_Name AND Cmp_ID=@Cmp_ID)  
--							BEGIN  
--								SELECT @Dept_ID = Dept_ID FROM T0040_Department_Master WITH (NOLOCK) WHERE Dept_Name =@Dept_Name AND Cmp_ID=@Cmp_ID  
--							END
--					  Else
--							BEGIN
--								IF @Dept_Name <> '' or @Dept_Name is not null
--									Begin
--										print 'Department'
--										INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Department Name Not Exits',@Emp_Superior,'Enter Correct Department Details',GETDATE(),'Employee Master','')  
--										SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
--										Goto ABC;
--									End
--								ELSE  
--									BEGIN  
--										SET @Dept_ID =NULL  
--									END
--						    END
--					End
				
--				if @Restrict_Other_Master <> 0
--					Begin
--						IF EXISTS(SELECT Desig_ID FROM T0040_Designation_Master WITH (NOLOCK) WHERE Desig_Name =@desig_Name AND Cmp_ID=@Cmp_ID)  
--							BEGIN  
--								SELECT @Desig_ID = Desig_ID FROM T0040_Designation_Master WITH (NOLOCK) WHERE Desig_Name =@desig_Name AND Cmp_ID=@Cmp_ID
--							END  
--					    ELSE  
--							BEGIN  
--								IF @Desig_Name IS NOT NULL  
--									BEGIN 
--										Declare @Desig_Code Varchar(5)
--										Declare @Desig_Code2 Varchar(5)
--										Declare @TEMP_DESIG_NAME Varchar(100)
--										SET @Desig_Code = NULL
--										SET @Desig_Code2 = NULL
--										--Set @Desig_Code = LEFT(@Desig_Name,3) -- Commented By Ramiz on 12/12/2016 , **Case:- If We Import 2 employees Senior Developer & Senior Tester , then Designation Code will become Same , so this will not work
										
--										SET @TEMP_DESIG_NAME = REPLACE(REPLACE(REPLACE(REPLACE(@DESIG_NAME , '.' , ''), '-', ''), '(',''),')','');
--										Set @Desig_Code2 = LEFT(REPLACE(@TEMP_DESIG_NAME, ' ',''),3)
								
										
--										IF (CHARINDEX(' ', @temp_Desig_Name) > 0)
--											BEGIN
--												SELECT	@Desig_Code = COALESCE(@Desig_Code,'') +  left(data, 1)
--												FROM	dbo.Split(@temp_Desig_Name, ' ' )	
												
--											END
										
--										SET @Desig_Code =  ISNULL(@Desig_Code, @Desig_Code2);										
										
										
--										IF  EXISTS(SELECT 1 FROM T0040_DESIGNATION_MASTER WITH (NOLOCK) 
--													WHERE	Desig_Code = @Desig_Code  AND Cmp_ID=@Cmp_ID)
--											BEGIN 
--												DECLARE @INDEX INT
--												SELECT	@INDEX = IsNull(COUNT(1),0) + 1
--												FROM	T0040_DESIGNATION_MASTER WITH (NOLOCK)
--												WHERE	Desig_Code LIKE @Desig_Code + '_%' AND Cmp_ID=@Cmp_ID
												
--												SET @Desig_Code = @Desig_Code + '_' + CAST(@INDEX AS VARCHAR(2))

												
--												--IF  EXISTS(SELECT 1 FROM T0040_DESIGNATION_MASTER
--												--	WHERE	Desig_Code = @Desig_Code2  AND Cmp_ID=@Cmp_ID)
--												--	BEGIN 
														
--												--		SELECT	@INDEX = COUNT(1) 
--												--		FROM	T0040_DESIGNATION_MASTER
--												--		WHERE	Desig_Code = @Desig_Code2  AND Cmp_ID=@Cmp_ID
--												--		SET @Desig_Code = UPPER(@temp_Desig_Name);
--												--	END
--												--ELSE
--												--	SET @Desig_Code = UPPER(@Desig_Code2);
--											END
										
--										EXEC P0040_DESIGNATION_MASTER @Desig_ID OUTPUT ,@Cmp_ID,@Desig_Name,0,0,0,0,'I','',0,'',0,@Desig_Code,1,null,'',0
--									END  
--								ELSE  
--									BEGIN  
--										print 'Designation'
--										INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Designation Name is Not Proper',@Desig_Name,'Please Enter Designation Name',GETDATE(),'Employee Master','')  
--										SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
--										Goto ABC;
--									END    
--							END
--					End
--				Else
--					Begin
--						IF EXISTS(SELECT Desig_ID FROM T0040_Designation_Master WITH (NOLOCK) WHERE Desig_Name =@desig_Name AND Cmp_ID=@Cmp_ID)  
--							BEGIN  
--								SELECT @Desig_ID = Desig_ID FROM T0040_Designation_Master WITH (NOLOCK) WHERE Desig_Name =@desig_Name AND Cmp_ID=@Cmp_ID
--							END
--						Else
--							Begin
--								print 'Designation'
--								INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Designation Name Not Exits',@Emp_Superior,'Enter Correct Designation Details',GETDATE(),'Employee Master','')  
--								SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
--								Goto ABC;
--							End
--					End  
					 
--				if @Restrict_Other_Master <> 0
--					Begin
--						IF EXISTS(SELECT TYPE_ID FROM T0040_TYPE_Master WITH (NOLOCK) WHERE TYPE_NAME =@Type_Name AND Cmp_ID=@Cmp_ID)  
--							BEGIN  
--								SELECT @Type_ID = TYPE_ID FROM T0040_TYPE_Master WITH (NOLOCK) WHERE TYPE_NAME =@Type_Name AND Cmp_ID=@Cmp_ID 
--							END  
--						ELSE  
--							BEGIN  
--								IF @Type_Name is not NULL  
--									BEGIN  
--										EXEC P0040_TYPE_MASTER @Type_ID OUTPUT ,@Cmp_ID,@Type_Name,0,0,'I'  
--									END  
--								ELSE  
--									BEGIN  
--										INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Type Name is Not Proper',@Type_Name,'Please Enter Type Name',GETDATE(),'Employee Master','')  
--										SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
--										Goto ABC;
--									END    
--							END
--					End
--				Else
--					Begin
--						IF EXISTS(SELECT TYPE_ID FROM T0040_TYPE_Master WITH (NOLOCK) WHERE TYPE_NAME =@Type_Name AND Cmp_ID=@Cmp_ID)  
--							BEGIN  
--								SELECT @Type_ID = TYPE_ID FROM T0040_TYPE_Master WITH (NOLOCK) WHERE TYPE_NAME =@Type_Name AND Cmp_ID=@Cmp_ID 
--							END
--						Else
--							Begin
--								print 'Employee Type'
--								INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Employee Type Name Not Exits',@Emp_Superior,'Enter Correct Employee Type Details',GETDATE(),'Employee Master','')  
--								SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
--								Goto ABC;
--							End
--					End 
				
				
--				if @Restrict_Other_Master <> 0
--					Begin
--						IF EXISTS(SELECT Shift_ID FROM T0040_SHIFT_MASTER WITH (NOLOCK) WHERE Shift_Name =@Shift_Name  AND Cmp_ID=@Cmp_ID)  
--							BEGIN  
--								SELECT @Shift_ID = Shift_ID FROM T0040_SHIFT_MASTER WITH (NOLOCK) WHERE Shift_Name =@Shift_Name  AND Cmp_ID=@Cmp_ID 
--							END  
--						ELSE  
--							BEGIN  
--								IF @Shift_Name is not NULL
--									BEGIN  
--										EXEC P0040_Shift_Master @Shift_ID OUTPUT ,@Cmp_ID,@Shift_Name,'09:00','17:00','08:00','09:00','17:00','08:00','','','','','','','I'  
--									END  
--								ELSE  
--									BEGIN  
--										INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Shift Name is Not Proper',@Shift_Name,'Please Enter Shift Name',GETDATE(),'Employee Master','')  
--										SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
--									END     
--							END
--					End
--				Else
--					Begin
--						IF EXISTS(SELECT Shift_ID FROM T0040_SHIFT_MASTER WITH (NOLOCK) WHERE Shift_Name =@Shift_Name  AND Cmp_ID=@Cmp_ID)  
--							BEGIN  
--								PRINT 'sh'
--								SELECT @Shift_ID = Shift_ID FROM T0040_SHIFT_MASTER WITH (NOLOCK) WHERE Shift_Name =@Shift_Name  AND Cmp_ID=@Cmp_ID 
--							END
--						Else
--							Begin
--								print 'shift'
--								INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Shift Name Not Exits',@Emp_Superior,'Enter Correct Shift Details',GETDATE(),'Employee Master','')  
--								SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
--								Goto ABC;
--							End
--					End
					
				 
--				if @Restrict_Other_Master <> 0
--					Begin
--						IF EXISTS(SELECT Bank_ID FROM T0040_Bank_Master WITH (NOLOCK) WHERE Bank_Name = @Bank_Name AND Cmp_ID=@Cmp_ID)  
--							BEGIN  
--						SELECT @Bank_ID = Bank_ID FROM T0040_Bank_Master WITH (NOLOCK) WHERE Bank_Name = @Bank_Name AND Cmp_ID=@Cmp_ID  
--							END  
--						ELSE  
--							BEGIN  
--								IF @Bank_Name <> ''
--									BEGIN  
--										DECLARE @Bank_Code VARCHAR(10) , @Bank_Branch_Name VARCHAR(50) 
--										SET @Bank_Code = LEFT(@Bank_Name,3)  

--										Select @Bank_Branch_Name = Cmp_City from T0010_COMPANY_MASTER Where Cmp_ID=@Cmp_ID 
										
--										EXEC P0040_BANK_MASTER @Bank_ID OUTPUT ,@Cmp_ID,@Bank_Code,@Bank_Name,'00000000','',@Bank_Branch_Name,'','N','I',@Emp_IFSC_No  
--									END  
--								ELSE  
--									BEGIN  
--										SET @Bank_ID =NULL  
--									END  
--							END
--					End
--				Else
--					Begin
--						IF EXISTS(SELECT Bank_ID FROM T0040_Bank_Master WITH (NOLOCK) WHERE Bank_Name =@Bank_Name AND Cmp_ID=@Cmp_ID)  
--							BEGIN  
--								SELECT @Bank_ID = Bank_ID FROM T0040_Bank_Master WITH (NOLOCK) WHERE Bank_Name =@Bank_Name AND Cmp_ID=@Cmp_ID  
--							END
--						Else
--							Begin
--								IF @Bank_Name is not NULL
--									BEGIN
--										print 'Bank'
--										INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Bank Name Not Exits',@Emp_Superior,'Enter Correct Bank Details',GETDATE(),'Employee Master','')  
--										SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
--										Goto ABC;
--									END
--								ELSE  
--									BEGIN  
--										SET @Bank_ID =NULL  
--									END
--							End
--					End	
				 
--				if @Restrict_Other_Master <> 0
--					Begin
--						IF EXISTS(SELECT Curr_ID FROM T0040_Currency_MAster  WITH (NOLOCK)  WHERE Curr_Name =@Curr_Name AND Cmp_ID=@Cmp_ID)  
--							BEGIN  
--								SELECT @Curr_ID = Curr_ID FROM T0040_Currency_MAster WITH (NOLOCK) WHERE Curr_Name =@Curr_Name AND Cmp_ID=@Cmp_ID 
--							END  
--						ELSE  
--							BEGIN  
--								IF @Curr_Name <> ''  
--									BEGIN  
--										EXEC P0040_CURRENCY_MASTER @Curr_ID OUTPUT ,@Cmp_ID,@Curr_Name,0,'N','','','I'  
--									END  
--								ELSE  
--									BEGIN  
--										SET @Curr_ID = NULL  
--									END    
--							END
--					End
--				Else
--					Begin
--						IF EXISTS(SELECT Curr_ID FROM T0040_Currency_MAster WITH (NOLOCK) WHERE Curr_Name =@Curr_Name AND Cmp_ID=@Cmp_ID)  
--							BEGIN  
--								SELECT @Curr_ID = Curr_ID FROM T0040_Currency_MAster WITH (NOLOCK) WHERE Curr_Name =@Curr_Name AND Cmp_ID=@Cmp_ID 
--							END
--						Else
--							Begin
--								print 'Currency'
--								INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Currency Code Not Exits',@Emp_Superior,'Enter Correct Currency Details',GETDATE(),'Employee Master','')  
--								SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
--								Goto ABC;
--							End
--					End
				
--				if @Restrict_Other_Master <> 0
--					Begin
--						IF EXISTS(SELECT Cat_ID FROM T0030_Category_master WITH (NOLOCK) WHERE Cat_Name =@Product_name AND Cmp_ID=@Cmp_ID)  
--							BEGIN    
--								SELECT @Cat_ID = Cat_ID FROM T0030_Category_master WITH (NOLOCK) WHERE Cat_Name =@Product_name AND Cmp_ID=@Cmp_ID  
--							END  
--						ELSE  
--							BEGIN  
--								IF @Product_name <> ''  
--									BEGIN  
--										EXEC P0030_Category_master @Cat_ID OUTPUT ,@Product_name,@Cmp_ID,'','I'  
--									END   
--								ELSE  
--									BEGIN  
--										SET @Cat_ID = NULL  
--									END    
--							END
--					End
--				Else
--					Begin
--						IF EXISTS(SELECT Cat_ID FROM T0030_Category_master WITH (NOLOCK) WHERE Cat_Name =@Product_name AND Cmp_ID=@Cmp_ID)  
--							BEGIN    
--								SELECT @Cat_ID = Cat_ID FROM T0030_Category_master WITH (NOLOCK) WHERE Cat_Name =@Product_name AND Cmp_ID=@Cmp_ID  
--							END
--						Else
--							Begin
--								IF @Product_name <> '' or @Product_name is not null
--									Begin
--									print 'Cat'
--										INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Category Name Not Exits',@Emp_Superior,'Enter Correct Category Details',GETDATE(),'Employee Master','')  
--										SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
--										Goto ABC;
--									End
--								Else
--									Begin
--										SET @Cat_ID = NULL
--									End
--							End
--					End
					
--				if @Restrict_Other_Master <> 0
--					Begin
--						IF EXISTS(SELECT Segment_ID FROM T0040_Business_Segment WITH (NOLOCK) WHERE Segment_Name = @Business_Segment AND Cmp_ID = @Cmp_ID )
--							BEGIN
--								SELECT @Segment_ID = Segment_ID FROM T0040_Business_Segment WITH (NOLOCK) WHERE Segment_Name = @Business_Segment AND Cmp_ID = @Cmp_ID
--							END
--						ELSE
--							BEGIN
--								IF @Business_Segment <> ''
--									BEGIN
--										Declare @Segment_Code As Varchar(50)					
--										Set @Segment_Code = Substring(@Business_Segment,1,3)
										
--										IF  EXISTS(SELECT 1 FROM T0040_Business_Segment WITH (NOLOCK) 
--													WHERE	Segment_Code = @Segment_Code  AND Cmp_ID=@Cmp_ID)
--											BEGIN 
--												DECLARE @INDEX_SEG INT
--												SELECT	@INDEX_SEG = IsNull(COUNT(1),0) + 1
--												FROM	T0040_Business_Segment WITH (NOLOCK)
--												WHERE	Segment_Code LIKE @Segment_Code + '_%' AND Cmp_ID=@Cmp_ID
												
--												SET @Segment_Code = @Segment_Code + '_' + CAST(@INDEX_SEG AS VARCHAR(2))
--											END

--										EXEC P0040_BUSINESS_SEGEMENT @Segment_ID OUTPUT,@cmp_ID,@Segment_Code,@Business_Segment,'','I'
--									END
--								ELSE
--									BEGIN
--										SET @Segment_ID = NULL
--									END
--							END
--					End
--				Else
--					Begin
--						IF EXISTS(SELECT Segment_ID FROM T0040_Business_Segment WITH (NOLOCK) WHERE Segment_Name = @Business_Segment AND Cmp_ID = @Cmp_ID )
--							BEGIN
--								SELECT @Segment_ID = Segment_ID FROM T0040_Business_Segment WITH (NOLOCK) WHERE Segment_Name = @Business_Segment AND Cmp_ID = @Cmp_ID
--							END
--						Else
--							Begin
--								IF @Business_Segment <> '' or @Business_Segment is not null
--									Begin
--										print 'Business'
--										INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Business Segment Name Not Exits',@Emp_Superior,'Enter Correct Business Segment Details',GETDATE(),'Employee Master','')  
--										SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
--										Goto ABC;
--									End
--								Else
--									Begin
--										SET @Segment_ID = NULL
--									End
--							End
--					End
					
					
--				 if @Restrict_Other_Master <> 0
--					Begin
--						IF EXISTS(SELECT Vertical_ID FROM T0040_Vertical_Segment WITH (NOLOCK) WHERE Vertical_Name = @Vertical AND Cmp_ID = @Cmp_ID )
--							BEGIN
--								SELECT @Vertical_ID = Vertical_ID FROM T0040_Vertical_Segment WITH (NOLOCK) WHERE Vertical_Name = @Vertical AND Cmp_ID = @Cmp_ID
--							END
--						ELSE
--							BEGIN
--								IF @Vertical <> ''
--									BEGIN
										
--										Declare @Vertical_Code As Varchar(50)			
--										Set @Vertical_Code = Substring(@Vertical,1,3)	
										
--										IF  EXISTS(SELECT 1 FROM T0040_Vertical_Segment WITH (NOLOCK) 
--													WHERE	Vertical_Code = @Vertical_Code  AND Cmp_ID=@Cmp_ID)
--											BEGIN 
--												DECLARE @INDEXX INT
--												SELECT	@INDEXX = IsNull(COUNT(1),0) + 1
--												FROM	T0040_Vertical_Segment WITH (NOLOCK)
--												WHERE	Vertical_Code LIKE @Vertical_Code + '_%' AND Cmp_ID=@Cmp_ID
												
--												SET @Vertical_Code = @Vertical_Code + '_' + CAST(@INDEXX AS VARCHAR(2))
--											END

--										EXEC P0040_Vertical @Vertical_ID OUTPUT,@cmp_ID, @Vertical_Code, @Vertical, '', 'I'
--									END

--								ELSE
--									BEGIN
--										SET @Vertical_ID = NULL
--									END
--							END
--					End
--				 Else
--					Begin
--						IF EXISTS(SELECT Vertical_ID FROM T0040_Vertical_Segment WITH (NOLOCK) WHERE Vertical_Name = @Vertical AND Cmp_ID = @Cmp_ID )
--							BEGIN
--								SELECT @Vertical_ID = Vertical_ID FROM T0040_Vertical_Segment WITH (NOLOCK) WHERE Vertical_Name = @Vertical AND Cmp_ID = @Cmp_ID
--							END
--						Else
--							Begin
--								IF @Vertical <> '' or @Vertical is not null
--									Begin 
--										INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Vertical Name Not Exits',@Emp_Superior,'Enter Correct Vertical Details',GETDATE(),'Employee Master','')  
--										SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
--										Goto ABC;
--									End
--								Else
--									Begin
--										SET @Vertical_ID = NULL
--									End
--							End
--					End	
				 	
--				if @Restrict_Other_Master <> 0
--					Begin
--						IF EXISTS(SELECT SubVertical_ID FROM T0050_SubVertical WITH (NOLOCK) WHERE SubVertical_Name = @Sub_Vertical AND Vertical_ID = @Vertical_ID AND Cmp_ID = @Cmp_ID )
--							BEGIN
--								SELECT @SubVertical_ID = SubVertical_ID FROM T0050_SubVertical WITH (NOLOCK) WHERE SubVertical_Name = @Sub_Vertical AND Vertical_ID = @Vertical_ID AND Cmp_ID = @Cmp_ID
--							END
--						ELSE
--							BEGIN
--								IF @Sub_Vertical <> ''
--									BEGIN
--										Declare @SubVertical_Code As Varchar(50)			
--										Set @SubVertical_Code = Substring(@sub_Vertical,1,3)	

--										IF  EXISTS(SELECT 1 FROM T0050_SubVertical WITH (NOLOCK) 
--													WHERE	SubVertical_Code = @SubVertical_Code  AND Cmp_ID=@Cmp_ID)
--											BEGIN 
--												DECLARE @INDEX_SUB INT
--												SELECT	@INDEX_SUB = IsNull(COUNT(1),0) + 1
--												FROM	T0050_SubVertical WITH (NOLOCK)
--												WHERE	SubVertical_Code LIKE @SubVertical_Code + '_%' AND Cmp_ID=@Cmp_ID
												
--												SET @SubVertical_Code = @SubVertical_Code + '_' + CAST(@INDEX_SUB AS VARCHAR(2))
--											END

--										EXEC P0050_SubVertical @subvertical_ID OUTPUT,@cmp_ID,@Vertical_ID,@SubVertical_Code,@sub_Vertical,'','I'
--									END
--								 ELSE
--									BEGIN
--										SET @SubVertical_ID = NULL
--									END
--							END
--					End
--				Else
--					Begin
--						IF EXISTS(SELECT SubVertical_ID FROM T0050_SubVertical WITH (NOLOCK) WHERE SubVertical_Name = @Sub_Vertical AND Vertical_ID = @Vertical_ID AND Cmp_ID = @Cmp_ID )
--							BEGIN
--								SELECT @SubVertical_ID = SubVertical_ID FROM T0050_SubVertical WITH (NOLOCK) WHERE SubVertical_Name = @Sub_Vertical AND Vertical_ID = @Vertical_ID AND Cmp_ID = @Cmp_ID
--							END
--						Else
--							Begin
--								IF @Sub_Vertical <> '' or @Sub_Vertical is not null
--									Begin
--										print 'sub Vertical'
--										INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Sub-Vertical Name Not Exits',@Emp_Superior,'Enter Correct Sub-Vertical Details',GETDATE(),'Employee Master','')  
--										SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
--										Goto ABC;
--									End
--								Else
--									Begin
--										SET @SubVertical_ID = NULL
--									End
--							End
--					End
					
				
--				if @Restrict_Other_Master <> 0
--					Begin
--						IF EXISTS(SELECT SubBranch_ID FROM T0050_SubBranch WITH (NOLOCK) WHERE SubBranch_Name = @Sub_Branch AND Branch_ID = @Branch_ID AND Cmp_ID = @Cmp_ID )
--							BEGIN
--								SELECT @SubBranch_ID = SubBranch_ID FROM T0050_SubBranch WITH (NOLOCK) WHERE SubBranch_Name = @sub_Branch AND Branch_ID = @Branch_ID AND Cmp_ID = @Cmp_ID
--							END
--						ELSE
--							BEGIN
--								IF @sub_Branch <> '' 
--									BEGIN
--										Declare @SubBranch_Code As Varchar(50)					
--										Set @SubBranch_Code = Substring(@sub_Branch,1,3)	
										

--									--Added by ronakk 22082022

--										IF  EXISTS(SELECT 1 FROM T0050_SubBranch WITH (NOLOCK) 
--													WHERE	SubBranch_Code = @SubBranch_Code  AND Cmp_ID=@Cmp_ID)
--											BEGIN 
--												DECLARE @INDEX_SUBB INT
--												SELECT	@INDEX_SUBB = IsNull(COUNT(1),0) + 1
--												FROM	T0050_SubBranch WITH (NOLOCK)
--												WHERE	SubBranch_Code LIKE @SubBranch_Code + '_%' AND Cmp_ID=@Cmp_ID
												
--												SET @SubBranch_Code = @SubBranch_Code + '_' + CAST(@INDEX_SUBB AS VARCHAR(2))
--											END

--								  --End by ronakk 22082022

--										EXEC P0050_SubBranch @subBranch_ID OUTPUT,@cmp_ID,@Branch_ID,@SubBranch_Code,@sub_Branch,'','I'
--									END
--								ELSE
--									BEGIN
--										SET @SubBranch_ID = NULL
--									END
--						END
--					End
--				Else
--					Begin
--					  IF EXISTS(SELECT SubBranch_ID FROM T0050_SubBranch WITH (NOLOCK) WHERE SubBranch_Name = @Sub_Branch AND Branch_ID = @Branch_ID AND Cmp_ID = @Cmp_ID )
--							BEGIN
--								SELECT @SubBranch_ID = SubBranch_ID FROM T0050_SubBranch WITH (NOLOCK) WHERE SubBranch_Name = @sub_Branch AND Branch_ID = @Branch_ID AND Cmp_ID = @Cmp_ID
--							END
--					  Else
--							Begin
--								IF @sub_Branch <> '' or @sub_Branch is not null
--									Begin
--										print 'Sub Branch'
--										INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Sub-Branch Name Not Exits',@Emp_Superior,'Enter Correct Sub-Branch Details',GETDATE(),'Employee Master','')  
--										SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
--										Goto ABC;
--									End
--								Else
--									Begin
--										SET @sub_Branch = NULL
--									End
--							End
--					End		
					
				
--				IF @Salary_Cycle <> '0'
--					BEGIN 
						
--						IF NOT EXISTS(SELECT Tran_ID FROM dbo.T0040_Salary_Cycle_Master WITH (NOLOCK) WHERE Name = @Salary_Cycle AND Cmp_Id = @Cmp_ID)  
--							BEGIN   
--								print 'salary Cycle'   
--								INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Salary Cycle Not Exits',@Emp_Superior,'Please First Add Salary Cycle In Master',GETDATE(),'Employee Master','')  
--								SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
--								--Set @Status_Details = cast(@Emp_Code as varchar(100)) + ',' 
								
--							END  
--						ELSE  
--							BEGIN  
--								SELECT @Salary_Cycle_ID = Tran_ID FROM dbo.T0040_Salary_Cycle_Master WITH (NOLOCK) WHERE Cmp_Id = @cmp_Id AND Name = @Salary_Cycle  
--							END     
--					END
				
--				-- Added by Gadriwala Muslim 09022015 - Start
--				IF @Emp_Superior <> '0' 
--						BEGIN 
--								print @Log_Status
--								IF NOT EXISTS(SELECT Emp_Id FROM dbo.T0080_Emp_Master WITH (NOLOCK) WHERE Alpha_Emp_Code=@Emp_Superior AND Cmp_Id=@Cmp_ID)  
--									BEGIN  
--										INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Superior Code Not Exits',@Emp_Superior,'Please First ALTER Employee To Assign',GETDATE(),'Employee Master','')  
--										SET @Log_Status=1
--										RETURN  
--									END  
--								ELSE  
--									BEGIN  
--										SELECT @emp_Id_sup = Emp_Id FROM dbo.T0080_Emp_Master WITH (NOLOCK) WHERE Cmp_Id=@cmp_Id AND Alpha_Emp_Code=@Emp_Superior  
--									END 
									  
--						END   
--				-- Added by Gadriwala Muslim 09022015 - End	
				
				
--				-- Added by Nilesh Patel on 08082015 - Start
				
--				if @Pay_Scale_Name = ''
--					Set @Pay_Scale_Name = NULL
				
--				SET @Pay_Scale_ID = 0	
--				IF @Pay_Scale_Name is not null  
--						BEGIN 
--								IF NOT EXISTS(SELECT Pay_Scale_ID FROM dbo.T0040_PAY_SCALE_MASTER WITH (NOLOCK) WHERE Pay_Scale_Name = @Pay_Scale_Name AND Cmp_Id = @Cmp_ID)  
--									BEGIN   
--									print 'pay cycle'   
--										INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Pay Scale Details Not Exits',@Pay_Scale_Name,'Please First Add Pay Scale In Master',GETDATE(),'Employee Master','')  
--										SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
--										Goto ABC; 
--									END  
--								ELSE  
--									BEGIN  
--										SELECT @Pay_Scale_ID = Pay_Scale_ID FROM dbo.T0040_PAY_SCALE_MASTER WITH (NOLOCK) WHERE Cmp_Id = @cmp_Id AND Pay_Scale_Name = @Pay_Scale_Name  
--									END       
--						END   
--				-- Added by Nilesh Patel on 08082015 - End	
				
--				IF @Cat_ID = 0  
--					SET @Cat_ID = NULL  
			 
--				IF @Dept_ID = 0  
--					SET @Dept_ID = NULL   
					
--				IF @Desig_Id = 0  
--					SET @Desig_Id = NULL 
					 
--				IF @Type_ID =0  
--					SET @Type_ID = NULL  
			 
--				IF @Loc_ID =0  
--					SET @Loc_ID = NULL  
		
--				IF @Curr_ID =0  
--					SET @Curr_ID = NULL  
			 
--				IF @Bank_ID =0  
--					SET @Bank_ID = NULL  
				
--				--IF @Payment_Mode IS NULL
--				--	SET @Payment_Mode= 'Cash'  
				
--				IF @Inc_Bank_AC_No IS NULL
--					SET @Inc_Bank_AC_No = NULL  
			 
--				IF @Confirm_Date IS NULL
--					SET @Confirm_Date = NULL
					  
--				IF @Segment_ID = 0
--					SET @Segment_ID = NULL	
			   
--				IF @Vertical_ID  = 0
--					SET @Vertical_ID = NULL 
			 
--				IF @SubVertical_ID = 0 
--					SET @SubVertical_ID = NULL 
			  
--				IF @SubBranch_ID = 0 
--					SET @SubBranch_ID = NULL  
			  
--				IF @Group_of_Joining IS NULL or @Group_of_Joining ='1900-01-01 00:00:00.000'
--					SET @Group_of_Joining = NULL  
					
--				IF IsNull(@Date_Of_Join, '1900-01-01') = '1900-01-01'
--					BEGIN  
--						INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Date Of Join is Not Proper',NULL,'Enter Date Of Join Proper It Must be dd-MMM-yyyy',GETDATE(),'Employee Master','')  
--						SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
--						SET @Emp_ID = 0   
--					END   
--				--added by jimit 23062017
--				IF (Cast(@Marital_Status As INT) > 3 or Cast(@Marital_Status AS INT) < 0)
--					BEGIN
--						INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Marital Status is Not Proper',NULL,'Enter Marital Status should be < 3',GETDATE(),'Employee Master','')  
--						SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
--						SET @Emp_ID = 0   
--					END
				
--				IF @Emp_Code = 0  
--					BEGIN        
--						INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Employee Code is Null Or 0 Or Was Not Properly Inserted',@Emp_Code,'Enter Employee Code Proper',GETDATE(),'Employee Master','')     
--					END  
		    
--				IF @Emp_First_Name IS NULL 
--					BEGIN  
--						print 'emp full name '
--						INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Employee First Name is Null Was Not Properly Inserted',@Emp_Code,'Enter Proper Employee First Name',GETDATE(),'Employee Master','')     
--						SET @HasResult = cast(@Emp_Code as varchar(100)) + ',' 
--						--Set @Status_Details = @Status_Details + cast(@Emp_Code as varchar(100)) + ','
--					END  
				
--				IF @Emp_Code=0 OR @Date_Of_Join Is NULL OR @Shift_Name Is NULL OR @Type_Name Is NULL OR @Desig_Name Is NULL OR @Grd_Name Is NULL OR @LOC_Name Is NULL OR @Branch_Name Is NULL OR @Emp_ID=0  
--				 BEGIN 
--					SET @HasResult = cast(@Emp_Code as varchar(100)) + ',' 
--					--Set @Status_Details = @Status_Details + cast(@Emp_Code as varchar(100)) + ','
--				 END

--				 if Isnull(@Enroll_No,0) <> 0
--					Begin
--						IF Exists(Select 1 From T0010_COMPANY_MASTER WITH (NOLOCK) Where Cmp_Id = @Cmp_ID and is_GroupOFCmp = 1)
--							Begin
--								if Object_ID('tempdb..#GroupCompany') is not NULL
--									BEGIN
--										Drop TABLE #GroupCompany
--									End

--								Create table #GroupCompany(Cmp_ID Numeric(18,0))

--								insert into #GroupCompany 
--								Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1

--								IF Exists(Select 1 From T0080_EMP_MASTER EM WITH (NOLOCK) Inner Join #GroupCompany GC ON EM.Cmp_ID = GC.Cmp_ID Where EM.Enroll_No = @Enroll_No AND Emp_Left_Date is null)
--									Begin 
--										INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Employee Enroll No. is exists so please check it.',@Emp_Code,'Employee Enroll No. is exists so please check it.',GETDATE(),'Employee Master','')     
--										SET @HasResult = cast(@Emp_Code as varchar(100)) + ',' 
--										SET @Log_Status=1
--										RETURN 
--									End

--							End
--						Else 
--							Begin
--								IF Exists(Select 1 From T0080_EMP_MASTER EM  WITH (NOLOCK) Where EM.Enroll_No = @Enroll_No AND Emp_Left_Date is null)
--									Begin 
--										INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Employee Enroll No. is exists so please check it.',@Emp_Code,'Employee Enroll No. is exists so please check it.',GETDATE(),'Employee Master','')     
--										SET @HasResult = cast(@Emp_Code as varchar(100)) + ',' 
--										SET @Log_Status=1
--										RETURN 
--									End
--							End
--					END
				
--				-----------Added By Jimit 08012018--------------
--				if @Esic_no = ''
--					Set @Esic_no = NULL
				
--				if @Pf_No = ''
--					Set @Pf_No = NULL
					
--				if @Pan_No = ''
--					Set @Pan_No = NULL

				
--				if @Esic_no Is Not Null or @Pf_No Is Not Null or @Pan_No Is Not Null or @Inc_Bank_Ac_No is not null  -- Added by Hardik 26/06/2020 for Bug id 9023, @Inc_Bank_AC_No
--					BEGIN
--							IF Object_ID('tempdb..#COLUMN_VALUE') is null
--								BEGIN		
--										CREATE TABLE #COLUMN_VALUE
--										(      
--											COLUMN_NAME  Varchar(50),
--											COLUMN_VALUE Varchar(50)							
--										)							
--								END	

--					END
				
--				if @Esic_no Is Not Null
--					BEGIN
--						 INSERT INTO #COLUMN_VALUE(COLUMN_NAME,Column_Value)
--						 EXEC P_EMP_UAN_PAN_VALIDATION @Cmp_ID,@Emp_ID,@Emp_First_Name,@Emp_Last_Name,@Date_OF_Birth,'','ESIC',@Esic_no
						 
						 
						 
--						 IF EXISTS(SELECT 1 FROM #COLUMN_VALUE)
--							BEGIN
--								  INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'ESIC No is alredy Exist',@Emp_Code,'Enter Proper ESIC No',GETDATE(),'Employee Master','')     
--								  SET @HasResult = cast(@Emp_Code as varchar(100)) + ',' 
								  
--								  DELETE FROM #COLUMN_VALUE
--							END
							
						 
--					END
--				if @Pf_No Is Not Null
--					BEGIN					
						
--						 INSERT INTO #COLUMN_VALUE(COLUMN_NAME,Column_Value)
--						 EXEC P_EMP_UAN_PAN_VALIDATION @Cmp_ID,@Emp_ID,@Emp_First_Name,@Emp_Last_Name,@Date_OF_Birth,'','PF',@Pf_No
						 
--						 IF EXISTS(SELECT 1 FROM #COLUMN_VALUE)
--							BEGIN
--								  INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'PF No is alredy Exist',@Emp_Code,'Enter Proper PF No',GETDATE(),'Employee Master','')     
--								  SET @HasResult = cast(@Emp_Code as varchar(100)) + ',' 
								  
--								  DELETE FROM #COLUMN_VALUE
								  
--							END
							
						
--					END

--				if @Pan_No Is Not Null
--					BEGIN
		 						 
--						 INSERT INTO #COLUMN_VALUE(COLUMN_NAME,Column_Value)
--						 EXEC P_EMP_UAN_PAN_VALIDATION @Cmp_ID,@Emp_ID,@Emp_First_Name,@Emp_Last_Name,@Date_OF_Birth,'','PAN',@Pan_No
	 
--						 IF EXISTS(SELECT 1 FROM #COLUMN_VALUE)
--							BEGIN
--								  INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'PAN No is alredy Exist',@Emp_Code,'Enter Proper PAN No',GETDATE(),'Employee Master','')     
--								  SET @HasResult = cast(@Emp_Code as varchar(100)) + ',' 
								  
--								 DELETE FROM #COLUMN_VALUE 
								  
--							END
--					END
--				-----------ended-----------------
				
--				--added by Krushna 12032020
--				if @Inc_Bank_Ac_No is not NULL
--					BEGIN
					
--						 INSERT INTO #COLUMN_VALUE(COLUMN_NAME,Column_Value)
--						 EXEC P_EMP_UAN_PAN_VALIDATION @Cmp_ID,@Emp_ID,@Emp_First_Name,@Emp_Last_Name,@Date_OF_Birth,'','BANK_ACCOUNT',@Inc_Bank_Ac_No
						 
--						 IF EXISTS(SELECT 1 FROM #COLUMN_VALUE)
--							BEGIN
--								INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Bank Account No is alredy Exist',@Emp_Code,'Enter Proper Bank Account',GETDATE(),'Employee Master','')
--								SET @HasResult = cast(@Emp_Code as varchar(100)) + ',' 
--								DELETE FROM #COLUMN_VALUE 
--							END
--					END
--				--End Krushna
				
--				 --ADDED BY MUKTI(09072020)START
				 
--				DECLARE @AGE NUMERIC				
--				DECLARE @MaxAgeLimit INT
--				SET @AGE = dbo.F_GET_AGE (@Date_Of_Birth,GETDATE(),'N','N')
--				SELECT @MaxAgeLimit = Setting_Value from T0040_SETTING WITH (NOLOCK) where cmp_id = @Cmp_ID and Setting_Name='Maximum Age Limit for Employee Joining'
				
--				IF @AGE >@MaxAgeLimit
--				BEGIN				
--					SET @ErrString='Employee Age is more than ' + ' ' +  cast(@MaxAgeLimit as varchar(15))  + ' ' + ' years'	
--					INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,@ErrString,0,@ErrString,GETDATE(),'Employee Master','') 
--					SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
--					Goto ABC;
--				END
--			--ADDED BY MUKTI(09072020)END
				
--				IF @Increment_ID = 0   
--				  SET @Increment_ID= NULL
				 
--				IF @Increment_ID <> 0   
--				  SET @Increment_ID= NULL
				   
--				Declare @Is_GroupOFCmp Numeric	--Hardik 12/11/2020 for Trident to check Duplicate Emp Code
--				DECLARE @Is_Alpha_Numeric_Branchwise TINYINT --Hardik 12/11/2020 for Trident to check Duplicate Emp Code
--				DECLARE @Max_Emp_Code Varchar(64)
--				Set @Is_GroupOFCmp = 0
--				Set @Is_Alpha_Numeric_Branchwise = 0

				
--				SELECT @Domain_Name = Domain_Name,@Cmp_Code = Cmp_Code,@Is_Auto_Alpha_Numeric_Code = Is_Auto_Alpha_Numeric_Code,
--					@No_Of_Digits = No_Of_Digit_Emp_Code,@Is_GroupOFCmp = ISNULL(Is_GroupOFCmp,0), 
--					@Is_Alpha_Numeric_Branchwise = isnull(Is_Alpha_Numeric_Branchwise,0),@Max_Emp_Code = Max_Emp_Code  
--				FROM dbo.T0010_COMPANY_MASTER WITH (NOLOCK) WHERE CMP_ID = @CMP_ID  
			    
--				IF SUBSTRING(@Domain_Name,1,1) <> '@'   
--					SET @Domain_Name = '@' + @Domain_Name  
			   
--				DECLARE @len AS NUMERIC(18,0)
--				SET @len = LEN(CAST (@emp_code AS VARCHAR(20)))  
				
--				IF @len > @No_Of_Digits  
--					SET @len = @No_Of_Digits  
			   
--				SELECT @Branch_Code = Branch_Code FROM T0030_BRANCH_MASTER WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND Branch_ID = @Branch_ID   
--				declare @Get_Emp_code  as varchar(40)		
--				declare @Get_Alpha_code  as varchar(10)
			   
--				set @Get_Emp_code = ''	
--				set @Get_Alpha_code = ''
				
--				insert into #Emp_Code_Detail
--				exec Get_Employee_Code @cmp_ID,@Branch_ID,@Date_Of_Join,@Get_Emp_Code output,@Get_Alpha_Code output,1 ,@Desig_Id,@Cat_ID,@Type_ID,@Date_OF_Birth

--				if @Alpha_Code is NULL
--				begin
--					set @Alpha_Code = @Get_Alpha_Code
--				end
				
--				if @Is_Auto_Alpha_Numeric_Code = 1
--					begin
--						if @Emp_code <> 0 and @Alpha_Code <> ''
--							begin
--								set @Alpha_Emp_Code = @Alpha_Code +  REPLICATE ('0',@No_Of_Digits - @len) + Cast(@Emp_code as Varchar(20))
--							end	
--						else
--							begin
--								set @Alpha_Emp_Code =   REPLICATE ('0',@No_Of_Digits - @len) + Cast(@Emp_code as Varchar(20)) 
--							end
--					end
--				 else
--					begin
--						set @Alpha_Emp_Code =  REPLICATE ('0',@No_Of_Digits - @len) + Cast(@Emp_code as Varchar(20)) 
--					end
					
--			   --Set @Emp_Full_Name = @Initial  + RTRIM(' ' + LTRIM(@Emp_First_Name)) + RTRIM(' ' + LTRIM(@Emp_Second_Name)) + RTRIM(' ' + LTRIM(@Emp_Last_Name)) 
--			   --ADDED BY RAMIZ ON 21/01/2019
--				If @Add_Initial_In_Emp_Full_Name = 1
--					BEGIN 
--						SET @Emp_Full_Name = @Initial  + RTRIM(' ' + LTRIM(@Emp_First_Name)) + RTRIM(' ' + LTRIM(@Emp_Second_Name)) + RTRIM(' ' + LTRIM(@Emp_Last_Name)) 
--					END
--				ELSE
--					BEGIN 
--						SET @Emp_Full_Name = RTRIM(LTRIM(@Emp_First_Name)) + RTRIM(' ' + LTRIM(@Emp_Second_Name)) + RTRIM(' ' + LTRIM(@Emp_Last_Name)) 
--					END 
			   
--			   --Added by Nilesh Patel on 29032019 -- For Kataria Client 
--			   Declare @Employee_Strength_Setting tinyint
--			   select @Employee_Strength_Setting = setting_value from T0040_SETTING WITH (NOLOCK) where cmp_id = @Cmp_ID and setting_name = 'Restrict Entry based on Employee Strength Master'
			   
--			   IF @Employee_Strength_Setting = 1
--				 Begin
--					IF @Branch_ID > 0 AND @Desig_Id > 0
--					Begin
--						Declare @Branch_Desig_Wise_Count Numeric(18,0)
--						Set @Branch_Desig_Wise_Count = 0

--						Declare @Branch_Desig_Strength_Count Numeric(18,0)
--						Set @Branch_Desig_Strength_Count = 0

--						Select 
--							@Branch_Desig_Wise_Count = Count(1)
--						FROM
--							(SELECT	
--								I1.EMP_ID, I1.DESIG_ID, I1.BRANCH_ID
--							FROM	T0095_INCREMENT I1 WITH (NOLOCK)
--							INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON E.EMP_ID = I1.EMP_ID AND (E.Emp_Left_Date IS NULL OR ISNULL(Emp_Left,'N') = 'N')
--							INNER JOIN (
--										SELECT	
--											MAX(I2.Increment_ID) AS Increment_ID, I2.Emp_ID
--										FROM	T0095_INCREMENT I2 WITH (NOLOCK)
--										INNER JOIN (
--														SELECT	
--															MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
--														FROM	T0095_INCREMENT I3 WITH (NOLOCK)
--														WHERE	I3.Increment_Effective_Date <= Getdate() AND Cmp_ID = @Cmp_ID
--														GROUP BY I3.Emp_ID
--													) I3 ON I2.Increment_Effective_Date=I3.INCREMENT_EFFECTIVE_DATE AND I2.Emp_ID=I3.Emp_ID																		
--										WHERE	I2.Cmp_ID = @Cmp_Id 
--										GROUP BY I2.Emp_ID
--									) I2 ON I1.Emp_ID=I2.Emp_ID AND I1.Increment_ID=I2.INCREMENT_ID	
--							WHERE	I1.Cmp_ID=@Cmp_Id	
--							AND NOT EXISTS(SELECT 1 FROM T0200_EMP_EXITAPPLICATION EE WITH (NOLOCK) WHERE EE.EMP_ID = I1.EMP_ID AND EE.status NOT IN('R','LR'))									
--							) I
--						WHERE I.Branch_ID = @Branch_ID AND I.Desig_Id = @Desig_Id 

--						Select @Branch_Desig_Strength_Count = ESM.Strength
--							From T0040_Employee_Strength_Master ESM WITH (NOLOCK)
--							INNER JOIN(
--										Select Max(Effective_Date) as For_Date,Branch_ID,Desig_Id 
--											From T0040_Employee_Strength_Master  WITH (NOLOCK)
--										Where Branch_Id <> 0 and Desig_Id <> 0
--										Group By Branch_ID,Desig_Id 
--							) as Qry 
--						ON ESM.Effective_Date = Qry.For_Date AND ESM.Branch_Id = Qry.Branch_Id AND ESM.Desig_Id = Qry.Desig_Id
--						Where ESM.Branch_Id = @Branch_ID AND ESM.Desig_Id = @Desig_Id

--						if @Branch_Desig_Wise_Count >= @Branch_Desig_Strength_Count
--							Begin
--								set @Emp_ID = 0
--								INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Employee count is greater than set employee strength count in strength Master',0,'Check Employee Count Details in Employee Strength',GETDATE(),'Employee Master','')    
--								SET @HasResult = cast(@Emp_Code as varchar(100)) + ',' 
--							End
--					End
--				End 
--			--Added by Nilesh Patel on 29032019 -- For Kataria Client

--			   if @Alpha_Code = '' --Added by nilesh patel on 30072015
--				Begin
--					Set @Alpha_Code = NULL
--				End 

--			  DECLARE @validateEmail as int
--			  IF (@Work_Email<>'') --Mukti(10112020)check for duplicate Official Email ID
--				BEGIN
--					IF EXISTS(SELECT 1 FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Work_Email =@Work_Email AND Alpha_Emp_Code <> @Alpha_Emp_Code AND Cmp_ID=@Cmp_ID)  
--					BEGIN  
--						INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Official Email ID already exist',0,'Official Email ID already exist',GETDATE(),'Employee Master','')  
--						SET @HasResult = cast(@Emp_Code as varchar(100)) + ',' 
--						SET @Log_Status=1   
--						RETURN  
--					END  

					
--					SELECT  @validateEmail= dbo.ValidEmail(@Work_Email)
--					IF (@validateEmail = 0)  --Mukti(10112020)check for proper Work Email ID
--					BEGIN				
--						INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Enter proper Work Email ID',0,'Enter proper Work Email ID',GETDATE(),'Employee Master','')  
--						SET @HasResult = cast(@Emp_Code as varchar(100)) + ',' 
--						SET @Log_Status=1   
--						RETURN 
--					END
--				END
				
--				IF (@Other_Email<>'') --Mukti(10112020)check for proper Work Other ID
--				BEGIN						
--						SELECT  @validateEmail= dbo.ValidEmail(@Other_Email)
--						IF (@validateEmail = 0) 
--						BEGIN				
--							INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Enter proper Other Email ID',0,'Enter proper Other Email ID',GETDATE(),'Employee Master','')  
--							SET @HasResult = cast(@Emp_Code as varchar(100)) + ',' 
--							SET @Log_Status=1   
--							RETURN 
--						END
--				END

--				DECLARE @EXISTING_DETAIL VARCHAR(256)
--				SET @EXISTING_DETAIL = NULL

--			    IF EXISTS(SELECT Emp_ID FROM dbo.T0080_EMP_MASTER WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND Alpha_Emp_Code = @Alpha_Emp_Code) AND @Is_GroupOFCmp = 0
--					BEGIN
--							print 'same emp code' 
--							INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Same Employess code already available in system',0,'Enter Employee Code Proper',GETDATE(),'Employee Master','')
--							SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
--							--Set @Status_Details = @Status_Details + cast(@Emp_Code as varchar(100)) + ','
--					END
--				ELSE IF Exists(select Emp_ID From dbo.T0080_EMP_MASTER WITH (NOLOCK) WHERE Alpha_Emp_Code = @Alpha_Emp_Code And Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1))
--							AND @Max_Emp_Code = 'Group_Company_Wise' AND @Is_GroupOFCmp = 1
--							BEGIN			
--								SELECT	@EXISTING_DETAIL = Cmp_Name 
--								FROM	T0080_EMP_MASTER E WITH (NOLOCK)
--										INNER JOIN T0010_COMPANY_MASTER C WITH (NOLOCK) ON e.Cmp_ID=c.Cmp_Id 
--								WHERE	Alpha_Emp_Code = @Alpha_Emp_Code AND C.is_GroupOFCmp=1
--								SET @EXISTING_DETAIL = 'Employee Code already exist in "' + @EXISTING_DETAIL + '" Company.'

--								IF (@EXISTING_DETAIL IS NOT NULL)
--									BEGIN
--										INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Alpha_Emp_Code,@EXISTING_DETAIL,0,'Enter Employee Code Proper',GETDATE(),'Employee Master','')
--										SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
--									END						

--							END
--				ELSE If Exists(select Emp_ID From dbo.T0080_EMP_MASTER WITH (NOLOCK) WHERE (Alpha_Emp_Code = @Alpha_Emp_Code) And Cmp_ID = @Cmp_ID)
--							AND @Max_Emp_Code = 'Company_Wise'  And @Is_Alpha_Numeric_Branchwise = 0 AND @Is_GroupOFCmp = 1
--							begin																	
--								SET @EXISTING_DETAIL = 'Employee Code already exist in Current Company.'

--								IF (@EXISTING_DETAIL IS NOT NULL)
--									BEGIN
--										INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Alpha_Emp_Code,@EXISTING_DETAIL,0,'Enter Employee Code Proper',GETDATE(),'Employee Master','')
--										SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
--									END						

--							END
--				ELSE If Exists(select Emp_ID From dbo.T0080_EMP_MASTER WITH (NOLOCK) WHERE (Alpha_Emp_Code = @Alpha_Emp_Code) And Cmp_ID = @Cmp_ID And Branch_ID = @Branch_Id)
--							AND @Max_Emp_Code = 'Company_Wise' And @Is_Alpha_Numeric_Branchwise = 1 AND @Is_GroupOFCmp = 1
--							begin																	
--								SET @EXISTING_DETAIL = 'Employee Code already exist in Current Company.'
--								IF (@EXISTING_DETAIL IS NOT NULL)
--									BEGIN
--										INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Alpha_Emp_Code,@EXISTING_DETAIL,0,'Enter Employee Code Proper',GETDATE(),'Employee Master','')
--										SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
--									END						
--							END
--				ELSE
--					BEGIN  
--						DECLARE @Count AS NUMERIC(18,0) 
--						DECLARE @Emp_LCount NUMERIC  
						
--						SELECT @Count =COUNT(Emp_ID) FROM dbo.T0080_EMP_MASTER WITH (NOLOCK) WHERE  Emp_Left <> 'y'        
--						SELECT @Emp_LCount = dbo.decrypt(Emp_License_Count) FROM dbo.Emp_Lcount  
			     
--						IF @Count > @Emp_LCount  
--							BEGIN  
--								SET @Emp_ID = 0  
								
--								INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Employee Limit Exceed Contact Administrator: Total Employee =' ,CAST(@Count AS VARCHAR(18)),'Please Contact with Administration',GETDATE(),'Employee Master','')  
--								SET @HasResult = '90'
--								Goto A;
--							END
						
--						SELECT @Emp_ID = ISNULL(MAX(Emp_ID),0) + 1  FROM dbo.T0080_EMP_MASTER WITH (NOLOCK)
--						SELECT @Adult_No = ISNULL(MAX(Worker_Adult_No),0) + 1 FROM dbo.T0080_EMP_MASTER WITH (NOLOCK) WHERE Cmp_ID=@Cmp_ID     
			     
						
--						IF EXISTS (SELECT Module_Id FROM T0011_module_detail WITH (NOLOCK) WHERE Cmp_Id=@Cmp_ID AND chg_pwd=1)  
--							BEGIN  
--								SET @Chg_Pwd=1  
--							END  
						
--						IF @HasResult <> ''
--							GOTO ABC;
--							-- added by rohit on 07072016
							
--						Declare @IS_EARLY_limit as varchar(15)
--						Declare @IS_EARLY_mark as numeric
--						set @IS_EARLY_limit  = '00:00'
--						set @IS_EARLY_mark = 0
						
--							if exists(select gen_id from T0040_GENERAL_SETTING WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Branch_ID=@Branch_ID and For_Date = (select max(for_date) From T0040_General_Setting WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Branch_ID =@branch_id))
--							begin
									
--									select @IS_EARLY_limit  = isnull(Early_Limit,'00:00') from T0040_GENERAL_SETTING WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Branch_ID=@Branch_ID and For_Date = (select max(for_date) From T0040_General_Setting WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Branch_ID =@branch_id)
--							if (isnull(@IS_EARLY_limit,'00:00') <> '00:00' and isnull(@IS_EARLY_limit,'00:00') <> '' )
--							begin
--								set @IS_EARLY_mark = 1
--							end
							
--							end
--							-- ended by rohit on 07072016	

--							--- Added Minimum Basic Condition by Hardik 16/08/2018 for Corona
--							Declare @Min_Basic_Applicable tinyint
--							Declare @Min_Basic Numeric(18,5)

--							Set @Min_Basic_Applicable = 0
--							Set @Min_Basic = 0

--							Select @Min_Basic_Applicable = Setting_Value  from T0040_SETTING WITH (NOLOCK) where Cmp_ID=@Cmp_ID  and Setting_Name = 'Min. basic rules applicable'
--							Select @Min_Basic = Isnull(min_basic,0)  from T0040_GRADE_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID And Grd_Id = @Grd_Id

--							IF @Basic_Salary = 0
--								AND EXISTS(select 1 from T0040_GRADE_MASTER WITH (NOLOCK) where Grd_ID=@Grd_ID AND Basic_Percentage > 0)
--								BEGIN
--									SELECT	@Basic_Salary = Basic_Percentage * CASE WHEN Basic_Calc_On = 'CTC' THEN @CTC else @Gross_salary end / 100
--									FROM	T0040_GRADE_MASTER WITH (NOLOCK) where Grd_ID=@Grd_ID 
								
--									If @Min_Basic_Applicable = 1 And @Min_Basic > 0 And @Basic_Salary < @Min_Basic --- Added by Hardik 16/08/2018
--										Set @Basic_Salary = @Min_Basic
--								END
--							ELSE IF @Basic_Salary = 0 And @Min_Basic_Applicable = 1 And @Min_Basic > 0 --- Added by Hardik 16/08/2018
--								BEGIN
--									Set @Basic_Salary = @Min_Basic
--								END	
												
--							--- Ended Minimum Basic Condition by Hardik 16/08/2018 for Corona

--							--if Object_ID('tempdb..#DynamicValidation') Is not null
--							--	Begin
--							--		Drop Table #DynamicValidation
--							--	End

--							--Create Table #DynamicValidation
--							--(
--							--	Alpha_Emp_Code Varchar(100),
--							--	Validation_Msg Varchar(500)
--							--)
							
--							-- Below Code is Created by Darshan on 19/01/2021 for Auto Active Mobile User during Employee Creation
							
--							DECLARE @lSettingValueForAutoActiveMobileUser INT,@lLicenceCount INT,@lActiveEmpCount INT
--							SELECT @lSettingValueForAutoActiveMobileUser = ISNULL(Setting_Value,0)
--							FROM T0040_SETTING WITH (NOLOCK) WHERE cmp_id = @Cmp_ID and setting_name = 'Auto Active Mobile User during Employee Creation'

--							IF @lSettingValueForAutoActiveMobileUser = 1
--								BEGIN
--									SELECT @lLicenceCount = dbo.Decrypt(Emp_License_Count_Mobile) FROM Emp_Lcount
--									SELECT @lActiveEmpCount = COUNT(1) FROM Active_InActive_Users_Mobile WHERE Cmp_ID = @Cmp_ID and is_for_mobile_Access = 1

--									IF @lActiveEmpCount >= @lLicenceCount
--										BEGIN
--											SET @Emp_ID = 0

--											INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Mobile Activation Failed due to Mobile License Limit has been exceed: For Employee = ' + CONVERT(VARCHAR,@Alpha_Emp_Code),@Emp_Code,'Please Contact with Administrator',GETDATE(),'Employee Master','')  
--											SET @HasResult = '90'
--											SET @Log_Status=1
--											Goto A;
--										END									
--								END

--							-- Code end for Auto Active Mobile User during Employee Creation
--						Declare @Image_Name as varchar(50) = ''
--                        If Upper(@Initial)= 'MS.' or Upper(@Initial) = 'MRS.'
--                                Set @Image_Name= 'Emp_Default_Female.png'
--                        ELSE
--                                Set @Image_Name = 'Emp_Default.png'


--							INSERT INTO dbo.T0080_EMP_MASTER  
--									(Emp_ID, Cmp_ID, Branch_ID, Cat_ID, Grd_ID, Dept_ID, Desig_Id, TYPE_ID, Shift_ID, Bank_ID, Emp_code,Initial, Emp_First_Name, Emp_Second_Name,   
--									Emp_Last_Name, Curr_ID, Date_Of_Join, SSN_No, SIN_No, Dr_Lic_No, Pan_No, Date_Of_Birth, Marital_Status, Gender, Dr_Lic_Ex_Date, Nationality,   
--									Loc_ID, Street_1, City, STATE, Zip_code, Home_Tel_no, Mobile_No, Work_Tel_No, Work_Email, Other_Email, Basic_Salary, Image_Name,Emp_Full_Name,  
--									Emp_Left,Present_Street,Present_City,Present_State,Present_Post_Box ,Blood_Group,Enroll_No,Tally_Led_Name,Religion,Height,Emp_Mark_Of_Identification  
--									,Despencery,Doctor_Name,DespenceryAddress,Insurance_No,Is_Gr_App,Is_Yearly_Bonus,Yearly_Leave_days,Yearly_Leave_Amount,Yearly_bonus_Per,Yearly_bonus_Amount,  
--									Worker_Adult_No,Father_name,Ifsc_Code,Emp_Confirm_Date,IS_ON_Probation,Old_Ref_No,Chg_Pwd,Alpha_Code,Alpha_Emp_Code,Emp_Superior,Is_LWF
--									,Segment_ID,Vertical_ID,SubVertical_ID,subBranch_ID,GroupJoiningDate,Date_of_Retirement
--									,EmpName_Alias_PrimaryBank,EmpName_Alias_SecondaryBank,EmpName_Alias_PF,EmpName_Alias_PT,EmpName_Alias_Tax,EmpName_Alias_ESIC,EmpName_Alias_Salary
--									,Emp_Shirt_Size,Emp_Pent_Size,Emp_Shoe_Size,Emp_Canteen_Code,Login_ID,System_Date)  
--								VALUES (@Emp_ID,@Cmp_ID,@Branch_ID,@Cat_ID,@Grd_ID,@Dept_ID,@Desig_Id,@Type_ID,@Shift_ID,@Bank_ID,@Emp_code,@Initial,@Emp_First_Name,@Emp_Second_Name,  
--									@Emp_Last_Name,@Curr_ID,@Date_Of_Join,@PF_No,@ESIC_No,'',@Pan_No,@Date_Of_Birth,@Marital_Status,@Gender,NULL,@Nationality,  
--									@Loc_ID,@Street_1,@City,@State,@Zip_code,@Home_Tel_no,@Mobile_No,@Work_Tel_No,@Work_Email,@Other_Email,@Basic_Salary,@Image_Name,@Emp_Full_Name,  
--									'N',@Present_Street,@Present_City,@Present_State,@Present_Post_Box,@Blood_Group,@Enroll_No,NULL,NULL,NULL,NULL,  
--									NULL,NULL,NULL,NULL,0,0.0,0.0,0.0,0.0,0.0,@Adult_No,@Father_Name,@Emp_IFSC_No,@Confirm_Date,@Probation,@Old_Ref_No,@Chg_Pwd,@Alpha_Code,@Alpha_Emp_Code,@emp_Id_sup,@Is_LWF
--									,@Segment_ID,@Vertical_ID,@SubVertical_ID,@SubBranch_ID,@Group_of_Joining,@Date_Of_Retirement
--									,@Emp_Full_Name,@Emp_Full_Name,@Emp_Full_Name,@Emp_Full_Name,@Emp_Full_Name,@Emp_Full_Name,@Emp_Full_Name
--									,0,0,0,0,@User_Id,Getdate()) 
							
--							-- Below Code is Created by Darshan on 19/01/2021 for Auto Active Mobile User during Employee Creation

--							IF @lSettingValueForAutoActiveMobileUser = 1
--								BEGIN
--									UPDATE T0080_EMP_MASTER SET is_for_mobile_Access = 1 
--									WHERE Emp_ID = @Emp_ID AND Cmp_ID = @Cmp_ID
--								END

--							-- Code end for Auto Active Mobile User during Employee Creation

--							SELECT @Default_Weekof = Default_Holiday, @Alt_W_Name =  Alt_W_Name ,@Alt_W_Full_Day_Cont = Alt_W_Full_Day_Cont  FROM dbo.T0010_COMPANY_MASTER WITH (NOLOCK) WHERE Cmp_Id = @Cmp_ID  
						
--							--If Exists(Select 1 From #DynamicValidation)
--							--	Begin
--							--	    Declare @Dynamic_Msg as varchar(500)
--							--		Select @Dynamic_Msg = Validation_Msg From #DynamicValidation
--							--		INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,@Dynamic_Msg,0,'Dynamic Mandatory Fields',GETDATE(),'Employee Master','')    
--							--		SET @HasResult = cast(@Emp_Code as varchar(100)) + ','
--							--		SET @Log_Status=1
--							--		RETURN
--							--	End
						
--							IF @Alpha_Emp_Code IS NOT NULL  
--								BEGIN  
--									SET @loginname = CAST(@Alpha_Emp_Code AS VARCHAR(50)) + @Domain_Name  
--								END  
--							ELSE  
--								BEGIN  
--									SET @loginname = CAST(@Emp_Code AS VARCHAR(10)) + @Domain_Name  
--								END   
			   
						
--							-------Select * From T0080_EMP_MASTER Where Emp_ID = @Emp_ID
						
--							IF NOT EXISTS(SELECT Row_ID FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) WHERE Cmp_ID=@Cmp_ID AND Emp_ID=@Emp_ID)  
--								BEGIN  
--									IF @emp_Id_sup IS NOT NULL And @emp_Id_sup > 0
--										BEGIN  
--											EXEC P0090_EMP_REPORTING_DETAIL 0,@Emp_ID,@Cmp_ID,'Supervisor',@emp_Id_sup,'Direct','i' ,0,0, '',@Date_OF_Join  
--										END  
--								END
						
--							--EXEC p0011_Login @Login_ID OUTPUT,@Cmp_Id,@loginname,'VuMs/PGYS74=',@Emp_ID,NULL,NULL,'I',2
--							EXEC p0011_Login @Login_ID OUTPUT,@Cmp_Id,@loginname,@EssPassword,@Emp_ID,NULL,NULL,'I',2
--							EXEC P0110_EMP_LEFT_JOIN_TRAN @EMP_ID,@CMP_ID,@Date_Of_Join,'','',0  
--							EXEC P0100_EMP_SHIFT_INSERT @emp_ID,@cmp_ID,@Shift_ID,@Date_of_Join,NULL 
--							Declare @i Numeric(1,0)
						
--							IF Exists(Select 1 From T0040_GRADE_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Grd_ID = @Grd_ID and Isnull(Grd_WAGES_TYPE,'') <> '')
--								Begin
--									Select @Wages_Type = Grd_WAGES_TYPE From T0040_GRADE_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Grd_ID = @Grd_ID
--								End
--							EXEC P0095_INCREMENT_INSERT @Increment_ID OUTPUT ,@Emp_ID,@Cmp_ID,@Branch_ID,@Cat_ID,@Grd_ID,@Dept_ID,@Desig_Id,@Type_ID,@Bank_ID
--								,@Curr_ID,@Wages_Type,@Salary_Basis_On,@Basic_Salary,@Gross_salary,'Joining',@Date_OF_Join,@Date_OF_Join,@Payment_Mode
--								,@Inc_Bank_AC_No,@Emp_OT,@Emp_OT_Min_Limit,@Emp_OT_Max_Limit,0,0,0,0,'',@Emp_LATE_MARK,@Emp_Full_PF,@Emp_PT,@Emp_Fix_Salary,0,'',0,1,@Login_ID,0
--								,NULL,@emp_Id_sup,1,0,@CTC,0,0,0,0,0,0,@IS_EARLY_mark,'','00:00',0,'','',0,@WeekDay_OT_Rate,@Weekoff_OT_Rate,@Holiday_OT_Rate,0,0,0,0,0,0,0
--								,@Salary_Cycle_ID
--								,@Cmp_Full_PF
--								,@Segment_ID ,@Vertical_ID,@SubVertical_ID,@SubBranch_ID,0,0,0,0,'','','','',0,'',@User_Id,@IP_Address,@Customer_Audit  --Change By Jaina 09-09-2016
							
						
--							EXEC P0100_EMP_GRADEWISE_ALLOWANCE @Cmp_ID,@Emp_ID,@Grd_ID,@Date_Of_Join,@Increment_ID  
--							--added By Mukti(start)27032017						
--							if @Gross_salary=0
--							BEGIN
--								declare @E_AD_AMOUNT as numeric(18,2)
--								set @E_AD_AMOUNT=0
--								select @E_AD_AMOUNT=isnull(sum(E_AD_AMOUNT),0) from V0100_EMP_EARN_DEDUCTION where EMP_ID=@Emp_ID and CMP_ID=@Cmp_ID
--								and AD_NOT_EFFECT_SALARY=0 and E_AD_FLAG='I'
							
--								set @Gross_salary= @Basic_Salary + @E_AD_AMOUNT
--								update T0095_INCREMENT SET Gross_Salary=@Gross_salary where EMP_ID=@Emp_ID and CMP_ID=@Cmp_ID
--							END
--							--added By Mukti(end)27032017
--							--update by chetan 070717
						
--							IF (ISNULL(@Default_Weekof,'') <> '')  or (ISNULL(@Alt_W_Name,'') <> '')
--								EXEC P0100_WEEKOFF_ADJ 0,@Cmp_ID,@Emp_ID,@Date_Of_Join,@Default_Weekof,'',@Alt_W_Name,@Alt_W_Full_Day_Cont,'',0,'I'  
			   
--							UPDATE dbo.T0080_EMP_MASTER SET Increment_ID = @Increment_ID  WHERE Emp_ID = @Emp_ID  
						
--							if @Pay_Scale_ID <> 0 
--								Begin
--									EXEC P0050_EMP_PAY_SCALE_DETAIL @Cmp_ID,0,@Emp_ID,@Pay_Scale_ID,@Date_Of_Join,1
--								End 
							
--							--Added by Mukti(02082017)start
--							select @Auto_LeaveCredit_Setting=isnull(Setting_Value,0) 
--							from T0040_SETTING WITH (NOLOCK)
--							--where Cmp_ID=@CMP_ID and Setting_Name='Auto Leave Credit Days while Import Employee Master' 
--							where Cmp_ID=@CMP_ID and Setting_Name='Advance Leave balance assign from Import Employee' 
						
											
--							if @Auto_LeaveCredit_Setting = 1
--								EXEC SP_Get_Advance_Leave_Details @Cmp_ID=@Cmp_ID,@Type_ID=	@Type_ID,@Join_Date=@Date_OF_Join,@Branch_ID=@Branch_ID,@flag='Import',@Emp_ID=@Emp_ID,@Grade_ID = @Grd_ID
--							--Added by Mukti(02082017)end
						
						
--							if @Increment_ID <> 0 
--								Begin
--									Declare @NewValue Varchar(Max)
--									Set @NewValue = ''
--									Set @NewValue = 'New Value'
--										  + '#Emp_Code ' + ' : ' +  isnull(Cast(@Emp_code AS varchar(20)),'')
--										  + '#Emp_int_Name    ' + ' : ' +  isnull(Cast(@Initial AS varchar(10)),'')
--										  + '#Emp_First_Name  ' + ' : ' +  isnull(@Emp_First_Name,'')
--										  + '#Emp_Second_Name ' + ' : ' +  isnull(@Emp_Second_Name,'') 
--										  + '#Emp_Last_Name   ' + ' : ' + isnull(@Emp_Last_Name,'')
--										  + '#Branch		' + ' : ' + isnull(@Branch_Name,'') 
--										  + '#Garde			' + ' : ' + isnull(@Grd_Name,'') 
--										  +	'#Dept			' + ' : ' + isnull(@Dept_Name,'') 
--										  + '#Category		' + ' : ' + isnull(@Product_name,'')
--										  + '#Designation   ' + ' : ' + isnull(@desig_Name,'') 
--										  + '#Type			' + ' : ' + isnull(@Type_Name,'')
--										  + '#Shift         ' + ' : ' + isnull(@Shift_Name,'') 
--										  + '#Bank_name     ' + ' : ' + isnull(@Bank_Name,'')
--										  + '#Curr_name     ' + ' : ' + isnull(@Curr_Name,'')
--										  + '#DOJ  ' + ' : ' + isnull(Replace(Convert(varchar(11),@Date_Of_Join,106),' ','-'),'')
--										  + '#Pan_No    ' + ' : ' + isnull(@Pan_No,'') 
--										  + '#EsicNo	' + ' : ' + isnull(@ESIC_No,'')
--										  + '#PFno      ' + ' : ' + isnull(@PF_No,'') 
--										  + '#BOD       ' + ' : ' + isnull(Replace(Convert(varchar(11),@Date_Of_Birth,106),' ','-'),'') 
--										  + '#Marital_status' + ' : ' + isnull(Cast(@Marital_Status AS varchar(2)),'')  
--										  + '#Gender    ' + ' : ' +   isnull(@Gender,'') 
--										  + '#Nationality' + ' : ' +  isnull(@Nationality,'')  
--										  + '#Location   ' + ' : ' +  isnull(@Loc_Name,'') 
--										  + '#Address	 ' + ' : ' +  isnull(@Street_1,'')  
--										  + '#City       ' + ' : ' +  isnull(@City,'') 
--										  + '#State      ' + ' : ' +  isnull(@State,'') 
--										  + '#PostBox    ' + ' : ' +  isnull(Cast(@Zip_code AS varchar(10)),'') 
--										  + '#Tel_No	 ' + ' : ' +  isnull(Cast(@Home_Tel_no AS varchar(10)),'')  
--										  + '#Mobile     ' + ' : ' +  isnull(Cast(@Mobile_No AS varchar(10)),'') 
--										  + '#Work_Tel_No' + ' : ' +  isnull(Cast(@Work_Tel_No AS varchar(10)),'') 
--										  + '#Work_Email ' + ' : ' +  isnull(@Work_Email,'') 
--										  + '#Other_Email' + ' : ' +  isnull(@Other_Email,'') 
--										  + '#Present_ADDRESS' + ' : ' + isnull(@Present_Street,'') 
--										  + '#Present_City   ' + ' : ' + isnull(@Present_City,'') 
--										  + '#Present_State  ' + ' : ' + isnull(@Present_State,'')
--										  + '#Present_Postbox' + ' : ' + isnull(Cast(@Present_Post_Box AS varchar(10)),'')
--										  + '#Salary         ' + ' : ' + isnull(Cast(@Basic_Salary AS varchar(10)),'')
--										  + '#GROSS			 ' + ' : ' + isnull(Cast(@GROSS_SALARY  AS varchar(10)),'')
--										  + '#WAGES          ' + ' : ' + isnull(@WAGES_TYPE,'')
--										  +	'#SALARY_BASIC_ON' + ' : ' + isnull(@SALARY_BASIS_ON,'')
--										  + '#PAYMENT_MODE   ' + ' : ' + isnull(@PAYMENT_MODE,'')
--										  + '#BANK_ACC_NO    ' + ' : ' + isnull(Cast(@INC_BANK_AC_NO AS varchar(10)),'')
--										  + '#EMP_OT         ' + ' : ' + isnull(Cast(@EMP_OT AS varchar(10)),'')
--										  + '#Min_Limit      ' + ' : ' + isnull(Cast(@Emp_OT_Min_Limit as varchar(5)),'') 
--										  + '#Max_Limit      ' + ' : ' + isnull(Cast(@Emp_OT_Max_Limit as varchar(5)),'') 
--										  + '#Late_Mark		 ' + ' : ' + isnull(Cast(@Emp_LATE_MARK as varchar(2)),'') 
--										  + '#Full_PF        ' + ' : ' + isnull(Cast(@Emp_Full_PF AS varchar(2)),'') 	
--										  + '#Prof_Tax		 ' + ' : ' + isnull(Cast(@Emp_PT as varchar(2)),'')	
--										  + '#Fix_Salary     ' + ' : ' + isnull(Cast(@Emp_Fix_Salary as varchar(2)),'')			
--										  + '#Blood_Group    ' + ' : ' + isnull(@Blood_Group,'')
--										  + '#Enroll_No      ' + ' : ' + isnull(Cast(@Enroll_No as varchar(20)),'')	 
--										  + '#Father_Name	 ' + ' : ' + isnull(@Father_Name,'') 
--										  + '#Bank_IFSC_NO   ' + ' : ' + isnull(Cast(@Emp_IFSC_No as varchar(10)),'')	
--										  + '#Confirmation_Date' + ' : ' + (case when @Confirm_Date is null then Replace(Convert(varchar(11),@Confirm_Date,106),' ','-') else '' END)
--										  + '#Probation		 ' + ' : ' + isnull(Cast(@Probation as varchar(10)),'')
--										  + '#Old_Ref_No     ' + ' : ' + isnull(Cast(@Old_Ref_No as varchar(10)),'')
--										  + '#Alpha_Code     ' + ' : ' + isnull(Cast(@Alpha_Code as varchar(20)),'')
--										  + '#Emp_Superior   ' + ' : ' + isnull(Cast(@Emp_Superior as varchar(6)),'') 
--										  + '#IS_LWF         ' + ' : ' + isnull(Cast(@IS_LWF as varchar(6)),'')
--										  + '#Weekday_OT_Rate' + ' : ' + isnull(Cast(@Weekday_OT_Rate as varchar(6)),'')
--										  + '#Weekoff_OT_Rate' + ' : ' + isnull(Cast(@Weekoff_OT_Rate as varchar(6)),'')
--										  + '#Holiday_OT_Rate' + ' : ' + isnull(Cast(@Holiday_OT_Rate as varchar(6)),'')
--										  + '#Business		 ' + ' : ' + isnull(Cast(@Business_Segment as varchar(6)),'')    
--										  + '#Vertical		 ' + ' : ' + isnull(Cast(@Vertical as varchar(6)),'')
--										  + '#sub_Vertical   ' + ' : ' + isnull(Cast(@Sub_Vertical as varchar(6)),'')
--										  + '#Group_Of_Join  ' + ' : ' + isnull(Cast(@Group_of_Joining as varchar(6)),'')
--										  + '#sub_Branch     ' + ' : ' + isnull(Cast(@Sub_Branch as varchar(6)),'')
--										  + '#Salary_Cycle   ' + ' : ' + isnull(Cast(@Salary_Cycle as varchar(6)),'')
--										  + '#Company_Full_PF' + ' : ' + isnull(Cast(@Cmp_Full_PF as varchar(6)),'')
--										  + '#Pay_Scale_Name ' + ' : ' + isnull(Cast(@Pay_Scale_Name as varchar(200)),'')
--										  + '#Customer_Audit ' + ' : ' + ISNULL(CAST(@Customer_Audit as varchar(10)),'')  --Added By Jaina 09-09-2016
						
--									--exec P9999_Audit_Trail @Cmp_ID,'I','Employee Import',@NewValue,@Emp_ID,7931,'',1
--									  exec P9999_Audit_Trail @Cmp_ID,'I','Employee Import',@NewValue,@Emp_Id,@User_Id,@IP_Address,1
--								End 
							

--							---Added By Jimit 02052019 For Inserting Default Scheme to Employees
--								SELECT @Tran_ID = ISNULL(MAX(Tran_ID),0) + 1 FROM T0095_EMP_SCHEME WITH (NOLOCK)

--								Insert Into T0095_EMP_SCHEME(Tran_ID, Cmp_ID, Emp_ID, Scheme_ID, Type, Effective_Date)
--								select  ROW_NUMBER() Over(Order By Scheme_Id asc) + @Tran_ID,@Cmp_ID, @Emp_ID,SCHEME_ID,SCHEME_TYPE,Cast(Cast(@Date_Of_Join As Varchar(11)) As Datetime)
--								FROM    T0040_SCHEME_MASTER WITH (NOLOCK)
--								WHERE   DEFAULT_SCHEME = 1 AND CMP_ID = @CMP_ID 
--										AND	NOT EXISTS(
--														SELECT	1 
--														FROM	T0095_EMP_SCHEME WITH (NOLOCK)
--														WHERE	EMP_ID = @EMP_ID AND TYPE = SCHEME_TYPE 
--																AND EFFECTIVE_DATE = GETDATE()
--													  )
--							--Ended

--						END 
				
					
--				END TRY
--				BEGIN CATCH 
--					DECLARE @w_error VARCHAR(200) 
--					SET @w_error= NULL
				
--					SET @w_error = error_message()
--					IF @w_error is not NULL 
--						BEGIN
--							SET @HasResult = cast(@Emp_Code as varchar(100)) + ','				
--							INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,@w_error,0,'Error in Import Data',GETDATE(),'Employee Master','') 
--						End   
--				END CATCH
--			ABC:
--				IF IsNull(@HasResult,'') <> ''
--					SET @Log_Status = @Log_Status + @HasResult
				
--			FETCH NEXT FROM curXml INTO @Marital_Status,@Gender,@Initial,@Nationality,@Loc_Name,@Wages_Type,@Basic_Salary,@Payment_Mode,@Emp_OT_Min_Limit,@Emp_OT_Max_Limit,@Emp_Full_PF,@Cmp_Full_PF,@Emp_PT,@Alpha_Code,@Emp_Superior,@Salary_Cycle,@Emp_Last_Name,@Group_of_Joining,@Branch_Name,@Grd_Name,@Shift_Name,@Emp_Code,@Emp_First_Name,@Emp_Second_Name,@Date_Of_Join,@desig_Name,@Type_Name,@Bank_Name,@Curr_Name,@Product_name,@Business_Segment,@Vertical,@Sub_Vertical,@Sub_Branch,@Street_1,@City,@State,@Zip_code,@Home_Tel_no,@Mobile_No,@Work_Tel_No,@Work_Email,@Other_Email,@Present_Street,@Present_City,@Present_State,@Present_Post_Box,@Enroll_No,@Blood_Group,@Father_Name,@Emp_IFSC_No,@Confirm_Date,@Probation,@Old_Ref_No,@IS_LWF,@Weekday_OT_Rate,@Weekoff_OT_Rate,@Holiday_OT_Rate,@Group_of_Joining,@Emp_LATE_MARK,@Pan_No,@ESIC_No,@PF_No,@Date_Of_Birth,@Gross_salary,@Salary_Basis_On,@Inc_Bank_Ac_No,@Emp_OT,@Emp_Fix_Salary,@Dept_Name,@Pay_Scale_Name,@Customer_Audit,@EssPassword,@CTC  --Change By Jaina 09-09-2016
--	   END  
--	CLOSE curXml                      
--	DEALLOCATE curXml
--		A:
		
--		if @HasResult = '' And @Log_Status = ''
--			begin
--				Set @Log_Status = '0'
--				return 
--			End	
--		Else
--			begin
--				If @Log_Status = ''
--					Set @Log_Status = @HasResult
				
--				--Set @Log_Status_Details = @Status_Details
--				return  
--			End

			
--END

