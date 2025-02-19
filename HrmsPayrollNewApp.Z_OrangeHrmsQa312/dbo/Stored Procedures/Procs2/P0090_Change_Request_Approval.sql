
CREATE PROCEDURE [dbo].[P0090_Change_Request_Approval] 
	 @Request_Apr_id Numeric(18,0) output,
	 @Request_id Numeric(18,0),
	 @Cmp_id Numeric(18,0),
	 @Emp_ID Numeric(18,0),
	 @Request_Type_id Numeric(18,0),
	 @Change_Reason Varchar(500),
	 @Request_Date datetime,
	 @Shift_From_Date Datetime,
	 @Shift_To_Date Datetime,
	 @Curr_Details Varchar(Max),
	 @New_Details Varchar(Max),
	 @Curr_Tehsil Varchar(200),	
	 @Curr_District Varchar(200),
	 @Curr_Thana Varchar(200),
	 @Curr_City_Village Varchar(200),
	 @Curr_State Varchar(200),
	 @Curr_Pincode Numeric(18,0),
	 @New_Tehsil Varchar(200),
	 @New_District Varchar(200),
	 @New_Thana Varchar(200),
	 @New_City_Village Varchar(200),
	 @New_State Varchar(200),
	 @New_Pincode Numeric(18,0),
	 @Request_status Char(1),
	 @EffectiveDate datetime,
	 @tran_type		char(1),
	 @Qu_Type Numeric(6,0),
	 @Qu_Specialization  Varchar(500),
	 @Qu_Passing_year Numeric(6,0),
	 @Qu_Passing_Score Varchar(100),
	 @Qu_Start_Date datetime,
	 @Qu_End_Date datetime,
	 @Dependant_Name Varchar(500),
	 @Dependant_Relationship Varchar(500),
	 @Dependant_Gender Varchar(1),
	 @Dependant_DOB datetime,
	 @Dependant_Age Numeric(18,1),
	 @Dependant_Is_Resident Numeric(1,0),
	 @Dependant_Is_Depended Numeric(1,0),
	 @Pass_Visa_Citizenship Numeric(18,0),
	 @Pass_Visa_No Varchar(100),
	 @Pass_Visa_Issue_Date datetime,
	 @Pass_Visa_Exp_Date  datetime,
	 @Pass_Visa_Review_Date datetime,
	 @Pass_Visa_Status  Varchar(100),
	 @License_ID Numeric(18,0),
	 @License_Type VarChar(100),
	 @License_IssueDate DateTime,
	 @License_No VarChar(100),
	 @License_ExpDate DateTime,
	 @License_Is_Expired  Numeric(1,0),
	 @Image_Path VarChar(1000),
	 @Curr_IFSC_Code VarChar(200),
	 @Curr_Account_No VarChar(200),
	 @Curr_Branch_Name VarChar(200),
	 @New_IFSC_Code VarChar(200),
	 @New_Account_No VarChar(200),
	 @New_Branch_Name nVarChar(MAX),
	 @Nominees_Address VarChar(500), --Added by nilesh Patel on 16042016
	 @Nominees_Share Numeric(5,0), --Added by nilesh Patel on 16042016
	 @Nominees_For Numeric(5,0), --Added by nilesh Patel on 16042016
	 @Nominees_Row_ID Varchar(100), --Added by nilesh Patel on 16042016
	 @Hospital_Name Varchar(500), --Added by nilesh Patel on 16042016
	 @Hospital_Address Varchar(500), --Added by nilesh Patel on 16042016
	 @Admit_Date DateTime, --Added by nilesh Patel on 16042016
	 @MediCalim_Approval_Amount Numeric(18,2) = 0, --Added by nilesh Patel on 16042016
	 @Old_Pan_No Varchar(200) = '', --Added by nilesh patel on 12072016
	 @New_Pan_No Varchar(200) = '', --Added by nilesh patel on 12072016
	 @Old_Adhar_No Varchar(200)= '' , --Added by nilesh patel on 12072016
	 @New_Adhar_No Varchar(200)= '', --Added by nilesh patel on 12072016
	 @Loan_Installment_Month Numeric(2,0) = 0,  --Added by nilesh patel on 01082016
	 @Loan_Installment_Year Numeric(4,0) = 0,   --Added by nilesh patel on 01082016
	 @Loan_Installment_New_Amt varchar(max) = '', --Added by nilesh patel on 3082016
	 @User_Id Numeric(18,0) = 0,  --Added by nilesh patel on 21042017
	 @IP_Address Varchar(200) = '', --Added by nilesh patel on 21042017
	 @Child_Birth_Date datetime = NULL  --Added by Jaina 27-04-2018

	 	 -----------------------Added by ronakk 22062022 -----------------------------------

	  ,@DepOccupationID int =0
	  ,@DepHobbyID nvarchar(500) = ''
	  ,@DepHobbyName nvarchar(1000) = ''
	  ,@DepCompany nvarchar(200) =''
	  ,@DepCmpCity nvarchar(200) = ''
	  ,@DepStandardId int=0
	  ,@DepSchCol nvarchar(200) = ''
	  ,@DepSchColCity nvarchar(200) = ''
	  ,@DepExtAct nvarchar(200)=''

	 -------------------------End by ronakk 22062022 -----------------------------------


	 
	   ------------------------Added by ronakk 22062022 ----------------------
	 ,@EmpFavSportID Nvarchar(500) = ''
	 ,@EmpFavSportName Nvarchar(1000) = ''
	 ,@EmpHobbyID Nvarchar(500) = ''
	 ,@EmpHobbyName Nvarchar(1000) = ''
	 ,@EmpFavFood Nvarchar(100) = ''
	 ,@EmpFavRestro Nvarchar(100) = ''
	 ,@EmpFavTrvDestination Nvarchar(100) = ''
	 ,@EmpFavFestival Nvarchar(100) = ''
	 ,@EmpFavSportPerson Nvarchar(100) = ''
	 ,@EmpFavSinger Nvarchar(100) = ''
    ----------------------------------End by ronakk 22062022 ---------------------



	 ------------------------Added by ronakk 24062022 ----------------------
	 ,@CurrEmpFavSportID Nvarchar(500) = ''
	 ,@CurrEmpFavSportName Nvarchar(1000) = ''
	 ,@CurrEmpHobbyID Nvarchar(500) = ''
	 ,@CurrEmpHobbyName Nvarchar(1000) = ''
	 ,@CurrEmpFavFood Nvarchar(100) = ''
	 ,@CurrEmpFavRestro Nvarchar(100) = ''
	 ,@CurrEmpFavTrvDestination Nvarchar(100) = ''
	 ,@CurrEmpFavFestival Nvarchar(100) = ''
	 ,@CurrEmpFavSportPerson Nvarchar(100) = ''
	 ,@CurrEmpFavSinger Nvarchar(100) = ''
    ----------------------------------End by ronakk 24062022 ---------------------

	--------------------------------------Added by ronakk 27062022 -----------------------
	 ,@DepOtherHobby nvarchar(1000)=''
	 ,@DepPancard nvarchar(50)=''
	 ,@DepAdharCard nvarchar(50)=''
	 ,@DepHeight nvarchar(20)=''
	 ,@DepWeight nvarchar(20)=''

	 ,@otherFavHobyy nvarchar(1000) = ''
	 ,@otherFavSport nvarchar(1000) = '' 

	--------------------------------------End by ronakk 27062022  -----------------------

	
	---------------------------------------------Added by ronakk 06072022----------------------------------

	,@CurDepID int
	,@CurDepName nvarchar(100)
	,@CurDepGender nvarchar(1) 
	,@CurDepDOB nvarchar(10)
	,@CurDepCAGE numeric(18,2)
	,@CurDepRelationship nvarchar(100)
	,@CurDepISResi int
	,@CurDepISDep int
	,@CurDepImagePath nvarchar(1000) 
	,@CurDepPanCard nvarchar(20)
	,@CurDepAdharCard nvarchar(20)
	,@CurDepHeight nvarchar(10)
	,@CurDepWeight nvarchar(10)
	,@CurDepOccupationID int
	,@CurDepOccupationName nvarchar(100)
	,@CurDepHobbyID nvarchar(500)
	,@CurDepHobbyName nvarchar(1000)
	,@CurDepCompanyName nvarchar(100)
	,@CurDepCompanyCity nvarchar(100)
	,@CurDepStandardID int
	,@CurDepStandardName nvarchar(100)
	,@CurDepSchCol nvarchar(100)
	,@CurDepSchColCity nvarchar(100)
	,@CurDepExtraActivity nvarchar(100)


	------------------------------------------------End  by ronakk 06072022 -------------------------------

	,@DepSpecialization nvarchar(200)	   --Added by ronakk 21072022
	,@CurDepSpecialization nvarchar(200)   --Added by ronakk 21072022


AS
declare @OldValue as  varchar(max)
 -- Declare For increment
 DECLARE @Increment_ID	As NUMERIC(18,0)
 DECLARE @Increment_ID_old	As NUMERIC(18,0)
 DECLARE @Branch_ID As NUMERIC(18,0)
 DECLARE @Cat_ID As NUMERIC(18,0)
 DECLARE @Grd_ID As NUMERIC(18,0)
 DECLARE @Dept_ID	As NUMERIC(18,0)
 DECLARE @Desig_Id As NUMERIC(18,0)
 DECLARE @Type_ID	As	NUMERIC(18,0)
 DECLARE @Bank_ID As NUMERIC(18,0)
 DECLARE @Curr_ID As NUMERIC(18,0)
 DECLARE @Wages_Type As	VARCHAR(10)
 DECLARE @Salary_Basis_On As VARCHAR(20)
 DECLARE @Basic_Salary				NUMERIC(18, 2)
 DECLARE @Gross_Salary				NUMERIC(18, 2)
 DECLARE @Increment_Type			VARCHAR(30)
 DECLARE @Increment_Date			DATETIME 
 DECLARE @Increment_Effective_Date	DATETIME 
 DECLARE @Payment_Mode				VARCHAR(20)
 DECLARE @Inc_Bank_AC_No			VARCHAR(20)
 DECLARE @Emp_OT					NUMERIC(18,0)
 DECLARE @Emp_OT_Min_Limit			VARCHAR(10)
 DECLARE @Emp_OT_Max_Limit			VARCHAR(10)
 DECLARE @Increment_Per				NUMERIC(18, 2)
 DECLARE @Increment_Amount			NUMERIC(18, 2)
 DECLARE @Pre_Basic_Salary			NUMERIC(18, 2)
 DECLARE @Pre_Gross_Salary			NUMERIC(18, 2)
 DECLARE @Increment_Comments		VARCHAR(250)
 DECLARE @Emp_Late_mark				NUMERIC
 DECLARE @Emp_Full_PF				NUMERIC
 DECLARE @Emp_PT					NUMERIC
 DECLARE @Emp_Fix_Salary			NUMERIC
 DECLARE @Emp_Late_Limit			VARCHAR(10) 
 DECLARE @Late_Dedu_type			VARCHAR(10)
 DECLARE @Emp_part_Time				NUMERIC(1,0)
 DECLARE @Is_Master_Rec				TINYINT 	-- Define this parameter in only Insert statement
 DECLARE @Login_ID					NUMERIC(18) 
 DECLARE @Yearly_Bonus_Amount		NUMERIC(22,2) 
 DECLARE @Deputation_End_Date		DATETIME 
 DECLARE @emp_superior				NUMERIC(18,0) 
 DECLARE @Dep_Reminder				TINYINT
 DECLARE @Is_Emp_Master				TINYINT
 DECLARE @CTC						NUMERIC(18,2) 
 DECLARE @Dep_Amount				NUMERIC(22,2) 
 DECLARE @Dep_Month					NUMERIC(18,0) 
 DECLARE @Dep_Year					NUMERIC(18,0) 
 DECLARE @Set_Amount				NUMERIC(22,2) 
 DECLARE @Set_Month					NUMERIC(18,0) 
 DECLARE @Set_Year					NUMERIC(18,0) 
 DECLARE @Emp_Early_mark			NUMERIC(1, 0) 
 DECLARE @Early_Dedu_Type			VARCHAR(10)	
 DECLARE @Emp_Early_Limit			VARCHAR(10)	
 DECLARE @Emp_Deficit_mark			NUMERIC(1, 0) 
 DECLARE @Deficit_Dedu_Type			VARCHAR(10)	 
 DECLARE @Emp_Deficit_Limit			VARCHAR(10)	
 DECLARE @Center_ID					NUMERIC(18,0)
 DECLARE @Emp_wd_ot_rate			NUMERIC(5,1) 
 DECLARE @Emp_wo_ot_rate			NUMERIC(5,1) 
 DECLARE @Emp_ho_ot_rate			NUMERIC(5,1) 
 DECLARE @Pre_CTC_Salary			NUMERIC(18,2)
 DECLARE @Incerment_Amount_gross	NUMERIC(18,2)
 DECLARE @Incerment_Amount_CTC		NUMERIC(18,2)
 DECLARE @Increment_Mode			TINYINT 
 DECLARE @no_of_chlidren			NUMERIC 
 DECLARE @is_metro					TINYINT 
 DECLARE @is_physical				TINYINT 
 DECLARE @Salary_Cycle_id			NUMERIC 
 DECLARE @auto_vpf					NUMERIC(18) 
 DECLARE @Segment_ID				NUMERIC 
 DECLARE @Vertical_ID				NUMERIC 
 DECLARE @SubVertical_ID			NUMERIC 
 DECLARE @subBranch_ID				NUMERIC 
 DECLARE @Monthly_Deficit_Adjust_OT_Hrs tinyint 
 DECLARE @Fix_OT_Hour_Rate_WD numeric(18,3)
 DECLARE @Fix_OT_Hour_Rate_WO_HO numeric(18,3)
 DECLARE @Bank_ID_Two		numeric(18, 0) 
 DECLARE @Payment_Mode_Two	varchar(20)	
 DECLARE @Inc_Bank_AC_No_Two	varchar(20)	
 DECLARE @Bank_Branch_Name	varchar(50)	
 DECLARE @Bank_Branch_Name_Two	varchar(50)	
 DECLARE @Earn_Dec_ID NUMERIC 
 Declare @Shift_Tran_ID Numeric 
 Declare @Leave_ID numeric(18,0)
 
 
 SET @Emp_Late_Limit	= '00:00'
 SET @Is_Master_Rec				  = 0	-- Define this parameter in only Insert statement
 SET @Login_ID					  = 0
 SET @Yearly_Bonus_Amount		  = 0
 SET @Deputation_End_Date		  = NULL 
 SET @emp_superior				  = 0
 SET @Dep_Reminder				 =1
 SET @Is_Emp_Master				 =0
 SET @CTC						  = 0
 SET @Dep_Amount				  = 0
 SET @Dep_Month					  = 0
 SET @Dep_Year					  = 0
 SET @Set_Amount				  = 0
 SET @Set_Month					  = 0
 SET @Set_Year					  = 0
 SET @Emp_Early_mark			  = 0 
 SET @Early_Dedu_Type			 	= ''
 SET @Emp_Early_Limit			 	= '00:00'
 SET @Emp_Deficit_mark			  = 0
 SET @Deficit_Dedu_Type			 	 = ''
 SET @Emp_Deficit_Limit			 	= ''
 SET @Center_ID					  = 0 
 SET @Emp_wd_ot_rate			  = 0
 SET @Emp_wo_ot_rate			  = 0
 SET @Emp_ho_ot_rate			  = 0
 SET @Pre_CTC_Salary			  = 0
 SET @Incerment_Amount_gross	  = 0
 SET @Incerment_Amount_CTC		  = 0
 SET @Increment_Mode			  = 0
 SET @no_of_chlidren			 = 0
 SET @is_metro					  = 0
 SET @is_physical				  = 0
 SET @Salary_Cycle_id			  = 0
 SET @auto_vpf					  = 0 
 SET @Segment_ID				  = 0
 SET @Vertical_ID				  = 0
 SET @SubVertical_ID			  = 0
 SET @subBranch_ID				  = 0 
 SET @Monthly_Deficit_Adjust_OT_Hrs   =0	
 SET @Fix_OT_Hour_Rate_WD  =0		
 SET @Fix_OT_Hour_Rate_WO_HO  =0	
 SET @Bank_ID_Two		  = 0			
 SET @Payment_Mode_Two	 	= ''			
 SET @Inc_Bank_AC_No_Two	 	= ''		
 SET @Bank_Branch_Name	 	= ''			
 SET @Bank_Branch_Name_Two	 	= ''
 SET @Earn_Dec_ID   = 0  	
 SET @Shift_Tran_ID   =0
 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	IF @Shift_From_Date = ''
		Begin
			Set @Shift_From_Date = NULL
		End
		
	If @Curr_Details = '01/01/1900'
		Set @Curr_Details = NULL
		
	IF @Shift_To_Date = ''
		Set @Shift_To_Date = NULL
	
	IF @Curr_Tehsil = ''
		Set @Curr_Tehsil = NULL
		
	IF @Curr_District = ''
		Set @Curr_District = NULL
		
	IF @Curr_Thana = ''
		Set @Curr_Thana = NULL
		
	IF @Curr_City_Village = ''
		Set @Curr_City_Village = NULL
		
	IF @Curr_State = ''
		Set @Curr_State = NULL
		
	IF @Curr_Pincode = 0
		Set @Curr_Pincode = NULL
		
	IF @New_Tehsil = ''
		Set @New_Tehsil = NULL
	
	IF @New_District = ''
		Set @New_District = NULL
	
	IF @New_Thana = ''
		Set @New_Thana = NULL	
		
	IF @New_City_Village = ''
		Set @New_City_Village = NULL
	
	IF @New_State = ''
		Set @New_State = NULL
		
	IF @New_Pincode = 0
		Set @New_State = NULL
		
	If @Qu_Start_Date = '01/01/1900'
		Set @Qu_Start_Date = NULL
		
	If @Qu_End_Date = '01/01/1900'
		Set @Qu_End_Date = NULL
	
	if @Dependant_DOB = '01/01/1900'
		Set @Dependant_DOB = NULL
	
	if @Pass_Visa_Issue_Date = '01/01/1900'
		Set @Pass_Visa_Issue_Date = NULL
		
	if @Pass_Visa_Exp_Date = '01/01/1900'
		Set @Pass_Visa_Exp_Date = NULL
		
	if @Pass_Visa_Review_Date = '01/01/1900'
		Set @Pass_Visa_Review_Date = NULL
		
	if @License_IssueDate = '01/01/1900'
		Set @License_IssueDate = NULL
		
	--if @License_ExpDate = '01/01/1900'
	--	Set @License_ExpDate = NULL
	
	if @Admit_Date = '01/01/1900'
		Set @Admit_Date = NULL
	
	if @Child_Birth_Date = '01/01/1900'  --Added by Jaina 27-04-2018
		set @Child_Birth_Date = NULL
		
	--if @Nominees_Row_ID = 'Self'
	--	Set @Nominees_Row_ID = '0'
	
	-- Added Condition For Cross Company Approval on 11092016
	if Exists(SELECT 1 From T0090_Change_Request_Application Where  Request_id = @Request_id  and Emp_id = @Emp_ID and Request_Type_id = @Request_Type_id)
		BEGIN
			SELECT @Cmp_ID = Cmp_ID From T0090_Change_Request_Application Where  Request_id = @Request_id  and Emp_id = @Emp_ID and Request_Type_id = @Request_Type_id
		End
	
		
		DECLARE @MONTH NUMERIC(18,0)
		DECLARE @YEAR NUMERIC(18,0)
		DECLARE @YEAR_ST_DATE DATETIME
		DECLARE @YEAR_END_DATE DATETIME		
		Declare @App_Count numeric(18,0) = 0
		DECLARE @Appr_Count numeric(18,0) = 0
		Declare @Count numeric(18,0) = 0  --Added by Jaina 11-05-2018
		Declare @Max_Limit numeric(18,0) --Added by Jaina 11-05-2018
		declare @Message varchar(200)
		

		
			-------------------------Added by ronakk 27062022 -------------------
		Declare @OtherHobby nvarchar(1000) =''
		if @Request_Type_id =8 
		begin
		    set @OtherHobby = @DepOtherHobby
		end
		else if  @Request_Type_id =23
		Begin
		       set @OtherHobby = @otherFavHobyy
		End

		-------------------------------End by ronakk 27062022 ---------------


		Declare @Cur_Dep_DOB datetime

		if @CurDepDOB <> ''
		Begin
		 set @Cur_Dep_DOB =  CONVERT(Datetime, @CurDepDOB, 103)
		End
		Else
		Begin
		     set @Cur_Dep_DOB =null
		End


    If Upper(@tran_type) = 'I'
		Begin
			if @Request_Type_id = 20
			BEGIN
				--select @Max_Limit = Max_Limit from T0040_Change_Request_Master where Cmp_ID=@Cmp_Id and Request_type='Child Birth Limit (For Paternity Leave)'
				select @Max_Limit = Max_Leave_Lifetime FROM T0040_LEAVE_MASTER WHERE CMP_ID = @CMP_ID and Leave_Type='Paternity Leave'  --Added by Jaina 14-03-2019
			
				select @App_Count = COUNT(1) FROM T0090_Change_Request_Application where Cmp_id=@Cmp_Id and Emp_ID=@Emp_id and Request_Type_id = 20 and Request_status='P' and Request_id <> @Request_id
				SELECT @Appr_Count = COUNT(1) FROM T0090_Change_Request_Approval where Cmp_id=@Cmp_Id AND Emp_ID=@Emp_id AND Request_Type_id=20 and Request_status = 'A'
				
				set @Count = isnull(@App_Count,0) + ISNULL(@Appr_Count,0)
				
				if @CHILD_BIRTH_DATE > getdate()
				begin
					set @Message = '@@Can''t Allow Future Child Birth Date @@'
					RAISERROR(@Message,16,2)
					RETURN
				end

				
				IF @Max_Limit <= @Count And @Max_Limit <> 0
				BEGIN
					set @Message = '@@Maximum limit is over for Paternity leave Request@@'
					RAISERROR(@Message,16,2)
					RETURN
				END	
				
				
					SET @MONTH = MONTH(@CHILD_BIRTH_DATE)
					SET @YEAR = YEAR(@CHILD_BIRTH_DATE)
					
					SET @YEAR_END_DATE = DBO.GET_MONTH_END_DATE(@MONTH,@YEAR)
					SET @YEAR_ST_DATE = DATEADD(yyyy,-1,@YEAR_END_DATE)									
								
					IF EXISTS (SELECT 1 FROM T0090_CHANGE_REQUEST_APPLICATION WHERE CMP_ID =@CMP_ID 
								AND REQUEST_TYPE_ID=20 AND EMP_ID=@EMP_ID AND Request_status='P'
								AND CHILD_BIRTH_DATE BETWEEN @YEAR_ST_DATE AND @YEAR_END_DATE AND Request_id <> @Request_id)
					BEGIN
						RAISERROR('@@You can''t apply this request for paternity leave within this year@@ ',16,2)
						RETURN
					END
					
					IF EXISTS (SELECT 1 FROM T0090_Change_Request_Approval WHERE CMP_ID =@CMP_ID 
								AND REQUEST_TYPE_ID=20 AND EMP_ID=@EMP_ID 
								AND CHILD_BIRTH_DATE BETWEEN @YEAR_ST_DATE AND @YEAR_END_DATE)
					BEGIN
						RAISERROR('@@You can''t apply this request for paternity leave within this year @@',16,2)
						RETURN
					END
			END
			
			If Exists(Select Request_id From T0090_Change_Request_Approval  Where Emp_id = @Emp_ID and Request_id = @Request_id  and Request_Type_id = @Request_Type_id AND isnull(Request_Apr_ID,0) = isnull(@Request_Apr_id,0) AND Request_status  = 'P')
				begin
					
					Select @Request_id = Request_id From T0090_Change_Request_Approval  Where Emp_id = @Emp_ID and Request_id = @Request_id and Request_Date = @Request_Date and Request_Type_id = @Request_Type_id
					Set @Request_id = 0
					Return
				end
			Else
			Begin
					select @Request_Apr_id = Isnull(max(Request_Apr_id),0) + 1 	From dbo.T0090_Change_Request_Approval 
					
					UPDATE    T0090_Change_Request_Application
						SET      Request_status = @Request_status
								WHERE     (Request_id = @Request_id  and Emp_id = @Emp_ID and Request_Type_id = @Request_Type_id) --and Cmp_ID=@Cmp_ID
								
					insert into T0090_Change_Request_Approval  
					(
					 Request_Apr_id,
					 Request_id,
					 Cmp_id,
					 Emp_ID,
					 Request_Type_id,
					 Change_Reason,
					 Request_Date,
					 Shift_From_Date,
					 Shift_To_Date,
					 Curr_Details,
					 New_Details,
					 Curr_Tehsil,
					 Curr_District,
					 Curr_Thana,
					 Curr_City_Village,
					 Curr_State,
					 Curr_Pincode,
					 New_Tehsil,
					 New_District,
					 New_Thana,
					 New_City_Village,
					 New_State,
					 New_Pincode,
					 Request_status,
					 Effective_Date,
					 Quaulification_ID,
					 Specialization,
                     Passing_Year,
					 Score,
					 Quaulification_Star_Date,
					 Quaulification_End_Date,
					 Dependant_Name,
					 Dependant_Relationship,
					 Dependant_Gender,
					 Dependant_DOB,
					 Dependant_Age,
					 Dependant_Is_Resident,
					 Dependant_Is_Dependant,
					 Pass_Visa_Citizenship,
					 Pass_Visa_No,
					 Pass_Visa_Issue_Date,
					 Pass_Visa_Exp_Date,
					 Pass_Visa_Review_Date,
					 Pass_Visa_Status,
					 License_ID,
					 License_Type,
					 License_IssueDate,
					 License_No,
					 License_ExpDate,
					 License_Is_Expired,
					 Image_path,
					 Curr_IFSC_Code,
					 Curr_Account_No,
					 Curr_Branch_Name,
					 New_IFSC_Code,
					 New_Account_No,
					 New_Branch_Name,
					 Nominess_Address,
					 Nominess_Share,
					 Nominess_For,
					 Nominees_Row_ID,
					 Hospital_Name,
					 Hospital_Address,
				     Admit_Date,
				     MediCalim_Approval_Amount,
				     Old_Pan_No,
				     New_Pan_No,
				     Old_Adhar_No,
				     New_Adhar_No,
				     Loan_Month,
					 Loan_Year,
					 Loan_Skip_Details,
					 Child_Birth_Date


					 
					---------------------------------------- Added by ronakk 22062022 ----------------------------
					,Dep_OccupationID
					,Dep_HobbyID
					,Dep_HobbyName
					,Dep_DepCompanyName
					,Dep_CmpCity
					,Dep_Standard_ID
					,Dep_Shcool_College
					,Dep_SchCity
					,Dep_ExtraActivity
					-------------------------------------------End by ronakk 22062022 ----------------------------

					---------------------------------------- Added by ronakk 22062022 ----------------------------
					  ,Emp_Fav_Sport_id 
					  ,Emp_Fav_Sport_Name 
					  ,Emp_Hobby_id 
					  ,Emp_Hobby_Name 
					  ,Emp_Fav_Food  
				      ,Emp_Fav_Restro 
					  ,Emp_Fav_Trv_Destination 
					  ,Emp_Fav_Festival 
					  ,Emp_Fav_SportPerson 
					  ,Emp_Fav_Singer
					   -------------------------------------------End by ronakk 22062022 ----------------------------


					      ---------------------------------------- Added by ronakk 24062022 ----------------------------
					  ,Curr_Emp_Fav_Sport_id 
					  ,Curr_Emp_Fav_Sport_Name 
					  ,Curr_Emp_Hobby_id 
					  ,Curr_Emp_Hobby_Name 
					  ,Curr_Emp_Fav_Food  
				      ,Curr_Emp_Fav_Restro 
					  ,Curr_Emp_Fav_Trv_Destination 
					  ,Curr_Emp_Fav_Festival 
					  ,Curr_Emp_Fav_SportPerson 
					  ,Curr_Emp_Fav_Singer
					   -------------------------------------------End by ronakk 24062022 ----------------------------

					    -----------------------------------------Added by ronakk 27062022 ---------------------------
					   ,OtherHobby
					   ,Dep_PancardNo
					   ,Dep_AdharcardNo
					   ,Dep_Height
					   ,Dep_Weight
					   ,OtherSports
					   -------------------------------------------End by ronakk 27062022 ---------------------------

					         ----------------------------------------Added by ronakk 06072022 --------------------------
					   ,Curr_Dep_ID 
					   ,Curr_Dep_Name 
					   ,Curr_Dep_Gender 
					   ,Curr_Dep_DOB
					   ,Curr_Dep_CAGE 
					   ,Curr_Dep_Relationship 
					   ,Curr_Dep_ISResi 
					   ,Curr_Dep_ISDep 
					   ,Curr_Dep_ImagePath 
					   ,Curr_Dep_PanCard
					   ,Curr_Dep_AdharCard 
					   ,Curr_Dep_Height 
					   ,Curr_Dep_Weight 
					   ,Curr_Dep_OccupationID 
					   ,Curr_Dep_OccupationName 
					   ,Curr_Dep_HobbyID 
					   ,Curr_Dep_HobbyName 
					   ,Curr_Dep_CompanyName 
					   ,Curr_Dep_CompanyCity 
					   ,Curr_Dep_StandardID
					   ,Curr_Dep_StandardName 
					   ,Curr_Dep_SchCol 
					   ,Curr_Dep_SchColCity
					   ,Curr_Dep_ExtraActivity 
					   ------------------------------------------End  by ronakk 06072022 -------------------------
					    ,Dep_Std_Specialization 		--Added by ronakk 21072022
					   ,Curr_Dep_Std_Specialization --Added by ronakk 21072022



					 ) 
					 VALUES
					 (
					 @Request_Apr_id,
					 @Request_id,
					 @Cmp_id,
					 @Emp_ID,
					 @Request_Type_id,
					 @Change_Reason,
					 @Request_Date,
					 @Shift_From_Date,
					 @Shift_To_Date,
					 @Curr_Details,
					 @New_Details,
					 @Curr_Tehsil,	
					 @Curr_District,
					 @Curr_Thana,
					 @Curr_City_Village,
					 @Curr_State,
					 @Curr_Pincode,
					 @New_Tehsil,
					 @New_District,
					 @New_Thana,
					 @New_City_Village,
					 @New_State,
					 @New_Pincode,
					 @Request_status,
					 @EffectiveDate,
					 @Qu_Type,
					 @Qu_Specialization,
	                 @Qu_Passing_year,
	                 @Qu_Passing_Score,
	                 @Qu_Start_Date,
	                 @Qu_End_Date,
	                 @Dependant_Name,
					 @Dependant_Relationship,
					 @Dependant_Gender,
					 @Dependant_DOB,
					 @Dependant_Age,
					 @Dependant_Is_Resident,
					 @Dependant_Is_Depended,
					 @Pass_Visa_Citizenship,
					 @Pass_Visa_No,
					 @Pass_Visa_Issue_Date,
					 @Pass_Visa_Exp_Date,
					 @Pass_Visa_Review_Date,
					 @Pass_Visa_Status,
					 @License_ID,
					 @License_Type,
					 @License_IssueDate,
					 @License_No,
					 @License_ExpDate,
					 @License_Is_Expired,
					 @Image_Path,
					 @Curr_IFSC_Code,
					 @Curr_Account_No,
					 @Curr_Branch_Name,
					 @New_IFSC_Code,
					 @New_Account_No,
					 @New_Branch_Name,
					 @Nominees_Address,
					 @Nominees_Share,
					 @Nominees_For,
					 @Nominees_Row_ID,
					 @Hospital_Name,
					 @Hospital_Address,
					 @Admit_Date,
					 @MediCalim_Approval_Amount,
					 @Old_Pan_No,
					 @New_Pan_No,
					 @Old_Adhar_No,
					 @New_Adhar_No,
					 @Loan_Installment_Month,
					 @Loan_Installment_Year,
					 @Loan_Installment_New_Amt,
					 @Child_Birth_Date


					 	-----------------------------------------Added by ronakk 22062022 ------------------------------

						 ,@DepOccupationID
						 ,@DepHobbyID
						 ,@DepHobbyName
						 ,@DepCompany
						 ,@DepCmpCity
						 ,@DepStandardId
						 ,@DepSchCol
						 ,@DepSchColCity
						 ,@DepExtAct
				   ----------------------------------------------End by ronakk 22062022 ---------------------------
				    -----------------------------------------Added by ronakk 22062022 ------------------------------
					  ,@EmpFavSportID 
					  ,@EmpFavSportName
					  ,@EmpHobbyID 
					  ,@EmpHobbyName
					  ,@EmpFavFood 
					  ,@EmpFavRestro
					  ,@EmpFavTrvDestination
		              ,@EmpFavFestival
					  ,@EmpFavSportPerson
					  ,@EmpFavSinger

					  -----------------------------------------End by ronakk 22062022 ------------------------------

					      -----------------------------------------Added by ronakk 24062022 ------------------------------
					   ,@CurrEmpFavSportID 
					   ,@CurrEmpFavSportName
					   ,@CurrEmpHobbyID 
					   ,@CurrEmpHobbyName
					   ,@CurrEmpFavFood 
					   ,@CurrEmpFavRestro
					   ,@CurrEmpFavTrvDestination
					   ,@CurrEmpFavFestival
					   ,@CurrEmpFavSportPerson
					   ,@CurrEmpFavSinger
					  
					   -----------------------------------------End by ronakk 24062022 ------------------------------
					    --------------------------------Add by ronakk 27062022--------------------------------
					   ,@OtherHobby
					   ,@DepPancard
					   ,@DepAdharCard
					   ,@DepHeight
					   ,@DepWeight
					   ,@otherFavSport
					   -----------------------------------End by ronakk 27062022 ----------------------------


					          ---------------------------------------------Added by ronakk 06072022 -------------------------------
					   ,@CurDepID 
					   ,@CurDepName
					   ,@CurDepGender 
					   ,@Cur_Dep_DOB 
					   ,@CurDepCAGE 
					   ,@CurDepRelationship 
					   ,@CurDepISResi 
					   ,@CurDepISDep 
					   ,@CurDepImagePath 
					   ,@CurDepPanCard
					   ,@CurDepAdharCard
					   ,@CurDepHeight 
					   ,@CurDepWeight 
					   ,@CurDepOccupationID 
					   ,@CurDepOccupationName
					   ,@CurDepHobbyID 
					   ,@CurDepHobbyName 
					   ,@CurDepCompanyName 
					   ,@CurDepCompanyCity 
					   ,@CurDepStandardID 
					   ,@CurDepStandardName 
					   ,@CurDepSchCol 
					   ,@CurDepSchColCity 
					   ,@CurDepExtraActivity
					   
					   --------------------------------------------------End by ronakk 06072022 ----------------------------

					     ,@DepSpecialization	   --Added by ronakk 21072022
					   ,@CurDepSpecialization  --Added by ronakk 21072022


					 )
					 
					If @Loan_Installment_New_Amt <> ''
						Begin
							Declare @Loan_Apr_Id Numeric(18,0)
							Declare @Loan_New_Install_Amt Numeric(18,2)
							
							Set @Loan_Apr_Id = 0
							Set @Loan_New_Install_Amt = 0
							
							Declare @Loan_ID Numeric(18,0)
							Declare @Loan_Install_Amt Numeric(18,0)
							
							if Exists(SELECT 1 From T0100_Monthly_Loan_Skip_Approval Where Loan_Apr_ID = @Request_Apr_id)
								BEGIN
									Delete From T0100_Monthly_Loan_Skip_Approval Where Request_Apr_ID = @Request_Apr_id
								End
							
							Declare Loan_Cursor Cursor For Select LEFT(data,CHARINDEX(',',data)-1),RIGHT(data,LEN(data)-CHARINDEX(',',data)) From dbo.Split(@Loan_Installment_New_Amt,'#')
							Open Loan_Cursor
							fetch next from Loan_Cursor into @Loan_Apr_Id,@Loan_New_Install_Amt
							while @@fetch_status = 0
								Begin
										Select @Loan_ID = isnull(Loan_ID,0),@Loan_Install_Amt = isnull(Loan_Apr_Installment_Amount,0) From T0120_LOAN_APPROVAL Where Loan_Apr_ID = @Loan_Apr_Id
										Exec P0100_Monthly_Loan_Skip_Approval @Tran_ID = 0,@Request_Apr_ID = @Request_Apr_id,@Request_id = @Request_id,@Cmp_ID = @Cmp_id,@Emp_ID = @Emp_ID,@Loan_Apr_ID = @Loan_Apr_Id,@Loan_ID = @Loan_ID,@Old_Install_Amount = @Loan_Install_Amt,@New_Install_Amount = @Loan_New_Install_Amt,@S_Emp_ID = 0,@Rpt_Level =0 ,@Final_Approval = 1
									fetch next from Loan_Cursor into @Loan_Apr_Id,@Loan_New_Install_Amt
								End
							close Loan_Cursor
							deallocate Loan_Cursor
						End
					 
					 if @Request_Type_id = 1 and @Request_status = 'A'
						Begin
							--Declare @NewDateFormate as varchar = Cast(SELECT Data FROM  dbo.split('15/01/1992','/')where Id = 1 as varchar(2)) + cast(SELECT * FROM  dbo.split('15/01/1992','/')where Id = 2 as varchar(2)) + cast(SELECT * FROM  dbo.split('15/01/1992','/')where Id = 3 as varchar(4))
							set @OldValue = 'New Value' + '#'+ 'Birth Date :' + ISNULL(@New_Details,'') + 'old Value' + '#' + 'Birth Date :' + ISNULL(@Curr_Details,'') + '#' 
							
							--Select @NewDateFormate
							--Select RIGHT(@NewDateFormate,4)+LEFT(@NewDateFormate,2)+SUBSTRING(@NewDateFormate,3,2)
							
							Update T0080_EMP_MASTER Set Date_Of_Birth = CONVERT(datetime ,@New_Details,103)
							where Cmp_id = @Cmp_id and
								  Emp_id = @Emp_ID 
								
						    exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Change Request Details',@OldValue,@Request_Type_id,@Emp_ID,''
						End
					 if @Request_Type_id = 3 and @Request_status = 'A'
						Begin
							DECLARE @VarDate Datetime --= @Shift_From_Date
							
							SET @VarDate = @Shift_From_Date --added jimit 18042016
							
							WHILE @VarDate <= @Shift_To_Date
								BEGIN
									DELETE T0100_Emp_Shift_Detail Where Emp_ID = @Emp_ID and For_Date= @VarDate --Added by Hardik 21/07/2015 to Remove Existing Shift Entry
									EXEC P0100_EMP_SHIFT_DETAIL @Shift_Tran_ID OUTPUT,@Emp_ID,@Cmp_id,@New_Details,@VarDate,'I',1,0,''
									SET @VarDate = DATEADD(DAY, 1, @VarDate)
								END
						End
					 if @Request_Type_id = 4 and @Request_status = 'A'
						Begin
							set @OldValue = 'New Value' + '#'+ 'Maritals status :' + ISNULL(@New_Details,'') + 'old Value' + '#' + 'Maritals status :' + ISNULL(@Curr_Details,'') + '#' 
							
							Update T0080_EMP_MASTER Set Marital_Status = @New_Details 
							where Cmp_id = @Cmp_id and
								  Emp_id = @Emp_ID
							
						    exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Change Request Details',@OldValue,@Request_Type_id,@Emp_ID,''
						End
					 if @Request_Type_id = 5 and @Request_status = 'A'
						Begin
							--set @OldValue = 'Old Value' + '#'+ ' Permanent Address :' + ISNULL(@New_Details,'') + '#' + 'Tehsil :' + ISNULL(@Curr_Tehsil,'') + '#'  + 'District :' + ISNULL(@Curr_District,'') + '#'  + 'Thana id :' + ISNULL(@Curr_Thana,'') + '#' + 'City/Village :' + ISNULL(@Curr_City_Village,'') + '#'+ 'State id :' + ISNULL(@Curr_State,'') + '#' + 'ZipCode :' + ISNULL(@Curr_Pincode,'') + '#'  
							set @OldValue = 'Old Value' + '#'+ ' Permanent Address :' + ISNULL(@New_Details,'') + '#' + 'Tehsil :' + ISNULL(@Curr_Tehsil,'') + '#'  
							
							Update T0080_EMP_MASTER 
							Set Street_1 =   @New_Details,
							    Tehsil	 =   @New_Tehsil,
							    Thana_Id =   @New_Thana,
							    District =   @New_District,
							    City	 =   @New_City_Village,
							    State	 =   @New_State,
							    Zip_code =   @New_Pincode
							where Cmp_id =   @Cmp_id and
								  Emp_id =   @Emp_ID
							
						    exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Change Request Details',@OldValue,@Request_Type_id,@Emp_ID,''
						End
					if @Request_Type_id = 6 and @Request_status = 'A'
						Begin
							set @OldValue = 'Old Value' + '#'+ ' Present Address :' + ISNULL(@New_Details,'') + '#' + 'Tehsil :' + ISNULL(@Curr_Tehsil,'') + '#'  + 'District :' + ISNULL(@Curr_District,'') + '#'  
							
							Update T0080_EMP_MASTER 
							Set Present_Street = @New_Details,
							    Tehsil_Wok = @New_Tehsil,
							    Thana_Id_Wok = @New_Thana,
							    District_Wok = @New_District,
							    Present_City = @New_City_Village,
							    Present_State = @New_State,
							    Present_Post_Box = @New_Pincode
							where Cmp_id = @Cmp_id and
								  Emp_id = @Emp_ID
							
						    exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Change Request Details',@OldValue,@Request_Type_id,@Emp_ID,''
						End
					if @Request_Type_id = 7 and @Request_status = 'A'
						Begin
							Declare @row_id as numeric(6,0)
							Exec P0090_EMP_QUALIFICATION_DETAIL @row_id OUTPUT ,@Emp_ID,@Cmp_id,@Qu_Type,@Qu_Specialization,@Qu_Passing_year,@Qu_Passing_Score,@Qu_Start_Date,@Qu_End_Date,'',@tran_type,0,@Image_Path
						End 
					if @Request_Type_id = 8 and @Request_status = 'A'
						Begin



						  ---Change by ronakk 27062022



							-------------------------Added by ronakk 27062022 ------------------------------------------------------
								declare @OH nvarchar(100)= @OtherHobby 
								declare @OHI nvarchar(1000)
								declare @MH nvarchar(100)=@DepHobbyID
								declare @FHI nvarchar(100) 
								declare @FHName nvarchar(1000)
								declare @HID nvarchar(1000)
								
								
								declare @HobbyCheck as table
								(
								  Hobby nvarchar(100)
								)
								
								--select cast(data  as nvarchar),120 from dbo.Split (@OH,',')  T Where T.Data <> ''
								if not exists( select 1 from T0040_Hobby_Master where Cmp_ID=@Cmp_id and HobbyName in (select cast(data  as nvarchar) from dbo.Split (@OH,',')  T Where T.Data <> ''))
								Begin
								
								insert into T0040_Hobby_Master 
								select cast(data  as nvarchar),@Cmp_id from dbo.Split (@OH,',')  T Where T.Data <> ''
								
								--print 'Yesy'
								
								select @OHI=COALESCE(@OHI + ',' + cast(H_ID as nvarchar),cast(H_ID as nvarchar))  
								from T0040_Hobby_Master where Cmp_ID=@Cmp_id and HobbyName in (select cast(data  as nvarchar) from dbo.Split (@OH,',')  T Where T.Data <> '')
								
								--set @FHI=@MH +','+ @OHI

								if @MH<>'' and @OHI<>''
								set @FHI=@MH +','+ @OHI
								else if @MH<>''
								set @FHI= @MH
								else if @OHI<>''
								set @FHI= @OHI



								End
								else
								Begin
								
								--print 'Boom'
								
								
								insert into @HobbyCheck 
								select cast(data  as nvarchar) from dbo.Split (@OH,',')  T Where T.Data <> ''
								
								
								delete from @HobbyCheck where 
								Hobby in (select HobbyName from T0040_Hobby_Master where Cmp_ID=@Cmp_id and HobbyName in (select cast(data  as nvarchar) from dbo.Split (@OH,',')  T Where T.Data <> ''))
								
								insert into T0040_Hobby_Master 
								select Hobby,@Cmp_id from @HobbyCheck
								
								select @OHI=COALESCE(@OHI + ',' + cast(H_ID as nvarchar),cast(H_ID as nvarchar))  
								from T0040_Hobby_Master where Cmp_ID=@Cmp_id and 
								--HobbyName in (select Hobby from @HobbyCheck)
								HobbyName in (select cast(data  as nvarchar) from dbo.Split (@OH,',')  T Where T.Data <> '')
								
								--set @FHI=@MH +','+ @OHI

								if @MH<>'' and @OHI<>''
								set @FHI=@MH +','+ @OHI
								else if @MH<>''
								set @FHI= @MH
								else if @OHI<>''
								set @FHI= @OHI

								End
								
								
								select  @FHName=COALESCE(@FHName + ',' + cast(HobbyName as nvarchar),cast(HobbyName as nvarchar))  
								from T0040_Hobby_Master where Cmp_ID=@Cmp_id and H_ID in (select cast(data  as int) from dbo.Split (@FHI,',')  T Where T.Data <> '')

								select  @HID=COALESCE(@HID + ',' + cast(H_ID as nvarchar),cast(H_ID as nvarchar))  
								from T0040_Hobby_Master where Cmp_ID=@Cmp_id and H_ID in (select cast(data  as int) from dbo.Split (@FHI,',')  T Where T.Data <> '')
								
								--select @FHI,@FHName,@HID ---Final hobby id and Hobby name 
							-------------------------End by ronakk 27062022 ------------------------------------------------------

							--Change by ronakk 06072022

							if @CurDepID <> 0
							Begin

							   Exec P0090_EMP_CHILDRAN_DETAIL @CurDepID OUTPUT,@Emp_ID,@Cmp_id,@Dependant_Name,@Dependant_Gender,@Dependant_DOB,@Dependant_Age,@Dependant_Relationship,@Dependant_Is_Resident,@Dependant_Is_Depended,'U',0,@Image_Path,@DepPancard,@DepAdharCard,@DepHeight,@DepWeight,@DepOccupationID,@HID,@FHName,@DepCompany,@DepStandardId,@DepSchCol,@DepExtAct,@DepSchColCity,@DepCmpCity,@DepSpecialization

							End
							else
							Begin
							      
						       Declare @row_id_1 as numeric(6,0)
							   Exec P0090_EMP_CHILDRAN_DETAIL @row_id_1 OUTPUT,@Emp_ID,@Cmp_id,@Dependant_Name,@Dependant_Gender,@Dependant_DOB,@Dependant_Age,@Dependant_Relationship,@Dependant_Is_Resident,@Dependant_Is_Depended,@tran_type,0,@Image_Path,@DepPancard,@DepAdharCard,@DepHeight,@DepWeight,@DepOccupationID,@HID,@FHName,@DepCompany,@DepStandardId,@DepSchCol,@DepExtAct,@DepSchColCity,@DepCmpCity,@DepSpecialization

							
							End
							

							--Declare @row_id_1 as numeric(6,0)
							--Exec P0090_EMP_CHILDRAN_DETAIL @row_id_1 OUTPUT,@Emp_ID,@Cmp_id,@Dependant_Name,@Dependant_Gender,@Dependant_DOB,@Dependant_Age,@Dependant_Relationship,@Dependant_Is_Resident,@Dependant_Is_Depended,@tran_type,0,@Image_Path
						End
					if @Request_Type_id = 14 and @Request_status = 'A'
						Begin
							Declare @row_id_12 as numeric(6,0)
							Exec P0090_EMP_DEPENDANT_DETAIL @row_id_12 OUTPUT,@Emp_ID,@Cmp_id,@Dependant_Name,@Dependant_Relationship,@Dependant_DOB,@Dependant_Age,@tran_type,@Nominees_Address,@Nominees_Share,@Dependant_Is_Resident,@Nominees_For,0
						End  
					If @Request_Type_id = 9 and @Request_status = 'A'
						Begin
							Declare @row_id_2 as numeric(6,0) 
							Exec P0090_EMP_IMMIGRATION_DETAIL @row_id_2 OUTPUT,@Emp_ID,@Cmp_id,@Pass_Visa_Citizenship,'Passport',@Pass_Visa_No,@Pass_Visa_Issue_Date,@Pass_Visa_Status,@Pass_Visa_Review_Date,'',@Pass_Visa_Exp_Date,@tran_type,0,@Image_Path
						End
					If @Request_Type_id = 10 and @Request_status = 'A'
						Begin
							
							Declare @row_id_3 as numeric(6,0) 
							Exec P0090_EMP_IMMIGRATION_DETAIL @row_id_3 OUTPUT,@Emp_ID,@Cmp_id,@Pass_Visa_Citizenship,'Visa',@Pass_Visa_No,@Pass_Visa_Issue_Date,@Pass_Visa_Status,@Pass_Visa_Review_Date,'',@Pass_Visa_Exp_Date,@tran_type,0,@Image_Path
							Select @row_id_3
						End
					If @Request_Type_id = 16 and @Request_status = 'A'
						Begin
							Update T0080_Emp_Master 
								Set Pan_No = (CASE WHEN @New_Pan_No = '' THEN Pan_No ELSE @New_Pan_No END)   ,
									Aadhar_Card_No = (CASE WHEN @New_Adhar_No = '' THEN Aadhar_Card_No ELSE @New_Adhar_No END)  
								Where Emp_ID = @Emp_ID and Cmp_ID = @Cmp_id
							
						End
					If @Request_Type_id = 11 and @Request_status = 'A'
						Begin
							Declare @row_id_4 as numeric(6,0) 
							Exec P0090_EMP_LICENSE_DETAIL @row_id_4 OUTPUT,@Emp_ID,@Cmp_id,@License_ID,@License_IssueDate,@License_ExpDate,'',@License_Type,@License_No,@License_Is_Expired,@tran_type
						End
					if @Request_Type_id = 13 and @Request_status = 'A'
						Begin
							Update T0080_EMP_MASTER Set Ifsc_Code = @New_IFSC_Code where Emp_ID = @Emp_ID And Cmp_ID = @Cmp_id
							
							Update I SET 
								I.Bank_ID = @New_Details,
								I.Inc_Bank_AC_No = @New_Account_No,
								Bank_Branch_Name = @New_Branch_Name
							From T0095_INCREMENT I Inner JOIN 
							(
								SELECT MAX(Increment_Effective_Date) as Effective_Date,Emp_ID
								FROM T0095_INCREMENT Where Cmp_ID = @Cmp_id and Increment_Effective_Date <= @EffectiveDate
								GROUP By Emp_ID
							) as Qry
							On I.Increment_Effective_Date = Qry.Effective_Date and I.Emp_ID = Qry.Emp_ID
							Where I.Emp_ID = @Emp_ID and I.Cmp_ID = @Cmp_id
							
							
						End
					if @Request_Type_id = 18 and @Request_status = 'A'
						Begin
							Declare @Left_Date Datetime
							Set @Left_Date = CONVERT(datetime ,@New_Details,103)
							Declare @p1 Numeric(18,2)
							Set @p1 = 0
							exec P0100_LEFT_EMP @Left_ID= @p1 output,@Emp_ID=@Emp_ID,@Cmp_ID=@Cmp_id,@Left_Date=@Left_Date ,@Reg_Accept_Date=@Left_Date,@Left_Reason='Employee Left From Abscoding Request',@New_Employer='',@Is_Terminate='0',@tran_type='Insert',@Uniform_Return=0,@Exit_Interview=0,@Notice_period=0,@Is_Death=0,@Reg_Date=@Left_Date,@Is_FnF_Applicable=1,@RptManager_ID=0,@IS_Retire=0,@User_Id=@User_Id,@IP_Address=@IP_Address,@Request_Apr_ID = @Request_Apr_id
						End
					if @Request_Type_id = 20 and @Request_status = 'A'  --Added by Jaina 27-04-2018
					Begin
							
							Declare @Emp_Increment_Id  Numeric(18,0)
							Declare @Emp_Grd_Id numeric(18,0)

							declare @Leave_Balance numeric(18,2)
							declare @Leave_Validity_Day numeric(18,2)
							declare @Last_Date datetime
							
							SELECT @Emp_Increment_Id = Increment_ID FROM dbo.fn_getEmpIncrement(@Cmp_Id,@Emp_id,GETDATE())
							
							select @Emp_Grd_Id = Grd_ID from T0095_INCREMENT where Cmp_ID=@Cmp_Id and Increment_ID = @Emp_Increment_Id
							
							SELECT @Leave_ID = Leave_ID, @Leave_Balance = Paternity_Leave_Balance,@Leave_Validity_Day = Paternity_Leave_Validity
							from T0040_LEAVE_MASTER where Cmp_ID=@Cmp_Id and Leave_Type='Paternity Leave'
							--select * from T0040_LEAVE_MASTER
							
							exec P0095_LEAVE_OPENING @Leave_Op_ID=0,@Emp_Id=@Emp_Id,@GRD_ID=@Emp_Grd_Id,@Cmp_ID=@Cmp_Id,@Leave_ID=@Leave_ID,@Leave_Op_Days=@Leave_Balance,@for_date=@Child_Birth_Date,@tran_type='Insert',@User_Id=@User_Id,@IP_Address=@IP_Address
							
							insert INTO T0135_Paternity_Leave_Detail(Cmp_Id,Emp_id,Leave_Id,For_Date,Paternity_Balance,Validity_Days,Laps_Status,System_Date) --Added by Jaina 08-05-2018
							SELECT @Cmp_Id,@Emp_Id,@Leave_ID,@Child_Birth_Date,@Leave_Balance,@Leave_Validity_Day,'Pending',GETDATE()
							
					End

						--------------------------------------------------------------Added by ronakk 22062022------------------------------------
						if @Request_Type_id = 23 and @Request_status = 'A'
						Begin
							--set @OldValue = 'Old Value' + '#'+ ' Present Address :' + ISNULL(@New_Details,'') + '#' + 'Tehsil :' + ISNULL(@Curr_Tehsil,'') + '#'  + 'District :' + ISNULL(@Curr_District,'') + '#'  
							



							-------------------------Added by ronakk 27062022 ------------------------------------------------------
								declare @OHF nvarchar(100)= @OtherHobby 
								declare @OHIF nvarchar(1000)
								declare @MHF nvarchar(100)=@EmpHobbyID
								declare @FHIF nvarchar(100) 
								declare @FHNameF nvarchar(1000)
								declare @FHID nvarchar(1000)
								
								
								declare @HobbyCheckF as table
								(
								  Hobby nvarchar(100)
								)
								
								--select cast(data  as nvarchar),120 from dbo.Split (@OH,',')  T Where T.Data <> ''
								if not exists( select 1 from T0040_Hobby_Master where Cmp_ID=@Cmp_id and HobbyName in (select cast(data  as nvarchar) from dbo.Split (@OHF,',')  T Where T.Data <> ''))
								Begin
								
								insert into T0040_Hobby_Master 
								select cast(data  as nvarchar),@Cmp_id from dbo.Split (@OHF,',')  T Where T.Data <> ''
								
								--print 'Yesy'
								
								select @OHIF=COALESCE(@OHIF + ',' + cast(H_ID as nvarchar),cast(H_ID as nvarchar))  
								from T0040_Hobby_Master where Cmp_ID=@Cmp_id and HobbyName in (select cast(data  as nvarchar) from dbo.Split (@OHF,',')  T Where T.Data <> '')
								
								--set @FHIF=@MHF +','+ @OHIF


								if @MHF<>'' and @OHIF<>''
								set @FHIF=@MHF +','+ @OHIF
								else if @MHF<>''
								set @FHIF= @MHF
								else if @OHIF<>''
								set @FHIF= @OHIF

								End
								else
								Begin
								
								--print 'Boom'
								
								
								insert into @HobbyCheckF 
								select cast(data  as nvarchar) from dbo.Split (@OHF,',')  T Where T.Data <> ''
								
								
								delete from @HobbyCheckF where 
								Hobby in (select HobbyName from T0040_Hobby_Master where Cmp_ID=@Cmp_id and HobbyName in (select cast(data  as nvarchar) from dbo.Split (@OHF,',')  T Where T.Data <> ''))
								
								insert into T0040_Hobby_Master 
								select Hobby,@Cmp_id from @HobbyCheckF
								
								select @OHIF=COALESCE(@OHIF + ',' + cast(H_ID as nvarchar),cast(H_ID as nvarchar))  
								from T0040_Hobby_Master where Cmp_ID=@Cmp_id and 
								--HobbyName in (select Hobby from @HobbyCheckF)
								HobbyName in (select cast(data  as nvarchar) from dbo.Split (@OHF,',')  T Where T.Data <> '')
								
								--set @FHIF=@MHF +','+ @OHIF

								if @MHF<>'' and @OHIF<>''
								set @FHIF=@MHF +','+ @OHIF
								else if @MHF<>''
								set @FHIF= @MHF
								else if @OHIF<>''
								set @FHIF= @OHIF



								End
								
								
								select  @FHNameF=COALESCE(@FHNameF + ',' + cast(HobbyName as nvarchar),cast(HobbyName as nvarchar))  
								from T0040_Hobby_Master where Cmp_ID=@Cmp_id and H_ID in (select cast(data  as int) from dbo.Split (@FHIF,',')  T Where T.Data <> '')

								select  @FHID=COALESCE(@FHID + ',' + cast(H_ID as nvarchar),cast(H_ID as nvarchar))  
								from T0040_Hobby_Master where Cmp_ID=@Cmp_id and H_ID in (select cast(data  as int) from dbo.Split (@FHIF,',')  T Where T.Data <> '')
								
								--select @FHIF,@FHNameF,@FHID ---Final hobby id and Hobby name 
							-------------------------End by ronakk 27062022 ------------------------------------------------------






							-------------------------Added by ronakk 27062022 ------------------------------------------------------
								declare @OSF nvarchar(100)= @otherFavSport
								declare @OSIF nvarchar(1000)
								declare @MSF nvarchar(100)=@EmpFavSportID
								declare @FSIF nvarchar(100) 
								declare @FSNameF nvarchar(1000)
								declare @FSID nvarchar(1000)
								
								
								declare @SportCheckF as table
								(
								  Sport nvarchar(100)
								)
								
								--select cast(data  as nvarchar),120 from dbo.Split (@OH,',')  T Where T.Data <> ''
								if not exists( select 1 from T0040_Fav_Sport_Master where Cmp_ID=@Cmp_id and Sport_Name in (select cast(data  as nvarchar) from dbo.Split (@OSF,',')  T Where T.Data <> ''))
								Begin
								
								insert into T0040_Fav_Sport_Master 
								select cast(data  as nvarchar),@Cmp_id from dbo.Split (@OSF,',')  T Where T.Data <> ''
								
								--print 'Yesy'
								
								select @OSIF=COALESCE(@OSIF + ',' + cast(FS_ID as nvarchar),cast(FS_ID as nvarchar))  
								from T0040_Fav_Sport_Master where Cmp_ID=@Cmp_id and Sport_Name in (select cast(data  as nvarchar) from dbo.Split (@OSF,',')  T Where T.Data <> '')
								
								--set @FSIF=@MSF +','+ @OSIF


								if @MSF<>'' and @OSIF<>''
								set @FSIF=@MSF +','+ @OSIF
								else if @MSF<>''
								set @FSIF= @MSF
								else if @OSIF<>''
								set @FSIF= @OSIF


								End
								else
								Begin
								
								--print 'Boom'
								
								
								insert into @SportCheckF 
								select cast(data  as nvarchar) from dbo.Split (@OSF,',')  T Where T.Data <> ''
								
								
								delete from @SportCheckF where 
								Sport in (select Sport_Name from T0040_Fav_Sport_Master where Cmp_ID=@Cmp_id and Sport_Name in (select cast(data  as nvarchar) from dbo.Split (@OSF,',')  T Where T.Data <> ''))
								
								insert into T0040_Fav_Sport_Master 
								select Sport,@Cmp_id from @SportCheckF

								select @OSIF=COALESCE(@OSIF + ',' + cast(FS_ID as nvarchar),cast(FS_ID as nvarchar))  
								from T0040_Fav_Sport_Master where Cmp_ID=@Cmp_id and 
								--Sport_Name in (select Sport from @SportCheckF)
								Sport_Name in (select cast(data  as nvarchar) from dbo.Split (@OSF,',')  T Where T.Data <> '')
								
								--set @FSIF=@MSF +','+ @OSIF


								if @MSF<>'' and @OSIF<>''
								set @FSIF=@MSF +','+ @OSIF
								else if @MSF<>''
								set @FSIF= @MSF
								else if @OSIF<>''
								set @FSIF= @OSIF

								End
								
								
								select  @FSNameF=COALESCE(@FSNameF + ',' + cast(Sport_Name as nvarchar),cast(Sport_Name as nvarchar))  
								from T0040_Fav_Sport_Master where Cmp_ID=@Cmp_id and FS_ID in (select cast(data  as int) from dbo.Split (@FSIF,',')  T Where T.Data <> '')

								select  @FSID=COALESCE(@FSID + ',' + cast(FS_ID as nvarchar),cast(FS_ID as nvarchar))  
								from T0040_Fav_Sport_Master where Cmp_ID=@Cmp_id and FS_ID in (select cast(data  as int) from dbo.Split (@FSIF,',')  T Where T.Data <> '')
								
								--select @FSIF,@FSNameF ---Final hobby id and Hobby name 
							-------------------------End by ronakk 27062022 ------------------------------------------------------






							Update T0080_EMP_MASTER 
							Set 
							     Emp_Fav_Sport_id = @FSID
								,Emp_Fav_Sport_Name = @FSNameF
								,Emp_Hobby_id = @FHID
								,Emp_Hobby_Name = @FHNameF
								,Emp_Fav_Food = @EmpFavFood
								,Emp_Fav_Restro = @EmpFavRestro
								,Emp_Fav_Trv_Destination = @EmpFavTrvDestination
								,Emp_Fav_Festival = @EmpFavFestival
								,Emp_Fav_SportPerson = @EmpFavSportPerson
								,Emp_Fav_Singer = @EmpFavSinger 

							where Cmp_id = @Cmp_id and
								  Emp_id = @Emp_ID

							
						   -- exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Change Request Details',@OldValue,@Request_Type_id,@Emp_ID,''
						End
						--------------------------------------------------------------End by ronakk 22062022 ------------------------------------------------



					IF @Request_Type_id = 2 and @Request_status = 'A'
						Begin
							select 
							@Increment_ID_old = TI.Increment_ID,
							@Branch_ID = Branch_ID,
							@Cat_ID = Cat_ID,
							@Grd_ID = Grd_ID,
							@Dept_ID = Dept_ID,
							@Desig_Id = Desig_Id,
							@Type_ID = Type_ID,
							@Bank_ID = Bank_ID,
							@Curr_ID = Curr_ID ,
							@Wages_Type = Wages_Type,
							@Salary_Basis_On = Salary_Basis_On,
							@Basic_Salary = Basic_Salary,
							@Gross_Salary = Gross_Salary,
							@Increment_Type = 'Transfer',
							@Increment_Date = @Request_Date,
							@Increment_Effective_Date = @EffectiveDate,
							@Payment_Mode = Payment_Mode,
							@Inc_Bank_AC_No = Inc_Bank_AC_No,
							@Emp_OT = Emp_OT,
							@Emp_OT_Min_Limit = Emp_OT_Min_Limit,
							@Emp_OT_Min_Limit = Emp_OT_Min_Limit,
							@Emp_OT_Max_Limit = Emp_OT_Max_Limit,
							@Increment_Per = Increment_Per, 
							@Increment_Amount = Increment_Amount,
							@Pre_Basic_Salary = Pre_Basic_Salary,
							@Pre_Gross_Salary = Pre_Gross_Salary,
							@Increment_Comments = Increment_Comments,
							@Emp_Late_mark = Emp_Late_mark,
							@Emp_Full_PF = Emp_Full_PF,
							@Emp_PT = Emp_PT,
							@Emp_Fix_Salary = Emp_Fix_Salary,
							@Emp_Late_Limit = Emp_Late_Limit,
							@Late_Dedu_type = Late_Dedu_type,
							@Emp_part_Time  = Emp_part_Time,
							--@Is_Master_Rec = Is_Master_Rec,  /* Comment Ankit 26082016 - New Increment Entry So Is_Master_Rec Set 0  */
							@Login_ID = Login_ID,
							@Yearly_Bonus_Amount = Yearly_Bonus_Amount,
							@Deputation_End_Date = Deputation_End_Date,
							@CTC = CTC,
							@Emp_Early_mark = Emp_Early_mark,
							@Early_Dedu_Type = Early_Dedu_Type,
							@Emp_Early_Limit = Emp_Early_Limit,
							@Emp_Deficit_mark = Emp_Deficit_mark,
							@Deficit_Dedu_Type = Deficit_Dedu_Type,
							@Emp_Deficit_Limit = Emp_Deficit_Limit,
							@Center_ID = Center_ID,
							@Emp_wd_ot_rate = Emp_WeekDay_OT_Rate,
							@Emp_wo_ot_rate = Emp_WeekOff_OT_Rate,
							@Emp_ho_ot_rate = Emp_Holiday_OT_Rate,
							@Pre_CTC_Salary = Pre_CTC_Salary,
							@Incerment_Amount_gross = Incerment_Amount_gross,
							@Incerment_Amount_CTC = Incerment_Amount_CTC,
							@Increment_Mode = Increment_Mode,
							@no_of_chlidren = Emp_Childran,
							@is_metro = is_Metro_city,
							@is_physical = is_physical,
							@Salary_Cycle_id = SalDate_id,
							@auto_vpf = Emp_Auto_Vpf,
							@Segment_ID = Segment_ID,
							@Vertical_ID = Vertical_ID,
							@SubVertical_ID = SubVertical_ID,
							@subBranch_ID = subBranch_ID,
							@Monthly_Deficit_Adjust_OT_Hrs = Monthly_Deficit_Adjust_OT_Hrs,	
							@Fix_OT_Hour_Rate_WD = Fix_OT_Hour_Rate_WD,
							@Fix_OT_Hour_Rate_WO_HO = Fix_OT_Hour_Rate_WO_HO,
							@Bank_ID_Two = Bank_ID_Two,
							@Payment_Mode_Two = Payment_Mode_Two,
							@Inc_Bank_AC_No_Two = @Inc_Bank_AC_No_Two,
							@Bank_Branch_Name = Bank_Branch_Name,
							@Bank_Branch_Name_Two = Bank_Branch_Name_Two
							from t0095_increment TI inner join
							(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment
							 Where Increment_effective_Date <= @EffectiveDate and Emp_ID = @Emp_ID Group by emp_ID) new_inc
							 on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
							 Where TI.Increment_effective_Date <= @EffectiveDate and ti.Emp_ID = @Emp_ID
							 
							--Select
							--@Branch_ID As Branch_ID,
							--@Cat_ID As	Cat_ID,
							--@Grd_ID As	Grd_ID,
							--@Dept_ID As	Dept_ID,
							--@Desig_Id As	Desig_Id,
							--@Type_ID As	Type_ID,
							--@Bank_ID As	Bank_ID,
							--@Curr_ID As	Curr_ID,
							--@Wages_Type As	Wages_Type,
							--@Salary_Basis_On As	Salary_Basis_On,
							--@Basic_Salary As	Basic_Salary,
							--@Gross_Salary As	Gross_Salary,
							--@Increment_Type As	Increment_Type,
							--@Increment_Date As	Increment_Date,
							--@Increment_Effective_Date As	Increment_Effective_Date,
							--@Payment_Mode As	Payment_Mode,
							--@Inc_Bank_AC_No As	Inc_Bank_AC_No,
							--@Emp_OT As	Emp_OT,
							--@Emp_OT_Min_Limit As	Emp_OT_Min_Limit,
							--@Emp_OT_Min_Limit As	Emp_OT_Min_Limit,
							--@Emp_OT_Max_Limit As	Emp_OT_Max_Limit,
							--@Increment_Per As	Increment_Per, 
							--@Increment_Amount As	Increment_Amount,
							--@Pre_Basic_Salary As	Pre_Basic_Salary,
							--@Pre_Gross_Salary As	Pre_Gross_Salary,
							--@Increment_Comments As	Increment_Comments,
							--@Emp_Late_mark As	Emp_Late_mark,
							--@Emp_Full_PF As	Emp_Full_PF,
							--@Emp_PT As	Emp_PT,
							--@Emp_Fix_Salary As	Emp_Fix_Salary,
							--@Emp_part_Time As	Emp_part_Time,
							--@Late_Dedu_type As	Late_Dedu_type,
							--@Emp_Late_Limit As	Emp_Late_Limit,
							--@Is_Master_Rec As	Is_Master_Rec,
							--@Login_ID As Login_ID,
							--@Yearly_Bonus_Amount As	Yearly_Bonus_Amount,
							--@Deputation_End_Date As	Deputation_End_Date,
							--@Emp_Early_mark As	Emp_Early_mark,
							--@Early_Dedu_Type As	Early_Dedu_Type,
							--@Emp_Early_Limit As	Emp_Early_Limit,
							--@Emp_Deficit_mark As	Emp_Deficit_mark,
							--@Deficit_Dedu_Type As	Deficit_Dedu_Type,
							--@Emp_Deficit_Limit As	Emp_Deficit_Limit,
							--@Center_ID  As	Center_ID,
							--@Emp_wd_ot_rate As	Emp_wd_ot_rate,
							--@Emp_wo_ot_rate As	Emp_wo_ot_rate,
							--@Emp_ho_ot_rate As	Emp_ho_ot_rate,
							--@Pre_CTC_Salary As	Pre_CTC_Salary,
							--@Incerment_Amount_gross As	Incerment_Amount_gross,
							--@Incerment_Amount_CTC As	Incerment_Amount_CTC,
							--@Increment_Mode As	Increment_Mode,
							--@no_of_chlidren As	no_of_chlidren,
							--@is_metro As	is_metro,
							--@is_physical As	is_physical,
							--@Salary_Cycle_id As	Salary_Cycle_id,
							--@auto_vpf As auto_vpf,
							--@Segment_ID As	Segment_ID,
							--@Vertical_ID As	Vertical_ID,
							--@SubVertical_ID As	SubVertical_ID,
							--@subBranch_ID As subBranch_ID,
							--@Monthly_Deficit_Adjust_OT_Hrs As	Monthly_Deficit_Adjust_OT_Hrs,
							--@Fix_OT_Hour_Rate_WD As	Fix_OT_Hour_Rate_WD,
							--@Fix_OT_Hour_Rate_WO_HO As	Fix_OT_Hour_Rate_WO_HO,
							--@Bank_ID_Two As	Bank_ID_Two,
							--@Payment_Mode_Two As	Payment_Mode_Two,
							--@Inc_Bank_AC_No_Two As	Inc_Bank_AC_No_Two,
							--@Bank_Branch_Name As	Bank_Branch_Name,
							--@Bank_Branch_Name_Two As	Bank_Branch_Name_Two

							
							--Select *
							--from t0095_increment TI inner join
							--(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment
							-- Where Increment_effective_Date <= @EffectiveDate and Emp_ID = @Emp_ID Group by emp_ID) new_inc
							-- on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
							-- Where TI.Increment_effective_Date <= @EffectiveDate and ti.Emp_ID = @Emp_ID
							 	
						EXEC P0095_INCREMENT_INSERT 
						    @Increment_ID OUTPUT ,
							@Emp_ID,
							@Cmp_ID,
							@New_Details,
							@Cat_ID,
							@Grd_ID,
							@Dept_ID,
							@Desig_Id,
							@Type_ID,
							@Bank_ID,
							@Curr_ID,
							@Wages_Type,
							@Salary_Basis_On,
							@Basic_Salary,
							@Gross_Salary,
							@Increment_Type,
							@Increment_Date,
							@Increment_Effective_Date,
							@Payment_Mode,
							@Inc_Bank_AC_No,
							@Emp_OT,
							@Emp_OT_Min_Limit,
							@Emp_OT_Max_Limit,
							@Increment_Per,
							@Increment_Amount,
							@Pre_Basic_Salary,
							@Pre_Gross_Salary,
							@Increment_Comments,
							@Emp_Late_mark,
							@Emp_Full_PF,
							@Emp_PT,
							@Emp_Fix_Salary,
							@Emp_Late_Limit,
							@Late_Dedu_type,
							@Emp_part_Time,
							@Is_Master_Rec,
							@Login_ID,
							@Yearly_Bonus_Amount,
							@Deputation_End_Date,
							@emp_superior,
							@Dep_Reminder,
							@Is_Emp_Master,
							@CTC,
							@Dep_Amount,
							@Dep_Month,
							@Dep_Year,
							@Set_Amount,
							@Set_Month,
							@Set_Year,
							@Emp_Early_mark,
							@Early_Dedu_Type,
							@Emp_Early_Limit,
							@Emp_Deficit_mark,
							@Deficit_Dedu_Type,
							@Emp_Deficit_Limit,
							@Center_ID,
							@Emp_wd_ot_rate,
							@Emp_wo_ot_rate,
							@Emp_ho_ot_rate,
							@Pre_CTC_Salary,
							@Incerment_Amount_gross,
							@Incerment_Amount_CTC,
							@Increment_Mode,
							@no_of_chlidren,
							@is_metro,
							@is_physical,
							@Salary_Cycle_id,
							@auto_vpf,
							@Segment_ID,
							@Vertical_ID,
							@SubVertical_ID,
							@subBranch_ID,
							@Monthly_Deficit_Adjust_OT_Hrs,	
							@Fix_OT_Hour_Rate_WD,
							@Fix_OT_Hour_Rate_WO_HO,
							@Bank_ID_Two,
							@Payment_Mode_Two,
							@Inc_Bank_AC_No_Two,
							@Bank_Branch_Name,
							@Bank_Branch_Name_Two
						
						SELECT @Earn_Dec_ID = ISNULL(MAX(AD_TRAN_ID),0) FROM T0100_EMP_EARN_DEDUCTION
						INSERT INTO [T0100_EMP_EARN_DEDUCTION]
						   ([AD_TRAN_ID]
						   ,[CMP_ID]
						   ,[EMP_ID]
						   ,[AD_ID]
						   ,[INCREMENT_ID]
						   ,[FOR_DATE]
						   ,[E_AD_FLAG]
						   ,[E_AD_MODE]
						   ,[E_AD_PERCENTAGE]
						   ,[E_AD_AMOUNT]
						   ,[E_AD_MAX_LIMIT]
						   ,[E_AD_YEARLY_AMOUNT])
						   (
						   Select
						    (@Earn_Dec_ID + ROW_NUMBER() OVER ( ORDER BY AD_TRAN_ID )) as row_id,
						    [CMP_ID]
						   ,[EMP_ID]
						   ,[AD_ID]
						   ,@Increment_ID
						   ,[FOR_DATE]
						   ,[E_AD_FLAG]
						   ,[E_AD_MODE]
						   ,[E_AD_PERCENTAGE]
						   ,[E_AD_AMOUNT]
						   ,[E_AD_MAX_LIMIT]
						   ,[E_AD_YEARLY_AMOUNT]
						   From T0100_EMP_EARN_DEDUCTION where Cmp_id = @cmp_id and Emp_ID = @Emp_ID and INCREMENT_ID = @Increment_ID_old)
						   Update T0090_Change_Request_Approval SET Increment_ID = @Increment_ID,Increment_ID_old = @Increment_ID_old where Cmp_id = @cmp_id and Request_id = @Request_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 	
						   Update T0080_EMP_MASTER Set Increment_ID = @Increment_ID,Branch_ID = @New_Details where Cmp_id = @cmp_id and Emp_ID = @Emp_ID --and INCREMENT_ID = @Increment_ID_old 
						   
						End   
			 End
		End
		Else If Upper(@tran_type) = 'D'
		BEGIN
			 
			 
			--Declare @Increment_ID Numeric(18,0)
			Declare @Request_App_ID Numeric(18,0)
			Select @Request_App_ID = Request_id From T0090_Change_Request_Approval where  Request_Apr_ID = @Request_Apr_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id
			--Declare @Increment_ID_old Numeric(18,0)
			--Select Request_Apr_ID From T0090_Change_Request_Approval where  Request_Apr_ID = @Request_Apr_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id
			
			If exists (Select Request_Apr_ID From T0090_Change_Request_Approval where  Request_Apr_ID = @Request_Apr_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id) 
				Begin
					
					if @Request_Type_id = 1 -- For Birthday Change Request 
					Begin
									
							UPDATE EM
							SET EM.Date_Of_Birth = (Case When CRA.Curr_Details = '' THEN NULL ELSE CONVERT(datetime,CRA.Curr_Details,103) End)
							FROM T0080_EMP_MASTER	EM
							INNER JOIN T0090_Change_Request_Approval CRA
							on  EM.Emp_ID  = CRA.Emp_ID and EM.Cmp_ID = CRA.Cmp_id
							Where CRA.Request_Apr_ID = @Request_Apr_id and CRA.Cmp_ID = @cmp_id and CRA.Emp_ID = @Emp_ID and CRA.Request_Type_id = @Request_Type_id 
							
							if exists(SELECT Request_id FROM T0115_Request_Level_Approval where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id )
								BEGIN
									Delete From T0115_Request_Level_Approval where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 
								End
							if exists(SELECT Request_id FROM T0090_Change_Request_Application Where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id )	
								BEGIN
									Update T0090_Change_Request_Application SET Request_status = 'P' Where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 
								End
								
							Delete From T0090_Change_Request_Approval where Request_Apr_ID = @Request_Apr_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 	
					End
					if @Request_Type_id = 3 -- For Change Shift 
						Begin
							
							Declare @Old_Shift_From_Date Datetime
							Declare @Old_Shift_To_Date Datetime
							
							Declare @old_New_Details Numeric
							
							Select 
							@Old_Shift_From_Date = CRA.Shift_From_Date,
							@Old_Shift_To_Date = CRA.Shift_To_Date,
							@old_New_Details = CRA.New_Details
							FROM T0080_EMP_MASTER	EM
							INNER JOIN T0090_Change_Request_Approval CRA
							on  EM.Emp_ID  = CRA.Emp_ID and EM.Cmp_ID = CRA.Cmp_id
							Where CRA.Request_id = @Request_App_ID and CRA.Cmp_ID = @cmp_id and CRA.Emp_ID = @Emp_ID and CRA.Request_Type_id = @Request_Type_id 
							
													
							If Exists(Select Sal_tran_Id From T0200_MONTHLY_SALARY where Emp_ID=@Emp_ID And 
								@Old_Shift_From_Date >= Month_St_Date and @Old_Shift_To_Date <= Isnull( Cutoff_Date, Month_End_Date))
								Begin
									 Raiserror('@@This Months Salary Exists.So You Cant Delete This Record.@@',16,2)
									 Set @Request_Apr_id = 0
									 Return @Request_Apr_id
								End
							Else
								Begin
									
									--Delete From T0115_Request_Level_Approval where Request_id = @Request_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id and S_Emp_Id = @S_Emp_Id
									if exists(SELECT Request_id FROM T0115_Request_Level_Approval where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id )
									BEGIN
										Delete From T0115_Request_Level_Approval where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 
										
									End
									if exists(SELECT Request_id FROM T0090_Change_Request_Application Where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id )	
									BEGIN
										Update T0090_Change_Request_Application SET Request_status = 'P' Where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 
									End
									Delete From T0090_Change_Request_Approval where Request_Apr_ID = @Request_Apr_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 	
									
									Delete From T0100_EMP_SHIFT_DETAIL Where Emp_ID = @Emp_ID and Cmp_ID = @cmp_id and Shift_ID = @old_New_Details and For_Date >= @Old_Shift_From_Date and For_Date <= @Old_Shift_To_Date
								End
						End
					if @Request_Type_id = 4 -- For Maritals Status Request 
					Begin
							
						    UPDATE EM
							SET EM.Marital_Status = CRA.Curr_Details
							FROM T0080_EMP_MASTER	EM
							INNER JOIN T0090_Change_Request_Approval CRA
							on  EM.Emp_ID  = CRA.Emp_ID and EM.Cmp_ID = CRA.Cmp_id
							Where CRA.Request_Apr_ID = @Request_Apr_id and CRA.Cmp_ID = @cmp_id and CRA.Emp_ID = @Emp_ID and CRA.Request_Type_id = @Request_Type_id 
							
							if exists(SELECT Request_id FROM T0115_Request_Level_Approval where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id )
								BEGIN
									Delete From T0115_Request_Level_Approval where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 
									
								End
							if exists(SELECT Request_id FROM T0090_Change_Request_Application Where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id )	
								BEGIN
									Update T0090_Change_Request_Application SET Request_status = 'P' Where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 
								End
							Delete From T0090_Change_Request_Approval where Request_Apr_ID = @Request_Apr_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 	
					End
					if @Request_Type_id = 5 -- For Permanent Address Request 
					Begin
							
						    UPDATE EM
							Set EM.Street_1 = CRA.Curr_Details,
							    EM.Tehsil	 = CRA.Curr_Tehsil,
							    EM.Thana_Id =  CRA.Curr_Thana,
							    EM.District =  CRA.Curr_District,
							    EM.City	 =   CRA.Curr_City_Village,
							    EM.State	 =   CRA.Curr_State,
							    EM.Zip_code =   CRA.Curr_Pincode
							FROM T0080_EMP_MASTER	EM
							INNER JOIN T0090_Change_Request_Approval CRA
							on  EM.Emp_ID  = CRA.Emp_ID and EM.Cmp_ID = CRA.Cmp_id
							Where CRA.Request_Apr_ID = @Request_Apr_id and CRA.Cmp_ID = @cmp_id and CRA.Emp_ID = @Emp_ID and CRA.Request_Type_id = @Request_Type_id 
							
							if exists(SELECT Request_id FROM T0115_Request_Level_Approval where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id )
								BEGIN
									Delete From T0115_Request_Level_Approval where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 
									Update T0090_Change_Request_Application SET Request_status = 'P' Where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 
								End
							if exists(SELECT Request_id FROM T0090_Change_Request_Application Where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id )	
									BEGIN
										Update T0090_Change_Request_Application SET Request_status = 'P' Where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 
									End	
							Delete From T0090_Change_Request_Approval where Request_Apr_ID = @Request_Apr_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 	
					End
					if @Request_Type_id = 6 -- For Present Address Request 
					Begin
							
						    UPDATE EM
							Set Present_Street = CRA.Curr_Details,
							    Tehsil_Wok = CRA.Curr_Tehsil,
							    Thana_Id_Wok = CRA.Curr_Thana,
							    District_Wok = CRA.Curr_District,
							    Present_City = CRA.Curr_City_Village,
							    Present_State = CRA.Curr_State,
							    Present_Post_Box = CRA.Curr_Pincode
							FROM T0080_EMP_MASTER	EM
							INNER JOIN T0090_Change_Request_Approval CRA
							on  EM.Emp_ID  = CRA.Emp_ID and EM.Cmp_ID = CRA.Cmp_id
							Where CRA.Request_Apr_ID = @Request_Apr_id and CRA.Cmp_ID = @cmp_id and CRA.Emp_ID = @Emp_ID and CRA.Request_Type_id = @Request_Type_id 
							
							if exists(SELECT Request_id FROM T0115_Request_Level_Approval where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id )
								BEGIN
									Delete From T0115_Request_Level_Approval where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 
									--Update T0090_Change_Request_Application SET Request_status = 'P' Where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 
								End
							if exists(SELECT Request_id FROM T0090_Change_Request_Application Where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id )	
									BEGIN
										Update T0090_Change_Request_Application SET Request_status = 'P' Where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 
									End	
							Delete From T0090_Change_Request_Approval where Request_Apr_ID = @Request_Apr_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 	
					End
					if @Request_Type_id = 13
						Begin
							
							Declare @EffectiveDate_1 Datetime
							Select @EffectiveDate_1 = Effective_Date From T0090_Change_Request_Approval CRA where CRA.Request_Apr_ID = @Request_Apr_id and CRA.Cmp_ID = @cmp_id and CRA.Emp_ID = @Emp_ID and CRA.Request_Type_id = @Request_Type_id 
							
							Update T0080_EMP_MASTER
								SET Ifsc_Code = CRA.Curr_IFSC_Code
							FROM T0080_EMP_MASTER	EM
							INNER JOIN T0090_Change_Request_Approval CRA
							on  EM.Emp_ID  = CRA.Emp_ID and EM.Cmp_ID = CRA.Cmp_id
							Where CRA.Request_Apr_ID = @Request_Apr_id and CRA.Cmp_ID = @cmp_id and CRA.Emp_ID = @Emp_ID and CRA.Request_Type_id = @Request_Type_id 
							
							Update I SET 
								I.Bank_ID = CRA.Curr_Details,
								I.Inc_Bank_AC_No = CRA.Curr_Account_No,
								I.Bank_Branch_Name = CRA.Curr_Branch_Name
							From T0095_INCREMENT I Inner JOIN 
							(
								SELECT MAX(Increment_Effective_Date) as Effective_Date,Emp_ID
								FROM T0095_INCREMENT Where Cmp_ID = @Cmp_id and Increment_Effective_Date <= @EffectiveDate_1
								GROUP By Emp_ID
							) as Qry
							On I.Increment_Effective_Date = Qry.Effective_Date and I.Emp_ID = Qry.Emp_ID
							Inner JOIN T0090_Change_Request_Approval CRA
							on  I.Emp_ID  = CRA.Emp_ID and I.Cmp_ID = CRA.Cmp_id
							Where CRA.Request_Apr_ID = @Request_Apr_id and CRA.Cmp_ID = @cmp_id and CRA.Emp_ID = @Emp_ID and CRA.Request_Type_id = @Request_Type_id 
							
			
							
							Update I SET 
								I.Bank_ID = CRA.Curr_Details,
								I.Inc_Bank_AC_No = CRA.Curr_Account_No,
								I.Bank_Branch_Name = CRA.Curr_Branch_Name
							From T0095_INCREMENT I Inner JOIN 
							(
								SELECT MAX(Increment_Effective_Date) as Effective_Date,Emp_ID
								FROM T0095_INCREMENT Where Cmp_ID = @Cmp_id and Increment_Effective_Date <= @EffectiveDate_1
								GROUP By Emp_ID
							) as Qry
							On I.Increment_Effective_Date = Qry.Effective_Date and I.Emp_ID = Qry.Emp_ID
							Inner JOIN T0090_Change_Request_Approval CRA
							on  I.Emp_ID  = CRA.Emp_ID and I.Cmp_ID = CRA.Cmp_id
							Where CRA.Request_Apr_ID = @Request_Apr_id and CRA.Cmp_ID = @cmp_id and CRA.Emp_ID = @Emp_ID and CRA.Request_Type_id = @Request_Type_id 
							
							if exists(SELECT Request_id FROM T0115_Request_Level_Approval where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id )
								BEGIN
									Delete From T0115_Request_Level_Approval where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id
								End
							if exists(SELECT Request_id FROM T0090_Change_Request_Application Where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id )	
								BEGIN
									Update T0090_Change_Request_Application SET Request_status = 'P' Where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 
								End	
							Delete From T0090_Change_Request_Approval where Request_Apr_ID = @Request_Apr_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 	
						End
					if @Request_Type_id = 7 -- For Qualification
						Begin 
							
							if exists(SELECT Request_id FROM T0115_Request_Level_Approval where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id )
								BEGIN
									Delete From T0115_Request_Level_Approval where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 
								End
							if exists(SELECT Request_id FROM T0090_Change_Request_Application Where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id )	
									BEGIN
										Update T0090_Change_Request_Application SET Request_status = 'P' Where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 
									End	
							Declare @Qual_ID Numeric(6,0)
							Select @Qual_ID = Quaulification_ID From T0090_Change_Request_Approval  where Request_Apr_ID = @Request_Apr_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 	
							Delete From T0090_EMP_QUALIFICATION_DETAIL where emp_id=@Emp_ID And Qual_ID=@Qual_ID 
							Delete From T0090_Change_Request_Approval where Request_Apr_ID = @Request_Apr_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 	
						End 
					if @Request_Type_id = 8 -- For Dependent
						Begin 


							Declare @DepID int
							Select @DepID = Curr_Dep_ID From T0090_Change_Request_Approval WITH (NOLOCK) 
							where Request_Apr_ID = @Request_Apr_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 

						if @DepID<>0
						Begin


						   
						   Update ECD
						   Set ECD.Name=RA.Curr_Dep_Name
						       ,ECD.Gender = RA.Curr_Dep_Gender
							   ,ECD.Date_Of_Birth = RA.Curr_Dep_DOB
							   ,ECD.C_Age = RA.Curr_Dep_CAGE
							   ,ECD.Relationship = RA.Curr_Dep_Relationship
							   ,ECD.Is_Resi = RA.Curr_Dep_ISResi
							   ,ECD.Is_Dependant = RA.Curr_Dep_ISDep
							   ,ECD.Image_Path = RA.Curr_Dep_ImagePath
							   ,ECD.Pan_Card_No = RA.Curr_Dep_PanCard
							   ,ECD.Adhar_Card_No = RA.Curr_Dep_AdharCard
							   ,ECD.Height = RA.Curr_Dep_Height
							   ,ECD.Weight = RA.Curr_Dep_Weight
							   ,ECD.OccupationID = RA.Curr_Dep_OccupationID
							   ,ECD.HobbyID = RA.Curr_Dep_HobbyID
							   ,ECD.HobbyName = RA.Curr_Dep_HobbyName
							   ,ECD.DepCompanyName = RA.Curr_Dep_CompanyName
							   ,ECD.CmpCity = RA.Curr_Dep_CompanyCity
							   ,ECD.Standard_ID = RA.Curr_Dep_StandardID
							   ,ECD.Shcool_College = RA.Curr_Dep_SchCol
							   ,ECD.City = RA.Curr_Dep_SchColCity
							   ,ECD.ExtraActivity = RA.Curr_Dep_ExtraActivity
							    ,ECD.Std_Specialization =RA.Curr_Dep_Std_Specialization --Added by ronakkk 25072022

							   From  T0090_EMP_CHILDRAN_DETAIL ECD
							   inner join T0090_Change_Request_Approval RA On ECD.Row_ID = RA.Curr_Dep_ID and ECD.Emp_ID= RA.Emp_ID
							   where RA.Request_id = @Request_id and ECD.Emp_ID = @Emp_ID and RA.Request_Type_id = @Request_Type_id
							   and ECD.Row_ID =RA.Curr_Dep_ID
						   

						    if exists(SELECT Request_id FROM T0115_Request_Level_Approval WITH (NOLOCK) where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id )
								BEGIN
									Delete From T0115_Request_Level_Approval where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 
								End
							if exists(SELECT Request_id FROM T0090_Change_Request_Application WITH (NOLOCK) Where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id )	
									BEGIN
										Update T0090_Change_Request_Application SET Request_status = 'P' Where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 
									End	
							Delete From T0090_Change_Request_Approval where Request_id = @Request_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 

						End
						else
						Begin

							if exists(SELECT Request_id FROM T0115_Request_Level_Approval WITH (NOLOCK) where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id )
								BEGIN
									Delete From T0115_Request_Level_Approval where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 
								End
							if exists(SELECT Request_id FROM T0090_Change_Request_Application WITH (NOLOCK) Where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id )	
									BEGIN
										Update T0090_Change_Request_Application SET Request_status = 'P' Where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 
									End	
							Declare @Depedant_Name Varchar(100)
							Select @Depedant_Name = Dependant_Name From T0090_Change_Request_Approval WITH (NOLOCK) where Request_Apr_ID = @Request_Apr_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 	
							Delete FROM T0090_EMP_CHILDRAN_DETAIL where Emp_ID = @Emp_ID and Name = @Depedant_Name 
							Delete From T0090_Change_Request_Approval where Request_Apr_ID = @Request_Apr_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 

						End


							
							--if exists(SELECT Request_id FROM T0115_Request_Level_Approval where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id )
							--	BEGIN
							--		Delete From T0115_Request_Level_Approval where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 
							--	End
							--if exists(SELECT Request_id FROM T0090_Change_Request_Application Where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id )	
							--		BEGIN
							--			Update T0090_Change_Request_Application SET Request_status = 'P' Where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 
							--		End	
							--Declare @Depedant_Name Varchar(100)
							--Select @Depedant_Name = Dependant_Name From T0090_Change_Request_Approval  where Request_Apr_ID = @Request_Apr_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 	
							--Delete FROM T0090_EMP_CHILDRAN_DETAIL where Emp_ID = @Emp_ID and Name = @Depedant_Name 
							--Delete From T0090_Change_Request_Approval where Request_Apr_ID = @Request_Apr_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 	
						End 
					if @Request_Type_id = 9 -- For Passport
						Begin 
							
							if exists(SELECT Request_id FROM T0115_Request_Level_Approval where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id )
								BEGIN
									Delete From T0115_Request_Level_Approval where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 
								End
							if exists(SELECT Request_id FROM T0090_Change_Request_Application Where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id )	
									BEGIN
										Update T0090_Change_Request_Application SET Request_status = 'P' Where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 
									End	
							Declare @passport_no Varchar(100)
							Select @passport_no = Pass_Visa_No From T0090_Change_Request_Approval  where Request_Apr_ID = @Request_Apr_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 	
							Delete FROM T0090_EMP_IMMIGRATION_DETAIL where Emp_ID = @Emp_ID and Imm_No = @passport_no 
							Delete From T0090_Change_Request_Approval where Request_Apr_ID = @Request_Apr_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 	
						End 
					if @Request_Type_id = 10 -- For Visa
						Begin 
							
							if exists(SELECT Request_id FROM T0115_Request_Level_Approval where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id )
								BEGIN
									Delete From T0115_Request_Level_Approval where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 
								End
							if exists(SELECT Request_id FROM T0090_Change_Request_Application Where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id )	
									BEGIN
										Update T0090_Change_Request_Application SET Request_status = 'P' Where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 
									End	
							Declare @visa_no Varchar(100)
							Select @visa_no = Pass_Visa_No From T0090_Change_Request_Approval  where Request_Apr_ID = @Request_Apr_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 	
							Delete FROM T0090_EMP_IMMIGRATION_DETAIL where Emp_ID = @Emp_ID and Imm_No = @visa_no 
							Delete From T0090_Change_Request_Approval where Request_Apr_ID = @Request_Apr_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 	
						End 
					if @Request_Type_id = 11 -- For License
						Begin 
							
							if exists(SELECT Request_id FROM T0115_Request_Level_Approval where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id )
								BEGIN
									Delete From T0115_Request_Level_Approval where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 
								End
							if exists(SELECT Request_id FROM T0090_Change_Request_Application Where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id )	
									BEGIN
										Update T0090_Change_Request_Application SET Request_status = 'P' Where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 
									End	
							Declare @LicenseID Varchar(100)
							Select @LicenseID = License_ID From T0090_Change_Request_Approval  where Request_Apr_ID = @Request_Apr_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 	
							Delete FROM T0090_EMP_LICENSE_DETAIL where Emp_ID = @Emp_ID and LIC_ID = @LicenseID 
							Delete From T0090_Change_Request_Approval where Request_Apr_ID = @Request_Apr_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 	
						End
					if @Request_Type_id = 2 -- For Branch Request 
					Begin
								
						    	SELECT @Increment_ID = Increment_ID,@Increment_ID_old = Increment_ID_old FROM T0090_Change_Request_Approval where Request_Apr_ID = @Request_Apr_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 	
						      
						    	UPDATE EM
								Set EM.Branch_ID = CRA.Curr_Details,
									EM.Increment_ID = @Increment_ID_old
								FROM T0080_EMP_MASTER	EM
								INNER JOIN T0090_Change_Request_Approval CRA
								on  EM.Emp_ID  = CRA.Emp_ID and EM.Cmp_ID = CRA.Cmp_id
								Where CRA.Request_Apr_ID = @Request_Apr_id and CRA.Cmp_ID = @cmp_id and CRA.Emp_ID = @Emp_ID and CRA.Request_Type_id = @Request_Type_id 
															
								Delete FROM T0100_Emp_Manager_History where Increment_id = @Increment_ID
								
								Delete From  T0100_EMP_EARN_DEDUCTION  where increment_id = @Increment_ID
								
								Delete From T0095_INCREMENT where increment_id = @Increment_ID
								
								if exists(SELECT Request_id FROM T0115_Request_Level_Approval where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id )
								BEGIN
									Delete From T0115_Request_Level_Approval where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 
									--Update T0090_Change_Request_Application SET Request_status = 'P' Where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 
								End
								if exists(SELECT Request_id FROM T0090_Change_Request_Application Where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id )	
									BEGIN
										Update T0090_Change_Request_Application SET Request_status = 'P' Where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 
									End	
								
								Delete From T0090_Change_Request_Approval where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 	
								
					End
					if @Request_Type_id = 12 -- For Othes   Added By Jaina 31-10-2015
					Begin
						--Added By Jaina 2-11-2015
						if exists(SELECT Request_id FROM T0090_Change_Request_Application Where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id )	
						BEGIN
							Update T0090_Change_Request_Application SET Request_status = 'P' Where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 
						End	
						Delete From T0090_Change_Request_Approval where Request_Apr_ID = @Request_Apr_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 	
					End
					if @Request_Type_id = 14 -- For Nominees Details 
						Begin
							if exists(SELECT Request_id FROM T0115_Request_Level_Approval where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id )
								BEGIN
									Delete From T0115_Request_Level_Approval where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 
								End
							if exists(SELECT Request_id FROM T0090_Change_Request_Application Where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id )	
									BEGIN
										Update T0090_Change_Request_Application SET Request_status = 'P' Where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 
									End	
							Declare @Nominees_Name Varchar(100)
							Select  @Nominees_Name = Dependant_Name From T0090_Change_Request_Approval  where Request_Apr_ID = @Request_Apr_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 	
							Delete FROM T0090_EMP_DEPENDANT_DETAIL where Emp_ID = @Emp_ID and Upper(Name) = Upper(@Nominees_Name) 
							Delete From T0090_Change_Request_Approval where Request_Apr_ID = @Request_Apr_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 	
 		
						End
					if @Request_Type_id = 15 -- For Medicalim 
						Begin
							if exists(SELECT Request_id FROM T0115_Request_Level_Approval where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id )
								BEGIN
									Delete From T0115_Request_Level_Approval where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 
								End
							if exists(SELECT Request_id FROM T0090_Change_Request_Application Where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id )	
								BEGIN
									Update T0090_Change_Request_Application SET Request_status = 'P' Where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 
								End	
									
							Delete From T0090_Change_Request_Approval where Request_Apr_ID = @Request_Apr_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 	
						End
					if @Request_Type_id = 16 -- For Pan Card & Adhar Card 
						Begin
							
							if exists(SELECT Request_id FROM T0115_Request_Level_Approval where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id )
								BEGIN
									Delete From T0115_Request_Level_Approval where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 
								End
							if exists(SELECT Request_id FROM T0090_Change_Request_Application Where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id )	
								BEGIN
									Update T0090_Change_Request_Application SET Request_status = 'P' Where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 
								End
							
							Update EM
								SET Pan_No = RA.Old_Pan_No,
									Aadhar_Card_No = RA.Old_Adhar_No
							From T0080_EMP_MASTER EM Inner JOIN  T0090_Change_Request_Approval RA
							On EM.Emp_ID = RA.Emp_ID
							where Request_Apr_ID = @Request_Apr_id and RA.Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 	
							
							Delete From T0090_Change_Request_Approval where Request_Apr_ID = @Request_Apr_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 	
						End
					if @Request_Type_id = 17 -- For Skip Monthly Loan Installment
						Begin
							
							Declare @Sal_Month Numeric(2,0)
							Declare @Sal_Year Numeric(4,0)
							
							Set @Sal_Month = 0
							Set @Sal_Year = 0
							
							Select @Sal_Month = Loan_Month,@Sal_Year = Loan_Year From T0090_Change_Request_Approval Where Request_Apr_ID = @Request_Apr_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 	
							
							if exists(SELECT 1 From T0200_MONTHLY_SALARY Where Month(Month_St_Date) = @Sal_Month AND Year(Month_St_Date) = @Sal_Year AND Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID)
								BEGIN
									--RAISERROR ('Salary Exists So You Can not Delete it.',16,1)
									Set @Request_Apr_id = -1
									return 
								END
							Else
								Begin
									if exists(SELECT Request_id FROM T0115_Request_Level_Approval where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id )
										BEGIN
											Delete From T0115_Request_Level_Approval where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id
										End
									if exists(SELECT Request_id FROM T0090_Change_Request_Application Where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id )	
										BEGIN
											Update T0090_Change_Request_Application SET Request_status = 'P' Where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 
										End
									
									Delete From T0090_Change_Request_Approval where Request_Apr_ID = @Request_Apr_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 
									Delete From T0100_Monthly_Loan_Skip_Approval where Request_Apr_ID = @Request_Apr_id and Emp_ID = @Emp_ID -- For Delete Apr Records
									Delete From T0100_Monthly_Loan_Skip_Approval where Request_ID = @Request_App_ID and Emp_ID = @Emp_ID -- For Delete Reporting Level Table
								End
							
						End
					if @Request_Type_id = 18 -- For Absconding
						Begin
							if exists(SELECT Request_id FROM T0115_Request_Level_Approval where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id )
								BEGIN
									Delete From T0115_Request_Level_Approval where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id
								End
							if exists(SELECT Request_id FROM T0090_Change_Request_Application Where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id )	
								BEGIN
									Update T0090_Change_Request_Application SET Request_status = 'P' Where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 
								End
							
							Declare @LeftDate Datetime
							Set @LeftDate = ''
								
							Select 
							@LeftDate = CONVERT(datetime,CRA.New_Details,103) 
							FROM T0080_EMP_MASTER	EM
							INNER JOIN T0090_Change_Request_Approval CRA
							on  EM.Emp_ID  = CRA.Emp_ID and EM.Cmp_ID = CRA.Cmp_id
							Where CRA.Request_Apr_ID = @Request_Apr_id and CRA.Emp_ID = @Emp_ID and CRA.Request_Type_id = @Request_Type_id
																	
							Declare @Left_id Numeric(18,2)
							Select @Left_id = Left_ID From T0100_LEFT_EMP Where Emp_ID = @Emp_ID and Reg_Date = @LeftDate
										 
							exec P0100_LEFT_EMP @Left_ID= @Left_id output,@Emp_ID=@Emp_ID,@Cmp_ID=@Cmp_id,@Left_Date=@LeftDate ,@Reg_Accept_Date=@LeftDate,@Left_Reason='',@New_Employer='',@Is_Terminate='0',@tran_type='Delete',@Uniform_Return=0,@Exit_Interview=0,@Notice_period=0,@Is_Death=0,@Reg_Date=@LeftDate,@Is_FnF_Applicable=1,@RptManager_ID=0,@IS_Retire=0,@User_Id=@User_Id,@IP_Address=@IP_Address,@Request_Apr_ID = @Request_Apr_id
							Delete From T0090_Change_Request_Approval where Request_Apr_ID = @Request_Apr_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 	
						End
					if @Request_Type_id = 19
							BEGIN
								if exists(SELECT Request_id FROM T0115_Request_Level_Approval where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id )
									BEGIN
										Delete From T0115_Request_Level_Approval where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id
									End
								if exists(SELECT Request_id FROM T0090_Change_Request_Application Where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id )	
									BEGIN
										Update T0090_Change_Request_Application SET Request_status = 'P' Where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 
									End
								Delete From T0090_Change_Request_Approval where Request_Apr_ID = @Request_Apr_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 
							End
					IF @Request_Type_id = 20   --Child Birth Detail   --Added by Jaina 30-04-2018
						begin
																			
							if exists (select 1 from T0040_LEAVE_MASTER where Leave_Type = 'Paternity Leave' AND Cmp_ID=@Cmp_id)
							BEGIN
								
								
								declare @From_Date datetime
								declare @To_Date datetime								
								
								select @Leave_ID = Leave_ID from T0040_LEAVE_MASTER where Leave_Type = 'Paternity Leave' and Cmp_ID=@Cmp_ID
								
								Create table #Paternity_Leave
								(
									Leave_Tran_Id numeric(18,0),
									Emp_id numeric(18,0),
									For_Date datetime,
									Leave_Opening numeric(18,2),
									Leave_Closing numeric(18,2),
									Laps_Days numeric(18,2),
									From_Date datetime,
									To_Date datetime
								)
								
								insert INTO #Paternity_Leave
								EXEC P_RESET_PATERNITY_LEAVE @CMP_ID = @CMP_ID,@EMP_ID=@EMP_ID
																								
								SELECT @From_Date = From_Date, @To_Date = To_Date 
								FROM #PATERNITY_LEAVE WHERE Emp_id=@emp_ID and From_Date = @Child_Birth_Date
												
							EnD
												
											
							IF EXISTS (SELECT  1 FROM T0100_LEAVE_APPLICATION LA INNER JOIN 
									       T0110_LEAVE_APPLICATION_DETAIL LAd ON LA.Leave_Application_ID = LAd.Leave_Application_ID INNER JOIN
										   T0040_LEAVE_MASTER L ON L.Leave_ID = LAd.Leave_ID INNER JOIN
										   T0090_Change_Request_Approval CRA ON CRA.Emp_ID = LA.Emp_ID INNER JOIN
										   T0040_Change_Request_Master CM ON CM.Request_id = CRA.Request_Type_id
										WHERE L.Cmp_ID = @Cmp_id AND L.Leave_Type = 'Paternity Leave' AND CM.Request_type = 'Child Birth Detail'
											AND La.Emp_ID = @Emp_ID	AND LAd.From_Date BETWEEN @From_Date AND @To_Date )
								  BEGIN
										RAISERROR('@@Reference Exists, In Leave Application@@',16,2)
										return
								  END							
							ELSE IF EXISTS (SELECT 1 FROM T0140_LEAVE_TRANSACTION LT INNER JOIN 
												T0040_LEAVE_MASTER LA ON LT.Leave_ID = LA.Leave_ID INNER JOIN
												T0090_Change_Request_Approval CRA ON CRA.Emp_ID = LT.Emp_ID INNER JOIN
												T0040_Change_Request_Master CM ON CM.Request_id = CRA.Request_Type_id
										WHERE LT.Cmp_ID = @Cmp_id AND LA.Leave_Type = 'Paternity Leave' AND CM.Request_type = 'Child Birth Detail'
										and lt.Emp_ID = @Emp_ID AND LT.For_Date BETWEEN @From_Date AND @To_Date AND LT.Leave_Used > 0)
									BEGIN
										RAISERROR('@@Reference Exists, In Leave Approval@@',16,2)
										return
									END
							ELSE
									BEGIN
										
										DELETE FROM T0095_LEAVE_OPENING WHERE CMP_ID = @CMP_ID AND FOR_DATE = @CHILD_BIRTH_DATE AND EMP_ID = @EMP_ID and Leave_ID =@Leave_Id
										DELETE FROM T0140_LEAVE_TRANSACTION WHERE CMP_ID = @CMP_ID AND EMP_ID = @EMP_ID AND FOR_DATE = @CHILD_BIRTH_DATE and Leave_ID =@Leave_Id
										DELETE FROM T0135_PATERNITY_LEAVE_DETAIL WHERE CMP_ID = @CMP_ID AND EMP_ID = @EMP_ID AND FOR_DATE = @CHILD_BIRTH_DATE
									END
	 
							if exists(SELECT Request_id FROM T0115_Request_Level_Approval where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id )
									BEGIN
										Delete From T0115_Request_Level_Approval where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id
									End
								if exists(SELECT Request_id FROM T0090_Change_Request_Application Where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id )	
									BEGIN
										Update T0090_Change_Request_Application SET Request_status = 'P' Where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 
									End
								Delete From T0090_Change_Request_Approval where Request_Apr_ID = @Request_Apr_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 
						end

						------------------------------Added by ronakk 22062022 ---------------------------------------

					if @Request_Type_id = 23 -- For Favourite Details
					Begin
							
						    UPDATE EM
							Set 

								 Emp_Fav_Sport_id 	= CRA.Curr_Emp_Fav_Sport_id 
								 ,Emp_Fav_Sport_Name = CRA.Curr_Emp_Fav_Sport_Name 
								 ,Emp_Hobby_id = CRA.Curr_Emp_Hobby_id 
								 ,Emp_Hobby_Name = CRA.Curr_Emp_Hobby_Name 
								 ,Emp_Fav_Food = CRA.Curr_Emp_Fav_Food  
								 ,Emp_Fav_Restro = CRA.Curr_Emp_Fav_Restro 
								 ,Emp_Fav_Trv_Destination = CRA.Curr_Emp_Fav_Trv_Destination 
								 ,Emp_Fav_Festival = CRA.Curr_Emp_Fav_Festival 
								 ,Emp_Fav_SportPerson = CRA.Curr_Emp_Fav_SportPerson 
								 ,Emp_Fav_Singer = CRA.Curr_Emp_Fav_Singer


							FROM T0080_EMP_MASTER	EM
							INNER JOIN T0090_Change_Request_Approval CRA
							on  EM.Emp_ID  = CRA.Emp_ID and EM.Cmp_ID = CRA.Cmp_id
							Where CRA.Request_Apr_ID = @Request_Apr_id and CRA.Cmp_ID = @cmp_id and CRA.Emp_ID = @Emp_ID and CRA.Request_Type_id = @Request_Type_id 
							
							if exists(SELECT Request_id FROM T0115_Request_Level_Approval WITH (NOLOCK) where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id )
								BEGIN
									Delete From T0115_Request_Level_Approval where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 
									--Update T0090_Change_Request_Application SET Request_status = 'P' Where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 
								End
							if exists(SELECT Request_id FROM T0090_Change_Request_Application WITH (NOLOCK) Where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id )	
									BEGIN
										Update T0090_Change_Request_Application SET Request_status = 'P' Where Request_id = @Request_App_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 
									End	
							Delete From T0090_Change_Request_Approval where Request_Apr_ID = @Request_Apr_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 	
					End

						------------------------------End by ronakk 22062022 ---------------------------------------
				End
		End
	
END

